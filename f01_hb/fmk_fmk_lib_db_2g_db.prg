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
#include "hbclass.ch"

FUNCTION TDBNew( oDesktop, cDirPriv, cDirKum, cDirSif )

   LOCAL oObj

   oObj := TDB():new()

   oObj:oDesktop := oDesktop
   oObj:cDirPriv := cDirPriv
   oObj:cDirKum := cDirKum
   oObj:cDirSif := cDirSif
   oObj:lAdmin := .F.



CREATE CLASS TDB
	EXPORTED:
	VAR oDesktop
	VAR oApp
	VAR cName

	VAR cSezona
	VAR cRadimUSezona

	VAR cSezonDir
	VAR cBase
	VAR cDirPriv
	VAR cDirKum
	VAR cDirSif
	VAR cSigmaBD
	VAR cUser
	VAR nPassword
	VAR nGroup1
	VAR nGroup2
	VAR nGroup3
	VAR lAdmin
	method radiUSezonskomPodrucju
	method loadSezonaRadimUSezona
	method saveSezona
	method saveRadimUSezona
	method logAgain
	method modstruAll
	method setDirPriv
	method setDirSif
	method setDirKum
	method setSigmaBD
	method setUser
	method setPassword
	method setGroup1
	method setGroup2
	method setGroup3
	method mInstall
	method vratiSez
	method setIfNil
	method scan

END CLASS


/* var TDB:lAdmin
 *   True - admin rezim, False - normalni pristup podacima
 */



method TDb:logAgain(cSezona, lSilent, lWriteKParam)

local cPom
local fURp:=.f.
// sezona koja je trenutno radno podrucje
local cDanasnjaSezona
private lURp:=.f.

//ako sam u administratorskom rezimu, za svaki slucaj kreiraj
//parametarske tabele
if ::lAdmin
	CreSystemDb()
endif

CLOSE ALL

::setIfNil()

if (lWriteKParam==nil)
	lWriteKParam:=.t.
endif


if ((cSezona!=nil) .and. (::cSezona != nil) .and. (lSilent!=nil))
	if ((cSezona==::cSezona) .and. (::cSezona==STR(Year(Date()),4)) .and. lSilent)
		fURP:=.t.
	endif
endif

if cSezona==nil
	cSezona:=STR(YEAR(DATE())-1,4)
endif

if lSilent==nil
	lsilent:=.f.
endif

cDanasnjaSezona:=STR(YEAR(DATE()),4)

IF ::cSezona==nil
	::cSezona:=cDanasnjaSezona
EndIF

if !lsilent
	Box(,1,60)
	set cursor on
  	@ m_x+1,m_y+2 SAY "Pristup podacima iz sezone " GET cSezona pict "@!"
  	read
  	ESC_BCR
	BoxC()

	// pristup sezonskim podacima tek godine
	if ( ::cSezona==cSezona  .or. cSezona=="RADP")
   		if Pitanje(,"Pristup radnom podrucju ?","D")=="D"
       			fURP:=.t.
   		endif
	endif
else

	if ( ::cSezona==cSezona .or. cSezona=="RADP")
		fURP := .t.
	endif

endif

// novi radni direktoriji
if !EMPTY(::cSezondir)
	::setDirKum(strtran(::cDirKum ,::cSezonDir,""))
	::setDirSif(strtran(::cDirSif ,::cSezonDir,""))
	::setDirPriv(strtran(::cDirPriv,::cSezonDir,""))
endif

// vrati u predhodno stanje

if !fURP .and. (::cSezona==cDanasnjaSezona)
	// nisam u radnom podrucju, ako se ovo pokrece sa radne stanice
  	// kreirajmo privatne datoteke
  	::skloniSezonu(cSezona,.f.,.t.,.f.,  .t.)
endif

if fUrP
  	cSezona:="RADP"
endif

if lWriteKParam
	private cSection:="1",cHistory:=" "; aHistory:={}
	O_KPARAMS
	::cRadimUSezona:=cSezona
	Wpar("rp",::cRadimUSezona)
	select kparams
endif

USE

MsgBeep( "server " + DTOS( netio_funcexec( "DATE" )) )


if fURP
 	::cSezonDir:=""
 	::oDesktop:showSezona(::cRadimUSezona)
 	::oDesktop:showMainScreen()
else
	StandardBoje()
	::oDesktop:showSezona(::cRadimUSezona)
	SezonskeBoje()
	::oDesktop:showMainScreen()
	StandardBoje()

	::cSezonDir:=SLASH+::cRadimUSezona
	::setDirKum( trim(::cDirKum) + SLASH + ::cRadimUSezona)
	::setDirSif( trim(::cDirSif) + SLASH + ::cRadimUSezona)
	::setDirPriv( trim(::cDirPriv) + SLASH + ::cRadimUSezona)

  MsgBeep( "sezonski direktoriji:##" + ::cDirKum + "#" + ::cDirSif + "#" + ::cDirPriv)

	::oDesktop:showSezona(::cRadimUSezona)

	StandardBoje()  // vrati standardne boje
endif


if !PostDir(::cDirKum) .and. Pitanje(,"Formirati sezonske direktorije","N")=="D"
	// kreiraj sezonske direktorije
	dirmake(::cDirKum)
	dirmake(::cDirSif)
	dirmake(::cDirPriv)
endif

lURp:=fURp

::oApp:SetGVars()

JelReadOnly()
return


method TDb:modstruAll()
local i
::lAdmin:=.t.

aSezone:=ASezona(::cDirKum)
f01_runmods(.t.)

FOR i:=1 TO LEN(aSezone)
	f01_cre_params()
	::LogAgain(aSezone[i,1], .t.)
	f01_cre_params()
	f01_runmods(.t.)
NEXT

::cRadimUSezona:="RADP"

private cSection:="1"
private cHistory:=" "
private aHistory:={}

O_KPARAMS
Wpar("rp",::cRadimUSezona)
select kparams
use

::lAdmin:=.f.
return


method TDb:setDirPriv(cDir)

local cPom

// dosadasnja vrijednost varijable
cPom:=::cDirPriv

cDir:=ALLTRIM(cDir)

::cDirPriv:=f01_transform_dbf_name(cDir)

// setuj i globalnu varijablu dok ne eliminisemo sve pozive na tu varijablu
cDirPriv:=::cDirPriv

return cPom


method TDb:setDirSif(cDir)
local cPom

// dosadasnja vrijednost varijable
cPom:=::cDirSif

cDir:=alltrim(cDir)

::cDirSif:=f01_transform_dbf_name(cDir)


cDirSif := ::cDirSif

return cPom


method TDb:setDirKum(cDir)
local cPom

// dosadasnja vrijednost varijable
cPom:=::cDirKum
cDir:=alltrim(cDir)


::cDirKum:=f01_transform_dbf_name(cDir)


cDirKum:=::cDirKum
cDirRad:=::cDirKum


SET(_SET_DEFAULT,trim(cDir))

return cPom


method TDb:setSigmaBD(cDir)
local cPom
// dosadasnja vrijednost varijable
cPom:=::cSigmaBD
cDir:=alltrim(cDir)
if (gKonvertPath=="D")
	KonvertPath(@cDir)
endif
::cSigmaBD:=f01_transform_dbf_name(cDir)
return cPom



method TDb:setUser(cUser)
local cPom
// dosadasnja vrijednost varijable
cPom:=::cUser
::cUser:=cUser
return cPom


method TDb:setPassword(nPassword)
local nPom
// dosadasnja vrijednost varijable
nPom:=::nPassword
::nPassword:=nPassword
return nPom

method TDb:setGroup1(nGroup)
local nPom
// dosadasnja vrijednost varijable
nPom:=::nGroup1
::nGroup1:=nGroup
return nPom


method TDb:setGroup2(nGroup)
local nPom
// dosadasnja vrijednost varijable
nPom:=::nGroup2
::nGroup2:=nGroup
return nPom


method TDb:setGroup3(nGroup)
local nPom
// dosadasnja vrijednost varijable
nPom:=::nGroup3
::nGroup3:=nGroup
return nPom



method TDb:mInstall()

local i, cPom, aLst
private nOldIzbor
private opc:={}
private opcexe:={}
private Izbor

::lAdmin:=.t.

@ 4,5 SAY""
AADD(opc,"1. pregled korisnika modula - sifre, prioriteti  ")
AADD(opcexe,{|| KorPreg() })
AADD(opc,"2. promjena šifre")
AADD(opcexe, {|| KorLoz() })
AADD(opc,"3. reindex")
AADD(opcexe, {|| f01_reindex() })
AADD(opc,"4. pakovanje")
AADD(opcexe, {|| Pakuj() })

AADD(opc,"5. briši pa ponovo kreiraj indekse")
AADD(opcexe, {|| f01_brisi_index_pakuj_dbf()})

AADD(opc,"6. modifikacija struktura")
AADD(opcexe, {|| f01_runmods()})
AADD(opc,"7. instalacija fajlova")
AADD(opcexe, {|| f01_cre_params(), ::kreiraj()  })
AADD(opc,"8. registracija modula")
AADD(opcexe, {|| cCurDir:=curdir(), goModul:sregg(), goModul:quit() } )
AADD(opc,"9. promjena oznake sezone u radnom podrucju")
AADD(opcexe, {|| PromOzSez() })
AADD(opc,"A. otpakuj iz tmp arhive")
AADD(opcexe, {|| UzmiIzArj() })
AADD(opc,"S. servisne komande")
AADD(opcexe,{|| ServisKom() })
AADD(opc,"-------------------")
AADD(opcexe, nil)
AADD(opc,"X. arhiviraj na diskete")
AADD(opcexe, {|| StaviUArj() })
AADD(opc,"Y. konverzija znakova u bazama")

	AADD(opcexe, {|| ::konvZn() })

AADD(opc,"F. ostale funkcije")

	AADD(opcexe, {|| ::ostalef() })

AADD(opc,"-------------------")
AADD(opcexe, nil)

AADD(opc,"T. tech info")
AADD(opcexe, {|| TechInfo() })
AADD(opc,"U. uklanjanje sezona")
AADD(opcexe, {|| BrisiSezonu() })

if System .or. (KLevel='0' .and. Right(trim(ImeKorisn),1)='1')
  AADD(opc,"S. sistem zastite")
  AADD(opcexe, {|| Secur() })
endif

Izbor:=1
Menu_SC("imod")

::lAdmin:=.f.
return



/*  TDB::vratiSez()
 *   vrati stanje podataka iz sezone u radno podrucje
 */

*void TDB::vratiSez()
method vratiSez(oDatabase)


if ::oApp:limitKLicence(AL_GOLD)
	return
endif


::lAdmin:=.t.

if !empty(::cSezonDir) // sezonski podaci
  Msg("Opcija nedostupna pri radu u sezonskom podrucju")
  closeret
endif

close all
if !sifra_za_koristenje_opcije("SIGMASEZ")
  return
endif

Box(,3,50)
  cDN:="N"
  set cursor on
  cSezona:=padr(goModul:oDataBase:cSezona,4)
  @ m_x+1, m_y+2 SAY "U radno podrucje vratiti stanje iz sezone" GET cSezona pict "9999" valid StSezona(cSezona)
  @ m_x+3, m_y+2 SAY "Zelite nastaviti operaciju D/N" GET cDN pict "@!" valid cdn $ "DN"
  read

BoxC()
if lastkey()==K_ESC  .or. cDN="N"
    return
endif


// privatni
fnul:=.f.

private aFilesP:={}
private aFilesS:={}
private aFilesK:={}
close all
if !PocSkSez()
  closeret
endif


cOldSezona:=goModul:oDataBase:cSezona

// ako je "0000" ne pravi backup backupa
if cSezona<>"0000"
 ::skloniSezonu("0000",.f.,.t.)   // backup
 // jos jednom za svaki slucaj bezuvjetno
 // .t. - bez price
else
 cOldSezona:=cSezona
endif

if Pitanje(,"Prenos RADNO PODRUCJE -> SEZONA "+goModul:oDataBase:cSezona+" ?","D")=="D"
    	// .f. - iz radnog u sezonski
	::skloniSezonu(goModul:oDataBase:cSezona,.f.,.t.)
endif


if Pitanje(,"Prenos: SEZONA "+cSezona+" -> RADNO PODRUCJE ?","D")=="D"
    ::skloniSezonu(cSezona,.t.,.t.)
    // .t. - iz sezonskog u radni
    // bezuvjetno

     Otkljucaj(KUMPATH+"KPARAMS.DBF")
     O_KPARAMS
     private cSection:="1",cHistory:=" "; aHistory:={}
     if cSezona=="0000"
     	// iz backupa vracam, pa cu ja odrediti sezonu
         gSezona:=goModul:oDataBase:cSezona
         Box(,4,60)
           set escape off
           set confirm on
           @ m_x+1,m_y+2 SAY "Podaci vraceni iz backup - 0000 sezone"
           @ m_x+2,m_y+2 SAY "Povrat je izvrsen u radno podrucje."
           @ m_x+4,m_y+2 SAY "Odredite sezonu podataka u radnom podrucju:" GET gSezona pict "9999" valid gSezona<>"0000"
           read
           set escape on
           set confirm off
         BoxC()
         goModul:oDataBase:cSezona:=gSezona
     else
      goModul:oDataBase:cSezona:=cSezona
     endif
     Wpar("se",goModul:oDataBase:cSezona,gSQL=="D")
     select kparams; use
     IspisiSez()
endif
KrajskSez(cOldSezona)

::lAdmin:=.f.
return



*string KParams_se;
/* ingroup params
 *  var: KParams_se
 *   Oznaka sezone za podatke u KUMPATH-u, tekucoj lokaciji podataka
 *  biljeska: Ako stoji 2002, znaci da se u ovom direktoriju nalaze podaci iz 2002 godine
 */

*string KParams_rp;
/* ingroup params
 *  var: KParams_rp
 *   Oznaka sezone sa kojom se trenutno radi
 *  biljeska: Ako stoji 2001, znaci da se trenutno radi sa podacima iz 2001 godine
 */



/*  TDB::loadSezonaRadimUSezona()
 *   ucitaj ::cSezona, ::cRadimUSezona iz tabele parametara
 */

*void TDB::loadSezonaRadimUSezona()
method loadSezonaRadimUSezona()
local cPom


O_KPARAMS
public gSezona:="    "


private cSection:="1"
private cHistory:=" "
private aHistory:={}

cPom:=::cSezona
Rpar("se",@cPom)
::cSezona:=cPom
SELECT kparams
USE

// nije upisana sezona tekuce godine, ovo se desava samo pri inicijalizaciji baze
if EMPTY(::cSezona)
    	::cSezona:=STR(YEAR(DATE()),4)
	::cSezonDir:=""
	::saveSezona(::cSezona)
endif

O_KPARAMS
cPom:=::cRadimUSezona
Rpar("rp",@cPom)
SELECT kparams
USE

if cPom==nil
	cPom:="RADP"
	::saveRadimUSezona(cPom)
endif

::cRadimUSezona:=cPom

if (::cRadimUSezona==::cSezona .or. ::cRadimUSezona=="RADP")
	::cSezonDir:=""
else
	::cSezonDir:=SLASH+::cRadimUSezona
endif

return


*void TDB:saveSezona(string cValue)

method saveSezona(cValue)

#ifdef CLIP
	? "save sezona ..."
#endif
O_KPARAMS
private cSection:="1"
private cHistory:=" "
private aHistory:={}
Wpar("se", cValue, gSQL=="D")
select kparams
use
return


*void TDB:saveRadimUSezona(string cValue)

method saveRadimUSezona(cValue)
O_KPARAMS
private cSection:="1"
private cHistory:=" "
private aHistory:={}
if gSql != "D"
	Wpar("rp", cValue, .f.)
else
	if TYPE("gSQLSite")=="N" .and. VALTYPE(goModul:cSqlLogBase)=="C"
		Wpar("rp", cValue, .t.)
	endif
	//if gSQL=="D"
	//	MsgBeep("Nije definisan gSQLSite ?")
	//endif
endif
SELECT kparams
USE
return



/*  *void TDB::radiUSezonskomPodrucju()
 *   Na osnovu ::cRadimUSezona odredi database: Sezonsko ili Radno podrucje
 *  biljeska: centralno pitanje je "Prosli put ste radili u sezonskom podrucju ... Nastaviti ?"
 */

*void TDB::radiUSezonskomPodrucju(bool lForceRadno)

method radiUSezonskomPodrucju(lForceRadno)

::setIfNil()
if (lForceRadno==nil)
	lForceRadno:=.f.
endif

if ::cRadimUSezona<>"RADP"
	if ( lForceRadno .or. Pitanje(,"Prosli put ste radili u sezonskom podrucju " +::cRadimUSezona+". Nastaviti ?","D")=="N")
		//ipak se prebaci na radno podrucje
		::cRadimUSezona:="RADP"
		::saveRadimUSezona(::cRadimUSezona)
		::cSezonDir:=""

	else
       		f01_cre_params()
		::logAgain(::cRadimUSezona,.t.)
	endif
else
		::cRadimUSezona:="RADP"
		::saveRadimUSezona(::cRadimUSezona)
endif



*void TDB:setIfNil()

method setIfNil()
if (::oDesktop==nil)
	::oDesktop:=goModul:oDesktop
endif
if (::oApp==nil)
	::oApp:=goModul
endif
return


*void TDB:scan()

method scan()

return
