#!/bin/bash
#          /marklogic/id/natlibcat/admin/bfi/auths/authorities2bf.xqy


# ex: nohup ./load_auth_yaz.sh [lccn] 


	./source2rdf_single.sh $1

#echo loading from id-main name titles  $LOAD_UNPROCESSED/single/$LCCN.rdf

	./loadrdf_single.sh

cd $CURDIR