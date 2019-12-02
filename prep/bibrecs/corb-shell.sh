#!/bin/bash
# generic corb runner
# USAGE example

# 						code/uris xqy  changecode   logging file              [background]
# 						=============  =======  =========================  ==
# nohup ./corb-shell.sh c-add-colls   reload     			[> ../logs/c-add-colls.log] [ampersand]
# nohup ./corb-shell.sh c-add-colls          			[> ../logs/c-add-colls.log] [ampersand] implies process-bib-files.xqy

# if  changecode, = reload then corb-bibframe-process-bib-files.xqy (ie reload)

#
#(expects c-add-colls.xqy, c-add-colls-uris.xqy)
# database is natlibcat by default



#
# This performs a CORB update for any xqy and uri set, passed in as $1  
#
# IMPORTANT: leave no stray blanks beyond "\" at the end of each line.
# Parameters as follows:
#	Classname
#	XCC URI
#	ML Collection
#	XQUERY-MODULE = module that will actually do the work
# 	Threads
# 	URI-MODULE - MODULE that exports URIs for updating
#	module root - try /marklogic/id/id-prep/ is 8282 root
# 	module database, use 0 for filesystem
# 	INSTALL - have no idea what this means, set to false.
 # xcc://id:pw@mlvlp04.loc.gov:port/ \
 
#set dirs etc:
source config bibrecs

CHANGEURIS="$1-uris.xqy"
CHANGECODE=$2
COLLECTIONS="/processing/$1/" 



if [ "$CHANGECODE" != "reload" ]
then
 	CHANGECODE="batchupdates/$1.xqy" 
 else 
	 CHANGECODE="corb-bibframe-process-bib-files.xqy"
 fi

#echo "$CORBPATH/marklogic-xcc-8.0-5.jar  xcc://$BFDB_XCC_USER:BFDB_XCC_PASS@BFDB_HOST:BFDB_PORT/ ? $COLLECTIONS : $CHANGECODE  | $THREADS : $CHANGEURIS"

java   -Xmx32G  -XX:+UseConcMarkSweepGC -cp $CORBPATH/marklogic-xcc-8.0-5.jar:$CORBPATH/corb.jar \
   com.marklogic.developer.corb.Manager \
   xcc://$BFDB_XCC_USER:$BFDB_XCC_PASS@$BFDB_HOST:$BFDB_XCC_PORT/  \
   $COLLECTIONS \
   $CHANGECODE \
   $THREADS \
   $CHANGEURIS \
   /prep/bibrecs/batchupdates/ \
   0 \
   false


