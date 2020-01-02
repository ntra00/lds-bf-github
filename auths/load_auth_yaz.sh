#!/bin/bash
#          /marklogic/id/natlibcat/admin/bfi/auths/authorities2bf.xqy


# ex: nohup ./load_auth_yaz.sh [lccn] 

./rnc $1
#-0------------------------------
	#source ../config auths
	#TODAY=`date +%Y-%m-%d`

	#LCCN=$1 

	#CURDIR=`echo $PWD`
	#echo TEMPORARILY USING ID instead of IDWEBVLP03 for marcxml:
	#curl -L http://id.loc.gov/authorities/names/$LCCN.marcxml.xml > $SOURCE_UNPROCESSED/single/$LCCN.xml

	#chmod 775 $SOURCE_UNPROCESSED/single/$LCCN*    > /dev/null
	#chgrp marklogic $SOURCE_UNPROCESSED/single/$LCCN* > /dev/null

	#yaz-record-conv $AUTH2BFDIR/auths-conv.xml $SOURCE_UNPROCESSED/single/$LCCN.xml |  sed -e "s|idwebvlcp03.loc.gov|id.loc.gov|g" | sed -e "s|mlvlp04.loc.gov:8080|id.loc.gov|g" >$LOAD_UNPROCESSED/$LCCN.rdf

	#chmod -R 775 $LOAD_UNPROCESSED/single/$LCCN* > /dev/null
	#chgrp -R marklogic  $LOAD_UNPROCESSED/single/$LCCN* > /dev/null

	#ls -l $LOAD_UNPROCESSED/single/$LCCN*
#-0------------------------------
./load_auth_single.sh

#-0------------------------------

		#echo loading from id-main name titles  $LOAD_UNPROCESSED/single/$LCCN.rdf


		 #$MLCPPATH/mlcp.sh import  \
		#	-host mlvlp04.loc.gov \
		#        -port $BFDB_XCC_PORT \
		#        -username $BFDB_XCC_USER \
		#        -password $BFDB_XCC_PASS \
		#		-input_file_path $LOAD_UNPROCESSED/single \
		#		-output_uri_replace "$LOAD_UNPROCESSED/single,''"  \
		#		-transform_module /prep/auths/authorities-yaz2bf.xqy \
		#		-transform_namespace "http://loc.gov/ndmso/authorities-yaz-2-bibframe" \
		# 		-output_collections /authorities/bfworks/,/resources/works/,/processing/load_bfworks/$TODAY/,/catalog/,/lscoll/lcdb/works/,/authorities/yazbfworks/,/bibframe/hubworks/ \
		#        -output_permissions lc_xmlsh,update,id-user-role,read \
		#        -thread_count $THREADS \
		#        -mode local 


		#  mv  $LOAD_UNPROCESSED/single/$LCCN* $LOAD_PROCESSED/single/

cd $CURDIR