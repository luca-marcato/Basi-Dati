--CREATE DATABASE ItaliExpress;

CREATE TABLE Indirizzo(
	Id INTEGER PRIMARY KEY, 
	Via VARCHAR(100), 
	NumeroCivico VARCHAR(10), 
	Citta VARCHAR(100), 
	CAP VARCHAR(5)
);

CREATE TABLE Fornitore(
	PIVA VARCHAR(11) PRIMARY KEY, 
	Nome VARCHAR(50) NOT NULL, 
	NumeroTelefono VARCHAR(15) NOT NULL, 
	Email VARCHAR(100) NOT NULL
);

CREATE TABLE Stabilimento(
	Id INTEGER PRIMARY KEY,
	Stato VARCHAR(100) NOT NULL, 
	Fornitore VARCHAR(11) NOT NULL,
	FOREIGN KEY (Id) REFERENCES Indirizzo (Id),
	FOREIGN KEY (Fornitore) REFERENCES Fornitore (PIVA)
);

CREATE TABLE Prodotto(
	Codice VARCHAR(14) PRIMARY KEY, 
	Nome VARCHAR(100) NOT NULL, 
	Prezzo DECIMAL NOT NULL CHECK (Prezzo >= 0), 
	Prime BOOLEAN NOT NULL, 
	CostoSpedizione DECIMAL NOT NULL CHECK (CostoSpedizione >= 0), 
	Descrizione VARCHAR(5000) NOT NULL, 
	Peso DECIMAL NOT NULL CHECK (Peso > 0), 
	QuantitaDisponibile INTEGER NOT NULL CHECK (QuantitaDisponibile >= 0), 
	Fornitore VARCHAR(11) NOT NULL,
	FOREIGN KEY (Fornitore) REFERENCES Fornitore (PIVA)
);

CREATE TABLE Residenza(
	Id INTEGER PRIMARY KEY,
	FOREIGN KEY (Id) REFERENCES Indirizzo (Id)
); 

CREATE TABLE PuntoDiRitiro(
	Id INTEGER PRIMARY KEY, 
	OrarioApertura TIMESTAMP NOT NULL, 
	OrarioChiusura TIMESTAMP NOT NULL CHECK (OrarioChiusura > OrarioApertura),
	FOREIGN KEY (Id) REFERENCES Indirizzo (Id)
);

CREATE TYPE TipoAbbonamento AS ENUM ('ANNUALE', 'MENSILE');

CREATE TABLE Utente(
	Email VARCHAR(100) PRIMARY KEY, 
	Nome VARCHAR(50) NOT NULL, 
	Cognome VARCHAR(50) NOT NULL, 
	NumeroTelefono VARCHAR(15) NOT NULL, 
	Password VARCHAR(20) NOT NULL,
	Abbonamento TipoAbbonamento, 
	DataIscrizione TIMESTAMP, 
	DataScadenza TIMESTAMP, 
	Residenza INTEGER,
	FOREIGN KEY (Residenza) REFERENCES Residenza (Id),
	CHECK (DataScadenza > DataIscrizione)
);

CREATE TABLE Carrello(
	Id INTEGER NOT NULL, 
	Utente VARCHAR(100) NOT NULL, 
	Importo DECIMAL NOT NULL DEFAULT 0 CHECK (Importo >= 0),
	PRIMARY KEY (Id, Utente),
	FOREIGN KEY (Utente) REFERENCES Utente (Email)
);

CREATE TABLE CartaDiCredito(
	Numero VARCHAR (16) PRIMARY KEY, 
	Circuito VARCHAR(25) NOT NULL, 
	Scadenza DATE NOT NULL, 
	CVV VARCHAR(3) NOT NULL, 
	Intestatario VARCHAR(50), 
	Utente VARCHAR(100),
	FOREIGN KEY (Utente) REFERENCES Utente (Email)
);

CREATE TABLE Spedizione(
	Codice VARCHAR(13) PRIMARY KEY, 
	DataPartenza TIMESTAMP NOT NULL, 
	DataArrivo TIMESTAMP NOT NULL CHECK (DataArrivo > DataPartenza), 
	DataEffettiva TIMESTAMP
); 

CREATE TABLE Ordine(
	Carrello INTEGER NOT NULL, 
	Utente VARCHAR(100) NOT NULL,
	DataAcquisto TIMESTAMP NOT NULL, 
	PreferenzeSpedizione VARCHAR(500), 
	CartaDiCredito VARCHAR(16) NOT NULL, 
	CodiceTransazione VARCHAR(20) NOT NULL, 
	CodiceSpedizione VARCHAR(13) NOT NULL, 
	Residenza INTEGER, 
	PuntoDiRitiro INTEGER,
	PRIMARY KEY (Carrello, Utente),
    FOREIGN KEY (Carrello, Utente) REFERENCES Carrello (Id, Utente),
	FOREIGN KEY (CartaDiCredito) REFERENCES CartaDiCredito (Numero),
	FOREIGN KEY (CodiceSpedizione) REFERENCES Spedizione (Codice),
	FOREIGN KEY (Residenza) REFERENCES Residenza (Id),
	FOREIGN KEY (PuntoDiRitiro) REFERENCES PuntoDiRitiro (Id),
	CHECK ( (Residenza IS NULL AND PuntoDiRitiro IS NOT NULL) OR
		    (Residenza IS NOT NULL AND PuntoDiRitiro IS NULL) ) 
);

CREATE TABLE Reso(
	Prodotto VARCHAR(14) NOT NULL,
	Ordine INTEGER NOT NULL,
	Utente VARCHAR(100) NOT NULL,
	Quantita INTEGER NOT NULL CHECK (Quantita > 0),
	Motivazione VARCHAR(500) NOT NULL,
	Indirizzo INTEGER NOT NULL,
	PRIMARY KEY (Prodotto, Ordine, Utente),
	FOREIGN KEY (Prodotto) REFERENCES Prodotto (Codice), 
	FOREIGN KEY (Ordine, Utente) REFERENCES Ordine (Carrello, Utente),
	FOREIGN KEY (Indirizzo) REFERENCES Stabilimento (Id)
);

CREATE TABLE ProdottiSalvati(
	Prodotto VARCHAR(14) NOT NULL, 
	Carrello INTEGER NOT NULL, 
	Utente VARCHAR(100) NOT NULL, 
	Quantita INTEGER CHECK (Quantita > 0),
	PRIMARY KEY (Prodotto, Carrello, Utente),
	FOREIGN KEY (Prodotto) REFERENCES Prodotto (Codice),
	FOREIGN KEY (Carrello, Utente) REFERENCES Carrello (Id, Utente)
);
