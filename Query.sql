--1
SELECT Prodotto.Nome, Prodotto.Prezzo, Prodotto.Descrizione, Prodtto.Prime
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
