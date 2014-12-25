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


#include "kalk01.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software
 * ----------------------------------------------------------------
 *
 */


/*! \file fmk/kalk/razdb/1g/fak_kal.prg
 *   Prenos dokumenata iz modula FAKT u KALK
 */


/*!  FaktKalk()
 *   Meni opcija za prenos dokumenata iz modula FAKT u KALK
 */

function FaktKalk()

private Opc:={}
private opcexe:={}

AADD(Opc,"1. magacin fakt->kalk         ")
AADD(opcexe,{|| FaKaMag() })
AADD(Opc,"2. prodavnica fakt->kalk")
AADD(opcexe,{||  FaKaProd()  })
AADD(Opc,"3. proizvodnja fakt->kalk")
AADD(opcexe,{||  FaKaProizvodnja() })
AADD(Opc,"4. konsignacija fakt->kalk")
AADD(opcexe, {|| FaktKonsig() })
private Izbor:=1
Menu_SC("faka")
CLOSERET
return





/*!  ProvjeriSif(clDok,cImePoljaID,nOblSif,clFor)
 *   Provjera postojanja sifara
 *   clDok - "while" uslov za obuhvatanje slogova tekuce baze
 *   cImePoljaID - ime polja tekuce baze u kojem su sifre za ispitivanje
 *   nOblSif - oblast baze sifrarnika
 *   clFor - "for" uslov za obuhvatanje slogova tekuce baze
 */

function ProvjeriSif(clDok,cImePoljaID,nOblSif,clFor,lTest)

LOCAL lVrati:=.t., nArr:=SELECT(), nRec:=RECNO(), lStartPrint:=.f., cPom3:=""
LOCAL nR:=0

if lTest == nil
	lTest := .f.
endif

IF clFor == NIL
	clFor:=".t."
ENDIF

PRIVATE cPom := clDok, cPom2 := cImePoljaID, cPom4:=clFor

DO WHILE &cPom
  IF &cPom4
    SELECT (nOblSif)
    cPom3 := (nArr)->(&cPom2)
    SEEK cPom3
    IF !FOUND()  .and.  !(  xFakt->(alltrim(podbr)==".")  .and. empty(xfakt->idroba))
                        // ovo je kada se ide 1.  1.1 1.2
      ++nR
      lVrati:=.f.
      if lTest == .f.
       IF !lStartPrint
        lStartPrint:=.t.
        StartPrint()
        ? "NEPOSTOJECE SIFRE:"
        ? "------------------"
       ENDIF
       ? STR(nR)+") SIFRA '"+cPom3+"'"
      else

      	nTArea := SELECT()
	select roba
	go top
	seek xfakt->idroba
	if !FOUND()
	  append blank
	  replace id with xfakt->idroba
	  replace naz with "!!! KONTROLOM UTVRDJENO"
	endif
	select (nTArea)

      endif
    ENDIF
  ENDIF
  SELECT (nArr)
  SKIP 1
ENDDO
GO (nRec)
IF lStartPrint
  ?
  EndPrint()
ENDIF
return lVrati
