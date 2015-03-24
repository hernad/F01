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

FUNCTION f01_kopi( cPath, fProm )

   IF fBrisiDBF
      nPos := At( ".", cDbf )
      SELECT olddbf; USE
      FErase( cPath + Left( cDbf, npos ) + "DBF" )
      ? "BRISEM :", cPath + Left( cDbf, npos ) + "DBF"
      FErase( cPath + Left( cDbf, npos ) + "FPT" )
      ? "BRISEM :", cPath + Left( cDbf, npos ) + "FPT"
      fBrisiDBF := .F.
      RETURN

   ENDIF

   IF fRenameDBF
      nPos := At( ".", cDbf )
      nPos2 := At( ".", cImeP )
      c1 := cPath + Left( cDbf, nPos ) + "DBF"
      c2 := cPath + Left( cImeP, nPos2 ) + "DBF"
      SELECT olddbf; USE
      IF FRename( c1, c2 ) = 0
         ? "PREIMENOVAO :", c1, " U ", c2
      ENDIF
      c1 := cPath + Left( cDbf, npos ) + "FPT"
      c2 := cPath + Left( cImeP, npos2 ) + "FPT"
      IF FRename( c1, c2 ) = 0
         ? "PREIMENOVAO :", c1, " U ", c2
      ENDIF
      fRenameDBF := .F.
      RETURN
   ENDIF

   IF fProm
      nPos := RAt( SLASH, cDbf )
      IF nPos <> 0
         cPath2 := SubStr( cDbf, 1, nPos )
      ELSE
         cPath2 := ""
      ENDIF
      cCDX := StrTran( cDBF, "." + DBFEXT, "." + INDEXEXT )
      IF Right( cCDX, 4 ) = "." + INDEXEXT
         FErase( cPath + cCDX )
      ENDIF

      FErase( f01_transform_dbf_name( cPath + cPath2 + "TMP_TMP.FPT" ) )
      FErase( f01_transform_dbf_name( cPath + cPath2 + "TMP_TMP.DBF" ) )
      FErase( f01_transform_dbf_name( cPath + cPath2 + "TMP_TMP.CDX" ) )

      dbCreate( f01_transform_dbf_name( cPath + cPath2 + "TMP_TMP.DBF" ), aNStru )

      SELECT 2
      USE_EXCLUSIVE( f01_transform_dbf_name( cPath + cPath2 + "TMP_TMP" ) ) ALIAS tmp
      SELECT olddbf

      ?
      nRow := Row()
      @ nrow, 20 SAY "/"; ?? RecCount()
      SET ORDER TO 0;  GO TOP
      DO WHILE !Eof()
         @ nrow, 1  SAY RecNo()
         SELECT tmp
         dbAppend()

         FOR i := 1 TO Len( aStru )
            // prolaz kroz staru strukturu i preuzimanje podataka
            cImeP := aStru[ i, 1 ]
            IF Len( aStru[ i ] ) > 4
               cImePN := aStru[ i, 5 ]
               IF aStru[ i, 2 ] == aStru[ i, 6 ]
                  replace &cImePN WITH olddbf->&cImeP
               ELSEIF aStru[ i, 2 ] == "C" .AND. aStru[ i, 6 ] == "N"
                  replace &cImePN WITH Val( olddbf->&cImeP )
               ELSEIF aStru[ i, 2 ] == "N" .AND. aStru[ i, 6 ] == "C"
                  replace &cImePN WITH Str( olddbf->&cImeP )
               ELSEIF aStru[ i, 2 ] == "C" .AND. aStru[ i, 6 ] == "D"
                  replace &cImePN WITH CToD( olddbf->&cImeP )
               ENDIF
            ELSE
               nPos := AScan( aNStru, {| x| cImeP == x[ 1 ] } )
               IF nPos <> 0 // polje postoji u novoj bazi
                  replace &cImeP WITH olddbf->&cImeP
               ENDIF
            ENDIF
         NEXT // aStru

         SELECT olddbf
         SKIP
      ENDDO  // prolaz kroz fajl

      CLOSE ALL
      nPos := RAt( ".", cDbf )

      FErase( cPath + Left( cDbf, npos ) + "BAK" )
      FRename( cPath + cDbf, cPath + Left( cDbf, npos ) + "BAK" )
      FRename( cPath + cPath2 + "TMP_TMP.DBF", cPath + cDbf )
      FErase( cPath + cPath2 + "TMP_TMP.DBF" )

      IF File( cPath + cPath2 + "TMP_TMP.FPT" )  // postoje memo polja

         FErase( cPath + Left( cDbf, nPos ) + "FPK" )
         FRename( cPath + Left( cDbf, nPos ) + "FPT", cPath + Left( cDbf, nPos ) + "FPK" )
         FRename( cPath + cPath2 + "TMP_TMP.FPT", cPath + Left( cDbf, nPos ) + "FPT" )
         FErase( cPath + cPath2 + "TMP_TMP.FPT" )

         FErase( cPath + Left( cDbf, nPos ) + "CDX" )
         FErase( cPath + Left( cDbf, npos ) + "cdx" )
      ENDIF
   ENDIF  // fprom

   RETURN
