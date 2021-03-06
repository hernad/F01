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
 */

#define NAZIV_PROD_LEN 15
 
*string tbl_tarifa_naz;

/* var tbl_tarifa_naz
 *   Polje naziva u sifrarniku tarifa treba da nosi u nazivu "(N.T.)" za nize tarife, da bi izvjestaj Pregled prometa prodavnica znao da definise nize (djecija obuca) i vise tarife (ostala obuca)
 *  \ingroup Planika
 */
 
*string IzFmkIni_KumPath_Prodavnice_KontoNeke;

/* var IzFmkIni_KumPath_KontoNekeProdavnice_NazivKonta
 *  \ingroup ini
 *   Definise naziv prodavnice koji ce se pojaviti u izvjestaju pregled prometa
 *  \code
 *  FMK.INI/KumPath
 *  ----------------
 *  [Prodavnice]
 *  Konto_13210="Sarajevo 1"
 *  Konto_13220="Sarajevo 2"
 *  ...
 *  Konto_13290="Zenica"
 *
 */


/*   PPProd()
 *  \ingroup Planika
 *   Izvjestaj: Pregled prometa prodavnice
 */
 
function PPProd()

local i
local dDatumOd
local dDatumDo
local cTbl
local nUPari1, nUPari2, nUPari
local nUBruto1, nUBruto2, nUBruto
local nUNeto1, nUNeto2, nUNeto
local nStr
// aPolozi, 2-d matrica: 
// [1] - naziv pologa, [2] - ukupno polog
local aPolozi
local nPolog
local cNazivProdKonto
local cIdKonto
local nRow
local cPrinter
local cPicKol
private cListaKonta:=SPACE(140)
private cPopustDN:="D"

dDan:=DATE()
cTops:="D"
cPodvuci:="N"
cFilterDn:="D"

if GetVars(@dDatumOd, @dDatumDo, @cListaKonta, @cPopustDN)==0
	return
endif

CrePPProd()
MsgBeep("Kreirane pomocne tabele !!!")
// otvori tabelu
OTblPPProd()

//formiraj pomocnu tabelu
if (ScanKoncij(dDatumOd, dDatumDo)==0)
	MsgBeep("Ne postoje podaci, ili podesenja nisu korektna!")
	return
endif

cPrinter:=gPrinter
gPrinter:="R"

StartPrint()
?
? "#%LANDS#"

nStr:=0

InitAPolozi(@aPolozi)
P_COND
Header(dDatumOd, dDatumDo, aPolozi, @nStr)

nUPari:=0
nUBruto1:=0
nUBruto2:=0
nUBruto:=0
nUNeto1:=0
nUNeto2:=0
nUNeto:=0

cPicKol:=REPLICATE("9",LEN(gPicKol))

SELECT ppprod
GO TOP
do while (!EOF())
	
	cIdKonto:=field->idKonto
	cNazivProdKonto := get_prod_naz(cIdKonto)
	
	? PADR(cNazivProdKonto, NAZIV_PROD_LEN)
	@ PROW(), PCOL()+1 SAY field->pari PICTURE cPicKol
	@ PROW(), PCOL()+1 SAY field->bruto1 PICTURE gPicDem
	@ PROW(), PCOL()+1 SAY field->bruto2 PICTURE gPicDem
	@ PROW(), PCOL()+1 SAY field->bruto PICTURE gPicDem
	
	@ PROW(), PCOL()+1 SAY field->neto1 PICTURE gPicDem
	@ PROW(), PCOL()+1 SAY field->neto2 PICTURE gPicDem
	@ PROW(), PCOL()+1 SAY field->neto PICTURE gPicDem
	
	nUPari+=field->pari
	nUBruto1+=field->bruto1
	nUBruto2+=field->bruto2
	nUBruto+=field->bruto
	nUNeto1+=field->neto1
	nUNeto2+=field->neto2
	nUNeto+=field->neto
	
	for i:=1 to LEN(aPolozi)
	 	nPolog:=FldPolog(i)
		@ PROW(), PCOL()+1 SAY nPolog PICTURE gPicDem
		//suma za polog vrste i
		aPolozi[i,2]+=nPolog
	next
	SKIP
enddo

Linija(LEN(aPolozi))
Footer(nUPari, nUBruto1, nUBruto2, nUBruto, nUNeto1, nUNeto2, nUNeto, aPolozi)
Linija(LEN(aPolozi))

EndPrint()
gPrinter:=cPrinter

CLOSERET
return



static function InitAPolozi(aPolozi)

local i

aPolozi:={}
for i:=1 to 12
	AADD(aPolozi, {"", 0})
	aPolozi[i,1]:=IzFmkIni('POS','Polog'+ALLTRIM(STR(i)), "-", KUMPATH)		
	if (ALLTRIM(aPolozi[i,1])=="-")
		ADEL(aPolozi, i)
		ASIZE(aPolozi, i-1)
		exit
	endif
next


static function Header(dDatumOd, dDatumDo, aPolozi, nStr)

local i
local nSirina

nSirina:=(LEN(gPicKol)+1)
nSirina+=(6+LEN(aPolozi))*(LEN(gPicDem)+1) 

DokNovaStrana(nSirina-8, @nStr, -1)
B_ON
? PADC("KALK: PREGLED PROMETA za period "+DTOC(dDatumOd)+"-"+DTOC(dDatumDo), nSirina) 
B_OFF

Linija(LEN(aPolozi))
// prvi red
? PADC("Prodavnica", NAZIV_PROD_LEN)
@ PROW(), PCOL()+1 SAY PADC("pari", LEN(gPicKol))
@ PROW(), PCOL()+1 SAY PADC("bruto", LEN(gPicDem))
@ PROW(), PCOL()+1 SAY PADC("bruto", LEN(gPicDem))
@ PROW(), PCOL()+1 SAY PADC("bruto", LEN(gPicDem))
@ PROW(), PCOL()+1 SAY PADC("neto", LEN(gPicDem))
@ PROW(), PCOL()+1 SAY PADC("neto", LEN(gPicDem))
@ PROW(), PCOL()+1 SAY PADC("neto", LEN(gPicDem))

for i:=1 to LEN(aPolozi)
	@ PROW(), PCOL()+1 SAY PADC(aPolozi[i,1], LEN(gPicDem))	
next

//drugi red
? PADC("", NAZIV_PROD_LEN)
@ PROW(), PCOL()+1 SAY PADC("", LEN(gPicKol))
@ PROW(), PCOL()+1 SAY PADC("visa tarifa", LEN(gPicDem))
@ PROW(), PCOL()+1 SAY PADC("niza tarifa", LEN(gPicDem))
@ PROW(), PCOL()+1 SAY PADC("svega", LEN(gPicDem))
@ PROW(), PCOL()+1 SAY PADC("visa tarifa", LEN(gPicDem))
@ PROW(), PCOL()+1 SAY PADC("niza tarifa", LEN(gPicDem))
@ PROW(), PCOL()+1 SAY PADC("svega", LEN(gPicDem))

for i:=1 to LEN(aPolozi)
	@ PROW(), PCOL()+1 SAY PADC("", LEN(gPicDem))	
next

Linija(LEN(aPolozi))

return


static function Footer(nUPari, nUBruto1, nUBruto2, nUBruto, nUNeto1, nUNeto2, nUNeto, aPolozi)

local i
local cPicKol
local nUkupnoPolozi

cPicKol:=REPLICATE("9",LEN(gPicKol))

? PADC("UKUPNO:", NAZIV_PROD_LEN)
@ PROW(), PCOL()+1 SAY nUPari PICTURE cPicKol
@ PROW(), PCOL()+1 SAY nUBruto1 PICTURE gPicDem
@ PROW(), PCOL()+1 SAY nUBruto2 PICTURE gPicDem
@ PROW(), PCOL()+1 SAY nUBruto PICTURE gPicDem
@ PROW(), PCOL()+1 SAY nUNeto1 PICTURE gPicDem
@ PROW(), PCOL()+1 SAY nUNeto2 PICTURE gPicDem
@ PROW(), PCOL()+1 SAY nUNeto PICTURE gPicDem

nUkupnoPolozi:=0
for i:=1 to LEN(aPolozi)
	@ PROW(), PCOL()+1 SAY aPolozi[i,2] PICTURE gPicDem
	nUkupnoPolozi+=aPolozi[i,2]
next
if (ROUND(nUkupnoPolozi-nUBruto,4)<>0)
	MsgBeep("Ukupno bruto <> suma pologa pazara !!???")
endif
return


static function Linija(nPologa)

local i

? REPLICATE("-", NAZIV_PROD_LEN)
@ PROW(), PCOL()+1 SAY REPLICATE("-", LEN(gPicKol))
for i:=1 to 6
	@ PROW(), PCOL()+1 SAY REPLICATE("-", LEN(gPicDem))
next
for i:=1 to nPologa
	@ PROW(), PCOL()+1 SAY REPLICATE("-", LEN(gPicDem))
next
return



static function FldPolog(nPos)

do case
	case nPos==1
		return field->polog01
	case nPos==2
		return field->polog02
	case nPos==3
		return field->polog03
	case nPos==4
		return field->polog04
	case nPos==5
		return field->polog05
	case nPos==6
		return field->polog06
	case nPos==7
		return field->polog07
	case nPos==8
		return field->polog08
	case nPos==9
		return field->polog09
	case nPos==10
		return field->polog10
	case nPos==11
		return field->polog11
	case nPos==12
		return field->polog12
endcase
return


static function OTblPPProd()

local cTbl

// kreiraj tabelu ppprod
cTbl:=DbfName(F_PPPROD, .t.)
SELECT(F_PPPROD)
USE (cTbl)
SET ORDER TO TAG "KONTO"
return


static function GetVars(dDatumOd, dDatumDo, cListaKonta, cPopustDN)


#ifdef PROBA
dDatumOd:=DATE()
dDatumDo:=DATE()
#else
dDatumOd:=DATE()-1
dDatumDo:=DATE()-1
#endif

Box(,3,60)
@ m_x+1, m_y+2 SAY "Datum od :" GET dDatumOd
@ m_x+1, col()+1 SAY "-" GET dDatumDo
@ m_x+2, m_y+2 SAY "Konta (prazno-svi)" GET cListaKonta PICT "@!S40"
@ m_x+3, m_y+2 SAY "Uzeti u obzir popust " GET cPopustDN valid !EMPTY(cPopustDN)
READ
if (LASTKEY()==K_ESC)
	BoxC()
	return 0
endif
BoxC()

return 1


static function ScanKoncij(dDatumOd, dDatumDo)

local cTSifPath
local nSifPath
local cTKumPath
local nCnt
local nMpcBp
local aPorezi

O_TARIFA
O_KONCIJ

if (FIELDPOS("KUMTOPS")==0)
	MsgBeep("Prvo izvrsite modifikaciju struktura pomocu KALK.CHS !")
	CLOSE ALL
	return 0
endif

// prodji kroz koncij
GO TOP

Box(,3,60)

nCnt := 0

do while (!EOF())
	
	if !EMPTY(cListaKonta) .and. AT(ALLTRIM(field->id), cListaKonta)==0
		skip 1
		loop
	endif
	
	cTSifPath:=TRIM(field->siftops)
	cTKumPath:=TRIM(field->kumtops)

	@ m_x+1,m_y+2 SAY "Prolazim kroz tabele......."

	if EMPTY(cTSifPath) .or. EMPTY(cTKumPath)
		SKIP 1
		loop
	endif
	
	AddBs(@cTKumPath)
	AddBs(@cTKumPath)
	AddBs(@cTSifPath)
	
	if (!File2(cTKumPath+"POS.DBF") .or. !File2(cTKumPath+"POS.CDX"))
		SKIP 1
		loop
	endif
	
	SELECT(F_ROBA)
	//if !File2(cTSifPath+"ROBA.DBF") .or. !File2(cTSifPath+"ROBA.CDX")
	USE (SIFPATH+"ROBA")
	SET ORDER TO TAG "ID"
	//else
	//	USE (cTSifPath+"ROBA")
	//	SET ORDER TO TAG "ID"
	//endif
	
	ScanPos(dDatumOd, dDatumDo, cTKumPath)
	ScanPromVp(dDatumOd, dDatumDo, cTKumPath)
	
	++ nCnt
	
	SELECT roba
	USE

	SELECT koncij
	SKIP 1
enddo
BoxC()

if nCnt == 0
	return 0
endif

return 1



static function ScanPos(dDatumOd, dDatumDo, cTKumP)

local aPorezi

SELECT 0
use (cTKumP+"POS")
// dtos(datum)
SET ORDER TO TAG "4" 


SEEK DTOS(dDatumOd)
do while (!EOF() .and. (DTOS(field->datum)<=DTOS(dDatumDo)))
	//samo prodaja
	if field->idvd<>"42" .and. field->idvd<>"01"
		skip
		loop
	endif
	
	SELECT roba
	SEEK pos->idroba
	SELECT pos
	
	Tarifa(koncij->id, pos->idRoba, @aPorezi)
	// Provjeri da li je bilo popusta u POS-u
	// Popust POS se evidentira u POS->NCIJENA
	// iznos postotka npr.10 kao 10%
	
	nPosCijena:=pos->cijena
	if cPopustDN=="D" .and. pos->ncijena<>0
		nPosCijena:=nPosCijena-pos->ncijena
	endif
	
	nMpcBp:=MpcBezPor(nPosCijena, @aPorezi)
	SELECT pos
	
	@ m_x+3,m_y+2 SAY "POS    :: Prodavnica: "+ALLTRIM(koncij->id)+", PATH: "+cTKumP
	if ("(N.T.)" $ tarifa->naz)
		//radi se o nizoj tarifi
		AFPos(koncij->id, "2", nPosCijena, nMpcBp, pos->kolicina) 	
	else
		//radi se o visoj tarifi
		AFPos(koncij->id, "1", nPosCijena, nMpcBp, pos->kolicina)
	endif
	
	SELECT pos
	SKIP
enddo

SELECT pos
USE

return



/*  AFPos(cIdKonto, cVisaNiza, nCijena, nCijenaBp, nKolicina)
 *   (A)ppend (F)rom Table (Pos)
 *   cIdKonto - konto prodavnice
 *   cVisaNiza - "1" - niza tarifa ostala obuca; "2" - visa tarifa - djecija obuca
 *   nCijena
 *   nCijenaBp
 *   nKolicina - kolicina pari
 *  biljeska:  Pripadnost tarifi odredjena je sadrzajem polja tbl_tarifa_naz
 *  \sa tbl_tarifa_naz
 *
 */

static function AFPos(cIdKonto, cVisaNiza, nCijena, nCijenaBp, nKolicina) 	

local nPari

SELECT ppprod
seek cIdKonto
if (!FOUND())
	APPEND BLANK
	REPLACE idKonto WITH cIdKonto
endif

if (LEFT(roba->k2, 1)=="X")
	nPari:=0
else
	nPari:=nKolicina
endif

REPLACE pari WITH pari+nPari

if (cVisaNiza=="1")
	REPLACE bruto1 WITH field->bruto1+nCijena*nKolicina
	REPLACE neto1 WITH field->neto1+nCijenaBp*nKolicina
else
	REPLACE neto2 WITH field->neto2+nCijenaBp*nKolicina
	REPLACE bruto2 WITH field->bruto2+nCijena*nKolicina
endif

REPLACE bruto  WITH field->bruto+nCijena*nKolicina
REPLACE neto WITH field->neto+nCijenaBp*nKolicina

SELECT pos
return


static function ScanPromVp(dDatumOd, dDatumDo, cTKumPath)


SELECT 0
USE (cTKumPath+"PROMVP")

if (FIELDPOS("polog01")==0)
	MsgBeep("Stara verzija promVp:"+cTKumPath)
	return 0
endif
// datum
SET ORDER TO TAG "1" 
SELECT promVp
SEEK dDatumOd
do while (!EOF() .and. (field->datum<=dDatumDo))
	ARFPromVp( koncij->id, field->polog01, field->polog02, field->polog03, field->polog04, field->polog05, field->polog06, field->polog07, field->polog08, field->polog09, field->polog10, field->polog11, field->polog12)
	SELECT promVp
	@ m_x+3,m_y+2 SAY "PROMVP :: Prodavnica: "+ALLTRIM(koncij->id)+", PATH: "+cTKumPath
	SKIP
enddo

SELECT promVp
USE

return 1


/*  ARFPromVp(cIdKonto, nPolog01, nPolog02, nPolog03, nPolog04, nPolog05, nPolog06, nPolog07, nPolog08, nPolog09, nPolog10, nPolog11, nPolog12)
 *   (A)ppend (R)ow (F)rom Table (PromVp)
 *   cIdKonto - prodavnicki konto
 *   nPolog01 - polog pazara vrste 01 (.. do nPolog12)
 *
 */
 
static function ARFPromVp(cIdKonto, nPolog01, nPolog02, nPolog03, nPolog04, nPolog05, nPolog06, nPolog07, nPolog08, nPolog09, nPolog10, nPolog11, nPolog12)


SELECT ppprod
SEEK cIdKonto
if !FOUND()
	APPEND BLANK
	REPLACE idKonto WITH cIdKonto
endif

REPLACE polog01 WITH field->polog01+nPolog01
REPLACE polog02 WITH field->polog02+nPolog02
REPLACE polog03 WITH field->polog03+nPolog03
REPLACE polog04 WITH field->polog04+nPolog04
REPLACE polog05 WITH field->polog05+nPolog05
REPLACE polog06 WITH field->polog06+nPolog06
REPLACE polog07 WITH field->polog07+nPolog07
REPLACE polog08 WITH field->polog08+nPolog08
REPLACE polog09 WITH field->polog09+nPolog09
REPLACE polog10 WITH field->polog10+nPolog10
REPLACE polog11 WITH field->polog11+nPolog11
REPLACE polog12 WITH field->polog12+nPolog12
return

