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
         cRiga := AllTrim(Str(ID_NOLEG)) + ";" + ;
               '"' + cNomeCliente + '"' + ";" + ;
               '"' + cNomeBici + '"' + ";" + ;
               DToC(D_INIZIO) + ";" + ;
               O_INIZIO + ";" + ;
               Transform(CAUZIONE, "999.00") + ";" + ; // <-- Aggiunto nel CSV
               Transform(ANTICIPO, "999.00") + ";" + ; // <-- Aggiunto nel CSV
               IF(Empty(D_FINE), "", DToC(D_FINE)) + ";" + ;
               O_FINE + ";" + ;
               StrTran(Str(TOTALE, 7, 2), ".", ",") + ";" + ;
               StrTran(Str(SALDO, 7, 2), ".", ",") + ;  // <-- Aggiunto nel CSV
               Chr(13) + Chr(10)

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
 PROCEDURE RientroNoleggio()
   LOCAL nIdBici := 0, nTotaleOre := 0, nImportoTempo := 0, nSaldoFinale := 0
   LOCAL nDiffSecondi := 0
   LOCAL nTariffaBici := 0
   
   CLS
   @ 2, 2 SAY "=== RIENTRO BICICLETTA E CONTEGGIO CASSA ==="
   @ 4, 2 SAY "Inserisci ID Bici rientrata: " GET nIdBici PICTURE "9999"
   READ
   
   IF LastKey() == 27 ; RETURN ; ENDIF
   
   // Trova il noleggio attivo usando l'apposito indice per ID Bici
   USE noleggi EXCLUSIVE NEW VIA "DBFCDX" SET ORDER TO TAG id_bici
   SEEK nIdBici
   
   // Scorre nel caso ci fossero vecchi noleggi chiusi per quella bici, cerca quello attivo (senza data fine)
   DO WHILE FOUND() .AND. !Empty(D_FINE)
      CONTINUE
   ENDDO
   
   IF !FOUND() .OR. !Empty(D_FINE)
      @ 6, 2 SAY "Nessun noleggio attivo trovato per questa bicicletta."
      USE; InKey(2); RETURN
   ENDIF
   
   // Chiude temporaneamente i tempi
   REPLACE D_FINE WITH Date()
   REPLACE O_FINE WITH Time()
   
   // Calcolo ore totali trascorse
   nDiffSecondi := (D_FINE - D_INIZIO) * 86400 + ( ElapSec( O_INIZIO, O_FINE ) )
   nTotaleOre   := nDiffSecondi / 3600
   IF nTotaleOre < 0.25 
      nTotaleOre := 0.25 
   ENDIF

   // Recupera la tariffa oraria della bici
   USE biciclette EXCLUSIVE NEW VIA "DBFCDX" SET ORDER TO TAG id_bici
   SEEK nIdBici
   IF FOUND()
      nTariffaBici := TARIFFA
      REPLACE STATO WITH "D" // Libera la bici
   ENDIF
   USE
   
   // Torna sul record del noleggio per salvare i calcoli economici finali
   SELECT noleggi
   nImportoTempo := nTotaleOre * nTariffaBici
   
   // Calcolo del Saldo Finale al netto dell'anticipo già versato alla partenza
   nSaldoFinale  := nImportoTempo - ANTICIPO
   
   REPLACE TOTALE WITH nImportoTempo
   REPLACE SALDO  WITH nSaldoFinale
   
   // Visualizzazione della ricevuta di chiusura
   CLS
   @ 2,  2 SAY "=== RICEVUTA CHIUSURA NOLEGGIO ==="
   @ 4,  2 SAY "Tempo totale di utilizzo  : " + Transform(nTotaleOre, "99.9") + " ore"
   @ 5,  2 SAY "Costo totale del servizio : EUR " + Transform(nImportoTempo, "9,999.00")
   @ 6,  2 SAY "--------------------------------------------------"
   @ 7,  2 SAY "Anticipo gia' versato     : EUR " + Transform(ANTICIPO, "9,999.00")
   
   IF nSaldoFinale > 0
      @ 9,  2 SAY "DA INCASSARE DAL CLIENTE  : EUR " + Transform(nSaldoFinale, "9,999.00")
   ELSEIF nSaldoFinale < 0
      @ 9,  2 SAY "DA RIMBORSARE AL CLIENTE  : EUR " + Transform(Abs(nSaldoFinale), "9,999.00")
   ELSE
      @ 9,  2 SAY "SALDO CORRETTO            : EUR 0.00 (Nessun pagamento dovuto)"
   ENDIF
   
   @ 11, 2 SAY "--------------------------------------------------"
   @ 12, 2 SAY "[!] DA RESTITUIRE ADESSO   : CAUZIONE DI EUR " + Transform(CAUZIONE, "999.00")
   @ 13, 2 SAY "--------------------------------------------------"
   
   USE // Chiude e salva noleggi
   @ MaxRow(), 2 SAY "Premi un tasto per confermare la transazione..."
   InKey(0)
RETURN



