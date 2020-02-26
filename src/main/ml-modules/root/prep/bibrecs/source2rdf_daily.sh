#!/bin/bash

#daily bibs2 (convert to rdf using yaz)

#process deletes: if type=d, find instance and drop the "catalog" collection
#process adds:
#move ? 

# set to yesterday unless date is passed in: (ILS records have yesterdays date)

source /marklogic/id/lds-bf-github/src/main/ml-modules/root/config bibrecs

CURDIR=`echo $PWD`



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


echo $filedate=filedate

#---------------------- marc2bf ---------------------------------------------#
# go back to source/unprocessedbibs_daily/date/A and D, convert to rdf for bibyazload
#cd /marklogic/id/natlibcat/admin/bfi/bibrecs/bibs_daily

cd $SOURCE_UNPROCESSED/$YESTERDAY/A


		for f in split*.xml
		do
			echo "now converting $f	 "
			 yaz-record-conv  $M2BFDIR/record-conv.vlp3.xml  $f > $f.tmp.rdf 

	   		 sed -e "s|idwebvlp03.loc.gov|id.loc.gov|g" <$f.tmp.rdf >$f.tmp.1.rdf
			 sed -e "s|mlvlp04.loc.gov:8080|id.loc.gov|g" <$f.tmp.1.rdf >$f.tmp.2.rdf
			 sed -e "s|//mlvlp06.loc.gov:8288|http://id.loc.gov|g" < $f.tmp.2.rdf  > $f.tmp.3.rdf

			 xsltproc  $MODULES/graphiphy.xsl  $f.tmp.3.rdf    > $f.rdf


			rm *tmp*

			chmod  775  * > /dev/null
		    chgrp marklogic * > /dev/null

		done

echo "finished with adds, starting deletes"

cd $CURDIR/source/unprocessed/$YESTERDAY/D
date



		for f in split*.xml
		do
			yaz-record-conv  $M2BFDIR/record-conv.vlp3.xml  $f > $f.tmp.rdf 
			 xsltproc  $MODULES/graphiphy.xsl  $f.tmp.rdf   > $f.rdf
			rm *tmp*

			
		    chmod   775  * > /dev/null
	        chgrp marklogic * > /dev/null

		done
	
	cd $CURDIR

echo "done yaz conversion of marcxml to bibframe, look for rdf in $SOURCE_PROCESSED/$YESTERDAY"
mv $SOURCE_UNPROCESSED/$YESTERDAY $SOURCE_PROCESSED/$YESTERDAY
