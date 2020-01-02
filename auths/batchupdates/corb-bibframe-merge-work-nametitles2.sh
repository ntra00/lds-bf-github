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
# 	INSTALL - whether the local modules should be deployed into the modules database for evaluation and execution; true means they get deployed into MarkLogic. 


# corb-bibframe-store-bib-files.xqy
# was corb-bibframe-process-bib-files.xqy
 
java -cp ../corb_updates/lib/xcc.jar:../corb_updates/lib/corb.jar \
  com.marklogic.developer.corb.Manager \
  xcc://id-admin:111888-USER-admin@localhost:8282/ \
  "" \
   corb-bibframe-merge-work-nametitles2.xqy  \
  30 \
  corb-bibframe-hash-work-nametitles-uris.xqy \
  bfi/ \
  0 \
  false


