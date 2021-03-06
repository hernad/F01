#ifndef SC_DEFINED
	#include "f01.ch"
#endif

#define D_EP_VERZIJA "01.31"
#define D_EP_PERIOD '01.06-09.02.11'

#ifndef FMK_DEFINED
	#include "o_f01.ch"
#endif

#xcommand O_P_KUF     => select (F_P_KUF);   USE_EXCLUSIVE(PRIVPATH+"P_KUF") ; set order to tag "r_br"

#xcommand O_P_KIF     => select (F_P_KIF);   USE_EXCLUSIVE(PRIVPATH+"P_KIF") ; set order to tag "r_br"

#xcommand O_KUF     => select (F_KUF);   USE_EXCLUSIVE(KUMPATH+"KUF") ; set order to tag "datum"
#xcommand O_KIF     => select (F_KIF);   USE_EXCLUSIVE(KUMPATH+"KIF") ; set order to tag "datum"

#xcommand O_PDV     => select (F_PDV);   USE_EXCLUSIVE(KUMPATH+"PDV") ; set order to tag "datum"

#xcommand O_SG_KIF   => select(F_SG_KIF);  use  (KUMPATH+"SG_KIF")  ; set order to tag "ID"

#xcommand O_SG_KUF   => select(F_SG_KUF);  use  (KUMPATH+"SG_KUF")  ; set order to tag "ID"


#xcommand O_R_KUF   => select(F_R_KUF);  use  (PRIVPATH+"R_KUF") 
#xcommand O_R_KIF   => select(F_R_KIF);  use  (PRIVPATH+"R_KIF")


#xcommand O_R_PDV   => select(F_R_PDV);  use  (PRIVPATH+"R_PDV")  




