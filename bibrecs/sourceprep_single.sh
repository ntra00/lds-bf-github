#!/bin/bash
# rbi does convert, load. Use rbc a bunch of times then one rbl to load them

#curl metaproxy or run yaz for a single bib record

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
