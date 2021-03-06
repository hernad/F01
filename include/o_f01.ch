#include "fmk_g.ch"


#xcommand O_ROBA   => select(F_ROBA);  use  (SIFPATH+"ROBA")  ; set order to tag "ID"
#xcommand O_TARIFA   => select(F_TARIFA);  use  (SIFPATH+"TARIFA")  ; set order to tag "ID"
#xcommand O_KONTO   => select(F_KONTO);  use  (SIFPATH+"KONTO") ; set order to tag "ID"
#xcommand O_TRFP    => select(F_TRFP);   use  (SIFPATH+"trfp")       ; set order to tag "ID"
#xcommand O_TRMP    => select(F_TRMP);   use  (SIFPATH+"trmp")       ; set order to tag "ID"
#xcommand O_PARTN   => select(F_PARTN);  use  (SIFPATH+"PARTN")  ; set order to tag "ID"
#xcommand O_TNAL   => select(F_TNAL);  use  (SIFPATH+"TNAL")         ; set order to tag "ID"
#xcommand O_TDOK   => select(F_TDOK);  use  (SIFPATH+"TDOK")         ; set order to tag "ID"
#xcommand O_KONCIJ => select(F_KONCIJ);  use  (SIFPATH+"KONCIJ")     ; set order to tag "ID"
#xcommand O_VALUTE => select(F_VALUTE);  use  (SIFPATH+"VALUTE")     ; set order to tag "ID"
#xcommand O_SAST   => select (F_SAST); use  (SIFPATH+"SAST")         ; set order to tag "ID"

#xcommand O_BARKOD  => select(F_BARKOD);  USE_EXCLUSIVE(PRIVPATH+"BARKOD"); set order to tag "1"

#xcommand O_RJ   => select(F_RJ);  use  (KUMPATH+"RJ")         ; set order to tag "ID"

#xcommand O_OPS   => select(F_OPS);  use  (SIFPATH+"OPS")         ; set order to tag "ID"

#xcommand O_REFER   => select(F_REFER);  use  (SIFPATH+"REFER")         ; set order to tag "ID"
#xcommand O_RNAL  => select(F_RNAL);  use  (SIFPATH+"RNAL")      ; set order to tag "ID"

#xcommand O_UGOV     => select(F_UGOV);  use  (KUMPATH+"UGOV")     ; set order to tag "ID"

#xcommand O_FDEVICE     => select(F_FDEVICE);  use  (PRIVPATH+"FDEVICE")     ; set order to tag "1"

#xcommand O_RUGOV    => select(F_RUGOV);  use  (KUMPATH+"RUGOV")   ; set order to tag "ID"

#xcommand O_GEN_UG   => select(F_GEN_UG);  use  (KUMPATH+"GEN_UG")  ; set order to tag "DAT_GEN"

#xcommand O_G_UG_P  => select(F_G_UG_P);  use  (KUMPATH+"GEN_UG_P")   ; set order to tag "DAT_GEN"

// grupe i karakteristike
#xcommand O_STRINGS  => select(F_STRINGS);  use  (SIFPATH + "STRINGS")   ; set order to tag "1"


// KALK

#xcommand O_PRIPR   => select(F_PRIPR); USE_EXCLUSIVE(PRIVPATH+"PRIPR") ; set order to 1
#xcommand O_S_PRIPR   => select(F_PRIPR); use (PRIVPATH+"PRIPR") ; set order to 1

#xcommand O_PRIPRRP   => select (F_PRIPRRP);   USE_EXCLUSIVE(strtran(cDirPriv,goModul:oDataBase:cSezonDir,SLASH)+"PRIPR") alias priprrp ; set order to 1

#xcommand O_PRIPR2  => select(F_PRIPR2); USE_EXCLUSIVE(PRIVPATH+"PRIPR2") ; set order to 1
#xcommand O_PRIPR9  => select(F_PRIPR9); USE_EXCLUSIVE(PRIVPATH+"PRIPR9") ; set order to 1
#xcommand O__KALK  => select(F__KALK); USE_EXCLUSIVE(PRIVPATH+"_KALK")

#xcommand O_FINMAT  => select(F_FINMAT); USE_EXCLUSIVE(PRIVPATH+"FINMAT")    ; set order to 1

#xcommand O_KALK   => select(F_KALK);  use  (KUMPATH+"KALK")  ; set order to 1
#xcommand O_KALKSEZ   => select(F_KALKSEZ);  use  (KUMPATH+"2005"+SLASH+"KALK") alias kalksez ; set order to 1
#xcommand O_ROBASEZ   => select(F_ROBASEZ);  use  (SIFPATH+"2005"+SLASH+"ROBA") alias robasez ; set order to tag "ID"
#xcommand O_KALKX  => select(F_KALK);  USE_EXCLUSIVE (KUMPATH+"KALK")  ; set order to 1

#xcommand O_KALKS  => select(F_KALKS);  use  (KUMPATH+"KALKS")  ; set order to 1
#xcommand O_KALKREP => if gKalks; select(F_KALK);use;select(F_KALK); use  (KUMPATH+"KALKS") alias KALK ; set order to 1;else; select(F_KALK);  use  (KUMPATH+"KALK")  ; set order to 1; end

#xcommand O_SKALK   => select(F_KALK);  use  (KUMPATH+"KALK")  alias PRIPR ; set order to 1
#xcommand O_DOKS    => select(F_DOKS);  use  (KUMPATH+"DOKS")     ; set order to 1
#xcommand O_DOKS2   => select(F_DOKS2);  use  (KUMPATH+"DOKS2")     ; set order to 1
#xcommand O_PORMP  => select(F_PORMP); USE_EXCLUSIVE(PRIVPATH+"PORMP")     ; set order to 1

#xcommand O__ROBA   => select(F__ROBA);  use  (PRIVPATH+"_ROBA")
#xcommand O__PARTN   => select(F__PARTN);  use  (PRIVPATH+"_PARTN")


#xcommand O_KONTO   => select(F_KONTO);  use  (SIFPATH+"KONTO") ; set order to tag "ID"
#xcommand O_TRFP    => select(F_TRFP);   use  (SIFPATH+"trfp")       ; set order to tag "ID"
#xcommand O_TRMP    => select(F_TRMP);   use  (SIFPATH+"trmp")       ; set order to tag "ID"
#xcommand O_PARTN   => select(F_PARTN);  use  (SIFPATH+"PARTN")  ; set order to tag "ID"
#xcommand O_TNAL   => select(F_TNAL);  use  (SIFPATH+"TNAL")         ; set order to tag "ID"
#xcommand O_TDOK   => select(F_TDOK);  use  (SIFPATH+"TDOK")         ; set order to tag "ID"
#xcommand O_KONCIJ => select(F_KONCIJ);  use  (SIFPATH+"KONCIJ")     ; set order to tag "ID"
#xcommand O_VALUTE => select(F_VALUTE);  use  (SIFPATH+"VALUTE")     ; set order to tag "ID"
#xcommand O_SAST   => select (F_SAST); use  (SIFPATH+"SAST")         ; set order to tag "ID"
#xcommand O_BANKE   => select (F_BANKE) ; use (SIFPATH+"BANKE")  ; set order to tag "ID"

#xcommand O_LOGK   => select (F_LOGK) ; use  (KUMPATH+"LOGK")         ; set order to tag "NO"
#xcommand O_LOGKD  => select (F_LOGKD); use  (KUMPATH+"LOGKD")        ; set order to tag "NO"

#xcommand O_BARKOD  => select(F_BARKOD);  use (PRIVPATH+"BARKOD"); set order to tag "1"


#xcommand O_FAKT      => select (F_FAKT) ;   use  (KUMPATH+"FAKT") ; set order to tag  "1"
#xcommand O__FAKT     => select(F__FAKT)  ; cmxAutoOpen(.f.);  USE_EXCLUSIVE(PRIVPATH+"_FAKT") ; cmxAutoOpen(.t.)
#xcommand O__ROBA   => select(F__ROBA);  use  (PRIVPATH+"_ROBA")
#xcommand O_PFAKT     => select (F_FAKT);  use  (KUMPATH+"FAKT") alias PRIPR; set order to tag   "1"
#xcommand O_DOKS      => select(F_DOKS);    use  (KUMPATH+"DOKS")  ; set order to tag "1"
#xcommand O_DOKS2     => select(F_DOKS2);    use  (KUMPATH+"DOKS2")  ; set order to tag "1"

#xcommand O_FTXT    => select (F_FTXT);    use (SIFPATH+"ftxt")    ; set order to tag "ID"
#xcommand O_UPL      => select (F_UPL); use  (KUMPATH+"UPL")         ; set order to tag "1"
#xcommand O_DEST     => select(F_DEST);  use  (SIFPATH+"DEST")     ; set order to tag "ID"
#xcommand O_POR      => select 95; cmxAutoOpen(.f.); USE_EXCLUSIVE(PRIVPATH+"por")  ; cmxAutoOpen(.t.)

#xcommand O_VRSTEP => SELECT (F_VRSTEP); USE (SIFPATH+"VRSTEP"); set order to tag "ID"
#xcommand O_OPS    => SELECT (F_OPS)   ; USE (SIFPATH+"OPS"); set order to tag "ID"

#xcommand O_RELAC  => SELECT (F_RELAC) ; USE (SIFPATH+"RELAC"); set order to tag "ID"
#xcommand O_VOZILA => SELECT (F_VOZILA); USE (SIFPATH+"VOZILA"); set order to tag "ID"
#xcommand O_KALPOS => SELECT (F_KALPOS); USE (KUMPATH+"KALPOS"); set order to tag "1"
#xcommand O_CROBA  => SELECT (F_CROBA) ; USE (gCENTPATH+"CROBA"); set order to tag "IDROBA"

#xcommand O_ADRES     => select (F_ADRES); use (f01_transform_dbf_name(SIFPATH+"adres")) ; set order to tag "ID"

#xcommand O_DOKSTXT  => select (F_DOKSTXT); use (f01_transform_dbf_name(SIFPATH+"dokstxt")) ; set order to tag "ID"

#xcommand O_EVENTS  => select (F_EVENTS); use (f01_transform_dbf_name(goModul:oDatabase:cSigmaBD+SLASH+"security"+SLASH+"events")) ; set order to tag "ID"

#xcommand O_EVENTLOG  => select (F_EVENTLOG); use (f01_transform_dbf_name(goModul:oDatabase:cSigmaBD+SLASH+"security"+SLASH+"eventlog")) ; set order to tag "ID"

#xcommand O_USERS  => select (F_USERS); use (f01_transform_dbf_name(goModul:oDatabase:cSigmaBD+SLASH+"security"+SLASH+"users")) ; set order to tag "ID"

#xcommand O_GROUPS  => select (F_GROUPS); use (f01_transform_dbf_name(goModul:oDatabase:cSigmaBD+SLASH+"security"+SLASH+"groups")) ; set order to tag "ID"

#xcommand O_RULES  => select (F_RULES); use (f01_transform_dbf_name(goModul:oDatabase:cSigmaBD+SLASH+"security"+SLASH+"rules")) ; set order to tag "ID"

#xcommand O_FMKRULES  => select (F_FMKRULES); use (SIFPATH+"FMKRULES") ; set order to tag "2"

//KALK ProdNC
#xcommand O_PRODNC   => select(F_PRODNC);  use  (KUMPATH+"PRODNC")  ; set order to tag "PRODROBA"

//KALK RVrsta
#xcommand O_RVRSTA   => select(F_RVRSTA);  use  (SIFPATH+"RVRSTA")  ; set order to tag "ID"

// stampa PDV racuna
#xcommand O_DRN => select(F_DRN); use (PRIVPATH+"DRN"); set order to tag "1"
#xcommand O_RN => select(F_RN); use (PRIVPATH+"RN"); set order to tag "1"
#xcommand O_DRNTEXT => select(F_DRNTEXT); use (PRIVPATH+"DRNTEXT"); set order to tag "1"
#xcommand O_DOKSPF => select(F_DOKSPF); use (KUMPATH+"DOKSPF"); set order to tag "1"

#xcommand O_R_EXP => select (F_R_EXP); USE_EXCLUSIVE(PRIVPATH+"r_export")

#xcommand O_LOKAL => select (F_LOKAL); USE_EXCLUSIVE(SIFPATH+"lokal")

// tabele provjere integriteta
#xcommand O_DINTEG1 => SELECT (F_DINTEG1); USE_EXCLUSIVE(KUMPATH+"DINTEG1"); set order to tag "1"
#xcommand O_DINTEG2 => SELECT (F_DINTEG2); USE_EXCLUSIVE(KUMPATH+"DINTEG2"); set order to tag "1"
#xcommand O_INTEG1 => SELECT (F_INTEG1); USE_EXCLUSIVE(KUMPATH+"INTEG1"); set order to tag "1"
#xcommand O_INTEG2 => SELECT (F_INTEG2); USE_EXCLUSIVE(KUMPATH+"INTEG2"); set order to tag "1"
#xcommand O_ERRORS => SELECT (F_ERRORS); USE_EXCLUSIVE(PRIVPATH+"ERRORS"); set order to tag "1"


// tabele DOK_SRC
#xcommand O_DOKSRC => SELECT (F_DOKSRC); USE (KUMPATH+"DOKSRC"); set order to tag "1"
#xcommand O_P_DOKSRC => SELECT (F_P_DOKSRC); USE_EXCLUSIVE(PRIVPATH+"P_DOKSRC"); set order to tag "1"

#xcommand O_RELATION => SELECT (F_RELATION); USE (SIFPATH+"RELATION"); set order to tag "1"

#xcommand O_TEMP => select (F_TEMP); USE_EXCLUSIVE(PRIVPATH+"temp")
