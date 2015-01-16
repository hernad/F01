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


FUNCTION TAppModNew( oParent, cVerzija, cPeriod, cKorisn, cSifra, p3, p4, p5, p6, p7 )

   LOCAL oObj

   oObj := TAppMod():new()

   oObj:self := oObj

   RETURN oObj



#include "class(y).ch"

CREATE CLASS TAppMod

   EXPORTED:
   VAR cName
   VAR oParent
   VAR oDatabase
   VAR oDesktop
   VAR cVerzija
   VAR cPeriod
   VAR cKorisn
   VAR cSifra
   VAR nKLicenca
   VAR cP3
   VAR cP4
   VAR cP5
   VAR cP6
   VAR cP7
   VAR cSqlLogBase
   VAR lSqlDirektno
   VAR lStarted
   VAR lTerminate
   VAR self
   METHOD hasParent
   METHOD setParent
   METHOD getParent
   METHOD setName
   METHOD RUN
   METHOD QUIT
   METHOD gProc
   METHOD INIT
   METHOD gParams
   METHOD setGVars
   METHOD limitKLicenca

END CLASS


METHOD TAppMod:init( oParent, cModul, cVerzija, cPeriod, cKorisn, cSifra, p3, p4, p5, p6, p7 )

   ::cName := cModul
   ::oParent := oParent
   ::oDatabase := nil
   ::cVerzija := cVerzija
   ::cPeriod := cPeriod
   ::cKorisn := cKorisn
   ::cSifra := cSifra
   ::cP3 := p3
   ::cP4 := p4
   ::cP5 := p5
   ::cP6 := p6
   ::cP7 := p7
   ::lTerminate := .F.

   RETURN


METHOD TAppMod:setGvars()


   f01_set_gvars_10()
   f01_set_gvars_20()


   IniPrinter()
   JelReadOnly()

   PUBLIC cZabrana := "Opcija nedostupna za ovaj nivo !"

   ::cSqlLogBase := IzFmkIni( "Sql", "SqlLogBase", "c:" + SLASH + "sigma" )
   gSqlLogBase := ::cSqlLogBase

   IF IzFmkIni( "Sql", "SqlDirektno", "D" ) == "D"
      ::lSqlDirektno := .T.
   ELSE
      ::lSqlDirektno := .F.
   ENDIF

   IF ( ::oDesktop != nil )
      ::oDesktop := nil
   ENDIF

   ::oDesktop := TDesktopNew()

   IniGparam2()
   BosTipke()
   KonvTable()

   //f01_set_global_vars()

   // silent
   //SetDirs( ::self, .F. )

   RETURN


/*  *bool TAppMod::hasParent()
 *   ima li objekat "roditelja"
 */

// bool TAppMod::hasParent()

METHOD hasParent()

   RETURN !( ::oParent == nil )



/*  *TObject TAppMod::setParent(TObject oParent)
 *   postavi roditelja ovog objekta
 *
 *  Roditelj je programski modul (objekat) koji je izvrsio kreiranje ovog objekta. To bi znacilo za oPos to parent oFMK - "master" aplikacijski modul koji poziva pojedinacne programske module (oFIN, oKALK, oFAKT)
 */
// TObject TAppMod::setParent(TObject oParent)

METHOD setParent( oParent )

   ::parent := oParent

   RETURN



/*  *TObject TAppMod::getParent()
 *   Daj mi roditelja ovog objekta
 */

// TObject TAppMod::getParent()

METHOD getParent()
   return ::oParent



// string TAppMod::setName(string cName)

METHOD setName()

   ::cName := "SCAPP"

   RETURN


METHOD TAppMod:RUN()

   altd()
   if ::oDesktop == nil
      ::oDesktop := TDesktopNew()
   ENDIF
   if ::lStarted == nil
      ::lStarted := .F.
   ENDIF

   f01_start( ::self, .T. )
   IF !::lStarted
      PID( "START" )
   ENDIF
   // da se zna da je objekat jednom vec startovan
   ::lStarted := .T.

   if ::lTerminate
      ::quit()
      RETURN
   ENDIF
   ::MMenu()

   RETURN


METHOD TAppMod:gProc( Ch )

   LOCAL lPushWa
   LOCAL i

   DO CASE

   CASE ( Ch == K_SH_F12 )
      InfoPodrucja()

   CASE ( Ch == K_SH_F1  .OR. Ch == K_CTRL_F1 )
      Calc()

   CASE ( Ch == K_SH_F2 .OR. Ch == K_CTRL_F2 )
      PPrint()

   CASE Ch == K_SH_F10
      ::gParams()

   CASE Ch == K_SH_F5
      ::oDatabase:vratiSez()

   CASE Ch == K_ALT_F6
      ProcPrenos()

   CASE Ch == K_SH_F6
      ::oDatabase:logAgain()

   CASE Ch == K_SH_F7
      KorLoz()

   CASE Ch == K_SH_F8
      TechInfo()

   CASE Ch == K_SH_F9
      Adresar()

   CASE Ch == K_CTRL_F10
      SetROnly()

   CASE Ch == K_ALT_F11
      ShowMem()

   OTHERWISE
      IF !( "U" $ Type( "gaKeys" ) )
         FOR i := 1 TO Len( gaKeys )
            IF ( Ch == gaKeys[ i, 1 ] )
               Eval( gaKeys[ i, 2 ] )
            ENDIF
         NEXT
      ENDIF
   ENDCASE

   RETURN



/*  *void TAppMod::quit(bool lVratiseURP)
 *   izlazak iz aplikacijskog modula
 *   lVratiSeURP - default vrijednost .t.; kada je .t. vrati se u radno podrucje; .f. ne mjenjaj radno podrucje
 *
 *  todo: proceduru izlaska revidirati, izbaciti Rad.sys iz upotrebe, kao i korisn.dbf
 */

// void TAppMod::quit(bool lVratiSeURP)

METHOD QUIT( lVratiseURP )

   LOCAL cKontrDbf

   CLOSE ALL
   IF ( lVratiseURP == nil )
      lVratiseURP := .T.
   ENDIF

#ifdef CLIP
   ? "quit metod."
#endif

   O_KORISN
   LOCATE FOR ( AllTrim( ImeKorisn ) == AllTrim( korisn->ime ) .AND. SifraKorisn == korisn->sif )

   SetColor( StaraBoja )

   IF lVratiseURP // zatvori korisnika
      IF !Empty( goModul:oDataBase:cSezonDir )
         // prebaci se u radno podrucje, ali nemoj to zapisati
         URadPodr( .F. )
      ENDIF
   ENDIF


   ::lTerminate := .T.

   PID( "STOP" )
   CLEAR SCREEN

   IF !( ::hasParent() )
      IF !gReadonly
         IF Found()
            REPLACE field->nk WITH .F.
         ELSE
            QUIT
         ENDIF
         USE
         MsgO( "Brisem RAD.SYS ..." )
         ERASE Rad.sys
         MsgC()
      ENDIF
      QUIT
   ENDIF

   RETURN



// void TAppMod::gParams()

METHOD gParams()

   LOCAL cFMKINI := "N"
   LOCAL cPosebno := "N"
   LOCAL cOldBoje := SetColor( INVERT )
   LOCAL cInstall := "N"
   LOCAL lPushWa := .F.
   LOCAL cWinParams := "N"
   PRIVATE GetList := {}

   IF Used()
      lPushWa := .T.
      PushWa()
   ELSE
      lPushWa := .F.
   ENDIF

   PRIVATE cSection := "1"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}

   SELECT ( F_PARAMS )
   USE
   O_PARAMS

   RPar( "p?", @cPosebno )

   gArhDir := PadR( gArhDir, 20 )
   gPFont := PadR( gPFont, 20 )
   Box(, 20, 70 )
   SET CURSOR ON
   @ m_x + 1, m_y + 2 SAY "Parametre pohraniti posebno za korisnika "  GET cPosebno VALID cPosebno $ "DN" PICT "@!"
   READ
   WPAr( "p?", cPosebno )
   SELECT params
   USE
   IF cPosebno == "D"
      IF !File2( PRIVPATH + "gparams.dbf" )
         cScr := ""
         SAVE SCREEN TO cscr
         CopySve( "gpara*.*", SLASH, PRIVPATH )
         RESTORE SCREEN FROM cScr

      ENDIF
   ENDIF
   IF cPosebno == "D"
      SELECT ( F_GPARAMSP )
      USE
      O_GPARAMSP
   ELSE
      SELECT ( F_GPARAMS )
      USE
      O_GPARAMS
   ENDIF

   gPtkonv := PadR( gPtkonv, 2 )
   gLokal := PadR( gLokal, 2 )
   @ m_x + 3, m_y + 2 SAY "Konverzija znakova BEZ, 7-852, 7-A, 852-7, 852-A"
   @ m_x + 4, m_y + 2 SAY "                    0  / 1   /  2  / 3   /   4  "  GET gPTKonv PICT "@!" VALID subst( gPtkonv, 2, 1 ) $ " 1"
   @ m_x + 6, m_y + 2 SAY "Unos podataka u sifrarnike velika/mala slova/konv.u 852 (V/M/8)"  GET gPicSif VALID gpicsif $ "VM8" PICT "@!"
   @ m_x + 7, m_y + 2 SAY "Stroga kontrola ispravki/brisanja sifara     (D/N)"  GET gSKSif VALID gSKSif $ "DN" PICT "@!"
   @ m_x + 8, m_y + 2 SAY "Direktorij pomocne kopije podataka" GET gArhDir PICT "@!"
   @ m_x + 9, m_y + 2 SAY "Default odgovor na pitanje 'Izlaz direktno na printer?' (D/N/V/E)" GET gcDirekt VALID gcDirekt $ "DNVER" PICT "@!"
   @ m_x + 10, m_y + 2 SAY "Shema boja za prikaz na ekranu 'V' (B1/B2/.../B7):" GET gShemaVF
   @ m_x + 11, m_y + 2 SAY "Windows font:" GET gPFont
   @ m_x + 12, m_y + 2 SAY "Kodna strana:" GET gKodnaS VALID gKodnaS $ "78" PICT "9"
   @ m_x + 12, Col() + 2 SAY "Word 97  D/N:" GET gWord97 VALID gWord97 $ "DN" PICT "@!"
   @ m_x + 12, Col() + 2 SAY "Zaok 50f (5):" GET g50f    VALID g50f    $ " 5" PICT "9"
   @ m_x + 13, m_y + 2 SAY "Prenijeti podatke na lokalni disk (NDCX):" GET gKesiraj    VALID gKesiraj $ "NDCX" PICT "@!"
   @ m_x + 14, m_y + 2 SAY "Omoguciti kolor-prikaz? (D/N)" GET gFKolor VALID gFKolor $ "DN" PICT "@!"
   @ m_x + 15, Col() + 2 SAY "SQL log ? (D/N)" GET gSql PICT "@!"

   @ m_x + 16, m_y + 2 SAY "PDV rezim rada? (D/N)" GET gPDV PICT "@!" VALID gPDV $ "DN"

   @ m_x + 17, m_y + 2 SAY "Lokalizacija 0/hr/ba/en/sr " GET gLokal ;
      VALID gLokal $ "0 #hr#ba#sr#en" ;

      @ m_x + 18, m_y + 2 SAY "PDF stampa (N/D/X)?" GET gPDFPrint VALID {|| gPDFPrint $ "DNX" .AND. if( gPDFPrint $ "XD", pdf_box(), .T. ) } PICT "@!"

   @ m_x + 18, Col() + 2 SAY "windows parametri" GET cWinParams ;
      VALID {|| cWinParams $ "DN" .AND. ;
      if( cWinParams == "D", win_box(), .T. ) } PICT "@!"

   @ m_x + 20, m_y + 2 SAY "Ispravka FMK.INI (D/S/P/K/M/N)" GET cFMKINI VALID cFMKINI $ "DNSPKM" PICT "@!"
   @ m_x + 20, m_y + 36 SAY "M - FMKMREZ"


   READ
   BoxC()

   IF cFMKIni $ "DSPKM"
      PRIVATE cKom := "q "
      IF cFMKINI == "D"
         cKom += EXEPATH
      ELSEIF  cFMKINI == "K"
         cKom += KUMPATH
      ELSEIF  cFMKINI == "P"
         cKom += PRIVPATH
      ELSEIF  cFMKINI == "S"
         cKom += SIFPATH
      ENDIF
      // -- M je za ispravku FMKMREZ.BAT
      IF cFMKINI == "M"
         cKom += EXEPATH + "FMKMREZ.BAT"
      ELSE
         cKom += "FMK.INI"
      ENDIF

      Box(, 25, 80 )
      run &ckom
      BoxC()
      IniRefresh() // izbrisi iz cache-a
   ENDIF


   IF LastKey() <> K_ESC
      Wpar( "pt", gPTKonv )
      Wpar( "pS", gPicSif )
      Wpar( "SK", gSKSif )
      Wpar( "DO", gcDirekt )
      Wpar( "FK", gFKolor )
      Wpar( "S9", gSQL )
      UzmiIzIni( KUMPATH + "fmk.ini", "Svi", "SqlLog", gSql, "WRITE" )
      Wpar( "SB", gShemaVF )
      Wpar( "Ad", Trim( gArhDir ) )
      Wpar( "FO", Trim( gPFont ) )
      Wpar( "KS", gKodnaS )
      Wpar( "W7", gWord97 )
      Wpar( "5f", g50f )
      Wpar( "pR", gPDFPrint )
      IF gKesiraj $ "CD"
         IF sifra_za_koristenje_opcije( "SKESH" )
            Wpar( "kE", gKesiraj )
         ELSE
            MsgBeep( "Neispravna sifra!" )
         ENDIF
      ELSE
         Wpar( "kE", gKesiraj )
      ENDIF
      WPar( "L8", AllTrim( gLokal ) )
   ENDIF

   KonvTable()

   SELECT gparams
   USE

   SetColor( cOldBoje )

   // upisi i u params parametre za PDV / PRIVPATH+params.dbf
   O_PARAMS
   SELECT params
   WPar( "PD", gPDV )
   USE

   IF lPushWa
      PopWa()
   ENDIF

   RETURN



// ------------------------------------------------------------
// prikaz dodatnog box-a za stimanje windows parametara
// ------------------------------------------------------------
STATIC FUNCTION win_box()

   LOCAL nX := 1
   PRIVATE GetList := {}

   IF Pitanje(, "Podesiti windows parametre (D/N) ?", "D" ) == "N"
      RETURN .T.
   ENDIF

   Box(, 20, 75 )

   @ m_x + nX, m_y + 2 SAY "Podesavanje windows parametara *******"

   nX += 2

   @ m_x + nX, m_y + 2 SAY "OO lokacija:" GET gOOPath PICT "@S56"

   nX += 1

   @ m_x + nX, m_y + 2 SAY "OO Writer pokretac:" GET gOOWriter PICT "@S30"

   nX += 1

   @ m_x + nX, m_y + 2 SAY "OO Spread pokretac:" GET gOOSpread PICT "@S30"

   nX += 2

   @ m_x + nX, m_y + 2 SAY "Java bin path:" GET gJavaPath PICT "@S56"

   nX += 1

   @ m_x + nX, m_y + 2 SAY "Java starna komanda:" GET gJavaStart ;
      PICT "@S56"

   nX += 1

   @ m_x + nX, m_y + 2 SAY "JODReports lokacija:" GET gJODRep PICT "@S30"

   nX += 1

   @ m_x + nX, m_y + 2 SAY "Lokacija template fajlova:" GET gJODTemplate PICT "@S30"

   READ
   BoxC()

   IF LastKey() <> K_ESC

      // snimi parametre.....
      Wpar( "oP", gOOPath )
      Wpar( "oW", gOOWriter )
      Wpar( "oS", gOOSpread )
      Wpar( "oJ", gJavaPath )
      Wpar( "jS", gJavaStart )
      Wpar( "jR", gJODRep )
      Wpar( "jT", gJODTemplate )

   ENDIF

   RETURN .T.



// ------------------------------------------------------------
// prikaz dodatnog box-a za stimanje parametara PDF stampe
// ------------------------------------------------------------
STATIC FUNCTION pdf_box()

   LOCAL nX := 1
   PRIVATE GetList := {}

   IF Pitanje(, "Podesiti parametre PDF stampe (D/N) ?", "D" ) == "N"
      RETURN .T.
   ENDIF

   Box(, 10, 75 )

   @ m_x + nX, m_y + 2 SAY "Podesavanje parametara PDF stampe *******"

   nX += 2

   @ m_x + nX, m_y + 2 SAY "PDF preglednik:" GET gPDFViewer VALID _g_pdf_viewer( @gPDFViewer ) PICT "@S56"

   nX += 1

   @ m_x + nX, m_y + 2 SAY "Printanje PDF-a bez poziva preglednika (D/N)?" GET gPDFPAuto VALID gPDFPAuto $ "DN" PICT "@!"

   nX += 2

   @ m_x + nX, m_y + 2 SAY "Default printer:" GET gDefPrinter PICT "@S55"


   READ
   BoxC()

   IF LastKey() <> K_ESC

      // generisi yml fajl iz parametara
      wr_to_yml()

      // snimi parametre.....
      Wpar( "pV", gPDFViewer )
      Wpar( "dP", gDefPrinter )
      Wpar( "pA", gPDFPAuto )

   ENDIF

   RETURN .T.


// ---------------------------------------------
// upisi u yml fajl podesenja
// ---------------------------------------------
STATIC FUNCTION wr_to_yml( cFName )

   LOCAL nH
   LOCAL cParams := ""
   LOCAL cNewRow := Chr( 13 ) + Chr( 10 )

   IF cFName == nil
      cFName := "fmk_pdf.yml"
   ENDIF

   // write params to yml
   cParams += "pdf_viewer: " + AllTrim( gPDFviewer )
   cParams += cNewRow
   cParams += "print_to: " + AllTrim( gDefPrinter )

   // kreiraj fajl
   nH := FCreate( EXEPATH + cFName )
   // upisi u fajl
   FWrite( nH, cParams )
   // zatvori fajl
   FClose( EXEPATH + cFName )

   RETURN



// -------------------------------------------
// vraca lokaciju pdf viewera
// -------------------------------------------
STATIC FUNCTION _g_pdf_viewer( cViewer )

   LOCAL cViewName := "acrord32.exe"
   LOCAL cViewPath := "c:\progra~1\adobe\"
   LOCAL aPath := Directory( cViewPath + "*.*", "D" )
   LOCAL cPom

   IF !Empty( cViewer )
      RETURN .T.
   ENDIF

   ASort( aPath, {| x, y| x[ 1 ] < y[ 1 ] } )

   nScan := AScan( aPath, {| xVal| Upper( xVal[ 1 ] ) = "ACRO" } )

   IF nScan > 0
      cPom := AllTrim( aPath[ nScan, 1 ] )

      cViewer := cViewPath + cPom
      cViewer += SLASH + "reader" + SLASH
      cViewer += cViewName

      cViewer := PadR( cViewer, 150 )

   ENDIF

   IF !Empty( cViewer ) .AND. !File2( cViewer )
      msgbeep( "Ne mogu naci Acrobat Reader!#Podesite rucno lokaciju preglednika..." )
   ENDIF

   RETURN .T.






/*  TAppMod::limitKLicenca(nLevel)
 *   Prikazuje poruku o ogranicenosti korisnicke licence
 *  return:  True ako je nLevel> oApp:nKLicenca return .t.
 */

// void TAppMod::limitKLicenca(nLevel)

METHOD limitKLicenca( nLevel )

   IF ( ::nKLicenca == nil )
      nKLicenca := 5
   ENDIF

   IF ( nLevel > ::nKLicenca )
      MsgBeep( "Prekoracen limit korisnicke licence" )
      RETURN .T.
   ENDIF

   RETURN .F.
