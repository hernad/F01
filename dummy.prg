/* net:127.0.0.1:2941:topsecret:data/_tst_ */

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

function dbselectarr( xArea )
 return dbselectArea( xArea )

function mkdir()

alert( "mkdir" )


FUNCTION ARG0()

FUNCTION BLILIBLOD()

FUNCTION  BLIMEMMAX()

FUNCTION BOOTCOLD()

//FUNCTION CM2STR()

//function fc_hcp_cli( cFPath, cFName, aKupac, cError )

FUNCTION mnu_narudzbenica()
  return mnu_narudzba()

FUNCTION rloptlevel()
  RETURN 0

// konvertovati na pic_vrijednost PIC_VRIJEDOST()


FUNCTION SETTBLPARTN()
  ALERT( "RENAME SETTBLPARTN() ... PARTNER")

FUNCTION FC_HCP_CLIENT

  Alert( "hcp client rename" )

FUNCTION GETNEXTKALKDOK()

   ALERT( "RENAME DOK TO GetNextKalkDoc" )


function CM2STR()

function CMFILTCOUNT()

function CMXAUTOOPEN()

function  CMXCLRSCOPE()

function       CMXKEYSINCLUDED()

function CMXSETSCOPE()

function PEEKBYTE()

function  SETPXLAT()


function hb_symbol_unused()


function f01_server()

  connect_to_f01_server()
  return 'net:' + DBSERVER + ':' +   hb_ntos( DBPORT ) + ':' + DBPASSWD + ':'


FUNCTION connect_to_f01_server()

  //SET EXCLUSIVE OFF
  //rddSetDefault( "DBFCDX" )

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


FUNCTION my_dbUseArea( lNew, xRdd, cDb, cAlias, lExclusive, lReadOnly )

   RETURN dbUseArea( lNew, xRdd, f01_server() + cDb, cAlias, !gInstall , gReadOnly )                                               ;
