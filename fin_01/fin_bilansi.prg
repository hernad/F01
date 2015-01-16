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

STATIC s_nProgres := 0

STATIC __par_len

// --------------------------------------
// bilansni izvjestaji
// --------------------------------------
FUNCTION Bilans( nVarijanta, hParams )

   IF hParams != NIL

      switch_thread_window()
      AltD()

      OutStd( "FIN server start " + hb_eol() )
      PUBLIC gModul := "FIN"
      MainFin( hParams[ 'user' ], hParams[ 'password' ], "SERVER" )

      PUBLIC cDirRad := hParams[ 'kumpath' ]
      PUBLIC cDirSif := hParams[ 'sifpath' ]
      PUBLIC cDirPriv := hParams[ 'privpath' ]

      OutStd( " kumpath: " + hParams[ 'kumpath' ] + hb_eol() )
      OutStd( "privpath: " + hParams[ 'privpath' ] + hb_eol() )


      PUBLIC gFirma := hParams[ 'gFirma' ]
      gReadOnly := .F.
      f01_set_global_vars()
      IniGparams()
      gOModul:setGVars()

   ENDIF

   IF gVar1 == "0"
      PRIVATE opc[ 5 ], Izbor
   ELSE
      PRIVATE opc[ 4 ], Izbor
   ENDIF

   IF nVarijanta == NIL
      nVarijanta := 0
   ENDIF

   cTip := ValDomaca()

   M6 := "--------- --------------- --------------- --------------- --------------- --------------- --------------- --------------- ---------------"
   M7 := "*        *          POCETNO STANJE       *         TEKUCI PROMET         *        KUMULATIVNI PROMET     *            SALDO             *"
   M8 := "  KLASA   ------------------------------- ------------------------------- ------------------------------- -------------------------------"
   M9 := "*        *    DUGUJE     *   POTRAZUJE   *     DUGUJE    *   POTRAZUJE   *    DUGUJE     *   POTRAZUJE   *     DUGUJE    *    POTRAZUJE *"
   M10 := "--------- --------------- --------------- --------------- --------------- --------------- --------------- --------------- ---------------"

   opc[ 1 ] := "1. po grupama       "
   opc[ 2 ] := "2. sintetika"
   opc[ 3 ] := "3. analitika"
   opc[ 4 ] := "4. subanalitika"
   IF gVar1 == "0"; opc[ 5 ] := "5. obracun: " + cTip; h[ 5 ] := ""; ENDIF
   h[ 1 ] := h[ 2 ] := h[ 3 ] := h[ 4 ] := ""


   Izbor := 1

   PRIVATE PicD := FormPicL( gPicBHD, 15 )
   DO WHILE .T.

      IF nVarijanta == 0
         Izbor := Menu( "bb", opc, Izbor, .F. )
      ELSE
         Izbor := nVarijanta
      ENDIF

      DO CASE
      CASE Izbor == 0
         EXIT

      CASE izbor = 1

         cBBV := cTip
         nBBK := 1
         GrupBB()

      CASE izbor == 2
         cBBV := cTip
         nBBK := 1
         SintBB()

      CASE izbor == 3

         cBBV := cTip
         nBBK := 1
         AnalBB()

      CASE izbor = 4

         cBBV := cTip
         nBBK := 1
         SubAnBB( hParams )


      CASE izbor = 5
         IF cTip == ValDomaca()
            PicD := FormPicL( gPicDEM, 15 )
            cTip := ValPomocna()
         ELSE
            PicD := FormPicL( gPicBHD, 15 )
            cTip := ValDomaca()
         ENDIF
         opc[ 5 ] := "5. obracun: " + cTip

      CASE izbor = 5
         Izbor := 0
      ENDCASE

      IF nVarijanta != 0
         EXIT
      ENDIF
   ENDDO

   RETURN



// ----------------------------------
// filuje tabelu za export
// ----------------------------------
STATIC FUNCTION fill_ssbb_tbl( cKonto, cIdPart, cNaziv, ;
      nFDug, nFPot, nFSaldo )

   LOCAL nArr

   nArr := Select()

   O_R_EXP
   APPEND BLANK
   REPLACE field->konto WITH cKonto
   REPLACE field->idpart WITH cIdPart
   REPLACE field->naziv WITH cNaziv
   REPLACE field->duguje WITH nFDug
   REPLACE field->potrazuje WITH nFPot
   REPLACE field->saldo WITH nFSaldo

   SELECT ( nArr )

   RETURN


// ------------------------------------------------
// filovanje tabele sbb
// ------------------------------------------------
STATIC FUNCTION fill_sbb_tbl( cKonto, cIdPart, cNaziv, ;
      nPsDug, nPsPot, nKumDug, nKumPot, ;
      nSldDug, nSldPot )

   LOCAL nArr

   nArr := Select()

   O_R_EXP
   APPEND BLANK
   REPLACE field->konto WITH cKonto
   REPLACE field->idpart WITH cIdPart
   REPLACE field->naziv WITH cNaziv
   REPLACE field->psdug WITH nPsDug
   REPLACE field->pspot WITH nPsPot
   REPLACE field->kumdug WITH nKumDug
   REPLACE field->kumpot WITH nKumPot
   REPLACE field->slddug WITH nSldDug
   REPLACE field->sldpot WITH nSldPot

   SELECT ( nArr )

   RETURN



// ------------------------------------------
// vraca matricu sa sub.bb poljima
// ------------------------------------------
STATIC FUNCTION get_sbb_fields( lBBSkraceni, nPartLen )

   IF nPartLen == nil
      nPartLen := 6
   ENDIF

   aFields := {}
   AAdd( aFields, { "konto", "C", 7, 0 } )
   AAdd( aFields, { "idpart", "C", nPartLen, 0 } )
   AAdd( aFields, { "naziv", "C", 40, 0 } )

   IF lBBSkraceni
      AAdd( aFields, { "duguje", "N", 15, 2 } )
      AAdd( aFields, { "potrazuje", "N", 15, 2 } )
      AAdd( aFields, { "saldo", "N", 15, 2 } )
   ELSE
      AAdd( aFields, { "psdug", "N", 15, 2 } )
      AAdd( aFields, { "pspot", "N", 15, 2 } )
      AAdd( aFields, { "kumdug", "N", 15, 2 } )
      AAdd( aFields, { "kumpot", "N", 15, 2 } )
      AAdd( aFields, { "slddug", "N", 15, 2 } )
      AAdd( aFields, { "sldpot", "N", 15, 2 } )
   ENDIF

   RETURN aFields




// -----------------------------------------------
// Subanaliticki bruto bilans
// -----------------------------------------------

FUNCTION SubAnBB( hParams )

   IF hParams == NIL

      hParams := hb_Hash()

      hParams[ 'user' ] := "11"
      hParams[ 'password' ] := "11"
      hParams[ 'kumpath' ] := cDirRad
      hParams[ 'sifpath' ] := cDirSif
      hParams[ 'privpath' ]  := cDirPriv
      hParams[ 'gFirma' ]  := gFirma

      RETURN netio_FuncExec( "Bilans", 4, hParams )

   ENDIF

   cIdFirma := gFirma

   O_KONTO
   O_PARTN

   __par_len := Len( partn->id )

   qqKonto := Space( 100 )
   dDatOd := dDatDo := CToD( "" )
   PRIVATE cFormat := "2"
   PRIVATE cPodKlas := "N"
   PRIVATE cNule := "D"
   PRIVATE cExpRptDN := "N"
   PRIVATE cBBSkrDN := "N"
   PRIVATE cPrikaz := "1"

   PRIVATE cIdRj := ""


   IF hParams == NIL

      Box( "sanb", 13, 60 )
      SET CURSOR ON

      DO WHILE .T.

         @ m_x + 1, m_y + 2 SAY "SUBANALITICKI BRUTO BILANS"
         IF gNW == "D"
            @ m_x + 2, m_y + 2 SAY "Firma "; ?? gFirma, "-", gNFirma
         ELSE
            @ m_x + 2, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| Empty( cIdFirma ) .OR. P_Firma( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
         ENDIF
         @ m_x + 3, m_y + 2 SAY "Konto " GET qqKonto    PICT "@!S50"
         @ m_x + 4, m_y + 2 SAY "Od datuma :" GET dDatOD
         @ m_x + 4, Col() + 2 SAY "do" GET dDatDo
         @ m_x + 6, m_y + 2 SAY "Format izvjestaja A3/A4/A4L (1/2/3)" GET cFormat
         @ m_x + 7, m_y + 2 SAY "Klase unutar glavnog izvjestaja (D/N)" GET cPodKlas VALID cPodKlas $ "DN" PICT "@!"
         @ m_x + 8, m_y + 2 SAY "Prikaz stavki sa saldom 0 D/N " GET cNule VALID cnule $ "DN" PICT "@!"

         cIdRJ := ""

         IF gRJ == "D"
            cIdRJ := "999999"
            @ m_x + 9, m_y + 2 SAY "Radna jedinica (999999-sve): " GET cIdRj
         ENDIF

         @ m_x + 10, m_y + 2 SAY "Export izvjestaja u dbf (D/N)? " GET cExpRptDN VALID cExpRptDN $ "DN" PICT "@!"
         @ m_x + 11, m_y + 2 SAY "Export skraceni bruto bilans (D/N)? " GET cBBSkrDN VALID cBBSkrDN $ "DN" PICT "@!"

         @ m_x + 12, m_y + 2 SAY "Prikaz suban (1) / suban+anal (2) / anal (3)" GET cPrikaz VALID cPrikaz $ "123" PICT "@!"

         READ
         ESC_BCR

         aUsl1 := Parsiraj( qqKonto, "IdKonto" )

         IF aUsl1 <> NIL
            EXIT
         ENDIF
      ENDDO

      BoxC()


   ENDIF


   aUsl1 := Parsiraj( qqKonto, "IdKonto" )
   cIdFirma := Trim( cIdFirma )

   IF cIdRj == "999999"
      cIdRj := ""
   ENDIF

   IF gRJ == "D" .AND. "." $ cIdRj
      cIdRj := Trim( StrTran( cIdRj, ".", "" ) )
      // odsjeci ako je tacka. prakticno "01. " -> sve koje pocinju sa  "01"

   ENDIF

   IF cFormat $ "1#3"
      PRIVATE REP1_LEN := 236
      th1 := "---- ------- -------- --------------------------------------------------- -------------- ----------------- --------------------------------- ------------------------------- ------------------------------- -------------------------------"
      th2 := "*R. * KONTO *PARTNER *     NAZIV KONTA ILI PARTNERA                      *    MJESTO    *      ADRESA     *        POCETNO STANJE           *         TEKUCI PROMET         *       KUMULATIVNI PROMET      *            SALDO             *"
      th3 := "                                                                                                           --------------------------------- ------------------------------- ------------------------------- -------------------------------"
      th4 := "*BR.*       *        *                                                   *              *                 *    DUGUJE       *   POTRAZUJE   *    DUGUJE     *   POTRAZUJE   *    DUGUJE     *   POTRAZUJE   *     DUGUJE    *   POTRAZUJE  *"
      th5 := "---- ------- -------- --------------------------------------------------- -------------- ----------------- ----------------- --------------- --------------- --------------- --------------- --------------- --------------- ---------------"
   ELSE
      PRIVATE REP1_LEN := 158
      th1 := "---- ------- -------- -------------------------------------- --------------------------------- ------------------------------- -------------------------------"
      th2 := "*R. * KONTO *PARTNER *    NAZIV KONTA ILI PARTNERA          *        POCETNO STANJE           *       KUMULATIVNI PROMET      *            SALDO             *"
      th3 := "                                                             --------------------------------- ------------------------------- -------------------------------"
      th4 := "*BR.*       *        *                                      *    DUGUJE       *   POTRAZUJE   *    DUGUJE     *   POTRAZUJE   *     DUGUJE    *   POTRAZUJE  *"
      th5 := "---- ------- -------- -------------------------------------- ----------------- --------------- --------------- --------------- --------------- ---------------"
   ENDIF

   PRIVATE lExpRpt := ( cExpRptDN == "D" )
   PRIVATE lBBSkraceni := ( cBBSkrDN == "D" )

   IF lExpRpt
      aExpFields := get_sbb_fields( lBBSkraceni, __par_len )
      t_exp_create( aExpFields )
      cLaunch := exp_report()
   ENDIF

   init_progres()

   O_KONTO
   O_PARTN
   O_SUBAN
   O_KONTO
   O_BBKLAS

   SELECT BBKLAS
   ZAP

   PRIVATE cFilter := ""

   SELECT SUBAN

   IF gRj == "D" .AND. Len( cIdrj ) <> 0
      cFilter += iif( Empty( cFilter ), "", ".and." ) + "idrj=" + cm2str( cidrj )
   ENDIF

   IF aUsl1 <> ".t."
      cFilter += iif( Empty( cFilter ), "", ".and." ) + aUsl1
   ENDIF

   IF !( Empty( dDatOd ) .AND. Empty( dDatDo ) )
      cFilter += iif( Empty( cFilter ), "", ".and." ) + "DATDOK>=CTOD('" + DToC( dDatOd ) + "') .and. DATDOK<=CTOD('" + DToC( dDatDo ) + "')"
   ENDIF

   IF !Empty( cFilter ) .AND. Len( cIdFirma ) == 2
      SET FILTER to &cFilter
   ENDIF

   IF Len( cIdFirma ) < 2
      SELECT SUBAN
      Box(, 2, 30 )
      nSlog := 0; nUkupno := RECCOUNT2()
      cFilt := iif( Empty( cFilter ), "IDFIRMA=" + cm2str( cIdFirma ), cFilter + ".and.IDFIRMA=" + cm2str( cIdFirma ) )
      cSort1 := "IdKonto+IdPartner+dtos(DatDok)+BrNal+RBr"
      INDEX ON &cSort1 TO "SUBTMP" FOR &cFilt Eval( TekRec2() ) EVERY 1
      GO TOP
      BoxC()
   ELSE
      HSEEK cIdFirma
   ENDIF

   EOF CRET

   nStr := 0

   BBMnoziSaK()

   START PRINT CRET


   B := B1 := B2 := 0  // brojaci

   SELECT SUBAN

   D1S := D2S := D3S := D4S := 0
   P1S := P2S := P3S := P4S := 0

   D4PS := P4PS := D4TP := P4TP := D4KP := P4KP := 0
   nCol1 := 50
   DO WHILE not_key_esc() .AND. !Eof() .AND. IdFirma = cIdFirma   // idfirma

      IF PRow() == 0
         ZaglSan( cFormat )
      ENDIF

      // PS - pocetno stanje
      // TP - tekuci promet
      // KP - kumulativni promet
      // S - saldo

      D3PS := P3PS := D3TP := P3TP := D3KP := P3KP := D3S := P3S := 0
      cKlKonto := Left( IdKonto, 1 )

      DO WHILE not_key_esc() .AND. !Eof() .AND. IdFirma = cIdFirma .AND. cKlKonto == Left( IdKonto, 1 )

         // klasa konto

         cSinKonto := Left( IdKonto, 3 )
         D2PS := P2PS := D2TP := P2TP := D2KP := P2KP := D2S := P2S := 0

         DO WHILE not_key_esc() .AND. !Eof() .AND. IdFirma = cIdFirma .AND. cSinKonto == Left( IdKonto, 3 )
            // sint. konto

            cIdKonto := IdKonto
            D1PS := P1PS := D1TP := P1TP := D1KP := P1KP := D1S := P1S := 0
            DO WHILE not_key_esc() .AND. !Eof() .AND. IdFirma = cIdFirma .AND. cIdKonto == IdKonto

               // konto

               cIdPartner := IdPartner
               D0PS := P0PS := D0TP := P0TP := D0KP := P0KP := D0S := P0S := 0

               DO WHILE not_key_esc() .AND. !Eof() .AND. IdFirma = cIdFirma .AND. cIdKonto == IdKonto .AND. cIdPartner == IdPartner

                  // partner

                  IF cTip == ValDomaca()
                     IF D_P = "1"
                        D0KP += IznosBHD * nBBK
                     ELSE
                        P0KP += IznosBHD * nBBK
                     ENDIF
                  ELSE
                     IF D_P = "1"
                        D0KP += IznosDEM
                     ELSE
                        P0KP += IznosDEM
                     ENDIF
                  ENDIF

                  IF cTip == ValDomaca()
                     IF IdVN = "00"
                        IF D_P == "1"; D0PS += IznosBHD * nBBK; ELSE; P0PS += IznosBHD * nBBK; ENDIF
                     ELSE
                        IF D_P == "1"; D0TP += IznosBHD * nBBK; ELSE; P0TP += IznosBHD * nBBK; ENDIF
                     ENDIF
                  ELSE

                     IF IdVN = "00"
                        IF D_P == "1"; D0PS += IznosDEM; ELSE; P0PS += IznosDEM; ENDIF
                     ELSE
                        IF D_P == "1"; D0TP += IznosDEM; ELSE; P0TP += IznosDEM; ENDIF
                     ENDIF
                  ENDIF

                  SKIP
               ENDDO // partner

               show_progres()

               IF PRow() > 61 + gpStranica
                  FF
                  ZaglSan( cFormat )
               ENDIF

               IF ( cNule == "N" .AND. Round( D0KP - P0KP, 2 ) == 0 )
                  // ne prikazuj
               ELSE

                  // if cPrikaz $ "12"

                  @ PRow() + 1, 0 SAY  ++B  PICTURE '9999'    // ; ?? "."
                  @ PRow(), PCol() + 1 SAY cIdKonto
                  @ PRow(), PCol() + 1 SAY cIdPartner       // IdPartner(cIdPartner)

                  SELECT PARTN
                  HSEEK cIdPartner

                  IF cFormat == "2"
                     @ PRow(), PCol() + 1 SAY PadR( naz, 48 -Len ( cIdPartner ) )
                  ELSE
                     @ PRow(), PCol() + 1 SAY PadR( naz, 20 )
                     @ PRow(), PCol() + 1 SAY PadR( naz2, 20 )
                     @ PRow(), PCol() + 1 SAY Mjesto
                     @ PRow(), PCol() + 1 SAY Adresa PICTURE 'XXXXXXXXXXXXXXXXX'
                  ENDIF

                  SELECT SUBAN

                  nCol1 := PCol() + 1
                  @ PRow(), PCol() + 1 SAY D0PS PICTURE PicD
                  @ PRow(), PCol() + 1 SAY P0PS PICTURE PicD

                  IF cFormat == "1"
                     @ PRow(), PCol() + 1 SAY D0TP PICTURE PicD
                     @ PRow(), PCol() + 1 SAY P0TP PICTURE PicD
                  ENDIF
                  @ PRow(), PCol() + 1 SAY D0KP PICTURE PicD
                  @ PRow(), PCol() + 1 SAY P0KP PICTURE PicD
                  D0S := D0KP - P0KP
                  IF D0S >= 0
                     P0S := 0
                  ELSE
                     P0S := -D0S
                     D0S := 0
                  ENDIF
                  @ PRow(), PCol() + 1 SAY D0S PICTURE PicD
                  @ PRow(), PCol() + 1 SAY P0S PICTURE PicD

                  // endif

                  D1PS += D0PS;P1PS += P0PS;D1TP += D0TP;P1TP += P0TP;D1KP += D0KP;P1KP += P0KP

                  IF lExpRpt .AND. !Empty( cIdPartner ) .AND. cPrikaz $ "12"
                     IF lBBSkraceni
                        fill_ssbb_tbl( cIdKonto, cIdPartner, partn->naz, D0KP, P0KP, D0KP - P0KP )
                     ELSE
                        fill_sbb_tbl( cIdKonto, cIdPartner, partn->naz, D0PS, P0PS, D0KP, P0KP, D0S, P0S )
                     ENDIF
                  ENDIF
               ENDIF

            ENDDO // konto

            IF PRow() > 59 + gpStranica
               FF
               ZaglSan( cFormat )
            ENDIF

            // if (( cPrikaz == "1" .and. EMPTY(cIdPartner)) .or. cPrikaz $ "23" )

            @ PRow() + 1, 2 SAY Replicate( "-", REP1_LEN - 2 )
            @ PRow() + 1, 2 SAY ++B1 PICTURE '9999'      // ; ?? "."
            @ PRow(), PCol() + 1 SAY cIdKonto
            SELECT KONTO
            HSEEK cIdKonto
            IF cFormat == "1"
               @ PRow(), PCol() + 1 SAY naz
            ELSE
               @ PRow(), PCol() + 1 SAY Left ( naz, 47 )  // 40
            ENDIF
            SELECT SUBAN

            @ PRow(), nCol1     SAY D1PS PICTURE PicD
            @ PRow(), PCol() + 1  SAY P1PS PICTURE PicD
            IF cFormat == "1"
               @ PRow(), PCol() + 1  SAY D1TP PICTURE PicD
               @ PRow(), PCol() + 1  SAY P1TP PICTURE PicD
            ENDIF
            @ PRow(), PCol() + 1  SAY D1KP PICTURE PicD
            @ PRow(), PCol() + 1  SAY P1KP PICTURE PicD

            // endif

            D1S := D1KP - P1KP

            IF D1S >= 0
               P1S := 0
               D2S += D1S;D3S += D1S;D4S += D1S
            ELSE
               P1S := -D1S; D1S := 0
               P2S += P1S;P3S += P1S;P4S += P1S
            ENDIF

            // if (( cPrikaz == "1" .and. EMPTY(cIdPartner)) .or. cPrikaz $ "23" )

            @ PRow(), PCol() + 1 SAY D1S PICTURE PicD
            @ PRow(), PCol() + 1 SAY P1S PICTURE PicD
            @ PRow() + 1, 2 SAY Replicate( "-", REP1_LEN - 2 )

            // endif

            SELECT SUBAN
            D2PS += D1PS;P2PS += P1PS;D2TP += D1TP;P2TP += P1TP;D2KP += D1KP;P2KP += P1KP

            IF lExpRpt .AND. ( ( cPrikaz == "1" .AND. Empty( cIdPartner ) ) .OR. cPrikaz $ "23" )
               IF lBBSkraceni
                  fill_ssbb_tbl( cIdKonto, "", konto->naz, D1KP, P1KP, D1KP - P1KP )
               ELSE
                  fill_sbb_tbl( cIdKonto, "", konto->naz, D1PS, P1PS, D1KP, P1KP, D1S, P1S )
               ENDIF
            ENDIF

         ENDDO  // sin konto

         IF PRow() > 61 + gpStranica
            FF
            ZaglSan( cFormat )
         ENDIF

         @ PRow() + 1, 4 SAY Replicate( "=", REP1_LEN - 4 )
         @ PRow() + 1, 4 SAY ++B2 PICTURE '9999';?? "."
         @ PRow(), PCol() + 1 SAY cSinKonto
         SELECT KONTO
         hseek cSinKonto
         IF cFormat == "1"
            @ PRow(), PCol() + 1 SAY Left( naz, 50 )
         ELSE
            @ PRow(), PCol() + 1 SAY Left( naz, 44 )       // 45
         ENDIF
         SELECT SUBAN
         @ PRow(), nCol1    SAY D2PS PICTURE PicD
         @ PRow(), PCol() + 1 SAY P2PS PICTURE PicD
         IF cFormat == "1"
            @ PRow(), PCol() + 1 SAY D2TP PICTURE PicD
            @ PRow(), PCol() + 1 SAY P2TP PICTURE PicD
         ENDIF
         @ PRow(), PCol() + 1 SAY D2KP PICTURE PicD
         @ PRow(), PCol() + 1 SAY P2KP PICTURE PicD
         @ PRow(), PCol() + 1 SAY D2S PICTURE PicD
         @ PRow(), PCol() + 1 SAY P2S PICTURE PicD
         @ PRow() + 1, 4 SAY Replicate( "=", REP1_LEN - 4 )

         SELECT SUBAN

         D3PS += D2PS;P3PS += P2PS;D3TP += D2TP;P3TP += P2TP;D3KP += D2KP;P3KP += P2KP

         IF lExpRpt
            IF lBBSkraceni
               fill_ssbb_tbl( cSinKonto, "", konto->naz, D2KP, P2KP, D2KP - P2KP )
            ELSE
               fill_sbb_tbl( cSinKonto, "", konto->naz, D2PS, P2PS, D2KP, P2KP, D2S, P2S )
            ENDIF
         ENDIF

      ENDDO  // klasa konto

      SELECT BBKLAS
      APPEND BLANK
      REPLACE IdKlasa WITH cKlKonto, ;
         PocDug  WITH D3PS, ;
         PocPot  WITH P3PS, ;
         TekPDug WITH D3TP, ;
         TekPPot WITH P3TP, ;
         KumPDug WITH D3KP, ;
         KumPPot WITH P3KP, ;
         SalPDug WITH D3S, ;
         SalPPot WITH P3S
      SELECT SUBAN

      IF cPodKlas == "D"
         ? th5
         ? "UKUPNO KLASA " + cklkonto
         @ PRow(), nCol1    SAY D3PS PICTURE PicD
         @ PRow(), PCol() + 1 SAY P3PS PICTURE PicD
         IF cFormat == "1"
            @ PRow(), PCol() + 1 SAY D3TP PICTURE PicD
            @ PRow(), PCol() + 1 SAY P3TP PICTURE PicD
         ENDIF
         @ PRow(), PCol() + 1 SAY D3KP PICTURE PicD
         @ PRow(), PCol() + 1 SAY P3KP PICTURE PicD
         @ PRow(), PCol() + 1 SAY D3S PICTURE PicD
         @ PRow(), PCol() + 1 SAY P3S PICTURE PicD
         ? th5
      ENDIF

      D4PS += D3PS;P4PS += P3PS;D4TP += D3TP;P4TP += P3TP;D4KP += D3KP;P4KP += P3KP

      IF lExpRpt
         IF lBBSkraceni
            fill_ssbb_tbl( cKlKonto, "", konto->naz, D3KP, P3KP, D3KP - P3KP )
         ELSE
            fill_sbb_tbl( cKlKonto, "", konto->naz, D3PS, P3PS, D3KP, P3KP, D3S, P3S )
         ENDIF
      ENDIF

   ENDDO

   IF PRow() > 59 + gpStranica
      FF
      ZaglSan( cFormat )
   ENDIF

   ? th5
   @ PRow() + 1, 6 SAY "UKUPNO:"
   @ PRow(), nCol1 SAY D4PS PICTURE PicD
   @ PRow(), PCol() + 1 SAY P4PS PICTURE PicD
   IF cFormat == "1"
      @ PRow(), PCol() + 1 SAY D4TP PICTURE PicD
      @ PRow(), PCol() + 1 SAY P4TP PICTURE PicD
   ENDIF
   @ PRow(), PCol() + 1 SAY D4KP PICTURE PicD
   @ PRow(), PCol() + 1 SAY P4KP PICTURE PicD
   @ PRow(), PCol() + 1 SAY D4S PICTURE PicD
   @ PRow(), PCol() + 1 SAY P4S PICTURE PicD
   ? th5

   IF lExpRpt
      IF lBBSkraceni
         fill_ssbb_tbl( "UKUPNO", "", "", D4KP, P4KP, D4KP - P4KP )
      ELSE
         fill_sbb_tbl( "UKUPNO", "", "", D4PS, P4PS, D4KP, P4KP, D4S, P4S )
      ENDIF
   ENDIF

   IF PRow() > 55 + gpStranica; FF; ELSE; ?;?; ENDIF

   ?? "REKAPITULACIJA PO KLASAMA NA DAN:"; @ PRow(), PCol() + 2 SAY Date()
   ? M6
   ? M7
   ? M8
   ? M9
   ? M10

   SELECT BBKLAS
   GO TOP
   nPocDug := nPocPot := nTekPDug := nTekPPot := nKumPDug := nKumPPot := nSalPDug := nSalPPot := 0

   DO WHILE not_key_esc() .AND. !Eof()
      IF PRow() > 63 + gpStranica; FF; ENDIF
      @ PRow() + 1, 4      SAY IdKlasa
      @ PRow(), 10       SAY PocDug               PICTURE PicD
      @ PRow(), PCol() + 1 SAY PocPot               PICTURE PicD
      @ PRow(), PCol() + 1 SAY TekPDug              PICTURE PicD
      @ PRow(), PCol() + 1 SAY TekPPot              PICTURE PicD
      @ PRow(), PCol() + 1 SAY KumPDug              PICTURE PicD
      @ PRow(), PCol() + 1 SAY KumPPot              PICTURE PicD
      @ PRow(), PCol() + 1 SAY SalPDug              PICTURE PicD
      @ PRow(), PCol() + 1 SAY SalPPot              PICTURE PicD

      nPocDug   += PocDug
      nPocPot   += PocPot
      nTekPDug  += TekPDug
      nTekPPot  += TekPPot
      nKumPDug  += KumPDug
      nKumPPot  += KumPPot
      nSalPDug  += SalPDug
      nSalPPot  += SalPPot
      SKIP
   ENDDO

   IF PRow() > 59 + gpStranica; FF; ENDIF
   ? M10
   ? "UKUPNO:"
   @ PRow(), 10 SAY  nPocDug    PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nPocPot    PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nTekPDug   PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nTekPPot   PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nKumPDug   PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nKumPPot   PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nSalPDug   PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nSalPPot   PICTURE PicD
   ? M10

   FF

   ENDPRINT

   IF lExpRpt
      tbl_export( cLaunch )
   ENDIF

   RETURN




/*  ZaglSan()
 *   Zaglavlje strane subanalitickog bruto bilansa
 */

FUNCTION ZaglSan( cFormat )

   IF cFormat == nil
      cFormat := "2"
   ENDIF

   ?

   IF cFormat $ "1#3"
      ? "#%LANDS#"
   ENDIF

   P_COND2

   ?? "FIN: SUBANALITICKI BRUTO BILANS U VALUTI '" + Trim( cBBV ) + "'"
   IF !( Empty( dDatod ) .AND. Empty( dDatDo ) )
      ?? " ZA PERIOD OD", dDatOd, "-", dDatDo
   ENDIF
   ?? " NA DAN: "; ?? Date()
   @ PRow(), REP1_LEN - 15 SAY "Str:" + Str( ++nStr, 3 )

   IF gNW == "D"
      ? "Firma:", gFirma, gNFirma
   ELSE
      ? "Firma:"
      @ PRow(), PCol() + 2 SAY cIdFirma
      SELECT PARTN
      HSEEK cIdFirma
      @ PRow(), PCol() + 2 SAY Naz; @ PRow(), PCol() + 2 SAY Naz2
   ENDIF

   IF gRJ == "D" .AND. Len( cIdRJ ) <> 0
      ? "Radna jedinica ='" + cIdRj + "'"
   ENDIF

   ? th1
   ? th2
   ? th3
   ? th4
   ? th5

   SELECT SUBAN

   RETURN



/*  AnalBB()
 *   Analiticki bruto bilans
 */

FUNCTION AnalBB()

   PRIVATE A1, D4PS, P4PS, D4TP, P4TP, D4KP, P4KP, D4S, P4S

   cIdFirma := gFirma

   O_KONTO
   O_PARTN

   qqKonto := Space( 100 )
   dDatOd := dDatDo := CToD( "" )
   PRIVATE cFormat := "2", cPodKlas := "N"
   Box( "", 8, 60 )
   SET CURSOR ON
   DO WHILE .T.
      @ m_x + 1, m_y + 2 SAY "ANALITICKI BRUTO BILANS"
      IF gNW == "D"
         @ m_x + 2, m_y + 2 SAY "Firma "; ?? gFirma, "-", gNFirma
      ELSE
         @ m_x + 2, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| Empty( cIdFirma ) .OR. P_Firma( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
      ENDIF
      @ m_x + 3, m_y + 2 SAY "Konto " GET qqKonto PICT "@!S50"
      @ m_x + 4, m_y + 2 SAY "Od datuma :" GET dDatOD
      @ m_x + 4, Col() + 2 SAY "do" GET dDatDo
      @ m_x + 6, m_y + 2 SAY "Format izvjestaja A3/A4 (1/2)" GET cFormat
      @ m_x + 7, m_y + 2 SAY "Klase unutar glavnog izvjestaja (D/N)" GET cPodKlas VALID cPodKlas $ "DN" PICT "@!"
      cIdRJ := ""
      IF gRJ == "D" .AND. gSAKrIz == "D"
         cIdRJ := "999999"
         @ m_x + 8, m_y + 2 SAY "Radna jedinica (999999-sve): " GET cIdRj
      ENDIF
      READ; ESC_BCR
      aUsl1 := Parsiraj( qqKonto, "IdKonto" )
      IF aUsl1 <> NIL; exit; ENDIF
   ENDDO
   BoxC()

   cidfirma := Trim( cidfirma )

   IF cIdRj == "999999"; cIdrj := ""; ENDIF
   IF gRJ == "D" .AND. gSAKrIz == "D" .AND. "." $ cidrj
      cidrj := Trim( StrTran( cidrj, ".", "" ) )
      // odsjeci ako je tacka. prakticno "01. " -> sve koje pocinju sa  "01"
   ENDIF

   IF cFormat == "1"
      M1 := "------ ----------- --------------------------------------------------------- ------------------------------- ------------------------------- ------------------------------- -------------------------------"
      M2 := "*REDNI*   KONTO   *                NAZIV ANALITICKOG KONTA                  *        POCETNO STANJE         *         TEKUCI PROMET         *       KUMULATIVNI PROMET      *            SALDO             *"
      M3 := "                                                                             ------------------------------- ------------------------------- ------------------------------- -------------------------------"
      M4 := "*BROJ *           *                                                         *    DUGUJE     *   POTRAZUJE   *    DUGUJE     *   POTRAZUJE   *    DUGUJE     *   POTRAZUJE   *    DUGUJE     *   POTRAZUJE  *"
      M5 := "------ ----------- --------------------------------------------------------- --------------- --------------- --------------- --------------- --------------- --------------- --------------- ---------------"
   ELSE
      M1 := "------ ----------- ---------------------------------------- ------------------------------- ------------------------------- -------------------------------"
      M2 := "*REDNI*   KONTO   *         NAZIV ANALITICKOG KONTA        *        POCETNO STANJE         *       KUMULATIVNI PROMET      *            SALDO             *"
      M3 := "                                                            ------------------------------- ------------------------------- -------------------------------"
      M4 := "*BROJ *           *                                        *    DUGUJE     *   POTRAZUJE   *    DUGUJE     *   POTRAZUJE   *    DUGUJE     *   POTRAZUJE  *"
      M5 := "------ ----------- ---------------------------------------- --------------- --------------- --------------- --------------- --------------- ---------------"
   ENDIF

   O_BBKLAS
   IF gRJ == "D" .AND. gSAKrIz == "D" .AND. Len( cIdRJ ) <> 0
      SintFilt( .F., "IDRJ='" + cIdRJ + "'" )
   ELSE
      O_ANAL
   ENDIF

   SELECT BBKLAS; ZAP

   SELECT ANAL

   cFilter := ""

   IF !( Empty( qqkonto ) )
      IF !( Empty( dDatOd ) .AND. Empty( dDatDo ) )
         cFilter += ( iif( Empty( cFilter ), "", ".and." ) + ;
            aUsl1 + ".and. DATNAL>=" + cm2str( dDatOd ) + " .and. DATNAL<=" + cm2str( dDatDo ) )
      ELSE
         cFilter += ( iif( Empty( cFilter ), "", ".and." ) + aUsl1 )
      ENDIF
   ELSEIF !( Empty( dDatOd ) .AND. Empty( dDatDo ) )
      cFilter += ( iif( Empty( cFilter ), "", ".and." ) + ;
         "DATNAL>=" + cm2str( dDatOd ) + " .and. DATNAL<=" + cm2str( dDatDo ) )
   ENDIF

   IF Len( cIdFirma ) < 2
      SELECT ANAL
      Box(, 2, 30 )
      nSlog := 0; nUkupno := RECCOUNT2()
      cFilt := IF( Empty( cFilter ), "IDFIRMA=" + cm2str( cIdFirma ), cFilter + ".and.IDFIRMA=" + cm2str( cIdFirma ) )
      cSort1 := "IdKonto+dtos(DatNal)"
      INDEX ON &cSort1 TO "ANATMP" FOR &cFilt Eval( TekRec2() ) EVERY 1
      GO TOP
      BoxC()
   ELSE
      SET FILTER TO &cFilter
      HSEEK cIdFirma
   ENDIF

   EOF CRET

   nStr := 0

   BBMnoziSaK()

   START PRINT CRET

   B := 0

   D1S := D2S := D3S := D4S := P1S := P2S := P3S := P4S := 0

   D4PS := P4PS := D4TP := P4TP := D4KP := P4KP := D4S := P4S := 0

   nCol1 := 50

   DO WHILE not_key_esc() .AND. !Eof() .AND. IdFirma = cIdFirma

      IF PRow() == 0; BrBil_21(); ENDIF

      cKlKonto := Left( IdKonto, 1 )
      D3PS := P3PS := D3TP := P3TP := D3KP := P3KP := D3S := P3S := 0
      DO WHILE not_key_esc() .AND. !Eof() .AND. IdFirma = cIdFirma .AND. cKlKonto == Left( IdKonto, 1 ) // kl konto

         cSinKonto := Left( idkonto, 3 )
         D2PS := P2PS := D2TP := P2TP := D2KP := P2KP := D2S := P2S := 0
         DO WHILE not_key_esc() .AND. !Eof() .AND. IdFirma = cIdFirma .AND. cSinKonto == Left( idkonto, 3 ) // sin konto

            cIdKonto := IdKonto

            D1PS := P1PS := D1TP := P1TP := D1KP := P1KP := D1S := P1S := 0
            DO WHILE not_key_esc() .AND. !Eof() .AND. IdFirma = cIdFirma .AND. cIdKonto == IdKonto // konto
               IF cTip == ValDomaca(); Dug := DugBHD * nBBK; Pot := PotBHD * nBBK; else; Dug := DUGDEM; Pot := POTDEM; ENDIF
               D1KP = D1KP + Dug
               P1KP = P1KP + Pot
               IF IdVN = "00"
                  D1PS += Dug; P1PS += Pot
               ELSE
                  D1TP += Dug; P1TP += Pot
               ENDIF
               SKIP
            ENDDO   // konto

            @ PRow() + 1, 1 SAY ++B PICTURE '9999';?? "."
            @ PRow(), 10 SAY cIdKonto

            SELECT KONTO
            HSEEK cIdKonto
            IF cFormat == "1"
               @ PRow(), 19 SAY naz
            ELSE
               @ PRow(), 19 SAY PadR( naz, 40 )
            ENDIF
            SELECT ANAL

            nCol1 := PCol() + 1
            @ PRow(), PCol() + 1 SAY D1PS PICTURE PicD
            @ PRow(), PCol() + 1 SAY P1PS PICTURE PicD
            IF cFormat == "1"
               @ PRow(), PCol() + 1 SAY D1TP PICTURE PicD
               @ PRow(), PCol() + 1 SAY P1TP PICTURE PicD
            ENDIF
            @ PRow(), PCol() + 1 SAY D1KP PICTURE PicD
            @ PRow(), PCol() + 1 SAY P1KP PICTURE PicD

            D1S = D1KP - P1KP
            IF D1S >= 0
               P1S := 0
               D2S += D1S; D3S += D1S; D4S += D1S
            ELSE
               P1S := -D1S; D1S := 0
               P1S := P1KP - D1KP
               P2S += P1S
               P3S += P1S; P4S += P1S
            ENDIF
            @ PRow(), PCol() + 1 SAY D1S PICTURE PicD
            @ PRow(), PCol() + 1 SAY P1S PICTURE PicD

            D2PS = D2PS + D1PS
            P2PS = P2PS + P1PS
            D2TP = D2TP + D1TP
            P2TP = P2TP + P1TP
            D2KP = D2KP + D1KP
            P2KP = P2KP + P1KP
            IF PRow() > 65 + gpStranica; FF;BrBil_21(); ENDIF

         ENDDO  // sinteticki konto
         IF PRow() > 61 + gpStranica; FF; BrBil_21(); ENDIF

         ? M5
         @ PRow() + 1, 10 SAY cSinKonto
         @ PRow(), nCol1    SAY D2PS PICTURE PicD
         @ PRow(), PCol() + 1 SAY P2PS PICTURE PicD
         IF cFormat == "1"
            @ PRow(), PCol() + 1 SAY D2TP PICTURE PicD
            @ PRow(), PCol() + 1 SAY P2TP PICTURE PicD
         ENDIF
         @ PRow(), PCol() + 1 SAY D2KP PICTURE PicD
         @ PRow(), PCol() + 1 SAY P2KP PICTURE PicD
         @ PRow(), PCol() + 1 SAY D2S PICTURE PicD
         @ PRow(), PCol() + 1 SAY P2S PICTURE PicD
         ? M5

         D3PS = D3PS + D2PS; P3PS = P3PS + P2PS
         D3TP = D3TP + D2TP; P3TP = P3TP + P2TP
         D3KP = D3KP + D2KP; P3KP = P3KP + P2KP

      ENDDO  // klasa konto

      SELECT BBKLAS
      APPEND BLANK
      REPLACE IdKlasa WITH cKlKonto, ;
         PocDug  WITH D3PS, ;
         PocPot  WITH P3PS, ;
         TekPDug WITH D3TP, ;
         TekPPot WITH P3TP, ;
         KumPDug WITH D3KP, ;
         KumPPot WITH P3KP, ;
         SalPDug WITH D3S, ;
         SalPPot WITH P3S

      SELECT ANAL

      IF cPodKlas == "D"
         ? M5
         ? "UKUPNO KLASA " + cklkonto
         @ PRow(), nCol1    SAY D3PS PICTURE PicD
         @ PRow(), PCol() + 1 SAY P3PS PICTURE PicD
         IF cFormat == "1"
            @ PRow(), PCol() + 1 SAY D3TP PICTURE PicD
            @ PRow(), PCol() + 1 SAY P3TP PICTURE PicD
         ENDIF
         @ PRow(), PCol() + 1 SAY D3KP PICTURE PicD
         @ PRow(), PCol() + 1 SAY P3KP PICTURE PicD
         @ PRow(), PCol() + 1 SAY D3S PICTURE PicD
         @ PRow(), PCol() + 1 SAY P3S PICTURE PicD
         ? M5
      ENDIF
      D4PS += D3PS; P4PS += P3PS; D4TP += D3TP; P4TP += P3TP; D4KP += D3KP; P4KP += P3KP

   ENDDO

   IF PRow() > 61 + gpStranica; FF ; BrBil_21(); ENDIF
   ? M5
   ? "UKUPNO:"
   @ PRow(), nCol1    SAY D4PS PICTURE PicD
   @ PRow(), PCol() + 1 SAY P4PS PICTURE PicD
   IF cFormat == "1"
      @ PRow(), PCol() + 1 SAY D4TP PICTURE PicD
      @ PRow(), PCol() + 1 SAY P4TP PICTURE PicD
   ENDIF
   @ PRow(), PCol() + 1 SAY D4KP PICTURE PicD
   @ PRow(), PCol() + 1 SAY P4KP PICTURE PicD
   @ PRow(), PCol() + 1 SAY D4S PICTURE PicD
   @ PRow(), PCol() + 1 SAY P4S PICTURE PicD
   ? M5

   IF PRow() > 55 + gpStranica; FF; else; ?;?; ENDIF

   ?? "REKAPITULACIJA PO KLASAMA NA DAN: ";?? Date()
   ?  M6
   ?  M7
   ?  M8
   ?  M9
   ?  M10

   SELECT BBKLAS; GO TOP


   nPocDug := nPocPot := nTekPDug := nTekPPot := nKumPDug := nKumPPot := nSalPDug := nSalPPot := 0

   DO WHILE not_key_esc() .AND. !Eof()
      @ PRow() + 1, 4   SAY IdKlasa
      @ PRow(), 10       SAY PocDug               PICTURE PicD
      @ PRow(), PCol() + 1 SAY PocPot               PICTURE PicD
      @ PRow(), PCol() + 1 SAY TekPDug              PICTURE PicD
      @ PRow(), PCol() + 1 SAY TekPPot              PICTURE PicD
      @ PRow(), PCol() + 1 SAY KumPDug              PICTURE PicD
      @ PRow(), PCol() + 1 SAY KumPPot              PICTURE PicD
      @ PRow(), PCol() + 1 SAY SalPDug              PICTURE PicD
      @ PRow(), PCol() + 1 SAY SalPPot              PICTURE PicD

      nPocDug   += PocDug
      nPocPot   += PocPot
      nTekPDug  += TekPDug
      nTekPPot  += TekPPot
      nKumPDug  += KumPDug
      nKumPPot  += KumPPot
      nSalPDug  += SalPDug
      nSalPPot  += SalPPot
      SKIP
   ENDDO

   ? M10
   ? "UKUPNO:"
   @ PRow(), 10       SAY  nPocDug    PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nPocPot    PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nTekPDug   PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nTekPPot   PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nKumPDug   PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nKumPPot   PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nSalPDug   PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nSalPPot   PICTURE PicD
   ? M10

   FF

   ENDPRINT

   closeret

   RETURN


/*  BrBil_21()
 *   Zaglavlje analitickog bruto bilansa
 */

FUNCTION BrBil_21()

   ?
   P_COND2
   ?? "FIN: ANALITICKI BRUTO BILANS U VALUTI '" + Trim( cBBV ) + "'"
   IF !( Empty( dDatod ) .AND. Empty( dDatDo ) )
      ?? " ZA PERIOD OD", dDatOd, "-", dDatDo
   ENDIF
   ?? " NA DAN: "; ?? Date()
   @ PRow(), IF( cFormat == "1", 220, 142 ) SAY "Str:" + Str( ++nStr, 3 )

   IF gNW == "D"
      ? "Firma:", gFirma, gNFirma
   ELSE
      SELECT PARTN
      HSEEK  cIdFirma
      ? "Firma:", cIdFirma, partn->naz, partn->naz2
   ENDIF

   IF gRJ == "D" .AND. gSAKrIz == "D" .AND. Len( cIdRJ ) <> 0
      ? "Radna jedinica ='" + cIdRj + "'"
   ENDIF

   SELECT ANAL

   ? M1
   ? M2
   ? M3
   ? M4
   ? M5

   RETURN



/*  SintBB()
 *   Sinteticki bruto bilans
 */

FUNCTION SintBB()

   LOCAL nPom

   cIdFirma := gFirma

   O_PARTN
   Box( "", 8, 60 )
   SET CURSOR ON
   qqKonto := Space( 100 )
   dDatOd := dDatDo := CToD( "" )
   PRIVATE cFormat := "2", cPodKlas := "N"

   DO WHILE .T.
      @ m_x + 1, m_y + 2 SAY "SINTETICKI BRUTO BILANS"
      IF gNW == "D"
         @ m_x + 2, m_y + 2 SAY "Firma "; ?? gFirma, "-", gNFirma
      ELSE
         @ m_x + 2, m_y + 2 SAY "Firma " GET cIdFirma valid {|| Empty( cIdFirma ) .OR. P_Firma( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
      ENDIF
      @ m_x + 3, m_y + 2 SAY "Konto " GET qqKonto    PICT "@!S50"
      @ m_x + 4, m_y + 2 SAY "Od datuma :" GET dDatOD
      @ m_x + 4, Col() + 2 SAY "do" GET dDatDo
      @ m_x + 6, m_y + 2 SAY "Format izvjestaja A3/A4 (1/2)" GET cFormat
      @ m_x + 7, m_y + 2 SAY "Klase unutar glavnog izvjestaja (D/N)" GET cPodKlas VALID cPodKlas $ "DN" PICT "@!"
      cIdRJ := ""
      IF gRJ == "D" .AND. gSAKrIz == "D"
         cIdRJ := "999999"
         @ m_x + 8, m_y + 2 SAY "Radna jedinica (999999-sve): " GET cIdRj
      ENDIF
      READ; ESC_BCR
      aUsl1 := Parsiraj( qqKonto, "IdKonto" )
      IF aUsl1 <> NIL; exit; ENDIF
   ENDDO

   cidfirma := Trim( cidfirma )

   BoxC()

   IF cIdRj == "999999"; cidrj := ""; ENDIF
   IF gRJ == "D" .AND. gSAKrIz == "D" .AND. "." $ cidrj
      cidrj := Trim( StrTran( cidrj, ".", "" ) )
      // odsjeci ako je tacka. prakticno "01. " -> sve koje pocinju sa  "01"
   ENDIF

   IF cFormat == "1"
      M1 := "------ ----------- --------------------------------------------------------- ------------------------------- ------------------------------- ------------------------------- -------------------------------"
      M2 := "*REDNI*   KONTO   *                  NAZIV SINTETICKOG KONTA                *        POCETNO STANJE         *         TEKUCI PROMET         *       KUMULATIVNI PROMET      *            SALDO             *"
      M3 := "                                                                             ------------------------------- ------------------------------- ------------------------------- -------------------------------"
      M4 := "*BROJ *           *                                                         *    DUGUJE     *   POTRAZUJE   *    DUGUJE     *   POTRAZUJE   *    DUGUJE     *   POTRAZUJE   *    DUGUJE     *   POTRAZUJE  *"
      M5 := "------ ----------- --------------------------------------------------------- --------------- --------------- --------------- --------------- --------------- --------------- --------------- ---------------"
   ELSE
      M1 := "---- ------------------------------ ------------------------------- ------------------------------- -------------------------------"
      M2 := "    *                              *        POCETNO STANJE         *       KUMULATIVNI PROMET      *            SALDO             *"
      M3 := "    *    SINTETICKI KONTO           ------------------------------- ------------------------------- -------------------------------"
      M4 := "    *                              *    DUGUJE     *   POTRAZUJE   *    DUGUJE     *   POTRAZUJE   *    DUGUJE     *   POTRAZUJE  *"
      M5 := "---- ------------------------------ --------------- --------------- --------------- --------------- --------------- ---------------"
   ENDIF


   O_KONTO
   O_BBKLAS

   IF gRJ == "D" .AND. gSAKrIz == "D" .AND. Len( cIdRJ ) <> 0
      SintFilt( .T., "IDRJ='" + cIdRJ + "'" )
   ELSE
      O_SINT
   ENDIF

   SELECT BBKLAS; ZAP
   SELECT SINT
   cFilter := ""
   IF !( Empty( qqkonto ) )
      IF !( Empty( dDatOd ) .AND. Empty( dDatDo ) )
         cFilter := aUsl1 + ".and. DATNAL>=" + cm2str( dDatOd ) + " .and. DATNAL<=" + cm2str( dDatDo )
      ELSE
         cFilter := aUsl1
      ENDIF
   ELSEIF !( Empty( dDatOd ) .AND. Empty( dDatDo ) )
      cFilter := "DATNAL>=" + cm2str( dDatOd ) + " .and. DATNAL<=" + cm2str( dDatDo )
   ENDIF

   IF Len( cIdFirma ) < 2
      SELECT SINT
      Box(, 2, 30 )
      nSlog := 0; nUkupno := RECCOUNT2()
      cFilt := IF( Empty( cFilter ), "IDFIRMA=" + cm2str( cIdFirma ), cFilter + ".and.IDFIRMA=" + cm2str( cIdFirma ) )
      cSort1 := "IdKonto+dtos(DatNal)"
      INDEX ON &cSort1 TO "SINTMP" FOR &cFilt Eval( TekRec2() ) EVERY 1
      GO TOP
      BoxC()
   ELSE
      IF !Empty( cFilter )
         SET FILTER TO &cFilter
      ENDIF
      HSEEK cIdFirma
   ENDIF

   EOF CRET


   nStr := 0

   BBMnoziSaK()

   START PRINT CRET

   B := 1

   D1S := D2S := D3S := D4S := P1S := P2S := P3S := P4S := 0


   D4PS := P4PS := D4TP := P4TP := D4KP := P4KP := D4S := P4S := 0
   nStr := 0

   nCol1 := 50

   DO WHILE not_key_esc() .AND. !Eof() .AND. IdFirma = cIdFirma

      IF PRow() == 0; BrBil_31(); ENDIF

      cKlKonto := Left( IdKonto, 1 )

      D3PS := P3PS := D3TP := P3TP := D3KP := P3KP := D3S := P3S := 0
      DO WHILE not_key_esc() .AND. !Eof() .AND. IdFirma = cIdFirma .AND. cKlKonto == Left( IdKonto, 1 )

         cIdKonto := IdKonto
         D1PS := P1PS := D1TP := P1TP := D1KP := P1KP := D1S := P1S := 0
         DO WHILE not_key_esc() .AND. !Eof() .AND. IdFirma = cIdFirma .AND. cIdKonto == Left( IdKonto, 3 )
            IF cTip == ValDomaca(); Dug := DugBHD * nBBK; Pot := PotBHD * nBBK; else; Dug := DUGDEM; Pot := POTDEM; ENDIF
            D1KP += Dug
            P1KP += Pot
            IF IdVN = "00"
               D1PS += Dug; P1PS += Pot
            ELSE
               D1TP += Dug; P1TP += Pot
            ENDIF
            SKIP
         ENDDO // konto

         IF PRow() > 63 + gpStranica; FF ; BrBil_31(); ENDIF

         IF cFormat == "1"
            @ PRow() + 1, 1 SAY B PICTURE '9999'; ?? "."
            @ PRow(), 10 SAY cIdKonto
            SELECT KONTO
            HSEEK cIdKonto
            @ PRow(), 19 SAY naz
            nCol1 := PCol() + 1
            @ PRow(), PCol() + 1 SAY D1PS PICTURE PicD
            @ PRow(), PCol() + 1 SAY P1PS PICTURE PicD
            @ PRow(), PCol() + 1 SAY D1TP PICTURE PicD
            @ PRow(), PCol() + 1 SAY P1TP PICTURE PicD
            @ PRow(), PCol() + 1 SAY D1KP PICTURE PicD
            @ PRow(), PCol() + 1 SAY P1KP PICTURE PicD
            D1S := D1KP - P1KP
            IF D1S >= 0
               P1S := 0; D3S += D1S; D4S += D1S
            ELSE
               P1S := -D1S; D1S := 0
               P3S += P1S; P4S += P1S
            ENDIF
            @ PRow(), PCol() + 1 SAY D1S PICTURE PicD
            @ PRow(), PCol() + 1 SAY P1S PICTURE PicD

         ELSE  // cformat=="2" - A4

            @ PRow() + 1, 1 SAY cIdKonto
            SELECT KONTO
            HSEEK cIdKonto

            PRIVATE aRez := SjeciStr( naz, 30 )
            PRIVATE nColNaz := PCol() + 1
            @ PRow(), PCol() + 1 SAY PadR( aRez[ 1 ], 30 )
            nCol1 := PCol() + 1
            @ PRow(), PCol() + 1 SAY D1PS PICTURE PicD
            @ PRow(), PCol() + 1 SAY P1PS PICTURE PicD
            @ PRow(), PCol() + 1 SAY D1KP PICTURE PicD
            @ PRow(), PCol() + 1 SAY P1KP PICTURE PicD
            D1S := D1KP - P1KP
            IF D1S >= 0
               P1S := 0; D3S += D1S; D4S += D1S
            ELSE
               P1S := -D1S; D1S := 0
               P3S += P1S; P4S += P1S
            ENDIF
            @ PRow(), PCol() + 1 SAY D1S PICTURE PicD
            @ PRow(), PCol() + 1 SAY P1S PICTURE PicD

            IF Len( aRez ) == 2
               @ PRow() + 1, nColNaz SAY PadR( aRez[ 2 ], 30 )
            ENDIF
         ENDIF // cformat

         SELECT SINT
         D3PS += D1PS; P3PS += P1PS; D3TP += D1TP; P3TP += P1TP; D3KP += D1KP; P3KP += P1KP

         ++B


      ENDDO // klasa konto

      SELECT BBKLAS
      APPEND BLANK
      REPLACE IdKlasa WITH cKlKonto, ;
         PocDug  WITH D3PS, ;
         PocPot  WITH P3PS, ;
         TekPDug WITH D3TP, ;
         TekPPot WITH P3TP, ;
         KumPDug WITH D3KP, ;
         KumPPot WITH P3KP, ;
         SalPDug WITH D3S, ;
         SalPPot WITH P3S

      SELECT SINT

      IF cPodKlas == "D"
         ? M5
         ? "UKUPNO KLASA " + cklkonto
         @ PRow(), nCol1    SAY D3PS PICTURE PicD
         @ PRow(), PCol() + 1 SAY P3PS PICTURE PicD
         IF cFormat == "1"
            @ PRow(), PCol() + 1 SAY D3TP PICTURE PicD
            @ PRow(), PCol() + 1 SAY P3TP PICTURE PicD
         ENDIF
         @ PRow(), PCol() + 1 SAY D3KP PICTURE PicD
         @ PRow(), PCol() + 1 SAY P3KP PICTURE PicD
         @ PRow(), PCol() + 1 SAY D3S PICTURE PicD
         @ PRow(), PCol() + 1 SAY P3S PICTURE PicD
         ? M5
      ENDIF
      D4PS += D3PS; P4PS += P3PS; D4TP += D3TP; P4TP += P3TP; D4KP += D3KP; P4KP += P3KP

   ENDDO

   IF PRow() > 58 + gpStranica; FF ; BrBil_31(); ENDIF
   ? M5
   ? "UKUPNO:"
   @ PRow(), nCol1    SAY D4PS PICTURE PicD
   @ PRow(), PCol() + 1 SAY P4PS PICTURE PicD
   IF cFormat == "1"
      @ PRow(), PCol() + 1 SAY D4TP PICTURE PicD
      @ PRow(), PCol() + 1 SAY P4TP PICTURE PicD
   ENDIF
   @ PRow(), PCol() + 1 SAY D4KP PICTURE PicD
   @ PRow(), PCol() + 1 SAY P4KP PICTURE PicD
   @ PRow(), PCol() + 1 SAY D4S PICTURE PicD
   @ PRow(), PCol() + 1 SAY P4S PICTURE PicD
   ? M5
   nPom := d4ps - p4ps
   @ PRow() + 1, nCol1   SAY iif( nPom > 0, nPom, 0 ) PICTURE PicD
   @ PRow(), PCol() + 1 SAY iif( nPom < 0, -nPom, 0 ) PICTURE PicD

   nPom := d4tp - p4tp
   IF cFormat == "1"
      @ PRow(), PCol() + 1 SAY iif( nPom > 0, nPom, 0 ) PICTURE PicD
      @ PRow(), PCol() + 1 SAY iif( nPom < 0, -nPom, 0 ) PICTURE PicD
   ENDIF

   nPom := d4kp - p4kp
   @ PRow(), PCol() + 1 SAY iif( nPom > 0, nPom, 0 ) PICTURE PicD
   @ PRow(), PCol() + 1 SAY iif( nPom < 0, -nPom, 0 ) PICTURE PicD
   nPom := d4s - p4s
   @ PRow(), PCol() + 1 SAY iif( nPom > 0, nPom, 0 ) PICTURE PicD
   @ PRow(), PCol() + 1 SAY iif( nPom < 0, -nPom, 0 ) PICTURE PicD
   ? M5

   FF

   ?? "REKAPITULACIJA PO KLASAMA NA DAN: "; ?? Date()
   ? IF( cFormat == "1", M6, "--------- --------------- --------------- --------------- --------------- --------------- ---------------" )
   ? IF( cFormat == "1", M7, "*        *          POZETNO STANJE       *        KUMULATIVNI PROMET     *            SALDO             *" )
   ? IF( cFormat == "1", M8, "  KLASA   ------------------------------- ------------------------------- -------------------------------" )
   ? IF( cFormat == "1", M9, "*        *    DUGUJE     *   POTRAZUJE   *    DUGUJE     *   POTRAZUJE   *     DUGUJE    *    POTRAZUJE *" )
   ? IF( cFormat == "1", M10, "--------- --------------- --------------- --------------- --------------- --------------- ---------------" )

   SELECT BBKLAS; GO TOP


   nPocDug := nPocPot := nTekPDug := nTekPPot := nKumPDug := nKumPPot := nSalPDug := nSalPPot := 0

   DO WHILE not_key_esc() .AND. !Eof()
      @ PRow() + 1, 4      SAY IdKlasa
      @ PRow(), 10       SAY PocDug               PICTURE PicD
      @ PRow(), PCol() + 1 SAY PocPot               PICTURE PicD
      IF cFormat == "1"
         @ PRow(), PCol() + 1 SAY TekPDug              PICTURE PicD
         @ PRow(), PCol() + 1 SAY TekPPot              PICTURE PicD
      ENDIF
      @ PRow(), PCol() + 1 SAY KumPDug              PICTURE PicD
      @ PRow(), PCol() + 1 SAY KumPPot              PICTURE PicD
      @ PRow(), PCol() + 1 SAY SalPDug              PICTURE PicD
      @ PRow(), PCol() + 1 SAY SalPPot              PICTURE PicD

      nPocDug   += PocDug
      nPocPot   += PocPot
      nTekPDug  += TekPDug
      nTekPPot  += TekPPot
      nKumPDug  += KumPDug
      nKumPPot  += KumPPot
      nSalPDug  += SalPDug
      nSalPPot  += SalPPot
      SKIP
   ENDDO

   ? IF( cFormat == "1", M10, "--------- --------------- --------------- --------------- --------------- --------------- ---------------" )
   ? "UKUPNO:"
   @ PRow(), 10       SAY  nPocDug    PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nPocPot    PICTURE PicD
   IF cFormat == "1"
      @ PRow(), PCol() + 1 SAY  nTekPDug   PICTURE PicD
      @ PRow(), PCol() + 1 SAY  nTekPPot   PICTURE PicD
   ENDIF
   @ PRow(), PCol() + 1 SAY  nKumPDug   PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nKumPPot   PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nSalPDug   PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nSalPPot   PICTURE PicD
   ? IF( cFormat == "1", M10, "--------- --------------- --------------- --------------- --------------- --------------- ---------------" )

   FF

   ENDPRINT
   closeret

   RETURN




/*  BrBil_31()
 *   Zaglavlje sintetickog bruto bilansa
 */

FUNCTION BrBil_31()

   ?
   P_COND2
   ?? "FIN: SINTETICKI BRUTO BILANS U VALUTI '" + Trim( cBBV ) + "'"
   IF !( Empty( dDatod ) .AND. Empty( dDatDo ) )
      ?? " ZA PERIOD OD", dDatOd, "-", dDatDo
   ENDIF
   ?? "  NA DAN: "; ?? Date()
   @ PRow(), 125 SAY "Str." + Str( ++nStr, 3 )

   IF gNW == "D"
      ? "Firma:", gFirma, gNFirma
   ELSE
      SELECT PARTN; HSEEK cIdFirma
      ? "Firma:", cidfirma, partn->naz, partn->naz2
   ENDIF

   IF gRJ == "D" .AND. gSAKrIz == "D" .AND. Len( cIdRJ ) <> 0
      ? "Radna jedinica ='" + cIdRj + "'"
   ENDIF

   SELECT SINT
   ? M1
   ? M2
   ? M3
   ? M4
   ? M5

   RETURN


/*  GrupBB()
 *   Bruto bilans po grupama konta
 */

FUNCTION GrupBB()

   LOCAL nPom

   cIdFirma := gFirma

   O_PARTN
   Box( "", 6, 60 )
   SET CURSOR ON
   qqKonto := Space( 100 )
   dDatOd := dDatDo := CToD( "" )
   PRIVATE cPodKlas := "N"

   DO WHILE .T.
      @ m_x + 1, m_y + 2 SAY "BRUTO BILANS PO GRUPAMA KONTA"
      IF gNW == "D"
         @ m_x + 2, m_y + 2 SAY "Firma "; ?? gFirma, "-", gNFirma
      ELSE
         @ m_x + 2, m_y + 2 SAY "Firma " GET cIdFirma valid {|| Empty( cIdFirma ) .OR. ;
            P_Firma( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
      ENDIF
      @ m_x + 3, m_y + 2 SAY "Konto " GET qqKonto    PICT "@!S50"
      @ m_x + 4, m_y + 2 SAY "Od datuma :" GET dDatOD
      @ m_x + 4, Col() + 2 SAY "do" GET dDatDo
      @ m_x + 5, m_y + 2 SAY "Klase unutar glavnog izvjestaja (D/N)" GET cPodKlas VALID cPodKlas $ "DN" PICT "@!"
      cIdRJ := ""
      IF gRJ == "D" .AND. gSAKrIz == "D"
         cIdRJ := "999999"
         @ m_x + 6, m_y + 2 SAY "Radna jedinica (999999-sve): " GET cIdRj
      ENDIF
      READ; ESC_BCR
      aUsl1 := Parsiraj( qqKonto, "IdKonto" )
      IF aUsl1 <> NIL; exit; ENDIF
   ENDDO

   cidfirma := Trim( cidfirma )

   BoxC()

   IF cIdRj == "999999"; cidrj := ""; ENDIF
   IF gRJ == "D" .AND. gSAKrIz == "D" .AND. "." $ cidrj
      cidrj := Trim( StrTran( cidrj, ".", "" ) )
      // odsjeci ako je tacka. prakticno "01. " -> sve koje pocinju sa  "01"
   ENDIF

   M1 := "------ ----------- ------------------------------- ------------------------------- ------------------------------- -------------------------------"
   M2 := "*REDNI*   GRUPA   *        POCETNO STANJE         *         TEKUCI PROMET         *       KUMULATIVNI PROMET      *            SALDO             *"
   M3 := "          KONTA    ------------------------------- ------------------------------- ------------------------------- -------------------------------"
   M4 := "*BROJ *           *    DUGUJE     *   POTRAZUJE   *    DUGUJE     *   POTRAZUJE   *    DUGUJE     *   POTRAZUJE   *    DUGUJE     *   POTRAZUJE  *"
   M5 := "------ ----------- --------------- --------------- --------------- --------------- --------------- --------------- --------------- ---------------"


   O_KONTO
   O_BBKLAS

   SELECT BBKLAS; ZAP

   IF gRJ == "D" .AND. gSAKrIz == "D" .AND. Len( cIdRJ ) <> 0
      SintFilt( .T., "IDRJ='" + cIdRJ + "'" )
   ELSE
      O_SINT
   ENDIF

   cFilter := ""

   IF !( Empty( qqkonto ) )
      IF !( Empty( dDatOd ) .AND. Empty( dDatDo ) )
         cFilter := aUsl1 + ".and. DATNAL>=" + cm2str( dDatOd ) + " .and. DATNAL<=" + cm2str( dDatDo )
      ELSE
         cFilter := aUsl1
      ENDIF
   ELSEIF !( Empty( dDatOd ) .AND. Empty( dDatDo ) )
      cFilter := "DATNAL>=" + cm2str( dDatOd ) + " .and. DATNAL<=" + cm2str( dDatDo )
   ENDIF

   IF Len( cIdFirma ) < 2
      SELECT SINT
      Box(, 2, 30 )
      nSlog := 0; nUkupno := RECCOUNT2()
      cFilt := IF( Empty( cFilter ), "IDFIRMA=" + cm2str( cIdFirma ), cFilter + ".and.IDFIRMA=" + cm2str( cIdFirma ) )
      cSort1 := "IdKonto+dtos(DatNal)"
      INDEX ON &cSort1 TO "SINTMP" FOR &cFilt Eval( TekRec2() ) EVERY 1
      GO TOP
      BoxC()
   ELSE
      IF !Empty( cFilter )
         SET FILTER TO &cFilter
      ENDIF
      HSEEK cIdFirma
   ENDIF

   EOF CRET

   nStr := 0

   BBMnoziSaK()

   START PRINT CRET

   B := 1

   D1S := D2S := D3S := D4S := P1S := P2S := P3S := P4S := 0


   D4PS := P4PS := D4TP := P4TP := D4KP := P4KP := D4S := P4S := 0
   nStr := 0

   nCol1 := 50

   DO WHILE not_key_esc() .AND. !Eof() .AND. IdFirma = cIdFirma

      IF PRow() == 0; BrBil_41(); ENDIF

      cKlKonto := Left( IdKonto, 1 )

      D3PS := P3PS := D3TP := P3TP := D3KP := P3KP := D3S := P3S := 0
      DO WHILE not_key_esc() .AND. !Eof() .AND. IdFirma = cIdFirma .AND. cKlKonto == Left( IdKonto, 1 )

         cIdKonto := Left( IdKonto, 2 )
         D1PS := P1PS := D1TP := P1TP := D1KP := P1KP := D1S := P1S := 0
         DO WHILE not_key_esc() .AND. !Eof() .AND. IdFirma = cIdFirma .AND. cIdKonto == Left( IdKonto, 2 )
            IF cTip == ValDomaca(); Dug := DugBHD * nBBK; Pot := PotBHD * nBBK; else; Dug := DUGDEM; Pot := POTDEM; ENDIF
            D1KP += Dug
            P1KP += Pot
            IF IdVN = "00"
               D1PS += Dug; P1PS += Pot
            ELSE
               D1TP += Dug; P1TP += Pot
            ENDIF
            SKIP
         ENDDO // konto

         IF PRow() > 63 + gpStranica; FF ; BrBil_41(); ENDIF

         @ PRow() + 1, 1 SAY B PICTURE '9999'; ?? "."
         @ PRow(), 10 SAY PadC( cIdKonto, 8 )
         nCol1 := PCol() + 1
         @ PRow(), PCol() + 1 SAY D1PS PICTURE PicD
         @ PRow(), PCol() + 1 SAY P1PS PICTURE PicD
         @ PRow(), PCol() + 1 SAY D1TP PICTURE PicD
         @ PRow(), PCol() + 1 SAY P1TP PICTURE PicD
         @ PRow(), PCol() + 1 SAY D1KP PICTURE PicD
         @ PRow(), PCol() + 1 SAY P1KP PICTURE PicD
         D1S := D1KP - P1KP
         IF D1S >= 0
            P1S := 0; D3S += D1S; D4S += D1S
         ELSE
            P1S := -D1S; D1S := 0
            P3S += P1S; P4S += P1S
         ENDIF
         @ PRow(), PCol() + 1 SAY D1S PICTURE PicD
         @ PRow(), PCol() + 1 SAY P1S PICTURE PicD


         SELECT SINT
         D3PS += D1PS; P3PS += P1PS; D3TP += D1TP; P3TP += P1TP; D3KP += D1KP; P3KP += P1KP

         ++B


      ENDDO // klasa konto

      SELECT BBKLAS
      APPEND BLANK
      REPLACE IdKlasa WITH cKlKonto, ;
         PocDug  WITH D3PS, ;
         PocPot  WITH P3PS, ;
         TekPDug WITH D3TP, ;
         TekPPot WITH P3TP, ;
         KumPDug WITH D3KP, ;
         KumPPot WITH P3KP, ;
         SalPDug WITH D3S, ;
         SalPPot WITH P3S

      SELECT SINT

      IF cPodKlas == "D"
         ? M5
         ? "UKUPNO KLASA " + cklkonto
         @ PRow(), nCol1    SAY D3PS PICTURE PicD
         @ PRow(), PCol() + 1 SAY P3PS PICTURE PicD
         @ PRow(), PCol() + 1 SAY D3TP PICTURE PicD
         @ PRow(), PCol() + 1 SAY P3TP PICTURE PicD
         @ PRow(), PCol() + 1 SAY D3KP PICTURE PicD
         @ PRow(), PCol() + 1 SAY P3KP PICTURE PicD
         @ PRow(), PCol() + 1 SAY D3S PICTURE PicD
         @ PRow(), PCol() + 1 SAY P3S PICTURE PicD
         ? M5
      ENDIF
      D4PS += D3PS; P4PS += P3PS; D4TP += D3TP; P4TP += P3TP; D4KP += D3KP; P4KP += P3KP

   ENDDO

   IF PRow() > 58 + gpStranica; FF ; BrBil_41(); ENDIF
   ? M5
   ? "UKUPNO:"
   @ PRow(), nCol1    SAY D4PS PICTURE PicD
   @ PRow(), PCol() + 1 SAY P4PS PICTURE PicD
   @ PRow(), PCol() + 1 SAY D4TP PICTURE PicD
   @ PRow(), PCol() + 1 SAY P4TP PICTURE PicD
   @ PRow(), PCol() + 1 SAY D4KP PICTURE PicD
   @ PRow(), PCol() + 1 SAY P4KP PICTURE PicD
   @ PRow(), PCol() + 1 SAY D4S PICTURE PicD
   @ PRow(), PCol() + 1 SAY P4S PICTURE PicD
   ? M5
   nPom := d4ps - p4ps
   @ PRow() + 1, nCol1   SAY iif( nPom > 0, nPom, 0 ) PICTURE PicD
   @ PRow(), PCol() + 1 SAY iif( nPom < 0, -nPom, 0 ) PICTURE PicD

   nPom := d4tp - p4tp
   @ PRow(), PCol() + 1 SAY iif( nPom > 0, nPom, 0 ) PICTURE PicD
   @ PRow(), PCol() + 1 SAY iif( nPom < 0, -nPom, 0 ) PICTURE PicD

   nPom := d4kp - p4kp
   @ PRow(), PCol() + 1 SAY iif( nPom > 0, nPom, 0 ) PICTURE PicD
   @ PRow(), PCol() + 1 SAY iif( nPom < 0, -nPom, 0 ) PICTURE PicD
   nPom := d4s - p4s
   @ PRow(), PCol() + 1 SAY iif( nPom > 0, nPom, 0 ) PICTURE PicD
   @ PRow(), PCol() + 1 SAY iif( nPom < 0, -nPom, 0 ) PICTURE PicD
   ? M5

   FF

   ?? "REKAPITULACIJA PO KLASAMA NA DAN: "; ?? Date()
   ?  M6
   ?  M7
   ?  M8
   ?  M9
   ?  M10

   SELECT BBKLAS; GO TOP


   nPocDug := nPocPot := nTekPDug := nTekPPot := nKumPDug := nKumPPot := nSalPDug := nSalPPot := 0

   DO WHILE not_key_esc() .AND. !Eof()
      @ PRow() + 1, 4      SAY IdKlasa
      @ PRow(), 10       SAY PocDug               PICTURE PicD
      @ PRow(), PCol() + 1 SAY PocPot               PICTURE PicD
      @ PRow(), PCol() + 1 SAY TekPDug              PICTURE PicD
      @ PRow(), PCol() + 1 SAY TekPPot              PICTURE PicD
      @ PRow(), PCol() + 1 SAY KumPDug              PICTURE PicD
      @ PRow(), PCol() + 1 SAY KumPPot              PICTURE PicD
      @ PRow(), PCol() + 1 SAY SalPDug              PICTURE PicD
      @ PRow(), PCol() + 1 SAY SalPPot              PICTURE PicD

      nPocDug   += PocDug
      nPocPot   += PocPot
      nTekPDug  += TekPDug
      nTekPPot  += TekPPot
      nKumPDug  += KumPDug
      nKumPPot  += KumPPot
      nSalPDug  += SalPDug
      nSalPPot  += SalPPot
      SKIP
   ENDDO

   ? M10
   ? "UKUPNO:"
   @ PRow(), 10       SAY  nPocDug    PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nPocPot    PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nTekPDug   PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nTekPPot   PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nKumPDug   PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nKumPPot   PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nSalPDug   PICTURE PicD
   @ PRow(), PCol() + 1 SAY  nSalPPot   PICTURE PicD
   ? M10

   FF

   ENDPRINT
   closeret

   RETURN



/*  BrBil_41()
 *   Zaglavlje bruto bilansa po grupama
 */

FUNCTION BrBil_41()

   ?
   P_COND2
   ?? "FIN.P:BRUTO BILANS PO GRUPAMA KONTA U VALUTI '" + Trim( cBBV ) + "'"
   IF !( Empty( dDatod ) .AND. Empty( dDatDo ) )
      ?? " ZA PERIOD OD", dDatOd, "-", dDatDo
   ENDIF
   ?? "  NA DAN: "; ?? Date()
   @ PRow(), 125 SAY "Str." + Str( ++nStr, 3 )

   IF gNW == "D"
      ? "Firma:", gFirma, gNFirma
   ELSE
      SELECT PARTN; HSEEK cIdFirma
      ? "Firma:", cidfirma, partn->naz, partn->naz2
   ENDIF

   IF gRJ == "D" .AND. gSAKrIz == "D" .AND. Len( cIdRJ ) <> 0
      ? "Radna jedinica ='" + cIdRj + "'"
   ENDIF

   SELECT SINT
   ? M1
   ? M2
   ? M3
   ? M4
   ? M5

   RETURN




/*  BBMnoziSaK()
 *
 */

FUNCTION BBMnoziSaK()

   LOCAL nArr := Select()

   IF cTip == ValDomaca() .AND. ;
         IzFMKIni( "FIN", "BrutoBilansUDrugojValuti", "N", KUMPATH ) == "D"
      Box(, 5, 70 )
      @ m_x + 2, m_y + 2 SAY "Pomocna valuta      " GET cBBV PICT "@!" VALID ImaUSifVal( cBBV )
      @ m_x + 3, m_y + 2 SAY "Omjer pomocna/domaca" GET nBBK WHEN {|| nBBK := OmjerVal2( cBBV, cTip ), .T. } PICT "999999999.999999999"
      READ
      BoxC()
   ELSE
      cBBV := cTip
      nBBK := 1
   ENDIF
   SELECT ( nArr )

   RETURN


STATIC FUNCTION init_progres()

   s_nProgres := 0

   RETURN .T.


STATIC FUNCTION show_progres()

   ++s_nProgres

   IF s_nProgres % 100 == 0

      OutStd( "Bilans: " + Str( s_nProgres, 6 ) + hb_eol() )

   ENDIF

   RETURN .T.
