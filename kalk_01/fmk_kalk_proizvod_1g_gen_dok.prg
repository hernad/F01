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

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */
 

/* file fmk/kalk/proizvod/1g/gen_dok.prg
 *  
 */


/*  GenProizvodnja()
 *   Meni opcija za generisanje dokumenata u vezi sa proizvodnjom
 */

function GenProizvodnja()

private Opc:={}
private opcexe:={}

AADD(Opc,"1. generisi 96 na osnovu 47 po normativima")
AADD(opcexe,{|| Iz47u96Norm() })

private Izbor:=1
Menu_SC("kkno")
CLOSERET
return





/*  Iz47u96Norm()
 *   Generisanje dokumenta tipa 96 na osnovu 47-ica po normativima
 */

function Iz47u96Norm()

local cIdFirma:=gFirma, cBrDok:=cBrKalk:=space(8)
O_PRIPR
O_KALK
O_ROBA
O_KONTO
O_PARTN
O_TARIFA
O_SAST
#xcommand XO_KALK    => select (F_FAKT);  use  ("KALK")  alias kalk2; set order to 1
XO_KALK
dDatKalk:=date()
cIdKonto:=padr("",7)
cIdKonto2:=padr("1010",7)
cIdZaduz2:=space(6)

cBrkalk:=space(8)
if gBrojac=="D"
 select kalk
 select kalk; set order to 1;seek cidfirma+"96X"
 skip -1
 if idvd<>"96"
   cbrkalk:=space(8)
 else
   cbrkalk:=brdok
 endif
endif
Box(,15,60)

if gBrojac=="D"
 cbrkalk:=UBrojDok(val(left(cbrkalk,5))+1,5,right(cBrKalk,3))
endif

do while .t.

  nRBr:=0
  @ m_x+1,m_y+2   SAY "Broj kalkulacije 96 -" GET cBrKalk pict "@!"
  @ m_x+1,col()+2 SAY "Datum:" GET dDatKalk
  @ m_x+3,m_y+2   SAY "Konto razduzuje:" GET cIdKonto2 pict "@!" valid P_Konto(@cIdKonto2)
  if gNW<>"X"
    @ m_x+3,col()+2 SAY "Razduzuje:" GET cIdZaduz2  pict "@!"      valid empty(cidzaduz2) .or. P_Firma(@cIdZaduz2)
  endif
  @ m_x+4,m_y+2   SAY "Konto zaduzuje :" GET cIdKonto  pict "@!" valid empty(cIdKonto) .or. P_Konto(@cIdKonto)

  cBrDok47:=space(8)
  @ m_x+7,m_Y+2 SAY "Broj dokumenta 47:" GET cBrDok47
  read
  if lastkey()==K_ESC; exit; endif

  select kalk2
  seek cIDFirma+'47'+cBrDok47
  dDatKalk:=datdok
  IF !ProvjeriSif("!eof() .and. '"+cIDFirma+"47"+cBrDok47+"'==IdFirma+IdVD+BrDok","IDROBA",F_ROBA)
    MsgBeep("U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!")
    LOOP
  ENDIF
  do while !eof() .and. cIDFirma+'47'+cBrDok47 == idfirma+idvd+brdok

       select ROBA; hseek kalk2->idroba

          select sast
          hseek  kalk2->idroba
          do while !eof() .and. id==kalk2->idroba // setaj kroz sast
            select roba; hseek sast->id2
            select pripr
            locate for idroba==sast->id2
            if found()
              replace kolicina with kolicina + kalk2->kolicina*sast->kolicina
            else
              select pripr
              append blank
              replace idfirma with cIdFirma,;
                      rbr     with str(++nRbr,3),;
                      idvd with "96",;   // izlazna faktura
                      brdok with cBrKalk,;
                      datdok with dDatKalk,;
                      idtarifa with ROBA->idtarifa,;
                      brfaktp with "",;
                      datfaktp with dDatKalk,;
                      idkonto   with cidkonto,;
                      idkonto2  with cidkonto2,;
                      idzaduz2  with cidzaduz2,;
                      datkurs with dDatKalk,;
                      kolicina with kalk2->kolicina*sast->kolicina,;
                      idroba with sast->id2,;
                      nc  with ROBA->nc
            endif
            select sast
            skip
          enddo

    select kalk2
    skip
  enddo

  @ m_x+10,m_y+2 SAY "Dokument je prenesen !!"
  if gBrojac=="D"
   cbrkalk:=UBrojDok(val(left(cbrkalk,5))+1,5,right(cBrKalk,3))
  endif
  inkey(4)
  @ m_x+8,m_y+2 SAY space(30)

enddo
Boxc()
select kalk2; use
closeret
return



