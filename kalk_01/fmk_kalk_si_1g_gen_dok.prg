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

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 *
 */


/* file fmk/kalk/si/1g/gen_dok.prg
 *   Generacija dokumenata sitnog inventara
 */

/*  Otpis16SI()
 *   Otpis 16 sitnog inventara. Kada je izvrsena doprema SI 16kom, napraviti novu 16ku na konto troskovnog mjesta otpisanog SI.
 */
 
function Otpis16SI()

O_KONCIJ
O_PRIPR
O_PRIPR2
O_KALK
O_SIFK
O_SIFV
O_ROBA

select pripr; go top
private cIdFirma:=idfirma,cIdVD:=idvd,cBrDok:=brdok
if !(cidvd $ "16") .or. "-X"$cBrDok .or. Pitanje(,"Formirati dokument radi evidentiranja otpisanog dijela? (D/N)","N")=="N"
  close all
  return .f.
endif

cBrUlaz := PADR( TRIM(PRIPR->brdok)+"-X" , 8 )

select pripr
go top
private nRBr:=0
do while !eof() .and. cidfirma==idfirma .and. cidvd==idvd .and. cbrdok==brdok
  scatter()
  select pripr2
   append blank
    _brdok:=cBrUlaz
    _idkonto:="X-"+TRIM(pripr->idkonto)
    _MKonto:=_idkonto
    _TBankTr:="X"    // izgenerisani dokument
     gather()
  select pripr
  skip
enddo

close all
RETURN .t.


