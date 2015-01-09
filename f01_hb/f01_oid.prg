#include "f01.ch"

FUNCTION f01_fill_oid( cImeDbf, cImeCDX )

   PRIVATE cPomKey

   IF FieldPos( "_OID_" ) == 0
      RETURN 0
   ENDIF


   cImeCDX := StrTran( cImeCDX, "." + INDEXEXT, "" )

   nOrder := ordNumber( "_OID_" )
   cOrdKey := ordKey( "_OID_" )
   IF !( nOrder == 0  .OR. !( Left( cOrdKey, 5 ) = "_OID_" ) )
      RETURN
   ENDIF

   IF ( field->_OID_ == 0 .AND. RecCount2() <> 0 )

      Msgbeep( "OID " + Alias() + " nepopunjen " )

      IF OID_ASK == "0"
         // OID nije inicijaliziran
         IF sifra_za_koristenje_opcije( "OIDFILL" )
            OID_ASK := "D"
         ENDIF
      ENDIF

      IF  ( OID_ASK == "D" ) .AND. Pitanje(, "Popuniti OID u tabeli " + Alias() + " ?", " " ) == "D"
         MsgO( "Popunjavam OID , tabela " + Alias() )
         cPomKey := "_OID_"
         INDEX on &cPomKey TAG "_OID_"  TO ( cImeCDX )
         GO TOP
         IF field->_OID_ = 0
            SET ORDER TO 0
            GO TOP
            DO WHILE !Eof()
               REPLACE _OID_ WITH New_Oid()
               SKIP
            ENDDO
         ENDIF
         MsgC()
      ENDIF
   ENDIF

   RETURN
