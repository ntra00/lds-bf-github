#!/bin/bash


#records are already rdf when loaded to database, after yaz process, in "loads" directory.
# no handling of deletes. probably need to ingest this process before the deletes in the main process.

CURDIR=`echo $PWD`


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



echo "then process deletes: change the ingest program to look for  d in leader, remove from catalog"
echo loading files from loads dir in rdf for:  $YESTERDAY

THREADS=8
MLCPPATH=/marklogic/id/id-prep/mlcp/bin
PASSWD=`/marklogic/id/id-prep/marc/keys/passwd-ml.sh`

echo not sure how to pass overwrite
echo not sure how to deal with deletes
#corb-bibframe-process-yazbib-files.xqy

 cd $CURDIR

 $MLCPPATH/mlcp.sh import  \
 	    -host localhost \
        -port 8203 \
        -username id-admin \
        -password $PASSWD \
		-input_file_path /marklogic/id/natlibcat/admin/bfi/bibrecs/loads \
		-output_uri_replace "/marklogic/id/natlibcat/admin/bfi/bibrecs/loads/,''"  \
		-output_collections /bibframe-process/,/processing/load/bibs/$YESTERDAY/ \
		-output_permissions lc_read,read,lc_read,execute,id-admin-role,update,lc_xmlsh,update \
   		-input_file_type documents \
		-transform_module /admin/bfi/bibrecs/corb-bibframe-process-yazbib-files.xqy \
		-transform_namespace "http://loc.gov/ndmso/marc-2-bibframe-yaz/" \
		-document_type xml \
		-aggregate_record_element RDF \
    	-aggregate_record_namespace http://www.w3.org/1999/02/22-rdf-syntax-ns# \
        -thread_count $THREADS \
        -mode local 

echo rdfxml done
