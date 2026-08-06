 PROCEDURE Main()
 
   PROCEDURE MenuPrincipale()
   LOCAL nScelta := 0
   
   DO WHILE nScelta # 7
      CLS
      @ 2, 10 SAY "=== GESTIONE NOLEGGIO BICI AVANZATO ==="
      @ 4, 12 SAY "1. Gestione Clienti (Inserimento)"
      @ 5, 12 SAY "2. Cerca Cliente (Testuale)"
      @ 6, 12 SAY "3. Avvia Nuovo Noleggio"
      @ 7, 12 SAY "4. Rientro Bici e Calcolo Totale"
      @ 8, 12 SAY "5. Report Guadagni con Filtro Date"
      @ 9, 12 SAY "6. Esporta Noleggi in File di Testo (.txt)"
      @ 10, 12 SAY "7. Esci"
      @ 12, 12 SAY "Scelta: " GET nScelta PICTURE "9" RANGE 1, 7
      READ
      
      DO CASE
         CASE nScelta == 1 ; GestioneClienti()
         CASE nScelta == 2 ; CercaCliente()
         CASE nScelta == 3 ; AvviaNoleggio()
         CASE nScelta == 4 ; RientroNoleggio()
         CASE nScelta == 5 ; ReportGuadagni()
         CASE nScelta == 6 ; EsportaTesto()
      ENDCASE
   ENDDO
RETURN
LOCAL nScelta := 0
   
   DO WHILE nScelta # 6
      CLS
      @ 2, 10 SAY "=== GESTIONE NOLEGGIO BICI AVANZATO ==="
      @ 4, 12 SAY "1. Gestione Clienti (Inserimento)"
      @ 5, 12 SAY "2. Cerca Cliente (Testuale)"
      @ 6, 12 SAY "3. Avvia Nuovo Noleggio"
      @ 7, 12 SAY "4. Rientro Bici e Calcolo Totale"
      @ 8, 12 SAY "5. Report Guadagni e Statistiche"
      @ 9, 12 SAY "6. Esci"
      @ 11, 12 SAY "Scelta: " GET nScelta PICTURE "9" RANGE 1, 6
      READ
      
      DO CASE
         CASE nScelta == 1 ; GestioneClienti()
         CASE nScelta == 2 ; CercaCliente()
         CASE nScelta == 3 ; AvviaNoleggio()
         CASE nScelta == 4 ; RientroNoleggio()
         CASE nScelta == 5 ; ReportGuadagni()
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

