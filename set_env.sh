#!/bin/bash
export QT_PLUGIN_PATH=c:/Platform/QT_Platform/plugins

HB_DBG_PATH=.
MODULES=fmk_hb
for m in $MODULES
do
      HB_DBG_PATH="$HB_DBG_PATH;$m"
done

echo $HB_DBG_PATH
