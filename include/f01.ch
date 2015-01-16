#define SC_DEFINED
#define SC_LIB_VER  "03.00"

#DEFINE BACKSLASH Chr(92)

#DEFINE SLASH hb_osPathSeparator()
#DEFINE USB_ROOT_PATH "F:" + SLASH


#ifdef __PLATFORM__UNIX

  #define DRIVE_ROOT_PATH "/F01/"
  #define DATA_ROOT "/F01/"

#else
  #define DRIVE_ROOT_PATH "C:" + SLASH
  #define DATA_ROOT DRIVE_ROOT_PATH+"F01"+SLASH
#endif

#define D_VERZIJA "CDX"

#define MODULE_ROOT "SIGMA"

#define DBFBASEPATH DATA_ROOT

#DEFINE DBUILD "HB1"

#define BOX_CHAR_USPRAVNO "|"
#define BOX_CHAR_HORIZONT "-"
#define BOX_CHAR_HORIZONT_2 "_"


#define  MEMOEXTENS  "FPT"
#DEFINE INDEXEXTENS "cdx"
#DEFINE INDEXEXT "cdx"
#DEFINE DBFEXT "DBF"
#DEFINE MEMOEXT "FPT"
#DEFINE RDDENGINE "DBFCDX"
#DEFINE DRVPATH ":" + SLASH

#define NOVI_RED hb_eol()
#define NOVI_RED_DOS Chr(13)+Chr(10)

#define P_NOVI_RED QOUT()


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



#define EXEPATH   tekuci_direktorij()

#define SIFPATH   trim(cDirSif)+SLASH
#define PRIVPATH  trim(cDirPriv)+SLASH
#define KUMPATH   trim(cDirRad)+SLASH

#define CURDIR    "."+SLASH

#command ESC_EXIT  => if lastkey()=K_ESC;
                      ;exit             ;
                      ;endif

#command ESC_RETURN <x> => if lastkey()=K_ESC;
                           ;return <x>       ;
                           ;endif

#command ESC_RETURN    => if lastkey()=K_ESC;
                           ;return        ;
                           ;endif
#command HSEEK <xpr>     => dbSeek(<xpr> ,.f.)
#command MSEEK <xpr>             => dbSeek(<xpr> )


#command SET MRELATION                                                  ;
         [<add:ADDITIVE>]                                               ;
         [TO <key1> INTO <(alias1)> [, [TO] <keyn> INTO <(aliasn)>]]    ;
                                                                        ;
      => if ( !<.add.> )                                                ;
       ;    dbClearRel()                                                ;
       ; end                                                            ;
                                                                        ;
       ; dbSetRelation( <(alias1)>,{||'1'+<key1>}, "'1'+"+<"key1"> )      ;
      [; dbSetRelation( <(aliasn)>,{||'1'+<keyn>}, "'1'+"+<"keyn"> ) ]


#command EJECTA0          => qqout(chr(13)+chr(10)+chr(12))  ;
                           ; setprc(0,0)             ;
                           ; A:=0

#command EJECTNA0         => qqout(chr(13)+chr(10)+chr(18)+chr(12))  ;
                           ; setprc(0,0)             ;
                           ; A:=0


#command FF               => gPFF()
#command P_FF               => gPFF()

#xcommand P_INI              =>  gpini()
#xcommand P_NR              =>   gpnr()
#xcommand P_COND             =>  gpCOND()
#xcommand P_COND2            =>  gpCOND2()
#xcommand P_10CPI            =>  gP10CPI()
#xcommand P_12CPI            =>  gP12CPI()
#xcommand F10CPI            =>  gP10CPI()
#xcommand F12CPI            =>  gP12CPI()
#xcommand P_B_ON             =>  gPB_ON()
#xcommand P_B_OFF            =>  gPB_OFF()
#xcommand P_I_ON             =>  gPI_ON()
#xcommand P_I_OFF            =>  gPI_OFF()
#xcommand P_U_ON             =>  gPU_ON()
#xcommand P_U_OFF            =>  gPU_OFF()

#xcommand P_PO_P             =>  gPO_Port()
#xcommand P_PO_L             =>  gPO_Land()
#xcommand P_RPL_N            =>  gRPL_Normal()
#xcommand P_RPL_G            =>  gRPL_Gusto()

#xcommand P_PIC_H <xpr>      =>  gpPicH(xpr)
#xcommand P_PIC_F            =>  gpPicF()

// stari interfejs
#xcommand INI             =>  gPB_ON()
#xcommand B_ON             =>  gPB_ON()
#xcommand B_OFF            =>  gPB_OFF()
#xcommand I_ON             =>  gPI_ON()
#xcommand I_OFF            =>  gPI_OFF()
#xcommand U_ON             =>  gPU_ON()
#xcommand U_OFF            =>  gPU_OFF()

#xcommand PO_P             =>  gPO_Port()
#xcommand PO_L             =>  gPO_Land()
#xcommand RPL_N            =>  gRPL_Normal()
#xcommand RPL_G            =>  gRPL_Gusto()


#xcommand RESET            =>  gPRESET()

#xcommand CLOSERET   => close all; return

#xcommand CLOSERET2   => close all; return

#xcommand CLOSERET <x>  => close all; return <x>

#xcommand ESC_BCR   => if lastkey()=K_ESC;
                           ; close all        ;
                           ; BoxC()           ;
                           ;return            ;
                           ;endif



***
*  @..SAYB
*

#command @ <row>, <col> SAYB <xpr>                                      ;
                        [PICTURE <pic>]                                 ;
                        [COLOR <color>]                                 ;
                                                                        ;
      => DevPos( m_x+<row>, m_y+<col> )                                 ;
       ; DevOutPict( <xpr>, <pic> [, <color>] )


***
*  @..GETB
*

#command @ <row>, <col> GETB <var>                                      ;
                        [PICTURE <pic>]                                 ;
                        [VALID <valid>]                                 ;
                        [WHEN <when>]                                   ;
                        [SEND <msg>]                                    ;
                                                                        ;
      => SetPos( m_x+<row>, m_y+<col> )                                 ;
       ; AAdd(                                                          ;
               GetList,                                                 ;
               _GET_( <var>, <(var)>, <pic>, <{valid}>, <{when}> )      ;
             )                                                          ;
      [; ATail(GetList):<msg>]


***
*   @..SAYB..GETB
*

#command @ <row>, <col> SAYB <sayxpr>                                   ;
                        [<sayClauses,...>]                              ;
                        GETB <var>                                      ;
                        [<getClauses,...>]                              ;
                                                                        ;
      => @ <row>, <col> SAYB <sayxpr> [<sayClauses>]                    ;
       ; @ Row(), Col()+1 GETB <var> [<getClauses>]


#command KRESI <x> NA <len> =>  <x>:=left(<x>,<len>)

#command START PRINT CRET <x> =>  if !StartPrint()       ;
                                  ;close all             ;
                                  ;return <x>            ;
                                  ;endif


#command START PRINT CRET     =>  if !StartPrint()       ;
                                  ;close all             ;
                                  ;return                ;
                                  ;endif

#command START PRINT CRET DOCNAME <y>    =>  if !StartPrint(nil, nil, <y>)    ;
                                             ;close all             ;
                                             ;return                ;
                                             ;endif

#command START PRINT CRET <x> DOCNAME  <y> =>  if !StartPrint(nil, nil, <y>  )  ;
                                  ;close all             ;
                                  ;return <x>            ;
                                  ;endif



#command START PRINT RET <x>  =>  if !StartPrint()       ;
                                  ;return <x>            ;
                                  ;endif
#command START PRINT RET      =>  if !StartPrint()       ;
                                  ;return                ;
                                  ;endif

#command START PRINT2 CRET <p>, <x> =>  IF !SPrint2(<p>)       ;
                                        ;close all             ;
                                        ;return <x>            ;
                                        ;endif
#command START PRINT2 CRET <p>   =>  if !Sprint2(<p>)          ;
                                     ;close all             ;
                                     ;return                ;
                                     ;endif

#command END PRN2 <x> => Eprint2(<x>)

#command END PRN2     => Eprint2()

#command ENDPRINT => EndPrint()

#command EOF CRET <x> =>  if EofFndret(.t.,.t.)       ;
                          ;return <x>                 ;
                          ;endif
#command EOF CRET     =>  if EofFndret(.t.,.t.)       ;
                          ;return                     ;
                          ;endif

#command EOF RET <x> =>   if EofFndret(.t.,.f.)      ;
                          ;return <x>             ;
                          ;endif
#command EOF RET     =>   if EofFndret(.t.,.f.)      ;
                          ;return                 ;
                          ;endif

#command NFOUND CRET <x> =>  if EofFndret(.f.,.t.)       ;
                             ;return <x>                 ;
                             ;endif
#command NFOUND CRET     =>  if EofFndret(.f.,.t.)       ;
                             ;return                     ;
                             ;endif

#command NFOUND RET <x> =>  if EofFndret(.f.,.f.)       ;
                            ;return  <x>                ;
                            ;endif
#command NFOUND RET     =>  if EofFndret(.f.,.f.)       ;
                            ;return                     ;
                            ;endif


#define DE_REF      12

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
