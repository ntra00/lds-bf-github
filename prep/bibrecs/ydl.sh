#!/bin/bash


#records are already rdf when loaded to database, after yaz process, in "yazdailyloads and yazdailydeletes" directory.


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

echo "$YESTERDAY is only for batch date; this loads the yazdaily directory. Is that bad?"

echo "then process deletes: change the ingest program to look for  d in leader, remove from catalog"
echo loading files from loads dir in rdf for:  $YESTERDAY

THREADS=3
MLCPPATH=/marklogic/id/id-prep/mlcp/bin
PASSWD=`/marklogic/id/id-prep/marc/keys/passwd-ml.sh`

#corb-bibframe-process-yazbib-files.xqy


LOAD_UNPROCESSED=yazdailyloads/
for file in $(ls $LOAD_UNPROCESSED | grep .xml); do
	echo $file
loadpath=$LOAD_UNPROCESSED$file
echo $loadpath

 cd $CURDIR
echo "yaz daily loads for $YESTERDAY starting:"


 #      -aggregate_record_element local \
  #      -aggregate_record_namespace http://id.loc.gov/ontologies/lclocal/ \
#  -input_file_path /marklogic/id/natlibcat/admin/bfi/bibrecs/yazdailyloads \
#  -input_file_path /marklogic/id/natlibcat/admin/bfi/bibrecs/$loadpath \
 $MLCPPATH/mlcp.sh import  \
 	    -host localhost \
        -port 8203 \
        -username id-admin \
        -password $PASSWD \
           -input_file_path /marklogic/id/natlibcat/admin/bfi/bibrecs/$loadpath \
		-output_uri_replace "/marklogic/id/natlibcat/admin/bfi/bibrecs/yazdailyloads/,''"  \
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
done
	
echo "done ydl for  $YESTERDAY "
cat ../logs/ydl.log | grep split |cut -d ":" -f5|sort|uniq



