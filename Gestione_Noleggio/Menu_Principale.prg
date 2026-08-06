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

PROCEDURE ListBici()
   CLS
   USE biciclette SHARED NEW
   @ 2, 2 SAY "ID  | MODELLO                      | STATO"
   @ 3, 2 SAY "----------------------------------------"
   DO WHILE !Eof()
      @ Row()+1, 2 SAY Str(ID_BICI, 4) + " | " + PadR(MODELLO, 30) + " | " + STATO
      DBSKIP()
   ENDDO
   USE
   @ MaxRow(), 2 SAY "Premi un tasto per continuare..."
   InKey(0)
RETURN

PROCEDURE RegistraNoleggio()
   LOCAL nIdBici := 0
   CLS
   @ 2, 2 SAY "--- REGISTRAZIONE NOLEGGIO ---"
   @ 4, 2 SAY "Inserisci ID Bici da noleggiare: " GET nIdBici PICTURE "9999"
   READ
   
   USE biciclette EXCLUSIVE NEW
   LOCATE FOR ID_BICI == nIdBici .AND. STATO == "D"
   IF FOUND()
      REPLACE STATO WITH "N"
      @ 6, 2 SAY "Noleggio registrato con successo per la bici ID: " + LTrim(Str(nIdBici))
   ELSE
      @ 6, 2 SAY "Bici non trovata o gia' noleggiata!"
   ENDIF
   USE
   InKey(2)
RETURN

