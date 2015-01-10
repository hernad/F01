/*
 * Harbour Project source code:
 *    demonstration/test code for alternative RDD IO API which uses own
 *    very simple TCP/IP file server.
 *
 * Copyright 2009 Przemyslaw Czerpak <druzus / at / priv.onet.pl>
 * www - http://harbour-project.org
 *
 */

#include "inkey.ch"

#require "hbnetio"


#define DBSERVER  "127.0.0.1"
#define DBPORT    2941
#define DBPASSWD  "f01"
#define DBDIR     "/data"
#define DBFILE    "_tst_"

STATIC s_lConnected := NIL

PROCEDURE Main()

   rddSetDefault( "DBFCDX" )
   OutStd( "client ver 0.1.0" + hb_eol() )

   connect_to_f01_server()

   testdb( "net:" + DBSERVER + ":" + hb_ntos( DBPORT ) + ":" + DBDIR + "/" + DBFILE )

   RETURN

PROCEDURE testdb( cName )

   LOCAL i, j

   USE ( cName )
   ? "used:", Used()
   ? "nterr:", NetErr()
   ? "alias:", Alias()
   ? "lastrec:", LastRec()
   ? "ordCount:", ordCount()
   FOR i := 1 TO ordCount()
      ordSetFocus( i )
      ? "index", i, "name:", ordName(), "key:", ordKey(), "keycount:", ordKeyCount()
   NEXT
   ordSetFocus( 1 )
   dbGoTop()
   i := Row()
   j := Col()
   dbGoTop()
   Browse()
   CLOSE

   RETURN


function PreUseEvent()

RETURN .T.


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



