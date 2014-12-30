#!/bin/bash

rm *.prg~
rm */*.prg~

if [ "$1" == log_errors ] ; then

  hbmk2 F01.hbp 2> errors.txt

else
  hbmk2 F01.hbp
fi
