#!/bin/bash
# this is written for idmain on localhost to ldx localhost 8282 to 8203
#  mlcp import after curling out a particular lccn ($1)  from nametitles in id-main

#8203 is natlibcat xdbc
#          /marklogic/id/natlibcat/admin/bfi/auths/authorities2bf.xqy


# ex: nohup ./load_nametitles_yaz.sh [lccn] 

  TODAY=`date +%Y-%m-%d`

THREADS=4

LCCN=$1 

rm  /marklogic/id/natlibcat/admin/bfi/auths/lccn/authorities/names/*
echo consider a whole bunch of yazzes, then a single load
CURDIR=`echo $PWD`
MLCPPATH=/marklogic/id/id-prep/mlcp/bin
PASSWD=`/marklogic/id/id-prep/marc/keys/passwd-ml.sh`
echo TEMPORARILY USING ID instead of IDWEBVLP03 for marcxml:
curl -L http://id.loc.gov/authorities/names/$LCCN.marcxml.xml > in/$LCCN.xml
chmod 775 in/$LCCN*    > /dev/null
chgrp marklogic in/$LCCN* >/dev/null
yaz-record-conv auth2bibframe2/auths-conv.xml in/$LCCN.xml |  sed -e "s|idwebvlcp03.loc.gov|id.loc.gov|g" | sed -e "s|mlvlp04.loc.gov:8080|id.loc.gov|g" >lccn/authorities/names/$LCCN.rdf

chmod -R 775 lccn/authorities/names/ > /dev/null
chgrp -R marklogic  lccn/authorities/names/ > /dev/null
ls -l lccn/authorities/names/$LCCN*
echo loading from id-main name titles  lccn/$LCCN.rdf
#  /admin/bfi/auths/authorities-yaz2bf.xqy calls the main authorities2bf link-and-load, since that starts with a marc record.
 $MLCPPATH/mlcp.sh import  \
	-host mlvlp04.loc.gov \
        -port 8203 \
        -username id-admin \
        -password $PASSWD \
	-input_file_path /marklogic/id/natlibcat/admin/bfi/auths/lccn/authorities/names \
	-output_uri_replace "/marklogic/id/natlibcat/admin/bfi/auths/lccn,''"  \
	-transform_module /admin/bfi/auths/authorities-yaz2bf.xqy \
	-transform_namespace "http://loc.gov/ndmso/authorities-yaz-2-bibframe" \
 	-output_collections /authorities/bfworks/,/resources/works/,/processing/load_bfworks/$TODAY/,/catalog/,/lscoll/lcdb/,/lscoll/lcdb/works/,/authorities/yazbfworks/,/bibframe/hubworks/ \
        -output_permissions lc_xmlsh,update,id-user-role,read \
        -thread_count $THREADS \
        -mode local 

cd $CURDIR
mv  /marklogic/id/natlibcat/admin/bfi/auths/lccn/authorities/names/* loaded
