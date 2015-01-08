
PROCEDURE MainX( ... )


  //f18_init_harbour()

  f01_init_harbour()

  main_thread( hb_threadSelf() )
  ? "- F01 start -"

  create_main_window()

  ? "- F01 new window -"

  MainFin( ... )

  RETURN
