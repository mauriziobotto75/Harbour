PROCEDURE EsportaTesto()
   LOCAL cFileOut := "report_noleggi.txt"
   
   CLS
   @ 2, 2 SAY "=== ESPORTAZIONE DATI IN FORMATO TESTO ==="
   @ 4, 2 SAY "Generazione del file '" + cFileOut + "' in corso..."
   
   IF !File("noleggi.dbf")
      @ 6, 2 SAY "Errore: Nessun dato da esportare."
      InKey(2)
      RETURN
   ENDIF
   
   // Apre i database necessari per leggere anche i dettagli di bici e clienti
   USE noleggi SHARED NEW
   USE clienti SHARED VIA "DBFCDX" NEW
   USE biciclette SHARED VIA "DBFCDX" NEW
   
   SELECT noleggi
   
   // Redireziona l'output dello schermo (i comandi ? o QOUT) all'interno del file di testo
   SET ALTERNATE TO (cFileOut)
   SET ALTERNATE ON
   
   // Scrittura intestazione del file di testo
   ? "=========================================================================================="
   ? "                      RELAZIONE COMPLETA MOVIMENTI NOLEGGIO BICICLETTE                   "
   ? "                      Generato in data: " + DToC(Date()) + " alle ore: " + Time()
   ? "=========================================================================================="
   ? PadR("ID NOL", 8) + " | " + PadR("CLIENTE", 25) + " | " + PadR("BICI MODELLO", 20) + " | " + PadR("DATA INIZ", 10) + " | " + PadR("DATA FINE", 10) + " | " + PadL("TOTALE", 10)
   ? "------------------------------------------------------------------------------------------"
   
   DO WHILE !Eof()
      LOCAL cNomeCliente := "Non trovato"
      LOCAL cNomeBici    := "Non trovata"
      
      // Recupera il nome del cliente
      SELECT clienti
      LOCATE FOR ID_CLIE == noleggi->ID_CLIE
      IF FOUND()
         cNomeCliente := Trim(NOME)
      ENDIF
      
      // Recupera il modello della bici
      SELECT biciclette
      LOCATE FOR ID_BICI == noleggi->ID_BICI
      IF FOUND()
         cNomeBici := Trim(MODELLO)
      ENDIF
      
      // Torna sul file noleggi per scrivere la riga nel report
      SELECT noleggi
      
      ? PadR(LTrim(Str(ID_NOLEG)), 8) + " | " + ;
        PadR(cNomeCliente, 25) + " | " + ;
        PadR(cNomeBici, 20) + " | " + ;
        DToC(D_INIZIO) + " | " + ;
        IF(Empty(D_FINE), "IN CORSO  ", DToC(D_FINE)) + " | " + ;
        PadL(Transform(TOTALE, "9,999.00"), 10)
        
      DBSKIP()
   ENDDO
   
   ? "------------------------------------------------------------------------------------------"
   ? "=================================== FINE DEL REPORT ======================================"
   
   // Chiude la scrittura del file di testo e ripristina l'output standard
   SET ALTERNATE OFF
   SET ALTERNATE TO
   
