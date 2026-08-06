PROCEDURE CercaCliente()
   LOCAL cChiave := Space(40)
   LOCAL nTrovati := 0
   
   CLS
   @ 2, 2 SAY "=== RICERCA TESTUALE CLIENTE ==="
   @ 4, 2 SAY "Inserisci parte del cognome/nome: " GET cChiave PICTURE "@!"
   READ
   
   IF LastKey() == 27 .OR. Empty(cChiave) ; RETURN ; ENDIF
   
   cChiave := Trim(cChiave)
   USE clienti SHARED NEW
   
   CLS
   @ 2, 2 SAY "=== RISULTATI DELLA RICERCA ==="
   @ 4, 2 SAY "ID   | NOME CLIENTE                             | TELEFONO"
   @ 5, 2 SAY "--------------------------------------------------------"
   
   DO WHILE !Eof()
      // Verifica se la stringa cercata è contenuta nel nome
      IF cChiave $ NOME
         @ Row()+1, 2 SAY Str(ID_CLIE, 4) + " | " + PadR(NOME, 40) + " | " + TELEFONO
         nTrovati++
      ENDIF
      DBSKIP()
   ENDDO
   
   IF nTrovati == 0
      @ 7, 2 SAY "Nessun cliente trovato con questo nome."
   ELSE
      @ Row()+2, 2 SAY "Totale clienti trovati: " + LTrim(Str(nTrovati))
   ENDIF
   
   USE
   @ MaxRow(), 2 SAY "Premi un tasto per tornare al menu..."
   InKey(0)
RETURN
