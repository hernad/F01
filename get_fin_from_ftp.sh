#!/bin/bash

USER_PASSWORD=$1
FOLDER=$2

echo PASSWORD=$PASSWORD
echo FOLDER=$FOLDER

FTP_SERVER=files.bring.out.ba

if  [ "$PWD" == "" ]; then 
  echo navedite user:password  za $FTP_SERVER kao prvi argument
  exit 1
fi


if  [ "$FOLDER" == "" ]; then
  echo navedite folder  za $FTP_SERVER kao drugi argument npr: bringout/korisnici/bringout/fin_2014
   exit 1
fi


mkdir -p SIGMA/FIN/KUM1
cd SIGMA/FIN/KUM1

CURL_OPTS="-L "
CURL_OPT2="--user $USER_PASSWORD"
 
echo curl opts: $CURL_OPTS

for f in ANAL SINT SUBAN NALOG; do
   echo curl $CURL_OPTS -o $f.7z ftp://$FTP_SERVER/$FOLDER/$f.7z $CURL_OPT2
   curl $CURL_OPTS -o $f.7z ftp://$FTP_SERVER/$FOLDER/$f.7z $CURL_OPT2
   if [ "$?" != "0" ] ; then
      echo ERR: curl error
      exit 1
   fi
   7za -y x $f.7z
done
