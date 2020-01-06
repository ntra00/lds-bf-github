#!/bin/bash
uses singleload; do not use

read x
#curl metaproxy or run yaz for a singleton

rm singleload/$1

BIBID=$2
if [[ $BIBID != "bibid" ]]; then
 

#this is an lccn
	curl "https://lccn.loc.gov/$1/marcxml" > source/$1.tmp
 else
  
  	curl "http://lx2.loc.gov:210/LCDB?query=rec.id=$1&recordSchema=bibframe2a&maximumRecords=1" >  source/$1.tmp
fi

 sed -e "s|\[from old catalog\]||g" < source/$1.tmp  > source/$1.xml
  /marklogic/applications/natlibcat/admin/bfi/utf-nf.1.0.2.pl -NFC < source/$1.xml > source/$12.xml

# rm source/$1.tmp

#daily bibs:
# cp /marklogic/opt/marcdump/bib/BIB.ML.D170522 .
# cp /marklogic/opt/marcdump/deletedbibs/deleted.bib.marc.170522 .


CURDIR=`echo $PWD`

if [[ $BIBID != "bibid" ]]; then
  	M2BFDIR=/marklogic/id/marc2bibframe2
    yaz-record-conv  $M2BFDIR/record-conv.xml  $CURDIR/source/$12.xml >$CURDIR/singleload/$1.rdf
else
	mv  source/$12.xml singleload/$1.rdf
fi

#rm $CURDIR/source/$1.*

TODAY=`date +%Y-%m-%d`

 echo "load date  = $TODAY"


MLCPPATH=/marklogic/id/id-prep/mlcp/bin
PASSWD=`/marklogic/id/id-prep/marc/keys/passwd-ml.sh`


#-input_file_pattern *\.rdf \

echo not sure how to pass overwrite
echo not sure how to deal with deletes
 
 $MLCPPATH/mlcp.sh import  \
 	    -host localhost \
        -port 8203 \
        -username id-admin \
        -password $PASSWD \
		-input_file_path /marklogic/id/natlibcat/admin/bfi/bibrecs/singleload \
		-output_uri_replace "/marklogic/id/natlibcat/admin/bfi/bibrecs/singleload/,''"  \
		-output_collections /bibframe-process/,/processing/load/bibs/$TODAY/,/bibframe-process/yaz-reload/ \
		-output_permissions lc_read,read,lc_read,execute,id-admin-role,update,lc_xmlsh,update \
   		-input_file_type documents \
		-transform_module /admin/bfi/bibrecs/corb-bibframe-process-yazbib-files.xqy \
		-transform_namespace "http://loc.gov/ndmso/marc-2-bibframe-yaz/" \
		-document_type xml \
		-aggregate_record_element RDF \
    	-aggregate_record_namespace http://www.w3.org/1999/02/22-rdf-syntax-ns# \
        -mode local 

echo this 
