#!/bin/bash

# USAGE example
# ./from-old-catalog.sh

#
# This performs a CORB update based on a search dynamically generated
# 1 is the field, 2 is the value (mxe:datafield_100 twain)

field=$1
value=$2
uris="$uris"

echo "xquery version '1.0-ml';
		declare namespace mxe  = 'http://www.loc.gov/mxe';
		declare namespace idx  = 'info:lc/xq-modules/lcindex';
		declare namespace bf   = 'http://id.loc.gov/ontologies/bibframe/';
		declare namespace bflc = 'http://id.loc.gov/ontologies/bflc/';

let \$batch:='/bibframe-process/2017-01-11-update/'

let \$uris:=cts:uris(
        	'/lscoll/lcdb/works/',
        	(),
        	 cts:and-not-query(
                                        cts:and-query((
                                        cts:word-query('from old catalog'),
                                        cts:collection-query('/bibframe/notMerged/')
                                        ))
                                  ,
                                        cts:collection-query(\$batch)
                                ) 
			)


	let \$uris:=
        	for \$i in \$uris
	          let \$bibid:=fn:replace(fn:tokenize(\$i,'/')[fn:last()],'^c0+','')
          return concat('/bibframe-process/records/',\$bibid)
          let \$ct:=(count(\$uris))

 	return (xdmp:log(fn:concat('CORB fromoldcat ',\$ct,' uris started'),'info'),
			  (count(\$uris),\$uris)
		)
 " > from-old-cat-uris.xqy
 
 chmod 775 from-old-cat-uris.xqy
 chgrp marklogic from-old-cat-uris.xqy

PASSWD=`/marklogic/id/id-prep/marc/keys/passwd-ml.sh`

 java -cp ../corb/marklogic-xcc-8.0-5.jar:../corb/corb.jar \
   com.marklogic.developer.corb.Manager \
   xcc://id-admin:$PASSWD@localhost:8203/ \
   "" \
   corb-bibframe-process-bib-files.xqy \
  16 \
  from-old-cat-uris.xqy \
  admin/bfi/bibrecs/ \
  0 \
  false


