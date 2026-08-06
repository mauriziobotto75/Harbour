REQUEST DBFCDX

PROCEDURE Main()
   LOCAL nScelta := 0
   RddSetDefault( "DBFCDX" )
   SET DATE FORMAT TO "DD/MM/YYYY"
   SET CENTURY ON
   CLS
   
   // Crea i file se non esistono
   InizializzaDatabase()
   
   DO WHILE nScelta # 4
      CLS
      @ 2, 10 SAY "=== GESTIONE NOLEGGIO BICI AVANZATO ==="
      @ 4, 12 SAY "1. Gestione Clienti (Anagrafica)"
      @ 5, 12 SAY "2. Avvia Nuovo Noleggio"
      @ 6, 12 SAY "3. Rientro Bici e Calcolo Totale"
      @ 7, 12 SAY "4. Esci"
      @ 9, 12 SAY "Scelta: " GET nScelta PICTURE "9" RANGE 1, 4
      READ
      
      DO CASE
         CASE nScelta == 1 ; GestioneClienti()
         CASE nScelta == 2 ; AvviaNoleggio()
         CASE nScelta == 3 ; RientroNoleggio()
      ENDCASE
   ENDDO
RETURN

// Creazione automatica dei file DBF necessari
PROCEDURE InizializzaDatabase()
   LOCAL aBici, aClie, aNole
   
   IF !File("biciclette.dbf")
      aBici := { {"ID_BICI",  "N",  4, 0}, ;
                 {"MODELLO",  "C", 30, 0}, ;
                 {"STATO",    "C",  1, 0}, ; // D=Disponibile, N=Noleggiata
                 {"TARIFFA",  "N",  6, 2} }  // Tariffa oraria in €
      DbCreate("biciclette.dbf", aBici)
      
      // Popolamento iniziale di test
      USE biciclette EXCLUSIVE
      APPEND BLANK; REPLACE ID_BICI WITH 1, MODELLO WITH "Mountain Bike Rock", STATO WITH "D", TARIFFA WITH 5.00
      APPEND BLANK; REPLACE ID_BICI WITH 2, MODELLO WITH "Bici Elettrica City",  STATO WITH "D", TARIFFA WITH 8.50
      USE
   ENDIF

   IF !File("clienti.dbf")
      aClie := { {"ID_CLIE",  "N",  4, 0}, ;
                 {"NOME",     "C", 40, 0}, ;
                 {"TELEFONO", "C", 15, 0}, ;
                 {"DOC_ID",   "C", 15, 0} }
      DbCreate("clienti.dbf", aClie)
   ENDIF

   IF !File("noleggi.dbf")
      aNole := { {"ID_NOLEG", "N",  6, 0}, ;
                 {"ID_BICI",  "N",  4, 0}, ;
                 {"ID_CLIE",  "N",  4, 0}, ;
                 {"D_INIZIO", "D",  8, 0}, ;
                 {"O_INIZIO", "C",  8, 0}, ; // Formato HH:MM:SS
                 {"D_FINE",   "D",  8, 0}, ;
                 {"O_FINE",   "C",  8, 0}, ;
                 {"TOTALE",   "N",  7, 2} }
      DbCreate("noleggi.dbf", aNole)
   ENDIF
RETURN

// Sottomenu e inserimento anagrafica clienti
PROCEDURE GestioneClienti()
   LOCAL nId := 0, cNome := Space(40), cTel := Space(15), cDoc := Space(15)
   CLS
   @ 2, 2 SAY "=== NUOVO CLIENTE ANAGRAFICA ==="
   @ 4, 2 SAY "ID Cliente: " GET nId PICTURE "9999"
   @ 5, 2 SAY "Nome      : " GET cNome PICTURE "@!"
   @ 6, 2 SAY "Telefono  : " GET cTel
   @ 7, 2 SAY "Documento : " GET cDoc
   READ
   
   IF LastKey() == 27 ; RETURN ; ENDIF
   
   USE clienti EXCLUSIVE NEW
   APPEND BLANK
   REPLACE ID_CLIE WITH nId, NOME WITH cNome, TELEFONO WITH cTel, DOC_ID WITH cDoc
   USE
   @ 9, 2 SAY "Cliente registrato!"
   InKey(1.5)
RETURN

// Registrazione della partenza del noleggio
PROCEDURE AvviaNoleggio()
   LOCAL nIdBici := 0, nIdClie := 0, nNuovoId := 1
   CLS
   @ 2, 2 SAY "=== AVVIA NUOVO NOLEGGIO ==="
   @ 4, 2 SAY "Inserisci ID Bici   : " GET nIdBici PICTURE "9999"
   @ 5, 2 SAY "Inserisci ID Cliente: " GET nIdClie PICTURE "9999"
   READ
   
   // Verifica Cliente
   USE clienti SHARED NEW
   LOCATE FOR ID_CLIE == nIdClie
   IF !FOUND()
      @ 7, 2 SAY "Errore: Cliente non registrato in anagrafica!"
      USE; InKey(2); RETURN
   ENDIF
   USE

   // Verifica e blocca la Bici
   USE biciclette EXCLUSIVE NEW
   LOCATE FOR ID_BICI == nIdBici .AND. STATO == "D"
   IF !FOUND()
      @ 7, 2 SAY "Errore: Bici non disponibile o inesistente!"
      USE; InKey(2); RETURN
   ENDIF
   REPLACE STATO WITH "N"
   USE

   // Registra il movimento di noleggio
   USE noleggi EXCLUSIVE NEW
   IF LastRec() > 0
      GO BOTTOM
      nNuovoId := ID_NOLEG + 1
   ENDIF
   
   APPEND BLANK
   REPLACE ID_NOLEG WITH nNuovoId, ;
           ID_BICI  WITH nIdBici, ;
           ID_CLIE  WITH nIdClie, ;
           D_INIZIO WITH Date(), ;
           O_INIZIO WITH Time(), ;
           TOTALE   WITH 0.00
   USE
   
   @ 8, 2 SAY "Noleggio #" + LTrim(Str(nNuovoId)) + " avviato con successo!"
   InKey(2)
RETURN

// Rientro, calcolo del tempo e del totale dovuto
PROCEDURE RientroNoleggio()
   LOCAL nIdBici := 0, nOre := 0, nMinuti := 0, nTotaleOre := 0, nImporto := 0
   LOCAL tInizio, tFine, nDiffSecondi
   
   CLS
   @ 2, 2 SAY "=== RIENTRO BICICLETTA ==="
   @ 4, 2 SAY "Inserisci ID Bici rientrata: " GET nIdBici PICTURE "9999"
   READ
   
   // Trova il noleggio attivo per questa bici (senza data fine)
   USE noleggi EXCLUSIVE NEW
   LOCATE FOR ID_BICI == nIdBici .AND. Empty(D_FINE)
   
   IF !FOUND()
      @ 6, 2 SAY "Nessun noleggio attivo trovato per questa bicicletta."
      USE; InKey(2); RETURN
   ENDIF
   
   // Registra la fine del noleggio (Data e Ora correnti)
   REPLACE D_FINE WITH Date()
   REPLACE O_FINE WITH Time()
   
   // Calcolo del tempo trascorso (Conversione in ore totali)
   // Se il noleggio è nello stesso giorno o successivo, calcoliamo la differenza oraria
   nDiffSecondi := (D_FINE - D_INIZIO) * 86400 + ;
                   ( ElapSec( O_INIZIO, O_FINE ) )
   
   // Converti in ore (arrotondamento minimo a 1 ora se inferiore a 15 minuti, o calcolo effettivo)
   nTotaleOre := nDiffSecondi / 3600
   IF nTotaleOre < 0.25 
      nTotaleOre := 0.25 // Tariffa minima di 15 minuti
   ENDIF

   // Recupera la tariffa della bici per calcolare il totale
   USE biciclette EXCLUSIVE NEW
   LOCATE FOR ID_BICI == nIdBici
   IF FOUND()
      nImporto := nTotaleOre * TARIFFA
      REPLACE STATO WITH "D" // Rende nuovamente la bici disponibile
   ENDIF
   USE // Chiude biciclette
   
   // Salva il totale calcolato nel record del noleggio
   SELECT noleggi
   REPLACE TOTALE WITH nImporto
   
   // Mostra il riepilogo a schermo
   @ 7,  2 SAY "Noleggio Chiuso correttamente!"
   @ 9,  2 SAY "Tempo totale : " + Transform(nTotaleOre, "99.9") + " ore"
   @ 10, 2 SAY "Totale da Pagare: EUR " + Transform(nImporto, "9,999.00")
   USE // Chiude noleggi
   
   InKey(0)
RETURN
