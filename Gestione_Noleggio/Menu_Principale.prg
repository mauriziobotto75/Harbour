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
