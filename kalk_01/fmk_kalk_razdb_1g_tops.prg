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

// ----------------------------------------------------------
// generacija tops dokumenata na osnovu kalk dokumenata
// ----------------------------------------------------------
function GenTops()
LOCAL nExpr:=0, nExpr2:=0, cPom:=""
local fBKempty:=.f.

if gTops<>"0 " .and. Pitanje(,"Izgenerisati datoteku KATOPS","N")=="D"
  O_ROBA;  O_KONCIJ; O_PRIPR
  select pripr; go top
  aDbf:={}
  AADD(aDBF,{"IDFIRMA","C",2,0})
  AADD(aDBF,{"BRDOK","C",8,0})
  AADD(aDBF,{"IDVD","C",2,0})
  AADD(aDBF,{"DATDOK","D",8,0})
  AADD(aDBF,{"IDKONTO","C",7,0})
  AADD(aDBF,{"IDKONTO2","C",7,0})
  AADD(aDBF,{"IDPARTNER","C",6,0})
  AADD(aDBF,{"IDPOS","C",2,0})
  AADD(aDBF,{"IDROBA","C",10,0})
  AADD(aDBF,{"kolicina","N",13,4})
  AADD(aDBF,{"MPC","N",13,4})
  AADD(aDBF,{"MPC2","N",13,4})
  AADD(aDBF,{"NAZIV","C",250,0})
  AADD(aDBF,{"IDTARIFA","C",6,0})
  AADD(aDBF,{"JMJ","C",3,0})

  if roba->(fieldpos("K1"))<>0
   AADD(aDBF,{"K1","C",4,0})
   AADD(aDBF,{"K2","C",4,0})
  endif

  if roba->(fieldpos("K7"))<>0
    AADD(aDBF,{"K7","C",1,0})
    AADD(aDBF,{"K8","C",2,0})
    AADD(aDBF,{"K9","C",3,0})
  endif

  if roba->(fieldpos("N1"))<>0
    AADD(aDBF,{"N1","N",12,2})
    AADD(aDBF, {"N2","N",12,2})
  endif
  if roba->(fieldpos("BARKOD"))<>0
    AADD(aDBF, {"BARKOD","C",13,0})
  endif

  cTOPSDBF:=trim(gTopsDEST)+"KATOPS.DBF"
  dbcreate2(cTOPSDBF,aDBf)
  USE_EXCLUSIVE(cTopsDBF)   NEW   alias katops
  select pripr
  nRbr:=0
  dDatdok:=date()
  aIdPos:={}   // matrica pos mjesta koje kaci kalkulacija
  fBkEmpty := .f. // upozori ako je empty barkod
  do while !eof()
    select roba; hseek pripr->idroba
    select koncij; seek trim(pripr->pkonto)
    select katops
    append blank
    if ASCAN(aIdPos,{|x| x==koncij->idprodmjes}) == 0
       AADD(aIdPos,koncij->idprodmjes)
    endif
    dDatDok:=pripr->datdok
    replace idfirma with gFirma
    replace idvd with pripr->idvd
    replace idpos with koncij->idprodmjes
    replace datdok with pripr->datdok
    replace idkonto with pripr->idkonto
    replace idkonto2 with pripr->idkonto2
    replace idpartner with pripr->idpartner
    replace idroba with pripr->idroba
    replace kolicina with pripr->kolicina
    replace mpc with pripr->mpcsapp
    replace naziv with roba->naz
    replace idtarifa with pripr->idtarifa
    replace jmj with roba->jmj
    replace brdok with pripr->brdok

    if roba->(fieldpos("K1"))<>0
        replace K1 with roba->k1, K2 with roba->K2
    endif
    if roba->(fieldpos("K7"))<>0
        replace K7 with roba->k7, K8 with roba->K8,;
                K9 with roba->k9
    endif

    if roba->(fieldpos("N1"))<>0
        replace N1 with roba->N1, N2 with roba->N2
    endif

    if roba->(fieldpos("BARKOD"))<>0
        replace BARKOD with roba->BARKOD
        if empty(roba->barkod)
           fBKEmpty:=.t.
        endif
    endif

    if pripr->pu_i=="3"  // radi se o nivelaciji
        replace mpc with pripr->fcj            ,;   // mpc - stara cijena
                mpc2 with pripr->(fcj+mpcsapp)      // mpc2 - nova cijena
    endif

    if pripr->pu_i=="5"
      replace kolicina with -kolicina
    endif
    if empty(koncij->idprodmjes)
       replace idpos with gTops
    endif

    cPom:=TRIM(pripr->idvd)+TRIM(pripr->idroba)+;
          TRIM(IF(!empty(koncij->idprodmjes),koncij->idprodmjes,gTops))+;
          TRIM(roba->naz)+TRIM(pripr->idtarifa)+TRIM(roba->jmj)

    nExpr  += LEN(cPom)
    nExpr2 += NUMAT("A",cPom)

    ++nRbr
    select pripr
    skip
  enddo

  select katops
  use
  if gModemVeza=="D"
     for i0:=1 to len(aIdPos)  // prodji kroz sve IdPos - baci
                               // datoteku o svim kasama
       cDestMod:=RIGHT(DToS(dDatDok),4)  // 1998 1105  - 11 mjesec, 05 dan
       cDestMod:=TRIM(aIdPos[i0])+"\KT"+cDestMod
       // cDestMod ==  "1\KT1117"
       USE_EXCLUSIVE(cTopsDBF) new alias ntops
       fIzadji:=.f.
       // donja for-next pelja otvara baze i , ako postoje, gleda da li je
       // u njih pohranjen isti dokument
       for i:=1 to 41
       	  bErr:=ERRORBLOCK({|o| MyErrH(o)})
          begin sequence
            if i>21
              USE_EXCLUSIVE( strtran(cTopsDbf,"KATOPS",cDestMod+"U"+CHR(i%21+64)) ) new alias otops
            else
              USE_EXCLUSIVE( strtran(cTopsDbf,"KATOPS",cDestMod+chr(64+i)) ) new alias otops
            endif
            // OD A-C

            if ( ntops->brdok == otops->brdok )
                fIzadji:=.t.
            endif
            use
          recover
            fizadji:=.t.
            // ako ne prodje use onda je prazno
          end sequence
          bErr:=ERRORBLOCK(bErr)
          if fizadji
             exit
          endif
       next
       if i>21
         cDestMod:=cDestMod+"U"+chr(64+i%21)+"."
       else
         cDestMod:=cDestMod+chr(64+i)+"."
       endif
       select ntops
       use
       cDestMod:=strtran(cTopsDbf,"KATOPS.",cDestMod)
       filecopy(cTopsDBF,cDestMod)
       cDestMod:=strtran(cDestMod,".DBF",".TXT")
       filecopy(PRIVPATH+"outf.txt",cDestMod)
       cDestMod:=strtran(cDestMod,".TXT",".DBF")
       MsgBeep("Datoteka "+cDestMod+"je izgenerisana#Broj stavki "+str(nRbr,4))
     next //***for i0:=1 to len(aIdPos)  // prodji kroz sve IdPos - baci
  else
   aPom:=IntegDbf(cTopsDBF)
   NapraviCRC( trim(gTopsDEST)+"CRCKT.CRC" , aPom[1] , aPom[2] )
   if fBKempty
     MsgBeep("Neki artikli imaju nepopunjeno polje barkoda ???")
   endif
   MsgBeep("Formirana je datoteka KATOPS.DBF za prenos u TOPS !#Broj stavki: "+str(nRbr))

  endif
  select pripr
endif

closeret
return



/*  SifKalkTops()
 *   Prenos sifrarnika iz KALK u TOPS
 */

function SifKalkTops()

private cDirZip:= DRIVE_ROOT_PATH + "SIGMA" + SLASH + "PREN" + SLASH

O_PARAMS

private cSection:="T"
private cHistory:=" "
private aHistory:={}

Params1()
 
cDirZip:=Padr(cDirZip,30)

Box(,5,70)
	@ m_x+1,m_y+2 SAY "Destinacija arhive sifrarnika:"
   	@ m_x+2,m_y+2 GET  cDirZip
   	read
BoxC()

cDirzip:=trim(cDirZip)

if Params2()
	WPar("Dz",cDirZip)
endif

select params
use

save screen to cScr
cls

select (F_ROBA)
use

private cKomLin:="zip " + cDirZip + "ROBKNJ.ZIP " + SIFPATH + "Roba.DBF" + " " + SIFPATH + "Roba.FPT"

run &cKomLin
cKomlin:="dir " + cDirzip + "robknj.zip"

run &cKomLin

cKomlin:="pause"
run &cKomLin

restore screen from cScr

return



/*  Mnu_GenKaTOPS()
 *   Menij generacije tops dokumenata na osnovu KALK-a
 */

function Mnu_GenKaTOPS()

private cIDFirma:=gFirma
private cIDTipDokumenta:="80"
private cBrojDokumenta:=SPACE(8)

Box(,5,40)
	set cursor on
	@ m_x+1,m_y+2 SAY "Generacija KALK -> TOPS: "
	@ m_x+2,m_y+2 SAY "-------------------------------"
	@ m_x+4,m_y+2 SAY "Dokument: " GET cIDFirma
	@ m_x+4,m_y+16 SAY " - " GET cIDTipDokumenta VALID !Empty(cIDTipDokumenta)
	@ m_x+4,m_y+23 SAY " - " GET cBrojDokumenta VALID !Empty(cBrojDokumenta)
	read
	ESC_BCR
BoxC()


if CheckKALKDokument(cIDFirma, cIDTipDokumenta, cBrojDokumenta)
	if (gTops <> "0 " .and. Pitanje(,"Izgenerisati datoteku prenosa?","N")=="D")
		GenTopsAzur(cIDFirma, cIDTipDokumenta, cBrojDokumenta)
	endif
endif

return



/*  CheckKALKDokument(idfirma, tipdokumenta, brojdokumenta)
 *   Provjerava da li dokument uopste postoji!
 *   idfirma - id firme
 *   tipdokumenta - tip dokumenta
 *   brojdokumenta - broj dokumenta
 *  return: .t. ako dok postoji, .f. ako ne postoji!!!
 */

function CheckKALKDokument(idfirma, tipdokumenta, brojdokumenta)

O_DOKS

select doks
hseek idfirma+tipdokumenta+brojdokumenta
if !Found()
	MsgBeep("Dokument " + TRIM(idfirma) + "-" + TRIM(tipdokumenta) + "-" + TRIM(brojdokumenta) + " ne postoji !!!")
	return .f.
else
	return .t.
endif



/*  GenTopsAzur(idfirma, idtipdokumenta, brojdokumenta)
 *   Generacija kalk->tops na osnovu azuriranih kalkulacija
 *   idfirma - id firme
 *   idtipdokumenta - tip dokumenta
 *   brojdokumenta - broj dokumenta
 */

function GenTopsAzur(idfirma, idtipdokumenta, brojdokumenta)

local nExpr:=0
local nExpr2:=0
local cPom:=""
local lBKempty:=.f.
local cFilter

O_ROBA
O_KONCIJ
O_PRIPR
O_KALK


cTOPSDBF:=TRIM(gTopsDEST)+"KATOPS.DBF"

// kreiraj DBF za prenos
CreDBKaTOPS()

select kalk
go top

seek idfirma+idtipdokumenta+brojdokumenta

nRbr:=0
dDatDok:=DATE()
aIdPos:={}   // matrica pos mjesta koje kaci kalkulacija
lBkEmpty := .f. // upozori ako je empty barkod

nIznos:=0

Box(,4,50)
@ m_x+1,m_y+2 SAY "Generisem " + TRIM(idtipdokumenta) + "-" + TRIM(brojdokumenta) + " ..."

do while !eof() .and. (field->idfirma==idfirma) .and. (field->idvd=idtipdokumenta) .and. (field->brdok==brojdokumenta)
	select roba
	hseek kalk->idroba
    	select koncij
	seek trim(kalk->pkonto)
    	select katops
    	append blank

	if ASCAN(aIdPos,{|x| x==koncij->idprodmjes}) == 0
       		AADD(aIdPos,koncij->idprodmjes)
    	endif

	dDatDok:=kalk->datdok

	replace idfirma with gFirma
	replace idvd with kalk->idvd
	replace idpos with koncij->idprodmjes
	replace datdok with dDatDok
	replace idkonto with kalk->idkonto
	replace idkonto2 with kalk->idkonto2
	replace idpartner with kalk->idpartner
     	replace idroba with kalk->idroba
     	replace kolicina with kalk->kolicina
     	replace mpc with kalk->mpcsapp
     	replace naziv with roba->naz
     	replace idtarifa with kalk->idtarifa
     	replace jmj with roba->jmj
     	replace brdok with kalk->brdok

    	if roba->(fieldpos("K1"))<>0
        	replace K1 with roba->k1
		replace K2 with roba->K2
    	endif

	if roba->(fieldpos("K7"))<>0
        	replace K7 with roba->k7
		replace K8 with roba->K8
                replace K9 with roba->k9
    	endif

    	if roba->(fieldpos("N1"))<>0
        	replace N1 with roba->N1
		replace N2 with roba->N2
    	endif

    	if roba->(fieldpos("BARKOD"))<>0
        	replace BARKOD with roba->BARKOD
        	if empty(roba->barkod)
           		lBKEmpty:=.t.
        	endif
    	endif

    	if kalk->pu_i=="3"  // radi se o nivelaciji
        	replace mpc with kalk->fcj   // mpc - stara cijena
                replace mpc2 with kalk->(fcj+mpcsapp)      // mpc2 - nova cijena
    	endif

    	if pripr->pu_i=="5"
      		replace kolicina with -kolicina
    	endif

    	if empty(koncij->idprodmjes)
       		replace idpos with gTops
    	endif

    	cPom:=TRIM(kalk->idvd) + TRIM(kalk->idroba) + TRIM(IF(!empty(koncij->idprodmjes),koncij->idprodmjes,gTops)) + TRIM(roba->naz) + TRIM(kalk->idtarifa) + TRIM(roba->jmj)

    	nExpr  += LEN(cPom)
    	nExpr2 += NUMAT("A",cPom)

	nIznos += katops->mpc * katops->kolicina

    	++nRbr

	@ m_x+3,m_y+2 SAY "Broj stavki: " + TRIM(STR(nRbr))

	select kalk
    	skip
enddo

BoxC()

if (nRbr>0)
	START PRINT CRET
	?
	? SPACE(2) + "Prenos KALK -> TOPS na dan: ", Date()
	? SPACE(2) + "---------------------------------------"
	?
	? SPACE(2) + "Dokument: " + idfirma + "-" + idtipdokumenta + "-" + brojdokumenta
	?
	? SPACE(2) + "Broj prenesenih stavki: " + ALLTRIM(STR(nRbr))
	? SPACE(2) + "Saldo: " + ALLTRIM(STR(nIznos, 10, 2))
	?
	ENDPRINT
endif

select katops
use

if (gModemVeza=="D")
	for i0:=1 to len(aIdPos)  // prodji kroz sve IdPos - baci
        	// datoteku o svim kasama
       		cDestMod:=RIGHT(DToS(dDatDok),4)
		// 1998 1105  - 11 mjesec, 05 dan
       		cDestMod:=TRIM(aIdPos[i0]) + "\KT" + cDestMod
       		// cDestMod ==  "1\KT1117"
       		USE_EXCLUSIVE(cTopsDBF) new alias ntops
       		fIzadji:=.f.
       		// donja for-next pelja otvara baze
		// i ako postoje, gleda da li je
       		// u njih pohranjen isti dokument
       		for i:=1 to 41
			bErr:=ERRORBLOCK({|o| MyErrH(o)})
          		begin sequence
            		if i>21
              			USE_EXCLUSIVE( strtran(cTopsDbf,"KATOPS",cDestMod+"U"+CHR(i%21+64)) ) new alias otops
            		else
              			USE_EXCLUSIVE( strtran(cTopsDbf,"KATOPS",cDestMod+chr(64+i)) ) new alias otops
            		endif
            		// OD A-C
            		if ntops->brdok==otops->brdok
              			fIzadji:=.t.
            		endif

			use
          		recover
            		fizadji:=.t.
            		// ako ne prodje use onda je prazno
          		end sequence
          		bErr:=ERRORBLOCK(bErr)
          		if fIzadji
             			exit
          		endif
       		next

		if i>21
        		cDestMod:=cDestMod+"U"+CHR(64+i%21)+"."
       		else
         		cDestMod:=cDestMod+CHR(64+i)+"."
       		endif

		select ntops
       		use

		cDestMod:=StrTran(cTopsDbf,"KATOPS.",cDestMod)
       		FileCopy(cTopsDBF,cDestMod)
       		cDestMod:=StrTran(cDestMod,".DBF",".TXT")
       		FileCopy(PRIVPATH+"outf.txt",cDestMod)
       		cDestMod:=StrTran(cDestMod,".TXT",".DBF")
       		MsgBeep("Datoteka "+cDestMod+"je izgenerisana#Broj stavki "+str(nRbr,4))
	next //***for i0:=1 to len(aIdPos)  // prodji kroz sve IdPos - baci
else
	aPom:=IntegDbf(cTopsDBF)
	NapraviCRC( trim(gTopsDEST)+"CRCKT.CRC" , aPom[1] , aPom[2] )
	if lBKempty
		MsgBeep("Neki artikli imaju nepopunjeno polje barkoda ???")
	endif

	MsgBeep("Formirana je datoteka KATOPS.DBF za prenos u TOPS !#Broj stavki: "+str(nRbr))
endif

select kalk

//set filter to

closeret
return



/*  CreDBKaTOPS()
 *   Kreira datoteku prenosa
 */
function CreDBKaTOPS()


MsgO("Kreiram tabelu prenosa")

aDbf:={}
AADD(aDBF,{"IDFIRMA","C",2,0})
AADD(aDBF,{"BRDOK","C",8,0})
AADD(aDBF,{"IDVD","C",2,0})
AADD(aDBF,{"IDPOS","C",2,0})
AADD(aDBF,{"DATDOK","D",8,0})
AADD(aDBF,{"IDKONTO","C",7,0})
AADD(aDBF,{"IDKONTO2","C",7,0})
AADD(aDBF,{"IDPARTNER","C",6,0})
AADD(aDBF,{"IDROBA","C",10,0})
AADD(aDBF,{"kolicina","N",13,4})
AADD(aDBF,{"MPC","N",13,4})
AADD(aDBF,{"MPC2","N",13,4})
AADD(aDBF,{"NAZIV","C",40,0})
AADD(aDBF,{"IDTARIFA","C",6,0})
AADD(aDBF,{"JMJ","C",3,0})

if roba->(fieldpos("K1"))<>0
	AADD(aDBF,{"K1","C",4,0})
	AADD(aDBF,{"K2","C",4,0})
endif

if roba->(fieldpos("K7"))<>0
	AADD(aDBF,{"K7","C",1,0})
	AADD(aDBF,{"K8","C",2,0})
	AADD(aDBF,{"K9","C",3,0})
endif

if roba->(fieldpos("N1"))<>0
	AADD(aDBF,{"N1","N",12,2})
	AADD(aDBF, {"N2","N",12,2})
endif

if roba->(fieldpos("BARKOD"))<>0
	AADD(aDBF, {"BARKOD","C",13,0})
endif

cTOPSDBF:=trim(gTopsDEST)+"KATOPS.DBF"
dbcreate2(cTOPSDBF,aDBf)
USE_EXCLUSIVE(cTopsDBF)   NEW   alias katops

MsgC()

return
