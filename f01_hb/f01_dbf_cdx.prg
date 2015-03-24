#include "f01.ch"

/*  ImdDBFCDX(cIme)
*   Mjenja DBF u indeksnu extenziju

*  suban     -> suban.CDX
*  suban.DBF -> suban.CDX

*/

FUNCTION f01_ime_dbf_cdx( cIme )

   cIme := Trim( StrTran( f01_transform_dbf_name( cIme ), "." + DBFEXT, "." + INDEXEXT ) )
   IF Right( cIme, 4 ) <> "." + INDEXEXT
      cIme := cIme + "." + INDEXEXT
   ENDIF

   RETURN  cIme
