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


#include "fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/dok/1g/stdrtf21.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.8 $
 * $Log: stdrtf21.prg,v $
 * Revision 1.8  2003/01/19 23:44:17  ernad
 * test network speed (sa), korekcija bl.lnk
 *
 * Revision 1.7  2002/09/16 09:01:28  mirsad
 * dokumentovanje INI parametara
 *
 * Revision 1.6  2002/07/05 13:11:04  mirsad
 * no message
 *
 * Revision 1.5  2002/07/04 08:34:19  mirsad
 * dokumentovanje ini parametara
 *
 * Revision 1.4  2002/06/21 12:51:22  sasa
 * no message
 *
 * Revision 1.3  2002/06/21 12:28:23  sasa
 * no message
 *
 * Revision 1.2  2002/06/18 13:01:05  sasa
 * no message
 *
 * Revision 1.1.1.1  2002/06/17 18:30:18  ernad
 * no message
 *
 *
 */


/*! \file fmk/fakt/dok/1g/stdrtf21.prg
 *  \brief Ko zna koja varijanta stampe u RTF formatu
 */


/*! \ingroup ini
  * \var *string FmkIni_KumPath_RTF_PartnerFS
  * \brief Velicina fonta za ispis partnera u rtf-fakturi
  * \param 28 - default vrijednost
  */
*string FmkIni_KumPath_RTF_PartnerFS;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_RTF_PartnerSB
  * \brief Format necega?! Nisam mogao testirati jer nemam instaliran MS Word!
  * \param 90 - default vrijednost
  */
*string FmkIni_KumPath_RTF_PartnerSB;



/*! \fn StdRtf21()
 *  \brief Stampa faktura u RTF formatu varijanta 2 1
 *  \param cImeF
 *  \param cIdFirma
 *  \param cIdTipDok
 *  \param cBrDok
 */
 
function StdRtf21()
*{
parameters cImeF,cIdFirma,cIdTipDok,cBrDok
local cTxt1,cTxt2,aMemo,nH,cPomoc:="", coutf:=""
local i,ii,ImeKol:={}, nRedova, fPrvaStr,cNPom
local cTi,nRab,nUk2:=nRab2:=0
Private nStr, nUk:=nUPorez:=0, nZaokr

nRedova:=30  // dodatnih redova na drugoj strani
fPrvaStr:=.t.

if (nH:=fcreate(cImeF))==-1
  Beep(4)
  Msg("Fajl "+cimeF+" se vec koristi !",6)
  return
endif
fclose(nH)

if cIdFirma<>NIL
 O_Edit(.t.)
else
 O_Edit()
endif


// ovaj dio se ponavlja pa lazno je reci ali 100 puta
// ima ga u svakom fajlu

cTI:="1"  // tip izvjestaja  1,2
O_PARAMS
private cSection:="1",cHistory:=" "; aHistory:={}
RPar("c1",@cTI)
select params; use

#define NL  chr(13)+chr(10)
#define CO1 8
#define CO2 16
#define CO3 IF(gVarRF=="3",33.5,45)
#define CO4 IF(gVarRF=="3",20,23)  // co3+co4  == sirina naziva
#define CO5 20
#define CO6 10       // JMJ
#define CO7 14
#define CO8 10.5
#define CO9 IF(gVarRF=="3",14,10.5)
#define COA IF(gVarRF=="3",10.5,18)
IF gVarRF=="3"
  #define COB 18
ENDIF

select PRIPR
if cidfirma=NIL  // poziva se faktura iz pripreme
 IF gNovine=="D"
   FilterPrNovine()
 ENDIF
 cIdTipdok:=idtipdok;cIdFirma:=IdFirma;cBrDok:=BrDok
endif
SEEK cidfirma+cidtipdok+cBrdok
NFOUND CRET

MsgO("Priprema rtf fajla")

aDbf:={ {"POR","C",10,0},;
          {"IZNOS","N",17,8} ;
         }
dbcreate2(PRIVPATH+"por",aDbf)
O_POR   // select 95
index  on BRISANO TAG "BRISAN"
index  on POR  TAG "1" ;  set order to tag "1"
select pripr

cTxt1:=cTxt2:=cTxt3a:=cTxt3b:=cTxt3c:=""
_BrOtp:=space(8); _DatOtp:=ctod(""); _BrNar:=space(8); _DatPl:=ctod("")

if val(podbr)=0  .and. val(rbr)==1
   aMemo:=ParsMemo(txt)
   if len(aMemo)>0
     cTxt1:=padr(aMemo[1],40)
   endif
   cTxt2:=aMemo[2]
   cTxt3a:=aMemo[3]
   cTxt3b:=aMemo[4]
   cTxt3c:=aMemo[5]
   cTxt2:=ToRtfStr( strtran(ctxt2,"�"+Chr(10),"") )
   if len(aMemo)>=9
    _BrOtp:=aMemo[6]; _DatOtp:=ctod(aMemo[7]); _BrNar:=amemo[8]; _DatPl:=ctod(aMemo[9])
   endif
else
  Beep(2)
  MsgC()
  Msg("Prva stavka mora biti  '1.'  ili '1 ' !",4)
  return
endif

InitFW()

nTxt2:=len(WWSjeciStr(cTxt2,10,173))


set printer to (cImeF)
set printer on
set console off

WWInit0()
WWFontTbl()
WWStyleTbl()
WWInit1()
// WWSetMarg(20,95,15,20)
IF gVarRF=="1"
  WWSetMarg(20,110,15,20)
ELSE
  WWSetMarg(20,95,15,20)
ENDIF
WWSetPage("A4","P")

if gVarF=="3"
 ? "{\*\do\dobxpage\dobypage\dodhgt12292\dpline\dpptx0\dppty0\dpptx0\dppty432\dpx1152\dpy4608\dpxsize1\dpysize433\dplinesolid\dplinecor0\dplinecog0\dplinecob0\dplinew15}"
 ? "{\*\do\dobxpage\dobypage\dodhgt12290\dpline\dpptx0\dppty0\dpptx0\dppty432\dpx5760\dpy4608\dpxsize1\dpysize433\dplinesolid\dplinecor0\dplinecog0\dplinecob0\dplinew15}"
 ? "{\*\do\dobxpage\dobypage\dodhgt12289\dpline\dpptx0\dppty0\dpptx0\dppty432\dpx5760\dpy3024\dpxsize1\dpysize433\dplinesolid\dplinecor0\dplinecog0\dplinecob0\dplinew15}"
 ? "{\*\do\dobxpage\dobypage\dodhgt12288\dpline\dpptx0\dppty0\dpptx0\dppty432\dpx1152\dpy3024\dpxsize1\dpysize433\dplinesolid\dplinecor0\dplinecog0\dplinecob0\dplinew15}"
 ? "{\*\do\dobxpage\dobypage\dodhgt12287\dpline\dpptx576\dppty0\dpptx0\dppty0\dpx5184\dpy5040\dpxsize577\dpysize1\dplinesolid\dplinecor0\dplinecog0\dplinecob0\dplinew15}"
 ? "{\*\do\dobxpage\dobypage\dodhgt12286\dpline\dpptx576\dppty0\dpptx0\dppty0\dpx1152\dpy5040\dpxsize577\dpysize1\dplinesolid\dplinecor0\dplinecog0\dplinecob0\dplinew15}"
 ? "{\*\do\dobxpage\dobypage\dodhgt12285\dpline\dpptx576\dppty0\dpptx0\dppty0\dpx5184\dpy3024\dpxsize577\dpysize1\dplinesolid\dplinecor0\dplinecog0\dplinecob0\dplinew15}"
 ? "{\*\do\dobxpage\dobypage\dodhgt12284\dpline\dpptx576\dppty0\dpptx0\dppty0\dpx1152\dpy3024\dpxsize577\dpysize1\dplinesolid\dplinecor0\dplinecog0\dplinecob0\dplinew15}"
endif

cDodatak := RegIPorBr()
cnFS     := IzFMKIni("RTF","PartnerFS","28",KUMPATH)
cnSB     := IzFMKIni("RTF","PartnerSB","90",KUMPATH)

*?? "{\header"
// WWTBox(20,54,80,35,"\f2\b\fs28\qc\sb90\sa0\sl400 "+;
IF gVarRF=="1"
  WWTBox(20,44,80,35,"\f2\b\fs"+cnFS+"\qc\sb"+cnSB+"\sa0\sl400 "+;
         ToRtfStr(cTxt3a)+iif(!empty(cTxt3b),"\line "+ToRtfStr(cTxt3b),"")+"\line "+ToRtfStr(cTxt3c)+cDodatak,;
         "0",{0,0,0}, 0,;   // line type, line color, line width
             {0,0,0},;  //  fill foreground
             {0,0,0},"0")     // fill background, fill pattern
ELSE
  WWTBox(20,70,80,35,"\f2\b\fs"+cnFS+"\qc\sb"+cnSB+"\sa0\sl400 "+;
         ToRtfStr(cTxt3a)+iif(!empty(cTxt3b),"\line "+ToRtfStr(cTxt3b),"")+"\line "+ToRtfStr(cTxt3c)+cDodatak,;
         "0",{0,0,0}, 0,;   // line type, line color, line width
             {0,0,0},;  //  fill foreground
             {0,0,0},"0")     // fill background, fill pattern
ENDIF

if !(gVarF $ "34")
// WWTBox(109.4,57,85,8,"\f2\fs22\qr "+gMjStr+", "+;
  IF gVarRF=="1"
    WWTBox(109.4,92,85,8,"\f2\fs22\qr "+Mjesto(cIdFirma)+", "+;
           ToRtfStr(dtoc(datdok)+" godine"),;
           "0",{0,0,0}, 0,;   // line type, line color, line width
               {0,0,0},;  //  fill foreground
               {0,0,0},"0")     // fill background, fill pattern
  ELSE
    WWTBox(109.4,67,85,8,"\f2\fs22\qr "+Mjesto(cIdFirma)+", "+;
           ToRtfStr(dtoc(datdok)+" godine"),;
           "0",{0,0,0}, 0,;   // line type, line color, line width
               {0,0,0},;  //  fill foreground
               {0,0,0},"0")     // fill background, fill pattern
  ENDIF
endif

cStr:=idtipdok+" "+brdok
cIdTipDok:=IdTipDok
private cpom:=""
if !(cIdTipDok $ "00#01#19")
 cPom:="G"+cidtipdok+"STR"
 cStr:=&cPom+" "+trim(BrDok)
endif

if gImeF=="D"    // svaki izlazni fajl ima svoje ime
 cOutf:=PRIVPATH+alltrim(idtipdok)+"-"+strtran(alltrim(brdok),"/","-")+".rtf"
endif

nWWPos:=1


// WWTBox(107.4,iif(gVarF=="4",82,78),85,10,"\f2\b\fs28\qr "+;
IF gVarRF=="1"
  WWTBox(107.4,100,85,10,"\f2\b\fs28\qr "+;
         ToRtfStr(cStr),;
         "0",{0,0,0}, 0,;   // line type, line color, line width
             {0,0,0},;  //  fill foreground
             {0,0,0},"0")     // fill background, fill pattern
ELSE
  WWTBox(107.4,88,85,10,"\f2\b\fs28\qr "+;
         ToRtfStr(cStr),;
         "0",{0,0,0}, 0,;   // line type, line color, line width
             {0,0,0},;  //  fill foreground
             {0,0,0},"0")     // fill background, fill pattern
ENDIF



if gVarF $ "34" .and. cidtipdok=="10"
 WWTBox(20,95,175.6,10,"\f2\fs20\tql\tx"+ToP(2)+" \tqr\tx"+ToP(170)+;
        " {\i\tab Otpremnica br: "+_brotp+", od "+dtoc(_datotp)+"\tab Datum fakture: "+dtoc(datdok)+;
           "\line\tab Ugovor/narud`ba: "+_brnar+"\tab Datum pla\}anja: "+dtoc(_datpl)+"}",;
        "0",{0,0,0}, 0,;   // line type, line color, line width
            {0,0,0},;  //  fill foreground
            {0,0,0},"0")     // fill background, fill pattern
 ?? "\par "
 ?? "\par "
 ?? "\par "
 nWWPos+=6
endif
?? "\par "
Zagl1()  // zaglavlje tabele

nUk:=0
nRab:=0
nZaokr:=ZAOKRUZENJE
PPrazna:=.t.
cDinDem:=dindem

IF gVarRF=="3"
  bRDefDet:={|| WWRowDef({ {CO1,{"l","s",0.1},{"r","s",0.1}   } , ;
             {CO2,{"l","s",0.1},{"r","s",0.1}  } , ;
             {CO3+CO4,{"l","s",0.1},{"r","s",0.1}  }, ;
             {CO5,{"l","s",0.1},{"r","s",0.1}  }, ;
             {CO6,{"l","s",0.1},{"r","s",0.1}   }, ;
             {CO7,{"l","s",0.1},{"r","s",0.1}  }, ;
             {CO8,{"l","s",0.1},{"r","s",0.1}   }, ;
             {CO9,{"l","s",0.1},{"r","s",0.1}  }, ;
             {COA,{"l","s",0.1},{"r","s",0.1}  }, ;
             {COB,{"l","s",0.1},{"r","s",0.1}  } ;
            }) }
ELSE
  bRDefDet:={|| WWRowDef({ {CO1,{"l","s",0.1},{"r","s",0.1}   } , ;
             {CO2,{"l","s",0.1},{"r","s",0.1}  } , ;
             {CO3+CO4,{"l","s",0.1},{"r","s",0.1}  }, ;
             {CO5,{"l","s",0.1},{"r","s",0.1}  }, ;
             {CO6,{"l","s",0.1},{"r","s",0.1}   }, ;
             {CO7,{"l","s",0.1},{"r","s",0.1}  }, ;
             {CO8,{"l","s",0.1},{"r","s",0.1}   }, ;
             {CO9,{"l","s",0.1},{"r","s",0.1}  }, ;
             {COA,{"l","s",0.1},{"r","s",0.1}  } ;
            }) }
ENDIF

nStr:=1
private cRnazB:=""

do while idfirma==cidfirma .and. idtipdok==cidtipdok .and. brdok==cbrdok .and. !eof()

   Eval(bRDefDet)

   NSRNPIdRoba()

   if alltrim(podbr)=="."   .or. roba->tip="U"
      aMemo:=ParsMemo(txt)
      cTxt1:=padr(aMemo[1],40)
   endif
   if roba->tip="U"
      cTxt1:=aMemo[1]
   endif


  if alltrim(podbr)=="." // zaglavlje
    cRNaz:="{\fs20\b "+ToRtfStr(cTxt1)+"}"
    nRez:=len(WWSjeciStr(cRNaz,10,(CO3+CO4-2)))
    nWWPos+=nRez

    if cTI=="1"
      if nWWPos+nTxt2 > nRedova+gERedova  // preci na drugu stranu
        nWWPos:=1; NStr(fPrvaStr)
        if fPrvaStr; fPrvaStr:=.f.; nRedova+=11; endif
      endif // nWWPos
       cNPom:=alltrim(Rbr())
       if gVarF $ "34"
         cNPom:=strtran(cNPom,")","")
       endif
       ?? "\ql\sb30\sa20\f2\fs20 "+cNPom+"\cell"
       cNPom:=alltrim(transform(kolicina,pickol))
       if gVarF $ "34"
          BosNum(@cNPom)
       endif
       WWCellS({" ",cRNaz,"\ri"+ToP(1)+"\qr "+cNPom,"\ri0 "," "," "," "," "})
    else
       nRec:=recno()
       cRbr:=Rbr
       nUk2:=nRab2:=nPor2:=0
       nPorez:=0
       do while !eof() .and. idfirma+idtipdok+brdok==cidfirma+cidtipdok+cbrdok.and. Rbr==cRbr
        if podbr=" ."
          skip; loop
        endif
        nUk2+=round(kolicina*cijena*Koef(cDinDem) , nZaokr)
        nRab2+=round(kolicina*cijena*Koef(cDinDem)*rabat/100 , nZaokr)
        nPor2+=round(kolicina*cijena*Koef(cDinDem)*(1-rabat/100)*Porez/100, nZaokr)
        skip
       enddo
       nPorez:=nPor2/(nUk2-nRab2)*100
       go nRec

       if nRab2*100/nUk2-int(nRab2*100/nUk2) <> 0
          cRab:=str(nRab2*100/nUk2,4,1)
       else
         cRab:=str(nRab2*100/nUk2,2,0)
       endif

       if nPorez-int(nPorez)<>0  // procenat poreza
        cPor:=str(nPorez,3,1)
       else
        cPor:=str(nPorez,2,0)
       endif
        // nWWPos+=iif(nPor2<>0,1,0)
        cNPom:=alltrim(Rbr())
        if gVarF $ "34"
         cNPom:=strtran(cNPom,")","")
        endif
        ?? "\ql\sb30\sa20\f2\fs18 "+cNPom+"\cell"
        if nWWPos+nTxt2 > nRedova+gERedova  // preci na drugu stranu
          nWWPos:=1; NStr(fPrvaStr)
          if fPrvaStr; fPrvaStr:=.f.; nRedova+=11; endif
        endif // nWWPos
        cNPom:=alltrim(transform(kolicina,pickol))
        cNPom2:=alltrim(transform(round(nUk2,nZaokr),picdem))
        IF gVarRF=="3"
          cNPom3:=alltrim(transform( round(iif(kolicina==0,0,nUk2-kolicina*cijena*rabat/100),nZaokr),picdem))
        ELSE
          cNPom3:=alltrim(transform( round(iif(kolicina==0,0,nUk2/kolicina),nZaokr),picdem))
        ENDIF
        if gVarF $ "34"
          BosNum(@cNPom)
          BosNum(@cNPom2)
          BosNum(@cNPom3)
          BosNum(@cRab)
          BosNum(@cPor)
        endif

        IF gVarRF=="3"
          WWCellS({" ","{\fs20 "+cRNaz+"}","\ri"+ToP(1)+"\qr "+cNPom+"\ri0","\ri0 ",;
              cNPom2,;
              cRab+"%",ALLTRIM(TRANSFORM(ROUND(cijena*rabat/100,nZaokr),picdem)),cPor+"%",;
              "{\b "+cNPom3+"}" ;
              })
        ELSE
          WWCellS({" ","{\fs20 "+cRNaz+"}","\ri"+ToP(1)+"\qr "+cNPom+"\ri0","\ri0 ",;
              cNPom2,;
              cRab+"%",cPor+"%",;
              "{\b "+cNPom3+"}" ;
              })
        ENDIF

       if nPor2<>0
         select por
         if roba->tip="U"
          cPor:="PPU "+ BosNum(str(nPorez,5,2))+"%"
         else
          cPor:="PPP "+ BosNum(str(nPorez,5,2))+"%"
         endif
         seek cPor
         if !found(); append blank; replace por with cPor ;endif
         replace iznos with iznos+nPor2
         select pripr
       endif
    endif //

  else // podbr nije "."
    NSRNPIdRoba()
    if roba->tip="U"
       cRNaza:="{\b\fs20 "+ToRtfStr(trim(cTxt1))+"}"
    else
     if empty(podbr)
       cRNaza:="{\fs20\b "+ToRtfStr(trim(ROBA->naz))+"}"
       cRnazb:=""
     else
       cRNaza:=ToRtfStr(trim(ROBA->naz))
     endif
     cRnazb:=iif(empty(serbr),"", " "+ToRtfStr("(s.b. "+trim(serbr)+")" ) )
    endif
    nRez1:=len(WWSjeciStr(cRnaz1:=(cRNaza+cRnazb),13,(CO3+CO4-2)))
      cRNaz:=cRnaz1
      nWWPos+=nRez1

    if rabat-int(rabat) <> 0
      cRab:=str(rabat,4,1)
    else
      cRab:=str(rabat,2,0)
    endif
    if porez-int(porez)<>0
        cPor:=str(porez,3,1)
    else
        cPor:=str(porez,2,0)
    endif

    nPor2:=cijena*Koef(cDinDem)*kolicina*(1-Rabat/100)*porez/100
    if nWWPos+nTxt2 > nRedova+gERedova  // preci na drugu stranu
          nWWPos:=1; NStr(fPrvaStr)
          if fPrvaStr; fPrvaStr:=.f.; nRedova+=11; endif
    endif // nWWPos
    cNPom:=alltrim(Rbr())
    if gVarF $ "34"
     cNPom:=strtran(cNPom,")","")
    endif
    ?? "\ql\sb30\sa20\f2\fs18 "+cNPom+"\cell"

    cNPom:=alltrim(transform(kolicina,pickol))
    cNPom2:=alltrim(transform(round(cijena*Koef(cDinDem),nZaokr),picdem))
    IF gVarRF=="3"
      cNPom3:=alltrim(transform(round(cijena*Koef(cDinDem)*kolicina*(1-rabat/100),nZaokr),picdem))
    ELSE
      cNPom3:=alltrim(transform(round(cijena*Koef(cDinDem)*kolicina,nZaokr),picdem))
    ENDIF
    if gVarF $ "34"
      BosNum(@cNPom)
      BosNum(@cNPom2)
      BosNum(@cNPom3)
      BosNum(@cPor)
      BosNum(@cRab)
    endif
    IF gVarRF=="3"
      WWCellS({;
            "\qc "+idroba,;
            "\ql {\fs20 "+cRNaz+"}",;
            "\ri"+ToP(1)+"\qr "+cNPom,;
            "\ri0\qc "+ToRtfStr(lower(ROBA->jmj)),;
            iif(empty(podbr) .or. (!empty(podbr) .and. cTI=="1"),"\qr "+cNPom2," "),;
            iif(empty(podbr) .or. (!empty(podbr) .and. cTI=="1"),cRab+"%"," "),;
            iif(empty(podbr) .or. (!empty(podbr) .and. cTI=="1"),ALLTRIM(TRANSFORM(ROUND(cijena*rabat/100,nZaokr),picdem))," "),;
            iif(empty(podbr) .or. (!empty(podbr) .and. cTI=="1"),"\qr "+cPor+"%"," "),;
            iif(empty(podbr) .or. (!empty(podbr) .and. cTI=="1"),"\qr{\b "+cNPom3+"}"," ") ;
            })
    ELSE
      WWCellS({;
            "\qc "+idroba,;
            "\ql {\fs20 "+cRNaz+"}",;
            "\ri"+ToP(1)+"\qr "+cNPom,;
            "\ri0\qc "+ToRtfStr(lower(ROBA->jmj)),;
            iif(empty(podbr) .or. (!empty(podbr) .and. cTI=="1"),"\qr "+cNPom2," "),;
            iif(empty(podbr) .or. (!empty(podbr) .and. cTI=="1"),cRab+"%"," "),;
            iif(empty(podbr) .or. (!empty(podbr) .and. cTI=="1"),"\qr "+cPor+"%"," "),;
            iif(empty(podbr) .or. (!empty(podbr) .and. cTI=="1"),"\qr{\b "+cNPom3+"}"," ") ;
            })
    ENDIF

    if empty(podbr) .or. (!empty(podbr) .and. cTI=="1")
      if nPor2<>0
         select por
         if roba->tip="U"
          cPor:="PPU "+ str(pripr->Porez,5,2)+"%"
         else
          cPor:="PPP "+ str(pripr->Porez,5,2)+"%"
         endif
         seek cPor
         if !found(); append blank; replace por with cPor ;endif
         replace iznos with iznos+nPor2
         select pripr
      endif
    endif
    nUk+=round(cijena*Koef(cDinDem)*kolicina , nZaokr)
    nRab+=round(cijena*Koef(cDinDem)*kolicina*rabat/100 , nZaokr)
    nUPorez+=round(nPor2, nZaokr)
  endif
 skip


enddo


IF gVarRF=="3"
  WWRowDef({ {CO1+CO2+CO3+CO4+CO5+CO6+CO7+CO8+CO9+COA+COB,{"l","s",0.1},{"t","s",0.4},{"r","s",0.1},{"b","s",0.1} } ;
           })
ELSE
  WWRowDef({ {CO1+CO2+CO3+CO4+CO5+CO6+CO7+CO8+CO9+COA,{"l","s",0.1},{"t","s",0.4},{"r","s",0.1},{"b","s",0.1} } ;
           })
ENDIF

select por
go top
cPor:=""
do while !eof()  // string poreza
 cNPom:= alltrim(transform(round(iznos,nZaokr),"9"+picdem))
 cNPom2:=por
 if gVarF $ "34"
   BosNum(@cNPom)
   BosNum(@cNPom2)
 endif
 cPor+="\line\tab "+trim(cNPom2)+":\tab {\b "+cNPom+"}"
 skip
enddo

cNPom:=alltrim(transform(round(nUk,nZaokr),"9"+picdem))
cNPom2:=alltrim(transform(round(nRab,nZaokr),"9"+picdem))
nFZaokr:=round(nUk-nRab+nUPorez,nZaokr)-round2(round(nUk-nRab+nUPorez,nZaokr),gFZaok)
cNPom3:=""
if gFZaok<>9 .and. round(nFzaokr,4)<>0
 cNPom3:=alltrim(transform(round(nFZaokr,nZaokr),"9"+picdem))
endif
if gVarF $ "34"
  BosNum(@cNPom)
  BosNum(@cNPom2)
  BosNum(@cNPom3)
endif
WWCells({ "\tqr\tx"+ToP(140.8)+"\tqr\tx"+ToP(173)+;
         "\tab Ukupno bez uracunatog rabata:\tab {\b "+;
         cNPom+;
        "}\line\tab Rabat:\tab {\b "+cNPom2+"}"+;
         cPor+;
         iif(empty(cNPom3),"","\line\tab Zaokruzenje:\tab {\b "+cNPom3+"}");
       })

IF gVarRF=="3"
  WWRowDef({ {CO1+CO2+CO3+CO4+CO5+CO6+CO7+CO8+CO9+COA+COB,{"l","s",0.1},{"r","s",0.1},{"b","s",0.4} } ;
           })
ELSE
  WWRowDef({ {CO1+CO2+CO3+CO4+CO5+CO6+CO7+CO8+CO9+COA,{"l","s",0.1},{"r","s",0.1},{"b","s",0.4} } ;
           })
ENDIF
cNPom:=alltrim(transform(round(nUk-nRab+nUPorez,nZaokr),"9"+picdem))
if gVarF $ "34"
  BosNum(@cNPom)
endif
WWCells({ "\tqr\tx"+ToP(140.8)+"\tqr\tx"+ToP(173)+;
         "\tab {\b\fs20 U K U P N O:\tab "+;
         +cNPom+;
        "}\line\fs20 "+iif(empty(picdem),"","slovima:"+;
         ToRtfStr(Slovima(round(nUk-nRab+nUPorez,nZaokr),cDinDem)));
       })

?? "\pard"   // zavrsetak tabele

? "\par"
? "\fs20 ",cTxt2

cPomoc := PrStr2R( cIdTipDok )

WWTBox(20,264,175.6,10,"\f2\fs18\tqc\tx"+ToP(25)+" \tqc\tx"+ToP(90)+" \tqc\tx"+ToP(150)+;
        " {\i "+cPomoc+"}",;
        "0",{0,0,0}, 0,;   // line type, line color, line width
            {0,0,0},;  //  fill foreground
            {0,0,0},"0")     // fill background, fill pattern

WWEnd()

set printer to
set printer off
set console on

MsgC()
Beep(2)
Box(,4,65,.t.)
set cursor off
@ m_x+1,m_y+2 SAY "Faktura je pripremljena za stampu."
@ m_x+3,m_y+2 SAY "Formiran je fajl: "+cImeF
if gImeF=="D"
  cKomLin:="copy "+cimef+" "+coutf
  run &cKomLin
  @ m_x+4,m_y+2 SAY "Takodje je formiran: "+cOutF
endif

if empty(gKomLin)
  InkeySc(0)
else
  save screen to cScr
  run &gKomLin
  restore screen from cScr
endif
BoxC()

select por; use
select pripr

closeret
*}




