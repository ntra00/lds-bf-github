#!/bin/bash
cd /marklogic/id/natlibcat/admin/bfi/bibrecs/
CURDIR=`echo $PWD`

ct=$(ls -ltra $CURDIR/singleload/ | wc -l)
watchct=$(ps -ef|grep watch-singles-i | wc -l)
echo watching: $watchct
echo $ct ready to post

if [[  $ct != 0 ]]; then
# something to post
   if [[ $watchct < 4 ]]; then
# no watch singles jobs running
      echo loading singles
      sleep 1
      mv `ls -tr $CURDIR/singleload/* | head -$ct` $CURDIR/loadrdf/
# reload instances with batch id collection
    ./rbli
          
   else
      echo "waiting for previous watch session : $watchct"
   fi
   else
	echo no singles to load
fi


