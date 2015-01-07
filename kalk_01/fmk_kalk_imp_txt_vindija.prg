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

// stampanje dokumenata .t. or .f.
static __stampaj


function MnuImpTxt()

private izbor:=1
private opc:={}
private opcexe:={}

__stampaj := .f.

if gAImpPrint == "D"
	__stampaj := .t.
endif

AADD(opc, "1. import vindija racun                 ")
AADD(opcexe, {|| ImpTxtDok()})
AADD(opc, "2. import vindija partner               ")
AADD(opcexe, {|| ImpTxtPartn()})
AADD(opc, "3. import vindija roba               ")
AADD(opcexe, {|| ImpTxtRoba()})
AADD(opc, "4. popuna polja sifra dobavljaca ")
AADD(opcexe, {|| FillDobSifra()})
AADD(opc, "5. nastavak obrade dokumenata ... ")
AADD(opcexe, {|| RestoreObrada()})
AADD(opc, "6. podesenja importa ")
AADD(opcexe, {|| aimp_setup()})
AADD(opc, "7. kreiraj pomocnu tabelu stanja")
AADD(opcexe, {|| gen_cache()})
AADD(opc, "8. pregled pomocne tabele stanja")
AADD(opcexe, {|| brow_cache()})

Menu_SC("itx")

return



// ----------------------------------
// podesenja importa
// ----------------------------------
static function aimp_setup()

local nX
local GetList:={}

gAImpRKonto := PADR( gAImpRKonto, 7 )

nX := 1

Box(, 10, 70)

	@ m_x + nX, m_y + 2 SAY "Podesenja importa ********"
	nX += 2
	@ m_x + nX, m_y + 2 SAY "Stampati dokumente pri auto obradi (D/N)" GET gAImpPrint VALID gAImpPrint $ "DN" PICT "@!"

	nX += 1
	@ m_x + nX, m_y + 2 SAY "Automatska ravnoteza naloga na konto: " GET gAImpRKonto

	nX += 1
	@ m_x + nX, m_y + 2 SAY "Provjera broj naloga (minus karaktera):" GET gAImpRight PICT "9"


	read
BoxC()

if LastKey() <> K_ESC

	O_PARAMS

	private cSection := "7"
	private cHistory := " "
	private aHistory := {}

	WPar("ap", gAImpPrint )
	WPar("ak", gAImpRKonto )
	WPar("ar", gAImpRight )

	select params
	use

endif

return


/*  ImpTxtDok()
 *   Import dokumenta
 */
function ImpTxtDok()

local cCtrl_art := "N"
private cExpPath
private cImpFile


CrePripTDbf()

// setuj varijablu putanje exportovanih fajlova
GetExpPath( @cExpPath )

// daj mi filter za import MP ili VP
cFFilt := GetImpFilter()

if gNC_ctrl > 0 .and. Pitanje(,"Ispusti artikle sa problematicnom nc (D/N)", ;
	"N" ) == "D"
	cCtrl_art := "D"
endif

// daj mi pregled fajlova za import, te setuj varijablu cImpFile
if _gFList( cFFilt, cExpPath, @cImpFile ) == 0
	return
endif

// provjeri da li je fajl za import prazan
if CheckFile(cImpFile)==0
	MsgBeep("Odabrani fajl je prazan!#! Prekidam operaciju !")
	return
endif

private aDbf:={}
private aRules:={}
private aFaktEx
private lFtSkip := .f.
private lNegative := .f.

// setuj polja temp tabele u matricu aDbf
SetTblDok(@aDbf)
// setuj pravila upisa podataka u temp tabelu
SetRuleDok(@aRules)

// prebaci iz txt => temp tbl
txt_to_temp_import_tabela(aDbf, aRules, cImpFile)

if !CheckDok()
	MsgBeep("Prekidamo operaciju !!!#Nepostojece sifre!!!")
	return
endif

if CheckBrFakt( @aFaktEx ) == 0
	if Pitanje(,"Preskociti ove dokumente prilikom importa (D/N)?","D")=="D"
		lFtSkip := .t.
	endif
endif

lNegative := .f.

if Pitanje(,"Prebaciti prvo negatine dokumente (povrate) ?", "D") == "D"
	lNegative := .t.
endif

if TTbl2Kalk( aFaktEx, lFtSkip, lNegative, cCtrl_art ) == 0
	MsgBeep("Operacija prekinuta!")
	return
endif

// obrada dokumenata iz pript tabele
MnuObrDok()

TxtErase(cImpFile, .t.)

return


/*  GetImpFilter()
 *   Vraca filter za naziv dokumenta u zavisnosti sta je odabrano VP ili MP
 */
static function GetImpFilter()

cVPMP := "V"
// pozovi box za izbor
Box(,5, 60)
	@ 1+m_x, 2+m_y SAY "Importovati:"
	@ 2+m_x, 2+m_y SAY "----------------------------------"
	@ 3+m_x, 2+m_y SAY "Veleprodaja (V)"
	@ 4+m_x, 2+m_y SAY "Maloprodaja (M)"
	@ 5+m_x, 17+m_y SAY "izbor =>" GET cVPMP VALID cVPMP$"MV" .and. !Empty(cVPMP) PICT "@!"
	read
BoxC()

// filter za veleprodaju
cRet := "R*.R??"

// postavi filter za fajlove
do case
	case cVPMP == "M"
		cRet := "M*.M??"

	case cVPMP == "V"
		cRet := "R*.R??"
endcase

return cRet



/*  MnuObrDok()
 *   Obrada dokumenata iz pomocne tabele
 */
static function MnuObrDok()

if Pitanje(,"Obraditi dokumente iz pomocne tabele (D/N)?", "D") == "D"
	ObradiImport( nil, nil, __stampaj )
else
	MsgBeep("Dokumenti nisu obradjeni!#Obrada se moze uraditi i naknadno!")
	close all
endif

return



/*  ImpTxtPartn()
 *   Import sifrarnika partnera
 */
static function ImpTxtPartn()

private cExpPath
private cImpFile

// setuj varijablu putanje exportovanih fajlova
GetExpPath(@cExpPath)

cFFilt := "P*.P??"

// daj mi pregled fajlova za import, te setuj varijablu cImpFile
if _gFList(cFFilt, cExpPath, @cImpFile) == 0
	return
endif

// provjeri da li je fajl za import prazan
if CheckFile(cImpFile)==0
	MsgBeep("Odabrani fajl je prazan!#!!! Prekidam operaciju !!!")
	return
endif

private aDbf:={}
private aRules:={}
// setuj polja temp tabele u matricu aDbf
set_tbl_partner(@aDbf)
// setuj pravila upisa podataka u temp tabelu
SetRulePartn(@aRules)

// prebaci iz txt => temp tbl
txt_to_temp_import_tabela(aDbf, aRules, cImpFile)

if CheckPartn() > 0
	if Pitanje(,"Izvrsiti import partnera (D/N)?", "D") == "N"
		MsgBeep("Opcija prekinuta!")
		return
	endif
else
	MsgBeep("Nema novih partnera za import !")
	return
endif

// ova opcija ipak i nije toliko dobra da se radi!
//
//lEdit := Pitanje(,"Izvrsiti korekcije postojecih podataka (D/N)?", "N") == "D"
lEdit := .f.

if TTbl2Partn(lEdit) == 0
	MsgBeep("Operacija prekinuta!")
	return
endif

MsgBeep("Operacija zavrsena !")


TxtErase(cImpFile)

return



// ------------------------------------------
// import sifrarnika robe
// ------------------------------------------
static function ImpTxtRoba()
private cExpPath
private cImpFile

// setuj varijablu putanje exportovanih fajlova
GetExpPath( @cExpPath )

cFFilt := "S*.S??"

// daj mi pregled fajlova za import, te setuj varijablu cImpFile
if _gFList(cFFilt, cExpPath, @cImpFile) == 0
	return
endif

// provjeri da li je fajl za import prazan
if CheckFile(cImpFile)==0
	MsgBeep("Odabrani fajl je prazan!#!!! Prekidam operaciju !!!")
	return
endif

private aDbf:={}
private aRules:={}
// setuj polja temp tabele u matricu aDbf
SetTblRoba(@aDbf)
// setuj pravila upisa podataka u temp tabelu
SetRuleRoba(@aRules)

// prebaci iz txt => temp tbl
txt_to_temp_import_tabela(aDbf, aRules, cImpFile)

if CheckRoba() > 0
	if Pitanje(,"Importovati nove cijene u sifrarnika robe (D/N)?", "D") == "N"
		MsgBeep("Opcija prekinuta!")
		return
	endif
else
	MsgBeep("Nema novih stavki za import !")
	return
endif

lEdit := .f.

if TTbl2Roba( lEdit ) == 0
	MsgBeep("Operacija prekinuta!")
	return
endif

MsgBeep("Operacija zavrsena !")

TxtErase(cImpFile)

return



/*  SetTblDok(aDbf)
 *   Setuj matricu sa poljima tabele dokumenata RACUN
 *   aDbf - matrica
 */
static function SetTblDok(aDbf)


AADD(aDbf,{"idfirma", "C", 2, 0})
AADD(aDbf,{"idtipdok", "C", 2, 0})
AADD(aDbf,{"brdok", "C", 8, 0})
AADD(aDbf,{"datdok", "D", 8, 0})
AADD(aDbf,{"idpartner", "C", 6, 0})
AADD(aDbf,{"idpm", "C", 3, 0})
AADD(aDbf,{"dindem", "C", 3, 0})
AADD(aDbf,{"zaokr", "N", 1, 0})
AADD(aDbf,{"rbr", "C", 3, 0})
AADD(aDbf,{"idroba", "C", 10, 0})
AADD(aDbf,{"kolicina", "N", 14, 5})
AADD(aDbf,{"cijena", "N", 14, 5})
AADD(aDbf,{"rabat", "N", 14, 5})
AADD(aDbf,{"porez", "N", 14, 5})
AADD(aDbf,{"rabatp", "N", 14, 5})
AADD(aDbf,{"datval", "D", 8, 0})
AADD(aDbf,{"obrkol", "N", 14, 5})
AADD(aDbf,{"idpj", "C", 3, 0})
AADD(aDbf,{"dtype", "C", 3, 0})

return


/*  set_tbl_partner(aDbf)
 *   Set polja tabele partner
 *   aDbf - matrica sa def.polja
 */
static function set_tbl_partner(aDbf)


AADD(aDbf,{"idpartner", "C", 6, 0})
AADD(aDbf,{"naz", "C", 25, 0})
AADD(aDbf,{"ptt", "C", 5, 0})
AADD(aDbf,{"mjesto", "C", 16, 0})
AADD(aDbf,{"adresa", "C", 24, 0})
AADD(aDbf,{"ziror", "C", 22, 0})
AADD(aDbf,{"telefon", "C", 12, 0})
AADD(aDbf,{"fax", "C", 12, 0})
AADD(aDbf,{"idops", "C", 4, 0})
AADD(aDbf,{"rokpl", "N", 5, 0})
AADD(aDbf,{"porbr", "C", 16, 0})
AADD(aDbf,{"idbroj", "C", 16, 0})
AADD(aDbf,{"ustn", "C", 20, 0})
AADD(aDbf,{"brupis", "C", 20, 0})
AADD(aDbf,{"brjes", "C", 20, 0})

return



// -------------------------------------
// matrica sa strukturom
// tabele ROBA
// -------------------------------------
static function SetTblRoba(aDbf)

AADD(aDbf,{"idpm", "C", 3, 0})
AADD(aDbf,{"datum", "C", 10, 0})
AADD(aDbf,{"sifradob", "C", 10, 0})
AADD(aDbf,{"naz", "C", 30, 0})
AADD(aDbf,{"mpc", "N", 15, 5})

return




/*  SetRuleDok(aRule)
 *   Setovanje pravila upisa zapisa u temp tabelu
 *   aRule - matrica pravila
 */
static function SetRuleDok(aRule)

/*

10 10 16452281 05.01.2015 118169 001 KM  2 001 2050  +000007200.00000 +000000001.38000 +0000000.00000 +0001689.12000 +0000000.00000 21.03.2015 +000007200.00000 010
10 10 16452281 05.01.2015 118169 001 KM  2 002 2086  +000002160.00000 +000000000.85000 +0000000.00000 +0000312.12000 +0000000.00000 21.03.2015 +000002160.00000 010

*/

// idfirma
AADD(aRule, {"SUBSTR(cVar, 1, 2)"})
// idtipdok
AADD(aRule, {"SUBSTR(cVar, 4, 2)"})
// brdok
AADD(aRule, {"SUBSTR(cVar, 7, 8)"})
// datdok
AADD(aRule, {"CTOD(SUBSTR(cVar, 16, 10))"})
// idpartner
AADD(aRule, {"SUBSTR(cVar, 27, 6)"})
// id pm
AADD(aRule, {"SUBSTR(cVar, 34, 3)"})
// dindem
AADD(aRule, {"SUBSTR(cVar, 38, 3)"})
// zaokr
AADD(aRule, {"VAL(SUBSTR(cVar, 42, 1))"})
// rbr
AADD(aRule, {"STR(VAL(SUBSTR(cVar, 44, 3)),3)"})
// idroba
AADD(aRule, {"ALLTRIM(SUBSTR(cVar, 48, 5))"})
// kolicina
AADD(aRule, {"VAL(SUBSTR(cVar, 54, 16))"})
// cijena
AADD(aRule, {"VAL(SUBSTR(cVar, 71, 16))"})
// rabat
AADD(aRule, {"VAL(SUBSTR(cVar, 88, 14))"})
// porez
AADD(aRule, {"VAL(SUBSTR(cVar, 103, 14))"})
// procenat rabata

AADD(aRule, {"VAL(SUBSTR(cVar, 118, 14))"})
// datum valute

AADD(aRule, {"CTOD(SUBSTR(cVar, 133, 10))"})
// obracunska kolicina

AADD(aRule, {"VAL(SUBSTR(cVar, 144, 16))"})

// poslovna jedinica "kod"
AADD(aRule, {"SUBSTR(cVar, 161, 3)"})

return



/*  SetRulePartn(aRule)
 *   Setovanje pravila upisa zapisa u temp tabelu
 *   aRule - matrica pravila
 */
static function SetRulePartn(aRule)

// id
AADD(aRule, {"SUBSTR(cVar, 1, 6)"})
// naz
AADD(aRule, {"SUBSTR(cVar, 8, 25)"})
// ptt
AADD(aRule, {"SUBSTR(cVar, 34, 5)"})
// mjesto
AADD(aRule, {"SUBSTR(cVar, 40, 16)"})
// adresa
AADD(aRule, {"SUBSTR(cVar, 57, 24)"})
// ziror
AADD(aRule, {"SUBSTR(cVar, 82, 22)"})
// telefon
AADD(aRule, {"SUBSTR(cVar, 105, 12)"})
// fax
AADD(aRule, {"SUBSTR(cVar, 118, 12)"})
// idops
AADD(aRule, {"SUBSTR(cVar, 131, 4)"})
// rokpl
AADD(aRule, {"VAL(SUBSTR(cVar, 136, 5))"})
// porbr
AADD(aRule, {"SUBSTR(cVar, 143, 16)"})
// idbroj
AADD(aRule, {"SUBSTR(cVar, 160, 16)"})
// ustn
AADD(aRule, {"SUBSTR(cVar, 177, 20)"})
// brupis
AADD(aRule, {"SUBSTR(cVar, 198, 20)"})
// brjes
AADD(aRule, {"SUBSTR(cVar, 219, 20)"})

return



// ---------------------------------------------
// pravila za import tabele robe
// ---------------------------------------------
static function SetRuleRoba(aRule)

// idpm
AADD(aRule, {"SUBSTR(cVar, 1, 3)"})
// datum
AADD(aRule, {"SUBSTR(cVar, 5, 10)"})
// sifra dobavljaca
AADD(aRule, {"SUBSTR(cVar, 16, 6)"})
// naziv
AADD(aRule, {"SUBSTR(cVar, 22, 30)"})
// mpc
AADD(aRule, {"VAL( STRTRAN( SUBSTR(cVar, 53, 10), ',', '.' ) )"})

return





/*  GetExpPath(cPath)
 *   Vraca podesenje putanje do exportovanih fajlova
 *   cPath - putanja, zadaje se sa argumentom @ kao priv.varijabla
 */
static function GetExpPath(cPath)

cPath:=IzFmkIni("KALK", "ImportPath", "c:" + SLASH + "liste" + SLASH, PRIVPATH)
if Empty(cPath) .or. cPath == nil
	cPath := "c:" + SLASH + "liste" + SLASH
endif
return




/*  txt_to_temp_import_tabela(aDbf, aRules, cTxtFile)
 *   Kreiranje temp tabele, te prenos zapisa iz text fajla "cTextFile" u tabelu putem aRules pravila
 *   aDbf - struktura tabele
 *   aRules - pravila upisivanja jednog zapisa u tabelu, princip uzimanja zapisa iz linije text fajla
 *   cTxtFile - txt fajl za import
 */
 */

static function txt_to_temp_import_tabela(aDbf, aRules, cTxtFile)

// prvo kreiraj tabelu temp
close all

CreTemp(aDbf)
O_TEMP

if !File(PRIVPATH + SLASH + "TEMP.DBF")
	MsgBeep("Ne mogu kreirati fajl TEMP.DBF!")
	return
endif

// zatim iscitaj fajl i ubaci podatke u tabelu

// broj linija fajla
nBrLin:=BrLinFajla(cTxtFile)
nStart:=0

// prodji kroz svaku liniju i insertuj zapise u temp.dbf
for i:=1 to nBrLin

	aFMat:=SljedLin(cTxtFile, nStart)
  nStart:=aFMat[2]
	// uzmi u cText liniju fajla
	cVar:=aFMat[1]

	// selektuj temp tabelu
	select temp
	// dodaj novi zapis
	append blank

	for nCt:=1 to LEN(aRules)
		fname := FIELD(nCt)
		xVal := aRules[nCt, 1]
		replace &fname with &xVal

	next
next



select temp

// prođi kroz temp i napuni da li je dtype pozitivno ili negativno
// ali samo ako je u pitanju racun tabela... !
if temp->(fieldpos("idtipdok")) <> 0
	go top
	do while !EOF()
		if field->idtipdok == "10" .and. field->kolicina < 0
			replace field->dtype with "0"
		else
			replace field->dtype with "1"
		endif
		skip
	enddo
endif

MsgBeep("Import txt => temp - OK")

return



/*  CheckFile(cTxtFile)
 *   Provjerava da li je fajl prazan
 *   cTxtFile - txt fajl
 */
function CheckFile(cTxtFile)

nBrLin:=BrLinFajla(cTxtFile)
return nBrLin



/*  CreTemp(aDbf)
 *   Kreira tabelu PRIVPATH\TEMP.DBF prema definiciji polja iz aDbf
 *   aDbf - def.polja
 */
static function CreTemp(aDbf)

cTmpTbl := PRIVPATH + "TEMP"

if File(cTmpTbl + ".DBF") .and. FErase(cTmpTbl + ".DBF") == -1
	MsgBeep("Ne mogu izbrisati TEMP.DBF!")
    	ShowFError()
endif
if File(cTmpTbl + ".CDX") .and. FErase(cTmpTbl + ".CDX") == -1
	MsgBeep("Ne mogu izbrisati TEMP.CDX!")
    	ShowFError()
endif

DbCreate2(cTmpTbl, aDbf)

// provjeri jesu li partneri ili dokumenti ili je roba
if aDbf[1,1] == "idpartner"
	// partner
	create_index("1","idpartner", cTmpTbl)
elseif aDbf[1,1] == "idpm"
	// roba
	create_index("1", "sifradob", cTmpTbl)
else
	// dokumenti
	create_index("1","idfirma+idtipdok+brdok+rbr", cTmpTbl)
	create_index("2","dtype+idfirma+idtipdok+brdok+rbr", cTmpTbl)
endif
return



/*  CrePriprTDbf()
 *   Kreiranje tabele PRIVPATH + PRIPT.DBF
 */
function CrePripTDbf()

close all
FErase(PRIVPATH + "PRIPT.DBF")
FErase(PRIVPATH + "PRIPT.CDX")

O_PRIPR
select pripr

// napravi pript sa strukturom tabele PRIPR
copy structure to (PRIVPATH+"struct")
create (PRIVPATH + "pript") from (PRIVPATH + "struct")
create_index("1","idfirma+idvd+brdok", PRIVPATH+"pript")
create_index("2","idfirma+idvd+brdok+idroba", PRIVPATH+"pript")

return



/*  CheckBrFakt()
 *   Provjeri da li postoji broj fakture u azuriranim dokumentima
 */
static function CheckBrFakt(aFakt )

aPomFakt := FaktExist( gAImpRight )

if LEN(aPomFakt) > 0

	START PRINT CRET
	?
	? "Kontrola azuriranih dokumenata:"
	? "-------------------------------"
	? "Broj fakture => kalkulacija"
	? "-------------------------------"
	?

	for i:=1 to LEN(aPomFakt)
		? aPomFakt[i, 1] + " => " + aPomFakt[i, 2]
	next

	?
	? "Kontrolom azuriranih dokumenata, uoceno da se vec pojavljuju"
	? "navedeni brojevi faktura iz fajla za import !"
	?

	FF
	END PRINT

	aFakt := aPomFakt
	return 0

endif

aFakt := aPomFakt

return 1



/*  CheckDok()
 *   Provjera da li postoje sve sifre u sifrarnicima za dokumente
 */
static function CheckDok()
local lSifDob := .t.

aPomPart := ParExist()
aPomArt  := TempArtExist( lSifDob )

if (LEN(aPomPart) > 0 .or. LEN(aPomArt) > 0)

	START PRINT CRET

	if (LEN(aPomPart) > 0)
		? "Lista nepostojecih partnera:"
		? "----------------------------"
		?
		for i:=1 to LEN(aPomPart)
			? aPomPart[i, 1]
		next
		?
	endif

	if (LEN(aPomArt) > 0)
		? "Lista nepostojecih artikala:"
		? "----------------------------"
		?
		for ii:=1 to LEN(aPomArt)
			? aPomArt[ii, 1]
		next
		?
	endif

	FF
	END PRINT

	return .f.
endif

return .t.




/*  CheckPartn()
 *  Provjerava i daje listu nepostojecih partnera pri importu liste partnera
 */
static function CheckPartn()


aPomPart := ParExist(.t.)

if (LEN(aPomPart) > 0)

	START PRINT CRET

	? "Lista nepostojecih partnera:"
	? "----------------------------"
	?
	for i:=1 to LEN(aPomPart)
		? aPomPart[i, 1]
		?? " " + aPomPart[i, 2]
	next
	?

	FF
	END PRINT

endif

return LEN(aPomPart)




// --------------------------------------------------------------------------
// Provjerava i daje listu promjena na robi
// --------------------------------------------------------------------------

static function CheckRoba()

aPomRoba := SDobExist( .t. )

if (LEN(aPomRoba) > 0)

	START PRINT CRET

	? "Lista promjena u sifrarniku robe:"
	? "---------------------------------------------------------------------------"
	? "sifradob    naziv                          stara cijena -> nova cijena "
	? "---------------------------------------------------------------------------"
	?

	for i:=1 to LEN(aPomRoba)

		? aPomRoba[i, 2]

		?? " " + aPomRoba[i, 9]

		if aPomRoba[i, 1] == "1"

			if aPomRoba[i, 3] == "001"
				// vpc
				nCijena := aPomRoba[i, 6]
			elseif aPomRoba[i, 3] == "002"
				// vpc2
				nCijena := aPomRoba[i, 7]
			elseif aPomRoba[i, 3] == "003"
				// mpc
				nCijena := aPomRoba[i, 8]
			endif

			?? STR( nCijena, 12, 2 )
			?? STR( aPomRoba[i, 4], 12, 2 )

			if nCijena = aPomRoba[i, 4]
				?? " x"
			endif

		else
			?? " ovog artikla nema u sifrarniku !"
		endif

	next

	?

	FF
	END PRINT

endif

return LEN(aPomRoba)





// --------------------------------------------------------
// provjerava da li postoji roba po sifri dobavljaca
// --------------------------------------------------------
static function SDobExist()
O_ROBA
select temp
go top

aRet:={}

do while !EOF()

	select roba
	set order to tag "SIFRADOB"
	go top

	seek temp->sifradob

	if Found()
		cInd := "1"
	else
		cInd := "0"
	endif

	AADD(aRet, {cInd, temp->sifradob, temp->idpm, temp->mpc, roba->id, ;
				roba->vpc, roba->vpc2, roba->mpc, temp->naz } )

	select temp
	skip

enddo

return aRet



/*  ParExist()
 *   Provjera da li postoje sifre partnera u sifraniku FMK
 */
static function ParExist(lPartNaz)

O_PARTN
select temp
go top

if lPartNaz == nil
	lPartNaz := .f.
endif

aRet:={}

do while !EOF()
	select partn
	go top
	seek temp->idpartner
	if !Found()
		if lPartNaz
			AADD(aRet, {temp->idpartner, temp->naz})
		else
			AADD(aRet, {temp->idpartner})
		endif
	endif
	select temp
	skip
enddo

return aRet



/*  GetKTipDok(cFaktTD)
 *   Vraca kalk tip dokumenta na osnovu fakt tip dokumenta
 *   cFaktTD - fakt tip dokumenta
 */
static function GetKTipDok(cFaktTD, cPm)

cRet:=""

if (cFaktTD == "" .or. cFaktTD == nil)
	return "XX"
endif

do case
	// racuni VP
	// FAKT 10 -> KALK 14
	case cFaktTD == "10"
		cRet := "14"

	// diskont vindija
	// FAKT 11 -> KALK 41
	case (cFaktTD == "11" .and. cPm >= "200")
		cRet := "41"

	// zaduzenje prodavnica
	// FAKT 13 -> KALK 11
	case (cFaktTD == "11" .and. cPm < "200")
		cRet := "11"

	// kalo, rastur - otpis
	// radio se u kalku
	case cFaktTD $ "90#91#92"
		cRet := "95"

	// Knjizna obavjest
	// 70 -> KALK KO
	case cFaktTD == "70"
		cRet := "KO"

endcase

return cRet



// ---------------------------------------------------------------
// Vrati konto za prodajno mjesto Vindijine prodavnice
//    cProd - prodajno mjesto C(3), npr "200"
//    cPoslovnica - poslovnica sarajevo ili tuzla ili ....
// cita iz fmk.ini/kumpath
//  [Vindija]
//  VPR200_050=13200
//  VPR201_050=13201
//  itd....
// ---------------------------------------------------------------
static function GetVPr( cProd, cPoslovnica )

if cProd == "XXX"
	return "XXXXX"
endif

if cProd == "" .or. cProd == nil
	return "XXXXX"
endif

if cPoslovnica == "" .or. cPoslovnica == nil
	return "XXXXX"
endif

cRet := IzFmkIni("VINDIJA", "VPR" + cProd + "_" + cPoslovnica, "xxxx", KUMPATH)

if cRet == "" .or. cRet == nil
	cRet := "XXXXX"
endif

return cRet


// -----------------------------------------------------------
// Vraca konto za odredjeni tipdokumenta
// cTipDok - tip dokumenta
// cTip - "Z" zaduzuje, "R" - razduzuje
// cPoslovnica -poslovnica vindije sarajevo, tuzla ili ...
// -----------------------------------------------------------
static function GetTdKonto(cTipDok, cTip, cPoslovnica)

cRet := IzFmkIni("VINDIJA", "TD" + cTipDok + cTip + cPoslovnica, ;
		"xxxx", KUMPATH)

// primjer:
// TD14Z050=1310 // posl.sarajevo
// TD14R050=1200
// TD14R042=1201 // posl.tuzla npr...

if cRet == "" .or. cRet == nil
	cRet := "XXXXX"
endif

return cRet




/*  FaktExist()
 *   vraca matricu sa parovima faktura -> pojavljuje se u azur.kalk
 *   nRight - npr. bez zadnjih nRight brojeva
 */
static function FaktExist( nRight )

local cBrFakt
local cTDok

if nRight == nil
	nRight := 0
endif

O_DOKS

select temp
go top

aRet:={}

cDok := "XXXXXX"
do while !EOF()

	cBrFakt := ALLTRIM(temp->brdok)
	cBrOriginal := cBrFakt

	if nRight > 0
		cBrFakt := PADR( cBrFakt, LEN(cBrFakt) - nRight )
	endif

	cTDok := GetKTipDok(ALLTRIM(temp->idtipdok), temp->idpm)

	if cBrFakt == cDok
		skip
		loop
	endif

	select doks

	if nRight > 0
		set order to tag "V_BRF2"
	else
		set order to tag "V_BRF"
	endif

	go top

	if nRight > 0
		seek cTDok + cBrFakt
	else
		seek PADR(cBrFakt, 10) + cTDok
	endif

	if FOUND()
		AADD(aRet, {cBrOriginal, doks->idfirma + "-" + doks->idvd + "-" + ALLTRIM(doks->brdok)})

	endif

	select temp
	skip

	cDok := cBrFakt
enddo

return aRet


/*  TTbl2Kalk(aFExist, lFSkip)
 *   kopira podatke iz pomocne tabele u tabelu KALK->PRIPT
 *   aFExist matrica sa postojecim fakturama
 *   lFSkip preskaci postojece fakture
 *   lNegative - prvo prebaci negativne fakture
 *   cCtrl_art - preskoci sporne artikle NC u hendeku ! na osnovu CACHE
 *         tabele
 */
static function TTbl2Kalk(aFExist, lFSkip, lNegative, cCtrl_art )

local cBrojKalk
local cTipDok
local cIdKonto
local cIdKonto2
local cIdPJ
local aArr_ctrl := {}
local _id_konto, _id_konto2

O_PRIPR
O_KONCIJ
O_DOKS
O_DOKS2
O_ROBA
O_PRIPT

select temp

if lNegative == nil
	lNegative := .f.
endif

if lNegative == .t.
	set order to tag "2"
else
	set order to tag "1"
endif

go top

nRbr:=0
nUvecaj:=0
nCnt:=0

cPFakt := "XXXXXX"
cPTDok := "XX"
cPPm := "XXX"
aPom := {}

do while !EOF()

	cFakt := ALLTRIM(temp->brdok)
	cTDok := GetKTipDok(ALLTRIM(temp->idtipdok), temp->idpm)
	cPm := temp->idpm
	cIdPJ := temp->idpj

	// pregledaj CACHE, da li treba preskociti ovaj artikal
	if cCtrl_art == "D"

		nT_scan := 0

		cTmp_kto := GetKtKalk( cTDok, temp->idpm, "R", cIdPJ )

		select roba
		set order to tag "ID_VSD"

		cTmp_dob := PADL( ALLTRIM(temp->idroba), 5, "0" )

		go top
		seek cTmp_dob

		cTmp_roba := field->id

		O_CACHE
		select cache
		set order to tag "1"
		go top
		seek PADR( cTmp_kto, 7 ) + PADR( cTmp_roba, 10 )

		if FOUND() .and. gNC_ctrl > 0 .and. ( field->odst > gNC_ctrl )
			// dodaj sporne u kontrolnu matricu

			nT_scan := ASCAN( aArr_ctrl, ;
				{|xVal| xVal[1] + PADR( xVal[2], 10 ) == ;
					cTDok + PADR( ALLTRIM( cFakt ), 10 ) } )

			if nT_scan = 0
				AADD( aArr_ctrl, { cTDok, ;
					PADR( ALLTRIM(cFakt), 10 ) } )
			endif

		endif

		select temp
	endif

	// ako je ukljucena opcija preskakanja postojecih faktura
	if lFSkip
		// ako postoji ista u matrici
		if LEN(aFExist) > 0
			nFExist := ASCAN(aFExist, {|aVal| ALLTRIM(aVal[1]) == cFakt})
			if nFExist > 0
				// prekoci onda ovaj zapis i idi dalje
				select temp
				skip
				loop
			endif
		endif
	endif

	if cTDok <> cPTDok
		nUvecaj := 0
	endif

  altd()

	if cFakt <> cPFakt
		++ nUvecaj
		cBrojKalk := GetNextKalkDoc(gFirma, cTDok, nUvecaj)
		nRbr := 0
		AADD(aPom, { cTDok, cBrojKalk, cFakt })
	else
		// ako su diskontna zaduzenja razgranici ih putem polja prodajno mjesto
		if cTDok == "11"
			if cPm <> cPPm
				++ nUvecaj
				cBrojKalk := GetNextKalkDoc(gFirma, cTDok, nUvecaj)
				nRbr := 0
				AADD(aPom, { cTDok, cBrojKalk, cFakt })
			endif
		endif
	endif

	// pronadji robu
	select roba
	set order to tag "ID_VSD"
	cTmpArt := PADL( ALLTRIM(temp->idroba), 5, "0" )
	go top
	seek cTmpArt


	// ovo dodaje datum valute itd...
	// bitno kod kontiranja kalk->fin
	// radi datuma valute
	if cTDok == "14"

		select doks2
		hseek gFirma + cTDok + cBrojKalk

		if !FOUND()
			append blank
			replace idvd with "14"
			replace brdok with cBrojKalk
			replace idfirma with gFirma
		endif

		replace DatVal with temp->datval

	endif

	// konta zaduzuje i razduzuje !
	_id_konto := GetKtKalk( cTDok, temp->idpm, "Z", cIdPJ )
	_id_konto2 := GetKtKalk( cTDok, temp->idpm, "R", cIdPJ )

	// pozicioniraj se na koncij stavku
	select koncij
	set order to tag "ID"
	go top
	seek _id_konto

	// dodaj zapis u pripr
	select pript
	append blank

	replace idfirma with gFirma
	replace rbr with STR(++nRbr, 3)

	// uzmi pravilan tip dokumenta za kalk
	replace idvd with cTDok

	replace brdok with cBrojKalk
	replace datdok with temp->datdok
	replace idpartner with temp->idpartner
	replace idtarifa with ROBA->idtarifa
	replace brfaktp with cFakt
	replace datfaktp with temp->datdok

	// konta:
	// =====================
	// zaduzuje
	replace idkonto with _id_konto
	// razduzuje
	replace idkonto2 with _id_konto2
	replace idzaduz2 with ""

	// spec.za tip dok 11
	if cTDok $ "11#41"

		replace tmarza2 with "A"
		replace tprevoz with "A"

		if cTDok == "11"
			// treba uzeti cijenu iz sifrarnika aktuelnu !
			replace mpcsapp with UzmiMpcSif()
		else
			replace mpcsapp with temp->cijena
		endif

	endif

	replace datkurs with temp->datdok
	replace kolicina with temp->kolicina
	replace idroba with roba->id
	replace nc with ROBA->nc
	replace vpc with temp->cijena
	replace rabatv with temp->rabatp
	replace mpc with temp->porez

	cPFakt := cFakt
	cPTDok := cTDok
	cPPm := cPm

	++ nCnt

	select temp
	skip
enddo

// izvjestaj o prebacenim dokumentima....
if nCnt > 0

	ASORT(aPom,,,{|x,y| x[1]+"-"+x[2] < y[1]+"-"+y[2]})

	START PRINT CRET
	? "========================================"
	? "Generisani sljedeci dokumenti:          "
	? "========================================"
	? "Dokument     * Sporna NC"
	? "----------------------------------------"

	for i:=1 to LEN(aPom)

		cT_tipdok := aPom[i, 1]
		cT_brdok := aPom[i, 2]
		cT_brfakt := aPom[i, 3]
		cT_ctrl := ""

		if cCtrl_art == "D" .and. LEN( aArr_ctrl ) > 0
		      nT_scan := ASCAN( aArr_ctrl, ;
				{|xVal| xVal[1] + PADR( xVal[2], 10 ) == ;
					cT_tipdok + PADR( cT_brfakt, 10 ) } )

		      if nT_scan <> 0
			cT_ctrl := " !!! ERROR !!!"
		      endif
		endif

		? cT_tipdok + " - " + cT_brdok, cT_ctrl

	next

	?

	FF
	END PRINT
endif

if cCtrl_art == "D" .and. LEN( aArr_ctrl ) > 0

	START PRINT CRET

	?
	? "Ispusteni dokumenti:"
	? "------------------------------------"

	for xy := 1 to LEN( aArr_ctrl )
		? aArr_ctrl[xy, 1] + "-" + aArr_ctrl[xy, 2]
	next

	FF
	END PRINT

endif

// pobrisi ispustene dokumente
if cCtrl_art == "D" .and. LEN( aArr_ctrl ) > 0

	nT_scan := 0

	select pript
	set order to tag "0"
	go top

	do while !EOF()

		nT_scan := ASCAN(aArr_ctrl, ;
			{|xval| xval[1] + PADR( xval[2], 10 ) == ;
			field->idvd + PADR( field->brfaktp, 10 ) })

		if nT_scan <> 0
			delete
		endif

		skip
	enddo

endif

return 1



/*  GetKtKalk(cTipDok, cPm, cTip)
 *   Varaca konto za trazeni tip dokumenta i prodajno mjesto
 *   cTipDok - tip dokumenta
 *   cPm - prodajno mjesto
 *   cTip - tip "Z" zad. i "R" razd.
 *   cPoslovnica - poslovnica tuzla ili sarajevo
 */

static function GetKtKalk(cTipDok, cPm, cTip, cPoslovnica)

do case
	case cTipDok == "14"
		cRet := GetTDKonto(cTipDok, cTip, cPoslovnica)
	case cTipDok == "11"
		if cTip == "R"
			cRet := GetTDKonto(cTipDok, cTip, cPoslovnica)
		else
			cRet := GetVPr(cPm, cPoslovnica)
		endif
	case cTipDok == "41"
		cRet := GetTDKonto(cTipDok, cTip, cPoslovnica)
	case cTipDok == "95"
		cRet := GetTDKonto(cTipDok, cTip, cPoslovnica)
	case cTipDok == "KO"
		cRet := GetTDKonto(cTipDok, cTip, cPoslovnica)

endcase

return cRet



/*  TTbl2Partn(lEditOld)
 *   kopira podatke iz pomocne tabele u tabelu PARTN
 *   lEditOld - ispraviti stare zapise
 */
static function TTbl2Partn(lEditOld)


O_PARTN
O_SIFK
O_SIFV

select temp
go top

lNovi := .f.

do while !EOF()

	// pronadji partnera
	select partn
	cTmpPar := ALLTRIM(temp->idpartner)
	go top
	seek cTmpPar

	// ako si nasao:
	//  1. ako je lEditOld .t. onda ispravi postojeci
	//  2. ako je lEditOld .f. onda preskoci
	if Found()
		if !lEditOld
			select temp
			skip
			loop
		endif
		lNovi := .f.
	else
		lNovi := .t.
	endif

	// dodaj zapis u partn
	select partn

	if lNovi
		append blank
	endif

	if !lNovi .and. !lEditOld
		select temp
		skip
		loop
	endif

	replace id with temp->idpartner
	cNaz := temp->naz
	replace naz with KonvZnWin(@cNaz, "8")
	replace ptt with temp->ptt
	cMjesto := temp->mjesto
	replace mjesto with KonvZnWin(@cMjesto, "8")
	cAdres := temp->adresa
	replace adresa with KonvZnWin(@cAdres, "8")
	replace ziror with temp->ziror
	replace telefon with temp->telefon
	replace fax with temp->fax
	replace idops with temp->idops
	// ubaci --vezane-- podatke i u sifK tabelu
	USifK("PARTN", "ROKP", temp->idpartner, temp->rokpl)
	USifK("PARTN", "PORB", temp->idpartner, temp->porbr)
	USifK("PARTN", "REGB", temp->idpartner, temp->idbroj)
	USifK("PARTN", "USTN", temp->idpartner, temp->ustn)
	USifK("PARTN", "BRUP", temp->idpartner, temp->brupis)
	USifK("PARTN", "BRJS", temp->idpartner, temp->brjes)

	select temp
	skip
enddo

return 1


// -----------------------------------------
// napuni iz tmp tabele u robu
// -----------------------------------------
static function TTbl2Roba()

O_ROBA
O_SIFK
O_SIFV

select temp
go top

do while !EOF()

	// pronadji robu
	select roba
	set order to tag "SIFRADOB"

	cTmpSif := ALLTRIM(temp->sifradob)

	go top
	seek cTmpSif

	if !Found()

		// da li treba dodavati novi zapis ...

	else

		// mjenja se VPC
		if temp->idpm == "001"
			if field->vpc <> temp->mpc
				replace field->vpc with temp->mpc
			endif
		// mjenja se VPC2
		elseif temp->idpm == "002"
			if field->vpc2 <> temp->mpc
				replace field->vpc2 with temp->mpc
			endif
		// mjenja se MPC
		elseif temp->idpm == "003"
			if field->mpc <> temp->mpc
				replace field->mpc with temp->mpc
			endif
		endif

	endif

	select temp
	skip
enddo

return 1




/*  GetKVars(dDatDok, cBrKalk, cTipDok, cIdKonto, cIdKonto2, cRazd)
 *   Setuj parametre prenosa TEMP->PRIPR(KALK)
 *   dDatDok - datum dokumenta
 *   cBrKalk - broj kalkulacije
 *   cTipDok - tip dokumenta
 *   cIdKonto - id konto zaduzuje
 *   cIdKonto2 - konto razduzuje
 *   cRazd - razdvajati dokumente po broju fakture (D ili N)
 */
static function GetKVars(dDatDok, cBrKalk, cTipDok, cIdKonto, cIdKonto2, cRazd)

dDatDok:=DATE()
cTipDok:="14"
cIdFirma:=gFirma
cIdKonto:=PADR("1200",7)
cIdKonto2:=PADR("1310",7)
cRazd:="D"
O_KONTO
O_DOKS
cBrKalk:=GetNextKalkDoc(cIdFirma, cTipDok)

Box(,15,60)
	@ m_x+1,m_y+2   SAY "Broj kalkulacije 14-" GET cBrKalk pict "@!"
  	@ m_x+1,col()+2 SAY "Datum:" GET dDatDok
  	@ m_x+4,m_y+2   SAY "Konto razduzuje:" GET cIdKonto2 pict "@!" VALID P_Konto(@cIdKonto2)
  	@ m_x+6,m_y+2   SAY "Razdvajati kalkulacije po broju faktura" GET cRazd pict "@!" valid cRazd$"DN"
	read
BoxC()

if LastKey()==K_ESC
	return 0
endif

return 1





/*  ObradiImport()
 *   Obrada importovanih dokumenata
 */
function ObradiImport(nPocniOd, lAsPokreni, lStampaj)
local cN_kalk_dok := ""
local nUvecaj := 0

O_PRIPR
O_PRIPT

if lAsPokreni == nil
	lAsPokreni := .t.
endif
if lStampaj == nil
	lStampaj := .t.
endif

if nPocniOd == nil
	nPocniOd := 0
endif

lAutom := .f.
if Pitanje(,"Automatski asistent i azuriranje naloga (D/N)?", "D") == "D"
	lAutom := .t.
endif


// iz pripr_temp prebaci u pripr jednu po jednu kalkulaciju
select pript
set order to tag "1"

if nPocniOd == 0
	go top
else
	go nPocniOd
endif

// uzmi parametre koje ces dokumente prenositi
cBBTipDok := SPACE(30)
Box(,3, 60)
	@ 1+m_x, 2+m_y SAY "Prenositi sljedece tipove dokumenata:"
	@ 3+m_x, 2+m_y SAY "Tip dokumenta (prazno-svi):" GET cBBTipDok PICT "@S25"
	read
BoxC()

if !Empty(cBBTipDok)
	cBBTipDok := ALLTRIM(cBBTipDok)
endif

//SetKey(K_F3,{|| SaveObrada(nPTRec)})

Box(,10, 70)
@ 1+m_x, 2+m_y SAY "Obrada dokumenata iz pomocne tabele:" COLOR "I"
@ 2+m_x, 2+m_y SAY "===================================="

do while !EOF()

	nPTRec:=RecNo()
	nPCRec:=nPTRec
	cBrDok := field->brdok
	cFirma := field->idfirma
	cIdVd  := field->idvd

	if !Empty(cBBTipDok) .and. !(cIdVd $ cBBTipDok)
		skip
		loop
	endif

	// daj novi broj dokumenta kalk
	nT_area := SELECT()
	cN_kalk_dok := GetNextKalkDoc(cFirma, cIdVd, 1)
	select (nT_area)

	@ 3+m_x, 2+m_y SAY "Prebacujem: " + cFirma + "-" + cIdVd + "-" + cBrDok

	nStCnt := 0
	do while !EOF() .and. field->brdok = cBrDok .and. field->idfirma = cFirma .and. field->idvd = cIdVd

		// jedan po jedan row azuriraj u pripr
		select pripr
		append blank
		Scatter()
		select pript
		Scatter()
		select pripr
		_brdok := cN_kalk_dok
		Gather()

		select pript
		skip
		++ nStCnt

		nPTRec := RecNo()

		@ 5+m_x, 13+m_y SAY SPACE(5)
		@ 5+m_x, 2+m_y SAY "Broj stavki:" + ALLTRIM(STR(nStCnt))
	enddo

	// nakon sto smo prebacili dokument u pripremu obraditi ga
	if lAutom
		// snimi zapis u params da znas dokle si dosao
		SaveObrada(nPCRec)
		ObradiDokument(cIdVd, lAsPokreni, lStampaj)
		SaveObrada(nPTRec)
		O_PRIPT
	endif

	select pript
	go nPTRec

enddo

BoxC()

// snimi i da je obrada zavrsena
SaveObrada(0)

MsgBeep("Dokumenti obradjeni!")

return


/*  SaveObrada()
 *   Snima momenat do kojeg je dosao pri obradi dokumenata
 */
static function SaveObrada(nPRec)

local nArr
nArr := SELECT()

O_PARAMS
select params

private cSection:="K"
private cHistory:=" "
private aHistory:={}

Wpar("is", nPRec)

select (nArr)

return


/*  RestoreObrada()
 *   Pokrece ponovo obradu od momenta do kojeg je stao
 */
static function RestoreObrada()

O_PARAMS
select params
private cSection:="K"
private cHistory:=" "
private aHistory:={}
private nDosaoDo
Rpar("is", @nDosaoDo)

if nDosaoDo == nil
	MsgBeep("Nema nista zapisano u parametrima!#Prekidam operaciju!")
	return
endif

if nDosaoDo == 0
	MsgBeep("Nema zapisa o prekinutoj obradi!")
	return
endif

O_PRIPT
select pript
set order to tag "1"
go nDosaoDo

if !EOF()
	MsgBeep("Nastavljam od dokumenta#" + field->idfirma + "-" + field->idvd + "-" + field->brdok)
else
	MsgBeep("Kraj tabele, nema nista za obradu!")
	return
endif

if Pitanje(,"Nastaviti sa obradom dokumenata", "D") == "N"
	MsgBeep("Operacija prekinuta!")
	return
endif

ObradiImport( nDosaoDo , nil, __stampaj )

return


/*  ObradiDokument(cIdVd)
 *   Obrada jednog dokumenta
 *   cIdVd - id vrsta dokumenta
 */
static function ObradiDokument(cIdVd, lAsPokreni, lStampaj)


// 1. pokreni asistenta
// 2. azuriraj kalk
// 3. azuriraj FIN

private lAsistRadi:=.f.

if lAsPokreni == nil
	lAsPokreni := .t.
endif

if lStampaj == nil
	lStampaj := .t.
endif

if lAsPokreni
	// pozovi asistenta
	KUnos(.t.)
else
	OEdit()
endif

if lStampaj == .t.
	// odstampaj kalk
	StKalk( nil, nil, .t. )
endif


kalk_Azur( .t. )

OEdit()

// ako postoje zavisni dokumenti non stop ponavljaj proceduru obrade
private nRslt

do while (ChkKPripr(cIdVd, @nRslt) <> 0)

	// vezni dokument u pripremi je ok
	if nRslt == 1

		if lAsPokreni
			// otvori pripremu
			KUnos(.t.)
		else
			OEdit()
		endif

		if lStampaj == .t.
			StKalk(nil, nil, .t.)
		endif

		kalk_Azur( .t. )
		OEdit()

	endif

	// vezni dokument ne pripada azuriranom dokumentu
	// sta sa njim

	if nRslt >= 2

		MsgBeep("Postoji dokument u pripremi koji je sumljiv!!!#Radi se o veznom dokumentu ili nekoj drugoj gresci...#Obradite ovaj dokument i autoimport ce nastaviti dalje sa radom !")
		KUnos()
		OEdit()

	endif
enddo

return


/*  ChkKPripr(cIdVd, nRes)
 *   Provjeri da li je priprema prazna
 *   cIdVd - id vrsta dokumenta
 */
static function ChkKPripr(cIdVd, nRes)
// provjeri da li je priprema prazna, ako je prazna vrati 0
select pripr
go top

if RecCount() == 0
	// idi dalje...
	nRes := 0
	return 0
endif

// provjeri koji je dokument u pripremi u odnosu na cIdVd
return nRes := ChkTipDok(cIdVd)

return 0



/*  ChkTipDok(cIdVd)
 *   Provjeri pripremu za tip dokumenta
 *   cIdVd - vrsta dokumenta
 */
static function ChkTipDok(cIdVd)

nNrRec := RecCount()
nTmp := 0
cPrviDok := field->idvd
nPrviDok := VAL(cPrviDok)

do while !EOF()
	nTmp += VAL(field->idvd)
	skip
enddo

nUzorak := nPrviDok * nNrRec

if nUzorak <> nNrRec * nTmp
	// ako u pripremi ima vise dokumenata vrati 2
	return 3
endif

do case
	case cIdVd == "14"
		return ChkTD14(cPrviDok)
	case cIdVd == "41"
		return ChkTD41(cPrviDok)
	case cIdVd == "11"
		return ChkTD11(cPrviDok)
	case cIdVD == "95"
		return ChkTD95(cPrviDok)
endcase

return 0



/*  ChkTD14(cVezniDok)
 *   Provjeri vezne dokumente za tip dokumenta 14
 *   cVezniDok - dokument iz pripreme
 *  vraca 1 ako je sve ok, ili 2 ako vezni dokument ne odgovara
 */
static function ChkTD14(cVezniDok)

if cVezniDok $ "18#19#95#16#11"
	return 1
endif

return 2


/*  ChkTD41()
 *   Provjeri vezne dokumente za tip dokumenta 41
 */
static function ChkTD41(cVezniDok)

if cVezniDok $ "18#19#95#16#11"
	return 1
endif

return 2


/*  ChkTD11()
 *   Provjeri vezne dokumente za tip dokumenta 11
 */
static function ChkTD11(cVezniDok)

if cVezniDok $ "18#19#95#16#11"
	return 1
endif

return 2


/*  ChkTD95()
 *   Provjeri vezne dokumente za tip dokumenta 95
 */
static function ChkTD95(cVezniDok)

if cVezniDok $ "18#19#95#16#11"
	return 1
endif

return 2



/*  FillDobSifra()
 *   Popunjavanje polja sifradob prema kljucu
 */
static function FillDobSifra()

if !SigmaSif("FILLDOB")
	MsgBeep("Nemate ovlastenja za ovu opciju!!!")
	return
endif

O_ROBA

select roba
set order to tag "ID"
go top

cSifra:=""
nCnt := 0
aRpt := {}
aSDob := {}

Box(,5, 60)
@ 1+m_x, 2+m_y SAY "Vrsim upis sifre dobavaljaca robe:"
@ 2+m_x, 2+m_y SAY "==================================="

do while !EOF()
	// ako je prazan zapis preskoci
	if Empty(field->id)
		skip
		loop
	endif

	cSStr := SUBSTR(field->id, 1, 1)

	// provjeri karakteristicnost robe
	if cSStr == "K" .or. cSStr == "P"
		// roba KOKA LEN 5 sifradob
		cSifra := SUBSTR(RTRIM(field->id), -5)
	elseif cSStr == "V"
		// ostala roba
		cSifra := SUBSTR(RTRIM(field->id), -4)
	else
		skip
		loop
	endif

	// upisi zapis
	Scatter()
	_sifradob := cSifra
	Gather()

	// potrazi sifru u matrici
	nRes := ASCAN(aSDob, {|aVal| aVal[1] == cSifra})
	if nRes == 0
		AADD(aSDob, {cSifra, field->id})
	else
		AADD(aRpt, {cSifra, aSDob[nRes, 2]})
		AADD(aRpt, {cSifra, field->id})
	endif

	++ nCnt

	@ 3+m_x, 2+m_y SAY "FMK sifra " + ALLTRIM(field->id) + " => sifra dob. " + cSifra
	@ 5+m_x, 2+m_y SAY " => ukupno " + ALLTRIM(STR(nCnt))

	skip

enddo

BoxC()

// ako je report matrica > 0 dakle postoje dupli zapisi
if LEN(aRpt) > 0
	START PRINT CRET
	? "KONTROLA DULIH SIFARA VINDIJA_FAKT:"
	? "==================================="
	? "Sifra Vindija_FAKT -> Sifra FMK  "
	?

	for i:=1 to LEN(aRpt)
		? aRpt[i, 1] + " -> " + aRpt[i, 2]
	next

	?
	? "Provjerite navedene sifre..."
	?

	FF
	END PRINT
endif


return
