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


#include "SC.CH"

/*!  KonvZnWin(cTekst, cWinKonv)
 *   Konverzija znakova u stringu
 *   cTekst - tekst
 *   cWinKonv - tip konverzije
 */
function KonvZnWin(cTekst, cWinKonv)
local aNiz:={}
local i
local j

AADD(aNiz, {"[","�",chr(138),"S","�"})
AADD(aNiz, {"{","�",chr(154),"s","�"})
AADD(aNiz, {"}","�",chr(230),"c","�"})
AADD(aNiz, {"]","�", chr(198),"C","�"})
AADD(aNiz, {"^","�", chr(200),"C","�"})
AADD(aNiz, {"~","�",chr(232),"c","�"})
AADD(aNiz, {"`","�",chr(158),"z","�"})
AADD(aNiz, {"@","�",chr(142),"Z","�"})
AADD(aNiz, {"|","�", chr(240),"dj","�"})
AADD(aNiz, {"\","�", chr(208),"DJ","�"})

if cWinKonv = NIL
	cWinKonv:=IzFmkIni("DelphiRb","Konverzija","5")
endif

i:=1
j:=1

if cWinKonv=="1"
	i:=1
	j:=2
elseif cWinKonv=="2"
        // 7->A
	i:=1
	j:=4  
elseif cWinKonv=="3"
        // 852->7
	i:=2
	j:=1   
elseif cWinKonv=="4"
        // 852->A
	i:=2
	j:=4 
elseif cWinKonv=="5"
        // 852->win1250
	i:=2
	j:=3  
elseif cWinKonv=="6"
        // 7->win1250
	i:=1
	j:=3 
elseif cWinKonv=="8"
	i:=3
	j:=5
endif

if i<>j
	AEVAL(aNiz,{|x| cTekst:=STRTRAN(cTekst,x[i],x[j])})
endif

return cTekst




/*!  StrKZN(cInput, cIz, cU)
 *   Vrsi zamjenu cInputa
 */
 
function StrKZN( cInput, cIz, cU, aFrom, aTo )
local a852:={"�","�","�","�","�","�","�","�","�","�"}
local a437:={"[","\","^","]","@","{","|","~","}","`"}
local aEng:={"S","D","C","C","Z","s","d","c","c","z"}
local aEngB:={"SS","DJ","CH","CC","ZZ","ss","dj","ch","cc","zz"}
local aWin:= {"�", "�", "�", "�", "�", "�", "�", "�", "�", "�"}
local aUTF:= {"&#352;", "&#272;", "&#268;", "&#262;", "&#381;", "&#353;", ;
	"&#273;", "&#269;", "&#263;", "&#382;"}
local i := 0
local aIz := {}
local aU := {}
local lTakeArr := .t.

if aFrom == nil .and. aTo == nil
	lTakeArr := .f.
endif

if cIz=="7"
	aIz := a437
elseif cIz=="8"
	aIz := a852
elseif (goModul:oDataBase:cName=="LD" .and. cIz=="B")
	aIz := aEngB
elseif (cIz=="W")
	aIz := aWin
elseif (cIz=="U")
	aIz := aUTF
elseif (cIz=="E")
	aIz := aEng
else
	aIz := aEng
endif


if cU=="7"
	aU:=a437
elseif cU=="8"
	aU:=a852
elseif cU=="U"
	aU:=aUTF
elseif cU=="W"
	aU:=aWin
elseif cU=="E"
	aU:=aEng
elseif goModul:oDataBase:cName=="LD" .and. cU=="B"
	aU:=aEngB
else
	aU:=aEng
endif

// uzmi ponudjene iz parametara
if lTakeArr == .t.
	aIz := aFrom
	aU := aTo
endif

cPocStanjeSif := cInput

for i:=1 to LEN( aU )

	if (goModul:oDataBase:cName=="LD" .and. i==5)
		if AT("D@", cInput)<>0
			cInput:=STRTRAN(cInput, "D@", "DZ")
		elseif AT("D|", cInput)<>0
			cInput:=STRTRAN(cInput, "D|", "DZ")
		endif
	endif
	
	if (goModul:oDataBase:cName=="LD" .and. i==10)
		if AT("d�", cInput)<>0
			cInput:=STRTRAN(cInput, "d�", "dz")
		elseif AT("d`", cInput)<>0
			cInput:=STRTRAN(cInput, "d`", "dz")
		endif
	endif

	cInput:=STRTRAN( cInput, aIz[i], aU[i] )
next

if (cU == "B" .and. LEN(ALLTRIM(cInput)) > 6)
	// provjeri da li ovaj par postoji u nizu
	nPos:=ASCAN(aKonvZN, {|aVal| aVal[1] == cPocStanjeSif})
	if nPos > 0
		cRet:=aKonvZN[nPos, 2]
	else
		cNoviId:=SPACE(6)
		Box(,3,25)
		@ 1+m_x, 2+m_y SAY "Unesi novi ID za sifru: "
		@ 2+m_x, 2+m_y SAY "Stari ID: " + cPocStanjeSif
		@ 3+m_x, 2+m_y SAY "Novi ID: " GET cNoviID
		read
		BoxC()
		AADD(aKonvZN, {cPocStanjeSif, cNoviId})
		cRet:=cNoviID
	endif
else
	cRet := cInput
endif

cKrajnjeStanjeSif:=cRet

return cRet


// ---------------------------------------------------
// konverzija u utf-8
// ---------------------------------------------------
function strkznutf8( cInput, cIz )
local aWin := {} 
local aUTF := {}
local a852 := {}
local aTmp := {}

// windows kodovi...
AADD( aWin, "&" ) 
AADD( aWin, "�" )
AADD( aWin, "�" )
AADD( aWin, "�" )
AADD( aWin, "�" )
AADD( aWin, "�" )
AADD( aWin, "�" )
AADD( aWin, "�" )
AADD( aWin, "�" )
AADD( aWin, "�" )
AADD( aWin, "�" )
AADD( aWin, "!" ) 
AADD( aWin, '"' ) 
AADD( aWin, "'" ) 
AADD( aWin, "," ) 
AADD( aWin, "-" ) 
AADD( aWin, "." ) 
AADD( aWin, "\" ) 
AADD( aWin, "/" ) 
AADD( aWin, "=" ) 
AADD( aWin, "(" ) 
AADD( aWin, ")" ) 
AADD( aWin, "[" ) 
AADD( aWin, "]" ) 
AADD( aWin, "{" ) 
AADD( aWin, "}" ) 
AADD( aWin, "<" ) 
AADD( aWin, ">" ) 

// pandan 852 je...
AADD( a852, "&" ) // feature
AADD( a852, "�" ) // SS
AADD( a852, "�" ) // DJ
AADD( a852, "�" ) // CC
AADD( a852, "�" ) // CH
AADD( a852, "�" ) // ZZ
AADD( a852, "�" ) // ss
AADD( a852, "�" ) // dj
AADD( a852, "�" ) // cc
AADD( a852, "�" ) // ch
AADD( a852, "�" ) // zz
AADD( a852, "!" ) // uzvicnik
AADD( a852, '"' ) // navodnici
AADD( a852, "'" ) // jedan navodnik
AADD( a852, "," ) // zarez
AADD( a852, "-" ) // minus
AADD( a852, "." ) // tacka
AADD( a852, "\" ) // b.slash
AADD( a852, "/" ) // slash
AADD( a852, "=" ) // jedanko
AADD( a852, "(" ) // otv.zagrada
AADD( a852, ")" ) // zatv.zagrada
AADD( a852, "[" ) // otv.ugl.zagrada
AADD( a852, "]" ) // zatv.ugl.zagrada
AADD( a852, "{" ) // otv.vit.zagrada
AADD( a852, "}" ) // zatv.vit.zagrada
AADD( a852, "<" ) // manje
AADD( a852, ">" ) // vece
// itd...

// pandan UTF je...
AADD( aUTF, "&#38;" ) 
AADD( aUTF, "&#352;" )
AADD( aUTF, "&#272;" )
AADD( aUTF, "&#268;" )
AADD( aUTF, "&#262;" )
AADD( aUTF, "&#381;" )
AADD( aUTF, "&#353;" )
AADD( aUTF, "&#273;" )
AADD( aUTF, "&#269;" )
AADD( aUTF, "&#263;" )
AADD( aUTF, "&#382;" )
AADD( aUTF, "&#33;" ) 
AADD( aUTF, "&quot;" ) 
AADD( aUTF, "&#39;" ) 
AADD( aUTF, "&#44;" ) 
AADD( aUTF, "&#45;" ) 
AADD( aUTF, "&#46;" ) 
//AADD( aUTF, "&#92;" ) 
AADD( aUTF, "\" ) 
//AADD( aUTF, "&#97;" ) 
AADD( aUTF, "/" ) 
AADD( aUTF, "&#8215;" ) 
AADD( aUTF, "&#40;" ) 
AADD( aUTF, "&#41;" ) 
AADD( aUTF, "&#91;" ) 
AADD( aUTF, "&#93;" ) 
AADD( aUTF, "&#123;" ) 
AADD( aUTF, "&#125;" ) 
AADD( aUTF, "&#60;" ) 
AADD( aUTF, "&#62;" ) 

if cIz == "8"
	aTmp := a852
elseif cIz == "W"
	aTmp := aWin
endif

cRet := strkzn( cInput, cIz, "U", aTmp, aUtf )

return cRet




function KSto7(cStr)
  cStr:=strtran(cStr,"�","{")
  cStr:=strtran(cStr,"�","|")
  cStr:=strtran(cStr,"�","`")
  cStr:=strtran(cStr,"�","~")
  cStr:=strtran(cStr,"�","}")
  cStr:=strtran(cStr,"�","[")
  cStr:=strtran(cStr,"�","\")
  cStr:=strtran(cStr,"�","@")
  cStr:=strtran(cStr,"�","^")
  cStr:=strtran(cStr,"�","]")
return cStr

* ako je gPTKonv == 0   nema konverzije
* ako je gPTKonv == 1   7bih - 852
* ako je gPTKonv == 2   7bih - Americki
* ako je gPTKonv == 3   852 -  7bih
* ako je gPTKonv == 4   852 -  Americki

function KonvTable(fGraf)
if left(gPTKonv,1)=="0"
 SetPxLat()
elseif left(gPTKonv,1)=="1"
 SetPxLat(ASC("["),"�"  )
 SetPxLat(ASC("{"),"�"  )
 SetPxLat(ASC("}"),"�"  )
 SetPxLat(ASC("]"),"�"  )
 SetPxLat(ASC("^"),"�" )
 SetPxLat(ASC("~"),"�" )
 SetPxLat(ASC("`"),"�" )
 SetPxLat(ASC("@"),"�" )
 SetPxLat(ASC("|"),"�" )
 SetPxLat(ASC("\"),"�" )
elseif left(gPTKonv,1)=="2"
 SetPxLat(ASC("["),"S"  )
 SetPxLat(ASC("{"),"s"  )
 SetPxLat(ASC("}"),"c"  )
 SetPxLat(ASC("]"),"C"  )
 SetPxLat(ASC("^"),"C" )
 SetPxLat(ASC("~"),"c" )
 SetPxLat(ASC("`"),"z" )
 SetPxLat(ASC("@"),"Z" )
 SetPxLat(ASC("|"),"d" )
 SetPxLat(ASC("\"),"D" )
elseif left(gPTKonv,1)=="3"
 SetPxLat(ASC("�"),"["  )
 SetPxLat(ASC("�"),"{"  )
 SetPxLat(ASC("�"),"}"  )
 SetPxLat(ASC("�"),"]"  )
 SetPxLat(ASC("�"),"^" )
 SetPxLat(ASC("�"),"~" )
 SetPxLat(ASC("�"),"`" )
 SetPxLat(ASC("�"),"@" )
 SetPxLat(ASC("�"),"|" )
 SetPxLat(ASC("�"),"\" )
elseif left(gPTKonv,1)=="4"
 SetPxLat(ASC("�"),"S"  )
 SetPxLat(ASC("�"),"s"  )
 SetPxLat(ASC("�"),"c"  )
 SetPxLat(ASC("�"),"C"  )
 SetPxLat(ASC("�"),"C" )
 SetPxLat(ASC("�"),"c" )
 SetPxLat(ASC("�"),"z" )
 SetPxLat(ASC("�"),"Z" )
 SetPxLat(ASC("�"),"d" )
 SetPxLat(ASC("�"),"D" )
endif

if fGraf<>NIL .or. substr(gPtkonv,2,1)="1"
 SetPxLat(ASC("�"),"-" )
 SetPxLat(ASC("�"),":" )
 SetPxLat(ASC("�"),"+" )
 SetPxLat(ASC("�"),"+" )
 SetPxLat(ASC("�"),"+" )
 SetPxLat(ASC("�"),"+" )
 SetPxLat(ASC("�"),"=" )
 SetPxLat(ASC("�"),"+" )
 SetPxLat(ASC("�"),"+" )
 SetPxLat(ASC("�"),"+" )
 SetPxLat(ASC("�"),"+" )
 SetPxLat(ASC("�"),"+" )
 SetPxLat(ASC("�"),"+" )
 SetPxLat(ASC("�"),"+" )
 SetPxLat(ASC("�"),":" )
 SetPxLat(ASC("�"),"+" )
 SetPxLat(ASC("�"),"+" )

 SetPxLat(ASC("�"),"+" )
 SetPxLat(ASC("�"),"+" )
 SetPxLat(ASC("�"),"+" )
 SetPxLat(ASC("�"),"+" )
endif



FUNCTION BHSORT(cInput)
 IF gKodnaS=="7"
   cInput:=STRTRAN(cInput,"[","S"+CHR(255))
   cInput:=STRTRAN(cInput,"\","D"+CHR(255))
   cInput:=STRTRAN(cInput,"^","C"+CHR(254))
   cInput:=STRTRAN(cInput,"]","C"+CHR(255))
   cInput:=STRTRAN(cInput,"@","Z"+CHR(255))
   cInput:=STRTRAN(cInput,"{","s"+CHR(255))
   cInput:=STRTRAN(cInput,"|","d"+CHR(255))
   cInput:=STRTRAN(cInput,"~","c"+CHR(254))
   cInput:=STRTRAN(cInput,"}","c"+CHR(255))
   cInput:=STRTRAN(cInput,"`","z"+CHR(255))
 ELSE  // "8"
   cInput:=STRTRAN(cInput,"�","S"+CHR(255))
   cInput:=STRTRAN(cInput,"�","D"+CHR(255))
   cInput:=STRTRAN(cInput,"�","C"+CHR(254))
   cInput:=STRTRAN(cInput,"�","C"+CHR(255))
   cInput:=STRTRAN(cInput,"�","Z"+CHR(255))
   cInput:=STRTRAN(cInput,"�","s"+CHR(255))
   cInput:=STRTRAN(cInput,"�","d"+CHR(255))
   cInput:=STRTRAN(cInput,"�","c"+CHR(254))
   cInput:=STRTRAN(cInput,"�","c"+CHR(255))
   cInput:=STRTRAN(cInput,"�","z"+CHR(255))
 ENDIF
RETURN PADR(cInput,100)

