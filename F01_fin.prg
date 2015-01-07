
PROCEDURE MainX( ... )

  altd()
  ? "hello"
  inkey(0)

  //f18_init_harbour()

  main_thread( hb_threadSelf() )
  ? "- F01 start -"
  create_main_window()

  ? "hello 2"
  inkey(0)


  MainFin( ... )

  RETURN
