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


#include "kalk01.ch"

STATIC cENTER := Chr( K_ENTER ) + Chr( K_ENTER ) + Chr( K_ENTER )


/*  Knjiz()
 *   Nudi meni za rad na dokumentu u staroj varijanti ili direktno poziva tabelu pripreme u novoj (default) varijanti
 */

FUNCTION kalk_Knjiz()

   LOCAL izbor := 1

   PRIVATE PicCDEM := gPicCDEM
   PRIVATE PicProc := gPicProc
   PRIVATE PicDEM := gPICDEM
   PRIVATE Pickol := gPICKOL
   PRIVATE lAsistRadi := .F.

   IF gNW == "N"

      PRIVATE opc[ 6 ]

      Opc[ 1 ] := "1. unos               "
      Opc[ 2 ] := "2. stampa"
      Opc[ 3 ] := "3. rekapitulacija"
      Opc[ 4 ] := "4. kontiranje"
      Opc[ 5 ] := "5. azuriranje"
      Opc[ 6 ] := "6. kurs:" + KursLis

      DO WHILE .T.
         Izbor := menu( "knjiz", opc, Izbor, .F. )

         DO CASE
         CASE Izbor == 0
            EXIT
         CASE izbor == 1
            f01_kalk_unos()
         CASE izbor == 2
            StKalk()
         CASE izbor == 3
            kalk_pripr_2_finmat()
         CASE izbor == 4
            kalk_kontiranje_naloga()
         CASE izbor == 5
            kalk_Azur()
         CASE izbor == 6
            IF KursLis == "1"  // prva vrijednost
               KursLis := "2"
            ELSE
               KursLis := "1"
            ENDIF
            Opc[ 6 ] := "6. kurs:" + KursLis
         ENDCASE

      ENDDO

   ELSE  // gnw=="D"
      f01_kalk_unos()
   ENDIF

   closeret

   RETURN




/*  f01_kalk_unos(lAutoObrada)
 *   Tabela pripreme dokumenta
 */

FUNCTION f01_kalk_unos( lAObrada )

   O_PARAMS

   PRIVATE lAutoObr := .F.
   PRIVATE lAAsist := .F.
   PRIVATE lAAzur := .F.

   IF lAObrada == nil
      lAutoObr := .F.
   ELSE
      lAutoObr := lAObrada
      lAAsist := .T.
      lAAzur := .T.
   ENDIF

   PRIVATE cSection := "K"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}
   SELECT 99
   USE


   kalk_oedit()

   PRIVATE gVarijanta := "2"
   PRIVATE PicV := "99999999.9"

   ImeKol := { ;
      { "F.", {|| IdFirma                  }, "IdFirma"     }, ;
      { "VD", {|| IdVD                     }, "IdVD"        }, ;
      { "BrDok", {|| BrDok                    }, "BrDok"       }, ;
      { "R.Br", {|| Rbr                      }, "Rbr"         }, ;
      { "Dat.Kalk", {|| DatDok                   }, "DatDok"      }, ;
      { "Dat.Fakt", {|| DatFaktP                 }, "DatFaktP"    }, ;
      { "K.zad. ", {|| IdKonto                  }, "IdKonto"     }, ;
      { "K.razd.", {|| IdKonto2                 }, "IdKonto2"    }, ;
      { "IdRoba", {|| IdRoba                   }, "IdRoba"      }, ;
      { "Kolicina", {|| Transform( Kolicina, picv ) }, "kolicina"    }, ;
      { "IdTarifa", {|| idtarifa                 }, "idtarifa"    }, ;
      { "F.Cj.", {|| Transform( FCJ, picv )      }, "fcj"         }, ;
      { "F.Cj2.", {|| Transform( FCJ2, picv )     }, "fcj2"        }, ;
      { "Nab.Cj.", {|| Transform( NC, picv )       }, "nc"          }, ;
      { "VPC", {|| Transform( VPC, picv )      }, "vpc"         }, ;
      { "VPCj.sa P.", {|| Transform( VPCsaP, picv )   }, "vpcsap"      }, ;
      { "MPC", {|| Transform( MPC, picv )      }, "mpc"         }, ;
      { "MPC sa PP", {|| Transform( MPCSaPP, picv )  }, "mpcsapp"     }, ;
      { "RN", {|| idzaduz2                 }, "idzaduz2"    }, ;
      { "Br.Fakt", {|| brfaktp                  }, "brfaktp"     }, ;
      { "Partner", {|| idpartner                }, "idpartner"   }, ;
      { "E", {|| error                    }, "error"       } ;
      }


   Kol := {}

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   Box(, 20, 77 )

   @ m_x + 17, m_y + 2 SAY "<c-N>  Nove Stavke      " + BOX_CHAR_USPRAVNO + "<ENT> Ispravi stavku    " + BOX_CHAR_USPRAVNO + "<c-T>  Brisi Stavku   "
   @ m_x + 18, m_y + 2 SAY "<c-A>  Ispravka Naloga  " + BOX_CHAR_USPRAVNO + "<c-P> Stampa Kalkulacije" + BOX_CHAR_USPRAVNO + "<a-A> Azuriranje      "
   @ m_x + 19, m_y + 2 SAY "<a-K>  Rekap+Kontiranje " + BOX_CHAR_USPRAVNO + "<c-F9> Brisi pripremu   " + BOX_CHAR_USPRAVNO + "<a-P> Stampa pripreme "
   @ m_x + 20, m_y + 2 SAY "<c-F8> Raspored troskova" + BOX_CHAR_USPRAVNO + "<a-F10> asistent        " + BOX_CHAR_USPRAVNO + "<F10>,<F11> Ost.opcije"
   IF gCijene == "1" .AND. gMetodaNC == " "
      Soboslikar( { { m_x + 17, m_y + 1, m_x + 20, m_y + 77 } }, 23, 14 )
   ENDIF

   PRIVATE lAutoAsist := .F.

   f01_db_edit( "PNal", 20, 77, {|| f01_kalk_edit_priprema_opcije( lAutoObr ) }, "<F5>-kartica magacin, <F6>-kartica prodavnica", "Priprema...", , , , , 4 )
   BoxC()

   CLOSERET

   RETURN




/*  kalk_oedit()
 *   Otvara sve potrebne baze za pripremu dokumenata
 */

FUNCTION kalk_oedit()

   O_DOKS
   O_PRIPR
   O_DOKSRC
   O_P_DOKSRC
   O_SIFK
   O_SIFV
   O_ROBA
   O_KALK
   O_KONTO
   O_PARTN
   O_TDOK
   O_VALUTE
   O_TARIFA
   O_KONCIJ

   SELECT PRIPR
   SET ORDER TO 1
   GO TOP

   RETURN




/*  f01_kalk_edit_priprema_opcije(lAObrada)
 *   Obrada dostupnih opcija u tabeli pripreme
 */

FUNCTION f01_kalk_edit_priprema_opcije()

   LOCAL nTr2, cSekv, nkekk
   LOCAL isekv

   IF ( Ch == K_CTRL_T .OR. Ch == K_ENTER ) .AND. Eof()
      RETURN DE_CONT
   ENDIF

   PRIVATE PicCDEM := gPicCDEM
   PRIVATE PicProc := gPicProc
   PRIVATE PicDEM := gPicDEM
   PRIVATE Pickol := gPicKol

   SELECT pripr
   DO CASE
   CASE Ch == K_ALT_H
      Savjetnik()
   CASE Ch == K_ALT_K
      CLOSE ALL
      kalk_pripr_2_finmat()
      IF Pitanje(, "Zelite li izvrsiti kontiranje ?", "D" ) == "D"
         kalk_kontiranje_naloga()
      ENDIF
      kalk_oedit()
      RETURN DE_REFRESH
   CASE Ch == K_ALT_P
      CLOSE ALL
      IzbDokOLPP()
      // StPripr()
      kalk_oedit()
      RETURN DE_REFRESH
   CASE Ch == K_ALT_L
      CLOSE ALL
      label_bkod()
      kalk_oedit()
      RETURN DE_REFRESH

   CASE Ch == K_ALT_Q
      IF Pitanje(, "Stampa naljepnica(labela) za robu ?", "D" ) == "D"
         CLOSE ALL
         RLabele()
         kalk_oedit()
         RETURN DE_REFRESH
      ENDIF
      RETURN DE_CONT
   CASE Ch == K_ALT_A

      CLOSE ALL
      kalk_Azur()
      kalk_oedit()
      IF PRIPR->( RecCount() ) == 0 .AND. IzFMKINI( "Indikatori", "ImaU_KALK", "N", PRIVPATH ) == "D"
         O__KALK
         SELECT PRIPR
         APPEND FROM _KALK
         UzmiIzINI( PRIVPATH + "FMK.INI", "Indikatori", "ImaU_KALK", "N", "WRITE" )
         CLOSE ALL
         kalk_oedit()
         MsgBeep( "Stavke koje su bile privremeno sklonjene sada su vracene! Obradite ih!" )
      ENDIF
      RETURN DE_REFRESH

   CASE Ch == K_CTRL_P
      IF IsJerry()
         JerryMP()
      ENDIF
      CLOSE ALL
      StKalk()
      kalk_oedit()
      RETURN DE_REFRESH

   CASE Ch == K_CTRL_T
      IF Pitanje(, "Zelite izbrisati ovu stavku ?", "D" ) == "D"

         cStavka := pripr->rbr
         cArtikal := pripr->idroba
         nKolicina := pripr->kolicina
         nNc := pripr->nc
         nVpc := pripr->vpc

         DELETE

         RETURN DE_REFRESH
      ENDIF
      RETURN DE_CONT

   CASE IsDigit( Chr( Ch ) )
      Msg( "Ako zelite zapoceti unos novog dokumenta: <Ctrl-N>" )
      RETURN DE_CONT
   CASE Ch == K_ENTER
      RETURN EditStavka()
   CASE Ch == K_CTRL_A
      RETURN kalk_edit_stavke_cirkularno()
   CASE Ch == K_CTRL_N  // nove stavke
      RETURN NovaStavka()
   CASE Ch == K_CTRL_F8
      RaspTrosk()
      RETURN DE_REFRESH

   CASE Ch == K_CTRL_F9
      IF Pitanje(, "Zelite Izbrisati cijelu pripremu ??", "N" ) == "D"

         cOpis := pripr->idfirma + "-" + ;
            pripr->idvd + "-" + ;
            pripr->brdok



         zapp()
         SELECT p_doksrc
         zapp()
         SELECT pripr
         RETURN DE_REFRESH

      ENDIF
      RETURN DE_CONT
   CASE Ch == K_ALT_F10 .OR. lAutoAsist

      RETURN KnjizAsistent()

   CASE Ch == K_F10
      RETURN MeniF10()

   CASE Ch == K_F11
      RETURN MeniF11()

   CASE Ch == K_F5
      Kmag()
      RETURN DE_CONT

   CASE Ch == K_F6

      KPro()
      RETURN DE_CONT
   CASE lAutoObr .AND. lAAsist
      // automatski obradi dokument
      // asistent
      lAAsist := .F.
      RETURN KnjizAsistent()

   CASE lAutoObr .AND. !lAAsist
      lAutoObr := .F.
      KEYBOARD Chr( K_ESC )
      RETURN DE_REFRESH
   ENDCASE

   RETURN DE_CONT


/*  EditStavka()
 *   Ispravka stavke dokumenta u pripremi
 */

FUNCTION EditStavka()

   IF reccount2() == 0
      Msg( "Ako zelite zapoceti unos novog dokumenta: <Ctrl-N>" )
      RETURN DE_CONT
   ENDIF

   Scatter()

   IF Left( _idkonto2, 3 ) = "XXX"
      Beep( 2 )
      Msg( "Ne mozete ispravljati protustavke" )
      RETURN DE_CONT
   ENDIF

   nRbr := RbrUNum( _Rbr );_ERROR := ""

   Box( "ist", 20, 77, .F. )
   IF kalk_edit_pripr( .F. ) == 0
      BoxC()
      RETURN DE_CONT
   ELSE
      BoxC()
      IF _ERROR <> "1"
         _ERROR := "0"
      ENDIF       // stavka onda postavi ERROR
      IF _idvd == "16"
         _oldval := _vpc * _kolicina  // vrijednost prosle stavke
      ELSE
         _oldval := _mpcsapp * _kolicina  // vrijednost prosle stavke
      ENDIF
      _oldvaln := _nc * _kolicina
      Gather()
      IF _idvd $ "16#80" .AND. !Empty( _idkonto2 )
         cIdkont := _idkonto
         cIdkont2 := _idkonto2
         _idkonto := cidkont2
         _idkonto2 := "XXX"
         _kolicina := -kolicina

         Box( "", 21, 77, .F., "Protustavka" )
         SEEK _idfirma + _idvd + _brdok + _rbr
         _Tbanktr := "X"
         DO WHILE !Eof() .AND. _idfirma + _idvd + _brdok + _rbr == idfirma + idvd + brdok + rbr
            IF Left( idkonto2, 3 ) == "XXX"
               Scatter()
               _TBankTr := ""
               EXIT
            ENDIF
            SKIP
         ENDDO
         _idkonto := cidkont2
         _idkonto2 := "XXX"
         IF _idvd == "16"
            IF IsPDV()
               Get1_16bPDV()
            ELSE
               Get1_16b()
            ENDIF
         ELSE
            Get1_80b()
         ENDIF
         IF _TBanktr == "X"
            APPEND ncnl
         ENDIF
         IF _ERROR <> "1"
            _ERROR := "0"
         ENDIF       // stavka onda postavi ERROR
         Gather()
         BoxC()
      ENDIF
      RETURN DE_REFRESH
   ENDIF

   RETURN DE_CONT




/*  NovaStavka()
 *   Unos nove stavke dokumenta u pripremi
 */

FUNCTION NovaStavka()

   // isprazni kontrolnu matricu
   aNC_ctrl := {}
   Box( "knjn", 21, 77, .F., "Unos novih stavki" )
   _TMarza := "A"
   // ipak idi na zadnju stavku !
   GO BOTTOM

   IF Left( idkonto2, 3 ) = "XXX"
      SKIP -1
   ENDIF
   // TODO: popni se u odnosu na negativne brojeve
   // TODO: VIDJETI ?? negativne su protustavke ????!!! zar to ima
   DO WHILE !Bof()
      IF Val( rbr ) < 0; SKIP -1; else; exit; ENDIF
   ENDDO

   cIdkont := ""
   cidkont2 := ""
   DO WHILE .T.

      Scatter(); _ERROR := ""
      IF _idvd $ "16#80" .AND. _idkonto2 = "XXX"
         _idkonto := cidkont
         _idkonto2 := cidkont2
      ENDIF
      _Kolicina := _GKolicina := _GKolicin2 := 0
      _FCj := _FCJ2 := _Rabat := 0
      IF !( _IdVD $ "10#81" )
         _Prevoz := _Prevoz2 := _Banktr := _SpedTr := _CarDaz := _ZavTr := 0
      ENDIF
      _NC := _VPC := _VPCSaP := _MPC := _MPCSaPP := 0
      nRbr := RbrUNum( _Rbr ) + 1

      IF kalk_edit_pripr( .T. ) == 0
         EXIT
      ENDIF
      APPEND BLANK
      IF _ERROR <> "1"; _ERROR := "0"; ENDIF       // stavka onda postavi ERROR
      IF _idvd == "16"
         _oldval := _vpc * _kolicina  // vrijednost prosle stavke
      ELSE
         _oldval := _mpcsapp * _kolicina  // vrijednost prosle stavke
      ENDIF
      _oldvaln := _nc * _kolicina
      Gather()
      IF _idvd $ "16#80" .AND. !Empty( _idkonto2 )
         cIdkont := _idkonto
         cIdkont2 := _idkonto2
         _idkonto := cidkont2
         _idkonto2 := "XXX"
         _kolicina := -kolicina
         Box( "", 21, 77, .F., "Protustavka" )
         IF _idvd == "16"
            IF IsPDV()
               Get1_16bPDV()
            ELSE
               Get1_16b()
            ENDIF
         ELSE
            Get1_80b()
         ENDIF
         APPEND BLANK
         IF _ERROR <> "1"; _ERROR := "0"; ENDIF       // stavka onda postavi ERROR
         Gather()
         BoxC()
         _idkonto := cidkont
         _idkonto2 := cidkont2
      ENDIF
   ENDDO

   BoxC()

   RETURN DE_REFRESH


FUNCTION kalk_edit_stavke_cirkularno()

   // ovu opciju moze pozvati i asistent alt+F10 !
   PushWA()
   SELECT PRIPR
   // go top
   Box( "anal", 20, 77, .F., "Ispravka naloga" )
   nDug := 0
   nPot := 0
   DO WHILE !Eof()
      SKIP
      nTR2 := RecNo()
      SKIP - 1
      Scatter()
      _ERROR := ""
      IF Left( _idkonto2, 3 ) = "XXX"
         // 80-ka
         SKIP
         SKIP
         nTR2 := RecNo()
         SKIP - 1
         Scatter()
         _ERROR := ""
         IF Left( _idkonto2, 3 ) = "XXX"
            EXIT
         ENDIF
      ENDIF

      nRbr := RbrUNum( _Rbr )
      IF lAsistRadi
         // pocisti bafer
         CLEAR TYPEAHEAD
         // spucaj mu dovoljno entera za jednu stavku
         cSekv := ""
         FOR nkekk := 1 TO 17
            cSekv += cEnter
         NEXT
         KEYBOARD cSekv
      ENDIF
      IF kalk_edit_pripr( .F. ) == 0
         EXIT
      ENDIF
      SELECT PRIPR
      IF _ERROR <> "1"
         _ERROR := "0"
      ENDIF       // stavka onda postavi ERROR
      _oldval := _mpcsapp * _kolicina  // vrijednost prosle stavke
      _oldvaln := _nc * _kolicina
      Gather()
      IF _idvd $ "16#80" .AND. !Empty( _idkonto2 )
         cIdkont := _idkonto
         cIdkont2 := _idkonto2
         _idkonto := cidkont2
         _idkonto2 := "XXX"
         _kolicina := -kolicina

         Box( "", 21, 77, .F., "Protustavka" )
         SEEK _idfirma + _idvd + _brdok + _rbr
         _Tbanktr := "X"
         DO WHILE !Eof() .AND. _idfirma + _idvd + _brdok + _rbr == idfirma + idvd + brdok + rbr
            IF Left( idkonto2, 3 ) == "XXX"
               Scatter()
               _TBankTr := ""
               EXIT
            ENDIF
            SKIP
         ENDDO
         _idkonto := cidkont2
         _idkonto2 := "XXX"
         IF _idvd == "16"
            Get1_16b()
         ELSE
            Get1_80b()
         ENDIF
         IF _TBanktr == "X"
            APPEND ncnl
         ENDIF
         IF _ERROR <> "1"
            _ERROR := "0"
         ENDIF       // stavka onda postavi ERROR
         Gather()
         BoxC()
      ENDIF
      GO nTR2
   ENDDO
   Beep( 1 )
   CLEAR TYPEAHEAD
   PopWA()
   BoxC()
   lAsistRadi := .F.

   RETURN DE_REFRESH



/*  KnjizAsistent()
 *   Asistent za obradu stavki dokumenta u pripremi
 */

FUNCTION KnjizAsistent()

   lAutoAsist := .F.
   PRIVATE nEntera := 30
   IF IzFMKIni( "KALK", "PametniAsistent", "D", KUMPATH ) == "D"
      lAsistRadi := .T.
      csekv := Chr( K_CTRL_A )
      KEYBOARD csekv
   ELSE
      // nova varijanta rada asistenta mora se ukljuciti parametrom
      // PametniAsistent=D
      // -----------------
      lAsistRadi := .F.
      // -----------------
      FOR isekv := 1 TO Int( reccount2() / 15 ) + 1
         csekv := Chr( K_CTRL_A )
         FOR nkekk := 1 TO Min( reccount2(), 15 ) * 30
            cSekv += cEnter
         NEXT
         KEYBOARD csekv
      NEXT
   ENDIF

   RETURN DE_REFRESH



/*  MeniF10()
 *   Meni ostalih opcija koji se poziva tipkom F10 u tabeli pripreme
 */

FUNCTION MeniF10()

   PRIVATE opc[ 9 ]

   IF gVodiSamoTarife == "D"
      opc[ 1 ] := "1. generisi storno sume 41 u postojeci dokument                 "
   ELSE
      opc[ 1 ] := "1. prenos dokumenta fakt->kalk                                  "
   ENDIF
   opc[ 2 ] := "2. povrat dokumenta u pripremu"
   opc[ 3 ] := "3. priprema -> smece"
   opc[ 4 ] := "4. smece    -> priprema"
   opc[ 5 ] := "5. najstariji dokument iz smeca u pripremu"
   opc[ 6 ] := "6. generacija dokumenta inventure magacin "
   opc[ 7 ] := "7. generacija dokumenta inventure prodavnica"
   opc[ 8 ] := "8. generacija nivelacije prodavn. na osnovu niv. za drugu prod"
   opc[ 9 ] := "9. parametri obrade - nc / obrada sumnjivih dokumenata"
   h[ 1 ] := h[ 2 ] := ""

   SELECT pripr
   GO TOP
   cIdVDTek := IdVD  // tekuca vrsta dokumenta

   IF cidvdtek == "19"
      AAdd( opc, "A. obrazac promjene cijena" )
   ELSE
      AAdd( opc, "--------------------------" )
   ENDIF

   AAdd( opc, "B. pretvori 11 -> 41  ili  11 -> 42"        )
   AAdd( opc, "C. promijeni predznak za kolicine"          )
   AAdd( opc, "D. preuzmi tarife iz sifrarnika"            )
   AAdd( opc, "E. storno dokumenta"                        )
   AAdd( opc, "F. prenesi VPC(sifr)+POREZ -> MPCSAPP(dok)" )
   AAdd( opc, "G. prenesi MPCSAPP(dok)    -> MPC(sifr)"    )
   AAdd( opc, "H. prenesi VPC(sif)        -> VPC(dok)"     )
   AAdd( opc, "I. povrat (12,11) -> u drugo skl.(96,97)"   )
   AAdd( opc, "J. zaduzenje prodavnice iz magacina (10->11)"   )
   AAdd( opc, "K. veleprodaja na osnovu dopreme u magacin (16->14)"   )

   CLOSE ALL
   PRIVATE am_x := m_x, am_y := m_y
   PRIVATE Izbor := 1
   DO WHILE .T.
      Izbor := menu( "prip", opc, Izbor, .F. )
      DO CASE
      CASE Izbor == 0
         EXIT
      CASE izbor == 1
         IF gVodiSamoTarife == "D"
            Gen41S()
         ELSE
            FaktKalk()
         ENDIF
      CASE izbor == 2
         kalk_povrat()
      CASE izbor == 3
         Azur9()
      CASE izbor == 4
         Povrat9()
      CASE izbor == 5
         P9najst()

      CASE izbor == 6
         im()
      CASE izbor == 7
         ip()
      CASE izbor == 8
         GenNivP()
      CASE izbor == 9
         aRezim := { gCijene, gMetodaNC }
         O_PARAMS
         PRIVATE cSection := "K", cHistory := " "; aHistory := {}
         cIspravka := "D"
         SetMetoda()
         SELECT params; USE
         IF gCijene <> aRezim[ 1 ] .OR. gMetodaNC <> aRezim[ 2 ]
            IF gCijene == "1" .AND. gMetodaNC == " "
               Soboslikar( { { m_x + 17, m_y + 1, m_x + 20, m_y + 77 } }, 23, 14 )
            ELSEIF aRezim[ 1 ] == "1" .AND. aRezim[ 2 ] == " "
               Soboslikar( { { m_x + 17, m_y + 1, m_x + 20, m_y + 77 } }, 14, 23 )
            ENDIF
         ENDIF

      CASE izbor == 10 .AND. cIdVDTek == "19"
         kalk_oedit()
         SELECT pripr
         GO TOP
         cidfirma := idfirma
         cidvd := idvd
         cbrdok := brdok
         Obraz19()
         SELECT pripr
         GO TOP
         RETURN DE_REFRESH

      CASE izbor == 11
         Iz11u412()

      CASE izbor == 12
         PlusMinusKol()

      CASE izbor == 13
         UzmiTarIzSif()

      CASE izbor == 14
         StornoDok()

      CASE izbor == 15
         DiskMPCSAPP()

      CASE izbor == 16
         IF sifra_za_koristenje_opcije( "SIGMAXXX" )
            IF Pitanje(, "Koristiti dokument u pripremi (D) ili azurirani (N) ?", "N" ) == "D"
               MPCSAPPuSif()
            ELSE
               MPCSAPPiz80uSif()
            ENDIF
         ENDIF

      CASE izbor == 17
         VPCSifUDok()

      CASE izbor == 18
         Iz12u97()     // 11,12 -> 96,97

      CASE izbor == 19
         Iz10u11()

      CASE izbor == 20
         Iz16u14()


      ENDCASE
   ENDDO
   m_x := am_x; m_y := am_y
   kalk_oedit()

   RETURN DE_REFRESH





/*  MeniF11()
 *   Meni ostalih opcija koji se poziva tipkom F11 u tabeli pripreme
 */

FUNCTION MeniF11()

   PRIVATE opc := {}
   PRIVATE opcexe := {}

   AAdd( opc, "1. preuzimanje kalkulacije iz druge firme        " )
   AAdd( opcexe, {|| IzKalk2f() } )
   AAdd( opc, "2. ubacivanje troskova-uvozna kalkulacija" )
   AAdd( opcexe, {|| KalkTrUvoz() } )
   AAdd( opc, "3. pretvori maloprodajni popust u smanjenje MPC" )
   AAdd( opcexe, {|| PopustKaoNivelacijaMP() } )
   AAdd( opc, "4. obracun poreza pri uvozu" )
   AAdd( opcexe, {|| ObracunPorezaUvoz() } )
   AAdd( opc, "5. pregled smeca" )
   AAdd( opcexe, {|| Pripr9View() } )
   AAdd( opc, "6. brisi sve protu-stavke" )
   AAdd( opcexe, {|| ProtStErase() } )
   AAdd( opc, "7. setuj sve NC na 0" )
   AAdd( opcexe, {|| SetNcTo0() } )

   CLOSE ALL
   PRIVATE am_x := m_x, am_y := m_y
   PRIVATE Izbor := 1
   Menu_SC( "osop2" )
   m_x := am_x; m_y := am_y
   kalk_oedit()

   RETURN DE_REFRESH



/*  ProtStErase()
 *   Brisi sve protustavke
 */
FUNCTION ProtStErase()

   IF Pitanje(, "Pobrisati protustavke dokumenta (D/N)?", "N" ) == "N"
      RETURN
   ENDIF

   O_PRIPR
   SELECT pripr
   GO TOP
   DO WHILE !Eof()
      IF "XXX" $ idkonto2
         DELETE
      ENDIF
      SKIP
   ENDDO

   GO TOP

   RETURN



/*  SetNcTo0()
 *   Setuj sve NC na 0
 */
FUNCTION SetNcTo0()

   IF Pitanje(, "Setovati NC na 0 (D/N)?", "N" ) == "N"
      RETURN
   ENDIF

   O_PRIPR
   SELECT pripr
   GO TOP
   DO WHILE !Eof()
      Scatter()
      _nc := 0
      Gather()
      SKIP
   ENDDO

   GO TOP

   RETURN




/*  kalk_edit_pripr(fNovi)
 *   Centralna funkcija za unos/ispravku stavke dokumenta
 */

// ulaz _IdFirma, _IdRoba, ...., nRBr (val(_RBr))
FUNCTION kalk_edit_pripr( fNovi )

   PRIVATE nMarza := 0, nMarza2 := 0, nR
   PRIVATE PicDEM := "9999999.99999999", PicKol := gPicKol

   nStrana := 1

   DO WHILE .T.

      @ m_x + 1, m_y + 1 CLEAR TO m_x + 20, m_y + 77

      SetKey( K_PGDN, {|| NIL } )
      SetKey( K_PGUP, {|| NIL } )

      // konvertovanje valute - ukljuci
      SetKey( K_CTRL_K, {|| a_val_convert() } )

      IF nStrana == 1
         nR := GET1( fnovi )
      ELSEIF nStrana == 2
         nR := GET2( fnovi )
      ENDIF

      SetKey( K_PGDN, NIL )
      SetKey( K_PGUP, NIL )

      // konvertovanje valute - iskljuci
      SetKey( K_CTRL_K, NIL )

      SET ESCAPE ON

      IF nR == K_ESC
         EXIT
      ELSEIF nR == K_PGUP
         --nStrana
      ELSEIF nR == K_PGDN .OR. nR == K_ENTER
         ++nStrana
      ENDIF

      IF nStrana == 0
         nStrana++
      ELSEIF nStrana >= 3
         EXIT
      ENDIF

   ENDDO

   IF LastKey() <> K_ESC
      _Rbr := RedniBroj( nRbr )
      _Dokument := P_TipDok( _IdVD, -2 )
      RETURN 1
   ELSE
      RETURN 0
   ENDIF

   RETURN





/*  Get1()
 *   fnovi
 *   Prva strana/prozor maske unosa/ispravke stavke dokumenta
 */

FUNCTION Get1()

   PARAMETERS fnovi

   PRIVATE pIzgSt := .F.   // izgenerisane stavke postoje
   PRIVATE Getlist := {}

   IF Get1Header() == 0
      RETURN K_ESC
   ENDIF

   IF _idvd == "10"
      IF nRbr == 1
         IF gVarEv == "2" .OR. glEkonomat .OR. Pitanje(, "Skracena varijanta (bez troskova) D/N ?", "N" ) == "D"
            gVarijanta := "1"
         ELSE
            gVarijanta := "2"
         ENDIF
      ENDIF

      RETURN iif( gVarijanta == "1", Get1_10sPDV(), Get1_10PDV() )

   ELSEIF _idvd == "11"
      RETURN GET1_11()
   ELSEIF _idvd == "12"
      RETURN GET1_12()
   ELSEIF _idvd == "13"
      RETURN GET1_12()
   ELSEIF _idvd == "14"  // .or._idvd=="74"
      RETURN Get1_14PDV()

   ELSEIF _idvd == "KO"   // vindija KO

      RETURN GET1_14PDV()

   ELSEIF _idvd == "15"
      IF !IsPDV()
         RETURN GET1_15()
      ENDIF
   ELSEIF _idvd == "16"
      IF IsPDV()
         RETURN GET1_16PDV()
      ELSE
         RETURN GET1_16()
      ENDIF
   ELSEIF _idvd == "18"
      RETURN GET1_18()
   ELSEIF _idvd == "19"
      RETURN GET1_19()
   ELSEIF _idvd $ "41#42#43#47#49"
      RETURN GET1_41()
   ELSEIF _idvd == "81"
      RETURN GET1_81()
   ELSEIF _idvd == "80"
      RETURN GET1_80()
   ELSEIF _idvd == "24"
      IF IsPDV()
         RETURN GET1_24PDV()
      ELSE
         RETURN GET1_24()
      ENDIF
   ELSEIF _idvd $ "95#96#97"
      RETURN GET1_95()

   ELSEIF _idvd $  "94#16"    // storno fakture, storno otpreme, doprema

      RETURN GET1_94()
   ELSEIF _idvd == "82"
      RETURN GET1_82()
   ELSEIF _idvd == "IM"
      RETURN GET1_IM()
   ELSEIF _idvd == "IP"
      RETURN GET1_IP()
   ELSEIF _idvd == "RN"
      RETURN GET1_RN()
   ELSEIF _idvd == "PR"
      RETURN GET1_PR()
   ELSE
      RETURN K_ESC
   ENDIF

   RETURN





/*  Get2()
 *   fnovi
 *   Druga strana/prozor maske unosa/ispravke stavke dokumenta
 */

FUNCTION Get2()

   PARAMETERS fnovi

   IF _idvd $ "10"
      IF IsPDV()
         RETURN Get2_10PDV()
      ELSE
         RETURN Get2_10()
      ENDIF
   ELSEIF _idvd == "81"
      RETURN Get2_81()
   ELSEIF _idvd == "RN"
      RETURN Get2_RN()
   ELSEIF _idvd == "PR"
      RETURN Get2_PR()
   ENDIF

   RETURN K_ESC





/*  Get1Header()
 *   Maska za unos/ispravku podataka zajednickih za sve stavke dokumenta
 */

FUNCTION Get1Header()

   IF fnovi; _idfirma := gFirma; ENDIF
   IF fnovi .AND. _TBankTr == "X"; _TBankTr := "%"; ENDIF  // izgenerisani izlazi


   @  m_x + 1, m_y + 2   SAY "Firma: "
   ?? gFirma, "-", gNFirma


   @  m_x + 2, m_y + 2   SAY "KALKULACIJA: "
   @  m_x + 2, Col()   SAY "Vrsta:" GET _IdVD VALID P_TipDok( @_IdVD, 2, 25 ) PICT "@!"

   read; ESC_RETURN 0

   IF fnovi .AND. gBrojac == "D" .AND. ( _idfirma <> idfirma .OR. _idvd <> idvd )
      IF glBrojacPoKontima .AND. _idVD $ "10#16#18#IM#14#95#96"
         Box( "#Glavni konto", 3, 70 )
         IF _idVD $ "10#16#18#IM"
            @ m_x + 2, m_y + 2 SAY "Magacinski konto zaduzuje" GET _idKonto VALID P_Konto( @_idKonto ) PICT "@!"
            READ
            cSufiks := SufBrKalk( _idKonto )
         ELSE
            @ m_x + 2, m_y + 2 SAY "Magacinski konto razduzuje" GET _idKonto2 VALID P_Konto( @_idKonto2 ) PICT "@!"
            READ
            cSufiks := SufBrKalk( _idKonto2 )
         ENDIF
         BoxC()
         _brDok := SljBrKalk( _idVD, _idFirma, cSufiks )
      ELSE
         _brDok := SljBrKalk( _idVD, _idFirma )
      ENDIF
      SELECT pripr
   ENDIF

   @  m_x + 2, m_y + 40  SAY "Broj:"  GET _BrDok  ;
      valid {|| !P_Kalk( _IdFirma, _IdVD, _BrDok ) }

   @  m_x + 2, Col() + 2 SAY "Datum:"   GET  _DatDok

   @ m_x + 4, m_y + 2  SAY "Redni broj stavke:" GET nRBr PICT '9999' valid {|| CentrTxt( "", 24 ), .T. }
   READ
   ESC_RETURN 0

   RETURN 1





/*  VpcSaPpp()
 *   Vrsi se preracunavanje veleprodajnih cijena ako je _VPC=0
 */

FUNCTION VpcSaPpp()

   IF _VPC == 0
      _RabatV := 0
      _VPC := ( _VPCSAPPP + _NC * tarifa->vpp / 100 ) / ( 1 + tarifa->vpp / 100 + _mpc / 100 )
      nMarza := _VPC - _NC
      _VPCSAP := _VPC + nMarza * TARIFA->VPP / 100
      _PNAP := _VPC * _mpc / 100
      _VPCSAPP := _VPC + _PNAP
   ENDIF
   ShowGets()

   RETURN .T.





/*  RaspTrosk(fSilent)
 *   Rasporedjivanje troskova koji su predvidjeni za raspored. Takodje se koristi za raspored ukupne nabavne vrijednosti na pojedinacne artikle kod npr. unosa pocetnog stanja prodavnice ili magacina
 */

FUNCTION RaspTrosk( fSilent )

   LOCAL nStUc := 20

   IF fsilent == NIL
      fsilent := .F.
   ENDIF
   IF fsilent .OR.  Pitanje(, "Rasporediti troskove ??", "N" ) == "D"
      PRIVATE qqTar := ""
      PRIVATE aUslTar := ""
      IF idvd $ "16#80"
         Box(, 1, 55 )
         IF idvd == "16"
            @ m_x + 1, m_y + 2 SAY "Stopa marze (vpc - stopa*vpc)=nc:" GET nStUc PICT "999.999"
         ELSE
            @ m_x + 1, m_y + 2 SAY "Stopa marze (mpc-stopa*mpcsapp)=nc:" GET nStUc PICT "999.999"
         ENDIF
         READ
         BoxC()
      ENDIF
      GO TOP

      SELECT F_KONCIJ
      IF !Used(); O_KONCIJ; ENDIF
      SELECT koncij
      SEEK Trim( pripr->mkonto )
      SELECT pripr

      IF .T.
         PushWA()
         IF !Empty( qqTar )
            aUslTar := Parsiraj( qqTar, "idTarifa" )
            IF aUslTar <> NIL .AND. !aUslTar == ".t."
               SET FILTER to &aUslTar
            ENDIF
         ENDIF
      ENDIF

      DO WHILE !Eof()
         nUKIzF := 0
         nUkProV := 0
         cIdFirma := idfirma;cIdVD := idvd;cBrDok := Brdok
         nRec := RecNo()
         DO WHILE !Eof() .AND. cidfirma == idfirma .AND. cidvd == idvd .AND. cBrDok == BrDok
            IF cidvd $ "10#16#81#80"    // zaduzenje magacina,prodavnice
               nUkIzF += Round( fcj * ( 1 -Rabat / 100 ) * kolicina, gZaokr )
            ENDIF
            IF cidvd $ "11#12#13"    // magacin-> prodavnica,povrat
               nUkIzF += Round( fcj * kolicina, gZaokr )
            ENDIF
            IF cidvd $ "RN"
               IF Val( Rbr ) < 900
                  nUkProV += Round( vpc * kolicina, gZaokr )
               ELSE
                  nUkIzF += Round( nc * kolicina, gZaokr )  // sirovine
               ENDIF
            ENDIF
            SKIP
         ENDDO
         IF cidvd $ "10#16#81#80#RN"  // zaduzenje magacina,prodavnice
            GO nRec
            RTPrevoz := .F. ; RPrevoz := 0
            RTCarDaz := .F. ;RCarDaz := 0
            RTBankTr := .F. ;RBankTr := 0
            RTSpedTr := .F. ;RSpedTr := 0
            RTZavTr := .F. ;RZavTr := 0
            IF TPrevoz == "R"; RTPrevoz := .T. ;RPrevoz := Prevoz; ENDIF
            IF TCarDaz == "R"; RTCarDaz := .T. ;RCarDaz := CarDaz; ENDIF
            IF TBankTr == "R"; RTBankTr := .T. ;RBankTr := BankTr; ENDIF
            IF TSpedTr == "R"; RTSpedTr := .T. ;RSpedTr := SpedTr; ENDIF
            IF TZavTr == "R"; RTZavTr := .T. ;RZavTr := ZavTr ; ENDIF

            UBankTr := 0   // do sada utrošeno na bank tr itd
            UPrevoz := 0
            UZavTr := 0
            USpedTr := 0
            UCarDaz := 0
            DO WHILE !Eof() .AND. cidfirma == idfirma .AND. cidvd == idvd .AND. cBrDok == BrDok
               Scatter()

               IF _idvd $ "RN" .AND. Val( _rbr ) < 900
                  _fcj := _fcj2 := _vpc / nUKProV * nUkIzF
                  // nabavne cijene izmisli proporcionalno prodajnim
               ENDIF

               IF RTPrevoz    // troskovi 1
                  IF Round( nUkIzF, 4 ) == 0
                     _Prevoz := 0
                  ELSE
                     _Prevoz := Round( _fcj * ( 1 -_Rabat / 100 ) * _kolicina / nUkIzF * RPrevoz, gZaokr )
                     UPrevoz += _Prevoz
                     IF Abs( RPrevoz - UPrevoz ) < 0.1 // sitniš, baci ga na zadnju st.
                        SKIP
                        IF ! ( !Eof() .AND. cidfirma == idfirma .AND. cidvd == idvd .AND. cBrDok == BrDok )
                           _Prevoz += ( RPrevoz - UPrevoz )
                        ENDIF
                        SKIP -1
                     ENDIF
                  ENDIF
                  _TPrevoz := "U"
               ENDIF
               IF RTCarDaz   // troskovi 2
                  IF Round( nUkIzF, 4 ) == 0
                     _CarDaz := 0
                  ELSE
                     _CarDaz := Round( _fcj * ( 1 -_Rabat / 100 ) * _kolicina / nUkIzF * RCarDaz, gZaokr )
                     UCardaz += _Cardaz
                     IF Abs( RCardaz - UCardaz ) < 0.1 // sitniš, baci ga na zadnju st.
                        SKIP
                        IF ! ( !Eof() .AND. cidfirma == idfirma .AND. cidvd == idvd .AND. cBrDok == BrDok )
                           _Cardaz += ( RCardaz - UCardaz )
                        ENDIF
                        SKIP -1
                     ENDIF
                  ENDIF
                  _TCarDaz := "U"
               ENDIF
               IF RTBankTr  // troskovi 3
                  IF Round( nUkIzF, 4 ) == 0
                     _BankTr := 0
                  ELSE
                     _BankTr := Round( _fcj * ( 1 -_Rabat / 100 ) * _kolicina / nUkIzF * RBankTr, gZaokr )
                     UBankTr += _BankTr
                     IF Abs( RBankTr - UBankTr ) < 0.1 // sitno baci ga na zadnju st.
                        SKIP
                        IF ! ( !Eof() .AND. cidfirma == idfirma .AND. cidvd == idvd .AND. cBrDok == BrDok )
                           _BankTr += ( RBankTr - UBankTr )
                        ENDIF
                        SKIP -1
                     ENDIF
                  ENDIF
                  _TBankTr := "U"
               ENDIF
               IF RTSpedTr    // troskovi 4
                  IF Round( nUkIzF, 4 ) == 0
                     _SpedTr := 0
                  ELSE
                     _SpedTr := Round( _fcj * ( 1 -_Rabat / 100 ) * _kolicina / nUkIzF * RSpedTr, gZaokr )
                     USpedTr += _SpedTr
                     IF Abs( RSpedTr - USpedTr ) < 0.1 // sitno baci ga na zadnju st.
                        SKIP
                        IF ! ( !Eof() .AND. cidfirma == idfirma .AND. cidvd == idvd .AND. cBrDok == BrDok )
                           _SpedTr += ( RSpedTr - USpedTr )
                        ENDIF
                        SKIP -1
                     ENDIF
                  ENDIF
                  _TSpedTr := "U"
               ENDIF
               IF RTZavTr    // troskovi
                  IF Round( nUkIzF, 4 ) == 0
                     _ZavTr := 0
                  ELSE
                     _ZavTr := Round( _fcj * ( 1 -_Rabat / 100 ) * _kolicina / nUkIzF * RZavTr, gZaokr )
                     UZavTR += _ZavTR
                     IF Abs( RZavTR - UZavTR ) < 0.1 // sitnio, baci ga na zadnju st.
                        SKIP
                        IF ! ( !Eof() .AND. cidfirma == idfirma .AND. cidvd == idvd .AND. cBrDok == BrDok )
                           _ZavTR += ( RZavTR - UZavTR )
                        ENDIF
                        SKIP -1
                     ENDIF
                  ENDIF
                  _TZavTr := "U"
               ENDIF
               SELECT roba; hseek _idroba
               SELECT tarifa; hseek _idtarifa; SELECT pripr
               IF _idvd == "RN"
                  IF Val( _rbr ) < 900
                     NabCj()
                  ENDIF
               ELSE
                  NabCj()
               ENDIF
               IF _idvd == "16"
                  _nc := _vpc * ( 1 -nStUc / 100 )
               ENDIF
               IF _idvd == "80"
                  _nc := _mpc - _mpcsapp * nStUc / 100
                  _vpc := _nc
                  _TMarza2 := "A"
                  _Marza2 := _mpc - _nc
               ENDIF
               IF koncij->naz == "N1"; _VPC := _NC; ENDIF
               IF _idvd == "RN"
                  IF Val( _rbr ) < 900
                     Marza()
                  ENDIF
               ELSE
                  Marza()
               ENDIF

               Gather()
               SKIP
            ENDDO
         ENDIF // cidvd $ 10
         IF cidvd $ "11#12#13"
            GO nRec
            RTPrevoz := .F. ;RPrevoz := 0
            IF TPrevoz == "R"; RTPrevoz := .T. ;RPrevoz := Prevoz; ENDIF
            nMarza2 := 0
            DO WHILE !Eof() .AND. cidfirma == idfirma .AND. cidvd == idvd .AND. cBrDok == BrDok
               Scatter()
               IF RTPrevoz    // troskovi 1
                  IF Round( nUkIzF, 4 ) == 0
                     _Prevoz := 0
                  ELSE
                     _Prevoz := _fcj / nUkIzF * RPrevoz
                  ENDIF
                  _TPrevoz := "A"
               ENDIF
               _nc := _fcj + _prevoz
               IF koncij->naz == "N1"; _VPC := _NC; ENDIF
               _marza := _VPC - _FCJ
               _TMarza := "A"
               SELECT roba; hseek _idroba
               SELECT tarifa; hseek _idtarifa; SELECT pripr
               Marza2()
               _TMarza2 := "A"
               _Marza2 := nMarza2
               Gather()
               SKIP
            ENDDO
         ENDIF // cidvd $ "11#12#13"
      ENDDO  // eof()

      IF .T.
         SELECT pripr
         PopWA()
      ENDIF

   ENDIF // pitanje
   GO TOP

   RETURN





/*  Savjetnik()
 *   Zamisljeno da se koristi kao pomoc u rjesavanju problema pri unosu dokumenta. Nije razradjeno.
 */

FUNCTION Savjetnik()

   LOCAL nRec := RecNo(), lGreska := .F.

   // pripremne radnje za stampu u fajl
   // ////////////////////////////////////////////////

   MsgO( "Priprema izvjestaja..." )
   SET CONSOLE OFF
   cKom := PRIVPATH + "savjeti.txt"
   SET PRINTER OFF
   SET DEVICE TO PRINTER
   cDDir := Set( _SET_DEFAULT )
   SET DEFAULT TO
   SET PRINTER to ( ckom )
   SET PRINTER ON
   SET( _SET_DEFAULT, cDDir )


   // stampanje izvjestaja
   // ////////////////////////////////////

   SELECT PRIPR
   GO TOP

   DO WHILE !Eof()
      lGreska := .F.
      DO CASE

      CASE idvd == "11"     // magacin->prodavnica
         IF vpc == 0
            OpisStavke( @lGreska )
            ? "PROBLEM: - veleprodajna cijena = 0"
            ? "OPIS:    - niste napravili ulaz u magacin, ili nemate veleprodajnu"
            ? "           cijenu (VPC) u sifrarniku za taj artikal"
         ENDIF

      ENDCASE

      IF Empty( datdok )
         OpisStavke( @lGreska )
         ? "DATUM KALKULACIJE NIJE UNESEN!!!"
      ENDIF

      IF Empty( error )
         OpisStavke( @lGreska )
         ? "STAVKA PRIPADA AUTOMATSKI FORMIRANOM DOKUMENTU !!!"
         ? "Pokrenite opciju <Alt-F10> - asistent ako zelite da program sam prodje"
         ? "kroz sve stavke ili udjite sa <Enter> u ispravku samo ove stavke."
         IF idvd == "11"
            ? "Kada pokrenete <Alt-F10> za ovu kalkulaciju (11), veleprodajna"
            ? "cijena ce biti preuzeta: 1) Ako program omogucava azuriranje"
            ? "sumnjivih dokumenata, VPC ce ostati nepromijenjena; 2) Ako program"
            ? "radi tako da ne omogucava azuriranje sumnjivih dokumenata, VPC ce"
            ? "biti preuzeta iz trenutne kartice artikla. Ako nemate evidentiranih"
            ? "ulaza artikla u magacin, bice preuzeta 0 sto naravno nije korektno."
         ENDIF
      ENDIF

      IF lGreska; ?; ENDIF
      SKIP 1
   ENDDO


   // zavrsetak stampe u fajl i pregled na ekranu
   // ////////////////////////////////////////////////

   SET PRINTER TO
   SET PRINTER OFF
   SET CONSOLE ON
   SET DEVICE TO SCREEN
   SET PRINTER TO
   MsgC()
   SAVE SCREEN TO cS
   VidiFajl( cKom )
   RESTORE SCREEN FROM cS
   SELECT PRIPR
   GO ( nRec )

   RETURN




/*  OpisStavke(lGreska)
 *   Daje informacije o dokumentu i artiklu radi lociranja problema. Koristi je opcija "savjetnik"
 *  \sa Savjetnik()
 */

FUNCTION OpisStavke( lGreska )

   IF !lGreska
      ? "Dokument:    " + idfirma + "-" + idvd + "-" + brdok + ", stavka " + rbr
      ? "Artikal: " + idroba + "-" + Left( Ocitaj( F_ROBA, idroba, "naz" ), 40 )
      lGreska := .T.
   ENDIF

   RETURN





/*  Soboslikar(aNiz,nIzKodaBoja,nUKodBoja)
 *   Mijenja boje dijela ekrana
 */

FUNCTION Soboslikar( aNiz, nIzKodaBoja, nUKodBoja )

   LOCAL i, cEkran

   FOR i := 1 TO Len( aNiz )
      cEkran := SaveScreen( aNiz[ i, 1 ], aNiz[ i, 2 ], aNiz[ i, 3 ], aNiz[ i, 4 ] )
      cEkran := StrTran( cEkran, Chr( nIzKodaBoja ), Chr( nUKodBoja ) )
      RestScreen( aNiz[ i, 1 ], aNiz[ i, 2 ], aNiz[ i, 3 ], aNiz[ i, 4 ], cEkran )
   NEXT

   RETURN



/*
function ZagFirma()

P_12CPI
U_OFF
B_OFF
I_OFF
? "Subjekt:"
U_ON
?? PADC(TRIM(gTS)+" "+TRIM(gNFirma),39)
U_OFF
? "Prodajni objekat:"
U_ON
?? PADC(ALLTRIM(NazProdObj()),30)
U_OFF
? "(poslovnica-poslovna jedinica)"
? "Datum:"
U_ON
?? PADC(SrediDat(DATDOK),18)
U_OFF
?
?
return
*/



/*  NazProdObj()
 *   Daje naziv prodavnickog konta iz pripreme
 */

FUNCTION NazProdObj()

   LOCAL cVrati := ""

   SELECT KONTO
   SEEK PRIPR->pkonto
   cVrati := naz
   SELECT PRIPR

   RETURN cVrati




/*  IzbDokOLPP()
 *   Izbor dokumenta za stampu u formi OLPP-a
 */

FUNCTION IzbDokOLPP()

   O_SIFK
   O_SIFV
   O_ROBA
   O_TARIFA
   O_PARTN
   O_KONTO
   O_PRIPR

   SELECT PRIPR; SET ORDER TO 1; GO TOP

   DO WHILE .T.

      cIdFirma := IdFirma; cBrDok := BrDok; cIdVD := IdVD

      IF Eof();  exit  ; ENDIF

      IF Empty( cidvd + cbrdok + cidfirma ) .OR. ! ( cIdVd $ "11#19#81#80" )
         skip; LOOP
      ENDIF

      Box( "", 2, 50 )
      SET CURSOR ON
      @ m_x + 1, m_y + 2 SAY "Dokument broj:"
      IF gNW $ "DX"
         @ m_x + 1, Col() + 2  SAY cIdFirma
      ELSE
         @ m_x + 1, Col() + 2 GET cIdFirma
      ENDIF
      @ m_x + 1, Col() + 1 SAY "-" GET cIdVD  VALID cIdVd $ "11#19#81#80"  PICT "@!"
      @ m_x + 1, Col() + 1 SAY "-" GET cBrDok
      read; ESC_BCR

      BoxC()

      HSEEK cIdFirma + cIdVD + cBrDok
      EOF CRET

      StOLPP()

   ENDDO

   CLOSERET

   RETURN




/*  PlusMinusKol()
 *   Mijenja predznak kolicini u svim stavkama u pripremi
 */

FUNCTION PlusMinusKol()

   kalk_oedit()
   SELECT PRIPR
   GO TOP
   DO WHILE !Eof()
      Scatter()
      _kolicina := -_kolicina
      _ERROR := " "
      Gather()
      SKIP 1
   ENDDO

   KEYBOARD Chr( K_ESC )
   CLOSERET

   RETURN





/*  UzmiTarIzSif()
 *   Filuje tarifu u svim stavkama u pripremi odgovarajucom sifrom tarife iz sifrarnika robe
 */

FUNCTION UzmiTarIzSif()

   kalk_oedit()
   SELECT PRIPR
   GO TOP
   DO WHILE !Eof()
      Scatter()
      _idtarifa := Ocitaj( F_ROBA, _idroba, "idtarifa" )
      _ERROR := " "
      Gather()
      SKIP 1
   ENDDO
   Msg( "Automatski pokrecem asistenta (Alt+F10)!", 1 )
   lAutoAsist := .T.
   KEYBOARD Chr( K_ESC )
   CLOSERET

   RETURN





/*  DiskMPCSAPP()
 *   Formira diskontnu maloprodajnu cijenu u svim stavkama u pripremi
 */

FUNCTION DiskMPCSAPP()

   aPorezi := {}
   kalk_oedit()
   SELECT PRIPR
   GO TOP
   DO WHILE !Eof()
      SELECT ROBA
      HSEEK PRIPR->idroba
      SELECT TARIFA
      HSEEK ROBA->idtarifa
      Tarifa( pripr->pKonto, pripr->idRoba, @aPorezi )
      SELECT PRIPR
      Scatter()

      _mpcSaPP := MpcSaPor( roba->vpc, aPorezi )

      _ERROR := " "
      Gather()
      SKIP 1
   ENDDO
   Msg( "Automatski pokrecem asistenta (Alt+F10)!", 1 )
   lAutoAsist := .T.
   KEYBOARD Chr( K_ESC )
   CLOSERET

   RETURN




/*  MPCSAPPuSif()
 *   Maloprodajne cijene svih artikala u pripremi kopira u sifrarnik robe
 */

FUNCTION MPCSAPPuSif()

   kalk_oedit()
   SELECT PRIPR
   GO TOP
   DO WHILE !Eof()
      cIdKonto := PRIPR->pkonto
      SELECT KONCIJ; HSEEK cIdKonto
      SELECT PRIPR
      DO WHILE !Eof() .AND. pkonto == cIdKonto
         SELECT ROBA; HSEEK PRIPR->idroba
         IF Found()
            StaviMPCSif( PRIPR->mpcsapp, .F. )
         ENDIF
         SELECT PRIPR
         SKIP 1
      ENDDO
   ENDDO
   CLOSERET

   RETURN




/*  MPCSAPPiz80uSif()
 *   Maloprodajne cijene svih artikala iz izabranog azuriranog dokumenta tipa 80 kopira u sifrarnik robe
 */

FUNCTION MPCSAPPiz80uSif()

   kalk_oedit()

   cIdFirma := gFirma
   cIdVdU   := "80"
   cBrDokU  := Space( Len( PRIPR->brdok ) )

   Box(, 4, 75 )
   @ m_x + 0, m_y + 5 SAY "FORMIRANJE MPC U SIFRARNIKU OD MPCSAPP DOKUMENTA TIPA 80"
   @ m_x + 2, m_y + 2 SAY "Dokument: " + cIdFirma + "-" + cIdVdU + "-"
   @ Row(), Col() GET cBrDokU VALID ImaDok( cIdFirma + cIdVdU + cBrDokU )
   READ; ESC_BCR
   BoxC()

   // pocnimo
   SELECT KALK
   SEEK cIdFirma + cIdVDU + cBrDokU
   cIdKonto := KALK->pkonto
   SELECT KONCIJ; HSEEK cIdKonto
   SELECT KALK
   DO WHILE !Eof() .AND. cIdFirma + cIdVDU + cBrDokU == IDFIRMA + IDVD + BRDOK
      SELECT ROBA; HSEEK KALK->idroba
      IF Found()
         StaviMPCSif( KALK->mpcsapp, .F. )
      ENDIF
      SELECT KALK
      SKIP 1
   ENDDO

   CLOSERET

   RETURN





/*  VPCSifUDok()
 *   Filuje VPC u svim stavkama u pripremi odgovarajucom VPC iz sifrarnika robe
 */

FUNCTION VPCSifUDok()

   kalk_oedit()
   SELECT PRIPR
   GO TOP
   DO WHILE !Eof()
      SELECT ROBA; HSEEK PRIPR->idroba
      SELECT KONCIJ; SEEK Trim( PRIPR->mkonto )
      // SELECT TARIFA; HSEEK ROBA->idtarifa
      SELECT PRIPR
      Scatter()
      _vpc := KoncijVPC()
      _ERROR := " "
      Gather()
      SKIP 1
   ENDDO
   Msg( "Automatski pokrecem asistenta (Alt+F10)!", 1 )
   lAutoAsist := .T.
   KEYBOARD Chr( K_ESC )
   CLOSERET

   RETURN




/*  StKalk()
 *   fstara
 *   cSeek
 *   Centralna funkcija za stampu KALK dokumenta. Poziva odgovarajucu funkciju za stampu dokumenta u zavisnosti od tipa dokumenta i podesenja parametara varijante izgleda dokumenta
 */

FUNCTION StKalk()

   PARAMETERS fstara, cSeek, lAuto
   LOCAL nCol1
   LOCAL nCol2
   LOCAL nPom

   nCol1 := 0
   nCol2 := 0
   nPom := 0

   PRIVATE PicCDEM := gPICCDEM
   PRIVATE PicProc := gPICPROC
   PRIVATE PicDEM := gPICDEM
   PRIVATE Pickol := gPICKOL

   PRIVATE nStr := 0
   O_KONCIJ
   O_ROBA
   O_TARIFA
   O_PARTN
   O_KONTO
   O_TDOK

   IF ( PCount() == 0 )
      fstara := .F.
   ENDIF
   IF ( fStara == nil )
      fStara := .F.
   ENDIF

   IF ( lAuto == nil )
      lAuto := .F.
   ENDIF

   IF ( cSeek == nil )
      cSeek := ""
   ENDIF

   IF fstara
#ifdef CAX
      SELECT ( F_PRIPR )
      USE
#endif
      O_SKALK   // alias pripr
   ELSE
      O_PRIPR
   ENDIF

   SELECT PRIPR
   SET ORDER TO 1
   GO TOP

   fTopsD := .F.
   fFaktD := .F.

   DO WHILE .T.

      cIdFirma := IdFirma
      cBrDok := BrDok
      cIdVD := IdVD

      IF Eof()
         EXIT
      ENDIF

      IF Empty( cidvd + cbrdok + cidfirma )
         SKIP
         LOOP
      ENDIF

      IF !lAuto

         IF ( cSeek == "" )
            Box( "", 1, 50 )
            SET CURSOR ON
            @ m_x + 1, m_y + 2 SAY "Dokument broj:"
            IF ( gNW $ "DX" )
               @ m_x + 1, Col() + 2  SAY cIdFirma
            ELSE
               @ m_x + 1, Col() + 2 GET cIdFirma
            ENDIF
            @ m_x + 1, Col() + 1 SAY "-" GET cIdVD  PICT "@!"
            @ m_x + 1, Col() + 1 SAY "-" GET cBrDok
            READ
            ESC_BCR
            BoxC()
         ENDIF

      ENDIF

      IF ( !Empty( cSeek ) .AND. cSeek != 'IZDOKS' )
         HSEEK cSeek
         cidfirma := SubStr( cSeek, 1, 2 )
         cIdvd := SubStr( cSeek, 3, 2 )
         cBrDok := PadR( SubStr( cSeek, 5, 8 ), 8 )
      ELSE
         HSEEK cIdFirma + cIdVD + cBrDok
      ENDIF

      IF ( cidvd == "24" )
         Msg( "Kalkulacija 24 ima samo izvjestaj rekapitulacije !" )
         closeret
      ENDIF

      IF ( cSeek != 'IZDOKS' )
         EOF CRET
      ELSE
         PRIVATE nStr := 1
      ENDIF

      START PRINT CRET
      ?

      DO WHILE .T.

         IF ( cidvd == "10" .AND. !( ( gVarEv == "2" ) .OR. ( gmagacin == "1" ) ) .OR. ( cidvd $ "11#12#13" ) ) .AND. ( c10Var == "3" )
            gPSOld := gPStranica
            gPStranica := Val( IzFmkIni( "KALK", "A3_GPSTRANICA", "-20", EXEPATH ) )
            P_PO_L
         ENDIF

         IF ( cSeek == 'IZDOKS' )  // stampaj sve odjednom !!!
            IF ( PRow() > 42 )
               ++nStr
               FF
            ENDIF
            SELECT pripr
            cIdfirma := doks->idfirma
            cIdvd := doks->idvd
            cBrdok := doks->brdok
            hseek cIdFirma + cIdVD + cBrDok
         ENDIF

         Preduzece()

         IF ( cidvd == "10" .OR. cidvd == "70" ) .AND. !IsPDV()
            IF ( gVarEv == "2" )
               StKalk10_sk()
            ELSEIF ( gMagacin == "1" )
               // samo po nabavnim
               StKalk10_1()
            ELSE
               IF ( c10Var == "1" )
                  StKalk10_2()
               ELSEIF ( c10Var == "2" )
                  StKalk10_3()
               ELSE
                  StKalk10_4()
               ENDIF
            ENDIF
         ELSEIF cIdVD == "10" .AND. IsPDV()
            IF ( gMagacin == "1" )
               // samo po nabavnim
               StKalk10_1()
            ELSE
               // PDV ulazna kalkulacija
               StKalk10_PDV()
            ENDIF
         ELSEIF cidvd $ "15"
            IF !IsPDV()
               StKalk15()
            ENDIF
         ELSEIF ( cidvd $ "11#12#13" )
            IF ( c10Var == "3" )
               StKalk11_3()
            ELSE
               IF ( gmagacin == "1" )
                  StKalk11_1()
               ELSE
                  StKalk11_2()
               ENDIF
            ENDIF
         ELSEIF ( cidvd $ "14#94#74#KO" )
            IF ( c10Var == "3" )
               Stkalk14_3()
            ELSE
               IF IsPDV()
                  StKalk14PDV()
               ELSE
                  Stkalk14()
               ENDIF
            ENDIF
         ELSEIF ( cidvd $ "16#95#96#97" ) .AND. IsPDV()
            IF gPDVMagNab == "D"
               StKalk95_1()
            ELSE
               StKalk95_PDV()
            ENDIF
         ELSEIF ( cidvd $ "95#96#97#16" ) .AND. !IsPDV()
            IF ( gVarEv == "2" )
               Stkalk95_sk()
            ELSEIF ( gmagacin == "1" )
               Stkalk95_1()
            ELSE
               Stkalk95()
            ENDIF
         ELSEIF ( cidvd $ "41#42#43#47#49" )   // realizacija prodavnice
            IF ( IsJerry() .AND. cIdVd $ "41#42#47" )
               StKalk47J()
            ELSE
               StKalk41()
            ENDIF
         ELSEIF ( cidvd == "18" )
            StKalk18()
         ELSEIF ( cidvd == "19" )
            IF IsJerry()
               StKalk19J()
            ELSE
               StKalk19()
            ENDIF
         ELSEIF ( cidvd == "80" )
            StKalk80()
         ELSEIF ( cidvd == "81" )
            IF IsJerry()
               StKalk81J()
            ELSE
               IF ( c10Var == "1" )
                  StKalk81()
               ELSE
                  StKalk81_2()
               ENDIF
            ENDIF
         ELSEIF ( cidvd == "82" )
            StKalk82()
         ELSEIF ( cidvd == "IM" )
            StKalkIm()
         ELSEIF ( cidvd == "IP" )
            StKalkIp()
         ELSEIF ( cidvd == "RN" )
            IF !fStara
               RaspTrosk( .T. )
            ENDIF
            StkalkRN()
         ELSEIF ( cidvd == "PR" )
            StkalkPR()
         ENDIF

         IF ( cSeek != 'IZDOKS' )
            EXIT
         ELSE
            SELECT doks
            SKIP
            IF Eof()
               EXIT
            ENDIF
            ?
            ?
         ENDIF

         IF ( cidvd == "10" .AND. !( ( gVarEv == "2" ) .OR. ( gmagacin == "1" ) ) .OR. ( cidvd $ "11#12#13" ) ) .AND. ( c10Var == "3" )
            gPStranica := gPSOld
            P_PO_P
         ENDIF

      ENDDO // cSEEK

      IF ( gPotpis == "D" )
         IF ( PRow() > 57 + gPStranica )
            FF
            @ PRow(), 125 SAY "Str:" + Str( ++nStr, 3 )
         ENDIF
         ?
         ?
         P_12CPI
         @ PRow() + 1, 47 SAY "Obrada AOP  "; ?? Replicate( "_", 20 )
         @ PRow() + 1, 47 SAY "Komercijala "; ?? Replicate( "_", 20 )
         @ PRow() + 1, 47 SAY "Likvidatura "; ?? Replicate( "_", 20 )
      ENDIF

      ?
      ?

      FF
      ENDPRINT

      IF ( cidvd $ "80#11#81#12#13#IP#19" )
         fTopsD := .T.
      ENDIF

      IF ( cidvd $ "10#11#81" )
         fFaktD := .T.
      ENDIF

      IF ( !Empty( cSeek ) )
         EXIT
      ENDIF

   ENDDO  // vrti kroz kalkulacije

   IF ( fTopsD .AND. !fstara .AND. gTops != "0 " )
      start PRINT cret
      SELECT PRIPR
      SET ORDER TO 1
      GO TOP
      cIdFirma := IdFirma
      cBrDok := BrDok
      cIdVD := IdVD
      IF ( cIdVd $ "11#12" )
         StKalk11_2( .T. )  // maksuzija za tops - bez NC
      ELSEIF ( cIdVd == "80" )
         Stkalk80( .T. )
      ELSEIF ( cIdVd == "81" )
         Stkalk81( .T. )
      ELSEIF ( cIdVd == "IP" )
         StkalkIP( .T. )
      ELSEIF ( cIdVd == "19" )
         Stkalk19()
      ENDIF
      CLOSE ALL
      FF
      ENDPRINT

      GenTops()
   ENDIF

   IF ( fFaktD .AND. !fstara .AND. gFakt != "0 " )
      start PRINT cret
      kalk_oedit()
      SELECT PRIPR
      SET ORDER TO 1
      GO TOP
      cIdFirma := IdFirma
      cBrDok := BrDok
      cIdVD := IdVD
      IF ( cIdVd $ "11#12" )
         StKalk11_2( .T. )  // maksuzija za tops - bez NC
      ELSEIF ( cIdVd == "10" )
         StKalk10_3( .T. )
      ELSEIF ( cIdVd == "81" )
         StKalk81( .T. )
      ENDIF
      CLOSE ALL
      FF
      ENDPRINT

      kalk_prenos_modem( .T. )
   ENDIF

#ifdef CAX
   IF fstara
      SELECT pripr
      USE
   ENDIF
#endif
   closeret

   RETURN NIL




/*  PopustKaoNivelacijaMP()
 *   Umjesto iskazanog popusta odradjuje smanjenje MPC
 */

FUNCTION PopustKaoNivelacijaMP()

   LOCAL lImaPromjena

   lImaPromjena := .F.
   kalk_oedit()
   SELECT pripr
   GO TOP
   DO WHILE !Eof()
      IF ( !idvd = "4" .OR. rabatv == 0 )
         SKIP 1
         LOOP
      ENDIF
      lImaPromjena := .T.
      Scatter()
      _mpcsapp := Round( _mpcsapp - _rabatv, 2 )
      _rabatv := 0
      PRIVATE aPorezi := {}
      PRIVATE fNovi := .F.
      VRoba( .F. )
      WMpc( .T. )
      _error := " "
      SELECT pripr
      Gather()
      SKIP 1
   ENDDO
   IF lImaPromjena
      Msg( "Izvrsio promjene!", 1 )
      // lAutoAsist:=.t.
      KEYBOARD Chr( K_ESC )
   ELSE
      MsgBeep( "Nisam nasao nijednu stavku sa maloprodajnim popustom!" )
   ENDIF
   CLOSERET

   RETURN




/*  StOLPPAz()
 *   Funkcija za stampu OLPP-a za azurirani KALK dokument
 */

FUNCTION StOLPPAz()

   LOCAL nCol1
   LOCAL nCol2
   LOCAL nPom

   nCol1 := 0
   nCol2 := 0
   nPom := 0

   PRIVATE PicCDEM := gPICCDEM
   PRIVATE PicProc := gPICPROC
   PRIVATE PicDEM := gPICDEM
   PRIVATE Pickol := gPICKOL

   PRIVATE nStr := 0

   O_KONCIJ
   O_ROBA
   O_TARIFA
   O_PARTN
   O_KONTO
   O_TDOK

#ifdef CAX
   SELECT ( F_PRIPR )
   USE
#endif
   O_SKALK   // alias pripr

   SELECT PRIPR
   SET ORDER TO 1
   GO TOP

   DO WHILE .T.

      cIdFirma := IdFirma
      cBrDok := BrDok
      cIdVD := IdVD

      IF Eof()
         EXIT
      ENDIF

      IF Empty( cIdVd + cBrDok + cIdFirma )
         SKIP
         LOOP
      ENDIF

      Box( "", 2, 50 )
      SET CURSOR ON
      @ m_x + 1, m_y + 2 SAY "Dokument broj:"
      IF ( gNW $ "DX" )
         @ m_x + 1, Col() + 2  SAY cIdFirma
      ELSE
         @ m_x + 1, Col() + 2 GET cIdFirma
      ENDIF
      @ m_x + 1, Col() + 1 SAY "-" GET cIdVD  VALID cIdVd $ "11#19#80#81" PICT "@!"
      @ m_x + 1, Col() + 1 SAY "-" GET cBrDok
      @ m_x + 2, m_y + 2 SAY "(moguce vrste KALK dok.su: 11,19,80,81)"
      READ
      ESC_BCR
      BoxC()

      HSEEK cIdFirma + cIdVD + cBrDok

      EOF CRET

      StOlpp()


   ENDDO  // vrti kroz kalkulacije

   closeret

   RETURN NIL
