#!/bin/bash
# this is written for idmain on localhost to ldx localhost 8282 to 8203
#  mlcp copy from nametitles madsrdf in id-main to natlibcat bf works, for a given lccn /authorities/names/[lccn].xml


#8282 is  id-main xdbc
#8203 is natlibcat xdbc
# 8203 transform uses file system, not Modules database; load to /admin/bfi/auths/authorities2bf.xqy
#				          /marklogic/id/natlibcat/admin/bfi/auths/ admin/bfi/auths/authorities2bf.xqy

# 8203 /marklogic/id/natlibcat/


# ex: nohup ./load_nametitles_lccn_mlcp.sh [lccn] > ../logs/nametitles2works.[lccn].log 

  TODAY=`date +%Y-%m-%d`

THREADS=4

LCCN=$1 
rm  /marklogic/id/natlibcat/admin/bfi/auths/lccn/authorities/names/*
 
CURDIR=`echo $PWD`
MLCPPATH=/marklogic/id/id-prep/mlcp/bin
PASSWD=`/marklogic/id/id-prep/marc/keys/passwd-ml.sh`
curl -L http://mlvlp04.loc.gov:8081/authorities/names/$LCCN.mets.xml > lccn/authorities/names/$LCCN.xml
#curl -L http://id.loc.gov/authorities/names/$LCCN.mets.xml > lccn/authorities/names/$LCCN.xml


echo loading from id-main name titles  lccn/$LCCN
#read n 
 $MLCPPATH/mlcp.sh import  \
	-host localhost \
        -port 8203 \
        -username id-admin \
        -password $PASSWD \
	-input_file_path /marklogic/id/natlibcat/admin/bfi/auths/lccn/authorities/names \
	-output_uri_replace "/marklogic/id/natlibcat/admin/bfi/auths/lccn,''"  \
	-transform_module /admin/bfi/auths/authorities2bf.xqy \
	-transform_namespace "http://loc.gov/ndmso/authorities-2-bibframe" \ 	
	-output_collections /authorities/bfworks/,/resources/works/,/processing/load_bfworks/$TODAY/,/catalog/,/lscoll/lcdb/,/lscoll/lcdb/works/,/bibframe/hubworks/ \
        -output_permissions lc_xmlsh,update,id-user-role,read \
        -thread_count $THREADS \
        -mode local 

cd $CURDIR
#  -output_permissions id-admin-role,update,id-admin-role,insert,id-user-role,read,id-admin-role,read \
