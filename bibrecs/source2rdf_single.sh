#!/bin/bash
# convert a single bib record to rdf

 yaz-record-conv  $M2BFDIR/record-conv.vlp3.xml  $SOURCE_UNPROCESSED/single/$ID.xml | sed -e "s|idwebvlp03.loc.gov|id.loc.gov|g" | sed -e "s|mlvlp04.loc.gov:8080|id.loc.gov|g"  > $SOURCE_UNPROCESSED/single/$ID.tmp.rdf

 xsltproc $MODULES/graphiphy.xsl  $SOURCE_UNPROCESSED/single/$ID.tmp.rdf  > $SOURCE_PROCESSED/single/$ID.rdf

rm  $SOURCE_UNPROCESSED/single/$ID.tmp.rdf
chmod 775 $SOURCE_PROCESSED/single/$ID*
chgrp marklogic $SOURCE_PROCESSED/single/$ID*

echo loadrdf_single.sh run by watch-singles-i.sh every 3 mins is looking in source/processed/single

rm $SOURCE_UNPROCESSED/single/$ID*

