!#/bin/bash
# test the conversion
rm ../out/marcxml.rdf

if [[ $2 == "" ]];
then

echo	curl -L http://mlvlp04.loc.gov:8230/resources/bibs/$1.xml > in/marcxml.xml
  curl -L http://mlvlp04.loc.gov:8230/resources/bibs/$1.xml > in/marcxml.xml

else

echo	curl -L https://lccn.loc.gov/$1/marcxml > in/marcxml.xml
  curl -L https://lccn.loc.gov/$1/marcxml > in/marcxml.xml
fi
# lookups important?
yaz-record-conv /marklogic/id/marc2bibframe2/record-conv.xml in/marcxml.xml > out/marcxml.rdf
rapper -i rdfxml -o ntriples -c out/marcxml.rdf
ls -ltr "[in|out]/marcxml.*"
