

#xcommand O_KORISN    => select (F_KORISN);  use (ToUnix( modul_dir() + "KORISN")); set order to tag "IME"
#xcommand O_PARAMS    => select (F_PARAMS);  use (ToUnix(PRIVPATH+"PARAMS")) ; set order to tag  "ID"
#xcommand O_GPARAMS   => select (F_GPARAMS); use ( ToUnix(DATA_ROOT + "GPARAMS") ) ;   set order to tag  "ID"
#xcommand O_GPARAMSP  => select (F_GPARAMSP); use (ToUnix(PRIVPATH+"GPARAMS")) ; set order to tag  "ID"
#xcommand O_MPARAMS   => select (F_MPARAMS); use (ToUnix(modul_dir() + "MPARAMS"))  ; set order  to tag  "ID"
#xcommand O_KPARAMS   => select (F_KPARAMS); use (ToUnix(KUMPATH + "KPARAMS")); set order to tag  "ID"
#xcommand O_SECUR     => select (F_SECUR); use (ToUnix(KUMPATH + "secur")) ; set order to tag "ID"

#xcommand O_SQLPAR    => select (F_SQLPAR); use (ToUnix(KUMPATH+"SQL" + SLASH + "SQLPAR"))


#xcommand O_SIFK => select(F_SIFK);  use  (ToUnix(SIFPATH+"SIFK"))    ; set order to tag "ID"
#xcommand O_SIFV => select(F_SIFV);  use  (ToUnix(SIFPATH+"SIFV"))    ; set order to tag "ID"

// PROIZVOLJNI IZVJESTAJI
#xcommand O_KONIZ  => select (F_KONIZ);    use  (ToUnix(KUMPATH+"KONIZ")); set order to tag "ID"
#xcommand O_IZVJE  => select (F_IZVJE);    use  (ToUnix(KUMPATH+"IZVJE")); set order to tag "ID"
#xcommand O_ZAGLI  => select (F_ZAGLI);    use  (ToUnix(KUMPATH+"ZAGLI")); set order to tag "ID"
#xcommand O_KOLIZ  => select (F_KOLIZ);    use  (ToUnix(KUMPATH+"KOLIZ")); set order to tag "ID"
