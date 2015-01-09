#include "f01.ch"

#include "fileio.ch"

static OID_ASK:="0"

static nSlogova:=0

/*
*   fDa - True -> Batch obrada (neinteraktivno)
*/

function f01_runmods(fDa)


if fda==nil
fda:=.f.
endif

cImeCHS:=EXEPATH+gModul+".CHS"

if fda .or. PitMstru(@cImeCHS)
cScr:=""
save screen to cScr
cEXT:=SLASH+"*."+INDEXEXT
cls
if fda .or. Pitanje(,"Modifikacija u Priv dir ?","D")=="D"
close all
f01_modstru(TRIM(cImeCHS),trim(goModul:oDataBase:cDirPriv))
endif

if fda .or. Pitanje(,"Modifikacija u SIF dir ?","N")=="D"
close all
f01_modstru(TRIM(cImeCHS),trim(goModul:oDataBase:cDirSif))
endif

if fda .or. Pitanje(,"Modifikacija u KUM dir ?","N")=="D"
close all
f01_modstru(TRIM(cImeCHS),trim(goModul:oDataBase:cDirKum))
endif

if fda .or. Pitanje(,"Modifikacija u tekucem dir ?","N")=="D"
close all
f01_modstru(TRIM(cImeCHS),".")
endif

Beep(1)
restore screen from cScr
close all
goModul:oDatabase:kreiraj()
Reindex(.t.)
endif

return


static function PitMstru(cImeChs)

local cDN:="N"

cImeChs:=padr(cImeChs,200)

Box(,3,50)
@ m_x+1,m_y+2 SAY "Izvrsiti modifikaciju struktura D/N" GET cDN pict "@!" valid cdn $ "DN"
read
if cDN=="D"
@ m_x+3,m_y+2 SAY "CHS Skript:" GET cImeCHS PICT "@S30"
read
cImeCHS:=trim(cImeChs)
endif
BoxC()
if cdn=="D"
return .t.
else
return .f.
endif



/*  f01_modstru(cImeF, cPath, fString)
*   procedura modifikacija struktura
*/
function f01_modStru( cImeF, cPath, fString )


? SPACE(40),"bring.out, 10.99, ver 02.33 CDX"
? SPACE(40),"-------------------------------"
?
set deleted on  // ne kopiraj izbrisane zapise
close all

cmxAutoOpen(.f.)  // ne otvaraj CDX-ove

if pcount()==0
?
? "Sintaksa:   MODSTRU  <ImeKomandnog_fajla>  <direktorij_sa_DBF_fajlovima>"
? "     npr:   MODSTRU  ver0155.chs    C:/EM/FIN/1"
?
quit
endif

if fstring == nil
fString=.f.
endif

if cPath==nil
cPath:=""
endif

if !fString

if RIGHT(cPath,1)<>SLASH
cPath:=cPath+SLASH
endif

nH:=FOPEN(ToUnix(cImeF))
if nH==-1
nH:=FOPEN(".."+SLASH+cImeF)
endif

else
if right(cImeF,4)<>"."+DBFEXT
cImeF:=cImeF+"."+DBFEXT
endif
cKomanda:=cPath
cPath:=""
endif

nLinija:=0
cDBF:=""

private fBrisiDBF:=.f.
private fRenameDBF:=.f.

fprom:=.f.
nProlaza:=0

do while fString .or. !FEOF(nH)
++nLinija
if fString
if nProlaza=0
cLin:="*"+cImeF
nProlaza++
elseif nProlaza=1
cLin:=cKomanda
nProlaza++
else
exit
endif
else
cLin:=FReadLN( nH, 1, 200)
cLin:=left(cLin,len(cLin)-2)
endif

if empty(cLin) .or.  left(cLin,1)==";"
loop
endif

if left(cLin,1)="*"
kopi(fProm)
cLin:=substr(cLin,2,len(trim(clin))-1)
cDbf:=alltrim(cLin)
? cPath+cDbf
cDbf:=UPPER(cDbf+iif(at(".",cDbf)<>0,"",".DBF"))
if file(cPath+cDbf)
select 1
USE_EXCLUSIVE(cPath+cDbf) alias olddbf
else
cDbf:="*"
?? "  Ne nalazi se u direktorijumu"
endif
fProm:=.f.   // flag za postojanje promjena u strukturi dbf-a
aStru:=DBSTRUCT()
aNStru:=aclone(aStru)      // nova struktura
else  // funkcije za promjenu polja
if empty(cDBF)
? "Nije zadat DBF fajl nad kojim se vrsi modifikacija strukture !"
quit
elseif cDbf=="*"
loop // preskoci
endif

cOp:=Rjec(@cLin)

if alltrim(cOp)=="IZBRISIDBF"
fBrisiDbf:=.t.
elseif alltrim(cOp)=="IMEDBF"
fRenameDBF:=.t.
cImeP:=Rjec(@cLin)
elseif alltrim(cOp)=="A"
cImeP:=Rjec(@cLin)
cTip:=Rjec(@cLin)
cLen:=Rjec(@cLin); nLen:=VAL(cLen)
cDec:=Rjec(@cLin); nDec:=VAL(cDec)
if !(nLen>0 .and. nLen>nDec) .or. (cTip="C" .and. nDec>0) .or. !(cTip $ "CNDM")
? "Greska: Dodavanje polja, linija:",nLinija
loop
endif
nPos=ascan(aStru,{|x| x[1]==cImep})
if npos<>0
? "Greska: Polje "+cImeP+" vec postoji u DBF-u, linija:",nlinija
loop
endif
? "Dodajem polje:",cImeP,cTip,nLen,nDec
AADD(aNStru,{cImeP,cTip,nLen,nDec})
fProm:=.t.

elseif alltrim(cOp)=="D"
cImeP:=upper(Rjec(@cLin))
nPos:=ASCAN(aNStru,{|x| x[1]==cImeP})
if nPos<>0
? "Brisem polje:",cImeP
ADEL(aNStru,nPos)
Prepakuj(@aNstru)  // prepakuj array
fProm:=.t.
else
? "Greska: Brisanje nepostojeceg polja, linija:",nLinija
endif

elseif alltrim(cOp)=="C"
cImeP1:=upper(Rjec(@cLin))
cTip1:=Rjec(@cLin)
cLen:=Rjec(@cLin); nLen1:=VAL(cLen)
cDec:=Rjec(@cLin); nDec1:=VAL(cDec)
nPos:=ASCAN(aStru,{|x| x[1]==cImeP1 .and. x[2]==cTip1 .and. x[3]==nLen1 .and. x[4]==nDec1})
if nPos==0
? "Greska: zadana je promjena nepostojeceg polja, linija:",nLinija
loop
endif
cImeP2:=upper(Rjec(@cLin))
cTip2:=Rjec(@cLin)
cLen:=Rjec(@cLin); nLen2:=VAL(cLen)
cDec:=Rjec(@cLin); nDec2:=VAL(cDec)

nPos2:=ASCAN(aStru,{|x| x[1]==cImep2})
if nPos2<>0 .and. cImeP1<>cImeP2
? "Greska: zadana je promjena u postojece polje, linija:",nLinija
loop
endif
fIspr:=.f.
if cTip1==cTip2
fispr:=.t.
endif
if (cTip1=="N" .and. cTip2=="C")   ;  fispr:=.t.; endif
if (cTip1=="C" .and. cTip2=="N")   ;  fispr:=.t.; endif
if (cTip1=="C" .and. cTip2=="D")   ;  fispr:=.t.; endif
if !fispr; ? "Greska: Neispravna konverzija, linija:",nLinija; loop; endif

AADD(aStru[nPos],cImeP2)
AADD(aStru[nPos],cTip2)
AADD(aStru[nPos],nLen2)
AADD(aStru[nPos],nDec2)

nPos:=ASCAN(aNStru,{|x| x[1]==cImeP1 .and. x[2]==cTip1 .and. x[3]==nLen1 .and. x[4]==nDec1})
aNStru[nPos]:={ cImeP2, cTip2, nLen2, nDec2}

? "Vrsim promjenu:",cImep1,cTip1,nLen1,nDec1," -> ",cImep2,cTip2,nLen2,nDec2
// npr {"POLJE1", "C", 10, 0} =>
//     {"POLJE1", "C", 10, 0,"POLJE1NEW", "C", "15", 0}

fProm:=.t.
else
? "Greska: Nepostojeca operacija, linija:",nLinija
endif
endif // fje za promjenu polja

enddo
kopi(fProm)

cmxAutoOpen(.t.)
return
