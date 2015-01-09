#include "f01.ch"

#include "fileio.ch"


FUNCTION f01_konv_zn_baza( aPriv, aKum, aSif, cIz, cU, cSamoId )

   // cSamoId  "1"- konvertuj samo polja koja pocinju sa id
   // "2"- konvertuj samo polja koja ne pocinju sa id
   // "3" ili nil - konvertuj sva polja
   // "B" - konvertuj samo IDRADN polja iz LD-a

   LOCAL i := 0, j := 0, k := 0, aPom := {}, xVar := "", anPolja := {}
   CLOSE ALL
   SET EXCLUSIVE ON
   IF aPriv == nil; aPriv := {}; ENDIF
   IF aKum == nil ; aKum := {} ; ENDIF
   IF aSif == nil ; aSif := {} ; ENDIF
   IF cSamoid == nil; cSamoid := "3"; ENDIF
   PRIVATE cPocStanjeSif
   PRIVATE cKrajnjeStanjeSif
   IF !gAppSrv
      Box( "xx", 1, 50, .F., "Vrsi se konverzija znakova u bazama podataka" )
      @ m_x + 1, m_y + 1 SAY "Konvertujem:"
   ELSE
      ? "Vrsi se konverzija znakova u tabelama"
   ENDIF
   FOR j := 1 TO 3
      DO CASE
      CASE j == 1
         aPom := aPriv
      CASE j == 2
         aPom := aKum
      CASE j == 3
         aPom := aSif
      ENDCASE
      FOR i := 1 TO Len( aPom )
         nDbf := aPom[ i ]
         goModul:oDatabase:obaza( nDbf )
         dbSelectArea ( nDbf )
         IF !gAppSrv
            @ m_x + 1, m_y + 25 SAY Space( 12 )
            @ m_x + 1, m_y + 25 SAY Alias( nDBF )
         ELSE
            ? "Konvertujem: " + Alias( nDBF )
         ENDIF
         IF Used()
            beep( 1 )
            ordSetFocus( 0 )
            GO TOP
            anPolja := {}
            FOR k := 1 TO FCount()
               IF ( cSamoId == "3" ) .OR. ( cSamoId == "1" .AND. Upper( FieldName( k ) ) = "ID" ) .OR. ( cSamoId == "2"  .AND. !( Upper( FieldName( k ) ) = "ID" ) ) .OR. ( cSamoId == "B" .AND. ( ( Upper( FieldName( k ) ) = "IDRADN" ) .OR. ( ( Upper( FieldName( k ) ) = "ID" ) .AND. Alias( nDbf ) == "RADN" ) ) )
                  xVar := FieldGet( k )
                  IF ValType( xVar ) $ "CM"
                     AAdd( anPolja, k )
                  ENDIF
               ENDIF  // csamoid
            NEXT
            DO WHILE !Eof()
               FOR k := 1 TO Len( anPolja )
                  xVar := FieldGet( anPolja[ k ] )
                  FieldPut( anPolja[ k ], StrKZN( xVar, cIz, cU ) )
                  // uzmi za radnika ime i prezime
                  IF ( cSamoId == "B" ) .AND. Upper( FieldName( 1 ) ) = "ID" .AND. Alias( nDbf ) == "RADN"
                     // AADD(aSifRev, {FIELDGET(4)+" "+FIELDGET(5), cPocStanjeSif, cKrajnjeStanjeSif})
                  ENDIF
               NEXT
               SKIP 1
            ENDDO
            USE
         ENDIF
      NEXT
   NEXT
   IF !gAppSrv
      BoxC()
   ENDIF
   SET EXCLUSIVE OFF
   IF !gAppSrv
      f01_brisi_index_pakuj_dbf()
   ELSE
      ? "Baze konvertovane!!!"
      f01_brisi_index_pakuj_dbf()
   ENDIF

   RETURN
