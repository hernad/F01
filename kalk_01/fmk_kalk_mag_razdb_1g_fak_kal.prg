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


#include "kalk01.ch"

FUNCTION FaKaMag()

   PRIVATE Opc := {}
   PRIVATE opcexe := {}
   PRIVATE Izbor := 1

   AAdd( Opc, "1. fakt->kalk (10->14) racun veleprodaje               " )
   AAdd( opcexe, {|| fakt_10_kalk_14() } )

   AAdd( Opc, "2. fakt->kalk (12->96) otpremnica" )
   AAdd( opcexe, {||  PrenosOt()  } )
   AAdd( Opc, "3. fakt->kalk (19->96) izlazi po ostalim osnovama" )
   AAdd( opcexe, {||  PrenosOt( "19" ) } )
   AAdd( Opc, "4. fakt->kalk (01->10) ulaz od dobavljaca" )
   AAdd( opcexe, {||  PrenosOt( "01_10" ) } )
   AAdd( Opc, "5. fakt->kalk (0x->16) doprema u magacin" )
   AAdd( opcexe, {||  PrenosOt( "0x" ) } )
   AAdd( Opc, "6. fakt->kalk, prenos otpremnica za period" )
   AAdd( opcexe, {||  PrenOtPeriod() } )


   Menu_SC( "fkma" )

   CLOSE ALL

   RETURN


STATIC FUNCTION _o_pr_tbls()

   O_KONCIJ
   O_PARAMS
   O_PRIPR
   O_KALK
   O_DOKS
   O_ROBA
   O_KONTO
   O_PARTN
   O_TARIFA
   XO_FAKT

   RETURN

// ----------------------------------------------------
// prenos otpremnica iz modula FAKT za period
// ----------------------------------------------------
FUNCTION PrenOtPeriod()

   LOCAL _id_firma := gFirma
   LOCAL _fakt_id_firma := gFirma
   LOCAL _tip_dok_fakt := PadR( "12;", 150 )
   LOCAL _d_fakt_od, _d_fakt_do
   LOCAL _br_kalk_dok := Space( 8 )
   LOCAL _tip_kalk := "96"
   LOCAL _dat_kalk
   LOCAL _id_kt
   LOCAL _id_kt_2
   LOCAL _sufix, _r_br, _razduzuje
   LOCAL _fakt_dobavljac := Space( 10 )
   LOCAL _artikli := Space( 150 )
   LOCAL _usl_roba

   _o_pr_tbls()

   _dat_kalk := Date()
   _id_kt := PadR( "", 7 )
   _id_kt_2 := PadR( "1010", 7 )
   _razduzuje := Space( 6 )
   _d_fakt_od := Date()
   _d_fakt_do := Date()
   _br_kalk_dok := GetNextKalkDoc( _id_firma, _tip_kalk )

   // procitaj parametre
   PRIVATE cSection := "G"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}
   SELECT params

   RPar( "k1", @_id_kt )
   RPar( "k2", @_id_kt_2 )
   RPar( "d1", @_d_fakt_od )
   RPar( "d2", @_d_fakt_do )
   RPar( "a1", @_artikli )
   RPar( "t1", @_tip_dok_fakt )

   Box(, 15, 70 )

   DO WHILE .T.

      _r_br := 0

      @ m_x + 1, m_y + 2 SAY "Broj kalkulacije " + _tip_kalk + " -" GET _br_kalk_dok PICT "@!"
      @ m_x + 1, Col() + 2 SAY "Datum:" GET _dat_kalk
      @ m_x + 3, m_y + 2 SAY "Konto zaduzuje :" GET _id_kt PICT "@!" VALID Empty( _id_kt ) .OR. P_Konto( @_id_kt )
      @ m_x + 4, m_y + 2 SAY "Konto razduzuje:" GET _id_kt_2 PICT "@!" VALID Empty( _id_kt_2 ) .OR. P_Konto( @_id_kt_2 )

      IF gNW <> "X"
         @ m_x + 4, Col() + 2 SAY "Razduzuje:" GET _razduzuje PICT "@!" VALID Empty( _razduzuje ) .OR. P_Firma( @_razduzuje )
      ENDIF

      _fakt_id_firma := _id_firma

      // postavi uslove za period...
      @ m_x + 6, m_y + 2 SAY "FAKT: id firma:" GET _fakt_id_firma
      @ m_x + 7, m_y + 2 SAY "Vrste dokumenata:" GET _tip_dok_fakt PICT "@S30"
      @ m_x + 8, m_y + 2 SAY "Dokumenti u periodu od" GET _d_fakt_od
      @ m_x + 8, Col() + 1 SAY "do" GET _d_fakt_do

      // uslov za sifre artikla
      @ m_x + 10, m_y + 2 SAY "Uslov po artiklima:" GET _artikli PICT "@S30"

      READ

      IF LastKey() == K_ESC
         EXIT
      ENDIF

      // snimi parametre
      SELECT params
      WPar( "k1", _id_kt )
      WPar( "k2", _id_kt_2 )
      WPar( "d1", _d_fakt_od )
      WPar( "d2", _d_fakt_do )
      WPar( "a1", _artikli )
      WPar( "t1", _tip_dok_fakt )

      // predji na selekt podataka
      SELECT xfakt
      SET ORDER TO TAG "1"
      SEEK _fakt_id_firma

      DO WHILE !Eof() .AND. field->idfirma == _fakt_id_firma

         // provjeri po vrsti dokumenta
         IF !( field->idtipdok $ _tip_dok_fakt )
            SKIP
            LOOP
         ENDIF

         // provjeri po datumskom uslovu
         IF field->datdok < _d_fakt_od .OR. field->datdok > _d_fakt_do
            SKIP
            LOOP
         ENDIF

         // provjera po robama...
         IF !Empty( _artikli )

            _usl_roba := Parsiraj( _artikli, "idroba" )

            IF !( &_usl_roba )
               SKIP
               LOOP
            ENDIF

         ENDIF

         SELECT KONCIJ
         SEEK Trim( _id_kt )

         SELECT xfakt

         // provjeri sifru u sifrarniku...
         IF !ProvjeriSif( "!eof() .and. '" + xfakt->idfirma + xfakt->idtipdok + xfakt->brdok + "'==IdFirma+IdTipDok+BrDok", "IDROBA", F_ROBA )
            MsgBeep( "U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!" )
            LOOP
         ENDIF

         SELECT ROBA
         hseek xfakt->idroba

         SELECT tarifa
         hseek roba->idtarifa

         SELECT xfakt

         // preskoci ako su usluge ili podbroj stavke...
         IF AllTrim( podbr ) == "." .OR. roba->tip $ "UY"
            SKIP
            LOOP
         ENDIF

         // dobro, sada imam prave dokumente koje treba da prebacujem,
         // bacimo se na posao...

         SELECT pripr
         GO BOTTOM
         // provjeri da li već postoji artikal prenesen, pa ga saberi sa prethodnim
         LOCATE FOR idroba == xfakt->idroba

         IF Found()

            // saberi ga sa prethodnim u pripremi
            REPLACE kolicina WITH kolicina + xfakt->kolicina

         ELSE

            // nema artikla, dodaj novi...
            APPEND BLANK

            REPLACE idfirma WITH _id_firma, ;
               rbr WITH Str( ++_r_br, 3 ), ;
               idvd WITH _tip_kalk, ;
               brdok WITH _br_kalk_dok, ;
               datdok WITH _dat_kalk, ;
               idpartner WITH "", ;
               idtarifa WITH ROBA->idtarifa, ;
               brfaktp WITH _fakt_dobavljac, ;
               datfaktp WITH xfakt->datdok, ;
               idkonto   WITH _id_kt, ;
               idkonto2  WITH _id_kt_2, ;
               idzaduz2  WITH _razduzuje, ;
               datkurs WITH xfakt->datdok, ;
               kolicina WITH xfakt->kolicina, ;
               idroba WITH xfakt->idroba, ;
               nc  WITH ROBA->nc, ;
               vpc WITH xfakt->cijena, ;
               rabatv WITH xfakt->rabat, ;
               mpc WITH xfakt->porez

            IF _tip_kalk $ "96" .AND. xfakt->( FieldPos( "idrnal" ) ) <> 0
               REPLACE idzaduz2 WITH xfakt->idRNal
            ENDIF

         ENDIF

         SELECT xfakt
         SKIP

      ENDDO

      IF _r_br > 0

         @ m_x + 14, m_y + 2 SAY "Dokument je generisan !!"

         Inkey( 4 )

         @ m_x + 14, m_y + 2 SAY Space( 30 )

         EXIT

      ENDIF

   ENDDO

   BoxC()

   CLOSE ALL

   RETURN


/*  fakt_10_kalk_14()
 *   Prenos FAKT 10 -> KALK 14 (veleprodajni racun)
 */

FUNCTION fakt_10_kalk_14()

   LOCAL nRabat := 0
   LOCAL cIdFirma := gFirma
   LOCAL cIdTipDok := "10"
   LOCAL cBrDok := Space( 8 )
   LOCAL cBrKalk := Space( 8 )
   LOCAL cFaktFirma := gFirma
   LOCAL dDatPl := CToD( "" )
   LOCAL fDoks2 := .F.

   PRIVATE lVrsteP := is_use_vrste_placanja()

   O_KONCIJ
   O_PRIPR
   O_KALK
   O_DOKS
   IF File( KUMPATH + "DOKS2.DBF" )
      fDoks2 := .T.
      O_DOKS2
   ENDIF
   O_ROBA
   O_KONTO
   O_PARTN
   O_TARIFA

   XO_FAKT

   dDatKalk := Date()
   cIdKonto := PadR( "1200", 7 )
   cIdKonto2 := PadR( "1310", 7 )
   cIdZaduz2 := Space( 6 )


   // kalk_novi_broj( cIdKonto, cIdFirma, cIdVd )
   IF glBrojacPoKontima

      Box( "#FAKT->KALK", 3, 70 )
      @ m_x + 2, m_y + 2 SAY "Konto razduzuje" GET cIdKonto2 PICT "@!" VALID P_Konto( @cIdKonto2 )
      READ
      BoxC()

      cSufiks := SufBrKalk( cIdKonto2 )
      cBrKalk := SljBrKalk( "14", cIdFirma, cSufiks )

   ELSE

      cBrKalk := GetNextKalkDoc( cIdFirma, "14" )
   ENDIF

   Box(, 15, 60 )

   DO WHILE .T.

      nRBr := 0
      @ m_x + 1, m_y + 2   SAY "Broj kalkulacije 14 -" GET cBrKalk PICT "@!"
      @ m_x + 1, Col() + 2 SAY "Datum:" GET dDatKalk
      // @ m_x+3,m_y+2   SAY "Konto zaduzuje :" GET cIdKonto  pict "@!" valid P_Konto(@cIdKonto)
      @ m_x + 4, m_y + 2   SAY "Konto razduzuje:" GET cIdKonto2 PICT "@!" WHEN !glBrojacPoKontima VALID P_Konto( @cIdKonto2 )
      IF gNW <> "X"
         @ m_x + 4, Col() + 2 SAY "Razduzuje:" GET cIdZaduz2  PICT "@!"      VALID Empty( cidzaduz2 ) .OR. P_Firma( @cIdZaduz2 )
      ENDIF

      cFaktFirma := IF( cIdKonto2 == gKomKonto, gKomFakt, cIdFirma )
      @ m_x + 6, m_y + 2 SAY "Broj fakture: " GET cFaktFirma
      @ m_x + 6, Col() + 2 SAY "- " + cidtipdok
      @ m_x + 6, Col() + 2 SAY "-" GET cBrDok
      READ
      IF LastKey() == K_ESC
         EXIT
      ENDIF

      SELECT xfakt
      SEEK cFaktFirma + cIdTipDok + cBrDok
      IF !Found()
         Beep( 4 )
         @ m_x + 14, m_y + 2 SAY "Ne postoji ovaj dokument !!"
         Inkey( 4 )
         @ m_x + 14, m_y + 2 SAY Space( 30 )
         LOOP
      ELSE
         IF lVrsteP
            cIdVrsteP := idvrstep
         ENDIF
         aMemo := parsmemo( txt )
         IF Len( aMemo ) >= 5
            @ m_x + 10, m_y + 2 SAY PadR( Trim( amemo[ 3 ] ), 30 )
            @ m_x + 11, m_y + 2 SAY PadR( Trim( amemo[ 4 ] ), 30 )
            @ m_x + 12, m_y + 2 SAY PadR( Trim( amemo[ 5 ] ), 30 )
         ELSE
            cTxt := ""
         ENDIF
         IF Len( aMemo ) >= 9
            dDatPl := CToD( aMemo[ 9 ] )
         ENDIF

         cIdPartner := Space( 6 )
         IF !Empty( idpartner )
            cIdPartner := idpartner
         ENDIF
         PRIVATE cBeze := " "
         @ m_x + 14, m_y + 2 SAY "Sifra partnera:"  GET cIdpartner PICT "@!" VALID P_Firma( @cIdPartner )
         @ m_x + 15, m_y + 2 SAY "<ENTER> - prenos" GET cBeze
         read; ESC_BCR

         SELECT PRIPR
         LOCATE FOR BrFaktP = cBrDok // faktura je vec prenesena
         IF Found()
            Beep( 4 )
            @ m_x + 8, m_y + 2 SAY "Dokument je vec prenesen !!"
            Inkey( 4 )
            @ m_x + 8, m_y + 2 SAY Space( 30 )
            LOOP
         ENDIF
         GO BOTTOM
         IF brdok == cBrKalk
            nRbr := Val( Rbr )
         ENDIF
         SELECT xfakt
         IF !ProvjeriSif( "!eof() .and. '" + cFaktFirma + cIdTipDok + cBrDok + "'==IdFirma+IdTipDok+BrDok", "IDROBA", F_ROBA )
            MsgBeep( "U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!" )
            LOOP
         ENDIF

         IF fdoks2
            SELECT doks2; hseek cidfirma + "14" + cbrkalk
            IF !Found()
               APPEND BLANK
               REPLACE idvd WITH "14", ;   // izlazna faktura
               brdok WITH cBrKalk, ;
                  idfirma WITH cidfirma
            ENDIF
            REPLACE DatVal WITH dDatPl
            IF lVrsteP
               REPLACE k2 WITH cIdVrsteP
            ENDIF
            SELECT xFakt

         ENDIF

         DO WHILE !Eof() .AND. cFaktFirma + cIdTipDok + cBrDok == IdFirma + IdTipDok + BrDok
            SELECT ROBA
            hseek xfakt->idroba

            SELECT tarifa
            hseek roba->idtarifa

            IF ( RobaZastCijena( roba->idTarifa ) .AND. !IsPdvObveznik( cIdPartner ) )
               // nije pdv obveznik
               // roba ima zasticenu cijenu
               nRabat := 0
            ELSE
               nRabat := xfakt->rabat
            ENDIF

            SELECT xfakt
            IF AllTrim( podbr ) == "."  .OR. roba->tip $ "UY"
               SKIP
               LOOP
            ENDIF

            SELECT PRIPR
            APPEND BLANK
            REPLACE idfirma WITH cIdFirma, ;
               rbr     WITH Str( ++nRbr, 3 ), ;
               idvd WITH "14", ;   // izlazna faktura
            brdok WITH cBrKalk, ;
               datdok WITH dDatKalk, ;
               idpartner WITH cIdPartner, ;
               idtarifa WITH ROBA->idtarifa, ;
               brfaktp WITH xfakt->brdok, ;
               datfaktp WITH xfakt->datdok, ;
               idkonto   WITH cidkonto, ;
               idkonto2  WITH cidkonto2, ;
               idzaduz2  WITH cidzaduz2, ;
               datkurs WITH xfakt->datdok, ;
               kolicina WITH xfakt->kolicina, ;
               idroba WITH xfakt->idroba, ;
               nc  WITH ROBA->nc, ;
               vpc WITH xfakt->cijena, ;
               rabatv WITH nRabat, ;
               mpc WITH xfakt->porez
            SELECT xfakt
            SKIP
         ENDDO
         @ m_x + 8, m_y + 2 SAY "Dokument je prenesen !!"
         IF gBrojac == "D"
            cbrkalk := UBrojDok( Val( Left( cbrkalk, 5 ) ) + 1, 5, Right( cBrKalk, 3 ) )
         ENDIF
         Inkey( 4 )
         @ m_x + 8, m_y + 2 SAY Space( 30 )
      ENDIF

   ENDDO
   BoxC()
   closeret

   RETURN





/*  PrenosOt(cIndik)
 *   Prenosi FAKT->KALK (12->96),(19->96),(01->10),(0x->16)
 */

FUNCTION PrenosOt( cIndik )

   LOCAL cIdFirma := gFirma
   LOCAL cIdTipDok := "12"
   LOCAL cBrDok := Space( 8 )
   LOCAL cBrKalk := Space( 8 )
   LOCAL cTipKalk := "96"
   LOCAL cFaktDob := Space( 10 )

   IF cIndik != NIL .AND. cIndik == "19"
      cIdTipDok := "19"
   ENDIF
   IF cIndik != NIL .AND. cIndik == "0x"
      cIdTipDok := "0x"
   ENDIF

   IF cIndik = "01_10"

      cTipKalk := "10"
      cIdtipdok := "01"

   ELSEIF cIndik = "0x"

      cTipKalk := "16"

   ENDIF

   O_KONCIJ
   O_PRIPR
   O_KALK
   O_DOKS
   O_ROBA
   O_KONTO
   O_PARTN
   O_TARIFA

   XO_FAKT

   dDatKalk := Date()

   IF cIdTipDok == "01"
      cIdKonto := PadR( "1310", 7 )
      cIdKonto2 := PadR( "", 7 )
   ELSEIF cIdTipDok == "0x"
      cIdKonto := PadR( "1310", 7 )
      cIdKonto2 := PadR( "", 7 )
   ELSE
      cIdKonto := PadR( "", 7 )
      cIdKonto2 := PadR( "1310", 7 )
   ENDIF

   cIdZaduz2 := Space( 6 )

   IF glBrojacPoKontima

      Box( "#FAKT->KALK", 3, 70 )
      @ m_x + 2, m_y + 2 SAY "Konto zaduzuje" GET cIdKonto  PICT "@!" VALID P_Konto( @cIdKonto )
      READ
      BoxC()

      cSufiks := SufBrKalk( cIdKonto )
      cBrKalk := SljBrKalk( cTipKalk, cIdFirma, cSufiks )
      // cBrKalk:=GetNextKalkDoc(cIdFirma, cTipKalk)

   ELSE

      // cBrKalk:=SljBrKalk(cTipKalk,cIdFirma)
      cBrKalk := GetNextKalkDoc( cIdFirma, cTipKalk )

   ENDIF

   Box(, 15, 60 )

   DO WHILE .T.

      nRBr := 0

      @ m_x + 1, m_y + 2   SAY "Broj kalkulacije " + cTipKalk + " -" GET cBrKalk PICT "@!"
      @ m_x + 1, Col() + 2 SAY "Datum:" GET dDatKalk
      @ m_x + 3, m_y + 2   SAY "Konto zaduzuje :" GET cIdKonto  PICT "@!" WHEN !glBrojacPoKontima VALID P_Konto( @cIdKonto )
      @ m_x + 4, m_y + 2   SAY "Konto razduzuje:" GET cIdKonto2 PICT "@!" VALID Empty( cidkonto2 ) .OR. P_Konto( @cIdKonto2 )
      IF gNW <> "X"
         @ m_x + 4, Col() + 2 SAY "Razduzuje:" GET cIdZaduz2  PICT "@!"      VALID Empty( cidzaduz2 ) .OR. P_Firma( @cIdZaduz2 )
      ENDIF

      cFaktFirma := cIdFirma

      @ m_x + 6, m_y + 2 SAY Space( 60 )
      @ m_x + 6, m_y + 2 SAY "Broj dokumenta u FAKT: " GET cFaktFirma
      @ m_x + 6, Col() + 1 SAY "-" GET cIdTipDok VALID cIdTipDok $ "00#01#10#12#19#16"
      @ m_x + 6, Col() + 1 SAY "-" GET cBrDok

      READ

      IF cIDTipDok == "10" .AND. cTipKalk == "10"
         @ m_x + 7, m_y + 2 SAY "Faktura dobavljaca: " GET cFaktDob
      ELSE
         cFaktDob := cBrDok
      ENDIF

      READ

      IF LastKey() == K_ESC
         EXIT
      ENDIF

      SELECT xfakt
      SEEK cFaktFirma + cIdTipDok + cBrDok

      IF !Found()
         Beep( 4 )
         @ m_x + 14, m_y + 2 SAY "Ne postoji ovaj dokument !!"
         Inkey( 4 )
         @ m_x + 14, m_y + 2 SAY Space( 30 )
         LOOP
      ELSE
         aMemo := parsmemo( txt )
         IF Len( aMemo ) >= 5
            @ m_x + 10, m_y + 2 SAY PadR( Trim( amemo[ 3 ] ), 30 )
            @ m_x + 11, m_y + 2 SAY PadR( Trim( amemo[ 4 ] ), 30 )
            @ m_x + 12, m_y + 2 SAY PadR( Trim( amemo[ 5 ] ), 30 )
         ELSE
            cTxt := ""
         ENDIF

         // uzmi i partnera za prebaciti
         cIdPartner := field->idpartner

         PRIVATE cBeze := " "

         IF cTipKalk $ "10"

            cIdPartner := Space( 6 )
            @ m_x + 14, m_y + 2 SAY "Sifra partnera:"  GET cIdpartner PICT "@!" VALID P_Firma( @cIdPartner )
            @ m_x + 15, m_y + 2 SAY "<ENTER> - prenos" GET cBeze

            READ

         ENDIF

         SELECT PRIPR
         LOCATE FOR BrFaktP = cBrDok // faktura je vec prenesena
         IF Found()
            Beep( 4 )
            @ m_x + 8, m_y + 2 SAY "Dokument je vec prenesen !!"
            Inkey( 4 )
            @ m_x + 8, m_y + 2 SAY Space( 30 )
            LOOP
         ENDIF

         GO BOTTOM

         IF brdok == cBrKalk
            nRbr := Val( Rbr )
         ENDIF

         SELECT KONCIJ
         SEEK Trim( cIdKonto )

         SELECT xfakt

         IF !ProvjeriSif( "!eof() .and. '" + cFaktFirma + cIdTipDok + cBrDok + "'==IdFirma+IdTipDok+BrDok", "IDROBA", F_ROBA )
            MsgBeep( "U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!" )
            LOOP
         ENDIF

         DO WHILE !Eof() .AND. cFaktFirma + cIdTipDok + cBrDok == IdFirma + IdTipDok + BrDok
            SELECT ROBA; hseek xfakt->idroba

            SELECT tarifa; hseek roba->idtarifa

            SELECT xfakt
            IF AllTrim( podbr ) == "."  .OR. roba->tip $ "UY"
               SKIP
               LOOP
            ENDIF

            SELECT PRIPR
            APPEND BLANK
            REPLACE idfirma WITH cIdFirma, ;
               rbr     WITH Str( ++nRbr, 3 ), ;
               idvd WITH cTipKalk, ;
               brdok WITH cBrKalk, ;
               datdok WITH dDatKalk, ;
               idpartner WITH cIdPartner, ;
               idtarifa WITH ROBA->idtarifa, ;
               brfaktp WITH cFaktDob, ;
               datfaktp WITH xfakt->datdok, ;
               idkonto   WITH cidkonto, ;
               idkonto2  WITH cidkonto2, ;
               idzaduz2  WITH cidzaduz2, ;
               datkurs WITH xfakt->datdok, ;
               kolicina WITH xfakt->kolicina, ;
               idroba WITH xfakt->idroba, ;
               nc  WITH ROBA->nc, ;
               vpc WITH xfakt->cijena, ;
               rabatv WITH xfakt->rabat, ;
               mpc WITH xfakt->porez

            IF cTipKalk $ "10#16" // kod ulaza puni sa cijenama iz sifranika
               // replace vpc with roba->vpc
               REPLACE vpc WITH KoncijVPC()
            ENDIF

            IF cTipKalk $ "96" .AND. xfakt->( FieldPos( "idrnal" ) ) <> 0
               REPLACE idzaduz2 WITH xfakt->idRNal
            ENDIF

            SELECT xfakt
            SKIP
         ENDDO

         @ m_x + 8, m_y + 2 SAY "Dokument je prenesen !!"

         IF gBrojac == "D"
            cBrKalk := UBrojDok( Val( Left( cbrkalk, 5 ) ) + 1, 5, Right( cBrKalk, 3 ) )
         ENDIF

         Inkey( 4 )

         @ m_x + 8, m_y + 2 SAY Space( 30 )

      ENDIF

   ENDDO

   BoxC()

   closeret

   RETURN


FUNCTION SufBrKalk( cIdKonto )

   LOCAL nArr := Select()
   LOCAL cSufiks := Space( 3 )

   SELECT koncij
   SEEK cIdKonto
   IF Found()
      cSufiks := field->sufiks
   ENDIF
   SELECT ( nArr )

   RETURN cSufiks


// --------------------------
// --------------------------
FUNCTION IsNumeric( cString )

   IF At( cString, "0123456789" ) <> 0
      lResult := .T.
   ELSE
      lResult := .F.
   ENDIF

   RETURN lResult
