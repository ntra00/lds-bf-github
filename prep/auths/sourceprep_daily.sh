#!/bin/bash

#daily auths: already in marcxml

# split to 250, formc, convert to rdf

# set to yesterday unless date is passed in: (ILS records have yesterdays' date
# getils runs at 1am
# from bibdaily_1.sh but basically bibdaily2, yaz converion

# runs for yesterday unless date yyy-mm-dd is passed in as parameter 1

# cant be ../config if run by crontab:
source /marklogic/nate/lds/lds-bf/prep/config auths

YESTERDAY=$1 
 if [[ -n "$YESTERDAY" ]]
 then
 	YESTERDAY=$YESTERDAY
 else
	YESTERDAY=`date +%Y-%m-%d -d "1 day ago"`
 fi
 echo "load date  = $YESTERDAY"

yr=$(echo $YESTERDAY | cut -c3-4)
mon=$(echo $YESTERDAY | cut -c6-7)
day=$(echo $YESTERDAY | cut -c9-10)
filedate=$yr$mon$day


echo $filedate ...is filedate...


cd $SOURCE_UNPROCESSED
pwd


ls /marklogic/opt/marcdump/auth/*$filedate*

for mrc in $(ls /marklogic/opt/marcdump/auth/*$filedate*) 
do
	echo ---------
	echo $mrc : $filedate
		
		directory=$YESTERDAY
		mkdir $directory >/dev/null
		chmod  775  $directory > /dev/null
		chgrp marklogic $directory > /dev/null
		cd $directory
		mkdir A
		chmod -R 775 A > /dev/null
		chgrp marklogic A > /dev/null
		cd A
						
			yaz-marcdump -C 250 -s split_ $mrc
			
			
			for f in split*
			do
					yaz-marcdump  -i marc -o marcxml $f  > $f.tmp.xml	 	
	
		 		sed -e "s|\[from old catalog\]||g" < $f.tmp.xml	 > $f.xml

				rm $f
				rm *tmp*

				chmod -R  775  * > /dev/null
			    chgrp marklogic * > /dev/null

			done
		
done
cd $SOURCE_UNPROCESSED
#for mrc in $(ls deleted.bib.marc.$filedated.xml) 
for mrc in $(ls /marklogic/opt/marcdump/deletedauths/deleted.auth.marc.*$filedate*) 
	do
	echo $mrc
		
		directory=$YESTERDAY
		mkdir $directory >/dev/null
		chmod -R 775 $directory > /dev/null
		chgrp marklogic $directory > /dev/null
		cd $directory
		mkdir D
		chmod -R  775  D > /dev/null
		chgrp marklogic D > /dev/null
		cd D
		yaz-marcdump -f utf8 -t utf8 -C 250 -s split_ $mrc > /dev/null  

		for f in split*
		do
		 	yaz-marcdump  -i marc -o marcxml $f  > $f.xml	
			
			rm $f

		    chmod -R  775  * > /dev/null
	        chgrp marklogic * > /dev/null

		done
		cd $CURDIR
done
