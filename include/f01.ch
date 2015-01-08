#define SC_DEFINED
#define SC_LIB_VER  "03.00"

#DEFINE BACKSLASH Chr(92)

#DEFINE SLASH hb_osPathSeparator()
#DEFINE USB_ROOT_PATH "F:" + SLASH
#define DRIVE_ROOT_PATH "C:" + SLASH

#ifdef __PLATFORM__UNIX
  #define DATA_ROOT "/F01/DATA"
#else
  #define DATA_ROOT DRIVE_ROOT_PATH+"SIGMA"
#endif

#define MODULE_ROOT "SIGMA"

#define DBFBASEPATH DATA_ROOT

#DEFINE DBUILD "HB1"

#define BOX_CHAR_USPRAVNO "|"

#define  MEMOEXTENS  "FPT"
#DEFINE INDEXEXTENS "CDX"
#DEFINE INDEXEXT "CDX"
#DEFINE DBFEXT "DBF"
#DEFINE MEMOEXT "FPT"
#DEFINE RDDENGINE "DBFCDX"
#DEFINE DRVPATH ":" + SLASH

#define NRED hb_eol()

#define P_NRED QOUT()

#include "sc_base.ch"
#include "inkey.ch"
#include "box.ch"
#include "dbedit.ch"
#include "set.ch"
#include "getexit.ch"

#command APPEND NCNL    =>  appblank2(.f.,.f.)

#command REPLSQL <f1> WITH <v1> [, <fN> WITH <vN> ]    ;
=> sql_repl(<"f1">,<v1>) [; sql_repl(<"fN">,<vN>) ];

#command REPLSQL TYPE <cTip> <f1> WITH <v1> [, <fN> WITH <vN> ]    ;
=> sql_repl(<"f1">,<v1>,0,<cTip>) [; sql_repl(<"fN">,<vN>,0,<cTip>) ];


#command DEL2                                                            ;
      => (nArr)->(DbDelete2())                                            ;
        ;(nTmpArr)->(DbDelete2())

#define DE_ADD  5
#define DE_DEL  6

#define P_KUMPATH  1
#define P_SIFPATH  2
#define P_PRIVPATH 3
#define P_TEKPATH  4
#define P_MODULPATH  5
#define P_KUMSQLPATH 6
#define P_ROOTPATH 7
#define P_EXEPATH 8
#define P_SECPATH 9


#command AP52 [FROM <(file)>]                                         ;
         [FIELDS <fields,...>]                                          ;
         [FOR <for>]                                                    ;
         [WHILE <while>]                                                ;
         [NEXT <next>]                                                  ;
         [RECORD <rec>]                                                 ;
         [<rest:REST>]                                                  ;
         [VIA <rdd>]                                                    ;
         [ALL]                                                          ;
                                                                        ;
      => __dbApp(                                                       ;
                  <(file)>, { <(fields)> },                             ;
                  <{for}>, <{while}>, <next>, <rec>, <.rest.>, <rdd>    ;
                )


#xcommand USE_EXCLUSIVE <(db)>                                       ;
          [VIA <rdd>]                                                ;
          [ALIAS <a>]                                                ;
          [<new: NEW>]                                               ;
          [<ro: READONLY>]                                           ;
          [INDEX <(index1)> [, <(indexn)>]]                          ;
          ;
          =>  PreUseEvent(<(db)>,.f.,gReadOnly)		 		               ;
          ;  my_dbUseArea(                                           ;
              <.new.>, <rdd>, <(db)>, <(a)>,                         ;
                  .f., gReadOnly       ;
              )                                                      ;
          ;
          [; dbSetIndex( <(index1)> )]                               ;
          [; dbSetIndex( <(indexn)> )]



#command USEW <(db)>                                                     ;
        [VIA <rdd>]                                                ;
        [ALIAS <a>]                                                ;
        [<new: NEW>]                                               ;
        [<ro: READONLY>]                                           ;
        [INDEX <(index1)> [, <(indexn)>]]                          ;
        ;
        => my_dbUseArea(                                                ;
                    <.new.>, <rdd>, <(db)>, <(a)>,                      ;
                    .t., .f.      ;
                    )                                                     ;
        ;
        [; dbSetIndex( <(index1)> )]                                      ;
        [; dbSetIndex( <(indexn)> )]



#command USER <(db)>                                                    ;
        [VIA <rdd>]                                                ;
        [ALIAS <a>]                                                ;
        [<new: NEW>]                                               ;
        [<ro: READONLY>]                                           ;
        [INDEX <(index1)> [, <(indexn)>]]                          ;
        ;
        => my_dbUseArea(                                                     ;
            <.new.>, <rdd>, <(db)>, <(a)>,                      ;
            .t., .t.                                           ;
          )                                                     ;
         ;
        [; dbSetIndex( <(index1)> )]                                      ;
        [; dbSetIndex( <(indexn)> )]


#ifndef FMK_DEFINED
	#include "o_f01.ch"
#endif

#include "o_f01_params.ch"

// #include "cm52.ch"

//korisnicke licence
#define AL_INET 1
#define AL_STANDARD 2
#define AL_SILVER 3
#define AL_GOLD 4
#define AL_PLATINIUM 5


#define ROUND(x,y)  rOund(rOund(x,8),y)
#define round(x,y)  rOund(rOund(x,8),y)
#define Round(x,y)  rOund(rOund(x,8),y)
#define RounD(x,y)  rOund(rOund(x,8),y)
#define ROunD(x,y)  rOund(rOund(x,8),y)
#define ROUnD(x,y)  rOund(rOund(x,8),y)
#define rounD(x,y)  rOund(rOund(x,8),y)
