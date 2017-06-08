#!/bin/bash

# USAGE example
# ./update_idx.sh 
#
# This performs a CORB update
#
# Parameters as follows:
#	Classname
#	XCC URI
#	ML Collection
#	XQUERY-MODULE = module that will actually do the work
# 	Threads
# 	URI-MODULE - MODULE that exports URIs for updating
#	module root - try /marklogic/id/id-main/
# 	module database, use 0 for filesystem
# 	INSTALL - have no idea what this means, set to false.

cp -f ../../id-main/constants.xqy constants.xqy
# add this back later nate, 20150617!!! cp -f ../../id-main/modules/*.xqy modules/

# add this back later???
#cp -f ../../id-main/constants.xqy ../../id-admin/constants.xqy
#cp -f ../../id-main/modules/*.xqy ../../id-admin/modules/

# echo "Instantiating Related Works file."
# curl -u id\-admin:111888\-USER\-admin http://localhost:8289/process-file-instantiate.xqy
# echo " "

# id-main works: xcc://id-admin:111888-USER-admin@localhost:8282/ "" \
# id-ts works: xcc://id-admin:111888-USER-admin@localhost:8283/ "" \
# idts isnt displaying ok, but works to load
lcml loading??? 

# corb-bf-nametitles-reload-uris.xqy  
 # get-work-uris.xqy is correct;
 # temp use corb-bf-nametitles-reload-uris.xqy for un-relaoded stuff
java -cp ../corb/xcc.jar:../corb/corb.jar \
  com.marklogic.developer.corb.Manager \
  xcc://:111888-USER-admin@localhost:8201/ "" \
  insert-work.xqy 6 \
  get-work-uris.xqy  \
  
  bf-prep/ \
  0 \
  false

# echo "Deduping Related Works file."
# curl -u id\-admin:111888\-USER\-admin http://localhost:8289/process-file-dedup.xqy
# echo " "

# echo "Processing Works file."
# c=1
# while [ $c -lt 1500000 ]
# do
#	curl -u id\-admin:111888\-USER\-admin http://localhost:8289/process-file-inserts.xqy?START=$c
#	c=$[$c+5000]
#done
#echo " "

echo " "
echo "Load complete."
echo " "

