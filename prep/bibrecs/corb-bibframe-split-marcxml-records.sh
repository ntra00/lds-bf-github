#!/bin/bash

# This performs a CORB update
#
# Parameters as follows:
#	Classname
#	XCC URI
#	ML Collection
#	XQUERY-MODULE = module that will actually do the work
# 	Threads
# 	URI-MODULE - MODULE that exports URIs for updating
#	module root - directory where uris.xqy is found
# 	module database, use 0 for filesystem
# 	INSTALL - whether the local modules should be deployed into the modules database for evaluation and execution; true means they get deployed into MarkLogic. 

USER="id-admin"
PASSWD=""
PASSWD=`/marklogic/id/id-prep/marc/keys/passwd-ml.sh`
#split the 1000 records in /bibframe/process into singletons 



java -cp ../corb/marklogic-xcc-8.0-5.jar:../corb/corb.jar \
  com.marklogic.developer.corb.Manager \
  xcc://$USER:$PASSWD@localhost:8203/ \
  "" \
  corb-bibframe-split-marcxml-records.xqy \
  8 \
  corb-bf-store-uris.xqy \
  admin/bfi/bibrecs/ \
  0 \
  false
