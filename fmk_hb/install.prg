STATIC s_lInstall := .F.


FUNCTION is_install( xVal )

  IF xVal != NIL
     s_lInstall := xVal
  ENDIF

  return s_lInstall
