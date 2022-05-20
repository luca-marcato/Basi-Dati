--1
SELECT Prodotto.Nome, Prodotto.Prezzo, Prodotto.Descrizione, Prodotto.Prime
FROM Prodotto JOIN 
(
SELECT Prodotto as Codice, COUNT(*) as NumeroResi
FROM Reso
GROUP BY Prodotto
HAVING NumeroResi >= 1000
) as ProdottoReso
ON Prodotto.Codice = ProdottoReso.Codice

--2
SELECT Nome, NumeroTelefono, Email, ProdottiPrime
FROM Fornitore JOIN
(
    SELECT Fornitore as PIVA, COUNT(*) as ProdottiPrime
    FROM Prodotto
    WHERE Prime = TRUE
    GROUP BY PIVA
    ORDER BY ProdottiPrime DESC
    --LIMIT(10) da aggiungere se si vogliono i primi 10
) as FornitorePrime
ON Fornitore.PIVA = FornitorePrime.PIVA

--3
DROP VIEW IF EXISTS FornitoreEstero
CREATE VIEW FornitoreEstero as
SELECT DISTINCT PIVA
FROM Fornitore, Stabilimento
WHERE Stabilimento.Fornitore = Fornitore.PIVA
AND Stato <> "IT"

SELECT ProdottiAcquistati.Utente
FROM Prodotto JOIN
(
    SELECT ProdottiSalvati.Prodotto as Prodotto, ProdottiSalvati.Utente as Utente
    FROM Ordine, Carrello, ProdottiSalvati
    WHERE Ordine.Carrello = Carrello.id
    AND Ordine.Utente = Carrello.Utente
    AND Carrello.id = ProdottiSalvati.Carrello
    AND Carrello.Utente = ProdottiSalvati.Utente
) as ProdottiAcquistati
ON ProdottiAcquistati.Prodotto = Prodotto.Codice
WHERE Prodotto.Fornitore IN FornitoreEstero

--4
SELECT Nome, Quantita, ProdottiAcquistati.DataPartenza, ProdottiAcquistati.DataArrivo
FROM Prodotto JOIN
(
    SELECT Prodotto as Codice, Quantita, InfoAcquisto.DataPartenza as DataPartenza, InfoAcquisto.DataEffettiva as DataArrivo
    FROM ProdottiSalvati JOIN 
    (
        SELECT Carrello, Utente, DataPartenza, DataEffettiva
        FROM Ordine JOIN Spedizione
        ON Ordine.Spedizione = Spedizione.Codice
        WHERE Ordine.PuntoDiRitiro = 
        (
            SELECT Id 
            FROM Indirizzo
            WHERE Via = "Via Trieste"
            AND NumeroCivico = "63",
            AND CAP = "35136",
            AND Citta = "Padova"
        )
        ORDER BY DataEffettiva
        LIMIT(5)
    ) as InfoAcquisto
    ON InfoAcquisto.Utente = ProdottiSalvati.Utente
    AND InfoAcquisto.Carrello = ProdottiSalvati.Carrello
) as ProdottiAcquistati
ON Prodotto.Codice = ProdottiAcquistati.Codice

--5
DROP VIEW IF EXISTS OrdiniPerCircuto
CREATE VIEW OrdiniPerCircuto as
SELECT Circuito, Utente, COUNT(*) as OrdiniEffettuati
FROM Ordine, CartaDiCredito
WHERE Ordine.CartaDiCredito = CartaDiCredito.Numero
GROUP BY Circuito

SELECT UtenteDatoImportoTotale.Email, UtenteDatoImportoTotale.Abbonamento, OC1.Circuito
FROM OrdiniPerCircuto as OC1, OrdiniPerCircuto as OC2,
(
    SELECT Utente.Email as Email, Abbonamento
    FROM Utente JOIN
    (
        SELECT Carrello.Utente as Email, SUM(Importo) as ImportoTotale
        FROM Ordine, Carrello
        WHERE Ordine.Utente = Carrello.Utente
        AND Ordine.Carrello = Carrello.Id
        GROUP BY Carrello.Utente
        HAVING ImportoTotale >= 5000
    ) as SpesaUtente
    ON Utente.Email = SpesaUtente.Email
) as UtenteDatoImportoTotale
WHERE OC1.Utente = OC2.Utente
AND OC1.Circuito <> OC2.Circuito
AND OC1.OrdiniEffettuati >= OC2.OrdiniEffettuati
AND UtenteDatoImportoTotale.Email = OC1.Email