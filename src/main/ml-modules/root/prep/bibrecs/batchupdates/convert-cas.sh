echo  convert nq to n3 using easyrdf
echo then use:

echo rapper -i n3 -o rdfxml-abbrev -f 'xmlns:bf="http://id.loc.gov/ontologies/bibframe/"'  -f 'xmlns:rel="http://id.loc.gov/vocabulary/relators/"'  -f 'xmlns:bflc="http://id.loc.gov/ontologies/bflc/"' -f 'xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#"' -f 'xmlns:pmo="http://performedmusicontology.org/ontology/"' -f 'xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"' -f 'xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"'  batchupdates/cas.nt  > batchupdates/cas.rdf
echo then post to valid/source?
