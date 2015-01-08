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

STATIC s_cFileContent := NIL

/*  VidiFajl(cImeF, aLinFiks, aKolFiks)
 *   Pregled tekstualnog fajla
 *
 *
 * aLinFiks se zadaje ako treba fiksirati dio fajla (npr.zaglavlje tabele)
 * To je niz od dva elementa (prvi el.je broj prvog reda u fajlu, a drugi el.
 * je broj redova koje treba fiksirati)
 *
 * aKolFiks se zadaje ako treba fiksirati dio fajla (npr.kolonu u tabeli)
 * To je niz od tri elementa (prvi el.je broj prve kolone u fajlu, drugi el.
 * je broj kolona koje zaredom, pocevsi od prve zadane, treba fiksirati, a
 * treci el. predstavlja broj reda pocevsi od kojeg se uzima za prikaz
 * fiksirana kolona)
 */

FUNCTION VidiFajl( cImeF, aLinFiks, aKolFiks )

   LOCAL nDF := VelFajla( cImeF, 0 )
   LOCAL nKol := 1
   LOCAL nOfset, nOf1l := 0, nZnak
   LOCAL lNevazna := .F.
   LOCAL nRed := 1
   LOCAL lSkrol := .F.
   LOCAL nURed := BrLinFajla( cImeF )
   LOCAL cKom, nLin := 21, nFRed := 0, nFRed2 := 0
   LOCAL cFajlPRN := "PRN777.TXT", nOfM1 := 0, nOfM2 := 0
   LOCAL nPrviRed := 1
   LOCAL aZagFix := {}
   LOCAL nPrvaKol := 0
   LOCAL nUKol := 80
   LOCAL aRedovi
   LOCAL lPrintReady

   PRIVATE cTrazi := Space( 30 )
   PRIVATE cMarkF := "1"
   PRIVATE cVStamp := "1"
   PRIVATE nStrOd := 1
   PRIVATE nStrDo := 1

   init_file_content()

   CSetAtMupa( .T. )

   IF aLinFiks != nil
      nPrviRed += aLinFiks[ 2 ]
      aZagFix  := DioFajlaUNiz( cImeF, aLinFiks[ 1 ], aLinFiks[ 2 ], nURed )
   ENDIF
   IF aKolFiks != nil
      nPrvaKol := aKolFiks[ 2 ]
      nUKol    := 80 - aKolFiks[ 2 ]
   ENDIF

   aRedovi := Array( nLin + 1 -nPrviRed, 2 )
   ShemaBoja( gShemaVF )
   @ 22, 0 SAY "Pomjeranje slike.......<>.<>.<>.<" + Chr( 26 ) + ">." + ;
      "<PgUp>.<PgDn>.<Ctrl>+<PgUp>.<Ctrl>+<PgDn>" COLOR cbokvira

   @ 23, 0 SAY "N.fajla:<Ctrl>+<N> Stampa:<Ctrl>+<P>,<Alt>+<P> Trazi:<F>/<F3> Marker:<Ctrl>+<J> " COLOR cbnaslova
   @ 24, 0 SAY "Pr.fajla:<Ctrl>+<O>     FAJL:                 KOLONA:         RED:              " COLOR cbnaslova
   DO WHILE .T.
      nOfset := nOf1l
      IF !lNevazna
         @ 24, 54 SAY Str( nKol, 3 ) + "/321" COLOR cbokvira
         @ 24, 67 SAY PadR( AllTrim( Str( nRed, 6 ) ) + "/" + AllTrim( Str( nURed, 6 ) ), 13 ) COLOR cbokvira
         @ 24, 30 SAY PadR( AfterAtNum( SLASH, cImeF ), 15 ) COLOR cbokvira
         IF Len( aZagFix ) > 0
            FOR i := 1 TO Len( aZagFix )
               IF nPrvaKol > 0
                  @ i,       0 SAY SubStr( PadR( aZagFix[ i ], 400 ), aKolFiks[ 1 ], nPrvaKol ) COLOR "W+/B"
                  @ i, nPrvaKol SAY SubStr( PadR( aZagFix[ i ], 400 ), nKol + IF( aKolFiks[ 1 ] > 1, 0, nPrvaKol ), nUKol ) COLOR "W+/B"
               ELSE
                  @ i, 0 SAY SubStr( PadR( aZagFix[ i ], 400 ), nKol, 80 ) COLOR "W+/B"
               ENDIF
            NEXT
         ENDIF

         FOR i := 1 to ( nLin + 1 - nPrviRed )

            IF !lSkrol
               aPom := SljedLin( cImeF, nOfset )
               aRedovi[ i ] := aPom
            ELSE
               aPom := aRedovi[ i ]
            ENDIF
            IF nPrvaKol > 0
               IF Len( aKolFiks ) > 3
                  cPom77 := aKolFiks[ 4 ]
                  @ i - 1 + nPrviRed, 0 SAY iif( !&cPom77, Space( nPrvaKol ), SubStr( PadR( aRedovi[ i, 1 ], 400 ), aKolFiks[ 1 ], nPrvaKol ) ) COLOR IF( nRed + i - 1 == nFRed, "W+/B", IF( nRed + i - 1 == nFRed2, "W+/R", cbteksta ) )
               ELSE
                  @ i - 1 + nPrviRed, 0 SAY iif( nRed + i - 1 < aKolFiks[ 3 ], Space( nPrvaKol ), SubStr( PadR( aRedovi[ i, 1 ], 400 ), aKolFiks[ 1 ], nPrvaKol ) ) COLOR IF( nRed + i - 1 == nFRed, "W+/B", IF( nRed + i - 1 == nFRed2, "W+/R", cbteksta ) )
               ENDIF
               @ i - 1 + nPrviRed, nPrvaKol SAY SubStr( PadR( aRedovi[ i, 1 ], 400 ), nKol + IF( aKolFiks[ 1 ] > 1, 0, nPrvaKol ), nUKol ) COLOR IF( nRed + i - 1 == nFRed, "W+/B", IF( nRed + i - 1 == nFRed2, "W+/R", cbteksta ) )
            ELSE
               @ i - 1 + nPrviRed, 0 SAY SubStr( PadR( aRedovi[ i, 1 ], 400 ), nKol, 80 ) COLOR IF( nRed + i - 1 == nFRed, "W+/B", IF( nRed + i - 1 == nFRed2, "W+/R", cbteksta ) )
            ENDIF
            nOfset := aPom[ 2 ]
         NEXT

      ENDIF

      lNevazna := .F.
      lSkrol := .F.

      KeyboardEvent( @nZnak )

      DO CASE
      CASE nZnak == 32         // svicuj zamrzavanje kolone
         IF nUKol < 80
            nPrvaKol := iif( nPrvaKol > 0, 0, aKolFiks[ 2 ] )
         ENDIF

      CASE nZnak == K_ESC
         EXIT
      CASE nZnak == K_CTRL_J  // pomjeri marker

         nPom1 := nFRed
         nPom2 := nFRed2
         nPom3 := nURed
         IF VarEdit( { { "Pozicija 1.(plavog) markera (broj reda)", "nPom1", "nPom1<=nPom3.and.nPom1>=0", "9999999", }, ;
               { "Pozicija 2.(crvenog) markera (broj reda)", "nPom2", "nPom2<=nPom3.and.nPom2>=0", "9999999", } }, 10, 1, 15, 78, ;
               "POMJERANJE MARKERA TEKSTA U FAJLU", gShemaVF )
            nPomRed := 1; nOfPom := 0; nOfM1 := 0; nOfM2 := 0
            DO WHILE nPomRed <= Max( nPom1, nPom2 ) .AND. nPomRed <= nURed
               aPom := SljedLin( cImeF, nOfPom )
               ++nPomRed
               nOfPom := aPom[ 2 ]
               IF nPomRed == nPom1
                  nOfM1 := nOfPom
               ELSEIF nPomRed == nPom2
                  nOfM2 := nOfPom
               ENDIF
            ENDDO
            nFRed  := nPom1
            nFRed2 := nPom2
         ENDIF

      CASE Upper( Chr( nZnak ) ) == 'F' .OR. nZnak == K_F3  // trazi tekst
         IF nZnak == K_F3 .OR. ;
               VarEdit( { ;
               { "Tekst", "cTrazi",, "@!", }, ;
               { "Oznaciti nadjeno markerom (1-plavi,2-crveni)", "cMarkF", "cMarkF$'12'", "", };
               }, 10, 10, 15, 69, ;
               "PRETRAGA TEKSTA U FAJLU", gShemaVF )
            aStaro := { nOf1l, nRed }
            IF cMarkF == "1" .AND. Upper( Chr( nZnak ) ) == 'F'
               nFRed := 0
            ELSEIF Upper( Chr( nZnak ) ) == 'F'
               nFRed2 := 0
            ENDIF
            IF Upper( Chr( nZnak ) ) == 'F' .OR. ;
                  cMarkF == "1" .AND. PripadaNInt( nFRed, nRed, nRed + 19 ) .OR. ;
                  cMarkF == "2" .AND. PripadaNInt( nFRed2, nRed, nRed + 19 )
               FOR i := IF( nZnak == K_F3, iif( cMarkF == "1", nFRed, nFRed2 ) -nRed + 2, 1 ) TO nLin + 1 -nPrviRed
                  IF ( nFPoz := At( Trim( cTrazi ), Upper( aRedovi[ i, 1 ] ) ) ) > 0
                     IF cMarkF == "1"
                        nFRed := nRed + i - 1
                        nOfM1 := IF( i == 1, nOf1l, aRedovi[ i - 1, 2 ] )
                     ELSE
                        nFRed2 := nRed + i - 1
                        nOfM2:I = IF( i == 1, nOf1l, aRedovi[ i - 1, 2 ] )
                     ENDIF
                     IF nFPoz < 40
                        nKol := 1

                     ELSEIF nFPoz > 360
                        nKol := 321
                     ELSE
                        nKol := 10 * Int( ( nFPoz - 40 ) / 10 ) + 1
                     ENDIF

                     lSkrol := .T.
                     EXIT
                  ENDIF
               NEXT
            ENDIF

            DO WHILE !lSkrol .AND. nRed < nURed - nLin + 1 -1 + nPrviRed
               ++nRed
               aPom := SljedLin( cImeF, aRedovi[ nLin + 1 -nPrviRed, 2 ] )
               nOf1l := aRedovi[ 1, 2 ]; ADel( aRedovi, 1 ); aRedovi[ nLin + 1 -nPrviRed ] := aPom
               IF nZnak == K_F3 .AND. ;
                     iif( cMarkF == "1", nFRed >= nRed + nLin - 1 + 1 -nPrviRed, nFRed2 >= nRed + nLin - 1 + 1 -nPrviRed )
                  LOOP
               ENDIF
               IF ( nFPoz := At( Trim( cTrazi ), Upper( aRedovi[ nLin + 1 -nPrviRed, 1 ] ) ) ) > 0
                  lSkrol := .T.
                  IF cMarkF == "1"
                     nFRed := nRed + nLin - 1 + 1 -nPrviRed
                     nOfM1 := aRedovi[ nLin - 1 + 1 -nPrviRed, 2 ]
                  ELSE
                     nFRed2 := nRed + nLin - 1 + 1 -nPrviRed
                     nOfM2 := aRedovi[ nLin - 1 + 1 -nPrviRed, 2 ]
                  ENDIF
                  IF nFPoz < 40
                     nKol := 1
                  ELSEIF nFPoz > 360
                     nKol := 321
                  ELSE
                     nKol := 10 * Int( ( nFPoz - 40 ) / 10 ) + 1
                  ENDIF
               ENDIF
            ENDDO
            IF iif( cMarkF == "1", nFRed == 0, nFRed2 == 0 )  // vrati se na staru poziciju
               nOf1l := aStaro[ 1 ]; nRed := aStaro[ 2 ]
               lSkrol := .F.
               Msg( "Tekst nije nadjen!", 4 )
            ENDIF
         ENDIF

      CASE nZnak == K_ALT_F1  // spremi tekucu i/ili vise baza na diskete
         // na koji disk
         cDisk := "A"
         Box(, 3, 77 )
         @ m_x + 1, m_y + 2 SAY "Izvrsiti prenos na disk A/B ?" GET cDisk PICT "@!" VALID cDisk >= "A" .AND.  diskprazan( cDisk )
         READ
         BoxC()

         IF LastKey() != K_ESC

            // koje baze
            IF aDefSpremBaz != NIL .AND. !Empty( aDefSpremBaz )     // vise njih
               nTekArr := Select()
               FOR i := 1 TO Len( aDefSpremBaz )
                  SELECT ( aDefSpremBaz[ i, 1 ] )
                  cPomFilt := aDefSpremBaz[ i, 4 ]
                  PushWA()
                  SET FILTER TO
                  SET FILTER to &cPomFilt
                  GO TOP
                  MsgO( "Kopiram '" + Alias( Select() ) + ".DBF' u '" + cDisk + ":" + SLASH + "_" + Alias( Select() ) + ".DBF" + "' !" )
                  CurToExtBase( cDisk + ":" + SLASH + "_" + Alias( Select() ) + ".DBF" )
                  MsgC()
                  SET FILTER TO
                  PopWA()
               NEXT
               SELECT ( nTekArr )
            ENDIF

            // odradi tekucu
            ccPom := cDisk + ":" + SLASH + "_" + Alias( Select() )
            PushWA(); GO TOP
            MsgO( "Kopiram '" + Alias( Select() ) + ".DBF' u '" + cDisk + ":" + SLASH + "_" + Alias( Select() ) + ".DBF" + "' !" )
            CurToExtBase( cDisk + ":" + SLASH + "_" + Alias( Select() ) + ".DBF" )
            MsgC()
            SET FILTER TO
            PopWA()

            // zapisi skript fajl

            MsgBeep( "Kopiranje zavrseno!" )
         ENDIF  // LASTKEY()!=K_ESC

      CASE nZnak == K_CTRL_O
         // ucitaj fajl
         nPom := RAt( SLASH, cImeF )
         DO WHILE .T.
            ccPom := PadR( SubStr( cImeF, nPom + 1 ), 12 )
            IF VarEdit( { { "Fajl", "ccPom",, "@!", } }, 10, 20, 14, 59, "NAZIV FAJLA ZA PREGLED", gShemaVF )
               ccPom := AllTrim( Left( cImeF, nPom ) + ccPom )
               IF File2( ccPom )
                  cImeF := ccPom
                  nPom := RAt( SLASH, cImeF )
                  nDF := VelFajla( cImeF, 0 ); nKol := 1; nOf1l := 0; lNevazna := .F.
                  nRed := 1; lSkrol := .F. ; nURed := BrLinFajla( cImeF )
                  aRedovi := Array( nLin + 1 -nPrviRed, 2 )
                  EXIT
               ELSE
                  Msg( "Zadani fajl ne postoji!", 4 )
               ENDIF
            ELSE
               EXIT
            ENDIF
         ENDDO

      CASE ( nZnak == K_LEFT .AND. nKol > 1 )
         lSkrol := .T.
         nKol -= 10

      CASE ( nZnak == K_RIGHT .AND. nKol < 321 )
         lSkrol := .T.
         nKol += 10

      CASE nZnak == K_UP .AND. nRed > 1
         lSkrol := .T.
         aPom := PrethLin( cImeF, nOf1l )
         --nRed
         AIns( aRedovi, 1 )
         aRedovi[ 1 ] := { aPom[ 1 ], nOf1l }
         nOf1l := iif( aPom[ 2 ] <= 0, 0, aPom[ 2 ] )

      CASE nZnak == K_DOWN .AND. nRed < nURed - nLin + 1 -1 + nPrviRed

         lSkrol := .T.
         ++nRed
         aPom := SljedLin( cImeF, aRedovi[ nLin + 1 -nPrviRed, 2 ] )
         nOf1l := aRedovi[ 1, 2 ]
         ADel( aRedovi, 1 )
         aRedovi[ nLin + 1 -nPrviRed ] := aPom

      CASE nZnak == K_PGUP .AND. nRed > 1
         IF nRed - nLin - 1 + nPrviRed > 1
            lSkrol := .T.
            FOR i := 1 TO nLin + 1 -nPrviRed
               aRedovi[ nLin + 1 + 1 -nPrviRed - i, 2 ] := IF( i == 1, nOf1l, aPom[ 2 ] )
               aPom := PrethLin( cImeF, nOf1l )
               nOf1l := aPom[ 2 ]
               aRedovi[ nLin + 1 + 1 -nPrviRed - i, 1 ] := aPom[ 1 ]
            NEXT
            nRed -= nLin + 1 -nPrviRed
            IF nOf1l <= 0; nOf1l := 0; nRed := 1; ENDIF
         ELSE
            nRed := 1
            nOf1l := 0
         ENDIF

      CASE nZnak == K_PGDN .AND. nRed < nURed - nLin + 1 -1 + nPrviRed
         IF nRed + nLin + 1 -nPrviRed <= nUred - nLin + 1 -1 + nPrviRed
            nOf1l := aRedovi[ nLin + 1 -nPrviRed, 2 ]
            nRed += nLin + 1 -nPrviRed
         ELSE
            nOf1l := aRedovi[ nURed - nLin + 1 -1 + nPrviRed - nRed, 2 ]
            nRed := nURed - nLin + 1 -1 + nPrviRed
         ENDIF
      CASE ( nZnak == K_CTRL_PGUP .OR. nZnak == K_HOME ) .AND. nRed > 1
         nOf1l := 0; nRed := 1
      CASE ( nZnak == K_CTRL_PGDN .OR. nZnak == K_END ) .AND. nURed > nLin + 1 -nPrviRed
         nOf1l := nDF + 2
         FOR i := 1 TO iif( FileStr( cImeF, 2, nDF - 2 ) != NOVI_RED, nLin + 1 -nPrviRed, nLin + 1 + 1 -nPrviRed )
            IF nOf1l > 0
               aPom := PrethLin( cImeF, nOf1l )
               nOf1l := aPom[ 2 ]
            ENDIF
         NEXT
         nRed := nURed - nLin + 1 -1 + nPrviRed

      CASE nZnak == K_CTRL_N
         nPom := RAt( SLASH, cImeF )
         DO WHILE .T.
            ccPom := PadR( SubStr( cImeF, nPom + 1 ), 12 )
            IF VarEdit( { { "Fajl", "ccPom",, "@!", } }, 10, 20, 14, 59, "PROMJENA NAZIVA FAJLA", gShemaVF )
               ccPom := AllTrim( Left( cImeF, nPom ) + ccPom )
               IF RenameFile( cImeF, ccPom ) == 0
                  cImeF := ccPom
                  nPom := RAt( SLASH, cImeF )
                  EXIT
               ENDIF
            ELSE
               EXIT
            ENDIF
         ENDDO
      CASE gPrinter = "R" .AND. ( nZnak = K_CTRL_P .OR. nZnak == K_ALT_P )

         IF gPDFPrint == "X" .AND. goModul:oDataBase:cName == "FAKT"
            IF Pitanje(, "Print u PDF/PTXT", "D" ) == "D"
               PDFView( cImeF )
            ELSE
               Ptxt( cImeF )
            ENDIF
         ELSEIF gPDFPrint == "D" .AND. goModul:oDataBase:cName == "FAKT"
            PDFView( cImeF )
         ELSE
            Ptxt( cImeF )
         ENDIF

      CASE nZnak == K_ALT_S
         SendFile( cImeF )

      CASE nZnak == K_CTRL_P

         IF nFRed > 0 .AND. nFRed2 > 0   // oba markera
            IF VarEdit( { { "1-sve, 2-dio izmedju markera, 3-sve ispod mark.1, 4-sve ispod mark.2)", "cVStamp", "cVStamp$'1234'", "@!", } }, 10, 1, 14, 78, ;
                  "IZBOR OBLASTI ZA STAMPANJE", gShemaVF )
            ELSE
               LOOP
            ENDIF
         ELSEIF nFRed > 0       // marker 1 (plavi)
            IF VarEdit( { { "1-sve,  3-sve ispod markera 1", "cVStamp", "cVStamp$'13'", "@!", } }, 10, 1, 14, 78, ;
                  "IZBOR OBLASTI ZA STAMPANJE", gShemaVF )
            ELSE
               LOOP
            ENDIF
         ELSEIF nFRed2 > 0      // marker 2 (crveni)
            IF VarEdit( { { "1-sve,  4-sve ispod markera 2", "cVStamp", "cVStamp$'14'", "@!", } }, 10, 1, 14, 78, ;
                  "IZBOR OBLASTI ZA STAMPANJE", gShemaVF )
            ELSE
               LOOP
            ENDIF
         ELSE // citav fajl
            cVStamp := "1"
         ENDIF

         IF cVStamp == "1"
            cFajlPRN := AllTrim( cImeF )
         ELSE
            cFajlPRN := "PRN777.TXT"
            IF File2( cFajlPRN )
               FErase( cFajlPRN )
            ENDIF
            nOfPoc := iif( cVStamp == "2", Min( nOfM1, nOfM2 ),;
               iif( cVStamp == "3", nOfM1, nOfM2 ) )
            nOfDuz := iif( cVStamp == "2", Abs( nOfM1 - nOfM2 ) + 1,;
               iif( cVStamp == "3", nDF - nOfM1 + 1, nDF - nOfM2 + 1 ) )
            nH := FCreate( cFajlPRN, 0 )
            DO WHILE nOfDuz > 0
               cPomF := FileStr( cImeF, iif( nOfDuz >= 400, 400, nOfDuz ), nOfPoc )
               FWrite( nH, cPomF )
               nOfPoc += 400
               nOfDuz -= 400
            ENDDO
            FWrite( nH, NOVI_RED )
            FClose( nH )
         ENDIF

         cKom := "LPT" + gPPort
         IF gPPort > "4"
            lPrintReady := .T.
            IF gPPort == "5"
               cKom := "LPT1"

            ELSEIF gPPort == "6"
               ckom := "LPT2"
            ELSEIF gPPort == "7"
               cKom := "LPT3"
            ENDIF
         ELSE
            lPrintReady := .F.
         ENDIF

         // cPom:=cFajlPRN+" "+cKom
         DO WHILE .T.
            IF lPrintReady .OR. PrintReady( Val( gpport ) )
               MsgO( "Sacekajte, stampanje u toku..." )
               FileCopy( cFajlPRN, cKom )
               MsgC()
               EXIT
            ENDIF
            IF Pitanje(, "Stampac nije spreman! Zelite li da probate ponovo?", "N" ) != "D"
               EXIT
            ENDIF
         ENDDO
      CASE nZnak == K_ALT_P
         IF VarEdit( { { "Stampati od stranice br.", "nStrOd", "nStrOd>0", "9999", }, ;
               { "         do stranice br.", "nStrDo", "nStrDo>=nStrOd", "9999", } }, 10, 1, 15, 78, ;
               "IZBOR STRANICA ZA STAMPANJE", gShemaVF )
         ELSE
            LOOP
         ENDIF

         cFajlPRN := "PRN777.TXT"
         IF File2( cFajlPRN )
            FErase( cFajlPRN )
         ENDIF

         aPom   := VratiOfset( gPFF, nStrOd - 1, nStrDo, cImeF, nDF )
         nOfPoc := aPom[ 1 ]
         nOfDuz := 1 + aPom[ 2 ] -aPom[ 1 ]

         nH := FCreate( cFajlPRN, 0 )
         FWrite( nH, gPINI )
         DO WHILE nOfDuz > 0
            cPomF := FileStr( cImeF, iif( nOfDuz >= 400, 400, nOfDuz ), nOfPoc )
            FWrite( nH, cPomF )
            nOfPoc += 400
            nOfDuz -= 400
         ENDDO
         FWrite( nH, NOVI_RED )
         FClose( nH )

         cKom := "LPT" + gPPort
         IF gpport > "4"
            IF gpport == "5"
               cKom := "LPT1"
            ELSEIF gpport == "6"
               ckom := "LPT2"
            ELSEIF gpport == "7"
               cKom := "LPT3"
            ENDIF
         ENDIF
         // cPom:=cFajlPRN+" "+cKom
         DO WHILE .T.
            IF PrintReady( Val( gpport ) )
               MsgO( "Sacekajte, stampanje u toku..." )
               // !copy &cPom
               FileCopy( cFajlPRN, cKom )
               MsgC()
               EXIT
            ENDIF
            IF Pitanje(, "Stampac nije spreman! Zelite li da probate ponovo?", "N" ) != "D"
               EXIT
            ENDIF
         ENDDO
      OTHERWISE
         goModul:GProc( nZnak )
         lNevazna := .T.
      ENDCASE
   ENDDO

   RETURN


FUNCTION init_file_content()

   s_cFileContent := NIL

   RETURN .T.


FUNCTION get_file_content( cFajl, nPocetak )

   IF s_cFileContent == NIL
      s_cFileContent := FileStr( cFajl, NIL )
   ENDIF

   IF nPocetak == NIL
      nPocetak := 0
   ENDIF

   RETURN SubStr( s_cFileContent, nPocetak )


FUNCTION SljedLin( cFajl, nPocetak )

   LOCAL cPom, nPom

   cPom := get_file_content( cFajl, nPocetak )

   nPom := At( NOVI_RED, cPom )

   IF nPom == 0
      nPom := Len( cPom ) + 1
   ENDIF

   RETURN { Left( cPom, nPom - 1 ), nPocetak + nPom + 1 }    // {cLinija,nPocetakSljedece}


FUNCTION PrethLin( cFajl, nKraj )

   LOCAL nKor := 400, cPom, nPom

   IF nKraj - nKor - 2 < 0; nKor := nKraj - 2; ENDIF

   cPom := FileStr( cFajl, nKor, nKraj - nKor - 2 )
   nPom := RAt( NOVI_RED,cPom )

   RETURN iif( nPom == 0, { cPom, 0 }, { SubStr( cPom, nPom + 2 ), nKraj - nKor + nPom - 1 } )

   RETURN


FUNCTION BrLinFajla( cImeF )

   LOCAL nOfset := 0, nSlobMem := 0, cPom := "", nVrati := 0

   IF FileStr( cImeF, 2, VelFajla( cImeF ) - 2 ) != NOVI_RED
      nVrati := 1
   ENDIF

   DO WHILE Len( cPom ) >= nSlobMem

      // nSlobMem:=MEMORY(1)*1024-100
      nSlobMem := 1024

      cPom := FileStr( cImeF, nSlobMem, nOfset )
      nOfset := nOfset + nSlobMem - 1
      nVrati := nVrati + NumAt( NOVI_RED, cPom )

   ENDDO

   RETURN nVrati


FUNCTION VelFajla( cImeF, cAttr )

   LOCAL aPom := Directory( cImeF, cAttr )

   RETURN iif ( !Empty( aPom ), aPom[ 1, 2 ], 0 )





FUNCTION PripadaNInt( nBroj, nOd, nDo, lSaKrajnjim )

   LOCAL lVrati := .F.

   IF lSaKrajnjim == nil; lSaKrajnjim := .T. ; ENDIF
   IF lSaKrajnjim .AND. nBroj >= nOd .AND. nBroj <= ndo .OR. ;
         nBroj > nOd .AND. nBroj < nDo
      lVrati := .T.
   ENDIF

   RETURN lVrati



FUNCTION DioFajlaUNiz( cImeF, nPocRed, nUkRedova, nUkRedUF )

   LOCAL aVrati := {}, nTekRed := 0, nOfset := 0, aPom := {}

   IF nUkRedUF == nil
      nUkRedUF := BrLinFajla( cImeF )
   ENDIF

   FOR nTekRed := 1 TO nUkRedUF
      aPom := SljedLin( cImeF, nOfset )
      IF nTekRed >= nPocRed .AND. nTekRed < nPocRed + nUkRedova
         AAdd( aVrati, aPom[ 1 ] )
      ENDIF
      IF nTekRed >= nPocRed + nUkRedova - 1
         EXIT
      ENDIF
      nOfset := aPom[ 2 ]
   NEXT

   RETURN aVrati


FUNCTION VratiOfset( cTrazeniTekst, nOdPojavljivanja, nDoPojavljivanja, cUFajlu, nVelicinaFajla )

   LOCAL nOfset := 0, aPom := {}, aOfsetOdDo := { 0, 0 }, nPojava := 0

   DO WHILE nVelicinaFajla > nOfset            // ?? mozda treba >nOfset+1
      aPom := SljedLin( cUFajlu, nOfset )
      IF cTrazeniTekst $ aPom[ 1 ]
         nPojava++
      ELSE
         nOfset := aPom[ 2 ]
         LOOP
      ENDIF
      IF nOdPojavljivanja > 0 .AND. nOdPojavljivanja == nPojava
         aOfsetOdDo[ 1 ] := nOfset + At( cTrazeniTekst, aPom[ 1 ] ) + Len( cTrazeniTekst ) - 1
      ENDIF
      IF nDoPojavljivanja == nPojava
         nOfset := nOfset + At( cTrazeniTekst, aPom[ 1 ] ) + Len( cTrazeniTekst ) - 2
         EXIT
      ENDIF
      nOfset := aPom[ 2 ]
   ENDDO
   aOfsetOdDo[ 2 ] := nOfset

   RETURN aOfsetOdDo


STATIC FUNCTION SendFile( cImeF )

   LOCAL cSendIme
   LOCAL cLokacija
   PRIVATE cKom

   cSendIme := PadR( "send", 8 )

   IF Pitanje(, "Izvrsiti snimanje izvjestaja - dokumenta ?", "D" ) == "N"
      RETURN
   ENDIF
   cLokacija := IzFmkIni( "FMK", "SendLokacija", ToUnix( "c:" + SLASH + "sigma" + SLASH + "send" ) )
   DirMak2( cLokacija )

   Box(, 3, 60 )
   @ m_x + 1, m_y + 2 SAY "Lokacija: FmkIni_KumPath/[FMK]/SendLokacija " + cLokacija
   @ m_x + 3, m_y + 2 SAY "Ime dokumenta je " GET cSendIme
   @ m_x + 3, Col() + 2 SAY ".txt"
   READ
   BoxC()
   IF ( LastKey() == K_ESC )
      RETURN 0
   ENDIF

   AddBs( @cLokacija )
   COPY File ( cImeF ) TO ( cLokacija + AllTrim( cSendIme ) + ".txt" )

   cKom := "start " + cLokacija
   RUN &cKom

   RETURN 1
