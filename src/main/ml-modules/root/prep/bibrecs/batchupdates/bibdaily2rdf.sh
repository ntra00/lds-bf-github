#!/bin/bash
************************
is this obsolete? not modified from admin/bfi/bibrecs
************************
#daily bibs:
# cp /marklogic/opt/marcdump/bib/BIB.ML.D170522 .
# cp /marklogic/opt/marcdump/deletedbibs/deleted.bib.marc.170522 .

#convert to markcxml, formc, ingest to /bibframe/chunks/[yesterday]? or just directly store to /bibframe/process/records/

#process deletes: if type=d, find instance and drop the "catalog" collection
#process adds:
#move ? 

# set to yesterday unless date is passed in: (ILS records have yesterdays' date
#

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

#`date +%Y%m%d | cut -c3-10`
cd /marklogic/id/natlibcat/admin/bfi/bibrecs/bibs_daily

ls -l *$filedate*
echo $filedate=filedate


#---------------------- marc2bf ---------------------------------------------#
# go back to bibs_daily/date/A and D, convert to rdf for bibyazload
cd /marklogic/id/natlibcat/admin/bfi/bibrecs/bibs_daily


for mrc in $(ls BIB.ML.D$filedate) 
	do
	echo $mrc
		
		directory=$YESTERDAY
		#$directory > /dev/null
		cd $directory
		
		cd A

		for f in split*.xml
		do
	 
			 yaz-record-conv  $M2BFDIR/record-conv.vlp3.xml  $f > $f.tmp.rdf 

		     sed -e "s|idwebvlp03.loc.gov|id.loc.gov|g" <$f.tmp.rdf >$f.tmp.1.rdf
			 sed -e "s|mlvlp04.loc.gov:8080|id.loc.gov|g" <$f.tmp.1.rdf >$f.tmp.2.rdf
			 sed -e "s|//mlvlp06.loc.gov:8288|http://id.loc.gov|g" < $f.tmp.2.rdf  > $f.tmp.3.rdf

			 xsltproc  /marklogic/id/natlibcat/admin/bfi/bibrecs/modules/graphiphy.xsl  $f.tmp.3.rdf   > $f.rdf

			rm *tmp*
#			rm $f
#			rm $f*tmp*

			chmod -R  775  * > /dev/null
		    chgrp marklogic * > /dev/null

		done
		cd ../..
done
for mrc in $(ls deleted.bib.marc.$filedate) 
	do
	echo $mrc
		
		directory=$YESTERDAY
		
		cd $directory
		
		cd D		

		for f in split*.xml
		do
			yaz-record-conv  $M2BFDIR/record-conv.vlp3.xml  $f > $f.tmp.rdf 
			 xsltproc  /marklogic/id/natlibcat/admin/bfi/bibrecs/modules/graphiphy.xsl  $f.tmp.rdf   > $f.rdf
			rm *tmp*

#			rm $f.tmp*.rdf
#			rm $f
			
		    chmod -R  775  * > /dev/null
	        chgrp marklogic * > /dev/null

		done
		cd ../..
done
