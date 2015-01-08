#include "f01.ch"

STATIC s_lVrstePlacanja := NIL

FUNCTION is_use_vrste_placanja()

  IF s_lVrstePlacanja == NIL
     s_lVrstePlacanja :=  IzFmkIni("FAKT","VrstePlacanja","N",SIFPATH)=="D"
  ENDIF

  RETURN s_lVrstePlacanja
