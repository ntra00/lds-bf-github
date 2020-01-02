#!/bin/bash

cd /marklogic/id/natlibcat/admin/bfi/bibrecs/
# make an xml file for doc label change checking
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
fi
pwd

	
	grep -n '"001"' *| cut -d">" -f2|cut -d "<" -f1 > $curdir/manifest/bibsload.manifest.txt
	if [ -f $curdir/manifest/bibsload.manifest.txt ]; then
	   echo "<?xml version='1.0' encoding='UTF-8'?>" >  $curdir/manifest/daysload.$TODAY.xml
	   echo "<daysload day='$TODAY'>" >>  $curdir/manifest/daysload.$TODAY.xml

		while read bibid
		do
			docid=$(printf '%09d' $bibid)
			objid=/resources/works/c${docid}
			echo $objid
			echo "<record objid='${objid}'/>" >> $curdir/manifest/daysload.$TODAY.xml

		done < $curdir/manifest/$TODAY.bibsload.manifest.txt
	  echo "</daysload>" >>  $curdir/manifest/daysload.$TODAY.xml
chmod 775 $curdir/manifest/daysload.$TODAY.xml
chgrp marklogic  $curdir/manifest/daysload.$TODAY.xml

fi

echo "done"
