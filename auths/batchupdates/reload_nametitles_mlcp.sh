#!/bin/bash
# this is written for idmain on localhost to nlc localhost 8282 to 8082?
# daily load files: find nametitles and titles loaded to id=main today in the names file.
# if you want to load a specific  day, 2017-07-01 on command line
# this will not load over the top of something; it's only a back-fill on error, written to reload stuff missing from 2017-04-02 specifically
#8282 is  id-main xdbc
#8203 is natlibcat xdbc
# 8203 transform uses file system, not Modules database; load to /admin/bfi/auths/authorities2bf.xqy
#				          /marklogic/id/natlibcat/admin/bfi/auths/ admin/bfi/auths/authorities2bf.xqy

# 8203 /marklogic/id/natlibcat/

# added collection to nametitles and titles (/authorities/bfworks/)

# ex: nohup ./load_nametitles_mlcp.sh [optional day yyyy-mm-dd defaults to today] > ../logs/nametitles2works.log 

# from id-main:    -output_permissions id-admin-role,update,id-admin-role,insert,id-user-role,read,id-admin-role,read \
# expects id-main to have /processing/load/bfworks/[today, ie., YYYY-MM-DD]/



THREADS=4

TODAY=$1 
 if [ -n "$TODAY" ]
 then
 	TODAY=$TODAY
 else
    TODAY=`date +%Y-%m-%d`
 fi

CURDIR=`echo $PWD`
MLCPPATH=/marklogic/id/id-prep/mlcp/bin
PASSWD=`/marklogic/id/id-prep/marc/keys/passwd-ml.sh`
#-options_file auth_daily_query_filter.txt \
#/processing/load_names/2017-06-14/
#test

echo loading files from id-main name titles  $TODAY
 
 $MLCPPATH/mlcp.sh copy  \
        -input_host localhost \
        -input_port 8282 \
        -input_username id-admin \
        -input_password $PASSWD \
		-collection_filter /processing/load_names/$TODAY/ \
		-transform_module /admin/bfi/auths/authorities2bf-missingonly.xqy \
		-transform_namespace "http://loc.gov/ndmso/authorities-2-bibframe" \
        -output_host localhost \
        -output_port 8203 \
        -output_username id-admin \
        -output_password $PASSWD \
        -output_collections /resources/works/,/authorities/bfworks/,/processing/load_bfworks/$TODAY/,/catalog/,/lscoll/lcdb/,/lscoll/,/catalog/lscoll/,/catalog/lscoll/lcdb/,/catalog/lscoll/lcdb/works/ \
	   -copy_collections false \
        -copy_properties false \
	   -output_permissions lc_xmlsh,update,id-user-role,read \
        -thread_count $THREADS \
        -mode local \

cd $CURDIR
#  -output_permissions id-admin-role,update,id-admin-role,insert,id-user-role,read,id-admin-role,read \


