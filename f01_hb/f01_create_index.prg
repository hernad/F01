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
f01_reindex(.t.)

return


function f01_prepakuj(aNStru)

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



static function Every()

//nSlogova=nSlogova+1
//@ 24, 10 SAY "Slogova: "+STR(nSlogova*100)
//OL_Yield()
//return
