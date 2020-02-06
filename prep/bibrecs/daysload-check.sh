#!/bin/bash
# curl todays adds

source /marklogic/nate/lds/lds-bf/prep/config bibrecs

CURDIR=`echo $PWD`

cd $LOAD_PROCESSED
pwd

TODAY=$1

if [[ -n "$TODAY" ]]
then
	TODAY=$TODAY
else
  TODAY=`date +%Y-%m-%d -d "1 day ago"`

fi

echo today:
echo $TODAY

if [ -d $TODAY ]; then
 cd $TODAY/A

pwd

	rm $CURDIR/manifest/bibsload*

	grep -n '"001"' *| cut -d">" -f2|cut -d "<" -f1 > $CURDIR/manifest/bibsload.manifest.txt
	if [ -f $CURDIR/manifest/bibsload.manifest.txt ]; then

		while read bibid
		do
			docid=$(printf '%09d' $bibid)
			url=http://mlvlp04.loc.gov:8230/resources/instances/c${docid}0001.rdf
			echo $docid: $url >> $CURDIR/manifest/bibsload.curlsraw.txt
			curl -I $url >> $CURDIR/manifest/bibsload.curlsraw.txt 

		done < $CURDIR/manifest/bibsload.manifest.txt

		grep -n "404 Item" $CURDIR/manifest/bibsload.curlsraw.txt > $CURDIR/manifest/bibsload.curls404.txt
		echo " curls404 has today's 404s"
		cat  $CURDIR/manifest/bibsload.curls404.txt
		
		if [ -f $CURDIR/manifest/bibsload.curls404.txt ]; then
			while read x
			do
			   	echo $x
			   	line404=$(echo ${x}|cut -d ":" -f1)
			   	curlline=$(($line404-1))
			   	echo "$line404 | $curlline"
			#   	echo sed the id and the curl output to curls.tmp

			    	sed -n ${curlline},${line404}p <   $CURDIR/manifest/bibsload.curlsraw.txt > $CURDIR/manifest/bibsload.curls.tmp
				cat  $CURDIR/manifest/bibsload.curls.tmp >> $CURDIR/manifest/bibsload.curls.txt

#			 	echo "append the tmp line to the txt line; one line per 404 bib"

			done < $CURDIR/manifest/bibsload.curls404.txt

			cd $CURDIR
			cat $CURDIR/manifest/bibsload.curls.txt| cut -d":" -f2-4 |grep -v Item >>  $CURDIR/manifest/bibsload.curls.notfound.txt

			mv $CURDIR/manifest/bibsload.curls.notfound.txt  $CURDIR/manifest/$TODAY.bibsload.curls.notfound.txt
			mv $CURDIR/manifest/bibsload.manifest.txt  $CURDIR/manifest/$TODAY.bibsload.manifest.txt
			
			chmod 775 $CURDIR/manifest/bibs*
			chmod 775 $CURDIR/manifest/$TODAY*

			chgrp marklogic $CURDIR/manifest/bibs*
			chgrp marklogic $CURDIR/manifest/$TODAY*
			echo
echo --------------------------------------
			ls -l $CURDIR/manifest/*$TODAY*notfound*
echo --------------------------------------

		fi
	fi
	else
	
echo "no data A dir for $TODAY"

while read bibid;
do
cat /var/opt/MarkLogic/Logs/ErrorLog.txt |grep $bibid
done <  $CURDIR/manifest/$TODAY.bibsload.curls.notfound.txt

fi

echo "done"
