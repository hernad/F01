#ifndef SC_DEFINED
	#include "f01.ch"
#endif

#define D_KA_VERZIJA "04.03"
#define D_KA_PERIOD  "11.94-25.03.15"
#ifndef FMK_DEFINED
	#include "o_f01.ch"
#endif

#define GSCTEMP "c:"+SLASH+"sctemp"+SLASH

#define I_ID 1

#xcommand CLREZRET   =>  IspitajRezim(); CLOSERET
#xcommand FO_PRIPR   => select (F_FIPRIPR);   USE_EXCLUSIVE(SezRad(gDirFin)+"PRIPR") ; set order to 1
#xcommand FO_SUBAN   => select (F_SUBAN);  use  (SezRad(gDirFik)+"SUBAN")   ; set order to 1
#xcommand FO_ANAL    => select (F_ANAL);  use  (SezRad(gDirFik)+"ANAL")     ; set order to 1
#xcommand FO_SINT    => select (F_SINT);  use  (SezRad(gDirFik)+"SINT")     ; set order to 1
#xcommand FO_BBKLAS  => select (F_BBKLAS);  USE_EXCLUSIVE(SezRad(gDirFin)+"BBKLAS") ; set order to 1
#xcommand FO_IOS     => select (F_IOS);  USE_EXCLUSIVE(SezRad(gDirFin)+"IOS")       ; set order to 1
#xcommand FO_NALOG   => select (F_NALOG);  use  (SezRad(gDirFik)+"NALOG")   ; set order to 1
#xcommand FO_PNALOG  => select (F_PNALOG); USE_EXCLUSIVE(SezRad(gDirFin)+"PNALOG")  ; set order to 1
#xcommand FO_PSUBAN  => select (F_PSUBAN); USE_EXCLUSIVE(SezRad(gDirFin)+"PSUBAN")  ; set order to 1
#xcommand FO_PANAL   => select (F_PANAL); USE_EXCLUSIVE(SezRad(gDirFin)+"PANAL")    ; set order to 1
#xcommand FO_PSINT   => select (F_PSINT); USE_EXCLUSIVE(SezRad(gDirFin)+"PSINT")    ; set order to 1
#xcommand FO_PKONTO  => select (F_PKONTO); use  (SIFPATH+"pkonto") ; set order to tag "ID"

//FAKT
#xcommand XO_PRIPR   => select (F_FAPRIPR);   USE_EXCLUSIVE(SezRad(gDirFakt)+"PRIPR") alias xpripr; set order to 1
#xcommand XO_FAKT    => select (F_FAKT);  use  (SezRad(gDirFakK)+"FAKT")  alias xfakt; set order to 1
#xcommand XO_DOKS    => select(F_FADOKS);  use  (SezRad(gDirFakK)+"DOKS") alias xdoks; set order to 1
#xcommand XO_PARAMS    => select (F_POM); use (SezRad(gDirFakt)+"params"); set order to 1
#xcommand XO_POR       => select (F_POR); USE_EXCLUSIVE(SezRad(gDirFakt)+"por")

#xcommand O_K1 => select (F_K1); use  (KUMPATH+"k1") ; set order to tag "ID"
#xcommand O_OBJEKTI => select (F_OBJEKTI); use  (KUMPATH+"objekti") ; set order to tag "ID"

#xcommand O_POBJEKTI => select (F_POBJEKTI); use  (PRIVPATH+"pobjekti") ; set order to tag "ID"

#xcommand O_REKAP1 => select (F_REKAP1); USE_EXCLUSIVE(PRIVPATH+"rekap1") ; set order to tag "1"

#xcommand O_REKAP2 => select (F_REKAP2); USE_EXCLUSIVE(PRIVPATH+"rekap2") ; set order to tag "2"

#xcommand O_REKA22 => select (F_REKA22); USE_EXCLUSIVE(PRIVPATH+"reka22") ; set order to tag "1"


#xcommand O_RPT_TMP => select (F_RPT_TMP); USE_EXCLUSIVE(PRIVPATH+"rpt_tmp")
#xcommand O_R_UIO => select (F_R_UIO); USE_EXCLUSIVE(PRIVPATH+"r_uio")
#xcommand O_R_EXP => select (F_R_EXP); USE_EXCLUSIVE(PRIVPATH+"r_export")

#xcommand O_PRIPT => select (F_PRIPT); USE_EXCLUSIVE(PRIVPATH+"pript")
#xcommand O_CACHE => select (F_CACHE); USE_EXCLUSIVE(PRIVPATH+"cache")
