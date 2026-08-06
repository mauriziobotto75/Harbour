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
      @10, 12 SAY "7. Esporta file in formato CSV"
      @ 10, 12 SAY "8. Esci"
      @ 12, 12 SAY "Scelta: " GET nScelta PICTURE "9" RANGE 1, 8
      READ
      
      DO CASE
         CASE nScelta == 1 ; GestioneClienti()
         CASE nScelta == 2 ; CercaCliente()
         CASE nScelta == 3 ; AvviaNoleggio()
         CASE nScelta == 4 ; RientroNoleggio()
         CASE nScelta == 5 ; ReportGuadagni()
         CASE nScelta == 6 ; EsportaTesto()
         CASE nScelta == 7 ; EsportaCSV();
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
 PROCEDURE EsportaCSV()
   LOCAL cFileCSV := "noleggi_export.csv"
   LOCAL nHandle
   LOCAL cRiga := ""
   LOCAL cNomeCliente, cNomeBici
   
   CLS
   @ 2, 2 SAY "=== ESPORTAZIONE DATI IN FORMATO CSV ==="
   @ 4, 2 SAY "Generazione del file '" + cFileCSV + "' per Excel..."
   
   IF !File("noleggi.dbf")
      @ 6, 2 SAY "Errore: Nessun dato da esportare."
      InKey(2); RETURN
   ENDIF
   
   // Crea/Apre il file CSV a basso livello in scrittura
   nHandle := FCreate(cFileCSV)
   IF nHandle < 0
      @ 6, 2 SAY "Errore nella creazione del file CSV!"
      InKey(2); RETURN
   ENDIF
   
   // Scrittura della riga di intestazione (Header)
   cRiga := "ID_NOLEGGIO;CLIENTE;MODELLO_BICI;DATA_INIZIO;ORA_INIZIO;DATA_FINE;ORA_FINE;TOTALE_EUR" + Chr(13) + Chr(10)
   FWrite(nHandle, cRiga)
   
   // Apertura database con i relativi indici attivi
   USE noleggi SHARED NEW VIA "DBFCDX"
   USE clienti SHARED NEW VIA "DBFCDX" SET ORDER TO TAG id_clie
   USE biciclette SHARED NEW VIA "DBFCDX" SET ORDER TO TAG id_bici
   
   SELECT noleggi
   GO TOP
   
   DO WHILE !Eof()
      cNomeCliente := "Sconosciuto"
      cNomeBici    := "Sconosciuta"
      
      // Sfrutta gli indici (SEEK) per trovare all'istante i record correlati
      SELECT clienti
      SEEK noleggi->ID_CLIE
      IF FOUND()
         cNomeCliente := AllTrim(NOME)
      ENDIF
      
      SELECT biciclette
      SEEK noleggi->ID_BICI
      IF FOUND()
         cNomeBici := AllTrim(MODELLO)
      ENDIF
      
      SELECT noleggi
      
      // Costruzione della riga CSV formattata
      cRiga := AllTrim(Str(ID_NOLEG)) + ";" + ;
               '"' + cNomeCliente + '"' + ";" + ;
               '"' + cNomeBici + '"' + ";" + ;
               DToC(D_INIZIO) + ";" + ;
               O_INIZIO + ";" + ;
               IF(Empty(D_FINE), "", DToC(D_FINE)) + ";" + ;
               O_FINE + ";" + ;
               StrTran(Str(TOTALE, 7, 2), ".", ",") + ; // Sostituisce il punto con la virgola per Excel italiano
               Chr(13) + Chr(10)
               
      FWrite(nHandle, cRiga)
      DBSKIP()
   ENDDO
   
   // Chiude il file system e i database
   FClose(nHandle)
   CLOSE DATABASES
   
   @ 6, 2 SAY "Esportazione completata con successo!"
   @ 7, 2 SAY "File '" + cFileCSV + "' salvato sul disco."
   InKey(2)
RETURN
 


