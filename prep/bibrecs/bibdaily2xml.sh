#!/bin/bash

#daily bibs:

#convert to markcxml, formc, ingest to /bibframe/chunks/[yesterday]? or just directly store to /bibframe/process/records/

#process deletes: if type=d, find instance and drop the "catalog" collection
#process adds:
#move ? 

# set to yesterday unless date is passed in: (ILS records have yesterdays' date
#

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
# First break up the large MARC 2709 files into smaller chunks, 500 per file.  Still 2709. 
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

# changed to uconv 12/3/18
# 			/marklogic/applications/natlibcat/admin/bfi/utf-nf.1.0.2.pl -NFC < $f.tmp  | xmllint --format --encode UTF-8 - > $mrc_$f.1.tmp
# -c skips bad chars
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

echo "next, daily adds ingest to /bibframe-process/records with batch name"

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
echo done splitting the add/edit docs from $YESTERDAY

./corb-bibframe-split-bib-chunks.sh $YESTERDAY D
echo done splitting the delete docs from $YESTERDAY
echo ready to process bibs in batch from $YESTERDAY 

echo this will process stuff split literally today, not $YESTERDAY
nohup ./corb-bibs-daily-process-bib-files.sh > ../logs/process-daily-bibs.log &

chmod 775  /marklogic/id/natlibcat/admin/bfi/logs/* > /dev/null 2>&1
echo done  processinging bibs in batch from $YESTERDAY loaded on `date`

#---------------------- marc2bf ---------------------------------------------#
# go back to bibs_daily/date/A and D, convert to rdf for bibyazload
cd /marklogic/id/natlibcat/admin/bfi/bibrecs/bibs_daily


for mrc in $(ls BIB.ML.D$filedate) 
	do
	echo $mrc
		
		directory=$YESTERDAY
		#$directory > /dev/null
		cd $directory
		
		cd A

		for f in split*.xml
		do
	 
			 yaz-record-conv  $M2BFDIR/record-conv.vlp3.xml  $f > $f.tmp.rdf 

		     sed -e "s|idwebvlp03.loc.gov|id.loc.gov|g" <$f.tmp.rdf >$f.tmp.1.rdf
			 sed -e "s|mlvlp04.loc.gov:8080|id.loc.gov|g" <$f.tmp.1.rdf >$f.tmp.2.rdf
			 sed -e "s|//mlvlp06.loc.gov:8288|http://id.loc.gov|g" < $f.tmp.2.rdf  > $f.tmp.3.rdf

			 xsltproc  /marklogic/id/natlibcat/admin/bfi/bibrecs/modules/graphiphy.xsl  $f.tmp.3.rdf   > $f.rdf

			rm *tmp*
#			rm $f
#			rm $f*tmp*

			chmod -R  775  * > /dev/null
		    chgrp marklogic * > /dev/null

		done
		cd ../..
done
for mrc in $(ls deleted.bib.marc.$filedate) 
	do
	echo $mrc
		
		directory=$YESTERDAY
		
		cd $directory
		
		cd D		

		for f in split*.xml
		do
			yaz-record-conv  $M2BFDIR/record-conv.vlp3.xml  $f > $f.tmp.rdf 
			 xsltproc  /marklogic/id/natlibcat/admin/bfi/bibrecs/modules/graphiphy.xsl  $f.tmp.rdf   > $f.rdf
			rm *tmp*

#			rm $f.tmp*.rdf
#			rm $f
			
		    chmod -R  775  * > /dev/null
	        chgrp marklogic * > /dev/null

		done
		cd ../..
done
