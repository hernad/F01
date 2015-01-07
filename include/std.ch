#ifndef _SET_DEFINED
#include "set.ch"
#endif


#command DO WHILE <exp>         =>  while <exp>

#command END <x>                => end
#command END SEQUENCE           => end
#command ENDSEQUENCE            => end
#command ENDDO    <*x*>         => enddo
#command ENDIF    <*x*>         => endif
#command ENDCASE  <*x*>         => endcase
#command ENDFOR [ <*x*> ]       => next


#command NEXT <v> [TO <x>] [STEP <s>]                                   ;
      => next

#command DO <proc>.PRG [WITH <list,...>]                                ;
      => do <proc> [ WITH <list>]

#command CALL <proc>() [WITH <list,...>]                                ;
      => call <proc> [ WITH <list>]

#command STORE <value> TO <var1> [, <varN> ]                            ;
      => <var1> := [ <varN> := ] <value>


#command COPY [STRUCTURE] [EXTENDED] [TO <(file)>]                      ;
      => __dbCopyXStruct( <(file)> )



#command SET ECHO <*x*>         =>
#command SET HEADING <*x*>      =>
#command SET MENU <*x*>         =>
#command SET STATUS <*x*>       =>
#command SET STEP <*x*>         =>
#command SET SAFETY <*x*>       =>
#command SET TALK <*x*>         =>
#command SET PROCEDURE TO       =>
#command SET PROCEDURE TO <f>   =>  _ProcReq_( <(f)> )


#command SET EXACT <x:ON,OFF,&>         => Set( _SET_EXACT, <(x)> )
#command SET EXACT (<x>)                => Set( _SET_EXACT, <x> )

#command SET FIXED <x:ON,OFF,&>         => Set( _SET_FIXED, <(x)> )
#command SET FIXED (<x>)                => Set( _SET_FIXED, <x> )

#command SET DECIMALS TO <x>            => Set( _SET_DECIMALS, <x> )
#command SET DECIMALS TO                => Set( _SET_DECIMALS, 0 )

#command SET PATH TO <*path*>           => Set( _SET_PATH, <(path)> )
#command SET PATH TO                    => Set( _SET_PATH, "" )

#command SET DEFAULT TO <(path)>        => Set( _SET_DEFAULT, <(path)> )
#command SET DEFAULT TO                 => Set( _SET_DEFAULT, "" )


#command SET CENTURY <x:ON,OFF,&>       => __SetCentury( <(x)> )
#command SET CENTURY (<x>)              => __SetCentury( <x> )
#command SET EPOCH TO <year>            => Set( _SET_EPOCH, <year> )
#command SET DATE FORMAT [TO] <c>       => Set( _SET_DATEFORMAT, <c> )

#define  _DFSET(x, y)  Set( _SET_DATEFORMAT, if(__SetCentury(), x, y) )

#command SET DATE [TO] AMERICAN         => _DFSET( "mm/dd/yyyy", "mm/dd/yy" )
#command SET DATE [TO] ANSI             => _DFSET( "yyyy.mm.dd", "yy.mm.dd" )
#command SET DATE [TO] BRITISH          => _DFSET( "dd/mm/yyyy", "dd/mm/yy" )
#command SET DATE [TO] FRENCH           => _DFSET( "dd/mm/yyyy", "dd/mm/yy" )
#command SET DATE [TO] GERMAN           => _DFSET( "dd.mm.yyyy", "dd.mm.yy" )
#command SET DATE [TO] ITALIAN          => _DFSET( "dd-mm-yyyy", "dd-mm-yy" )
#command SET DATE [TO] JAPANESE         => _DFSET( "yyyy/mm/dd", "yy/mm/dd" )
#command SET DATE [TO] USA              => _DFSET( "mm-dd-yyyy", "mm-dd-yy" )


#command SET ALTERNATE <x:ON,OFF,&>     => Set( _SET_ALTERNATE, <(x)> )
#command SET ALTERNATE (<x>)            => Set( _SET_ALTERNATE, <x> )

#command SET ALTERNATE TO               => Set( _SET_ALTFILE, "" )

#command SET ALTERNATE TO <(file)> [<add: ADDITIVE>]                    ;
      => Set( _SET_ALTFILE, <(file)>, <.add.> )


#command SET CONSOLE <x:ON,OFF,&>       => Set( _SET_CONSOLE, <(x)> )
#command SET CONSOLE (<x>)              => Set( _SET_CONSOLE, <x> )

#command SET MARGIN TO <x>              => Set( _SET_MARGIN, <x> )
#command SET MARGIN TO                  => Set( _SET_MARGIN, 0 )


#command SET PRINTER <x:ON,OFF,&>       => Set( _SET_PRINTER, <(x)> )
#command SET PRINTER (<x>)              => Set( _SET_PRINTER, <x> )

#command SET PRINTER TO                 => Set( _SET_PRINTFILE, "" )

#command SET PRINTER TO <(file)> [<add: ADDITIVE>]                      ;
      => Set( _SET_PRINTFILE, <(file)>, <.add.> )


#command SET DEVICE TO SCREEN           => Set( _SET_DEVICE, "SCREEN" )
#command SET DEVICE TO PRINTER          => Set( _SET_DEVICE, "PRINTER" )

#command SET COLOR TO [<*spec*>]        => SetColor( #<spec> )
#command SET COLOR TO ( <c> )           => SetColor( <c> )
#command SET COLOUR TO <*spec*>         => SET COLOR TO <spec>

#command SET CURSOR <x:ON,OFF,&>                                        ;
      => SetCursor( if(Upper(<(x)>) == "ON", iif(Readinsert(),2,1), 0) )


#command ?  [ <list,...> ]      => QOut( <list> )
#command ?? [ <list,...> ]      => QQOut( <list> )

#command EJECT                  => __Eject()

#command TEXT                                                           ;
      => text QOut, QQOut

#command TEXT TO FILE <(file)>                                          ;
      => __TextSave( <(file)> )                                         ;
       ; text QOut, __TextRestore

#command TEXT TO PRINTER                                                ;
      => __TextSave("PRINTER")                                          ;
       ; text QOut, __TextRestore



#command CLS                                                            ;
      => Scroll()                                                       ;
       ; SetPos(0,0)

#command CLEAR SCREEN                                                   ;
      => CLS

#command @ <row>, <col>                                                 ;
      => Scroll( <row>, <col>, <row> )                                  ;
       ; SetPos( <row>, <col> )

#command @ <top>, <left> CLEAR                                          ;
      => Scroll( <top>, <left> )                                        ;
       ; SetPos( <top>, <left> )


#command @ <top>, <left> CLEAR TO <bottom>, <right>                     ;
      => Scroll( <top>, <left>, <bottom>, <right> )                     ;
       ; SetPos( <top>, <left> )



#command @ <top>, <left>, <bottom>, <right> BOX <string>                ;
                                            [COLOR <color>]             ;
      => DispBox(                                                       ;
                  <top>, <left>, <bottom>, <right>, <string>            ;
                  [, <color> ]                                          ;
                )


#command @ <top>, <left> TO <bottom>, <right> [DOUBLE]                  ;
                                              [COLOR <color>]           ;
      => DispBox(                                                       ;
                  <top>, <left>, <bottom>, <right>, 2                   ;
                  [, <color> ]                                          ;
                )


#command @ <top>, <left> TO <bottom>, <right> [COLOR <color>]           ;
                                                                        ;
      => DispBox(                                                       ;
                  <top>, <left>, <bottom>, <right>, 1                   ;
                  [, <color> ]                                          ;
                )



#command @ <row>, <col> SAY <xpr>                                       ;
                        [PICTURE <pic>]                                 ;
                        [COLOR <color>]                                 ;
                                                                        ;
      => if gAppSrv;
       ;  QQOut(<xpr>);
       ; else;
       ;  DevPos( <row>, <col> )                                         ;
       ;  DevOutPict( <xpr>, <pic> [, <color>] ) ;
       ; end


#command @ <row>, <col> SAY <xpr>                                       ;
                        [COLOR <color>]                                 ;
                                                                        ;
      => if gAppSrv;
       ;   QQout(<xpr>);
       ; else;
       ;  DevPos( <row>, <col> )                                         ;
       ;  DevOut( <xpr> [, <color>] );
       ; end



#command SET BELL <x:ON,OFF,&>          => Set( _SET_BELL, <(x)> )
#command SET BELL (<x>)                 => Set( _SET_BELL, <x> )

#command SET CONFIRM <x:ON,OFF,&>       => Set( _SET_CONFIRM, <(x)> )
#command SET CONFIRM (<x>)              => Set( _SET_CONFIRM, <x> )

#command SET ESCAPE <x:ON,OFF,&>        => Set( _SET_ESCAPE, <(x)> )
#command SET ESCAPE (<x>)               => Set( _SET_ESCAPE, <x> )

#command SET INTENSITY <x:ON,OFF,&>     => Set( _SET_INTENSITY, <(x)> )
#command SET INTENSITY (<x>)            => Set( _SET_INTENSITY, <x> )

#command SET SCOREBOARD <x:ON,OFF,&>    => Set( _SET_SCOREBOARD, <(x)> )
#command SET SCOREBOARD (<x>)           => Set( _SET_SCOREBOARD, <x> )

#command SET DELIMITERS <x:ON,OFF,&>    => Set( _SET_DELIMITERS, <(x)> )
#command SET DELIMITERS (<x>)           => Set( _SET_DELIMITERS, <x> )

#command SET DELIMITERS TO <c>          => Set( _SET_DELIMCHARS, <c> )
#command SET DELIMITERS TO DEFAULT      => Set( _SET_DELIMCHARS, "::" )
#command SET DELIMITERS TO              => Set( _SET_DELIMCHARS, "::" )


#command SET FORMAT TO <proc>                                           ;
                                                                        ;
      => _ProcReq_( <(proc)> + ".FMT" )                                 ;
       ; __SetFormat( {|| <proc>()} )

#command SET FORMAT TO <proc>.<ext>                                     ;
                                                                        ;
      => _ProcReq_( <(proc)> + "." + <(ext)> )                          ;
       ; __SetFormat( {|| <proc>()} )

#command SET FORMAT TO <x:&>                                            ;
                                                                        ;
      => if ( Empty(<(x)>) )                                            ;
       ;   SET FORMAT TO                                                ;
       ; else                                                           ;
       ;   __SetFormat( &("{||" + <(x)> + "()}") )                      ;
       ; end

#command SET FORMAT TO                                                  ;
      => __SetFormat()



#command @ <row>, <col> GET <var>                                       ;
                        [PICTURE <pic>]                                 ;
                        [VALID <valid>]                                 ;
                        [WHEN <when>]                                   ;
                        [SEND <msg>]                                    ;
                                                                        ;
      => SetPos( <row>, <col> )                                         ;
       ; AAdd(                                                          ;
           GetList,                                                     ;
           _GET_( <var>, <"var">, <pic>, <{valid}>, <{when}> ):display();
             )                                                          ;
      [; ATail(GetList):<msg>]


***
*   @..SAY..GET
*

#command @ <row>, <col> SAY <sayxpr>                                    ;
                        [<sayClauses,...>]                              ;
                        GET <var>                                       ;
                        [<getClauses,...>]                              ;
                                                                        ;
      => @ <row>, <col> SAY <sayxpr> [<sayClauses>]                     ;
       ; @ Row(), Col()+1 GET <var> [<getClauses>]




#command @ <row>, <col> GET <var>                                       ;
                        [<clauses,...>]                                 ;
                        RANGE <lo>, <hi>                                ;
                        [<moreClauses,...>]                             ;
                                                                        ;
      => @ <row>, <col> GET <var>                                       ;
                        [<clauses>]                                     ;
                        VALID {|_1| RangeCheck(_1,, <lo>, <hi>)}        ;
                        [<moreClauses>]


// @..GET COLOR

#command @ <row>, <col> GET <var>                                       ;
                        [<clauses,...>]                                 ;
                        COLOR <color>                                   ;
                        [<moreClauses,...>]                             ;
                                                                        ;
      => @ <row>, <col> GET <var>                                       ;
                        [<clauses>]                                     ;
                        SEND colorDisp(<color>)                         ;
                        [<moreClauses>]




#command READ SAVE                                                      ;
       => ReadModSC(GetList)

#command READ                                                           ;
      => ReadModSC(GetList)                                             ;
       ; GetList := {}

#command CLEAR GETS                                                     ;
      => __KillRead()                                                   ;
       ; GetList := {}



***
*  Refinement...
*

#command @ [<clauses,...>] COLOUR [<moreClauses,...>]                   ;
      => @ [<clauses>] COLOR [<moreClauses>]



***
*  MENU TO
*

#command SET WRAP <x:ON,OFF,&>  => Set( _SET_WRAP, <(x)> )
#command SET WRAP (<x>)         => Set( _SET_WRAP, <x> )

#command SET MESSAGE TO <n> [<cent: CENTER, CENTRE>]                    ;
      => Set( _SET_MESSAGE, <n> )                                       ;
       ; Set( _SET_MCENTER, <.cent.> )

#command SET MESSAGE TO                                                 ;
      => Set( _SET_MESSAGE, 0 )                                         ;
       ; Set( _SET_MCENTER, .f. )

#command @ <row>, <col> PROMPT <prompt> [MESSAGE <msg>]                 ;
      => __AtPrompt( <row>, <col>, <prompt> , <msg> )

*#command MENU TO <v>                                                    ;
*      => <v> := __MenuTo( {|_1| if(PCount() == 0, <v>, <v> := _1)}, #<v> )
*


***
*  SAVE / RESTORE SCREEN
*

#command SAVE SCREEN            => __XSaveScreen()
#command RESTORE SCREEN         => __XRestScreen()

#command SAVE SCREEN TO <var>                                           ;
      => <var> := SaveScreen( 0, 0, Maxrow(), Maxcol() )

#command RESTORE SCREEN FROM <c>                                        ;
      => RestScreen( 0, 0, Maxrow(), Maxcol(), <c> )



***
*  Modal keyboard input
*

#command WAIT [<c>]             => __Wait( <c> )
#command WAIT [<c>] TO <var>    => <var> := __Wait( <c> )
#command ACCEPT [<c>] TO <var>  => <var> := __Accept( <c> )

#command INPUT [<c>] TO <var>                                           ;
                                                                        ;
      => if ( !Empty(__Accept(<c>)) )                                   ;
       ;    <var> := &( __AcceptStr() )                                 ;
       ; end


#command KEYBOARD <c>           => __Keyboard( <c> )
#command CLEAR TYPEAHEAD        => __Keyboard()
#command SET TYPEAHEAD TO <n>   => Set( _SET_TYPEAHEAD, <n> )

#command SET KEY <n> TO <proc>                                          ;
      => SetKey( <n>, {|p, l, v| <proc>(p, l, v)} )

#command SET KEY <n> TO <proc> ( [<list,...>] )                         ;
      => SET KEY <n> TO <proc>

#command SET KEY <n> TO <proc:&>                                        ;
                                                                        ;
      => if ( Empty(<(proc)>) )                                         ;
       ;   SetKey( <n>, NIL )                                           ;
       ; else                                                           ;
       ;   SetKey( <n>, {|p, l, v| <proc>(p, l, v)} )                   ;
       ; end

#command SET KEY <n> [TO]                                               ;
      => SetKey( <n>, NIL )

#command SET FUNCTION <n> [TO] [<c>]                                    ;
      => __SetFunction( <n>, <c> )



***
*  MEMVAR variables
*

#command CLEAR MEMORY                   => __MClear()
#command RELEASE <vars,...>             => __MXRelease( <"vars"> )
#command RELEASE ALL                    => __MRelease("*", .t.)
#command RELEASE ALL LIKE <skel>        => __MRelease( #<skel>, .t. )
#command RELEASE ALL EXCEPT <skel>      => __MRelease( #<skel>, .f. )

#command RESTORE [FROM <(file)>] [<add: ADDITIVE>]                      ;
      => __MRestore( <(file)>, <.add.> )

#command SAVE ALL LIKE <skel> TO <(file)>                               ;
      => __MSave( <(file)>, <(skel)>, .t. )

#command SAVE TO <(file)> ALL LIKE <skel>                               ;
      => __MSave( <(file)>, <(skel)>, .t. )

#command SAVE ALL EXCEPT <skel> TO <(file)>                             ;
      => __MSave( <(file)>, <(skel)>, .f. )

#command SAVE TO <(file)> ALL EXCEPT <skel>                             ;
      => __MSave( <(file)>, <(skel)>, .f. )

#command SAVE [TO <(file)>] [ALL]                                       ;
      => __MSave( <(file)>, "*", .t. )



***
*  DOS file commands
*

#command ERASE <(file)>                 => FErase( <(file)> )
#command DELETE FILE <(file)>           => FErase( <(file)> )
#command RENAME <(old)> TO <(new)>      => FRename( <(old)>, <(new)> )

#command COPY FILE <(src)> TO <(dest)>  => __CopyFile( <(src)>, <(dest)> )
#command DIR [<(spec)>]                 => __Dir( <(spec)> )

#command TYPE <(file)> [<print: TO PRINTER>] [TO FILE <(dest)>]         ;
                                                                        ;
      => __TypeFile( <(file)>, <.print.> )                              ;
      [; COPY FILE <(file)> TO <(dest)> ]

#command TYPE <(file)> [<print: TO PRINTER>]                            ;
                                                                        ;
      => __TypeFile( <(file)>, <.print.> )



***
*  Process
*

#command CANCEL                 => __Quit()
#command QUIT                   => __Quit()

#command RUN <*cmd*>            => run_ext_command(#<cmd>,0,"","")
#command RUN ( <c> )            => run_ext_command( <c>  ,0,"","")
#command ! <*cmd*>              => RUN <cmd>
#command RUN = <xpr>            => ( run := <xpr> )
#command RUN := <xpr>           => ( run := <xpr> )


#command SET EXCLUSIVE <x:ON,OFF,&>     =>  Set( _SET_EXCLUSIVE, <(x)> )
#command SET EXCLUSIVE (<x>)            =>  Set( _SET_EXCLUSIVE, <x> )

#command SET SOFTSEEK <x:ON,OFF,&>      =>  Set( _SET_SOFTSEEK, <(x)> )
#command SET SOFTSEEK (<x>)             =>  Set( _SET_SOFTSEEK, <x> )

#command SET UNIQUE <x:ON,OFF,&>        =>  Set( _SET_UNIQUE, <(x)> )
#command SET UNIQUE (<x>)               =>  Set( _SET_UNIQUE, <x> )

#command SET DELETED <x:ON,OFF,&>       =>  Set( _SET_DELETED, <(x)> )
#command SET DELETED (<x>)              =>  Set( _SET_DELETED, <x> )


#command SELECT <whatever>              => dbSelectArea( <(whatever)> )
#command SELECT <f>([<list,...>])       => dbSelectArea( <f>(<list>) )


#command USE                            => dbCloseArea()

#command USE <(db)>                                                     ;
             [VIA <rdd>]                                                ;
             [ALIAS <a>]                                                ;
             [<new: NEW>]                                               ;
             [<ro: READONLY>]                                           ;
             [INDEX <(index1)> [, <(indexn)>]]                          ;
                                                                        ;
      =>  PreUseEvent(<(db)>, !is_install(), gReadOnly)			;
         ; my_dbUseArea(                                                   ;
                    <.new.>, <rdd>, <(db)>, <(a)>,        ;
                     !is_install() , <.ro.>       ;
                  )                                                     ;
                                                                        ;
      [; dbSetIndex( <(index1)> )]                                      ;
      [; dbSetIndex( <(indexn)> )]


#command SET INDEX TO [ <(index1)> [, <(indexn)>]]                      ;
                                                                        ;
      => dbClearIndex()                                                 ;
                                                                        ;
      [; dbSetIndex( <(index1)> )]                                      ;
      [; dbSetIndex( <(indexn)> )]







#command APPEND BLANKS           => appblank2()

#command APPEND BLANK    =>  appblank2()





#command PACK            => Msg("PACK nedozvoljen !",15)


#command ZAP             => zapp()


#command REPLACE <f1> WITH <v1> [, <fN> WITH <vN> ]    ;
      => while .t.;
         ; if rlock();
         ;   _FIELD-><f1> := <v1> [; _FIELD-><fN> := <vN>];
         ;   dbunlock();
         ; else;
         ;   Msg("Neko vec koristi zapis",10);
         ;   if pitanje("pp","Pokusati ponovo (D/N) ?","D")=="D";
         ;     loop;
         ;   else;
         ;     exit;
         ;   end;
         ; end;
         ; exit;
         ;end;



#command DELETE  =>    delete2()


#command RECALL  =>    dbRecall()



#command UNLOCK                 => dbUnlock()
#command UNLOCK ALL             => dbUnlockAll()
#command COMMIT                 => dbCommitAll()


#command GOTO <n>               => dbGoto(<n>)
#command GO <n>                 => dbGoto(<n>)
#command GOTO TOP               => dbGoTop()
#command GO TOP                 => dbGoTop()
#command GOTO BOTTOM            => dbGoBottom()
#command GO BOTTOM              => dbGoBottom()

#command SKIP                   => dbSkip(1)
#command SKIP <n>               => dbSkip( <n> )
#command SKIP ALIAS <a>         => <a> -> ( dbSkip(1) )
#command SKIP <n> ALIAS <a>     => <a> -> ( dbSkip(<n>) )

#command SEEK <xpr>                                                     ;
         [<soft: SOFTSEEK>]                                             ;
      => dbSeek( <xpr>, if( <.soft.>, .T., NIL ) )

#command CONTINUE               => __dbContinue()

#command LOCATE                                                         ;
         [FOR <for>]                                                    ;
         [WHILE <while>]                                                ;
         [NEXT <next>]                                                  ;
         [RECORD <rec>]                                                 ;
         [<rest:REST>]                                                  ;
         [ALL]                                                          ;
                                                                        ;
      => __dbLocate( <{for}>, <{while}>, <next>, <rec>, <.rest.> )



#command SET RELATION TO        => dbClearRel()


#command SET FILTER TO          => dbClearFilter(NIL)
#command SET FILTER TO <xpr>    => dbSetFilter( <{xpr}>, <"xpr"> )

#command SET FILTER TO <x:&>                                            ;
      => if ( Empty(<(x)>) )                                            ;
       ;    dbClearFilter()                                             ;
       ; else                                                           ;
       ;    dbSetFilter( <{x}>, <(x)> )                                 ;
       ; end


#command CREATE <(file1)>                                               ;
            [FROM <(file2)>]                                            ;
            [VIA <rdd>]                                                 ;
            [ALIAS <a>]                                                 ;
            [<new: NEW>]                                                ;
                                                                        ;
      => __dbCreate( <(file1)>, <(file2)>, <rdd>, <.new.>, <(a)> )


#command APPEND FROM <(file)>                                           ;
         [<opp:OPEN>]                                                   ;
                                                                        ;
      => while .t.;
         ; if flock();
         ;   appfrom(<(file)>,<.opp.>);
         ;   dbunlock();
         ; else;
         ;   inkey(0.4);
         ;   loop;
         ; end;
         ; exit;
         ;end

#command TOTAL [TO <(file)>] [ON <key>]                                 ;
         [FIELDS <fields,...>]                                          ;
         [FOR <for>]                                                    ;
         [WHILE <while>]                                                ;
         [NEXT <next>]                                                  ;
         [RECORD <rec>]                                                 ;
         [<rest:REST>]                                                  ;
         [ALL]                                                          ;
                                                                        ;
      => __dbTotal(                                                     ;
                    <(file)>, <{key}>, { <(fields)> },                  ;
                    <{for}>, <{while}>, <next>, <rec>, <.rest.>         ;
                  )


#command UPDATE [FROM <(alias)>] [ON <key>]                             ;
         [REPLACE <f1> WITH <x1> [, <fn> WITH <xn>]]                    ;
         [<rand:RANDOM>]                                                ;
                                                                        ;
      => __dbUpdate(                                                    ;
                     <(alias)>, <{key}>, <.rand.>,                      ;
                     {|| _FIELD-><f1> := <x1> [, _FIELD-><fn> := <xn>]} ;
                   )


#command JOIN [WITH <(alias)>] [TO <file>]                              ;
         [FIELDS <fields,...>]                                          ;
         [FOR <for>]                                                    ;
                                                                        ;
      => __dbJoin( <(alias)>, <(file)>, { <(fields)> }, <{for}> )


#command COUNT [TO <var>]                                               ;
         [FOR <for>]                                                    ;
         [WHILE <while>]                                                ;
         [NEXT <next>]                                                  ;
         [RECORD <rec>]                                                 ;
         [<rest:REST>]                                                  ;
         [ALL]                                                          ;
                                                                        ;
      => <var> := 0                                                     ;
       ; DBEval(                                                        ;
                 {|| <var> := <var> + 1},                               ;
                 <{for}>, <{while}>, <next>, <rec>, <.rest.>            ;
               )


#command SUM [ <x1> [, <xn>]  TO  <v1> [, <vn>] ]                       ;
         [FOR <for>]                                                    ;
         [WHILE <while>]                                                ;
         [NEXT <next>]                                                  ;
         [RECORD <rec>]                                                 ;
         [<rest:REST>]                                                  ;
         [ALL]                                                          ;
                                                                        ;
      => <v1> := [ <vn> := ] 0                                          ;
       ; DBEval(                                                        ;
                 {|| <v1> := <v1> + <x1> [, <vn> := <vn> + <xn> ]},     ;
                 <{for}>, <{while}>, <next>, <rec>, <.rest.>            ;
               )


#command AVERAGE [ <x1> [, <xn>]  TO  <v1> [, <vn>] ]                   ;
         [FOR <for>]                                                    ;
         [WHILE <while>]                                                ;
         [NEXT <next>]                                                  ;
         [RECORD <rec>]                                                 ;
         [<rest:REST>]                                                  ;
         [ALL]                                                          ;
                                                                        ;
      => M->__Avg := <v1> := [ <vn> := ] 0                              ;
                                                                        ;
       ; DBEval(                                                        ;
                 {|| M->__Avg := M->__Avg + 1,                          ;
                 <v1> := <v1> + <x1> [, <vn> := <vn> + <xn>] },         ;
                 <{for}>, <{while}>, <next>, <rec>, <.rest.>            ;
               )                                                        ;
                                                                        ;
       ; <v1> := <v1> / M->__Avg [; <vn> := <vn> / M->__Avg ]


#command LIST [<list,...>]                                              ;
         [<off:OFF>]                                                    ;
         [<toPrint: TO PRINTER>]                                        ;
         [TO FILE <(toFile)>]                                           ;
         [FOR <for>]                                                    ;
         [WHILE <while>]                                                ;
         [NEXT <next>]                                                  ;
         [RECORD <rec>]                                                 ;
         [<rest:REST>]                                                  ;
         [ALL]                                                          ;
                                                                        ;
      => __dbList(                                                      ;
                   <.off.>, { <{list}> }, .t.,                          ;
                   <{for}>, <{while}>, <next>, <rec>, <.rest.>,         ;
                   <.toPrint.>, <(toFile)>                              ;
                 )


#command DISPLAY [<list,...>]                                           ;
         [<off:OFF>]                                                    ;
         [<toPrint: TO PRINTER>]                                        ;
         [TO FILE <(toFile)>]                                           ;
         [FOR <for>]                                                    ;
         [WHILE <while>]                                                ;
         [NEXT <next>]                                                  ;
         [RECORD <rec>]                                                 ;
         [<rest:REST>]                                                  ;
         [<all:ALL>]                                                    ;
                                                                        ;
      => __DBList(                                                      ;
                   <.off.>, { <{list}> }, <.all.>,                      ;
                   <{for}>, <{while}>, <next>, <rec>, <.rest.>,         ;
                   <.toPrint.>, <(toFile)>                              ;
                 )



// NOTE:  CLOSE <alias> must precede the others
#command CLOSE <alias>          => <alias>->( dbCloseArea() )

#command CLOSE                  => dbCloseArea()
#command CLOSE DATABASES        => dbCloseAll()
#command CLOSE ALTERNATE        => Set(_SET_ALTFILE, "")
#command CLOSE FORMAT           => __SetFormat(NIL)
#command CLOSE INDEXES          => dbClearIndex()
#command CLOSE PROCEDURE        =>

#command CLOSE ALL                                                      ;
                                                                        ;
      => CLOSE DATABASES                                                ;
       ; SELECT 1                                                       ;
       ; CLOSE FORMAT

#command CLEAR                                                          ;
                                                                        ;
      => CLEAR SCREEN                                                   ;
       ; CLEAR GETS                                                     ;

#command CLEAR ALL                                                      ;
                                                                        ;
      => CLOSE DATABASES                                                ;
       ; CLOSE FORMAT                                                   ;
       ; CLEAR MEMORY                                                   ;
       ; CLEAR GETS                                                     ;
       ; SET ALTERNATE OFF                                              ;
       ; SET ALTERNATE TO


/***
*  ORD - Ordering commands
*
*
*/

// cmx
#command INDEX ON <key> [TAG <(cOrder)>] TO <(cBag)>                    ;
            [FOR <for>]                                                 ;
            [WHILE <while>]                                             ;
            [<lUnique: UNIQUE>]                                         ;
            [<ascend: ASCENDING>]                                       ;
            [<descend: DESCENDING>]                                     ;
            [<lUsecurrent: USECURRENT>]                                 ;
            [<lAdditive: ADDITIVE>]                                     ;
            [EVAL <eval> [ EVERY <nEvery> ]]                            ;
            [<lCustom: CUSTOM>]                                         ;
            [<lNoOpt: NOOPTIMIZE>]                                      ;
    =>  ordCondSet( <"for">, <{for}>,                                   ;
                     nil,                                               ;
                     <{while}>,                                         ;
                     <{eval}>, <nEvery>,                                ;
                     nil, nil, nil,                                     ;
                     nil, [<.descend.>],                                ;
                     nil, <.lAdditive.>, <.lUsecurrent.>, <.lCustom.>,  ;
                     <.lNoOpt.>)                                        ;
        ;  ordCreate(<(cBag)>, <(cOrder)>, <"key">, <{key}>, [<.lUnique.>])

#command INDEX ON <key> TAG <(cOrder)> [TO <(cBag)>]                    ;
            [FOR <for>]                                                 ;
            [WHILE <while>]                                             ;
            [<lUnique: UNIQUE>]                                         ;
            [<ascend: ASCENDING>]                                       ;
            [<descend: DESCENDING>]                                     ;
            [<lUsecurrent: USECURRENT>]                                 ;
            [<lAdditive: ADDITIVE>]                                     ;
            [EVAL <eval> [ EVERY <nEvery> ]]                            ;
            [<lCustom: CUSTOM>]                                         ;
            [<lNoOpt: NOOPTIMIZE>]                                      ;
    =>  ordCondSet( <"for">, <{for}>,                                   ;
                     nil,                                               ;
                     <{while}>,                                         ;
                     <{eval}>, <nEvery>,                                ;
                     nil, nil, nil,                                     ;
                     nil, [<.descend.>],                                ;
                     nil, <.lAdditive.>, <.lUsecurrent.>, <.lCustom.>,  ;
                     <.lNoOpt.>)                                        ;
        ;  ordCreate(<(cBag)>, <(cOrder)>, <"key">, <{key}>, [<.lUnique.>])


#command XINDEX ON <key> [TAG <(cOrder)>] TO <(cBag)>                   ;
            [FOR <for>]                                                 ;
            [WHILE <while>]                                             ;
            [<lUnique: UNIQUE>]                                         ;
            [<ascend: ASCENDING>]                                       ;
            [<descend: DESCENDING>]                                     ;
            [<lUsecurrent: USECURRENT>]                                 ;
            [<lAdditive: ADDITIVE>]                                     ;
            [EVAL <eval> [ EVERY <nEvery> ]]                            ;
            [<lCustom: CUSTOM>]                                         ;
            [<lNoOpt: NOOPTIMIZE>]                                      ;
    =>  ordCondSet( <(for)>,                                            ;
                     iif(<.for.>,&("{||" + <(for)> + "}"),NIL),         ;
                     nil,                                               ;
                     <{while}>,                                         ;
                     <{eval}>, <nEvery>,                                ;
                     nil, nil, nil,                                     ;
                     nil, [<.descend.>],                                ;
                     nil, <.lAdditive.>, <.lUsecurrent.>, <.lCustom.>,  ;
                     <.lNoOpt.>)                                        ;
        ;  ordCreate(<(cBag)>, <(cOrder)>,                              ;
                     <(key)>, &("{||" + <(key)> + "}"), [<.lUnique.>])

#command XINDEX ON <key> TAG <(cOrder)> [TO <(cBag)>]                   ;
            [FOR <for>]                                                 ;
            [WHILE <while>]                                             ;
            [<lUnique: UNIQUE>]                                         ;
            [<ascend: ASCENDING>]                                       ;
            [<descend: DESCENDING>]                                     ;
            [<lUsecurrent: USECURRENT>]                                 ;
            [<lAdditive: ADDITIVE>]                                     ;
            [EVAL <eval> [ EVERY <nEvery> ]]                            ;
            [<lCustom: CUSTOM>]                                         ;
            [<lNoOpt: NOOPTIMIZE>]                                      ;
    =>  ordCondSet( <(for)>,                                            ;
                     iif(<.for.>,&("{||" + <(for)> + "}"),NIL),         ;
                     nil,                                               ;
                     <{while}>,                                         ;
                     <{eval}>, <nEvery>,                                ;
                     nil, nil, nil,                                     ;
                     nil, [<.descend.>],                                ;
                     nil, <.lAdditive.>, <.lUsecurrent.>, <.lCustom.>,  ;
                     <.lNoOpt.>)                                        ;
        ;  ordCreate(<(cBag)>, <(cOrder)>,                              ;
                     <(key)>, &("{||" + <(key)> + "}"), [<.lUnique.>])

#command REINDEX                                                        ;
            [EVAL <eval>]                                               ;
            [EVERY <every>]                                             ;
            [<lNoOpt: NOOPTIMIZE>]                                      ;
      => ordCondSet(,,,, <{eval}>, <every>,,,,,,,,,, <.lNoOpt.>)        ;
         ; ordListRebuild()


#xcommand SET DESCENDING ON                                             ;
    =>  cmxDescend(,, .t.)

#xcommand SET DESCENDING OFF                                            ;
    =>  cmxDescend(,, .f.)

#xcommand SET MEMOBLOCK TO <nSize>                                      ;
    =>  cmxMemoBlock(<nSize>)

#command SEEK <xValue>                                                  ;
         [<lSoft: SOFTSEEK>]                                            ;
         LAST                                                           ;
      => cmxSeekLast(<xValue>, if( <.lSoft.>, .T., NIL ))

#command SET RELATION                                                   ;
         [<add:ADDITIVE>]                                               ;
         [TO <key1> INTO <(alias1)> [, [TO] <keyn> INTO <(aliasn)>]]    ;
                                                                        ;
      => if ( !<.add.> )                                                ;
       ;    dbClearRel()                                                ;
       ; end                                                            ;
                                                                        ;
       ; dbSetRelation( <(alias1)>, <{key1}>, <"key1"> )                ;
      [; dbSetRelation( <(aliasn)>, <{keyn}>, <"keyn"> )]


#command SET RELATION                                                   ;
         [<add:ADDITIVE>]                                               ;
         TO <key1> INTO <(alias1)> [, [TO] <keyn> INTO <(aliasn)>]      ;
         SCOPED                                                         ;
                                                                        ;
      => if ( !<.add.> )                                                ;
       ;    dbClearRel()                                                ;
       ; end                                                            ;
                                                                        ;
       ; cmxSetRelation( <(alias1)>, <{key1}>, <"key1"> )               ;
      [; cmxSetRelation( <(aliasn)>, <{keyn}>, <"keyn"> )]


//#command REQUEST <vars,...>             => EXTERNAL <vars>


#command SET ORDER TO TAG <(cOrder)>                                                 ;
         [IN <(cOrdBag)>]                                               ;
                                                                        ;
      => ordSetFocus( <(cOrder)> [, <(cOrdBag)>] )


#command SET ORDER TO <xOrder>                                          ;
         [IN <(cOrdBag)>]                                               ;
                                                                        ;
      => ordSetFocus( alltrim(str(<xOrder>)) [, <(cOrdBag)>] )



#command SET ORDER TO TAG <(cOrder)>                                                 ;
         [IN <(cOrdBag)>]                                               ;
                                                                        ;
      => ordSetFocus( <(cOrder)> [, <(cOrdBag)>] )


#command SET ORDER TO           => ordSetFocus(0)

#command SET ORDER TO 0         => ordSetFocus(0)

#command DELETE TAG <(cOrdName1)> [ IN <(cOrdBag1)> ]                   ;
                  [, <(cOrdNameN)> [ IN <(cOrdBagN)> ] ]                ;
      => ordDestroy( <(cOrdName1)>, <(cOrdBag1)> )                      ;
      [; ordDestroy( <(cOrdNameN)>, <(cOrdBagN)> ) ]
