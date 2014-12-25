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


/*! \file fmk/fin/specif/ramaglas/rpt/1g/mnu_rpt.prg
 *   Meni izvjestaja za rama glas - "pogonsko knjigovodstvo"
 */

/*!  Izvjestaji()
 *   Glavni menij za izbor izvjestaja
 *  \param 
 */
 
function IzvjPogonK()

private Izbor:=1
private opc:={}
private opcexe:={}

AADD(opc,"1. specifikacija troskova po radnim nalozima")
AADD(opcexe,{|| SpecTrosRN()})

Menu_SC("izPK")

return .f.


