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


#include "f01.ch"
#include "achoice.ch"
#include "fileio.ch"


STATIC s_cParamDesniDio := ""


/* defgroup params
 *  @{
 *  @}
 */

/* file sc1g/base/base.prg
     Inicijalizacija systema, bazne funkcije
    biljeska: prebaciti u potpunosti na objektni model (ionako se koristi oApp)
 */

/*  f01_start(oApp, lSezone)
 *   Aktiviranje "glavnog" programskog modula"
 */


// string FmkIni_ExePath_FMK_ReadOnly;

/* var *string FmkIni_ExePath_FMK_ReadOnly
 *   D-baza ce se otvoriti u readonly rezimu, N-tekuca vrijednost
 *  biljeska: postavlja vrijednost globalne var. gReadOnly
 *  \sa SC_START,gReadOnly
 */


/*  f01_start(oApp, lSezone)
 *   Inicijalizacija sclib sistema
 *
 *  todo: Nakon verzije 1.5 ... kreiranje F_SECUR  treba ukinuti
 *
 */

FUNCTION f01_start( oApp, lSezone )

   LOCAL cStartFn

   PUBLIC gAppSrv

   IF !oApp:lStarted

      rddSetDefault( RDDENGINE )
      oApp:initdb()
   ENDIF

   SetgaSDbfs()
   SetScGVars()

   gModul := oApp:cName
   gVerzija := oApp:cVerzija

   gAppSrv := .F.

   IF mpar37( "/APPSRV", oApp )
      ? "Pokrecem App Serv ..."
      gAppSrv := .T.
   ENDIF

   SetNaslov( oApp )


   IF mpar37( "/INSTALL", oApp )
      oApp:oDatabase:lAdmin := .T.
      is_install( .T. )

      CreGParam()
   ENDIF


   IniGparams()

   // inicijalizacija, prijava
   InitE( oApp )

   SetScGVar2()
   IF oApp:lTerminate
      RETURN
   ENDIF

   oApp:oDatabase:setgaDbfs()

   IF mpar37( "/INSTALL", oApp )
      is_install( .T. )
      oApp:oDatabase:install()
   ENDIF

   altd()
   IF mpar37( "/FN_ON_STARTUP:", oApp )
     altd()

     oApp:setGVars()
     cStartFn := param_desni_dio()
     &cStartFn
   ENDIF

   IniGparam2()
   BosTipke()
   KonvTable()

   IF lSezone
      oApp:oDatabase:loadSezonaRadimUSezona()
      IF gAppSrv
         ? "Pokrecem App Serv ..."
         oApp:setGVars()
         gAppSrv := .T.
         oApp:srv()
      ENDIF
      oApp:oDatabase:radiUSezonskomPodrucju( mpar37( "/XN", oApp ) )
      IF !mpar37( "/XN", oApp )
         ArhSigma()
      ENDIF
      gProcPrenos := "D"

   ELSE
      IF gAppSrv
         cPars := mparstring( oApp )
         cKom := "{|| RunAppSrv(" + cPars + ")}"
         ? "Pokrecem App Serv ..."
         gAppSrv := .T.
         oApp:SetGVars()
         Eval( &cKom )
      ENDIF

   ENDIF

   IF ( lSezone .AND. mpar37( "/XN", oApp ) )
      SetOznNoGod()
   ENDIF

   gReadOnly := ( IzFmkIni( "FMK", "ReadOnly", "N" ) == "D" )

   SET EXCLUSIVE OFF

   // Setuj globalne varijable varijable modula
   oApp:setGVars()

/*

cImeDbf:=KUMPATH+"SECUR.DBF"
if !File2(cImeDbf)
 oApp:oDatabase:kreiraj(F_SECUR)
endif
*/

   oApp:oDataBase:setSigmaBD( IzFmkIni( "Svi", "SigmaBD", "c:" + SLASH + "sigma", EXEPATH ) )

   IF ( gSecurity == "D" )
      AddSecgaSDBFs()
      LoginScreen()
      ShowUser()
      PUBLIC nUser := GetUserID()
   ENDIF

   RETURN



/*  If01_start(oApp, lSezone)
 *   Aktiviranje "install" programskog modula"
 */

FUNCTION If01_start( oApp, lSezone )

   rddSetDefault( RDDENGINE )

   SET EXCLUSIVE ON
   oApp:oDatabase:lAdmin := .T.
   CreKorisn()
   @ 10, 30 SAY ""

   SetDirs( oApp )
   CreSystemDB()

   IniGparams( .F. )
   IniGparam2( .F. )

   oApp:oDatabase:loadSezonaRadimUSezona()
   oApp:oDatabase:radiUSezonskomPodrucju()

   oApp:setGVars()
   @ 10, 20 SAY ""
   IF Pitanje(, "Izvrsiti instalaciju fajlova (D/N) ?", "N" ) == "D"
      oApp:oDatabase:kreiraj()
   ENDIF

   gPrinter := "R"
   InigEpson()

   O_GPARAMS
   O_PARAMS
   gMeniSif := .F.
   gValIz := "280 "
   gValU := "000 "
   gKurs := "1"

   PRIVATE cSection := "1"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}
   RPar( "px", @gPrinter )
   RPar( "vi", @gValIz )
   RPar( "vu", @gValU )
   RPar( "vk", @gKurs )
   SELECT params
   USE

   SELECT gparams
   PRIVATE cSection := "P"
   PRIVATE cHistory := gPrinter
   PRIVATE aHistory := {}
   RPar_Printer()

   gPTKONV := "0"
   gPicSif := "V"
   gcDirekt := "V"
   gSKSif := "D"
   gArhDir := ToUnix( "C:" + SLASH + "SIGARH" )
   gPFont := "Arial"

   PRIVATE cSection := "1", cHistory := " "; aHistory := {}
   Rpar( "pt", @gPTKonv )
   Rpar( "pS", @gPicSif )
   Rpar( "SK", @gSKSif )
   Rpar( "DO", @gcDirekt )
   Rpar( "Ad", @gArhDir )
   Rpar( "FO", @gPFont )

   SELECT gparams
   USE

   // if (gSql=="D")
   // O_Log()
   // endif

   Beep( 1 )

   IBatchRun( oApp )

   @ 10, 30 SAY ""
   oApp:oDatabase:mInstall()

   RETURN



/*  IBatchRun(oApp)
 *   Batch funkcije za kreiranje baze podataka
 *  todo: Sve batch funkcije prebaciti u appsrv kompomentu
 */

FUNCTION IBatchRun( oApp )

   IF mpar37( "/XM", oApp )
      oApp:oDatabase:modstruAll()
   ENDIF

   IF mpar37( "/APPSRV", oApp )
      cKom := "{|| RunAppSrv() }"
      ? "Pokrecem App Serv ..."
      Eval( &cKom )
   ENDIF

   IF mpar37( "/B", oApp )
      BrisipaK( .T. )
      CreKorisn()
      CreSystemDb()
      oApp:oDatabase:kreiraj()
   ENDIF

   IF mpar37( "/I", oApp )
      oApp:oDatabase:kreiraj()
   ENDIF

   IF mpar37( "/R", oApp )
      REINDEX( .T. )
   ENDIF

   IF mpar37( "/P", oApp )
      Pakuj( .T. )
   ENDIF

   IF mpar37( "/M", oApp )
      RunMods( .T. )
   ENDIF

   RETURN



FUNCTION SetNaslov( oApp )

   gNaslov := oApp:cName + " HB, " + oApp:cPeriod + " " + D_VERZIJA

   SetCancel( .F. )

   IF !is_install()
      IzvrsenIn( oApp:cP3 )
   ENDIF

   gNaslov += ", Reg: " + SubStr( EVar, 7, 20 )

   PUBLIC bGlobalErrorHandler
   bGlobalErrorHandler := {| objError| GlobalErrorHandler( objError, .F. ) }
   ErrorBlock( bGlobalErrorHandler )

   RETURN


FUNCTION InitE( oApp )

   IF ( oApp:cKorisn <> NIL .AND. oApp:cSifra == nil )

      ? "Koristenje:  ImePrograma "
      ? "             ImePrograma ImeKorisnika Sifra"
      ?
      QUIT

   ENDIF

   AFill( h, "" )

   nOldCursor := iif( ReadInsert(), 2, 1 )

   IF !gAppSrv
      standardboje()
   ENDIF

   SET KEY K_INS  TO ToggleINS()
   SET MESSAGE TO 24 CENTER
   SET DELETED ON   // most commands ignores deleted records
   SET DATE GERMAN
   SET SCOREBOARD OFF
   SET CONFIRM ON
   SET WRAP ON
   SET ESCAPE ON
   SET SOFTSEEK ON
   // naslovna strana

   IF gAppSrv
      ? gNaslov, oApp:cVerzija
      Prijava( oApp, .F. )
      RETURN
   ENDIF

   NaslEkran( .T. )
   ToggleIns()
   ToggleIns()

   @ 10, 35 SAY ""
   // prijava

   IF !oApp:lStarted
      IF ( oApp:cKorisn <> NIL .AND. oApp:cSifra <> nil )
         IF oApp:cP3 <> nil
            Prijava( oApp, .F. )  // bez prijavnog Box-a
         ELSE
            Prijava( oApp )
            // PokreniInstall(oApp)
         ENDIF
      ELSE
         Prijava( oApp )
      ENDIF
   ENDIF

   SayPrivDir( cDirPriv )

   RETURN NIL



FUNCTION PokreniInstall( oApp )

   LOCAL cFile
   LOCAL lPitaj

   lPitaj := .F.

   cFile := oApp:oDatabase:cDirPriv

   IF ( cFile == nil )
      RETURN
   ENDIF

   IF !PostDir( cFile )
      lPitaj := .T.
   ENDIF

   cFile := oApp:oDatabase:cDirSif
   IF !PostDir( cFile )
      lPitaj := .T.
   ENDIF

   cFile := oApp:oDatabase:cDirKum
   IF !PostDir( cFile )
      lPitaj := .T.
   ENDIF

   IF lPitaj
      IF Pitanje(, "Pokrenuti instalacijsku proceduru ?", "D" ) == "D"
         oApp:oDatabase:install()
      ENDIF
   ENDIF

   RETURN


/*
  ulazni parametri aplikacije

  poziv: ./F01_kalk 11 11 /FN_ON_STARTUP:Alert\(\'hello\'\)
         ./F01_kalk 11 11 /FN_ON_STARTUP:vindija_import_txt_dokument\(\)

  mpar37( "/FN_ON_STARTUP:", oApp ) => .T.
*/

FUNCTION mpar37( x, oApp )

   lp3 := oApp:cP3
   lp4 := oApp:cP4
   lp5 := oApp:cP5
   lp6 := oApp:cP6
   lp7 := oApp:cP7

   RETURN ( compare_param_start_with( x, lp3 ) .OR. ;
            compare_param_start_with( x, lp4 ) .OR. ;
            compare_param_start_with( x, lp5 ) .OR. ;
            compare_param_start_with( x, lp6 ) .OR. ;
            compare_param_start_with( x, lp7 ) )


FUNCTION param_desni_dio( xVal )

  IF xVal != NIL
    s_cParamDesniDio := xVal
  ENDIF

  RETURN s_cParamDesniDio

/*
   primjer:
   x: "/FN_ON_START:"
   y: "/FN_ON_START:pokreni_me(1,2)""

*/
STATIC FUNCTION compare_param_start_with( x, y )

  LOCAL nLen

  IF y == NIL
     RETURN .F.
  ENDIF

  nLen := LEN( x )

  IF nLen == 0
     RETURN .F.
  ENDIF

  IF LEFT( y, nLen ) == x
     param_desni_dio( SUBSTR( y, nLen + 1 ) )
     RETURN .T.
  ENDIF

  RETURN .F.

FUNCTION mpar37cnt( oApp )

   LOCAL nCnt := 0

   IF oApp:cP3 <> nil
      ++nCnt
   ENDIF

   IF oApp:cP4 <> nil
      ++nCnt
   ENDIF

   IF oApp:cP5 <> nil
      ++nCnt
   ENDIF

   IF oApp:cP6 <> nil
      ++nCnt
   ENDIF

   IF oApp:cP7 <> nil
      ++nCnt
   ENDIF

   RETURN nCnt


FUNCTION mparstring( oApp )

   LOCAL cPars

   cPars := ""

   IF oApp:cP3 <> NIL
      cPars += "'" + oApp:cP3 + "'"
   ENDIF

   IF oApp:cP4 <> NIL
      IF !Empty( cPars ); cPars += ", ";ENDIF
      cPars += "'" + oApp:cP4 + "'"
   ENDIF

   IF oApp:cP5 <> NIL
      IF !Empty( cPars ); cPars += ", ";ENDIF
      cPars += "'" + oApp:cP5 + "'"
   ENDIF

   IF oApp:cP6 <> NIL
      IF !Empty( cPars ); cPars += ", ";ENDIF
      cPars += "'" + oApp:cP6 + "'"
   ENDIF

   IF oApp:cP7 <> NIL
      IF !Empty( cPars ); cPars += ", ";ENDIF
      cPars += "'" + oApp:cP7 + "'"
   ENDIF

   RETURN cPars


/*  PID(cStart)
 *   funkcije za kreiranje/brisanje PID fajla
 *  biljeska: PID (Program Idefntifcation)
 *
 *   cStart - "START" - na ulasku u aplikaciju napravi PID; "STOP"  - izbrisi pid fajl
 *
 * Primjer koda:
 * \code
 *
 * //pocetak aplikacije
 * PID("START")
 * ....
 * //u Quit proceduri (na kraju):
 * PID("STOP")
 *
 * \endcode
 *
 *
 * Primjer FMK.INI
 * \code
 *
 * Ime PID-a koji ce kreirati se cita iz EXEPATH/FMK.INI
 * [PID]
 * <IME_MODULA>_<IME_KORISNIKA> = IME_PID_FAJLA
 * Default vrijednost je <BROJMODULA>
 *
 *
 * Tako je za modul TOPS, za korisnika sistem
 * [PID]
 * TOPS_SYSTEM=8
 *
 * Ako imamo vise poziva TOPS-a iz istog EXE direktorija moramo u fmk ini za
 * svakog korisnika definisati ime PID-fajla:
 * [PID]
 * ;korisnik SYSTEM
 * TOPS_SYSTEM=8_KASA
 * ;za sve instal module isti je PID sto znaci da ga moze pokrenuti
 * ;samo jedan korisnik istovremeno
 * I_TOPS_SYSTEM=I_8
 * ;korisnik NELA
 * TOPS_NELA=8_KNJIG
 * I_TOPS_NELA=I_8
 * ;korisnik MEVLIDA
 * TOPS_MEVLIDA=8_KNJIG2
 * I_TOPS_NELA=I_8
 *
 * \endcode
 *
 */

FUNCTION PID( cStart )

   LOCAL cPom, cDefault, cPidFile
   LOCAL lKoristitiPid

#ifdef CLIP

   ? "pid ", cStart
#endif

   cPidDefault := iif ( goModul:cName == "TOPS", "D", "N" )
   lKoristitiPid := IzFmkIni( "FMK", "KoristiSePID", cPidDefault, EXEPATH ) == "N"

   IF ( ( cStart == "START" ) .AND. ( goModul:lStarted ) .OR. lKoristitiPid )
      // glavni aplikacijski objekat je vec startovan
      RETURN
   ENDIF

   IF gModul = "FIN"
      cDefault := "1"
   ELSEIF gModul = "KALK"
      cDefault := "2"
   ELSEIF gModul = "FAKT"
      cDefault := "3"
   ELSEIF gModul = "OS"
      cDefault := "4"
   ELSEIF gModul = "LD"
      cDefault := "5"
   ELSEIF gModul = "VIRM"
      cDefault := "6"
   ELSEIF gModul = "KAM"
      cDefault := "7"
   ELSEIF gModul = "TOPS"
      cDefault := "8"
   ELSEIF gModul = "HOPS"
      cDefault := "9"
   ELSEIF gModul = "KADEV"
      cDefault := "10"
   ELSEIF gModul = "TNAM"
      cDefault := "11"
   ENDIF

   cPom := gModul

   IF is_install()
      cDefault := "I_" + cDefault
      cPom := "I_" + cPom
   ENDIF

   cPom := cPom + "_" + Upper( AllTrim( ImeKorisn ) )

   // koji PID pripada ovoj aplikaciji ?
   // primjer TOPS_SYSTEM

   cPid := IzFmkIni( "PID", cPom, cDefault, EXEPATH )

   cPidFile := ToUnix( EXEPATH + cPid + ".pid" )

   IF cStart = "STOP"
      // zatvori PID
      IF Type( "gHndPid" ) <> "U"
         FClose( gHndPid )
      ENDIF
      FErase( cPidFile )
   ELSE

      PUBLIC gHndPid := FCreate( cPidFile )
      FClose( gHndPid )
      gHndPid := FOpen( cPidFile, 2 + 16 ) // exclusive
      IF gHndPid < 0
         // ne mogu izbrisati  pid
         MsgBeep( " PID:" + cDefault + " je vec aktiviran !" )
         CLEAR SCREEN
         QUIT
      ENDIF

   ENDIF

   RETURN



/*  Prijava(oApp,lScreen)
 *   Prijava korisnika pri ulasku u aplikaciju
 *  todo: Prijava je primjer klasicne kobasica funkcije ! Razbiti je.
 *  todo: prijavu na osnovu scshell.ini izdvojiti kao posebnu funkciju
 */

FUNCTION Prijava( oApp, lScreen )

   LOCAL i
   LOCAL nRec
   LOCAL cKontrDbf
   LOCAL cCD

   LOCAL cPom
   LOCAL cPom2
   LOCAL lRegularnoZavrsen

   IF lScreen == nil
      lScreen := .T.
   ENDIF

   IF File2( EXEPATH + 'scshell.ini' )
      ScShellIni()
   ENDIF

   IF goModul:oDatabase:lAdmin
      CreKorisn()
   ENDIF

   O_KORISN
   DO WHILE .T.
      IF oApp:cKorisn <> NIL .AND. oApp:cSifra <> nil
         oApp:cKorisn := AllTrim( Upper( oApp:cKorisn ) )
         oApp:cSifra := CryptSC( Upper( PadR( oApp:cSifra, 6 ) ) )
         LOCATE FOR oApp:cSifra == korisn->sif
         // Postoji korisnik, sifra
         IF Found()
            EXIT
         ENDIF
      ENDIF

      m_ime := Space( 10 )
      m_sif := Space( 6 )
      GetSifra( oApp, @m_ime, @m_sif )
      IF oApp:lTerminate
         RETURN
      ENDIF
      SetColor( Normal )
      IF m_sif = "APPSRV"
         // aplikacijski server
         PRIVATE cKom := "{|| RunAppSrv()}"
         Eval ( &cKom )
      ENDIF
      IF Left( m_sif, 1 ) == "I"
         IF ( cKom == nil )
            cKom := ""
         ENDIF
         PrijRunInstall( m_sif, @cKom )
      ENDIF

      IF ( m_ime == "SIGMAX" .OR. m_sif == "SIGMAX" )
         Imekorisn := "SYSTEM"
         SifraKorisn := m_sif
         KLevel := "0"
         EXIT
      ENDIF

      m_sif := CryptSC( Upper( m_sif ) )


      oApp:cSifra := m_sif
      LOCATE FOR oApp:cSifra == korisn->sif
      // Postoji korisnik, sifra
      IF Found()
         EXIT
      ENDIF

   ENDDO

   LOCATE FOR oApp:cSifra == korisn->sif
   CONTINUE

   IF Found()

      // postoji vise od jedne sifre
      IF ( oApp:cKorisn == NIL )
         oApp:cKorisn := Space( 10 )
      ELSE
         oApp:cKorisn := PadR( oApp:cKorisn, 10 )
      ENDIF

      LOCATE FOR oApp:cSifra == korisn->sif .AND. korisn->ime == oApp:cKorisn
      IF !Found()
         DO WHILE .T. // oznaka preduzeca
            Box(, 2, 30 )
            @ m_x + 1, m_y + 2 SAY "Oznaka preduzeca:" GET oApp:cKorisn
            READ
            BoxC()
            IF LastKey() == K_ESC
               CLEAR
               oApp:quit()
            ENDIF
            LOCATE FOR oApp:cSifra == korisn->sif .AND. korisn->ime == oApp:cKorisn
            IF Found()
               EXIT
            ENDIF
         ENDDO
      ENDIF
   ELSE
      // samo jedna sifra
      LOCATE FOR oApp:cSifra == korisn->sif
      oApp:cKorisn := korisn->ime
   ENDIF

   @ 3, 4 SAY ""
   IF ( gfKolor == "D" .AND. IsColor() )
      Normal := "GR+/B,R/N+,,,N/W"
   ELSE
      Normal := "W/N,N/W,,,N/W"
   ENDIF

   IF !oApp:lStarted
      IF lScreen
         PozdravMsg( gNaslov, gVerzija, .F. )
      ENDIF
   ENDIF

   IF ( gfKolor == "D" .AND. IsColor() )
      Normal := "W/B,R/N+,,,N/W"
   ELSE
      Normal := "W/N,N/W,,,N/W"
   ENDIF

   IF ( oApp:cKorisn == "SYSTEM" )

      oApp:oDatabase:setDirKum( "." )
      oApp:oDatabase:setDirSif( "." )
      oApp:oDatabase:setDirPriv( "." )

   ELSE

      SELECT korisn
      LOCATE FOR oApp:cSifra == field->sif .AND. field->ime == oApp:cKorisn

      // eliminsati i ove globalne varijable
      ImeKorisn := korisn->ime
      SifraKorisn := korisn->sif

      oApp:oDatabase:setDirKum( ToUnix( korisn->dirRad ) )
      oApp:oDatabase:setDirSif( ToUnix( korisn->dirSif ) )
      oApp:oDatabase:setDirPriv( ToUnix( korisn->dirPriv ) )

      // KLevel ... ubaciti u TAppMod klasu
      KLevel := level

      IF !gReadonly
         REPLACE dat WITH Date()
         REPLACE time WITH Time()
         REPLACE nk WITH .T.
      ENDIF

   ENDIF

   System := ( Trim( ImeKorisn ) == "SYSTEM" )
   USE

   // silent
   SetDirs( oApp, .F. )

   CLOSERET

   RETURN NIL



FUNCTION ScShellIni( oApp )

   LOCAL cPPSaMr
   LOCAL cBazniDir
   LOCAL cMrRs
   LOCAL cBrojLok

   cPPSaMr := ""
   cPPSaMr := R_IniRead ( 'TekucaLokacija', 'PrivPodSaMrezeU',  "", EXEPATH + 'scshell.INI' )
   // u ovu varijablu staviti direktorij npr C:\SIGMA
   cBazniDir := R_IniRead ( 'TekucaLokacija', 'BazniDir',  "", EXEPATH + 'scshell.INI' )
   cMrRS := R_IniRead ( 'TekucaLokacija', 'RS',  "", EXEPATH + 'scshell.INI' )
   cBrojLok := R_IniRead ( 'TekucaLokacija', 'Broj',  "", EXEPATH + 'scshell.INI' )
   // Mrezna radna stanica


   IF goModul:oDatabase:lAdmin
      CreKorisn()
   ENDIF

   O_KORISN
   // napravi u korisn ovog korisnika
   IF !Empty( cPPSaMr )
      LOCATE FOR field->ime == PadR( oApp:cKorisn, 6 )
      IF !Found()
         LOCATE FOR korisn->ime == PadR( Left( oApp:cKorisn, Len( oApp:cKorisn ) -1 ) + '1', 6 )
         // mora postojata korisnik 1 !!! na osnovu kojeg se formira novi korisnik
         // cKorisn = 501, cMRRs=5 -> 505
         IF Found()
            cPom := StrTran( Trim( DirPriv ), Left( Trim( DirPriv ), Len( cPPSaMr ) ), cPPSaMr )
            // K:\SIGMA\FIN\11  ->  C:\SIGMA\FIN\11
            cPom := Left( cPom, Len( cPom ) -1 ) + cMRRs
            // cMRS=8  =>  cPom:=C:\SIGMA\FIN\18
            // pravim direktorij, kopiram privatne fajlove za korisnika
            SAVE SCREEN TO cScr
            cls
            ? "Kopiram privatne fajlova za korisnika ..."
            ?
            DirMak2( cPom )
            cPom2 := StrTran( Trim( DirPriv ), Left( Trim( DirPriv ), Len( cBazniDir ) ), cBazniDir ) + SLASH
            ?  cPom2
            CopySve( "*." + DBFEXT, cPom2, cPom + SLASH )
            CopySve( "*." + INDEXEXT, cPom2, cPom + SLASH )
            CopySve( "*." + MEMOEXT, cPom2, cPom + SLASH )
            CopySve( "*.TXT", cPom2, cPom + SLASH )
            RESTORE SCREEN FROM cScr

            oApp:oDatabase:setDirRad( StrTran( Trim( DirRad ), Left( Trim( DirRad ), Len( cBazniDir ) ), cBazniDir ) )
            oApp:oDatabase:setDirSif( StrTran( Trim( DirSif ), Left( Trim( DirSif ), Len( cBazniDir ) ), cBazniDir ) )

            ApndKorisn( cKorisn, cPom, oApp:cDirSif, oApp:cDirKum )
            oApp:oDatabase:setDirPriv( "" )
            oApp:oDatabase:setDirSif( "" )
            oApp:oDatabase:setDirKum( "" )

         ELSE
            MsgBeep( "Mora postojati korisnik :" + Left( cKorisn, Len( cKorisn ) -1 ) + '1' )
            oApp:quit()
         ENDIF
      ENDIF


   ENDIF

   RETURN


STATIC FUNCTION GetSifra( oApp, m_ime, m_sif )

   @ 10, 20 SAY ""
   m_ime := Space( 10 )
   m_sif := Space( 6 )

   Box( "pas", 3, 30, .F. )

   SET CURSOR ON
   @ m_x + 3, m_y + 9 SAY "<ESC> Izlaz"
   @ m_x + 1, m_y + 2 SAY "Sifra         "

   m_sif := Upper( GetSecret( m_sif ) )

   IF ( LastKey() == K_ESC )
      CLEAR
      oApp:quit()
   ENDIF
   SET CURSOR OFF

   BoxC()

   m_ime := AllTrim( Upper( m_ime ) )

   RETURN


STATIC FUNCTION PrijRunInstall( m_sif, cKom )

   IF m_sif == "I"
      cKom := cKom := "I" + gModul + " " + ImeKorisn + " " + CryptSC( sifrakorisn )
   ENDIF
   IF m_sif == "IM"
      cKom += "  /M"
   ENDIF
   IF m_sif == "II"
      cKom += "  /I"
   ENDIF
   IF m_sif == "IR"
      cKom += "  /R"
   ENDIF
   IF m_sif == "IP"
      cKom += "  /P"
   ENDIF
   IF m_sif == "IB"
      cKom += "  /B"
   ENDIF
   RunInstall( cKom )

   RETURN



STATIC FUNCTION ApndKorisn( cKorisn, cDirPriv, cDirSif, cDirKum )

   APPEND BLANK
   REPLACE ime WITH cKorisn
   REPLACE sif WITH Crypt( PadR( cKorisn, 6 ) )
   REPLACE dat WITH Date()
   REPLACE time WITH Time()
   REPLACE prov WITH 0
   REPLACE level WITH "0"
   REPLACE nk WITH .F.
   REPLACE level WITH "0"
   REPLACE dirPriv WITH cDirPriv
   REPLACE dirSif WITH cDirSif
   REPLACE dirRad WITH cDirKum

   RETURN



FUNCTION SetDirs( oApp, lScreen )

   LOCAL cDN := "N"
   LOCAL cPom

   IF lScreen == nil
      lScreen := .T.
   ENDIF

   SELECT ( F_KORISN )
   USE
   O_KORISN

   LOCATE FOR AllTrim( ImeKorisn ) == AllTrim( korisn->ime ) .AND. SifraKorisn = korisn->sif
   Scatter()

   IF is_install() .OR. lScreen
      Box( "radD", 5, 65, .F., "Lokacije podataka" )
      SET CURSOR ON
      @ m_x + 1, m_y + 2 SAY "Podesiti direktorije  "  GET cDN PICTURE "@!" VALID cDN $ "DN"
      @ m_x + 3, m_y + 2 SAY "Radni direktorij      "  GET _DirRad PICTURE "@!";
         VALID( DirExists( _DirRad ) ) WHEN cDN == "D"
      @ m_x + 4, m_y + 2 SAY "Direktorij sifrarnika "  GET _DirSif PICTURE "@!";
         VALID( DirExists( _DirSif ) ) WHEN cDN == "D"
      @ m_x + 5, m_y + 2 SAY "Privatni direktorij   "  GET _DirPriv PICTURE "@!";
         VALID( DirExists( _DirPriv ) )  WHEN cDN == "D"
      READ
      ESC_BCR
      BoxC()

      IF !gReadOnly
         Gather()
      ENDIF

      @ 0, 24 SAY PadR( Trim( ImeKorisn ) + ":" + cDirPriv, 25 ) COLOR INVERT
   ENDIF

   USE

   oApp:oDatabase:setDirPriv( _DirPriv )
   oApp:oDatabase:setDirSif( _DirSif )
   oApp:oDatabase:setDirKum( _DirRad )

   IF gReadOnly .AND. ( IzFmkIni( 'Svi', 'CitatiCD', 'N', EXEPATH ) == "D" )
      cCD := ""
      IF File( EXEPATH + 'scshell.ini' )
         cCD := ""
         cCD := R_IniRead ( 'TekucaLokacija', 'CD', "", EXEPATH + 'scshell.INI' )
      ENDIF
      IF Empty( cCD ) .AND. Pitanje(, "Citati podatke sa CD-a ?", "N" ) == "D"
         cCd := "E"
         Box(, 1, 60 )
         @ m_x + 1, m_y + 2 SAY "CD UREDJAJ:" GET cCD PICT "@!"
         READ
         BoxC()
      ENDIF
      IF !Empty( cCD )
         cPom := cCD + SubStr( oApp:oDatabase:cDirPriv, 2 )
         oApp:oDatabase:setDirPriv( cPom )
         cPom := cCD + SubStr( oApp:oDatabase:cDirSif, 2 )
         oApp:oDatabase:setDirSif( cPom )
         cPom := cCD + SubStr( oApp:oDatabase:cDirKum, 2 )
         oApp:oDatabase:setDirKum( cPom )
      ENDIF
   ENDIF

FUNCTION RunInstall( cKom )

   LOCAL lIB

   lIB := .F.

   IF ( cKom == nil )
      cKom := ""
   ENDIF

   // MsgBeep("cKom="+cKom)
   IF ( " /B" $ cKom )
      goModul:cP7 := "/B"
      lIb := .T.
   ENDIF
   goModul:oDatabase:install()

   IF ( lIB )
      goModul:cP7 := ""
      lIB := .F.
   ENDIF




/*
function T_Start(nHPid, cPath, cModul, cUser )

local hH, nCnt
local cFN
local cBuf

cBuf:=space(10)
cFN:=cPath+gmodul+'.pid'
do while .t.
  nHPid:=FCREATE(cFN)
  if nHPid < 0
     nH:=fopen(cFN)
     nCnt:=fread(nH,@cBuf)
     FClose(nH)
     @ 23,65 SAY "..azurira:"+left(cBuf,nCnt)
     inkey(1)
     @ 23,65 SAY space(10)
     if lastkey()=27
        exit
     endif
  else
     fwrite(nHPid,cUser)
     exit
  endif
enddo
return nHPid


function T_Stop(nHPid, cPath, cModul, cUser )

local cFN
cFN:=cPath+cmodul+'.pid'
fclose(nHPid)
ferase(cFN)
return


*/

FUNCTION IzvrsenIn( p3, fImodul, cModul, fsilent )

   LOCAL i, nCheck, fid, cBuffer, nBytes

   PUBLIC EVar := "#Erky#bringout#0000"

   IF fimodul == NIL; fImodul := .F. ; ENDIF
   IF cmodul == NIL; cModul := gModul; ENDIF
   IF fsilent == NIL; fSilent := .F. ; ENDIF

   RETURN .T.
