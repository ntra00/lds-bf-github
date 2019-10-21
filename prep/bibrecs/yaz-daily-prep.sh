#!/bin/bash


#daily bibs:
# cp /marklogic/opt/marcdump/bib/BIB.ML.D170522 .
# cp /marklogic/opt/marcdump/deletedbibs/deleted.bib.marc.170522 .

#records are already rdf when loaded to database, after yaz process
# no handling of deletes. probably need to ingest this process before the deletes in the main process.


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
cd /marklogic/id/natlibcat/admin/bfi/bibrecs/bibs_daily
#symlink the days voyager output here:

ls -l *$filedate*
echo $filedate=filedate

# records are already marcxml chunked; will need to add that after catchup

# First break up the large MARC 2709 files into smaller chunks, 1000 per file.  Still 2709. 
# Convert from marc8 encoding to UTF-8. Save with a prefix of "split_".  They will write to the same directory as the large 2709 files.

# currently just taking the split files from the other process; that process still stores records inside database in bibid sequence.
	
directory=$YESTERDAY
rm loads/*		
cd $CURDIR/bibs_daily/$YESTERDAY/A/

		for f in *
		do			
		 	yaz-record-conv  $M2BFDIR/record-conv.vlp3.xml  $f > $CURDIR/loads/$f.rdf 
			
		done

echo "next, daily adds ingest to /bibframe-process/records with batch name"
echo "then process deletes: change the ingest program to look for  d in leader, remove from catalog"
echo loading files from id-main name titles  $YESTERDAY
 

