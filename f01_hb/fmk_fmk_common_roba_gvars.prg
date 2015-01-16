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


FUNCTION f01_set_gvars_10()

   PUBLIC gUVarPP
   PUBLIC glProvNazRobe
   PUBLIC gRobaBlock
   PUBLIC gPicCDem
   PUBLIC PicDem
   PUBLIC gPicProc
   PUBLIC gPicDEM
   PUBLIC gPickol
   PUBLIC gFPicCDem
   PUBLIC gFPicDem
   PUBLIC gFPicKol

   PUBLIC glAutoFillBK
   PUBLIC gDuzSifIni

   PUBLIC glPoreziLegacy
   PUBLIC glUgost
   PUBLIC gUgostVarijanta

   // R - Obracun porez na RUC
   // D - starija varijanta ???
   // N - obicno robno knjigovodstvo


   glPoreziLegacy := ( IzFmkIni( "POREZI", "Legacy", "D", EXEPATH ) == "D" )


   glUgost := ( IzFmkIni( "UGOSTITELJSTVO", "Obracun", "N", KUMPATH ) == "D" )

   // RMarza_DLimit - osnovica realizovana marza ili donji limit
   // MpcSaPor - Maloprodajna cijena sa porezom
   gUgostVarijanta := Upper( IzFmkIni( "UGOSTITELJSTVO", "Varijanta", "Rmarza_DLimit", KUMPATH ) )

   gUVarPP := IzFMKINI( "POREZI", "PPUgostKaoPPU", "N", KUMPATH )

   glProvNazRobe := ( IzFmkIni( "ROBA", "BezIstihNaziva", "N" ) == "D" )

   glAutoFillBK := ( IzFmkIni( "ROBA", "AutoFillBarKod", "N", SIFPATH ) == "D" )

   gRobaBlock := nil

   gPicCDEM := "999999.999"
   gPicProc := "999999.99%"
   gPicDEM := "9999999.99"
   gPickol := "999999.999"
   gFPicCDem := "0"
   gFPicDem := "0"
   gFPicKol := "0"

   gDuzSifINI := IzFmkIni( 'Sifroba', 'DuzSifra', '10', SIFPATH )

   RETURN
