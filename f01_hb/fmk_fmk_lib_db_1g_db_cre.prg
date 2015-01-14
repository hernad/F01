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

FUNCTION CreKorisn( nArea )

   LOCAL cImeDBF

   IF nArea == nil
      nArea := -1
   ENDIF

   IF ( nArea == -1 .OR. nArea == F_KORISN )

      cImeDBF := ToUnix( modul_dir() + "KORISN.dbf" )

      IF !File2( cImeDBF )
         aDbf := {}
         AAdd( aDbf, { "ime", "C", 10, 0 } )
         AAdd( aDbf, { "sif", "C", 6, 0 } )
         AAdd( aDbf, { "dat", "D", 8, 0 } )
         AAdd( aDbf, { "time", "C", 8, 0 } )
         AAdd( aDbf, { "prov", "N", 4, 0 } )  // brojac neispravnih pokusaja ulaza
         AAdd( aDbf, { "nk", "L", 1, 0 } )
         AAdd( aDbf, { "level", "C", 1, 0 } )
         AAdd( aDbf, { "DirRad", "C", 40, 0 } )
         AAdd( aDbf, { "DirSif", "C", 40, 0 } )
         AAdd( aDbf, { "DirPriv", "C", 40, 0 } )
         DBCREATE2( cImeDBF, aDbf )
         USE ( cImeDBF )

         APPEND BLANK
         REPLACE ime WITH "SYSTEM",  ;               // SYSTEM
            sif WITH CryptSC( "SYSTEM" ),  ;
            dat WITH  Date(),  ;
            time WITH Time(),  ;
            prov WITH 0,  ;
            level WITH "0",  ;
            nk WITH .F.,  ;
            level WITH "0",  ;
            DirRad  WITH             '*',;
            DirSif  WITH             '*',;
            DirPriv WITH             '*'
         USE
      ENDIF


      f01_create_index( "IME", "ime", ToUnix( "." + SLASH + "korisn.dbf" ), .T. )
   ENDIF

   RETURN


/*  CreSystemDb()
 *   Kreiraj sistemske tabele (gparams, params, adres, ...)
 */
FUNCTION CreSystemDb( nArea )

   LOCAL lShowMsg

   lShowMsg := .F.

   IF ( nArea == nil )
      nArea := -1

      IF goModul:oDatabase:lAdmin
         lShowMsg := .T.
      ENDIF

   ENDIF

   IF lShowMsg
      MsgO( "Kreiram systemske tabele" )
   ENDIF
   CreGParam( nArea )
   CreParams( nArea )
   CreAdres( nArea )
   IF lShowMsg
      MsgC()
   ENDIF

   RETURN


FUNCTION CreParams( nArea )

   LOCAL cParams := ToUnix( PRIVPATH + "PARAMS.DBF" )
   LOCAL cGParams := ToUnix( PRIVPATH + "GPARAMS.DBF" )
   LOCAL cMParams := ToUnix( modul_dir() + "MPARAMS.DBF" )
   LOCAL cKParams := ToUnix( KUMPATH + "KPARAMS.DBF" )

   CLOSE ALL

   IF gReadOnly
      RETURN
   ENDIF

   IF ( nArea == nil )
      nArea := -1
   ENDIF

   aDbf := {}
   AAdd( aDbf, { "FH", "C", 1, 0 } )  // istorija
   AAdd( aDbf, { "FSec", "C", 1, 0 } )
   AAdd( aDbf, { "FVar", "C", 2, 0 } )
   AAdd( aDbf, { "Rbr", "C", 1, 0 } )
   AAdd( aDbf, { "Tip", "C", 1, 0 } ) // tip varijable
   AAdd( aDbf, { "Fv", "C", 15, 0 }  ) // sadrzaj

   IF ( nArea == -1 .OR. nArea == F_PARAMS )

      IF !File2( cParams )
         DBCREATE2( cParams,aDbf )
      ENDIF
      f01_create_index( "ID", "fsec+fh+fvar+rbr", cParams, .T. )

   ENDIF



   IF ( nArea == -1 .OR. nArea == F_GPARAMS )
      IF !File2( cGParams )
         DBCREATE2( cGParams, aDbf )
      ENDIF
      f01_create_index( "ID", "fsec+fh+fvar+rbr", cGParams, .T. )
   ENDIF

   IF ( nArea == -1 .OR. nArea == F_MPARAMS )
      IF !File2( ToUnix( cMParams ) )
         DBCREATE2( cMParams, aDbf )
      ENDIF
      f01_create_index( "ID", "fsec+fh+fvar+rbr", cMParams, .T. )
   ENDIF

   IF ( nArea == -1 .OR. nArea == F_KPARAMS )
      IF !File2( cKParams )
         DBCREATE2 ( cKParams, aDbf )
      ENDIF
      f01_create_index( "ID", "fsec+fh+fvar+rbr", cKParams, .T. )
   ENDIF


   aDbf := {}
   AAdd( aDbf, { "FH", "C", 1, 0 } )  // istorija
   AAdd( aDbf, { "FSec", "C", 1, 0 } )
   AAdd( aDbf, { "FVar", "C", 15, 0 } )
   AAdd( aDbf, { "Rbr", "C", 1, 0 } )
   AAdd( aDbf, { "Tip", "C", 1, 0 } ) // tip varijable
   AAdd( aDbf, { "Fv", "C", 15, 0 }  ) // sadrzaj


   IF ( nArea == -1 .OR. nArea == F_SECUR )
      cImeDBf := ToUnix( KUMPATH + "secur.dbf" )
      IF !File2( cImeDBF )
         DBCREATE2( cImeDBF, aDbf )
      ENDIF
      f01_create_index( "ID", "fsec+fh+fvar+rbr", cImeDBF, .T. )
   ENDIF

   RETURN NIL



FUNCTION CreAdres( nArea )

   IF ( nArea == nil )
      nArea := -1
   ENDIF

   IF ( nArea == -1 .OR. nArea == F_KPARAMS )
      IF !File2( ToUnix( SIFPATH + "ADRES.DBF" ) )
         aDBF := {}
         AAdd( aDBf, { 'ID', 'C',  50,   0 } )
         AAdd( aDBf, { 'RJ', 'C',  30,   0 } )
         AAdd( aDBf, { 'KONTAKT', 'C',  30,   0 } )
         AAdd( aDBf, { 'NAZ', 'C',  15,   0 } )
         AAdd( aDBf, { 'TEL2', 'C',  15,   0 } )
         AAdd( aDBf, { 'TEL3', 'C',  15,   0 } )
         AAdd( aDBf, { 'MJESTO', 'C',  15,   0 } )
         AAdd( aDBf, { 'PTT', 'C',  6,   0 } )
         AAdd( aDBf, { 'ADRESA', 'C',  50,   0 } )
         AAdd( aDBf, { 'DRZAVA', 'C',  22,   0 } )
         AAdd( aDBf, { 'ziror', 'C',  30,   0 } )
         AAdd( aDBf, { 'zirod', 'C',  30,   0 } )
         AAdd( aDBf, { 'K7', 'C',  1,   0 } )
         AAdd( aDBf, { 'K8', 'C',  2,   0 } )
         AAdd( aDBf, { 'K9', 'C',  3,   0 } )
         DBCREATE2( SIFPATH + "ADRES.DBF", aDBf )
      ENDIF
      f01_create_index( "ID", "id+naz", SIFPATH + "ADRES.DBF" )
   ENDIF

   RETURN


FUNCTION CreGparam( nArea )

   LOCAL aDbf

   IF ( nArea == nil )
      nArea := -1
   ENDIF
   CLOSE ALL

   aDbf := {}
   AAdd( aDbf, { "FH", "C", 1, 0 } )  // istorija
   AAdd( aDbf, { "FSec", "C", 1, 0 } )
   AAdd( aDbf, { "FVar", "C", 2, 0 } )
   AAdd( aDbf, { "Rbr", "C", 1, 0 } )
   AAdd( aDbf, { "Tip", "C", 1, 0 } ) // tip varijable
   AAdd( aDbf, { "Fv", "C", 15, 0 }  ) // sadrzaj

   IF ( nArea == -1 .OR. nArea == F_GPARAMS )

      cImeDBf := ToUnix( DATA_ROOT + "GPARAMS.DBF" )
      IF !File2( cImeDbf )
         DBCREATE2( cImeDbf, aDbf )
      ENDIF
      f01_create_index( "ID", "fsec+fh+fvar+rbr", cImeDBF )

   ENDIF

   RETURN



FUNCTION KonvParams( cImeDBF )

   cImeDBF := ToUnix( cImeDBF )
   CLOSE  ALL
   IF File( cImeDBF ) // ako postoji
      USE ( cImeDbf )
      IF FieldPos( "VAR" ) <> 0  // stara varijanta parametara
         SAVE SCREEN TO cScr
         cls
         f01_modstru( cImeDbf, "C H C 1 0  FH  C 1 0", .T. )
         f01_modstru( cImeDbf, "C SEC C 1 0  FSEC C 1 0", .T. )
         f01_modstru( cImeDbf, "C VAR C 2 0 FVAR C 2 0", .T. )
         f01_modstru( cImeDbf, "C  V C 15 0  FV C 15 0", .T. )
         f01_modstru( cImeDbf, "A BRISANO C 1 0", .T. )  // dodaj polje "BRISANO"
         Inkey( 2 )
         RESTORE SCREEN FROM cScr
      ENDIF
   ENDIF
   CLOSE ALL

   RETURN


FUNCTION DBCREATE2( cIme, aDbf, cDriver )

   LOCAL nPos
   LOCAL cCDX

   cIme := ToUnix( cIme )
   nPos := AScan( aDbf,  {| x| x[ 1 ] == "BRISANO" } )
   IF nPos == 0
      AAdd( aDBf, { 'BRISANO', 'C',  1,  0 } )
   ENDIF

   IF Right( cIme, 4 ) <> "." + DBFEXT
      cIme := cIme + "." + DBFEXT
   ENDIF

   cCDX := StrTran( cIme, "." + DBFEXT, "." + INDEXEXT )
   IF Right( cCDX, 4 ) = "." + INDEXEXT
      FErase( cCDX )
   ENDIF

   dbCreate( cIme, aDbf, cDriver )

   RETURN


FUNCTION AddOidFields( aDbf )

   AAdd( aDbf, { "_OID_", "N", 12, 0 } )
   AAdd( aDbf, { "_SITE_", "N", 2, 0 } )
   AAdd( aDbf, { "_DATAZ_", "D", 8, 0 } )
   AAdd( aDbf, { "_TIMEAZ_", "C", 8, 0 } )
   AAdd( aDbf, { "_COMMIT_", "C", 1, 0 } )
   AAdd( aDbf, { "_USER_", "N", 3, 0 } )

   RETURN
