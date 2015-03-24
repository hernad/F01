#include "f01.ch"


FUNCTION f01_reindex( ff )

   // REINDEXiranje DBF-ova

   LOCAL nDbf
   LOCAL lZakljucana

   IF ( ff <> NIL .AND. ff == .T. ) .OR. if( !gAppSrv,  Pitanje( "", "Reindeksirati DB (D/N)", "N" ) == "D", .T. )

      IF !gAppSrv
         Box( "xx", 1, 56, .F., "Vrsi se reindeksiranje DB-a " )
      ELSE
         ? "Vrsi se reindex tabela..."
      ENDIF

      // Provjeri da li je sezona zakljucana
      lZakljucana := .F.

      IF gReadOnly
         lZakljucana := .T.
         // otkljucaj sezonu
         SetWOnly( .T. )
      ENDIF
      //

      CLOSE ALL

      // CDX verzija
      SET EXCLUSIVE ON
      FOR nDbf := 1 TO 250
         IF !gAppSrv
            @ m_x + 1, m_y + 2 SAY Space( 54 )
         ENDIF
#ifndef PROBA
         bErr := ErrorBlock( {| o| MyErrHt( o ) } )
         BEGIN SEQUENCE
            // sprijeciti ispadanje kad je neko vec otvorio bazu
            goModul:oDatabase:obaza( nDbf )
         RECOVER
            Beep( 2 )
            IF !gAppSrv
               @ m_x + 1, m_y + 2 SAY "Ne mogu administrirati " + DbfName( nDbf ) + " / " + AllTrim( Str( nDbf ) )
            ELSE
               ? "Ne mogu administrirati: " + DBFName( nDbf ) + " / " + AllTrim( Str( nDBF ) )
            ENDIF

            IF !Empty( DBFName( nDbf ) )
               // ovaj modul "zna" za ovu tabelu, ali postoji problem
               Inkey( 3 )
            ENDIF
         END SEQUENCE
         bErr := ErrorBlock( bErr )
#else
         goModul:oDatabase:obaza( nDbf )
         IF !gAppSrv
            @ m_x + 1, m_y + 2  SAY Space( 40 )
         ENDIF
#endif

         dbSelectArea ( nDbf )
         IF !gAppSrv
            @ m_x + 1, m_y + 2 SAY "Reindeksiram: " + Alias( nDBF )
         ELSE
            ? "Reindexiram: " + Alias( nDBF )
         ENDIF

         IF Used()
            beep( 1 )
            ordSetFocus( 0 )
            nSlogova := 0
            REINDEX
            // EVAL { || Every() } EVERY 150
            USE
         ENDIF

      NEXT
      SET EXCLUSIVE OFF
      IF !gAppSrv
         BoxC()
      ENDIF
   ENDIF

   IF lZakljucana == .T.
      SetROnly( .T. )
   ENDIF

   closeret

   RETURN NIL



FUNCTION Pakuj( ff )

   LOCAL nDbfff, cDN

   IF ( ff <> NIL .AND. ff == .T. ) .OR. ( cDN := Pitanje( "pp", "Prepakovati bazu (D/N/L)", "N" ) ) $ "DL"


      Box( "xx", 1, 50, .F., "Fizicko brisanje zapisa iz baze koji su markirani za brisanje" )
      @ m_x + 1, m_y + 1 SAY "Pakuje se DB:"


      CLOSE ALL

      SET EXCLUSIVE ON
      FOR nDbfff := 1 TO 250
         goModul:oDatabase:obaza( nDbfff )
         IF Used()
            @ m_x + 1, m_y + 30 SAY Space( 12 )
            @ m_x + 1, m_y + 30 SAY Alias()
            SET DELETED OFF
            nOrder := ordNumber( "BRISAN" )

            // bezuslovno trazi deleted()
            IF cDN == "L"
               LOCATE FOR Deleted()
            ELSE
               IF norder <> 0
                  SET ORDER TO TAG "BRISAN"

                  // nadji izbrisan zapis
                  SEEK "1"
               ENDIF
            ENDIF
            IF nOrder = 0 .OR. Found()
               BEEP( 1 )
               ordSetFocus( 0 )
               @ m_x + 1, m_y + 36 SAY RecCount() PICT "999999"
               __dbPack()
               @ m_x + 1, m_y + 42 SAY "+"
               @ m_x + 1, m_y + 44 SAY RecCount() PICT "99999"
               SET DELETED ON
            ELSE
               @ m_x + 1, m_y + 36 SAY Space( 4 )
               @ m_x + 1, m_y + 42 SAY "-"
               @ m_x + 1, m_y + 44 SAY Space( 4 )
            ENDIF
            Inkey( 0.4 )


            SET DELETED ON
            USE
         ENDIF // used
      NEXT
      BoxC()

   ENDIF

   closeret

   RETURN



FUNCTION f01_brisi_index_pakuj_dbf( fSilent )

   IF fSilent == nil
      fSilent := .F.
   ENDIF

#ifdef proba
   IF !gAppSrv
      Msgbeep( "Brisipak procedura..." )
   ENDIF
#endif

   IF fSilent .OR. if( !gAppSrv, Pitanje(, "Izbrisati " + INDEXEXT + " fajlove pa ih nanovo kreirati", "N" ) == "D", .T. )
      CLOSE ALL
      cMask := "*." + INDEXEXT
      IF !gAppSrv
         cScr := ""
         SAVE SCREEN TO cScr
         cls
         IF fSilent .OR. pitanje(, "Indeksi iz privatnog direktorija ?", "D" ) == "D"
            DelSve( cMask, Trim( cDirPriv ) )
            Inkey( 1 )
         ENDIF
         IF fSilent .OR.  pitanje(, "Indeksi iz direktorija kumulativa ?", "N" ) == "D"
            DelSve( cMask, Trim( cDirRad ) )
            Inkey( 1 )
         ENDIF
         IF fSilent .OR.  pitanje(, "Indeksi iz direktorija sifrarnika ?", "N" ) == "D"
            DelSve( cMask, Trim( cDirSif ) )
            Inkey( 1 )
         ENDIF
         IF fSilent .OR.  pitanje(, "Indeksi iz tekuceg direktorija?", "N" ) == "D"
            DelSve( cMask, "." )
            Inkey( 1 )
         ENDIF
         IF fSilent .OR. pitanje(, "Indeksi iz korjenog direktorija?", "N" ) == "D"
            DelSve( cMask, SLASH )
            Inkey( 1 )
         ENDIF
      ELSE
         ? "Brisem sve indexe..."
         ? "Radni dir: " + Trim( cDirRad )
         DelSve( cMask, Trim( cDirRad ) )
         DelSve( cMask, Trim( cDirSif ) )
         DelSve( cMask, Trim( cDirPriv ) )
      ENDIF
      IF !gAppSrv
         RESTORE SCREEN FROM cScr
      ENDIF
      f01_cre_params()
      CLOSE ALL
      IF gAppSrv
         ? "Kreiram sve indexe ...."
         ? "Radni dir: " + cDirRad
      ENDIF
      goModul:oDatabase:kreiraj()
      IF gAppSrv
         ? "Kreirao index-e...."
      ENDIF
   ENDIF

   RETURN




FUNCTION f01_prepakuj( aNStru )

   LOCAL i, aPom

   aPom := {}
   FOR i := 1 TO Len( aNStru )
      IF aNStru[ i ] <> nil
         AAdd( aPom, aNStru[ i ] )
      ENDIF
   NEXT
   aNStru := AClone( aPom )

   RETURN NIL
