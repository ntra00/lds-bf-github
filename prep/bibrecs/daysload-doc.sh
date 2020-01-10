#!/bin/bash

source  /marklogic/nate/lds/lds-bf/prep/config bibrecs
# make an xml file for doc label change checking
CURDIR=`pwd`

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
fi
pwd

	
	grep -n '"001"' *| cut -d">" -f2|cut -d "<" -f1 > $CURDIR/manifest/bibsload.manifest.txt
	if [ -f $CURDIR/manifest/bibsload.manifest.txt ]; then
	   echo "<?xml version='1.0' encoding='UTF-8'?>" >  $CURDIR/manifest/daysload.$TODAY.xml
	   echo "<daysload day='$TODAY'>" >>  $CURDIR/manifest/daysload.$TODAY.xml

		while read bibid
		do
			docid=$(printf '%09d' $bibid)
			objid=/resources/works/c${docid}
			echo $objid
			echo "<record objid='${objid}'/>" >> $CURDIR/manifest/daysload.$TODAY.xml

		done < $CURDIR/manifest/$TODAY.bibsload.manifest.txt
	  echo "</daysload>" >>  $CURDIR/manifest/daysload.$TODAY.xml
chmod 775 $CURDIR/manifest/daysload.$TODAY.xml
chgrp marklogic  $CURDIR/manifest/daysload.$TODAY.xml

fi

echo "done"
