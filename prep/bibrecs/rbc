#!/bin/bash
# rbi does convert, load. Use rbc a bunch of times then one rbl to load them

#curl metaproxy or run yaz for a singleton
# usage rbc [bibid#|lccn#] [lccn]
# bib example: ./rbc 5226
#lccn example ./rbi 201902345 lccn

source ../config bibrecs
CURDIR=`echo $PWD`

ID=$1
LCCN=$2
if [[  $LCCN == "" ]]
then
 	curl "http://mlvlp04.loc.gov:8230/resources/bibs/$ID.xml"  | sed -e "s|\[from old catalog\]||g"   > $SOURCE_UNPROCESSED/single/$ID.xml
else
	echo curling permalink for lccn: $lccn/marcxml
	# sru:
	curl -L "https://lccn.loc.gov/$ID/marcxml"    | sed -e "s|\[from old catalog\]||g"   > $SOURCE_UNPROCESSED/single/$ID.xml
	echo "curl -L 'https://lccn.loc.gov/$ID/marcxml'    | sed -e 's|\[from old catalog\]||g'   > $SOURCE_UNPROCESSED/single/$ID.xml"
fi


chmod 775 $SOURCE_UNPROCESSED/single/$ID*
chgrp marklogic $SOURCE_UNPROCESSED/single/$ID*



 yaz-record-conv  $M2BFDIR/record-conv.vlp3.xml  $SOURCE_UNPROCESSED/single/$ID.xml | sed -e "s|idwebvlp03.loc.gov|id.loc.gov|g" | sed -e "s|mlvlp04.loc.gov:8080|id.loc.gov|g"  > $SOURCE_UNPROCESSED/single/$ID.tmp.rdf

 xsltproc $MODULES/graphiphy.xsl  $SOURCE_UNPROCESSED/single/$ID.tmp.rdf  > $SOURCE_PROCESSED/single/$ID.rdf

rm  $SOURCE_UNPROCESSED/single/$ID.tmp.rdf
chmod 775 $SOURCE_PROCESSED/single/$ID*
chgrp marklogic $SOURCE_PROCESSED/single/$ID*

echo load_bib_yaz.sh run by watch-singles-i.sh every 3 mins is looking in source/processed/single

rm $SOURCE_UNPROCESSED/single/$ID*

