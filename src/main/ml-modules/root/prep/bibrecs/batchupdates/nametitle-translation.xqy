xquery version "1.0-ml";
declare namespace idx="info:lc/xq-modules/lcindex";
declare namespace mets      = "http://www.loc.gov/METS/";
declare namespace xdmp      = "http://marklogic.com/xdmp";
declare namespace bf   = 'http://id.loc.gov/ontologies/bibframe/';
declare namespace   bflc            	= "http://id.loc.gov/ontologies/bflc/";
declare namespace rdf           = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace mxe	        = "http://www.loc.gov/mxe";
declare namespace html = "http://www.w3.org/1999/xhtml";
declare  namespace marcxml="http://www.loc.gov/MARC21/slim";

import module namespace 		bf4ts   			= "info:lc/xq-modules/bf4ts#"   			  at "../modules/module.BIBFRAME-4-Triplestore.xqy";
import module namespace			auth2bf = 			"http://loc.gov/ndmso/authorities-2-bibframe" at "../../auths/authorities2bf.xqy";

(:  query to add translation links to nametitles
	collection batch is "/bibframe-process/2018-06-01/"
	To use this code as  a template, 
	set the batch and the query in the uris file,
	use the same batch here,
	Modify the code in local:fix(), but keep the timestamp update.
	Decide if your fix means you have to recalculate the idx and/or the sem triples
	replace what's new
	The logging and adding to collections stays the same. If you have to run this more than once, it will exclude the stuff you've already fixed.
	


snippets:
let $marcxml:=$doc//marcxml:record

	let $new:=try {
					xdmp:node-delete($doc//bf:changeDate[fn:string(.)="0000-00-00T00:00:00"])

			 } catch ($e){
                              xdmp:log(fn:concat("CORB ", $batch, " failed for : ",$URI), "info")
                   }
	
               
                xdmp:node-replace($doc//mets:dmdSec[@ID="mxe"]/mets:mdWrap[@MDTYPE="OTHER"]/mets:xmlData/mxe:record,$new)
			xdmp:node-replace($doc//mets:dmdSec[@ID="semtriples"]//mets:xmlData/sem:triples, $new)
        	xdmp:node-replace($doc//mets:dmdSec[@ID="index"]//mets:xmlData/index:index, $work-bfindex )
		

 :)

declare variable $URI as xs:string external;

declare  function local:fix($d,$batch) {

	let $doc :=doc($d)
       
	let $time:=attribute LASTMODDATE {fn:current-dateTime()}
 	          
   	let $work:=$doc/mets:mets/mets:dmdSec[@ID="bibframe"]//rdf:RDF/bf:Work
	
	let $new-uri:=fn:string($work/@rdf:about)
	let $lccn:= fn:normalize-space(fn:tokenize($new-uri,"/")[fn:last()])
	
	let $title-lang:=fn:substring-after(fn:string($work/bf:title[1]/bf:Title[1]/*[self::* instance of element(bflc:title00MarcKey) or self::* instance of element(bflc:title10MarcKey) or self::* instance of element(bflc:title11MarcKey) or self::* instance of element(bflc:title30MarcKey)][1]),"$l")	
	let $translation-link:= if ($title-lang!="") then											
									auth2bf:link2relateds($work,$lccn, $title-lang, $new-uri) 				
								else ()
	let $distinct-translations:=auth2bf:dedup-links($work,"bf:translationOf", $translation-link)
	
	(: get link for medium like motion picture, 130$h :)
 (: 	
	let $medium:=fn:substring-after(fn:string($work/bf:title[1]/bf:Title[1]/*[self::* instance of element(bflc:title00MarcKey) or self::* instance of element(bflc:title10MarcKey) or self::* instance of element(bflc:title11MarcKey) or self::* instance of element(bflc:title30MarcKey)][1]),"$h")	
	let $medium-link:= if ($medium!="") then											
								auth2bf:link2translations($work,$lccn, $medium, $new-uri) 				
							else ()
	
	 let $distinct-mediums:=auth2bf:dedup-links($work,"bf:relatedTo", $medium-link)
	
	  let $arr:=fn:substring-after(fn:string($work/bf:title[1]/bf:Title[1]/*[self::* instance of element(bflc:title00MarcKey) or self::* instance of element(bflc:title10MarcKey) or self::* instance of element(bflc:title11MarcKey) or self::* instance of element(bflc:title30MarcKey)][1]),"$o")	
	let $arr-link:= if ($arr!="") then											
								auth2bf:link2translations($work,$lccn, $arr, $new-uri) 				
							else ()
	
	 let $distinct-arrs:=auth2bf:dedup-links($work,"bf:relatedTo", $arr-link)
 	
	let $version:=fn:substring-after(fn:string($work/bf:title[1]/bf:Title[1]/*[self::* instance of element(bflc:title00MarcKey) or self::* instance of element(bflc:title10MarcKey) or self::* instance of element(bflc:title11MarcKey) or self::* instance of element(bflc:title30MarcKey)][1]),"$s")	
	let $version-link:= if ($version!="") then											
								auth2bf:link2translations($work,$lccn, $version, $new-uri) 				
							else ()
	let $distinct-versions:=auth2bf:dedup-links($work,"bf:relatedTo", $version-link)
	let $form:=fn:substring-after(fn:string($work/bf:title[1]/bf:Title[1]/*[self::* instance of element(bflc:title00MarcKey) or self::* instance of element(bflc:title10MarcKey) or self::* instance of element(bflc:title11MarcKey) or self::* instance of element(bflc:title30MarcKey)][1]),"$k")	
	let $form-link:= if ($form!="") then											
								auth2bf:link2translations($work,$lccn, $form, $new-uri) 				
							else ()
	
	  let $distinct-forms:=auth2bf:dedup-links($work,"bf:relatedTo", $form-link)
	  
:)
	(:let $parts:=fn:tokenize(fn:string($work/bf:title[1]/bf:Title[1]/*[self::* instance of element(bflc:title00MarcKey) or self::* instance of element(bflc:title10MarcKey) or self::* instance of element(bflc:title11MarcKey) or self::* instance of element(bflc:title30MarcKey)][1]),"$p")
	let $distinct-parts:= if ($parts[2]) then (:found:)
	                         for $part at $x in $parts
	                               return if ($x > 1  ) then 	                               
	                                   let $part-link:=auth2bf:link2translations($work,$lccn, $part, $new-uri)
	                                   return (auth2bf:dedup-links($work,"bf:relatedTo", $part-link)
	                                   ,xdmp:log(fn:concat("linking part",$part-link),"info")
	                                   )
	                                   else
        	                            ()
	                    else 
	                       ():)
                   
        let $distinct-relateds:=
    	    for $node-code in ("f","$h","$k","$m","$n","$o","$p","$r","$s") 
               return 
               let $node-parts:=fn:tokenize(fn:string($work/bf:title[1]/bf:Title[1]/*[self::* instance of element(bflc:title00MarcKey) or self::* instance of element(bflc:title10MarcKey) or self::* instance of element(bflc:title11MarcKey) or self::* instance of element(bflc:title30MarcKey)][1]),"{$node-code}")
                for $node-text at $x in  $node-parts
                  return if ($x > 1  ) then 
                            let $node-link:=auth2bf:link2translations($work,$lccn, fn:string($node-text), $new-uri)
                            return (auth2bf:dedup-links($work,"bf:relatedTo", $node-link)
                                     ,xdmp:log(fn:concat("linking part",$node-link),"info")
                             )	                                 
                        else ()
	           
	                       
	(:let $part:=fn:substring-after(fn:string($work/bf:title[1]/bf:Title[1]/*[self::* instance of element(bflc:title00MarcKey) or self::* instance of element(bflc:title10MarcKey) or self::* instance of element(bflc:title11MarcKey) or self::* instance of element(bflc:title30MarcKey)][1]),"$p")	
	let $part-link:= if ($part!="") then											
								auth2bf:link2translations($work,$lccn, $part, $new-uri) 				
							else ()
	
	
	  let $distinct-parts:=auth2bf:dedup-links($work,"bf:relatedTo", $part-link)
							:)
	
	let $bfwork:= if (
						$distinct-translations or
						$distinct-relateds						
						)then
	
          						<rdf:RDF><bf:Work rdf:about="{$new-uri}">
									{ 
          								$work/*[fn:not(self::* instance of element (bf:translationOf) or self::* instance of element (bf:relatedTo) )] 
											,
										$distinct-translations,									
										$distinct-relateds									
									}
          						</bf:Work></rdf:RDF>
          
          		else ()
								
          		
return
	  if ($bfwork) then
           
			let $work-sem :=  bf4ts:bf4ts(  $bfwork  ) (: logged, null if failed:)
			let $_:=xdmp:node-replace($doc/mets:mets/mets:dmdSec[@ID="bibframe"]//rdf:RDF,$bfwork)			
			
			let $_:=xdmp:node-replace($doc//mets:metsHdr/@LASTMODDATE,$time)			
			let $_:= if ($work-sem) then xdmp:node-replace($doc/mets:mets/mets:dmdSec[@ID="semtriples"]/mets:mdWrap/mets:xmlData/sem:triples, $work-sem[1])
						else ()

			return 
				(xdmp:log(fn:concat("CORB ", $batch, " translation added to : ",$URI), "info"))
            
			else 
					xdmp:log(fn:concat("CORB ", $batch, " no translation for : ",$URI), "info")
 
 
};
(: ------------------------------------------ Main Code ------------------------------------ :)
let $batch:="/bibframe-process/2018-06-04/"

return 		try {
                        (	local:fix($URI, $batch)
							
							(: skip this for now: 
								,	xdmp:document-add-collections($URI,$batch)							
							:)
							
						)

                   } catch ($e){
						()
                   }


