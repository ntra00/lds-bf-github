#!/bin/bash
source /marklogic/nate/lds/lds-bf/prep/config auths
CURDIR=`echo $PWD`

ct=$(ls -ltra $SOURCE_PROCESSED/single/*.rdf | wc -l)
watchct=$(ps -ef|grep watch-auths | wc -l)
echo watching: $watchct
echo $ct ready to post

if [[  $ct != 0 ]]; then
# something to post
   if [[ $watchct < 4 ]]; then
# no watch singles jobs running
      echo loading singles
      sleep 1
      mv `ls -tr $SOURCE_PROCESSED/single/*.rdf | head -$ct` $LOAD_UNPROCESSED/single/

# reload auths 
    ./loadrdf_single.sh
          
   else
      echo "waiting for previous watch session : $watchct"
   fi
   else
	echo no singles to load
fi


