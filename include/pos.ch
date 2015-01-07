#ifndef SC_DEFINED
	#include "f01.ch"
#endif

#define D_PO_VERZIJA "03.35"
#define D_PO_PERIOD  "09.97-01.08.14"

#define SC_HEADER

#ifdef HOPS
  #define G_MODUL 'HOPS' 
#else
  #define G_MODUL 'TOPS' 
#endif

#ifndef FMK_DEFINED
	#include "o_f01.ch"
#endif

// definicija korisnickih nivoa
#define L_SYSTEM           "0"
#define L_ADMIN            "0"
#define L_UPRAVN           "1"
#define L_UPRAVN_2         "2"
#define L_PRODAVAC         "3"

// ulaz / izlaz roba /sirovina
#define R_U       "1"           // roba - ulaz
#define R_I       "2"           //      - izlaz
#define S_U       "3"           // sirovina - ulaz
#define S_I       "4"           //          - izlaz
#define SP_I      "I"           // inventura - stanje
#define SP_N      "N"           // nivelacija

// vrste dokumenata
#define VD_RN        "42"       // racuni
#define VD_ZAD       "16"       // zaduzenje
#define VD_OTP       "95"       // otpis
#define VD_REK       "98"       // reklamacija
#define VD_INV       "IN"       // inventura
#define VD_NIV       "NI"       // nivelacija
#define VD_RZS       "96"       // razduzenje sirovina-otprema pr. magacina
#define VD_PCS       "00"       // pocetno stanje
#define VD_PRR       "01"       // prenos realizacije iz prethodnih sezona
#define VD_CK        "90"       // dokument cek
#define VD_SK        "91"       // dokument sindikalni kredit
#define VD_GP        "92"       // dokument garatno pismo
#define VD_PP        "88"       // dokument polog pazara
#define VD_ROP       "99"       // reklamacije ostali podaci

#define DOK_ULAZA "00#16"
#define DOK_IZLAZA "42#01#96#98"

// vrste zaduzenja
#define ZAD_NORMAL   "0"
#define ZAD_OTPIS    "1"

// flagovi da li je slog sa kase prebacen na server
#define OBR_NIJE     "1"
#define OBR_JEST     "0"

// flagovi da li je racun placen
#define PLAC_NIJE    "1"
#define PLAC_JEST    "0"

// ako ima potrebe, brojeve zaokruzujemo na
#define N_ROUNDTO    2
#define I_ID         1
#define I_ID2        2


// Prometne datoteke
#xcommand O_DOKS      => SELECT (F_DOKS); USE (KUMPATH+"DOKS"); set order to 1
#xcommand O_POS       => SELECT (F_POS); USE (KUMPATH+"POS"); set order to 1
#xcommand O_RNGPLA    => SELECT (F_RNGPLA); USE (KUMPATH+"RNGPLA"); set order to 1
#xcommand O_PROMVP    => SELECT (F_PROMVP); USE (KUMPATH+"PROMVP"); set order to 1

// exclusive use
#xcommand OX_DOKS     => SELECT (F_DOKS); USE_EXCLUSIVE(KUMPATH+"DOKS"); set order to 1
#xcommand OX_POS      => SELECT (F_POS); USE_EXCLUSIVE(KUMPATH+"POS"); set order to 1
#xcommand OX_RNGPLA   => SELECT (F_RNGPLA); USE_EXCLUSIVE(KUMPATH+"RNGPLA"); set order to 1
#xcommand OX_PROMVP    => SELECT (F_PROMVP); USE_EXCLUSIVE(KUMPATH+"PROMVP"); set order to 1

// Pomocne prometne datoteke
#xcommand O__POS      => SELECT (F__POS)  ; USE_EXCLUSIVE(PRIVPATH+"_POS")  ; set order to 1
#xcommand O__PRIPR    => SELECT (F__PRIPR); USE_EXCLUSIVE(PRIVPATH+"_PRIPR"); set order to 1
#xcommand O_PRIPRZ    => SELECT (F_PRIPRZ); USE_EXCLUSIVE(PRIVPATH+"PRIPRZ"); set order to 1
#xcommand O_PRIPRG    => SELECT (F_PRIPRG); USE_EXCLUSIVE(PRIVPATH+"PRIPRG"); set order to 1
#xcommand O__POSP     => select(F__POSP)  ; cmxAutoOpen(.f.);  USE_EXCLUSIVE(PRIVPATH+"_POSP") ; cmxAutoOpen(.t.)
#xcommand O__DOKSP     => select(F__DOKSP)  ; cmxAutoOpen(.f.);  USE_EXCLUSIVE(PRIVPATH+"_DOKSP") ; cmxAutoOpen(.t.)


// Privatne datoteke
#xcommand O_K2C       => SELECT (F_K2C)   ; USE (PRIVPATH+"K2C")   ; set order to 1
#xcommand O_MJTRUR    => SELECT (F_MJTRUR); USE (PRIVPATH+"MJTRUR"); set order to 1
#xcommand O_ROBAIZ    => SELECT (F_ROBAIZ); USE (PRIVPATH+"ROBAIZ"); set order to 1
#xcommand O_RAZDR     => SELECT (F_RAZDR) ; USE (PRIVPATH+"RAZDR")
// exclusive use
#xcommand OX_K2C      => SELECT (F_K2C); USE_EXCLUSIVE(PRIVPATH+"K2C"); set order to 1
#xcommand OX_MJTRUR   => SELECT (F_MJTRUR); USE_EXCLUSIVE(PRIVPATH+"MJTRUR"); set order to 1
#xcommand OX_ROBAIZ   => SELECT (F_ROBAIZ); USE_EXCLUSIVE(PRIVPATH+"ROBAIZ"); set order to 1
#xcommand OX_RAZDR    => SELECT (F_RAZDR); USE_EXCLUSIVE(PRIVPATH+"RAZDR")

// SIFARNICI
#xcommand O_ROBA   => SELECT (F_ROBA); USE (gSIFPATH+"ROBA"); set order to tag "ID"
#xcommand O_SIROV  => SELECT (F_SIROV); USE (gSIFPATH+"SIROV"); set order to tag "ID"
#xcommand O_SAST   => SELECT (F_SAST); USE (gSIFPATH+"SAST"); set order to tag "ID"
#xcommand O_STRAD  => SELECT (F_STRAD); USE (gSIFPATH+"STRAD"); set order to tag "ID"
#xcommand O_OSOB   => SELECT (F_OSOB); USE (gSIFPATH+"OSOB"); set order to tag "ID"
#xcommand O_TARIFA => SELECT (F_TARIFA); USE (gSIFPATH+"TARIFA" ); set order to tag "ID"
#xcommand O_VALUTE => SELECT (F_VALUTE); USE (gSIFPATH+"VALUTE"); set order to tag "ID"
#xcommand O_VRSTEP => SELECT (F_VRSTEP); USE (gSIFPATH+"VRSTEP"); set order to tag "ID"
#xcommand O_KASE   => SELECT (F_KASE); USE (gSIFPATH+"KASE"); set order to tag "ID"
#xcommand O_ODJ    => SELECT (F_ODJ); USE (gSIFPATH+"ODJ"); set order to tag "ID"
#xcommand O_DIO    => SELECT (F_DIO); USE (gSIFPATH+"DIO"); set order to tag "ID"
#xcommand O_UREDJ  => SELECT (F_UREDJ); USE (gSIFPATH+"UREDJ"); set order to tag "ID"
#xcommand O_RNGOST => SELECT (F_RNGOST); USE (gSIFPATH+"RNGOST"); set order to tag "ID"
#xcommand O_MARS   => SELECT (F_MARS); USE (gSIFPATH+"MARS"); set order to tag "ID"

#xcommand OX_ROBA   => SELECT (F_ROBA); USE_EXCLUSIVE(gSIFPATH+"ROBA"); set order to tag "ID"
#xcommand OX_SIROV  => SELECT (F_SIROV); USE_EXCLUSIVE(gSIFPATH+"SIROV"); set order to tag "ID"
#xcommand OX_SAST   => SELECT (F_SAST); USE_EXCLUSIVE(gSIFPATH+"SAST"); set order to tag "ID"
#xcommand OX_STRAD  => SELECT (F_STRAD); USE_EXCLUSIVE(gSIFPATH+"STRAD")
#xcommand OX_OSOB   => SELECT (F_OSOB); USE_EXCLUSIVE(gSIFPATH+"OSOB")
#xcommand OX_TARIFA => SELECT (F_TARIFA); USE_EXCLUSIVE(gSIFPATH+"TARIFA" )
#xcommand OX_VALUTE => SELECT (F_VALUTE); USE_EXCLUSIVE(gSIFPATH+"VALUTE")
#xcommand OX_VRSTEP => SELECT (F_VRSTEP); USE_EXCLUSIVE(gSIFPATH+"VRSTEP")
#xcommand OX_KASE   => SELECT (F_KASE); USE_EXCLUSIVE(gSIFPATH+"KASE")
#xcommand OX_ODJ    => SELECT (F_ODJ); USE_EXCLUSIVE(gSIFPATH+"ODJ"); set order to tag "ID"
#xcommand OX_DIO    => SELECT (F_DIO); USE_EXCLUSIVE(gSIFPATH+"DIO"); set order to tag "ID"
#xcommand OX_UREDJ  => SELECT (F_UREDJ); USE_EXCLUSIVE(gSIFPATH+"UREDJ"); set order to tag "ID"
#xcommand OX_RNGOST => SELECT (F_RNGOST); USE_EXCLUSIVE(gSIFPATH+"RNGOST"); set order to tag "ID"
#xcommand OX_MARS   => SELECT (F_MARS); USE_EXCLUSIVE(gSIFPATH+"MARS"); set order to tag "ID"

