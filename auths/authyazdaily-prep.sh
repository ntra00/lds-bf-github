#!/bin/bash

# rewritten to start from auth exports from ILS, not mets files in ID. after loads int ID, files are here:

#/marklogic/staging/marcdump/auth_updates_xml/done/AUTH.ML.D190214a.xml 
#/marklogic/staging/marcdump/auth_updates_xml/done/AUTH.ML.D190214d.xml 


# this is written for idmain on localhost to nlc localhost 8282 to 8082?
# test of mlcp copy from nametitles madsrdf in id-main to natlibcat bf works
# daily load files: find nametitles and titles loaded to id=main today in the names file.
# if you want to load a specific  day, 2017-07-01 on command line

# added collection to nametitles and titles (/authorities/bfworks/)

# ex: nohup ./load_nametitles_mlcp.sh [optional day yyyy-mm-dd defaults to today] > ../logs/nametitles2works.log 

# from id-main:    -output_permissions id-admin-role,update,id-admin-role,insert,id-user-role,read,id-admin-role,read \
# expects id-main to have /processing/load/bfworks/[today, ie., YYYY-MM-DD]/


M2BFDIR=/marklogic/id/marc2bibframe2

YESTERDAY=$1 
 if [[ -n "$YESTERDAY" ]]
 then
 	YESTERDAY=$YESTERDAY
 else
# 	TODAY=`date +%Y-%m-%d`
	YESTERDAY=`date +%Y-%m-%d -d "1 day ago"`
 fi
 echo "load date  = $YESTERDAY"
yr=$(echo $YESTERDAY | cut -c3-4)
mon=$(echo $YESTERDAY | cut -c6-7)
day=$(echo $YESTERDAY | cut -c9-10)
filedate=$yr$mon$day

#filedate=$(echo $YESTERDAY | cut -c3-10)
echo $filedate

echo $filedate=filedate

read qy

THREADS=4

CURDIR=`echo $PWD`

cd /marklogic/id/natlibcat/admin/bfi/auths/auths_daily
mkdir $filedate
chmod 775 $filedate
chgrp marklogic $filedate
cd $filedate
	mkdir "A"
	chmod 775 "A"
	chgrp marklogic "A"	
	mkdir "D"
	chmod 775 "D"
	chgrp marklogic "D"	

	ln -s /marklogic/staging/marcdump/auth_updates_xml/done/AUTH.ML.D$filedatea.xml .
	uconv -f utf8 -t utf8 -x nfc -c --from-callback skip --to-callback skip  < AUTH.ML.D$filedatea.xml   > D$filedatea.xml
	
	cd "A"
	yaz-marcdump -f utf8 -t utf8 -C 500 -s split_ ../D$filedatea.xml  #> /dev/null  
	
done
cd ..