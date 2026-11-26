PROGETTI_MDB\\MSYS · Access · stato al 14/11/2026

# Master Plan MSys

Una Form MASTER che carica nelle sue 12 pagine le sottoform dichiarate in due tabelle: i **progetti** e le **pagine**. Ogni mini-progetto vive nella sua cartella con dati e oggetti separati; il MASTER collega i dati e importa gli oggetti. Questa pagina fissa il quadro d'insieme, le definizioni e la grammatica dei nomi.

Basato sull'inventario in sola lettura di oltre 70 database in `PROGETTI_MDB\MSYS` (albero nuovo) e `PROGETTI_MDB\MSYS_OGGETTI\MSYS\MDB` (albero attuale). Le etichette come `#18.06` rimandano alle sezioni e ai paragrafi del codice della Form MASTER.

[#01Quadro d'insieme](#quadro) [#02Definizioni](#definizioni) [#03Caricamento](#caricamento) [#04Ciclo di un oggetto](#ciclo) [#05Nomi e chiavi](#nomi) [#06Cartelle](#cartelle) [#07Inventario](#inventario) [#08Roadmap](#roadmap) [#09Decisioni](#decisioni)

#01#

## Il quadro d'insieme

Il sistema ha tre parti. I **mini-progetti** producono tabelle e oggetti. L'**utilità** TB30 li porta nel MASTER. L'**applicazione MASTER** li usa. I dati non vengono mai copiati: il MASTER li legge attraverso un collegamento, quindi un errore nel MASTER non può danneggiare i dati.

Il mini-progetto tiene i dati nel back-end e gli oggetti nel front-end. Il MASTER collega le tabelle senza copiarle e importa solo gli oggetti. La Form MASTER legge in TB40 e TB41 quali form mostrare e le assegna alle pagine.

#02#

## Le definizioni

La parola **progetto** oggi indica tre cose diverse: tutto MSys, una cartella come DF11, una riga della tabella dei progetti del MASTER. Da qui in avanti ognuna ha un nome suo.

Super-progetto MSys

Tutto il sistema, cioè la cartella `MSYS\`. Chiave di estrazione: `MSys_*`

Mini-progetto

Una cartella con un codice di 4 caratteri (`DF11`, `TB41`), una tabella principale e i suoi oggetti. Ha due database: back-end e front-end. Chiave: `MSys_DF11_*`

Definizione (DF)

Mini-progetto con valori stabili che descrivono il sistema: comandi, tipi di oggetto, codici progetto, DLL, percorsi.

Archivio (TB)

Mini-progetto con dati che cambiano durante il lavoro. La copia di lavoro temporanea ha suffisso `_TMP`.

Back-end

`MSys_DF11.mdb`: contiene **solo tabelle**. È il file da proteggere; nessuno ci lavora dentro con le form.

Front-end

`GE_MSys_DF11.mdb`: collegamenti alle tabelle, query, form, report, moduli. Si può ricostruire in qualsiasi momento.

Applicazione MASTER

`MSYS_ATTIVA_GEST_OGGETTI.mdb`: il front-end che collega le tabelle di tutti i mini-progetti e contiene gli oggetti importati. Non è un mini-progetto.

Progetto MASTER

Una riga di **TB40** identificata da `COD_PROGETTO_s`. Dice quale insieme di pagine caricare. Quello attivo ha `Scel_b = True`.

Pagina

Una riga di **TB41**: numero (1–12), sottomaschera (`SottoForm_01`…`_12`), nome della form da caricare, etichetta, visibilità.

Chiave di estrazione

La parte iniziale (o una parte in posizione fissa) del nome di un oggetto, usata in un filtro `LIKE` per trovare un gruppo di oggetti.

#03#

## Il meccanismo di caricamento

Due tabelle bastano a descrivere cosa mostra la Form MASTER. Un progetto MASTER ha molte pagine; ogni pagina indica il nome di una form che deve già esistere nel database del MASTER.

TB40 e TB41 sono i nomi proposti per le tabelle che oggi si chiamano TAB401 e TAB402 (le cartelle `Msys_TB40_PROG_MASTER` e `MSys_TB41_VISUAL_PAG_MASTER` esistono già). La linea tratteggiata è la proposta: il codice progetto di TB40 si sceglie da DF11 invece di essere riscritto.

### Cosa succede quando si apre la Form MASTER

Il controllo preventivo `#18.06` verifica tutte le form visibili prima di caricarne anche una sola: se ne manca una, nessuna pagina viene caricata e un unico messaggio elenca ID, numero, pagina e nome. Lo stesso percorso parte dal doppio click sul codice progetto nella sottomaschera 401.

#04#

## Il ciclo di vita di un oggetto

Una sottoform arriva nella Form MASTER sempre per gli stessi sei passi. Ogni passo ha un posto preciso, e un controllo impedisce di saltare quello prima.

1. ### Costruisci

   Crei form, query e moduli nel front-end del mini-progetto, con i nomi della sezione #05. I dati restano nel back-end.

   GE_MSys_DF11.mdb
2. ### Esporta

   Salvi gli oggetti in testo nella cartella OBJECT e fai commit con git: copia di sicurezza e storia delle modifiche.

   OBJECT\\ · git
3. ### Importa

   Dal MASTER importi gli oggetti e colleghi le tabelle del back-end con l'utilità TB30.

   Msys_TB30_UTIL · Frm21 IMPORTA_OGGETTI
4. ### Registra

   In TB41 aggiungi le pagine del progetto. Un nome di form inesistente viene rifiutato subito.

   form 402 · controllo #02.02
5. ### Attiva

   In TB40 spunti `Scel_b` sul progetto. Il controllo sulla spunta è progettato ma non ancora installato.

   sottomaschera 401 · #08 (proposto)
6. ### Carica

   La Form MASTER verifica tutte le form del progetto e le assegna alle pagine.

   Form MASTER · #18.06 → #09

#05#

## La grammatica dei nomi

Un nome è fatto di segmenti in **ordine fisso** e di **larghezza fissa**. È questo che rende possibili le chiavi di estrazione: con posizioni fisse un filtro può chiedere "tutte le query di aggiornamento" senza confondersi con le descrizioni.

MSys**Progetto**sempre così

\_

DF01**Mini-progetto**4 caratteri

\_

Qry01**Tipo + tabella**query sulla Tb01

\_

01**Progressivo**2 cifre

\_

SEL**Ruolo**3 lettere

\_

COMANDI_TUTTI**Descrizione**maiuscolo, libera

### Codici dei mini-progetti per fasce

Le fasce ricalcano i codici che usi già: il numero dice da solo a quale famiglia appartiene un mini-progetto.

| Fascia | Famiglia | Esistenti |
| --- | --- | --- |
| `DF00` | modello da copiare | DF00, MSYS_BASE |
| `DF01–DF09` | definizioni degli oggetti | DF01 comandi · DF02 tipi oggetto · DF05 attributi |
| `DF10–DF19` | definizioni di progetto | DF10 database · DF11 codici · DF12 · DF13 DLL · DF14 path · DF19 controlli |
| `TB01–TB19` | archivi | TB03 elenco oggetti · TB04 · TB12 file |
| `TB20–TB29` | archivi di supporto | TB20 proprietà controlli |
| `TB30–TB39` | utilità | TB30 UTIL |
| `TB40–TB49` | sistema MASTER | TB40 progetti · TB41 pagine |
| `TB90–TB99` | servizio | TB99 LINK |

### Tipi di oggetto

Il primo numero dopo il tipo è la tabella del mini-progetto su cui l'oggetto lavora; il secondo è il progressivo.

| Token | Oggetto | Esempio |
| --- | --- | --- |
| `Tb01` | tabella | `MSys_DF01_Tb01_COMANDI` |
| `Qry01_01` | query | `MSys_DF01_Qry01_01_SEL_COMANDI` |
| `Frm01_M01` | form principale | `MSys_DF01_Frm01_M01_COMANDI` |
| `Frm01_S01` | sottoform | `MSys_DF01_Frm01_S01_COMANDI` |
| `Frm01_D01` | finestra di dialogo | `MSys_TB30_Frm01_D01_PROGRESSO` |
| `Rpt01_01` | report | `MSys_DF01_Rpt01_01_COMANDI` |
| `Mdl01` | modulo | `MSys_DF01_Mdl01_COLLEGA_COMANDI` |
| `Cls01` | classe | `MSys_TB30_Cls01_GESTIONE_OGGETTI` |
| `Mcr01` | macro | `MSys_DF01_Mcr01_AVVIO` |

### Ruolo delle query

| Ruolo | Tipo di query Access | Ruolo | Tipo di query Access |
| --- | --- | --- | --- |
| `SEL` | selezione | `INS` | accodamento |
| `GRP` | raggruppamento, totali | `UPD` | aggiornamento |
| `UNI` | unione | `DEL` | eliminazione |
| `XTB` | a campi incrociati | `MAK` | creazione tabella |

Suffissi: `_TMP` per tabelle temporanee e oggetti che ci lavorano sopra. Le intestazioni di gruppo come `MSys_DF01_}-----@` restano: separano i gruppi nel riquadro di spostamento e non sono oggetti di lavoro.

### Dai nomi di oggi ai nomi proposti

| Oggi | Proposto | Cosa cambia |
| --- | --- | --- |
| `MSys_DF01_COMANDI_Qry01_01_SELECT_TUTTI` | `MSys_DF01_Qry01_01_SEL_COMANDI_TUTTI` | il tipo segue subito il codice; ruolo di 3 lettere |
| `Msys_DF01Qry01_01_COMANDI_TUTTI` | `MSys_DF01_Qry01_02_SEL_COMANDI_TUTTI` | manca il `_` dopo DF01; da unificare con la precedente se fanno la stessa cosa |
| `MSSys_DF02_Qry01_01_SELECT_TIPO_OGGETTO` | `MSys_DF02_Qry01_01_SEL_TIPO_OGGETTO` | `MSSys_` esce dal filtro `MSys_*` |
| `MSsys_DF05_Qry01_ATTRIBUTI` | `MSys_DF05_Qry01_01_SEL_ATTRIBUTI` | stesso problema, e manca il progressivo |
| `MSys_TAB402_Qry01_02_VISUAL_PAG_MASTER_Insert_TMP` | `MSys_TB41_Qry01_02_INS_PAGINE_TMP` | codice di 4 caratteri; ruolo in posizione fissa |
| `MSys_TAB401_Frm01_01_GE_TabContr_MASTER` | `MSys_TB40_Frm01_S01_PROGETTI` | è una sottoform: `S01` |
| `Msys_DF01_Frm01_M01_GE_COMANDI` | `MSys_DF01_Frm01_M01_COMANDI` | già quasi conforme; `GE_` è implicito in `M01` |
| `Msys_DF11_Mdl01_COLLEGA_PROGETTI` | `MSys_DF11_Mdl01_COLLEGA_PROGETTI` | solo il prefisso |

### Le chiavi di estrazione

In Access `*` vale qualsiasi testo, `?` un carattere, `#` una cifra. Grazie alla larghezza fissa, `????` copre qualunque codice di mini-progetto.

| Chiave (LIKE) | Estrae |
| --- | --- |
| `MSys_*` | tutto il super-progetto (le tabelle di sistema come `MSysObjects` restano fuori grazie al `_`) |
| `MSys_DF*` | tutte le definizioni |
| `MSys_DF1#_*` | le definizioni di progetto, DF10–DF19 |
| `MSys_TB4#_*` | tutto il sistema MASTER |
| `MSys_DF01_*` | tutto il mini-progetto DF01 |
| `MSys_DF01_Qry*` | le query di DF01 |
| `MSys_????_Qry##_##_UPD_*` | tutte le query di aggiornamento del progetto |
| `MSys_????_Frm##_M##_*` | tutte le form principali |
| `MSys_????_Frm##_S##_*` | tutte le sottoform |
| `MSys_*_TMP` | tutti gli oggetti temporanei |

```
' tutte le query di aggiornamento del super-progetto, dall'interno di Access
SELECT Name FROM MSysObjects
WHERE Name LIKE "MSys_????_Qry##_##_UPD_*" AND Type = 5;
' Type: 1 tabella locale · 6 collegata · 5 query · -32768 form · -32764 report · -32761 modulo
```

Il carattere `_` è un carattere normale nelle query di Access e nell'operatore `Like` di VBA. Diventa un jolly solo con ADO in modalità ANSI-92: in quel caso si scrive `[_]`.

### Regole

- Il prefisso è sempre `MSys_`, scritto così. Le maiuscole non cambiano il risultato del filtro, ma una lettera in più sì.
- Il codice del mini-progetto ha sempre 4 caratteri: `TB41`, mai `TAB402` o `TB0401`.
- I numeri hanno sempre 2 cifre: `Qry01_03`, mai `Qry1_3`.
- L'ordine dei segmenti non cambia: progetto, mini-progetto, tipo e numeri, ruolo, descrizione.
- La descrizione è in maiuscolo, con `_` tra le parole, senza spazi né accenti.
- Al massimo 64 caratteri (limite di Access); meglio restare sotto i 45.
- Un oggetto ha un solo nome: niente date, "copia di" o `_OLD` nel nome. Le versioni stanno in git, i dismessi in `ZZ_OLD\`.

#06#

## Le cartelle

### Albero proposto

```
MSYS\
├─ 00_DOC\                 master plan, convenzioni
├─ MSYS_ATTIVA_GEST\       applicazione MASTER
├─ MSys_AA_PROJECT_E_MASTER_PLAN\              modello da copiare
├─ MSys_DF01 … DF09\       definizioni oggetti
├─ MSys_DF10 … DF19\       definizioni progetto
├─ MSys_TB01 … TB29\       archivi
├─ MSys_TB30 … TB39\       utilità
├─ MSys_TB40 … TB49\       sistema MASTER
├─ MSys_TB90 … TB99\       servizio
└─ ZZ_OLD\                 dismesso, fuori dai filtri
```

### Dentro ogni mini-progetto

```
MSys_DF11\
├─ MDB\
│  ├─ MSys_DF11.mdb        back-end: solo tabelle
│  └─ GE_MSys_DF11.mdb     front-end: tutto il resto
├─ OBJECT\                 oggetti in testo (git)
├─ HELP\                   PDF e note
├─ AA_SALVATAGGI\          copie datate
└─ README_DF11.md          scopo, tabelle, chiave
```

Lo schema esiste già nel nuovo albero. Manca la separazione netta: oggi molti back-end contengono anche form e query (per esempio `MSys_DF01.mdb` ha 3 form), quindi si rischia di modificare la copia sbagliata.

### Dove va ogni cartella di oggi

Contenuto rilevato aprendo i database in sola lettura; tra parentesi il numero di righe.

| Cartella di oggi | Cosa contiene | Proposta | Azione |
| --- | --- | --- | --- |
| Sistema MASTER |  |  |  |
| `MSYS_ATTIVA_GEST` / `MSYS_ATTIVA_GEST_OGGETTI` | front-end MASTER: 60 collegamenti, 197 query, 55 form; presente in tutti e due gli alberi | applicazione MASTER | tieni |
| `TAB_CONTROL_MASTER_(401_402_501_502)` | TAB401 progetti (12) e TAB402 pagine (58): **in uso** | TB40 / TB41 | unisci in TB40/TB41 |
| `Msys_TB40_PROG_MASTER` | MSys_TB40_PROG_MASTER (12) e MSys_TAB40_PROG_MASTER (12), copie | TB40 progetti MASTER | tieni |
| `MSys_TB41_VISUAL_PAG_MASTER` | MSys_TB41_VISUAL_PAG_MASTER (58), copia | TB41 pagine MASTER | tieni |
| `MSys_FORMS_MASTER` | SottoFormMaster e MSys_TUTTI_TB01/TB02: sistema dismesso il 14/11 | — | archivia |
| Definizioni |  |  |  |
| `MSys_AA_PROJECT_E_MASTER_PLAN`, `MSYS_BASE` | modello di mini-progetto; MSYS_BASE_MODELLO con tabelle MODELLO_Tb01… | DF00 modello | unisci in DF00 |
| `MSys_DF01 … DF06` | comandi, tipi oggetto, quote, attributi tabella; DF06 senza database | DF01–DF09 | tieni |
| `MSys_DF10 … DF14` | database, codici progetto, oggetti necessari, DLL, path | DF10–DF19; DF11 anagrafe unica | tieni |
| `TAB_CONTROL` | MSys_DF19_CODICI_CONTROLS (7), MSys_TB20_Control_PROPRIETA (1310) | DF19 + TB20 | decidi |
| Archivi |  |  |  |
| `MSys_TB01_PROGETTI` | Msys_TB01_PROGETTI (24), PROGETTI_Msys_TB01_PROJECT (24), Msys_TUTTI_PROGETTI.mdb | doppione di DF11 | unisci in DF11 |
| `MSys_TB02_TIPO_OGGETTI` | Msys_TB02_TIPO_OGGETTI (43) | sovrapposto a DF12 | decidi |
| `MSys_TB03_ELENCO_OGGETTI` | Msys_TB03_ELENCO_ObjProgetti (377) e un database LLPP | catalogo unico degli oggetti | tieni |
| `MSys_ELENCO` | MSys_ELENCO_ObjProgetti (244) | doppione di TB03 | unisci in TB03 |
| `MSys_FORMS`, `QUERY`, `TABELLE`, `MODULI`, `REPORT`, `MACRO`, `PAGINE`, `Msys_TB05_FORMS` | un inventario per tipo: 35 · 86 · 75 · 49 · 2 · 3 · 43 · 2 | query su TB03 filtrate per tipo | unisci in TB03 |
| `MSys_TB04_DB_ESTERNO` | MSYS_TB04_DB_ESTERNO (4) | sovrapposto a DF10 (database) | decidi |
| `Msys_TB12_FILES` | Msys_TB12_FILES (1) | TB12 file | tieni |
| `MSys_TB99_LINK` | LINK (43), LINK_Object (508), LINK_PATH_DB (43) | TB99 servizio collegamenti | tieni |
| Utilità |  |  |  |
| `Msys_TB30_UTIL` | Frm21 IMPORTA_OGGETTI, 44 query | TB30 import / export | tieni |
| `MsysUTIL`, `MSys_ESPORTA_IMPORTA`, `MSYS_OBJECT_DB_EST`, `TMP_ESPORTA_*`, `TMP_IMPORTA_*` | strumenti di import / export precedenti | confluiscono in TB30 | unisci in TB30 |
| `MSys_GE_FILE` | classi clsFileSystem, clsLogger, clsDBInspector | libreria classi, fascia TB30–TB39 | decidi il codice |
| `MSYS_MENU` | GEST_MENU_Tb01_VOCI (7), GEST_MENU_TB02_FUNZIONI (23), prefisso proprio | mini-progetto menu o progetto a parte | decidi |
| `TREVIEW` | Tree (37), Tree_CLASSI_STAMPA_DI_CONTROLLO (128.355) | visualizzazione ad albero | decidi |
| Archivio |  |  |  |
| `MSYS_OGGETTI_OLD`, `TMP_OGGETTI_DA_CANCELLARE`, `MSys_TUTTI_MODELLI` | vecchio materiale; GE_LLPP_ATTI appartiene a un altro progetto | ZZ_OLD | archivia |

#07#

## Cosa ha mostrato l'inventario

Queste sono le cause concrete della difficoltà a vedere il quadro: la stessa informazione vive in più posti, con nomi diversi.

1. **L'anagrafe dei progetti esiste in cinque tabelle.** Lo stesso codice può avere descrizioni diverse a seconda di dove lo si legge. Msys_DF11_COD_PROGETTO · Msys_TB01_PROGETTI (24) · MSys_TB05_CODICI_PROGETTO (1) · MSys_TB40_PROG_MASTER (12) · MSys_TAB401_GE_TabContr_MASTER (12, in uso)
2. **L'elenco degli oggetti esiste in almeno dieci tabelle**, una per tipo più tre elenchi generali. TB99_LINK_Object (508) · TB03_ELENCO_ObjProgetti (377) · MSys_ELENCO_ObjProgetti (244) · MSys_QUERY (86) · MSys_TABELLE (75) · MSys_MODULI (49) · MSys_PAGINE (43) · MSys_FORMS (35) · MSys_MACRO (3) · MSys_REPORT (2)
3. **Le tabelle del MASTER sono in doppia copia.** MSys_TAB402_VISUAL_PAG_MASTER (58, in uso) e MSys_TB41_VISUAL_PAG_MASTER (58) · MSys_TAB401\_… (12) e MSys_TB40_PROG_MASTER (12)
4. **Il prefisso è scritto in cinque modi.** I primi tre passano il filtro `MSys_*`, gli ultimi due no. MSys\_ · Msys\_ · MSYS\_ · MSSys_DF02_Qry01_01_SELECT_TIPO_OGGETTO · MSsys_DF05_Qry01_ATTRIBUTI
5. **Il tipo di oggetto cambia posizione nel nome**, quindi nessun filtro a posizione fissa funziona. MSys_DF01_COMANDI_Qry01_01\_… · Msys_DF01Qry01_01\_… · MSys_DF02_Qry01_01\_…
6. **I back-end contengono anche form e query**, copie di quelle del front-end. MSys_DF01.mdb: 3 form, 4 query · MSys_DF02.mdb: 2 form, 3 query · MSys_DF03.mdb: 2 form
7. **Nelle cartelle MSys ci sono database di un altro progetto (LLPP).** MSys_GE_FILE\\LLPP_ATTI_DF01_CodiceOpera.mdb · MSys_TB03_ELENCO_OGGETTI\\LLPP_ATTI_TB06_PROCEDIMENTI.mdb · TMP_IMPORTA_MODULI\\LLPP_ATTI_GESTIONE.mdb
8. **Il menu usa un prefisso suo**, quindi nessun filtro `MSys_*` lo trova. GEST_MENU_Tb01_VOCI · GEST_MENU_TB02_FUNZIONI
9. **Ci sono due alberi in parallelo** e il database MASTER esiste in entrambi. PROGETTI_MDB\\MSYS\\MSYS_ATTIVA_GEST · PROGETTI_MDB\\MSYS_OGGETTI\\MSYS\\MDB\\MSYS_ATTIVA_GEST_OGGETTI

#08#

## Roadmap

Ogni fase lascia il sistema funzionante. L'ordine conta: prima le regole, poi le fonti uniche, per ultima la rinomina, che tocca tutto.

1. **Fissare le regole.** Approvare definizioni, fasce dei codici e grammatica dei nomi (questa pagina). Nessun file viene toccato.
2. **Una sola anagrafe dei progetti.** DF11 diventa la fonte dei codici; in TB40 il codice si sceglie da DF11 con una casella combinata. TB01 e TB05 vanno in archivio.
3. **Una sola coppia di tabelle per il MASTER.** TAB401 e TAB402 diventano TB40 e TB41: tabelle, collegamenti, query e codice (`#16.06`, `#18`, sottomaschera 401) in un solo passaggio, con backup e log.
4. **Un solo catalogo degli oggetti.** TB03 con il tipo preso da DF02; gli inventari per tipo diventano query come `MSys_TB03_Qry01_01_SEL_FORM`.
5. **Un solo albero di cartelle.** Tutto in `PROGETTI_MDB\MSYS`; il dismesso in `ZZ_OLD\`; i database LLPP fuori da MSys.
6. **Rinomina graduale.** Una tabella di corrispondenza vecchio nome → nuovo nome e uno script che rinomina e aggiorna i riferimenti, un mini-progetto alla volta, partendo da DF01.

#09#

## Decisioni da prendere

1. **Nomi definitivi delle tabelle del MASTER:** TB40 / TB41 oppure TAB401 / TAB402? Consigliato: TB40 / TB41, le cartelle esistono già e rispettano i 4 caratteri.
2. **Token `Tb01` nel nome delle tabelle:** `MSys_DF01_Tb01_COMANDI` oppure `MSys_DF01_COMANDI`? Consigliato: con il token, così i filtri per tipo funzionano anche sulle tabelle.
3. **Ruolo delle query:** sigla (`SEL`, `UPD`) oppure fasce numeriche come nel modello di TB30 (01 select, 10 group, 25 union, 60 update)? Consigliato: sigla, si legge senza tabella di decodifica.
4. **Menu `GEST_MENU`:** diventa un mini-progetto MSys (per esempio nella fascia TB20–TB29) o resta un progetto a parte?
5. **Oggetti necessari per progetto:** DF12 (`Msys_DF12_ObjProgetti`) oppure TB02 (`Msys_TB02_TIPO_OGGETTI`)? Le due tabelle descrivono la stessa cosa.
6. **TREVIEW e TAB_CONTROL:** restano nel super-progetto o vanno in archivio?

Master Plan MSys · inventario del 14/11/2026 · i numeri tra parentesi sono le righe delle tabelle al momento della lettura.
