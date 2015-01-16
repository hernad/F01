INIT PROCEDURE f01_init()

  OutStd( "init f01" )
  OutStd( hb_eol() )

/*
  connect_to_f01_server()

  OutStd( netio_funcexec( "DATE" ) )
  OutStd( hb_eol() )
  OutStd( netio_funcexec( "TIME" ) )
  OutStd( hb_eol() )
  OutStd( netio_funcexec( "HB_DATETIME" ) )
  OutStd( hb_eol() )

  OutStd( netio_procexists( "SRV_ADD" ) )
  OutStd( hb_eol() )
  OutStd( netio_funcexec( "SRV_ADD", 1, 2 ) )
  OutStd( hb_eol() )

  OutStd( netio_procexists( "HELLO_NETIO" ) )
  OutStd( hb_eol() )
  OutStd( netio_funcexec( "HELLO_NETIO" ) )
  OutStd( hb_eol() )
*/

  RETURN
