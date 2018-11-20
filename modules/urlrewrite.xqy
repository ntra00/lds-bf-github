xquery version "1.0-ml";

import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/lds/lib/l-param.xqy";
import module namespace mime = "info:lc/xq-modules/mime-utils" at "/xq/modules/mime-utils.xqy";
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/lds/config.xqy";
import module namespace utils = "info:lc/xq-modules/mets-utils" at "/xq/modules/mets-utils.xqy";
(:import module namespace rest="http://marklogic.com/appservices/rest" at "/MarkLogic/appservices/utils/rest.xqy"; :)
(: tohap permalinks and xml output are hardcoded to work within the branding url, diglib/tohap instead of at the root:)
declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare variable $REGEX-FOR-RESOURCES-SUGGEST as xs:string := "/resources/(.*)/suggest/$";
declare variable $REGEX-FOR-RESOURCES-SUGGEST-TOKEN as xs:string := "/resources/(.*)/suggest/(lccn|token)/(.+)$";
declare variable $REGEX-FOR-RESOURCES-FEED as xs:string := "/resources/(.*/)feed([/]?)([0-9]+)?";
declare variable $REGEX-FOR-LABEL-SERVICE as xs:string := "/resources/works/label/(.+)(\..+)?$";
(:change to rest:rewrite  soon!:)
(: sample logger:
let $_ := xdmp:log(concat('urlrewriter  success -  ',$args),'notice')
:)

let $url := xdmp:get-request-url()
let $path := xdmp:get-request-path()

(:
	let $escaped-url := xdmp:url-decode($url)
	let $args :=  string-join(
    					for $param in xdmp:get-request-field-names()
    						return concat("&amp;",$param,"=",encode-for-uri(xdmp:get-request-field($param))), ""
					)
	let $args :=  substring-after(xdmp:get-request-url() , "?")  
	let $urlTokens := tokenize($url,"/")
	let $id:= substring($url,2)
:)

let $args := substring-after($url, "?")

(: allow id-like urls: http://mlvlp04.loc.gov:8231/resources/works/no2015083973  :)
(: this is mine; maybe trebor's is better :)
	(:
	let $path:= if (fn:matches($path,"^/resources/(works|instances|items)/.+")) then
					fn:replace($path,"resources/(works|instances|items)(/)(.+)","loc.natlib.$1.$3")
					
				else $path
	:)

let $path:= 
    if (fn:matches($path, "^/resources/(instances|works|items)/") and 
		fn:not(fn:matches($path, $REGEX-FOR-RESOURCES-SUGGEST)) and 
		fn:not(fn:matches($path, $REGEX-FOR-RESOURCES-FEED)) and 
		fn:not(fn:matches($path, $REGEX-FOR-LABEL-SERVICE)) and 
		fn:not(fn:matches($path, $REGEX-FOR-RESOURCES-SUGGEST-TOKEN)) 
		)
    then	
        fn:replace($path, "^/resources/(instances|works|items)/", "/loc.natlib.$1.")	
    else
        $path     
(:let $path:= 
    if (fn:matches($path, "^/resource/(instance|work|item)/")		 )
    then	
        fn:replace($path, "^/resource/(instance|work|item)/", "/loc.natlib.$1.")	
    else
        $path       :)

return
 (: ****************   bookmarks with various serializations *********************:) 
		  (: mets does not include mxe or idx; use doc.xml to find that :)
		  if (matches($path, "/lds(/)?$")) then 
		  		concat("/lds/index.xqy", $args)
		    (: label service for nametitle :)
			else if (fn:matches($path,$REGEX-FOR-LABEL-SERVICE)) then
 				 let $accept := "text/xml"
 					let $redir:=  fn:replace($url, "^/resources/works/label/(.+)(\..+)?$", 					
						"/lds/search.xqy?count=1&amp;sort=score-desc&amp;precision=exact&amp;qName=idx:nameTitle&amp;q=$1&amp;mime=")
						let $redir:=fn:concat($redir,$accept)
				
				return $redir

		
			else if(matches($path, "^/resources/bibs/[0-9]+(\.xml)?$")) then
		      let $accept := "application/marcxml+xml"      
			  let $tmppath:= if (fn:contains($path, ".xml")) then
			  					substring-before($path,".xml")
			  				 else
							 	$path
		      (:let $_:= 		xdmp:log(concat("/lds/permalink.xqy?uri=", $tmppath, "&amp;mime=", $accept),"info"):)
			  return concat("/lds/permalink.xqy?uri=", $tmppath, "&amp;mime=", $accept)
(: ========================== experimental redirect of lccn based search =============================:)
			
			else if (matches($path, "^/resource/(work|instance|item)/.+(\.(ttl|nt|xml|rdf|html))$")) then			  
					 let $ser:=fn:replace($path,
					  					"^/resource/(work|instance|item)/(.+)\.(ttl|nt|xml|rdf|html)$",
					   "$3" 
					   ) 			  				
					 let $accept := if ($ser="xml") then  "application/mdoc+xml" 
					 else if ($ser="rdf") then  "application/rdf+xml" 
					 else if ($ser="html") then  "text+html" 
					 else 
					 	 "application/mets+xml"      
 		let $tmppath:= if (fn:contains($path, ".")) then
			  					substring-before($path,".")
			  				 else
							 	$path

		let $tmppath:=			 utils:get-mets-id-by-lccn($path)
		return ( concat("/lds/permalink.xqy?uri=", $tmppath, "&amp;mime=", $accept))

(: ========================== experimental redirect of lccn based search =============================:)		  
(: get marc bibs records :)
			else if(matches($path, "^/resources/bibs/n.+(\.xml)?$")) then
		      let $accept := "application/marcxml+xml"      
			  let $tmppath:= if (fn:contains($path, ".xml")) then
			  					substring-before($path,".xml")
			  				 else
							 	$path
		      (:let $_:= xdmp:log(concat("/lds/permalink.xqy?uri=", $tmppath, "&amp;mime=", $accept),"info"):)
			  
			  return concat("/lds/permalink.xqy?uri=", $tmppath, "&amp;mime=", $accept)

(: handle feed requests:)			
		else if (matches($path, "^/resources/(works|instances|items|agents|subjects|imprints)/feed(/)?$") ) then
		      let $tmppath:=replace($path,"^/resources/(works|instances|items|agents|subjects|imprints)/feed(/)?$", 
			  			  								"/lds/page-service.xqy?scheme=/resources/$1/")
			  
			  let $accept := "application/atom+xml"
			  let $tmppath:=fn:concat($tmppath,	"&amp;service=feed&amp;mime=",		 $accept, "&amp;page=1")								
				return $tmppath
		      (:return concat("/lds/page-service.xqy?scheme=", "$1", "&amp;service=feed&amp;mime=", $accept, "&amp;page=1"):)

		else if (matches($path, "^/resources/(works|instances|items|names|subjects|imprints)/feed/([0-9]+)$") ) then
		      
			  let $tmppath:=fn:replace($path,"^/resources/(works|instances|items|names|subjects|imprints)/feed/(.+)",
			  								"/lds/page-service.xqy?scheme=/resources/$1/")

			  let $accept := "application/atom+xml"		      
		      let $page:=fn:substring-after($path,"/feed/")
			  let $tmppath:=fn:concat($tmppath,	"&amp;service=feed&amp;mime=",	 $accept, "&amp;page=",$page)								
			  
			  return $tmppath
		      (:return concat("/lds/page-service.xqy?scheme=", "$1", "&amp;service=feed&amp;mime=", $accept, "&amp;page=", $page):)

		  else if(matches($path, "^/loc\.(natlib|pnp|asian|afc|gmd|music)\.(lcdb|ia|copland|tohap|asian|gottlieb|nksip|ggbain|bernstein|lcwa[0-9]+|afc2001001|pae|ihas|afc9999005|erms|works|instances|items)\..+\.mets\.xml$")) then
		      let $accept := "application/mets+xml"
		      let $tmppath := replace($path, "/", "")
		      let $objid := substring-before($tmppath, ".mets.xml")
		      return concat("/lds/permalink.xqy?uri=", $objid, "&amp;mime=", $accept)
		(: handle semtriples subset first; the rest assume bibframe.rdf :)
		(:else  
            if(matches($path, "^/loc\.natlib\.(lcdb|works|instances|items)\..+\.semtriples\.(ttl|nt|xml|rdf)$")) then
              let $tmppath := replace($path, "/", "")
			  let $objid := substring-before($tmppath, ".semtriples")
			  
			  let $ser:=replace ($tmppath,".+semtriples\.(ttl|nt|xml|rdf)$","$1")
			  let $accept := if ($ser="ttl") then
			  		       		"text/turtle"
			  				else if ($ser="nt") then
			  				   "application/n-triples"
              			else if ($ser="rdf") then
			  				 	"application/rdf+xml"
						else if ( $ser="xml") then
			  				 	"application/mets+xml"
						else "application/rdf+xml"

              (:let $objid := replace($tmppath, "^/loc\.natlib\.(lcdb|works|instances|items)\..+\.semtriples\.(ttl|nt|xml|rdf)$",concat("loc.natlib.","$1")):)
              
			  return concat("/lds/permalink.xqy?uri=", $objid, "&amp;subset=semtriples&amp;mime=", $accept)
          
		  :)
		
		(:rdf  :)
		else if(matches($path, "^/loc\.natlib\.(lcdb|works|instances|items)\..+\.simple.rdf$")) then
	 	
		      let $accept := "application/bf-simple+xml"
		      let $tmppath := replace($path, "/", "")
		      let $objid := substring-before($tmppath, ".simple.rdf")
		      return(
			   		concat("/lds/permalink.xqy?uri=", $objid, "&amp;mime=", $accept)
			   )
			  
		 else if(matches($path, "^/loc\.(natlib|pnp|asian|afc|gmd|music)\.(lcdb|works|instances|items)\..+\.rdf$")) then
		      let $accept := "application/rdf+xml"
		      let $tmppath := replace($path, "/", "")
		      let $objid := substring-before($tmppath, ".rdf")
		      return concat("/lds/permalink.xqy?uri=", $objid, "&amp;mime=", $accept)
	 
	 

		 else if(matches($path, "^/loc\.natlib\.(lcdb|works|instances|items)\..+\.ttl$")) then
		      let $accept := "text/turtle"
		      let $tmppath := replace($path, "/", "")
		      let $objid := substring-before($tmppath, ".ttl")
		      return concat("/lds/permalink.xqy?uri=", $objid, "&amp;mime=", $accept)
 
		 else if(matches($path, "^/convert/[0-9]+/bib2lccn$")) then
		      let $accept := "text/plain"
		      let $tmppath := replace($path, "/", "")
		      let $objid := tokenize($path, "/")[3]
		      return concat("/lds/bib2lccn.xqy?bibid=", $objid, "&amp;mime=", $accept)

		else if(matches($path, "^/loc\.natlib\.(lcdb|works|instances|items)\..+\.n3$")) then
		      let $accept := "text/n3"
		      let $tmppath := replace($path, "/", "")
		      let $objid := substring-before($tmppath, ".n3")
		      return concat("/lds/permalink.xqy?uri=", $objid, "&amp;mime=", $accept)
	    
		else if(matches($path, "^/loc\.natlib\.(lcdb|works|instances|items)\..+\.json$")) then
		      let $accept := "application/json"
		      let $tmppath := replace($path, "/", "")
		      let $objid := substring-before($tmppath, ".json")
		      return concat("/lds/permalink.xqy?uri=", $objid, "&amp;mime=", $accept)

		else if(matches($path, "^/loc\.natlib\.(lcdb|works|instances|items)\..+\.jsonld$")) then
		      let $accept := "application/ld+json"
		      let $tmppath := replace($path, "/", "")
		      let $objid := substring-before($tmppath, ".jsonld")
			  
		      return concat("/lds/permalink.xqy?uri=", $objid, "&amp;mime=", $accept)
		
		else if(matches($path, "^/loc\.natlib\.(lcdb|works|instances|items)\..+\.nt$")) then
		      let $accept := "application/n-triples"
		      let $tmppath := replace($path, "/", "")
		      let $objid := substring-before($tmppath, ".nt")
		      return concat("/lds/permalink.xqy?uri=", $objid, "&amp;mime=", $accept)
		
		

(: ****************   suggest service  *********************:) 
(: Suggests, from specific scheme searches to generic searches from id-main for bf editor this one uses a $term variable token, lccn,etc. :)
 else if (fn:matches($path,$REGEX-FOR-RESOURCES-SUGGEST-TOKEN)) then
 		
 		let $redir:=  fn:replace($url, "^/resources/(.+)/suggest/(.+)/(.+)(\..+)?$", 
					"/xq/resources-suggest.xqy?scheme=http://id.loc.gov/resources/$1&amp;mime=$4&amp;term=$2&amp;q=$3")
		return $redir

(: Suggests, from specific scheme searches to generic searches from id-main for bf editor :)
(: else if (fn:matches($path,"^/resources/(.+)/?suggest([/]?)$")) then
 		let $redir:=  fn:replace($url, "^/resources/(.+/)?suggest([/]?)", "/xq/resources-suggest.xqy?scheme=http://id.loc.gov/resources/$2"&amp;mime=http://")
		return $redir

else if (fn:matches($path,  "^/suggest([/]?)$") ) then
		let $redir:= fn:replace($url,  "^/suggest([/]?)$",   			"/xq/resources-suggest.xqy?scheme=all")
		return $redir
:)
else if (fn:matches($path, $REGEX-FOR-RESOURCES-SUGGEST)) then
 		let $accept := "application/json"
 		(:let $rdftype :=  "http://id.loc.gov/ontologies/bibframe/Work":)
 		let $redir := fn:replace($url, "/(resources)/(.*/)suggest[/]?\?(.*)", "/xq/resources-suggest.xqy?scheme=http://id.loc.gov/$1/$2&amp;$3")
 		(:let $retval := fn:concat($redir, "&amp;mime=", $accept, "&amp;rdftype=", $rdftype ):)
		let $retval := fn:concat($redir, "&amp;mime=", $accept )
 		
		return $retval


else if (fn:matches($path,  "^/suggest([/]?)$") ) then
        let $accept := "application/json"
		let $redir:= fn:replace($url,  "^/suggest([/]?)$", "/xq/resources-suggest.xqy?scheme=all")
		return fn:concat($redir, "&amp;mime=", $accept)

(: ****************  various serializations for marc based data *********************:) 
 else (:tohap branded mets:)
  if(matches($path, "^/tohap/loc\.(natlib|pnp|asian|afc|gmd|music)\.(lcdb|ia|copland|tohap|asian|gottlieb|nksip|ggbain|bernstein|lcwa[0-9]+|afc2001001|pae|ihas|afc9999005|erms|works|instances|items)\..+\.mets\.xml$")) then
      let $accept := "application/mets+xml"
      let $tmppath := replace($path, "/tohap/", "")
      let $objid := substring-before($tmppath, ".mets.xml")
      return concat("/lds/permalink.xqy?uri=", $objid, "&amp;mime=", $accept)
    else
      if(matches($path, "^/loc\.(natlib|pnp|asian|afc|gmd|music)\.(lcdb|ia|copland|tohap|asian|nksip|gottlieb|ggbain|bernstein|lcwa[0-9]+|afc2001001|pae|ihas|afc9999005|ermsworks|instances|items)\..+\.mods\.xml$")) then
        let $accept := "application/mods+xml"
        let $tmppath := replace($path, "/", "")
        let $objid := substring-before($tmppath, ".mods.xml")
        return concat("/lds/permalink.xqy?uri=", $objid, "&amp;mime=", $accept)
      else (:tohap branded mods:)
      if(matches($path, "^/tohap/loc\.(natlib|pnp|asian|afc|gmd|music)\.(lcdb|ia|copland|tohap|asian|nksip|gottlieb|ggbain|bernstein|lcwa[0-9]+|afc2001001|pae|ihas|afc9999005|erms|works|instances|items)\..+\.mods\.xml$")) then
        let $accept := "application/mods+xml"
        let $tmppath := replace($path, "/tohap/", "")
        let $objid := substring-before($tmppath, ".mods.xml")
        return concat("/lds/permalink.xqy?uri=", $objid, "&amp;mime=", $accept)
      else (:bookmarked  mods:)
        if(matches($path, "^/loc\.(natlib|pnp|asian|afc|gmd|music)\.(lcdb|ia|copland|tohap|asian|nksip|gottlieb|ggbain|bernstein|lcwa[0-9]+|afc2001001|pae|ihas|afc9999005|erms|works|instances|items|sm[0-9]+)\..+\.marcxml\.xml$")) then
          let $accept := "application/marcxml+xml"
          let $tmppath := replace($path, "/", "")
          let $objid := substring-before($tmppath, ".marcxml.xml")
          return concat("/lds/permalink.xqy?uri=", $objid, "&amp;mime=", $accept)
        else
          if(matches($path, "^/loc\.(natlib|pnp|asian|afc|gmd|music)\.(lcdb|ia|copland|tohap|asian|nksip|gottlieb|ggbain|bernstein|lcwa[0-9]+|afc2001001|pae|ihas|afc9999005|erms|works|instances|items|sm[0-9]+)\..+\.dc\.xml$")) then
            let $accept := "application/srwdc+xml"
            let $tmppath := replace($path, "/", "")
            let $objid := substring-before($tmppath, ".dc.xml")
            return concat("/lds/permalink.xqy?uri=", $objid, "&amp;mime=", $accept)
        else (:tohap branded dc:)
          if(matches($path, "^/tohap/loc\.(natlib|pnp|asian|afc|gmd|music)\.(lcdb|ia|copland|tohap|asian|nksip|gottlieb|ggbain|bernstein|lcwa[0-9]+|afc2001001|pae|ihas|afc9999005|erms|works|instances|items|sm[0-9]+)\..+\.dc\.xml$")) then
            let $accept := "application/srwdc+xml"
            let $tmppath := replace($path, "/tohap/", "")
            let $objid := substring-before($tmppath, ".dc.xml")
            return concat("/lds/permalink.xqy?uri=", $objid, "&amp;mime=", $accept)

          else   (:		index data in stored doc: :)
            if(matches($path, "^/loc\.(natlib|pnp|asian|afc|gmd|music)\.(lcdb|ia|copland|tohap|asian|nksip|gottlieb|ggbain|bernstein|lcwa[0-9]+|afc2001001|pae|ihas|afc9999005|erms|works|instances|items|sm[0-9]+)\..+\.index\.xml$")) then
              let $accept := "application/index+xml"
              let $tmppath := replace($path, "/", "")
              let $objid := substring-before($tmppath, ".index.xml")
              return concat("/lds/permalink.xqy?uri=", $objid, "&amp;mime=", $accept)
          
		    (:		full document as stored: :)
            else
              if(matches($path, "^/loc\.(natlib|pnp|asian|afc|gmd|music)\.(lcdb|ia|copland|tohap|asian|nksip|gottlieb|ggbain|bernstein|lcwa[0-9]+|afc2001001|pae|ihas|afc9999005|erms|works|instances|items|sm[0-9]+)\..+\.doc\.xml$")) then
                let $accept := "application/mldoc+xml"
                let $tmppath := replace($path, "/", "")
                let $objid := substring-before($tmppath, ".doc.xml")
                return concat("/lds/permalink.xqy?uri=", $objid, "&amp;mime=", $accept)
   (:********************* bibframe lccn lookup rewriter *********************:) 
			else 
				  if(matches($path, "^/loc\.(natlib)\.(work|instance|item)\..+(\.html)?$")) then
                  let $accept := "text/html"
                  let $tmppath := replace($path, "/", "")
                  let $objid := if(contains($tmppath, ".html")) then substring-before($tmppath, ".html")
                                else $tmppath
                  (: added branding to allow links to work in context (ils records all get lds, though) :)
				  (: took this out because lcwa0002 records found in lds were going to the lcwa0002 display; not ready for 
				  that yet and it might be the wrong behavior:)
                  let $branding :=  "lds"
				  		(: if (matches($path, "\.lcdb\.")) then "lds"
                        else  replace($path, "^/loc\.(\w+)\.(\w+)\..+(\.html)$", "$2"):)
				  
                  return concat("/lds/permalink.xqy?uri=", $objid, "&amp;mime=", $accept, "&amp;branding=", $branding, "&amp;",$args)
   (: ****************  html ?? *********************:) 
			else 
				  if(matches($path, "^/loc\.(natlib|pnp|asian|afc|gmd|music)\.(lcdb|ia|copland|tohap|asian|nksip|gottlieb|ggbain|bernstein|lcwa[0-9]+|afc2001001|pae|ihas|afc9999005|erms|works|instances|items|sm[0-9]+)\..+(\.html)?$")) then
                  let $accept := "text/html"
                  let $tmppath := replace($path, "/", "")
                  let $objid := if(contains($tmppath, ".html")) then substring-before($tmppath, ".html")
                                else $tmppath
                  (: added branding to allow links to work in context (ils records all get lds, though) :)
				  (: took this out because lcwa0002 records found in lds were going to the lcwa0002 display; not ready for 
				  that yet and it might be the wrong behavior:)
                  let $branding :=  "lds"
				  		(: if (matches($path, "\.lcdb\.")) then "lds"
                        else  replace($path, "^/loc\.(\w+)\.(\w+)\..+(\.html)$", "$2"):)
				  
                  return concat("/lds/permalink.xqy?uri=", $objid, "&amp;mime=", $accept, "&amp;branding=", $branding, "&amp;",$args)
 (: ****************  holdings  *********************:) 
            else   if(matches($path, "^/loc\.natlib\.(lcdb|ia|erms|works|instances|items)\..+\.hold\.xml$")) then
                      let $accept := "application/holdings+xml"
                      let $tmppath := replace($path, "/", "")
                      let $objid := substring-before($tmppath, ".hold.xml")
                      return concat("/lds/permalink.xqy?uri=", $objid, "&amp;mime=", $accept)
			(: ****************  tohap branded html   *********************:) 
			else 
				  if(matches($path, "^/tohap/loc\.(natlib|pnp|asian|afc|gmd|music)\.(lcdb|ia|copland|tohap|asian|nksip|gottlieb|ggbain|bernstein|lcwa[0-9]+|afc2001001|pae|ihas|afc9999005|erms|works|instances|items|sm[0-9]+)\..+(\.html)?$")) then
                  let $accept := "text/html"
                  let $tmppath := replace($path, "/tohap/", "")
                  let $objid := if(contains($tmppath, ".html")) then substring-before($tmppath, ".html")
                                else $tmppath
                  (: added branding to allow links to work in context (ils records all get lds, though) :)
				  (: took this out because lcwa0002 records found in lds were going to the lcwa0002 display; not ready for 
				  that yet and it might be the wrong behavior:)
                  let $branding :=  "tohap"
				  		(: if (matches($path, "\.lcdb\.")) then "lds"
                        else  replace($path, "^/loc\.(\w+)\.(\w+)\..+(\.html)$", "$2"):)
				  
                  return concat("/lds/permalink.xqy?uri=", $objid, "&amp;mime=", $accept, "&amp;branding=", $branding, "&amp;",$args)

                (: Content Negotiation :)
                else
                  (:if(matches($path, "^/loc\.(natlib|pnp|asian|afc|gmd)\.(lcdb|ia|copland|tohap|asian|nksip|gottlieb|ggbain|bernstein|lcwa[0-9]+|afc2001001|pae|ihas|afc9999005|erms|works|instances|items|sm[0-9]+|sanborn|g4374am)\..+/?$")) then:)
                  if(matches($path, "^/loc\.(natlib|pnp|asian|afc|gmd|music)\..+/?$")) then
                    let $accept := xdmp:get-request-header("Accept", "text/html")
                    let $behavior := if(lp:get-param-single($lp:CUR-PARAMS, "behavior")) then concat("&amp;behavior=", lp:get-param-single($lp:CUR-PARAMS, "behavior"))
                                     else ()
                    
					return concat("/lds/permalink.xqy?uri=", replace($path, "/", ""), "&amp;mime=", $accept, $behavior)
                  else
                    if(matches($path, "^/loc\.natlib\.(lcdb|ia|erms)\..+\.hold\.xml$")) then
                      let $accept := "application/holdings+xml"
                      let $tmppath := replace($path, "/", "")
                      let $objid := substring-before($tmppath, ".hold.xml")
                      return concat("/lds/permalink.xqy?uri=", $objid, "&amp;mime=", $accept)
                    else
                      if (matches($path, "^/unapi")) then
                        let $accept := "text/html"
                        let $parms := substring-after($url, "unapi")
                        return concat("/lds/unapi.xqy", $parms)
                  							
                        (: /branding(/?) home pages :)
                    else if ( matches($path, concat("^/", $cfg:SITE-NAMES, "/?$"))) then
                          let $accept := "text/html"
                          let $branding := replace($path, "^/(\w+)/?$", "$1")
                          let $coll := $cfg:SITES//*:site[*:branding = $branding]/*:collection/string()
                          let $xqy := if(matches($branding, "^(lscoll|tohap|lcwa)$")) then $branding
                                      else "subcoll"						  
                          return concat("/splashpages/", $xqy, ".xqy?collection=", $coll, "&amp;branding=", $branding)
                        
						(: trap for a branding search and send it as a collection parameter:)
                        else
                          if(matches($path, concat("^/", $cfg:SITE-NAMES, "/(search|browse|detail|feedback|permalink|print|unapi|parts/.+)\.(jsp|xqy)?.+$"))) then
                            let $branding := replace($path, concat("^/", $cfg:SITE-NAMES, "/.+$"), "$1")
                            let $coll := $cfg:SITES//*:site[*:branding = $branding]/*:collection/string()
                            let $newpath := replace($path, concat("^/", $cfg:SITE-NAMES, "/(search|browse|detail|feedback|permalink|print|unapi|parts/.+)\..+$"), "/lds/$2.xqy")
                            return concat($newpath, "?", $args, "&amp;collection=", $coll, "&amp;branding=", $branding)
			else if (matches($path,"^/remove/.+")) then
				let $uri:=replace($path,"(/remove/)(.+$)","$2")
				
					return concat("/admin/remove-collection.xqy?uri=",$uri)

                          else $url
						  