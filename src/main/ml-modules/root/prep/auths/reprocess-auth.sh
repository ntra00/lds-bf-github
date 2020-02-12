#!/bin/bash
AUTHID=$1

echo $AUTHID
cd /marklogic/applications/test/id/id-prep/marc-auth/names/source/unprocessed
curl -L http://lccn.loc.gov/$AUTHID/marcxml > $AUTHID.xml
chmod 775 $AUTHID.xml
chgrp marklogic $AUTHID.xml
echo "$AUTHID saved for today's load at:"
echo " /marklogic/applications/test/id/id-prep/marc-auth/names/source/unprocessed"

echo "  as:"

ls -l 

