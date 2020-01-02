#!/bin/bash
# USAGE example
# ./corb-bibs-bulk-load-cleanup.sh 
#
# This performs a CORB update: 
# 		Process bib files takes stuff from inside the database /bibframe-process/records/[bibid], converts, matches, merges, stores work, instance, item
#
# this finds all that wasn't loaded in the main bibs-bulk-load for  whatever reason

TODAY=`date +%Y-%m-%d`
PASSWD=`/marklogic/id/id-prep/marc/keys/passwd-ml.sh`

echo "
xquery version '1.0-ml';
(:  process everything not in collection cts:collection-query("/bibframe-process/reloads/2017-09-16/")
:   started at $TODAY
:)
	let \$uris := 
	 cts:uris(
        '/lscoll/lcdb/works/',
        (),
        cts:not-query((
            cts:collection-query('/bibframe-process/reloads/2017-09-16/')            
        ))
    )
    let \$uris:=
        for \$u in \$uris
            let \$uri:=fn:tokenize(\$u,'/')[fn:last()]
            let \$uri:=fn:concat('/bibframe-process/records/', fn:replace(\$uri,'^c0+',''))
            return \$uri
    
	return (fn:count(\$uris) , \$uris)

" > corb-auto-bibs-bulk-process-uris.xqy

java -cp ../corb/marklogic-xcc-8.0-5.jar:../corb/corb.jar \
  com.marklogic.developer.corb.Manager \
  xcc://id-admin:$PASSWD@localhost:8203/ \
  "" \
  corb-bibframe-process-bib-files.xqy \
  12 \
  corb-auto-bibs-bulk-process-uris.xqy \
  admin/bfi/bibrecs/ \
  0 \
  false

