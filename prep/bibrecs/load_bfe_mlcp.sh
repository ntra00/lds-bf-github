#!/bin/bash
# this is written for ingesting from the bfe editor
# it runs every minute under "marklogic"
# use rapper and cat to look for known errors, copy files to appropriate directories
# send editor json error messages (valid files get their own from the xquery during load)

# 8203 transform uses   /admin/bfi/bibrecs/modules/bfe2mets.xqy
# ex:  ./load_bfe_mlcp.sh 

CURDIR=/marklogic/id/natlibcat/admin/bfi/bibrecs
cd $CURDIR

BFEDIR=/marklogic/bibliomata/recto/resources/
cd $BFEDIR
ct=$(find -maxdepth 1 -mtime 0 -type f | wc -l)
#ct=1
# if there are any records in the editor "save" directory:
if [[  $ct > 0 ]]
 then

THREADS=4

MLCPPATH=/marklogic/id/id-prep/mlcp/bin
PASSWD=`/marklogic/id/id-prep/marc/keys/passwd-ml.sh`
ERRORDIR=$CURDIR/bfe-preprocess/errors/
ZERODIR=$CURDIR/bfe-preprocess/zero/
WARNDIR=$CURDIR/bfe-preprocess/warn/
VALIDDIR=$CURDIR/bfe-preprocess/valid
MISCDIR=$CURDIR/bfe-preprocess/misc/

#rm  $CURDIR/bfe-preprocess/*.rdf
#rm $ZERODIR*.rdf
#rm $WARNDIR*.rdf
#rm $ERRORDIR*.rdf
#rm $VALIDDIR/*.rdf
#rm $MISCDIR*.rdf

echo "==========================="
echo "Processing $ct records in bfe" 
echo "==========================="
#only today:
for f in $(find -maxdepth 1  -mtime 0  -type f)

#do all:
# for f in $(find -maxdepth 1 -type f)
#do 23 days worth
# for f in $(find -maxdepth 1  -mtime -30  -type f)

do

#echo starting $f >>  $CURDIR/bfe-preprocess/log.txt
#	zero=$(rapper -i rdfxml -o ntriples $f -c 	2>&1 | grep " 0 triples" | wc -l)
#	warning=$(rapper -i rdfxml -o ntriples $f -c  2>&1 | grep "rapper: Warning" |grep -v "Unicode Normal Form C" |wc -l)
#	error=$(rapper -i rdfxml -o ntriples $f  -c   2>&1 | grep "rapper: Error" | wc -l)
#	vocab1=$(cat $f   | grep "bibframe.org/vocab" | wc -l)
#	rdfdesc=$(cat $f  | grep "rdf:Description" | wc -l)
		
				
    nodeID=$(echo $f| cut -d "/" -f2| cut -d "." -f1)
	dirname="valid"
	lookfor=""
	
	if [[ -f $VALIDDIR/posted/$f ]]; then
		echo "posted, skipping: " $f
		dirname="valid posted"
		else 
			  zero=$(rapper -i rdfxml -o ntriples $f -c       2>&1 | grep " 0 triples" | wc -l)
			  warning=$(rapper -i rdfxml -o ntriples $f -c  2>&1 | grep "rapper: Warning" |grep -v "Unicode Normal Form C" |wc -l)
		      error=$(rapper -i rdfxml -o ntriples $f  -c   2>&1 | grep "rapper: Error" | wc -l)
			  vocab1=$(cat $f   | grep "bibframe.org/vocab" | wc -l)
			  rdfdesc=$(cat $f  | grep "rdf:Description" | wc -l)
            
			# echo `date` ":$f" >> $CURDIR/bfe-preprocess/log.txt
			
			if [[ $warning != 0 ]];
			 then
				echo Warning:  $f 
				dirname=$WARNDIR
				lookfor="rapper: Warning"		    	
			
			else if [[ $error != 0 ]];
				 then
					echo Error:  $f  
					dirname=$ERRORDIR		
					lookfor="rapper: Error"
											
				 else if [[ $zero != 0 ]];
					 then
						echo zero triples:  $f 					
						lookfor="Parsing returned 0 triples"
						dirname=$ZERODIR
			                    
				 else if [[ $vocab1 != 0 ]] ;
				       then
        		            echo vocab1 used:  $f
	                	    dirname=$MISCDIR                       	                
							lookfor="bibframe.org"          
						#else if [[ $rdfdesc != 0 ]] ; then 
						 #   echo rdfdescription:  $f
				          #           dirname=$MISCDIR
			    	       #        	    lookfor="rdf:Description found"
					    else 
							echo valid: $f		
							dirname=$VALIDDIR/source						
						# fi # rdf:Description found, or valid?
				fi #vocab1 used?
			fi # zero triples?
				
		fi # is it an error ?
	fi # is it a warning?
	# this happens to all but posted (errors + valid)
	echo copying
	cp $f $dirname
fi # was it already posted
	
	ERRMSG=""
	if [[ $dirname != *"valid"* ]];
	 then	
		      if [[ $lookfor == "bibframe.org" ]] ;
			   then
					ERRMSG="vocab1 used"
				else if [[ $lookfor == "rdf:Description found" ]] ;
					then
						ERRMSG="rdf:Description found"
					else
			  			ERRMSG=$(rapper -i rdfxml -o ntriples $f  -c 2>&1  | grep "$lookfor")						
					fi
			  fi

		      json='{"name": "'$nodeID'","objid": "resources.works.'$nodeID'","publish": {"status": "error","message": "'$ERRMSG'"}}'
			  echo `date` $json >> $CURDIR/bfe-preprocess/log.txt
			  curl -X POST -H "Content-Type: application/json" -d "$json" http://mlvlp04.loc.gov:3000/profile-edit/server/publishRsp			  
    fi # some error found 

done

chmod -R 775  $CURDIR/bfe-preprocess/*/*
chgrp -R marklogic $CURDIR/bfe-preprocess/*/*
cd $VALIDDIR/source
postingct=$(find -maxdepth 1 -mtime 0 -type f | wc -l)



if [[  $postingct > 0 ]]
 then
	cd $CURDIR
	echo loading files from bfe

	$MLCPPATH/mlcp.sh import  \
        -host mlvlp04.loc.gov \
        -port 8203 \
        -username id-admin \
        -password $PASSWD \
		-input_file_path $VALIDDIR/source/ \
		-input_file_pattern '.*\.rdf' \
		-output_uri_replace "/marklogic/applications/natlibcat/admin/bfi/bibrecs/bfe-preprocess/valid/source/,''"  \
		-output_permissions lc_read,read,lc_read,execute,id-admin-role,update,lc_xmlsh,update \
    	-input_file_type documents \
		-document_type XML \
		-transform_module /admin/bfi/bibrecs/modules/bfe2mets.xqy \
		-transform_function transform \
	    -transform_namespace http://loc.gov/ndmso/bfe-2-mets \
        -thread_count $THREADS 

	mv $VALIDDIR/source/* $VALIDDIR/posted/       

fi # any records valid?

fi # any records published? 

cd $CURDIR
