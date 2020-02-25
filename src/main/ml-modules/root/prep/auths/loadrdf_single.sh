#!/bin/bash
#          /marklogic/id/natlibcat/admin/bfi/auths/authorities2bf.xqy

#only loads whatevers in single, using yaz
# ex: nohup ./load_auth_single.sh 


source  /marklogic/id/lds-bf-github/src/main/ml-modules/root/prep/config auths
TODAY=`date +%Y-%m-%d`


CURDIR=`echo $PWD`

echo loading whatever is in  $LOAD_UNPROCESSED/single:

ls -l $LOAD_UNPROCESSED/single/$LCCN*

echo loading from file system at   $LOAD_UNPROCESSED/single/$LCCN.rdf, using $BFDB_XCC_PORT  

# CHANGE TO VIA MODULES PORT??
# BFDB_XCC_VIAMODULES_PORT=8203
#  -port $BFDB_XCC_PORT \
#-port $BFDB_XCC_VIAMODULES_PORT \
 $MLCPPATH/mlcp.sh import  \
	-host localhost \
          -port $BFDB_XCC_PORT \
        -username $BFDB_XCC_USER \
        -password $BFDB_XCC_PASS \
	-input_file_path $LOAD_UNPROCESSED/single \
	-output_uri_replace "$LOAD_UNPROCESSED/single,''"  \
	-transform_module /prep/auths/authorities-yaz2bf.xqy \
	-transform_namespace "http://loc.gov/ndmso/authorities-yaz-2-bibframe" \
	-output_collections /authorities/bfworks/,/resources/works/,/processing/load_bfworks/$TODAY/,/catalog/,/lscoll/lcdb/works/,/authorities/yazbfworks/,/bibframe/hubworks/ \
        -output_permissions lc_xmlsh,update,id-user-role,read \
        -thread_count $THREADS \
        -mode local 

cd $CURDIR
echo moved to $LOAD_PROCESSED
mv  $LOAD_UNPROCESSED/single/* $LOAD_PROCESSED/single/
