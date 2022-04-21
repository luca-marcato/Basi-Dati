# Basi-Dati

La consegna del progetto prevede la costruzione di una base di dati, contenente i seguenti elementi:

- **Analisi dei requisiti**
- **Progettazione**
  - progettazione concettuale
  - progettazione logica
- **Realizzazione** (PostgreSQL and software in C)

## In dettaglio

L'analisi dei requisiti deve identificare:

- Le **classi** degli oggetti di interesse
- Le **relazioni** e le loro proprietà strutturali
- Gli **attributi** delle classi, le relazioni e i loro tipi
- I **vincoli** di integrità (chiavi, not null, ...)

La progettazione concettuale espone:

- Lista di tutte le classi
  - Breve descrizione della collezione che rappresenta
  - Attributi con il loro tipo
  - Vincoli di integrità
- Descrizione delle relazioni e le loro proprietà strutturali
  - Cardinalità
- Descrizione della gerarchia tra le classi
  - Totalità/Parzialità

Si deve inoltre fornire lo **Schema Concettuale**

[link](https://lucid.app/documents/view/4db85d06-4eda-48de-9673-a92fde015418)

La progettazione logica prevede:

- Analisi delle ridondanze (almeno una significativa)
- Eliminazione delle generalizzazioni
- Partizionamento/accorpamento di entità e relazioni
- Scelta degli identificatori primari
- Diagramma schema ristrutturato
  - Schema relazionale
- Descrizione Schema relazionale
- Eventuali vincoli di integrità referenziale

Si deve inoltre fornire lo **Schema Logico**.

[link]()

*L'implementazione dello schema logico ovvero della base di dati deve essere riportato su un file SQL separato.*
In cui deve essere presente tutto il codice per:
- Creazione tabelle
- Popolamento
- Query e Indici

## Vincoli

Il progetto deve includere almeno:

-  5 query significative per rispondere a domandeinteressanti sulla base di dati
  - Una query è significativa se coinvolge almeno **due “relations”** (cioè tabelle)
  - Almeno 3 query devono utilizzare il **“group by” e/o gli operatori aggregati**
  - Almeno 1 query deve utilizzare il **“group by” e “having”**
- Almeno un indice significativo: ipotizzare un caso d'uso su larga scala e motivare la scelta dell’indice/degli indici

Inoltre per essere accettabile un progetto deve possedere i seguenti requisiti minimi:

- Il diagramma E-R del progetto deve contenere un numero adeguato di entità (≥ 5) escluse quelle coinvolte da una gerarchia (conta solo l’entità padre)
- Almeno una gerarchia significativa
- Un esempio di relazione per ogni tipo di cardinalità (1:N, 1:1, N:M)

Domande:
- Cosa si intende che deve essere presente almeno un indice significativo?
- Come posso inserire all'interno del database la cronologia del carrello di ogni utente?
