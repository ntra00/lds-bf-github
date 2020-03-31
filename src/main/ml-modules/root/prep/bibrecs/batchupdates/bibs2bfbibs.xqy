xquery version "1.0-ml";

module namespace bib2bfb = "http://loc.gov/ndmso/bibs-2-bfbibs";



declare namespace 	rdf					= "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace   mets       		 	= "http://www.loc.gov/METS/";
declare namespace   marcxml             = "http://www.loc.gov/MARC21/slim";
declare namespace   mxe					= "http://www.loc.gov/mxe";
declare namespace 	bf					= "http://id.loc.gov/ontologies/bibframe/";
declare namespace 	idx 				= "info:lc/xq-modules/lcindex";

(: 
	load a chunk of bib marcxml
	
	also... add to collections?


 :)
 


declare function bib2bfb:transform(
  $content as map:map,
  $context as map:map
) as map:map*
{
	let $cdt := fn:current-dateTime() cast as xs:string
	  let $collections := ("/bibframe-process/", fn:concat("/bibframe-process/", $cdt, "/"))
        
    let $auth2bfBase:="/admin/bfi/auths/auth2bibframe2/"
	let $body := map:get($content, "value")
	let $orig-uri := map:get($content, "uri")  
	(: "/bibframe-process/catalog01_split_000001.xml :)
	let $base:=""
	let $uri:=fn:concat($base,$orig-uri)  
	    let $permissions := (
            xdmp:permission("id-user-role", "read"),
            xdmp:permission("id-admin-role", "update"),
            xdmp:permission("id-admin-role", "insert")
        )
	return
	   if ($body/node() instance of element(marcxml:collection)) then        		
            try {
                (
                    xdmp:document-insert($uri, $body, $permissions, $collections ),
                    xdmp:log(fn:concat("CORB Successful insertion of MARCXML for BF processing at ", $uri), "info")
                )
            } catch($e) {
                xdmp:log(fn:concat("CORB Failed insertion of MARCXML for BF processing at ", $uri), "error")
            }
    else
        	(xdmp:log(fn:concat("CORB fail node: ", fn:name($body)," at ", $uri), "info"),
			 (: If it's a MARCXML collection, we're good to process.  If not, reject the transmission :)
        fn:error(xs:QName("MARCXML_INPUT_EXCEPTION"), "Root node not an instance of element(marcxml:collection)")
		() (: xslt failed above :)

		)
     };