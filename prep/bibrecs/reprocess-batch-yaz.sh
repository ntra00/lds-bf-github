#!/bin/bash

#curl metaproxy or run yaz for a singleton

mv loads/* batchload/
chmod 775 batchload/*


CURDIR=`echo $PWD`



TODAY=`date +%Y-%m-%d`

 echo "load date  = $TODAY"


MLCPPATH=/marklogic/id/id-prep/mlcp/bin
PASSWD=`/marklogic/id/id-prep/marc/keys/passwd-ml.sh`



echo not sure how to pass overwrite
echo not sure how to deal with deletes
 
 $MLCPPATH/mlcp.sh import  \
 	    -host localhost \
        -port 8203 \
        -username id-admin \
        -password $PASSWD \
		-input_file_path /marklogic/id/natlibcat/admin/bfi/bibrecs/batchload \
		-output_uri_replace "/marklogic/id/natlibcat/admin/bfi/bibrecs/batchload/,''"  \
		-output_collections /bibframe-process/,/processing/load/bibs/$TODAY/,/bibframe-process/yaz-reload/ \
		-output_permissions lc_read,read,lc_read,execute,id-admin-role,update,lc_xmlsh,update \
   		-input_file_type documents \
		-transform_module /admin/bfi/bibrecs/corb-bibframe-process-yazbib-files.xqy \
		-transform_namespace "http://loc.gov/ndmso/marc-2-bibframe-yaz/" \
		-document_type xml \
		-aggregate_record_element RDF \
    	-aggregate_record_namespace http://www.w3.org/1999/02/22-rdf-syntax-ns# \
        -mode local 

echo this 
mv batchload/* loaded/
