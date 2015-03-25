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


STATIC s_cTranzitKontoId := NIL

#include "kalk01.ch"

FUNCTION magacin_tranzit_konto_id()

   IF s_cTranzitniKontoId == NIL
	    s_cTranzitniKontoId := IzFmkIni( "KALK", "Tranzit", "1322" )
	 ENDIF

	 RETURN PADR( s_cTranzitniKontoId, 7 )


FUNCTION cre_cache()

   LOCAL aFld := {}
   LOCAL cTbl := PRIVPATH + SLASH + "CACHE.DBF"

   AAdd( aFld, { "idkonto", "C", 7, 0 } )
   AAdd( aFld, { "idroba", "C", 10, 0 } )
   AAdd( aFld, { "ulaz", "N", 18, 8 } )
   AAdd( aFld, { "izlaz", "N", 18, 8 } )
   AAdd( aFld, { "stanje", "N", 18, 8 } )
   AAdd( aFld, { "nvu", "N", 18, 8 } )
   AAdd( aFld, { "nvi", "N", 18, 8 } )
   AAdd( aFld, { "nv", "N", 18, 8 } )
   AAdd( aFld, { "z_nv", "N", 18, 8 } )
   AAdd( aFld, { "odst", "N", 18, 8 } )

   IF !if_cache()
      DBCreate2( cTbl, aFld )
      f01_create_index( "1", "idkonto+idroba", cTbl )
   ENDIF

   RETURN


// -------------------------------
// ima li cache tabele
// -------------------------------
FUNCTION if_cache()

   LOCAL lRet := .F.

   IF File2( PRIVPATH + SLASH + "CACHE.DBF" )
      lRet := .T.
   ENDIF

   RETURN lRet



FUNCTION f01_kalk_nab_cijene_iz_cache( cC_Kto, cC_Roba, nC_Ulaz, nC_Izlaz, nC_Stanje, nC_NVU, nC_NVI, nC_NV )

   LOCAL nTArea := Select()
   LOCAL nZC_nv := 0

   IF !if_cache() .OR. gCache == "N"
      RETURN 0
   ENDIF

   cC_Kto := PadR( cC_Kto, 7 )
   cC_Roba := PadR( cC_Roba, 10 )

	 IF cC_Kto == magacin_tranzit_konto_id()
	    // tranzitni konto se takodje ne uzima iz keša, nego direktnim proračunom
	    RETURN 0
	 ENDIF

   IF cC_Kto == PADR("", 7)
   nC_ulaz := 0
   nC_izlaz := 0
   nC_stanje := 0
   nC_nvu := 0
   nC_nvi := 0
   nC_nv := 0

   O_CACHE
   SELECT cache
   SET ORDER TO TAG "1"
   GO TOP

   SEEK cC_Kto + cC_Roba

   IF Found() .AND. ( cC_kto == field->idkonto .AND. cC_roba == field->idroba )
      nC_Ulaz := field->ulaz
      nC_Izlaz := field->izlaz
      nC_Stanje := field->stanje
      nC_NVU := field->nvu
      nC_NVI := field->nvi
      nC_Nv := field->nv
      nZC_nv := field->z_nv
   ENDIF

   // ako se koristi kontrola NC
   IF gNC_ctrl > 0 .AND. nC_nv <> 0 .AND. nZC_nv <> 0

      nTmp := Round( nC_nv, 4 ) - Round( nZC_nv, 4 )
      nOdst := ( nTmp / Round( nZC_nv, 4 ) ) * 100

      IF Abs( nOdst ) > gNC_ctrl

         Beep( 4 )
         CLEAR TYPEAHEAD

         msgbeep( "Odstupanje u odnosu na zadnji ulaz je#" + ;
            AllTrim( Str( Abs( nOdst ) ) ) + " %" + "#" + ;
            "artikal: " + AllTrim( cC_roba ) + " " + ;
            PadR( roba->naz, 15 ) + " nc:" + ;
            AllTrim( Str( nC_nv, 12, 2 ) ) )

         // a_nc_ctrl( @aNC_ctrl, field->idroba, field->stanje, ;
         // field->nv, field->z_nv )

         IF Pitanje(, "Napraviti korekciju NC (D/N)?", "N" ) == "D"

            nTmp_n_stanje := ( nC_stanje - _kolicina )
            nTmp_n_nv := ( nTmp_n_stanje * nZC_nv )
            nTmp_s_nv := ( nC_stanje * nC_nv )

            nC_nv := ( ( nTmp_s_nv - nTmp_n_nv ) / _kolicina )

         ENDIF

         IF Pitanje(, "Upisati u CACHE novu NC (D/N)?", "D" ) == "D"

            REPLACE field->nv WITH field->z_nv
            REPLACE field->odst WITH 0

         ENDIF

      ENDIF
   ENDIF

   SELECT ( nTArea )

   RETURN 1


// ------------------------------------------------------------
// lista konta
// ------------------------------------------------------------
STATIC FUNCTION _g_kto( cMList, cPList, dDatGen, cAppendSif, ;
      nT_kol, nT_ncproc )

   LOCAL GetList := {}
   LOCAL nTArea := Select()

   O_PARAMS
   PRIVATE cSection := "Q"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}

   cMList := PadR( "1310;13101;", 250 )
   cPList := PadR( "1320;", 250 )
   dDatGen := Date()
   cAppendSif := "D"
   nT_kol := 100.00
   nT_ncproc := 17.00

   RPar( "mk", @cMList )
   RPar( "pk", @cPList )
   RPar( "as", @cAppendSif )
   RPar( "np", @nT_ncproc )
   RPar( "nk", @nT_kol )

   cMList := PadR( cMList, 250 )
   cPList := PadR( cPList, 250 )

   Box(, 6, 60 )

   @ m_x + 1, m_y + 2 SAY "Mag. konta:" GET cMList PICT "@S40"
   @ m_x + 2, m_y + 2 SAY "Pro. konta:" GET cPList PICT "@S40"
   @ m_x + 3, m_y + 2 SAY "Datum do:" GET dDatGen
   @ m_x + 4, m_y + 2 SAY "Dodaj nepost.stavke iz sifrarnika (D/N):" GET cAppendSif

   READ

   IF cAppendSif == "D"

      @ m_x + 5, m_y + 2 SAY " -         default stanje:" ;
         GET nT_kol VALID nT_kol > 0 PICT "999999.99"
      @ m_x + 6, m_y + 2 SAY " - default procenat za nc:" ;
         GET nT_ncproc PICT "9999999.99"

      READ
   ENDIF
   BoxC()

   IF LastKey() == K_ESC
      SELECT ( nTArea )
      RETURN 0
   ENDIF

   WPar( "mk", cMList )
   WPar( "pk", cPList )
   WPar( "dg", dDatGen )
   WPar( "as", cAppendSif )
   WPar( "np", nT_ncproc )
   WPar( "nk", nT_kol )

   SELECT ( nTArea )

   RETURN 1



// --------------------------------------------------
// generisi cache tabelu
// --------------------------------------------------
FUNCTION gen_cache()

   LOCAL nIzlNV
   LOCAL nIzlKol
   LOCAL nUlNV
   LOCAL nUlKol
   LOCAL nKolNeto
   LOCAL cIdKonto
   LOCAL cIdFirma := gFirma
   LOCAL cIdRoba
   LOCAL cMKtoLst
   LOCAL cPKtoLst
   LOCAL dDatGen
   LOCAL cAppFSif
   LOCAL nT_kol
   LOCAL nT_ncproc
   LOCAL GetList := {}
   LOCAL i

   // posljednje pozitivno stanje
   LOCAL nKol_poz := 0
   LOCAL nUVr_poz, nIVr_poz
   LOCAL nUKol_poz, nIKol_poz
   LOCAL nZadnjaNC := 0
   LOCAL nOdstup := 0
   LOCAL _dok_korek := .F.

   IF _g_kto( @cMKtoLst, @cPKtoLst, @dDatGen, @cAppFSif, ;
         @nT_kol, @nT_ncproc ) == 0
      RETURN
   ENDIF

   cre_cache()

   O_CACHE
   SELECT cache
   ZAP
   __dbPack()

   O_CACHE
   O_DOKS
   O_KALK


   Box(, 1, 70 )

   aKto := TOKTONIZ( cMKtoLst, ";" )

   FOR i := 1 TO Len( aKto )

      cIdKonto := PadR( aKto[ i ], 7 )

      IF Empty( cIdKonto )
         LOOP
      ENDIF

      @ m_x + 1, m_y + 2 SAY "mag. konto: " + cIdKonto

      SELECT kalk
      // mkonto
      SET ORDER TO TAG "3"
      GO TOP

      SEEK cIdFirma + cIdKonto

      DO WHILE !Eof() .AND. cIdFirma == field->idfirma ;
            .AND. cIdKonto == field->mkonto


         cIdRoba := field->idroba

         nKolicina := 0
         nIzlNV := 0
         // ukupna izlazna nabavna vrijednost
         nUlNV := 0
         nIzlKol := 0
         // ukupna izlazna kolicina
         nUlKol := 0
         // ulazna kolicina

         nKol_poz := 0
         nZadnjaNC := 0
         nOdstup := 0

         @ m_x + 1, m_y + 20 SAY cIdRoba

         DO WHILE !Eof() .AND. ( ( cIdFirma + cIdKonto + cIdRoba ) == ( idFirma + mkonto + idroba ) )

            // provjeri datum
            IF field->datdok > dDatGen
               SKIP
               LOOP
            ENDIF

            SELECT doks
            SET ORDER TO TAG "1"
            GO TOP
            SEEK kalk->idfirma + kalk->idvd + kalk->brdok
            SELECT kalk

            IF Left( doks->brfaktp, 6 ) == "#KOREK"
               _dok_korek := .T.
            ELSE
               _dok_korek := .F.
            ENDIF

            IF field->mu_i == "1" .OR. field->mu_i == "5"

               IF idvd == "10"
                  nKolNeto := Abs( kolicina - gkolicina - gkolicin2 )
               ELSE
                  nKolNeto := Abs( kolicina )
               ENDIF

               IF ( field->mu_i == "1" .AND. field->kolicina > 0 ) .OR. ;
                     ( field->mu_i == "5" .AND. field->kolicina < 0 )

                  nKolicina += nKolNeto

                  nUlKol += nKolNeto
                  nUlNV += ( nKolNeto * field->nc )

                  // zadnja nabavna cijena ulaza
                  IF idvd $ "10#16#96" .AND. !_dok_korek
                     nZadnjaNC := field->nc
                  ENDIF

               ELSE

                  nKolicina -= nKolNeto

                  nIzlKol += nKolNeto
                  nIzlNV += ( nKolNeto * field->nc )

                  IF idvd == "16" .AND. _dok_korek
                     nZadnjaNC := field->nc
                  ENDIF

               ENDIF

               // ako je stanje pozitivno zapamti ga
               IF Round( nKolicina, 8 ) > 0

                  nKol_poz := nKolicina

                  nUKol_poz := nUlKol
                  nIKol_poz := nIzlKol

                  nUVr_poz := nUlNv
                  nIVr_poz := nIzlNv

               ENDIF

            ENDIF

            SKIP

         ENDDO

         // utvrdi srednju nabavnu cijenu na osnovu posljednjeg pozitivnog stanja
         IF Round( nKol_poz, 8 ) == 0
            nSNc := 0
         ELSE
            // srednja nabavna cijena
            nSNc := ( nUVr_poz - nIVr_poz ) / nKol_poz
         ENDIF

         nKolicina := Round( nKolicina, 4 )

         IF Round( nKol_poz, 8 ) <> 0

            // upisi u cache
            SELECT cache
            APPEND BLANK

            REPLACE idkonto WITH cIdKonto
            REPLACE idroba WITH cIdRoba
            REPLACE ulaz WITH nUKol_poz + nT_kol
            REPLACE izlaz WITH nIKol_poz
            REPLACE stanje WITH nKol_poz + nT_kol
            REPLACE nvu WITH nUVr_poz
            REPLACE nvi WITH nIVr_poz
            REPLACE nv WITH nSnc
            REPLACE z_nv WITH nZadnjaNC

            IF nSNC <> 0 .AND. nZadnjaNC <> 0

               nTmp := ( Round( nSNC, 4 ) - Round( nZadnjaNC, 4 ) )
               nOdst := ( nTmp / Round( nZadnjaNC, 4 ) ) * 100

               REPLACE odst WITH Round( nOdst, 2 )
            ELSE
               REPLACE odst WITH 0
            ENDIF

         ENDIF

         SELECT kalk

      ENDDO

   NEXT

   i := 1

   // a sada prodavnice

   aKto := TOKTONIZ( cPKtoLst, ";" )

   FOR i := 1 TO Len( aKto )

      cIdKonto := PadR( aKto[ i ], 7 )

      IF Empty( cIdKonto )
         LOOP
      ENDIF

      @ m_x + 1, m_y + 2 SAY "prod.konto: " + cIdKonto

      SELECT kalk
      // pkonto
      SET ORDER TO TAG "4"
      GO TOP

      SEEK cIdFirma + cIdKonto

      DO WHILE !Eof() .AND. cIdFirma == field->idfirma ;
            .AND. cIdKonto == field->pkonto


         cIdRoba := field->idroba

         nKolicina := 0
         nIzlNV := 0
         // ukupna izlazna nabavna vrijednost
         nUlNV := 0
         nIzlKol := 0
         // ukupna izlazna kolicina
         nUlKol := 0
         // ulazna kolicina

         @ m_x + 1, m_y + 20 SAY cIdRoba

         DO WHILE !Eof() .AND. cIdFirma + cIdKonto + cIdRoba == idFirma + pkonto + idroba

            // provjeri datum
            IF field->datdok > dDatGen
               SKIP
               LOOP
            ENDIF

            SELECT doks
            SET ORDER TO TAG "1"
            GO TOP
            SEEK kalk->idfirma + kalk->idvd + kalk->brdok
            SELECT kalk

            IF Left( doks->brfaktp, 6 ) == "#KOREK"
               _dok_korek := .T.
            ELSE
               _dok_korek := .F.
            ENDIF

            IF field->pu_i == "1" .OR. field->pu_i == "5"

               IF ( field->pu_i == "1" .AND. field->kolicina > 0 ) ;
                     .OR. ( field->pu_i == "5" .AND. field->kolicina < 0 )

                  nKolicina += Abs( field->kolicina )
                  nUlKol    += Abs( field->kolicina )
                  nUlNV     += ( Abs( field->kolicina ) * field->nc )

               ELSE

                  nKolicina -= Abs( field->kolicina )
                  nIzlKol   += Abs( field->kolicina )
                  nIzlNV    += ( Abs( field->kolicina ) * field->nc )

               ENDIF

            ELSEIF field->pu_i == "I"
               nKolicina -= field->gkolicin2
               nIzlKol += field->gkolicin2
               nIzlNV += field->nc * field->gkolicin2
            ENDIF
            SKIP

         ENDDO

         IF Round( nKolicina, 5 ) == 0
            nSNC := 0
         ELSE
            nSNC := ( nUlNV - nIzlNV ) / nKolicina
         ENDIF

         nKolicina := Round( nKolicina, 4 )

         IF nKolicina <> 0

            // upisi u cache
            SELECT cache
            APPEND BLANK

            REPLACE idkonto WITH cIdKonto
            REPLACE idroba WITH cIdRoba
            REPLACE ulaz WITH nUlKol + nT_kol
            REPLACE izlaz WITH nIzlkol
            REPLACE stanje WITH nKolicina + nT_kol
            REPLACE nvu WITH nUlNv
            REPLACE nvi WITH nIzlNv
            REPLACE nv WITH nSnc
            REPLACE z_nv WITH 0

         ENDIF

         SELECT kalk

      ENDDO

   NEXT

   BoxC()

   IF cAppFSif == "D"
      // dodaj stavke iz sifrarnika robe koje ne postoje
      _app_from_sif( cMKtoLst, cPKtoLst, nT_kol, nT_ncproc )
   ENDIF

   RETURN


// ---------------------------------------------------------------
// dodaj u cache tabelu stavke iz sifrarnika koje ne postoje
// u cache
// ---------------------------------------------------------------
STATIC FUNCTION _app_from_sif( cM_list, cP_list, nT_kol, nT_ncproc )

   LOCAL nTArea := Select()
   LOCAL aKto := {}
   LOCAL i

   PRIVATE GetList := {}

   IF nT_kol = NIL .OR. nT_kol <= 0
      msgbeep( "Default kolicina setovana na 0. Kako je to moguce :)" )
      RETURN
   ENDIF

   IF nT_ncproc = NIL .OR. nT_ncproc <= 0
      msgbeep( "Default procenat nc setovan na <= 0. Kako je to moguce :)" )
      RETURN
   ENDIF

   Box(, 3, 60 )

   IF !Empty( cM_list )
      // odradi magacine...
      aKto := TOKTONIZ( cM_list, ";" )
      i := 1

      FOR i := 1 TO Len( aKto )
         // magacin je aKto[i]
         @ m_x + 1, m_y + 2 SAY PadR( "radim magacin: " + aKto[ i ], 60 )
         _app_for_kto( aKto[ i ], nT_kol, nT_ncproc )
      NEXT
   ENDIF

   IF !Empty( cP_list )
      // odradi prodavnice...
      aKto := TOKTONIZ( cP_list, ";" )
      i := 1

      FOR i := 1 TO Len( aKto )
         // magacin je aKto[i]
         @ m_x + 1, m_y + 2 SAY PadR( "radim prodavnicu: " + aKto[ i ], 60 )
         _app_for_kto( aKto[ i ], nT_kol, nT_ncproc )
      NEXT
   ENDIF

   BoxC()

   SELECT ( nTArea )

   RETURN


// ------------------------------------------------
// dodaj u cache tabelu robu za konto
// ------------------------------------------------
STATIC FUNCTION _app_for_kto( cKto, nKol, nNcProc, lSilent )

   LOCAL cRoba
   LOCAL cRobaNaz
   LOCAL nVPC

   IF Empty( cKto )
      RETURN
   ENDIF

   cKto := PadR( cKto, 7 )

   IF nKol = nil
      nKol := 100
   ENDIF

   IF nNcProc = nil
      nNcProc := 17.00
   ENDIF

   IF lSilent == nil
      lSilent := .F.
   ENDIF

   O_ROBA
   GO TOP

   DO WHILE !Eof()

      // ako nema sifre dobavljaca, preskoci...
      IF Empty( field->sifradob ) .OR. field->vpc = 0
         SKIP
         LOOP
      ENDIF

      cRoba := field->id
      cRobaNaz := field->naz
      nVPC := field->vpc

      // provjeri ima li u cache tabeli
      SELECT cache
      SET ORDER TO TAG "1"
      GO TOP
      SEEK cKto + cRoba

      IF !Found()

         // nisam nasao upisi u cache

         IF !lSilent
            @ m_x + 2, m_y + 2 SAY "roba: " + PadR( cRoba, 10 ) ;
               + "-" + PadR( cRobaNaz, 40 )
         ENDIF

         APPEND BLANK
         REPLACE idkonto WITH cKto
         REPLACE idroba WITH cRoba
         REPLACE ulaz WITH nKol
         REPLACE izlaz WITH 0
         REPLACE stanje WITH nKol
         REPLACE nv WITH nVPC / ( ( nNcProc / 100 ) + 1 )
         REPLACE nvu WITH nv * nKol
         REPLACE nvi WITH 0
         REPLACE z_nv WITH nv
         REPLACE odst WITH 0

      ENDIF

      SELECT roba
      SKIP
   ENDDO

   RETURN


// -------------------------------------------------------
// konvertuje numericko polje u karakterno za prikaz
// -------------------------------------------------------
STATIC FUNCTION s_num( nNum )

   LOCAL cNum := Str( nNum, 12, 2 )

   RETURN cNum


// ----------------------------------------
// browsanje tabele cache
// ----------------------------------------
FUNCTION brow_cache()

   PRIVATE ImeKol
   PRIVATE Kol

   O_CACHE
   SET ORDER TO TAG "1"

   ImeKol := { { PadR( "Konto", 15 ), {|| PadR( AllTrim( IdKonto ) + ;
      "-" + AllTrim( IDROBA ), 13 ) }, "IdKonto" },;
      { PadR( "Stanje", 10 ), {|| s_num( Stanje ) }, "Stanje" },;
      { PadR( "NC", 10 ), {|| s_num( NV ) }, "Nab.cijena" }, ;
      { PadR( "Z_NC", 10 ), {|| s_num( Z_NV ) }, "Zadnja NC" }, ;
      { PadR( "odst", 10 ), {|| s_num( ODST ) }, "Odstupanje" } }

   Kol := {}

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   Box(, 20, 77 )
   @ m_x + 17, m_y + 2 SAY "<c+N> novi zapis   <F2>  ispravka  <c+T> brisi stavku"
   @ m_x + 18, m_y + 2 SAY "<F>   filter odstupanja"
   @ m_x + 19, m_y + 2 SAY " "
   @ m_x + 20, m_y + 2 SAY " "

   f01_db_edit( "CACHE", 20, 77, {|| key_handler() }, "", "pregled cache tabele", , , , , 4 )

   BoxC()

   RETURN


// ---------------------------------------
// handler key event
// ---------------------------------------
STATIC FUNCTION key_handler()

   LOCAL nOdst := 0
   LOCAL cT_filter := dbFilter()

   DO CASE
   CASE ch == K_F2
      IF edit_item() == 1

         IF !Empty( cT_filter )
            SET FILTER to &cT_filter
            GO TOP
         ENDIF

         RETURN DE_REFRESH
      ELSE
         RETURN DE_CONT
      ENDIF

   CASE ch == K_CTRL_N

      // dodaj novu stavku u tabelu
      IF edit_item( .T. ) == 1

         IF !Empty( cT_filter )
            SET FILTER to &cT_filter
            GO TOP
         ENDIF

         RETURN DE_REFRESH
      ELSE
         RETURN DE_CONT
      ENDIF

   CASE ch == K_CTRL_T

      // brisi stavku iz tabele
      IF Pitanje(, "Brisati stavku ?", "N" ) == "D"
         DELETE
         RETURN DE_REFRESH
      ENDIF

   CASE Upper( Chr( ch ) ) == "F"

      cSign := ">="

      // filter
      Box(, 1, 22 )
      @ m_x + 1, m_y + 2 SAY "Odstupanje" GET cSign ;
         PICT "@S2"
      @ m_x + 1, Col() + 1 GET nOdst ;
         PICT "9999.99"
      READ
      BoxC()

      IF nOdst <> 0

         PRIVATE cFilter := "odst " + AllTrim( cSign ) ;
            + CM2STR( nOdst )
         SET FILTER to &cFilter
         GO TOP

         cT_filter := dbFilter()

         RETURN DE_REFRESH
      ENDIF

   ENDCASE

   RETURN DE_CONT


// -------------------------------------
// korekcija stavke
// -------------------------------------
STATIC FUNCTION edit_item( lNew )

   LOCAL GetList := {}
   LOCAL nTmp
   LOCAL nOdst
   LOCAL nL_nv
   LOCAL nL_znv

   IF lNew == nil
      lNew := .F.
   ENDIF

   Scatter()

   // uzmi ovo radi daljnjeg analiziranja - postojece stanje
   nL_nv := _nv
   nL_znv := _z_nv

   IF lNew

      // resetuj varijable
      _idroba := Space( Len( _idroba ) )
      _ulaz := 0
      _izlaz := 0
      _stanje := 0
      _nvu := 0
      _nvi := 0
      _nv := 0
      _z_nv := 0

      APPEND BLANK
   ENDIF

   Box(, 5, 60 )

   IF lNew

      @ m_x + 1, m_y + 2 SAY "Id konto:" GET _idkonto
      @ m_x + 1, Col() + 2 SAY "Id roba:" GET _idroba

      @ m_x + 2, m_y + 2 SAY "ulaz:" GET _ulaz
      @ m_x + 2, Col() + 1 SAY "izlaz:" GET _izlaz
      @ m_x + 2, Col() + 1 SAY "stanje:" GET _stanje

      @ m_x + 3, m_y + 2 SAY "NV ulaz:" GET _nvu
      @ m_x + 3, Col() + 1 SAY "NV izlaz:" GET _nvi

   ENDIF

   @ m_x + 4, m_y + 2 SAY "Srednja NC:" GET _nv
   @ m_x + 4, Col() + 2 SAY " Zadnja NC:" GET _z_nv

   IF lNew
      @ m_x + 5, m_y + 2 SAY "odstupanje:" GET _odst
   ENDIF

   READ
   BoxC()

   IF LastKey() == K_ESC
      RETURN 0
   ENDIF

   Gather()

   // izadji ako je dodavanje novog zapisa...
   IF lNew
      RETURN 1
   ENDIF

   // kalkulisi odstupanje automatski ako su cijene promjenjene

   IF ( nL_nv <> field->nv ) .OR. ( nL_znv <> field->z_nv )

      nTmp := Round( field->nv, 4 ) - Round( field->z_nv, 4 )
      nOdst := ( nTmp / Round( field->z_nv, 4 ) ) * 100

      REPLACE field->odst WITH Round( nOdst, 2 )

   ENDIF

   RETURN 1
