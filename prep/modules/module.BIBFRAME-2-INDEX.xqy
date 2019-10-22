xquery version "1.0-ml";
(:
:   Module Name: BIBFRAME Full to Index adapted from natlibcat version for namespace issues and uri issues
:
:   Module Version: 1.0
:
:   Date: 2012 Sept 18
:
:   Copyright: Public Domain
:
:   Proprietary XQuery Extensions Used: none
:
:   Xquery Specification: January 2007
:
:   Module Overview:    Primary purpose is to take a full BIBFRAME
:       record and create the index document used by MarkLogic 
:       for indexing.  
:
:)
   
(:~
:   Primary purpose is to take a full BIBFRAME
:   record and create the index document used by MarkLogic 
:   for indexing.   Based on madsrdf2index
:
:   @author Nate Trail (ntra@loc.gov)
:   @since May 18, 2015
:   @version 1.1
: 	Modifications:
:
:       
:)
         
(: NAMESPACES :)
module namespace    bibframe2index      = "info:lc/id-modules/bibframe2index#";
declare namespace   rdf                 = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace   rdfs                = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace   madsrdf             = "http://www.loc.gov/mads/rdf/v1#";
declare namespace   mods	            = "http://www.loc.gov/mods/v3";
declare namespace   mxe					= "http://www.loc.gov/mxe";
declare namespace   ri                  = "http://id.loc.gov/ontologies/RecordInfo#";
declare namespace   bf              	= "http://id.loc.gov/ontologies/bibframe/";
declare namespace   bflc            	= "http://id.loc.gov/ontologies/bflc/";
declare namespace   index               = "info:lc/xq-modules/lcindex";
declare namespace   idx 	            = "info:lc/xq-modules/lcindex";
declare namespace   relators            = "http://id.loc.gov/vocabulary/relators/";
declare namespace	xdmp            	= "http://marklogic.com/xdmp";								
declare namespace 	hld 				= "http://www.indexdata.com/turbomarc";
declare namespace 	pmo  				= "http://performedmusicontology.org/ontology/";

import module namespace ldsindex 		= "info:lc/xq-modules/index-utils" at "/src/xq/modules/index-utils.xqy";
import module namespace lcc 			= "info:lc/xq-modules/config/lcclass" at "/src/xq/modules/config/lcc2.xqy";

declare namespace xdmphttp = "xdmp:http";

(: VARIABLES :)

(:~
:   This is the main function.  It converts full bibframe to 
:   an Index document.
:   It takes the bibframe XML as the only argument.
:
:   @param  $rdf        node() is the bibframe XML  , starting at rdf:RDF/bf:work, instance, item 
:   @param  $mxe 			is nametitle marcxml

:   @return index:index node
:)
declare function bibframe2index:bibframe2index($rdfxml as element(rdf:RDF) , $mxe  ) {
    		
	let $resource := $rdfxml/child::node()[fn:name()][1] (:bf:work, instance, item :)
	
    let $uris := bibframe2index:get_uris($resource)
	
    let $types := bibframe2index:get_types($resource)
        
    let $identifiers := bibframe2index:get_identifiers($resource)

    let $classes := for $c in $resource/bf:classification
						return bibframe2index:get_classes($c)
    
    (: bibframe-related extracts :)
    let $uniformTitle :=  bibframe2index:get_bibframe_uniform_title($resource)
	
	let $mainTitles := bibframe2index:get_bibframe_titles($resource)
	let $aLabel:=if($uniformTitle) then 
	   element index:aLabel {$uniformTitle//text()}
	 else if ($mainTitles) then
	   element index:aLabel {$mainTitles[1]//text()}
	   else 
	       element index:aLabel {"no title"}
    let $bibframeLabels := ()
            (: bibframe2index:get_bibframe_labels($resource):)
    let $creators := bibframe2index:get_bibframe_creator($resource)
    let $contributors := bibframe2index:get_bibframe_contributor($resource)
    (:let $language :=bibframe2index:get_bibframe_language($resource):)

	let $languages := bibframe2index:get_bibframe_language($resource)
	
	let $language:= for $l in fn:distinct-values($languages)
						return element index:language {$l}
    let $derivations := bibframe2index:get_bibframe_derivations($resource)
    
	let $createDate := bibframe2index:get_creation_dates($resource/bf:adminMetadata/bf:AdminMetadata/bf:creationDate, "c")
	
	let $modifyDate := if ($resource/bf:adminMetadata/bf:AdminMetadata/bf:changeDate/text() ) then
				 			bibframe2index:get_creation_dates($resource/bf:adminMetadata/bf:AdminMetadata/bf:changeDate, "m")
				 		else
							 $createDate
	
	(: redundant >(2018-07-11) 
	let $changeDates2:=if (fn:not($changeDates2)) then
							for $e in $changeDates1 
								return
									element index:mDate {$e/*}
						else
						 $changeDates2
						 :)
	let $imprints:=bibframe2index:getImprints($resource//bf:provisionActivity)					
	let $pubPlaces:=bibframe2index:getPubPlaces($resource//bf:provisionActivity)					
	let $issuance:=bibframe2index:getIssuance($resource//bf:issuance)					
	let $generationProcess := bibframe2index:get_generation($resource//bflc:generationProcess)
    let $aaps:=      bibframe2index:get_aaps($resource)
		(: can't remember why rdfxml instead of resource, but leave it for now :)
    let $uri:=fn:string($rdfxml/@rdf:about)
	let $uri:=fn:substring-after($uri,"loc.gov")
	let $display:=   bibframe2index:getHitlist( $rdfxml, $mxe, $uri)
    (:let $_:=xdmp:log("in index","info"):)
	let $result:=
        element index:index {
            $uris,   
			$identifiers,			
            $types,
            $aaps,            
            $uniformTitle,            
			$mainTitles,
			$aLabel,
            $bibframeLabels,
            $creators,
            $contributors/*,           
            $language,
			$classes,
			$imprints,
			$pubPlaces,
			$issuance,
			$display,
            $derivations,
            $createDate[text()],
			$modifyDate[text()],
			$generationProcess		          
        }
		return ($result
	
		)
		
};

declare function bibframe2index:getIssuance($issuances as element()*) as element()* {

for $issuance in $issuances/bf:Issuance

	let $code:=fn:string($issuance/@rdf:about)
	let $code:=if ($code) then fn:tokenize($code,"/")[fn:last()] else ()
	let $label:=if ($code='intg') then "Integrating resource"
    			else if ($code='mulm') then "Multipart monograph"
    			else if ($code='serl') then "Serial"
    			else if ($code='mono') then "Single unit"
    			else $code

return  if ($label!="") then 
		<index:issuance>{$label}</index:issuance> 
		
					(:<wrap><index:issuance>{$label}</index:issuance> 
					 <index:materialGroup> {$label}</index:materialGroup>
					 </wrap>:)
					 (: changed mind about wanting serial, mono etc; instance material groups are pretty good already:)
	else ()


};

(:<bf:provisionActivity><bf:ProvisionActivity><rdf:type rdf:resource="http://id.loc.gov/ontologies/bibframe/Publication"/><bf:place><bf:Place><rdfs:label>Cambridge</rdfs:label></bf:Place></bf:place><bf:place><bf:Place><rdfs:label>New York</rdfs:label></bf:Place></bf:place><bf:agent><bf:Agent><rdfs:label>Cambridge University Press</rdfs:label></bf:Agent></bf:agent><bf:date>1987</bf:date></bf:ProvisionActivity></bf:provisionActivity>
:)
declare function bibframe2index:getImprints($provision as element())  {

for $activity in $provision/bf:ProvisionActivity
for $agent in $activity/bf:agent
	(:let $agent:=$activity/bf:agent[1]:)
	let $imprint:=fn:string($agent/bf:Agent/rdfs:label[1])
	let $imprint:= if ($imprint) then $imprint else fn:string($agent/@rdf:resource)
	let $imprint:=if ($imprint) then $imprint else fn:string($agent/bf:Agent/@rdf:about)
	
	(:let $imprint:=fn:string($agent/@rdf:resource)
		let $imprint:=if ($imprint) then $imprint else fn:string($agent/bf:Agent/@rdf:about)
		let $imprint:= if ($imprint) then $imprint else fn:string($agent/bf:Agent/rdfs:label[1])
	:)

return  if ($imprint!="") then  <index:imprint>{$imprint}</index:imprint> else ()


};
(: pub place  :)
declare function bibframe2index:getPubPlaces($provision as element())  {

for $activity in $provision/bf:ProvisionActivity
for $place in $activity/bf:place	
	let $pubPlace := fn:string($place/bf:Place/rdfs:label[1])
	(:let $pubPlace := if ($pubPlace) then $pubPlace else fn:string($place/@rdf:resource)
	let $pubPlace:=if ($pubPlace) then $pubPlace else fn:string($place/bf:Place/@rdf:about)
	:)

return  if ($pubPlace!="") then  <index:pubPlace>{$pubPlace}</index:pubPlace> else ()


};

(:-----------------------------------------------------------------------
from ldsindex:getPubDates
<bf:provisionActivity><bf:ProvisionActivity><rdf:type rdf:resource="http://id.loc.gov/ontologies/bibframe/Publication"/>
	<bf:date rdf:datatype="http://id.loc.gov/datatypes/edtf">1991</bf:date>
		<bf:place><bf:Place rdf:about="http://id.loc.gov/vocabulary/countries/nyu"/></bf:place>
</bf:ProvisionActivity></bf:provisionActivity>
-----------------------------------------------------------------------:)



declare function bibframe2index:getPubDates($provision as element()) as element()? {
(: unresolved: hebrew and other calendars: lccn 2015477678  :)


for $datenode in $provision//bf:ProvisionActivity/bf:date[1][fn:matches(fn:string(.),"[0-9]")][fn:not(fn:contains(fn:string(.), "minguo"))]             
(: skip japanese dates for now:)
return

 if (fn:matches(fn:string($datenode), "(heisei|showa|taisho|min)","i")) then
		()
		else

	        let $dates:=fn:string($datenode)
	        let $type:=fn:string($datenode/@rdf:datatype)
	        let $begin := if (fn:contains($dates,"(/|-)"))  then
	                        fn:replace($dates,"^(.+)(/|-)(.+)","$1")
	                      else 
	                        $dates
	        let $range:= fn:matches($dates,".*(-|X|/).*")   
	        let $computedBegin:= if ($range) then  replace($begin,"(-|X|/)","0") else ()

	        let $begindate:= 
	             if (fn:exists($computedBegin)) then
	                 fn:substring(fn:replace($computedBegin,"\D+",""),1,4) 
	             else
	                 if ( $begin!="") then
	                     fn:substring(fn:replace($begin,"\D+",""),1,4) 
	                 else 
	                     "Undetermined" (:"-9999":) (: cast as xs:gYear:)
                     
                     
	        let $end:=  if (fn:contains($dates,"(/|-)"))  then  
	                          fn:replace($dates,"^(.+)(/|-)(.+)","$3")
	                    else  if ($range) then fn:replace($begin,"(-|X|/)","9")
	                    else ()

	        let $enddate:= 
	            if (exists($end)) then
	                fn:substring(fn:replace($end,"\D+",""),1,4)
	            else
	                "Undetermined" (:"-9998":)(: cast as xs:gYear :)
        
	        let $result:=
	           if ($range) then
	             <index:range>
	                <index:beginpubdate>{$begindate}</index:beginpubdate>
	            	<index:begyear>{ldsindex:gyear($begindate)}</index:begyear>        
	                <index:endpubdate>{$enddate}</index:endpubdate>
	            	<index:endyear>{ldsindex:gyear($enddate)}</index:endyear>        
	             </index:range>
	             else 
	                (<index:beginpubdate>{$begindate}</index:beginpubdate>,
	            	<index:begyear>{ldsindex:gyear($begindate)}</index:begyear>        )
                
	        return 
	           <index:pubdates>
	                {$result}
	                {if (exists($computedBegin)) then 
	            		let $sort:=
	            			if ($computedBegin="Undetermined")  then 
	            	   			$computedBegin 
	            			else replace($computedBegin,"\D+","")
	                    return (<index:pubdateSort>{$sort}</index:pubdateSort>,
	            				<index:pubyrSort>{ldsindex:gyear($sort)}</index:pubyrSort>        )
	                else if (exists($begindate)) then        
	                    (<index:pubdateSort>{$begindate}</index:pubdateSort> ,
	            		      <index:pubyrSort>{ldsindex:gyear($begindate)}</index:pubyrSort>        )
	                    else ()}        
	            </index:pubdates>
   
};

(:~
:   Records the lccn, isbn, issn: NOT IN USE!
:
:   @param  $el        element() is the MADS/RDF property  
:   @return index:code element()
:)
declare function bibframe2index:get_code($el as element()*) as element()* {
    for $e in $el
    return 
        (
            element index:code { text { $e/text() } },
            if ( fn:contains(xs:string($e), "-") ) then
                let $codeStart := fn:substring-before(xs:string($e), "-")
                let $codeEnd := fn:substring-after(xs:string($e), "-")
                return 
                    (
                        element index:codeStart { $codeStart },
                        element index:codeEnd { $codeEnd }
                    )
            else
                ()
        )
};

(:~
:   Records the code
:
:   @param  $el        element() is the MADS/RDF property  
:   @return index:code element()
:  indexes numbers  of any status, not just the valid ones.
:)
declare function bibframe2index:get_identifiers($el as element()*) as element()* {
    for $e in $el//bf:identifiedBy/*
		return
				if (fn:matches(fn:name($e),"(bf:Lccn|bf:Issn|bf:Isbn)") or 
				   fn:contains(fn:string($e/rdf:type/@rdf:resource), "(Lccn|Issn|Isbn)") 
				) then
				let $types :=fn:concat(fn:local-name($e), fn:replace(fn:string($e/rdf:type[1]/@rdf:resource),"http://id.loc.gov/ontologies/bibframe/",""))
						(: IdentifierLccn  or bf:Issn :)
				let $type:= 
							 if  ( fn:contains($types,"Lccn") ) then
								"index:lccn"
							else if (  fn:contains($types,"Isbn")) then
								"index:isbn"
							else if  ( fn:contains($types,"Issn")) then
								"index:issn"
							else if  ( fn:string($e/bf:source/bf:Source/rdfs:label) ="DLC") then							
									"index:lccn"
							else "index:identifier"
			   		 return
						if ($type="index:identifier") then 
					        ( 
					            element {$type} { fn:normalize-space(fn:string($e/rdf:value)) }			            
	
					        )
						else
					        ( element index:identifier { fn:normalize-space(fn:string($e/rdf:value))},
						            element {$type} { fn:normalize-space(fn:string($e/rdf:value)) }			            
						     )
				else ()

				

};
(:~
:   Records the authorizedAccessPoints (both hash and string
:
:   @param  $el        	element() is the MADS/RDF property  
:   @return index:aap element()
:)
declare function bibframe2index:get_aaps($el as element()*) as element()* {
     
       (for $e in $el//bf:authorizedAccessPoint
        let $elname:=				
					fn:local-name($e/parent::*)				
            return (: no workaap for exoressions or other embedded related works; only the root work:)
				if ($elname = "Work" and fn:local-name($e/parent::*/parent::*) ="RDF") then
					element {fn:concat("idx",$elname,"aap")} { text { $e/text() } }         
				else ()   				
				,
		for $aap in $el/bf:authorizedAccessPoint[fn:not(@xml:lang='x-bf-hash')]
         return 
				element index:aLabel { text { $aap/text() } }    , 
		for $aap in $el/bf:authorizedAccessPoint[@xml:lang='x-bf-hash']
         return 
				element index:WorkHash { xdmp:md5(fn:normalize-space($aap)) }     
				)
};
declare function bibframe2index:get-lcc-facet($mods ,$holdings) {


let $validLCC:=("DAW","DJK","KBM","KBP","KBR","KBU","KDC","KDE","KDG","KDK","KDZ","KEA","KEB","KEM","KEN","KEO","KEP","KEQ","KES","KEY","KEZ","KFA","KFC","KFD","KFF","KFG","KFH","KFI","KFK","KFL","KFM","KFN","KFO","KFP","KFR","KFS","KFT","KFU","KFV","KFW","KFX","KFZ","KGA","KGB","KGC","KGD","KGE","KGF","KGG","KGH","KGJ","KGK","KGL","KGM","KGN","KGP","KGQ","KGR","KGS","KGT","KGU","KGV","KGW","KGX","KGY","KGZ","KHA","KHC","KHD","KHF","KHH","KHK","KHL","KHM","KHN","KHP","KHQ","KHS","KHU","KHW","KJA","KJC","KJE","KJG","KJH","KJJ","KJK","KJM","KJN","KJP","KJR","KJS","KJT","KJV","KJW","KKA","KKB","KKC","KKE","KKF","KKG","KKH","KKI","KKJ","KKK","KKL","KKM","KKN","KKP","KKQ","KKR","KKS","KKT","KKV","KKW","KKX","KKY","KKZ","KLA","KLB","KLD","KLE","KLF","KLH","KLM","KLN","KLP","KLQ","KLR","KLS","KLT","KLV","KLW","KMC","KME","KMF","KMG","KMH","KMJ","KMK","KML","KMM","KMN","KMP","KMQ","KMS","KMT","KMU","KMV","KMX","KMY","KNC","KNE","KNF","KNG","KNH","KNK","KNL","KNM","KNN","KNP","KNQ","KNR","KNS","KNT","KNU","KNV","KNW","KNX","KNY","KPA","KPC","KPE","KPF","KPG","KPH","KPJ","KPK","KPL","KPM","KPP","KPS","KPT","KPV","KPW","KQC","KQE","KQG","KQH","KQJ","KQK","KQM","KQP","KQT","KQV","KQW","KQX","KRB","KRC","KRE","KRG","KRK","KRL","KRM","KRN","KRP","KRR","KRS","KRU","KRV","KRW","KRX","KRY","KSA","KSC","KSE","KSG","KSH","KSK","KSL","KSN","KSP","KSR","KSS","KST","KSU","KSV","KSW","KSX","KSY","KSZ","KTA","KTC","KTD","KTE","KTF","KTG","KTH","KTJ","KTK","KTL","KTN","KTQ","KTR","KTT","KTU","KTV","KTW","KTX","KTY","KTZ","KUA","KUB","KUC","KUD","KUE","KUF","KUG","KUH","KUN","KUQ","KVB","KVC","KVE","KVH","KVL","KVM","KVN","KVP","KVQ","KVR","KVS","KVU","KVW","KWA","KWC","KWE","KWG","KWH","KWL","KWP","KWQ","KWR","KWT","KWW","KWX","KZA","KZD","AC","AE","AG","AI","AM","AN","AP","AS","AY","AZ","BC","BD","BF","BH","BJ","BL","BM","BP","BQ","BR","BS","BT","BV","BX","CB","CC", "CD","CE","CJ","CN","CR","CS","CT","DA","DB","DC","DD","DE","DF","DG","DH","DJ","DK","DL","DP","DQ","DR","DS","DT","DU","DX","GA","GB","GC","GE","GF","GN","GR","GT","GV","HA","HB","HC","HD","HE","HF","HG","HJ","HM","HN","HQ","HS","HT","HV","HX","JA","JC","JF","JJ","JK","JL","JN","JQ","JS","JV","JX","JZ","KB","KD","KE","KF","KG","KH","KJ","KK","KL","KM","KN","KP","KQ","KR","KS","KT","KU","KV","KW","KZ","LA","LB","LC","LD","LE",  "LF","LG","LH","LJ","LT","ML","MT","NA","NB","NC","ND","NE","NK","NX","PA","PB","PC","PD","PE","PF","PG","PH","PJ","PK","PL","PM","PN","PQ","PR","PS","PT","PZ","QA","QB","QC","QD","QE","QH","QK","QL","QM","QP","QR","RA","RB","RC","RD","RE","RF","RG",   "RJ","RK","RL","RM","RS","RT","RV","RX","RZ","SB","SD","SF","SH","SK","TA","TC","TD","TE","TF","TG","TH","TJ","TK","TL","TN","TP","TR","TS","TT","TX","UA","UB","UC","UD","UE","UF","UG","UH","VA","VB","VC","VD","VE","VF","VG","VK","VM","ZA","A","B","C","D","E","F","G","H","J","K","L","M","N","P","Q","R","S","T","U","V","Z")

let  $lcc:= (:sequence of location codes in hld:sh :)
		if (exists($holdings//hld:d852/hld:sh)) then
		   (:($holdings//hld:d852/hld:sh):)
		     for $class in $holdings//hld:d852
		       return <cl search="{$class/hld:sh/string()}">{string-join($class/*[local-name()!='sb'][local-name()!='s3'][local-name()!='st'][local-name()!='sz'][local-name()!='sx'],' ')}</cl>
		else
			for  $class in $mods/mods:classification[@authority="lcc"]
		
				return if (contains($class/string(), '.')) then
				     <cl search="{substring-before($class/string(),'.')}">{$class/string()}</cl>
					else 
				 		<cl search="{$class/string() }">{$class/string()}</cl>

let $possibleLCC:=
	<set>{
		 for $cl in $lcc
		 	return if (matches($cl,'^U.')) then
				()
			else
				let $strip := replace($cl/string(), "(\s+|\.).+$", "")			
				let $subclassCode := replace($strip, "\d", "")			
				return (
					(: lc classes don't have a space after the alpha prefix, like DA1 vs "DA 1" :)
    				if (substring(substring-after($cl/string(), $subclassCode),1,1)!=' ' and $subclassCode = $validLCC  ) then   				
							(<index:lcclass search="{$cl/@search}">{$cl/string()}</index:lcclass>,							
                               $cl,
							 <index:lcc>{lcc:getLCClass($subclassCode)}</index:lcc>)
					else if ($subclassCode="LAW") then
						<index:invalid>{$subclassCode}</index:invalid>(: allows you to see that there's at least one unclassed law later:)
					else 
						()
				   ) 
		}
	</set>
	
return (
         $possibleLCC//index:lcclass,
			if ($possibleLCC//index:lcc) then
			   $possibleLCC/index:lcc[1]
			else 
			 if ($possibleLCC//index:invalid/string()="LAW") then
			    <index:lcc>
					<index:lcc1>K - Law</index:lcc1>
				 	<index:lcc2>K~ - Unclassed</index:lcc2>
				</index:lcc>
			else
			    <index:lcc>
					<index:lcc1>~ - Unclassed</index:lcc1>
				</index:lcc>				
		)
	
};
(:~
:   Records the classifications
:
:   @param  $el        	element() is the MADS/RDF property  
:   @return index:class element()
:)

declare function bibframe2index:get_classes($el as element()*) as element()* {

    for $e in ( $el//bf:ClassificationLcc  ,$el//bf:Classification[rdf:type/@rdf:resource="http://id.loc.gov/ontologies/bibframe/ClassificationLcc"])
	(: not sure which record ?? c015196720, but some classportions are multiples :)
		let $classmods:=<mods:mods><mods:classification authority="lcc">{fn:string($e/bf:classificationPortion[1])}</mods:classification></mods:mods>
		
		let $holdings:=<hld:holdings></hld:holdings>
		let $lcc:=ldsindex:get-lcc-facet($classmods, $holdings)
	

return (
		if ($lcc) then	
			$lcc
			else
		element index:lcc { fn:string($e/bf:classificationPortion)}
		)
		
		
	
	
};

(:~
:   This is gathers all the collections to which this
:   record belongs.
:
:   @param  $el        element() is the MADS/RDF related item  
:   @return index:memberURI element()
:)
declare function bibframe2index:get_collections($el as element()*) as element()* {
    for $e in $el
        return 
            (
                element index:scheme { text { fn:data($e/@rdf:resource) } }
            )
};

(:~
:   This is adds contentSource to the index document.
:
:   @param  $el        element() is the bibframe related item  
:   @return index:contentSource element()
:)
declare function bibframe2index:get_contentSources($el as element()*) as element()* {
    for $e in fn:distinct-values($el/@rdf:resource)
        return 
            (
                element index:contentSource { text { fn:data($e) } }
            )
};

(:~
:   Grabs the creation/modify date for the record
:
:   @param  $el        element() is the MADS/RDF related item  
:   @param  $type       string is c or m, create or modify date
:   @return multiple possible index:cDate/index:mDate elements


:)
declare function bibframe2index:get_creation_dates($el as element()*, $type as xs:string ) as element()* {

    
		for $e in $el
			let $elname:= if ($type="c") then "index:cDate" else "index:mDate" 
			let $date:= fn:normalize-space($e)
			let $date:= if (fn:contains($date,"T")) then
					fn:substring-before($date, "T")
				else 
					$date
			let $date:=if ($date castable as xs:date) then
							$date
						else "1969-01-01"
        	return  (:creation dates  are also modifed dates:)
				if ($elname="index:cDate") then
					<index:cDate>{$date}</index:cDate>
				else
					<index:mDate>{$date}</index:mDate>
};

(:~
:   Grabs the generation process date for the record
:
:   @param  $el        element() is the bibframe generation process set (may include auths process)
:   @return index:generationProcess element()
:)
declare function bibframe2index:get_generation($el as element()*) as element()* {
    for $e in $el
        return element index:generation { text { $e/text() } }
};

(:~
:   Records the RDF types
:
:   @param  $el        element() is the bibframe class
:   @return index:rdftype element() - will be multiple element()
:)
declare function bibframe2index:get_types($el as element()) as element()* 
{
    
	let $root_rdftype := fn:local-name($el)
    
	(: for auths, detect title vs nametitle types title30 means it's from a 130; if it's not that but it is a name auth, then it's a nametitle :)
	let $authtype:= if ($el/bf:title/bf:Title/bflc:title30MarcKey) then 
							element index:rdftype { "Title" }
						else if (fn:starts-with(fn:normalize-space($el/bf:identfiedBy/bf:Lccn/rdf:value),"n"))  then 
							element index:rdftype { "NameTitle" }
				else ()
	return 
        (
        element index:rdftype { text { fn:concat("http://id.loc.gov/ontologies/bibframe/",$root_rdftype)} },
        for $type in $el/../*[fn:matches(fn:local-name(),"(Work|Instance)")]/rdf:type[1]
			let $group:=if (fn:matches($type/@rdf:resource,"ontologies/bibframe/")) then
							 fn:substring-after($type/@rdf:resource,"ontologies/bibframe/")
					    else if (fn:matches($type/@rdf:resource,"ontologies/bflc/")) then
					 			fn:substring-after($type/@rdf:resource,"ontologies/bflc/")
					 	else ()
			return ( element index:rdftype { fn:string($type/@rdf:resource) } ,
					 if ($group) then
							element index:materialGroup { $group}
				 	else ()
					),
					if (fn:not($el/../*[fn:matches(fn:local-name(),"(Work|Instance)")]/rdf:type)) then
				 		element index:materialGroup { fn:local-name($el) }
					else ()
				,
				$authtype
	
       )
};

(:~
:   Records the URIs
:
:   @param  $el        element() is the MADS/RDF property  
:   @return index:uri element(), index:token element() - will be multiple element()
:)
declare function bibframe2index:get_uris($el as element()) as element()* {
    
	let $about := fn:string($el/@rdf:about)  	(: http://id.loc.gov/resources/works/n99269797":)
    let $uriandtoken:= if (fn:starts-with($about, "loc.natlib." )) then
							(: coming from editor, uri is okay already:)
						 (element index:uri {  $about },
						  element index:token { fn:tokenize( $about , '\.')[fn:last()] }
						  )
				else
					let $uri_tokens := fn:tokenize( $about , '/')
					let $obj := $uri_tokens[5]
					let $lccn := $uri_tokens[6] (: not really lccn, just for auths:)
					let $uri:=fn:concat("loc.natlib.",$obj,".",$lccn)	
					 return (	element index:uri { text { $uri } },
            					element index:token { text { $lccn } }
								)
	
    let $bfdoctype:= if (fn:matches(fn:string($el//bf:adminMetadata/bf:AdminMetadata/bflc:derivedFrom/@rdf:resource),"/authorities/names")) then
                            "/bibframe/transformedTitles/"
                     else if (fn:matches(fn:string($el//bf:adminMetadata/bf:AdminMetadata/bflc:derivedFrom/@rdf:resource),"/bibs/")) then
                            "/bibframe/convertedBibs/"
                     else  (:not converted name/title, not converted marc :)
                            "/bibframe/newEntry/"
                        
    return
        ( 	$uriandtoken,
            
			element index:scheme { "/bibframe/" },			
			element index:scheme { $bfdoctype } ,
			element index:scheme { if (fn:name($el)="bf:Work") then 
										"http://id.loc.gov/resources/works/" 
									else if (fn:name($el)="bf:Instance") then
										"http://id.loc.gov/resources/instances/" 
									else if (fn:name($el)="bf:Item") then
										"http://id.loc.gov/resources/items/" 
										else fn:name($el)
								} 
        )
};

(:~
:   Extracts the contributor from an instance from a work.
:
:   @param  $resource is the resource  
:   @return index:contributor), index:role or nothing in <wrap>
:)
declare function bibframe2index:get_bibframe_contributor
    ($resource as element()) 
    as element()*
{

let $contribs:=
    for $t in   $resource/self::bf:Work/bf:contribution/*/bf:agent
    	let $con:=   
			if ($t/bf:Agent/rdfs:label) then     			 	
	            xs:string($t/bf:Agent/rdfs:label)				
			else if ($t/*/rdfs:label) then     			 	
	            xs:string($t/*[1]/rdfs:label)				
			else if ($t/@rdf:resource) then 
				fn:string($t/@rdf:resource) 
			else if ($t/*[1]/@rdf:about ) then  (:madsrdf:PersonalName, eg.:)
				fn:string($t/*[1]/@rdf:about) 
			else 
	            ()
 			return if ($con) then
			   			element index:contributor {
			   				$con
						}
					else ()
		let $roles-raw:=		
			for $rnode in   $resource/self::bf:Work/bf:contribution/*/bf:role
    			let $role:=   
					  if ($rnode/bf:Role/rdfs:label) then     				 	
			            	xs:string($rnode/bf:Role/rdfs:label)					
					  else if ($rnode/@rdf:resource) then 
					        	fn:string($rnode/@rdf:resource) 
					  else if ($rnode/bf:Role/@rdf:about ) then  (:relators/act eg.:)
						        fn:string($rnode/bf:Role/@rdf:about) 
					  else 
			              ()
			   return 				   
				   			if ($role and fn:contains($role,"id.loc.gov/vocabulary/relators/")) then
							    fn:concat("rel:", fn:tokenize($role,"/")[fn:last()])
							else if ($role) then
							   fn:replace(fn:normalize-space($role),"(.+)(\.|:|,)$","$1")					
  					  else ()
 let $roles :=for $rtext in distinct-values($roles-raw)
        return element index:role {
                  $rtext				  
                  }

return <wrap>{$contribs}{$roles}</wrap>
};


(:~
:   Extracts the creator from a work.  This 
:   will have to be monitored. Is it possible to
:   simply refine a search query to accurately 
:   identify a resource without knowing
:   the precise relationship between the creator and 
:   the work.
:
:   @param  $resource is the resource  
:   @return index:creator or nothing
:)
declare function bibframe2index:get_bibframe_creator
    ($resource as element()) 
    as element()*
{
    for $t in   $resource/self::bf:Work/bf:contribution/*[(self::* instance of element(bflc:PrimaryContribution) ) or rdf:type/rdf:resource="http://id.loc.gov/ontologies/bflc/PrimaryContribution"]
    return
        element index:creator {		

			if ($t/bf:agent/@rdf:resource )then 
				(fn:string($t/bf:agent/@rdf:resource))
			else if ($t/bf:agent/*/rdfs:label )then 
				for $l in $t/bf:agent/*
					return $l/rdfs:label[1]/fn:string()
			else if ($t/bf:agent/madsrdf:*/@rdf:about )then 
				(fn:string($t/bf:agent/madsrdf:*/@rdf:about))
			else
            	($t/bf:agent/bf:Agent[1]/*[fn:matches(fn:local-name(),"primaryContributorName[0-9]{2}MatchKey")]/@xml:lang,
            		xs:string($t/bf:agent/bf:Agent/*[fn:matches(fn:local-name(),"primaryContributorName[0-9]{2}MatchKey")])
				)			
			}

};

(:~
:   Extracts the derivation relationships.
:
:   @param  $resource is the resource  
:   @return index:derivedFrom or nothing
:)
declare function bibframe2index:get_bibframe_derivations
    ($resource as element()) 
    as element()*
{
    for $t in   $resource/bflc:derivedFrom/@rdf:resource
    return
        element index:derivedFrom {
            xs:string($t)
        }
};

(:~
:   Extracts the variant titles
: not used
:   @param  $resource is the resource  
:   @return index:title elements or nothing
:)
declare function bibframe2index:get_bibframe_labels
    ($resource as element()) 
    as element()*
{
    for $t in $resource/rdfs:label
    return
        element index:label {
            $t/@xml:lang,
            xs:string($t)
        }
};
(:~
:   Extracts the language
:   This will require some kind of refinement
:   for codes
:
:   @param  $resource is the resource  
:   @return index:language (s) or nothing
<bf:language>
<bf:Language>
<bf:part>accompanying material</bf:part>
<bf:identifiedBy><bf:Identifier>
<rdf:value rdf:resource="http://id.loc.gov/vocabulary/languages/ger"/><bf:source><bf:Source rdf:about="http://id.loc.gov/vocabulary/languages"/></bf:source></bf:Identifier></bf:identifiedBy></bf:Language></bf:language>
:)
declare function bibframe2index:get_bibframe_language
    ($resource as element()) 
    as xs:string*
{
      
	  for $lang in $resource/bf:language
		let $l:=
		 if ($lang/@rdf:resource) then         			
            		xs:string($lang/@rdf:resource)
                else if ($lang/bf:Language/@rdf:about) then
					xs:string($lang/bf:Language/@rdf:about)
					(: overcoming bad practice? :)
				else if ($lang/bf:Language/bf:identifiedBy/*[1]/rdf:value/@rdf:resource) then
					fn:string($lang/bf:Language/bf:identifiedBy/*[1]/rdf:value/@rdf:resource) 
        		else if ($lang/bf:Language/rdfs:label ) then		 			
					fn:string($lang/bf:Language/rdfs:label[1])
				else ()
			return if (fn:contains($l,"id.loc.gov/vocabulary/languages/")) then
							fn:concat("mlang:", fn:tokenize($l,"/")[fn:last()])
							else
							$l
};
(:~
:   Extracts the uniformTitle, builds a nametitle combo
:
:   @param  $resource is the resource  
:   @return index:uniformTitle or nothing
:)
declare function bibframe2index:get_bibframe_uniform_title
    ($resource as element()) 
    as element()*
{ (: bf editor uses this for nametitle construct:  :)
	
	
	if (fn:string($resource/madsrdf:authoritativeLabel)!="") then
		element index:nameTitle {fn:string($resource/madsrdf:authoritativeLabel)}
	else 
       	let $name:=
                      for $contrib in $resource/bf:contribution/bf:Contribution[rdf:type/@rdf:resource="http://id.loc.gov/ontologies/bflc/PrimaryContribution"][fn:not(fn:contains(bf:agent/bf:Agent[1]/@rdf:about, "Agent880"))]
                               return        fn:string($contrib/bf:agent/bf:Agent[1][fn:not(fn:contains(@rdf:about, "Agent880"))]/bflc:*[fn:starts-with(fn:local-name(),'primaryContributorName')][1])
       	(: was:
       			let $name:= for $n in $resource/bf:contribution/*[self::* instance of element(bflc:PrimaryContribution) or rdf:type/@rdf:resource="http://id.loc.gov/ontologies/bflc/PrimaryContribution"][1]
       				              return $n/bf:agent/bf:Agent[1][fn:not(fn:contains(@rdf:about, "Agent880"))]/bflc:*[fn:matches(fn:local-name(),"^name[0-9]{2}MatchKey$")]				
       			:)
       	
       	(:let $name:= if ($name) then  (:use 880 if none else found :)
       						$name 
       				else
       				   for $contrib in $resource/bf:contribution/bf:Contribution[1]/bf:agent/bf:Agent[1]
                               return        fn:string($contrib/bflc:*[fn:matches(fn:local-name(),"^name[0-9]{2}MatchKey$")][1])
       	:)
       	let $title:=	
       	 	if (  $resource/bf:title/bf:Title[1][bflc:*[fn:matches(fn:local-name(),"^title[0-9]{2}MatchKey$")]]	) then
       			for $t in $resource/bf:title/bf:Title[1][bflc:*[fn:matches(fn:local-name(),"^title[0-9]{2}MatchKey$")]]
       					return  if (
       								fn:not(fn:contains(
       									fn:string(
       						      			$t/bflc:*[fn:matches(fn:local-name(),"^title[0-9]{2}MarcKey$")]
       						      			),"$6880")) 
       							) then
       				 			 xs:string($t/bflc:*[fn:matches(fn:local-name(),"^title[0-9]{2}MatchKey$")][1])
       						else 
       							()
       		else
       			if (  $resource/bf:title/bf:Title[1]/bflc:titleSortKey	) then
       				fn:string($resource/bf:title[1]/bf:Title[1]/bflc:titleSortKey)
       				 				
       		else
               	for $t in $resource/bf:title/bf:Title[1]
       				return xs:string($t/rdfs:label[1])
       				
        let $title:=fn:replace($title[1], "/$","")
		    	

	return
				( if ($title!="") then                      	 
					  element index:uniformTitle {			        		    
			            		$title
			        	}
					else (),
				 if ($name="") then 
						element index:nameTitle {
			        		    fn:normalize-space( $title[1] )
			        		}					
					else if ($title!="" or $name!="") then
						element index:nameTitle {
			        		    fn:normalize-space(
									fn:concat(fn:string($name[1]),	" ", $title[1]	)
								)
			        	}					
					else ()
				)


};

(:~
:   Extracts the main titles (i.e. not variants not uniforms)
:
:   @param  $resource is the resource  
:   @return index:title elements or nothing
:)
declare function bibframe2index:get_bibframe_titles
    ($resource as element()) 
    as element()*
{ (: no bflc:)
    for $t in $resource//bf:title/bf:Title[bf:mainTitle/text()]
    return
        element index:mTitle {
            $t/bf:mainTitle/@xml:lang,
            xs:string($t/bf:mainTitle)
        }
};
declare function bibframe2index:getHitlist($metadata as element() ,$mxe as element(), $uri as xs:string) as element()+ {

(: display terms for search hit list also includes mxe elements for title and subject lexicon indexes:)
(: bib or auth test is actually ingested bibs vs nametitle or bf editor :)

let $bibOrAuth:=if ($metadata//*[self::node() instance of element (bf:Work) or self::node() instance of element (bf:Instance)
					or self::node() instance of element (bf:Item)] ) then "auth" else "bib"

let $mxetitle:=
    if ($bibOrAuth = "auth") then
        for $node in $metadata//*[self::node() instance of element (bf:Work) or self::node() instance of element (bf:Instance)
					or self::node() instance of element (bf:Item)][1]
		 	let $title-node:=
					$node/bf:title/bf:Title[fn:not(rdf:type)][1]
			let $title-node:= if ($title-node) then
									$title-node
							  else 
							  		$node/bf:title/bf:Title/bflc:*[fn:matches(fn:local-name(),"^title[0-9]{2}MatchKey$")][1]
			let $title-node:= if ($title-node) then
									$title-node
							  else $node/bf:title/bf:Title[rdf:type/@rdf:resource="http://id.loc.gov/ontologies/bibframe/KeyTitle"][1]
    		let $title-node:= if ($title-node) then
									$title-node					
							 else
							 	$node/bf:title/bf:Title[1]

					(:for $t in $node/bf:title
						return if ($t/bf:Title[fn:not(rdf:type)] ) then 
									$t/bf:Title
								else if ($t/bf:Title/bflc:*[fn:matches(fn:local-name(),"^title[0-9]{2}MatchKey$")]) then 
									$t/bf:Title
								else if ($t/bf:Title[rdf:type/@rdf:resource="http://id.loc.gov/ontologies/bibframe/KeyTitle"]) then
									 $t/bf:Title[rdf:type/@rdf:resource="http://id.loc.gov/ontologies/bibframe/KeyTitle"]
								else $t/bf:Title[1]
					:)
			
			return for $t in $title-node[1]
					let $title:=
					 if ($t/bflc:*[fn:matches(fn:local-name(),"^title[0-9]{2}MatchKey$")]) then
		            	 		fn:string($t/bflc:*[fn:matches(fn:local-name(),"^title[0-9]{2}MatchKey$")])
							else (: instances from editor have no rdfs:label :)
								if (fn:string($t/bf:mainTitle) !="") then		
									fn:string($t/bf:mainTitle[1])

							else if ($t/rdfs:label[@xml:lang="en"]) then
									fn:string($t/rdfs:label[@xml:lang="en"])
							else if ($t/rdfs:label[fn:not(@xml:lang)]) then
								fn:string($t/rdfs:label[fn:not(@xml:lang)])
							else if ($t/rdfs:label) then
									fn:string($t/rdfs:label[1])
							else ()
					 return fn:replace($title, "/$","")

	
	(:					
		for $t in $metadata//*[self::node() instance of element (bf:Work) or self::node() instance of element (bf:Instance)
					or self::node() instance of element (bf:Item)][1]/bf:title[1]/bf:Title[1]
			let $title:=
			 if ($t/bflc:*[fn:matches(fn:local-name(),"^title[0-9]{2}MatchKey$")]) then
            	 		fn:string($t/bflc:*[fn:matches(fn:local-name(),"^title[0-9]{2}MatchKey$")])
					else (: instances from editor have no rdfs:label :)
						 if ($t/bf:mainTitle) then
							fn:string($t/bf:mainTitle)

					else if ($t/rdfs:label[@xml:lang="en"]) then
							fn:string($t/rdfs:label[@xml:lang="en"])
					else if ($t/rdfs:label[fn:not(@xml:lang)]) then
						fn:string($t/rdfs:label[fn:not(@xml:lang)])
					else if ($t/rdfs:label) then
							fn:string($t/rdfs:label[1])
					else ()
			 return fn:replace($title, "/$","")
		:)
	 
	 else for $subpart in $mxe//mxe:datafield_245     
       return    string-join($subpart/*[local-name()!="d245_subfield_c"][local-name()!="d245_subfield_6"]," ")

let $mxetitle:=if ($mxetitle!="") then
						$mxetitle
					else 
						$uri
let $mxetitle:=$mxetitle[1]         
let $mxetitleText:= 
        if (string-length($mxetitle) >200 ) then
                concat(ldsindex:findLastSpace(substring($mxetitle,1,200)),"... / ",$mxe/mxe:datafield_245/mxe:d245_subfield_c[1])
        else if (substring($mxetitle,string-length($mxetitle),1) = "/") then
                    substring($mxetitle,1,string-length($mxetitle)-1) 
        else $mxetitle

let $mxetitleText:=element index:title {if (exists($mxetitleText)) then $mxetitleText  else "[Unknown]"}        

let $mxetitleLex:=
    if ($bibOrAuth="auth") then $mxetitle
    else   for $data in $mxe//mxe:datafield_245/*[local-name()!="d245_subfield_6"] return concat($data/string()," ")

                  (: subjects should be from known controlled lists, so  653  is out(uncontrolled index) :)

let $mxesubjectLex:=
    if ($bibOrAuth="auth") then 
			<subjects>{
						for  $subj in $metadata//bf:subject
							return <index:subjectLexicon>{fn:string($subj/*/madsrdf:authoritativeLabel[1])}</index:subjectLexicon>
					}</subjects>
    else 
        <subjects>{
                    for $subj in $mxe//*[(contains(local-name(),"datafield_6") and not(local-name()='datafield_653')) or (local-name()="datafield_880" and starts-with(mxe:d880_subfield_6,'6') )]
                           let $sub:=                     
                                string-join($subj/*[not(matches(local-name(),"(subfield_2|subfield_6)") )],"--")
							let $auth:= if ($subj/@ind2="0") then "lcsh" 
											else if  ($subj/@ind2="1") then "lcshac"  
											else if  ($subj/@ind2="2")  then "mesh"  
											else if  ($subj/@ind2="5")  then "csh"
											else if  ($subj/@ind2="3")  then "nal"
											else if  ($subj/@ind2="6")  then "rvm"
									   else ()  
							let $authattrib:=concat("vocab_",$auth)
		                    return
		                    	if ($auth!='') then
		                     		<index:subjectLexicon > {attribute {$authattrib} {$auth} } {  $sub }</index:subjectLexicon>
		                     	else
		                     		<index:subjectLexicon > { $sub }</index:subjectLexicon>
					
					
		            }
        </subjects>
                     (: remove $c roles/locations of meetings 1/30/2011 :)
let $pname:= 
        for $data in $mxe//mxe:datafield_100
                        return string-join($data/*[local-name()!="d100_subfield_e" and local-name()!="d100_subfield_4" and local-name()!="d100_subfield_6" and local-name()!="d100_subfield_c" ]," ")                      

let $corpname:=  for $data in $mxe//mxe:datafield_110
                            return string-join($data/*[local-name()!="d110_subfield_e" and local-name()!="d110_subfield_4" and local-name()!="d110_subfield_6" and local-name()!="d110_subfield_c"]," ")                             

let $meetname:= for $data in $mxe//mxe:datafield_111
                        return string-join($data/*[local-name()!="d111_subfield_j" and local-name()!="d111_subfield_4" and local-name()!="d111_subfield_6" and local-name()!="d111_subfield_c"]," ")                             

let $pname880 :=for $data in $mxe//mxe:datafield_880[starts-with(mxe:d880_subfield_6,'100')]
                        return string-join($data/*[local-name()!="d880_subfield_e" and local-name()!="d880_subfield_4" and local-name()!="d880_subfield_6" and local-name()!="d880_subfield_c"]," ")  

let $corpname880:=  for $data in $mxe//mxe:datafield_880[starts-with(mxe:d880_subfield_6,'110')]
                            return string-join($data/*[local-name()!="d880_subfield_e" and local-name()!="d880_subfield_4" and local-name()!="d880_subfield_6" and local-name()!="d880_subfield_c"]," ")                             

let $meetname880:= for $data in $mxe//mxe:datafield_880[starts-with(mxe:d880_subfield_6,'111')]
                        return string-join($data/*[local-name()!="d880_subfield_j" and local-name()!="d880_subfield_4" and local-name()!="d880_subfield_6" and local-name()!="d880_subfield_c"]," ")                             

let $namelang:= if ($mxe//mxe:datafield_880[matches(mxe:d880_subfield_6,'^(100|110|111)+') and contains(mxe:d880_subfield_6,'(2') ] ) then   "he" 
                        else if ($mxe//mxe:datafield_880[matches(mxe:d880_subfield_6,'^(100|110|111)+') and contains(mxe:d880_subfield_6,'(3')] ) then "ar" 
                        else ()                  

let $corpname:=  for $data in $mxe//mxe:datafield_110
                            return string-join($data/*[local-name()!="d110_subfield_e" and local-name()!="d110_subfield_4" and local-name()!="d110_subfield_6" and local-name()!="d100_subfield_c"]," ")                             
let $meetname:= for $data in $mxe//mxe:datafield_111
                        return string-join($data/*[local-name()!="d111_subfield_j" and local-name()!="d111_subfield_4" and local-name()!="d111_subfield_6" and local-name()!="d100_subfield_c"]," ")                             

let $mxecreator:=  if ($bibOrAuth = "auth" ) then  								
				   	for $creator in $metadata//bf:Work/bf:contribution/*[. instance of element (bflc:PrimaryContribution) or rdf:type/@rdf:resource="http://id.loc.gov/ontologies/bflc/PrimaryContribution"]/bf:agent/bf:Agent/bflc:*[fn:starts-with(fn:local-name(),'primaryContributorName')]							
				   			return if ($creator/bf:agent/@rdf:resource )then 
											fn:string($creator/bf:agent/@rdf:resource)
			 						else	fn:string($creator)

		            else if ( exists($pname)) then $pname 
		            else if (exists($corpname)) then $corpname
		            else $meetname

let $mxecreator880:= if ( exists($pname880)) then $pname880
                            else  if (exists($corpname880)) then $corpname880
                            else $meetname880
                            
(:
	let $nameTitle:= if (exists($mxetitle) and exists($mxecreator))  then
                             <index:nameTitle>{concat($mxecreator," ",$mxetitle)}</index:nameTitle>							 
                        else ()
:)
let $pubDates:=   if ($bibOrAuth="auth") then
						for $provision in $metadata//bf:provisionActivity
							return  bibframe2index:getPubDates($provision)
					else 
						ldsindex:getPubDates($metadata/mods:originInfo)
let $mxepub:= 		
				if ($mxe/mxe:datafield_260) then
					element index:pubinfo {	string-join($mxe/mxe:datafield_260/*[local-name()!="d260_subfield_6"]," ")}
				else
					ldsindex:getModsPub($metadata)			
				
(:let $mxepub:=element index:pubinfo {string-join($mxe/mxe:datafield_260/*[local-name()!="d260_subfield_6"]," ")}:)
let $mattype:=  if ($bibOrAuth="auth") then 
				()
				else
					ldsindex:getMattype($mxe)
 
return  
        ( 
                <index:display>
                {  if (exists($mxetitleText)) then  $mxetitleText else ()}
                  { if (exists($mxecreator) ) then 
                       	(   for $c in $mxecreator
						  		return (element index:mainCreator {$c} ,
										element index:byName {$c} 
										)
								)
                      else () ,
                     if (exists($mxecreator880)  and exists($namelang)) then 
                         <index:mainCreator xml:lang="{$namelang}"> {$mxecreator880} </index:mainCreator>
                        else
                     if (exists($mxecreator880) ) then 
                         element index:mainCreator880  {$mxecreator880}
                      else ()
                   } 
               {$mxepub}               
               {$mattype}
			   {if (exists($mxecreator) ) then 
                     element index:nameSort {$mxecreator[1]} 
                else () 
				}
        </index:display>,
        if (exists($mxetitleLex)  ) then 
              element index:titleLexicon {$mxetitleLex}
        else
			 (),
	    $mxesubjectLex/*,     
  		$pubDates
  	
  		)		
};
(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)