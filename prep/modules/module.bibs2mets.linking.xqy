xquery version "1.0-ml";
(: 
	shared module for editor and bib conversion get-instances , get-items is used by both, now get-work is shared by process-bib-files and yaz process bib files 2017-12-15
	now in prod: linking on 7xxworks, translations, 130/240 sub-parts
	

* 	this version does not expect to merge; see if it does ; some stuff maybe ok ????

	Nametitles are loaded as superworks (collection /bibframe/hubworks/  )
		and Work subclass (rdftype) "http://id.loc.gov/ontologies/lclocal/Hub"
	Bibs look for matching name title  or title superwork; if found and its a superwork from a bib with no other rdf subclass, 
			*link to it (expressionOf?)
			 DON'T copy it's subjects and classes to the superwork

		if found and there is an rdftype such as Audio then this is a bib that's been converted to superwork
			*create a stub superwork from the found record (stripping properties that are manifesty, esp the rdftype work subclasses, add Hub subclass)

			* link from the found work to the new superwork (remove it from the hub collection)
			* link from the current work to the new superwork
			save all 3 works
			save instances and items.
			
	If not found, add superwork collection and NO subclass: available for linking as a "pre-superwork"

	This prevents us from creating stub superworks until they are actually needed.

Types of links, merges: 
	130/240 subfields subtracted to find parents  eg.,
			"Twain,Mark Works. Selections. German"	
			"Bible New Testament. Newari. 2015."
	7xx related:
		hasPart chapter1 title.
		absorbedInto Other Serial Title
	Auths 4xx relatedworks (
	6xx subject Works
	Exact NameTitle

Only exact whole Nametitle 130/240 or 245 gets Hub treatment. Others are just links between existing works.
Are they the only FRBR expressions?

	Starting to code 11/29/18; not in use yet

:)
module namespace bibs2mets = "http://loc.gov/ndmso/bibs-2-mets";


import module namespace 		bibframe2index   	= "info:lc/id-modules/bibframe2index#"   at "module.BIBFRAME-2-INDEX.xqy";
import module namespace 		bf4ts   			= "info:lc/xq-modules/bf4ts#"   		 at "module.BIBFRAME-4-Triplestore.xqy";
import module namespace 		mem 				= "http://xqdev.com/in-mem-update" 		 at "/MarkLogic/appservices/utils/in-mem-update.xqy";
import module namespace 		auth2bf				= "http://loc.gov/ndmso/authorities-2-bibframe" at "../../auths/authorities2bf.xqy";
import module namespace 		searchts 			= 'info:lc/xq-modules/searchts#' 		 at "/modules/xq/modules/module.SearchTS.xqy";
declare namespace sparql                = "http://www.w3.org/2005/sparql-results#";
declare namespace 				rdf					= "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace  				rdfs   			    = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace   			mets       		 	= "http://www.loc.gov/METS/";
declare namespace  				marcxml             = "http://www.loc.gov/MARC21/slim";
declare namespace 				madsrdf   		    = "http://www.loc.gov/mads/rdf/v1#";
declare namespace  				mxe					= "http://www.loc.gov/mxe";
declare namespace 				bf					= "http://id.loc.gov/ontologies/bibframe/";
declare namespace				bflc				= "http://id.loc.gov/ontologies/bflc/";
declare namespace 				index 				= "info:lc/xq-modules/lcindex";
declare namespace 				idx 				= "info:lc/xq-modules/lcindex";
declare namespace   			mlerror	            = "http://marklogic.com/xdmp/error"; 
declare namespace				pmo 	 			= "http://performedmusicontology.org/ontology/";
declare namespace				lclocal				="http://id.loc.gov/ontologies/lclocal/";

declare variable $BASE_COLLECTIONS:= ("/lscoll/lcdb/", "/lscoll/", "/catalog/", "/catalog/lscoll/", "/catalog/lscoll/lcdb/",
 "/catalog/lscoll/lcdb/bib/","/bibframe-process/reloads/2017-09-16/" );
declare variable $BASE-URI  as xs:string:="http://id.loc.gov/resources/works/";
declare variable $INVERSES :=<set>
<rel><name>relatedTo</name><inverse>relatedTo</inverse></rel>
<rel><name>hasInstance</name><inverse>instanceOf</inverse></rel>
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
<rel><name>translation</name><inverse>translationOf</inverse></rel>
<rel><name>translationOf</name><inverse>translation</inverse></rel>
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
<rel><name>continuedInPartBy</name><inverse>separatedFrom</inverse></rel>
</set>;
declare variable $LINK-EXPRESSIONS:=<set>
	<node>http://id.loc.gov/ontologies/bibframe/NotatedMusic</node>
	<node>http://id.loc.gov/ontologies/bibframe/NotatedMovement</node>
	<node>http://id.loc.gov/ontologies/bibframe/MovingImage</node>
	<node>http://id.loc.gov/ontologies/bibframe/Audio</node>
</set>;
declare variable $UT-ADDONS:=<set>
	<node code="d">bf:treatyDate</node>
	<node code="f">bf:originDate</node>
	<node code="ghk">bf:genreForm</node>
	<node code="k">bf:natureOfContent</node>
	<node code="l">bf:language</node>
	<node code="m">bf:musicMedium</node>
	<node code="n">bf:partNumber</node>
	<node code="r">bf:musicKey</node>
	<node code="s">bf:version</node>
	<node code="p">bf:partName</node>
	
</set>;
declare variable $ut-parts:=$UT-ADDONS//node/text()
(: 
	functions to format either bf raw output of conversion or
	bfe output to 3 mets docs for loading. (bfe does not merge, just stores)
	
 :)
 
(:
    Unique URI strategy
    
    c+ zero padded bibid +
    4-digit number, beginning 0001

:)
(:
    Tokenize URI
    Generate work URI  
    Get Bib MARC/XML
    
    Transform MARCXML/BIB to BIBFRAME/RAW
    
    Works
        Check if exists
            if yes, then retrieve work record
                add subjects, all other info
            if no, then add to db as own work  
			copy adminMeta to instance IF IT doesn't have one!

    Instance
        for each instance
            associate with work
            generate URI, add to DB.

    Items
        for each item
            associate with instance             
            use instance URI, add to DB.
			ids are relative to the work, not the instance, or we'd get impossibly long ids.
:)
(:
    $pos is the offset position of an instance or item
    paddedid is the c00[bibid]
:)
declare function bibs2mets:get-padded-subnode($pos, $paddedID) as xs:string {

let $iNumStr := xs:string($pos)
  let $iNumLen := fn:string-length($iNumStr)
  let $iID := 
      if ( $iNumLen eq 1 ) then
          fn:concat( $paddedID, "000", $iNumStr )
      else if ( $iNumLen eq 2 ) then
          fn:concat( $paddedID, "00", $iNumStr )
      else if ( $iNumLen eq 3 ) then
          fn:concat( $paddedID, "0", $iNumStr )
      else
          fn:concat( $paddedID, $iNumStr )
          return $iID
   };
declare function bibs2mets:chars-001($arg as xs:string?) as xs:string* {       
   for $ch in string-to-codepoints($arg) return codepoints-to-string($ch)
};
(: padded to 9 if less :)
declare function bibs2mets:padded-id($id as xs:string) 
{

    let $idLen := fn:string-length( $id )
    let $paddedID := 
        if ( $idLen eq 1 ) then
            fn:concat("00000000" , $id)
        else if ( $idLen eq 2 ) then
            fn:concat("0000000" , $id)
        else if ( $idLen eq 3 ) then
            fn:concat("000000" , $id)
        else if ( $idLen eq 4 ) then
            fn:concat("00000" , $id)
        else if ( $idLen eq 5 ) then
            fn:concat("0000" , $id)
        else if ( $idLen eq 6 ) then
            fn:concat("000" , $id)
        else if ( $idLen eq 7 ) then
            fn:concat("00" , $id)
        else if ( $idLen eq 8 ) then
            fn:concat("0" , $id)
        else 
            $id
    return $paddedID
    
};

(: this links to 7xx works that have lccn's (identifier with source DLC)
using cts, not triples :)

declare function bibs2mets:link-via-lccn2($lccn,  $workDBURI) {

	let $q:= cts:and-query((
				cts:element-value-query(xs:QName("idx:lccn"),$lccn),
      			cts:collection-query("/catalog/"),
				cts:collection-query("/resources/instances/")                                   
                ))
 let $uri:=
			cts:uris((),(),
			      $q
			  )[1 to 5]

  
  return if (count($uri) = 0) then
  			xdmp:log(fn:concat("CORB BIB merge: not linking ",$workDBURI," via lccn ", $lccn, " zero hits. " ),"info")
		else  if (count($uri) != 1) then
			xdmp:log(fn:concat("CORB BIB merge: not linking ",$workDBURI," via lccn ", $lccn, " too many hits. " ),"info")
			  
   else
		let $instance-uri:=fn:replace(fn:tokenize($uri,"/")[fn:last()],".xml","")
		let $instance-uri:=fn:concat("http://id.loc.gov/resources/instances/",$instance-uri)
		
		let $q:=  <query><![CDATA[
	
		      		PREFIX madsrdf: <http://www.loc.gov/mads/rdf/v1#>
					PREFIX rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
					PREFIX rdfs:        <http://www.w3.org/2000/01/rdf-schema#>			
					PREFIX bf:          <http://id.loc.gov/ontologies/bibframe/>
					PREFIX bflc:        <http://id.loc.gov/ontologies/bflc/>
		   			
					SELECT distinct ?work
			  	  	WHERE {		?uri bf:instanceOf ?work .	}
		   limit 10  
		                ]]></query>
 
		 let $uri-param:=         
		            sem:iri(
		                $instance-uri             
		            )
					(:map:entry( "lccn", sem:iri( fn:string($lccn))):)          
		let $params := 
		        map:new((		            
		            map:entry( "uri",   $uri-param)
		        ))
		
				let $res:=  searchts:sparql($q/text(), $params,"/resources/instances/")		
	
		let $relatedWork:= if($res//sparql:result) then
		     fn:string($res//sparql:result[1]/sparql:binding[ @name="work"]/sparql:uri)
     
		     else ()
     
		return if ($relatedWork) then
				(	$relatedWork,xdmp:log(fn:concat("CORB BIB merge: linked via lccn ", $workDBURI, " to :" ,$relatedWork),"info"))
				else ("",xdmp:log(fn:concat("CORB BIB merge: not linked via lccn ", $workDBURI, " to :" ,$relatedWork),"info"))
};

(: this work is the 7xx work, so it is not primarycontribution etc:)
declare function bibs2mets:link2relateds($bfwork,$lccn, $workDBURI, $contributions) {

(: this one is on the related bf:Work :)
	
	(: don't match if there is no contributor ? 
	and don't if it's an 880 :)
	
	let $blank-node-uri:=fn:string($bfwork/@rdf:about)
		(: we now do a search on +primary contrib,+nonsorttitle  or firstcontrib +title or second contrib + title:)
(: why does there have to be a contrib? nate removed 2019-02-07 
	let $romanizedcontrib:=for $agent at $x in $bfwork/bf:contribution/bf:Contribution/bf:agent/bf:Agent[1]/bflc:*[fn:matches(fn:local-name(),"^name[0-9]{2}MarcKey$")]
									return if (fn:starts-with(fn:string($agent),"880")) then 0 else 1
	let $romanizedcontrib:=if (exists(index-of($romanizedcontrib, 1))) then fn:true() else fn:false()
:)
(:
	when linking 7xxs to existing works, you can include work stubs 
	(???? unlike when merging; those must exclude stubs ???) 
	2019-02-12: merge to for a hub even with stubs; this might be the work you've been looking for
:)
	let $matching :=
		if (
			(
			 $bfwork/bf:title[1]/bf:Title[1]/bflc:*[fn:matches(fn:local-name(),"^title[0-9]{2}MatchKey$")] !='' or 
			 $bfwork/bf:title[1]/bf:Title[fn:not(rdf:type)] or
			 $bfwork/bf:hasInstance/bf:Instance/bf:title[1]/bf:Title[1]/rdfs:label
			)
			(: why does there have to be a contrib? nate removed 2019-02-07
			and $romanizedcontrib
			:)
				(:   multiple auth contributors makes this too hard to check in the if; maybe build it in below
				and fn:not(fn:starts-with($bfwork/bf:contribution/bf:Contribution/bf:agent/bf:Agent[1]/bflc:*[fn:matches(fn:local-name(),"^name[0-9]{2}MarcKey$")],"880")
				) :)
			and
			fn:not(fn:contains( $blank-node-uri,"Work880"))

		   ) 
			 then	
	
				let $titlematchkey:= 		
		            for $t in $bfwork/bf:title[1]/bf:Title[1]
							return if ($t/bflc:*[fn:matches(fn:local-name(),"^title[0-9]{2}MatchKey$")]) then
		                				 fn:string($t/bflc:*[fn:matches(fn:local-name(),"^title[0-9]{2}MatchKey$")][1])		
									else fn:string($t/rdfs:label) (: $a$b ... may not work weelllll   :)
				
				let $titlematchkey:=fn:replace($titlematchkey,"/$","")
        		
				(: 773 titles are on the instance! c020012424 :)
				let $titlematchkey:= if ($titlematchkey) then
											$titlematchkey
									 else fn:string($bfwork/bf:hasInstance/bf:Instance/bf:title[1]/bf:Title[1]/rdfs:label[1])
				let $nonsortTitle:=			 		
		            for $t in $bfwork/bf:title[1]/bf:Title[1]
							return $t/bflc:titleSortKey		                				 
				let $nonsortTitle:=fn:replace($nonsortTitle,"/$","")
				let $nonsortTitle:=if (fn:normalize-space($nonsortTitle)!='') then
										fn:normalize-space($nonsortTitle)
										else ()
				let $contributor:= 
                        for $contrib in $bfwork/bf:contribution/bf:Contribution[1]
						return        fn:string($contrib/bf:agent/bf:Agent[1][fn:not(fn:contains(@rdf:about, "Agent880"))]/bflc:*[fn:matches(fn:local-name(),'^name[0-9]{2}MatchKey$')][1])
				let $contributor:= if ($contributor) then 
									$contributor
								else
									for $contrib in $contributions/bf:Contribution[1]
                        				return        fn:string($contrib/bf:agent/bf:Agent[1][fn:not(fn:contains(@rdf:about, "Agent880"))]/bflc:*[fn:matches(fn:local-name(),'^name[0-9]{2}MatchKey$')][1])
			
			    let $nameTitle :=	    
			         if (exists($titlematchkey) or exists($contributor))  then
			                     concat($contributor[1]," ",$titlematchkey)
			         else ()
				let $nameTitle:=fn:replace($nameTitle,"\[from old catalog\]",""	)
				let $nameTitle:=fn:replace($nameTitle,"-","&#8212;"	)
				let $nameTitle2 :=	    
			         if ( exists($contributor[2]))  then
			                let $nt2:=   concat($contributor[2]," ",$titlematchkey)
							let $nt2:=fn:replace($nt2,"\[from old catalog\]",""	)
							let $nt2:=fn:replace($nt2,"-","&#8212;"	)
							return $nt2
			         else ()

				let $_:=xdmp:log(fn:concat("CORB BIB merge link2: for ",$workDBURI, " looking for namet1: ",$nameTitle, "namet2:",$nameTitle2),"info")

				let $nonsortNameTitle:=
				    if ($nonsortTitle and $titlematchkey !=  $nonsortTitle ) then
                        fn:concat(fn:string($contributor[1]), " ",$nonsortTitle)                       
                     else ()
                let $nonsortNameTitle:=fn:replace($nonsortNameTitle,"\[from old catalog\]",""	)                     
				(: escape any hyphens :)				
				let $nonsortNameTitle:=fn:replace($nonsortNameTitle,"-","&#8212;"	)                     
				
				let $inner-query:= if ($nonsortNameTitle!=''  and $nameTitle2!='')		then
  									cts:or-query((
														cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "nameTitle"), xs:string($nonsortNameTitle), ("unstemmed", "case-insensitive", "punctuation-insensitive", "diacritic-insensitive"), 15) ,
                            							cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "nameTitle"), xs:string($nameTitle), ("unstemmed", "case-insensitive", "punctuation-insensitive", "diacritic-insensitive"), 15) ,
														cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "nameTitle"), xs:string($nameTitle2), ("unstemmed", "case-insensitive", "punctuation-insensitive", "diacritic-insensitive"), 15)
                                            ))
									else if ($nonsortNameTitle!='' )		then
												cts:or-query((
														cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "nameTitle"), xs:string($nonsortNameTitle), ("unstemmed", "case-insensitive", "punctuation-insensitive", "diacritic-insensitive"), 15) ,
                                 						cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "nameTitle"), xs:string($nameTitle), ("unstemmed", "case-insensitive", "punctuation-insensitive", "diacritic-insensitive"), 15) 																		
            		                                ))
									else if ($nameTitle2!='' )		then
											cts:or-query((
														cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "nameTitle"), xs:string($nameTitle), ("unstemmed", "case-insensitive", "punctuation-insensitive", "diacritic-insensitive"), 15) ,
                                 						cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "nameTitle"), xs:string($nameTitle2), ("unstemmed", "case-insensitive", "punctuation-insensitive", "diacritic-insensitive"), 15) 																	
            		                                ))
									else
											cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "nameTitle"), xs:string($nameTitle), ("unstemmed", "case-insensitive", "punctuation-insensitive", "diacritic-insensitive"), 15) 
				
				let $search :=  
					 if (fn:normalize-space($nameTitle)!="" 
					 		and fn:not(fn:contains($nameTitle,"Untitled") ) 
					 		and fn:not(fn:matches($nameTitle,"NO CAPTION") ) 
					 		and fn:not(fn:matches($nameTitle,"^Annual Report$") ) 
					 ) then
							"try to link"
						else
							"skip link"	           		       
	        			(: if nonsortnametitle is different from nametitle, perform an OR search for it :)
	        	let $result:= if ($search = "try to link" ) then 
								let $searchcode:= 
								    
										 cts:and-not-query(    										
						                            cts:and-query(( 
						                                			cts:collection-query("/resources/works/"),
														            cts:collection-query("/bibframe/hubworks/"),
																	cts:collection-query("/catalog/"),
						            		  						$inner-query											                                              
						            		        ))                                   
													,
										 		cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "uri"),$workDBURI)
										 )		
										 							
									return
										   cts:search( fn:doc(), $searchcode,
				 							(cts:index-order(cts:element-reference(fn:QName("info:lc/xq-modules/lcindex", "materialGroup") ) ,("descending")))
				                  			)[1 to 5]
                  			 else ()
			
			let $found:= if (  $result) then 
								$result[1]							
								else
									 ()
			
	   		return		 (:as  $matching:)
				( $found,
					 if ($found) then  					 							
						fn:string($found//@OBJID)						
					 else ()
			    )		
    		
		else (: didn't  even look for found match :)
			( $bfwork, "didn't look"	)

	let $found-uri :=
			if  ($matching[2] = "didn't look") then
				$matching[2]
			else if ($matching[2] and (fn:not($matching[2] = $workDBURI) ) ) then 
						fn:replace($matching[2],"loc.natlib.works.","")
				 else ()

		(:returns either a string for the uri or "didn't look" or nothing :)	
	
	return if ($found-uri and $found-uri != "didn't look" ) then
				(fn:concat($BASE-URI,$found-uri) ,
				xdmp:log(fn:concat("CORB BIB merge: linking ", $workDBURI, " to :" ,$found-uri),"info")
				)
			else if ($found-uri and $found-uri = "didn't look" ) then
				$found-uri
		 	else ()
(:returns either a string for the uri or "didn't look" or nothing:)

};


(:
: bfraw is a whole package (work+instances, starting at rdf:RDF
: stubs ok
:  exclude photos and bad titles
: this is the main function, called by corb-bibframe-process-bib-files.xqy
: matches found here will build a hub if necessary; 7xx and other searches do not need to mess with that
:)
declare function bibs2mets:get-work($bfraw, $workDBURI, $paddedID, $BIBURI, $mxe, $collections, $destination-uri)
{

    let $bfraw-work := $bfraw/bf:Work
    	(: only match if there's a 240/130 matchable node :)
					
	let $rdftype:=fn:string($bfraw-work/rdf:type[1]/@rdf:resource)

	let $matching :=
		if (
			($bfraw-work/bf:title[1]/bf:Title[1]/bflc:*[fn:matches(fn:local-name(),"^title[0-9]{2}MatchKey$")] !=''		or 
			$bfraw-work/bf:title[1]/bf:Title[fn:not(rdf:type)] ) and 
			($rdftype!="http://id.loc.gov/ontologies/bibframe/StillImage" or not($rdftype)
		   ) 
			 then	
			 
				let $titlematchkey:= 		
		            for $t in $bfraw-work/bf:title[1]/bf:Title[1]
							return if ($t/bflc:*[fn:matches(fn:local-name(),"^title[0-9]{2}MatchKey$")]) then
		                				 fn:string($t/bflc:*[fn:matches(fn:local-name(),"^title[0-9]{2}MatchKey$")][1])		
									else fn:string($t/rdfs:label) (: $a$b ... may not work weelllll   :)
				
				let $titlematchkey:=fn:replace($titlematchkey,"/$","")
				let $nonsortTitle:=			 		
		            for $t in $bfraw-work/bf:title[1]/bf:Title[1]
							return $t/bflc:titleSortKey		                				 
				let $nonsortTitle:=fn:replace($nonsortTitle,"/$","")
				
				let $primarycontrib:= 
                        for $contrib in $bfraw-work/bf:contribution/bf:Contribution[rdf:type/@rdf:resource="http://id.loc.gov/ontologies/bflc/PrimaryContribution"][fn:not(fn:contains(bf:agent/bf:Agent[1]/@rdf:about, "Agent880"))]
                        return        fn:string($contrib/bf:agent/bf:Agent[1][fn:not(fn:contains(@rdf:about, "Agent880"))]/bflc:*[fn:starts-with(fn:local-name(),'primaryContributorName')][1])
	
			    let $nameTitle :=	    
			         if (exists($titlematchkey) or exists($primarycontrib))  then
			                     concat($primarycontrib[1]," ",$titlematchkey)
			         else ()
				let $nameTitle:=fn:replace($nameTitle,"\[from old catalog\]",""	)
				let $nonsortNameTitle:=
				    if ($titlematchkey !=  $nonsortTitle ) then
                        fn:concat(fn:string($primarycontrib[1]), " ",$nonsortTitle)                       
                     else ()
                let $nonsortNameTitle:=fn:replace($nonsortNameTitle,"\[from old catalog\]",""	)                     
	
	
				let $search :=  
					 if ($nameTitle!="" and fn:not(fn:contains($nameTitle,"Untitled") )	
					 				    and fn:not(fn:matches($nameTitle,"NO CAPTION") ) ) then
							"try to merge"
						else 
							"skip merge"	           		       
	        	
				(: if nonsortnametitle is different from nametitle, perform an OR search for it :)
	        	
				let $found:= if ($search = "try to merge" ) then 
								let $searchcode:= 
								    if ($nonsortNameTitle!="" and fn:string-length($nonsortNameTitle) > 1 ) then
																				
										 cts:and-not-query(
    										cts:and-not-query(
						                            cts:and-query(( 
						                                	cts:collection-query("/resources/works/"),
															cts:collection-query("/bibframe/hubworks/"),
														    cts:collection-query("/catalog/"),
						            		                cts:or-query((
																	cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "nameTitle"), xs:string($nonsortNameTitle), ("unstemmed", "case-insensitive", "punctuation-insensitive", "diacritic-insensitive"), 15) ,
                                            cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "nameTitle"), xs:string($nameTitle), ("unstemmed", "case-insensitive", "punctuation-insensitive", "diacritic-insensitive"), 15)
                                            ))
                                            
			            		        ))
                                    	,		
						            		        cts:collection-query("/bibframe/stubworks/")
						            		        )
													,
										 cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "token"),$paddedID)
									)
									
								else
								   cts:and-not-query(										
						                            cts:and-query(( 
						                                cts:collection-query("/resources/works/"),
														cts:collection-query("/bibframe/hubworks/"),
														cts:collection-query("/catalog/"),
						            		            cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "nameTitle"), xs:string($nameTitle), ("unstemmed", "case-insensitive", "punctuation-insensitive", "diacritic-insensitive"), 15)            		            
						            		        ))
													
													,
										 cts:element-value-query(fn:QName("info:lc/xq-modules/lcindex", "token"),$paddedID)
									)
																											
       	               			return
										   cts:search( fn:doc(), $searchcode,
				 							(cts:index-order(cts:element-reference(fn:QName("info:lc/xq-modules/lcindex", "materialGroup") ) ,("descending")))
				                  			)[1 to 10]
                  			 else () (: not "try to merge" :)
				
				let $found:= if (  $found ) then
								$found[1]								
							else ()


	   		return ( $found,
				
					 if ($found) then  
					 	(:cts:uris((),(), $search)[1] :)
						fn:base-uri($found)
					 else ()
					 )		
    		
		else (: didn't  even look for found match :)
			()
	
	(: $matching contains [1]: mets doc and [2]:objid , or nothing :)
	
	let $found-mets:= if ($matching and (fn:not( fn:string( $matching[1]//@OBJID) =$workDBURI)) ) then $matching[1] else ()
	let $found-uri := if ($matching and (fn:not( fn:string( $matching[1]//@OBJID) =$workDBURI)) ) then $matching[2] else ()
	
(: for  certain types, an exact match is still an expression; should this just be the normal hub operation for all now? 
	So in addition to adding an expressionOf link we have to build a hub, assign it a uri, and point both works to it.
:)
let $link-expression:=($rdftype!="" and fn:contains(fn:string-join($LINK-EXPRESSIONS," "),$rdftype)  )
	(:let $_:=xdmp:log(fn:concat("CORB BIB merge: rdftype: ", $rdftype, " link-expression :" ,$link-expression),"info"):)



let $found-rdftype:=if ($found-mets) then
						for $t in $found-mets//mets:dmdSec[@ID="bibframe"]//bf:Work/rdf:type 
							return fn:string($t/@rdf:resource)
					else ()

(: if (index-of($found-rdftype,"http://id.loc.gov/ontologies/lclocal/Hub" ) ) then
					"just link"  add bf:expressionOf found-mets//bf:work to $bfraw-work
					else found psuedo hub, need to shuffle
						a) make a new work from found-mets//work with HUB rdftype
							uri is md5 of name/title
							(if doc-exists, add something)
						b) add bf:expressionOf md5 to $bfraw-work
						c) add bf:expressionOf md5 to $found-mets//work (xdmp:node-insert?)
						d) remove collection /bibframe/hubworks/ from found-mets

:)

let $create-hub:= if (index-of($found-rdftype,"http://id.loc.gov/ontologies/lclocal/Hub" ) ) then
						"just link" 
					else if ( $found-mets) then
						"create hub"
					else ()

let $hub-uri:= if ($create-hub="create hub") then
						bibs2mets:create-hub($found-mets,$collections, $nameTitle)	
					else	
						() 

let $expressionOfURI:= if ($found-mets  and $create-hub="just link") then
				let $objid:=fn:string( $found-mets/mets:mets/@OBJID)
				let $objid:=fn:tokenize($objid,"\.")[fn:last()]
								
							return fn:concat($BASE-URI,$objid)
						else 		if ($found-mets  and $create-hub="create hub") then					
							()


let $work := (: if found :)
		if ( 	( $found-mets and $link-expression ) or
				$create-hub ="just link" ) then
				(: link expression, don't merge work :)
				
				(:let $expressionOfURI:= fn:string( $found-mets/mets:mets/@OBJID)
				let $expressionOfURI:=fn:tokenize($expressionOfURI,"\.")[fn:last()]
				let $_:=xdmp:log(fn:concat("CORB BIB merge: expression instead of linking ", $workDBURI, " to :" ,$expressionOfURI),"info")
				let $expressionOfURI:=fn:concat($BASE-URI,$expressionOfURI) 
						 return:)
						  element bf:Work {
						                    $bfraw-work/@*,
						                    $bfraw-work/*,											
											 element bf:expressionOf {attribute rdf:resource {$expressionOfURI} }															 
				                	}
		else	if ($found-mets) then		   
			let $w := 
					 $found-mets/mets:mets/mets:dmdSec[@ID="bibframe"]/mets:mdWrap/mets:xmlData/rdf:RDF/child::bf:Work[1]

            let $subjects-new :=
                for $s in $bfraw-work/bf:subject
                let $sLabel := xs:string($s/bf:*[1]/madsrdf:authoritativeLabel)
				let $found-subject:= for $stored-subject in  $w/bf:subject/child::*/madsrdf:authoritativeLabel
											return if (fn:string($stored-subject)=$sLabel) then "y" else ()
                return
				if ( $found-subject) then
	                        ()	                   
						else
	                        $s
                   
            let $classes-new := (: no rdf:about in bf2 yet :)
              
                for $c in $bfraw-work/*[self::* instance of element (bf:classification)]
	                (:let $cAbout := fn:concat(fn:string($c/@rdf:resource),fn:string($c/bf:*[1]/@rdf:about))				:)
					let $cLabel:= fn:string( $c )
					let $found-class:= for $stored-class in  $w/bf:*[fn:starts-with(fn:local-name(),"classification")]
											return if (fn:string($stored-class) = $cLabel ) then "y" else ()

	                return
						if ( $found-class) then
	                        ()	                   
						else
	                        $c  
			
			let $consolidates := if (fn:not($w//bflc:consolidates) or fn:not($w//bflc:consolidates[fn:string(@rdf:resource)=fn:concat("http://id.loc.gov/resources/bibs/", $BIBURI)] ) or
									 fn:not($w//lclocal:consolidates) or fn:not($w//lclocal:consolidates[fn:string(@rdf:resource)=fn:concat("http://id.loc.gov/resources/bibs/", $BIBURI)] )		
									) then
					                element lclocal:consolidates {
					                    attribute rdf:resource { fn:concat("http://id.loc.gov/resources/bibs/", fn:replace($BIBURI,"^0+","") ) }
					                }
 							else ()
			    
				(: move adminMetadata to instances :) 
				                       
            return  (: doesn't include hasInstance to the merged instances... put in sem?   :)
                element bf:Work {
		                    $w/@*,
		                    $w/*,
		                    $subjects-new,
		                    $classes-new     ,
							$consolidates              
                	}
				
        else (: $found-mets is false, work as converted by bib xslt conversion, rdf:RDF is top! nothing matched, so this is a pseudo hub (not a real hub until something matches :)
			<rdf:RDF>
					<bf:Work rdf:about="{$bfraw-work/rdf:RDF/bf:Work/@rdf:about}">
							<!--<rdf:type rdf:resource="http://id.loc.gov/ontologies/lclocal/Hub"/>-->
							{$bfraw-work/rdf:RDF/bf:Work/* }
					</bf:Work>
			</rdf:RDF>
            

	 let $adminMeta-for-instance:= $bfraw-work/bf:adminMetadata[1]
     						
	let $workDBURI := 
        if ($found-mets and $work/@rdf:about ne $bfraw-work/@rdf:about ) then			 
			 fn:string($found-mets/mets:mets/@OBJID)         					
        else
            $workDBURI
	
	
	let $lccn:="" (: in normal bibs2mets, don't change the uri to the lccn number . IBC is also for  the editor only:)
	let $ibc:=""
	
    let $instances := bibs2mets:get-instances($bfraw,$workDBURI,$paddedID, <mxe:record/>, $adminMeta-for-instance, $lccn, $ibc)
	
	(:let $items := bibs2mets:get-items($bfraw,$workDBURI, $work//bflc:consolidates[1], $paddedID, <mxe:record/>):)

(: new nate adds links to found expressionOfs.
c014571916 should be related to n82013164
:)
   let $newlylinkedExpressionOfs:=  
		if ($found-mets) then
			$work/bf:relatedTo[@rdf:resource=$expressionOfURI ]
		else ()

	 (: if  ($bfraw/bf:Work/*[fn:not(self::* instance of element (bf:subject))]/bf:Work) then
                           	 for $relation at $x in $bfraw-work/*[fn:not(self::* instance of element (bf:subject))][bf:Work]
								return
										element {xs:QName(fn:name($relation))} {attribute rdf:resource {
											fn:concat("http://id.loc.gov/resources/works/",$paddedID,format-number($x,"0000"))
										}
										}
								else ()
		:)	
(: search for language expression (translation) if not merging :)

let $title-lang:=if (fn:not($found-mets)) then
					(: 130 240 $l:)			
						fn:substring-after($work/bf:title[1]/bf:Title[1]/*[self::* instance of element(bflc:title30MarcKey) or self::* instance of element(bflc:title40MarcKey) ] ,"$l")
					else ()
					
let $translation-link:= if ($title-lang!="") then											
							auth2bf:link2translations($work,"", $title-lang,$workDBURI) 							 
						else ()
						  
let $distinct-translations:=auth2bf:dedup-links($work,"bf:translationOf", $translation-link)
             
let $distinct-relateds:= if (fn:not($found-mets)) then
					    	    for $node-code in ("\$f","\$h","\$k","\$m","\$n","\$o","\$p","\$r","\$s") 
					               return 
					                let $node-parts:=fn:tokenize(fn:string($work/bf:title[1]/bf:Title[1]/*[self::* instance of element(bflc:title00MarcKey) or self::* instance of element(bflc:title10MarcKey) or self::* instance of element(bflc:title11MarcKey) or self::* instance of element(bflc:title30MarcKey) or self::* instance of element(bflc:title40MarcKey)]),$node-code)[2]
								   	
					                for $node-text at $x in  $node-parts

									(: node text is the string to ignore, ie., $s: "vocal score":)
							
									
					                            let $node-link:=auth2bf:link2translations($work,$lccn, $node-text, $workDBURI)
											      return 
													auth2bf:dedup-links($work,"bf:relatedTo", $node-link)					                                  
					                        
					       else () 

let $related-7xxs:=if  ($bfraw-work/*[fn:not(self::* instance of element (bf:subject))]/bf:Work) then
						let $contributions:=$work//bf:contribution[bf:Contribution/bf:agent/bf:Agent[fn:not(fn:contains(fn:string(@rdf:about),"#Agent880"))]]
						return
						<related-7xxs>{
						for $w in $bfraw-work/*[fn:not(self::* instance of element (bf:subject))]/bf:Work
							
							(: 20180918 sparql query needs work; too slow; maybe lccn substitution issue?? :)
	
							let $link:= if ($w/bf:identifiedBy/bf:Identifier[fn:string(bf:source/bf:Source/rdfs:label)="DLC"]) then
													let $lccn:= for $l in $w/bf:identifiedBy/bf:Identifier[1][fn:string(bf:source/bf:Source/rdfs:label)="DLC"]
														return	if (fn:matches($l/bf:status/bf:Status/rdfs:label,"invalid","i" )) then
															()
															else fn:string($l/rdf:value)
												let $lccn:= fn:normalize-space($lccn[1])

												return if (fn:string-length($lccn ) >4 ) then												
												 			bibs2mets:link-via-lccn2($lccn, $workDBURI)
												
														else ()
										else
												bibs2mets:link2relateds($w, "",$workDBURI, $contributions) 							

									

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
						 	auth2bf:dedup-links($work,$linkset/name,$linkset/link)							 							
						else
							(:  blank nodes will be inserted as stubs  :)
							 $linkset
							
				}</wrap>		
	let $sevenxx-properties:= fn:distinct-values(for $node in $related-7xxs/child::* return fn:name($node))

let $subject-works:=
		if ($bfraw-work/*[self::* instance of element (bf:subject)]/bf:Work)  then 
				for $w in 	$bfraw-work/*[self::* instance of element (bf:subject)]/bf:Work
                 return  bibs2mets:link-subject-works($w)
		else ()

(: add stubs before deleting relatedto's :)
let $relateds:= 
				if  ($related-7xxs/*/bf:Work[fn:not(fn:contains( fn:string(@rdf:about),"Work880"))	]) then							

						let $rels:=		<rdf:RDF><bf:Work>{
												for $rel in $related-7xxs/*[bf:Work[fn:not(fn:contains( fn:string(@rdf:about),"Work880"))]]
												return  $rel
	    									}</bf:Work></rdf:RDF>		
				
							return bibs2mets:insert-work-stubs($rels,$workDBURI, $paddedID, $BIBURI, $destination-uri)							                             
					else  ()
	
let $work:= if ( $distinct-translations or $distinct-relateds or $related-7xxs) then
						<bf:Work>{
							$work/@rdf:about,
							$work/*[fn:not(index-of($sevenxx-properties,fn:name(.)))],
							
							(:$work/*[self::* instance of element (bf:translationOf) or self::* instance of element (bf:relatedTo) or self::* instance of element (bf:hasPart) )],:)
							(: keep relateds that are blank nodes :)							
							$distinct-translations,
							$distinct-relateds,
							$related-7xxs/*
							}
          				</bf:Work>
				else
					 $work
	
	let $resclean:=fn:substring-after($workDBURI,"works.")
	let $destination-uri:= (:store doc under old id:)
			if (fn:not($found-mets)   or $link-expression) then 
				$destination-uri				
			else (: store doc under found id:)
				$found-uri	
	let $rdfabout:= 
			if (fn:not($found-mets) or $link-expression) then 
				attribute rdf:about {fn:concat($BASE-URI, $resclean)}
			else 
				$work/@rdf:about 

    let $work := 
        element {fn:name($work)} { $rdfabout,
            $work/@*[fn:not(fn:name()='rdf:about')],
           	$work/*[fn:not(self::* instance of element(bf:hasInstance))]           ,			
			$newlylinkedExpressionOfs
        }
    
    let $work :=  element rdf:RDF { $work } 
            	
	let $work-sem := bf4ts:bf4ts(  $work   )
	
	let $mxe:= if ($found-mets) then	
					$found-mets/mets:mets/mets:dmdSec[@ID="mxe"]/mets:mdWrap/mets:xmlData/*
			    else
					 <mxe:empty-record/>


	let $work-bfindex :=  
					   try {
					       			bibframe2index:bibframe2index( $work ,  <mxe:empty-record/> )
									

					   } catch($e){
					             (<index:index/>,
								 	( 	$e, "info"),
								 	xdmp:log(fn:concat("CORB BFE/BIB indexing error  for ",fn:tokenize($destination-uri,"/")[fn:last()]), "info")
								 )
					   }
    let $work-mets := 
        <mets:mets 
            PROFILE="workRecord" 
            OBJID="{$workDBURI}" 
            xsi:schemaLocation="http://www.loc.gov/METS/ http://www.loc.gov/standards/mets/mets.xsd" 
            xmlns:mets	="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink" 
            xmlns:rdfs  = "http://www.w3.org/2000/01/rdf-schema#"			
			xmlns:rdf   = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:bf	="http://id.loc.gov/ontologies/bibframe/" 
			xmlns:bflc	="http://id.loc.gov/ontologies/bflc/" 
			xmlns:lclocal="http://id.loc.gov/ontologies/lclocal/"
        	xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#" 
			xmlns:relators      = "http://id.loc.gov/vocabulary/relators/"            
			xmlns:idx="info:lc/xq-modules/lcindex"
            xmlns:index="info:lc/xq-modules/lcindex">
            <mets:metsHdr LASTMODDATE="{fn:current-dateTime()}"/>
            <mets:dmdSec ID="bibframe">
                <mets:mdWrap MDTYPE="OTHER">
                    <mets:xmlData>
                        {$work}
                    </mets:xmlData>
                </mets:mdWrap>
            </mets:dmdSec>	
            <mets:dmdSec ID="mxe">
                <mets:mdWrap MDTYPE="OTHER">
                    <mets:xmlData>
                        {$mxe}
                    </mets:xmlData>
                </mets:mdWrap>
            </mets:dmdSec>
			<mets:dmdSec ID="semtriples">
                <mets:mdWrap MDTYPE="OTHER">
                    <mets:xmlData>
                        {$work-sem}
                    </mets:xmlData>
                </mets:mdWrap>
            </mets:dmdSec>
            <mets:dmdSec ID="index">
                <mets:mdWrap MDTYPE="OTHER">
                    <mets:xmlData>
                       { $work-bfindex  	}
                    </mets:xmlData>
                </mets:mdWrap>
            </mets:dmdSec>
            <mets:structMap>
                <mets:div TYPE="workRecord" DMDID="bibframe mxe semtriples index"/>
            </mets:structMap>
        </mets:mets>
		(: think about this nate; hubworks if found AND if not found?  If not found, it stands alone and could be a hub; if found, the hub is the other one
		different    ?????
   	:)
    let $work-collections :=
		 if ( $found-mets and $link-expression  ) then 
		 	("/resources/works/","/bibframe/convertedBibs/","/bibframe/relatedTo/")
		 else if ($found-mets) then
        	    ("/resources/works/","/bibframe/convertedBibs/","/bibframe/consolidatedBibs/")
          else (: psuedo hub for future matching:)
          		("/resources/works/","/bibframe/","/bibframe/convertedBibs/","/bibframe/notMerged/","/bibframe/hubworks/")
	let $work-collections:=if ($translation-link)  then								
								($work-collections,"/resources/expressions/")
							else 
								$work-collections
	let $work-collections:= if  ($bfraw-work/*[fn:not(self::* instance of element (bf:subject))]/bf:Work) then
									($work-collections,"/bibframe/had7xx/") (: used to find bad instances? 2018-07-26:)
								else 
									$work-collections
    let $work-collections:=  if ( $distinct-translations or $distinct-relateds or $related-7xxs) then
									($work-collections,"/bibframe/relatedTo/") (: used to see if reloaded and checked for links :)
								else 
									$work-collections

	let $work-collections:= ($work-collections,$collections)
    let $quality :=()

    let $forests:=()
	let $insert-work := 
		(: if ( $OVERWRITE !="replace" and fn:doc-available($destination-uri)  and xdmp:document-get-collections($destination-uri)="/bibframe/editor/")  then:)
		 if (fn:doc-available($destination-uri)  and xdmp:document-get-collections($destination-uri)="/bibframe/editor/")  then
				xdmp:log(fn:concat("CORB BIB merge: skipping loading work doc - edited  : ",$workDBURI, " from bib doc : ",$BIBURI )   , "info")
			else
       
		 (
		 	try {
			(	
					xdmp:lock-for-update($destination-uri),
					xdmp:document-insert(
                						 $destination-uri, (: not $workdburi:)
                 						 $work-mets,
						                (
						                    xdmp:permission("id-user-role", "read"), 
						                    xdmp:permission("id-admin-role", "update"),
						                    xdmp:permission("id-admin-role", "insert")
						                ),
						        		$work-collections, $quality, $forests
						            )		
				)         
        }
             catch ($e) { xdmp:log(fn:concat("CORB BIB merge: work not loaded error on : ", $workDBURI, "; $paddedID for instances merged= ",$paddedID,". ","destination:",fn:tokenize($destination-uri,"/")[fn:last()],  fn:string( $e/mlerror:code))    , "info")
        }
        , if (fn:contains($workDBURI,$BIBURI)) then 
				xdmp:log(fn:concat("CORB BIB merge: loaded bib work doc : ",$workDBURI, " from bib doc : ",$BIBURI," to : ",fn:tokenize($destination-uri,"/")[fn:last()] )   , "info")
			else			
				xdmp:log(fn:concat("CORB BIB merge: merged onto work doc : ",$workDBURI, " from bib doc : ",$BIBURI )  , "info")
        )

	(:let $instance-collections := ( "/lscoll/lcdb/", "/lscoll/","/catalog/", "/catalog/lscoll/", "/catalog/lscoll/lcdb/", "/catalog/lscoll/lcdb/bib/")	:)	
    let $instance-collections := ($BASE_COLLECTIONS,"/resources/instances/","/bibframe/","/bibframe/convertedBibs/", "/lscoll/lcdb/instances/")     
	let $instance-collections:= if ($found-mets and fn:matches($workDBURI,"works.n")) then 
									($instance-collections, "/bibframe/mergedtoAuthWork/","/bibframe/mergedInstances/")
	                           else	if ($found-mets and fn:matches($workDBURI,"works.e")) then 
									($instance-collections, "/bibframe/mergedtoEditedWork/","/bibframe/mergedInstances/")
	                            else if ($found-mets) then 
									($instance-collections, ("/bibframe/mergedInstances/","/bibframe/mergedtoBibWork/"))
								else
									($instance-collections,("/bibframe/notMerged/"))

	let $instance-collections:=($instance-collections, $collections)
  (: this generates 58 hasitem links! http://mlvlp04.loc.gov:8230/resources/instances/c0112880890003 :)
    
	let $insert-instances :=
        for $i in $instances (: instances are mets:mets nodes:)
			(:-------------------------from ingest-voyager-bib  -------------------------:)
			let $bibid := fn:tokenize( xs:string($i/@OBJID), "\.")[fn:last()]
			
			(: loc.natlib.instance.c0001000000001 
				http://id.loc.gov/resources/instances/c0001000000001":)
			(:let $bibid:= fn:tokenize($i/rdf:RDF/bf:Instance/@rdf:about,"/")[fn:last()]:)
			
			let $resclean := fn:substring($bibid,1,10)
			let $dirtox := bibs2mets:chars-001($resclean)
			let $destination-root := "/lscoll/lcdb/instances/"
		    let $dir := fn:concat($destination-root, string-join($dirtox, '/'), '/')
		    let $destination-uri := fn:concat($dir, $bibid,'.xml')    
			(:-------------------------from ingest-voyager-bib  -------------------------:)

	        return
	          if (fn:doc-available($destination-uri)  and xdmp:document-get-collections($destination-uri)="/bibframe/editor/" ) then				
				xdmp:log(fn:concat("CORB BIB merge: skipping loading instance doc - edited : ", xs:string($i/@OBJID), " from bib doc : ",$BIBURI , " to : ",fn:tokenize($destination-uri,"/")[fn:last()]  )   , "info")
			else
				
				try{	(xdmp:lock-for-update($destination-uri),
				 		xdmp:document-insert(
	         				   $destination-uri (:not  xs:string($i/@OBJID) :), 
	            				$i,
					            (
					                xdmp:permission("id-user-role", "read"), 
					                xdmp:permission("id-admin-role", "update"),
					                xdmp:permission("id-admin-role", "insert")
					            ),
								$instance-collections, $quality, $forests			
	        				)
							,
							xdmp:log(fn:concat("CORB BIB merge: loaded instance doc : ", xs:string($i/@OBJID), " from bib doc : ",$BIBURI , " to : ",fn:tokenize($destination-uri,"/")[fn:last()]  )   , "info")
						)
					}
				catch ($e) {xdmp:log(fn:concat("CORB BIB merge: failed to load instance doc : ", xs:string($i/@OBJID), " from bib doc : ",$BIBURI , " to : "
				 				,fn:tokenize($destination-uri,"/")[fn:last()] )   , "info")
				 }			
		(: items now generated per instance, not overall (2019-01-03) so comment this out: :)	
	(:
			let $item-collections := ( "/lscoll/lcdb/", "/lscoll/","/catalog/", "/catalog/lscoll/", "/catalog/lscoll/lcdb/", "/catalog/lscoll/lcdb/bib/")		
			let $item-collections := ($item-collections, "/resources/items/"  , "/bibframe","/bibframe/convertedBibs/",  "/lscoll/lcdb/items/")      
			let $item-collections:=($item-collections, $collections)
    
			let $insert-items := 
	
		        for $i in $items
					(:-------------------------from ingest-voyager-bib  -------------------------:)
					let $bibid := fn:tokenize( xs:string($i/@OBJID), "\.")[fn:last()]				
					let $resclean := fn:substring($bibid,1,10)			
					let $dirtox := bibs2mets:chars-001($resclean)
					let $destination-root := "/lscoll/lcdb/items/"
				    let $dir := fn:concat($destination-root, string-join($dirtox, '/'), '/')
				    let $destination-uri := fn:concat($dir, $bibid, '.xml')
		   			(:-------------------------from ingest-voyager-bib  -------------------------:)

		        return
				if (fn:doc-available($destination-uri)  and xdmp:document-get-collections($destination-uri)="/bibframe/editor/" ) then								
						xdmp:log(fn:concat("CORB BIB merge: skipping loading item doc - edited : ", xs:string($i/@OBJID), " from bib doc : ", $BIBURI , " to : " ,fn:tokenize($destination-uri,"/")[fn:last()]   )   , "info")
					else
		           ( try {
				    xdmp:document-insert(
					           	$destination-uri ,
					            $i,
					            (
					                xdmp:permission("id-user-role", "read"), 
					                xdmp:permission("id-admin-role", "update"),
					                xdmp:permission("id-admin-role", "insert")
					            ),
								$item-collections, $quality, $forests			
		        		),
						xdmp:log(fn:concat("CORB BIB merge: loaded item doc : ", xs:string($i/@OBJID), " from bib doc : ", $BIBURI , " to : " ,fn:tokenize($destination-uri,"/")[fn:last()]   )   , "info")						
					}
					catch ($e) {xdmp:log(fn:concat("CORB BIB merge: failed to load item doc : ", xs:string($i/@OBJID), " from bib doc : ", $BIBURI , " to : " ,fn:tokenize($destination-uri,"/")[fn:last()] , fn:string($e//mlerror:message[1])  )   , "info")
								}
				)
	:)

    return 
        (   $workDBURI    )
    
};
 (: every subject/work may be a resource; go link to it... not started!!!! :)
 declare function bibs2mets:link-subject-works($subjects) {
()
 };

 (: nametitle md5: first time should be not found; 
 but if found add one of $ut-parts, in order, one at a time until doc not available;  establish that.:)
 declare function bibs2mets:create-hub($found-mets,$collections, $nameTitle)	{
 
 let $token:=xdmp:md5($nameTitle)
 let $dirtox := bibs2mets:chars-001($token)
 let $destination-root := "/lscoll/lcdb/work/"
 let $dir := fn:concat($destination-root, string-join($dirtox, '/'), '/')
 let $work-destination-uri := fn:concat($dir, $iID, '.xml')
if doc-available($work-destination-uri) then
	let $addons:=
	for $node in $ut-addons/node
		return	for $n in $work/child::*[self::* instance of element($node)][1] return ($n/text()|$n//rdfs:label[1])[1]
	() (:get-another(uri):)
	else 
		()(:insert this one:)
for $node in $ut-parts/text()
							
 let $work:=$found-mets/mets:dmdSec[@ID="bibframe"]//bf:Work
 let $hub-work:=
 <bf:Work>{$work/@rdf:about}
 			{$work/rdf:type[fn:not(fn:string(@rdf:resource="http://id.loc.gov/ontologies/lclocal/Hub"))]}
			{$work/bf:contribution}
			{$work/bf:title}
			
			{$work/bf:adminMetadata}
			
 </bf:Work>
 };
(: return instance mets docs for each bf:Instance in $bfraw:)

declare function bibs2mets:get-instances(
        $bfraw as element(rdf:RDF), 
        $workDBURI as xs:string, 
        $paddedID as xs:string,
		$mxe as element(),
		$adminMeta as element()?	,
		$lccn	,
		$ibc
    )
{
(: INSTANCES 
if workdburi and paddedID are null then the payload did not include a work, and instanceOf is already correct
adminmeta will be null bf:adminMetadata/
:)    
(:
if paddedid (work node) is not the same as lccn, maybe use lccn for the instance paddedid.if ibc=yes, then the intent is to update this instance with the lccn, so use it.
if ibc is no, leave it all
:)
	let $workuri-4-instance:=  
			if ($workDBURI!="") then								
				let $tmp-uri:= fn:concat("http://id.loc.gov/resources/works/", fn:replace($workDBURI, ".xml", ""))
				return fn:replace($tmp-uri, "loc.natlib.works.","")
			else ()	

let $_:=xdmp:log(fn:concat("CORB BFE/BIB workdburi for ", $workuri-4-instance," ", $ibc), "info")									

let $paddedID:=if ($ibc="yes" and $lccn!="" and  fn:not(fn:contains($paddedID, $lccn) ) ) then
						fn:concat("e", $lccn)
					else 
						$paddedID
(:let $_:=xdmp:log(fn:concat("CORB BFE/BIB $padded id ",$paddedID), "info")									:)

	let $adminMeta:=if ($adminMeta/*) then $adminMeta else ()
    (: Go through instances, create new id, create mets :)    
    let $instances := 
	(: some instances are in parts of a different work , skip :)
	(: this is way too inclusive: rdf/work/hasinstance/instance or rdf/instance only? :)
        
		
(: 2018-07-26 removed this overly inclusive one; need to check how editor reacts 
		for $i at $pos in $bfraw//bf:Instance[	parent::rdf:RDF or 
												(fn:not(ancestor::bf:Work/parent::bf:partOf) and 
													fn:not(parent::bflc:indexedIn)
												)]
												:)		
		for $i at $pos in $bfraw/self::rdf:RDF/bf:Instance|$bfraw/self::rdf:RDF/child::bf:Work[1]/bf:hasInstance/bf:Instance									 
			return 
			if ($i/parent::* instance of element(bf:hasSeries) ) then
				()
			else
				let $paddedID:= if ($paddedID="") then 
									fn:tokenize(fn:string($i/@rdf:about),"/")[fn:last()]
								else
									$paddedID
				
			    let $iID:=bibs2mets:get-padded-subnode($pos, $paddedID)
	       
		        let $instanceDBURI := fn:concat("loc.natlib.instances." , $iID )
		        let $instanceURI := fn:concat("http://id.loc.gov/resources/instances/", $iID)

	  	        let $instanceOf := 
						if  ($i/bf:instanceOf) then 
							if ($i/bf:instanceOf/bf:Work/@rdf:about) then
								element bf:instanceOf {
									attribute rdf:resource {
										fn:string($i/bf:instanceOf/bf:Work/@rdf:about) }
									}
							else if ($i/bf:instanceOf/child::*[1][fn:not(self::* instance of element(bf:Work))]/@rdf:about) then
								element bf:instanceOf {
									attribute rdf:resource {
										fn:string($i/bf:instanceOf/child::*[1]/@rdf:about) }
									}
							else if (fn:contains(fn:string($i/bf:instanceOf/@rdf:resource),"#Work")) then
								element bf:instanceOf {
						            attribute rdf:resource { $workuri-4-instance }
						        }
							else								 
								$i/bf:instanceOf
						else if ($workuri-4-instance) then
							        element bf:instanceOf {
							            attribute rdf:resource { $workuri-4-instance }
							        }
							else 
							()						
(:$i/bf:instanceOf may be a blank node work that needs to be replaced by the workuri-4-instance, see lccn 2018377860:)
let $instanceOf:=if ($instanceOf/@rdf:resource)  then
						$instanceOf
				else
						element bf:instanceOf {
						          attribute rdf:resource { $workuri-4-instance }
						  }

				let $itemURI := fn:concat("http://id.loc.gov/resources/items/", $iID)
		        (:

					for each hasItem, the number is relative to the Work!!!

				:)
				 (: only items with abouts ie not 010066190 :)
				(:let $hasItems:=
	        				if ($workDBURI="") then
								$i/bf:hasItem
							else 
								for $item in $i/bf:hasItem/bf:Item[@rdf:about]
									let $this-item-about:=fn:string($item/@rdf:about)							
										for $i at $itempos in $bfraw//bf:Item[@rdf:about]                   	
										
										 return 
										 	if ($i/@rdf:about!=$this-item-about) then
												()	
										  	else 
               
												let $itemID:= bibs2mets:get-padded-subnode($itempos, $paddedID)
												let $itemURI := fn:concat("http://id.loc.gov/resources/items/", $itemID)
              			
												return element bf:hasItem {attribute rdf:resource {$itemURI} }
				:)
	       	(: build mets for each item, calls insert-any mets to store :)
				let $items := bibs2mets:get-items-new($i,$workDBURI,  $paddedID,$pos )		
				
			
				let $instance-modified := 
	            	element bf:Instance {
	                	attribute rdf:about {$instanceURI},
	                
						$i/*[fn:local-name() ne "instanceOf" and fn:local-name()!="hasItem"],					
		                $instanceOf,						
						if ($i/bf:adminMetadata) then 
							()
						 else
							$adminMeta
	           	 }
				 (: consider "insert-any-mets" here :)
				let $instance-sem :=  
							try {
								bf4ts:bf4ts( element rdf:RDF { $instance-modified } )
							  }
							  catch($e){
			  							( 	<sem:triples/>,$e,
							 			xdmp:log(fn:concat("CORB BFE/BIB sem error  for ", $instanceURI), "info")									
							 		)
							  }
		        let $instance-index :=
				 	try {
	     				bibframe2index:bibframe2index( element rdf:RDF { $instance-modified }, $mxe )
					   } catch($e){
					             ( 	<index:index/>,
								 	xdmp:log(fn:concat("CORB BFE/BIB indexing error  for ", $instanceURI), "info")
								 )
					   }
		
		        let $instance-mets := 
	           	 <mets:mets 
	                PROFILE="instanceRecord" 
	                OBJID="{$instanceDBURI}" 
	                xsi:schemaLocation="http://www.loc.gov/METS/ http://www.loc.gov/standards/mets/mets.xsd" 
	                xmlns:mets	="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink" 
	                xmlns:rdf	="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
					xmlns:rdfs  = "http://www.w3.org/2000/01/rdf-schema#"						
					xmlns:bf	= "http://id.loc.gov/ontologies/bibframe/" 
					xmlns:bflc	= "http://id.loc.gov/ontologies/bflc/" 
					xmlns:lclocal="http://id.loc.gov/ontologies/lclocal/"
	                xmlns:madsrdf= "http://www.loc.gov/mads/rdf/v1#" 
	                xmlns:xsi	= "http://www.w3.org/2001/XMLSchema-instance" 
					xmlns:idx	= "info:lc/xq-modules/lcindex" 
	                xmlns:index = "info:lc/xq-modules/lcindex" >
	                <mets:metsHdr LASTMODDATE="{fn:current-dateTime()}"/>
	                <mets:dmdSec ID="bibframe">
	                    <mets:mdWrap MDTYPE="OTHER">
	                        <mets:xmlData>
	                            <rdf:RDF>
	                                {$instance-modified}
	                            </rdf:RDF>
	                        </mets:xmlData>
	                    </mets:mdWrap>
	                </mets:dmdSec>
					<mets:dmdSec ID="semtriples">
	                    <mets:mdWrap MDTYPE="OTHER">
	                        <mets:xmlData>
	                                    { $instance-sem}
	                        </mets:xmlData>
	                    </mets:mdWrap>
	                </mets:dmdSec>
	                <mets:dmdSec ID="index"><mets:mdWrap MDTYPE="OTHER">
	                        <mets:xmlData>{$instance-index}</mets:xmlData>
	                    </mets:mdWrap>
	                </mets:dmdSec>
	                <mets:structMap>
	                    <mets:div TYPE="instanceRecord" DMDID="bibframe semtriples index"/>
	                </mets:structMap>
	            </mets:mets>
            
        	return $instance-mets (:to $instances:)
            
    return $instances
    
};

(: only bfraw and padded id are used
: this version looked top down for items; new one looks only for embedded items in instances
:)
declare function bibs2mets:get-items(
        $bfraw as element(rdf:RDF), 
        $workDBURI as xs:string, 
		$consolidates as element()?,
        $paddedID as xs:string,
		$mxe as element()
		
    )
{
      
    (: Go through items, create new id, create mets
	each instance may have one or more items.
	items get id's relative to position in the whole doc
	 :)    
       
let $items := (: avoid related works with instances with specific xpath:)
      for $inst at $instancepos in $bfraw//bf:Instance
	  	
	  		for $item in $inst//bf:hasItem/bf:Item[@rdf:about or @rdf:nodeID] (: for each item  :)
				let $this-item-about:=($item/@rdf:about||$item/@rdf:nodeID)[1]
		
				(: get the item position relative to the RDF:RDF, not the instance :)
				
				 let $my-pos:=
		                for $i at $itempos in $bfraw//bf:Item[@rdf:about or @rdf:nodeID] 
		                  return (: not this item :)
		                    if ($i/@rdf:nodeID!=$this-item-about) then 
								()
							else if ($i/@rdf:about!=$this-item-about) then 
		                          ()
		                      else (: item found at this itempos :)
		                               $itempos
	           		(: caused duplication! thru 9/14/17 :)
					(: for $i at $itempos in $bfraw//bf:Item[@rdf:about] 
						return 
							if ($i/@rdf:about!=$this-item-about) then 
					 			()
					   	else 
					   :)
					   (: bug in conversion is allowing 856 to be converted twice with same uri, bibid c010063988; fix requested 9/14/17 , [1] prevents error:)
		                	let $iID:=bibs2mets:get-padded-subnode($my-pos[1], $paddedID)
		                	let $instanceID:=bibs2mets:get-padded-subnode($instancepos, $paddedID)
                
			                let $itemDBURI := fn:concat("loc.natlib.items." , $iID )
			                let $itemURI := fn:concat("http://id.loc.gov/resources/items/", $iID)
			          		let $derivedbib:= fn:replace($paddedID,"^c","")
			          		let $derivedbib:= fn:replace($derivedbib,"^0+","")
			          		 let $itemOf := 
			          	        element bflc:itemOf {          		           
			          				    attribute rdf:resource { fn:concat("http://id.loc.gov/resources/instances/", $instanceID ) }
			                  }
					
		             let $item-modified := 
		                 element bf:Item {
		                     attribute rdf:about {$itemURI},				
		                     $item/*[fn:local-name() ne "itemOf" and fn:local-name() ne "derivedFrom" ],
		     				element bflc:derivedFrom {attribute rdf:resource {fn:concat("http://id.loc.gov/resources/bibs/",$derivedbib)} },			
		                        $itemOf
		                 }
        			let $item-sem :=
						  try {
			   				  bf4ts:bf4ts( element rdf:RDF { $item-modified } )
					 
					 		} catch($e){	( (),
					     					xdmp:log(fn:concat("CORB BFE/BIB sem conversion error for ", $iID), "info")
											
										)
					 		}
			        let $item-index :=   try {
										 bibframe2index:bibframe2index( element rdf:RDF { $item-modified }, $mxe )
										 } catch($e){	( (),
										 xdmp:log(fn:concat("CORB BFE/BIB item index for ", $iID), "info")
										)
					 		}

			        let $item-mets := 
			            <mets:mets 
			                PROFILE="itemRecord" 
			                OBJID="{$itemDBURI}" 
			                xsi:schemaLocation="http://www.loc.gov/METS/ http://www.loc.gov/standards/mets/mets.xsd" 
			                xmlns:mets	="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink" 
			             	xmlns:rdf	="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
							xmlns:rdfs  = "http://www.w3.org/2000/01/rdf-schema#"						
							xmlns:bf	= "http://id.loc.gov/ontologies/bibframe/" 
							xmlns:bflc	= "http://id.loc.gov/ontologies/bflc/" 
							xmlns:lclocal="http://id.loc.gov/ontologies/lclocal/"
					        xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#" 
			                xmlns:xsi	= "http://www.w3.org/2001/XMLSchema-instance" 
							xmlns:idx	="info:lc/xq-modules/lcindex"
			                xmlns:index	="info:lc/xq-modules/lcindex">
			                <mets:metsHdr LASTMODDATE="{fn:current-dateTime()}"/>
			                <mets:dmdSec ID="bibframe">
			                    <mets:mdWrap MDTYPE="OTHER">
			                        <mets:xmlData>
			                            <rdf:RDF>
			                                {$item-modified}
			                            </rdf:RDF>
			                        </mets:xmlData>
			                    </mets:mdWrap>
			                </mets:dmdSec>
							<mets:dmdSec ID="semtriples">
			                    <mets:mdWrap MDTYPE="OTHER">
			                        <mets:xmlData>
			                            <rdf:RDF>
			                                {if ($item-sem) then $item-sem else <sem:triples/>}
			                            </rdf:RDF>
			                        </mets:xmlData>
			                    </mets:mdWrap>
			                </mets:dmdSec>
			                <mets:dmdSec ID="index">
			                    <mets:mdWrap MDTYPE="OTHER">
			                        <mets:xmlData>
			                           
										    {if ($item-index) then $item-index else <index:index/>}
			                        </mets:xmlData>
			                    </mets:mdWrap>
			                </mets:dmdSec>
			                <mets:structMap>
			                    <mets:div TYPE="itemRecord" DMDID="bibframe index"/>
			                </mets:structMap>
			            </mets:mets>
            
        return $item-mets
            
    return $items
    
};
(: only bfraw and padded id are used
: this version looked top down for items; new one looks only for embedded items in instances
:)
declare function bibs2mets:get-items-new(
        $instance as element(bf:Instance), 
        $workDBURI as xs:string, 		
        $paddedID as xs:string,
		$instance-pos 
	
    )
{
      
    (: Go through items, create new id, create mets
	each instance may have one or more items.
	items get id's relative to position in the whole doc
	 :)    
       (: nate continue here on renaming items with elccn number:)
	let $_:=xdmp:log(fn:concat("get-items new:", $paddedID, "|", $workDBURI),"info")
let $item-collections := ($BASE_COLLECTIONS, "/resources/items/"  , "/bibframe/","/bibframe/convertedBibs/",  "/lscoll/lcdb/items/")      
	
let $items :=       	  	
	  		for $item  at $item-pos in $instance//bf:hasItem/bf:Item[@rdf:about or @rdf:nodeID] (: for each item  :)
				let $this-item-about:=($item/@rdf:about||$item/@rdf:nodeID)[1]
		
				(: get the item position relative to the RDF:RDF, not the instance :)
				
				 					   
		                	(:let $iID:=bibs2mets:get-padded-subnode($my-pos[1], $paddedID):)
		                	
							let $instanceID:=bibs2mets:get-padded-subnode($instance-pos, $paddedID)
                			let $iID:=fn:concat($instanceID,"-",$item-pos)
			                
							let $itemDBURI := fn:concat("loc.natlib.items." , $iID )
			                let $itemURI := fn:concat("http://id.loc.gov/resources/items/", $iID)
							
							let $resclean := fn:substring($iID,1,10)			
							let $dirtox := bibs2mets:chars-001($resclean)
							let $destination-root := "/lscoll/lcdb/items/"
		    				let $dir := fn:concat($destination-root, string-join($dirtox, '/'), '/')
		    				let $item-destination-uri := fn:concat($dir, $iID, '.xml')
							
			          	
							let $derivedbib:= fn:replace($paddedID,"^c","")
			          		let $derivedbib:= fn:replace($derivedbib,"^0+","")
			          		 let $itemOf := 
			          	        element bflc:itemOf {          		           
			          				    attribute rdf:resource { fn:concat("http://id.loc.gov/resources/instances/", $instanceID ) }
			                  }
					
		             let $item-modified := 
		                 element bf:Item {
		                     attribute rdf:about {$itemURI},				
		                     $item/*[fn:local-name() ne "itemOf" and fn:local-name() ne "derivedFrom" ],
		     				element bflc:derivedFrom {attribute rdf:resource {fn:concat("http://id.loc.gov/resources/bibs/",$derivedbib)} },			
		                        $itemOf		            
					     }

					let $remove-old:=
					
								for $uri in cts:uri-match(fn:concat($dir,"*") )
									return	if (fn:contains($uri, "-") ) then 
											()
											else (	xdmp:document-delete($uri),
												xdmp:log(fn:concat("CORB BFE/BIB item shuffle, deleting: ", $uri),"info")
																		
									)
					return bibs2mets:insert-any-mets(element rdf:RDF { $item-modified } ,$itemDBURI, $item-destination-uri, $item-collections , "itemRecord")
		            (: let $item-modified := 
		                 element bf:Item {
		                     attribute rdf:about {$itemURI},				
		                     $item/*[fn:local-name() ne "itemOf" and fn:local-name() ne "derivedFrom" ],
		     				element bflc:derivedFrom {attribute rdf:resource {fn:concat("http://id.loc.gov/resources/bibs/",$derivedbib,".marcxml.xml")} },			
		                        $itemOf
		                 }
        			let $item-sem :=
						  try {
			   				  bf4ts:bf4ts( element rdf:RDF { $item-modified } )
					 
					 		} catch($e){	( (),
					     					xdmp:log(fn:concat("CORB BFE/BIB sem conversion error for ", $iID), "info")
											
										)
					 		}
			        let $item-index :=   try {
										 bibframe2index:bibframe2index( element rdf:RDF { $item-modified },<mxe:record/> )
										 } catch($e){	( (),
										 xdmp:log(fn:concat("CORB BFE/BIB item index for ", $iID), "info")
										)
					 		}

			        let $item-mets := 
			            <mets:mets 
			                PROFILE="itemRecord" 
			                OBJID="{$itemDBURI}" 
			                xsi:schemaLocation="http://www.loc.gov/METS/ http://www.loc.gov/standards/mets/mets.xsd" 
			                xmlns:mets	="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink" 
			             	xmlns:rdf	="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
							xmlns:rdfs  = "http://www.w3.org/2000/01/rdf-schema#"						
							xmlns:bf	= "http://id.loc.gov/ontologies/bibframe/" 
							xmlns:bflc	= "http://id.loc.gov/ontologies/bflc/" 
							xmlns:lclocal="http://id.loc.gov/ontologies/lclocal/"
					        xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#" 
			                xmlns:xsi	= "http://www.w3.org/2001/XMLSchema-instance" 
							xmlns:idx	="info:lc/xq-modules/lcindex"
			                xmlns:index	="info:lc/xq-modules/lcindex">
			                <mets:metsHdr LASTMODDATE="{fn:current-dateTime()}"/>
			                <mets:dmdSec ID="bibframe">
			                    <mets:mdWrap MDTYPE="OTHER">
			                        <mets:xmlData>
			                            <rdf:RDF>
			                                {$item-modified}
			                            </rdf:RDF>
			                        </mets:xmlData>
			                    </mets:mdWrap>
			                </mets:dmdSec>
							<mets:dmdSec ID="semtriples">
			                    <mets:mdWrap MDTYPE="OTHER">
			                        <mets:xmlData>
			                            <rdf:RDF>
			                                {if ($item-sem) then $item-sem else <sem:triples/>}
			                            </rdf:RDF>
			                        </mets:xmlData>
			                    </mets:mdWrap>
			                </mets:dmdSec>
			                <mets:dmdSec ID="index">
			                    <mets:mdWrap MDTYPE="OTHER">
			                        <mets:xmlData>
			                           
										    {if ($item-index) then $item-index else <index:index/>}
			                        </mets:xmlData>
			                    </mets:mdWrap>
			                </mets:dmdSec>
			                <mets:structMap>
			                    <mets:div TYPE="itemRecord" DMDID="bibframe semtriples index"/>
			                </mets:structMap>
			            </mets:mets>
            
        return $item-mets
            :)
            
    return $items
    
};

(:
 needs  rdf (work, instance, Item) objectId, file path, collections

:)
declare function bibs2mets:insert-any-mets($rdf as element (rdf:RDF) ,$objectID,$filepath, $collections , $metsprofile){

let $node-name:=fn:name($rdf/*[1])
let $node:=$rdf/*[1]
let $node-name:=fn:name($node)
	
	let $bfindex :=
	   try {
	       			bibframe2index:bibframe2index($rdf, <mxe:empty-record/> )
	   } catch($e){
	             ( 	<index:index/>, 
				 	xdmp:log(fn:concat("CORB BFE/BIB indexing error  for ", $objectID), "info")
				 )
	   }
	let $sem :=  try {
			   			 bf4ts:bf4ts( $rdf )
						 
					 
					 } catch($e){(<sem:triples/>,					 
					     		xdmp:log(fn:concat("CORB BFE/BIB sem conversion error for ", $objectID), "info")
)
					 }
    let $mets := 
        <mets:mets 
            PROFILE="{$metsprofile}" 
            OBJID="{$objectID}" 
            xsi:schemaLocation="http://www.loc.gov/METS/ http://www.loc.gov/standards/mets/mets.xsd" 
            xmlns:mets		="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink" 
            xmlns:rdfs  	= "http://www.w3.org/2000/01/rdf-schema#"			
			xmlns:rdf   	= "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:bf		="http://id.loc.gov/ontologies/bibframe/" 
			xmlns:bflc		="http://id.loc.gov/ontologies/bflc/" 
			xmlns:lclocal="http://id.loc.gov/ontologies/lclocal/"
        	xmlns:madsrdf	="http://www.loc.gov/mads/rdf/v1#" 
			xmlns:relators  = "http://id.loc.gov/vocabulary/relators/"            
            xmlns:index		="info:lc/xq-modules/lcindex"
			xmlns:idx 		= "info:lc/xq-modules/lcindex"							
			xmlns:mxe		= "http://www.loc.gov/mxe"	            	        
			xmlns:skos		= "http://www.w3.org/2004/02/skos/core#"	            	        
	        xmlns:ri		= "http://id.loc.gov/ontologies/RecordInfo#"	        							
			xmlns:sem		= "http://marklogic.com/semantics">
            <mets:metsHdr LASTMODDATE="{fn:current-dateTime()}"/>
            <mets:dmdSec ID="bibframe"><mets:mdWrap MDTYPE="OTHER"><mets:xmlData>
                        				<rdf:RDF> {$node }</rdf:RDF>
                				</mets:xmlData></mets:mdWrap>
            </mets:dmdSec>			
			<mets:dmdSec ID="mxe"><mets:mdWrap MDTYPE="OTHER"><mets:xmlData><mxe:empty-record/></mets:xmlData></mets:mdWrap></mets:dmdSec>
            <mets:dmdSec ID="index">
                <mets:mdWrap MDTYPE="OTHER">
                    <mets:xmlData>{ $bfindex }</mets:xmlData>
                </mets:mdWrap>
            </mets:dmdSec>
			<mets:dmdSec ID="semtriples">
                <mets:mdWrap MDTYPE="OTHER">
                    <mets:xmlData>
                         { $sem }
                    </mets:xmlData>
                </mets:mdWrap>
            </mets:dmdSec>
            <mets:structMap>
                <mets:div TYPE="{$metsprofile}" DMDID="bibframe mxe index semtriples"/>
            </mets:structMap>
        </mets:mets>
 let $quality :=()
 let $forests	:=()	
   	  
 let $insert-node := 
         (try {(xdmp:lock-for-update($filepath),
		 		xdmp:document-insert(
			           			 $filepath, 
				                $mets,
				                (
				                    xdmp:permission("id-user-role", "read"), 
				                    xdmp:permission("id-admin-role", "update"),
				                    xdmp:permission("id-admin-role", "insert")
				                ),
				        		$collections, $quality, $forests
            				)
				)		         
        }
             catch ($e) { xdmp:log(fn:concat("CORB BFE/BIB editor load: not loaded error on : ", $objectID,  fn:string( $e/mlerror:message))    , "error")
        }
        ,
			xdmp:log(fn:concat("CORB BFE/BIB editor load: loaded doc : ",$objectID, " to ",  fn:tokenize($filepath,"/")[fn:last()])   , "info")			
        )
	
    
	return 
        (         
            $objectID          
        )
    
};

(: put the stub in with calculated inverses
	work comes in as rdf:rdf/bf:Work/bf:relatedto/bf:Work (all the relations at once)
	check that the stub title  does not  already exist!
	
:)
declare function bibs2mets:insert-work-stubs($work,$workDBURI, $paddedID, $BIBURI, $destination-uri)
{
for $related at $workpos in $work/bf:Work/*
	
	let $inverse-relation:= 
			 if (fn:index-of(distinct-values($INVERSES//rel/name), fn:local-name($related))) then
								fn:concat("bf:",fn:string($INVERSES//rel[fn:string(name) eq fn:local-name($related)]/inverse))
							else "bf:relatedTo"

	let $wID:= bibs2mets:get-padded-subnode($workpos, $paddedID)
    let $stub-destination-uri:=fn:concat(fn:replace($destination-uri,".xml",format-number($workpos,"0000")),".xml")										

    let $relWorkDBURI := fn:concat("loc.natlib.works." , $wID )
    let $relworkURI := fn:concat("http://id.loc.gov/resources/works/", $wID)
		
		 let $relatedTo := 			 		        		
					element {xs:QName($inverse-relation)} {
								attribute  rdf:resource {
												fn:concat('http://id.loc.gov/resources/works/', $paddedID ) 
												 	}
												 }  
let $label:= if ($related/bf:Work/rdfs:label) then
				()
				else if ($related/bf:Work/bf:title[1]/bf:Title/rdfs:label) 	then
						$related/bf:Work/bf:title[1]/bf:Title/rdfs:label
 					else if  ($related/bf:Work/bf:title[1]/bf:Title/bf:mainTitle) then
						<rdfs:label>{fn:string($related/bf:Work/bf:title[1]/bf:Title/bf:mainTitle)}</rdfs:label>
						else 
						<rdfs:label>[No title]</rdfs:label>

	  let $stub-work:= <rdf:RDF>
			  <bf:Work rdf:about="{$relworkURI}">			
			  {$label}
				{$related/bf:Work/*}
				{$relatedTo}
			</bf:Work>	
			</rdf:RDF>
			
    let $stub-collections :=if (fn:starts-with($wID,"e")) then
					 ("/lscoll/lcdb/works/","/resources/works/","/bibframe/","/bibframe/editor/","/bibframe/stubworks/" ,$BASE_COLLECTIONS)
				 else if (fn:starts-with($wID,"n")) then
					 ("/lscoll/lcdb/works/","/resources/works/","/bibframe/","/bibframe/stubworks/","/bibframe/nametitle-work/",$BASE_COLLECTIONS)
					 else
					("/lscoll/lcdb/works/","/resources/works/","/bibframe/","/bibframe/convertedBibs/","/bibframe/stubworks/" ,$BASE_COLLECTIONS)

	let $insert-stub-mets:= bibs2mets:insert-any-mets($stub-work  ,$relWorkDBURI ,  $stub-destination-uri, $stub-collections ,"workRecord")

	return 
        (         
            $relWorkDBURI 
        )

};
