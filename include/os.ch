#ifndef SC_DEFINED
	#include "f01.ch"
#endif

#define D_OS_VERZIJA "02.08"
#define D_OS_PERIOD '08.96-20.09.07'

#ifndef FMK_DEFINED
	#include "o_f01.ch"
#endif

#xcommand O_OS   => select (F_OS); use (KUMPATH+"OS"); set order to tag "1"
#xcommand O_OSX   => select (F_OS); USE_EXCLUSIVE(KUMPATH+"OS"); set order to tag "1"
#xcommand O_PROMJ   => select (F_PROMJ); use (KUMPATH+"PROMJ"); set order to tag "1"
#xcommand O_PROMJX   => select (F_PROMJ); USE_EXCLUSIVE(KUMPATH+"PROMJ"); set order to tag "1"
#xcommand O_INVENT  =>  select (F_INVENT); USE_EXCLUSIVE(PRIVPATH+"INVENT"); set order to tag "1"

#xcommand O_AMORT   => select (F_AMORT); use (SIFPATH+"AMORT"); set order to tag "ID"
#xcommand O_REVAL   => select (F_REVAL); use (SIFPATH+"REVAL"); set order to tag "ID"
#xcommand O_RJ   => select (F_RJ); use (KUMPATH+"RJ"); set order to tag "ID"
#xcommand O_K1   => select (F_K1); use (KUMPATH+"K1"); set order to tag "ID"


