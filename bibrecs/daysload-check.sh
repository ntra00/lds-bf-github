#!/bin/bash
# curl todays adds

source ../config bibrecs


CURDIR=`echo $PWD`

cd $LOAD_PROCESSED
pwd

TODAY=$1

if [[ -n "$TODAY" ]]
then
	TODAY=$TODAY
else
  TODAY=`date +%Y-%m-%d -d "1 day ago"`

 #TODAY=`date +%Y-%m-%d`

fi

echo today:
echo $TODAY

if [ -d $TODAY ]; then
 cd $TODAY/A

pwd

	rm manifest/bibsload*
	grep -n '"001"' *| cut -d">" -f2|cut -d "<" -f1 > manifest/bibsload.manifest.txt
	if [ -f manifest/bibsload.manifest.txt ]; then

		while read bibid
		do
			docid=$(printf '%09d' $bibid)
			url=http://mlvlp04.loc.gov:8230/resources/instances/c${docid}0001.rdf
			echo $docid: $url >> manifest/bibsload.curlsraw.txt
			curl -I $url >> manifest/bibsload.curlsraw.txt 

		done < manifest/$TODAY.bibsload.manifest.txt

		grep -n "404 Item" manifest/bibsload.curlsraw.txt > manifest/bibsload.curls404.txt
		echo " curls404 has today's 404s"
		cat  manifest/bibsload.curls404.txt
		
		if [ -f manifest/bibsload.curls404.txt ]; then
			while read x
			do
			   	echo $x
			   	line404=$(echo ${x}|cut -d ":" -f1)
			   	curlline=$(($line404-1))
			   	echo "$line404 | $curlline"
			#   	echo sed the id and the curl output to curls.tmp

			    	sed -n ${curlline},${line404}p <   manifest/bibsload.curlsraw.txt > manifest/bibsload.curls.tmp
				cat  /manifest/bibsload.curls.tmp >> manifest/bibsload.curls.txt

#			 	echo "append the tmp line to the txt line; one line per 404 bib"

			done < manifest/bibsload.curls404.txt

			cd $CURDIR
			cat  manifest/bibsload.curls.txt
			cat manifest/bibsload.curls.txt| cut -d":" -f2-4 |grep -v Item >>  manifest/bibsload.curls.notfound.txt

			mv manifest/bibsload.curls.notfound.txt  manifest/$TODAY.bibsload.curls.notfound.txt
			mv manifest/bibsload.manifest.txt  manifest/$TODAY.bibsload.manifest.txt
			
			chmod 775 $CURDIR/manifest/bibs*
			chmod 775 $CURDIR/manifest/$TODAY*

			chgrp marklogic manifest/bibs*
			chgrp marklogic manifest/$TODAY*
			echo
echo --------------------------------------
			ls -l manifest/*$TODAY*notfound*
echo --------------------------------------

		fi
	fi
	else
	
echo "no data A dir for $TODAY"

while read bibid;
do
cat /var/opt/MarkLogic/Logs/Error.log |grep $bibid
done <  manifest/$TODAY.bibsload.curls.notfound.txt

fi

echo "done"
