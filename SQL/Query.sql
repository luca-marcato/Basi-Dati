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
