xquery version "1.0-ml";

module namespace 		md 			= "http://www.marklogic.com/ps/model/m-doc";

import module namespace cfg 		= "http://www.marklogic.com/ps/config" at "../config.xqy";
import module namespace lp 			= "http://www.marklogic.com/ps/lib/l-param" at "../lib/l-param.xqy";
import module namespace utils 		= "info:lc/xq-modules/mets-utils" at "../..//xq/modules/mets-utils.xqy";
import module namespace matconf		= "info:lc/xq-modules/config/materials" at "../../xq/modules/config/materialtype.xqy";
import module namespace marcutil	= "info:lc/xq-modules/marc-utils" at "../../xq/modules/marc-utils.xqy";
import module namespace display		= "info:lc/xq-modules/display-utils" at "../../xq/modules/display-utils.xqy";
import module namespace ssk 		= "info:lc/xq-modules/search-skin" at "../../xq/modules/natlibcat-skin.xqy";
import module namespace searchts 	= "info:lc/xq-modules/searchts#" at "../../xq/modules/module.SearchTS.xqy";
import module namespace mem 		= "http://xqdev.com/in-mem-update" at "../../xq/modules/in-mem-update.xqy";

declare namespace       functx      = "http://www.functx.com";
declare namespace 		mets		= "http://www.loc.gov/METS/";
declare namespace 		mods 		= "http://www.loc.gov/mods/v3";
declare namespace 		idx			= "info:lc/xq-modules/lcindex";
declare namespace 		lcvar 		= "info:lc/xq-invoke-variable";
declare namespace 		mxe 		= "http://www.loc.gov/mxe";
declare namespace 		mat 		= "info:lc/xq-modules/config/materials";
declare namespace 		tei 		= "http://www.tei-c.org/ns/1.0";
declare namespace 		xhtml 		= "http://www.w3.org/1999/xhtml";
declare namespace 		hld 		= "http://www.indexdata.com/turbomarc";
declare namespace 		bf    		= "http://id.loc.gov/ontologies/bibframe/";
declare namespace 		bflc    	= "http://id.loc.gov/ontologies/bflc/";
declare namespace 		l 			= "local";
declare namespace 		rdf         = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace  		rdfs        = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace		sparql 		= "http://www.w3.org/2005/sparql-results#";
declare namespace 		xdmphttp      = "xdmp:http";

declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare variable $INVERSES :=
<set>
	<!--	<rel><name>relatedTo</name><inverse>relatedTo</inverse><label>Related To</label></rel>
		<rel><name>hasInstance</name><inverse>instanceOf</inverse> <label>Instance Of</label></rel>
		<rel><name>instanceOf</name><inverse>hasInstance</inverse></rel>
		<rel><name>hasExpression</name><inverse>expressionOf</inverse></rel>
		<rel><name>expressionOf</name><inverse>hasExpression</inverse></rel>
		<rel><name>hasItem</name><inverse>itemOf</inverse></rel>
		<rel><name>itemOf</name><inverse>hasItem</inverse></rel>
		<rel><name>eventContent</name><inverse>eventContentOf</inverse></rel>
		<rel><name>eventContentOf</name><inverse>eventContent</inverse></rel>
		<rel><name>hasEquivalent</name><inverse>hasEquivalent</inverse></rel>
		<rel><name>hasPart</name><inverse>partOf</inverse></rel>
		<rel><name>partOf</name><inverse>hasPart</inverse></rel>
		<rel><name>accompaniedBy</name><inverse>accompanies</inverse></rel>
		<rel><name>accompanies</name><inverse>accompaniedBy</inverse></rel>
		<rel><name>hasDerivative</name><inverse>derivativeOf</inverse></rel>
		<rel><name>derivativeOf</name><inverse>hasDerivative</inverse></rel>
		<rel><name>precededBy</name><inverse>succeededBy</inverse></rel>
		<rel><name>succeededBy</name><inverse>precededBy</inverse></rel>
		<rel><name>references</name><inverse>referencedBy</inverse></rel>
		<rel><name>referencedBy</name><inverse>references</inverse></rel>
		<rel><name>issuedWith</name><inverse>issuedWith</inverse></rel>		
		<rel><name>otherPhysicalFormat</name><inverse>otherPhysicalFormat</inverse></rel>
		<rel><name>hasReproduction</name><inverse>reproductionOf</inverse></rel>
		<rel><name>reproductionOf</name><inverse>hasReproduction</inverse></rel>
		<rel><name>hasSeries</name><inverse>seriesOf</inverse></rel>
		<rel><name>seriesOf</name><inverse>hasSeries</inverse></rel>
		<rel><name>hasSubseries</name><inverse>subseriesOf</inverse></rel>
		<rel><name>subseriesOf</name><inverse>hasSubseries</inverse></rel>
		<rel><name>supplement</name><inverse>supplementTo</inverse></rel>
		<rel><name>supplementTo</name><inverse>supplement</inverse></rel>
		
		<rel><name>translation</name><inverse>translationOf</inverse><label>Translated as</label></rel>
		<rel><name>translationOf</name><inverse>translation</inverse><label>Translation Of</label></rel>
		<rel><name>originalVersion</name><inverse>originalVersionOf</inverse></rel>
		<rel><name>originalVersionOf</name><inverse>originalVersion</inverse></rel>
		<rel><name>index</name><inverse>indexOf</inverse></rel>
		<rel><name>indexOf</name><inverse>index</inverse></rel>
		<rel><name>otherEdition</name><inverse>otherEdition</inverse></rel>
		<rel><name>findingAid</name><inverse>findingAidOf</inverse></rel>
		<rel><name>findingAidOf</name><inverse>findingAid</inverse></rel>
		<rel><name>replacementOf</name><inverse>replacedBy</inverse></rel>
		<rel><name>replacedBy</name><inverse>replacementOf</inverse></rel>
		<rel><name>mergerOf</name><inverse>mergedToForm</inverse></rel>
		<rel><name>mergedToForm</name><inverse>mergerOf</inverse></rel>
		<rel><name>continues</name><inverse>continuedBy</inverse></rel>
		<rel><name>continuedBy</name><inverse>continues</inverse></rel>
		<rel><name>continuesInPart</name><inverse>splitInto</inverse></rel>
		<rel><name>splitInto</name><inverse>continuesInPart</inverse></rel>
		<rel><name>absorbed</name><inverse>absorbedBy</inverse></rel>
		<rel><name>absorbedBy</name><inverse>absorbed</inverse></rel>
		<rel><name>separatedFrom</name><inverse>continuedInPartBy</inverse></rel>
		<rel><name>continuedInPartBy</name><inverse>separatedFrom</inverse></rel>-->
		<rel><name>relatedTo</name><inverse>relatedTo</inverse><label>Related resource</label></rel>
<rel><name>hasInstance</name><inverse>instanceOf</inverse><label>Has Instance</label></rel>
<rel><name>instanceOf</name><inverse>hasInstance</inverse><label>Instance of</label></rel>
<rel><name>hasExpression</name><inverse>expressionOf</inverse><label>Has Expression</label></rel>
<rel><name>expressionOf</name><inverse>hasExpression</inverse><label>Expression of</label></rel>
<rel><name>hasItem</name><inverse>itemOf</inverse><label>Has Item</label></rel>
<rel><name>itemOf</name><inverse>hasItem</inverse><label>Item of</label></rel>
<rel><name>eventContent</name><inverse>eventContentOf</inverse><label>Event content</label></rel>
<rel><name>eventContentOf</name><inverse>eventContent</inverse><label>Has event content</label></rel>
<rel><name>hasEquivalent</name><inverse>hasEquivalent</inverse><label>Equivalence</label></rel>
<rel><name>hasPart</name><inverse>partOf</inverse><label>Has part</label></rel>
<rel><name>partOf</name><inverse>hasPart</inverse><label>Is part of</label></rel>
<rel><name>accompaniedBy</name><inverse>accompanies</inverse><label>Accompanied by</label></rel>
<rel><name>accompanies</name><inverse>accompaniedBy</inverse><label>Accompanies</label></rel>
<rel><name>hasDerivative</name><inverse>derivativeOf</inverse><label>Has derivative</label></rel>
<rel><name>derivativeOf</name><inverse>hasDerivative</inverse><label>Is derivative of</label></rel>
<rel><name>precededBy</name><inverse>succeededBy</inverse><label>Preceded by</label></rel>
<rel><name>succeededBy</name><inverse>precededBy</inverse><label>Succeeded by</label></rel>
<rel><name>references</name><inverse>referencedBy</inverse><label>References</label></rel>
<rel><name>referencedBy</name><inverse>references</inverse><label>Referenced by</label></rel>
<rel><name>issuedWith</name><inverse>issuedWith</inverse><label>Issued with</label></rel>
<rel><name>otherPhysicalFormat</name><inverse>otherPhysicalFormat</inverse><label>Has other physical format</label></rel>
<rel><name>hasReproduction</name><inverse>reproductionOf</inverse><label>Reproduced as</label></rel>
<rel><name>reproductionOf</name><inverse>hasReproduction</inverse><label>Reproduction of</label></rel>
<rel><name>hasSeries</name><inverse>seriesOf</inverse><label>In series</label></rel>
<rel><name>seriesOf</name><inverse>hasSeries</inverse><label>Series container of</label></rel>
<rel><name>hasSubseries</name><inverse>subseriesOf</inverse><label>Subseries</label></rel>
<rel><name>subseriesOf</name><inverse>hasSubseries</inverse><label>Subseries of</label></rel>
<rel><name>supplement</name><inverse>supplementTo</inverse><label>Supplement</label></rel>
<rel><name>supplementTo</name><inverse>supplement</inverse><label>Supplement to</label></rel>

<rel><name>translation</name><inverse>translationOf</inverse><label>Translated as</label></rel>
<rel><name>translationOf</name><inverse>translation</inverse><label>Translation of</label></rel>
<rel><name>originalVersion</name><inverse>originalVersionOf</inverse><label>Original version</label></rel>
<rel><name>originalVersionOf</name><inverse>originalVersion</inverse><label>Original version of </label></rel>
<rel><name>index</name><inverse>indexOf</inverse><label>Has index </label></rel>
<rel><name>indexOf</name><inverse>index</inverse><label>Index to</label></rel>
<rel><name>otherEdition</name><inverse>otherEdition</inverse><label>Other edition</label></rel>
<rel><name>findingAid</name><inverse>findingAidOf</inverse><label>Finding aid</label></rel>
<rel><name>findingAidOf</name><inverse>findingAid</inverse><label>Finding aid for</label></rel>
<rel><name>replacementOf</name><inverse>replacedBy</inverse><label>Preceded by</label></rel>
<rel><name>replacedBy</name><inverse>replacementOf</inverse><label>Succeeded by</label></rel>
<rel><name>mergerOf</name><inverse>mergedToForm</inverse><label>Merger of</label></rel>
<rel><name>mergedToForm</name><inverse>mergerOf</inverse><label>Merged to form</label></rel>
<rel><name>continues</name><inverse>continuedBy</inverse><label>Continues</label></rel>
<rel><name>continuedBy</name><inverse>continues</inverse><label>Continued by</label></rel>
<rel><name>continuesInPart</name><inverse>splitInto</inverse><label>Continues in part</label></rel>
<rel><name>splitInto</name><inverse>continuesInPart</inverse><label>Split into</label></rel>
<rel><name>absorbed</name><inverse>absorbedBy</inverse><label>Absorption of</label></rel>
<rel><name>absorbedBy</name><inverse>absorbed</inverse><label>Absorbed by</label></rel>
<rel><name>separatedFrom</name><inverse>continuedInPartBy</inverse><label>Separated from</label></rel>
<rel><name>continuedInPartBy</name><inverse>separatedFrom</inverse><label>Continued in part by</label></rel>

</set>;

declare function md:prettify-rdf($rdf, $indent ) {
     let $c_or_p:=if (fn:substring(fn:name($rdf),1,1) eq "ABCDEFGHIJKLMNOPQRSTUVWXYZ") then
	 					"c"
						else "p"
	return 				
	    if ( fn:name($rdf) ne "" and $c_or_p="c" ) then (: node  is a class; don't indent yet :)
			let $attributes := 
                   for $a in $rdf/@*
                     return
                       if (fn:name($a) eq "rdf:about" or fn:name($a) eq "rdf:resource") then
                         <span>
                            <span style="color: #0066FF"><a href="{xs:string($a)}">{xs:string($a)}</a></span>
                         </span>
                       else if (fn:name($a) eq "rdf:datatype") then
                         <span> (datatype:{fn:substring-after($a, "#")}) </span>
                       else
                         <span>
                             <span><b>{fn:name($a)}</b></span>=<span style="color: #0066FF">"{xs:string($a)}"</span>
                         </span>
			return 
		         ( <span style="color: #1A661A">{ fn:name($rdf) }</span>	,
	                $attributes,
                    concat('<div style="margin-left: ',$indent,'px">'),
	                		for $i in $rdf/child::node()
	                   			return (  md:prettify-rdf($i, $indent + 3) ),
							
					 "</div>"
					) 
    else if ( fn:name($rdf) ne "" and xs:string($rdf) ne "" and fn:not(fn:name($rdf) eq "rdfs:label")) then (: node with text in it :)
             <div  style="margin-left: {$indent}px">
            { if (fn:not(upper-case(fn:name($rdf)) eq "RDF:RDF" or fn:name($rdf) eq "rdfs:label")) then
               <span style="color: #1A661A">{ fn:name($rdf) }</span>
             else () }
             { if ($rdf/child::node()[fn:name()="rdfs:label"]) then
               <span><b>["{ $rdf/child::node()[fn:name()="rdfs:label"]/text() }"] </b></span>
              else()
             } 
                 {
                     let $attributes := 
                         for $a in $rdf/@*
                         return
                          if (fn:name($a) eq "rdf:about" or fn:name($a) eq "rdf:resource") then
                             <span>
                                <span style="color: #0066FF"><a href="{xs:string($a)}">{xs:string($a)}</a></span>
                             </span>
                          else if (fn:name($a) eq "rdf:datatype") then
                            <span> (datatype:{fn:substring-after($a, "#")}) </span>
                          else
                             <span>
                                 <span><b>{fn:name($a)}</b></span>=<span style="color: #0066FF">"{xs:string($a)}"</span>
                             </span>
                     return (" ",$attributes)
                 } 
                 {
                     let $newindent := $indent + 3
                     for $i in $rdf/child::node()
                     return md:prettify-rdf($i, $newindent)
                     
                 }  
             </div>
                          
    else if ( fn:name($rdf) ne "" and $rdf/child::node() and fn:not(fn:name($rdf) eq "rdfs:label")) then (: node with child  in it :)
             <div style="margin-left: {$indent}px">
               <span style="color: #1A661A">{ fn:name($rdf) }</span>
                 {
                     let $attributes := 
                         for $a in $rdf/@*
                         return
                           if (fn:name($a) eq "rdf:about" or fn:name($a) eq "rdf:resource") then
                             <span>
                                <span style="color: #0066FF"><a href="{xs:string($a)}">{xs:string($a)}</a></span>
                             </span>
                           else if (fn:name($a) eq "rdf:datatype") then
                             <span> (datatype:{fn:substring-after($a, "#")}) </span>
                           else
                             <span>
                                 <span><b>{fn:name($a)}</b></span>=<span style="color: #0066FF">"{xs:string($a)}"</span>
                             </span>
                     return (" ",$attributes),
					 $rdf/text()
                 }
                     {
                     let $newindent := $indent + 3
                     for $i in $rdf/child::node()
                       return (  md:prettify-rdf($i, $newindent)                     )
                     }
             </div>
    else if ( fn:name($rdf) ne "" and xs:string($rdf) eq "" and fn:not(fn:name($rdf) eq "rdfs:label")) then (: node  with only attributes :)
             <div style="margin-left: {$indent}px">
                 <span style="color: #1A661A">{ fn:name($rdf) }</span>
                 {
                     let $attributes := 
                         for $a in $rdf/@*
                         return
                          if (fn:name($a) eq "rdf:about" or fn:name($a) eq "rdf:resource") then
                             <span>
                                <span style="color: #0066FF"><a href="{xs:string($a)}">{xs:string($a)}</a></span>
                             </span>
                          else if (fn:name($a) eq "rdf:datatype") then
                            <span> (datatype:{fn:substring-after($a, "#")}) </span>
                          else
                             <span>
                                 <span><b>{fn:name($a)}</b></span> <span style="color: #0066FF">="{xs:string($a)}"</span>
                             </span>
                     return (" ",$attributes)
                 }               <b>{fn:normalize-space(xs:string($rdf))}</b>
             </div>
    else if ( fn:not(fn:name($rdf) eq "rdfs:label") ) then
           <b>{fn:normalize-space(xs:string($rdf))}</b>
    else 
               ()
};

(:?instance instanceOf ?uri becomes "has instance " ?instance
:)
declare function md:my-children($my-uri,$node, $offset) {
	let $limit:=$cfg:SPARQL-LIMIT
	let $results:=
	           if ($node="work") then (:instance of me:)
	               searchts:return-specific-family($my-uri,"http://id.loc.gov/ontologies/bibframe/instanceOf", "/resources/instances/")
	           else (: is itemOf in bf or bflc?? :)
	               (searchts:return-specific-family($my-uri,"http://id.loc.gov/ontologies/bflc/itemOf", "/resources/items/"),
	                searchts:return-specific-family($my-uri,"http://id.loc.gov/ontologies/bibframe/itemOf", "/resources/items/")
					)	
	let  $label:= if ($node="work") then 
	                   "Has Instance(s)"
	               else "Has Items(s)"
(: this may dedup multiple titles, but is it right? :)
let $results:=<sparql:results>{
				for $r in distinct-values($results//*:uri)
					 
					let $provact:=if ($node="work") then							
							distinct-values( md:getprovactivity(fn:string($r)))
						else ()
						

					return
				
				<sparql:result>
					{for $n in $results//sparql:result[sparql:binding[@name="relateduri"]/sparql:uri=$r][1]
					
						return 
							(<sparql:binding name="relateduri">
							{$n//sparql:uri}
							</sparql:binding>,
							if ($provact) then 
									<sparql:binding name="label"><sparql:literal>{$provact}</sparql:literal></sparql:binding>
									
								else
									$n//sparql:binding[@name="label"]
							)
					}
					
				</sparql:result>

				}</sparql:results>
	
	let $sparql-nav:=md:sparql-nav($my-uri,$results,$offset, $limit)
	
 return md:linked-layout($results, $my-uri,$label, ()) 
		
};

declare function md:getprovactivity($my-uri) {
let $objid:=fn:replace($my-uri,"http://id.loc.gov","")

let $objid:=fn:replace($objid,"/",".")

let $objid:=fn:replace($objid,".resources","loc.natlib")



let $mets:=utils:mets($objid)
let $rdf:=$mets//mets:dmdSec[@ID="bibframe"]/mets:mdWrap[@MDTYPE="OTHER"]/mets:xmlData/*[1]
 let $prov:=if ($mets//idx:aLabel) then 
 				$mets//idx:aLabel
 			else
 				$rdf/*[1]/bf:provisionActivityStatement[1]
 
 
let $prov:=if ($prov)  then
 			fn:string($prov)
 		else
			fn:string-join($rdf/*[1]/bf:provisionActivity/bf:ProvisionActivity/*," ")
 
let $mat:=fn:string($mets//mets:dmdSec[@ID="index" or @ID="lds-index"]/mets:mdWrap[@MDTYPE="OTHER"]/mets:xmlData/idx:*//idx:materialGroup)
 

 return if  ($mat and $mat!="Instance") then fn:concat("(",$mat,") ",$prov) else $prov


};
(:parent is in bf, use xpath, then sparql for label
:)
declare function md:my-parent($my-uri,$node, $bf) {
	
	let $parent-uri:=
	           if ($node="instance") then 
	               fn:string($bf/bf:Instance/bf:instanceOf/@rdf:resource)
	           else if ($node="item") then 
	               fn:string($bf/bf:Item/*[fn:local-name()='itemOf']/@rdf:resource)
	               else () 
     
     let $parent-graph:=if ($node="instance")  then 
                                    "/resources/works/"  
                                else if ($node="item") then 
                                    "/resources/instances/" 
                                  else ()
     let  $label:= if ($node="instance") then 
	                   "Instance Of"
	               else "Item Of"                
	       
	       
     let $results:=searchts:return-related-title($parent-uri, $parent-graph)
  (: this may dedup multiple titles, but is it right? :)
let $results:=<sparql:results>{
				for $r in distinct-values($results/sparql:result/sparql:binding[@name="relateduri"]/sparql:uri)
					return 
						$results//sparql:result[sparql:binding[@name="relateduri"]/sparql:uri=$r][1]
				}</sparql:results>
	

	 return md:linked-layout($results, $my-uri,$label, ()) 

    (:  
	    let $parent-label:= for $node in $results/sparql:result                            
                            return $node/sparql:binding[@name="label"]/sparql:literal
        let $parent-id:=fn:tokenize($parent-uri,"/")[fn:last()]    
		let $parent-link:=fn:replace($parent-uri,"id.loc.gov",$cfg:DISPLAY-SUBDOMAIN)	 		
	
	return
			if ($parent-uri) then	
			<ul>{$label}
				 <li><a href="{fn:string($parent-link)}">{fn:string($parent-label)} ({$parent-id})</a></li>
			</ul>			
		else 
			()

		:)
};
declare function md:titleChop($title,$length) {
    
    if ( fn:string-length($title) < $length ) then 
          $title 
       else 
                  fn:concat( md:reverse-str( fn:substring-after(
                                       md:reverse-str(fn:substring($title,1,$length)
                                       )," ")
 	                      ),"...")
};

declare function md:reverse-str( $str as xs:string? )  as xs:string {
   codepoints-to-string(reverse(string-to-codepoints($str)))
 } ;
(:  this is to get the label of the entities/lationships at Id for entities/relationships (head request) or bibframe (get rdf)
:)
 declare function md:get-rel-label( $uri as xs:string )  as xs:string {

 let $uri:= if (fn:contains($uri, "entities/relationship")) then fn:concat($uri,".html") 
 			else  fn:concat($uri,".rdf") 
   let $res:=if (fn:contains($uri, "entities/relationship")) then xdmp:http-head($uri)
		   else xdmp:http-get($uri)[2]

   
return if (fn:contains($uri, "entities/relationship")) then 
				fn:string($res//xdmphttp:x-preflabel)
			else
			$res/rdf:RDF//rdfs:label[1]
 } ;
(:sparql results layout : 
:  params @results : sparql results
:  		  @my-uri is the current uri, so you don't create a link to yourself
:		  @label is the label for this query
: 		@bf is the whole doc, to mine for text relations
: many titles now possible, since not using rdfs:label
: if you want, as in my direct children, dedup before coming here
: order by?
:)
declare function md:linked-layout($results, $my-uri , $label, $bf) {
let $my-node:=fn:tokenize($my-uri,"/")[fn:last()]									
(:let $style:=if ($label="Has Instance(s)") then "background-color: #DDDDDD;"	else ()
<ul style="{$style }" >
changing the style based on depth only will work if we know the parent.
**
** if incoming is from /id.loc.gov/entities/relationships/, then  I don't know the inverse; get the label and add "of"?
**
:)
return
		if ($results/sparql:result) then		
<ul>

		<h2 class="top">{$label}</h2>
				{
				for $node in $results/sparql:result
				 		let $node-uri:=fn:string($node/sparql:binding[@name="relateduri"]/sparql:uri)
				
						let $node-id:=fn:tokenize($node-uri,"/")[fn:last()]									
					
						let $node-label:=
											md:titleChop($node/sparql:binding[@name="label"]/sparql:literal,100)
			 		
						let $node-rel:= 													
									if ($node/sparql:binding[@name="relation"]/sparql:uri) then
											fn:string($node/sparql:binding[@name="relation"]/sparql:uri)
									else if ($bf) then
											$bf/bf:Work/bflc:relationship/bflc:Relationship[fn:string(bf:relatedTo/bf:Work/@rdf:about)=$node-uri]/bflc:relation/rdfs:Resource/rdfs:label
									else fn:string($node/sparql:binding[@name="relation"]/sparql:uri)
			 		
				
						let $node-relation:=
								if (fn:contains(fn:string($node/sparql:binding[@name="relation"]/sparql:uri),"entities/relationships") ) then
										
											md:get-rel-label(fn:string($node/sparql:binding[@name="relation"]/sparql:uri))
				 						else if ($node/sparql:binding[@name="relation"]/sparql:uri) then
											md:get-rel-label(fn:string($node/sparql:binding[@name="relation"]/sparql:uri))
										 else  $node-rel
						
						(: a stub work for c006408223 is c0064082230001  :)
						(: a native instance will have the same root work for c006408223 is c0064082230001  
						 on siblings, the first 10 will be the same :)
						let $stub:=if (fn:contains($node-id,$my-node)) then "stub" else "notstub"
						let $native:=if (fn:contains(fn:substring($node-id,1,10) ,fn:substring($my-node,1,10)) )then "native" else "non"
						(:instances on work and siblings on instances show only the instance num if same root:)
						let $node-id:=if ((fn:contains($label,"Has Instance") or  fn:contains($label,"Sibling") ) and $native="native") then
										fn:concat("i",fn:substring($node-id,fn:string-length($node-id)-3))
									else if ($stub="stub" and fn:not(fn:contains($label,"Item")) and fn:not(fn:contains($node-uri,"#Work")))  then
										fn:concat("w",fn:substring($node-id,fn:string-length($node-id)-3))
									else if (fn:contains($label,"Item Of") ) then
										(:fn:concat("instance",fn:substring($node-id,fn:string-length($node-id)-5)):)
										$node-id
									else if ($stub="stub" and fn:contains($label,"Item") ) then
										fn:concat("item",fn:substring($node-id,fn:string-length($node-id)-5))
									else $node-id

					order by $stub, $node-relation,fn:replace($node-label,"^[\[\]~ @#*()}{|]+",""), $node-uri


					return <li>
							{if ( fn:contains($node-uri,"example.org")) then
									()
							 else if ( $my-uri != $node-uri ) then
										let $related-local-uri:=fn:replace($node-uri,"id.loc.gov",$cfg:DISPLAY-SUBDOMAIN) (:???:)
										(: relations onl show (ie., vary) for works, not hasinstance, hasitem:)
										let $inverse:= if (fn:contains($label, "Incoming") and fn:not(fn:contains($label,"nstance")) 
															and fn:not(fn:matches($label,"item","i")) )  then 																							
														 md:inverseRelationship($node-rel, $node-relation)											
														else
															 ()
														
															
										let $relation:= 
											if (fn:contains($label, "Incoming") and fn:not(fn:contains($label,"nstance")) and fn:not(fn:matches($label,"item","i")) )  then 																																				
															(:<span style="color:blue;">{fn:substring-before($inverse,"inverse rel not available")}</span>:)
															<span style="color:blue;">{fn:concat($inverse," : ")}</span>
													else if (fn:not(fn:contains($label,"nstance")) and fn:not(fn:matches($label,"item","i")) )  then 
														<span style="color:blue;">{fn:concat($node-relation," : ")}</span>
													else ()
									
										let $layout :=
											   if (fn:contains($inverse,"inverse rel not available")) then
																(<a href="{$related-local-uri}">{fn:string($node-label)} </a>, fn:concat("(", $node-id,")" ,fn:concat(" (", <span style="color:blue;">{$relation}</span>,")" ) ) )
												else		if ($node-label!="" and $node-relation) then 
													 	       ($relation,<a href="{$related-local-uri}">{fn:string($node-label)} </a>, <span style="color:blue;">{fn:concat(" (", $node-id,")" )}</span> )
														
															else if ($node-label!="") then
																(<a href="{$related-local-uri}">{fn:string($node-label)} </a>, fn:concat("(", $node-id,")" ) )
															else if ($node-id) then
														    	 ($relation ,	<a href="{$related-local-uri}">{fn:string($node-id)} </a>)
															else ()
									
													return $layout
										(:if (fn:contains($label, "Incoming") and $node-label!="" and $node-relation) then 
								 	       (<a href="{$related-local-uri}">{fn:string($node-label)}</a>, fn:concat(" (", $node-id,") " ) ,$relation )
										else if (fn:contains($label, "Incoming")  and $node-relation) then 
								 	       (<a href="{$related-local-uri}">{fn:string($node-id)}</a>,$relation )									
										else :)
										 
										else  (<b>{fn:string($node-label)}</b>,fn:concat("(", $node-id,")" ))
							}
							</li>
				} </ul>	
		else 
			()
};
(:?instance instanceOf ?uri becomes "has instance " ?instance
:  params @instance is this instance uri for comarison
: expressions ,or non-expressions, or all
:  		  @work-uri is the parent uri
:)
declare function md:work-siblings-old($my-uri) {
	let $expressions:=
			searchts:return-work-siblings($my-uri , "expressions")
	let $expressions:=				
		if ($expressions) then
			md:linked-layout($expressions, $my-uri, "Expressions/Translations", () )
			else ()
	let $other-works:=
			searchts:return-work-siblings($my-uri , "nonex-relateds")
	let $other-works:=				
		if ($other-works) then				
			md:linked-layout($other-works, $my-uri,"Related Work(s), including stubs", ()) 
		else ()
	
	return(	 $expressions, $other-works )
};
declare function md:inverseRelationship($relation-uri, $relation-text) {
(:for $rel in $indirect-res//sparql:result
let $relation:=fn:tokenize(fn:string($rel/sparql:binding[@name="relation"]/sparql:uri),"/")[fn:last()]
	:)
let $token:=fn:tokenize($relation-uri,"/")[fn:last()]

let $inverse:= if (fn:index-of(distinct-values($INVERSES//rel/name), $token )) then
				let $i:=	fn:string($INVERSES//rel[fn:string(name) = $token]/inverse)
					return $INVERSES//rel[fn:string(name) =$i]/label
				else if (fn:contains($relation-uri,"relationships") and fn:ends-with($relation-uri,"of")) then 
							(:fn:concat($token, "inverse rel not available"):)
							fn:substring-before($relation-text, "of")
				else if (fn:contains($relation-uri,"relationships") )  then
					fn:concat($relation-text, " of")
				else "Related resource"



return $inverse
};


declare function md:work-siblings($my-uri, $offset,$bf) {
	let $limit:=$cfg:SPARQL-LIMIT
	let $direct-res:=
			searchts:work-siblings-directional($my-uri , "Direct", $offset)
	let $direct-res:=				
		if ($direct-res) then				(: need bf for text relationships :)
				md:linked-layout($direct-res, $my-uri, "Outgoing Work Link(s)", $bf )
			else ()
					
	let $indirect-res:=
			searchts:work-siblings-directional($my-uri , "Indirect",$offset)
	
	let $indirect-res:=				
		if ($indirect-res) then						
			 		md:linked-layout($indirect-res, $my-uri,"Incoming Work Link(s)",()) 
		else ()
	let $sparql-nav:=md:sparql-nav($my-uri,$direct-res,$offset, $limit)
	return(	 $direct-res, $indirect-res , $sparql-nav)
};


(:?instance instanceOf ?uri becomes "has instance " ?instance
:  params @instance is this instance uri for comarison
: not called by works
:  		  @work-uri is the parent uri
:)
declare function md:my-siblings($my-uri, $parent-uri,$offset) {
 	let $limit:=$cfg:SPARQL-LIMIT
	let $graph:= if (fn:contains($my-uri,"instances")) then
	               "/resources/instances/"
	           else if (fn:contains($my-uri,"items")) then
	               "/resources/items/"
	           else ()
	let $results:=
			(:if (fn:contains($my-uri,"works")) then
				searchts:return-work-siblings($my-uri , "all")
				else 
			:)			
				searchts:return-my-siblings($parent-uri,$graph, $offset)

	(: this may dedup multiple titles, but is it right? :)
let $results:=<sparql:results>{
				for $r in distinct-values($results/sparql:result/sparql:binding[@name="relateduri"]/sparql:uri)
					return 
						$results//sparql:result[sparql:binding[@name="relateduri"]/sparql:uri=$r][1]
				}</sparql:results>
let $sparql-nav:=md:sparql-nav($my-uri,$results, $limit, $offset)

	return
		( 
			md:linked-layout($results, $my-uri,"Sibling(s)", ())		,
			$sparql-nav
				)
		
};
(: show more and previous links for any sparql result :)
declare function md:sparql-nav($uri,$results, $limit, $offset){
let $permalink:=fn:string-join(fn:tokenize($uri, "/")[4 to 6],"/")
let $more:=if (count($results//sparql:result) >0  and count($results//sparql:result) = $limit  ) then (: show a more link:)
				let $params:=				lp:get-params() 
				let $put:=lp:param-replace-or-insert($params, "offset", $offset + $limit)
								
				return <a href="/{$permalink}?offset={$offset+ $limit}">from {$offset + $limit} {count($results//sparql:result)} </a> 
				
				else ()
let $less:=if (count($results//sparql:result) < (  $limit ) and $offset > 0) then 
				let $params:=				lp:get-params() 
				let $put:=lp:param-replace-or-insert($params, "offset", $offset - $limit)
			
				let $prevlabel:=
						if (( $offset - $limit) = 0 ) then 
							fn:concat("First ", $limit)
						 else 
						 	fn:concat("previous ",$limit, " from :",($offset - $limit))
			
				return <a href="/{$permalink}?offset={$offset - $limit}">{$prevlabel}</a> 
			else ()
return 			<span style="margin-left:40px;">
					{$less} {
						if ($less) then  fn:concat(" | ",$offset , " to ",($offset + $limit)," | ") else ()
					}{ $more}
				</span>
};
(: use sem triples to infer relations like instances that are instance of this work
:)
declare function md:bf-sem-links($uri, $bf, $offset) {
(: parent :)
let $parent:=		
	if (fn:contains($uri,"instances")) then
				(: get instance or item parent:)
				md:my-parent($uri, "instance", $bf)			
	else if (fn:contains($uri,"items")) then
				md:my-parent($uri, "item", $bf)
    else ()    

(: siblings :)
let $siblings:=
	if (fn:matches($uri,"(instances|items)")) then
		let $parent-uri:=
				if (fn:matches($uri,"instances")) then
						fn:string($bf/bf:Instance/bf:instanceOf[1]/@rdf:resource)
					else 
						fn:string($bf/bf:Item/*[fn:local-name()='itemOf'][1]/@rdf:resource)
		
			return md:my-siblings($uri, $parent-uri, $offset)
						
	else if (fn:matches($uri,"works")) then			
			md:work-siblings($uri, $offset, $bf)			 		
	else ()			

(: children :)
let $children:=    
	if (fn:contains($uri,"works")) then
				md:my-children($uri, "work", $offset)			
	else if (fn:contains($uri,"instances")) then
				md:my-children($uri, "instance", $offset)
    else ()			

	
	return  ($parent, $siblings,$children)
	
};

declare function md:lcrender($uri as xs:string) as element(div) {
(:is this used?:)
    let $params := lp:param-string($lp:CUR-PARAMS)
    let $vars := concat("id=", $uri, ";;", "mime=text/html", ";;", "view=ajax", ";;", "params=", $params)
    let $xml :=
        try {
            xdmp:invoke("/lds/renderajax.xqy", (xs:QName("lcvar:ajaxdata"), $vars))
        } catch($e) {
            $e
        }
    return $xml
};
(:
label search at id like authorities/names/label/*
:)
declare function md:check-id-head(
	$uri2check as xs:string    
    )
{
let $x:=
    try { 
		fn:string( xdmp:http-head($uri2check)//xdmphttp:x-uri	)
	}
		
	catch ($e) {(xdmp:log($e,"info"),
		(:"error on id header lookup", but just return blank; nothing found to enhance:)
		"")
	}   
	
return if ($x!="" ) then 
			fn:replace($x,$cfg:ID-LOOKUP-CACHE-BASE, $cfg:ID-BASE)
		else ""
};
(: if source_rdf is "simple" then render the display from simple.rdf :)
declare function md:lcrenderBib($mets as node() ,$uri as xs:string, $offset, $source_rdf ) as element()? { 

(:returns xhtml div or error:error or 404 not found and () :)
     
    let $mime := "mime=text/html"
    let $hostname:=  $cfg:DISPLAY-SUBDOMAIN
    let $new-params := lp:param-remove-all($lp:CUR-PARAMS, 'browse-order')
    let $new-params := lp:param-remove-all($new-params, 'bq')
    let $new-params := lp:param-remove-all($new-params, 'browse')
	let $new-params := lp:param-remove-all($new-params, 'collection')
	let $new-params := lp:param-remove-all($new-params, 'branding')
    
    let $ajaxparams := lp:param-string($new-params)	
	(:let $offset  := lp:get-param-single($lp:CUR-PARAMS, 'offset', '0'):)
    
	let $offset:= if (fn:not($offset castable as xs:integer)) then 0
				else if (xs:integer($offset) > 200 ) then 200
				else xs:integer($offset)

    
    return 
	  if ( not(exists( $mets) ) ) then
			xdmp:set-response-code(404,"Item Not found")
	  else
		    let $stylesheetBase :="/xslt/"
		    let $displayXsl := concat( $stylesheetBase ,"displayLcdb.xsl")
    
		    let $mxe:=$mets//mxe:record
			let $idxtitle:=$mets//idx:display/idx:title/string()
        
		    let $mattype:=           
		        if (not( empty($mets//mets:dmdSec[@ID="IDX1" or @ID="index"]/mets:mdWrap[@MDTYPE="OTHER"]/mets:xmlData/idx:indexTerms//idx:typeOfMaterial))) then
		            $mets//mets:dmdSec[@ID="IDX1" or @ID="index"]/mets:mdWrap[@MDTYPE="OTHER"]/mets:xmlData/idx:indexTerms//idx:typeOfMaterial/string()      
		        else  
		            let $leader6:= $mxe/mxe:leader/mxe:leader_cp06
		            let $leader6_2:= substring($mxe/mxe:leader,7,2)
		            let $control6:=$mxe/mxe:controlfield_006/mxe:c006_cp00
		            let $control7:= $mxe/mxe:controlfield_007/mxe:c007_cp00            
		            let $materials:=matconf:materials()
		            return
		                if ($materials//mat:materialtype[@tag='000_06_2'][@code=$leader6_2]/mat:desc/text()!="" ) then
		                    $materials//mat:materialtype[@tag='000_06_2'][@code=$leader6_2]/mat:desc/string()
		                else if ($materials//mat:materialtype[@tag='007_00_1'][@code=$control7]/mat:desc/text()!="") then
		                    $materials//mat:materialtype[@tag='007_00_1'][@code=$control7]/mat:desc/string()
		                else if ($materials//mat:materialtype[@tag='006_00_1'][@code=$control6]/mat:desc/text()!="") then
		                    $materials//mat:materialtype[@tag='006_00_1'][@code=$control6]/mat:desc/string()
		                else ()  
		    let $marcxml:=marcutil:mxe2-to-marcslim($mxe)
		    let $lccn:=($mxe//mxe:d010_subfield_a)[1]
			
		    let $behavior as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'behavior', 'bfview')
			(:status is the bib circ status:)
    		let $status as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'status', 'no')
			let $branding := lp:get-param-single($lp:CUR-PARAMS, 'branding','lds')
		    let $params:=map:map()
		    let $put:=map:put($params, "hostname", $cfg:DISPLAY-SUBDOMAIN)
		    let $put:=map:put($params, "mattype",$mattype)
		    let $put:=map:put($params, "lccn",$lccn)
		    let $put:=map:put($params, "behavior",$behavior)
			let $put:=map:put($params, "idxtitle",$idxtitle)
			let $put:=map:put($params, "status",$status)
			let $put:=map:put($params, "uri",$uri)
			(:suppress holdings unless marcedit="yes" :)
			let $put:= if (matches($uri,"erms\.e") ) then 
						map:put($params, "marcedit","erms-r" )
					else  if (matches($uri,"erms") ) then					
					  map:put($params, "marcedit","erms" )
					else if (matches($uri,"works") ) then 
						map:put($params, "marcedit","works" )
					else   map:put($params, "marcedit","yes" )
			let $put:= map:put($params, "url-prefix",$cfg:MY-SITE/cfg:prefix/string() )   
		    let $put :=
		        if (string-length($ajaxparams) gt 0) then
		            map:put($params, "ajaxparams", $ajaxparams)
		        else
		            ()
     		let $put :=map:put($params, "marcedit","yes" )
            let $bf:= $mets//mets:dmdSec[@ID="bibframe"]/mets:mdWrap/mets:xmlData/rdf:RDF
			let $editor-profile:=fn:string($bf/child::*[1]/bf:adminMetadata[1]//bflc:profile[1]  )
		 (: not working: update the doc from blank node! node replace of the rdf:about does not work for permissions issues. ask clay?:)
		
		(:	let $x :=xdmp:log(fn:string($bf/bf:Work/bf:contribution[1]/*/bf:agent/bf:Agent/@rdf:about),"info")
			let $_:=if (fn:contains(fn:string($bf/bf:Work/bf:contribution[1]/*/bf:agent/bf:Agent/@rdf:about), "#Agent100")) then
						let $label:=fn:string($bf/bf:Work/bf:contribution[1]/*/bf:agent/bf:Agent/bflc:primaryContributorName00MatchKey)
						let $id-lookuplink:=fn:concat($cfg:ID-VARNISH-BASE,"/authorities/names/label/",fn:encode-for-uri($label))
						let $id-lookup:=md:check-id-head($id-lookuplink)
						let $idurl:= if ($id-lookup!="") then 
										attribute rdf:about {$id-lookup}
									else ()
						let $_  :=xdmp:log(fn:concat("BFDB name lookup ",$id-lookuplink),"info")
						
						return if ($idurl) then
								
								 try {xdmp:node-replace(
								 $mets//mets:dmdSec[@ID="bibframe"]/mets:mdWrap/mets:xmlData/rdf:RDF/bf:Work/bf:contribution[1]/*/bf:agent/bf:Agent/@rdf:about,$idurl )
								 			}catch($e){
								 				xdmp:log($e,"info")
								 	}
								else ()

					else ()
			
			:)
			let $uri:=if ($uri) then
							$uri
						 else
							fn:string($mets/mets:mets/@OBJID)
			let $loaded:=fn:substring($mets//mets:metsHdr/@LASTMODDATE,1,10)
			let $loaddate:=xs:date($loaded)

			let $loaded-display:=if (fn:starts-with($loaded,"2017")			) then <span style="color:red;">{$loaded}</span>
							else <span >{$loaded}</span>
							(: reload command for nametitles or bibs that were loaded before 8/31/18 and not merged: :)
			let $reloadable:= if (fn:contains($uri,"works") and
								 fn:not(fn:contains($uri, "works.n")) and 
								 fn:not(fn:contains($uri, "s.e")) and 
								 ( $loaddate < xs:date("2018-11-30") 
								 ) and 
								 index-of(xdmp:document-get-collections(fn:base-uri($mets)), "/bibframe/convertedBibs/" ) and 
								 fn:not(
								 	index-of(xdmp:document-get-collections(fn:base-uri($mets)), "/bibframe/consolidatedBibs/" )
								 	)
								 ) then
									
									let $token:=fn:tokenize($uri,"\.")[fn:last()]
									let $token:=substring($token, 1,10)
									let $token:=fn:replace($token,"^c0*","")
										return fn:concat("./rbi ", $token)
								else if (fn:contains($uri,"instances") and
											 ($loaddate < xs:date("2018-11-30")) and
										  	  fn:not(fn:contains($uri, "s.e"))
										) then
										let $token:=fn:replace(fn:tokenize($uri,"\.")[fn:last()],"^c0*","")
												return fn:concat("./rbi ", fn:substring($token,1,fn:string-length($token)-4))
								else if  (fn:contains($uri, "works.n") and
								 		 $loaddate < xs:date("2018-11-30") and 
										 fn:not(index-of(xdmp:document-get-collections(fn:base-uri($mets)), "/bibframe/consolidatedBibs/" ))
								 )  then
										let $token:= fn:tokenize($uri,"\.")[fn:last()]
											return fn:concat("./post-auth.sh ", $token)
								else
										()
							
			
						let $_ := if ($reloadable) 	then
						 	 (: allows log file to contain rbi  or post-auth command for auto reload: :)
							xdmp:log(fn:concat("BF Database viewed: ", $uri, ": ", $reloadable),"info")
						 else 
						 ()
			
			
			let $resourceslink:=
							if (contains($uri,"loc.natlib")) then
									concat("http://id.loc.gov/resources/",tokenize($uri,"\.")[3],"/",tokenize($uri,"\.")[4])
								else if (contains($uri,"/resources")) then
									concat("http://id.loc.gov/",$uri)									
								else $uri

	 		let $isbn:=fn:string($mets//mets:dmdSec[@ID="ldsindex" or @ID="index"]/mets:mdWrap/mets:xmlData/idx:index/idx:isbn[1])
			
			let $bfe-lookup:=
				if (fn:contains($uri,"items")) then
					let $instance-uri:=fn:string($bf//*[fn:local-name()='itemOf']/@rdf:resource)
					let $instance-titles:=searchts:return-related-title($instance-uri, "/resources/instances/")
					let $instance-title:=if ($instance-titles) then
											$instance-titles/sparql:result[1]/sparql:binding[@name='label']
										else $uri
					return
						 fn:string($instance-title)
				else
						 fn:string(
								($mets//mets:dmdSec[@ID="ldsindex" or @ID="index"]/mets:mdWrap/mets:xmlData/idx:index/idx:nameTitle,
								$mets//mets:dmdSec[@ID="ldsindex" or @ID="index"]/mets:mdWrap/mets:xmlData/idx:index/idx:display/idx:title)[1])
								
			let $bfe-lookup:=if ($bfe-lookup="[Unknown]")  then
								 fn:concat($bfe-lookup,  " ", fn:string($mets//mets:dmdSec[@ID="ldsindex" or @ID="index"]/mets:mdWrap/mets:xmlData/idx:index/idx:uri[1]))
							else
								 $bfe-lookup

			let $workid-length:=  if (fn:contains($uri,"works")) then
									fn:string-length(fn:tokenize($uri,"\.")[fn:last()])
		   						else
									1
		    let $datasource:= if ($workid-length > 12 and fn:contains($uri,"works.n")) then
		   					 		"Work stub from Authority" 
							 else if (fn:contains($uri,"works.n")) then
									 "Work from Authority" 
							 else if ($workid-length > 14 and fn:contains($uri,"works.c")) then 
							 		"Work Stub from Bib"
							  else if ($workid-length = 15 and fn:contains($uri,"works.e")) then 
							  		"Work stub from Editor"
							  else if (fn:contains($uri,"works.c")) then 
							  		"Work from Bib"							  
							   else if (fn:contains($uri,"works.e")) then 
							  		"Work from Editor"							  
							  else if (fn:contains($uri,"instances.c")) then 
							  		"Instance"	
							  else if (fn:contains($uri,"items.e")) then 
							  		fn:concat("Item from Editor")
							  else if (fn:contains($uri,"items")) then 
							  		"Item"								 
							  else if (fn:contains($uri,"instances.e")) then 
							  		"Instance from Editor"							 
							  else ""			
			let $rdftype:= if (fn:starts-with($datasource,"Work") or fn:starts-with($datasource,"Instance") ) then 
								fn:tokenize(fn:string($bf/bf:*[1]/rdf:type[1]/@rdf:resource) ,"/")[fn:last()] 
								
								else ()
			let $rdftype:= if ($rdftype) then $rdftype else "Untyped"
            let $token:=tokenize($uri,"\.")[last()]
            let $bibid:=replace($token,"^c0+","")
  			let $bibid:=replace($bibid,"^e0+","")
    		let $bibid:=if (string-length($token) > 10 ) then 
					substring($bibid, 1,string-length($bibid)-4)
				else 
					$bibid
            
            (:let $imageUri:=concat("loc.natlib.lcdb.",$bibid)			
            	let $imagePath:=concat('/media/',$imageUri,'/0001.tif/200'):)
				(:new tile server: <img src="//tile.loc.gov/image-services/iiif/service:ndmso:lcdb:0000_00:0000000027/full/full/0/default.jpg"/>:)
			let $imageLink:=if (fn:not(fn:contains($uri,"works"))) then 
										(:<img src="http://der02vlp.loc.gov{$imagePath}" alt="{$uri}"/>:)
									let $paddedid:=format-number(number($bibid), '0000000000')
									let $convgrp:=fn:concat(fn:substring($paddedid,1,4), "_",fn:substring($paddedid,5,2))
									let $tileservice:="//tile.loc.gov/image-services/iiif/service:ndmso:lcdb:"
									let $sizing:="/full/full/0/"
								 
									let $link:=fn:concat($tileservice,":",$convgrp,":",$paddedid,$sizing,"default.jpg")
									return 
										<img src="{$link}" />
								
								
							else ()
		  
	(:	  let $ajax:= 
		 		"
				$('[displayhref]').each(function() {
				    $(this).qtip({
				      content: {
				        text: function(event, api) {
				          $.ajax({
				            url: api.elements.target.attr('displayhref') // Use displayhref attribute as URL
				          })
				          .then(function(content) {
				            // Set the tooltip content upon successful retrieval
				            api.set('content.text', content);
				          }, function(xhr, status, error) {
				            // Upon failure... set the tooltip content to error
				            api.set('content.text', status + ': ' + error);
				          });
				          return 'Loading...'; // Set some initial text
				        }
				      },
				      position: {
				        viewport: $(window)
				      },
				      style: 'qtip-wiki'
				    });
				  });
				"
				 //$(this).load(url);
				 //$(this).prev(['#resolver']).load(url);
				 :)
let $ajax:=			

			 "
			$('[displayhref]').each( function() {     
			  var url = $(this).attr('displayhref')  ;
			//$('#resolver').load(url);			 
			$(this).prev(['#resolver']).load(url);
			 
			});

			 "
			let $lcdbDisplay:=
				if ($behavior="bfview" 
					or fn:matches($uri, "(instances|items)" )					
					or not($mxe)
					) then											
					   <div id="ajaxview">
					   	<div id="dsresults">
					   		<div id="ds-bibrecord">					  
					   	 		 <h1 id="title-top">{$bfe-lookup} </h1>
								 <span class="format">{$datasource}</span>		( <span style="color:red;" class="format">{$rdftype}</span> )
					   			<div style="align:right;">{$imageLink}</div>														

		
								<!-- <div style="align:right;">{<img src="http://covers.librarything.com/devkey/2ed454fd22af5dceef59b6069ed7c020/large/isbn/{$isbn}" alt="Book cover image"/>}</div> -->
					                         
					   			{display:display-rdf($bf,0)}
								<script>{$ajax}</script>		
					   		</div>					      
					       
					      </div>
					   </div> 
				
				else 
			        try {
			            xdmp:xslt-invoke($displayXsl,document{$marcxml},$params)
			        } catch ($exception) {
			            ($exception, xdmp:log(fn:string($exception),"info"))
						
			        }  			
			let $bflinks:= for $l in $bf
								return 									
									$l/child::*[1]/*[fn:local-name()= "itemOf" or fn:local-name()= "instanceOf" or fn:local-name()="hasInstance" or fn:local-name()="hasItem" or fn:local-name()="consolidates"]
		    	
			
			let $bookmarklink:= if (contains($uri,"loc.natlib")) then
									$uri
								else if (contains($uri,"/resources")) then
									concat("http://id.loc.gov/",$uri)									
								else $uri

			let $formats-base:=replace($resourceslink, "id.loc.gov",$cfg:DISPLAY-SUBDOMAIN)

			let $biblink:=
			 	if ( contains($hostname,"mlvlp04")  and contains($uri, ".c") ) then
					(: already known
					let $bibid:=fn:tokenize($uri,"\.")[fn:last()]				
					let $bibid:=fn:substring($bibid, 1,10)
					let $bibid:=fn:replace($bibid,"^c0+","") return
					:)
			        <a href="{concat("http://",$hostname,"/resources/bibs/",$bibid,".xml")}"> MARC source </a>
				else if ( contains($uri, "works.n") ) then
				(:let $node:=fn:tokenize($uri,"\.")[fn:last()] return:)
				 	 <a href="{concat('https://id.loc.gov/authorities/names/',$token,'.marcxml.xml')}">MARC authority source (at ID) </a>
				else ()
			let $sem-links:= md:bf-sem-links($resourceslink, $bf, $offset)
            
			return
				if ($lcdbDisplay instance of element(error:error)) then
				  $lcdbDisplay		           
		        else
		            <div id="ajaxview">
		           	  {$lcdbDisplay//descendant-or-self::div[@id="ds-bibviews" or @id="ds-bibrecord" or @id="tab1"][1]} 
					 	<div id="ds-bibviews"><!--<h2 class="top">BIBFRAME links</h2>-->
					 	 { $sem-links }						
						   
						 {if (fn:not($sem-links//li ) ) then
						         <ul>
					 			   { 
								   	for $link in $bflinks
					 			   		let $rewrite-link:= 
													if (contains($link/@rdf:resource,"/resources/bibs")) then
														let $id:=tokenize(string($link/@rdf:resource),"/")[last()]
														let $id:=replace($id,"^0+","")
															return concat("/resources/bibs/", $id)
													else if ($link/@rdf:resource) then
														fn:replace($link/@rdf:resource, "id.loc.gov",$cfg:DISPLAY-SUBDOMAIN)
					 			                     else if ($link/@rdf:about) then
													   		fn:replace($link/@rdf:about, "id.loc.gov",$cfg:DISPLAY-SUBDOMAIN)
					 			                    else ""
										let $subnode:= if (contains($rewrite-link, "loc.natlib")) then
										   					tokenize($rewrite-link,"\.")[last()]
														else
															tokenize( $rewrite-link,"/")[last()]
										let $hasInstance:=if  (contains($link/@rdf:resource,"/resources/bibs")) then
															let $id:=tokenize(string($link/@rdf:resource),"/")[last()]
															return  ( concat("/resources/instances/c",$id,"0001"), concat("c",$id,"0001"))
														  else 	 ()
					 				return				
					 					<li >
											<span class="white-space">{fn:local-name($link)} :<a href="{ $rewrite-link}">{$subnode}</a></span>
											{if ($hasInstance) then 
													<span class="white-space"> (hasInstance :
															<a href="{$hasInstance[1]}">{$hasInstance[2]}</a>
															)
													 </span>
													  else ()
													  }

										</li>
										}
								 </ul>
								 else () (: sem links available, suppress manual creations:)
								 }
								 

                  					{ 	if ($lcdbDisplay//h2[starts-with(., "Other Views for This Description" )]) then
                                            ()
                  						else                                                          						                    						     
                  						    (<h2>Other Views for This Description</h2>,
                            			          <ul>		 		
                                       				
													<li><a href="{$formats-base}.rdf">BIBFRAME RDF</a>
                                       				
                                       				</li>
													<li>
                                       					<a href="{$formats-base}.ttl">BIBFRAME Turtle</a>
                                       				</li>
                                       				<li>
                                       					<a href="{$formats-base}.json">BIBFRAME JSON</a>
                                       				</li>
                                       				<li>
                                       					<a href="{$formats-base}.jsonld">BIBFRAME JSON-LD</a>
                                       				</li>
                                       				<li>
                                       					<a href="{$formats-base}.simple.rdf">New sem</a>														
                                       				</li> 
													<li>
                                       					<a href="{$formats-base}.doc.xml">Whole Document</a>														
                                       				</li>                                       				
													<li>
                                       					<a href="{$formats-base}.index.xml">Fast Indexes</a>														
                                       				</li>   													
													<li>
                                       					{$biblink}
                                       				</li>                                       				
													{if (fn:contains($uri,"instances")) then
														<li>
                                       						<a href="{$formats-base}.marc-pkg.xml">MARC Conversion pkg</a>														
                                       					</li>
													else 
														()
													}
                                       			</ul>,
                                       			
                                       			<h2>Bookmark This Description</h2>,
                                       			<ul>
                                       				<li>
                                       					<span id="print-permalink" class="white-space">														
														<a href="{replace($resourceslink, 'id.loc.gov',$cfg:DISPLAY-SUBDOMAIN)}">{$resourceslink}</a>
                                       					</span>
                                       				</li>
                                       			</ul>	,
												if (fn:not(fn:contains($uri,"items"))) then
													let $load-action:= if (fn:contains($uri,"works")) then
																			"loadwork"
																		else
																				"loadibc"
													return
													(<h2>Editor Link</h2>,
                                       				<ul>
                                       					<li>
                                       					<span class="white-space" style="color:#36c;">														
														<!--{$formats-base}.jsonld-->
														<!--<form action="http://mlvlp04.loc.gov:3000/bfe/index.html">
															<input type="hidden" name="action" value="loadibc"/>
															<input   type="hidden" name="url" value="{$formats-base}.jsonld"/>
															<button value="submit for edit">Submit to Editor</button>
														</form>-->
														<p>{$formats-base}.jsonld</p>
                                       					 <a href="http://mlvlp04.loc.gov:3000/bfe/index.html?action={$load-action}&amp;url={$formats-base}.jsonld&amp;profile={$editor-profile}">Load to Editor</a>
														</span>														
	                                       				</li>
	                                       			</ul>)
													else ()
                                      		)}
                           <br/><br/>Last loaded: {$loaded-display} 		                                       			
						          </div>
								  
									
		            </div> 			    
				
};

declare function md:lcrenderMods($mets as node() )  { (:as element()?:)
(:returns xhtml div or error:error or 404 not found and () 
developed with lcwa content
record profile is probably modsBibRecord, and source is originally mods, not mxe or marcxml
:)
     
if ( not(exists( $mets) ) ) then
			xdmp:set-response-code(404,"Item Not found")
	  else 
	    let $mime := "mime=text/html"
    	let $ip as xs:string? := xdmp:get-request-header("X-Forwarded-For")
    	let $branding:=$cfg:MY-SITE/cfg:branding/string()
		let $url-prefix:=$cfg:MY-SITE/cfg:prefix/string()

		(:let $branding as xs:string := lp:get-param-single($lp:CUR-PARAMS, 'branding', $cfg:DEFAULT-BRANDING)
        let $url-prefix:=concat("/",$branding,"/"):)
	    let $new-params := lp:param-remove-all($lp:CUR-PARAMS, 'browse-order')
	    let $new-params := lp:param-remove-all($new-params, 'bq')
	    let $new-params := lp:param-remove-all($new-params, 'browse')
	    let $new-params := lp:param-remove-all($new-params, 'collection')
	    let $new-params := lp:param-remove-all($new-params, 'branding')
	    let $ajaxparams := lp:param-string($new-params)
		let $objectType := substring-after($mets//@PROFILE,'lc:')
		let $uri := $mets//@OBJID/string()
		let $behavior as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'behavior', 'default')
        
    
 		(:*********************  Description *********************  :)

		    
		    let $labelsParams := map:map()
			let $put := map:put($labelsParams, "uri", $uri)    
		    let $put := map:put($labelsParams, "profile", $objectType)    
		    let $put := map:put($labelsParams, "ip", $ip) 
		    let $put := map:put($labelsParams, "behavior", $behavior)			
		    let $put := map:put($labelsParams, "branding", $branding)
			let $put := map:put($labelsParams, "ajaxparams", $ajaxparams)  

		    let $labels :=
		        try {
		            xdmp:xslt-invoke("/xslt/mods/labels.xsl", $mets, $labelsParams)
		        } catch ($exception) {
		            $exception 
		        }      
		    (: ------- group same labels together --------- :)		    
		    let $groupings :=
		        try {
		            xdmp:xslt-invoke("/xslt/mods/groupings.xsl", document{$labels})                  
		        } catch ($exception) {
		            $exception
		        }  
		  let $illustrative:=utils:illustrative($mets/node() ,$uri)
		  let $bibid:=  fn:replace(fn:tokenize($uri,"\.")[last()],"^c0+","")
		  let $bibid:=  fn:replace($bibid,"^e0+","")
		  let $imgid:=if (string-length($bibid) > 10 ) then 
								substring($bibid, 1,string-length($bibid)-4)
							else 
								$bibid
            
		  let $imagepath := 
				if ( matches($uri,"lcwa") and exists($illustrative) ) then
					<img src="{replace($illustrative,'lcwa','mrva')}/200" alt="thumbnail" />			
			    else if (fn:not(fn:contains($uri,"/works/")) and 
						matches($objectType,"(bibRecord|modsBibRecord|metadataRecord)") and
						exists($illustrative)) then
			        (:<img src="{$illustrative}/200" alt="thumbnail" />:)
			        <img src="loc.natlib.lcdb.{$imgid}/200" alt="thumbnail" />
					else 					
						()

			  			
		   let $modsDisplay:=   
		        try {
		            xdmp:xslt-invoke("/xslt/mods/mods-metadata.xsl", document{$groupings})                  
		        } catch ($exception) {
		            $exception
		        }   
	let $modsDisplay:=
		if (not(empty($imagepath))) then 
			mem:node-insert-before($modsDisplay//h1[@id="title-top"],$imagepath)
		else $modsDisplay
							
				(:*********************  Menu *********************  :)      
    let $itemID as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'itemID', '')
    let $menuParams := map:map()
    let $put := map:put($menuParams, "url", xdmp:get-request-url()  ) 
    let $put := map:put($menuParams, "behavior", $behavior)
    let $put := map:put($menuParams, "itemID", $itemID)
    let $put := map:put($menuParams, "id", $uri)
    let $put := map:put($menuParams, "hostname", $cfg:DISPLAY-SUBDOMAIN)
    let $menu :=
        try {                     
            xdmp:xslt-invoke("/xslt/pageturner/navigation.xsl",$mets, $menuParams)
        } catch ($exception) {
            $exception
        } 		 	
	let $restricted:=
		if (matches($mets//mods:accessCondition[@type="restrictionOnAccess"],'^Access restricted') ) then
			 true()
		 else  false()
	let $contents :=
	       <ul class="std">{ 
			   	for $item at $count in $menu//l:items/l:item[@fileid]
					return <li id="{$item/@fileID}">
				         <code id="{$item/@fileID}" style="display:none">{$count}</code>
						<a id="{$item/@fileID}" class="player_trigger" href="">{$item//l:title/string()}</a>								
						<p class="abstract">{$item//l:comment/string()}</p></li>
				}
				(: web crawl parts or other links out to known urls :)
				{ 
			   	for $item at $count in $menu//l:item[@id and not(@fileid)]
					return <li id="{$item/@id}">					
								{if (not($restricted) or  matches($ip,"^140.147\.")) then
  								 if (matches($branding,'(lcwa|lcwa[0-9]+)' ) or matches($uri,'lcwa') ) then
									<a id="{$item/@id}"  target="_blank" rel="nofollow" href="{$item//l:href/l:url}">{$item//l:title/string()}</a>
									else
										<a id="{$item/@id}"  href="{$item//l:href/l:url}">{$item//l:title/string()}</a>
								else
									<span>{$item//l:title/string()}</span>
								}
								<p class="abstract">{$item//l:comment/string()}</p>
							</li>
				}
				</ul>
	
		    return  	
			if ($behavior="grp") then
			  	 $groupings		
			   else
			   (:???? could this be dt:transform($groupings/?? instead of modsdisplay??? :)
			   if ($labels instance of element(error:error)) then
				  $labels
				else if ($groupings instance of element(error:error)) then
				  $groupings
			    else if ($modsDisplay instance of element(error:error)) then
				  $modsDisplay           
		        else
		            <div id="ajaxview">
						{$modsDisplay} {md:sidebar($groupings, $contents, $branding, $uri)}
		            </div> 							  
};

declare function md:renderDigital($result as node()) as element(div)* {
    
	let $mets := if ($result/mets:mets) then $result/mets:mets else $result
	
    let $uri := $mets/@OBJID/string()    
    let $stylesheetBase := "/xslt/"
    (:let $objectType := substring-after($mets/@PROFILE,'lc:'):)
	let $objectType := fn:string($mets/@PROFILE)
    let $ip as xs:string? := xdmp:get-request-header("X-Forwarded-For")
    let $behavior as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'behavior', 'default')
    let $hostname :=  $cfg:DISPLAY-SUBDOMAIN
    let $branding:=$cfg:MY-SITE/cfg:branding/string()
	let $site-title:=$cfg:MY-SITE/cfg:label/string()
	let $section as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'section')
 (:   let $page as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'page')
    let $size as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'size'):)
    let $itemID as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'itemID')
	  	
    (:*********************  Menu *********************  :)      
    let $menuXsl := concat($stylesheetBase, "pageturner/navigation.xsl")
    let $menuParams := map:map()
    let $put := map:put($menuParams, "url", xdmp:get-request-url()  ) 
    let $put := map:put($menuParams, "behavior", $behavior)
    let $put := map:put($menuParams, "itemID", $itemID)
    let $put := map:put($menuParams, "id", $uri)
    let $put := map:put($menuParams, "hostname", $cfg:DISPLAY-SUBDOMAIN)
    let $menu :=
        try {                     
            xdmp:xslt-invoke($menuXsl,$mets, $menuParams)
        } catch ($exception) {
            $exception
        }
     
    (:*********************  all full texts (currently just tohap, NOT IA) *********************  :)
	(: won't be necessary to do this when we integrate the JS on tab4 (and snippets??) :)
  let $tei := 
  	if ($mets//tei:TEI) then
  		utils:tei-files($mets)
	else
		()

  let $full-text :=	   
  	if (exists($tei)) then
        try {
            xdmp:xslt-invoke("/xslt/pageturner/tei2HTML.xsl", $tei)
        } catch ($exception) {
            $exception
        }     
		else 
		 ()
		 	
    (:*********************  Description *********************  :)
     
    let $labelsParams := map:map()
	let $put := map:put($labelsParams, "uri", $uri)    
    let $put := map:put($labelsParams, "profile", $objectType)    
    let $put := map:put($labelsParams, "ip", $ip) 
    let $put := map:put($labelsParams, "behavior", $behavior)  
	let $put := map:put($labelsParams, "branding", $branding)  
    let $labels :=
        try {
            xdmp:xslt-invoke("/xslt/mods/labels.xsl", $mets, $labelsParams)
        } catch ($exception) {
            $exception
        }      
	
    (: ------- group same labels together --------- :)
    
    let $groupings :=
        try {
            xdmp:xslt-invoke("/xslt/mods/groupings.xsl", document{$labels})                  
        } catch ($exception) {
            $exception
        }        
	
	(:*********************  related item children contents and snippets if found *********************  :)        
    
    let $contents := 
       <ul class="std">{ 
	   	for $item at $count in $menu//l:items/l:item
			return <li id="{$item/@fileID}"><!--<h1>{$item//l:href/l:sectionTitle/string()}</h1>-->
			         <code id="{$item/@fileID}" style="display:none">{$count}</code>
					<a id="{$item/@fileID}" class="player_trigger" href="">{$item//l:title/string()}</a>
					
					<p class="abstract">{$item//l:comment/string()}</p></li>
			}</ul>

	(:*********************  Right Nav bar (available behaviors, related items ) *********************  :)    
    (: not used anymore - rsin
    let $illustrative:=utils:illustrative($mets,$uri):)
    let $main :=      
	  
       	if ($behavior eq "default") then			      	
		  md:maincontent($groupings, $behavior, $uri, $objectType)
       
		else if ($behavior="menu") then
 				$menu		
		else if ($behavior="tei") then
				$tei
		else if ($behavior="full") then
				$full-text		
		else if ($behavior="contents") then
 				($contents)	
		else if ($behavior eq "labels") then
            	$labels
	    else if ($behavior="bfview") then
 				($groupings)
        else if ($behavior="grp") then
 				($groupings)
        else (: this is not being used , but could access contactsheet and other xsl's :)
                       
            ()
    return 
        <div id="ajaxview">    
			<div id="container"> 						
				<h1 id="title-top" style="width:80%" >{$site-title}<br /><span>{$groupings/l:descriptive/l:pagetitle/text() }</span></h1>
				<abbr title="{normalize-space($uri)}" class="unapi-id"></abbr>
				
				 {md:sidebar($groupings, $contents,$branding,$uri)}
				 {$main}
				 {$groupings//*:metatags}<!-- for seo, removed before display -->
			</div>
			{if ($behavior="debug") then <div class="debug" style="visibility: hidden;">{$groupings}</div>        else ()}
        </div>
};
declare private function md:dt-transform($nodes as node()*) as item()* {
    for $node in $nodes
    return 
        typeswitch($node)
            case text() return $node            
			case element(l:element) return 
										element dt {attribute class {"label"},
					  								md:dt-transform($node/node())
										 		} 	
			
			case element(l:label) return md:dt-transform($node/node())										 			
            case element(l:value) return element dd {attribute class {"bibdata"},
													md:dt-transform($node/node())
											}
			case element(l:href) return  if ($node//l:browseurl and not($node//l:url)) then 
											md:dt-transform($node/node())										
										 else 
										 	element a {md:dt-transform($node/node())}
														
            case element(l:url) return attribute href {md:dt-transform($node/node())}           
			case element(l:browseurl) return ()	
            default return md:dt-transform($node/node())
};
(:declare function md:li-singletransform($nodes as node()* ) as item()* {
(: each element/value is an li ... not used

:)
    for $node in $nodes
    return 
        typeswitch($node)
            case text() return $node            
			case element(l:element) return md:li-singletransform($node/node())
			case element(l:label) return 	()
            case element(l:value) return element li {md:li-singletransform($node/node())}
			case element(l:href) return element a {md:li-singletransform($node/node())}
            case element(l:url) return	attribute href {md:li-singletransform($node/node())}           									
			case element(l:browseurl) return ()																				
         default return md:li-singletransform($node/node())
};:)

declare private function md:li-browsetransform($nodes as node()* ) as item()* {
(: each element/value is an li , for right nav bar... uses browse url, not search url
not all values have browseurl (only if lcsh, auth, etc) 

:)
    for $node in $nodes
    return 
        typeswitch($node)
            case text()				return $node            
			case element(l:element) return md:li-browsetransform($node/node())
			case element(l:label) 	return ()
            case element(l:value) 	return if ($node//l:browseurl) then 
												element li {md:li-browsetransform($node/node())}
											else () 
			case element(l:href) 		return element a {md:li-browsetransform($node/node())}            						
			case element(l:browseurl) 	return  attribute href {md:li-browsetransform($node/node())}           																				
            case element(l:url) 		return	()	

		default 					return md:li-browsetransform($node/node())
};
declare private function md:li-alltransform($nodes as node()*) as item()* {
(:

<li>Links: <a href="href/url">href text </a>| <a href="#">Publishers Desciption</a> | <a href="#">Abstract/Review</a></li>


<value>
		<href>
			<url>http://hdl.loc.gov/loc.music/copland.writ0025</url>
			http://hdl.loc.gov/loc.music/copland.writ0025
			</href>
	</value>
:)
    for $node in $nodes
    return 
        typeswitch($node)
            case text() 				return $node            
			case element(l:element) 	return md:li-alltransform($node/node())
			case element(l:label) 		return ()
            case element(l:value) 		return md:li-alltransform($node/node())
			case element(l:href) 		return element a {md:li-alltransform($node/node())}
            case element(l:url) 		return attribute href {md:li-alltransform($node/node())}           
			case element(l:browseurl) 	return ()

         default 						return ()
};
declare function md:locations($groupings, $uri, $objectType) {

let $links:= if (matches($objectType,"(modsBibRecord | bibRecord)")) then
			   	 <li>Links: 
			        {for $link at $x in $groupings//l:element[lower-case(l:label)="url" or l:label="Electronic resource"][//l:href]/l:value   
			    		return ( 
			    			md:li-alltransform($link),  
			    				if ($x != count($groupings//l:element[@field="url" or l:label="Electronic resource"][//l:href]/l:value ) ) then " | "  else () 
			    			),
			    			for $link at $x in $groupings//l:element[@field="identifier"][lower-case(l:label)="url"]/l:value
			    				return (md:li-alltransform($link), if ($x != count($groupings//l:element[@field="identifier"][lower-case(@label)="url"]/l:value)) then " | " else () 
			    			)
					}
		  	 	 </li>
			else () 
let $locations:= if ($groupings//l:element[@field="location" or l:label="Repository"]/l:value) then
					<li>Library Location: 
						{for $loc at $x in $groupings//l:element[@field="location" or l:label="Repository"]/l:value
				    		return
				        		(md:li-alltransform($loc), if ($x != count($groupings//l:element[@field="location" or l:label="Repository"]/l:value) ) then " | " else ())
						}
					</li> 
		else ()
return
    ($links,$locations)
};

declare private function md:sidebar($groupings as node(), $contents as element(), $branding as xs:string , $uri as xs:string) {
 (:let $browse:= $groupings//*[(matches(lower-case(l:label/string()),"(subject|name|call no)")) or matches(@field,"name")] :)
let $ip as xs:string? := xdmp:get-request-header("X-Forwarded-For")


let $browse:= $groupings//*[matches(lower-case(l:label),"(subject|name|classification)")][//l:browseurl]
	(:id="sidebar":)
let $url-prefix:=if (xdmp:get-request-header('X-LOC-Environment')='Staging') then "/tohap/" else ()

return
	<div  id="sidebar">
			<!-- use this to link to the collection/collections for the digital item -->
			{ (: Don't display div at all if there are no relatedItem nodes :)
                if ($groupings//l:relatedItem[@type="host"]) then
        			<div id="collection">
        				<h3>Collection</h3>
        				
        					<ul class="std">
        						{for $item at $x in md:li-alltransform($groupings//l:relatedItem[@type="host"]/l:element)
        						  return <li>
        								  {if ($branding="tohap" and $x=1)then
        								  	<a href="/tohap/">Tibetan Oral History and Archive Project (TOHAP)</a>
        								  	else $item
        								  }</li>
        						 }						
        					</ul>
        			</div>
    			else ()
                    }
			<!-- end id:#sidebar #collection -->
			{if (exists($contents//li) ) then
				<div id="related">					
					<h3>{if (matches($branding,'(lcwa|lcwa[0-9]+)' ) or matches($uri,'lcwa') ) then "Access the Archive" else "Interview Parts"}</h3> 
					<ul class="std">
						{for $item in $contents//li return 									
						 <li>					
							{$item/*[@class!='abstract' or not(@class)]}
						</li>
						}
						</ul>
				</div>
				else ()
			}
			<!-- use this to link to browses for related subjects, names and LC classes -->
			{if (exists($browse)) then
				<div id="xml"><h3>Browse More Like This</h3>
					{
						(  		(:at least one lcsh: :)
							if ($browse[matches(lower-case(l:label),"subject" )]//l:browseurl ) then																														
								<div id="browse-subjects">
									<h4>Subjects</h4>
										<ul class="std">
											{md:li-browsetransform($browse[matches(lower-case(l:label/string()),"subject")][//l:browseurl])}											
										</ul>
								 <!--end browse-subjects --></div>
							 else (),
							 if ($browse[matches(lower-case(l:label),"name" )]//l:browseurl ) then																							
								<div id="browse-names">
									<h4>Names</h4>
										<ul class="std">
											{md:li-browsetransform($browse[matches(lower-case(l:label/string()),"name" )][//l:browseurl])}			
										</ul>
								 <!-- end browse-names --></div>
							 else (),
							  if ($browse[matches(lower-case(l:label),"classification" )]//l:browseurl ) then
								<div id="browse-class">
 									<h4>LC Class</h4>
										<ul class="std">										
											{md:li-browsetransform($browse[matches(lower-case(l:label),"classification" )][//l:browseurl])}
										</ul>
								 <!-- end browse-class --></div>
							 else ()
						 )
					 }
					<!-- end id: related -->
					</div>
									
				else () }			
				
				{if ($groupings//l:element[@field="identifier"][starts-with(l:label,'Reproduction Number')]) then
				<div id="duplication">
					<h3>Obtain Copies</h3>					
					<ul class="std">					
					  <li><a href="http://www.loc.gov/duplicationservices/order.html">Duplication Services -- stock number: 
					 { for $item in $groupings//l:element[@field="identifier"][starts-with(l:label,'Reproduction Number')]
					 	 return ($item/l:value/string()," ") }</a></li>
					</ul>									
				<!-- end duplication --></div>
				else ()
					}
			<div id="xml">
			<h3>Other Views for This Description</h3>
			<ul class="std">	
				<li>
					<a href="{concat($url-prefix,$uri)}.rdf">BIBFRAME RDF</a>
				</li>
				<li>
						<a href="{concat($url-prefix,$uri)}.dc.xml">Dublin Core (SRU)</a>
				</li>
				<li>
					<a href="{concat($url-prefix,$uri)}.mets.xml">METS</a>
				</li>
			</ul>
			</div><!-- end xml -->
			<div id="permalink">
			<h3>Bookmark This Description</h3>
			<ul class="std">	
				<li>
					<span id="print-permalink" class="white-space">
						<a href="{concat($url-prefix,$uri)}">{$uri}</a>
					</span>
				</li>
			</ul>
			</div> <!--end permalink -->
				{ if (matches($branding,'(lcwa|lcwa[0-9]+)' ) or matches($uri,'lcwa') ) then 	
						()
				else
					ssk:feedback-link(true())
				}
			
		</div>
		};

declare function md:maincontent($groupings as node()?, $behavior as xs:string?, $uri as xs:string, $objectType as xs:string?) as element(div) {

	let $url-prefix:=$cfg:MY-SITE/cfg:prefix/string()
	let $imguri:=replace($uri,'c0[0-3]','')
	let $imagepath := 		
		if (matches($objectType,"(bibRecord|modsBibRecord)") ) then
			<!--<img src="http://loccatalog.loc.gov/media/{$imguri}/0001.tif/200" alt="thumbnail" />			-->
			else 
				()

	(: holdings-- not done: only if we use tabbed view for lcdb records: :)
	let $hold := 
	   if (contains($uri, "lcdb") and not(matches($uri, "(works|instances|items)")) ) then
	       utils:hold-bib(xs:integer(tokenize($uri, "\.")[last()]),"lcdb")
	   else ()    


	(: the ds-viewport class is a container for the viewport or other digital object player; if id=viewport-off, then it will disappear :)	
	let $window:=	
		if (matches($objectType,"(recordedEvent|simpleAudio|videoRecording)")) then 
			(:should we change this to pass in $mets???:)			
			let $json-list:= utils:mets-files($uri,"json","all")						
			let $script:= 
			 	<script type="text/javascript">
    			 $(document).ready(function () {{
    			     clean_json({$json-list});
    			 }});
			 	</script>
			return
			(<div id="lcPlaylistPlayer" style="height: 148px; margin-bottom: 1.5em; width: 522px; display:block;"><!-- end class:lcPlaylistPlayer --></div>
			, $script)
		else
			<div id="ds-digitalport">
				<div id="{if ( contains($uri,'lcwa') or contains($uri,'lcdb') ) then 'viewport-off' else 'viewport-on'}"><!-- end class:viewport-on --></div>
			<!-- end class:ds-viewport --></div>
    
    return    				
    		<div id="ds-maincontent"><span id="objectType" style="visibility: hidden;">{$objectType}</span>
    			{$window}    			
    			<!-- the tabs are for bib views digital behaviors, etc. -->
    			{if (contains($uri,'tohap')) then
    			     md:tohap-content-tab($uri,$url-prefix,$groupings)
    			 else if (contains($uri,'ia')) then
    			     md:ia-content-tab($uri,$url-prefix,$groupings)
    			 else
    			(
				<ul class="tabnav">
				  <li class="first active"><a href="#access">Access/Details</a></li>				 
                  {
                    if (contains($uri,"lcdb")) then
                        <li><a class="get_holdings" href="#holdings">Holdings</a></li>
                    else ()
                  }
					 <li><a href="#rights">Rights/Restrictions</a></li>
				<!-- end class:tabnav --></ul>,

    			<div class="tab_container">
    				<div id="access" class="tab_content">
						{(: removed for now; we can sort the location/url higher if we want on modsbibrecords or 856 on ia/lcdb records 
							let $links-locs:=md:locations($groupings, $uri, $objectType)
					 	  return  if  (exists($links-locs) and $cfg:MY-SITE/cfg:branding/string!="tohap" ) then
    								<div class="access-box">
    									<h2 class="hidden">Access</h2>
    									<ul class="std">{$links-locs}</ul>
    								</div>							 									 								 		
									else 
							 			()
						:)
						}
    					<!-- access-box -->
    					<div id="ds-bibrecord-new">						
    						<h2 class="hidden">Details</h2>
    						{$imagepath}
    						{md:record-display($groupings)}
    					</div>
                    <!--bibrecord-->
    				</div>
    				<!-- access tab -->
    			
    					{
    					   if (contains($uri,"lcdb")) then
    					       (
    					       <a class="hidden" id="holdings_tab_url" href="{$url-prefix}parts/holdings.xqy?uri={$uri}&amp;status=yes"></a>,
    					       <div id="holdings" class="tab_content">
    					       <h2 class="hidden">Holdings</h2>
                                {if ($hold/hld:r) then
                                    (<div class="holdings"></div>)
                                 else
                                    (<span class="noholdings">Library of Congress Holdings Information Not Available.</span>)
                                 }
    					       </div>)
    					   else ()
    					}

                        {md:rights-tab($groupings)}
    			<!-- tab_container --></div>
    			)		
    			}				
    		<!-- maincontent: -->
    		</div>
};

declare function md:record-display($groupings) {
    <dl class="record">
        {                           
          for $element in $groupings//l:full/l:element[l:label/string()!="Copyright"]
              return (
                md:dt-transform($element)                                            
            )                           
        }
    </dl>
};

declare function md:rights-tab($groupings) {
    <div id="rights" class="tab_content">
        <h2 class="hidden">Rights and Restrictions</h2>
        <p>                           
            <strong>Access:&#160;</strong>
            {
                if ($groupings//l:element[matches(lower-case(l:label),"useandreproduction")]) then 
                        for $condition in $groupings//l:element[matches(lower-case(l:label),"useandreproduction")]/l:value
                        return
                            md:li-alltransform($condition)
                else 
                    " Conditions Undetermined."
            }
        </p>                        
        <p>                         
                <strong>Restrictions:&#160;</strong>
                {
                    if ($groupings//l:element[matches(l:label,"estrictions")]) then 
                        for $condition in $groupings//l:element[matches(l:label,"estrictions")]/l:value
                        return
                            md:li-alltransform($condition)                                                                  
                     else 
                         " Undetermined."
                }                           
        </p>                    
        <!--<p>
            <strong>Credit Line:&#160;</strong>
            { if ($groupings//l:element[ matches(l:label,"Permissions")] ) then                             
                    for $condition in $groupings//l:element[matches(l:label,"Permissions")]/l:value
                        return md:li-alltransform($condition)
             else 
              " Undetermined."
            }
            </p>-->
            <p>
            <strong>Copyright Statement:&#160;</strong>
            { if ($groupings//l:element[matches(l:label,"Copyright") ] ) then                           
                    for $condition in $groupings//l:element[matches(l:label,"Copyright") ]/l:value
                        return concat(md:li-alltransform($condition),' ')
             else 
              " Undetermined."
            }
            </p>
   <!-- rights --> </div> 
};

declare function md:tohap-content-tab($uri, $url-prefix,$groupings) {
    let $searchurl:=concat($url-prefix,'parts/tei-tab.xqy?uri=',$uri)
    let $q as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'q','')
    let $searchform := <div class="access-box">
            <form onsubmit="return searchFullText(this);" method="GET" style="margin-bottom:0px; padding-bottom:0px;">
            <label for="searchcollection" class="box-label">Search within text/transcript:</label><br />
                <input name="q" type="text" size="50"  maxlength="125"  class="txt" value="{$q}" onfocus="this.value=''" id="searchcollection"/>
                <button id="submit">Go</button><input name="url" type="hidden" value="{$searchurl}"  id="objid"/>
            </form>
        </div>
    return
      (           
        <ul class="tabnav">
            <li class="first active"><a href="#access">Access/Details</a></li>
            <li><a class="get_snippets" href="#snippets">Text/Transcript Search Results</a></li>
            <li><a href="#transcript">Text/Transcript</a></li>
            <li><a href="#rights">Rights/Restrictions</a></li>
        </ul>,
        <div class="tab_container">
            <div id="access" class="tab_content">
                {(: should the searchform only be displayed when in tohap branding??:) 
                $searchform}
                <!-- access-box -->
                <div id="ds-bibrecord-new">                     
                    <h2 class="hidden">Details</h2>
                    {md:record-display($groupings)}
                </div>
            <!--bibrecord-->
            </div>
            <!-- access tab -->
              
            <a id="tei_tab_url" class="hidden" href="{$url-prefix}parts/tei-tab.xqy?uri={$uri}&amp;q={lp:get-param-single($lp:CUR-PARAMS, 'q')}"></a>
                    <div id="snippets" class="tab_content">
                            <h2 class="hidden">Full-text Search Results</h2>
                            <div id="tei-snips"></div>
                        </div>
                   
                        <div id="transcript" class="tab_content">
                            <h2 class="hidden">Full Text</h2>                                   
                            <div id="tei-div"> </div>
                        </div>
            {md:rights-tab($groupings)}    
        <!-- tab_container -->
        </div>   
      )     
};

declare function md:ia-content-tab($uri, $url-prefix, $groupings) {
    (
                <ul class="tabnav">
                  <li class="first active"><a href="#access">Access/Details</a></li>                 
                  <li><a class="get_search_results" href="#search">Text Search Results</a></li>
                  <!-- <li><a href="#citation">Citation Formats</a></li> -->
                  <li><a href="#rights">Rights/Restrictions</a></li>
                </ul>,
                        
                <div class="tab_container">
                    <div id="access" class="tab_content">
                        <!-- access-box -->
                        <div id="ds-bibrecord-new">                     
                            <h2 class="hidden">Details</h2>
                            {md:record-display($groupings)}
                        </div>
                    <!--bibrecord-->
                    </div>
                    <!-- access tab -->

                    <a class="hidden" id="search_tab_url" href="{$url-prefix}parts/ia-search.xqy?uri={$uri}&amp;q={lp:get-param-single($lp:CUR-PARAMS, 'q')}"></a>,
                    <div id="search" class="tab_content" style="overflow: auto"></div>
                    {md:rights-tab($groupings)}
                <!-- tab_container -->
                </div>                                
        )
};(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)