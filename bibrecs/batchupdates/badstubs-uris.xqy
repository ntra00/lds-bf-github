
xquery version "1.0-ml";
declare namespace html = "http://www.w3.org/1999/xhtml";
declare namespace   rdf             = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace   madsrdf         = "http://www.loc.gov/mads/rdf/v1#";
declare namespace   marcxml         = "http://www.loc.gov/MARC21/slim";
declare namespace   lcc             = "http://id.loc.gov/ontologies/lcc#";
declare namespace   bf-abstract 	= "http://bibframe.org/model-abstract/"  ;
declare namespace   owl             = "http://www.w3.org/2002/07/owl#";
declare namespace   rdfs            = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace   zs              = "http://www.loc.gov/zing/srw/" ;
declare namespace	skos			= "http://www.w3.org/2004/02/skos/core#";
declare namespace	dcterms    	    = "http://purl.org/dc/terms/";
declare namespace   index           = "info:lc/xq-modules/lcindex";

let $unmarked-stubs:=
		for $x in 
		cts:uris( (),(),
		cts:and-not-query(
										
								                            cts:and-query(( 
								                                cts:collection-query("/resources/works/"),
																 cts:collection-query("/catalog/")
								            		           
								            		        )),
								            		        cts:collection-query("/bibframe/stubworks/")
								      )      		        
											)[1 to 50000] 
										
                      
                      return if (fn:string-length(doc($x)//index:token[1]) = 14) 
                            then  fn:string-length(doc($x)//index:token) else  ()
  let $res:=<unmarkedstubs>{
                       ($unmarked-stubs, $unmarked-stubs)
                       }
                       </unmarkedstubs>
 return (xdmp:save("/marklogic/backups/unmarkedstubs.xml",$res),())
                      