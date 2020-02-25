#!/bin/bash


source /marklogic/id/lds-bf-github/src/main/ml-modules/root/prep/config  bibrecs

CURDIR=`echo $PWD`

ct=$(ls -ltra $SOURCE_PROCESSED/single/ | wc -l)

watchct=$(ps -ef|grep watch-singles-i | wc -l)
echo watching: $watchct
echo $ct ready to post

if [[  $ct != 0 ]]; then
# something to post
   if [[ $watchct < 4 ]]; then
# no watch singles jobs running
      echo loading singles
      sleep 1
      mv `ls -tr $SOURCE_PROCESSED/single/* | head -$ct` $LOAD_UNPROCESSED/single/
	  
	 ls -l  $LOAD_UNPROCESSED/single/
	 
# reload instances with batch id collection
   ./loadrdf_single.sh 
   else
      echo "waiting for previous watch session : $watchct"
   fi
   else
	echo no singles to load
fi


