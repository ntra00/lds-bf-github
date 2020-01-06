!/bin/bash

# during testing, just converting one day's chunked marcxml; no symlinking etc.
# no loading, but handles deletes
#daily bibs:
i think we're using bibyazdaily prep, not this.; has no sed for tmp uris mlvlp04 etc


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

echo date

#filedate=$(echo $YESTERDAY | cut -c3-10)
echo $filedate

echo $filedate=filedate
cd /marklogic/id/natlibcat/admin/bfi/bibrecs/bibs_daily


ls -l *$filedate*
echo $filedate=filedate

# records are already marcxml chunked; cleaned, uconved will need to add that after catchup


# currently just taking the split files from the other process; that process still stores records inside database in bibid sequence.
	
directory=$YESTERDAY
rm yazdailyloads/*		
rm yazdailydeletes/*		
cd $CURDIR/bibs_daily/$YESTERDAY/A/

		for f in *.xml
		do			
		 	yaz-record-conv  $M2BFDIR/record-conv.vlp3.xml  $f > $f.tmp.rdf
			uconv -f utf8 -t utf8 -x nfc -c --from-callback skip --to-callback skip  < $f.tmp.rdf   > $f.tmp2.rdf
			xsltproc  /marklogic/id/natlibcat/admin/bfi/bibrecs/modules/graphiphy.xsl  $f.tmp2.rdf  > $f.rdf


			chmod 775 $f.rdf 
			chgrp marklogic $f.rdf
			
		done
		echo "done with A"
		echo "starting D"

cd $CURDIR/bibs_daily/$YESTERDAY/D/
pwd
		for f in *.xml
			
		do	
			echo $f		
		 	yaz-record-conv  $M2BFDIR/record-conv.deletions.xml  $f > $f.tmp.rdf 
			xsltproc  /marklogic/id/natlibcat/admin/bfi/bibrecs/modules/graphiphy.xsl  $f.tmp.rdf  > $f.rdf

			chmod 775 $f.rdf 
			chgrp marklogic $f.rdf
			
		done
echo "next, daily yaz load only for $YESTERDAY"


 

