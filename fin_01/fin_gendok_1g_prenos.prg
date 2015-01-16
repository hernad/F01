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


#include "fin01.ch"


FUNCTION PrenosFin()

   LOCAL cStranaBitna
   LOCAL lStranaBitna

   PRIVATE fK1 := fk2 := fk3 := fk4 := "N"

   O_PARAMS
   PRIVATE cSection := "1"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}


   RPar( "k1", @fk1 )
   RPar( "k2", @fk2 )
   RPar( "k3", @fk3 )
   RPar( "k4", @fk4 )
   SELECT params
   USE

   PRIVATE cK1 := cK2 := "9"
   PRIVATE cK3 := cK4 := "99"

   IF IzFMKIni( "FIN", "LimitiPoUgovoru_PoljeK3", "N", SIFPATH ) == "D"
      ck3 := "999"
   ENDIF

   O_PKONTO
   P_PKonto()

   cStranaBitna := "N"
   cKlDuguje := "2"
   cKlPotraz := "5"

   Box(, 12, 60 )
   nMjesta := 3
   ddatDo := Date()

   @ m_x + 1, m_y + 2 SAY "Navedite koje grupacije konta se isto ponasaju:"
   @ m_x + 3, m_y + 2 SAY "Grupisem konte na (broj mjesta)" GET nMjesta PICT "9"
   @ m_x + 5, m_y + 2 SAY "Datum do kojeg se promet prenosi" GET dDatDo

   IF fk1 == "D"; @ m_x + 7, m_y + 2   SAY "K1 (9 svi) :" GET cK1; ENDIF
   IF fk2 == "D"; @ m_x + 7, Col() + 2 SAY "K2 (9 svi) :" GET cK2; ENDIF
   IF fk3 == "D"; @ m_x + 8, m_y + 2   SAY "K3 (" + ck3 + " svi):" GET cK3; ENDIF
   IF fk4 == "D"; @ m_x + 8, Col() + 1 SAY "K4 (99 svi):" GET cK4; ENDIF

   @ m_x + 9, m_y + 2 SAY "Klasa konta duguje " GET cKlDuguje PICT "9"
   @ m_x + 10, m_y + 2 SAY "Klasa konta potraz " GET cKlPotraz PICT "9"

   @ m_x + 12, m_y + 2 SAY "Saldo strane valute je bitan ?" GET cStranaBitna ;
      PICT "@!" ;
      VALID cStranaBitna $ "DN"

   READ
   ESC_BCR

   BoxC()

   lStranaBitna := ( cStranaBitna == "D" )

   IF ck1 == "9"; ck1 := ""; ENDIF
   IF ck2 == "9"; ck2 := ""; ENDIF
   IF ck3 == REPL( "9", Len( ck3 ) )
      ck3 := ""
   ELSE
      ck3 := k3u256( ck3 )
   ENDIF
   IF ck4 == "99"; ck4 := ""; ENDIF



   lPrenos4 := lPrenos5 := lPrenos6 := .F.
   SELECT ( F_PKONTO )
   GO TOP
   DO WHILE !Eof()
      IF tip == "4"; lPrenos4 := .T. ; ENDIF
      IF tip == "5"; lPrenos5 := .T. ; ENDIF
      IF tip == "6"; lPrenos6 := .T. ; ENDIF
      SKIP 1
   ENDDO


   cFilter := ".t."
   IF fk1 == "D" .AND. Len( ck1 ) <> 0
      cFilter += " .and. k1='" + ck1 + "'"
   ENDIF
   IF fk2 == "D" .AND. Len( ck2 ) <> 0
      cFilter += " .and. k2='" + ck2 + "'"
   ENDIF
   IF fk3 == "D" .AND. Len( ck3 ) <> 0
      cFilter += " .and. k3='" + ck3 + "'"
   ENDIF
   IF fk4 == "D" .AND. Len( ck4 ) <> 0
      cFilter += " .and. k4='" + ck4 + "'"
   ENDIF

   IF lPrenos4 .OR. lPrenos5 .OR. lPrenos6
      SELECT ( F_SUBAN )
      USE_EXCLUSIVE( cDirRad + SLASH + "suban" )
      IF lPrenos4
         INDEX ON idfirma + idkonto + idpartner + idrj + funk + fond TO SUBSUB
      ENDIF
      IF lPrenos5
         INDEX ON idfirma + idkonto + idpartner + idrj + fond TO SUBSUB5
      ENDIF
      IF lPrenos6
         INDEX ON idfirma + idkonto + idpartner + idrj TO SUBSUB6
      ENDIF
      USE
      SELECT ( F_SUBAN )
      USE_EXCLUSIVE( cDirRad + SLASH + "suban" )
      IF lPrenos4
         SET INDEX TO SUBSUB
         SET ORDER TO TAG "SUBSUB"
      ENDIF
      IF lPrenos5
         SET INDEX TO SUBSUB5
         SET ORDER TO TAG "SUBSUB5"
      ENDIF
      IF lPrenos6
         SET INDEX TO SUBSUB6
         SET ORDER TO TAG "SUBSUB6"
      ENDIF
   ELSE
      SELECT ( F_SUBAN )
      USE_EXCLUSIVE( cDirRad + SLASH + "suban" ); SET ORDER TO TAG "3"
   ENDIF

   IF !( cFilter == ".t." )
      SELECT ( F_SUBAN )
      SET FILTER TO &( cFilter )
   ENDIF

   SELECT ( F_PKONTO )
   USE_EXCLUSIVE( cDirSif + SLASH + "pkonto" ); SET ORDER TO TAG "ID"

   O_PRIPR
   IF reccount2() <> 0
      MsgBeep( "Priprema mora biti prazna" )
      closeret
   ENDIF
   zap; SET ORDER TO 0

   start PRINT cret
   ?
   ? "Prolazim kroz bazu...."
   SELECT suban
   GO TOP

   lVodeSeRJ := FieldPos( "IDRJ" ) > 0


   Postotak( 1, RECCOUNT2(), "Generacija pocetnog stanja" )
   nProslo := 0

   GO TOP
   // idfirma, idkonto, idpartner, datdok

   dDatVal := CToD( "" )

   // ----------------------------------- petlja 1
   DO WHILE !Eof()

      nRbr := ZadnjiRBR()
      cIdFirma := idfirma

      // ----------------------------------- petlja 2
      DO WHILE !Eof() .AND. cIdFirma == IdFirma

         cIdKonto := IdKonto
         cTipPr := "0" // tip prenosa
         SELECT pkonto; SEEK Left( cIdKonto, nMjesta )
         IF Found()        // 1 - otvorene stavke, 2 - saldo partnera,
            cTipPr := tip     // 3 - otv.st.bez sabiranja,
         ENDIF             // 4 - salda po konto+partner+rj+funkcija+fond
         // 5 - salda po konto+partner+rj+fond
         // 6 - salda po konto+partner+rj
         SELECT suban

         IF cTipPr == "4"    // mijenjam sort za ovu varijantu
            SET ORDER TO TAG "SUBSUB"
            SEEK cIdFirma + cIdKonto
         ELSEIF cTipPr == "5"    // mijenjam sort za ovu varijantu
            SET ORDER TO TAG "SUBSUB5"
            SEEK cIdFirma + cIdKonto
         ELSEIF cTipPr == "6"    // mijenjam sort za ovu varijantu
            SET ORDER TO TAG "SUBSUB6"
            SEEK cIdFirma + cIdKonto
         ELSEIF lPrenos4 .OR. lPrenos5 .OR. lPrenos6   // standardni sort
            SET ORDER TO TAG "3"
            SEEK cIdFirma + cIdKonto
         ENDIF

         nDin := nDem := 0
         // KONTO....pocinje

         // ----------------------------------- petlja 3
         DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdKonto == IdKonto

            cIdPartner := IdPartner
            ? "Konto:", cidkonto, "    Partner:", cidpartner
            IF cTipPr $ "2"    // sabirem po konto+partner
               nDin := 0; nDem := 0
            ENDIF

            IF ctippr == "3"
               cSUBk1 := k1
               cSUBk2 := k2
               cSUBk3 := k3
               cSUBk4 := k4

               IF Otvst == " "
                  Scatter()
                  SELECT pripr
                  APPEND BLANK
                  Gather()
                  REPLACE rbr WITH Str( ++nRbr, 4 ), ;
                     idvn WITH "00", ;
                     brnal WITH "00000001"

                  SELECT suban
               ENDIF
               Postotak( 2, ++nProslo )
               SKIP 1
            ELSE // tipppr=="3#

               cSUBk1 := k1; cSUBk2 := k2; cSUBk3 := k3; cSUBk4 := k4

               // ----------------------------------- petlja 4
               DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdKonto == IdKonto .AND. IdPartner == cIdPartner

                  cSUBk1 := k1; cSUBk2 := k2; cSUBk3 := k3; cSUBk4 := k4

                  IF cTipPr == "1"
                     cBrDok := Brdok
                     nDin := 0
                     nDem := 0
                     cOtvSt := otvSt // pretpostavlja se da sve stavke jednog
                     // dokumenta imaju isti znak - otvoren ili zatvoren
                     cTekucaRJ := ""
                     // ----------------------------------- petlja 5
                     dDatVal := CToD( "" )
                     DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdKonto == IdKonto .AND. IdPartner == cIdPartner .AND. BrDok == cBrDok

                        IF Empty( dDatVal )

                           // konto kupaca
                           IF ( Left( IdKonto, 1 ) == cKlDuguje ) .AND. ( d_p == "1" )
                              IF IsVindija()
                                 IF Empty( DatVal ) .AND. !( IsVindija() .AND. idvn == "09" )
                                    dDatVal := datdok
                                 ELSE
                                    dDatVal := datval
                                 ENDIF
                              ELSE
                                 IF Empty( DatVal )
                                    dDatVal := datdok
                                 ELSE
                                    dDatVal := datval
                                 ENDIF
                              ENDIF
                           ENDIF

                           // konto dobavljaca
                           IF ( Left( IdKonto, 1 ) == cKlPotraz ) .AND. ( d_p == "2" )
                              IF Empty( DatVal )
                                 dDatVal := datdok
                              ELSE
                                 dDatVal := datval
                              ENDIF
                           ENDIF


                        ENDIF

                        nDin += iif( d_p == "1", iznosbhd, -iznosbhd )
                        nDem += iif( d_p == "1", iznosdem, -iznosdem )

                        IF lVodeSeRJ .AND. Empty( cTekucaRJ )
                           cTekucaRJ := IDRJ
                        ENDIF
                        Postotak( 2, ++nProslo )
                        SKIP 1

                     ENDDO // brdok
                     // ----------------------------------- petlja 5

                     // if cOtvSt=="9"
                     IF Round( nDin, 3 ) <> 0  // ako saldo nije 0
                        SELECT pripr
                        APPEND BLANK
                        REPLACE  idfirma WITH cidfirma, ;
                           idvn WITH "00", ;
                           brnal WITH "00000001", ;
                           rbr WITH Str( ++nRbr, 4 ), ;
                           idkonto WITH cIdkonto, ;
                           idpartner WITH cidpartner, ;
                           brdok  WITH cBrDok, ;
                           datdok WITH dDatDo + 1,;
                           datval WITH dDatVal

                        IF !( cFilter == ".t." )
                           REPLACE  k1 WITH cSUBk1, ;
                              k2 WITH cSUBk2, ;
                              k3 WITH cSUBk3, ;
                              k4 WITH cSUBk4
                        ENDIF

                        IF cTipPr == "1"
                           IF Left( IdKonto, 1 ) == cKlPotraz
                              // konto dobavljaca
                              REPLACE d_p WITH "2", iznosbhd WITH -nDin, iznosdem WITH -nDem
                           ELSE
                              // konto kupca
                              REPLACE d_p WITH "1", iznosbhd WITH nDin, iznosdem WITH nDem
                           ENDIF

                        ELSE
                           // cTipPr <> "1"
                           IF ndin >= 0
                              REPLACE d_p WITH "1", iznosbhd WITH nDin, iznosdem WITH nDem
                           ELSE
                              REPLACE d_p WITH "2", iznosbhd WITH -nDin, iznosdem WITH -nDem
                           ENDIF
                        ENDIF

                        IF lVodeSeRj
                           REPLACE IDRJ WITH cTekucaRJ
                        ENDIF
                        SELECT suban
                     ENDIF  // limit
                     // endif // cotvst=="9"

                  ENDIF  // cTipPr=="1"

                  IF cTipPr == "4"
                     cIDRJ := IDRJ; cFunk := FUNK; cFond := FOND
                     nDin := 0; nDem := 0

                     // ----------------------------------- petlja 6
                     DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdKonto == IdKonto .AND. IdPartner == cIdPartner ;
                           .AND. cIDRJ == IDRJ .AND. cFunk == FUNK .AND. cFond == FOND

                        nDin += iif( d_p == "1", iznosbhd, -iznosbhd )
                        nDem += iif( d_p == "1", iznosdem, -iznosdem )
                        Postotak( 2, ++nProslo )
                        SKIP 1

                     ENDDO // brdok
                     // ----------------------------------- petlja 6

                     IF Round( nDin, 3 ) <> 0  // ako saldo nije 0
                        SELECT pripr
                        APPEND BLANK
                        REPLACE  idfirma WITH cidfirma, ;
                           idvn WITH "00", ;
                           brnal WITH "00000001", ;
                           rbr WITH Str( ++nRbr, 4 ), ;
                           idkonto WITH cIdkonto, ;
                           idpartner WITH cidpartner, ;
                           idrj WITH cIDRJ, ;
                           funk WITH cFunk, ;
                           fond WITH cFond, ;
                           datdok WITH dDatDo + 1

                        IF !( cFilter == ".t." )
                           REPLACE  k1 WITH cSUBk1, ;
                              k2 WITH cSUBk2, ;
                              k3 WITH cSUBk3, ;
                              k4 WITH cSUBk4
                        ENDIF
                        IF ndin >= 0
                           REPLACE d_p WITH "1", iznosbhd WITH nDin, iznosdem WITH nDem
                        ELSE
                           REPLACE d_p WITH "2", iznosbhd WITH -nDin, iznosdem WITH -nDem
                        ENDIF // ndin
                        SELECT suban
                     ENDIF  // limit

                  ENDIF  // cTipPr=="4"

                  IF cTipPr == "5"
                     cIDRJ := IDRJ; cFond := FOND
                     nDin := 0; nDem := 0

                     // ----------------------------------- petlja 6
                     DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdKonto == IdKonto .AND. IdPartner == cIdPartner ;
                           .AND. cIDRJ == IDRJ .AND. cFond == FOND

                        nDin += iif( d_p == "1", iznosbhd, -iznosbhd )
                        nDem += iif( d_p == "1", iznosdem, -iznosdem )
                        Postotak( 2, ++nProslo )
                        SKIP 1

                     ENDDO // brdok
                     // ----------------------------------- petlja 6

                     IF Round( nDin, 3 ) <> 0  // ako saldo nije 0
                        SELECT pripr
                        APPEND BLANK
                        REPLACE  idfirma WITH cidfirma, ;
                           idvn WITH "00", ;
                           brnal WITH "00000001", ;
                           rbr WITH Str( ++nRbr, 4 ), ;
                           idkonto WITH cIdkonto, ;
                           idpartner WITH cidpartner, ;
                           idrj WITH cIDRJ, ;
                           fond WITH cFond, ;
                           datdok WITH dDatDo + 1
                        IF !( cFilter == ".t." )
                           REPLACE  k1 WITH cSUBk1, ;
                              k2 WITH cSUBk2, ;
                              k3 WITH cSUBk3, ;
                              k4 WITH cSUBk4
                        ENDIF
                        IF ndin >= 0
                           REPLACE d_p WITH "1", iznosbhd WITH nDin, iznosdem WITH nDem
                        ELSE
                           REPLACE d_p WITH "2", iznosbhd WITH -nDin, iznosdem WITH -nDem
                        ENDIF // ndin
                        SELECT suban
                     ENDIF  // limit

                  ENDIF  // cTipPr=="5"

                  IF cTipPr == "6"
                     cIDRJ := IDRJ
                     nDin := 0; nDem := 0

                     // ----------------------------------- petlja 6
                     DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdKonto == IdKonto .AND. IdPartner == cIdPartner ;
                           .AND. cIDRJ == IDRJ

                        nDin += iif( d_p == "1", iznosbhd, -iznosbhd )
                        nDem += iif( d_p == "1", iznosdem, -iznosdem )
                        Postotak( 2, ++nProslo )
                        SKIP 1

                     ENDDO // brdok
                     // ----------------------------------- petlja 6

                     IF Round( nDin, 3 ) <> 0  // ako saldo nije 0
                        SELECT pripr
                        APPEND BLANK
                        REPLACE  idfirma WITH cidfirma, ;
                           idvn WITH "00", ;
                           brnal WITH "00000001", ;
                           rbr WITH Str( ++nRbr, 4 ), ;
                           idkonto WITH cIdkonto, ;
                           idpartner WITH cidpartner, ;
                           idrj WITH cIDRJ, ;
                           datdok WITH dDatDo + 1
                        IF !( cFilter == ".t." )
                           REPLACE  k1 WITH cSUBk1, ;
                              k2 WITH cSUBk2, ;
                              k3 WITH cSUBk3, ;
                              k4 WITH cSUBk4
                        ENDIF
                        IF ndin >= 0
                           REPLACE d_p WITH "1", iznosbhd WITH nDin, iznosdem WITH nDem
                        ELSE
                           REPLACE d_p WITH "2", iznosbhd WITH -nDin, iznosdem WITH -nDem
                        ENDIF // ndin
                        SELECT suban
                     ENDIF  // limit

                  ENDIF  // cTipPr=="6"

                  IF cTipPr $ "02"
                     IF d_p == "1"; nDin += iznosbhd; nDem += IznosDEM; ENDIF
                     IF d_p == "2"; nDin -= iznosbhd; nDem -= IznosDEM; ENDIF
                     SKIP 1
                     Postotak( 2, ++nProslo )
                  ENDIF

               ENDDO // konto, partner
               // ----------------------------------- petlja 4

            ENDIF    // tippr=="3"

            IF cTipPr == "2"  // sabirem po konto+partner
               IF ( Round( nDin, 2 ) <> 0 ) .OR. ( ( Round( nDem, 2 ) <> 0 ) .AND. lStranaBitna )
                  SELECT pripr
                  APPEND BLANK
                  REPLACE rbr WITH  Str( ++nRbr, 4 ), ;
                     idkonto WITH cIdkonto, ;
                     idpartner WITH cidpartner, ;
                     datdok WITH dDatDo + 1, ;
                     idfirma WITH cidfirma, ;
                     idvn WITH "00", idtipdok WITH "00", ;
                     brnal WITH "00000001"
                  IF !( cFilter == ".t." )
                     REPLACE  k1 WITH cSUBk1, ;
                        k2 WITH cSUBk2, ;
                        k3 WITH cSUBk3, ;
                        k4 WITH cSUBk4
                  ENDIF

                  IF nDin >= 0
                     REPLACE d_p WITH "1", ;
                        iznosbhd WITH nDin, ;
                        iznosdem WITH nDem
                  ELSE
                     REPLACE d_p WITH "2", ;
                        iznosbhd WITH -nDin, ;
                        iznosdem WITH -nDem
                  ENDIF // ndin

                  SELECT suban
               ENDIF // <> 0
            ENDIF

         ENDDO // konto
         // ----------------------------------- petlja 3

         IF cTipPr == "0"  // sabirem po konto bez obzira na partnera
            IF ( Round( nDin, 2 ) <> 0 ) .OR. ( Round( nDem, 2 ) <> 0  .AND. lStranaBitna )
               SELECT pripr
               APPEND BLANK
               REPLACE rbr WITH  Str( ++nRbr, 4 ), ;
                  idkonto WITH cIdkonto, ;
                  datdok WITH dDatDo + 1, ;
                  idfirma WITH cidfirma, ;
                  idvn WITH "00", idtipdok WITH "00", ;
                  brnal WITH "00000001"
               IF !( cFilter == ".t." )
                  REPLACE  k1 WITH cSUBk1, ;
                     k2 WITH cSUBk2, ;
                     k3 WITH cSUBk3, ;
                     k4 WITH cSUBk4
               ENDIF
               IF ndin >= 0
                  REPLACE d_p WITH "1", ;
                     iznosbhd WITH nDin, ;
                     iznosdem WITH nDem
               ELSE
                  REPLACE d_p WITH "2", ;
                     iznosbhd WITH -nDin, ;
                     iznosdem WITH -nDem
               ENDIF // ndin
               SELECT suban
            ENDIF // <> 0
         ENDIF

      ENDDO // firma
      // ----------------------------------- petlja 2

   ENDDO // eof
   // ----------------------------------- petlja 1

   Postotak( 0 )

   ENDPRINT
   CLOSE ALL

   IF !Empty( goModul:oDataBase:cSezona ) .AND. Pitanje(, "Prebaciti dokument u radno podrucje", "D" ) == "D"
      O_PRIPRRP
      O_PRIPR
      SELECT priprrp
      APPEND FROM pripr
      SELECT pripr; ZAP
      CLOSE ALL
      IF Pitanje(, "Prebaciti se na rad sa radnim podrucjem ?", "D" ) == "D"
         URadPodr()
      ENDIF
   ENDIF


   CLOSE ALL

   RETURN




/*  PreKart()
 *   Prebacivanje subanalitickih konta...
 */

FUNCTION PreKart()

   LOCAL aNiz := {}
   PRIVATE cKonto := Space( 60 ), cPartn := Space( 60 )
   PRIVATE dDat0 := CToD( "" ), dDat1 := CToD( "" ), cFirma := gFirma

   IF !sifra_za_koristenje_opcije( "SIGMAPRE" )
      CLOSERET
   ENDIF

   Msg( "Ova opcija omogucava prebacivanje svih ili dijela stavki sa#" + ;
      "postojeceg na drugi konto. Zeljeni konto je u tabeli prikazan#" + ;
      "u koloni sa zaglavljem 'Novi konto'. POSLJEDICA OVIH PROMJENA#" + ;
      "JE DA CE NALOZI KOJI SADRZE IZMIJENJENE STAVKE BITI RAZLICITI#" + ;
      "OD ODSTAMPANIH, PA SE PREPORUCUJE PONOVNA STAMPA TIH NALOGA." )

   AAdd ( aNiz, { "Firma (prazno-sve)", "cFirma",,, } )
   AAdd ( aNiz, { "Konto (prazno-sva)", "cKonto",, "@!S30", } )
   AAdd ( aNiz, { "Partner (prazno-svi)", "cPartn",, "@!S30", } )
   AAdd ( aNiz, { "Za period od datuma", "dDat0",,, } )
   AAdd ( aNiz, { "          do datuma", "dDat1",,, } )

   DO WHILE .T.
      IF !VarEdit( aNiz, 9, 5, 17, 74, ;
            'POSTAVLJANJE USLOVA ZA IZDVAJANJE SUBANALITICKIH STAVKI', ;
            "B1" )
         CLOSERET
      ENDIF
      aUsl1 := Parsiraj( cKonto, "idkonto" )
      aUsl2 := Parsiraj( cPartn, "idpartner" )
      IF aUsl1 <> NIL .AND. aUsl2 <> NIL
         EXIT
      ELSEIF aUsl1 <> NIL
         MsgBeep ( "Kriterij za partnera nije korektno postavljen!" )
      ELSEIF aUsl2 <> NIL
         MsgBeep ( "Kriterij za konto nije korektno postavljen!" )
      ELSE
         MsgBeep ( "Kriteriji za konto i partnera nisu korektno postavljeni!" )
      ENDIF
   ENDDO // .t.

   // otvaranje potrebnih baza
   // /////////////////////////

   O_KONTO
   O_PARTN
   O_SINT
   SET ORDER TO 2
   O_ANAL
   SET ORDER TO 2
   O_SUBAN

   IF !File2( "TEMP77.DBF" )
      aTmp := dbStruct()
      AAdd( aTmp, { "KONTO2", "C", 7, 0 } )
      AAdd( aTmp, { "PART2", "C", 6, 0 } )
      AAdd( aTmp, { "NSLOG", "N", 10, 0 } )
      DBCREATE2( "TEMP77.DBF", aTmp )
   ENDIF

   SELECT F_TEMP77
   USE_EXCLUSIVE ( "TEMP77" )
   ZAP

   SELECT F_SUBAN

   cFilt1 := ".t." + iif( !Empty( cFirma ), ".and.IDFIRMA==" + cm2str( cFirma ), "" ) + ;
      iif( !Empty( dDat0 ), ".and.DATDOK>=" + cm2str( dDat0 ), "" ) + ;
      iif( !Empty( dDat1 ), ".and.DATDOK<=" + cm2str( dDat1 ), "" ) + ;
      ".and." + aUsl1 + ".and." + aUsl2

   cFilt1 := StrTran( cFilt1, ".t..and.", "" )
   IF !( cFilt1 == ".t." )
      SET FILTER TO &cFilt1
   ENDIF

   GO TOP
   DO WHILE !Eof()
      Scatter()
      _konto2 := _idkonto
      _part2 := _idpartner
      _nslog := RecNo()
      SELECT TEMP77
      APPEND BLANK
      Gather()
      SELECT F_SUBAN
      SKIP 1
   ENDDO

   SELECT TEMP77
   GO TOP

   ImeKol := { ;
      { "F.",            {|| IdFirma }, "IdFirma" },;
      { "VN",            {|| IdVN    }, "IdVN" },;
      { "Br.",           {|| BrNal   }, "BrNal" }, ;
      { "R.br",          {|| RBr     }, "rbr", {|| wrbr() }, {|| vrbr() } },;
      { "Konto",         {|| IdKonto }, "IdKonto", {|| .T. }, {|| P_Konto( @_IdKonto ), .T. } },;
      { "Novi konto",    {|| konto2  }, "konto2", {|| .T. }, {|| P_Konto( @_konto2 ), .T. } },;
      { "Partner",       {|| IdPartner }, "IdPartner", {|| .T. }, {|| P_Firma( @_idpartner ), .T. } },;
      { "Novi partner",  {|| part2  }, "part2", {|| .T. }, {|| P_Firma( @_part2 ), .T. } },;
      { "Br.veze ",      {|| BrDok   }, "BrDok" },;
      { "Datum",         {|| DatDok  }, "DatDok" },;
      { "D/P",           {|| D_P     }, "D_P" },;
      { ValDomaca(),     {|| Transform( IznosBHD, FormPicL( gPicBHD, 15 ) ) }, "iznos " + AllTrim( ValDomaca() ) },;
      { ValPomocna(),    {|| Transform( IznosDEM, FormPicL( gPicDEM, 10 ) ) }, "iznos " + AllTrim( ValPomocna() ) },;
      { "Opis",          {|| Opis      }, "OPIS" }, ;
      { "K1",            {|| k1      }, "k1" }, ;
      { "K2",            {|| k2      }, "k2" }, ;
      { "K3",            {|| k3iz256( k3 )      }, "k3" }, ;
      { "K4",            {|| k4      }, "k4" } ;
      }

   Kol := {}; FOR i := 1 TO Len( ImeKol ); AAdd( Kol, i ); NEXT

   DO WHILE .T.
      Box(, 20, 77 )
      @ m_x + 19, m_y + 2 SAY "                         �                        �                   "
      @ m_x + 20, m_y + 2 SAY " <c-T>  Brisi stavku     � <ENTER>  Ispravi konto � <a-A> Azuriraj    "
      ObjDbedit( "PPK", 20, 77, {|| EPPK() }, "", "Priprema za prebacivanje stavki", , , , , 2 )
      BoxC()
      IF RECCOUNT2() > 0
         i := KudaDalje( "ZAVRSAVATE SA PRIPREMOM PODATAKA. STA RADITI SA URADJENIM?", ;
            { "AZURIRATI PODATKE", ;
            "IZBRISATI PODATKE", ;
            "VRATIMO SE U PRIPREMU" } )
         DO CASE
         CASE i == 1
            AzurPPK()
            EXIT
         CASE i == 2
            EXIT
         CASE i == 3
            GO TOP
         ENDCASE
      ELSE
         EXIT
      ENDIF
   ENDDO

   CLOSERET

   RETURN NIL



/*  EPPK()
 *   Ispravka konta, promjena konta
 */

FUNCTION EPPK()

   LOCAL nTr2

   IF ( Ch == K_CTRL_T .OR. Ch == K_ENTER ) .AND. reccount2() == 0
      RETURN DE_CONT
   ENDIF

   SELECT temp77
   DO CASE

   CASE Ch == K_CTRL_T
      IF Pitanje( "p01", "Zelite izbrisati ovu stavku ?", "D" ) == "D"
         DELETE
         RETURN DE_REFRESH
      ENDIF
      RETURN DE_CONT

   CASE Ch == K_ENTER
      Scatter()
      IF !VarEdit( { { "Konto", "_konto2", "P_Konto(@_konto2)",, } }, 9, 5, 17, 74, ;
            'POSTAVLJANJE NOVOG KONTA', ;
            "B1" )
         RETURN DE_CONT
      ELSE
         Gather()
         RETURN DE_REFRESH
      ENDIF

   CASE Ch == K_ALT_A
      AzurPPK()
      RETURN DE_REFRESH

   ENDCASE

   RETURN DE_CONT



/*  AzurPPK()
 *   Azuriranje promjena konta
 */

FUNCTION AzurPPK()

   LOCAL lIndik1 := .F., lIndik2 := .F., nZapisa := 0, nSlog := 0, cStavka := "   "

   SELECT SUBAN
   SET FILTER TO
   GO TOP
   SELECT TEMP77
   Postotak( 1, RECCOUNT2(), "Azuriranje promjena na subanalitici",,, .T. )
   GO TOP
   DO WHILE !Eof()

      // azuriraj subanalitiku
      // ////////////////////////////////////////////////
      IF ( TEMP77->idkonto != TEMP77->konto2 )
         SELECT SUBAN
         GO TEMP77->NSLOG
         Scatter()
         _idkonto := TEMP77->konto2
         Gather()
      ENDIF

      IF ( TEMP77->idpartner != TEMP77->part2 )
         SELECT SUBAN
         GO TEMP77->NSLOG
         Scatter()
         _idpartner := TEMP77->part2
         Gather()
      ENDIF

      // azuriraj analitiku
      // ////////////////////////////////////////////////
      IF TEMP77->idkonto != TEMP77->konto2
         SELECT ANAL; GO TOP
         SEEK TEMP77->( idfirma + idvn + brnal )
         lIndik1 := .F. ; lIndik2 := .F.
         DO WHILE !Eof() .AND. idfirma + idvn + brnal == TEMP77->( idfirma + idvn + brnal )
            IF idkonto == TEMP77->idkonto .AND. !lIndik1
               lIndik1 := .T.
               Scatter()
               IF TEMP77->d_p == "1"
                  _dugbhd := _dugbhd - TEMP77->iznosbhd
                  _dugdem := _dugdem - TEMP77->iznosdem
               ELSE
                  _potbhd := _potbhd - TEMP77->iznosbhd
                  _potdem := _potdem - TEMP77->iznosdem
               ENDIF
               Gather()
            ELSEIF idkonto == TEMP77->konto2 .AND. !lIndik2
               lIndik2 := .T.
               Scatter()
               IF TEMP77->d_p == "1"
                  _dugbhd := _dugbhd + TEMP77->iznosbhd
                  _dugdem := _dugdem + TEMP77->iznosdem
               ELSE
                  _potbhd := _potbhd + TEMP77->iznosbhd
                  _potdem := _potdem + TEMP77->iznosdem
               ENDIF
               Gather()
            ENDIF
            SKIP 1
         ENDDO
         SKIP -1
         IF !lIndik2
            Scatter()
            _idkonto := TEMP77->konto2
            _rbr := NovaSifra( _rbr )
            IF gDatNal == "N"; _datnal := TEMP77->datdok; ENDIF
            _dugbhd := IF( TEMP77->d_p == "1", TEMP77->iznosbhd, 0 )
            _potbhd := IF( TEMP77->d_p == "2", TEMP77->iznosbhd, 0 )
            _dugdem := IF( TEMP77->d_p == "1", TEMP77->iznosdem, 0 )
            _potdem := IF( TEMP77->d_p == "2", TEMP77->iznosdem, 0 )
            APPEND BLANK
            Gather()
         ENDIF
      ENDIF

      // azuriraj sintetiku
      // ////////////////////////////////////////////////
      IF Left( TEMP77->idkonto, 3 ) != Left( TEMP77->konto2, 3 )
         SELECT SINT; GO TOP
         SEEK TEMP77->( idfirma + idvn + brnal )
         lIndik1 := .F. ; lIndik2 := .F.
         DO WHILE !Eof() .AND. idfirma + idvn + brnal == TEMP77->( idfirma + idvn + brnal )
            IF idkonto == Left( TEMP77->idkonto, 3 ) .AND. !lIndik1
               lIndik1 := .T.
               Scatter()
               IF TEMP77->d_p == "1"
                  _dugbhd := _dugbhd - TEMP77->iznosbhd
                  _dugdem := _dugdem - TEMP77->iznosdem
               ELSE
                  _potbhd := _potbhd - TEMP77->iznosbhd
                  _potdem := _potdem - TEMP77->iznosdem
               ENDIF
               Gather()
            ELSEIF idkonto == Left( TEMP77->konto2, 3 ) .AND. !lIndik2
               lIndik2 := .T.
               Scatter()
               IF TEMP77->d_p == "1"
                  _dugbhd := _dugbhd + TEMP77->iznosbhd
                  _dugdem := _dugdem + TEMP77->iznosdem
               ELSE
                  _potbhd := _potbhd + TEMP77->iznosbhd
                  _potdem := _potdem + TEMP77->iznosdem
               ENDIF
               Gather()
            ENDIF
            SKIP 1
         ENDDO
         SKIP -1
         IF !lIndik2
            Scatter()
            _idkonto := Left( TEMP77->konto2, 3 )
            _rbr := NovaSifra( _rbr )
            IF gDatNal == "N"; _datnal := TEMP77->datdok; ENDIF
            _dugbhd := IF( TEMP77->d_p == "1", TEMP77->iznosbhd, 0 )
            _potbhd := IF( TEMP77->d_p == "2", TEMP77->iznosbhd, 0 )
            _dugdem := IF( TEMP77->d_p == "1", TEMP77->iznosdem, 0 )
            _potdem := IF( TEMP77->d_p == "2", TEMP77->iznosdem, 0 )
            APPEND BLANK
            Gather()
         ENDIF
      ENDIF

      SELECT TEMP77
      SKIP 1
      Postotak( 2, ++nZapisa,,,, .F. )
   ENDDO
   Postotak( -1,,,,, .F. )
   ZAP

   SELECT ANAL
   nZapisa := 0
   Postotak( 1, RECCOUNT2(), "Azuriranje promjena na analitici",,, .F. )
   GO TOP
   DO WHILE !Eof()
      IF dugbhd == 0 .AND. potbhd == 0 .AND. dugdem == 0 .AND. potdem == 0
         SKIP 1
         nSlog := RecNo()
         SKIP -1
         DELETE
         GO nSlog
      ELSE
         SKIP 1
      ENDIF
      Postotak( 2, ++nZapisa,,,, .F. )
   ENDDO
   Postotak( -1,,,,, .F. )

   SELECT SINT
   nZapisa := 0
   Postotak( 1, RECCOUNT2(), "Azuriranje promjena na sintetici",,, .F. )
   GO TOP
   DO WHILE !Eof()
      IF dugbhd == 0 .AND. potbhd == 0 .AND. dugdem == 0 .AND. potdem == 0
         SKIP 1
         nSlog := RecNo()
         SKIP -1
         DELETE
         GO nSlog
      ELSE
         SKIP 1
      ENDIF
      Postotak( 2, ++nZapisa,,,, .F. )
   ENDDO
   Postotak( -1,,,,, .T. )

   SELECT TEMP77

   RETURN



/*  ZadnjiRbr()
 *   Vraca zadnji redni broj
 */

FUNCTION ZadnjiRBR()

   LOCAL nZRBR := 0
   LOCAL nObl := Select()

   O_PRIPRRP
   GO BOTTOM
   nZRBR := Val( rbr )
   USE
   SELECT ( nObl )

   RETURN ( nZRBR )
