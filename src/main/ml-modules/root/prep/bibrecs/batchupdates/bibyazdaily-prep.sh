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

for f in $(ls /marklogic/opt/marcdump/bib/*$filedate*) 
do
 ln -s $f .
done

ls -l *$filedate*
echo $filedate=filedate

# records are already marcxml chunked; will need to add that after catchup

# First break up the large MARC 2709 files into smaller chunks, 1000 per file.  Still 2709. 
# Convert from marc8 encoding to UTF-8. Save with a prefix of "split_".  They will write to the same directory as the large 2709 files.

# currently just taking the split files from the other process; that process still stores records inside database in bibid sequence.
for mrc in $(ls BIB.ML.D$filedate) 
	do
	echo $mrc
		
		directory=$YESTERDAY
		mkdir $directory
		chmod -R 775  $directory
		chgrp marklogic $directory
		cd $directory
		mkdir A
		chmod -R 775 A
		chgrp marklogic A
		cd A
		yaz-marcdump -f utf8 -t utf8 -C 500 -s split_ ../../$mrc > /dev/null  

		for f in split*
		do
		 	yaz-marcdump  -i marc -o marcxml $f  > $f.tmp 
			# changed from utf-nf perl script to uconv 11/30/18
			#/marklogic/applications/natlibcat/admin/bfi/utf-nf.1.0.2.pl -NFC < $f.tmp  | xmllint --format --encode UTF-8 - > $mrc_$f.1.tmp
			
			uconv -f utf8 -t utf8 -x nfc -c --from-callback skip --to-callback skip  < $f.tmp   > $mrc_$f.1.tmp
	
			#remove [from old catalog]:

	 		sed -e "s|\[from old catalog\]||g" < $mrc_$f.1.tmp  >$mrc_$f.xml

			rm $f.tmp
			rm $f.1.tmp
			rm $f

		done
		cd ../..
done
for mrc in $(ls deleted.bib.marc.$filedate) 
	do
	echo $mrc
		
		directory=$YESTERDAY
		mkdir $directory
		chmod -R 775 $directory
		chgrp marklogic $directory
		cd $directory
		mkdir D
		chmod -R  775  D
		chgrp marklogic D
		cd D
		yaz-marcdump -f utf8 -t utf8 -C 1000 -s split_ ../../$mrc > /dev/null  

		for f in split*
		do

		 	yaz-marcdump  -i marc -o marcxml $f  > $f.xml
			#no need to uconv deletions!
			#/marklogic/applications/natlibcat/admin/bfi/utf-nf.1.0.2.pl -NFC < $f.tmp  | xmllint --format --encode UTF-8 - > $mrc_$f.xml

			rm $f.tmp
			rm $f

		done
		cd ../..
done

cd $CURDIR/bibs_daily/$YESTERDAY/A/
splits=$(ls -l | wc -l)

	for f in *
		do			
		echo " yaz conversion for $f ($splits files) "
		 	#yaz-record-conv  $M2BFDIR/record-conv.xml  $f  >> $CURDIR/../logs/lookups.$filedate.log 2>&1 > $CURDIR/yazdailyloads/$f.rdf 			
			
			yaz-record-conv  $M2BFDIR/record-conv.vlp3.xml  $f >  $CURDIR/yazdailyloads/$f.tmp.rdf
			sed -e "s|idwebvlcp03.loc.gov|id.loc.gov|g"  $CURDIR/yazdailyloads/$f.tmp.rdf >  $CURDIR/yazdailyloads/$f.tmp2.rdf 
			sed -e "s|mlvlp04.loc.gov:8080|id.loc.gov|g" $CURDIR/yazdailyloads/$f.tmp2.rdf > $CURDIR/yazdailyloads/$f.tmp3.rdf 

	 		xsltproc  /marklogic/id/natlibcat/admin/bfi/bibrecs/modules/graphiphy.xsl  $f.tmp3.rdf   > $f.rdf

			rm $CURDIR/yazdailyloads/$f.tmp*
		done
echo "converting deletes.."
cd $CURDIR/bibs_daily/$YESTERDAY/D/
splits=$(ls -l | wc -l)

	for f in *
		do			
		echo " yaz conversion for $f ($splits files) "
		 	#yaz-record-conv  $M2BFDIR/record-conv.xml  $f  >> $CURDIR/../logs/lookups.$filedate.log 2>&1 > $CURDIR/yazdailyloads/$f.rdf 			
			
			yaz-record-conv  $M2BFDIR/record-conv.deletions.xml  $f >  $CURDIR/yazdailyloads/$f.tmp.rdf
			#sed -e "s|idwebvlcp03.loc.gov|id.loc.gov|g"  $CURDIR/yazdailyloads/$f.tmp.rdf >  $CURDIR/yazdailyloads/$f.tmp2.rdf 
			#sed -e "s|mlvlp04.loc.gov:8080|id.loc.gov|g" $CURDIR/yazdailyloads/$f.tmp2.rdf > $CURDIR/yazdailyloads/$f.tmp3.rdf 
			xsltproc  /marklogic/id/natlibcat/admin/bfi/bibrecs/modules/graphiphy.xsl  $f.tmp.rdf   > $f.rdf

			rm $CURDIR/yazdailyloads/$f.tmp*
		done



echo "bib yaz load only.sh "

