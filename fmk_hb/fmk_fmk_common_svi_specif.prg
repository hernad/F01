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


#include "sc.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software
 * ----------------------------------------------------------------
 *
 */

/* defgroup Planika Specificne nadogradnje za korisnika Planika
 *  @{
 *  @}
 */

/* defgroup Vindija  Specificne nadogradnje za korisnika Vindija
 *  @{
 *  @}
 */

/* defgroup Tvin Specificne nadogradnje za korisnika Tvin
 *  @{
 *  @}
 */

 /* defgroup Niagara Specificne nadogradnje za korisnika Niagara
 *  @{
 *  @}
 */

/* defgroup Tigra  Specificne nadogradnje za korisnika Tigra
 *  @{
 *  @}
 */


/* defgroup Merkomerc  Specificne nadogradnje za korisnika Merkomerc
 *  @{
 *  @}
 */


/* defgroup RamaGlas  Specificne nadogradnje za korisnika RamaGlas
 *  @{
 *  @}
 */


/* defgroup LdFin  Specificnost - kontiranje obracuna LD
 *  @{
 *  @}
 */


/* defgroup Rudnik  Specificne nadogradnje za korisnika Rudnik
 *  @{
 *  @}
 */


/* defgroup SigmaCom Specificne nadogradnje za korisnika SigmaCom
 *  @{
 *  @}
 */


/* defgroup Jerry  Specificne nadogradnje za korisnika Jerry Trade
 *  @{
 *  @}
 */


static lTvin

static lNiagara

static lPlanika


static lPlNS

static lTigra

static lSigmaCom

static lRobaGroup

static lJerry

static lVindija

static lRudnik

static lZips

static lTrgom

static lKonsig


static lStampa

static lUgovori

static lRamaGlas

static lLdFin

static lMupZeDo

static lFakultet

static lDomZdr

static lRabati

static lTehnoprom

function IsPlanika()

return lPlanika


function SetPlanika(lValue)

lPlanika:=lValue


/* ingroup Planika
 *   IsPlNS()
 *  return: True - Ako je ini parametar PlNS podesen na "D", u suprotnom False
 *  \sa IzFmkIni_KumPath_FMK_PlNS
 */
function IsPlNS()

return lPlNS


function SetPlNS(lValue)

lPlNS:=lValue


function IsRobaGroup()

return lRobaGroup


function SetRobaGroup(lValue)

lRobaGroup:=lValue



function IsVindija()

return lVindija


function SetVindija(lValue)

lVindija:=lValue


function IsZips()

return lZips


function SetZips(lValue)

lZips:=lValue


function IsTvin()

return lTvin


function SetTvin(lValue)

lTvin:=lValue



function IsNiagara()

return lNiagara


function SetNiagara(lValue)

lNiagara:=lValue



function IsTrgom()

return lTrgom


function SetTrgom(lValue)

lTrgom:=lValue


function IsRudnik()

return lRudnik


function SetRudnik(lValue)

lRudnik:=lValue


function IsKonsig()

return lKonsig


function SetKonsig(lValue)

lKonsig:=lValue


function IsStampa()

return lStampa


function SetStampa(lValue)

lStampa:=lValue


function IsUgovori()

return lUgovori


function SetUgovori(lValue)

lUgovori:=lValue


function IsRabati()

return lRabati


function SetRabati(lValue)

lRabati:=lValue



function IsRamaGlas()

return lRamaGlas


function IsLdFin()

return lLdFin


function SetRamaGlas(lValue)

lRamaGlas:=lValue



function SetLdFin(lValue)

lLdFin:=lValue




function IsJerry()

return lJerry


function SetJerry(lValue)

lJerry:=lValue



function IsMupZeDo()

return lMupZeDo


function SetMupZeDo(lValue)

lMupZeDo:=lValue



function IsFakultet()

return lFakultet


function SetFakultet(lValue)

lFakultet:=lValue



function IsDomZdr()

return lDomZdr


function SetDomZdr(lValue)

lDomZdr:=lValue



function IsTehnoprom()

return lTehnoprom


function SetTehnoprom(lValue)

lTehnoprom:=lValue



/*  SetSpecifVars()
 *   Setuje globalne varijable za specificne korisnike
 */

function SetSpecifVars()

if IzFmkIni("FMK","Tvin","N",KUMPATH)=="D"
	SetTvin(.t.)
else
	SetTvin(.f.)
endif

if IzFmkIni("FMK","Niagara","N",KUMPATH)=="D"
	SetNiagara(.t.)
else
	SetNiagara(.f.)
endif

if IzFmkIni("FMK","Planika","N",KUMPATH)=="D"
	SetPlanika(.t.)
else
	SetPlanika(.f.)
endif

if IzFmkIni("FMK","DomZdr","N",KUMPATH)=="D"
	SetDomZdr(.t.)
else
	SetDomZdr(.f.)
endif

if IzFmkIni("FMK","RobaGroup","N",KUMPATH)=="D"
	SetRobaGroup(.t.)
else
	SetRobaGroup(.f.)
endif

if IzFmkIni("FMK","Tehnoprom","N",KUMPATH)=="D"
	SetTehnoprom(.t.)
else
	SetTehnoprom(.f.)
endif

if IzFmkIni("FMK","PlNS","N",KUMPATH)=="D"
	SetPlNS(.t.)
else
	SetPlNS(.f.)
endif

if IzFmkIni("FMK","Vindija","N",KUMPATH)=="D"
	SetVindija(.t.)
else
	SetVindija(.f.)
endif

if IzFmkIni("FMK","Zips","N",KUMPATH)=="D"
	SetZips(.t.)
else
	SetZips(.f.)
endif

if IzFmkIni("FMK","Trgom","N",KUMPATH)=="D"
	SetTrgom(.t.)
else
	SetTrgom(.f.)
endif

if IzFmkIni("FMK","Rudnik","N",KUMPATH)=="D"
	SetRudnik(.t.)
else
	SetRudnik(.f.)
endif

if IzFmkIni("FMK","Konsignacija","N",KUMPATH)=="D"
	SetKonsig(.t.)
else
	SetKonsig(.f.)
endif

if IzFmkIni("FMK","Stampa","N",KUMPATH)=="D"
	SetStampa(.t.)
else
	SetStampa(.f.)
endif

if IzFmkIni("FMK","Ugovori","N",KUMPATH)=="D"
	SetUgovori(.t.)
else
	SetUgovori(.f.)
endif


if IzFmkIni("FMK","Jerry","N",KUMPATH)=="D"
	SetJerry(.t.)
else
	SetJerry(.f.)
endif


if IzFmkIni("FMK","RamaGlas","N",KUMPATH)=="D"
	SetRamaGlas(.t.)
else
	SetRamaGlas(.f.)
endif


if IzFmkIni("FMK","LdFin","N",KUMPATH)=="D"
	SetLdFin(.t.)
else
	SetLdFin(.f.)
endif

if IzFmkIni("FMK","MUPZEDO","N",KUMPATH)=="D"
	SetMupZeDo(.t.)
else
	SetMupZeDo(.f.)
endif

if IzFmkIni("FMK","Fakultet","N",KUMPATH)=="D"
	SetFakultet(.t.)
else
	SetFakultet(.f.)
endif

if IzFmkIni("FMK","Rabati","N",KUMPATH)=="D"
	SetRabati(.t.)
else
	SetRabati(.f.)
endif


return
