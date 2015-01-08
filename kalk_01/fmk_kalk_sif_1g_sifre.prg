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

FUNCTION kalk_Sifre_meni()

   PRIVATE PicDem

   PicDem := gPICDem
   CLOSE ALL

   PRIVATE opc := {}
   PRIVATE opcexe := {}
   AAdd( opc, "1. opci sifrarnici                  " )
   IF ( ImaPravoPristupa( goModul:oDataBase:cName, "SIF", "OPCISIFOPEN" ) )
      AAdd( opcexe, {|| SifFmkSvi() } )
   ELSE
      AAdd( opcexe, {|| MsgBeep( cZabrana ) } )
   ENDIF
   AAdd( opc, "2. robno-materijalno poslovanje" )
   IF ( ImaPravoPristupa( goModul:oDataBase:cName, "SIF", "ROBMATSIFOPEN" ) )
      AAdd( opcexe, {|| SifFmkRoba() } )
   ELSE
      AAdd( opcexe, {|| MsgBeep( cZabrana ) } )
   ENDIF

   AAdd( opc, "3. magacinski i prodajni objekti" )
   IF ( ImaPravoPristupa( goModul:oDataBase:cName, "SIF", "PRODOBJSIFOPEN" ) )
      AAdd( opcexe, {|| P_Objekti() } )
   ELSE
      AAdd( opcexe, {|| MsgBeep( cZabrana ) } )
   ENDIF

   IF IsPlanika()
      AAdd( opc, "P. planika" )
      IF ( ImaPravoPristupa( goModul:oDataBase:cName, "SIF", "PLSIFOPEN" ) )
         AAdd( opcexe, {|| KaSifPlanika() } )
      ELSE
         AAdd( opcexe, {|| MsgBeep( cZabrana ) } )
      ENDIF
   ENDIF
   PRIVATE Izbor := 1
   Menu_SC( "msif" )
   CLOSERET

   RETURN .F.




/*  kalk_serv_fun()
 *   Servisne funkcije
 */

FUNCTION kalk_serv_fun()

   Msg( "Nije u upotrebi" )
   closeret

   RETURN



/*  RobaBlock(Ch)
 *   Obrada funkcija nad sifrarnikom robe
 *   Ch - Pritisnuti taster
 */

FUNCTION RobaBlock( Ch )

   LOCAL cSif := ROBA->id, cSif2 := ""

   IF Ch == K_CTRL_T .AND. gSKSif == "D"

      // provjerimo da li je sifra dupla
      PushWA()
      SET ORDER TO TAG "ID"
      SEEK cSif
      SKIP 1
      cSif2 := ROBA->id
      PopWA()
      IF !( cSif == cSif2 )
         // ako nije dupla provjerimo da li postoji u kumulativu
         IF ImaUKumul( cSif, "7" )
            Beep( 1 )
            Msg( "Stavka se ne moze brisati jer se vec nalazi u dokumentima!" )
            RETURN 7
         ENDIF
      ENDIF

   ELSEIF Ch == K_ALT_M
      RETURN  MpcIzVpc()

   ELSEIF Ch == K_F2 .AND. gSKSif == "D"
      IF ImaUKumul( cSif, "7" )
         RETURN 99
      ENDIF

   ELSEIF Ch == K_F8  // cjenovnik

      PushWa()
      nRet := CjenR()
      OSifBaze()
      SELECT ROBA
      PopWA()
      RETURN nRet

   ELSEIF Upper( Chr( Ch ) ) == "O"
      IF roba->( FieldPos( "strings" ) ) == 0
         RETURN 6
      ENDIF
      TB:Stabilize()
      PushWa()
      m_strings( roba->strings, roba->id )
      SELECT roba
      PopWa()
      RETURN 7

   ELSEIF Upper( Chr( Ch ) ) == "S"

      TB:Stabilize()  // problem sa "S" - exlusive, htc
      PushWa()
      KalkStanje( roba->id )
      PopWa()
      RETURN 6  // DE_CONT2

   ENDIF

   RETURN DE_CONT



FUNCTION FSvaki2()

   RETURN




/*  OSifBaze()
 *   Otvara sve tabele vezane za sifrarnike
 */

FUNCTION OSifBaze()

   O_SIFK
   O_SIFV
   O_KONTO
   O_KONCIJ
   O_PARTN
   O_TNAL
   O_TDOK
   O_TRFP
   O_TRMP
   O_VALUTE
   O_TARIFA
   O_ROBA
   O_SAST

   RETURN




FUNCTION P_K1()

   LOCAL nTArea
   PRIVATE ImeKol
   PRIVATE Kol

   ImeKol := {}
   Kol := {}

   nTArea := Select()
   O_K1

   AAdd( ImeKol, { "ID", {|| id }, "id" } )
   add_mcode( @ImeKol )
   AAdd( ImeKol, { "Naziv", {|| naz }, "naz" } )

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   SELECT ( nTArea )
   PostojiSifra( F_K1, I_ID, 10, 60, "Lista - K1" )

   RETURN


FUNCTION P_Objekti()

   LOCAL nTArea
   PRIVATE ImeKol
   PRIVATE Kol

   ImeKol := {}
   Kol := {}

   nTArea := Select()
   O_OBJEKTI

   AAdd( ImeKol, { "ID", {|| id }, "id" } )
   add_mcode( @ImeKol )
   AAdd( ImeKol, { "Naziv", {|| naz }, "naz" } )
   AAdd( ImeKol, { "IdObj", {|| idobj }, "idobj" } )

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   SELECT ( nTArea )
   PostojiSifra( F_OBJEKTI, 1, 10, 60, "Objekti" )

   RETURN
