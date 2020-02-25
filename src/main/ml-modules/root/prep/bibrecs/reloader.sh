#!/bin/bash
# this views the log from the last 10 minutes and finds the uniq rbis, 
# then changes rbi to rbc so that the records are yazzed first and loaded as a batch
# then executes each yaz using "rbc"

watchct=$(ps -ef|grep reloader.sh -i |grep -v grep| wc -l)
echo $watchct= watchcount
   if [[ !$watchct  ]]; then

echo starting reloader
source /marklogic/id/lds-bf-github/src/main/ml-modules/root/prep/config bibrecs

#date >> /home/ntra/reloader.log
CURDIR=`pwd`
echo $CURDIR
read q
prev=$(date  "+%R" -d "1 min ago")
this=$(date "+%R")
  TODAY=`date +%Y-%m-%d`

matcher="$TODAY $prev\|$this"
echo $matcher
    cat /var/opt/MarkLogic/Logs/ErrorLog.txt |grep  ./rbi| grep "$matcher" | cut -d ":" -f7-12 |grep -v "e" |sort |uniq > batchupdates/reloads.txt

     cat /var/opt/MarkLogic/Logs/ErrorLog.txt |grep  ./post-auth.sh | grep "$matcher" |  cut -d ":" -f7-12 |sort |uniq >> batchupdates/reloads.txt
sed "s|rbi|rbc|g" <  batchupdates/reloads.txt >  batchupdates/reloads-now.txt

cat  batchupdates/reloads-now.txt|wc -l

while read line
do
	echo "`$line`"
echo "`sleep .2`"
	echo this is the line sleep .2| $line

done < batchupdates/reloads-now.txt

fi
