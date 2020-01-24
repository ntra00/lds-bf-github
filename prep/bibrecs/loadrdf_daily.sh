#!/bin/bash

#records are already rdf , in source/processed/[date]/[A|D]
# if re-running, copy from $LOAD_PROCESSED first

source /marklogic/nate/lds/lds-bf/prep/config bibrecs

CURDIR=`echo $PWD`


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



echo $filedate=filedate

echo "$YESTERDAY is only for batch date; this loads the yazdaily directory.bad if you forgot to enter the date parameter."

echo "then process deletes:  remove from catalog"
echo loading files from loads dir in rdf for:  $YESTERDAY


cp -R $SOURCE_PROCESSED/$YESTERDAY $LOAD_UNPROCESSED/

DAILY_ADD=$LOAD_UNPROCESSED/$YESTERDAY/A
DAILY_DEL=$LOAD_UNPROCESSED/$YESTERDAY/D


 cd $CURDIR
echo "yaz daily loads for $YESTERDAY starting:"

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
		-output_collections /bibframe-process/,/processing/load/bibs/$YESTERDAY/,/bibframe-process/yaz-reload/ \
		-output_permissions lc_read,read,lc_read,execute,id-admin-role,update,lc_xmlsh,update \
   		-input_file_type documents \
		-transform_module /prep/bibrecs/corb-bibframe-process-yazbib-files.xqy \
		-transform_namespace "http://loc.gov/ndmso/marc-2-bibframe-yaz/" \
		-document_type xml \
        -aggregate_record_element RDF \
        -aggregate_record_namespace http://www.w3.org/1999/02/22-rdf-syntax-ns# \
        -thread_count $THREADS \
        -mode local

done

		echo "deletes for $YESTERDAY starting: $DAILY_DEL"
for file in $(ls $DAILY_DEL/*.rdf); do
		

	$MLCPPATH/mlcp.sh import  \
 	    -host localhost \
        -port $BFDB_XCC_PORT \
        -username $BFDB_XCC_USER \
        -password $BFDB_XCC_PASS \
		-input_file_path ${DAILY_DEL}	 \
		-output_uri_replace "${DAILY_DEL},''"  \
		-output_collections /bibframe-process/,/processing/load/bibs/$YESTERDAY/ \
		-output_permissions lc_read,read,lc_read,execute,id-admin-role,update,lc_xmlsh,update \
   		-input_file_type documents \
		-transform_module /prep/bibrecs/corb-bibframe-process-yazbib-files.xqy \
		-transform_namespace "http://loc.gov/ndmso/marc-2-bibframe-yaz/" \
		-document_type xml \
		-aggregate_record_element RDF \
    	-aggregate_record_namespace http://www.w3.org/1999/02/22-rdf-syntax-ns# \
        -thread_count $THREADS \
        -mode local

done

echo rdfxml done
echo  checking urls posted

   #./daysload-check.sh $YESTERDAY
echo done loadrdf  ingest of yazzed bibs to bf database

yr=$(echo $YESTERDAY | cut -c3-4)
mon=$(echo $YESTERDAY | cut -c6-7)
day=$(echo $YESTERDAY | cut -c9-10)
filedate=$yr$mon$day


mv $LOAD_UNPROCESSED/$YESTERDAY $LOAD_PROCESSED
rm -R $SOURCE_PROCESSED/$YESTERDAY

#cat  ../logs/bibdaily_4$filedate.log |grep split  |cut -d ':' -f5|sort



