#!/bin/bash


#records are already rdf when loaded to database, after yaz process, in "yazdailyloads and yazdailydeletes" directory.

cd  /marklogic/id/natlibcat/admin/bfi/bibrecs/

CURDIR=`echo $PWD`


M2BFDIR=/marklogic/id/marc2bibframe2

YESTERDAY=$1 
 if [[ -n "$YESTERDAY" ]]
 then
 	YESTERDAY=$YESTERDAY
 else
# 	TODAY=`date +%Y-%m-%d`
	YESTERDAY=`date +%Y-%m-%d -d "1 day ago"`
 fi
 echo "load date  = $YESTERDAY"
yr=$(echo $YESTERDAY | cut -c3-4)
mon=$(echo $YESTERDAY | cut -c6-7)
day=$(echo $YESTERDAY | cut -c9-10)
filedate=$yr$mon$day

#filedate=$(echo $YESTERDAY | cut -c3-10)
echo $filedate

echo $filedate=filedate

echo "$YESTERDAY is only for batch date; this loads the yazdaily directory.bad if you forgot to enter the date parameter."

echo "then process deletes:  remove from catalog"
echo loading files from loads dir in rdf for:  $YESTERDAY

THREADS=4
MLCPPATH=/marklogic/id/id-prep/mlcp/bin
PASSWD=`/marklogic/id/id-prep/marc/keys/passwd-ml.sh`

#corb-bibframe-process-yazbib-files.xqy

rm  /marklogic/id/natlibcat/admin/bfi/bibrecs/yazdailyloads/*
rm /marklogic/id/natlibcat/admin/bfi/bibrecs/yazdailydeletes/*

cp /marklogic/id/natlibcat/admin/bfi/bibrecs/bibs_daily/$YESTERDAY/A/*.rdf   /marklogic/id/natlibcat/admin/bfi/bibrecs/yazdailyloads
cp /marklogic/id/natlibcat/admin/bfi/bibrecs/bibs_daily/$YESTERDAY/D/*.rdf   /marklogic/id/natlibcat/admin/bfi/bibrecs/yazdailydeletes

     chmod -R  775  yazdailyloads/* > /dev/null
     chgrp marklogic yazdailyloads/* > /dev/null

     chmod -R  775  yazdailydeletes/* > /dev/null
     chgrp marklogic yazdailydeletes/* > /dev/null


 cd $CURDIR
echo "yaz daily loads for $YESTERDAY starting:"


#	-aggregate_record_element local \
 #       -aggregate_record_namespace http://id.loc.gov/ontologies/lclocal/ \


echo running each split file separately so there are no errors:

LOAD_UNPROCESSED=yazdailyloads/
ls -l $LOAD_UNPROCESSED

for file in $(ls $LOAD_UNPROCESSED | grep .xml); do
        echo $file
loadpath=$LOAD_UNPROCESSED$file
echo $loadpath
#   -input_file_path /marklogic/id/natlibcat/admin/bfi/bibrecs/yazdailyloads \



 $MLCPPATH/mlcp.sh import  \
 	    -host localhost \
        -port 8203 \
        -username id-admin \
        -password $PASSWD \
		-input_file_path /marklogic/id/natlibcat/admin/bfi/bibrecs/$loadpath \
		-output_uri_replace "/marklogic/id/natlibcat/admin/bfi/bibrecs/yazdailyloads/,''"  \
		-output_collections /bibframe-process/,/processing/load/bibs/$YESTERDAY/,/bibframe-process/yaz-reload/ \
		-output_permissions lc_read,read,lc_read,execute,id-admin-role,update,lc_xmlsh,update \
   		-input_file_type documents \
		-transform_module /admin/bfi/bibrecs/corb-bibframe-process-yazbib-files.xqy \
		-transform_namespace "http://loc.gov/ndmso/marc-2-bibframe-yaz/" \
		-document_type xml \
        -aggregate_record_element RDF \
        -aggregate_record_namespace http://www.w3.org/1999/02/22-rdf-syntax-ns# \
        -thread_count $THREADS \
        -mode local

done

		echo "deletes for $YESTERDAY starting:"


$MLCPPATH/mlcp.sh import  \
 	    -host localhost \
        -port 8203 \
        -username id-admin \
        -password $PASSWD \
		-input_file_path /marklogic/id/natlibcat/admin/bfi/bibrecs/yazdailydeletes \
		-output_uri_replace "/marklogic/id/natlibcat/admin/bfi/bibrecs/yazdailydeletes/,''"  \
		-output_collections /bibframe-process/,/processing/load/bibs/$YESTERDAY/ \
		-output_permissions lc_read,read,lc_read,execute,id-admin-role,update,lc_xmlsh,update \
   		-input_file_type documents \
		-transform_module /admin/bfi/bibrecs/corb-bibframe-process-yazbib-files.xqy \
		-transform_namespace "http://loc.gov/ndmso/marc-2-bibframe-yaz/" \
		-document_type xml \
		-aggregate_record_element RDF \
    	-aggregate_record_namespace http://www.w3.org/1999/02/22-rdf-syntax-ns# \
        -thread_count $THREADS \
        -mode local
echo rdfxml done
echo  checking urls posted

./daysload-check.sh $YESTERDAY
echo done daily4 ingest of yazzed bibs to bf database
yr=$(echo $YESTERDAY | cut -c3-4)
mon=$(echo $YESTERDAY | cut -c6-7)
day=$(echo $YESTERDAY | cut -c9-10)
filedate=$yr$mon$day

cat  ../logs/bibdaily_4$filedate.log |grep split  |cut -d ':' -f5|sort
chmod 775 yazdailyloads/*


