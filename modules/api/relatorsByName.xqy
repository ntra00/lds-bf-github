xquery version "1.0-ml";

import module namespace cfg = "http://www.marklogic.com/ps/config" at "/nlc/config.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/nlc/lib/l-param.xqy";
import module namespace relators = "info:lc/xq-modules/config/relators" at "/xq/modules/config/relators.xqy";
import module namespace resp = "info:lc/xq-modules/http-response-utils" at "/xq/modules/http-response-utils.xqy";
import module namespace mime = "info:lc/xq-modules/mime-utils" at "/xq/modules/mime-utils.xqy";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace id = "http://id.loc.gov/vocabulary/relators/";
declare namespace madsrdf= "http://www.loc.gov/mads/rdf/v1#";
declare namespace modsrdf = "http://www.loc.gov/standards/mods/modsrdf/modsOntology.owl#";

declare function local:rdfxml($byName as map:map) as element(rdf:RDF) {
        <rdf:RDF xmlns:id="http://id.loc.gov/vocabulary/relators/" xmlns:modsrdf="http://www.loc.gov/standards/mods/modsrdf/modsOntology.owl#" xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#">
            {
                let $outdir := map:get($byName, "authorityURIStatementPosition")
                return 
                    if ($outdir eq "rdf:subject") then
                        <rdf:Description rdf:about="{map:get($byName, "authorityURI")}"> 
                            <rdf:type rdf:resource="http://www.w3.org/1999/02/22-rdf-syntax-ns#Resource"/>
                            <rdf:type rdf:resource="http://www.loc.gov/mads/rdf/v1#Name"/>
                            {
                                for $z in map:get($byName, "hits")
                                return
                                    if (map:get($z, "relatorQName")) then
                                      element { map:get($z, "relatorQName") } 
                                      {
                                        attribute rdf:resource {map:get($z, "resourceURI")}
                                      }
                                    else
                                      <modsrdf:roleRelationship>
	                                        <modsrdf:RoleRelationship>
		                                          <modsrdf:roleText>{map:get($z, "originalResourceRelatorLabel")}</modsrdf:roleText>
	                                          	<modsrdf:roleIn rdf:resource="{map:get($z, "resourceURI")}" />
	                                        </modsrdf:RoleRelationship>
                                      </modsrdf:roleRelationship>
                            }
                            </rdf:Description>
                    else
                      for $z in map:get($byName, "hits")
                      let $subj := map:get($z, "resourceURI")
                      return 
                            <rdf:Description rdf:about="{$subj}"> 
                                <rdf:type rdf:resource="http://www.w3.org/1999/02/22-rdf-syntax-ns#Resource"/>
                                {
                                      if (map:get($z, "relatorQName")) then
                                        element { map:get($z, "relatorQName") } 
                                        {
                                          attribute rdf:resource {map:get($byName, "authorityURI")}
                                        }
                                      else
                                      <modsrdf:roleRelationship>
	                                        <modsrdf:RoleRelationship>
		                                          <modsrdf:roleText>{map:get($z, "originalResourceRelatorLabel")}</modsrdf:roleText>
	                                          	<modsrdf:roleName rdf:resource="{map:get($byName, "authorityURI")}" />
	                                        </modsrdf:RoleRelationship>
                                      </modsrdf:roleRelationship>
                                }
                                </rdf:Description>
                                }
                            </rdf:RDF>
};

declare function local:json($byName as map:map) as xs:string {
    xdmp:to-json($byName)
};

let $authLabel as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'authLabel')
let $authURI as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'authURI')
let $position as xs:string := lp:get-param-single($lp:CUR-PARAMS, 'spoPosition', "rdf:object")
let $inmime as xs:string := lp:get-param-single($lp:CUR-PARAMS, 'mime', "application/rdf+xml")
let $mime := mime:safe-mime($inmime)
let $duration := $cfg:HTTP_EXPIRES_CACHE
return
    if ($authLabel and $authURI) then
        let $byName := relators:byName(normalize-space($authLabel), xs:anyURI(normalize-space($authURI)), normalize-space($position))
        return
            if (count(map:get($byName, "hits")) eq 0) then
                xdmp:set-response-code(204, "No Content")
            else if (matches($mime, "(text|application)/json")) then
                    (
                        xdmp:set-response-content-type(concat($mime, "; charset=utf-8")), 
                        xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
                        xdmp:add-response-header("Cache-Control", resp:cache-control($duration)), 
                        xdmp:add-response-header("Expires", resp:expires($duration)),
                        $byName
                    )
            else if ($mime eq "application/rdf+xml") then
                    (
                        xdmp:set-response-content-type(concat($mime, "; charset=utf-8")), 
                        xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
                        xdmp:add-response-header("Cache-Control", resp:cache-control($duration)), 
                        xdmp:add-response-header("Expires", resp:expires($duration)),
                        document { local:rdfxml($byName) }
                    )
            else
                    (
                        xdmp:set-response-code(400, "Bad Request"), 
                        xdmp:set-response-content-type(concat("text/plain", "; charset=utf-8")), 
                        "You must specify a valid mime-type for serialization"
                    )
    else
            (
                xdmp:set-response-code(400, "Bad Request"), 
                xdmp:set-response-content-type(concat("text/plain", "; charset=utf-8")), 
                "You must include an authority label and an authority URI, these are required parameters"
            )