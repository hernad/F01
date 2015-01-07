/* net:127.0.0.1:2941:topsecret:data/_tst_ */

//#define DBSERVER  "f01-srv"
#define DBSERVER  "192.168.45.149"
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


FUNCTION ARG0()


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

  connect_to_f01_server()

  RETURN 'net:' + DBSERVER + ':' +   hb_ntos( DBPORT ) + ':' + DBPASSWD + ':'


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

   cDb := f01_server() + cDb
   RETURN dbUseArea( lNew, xRdd, cDb, cAlias, lShared , lReadOnly )                                               ;


FUNCTION testMain()

   ? "hello world"
   inkey(0)
   RETURN .T.

FUNCTION run_ext_command( cCommand )

 RUN cCommand


FUNCTION OL_YIELD()

  RETURN .T.
