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


#include "fakt01.ch"


/* file fmk/fakt/specif/vindija/1g/mnu_sif.prg
 *   Menij sifrarnika za vindiju
 */

/*  SifOVindija()
 *   Opci sifrarnik koji koristi vindija
 */

function SifOVindija()

private Opc:={}
private opcexe:={}

AADD(opc,"1. relacije          ")
AADD(opcexe,{|| P_Relac()})
AADD(opc,"2. vozila")
AADD(opcexe,{|| P_Vozila()})
AADD(opc,"3. kalendar posjeta")
AADD(opcexe,{|| P_KalPos()})

CLOSE ALL
O_PARTN
OSifVindija()

private Izbor:=1
Menu_SC("vsif")

return .f.
