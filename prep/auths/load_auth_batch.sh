#!/bin/bash
# this is written for idmain on localhost to nlc localhost 8282 to 8082?
# test of mlcp copy from nametitles madsrdf in id-main to natlibcat bf works
# daily load files: find nametitles and titles loaded to id=main today in the names file.
# if you want to load a specific  day, 2017-07-01 on command line

#8282 is  id-main xdbc
# try 8082for id-main

#8203 is natlibcat xdbc
# 8203 transform uses file system, not Modules database; load to /admin/bfi/auths/authorities2bf.xqy
#				          /marklogic/id/natlibcat/admin/bfi/auths/ admin/bfi/auths/authorities2bf.xqy

# 8203 /marklogic/id/natlibcat/

# added collection to nametitles and titles (/authorities/bfworks/)

# ex: nohup ./load_nametitles_mlcp.sh [optional day yyyy-mm-dd defaults to today] > ../logs/nametitles2works.log 

# from id-main:    -output_permissions id-admin-role,update,id-admin-role,insert,id-user-role,read,id-admin-role,read \
# expects id-main to have /processing/load/bfworks/[today, ie., YYYY-MM-DD]/

# run config and set the directgory to /marklogic/applications/nate/lds/lds-bf/prep/auths

source ../config auths


TODAY=$1 
 if [ -n "$TODAY" ]
 then
 	TODAY=$TODAY
 else
    TODAY=`date +%Y-%m-%d`
 fi

CURDIR=`echo $PWD`

echo $TODAY ...

filter="sed 's|YYYY-MM-DD|${TODAY}|g' < auth_daily_query_filter.default > auth_daily_query_filter.txt"

eval ${filter}


#filter='-query_filter 
#<cts:and-query xmlns:cts="http://marklogic.com/cts">	<cts:collection-query>		<cts:uri>/processing/load_names/${TODAY}/</cts:uri>	</cts:collection-query>	<cts:or-query>		<cts:element-value-query>			<cts:element xmlns:idx="info:lc/xq-modules/lcindex">idx:memberOfURI</cts:element>			<cts:text xml:lang="en">http://id.loc.gov/authorities/names/collection_FRBRWork</cts:text>		</cts:element-value-query>		<cts:element-value-query>			<cts:element xmlns:idx="info:lc/xq-modules/lcindex">idx:memberOfURI</cts:element>			<cts:text xml:lang="en">http://id.loc.gov/authorities/names/collection_FRBRExpression</cts:text>		</cts:element-value-query>	</cts:or-query></cts:and-query>' 

#MLCPPATH=/marklogic/id/id-prep/mlcp/bin
#PASSWD=`/marklogic/id/id-prep/marc/keys/passwd-ml.sh`


echo loading files from id-main name titles  $TODAY
 
 $MLCPPATH/mlcp.sh copy  \
        -input_host localhost \
        -input_port $ID_XCC_PORT \
        -input_username $ID_XCC_USER \
        -input_password $ID_XCC_PASS \
		-collection_filter /processing/load_names/$TODAY/ \
		-options_file  auth_daily_query_filter.txt \
		-transform_module /prep/auths/authorities2bf.xqy \
		-transform_namespace "http://loc.gov/ndmso/authorities-2-bibframe" \
        -output_host localhost \
        -output_port $BFDB_XCC_PORT \
        -output_username $BFDB_XCC_USER \
        -output_password $BFDB_XCC_PASS \
		-output_collections /authorities/bfworks/,/resources/works/,/processing/load_bfworks/$TODAY/,/catalog/,/lscoll/lcdb/,/lscoll/lcdb/works/,/bibframe/hubworks/ \
		-copy_collections false \
        -copy_properties false \
		-output_permissions lc_xmlsh,update,id-user-role,read \
        -thread_count $THREADS \
        -mode local

cd $CURDIR
echo any errors? look  in ../logs/rel.auth.txt

cat /var/opt/MarkLogic/Logs/ErrorLog.txt|grep auth|grep error| wc -l
cat /var/opt/MarkLogic/Logs/ErrorLog.txt|grep auth|grep error |cut -d ";" -f2| cut -d " " -f5 |sort |uniq> ../logs/rel.auth.txt


#four0fours=$(cat ../logs/rel.auth.txt|grep ^n |wc -l)
four0fours=0
if [[ $four0fours > 0 ]]; then

echo "Found 404s; reloading"
cd  /marklogic/id/natlibcat/admin/bfi/bibrecs/
 while read x;
  do
  sleep .1
	./post-auth.sh $x
  echo $x
  done < ../logs/rel.auth.txt


else
        echo No 404s.
fi



