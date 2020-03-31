#!/bin/bash

# USAGE example
# ./corb-find-and-reload.sh mxe:datafield_100 twain

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

 	let \$uris:=cts:uris((), (),  
 		cts:element-query(xs:QName( '$field' ), '$value' )
 	)
	let \$uris:=
        	for \$i in \$uris
	          let \$bibid:=fn:replace(fn:tokenize(\$i,'/')[fn:last()],'^c0+','')
          return concat('/bibframe-process/records/',\$bibid)
          let \$ct:=(count(\$uris))

 	return (xdmp:log(fn:concat('CORB find-reload ',\$ct,' uris for ','$field','= ', '$value'),'info'),
			  (count(\$uris),\$uris)
		)
 " > corb-find-and-reload-uris.xqy
 
 chmod 775 corb-find-and-reload-uris.xqy
 chgrp marklogic corb-find-and-reload-uris.xqy

PASSWD=`/marklogic/id/id-prep/marc/keys/passwd-ml.sh`

 java -cp ../corb/marklogic-xcc-8.0-5.jar:../corb/corb.jar \
   com.marklogic.developer.corb.Manager \
   xcc://id-admin:$PASSWD@localhost:8203/ \
   "" \
   corb-bibframe-process-bib-files.xqy \
  16 \
  corb-find-and-reload-uris.xqy \
  admin/bfi/bibrecs/ \
  0 \
  false


