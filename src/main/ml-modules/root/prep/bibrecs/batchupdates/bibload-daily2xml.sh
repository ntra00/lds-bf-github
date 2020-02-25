#!/bin/bash
# copied from bibdail2xml: does not process bibs, just load chunks and split.

#daily bibs:
# cp /marklogic/opt/marcdump/bib/BIB.ML.D170522 .
# cp /marklogic/opt/marcdump/deletedbibs/deleted.bib.marc.170522 .

#convert to markcxml, formc, ingest to /bibframe/chunks/[yesterday]? or just directly store to /bibframe/process/records/

#process deletes: if type=d, find instance and drop the "catalog" collection
#process adds:
#move ? 

# set to yesterday unless date is passed in: (ILS records have yesterdays' date
#
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
# First break up the large MARC 2709 files into smaller chunks, 1000 per file.  Still 2709. 
# Convert from marc8 encoding to UTF-8. Save with a prefix of "split_".  They will write to the same directory as the large 2709 files.



echo "next, daily adds ingest to /bibframe-process/records with batch name"

echo "then process deletes: change the ingest program to look for  d in leader, remove from catalog"
echo loading files from id-main name titles  $YESTERDAY
 


SUBDIR=D$filedate
THREADS=10
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


echo this will NOT process stuff split literally today, not $YESTERDAY
#nohup ./corb-bibs-daily-process-bib-files.sh > ../logs/process-daily-bibs.log &
#echo done  processinging bibs in batch from $YESTERDAY loaded on `date`
echo done loading and splitting $YESTERDAY
