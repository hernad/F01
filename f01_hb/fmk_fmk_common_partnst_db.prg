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
#include "partnst.ch"



/*  CrePStDB(cModulName)
 *   Kreiranje tabela za prenos (OSTAV, PARAMS)
 *   cModulName - ime modula - generisi tabele samo dok si u modulu POS
 */
function CrePStDB(cModulName)


if cModulName<>"POS"
	return
endif

// Izbrisi tabelu OSTAV
ferase(KUMPATH+"ostav.dbf")
ferase(KUMPATH+"ostav.cdx")
// Izbrisi tabelu PARAMS
ferase(KUMPATH+"params.dbf")
ferase(KUMPATH+"params.cdx")
// Izbrisi tabelu PARTN
ferase(KUMPATH+"partn.dbf")
ferase(KUMPATH+"partn.cdx")

aDbf:={} 
AADD(aDbf, { "ID",       "N",  6, 0})
AADD(aDbf, { "IZNOSG",   "N", 15, 2})
AADD(aDbf, { "IZNOSZ1",  "N", 15, 2})
AADD(aDbf, { "IZNOSZ2",  "N", 15, 2})
AADD(aDbf, { "IZNOSZ3",  "N", 15, 2})
AADD(aDbf, { "IZNOSZ4",  "N", 15, 2})
AADD(aDbf, { "IZNOSZ5",  "N", 15, 2})
DBcreate2(KUMPATH+"OSTAV.DBF",aDbf)
f01_create_index("ID", "id", KUMPATH+"OSTAV")

aDbf:={} 
AADD(aDbf, { "ID",       "N",  6, 0})
AADD(aDbf, { "OZNAKA",   "C",  8, 0})
AADD(aDbf, { "NAZIV",    "C", 30, 0})
DBcreate2(KUMPATH+"PARTN.DBF",aDbf)
f01_create_index("ID", "id", KUMPATH+"PARTN")
f01_create_index("OZNAKA", "oznaka", KUMPATH+"PARTN")


aDbf:={}
AADD(aDbf, { "ID",   "C",  3, 0} )
AADD(aDbf, { "NAZ",  "C", 20, 0} )
AADD(aDbf, { "OPIS", "C", 40, 0} )
DBcreate2(KUMPATH+"PARAMS.DBF",aDbf)
f01_create_index("ID", "ID", KUMPATH+"PARAMS")

return



/*  O_PrenHH(cPosID)
 *   Otvaranje tabele za prenos na HH
 *   cPosID - id oznaka POS-a - bitan za modul FIN
 */
function O_PrenHH(cPosID)

local nArr
nArr:=SELECT()

if cPosID <> nil
	O_KONCIJ

	cTKPath:=addbs(GetTopsKumPathFromKoncij())

	// OSTAV
	SELECT (F_F_OSTAV)
	USE (cTKPath+"OSTAV")
	set order to tag "ID"

	// PARTN
	SELECT (F_F_PARTN)
	if !used()
		USE (cTKPath+"PARTN") ALIAS "T_PARTN"
	endif
	set order to tag "ID" 
else
	O_OSTAV
	O_PARAMS
	O_PARTN
endif

select (nArr)
return



/*  GetTopsKumPathFromKoncij(cTId)
 *   Vraca KUMPATH TOPS-a iz tabele koncij
 *   cTId - idpm TOPS
 *  todo: razraditi procedure ako nema podesenog PATH-a
 */
function GetTopsKumPathFromKoncij()

cTKPath:=""
O_KONCIJ
select koncij
// setuj filter po cProdId
set filter to idprodmjes = cPosId
go top
if (field->idprodmjes == cPosId)
	cTKPath:=ALLTRIM(koncij->kumtops)
else
	cTKPath:="C:\KASE\TOPS\KUM"+cPosId
endif
set filter to

return cTKPath



/*  AddToOstav(nId, nIznosG)
 *   Dodaje gotovinski zapis u tabelu ostav - iz TOPS-a
 *   nId - polje IDN iz rngost (veza sa partn->id)
 *   nIznosG - saldo partnera iz TOPS-a
 */
function AddToOstav(nId, nIznosG)

local nArr
nArr:=SELECT()

select ostav
append blank
replace id with nId
replace iznosg with nIznosG
// ostala polja setuj na 0
replace iznosz1 with 0
replace iznosz2 with 0
replace iznosz3 with 0
replace iznosz4 with 0
replace iznosz5 with 0

select (nArr)

return


/*  AddToPartn(nId, cIdFmk, cNaziv)
 *   Dodaje zapis u tabelu partn - iz TOPS-a
 *   nId - polje IDN iz rngost (veza sa partn->id)
 *   cIdFmk - polje IDFMK iz tabele RNGOST
 *   cNaziv - naziv partnera
 */
function AddToPartn(nId, cIdFmk, cNaziv)

local nArr
nArr:=SELECT()

select partn
append blank
replace id with nId
replace oznaka with cIdFmk
replace naziv with cNaziv

select (nArr)

return



/*  AddToParams(cID, cNaziv, cOpis)
 *   Dodaje zapis u tabelu params - ovo je kontrolna tabela iz koje mozemo vidjeti koliko je preneseno partnera a koliko otvorenih stavki te kada je zadnji put prenos radjen.
 *   cID - 1. PAZ - Posljednje azuriranje 2. PCN - Broj prenesenih partnera 3. SCN - Broj prenesenih otvorenih stavki.
 *   cNaziv - Naziv promjene
 *   cOpis - Opis promjene
 */
function AddToParams(cID, cNaziv, cOpis)

local nArr
nArr:=SELECT()

select params
append blank
replace id with cId
replace naz with cNaziv
replace opis with cOpis

select (nArr)

return



/*  AddFinIntervalsToOstav(cIdPartn, nIznos1, nIznos2, nIznos3, nIznos4)
 *   Dodaje rocne intervale u OSTAV iz modula FIN 
 *   cIdPartn - id partnera
 *   nIznos1 - saldo do 4 dana
 *   nIznos2 - saldo do 8 dana
 *   nIznos3 - saldo do 16 dana
 *   nIznos4 - saldo do 20 dana
 */
function AddFinIntervalsToOstav(cIdPartn, cParNaz, nIznos1, nIznos2, nIznos3, nIznos4, nIznos5)

local nArr, nId
nArr:=SELECT()

nId:=-999

select (F_F_PARTN)
set order to tag "OZNAKA"
go top
seek PADR(cIdPartn, 8)

if field->oznaka == PADR(cIdPartn, 8)
	nId := field->id
else
	nId := 10000 + GetFOstavCnt()
	append blank
	replace id with nId 
	replace oznaka with cIdPartn
	replace naziv with cParNaz
endif

select (F_F_OSTAV)
set order to tag "id"
go top

if (nId < 10000)
	seek nId
	if field->id == nId
		replace iznosz1 with nIznos1
		replace iznosz2 with nIznos2
		replace iznosz3 with nIznos3
		replace iznosz4 with nIznos4
		replace iznosz5 with nIznos5
	endif
else
	append blank
	replace id with nId
	replace iznosg with 0
	replace iznosz1 with nIznos1
	replace iznosz2 with nIznos2
	replace iznosz3 with nIznos3
	replace iznosz4 with nIznos4
	replace iznosz5 with nIznos5
endif

select (nArr)

return



/*  GetOstavCnt()
 *   Vraca broj prenesenih partnera u OSTAV
 */
function GetOstavCnt()

local nArr
nArr:=SELECT()
O_OSTAV
nCnt:=RecCount()
select (nArr)
return nCnt



/*  GetFOstavCnt()
 *   Vraca broj prenesenih partnera u OSTAV iz modula FIN
 */
function GetFOstavCnt()

local nArr
nArr:=SELECT()
select (F_F_OSTAV)
nCnt:=RecCount()
select (nArr)
return nCnt



/*  GetPartnCnt()
 *   Vraca broj prenesenih partnera u OSTAV
 */
function GetPartnCnt()

local nArr
nArr:=SELECT()
O_PARTN
nCnt:=RecCount()
select (nArr)
return nCnt


