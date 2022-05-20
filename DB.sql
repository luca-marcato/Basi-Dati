CREATE DATABASE ItaliExpress;

CREATE TABLE Indirizzo(
	Id INTEGER PRIMARY KEY, 
	Via VARCHAR(10), 
	NumeroCivico VARCHAR(2), 
	Citta VARCHAR(10), 
	CAP INTEGER(5)
);

CREATE TABLE Fornitore(
	PIVA VARCHAR(11) PRIMARY KEY NOT NULL, 
	Nome VARCHAR(50) NOT NULL, 
	NumeroTelefono VARCHAR(15) NOT NULL, 
	email VARCHAR(100) NOT NULL
);

CREATE TABLE Stabilimento(
	Id INTEGER PRIMARY KEY NOT NULL
	Stato VARCHAR(100) NOT NULL, 
	Fornitore VARCHAR(11) NOT NULL,
	FOREIGN KEY (Id) REFERENCES Indirizzo (Id),
	FOREIGN KEY (Fornitore) REFERENCES Fornitore (PIVA)
);

CREATE TABLE Prodotto(
	Codice VARCHAR(14) PRIMARY KEY NOT NULL, 
	Nome VARCHAR(100) NOT NULL, 
	Prezzo DECIMAL NOT NULL CHECK (Prezzo >= 0), 
	Prime BOOLEAN NOT NULL, 
	CostoSpedizione DECIMAL NOT NULL CHECK (CostoSpedizione >= 0), 
	Descrizione VARCHAR(5000) NOT NULL, 
	Peso DECIMAL NOT NULL CHECK (Peso > 0), 
	QuantitaDisponibile INTEGER NOT NULL CHECK (QuantitaDisponibile >= 0), 
	Fornitore NOT NULL VARCHAR(11),
	FOREIGN KEY (Fornitore) REFERENCES Fornitore (PIVA)
);

CREATE TABLE Carrello(
	Id INTEGER NOT NULL, 
	Utente VARCHAR(100) NOT NULL, 
	Importo DECIMAL CHECK (Importo >= 0),
	PRIMARY KEY (Id, Utente),
	FOREIGN KEY (Utente) REFERENCES Utente (Email)
);

CREATE TABLE Utente(
	Email VARCHAR(100) PRIMARY KEY NOT NULL, 
	Nome VARCHAR(50) NOT NULL, 
	Cognome VARCHAR(50) NOT NULL, 
	NumeroTelefono VARCHAR(15) NOT NULL, 
	Password VARCHAR(20) NOT NULL,
	Abbonamento ENUM('ANNUALE', 'MENSILE'), 
	DataIscrizione TIMESTAMP, 
	DataScadenza TIMESTAMP CHECK (DataScadenza > DataIscrizione), 
	Residenza INTEGER NOT NULL,
	FOREIGN KEY (Residenza) REFERENCES Residenza (Id)
);

CREATE TABLE CartaDiCredito(
	Numero VARCHAR (16) PRIMARY KEY NOT NULL, 
	Circuito VARCHAR(25) NOT NULL, 
	Scadenza DATE NOT NULL, 
	CVV VARCHAR(3) NOT NULL, 
	Intestatario VARCHAR(50), 
	Utente VARCHAR(100),
	FOREIGN KEY (Utente) REFERENCES Utente (Email)
);

CREATE TABLE Spedizione(
	Codice VARCHAR(13) PRIMARY KEY NOT NULL, 
	DataPartenza TIMESTAMP NOT NULL, 
	DataArrivo TIMESTAMP NOT NULL CHECK (DataArrivo > DataPartenza), 
	DataEffettiva TIMESTAMP NOT NULL CHECK (DataEffettiva > DataPartenza)
); 

CREATE TABLE Residenza(
	Id INTEGER PRIMARY KEY NOT NULL,
	FOREIGN KEY (Id) REFERENCES Indirizzo (Id)
); 

CREATE TABLE PuntoDiRitiro(
	Id INTEGER PRIMARY KEY NOT NULL, 
	OrarioApertura TIMESTAMP NOT NULL, 
	OrarioChiusura TIMESTAMP NOT NULL CHECK (OrarioChiusura > OrarioApertura),
	FOREIGN KEY (Id) REFERENCES Indirizzo (Id)
);

CREATE TABLE Ordine(
	Carrello INTEGER NOT NULL, 
	Utente VARCHAR(100) NOT NULL,
	DataAcquisto TIMESTAMP NOT NULL, 
	PreferenzeSpedizione VARCHAR(500), 
	CartaDiCredito VARCHAR(16) NOT NULL, 
	CodiceTransazione VARCHAR(20) NOT NULL, 
	InfoSpedizione VARCHAR(13) NOT NULL, 
	Residenza INTEGER, 
	PuntoDiRitiro INTEGER,
	PRIMARY KEY (Carrello, Utente),
    FOREIGN KEY (Carrello) REFERENCES Carrello (Id),
	FOREIGN KEY (Utente) REFERENCES Carrello (Utente),
	FOREIGN KEY (CartaDiCredito) REFERENCES CartaDiCredito (Numero),
	FOREIGN KEY (InfoSpedizione) REFERENCES Spedizione (codice),
	FOREIGN KEY (Residenza) REFERENCES Residenza (id),
	FOREIGN KEY (PuntoDiRitiro) REFERENCES PuntoDiRitiro (id)
);

CREATE TABLE Reso(
	Prodotto VARCHAR(14) NOT NULL,
	Ordine INTEGER NOT NULL,
	Utente VARCHAR(100) NOT NULL,
	Quantita INTEGER NOT NULL CHECK (Quantita > 0),
	Motivazione VARCHAR(500) NOT NULL,
	PRIMARY KEY (Prodotto, Ordine, Utente),
	FOREIGN KEY (Prodotto) REFERENCES Prodotto (Codice), 
	FOREIGN KEY (Ordine) REFERENCES Ordine (Carrello), 
	FOREIGN KEY (Utente) REFERENCES Ordine (Utente), 
	FOREIGN KEY (Indirizzo) REFERENCES Stabilimento (Id)
);

CREATE TABLE ProdottiSalvati(
	Prodotto INTEGER NOT NULL, 
	Carrello INTEGER NOT NULL, 
	Utente VARCHAR(100), 
	Quantita INTEGER CHECK (Quantita > 0),
	PRIMARY KEY (Prodotto, Carrello, Utente),
	FOREIGN KEY (Prodotto) REFERENCES Prodotto (Codice),
	FOREIGN KEY (Carrello) REFERENCES Carrello (Id),
	FOREIGN KEY (Utente) REFERENCES Carrello (Utente)
);
