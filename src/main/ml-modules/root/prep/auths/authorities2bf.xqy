xquery version "1.0-ml";

module namespace auth2bf = "http://loc.gov/ndmso/authorities-2-bibframe";

import module namespace bibframe2index    = "info:lc/id-modules/bibframe2index#"   at "/modules/module.BIBFRAME-2-INDEX.xqy";
import module namespace	bf4ts   		  = "info:lc/xq-modules/bf4ts#"   		   at "/modules/module.BIBFRAME-4-Triplestore.xqy";
import module namespace bibs2mets 		  = "http://loc.gov/ndmso/bibs-2-mets" 	at 	"/modules/module.bibs2mets.xqy";

declare namespace 	rdf					= "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace	rdfs   			    = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace 	madsrdf      		 = "http://www.loc.gov/mads/rdf/v1#";
declare namespace   mets       		 	= "http://www.loc.gov/METS/";
declare namespace   marcxml             = "http://www.loc.gov/MARC21/slim";
declare namespace   mxe					= "http://www.loc.gov/mxe";
declare namespace 	bf					= "http://id.loc.gov/ontologies/bibframe/";
declare namespace	bflc				= "http://id.loc.gov/ontologies/bflc/";
declare namespace 	idx 				= "info:lc/xq-modules/lcindex";
declare namespace 	index 				= "info:lc/xq-modules/lcindex";

declare namespace				lclocal				="http://id.loc.gov/ontologies/lclocal/";

declare variable $BASE-URI  as xs:string:="http://id.loc.gov/resources/works/";
(: 
	load a nametitle or title madsrdf doc (in mets wrapper) from id-main, rename the uri and OBJID from /authorities/names/n*.xml to /resources/works/lw*.xml
	also... add to collections?
this is run by load_names_daily, port 8203, relative to  /marklogic/id/natlibcat/ 
	need to reindex, new sem !!

 :)
 (:
 : this makes sure reloaded related stuff is deduped
 :)
declare function auth2bf:dedup-links($work, $prop-name,$resource-url) {

let $distinct:= fn:distinct-values($work/*[fn:name()=$prop-name]/@rdf:resource)

let $new-distinct:=  if (fn:matches(  $resource-url, $distinct ) ) then
					 					$distinct
									else
										($resource-url,  $distinct)
	  return 	
	    for $t in   $new-distinct
			 return 
			 element {$prop-name} {attribute  rdf:resource {$t} }

			 
};

(: 
this is for translations:
if there is a language, find  and link to relate to it's root doc
	 skipping lccn so we can do bibs as well...
	 works for auths,  bibs 2018-05-29
	also works for versions ? 240 $s libretto eg.
:)
declare function auth2bf:link2translations($bfraw-work,$lccn, $string2ignore, $workDBURI) {

	let $bfraw-work:= if ($bfraw-work/self::* instance of element(bf:Work)) then
					$bfraw-work
			else if ($bfraw-work/bf:Work) then
							$bfraw-work/bf:Work
						else
							$bfraw-work/rdf:RDF/*[1] (: down to bf:Work:)	
	
	let $matching :=
		if ($bfraw-work/bf:title[1]/bf:Title[1]/bflc:*[fn:matches(fn:local-name(),"^title[0-9]{2}MatchKey$")] !=''
			or $bfraw-work/bf:title[1]/bf:Title[fn:not(rdf:type)] (: not all have matchkeys :)
		   ) 
			 then	
	
				let $titlematchkey:= 		
		            for $t in $bfraw-work/bf:title[1]/bf:Title[1]
							return if ($t/bflc:*[fn:matches(fn:local-name(),"^title[0-9]{2}MatchKey$")]) then
		                				 fn:string($t/bflc:*[fn:matches(fn:local-name(),"^title[0-9]{2}MatchKey$")][1])		
									else fn:string($t/rdfs:label) (: $a$b ... may not work weelllll   :)
				
				let $titlematchkey:=fn:replace($titlematchkey,"/$","")
				let $titlematchkey:=fn:substring-before($titlematchkey,$string2ignore)

				let $nonsortTitle:=			 		
		            for $t in $bfraw-work/bf:title[1]/bf:Title[1]
							return $t/bflc:titleSortKey		                				 
				let $nonsortTitle:=fn:replace($nonsortTitle,"/$","")
				let $nonsortTitle:=fn:substring-before($nonsortTitle,$string2ignore)
				
				let $primarycontrib:= 
                        for $contrib in $bfraw-work/bf:contribution/bf:Contribution[rdf:type/@rdf:resource="http://id.loc.gov/ontologies/bflc/PrimaryContribution"][1][bf:agent/bf:Agent[1][fn:not(fn:contains(fn:string(@rdf:about), "Agent880"))]]
                        return        fn:string($contrib/bf:agent/bf:Agent[1][fn:not(fn:contains(@rdf:about, "Agent880"))]/bflc:*[fn:starts-with(fn:local-name(),'primaryContributorName')][1])
	
			    let $nameTitle :=	    
			         if (exists($titlematchkey) or exists($primarycontrib))  then
			                     concat($primarycontrib[1]," ",$titlematchkey)
			         else ()
				let $nameTitle:=fn:replace($nameTitle,"\[from old catalog\]",""	)
				let $nameTitle:=fn:normalize-space($nameTitle)
				let $nonsortNameTitle:=
				    if ($titlematchkey !=  $nonsortTitle ) then
                        fn:concat(fn:string($primarycontrib[1]), " ",$nonsortTitle)                       
                     else ()
                let $nonsortNameTitle:=fn:replace($nonsortNameTitle,"\[from old catalog\]",""	)                     
	            let $nonsortNameTitle:=fn:normalize-space($nonsortNameTitle)			
	
				let $search :=  
					 if ($nameTitle!="" and fn:not(fn:contains($nameTitle,"Untitled") ) ) then
							"try to link"
						else
							"skip link"	           		       
	        	(: if nonsortnametitle is different from nametitle, perform an OR search for it :)
	        	let $found:= if ($search = "try to link" ) then 
								let $searchcode:= 
								    if ($nonsortNameTitle!="") then
										 cts:and-not-query(
    										cts:and-not-query(
						                            cts:and-query(( 
						                                cts:collection-query("/resources/works/"),
														                 cts:collection-query("/catalog/"),
						            		                cts:or-query((cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "nameTitle"), xs:string($nonsortNameTitle), ("unstemmed", "case-insensitive", "punctuation-insensitive", "diacritic-insensitive"), 15) ,
                                            							  cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "nameTitle"), xs:string($nameTitle), ("unstemmed", "case-insensitive", "punctuation-insensitive", "diacritic-insensitive"), 15)
                                            ))
                                            
			            		        ))
                                    ,
						            		        cts:collection-query("/bibframe/stubworks/")
						            		        ),
										 cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "uri"),$workDBURI)
										 )
																		
											else
										   cts:and-not-query(
												cts:and-not-query(
								                            cts:and-query(( 
								                                cts:collection-query("/resources/works/"),
																 cts:collection-query("/catalog/"),
								            		            cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "nameTitle"), xs:string($nameTitle), ("unstemmed", "case-insensitive", "punctuation-insensitive", "diacritic-insensitive"), 15)            		            
								            		        )),
								            		        cts:collection-query("/bibframe/stubworks/")
								            		        ),
												 cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "uri"),$workDBURI)
											)
								(:let $_:=xdmp:log(concat ("CORB auth :  searching for ", $nameTitle),"info"):)
	
       	               			return
										   cts:search( fn:doc(), $searchcode,
				 							(cts:index-order(cts:element-reference(fn:QName("info:lc/xq-modules/lcindex", "materialGroup")),("descending")))
				                  			)[1 to 2]
                  			 else ()
			
				let $found:= if (  $found and fn:string( $found[1]//@OBJID) = $workDBURI and $found[2]) then 
							$found[2]
							else if ($found[1]) then
								$found[1]
								else ()
								
	   		return ( $found,
					 if ($found) then  					 							
						fn:string($found//@OBJID)
					 else ()
					 )		
    		
		else (: didn't  even look for found match :)
			()

	
	let $found-uri := if ($matching[2] and (fn:not($matching[2] = $workDBURI) ) ) then 
						fn:replace($matching[2],"loc.natlib.works.","")
				 else ()
	return if ($found-uri) then
			(	fn:concat($BASE-URI,$found-uri) 
				,	xdmp:log(fn:concat("CORB auth/bib : adding translation link from ",$workDBURI, " to ", $found-uri ),"info")
			)
		 else ()

};
 
 (: 
this is for relatedto Work: (not started yet)
if there is a language, find  and link to relate to it's root doc
	 skipping lccn so we can do bibs as well...
	not finished (ie barely started) 2018-03-08 . works for auths, starting on bibs 2018-05-29

	works in bibs; not used in auths
:)
(:
declare function auth2bf:link2relateds($bfraw-work,$lccn, $title-lang, $workDBURI) {

	let $bfraw-work:= if ($bfraw-work/self::* instance of element(bf:Work)) then
					$bfraw-work
			else if ($bfraw-work/bf:Work) then
							$bfraw-work/bf:Work
						else
							$bfraw-work/rdf:RDF/*[1] (: down to bf:Work:)			
	let $matching :=
		if ($bfraw-work/bf:title[1]/bf:Title[1]/bflc:*[fn:matches(fn:local-name(),"^title[0-9]{2}MatchKey$")] !=''
			or $bfraw-work/bf:title[1]/bf:Title[fn:not(rdf:type)] (: not all have matchkeys :)
		   ) 
			 then	
	
				let $titlematchkey:= 		
		            for $t in $bfraw-work/bf:title[1]/bf:Title[1]
							return if ($t/bflc:*[fn:matches(fn:local-name(),"^title[0-9]{2}MatchKey$")]) then
		                				 fn:string($t/bflc:*[fn:matches(fn:local-name(),"^title[0-9]{2}MatchKey$")][1])		
									else fn:string($t/rdfs:label) (: $a$b ... may not work weelllll   :)
				
				let $titlematchkey:=fn:replace($titlematchkey,"/$","")
				let $titlematchkey:=fn:substring-before($titlematchkey,$title-lang)

				let $nonsortTitle:=			 		
		            for $t in $bfraw-work/bf:title[1]/bf:Title[1]
							return $t/bflc:titleSortKey		                				 
				let $nonsortTitle:=fn:replace($nonsortTitle,"/$","")
				let $nonsortTitle:=fn:substring-before($nonsortTitle,$title-lang)
				
				let $primarycontrib:= 
                        for $contrib in $bfraw-work/bf:contribution/bf:Contribution[rdf:type/@rdf:resource="http://id.loc.gov/ontologies/bflc/PrimaryContribution"][1][fn:not(fn:contains(bf:agent/bf:Agent[1]/@rdf:about, "Agent880"))][1]
                        return        fn:string($contrib/bf:agent/bf:Agent[1][fn:not(fn:contains(@rdf:about, "Agent880"))]/bflc:*[fn:starts-with(fn:local-name(),'primaryContributorName')][1])
	
			    let $nameTitle :=	    
			         if (exists($titlematchkey) or exists($primarycontrib))  then
			                     concat($primarycontrib[1]," ",$titlematchkey)
			         else ()
				let $nameTitle:=fn:replace($nameTitle,"\[from old catalog\]",""	)
				let $nonsortNameTitle:=
				    if ($titlematchkey !=  $nonsortTitle ) then
                        fn:concat(fn:string($primarycontrib), " ",$nonsortTitle)                       
                     else ()
                let $nonsortNameTitle:=fn:replace($nonsortNameTitle,"\[from old catalog\]",""	)                     
				
				
	
				let $search :=  
					 if ($nameTitle!="" and fn:not(fn:contains($nameTitle,"Untitled") ) ) then
							"try to link"
						else
							"skip link"	           		       
	        	(: if nonsortnametitle is different from nametitle, perform an OR search for it :)
	        	let $found:= if ($search = "try to link" ) then 
								let $searchcode:= 
								    if ($nonsortNameTitle) then
										 cts:and-not-query(
    										cts:and-not-query(
						                            cts:and-query(( 
						                                cts:collection-query("/resources/works/"),
														                 cts:collection-query("/catalog/"),
						            		                cts:or-query((cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "nameTitle"), xs:string($nonsortNameTitle), ("unstemmed", "case-insensitive", "punctuation-insensitive", "diacritic-insensitive"), 15) ,
                                            							  cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "nameTitle"), xs:string($nameTitle), ("unstemmed", "case-insensitive", "punctuation-insensitive", "diacritic-insensitive"), 15)
                                            ))
                                            
			            		        ))
                                    ,
						            		        cts:collection-query("/bibframe/stubworks/")
						            		        ),
										 cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "uri"),$workDBURI)
										 )
									
									
											else
								   cts:and-not-query(
										cts:and-not-query(
						                            cts:and-query(( 
						                                cts:collection-query("/resources/works/"),
														 cts:collection-query("/catalog/"),
						            		            cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "nameTitle"), xs:string($nameTitle), ("unstemmed", "case-insensitive", "punctuation-insensitive", "diacritic-insensitive"), 15)            		            
						            		        )),
						            		        cts:collection-query("/bibframe/stubworks/")
						            		        ),
										 cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "uri"),$workDBURI)
									)
									
       	               			return
										   cts:search( fn:doc(), $searchcode,
				 							(cts:index-order(cts:element-reference(fn:QName("info:lc/xq-modules/lcindex", "rdftype")),("descending")))
				                  			)[1 to 2]
                  			 else ()
			
				let $found:= if (  $found and fn:string( $found[1]//@OBJID) = $workDBURI and $found[2]) then 
							$found[2]
							else if ($found[1]) then
								$found[1]
								else ()
								
	   		return ( $found,
					 if ($found) then  					 							
						(
						fn:string($found//@OBJID)
						)
						
					 else ()
					 )		
    		
		else (: didn't  even look for found match :)
			()

	
	let $found-uri := if ($matching[2] and (fn:not($matching[2] = $workDBURI) ) ) then 
						fn:replace($matching[2],"loc.natlib.works.","")
				 else ()
	return if ($found-uri) then
			(	fn:concat($BASE-URI,$found-uri) 
				,	xdmp:log(fn:concat("CORB auth/bib : adding translation link from ",$workDBURI, " to ", $found-uri ),"info")
			)
		 else ()

};
:)

declare function auth2bf:chars-001($arg as xs:string?) as xs:string* {       
   for $ch in string-to-codepoints($arg) return codepoints-to-string($ch)
};

(: this function is the same as transform, but it does not test to see if a merge has  happened
so it will overwrite and bibs need to be re-processed to merge with them.
Need to  find a way to smartly reload w/o removing the merges when the changes are not so drastic
this function used to be called by the bulk loader load_nametitles_bulk_mlcp.sh ,

but I don't think it's kept up to date (linkages!) so we should trash it. Removed from bulk 2018-11-13 ntra
DO NOT CALL 
:)
declare function auth2bf:transform-and-overwrite(
  $content as map:map,
  $context as map:map
) as map:map*
{
 let $auth2bfBase:="/prep/auths/auth2bibframe2/"
	let $the-doc := map:get($content, "value")
	let $orig-uri := map:get($content, "uri")  
	let $lccn:= fn:normalize-space(fn:tokenize($orig-uri,"/")[fn:last()])
	
	let $new-uri:=fn:concat("loc.natlib.works.",fn:replace($lccn,".xml",""))
	       (: dailies may not be nametitle or title records; also may have the 985 tag : skip them:)
	let $marcxml:=$the-doc/mets:mets/mets:dmdSec[@ID="marcxml"]/mets:mdWrap/mets:xmlData/marcxml:record
	
	let $already-in-pilot:=   
		for $tag in $marcxml/marcxml:datafield[@tag="985"]/marcxml:subfield[@code="a"]
      	return if (fn:matches(fn:string($tag) ,"BibframePilot2","i")) then
        			fn:true()
       			else 
        			()

	let $deprecated:= if (fn:substring($marcxml/marcxml:leader,6,1)="d") then
						"yes"
						else
						()
	
	(:-------------------------from ingest-voyager-bib  -------------------------:)
    	
    	let $resclean := fn:normalize-space(fn:string($marcxml/marcxml:controlfield[@tag='001']) )
    	let $dirtox := auth2bf:chars-001($resclean)
    	let $dest := "/lscoll/lcdb/works/"
        let $destination-root := $dest
        let $dir := fn:concat($destination-root, string-join($dirtox, '/'), '/')
        let $destination-uri := fn:concat($dir, $resclean, '.xml')

        let $destination-collections := ($destination-root, "/lscoll/lcdb/", "/lscoll/", "/catalog/", "/catalog/lscoll/", "/catalog/lscoll/lcdb/",
									"/resources/works/","/bibframe-process/reloads/2018-12-14/","/bibframe/hubworks/")
								(:/resources works is for suggest:)
		
		let $colls:= map:get($context,"collections")
		let $colls:=map:put($context,"collections",($colls,$destination-collections))
    (:-------------------------from ingest-voyager-bib  -------------------------:)
return
	if ($deprecated and doc-available($destination-uri)) then
		(
			xdmp:document-remove-collections($destination-uri,"/catalog/"),
			xdmp:log(fn:concat("CORB auth : auth2bibframe document deprecated : ",$resclean), "info")
		)
	else (:  if ( fn:not($already-in-pilot)) then    :)
     	if ($the-doc/mets:mets/mets:dmdSec[@ID="index"]/mets:mdWrap/mets:xmlData[//index:memberOfURI="http://id.loc.gov/authorities/names/collection_FRBRWork"  
                        or //index:memberOfURI="http://id.loc.gov/authorities/names/collection_FRBRExpression"]
                        and fn:not($already-in-pilot)) then
	(:let $marcxml:=$the-doc/mets:mets/mets:dmdSec[@ID="marcxml"]/mets:mdWrap/mets:xmlData/marcxml:record:)	
    
      	
        let $metsHdr:= <mets:metsHdr LASTMODDATE="{fn:current-dateTime()}"/>
        
        let $params:=map:map()
    	let $put:=map:put($params, "baseuri", $BASE-URI)
    	let $put:=map:put($params, "idfield", "001")
    	
        
    	let $stylesheet:=fn:concat( $auth2bfBase,"auth2bibframe2.xsl")
    	
    	let $bfwork:=           
    		try {				
    				xdmp:xslt-invoke("/prep/auths/auth2bibframe2/auth2bibframe2.xsl",document{$marcxml},$params)
    			 } 
    		catch ($e) {
    					(
						$stylesheet,
    					xdmp:log(fn:concat("CORB auth : auth2bibframe error. transform failed on",$resclean), "info")
						,xdmp:log($e, "info")
    					)				
    		}
			
    return
    	if ($bfwork/rdf:RDF) then (: ok to store :)
    		let $bfwork:= 
    						<rdf:RDF><bf:Work rdf:about="{fn:normalize-space(fn:substring-before($bfwork/rdf:RDF/bf:Work/@rdf:about,'#'))}">
							{$bfwork/rdf:RDF/bf:Work/*}
    						</bf:Work></rdf:RDF>
    			
    		let $mxe:= $the-doc/mets:mets/mets:dmdSec[@ID="mxe"]/mets:mdWrap/mets:xmlData/mxe:record
    		let $idx:= try{bibframe2index:bibframe2index($bfwork, $mxe)			}
						catch($e){xdmp:log(fn:concat("CORB auth : auth2bibframe idx failed for ",$resclean), "info")
			}
    		
    	    let $new-doc:=
            		  	  <mets:mets 
            		  		OBJID="{$new-uri}"
            	        	PROFILE			= "workRecord"
            	        	xmlns:xlink		= "http://www.w3.org/1999/xlink"  
							xmlns:idx 		= "info:lc/xq-modules/lcindex"
							xmlns:index		= "info:lc/xq-modules/lcindex"
            	        	xmlns:marcxml	= "http://www.loc.gov/MARC21/slim" 
            	        	xmlns:mets		= "http://www.loc.gov/METS/" 
	            			xmlns:mxe		= "http://www.loc.gov/mxe"
	            	        xmlns:rdf		= "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	            			xmlns:bf		= "http://id.loc.gov/ontologies/bibframe/"
	            			xmlns:bflc		= "http://id.loc.gov/ontologies/bflc/"
	            			xmlns:rdfs		= "http://www.w3.org/2000/01/rdf-schema#"
	            			xmlns:skos		= "http://www.w3.org/2004/02/skos/core#"
	            	        xmlns:madsrdf	= "http://www.loc.gov/mads/rdf/v1#"
	            	        xmlns:ri		= "http://id.loc.gov/ontologies/RecordInfo#"	        
	            			xmlns:sem		= "http://marklogic.com/semantics">
            			{$metsHdr}
            	        <mets:dmdSec ID="bibframe">
            				<mets:mdWrap MDTYPE="OTHER">
            					<mets:xmlData>{ $bfwork}</mets:xmlData>
            				</mets:mdWrap>
            			</mets:dmdSec>    
            			{$the-doc/mets:mets/mets:dmdSec[fn:not(@ID="marcxml")]}
            			<mets:dmdSec ID="ldsindex">
            				<mets:mdWrap MDTYPE="OTHER">
            					<mets:xmlData>{ $idx  }</mets:xmlData>
            				</mets:mdWrap>
            			</mets:dmdSec>
						  
            			<mets:structMap>
                            <mets:div TYPE="workRecord" DMDID="bibframe  mxe madsrdf semtriples ldsindex"/>
                        </mets:structMap> 		
            	</mets:mets>
      	
    		return
			try {
    				(
    			 		(  						
    					  map:put($content, "uri", $destination-uri   	),					
      					  map:put($content,"value", $new-doc  	), 
    					  $content,
						  $context
    					),
						
    					xdmp:log( fn:concat("CORB auth : ",$orig-uri," loaded as ", $new-uri),"info")
    				)
    			} catch($e) {
    						($e, xdmp:log( fn:concat("CORB auth : ", $orig-uri," not loaded as ", $new-uri),"info") )
    			}				
    
    			else 
    				() (: xslt failed above :)
    		
    else (: not a frbr expression/work ie name title :)
            xdmp:log( fn:concat("CORB auth : ",$orig-uri," skipped on load: Not a BFWork or has 985"),"info")
         
};

(: this is the main function for yaz, too :)

declare function auth2bf:link-and-make-mets($bfwork, $orig-uri, $new-uri,$lccn, $AUTHURI, $destination-uri, $the-doc){
				(: get link for translationOf :)
	          	(:let $title-lang:=fn:string($marcxml//marcxml:datafield[fn:starts-with(fn:string(@tag),"1")]/marcxml:subfield[@code="l"]):)
	          	let $title-lang:=fn:substring-after(fn:string($bfwork/rdf:RDF/bf:Work/bf:title[1]/bf:Title[1]/*[self::* instance of element(bflc:title00MarcKey) or self::* instance of element(bflc:title10MarcKey) or self::* instance of element(bflc:title11MarcKey) or self::* instance of element(bflc:title30MarcKey)][1]),"$l")	
	
				let $translation-link:= if ($title-lang!="") then											
											auth2bf:link2translations($bfwork/rdf:RDF/bf:Work,$lccn, $title-lang, $new-uri) 				
										else ()
 				
               let $distinct-relateds:=
    	    	 for $node-code in ("$f","$h","$k","$m","$n","$o","$p","$r","$s") 
               		let $title-str:=fn:string($bfwork/rdf:RDF/bf:Work/bf:title[1]/bf:Title[1]/*[self::* instance of element(bflc:title00MarcKey) or self::* instance of element(bflc:title10MarcKey) or self::* instance of element(bflc:title11MarcKey) or self::* instance of element(bflc:title30MarcKey)][1])
					return if (fn:contains($title-str,$node-code)) then

						   (: the text after the code:)
						   	let $node-text:=fn:substring-after($title-str,$node-code)
							let $node-text:=fn:tokenize($node-text,"\$")[1] (: drop any further subfields :)
 
		                	let $node-link:=auth2bf:link2translations($bfwork,$lccn, $node-text, $new-uri)
			            	return (auth2bf:dedup-links($bfwork/rdf:RDF/bf:Work,"bf:relatedTo", $node-link)
			                     		(:,xdmp:log(fn:concat("linking part ",$node-link),"info"):)
			             			)	                                        
					else ()
				 let $distinct-translations:=auth2bf:dedup-links($bfwork,"bf:translationOf", $translation-link)		
				
				
				(:========== adding related  4 and 5xx  copied from 7xx in bibs =========== :)
let $text-relationships:=if  ($bfwork/rdf:RDF/bf:Work/bflc:relationship/bflc:Relationship/bf:relatedTo/bf:Work 
							) then
							let $contributions:=$bfwork/rdf:RDF/bf:Work/bf:contribution[bf:Contribution/bf:agent/bf:Agent[fn:not(fn:contains(fn:string(@rdf:about),"#Agent880"))]]
							return
							<text-relations>{
							 for $w in 	$bfwork/rdf:RDF/bf:Work/bflc:relationship/bflc:Relationship/bf:relatedTo/bf:Work							 			
									
									(:$newuri=objid=workdburi from bibs:)
								let $link:= bibs2mets:link2relateds($w, "",$new-uri, $contributions) 							
							
								return  if ($link="didn't look") then  
												$w/parent::node()
										else if ($link!="") then																				
							 				<wrap>
													<name>{fn:name($w/parent::*)}</name>
													<link>{ $link}</link>
													<replace-link>{fn:string($w/@rdf:about)}</replace-link>
												</wrap>		
										else 											
											$w/parent::node()																						
						}</text-relations>				
					else ()
let $text-relation-nodes:=if ($text-relationships) then
								 for $rel in $bfwork/rdf:RDF/bf:Work/bflc:relationship/bflc:Relationship[bf:relatedTo/bf:Work][1]
									  let $about:=fn:string($rel/bf:relatedTo/bf:Work/@rdf:about)
									 return
									 for $link in  $text-relationships/wrap[fn:string(replace-link) = $about]
									 	 return <bflc:Relationship>{$rel/bflc:relation}
										 		<bf:relatedTo>
													<bf:Work rdf:about="{$link/link}">{$rel/bf:relatedTo/bf:Work/rdfs:label}</bf:Work>
												</bf:relatedTo>
											</bflc:Relationship>
								else ()
 let $related-7xxs:=if  ($bfwork/*[fn:not(self::* instance of element (bf:subject))]/bf:Work) then
						let $contributions:=$bfwork/rdf:RDF/bf:Work/bf:contribution[bf:Contribution/bf:agent/bf:Agent[fn:not(fn:contains(fn:string(@rdf:about),"#Agent880"))]]
						return
						<related-7xxs>{
						 for $w in $bfwork/rdf:RDF/bf:Work/*[fn:not(self::* instance of element (bf:subject))]/bf:Work
 									
								(:$newuri=objid=workdburi from bibs:)
							let $link:= bibs2mets:link2relateds($w, "",$new-uri, $contributions) 														

							return  if ($link="didn't look") then  
												$w/parent::node()
										else if ($link!="") then									
												 <wrap>
													<name>{fn:name($w/parent::*)}</name><link>{ $link}</link>											
												</wrap>	
										else 											
											$w/parent::node()
																						
						}</related-7xxs>				
						else ()


let $related-7xxs:=  (:nodes and links to replace the 7xxs :)
			<wrap>{				
				 for $linkset in $related-7xxs/* (:links, not nodes:)
					return												
				 		if ( $linkset[self::* instance of element(wrap)]) then
						 	auth2bf:dedup-links($bfwork,$linkset/name,$linkset/link)							 							
						else
							(:  blank nodes will be inserted as stubs  :)
							 $linkset
							
				}</wrap>	


	let $sevenxx-properties:= (fn:distinct-values(for $node in $related-7xxs/child::* return fn:name($node)),
								if ($text-relation-nodes) then "bflc:relationship" else ()
								)

(: add stubs before deleting relatedto's :)
let $relateds:= 
				if  ($related-7xxs/*/bf:Work[fn:not(fn:contains( fn:string(@rdf:about),"Work880"))	]) then							

						let $rels:=		<rdf:RDF><bf:Work>{
												for $rel in $related-7xxs/*[bf:Work[fn:not(fn:contains( fn:string(@rdf:about),"Work880"))]]
												return  $rel
	    									}</bf:Work></rdf:RDF>						
							
								return  bibs2mets:insert-work-stubs($rels,$new-uri, $AUTHURI, $AUTHURI, $destination-uri)							                            
					else  ()
 

	let $haslinks := if ( $distinct-translations or $distinct-relateds or $related-7xxs/wrap/* or $text-relation-nodes ) then
						"/bibframe/relatedTo/"
						else ()
	let $expressions := if ( $distinct-translations ) then
						("/resources/expressions/","/bibframe/translations/")
						else ()

	let $titlerelations := if (  $distinct-relateds  ) then
						"/bibframe/relationsfromtitlenode/"
						else ()

	let $had7xx := if ( $related-7xxs/wrap/*  ) then
						("/bibframe/had7xx/")
						else ()
	let $textrelations := if ( $text-relation-nodes ) then
						"/bibframe/textrelations/"
						else ()
	(: memberofuri no longer makes it into the bf databse, so post it to the collection (all are resources/works, only some are resources/expressions: :)
	
	let $nametitle-expression:=if ($the-doc/mets:mets/mets:dmdSec[@ID="index"]/mets:mdWrap/mets:xmlData//index:memberOfURI="http://id.loc.gov/authorities/names/collection_FRBRExpression") then "/resources/expressions/" else ()
	let $rel-colls:=($haslinks, $expressions,$titlerelations, $had7xx,$textrelations, $nametitle-expression)
	
	let $bfwork:= 
					<rdf:RDF>
						<bf:Work rdf:about="{fn:normalize-space(fn:substring-before($bfwork/bf:Work/@rdf:about,'#'))}">
						<rdf:type rdf:resource="http://id.loc.gov/ontologies/lclocal/Hub"/>
						{if ( $distinct-translations or $distinct-relateds or $related-7xxs or $text-relation-nodes) then
							
							(
							$bfwork/bf:Work/*[fn:not(index-of($sevenxx-properties,fn:name(.)))],
														
								(: keep relateds that are blank nodes :)							
								$distinct-translations,
								$distinct-relateds,
								$related-7xxs/*,
								(: no auth relateds are kept; all are stubs $related-7xxs/*, :)
								for $n in $text-relation-nodes return
									<bflc:relationship>{$n}</bflc:relationship>
							)
						else 
						(
							$bfwork//bf:Work/*
							)
						}

      				</bf:Work></rdf:RDF>
				
				
          		let $mxe:= $the-doc/mets:mets/mets:dmdSec[@ID="mxe"]/mets:mdWrap/mets:xmlData/mxe:record
          						
			  let $idx:= try {
				       			bibframe2index:bibframe2index($bfwork, <mxe:empty-record/> )
				   } catch($e){
				             ( 	<idx:index/>, 
							 	xdmp:log(fn:concat("CORB auths indexing error  for ", $AUTHURI), "info")
							 )
				   }
			
				let $sem:= try {
									bf4ts:bf4ts($bfwork)														
								}
          				   catch ($e) {
						   		xdmp:log(fn:concat("CORB auth : bf4ts transform failed for ",$AUTHURI), "info") 
						   }
				let $metsHdr:= <mets:metsHdr LASTMODDATE="{fn:current-dateTime()}"/>

          	    let $new-doc:=
            		  <mets:mets 
            		  		OBJID="{$new-uri}"
            	        	PROFILE			= "workRecord"
            	        	xmlns:xlink		= "http://www.w3.org/1999/xlink"  
							xmlns:idx 		= "info:lc/xq-modules/lcindex"							
							xmlns:index		= "info:lc/xq-modules/lcindex"
            	        	xmlns:marcxml	= "http://www.loc.gov/MARC21/slim" 
            	        	xmlns:mets		= "http://www.loc.gov/METS/" 
	            			xmlns:mxe		= "http://www.loc.gov/mxe"
	            	        xmlns:rdf		= "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	            			xmlns:bf		= "http://id.loc.gov/ontologies/bibframe/"
	            			xmlns:bflc		= "http://id.loc.gov/ontologies/bflc/"
	            			xmlns:rdfs		= "http://www.w3.org/2000/01/rdf-schema#"
	            			xmlns:skos		= "http://www.w3.org/2004/02/skos/core#"
	            	        xmlns:madsrdf	= "http://www.loc.gov/mads/rdf/v1#"
	            	        xmlns:ri		= "http://id.loc.gov/ontologies/RecordInfo#"	        							
	            			xmlns:sem		= "http://marklogic.com/semantics">
            			{$metsHdr}
            	        <mets:dmdSec ID="bibframe">
            				<mets:mdWrap MDTYPE="OTHER">
            					<mets:xmlData>{ $bfwork}</mets:xmlData>
            				</mets:mdWrap>
            			</mets:dmdSec>    
            			{$the-doc//mets:dmdSec[fn:not(@ID="marcxml") and fn:not(@ID="semtriples")] }
            			
						<mets:dmdSec ID="semtriples">
            				<mets:mdWrap MDTYPE="OTHER">            					
								<mets:xmlData>{if ($sem) then $sem else <sem:triples/>  }</mets:xmlData>
            				</mets:mdWrap>
            			</mets:dmdSec>    

						<mets:dmdSec ID="ldsindex">
            				<mets:mdWrap MDTYPE="OTHER">
            					<mets:xmlData>{$idx}</mets:xmlData>
            				</mets:mdWrap>
            			</mets:dmdSec>    
            			<mets:structMap>
                            <mets:div TYPE="workRecord" DMDID="bibframe  mxe madsrdf semtriples ldsindex"/>
                        </mets:structMap> 		
            	</mets:mets>
            				

    		return ($new-doc, $rel-colls)


};
(: THIS IS THE MAIN FUNCTION 
:	transform the payload mets file by extracting the marcxml, converting to bf, linking, and storing the work in a new mets. 
:)
declare function auth2bf:transform(
  $content as map:map,
  $context as map:map
) as map:map*
{
    let $auth2bfBase:="/prep/auths/auth2bibframe2/"
	let $the-doc := map:get($content, "value")
	
	let $orig-uri := map:get($content, "uri")  
	return if ($the-doc/mets:mets/mets:dmdSec[@ID="index"]/mets:mdWrap/mets:xmlData[//index:memberOfURI="http://id.loc.gov/authorities/names/collection_FRBRWork"  
                        or //index:memberOfURI="http://id.loc.gov/authorities/names/collection_FRBRExpression"]
						or $the-doc/mets:mets/mets:dmdSec[@ID="madsrdf"]/mets:mdWrap/mets:xmlData/rdf:RDF/madsrdf:Title 
						or $the-doc/mets:mets/mets:dmdSec[@ID="madsrdf"]/mets:mdWrap/mets:xmlData/rdf:RDF/madsrdf:NameTitle )
						then


	let $lccn:= fn:normalize-space(fn:tokenize($orig-uri,"/")[fn:last()])
	
	let $new-uri:=fn:concat("loc.natlib.works.",fn:replace($lccn,".xml",""))
	       (: dailies may not be nametitle or title records; also may have the 985 tag : skip them:)
	
	let $marcxml:=$the-doc/mets:mets/mets:dmdSec[@ID="marcxml"]/mets:mdWrap/mets:xmlData/marcxml:record
	
	let $already-in-pilot:=   
		for $tag in $marcxml/marcxml:datafield[@tag="985"]/marcxml:subfield[@code="a"]
      	return if (fn:matches(fn:string($tag) ,"BibframePilot2","i")) then
        			fn:true()
       			else 
        			()
	let $subjectLccn:= 
			if (				fn:starts-with($lccn,"sh") or fn:starts-with($lccn,"sj") 				) then
					"yes"
			else
					()
				
	let $deprecated:= 
			if (
				fn:substring($marcxml/marcxml:leader,6,1)="d" or 
				$the-doc/mets:mets/mets:dmdSec[@ID="index"]/mets:mdWrap/mets:xmlData/index:index/index:rdftype="DeprecatedAuthority"
			) then
					"yes"
			else
					()
				
    (:-------------------------from ingest-voyager-bib  -------------------------:)
    	let $recstatus := fn:substring($marcxml/marcxml:leader, 6, 1)
    	let $resclean := fn:normalize-space(fn:string($marcxml/marcxml:controlfield[@tag='001']) )
    	let $dirtox := auth2bf:chars-001($resclean)
    	let $dest := "/lscoll/lcdb/works/"
        let $destination-root := $dest
        let $dir := fn:concat($destination-root, string-join($dirtox, '/'), '/')
        let $destination-uri := fn:concat($dir, $resclean, '.xml')
        let $destination-collections := ($destination-root, "/lscoll/lcdb/", "/lscoll/", "/catalog/",
								 "/catalog/lscoll/", "/catalog/lscoll/lcdb/", 
								"/bibframe/nametitle-work/",
								"/resources/works/","/bibframe-process/reloads/2018-12-14/")

								(:/resources works is for suggest:)
		

    (:-------------------------from ingest-voyager-bib  -------------------------:)

		let $AUTHURI:= $resclean
		
		let $paddedID := $AUTHURI
return
	if ($deprecated and doc-available($destination-uri)) then
		(
		xdmp:document-remove-collections($destination-uri,"/catalog/"),
		xdmp:document-add-collections($destination-uri,"/deleted/"),
		xdmp:log(fn:concat("CORB auth : auth2bibframe document deprecated : ",$resclean), "info")
		)
	else if ($subjectLccn) then 
			xdmp:log(fn:concat("CORB auth : auth2bibframe document is a subject, not a name ",$resclean), "info")
	else     (: redundant for now; need to remove it:)
		if (fn:not($already-in-pilot)) then
   
   		
		(: records being updated: only if not consolidated;
   		 :  need to figure out how to update  bf w/o overwriting  merge data
	  	 :) 
   		let $doc-exists:=fn:doc-available($new-uri) 
    	return	if (($doc-exists and   fn:not(fn:doc($new-uri)//bflc:consolidates) and   fn:not(fn:doc($new-uri)//lclocal:consolidates) ) 
	      			 or fn:not($doc-exists) )  then	     	
		               
		        let $params:=map:map()
		    	let $put:=map:put($params, "baseuri", "http://id.loc.gov/resources/works/")
		    	let $put:=map:put($params, "idfield", "001")
    
		    	let $stylesheet:=fn:concat( $auth2bfBase,"auth2bibframe2.xsl")
    	
		    	let $bfwork:=           
		    		try {				
		    				xdmp:xslt-invoke("/prep/auths/auth2bibframe2/auth2bibframe2.xsl",document{$marcxml},$params)					
		    			 } 
		    		catch ($e) {
		    					(
												xdmp:log(fn:concat("CORB auth : auth2bibframe error; transform failed on ",$resclean), "info")						
		    									
								)
		    		}		
	
 
    	return
    		if ($bfwork/rdf:RDF) then (: ok to store :)
					(: the-doc is sent so it will include mets/* if loaded from id:marcxml; if loaded from bf:rdf, the-doc can be null :)
				let $new-doc:=
					 auth2bf:link-and-make-mets($bfwork, $orig-uri, $new-uri, $lccn, $AUTHURI,  $destination-uri, $the-doc) 
				let $rel-colls:=if ($new-doc[2]) then
									let $colls:=map:get($context,"collections")
									return 
										map:put($context,"collections",($colls, $new-doc[2]))							
					 			else ()
				return
						 try {
            				(
            			 		(  						
            					  map:put($content, "uri", $destination-uri   	),					
              					  map:put($content,"value", $new-doc[1]  	), 
            					  $content,
								  $context
            					),
            					xdmp:log( fn:concat("CORB auth : ",$orig-uri," loaded as this uri ", $new-uri),"info")
								
            				)
             			} catch($e) {
             						($e, 
									xdmp:log( fn:concat("CORB auth : ", $orig-uri," not loaded as ", $new-uri),"info") 
									)
             			}	
             
    			else 
    				() (: xslt failed above, $bfwork IS NOT RDF:)
    				    		
    	   else xdmp:log( fn:concat("CORB auth : ",$orig-uri," skipped on load: BFWork already there, consolidated"),"info")
    
    else 	(: not a frbr expression/work ie name title :)
            xdmp:log( fn:concat("CORB auth : ",$orig-uri," skipped on  load: Not a BFWork or has 985"),"info")

else (: not $deprecated and doc-available($destination-uri) :)
 ()
	 (:xdmp:log( fn:concat("CORB auth : ",$orig-uri," skipped on load: Not a bfWork"),"info"):)
         
         };(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)