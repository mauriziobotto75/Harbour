*****
* Version    : MYTETRIS 1.0
* Compilation: /n /w
* Description: Tetris Game
* Information: Questions? My CIS-ID: 100604,1637 Phil
*****

#include 'box.ch'
#include 'inkey.ch'
#include 'setcurs.ch'

#define WIN_UP                  2
#define WIN_LEFT                17
#define BD_HEIGHT               20            // 18
#define BD_WIDTH                20
#define ST_WIDTH                23
#define N_ROW_TEXT              WIN_UP + 2
#define N_COL_TEXT              WIN_LEFT + BD_WIDTH + 3
#define N_COL_SCORE             N_COL_TEXT + 12
#define N_LEN_DISP              ST_WIDTH - 13
#define N_NEXT_BLOCK_ROW        WIN_UP + 8

// aEnv
#define ENV_SCREEN              1
#define ENV_CURSOR              2
#define ENV_COLOR               3
#define ENV_ROW                 4
#define ENV_COL                 5

// a_status
#define ST_ROW                  1
#define ST_TEXT                 2
#define ST_COLOR                3
#define ST_CBLOCK               4

// aCargo
#define CG_N_GAME               1
#define CG_N_HIGH_SCORE         2
#define CG_N_INIT_SCORE         3
#define CG_N_SCORE              4
#define CG_N_COUNT_LINES        5
#define CG_N_COUNT_BLOCKS       6
#define CG_N_LEVEL              7
#define CG_N_CUR_WAIT           8
#define CG_N_CUR_BLOCK          9
#define CG_N_NEXT_BLOCK         10
#define CG_N_BLOCK_SIZE         11
#define CG_N_BLOCK_ROW          12
#define CG_N_BLOCK_COL          13
#define CG_N_RANDOM             14
#define CG_N_INIT_TIK           15
#define CG_N_MAX_BLOCKS         16
#define LEN_A_CARGO             16      // size

// CG_N_GAME
#define N_GAME_OVER             1
#define N_PLAYING               2
#define N_PAUSED                3
#define A_C_STATUS              {'Terminado', 'En juego', 'en pausa'}
*                                 123456789    12345678    12345678
// Misc.
#define N_MIN_LEVEL             1
#define N_INIT_MAX_BLOCKS       7
#define N_LEVEL_ADD_BLOCKS      3
#define N_PT_PER_BLOCK          1
#define N_PT_PER_LINE           5
#define N_BLOCKS_PER_LEVEL      25
#define N_INIT_WAIT             1100
#define N_TIME_PER_LEVEL        100
#define C_ELEMENT               "ÛÛ"
#define N_EMPTY                 0
#define N_BORDURE               -1
#define C_MASK                  replicate("±q", 9)      // 177+113

#define C_BOARD_CLR             'N'
#define C_FILE_NAME             'MYTETRIS.INI'
#define NPADL(nVal)             padr(ntrim(nVal), N_LEN_DISP)

*
function main()
*------------
setmode(28,80)
return mytetris()

*
function MyTetris()
*----------------
local nKey
local wHK
local lLoop := .T.
local lAllDrop := .F.
local aEnv := Make_Env_Win()
local aBlocks, aBoard, aColor, aCargo, aCurBlock

wHK := lastkey()
if wHK = 0
   wHK := 9999  // un valor imposible
endif

Create_Vars(@aBlocks, @aBoard, @aColor, @aCargo)

while lLoop

      nKey := inkey(0.01, INKEY_KEYBOARD)

      dispbegin()
      DO CASE
         CASE nKey = K_ESC .or. nKey = wHK
              lLoop := .F.

         CASE nKey = K_ENTER
              Init_Game(aBlocks, aBoard, @aCurBlock, aCargo)
              Draw_Block(aCurBlock, aColor, aCargo, .T.)

         CASE aCargo[CG_N_GAME] # N_GAME_OVER
              DO CASE
                 CASE aCargo[CG_N_GAME] = N_PAUSED .AND. nKey # 0
                      aCargo[CG_N_GAME] := N_PLAYING

                 CASE nKey = K_SPACE
                      aCargo[CG_N_GAME] := N_PAUSED

                 CASE nKey = K_UP	// giros
                      Draw_Block(aCurBlock, aColor, aCargo, .F.)
                      Rotate_Block(@aCurBlock, aCargo, K_LEFT)  // a izq.
                      IF Hit_Block(aBoard, aCurBlock, aCargo)	// si hay colision lo deja como estaba
                         Rotate_Block(@aCurBlock, aCargo, K_RIGHT) 
                      ENDIF
                      Draw_Block(aCurBlock, aColor, aCargo, .T.)

                 CASE nKey = K_LEFT .OR. nKey = K_RIGHT		// mov. horizontal
                      Draw_Block(aCurBlock, aColor, aCargo, .F.)
                      aCargo[CG_N_BLOCK_COL] += IF(nKey = K_LEFT, -2, 2)
                      IF Hit_Block(aBoard, aCurBlock, aCargo)
                         aCargo[CG_N_BLOCK_COL] += IF(nKey = K_LEFT, 2, -2)
                      ENDIF
                      Draw_Block(aCurBlock, aColor, aCargo, .T.)

                 CASE nKey = K_DOWN	// caida
                      lAllDrop := .T.
              ENDCASE
      ENDCASE

      IF aCargo[CG_N_GAME] = N_PLAYING
         IF lAllDrop .OR. Tic_Tac(aCargo[CG_N_CUR_WAIT], aCargo[CG_N_INIT_TIK])
            Draw_Block(aCurBlock, aColor, aCargo, .F.)
            aCargo[CG_N_BLOCK_ROW]++
            IF Hit_Block(aBoard, aCurBlock, aCargo)
               aCargo[CG_N_BLOCK_ROW]--
               Draw_Block(aCurBlock, aColor, aCargo, .T.)
               Place_Block(aBlocks, aBoard, @aCurBlock, aColor, aCargo)
               lAllDrop := .F.
            ENDIF
            Draw_Block(aCurBlock, aColor, aCargo, .T.)
            aCargo[CG_N_INIT_TIK] := seconds()
         ENDIF
      ENDIF

      Disp_Score(aBlocks, aColor, aCargo)
      dispend()
ENDDO

Rest_Env(aEnv, aCargo)

return nil

*
* funciones de soporte
*

*
STATIC FUNCTION MAKE_ENV_WIN()
*---------------------------
local aEnv := ARRAY(5)

dispbegin()

aEnv[ENV_SCREEN] := SAVESCREEN (0, 0, MAXROW(), MAXCOL())
aEnv[ENV_CURSOR] := SETCURSOR(SC_NONE)
aEnv[ENV_COLOR]  := SETCOLOR("GR+/W")
aEnv[ENV_ROW]    := ROW()
aEnv[ENV_COL]    := COL()

@ 0, 0 SAY PADC("Tetris V5.20 - "+ ntrim(year(date())), MAXCOL() + 1)

@ MAXROW(), 0 SAY PADC("<Esc>: Fin  <Enter>: Nuevo  <Sp>: Pausa  "+ ;
                       CHR(30) +": Rotar  "+ ;
                       CHR(17) +"/"+ CHR(16) +": Mover  "+ ;
                       CHR(31) +": Bajar", MAXCOL() + 1)

RESTSCREEN(1, 0, MAXROW() - 1, MAXCOL(), ;
           REPLICATE(C_MASK, ((MAXCOL() + 1) * (MAXROW() - 1)) / 2))

SETCOLOR("BG/"+ C_BOARD_CLR)

shadow(WIN_UP + 1, ;
       WIN_LEFT + 1, ;
       WIN_UP + BD_HEIGHT + 2, ;
       WIN_LEFT + BD_WIDTH + ST_WIDTH + 3)
@ WIN_UP, WIN_LEFT, WIN_UP + BD_HEIGHT + 1, ;
  WIN_LEFT + BD_WIDTH + ST_WIDTH + 2 BOX B_SINGLE +" "

@ WIN_UP, WIN_LEFT, WIN_UP + BD_HEIGHT + 1, WIN_LEFT + BD_WIDTH + 1 BOX B_SINGLE
@ WIN_UP, WIN_LEFT + BD_WIDTH + 1 SAY "Â"
@ WIN_UP + BD_HEIGHT + 1, WIN_LEFT + BD_WIDTH + 1 SAY "Á"

SETCOLOR("W+/"+ C_BOARD_CLR)
AEVAL(A_STATUS(), {|as| SETPOS(N_ROW_TEXT + as[ST_ROW], N_COL_TEXT), QQOUT(as[ST_TEXT])})
@ N_NEXT_BLOCK_ROW, N_COL_TEXT SAY "Siguiente:"

dispend()

return aEnv

*
STATIC FUNCTION REST_ENV(aEnv, aCargo)
*-----------------------

IF aCargo[CG_N_INIT_SCORE] < aCargo[CG_N_HIGH_SCORE]
   hb_memowrit(curdir() + C_FILE_NAME, NTRIM(aCargo[CG_N_HIGH_SCORE]), .F.)
ENDIF

RESTSCREEN(0, 0, MAXROW(), MAXCOL(), aEnv[ENV_SCREEN])
SETCURSOR(aEnv[ENV_CURSOR])
SETCOLOR(aEnv[ENV_COLOR])
SETPOS(aEnv[ENV_ROW], aEnv[ENV_COL])

return nil

*
STATIC FUNCTION Create_Vars(aBlocks, aBoard, aColor, aCargo)
*-------------------------- @        @       @       @
local wIniFile := curdir() + C_FILE_NAME

// crea los bloques               forma 
aBlocks := {{.F.,.T.,.F.,.F.,;  /* oÛoo */
             .F.,.T.,.F.,.F.,;  /* oÛoo */
             .F.,.T.,.F.,.F.,;  /* oÛoo */
             .F.,.T.,.F.,.F.},; /* oÛoo */
            ;
            {.F.,.T.,.T.,;      /* oÛÛ  */
             .F.,.T.,.F.,;      /* oÛo  */
             .F.,.T.,.F.},;     /* oÛo  */
            ;
            {.T.,.T.,.F.,;      /* ÛÛo  */
             .F.,.T.,.F.,;      /* oÛo  */
             .F.,.T.,.F.},;     /* oÛo  */
            ;
            {.F.,.T.,.F.,;      /* oÛo  */
             .T.,.T.,.T.,;      /* ÛÛÛ  */
             .F.,.F.,.F.},;     /* ooo  */
            ;
            {.T.,.T.,.F.,;      /* ÛÛo  */
             .F.,.T.,.T.,;      /* oÛÛ  */
             .F.,.F.,.F.},;     /* ooo  */
            ;
            {.F.,.T.,.T.,;      /* oÛÛ  */
             .T.,.T.,.F.,;      /* ÛÛo  */
             .F.,.F.,.F.},;     /* ooo  */
            ;
            {.T.,.T.,.F.,;      /* ÛÛo  */
             .T.,.T.,.F.,;      /* ÛÛo  */
             .F.,.F.,.F.},;     /* ooo  */
            ;
            {.F.,.T.,.T.,;      /* oÛÛ  */
             .F.,.T.,.F.,;      /* oÛo  */
             .F.,.T.,.T.},;     /* oÛÛ  */
            ;
            {.F.,.T.,.T.,;      /* oÛÛ  */
             .F.,.T.,.F.,;      /* oÛo  */
             .T.,.T.,.F.},;     /* ÛÛo  */
            ;
            {.F.,.T.,.T.,;      /* oÛÛ  */
             .F.,.T.,.T.,;      /* oÛÛ  */
             .F.,.T.,.F.},;     /* oÛo  */
            ;
            {.F.,.T.,.F.,;      /* oÛo  */
             .F.,.T.,.F.,;      /* oÛo  */
             .F.,.T.,.F.},;     /* oÛo  */
            ;
            {.T.,.T.,.F.,;      /* ÛÛo  */
             .F.,.T.,.T.,;      /* oÛÛ  */
             .F.,.F.,.T.},;     /* ooÛ  */
            ;
            {.F.,.T.,.F.,;      /* oÛo  */
             .F.,.T.,.F.,;      /* oÛo  */
             .T.,.T.,.T.},;     /* ÛÛÛ  */
            ;
            {.F.,.T.,.F.,;      /* oÛo  */
             .T.,.T.,.F.,;      /* ÛÛo  */
             .F.,.T.,.T.}}      /* oÛÛ  */

aColor := {"W+", "G+", "GR+", "R+", "BG+", "B+", "RB+", "RB", "B", "BG", "R", "GR", "G", "B"}
aBoard := ARRAY(BD_HEIGHT + 1, BD_WIDTH + 3)
aCargo := ARRAY(LEN_A_CARGO)
aCargo[CG_N_GAME]     := N_GAME_OVER
aCargo[CG_N_RANDOM]   := int(seconds() * 1000)
aCargo[CG_N_CUR_WAIT] := N_INIT_WAIT

Init_Score(aCargo)

aCargo[CG_N_INIT_SCORE] := aCargo[CG_N_HIGH_SCORE] := 0
IF FILE(wIniFile)
   aCargo[CG_N_HIGH_SCORE] := val(memoread(wIniFile))
ENDIF

return nil

*
STATIC FUNCTION DISP_SCORE(aBlocks, aColor, aCargo)
*-------------------------

AEVAL(A_STATUS(), {|as| SETCOLOR(as[ST_COLOR]+C_BOARD_CLR), ;
                        SETPOS(N_ROW_TEXT + as[ST_ROW], N_COL_SCORE), ;
                        QQOUT(EVAL(as[ST_CBLOCK], aCargo))})

IF aCargo[CG_N_LEVEL] >= N_LEVEL_ADD_BLOCKS
   Draw_Next_Block(aBlocks, aColor, aCargo)
ENDIF

return nil

*
STATIC FUNCTION INIT_SCORE(aCargo)
*-------------------------

aCargo[CG_N_SCORE]        := 0
aCargo[CG_N_COUNT_LINES]  := 0
aCargo[CG_N_COUNT_BLOCKS] := 0
aCargo[CG_N_LEVEL]        := N_MIN_LEVEL

return nil

*
STATIC FUNCTION RANDOM_BLOCK(aCargo, nMax)
*---------------------------

#define IA  421
#define IC  1663
#define IM  7875

aCargo[CG_N_RANDOM] := (aCargo[CG_N_RANDOM] * IA + IC) % IM

return INT((aCargo[CG_N_RANDOM] / IM) * nMax) + 1

*
STATIC FUNCTION TIC_TAC(nXms, nTop)
*----------------------
LOCAL nTic, nTac, nElapsed

nTac     := INT((nXms / 55) + IF(nXms % 55 > 0, 1, 0))
nElapsed := INT((seconds() - nTop) * 1000)
nTic     := INT((IF(nElapsed < 0, nElapsed += 86400000, nElapsed) / 55) + IF (nElapsed % 55 > 0, 1, 0))

return (nTic >= nTac)

*
STATIC FUNCTION INIT_GAME(aBlocks, aBoard, aCurBlock, aCargo)
*------------------------                  @
LOCAL i, j

@ WIN_UP + 1, WIN_LEFT + 1 CLEAR TO WIN_UP + BD_HEIGHT, WIN_LEFT + BD_WIDTH

FOR i := 1 TO BD_HEIGHT
    FOR j := 2 TO BD_WIDTH + 1
        aBoard[i,j] := N_EMPTY
    NEXT
    aBoard[i,1] := aBoard[i,BD_WIDTH+2] := aBoard[i,BD_WIDTH+3] := N_BORDURE
NEXT
AFILL(aBoard[i], N_BORDURE)

aCargo[CG_N_GAME]       := N_PLAYING
aCargo[CG_N_CUR_WAIT]   := N_INIT_WAIT
aCargo[CG_N_MAX_BLOCKS] := N_INIT_MAX_BLOCKS
aCargo[CG_N_NEXT_BLOCK] := Random_Block(aCargo, aCargo[CG_N_MAX_BLOCKS])

Init_Score(aCargo)
@ N_NEXT_BLOCK_ROW, N_COL_SCORE CLEAR TO ;
  N_NEXT_BLOCK_ROW + 3, N_COL_SCORE + 7
New_Block(aBlocks, aBoard, @aCurBlock, aCargo)

aCargo[CG_N_INIT_TIK] := seconds()

return nil

*
* funciones con los bloques
*

*
STATIC FUNCTION NEW_BLOCK(aBlocks, aBoard, aCurBlock, aCargo)
*------------------------                  @

aCargo[CG_N_CUR_BLOCK]  := aCargo[CG_N_NEXT_BLOCK]
aCargo[CG_N_NEXT_BLOCK] := Random_Block(aCargo, aCargo[CG_N_MAX_BLOCKS])

IF ++aCargo[CG_N_COUNT_BLOCKS] % N_BLOCKS_PER_LEVEL = 0 .AND.;
   aCargo[CG_N_CUR_WAIT] > 0
   IF ++aCargo[CG_N_LEVEL] = N_LEVEL_ADD_BLOCKS
      aCargo[CG_N_CUR_WAIT]   := N_INIT_WAIT - N_TIME_PER_LEVEL
      aCargo[CG_N_MAX_BLOCKS] := LEN(aBlocks)
   ELSE
      aCargo[CG_N_CUR_WAIT]  -= N_TIME_PER_LEVEL
   ENDIF
ENDIF

aCargo[CG_N_SCORE] += aCargo[CG_N_LEVEL] * N_PT_PER_BLOCK
IF aCargo[CG_N_SCORE] > aCargo[CG_N_HIGH_SCORE]
   aCargo[CG_N_HIGH_SCORE] := aCargo[CG_N_SCORE]
ENDIF

aCargo[CG_N_BLOCK_SIZE] := LEN(aBlocks[aCargo[CG_N_CUR_BLOCK]]) ^ 0.5
aCargo[CG_N_BLOCK_ROW]  := 0
aCargo[CG_N_BLOCK_COL]  := BD_WIDTH / 2
aCurBlock := ACLONE(aBlocks[aCargo[CG_N_CUR_BLOCK]])

IF Hit_Block(aBoard, aCurBlock, aCargo)
   ACOPY(aCurBlock, aCurBlock, aCargo[CG_N_BLOCK_SIZE] + 1)
   AFILL(aCurBlock, .F., LEN(aCurBlock) - aCargo[CG_N_BLOCK_SIZE] + 1)
   WHILE Hit_Block(aBoard, aCurBlock, aCargo)
         ACOPY(aCurBlock, aCurBlock, aCargo[CG_N_BLOCK_SIZE] + 1)
   ENDDO
   aCargo[CG_N_GAME] := N_GAME_OVER
ENDIF

return nil

*
STATIC FUNCTION DRAW_BLOCK(aCurBlock, aColor, aCargo, lDraw)
*-------------------------
LOCAL i, j

SETCOLOR(IF(lDraw, aColor[aCargo[CG_N_CUR_BLOCK]], 'I'))
FOR i := 0 TO aCargo[CG_N_BLOCK_SIZE] - 1
    FOR j := 0 TO aCargo[CG_N_BLOCK_SIZE] - 1
        IF aCurBlock[i*aCargo[CG_N_BLOCK_SIZE] + j + 1]
           @ aCargo[CG_N_BLOCK_ROW] + WIN_UP + i + 1, ;
             aCargo[CG_N_BLOCK_COL] + WIN_LEFT + j*2 - 1 SAY C_ELEMENT
        ENDIF
    NEXT
NEXT

return nil

*
STATIC FUNCTION DRAW_BCKGND(aBoard, aColor)
*--------------------------
LOCAL i, j

FOR i := 1 TO BD_HEIGHT
    FOR j := 2 TO BD_WIDTH STEP 2
        SETCOLOR(IF (aBoard[i,j] # N_EMPTY, aColor[aBoard[i,j]], 'I'))
        @ WIN_UP + i, WIN_LEFT + j - 1 SAY C_ELEMENT
    NEXT
NEXT

return nil

*
STATIC FUNCTION DRAW_NEXT_BLOCK(aBlocks, aColor, aCargo)
*------------------------------
LOCAL i, j, nSize

SETCOLOR(aColor[aCargo[CG_N_NEXT_BLOCK]])
nSize := LEN(aBlocks[aCargo[CG_N_NEXT_BLOCK]] ) ^ 0.5
@ N_NEXT_BLOCK_ROW, N_COL_SCORE CLEAR TO ;
  N_NEXT_BLOCK_ROW + 3, N_COL_SCORE + 7
FOR i := 0 TO nSize - 1
    FOR j := 0 TO nSize - 1
        IF aBlocks[aCargo[CG_N_NEXT_BLOCK], i * nSize + j + 1]
           @ N_NEXT_BLOCK_ROW+i, N_COL_SCORE + j*2 SAY C_ELEMENT
        ENDIF
    NEXT
NEXT

return nil

*
STATIC FUNCTION ROTATE_BLOCK(aCurBlock, aCargo, nSens)
*--------------------------- @
LOCAL i, j, aTmpBlock, wCargo := aCargo[CG_N_BLOCK_SIZE]

DO CASE
   CASE wCargo = 4
        aTmpBlock := ARRAY(LEN(aCurBlock))
        IF nSens = K_LEFT
           FOR i := 0 TO 3
               FOR j := 0 TO 3
                   aTmpBlock[ i * 4 + j + 1 ] := aCurBlock[ j * 4 + i + 1 ]
               NEXT
           NEXT
        ELSE
           FOR i := 0 TO 3
               FOR j := 0 TO 3
                   aTmpBlock[ j * 4 + i + 1 ] := aCurBlock[ i * 4 + j + 1 ]
               NEXT
           NEXT
        ENDIF
        aCurBlock := aTmpBlock

   CASE wCargo = 3
        aTmpBlock := ARRAY(LEN(aCurBlock))
        IF nSens = K_LEFT
           FOR i := 0 TO 2
               FOR j := 0 TO 2
                   aTmpBlock[ ( 2 - j ) * 3 + i + 1 ] := aCurBlock[ i * 3 + j + 1 ]
               NEXT
           NEXT
        ELSE
           FOR i := 0 TO 2
               FOR j := 0 TO 2
                   aTmpBlock[ i * 3 + j + 1 ] := aCurBlock[ (2 - j) * 3 + i + 1 ]
               NEXT
           NEXT
        ENDIF
        aCurBlock := aTmpBlock
ENDCASE

return nil

*
STATIC FUNCTION HIT_BLOCK(aBoard, aCurBlock, aCargo)
*------------------------
LOCAL i,j

FOR i := 0 TO aCargo[CG_N_BLOCK_SIZE] - 1

    FOR j := 0 TO aCargo[CG_N_BLOCK_SIZE] - 1

        IF aCurBlock[i * aCargo[CG_N_BLOCK_SIZE] + j + 1] .AND.;
           aBoard[aCargo[CG_N_BLOCK_ROW] + i + 1, aCargo[CG_N_BLOCK_COL] + j * 2 + 1] # N_EMPTY
           return .T.
        ENDIF

    NEXT
NEXT

return .F.

*
STATIC FUNCTION PLACE_BLOCK(aBlocks, aBoard, aCurBlock, aColor, aCargo)
*--------------------------                  @
LOCAL i,j, nLines

FOR i := 0 TO aCargo[CG_N_BLOCK_SIZE] - 1
    FOR j := 0 TO aCargo[CG_N_BLOCK_SIZE] - 1
        IF aCurBlock[ i * aCargo[CG_N_BLOCK_SIZE] + j + 1]
           aBoard[aCargo[CG_N_BLOCK_ROW] + i + 1, aCargo[CG_N_BLOCK_COL] + j * 2 ] := ;
            aBoard[aCargo[CG_N_BLOCK_ROW] + i + 1, aCargo[CG_N_BLOCK_COL] + j * 2 + 1 ] := ;
             aCargo[CG_N_CUR_BLOCK]
        ENDIF
    NEXT
NEXT

IF Remove_Lines(aBoard, @nLines)
   TONE(1100,1)
   TONE(1500,1)
   Draw_BckGnd(aBoard, aColor)
   aCargo[CG_N_SCORE] += (aCargo[CG_N_LEVEL] * N_PT_PER_LINE) * nLines
   aCargo[CG_N_COUNT_LINES] += nLines
ELSE
   Draw_Block(aCurBlock, aColor, aCargo, .T.)
ENDIF

New_Block(aBlocks, aBoard, @aCurBlock, aCargo)

return nil

*
STATIC FUNCTION REMOVE_LINES(aBoard, nLines)
*---------------------------         @
LOCAL j,k,l, bRemove := .F., i := BD_HEIGHT

nLines := 0
WHILE i >= 1
      FOR j := 2 TO BD_WIDTH + 1
          IF aBoard[i,j] = N_EMPTY
             EXIT
          ENDIF
      NEXT
      IF j > BD_WIDTH + 1
         FOR k := i TO 2 STEP - 1
             FOR l := 2 TO BD_WIDTH + 1
                 aBoard[k,l] := aBoard[k-1,l]
             NEXT
             FOR l := 2 TO BD_WIDTH + 1
                 aBoard[1,l] := N_EMPTY
             NEXT
         NEXT
         bRemove := .T.
         nLines++
      ELSE
         i--
      ENDIF
ENDDO

return bRemove

*
STATIC FUNCTION A_STATUS()
*-----------------------
//        1   2             3      4
return { {00, "  Puntaje:", "R/",  {|aCargo| NPADL(aCargo[CG_N_HIGH_SCORE])} },;
         {02, "   Estado:", "R/",  {|aCargo| PADR(A_C_STATUS[aCargo[CG_N_GAME]], N_LEN_DISP)} },;
         {04, "Resultado:", "R+/", {|aCargo| NPADL(aCargo[CG_N_SCORE])} },;
         {11, "    Nivel:", "GR+/",{|aCargo| NPADL(aCargo[CG_N_LEVEL])} },;
         {13, "   L¡neas:", "G+/", {|aCargo| NPADL(aCargo[CG_N_COUNT_LINES])} },;
         {14, "  Bloques:", "G+/", {|aCargo| NPADL(aCargo[CG_N_COUNT_BLOCKS])} },;
         {15, "Velocidad:", "G+/", {|aCargo| NPADL(1 + int((N_INIT_WAIT - aCargo[CG_N_CUR_WAIT]) / 100))} } }

*
function ntrim(x) ; return ltrim(str(x))

*
function Shadow(nTop, nLeft, nBottom, nRight, cCol)
*--------------
local wScr

cCol := if(cCol = nil, chr(8), cCol)

dispbegin()

wScr := savescreen(nTop, nLeft, nBottom, nRight)
restscreen(nTop, nLeft, nBottom, nRight, ;
           transform(wScr, replicate('X'+ cCol, len(wScr))))

dispend()

return nil
