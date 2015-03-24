/* net:127.0.0.1:2941:topsecret:data/_tst_ */

// #define DBSERVER  "f01-srv"

#include "f01.ch"

#define DBSERVER  "127.0.0.1"
#define DBPORT    2941
#define DBPASSWD  "f01"
#define DBDIR     "/data"
#define DBFILE    "_tst_"

STATIC s_lConnected := NIL
STATIC s_lServer := .F.

FUNCTION initfw()

   // to nesto rtf koristili

   RETURN

FUNCTION wwsjecistr()

   // to nesto koristeno za rtf

   RETURN


FUNCTION mkdir()

   Alert( "mkdir" )

FUNCTION tekuci_direktorij()
   RETURN "." + SLASH

FUNCTION modul_dir()

   // npr. SIGMA/KALK/

   RETURN MODULE_ROOT + SLASH + gModul + SLASH


FUNCTION mnu_narudzbenica()
   RETURN mnu_narudzba()

FUNCTION rloptlevel()
   RETURN 0


FUNCTION cm2Str( xVal )

   cType = ValType( xVal )
   cVal := hb_ValToStr( xVal )

   IF cType == 'C'
      cVal := "'" + cVal + "'"
   ENDIF

   IF cType == 'D'
      cVal := "STOD('" + DToS( xVal ) + "')"
   ENDIF

   RETURN cVal


FUNCTION cmxAutoOpen ( lAuto )

   RETURN  SET( _SET_AUTOPEN, lAuto )


FUNCTION  SETPXLAT( xVal )
   RETURN xVal


FUNCTION hb_symbol_unused()

FUNCTION f01_server()

   IF is_install() .OR. is_server_run()
      // lokalno pristupiti
      RETURN ""
   ENDIF

   RETURN 'net:' + DBSERVER + ':' +   hb_ntos( DBPORT ) + ':' + DBPASSWD + ':'


FUNCTION connect_to_f01_server()

   IF is_server_run()
      RETURN .T.
   ENDIF

   IF s_lConnected != NIL
      RETURN .T.
   ENDIF

   s_lConnected := netio_Connect( DBSERVER, DBPORT,, DBPASSWD )

   IF !s_lConnected
      ? "Cannot connect to NETIO server !!!"
      WAIT "Press any key to exit..."
      QUIT
   ENDIF

   RETURN .T.


FUNCTION my_dbUseArea( lNew, xRdd, cDb, cAlias, lShared, lReadOnly )

   cDb := f01_server() + ChangeEXT( cDb, DBFEXT, "DBF" )
   //cDb := STRTRAN( cDb, "." + BACKSLASH , "")

   OutStd( "my db use: " + cDb + hb_eol() )
   RETURN dbUseArea( lNew, xRdd, cDb, cAlias, lShared, lReadOnly )                                               ;


      FUNCTION testMain()

? "hello world"
Inkey( 0 )

   RETURN .T.

FUNCTION run_ext_command( cCommand )

   RUN cCommand

FUNCTION OL_Yield()

   RETURN hb_idleSleep()


PROCEDURE f01_init_harbour()

   SET CENTURY OFF
   SET EPOCH TO 1960
   SET DATE TO GERMAN

   SET DELETED ON

   hb_cdpSelect( "SL852" )
   hb_SetTermCP( "SLISO" )

   RETURN


FUNCTION is_server_run( xVal )

   IF xVal != NIL
      s_lServer := xVal
   ENDIF

   RETURN s_lServer


/*
   DO WHILE not_key_esc()
*/

FUNCTION not_key_esc()

   IF Inkey() == 27
      dbCloseAll()
      SET( _SET_DEVICE, "SCREEN" )
      SET( _SET_CONSOLE, "ON" )
      SET( _SET_PRINTER, "" )
      SET( _SET_PRINTFILE, "" )
      MsgC()
      RETURN     .F.
   ENDIF

   RETURN .T.
