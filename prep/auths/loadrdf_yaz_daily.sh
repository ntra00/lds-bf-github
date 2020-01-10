#!/bin/bash

# YAZzed records, loaded like bibs; may work

#records are already rdf , in source/processed/[date]/[A|D]
# if re-running, copy from $LOAD_PROCESSED first

# cant be ../config if run by crontab:
source /marklogic/nate/lds/lds-bf/prep/config auths

CURDIR=`echo $PWD`

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

echo $filedate=filedate

echo loading files from loads dir in rdf for:  $YESTERDAY

cp -R $SOURCE_PROCESSED/$YESTERDAY $LOAD_UNPROCESSED/

DAILY_ADD=$LOAD_UNPROCESSED/$YESTERDAY/A
DAILY_DEL=$LOAD_UNPROCESSED/$YESTERDAY/D


 cd $CURDIR
echo "yaz daily loads for $YESTERDAY starting:"
ls $DAILY_ADD/*.rdf

echo running each split file separately so there are no errors:
for file in $(ls $DAILY_ADD/*.rdf); do
        echo "loading $file"

 $MLCPPATH/mlcp.sh import  \
 	    -host localhost \
        -port $BFDB_XCC_PORT \
        -username $BFDB_XCC_USER \
        -password $BFDB_XCC_PASS \
		-input_file_path $file	 \
		-output_uri_replace "$DAILY_ADD,''"  \
		-output_collections /authorities/bfworks/,/resources/works/,/processing/load_bfworks/$YESTERDAY/,/catalog/,/lscoll/lcdb/works/,/authorities/yazbfworks/,/bibframe/hubworks/ \
		-output_permissions lc_read,read,lc_read,execute,id-admin-role,update,lc_xmlsh,update \
   		-input_file_type documents \
		-transform_module /prep/auths/authorities-yaz2bf.xqy \
		-transform_namespace "http://loc.gov/ndmso/authorities-yaz-2-bibframe" \
		-document_type xml \
        -aggregate_record_element RDF \
        -aggregate_record_namespace http://www.w3.org/1999/02/22-rdf-syntax-ns# \
        -thread_count $THREADS \
        -mode local

done

		echo "deletes for $YESTERDAY starting: $DAILY_DEL"
		
$MLCPPATH/mlcp.sh import  \
 	    -host localhost \
        -port $BFDB_XCC_PORT \
        -username $BFDB_XCC_USER \
        -password $BFDB_XCC_PASS \
		-input_file_path $DAILY_DEL	 \
		-output_uri_replace "$DAILY_DEL,''"  \
		-output_collections /authorities/bfworks/,/resources/works/,/processing/load_bfworks/$YESTERDAY/,/catalog/,/lscoll/lcdb/works/,/authorities/yazbfworks/,/bibframe/hubworks/ \
		-output_permissions lc_read,read,lc_read,execute,id-admin-role,update,lc_xmlsh,update \
   		-input_file_type documents \
		-transform_module /prep/auths/authorities-yaz2bf.xqy \
		-transform_namespace "http://loc.gov/ndmso/authorities-yaz-2-bibframe" \
		-document_type xml \
		-aggregate_record_element RDF \
    	-aggregate_record_namespace http://www.w3.org/1999/02/22-rdf-syntax-ns# \
        -thread_count $THREADS \
        -mode local

echo rdfxml done
echo  checking urls posted

   #./daysload-check.sh $YESTERDAY (only works in bibs so far)

echo done loadrdf  ingest of yazzed bibs to bf database


mv $LOAD_UNPROCESSED/$YESTERDAY $LOAD_PROCESSED

rm -R $SOURCE_PROCESSED/$YESTERDAY



