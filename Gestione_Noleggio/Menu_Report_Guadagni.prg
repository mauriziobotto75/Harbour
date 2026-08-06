 
    PROCEDURE ReportGuadagni()
   LOCAL nIncassoTotale := 0.00
   LOCAL nNoleggiChiusi  := 0
   LOCAL nNoleggiAttivi  := 0
   LOCAL nTotaleOre      := 0
   LOCAL nDiffSecondi    := 0
   LOCAL dDataDal        := CToD("01/01/" + Str(Year(Date()), 4)) // Default 1° Gennaio anno corrente
   LOCAL dDataAl        := Date()
   
   CLS
   @ 2, 2 SAY "=== REPORT FINANZIARIO CON FILTRO DATA ==="
   @ 4, 2 SAY "Data Inizio (GG/MM/AAAA): " GET dDataDal
   @ 5, 2 SAY "Data Fine   (GG/MM/AAAA): " GET dDataAl
   READ
   
   IF LastKey() == 27 ; RETURN ; ENDIF
   
   IF !File("noleggi.dbf")
      @ 7, 2 SAY "Nessun dato di noleggio presente."
      InKey(2)
      RETURN
   ENDIF
   
   USE noleggi SHARED NEW
   
   CLS
   @ 2, 2 SAY "=== STATISTICHE DAL " + DToC(dDataDal) + " AL " + DToC(dDataAl) + " ==="
   
   DO WHILE !Eof()
      // Filtro sul periodo specificato
      IF D_INIZIO >= dDataDal .AND. D_INIZIO <= dDataAl
         IF !Empty(D_FINE)
            nIncassoTotale += TOTALE
            nNoleggiChiusi++
            nDiffSecondi := (D_FINE - D_INIZIO) * 86400 + ElapSec(O_INIZIO, O_FINE)
            nTotaleOre   += (nDiffSecondi / 3600)
         ELSE
            nNoleggiAttivi++
         ENDIF
      ENDIF
      DBSKIP()
   ENDDO
   USE
   
   @ 5,  2 SAY "----------------------------------------"
   @ 6,  2 SAY "Noleggi Completati       : " + Transform(nNoleggiChiusi, "9,999")
   @ 7,  2 SAY "Noleggi Attivi (In Corso): " + Transform(nNoleggiAttivi, "9,999")
   @ 8,  2 SAY "----------------------------------------"
   @ 10, 2 SAY "Ore Totali Noleggiate    : " + Transform(nTotaleOre, "99,999.0") + " ore"
   
   IF nNoleggiChiusi > 0
      @ 11, 2 SAY "Durata Media Noleggio    : " + Transform(nTotaleOre / nNoleggiChiusi, "99.9") + " ore"
   ELSE
      @ 11, 2 SAY "Durata Media Noleggio    : N/D"
   ENDIF
   
   @ 13, 2 SAY "----------------------------------------"
   @ 15, 2 SAY "INCASSO GENERATO NEL PERIODO: EUR " + Transform(nIncassoTotale, "999,999.00")
   @ 16, 2 SAY "----------------------------------------"
   
   @ MaxRow(), 2 SAY "Premi un tasto per tornare al menu..."
   InKey(0)
RETURN

RETURN
   CLOSE DATABASES
   
   @ 6, 2 SAY "Esportazione completata con successo!"
   @ 7, 2 SAY "File creato nella cartella del programma."
   InKey(2)
RETURN
