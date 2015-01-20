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



FUNCTION SifkPartnBank()

   O_SIFK
   SET ORDER TO TAG "ID2"
   SEEK PadR( "PARTN", 8 ) + "BANK"
   IF !Found()
      IF Pitanje(, "U sifk dodati PARTN/BANK  ?", "D" ) == "D"
         APPEND BLANK
         REPLACE id WITH "PARTN", oznaka WITH "BANK", naz WITH "Banke", ;
            Veza WITH "N", Duzina WITH 16, Tip WITH "C"
      ENDIF
   ENDIF
   USE

   RETURN NIL




/*  OKumul(nArea,cStaza,cIme,nIndexa,cDefault)
 *   Kopira podatke sa mreze radi brzine pregleda dokumenata, sluzi samo za pregled
 *   nArea    - podrucje
 *   cStaza
 *   cIme
 *   nIndexa
 *   cDefault
 */

FUNCTION OKumul( nArea, cStaza, cIme, nIndexa, cDefault )

   LOCAL cPath, cScreen

   IF cDefault == NIL
      cDefault := "0"
   ENDIF

   SELECT ( nArea )
   IF gKesiraj $ "CD"
      cPath := StrTran( cStaza, Left( cStaza, 3 ), gKesiraj + ":" + SLASH )

      DirMak2( cPath )  // napravi odredisni direktorij

      IF cDefault != "0"
         IF !File2( cPath + cIme + ".DBF" ) .OR. Pitanje(, "Osvjeziti podatke za " + cIme, cDefault ) == "D"
            SAVE SCREEN TO cScr
            cls
            ? "Molim sacekajte prenos podataka na vas racunar "
            ? "radi brzeg pregleda podataka"
            ?
            ? "Ovaj racunar NE KORISTITE za unos novih podataka !"
            ?
            CLOSE ALL
            Copysve( cIme + "*.DB?", cStaza, cPath )
            Copysve( cIme + "*.CDX", cStaza, cPath )
            ?
            ? "pritisni nesto za nastavak ..."
            Inkey( 10 )
            RESTORE SCREEN FROM cScr
         ENDIF
      ENDIF

   ELSE
      cPath := cStaza
   ENDIF
   cPath := cPath + cIme
   USE  ( cPath )

   RETURN NIL


// -----------------------------------------------------------------
// provjerava da li u pripremi postoji vise razlicitih dokumenata
// -----------------------------------------------------------------
STATIC FUNCTION _is_vise_dok()

   LOCAL lRet := .F.
   LOCAL nTRec := RecNo()
   LOCAL cBrNal
   LOCAL cTmpNal := "XXXXXXXX"

   SELECT pripr
   GO TOP

   cTmpNal := field->brnal

   DO WHILE !Eof()

      cBrNal := field->brnal

      IF  cBrNal == cTmpNal


         cTmpNal := cBrNal

         SKIP
         LOOP

      ELSE
         lRet := .T.
         EXIT
      ENDIF

   ENDDO

   RETURN lRet


// ------------------------------------------------------------
// provjeri duple stavke u pripremi za vise dokumenata
// ------------------------------------------------------------
STATIC FUNCTION prov_duple_stavke()

   LOCAL cSeekNal
   LOCAL lNalExist := .F.

   SELECT pripr
   GO TOP

   // provjeri duple dokumente
   DO WHILE !Eof()

      cSeekNal := pripr->( idfirma + idvn + brnal )

      IF dupli_nalog( cSeekNal )
         lNalExist := .T.
         EXIT
      ENDIF

      SELECT pripr
      SKIP

   ENDDO

   // postoje dokumenti dupli
   IF lNalExist
      MsgBeep( "U pripremi su se pojavili dupli nalozi !" )
      IF Pitanje(, "Pobrisati duple naloge (D/N)?", "D" ) == "N"
         MsgBeep( "Dupli nalozi ostavljeni u tabeli pripreme!#Prekidam operaciju azuriranja!" )
         RETURN 1
      ELSE
         Box(, 1, 60 )

         cKumPripr := "P"
         @ m_x + 1, m_y + 2 SAY "Zelite brisati stavke iz kumulativa ili pripreme (K/P)" GET cKumPripr VALID !Empty( cKumPripr ) .OR. cKumPripr $ "KP" PICT "@!"
         READ
         BoxC()

         IF cKumPripr == "P"
            // brisi pripremu
            RETURN prip_brisi_duple()
         ELSE
            // brisi kumulativ
            RETURN kum_brisi_duple()
         ENDIF
      ENDIF
   ENDIF

   RETURN 0


// ------------------------------------------------------------
// brisi stavke iz pripreme koje se vec nalaze u kumulativu
// ------------------------------------------------------------
STATIC FUNCTION prip_brisi_duple()

   LOCAL cSeek

   SELECT pripr
   GO TOP

   DO WHILE !Eof()

      cSeek := pripr->( idfirma + idvn + brnal )

      IF dupli_nalog( cSeek )
         // pobrisi stavku
         SELECT pripr
         DELETE
      ENDIF

      SELECT pripr
      SKIP
   ENDDO

   RETURN 0


// -------------------------------------------------------------
// brisi stavke iz kumulativa koje se vec nalaze u pripremi
// -------------------------------------------------------------
STATIC FUNCTION kum_brisi_duple()

   LOCAL cSeek

   SELECT pripr
   GO TOP

   cKontrola := "XXX"

   DO WHILE !Eof()

      cSeek := pripr->( idfirma + idvn + brnal )

      IF cSeek == cKontrola
         SKIP
         LOOP
      ENDIF

      IF dupli_nalog( cSeek )

         MsgO( "Brisem stavke iz kumulativa ... sacekajte trenutak!" )

         // brisi nalog
         SELECT nalog

         IF !FLock()
            msg( "Datoteka je zauzeta ", 3 )
            closeret
         ENDIF

         SET ORDER TO TAG "1"
         GO TOP
         SEEK cSeek

         IF Found()

            DO WHILE !Eof() .AND. nalog->( idfirma + idvn + brnal ) == cSeek
               SKIP 1
               nRec := RecNo()
               SKIP -1
               DbDelete2()
               GO nRec
            ENDDO
         ENDIF

         // brisi iz suban
         SELECT suban
         IF !FLock()
            msg( "Datoteka je zauzeta ", 3 )
            closeret
         ENDIF

         SET ORDER TO TAG "4"
         GO TOP
         SEEK cSeek
         IF Found()
            DO WHILE !Eof() .AND. suban->( idfirma + idvn + brnal ) == cSeek

               SKIP 1
               nRec := RecNo()
               SKIP -1
               DbDelete2()
               GO nRec
            ENDDO
         ENDIF


         // brisi iz sint
         SELECT sint
         IF !FLock()
            msg( "Datoteka je zauzeta ", 3 )
            closeret
         ENDIF

         SET ORDER TO TAG "2"
         GO TOP
         SEEK cSeek
         IF Found()
            DO WHILE !Eof() .AND. sint->( idfirma + idvn + brnal ) == cSeek

               SKIP 1
               nRec := RecNo()
               SKIP -1
               DbDelete2()
               GO nRec
            ENDDO
         ENDIF

         // brisi iz anal
         SELECT anal
         IF !FLock()
            msg( "Datoteka je zauzeta ", 3 )
            closeret
         ENDIF

         SET ORDER TO TAG "2"
         GO TOP
         SEEK cSeek
         IF Found()
            DO WHILE !Eof() .AND. anal->( idfirma + idvn + brnal ) == cSeek

               SKIP 1
               nRec := RecNo()
               SKIP -1
               DbDelete2()
               GO nRec
            ENDDO
         ENDIF


         MsgC()
      ENDIF

      cKontrola := cSeek

      SELECT pripr
      SKIP
   ENDDO

   RETURN 0


// ------------------------------------------
// provjerava da li je dokument dupli
// ------------------------------------------
STATIC FUNCTION dupli_nalog( cSeek )

   SELECT nalog
   SET ORDER TO TAG "1"
   GO TOP
   SEEK cSeek
   IF Found()
      RETURN .T.
   ENDIF

   RETURN .F.



/*  fin_Azur(lAuto)
 *   Azuriranje knjizenja
 *   lAuto - .t. azuriraj automatski, .f. azuriraj sa pitanjem
 */

FUNCTION fin_Azur( lAuto )

   LOCAL bErrHan, nC
   LOCAL nTArea := Select()

   IF Logirati( goModul:oDataBase:cName, "DOK", "AZUR" )
      lLogAzur := .T.
   ELSE
      lLogAzur := .F.
   ENDIF

   IF ( lAuto == NIL )
      lAuto := .F.
   ENDIF

   IF !lAuto .AND. Pitanje( "pAz", "Sigurno zelite izvrsiti azuriranje (D/N)?", "N" ) == "N"
      RETURN
   ENDIF

   O_KONTO
   O_PARTN
   O_PRIPR
   O_SUBAN
   O_ANAL
   O_SINT
   O_NALOG

   O_PSUBAN
   O_PANAL
   O_PSINT
   O_PNALOG

   // provjeri da li se u pripremi nalazi vise dokumenata... razlicitih
   IF _is_vise_dok() == .T.

      // provjeri za duple stavke prilikom azuriranja...
      IF prov_duple_stavke() == 1
         RETURN
      ENDIF

      // nafiluj sve potrebne tabele
      stnal( .T. )
   ENDIF

   O_KONTO
   O_PARTN
   O_PRIPR
   O_SUBAN
   O_ANAL
   O_SINT
   O_NALOG

   O_PSUBAN
   O_PANAL
   O_PSINT
   O_PNALOG


   fAzur := .T.
   SELECT PSUBAN

   IF reccount2() == 0
      fAzur := .F.
   ENDIF
   SELECT PANAL
   IF reccount2() == 0
      fAzur := .F.
   ENDIF
   SELECT PSINT
   IF reccount2() == 0
      fAzur := .F.
   ENDIF


   IF !fAzur
      Beep( 3 )
      Msg( "Niste izvršili štampanje naloga ...", 10 )
      closeret
   ENDIF

   IF lLogAzur
      cOpis := pripr->idfirma + "-" + ;
         pripr->idvn + "-" + ;
         pripr->brnal

      EventLog( nUser, goModul:oDataBase:cName, "DOK", "AZUR", ;
         nil, nil, nil, nil, ;
         cOpis, "", "", pripr->datdok, Date(), ;
         "", "Azuriranje dokumenta - poceo !" )

   ENDIF

   Box(, 5, 60 )
   SELECT PSUBAN
   SET ORDER TO 1
   GO TOP

   fIzgenerisi := .F.
   IF reccount2() > 9999 .AND. !lAuto
      IF Pitanje(, "Staviti na stanje bez provjere ?", "N" ) == "D"
         fizgenerisi := .T.
      ENDIF
   ENDIF


   DO WHILE !Eof()
      // prodji kroz PSUBAN i vidi da li je nalog zatvoren
      // samo u tom slucaju proknjizi nalog u odgovarajuce datoteke

      cNal := IDFirma + IdVn + BrNal
      IF "." $ cNal
         MsgBeep( "Nalog " + IdFirma + "-" + idvn + "-" + ( brnal ) + ;
            " sadrzi znak '.' i zato nece biti azuriran!" )
         DO WHILE !Eof() .AND. cNal == IDFirma + IdVn + BrNal
            SKIP 1
         ENDDO
         LOOP
      ENDIF

      @ m_x + 1, m_y + 2 SAY "Azuriram nalog: " + IdFirma + "-" + idvn + "-" + AllTrim( brnal )
      nSaldo := 0

      cEvIdFirma := idfirma
      cEvVrBrNal := idvn + "-" + brnal
      dDatNaloga := datdok
      dDatValute := datval

      DO WHILE !Eof() .AND. cNal == IdFirma + IdVn + BrNal

         IF !Empty( psuban->idpartner )
            SELECT partn
            hseek psuban->idpartner

            IF !Found() .AND. !fizgenerisi
               Beep( 1 )
               Msg( "Stavka br." + psuban->rbr + ": Nepostojeca sifra partnera!" )
               IF PSUBAN->idvn == "00" .AND. Pitanje(, "Preuzeti nepostojecu sifru iz sezone?", "N" ) == 'D'
                  PreuzSezSPK( "P" )
               ELSE
                  Boxc()
                  SELECT PSUBAN
                  zapp()
                  SELECT PANAL
                  zapp()
                  SELECT PSINT
                  zapp()
                  closeret
               ENDIF
            ENDIF
         ENDIF
         IF !Empty( psuban->idkonto )
            SELECT konto
            hseek psuban->idkonto
            IF !Found() .AND. !fizgenerisi
               Beep( 1 )
               Msg( "Stavka br." + psuban->rbr + ": Nepostojeca sifra konta!" )
               IF PSUBAN->idvn == "00" .AND. Pitanje(, "Preuzeti nepostojecu sifru iz sezone?", "N" ) == 'D'
                  PreuzSezSPK( "K" )
               ELSE
                  Boxc()
                  SELECT PSUBAN
                  zapp()
                  SELECT PANAL
                  zapp()
                  SELECT PSINT
                  zapp()
                  closeret
               ENDIF
            ENDIF
         ENDIF
         SELECT psuban

         IF D_P == "1"
            nSaldo += IznosBHD
         ELSE
            nSaldo -= IznosBHD
         ENDIF
         SKIP
      ENDDO

      IF Round( nSaldo, 4 ) <> 0 .AND. gRavnot == "D"
         Beep( 1 )
         Msg( "Neophodna ravnoteza naloga, azuriranje nece biti izvrseno!" )
      ENDIF

      // nalog je uravnotezen, azuriraj ga !
      IF Round( nSaldo, 4 ) == 0  .OR. gRavnot == "N"

         IF !( SUBAN->( FLock() ) .AND. ;
               ANAL->( FLock() ) .AND.  ;
               SINT->( FLock() ) .AND.  ;
               NALOG->( FLock() )  )

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

               IF ( SUBAN->( FLock() ) .AND. ;
                     ANAL->( FLock() ) .AND.  ;
                     SINT->( FLock() ) .AND.  ;
                     NALOG->( FLock() )  )
                  EXIT
               ENDIF

               Sleep( 1 )

            ENDDO

            BoxC()

            IF nTime = 0 .AND. !( SUBAN->( FLock() ) .AND. ;
                  ANAL->( FLock() ) .AND.  ;
                  SINT->( FLock() ) .AND.  ;
                  NALOG->( FLock() )  )

               Beep( 4 )
               BoxC()
               Msg( "Timeout za azuriranje istekao!#Ne mogu azuriranti nalog..." )
               closeret

            ENDIF
         ENDIF


         @ m_x + 3, m_y + 2 SAY "NALOZI         "
         SELECT  SUBAN; SET ORDER TO 4  // "4","idFirma+IdVN+BrNal+Rbr"
         SEEK cNal
         IF Found()
            BoxC()
            Msg( "Vec postoji u suban ? " + IdFirma + "-" + IdVn + "-" + AllTrim( BrNal ) + "  !" )
            closeret
         ENDIF


         SELECT  NALOG
         SEEK cNal
         IF Found()
            BoxC()
            Msg( "Vec postoji proknjizen nalog " + IdFirma + "-" + IdVn + "-" + AllTrim( BrNal ) + "  !" )
            closeret
         ENDIF // found()

         SELECT PNALOG
         SEEK cNal
         IF Found()
            Scatter()
            _Sifra := sifrakorisn
            SELECT NALOG
            APPEND ncnl
            sql_append()
            Gather2()
            GathSql()
            sql_azur( .F. )
         ELSE
            Beep( 4 )
            Msg( "Greska... ponovi stampu naloga ..." )
         ENDIF

         @ m_x + 3, m_y + 2 SAY "ANALITIKA       "
         SELECT PANAL
         SEEK cNal
         DO WHILE !Eof() .AND. cNal == IdFirma + IdVn + BrNal
            Scatter()
            SELECT ANAL
            APPEND ncnl
            sql_append()
            Gather2()
            GathSql()
            SELECT PANAL
            SKIP
         ENDDO

         @ m_x + 3, m_y + 2 SAY "SINTETIKA       "
         SELECT PSINT
         SEEK cNal
         DO WHILE !Eof() .AND. cNal == IdFirma + IdVn + BrNal
            Scatter()
            SELECT SINT
            APPEND ncnl
            sql_append()
            Gather2()
            GathSql()
            SELECT PSINT
            SKIP
         ENDDO

         @ m_x + 3, m_y + 2 SAY "SUBANALITIKA   "
         SELECT SUBAN
         SET ORDER TO TAG "3"
         SELECT PSUBAN
         SEEK cNal
         nC := 0
         DO WHILE !Eof() .AND. cNal == IdFirma + IdVn + BrNal

            @ m_x + 3, m_y + 25 SAY ++nC  PICT "99999999999"

            Scatter()
            IF _d_p == "1"; nSaldo := _IznosBHD; else; nSaldo := -_IznosBHD; ENDIF
            SELECT SUBAN
            SEEK _IdFirma + _IdKonto + _IdPartner + _BrDok    // isti dokument
            nRec := RecNo()
            DO WHILE  !Eof() .AND. ( _IdFirma + _IdKonto + _IdPartner + _BrDok ) == ( IdFirma + IdKonto + IdPartner + BrDok )
               IF d_P == "1"; nSaldo += IznosBHD; else; nSaldo -= IznosBHD; ENDIF
               SKIP
            ENDDO

            IF Abs( Round( nSaldo, 3 ) ) <= gnLOSt
               GO nRec
               DO WHILE  !Eof() .AND. ( _IdFirma + _IdKonto + _IdPartner + _BrDok ) == ( IdFirma + IdKonto + IdPartner + BrDok )
                  field->OtvSt := "9"
                  SKIP
               ENDDO
               _OtvSt := "9"
            ENDIF

            // dodaj u suban
            APPEND ncnl
            sql_append()
            Gather2()
            GathSql()

            SELECT PSUBAN
            SKIP
         ENDDO

         IF lLogAzur

            cOpis := cEvIdFirma + "-" + cEvVrBrNal

            EventLog( nUser, goModul:oDataBase:cName, "DOK", "AZUR", ;
               nSaldo, nil, nil, nil, ;
               cOpis, "", "", dDatNaloga, dDatValute, ;
               "", "Azuriranje dokumenta - zavrsio !!!" )

         ENDIF


         // nalog je uravnotezen, moze se izbrisati iz PRIPR

         SELECT PRIPR
         SEEK cNal
         @ m_x + 3, m_y + 2 SAY "BRISEM PRIPREMU "
         DO WHILE !Eof() .AND. cNal == IdFirma + IdVn + BrNal
            SKIP
            ntRec := RecNo()
            SKIP -1
            dbdelete2()
            GO ntRec
         ENDDO

      ENDIF // saldo == 0

      SELECT PSUBAN
   ENDDO

   BoxC()


   SELECT PRIPR
   __dbPack()

   SELECT PSUBAN
   ZAP
   SELECT PANAL
   ZAP
   SELECT PSINT
   ZAP
   SELECT PNALOG
   ZAP

   closeret

   RETURN




/*  Dupli(cIdFirma,cIdVn,cBrNal)
 *   Provjera duplog naloga
 *   cIdFirma
 *   cIdVn
 *   cBrNal
 */

FUNCTION Dupli( cIdFirma, cIdVn, cBrNal )

   PushWa()

   SELECT NALOG
   SET ORDER TO 1
   SEEK cIdFirma + cIdVN + cBrNal

   IF Found()
      MsgO( " Dupli nalog ! " )
      Beep( 3 )
      MsgC()
      PopWa()
      RETURN .F.
   ENDIF

   PopWa()

   RETURN .T.


// --------------------------------
// validacija broja naloga
// --------------------------------
STATIC FUNCTION __val_nalog( cNalog )

   LOCAL lRet := .T.
   LOCAL cTmp
   LOCAL cChar
   LOCAL i

   cTmp := Right( cNalog, 4 )

   // vidi jesu li sve brojevi
   FOR i := 1 TO Len( cTmp )

      cChar := SubStr( cTmp, i, 1 )

      IF cChar $ "0123456789"
         LOOP
      ELSE
         lRet := .F.
         EXIT
      ENDIF

   NEXT

   RETURN lRet




FUNCTION sljedeci_fin_nalog( cIdFirma, cIdVN )

   LOCAL nArr

   nArr := Select()

   IF gBrojac == "1"

      SELECT NALOG
      SET ORDER TO 1
      SEEK cIdFirma + cIdVN + Chr( 254 )
      SKIP -1
      IF ( idfirma + idvn == cIdFirma + cIdVN )

         // napravi validaciju polja ...
         DO WHILE !Bof()

            IF !__val_nalog( field->brnal )
               SKIP -1
               LOOP
            ELSE
               EXIT
            ENDIF
         ENDDO

         cBrNal := NovaSifra( brNal )
      ELSE
         cBrNal := "00000001"
      ENDIF

   ELSE
      SELECT NALOG
      SET ORDER TO 2
      SEEK cIdFirma + Chr( 254 )
      SKIP -1
      cBrNal := PadL( AllTrim( Str( Val( brnal ) + 1 ) ), 8, "0" )
   ENDIF

   SELECT ( nArr )

   RETURN cBrNal


// ----------------------------------------------------------------
// specijalna funkcija regeneracije brojeva naloga u kum tabelama
// C(4) -> C(8) konverzija
// stari broj A001 -> 0000A001
// ----------------------------------------------------------------
FUNCTION regen_tbl()

   IF !sifra_za_koristenje_opcije( "REGEN" )
      MsgBeep( "Ne diraj lava dok spava !" )
      RETURN
   ENDIF

   // otvori sve potrebne tabele
   O_SUBAN

   IF Len( suban->brnal ) = 4
      msgbeep( "potrebno odraditi modifikaciju FIN.CHS prvo !" )
      RETURN
   ENDIF

   O_NALOG
   O_ANAL
   O_SINT

   // pa idemo redom
   SELECT suban
   _renum_convert()
   SELECT nalog
   _renum_convert()
   SELECT anal
   _renum_convert()
   SELECT sint
   _renum_convert()

   RETURN


// --------------------------------------------------
// konvertuje polje BRNAL na zadatoj tabeli
// --------------------------------------------------
STATIC FUNCTION _renum_convert()

   LOCAL xValue
   LOCAL nCnt

   SET ORDER TO TAG "0"
   GO TOP

   Box(, 2, 50 )

   @ m_x + 1, m_y + 2 SAY "Konvertovanje u toku... "

   nCnt := 0
   DO WHILE !Eof()
      xValue := field->brnal
      IF !Empty( xValue )
         REPLACE field->brnal WITH PadL( AllTrim( xValue ), 8, "0" )
         ++ nCnt
      ENDIF
      @ m_x + 2, m_y + 2 SAY PadR( "odradjeno " + AllTrim( Str( nCnt ) ), 45 )
      SKIP
   ENDDO

   BoxC()

   RETURN



// -----------------------------------------
// provjera podataka za migraciju f18
// -----------------------------------------
FUNCTION fin_f18_test_data()

   LOCAL _a_sif := {}
   LOCAL _a_data := {}
   LOCAL _a_ctrl := {}
   LOCAL _chk_sif := .F.

   IF Pitanje(, "Provjera sifrarnika (D/N) ?", "N" ) == "D"
      _chk_sif := .T.
   ENDIF

   // provjeri sifrarnik
   IF _chk_sif == .T.
      f18_sif_data( @_a_sif, @_a_ctrl )
   ENDIF

   f18_fin_data( @_a_data, @_a_ctrl )

   // prikazi rezultat testa
   f18_rezultat( _a_ctrl, _a_data, _a_sif )

   RETURN



// -----------------------------------------
// provjera suban, anal, sint
// -----------------------------------------
STATIC FUNCTION f18_fin_data( data, checksum )

   LOCAL _n_c_iznos := 0
   LOCAL _n_c_stavke := 0
   LOCAL _scan

   O_SUBAN
   O_ANAL
   O_SINT

   Box(, 2, 60 )

   SELECT suban
   SET ORDER TO TAG "4"
   GO TOP

   DO WHILE !Eof()

      _firma := field->idfirma
      _tdok := field->idvn
      _brdok := field->brnal
      _dok := _firma + "-" + _tdok + "-" + AllTrim( _brdok )

      _rbr_chk := "xx"

      @ m_x + 1, m_y + 2 SAY "dokument: " + _dok

      DO WHILE !Eof() .AND. field->idfirma == _firma ;
            .AND. field->idvn == _tdok ;
            .AND. field->brnal == _brdok

         _rbr := field->rbr

         @ m_x + 2, m_y + 2 SAY "redni broj dokumenta: " + PadL( _rbr, 5 )

         IF _rbr == _rbr_chk
            // dodaj u matricu...
            _scan := AScan( data, {| var| VAR[ 1 ] == _dok } )
            IF _scan == 0
               AAdd( data, { _dok } )
            ENDIF
         ENDIF

         _rbr_chk := _rbr

         // kontrolni broj
         ++ _n_c_stavke
         _n_c_iznos += ( field->iznosbhd )

         SKIP
      ENDDO

   ENDDO

   BoxC()

   IF _n_c_stavke > 0
      AAdd( checksum, { "fin data", _n_c_stavke, _n_c_iznos } )
   ENDIF

   RETURN
