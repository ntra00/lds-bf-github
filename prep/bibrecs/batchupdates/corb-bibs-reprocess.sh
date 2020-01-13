#!/bin/bash

# USAGE example
# ./corb-bibframe-reprocess.sh [uris.xqy]


#
# This performs a CORB update: 
# 		Process bib files takes stuff from insid the database /bibframe-process/records/[bibid], converts, matches, merges, stores work, instance, item
# substitute any uris file
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
# 	INSTALL - whether the local modules should be deployed into the modules database for evaluation and execution; true means they get deployed into MarkLogic. 
NUM=$1
PASSWD=`/marklogic/id/id-prep/marc/keys/passwd-ml.sh`
echo $PASSWD
# corb-bibframe-store-bib-files.xqy
# was corb-bibframe-process-bib-files.xqy
# changed back to process for bf2, 2017 05
# corb-bibframe-process-uris.xqy \
# corb-bibs-reprocess-instance-uris.xqy \

### corb-bibs-reprocess-uris.xqy \


java -cp ../corb/marklogic-xcc-8.0-5.jar:../corb/corb.jar \
  com.marklogic.developer.corb.Manager \
  xcc://id-admin:$PASSWD@localhost:8203/ \
  "" \
  corb-bibframe-process-bib-files.xqy \
  24 \
  $1 \
  admin/bfi/bibrecs/ \
  0 \
  false
