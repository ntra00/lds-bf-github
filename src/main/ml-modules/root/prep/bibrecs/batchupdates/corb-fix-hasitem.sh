#!/bin/bash

# USAGE example
# ./corb-bbfe load testsh

#
# This performs a CORB update: 
# 		bf:hasItem has attribute rdf:about, should be rdf:resource

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
 CORBPATH=/marklogic/id/corb
java -cp $CORBPATH/marklogic-xcc-8.0-5.jar:$CORBPATH/corb.jar \
  com.marklogic.developer.corb.Manager \
  xcc://id-admin:$PASSWD@localhost:8203/ \
  "" \
  corb-fix-hasitem.xqy \
  4 \
  corb-fix-hasitem-uris.xqy \
  admin/bfi/bibrecs/ \
  0 \
  false
