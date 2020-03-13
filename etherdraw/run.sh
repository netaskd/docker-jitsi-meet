#!/bin/sh

#Move to the folder where ep-lite is installed
cd `dirname $0`

#Was this script started in the bin folder? if yes move out
if [ -d "../bin" ]; then
  cd "../"
fi

#prepare the enviroment
bin/installDeps.sh $* || exit 1

#Move to the node folder and start
echo "start..."
exec node server.js $*
