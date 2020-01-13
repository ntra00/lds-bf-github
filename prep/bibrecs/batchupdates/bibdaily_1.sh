#!/bin/bash

#daily bibs:

#convert to marcxml, formc, ingest to /bibframe/chunks/[yesterday]? , store to /bibframe/process/records/

# set to yesterday unless date is passed in: (ILS records have yesterdays' date
# getils runs at 1am
# bibdaily_1.sh to marcxml and posts to database as marcxml: 1:30am
# bibdaily_2.sh convert using just xslt and post to db; runs when 1 finishes
# bibdaily_4.sh convert to rdf using yaz and load (has split problems but rarely)

# runs for yesterday unless date yyy-mm-dd is passed in as parameter 1

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

#`date +%Y%m%d | cut -c3-10`
cd /marklogic/id/natlibcat/admin/bfi/bibrecs/bibs_daily
#symlink the days voyager output here:
for f in $(ls /marklogic/opt/marcdump/bib/*$filedate*) 
do
 ln -s $f .
done

for f in $(ls /marklogic/opt/marcdump/deletedbibs/*$filedate*) 
do
 ln -s $f .
done

ls -l *$filedate*
echo $filedate=filedate

# First break up the large MARC 2709 files into smaller chunks, 250 per file.  Still 2709. 
# Convert from marc8 encoding to UTF-8. Save with a prefix of "split_".  They will write to the same directory as the large 2709 files.

for mrc in $(ls BIB.ML.D$filedate) 
	do
	echo $mrc
		
		directory=$YESTERDAY
		mkdir $directory
		chmod -R 775  $directory > /dev/null
		chgrp marklogic $directory > /dev/null
		cd $directory
		mkdir A
		chmod -R 775 A > /dev/null
		chgrp marklogic A > /dev/null
		cd A
		yaz-marcdump -f utf8 -t utf8 -C 250 -s split_ ../../$mrc > /dev/null  

		for f in split*
		do
		 	yaz-marcdump  -i marc -o marcxml $f  > $f.tmp 
			uconv -f utf8 -t utf8 -x nfc -c --from-callback skip --to-callback skip  < $f.tmp   > $mrc_$f.1.tmp
			
	#remove [from old catalog]:

	 sed -e "s|\[from old catalog\]||g" < $mrc_$f.1.tmp  >$mrc_$f.xml
	 
	 
#			rm $f.tmp
			rm $f
			rm *tmp*

			chmod -R  775  * > /dev/null
		    chgrp marklogic * > /dev/null

		done
		cd ../..
done
for mrc in $(ls deleted.bib.marc.$filedate) 
	do
	echo $mrc
		
		directory=$YESTERDAY
		mkdir $directory
		chmod -R 775 $directory > /dev/null
		chgrp marklogic $directory > /dev/null
		cd $directory
		mkdir D
		chmod -R  775  D > /dev/null
		chgrp marklogic D > /dev/null
		cd D
		yaz-marcdump -f utf8 -t utf8 -C 250 -s split_ ../../$mrc > /dev/null  

		for f in split*
		do

		 	yaz-marcdump  -i marc -o marcxml $f  > $mrc_$f.xml

            rm *tmp*
#			rm $f.tmp*.rdf
			rm $f
			
		    chmod -R  775  * > /dev/null
	        chgrp marklogic * > /dev/null

		done
		cd ../..
done
# -----------   start loading ------------- #

echo "next, daily ADD records ingested to /bibframe-process/records with batch name"

echo "then process deletes: change the ingest program to look for  d in leader, remove from catalog"
echo loading files from id-main name titles  $YESTERDAY
 
# import chunks as split*


SUBDIR=D$filedate
THREADS=4
MLCPPATH=/marklogic/id/id-prep/mlcp/bin
PASSWD=`/marklogic/id/id-prep/marc/keys/passwd-ml.sh`
 # process the Adds first (eg., ../2017-07-22/A )
 
 $MLCPPATH/mlcp.sh import  \
        -host localhost \
        -port 8203 \
        -username id-admin \
        -password $PASSWD \
		-input_file_path /marklogic/id/natlibcat/admin/bfi/bibrecs/bibs_daily/$YESTERDAY/A \
		-output_uri_replace "/marklogic/id/natlibcat/admin/bfi/bibrecs/bibs_daily,''"  \
		-output_collections /bibframe-process/,/bibframe-process/chunks/,/processing/load/bibchunks/$YESTERDAY/ \
		-output_uri_prefix "/bibframe-process/chunks" \
		-input_file_pattern split.*\.xml \
		-output_permissions lc_read,read,lc_read,execute,id-admin-role,update,lc_xmlsh,update \
    	-input_file_type documents \
		-document_type xml \
		-aggregate_record_element collection \
    	-aggregate_record_namespace http://www.loc.gov/MARC21/slim \
        -thread_count $THREADS \
        -mode local \

$MLCPPATH/mlcp.sh import  \
        -host localhost \
        -port 8203 \
        -username id-admin \
        -password $PASSWD \
	-input_file_path /marklogic/id/natlibcat/admin/bfi/bibrecs/bibs_daily/$YESTERDAY/D \
	-output_uri_replace "/marklogic/id/natlibcat/admin/bfi/bibrecs/bibs_daily,''"  \
	-output_collections /bibframe-process/,/bibframe-process/chunks/,/processing/load/bibchunks/$YESTERDAY/,/processing/load/bibchunks/deletes/ \
	-output_uri_prefix "/bibframe-process/chunks" \
	-input_file_pattern split.*\.xml \
	-output_permissions lc_read,read,lc_read,execute,id-admin-role,update,lc_xmlsh,update \
    	-input_file_type documents \
	-document_type xml \
	-aggregate_record_element collection \
    	-aggregate_record_namespace http://www.loc.gov/MARC21/slim \
        -thread_count $THREADS \
        -mode local \

echo done importing bib chunks  for $YESTERDAY 
cd   /marklogic/applications/natlibcat/admin/bfi/bibrecs

./corb-bibframe-split-bib-chunks.sh $YESTERDAY A
echo " done splitting the add/edit docs from $YESTERDAY"

./corb-bibframe-split-bib-chunks.sh $YESTERDAY D
echo "done splitting the delete docs from $YESTERDAY (bibdaily_1.sh)"
echo "ready to process bibs in batch from $YESTERDAY "

#---------------------- marc2bf ---------------------------------------------
# now done n bibdaily_2.sh at 01:40am
