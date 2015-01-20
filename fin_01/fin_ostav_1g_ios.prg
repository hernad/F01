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


// -----------------------------------------------
// izvjestaj otvorenih stavki
// -----------------------------------------------
FUNCTION IOS()

   PRIVATE opc[ 4 ]
   PRIVATE izbor

   picBHD := "@Z " + ( R1 := FormPicL( "9 " + gPicBHD, 16 ) )
   picDEM := "@Z " + ( R2 := FormPicL( "9 " + gPicDEM, 12 ) )
   R1 := R1 + " " + ValDomaca()
   R2 := R2 + " " + ValPomocna()

   PRIVATE cMjesto := PadR( "SARAJEVO", 20 )

   O_PARAMS
   PRIVATE cSection := "6", cHistory := " "; aHistory := {}
   Rpar( "mj", @cMjesto )

   Box(, 5, 60 )
   @ m_x + 4, m_y + 2 SAY "Napomena: Prije stampanja mora se pokrenuti"
   @ m_x + 5, m_y + 2 SAY "specifikacija IOS-a "
   @ m_x + 1, m_y + 2 SAY "Mjesto:" GET cMjesto PICT "@!"
   READ
   BoxC()

   IF LastKey() != K_ESC
      Wpar( "mj", cMjesto )
   ENDIF
   SELECT PARAMS; USE

   opc[ 1 ] := "1. specifikacija ios-a                     "
   opc[ 2 ] := "2. ios"
   opc[ 3 ] := "3. ios (nastavak u slucaju prekida rada) "
   opc[ 4 ] := "4. ios (pojedinacan)"
   // opc[5]:="9. kraj posla"

   Izbor := 1
   DO WHILE .T.
      h[ 1 ] := "Specifikacija IOS-a je priprema za stampanje obrazaca IOS-a"
      h[ 2 ] := "Stampanje svih IOS-a iz specifikacije"
      h[ 3 ] := "Nastavak u slucaju prekida opcije 2."
      h[ 4 ] := "Stampanje IOS-a za pojedinacnog partnera"
      h[ 5 ] := ""
      Izbor := Menu( "IOS", opc, Izbor, .F. )
      DO CASE
      CASE Izbor == 0
         EXIT
      CASE izbor == 1
         SpecIOS()
      CASE izbor == 2
         IOSS()
      CASE izbor == 3
         IOSPrekid()
      CASE izbor == 4
         IOSPojed()
      CASE Izbor == 5
         Izbor := 0
      ENDCASE
   ENDDO

   RETURN




/*  SpecIOS()
 *   Specifikacija otvorenih stavki
 */

PROCEDURE SpecIOS()

   LOCAL dDatDo := Date()

   cIdFirma := gFirma
   cIdKonto := Space( 7 )
   IF gVar1 == "0"
      M := "----- ------ ------------------------------------ ----- ----------------- --------------- ---------------- ---------------- ---------------- ------------ ------------ ------------ ------------"
   ELSE
      M := "----- ------ ------------------------------------ ----- ----------------- --------------- ---------------- ---------------- -----------------"
   ENDIF
   O_PARTN
   O_KONTO
   cPrik0 := "D"
   Box( "", 6, 60 )
   @ m_x + 1, m_y + 6 SAY "SPECIFIKACIJA IOS-a"
   IF gNW == "D"
      @ m_x + 3, m_y + 2 SAY "Firma "; ?? gFirma, "-", gNFirma
   ELSE
      @ m_x + 3, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| P_Firma( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
   ENDIF
   @ m_x + 4, m_y + 2 SAY "Konto: " GET cIdKonto VALID P_Konto( @cIdKonto )
   @ m_x + 5, m_y + 2 SAY "Datum do kojeg se generise  :" GET dDatDo
   @ m_x + 6, m_y + 2 SAY "Prikaz partnera sa saldom 0 :" GET cPrik0 VALID cPrik0 $ "DN" PICT "@!"
   READ; ESC_BCR
   BoxC()

   cIdFirma := Left( cIdFirma, 2 )

   O_SUBAN
   O_IOS

   SELECT IOS; ZAP

   SELECT SUBAN; SET ORDER TO 1

   SEEK cIdFirma + cIdKonto
   EOF CRET


   start PRINT cret
   ?

   B := 0
   nDugBHD := nUkDugBHD := nDugDEM := nUkDugDEM := 0
   nPotBHD := nUkPotBHD := nPotDEM := nUkPotDEM := 0


   nUkBHDDS := nUkBHDPS := 0
   nUkDEMDS := nUkDEMPS := 0
   DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdKonto == IdKonto

      cIdPartner := IdPartner
      DO WHILE  !Eof() .AND. cIdFirma = IdFirma .AND. cIdKonto = IdKonto .AND. cIdPartner == IdPartner

         // ako je datum veci od datuma do kojeg generisem
         // preskoci
         IF field->datdok > dDatDo
            SKIP
            LOOP
         ENDIF

         IF OtvSt = " "
            IF D_P = "1"
               nDugBHD += IznosBHD
               nUkDugBHD += IznosBHD
               nDugDEM += IznosDEM
               nUkDugDEM += IznosDEM
            ELSE
               nPotBHD += IznosBHD
               nUkPotBHD += IznosBHD
               nPotDEM += IznosDEM
               nUkPotDEM += IznosDEM
            ENDIF
         ENDIF
         SKIP
      ENDDO // partner

      nSaldoBHD := nDugBHD - nPotBHD
      nSaldoDEM := nDugDEM - nPotDEM
      IF cPrik0 == "D"  .OR. Round( nsaldobhd, 2 ) <> 0  // ako je iznos <> 0

         IF PRow() == 0; ZagSpecIOS(); ENDIF
         IF PRow() > 61 + gPStranica; FF; ZagSpecIOS(); ENDIF
         @ PRow() + 1, 0 SAY ++B PICTURE '9999'
         @ PRow(), 5 SAY cIdPartner
         SELECT PARTN; HSEEK cIdPartner
         @ PRow(), 12 SAY PadR( AllTrim( naz ), 20 )
         @ PRow(), 37 SAY AllTrim( naz2 ) PICTURE 'XXXXXXXXXXXX'
         @ PRow(), 50 SAY PTT
         @ PRow(), 56 SAY Mjesto


         // BHD
         @ PRow(), 73 SAY nDugBHD PICTURE picBHD
         @ PRow(), PCol() + 1 SAY nPotBHD PICTURE picBHD


         SELECT IOS
         APPEND BLANK
         REPLACE IdFirma WITH   cIdFirma, ;
            IdKonto WITH   cIdKonto, ;
            IdPartner WITH cIdPartner, ;
            IznosBHD WITH nSaldoBHD,;
            IznosDEM WITH nSaldoDEM

      ENDIF // nsaldo<>0
      SELECT SUBAN

      IF nSaldoBHD >= 0
         @ PRow(), PCol() + 1 SAY nSaldoBHD PICTURE picBHD
         @ PRow(), PCol() + 1 SAY 0 PICTURE picBHD
         nUkBHDDS += nSaldoBHD
      ELSE
         @ PRow(), PCol() + 1 SAY 0 PICTURE picBHD
         @ PRow(), PCol() + 1 SAY -nSaldoBHD PICTURE picBHD
         nUkBHDPS += -nSaldoBHD
      ENDIF

      IF gVar1 == "0"
         // DEM

         @ PRow(), PCol() + 1 SAY nDugDEM PICTURE picDEM
         @ PRow(), PCol() + 1 SAY nPotDEM PICTURE picDEM

         IF nSaldoDEM >= 0
            @ PRow(), PCol() + 1 SAY nSaldoDEM PICTURE picDEM
            @ PRow(), PCol() + 1 SAY 0 PICTURE picDEM
            nUkDEMDS += nSaldoDEM
         ELSE
            @ PRow(), PCol() + 1 SAY 0 PICTURE picDEM
            @ PRow(), PCol() + 1 SAY -nSaldoDEM PICTURE picDEM
            nUkDEMPS += -nSaldoDEM
         ENDIF
      ENDIF

      nDugBHD := nPotBHD := nDugDEM := nPotDEM := 0
      cIdPartner := IdPartner
   ENDDO // konto

   IF PRow() > 61 + gPStranica; FF; ZagSpecIOS(); ENDIF
   @ PRow() + 1, 0 SAY M
   @ PRow() + 1, 0 SAY "UKUPNO ZA KONTO:"
   @ PRow(), 73       SAY nUkDugBHD PICTURE picBHD
   @ PRow(), PCol() + 1 SAY nUkPotBHD PICTURE picBHD

   nS := nUkBHDDS - nUkBHDPS
   @ PRow(), PCol() + 1 SAY iif( nS >= 0, nS, 0 ) PICTURE picBHD
   @ PRow(), PCol() + 1 SAY iif( nS <= 0, nS, 0 ) PICTURE picBHD

   IF gVar1 == "0"
      @ PRow(), PCol() + 1 SAY nUkDugDEM PICTURE picDEM
      @ PRow(), PCol() + 1 SAY nUkPotDEM PICTURE picDEM

      nS := nUkDEMDS - nUkDEMPS
      @ PRow(), PCol() + 1 SAY iif( nS >= 0, nS, 0 ) PICTURE picDEM
      @ PRow(), PCol() + 1 SAY iif( nS <= 0, nS, 0 ) PICTURE picDEM
   ENDIF
   @ PRow() + 1, 0 SAY M

   FF
   ENDPRINT
   closeret

   RETURN




/*  ZagSpecIOS()
 *   Zaglavlje specifikacije otvorenih stavki
 */

FUNCTION ZagSpecIOS()

   P_COND

   ??  "FIN: SPECIFIKACIJA IOS-a     NA DAN "
   ?? Date()
   ? "FIRMA:"
   @ PRow(), PCol() + 1 SAY cIdFirma

   SELECT PARTN
   HSEEK cIdFirma
   @ PRow(), PCol() + 1 SAY AllTrim( naz )
   @ PRow(), PCol() + 1 SAY AllTrim( naz2 )

   ? M

   ? "*RED.* �IFRA*      NAZIV POSLOVNOG PARTNERA      * PTT *      MJESTO     *   KUMULATIVNI PROMET  U  " + ValDomaca() + "  *    S A L D O   U   " + ValDomaca() + "         " + IF( gVar1 == "0", "*  KUMULAT. PROMET U " + ValPomocna() + " *  S A L D O   U   " + ValPomocna() + "  ", "" ) + "*"
   ? "                                                                          ________________________________ _________________________________" + IF( gVar1 == "0", "*_________________________ ________________________", "" ) + "_"
   ? "*BROJ*      *                                    * BROJ*                 *    DUGUJE     *   POTRAZUJE    *    DUGUJE      *   POTRAZUJE    " + IF( gVar1 == "0", "*    DUGUJE  * POTRAZUJE  *   DUGUJE   * POTRAZUJE ", "" ) + "*"
   ? M

   SELECT SUBAN

   RETURN




// --------------------------------------------------
// ios za sve partnere nakon specifikacije
// --------------------------------------------------

FUNCTION IOSS()

   LOCAL lExpDbf := .F.
   LOCAL cExpDbf := "N"
   LOCAL cLaunch
   LOCAL aExpFields
   LOCAL dDatDo := Date()

   CLOSE ALL
   cPrelomljeno := "N"
   PRIVATE cKaoKartica := "D"
   memvar->DATUM := Date()
   cDinDem := "1"

   Box( "IOSS", 7, 60, .F. )

   @ m_x + 1, m_y + 8 SAY "I O S"
   @ m_x + 2, m_y + 2 SAY "UKUCAJTE DATUM IOS-a:"  GET memvar->DATUM
   IF gVar1 == "0"
      @ m_x + 3, m_y + 2 SAY "Prikaz " + AllTrim( ValDomaca() ) + "/" + AllTrim( ValPomocna() ) + " (1/2)"  GET cDinDem VALID cdindem $ "12"
   ENDIF
   @ m_x + 4, m_y + 2 SAY "Prikaz prebijenog stanja " GET cPrelomljeno VALID cPrelomljeno $ "DN" PICT "@!"
   @ m_x + 5, m_y + 2 SAY "Prikaz identicno kartici " GET cKaoKartica VALID cKaoKartica $ "DN" PICT "@!"
   @ m_x + 6, m_y + 2 SAY "Gledati period do: " GET dDatDo
   @ m_x + 7, m_y + 2 SAY "Exportovati tabelu u dbf?" GET cExpDbf VALID cExpDbf $ "DN" PICT "@!"
   READ
   BoxC()

   IF cExpDbf == "D"
      lExpDbf := .T.
   ENDIF

   IF lExpDbf == .T.
      aExpFields := g_exp_fields()
      t_exp_create( aExpFields )
      cLaunch := exp_report()
   ENDIF

   ESC_RETURN 0

   A := 0
   B := 0

   nDugBHD := nPotBHD := nDugDEM := nPotDEM := 0

   O_PARTN
   O_KONTO
   O_TNAL
   O_SUBAN
   O_IOS

   start PRINT cret

   SELECT IOS
   GO TOP

   DO WHILE !Eof()

      cIdFirma := IdFirma
      cIdKonto := IdKonto
      cIdPartner := IdPartner
      nIznosBHD := IznosBHD
      nIznosDEM := IznosDEM

      // ispisi ios, exportuj ako treba
      ZagIOSS( cDinDem, dDatDo, lExpDbf )

      SKIP

   ENDDO

   FF
   ENDPRINT

   // lansiraj report....
   IF lExpDbf == .T.
      tbl_export( cLaunch )
   ENDIF

   closeret

   RETURN 1



/*  IOSPrekid()
 *   Ukoliko dodje do prekida u IOSS nastavlja dalje
 */

FUNCTION IOSPrekid()

   LOCAL dDatDo := Date()
   memvar->DATUM = Date()

   cIdFirma := gFirma
   cIdKonto := Space( 7 )
   cIdPartner := Space( 6 )
   O_KONTO
   O_PARTN
   PRIVATE cKaoKartica := "D"
   cPrelomljeno := "N"
   cDinDem := "1"
   Box( "IOSPrek", 9, 60, .F. )
   @ m_x + 1, m_y + 2 SAY " I O S (NASTAVAK U SLUCAJU PREKIDA RADA)"
   @ m_x + 2, m_y + 2 SAY "Datum IOS-a:" GET memvar->DATUM
   IF gNW == "D"
      @ m_x + 3, m_y + 2 SAY "Firma "; ?? gFirma, "-", gNFirma
   ELSE
      @ m_x + 3, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| P_Firma( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
   ENDIF
   @ m_x + 4, m_y + 2 SAY "Konto      :" GET cIdKonto VALID P_Konto( @cIdKonto )
   @ m_x + 5, m_y + 2 SAY "Partner    :" GET cIdPartner VALID P_Firma( @cIdPartner ) PICT "@!"
   IF gVar1 == "0"
      @ m_x + 6, m_y + 2 SAY "Prikaz " + AllTrim( ValDomaca() ) + "/" + AllTrim( ValPomocna() ) + " (1/2)"  GET cDinDem VALID cdindem $ "12"
   ENDIF
   @ m_x + 7, m_y + 2 SAY "Gledati period do: " GET dDatDo
   @ m_x + 8, m_y + 2 SAY "Prikaz prebijenog stanja " GET cPrelomljeno VALID cPrelomljeno $ "DN" PICT "@!"
   @ m_x + 9, m_y + 2 SAY "Prikaz identicno kartici " GET cKaoKartica VALID cKaoKartica $ "DN" PICT "@!"
   READ; ESC_BCR
   BoxC()
   nDugBHD := nPotBHD := nDugDEM := nPotDEM := 0

   cIdFirma := Left( cIdFirma, 2 )

   O_TNAL
   O_SUBAN
   O_IOS

   SELECT IOS

   SEEK cIdFirma + cIdKonto + cIdPartner

   NFOUND CRET

   start PRINT cret

   A := 0; B := 0
   SELECT IOS
   DO WHILE !Eof()
      cIdFirma = IdFirma; cIdKonto = IdKonto; cIdPartner = IdPartner
      nIznosbHD = IznosBHD; nIznosDEM := IznosDEM
      ZagIOSS( cDinDem, dDatDo )
      SKIP
   ENDDO

   FF
   ENDPRINT
   closeret

   RETURN




/*  IOSPojed()
 *   Pojedinacni IOS
 */

FUNCTION IOSPojed()

   LOCAL dDatDo := Date()
   memvar->DATUM = Date()

   cIdFirma := gFirma
   cIdKonto := Space( 7 )
   cIdPartner := Space( 6 )

   O_KONTO
   O_PARTN

   cDinDem := "1"
   PRIVATE cKaoKartica := "D"
   cPrelomljeno := "N"
   Box( "IOSPoj", 9, 60, .F. )
   @ m_x + 1, m_y + 2 SAY " I O S (POJEDINACAN)"
   @ m_x + 2, m_y + 2 SAY "Datum IOS-a :" GET memvar->DATUM
   IF gNW == "D"
      @ m_x + 3, m_y + 2 SAY "Firma "; ?? gFirma, "-", gNFirma
   ELSE
      @ m_x + 3, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| P_Firma( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
   ENDIF
   @ m_x + 4, m_y + 2 SAY "Konto       :" GET cIdKonto VALID P_Konto( @cIdKonto )
   @ m_x + 5, m_y + 2 SAY "Partner     :" GET cIdPartner VALID P_Firma( @cIdPartner ) PICT "@!"
   IF gVar1 == "0"
      @ m_x + 6, m_y + 2 SAY "Prikaz " + AllTrim( ValDomaca() ) + "/" + AllTrim( ValPomocna() ) + " (1/2)"  GET cDinDem VALID cdindem $ "12"
   ENDIF

   @ m_x + 7, m_y + 2 SAY "Datum do: " GET dDatDo
   @ m_x + 8, m_y + 2 SAY "Prikaz prebijenog stanja " GET cPrelomljeno VALID cPrelomljeno $ "DN" PICT "@!"
   @ m_x + 9, m_y + 2 SAY "Prikaz identicno kartici " GET cKaoKartica VALID cKaoKartica $ "DN" PICT "@!"
   READ; ESC_BCR
   BoxC()
   nDugBHD := nPotBHD := nDugDEM := nPotDEM := 0

   cIdFirma := Left( cIdFirma, 2 )

   O_TNAL
   O_SUBAN
   O_IOS

   SELECT IOS
   SEEK cIdFirma + cIdKonto + cIdPartner
   NFOUND CRET

   start PRINT cret

   B := 0
   SELECT IOS
   DO WHILE !Eof() .AND. cIdFirma = IdFirma .AND. cIdKonto = IdKonto .AND. cIdPartner = IdPartner
      nIznosBHD := IznosBHD; nIznosDEM := IznosDEM
      ZagIOSS( cDinDem, dDatDo )
      SKIP
   ENDDO

   // FF
   ENDPRINT
   closeret

   RETURN


// ------------------------------------------
// vraca strukturu tabele za export
// ------------------------------------------
STATIC FUNCTION g_exp_fields()

   LOCAL aDbf := {}

   AAdd( aDbf, { "idpartner", "C", 10, 0 } )
   AAdd( aDbf, { "partner", "C", 40, 0 } )
   AAdd( aDbf, { "brrn", "C", 10, 0 } )
   AAdd( aDbf, { "opis", "C", 40, 0 } )
   AAdd( aDbf, { "datum", "D", 8, 0 } )
   AAdd( aDbf, { "valuta", "D", 8, 0 } )
   AAdd( aDbf, { "duguje", "N", 15, 5 } )
   AAdd( aDbf, { "potrazuje", "N", 15, 5 } )

   RETURN aDbf


// ---------------------------------------------------------
// filovanje tabele sa podacima
// ---------------------------------------------------------
STATIC FUNCTION fill_exp_tbl( cIdPart, cNazPart, ;
      cBrRn, cOpis, dDatum, dValuta, ;
      nDug, nPot )

   LOCAL nTArea := Select()

   O_R_EXP
   APPEND BLANK

   REPLACE field->idpartner WITH cIdPart
   REPLACE field->partner WITH cNazPart
   REPLACE field->brrn WITH cBrRn
   REPLACE field->opis WITH cOpis
   REPLACE field->datum WITH dDatum
   REPLACE field->valuta WITH dValuta
   REPLACE field->duguje WITH nDug
   REPLACE field->potrazuje WITH nPot

   SELECT ( nTArea )

   RETURN



// -----------------------------------------
// zaglavlje IOS-a ispisuje stavke ios-a
// -----------------------------------------
FUNCTION ZagIOSS( cDinDem, dDatDo, lExpDbf )

   LOCAL nRbr
   LOCAL nCOpis := 0
   LOCAL cIdPar
   LOCAL cNazPar

   IF lExpDbf == nil
      lExpDbf := .F.
   ENDIF

   ?

   @ PRow(), 58 SAY "OBRAZAC: I O S"
   @ PRow() + 1, 1 SAY cIdFirma

   SELECT PARTN
   HSEEK cIdFirma

   @ PRow(), 5 SAY AllTrim( naz )
   @ PRow(), PCol() + 1 SAY AllTrim( naz2 )
   @ PRow() + 1, 5 SAY Mjesto
   @ PRow() + 1, 5 SAY Adresa
   @ PRow() + 1, 5 SAY PTT
   @ PRow() + 1, 5 SAY ZiroR
   @ PRow() + 1, 5 SAY IzSifK( "PARTN", "REGB", cIdFirma, .F. )

   ?

   SELECT PARTN
   HSEEK cIdPartner

   @ PRow(), 45 SAY cIdPartner
   ?? " -", naz
   @ PRow() + 1, 45 SAY mjesto
   @ PRow() + 1, 45 SAY adresa
   @ PRow() + 1, 45 SAY ptt
   @ PRow() + 1, 45 SAY ziror
   IF !Empty( telefon )
      @ PRow() + 1, 45 SAY "Telefon: " + telefon
   ENDIF
   @ PRow() + 1, 45 SAY IzSifK( "PARTN", "REGB", cIdPartner, .F. )

   // setuj id i naziv partnera
   cIdPar := id
   cNazPar := naz

   ?
   ?
   @ PRow(), 6 SAY "IZVOD OTVORENIH STAVKI NA DAN :"; @ PRow(), PCol() + 2 SAY memvar->DATUM; @ PRow(), PCol() + 1 SAY "GODINE"
   ?
   ?
   @ PRow(), 0 SAY "VA�E STANJE NA KONTU" ; @ PRow(), PCol() + 1 SAY cIdKonto
   @ PRow(), PCol() + 1 SAY " - " + cIdPartner
   @ PRow() + 1, 0 SAY "PREMA NA�IM POSLOVNIM KNJIGAMA NA DAN:"
   @ PRow(), 39 SAY memvar->DATUM
   @ PRow(), 48 SAY "GODINE"
   ?
   ?
   @ PRow(), 0 SAY "POKAZUJE SALDO:"

   qqIznosBHD := nIznosBHD
   qqIznosDEM := nIznosDEM

   IF nIznosBHD < 0
      qqIznosBHD := -nIznosBHD
   ENDIF

   IF nIznosDEM < 0
      qqIznosDEM := -nIznosDEM
   ENDIF

   IF cDinDEM == "1"
      @ PRow(), 16 SAY qqIznosBHD PICTURE R1
   ELSE
      @ PRow(), 16 SAY qqIznosDEM PICTURE R2
   ENDIF

   ?
   ?

   @ PRow(), 0 SAY "U"
   IF nIznosBHD > 0
      @ PRow(), PCol() + 1 SAY "NA�U"
   ELSE
      @ PRow(), PCol() + 1 SAY "VA�U"
   ENDIF

   @ PRow(), PCol() + 1 SAY "KORIST I SASTOJI SE IZ SLIJEDE�IH OTVORENIH STAVKI:"
   P_COND
   M := "       ---- ---------- -------------------- -------- -------- ---------------- ----------------"

   ? M
   ? "       *R. *   BROJ   *    OPIS            * DATUM  * VALUTA *       IZNOS  U  " + iif( cdindem == "1", ValDomaca(), ValPomocna() ) + "            *"
   ? "       *Br.*          *                    *                 * --------------------------------"
   ? "       *   *  RA�UNA  *                    * RA�UNA * RA�UNA *     DUGUJE     *   POTRA�UJE   *"
   ? M
   nCol1 := 62
   SELECT SUBAN

   IF cKaoKartica == "D"
      SET ORDER TO 1

      // "IdFirma+IdKonto+IdPartner+dtos(DatDok)+BrNal+RBr"
   ELSE
      SET ORDER TO 3
   ENDIF

   SEEK cIdFirma + cIdKonto + cIdPartner

   nDugBHD := nPotBHD := nDugDEM := nPotDEM := 0
   nDugBHDZ := nPotBHDZ := nDugDEMZ := nPotDEMZ := 0
   nRbr := 0

   // ako je kartica, onda nikad ne prelamaj
   IF cKaoKartica == "D"
      cPrelomljeno := "N"
   ENDIF

   DO WHILE !Eof() .AND. cIdFirma = IdFirma .AND. cIdKonto = IdKonto .AND. cIdPartner == IdPartner

      cBrDok := brdok
      dDatdok := datdok
      cOpis := AllTrim( opis )
      dDatVal := datval
      nDBHD := 0
      nPBHD := 0
      nDDEM := 0
      nPDEM := 0
      cOtvSt := otvst

      DO WHILE !Eof() .AND. cIdFirma = IdFirma .AND. cIdKonto = IdKonto .AND. cIdPartner == IdPartner .AND. ( cKaoKartica == "D" .OR. brdok == cBrdok )

         IF field->datdok > dDatDo
            SKIP
            LOOP
         ENDIF

         IF OtvSt = " "

            IF cKaoKartica == "D"

               IF PRow() > 61 + gPStranica
                  FF
               ENDIF

               @ PRow() + 1, 8 SAY ++nRbr PICTURE '999'
               @ PRow(), PCol() + 1  SAY BrDok
               nCOpis := PCol() + 1
               @ PRow(), nCOpis    SAY PadR( Opis, 20 )
               @ PRow(), PCol() + 1  SAY DatDok
               @ PRow(), PCol() + 1  SAY DatVal

               IF cDinDem == "1"
                  @ PRow(), ncol1    SAY iif( D_P = "1", iznosbhd, 0 )  PICTURE picBHD
                  @ PRow(), PCol() + 1 SAY iif( D_P = "2", iznosbhd, 0 )  PICTURE picBHD
               ELSE
                  @ PRow(), ncol1    SAY iif( D_P = "1", iznosdem, 0 ) PICTURE picBHD
                  @ PRow(), PCol() + 1 SAY iif( D_P = "2", iznosdem, 0 ) PICTURE picBHD
               ENDIF

               IF lExpDbf == .T.
                  fill_exp_tbl( cIdPar, cNazPar, brdok, opis, ;
                     datdok, datval, iif( d_p == "1", iznosbhd, 0 ), ;
                     iif( d_p == "2", iznosbhd, 0 ) )
               ENDIF

            ENDIF

            IF D_P = "1"
               nDBHD += IznosBHD
               nDDEM += IznosDEM
            ELSE
               nPBHD += IznosBHD
               nPDEM += IznosDEM
            ENDIF

            cOtvSt := " "

         ELSE  // zatvorene stavke

            IF D_P = "1"
               nDugBHDZ += IznosBHD; nDugDEMZ += IznosDEM
            ELSE
               nPotBHDZ += IznosBHD; nPotDEMZ += IznosDEM
            ENDIF

         ENDIF

         SKIP

      ENDDO

      IF cOtvSt == " "

         IF cKaoKartica == "N"

            IF PRow() > 61 + gPStranica
               FF
            ENDIF

            // MS 29.11.01

            @ PRow() + 1, 8 SAY ++nRbr PICTURE '999'

            @ PRow(), PCol() + 1  SAY cBrDok
            nCOpis := PCol() + 1
            @ PRow(), nCOpis    SAY PadR( cOpis, 20 )
            @ PRow(), PCol() + 1  SAY dDatDok
            @ PRow(), PCol() + 1  SAY dDatVal

         ENDIF

         IF cDinDem == "1"

            IF cPrelomljeno == "D"

               IF nDBHD - nPBHD > 0
                  nDBHD := nDBHD - nPBHD
                  nPBHD := 0
               ELSE
                  nPBHD := nPBHD - nDBHD
                  nDBHD := 0
               ENDIF

            ENDIF

            IF cKaoKartica == "N"

               @ PRow(), ncol1 SAY nDBHD PICTURE picBHD
               @ PRow(), PCol() + 1 SAY nPBhD PICTURE picBHD

               IF lExpDbf == .T.
                  fill_exp_tbl( cIdPar, cNazPar, cBrDok, cOpis, dDatdok, dDatval, nDBHD, nPBHD )
               ENDIF

            ENDIF


         ELSE
            IF cPrelomljeno == "D"
               IF nDDEM - nPDEM > 0
                  nDDEM := nDDEM - nPDEM
                  nPBHD := 0
               ELSE
                  nPDEM := nPDEM - nDDEM
                  nDDEM := 0
               ENDIF
            ENDIF

            IF cKaoKartica == "N"

               @ PRow(), ncol1    SAY nDDEM PICTURE picBHD
               @ PRow(), PCol() + 1 SAY nPDEM PICTURE picBHD


               IF lExpDbf == .T.
                  fill_exp_tbl( cIdPar, cNazPar, cBrdok, cOpis, dDatdok, dDatval, nDDEM, nPDEM )
               ENDIF

            ENDIF
         ENDIF

         nDugBHD += nDBHD; nPotBHD += nPBHD
         nDugDem += nDDem; nPotDem += nPDem

      ENDIF

      OstatakOpisa( cOpis, nCOpis )

   ENDDO

   IF PRow() > 61 + gPStranica; FF; ENDIF

   @ PRow() + 1, 0 SAY M
   @ PRow() + 1, 8 SAY "UKUPNO:"

   IF cDinDEM == "1"
      @ PRow(), ncol1    SAY nDugBHD PICTURE picBHD
      @ PRow(), PCol() + 1 SAY nPotBHD PICTURE picBHD
   ELSE
      @ PRow(), ncol1    SAY nDugBHD PICTURE picBHD
      @ PRow(), PCol() + 1 SAY nPotBHD PICTURE picBHD
   ENDIF


   // ako je promet zatvorenih stavki <> 0  prikazi ga ????
   IF cDinDEM == "1"
      IF Round( nDugBHDZ - nPOTBHDZ, 4 ) <> 0
         @ PRow() + 1, 0 SAY M
         @ PRow() + 1, 8 SAY "ZATVORENE STAVKE"
         @ PRow(), ncol1    SAY nDugBHDZ - nPOTBHDZ PICTURE picBHD
         @ PRow(), PCol() + 1 SAY  " GRE�KA !!"
      ENDIF
   ELSE
      IF Round( nDugDEMZ - nPOTDEMZ, 4 ) <> 0
         @ PRow() + 1, 0 SAY M
         @ PRow() + 1, 8 SAY "ZATVORENE STAVKE"
         @ PRow(), ncol1    SAY nDugDEMZ - nPOTDEMZ PICTURE picBHD
         @ PRow(), PCol() + 1 SAY " GRE�KA !!"
      ENDIF
   ENDIF


   @ PRow() + 1, 0 SAY M
   @ PRow() + 1, 8 SAY "SALDO:"
   nSaldoBHD := nDugBHD - nPotBHD
   nSaldoDEM := nDugDEM - nPotDEM
   IF cDINDEM == "1"
      IF nSaldoBHD >= 0
         @ PRow(), ncol1 SAY nSaldoBHD PICTURE picBHD
         @ PRow(), PCol() + 1 SAY 0 PICTURE picBHD
      ELSE
         nSaldoBHD := -nSaldoBHD
         nSaldoDEM := -nSaldoDEM
         @ PRow(), ncol1 SAY 0 PICTURE picBHD
         @ PRow(), PCol() + 1 SAY nSaldoBHD PICTURE picBHD
      ENDIF
   ELSE
      IF nSaldoDEM >= 0
         @ PRow(), ncol1 SAY nSaldoDEM PICTURE picBHD
         @ PRow(), PCol() + 1 SAY 0 PICTURE picBHD
      ELSE
         nSaldoDEM := -nSaldoDEM
         @ PRow(), ncol1 SAY 0 PICTURE picBHD
         @ PRow(), PCol() + 1 SAY nSaldoDEM PICTURE picBHD
      ENDIF
   ENDIF
   ? m
   F10CPI

   ?

   // ENDIF
   IF PRow() > 61 + gPStranica; FF; ENDIF
   ?
   ?
   F12CPI
   @ PRow(), 13 SAY "PO�ILJALAC IZVODA:"
   @ PRow(), 53 SAY "POTVR�UJEMO SAGLASNOST"
   @ PRow() + 1, 50 SAY "OTVORENIH STAVKI:"
   ?
   ?
   @ PRow(), 10 SAY "__________________"
   @ PRow(), 50 SAY "______________________"

   IF PRow() > 58 + gPStranica; FF; ENDIF
   ?
   ?
   @ PRow(), 10 SAY "__________________ M.P."
   @ PRow(), 50 SAY "______________________ M.P."
   ?
   ?
   @ PRow(), 10 SAY Trim( cMjesto ) + ", " + DToC( Date() )
   @ PRow(), 52 SAY "( MJESTO I DATUM )"

   IF PRow() > 52 + gPStranica; FF; ENDIF
   ?
   ?
   @ PRow(), 0 SAY "Prema clanu 28. stav 4. Zakona o racunovodstvu i reviziji u FBiH (Sl.novine FBiH, broj 83/09)"
   @ PRow() + 1, 0 SAY "na ovu nasu konfirmaciju ste duzni odgovoriti u roku od osam dana. Ukoliko u tom roku ne primimo"
   @ PRow() + 1, 0 SAY "potvrdu ili osporavanje iskazanog stanja, smatracemo da je usaglasavanje zavrseno i da je stanje isto."
   ?
   ?
   @ PRow(), 0 SAY "NAPOMENA: OSPORAVAMO ISKAZANO STANJE U CJELINI _______________ DJELIMI�NO"
   @ PRow() + 1, 0 SAY "ZA IZNOS OD  " + ValDomaca() + "= _______________ IZ SLIJEDE�IH RAZLOGA:"
   @ PRow() + 1, 0 SAY "_________________________________________________________________________"
   ?
   ?
   @ PRow(), 0 SAY "_________________________________________________________________________"
   ?
   ?
   @ PRow(), 48 SAY "DU�NIK:"
   @ PRow() + 1, 40 SAY "_______________________ M.P."
   @ PRow() + 1, 44 SAY "( MJESTO I DATUM )"

   FF

   SELECT IOS

   RETURN



/*  OstatakOpisa(cO,nCO,bUslov,nSir)
 *   Stampa ostatka opisa
 *   cO
 *   nCO
 *   bUslov
 *   nSir
 */

FUNCTION OstatakOpisa( cO, nCO, bUslov, nSir )

   IF nSir == NIL; nSir := 20; ENDIF
   DO WHILE Len( cO ) > nSir
      IF bUslov != NIL; Eval( bUslov ); ENDIF
      cO := SubStr( cO, nSir + 1 )
      IF !Empty( PadR( cO, nSir ) )
         @ PRow() + 1, nCO SAY PadR( cO, nSir )
      ENDIF
   ENDDO

   RETURN
