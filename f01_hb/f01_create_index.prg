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

#include "fileio.ch"

static OID_ASK:="0"

static nSlogova:=0


function f01_create_index(cImeInd, cKljuc, cImeDbf, fSilent)

local bErr
local cFulDbf
local nH
local cImeCDXIz
local cImeCDX
local nOrder
local nPos

private cTag
private cKljuciz

close all

cImeDbf:=ToUnix(cImeDbf)
if fSilent==nil
    fSilent:=.f.
endif

if AT(SLASH,cImeDbf)==0  // onda se radi o kumulativnoj datoteci
     cImeCdx :=  alltrim(cDirRad) + SLASH + f01_ime_dbf_cdx( cImeDbf )
else
     cImeCdx := f01_ime_dbf_cdx(cImeDbf)
endif

nPom:=RAT(SLASH,cImeInd)
cTag:=""
cKljucIz:=cKljuc
if nPom<>0
   cTag:=substr(cImeInd,nPom+1)
else
   cTag:=cImeInd
endif

fPostoji:=.t.

#ifndef PROBA
 bErr:=ERRORBLOCK({|o| MyErrH(o)})
 BEGIN SEQUENCE
#endif

	select (F_TMP)
	USE_EXCLUSIVE (cImeDbf)

	if USED()
		nPos:=FIELDPOS("BRISANO")
		//nPos == nil ako nije otvoren DBF

		if nPos==0
			f01_add_field_brisano(cImeDbf)
		endif

		nOrder:=ORDNUMBER("BRISAN")
		cOrdKey:=ORDKEY("BRISAN")
		if (nOrder==0)  .or. !(LEFT(cOrdKey,8)=="BRISANO")
			PRIVATE cPomKey:="BRISANO"
			PRIVATE cPomTag:="BRISAN"
			cImeCDX:=STRTRAN(cImeCDX,"."+INDEXEXT,"")
			INDEX ON &cPomKey  TAG (cPomTag) TO (cImeCDX)
		endif

		if (gSQL=="D")
			f01_fill_oid(cImeDbf, cImeCDX)
			if (fieldpos("_OID_")<>0)
				//tabela ima _OID_ polje
				nOrder:=ORDNUMBER("_OID_")
				if (nOrder==0)
					cPomKey:="_OID_"
					index on &cPomKey TAG "_OID_"  TO (cImeCDX)
				endif
			endif
		endif


		if (gSQL=="D")
			if fieldpos("_SITE_")<>0
				nOrder:=ORDNUMBER("_SITE_")
				cOrdKey:=ORDKEY("_SITE_")
				if norder=0  .or. !(left(cOrdKey,6)="_SITE_")
					index on _SITE_  TAG _SITE_
				endif
			endif
		endif

		nOrder:=ORDNUMBER(cTag)
		cOrdKey:=ordkey(cTag)
		select (F_TMP)
		use
	else
		MsgBeep("Nisam uspio otvoriti "+cImeDbf)
		fPostoji:=.f.
	endif

#ifndef PROBA
RECOVER
	fPostoji:=.f.
END SEQUENCE
bErr:=ERRORBLOCK(bErr)
#endif

if !fPostoji
	// nisam uspio otvoriti, znaci ne mogu ni kreirati indexs ..
	return
endif

#ifdef __PLATFORM__UNIX
   cImeCdx := ChangeExt( cImeCdx, "CDX", "cdx" )

if !File( cImeCdx )  .or. nOrder==0  .or. UPPER(cOrdKey)<>UPPER(cKljuc)


     cFulDbf:=cImeDbf
     if right(cFulDbf,4)<>"."+DBFEXT
       cFulDbf:=trim(cFulDbf)+"."+DBFEXT
       if at(SLASH, cFulDbf)==0  // onda se radi o kumulativnoj datoteci
          cFulDbf:=alltrim(cDirRad)+SLASH+cFulDbf
       endif
     endif

     if  !IsFreeForReading(cFulDBF,fSilent)
	 return .f.
     endif

	DBUSEAREA (.f., nil, cImeDbf, nil, .t. )


   if !fSilent
    MsgO("Baza:"+cImeDbf+", Kreiram index-tag :"+cImeInd+"#"+ExFileName(cImeCdx))
   endif

    nPom:=RAT(SLASH,cImeInd)
    private cTag:=""
    private cKljuciz:=cKljuc
    if nPom<>0
     cTag:=substr(cImeInd,nPom)
    else
     cTag:=cImeInd
    endif


     if (LEFT(cTag,4)=="ID_J" .and. fieldpos("ID_J")==0) .or. (cTag=="_M1_" .and. FIELDPOS("_M1_")==0)
        // da ne bi ispao ovo stavljam !!
     else
	cImeCdx:=strtran(cImeCdx,"."+INDEXEXT,"")
	INDEX ON &cKljucIz  TAG (cTag)  TO (cImeCdx)
	USE
     endif

   if !fSilent
    MsgC()
   endif
    use
  endif

return


function IsFreeForReading(cFulDBF, fSilent)

local nH

nH:=FOPEN(cFulDbf,2)  // za citanje i pisanje
if FERROR()<>0
      Beep(2)
      if !fSilent
       Msg("Ne mogu otvoriti "+cFulDBF+" - vjerovatno ga neko koristi#"+;
              "na mrezi. Ponovite operaciju kada ovo rijesite !")
       return .f.
      else
        cls
        ? "Ne mogu otvoriti",cFulDbf
        DO WHILE NEXTKEY()==0; OL_YIELD(); ENDDO
        INKEY()
      endif
      FCLOSE(nH)
      return .t.
endif
FCLOSE(nH)
return .t.



function MyErrHt(o)

BREAK o
return .t.



function Reindex(ff)


*  REINDEXiranje DBF-ova

local nDbf
local lZakljucana

IF (ff<>nil .and. ff==.t.) .or. if( !gAppSrv,  Pitanje("","Reindeksirati DB (D/N)","N")=="D", .t.)

if !gAppSrv
	Box("xx",1,56,.f.,"Vrsi se reindeksiranje DB-a ")
else
	? "Vrsi se reindex tabela..."
endif

// Provjeri da li je sezona zakljucana
lZakljucana := .f.

if gReadOnly
	lZakljucana := .t.
	// otkljucaj sezonu
	SetWOnly(.t.)
endif
//

close all

// CDX verzija
set exclusive on
for nDbf:=1 to 250
	if !gAppSrv
       		@ m_x+1,m_y+2 SAY SPACE(54)
   	endif
	#ifndef PROBA
		bErr:=ERRORBLOCK({|o| MyErrHt(o)})
		BEGIN SEQUENCE
		// sprijeciti ispadanje kad je neko vec otvorio bazu
		goModul:oDatabase:obaza(nDbf)
		RECOVER
		Beep(2)
		if !gAppSrv
			@ m_x+1,m_y+2 SAY "Ne mogu administrirati "+DbfName(nDbf)+" / "+alltrim(str(nDbf))
		else
			? "Ne mogu administrirati: " + DBFName(nDbf) + " / " + ALLTRIM(STR(nDBF))
		endif

		if !EMPTY(DBFName(nDbf))
			// ovaj modul "zna" za ovu tabelu, ali postoji problem
			inkey(3)
		endif
		END SEQUENCE
		bErr:=ERRORBLOCK(bErr)
	#else
		goModul:oDatabase:obaza(nDbf)
		if !gAppSrv
			@ m_x+1,m_y+2  SAY SPACE(40)
		endif
	#endif

	DBSELECTArea (nDbf)
	if !gAppSrv
		@ m_x+1,m_y+2 SAY "Reindeksiram: " + ALIAS(nDBF)
	else
		? "Reindexiram: " + ALIAS(nDBF)
	endif

	if used()
		beep(1)
		ordsetfocus(0)
		nSlogova:=0
		REINDEX
		//EVAL { || Every() } EVERY 150
		use
	endif

   next
   set exclusive off
   if !gAppSrv
   	BoxC()
   endif
endif

if lZakljucana == .t.
	SetROnly(.t.)
endif

closeret
return nil



function Pakuj(ff)

local nDbfff,cDN

IF (ff<>nil .and. ff==.t.) .or. (cDN:=Pitanje("pp","Prepakovati bazu (D/N/L)","N")) $ "DL"


 Box("xx",1,50,.f.,"Fizicko brisanje zapisa iz baze koji su markirani za brisanje")
   @ m_x+1,m_y+1 say "Pakuje se DB:"


close all

set exclusive on
for nDbfff:=1 to 250
   goModul:oDatabase:obaza(nDbfff)
   if used()
    @ m_x+1,m_y+30 SAY SPACE(12)
    @ m_x+1,m_y+30 SAY ALIAS()
    set deleted off
    nOrder:=ORDNUMBER("BRISAN")

    // bezuslovno trazi deleted()
    if cDN=="L"
     locate for deleted()
    else
     if norder<>0
      set order to TAG "BRISAN"

      // nadji izbrisan zapis
      seek "1"
     endif
    endif
    if nOrder=0 .or. found()
      BEEP(1)
      ordsetfocus(0)
      @ m_x+1,m_y+36 SAY reccount() pict "999999"
      __DBPACK()
      @ m_x+1,m_y+42 SAY "+"
      @ m_x+1,m_y+44 SAY reccount() pict "99999"
      set deleted on
    else
      @ m_x+1,m_y+36 SAY space(4)
      @ m_x+1,m_y+42 SAY "-"
      @ m_x+1,m_y+44 SAY space(4)
    endif
    inkey(0.4)


    set deleted on
    use
   endif //used
next
BoxC()

endif

closeret
return



function BrisiPAk(fSilent)

if fSilent==nil
  fSilent:=.f.
endif

#ifdef proba
if !gAppSrv
  Msgbeep("Brisipak procedura...")
endif
#endif

if fSilent .or. if(!gAppSrv, Pitanje(,"Izbrisati "+INDEXEXT+" fajlove pa ih nanovo kreirati","N")=="D", .t.)
   close all
   cMask:="*."+INDEXEXT
   if !gAppSrv
   	cScr:=""
   	save screen to cScr
   	cls
	if fSilent .or. pitanje(,"Indeksi iz privatnog direktorija ?","D")=="D"
     		DelSve(cMask,trim(cDirPriv))
     		inkey(1)
   	endif
   	if fSilent .or.  pitanje(,"Indeksi iz direktorija kumulativa ?","N")=="D"
     		DelSve(cMask,trim(cDirRad))
     		inkey(1)
   	endif
   	if fSilent .or.  pitanje(,"Indeksi iz direktorija sifrarnika ?","N")=="D"
    		DelSve(cMask,trim(cDirSif))
     		inkey(1)
   	endif
   	if fSilent .or.  pitanje(,"Indeksi iz tekuceg direktorija?","N")=="D"
     		DelSve(cMask,".")
     		inkey(1)
   	endif
   	if fSilent .or. pitanje(,"Indeksi iz korjenog direktorija?","N")=="D"
     		DelSve(cMask,SLASH)
     		inkey(1)
   	endif
   else
   	? "Brisem sve indexe..."
	? "Radni dir: " + TRIM(cDirRad)
	DelSve(cMask, TRIM(cDirRad))
	DelSve(cMask, TRIM(cDirSif))
	DelSve(cMask, TRIM(cDirPriv))
   endif
   if !gAppSrv
   	restore screen from cScr
   endif
   CreParams()
   close all
   if gAppSrv
   	? "Kreiram sve indexe ...."
	? "Radni dir: " + cDirRad
   endif
   goModul:oDatabase:kreiraj()
   if gAppSrv
   	? "Kreirao index-e...."
   endif
endif

return



/*  AppModS(cCHSName)
 *   Modifikacija struktura APPSRV rezim rada
 *   cCHSName - ime chs fajla (npr. FIN)
 */
function AppModS(cCHSName)

local cCHSFile:=""

if !gAppSrv
	return
endif

// ako nije zadan parametar uzmi osnovnu modifikaciju

if cCHSName==NIL .or. EMPTY(cChsName)
	cCHSFile:=(EXEPATH + gModul + ".CHS")
else
	cCHSFile:=(EXEPATH + cCHSName + ".CHS")
endif


? "Modifikacija struktura " + cCHSFile
? "Pricekajte koji trenutak ..."

cEXT:=SLASH + "*." + INDEXEXT

? "Modifikacija u privatnom direktoriju ..."
f01_modstru(TRIM(cCHSFile), trim(goModul:oDataBase:cDirPriv))

? "Modifikacija u direktoriju sifrarnika ..."
f01_modstru(TRIM(cCHSFile),trim(goModul:oDataBase:cDirSif))

? "Modifikacija u direktoriju kumulativa ..."
f01_modstru(TRIM(cCHSFile),trim(goModul:oDataBase:cDirKum))


// kreiraj, reindex
close all
goModul:oDatabase:kreiraj()
Reindex(.t.)

return




function Rjec(cLin)

local cOp,nPos

nPos:=aT(" ",cLin)
if nPos==0 .and. !empty(cLin) // zadnje polje
	cOp:=alltrim(clin)
	cLin:=""
	return cOp
endif

cOp:=alltrim(left(cLin,nPos-1))
cLin:=right(cLin,len(cLin)-nPos)
cLin:=alltrim(cLin)
return cOp



function Prepakuj(aNStru)

local i,aPom
aPom:={}
for i:=1 to len(aNStru)
  if aNStru[i]<>nil
   aadd(aPom,aNStru[i])
  endif
next
aNStru:=aClone(aPom)
return nil


/***
*  FGets( <nHandle>, [<nLines>], [<nLineLength>], [<cDelim>] ) --> cBuffer
*  Read one or more lines from a text file
*
*/

function FGets(nHandle, nLines, nLineLength, cDelim)

return FReadLn(nHandle, nLines, nLineLength, cDelim)



/*  FileTop(nHandle)
 *   Position the file pointer to the first byte in a binary file and return the new file position (i.e., 0).
 *  return: nPos
 *
 */

function FileTop(nHandle)

return FSEEK(nHandle, 0)


/*  FileBottom(nHandle)
 *  Position the file pointer to the last byte in a binary file and return the new file position
 *  nHandle - handle fajla
 * return: nPos - lokacija
 */

function FileBottom(nHandle)

return FSEEK(nHandle, 0, FS_END)




function SetgaSDBFs

PUBLIC gaSDBFs:={ ;
 {F_GPARAMS  , "GPARAMS",  P_ROOTPATH },;
 {F_GPARAMSP , "GPARAMS",  P_PRIVPATH},;
 {F_PARAMS   , "PARAMS"  , P_PRIVPATH},;
 {F_KORISN   , "KORISN"  , P_TEKPATH },;
 {F_MPARAMS  , "MPARAMS" , P_TEKPATH },;
 {F_KPARAMS  , "KPARAMS" , P_KUMPATH },;
 {F_SECUR    , "SECUR"   , P_KUMPATH },;
 {F_ADRES    , "ADRES"   , P_SIFPATH },;
 {F_SIFK     , "SIFK"    , P_SIFPATH },;
 {F_SIFV     , "SIFV"    , P_SIFPATH  },;
 {F_TMP      , "TMP"     , P_PRIVPATH},;
 {F_SQLPAR   , "SQLPAR"  , P_KUMSQLPATH};
}
return


/*  ImdDBFCDX(cIme)
 *   Mjenja DBF u indeksnu extenziju

 *  suban     -> suban.CDX
 *  suban.DBF -> suban.CDX

 */

function f01_ime_dbf_cdx(cIme)

cIme:=trim(strtran(ToUnix(cIme),"."+DBFEXT,"."+INDEXEXT))
if right(cIme,4)<>"."+INDEXEXT
	cIme:=cIme+"."+INDEXEXT
endif
return  cIme


static function Every()

//nSlogova=nSlogova+1
//@ 24, 10 SAY "Slogova: "+STR(nSlogova*100)
//OL_Yield()
//return
