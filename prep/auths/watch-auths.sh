#!/bin/bash
cd /marklogic/id/natlibcat/admin/bfi/auths/
CURDIR=`echo $PWD`

ct=$(ls -ltra $CURDIR/source/*.rdf | wc -l)
watchct=$(ps -ef|grep watch-auths | wc -l)
echo watching: $watchct
echo $ct ready to post

if [[  $ct != 0 ]]; then
# something to post
   if [[ $watchct < 4 ]]; then
# no watch singles jobs running
      echo loading singles
      sleep 1
      mv `ls -tr $CURDIR/source/*.rdf | head -$ct` $CURDIR/load/
# reload instances with batch id collection
    ./rnl
          
   else
      echo "waiting for previous watch session : $watchct"
   fi
   else
	echo no singles to load
fi


