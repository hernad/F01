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

function TDbKalkNew()

local oObj
oObj:=TDbKalk():new()
oObj:self:=oObj
oObj:cName:="KALK"
oObj:lAdmin:=.f.
return oObj



#include "class(y).ch"
CLASS TDbKalk FROM TDB

	var    self
	var    cName
	method skloniSezonu()
	method install()

	method setgaDBFs()
	method ostalef()
	method obaza()
	method kreiraj()
	method konvZn()

ENDCLASS




method dummy
return


/*  *void TDbKalk::skloniSezonu(string cSezona, bool finverse,bool fda,bool fnulirati,bool fRS)
 *   formiraj sezonsku bazu podataka
 *   cSezona -
 *   fInverse - .t. iz sezone u radno, .f. iz radnog u sezonu
 *   fda - ne znam
 *   fnulirati - nulirati tabele
 *   fRS - ne znam
 */

*void TDbKalk::skloniSezonu(string cSezona, bool finverse,bool fda,bool fnulirati,bool fRS)


method TDbKalk:skloniSezonu(cSezona,finverse,fda,fnulirati, fRS)
save screen to cScr

if (fda==nil)
	fDA:=.f.
endif
if (finverse==nil)
	finverse:=.f.
endif
if (fNulirati==nil)
	fnulirati:=.f.
endif
if (fRS==nil)
  // mrezna radna stanica , sezona je otvorena
  fRS:=.f.
endif

if fRS // radna stanica
  if file(PRIVPATH+cSezona + SLASH + "PRIPR.DBF")
      // nema se sta raditi ......., pripr.dbf u sezoni postoji !
      return
  endif
  aFilesK:={}
  aFilesS:={}
  aFilesP:={}
endif

if KLevel<>"0"
	MsgBeep("Nemate pravo na koristenje ove opcije")
endif

cls

if fRS
   // mrezna radna stanica
   ? "Formiranje DBF-ova u privatnom direktoriju, RS ...."
endif

?
if finverse
 ? "Prenos iz  sezonskih direktorija u radne podatke"
else
 ? "Prenos radnih podataka u sezonske direktorije"
endif
?

fnul:=.f.
Skloni(PRIVPATH,"PRIPR.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"_KALK.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"FINMAT.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"PARAMS.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"PRIPR2.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"PRIPR9.DBF",cSezona,finverse,fda,fnul)
if is_doksrc()
	Skloni(PRIVPATH,"P_DOKSRC.DBF",cSezona,finverse,fda,fnul)
endif
Skloni(PRIVPATH,"FMK.INI",cSezona,finverse,fda,fnul)

if fRS
 // mrezna radna stanica!!! , baci samo privatne direktorije
 ?
 ?
 ?
 Beep(4)
 ? "pritisni nesto za nastavak.."

 restore screen from cScr
 return
endif

if fnulirati; fnul:=.t.; else; fnul:=.f.; endif  // kumulativ datoteke
Skloni(KUMPATH,"KALK.DBF",cSezona,finverse,fda,fnul)
if File2(KUMPATH+"KALKS.DBF")
  Skloni(KUMPATH,"KALKS.DBF",cSezona,finverse,fda,fnul)
endif
Skloni(KUMPATH,"DOKS.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"DOKS2.DBF",cSezona,finverse,fda,fnul)
if is_doksrc()
	Skloni(KUMPATH,"DOKSRC.DBF",cSezona,finverse,fda,fnul)
endif


fnul:=.f.
// proizvoljni izvjestaji
Skloni(KUMPATH,"KONIZ.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"KOLIZ.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"IZVJE.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"ZAGLI.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"FMK.INI",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"OBJEKTI.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"K1.DBF",cSezona,finverse,fda,fnul)

fnul:=.f.
Skloni(SIFPATH,"TARIFA.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"ROBA.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"ROBA.FPT",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"PARTN.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"TNAL.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"TDOK.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"KONTO.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"TRFP.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"VALUTE.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"KONCIJ.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"SAST.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"SIFK.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"SIFV.DBF",cSezona,finverse,fda,fnul)
if IsPlanika()
	Skloni(KUMPATH,"PRODNC.DBF",cSezona,finverse,fda,fnul)
	Skloni(SIFPATH,"RVRSTA.DBF",cSezona,finverse,fda,fnul)
endif

Skloni(SIFPATH,"FMK.INI",cSezona,finverse,fda,fnul)



?
?
?
Beep(4)
? "pritisni nesto za nastavak.."

restore screen from cScr
return


method TDBKalk:setgaDBFs()

PUBLIC gaDbfs := {;
{ F_PRIPR  ,"PRIPR"   , P_PRIVPATH    },;
{ F_PRIPR2 ,"PRIPR2"  , P_PRIVPATH    },;
{ F_PRIPR9 ,"PRIPR9"  , P_PRIVPATH    },;
{ F__KALK  ,"_KALK"   , P_PRIVPATH    },;
{ F_FINMAT ,"FINMAT"  , P_PRIVPATH    },;
{ F_KALK   ,"KALK"    , P_KUMPATH     },;
{ F_KALKS  ,"KALKS"   , P_KUMPATH     },;
{ F_DOKS   ,"DOKS"    , P_KUMPATH     },;
{ F_DOKS2  ,"DOKS2"   , P_KUMPATH     },;
{ F_PORMP  ,"PORMP"   , P_PRIVPATH    },;
{ F__ROBA  ,"_ROBA"   , P_PRIVPATH    },;
{ F__PARTN ,"_PARTN"  , P_PRIVPATH    },;
{ F_ROBA   ,"ROBA"    , P_SIFPATH     },;
{ F_TARIFA ,"TARIFA"  , P_SIFPATH     },;
{ F_KONTO  ,"KONTO"   , P_SIFPATH     },;
{ F_TRFP   ,"TRFP"    , P_SIFPATH     },;
{ F_PARTN  ,"PARTN"   , P_SIFPATH     },;
{ F_TNAL   ,"TNAL"    , P_SIFPATH     },;
{ F_TDOK   ,"TDOK"    , P_SIFPATH     },;
{ F_KONCIJ ,"KONCIJ"  , P_SIFPATH     },;
{ F_VALUTE ,"VALUTE"  , P_SIFPATH     },;
{ F_SAST   ,"SAST"    , P_SIFPATH     },;
{ F_KONIZ  ,"KONIZ"   , P_KUMPATH     },;
{ F_IZVJE  ,"IZVJE"   , P_KUMPATH     },;
{ F_ZAGLI  ,"ZAGLI"   , P_KUMPATH     },;
{ F_KOLIZ  ,"KOLIZ"   , P_KUMPATH     },;
{ F_DOKSRC ,"DOKSRC"  , P_KUMPATH     },;
{ F_LOGK   ,"LOGK"    , P_KUMPATH     },;
{ F_LOGKD  ,"LOGKD"   , P_KUMPATH     },;
{ F_BARKOD ,"BARKOD"  , P_PRIVPATH    },;
{ F_PPPROD ,"PPPROD"  , P_PRIVPATH    },;
{ F_P_DOKSRC,"P_DOKSRC", P_PRIVPATH    },;
{ F_OBJEKTI,"OBJEKTI" , P_KUMPATH     },;
{ F_PRODNC, "PRODNC"  , P_KUMPATH     },;
{ F_RVRSTA, "RVRSTA"  , P_SIFPATH     },;
{ F_K1     ,"K1"      , P_KUMPATH     };
}

return




/*  *void TDbKalk::install(string cKorisn,string cSifra,variant p3,variant p4,variant p5,variant p6,variant p7)
 *   osnovni meni za instalacijske procedure
 */

*void TDbKalk::install(string cKorisn,string cSifra,variant p3,variant p4,variant p5,variant p6,variant p7)


method install(cKorisn,cSifra,p3,p4,p5,p6,p7)
	If01_start(goModul,.f.)
return


/*  *void TDbKalk::kreiraj(int nArea)
 *   kreirane baze podataka POS
 */

method TDbKalk:kreiraj(nArea)


if (nArea==nil)
	nArea:=-1
endif

if (nArea<>-1)
	CreSystemDb(nArea)
endif

CreFMKSvi()
f01_cre_roba()
CreFMKPI()

#IFDEF SR
	if (nArea==-1 .or. nArea==(F_LOGK))
		//LOGK.DBF

		aDbf:={}
   		AADD(aDbf,{"NO",     "N",15,0})
   		AADD(aDbf,{"ID",     "C",6,0})
   		AADD(aDbf,{"DatProm","D",8,0})
   		AADD(aDbf,{"Datum",  "D",8,0})
   		AADD(aDbf,{"K1",     "C",10,0})
  	 	AADD(aDbf,{"K2",     "C",10,0})
   		AADD(aDbf,{"K3",     "C",2,0})
   		AADD(aDbf,{"N1",     "N",10,2})

		if !File2(KUMPATH+"LOGK.DBF")
   			DBcreate2(KUMPATH+'LOGK.DBF',aDbf)
		endif

		f01_create_index("ID","id", KUMPATH+"LOGK")
		f01_create_index("NO","NO", KUMPATH+"LOGK")
		f01_create_index("Datum","Datum", KUMPATH+"LOGK")
	endif
#endif



aDbf:={}
AADD(aDBf,{ 'IDFIRMA'             , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'IDROBA'              , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'IDKONTO'             , 'C' ,   7 ,  0 })
AADD(aDBf,{ 'IDKONTO2'            , 'C' ,   7 ,  0 })
AADD(aDBf,{ 'IDZADUZ'             , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'IDZADUZ2'            , 'C' ,   6 ,  0 })
// ova su polja prakticno tu samo radi kompat
// istina, ona su ponegdje iskoristena za neke sasvim druge stvari
// pa zato treba biti pazljiv sa njihovim diranjem
AADD(aDBf,{ 'IDVD'                , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'BRDOK'               , 'C' ,   8 ,  0 })
AADD(aDBf,{ 'DATDOK'              , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'BRFAKTP'             , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'DATFAKTP'            , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'IDPARTNER'           , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'DATKURS'             , 'D' ,   8 ,  0 })
// ovaj datkurs je sada skroz eliminisan iz upotrebe
// vidjeti za njegovo uklanjanje  (paziti na modul FIN) jer se ovo i tamo
// koristi
AADD(aDBf,{ 'RBR'                 , 'C' ,   3 ,  0 })
AADD(aDBf,{ 'KOLICINA'            , 'N' ,  12 ,  3 })
AADD(aDBf,{ 'GKOLICINA'           , 'N' ,  12 ,  3 })
AADD(aDBf,{ 'GKOLICIN2'           , 'N' ,  12 ,  3 })
AADD(aDBf,{ 'FCJ'                 , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'FCJ2'                , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'FCJ3'                , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'TRABAT'              , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'RABAT'               , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'TPREVOZ'             , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'PREVOZ'              , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'TPREVOZ2'            , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'PREVOZ2'             , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'TBANKTR'             , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'BANKTR'              , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'TSPEDTR'             , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'SPEDTR'              , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'TCARDAZ'             , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'CARDAZ'              , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'TZAVTR'              , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'ZAVTR'               , 'N' ,  18 ,  8 })
// ovi troskovi pravo uvecavaju bazu, mislim da bi njihovo sklanjanje u
// drugu bazu zaista pomoglo brzini
// medjutim i ova su polja viseznacna
AADD(aDBf,{ 'NC'                  , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'TMARZA'              , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'MARZA'               , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'VPC'                 , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'RABATV'              , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'VPCSAP'              , 'N' ,  18 ,  8 })
// ova vpcsap je u principu skroz bezvezna stvar
AADD(aDBf,{ 'TMARZA2'             , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'MARZA2'              , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'MPC'                 , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'IDTARIFA'            , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'MPCSAPP'             , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'MKONTO'              , 'C' ,   7 ,  0 })
AADD(aDBf,{ 'PKONTO'              , 'C' ,   7 ,  0 })
AADD(aDBf,{ 'RokTr'               , 'D' ,   8 ,  0 })
// rok trajanja NIKO ne koristi !!
AADD(aDBf,{ 'MU_I'                , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'PU_I'                , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'ERROR'               , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'PODBR'               , 'C' ,   2 ,  0 })

if (nArea==-1 .or. nArea==(F_PRIPR))
	//PRIPR.DBF

	if !File2(PRIVPATH+"PRIPR.dbf")
  		DBcreate2(PRIVPATH+'PRIPR.DBF',aDbf)
	endif

	f01_create_index("1","idFirma+IdVD+BrDok+RBr",PRIVPATH+"PRIPR")
	f01_create_index("2","idFirma+idvd+brdok+IDTarifa",PRIVPATH+"PRIPR")
	f01_create_index("3","idFirma+idvd+brdok+idroba+rbr",PRIVPATH+"PRIPR")
	f01_create_index("4","idFirma+idvd+idroba",PRIVPATH+"PRIPR")
	f01_create_index("5","idFirma+idvd+idroba+STR(mpcsapp,12,2)",PRIVPATH+"PRIPR")
endif

if (nArea==-1 .or. nArea==(F_PRIPR2))
	//PRIPR2

	if !File2(PRIVPATH+"PRIPR2.DBF")
  		dbcreate2(PRIVPATH+'PRIPR2.DBF',aDbf)
	endif

	f01_create_index("1","idFirma+IdVD+BrDok+RBr",PRIVPATH+"PRIPR2")
	f01_create_index("2","idFirma+idvd+brdok+IDTarifa",PRIVPATH+"PRIPR2")
endif

if (nArea==-1 .or. nArea==(F_PRIPR9))
	//PRIPR9.DBF

	if !File2(PRIVPATH+"PRIPR9.DBF")
  		DBcreate2(PRIVPATH+'PRIPR9.DBF',aDbf)
	endif

	f01_create_index("1","idFirma+IdVD+BrDok+RBr",PRIVPATH+"PRIPR9")
	f01_create_index("2","idFirma+idvd+brdok+IDTarifa",PRIVPATH+"PRIPR9")
	f01_create_index("3","dtos(datdok)+mu_i+pu_i",PRIVPATH+"PRIPR9")
endif

if (nArea==-1 .or. nArea==(F__KALK))
	//_KALK.DBF

	if !File2(PRIVPATH+"_KALK.DBF")
  		DBcreate2(PRIVPATH+'_KALK.DBF',aDbf)
	endif

	f01_create_index("1","idFirma+IdVD+BrDok+RBr",PRIVPATH+"_KALK")
endif


if (nArea==-1 .or. nArea==(F_KALK))
	//KALK.DBF

	if !File2(KUMPATH+"KALK.dbf")
  		DBcreate2(KUMPATH+'KALK.DBF',aDbf)
	endif

	f01_create_index("1","idFirma+IdVD+BrDok+RBr",KUMPATH+"KALK")
	f01_create_index("2","idFirma+idvd+brdok+IDTarifa",KUMPATH+"KALK")
	// 3 - vodjenje magacina
	f01_create_index("3","idFirma+mkonto+idroba+dtos(datdok)+podbr+MU_I+IdVD",KUMPATH+"KALK")
	// 4 - vodjenje prodavnice
	f01_create_index("4","idFirma+Pkonto+idroba+dtos(datdok)+podbr+PU_I+IdVD",KUMPATH+"KALK")

	f01_create_index("5","idFirma+dtos(datdok)+podbr+idvd+brdok",KUMPATH+"KALK")

	f01_create_index("6","idFirma+IdTarifa+idroba",KUMPATH+"KALK")

	f01_create_index("7","idroba+idvd",KUMPATH+"KALK")
	f01_create_index("8","mkonto",KUMPATH+"KALK")
	f01_create_index("9","pkonto",KUMPATH+"KALK")

	f01_create_index("MU_I","mu_i+mkonto+idfirma+idvd+brdok",KUMPATH+"KALK")
	f01_create_index("MU_I2","mu_i+idfirma+idvd+brdok",KUMPATH+"KALK")
	f01_create_index("PU_I","pu_i+pkonto+idfirma+idvd+brdok",KUMPATH+"KALK")
	f01_create_index("PU_I2","pu_i+idfirma+idvd+brdok",KUMPATH+"KALK")

	f01_create_index("PMAG","idfirma+mkonto+idpartner+idvd+dtos(datdok)",KUMPATH+"KALK")

	if is_uobrada()

		f01_create_index("UOBR","idfirma+mkonto+odobr_no+dtos(datdok)",KUMPATH+"KALK")
	endif

	f01_create_index("BRFAKTP","idfirma+brfaktp+idvd+brdok+rbr+dtos(datdok)",KUMPATH+"KALK")
	if lPoNarudzbi
  		f01_create_index("3N","idFirma+mkonto+idnar+idroba+dtos(datdok)+podbr+MU_I+IdVD",KUMPATH+"KALK")
  		f01_create_index("4N","idFirma+Pkonto+idnar+idroba+dtos(datdok)+podbr+PU_I+IdVD",KUMPATH+"KALK")
  		f01_create_index("6N","idFirma+IdTarifa+idnar+idroba",KUMPATH+"KALK")
	endif
	if  gVodiSamoTarife=="D"
 		f01_create_index("PTARIFA","idFirma+pkonto+IdTarifa+idroba",KUMPATH+"KALK")
	endif
endif



if (nArea==-1 .or. nArea==(F_DOKS))
	//DOKS.DBF

	aDbf:={}
	AADD(aDBf,{ 'IDFIRMA'             , 'C' ,   2 ,  0 })
	AADD(aDBf,{ 'IDVD'                , 'C' ,   2 ,  0 })
	AADD(aDBf,{ 'BRDOK'               , 'C' ,   8 ,  0 })
	AADD(aDBf,{ 'DATDOK'              , 'D' ,   8 ,  0 })
	AADD(aDBf,{ 'BRFAKTP'             , 'C' ,  10 ,  0 })
	AADD(aDBf,{ 'IDPARTNER'           , 'C' ,   6 ,  0 })
	AADD(aDBf,{ 'IdZADUZ'             , 'C' ,   6 ,  0 })
	AADD(aDBf,{ 'IdZADUZ2'            , 'C' ,   6 ,  0 })
	AADD(aDBf,{ 'PKONTO'              , 'C' ,   7 ,  0 })
	AADD(aDBf,{ 'MKONTO'              , 'C' ,   7 ,  0 })
	AADD(aDBf,{ 'NV'                  , 'N' ,  12 ,  2 })
	AADD(aDBf,{ 'VPV'                 , 'N' ,  12 ,  2 })
	AADD(aDBf,{ 'RABAT'               , 'N' ,  12 ,  2 })
	AADD(aDBf,{ 'MPV'                 , 'N' ,  12 ,  2 })
	AADD(aDBf,{ 'PODBR'               , 'C' ,   2 ,  0 })

	if !File2(KUMPATH+'DOKS.DBF')
        	DBcreate2(KUMPATH+'DOKS.DBF',aDbf)
	endif

	f01_create_index("1","IdFirma+idvd+brdok", KUMPATH+"DOKS")
	f01_create_index("2","IdFirma+MKONTO+idzaduz2+idvd+brdok", KUMPATH+"DOKS")
	f01_create_index("3","IdFirma+dtos(datdok)+podbr+idvd+brdok", KUMPATH+"DOKS")

	// 00001/T => /T00001
	// 00001/X => /X00001
	f01_create_index("1S","IdFirma+idvd+SUBSTR(brdok,6)+LEFT(brdok,5)",KUMPATH+"DOKS")

	f01_create_index("V_BRF","brfaktp+idvd",KUMPATH+"DOKS")
	f01_create_index("V_BRF2","idvd+brfaktp",KUMPATH+"DOKS")
endif


if (nArea==-1 .or. nArea==(F_DOKS2))
	//DOKS2.DBF

	aDbf:={}
	AADD(aDBf,{ 'IDFIRMA'             , 'C' ,   2 ,  0 })
	AADD(aDBf,{ 'IDvd'                , 'C' ,   2 ,  0 })
	AADD(aDBf,{ 'BRDOK'               , 'C' ,   8 ,  0 })
	AADD(aDBf,{ 'DATVAL'              , 'D' ,   8 ,  0 })
	AADD(aDBf,{ 'Opis'                , 'C' ,  20 ,  0 })
	AADD(aDBf,{ 'K1'                , 'C' ,  1 ,  0 })
	AADD(aDBf,{ 'K2'                , 'C' ,  2 ,  0 })
	AADD(aDBf,{ 'K3'                , 'C' ,  3 ,  0 })
	if !File2(KUMPATH+'DOKS2.DBF')
       		DBcreate2(KUMPATH+'DOKS2.DBF',aDbf)
	endif

	f01_create_index("1","IdFirma+idvd+brdok",KUMPATH+"DOKS2")
endif



aDbf:={}
AADD(aDBf,{ 'IDFIRMA'             , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'IDKONTO'             , 'C' ,   7 ,  0 })
AADD(aDBf,{ 'IDKONTO2'            , 'C' ,   7 ,  0 })
AADD(aDBf,{ 'IDTARIFA'            , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'IDPARTNER'           , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'IDZADUZ'             , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'IDZADUZ2'            , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'IDVD'                , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'BRDOK'               , 'C' ,   8 ,  0 })
AADD(aDBf,{ 'DATDOK'              , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'BRFAKTP'             , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'DATFAKTP'            , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'DATKURS'             , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'FV'                  , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'GKV'                 , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'GKV2'                , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'RABAT'               , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'PREVOZ'              , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'CARDAZ'              , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'BANKTR'              , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'SPEDTR'              , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'ZAVTR'               , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'NV'                  , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'RABATV'              , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'POREZV'              , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'MARZA'               , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'VPV'                 , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'VPVSAP'              , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'MARZA2'              , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'MPV'                 , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'POREZ'               , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'POREZ2'              , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'MPVSAPP'             , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'IDROBA'              , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'KOLICINA'            , 'N' ,  19 ,  7 })
AADD(aDBf,{ 'GKol'                , 'N' ,  19 ,  7 })
AADD(aDBf,{ 'GKol2'               , 'N' ,  19 ,  7 })
AADD(aDBf,{ 'PORVT'               , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'UPOREZV'             , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'PRUCMP'              , 'N' ,  20 ,  8 })
AADD(aDBf,{ 'PORPOT'              , 'N' ,  20 ,  8 })

if (nArea==-1 .or. nArea==(F_FINMAT))
	//FINMAT.DBF

	if !File2(PRIVPATH+"FINMAT.dbf")
    		DBcreate2(PRIVPATH+'FINMAT.DBF',aDbf)
	endif

	f01_create_index("1","idFirma+IdVD+BRDok",PRIVPATH+"FINMAT")
endif


if (nArea==-1 .or. nArea==(F_OBJEKTI))

	cImeTbl:=KUMPATH+"OBJEKTI.DBF"
	aDbf:={}
	AADD(aDbf, {"id","C",2,0})
	AADD(aDbf, {"naz","C",10,0})
	AADD(aDbf, {"IdObj","C", 7,0})

	if !File2(cImeTbl)
		DBCREATE2(cImeTbl, aDbf)
	endif

	f01_create_index("ID", "ID", cImeTbl)
	f01_create_index("NAZ", "NAZ", cImeTbl)
	f01_create_index("IdObj", "IdObj", cImeTbl)

endif


if (nArea==-1 .or. nArea==(F_K1))
	aDbf:={}
	AADD(aDbf, {"id","C",4,0})
	AADD(aDbf, {"naz","C",20,0})
	cImeTbl:=KUMPATH+"K1.DBF"
	if !File2(cImeTbl)
		DBCREATE2(KUMPATH+"K1",aDbf)
	endif
	f01_create_index("ID", "ID", cImeTbl)
	f01_create_index("NAZ", "NAZ", cImeTbl)
endif


if IsPlanika()

//ProdNc.Dbf

aDbf:={}
AADD(aDBf,{ 'PKONTO'             , 'C' ,   7 ,  0 })
AADD(aDBf,{ 'IDROBA'             , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'IDTARIFA'           , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'IDVD'               , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'BRDOK'              , 'C' ,   8 ,  0 })
AADD(aDBf,{ 'DATDOK'             , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'NC'                 , 'N' ,  20 ,  8 })

// kolicina kod posljednje nabavke
AADD(aDBf,{ 'KOLICINA'           , 'N' ,  12 ,  2 })


if (nArea==-1 .or. nArea==(F_PRODNC))
	if !File2(KUMPATH+"PRODNC.dbf")
    		DBcreate2(KUMPATH+'PRODNC.DBF',aDbf)
	endif

	f01_create_index("PRODROBA","PKONTO+IDROBA",KUMPATH+"PRODNC")
endif

//RVrsta.Dbf
aDbf:={}
AADD(aDBf,{ 'ID'              , 'C' ,  1 ,  0 })
AADD(aDBf,{ 'NAZ'             , 'C' , 30 ,  0 })
if (nArea==-1 .or. nArea==(F_RVRSTA))
	if !File2(SIFPATH+"RVRSTA.dbf")
    		DBcreate2(SIFPATH+'RVRSTA.DBF',aDbf)
	endif

	f01_create_index("ID","ID",SIFPATH+"RVRSTA")
	f01_create_index("NAZ", "NAZ", SIFPATH+"RVRSTA")
endif


//IsPlanika()
endif

return


/*  *void TDbKalk::obaza(int i)
 *   otvara odgovarajucu tabelu
 *
 *
 */

*void TDbKalk::obaza(int i)


method obaza (i)
local lIdIDalje
local cDbfName

lIdiDalje:=.f.



if i==F_PRIPR .or. i==F_FINMAT .or. i==F_PRIPR2 .or. i==F_PRIPR9
	lIdiDalje:=.t.
endif

if i==F__KALK .or. i==F__ROBA .or. i==F__PARTN
	lIdiDalje:=.t.
endif

if i==F_KALK .or. i=F_DOKS .or. i==F_ROBA .or. i==F_TARIFA .or. i==F_PARTN  .or. i==F_TNAL   .or. i==F_TDOK  .or. i==F_KONTO
	lIdiDalje:=.t.
endif

if i==F_TRFP .or. i==F_VALUTE .or. i==F_KONCIJ .or. i==F_SAST  .or. i==F_BARKOD
	lIdiDalje:=.t.
endif

if i==F_PARAMS .or. i==F_GPARAMS .or. i==F_GPARAMSP .or. i==F_KORISN .or. i==F_MPARAMS .or. i==F_KPARAMS .or. i==F_SECUR .or. i==F_ADRES
	lIdiDalje:=.t.
endif

if i==F_KONIZ .or. i==F_KOLIZ .or. i==F_IZVJE .or. i==F_ZAGLI
	lIdiDalje:=.t.
endif

if i==F_OBJEKTI .or. i==F_K1
	lIdiDalje:=.t.
endif

if is_doksrc()
	if i==F_P_DOKSRC .or. i==F_DOKSRC
		lIdiDalje := .t.
	endif
endif

if IsPlanika()
	if i==F_PRODNC .or. i==F_RVRSTA
		lIdiDalje:=.t.
	endif
endif


if (gSecurity=="D" .and. (i==F_EVENTS .or. i==F_EVENTLOG .or. i==F_USERS .or. i==F_GROUPS .or. i==F_RULES))
	lIdiDalje:=.t.
endif

if lIdiDalje
	cDbfName:=DBFName(i,.t.)
	if gAppSrv
		? "OPEN: " + cDbfName + ".DBF"
		if !File2(cDbfName + ".DBF")
			? "Fajl " + cDbfName + ".dbf ne postoji!!!"
			use
			return
		endif
	endif

	select(i)
	USE_EXCLUSIVE (cDbfName)
else
	use
	return
endif


return


/*  *void TDbKalk::ostalef()
 *   Ostalef funkcije (bivsi install modul)
 *  biljeska:  sifra: SIGMAXXX
*/

*void TDbKalk::ostalef()

method ostalef()

if pitanje(,"Formirati Bosanski sort","N")=="D"
   f01_create_index("NAZ_B","BTOEU(Naz)",SIFPATH+"ROBA")
endif

if pitanje(,"Formirati KALKS ?","N")=="D"

aDbf:={}
AADD(aDBf,{ 'IDFIRMA'             , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'IDROBA'              , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'IDVD'                , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'BRDOK'               , 'C' ,   8 ,  0 })
AADD(aDBf,{ 'DATDOK'              , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'IDPARTNER'           , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'RBR'                 , 'C' ,   3 ,  0 })
AADD(aDBf,{ 'KOLICINA'            , 'N' ,  12 ,  3 })
AADD(aDBf,{ 'GKOLICINA'           , 'N' ,  12 ,  3 })
AADD(aDBf,{ 'GKOLICIN2'           , 'N' ,  12 ,  3 })
AADD(aDBf,{ 'NC'                  , 'N' ,  15 ,  8 })
AADD(aDBf,{ 'TMARZA'              , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'MARZA'               , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'VPC'                 , 'N' ,  12 ,  4 })
AADD(aDBf,{ 'RABATV'              , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'TMARZA2'             , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'MARZA2'              , 'N' ,  15 ,  8 })
AADD(aDBf,{ 'MPC'                 , 'N' ,  15 ,  8 })
AADD(aDBf,{ 'IDTARIFA'            , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'MPCSAPP'             , 'N' ,  12 ,  4 })
AADD(aDBf,{ 'MKONTO'              , 'C' ,   7 ,  0 })
AADD(aDBf,{ 'PKONTO'              , 'C' ,   7 ,  0 })
AADD(aDBf,{ 'RokTr'               , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'MU_I'                , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'PU_I'                , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'ERROR'               , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'PODBR'               , 'C' ,   2 ,  0 })

if Pitanje(,"KALKS vec postoji, nulirati je ?","N")=="D"
    ferase(KUMPATH+'KALKS.CDX')
    ferase(KUMPATH+'KALKS.DBF')
endif

if !File2(KUMPATH+'KALKS.DBF')
 ferase(KUMPATH+'KALKS.CDX')
 dbcreate2(KUMPATH+'KALKS.DBF',aDbf)
endif

f01_create_index("1","idFirma+IdVD+BrDok+RBr",KUMPATH+"KALKS")
f01_create_index("2","idFirma+idvd+brdok+IDTarifa",KUMPATH+"KALKS")
// 3 - vodjenje magacina
f01_create_index("3","idFirma+mkonto+idroba+dtos(datdok)+podbr+MU_I+IdVD",KUMPATH+"KALKS")
// 4 - vodjenje prodavnice
f01_create_index("4","idFirma+Pkonto+idroba+dtos(datdok)+podbr+PU_I+IdVD",KUMPATH+"KALKS")
f01_create_index("5","idFirma+dtos(datdok)+podbr+idvd+brdok",KUMPATH+"KALKS")
f01_create_index("6","idFirma+IdTarifa+idroba",KUMPATH+"KALKS")
f01_create_index("7","idroba",KUMPATH+"KALKS")
f01_create_index("8","mkonto",KUMPATH+"KALKS")
f01_create_index("9","pkonto",KUMPATH+"KALKS")
f01_create_index("D","datdok",KUMPATH+"KALKS")

endif

return


/*  *void TDbKalk::konvZn()
 *   koverzija 7->8 baze podataka KALK
 */

*void TDbKalk::konvZn()

method konvZn()
LOCAL cIz:="7", cU:="8", aPriv:={}, aKum:={}, aSif:={}
LOCAL GetList:={}, cSif:="D", cKum:="D", cPriv:="D"

if !gAppSrv
	if !sifra_za_koristenje_opcije("KZ      ")
		return
	endif
	Box(,8,50)
  	@ m_x+2, m_y+2 SAY "Trenutni standard (7/8)        " GET cIz   VALID   cIz$"78"  PICT "9"
  	@ m_x+3, m_y+2 SAY "Konvertovati u standard (7/8/A)" GET cU    VALID    cU$"78A" PICT "@!"
  	@ m_x+5, m_y+2 SAY "Konvertovati sifrarnike (D/N)  " GET cSif  VALID  cSif$"DN"  PICT "@!"
  	@ m_x+6, m_y+2 SAY "Konvertovati radne baze (D/N)  " GET cKum  VALID  cKum$"DN"  PICT "@!"
  	@ m_x+7, m_y+2 SAY "Konvertovati priv.baze  (D/N)  " GET cPriv VALID cPriv$"DN"  PICT "@!"
  	READ
  	IF LASTKEY()==K_ESC
		BoxC()
		RETURN
	ENDIF
  	IF Pitanje(,"Jeste li sigurni da zelite izvrsiti konverziju (D/N)","N")=="N"
    		BoxC()
		RETURN
  	ENDIF
 	BoxC()
else
	?
	cKonvertTo:=IzFmkIni("FMK","KonvertTo","78",EXEPATH)

	if cKonvertTo=="78"
		cIz:="7"
		cU:="8"
		? "Trenutni standard: " + cIz
		? "Konvertovati u: " + cU
	elseif cKonvertTo=="87"
		cIz:="8"
		cU:="7"
		? "Trenutni standard: " + cIz
		? "Konvertovati u: " + cU
	else // pitaj
		?
		@ 10, 2 SAY "Trenutni standard (7/8)        " GET cIz VALID cIz$"78" PICT "9"
		?
		@ 11, 2 SAY "Konvertovati u standard (7/8/A)" GET cU VALID cU$"78A" PICT "@!"
		read
	endif
	cSif:="D"
	cKum:="D"
	cPriv:="D"
endif

aPriv := { F_PRIPR, F_FINMAT, F_PRIPR2, F_PRIPR9, F__KALK, F__ROBA,;
            F__PARTN, F_PORMP }
aKum  := { F_KALK, F_DOKS, F_KONIZ, F_IZVJE, F_ZAGLI, F_KOLIZ }
aSif  := { F_ROBA, F_TARIFA, F_PARTN, F_TNAL, F_TDOK, F_KONTO, F_TRFP,;
            F_VALUTE, F_KONCIJ, F_SAST }

IF cSif  == "N"
	aSif  := {}
ENDIF
IF cKum  == "N"
	aKum  := {}
ENDIF
IF cPriv == "N"
	aPriv := {}
ENDIF

f01_konv_zn_baza(aPriv,aKum,aSif,cIz,cU)

return



/*
function O_Log()

local cPom, cLogF

cPom:=KUMPATH+ SLASH + "SQL"
DirMak2(cPom)
cLogF:=cPom+ SLASH +replicate("0",8)

OKreSQLPar(cPom)

public gSQLSite:=field->_SITE_
public gSQLUser:=1
use

//postavi site
Gw("SET SITE "+Str(gSQLSite))
Gw("SET TODATABASE OFF")
Gw("SET MODUL "+gModul)
return

*/
