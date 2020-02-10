#!/bin/bash

#loads all the singles in load/unprocessed/single

# ex: nohup ./load_bib_yaz.sh 


source ../config bibrecs

CURDIR=`echo $PWD`

TODAY=`date +%Y-%m-%d`

echo loading from  $LOAD_UNPROCESSED/single/*

#ls -l  $LOAD_UNPROCESSED/single/*
if [ -z "$(ls -A  $LOAD_UNPROCESSED/single/)" ]; then
   echo "Empty"
echo nothing in   $LOAD_UNPROCESSED/single/*  to load

else

ct=$(ls -l  $LOAD_UNPROCESSED/single/*|wc -l)
echo $ct files starting

 $MLCPPATH/mlcp.sh import  \
	-host localhost \
        -port $BFDB_XCC_PORT \
        -username $BFDB_XCC_USER \
        -password $BFDB_XCC_PASS \
		-input_file_path $LOAD_UNPROCESSED/single \
		-output_uri_replace "$LOAD_UNPROCESSED/single,''"  \
		-transform_module /prep/bibrecs/corb-bibframe-process-yazbib-files.xqy \
		-transform_namespace "http://loc.gov/ndmso/marc-2-bibframe-yaz/" \
 		-output_collections /authorities/bfworks/,/resources/works/,/processing/load_bfworks/$TODAY/,/catalog/,/lscoll/lcdb/works/,/authorities/yazbfworks/,/bibframe/hubworks/ \
        -output_permissions lc_xmlsh,update,id-user-role,read \
        -thread_count $THREADS \
        -mode local 

cd $CURDIR
echo "--------------"
ls -l $LOAD_UNPROCESSED/single/*
echo 
echo "--------------"

mv  $LOAD_UNPROCESSED/single/* $LOAD_PROCESSED/single
ls -l $LOAD_PROCESSED/single/* |wc -l

fi
