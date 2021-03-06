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

/*  KonvZnWin(cTekst, cWinKonv)
 *   Konverzija znakova u stringu
 *   cTekst - tekst
 *   cWinKonv - tip konverzije
 */
function KonvZnWin(cTekst, cWinKonv)
local aNiz:={}
local i
local j

AADD(aNiz, {"[",BOX_CHAR_USPRAVNO,chr(138),"S",BOX_CHAR_USPRAVNO})
AADD(aNiz, {"{",BOX_CHAR_USPRAVNO,chr(154),"s",BOX_CHAR_USPRAVNO})
AADD(aNiz, {"}",BOX_CHAR_USPRAVNO,chr(230),"c",BOX_CHAR_USPRAVNO})
AADD(aNiz, {"]",BOX_CHAR_USPRAVNO, chr(198),"C",BOX_CHAR_USPRAVNO})
AADD(aNiz, {"^",BOX_CHAR_USPRAVNO, chr(200),"C",BOX_CHAR_USPRAVNO})
AADD(aNiz, {"~",BOX_CHAR_USPRAVNO,chr(232),"c",BOX_CHAR_USPRAVNO})
AADD(aNiz, {"`",BOX_CHAR_USPRAVNO,chr(158),"z",BOX_CHAR_USPRAVNO})
AADD(aNiz, {"@",BOX_CHAR_USPRAVNO,chr(142),"Z",BOX_CHAR_USPRAVNO})
AADD(aNiz, {"|",BOX_CHAR_USPRAVNO, chr(240),"dj",BOX_CHAR_USPRAVNO})
AADD(aNiz, {"\",BOX_CHAR_USPRAVNO, chr(208),"DJ",BOX_CHAR_USPRAVNO})

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






function KSto7(cStr)
  cStr:=strtran(cStr,BOX_CHAR_USPRAVNO,"{")
  cStr:=strtran(cStr,BOX_CHAR_USPRAVNO,"|")
  cStr:=strtran(cStr,BOX_CHAR_USPRAVNO,"`")
  cStr:=strtran(cStr,BOX_CHAR_USPRAVNO,"~")
  cStr:=strtran(cStr,BOX_CHAR_USPRAVNO,"}")
  cStr:=strtran(cStr,BOX_CHAR_USPRAVNO,"[")
  cStr:=strtran(cStr,BOX_CHAR_USPRAVNO,"\")
  cStr:=strtran(cStr,BOX_CHAR_USPRAVNO,"@")
  cStr:=strtran(cStr,BOX_CHAR_USPRAVNO,"^")
  cStr:=strtran(cStr,BOX_CHAR_USPRAVNO,"]")
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
 SetPxLat(ASC("["),BOX_CHAR_USPRAVNO  )
 SetPxLat(ASC("{"),BOX_CHAR_USPRAVNO  )
 SetPxLat(ASC("}"),BOX_CHAR_USPRAVNO  )
 SetPxLat(ASC("]"),BOX_CHAR_USPRAVNO  )
 SetPxLat(ASC("^"),BOX_CHAR_USPRAVNO )
 SetPxLat(ASC("~"),BOX_CHAR_USPRAVNO )
 SetPxLat(ASC("`"),BOX_CHAR_USPRAVNO )
 SetPxLat(ASC("@"),BOX_CHAR_USPRAVNO )
 SetPxLat(ASC("|"),BOX_CHAR_USPRAVNO )
 SetPxLat(ASC("\"),BOX_CHAR_USPRAVNO )
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
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"["  )
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"{"  )
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"}"  )
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"]"  )
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"^" )
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"~" )
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"`" )
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"@" )
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"|" )
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"\" )
elseif left(gPTKonv,1)=="4"
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"S"  )
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"s"  )
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"c"  )
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"C"  )
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"C" )
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"c" )
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"z" )
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"Z" )
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"d" )
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"D" )
endif

if fGraf<>NIL .or. substr(gPtkonv,2,1)="1"
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"-" )
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),":" )
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"+" )
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"+" )
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"+" )
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"+" )
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"=" )
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"+" )
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"+" )
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"+" )
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"+" )
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"+" )
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"+" )
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"+" )
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),":" )
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"+" )
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"+" )

 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"+" )
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"+" )
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"+" )
 SetPxLat(ASC(BOX_CHAR_USPRAVNO),"+" )
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
   cInput:=STRTRAN(cInput,BOX_CHAR_USPRAVNO,"S"+CHR(255))
   cInput:=STRTRAN(cInput,BOX_CHAR_USPRAVNO,"D"+CHR(255))
   cInput:=STRTRAN(cInput,BOX_CHAR_USPRAVNO,"C"+CHR(254))
   cInput:=STRTRAN(cInput,BOX_CHAR_USPRAVNO,"C"+CHR(255))
   cInput:=STRTRAN(cInput,BOX_CHAR_USPRAVNO,"Z"+CHR(255))
   cInput:=STRTRAN(cInput,BOX_CHAR_USPRAVNO,"s"+CHR(255))
   cInput:=STRTRAN(cInput,BOX_CHAR_USPRAVNO,"d"+CHR(255))
   cInput:=STRTRAN(cInput,BOX_CHAR_USPRAVNO,"c"+CHR(254))
   cInput:=STRTRAN(cInput,BOX_CHAR_USPRAVNO,"c"+CHR(255))
   cInput:=STRTRAN(cInput,BOX_CHAR_USPRAVNO,"z"+CHR(255))
 ENDIF
RETURN PADR(cInput,100)
