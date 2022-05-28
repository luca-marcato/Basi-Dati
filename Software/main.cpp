#include <cstdio>
#include <iostream>
#include <iomanip>
#include "dependencies/include/libpq-fe.h"

#define PG_HOST		"127.0.0.1"
#define PG_USER		"postgres"
#define PG_DB		"ItaliExpress"
#define PG_PASS		"admin"
#define PG_PORT		5432

void checkResults(PGresult* res, const PGconn* conn) {
	if(PQresultStatus(res) != PGRES_TUPLES_OK) {
		std::cout<<"Something went wrong:"<<std::endl<<PQerrorMessage(conn);
		PQclear(res);
		exit(1);
	}
}

template<typename T> void printElement(T t, const int& width)
{
    std::cout << std::left << std::setw(width) << std::setfill(' ') << t;
}

int main(int argc, char **argv) {
	std::cout<<"Starting connection.."<<std::endl;
	
	char conninfo[250];
	
	//Stringa per la conessione
	sprintf(conninfo, "user=%s password=%s dbname=%s hostaddr=%s port=%d",
			PG_USER, PG_PASS, PG_DB, PG_HOST, PG_PORT);
	
	//Connessione
	PGconn *conn = PQconnectdb(conninfo);
	
	if(PQstatus(conn) != CONNECTION_OK) {
		std::cout<<"Errore di connessione"<<std::endl<<PQerrorMessage(conn);
		PQfinish(conn);
		exit(1);
	}
	
	std::cout<<"Database connected successfully"<<std::endl;
	
	std::string query_1 = "SELECT Utente.Email, COUNT(*) as NumeroResi \
						   FROM Reso, Utente \
						   WHERE Reso.Utente = Utente.Email \
						    \
						   GROUP BY Utente.Email \
						   ORDER BY NumeroResi DESC";

	std::string query_2 = "SELECT Nome, NumeroTelefono, Email, ProdottiPrime \
						   FROM Fornitore JOIN \
						   ( \
						   	   SELECT Fornitore as PIVA, COUNT(*) as ProdottiPrime \
							   FROM Prodotto \
							   WHERE Prime = TRUE \
							   GROUP BY PIVA \
							   ORDER BY ProdottiPrime DESC \
							   LIMIT(5) \
						   ) as FornitorePrime \
						   ON Fornitore.PIVA = FornitorePrime.PIVA";

	std::string query_3 = "  DROP VIEW IF EXISTS FornitoreEstero; \
							 CREATE VIEW FornitoreEstero as \
							 SELECT PIVA \
							 FROM Fornitore, Stabilimento \
							 WHERE Stabilimento.Fornitore = Fornitore.PIVA \
							 AND Stato <> 'IT'; \
							 \
							 SELECT Nome, Cognome, Citta \
							 FROM Utente, Indirizzo, \
							 ( \
								 SELECT DISTINCT ProdottiAcquistati.Utente \
								 FROM Prodotto JOIN \
								 ( \
									 SELECT ProdottiSalvati.Prodotto, ProdottiSalvati.Utente \
									 FROM Ordine, Carrello, ProdottiSalvati \
									 WHERE Ordine.Carrello = Carrello.id \
									 AND Ordine.Utente = Carrello.Utente \
									 AND Carrello.id = ProdottiSalvati.Carrello \
									 AND Carrello.Utente = ProdottiSalvati.Utente \
								 ) as ProdottiAcquistati \
								 ON ProdottiAcquistati.Prodotto = Prodotto.Codice \
								 WHERE Prodotto.Fornitore IN (SELECT * FROM FornitoreEstero) \
							 ) as Utenti \
							 WHERE Utente.Email = Utenti.Utente \
							 AND Utente.Residenza = Indirizzo.id;";

	std::string query_4 = "SELECT Nome, Quantita, ProdottiAcquistati.Ordine, ProdottiAcquistati.Utente, ProdottiAcquistati.CodiceSpedizione \
						   FROM Prodotto JOIN \
						   ( \
							   SELECT Prodotto as Codice, Quantita, InfoAcquisto.Carrello as Ordine, InfoAcquisto.Utente, InfoAcquisto.Codice as CodiceSpedizione \
							   FROM ProdottiSalvati JOIN \
							   ( \
								   SELECT Carrello, Utente, Codice \
								   FROM Ordine JOIN Spedizione \
								   ON Ordine.CodiceSpedizione = Spedizione.Codice \
								   WHERE Ordine.PuntoDiRitiro =  \
								   ( \
									   SELECT Id  \
									   FROM Indirizzo \
									   WHERE Via = $1::varchar \
									   AND NumeroCivico = $2::varchar \
									   AND CAP = $3::varchar \
									   AND Citta = $4::varchar \
								   ) \
								   ORDER BY DataEffettiva \
								   LIMIT(5) \
							   ) as InfoAcquisto \
							   ON InfoAcquisto.Utente = ProdottiSalvati.Utente \
							   AND InfoAcquisto.Carrello = ProdottiSalvati.Carrello \
						   ) as ProdottiAcquistati \
						   ON Prodotto.Codice = ProdottiAcquistati.Codice";

	std::string query_5 = "DROP VIEW IF EXISTS OrdiniPerCircuto; \
						   CREATE VIEW OrdiniPerCircuto as \
						   SELECT Circuito, Ordine.Utente, COUNT(*) as OrdiniEffettuati \
						   FROM Ordine, CartaDiCredito \
						   WHERE Ordine.CartaDiCredito = CartaDiCredito.Numero \
						   GROUP BY Circuito, Ordine.Utente; \
						   \
						   SELECT UtenteDatoImportoTotale.Email, UtenteDatoImportoTotale.Abbonamento, OrdiniPerCircuto.Circuito, UtenteDatoImportoTotale.ImportoTotale \
						   FROM OrdiniPerCircuto, \
						   ( \
							   SELECT Utente.Email as Email, Abbonamento, SpesaUtente.ImportoTotale \
							   FROM Utente JOIN \
							   ( \
								   SELECT Carrello.Utente as Email, SUM(Importo) as ImportoTotale \
						   		   FROM Ordine, Carrello \
								   WHERE Ordine.Utente = Carrello.Utente \
								   AND Ordine.Carrello = Carrello.Id \
								   GROUP BY Carrello.Utente \
								   HAVING SUM(Importo) >= 500 \
							   ) as SpesaUtente \
							   ON Utente.Email = SpesaUtente.Email \
						   ) as UtenteDatoImportoTotale \
						   WHERE UtenteDatoImportoTotale.Email = OrdiniPerCircuto.Utente \
						   AND OrdiniPerCircuto.OrdiniEffettuati = (SELECT MAX(OrdiniEffettuati) \
																    FROM OrdiniPerCircuto \
																    WHERE OrdiniPerCircuto.Utente = UtenteDatoImportoTotale.Email)";
	
	PGresult *res;

	std::cout<<"1. Selezionare l'email ed il numero totale di resi di ogni utente"<<std::endl;

	res = PQexec(conn, query_1.c_str());

	checkResults(res, conn);

	const int fQuery_1 = PQnfields(res);
	const int tQuery_1 = PQntuples(res);
	for(int i = 0; i < fQuery_1; i++) {
		printElement(PQfname(res, i), 35);
	}
	std::cout<<std::endl;
	for(int i = 0; i < tQuery_1; i++) {
		for(int j = 0; j < fQuery_1; j++) {
			printElement(PQgetvalue(res, i, j), 35);
		}
		std::cout<<std::endl;
	}

	std::cout<<std::endl<<"2. Selezionare le informazioni dei fornitori che emettono il maggior numero di prodotti prime, i primi 5"<<std::endl;

	res = PQexec(conn, query_2.c_str());

	checkResults(res, conn);

	const int fQuery_2 = PQnfields(res);
	const int tQuery_2 = PQntuples(res);
	for(int i = 0; i < fQuery_2; i++) {
		printElement(PQfname(res, i), 30);
	}
	std::cout<<std::endl;
	for(int i = 0; i < tQuery_2; i++) {
		for(int j = 0; j < fQuery_2; j++) {
			printElement(PQgetvalue(res, i, j), 30);
		}
		std::cout<<std::endl;
	}

	std::cout<<std::endl<<"3. Selezionare gli utenti che hanno acquistato almeno un prodotto realizzato da un fornitore che possiede almeno uno stabilimento all'estero e la citta' della loro residenza"<<std::endl;

	res = PQexec(conn, query_3.c_str());

	checkResults(res, conn);

	const int fQuery_3 = PQnfields(res);
	const int tQuery_3 = PQntuples(res);
	for(int i = 0; i < fQuery_3; i++) {
		printElement(PQfname(res, i), 20);
	}
	std::cout<<std::endl;
	for(int i = 0; i < tQuery_3; i++) {
		for(int j = 0; j < fQuery_3; j++) {
			printElement(PQgetvalue(res, i, j), 20);
		}
		std::cout<<std::endl;
	}

	std::cout<<std::endl<<"4. Selezionare i prodotti, la quantita', l'ordine e il codice di spedizione delle ultime 5 spedizioni effettuate all'indirizzo 'Via Trieste, 63, 35121, Padova'"<<std::endl;
	
	std::string via, ncv, cap, citta;
	std::cout<<"Inserire i dati come descritto!"<<std::endl;
	std::cout<<"Inserire la via. (Via Trieste): ";
	std::getline(std::cin, via);
	std::cout<<"Inserire il numero civico. (63): ";
	std::getline(std::cin, ncv);
	std::cout<<"Inserire il cap. (35121): ";
	std::getline(std::cin, cap);
	std::cout<<"Inserire la citta. (Padova): ";
	std::getline(std::cin, citta);

	const char* params[] = {via.c_str(), ncv.c_str(), cap.c_str(), citta.c_str()};

	res = PQexecParams(conn, query_4.c_str(), 4, NULL, params, NULL, NULL, 0);

	checkResults(res, conn);

	const int fQuery_4 = PQnfields(res);
	const int tQuery_4 = PQntuples(res);
	for(int i = 0; i < fQuery_4; i++) {
		printElement(PQfname(res, i), 25);
	}
	std::cout<<std::endl;
	for(int i = 0; i < tQuery_4; i++) {
		for(int j = 0; j < fQuery_4; j++) {
			printElement(PQgetvalue(res, i, j), 25);
		}
		std::cout<<std::endl;
	}

	std::cout<<std::endl<<"5. Selezionare l'email, il tipo di abbonamento e la carta di credito più usata degli utenti che hanno una spesa totale maggiore di 500 euro"<<std::endl;

	res = PQexec(conn, query_5.c_str());

	checkResults(res, conn);

	const int fQuery_5 = PQnfields(res);
	const int tQuery_5 = PQntuples(res);
	for(int i = 0; i < fQuery_5; i++) {
		printElement(PQfname(res, i), 30);
	}
	std::cout<<std::endl;
	for(int i = 0; i < tQuery_5; i++) {
		for(int j = 0; j < fQuery_5; j++) {
			printElement(PQgetvalue(res, i, j), 30);
		}
		std::cout<<std::endl;
	}
	
	return 0;		
}