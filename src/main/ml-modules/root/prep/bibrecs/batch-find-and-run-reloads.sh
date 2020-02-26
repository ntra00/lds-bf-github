#!/bin/bash
# this views the log from yesterday (after midnight) and finds the uniq rbis, 
# then changes rbi to rbc so that the records are yazzed first and loaded as a batch
# then executes each yaz using "rbc"


source /marklogic/id/lds-bf-github/src/main/ml-modules/root/config bibrecs

CURDIR=`pwd`
echo $CURDIR

     cat /var/opt/MarkLogic/Logs/ErrorLog_1.txt |grep  ./rbi| cut -d ":" -f7-12 |grep -v "e" |sort |uniq > batchupdates/display-reloads.txt

     cat /var/opt/MarkLogic/Logs/ErrorLog_1.txt |grep  ./post-auth.sh | cut -d ":" -f7-12 |sort |uniq >> batchupdates/display-reloads.txt
     
sed "s|rbi|rbc|g" <  batchupdates/display-reloads.txt >  batchupdates/batch-display-reloads.txt

cat  batchupdates/batch-display-reloads.txt|wc -l


while read line
do
	echo "`$line`"
echo "`sleep .2`"
	echo this is the line sleep .2| $line

done < batchupdates/batch-display-reloads.txt


