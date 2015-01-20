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


// -------------------------------------------
// kreiraj index FIN rules....
// -------------------------------------------
FUNCTION cre_rule_cdx()

   f01_create_index( "FINKNJ1", "MODUL_NAME+RULE_OBJ+STR(RULE_NO,5)", SIFPATH + "FMKRULES" )

   f01_create_index( "ELBA1", "MODUL_NAME+RULE_OBJ+RULE_C3", SIFPATH + "FMKRULES" )

   RETURN




// --------------------------------------------
// rule - kolone specificne
// --------------------------------------------
FUNCTION g_rule_cols()

   LOCAL aKols := {}

   // rule_c1 = 1
   // rule_c2 = 5
   // rule_c3 = 10
   // rule_c4 = 10
   // rule_c5 = 50
   // rule_c6 = 50
   // rule_c7 = 100

   AAdd( aKols, { "tip nal", {|| PadR( rule_c3, 10 ) }, "rule_c3", {|| .T. }, {|| .T. } } )
   AAdd( aKols, { "partner", {|| PadR( rule_c5, 20 ) }, "rule_c5", {|| .T. }, {|| .T. } } )
   AAdd( aKols, { "konto", {|| PadR( rule_c6, 20 ) }, "rule_c6", {|| .T. }, {|| .T. } } )
   AAdd( aKols, { "d_p", {|| rule_c1 }, "rule_c1", {|| .T. }, {|| .T. } } )

   RETURN aKols


// -------------------------------------
// rule - block tabele rule
// -------------------------------------
FUNCTION g_rule_block()

   LOCAL bBlock := {|| ed_rule_bl() }

   RETURN bBlock

// ------------------------------------
// edit rule key handler
// ------------------------------------
STATIC FUNCTION ed_rule_bl()
   RETURN DE_CONT



// ---------------------------------------
//
// .....RULES.....
//
// ---------------------------------------


STATIC FUNCTION err_validate( nLevel )

   LOCAL lRet := .F.

   IF nLevel <= 3

      lRet := .T.

   ELSEIF nLevel == 4

      IF Pitanje(, "Zanemariti ovo pravilo (D/N) ?", "N" ) == "D"

         lRet := .T.

      ENDIF

   ENDIF

   RETURN lRet




// -------------------------------------
// ispitivanje pravila o kontima
// -------------------------------------
FUNCTION _rule_kto_()

   LOCAL nErrLevel := 0

   // ako se koriste pravila ? uopste
   IF is_fmkrules()

      nErrLevel := _rule_kto1_()

   ENDIF

   RETURN err_validate( nErrLevel )



// -------------------------------------------
// dozvoljen konto na nalogu
// -------------------------------------------
FUNCTION _rule_kto1_()

   LOCAL nReturn := 0
   LOCAL nTArea := Select()

   LOCAL cObj := "KNJIZ_KONTO"
   LOCAL cMod := goModul:oDataBase:cName

   LOCAL nErrLevel
   LOCAL cKtoList
   LOCAL cNalog

   O_FMKRULES
   SELECT fmkrules
   SET ORDER TO TAG "FINKNJ1"
   GO TOP

   SEEK g_rulemod( cMod ) + g_ruleobj( cObj )

   DO WHILE !Eof() .AND. field->modul_name == g_rulemod( cMod ) ;
         .AND. field->rule_obj == g_ruleobj( cObj )

      // B4 ili B* ili *
      cNalog := AllTrim( fmkrules->rule_c3 )
      // 132 ili 132;1333;2311;....
      cKtoList := AllTrim( fmkrules->rule_c6 )
      // nivo pravila
      nErrLevel := fmkrules->rule_level

      // ima li konta ???
      IF nErrLevel <> 0 .AND. ;
            _nalog_cond( _idvn, cNalog ) .AND. ;
            _konto_cond( _idkonto, cKtoList )

         nReturn := nErrLevel

         sh_rule_err( fmkrules->rule_ermsg, nErrLevel )

         EXIT

      ENDIF


      SKIP

   ENDDO

   SELECT ( nTArea )

   RETURN nReturn



// ---------------------------------------------------
// da li vrsta naloga zadovoljava....
// ---------------------------------------------------
STATIC FUNCTION _nalog_cond( cFinNalog, cRuleNalog )

   LOCAL lRet := .F.

   IF cRuleNalog == "*"

      // odnosi se na sve naloge svi nalozi

      lRet := .T.

   ELSEIF Left( cRuleNalog, 1 ) <> "*" .AND. "*" $ cRuleNalog

      // odnosi se na pravilo "B*" recimo

      IF Left( cRuleNalog, 1 ) == Left( cFinNalog, 1 )
         lRet := .T.
      ENDIF

   ELSEIF cRuleNalog == cFinNalog

      // odnosi se na uslov "B4"

      lRet := .T.

   ENDIF

   RETURN lRet




// -------------------------------------
// ispitivanje pravila o partneru
// -------------------------------------
FUNCTION _rule_partn_()

   LOCAL nErrLevel := 0

   // ako se koriste pravila ? uopste
   IF is_fmkrules()

      nErrLevel := _rule_pt1_()

   ENDIF

   RETURN err_validate( nErrLevel )



// -------------------------------------------
// koji partner na kontu ???
// -------------------------------------------
FUNCTION _rule_pt1_()

   LOCAL nReturn := 0
   LOCAL nTArea := Select()

   LOCAL cObj := "KNJIZ_PARTNER_KONTO"
   LOCAL cMod := goModul:oDataBase:cName

   LOCAL nErrLevel
   LOCAL cKtoList
   LOCAL cNalog
   LOCAL cPartn

   O_FMKRULES
   SELECT fmkrules
   SET ORDER TO TAG "FINKNJ1"
   GO TOP

   SEEK g_rulemod( cMod ) + g_ruleobj( cObj )

   DO WHILE !Eof() .AND. field->modul_name == g_rulemod( cMod ) ;
         .AND. field->rule_obj == g_ruleobj( cObj )

      // B4 ili B* ili *
      cNalog := AllTrim( fmkrules->rule_c3 )

      // 132 ili 132;1333;2311;....
      cKtoList := AllTrim( fmkrules->rule_c6 )

      // SC_SV1 - sifra partnera
      cPartn := AllTrim( fmkrules->rule_c5 )

      // nivo pravila
      nErrLevel := fmkrules->rule_level

      // ima li konta ???
      IF nErrLevel <> 0 .AND. ;
            _nalog_cond( _idvn, cNalog ) .AND. ;
            _konto_cond( _idkonto, cKtoList ) .AND. ;
            _partn_cond( _idpartner, cPartn ) == .F.

         nReturn := nErrLevel

         sh_rule_err( fmkrules->rule_ermsg, nErrLevel )

         EXIT

      ENDIF


      SKIP

   ENDDO

   SELECT ( nTArea )

   RETURN nReturn



// -------------------------------------
// ispitivanje dugovne/potrazne strane
// -------------------------------------
FUNCTION _rule_d_p_()

   LOCAL nErrLevel := 0

   // ako se koriste pravila ? uopste
   IF is_fmkrules()

      nErrLevel := _rule_dp1_()

   ENDIF

   RETURN err_validate( nErrLevel )



// -------------------------------------------
// duguje / potrazuje / partner / konto ????
// -------------------------------------------
FUNCTION _rule_dp1_()

   LOCAL nReturn := 0
   LOCAL nTArea := Select()

   LOCAL cObj := "KNJIZ_DP_PARTNER_KONTO"
   LOCAL cMod := goModul:oDataBase:cName

   LOCAL nErrLevel
   LOCAL cKtoList
   LOCAL cDugPot
   LOCAL cPartn
   LOCAL cNalog

   O_FMKRULES
   SELECT fmkrules
   SET ORDER TO TAG "FINKNJ1"
   GO TOP

   SEEK g_rulemod( cMod ) + g_ruleobj( cObj )

   DO WHILE !Eof() .AND. field->modul_name == g_rulemod( cMod ) ;
         .AND. field->rule_obj == g_ruleobj( cObj )

      // B4 ili B* ili *
      cNalog := AllTrim( fmkrules->rule_c3 )

      // 132 ili 132;1333;2311;....
      cKtoList := AllTrim( fmkrules->rule_c6 )

      // SC_SV1 - sifra partnera
      cPartn := AllTrim( fmkrules->rule_c5 )

      // duguje ili potrazuje (1 ili 2)
      cDugPot := AllTrim( fmkrules->rule_c1 )

      // nivo pravila
      nErrLevel := fmkrules->rule_level

      // ima li konta ???
      IF nErrLevel <> 0 .AND. ;
            _nalog_cond( _idvn, cNalog ) .AND. ;
            _konto_cond( _idkonto, cKtoList ) .AND. ;
            ( _partn_cond( _idpartner, cPartn ) == .F. .OR. ;
            _dp_cond( _d_p, cDugPot ) == .F. )

         nReturn := nErrLevel

         sh_rule_err( fmkrules->rule_ermsg, nErrLevel )

         EXIT


      ENDIF

      SKIP

   ENDDO

   SELECT ( nTArea )

   RETURN nReturn



// ---------------------------------------------------
// da li kupac zadovoljava kriterij ????
// ---------------------------------------------------
STATIC FUNCTION _partn_cond( cNalPartn, cRulePartn, lEmpty )

   LOCAL lRet := .F.

   IF lEmpty == nil
      lEmpty := .F.
   ENDIF

   cNalPartn := AllTrim( cNalPartn )

   IF lEmpty == .T. .AND. Empty( cRulePartn )

      lRet := .T.

   ELSEIF cRulePartn == "*"

      // svi partneri
      lRet := .T.

   ELSEIF cRulePartn == "#KUPAC#"

      // provjeri da li je partner kupac?

      lRet := is_kupac( cNalPartn )

   ELSEIF cRulePartn == "#DOBAVLJAC#"

      // provjeri da li je partner dobavljac?

      lRet := is_dobavljac( cNalPartn )

   ELSEIF cRulePartn == "#BANKA#"

      // provjeri da li je partner banka?

      lRet := is_banka( cNalPartn )

   ELSEIF cRulePartn == "#RADNIK#"

      // provjeri da li je partner radnik?

      lRet := is_radnik( cNalPartn )

   ELSEIF cRulePartn == cNalPartn

      // odnosi se na uslov "01CZ02", konkretnu sifru

      lRet := .T.

   ENDIF

   RETURN lRet



// ---------------------------------------------------
// da li konto kriterij zadovoljava ????
// ---------------------------------------------------
STATIC FUNCTION _konto_cond( cNalKonto, cRuleKtoList, lEmpty )

   LOCAL lRet := .F.

   cNalKonto := AllTrim( cNalKonto )

   IF lEmpty == nil
      lEmpty := .F.
   ENDIF

   IF lEmpty == .T. .AND. Empty( cRuleKtoList )

      lRet := .T.

   ELSEIF cRuleKtoList == "*"

      // sva konta
      lRet := .T.

   ELSEIF cNalKonto $ cRuleKtoList

      lRet := .T.

   ENDIF

   RETURN lRet



// ---------------------------------------------------
// da li DP kriterij zadovoljava ????
// ---------------------------------------------------
STATIC FUNCTION _dp_cond( cNalDP, cRuleDP, lEmpty )

   LOCAL lRet := .F.

   cNalDP := AllTrim( cNalDP )

   IF lEmpty == nil
      lEmpty := .F.
   ENDIF

   IF lEmpty == .T. .AND. Empty( cRuleDP )

      lRet := .T.

   ELSEIF cNalDP == cRuleDP

      lRet := .T.

   ENDIF

   RETURN lRet


// -------------------------------------
// ispitivanje broja veze naloga
// -------------------------------------
FUNCTION _rule_veza_()

   LOCAL nErrLevel := 0

   // ako se koriste pravila ? uopste
   IF is_fmkrules()

      nErrLevel := _rule_bv1_()

   ENDIF

   RETURN err_validate( nErrLevel )



// -------------------------------------------
// broj veze pravilo 1 ????
// -------------------------------------------
FUNCTION _rule_bv1_()

   LOCAL nReturn := 0
   LOCAL nTArea := Select()

   LOCAL cObj := "KNJIZ_BROJ_VEZE"
   LOCAL cMod := goModul:oDataBase:cName

   LOCAL nErrLevel
   LOCAL cKtoList
   LOCAL cNalog
   LOCAL cPartn
   LOCAL cDugPot

   O_FMKRULES
   SELECT fmkrules
   SET ORDER TO TAG "FINKNJ1"
   GO TOP

   SEEK g_rulemod( cMod ) + g_ruleobj( cObj )

   DO WHILE !Eof() .AND. field->modul_name == g_rulemod( cMod ) ;
         .AND. field->rule_obj == g_ruleobj( cObj )

      // B4 ili B* ili *
      cNalog := AllTrim( fmkrules->rule_c3 )

      // 132 ili 132;1333;2311;....
      cKtoList := AllTrim( fmkrules->rule_c6 )

      // partner
      cPartn := AllTrim( fmkrules->rule_c5 )

      // duguje / potrazuje
      cDugPot := AllTrim( fmkrules->rule_c1 )

      // nivo pravila
      nErrLevel := fmkrules->rule_level

      // ima li konto/nalog/opis ???
      IF nErrLevel <> 0 .AND. ;
            _nalog_cond( _idvn, cNalog ) .AND. ;
            _konto_cond( _idkonto, cKtoList, .T. ) .AND. ;
            _partn_cond( _idpartner, cPartn, .T. ) .AND. ;
            _dp_cond( _d_p, cDugPot, .T. ) .AND. ;
            Empty( _brdok )

         nReturn := nErrLevel

         sh_rule_err( fmkrules->rule_ermsg, nErrLevel )

         EXIT


      ENDIF

      SKIP

   ENDDO

   SELECT ( nTArea )

   RETURN nReturn



// ----------------------------------------
// ELBA import rules
// ----------------------------------------

// vraca konto po uslovu rule_c3
FUNCTION r_get_konto( cCond, cPartner )

   LOCAL nTArea := Select()

   LOCAL cObj := "ELBA_IMPORT"
   LOCAL cMod := goModul:oDataBase:cName
   LOCAL cKonto := "XX"

   O_FMKRULES
   SELECT fmkrules
   SET ORDER TO TAG "ELBA1"
   GO TOP

   SEEK g_rulemod( cMod ) + g_ruleobj( cObj ) + g_rule_c3( cCond )

   IF cPartner == nil
      cPartner := ""
   ENDIF

   DO WHILE !Eof() .AND. field->modul_name == g_rulemod( cMod ) ;
         .AND. field->rule_obj == g_ruleobj( cObj ) ;
         .AND. field->rule_c3 == g_rule_c3( cCond )

      IF Empty( cPartner )

         IF Empty( field->rule_c5 )
            cKonto := PadR( field->rule_c6, 7 )
            EXIT
         ENDIF

      ELSE

         IF AllTrim( cPartner ) == AllTrim( field->rule_c5 )
            cKonto := PadR( field->rule_c6, 7 )
            EXIT
         ENDIF

      ENDIF

      SKIP
   ENDDO

   SELECT ( nTArea )

   RETURN cKonto



// vraca partnera po uslovu konta
FUNCTION r_get_kpartn( cKonto )

   LOCAL nTArea := Select()

   LOCAL cObj := "ELBA_IMPORT"
   LOCAL cMod := goModul:oDataBase:cName
   LOCAL cCond := "KTO_PARTN"
   LOCAL cPartn := ""

   O_FMKRULES
   SELECT fmkrules
   SET ORDER TO TAG "ELBA1"
   GO TOP

   SEEK g_rulemod( cMod ) + g_ruleobj( cObj ) + g_rule_c3( cCond )

   DO WHILE !Eof() .AND. field->modul_name == g_rulemod( cMod ) .AND. ;
         field->rule_obj == g_ruleobj( cObj ) .AND. ;
         field->rule_c3 == g_rule_c3( cCond )

      IF AllTrim( cKonto ) == AllTrim( field->rule_c6 )

         cPartn := PadR( field->rule_c5, 6 )

         EXIT

      ENDIF

      SKIP

   ENDDO

   SELECT ( nTArea )

   RETURN cPartn
