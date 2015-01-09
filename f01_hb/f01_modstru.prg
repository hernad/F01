#include "f01.ch"

#include "fileio.ch"

STATIC OID_ASK := "0"

STATIC nSlogova := 0

/*
*   fDa - True -> Batch obrada (neinteraktivno)
*/

FUNCTION f01_runmods( fDa )

   IF fda == nil
      fda := .F.
   ENDIF

   cImeCHS := EXEPATH + gModul + ".CHS"

   IF fda .OR. PitMstru( @cImeCHS )
      cScr := ""
      SAVE SCREEN TO cScr
      cEXT := SLASH + "*." + INDEXEXT
      cls
      IF fda .OR. Pitanje(, "Modifikacija u Priv dir ?", "D" ) == "D"
         CLOSE ALL
         f01_modstru( Trim( cImeCHS ), Trim( goModul:oDataBase:cDirPriv ) )
      ENDIF

      IF fda .OR. Pitanje(, "Modifikacija u SIF dir ?", "N" ) == "D"
         CLOSE ALL
         f01_modstru( Trim( cImeCHS ), Trim( goModul:oDataBase:cDirSif ) )
      ENDIF

      IF fda .OR. Pitanje(, "Modifikacija u KUM dir ?", "N" ) == "D"
         CLOSE ALL
         f01_modstru( Trim( cImeCHS ), Trim( goModul:oDataBase:cDirKum ) )
      ENDIF

      IF fda .OR. Pitanje(, "Modifikacija u tekucem dir ?", "N" ) == "D"
         CLOSE ALL
         f01_modstru( Trim( cImeCHS ), "." )
      ENDIF

      Beep( 1 )
      RESTORE SCREEN FROM cScr
      CLOSE ALL
      goModul:oDatabase:kreiraj()
      f01_reindex( .T. )
   ENDIF

   RETURN


STATIC FUNCTION PitMstru( cImeChs )

   LOCAL cDN := "N"

   cImeChs := PadR( cImeChs, 200 )

   Box(, 3, 50 )
   @ m_x + 1, m_y + 2 SAY "Izvrsiti modifikaciju struktura D/N" GET cDN PICT "@!" VALID cdn $ "DN"
   READ
   IF cDN == "D"
      @ m_x + 3, m_y + 2 SAY "CHS Skript:" GET cImeCHS PICT "@S30"
      READ
      cImeCHS := Trim( cImeChs )
   ENDIF
   BoxC()
   IF cdn == "D"
      RETURN .T.
   ELSE
      RETURN .F.
   ENDIF



/*  f01_modstru(cImeF, cPath, fString)
*   procedura modifikacija struktura
*/

FUNCTION f01_modStru( cImeF, cPath, fString )

   ? Space( 40 ), "bring.out, 10.99, ver 02.33 CDX"
   ? Space( 40 ), "-------------------------------"
   ?
   SET DELETED ON  // ne kopiraj izbrisane zapise
   CLOSE ALL

   cmxAutoOpen( .F. )  // ne otvaraj CDX-ove

   IF PCount() == 0
      ?
      ? "Sintaksa:   MODSTRU  <ImeKomandnog_fajla>  <direktorij_sa_DBF_fajlovima>"
      ? "     npr:   MODSTRU  ver0155.chs    C:/EM/FIN/1"
      ?
      QUIT
   ENDIF

   IF fstring == nil
      fString = .F.
   ENDIF

   IF cPath == nil
      cPath := ""
   ENDIF

   IF !fString

      IF Right( cPath, 1 ) <> SLASH
         cPath := cPath + SLASH
      ENDIF

      nH := FOpen( ToUnix( cImeF ) )
      IF nH == -1
         nH := FOpen( ".." + SLASH + cImeF )
      ENDIF

   ELSE
      IF Right( cImeF, 4 ) <> "." + DBFEXT
         cImeF := cImeF + "." + DBFEXT
      ENDIF
      cKomanda := cPath
      cPath := ""
   ENDIF

   nLinija := 0
   cDBF := ""

   PRIVATE fBrisiDBF := .F.
   PRIVATE fRenameDBF := .F.

   fprom := .F.
   nProlaza := 0

   DO WHILE fString .OR. !FEOF( nH )
      ++nLinija
      IF fString
         IF nProlaza = 0
            cLin := "*" + cImeF
            nProlaza++
         ELSEIF nProlaza = 1
            cLin := cKomanda
            nProlaza++
         ELSE
            EXIT
         ENDIF
      ELSE
         cLin := FReadLN( nH, 1, 200 )
         cLin := Left( cLin, Len( cLin ) -2 )
      ENDIF

      IF Empty( cLin ) .OR.  Left( cLin, 1 ) == ";"
         LOOP
      ENDIF

      IF Left( cLin, 1 ) = "*"
         kopi( fProm )
         cLin := SubStr( cLin, 2, Len( Trim( clin ) ) -1 )
         cDbf := AllTrim( cLin )
         ? cPath + cDbf
         cDbf := Upper( cDbf + iif( At( ".", cDbf ) <> 0, "", ".DBF" ) )
         IF File( cPath + cDbf )
            SELECT 1
            USE_EXCLUSIVE( cPath + cDbf ) ALIAS olddbf
         ELSE
            cDbf := "*"
            ?? "  Ne nalazi se u direktorijumu"
         ENDIF
         fProm := .F.   // flag za postojanje promjena u strukturi dbf-a
         aStru := dbStruct()
         aNStru := AClone( aStru )      // nova struktura
      ELSE  // funkcije za promjenu polja
         IF Empty( cDBF )
            ? "Nije zadat DBF fajl nad kojim se vrsi modifikacija strukture !"
            QUIT
         ELSEIF cDbf == "*"
            LOOP // preskoci
         ENDIF

         cOp := f01_rjec( @cLin )

         IF AllTrim( cOp ) == "IZBRISIDBF"
            fBrisiDbf := .T.
         ELSEIF AllTrim( cOp ) == "IMEDBF"
            fRenameDBF := .T.
            cImeP := f01_rjec( @cLin )
         ELSEIF AllTrim( cOp ) == "A"
            cImeP := f01_rjec( @cLin )
            cTip := f01_rjec( @cLin )
            cLen := f01_rjec( @cLin ); nLen := Val( cLen )
            cDec := f01_rjec( @cLin ); nDec := Val( cDec )
            IF !( nLen > 0 .AND. nLen > nDec ) .OR. ( cTip = "C" .AND. nDec > 0 ) .OR. !( cTip $ "CNDM" )
               ? "Greska: Dodavanje polja, linija:", nLinija
               LOOP
            ENDIF
            nPos = AScan( aStru, {| x| x[ 1 ] == cImep } )
            IF npos <> 0
               ? "Greska: Polje " + cImeP + " vec postoji u DBF-u, linija:", nlinija
               LOOP
            ENDIF
            ? "Dodajem polje:", cImeP, cTip, nLen, nDec
            AAdd( aNStru, { cImeP, cTip, nLen, nDec } )
            fProm := .T.

         ELSEIF AllTrim( cOp ) == "D"
            cImeP := Upper( f01_rjec( @cLin ) )
            nPos := AScan( aNStru, {| x| x[ 1 ] == cImeP } )
            IF nPos <> 0
               ? "Brisem polje:", cImeP
               ADel( aNStru, nPos )
               f01_prepakuj( @aNstru )  // prepakuj array
               fProm := .T.
            ELSE
               ? "Greska: Brisanje nepostojeceg polja, linija:", nLinija
            ENDIF

         ELSEIF AllTrim( cOp ) == "C"
            cImeP1 := Upper( f01_rjec( @cLin ) )
            cTip1 := f01_rjec( @cLin )
            cLen := f01_rjec( @cLin ); nLen1 := Val( cLen )
            cDec := f01_rjec( @cLin ); nDec1 := Val( cDec )
            nPos := AScan( aStru, {| x| x[ 1 ] == cImeP1 .AND. x[ 2 ] == cTip1 .AND. x[ 3 ] == nLen1 .AND. x[ 4 ] == nDec1 } )
            IF nPos == 0
               ? "Greska: zadana je promjena nepostojeceg polja, linija:", nLinija
               LOOP
            ENDIF
            cImeP2 := Upper( f01_rjec( @cLin ) )
            cTip2 := f01_rjec( @cLin )
            cLen := f01_rjec( @cLin ); nLen2 := Val( cLen )
            cDec := f01_rjec( @cLin ); nDec2 := Val( cDec )

            nPos2 := AScan( aStru, {| x| x[ 1 ] == cImep2 } )
            IF nPos2 <> 0 .AND. cImeP1 <> cImeP2
               ? "Greska: zadana je promjena u postojece polje, linija:", nLinija
               LOOP
            ENDIF
            fIspr := .F.
            IF cTip1 == cTip2
               fispr := .T.
            ENDIF
            IF ( cTip1 == "N" .AND. cTip2 == "C" )   ;  fispr := .T. ; ENDIF
            IF ( cTip1 == "C" .AND. cTip2 == "N" )   ;  fispr := .T. ; ENDIF
            IF ( cTip1 == "C" .AND. cTip2 == "D" )   ;  fispr := .T. ; ENDIF
            IF !fispr; ? "Greska: Neispravna konverzija, linija:", nLinija; loop; ENDIF

            AAdd( aStru[ nPos ], cImeP2 )
            AAdd( aStru[ nPos ], cTip2 )
            AAdd( aStru[ nPos ], nLen2 )
            AAdd( aStru[ nPos ], nDec2 )

            nPos := AScan( aNStru, {| x| x[ 1 ] == cImeP1 .AND. x[ 2 ] == cTip1 .AND. x[ 3 ] == nLen1 .AND. x[ 4 ] == nDec1 } )
            aNStru[ nPos ] := { cImeP2, cTip2, nLen2, nDec2 }

            ? "Vrsim promjenu:", cImep1, cTip1, nLen1, nDec1, " -> ", cImep2, cTip2, nLen2, nDec2
            // npr {"POLJE1", "C", 10, 0} =>
            // {"POLJE1", "C", 10, 0,"POLJE1NEW", "C", "15", 0}

            fProm := .T.
         ELSE
            ? "Greska: Nepostojeca operacija, linija:", nLinija
         ENDIF
      ENDIF // fje za promjenu polja

   ENDDO
   kopi( fProm )

   cmxAutoOpen( .T. )

   RETURN


FUNCTION f01_add_field_brisano( cImeDbf )

   USE
   SAVE SCREEN TO cScr
   CLS
   f01_modstru( cImeDbf, "C H C 1 0  FH  C 1 0", .T. )
   f01_modstru( cImeDbf, "C SEC C 1 0  FSEC C 1 0", .T. )
   f01_modstru( cImeDbf, "C VAR C 2 0 FVAR C 2 0", .T. )
   f01_modstru( cImeDbf, "C VAR C 15 0 FVAR C 15 0", .T. )
   f01_modstru( cImeDbf, "C  V C 15 0  FV C 15 0", .T. )
   f01_modstru( cImeDbf, "A BRISANO C 1 0", .T. )  // dodaj polje "BRISANO"
   Inkey( 3 )
   RESTORE SCREEN FROM cScr

   SELECT ( F_TMP )
   USE_EXCLUSIVE( cImeDbf )

   RETURN
