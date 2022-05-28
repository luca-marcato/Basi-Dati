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
	FOREIGN KEY (Id) REFERENCES Indirizzo (Id) ON DELETE CASCADE,
	FOREIGN KEY (Fornitore) REFERENCES Fornitore (PIVA) ON DELETE CASCADE
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
	FOREIGN KEY (Fornitore) REFERENCES Fornitore (PIVA) ON DELETE NO ACTION
);

CREATE TABLE Residenza(
	Id INTEGER PRIMARY KEY,
	FOREIGN KEY (Id) REFERENCES Indirizzo (Id) ON DELETE CASCADE
); 

CREATE TABLE PuntoDiRitiro(
	Id INTEGER PRIMARY KEY, 
	OrarioApertura TIME NOT NULL, 
	OrarioChiusura TIME NOT NULL CHECK (OrarioChiusura > OrarioApertura),
	FOREIGN KEY (Id) REFERENCES Indirizzo (Id) ON DELETE CASCADE
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
	FOREIGN KEY (Residenza) REFERENCES Residenza (Id) ON DELETE SET NULL,
	CHECK (DataScadenza > DataIscrizione)
);

CREATE TABLE Carrello(
	Id INTEGER NOT NULL, 
	Utente VARCHAR(100) NOT NULL, 
	Importo DECIMAL NOT NULL DEFAULT 0 CHECK (Importo >= 0),
	PRIMARY KEY (Id, Utente),
	FOREIGN KEY (Utente) REFERENCES Utente (Email) ON DELETE NO ACTION
);

CREATE TABLE CartaDiCredito(
	Numero VARCHAR (16) PRIMARY KEY, 
	Circuito VARCHAR(25) NOT NULL, 
	Scadenza DATE NOT NULL, 
	CVV VARCHAR(3) NOT NULL, 
	Intestatario VARCHAR(50), 
	Utente VARCHAR(100),
	FOREIGN KEY (Utente) REFERENCES Utente (Email) ON DELETE NO ACTION
);

CREATE TABLE Spedizione(
	Codice VARCHAR(13) PRIMARY KEY, 
	DataPartenza TIMESTAMP NOT NULL, 
	DataArrivo TIMESTAMP NOT NULL CHECK (DataArrivo > DataPartenza), 
	DataEffettiva TIMESTAMP 
	CHECK( (DataEffettiva IS NOT NULL AND DataEffettiva > DataPartenza) OR DataEffettiva IS NULL )
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
    FOREIGN KEY (Carrello, Utente) REFERENCES Carrello (Id, Utente) ON DELETE NO ACTION,
	FOREIGN KEY (CartaDiCredito) REFERENCES CartaDiCredito (Numero) ON DELETE NO ACTION,
	FOREIGN KEY (CodiceSpedizione) REFERENCES Spedizione (Codice) ON DELETE NO ACTION,
	FOREIGN KEY (Residenza) REFERENCES Residenza (Id) ON DELETE NO ACTION,
	FOREIGN KEY (PuntoDiRitiro) REFERENCES PuntoDiRitiro (Id) ON DELETE NO ACTION,
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
	FOREIGN KEY (Prodotto) REFERENCES Prodotto (Codice) ON DELETE NO ACTION, 
	FOREIGN KEY (Ordine, Utente) REFERENCES Ordine (Carrello, Utente) ON DELETE NO ACTION,
	FOREIGN KEY (Indirizzo) REFERENCES Stabilimento (Id) ON DELETE NO ACTION
);

CREATE TABLE ProdottiSalvati(
	Prodotto VARCHAR(14) NOT NULL, 
	Carrello INTEGER NOT NULL, 
	Utente VARCHAR(100) NOT NULL, 
	Quantita INTEGER CHECK (Quantita > 0),
	PRIMARY KEY (Prodotto, Carrello, Utente),
	FOREIGN KEY (Prodotto) REFERENCES Prodotto (Codice) ON DELETE CASCADE,
	FOREIGN KEY (Carrello, Utente) REFERENCES Carrello (Id, Utente) ON DELETE CASCADE
);

CREATE INDEX NomiProdotti ON Prodotto(Nome);

-- INDIRIZZI
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (1, 'Viale dell''Università', '16', 'Legnaro', '35020');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (2, 'Piazza Capitaniato ', '7', 'Padova', '35139');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (3, 'Via U. Bassi', '58/b', 'Padova', '35121');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (4, 'Via 8 Febbraio', '2', 'Padova', '35122');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (5, 'Piazza Capitaniato', '3', 'Padova', '35139');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (6, 'Via Marzolo', '8', 'Padova', '35131');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (7, 'Via Gradenigo', '6', 'Padova', '35131');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (8, 'Via Marzolo', '9', 'Padova', '35131');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (9, 'Via Gradenigo', '6/b', 'Padova', '35131');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (10, 'Via Gradenigo', '6/a', 'Padova', '35131');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (11, 'Via Trieste', '63', 'Padova', '35121');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (12, 'Via Giustiniani', '2', 'Padova', '35128');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (13, 'Via Gabelli', '63', 'Padova', '35121');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (14, 'Via Belzoni', '160', 'Padova', '35121');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (15, 'Via Venezia', '8', 'Padova ', '35131');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (16, 'Via Giustiniani', '3', 'Padova ', '35128');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (17, 'Via Ugo Bassi', '58/b', 'Padova ', '35131');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (18, 'Via Marzolo', '1', 'Padova ', '35131');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (19, 'Via Marzolo', '5', 'Padova ', '35131');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (20, 'Via del Santo', '33', 'Padova ', '35123');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (21, 'Via 2 Giugno', '30', 'Padova ', '35131');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (22, 'Via 25 Aprile', '21/b', 'Padova ', '35128');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (23, 'Via 22 Ottobre', '2', 'Padova ', '35131');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (24, 'Via 14 Luglio', '14', 'Legnaro ', '35020');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (25, 'Via 14 Luglio', '15', 'Legnaro ', '35020');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (26, 'Via 5 Maggio', '19', 'Padova ', '35128');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (27, 'Via 1 Giugno', '61', 'Padova ', '35128');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (28, 'Via 29 Febbraio', '4', 'Padova ', '35131');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (29, 'Via 25 Dicembre', '77', 'Legnaro', '35020');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (30, 'Via 6 Agosto', '11', 'Padova ', '35131');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (31, 'Via Roma', '21', 'Milano', '20121');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (32, 'Via Genova', '33/a', 'Milano', '20127');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (33, 'Via Treviso', '2', 'Milano', '20089');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (34, 'Via Nizza', '89', 'Parigi', '75004');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (35, 'Via Lione', '32/a', 'Parigi', '75019');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (36, 'Via Lione', '32/b', 'Parigi', '75019');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (37, 'Via Parma', '12', 'Torino', '10096');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (38, 'Via Palermo', '44', 'Torino', '10094');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (39, 'Via Firenze', '2', 'Bologna', '20121');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (40, 'Via Cremona', '41', 'Bologna', '20121');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (41, 'Via Graz', '13', 'Salisburgo', '5082');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (42, 'Via Vienna', '5/a', 'Salisburgo', '5082');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (43, 'Via Berlino', '9', 'Amburgo', '20249');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (44, 'Via Dresda', '66', 'Amburgo', '20149');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (45, 'Via Teramo', '3', 'Roma', '00100');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (46, 'Via L''aquila', '8/b', 'Padova', '35132');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (47, 'Via Lecce', '12', 'Napoli', '80100');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (48, 'Via Lucca', '42', 'Nalopi', '80126');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (49, 'Via Pompei', '76', 'Verona', '37100');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (50, 'Via Napoli', '2', 'Verona', '37121');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (51, 'Via Bari', '99', 'Taranto', '74121');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (52, 'Via Catania', '4/a', 'Taranto', '74121');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (53, 'Via Trieste', '33/b', 'Perugia', '06129');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (54, 'Via Patro', '7', 'Perugia', '06131');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (55, 'Via Braga', '81', 'Lisbona', '10011');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (56, 'Via Coimbra', '6', 'Lisbona', '10011');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (57, 'Via Faro', '12/a', 'Porto', '40009');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (58, 'Via Cannes', '8', 'Tolosa', '31500');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (59, 'Via Nantes', '10', 'Tolosa', '31500');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (60, 'Via Annecy', '101', 'Marsiglia', '13004');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (61, 'Via Montpellier', '54/a', 'Marsiglia', W'13005');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (62, 'Via Brema', '65', 'Dresda', '01067');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (63, 'Via Colonia', '87', 'Dresda', '01069');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (64, 'Via Monaco di Baviera', '22', 'Amburgo', '20095');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (65, 'Via Norimberga', '1', 'Amburgo', '20095');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (66, 'Via l''Aia', '12', 'Rotterdam', '10831');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (67, 'Via Utrecht', '6', 'Rotterdam', '10832');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (68, 'Via Groninga', '72/a', 'Leida', '17840');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (69, 'Via Nimega', '91', 'Leida', '17841');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (70, 'Via Cracovia', '1', 'Varsavia', '19901');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (71, 'Via Olomuc', '1/a', 'Praga', '50240');
INSERT INTO public.indirizzo(id, via, numerocivico, citta, cap)
VALUES (72, 'Via Liberec', '19', 'Brno', '60440');
--Residenze
INSERT INTO public.residenza(id)
VALUES (21);
INSERT INTO public.residenza(id)
VALUES (22);
INSERT INTO public.residenza(id)
VALUES (23);
INSERT INTO public.residenza(id)
VALUES (24);
INSERT INTO public.residenza(id)
VALUES (25);
INSERT INTO public.residenza(id)
VALUES (26);
INSERT INTO public.residenza(id)
VALUES (27);
INSERT INTO public.residenza(id)
VALUES (28);
INSERT INTO public.residenza(id)
VALUES (29);
INSERT INTO public.residenza(id)
VALUES (30);
--PuntiDiRitiro
INSERT INTO public.puntodiritiro(id, orarioapertura, orariochiusura)
VALUES (1, '08:30:00', '18:30:00');
INSERT INTO public.puntodiritiro(id, orarioapertura, orariochiusura)
VALUES (2, '08:30:00', '17:30:00');
INSERT INTO public.puntodiritiro(id, orarioapertura, orariochiusura)
VALUES (3, '08:30:00', '19:00:00');
INSERT INTO public.puntodiritiro(id, orarioapertura, orariochiusura)
VALUES (4, '08:00:00', '18:00:00');
INSERT INTO public.puntodiritiro(id, orarioapertura, orariochiusura)
VALUES (5, '08:00:00', '19:00:00');
INSERT INTO public.puntodiritiro(id, orarioapertura, orariochiusura)
VALUES (6, '07:30:00', '17:30:00');
INSERT INTO public.puntodiritiro(id, orarioapertura, orariochiusura)
VALUES (7, '07:00:00', '13:00:00');
INSERT INTO public.puntodiritiro(id, orarioapertura, orariochiusura)
VALUES (8, '07:00:00', '14:00:00');
INSERT INTO public.puntodiritiro(id, orarioapertura, orariochiusura)
VALUES (9, '07:30:00', '19:00:00');
INSERT INTO public.puntodiritiro(id, orarioapertura, orariochiusura)
VALUES (10, '09:30:00', '19:00:00');
INSERT INTO public.puntodiritiro(id, orarioapertura, orariochiusura)
VALUES (11, '07:30:00', '19:00:00');
INSERT INTO public.puntodiritiro(id, orarioapertura, orariochiusura)
VALUES (12, '09:30:00', '15:00:00');
INSERT INTO public.puntodiritiro(id, orarioapertura, orariochiusura)
VALUES (13, '08:00:00', '15:30:00');
INSERT INTO public.puntodiritiro(id, orarioapertura, orariochiusura)
VALUES (14, '08:00:00', '15:30:00');
INSERT INTO public.puntodiritiro(id, orarioapertura, orariochiusura)
VALUES (15, '08:00:00', '15:30:00');
INSERT INTO public.puntodiritiro(id, orarioapertura, orariochiusura)
VALUES (16, '08:00:00', '16:30:00');
INSERT INTO public.puntodiritiro(id, orarioapertura, orariochiusura)
VALUES (17, '07:30:00', '17:00:00');
INSERT INTO public.puntodiritiro(id, orarioapertura, orariochiusura)
VALUES (18, '09:00:00', '13:00:00');
INSERT INTO public.puntodiritiro(id, orarioapertura, orariochiusura)
VALUES (19, '10:00:00', '17:30:00');
INSERT INTO public.puntodiritiro(id, orarioapertura, orariochiusura)
VALUES (20, '06:30:00', '16:00:00');
--Fornitori
INSERT INTO public.fornitore(piva, nome, numerotelefono, email)
VALUES ('0764352056C', 'Fornitore1', '+390987654321', 'fornitore1@italiexpress.com');
INSERT INTO public.fornitore(piva, nome, numerotelefono, email)
VALUES ('1764352056C', 'Fornitore2', '+390987654322', 'fornitore2@italiexpress.com');
INSERT INTO public.fornitore(piva, nome, numerotelefono, email)
VALUES ('2764352056C', 'Fornitore3', '+390987654323', 'fornitore3@italiexpress.com');
INSERT INTO public.fornitore(piva, nome, numerotelefono, email)
VALUES ('3764352056C', 'Fornitore4', '+390987654324', 'fornitore4@italiexpress.com');
INSERT INTO public.fornitore(piva, nome, numerotelefono, email)
VALUES ('4764352056C', 'Fornitore5', '+390987654325', 'fornitore5@italiexpress.com');
INSERT INTO public.fornitore(piva, nome, numerotelefono, email)
VALUES ('5764352056C', 'Fornitore6', '+390987654326', 'fornitore6@italiexpress.com');
INSERT INTO public.fornitore(piva, nome, numerotelefono, email)
VALUES ('6764352056C', 'Fornitore7', '+390987654327', 'fornitore7@italiexpress.com');
INSERT INTO public.fornitore(piva, nome, numerotelefono, email)
VALUES ('7764352056C', 'Fornitore8', '+390987654328', 'fornitore8@italiexpress.com');
INSERT INTO public.fornitore(piva, nome, numerotelefono, email)
VALUES ('8764352056C', 'Fornitore9', '+390987654329', 'fornitore9@italiexpress.com');
INSERT INTO public.fornitore(piva, nome, numerotelefono, email)
VALUES ('9764352056C', 'Fornitore10', '+390987654330', 'fornitore10@italiexpress.com');
INSERT INTO public.fornitore(piva, nome, numerotelefono, email)
VALUES ('0664352056C', 'Fornitore11', '+390987654331', 'fornitore11@italiexpress.com');
INSERT INTO public.fornitore(piva, nome, numerotelefono, email)
VALUES ('1664352056C', 'Fornitore12', '+390987654332', 'fornitore12@italiexpress.com');
INSERT INTO public.fornitore(piva, nome, numerotelefono, email)
VALUES ('2664352056C', 'Fornitore13', '+390987654333', 'fornitore13@italiexpress.com');
INSERT INTO public.fornitore(piva, nome, numerotelefono, email)
VALUES ('3664352056C', 'Fornitore14', '+390987654334', 'fornitore14@italiexpress.com');
INSERT INTO public.fornitore(piva, nome, numerotelefono, email)
VALUES ('4664352056C', 'Fornitore15', '+390987654335', 'fornitore15@italiexpress.com');
INSERT INTO public.fornitore(piva, nome, numerotelefono, email)
VALUES ('5664352056C', 'Fornitore16', '+390987654335', 'fornitore16@italiexpress.com');
INSERT INTO public.fornitore(piva, nome, numerotelefono, email)
VALUES ('6664352056C', 'Fornitore17', '+390987654336', 'fornitore17@italiexpress.com');
INSERT INTO public.fornitore(piva, nome, numerotelefono, email)
VALUES ('7664352056C', 'Fornitore18', '+390987654337', 'fornitore18@italiexpress.com');
INSERT INTO public.fornitore(piva, nome, numerotelefono, email)
VALUES ('8664352056C', 'Fornitore19', '+390987654338', 'fornitore19@italiexpress.com');
INSERT INTO public.fornitore(piva, nome, numerotelefono, email)
VALUES ('9664352056C', 'Fornitore20', '+390987654339', 'fornitore20@italiexpress.com');
INSERT INTO public.fornitore(piva, nome, numerotelefono, email)
VALUES ('0564352056C', 'Fornitore21', '+390987654340', 'fornitore21@italiexpress.com');
INSERT INTO public.fornitore(piva, nome, numerotelefono, email)
VALUES ('1564352056C', 'Fornitore22', '+390987654341', 'fornitore22@italiexpress.com');
INSERT INTO public.fornitore(piva, nome, numerotelefono, email)
VALUES ('2564352056C', 'Fornitore23', '+390987654342', 'fornitore23@italiexpress.com');
INSERT INTO public.fornitore(piva, nome, numerotelefono, email)
VALUES ('3564352056C', 'Fornitore24', '+390987654343', 'fornitore24@italiexpress.com');
INSERT INTO public.fornitore(piva, nome, numerotelefono, email)
VALUES ('4564352056C', 'Fornitore25', '+390987654344', 'fornitore25@italiexpress.com');
INSERT INTO public.fornitore(piva, nome, numerotelefono, email)
VALUES ('5564352056C', 'Fornitore26', '+390987654345', 'fornitore26@italiexpress.com');
INSERT INTO public.fornitore(piva, nome, numerotelefono, email)
VALUES ('6564352056C', 'Fornitore27', '+390987654346', 'fornitore27@italiexpress.com');
INSERT INTO public.fornitore(piva, nome, numerotelefono, email)
VALUES ('7564352056C', 'Fornitore28', '+390987654347', 'fornitore28@italiexpress.com');
INSERT INTO public.fornitore(piva, nome, numerotelefono, email)
VALUES ('8564352056C', 'Fornitore29', '+390987654348', 'fornitore29@italiexpress.com');
INSERT INTO public.fornitore(piva, nome, numerotelefono, email)
VALUES ('9564352056C', 'Fornitore30', '+390987654349', 'fornitore30@italiexpress.com');
--Stabilimenti
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (31, 'IT', '0764352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (32, 'IT', '1764352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (33, 'IT', '2764352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (34, 'FR', '2764352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (35, 'FR', '3764352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (36, 'FR', '3764352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (37, 'IT', '4764352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (38, 'IT', '5764352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (39, 'IT', '6764352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (40, 'IT', '7764352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (41, 'AT', '7764352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (42, 'AT', '7764352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (43, 'AT', '8764352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (44, 'AT', '9764352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (45, 'IT', '0664352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (46, 'IT', '1664352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (47, 'IT', '2664352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (48, 'IT', '3664352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (49, 'IT', '3664352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (50, 'IT', '4664352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (51, 'IT', '5664352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (52, 'IT', '6664352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (53, 'IT', '7664352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (54, 'IT', '8664352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (55, 'PT', '9664352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (56, 'PT', '9664352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (57, 'PT', '0564352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (58, 'FR', '0564352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (59, 'FR', '0564352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (60, 'FR', '1564352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (61, 'FR', '2564352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (62, 'DE' , '3564352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (63, 'DE', '4564352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (64, 'DE', '5564352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (65, 'DE', '5564352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (66, 'NL', '5564352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (67, 'NL', '6564352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (68, 'NL', '7564352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (69, 'NL', '7564352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (70, 'CZ', '8564352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (71, 'CZ', '9564352056C');
INSERT INTO public.stabilimento(id, stato, fornitore)
VALUES (72, 'CZ', '9564352056C');
--Utenti
INSERT INTO public.utente(email, nome, cognome, numerotelefono, password, abbonamento, dataiscrizione, datascadenza, residenza)
VALUES ('utente1@studente.unipd.it', 'utente', '1', '+391234567890', 'utente1', 'MENSILE', '2022-02-10 16:05:06', '2022-03-10 16:05:06', NULL);
INSERT INTO public.utente(email, nome, cognome, numerotelefono, password, abbonamento, dataiscrizione, datascadenza, residenza)
VALUES ('utente2@studente.unipd.it', 'utente', '2', '+391234567891', 'utente2', 'ANNUALE', '2021-12-11 08:15:16', '2022-12-11 08:15:16', 21);
INSERT INTO public.utente(email, nome, cognome, numerotelefono, password, abbonamento, dataiscrizione, datascadenza, residenza)
VALUES ('utente3@studente.unipd.it', 'utente', '3', '+391234567892', 'utente3', 'ANNUALE', '2020-11-22 14:55:19', '2021-11-22 014:55:19', NULL);
INSERT INTO public.utente(email, nome, cognome, numerotelefono, password, abbonamento, dataiscrizione, datascadenza, residenza)
VALUES ('utente4@studente.unipd.it', 'utente', '4', '+391234567893', 'utente4', 'MENSILE', '2022-04-12 12:52:49', '2022-05-12 12:52:49', NULL);
INSERT INTO public.utente(email, nome, cognome, numerotelefono, password, abbonamento, dataiscrizione, datascadenza, residenza)
VALUES ('utente5@studente.unipd.it', 'utente', '5', '+391234567894', 'utente5', 'ANNUALE', '2022-03-17 08:25:01', '2023-03-17 08:25:01', 22);
INSERT INTO public.utente(email, nome, cognome, numerotelefono, password, abbonamento, dataiscrizione, datascadenza, residenza)
VALUES ('utente6@studente.unipd.it', 'utente', '6', '+391234567895', 'utente6', 'ANNUALE', '2022-03-17 08:26:11', '2023-03-17 08:26:11', 22);
INSERT INTO public.utente(email, nome, cognome, numerotelefono, password, abbonamento, dataiscrizione, datascadenza, residenza)
VALUES ('utente7@studente.unipd.it', 'utente', '7', '+391234567896', 'utente7', 'ANNUALE', '2022-03-17 08:25:51', '2023-03-17 08:25:51', 22);
INSERT INTO public.utente(email, nome, cognome, numerotelefono, password, abbonamento, dataiscrizione, datascadenza, residenza)
VALUES ('utente8@studente.unipd.it', 'utente', '8', '+391234567897', 'utente8', NULL, NULL, NULL, 23);
INSERT INTO public.utente(email, nome, cognome, numerotelefono, password, abbonamento, dataiscrizione, datascadenza, residenza)
VALUES ('utente9@studente.unipd.it', 'utente', '9', '+391234567898', 'utente9', NULL, NULL, NULL, NULL);
INSERT INTO public.utente(email, nome, cognome, numerotelefono, password, abbonamento, dataiscrizione, datascadenza, residenza)
VALUES ('utente10@studente.unipd.it', 'utente', '10', '+391234567899', 'utente10', 'ANNUALE', '2020-10-21 13:49:22', '2021-10-21 13:49:22', 23);
INSERT INTO public.utente(email, nome, cognome, numerotelefono, password, abbonamento, dataiscrizione, datascadenza, residenza)
VALUES ('utente11@studente.unipd.it', 'utente', '11', '+391234567881', 'utente11', 'MENSILE', '2022-05-12 08:31:44', '2022-06-12 08:31:44', NULL);
INSERT INTO public.utente(email, nome, cognome, numerotelefono, password, abbonamento, dataiscrizione, datascadenza, residenza)
VALUES ('utente12@studente.unipd.it', 'utente', '12', '+391234567882', 'utente12', NULL, NULL, NULL, 24);
INSERT INTO public.utente(email, nome, cognome, numerotelefono, password, abbonamento, dataiscrizione, datascadenza, residenza)
VALUES ('utente13@studente.unipd.it', 'utente', '13', '+391234567883', 'utente13', 'ANNUALE', '2018-06-23 20:52:28', '2019-06-23 20:52:28', 25);
INSERT INTO public.utente(email, nome, cognome, numerotelefono, password, abbonamento, dataiscrizione, datascadenza, residenza)
VALUES ('utente14@studente.unipd.it', 'utente', '14', '+391234567884', 'utente14', 'MENSILE', '2022-05-21 21:02:34', '2022-06-21 21:02:34', NULL);
INSERT INTO public.utente(email, nome, cognome, numerotelefono, password, abbonamento, dataiscrizione, datascadenza, residenza)
VALUES ('utente15@studente.unipd.it', 'utente', '15', '+391234567885', 'utente15', 'ANNUALE', '2021-07-13 09:08:07', '2022-07-13 09:08:07', 26);
INSERT INTO public.utente(email, nome, cognome, numerotelefono, password, abbonamento, dataiscrizione, datascadenza, residenza)
VALUES ('utente16@studente.unipd.it', 'utente', '16', '+391234567886', 'utente16', NULL, NULL, NULL, 26);
INSERT INTO public.utente(email, nome, cognome, numerotelefono, password, abbonamento, dataiscrizione, datascadenza, residenza)
VALUES ('utente17@studente.unipd.it', 'utente', '17', '+391234567887', 'utente17', 'MENSILE', '2018-05-13 20:36:29', '2018-06-13 20:36:29', NULL);
INSERT INTO public.utente(email, nome, cognome, numerotelefono, password, abbonamento, dataiscrizione, datascadenza, residenza)
VALUES ('utente1@unipd.it', 'utente', '1', '+391234567888', 'utente1', 'MENSILE', '2019-09-01 11:31:21', '2019-10-01 11:31:21', 27);
INSERT INTO public.utente(email, nome, cognome, numerotelefono, password, abbonamento, dataiscrizione, datascadenza, residenza)
VALUES ('utente2@unipd.it', 'utente', '2', '+391234567889', 'utente2', 'ANNUALE', '2021-09-16 07:58:00', '2022-09-16 07:58:00', 27);
INSERT INTO public.utente(email, nome, cognome, numerotelefono, password, abbonamento, dataiscrizione, datascadenza, residenza)
VALUES ('utente3@unipd.it', 'utente', '3', '+391234567870', 'utente3', 'ANNUALE', '2022-02-15 15:15:06', '2023-02-15 15:15:06', NULL);
INSERT INTO public.utente(email, nome, cognome, numerotelefono, password, abbonamento, dataiscrizione, datascadenza, residenza)
VALUES ('utente4@unipd.it', 'utente', '4', '+391234567871', 'utente4', 'MENSILE', '2020-11-02 23:48:50', '2020-12-02 23:48:50', 28);
INSERT INTO public.utente(email, nome, cognome, numerotelefono, password, abbonamento, dataiscrizione, datascadenza, residenza)
VALUES ('utente5@unipd.it', 'utente', '5', '+391234567872', 'utente5', NULL, NULL, NULL, NULL);
INSERT INTO public.utente(email, nome, cognome, numerotelefono, password, abbonamento, dataiscrizione, datascadenza, residenza)
VALUES ('utente6@unipd.it', 'utente', '6', '+391234567873', 'utente6', 'ANNUALE', '2021-12-23 21:10:37', '2022-12-23 21:10:37', NULL);
INSERT INTO public.utente(email, nome, cognome, numerotelefono, password, abbonamento, dataiscrizione, datascadenza, residenza)
VALUES ('utente7@unipd.it', 'utente', '7', '+391234567874', 'utente7', 'MENSILE', '2022-04-29 16:59:30', '2022-05-29 16:59:30', 29);
INSERT INTO public.utente(email, nome, cognome, numerotelefono, password, abbonamento, dataiscrizione, datascadenza, residenza)
VALUES ('utente8@unipd.it', 'utente', '8', '+391234567875', 'utente8', NULL, NULL, NULL, NULL);
INSERT INTO public.utente(email, nome, cognome, numerotelefono, password, abbonamento, dataiscrizione, datascadenza, residenza)
VALUES ('utente9@unipd.it', 'utente', '9', '+391234567876', 'utente9', 'ANNUALE', '2022-01-16 18:26:22', '2023-01-16 18:26:22', 30);
INSERT INTO public.utente(email, nome, cognome, numerotelefono, password, abbonamento, dataiscrizione, datascadenza, residenza)
VALUES ('utente10@unipd.it', 'utente', '10', '+391234567877', 'utente10', 'ANNUALE', '2021-08-19 19:38:18', '2022-08-19 19:38:18', NULL);
--Prodotti
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0107', 'Prodotto 1', 23.50, true, 1.20, 'Descrizione del prodotto 1', 12.33, 999, '0764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0207', 'Prodotto 2', 11.00, true, 3.20, 'Descrizione del prodotto 2', 0.37, 1500, '0764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0307', 'Prodotto 3', 45.99, true, 1.50, 'Descrizione del prodotto 3', 14.98, 799, '0764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0407', 'Prodotto 4', 23.30, true, 1.20, 'Descrizione del prodotto 4', 12.43, 1000, '0764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0507', 'Prodotto 5', 29.99, false, 4.99, 'Descrizione del prodotto 5', 5.90, 1050, '0764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0117', 'Prodotto 1', 78.00, true, 1.90, 'Descrizione del prodotto 1', 2.10, 2110, '1764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0217', 'Prodotto 2', 2.50, true, 0.20, 'Descrizione del prodotto 2', 8.99, 899, '1764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0317', 'Prodotto 3', 66.50, true, 3.67, 'Descrizione del prodotto 3', 1.50, 1620, '1764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0417', 'Prodotto 4', 87.19, true, 4.88, 'Descrizione del prodotto 4', 30.00, 955, '1764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0517', 'Prodotto 5', 11.50, false, 1.40, 'Descrizione del prodotto 5', 4.20, 1150, '1764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0127', 'Prodotto 1', 3.50, true, 0.90, 'Descrizione del prodotto 1', 2.10, 1109, '2764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0227', 'Prodotto 2', 11.90, true, 1.10, 'Descrizione del prodotto 2', 7.99, 1997, '2764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0327', 'Prodotto 3', 35.70, true, 1.00, 'Descrizione del prodotto 3', 2.55, 2900, '2764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0427', 'Prodotto 4', 20.99, true, 0.50, 'Descrizione del prodotto 4', 4.00, 1001, '2764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0527', 'Prodotto 5', 10.50, false, 3.90, 'Descrizione del prodotto 5', 4.20, 900, '2764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0137', 'Prodotto 1', 30.50, true, 12.90, 'Descrizione del prodotto 1', 2.11, 1129, '3764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0237', 'Prodotto 2', 101.90, true, 1.10, 'Descrizione del prodotto 2', 27.59, 1900, '3764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0337', 'Prodotto 3', 155.70, true, 10.00, 'Descrizione del prodotto 3', 12.55, 1900, '3764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0437', 'Prodotto 4', 22.99, true, 5.50, 'Descrizione del prodotto 4', 4.30, 701, '3764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0537', 'Prodotto 5', 100.50, false, 4.99, 'Descrizione del prodotto 5', 0.20, 2900, '3764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0147', 'Prodotto 1', 150.50, true, 9.90, 'Descrizione del prodotto 1', 0.11, 1542, '4764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0247', 'Prodotto 2', 10.65, true, 1.10, 'Descrizione del prodotto 2', 7.59, 1999, '4764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0347', 'Prodotto 3', 355.70, true, 1.00, 'Descrizione del prodotto 3', 14.55, 200, '4764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0447', 'Prodotto 4', 76.99, true, 3.50, 'Descrizione del prodotto 4', 4.30, 1701, '4764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0547', 'Prodotto 5', 10.55, false, 2.99, 'Descrizione del prodotto 5', 5.20, 900, '4764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0157', 'Prodotto 1', 1.50, true, 9.90, 'Descrizione del prodotto 1', 0.12, 1742, '5764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0257', 'Prodotto 2', 2.65, true, 1.10, 'Descrizione del prodotto 2', 1.21, 999, '5764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0357', 'Prodotto 3', 4.70, true, 1.00, 'Descrizione del prodotto 3', 6.89, 2110, '5764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0457', 'Prodotto 4', 46.69, true, 3.50, 'Descrizione del prodotto 4', 3.33, 501, '5764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0557', 'Prodotto 5', 12.59, false, 2.99, 'Descrizione del prodotto 5', 6.30, 500, '5764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0167', 'Prodotto 1', 12.50, true, 2.90, 'Descrizione del prodotto 1', 1.12, 1042, '6764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0267', 'Prodotto 2', 32.65, true, 0.20, 'Descrizione del prodotto 2', 12.21, 699, '6764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0367', 'Prodotto 3', 42.40, true, 1.01, 'Descrizione del prodotto 3', 23.89, 210, '6764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0467', 'Prodotto 4', 422.19, true, 5.49, 'Descrizione del prodotto 4', 44.31, 3301, '6764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0567', 'Prodotto 5', 53.99, false, 2.60, 'Descrizione del prodotto 5', 5.10, 1500, '6764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0177', 'Prodotto 1', 2.20, true, 2.90, 'Descrizione del prodotto 1', 12.12, 2042, '7764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0277', 'Prodotto 2', 12.95, true, 0.20, 'Descrizione del prodotto 2', 16.71, 1699, '7764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0377', 'Prodotto 3', 92.50, true, 1.01, 'Descrizione del prodotto 3', 76.80, 2100, '7764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0477', 'Prodotto 4', 4.99, true, 1.49, 'Descrizione del prodotto 4', 2.00, 201, '7764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0577', 'Prodotto 5', 3.99, false, 4.60, 'Descrizione del prodotto 5', 3.00, 2530, '7764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0187', 'Prodotto 1', 123.20, true, 5.50, 'Descrizione del prodotto 1', 22.42, 1042, '8764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0287', 'Prodotto 2', 0.95, true, 1.20, 'Descrizione del prodotto 2', 16.71, 3099, '8764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0387', 'Prodotto 3', 91.50, false, 3.01, 'Descrizione del prodotto 3', 76.80, 100, '8764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0197', 'Prodotto 1', 410.00, true, 3.55, 'Descrizione del prodotto 1', 2.45, 989, '9764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0297', 'Prodotto 2', 12.95, true, 2.99, 'Descrizione del prodotto 2', 13.81, 2011, '9764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0397', 'Prodotto 3', 99.50, false, 1.01, 'Descrizione del prodotto 3', 3.33, 1000, '9764352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0106', 'Prodotto 1', 439.99, true, 2.55, 'Descrizione del prodotto 1', 32.67, 589, '0664352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0206', 'Prodotto 2', 122.95, true, 2.39, 'Descrizione del prodotto 2', 9.87, 1021, '0664352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0306', 'Prodotto 3', 119.50, false, 11.00, 'Descrizione del prodotto 3', 0.33, 799, '0664352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0116', 'Prodotto 1', 9.99, true, 2.35, 'Descrizione del prodotto 1', 12.67, 589, '1664352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0216', 'Prodotto 2', 112.95, true, 2.39, 'Descrizione del prodotto 2', 9.47, 1021, '1664352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0316', 'Prodotto 3', 112.50, false, 12.00, 'Descrizione del prodotto 3', 1.33, 799, '1664352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0126', 'Prodotto 1', 0.99, true, 2.35, 'Descrizione del prodotto 1', 2.67, 699, '2664352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0226', 'Prodotto 2', 132.91, true, 2.39, 'Descrizione del prodotto 2', 12.47, 2021, '2664352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0326', 'Prodotto 3', 12.50, false, 12.00, 'Descrizione del prodotto 3', 1.63, 119, '2664352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0136', 'Prodotto 1', 67.00, true, 3.35, 'Descrizione del prodotto 1', 3.40, 999, '3664352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0236', 'Prodotto 2', 16.11, true, 2.50, 'Descrizione del prodotto 2', 6.40, 1121, '3664352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0336', 'Prodotto 3', 112.50, false, 1.00, 'Descrizione del prodotto 3', 21.23, 2119, '3664352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0146', 'Prodotto 1', 1.33, true, 7.35, 'Descrizione del prodotto 1', 4.33, 1901, '4664352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0246', 'Prodotto 2', 112.12, true, 2.66, 'Descrizione del prodotto 2', 1.40, 921, '4664352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0346', 'Prodotto 3', 15.55, false, 5.00, 'Descrizione del prodotto 3', 4.4, 2112, '4664352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0156', 'Prodotto 1', 5.0, true, 0.35, 'Descrizione del prodotto 1', 4.00, 2901, '5664352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0256', 'Prodotto 2', 12.00, true, 5.66, 'Descrizione del prodotto 2', 11.42, 1921, '5664352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0356', 'Prodotto 3', 0.55, false, 0.00, 'Descrizione del prodotto 3', 2.4, 912, '5664352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0166', 'Prodotto 1', 5.99, true, 1.35, 'Descrizione del prodotto 1', 1.01, 1099, '6664352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0266', 'Prodotto 2', 155.48, true, 2.86, 'Descrizione del prodotto 2', 33.42, 2099, '6664352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0366', 'Prodotto 3', 32.55, false, 1.80, 'Descrizione del prodotto 3', 2.12, 999, '6664352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0176', 'Prodotto 1', 5.44, true, 2.35, 'Descrizione del prodotto 1', 5.77, 991, '7664352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0276', 'Prodotto 2', 14.44, true, 4.80, 'Descrizione del prodotto 2', 6.72, 667, '7664352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0376', 'Prodotto 3', 132.55, false, 1.99, 'Descrizione del prodotto 3', 22.12, 2099, '7664352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0186', 'Prodotto 1', 15.44, true, 4.45, 'Descrizione del prodotto 1', 6.67, 881, '8664352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0286', 'Prodotto 2', 321.34, true, 1.80, 'Descrizione del prodotto 2', 5.76, 1667, '8664352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0386', 'Prodotto 3', 77.15, false, 2.77, 'Descrizione del prodotto 3', 2.12, 2599, '8664352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0196', 'Prodotto 1', 17.09, true, 4.45, 'Descrizione del prodotto 1', 66.55, 382, '9664352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0296', 'Prodotto 2', 30.22, true, 1.80, 'Descrizione del prodotto 2', 3.54, 1557, '9664352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0396', 'Prodotto 3', 76.15, false, 2.77, 'Descrizione del prodotto 3', 42.12, 2330, '9664352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0105', 'Prodotto 1', 5.00, true, 4.05, 'Descrizione del prodotto 1', 22.53, 876, '0564352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0205', 'Prodotto 2', 22.11, true, 4.80, 'Descrizione del prodotto 2', 12.54, 667, '0564352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0305', 'Prodotto 3', 32.15, false, 3.77, 'Descrizione del prodotto 3', 10.14, 2443, '0564352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0115', 'Prodotto 1', 115.00, true, 0.05, 'Descrizione del prodotto 1', 2.63, 1176, '1564352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0215', 'Prodotto 2', 44.43, true, 1.30, 'Descrizione del prodotto 2', 13.56, 647, '1564352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0125', 'Prodotto 1', 32.04, true, 2.05, 'Descrizione del prodotto 1', 0.63, 1222, '2564352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0225', 'Prodotto 2', 33.33, true, 5.69, 'Descrizione del prodotto 2', 12.56, 787, '2564352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0135', 'Prodotto 1', 433.44, true, 1.25, 'Descrizione del prodotto 1', 10.33, 922, '3564352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0235', 'Prodotto 2', 12.20, true, 4.39, 'Descrizione del prodotto 2', 82.46, 700, '3564352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0145', 'Prodotto 1', 40.40, true, 2.24, 'Descrizione del prodotto 1', 19.49, 1221, '4564352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0245', 'Prodotto 2', 65.20, true, 1.11, 'Descrizione del prodotto 2', 2.43, 1700, '4564352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0155', 'Prodotto 1', 20.45, true, 5.00, 'Descrizione del prodotto 1', 8.00, 2231, '5564352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0255', 'Prodotto 2', 165.20, true, 1.20, 'Descrizione del prodotto 2', 12.01, 980, '5564352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0165', 'Prodotto 1', 26.45, true, 4.00, 'Descrizione del prodotto 1', 3.00, 1231, '6564352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0265', 'Prodotto 2', 565.20, true, 3.20, 'Descrizione del prodotto 2', 12.11, 920, '6564352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0175', 'Prodotto 1', 23.45, true, 1.01, 'Descrizione del prodotto 1', 2.02, 4431, '7564352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0275', 'Prodotto 2', 35.20, true, 2.20, 'Descrizione del prodotto 2', 13.11, 920, '7564352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0185', 'Prodotto 1', 321.45, true, 1.66, 'Descrizione del prodotto 1', 1.02, 599, '8564352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0285', 'Prodotto 2', 33.11, true, 2.20, 'Descrizione del prodotto 2', 3.22, 922, '8564352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0195', 'Prodotto 1', 991.45, true, 9.86, 'Descrizione del prodotto 1', 10.02, 99, '9564352056C');
INSERT INTO public.prodotto(codice, nome, prezzo, prime, costospedizione, descrizione, peso, quantitadisponibile, fornitore)
VALUES ('P0295', 'Prodotto 2', 311.12, true, 7.28, 'Descrizione del prodotto 2', 3.22, 1922, '9564352056C');	
--Carrelli
INSERT INTO public.carrello(id, utente, importo)
VALUES (1, 'utente1@studente.unipd.it', 189.98);
INSERT INTO public.carrello(id, utente, importo)
VALUES (2, 'utente1@studente.unipd.it', 788.49);
INSERT INTO public.carrello(id, utente, importo)
VALUES (3, 'utente1@studente.unipd.it', 430.5);
INSERT INTO public.carrello(id, utente, importo)
VALUES (1, 'utente2@studente.unipd.it', 616.41);
INSERT INTO public.carrello(id, utente, importo)
VALUES (2, 'utente2@studente.unipd.it', 12.95);
INSERT INTO public.carrello(id, utente, importo)
VALUES (1, 'utente3@studente.unipd.it', 576.22);
INSERT INTO public.carrello(id, utente, importo)
VALUES (1, 'utente4@studente.unipd.it', 329.99);
INSERT INTO public.carrello(id, utente, importo)
VALUES (2, 'utente4@studente.unipd.it', 271.96);
INSERT INTO public.carrello(id, utente, importo)
VALUES (3, 'utente4@studente.unipd.it', 266.36);
INSERT INTO public.carrello(id, utente, importo)
VALUES (1, 'utente5@studente.unipd.it', 1116.39);
INSERT INTO public.carrello(id, utente, importo)
VALUES (1, 'utente6@studente.unipd.it', 356.47);
INSERT INTO public.carrello(id, utente, importo)
VALUES (2, 'utente6@studente.unipd.it', 353.77);
INSERT INTO public.carrello(id, utente, importo)
VALUES (3, 'utente6@studente.unipd.it', 991.45);
INSERT INTO public.carrello(id, utente, importo)
VALUES (4, 'utente6@studente.unipd.it', 108.64);
INSERT INTO public.carrello(id, utente, importo)
VALUES (1, 'utente7@studente.unipd.it', 256.30);
INSERT INTO public.carrello(id, utente, importo)
VALUES (2, 'utente7@studente.unipd.it', 410.00);
INSERT INTO public.carrello(id, utente, importo)
VALUES (3, 'utente7@studente.unipd.it', 0);
INSERT INTO public.carrello(id, utente, importo)
VALUES (1, 'utente8@studente.unipd.it', 441.13);
INSERT INTO public.carrello(id, utente, importo)
VALUES (1, 'utente9@studente.unipd.it', 0);
INSERT INTO public.carrello(id, utente, importo)
VALUES (1, 'utente10@studente.unipd.it', 195.97);
INSERT INTO public.carrello(id, utente, importo)
VALUES (2, 'utente10@studente.unipd.it', 111.57);
INSERT INTO public.carrello(id, utente, importo)
VALUES (1, 'utente11@studente.unipd.it', 99.93);
INSERT INTO public.carrello(id, utente, importo)
VALUES (2, 'utente11@studente.unipd.it', 384.97);
INSERT INTO public.carrello(id, utente, importo)
VALUES (3, 'utente11@studente.unipd.it', 187.18);
INSERT INTO public.carrello(id, utente, importo)
VALUES (1, 'utente12@studente.unipd.it', 288.25);
INSERT INTO public.carrello(id, utente, importo)
VALUES (1, 'utente13@studente.unipd.it', 232.83);
INSERT INTO public.carrello(id, utente, importo)
VALUES (2, 'utente13@studente.unipd.it', 346.32);
INSERT INTO public.carrello(id, utente, importo)
VALUES (3, 'utente13@studente.unipd.it', 265.82);
INSERT INTO public.carrello(id, utente, importo)
VALUES (4, 'utente13@studente.unipd.it', 1058.11);
INSERT INTO public.carrello(id, utente, importo)
VALUES (1, 'utente14@studente.unipd.it', 452.00);
INSERT INTO public.carrello(id, utente, importo)
VALUES (2, 'utente14@studente.unipd.it', 203.80);
INSERT INTO public.carrello(id, utente, importo)
VALUES (1, 'utente15@studente.unipd.it', 358.94);
INSERT INTO public.carrello(id, utente, importo)
VALUES (1, 'utente16@studente.unipd.it', 0);
INSERT INTO public.carrello(id, utente, importo)
VALUES (1, 'utente17@studente.unipd.it', 202.40);
INSERT INTO public.carrello(id, utente, importo)
VALUES (2, 'utente17@studente.unipd.it', 934.98);
INSERT INTO public.carrello(id, utente, importo)
VALUES (1, 'utente1@unipd.it', 175.75);
INSERT INTO public.carrello(id, utente, importo)
VALUES (2, 'utente1@unipd.it', 0);
INSERT INTO public.carrello(id, utente, importo)
VALUES (1, 'utente2@unipd.it', 293.67);
INSERT INTO public.carrello(id, utente, importo)
VALUES (2, 'utente2@unipd.it', 115.69);
INSERT INTO public.carrello(id, utente, importo)
VALUES (3, 'utente2@unipd.it', 0);
INSERT INTO public.carrello(id, utente, importo)
VALUES (1, 'utente3@unipd.it', 0);
INSERT INTO public.carrello(id, utente, importo)
VALUES (1, 'utente4@unipd.it', 20.45);
INSERT INTO public.carrello(id, utente, importo)
VALUES (2, 'utente4@unipd.it', 322);
INSERT INTO public.carrello(id, utente, importo)
VALUES (1, 'utente5@unipd.it', 97.94);
INSERT INTO public.carrello(id, utente, importo)
VALUES (2, 'utente5@unipd.it', 123.20);
INSERT INTO public.carrello(id, utente, importo)
VALUES (3, 'utente5@unipd.it', 132.91);
INSERT INTO public.carrello(id, utente, importo)
VALUES (1, 'utente6@unipd.it', 0);
INSERT INTO public.carrello(id, utente, importo)
VALUES (1, 'utente7@unipd.it', 0);
INSERT INTO public.carrello(id, utente, importo)
VALUES (1, 'utente8@unipd.it', 4.75);
INSERT INTO public.carrello(id, utente, importo)
VALUES (2, 'utente8@unipd.it', 189.70);
INSERT INTO public.carrello(id, utente, importo)
VALUES (3, 'utente8@unipd.it', 5.99);
INSERT INTO public.carrello(id, utente, importo)
VALUES (4, 'utente8@unipd.it', 44.43);
INSERT INTO public.carrello(id, utente, importo)
VALUES (1, 'utente9@unipd.it', 30.22);
INSERT INTO public.carrello(id, utente, importo)
VALUES (1, 'utente10@unipd.it', 20.45);
--ProdottiSalvati
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0136', 1, 'utente1@studente.unipd.it', 1);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0307', 1, 'utente1@studente.unipd.it', 1);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0447', 1, 'utente1@studente.unipd.it', 1);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0147', 2, 'utente1@studente.unipd.it', 2);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0267', 2, 'utente1@studente.unipd.it', 2);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0467', 2, 'utente1@studente.unipd.it', 1);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0267', 3, 'utente1@studente.unipd.it', 1);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0397', 3, 'utente1@studente.unipd.it', 4);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0185', 1, 'utente2@studente.unipd.it', 1);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0156', 1, 'utente2@studente.unipd.it', 2);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0567', 1, 'utente2@studente.unipd.it', 1);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0447', 1, 'utente2@studente.unipd.it', 3);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0297', 2, 'utente2@studente.unipd.it', 1);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0376', 1, 'utente3@studente.unipd.it', 2);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0295', 1, 'utente3@studente.unipd.it', 1);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0115', 1, 'utente4@studente.unipd.it', 2);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0225', 1, 'utente4@studente.unipd.it', 3);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0437', 2, 'utente4@studente.unipd.it', 4);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0537', 2, 'utente4@studente.unipd.it', 1); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0257', 2, 'utente4@studente.unipd.it', 3); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0417', 3, 'utente4@studente.unipd.it', 2); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0307', 3, 'utente4@studente.unipd.it', 2); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0517', 1, 'utente5@studente.unipd.it', 5); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0337', 1, 'utente5@studente.unipd.it', 3); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0467', 1, 'utente5@studente.unipd.it', 1); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0367', 1, 'utente5@studente.unipd.it', 4); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0297', 1, 'utente6@studente.unipd.it', 7); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0226', 1, 'utente6@studente.unipd.it', 2); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0295', 2, 'utente6@studente.unipd.it', 1); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0155', 2, 'utente6@studente.unipd.it', 3); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0275', 2, 'utente6@studente.unipd.it', 1); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0195', 3, 'utente6@studente.unipd.it', 1);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0225', 4, 'utente6@studente.unipd.it', 2);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0427', 4, 'utente6@studente.unipd.it', 2);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0527', 1, 'utente7@studente.unipd.it', 5);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0237', 1, 'utente7@studente.unipd.it', 2); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0197', 2, 'utente6@studente.unipd.it', 1);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0337', 1, 'utente8@studente.unipd.it', 2); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0447', 1, 'utente8@studente.unipd.it', 1); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0557', 1, 'utente8@studente.unipd.it', 3); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0477', 1, 'utente8@studente.unipd.it', 3); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0427', 1, 'utente10@studente.unipd.it', 3); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0317', 1, 'utente10@studente.unipd.it', 2); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0247', 2, 'utente10@studente.unipd.it', 4); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0197', 2, 'utente10@studente.unipd.it', 3); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0257', 1, 'utente11@studente.unipd.it', 3);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0307', 1, 'utente11@studente.unipd.it', 2);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0115', 2, 'utente11@studente.unipd.it', 1);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0437', 2, 'utente11@studente.unipd.it', 3);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0537', 2, 'utente11@studente.unipd.it', 2);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0417', 3, 'utente11@studente.unipd.it', 1); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0225', 3, 'utente11@studente.unipd.it', 3); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0275', 1, 'utente12@studente.unipd.it', 3); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0245', 1, 'utente12@studente.unipd.it', 1); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0267', 1, 'utente12@studente.unipd.it', 1); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0367', 1, 'utente12@studente.unipd.it', 2); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0297', 1, 'utente13@studente.unipd.it', 10);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0155', 1, 'utente13@studente.unipd.it', 3); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0427', 1, 'utente13@studente.unipd.it', 2); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0295', 2, 'utente13@studente.unipd.it', 1); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0275', 2, 'utente13@studente.unipd.it', 1); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0226', 3, 'utente13@studente.unipd.it', 2); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0225', 4, 'utente13@studente.unipd.it', 2);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0195', 4, 'utente13@studente.unipd.it', 1); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0527', 1, 'utente14@studente.unipd.it', 4); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0197', 1, 'utente14@studente.unipd.it', 1);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0237', 2, 'utente14@studente.unipd.it', 2); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0337', 1, 'utente15@studente.unipd.it', 1); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0147', 1, 'utente15@studente.unipd.it', 1); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0557', 1, 'utente15@studente.unipd.it', 3); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0477', 1, 'utente15@studente.unipd.it', 3); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0327', 1, 'utente17@studente.unipd.it', 2); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0317', 1, 'utente17@studente.unipd.it', 2); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0207', 2, 'utente17@studente.unipd.it', 5);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0106', 2, 'utente17@studente.unipd.it', 2);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0396', 1, 'utente1@unipd.it', 2);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0175', 1, 'utente1@unipd.it', 1);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0307', 1, 'utente2@unipd.it', 3); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0337', 1, 'utente2@unipd.it', 1);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0367', 2, 'utente2@unipd.it', 1); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0116', 2, 'utente2@unipd.it', 4);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0225', 2, 'utente2@unipd.it', 1);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0155', 1, 'utente4@unipd.it', 1);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0295', 2, 'utente4@unipd.it', 1); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0176', 2, 'utente4@unipd.it', 2); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0296', 1, 'utente5@unipd.it', 2);   
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0326', 1, 'utente5@unipd.it', 3);  
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0187', 2, 'utente5@unipd.it', 1);  
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0226', 3, 'utente5@unipd.it', 1);
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0287', 1, 'utente8@unipd.it', 5); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0357', 2, 'utente8@unipd.it', 1); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0377', 2, 'utente8@unipd.it', 2); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0166', 3, 'utente8@unipd.it', 1); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0215', 4, 'utente8@unipd.it', 1); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0296', 1, 'utente9@unipd.it', 1); 
INSERT INTO public.prodottisalvati(prodotto, carrello, utente, quantita)
VALUES ('P0155', 1, 'utente10@unipd.it', 1); 
--CarteDiCredito
INSERT INTO public.cartadicredito(numero, circuito, scadenza, cvv, intestatario, utente)
VALUES ('1234567812345678', 'Visa', '2030-12-12', '123', 'Intestatario 1', 'utente1@studente.unipd.it');
INSERT INTO public.cartadicredito(numero, circuito, scadenza, cvv, intestatario, utente)
VALUES ('1234567812345677', 'MasterCard', '2030-12-12', '123', 'Intestatario 2', 'utente1@studente.unipd.it');
INSERT INTO public.cartadicredito(numero, circuito, scadenza, cvv, intestatario, utente)
VALUES ('1234567812345676', 'Visa', '2030-12-12', '123', 'Intestatario 1', 'utente2@studente.unipd.it');
INSERT INTO public.cartadicredito(numero, circuito, scadenza, cvv, intestatario, utente)
VALUES ('1234567812345675', 'Visa', '2030-12-12', '123', 'Intestatario 1', 'utente3@studente.unipd.it');
INSERT INTO public.cartadicredito(numero, circuito, scadenza, cvv, intestatario, utente)
VALUES ('1234567812345674', 'MasterCard', '2030-12-12', '123', 'Intestatario 2', 'utente3@studente.unipd.it');
INSERT INTO public.cartadicredito(numero, circuito, scadenza, cvv, intestatario, utente)
VALUES ('1234567812345673', 'MasterCard', '2030-12-12', '123', 'Intestatario 1', 'utente4@studente.unipd.it');
INSERT INTO public.cartadicredito(numero, circuito, scadenza, cvv, intestatario, utente)
VALUES ('1234567812345672', 'Visa', '2030-12-12', '123', 'Intestatario 1', 'utente5@studente.unipd.it');
INSERT INTO public.cartadicredito(numero, circuito, scadenza, cvv, intestatario, utente)
VALUES ('1234567812345671', 'Visa', '2030-12-12', '123', 'Intestatario 1', 'utente6@studente.unipd.it');
INSERT INTO public.cartadicredito(numero, circuito, scadenza, cvv, intestatario, utente)
VALUES ('1234567812345670', 'Visa', '2030-12-12', '123', 'Intestatario 1', 'utente7@studente.unipd.it');
INSERT INTO public.cartadicredito(numero, circuito, scadenza, cvv, intestatario, utente)
VALUES ('1234567812345668', 'Visa', '2030-12-12', '123', 'Intestatario 2', 'utente7@studente.unipd.it');
INSERT INTO public.cartadicredito(numero, circuito, scadenza, cvv, intestatario, utente)
VALUES ('1234567812345667', 'MasterCard', '2030-12-12', '123', 'Intestatario 1', 'utente8@studente.unipd.it');
INSERT INTO public.cartadicredito(numero, circuito, scadenza, cvv, intestatario, utente)
VALUES ('1234567812345666', 'MasterCard', '2030-12-12', '123', 'Intestatario 1', 'utente9@studente.unipd.it');
INSERT INTO public.cartadicredito(numero, circuito, scadenza, cvv, intestatario, utente)
VALUES ('1234567812345665', 'Visa', '2030-12-12', '123', 'Intestatario 1', 'utente10@studente.unipd.it');
INSERT INTO public.cartadicredito(numero, circuito, scadenza, cvv, intestatario, utente)
VALUES ('1234567812345664', 'MasterCard', '2030-12-12', '123', 'Intestatario 2', 'utente10@studente.unipd.it');
INSERT INTO public.cartadicredito(numero, circuito, scadenza, cvv, intestatario, utente)
VALUES ('1234567812345663', 'MasterCard', '2030-12-12', '123', 'Intestatario 1', 'utente11@studente.unipd.it');
INSERT INTO public.cartadicredito(numero, circuito, scadenza, cvv, intestatario, utente)
VALUES ('1234567812345662', 'Visa', '2030-12-12', '123', 'Intestatario 1', 'utente12@studente.unipd.it');
INSERT INTO public.cartadicredito(numero, circuito, scadenza, cvv, intestatario, utente)
VALUES ('1234567812345661', 'Visa', '2030-12-12', '123', 'Intestatario 1', 'utente13@studente.unipd.it');
INSERT INTO public.cartadicredito(numero, circuito, scadenza, cvv, intestatario, utente)
VALUES ('1234567812345660', 'Visa', '2030-12-12', '123', 'Intestatario 1', 'utente14@studente.unipd.it');
INSERT INTO public.cartadicredito(numero, circuito, scadenza, cvv, intestatario, utente)
VALUES ('1234567812345658', 'MasterCard', '2030-12-12', '123', 'Intestatario 1', 'utente15@studente.unipd.it');
INSERT INTO public.cartadicredito(numero, circuito, scadenza, cvv, intestatario, utente)
VALUES ('1234567812345657', 'Visa', '2030-12-12', '123', 'Intestatario 1', 'utente16@studente.unipd.it');
INSERT INTO public.cartadicredito(numero, circuito, scadenza, cvv, intestatario, utente)
VALUES ('1234567812345656', 'Visa', '2030-12-12', '123', 'Intestatario 1', 'utente17@studente.unipd.it');
INSERT INTO public.cartadicredito(numero, circuito, scadenza, cvv, intestatario, utente)
VALUES ('1234567812345655', 'Visa', '2030-12-12', '123', 'Intestatario 1', 'utente1@unipd.it');
INSERT INTO public.cartadicredito(numero, circuito, scadenza, cvv, intestatario, utente)
VALUES ('1234567812345654', 'MasterCard', '2030-12-12', '123', 'Intestatario 2', 'utente1@unipd.it');
INSERT INTO public.cartadicredito(numero, circuito, scadenza, cvv, intestatario, utente)
VALUES ('1234567812345653', 'MasterCard', '2030-12-12', '123', 'Intestatario 1', 'utente2@unipd.it');
INSERT INTO public.cartadicredito(numero, circuito, scadenza, cvv, intestatario, utente)
VALUES ('1234567812345652', 'MasterCard', '2030-12-12', '123', 'Intestatario 1', 'utente3@unipd.it');
INSERT INTO public.cartadicredito(numero, circuito, scadenza, cvv, intestatario, utente)
VALUES ('1234567812345651', 'MasterCard', '2030-12-12', '123', 'Intestatario 1', 'utente4@unipd.it');
INSERT INTO public.cartadicredito(numero, circuito, scadenza, cvv, intestatario, utente)
VALUES ('1234567812345650', 'Visa', '2030-12-12', '123', 'Intestatario 2', 'utente4@unipd.it');
INSERT INTO public.cartadicredito(numero, circuito, scadenza, cvv, intestatario, utente)
VALUES ('1234567812345648', 'MasterCard', '2030-12-12', '123', 'Intestatario 1', 'utente5@unipd.it');
INSERT INTO public.cartadicredito(numero, circuito, scadenza, cvv, intestatario, utente)
VALUES ('1234567812345647', 'MasterCard', '2030-12-12', '123', 'Intestatario 1', 'utente6@unipd.it');
INSERT INTO public.cartadicredito(numero, circuito, scadenza, cvv, intestatario, utente)
VALUES ('1234567812345646', 'MasterCard', '2030-12-12', '123', 'Intestatario 1', 'utente7@unipd.it');
INSERT INTO public.cartadicredito(numero, circuito, scadenza, cvv, intestatario, utente)
VALUES ('1234567812345645', 'Visa', '2030-12-12', '123', 'Intestatario 2', 'utente7@unipd.it');
INSERT INTO public.cartadicredito(numero, circuito, scadenza, cvv, intestatario, utente)
VALUES ('1234567812345644', 'MasterCard', '2030-12-12', '123', 'Intestatario 1', 'utente8@unipd.it');
INSERT INTO public.cartadicredito(numero, circuito, scadenza, cvv, intestatario, utente)
VALUES ('1234567812345643', 'MasterCard', '2030-12-12', '123', 'Intestatario 1', 'utente9@unipd.it');
INSERT INTO public.cartadicredito(numero, circuito, scadenza, cvv, intestatario, utente)
VALUES ('1234567812345642', 'MasterCard', '2030-12-12', '123', 'Intestatario 1', 'utente10@unipd.it');
INSERT INTO public.cartadicredito(numero, circuito, scadenza, cvv, intestatario, utente)
VALUES ('1234567812345641', 'MasterCard', '2030-12-12', '123', 'Intestatario 2', 'utente10@unipd.it');
INSERT INTO public.cartadicredito(numero, circuito, scadenza, cvv, intestatario, utente)
VALUES ('1234567812345640', 'Visa', '2030-12-12', '123', 'Intestatario 1', 'utente10@unipd.it');
--Spedizioni
INSERT INTO public.spedizione(codice, datapartenza, dataarrivo, dataeffettiva)
VALUES ('SP001', '2022-03-01 12:00:00', '2022-04-01 12:00:00', '2022-04-03 13:00:00');
INSERT INTO public.spedizione(codice, datapartenza, dataarrivo, dataeffettiva)
VALUES ('SP002', '2022-02-01 17:00:00', '2022-03-01 17:00:00', '2022-02-26 15:00:00');
INSERT INTO public.spedizione(codice, datapartenza, dataarrivo, dataeffettiva)
VALUES ('SP003', '2022-01-01 11:00:00', '2022-02-01 11:00:00', '2022-02-04 14:00:00');
INSERT INTO public.spedizione(codice, datapartenza, dataarrivo, dataeffettiva)
VALUES ('SP004', '2021-12-01 14:00:00', '2022-01-01 14:00:00', '2021-12-27 14:00:00');
INSERT INTO public.spedizione(codice, datapartenza, dataarrivo, dataeffettiva)
VALUES ('SP005', '2021-11-05 15:30:00', '2021-12-05 15:30:00', '2021-11-25 17:00:00');
INSERT INTO public.spedizione(codice, datapartenza, dataarrivo, dataeffettiva)
VALUES ('SP006', '2022-02-20 15:30:00', '2022-03-20 15:30:00', '2022-03-26 12:00:00');
INSERT INTO public.spedizione(codice, datapartenza, dataarrivo, dataeffettiva)
VALUES ('SP007', '2022-04-22 09:30:00', '2022-05-22 12:30:00', NULL);
INSERT INTO public.spedizione(codice, datapartenza, dataarrivo, dataeffettiva)
VALUES ('SP008', '2021-12-15 10:00:00', '2022-01-15 15:30:00', '2022-01-25 09:30:00');
INSERT INTO public.spedizione(codice, datapartenza, dataarrivo, dataeffettiva)
VALUES ('SP009', '2022-05-24 08:00:00', '2022-06-15 15:30:00', NULL);
INSERT INTO public.spedizione(codice, datapartenza, dataarrivo, dataeffettiva)
VALUES ('SP010', '2018-03-20 12:00:00', '2018-03-21 15:00:00', '2018-03-21 15:00:00');
INSERT INTO public.spedizione(codice, datapartenza, dataarrivo, dataeffettiva)
VALUES ('SP011', '2012-02-01 17:00:00', '2022-03-01 17:00:00', '2022-02-26 15:00:00');
INSERT INTO public.spedizione(codice, datapartenza, dataarrivo, dataeffettiva)
VALUES ('SP012', '2013-01-01 11:00:00', '2013-02-01 11:00:00', '2013-02-15 12:30:00');
INSERT INTO public.spedizione(codice, datapartenza, dataarrivo, dataeffettiva)
VALUES ('SP013', '2014-12-20 14:00:00', '2015-01-10 14:00:00', '2015-01-10 17:20:00');
INSERT INTO public.spedizione(codice, datapartenza, dataarrivo, dataeffettiva)
VALUES ('SP014', '2016-05-05 15:30:00', '2016-06-05 10:30:00', '2016-06-25 13:45:00');
INSERT INTO public.spedizione(codice, datapartenza, dataarrivo, dataeffettiva)
VALUES ('SP015', '2016-02-29 15:30:00', '2022-04-01 10:00:00', '2022-03-29 12:25:00');
INSERT INTO public.spedizione(codice, datapartenza, dataarrivo, dataeffettiva)
VALUES ('SP016', '2017-04-15 09:30:00', '2017-05-22 12:30:00', '2017-05-22 16:30:00');
INSERT INTO public.spedizione(codice, datapartenza, dataarrivo, dataeffettiva)
VALUES ('SP017', '2018-12-22 10:00:00', '2019-01-15 15:30:00', '2018-01-15 15:30:00');
INSERT INTO public.spedizione(codice, datapartenza, dataarrivo, dataeffettiva)
VALUES ('SP018', '2019-06-30 09:00:00', '2019-07-01 15:30:00', '2019-07-04 15:00:00');
INSERT INTO public.spedizione(codice, datapartenza, dataarrivo, dataeffettiva)
VALUES ('SP019', '2019-09-01 12:00:00', '2019-09-15 16:00:00', '2019-09-15 18:00:00');
INSERT INTO public.spedizione(codice, datapartenza, dataarrivo, dataeffettiva)
VALUES ('SP020', '2021-10-10 15:30:00', '2021-10-30 15:30:00', '2021-12-07 13:00:00');
INSERT INTO public.spedizione(codice, datapartenza, dataarrivo, dataeffettiva)
VALUES ('SP021', '2021-10-15 15:30:00', '2021-10-30 15:30:00', '2021-12-07 13:00:00');
INSERT INTO public.spedizione(codice, datapartenza, dataarrivo, dataeffettiva)
VALUES ('SP022', '2021-11-26 10:30:00', '2021-12-23 17:30:00', '2021-12-27 13:00:00');
INSERT INTO public.spedizione(codice, datapartenza, dataarrivo, dataeffettiva)
VALUES ('SP023', '2021-12-06 18:40:00', '2021-12-07 19:30:00', '2021-12-09 13:00:00');
INSERT INTO public.spedizione(codice, datapartenza, dataarrivo, dataeffettiva)
VALUES ('SP024', '2022-02-10 11:10:00', '2022-02-11 16:00:00', '2022-02-11 16:00:00');
INSERT INTO public.spedizione(codice, datapartenza, dataarrivo, dataeffettiva)
VALUES ('SP025', '2022-02-20 15:30:00', '2022-03-08 10:00:00', '2022-03-08 13:10:00');
--Ordini
INSERT INTO public.ordine(carrello, utente, dataacquisto, preferenzespedizione, cartadicredito, codicetransazione, codicespedizione, residenza, puntodiritiro)
VALUES (1, 'utente1@studente.unipd.it', '2022-03-04 12:00', 'Preferenza Spedizione 1', '1234567812345678', 'CS001', 'SP001', NULL, 1);
INSERT INTO public.ordine(carrello, utente, dataacquisto, preferenzespedizione, cartadicredito, codicetransazione, codicespedizione, residenza, puntodiritiro)
VALUES (2, 'utente1@studente.unipd.it', '2022-04-24 12:00', 'Preferenza Spedizione 2', '1234567812345678', 'CS002', 'SP007', NULL, 1);
INSERT INTO public.ordine(carrello, utente, dataacquisto, preferenzespedizione, cartadicredito, codicetransazione, codicespedizione, residenza, puntodiritiro)
VALUES (1, 'utente2@studente.unipd.it', '2019-09-04 12:00', 'Preferenza Spedizione 1', '1234567812345677', 'CS003', 'SP019', 21, NULL);
INSERT INTO public.ordine(carrello, utente, dataacquisto, preferenzespedizione, cartadicredito, codicetransazione, codicespedizione, residenza, puntodiritiro)
VALUES (1, 'utente4@studente.unipd.it', '2012-02-06 12:00', 'Preferenza Spedizione 1', '1234567812345673', 'CS004', 'SP011', NULL, 2);
INSERT INTO public.ordine(carrello, utente, dataacquisto, preferenzespedizione, cartadicredito, codicetransazione, codicespedizione, residenza, puntodiritiro)
VALUES (2, 'utente4@studente.unipd.it', '2017-04-17 12:00', 'Preferenza Spedizione 2', '1234567812345673', 'CS005', 'SP016', NULL, 2);
INSERT INTO public.ordine(carrello, utente, dataacquisto, preferenzespedizione, cartadicredito, codicetransazione, codicespedizione, residenza, puntodiritiro)
VALUES (1, 'utente6@studente.unipd.it', '2021-12-15 12:00', 'Preferenza Spedizione 1', '1234567812345671', 'CS006', 'SP008', NULL, 3);
INSERT INTO public.ordine(carrello, utente, dataacquisto, preferenzespedizione, cartadicredito, codicetransazione, codicespedizione, residenza, puntodiritiro)
VALUES (2, 'utente6@studente.unipd.it', '2022-02-24 12:00', 'Preferenza Spedizione 2', '1234567812345671', 'CS007', 'SP006', 22, NULL);
INSERT INTO public.ordine(carrello, utente, dataacquisto, preferenzespedizione, cartadicredito, codicetransazione, codicespedizione, residenza, puntodiritiro)
VALUES (3, 'utente6@studente.unipd.it', '2022-05-25 12:00', 'Preferenza Spedizione 3', '1234567812345671', 'CS008', 'SP009', 22, NULL);
INSERT INTO public.ordine(carrello, utente, dataacquisto, preferenzespedizione, cartadicredito, codicetransazione, codicespedizione, residenza, puntodiritiro)
VALUES (1, 'utente7@studente.unipd.it', '2021-12-08 12:00', 'Preferenza Spedizione 1', '1234567812345668', 'CS009', 'SP023', NULL, 3);
INSERT INTO public.ordine(carrello, utente, dataacquisto, preferenzespedizione, cartadicredito, codicetransazione, codicespedizione, residenza, puntodiritiro)
VALUES (2, 'utente7@studente.unipd.it', '2022-02-10 12:00', 'Preferenza Spedizione 2', '1234567812345668', 'CS010', 'SP024', 23, NULL);
INSERT INTO public.ordine(carrello, utente, dataacquisto, preferenzespedizione, cartadicredito, codicetransazione, codicespedizione, residenza, puntodiritiro)
VALUES (1, 'utente10@studente.unipd.it', '2021-10-14 12:00', 'Preferenza Spedizione 1', '1234567812345664', 'CS011', 'SP020', NULL, 4);
INSERT INTO public.ordine(carrello, utente, dataacquisto, preferenzespedizione, cartadicredito, codicetransazione, codicespedizione, residenza, puntodiritiro)
VALUES (1, 'utente11@studente.unipd.it', '2021-11-07 12:00', 'Preferenza Spedizione 1', '1234567812345663', 'CS012', 'SP005', NULL, 5);
INSERT INTO public.ordine(carrello, utente, dataacquisto, preferenzespedizione, cartadicredito, codicetransazione, codicespedizione, residenza, puntodiritiro)
VALUES (2, 'utente11@studente.unipd.it', '2021-11-08 12:00', 'Preferenza Spedizione 2', '1234567812345663', 'CS013', 'SP005', NULL, 5);
INSERT INTO public.ordine(carrello, utente, dataacquisto, preferenzespedizione, cartadicredito, codicetransazione, codicespedizione, residenza, puntodiritiro)
VALUES (1, 'utente13@studente.unipd.it', '2022-02-25 12:00', 'Preferenza Spedizione 1', '1234567812345661', 'CS014', 'SP006', NULL, 6);
INSERT INTO public.ordine(carrello, utente, dataacquisto, preferenzespedizione, cartadicredito, codicetransazione, codicespedizione, residenza, puntodiritiro)
VALUES (2, 'utente13@studente.unipd.it', '2022-04-24 12:00', 'Preferenza Spedizione 2', '1234567812345661', 'CS015', 'SP007', 24, NULL);
INSERT INTO public.ordine(carrello, utente, dataacquisto, preferenzespedizione, cartadicredito, codicetransazione, codicespedizione, residenza, puntodiritiro)
VALUES (3, 'utente13@studente.unipd.it', '2022-05-24 12:00', 'Preferenza Spedizione 3', '1234567812345661', 'CS016', 'SP009', NULL, 7);
INSERT INTO public.ordine(carrello, utente, dataacquisto, preferenzespedizione, cartadicredito, codicetransazione, codicespedizione, residenza, puntodiritiro)
VALUES (1, 'utente14@studente.unipd.it', '2013-01-17 12:00', 'Preferenza Spedizione 1', '1234567812345660', 'CS017', 'SP012', NULL, 8);
INSERT INTO public.ordine(carrello, utente, dataacquisto, preferenzespedizione, cartadicredito, codicetransazione, codicespedizione, residenza, puntodiritiro)
VALUES (1, 'utente17@studente.unipd.it', '2012-02-04 12:00', 'Preferenza Spedizione 1', '1234567812345656', 'CS018', 'SP011', NULL, 9);
INSERT INTO public.ordine(carrello, utente, dataacquisto, preferenzespedizione, cartadicredito, codicetransazione, codicespedizione, residenza, puntodiritiro)
VALUES (1, 'utente1@unipd.it', '2022-03-07 12:00', 'Preferenza Spedizione 1', '1234567812345654', 'CS019', 'SP001', NULL, 10);
INSERT INTO public.ordine(carrello, utente, dataacquisto, preferenzespedizione, cartadicredito, codicetransazione, codicespedizione, residenza, puntodiritiro)
VALUES (1, 'utente2@unipd.it', '2021-11-11 12:00', 'Preferenza Spedizione 1', '1234567812345653', 'CS020', 'SP005', NULL, 10);
INSERT INTO public.ordine(carrello, utente, dataacquisto, preferenzespedizione, cartadicredito, codicetransazione, codicespedizione, residenza, puntodiritiro)
VALUES (2, 'utente2@unipd.it', '2022-04-24 12:00', 'Preferenza Spedizione 2', '1234567812345653', 'CS021', 'SP007', 25, NULL);
INSERT INTO public.ordine(carrello, utente, dataacquisto, preferenzespedizione, cartadicredito, codicetransazione, codicespedizione, residenza, puntodiritiro)
VALUES (1, 'utente4@unipd.it', '2021-12-06 12:00', 'Preferenza Spedizione 1', '1234567812345651', 'CS022', 'SP023', NULL, 11);
INSERT INTO public.ordine(carrello, utente, dataacquisto, preferenzespedizione, cartadicredito, codicetransazione, codicespedizione, residenza, puntodiritiro)
VALUES (1, 'utente5@unipd.it', '2017-04-20 12:00', 'Preferenza Spedizione 1', '1234567812345648', 'CS023', 'SP016', NULL, 11);
INSERT INTO public.ordine(carrello, utente, dataacquisto, preferenzespedizione, cartadicredito, codicetransazione, codicespedizione, residenza, puntodiritiro)
VALUES (2, 'utente5@unipd.it', '2019-06-30 12:00', 'Preferenza Spedizione 2', '1234567812345648', 'CS024', 'SP018', NULL, 12);
INSERT INTO public.ordine(carrello, utente, dataacquisto, preferenzespedizione, cartadicredito, codicetransazione, codicespedizione, residenza, puntodiritiro)
VALUES (1, 'utente8@unipd.it', '2014-12-21 12:00', 'Preferenza Spedizione 1', '1234567812345644', 'CS025', 'SP013', NULL, 13);
INSERT INTO public.ordine(carrello, utente, dataacquisto, preferenzespedizione, cartadicredito, codicetransazione, codicespedizione, residenza, puntodiritiro)
VALUES (2, 'utente8@unipd.it', '2022-04-24 12:00', 'Preferenza Spedizione 2', '1234567812345644', 'CS026', 'SP007', NULL, 14);
INSERT INTO public.ordine(carrello, utente, dataacquisto, preferenzespedizione, cartadicredito, codicetransazione, codicespedizione, residenza, puntodiritiro)
VALUES (3, 'utente8@unipd.it', '2022-04-30 12:00', 'Preferenza Spedizione 3', '1234567812345644', 'CS027', 'SP007', NULL, 15);
--Resi
INSERT INTO public.reso(prodotto, ordine, utente, quantita, motivazione, indirizzo)
VALUES ('P0136', 1, 'utente1@studente.unipd.it', 1, 'Motivazione 1', 48);
INSERT INTO public.reso(prodotto, ordine, utente, quantita, motivazione, indirizzo)
VALUES ('P0417', 1, 'utente11@studente.unipd.it', 1, 'Motivazione 2', 32);
INSERT INTO public.reso(prodotto, ordine, utente, quantita, motivazione, indirizzo)
VALUES ('P0337', 1, 'utente2@unipd.it', 1, 'Motivazione 3', 35);
INSERT INTO public.reso(prodotto, ordine, utente, quantita, motivazione, indirizzo)
VALUES ('P0115', 1, 'utente4@studente.unipd.it', 1, 'Motivazione 4', 60);
INSERT INTO public.reso(prodotto, ordine, utente, quantita, motivazione, indirizzo)
VALUES ('P0295', 2, 'utente6@studente.unipd.it', 1, 'Motivazione 5', 71);
INSERT INTO public.reso(prodotto, ordine, utente, quantita, motivazione, indirizzo)
VALUES ('P0267', 2, 'utente1@studente.unipd.it', 1, 'Motivazione 6', 39);
INSERT INTO public.reso(prodotto, ordine, utente, quantita, motivazione, indirizzo)
VALUES ('P0437', 2, 'utente11@studente.unipd.it', 1, 'Motivazione ', 36);
INSERT INTO public.reso(prodotto, ordine, utente, quantita, motivazione, indirizzo)
VALUES ('P0367', 2, 'utente2@unipd.it', 1, 'Motivazione ', 39);

--1
SELECT Utente.Email, COUNT(*) as NumeroResi
FROM Reso, Utente
WHERE Reso.Utente = Utente.Email
GROUP BY Utente.Email
ORDER BY NumeroResi DESC

--2
SELECT Nome, NumeroTelefono, Email, ProdottiPrime
FROM Fornitore JOIN
(
    SELECT Fornitore as PIVA, COUNT(*) as ProdottiPrime
    FROM Prodotto
    WHERE Prime = TRUE
    GROUP BY PIVA
    ORDER BY ProdottiPrime DESC
    LIMIT(5)
) as FornitorePrime
ON Fornitore.PIVA = FornitorePrime.PIVA

--3
  DROP VIEW IF EXISTS FornitoreEstero;
    CREATE VIEW FornitoreEstero as
    SELECT PIVA
    FROM Fornitore, Stabilimento
    WHERE Stabilimento.Fornitore = Fornitore.PIVA
    AND Stato <> 'IT';

    SELECT Nome, Cognome, Citta
    FROM Utente, Indirizzo,
    (
        SELECT DISTINCT ProdottiAcquistati.Utente
        FROM Prodotto JOIN
        (
            SELECT ProdottiSalvati.Prodotto, ProdottiSalvati.Utente
            FROM Ordine, Carrello, ProdottiSalvati
            WHERE Ordine.Carrello = Carrello.id
            AND Ordine.Utente = Carrello.Utente
            AND Carrello.id = ProdottiSalvati.Carrello
            AND Carrello.Utente = ProdottiSalvati.Utente
        ) as ProdottiAcquistati
        ON ProdottiAcquistati.Prodotto = Prodotto.Codice
        WHERE Prodotto.Fornitore IN (SELECT * FROM FornitoreEstero)
    ) as Utenti
    WHERE Utente.Email = Utenti.Utente
    AND Utente.Residenza = Indirizzo.id;

--4
SELECT Nome, Quantita, ProdottiAcquistati.Ordine, ProdottiAcquistati.Utente, ProdottiAcquistati.CodiceSpedizione
FROM Prodotto JOIN
(
    SELECT Prodotto as Codice, Quantita, InfoAcquisto.Carrello as Ordine, InfoAcquisto.Utente, InfoAcquisto.Codice as CodiceSpedizione
    FROM ProdottiSalvati JOIN 
    (
        SELECT Carrello, Utente, Codice
        FROM Ordine JOIN Spedizione
        ON Ordine.CodiceSpedizione = Spedizione.Codice
        WHERE Ordine.PuntoDiRitiro = 
        (
            SELECT Id 
            FROM Indirizzo
            WHERE Via = 'Via Trieste'
            AND NumeroCivico = '63'
            AND CAP = '35121'
            AND Citta = 'Padova'
        )
        ORDER BY DataEffettiva
        LIMIT(5)
    ) as InfoAcquisto
    ON InfoAcquisto.Utente = ProdottiSalvati.Utente
    AND InfoAcquisto.Carrello = ProdottiSalvati.Carrello
) as ProdottiAcquistati
ON Prodotto.Codice = ProdottiAcquistati.Codice

--5
DROP VIEW IF EXISTS OrdiniPerCircuto;
CREATE VIEW OrdiniPerCircuto as
SELECT Circuito, Ordine.Utente, COUNT(*) as OrdiniEffettuati
FROM Ordine, CartaDiCredito
WHERE Ordine.CartaDiCredito = CartaDiCredito.Numero
GROUP BY Circuito, Ordine.Utente;

SELECT UtenteDatoImportoTotale.Email, UtenteDatoImportoTotale.Abbonamento, OrdiniPerCircuto.Circuito, UtenteDatoImportoTotale.ImportoTotale
FROM OrdiniPerCircuto,
(
    SELECT Utente.Email as Email, Abbonamento, SpesaUtente.ImportoTotale
    FROM Utente JOIN
    (
        SELECT Carrello.Utente as Email, SUM(Importo) as ImportoTotale
        FROM Ordine, Carrello
        WHERE Ordine.Utente = Carrello.Utente
        AND Ordine.Carrello = Carrello.Id
        GROUP BY Carrello.Utente
        HAVING SUM(Importo) >= 500
    ) as SpesaUtente
    ON Utente.Email = SpesaUtente.Email
) as UtenteDatoImportoTotale
WHERE UtenteDatoImportoTotale.Email = OrdiniPerCircuto.Utente
AND OrdiniPerCircuto.OrdiniEffettuati = (SELECT MAX(OrdiniEffettuati)
                                         FROM OrdiniPerCircuto
                                         WHERE OrdiniPerCircuto.Utente = UtenteDatoImportoTotale.Email)
