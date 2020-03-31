#!/bin/bash

#curl metaproxy or run yaz for a batch of nametitles to upload

#rm singleload/*
 curl "https://lccn.loc.gov/$1/marcxml" > source/$1.tmp
 sed -e "s|\[from old catalog\]||g" < source/$1.tmp  > source/$1.xml
  /marklogic/applications/natlibcat/admin/bfi/utf-nf.1.0.2.pl -NFC < source/$1.xml > source/$12.xml

 rm source/$1.tmp


CURDIR=`echo $PWD`


  M2BFDIR=/marklogic/id/marc2bibframe2
     yaz-record-conv  $M2BFDIR/record-conv.xml  $CURDIR/source/$12.xml >$CURDIR/loads/$1.rdf
rm $CURDIR/source/$1.*

sleep 1
ls -l  source/$1*


