#!/bin/bash
# this views the log from yesterday (after midnight) and finds the uniq rbis, 
# then changes rbi to rbc so that the records are yazzed first and loaded as a batch
# then executes each yaz
# watch-singles-i.sh is running every 3 mins to get the yazzed files and load them.
cd /marklogic/id/natlibcat/admin/bfi/bibrecs

CURDIR=`pwd`
echo $CURDIR

	 cat /var/opt/MarkLogic/Logs/ErrorLog_1.txt |grep  ./rbi| cut -d ":" -f7-12 |grep -v "e" |sort |uniq > $CURDIR/batchupdates/display-reloads.txt
         cat /var/opt/MarkLogic/Logs/ErrorLog_1.txt |grep  ./post-auth.sh | cut -d ":" -f7-12 |sort |uniq >> $CURDIR/batchupdates/display-reloads.txt

	sed "s|rbi|rbc|g" <  $CURDIR/batchupdates/display-reloads.txt >  $CURDIR/batchupdates/batch-display-reloads.txt

while read line
do
	echo "`$line`"
echo "`sleep .2`"
	echo this is the line sleep .2| $line

done < $CURDIR/batchupdates/batch-display-reloads.txt


