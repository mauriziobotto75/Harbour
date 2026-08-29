* GESTIONE NOLEGGIO BICICLETTE - Visual FoxPro 9
* Conversione da Harbour

SET SAFETY OFF
SET EXCLUSIVE OFF
SET CENTURY ON
SET DATE FORMAT TO "DD/MM/YYYY"
SET DELETED ON
SET REC LOCK ON

* ========================================
* PROCEDURA PRINCIPALE
* ========================================
PROCEDURE Main()
	LOCAL nScelta := 0
	
	CLS
	
	* Inizializza il database
	InizializzaDatabase()
	
	* Menu principale (da implementare)
	DO MenuPrincipale
	
ENDPROC

* ========================================
* CREAZIONE AUTOMATICA DEI FILE DBF
* ========================================
PROCEDURE InizializzaDatabase()
	LOCAL aBici, aClie, aNole, aPrenotazioni
	
	* 1. ARCHIVIO BICICLETTE
	IF !FILE("biciclette.dbf")
		CREATE TABLE biciclette (ID_BICI N(4), MODELLO C(30), STATO C(1), TARIFFA N(6,2))
		
		* Inserisci dati di test
		INSERT INTO biciclette VALUES (1, "Mountain Bike Rock", "D", 5.00)
		INSERT INTO biciclette VALUES (2, "Bici Elettrica City", "D", 8.50)
		
		* Crea indice
		INDEX ON ID_BICI TAG id_bici
	ENDIF
	
	* 2. ARCHIVIO CLIENTI
	IF !FILE("clienti.dbf")
		CREATE TABLE clienti (ID_CLIE N(4), NOME C(40), TELEFONO C(15), DOC_ID C(15))
		
		* Crea indici
		INDEX ON ID_CLIE TAG id_clie
		INDEX ON NOME TAG nome
	ENDIF
	
	* 3. ARCHIVIO NOLEGGI
	IF !FILE("noleggi.dbf")
		CREATE TABLE noleggi (;
			ID_NOLEG N(6), ;
			ID_BICI N(4), ;
			ID_CLIE N(4), ;
			D_INIZIO D, ;
			O_INIZIO C(8), ;
			ORE_MAX N(3), ;
			CAUZIONE N(6,2), ;
			ANTICIPO N(6,2), ;
			D_FINE D, ;
			O_FINE C(8), ;
			TOTALE N(7,2), ;
			PENALE N(6,2), ;
			SALDO N(7,2) )
		
		* Crea indici
		INDEX ON ID_NOLEG TAG id_noleg
		INDEX ON ID_BICI TAG id_bici
		INDEX ON D_INIZIO TAG d_inizio
	ENDIF
	
	* 4. ARCHIVIO PRENOTAZIONI
	IF !FILE("prenotazioni.dbf")
		CREATE TABLE prenotazioni (;
			ID_PRENOT N(6), ;
			ID_BICI N(4), ;
			ID_CLIE N(4), ;
			D_PRENOTAZIONE D, ;
			STATO_PR C(1) )
		
		* Crea indici
		INDEX ON ID_PRENOT TAG id_prenot
		INDEX ON ID_BICI + DTOS(D_PRENOTAZIONE) TAG bici_data
	ENDIF

ENDPROC

* ========================================
* GESTIONE CLIENTI
* ========================================
PROCEDURE GestioneClienti()
	LOCAL nId := 0, cNome := SPACE(40), cTel := SPACE(15), cDoc := SPACE(15)
	LOCAL nRecCount
	
	CLS
	? "=== NUOVO CLIENTE ANAGRAFICA ==="
	? ""
	
	ACCEPT "ID Cliente (1-9999)        : " TO nId
	ACCEPT "Nome cliente               : " TO cNome
	ACCEPT "Numero Telefono            : " TO cTel
	ACCEPT "Documento Identita         : " TO cDoc
	
	* Validazione input
	IF EMPTY(nId) OR EMPTY(cNome)
		? "Errore: ID e Nome sono obbligatori!"
		INKEY(2)
		RETURN
	ENDIF
	
	USE clienti EXCLUSIVE
	* Controlla se il cliente esiste già
	SET ORDER TO TAG id_clie
	SEEK nId
	
	IF FOUND()
		? "Cliente già registrato!"
		INKEY(2)
		USE
		RETURN
	ENDIF
	
	* Aggiunge nuovo cliente
	APPEND BLANK
	REPLACE ID_CLIE WITH nId, ;
			NOME WITH TRIM(cNome), ;
			TELEFONO WITH TRIM(cTel), ;
			DOC_ID WITH TRIM(cDoc)
	
	USE
	? "Cliente registrato con successo!"
	INKEY(2)

ENDPROC

* ========================================
* AVVIA NUOVO NOLEGGIO
* ========================================
PROCEDURE AvviaNoleggio()
	LOCAL nIdBici := 0, nIdClie := 0, nNuovoId := 1
	LOCAL nCauzione := 0.00, nAnticipo := 0.00, nOreMax := 5
	LOCAL cChiaveCerca := "", lHaPrenotazione := .F.
	LOCAL nLastRec
	
	CLS
	? "=== AVVIA NUOVO NOLEGGIO CON VERIFICA PRENOTAZIONI ==="
	? ""
	
	ACCEPT "Inserisci ID Bici         : " TO nIdBici
	ACCEPT "Inserisci ID Cliente      : " TO nIdClie
	ACCEPT "Limite Max Ore Concesse   : " TO nOreMax
	ACCEPT "Cauzione Richiesta (EUR)  : " TO nCauzione
	ACCEPT "Pagamento Anticipato (EUR): " TO nAnticipo
	
	* Validazione input
	IF EMPTY(nIdBici) OR EMPTY(nIdClie)
		? "Errore: ID Bici e ID Cliente sono obbligatori!"
		INKEY(2)
		RETURN
	ENDIF
	
	* 1. Controllo anagrafica cliente
	USE clienti SHARED
	SET ORDER TO TAG id_clie
	SEEK nIdClie
	
	IF !FOUND()
		? "Errore: Cliente non registrato!"
		USE
		INKEY(2)
		RETURN
	ENDIF
	USE
	
	* 2. Controllo prenotazioni attive per OGGI su questa bicicletta
	IF FILE("prenotazioni.dbf")
		USE prenotazioni SHARED
		SET ORDER TO TAG bici_data
		cChiaveCerca := STR(nIdBici, 4) + DTOS(DATE())
		SEEK cChiaveCerca
		
		IF FOUND() AND STATO_PR == "A"
			IF ID_CLIE == nIdClie
				lHaPrenotazione := .T.  * È la prenotazione del cliente corrente
			ELSE
				? "Errore: Questa bici e' riservata oggi per un'altra prenotazione!"
				USE
				INKEY(2)
				RETURN
			ENDIF
		ENDIF
		USE
	ENDIF
	
	* 3. Controllo e blocco fisico della bicicletta
	USE biciclette EXCLUSIVE
	SET ORDER TO TAG id_bici
	SEEK nIdBici
	
	IF !FOUND() OR STATO != "D"
		? "Errore: Bici non disponibile o in manutenzione!"
		USE
		INKEY(2)
		RETURN
	ENDIF
	
	REPLACE STATO WITH "N"
	USE
	
	* 4. Aggiorna lo stato della prenotazione se presente
	IF lHaPrenotazione
		USE prenotazioni EXCLUSIVE
		REPLACE STATO_PR WITH "E"  * Evasa, trasformata in noleggio attivo
		USE
	ENDIF
	
	* 5. Registrazione finale del noleggio
	USE noleggi EXCLUSIVE
	nLastRec := RECCOUNT()
	
	IF nLastRec > 0
		GO BOTTOM
		nNuovoId := ID_NOLEG + 1
	ELSE
		nNuovoId := 1
	ENDIF
	
	APPEND BLANK
	REPLACE ID_NOLEG WITH nNuovoId, ;
			ID_BICI WITH nIdBici, ;
			ID_CLIE WITH nIdClie, ;
			D_INIZIO WITH DATE(), ;
			O_INIZIO WITH TIME(), ;
			ORE_MAX WITH nOreMax, ;
			CAUZIONE WITH nCauzione, ;
			ANTICIPO WITH nAnticipo, ;
			TOTALE WITH 0.00, ;
			PENALE WITH 0.00, ;
			SALDO WITH 0.00
	
	USE
	
	? "Noleggio #" + TRIM(STR(nNuovoId)) + " avviato con successo!"
	INKEY(2)

ENDPROC

* ========================================
* RIENTRO BICICLETTA E CALCOLO TOTALE
* ========================================
PROCEDURE RientroNoleggio()
	LOCAL nIdBici := 0, nOre := 0, nMinuti := 0, nTotaleOre := 0, nImporto := 0
	LOCAL tInizio, tFine, nDiffSecondi, dDataInizio, cOraInizio
	
	CLS
	? "=== RIENTRO BICICLETTA ==="
	? ""
	
	ACCEPT "Inserisci ID Bici rientrata: " TO nIdBici
	
	* Trova il noleggio attivo per questa bici (senza data fine)
	USE noleggi EXCLUSIVE
	LOCATE FOR ID_BICI == nIdBici AND EMPTY(D_FINE)
	
	IF !FOUND()
		? "Nessun noleggio attivo trovato per questa bicicletta."
		USE
		INKEY(2)
		RETURN
	ENDIF
	
	* Salva i dati del noleggio prima di aggiornare
	dDataInizio := D_INIZIO
	cOraInizio := O_INIZIO
	
	* Registra la fine del noleggio
	REPLACE D_FINE WITH DATE()
	REPLACE O_FINE WITH TIME()
	
	* Calcolo del tempo trascorso (in secondi)
	nDiffSecondi := (D_FINE - dDataInizio) * 86400 + ElapSec(cOraInizio, TIME())
	
	* Converti in ore
	nTotaleOre := nDiffSecondi / 3600.0
	
	* Tariffa minima di 15 minuti
	IF nTotaleOre < 0.25
		nTotaleOre := 0.25
	ENDIF
	
	* Recupera la tariffa della bici per calcolare il totale
	USE biciclette EXCLUSIVE
	SET ORDER TO TAG id_bici
	SEEK nIdBici
	
	IF FOUND()
		nImporto := nTotaleOre * TARIFFA
		REPLACE STATO WITH "D"  * Rende la bici disponibile
	ENDIF
	USE
	
	* Salva il totale calcolato nel record del noleggio
	USE noleggi EXCLUSIVE
	SET ORDER TO TAG id_noleg
	SEEK nIdBici  * Ritorna al record corretto
	REPLACE TOTALE WITH nImporto
	USE
	
	* Mostra il riepilogo
	CLS
	? "========================================="
	? "RIEPILOGO NOLEGGIO CHIUSO"
	? "========================================="
	? "ID Bicicletta    : " + STR(nIdBici, 4)
	? "Tempo totale     : " + TRANSFORM(nTotaleOre, "99.99") + " ore"
	? "Tariffa oraria   : EUR " + TRANSFORM(nImporto / nTotaleOre, "999.99")
	? "Totale da Pagare : EUR " + TRANSFORM(nImporto, "9,999.99")
	? "========================================="
	
	INKEY(0)

ENDPROC

* ========================================
* FUNZIONE AUSILIARIA: CALCOLO SECONDI TRA DUE ORARI
* ========================================
FUNCTION ElapSec(cTimeStart, cTimeEnd)
	LOCAL nSecStart, nSecEnd
	
	* Converte HH:MM:SS in secondi
	nSecStart := VAL(SUBSTR(cTimeStart, 1, 2)) * 3600 + ;
				VAL(SUBSTR(cTimeStart, 4, 2)) * 60 + ;
				VAL(SUBSTR(cTimeStart, 7, 2))
	
	nSecEnd := VAL(SUBSTR(cTimeEnd, 1, 2)) * 3600 + ;
			  VAL(SUBSTR(cTimeEnd, 4, 2)) * 60 + ;
			  VAL(SUBSTR(cTimeEnd, 7, 2))
	
	* Gestisci il caso in cui l'ora di fine sia del giorno successivo
	IF nSecEnd < nSecStart
		nSecEnd := nSecEnd + 86400  * 24 ore in secondi
	ENDIF
	
	RETURN nSecEnd - nSecStart

ENDFUNC

* ========================================
* MENU PRINCIPALE (DA COMPLETARE)
* ========================================
PROCEDURE MenuPrincipale()
	LOCAL nScelta := 0
	
	DO WHILE .T.
		CLS
		? "========================================="
		? "GESTIONE NOLEGGIO BICICLETTE"
		? "========================================="
		? "1. Gestione Clienti"
		? "2. Avvia Noleggio"
		? "3. Rientro Bicicletta"
		? "4. Visualizza Noleggi Attivi"
		? "5. Esci"
		? "========================================="
		
		ACCEPT "Seleziona un'opzione (1-5): " TO nScelta
		
		DO CASE
			CASE nScelta == 1
				DO GestioneClienti
			CASE nScelta == 2
				DO AvviaNoleggio
			CASE nScelta == 3
				DO RientroNoleggio
			CASE nScelta == 4
				DO VisualizzaNoleggiAttivi
			CASE nScelta == 5
				EXIT
			OTHERWISE
				? "Opzione non valida!"
				INKEY(2)
		ENDCASE
	ENDDO

ENDPROC

* ========================================
* VISUALIZZA NOLEGGI ATTIVI
* ========================================
PROCEDURE VisualizzaNoleggiAttivi()
	LOCAL nCount := 0
	
	CLS
	? "=== NOLEGGI ATTIVI ==="
	? ""
	
	USE noleggi SHARED
	SET ORDER TO TAG id_noleg
	GO TOP
	
	IF EOF()
		? "Nessun noleggio attivo."
	ELSE
		? "ID_NOLEG | ID_BICI | ID_CLIE | DATA_INIZIO | ORA_INIZIO | ORE_MAX | CAUZIONE"
		? REPL("-", 80)
		
		DO WHILE !EOF()
			IF EMPTY(D_FINE)  * Solo noleggi attivi
				? STR(ID_NOLEG, 6) + " | " + STR(ID_BICI, 4) + " | " + STR(ID_CLIE, 4) + " | " + ;
				  DTOC(D_INIZIO) + " | " + O_INIZIO + " | " + STR(ORE_MAX, 3) + " | " + ;
				  TRANSFORM(CAUZIONE, "999.99")
				nCount := nCount + 1
			ENDIF
			SKIP
		ENDDO
		
		? REPL("-", 80)
		? "Totale noleggi attivi: " + STR(nCount)
	ENDIF
	
	USE
	? ""
	INKEY(0)

ENDPROC
