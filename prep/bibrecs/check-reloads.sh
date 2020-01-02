#!/bin/bash
source ../config bibrecs

echo "--------------------------------------------------------------------"
echo source/processed/single contains yazzed content ready for reload
echo  watch-singles-i.sh runs every 3 minutes to copy them to loadrdf
echo from which we run rbl to load to database
echo
echo "--------------------------------------------------------------------"
echo $SOURCE_PROCESSED/single:
 ls -l $SOURCPROCESSED/single/|wc -l

echo $LOAD_UNPROCESSED:
 ls -l $LOAD_UNPROCESSED/single|wc -l
currentrec=$(ps -ef|grep rbc|grep bash| cut -d "." -f2-3 | cut -d " " -f2)
if  [[ $currentrec != "" ]] ; then
echo current rec $currentrec

filepos=$(cat batchupdates/reload.txt |grep -n $currentrec)
start=$(ps -ef|grep reload-generic |grep sh| cut -d "." -f2-3| cut -d " " -f2)

f=$(echo $filepos|cut -d ":" -f1)
echo progress:
echo `expr $f - $start`
fi



