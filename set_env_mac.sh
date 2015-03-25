#!/bin/bash

#export QT_PLUGIN_PATH=c:/Platform/QT_Platform/plugins

export DYLD_LIBRARY_PATH=.:$HB_LIB_INSTALL

HB_DBG_PATH=.
MODULES="fin_01 kalk_01 fakt_01 f01_hb"
for m in $MODULES
do
      HB_DBG_PATH="$HB_DBG_PATH:$m"
done

export HB_DBG_PATH

echo $HB_DBG_PATH
