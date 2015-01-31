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
#include "hbclass.ch"


FUNCTION TFinModNew()

   LOCAL oObj

   oObj := TFinMod():new()

   oObj:self := oObj

   RETURN oObj

CREATE CLASS TFinMod INHERIT TAppMod

   VAR oSqlLog
   METHOD dummy
   METHOD setGVars
   METHOD mMenu
   METHOD mMenuStandard
   METHOD sRegg
   METHOD initdb
   METHOD srv

END CLASS

METHOD dummy()
   RETURN


METHOD TFinMod:initdb()

   ::oDatabase := TDBFinNew()

   RETURN NIL



METHOD TFinMod:mMenu()

   ::oSqlLog := TSqlLogNew()

   PID( "START" )
   IF gSql == "D"
      ::oSqlLog:open()
      ::oDatabase:scan()
   ENDIF

   CLOSE ALL

   SetKey( K_SH_F1, {|| Calc() } )

   CLOSE ALL

   @ 1, 2 SAY PadC( gTS + ": " + gNFirma, 50, "*" )
   @ 4, 5 SAY ""

   ::mMenuStandard()

   ::quit()

   RETURN NIL



METHOD TFinMod:mMenuStandard()

   PRIVATE Izbor := 1
   PRIVATE opc := {}
   PRIVATE opcexe := {}

   say_fmk_ver()

   AAdd( opc, "1. unos/ispravka dokumenta                   " )
   IF ( ImaPravoPristupa( goModul:oDataBase:cName, "DOK", "KNJIZNALOGA" ) )
      AAdd( opcexe, {|| fin_Knjiz() } )
   ELSE
      AAdd( opcexe, {|| MsgBeep( cZabrana ) } )
   ENDIF
   AAdd( opc, "2. izvjestaji" )
   AAdd( opcexe, {|| Izvjestaji() } )

   AAdd( opc, "3. pregled dokumenata" )
   AAdd( opcexe, {|| MnuPregledDokumenata() } )

   AAdd( opc, "4. generacija dokumenata" )
   IF ( ImaPravoPristupa( goModul:oDataBase:cName, "DOK", "GENDOK" ) )
      AAdd( opcexe, {|| MnuGenDok() } )
   ELSE
      AAdd( opcexe, {|| MsgBeep( cZabrana ) } )
   ENDIF

   AAdd( opc, "5. moduli - razmjena podataka" )
   IF ( ImaPravoPristupa( goModul:oDataBase:cName, "RAZDB", "MODULIRAZMJENA" ) )
      AAdd( opcexe, {|| MnuRazmjenaPodataka() } )
   ELSE
      AAdd( opcexe, {|| MsgBeep( cZabrana ) } )
   ENDIF

   AAdd( opc, "6. ostale operacije nad dokumentima" )
   AAdd( opcexe, {|| MnuOstOperacije() } )

   AAdd( opc, "7. udaljene lokacije - razmjena podataka " )
   IF ( ImaPravoPristupa( goModul:oDataBase:cName, "RAZDB", "UDLOKRAZMJENA" ) )
      AAdd( opcexe, {|| MnuUdaljeneLokacije() } )
   ELSE
      AAdd( opcexe, {|| MsgBeep( cZabrana ) } )
   ENDIF

   AAdd( opc, "------------------------------------" )
   AAdd( opcexe, {|| nil } )

   AAdd( opc, "8. sifrarnici" )
   AAdd( opcexe, {|| MnuSifrarnik() } )

   AAdd( opc, "9. administracija baze podataka" )
   IF ( ImaPravoPristupa( goModul:oDataBase:cName, "MAIN", "DBADMIN" ) )
      AAdd( opcexe, {|| MnuAdminDB() } )
   ELSE
      AAdd( opcexe, {|| MsgBeep( cZabrana ) } )
   ENDIF

   AAdd( opc, "------------------------------------" )
   AAdd( opcexe, {|| nil } )

   AAdd( opc, "K. kontrola zbira datoteka" )
   AAdd( opcexe, {|| f01_kontrola_zbira_fin() } )

   AAdd( opc, "P. povrat dokumenta u pripremu" )
   IF ( ImaPravoPristupa( goModul:oDatabase:cName, "UT", "POVRATNALOGA" ) )
      AAdd( opcexe, {|| PovratNaloga() } )
   ELSE
      AAdd( opcexe, {|| MsgBeep( cZabrana ) } )
   ENDIF

   AAdd( opc, "------------------------------------" )
   AAdd( opcexe, {|| nil } )

   AAdd( opc, "X. parametri" )
   IF ( ImaPravoPristupa( goModul:oDataBase:cName, "PARAM", "PARAMETRI" ) )
      AAdd( opcexe, {|| fin_menu_params() } )
   ELSE
      AAdd( opcexe, {|| MsgBeep( cZabrana ) } )
   ENDIF


   lPodBugom := .F.

   Menu_SC( "gfin", .T., lPodBugom )

   RETURN


METHOD TFinMod:sRegg()

   RETURN

METHOD TFinMod:srv()

   ? "Pokrecem FIN aplikacijski server"

   // konverzija baza
   IF ( MPar37( "/KONVERT", goModul ) )
      IF Left( self:cP5, 3 ) == "/S="
         cKonvSez := SubStr( self:cP5, 4 )
         ? "Radim sezonu: " + cKonvSez
         IF cKonvSez <> "RADP"
            // prebaci se u sezonu cKonvSez
            goModul:oDataBase:cSezonDir := SLASH + cKonvSez
            goModul:oDataBase:setDirKum( Trim( goModul:oDataBase:cDirKum ) + SLASH + cKonvSez )
            goModul:oDataBase:setDirSif( Trim( goModul:oDataBase:cDirSif ) + SLASH + cKonvSez )
            goModul:oDataBase:setDirPriv( Trim( goModul:oDataBase:cDirPriv ) + SLASH + cKonvSez )
         ENDIF
      ENDIF
      goModul:oDataBase:KonvZN()
      goModul:quit( .F. )
   ENDIF

   // modifikacija struktura
   IF ( MPar37( "/MODSTRU", goModul ) )
      IF Left( self:cP5, 3 ) == "/S="
         cKonvSez := SubStr( self:cP5, 4 )
         ? "Radim sezonu: " + cKonvSez
         IF cKonvSez <> "RADP"
            // prebaci se u sezonu cKonvSez
            goModul:oDataBase:cSezonDir := SLASH + cKonvSez
            goModul:oDataBase:setDirKum( Trim( goModul:oDataBase:cDirKum ) + SLASH + cSez )
            goModul:oDataBase:setDirSif( Trim( goModul:oDataBase:cDirSif ) + SLASH + cSez )
            goModul:oDataBase:setDirPriv( Trim( goModul:oDataBase:cDirPriv ) + SLASH + cSez )
         ENDIF
      ENDIF

      cMsFile := goModul:oDataBase:cName
      IF Left( self:cP6, 3 ) == "/M="
         cMSFile := SubStr( self:cP6, 4 )
      ENDIF
      f01_runmods( .T. )
      goModul:quit( .F. )
   ENDIF

   RETURN



METHOD TFinMod:setGVars()

   // f01_set_gvars_20()
   // f01_set_gvars_10()

   PRIVATE cSection := "1"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}

   PUBLIC gFirma := "10"
   PUBLIC gTS := "Preduzece"
   PUBLIC gNFirma := Space( 20 )  // naziv firme
   PUBLIC gRavnot := "D"
   PUBLIC gDatNal := "N"
   PUBLIC gSAKrIz := "N"
   PUBLIC gNW := "D"  // new wave
   PUBLIC gBezVracanja := "N"  // parametar zabrane povrata naloga u pripremu
   PUBLIC gBuIz := "N"  // koristenje konta-izuzetaka u FIN-BUDZET-u
   PUBLIC gPicDEM := "9999999.99"
   PUBLIC gPicBHD := "999999999999.99"
   PUBLIC gVar1 := "0"
   PUBLIC gRj := "N"
   PUBLIC gTroskovi := "N"
   PUBLIC gnRazRed := 3
   PUBLIC gVSubOp := "N"
   PUBLIC gnLMONI := 120
   PUBLIC gKtoLimit := "N"
   PUBLIC gnKtoLimit := 3
   PUBLIC gFKomp := PadR( "KOMP.TXT", 13 )
   PUBLIC gDUFRJ := "N"
   PUBLIC gBrojac := "1"
   PUBLIC gK1 := "N"
   PUBLIC gK2 := "N"
   PUBLIC gK3 := "N"
   PUBLIC gK4 := "N"
   PUBLIC gDatVal := "N"
   PUBLIC gnLOSt := 0
   PUBLIC gPotpis := "N"
   PUBLIC gnKZBDana := 0
   PUBLIC gOAsDuPartn := "N"
   PUBLIC gAzurTimeOut := 120
   PUBLIC gMjRj := "N"

   PUBLIC aRuleCols := g_rule_cols()
   PUBLIC bRuleBlock := g_rule_block()

   O_PARAMS
   Rpar( "br", @gBrojac )
   Rpar( "ff", @gFirma )
   Rpar( "ts", @gTS )
   RPar( "du", @gDUFRJ )
   Rpar( "fk", @gFKomp )
   Rpar( "fn", @gNFirma )
   Rpar( "Ra", @gRavnot )
   Rpar( "dn", @gDatNal )
   Rpar( "nw", @gNW )
   Rpar( "bv", @gBezVracanja )
   Rpar( "bi", @gBuIz )
   Rpar( "p1", @gPicDEM )
   Rpar( "p2", @gPicBHD )
   Rpar( "v1", @gVar1 )
   Rpar( "tr", @gTroskovi )
   Rpar( "rj", @gRj )
   Rpar( "rr", @gnRazRed )
   Rpar( "so", @gVSubOp )
   Rpar( "lm", @gnLMONI )
   Rpar( "si", @gSAKrIz )
   Rpar( "zx", @gKtoLimit )
   Rpar( "zy", @gnKtoLimit )
   Rpar( "OA", @gOAsDuPartn )

   Rpar( "k1", @gK1 )
   Rpar( "k2", @gK2 )
   Rpar( "k3", @gK3 )
   Rpar( "k4", @gK4 )
   Rpar( "dv", @gDatVal )
   Rpar( "li", @gnLOSt )
   Rpar( "po", @gPotpis )
   Rpar( "az", @gnKZBdana )
   Rpar( "aT", @gAzurTimeout )

   IF Empty( gNFirma )
      Beep( 1 )
      Box(, 1, 50 )
      @ m_x + 1, m_y + 2 SAY "Unesi naziv firme:" GET gNFirma PICT "@!"
      READ
      BoxC()
      WPar( "fn", gNFirma )
   ENDIF
   SELECT ( F_PARAMS )

#ifndef CAX
   USE
#endif

   PUBLIC gModul
   PUBLIC gTema
   PUBLIC gGlBaza

   gModul := "FIN"
   gTema := "OSN_MENI"
   gGlBaza := "SUBAN.DBF"


   ::super:setGvars()

   RETURN
