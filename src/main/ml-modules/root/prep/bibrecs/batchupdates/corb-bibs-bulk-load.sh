#!/bin/bash

# USAGE example
# ./corb-bibs-bulk-load.sh 0 (zero offset array of million bibs at a time )
# 0 to 18 million
# first run the code to get the numbers
#
# This performs a CORB update: 
# 		Process bib files takes stuff from inside the database /bibframe-process/records/[bibid], converts, matches, merges, stores work, instance, item
#

TODAY=`date +%Y-%m-%d`
URISFILE=$1
PASSWD=`/marklogic/id/id-prep/marc/keys/passwd-ml.sh`
#?? echo $PASSWD
#this is as of 2017-09-18: 
SET=(/bibframe-process/records/022.xml
/bibframe-process/records/10935043.xml
/bibframe-process/records/11873946.xml
/bibframe-process/records/12880623.xml
/bibframe-process/records/13909910.xml
/bibframe-process/records/15027732.xml
/bibframe-process/records/16233143.xml
/bibframe-process/records/17444128.xml
/bibframe-process/records/18566273.xml
/bibframe-process/records/19677345.xml
/bibframe-process/records/2632177.xml
/bibframe-process/records/3538110.xml
/bibframe-process/records/4443657.xml
/bibframe-process/records/5352975.xml
/bibframe-process/records/6269905.xml
/bibframe-process/records/7192926.xml
/bibframe-process/records/8118875.xml
/bibframe-process/records/904003.xml
/bibframe-process/records/9966557.xml
)
NUM=$1
BIBURI=${SET[$NUM]}
#if [[ $NUM == "1" ]]; then
#        BIBURI="/bibframe-process/records/022.xml"
#    else if [[ $NUM == "2" ]]; then
#        BIBURI="/bibframe-process/records/10935043.xml"
#    fi
#fi

echo "
xquery version '1.0-ml';
(:  process $NUM, starting at $BIBURI
:   started at $TODAY
:)
	let \$uris := cts:uris('$BIBURI',
	                        ('ascending', 'concurrent', 'limit=1000000'),
	                         cts:collection-query('/bibframe-process/records/')
	                       )
	
	return (fn:count(\$uris) , \$uris)

" > corb-auto-bibs-bulk-process-uris.xqy

java -cp ../corb/marklogic-xcc-8.0-5.jar:../corb/corb.jar \
  com.marklogic.developer.corb.Manager \
  xcc://id-admin:$PASSWD@localhost:8203/ \
  "" \
  corb-bibframe-process-bib-files.xqy \
  8 \
  corb-auto-bibs-bulk-process-uris.xqy \
  admin/bfi/bibrecs/ \
  0 \
  false



