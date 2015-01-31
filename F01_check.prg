#include "f01.ch"

STATIC s_hNalozi := NIL

STATIC s_cFinDir := "."

STATIC s_lEsc := .F.

REQUEST DBFCDX


PROCEDURE usage()

   ? "Poziv:"
   ?
   ? "unix:     $ ./F01_check"
   ? "          $ ./F01_check  --findir SIGMA/FIN/KUM1"
   ?
   ? "windows   > F01.exe"
   ? "          > F01.exe --findir C:\SIGMA\FIN\KUM1"
 
   ?

   RETURN

FUNCTION fin_dir()
   RETURN s_cFinDir

PROCEDURE Main( ... )

   LOCAL lFinDirNext := .F.
   LOCAL cParam

   FOR EACH cParam IN hb_AParams()
      IF lFinDirNext
         s_cFinDir := cParam
      ENDIF
      IF cParam == "--fin-dir"
         lFinDirNext := .T.
      ELSE
         lFinDirNext := .F.
      ENDIF

      IF cParam == "--help"
         usage()
         QUIT
      ENDIF
   NEXT

   f01_init_harbour()
   f01_check_fin()

   RETURN


FUNCTION f01_check_fin()

   s_hNalozi := hb_hash()

   sum_tbl_nalog()

   analiza_nalozi()

   RETURN .T.

FUNCTION keyboard_esc()

   IF !s_lEsc
     s_lEsc := (INKEY() == 27)
   ENDIF

   RETURN s_lEsc

FUNCTION sum_tbl_nalog()

   LOCAL nDug, nPot
   LOCAL cTabela
   LOCAL cIdFirma, cIdVn, cBrNal
   LOCAL bNalogVars := {| cIdFirma, cIdvn, cBrNal | field->idfirma + field->idvn + field->brNal == cIdFirma + cIdVn + cBrNal }
   LOCAL bSum := {| nDug, nPot | nDug := nDug + field->dugBHD, nPot := nPot + field->potBHD }


   ? "Keyboard <ESC> - prekid"

   FOR EACH cTabela IN { "n", "s", "a", "x" }

      SWITCH cTabela
      CASE 'n'
         USE ( fin_dir() + SLASH + "NALOG" )
         SET ORDER TO TAG "1"
         EXIT
      CASE 's'
         USE ( fin_dir() + SLASH + "SINT" )
         SET ORDER TO TAG "2"
         EXIT
      CASE 'a'
         USE ( fin_dir() + SLASH + "ANAL" )
         SET ORDER TO TAG "2"
         EXIT
      CASE 'x'
         USE ( fin_dir() + SLASH + "SUBAN" )
         SET ORDER TO TAG "4"
         bSum := {| nDug, nPot | IIF( field->d_p == "1", nDug := nDug + field->iznosBHD, nPot := nPot + field->iznosBHD ) }

         EXIT
      ENDSWITCH


      GO TOP
      DO WHILE !Eof() .AND. !keyboard_esc()
         cIdFirma := field->idFirma
         cIdVn := field->idVn
         cBrNal := field->brNal
         nDug := 0
         nPot := 0
         DO WHILE !Eof() .AND. !keyboard_esc() .AND. Eval( bNalogVars, cIdFirma, cIdVn, cBrNal )
            Eval( bSum, @nDug, @nPot )
            SKIP
         ENDDO
         add_nalog( cTabela, cIdFirma + "-" + cIdVn + "-" + cBrNal, nDug, nPot )

      ENDDO
      USE

   NEXT

   RETURN .T.

FUNCTION analiza_nalozi()

LOCAL cKey, aNalog

   ? "Broj finansijski naloga: ", Len( s_hNalozi )

   ? "Fajl 'error.txt' sadrzi naloge sa greskama"

    
   SET ALTERNATE TO "error.txt"
   ? "error.txt se formira ... sacekajte trenutak ... "
   SET ALTERNATE ON
   SET CONSOLE OFF
   ? "---- F01_check - ERROR report  -------" 
   ? DATE(), TIME()

   hb_hEval( s_hNalozi, { | cNalog, aNalog, nPos|
     IF (ROUND(aNalog[1][1] - aNalog[2][1], 3) != 0) .OR. ;
        (ROUND(aNalog[1][1] - aNalog[3][1], 3) != 0) .OR. ;
        (ROUND(aNalog[1][1] - aNalog[4][1], 3) != 0) .OR. ;
        (ROUND(aNalog[1][2] - aNalog[2][2], 3) != 0) .OR. ;
        (ROUND(aNalog[1][2] - aNalog[3][2], 3) != 0) .OR. ;
        (ROUND(aNalog[1][2] - aNalog[4][2], 3) != 0)
         print_error_nalog( cNalog, aNalog )
     ENDIF
   } )
   ? 
   ? "------ ERROR REPORT END ---------------"
   SET ALTERNATE OFF
   SET CONSOLE ON
   ? "error txt napravljen !"
   RETURN .T.


FUNCTION print_error_nalog(cNalog, aNalog)

  ? "ERROR", cNalog
  ? "nalog:", transform( aNalog[1,1], format_iznos()), transform( aNalog[1,2], format_iznos() )
  ? " sint:", transform( aNalog[2,1], format_iznos()), transform( aNalog[2,2], format_iznos() )
  ? " anal:", transform( aNalog[3,1], format_iznos()), transform( aNalog[3,2], format_iznos() )
  ? "suban:", transform( aNalog[4,1], format_iznos()), transform( aNalog[4,2], format_iznos() )

  RETURN .T.


FUNCTION format_iznos()

   RETURN "99999999.99"

FUNCTION add_nalog( cTabela, cNalog, nDug, nPot )

   LOCAL nRet
   LOCAL aSumNalog := {-999999, -999999}, aSumSint := {-888888, -888888}
   LOCAL aSumAnal := {-777777, -777777}, aSumSuban := {-666666, -666666}

   ? cTabela, cNalog, TRANSFORM( nDug, format_iznos()), TRANSFORM(nPot, format_iznos())


   nRet := hb_hPos( s_hNalozi, cNalog )

   IF nRet == 0
      s_hNalozi[ cNalog ] := { aSumNalog, aSumSint, aSumAnal, aSumSuban }
      nRet := 1
   ENDIF

   SWITCH cTabela
   CASE 'n'
      aSumNalog := { nDug, nPot }
      s_hNalozi[ cNalog ][ 1 ] := aSumNalog
      EXIT
   CASE 's'
      aSumSint := { nDug, nPot }
      s_hNalozi[ cNalog ][ 2 ] := aSumSint
      EXIT
   CASE 'a'
      aSumAnal := { nDug, nPot }
      s_hNalozi[ cNalog ][ 3 ] := aSumAnal
      EXIT
   CASE 'x'
      aSumSuban := { nDug, nPot }
      s_hNalozi[ cNalog ][ 4 ] := aSumSuban
      EXIT
   ENDSWITCH

   RETURN .T.


PROCEDURE f01_init_harbour()

   SET CENTURY OFF
   SET EPOCH TO 1960
   SET DATE TO GERMAN

   SET DELETED ON

   // hb_cdpSelect( "SL852" )
   // hb_SetTermCP( "SLISO" )
   rddSetDefault( "DBFCDX" )

   RETURN
