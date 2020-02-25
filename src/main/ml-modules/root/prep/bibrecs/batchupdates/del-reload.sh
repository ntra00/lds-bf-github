#!/bin/bash

#NAMETITLE=$1
# if [[ -n "NAMETITLE" ]]
# then
 #	NAMETITLE=$NAMETITLE
    PASSWD=`/marklogic/id/id-prep/marc/keys/passwd-ml.sh`
    THREADCOUNT=4

    CORBPATH=/marklogic/id/corb        
    CHANGEURIS="batchupdates/del-reload-uris.xqy"
    CHANGECODE="corb-bibframe-process-bib-files.xqy"
    USER=id-admin 
# this searches for  stuff  and deletes it, setting up a list to reload:
       mv bachupdates/reload-uris.xqy batchupdate/reload-uris.old.xqy
	   ./corb-shell.sh del-reload reload

#echo $NAMETITLE    
   
#java   -Xmx32G  -XX:+UseConcMarkSweepGC server -cp $CORBPATH/marklogic-xcc-8.0-5.jar:$CORBPATH/corb.jar \
 #java   -server -cp $CORBPATH/marklogic-xcc-8.0-5.jar:$CORBPATH/corb.jar \          
  #      	-DXCC-CONNECTION-URI=xcc://$USER:$PASSWD@localhost:8203 \
   #     	-DTHREAD-COUNT=$THREADCOUNT \
        	    
#       java -server -cp ../corb/marklogic-xcc-8.0-5.jar:../corb/marklogic-corb-2.3.2.jar \            
 #       	-DXCC_CONNECTION_URI=xcc://$USER:$PASSWD@localhost:8203 \
  #      	-DTHREAD-COUNT=$THREADCOUNT \
   #     	-DURIS-MODULE=$CHANGEURIS \
    #    	-DURIS-MODULE.NAMETITLE=$NAMETITLE \
     #   	-DPROCESS-MODULE=$CHANGECODE \
      #  	-DMODULES-ROOT=admin/bfi/bibrecs/ \
       #     com.marklogic.developer.corb.Manager          

       sleep 1
       echo 'xquery version "1.0-ml";' > batchupdates/reload-uris.xqy
       cat /marklogic/backups/reloaddocs.txt |grep -v reload >> batchupdates/reload-uris.xqy
       chmod 775 batchupdates/reload-uris*.xqy
       chgrp marklogic batchupdates/reload-uris*.xqy
       
       
       cat   batchupdates/reload-uris.xqy
       cat /marklogic/backups/reloaddocs.nate
       echo ok to continue?
       read x
       
       #-DURIS-MODULE.NAMETITLE=$NAMETITLE \
       
       java -server -cp ../corb/marklogic-xcc-8.0-5.jar:../corb/marklogic-corb-2.3.2.jar \
        	-DXCC-CONNECTION-URI=xcc://$USER:$PASSWD@localhost:8203 \
        	-DTHREAD-COUNT=$THREADCOUNT \
        	-DURIS-MODULE=admin/bfi/bibrecs/batchupdates/reload-uris.xqy \
        	-DPROCESS-MODULE=admin/bfi/bibrecs/corb-bibframe-process-bib-files.xqy \
        	-DMODULES-ROOT=admin/bfi/bibrecs/ \
        	com.marklogic.developer.corb.Manager
       
       echo "done".
       cat  batchupdates/reload-uris.xqy
       cat /marklogic/backups/reloaddocs.nate
       tail -n 1000 /var/opt/MarkLogic/Logs/ErrorLog.txt | grep merged
       

  #  echo "you have to put in a title"	

 #fi
