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

/* net:127.0.0.1:2941:topsecret:data/_tst_ */

#define DBSERVER  "127.0.0.1"
#define DBPORT    2941
#define DBPASSWD  "f01"
#define DBDIR     "data"
#define DBFILE    "_tst_.dbf"

#define DBNAME    "net:" + DBSERVER + ":" + hb_ntos( DBPORT ) + ":" + ;
                  DBPASSWD + ":" + DBDIR + "/" + DBFILE

#define LOCAL_DBNAME DBDIR + "/" + DBFILE

REQUEST DBFCDX

REQUEST hb_DirExists
REQUEST hb_DirCreate


PROCEDURE Main()

   LOCAL pSockSrv, lExists

   OutStd( "ver 0.3.0" + hb_eol() )

   f01_gvars_init()
//   f01_init_harbour()


   SET EXCLUSIVE OFF
   rddSetDefault( "DBFCDX" )

   pSockSrv := netio_MTServer( DBPORT,,, /* RPC */ .T., DBPASSWD )

   IF Empty( pSockSrv )
      ? "Cannot start NETIO server !!!"
      WAIT "Press any key to exit..."
      QUIT
   ENDIF

   ? "NETIO server activated."
   hb_idleSleep( 0.1 )
   WAIT

   ?
   ? "netio_Connect():", netio_Connect( DBSERVER, DBPORT, , DBPASSWD )
   ?

   lExists := netio_FuncExec( "HB_DirExists", "data" )
   ? "Directory 'data'", iif( ! lExists, "not exists", "exists" )
   IF ! lExists
      ? "Creating directory 'data' ->", ;
         iif( netio_FuncExec( "hb_DirCreate", "data" ) == -1, "error", "OK" )
   ENDIF

   ? "'" + DBNAME + "'"
   createdb( LOCAL_DBNAME, DBNAME )
   testdb( LOCAL_DBNAME )
   WAIT

   ?
   ? "table exists:", dbExists( DBNAME )
   WAIT

/*
   dbDrop, dbExists

   ?
   ? "delete table with indexes:", dbDrop( DBNAME )
   ? "table exists:", dbExists( DBNAME )
   WAIT
*/

   DO while .T.
     ? " 'ex' za izlazak"
     WAIT

     IF LastKey() == ASC( 'e' )
       ? "Ostalo jos 'x' za izlazak"
       WAIT
       IF LastKey() == ASC( 'x' )
         ? "netio_Disconnect():", netio_Disconnect( DBSERVER, DBPORT )

         ?
         ? "stopping the server..."
         netio_ServerStop( pSockSrv, .T. )
         QUIT
       ELSE
         ? "pressed key:", LastKey()
       ENDIF
    ELSE
        ? "pressed key:" , LastKey()
    ENDIF

   ENDDO

   RETURN


FUNCTION  HELLO_NETIO()
   RETURN "HELLO NETIO"


PROCEDURE createdb( cLocalName, cName )

   LOCAL n, lCreated := .F.

   srv_add( 10, 20 )

   IF ! File( cLocalName )
     ? "Fajl ne postoji", cLocalName
     ? "local:", cLocalName, "netio name", cName
     inkey(0)

     dbCreate( cName, { ;
      { "F1", "C", 20, 0 }, ;
      { "F2", "M",  4, 0 }, ;
      { "F3", "N", 10, 2 }, ;
      { "F4", "T",  8, 0 } } )
   
   ? "create neterr:", NetErr(), hb_osError()
     lCreated := .T.
   ELSE
      ? "vec postoji tabela:", cLocalName
   ENDIF

   inkey(0)

   USE ( cLocalName )
   ? "use neterr:", NetErr(), hb_osError()


   IF lCreated
   WHILE LastRec() < 1000
      dbAppend()
      n := RecNo() - 1
      ? Recno()

      field->F1 := Chr( n % 26 + Asc( "A" ) ) + " " + Time()
      field->F2 := field->F1
      field->F3 := n / 100
      field->F4 := hb_DateTime()
   ENDDO
   ENDIF

   ? "reccount:", reccount()

/*
   IF OrdNum() == 3
     ? "indeksi vec postoje"
   ELSE

     ? "creating indexes:"
     ? "index F1"
     INDEX ON field->F1 TAG T1
     ? "index F3"
     INDEX ON field->F3 TAG T3
     ? "index F4"
     INDEX ON field->F4 TAG T4
     CLOSE
     ?
   ENDIF
*/

   RETURN

PROCEDURE testdb( cName )

   LOCAL i, j

   USE ( cName )
   ? "used:", Used()
   ? "nterr:", NetErr()
   ? "alias:", Alias()
   ? "lastrec:", LastRec()
/*
   ? "ordCount:", ordCount()
   FOR i := 1 TO ordCount()
      ordSetFocus( i )
      ? i, "name:", ordName(), "key:", ordKey(), "keycount:", ordKeyCount()
   NEXT
   ordSetFocus( 1 )
   dbGoTop()
   WHILE ! Eof()
      IF ! field->F1 == field->F2
         ? "error at record:", RecNo()
         ? "  ! '" + field->F1 + "' == '" + field->F2 + "'"
      ENDIF
      dbSkip()
   ENDDO
   WAIT
   i := Row()
   j := Col()
   dbGoTop()
   Browse()
   SetPos( i, j )
*/

   CLOSE

   RETURN


function PreUseEvent()

RETURN .T.


function f01_gvars_init()

   public gReadOnly := .f.
   RETURN .T.


function SRV_ADD( n1, n2 )
 
  ? n1, "+", n2, "=", n1 + n2
 
  RETURN n1 + n2

