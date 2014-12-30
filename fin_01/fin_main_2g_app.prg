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
#include "hbclass.ch"


function TFinModNew()
local oObj

oObj:=TFinMod():new()

oObj:self:=oObj
return oObj

CREATE CLASS TFinMod INHERIT TAppMod
	var oSqlLog
	method dummy
	method setGVars
	method mMenu
	method mMenuStandard
	method sRegg
	method initdb
	method srv
END CLASS

method dummy()
return


method initdb()

::oDatabase:=TDBFinNew()

return NIL



method mMenu()

::oSqlLog:=TSqlLogNew()

PID("START")
if gSql=="D"
	::oSqlLog:open()
	::oDatabase:scan()
endif

close all

SETKEY(K_SH_F1,{|| Calc()})

close all

@ 1,2 SAY padc(gTS+": "+gNFirma,50,"*")
@ 4,5 SAY ""

::mMenuStandard()

::quit()

return nil



method TFinMod:mMenuStandard()

private Izbor:=1
private opc:={}
private opcexe:={}

say_fmk_ver()

AADD(opc, "1. unos/ispravka dokumenta                   ")
if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","KNJIZNALOGA"))
	AADD(opcexe, {|| fin_Knjiz()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif
AADD(opc, "2. izvjestaji")
AADD(opcexe, {|| Izvjestaji()})

AADD(opc, "3. pregled dokumenata")
AADD(opcexe, {|| MnuPregledDokumenata()})

AADD(opc, "4. generacija dokumenata")
if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","GENDOK"))
	AADD(opcexe, {|| MnuGenDok()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "5. moduli - razmjena podataka")
if (ImaPravoPristupa(goModul:oDataBase:cName,"RAZDB","MODULIRAZMJENA"))
	AADD(opcexe, {|| MnuRazmjenaPodataka()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "6. ostale operacije nad dokumentima")
AADD(opcexe, {|| MnuOstOperacije()})

AADD(opc, "7. udaljene lokacije - razmjena podataka ")
if (ImaPravoPristupa(goModul:oDataBase:cName,"RAZDB","UDLOKRAZMJENA"))
	AADD(opcexe, {|| MnuUdaljeneLokacije()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "------------------------------------")
AADD(opcexe, {|| nil})

AADD(opc, "8. sifrarnici")
AADD(opcexe, {|| MnuSifrarnik()})

AADD(opc, "9. administracija baze podataka")
if (ImaPravoPristupa(goModul:oDataBase:cName,"MAIN","DBADMIN"))
	AADD(opcexe, {|| MnuAdminDB()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "------------------------------------")
AADD(opcexe, {|| nil})

AADD(opc, "K. kontrola zbira datoteka")
AADD(opcexe, {|| KontrZb()})

AADD(opc, "P. povrat dokumenta u pripremu")
if (ImaPravoPristupa(goModul:oDatabase:cName,"UT","POVRATNALOGA"))
	AADD(opcexe, {|| PovratNaloga()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "------------------------------------")
AADD(opcexe, {|| nil})

AADD(opc, "X. parametri")
if (ImaPravoPristupa(goModul:oDataBase:cName,"PARAM","PARAMETRI"))
	AADD(opcexe, {|| fin_menu_params()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif


lPodBugom:=.f.

Menu_SC("gfin",.t.,lPodBugom)

return


method sRegg()

return



*void TFinMod::srv()

method srv()
? "Pokrecem FIN aplikacijski server"

// konverzija baza
if (MPar37("/KONVERT", goModul))
	if LEFT(self:cP5,3)=="/S="
		cKonvSez:=SUBSTR(self:cP5,4)
		? "Radim sezonu: " + cKonvSez
		if cKonvSez<>"RADP"
			// prebaci se u sezonu cKonvSez
			goModul:oDataBase:cSezonDir:=SLASH+cKonvSez
 			goModul:oDataBase:setDirKum(trim(goModul:oDataBase:cDirKum)+SLASH+cKonvSez)
 			goModul:oDataBase:setDirSif(trim(goModul:oDataBase:cDirSif)+SLASH+cKonvSez)
 			goModul:oDataBase:setDirPriv(trim(goModul:oDataBase:cDirPriv)+SLASH+cKonvSez)
		endif
	endif
	goModul:oDataBase:KonvZN()
	goModul:quit(.f.)
endif

// modifikacija struktura
if (MPar37("/MODSTRU", goModul))
	if LEFT(self:cP5,3)=="/S="
		cKonvSez:=SUBSTR(self:cP5,4)
		? "Radim sezonu: " + cKonvSez
		if cKonvSez<>"RADP"
			// prebaci se u sezonu cKonvSez
			goModul:oDataBase:cSezonDir:=SLASH+cKonvSez
 			goModul:oDataBase:setDirKum(trim(goModul:oDataBase:cDirKum)+SLASH+cSez)
 			goModul:oDataBase:setDirSif(trim(goModul:oDataBase:cDirSif)+SLASH+cSez)
 			goModul:oDataBase:setDirPriv(trim(goModul:oDataBase:cDirPriv)+SLASH+cSez)
		endif
	endif
	cMsFile:=goModul:oDataBase:cName
	if LEFT(self:cP6,3)=="/M="
		cMSFile:=SUBSTR(self:cP6,4)
	endif
	runmods(.t.)
	goModul:quit(.f.)
endif


return


/*!  *void TFinMod::setGVars()
 *   opste funkcije FIN modula
 */

*void TFinMod::setGVars()


method setGVars()

SetFmkSGVars()
SetFmkRGVars()

private cSection:="1"
private cHistory:=" "
private aHistory:={}

public gFirma:="10"
public gTS:="Preduzece"
public gNFirma:=space(20)  // naziv firme
public gRavnot:="D"
public gDatNal:="N"
public gSAKrIz:="N"
public gNW:="D"  // new wave
public gBezVracanja:="N"  // parametar zabrane povrata naloga u pripremu
public gBuIz:="N"  // koristenje konta-izuzetaka u FIN-BUDZET-u
public gPicDEM:= "9999999.99"
public gPicBHD:= "999999999999.99"
public gVar1:="0"
public gRj:="N"
public gTroskovi:="N"
public gnRazRed:=3
public gVSubOp:="N"
public gnLMONI:=120
public gKtoLimit:="N"
public gnKtoLimit:=3
public gFKomp:=PADR("KOMP.TXT",13)
public gDUFRJ:="N"
public gBrojac:="1"
public gK1:="N"
public gK2:="N"
public gK3:="N"
public gK4:="N"
public gDatVal:="N"
public gnLOSt:=0
public gPotpis:="N"
public gnKZBDana:=0
public gOAsDuPartn:="N"
public gAzurTimeOut := 120
public gMjRj := "N"

public aRuleCols := g_rule_cols()
public bRuleBlock := g_rule_block()

::super:setTGVars()

O_PARAMS
Rpar("br",@gBrojac)
Rpar("ff",@gFirma)
Rpar("ts",@gTS)
RPar("du",@gDUFRJ)
Rpar("fk",@gFKomp)
Rpar("fn",@gNFirma)
Rpar("Ra",@gRavnot)
Rpar("dn",@gDatNal)
Rpar("nw",@gNW)
Rpar("bv",@gBezVracanja)
Rpar("bi",@gBuIz)
Rpar("p1",@gPicDEM)
Rpar("p2",@gPicBHD)
Rpar("v1",@gVar1)
Rpar("tr",@gTroskovi)
Rpar("rj",@gRj)
Rpar("rr",@gnRazRed)
Rpar("so",@gVSubOp)
Rpar("lm",@gnLMONI)
Rpar("si",@gSAKrIz)
Rpar("zx",@gKtoLimit)
Rpar("zy",@gnKtoLimit)
Rpar("OA",@gOAsDuPartn)

Rpar("k1",@gK1)
Rpar("k2",@gK2)
Rpar("k3",@gK3)
Rpar("k4",@gK4)
Rpar("dv",@gDatVal)
Rpar("li",@gnLOSt)
Rpar("po",@gPotpis)
Rpar("az",@gnKZBdana)
Rpar("aT",@gAzurTimeout)

if empty(gNFirma)
	Beep(1)
  	Box(,1,50)
    		@ m_x+1,m_y+2 SAY "Unesi naziv firme:" GET gNFirma pict "@!"
    		read
  	BoxC()
  	WPar("fn",gNFirma)
endif
select (F_PARAMS)

#ifndef CAX
	use
#endif

public gModul
public gTema
public gGlBaza

gModul:="FIN"
gTema:="OSN_MENI"
gGlBaza:="SUBAN.DBF"

public cZabrana:="Opcija nedostupna za ovaj nivo !!!"

return
