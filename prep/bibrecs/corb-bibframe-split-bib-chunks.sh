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
#	module root - directory wher uris.xqy is found
# 	module database, use 0 for filesystem
# 	INSTALL - whether the local modules should be deployed into the modules database for evaluation and execution; true means they get deployed into MarkLogic. 

# used to either split all the catalog records (bulk) or the dailies (a and d) or a specific date
# tests using the mudule executor tool:
# https://github.com/marklogic-community/corb2/wiki/ModuleExecutor-Tool
## USAGE:     ./corb-bibframe-split-bib-chunks.sh daily A
## USAGE:     ./corb-bibframe-split-bib-chunks.sh daily D
## USAGE:     ./corb-bibframe-split-bib-chunks.sh bulk 
## USAGE:     ./corb-bibframe-split-bib-chunks.sh 2017-06-23 A
## USAGE:     ./corb-bibframe-split-bib-chunks.sh 2017-06-23 D


USER="id-admin"
PASSWD=""
PASSWD=`/marklogic/id/id-prep/marc/keys/passwd-ml.sh`
#split the 1000 records in /bibframe/process into singletons 

LOADTYPE=$1
BIBTYPE=$2


if [[ $LOADTYPE == "bulk" ]]; then
	
	URISFILE=corb-bf-store-uris.xqy
	BATCHDATE=""
	TYPE=""
	
	else if [[ $LOADTYPE == "today" ]]; then

		TODAY=`date +%Y-%m-%d`

		URISFILE="corb-bf-daily-uris.xqy"
		BATCHDATE="-DURIS-MODULE.BATCHDATE=$TODAY"
		TYPE=-DURIS-MODULE.BIBTYPE=$BIBTYPE
		
		else if [[ $LOADTYPE == 20* ]]; then
				# manually entered date				
				URISFILE="corb-bf-daily-uris.xqy"
				BATCHDATE="-DURIS-MODULE.BATCHDATE=$LOADTYPE"
				TYPE="-DURIS-MODULE.BIBTYPE=$BIBTYPE"
			else
				echo $LOADTYPE
			fi
	fi
fi

###=======================

		 	
		java -cp ../corb/marklogic-corb-2.3.2.jar:../corb/marklogic-xcc-8.0-5.jar $BATCHDATE  $TYPE \
			com.marklogic.developer.corb.Manager \
	        xcc://$USER:$PASSWD@localhost:8203/ \
	  		"" \
			corb-bibframe-split-marcxml-records.xqy \
			8 \
			$URISFILE \
			admin/bfi/bibrecs/ \
			0 \
  			false 

					
		echo done $LOADTYPE
