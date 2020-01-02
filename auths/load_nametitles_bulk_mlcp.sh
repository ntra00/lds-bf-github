#!/bin/bash
# this is written for idmain on localhost to nlc localhost 8282 to 8082?
# test of mlcp copy from nametitles madsrdf in id-main to natlibcat bf works
# full load files

# change back to all collection: /authorities/bfworks/ before running. Also, collection "bfworks/Title"  is as of 7/24/17 unless updated!!

#8282 is  id-main xdbc
#8203 is natlibcat xdbc
# 8203 transform uses Modules database; load to /admin/bfi/authoirties2bf.xqy

echo check the collections; this is an old program
read x

# added collection to nametitles and titles (/authorities/bfworks/)

# ex: nohup ./load_nametitles_mlcp.sh 10 > ../logs/nametitles2works.log 

# from id-main:    -output_permissions id-admin-role,update,id-admin-role,insert,id-user-role,read,id-admin-role,read \

THREADS=$1
 
 if [ -n "$THREADS" ]
 then
 	THREADS=$THREADS
 else
 	THREADS=4
 fi

CURDIR=`echo $PWD`
MLCPPATH=/marklogic/id/id-prep/mlcp/bin
PASSWD=`/marklogic/id/id-prep/marc/keys/passwd-ml.sh`

#transforms only work in a Modules database, not the file system!!!
TODAY=`date +%Y-%m-%d`
     
echo "loading files from id-main name titles (all)  $TODAY"
# titles only:/authorities/bfworks/Title/ 
# change back to all before running. Also, collection Title  is as of 7/24/17 unless updated!!
# all :  /authorities/bfworks/
# 2018-12-17; all are superworks /bibframe/hubworks/

 $MLCPPATH/mlcp.sh copy  \
        -input_host localhost \
        -input_port 8282 \
        -input_username id-admin \
        -input_password $PASSWD \
        -collection_filter /authorities/bfworks/  \
	-transform_module /admin/bfi/auths/authorities2bf.xqy \
	-transform_namespace http://loc.gov/ndmso/authorities-2-bibframe \
	-transform_function transform-and-overwrite \
	-output_host localhost \
        -output_port 8203 \
        -output_username id-admin \
        -output_password $PASSWD \
	-output_collections /authorities/bfworks/,/resources/works/,/processing/load/bfworks/$TODAY/,/catalog/,/lscoll/lcdb/,/lscoll/,/catalog/,/catalog/lscoll/,/catalog/lscoll/lcdb/,/catalog/lscoll/lcdb/works/,/bibframe/hubworks/ \
	-copy_collections false \
        -copy_properties false \
	-output_permissions lc_xmlsh,update,id-user-role,read\
        -thread_count $THREADS \
        -mode local \

cd $CURDIR



