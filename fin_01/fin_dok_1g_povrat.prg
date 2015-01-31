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


// -------------------------------------
// povrat naloga u pripremu
// -------------------------------------
FUNCTION fin_povrat( lStorno )

   LOCAL nRec

   IF lStorno == NIL
      lStorno := .F.
   ENDIF

   IF Logirati( goModul:oDataBase:cName, "DOK", "POVRAT" )
      lLogPovrat := .T.
   ELSE
      lLogPovrat := .F.
   ENDIF

   O_SUBAN
   O_PRIPR
   O_ANAL
   O_SINT
   O_NALOG

   SELECT SUBAN
   SET ORDER TO 4

   cIdFirma := gFirma
   cIdFirma2 := gFirma
   cIdVN := cIdVN2 := Space( 2 )
   cBrNal := cBrNal2 := Space( 8 )

   Box( "", IF( lStorno, 3, 1 ), IF( lStorno, 65, 35 ) )
   @ m_x + 1, m_y + 2 SAY "Nalog:"
   IF gNW == "D"
      @ m_x + 1, Col() + 1 SAY cIdFirma PICT "@!"
   ELSE
      @ m_x + 1, Col() + 1 GET cIdFirma PICT "@!"
   ENDIF
   @ m_x + 1, Col() + 1 SAY "-" GET cIdVN PICT "@!"
   @ m_x + 1, Col() + 1 SAY "-" GET cBrNal VALID _f_brnal( @cBrNal )
   IF lStorno
      @ m_x + 3, m_y + 2 SAY "Broj novog naloga (naloga storna):"
      IF gNW == "D"
         @ m_x + 3, Col() + 1 SAY cIdFirma2
      ELSE
         @ m_x + 3, Col() + 1 GET cIdFirma2
      ENDIF
      @ m_x + 3, Col() + 1 SAY "-" GET cIdVN2 PICT "@!"
      @ m_x + 3, Col() + 1 SAY "-" GET cBrNal2
   ENDIF
   read; ESC_BCR
   BoxC()


   IF cBrNal = "."
      IF !sifra_za_koristenje_opcije()
         CLOSERET
      ENDIF
      PRIVATE qqBrNal := qqDatDok := qqIdvn := Space( 80 )
      qqIdVn := PadR( cidvn + ";", 80 )
      Box(, 3, 60 )
      DO WHILE .T.
         @ m_x + 1, m_y + 2 SAY "Vrste naloga   "  GET qqIdVn PICT "@S40"
         @ m_x + 2, m_y + 2 SAY "Broj naloga    "  GET qqBrNal PICT "@S40"
         READ
         PRIVATE aUsl1 := Parsiraj( qqBrNal, "BrNal", "C" )
         PRIVATE aUsl3 := Parsiraj( qqIdVN, "IdVN", "C" )
         IF aUsl1 <> NIL .AND. ausl3 <> NIL
            EXIT
         ENDIF
      ENDDO
      Boxc()
      IF Pitanje(, IF( lStorno, "Stornirati", "Povuci u pripremu" ) + " naloge sa ovim kriterijem ?", "N" ) == "D"
         SELECT suban
         IF !FLock()
            Msg( "SUBANALITIKA je zauzeta ", 3 )
            closeret
         ENDIF

         PRIVATE cFilt := "IdFirma==" + cm2str( cIdFirma )
         IF aUsl1 == ".t." .AND. aUsl3 == ".t."
            SET FILTER to &cFilt
         ELSE
            cFilt := cFilt + ".and." + aUsl1 + ".and." + aUsl3
            SET FILTER to &cFilt
         ENDIF


         MsgO( "Prolaz kroz SUBANALITIKU..." )
         GO TOP
         DO WHILE !Eof()
            SELECT SUBAN; Scatter()
            SELECT PRIPR
            IF lStorno
               _idfirma := cIdFirma2
               _idvn := cIdVn2
               _brnal := cBrNal2
               _iznosbhd := -_iznosbhd
               _iznosdem := -_iznosdem
            ENDIF
            APPEND ncnl;  Gather2()
            SELECT suban
            SKIP
            nRec := RecNo()
            SKIP -1

            IF !lStorno; dbdelete2(); ENDIF

            GO nRec
         ENDDO
         MsgC()
         MsgO( "Prolaz kroz ANALITIKU..." )
         SELECT anal
         IF !FLock(); msg( "Datoteka je zauzeta ", 3 ); closeret; ENDIF

         PRIVATE cFilt := "IdFirma==" + cm2str( cIdFirma )
         IF aUsl1 == ".t." .AND. aUsl3 == ".t."
            SET FILTER to &cFilt
         ELSE
            cFilt := cFilt + ".and." + aUsl1 + ".and." + aUsl3
            SET FILTER to &cFilt
         ENDIF
         GO TOP
         DO WHILE !Eof()
            skip; nRec := RecNo(); SKIP -1
            IF !lStorno; dbdelete2(); ENDIF
            GO nRec
         ENDDO
         MsgC()

         MsgO( "Prolaz kroz SINTETIKU..." )
         SELECT sint
         IF !FLock(); msg( "Datoteka je zauzeta ", 3 ); closeret; ENDIF



         PRIVATE cFilt := "IdFirma==" + cm2str( cIdFirma )
         IF aUsl1 == ".t." .AND. aUsl3 == ".t."
            SET FILTER to &cFilt
         ELSE
            cFilt := cFilt + ".and." + aUsl1 + ".and." + aUsl3
            SET FILTER to &cFilt
         ENDIF
         GO TOP
         DO WHILE !Eof()
            skip; nRec := RecNo(); SKIP -1
            IF !lStorno; dbdelete2(); ENDIF
            GO nRec
         ENDDO
         MsgC()
         MsgO( "Prolaz kroz NALOZI..." )
         SELECT nalog
         IF !FLock(); msg( "Datoteka je zauzeta ", 3 ); closeret; ENDIF
         PRIVATE cFilt := "IdFirma==" + cm2str( cIdFirma )
         IF aUsl1 == ".t." .AND. aUsl3 == ".t."
            SET FILTER to &cFilt
         ELSE
            cFilt := cFilt + ".and." + aUsl1 + ".and." + aUsl3
            SET FILTER to &cFilt
         ENDIF
         GO TOP
         DO WHILE !Eof()
            skip; nRec := RecNo(); SKIP -1
            IF !lStorno; dbdelete2(); ENDIF
            GO nRec
         ENDDO
         MsgC()

      ENDIF
      closeret
   ENDIF


   IF Pitanje(, "Nalog " + cIdFirma + "-" + cIdVN + "-" + cBrNal + IF( lStorno, " stornirati", " povuci u pripremu" ) + " (D/N) ?", "D" ) == "N"
      closeret
   ENDIF

   lBrisi := .T.
   IF !lStorno
      IF IzFMKIni( "FIN", "MogucPovratNalogaBezBrisanja", "N", KUMPATH ) == "D"
         lBrisi := ( Pitanje(, "Nalog " + cIdFirma + "-" + cIdVN + "-" + cBrNal + ;
            " izbrisati iz baze azuriranih dokumenata (D/N) ?", "D" ) == "D" )
      ENDIF
   ENDIF

   MsgO( "SUBAN" )

   SELECT SUBAN
   SEEK cidfirma + cidvn + cbrNal
   DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdVN == IdVN .AND. cBrNal == BrNal
      SELECT PRIPR; Scatter()
      SELECT SUBAN; Scatter()
      SELECT PRIPR
      IF lStorno
         _idfirma := cIdFirma2
         _idvn := cIdVn2
         _brnal := cBrNal2
         _iznosbhd := -_iznosbhd
         _iznosdem := -_iznosdem
      ENDIF
#ifdef XBASE
      APPEND blank; Gather()
#else
      APPEND ncnl; Gather2()
#endif
      SELECT SUBAN
      SKIP
   ENDDO

   IF !lBrisi
      CLOSERET
   ENDIF

   IF tbl_busy( F_SUBAN ) = 0
      msg( "Datoteka je zauzeta ", 3 )
      closeret
   ENDIF

   // if !flock(); msg("Datoteka je zauzeta ",3); closeret; endif

   SEEK cidfirma + cidvn + cbrNal
   DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdVN == IdVN .AND. cBrNal == BrNal
      SKIP 1; nRec := RecNo(); SKIP -1
      IF !lStorno; dbdelete2(); ENDIF
      GO nRec
   ENDDO
   USE

   MsgC()

   MsgO( "ANAL" )
   SELECT ANAL; SET ORDER TO 2

   IF tbl_busy( F_ANAL ) = 0
      msg( "Datoteka je zauzeta ", 3 )
      closeret
   ENDIF

   // if !flock(); msg("Datoteka je zauzeta ",3); closeret; endif

   SEEK cidfirma + cidvn + cbrNal
   DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdVN == IdVN .AND. cBrNal == BrNal
      SKIP 1; nRec := RecNo(); SKIP -1
      IF !lStorno; dbdelete2(); ENDIF
      GO nRec
   ENDDO
   USE
   MsgC()


   MsgO( "SINT" )
   SELECT sint;  SET ORDER TO 2

   IF tbl_busy( F_SINT ) = 0
      msg( "Datoteka je zauzeta ", 3 )
      closeret
   ENDIF

   // if !flock(); msg("Datoteka je zauzeta ",3); closeret; endif

   SEEK cidfirma + cidvn + cbrNal
   DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdVN == IdVN .AND. cBrNal == BrNal
      SKIP 1; nRec := RecNo(); SKIP -1
      IF !lStorno; dbdelete2(); ENDIF
      GO nRec
   ENDDO

   USE
   MsgC()

   MsgO( "NALOG" )
   SELECT nalog

   IF tbl_busy( F_NALOG ) = 0
      msg( "Datoteka je zauzeta ", 3 )
      closeret
   ENDIF
   // if !flock(); msg("Datoteka je zauzeta ",3); closeret; endif

   SEEK cidfirma + cidvn + cbrNal
   DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdVN == IdVN .AND. cBrNal == BrNal
      SKIP 1; nRec := RecNo(); SKIP -1
      IF !lStorno; dbdelete2(); ENDIF
      GO nRec
   ENDDO
   USE
   MsgC()

   IF lLogPovrat
      EventLog( nUser, goModul:oDataBase:cName, "DOK", "POVRAT", nil, nil, nil, nil, "", "", cIdFirma + "-" + cIdVn + "-" + cBrNal, Date(), Date(), "", "Povrat naloga u pripremu" )
   ENDIF

   closeret

   RETURN



// --------------------------------
// tabela zauzeta
// --------------------------------
FUNCTION tbl_busy( f_area )

   LOCAL nTime
   PRIVATE cAlias := Alias( f_area )

   IF !( &( cAlias )->( FLock() ) )

      IF gAzurTimeOut == nil
         nTime := 150
      ELSE
         nTime := gAzurTimeOut
      ENDIF

      Box(, 1, 40 )

      // daj mu vremena...
      DO WHILE nTime > 0

         -- nTime

         @ m_x + 1, m_y + 2 SAY "timeout: " + AllTrim( Str( nTime ) )

         IF ( &( cAlias )->( FLock() ) )
            EXIT
         ENDIF

         Sleep( 1 )

      ENDDO

      BoxC()

      IF nTime = 0 .AND. !( &( cAlias )->( FLock() ) )

         Beep( 4 )
         BoxC()
         Msg( "Timeout istekao !#Ponovite operaciju" )
         CLOSE
         RETURN 0

      ENDIF

   ENDIF

   RETURN 1


/*  Preknjiz()
 *   Preknjizenje naloga
 */

FUNCTION Preknjiz()

   LOCAL fK1 := "N"
   LOCAL fk2 := "N"
   LOCAL fk3 := "N"
   LOCAL fk4 := "N"
   LOCAL cSK := "N"

   nC := 50

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

   cIdFirma := gFirma
   picBHD := FormPicL( "9 " + gPicBHD, 20 )

   O_PARTN

   dDatOd := CToD( "" )
   dDatDo := CToD( "" )

   qqKonto := Space( 100 )
   qqPartner := Space( 100 )
   IF gRJ == "D"
      qqIdRj := Space( 100 )
   ENDIF

   cTip := "1"

   Box( "", 14, 65 )
   SET CURSOR ON

   cK1 := "9"
   cK2 := "9"
   cK3 := "99"
   cK4 := "99"

   IF IzFMKIni( "FIN", "LimitiPoUgovoru_PoljeK3", "N", SIFPATH ) == "D"
      cK3 := "999"
   ENDIF

   cNula := "N"
   cPreknjizi := "P"
   cStrana := "D"
   cIDVN := "88"
   cBrNal := "00000001"
   dDatDok := Date()
   cRascl := "D"
   PRIVATE lRJRascl := .F.


   DO WHILE .T.
      @ m_x + 1, m_y + 6 SAY "PREKNJIZENJE SUBANALITICKIH KONTA"
      IF gNW == "D"
         @ m_x + 2, m_y + 2 SAY "Firma "
         ?? gFirma, "-", gNFirma
      ELSE
         @ m_x + 2, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| P_Firma( @cIdFirma ), cIdFirma := Left( cIdFirma, 2 ), .T. }
      ENDIF
      @ m_x + 3, m_y + 2 SAY "Konto   " GET qqKonto  PICT "@!S50"
      @ m_x + 4, m_y + 2 SAY "Partner " GET qqPartner PICT "@!S50"
      IF gRJ == "D"
         @ m_x + 5, m_y + 2 SAY "Rad.jed." GET qqIdRj PICT "@!S50"
         @ m_x + 6, m_y + 2 SAY "Rasclaniti po RJ" GET cRascl PICT "@!" VALID cRascl $ "DN"
      ENDIF
      @ m_x + 7, m_y + 2 SAY "Datum dokumenta od" GET dDatOd
      @ m_x + 7, Col() + 2 SAY "do" GET dDatDo

      // dodata mogucnost izbora i saldo (T), aMersed, 26.03.2004
      @ m_x + 8, m_y + 2 SAY "Protustav/Storno/Saldo (P/S/T) " GET cPreknjizi VALID cPreknjizi $ "PST" PICT "@!"
      // ako je cPreknjizi T onda mora odrediti na koju stranu knjizi
      // posto moram provjeriti upravo upisanu varijablu ide READ
      READ

      IF cPreknjizi == "T"
         @ m_x + 9, m_y + 38 SAY "Duguje/Potrazuje (D/P)" GET cStrana VALID cStrana $ "DP" PICT "@!"
      ENDIF

      @ m_x + 10, m_y + 2 SAY "Sifra naloga koji se generise" GET cIDVN
      @ m_x + 10, Col() + 2 SAY "Broj" GET cBrNal
      @ m_x + 10, Col() + 2 SAY "datum" GET dDatDok
      IF fk1 == "D"
         @ m_x + 11, m_y + 2 SAY "K1 (9 svi) :" GET cK1
      ENDIF
      IF fk2 == "D"
         @ m_x + 12, m_y + 2 SAY "K2 (9 svi) :" GET cK2
      ENDIF
      IF fk3 == "D"
         @ m_x + 13, m_y + 2 SAY "K3 (" + cK3 + " svi):" GET cK3
      ENDIF
      IF fk4 == "D"
         @ m_x + 14, m_y + 2 SAY "K4 (99 svi):" GET cK4
      ENDIF

      READ
      ESC_BCR

      aUsl1 := Parsiraj( qqKonto, "IdKonto" )
      aUsl2 := Parsiraj( qqPartner, "IdPartner" )
      IF gRJ == "D"
         IF cRascl == "D"
            lRJRascl := .T.
         ENDIF
      ENDIF
      IF gRJ == "D"
         aUsl3 := Parsiraj( qqIdRj, "IdRj" )
      ENDIF
      IF aUsl1 <> NIL .AND. aUsl2 <> NIL
         EXIT
      ENDIF

      IF gRJ == "D" .AND. aUsl3 <> NIL
         EXIT
      ENDIF

   ENDDO
   BoxC()

   cIdFirma := Left( cIdFirma, 2 )

   O_PRIPR
   O_KONTO
   O_SUBAN

   IF cK1 == "9"
      cK1 := ""
   ENDIF
   IF cK2 == "9"
      cK2 := ""
   ENDIF
   IF cK3 == REPL( "9", Len( ck3 ) )
      cK3 := ""
   ELSE
      cK3 := K3U256( cK3 )
   ENDIF
   IF cK4 == "99"
      cK4 := ""
   ENDIF

   SELECT SUBAN

   IF ( gRj == "D" .AND. lRjRascl )
      SET ORDER TO TAG "9" // idfirma+idkonto+idrj+idpartner+...
   ELSE
      SET ORDER TO TAG "1"
   ENDIF

   cFilt1 := "IDFIRMA=" + Cm2Str( cIdFirma ) + ".and." + aUsl1 + ".and." + aUsl2 + IF( gRJ == "D", ".and." + aUsl3, "" ) + ;
      IF( Empty( dDatOd ), "", ".and.DATDOK>=" + cm2str( dDatOd ) ) + ;
      IF( Empty( dDatDo ), "", ".and.DATDOK<=" + cm2str( dDatDo ) ) + ;
      IF( fk1 == "N", "", ".and.k1=" + cm2str( ck1 ) ) + ;
      IF( fk2 == "N", "", ".and.k2=" + cm2str( ck2 ) ) + ;
      IF( fk3 == "N", "", ".and.k3=ck3" ) + ;
      IF( fk4 == "N", "", ".and.k4=" + cm2str( ck4 ) )

   cFilt1 := StrTran( cFilt1, ".t..and.", "" )

   IF !( cFilt1 == ".t." )
      SET FILTER TO &cFilt1
   ENDIF

   GO TOP
   EOF CRET

   Pic := PicBhd

   IF cTip == "3"
      m := "------  ------ ------------------------------------------------- --------------------- --------------------"
   ELSE
      m := "------  ------ ------------------------------------------------- --------------------- -------------------- --------------------"
   ENDIF

   nStr := 0
   nUd := 0
   nUp := 0      // DIN
   nUd2 := 0
   nUp2 := 0    // DEM
   nRbr := 0

   SELECT pripr
   GO BOTTOM
   nRbr := Val( rbr )
   SELECT suban

   DO WHILE not_key_esc() .AND. !Eof()
      cSin := Left( idkonto, 3 )
      nKd := 0
      nKp := 0
      nKd2 := 0
      nKp2 := 0

      DO WHILE not_key_esc() .AND. !Eof() .AND.  cSin == Left( idkonto, 3 )
         cIdKonto := IdKonto
         cIdPartner := IdPartner
         IF gRj == "D"
            cIdRj := idRj
         ENDIF
         nD := 0
         nP := 0
         nD2 := 0
         nP2 := 0

         IF ( gRj == "D" .AND. lRjRascl )
            bCond := {|| cIdKonto == IdKonto .AND. IdRj == cIdRj .AND. IdPartner == cIdPartner }
         ELSE
            bCond := {|| cIdKonto == IdKonto .AND. IdPartner == cIdPartner }
         ENDIF

         DO WHILE not_key_esc() .AND. !Eof() .AND. Eval( bCond )
            IF d_P == "1"
               nD += iznosbhd
               nD2 += iznosdem
            ELSE
               nP += iznosbhd
               nP2 += iznosdem
            ENDIF
            SKIP
         ENDDO    // partner

         SELECT pripr

         // dodata opcija za preknjizenje saldo T
         IF cPreknjizi == "T"
            IF Round( nD - nP, 2 ) <> 0
               APPEND BLANK
               REPLACE idfirma WITH cIdFirma, idpartner WITH cIdPartner, idkonto WITH cIdKonto, idvn WITH cIdVn, brnal WITH cBrNal, datdok WITH dDatDok, rbr WITH Str( ++nRbr, 4 )
               REPLACE d_p WITH iif( cStrana == "D", "1", "2" ), iznosbhd with ( nD - nP ), iznosdem with ( nD2 - nP2 )
               IF gRj == "D"
                  REPLACE idrj WITH cIdRj
               ENDIF
            ENDIF
         ENDIF

         IF cPreknjizi == "P"
            IF Round( nD - nP, 2 ) <> 0
               APPEND BLANK
               REPLACE idfirma WITH cIdFirma, idpartner WITH cIdPartner, idkonto WITH cIdKonto, idvn WITH cIdVn, brnal WITH cBrNal, datdok WITH dDatDok, rbr WITH Str( ++nRbr, 4 )
               REPLACE  d_p WITH iif( nD - nP > 0, "2", "1" ), iznosbhd WITH Abs( nD - nP ), iznosdem WITH Abs( nD2 - nP2 )
               IF gRj == "D"
                  REPLACE idrj WITH cIdRj
               ENDIF
            ENDIF
         ENDIF

         IF cPreknjizi == "S"
            IF Round( nD, 3 ) <> 0
               APPEND BLANK
               REPLACE idfirma WITH cIdFirma, idpartner WITH cIdPartner, idkonto WITH cIdKonto, idvn WITH cIdVn, brnal WITH cBrNal, datdok WITH dDatDok, rbr WITH Str( ++nRbr, 4 )
               REPLACE  d_p WITH "1", iznosbhd WITH -nd, iznosdem WITH -nd2
               IF gRj == "D"
                  REPLACE idrj WITH cIdRj
               ENDIF
            ENDIF
            IF Round( nP, 3 ) <> 0
               APPEND BLANK
               REPLACE idfirma WITH cIdFirma, idpartner WITH cIdPartner, idkonto WITH cIdKonto, idvn WITH cIdVn, brnal WITH cBrNal, datdok WITH dDatDok, rbr WITH Str( ++nRbr, 4 )
               REPLACE  d_p WITH "2", iznosbhd WITH -nP, iznosdem WITH -nP2
               IF gRj == "D"
                  REPLACE idrj WITH cIdRj
               ENDIF
            ENDIF
         ENDIF
         SELECT suban
         nKd += nD
         nKp += nP  // ukupno  za klasu
         nKd2 += nD2
         nKp2 += nP2  // ukupno  za klasu
      ENDDO  // sintetika
      nUd += nKd
      nUp += nKp   // ukupno za sve
      nUd2 += nKd2
      nUp2 += nKp2   // ukupno za sve
   ENDDO // eof
   closeret

   RETURN
