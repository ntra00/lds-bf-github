#!/bin/bash

source /marklogic/id/lds-bf-github/src/main/ml-modules/root/prep/config bibrecs

# make an xml file for doc label change checking
# after sourceprep, goes through the file system looking for 001s and creates a manifest of OBJIDs in xml
CURDIR=`pwd`

#cd $SOURCE_UNPROCESSED

cd $SOURCE_PROCESSED
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
	
	grep -n '"001"' *.xml | cut -d">" -f2|cut -d "<" -f1 > $CURDIR/manifest/bibsload.manifest.txt
	if [ -f $CURDIR/manifest/bibsload.manifest.txt ]; then
	   echo "<?xml version='1.0' encoding='UTF-8'?>" >  $CURDIR/manifest/daysload.$TODAY.xml
	   echo "<daysload day='$TODAY'>" >>  $CURDIR/manifest/daysload.$TODAY.xml

		while read bibid
		do

			docid=$(printf '%09d' $bibid)
			objid=/resources/works/c${docid}
			echo $objid
			echo "<record objid='${objid}'/>" >> $CURDIR/manifest/daysload.$TODAY.xml

		done <  $CURDIR/manifest/bibsload.manifest.txt

	  echo "</daysload>" >>  $CURDIR/manifest/daysload.$TODAY.xml
chmod 775 $CURDIR/manifest/daysload.$TODAY.xml
chgrp marklogic  $CURDIR/manifest/daysload.$TODAY.xml

fi

echo "done  daysload-doc building xml file of bibs object ids"
