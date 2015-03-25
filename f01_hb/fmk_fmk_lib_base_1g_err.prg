/*
 * This file is part of the bring.out FMK, a free and open source
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "f01.ch"
#include "error.ch"
#include "dbstruct.ch"
#include "set.ch"


FUNCTION f01_error_handler( objErr, lLocalHandler )

   LOCAL cOldDev
   LOCAL cOldCon
   LOCAL cScr
   LOCAL cStampaj
   LOCAL nErr
   LOCAL cOdg

   PRIVATE ckom

   IF llocalHandler == NIL
      lLocalHandler := .F.
   ENDIF


   IF lLocalHandler
      Break objErr
   ENDIF

/*
   cOldDev := Set( _SET_DEVICE, "SCREEN" )
   cOldCon := Set( _SET_CONSOLE, "ON" )
   cOldPrn := Set( _SET_PRINTER, "" )
   cOldFile := Set( _SET_PRINTFILE, "" )


   lInstallDB := .F.

   BEEP( 5 )
   SetCancel( .T. )

   nErr := objErr:genCode
   DO CASE

   CASE objErr:genCode = EG_ARG
      MsgO( objErr:description + ' Neispravan argument' )
   CASE objErr:genCode = EG_BOUND
      MsgO( objErr:description + ' Greska-EG_BOUND' )
   CASE objErr:genCode = EG_STROVERFLOW
      MsgO( objErr:description + ' Prevelik string' )
   CASE objErr:genCode = EG_NUMOVERFLOW
      MsgO( objErr:description + ' Prevelik broj' )
   CASE objErr:genCode = 36
      // Workarea not indexed
      lInstallDB := .T.

   CASE objErr:genCode = EG_ZERODIV
      MsgO( objErr:description + ' Dijeljenje sa nulom' )
   CASE objErr:genCode = EG_NUMERR
      MsgO( objErr:description + ' EG_NUMERR' )
   CASE objErr:genCode = EG_SYNTAX
      MsgO( objErr:description + ' Greska sa sintaksom' )
   CASE objErr:genCode = EG_COMPLEXITY
      MsgO( 'Prevelika kompleksnost za makro operaciju' )

   CASE objErr:genCode = EG_MEM
      MsgO( objErr:description + ' Nepostojeca varijabla' )


   CASE objErr:genCode = EG_NOFUNC
      MsgO( objErr:description + ' Nepostojeca funkcija' )
   CASE objErr:genCode = EG_NOMETHOD
      MsgO( objErr:description + ' Nepostojeci metod' )
   CASE objErr:genCode = EG_NOVAR
      MsgO( objErr:description + ' Nepostojeca varijabla -?-' )

   CASE objErr:genCode = EG_NOALIAS
      MsgO( objErr:description + ' Nepostojeci alias' )
   CASE objErr:genCode = EG_NOVARMETHOD
      MsgO( objErr:description + ' Nepostojeci metod' )

   CASE objErr:genCode = EG_CREATE
      MsgO( ObjErr:description + ' Ne mogu kreirati fajl ' + ObjErr:filename )
   CASE objErr:genCode = EG_OPEN
      MsgO( ObjErr:description + ' Ne mogu otvoriti fajl ' + ObjErr:filename )
      lInstallDB := .T.

   CASE objErr:genCode = EG_CLOSE
      MsgO( objErr:description + ':Ne mogu zatvoriti fajl ' + ObjErr:filename )
   CASE objErr:genCode = EG_READ
      MsgO( objErr:description + ':Ne mogu procitati fajl ' + ObjErr:filename )
   CASE objErr:genCode = EG_WRITE
      MsgO( objErr:description + ':Ne mogu zapisati u fajl ' + ObjErr:filename )
   CASE objErr:genCode = EG_PRINT
      MsgO( objErr:description + ':Greska sa stampacem !!!!' )

   CASE objErr:genCode = EG_UNSUPPORTED
      MsgO( objErr:description + ' Greska - nepodrzano' )

   CASE objErr:genCode = EG_CORRUPTION
      MsgO( objErr:description + ' Grska - ostecenje pomocnih CDX fajlova' )
      lInstallDB := .T.

   CASE objErr:genCode = EG_DATATYPE
      MsgO( objErr:description + ' Greska - tip podataka neispravan' )
   CASE objErr:genCode = EG_DATAWIDTH
      MsgO( objErr:description + ' Greska EG_DATAWIDTH' )
   CASE objErr:genCode = EG_NOTABLE
      MsgO( objErr:description + ' Greska - EG_NOTABLE' )
   CASE objErr:genCode = EG_NOORDER
      MsgO( objErr:description + ' Greska - no order ' )
   CASE objErr:genCode = EG_SHARED
      MsgO( objErr:description + ' Greska - dijeljenje' )
   CASE objErr:genCode = EG_UNLOCKED
      MsgO( objErr:description + ' Greska - nije zakljucan zapis/fajl' )
   CASE objErr:genCode = EG_READONLY
      MsgO( objErr:description + ' Greska - samo za citanje' )
   CASE objErr:genCode = EG_APPENDLOCK
      MsgO( objErr:description + ' Greska - nije zakljucano pri apendovanju' )
   OTHERWISE
      MsgO( objErr:description + ' Greska !' )
   ENDCASE


   DO WHILE NextKey() == 0
      OL_Yield()
   ENDDO
   Inkey()
   MsgC()

   IF ( lInstallDB .AND. !( goModul:oDatabase:lAdmin ) .AND. Pitanje(, "Install DB procedura ?", "D" ) == "D" )
      goModul:oDatabase:install()
      RETURN .T.
   ENDIF


   SET( _SET_DEVICE, cOldDev )
   SET( _SET_CONSOLE, cOldCon )
   SET( _SET_PRINTER, cOldPrn )
   SET( _SET_PRINTFILE, cOldFile )

   SetColor( StaraBoja )

   CLS
*/

   //START PRINT RET .F.
   SET( _SET_PRINTER, "f01_error.txt" )
   SET PRINTER ON

   ?
   ? "Verzija programa:", gVerzija," verzija LIB-a:", elibver()
   ?
   ? "Podsistem :", objErr:SubSystem
   ? "GenKod:", Str( objErr:GenCode, 3 ), "OpSistKod:", Str( objErr:OsCode, 3 )
   ? "Opis:", objErr:description
   ? "ImeFajla:", objErr:filename
   ? "Operacija:", objErr:operation
   ? "Argumenti:", objErr:args

   FOR i := 10 TO 2 STEP -1
      IF !Empty( ProcName( i ) )
         ? "Procedura:", PadR( ProcName( i ), 30 ), "Linija:", ProcLine( i )
      ENDIF
   NEXT

/*
   ?
   ? "Trenutno radno podrucje:", Alias(), ", na zapisu broj:", RecNo()
   ? "PrivPath :", PRIVPATH
   ? "KumPath  :", KUMPATH
   ? "SifPath  :", SIFPATH
   ?
*/

   //ENDPRINT
   SET PRINTER OFF

   ? "ERROR QUIT !"
   Inkey()
   QUIT



   CLOSE ALL
   goModul:quit()

   RETURN


FUNCTION ShowFERROR()

   LOCAL aGr := { {  0, "Successful" }, ;
      {  2, "File not found" }, ;
      {  3, "Path not found" }, ;
      {  4, "Too many files open" }, ;
      {  5, "Access denied" }, ;
      {  6, "Invalid handle" }, ;
      {  8, "Insufficient memory" }, ;
      { 15, "Invalid drive specified" }, ;
      { 19, "Attempted to write to a write-protected" }, ;
      { 21, "Drive not ready" }, ;
      { 23, "Data CRC error" }, ;
      { 29, "Write fault" }, ;
      { 30, "Read fault" }, ;
      { 32, "Sharing violation" }, ;
      { 33, "Lock violation" } }
   LOCAL n := 0, k := FError()

   n := AScan( aGr, {| x| x[ 1 ] == k } )
   IF n > 0
      MsgBeep( "FERROR: " + AllTrim( Str( aGr[ n, 1 ] ) ) + "-" + aGr[ n, 2 ] )
   ELSEIF k <> 0
      MsgBeep( "FERROR: " + AllTrim( Str( k ) ) )
   ENDIF

   RETURN



FUNCTION MyErrH( o )

   BREAK o

   RETURN
