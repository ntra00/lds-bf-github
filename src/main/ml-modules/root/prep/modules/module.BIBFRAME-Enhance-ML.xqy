xquery version "1.0-ml";

(:
:   Module Name: bibframe Enhance ML
:
:   Module Version: 1.0
:
:   Date: 2012 Sept 27
:
:   Copyright: Public Domain
:
:   Proprietary XQuery Extensions Used: xdmp, search
:
:   Xquery Specification: January 2007
:
:   Module Overview:    Enahnces bibframe parts using ML extensions.  
:
:)
   
(:~
:   Enhances bibframe nodes with uris from ID, performs lookups to 
:	external annotation sites like catdir.
:   Uses the *raw* transform from MARCXML-2-bibframe.  
:
:   @author Nate Trail (ntra@loc.gov)
:   @since September 27, 2012
:   @version 1.0
:)
        

(: NAMESPACES :)
module namespace bibframeenhance  = 'info:lc/id-modules/bibframe-enhance#';


import module namespace constants       = 'info:lc/id-modules/constants#' at "../constants.xqy";
import module namespace marcbib2bibframe  = 'info:lc/id-modules/marcbib2bibframe#' at "module.MARCXMLBIB-2-BIBFRAME.xqy";
import module namespace search = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";
import module namespace shared      = "info:lc/id-modules/shared#" at "module.Shared.xqy";

declare namespace marcxml       = "http://www.loc.gov/MARC21/slim";
declare namespace rdf           = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfs          = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace bf            = "http://bibframe.org/vocab/";
declare namespace bf2           = "http://bibframe.org/vocab/2";(: additional terms :)
declare namespace madsrdf       = "http://www.loc.gov/mads/rdf/v1#";
declare namespace lcc			= "http://id.loc.gov/ontologies/lcc#";
declare namespace identifiers	= "http://id.loc.gov/vocabulary/identifiers/";
declare namespace relators      = "http://id.loc.gov/vocabulary/relators/";
declare namespace xdmp 			= "http://marklogic.com/xdmp";
declare namespace xdmphttp      = "xdmp:http";
declare namespace dcterms       = "http://purl.org/dc/terms/";
declare namespace cnt           = "http://www.w3.org/2011/content#";
(: Future work: find identifiers at various lookup sites:

ean: 	bibid:14706113: http://www.ean-search.org/perl/ean-search.pl?q=637051004321
upc:	bibid: 14068812 : http://www.upc-search.org/perl/upc-search.pl?q=821689011725
:)
(:~
:   This is the main function.  It expects bibframe RDF as input.
:   It generates bibframe RDF data as output.
:
:   @param  $bibframe        element is the MARCXML  
:   @return rdf:RDF as element()
:)
declare function bibframeenhance:bibframe-enhance(
        $bibframe as element(rdf:RDF)
        ) as element(rdf:RDF) 
{ 

    let $bibframe := bibframeenhance:process(document{$bibframe})
    (: 
        The below is a temporary hack. During the load process, the BIBIDs 
        were inadvertently left off the bf:consolidates property.
        This puts them in there.
        Also, annotates properties were duplicated.
    :)
    (: let $bibframe_all := $bibframe/bf:* some stuff in other namespaces:)
	let $bibframe_all := $bibframe/*
	let $bibid:= fn:substring-after(fn:string($bibframe_all/@rdf:about),"/bibs/")               		  
	let $bibid:= if (fn:not($bibid)) then
	               fn:substring-after(fn:string($bibframe_all/@rdf:about),"/works/c")
	             else $bibid
	let $bibid:= if (fn:not($bibid)) then
	               fn:substring-after(fn:string($bibframe_all/@rdf:about),"/works/lw")
	             else $bibid
let $bibid:=fn:replace($bibid,"^0+","")
let $illus-uri:= fn:concat($constants:BASE_COVERART_URL  , "loc.natlib.lcdb.",$bibid,"/thumb")    
let $illus:= 
        try{xdmp:http-head(
            $illus-uri           
        )}
		catch ($e) {()}
    
    let $bibframe_all := 
        element rdf:RDF { $bibframe/@*,
        (for $bibframe in $bibframe_all 
            return
            if (fn:name($bibframe)="bf:Work" or fn:name($bibframe)="bf:Annotation") then            
            	element {fn:name($bibframe)} {
                    $bibframe/@*,
				    if ( xs:string($illus[1]//xdmphttp:code[1]) = "200") then
                            element bf:hasIllustration{$illus-uri}
                    else (),
                    $bibframe/child::node()[fn:name() ne "bf:consolidates" and fn:name() ne "bf:annotates" and fn:name() ne "bf:classification"],
                
                    for $a in fn:distinct-values($bibframe/bf:annotates/bf:Work/@rdf:about)
                    return $bibframe/bf:annotates[bf:Work[xs:string(@rdf:about) eq $a]][1],
              		(:for $a in fn:distinct-values($bibframe//bf:LCC/@rdf:about)              		  
                    	return element bf:classification {$bibframe//bf:LCC[fn:string(@rdf:about) eq $a][1]},:)
                    
                    for $a in fn:distinct-values($bibframe/bf:annotates/@rdf:resource)
                    return 
                        element bf:annotates {
                            attribute rdf:resource {$a}
                        },
                
                    if ( xs:string($bibframe/bf:consolidates[1]/@rdf:resource) eq "http://id.loc.gov/resources/bibs/") then
                        let $dFrom := $bibframe/bf:derivedFrom[1]/@rdf:resource
                        return
                            for $i in $bibframe/bf:hasInstance/bf:Instance/bf:derivedFrom/@rdf:resource
                            where $i ne $dFrom
                            return
                                element bf2:consolidates {
                                    $i
                                }
                else(), 

               	if (fn:name($bibframe)="bf:Work") then    
               		(:for consolidated works, need to find multiple derived-froms, and get all their holdings;
               		for now this will duplicate all the 050 classes... needs work:)
               		let $allclasses:=
               			for $record in $bibframe_all//bf:derivedFrom               			
               				let $bibid:= fn:substring-after(fn:string($record/@rdf:resource),"/bibs/")               		  
               				return 
               				if ($bibid!='') then (:the second var should be the 050, but at this point, 
               									there's no way to tell if the work is a consolidation:)
               					
									bibframeenhance:holdings-lcc($bibid  ,$bibframe_all//bf:LCC[1] )
								
               				else ()
               			return
               				for $item in fn:distinct-values($allclasses/bf:LCC/bf:label)
               					return                					               					
               					element bf:class {($allclasses/bf:LCC[fn:string(bf:label)=$item])[1]}               						               					
           		else ()				
            }
            else
            	$bibframe                             
			)            	         
        }
    return  $bibframe_all    
	
};

(:typeswitch to copy or enhance each node:)
declare function bibframeenhance:process($nodes ) as item()* {
 
 for $node in $nodes
    return 
    typeswitch($node)
        case text() 		return $node               
        case element() 		return bibframeenhance:decide($node, fn:name($node))     
        default 			return bibframeenhance:process($node/node())
 
};


declare  function bibframeenhance:decide($node , $node-name as xs:string)  
{
(:enhance names, subjects, titles, lcc
all else: copy
:)
 
    if (fn:matches($node-name, "(bf:Person|bf:Organization|bf:Meeeting)" ) ) then 
    	bibframeenhance:enhance-name($node)
    else if (fn:matches($node-name, "bf:Topic")) then
    	bibframeenhance:enhance-topic($node)
   
    else if (fn:matches($node-name, "bf:Genre")) then
    	bibframeenhance:enhance-genre($node)        
     else if (fn:matches($node-name, "bf:Instance")) then     
  	(:adds holdings and cover art links to each Instance:)
        bibframeenhance:enhance-instance($node)
  	else if (fn:matches($node-name, "bf:copyrightDocumentID")) then     
  		bibframeenhance:enhance-copyright($node)
    else if (fn:matches($node-name, "bf:Place")) then
    	bibframeenhance:enhance-place($node)            	
    else if (($node-name="bf:instance" or $node-name="bf:annotation") and $node/@rdf:resource) then
        bibframeenhance:enhance-instance-annotation($node)
  
    else if (fn:matches($node-name, "(bf:link|bf:annotation-service)") and fn:not($node/@rdf:resource) ) then            
             element {$node-name} {
                attribute rdf:resource { xs:string($node) }
            }
    else if (fn:matches($node-name, "bf:hasInstance") and $node/@rdf:resource)then
        bibframeenhance:enhance-instance-label($node)
    else if (fn:matches($node-name, "(bf:Work)") and fn:not($node/@rdf:about) ) then    
        bibframeenhance:enhance-work($node)
    else     	
		element {$node-name} { 		
     					for $att in $node/@*
              			 return $att
           			 ,
                	bibframeenhance:process($node/node())
        }     	  
};
(:
add try/catch to id header lookups
:)
declare function bibframeenhance:check-id-head(
	$uri2check as xs:string    
    )
{
let $x:=
    try { 
		fn:string( xdmp:http-head($uri2check)//xdmphttp:x-uri	)
	}
		
	catch ($e) {
		(:"error on id header lookup", but just return blank; nothing found to enhance:)
		""
	}   
return $x	
};
(: gets prefLabel and  a uri, now that .rdf returns x-preflabel
:)
declare function bibframeenhance:check-id-head-forPrefLabel(
	$uri2check as xs:string    
    )
{
let $check:=
    try { 
		xdmp:http-head($uri2check)
	}		
	catch ($e) {
		(:"error on id header lookup", but just return blank; nothing found to enhance:)
		()
	}  
	 
return
	
	if ($check) then (
			fn:string($check//xdmphttp:x-uri),
			fn:string($check//xdmphttp:x-preflabel)
		)
	else ()
	
};
(:
add try/catch to id header lookups with 302 checking (names...)
:)
declare function bibframeenhance:check-id-head302(
	$uri2check as xs:string    
    ) 
{

    try {		
		let $id-response := xdmp:http-head($uri2check)
        return
                if ( xs:string($id-response[1]//xdmphttp:code[1]) = "302") then
                    $id-response[1]//xdmphttp:x-uri
                else
                    ""
	   }
		
	catch ($e) {
	   	(:"error on id header lookup", but just return blank; nothing found to enhance:)
		""
	}   	

};
(:~
:   This function enhances a bf:instance beyond simply being a link.
:
:   @param  $name       element is bf:instance  
:   @return name+       enhanced with attribute rdf:about  if found at id 
:)
declare function bibframeenhance:enhance-instance-annotation(
    $property as element()
    ) as element()
{

    let $url := xs:string($property/@rdf:resource)
    let $url := fn:replace($url, "http://id.loc.gov/", $constants:BASE_APP_URL)
    let $url := fn:concat($url,".bibframe_raw.rdf")
    let $httpget := 
        xdmp:http-get(
            $url,
            <options xmlns="xdmp:http-get">
                <format xmlns="xdmp:document-get">xml</format>
            </options>
        )
    let $propName := 
        if (fn:name($property) eq "bf:instance") then
            "bf:instance"
        else if (fn:name($property) eq "bf:instanceOf") then
            "bf:instanceOf"
        else if (fn:name($property) eq "bf:annotates") then
            "bf:annotates"
             else if (fn:name($property) eq "bf:holdingFor") then
            "bf:holdingFor"
        else
            "bf:annotation"
    
    return 
        if ( xs:string($httpget[1]/xdmphttp:code) eq "200" ) then
            let $i := $httpget[2]/rdf:RDF/bf:*[1]
            return
                element {$propName} {
                    element {fn:name($i[1])} {                    
                        $i/@*,                        
                        $i/rdf:type,
                        $i/madsrdf:authoritativeLabel,
                        $i/bf:uniformTitle,
                        $i/bf:atitle,
                        $i/bf:title,
                        $i/bf:label,
                        $i/bf:link,                        
                        $i/bf:contributor,
                        $i/bf:date,
                        $i/bf:derivedFrom
                        
                    }
                }
        else
            $property
};

declare function bibframeenhance:enhance-instance-label(
    $property as element()
    ) as element()
{
   let $propName := fn:name($property)
   let $url := fn:concat(shared:rewrite-uri($property/@rdf:resource), ".rdf")
   let $httpget := xdmp:http-get(
                   $url,
                   <options xmlns="xdmp:http-get">
                   <format xmlns="xdmp:document-get">xml</format>
                   </options>
                   )
   let $iTitle := (if ( xs:string($httpget[1]/xdmphttp:code) eq "200" ) then
                   let $i := $httpget[2]/rdf:RDF/bf:*[1]
                       return
                       if($i//bf:authorizedAccessPoint[fn:not(@xml:lang eq "x-bf-hash")][1]) then
                          $i//bf:authorizedAccessPoint[1]
                       else if($i//bf:Title[1]/bf:label) then
                          $i//bf:Title[1]/bf:label
                       else if($i//bf:Title[1]/bf:titleValue) then
                          $i//bf:Title[1]/bf:titleValue
                       else()
                    else())
   return
        if ( xs:string($httpget[1]/xdmphttp:code) eq "200" ) then
            let $i := $httpget[2]/rdf:RDF/bf:*[1]
            return
                element {$propName} {
                    element {fn:name($i[1])} {   
                            attribute rdf:about {shared:rewrite-uri($property/@rdf:resource)},
                            element rdfs:label {
                                text{$iTitle}
                        }
                    }
                }
        else
            $property
                                                   
};


(:~
:   This function enhances a bibframe name with links to id.loc.gov.
:   It takes one of 3 datafields as input: name, organization, meeting
:   It adds a rdf:about link as output, if found, then get the authoritative label and rdftype from id.
:
:   @param  $name       element is the bf:Person, bf:Organization, bf:Meeting  
:   @return name+		enhanced with attribute rdf:about  if found at id 
:)
declare function bibframeenhance:enhance-name(
    $name as element() 
    ) as element() 
	{ 
	
    let $name:=
        if ($name/bf:*[1]/bf:label) then
            $name/bf:*[1]
        else
            $name
    let $name-type:=fn:name($name)
    (: kefo - removed period because of how common it is in names :)
    let $label := for $n in $name[1]/bf:label[1] 
                    return fn:replace(fn:string($n),"(,)$","")
    let $encoded-label:=fn:encode-for-uri(fn:replace($label,"(,)$",""))
    let $id-check:=fn:concat($constants:BASE_APP_URL_PROD,"/authorities/names/label/",$encoded-label,".rdf")
    (:let $id-response := xdmp:http-head($id-check)
    let $id-uri:= 
        if ( xs:string($id-response[1]//xdmphttp:code[1]) = "302") then
            $id-response[1]//xdmphttp:x-uri
        else
            "":)
    let $id-uri:=bibframeenhance:check-id-head302($id-check)

	let $id-uri := 
        if ($id-uri = "" ) then
            let $encoded-label :=fn:encode-for-uri(fn:replace($label,"(\.|,)$",""))
            let $id-check :=fn:concat($constants:BASE_APP_URL_PROD,"authorities/names/label/",$encoded-label,".rdf")
            (:let $id-response := xdmp:http-head($id-check):)            
            (:let $id-uri:= 
                if ( xs:string($id-response[1]//xdmphttp:code[1]) = "302") then
                    $id-response[1]//xdmphttp:x-uri
                else
                    ""
                    return $id-uri:)
             return
                bibframeenhance:check-id-head302($id-check)
            
        else
            $id-uri
   
            
    return
        element {$name-type} {          
             if ($id-uri!="" ) then
                	attribute rdf:about {$id-uri} 
               	else (),
           
                if ($id-uri!="" ) then
            	    let $id-url:= fn:concat($id-uri,".madsrdf_raw.rdf")
    				let $id-doc:=xdmp:http-get($id-url)[2]
     				return 
     				   (
     				   $id-doc/rdf:RDF/child::*[1]/madsrdf:authoritativeLabel,
     				   $name/bf:label,
     				   $id-doc/rdf:RDF/child::*[1]/rdf:type,
     				   $name/bf:*[fn:name ne "bf:label"],
     				    $name/rdfs:label
     				   )     				   				     				
                else 
                	(   
                	   element bf:label {$label},
                		$name/*[fn:not(fn:matches(fn:name(),"(bf:label)"))]
                	)              
        }
};
(:~
:   This function enhances a bibframe name with links to id.loc.gov.
:   It takes one of 3 datafields as input: name, organization, meeting
:   It adds a rdf:about link as output, if found, then get the authoritative label and rdftype from id.
:
:   @param  $name       element is the bf:Person, bf:Organization, bf:Meeting  
:   @return name+		enhanced with attribute rdf:about  if found at id 
:)
declare function bibframeenhance:enhance-instance(
    $instance as element() 
    ) as element() 
	{ 
	let $bibid:= if ($instance//bf:derivedFrom) then
				 fn:substring-before(fn:substring-after(fn:string(($instance//bf:derivedFrom)[1]/@rdf:resource),"bibs/")   ,".marcxml.xml")
				 else if ($instance/@rdf:about) then
				 	let $bib:=fn:substring-after($instance/@rdf:about,"instances/")
					let $bib:=fn:replace($bib,"^c0?","")
					return fn:replace($bib,"000[1-9]$","")
				 else ()

    let $name-type:=fn:name($instance)
    let $label := fn:replace($instance/bf:label,"(\.|,)$","")
    let $encoded-label:=fn:encode-for-uri(fn:replace($instance,"(\.|,)$",""))
    (:??? cleanstring???:)
    (:let $id-check:=fn:concat($constants:BASE_APP_URL_PROD,"resources/hlds/",$bibid,".marcxml.xml"):)
    let $id-check:= fn:concat($constants:BASE_APP_URL,"resources/hlds/",$bibid,".marcxml.xml")
   	(:let $id-uri:= fn:string(xdmp:http-head($id-check)[1]//xdmphttp:code)
   	:)
   	let $id-uri:=bibframeenhance:check-id-head($id-check)
    let $holdings-uri := fn:concat("http://id.loc.gov/resources/hlds/",$bibid,".marcxml.xml")
    
    let $illus-uri:= fn:concat($constants:BASE_COVERART_URL  , "loc.natlib.lcdb.",$bibid,"/thumb")    
    let $illus:= 
        try{xdmp:http-head(
            $illus-uri
           
        )}
		catch ($e) {()}

    return
        element bf:Instance {  
            $instance/@*,       
            bibframeenhance:process($instance/*),
            element bf:hasIllustration{ fn:concat($constants:BASE_COVERART_URL  ,  "loc.natlib.lcdb.",$bibid,"/thumb")    },             
             
            if ( xs:string($illus[1]//xdmphttp:code[1]) = "200") then
             element bf:hasIllustration{$illus-uri}
                (:element bf:hasIllustration {
                 element bf:Annotation {
                    for $elm in $illus[2]/rdf:RDF/bf:Annotation/*
                        return if (fn:local-name($elm)="link") then
                                    element bf:link {
                                        attribute rdf:resource{fn:replace (fn:string($elm/@rdf:resource),'http://loccatalog.loc.gov','http://marklogic4.loc.gov')}
                                        }                     
                                else                
                                $elm
                             }
                    }:)
            else (),
        
            if ($id-uri="200") then
                element bf:hasHolding {attribute rdf:resource {$holdings-uri} }
            else ()
        }
};

declare function bibframeenhance:enhance-topic(
    $subject as element()
    ) as element()
{
    let $subject-type:=fn:name($subject)
    let $aLabel := fn:replace($subject/bf:authorizedAccessPoint,"\.$","")    
    let $id-check:=fn:concat($constants:BASE_APP_URL_PROD,"authorities/subjects/label/",fn:encode-for-uri($aLabel),".rdf")
    (:let $id-uri:= fn:string(xdmp:http-get($id-check)//xdmphttp:x-uri):)
    let $id-uri:= bibframeenhance:check-id-head($id-check)
     
    return
        element {$subject-type} {        
             if ($id-uri!="")  then
                attribute rdf:about {$id-uri} 
               else(),                    
             if ($id-uri!="")  then
                	let $id-url:= fn:concat($id-uri,".madsrdf_raw.rdf")
    				let $id-doc:=xdmp:http-get($id-url)[2]
                	return $id-doc/rdf:RDF/child::*[1]/*[fn:matches(fn:name(),"(madsrdf:authoritativeLabel|rdf:type)")]
                else 
                	(	element madsrdf:authoritativeLabel {$aLabel},
                		element madsrdf:isMemberOfMADSCollection { 
                		attribute rdf:resource {fn:concat($constants:BASE_APP_URL_PROD,"authorities/names/collection_UndifferentiatedTopics")}}
                	),
                	(:for $node in $subject/*[fn:not(fn:matches(fn:name(),"(bf:label|madsrdf:authoritativeLabel)"))]
                	return	bibframeenhance:process($node),:)
                	 element bf:label {$aLabel}
        }

};

(:nametitle ex: 16938761 doesn't find anything... only look up ut's?
16772394 bible in 630
starts at bf:Work
1: check title only
2) check nametitle in authoritativeLabel
2) check uniformTitle ??
3)??? check previously stored works in a second pass, or once they're set up??? 
CORRECTION: this only addds the illustration.
:)
declare function bibframeenhance:enhance-work(
    $work as element()
    ) as element()
{  	

    let $aLabel := xs:string($work/madsrdf:authoritativeLabel[1])
    let $work-check:=fn:concat($constants:BASE_APP_URL,"resources/works/label/",fn:encode-for-uri($aLabel),".rdf")
    (:let $work-uri:= fn:string(xdmp:http-head($work-check)//xdmphttp:x-uri):)
    let $work-uri:= bibframeenhance:check-id-head($work-check)
    return
        if ($work-uri!="") then
            element {fn:name($work[1])} {
                attribute rdf:about { shared:rewrite-uri($work-uri) },
                $work/@*,
                $work/*
            }
        else 
            $work
   
};
(:places ex: 15991996
searches subjects first, then names if not found
geographic ex: 15991996
geographic starts with authlabel, place startsw ith bf:label, but both have bf:label
multiple bf:label means 2 langs.
043 geographicCode has uri in @rdf:about
:)
declare function bibframeenhance:enhance-place(
    $place as element()
    ) as element()
{

if ($place/@rdf:about) then
 let $id-url:= fn:concat(fn:string($place/@rdf:about)  ,".madsrdf_raw.rdf")
 let $id-doc:=xdmp:http-get($id-url)[2]
    return
        element {fn:name($place)} {                        
                 attribute rdf:resource {fn:string($place/@rdf:about)},               
                	 $id-doc/rdf:RDF/child::*[1]/*[fn:matches(fn:name(),"(madsrdf:authoritativeLabel|madsrdf:code|rdf:type)")]
        	}
else
    
    (:geographic starts with authlabel, place starts with bf:label, but both have bf:label:)     
    (:
        kefo - Removed period matching becuase it removed it from N.Y.
    :)
    let $label :=  fn:replace(fn:string($place/bf:label[fn:not(@xml:lang) or @xml:lang = "en"]),"(\.|;|:)$","")
                                
(:    let $name-label := fn:replace($place/bf:label[fn:not(@xml:lang) or @xml:lang = "en"] ,"(\.|;| : ) $","") ...the colon paren is not the end of a comment inside the $... :)
                                                                                            
    (:let $place-type:=fn:name($place):)
        
    let $id-subject-check:=fn:concat($constants:BASE_APP_URL_PROD,"authorities/subjects/label/",fn:encode-for-uri($label),".rdf")
    (:let $id-uri:= fn:string(xdmp:http-head($id-subject-check)//xdmphttp:x-uri):)
    let $id-uri:= bibframeenhance:check-id-head($id-subject-check)
     let $id-uri:=
      	  if ($id-uri = "" and fn:matches($label,"(\.|,)$") ) then
    		let $id-name-check:=fn:concat($constants:BASE_APP_URL_PROD,"authorities/names/label/",fn:encode-for-uri($label ),".rdf")
    		(:return fn:string(xdmp:http-head($id-name-check)//xdmphttp:x-uri):)
    		return bibframeenhance:check-id-head($id-name-check)
    	else $id-uri
    	
    let $label := fn:replace(fn:string($place/bf:label[fn:not(@xml:lang) or @xml:lang = "en"]) ,"(;|:)$","")
    (:let $name-label := fn:replace($place/bf:label ,"(;| : )$",""):)
    	
    return
        element {fn:name($place)} {          
              if ($id-uri!="") then
                 attribute rdf:about {fn:string($id-uri)} 
               else(),               
             if ($id-uri!="") then
                	let $id-url:= fn:concat($id-uri,".madsrdf_raw.rdf")
    				let $id-doc:=xdmp:http-get($id-url)[2]
                	return $id-doc/rdf:RDF/child::*[1]/*[fn:matches(fn:name(),"(madsrdf:authoritativeLabel|rdf:type)")]
	            else (),
              element bf:label {$label},
              $place/bf:label[@xml:lang and @xml:lang != "en"],
              $place/rdfs:label           
        }
};
(: places ex: 15991996
searches subjects first, then names if not found
geographic ex: 15991996
geographic starts with authlabel, place startsw ith bf:label, but both have bf:label
043 geographicCode
:)
declare function bibframeenhance:enhance-gac(
    $place as element()
    ) as element()
{
    let $place-type:=fn:name($place)
    (:geographic starts with authlabel, place startsw ith bf:label, but both have bf:label:)
    let $label := fn:replace($place/bf:label ,"(\.|:|;)$","")
    
    
    let $id-uri:= fn:string($place/@rdf:about)
           
    	
    return
        element {$place-type} {          
              if ($id-uri!="") then
                 attribute rdf:resource {$id-uri} 
               else(),            
            
             if ($id-uri!="") then
                	let $id-url:= fn:concat($id-uri,".madsrdf_raw.rdf")
    				let $id-doc:=xdmp:http-get($id-url)[2]
                	return $id-doc/rdf:RDF/child::*[1]/*[fn:matches(fn:name(),"(madsrdf:authoritativeLabel|madsrdf:code|rdf:type)")]
	            else ()
                                     
        }
};
(:genre
:)
declare function bibframeenhance:enhance-genre(
    $genre as element()
    ) as element()
{
    let $genre-type:=fn:name($genre)
    
    let $label := fn:replace($genre/madsrdf:authoritativeLabel  ,"(\.|:|;)$","")
  
 
    let $id-gf-check:=fn:concat($constants:BASE_APP_URL_PROD,"authorities/genreForms/label/",fn:encode-for-uri($label),".rdf")
     (:let $id-uri:= fn:string(xdmp:http-head($id-gf-check)//xdmphttp:x-uri):)
	let $id-uri:=bibframeenhance:check-id-head($id-gf-check)
     let $id-uri:=
      	if ($id-uri="") then
    		let $id-subject-check:=fn:concat($constants:BASE_APP_URL_PROD,"authorities/subjects/label/",fn:encode-for-uri($label),".rdf")
    		return fn:string(xdmp:http-head($id-subject-check)//xdmphttp:x-uri)
    	else $id-uri
    	
    return
        element {$genre-type} {          
              if ($id-uri!="") then
                 attribute rdf:resource {fn:string($id-uri)} 
               else(),               
             if ($id-uri!="") then
                	let $id-url:= fn:concat($id-uri,".madsrdf_raw.rdf")
    				let $id-doc:=xdmp:http-get($id-url)[2]
                	return $id-doc/rdf:RDF/child::*[1]/*[fn:matches(fn:name(),"(madsrdf:authoritativeLabel|rdf:type)")]
	            else (),
              element bf:label {$label}                         
        }
};
(:  search id for class b,n,m,z auth label
:) 
declare function bibframeenhance:enhance-lcc(	 $lcc  ) {
    if (fn:exists($lcc)) then
    for $cl in $lcc
	    let $id-url:=fn:concat(fn:string($cl/@rdf:about),".madsrdf_raw.rdf")
	    let $id-doc:=xdmp:http-get($id-url)[2]
	    let $aLabel:=$id-doc/rdf:RDF/lcc:ClassNumber/madsrdf:authoritativeLabel    
    
    return
       	 element bf:LCC  {          		   	
             if (fn:exists($id-doc) ) then
        		$cl/@rdf:about else (),
        		
             if ( xs:string($id-doc[1]//xdmphttp:code[1]) = "200") then
             (             
             	element rdf:type { attribute rdf:resource {fn:concat($constants:BASE_APP_URL_PROD,"ontologies/lcc#ClassNumber")} },        
                $id-doc/rdf:RDF/child::*[1]/*[fn:matches(fn:name(),"(madsrdf:authoritativeLabel|madsrdf:code|rdf:type|rdfs:label)")]
                )               
               else
               	$cl/bf:label,
              $cl/*[fn:not(fn:matches(fn:name(),"bf:label"))]        
        	}
else ()
};
  (:  search id for bnmz auth label in 852$h's (distinct-values)
  bibid is the ILS bibid
:) 
(::~
:   This function enhances a bibframe class with links to id.loc.gov.
:   It takes the bib id as input, and the 050 class string.  All holdings associated with the bib are
:	found and deduped and validated.
:	It builds a bf:LCC element for each, then enhances it with the search in ID
:
:   @param  $bibid       string is the ILS bib id
:	@param $class-050	 element 
:   @return bf:LCC 	 
:)
declare function bibframeenhance:holdings-lcc(
 $bibid as xs:string , $class-050  as element()* )  {
          
    let $holds-url:= fn:concat($constants:BASE_APP_URL,"resources/hlds/",$bibid,".marcxml.xml")
    let $holds:=xdmp:http-get($holds-url)[2]
    let $validLCC:=("DAW","DJK","KBM","KBP","KBR","KBU","KDC","KDE","KDG","KDK","KDZ","KEA","KEB","KEM","KEN","KEO","KEP","KEQ","KES","KEY","KEZ","KFA","KFC","KFD","KFF","KFG","KFH","KFI","KFK","KFL","KFM","KFN","KFO","KFP","KFR","KFS","KFT","KFU","KFV","KFW","KFX","KFZ","KGA","KGB","KGC","KGD","KGE","KGF","KGG","KGH","KGJ","KGK","KGL","KGM","KGN","KGP","KGQ","KGR","KGS","KGT","KGU","KGV","KGW","KGX","KGY","KGZ","KHA","KHC","KHD","KHF","KHH","KHK","KHL","KHM","KHN","KHP","KHQ","KHS","KHU","KHW","KJA","KJC","KJE","KJG","KJH","KJJ","KJK","KJM","KJN","KJP","KJR","KJS","KJT","KJV","KJW","KKA","KKB","KKC","KKE","KKF","KKG","KKH","KKI","KKJ","KKK","KKL","KKM","KKN","KKP","KKQ","KKR","KKS","KKT","KKV","KKW","KKX","KKY","KKZ","KLA","KLB","KLD","KLE","KLF","KLH","KLM","KLN","KLP","KLQ","KLR","KLS","KLT","KLV","KLW","KMC","KME","KMF","KMG","KMH","KMJ","KMK","KML","KMM","KMN","KMP","KMQ","KMS","KMT","KMU","KMV","KMX","KMY","KNC","KNE","KNF","KNG","KNH","KNK","KNL","KNM","KNN","KNP","KNQ","KNR","KNS","KNT","KNU","KNV","KNW","KNX","KNY","KPA","KPC","KPE","KPF","KPG","KPH","KPJ","KPK","KPL","KPM","KPP","KPS","KPT","KPV","KPW","KQC","KQE","KQG","KQH","KQJ","KQK","KQM","KQP","KQT","KQV","KQW","KQX","KRB","KRC","KRE","KRG","KRK","KRL","KRM","KRN","KRP","KRR","KRS","KRU","KRV","KRW","KRX","KRY","KSA","KSC","KSE","KSG","KSH","KSK","KSL","KSN","KSP","KSR","KSS","KST","KSU","KSV","KSW","KSX","KSY","KSZ","KTA","KTC","KTD","KTE","KTF","KTG","KTH","KTJ","KTK","KTL","KTN","KTQ","KTR","KTT","KTU","KTV","KTW","KTX","KTY","KTZ","KUA","KUB","KUC","KUD","KUE","KUF","KUG","KUH","KUN","KUQ","KVB","KVC","KVE","KVH","KVL","KVM","KVN","KVP","KVQ","KVR","KVS","KVU","KVW","KWA","KWC","KWE","KWG","KWH","KWL","KWP","KWQ","KWR","KWT","KWW","KWX","KZA","KZD","AC","AE","AG","AI","AM","AN","AP","AS","AY","AZ","BC","BD","BF","BH","BJ","BL","BM","BP","BQ","BR","BS","BT","BV","BX","CB","CC", "CD","CE","CJ","CN","CR","CS","CT","DA","DB","DC","DD","DE","DF","DG","DH","DJ","DK","DL","DP","DQ","DR","DS","DT","DU","DX","GA","GB","GC","GE","GF","GN","GR","GT","GV","HA","HB","HC","HD","HE","HF","HG","HJ","HM","HN","HQ","HS","HT","HV","HX","JA","JC","JF","JJ","JK","JL","JN","JQ","JS","JV","JX","JZ","KB","KD","KE","KF","KG","KH","KJ","KK","KL","KM","KN","KP","KQ","KR","KS","KT","KU","KV","KW","KZ","LA","LB","LC","LD","LE",  "LF","LG","LH","LJ","LT","ML","MT","NA","NB","NC","ND","NE","NK","NX","PA","PB","PC","PD","PE","PF","PG","PH","PJ","PK","PL","PM","PN","PQ","PR","PS","PT","PZ","QA","QB","QC","QD","QE","QH","QK","QL","QM","QP","QR","RA","RB","RC","RD","RE","RF","RG",   "RJ","RK","RL","RM","RS","RT","RV","RX","RZ","SB","SD","SF","SH","SK","TA","TC","TD","TE","TF","TG","TH","TJ","TK","TL","TN","TP","TR","TS","TT","TX","UA","UB","UC","UD","UE","UF","UG","UH","VA","VB","VC","VD","VE","VF","VG","VK","VM","ZA","A","B","C","D","E","F","G","H","J","K","L","M","N","P","Q","R","S","T","U","V","Z")
    let $holdings-nodes:=
    	for $class in fn:distinct-values($holds//marcxml:datafield[@tag="852"]/marcxml:subfield[@code="h"])             			
			let $strip := fn:replace(fn:string($class), "(\s+|\.).+$", "")			
			let $subclassCode := fn:replace($strip, "\d", "")			
			let $pre-enhanced:=
	            (: lc classes don't have a space after the alpha prefix, like DA1 vs "DA 1" :)
	            if (
	                fn:substring(fn:substring-after(fn:string($class), $subclassCode),1,1)!=' ' and 
	                $subclassCode = $validLCC 
	                ) then                                             
	                    element bf:LCC {														 							
	                        attribute rdf:about {fn:concat($constants:BASE_APP_URL_PROD,"authorities/classification/",fn:string($strip))},						
							element bf:label {fn:string($class)}	
	                    }	                
	            else (:invalid content in 852$h:)
	                ()  
	            return  
	            	if (fn:exists($pre-enhanced)) then 
	            		 bibframeenhance:enhance-lcc($pre-enhanced)
	            	else ()
	 let $lcc-set:= 	 		 								
		 			($holdings-nodes,
		 			if (fn:exists($class-050)) then
		 				bibframeenhance:enhance-lcc($class-050)
		 			else ()
		 			)
		 							
	return 
		if (fn:exists(fn:distinct-values($lcc-set//@rdf:about) )) then			
			for $hit in fn:distinct-values($lcc-set//@rdf:about)
				return
				element bf:class {
					$lcc-set[fn:string(@rdf:about)=$hit]
				}
		else ()
		

};
(:ex: 16098370 00823
post 1978 records can be looked up in copyright ils
:)
declare function bibframeenhance:enhance-copyright($copyright){

let $id:=fn:replace(fn:lower-case($copyright),"-\[\],\.?","")
let $idnum:=
	if (fn:starts-with($id,"csn")) then
		fn:concat('CSN',bibframeenhance:pad-integer(fn:substring-after($id,'csn'),9))
	else if (fn:starts-with($id,'tx')) then
		fn:concat('TX',bibframeenhance:pad-integer(fn:substring-after($id,'tx'),10))
	else if (fn:starts-with($id,'txu')) then
		fn:concat('TXu',bibframeenhance:pad-integer(fn:substring-after($id,'txu'),9))
	else if (fn:starts-with($id,'pau')) then
		fn:concat('PAu',bibframeenhance:pad-integer(fn:substring-after($id,'pau'),9))
	else if (fn:starts-with($id,'pa')) then
		fn:concat('PA',bibframeenhance:pad-integer(fn:substring-after($id,'pa'),10))
	else if (fn:starts-with($id,'pre')) then
		fn:concat('PRE',bibframeenhance:pad-integer(fn:substring-after($id,'pre'),9))
	else if (fn:starts-with($id,'re')) then
		fn:concat('RE',bibframeenhance:pad-integer(fn:substring-after($id,'re'),10))
	else if (fn:starts-with($id,'sru')) then
		fn:concat('SRu',bibframeenhance:pad-integer(fn:substring-after($id,'sru'),9))
	else if (fn:starts-with($id,'sr')) then
		fn:concat('SR',bibframeenhance:pad-integer(fn:substring-after($id,'sr'),10))
	else if (fn:starts-with($id,'vag')) then
		fn:concat('VAG',bibframeenhance:pad-integer(fn:substring-after($id,'vag'),9))
	else if (fn:starts-with($id,'vau')) then
		fn:concat('VAu',bibframeenhance:pad-integer(fn:substring-after($id,'vau'),9))
	else if (fn:starts-with($id,'va'))then 
		fn:concat('VA',bibframeenhance:pad-integer(fn:substring-after($id,'va'),10))
	else if (fn:starts-with($id,'vbp')) then
		fn:concat('VBP',bibframeenhance:pad-integer(fn:substring-after($id,'vbp'),9))
	else
		()
	return
		element bf:copyrightDocumentID {
			if (fn:exists($idnum)) then	
				(attribute rdf:resource {fn:concat("http://cocatalog.loc.gov/cgi-bin/Pwebrecon.cgi?DB=local&amp;CMD=",$idnum,"&amp;v3=1&amp;CNT=10&amp;v1=1")},
					element bf:label {$idnum})
			else $copyright/*		
			
		}
	};
	declare function bibframeenhance:pad-integer
  ( $int as xs:anyAtomicType? ,
    $length as xs:integer )  as xs:string {
       let $pad:=fn:string-length($int)
       return       
       	fn:concat(fn:string-join(for $i in 1 to ($length - $pad) return "0",""),$int)
       
 } ;
