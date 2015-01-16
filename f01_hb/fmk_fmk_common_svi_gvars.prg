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

FUNCTION f01_set_gvars_20()

   SetSpecifVars()
   SetValuta()

   PUBLIC gFirma := "10"
   PUBLIC gTS := "Preduzece"
   PRIVATE cSection := "K", cHistory := " "; aHistory := {}
   PUBLIC gNFirma := Space( 20 )  // naziv firme
   PUBLIC gZaokr := 2
   PUBLIC gTabela := 0
   PUBLIC gPDV := ""

   IF gModul == "FAKT" .OR. gModul == "FIN"
      cSection := "1"
   ENDIF

   SELECT ( F_PARAMS )
   IF !Used()
      O_PARAMS
   ENDIF

   RPar( "za", @gZaokr )
   Rpar( "fn", @gNFirma )
   Rpar( "ts", @gTS )
   Rpar( "tt", @gTabela )

   IF gModul == "FAKT"
      Rpar( "fi", @gFirma )
   ELSE
      Rpar( "ff", @gFirma )
   ENDIF

   IF !is_server_run() .AND. ( gModul <> "POS" .AND. gModul <> "TOPS" .AND. gModul <> "HOPS" )
      IF Empty( gNFirma )
         Box(, 1, 50 )
         Beep( 1 )
         @ m_x + 1, m_y + 2 SAY "Unesi naziv firme:" GET gNFirma PICT "@!"
         READ
         BoxC()
         WPar( "fn", gNFirma )
      ENDIF
   ENDIF

   // u sekciji 1 je pdv parametar
   cSection := "1"

   IF gModul <> "TOPS"
      RPar( "PD", @gPDV )
      ParPDV()
      WPar( "PD", gPDV )
   ENDIF

   SELECT ( F_PARAMS )
   USE

   PUBLIC gPartnBlock
   gPartnBlock := NIL

   PUBLIC gSecurity
   gSecurity := IzFmkIni( "Svi", "Security", "N", EXEPATH )

   PUBLIC gnDebug
   gnDebug := Val( IzFmkIni( "Svi", "Debug", "0", EXEPATH ) )

   PUBLIC gNoReg
   IF IzFmkIni( "Svi", "NoReg", "N", EXEPATH ) == "D"
      gNoReg := .T.
   ELSEIF IzFmkIni( "Svi", "NoReg", "N", EXEPATH ) == "N"
      gNoReg := .F.
   ELSE
      gNoReg := .F.
   ENDIF

   PUBLIC gOpSist
   gOpSist := IzFmkIni( "Svi", "OS", "-", EXEPATH )

   PUBLIC cZabrana := "Opcija nedostupna za ovaj nivo !!!"

   PUBLIC gNovine
   gNovine := IzFmkIni( "STAMPA", "Opresa", "N", KUMPATH )

   if is_server_run()
	     RETURN .T.
	 ENDIF

   IF gModul <> "TOPS"
      IF goModul:oDataBase:cRadimUSezona == "RADP"
         SetPDVBoje()
      ENDIF
   ENDIF

   RETURN .T.


FUNCTION SetPDVBoje()

   IF IsPDV()
      PDVBoje()
      goModul:oDesktop:showMainScreen()
      StandardBoje()
   ELSE
      StandardBoje()
      goModul:oDesktop:showMainScreen()
      StandardBoje()
   ENDIF

   RETURN



FUNCTION SetValuta()

   // ako se radi o planici Novi Sad onda je naziv valute DIN
   PUBLIC gOznVal
   IF IsPlNS()
      gOznVal := "DIN"
   ELSE
      gOznVal := "KM"
   ENDIF

   RETURN



/*  ParPDV()
 *   Provjeri parametar pdv
 */
FUNCTION ParPDV()

   IF ( gPDV == "" ) .OR. ( gPDV $ "ND" .AND. gModul == "TOPS" )
      // ako je tekuci datum >= 01.01.2006
      IF Date() >= CToD( "01.01.2006" )
         gPDV := "D"
      ELSE
         gPDV := "N"
      ENDIF
   ENDIF

   RETURN



/*  IsPDV()
 *   Da li je pdv rezim rada ili ne
 *  \ret .t. or .f.
 */
FUNCTION IsPDV()

   IF gPDV == "D"
      RETURN .T.
   ENDIF

   RETURN .F.
