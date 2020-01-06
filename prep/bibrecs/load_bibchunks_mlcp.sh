#!/bin/bash

# test of mlcp copy from records I convert using Yaz; /marklogic/applications/natlibcat/admin/bfi/auths/auth2bibframe2/out

# from admin/bfi/bibrecs/bibs_full/catalog*/*.xml
# bf_bib is controlled xdbc by 8028 (former ammem)

#8282 is  id-main xdbc
#8203 is natlibcat xdbc
# 8203 transform uses Modules database; load to /admin/bfi/auths/authorities2bf.xqy

SUBDIR=$1
if [ -n "$SUBDIR" ]
 then
 	SUBDIR=$SUBDIR
 else
 	SUBDIR=catalog01
 fi
# ex: nohup ./load_bibchunks_mlcp.sh 10 > logfile

# from id-main:    -output_permissions id-admin-role,update,id-admin-role,insert,id-user-role,read,id-admin-role,read \

#THREADS=$1
 
 #if [ -n "$THREADS" ]
 #then
 #	THREADS=$THREADS
 #else
 	THREADS=10
 #fi

CURDIR=`echo $PWD`
MLCPPATH=/marklogic/id/id-prep/mlcp/bin
PASSWD=`/marklogic/id/id-prep/marc/keys/passwd-ml.sh`

TODAY=`date +%Y-%m-%d`
     
echo loading files from id-main name titles  $TODAY
 
## -collection_filter /authorities/bfworks/ \
## -input_file_path `in/*.xml` \
## /processing/load/bfworks/2017-02-27/
## -collection_filter /processing/load/bfworks/$TODAY/ \ 

## -collection_filter /processing/load/bfworks/2017-02-27/ \

 $MLCPPATH/mlcp.sh import  \
        -host localhost \
        -port 8203 \
        -username id-admin \
        -password $PASSWD \
		-input_file_path /marklogic/id/natlibcat/admin/bfi/bibrecs/bibs_full/$SUBDIR \
		-output_uri_replace "/marklogic/id/natlibcat/admin/bfi/bibrecs/bibs_full,''"  \
		-output_collections /bibframe-process/chunks/,/processing/load/bibchunks/$TODAY/ \
		-output_uri_prefix "/bibframe-process/chunks" \
		-input_file_pattern '.*\.xml' \
		-output_permissions lc_read,read,lc_read,execute,id-admin-role,update,lc_xmlsh,update \
    	-input_file_type documents \
		-document_type xml \
		-aggregate_record_element collection \
    	-aggregate_record_namespace http://www.loc.gov/MARC21/slim \
		-transform_module /admin/bfi/bibrecs/bibs2bfbibs.xqy \
		-transform_namespace http://loc.gov/ndmso/bibs-2-bfbibs \
        -thread_count $THREADS \
        -mode local \

cd $CURDIR
 
