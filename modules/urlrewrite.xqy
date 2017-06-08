xquery version "1.0-ml";

import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/lds/lib/l-param.xqy";
import module namespace mime = "info:lc/xq-modules/mime-utils" at "/xq/modules/mime-utils.xqy";
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/lds/config.xqy";
(:import module namespace rest="http://marklogic.com/appservices/rest" at "/MarkLogic/appservices/utils/rest.xqy"; :)
(: tohap permalinks and xml output are hardcoded to work within the branding url, diglib/tohap instead of at the root:)
declare default function namespace "http://www.w3.org/2005/xpath-functions";
(:change to rest:rewrite  soon!:)
(: sample logger:
let $_ := xdmp:log(concat('urlrewriter  success -  ',$args),'notice')
:)
let $url := xdmp:get-request-url()
let $path := xdmp:get-request-path()
(:let $escaped-url := xdmp:url-decode($url)
let $args :=  string-join(
    for $param in xdmp:get-request-field-names()
    return concat("&amp;",$param,"=",encode-for-uri(xdmp:get-request-field($param))), ""
)
let $args :=  substring-after(xdmp:get-request-url() , "?")  
let $urlTokens := tokenize($url,"/")
let $id:= substring($url,2):)
let $args := substring-after($url, "?")

(: allow id-like urls: http://mlvlp04.loc.gov:8231/resources/works/no2015083973  :)
let $path:= if (fn:matches($path,"^/resources/works/")) then
				fn:replace($path,"^/resources/works/","/loc.natlib.works.")
			else $path
				

return
  (: mets does not include mxe or idx; use doc.xml to find that :)
  if(matches($path, "/lds(/)?$")) then concat("/lds/index.xqy", $args)
  else
    if(matches($path, "^/loc\.(natlib|pnp|asian|afc|gmd|music)\.(lcdb|ia|copland|tohap|asian|gottlieb|nksip|ggbain|bernstein|lcwa[0-9]+|afc2001001|pae|ihas|afc9999005|erms|works|instances|items)\..+\.mets\.xml$")) then
      let $accept := "application/mets+xml"
      let $tmppath := replace($path, "/", "")
      let $objid := substring-before($tmppath, ".mets.xml")
      return concat("/lds/permalink.xqy?uri=", $objid, "&amp;mime=", $accept)
(:rdf from id-main :)
 else if(matches($path, "^/loc\.(natlib|pnp|asian|afc|gmd|music)\.(lcdb|ia|copland|tohap|asian|gottlieb|nksip|ggbain|bernstein|lcwa[0-9]+|afc2001001|pae|ihas|afc9999005|erms|works|instances|items)\..+\.rdf$")) then
      let $accept := "application/rdf+xml"
      let $tmppath := replace($path, "/", "")
      let $objid := substring-before($tmppath, ".rdf")
      return concat("/lds/permalink.xqy?uri=", $objid, "&amp;mime=", $accept)

(: Suggests, from specific scheme searches to generic searches from id-main for bf editor :)
else if (fn:matches($path,"^/(authorities|vocabulary|resources)/(.+/)?suggest([/]?)$")) then
 		let $accept := "application/json"
 		let $rdftype:=  "http://id.loc.gov/ontologies/bibframe/Work"
 		let $redir:=  fn:replace($url, "^/(resources)/(.+/)?suggest([/]?)$", "/xq/resources-suggest.xqy?scheme=http://id.loc.gov/$1/$2/")
		return fn:concat($redir, "&amp;mime=", $accept, "&amp;rdftype=", $rdftype )

else if (fn:matches($path,  "^/suggest([/]?)$") ) then
        let $accept := "application/json"
		let $redir:= fn:replace($url,  "^/suggest([/]?)$", "/xq/resources-suggest.xqy?scheme=all")
		return fn:concat($redir, "&amp;mime=", $accept)

 else (:tohap branded mets:)
  if(matches($path, "^/tohap/loc\.(natlib|pnp|asian|afc|gmd|music)\.(lcdb|ia|copland|tohap|asian|gottlieb|nksip|ggbain|bernstein|lcwa[0-9]+|afc2001001|pae|ihas|afc9999005|erms|works|instances|items)\..+\.mets\.xml$")) then
      let $accept := "application/mets+xml"
      let $tmppath := replace($path, "/tohap/", "")
      let $objid := substring-before($tmppath, ".mets.xml")
      return concat("/lds/permalink.xqy?uri=", $objid, "&amp;mime=", $accept)
    else
      if(matches($path, "^/loc\.(natlib|pnp|asian|afc|gmd|music)\.(lcdb|ia|copland|tohap|asian|nksip|gottlieb|ggbain|bernstein|lcwa[0-9]+|afc2001001|pae|ihas|afc9999005|erms|works|instances|items)\..+\.mods\.xml$")) then
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
      else
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

          else
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
             			
			else
				  if(matches($path, "^/loc\.(natlib|pnp|asian|afc|gmd|music)\.(lcdb|ia|copland|tohap|asian|nksip|gottlieb|ggbain|bernstein|lcwa[0-9]+|afc2001001|pae|ihas|afc9999005|erms|works|instances|items|sm[0-9]+)\..+(\.html)?$")) then
                  let $accept := "text/html"
                  let $tmppath := replace($path, "/", "")
                  let $objid := if(contains($tmppath, ".html")) then substring-before($tmppath, ".html")
                                else $tmppath
                  (: added branding to allow links to work in context (ils records all get lds, though) :)
				  (: took this out because lcwa0002 records found in lds were going to the lcwa0002 display; not ready for 
				  that yet and it might be hte wrong behavior:)
                  let $branding :=  "lds"
				  		(: if (matches($path, "\.lcdb\.")) then "lds"
                        else  replace($path, "^/loc\.(\w+)\.(\w+)\..+(\.html)$", "$2"):)
				  
                  return concat("/lds/permalink.xqy?uri=", $objid, "&amp;mime=", $accept, "&amp;branding=", $branding, "&amp;",$args)
            else   if(matches($path, "^/loc\.natlib\.(lcdb|ia|erms)\..+\.hold\.xml$")) then
                      let $accept := "application/holdings+xml"
                      let $tmppath := replace($path, "/", "")
                      let $objid := substring-before($tmppath, ".hold.xml")
                      return concat("/lds/permalink.xqy?uri=", $objid, "&amp;mime=", $accept)
			else (:tohap branded html permalink:)
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
                          else $url
						  