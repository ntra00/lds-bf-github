rm ../out/marcxml.rdf

if [[ $1 == n* ]];
then
curl -L https://lccn.loc.gov/$1/marcxml > ../in/marcxml.xml

fi
yaz-record-conv auths-conv.xml ../in/marcxml.xml > ../out/marcxml.rdf
rapper -i rdfxml -o ntriples -c ../out/marcxml.rdf
ls -ltr ../*/marcxml.*
