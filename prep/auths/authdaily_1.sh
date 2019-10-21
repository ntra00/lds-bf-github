#!/bin/bash

#daily auths: already in marcxml

# split to 250, formc, convert to rdf

# set to yesterday unless date is passed in: (ILS records have yesterdays' date
# getils runs at 1am
# from bibdaily_1.sh but basically bibdaily2, yaz converion

# runs for yesterday unless date yyy-mm-dd is passed in as parameter 1

#AUTH2BFDIR=/marklogic/id/auth2bibframe2

AUTH2BFDIR=/marklogic/id/natlibcat/admin/bfi/auths/auth2bibframe2

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
cd /marklogic/id/natlibcat/admin/bfi/auths
#symlink the days voyager output here:
for f in $(ls /marklogic/id/lds-id/prep/marc-auth/names/load/processed/AUTH.ML.*$filedate*a.xml) 
do
 ln -s $f .
done
for f in $(ls /marklogic/id/lds-id/prep/marc-auth/names/load/processed/AUTH.ML.*$filedate*d.xml) 
do
 ln -s $f .
done

#ls -l *$filedate*
#echo $filedate=filedate

# First break up the large MARC 2709 files into smaller chunks, 250 per file.  Still 2709. 
# Convert from marc8 encoding to UTF-8. Save with a prefix of "split_".  They will write to the same directory as the large 2709 files.
adds='AUTH.ML.D'
suffix="a.xml"
echo $adds$filedate$suffix
ls -l $adds$filedate$suffix

for mrc in $(ls $adds$filedate$suffix)
	do
	echo $mrc : $filedate
		cd auths_daily
		directory=$YESTERDAY
		mkdir $directory
		chmod -R 775  $directory > /dev/null
		chgrp marklogic $directory > /dev/null
		cd $directory
		mkdir A
		chmod -R 775 A > /dev/null
		chgrp marklogic A > /dev/null
		cd A
			xsltproc  /marklogic/id/natlibcat/admin/bfi/auths/modules/get-marcxml.xsl ../../../$mrc > ../../../$mrc.collection.xml
echo about to split:
			yaz-marcdump -f utf8 -t utf8 -C 250 -s split_ ../../../$mrc.collection.xml 
echo done split
ls -l split*

		for f in split*
		do
		 	
#			uconv -f utf8 -t utf8 -x nfc -c --from-callback skip --to-callback skip  < $f   > $f.1.tmp
			
	
#  sed -e "s|\[from old catalog\]||g" < $f.1.tmp  >$mrc_$f.xml

	 sed -e "s|\[from old catalog\]||g" < $f  >$mrc_$f.xml

	 yaz-record-conv  $AUTH2BFDIR/auths-conv.xml  $mrc_$f.xml > $f.tmp.rdf 

	   		 sed -e "s|idwebvlp03.loc.gov|id.loc.gov|g" <$f.tmp.rdf >$f.tmp.1.rdf
			 sed -e "s|mlvlp04.loc.gov:8080|id.loc.gov|g" <$f.tmp.1.rdf >$f.tmp.2.rdf
			 sed -e "s|//mlvlp06.loc.gov:8288|http://id.loc.gov|g" < $f.tmp.2.rdf  > $f.tmp.3.rdf

			 xsltproc  /marklogic/id/natlibcat/admin/bfi/auths/modules/graphiphy.xsl  $f.tmp.3.rdf   > $f.rdf

	 
#			rm $f.tmp
			rm $f
			rm *tmp*

			chmod -R  775  * > /dev/null
		    chgrp marklogic * > /dev/null

		done
		cd ../..
done
for mrc in $(ls deleted.bib.marc.$filedated.xml) 
	do
	echo $mrc
		
		directory=$YESTERDAY
		mkdir $directory
		chmod -R 775 $directory > /dev/null
		chgrp marklogic $directory > /dev/null
		cd $directory
		mkdir D
		chmod -R  775  D > /dev/null
		chgrp marklogic D > /dev/null
		cd D
		yaz-marcdump -f utf8 -t utf8 -C 250 -s split_ ../../$mrc > /dev/null  

		for f in split*
		do

		 	
			yaz-record-conv  $M2BFDIR/record-conv.vlp3.xml  $f > $f.tmp.rdf 
			 xsltproc  /marklogic/id/natlibcat/admin/bfi/bibrecs/modules/graphiphy.xsl  $f.tmp.rdf   > $f.rdf
            rm *tmp*
#			rm $f.tmp*.rdf
			rm $f
			
		    chmod -R  775  * > /dev/null
	        chgrp marklogic * > /dev/null

		done
		cd ../..
done
