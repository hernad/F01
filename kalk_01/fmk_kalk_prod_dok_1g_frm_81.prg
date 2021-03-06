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

*array
static aPorezi:={}
*;


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software
 * ----------------------------------------------------------------
 */


/* file fmk/kalk/prod/dok/1g/frm_81.prg
 *   Maska za unos dokumenata tipa 81
 */


/*  Get1_81()
 *   Prva strana maske za unos dokumenta tipa 81
 */

// direktni ulaz u prodavnicu
function Get1_81()


if nRbr==1 .and. fnovi
  _DatFaktP:=_datdok
endif

if nRbr==1  .or. !fnovi
 @  m_x+6,m_y+2   SAY "DOBAVLJAC:" get _IdPartner pict "@!" valid empty(_IdPartner) .or. P_Firma(@_IdPartner,6,30)
 @  m_x+7,m_y+2   SAY "Faktura dobavljaca - Broj:" get _BrFaktP
 @  m_x+7,col()+2 SAY "Datum:" get _DatFaktP

 @ m_x+10,m_y+2   SAY "Konto koji zaduzuje" GET _IdKonto valid  P_Konto(@_IdKonto,24) pict "@!"
 if gNW<>"X"
   @ m_x+10,m_y+35  SAY "Zaduzuje: "   GET _IdZaduz  pict "@!" valid empty(_idZaduz) .or. P_Firma(@_IdZaduz,24)
 endif
 read
 ESC_RETURN K_ESC
 _DatKurs:=_DatFaktP
else
 @  m_x+6,m_y+2   SAY "DOBAVLJAC: "; ?? _IdPartner
 @  m_x+7,m_y+2   SAY "Faktura dobavljaca - Broj: "; ?? _BrFaktP
 @  m_x+7,col()+2 SAY "Datum: "; ?? _DatFaktP
 @  m_x+10,m_y+2  SAY "Konto koji zaduzuje "; ?? _IdKonto
 if gNW<>"X"
   @  m_x+10,m_y+35 SAY "Zaduzuje: "; ?? _IdZaduz
 endif
 read; ESC_RETURN K_ESC
endif

@ m_x+11,m_y+66 SAY "Tarif.br->"
if lKoristitiBK
	@ m_x+12,m_y+2   SAY "Artikal  " GET _IdRoba pict "@!S10" when {|| _IdRoba:=PADR(_idroba,VAL(gDuzSifIni)),.t.} valid VRoba_lv(fNovi, @aPorezi)
else
	@ m_x+12,m_y+2  SAY "Artikal  " GET _IdRoba pict "@!"  valid  VRoba_lv(fNovi, @aPorezi)

endif

@ m_x+12,m_y+70 GET _IdTarifa when gPromTar=="N" valid P_Tarifa(@_IdTarifa)

read
ESC_RETURN K_ESC

if lKoristitiBK
	_idRoba:=Left(_idRoba,10)
endif

//select TARIFA
//hseek _IdTarifa  // postavi TARIFA na pravu poziciju

select koncij
seek trim(_idkonto)
select PRIPR  // napuni tarifu

_PKonto:=_Idkonto
DatPosljP()

  @ m_x+13, m_y+2   SAY "Kolicina " GET _Kolicina PICTURE PicKol valid _Kolicina<>0

 IF IsDomZdr()
   @ m_x+14, m_y+2   SAY "Tip sredstva (prazno-svi) " GET _Tip PICT "@!"
 ENDIF


if fNovi
 select koncij
 seek trim(_idkonto)
 select ROBA
 HSEEK _IdRoba
 _MPCSapp:=UzmiMPCSif()
 _TMarza2:="%"
 if Carina<>0
    _TCarDaz:="%"
    _CarDaz:=carina
  endif
endif


select PRIPR

@ m_x+15, m_y+2   SAY "F.CJ.(DEM/JM):"
@ m_x+15, m_y+50  GET _FCJ PICTURE PicDEM    valid _fcj>0  when VKol()

@ m_x+17, m_y+2   SAY "KASA-SKONTO(%):"
@ m_x+17, m_y+40 GET _Rabat PICTURE PicDEM when DuplRoba()

if gNW<>"X"
 @ m_x+18, m_y+2   SAY "Transport. kalo:"
 @ m_x+18, m_y+40  GET _GKolicina PICTURE PicKol

 @ m_x+19, m_y+2   SAY "Ostalo kalo:    "
 @ m_x+19, m_y+40  GET _GKolicin2 PICTURE PicKol
endif

read

ESC_RETURN K_ESC
_FCJ2:=_FCJ*(1-_Rabat/100)

return lastkey()





/*  VKol()
 *   Validacija kolicine pri unosu dokumenta tipa 81
 */

static function VKol()

if _kolicina<0  // storno
//////// kalkulacija nabavne cijene
//////// nKolZN:=kolicina koja je na stanju a porijeklo je od zadnje nabavke
nKolS:=0;nKolZN:=0;nc1:=nc2:=0; dDatNab:=ctod("")
 if !empty(gMetodaNC)
  MsgO("Racunam stanje na u prodavnici")
  KalkNabP(_idfirma,_idroba,_idkonto,@nKolS,@nKolZN,@nc1,@nc2,@dDatNab)
  MsgC()
  @ m_x+12,m_y+30   SAY "Ukupno na stanju "; @ m_x+12,col()+2 SAY nkols pict pickol
 endif
 if dDatNab>_DatDok; Beep(1);Msg("Datum nabavke je "+dtoc(dDatNab),4);endif
 //if _nc==0; _nc:=nc2; endif
 //if gMetodaNC $ "13"; _nc:=nc1; elseif gMetodaNC=="2"; _nc:=nc2; endif
 if nkols < abs(_kolicina)
   _ERROR:="1"
   Beep(2)
   Msg("Na stanju je samo kolicina:"+str(nkols,12,3))
 endif
select PRIPR
endif
return .t.





/*  Get2_81()
 *   Druga strana maske za unos dokumenta tipa 81
 */

function Get2_81()

local cSPom:=" (%,A,U,R) "
private getlist:={}
private fMarza:=" "

if empty(_TPrevoz); _TPrevoz:="%"; endif
if empty(_TCarDaz); _TCarDaz:="%"; endif
if empty(_TBankTr); _TBankTr:="%"; endif
if empty(_TSpedTr); _TSpedtr:="%"; endif
if empty(_TZavTr);  _TZavTr:="%" ; endif
if empty(_TMarza);  _TMarza:="%" ; endif

@ m_x+2,m_y+2     SAY c10T1+cSPom GET _TPrevoz VALID _TPrevoz $ "%AUR" PICTURE "@!"
@ m_x+2,m_y+40    GET _Prevoz PICTURE  PicDEM

@ m_x+3,m_y+2     SAY c10T2+cSPom  GET _TBankTr VALID _TBankTr $ "%AUR" pict "@!"
@ m_x+3,m_y+40    GET _BankTr PICTURE PicDEM

@ m_x+4,m_y+2     SAY c10T3+cSPom GET _TSpedTr valid _TSpedTr $ "%AUR" pict "@!"
@ m_x+4,m_y+40    GET _SpedTr PICTURE PicDEM

@ m_x+5,m_y+2     SAY c10T4+cSPom GET _TCarDaz VALID _TCarDaz $ "%AUR" PICTURE "@!"
@ m_x+5,m_y+40    GET _CarDaz PICTURE PicDEM

@ m_x+6,m_y+2     SAY c10T5+cSPom GET _TZavTr VALID _TZavTr $ "%AUR" PICTURE "@!"
@ m_x+6,m_y+40    GET _ZavTr PICTURE PicDEM ;
                    VALID {|| NabCj(),.t.}

@ m_x+8,m_y+2     SAY "NABAVNA CJENA:"
@ m_x+8,m_y+50    GET _NC     PICTURE PicDEM

@ m_x+10,m_y+2 SAY "Marza:" GET _TMarza2  VALID _Tmarza2 $ "%AU" PICTURE "@!"
@ m_x+10,col()+2  GET _Marza2 ;
	PICTURE  PicDEM ;
	valid {|| _vpc:=_nc, .t.}

@ m_x+10,col()+1 GET fMarza pict "@!"

if IsPDV()
	@ m_x+12,m_y+2  SAY "          PC BEZ PDV :"
else
	@ m_x+12,m_y+2  SAY "MALOPROD. CJENA (MPC):"
endif

@ m_x+12,m_y+50 GET _MPC picture PicDEM ;
     WHEN W_MPC_("81", (fMarza == "F"), @aPorezi) ;
     VALID V_Mpc_ ("81", (fMarza=="F"), @aPorezi)

if IsPDV()
	@ m_x+14, m_y+2 SAY "PDV (%):"
	@ row(),col()+2 SAY  TARIFA->OPP PICTURE "99.99"
	if glUgost
	  @ m_x+14,col()+8  SAY "PP (%):"
	  @ row(),col()+2  SAY TARIFA->ZPP PICTURE "99.99"
	endif
else
	@ m_x+14, m_y+2 SAY "PPP (%):"
	@ row(),col()+2 SAY  TARIFA->OPP PICTURE "99.99"
	@ m_x+14,col()+8  SAY "PPU (%):"
	@ row(),col()+2  SAY TARIFA->PPP PICTURE "99.99"
	@ m_x+14,col()+8  SAY "PP (%):"
	@ row(),col()+2  SAY TARIFA->ZPP PICTURE "99.99"
endif

if IsPDV()
	@ m_x+16,m_y+2 SAY "    PC SA PDV  :"
else
	@ m_x+16,m_y+2 SAY "MPC SA POREZOM :"
endif

@ m_x+16,m_y+50 GET _MPCSaPP  picture PicDEM ;
    WHEN {|| fMarza:=" ", _Marza2:=0, .t.} ;
    VALID V_MpcSaPP_( "81", .f., @aPorezi, .t.)

read
ESC_RETURN K_ESC

select koncij
seek trim(_idkonto)

StaviMPCSif(_mpcsapp,.t.)

select pripr

_PKonto:=_Idkonto

_PU_I:="1"

_MKonto:=""
_MU_I:=""

nStrana:=3
return lastkey()
