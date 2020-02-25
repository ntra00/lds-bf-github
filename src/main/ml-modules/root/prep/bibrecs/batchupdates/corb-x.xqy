 xquery version "1.0-ml";
(:optimize sparql with collections in  lds :)
declare namespace html = "http://www.w3.org/1999/xhtml";
  declare namespace bf   = 'http://id.loc.gov/ontologies/bibframe/';
      declare namespace bflc = 'http://id.loc.gov/ontologies/bflc/';
      declare namespace   index               = "info:lc/xq-modules/lcindex";
       
       declare namespace idx        = "info:lc/xq-modules/lcindex";
      declare namespace   mets                                                     = "http://www.loc.gov/METS/";
      declare namespace marcxml       = "http://www.loc.gov/MARC21/slim";
declare namespace   rdf                 = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace   rdfs                = "http://www.w3.org/2000/01/rdf-schema#";
 declare namespace sparql ="http://www.w3.org/2005/sparql-results#";
import module namespace sem = "http://marklogic.com/semantics"     at "/MarkLogic/semantics.xqy";

let $uri:="http://id.loc.gov/resources/instances/c0186848030001"
let $params := 
        map:new((
            map:entry("uri", sem:iri($uri)       )
        ))

let $start:=xdmp:elapsed-time()
let $_:= xdmp:log(fn:concat("CORB temporal sparql start:  ", $start cast as xs:string), "info")

let $res:=

sem:sparql(  '
            PREFIX madsrdf: <http://www.loc.gov/mads/rdf/v1#>
            PREFIX lcc: <http://id.loc.gov/ontologies/lcc#>
            PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
            PREFIX  rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
            PREFIX madsrdf: <http://www.loc.gov/mads/rdf/v1#>
			PREFIX rdfs: 	<http://www.w3.org/2000/01/rdf-schema#>
			PREFIX bf: 		<http://id.loc.gov/ontologies/bibframe/>
			PREFIX bflc: 	<http://id.loc.gov/ontologies/bflc/>
	
	            
			SELECT    ?label
			WHERE {
  		
	  			?s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.loc.gov/mads/rdf/v1#Temporal> .
        ?s <http://www.loc.gov/mads/rdf/v1#authoritativeLabel> ?label .
	  			
			} 
      
            '
            , $params, (),   
              cts:and-not-query(cts:collection-query("/resources/works/"),cts:collection-query("/authorities/bfworks/"))
              
            )
            let $y:=sem:query-results-serialize($res)/sparql:results
              
   
  
     return (
		xdmp:save("/marklogic/backups/temporal-test.txt",<out>{
                       for $i in $y//sparql:binding
                           return  fn:concat(fn:string($i),"&#10;")
         }</out>
        )
,
     
     
             
xdmp:log(fn:concat("CORB temporal sparql:  ", (xdmp:elapsed-time() - $start) cast as xs:string), "info")
)
