PROCEDURE ReportGuadagni()
   LOCAL nIncassoTotale := 0.00
   LOCAL nNoleggiChiusi  := 0
   LOCAL nNoleggiAttivi  := 0
   LOCAL nTotaleOre      := 0
   LOCAL nDiffSecondi    := 0
   
   CLS
   @ 2, 2 SAY "=== REPORT FINANZIARIO E GUADAGNI ==="
   
   IF !File("noleggi.dbf")
      @ 4, 2 SAY "Nessun dato di noleggio presente."
      InKey(2)
      RETURN
   ENDIF
   
   USE noleggi SHARED NEW
   
   // Scansione completa del database noleggi
   DO WHILE !Eof()
      IF !Empty(D_FINE)
         // Noleggio concluso: accumula incasso e calcola i tempi
         nIncassoTotale += TOTALE
         nNoleggiChiusi++
         
         // Calcolo ore totali accumulate (stessa logica della chiusura)
         nDiffSecondi := (D_FINE - D_INIZIO) * 86400 + ElapSec(O_INIZIO, O_FINE)
         nTotaleOre   += (nDiffSecondi / 3600)
      ELSE
         // Noleggio ancora in corso
         nNoleggiAttivi++
      ENDIF
      DBSKIP()
   ENDDO
   USE
   
   // Visualizzazione del Report a schermo
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
   @ 15, 2 SAY "INCASSO TOTALE GENERATO  : EUR " + Transform(nIncassoTotale, "999,999.00")
   @ 16, 2 SAY "----------------------------------------"
   
   @ MaxRow(), 2 SAY "Premi un tasto per tornare al menu..."
   InKey(0)
RETURN
