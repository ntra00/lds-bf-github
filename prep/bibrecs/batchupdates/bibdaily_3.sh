#!/bin/bash
# 2017 10/3 nate changed install to TRUE
#PRODUCTION DAILY LOAD called by marklogic cron
# USAGE example
# ./corb-bibs-daily-process-bib-files.sh 2017-07-01 (if blank, today)

#
# This performs a CORB update: 
# 		Process bib files takes stuff from inside the database /bibframe-process/records/[bibid], converts, matches, merges, stores work, instance, item
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

CORBDIR=/marklogic/applications/id-prep/corb

TODAY=$1
 if [[ -n "$TODAY" ]]
 then
        TODAY=$TODAY
 else
        TODAY=`date +%Y-%m-%d`
 fi
 echo "today = $TODAY"

OVERWRITE=$2
if [ -n "$OVERWRITE" ]
 then
        OVERWRITE=$OVERWRITE
 else        
	
		OVERWRITE=""
fi


echo $TODAY
echo "
xquery version '1.0-ml';

	let \$uris := cts:uris((),(),cts:collection-query('/bibframe-process/load_splitmarcxml/$TODAY/'))
	return (fn:count(\$uris) , \$uris)

" > corb-auto-bibs-daily-process-uris.xqy

PASSWD=`/marklogic/id/id-prep/marc/keys/passwd-ml.sh`


java -server -cp $CORBDIR/marklogic-xcc-8.0-5.jar:$CORBDIR/marklogic-corb-2.3.2.jar \
	-DXCC-CONNECTION-URI=xcc://id-admin:$PASSWD@localhost:8203 \
	-DTHREAD-COUNT=4 \
	-DURIS-MODULE=admin/bfi/bibrecs/corb-auto-bibs-daily-process-uris.xqy \
	-DPROCESS-MODULE=admin/bfi/bibrecs/corb-bibframe-process-bib-files.xqy \
	-DPROCESS-MODULE.OVERWRITE=$OVERWRITE \
	-DMODULES-ROOT=admin/bfi/bibrecs/ \
	com.marklogic.developer.corb.Manager

echo "bibdaily_3 done (nonyazload)... ok to run bibdaily4 (yazload)"
