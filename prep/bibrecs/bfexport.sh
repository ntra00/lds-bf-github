#!/bin/bash

# SETTINGS FOR THIS FILE ARE IN `config`
# CHANGE THIS FILE ONLY IF YOU ARE CHANGING THE LOGIC

cd /marklogic/applications/natlibcat/admin/bfi/bibrecs
DIR=`pwd`
echo $DIR
#runs from bibfrecs, corb is up one level?
#exports works, instances, items based on $1


NODE=$1
if [ "$NODE" == "" ]
then
  echo "\$NODE not specified.  Please specify  [works|instances|items] to export."
  exit 0
fi

PASSWD=`/marklogic/id/id-prep/marc/keys/passwd-ml.sh`

MLDIR=$DIR/../


echo "exporting : $NODE"

#java -cp ../corb/marklogic-xcc-8.0-5.jar:../corb/corb.jar \
#  com.marklogic.developer.corb.Manager \
#  xcc://id-admin:$PASSWD@localhost:8203/ \

#path is relative to 8203 home??? that is : /marklogic/applications/natlibcat/
# starts in bfi, so export file, error file are relative to that,  but modules are relative to 8203, ie natlibcat

cd $MLDIR
echo $DIR
echo $MLDIR
pwd

#startindex ??
java  -Xmx32G  -XX:+UseConcMarkSweepGC  -server -cp ../corb/marklogic-xcc-8.0-5.jar:../corb/marklogic-corb-2.3.2.jar \
	-DXCC-CONNECTION-URI=xcc://id-admin:$PASSWD@localhost:8203/natlibcat \
	-DTHREAD-COUNT=16 \
	-DURIS-MODULE=/admin/bfi/bibrecs/corb-export-uris.xqy \
	-DURIS-MODULE.NODE=$NODE \
	-DPROCESS-MODULE=/admin/bfi/bibrecs/corb-export.xqy \
	-DPROCESS-TASK=com.marklogic.developer.corb.ExportBatchToFileTask \
	-DEXPORT-FILE-NAME=bibrecs/bfexports/$NODE.nt \
	-DDISK-QUEUE=True \
	-DFAIL-ON-ERROR=False \
	-DERROR-FILE-NAME=bibrecs/bfexports/errors.log \
 com.marklogic.developer.corb.Manager 

cd $DIR
echo "done $NODE"

