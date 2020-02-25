#!/bin/bash

    PASSWD=`/marklogic/id/id-prep/marc/keys/passwd-ml.sh`
    THREADCOUNT=4

    CORBPATH=/marklogic/id/id-prep/corb        
    CHANGEURIS="batchupdates/del-reload-uris.xqy"
    CHANGECODE="corb-bibframe-process-bib-files.xqy"
    USER=id-admin 
   
       java -server -cp ../corb/marklogic-xcc-8.0-5.jar:../corb/marklogic-corb-2.3.2.jar \
        	-DXCC-CONNECTION-URI=xcc://$USER:$PASSWD@localhost:8203 \
        	-DTHREAD-COUNT=$THREADCOUNT \
        	-DURIS-MODULE=admin/bfi/bibrecs/batchupdates/reload-uris.xqy \
        	-DPROCESS-MODULE=admin/bfi/bibrecs/corb-bibframe-process-bib-files.xqy \
        	-DMODULES-ROOT=admin/bfi/bibrecs/ \
        	com.marklogic.developer.corb.Manager
       
       echo "done".
       

  #  echo "you have to put in a title"	

 #fi
