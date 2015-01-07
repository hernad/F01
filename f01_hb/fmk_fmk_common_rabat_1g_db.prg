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
#include "rabat.ch"

/*  CreRabDB()
 *   Kreira tabelu rabat u SIFPATH
 */
 
function CreRabDB()

// RABAT.DBF
aDbf:={}
AADD(aDbf,{"IDRABAT"      , "C", 10, 0})
AADD(aDbf,{"TIPRABAT"     , "C", 10, 0})
AADD(aDbf,{"DATUM"        , "D",  8, 0})
AADD(aDbf,{"DANA"         , "N",  5, 0})
AADD(aDbf,{"IDROBA"       , "C", 10, 0})
AADD(aDbf,{"IZNOS1"       , "N",  8, 2})
AADD(aDbf,{"IZNOS2"       , "N",  8, 2})
AADD(aDbf,{"IZNOS3"       , "N",  8, 2})
AADD(aDbf,{"IZNOS4"       , "N",  8, 2})
AADD(aDbf,{"IZNOS5"       , "N",  8, 2})
AADD(aDbf,{"SKONTO"       , "N",  8, 2})

if !File((SIFPATH + "rabat.dbf"))
	DbCreate2(SIFPATH + "rabat.dbf", aDbf)
endif

CREATE_INDEX("1", "IDRABAT+TIPRABAT+IDROBA", SIFPATH + "rabat.dbf", .t.)
CREATE_INDEX("2", "IDRABAT+TIPRABAT+DTOS(DATUM)", SIFPATH + "rabat.dbf", .t.)

return



/*  GetRabForArticle(cIdRab, cTipRab, cIdRoba, nTekIznos)
 *   Vraca iznos rabata za dati artikal
 *   cIdRab - id rabat
 *   nTekIznos - tekuce polje iznosa
 *   cTipRab - tip rabata
 *   cIdRoba - id roba
 *  return: nRet - vrijednost rabata
 */
function GetRabForArticle(cIdRab, cTipRab, cIdRoba, nTekIznos)

local nArr
nArr:=SELECT()

cIdRab := PADR(cIdRab, 10)
cTipRab := PADR(cTipRab, 10)

O_RABAT
select rabat
set order to tag "1"
go top
seek cIdRab + cTipRab + cIdRoba

// vrati iznos rabata za tekucu vriijednost polja IZNOSn
nRet:=GetRabIznos(nTekIznos)

select (nArr)

return nRet



/*  GetDaysForRabat(cIdRab, cTipRab)
 *   Vraca broj dana (rok placanja) za odredjeni tip rabata
 *   cIdRab - id rabat
 *   cTipRab - tip rabata
 *  return: nRet - vrijednost dana
 */
function GetDaysForRabat(cIdRab, cTipRab)

local nArr
nArr:=SELECT()

cIdRab := PADR(cIdRab, 10)
cTipRab := PADR(cTipRab, 10)

O_RABAT
select rabat
set order to tag "1"
go top
seek cIdRab + cTipRab
nRet:=field->dana
select (nArr)

return nRet



/*  GetRabIznos(cTekIzn)
 *   Vraca iznos rabata za zadati cTekIznos (vrijednost polja)
 *   cTekIzn - tekuce polje koje se uzima
 */
function GetRabIznos(cTekIzn)

if (cTekIzn == nil)
	cTekIzn := "1"
endif

// primjer: "iznos" + cTekIzn
//           iznos1 ili iznos3
cField := "iznos" + ALLTRIM(cTekIzn)
// izvrsi macro evaluaciju
nRet := field->&cField
return nRet



/*  GetSkontoArticle(cIdRab, cTipRab, cIdRoba)
 *   Vraca iznos skonto za dati artikal
 *   cIdRab - id rabat
 *   cTipRab - tip rabata
 *   cIdRoba - id roba
 *  return: nRet - vrijednost skonto
 */
function GetSkontoArticle(cIdRab, cTipRab, cIdRoba)

local nArr
nArr:=SELECT()

cIdRab := PADR(cIdRab, 10)
cTipRab := PADR(cTipRab, 10)
O_RABAT
select rabat
set order to tag "1"
go top
seek cIdRab + cTipRab + cIdRoba
nRet:=field->skonto
select (nArr)

return nRet






