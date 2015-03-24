

#xcommand O_KORISN    => select (F_KORISN);  use (f01_transform_dbf_name( modul_dir() + "KORISN")); set order to tag "IME"
#xcommand O_PARAMS    => select (F_PARAMS);  use (f01_transform_dbf_name(PRIVPATH+"PARAMS")) ; set order to tag  "ID"
#xcommand O_GPARAMS   => f01_use_gparams()
#xcommand O_GPARAMSP  => select (F_GPARAMSP); use (f01_transform_dbf_name(PRIVPATH+"GPARAMS")) ; set order to tag  "ID"
#xcommand O_MPARAMS   => select (F_MPARAMS); use (f01_transform_dbf_name(modul_dir() + "MPARAMS"))  ; set order  to tag  "ID"
#xcommand O_KPARAMS   => select (F_KPARAMS); use (f01_transform_dbf_name(KUMPATH + "KPARAMS")); set order to tag  "ID"
#xcommand O_SECUR     => select (F_SECUR); use (f01_transform_dbf_name(KUMPATH + "secur")) ; set order to tag "ID"

#xcommand O_SQLPAR    => select (F_SQLPAR); use (f01_transform_dbf_name(KUMPATH+"SQL" + SLASH + "SQLPAR"))


#xcommand O_SIFK => select(F_SIFK);  use  (f01_transform_dbf_name(SIFPATH+"SIFK"))    ; set order to tag "ID"
#xcommand O_SIFV => select(F_SIFV);  use  (f01_transform_dbf_name(SIFPATH+"SIFV"))    ; set order to tag "ID"

// PROIZVOLJNI IZVJESTAJI
#xcommand O_KONIZ  => select (F_KONIZ);    use  (f01_transform_dbf_name(KUMPATH+"KONIZ")); set order to tag "ID"
#xcommand O_IZVJE  => select (F_IZVJE);    use  (f01_transform_dbf_name(KUMPATH+"IZVJE")); set order to tag "ID"
#xcommand O_ZAGLI  => select (F_ZAGLI);    use  (f01_transform_dbf_name(KUMPATH+"ZAGLI")); set order to tag "ID"
#xcommand O_KOLIZ  => select (F_KOLIZ);    use  (f01_transform_dbf_name(KUMPATH+"KOLIZ")); set order to tag "ID"
