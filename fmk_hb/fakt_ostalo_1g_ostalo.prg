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

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */
 

/*! \file fmk/fakt/ostalo/1g/ostalo.prg
 */


function FaAsistent()

local nEntera

nEntera:=30
for iSekv:=1 to int(RecCount2()/15)+1
cSekv:=chr(K_CTRL_A)
	for nKekk:=1 to min(reccount2(),15)*20
		cSekv+=cEnter
	next
	keyboard csekv
next
return


