REQUEST DBFCDX

PROCEDURE Main()
   LOCAL nScelta := 0
   RddSetDefault( "DBFCDX" )
   SET DATE FORMAT TO "DD/MM/YYYY"
   SET CENTURY ON
   CLS
   
   // Crea i file se non esistono
  PROCEDURE InizializzaDatabase()
   LOCAL aBici, aClie, aNole
   
     IF !File("noleggi.dbf")
      aNole := { {"ID_NOLEG", "N",  6, 0}, ;
                 {"ID_BICI",  "N",  4, 0}, ;
                 {"ID_CLIE",  "N",  4, 0}, ;
                 {"D_INIZIO", "D",  8, 0}, ;
                 {"O_INIZIO", "C",  8, 0}, ;
                 {"ORE_MAX",  "N",  3, 0}, ; // <-- NUOVO: Limite massimo ore concordate
                 {"CAUZIONE", "N",  6, 2}, ;
                 {"ANTICIPO", "N",  6, 2}, ;
                 {"D_FINE",   "D",  8, 0}, ;
                 {"O_FINE",   "C",  8, 0}, ;
                 {"TOTALE",   "N",  7, 2}, ; // Costo effettivo tempo standard
                 {"PENALE",   "N",  6, 2}, ; // <-- NUOVO: Importo penale per ritardo
                 {"SALDO",    "N",  7, 2} }
      DbCreate("noleggi.dbf", aNole)
   ENDIF



   // 2. ARCHIVIO CLIENTI
   IF !File("clienti.dbf")
      aClie := { {"ID_CLIE",  "N",  4, 0}, ;
                 {"NOME",     "C", 40, 0}, ;
                 {"TELEFONO", "C", 15, 0}, ;
                 {"DOC_ID",   "C", 15, 0} }
      DbCreate("clienti.dbf", aClie)
   ENDIF
   // Controllo e generazione indice Clienti
   IF !File("clienti.cdx")
      USE clienti EXCLUSIVE
      INDEX ON ID_CLIE TAG id_clie         // Ricerca rapida per ID
      INDEX ON NOME    TAG nome            // Ottimizza le ricerche alfabetiche
      USE
   ENDIF

   // 3. ARCHIVIO NOLEGGI
   IF !File("noleggi.dbf")
      aNole := { {"ID_NOLEG", "N",  6, 0}, ;
                 {"ID_BICI",  "N",  4, 0}, ;
                 {"ID_CLIE",  "N",  4, 0}, ;
                 {"D_INIZIO", "D",  8, 0}, ;
                 {"O_INIZIO", "C",  8, 0}, ;
                 {"D_FINE",   "D",  8, 0}, ;
                 {"O_FINE",   "C",  8, 0}, ;
                 {"TOTALE",   "N",  7, 2} }
      DbCreate("noleggi.dbf", aNole)
   ENDIF
   // Controllo e generazione indice Noleggi
   IF !File("noleggi.cdx")
      USE noleggi EXCLUSIVE
      INDEX ON ID_NOLEG  TAG id_noleg      // ID Noleggio
      INDEX ON ID_BICI   TAG id_bici       // Trova i noleggi di una bici
      INDEX ON D_INIZIO  TAG d_inizio      // Ordinamento cronologico
      USE
   ENDIF
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
   LOCAL nCauzione := 0.00, nAnticipo := 0.00, nOreMax := 5 // Default 5 ore max
   CLS
   @ 2, 2 SAY "=== AVVIA NUOVO NOLEGGIO CON LIMITI DI TEMPO ==="
   @ 4, 2 SAY "Inserisci ID Bici      : " GET nIdBici PICTURE "9999"
   @ 5, 2 SAY "Inserisci ID Cliente   : " GET nIdClie PICTURE "9999"
   @ 6, 2 SAY "Limite Max Ore Concesse: " GET nOreMax PICTURE "99" RANGE 1, 99
   @ 8, 2 SAY "Cauzione Richiesta EUR : " GET nCauzione PICTURE "999.00"
   @ 9, 2 SAY "Pagamento Anticipato € : " GET nAnticipo PICTURE "999.00"
   READ
   
   IF LastKey() == 27 ; RETURN ; ENDIF

   USE clienti SHARED NEW VIA "DBFCDX" SET ORDER TO TAG id_clie
   SEEK nIdClie
   IF !FOUND()
      @ 11, 2 SAY "Errore: Cliente non registrato!"
      USE; InKey(2); RETURN
   ENDIF
   USE

   USE biciclette EXCLUSIVE NEW VIA "DBFCDX" SET ORDER TO TAG id_bici
   SEEK nIdBici
   IF !FOUND() .OR. STATO != "D"
      @ 11, 2 SAY "Errore: Bici non disponibile!"
      USE; InKey(2); RETURN
   ENDIF
   REPLACE STATO WITH "N"
   USE

   USE noleggi EXCLUSIVE NEW VIA "DBFCDX"
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
           ORE_MAX  WITH nOreMax, ; // Salva il limite pattuito
           CAUZIONE WITH nCauzione, ;
           ANTICIPO WITH nAnticipo, ;
           TOTALE   WITH 0.00, ;
           PENALE   WITH 0.00, ;
           SALDO    WITH 0.00
   USE
   
   @ 12, 2 SAY "Noleggio #" + LTrim(Str(nNuovoId)) + " avviato. Limite: " + Str(nOreMax,2) + " ore."
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
// Funzione ausiliaria per calcolare i secondi tra due orari (formato HH:MM:SS)
STATIC FUNCTION ElapSec( cTimeStart, cTimeEnd )
   LOCAL nSecStart := Val(SubStr(cTimeStart,1,2))*3600 + Val(SubStr(cTimeStart,4,2))*60 + Val(SubStr(cTimeStart,7,2))
   LOCAL nSecEnd   := Val(SubStr(cTimeEnd,1,2))*3600   + Val(SubStr(cTimeEnd,4,2))*60   + Val(SubStr(cTimeEnd,7,2))
RETURN nSecEnd - nSecStart
