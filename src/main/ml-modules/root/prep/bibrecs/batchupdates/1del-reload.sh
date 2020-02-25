#!/bin/bash
# send in the offset of the name/title term in /marklogic/backups/del-reload.xml

NAMETITLE=$1

if [[ -n "NAMETITLE" ]]
 then
  	NAMETITLE=$NAMETITLE
    PASSWD=`/marklogic/id/id-prep/marc/keys/passwd-ml.sh`
    THREADCOUNT=4

    CORBPATH=/marklogic/id/id-prep/corb        
    CHANGEURIS="admin/bfi/bibrecs/batchupdates/del-reload-uris.xqy"
    CHANGECODE="admin/bfi/bibrecs/corb-bibframe-process-bib-files.xqy"
    USER=id-admin 
# this searches for  stuff  and deletes it, setting up a list to reload:

mv batchupdates/reload-uris.xqy batchupdates/reload-uris.old.xqy

#	   ./corb-shell.sh del-reload reload

echo $NAMETITLE    
        	    
       java -server -cp ../corb/marklogic-xcc-8.0-5.jar:../corb/marklogic-corb-2.3.2.jar \
        	-DXCC-CONNECTION-URI=xcc://$USER:$PASSWD@localhost:8203 \
        	-DTHREAD-COUNT=$THREADCOUNT \
        	-DURIS-MODULE=$CHANGEURIS \
        	-DURIS-MODULE.NAMETITLE-OFFSET=$NAMETITLE \
        	-DPROCESS-MODULE=$CHANGECODE \
        	-DMODULES-ROOT=admin/bfi/bibrecs/ \
            com.marklogic.developer.corb.Manager 

       sleep 0.4
	  

	   # this does the anchor only:
	    echo '
				xquery version "1.0-ml";
				("1",
			' > batchupdates/reload-anchor-uri.xqy

	    cat /marklogic/backups/reloaddocs.txt| grep anchor | cut -d ":" -f2 >>  batchupdates/reload-anchor-uri.xqy

	   echo ')
			' >> batchupdates/reload-anchor-uri.xqy

       # this does the whole  thing:
       echo 'xquery version "1.0-ml";' > batchupdates/reload-uris.xqy
       
	   cat /marklogic/backups/reloaddocs.txt |grep -v reload |grep -v anchor >> batchupdates/reload-uris.xqy
       chmod 775 batchupdates/reload-uris*.xqy
       chgrp marklogic batchupdates/reload-uris*.xqy 

    
java -server -cp ../corb/marklogic-xcc-8.0-5.jar:../corb/marklogic-corb-2.3.2.jar \
        	-DXCC-CONNECTION-URI=xcc://$USER:$PASSWD@localhost:8203 \
        	-DTHREAD-COUNT=$THREADCOUNT \
        	-DURIS-MODULE=admin/bfi/bibrecs/batchupdates/reload-anchor-uri.xqy \
        	-DPROCESS-MODULE=admin/bfi/bibrecs/corb-bibframe-process-bib-files.xqy \
        	-DMODULES-ROOT=admin/bfi/bibrecs/ \
        	com.marklogic.developer.corb.Manager 
       
zero=$( cat  /marklogic/backups/reloaddocs.txt |grep "'0'"| wc -l)

if [[ $zero != 1 ]] ; then

        
java -server -cp ../corb/marklogic-xcc-8.0-5.jar:../corb/marklogic-corb-2.3.2.jar \
        	-DXCC-CONNECTION-URI=xcc://$USER:$PASSWD@localhost:8203 \
        	-DTHREAD-COUNT=$THREADCOUNT \
        	-DURIS-MODULE=admin/bfi/bibrecs/batchupdates/reload-uris.xqy \
        	-DPROCESS-MODULE=admin/bfi/bibrecs/corb-bibframe-process-bib-files.xqy \
        	-DMODULES-ROOT=admin/bfi/bibrecs/ \
        	com.marklogic.developer.corb.Manager
fi
       echo "done".
       #cat  batchupdates/reload-uris.xqy
       #cat /marklogic/backups/reloaddocs.nate
#       tail -n 100 /var/opt/MarkLogic/Logs/ErrorLog.txt | grep merged
	   tail -n 100 /var/opt/MarkLogic/Logs/ErrorLog.txt | grep "CORB term"
       
else
   echo "you have to put in a title offset number"	

 fi
