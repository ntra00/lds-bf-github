#!/bin/bash

# USAGE example
# ./corb-bfe loadtest.sh

#
# This performs a CORB update: 
# 		Process bfe payload like a bib import without merging
#ib files takes stuff from insid the database /bibframe-process/records/[bibid], converts, matches, merges, stores work, instance, item
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
java -cp ../corb/marklogic-xcc-8.0-5.jar:../corb/corb.jar \
  com.marklogic.developer.corb.Manager \
  xcc://id-admin:$PASSWD@localhost:8203/ \
  "" \
  x.check this.natesbfe2mets.xqy \
  8 \
  corb-bfe-load-uris.xqy \
  admin/bfi/bibrecs/ \
  0 \
  false
