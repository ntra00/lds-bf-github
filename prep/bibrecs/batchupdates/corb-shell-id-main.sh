#!/bin/bash
# generic corb runner
# USAGE example
# 						code/uris xqy  threads  logging file              [background]
# 						=============  =======  =========================  ==
# nohup ./corb-shell.sh c-add-colls     [ 10 ]    [> ../logs/c-add-colls.log] [ampersand]
#
# threads will default to 4 if ommitted, logging is also optional as is background

#
#(expects c-add-colls.xqy, c-add-colls-uris.xqy)
# database is natlibcat by default
#To use this code as  a template, 
#	set the batch and the query in the batchupdates/*uris file,
##	use the same batch in the main xqy code ,
#	Modify the code in local:fix(), but keep the timestamp update.
#	Decide if your fix means you have to recalculate the idx and/or the sem triples
#	replace what's new
#	The logging and adding to collections stays the same. If you have to run this more than once, it will exclude the stuff you've already fixed.

#	Figured out how to run it for id-main: put the code and uris in controllers/corb





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
 # xcc://id-admin:111888-USER-admin@mlvlp04.loc.gov:8282/ \
 
 BASEPATH=/marklogic/id/natlibcat/admin/bfi/bibrecs/

 CORBPATH=/marklogic/id/corb
 PASSWD=`/marklogic/id/id-prep/marc/keys/passwd-ml.sh`
 USER=id-admin 

 CHANGECODE="/controllers/corb/$1.xqy"
 CHANGEURIS="/controllers/corb/$1-uris.xqy"
 
 THREADS=$2
 if [ -n "$THREADS" ]
 then
 	THREADS=$THREADS
 else
 	THREADS=4
 fi

#java -cp $CORBPATH/marklogic-xcc-8.0-5.jar:$CORBPATH/corb.jar \
#   com.marklogic.developer.corb.Manager \
#   xcc://$USER:$PASSWD@localhost:8282/id-main  \
#   "" \
#   $CHANGECODE \
#   $THREADS \
#   $CHANGEURIS \
#   /\ 

   #0 \
   #false

   java  -Xmx32G  -XX:+UseConcMarkSweepGC -server -cp $CORBPATH/marklogic-corb-2.3.2.jar:$CORBPATH/marklogic-xcc-8.0-5.jar \
	-DXCC-CONNECTION-URI=xcc://id-admin:$PASSWD@localhost:8082/id-main \
	-DTHREAD-COUNT=$THREADS \
	-DURIS-MODULE=$CHANGEURIS \
	-DPROCESS-MODULE=$CHANGECODE \
com.marklogic.developer.corb.Manager


echo " "
echo " $CHANGECODE ....complete."
echo " "

