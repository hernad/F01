/* net:127.0.0.1:2941:topsecret:data/_tst_ */

//#define DBSERVER  "f01-srv"

#include "f01.ch"

#define DBSERVER  "127.0.0.1"
#define DBPORT    2941
#define DBPASSWD  "f01"
#define DBDIR     "/data"
#define DBFILE    "_tst_"

STATIC s_lConnected := NIL

function initfw()

  //to nesto rtf koristili
  RETURN

function wwsjecistr()

  //to nesto koristeno za rtf
  RETURN


function mkdir()

alert( "mkdir" )


FUNCTION tekuci_direktorij()
 RETURN "." + SLASH

FUNCTION modul_dir()

 // npr. SIGMA/KALK/
 RETURN MODULE_ROOT + SLASH + gModul + SLASH


FUNCTION mnu_narudzbenica()
  return mnu_narudzba()

FUNCTION rloptlevel()
  RETURN 0


function cm2Str( xVal )

  cType = VALTYPE( xVal )
  cVal := hb_ValToStr( xVal )

  IF cType == 'C'
     cVal := "'" + cVal + "'"
  ENDIF

  IF cType == 'D'
     cVal := "STOD('" + DTOS( xVal ) + "')"
  ENDIF

  RETURN cVal


function cmxAutoOpen ( lAuto )

  return  Set( _SET_AUTOPEN, lAuto )


function  SETPXLAT( xVal )
 return xVal


function hb_symbol_unused()


function f01_server()

  IF is_install()
      // lokalno pristupiti
      RETURN ""
  ENDIF

  RETURN ""
  //RETURN 'net:' + DBSERVER + ':' +   hb_ntos( DBPORT ) + ':' + DBPASSWD + ':'


FUNCTION connect_to_f01_server()


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

   cDb := f01_server() + ChangeEXT(cDb, DBFEXT, "DBF")
   RETURN dbUseArea( lNew, xRdd, cDb, cAlias, lShared , lReadOnly )                                               ;


FUNCTION testMain()

   ? "hello world"
   inkey(0)
   RETURN .T.

FUNCTION run_ext_command( cCommand )

 RUN cCommand


FUNCTION OL_YIELD()

  RETURN hb_idleSleep()


PROCEDURE f01_init_harbour()

  SET CENTURY OFF
  SET EPOCH TO 1960
  SET DATE TO GERMAN

  SET DELETED ON

  hb_cdpSelect( "SL852" )
  hb_SetTermCP( "SLISO" )


  RETURN
