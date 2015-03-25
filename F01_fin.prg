
PROCEDURE Main( ... )


  gModul := "FIN"

  //f18_init_harbour()

  f01_init_harbour()

  connect_to_f01_server()
  main_thread( hb_threadSelf() )
  ? "- F01 start -"

  create_main_window()

  ? "- F01 new window -"

  MainFin( ... )

  RETURN
