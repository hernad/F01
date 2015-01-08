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
#include "fileio.ch"

/*
 * ----------------------------------------------------------------
 *                          Copyright Sigma-com software 1994-2006
 * ----------------------------------------------------------------
 */


// File cache buffer
*string
static cCache
*;

// Name of the .INI file that is in the cache buffer
*string
static cIniFile
*;

//#include "COMMON.CH"

static INI_DATA := {}
static INI_NAME := ''
static INI_SECTION := 'xx'


function R_IniRead ( cSection, cEntry, cDefault, cFName, lAppend )

local	nHandle
local	cString
local	nPos
local	nEnd
local	aEntries := {}
local   lPom0, lPom

if lAppend==NIL
	lAppend:=.f.
endif


// Extension omitted : Add default extension
if ( At ( '.', cFName ) == 0 )
   cFName -= '.INI'
endif

if ( cIniFile == NIL )
   // First time ... (buffer not in cache)
   cIniFile := ''
endif

// Check the filename
if ( cIniFile != cFName )
   // Other .INI file name : file not in cache !

   if ( nHandle := FOpen ( cFName, FO_READ + FO_SHARED ) ) < 5
      // Error opening .INI file
      return nil
   endif

   // INI file opened ...

   // Read complete file into cCache
   ReadFile(nHandle)

   // File not needed anymore ...
   FClose(nHandle)

   // File in cache ...
   cIniFile := cFName

endif

lPom0:= SeekSection(cSection, @nPos)
if lPom0

   // Section FOUND, nPos points to the start of the section
   if cEntry = NIL
      // return ALL ENTRIES IN SECTION !

      // nPos points to start of section

      // Skip [section] + NRED
      nPos = nPos + 4 + Len ( cSection )

      // nPos points to start of first entry
      DO WHILE nPos <= Len ( cCache ) .and. SubStr ( cCache, nPos, 1 ) != '['

         nEnd    := I_At ( '=', .f., nPos )
         cEntry  := SubStr ( cCache, nPos, nEnd - nPos )
         nPos    := nEnd + 1
         nEnd    := I_At ( NRED, .f., nPos )
         cString := SubStr ( cCache, nPos, nEnd - nPos )
         AAdd ( aEntries, { cEntry, cString } )
         nPos    := nEnd + 2

         DO WHILE SubStr(cCache, nPos, 2) = NRED
            // Skip NRED's, if any
            nPos += 2
         ENDDO

      ENDDO

      return aEntries

   else
      // Locate specified entry
      nPos := I_At(Upper(cEntry)+'=', .t., nPos )

      if ( nPos > 0 )
         // Entry found, nPos points to start of entry

         // Skip 'entry=' part
         nPos += Len ( cEntry )

         // Return value
         return SubStr ( cCache, nPos+1, ;
            I_At ( NRED, .f., nPos+1 ) - nPos - 1 )

      endif

   endif

else
   // Section not found
   if ( VALTYPE(cEntry) != "C" )
      // Request to return all entries in section ...
      return NIL
   endif
endif


if (lAppend)
   // CREATE A NEW cDEFAULT ENTRY, if THE SPECIFIED ENTRY NOT EXISTS
   R_IniWrite ( cSection, cEntry, cDefault, cIniFile )
endif


// Return default value

IniRefresh()
return cDefault



/*  R_IniWrite ( cSection, cEntry, cString, cFName )
 *
 *  cSection - String that specifies the section to which the string will  be copied. If the section does not exist, it is created. cSection is case-independent
 *  cEntry - String containing the entry to be associated with the string. If the entry does not exist in the specified section, it is created. If the parameter is NIL, the entire section, including all entries within the section, is deleted.
 *  cString - String to be written to the file. If this parameter is NIL, the entry specified by the cEntry parameter is deleted.
 *  cFName  - String that names the initialization file
 *
 * \sa R_IniWrite
 *
 */

function R_IniWrite( cSection, cEntry, cString, cFName )

local	nHandle
local	nBytes
local	nPos
local	nEntry

if (cFName==NIL) .or. Valtype ( cFName ) != 'C'
   // Required parameter !
   return .f.
endif

if (cSection==NIL) .or. Valtype ( cSection ) != 'C'
   // Required paramter !
   return .f.
endif

// Append default extension (if no extension present)
if At ( '.', cFName ) = 0
   cFName -= '.INI'
endif

if cIniFile = NIL
   // First time ...
   cIniFile := ''
endif

// Check the filename
if (cIniFile != cFName)
   // If file name is the SAME : file is still in Cache buffer (cCache) ...

   // Other .INI file or the first time
   if (nHandle:=FOPEN(cFName, FO_READWRITE + FO_SHARED)) < 5
      // Error opening .INI file

      if (nHandle:=FCreate(cFName, FC_NORMAL)) < 5
         // Error creating .INI file
	IniRefresh()
         return .f.

      else
         // .INI file created : Write Section and Entry
         PutSection( nHandle, cSection )

         PutEntry ( nHandle, cEntry, cString )

         // ReRead file to adjust cCache cache

	 ReadFile(nHandle)
         FClose(nHandle)

         // Buffer in cache ...
         cIniFile := cFName

	IniRefresh()
         return .t.

      endif

   endif

   // Read complete file into cCache
   //Logg("Ini fajl name:" + cFName)
   ReadFile(nHandle)

   // Buffer in cache ...
   cIniFile := cFName

endif

nPos:=0

lPom:=SeekSection( cSection, @nPos)
if !lPom
   // Section NOT present : append SECTION AND ENTRY !
   if (nHandle==NIL)
      // File not presently open
      nHandle := FOpen ( cFName, FO_READWRITE + FO_SHARED )
   endif

   // Pointer to end-of-file
   FSeek(nHandle, 0, FS_END)

   // APPEND NEW SECTION (separated with an empty line)
   FWrite (nHandle, NRED, 2)
   PutSection (nHandle, cSection)

   PutEntry(nHandle, cEntry, cString)

   // ReRead file to adjust cCache ....
   ReadFile(nHandle)

else
   // SECTION ALREADY PRESENT
   // nPos points to the start of the section

   if cEntry==NIL

      // DELETE COMPLETE SECTION !
      // nPos points to start of section
      if ( nEntry := I_At ( '[', .f., nPos + 1 ) ) = 0
         // No next section : delete to end-of-file
         nEntry := Len ( cCache ) + 1
      endif

      // Delete bytes from string
      cCache:=Stuff(cCache, nPos, nEntry - nPos, '')
      ReWrite(nHandle,cFName)
	IniRefresh()
      return .t.

   endif

   // Skip section + NRED
   nPos = nPos + 4 + Len ( cSection )

   if ( nEntry := I_At ( Upper ( cEntry ) + '=', .t., nPos ) ) = 0

      // ENTRY NOT FOUND : APPEND ENTRY
      if cString != NIL
         // Locate start of next SECTION
         if nHandle = NIL
            nHandle := FOpen ( cFName, FO_READWRITE + FO_SHARED )
         endif

         if ( nEntry := I_At ( '[', .f., nPos ) ) = 0

            // Last section : append to end of file
            FSEEK ( nHandle, 0, FS_END )

            PutEntry ( nHandle, cEntry, cString )

            // ReRead file to adjust cCache
            ReadFile( nHandle )

         else
            //-- Next section present at : nEntry - 2

            //-- INSERT ENTRY AT END OF SECTION
            DO WHILE SubStr ( cCache, nEntry-2, 2 ) = NRED
               //-- Skip NRED's, if any ...
               nEntry -= 2
            ENDDO

            //-- Keep 1 NRED string ...
            nEntry += 2

            cCache:=Stuff(cCache, nEntry, 0, cEntry + '=' + cString + NRED)

            ReWrite(nHandle, cFName)

		IniRefresh()
            return .t.

         endif

      endif

   else
      //-- ENTRY FOUND : REPLACE VALUE

      if (cString == NIL)
         //-- DELETE ENTRY !

         // nEntry points to first pos of entry name
         nPos := I_At(NRED, .f., nEntry ) + 2

         // Delete bytes from string
         cCache := Stuff ( cCache, nEntry, nPos - nEntry, '' )
      else
         // REPLACE VALUE

         // nEntry points to first pos of entry name

         nEntry  := nEntry + Len ( cEntry ) + 1
         cCache := Stuff ( cCache, nEntry, ;
            At ( NRED, SubStr ( cCache, nEntry ) ) - 1, cString )

      endif

      ReWrite ( nHandle, cFName )
	IniRefresh()

      return .t.

   endif

endif
FClose ( nHandle )

IniRefresh()
return .t.



/*  I_At(cSearch, cString, nStart)
 *   nStart - pocni pretragu od nStart pozicije
 */
static function I_At(cSearch, lUpper, nStart)

local nPos
if lUpper
	nPos := At( cSearch, SubStr(UPPER(cCache), nStart) )
else
	nPos := At( cSearch, SubStr(cCache, nStart) )
endif
return if ( nPos > 0, nPos + nStart - 1, 0 )



/*  IzFmkIni(cSection, cVar, cValue, cLokacija )
 *
 *   cSection  - [SECTION]
 *   cVar      - Variable
 *   cValue    - Default value of Variable
 *   cLokacija - Default = EXEPATH, or PRIVPATH, or SIFPATH or KUMPATH (FileName='FMK.INI')
 *   lAppend   - True - ako zapisa u ini-ju nema dodaj ga, default false

 * // uzmi vrijednost varijable Debug, sekcija Gateway, iz EXEPATH/FMK.INI
 * cDN:=IzFmkIni("Gateway","Debug","N",EXEPATH)
 */

function IzFmkIni(cSection, cVar, cValue, cLokacija, lAppend)

local cRez := ""
local cNazIni:='FMK.INI'

if (cLokacija == NIL)
	cLokacija := EXEPATH
endif

if (lAppend==nil)
	lAppend:=.f.
endif

if !File2(cLokacija+cNazIni)
  nFH := FCreate(cLokacija+cNazIni)
  FWrite(nFh,";------- Ini Fajl FMK-------")
  Fclose(nFH)
endif

cRez := R_IniRead( cSection, cVar,  "", cLokacija + cNazIni)

if (lAppend .and. EMPTY(cRez))
	// nije toga bilo u fmk.ini
  	R_IniWrite(cSection, cVar, cValue, cLokacija + cNazIni)
	IniRefresh()
  	return cValue
elseif (EMPTY(cRez))
	IniRefresh()
	return cValue
else
	IniRefresh()
	return cRez
endif

return



function TEMPINI(cSection, cVar, cValue, cread)

*
* cValue  - tekuca vrijednost
* cREAD = "WRITE" , "READ"

local cRez:=""
local cNazIni:=EXEPATH+'TEMP.INI'

if cread==NIL
 read:="READ"
endif


if !File2(EXEPATH+'TEMP.INI')
  nFH:=FCreate(EXEPATH+'TEMP.INI')
  FWrite(nFh,";------- Ini Fajl TMP-------")
  Fclose(nFH)
endif

cRez:=R_IniRead ( cSection, cVar,  "", cNazIni)

if empty(cRez) .or. cRead=="WRITE"  // nije toga bilo u fmk.ini
  R_IniWrite(cSection,cVar,cValue, cNazIni)
  return cValue
else
  return cRez
endif

return



function IniRefresh()


cCache:=""
cIniFile:=""


return



function UzmiIzINI(cNazIni,cSection, cVar, cValue, cread)

local cRez:=""

if cread==NIL
 read:="READ"
endif

if !File2(cNazIni)
  nFH:=FCreate(cNazIni)
  FWrite(nFh,";------- Ini Fajl "+cNazIni+"-------")
  Fclose(nFH)
endif

cRez:=R_IniRead ( cSection, cVar,  "", cNazIni)

if empty(cRez) .or. cRead=="WRITE"
  if valtype(cValue) = "N"
    R_IniWrite(cSection,cVar,str(cValue,22,2), cNazIni)
  else
    R_IniWrite(cSection,cVar,cValue, cNazIni)
  endif
  return cValue
else
  return cRez
endif
return



static function SeekSection( sect, pos )
// Look for the specified section in buffer

pos:= At ('['+Upper (sect)+']', Upper (cCache) )

return pos>0



static function ReadFile( hnd)


cCache:=Space( FSeek ( hnd, 0, FS_END ) )
FSeek ( hnd, 0, FS_SET )
FRead ( hnd, @cCache, Len(cCache) )

return


static function PutSection(hnd, sect)

if !EMPTY( sect )
  return FWrite ( hnd, '[' + sect + ']' + NRED )
else
  return nil
endif
return



static function PutEntry( hnd,entry,val )

if !Empty ( entry ) .and. !Empty ( val )
 return FWrite ( hnd, entry + '=' + val + NRED )
else
 return nil
endif


// Rewrite complete file from buffer
static function ReWrite(hnd,fnm)

if ( hnd!=NIL )
   FClose(hnd)
endif
hnd := FCreate ( fnm, FC_NORMAL )
FWrite ( hnd, cCache )
FClose ( hnd )
return
