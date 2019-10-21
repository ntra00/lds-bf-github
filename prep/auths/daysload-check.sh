#!/bin/bash

cd /marklogic/id/natlibcat/admin/bfi/auths/

curdir=`pwd`
# mkdir $curdir/manifest

cd bibs_daily
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

	rm $curdir/manifest/bibsload*
	grep -n '"001"' *| cut -d">" -f2|cut -d "<" -f1 > $curdir/manifest/bibsload.manifest.txt
	if [ -f $curdir/manifest/bibsload.manifest.txt ]; then

		while read bibid
		do
			docid=$(printf '%09d' $bibid)
			url=http://mlvlp04.loc.gov:8230/resources/instances/c${docid}0001.rdf
			echo $docid: $url >> $curdir/manifest/bibsload.curlsraw.txt
			curl -I $url >> $curdir/manifest/bibsload.curlsraw.txt 

		done < $curdir/manifest/$TODAY.bibsload.manifest.txt

		grep -n "404 Item" $curdir/manifest/bibsload.curlsraw.txt > $curdir/manifest/bibsload.curls404.txt
		echo " curls404 has today's 404s"
		cat  $curdir/manifest/bibsload.curls404.txt
		
		if [ -f $curdir/manifest/bibsload.curls404.txt ]; then
			while read x
			do
			   	echo $x
			   	line404=$(echo ${x}|cut -d ":" -f1)
			   	curlline=$(($line404-1))
			   	echo "$line404 | $curlline"
			#   	echo sed the id and the curl output to curls.tmp

			    	sed -n ${curlline},${line404}p <   $curdir/manifest/bibsload.curlsraw.txt > $curdir/manifest/bibsload.curls.tmp
				cat  $curdir/manifest/bibsload.curls.tmp >> $curdir/manifest/bibsload.curls.txt

#			 	echo "append the tmp line to the txt line; one line per 404 bib"

			done < $curdir/manifest/bibsload.curls404.txt

			cd $curdir
			cat  $curdir/manifest/bibsload.curls.txt
			cat $curdir/manifest/bibsload.curls.txt| cut -d":" -f2-4 |grep -v Item >>  $curdir/manifest/bibsload.curls.notfound.txt

			mv $curdir/manifest/bibsload.curls.notfound.txt  $curdir/manifest/$TODAY.bibsload.curls.notfound.txt
			mv $curdir/manifest/bibsload.manifest.txt  $curdir/manifest/$TODAY.bibsload.manifest.txt
			
			chmod 775 $curdir/manifest/bibs*
			chmod 775 $curdir/manifest/$TODAY*

			chgrp marklogic $curdir/manifest/bibs*
			chgrp marklogic $curdir/manifest/$TODAY*
			echo
echo --------------------------------------
			ls -l manifest/*$TODAY*notfound*
echo --------------------------------------

		fi
	fi
	else
	
echo "no data A dir for $TODAY"

fi

echo "done"
