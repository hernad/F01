/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f01.ch"

FUNCTION kalk_novi_broj( cIdFirma, cIdVd, cIdKonto, nUvecaj )

   LOCAL cSufiks


   IF glBrojacPoKontima

/*
    Box( "#FAKT->KALK", 3, 70 )
      @ m_x + 2, m_y + 2 SAY "Konto razduzuje" GET cIdKonto PICT "@!" VALID P_Konto( @cIdKonto )
      READ
    BoxC()
*/
      cSufiks := SufBrKalk( cIdKonto )
      cBrKalk := SljBrKalk( cIdVd , cIdFirma, cSufiks, nUvecaj )

   ELSE

      cBrKalk := GetNextKalkDoc( cIdFirma, cIdVd, nUvecaj )
   ENDIF

   RETURN cBrKalk
