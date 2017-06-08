xquery version "1.0-ml";

(: 
module for conversion of mets/mods data to idx index terms
version 20100706: added names,topics
:)

module namespace index = "info:lc/xq-modules/index-utils";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "info:lc/xq-modules/lcindex";
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare  namespace idx="info:lc/xq-modules/lcindex";

declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skos="http://www.w3.org/2004/02/skos/core#";						
declare namespace ctry="info:lc/xmlns/codelist-v1";

(: -------------------------- index terms starts here: -------------------------- :)
(:indexTerms.xqy functions:)

declare function index:getAboutDates($mods as node() )  as element() {
(: find best date for faceting and sorting 
test dates;
 To 332 B. C 
 
 Warring States, 403-221 B.C           [*** note that 403 is implied BC]
15th century
221 B.C.-960 A.D
Azuchi-Momoyama period, 1568-1603. [from old catalog]   [*** this is a problem because of multiple hyphens, solved by
    														regex "^\w*(\d*)(-?)(\d*)\w*" $1,$2,$3
Cambrian
Fire, 1933. [from old catalog]
/home/ntra/downloads/temporals.xml
!!! centuries not done and need to use clay's regex !!!
:)

(:let $hasbegindate := if  ($mods//mods:temporal[@point="start"])  then  true  else
if (contains( $mods//mods:temporal,"-") ) then true else                       false
:)
let $aboutdates:= 
    for $temporalsubject in $mods//mods:subject[mods:temporal]
            let $splitdate:=
                for $date in $temporalsubject/mods:temporal                    
                        return (:???? continue here::)
                        (:replace($date,"^\w*(\d*)(-?)(\d*)\w*$",$1,$2,$3) :)
(:              replace $1 as begindate, $3 is enddate
                        from urlrewrite: replace($url, "^/sru(\?.*)?$", "/marklogic/sru.xqy$1"):)
                          if  ( contains($date,"-")  )  then 
                                tokenize($date,"-") else 
                                if  ( contains(lower-case($date),"to ") )  then 
                                tokenize(lower-case($date),"to ")
                            else $date
            let $begin:= 
                            if ($temporalsubject/mods:temporal[@
                            encoding="iso8601"][@point="start" or not(@point)]) then
                                $temporalsubject/mods:temporal[1][@encoding="iso8601"][@point="start" or not(@point)]/string()
                                else if ( $splitdate[2]) then (:single date field, expressed as range with hyphen:)
                                  $splitdate[1]
                                  else  if ( $temporalsubject/mods:temporal[not(@encoding) ] )  then
                                        $temporalsubject/mods:temporal[1][not(@encoding)]                                         
                            else ()
                            
            let $begindate:= if ($begin!="") then                           
                try{ 
                    if (matches($begin,"^c[0-9]")) then (:AD:)
                        substring(replace($begin,"^c","-"),1,5) else
                        if (matches($begin,"^d[0-9]")) then (:AD:)
                            substring(replace($begin,"^d",""),1,4) else
                                if (matches(lower-case($begin),"b.c[\.]*$")) then (:B. C is manually replaced with -, A. D is just stripped later:)                                    
                                    concat("-",(replace(lower-case($begin),"b.c[\.]*$","")))
                                    else 
                                    if (matches(lower-case($splitdate[2]),"b.c[\.]*$")) then (:B. C is implied on begindate based on enddate having "b.c.:)
                                    concat("-",replace($begin,"\D+",""))
                                else                            
                                    substring(replace($begin,"\D+",""),1,4) (:cast as xs:gYear:)                                    
                                                    } catch($exception) {
                                                    ""
                                                }                                
                            else ()
            
            let $end:= if ($temporalsubject/mods:temporal[@encoding="iso8601"][@point="end"]) then
                             $temporalsubject/mods:temporal[@encoding="iso8601"][@point="end"]/string() else 
                            if ( $splitdate[2]) then (:single date field, expressed as range with hyphen:)
                                  $splitdate[2]                            
                            else ()
                            
            let $enddate:= if ($end!="") then
                              try{ 
                    if (matches($end,"^c[0-9]")) then
                        substring(replace($end,"^c","-"),1,5) else
                        if (matches($end,"^d[0-9]")) then
                            substring(replace($end,"^d",""),1,4) else
                             if (matches(lower-case($end),"b.c[\.]*$")) then (:B. C is manually replaced with -, A. D is just stripped later:)                                    
                                    concat("-",(replace(lower-case($end),"b.c[\.]*$","")))
                            else  
                                    substring(replace($end,"\D+",""),1,4) (:cast as xs:gYear:)                                    
                                                    } catch($exception) {
                                                    ""
                                                }                                
                            else ()
            return              
      if ($enddate!="" ) then            
                      
                          <range>          
                                <beginaboutdate>{$splitdate[1]}</beginaboutdate>                                     
                              <endaboutdate>{$enddate}</endaboutdate>
                        </range>
                        else
                          <beginaboutdate>{$begindate}</beginaboutdate>          
                                
   return 
   <aboutdates>{$aboutdates}</aboutdates>
     
     
};


declare function index:getPubDates($origin as node()) as element() {
(: find best date for faceting and sorting :)
let $begin:= if ( $origin/mods:dateIssued[@encoding="marc"][@point="start" or not(@point)]) then
                 $origin/mods:dateIssued[1][@encoding="marc"][@point="start" or not(@point)]/string() else 
                if ($origin/mods:dateCreated[@encoding="marc"][@point="start" or not(@point)]) then
                    $origin/mods:dateCreated[1][@encoding="marc"][@point="start" or not(@point)]/string() else
                if ($origin/mods:dateCaptured[@encoding="iso8601"][@point="start" or not(@point)]) then
                    $origin/mods:dateCaptured[1][@encoding="iso8601"][@point="start" or not(@point)]/string() else
                if ($origin/*[@keydate="yes"]) then
                    $origin/*[@keydate="yes"][1]/string()
                else $origin/*[starts-with(local-name(),"date")][1]/string()
let $begindate:= if ($begin!="") then
                   try{ substring(replace($begin,"\W+",""),1,4) cast as xs:gYear
                        } catch($exception) {
                        ""
                    } 
                else ()

let $end:= if ( $origin/mods:dateIssued[@encoding="marc"][@point="end"]) then
                 $origin/mods:dateIssued[1][@encoding="marc"][@point="end"]/string() else 
                if ($origin/mods:dateCreated[@encoding="marc"][@point="end"]) then
                    $origin/mods:dateCreated[1][@encoding="marc"][@point="end"]/string() else
                if ($origin/mods:dateCaptured[@encoding="iso8601"][@point="end"]) then
                    $origin/mods:dateCaptured[1][@encoding="iso8601"][@point="end"]/string() else
                if ($origin/*[@keydate="yes"]) then
                    $origin/*[@keydate="yes"][1]/string()
                else ()
let $enddate:= if ($end!="") then
                 try{substring(replace($end,"\W+",""),1,4) cast as xs:gYear
                            } catch($exception) {
                            ()
                }
                else ()

return 
    <dates>
        <beginpubdate>{$begindate}</beginpubdate>        
        <endpubdate> {$enddate}</endpubdate>
        <datesort>{replace($begin,"\W+","")}</datesort>
     </dates>
};

declare function index:getEadPubDates($pubstmt as  node()) as element() {
let $begin:=
    if ($pubstmt//ead:date/@normal) then 
      $pubstmt//ead:date/@normal
    else
    ()

let $begindate:= if ($begin!="") then
                   try{ substring(replace($begin,"\W+",""),1,4) cast as xs:gYear
                        } catch($exception) {
                        ""
                        } 
            else ()
return 
    <dates>
        <beginpubdate>{$begindate}</beginpubdate>
        <endpubdate/> 
        <datesort>{replace($begin,"\W+","")}</datesort>
     </dates>
};

declare function index:getSorts($mods as node() ) as node() {
(: sorts have one only per doc :)
let $titles:=  $mods/mods:titleInfo[not(@type)]
let $titleSort:= if ( $titles[1]/mods:subTitle) then 
                      concat($titles[1]/mods:title,", ",$titles[1]/mods:nonSort,": ", $titles[1]/mods:subTitle)
                 else
                      concat($titles[1]/mods:title, $titles[1]/mods:subTitle)

let $names := $mods/mods:name[1]

return 
<sorts>
   <titleSort>{$titleSort}</titleSort>
   <nameSort>{$names[1]//mods:namePart[not(@type) or @type!='date']/string()}</nameSort>
</sorts>
};
declare function index:getEadSorts($archdesc as node() ) as node() {
(: sorts have one only per doc :)
let $title:=  $archdesc/unittitle/string()


let $names := $archdesc/repository/string()

return 
<sorts>
   <titleSort>{$title}</titleSort>
   <nameSort>{$names}</nameSort>
</sorts>
};

(:********************************** :)
declare function index:getObjectType($mods as node(),$profile as xs:string ) as xs:string {
(:genre or form or profile, in that order :)

       if ($mods/mods:genre[@authority="marcgt"]) then
             $mods/mods:genre[@authority="marcgt"][1]/string()
        else if  ( $mods/mods:genre) then
                $mods/mods:genre[1]/string()
        else  if ($mods/mods:form[@authority="marccategory"]) then
           $mods/mods:form[@authority="marccategory"][1]/string()
        else  if ($mods/mods:form) then
           $mods/mods:form[1]/string()
       else 
            substring-after($profile,"lc:")

};
(: *************************************************:)
declare function index:getmarccountries($placeCode as element()? ) {
 
let $countries:=xdmp:document-get("/usr/local/lcdemo/marklogic/config/marcCountries.xml")/ctry:codelist/ctry:countries
return
    if ($placeCode) then
        $countries/ctry:country[ctry:code=$placeCode/string()]/ctry:name[@authorized="yes"]
    else
        replace($placeCode ,"[]","")
 

};
(: *************************************************:)
declare function index:getmarcgacs($placeCode as element()? ) {

	let $gacs:=xdmp:document-get("/usr/local/lcdemo/marklogic/config/gacs.skos.rdf")
	let $code:=replace($placeCode,"--$","")	
	let $pc1:=
 			$gacs//rdf:Description[skos:prefLabel[@xml:lang="zxx"]=$code]
	let $pterm1:=
 		if ($pc1) then
     		$pc1/skos:prefLabel[@xml:lang="en"]/string()
 		else ""
	let $pc2:=
		 if ($pc1/skos:broader) then
		     $gacs//rdf:Description[@rdf:about=$pc1/skos:broader/@rdf:resource]
		 else ()
	let $pterm2:=
 		if ($pc2) then 
  			$pc2/skos:prefLabel[@xml:lang="en"]/string() else ""

	let $pc3:=
 		if ($pc2/skos:broader) then
     		$gacs//rdf:Description[@rdf:about=$pc2/skos:broader/@rdf:resource] else ()
	let $pterm3:=
		 if ($pc3) then 
		  $pc3/skos:prefLabel[@xml:lang="en"]/string() else "" 
	let $pc4:=
		 if ($pc3/skos:broader) then
		     $gacs//rdf:Description[@rdf:about=$pc3/skos:broader/@rdf:resource] else ()
	let $pterm4:=
		 if ($pc4) then 
		  $pc4/skos:prefLabel[@xml:lang="en"]/string() else ""

return ( if ($pterm1!="") then $pterm1 else "",
       if ($pterm2!="") then $pterm2 else "",
       if ($pterm3!="") then $pterm3 else "",
       if ($pterm4!="") then $pterm4 else ""
     ) 

};

(: *************************************************:)
declare function index:getPlaces($mods as element()? ) as node()+ {
 (:
  mods has subject/geographic strings
 subject/hierarchicalGeographic nodes with subelements like "country" that will be idx: terms
 and subject/geographicCodes that must be translated from marccountries or gacs 
 All are deduped and returned as one or more idx:aboutPlace nodes and zero or more idx:country/state etc nodes:)

let $pubplaceCodes:=$mods//mods:place/mods:placeTerm[@type="code"]

let $pubplaceTerms:= (: sequence of text terms :)
    if ($pubplaceCodes) then
	    for $pubplace in $pubplaceCodes
			return
			if ($pubplace/@authority="marccountry") then
				index:getmarccountries($pubplace)
				
			else
				if ($pubplace/@authority="marcgac") then
		             index:getmarcgacs($pubplace)  
				else (:is03166 or unknown :)
					$pubplace/string()          
    else
		replace($mods//mods:place/mods:placeTerm[@type="text"],"[]","")

let $pubplaces:= 
	if ($pubplaceTerms) then (: sequence of idx nodes :)
	  	for $item in distinct-values($pubplaceTerms) 
	    	  return 
			   element { QName("info:lc/xq-modules/lcindex","pubPlace") } 
	    		 {$item}
    else
		 element { QName("info:lc/xq-modules/lcindex","pubPlace") } 
	   		 {"none"}
   			
let $placeSet:=distinct-values($mods//mods:subject/mods:geographic/string())
let $placeCodeSet:=$mods//mods:subject/mods:geographicCode
let $hierachicalPlaces:= 
    for $hierachicalPlace in $mods//mods:subject/mods:hierarchicalGeographic/*
  		return
   			( element { QName("info:lc/xq-modules/lcindex","aboutPlace") } 
    			{$hierachicalPlace/string()},
   			  element { QName("info:lc/xq-modules/lcindex",local-name($hierachicalPlace)) } 
   				{$hierachicalPlace/string()}
  			)

   (: sequence of mods:geographic strings, geocodes translated to strings :)
let $subjectPlaceCodes:= 
 	($placeSet,
	   if ($placeCodeSet) then 
	         for $placeCode in $placeCodeSet
	            return
	       			if ($placeCode/@authority="marccountry") then
	      				index:getmarccountries($placeCode)
	    			else 
	        			if ($placeCode/@authority="marcgac") then
	                  		(index:getmarcgacs($placeCode)  )
	     				else (:no xwalk avail? :)
	                      replace($placeCode/string(),"[]","")
             
	  else ""
	  )   
	  (:combine with $hierachicalPlaces nodes :)
let $allSubjects:=(
			for $placeTerm in  distinct-values($subjectPlaceCodes[string()!=""])
		 		return  element { QName("info:lc/xq-modules/lcindex","aboutPlace") } 
		        	         {$placeTerm},
		     $hierachicalPlaces	
		  )
let $subjectSet:=
	 if ($allSubjects) then 
			$allSubjects
	     else 
	     	element { QName("info:lc/xq-modules/lcindex","aboutPlace") } 
                    {"none"}
return (: one or more aboutPlace nodes and one or more pubPlace nodes  :)
($subjectSet,$pubplaces)
};

(:********************************** :)
declare function index:eadLanguages($lang as element()+ ) as element()+ {
(: takes mods:language or similar (may be sequence), returns de-coded if marclanguage, burst into individual idx:language terms :)
let $marcLangs:= xdmp:document-get("/usr/local/lcdemo/marklogic/config/marcLanguages.xml")/marcLanguages
(:language crosswalk: :)
	
let $language:= 
   if (not($lang)) then
           <language>none</language>
    else if  (not($lang/@langcode)) then
         for $term in $lang/string()
              return 
                 <language>{replace($term,"\W+","")}</language> 
        else
          for $term in $lang/@langcode/string()
                 return 
                    if ( $marcLangs/language[@code=$term] )  then
                         <language>{$marcLangs//language[@code=$term]/string()}  </language>                                                  
                    else 
                        <language>invalid</language>
return $language
        
};

(:********************************** :)
declare function index:languages($lang as element()+ ) as element()+ {
(: takes mods:language or similar (may be sequence), returns de-coded if marclanguage, burst into individual idx:language terms :)
let $marcLangs:= xdmp:document-get("/usr/local/lcdemo/marklogic/config/marcLanguages.xml")/marcLanguages
(:language crosswalk: :)
let $skoslangs:=xdmp:document-get("/usr/local/lcdemo/marklogic/config/languages.skos.rdf")
	

(:let $lang:=$doc//mods:mods/mods:language:)
  let $language:= 
   if (not($lang)) then
           <language>none</language>
    else 
( for $term in distinct-values($lang/mods:languageTerm[@type="text"]/string())
           return 
                    <language>{replace($term,"\W+","")}</language> 
,
for $term in distinct-values($lang/mods:languageTerm[@type="code" and @authority="iso639-2b"]/string())
         return
                    (:if ( $marcLangs/language[@code=$term] )  then
               <language>{$marcLangs/language[@code=$term]/string()}</language>:)
if ( $skoslangs//rdf:Description[skos:prefLabel[@xml:lang="zxx"]=$term])  then
                         (:single term rdf set:)
	let $skoslang:=
 			$skoslangs//rdf:Description[skos:prefLabel[@xml:lang="zxx"]=$term]
                          return <language>{$skoslang/skos:prefLabel[@xml:lang="en"]/string()}  </language>               
       else 
                (:<language>invalid,{$term}</language>:)
                <language>invalid</language>
)
  return $language (: one or more sequence <language> nodes:)

};

(:********************************** :)
declare function index:cleanLocation($locString as xs:string ) as xs:string {
(:trim out library address from reading rooms:)

   if (matches(lower-case($locString),"prints")) then
        "Prints and Photographs" else
    if (matches(lower-case($locString),"folk|afc")) then
        "American Folklife Center" else
    if (matches(lower-case($locString),"geography|map")) then
        "Geography and Maps" else
    if (matches(lower-case($locString),"african")) then
        "African and Middle Eastern" else
    if (matches(lower-case($locString),"asian")) then
        "Asian Division" else
    if (matches(lower-case($locString),"veteran")) then
        "Veterans History Project" else
    if (matches(lower-case($locString),"serial")) then
        "Serial and Government Publications" else
    if (matches(lower-case($locString),"performing")) then
        "Performing Arts Reading Room" else
  if (matches(lower-case($locString),"science")) then
        "Science, Technology and Business" else
  if (matches(lower-case($locString),"music")) then
        "Music Division" else
  if (matches(lower-case($locString),"microform")) then
        "Microforms" else
  if (matches(lower-case($locString),"recorded sound")) then
       "MBRS Recorded Sound Section" else
  if (matches(lower-case($locString),"moving image")) then
        "MBRS Moving Image Section" else
  if (matches(lower-case($locString),"motion picture")) then
        "Motion Picture, Broadcast, Recorded Sound" else
 if (matches(lower-case($locString),"newspapers")) then
        "Newspapers and Current Periodicals" else
 if (matches(lower-case($locString),"general")) then
        "General Collections" else
    if (matches(lower-case($locString),"library of congress|dlc")) then
            "Library of Congress"
    else
        $locString

};


(:********************************** :)
declare function index:getDisplaySet($doc as node()) as node() {
(: for display, not facets:)
let $title:=normalize-space(string($doc//mods:mods/mods:titleInfo[not(@type)][1]))
let $name:=$doc//mods:mods/mods:name[1]
let $nameDisplay:= 
    if ($doc//mods:mods/mods:name) then 
     for $node in $name/*
        where local-name($node)!="role" and ($node/@type!="date" or not($node/@type)) 
         return string($node)
    else ""

let $nameTitle:= if ($nameDisplay!="" and $title!="") then ($nameDisplay, " ", $title) else ""
(: not working well; need to handle roleterm, code etc    if ($primaryname[1]/mods:role ) then
    concat( string($primaryname[1]//*[local-name()!="role"]) , " (", index:getRole($primaryname[1]/mods:role/mods:roleTerm ,")"  )
      else $primaryname[1]/string() :)
let $origin:=$doc//mods:mods/mods:originInfo
let $date:=$origin/*[starts-with(local-name(),"date")]

(:let $countries:=xdmp:document-get("/usr/local/lcdemo/marklogic/config/marcCountries.xml")[2]/ctry:codelist/ctry:countries
let $pubplacecode:=$origin/mods:place/mods:placeTerm[@type="code"]/string()
let $pubplace:=
    if ($pubplacecode!="") then
        $countries/ctry:country[ctry:code=$pubplacecode]/ctry:name[@authorized="yes"]/string()
    else
        replace($origin/mods:place[1]/mods:placeTerm/string(),"[]","")
:)
let $objectType := if ($doc/mets:dmdSec[@ID="ead"]) then
                     "Finding Aid"
                    else
                     index:getObjectType($doc/mets:dmdSec/mets:mdWrap[@MDTYPE="MODS"]/mets:xmlData/mods:mods, $doc/@PROFILE)

 let $firstimage:=
    if ($doc//mets:structMap//mets:div[@LABEL="thumb"]) then 
        let $fileid:= $doc//mets:structMap//mets:div[@LABEL="thumb"]/mets:fptr[2]/@FILEID
        return $doc//mets:fileGrp[@USE="SERVICE"]/mets:file[@ID=$fileid]/mets:FLocat/@xlink:href/string()
    else $doc//mets:fileGrp[@USE="SERVICE"]/mets:file[contains(mets:FLocat/@xlink:href,".jpg")][1]/mets:FLocat/@xlink:href/string()
let $illustrative := 
    if (matches($firstimage,"\.jp2$")) then
        $firstimage else
        if (matches($firstimage,"/afcwip/|/pnp/")  ) then
            replace ($firstimage,"v.jpg","t.gif")
        else if ($firstimage!="") then
            replace ($firstimage,"v.jpg","h.jpg")
        else "none"
(: thumbnail is illustrative or a boilerplate image based on objectttype :)
let $thumbnail:= $illustrative
return 
<display>
   <title>{$title[1]}</title>
   <primaryName>{$nameDisplay}</primaryName>
   <date>{$date[1]/string()}</date> 
   <objectType>{$objectType}</objectType >
   <thumbnail>{$thumbnail}</thumbnail>   
   <nameTitle>{$nameTitle}</nameTitle> 
   <abstract>{$doc//mods:mods/mods:abstract[1]/string()}</abstract> 
</display>
(:   <pubPlace>{$pubplace}</pubPlace>:)
};
declare function index:getEadFacets($doc as node()){
(: may have more than one per term per doc :)
let $genreSet:=$doc//ead:controlaccess//ead:genreform

let $genres:=
  for $term in distinct-values($genreSet)
    return element { QName("info:lc/xq-modules/lcindex","genre") } 
     {string(replace($term,"[\.]",""))} 

let $typeOfResource:= "collection"
let $manuscript:= "yes"
let $hasLink := if ($doc//mods:mods/mods:identifier[@type="hdl"] or $doc//mods:mods/mods:location/mods:physicalLocation[@xlink] or  $doc//mods:mods/mods:location/mods:url   )  then "true" else "false"

(:let $marcLangs:= xdmp:document-get("/usr/local/lcdemo/marklogic/config/marcLanguages.xml")/marcLanguages:)
let $lang:= $doc//ead:archdesc/ead:did/ead:langmaterial/ead:language
let $language:= if ($lang) then index:eadLanguages($lang) else <language>none</language>

let $digitized:= if($doc//mets:fileSec)  then "true" else "false"
let $location:= if ($doc//ead:archdesc/ead:did/ead:repository) then
                    index:cleanLocation($doc//ead:archdesc/ead:did/ead:repository[1]/string())
                else "none"
let $access:= if ($doc//ead:archdesc/ead:accessrestrict) then 
    $doc//ead:archdesc/ead:accessrestrict
  else "none"
let $profile:= substring-after($doc/@PROFILE/string(),"lc:")
return
	<facets>
	   <genreTerms>{$genres}</genreTerms>
	   <resourceType>{$typeOfResource}</resourceType>
	   <collection>true</collection>
	   <manuscript>{$manuscript}</manuscript>
		{$language}
	   <digitized>{$digitized}</digitized>
	   <hasLink>{$hasLink}</hasLink>
	   <location>{$location}</location>
	   <profile>{$profile}</profile>
	</facets>

};
(: *************************************************:)
declare function index:getNotes($mods as element() ) {
(: may have more than one per term per doc :)

let $noteSet:=$mods//mods:note[@type]

for $note in $noteSet[not(matches("[additionalphysicalform | venue|reproduction]",lower-case(replace(@type,"\W+","")) ) )]
  let $element:=lower-case(replace($note/@type,"\W+",""))
    return 
         element { QName("info:lc/xq-modules/lcindex",$element) } 
            {$note/string()}
  
};
(: *************************************************:)
declare function index:getRole($roleterm as element()  ) as xs:string {
	if ($roleterm/@type="text") then		
		lower-case($roleterm/string())
	else
		let $relatorURI:=concat("http://id.loc.gov/vocabulary/relators/",$roleterm[@type = "code"]/string() )		
		let $relatorXML:=xdmp:http-get(concat($relatorURI,".rdf"))
		return
			lower-case($relatorXML//rdf:Description[@rdf:about=$relatorURI]/skos:prefLabel[@xml:lang="en"]/string())
			
};

(: *************************************************:)
declare function index:getNames($mods as element() ) {
(: may have more than one per term per doc :)

let $aboutSet:=$mods//mods:subject/mods:name
let $bySet:=($mods/mods:name[local-name(parent::*)!="subject"],
$mods/mods:relatedItem[@type="constituent"]/mods:name)

return	(
    for $name in $aboutSet  
  	return 	 
             element { QName("info:lc/xq-modules/lcindex","aboutName") } 
                 {$name/*[local-name()!="role"]/string()},
		
    for $name in $bySet  
    	return 	(: always return creator , but add performer: :)
	       (if ($name/mods:role) then				
		  for $roleterm in $name/mods:role/mods:roleTerm
			    let $role:= index:getRole($roleterm)
		                  return					
	         			element { QName("info:lc/xq-modules/lcindex", $role ) } 
    	        			    {$name/*[local-name()!="role"]/string()}
    	        	else 
    	        	    element { QName("info:lc/xq-modules/lcindex","creator") } 
            	          {$name/*[local-name()!="role"]/string()}		  
                 )
	)
};


(: *************************************************:)
declare function index:getTopics($mods as element() ) {
(: may have more than one per term per doc :)
(: not finished:)
let $subjectSet:=$mods//mods:subject[mods:topic[1]]

for $topic in $subjectSet
  
    return 
	 if ($topic/@authority="lcsh") then
         element { QName("info:lc/xq-modules/lcindex","lcshTopic") } 
            {$topic/mods:topic/string()}
			else
			element { QName("info:lc/xq-modules/lcindex","topic") } 
            {$topic/mods:topic/string()}
  
};


declare function index:getFacets($doc as node()){
(: may have more than one per term per doc :)
let $genreSet:=$doc//mods:mods/mods:genre
let $marcgt:=
  if ($genreSet[@authority="marcgt"]) then 
	  for $term in distinct-values($genreSet[@authority="marcgt"])
	    return element { QName("info:lc/xq-modules/lcindex","marcgt") } 
	     {replace(string($term),"[\.\[\]]","")} 
		 else
		    <marcgt>none</marcgt>

let $tgmgenre:=
	if ($genreSet[@authority="gmgpc" or @authority="tgm"]) then
		  for $term in distinct-values($genreSet[@authority="gmgpc" or @authority="tgm"])
		    return element { QName("info:lc/xq-modules/lcindex","tgmgenre") } 
		     { replace(string($term),"[\.\[\]]","")} 
    else
		    <tgmterm>none</tgmterm>

let $genres:=
  for $term in distinct-values($genreSet[not(@authority="marcgt" or @authority="gmgpc" or @authority="tgm")])
    return element { QName("info:lc/xq-modules/lcindex","genre") } 
     {replace(string($term),"[\.\[\]]","")} 


let $formSet:=$doc//mods:form

let $forms:=
  for $term in distinct-values($formSet)
   order by string($term)
    return 
     element { QName("info:lc/xq-modules/lcindex","form") } 
        {string($term)} 

let $marcform:= 
    <marcform>{
           if (not($formSet[@authority="marccategory"]/string()) ) then 
                "none" 
            else
                 $formSet[@authority="marccategory"]/string()
    }</marcform>


let $resource:=$doc//mods:mods/mods:typeOfResource
let $typeOfResource:= $resource/string()
let $manuscript:= if ($resource/@manuscript="yes") then "true" else "false"
let $collection:= if ($resource/@collection="yes") then "true" else 
      if ($doc/@PROFILE="lc:collectionRecord") then "true" else "false"
let $lcclass:=
            if ($doc//mods:classification[@authority="lcc"] ) then
                $doc//mods:classification[@authority="lcc"][1]/string()
            else "none"

let $deweyclass:=
            if ($doc//mods:classification[@authority="ddc"]) then
                $doc//mods:classification[@authority="ddc"][1]/string()
            else "none"


let $hasLink := if ($doc//mods:mods/mods:identifier[@type="hdl"] or $doc//mods:mods/mods:location/mods:physicalLocation[@xlink] or  $doc//mods:mods/mods:location/mods:url   )  then 
                "true" else "false"
(:let $marcLangs:= xdmp:document-get("/usr/local/lcdemo/marklogic/config/marcLanguages.xml")/marcLanguages :)
let $lang:=$doc//mods:mods/mods:language

  let $language:= if ($lang) then index:languages($lang) else <language>none</language>

let $digitized:= if($doc//mets:fileSec)  then "true" else "false"
let $location:=  if ($doc//mods:location/mods:physicalLocation) then 
                     index:cleanLocation(string($doc//mods:mods/mods:location/mods:physicalLocation[1] )) else "none" 
let $access:= if ($doc//mods:mods/mods:accessCondition) then 
    $doc//mods:mods/mods:accessCondition
  else "none"
(: name/title, subject by type, name by type, etc???:)
let $profile:=substring-after($doc/@PROFILE,"lc:")
return
<facets>
   <genreTerms>{$marcgt}{$tgmgenre}{$genres}</genreTerms>
   <forms>{$marcform}{$forms}</forms>
   <resourceType>{$typeOfResource}</resourceType>
   <collection>{$collection}</collection>
   <manuscript>{$manuscript}</manuscript>
    {$language} 
   <lcclass>{$lcclass}</lcclass> 
   <dewey>{$deweyclass}</dewey>   
   <digitized>{$digitized}</digitized>
   <location>{$location}</location>
   <hasLink>{$hasLink}</hasLink>
   <profile>{$profile}</profile>
   
</facets>

};
(:********************************** :)
declare function index:getIds($doc as node()){

let $objectid:=string($doc/@OBJID)
let $idnode3:=tokenize($objectid,"\.")[3]
let $ids:=$doc//mods:mods/mods:identifier[@type][@type!="membership"][@type!="local"]
(: related item children are included, but see alsos are not :)
let $childids:=$doc//mods:relatedItem[@type="constituent"]/mods:identifier[@type][@type!="membership"][@type!="local"]
let $idSet:=
 for $id in ($ids,$childids)
      let $localname:= replace(string($id/@type),"\W+","") 
   order by $id/@type, string($id)
     return  
     element { QName("info:lc/xq-modules/lcindex", $localname) }                   
        {string($id)} 
let $sets:=$doc//mods:identifier[@type="membership"]

(: need registered list of memberships and displayNames for all :)

let $memberships:=
 for $member in $sets
  order by string($member)
    return  
     element { QName("info:lc/xq-modules/lcindex","memberCode") } {
      element memberOf {string($member)},
      element uri { concat("http://www.datastore.gov/memberships/",replace(string($member),"\W+",""))}
     }

return
<ids>
   <objectid>{$objectid}</objectid>
   {$idSet}
{$memberships}
<memberCode><memberOf>{$idnode3}</memberOf><uri>http://www.datastore.gov/memberships/{$idnode3}</uri> </memberCode>
<memberCode><memberOf>allrecords</memberOf><uri>http://www.datastore.gov/memberships/allrecords</uri> </memberCode>

</ids>

};

(:declare function index:getIndexTerms($id as xs:string) as node() {
(: not actually used; use indexTerms.xqy to call these functions :)
(: get the index terms for a given document; this should be performed on ingest, but if not found in a document, 
   can be called dynamically, as in the search results page 
   get.xqy uses this if idx: is not embedded in the document
:)

(: facets are multiple per doc, sorts are single per doc :)


(:declare variable $id as xs:string := xdmp:get-request-field("id",""); :)
let $doc:=utils:mets($id) 

(: test ids :)
(:
let $doc:=doc("loc.natlib.lcdb.12037148.xml")
let $doc:=doc("/pae/loc.natlib.ihas.200003782.xml")
let $doc:=doc("/bib/loc.natlib.mrva0016.1899.xml")
let $doc:=xdmp:http-get("http://marklogic1.loctest.gov/loc.mss.eadmss.ms008066")[2]
:)


let $pubdates:= 
  if ($doc//mets:dmdSec[@ID="ead"]) then
    index:getEadPubDates($doc//mets:dmdSec[@ID="ead"]/mets:mdWrap/mets:xmlData/ead:ead/ead:eadheader/ead:filedesc/ead:publicationstmt)
else
   index:getPubDates($doc/mets:dmdSec/mets:mdWrap[@MDTYPE="MODS"]/mets:xmlData/mods:mods/mods:originInfo)

let $facets:= 
  if ($doc/mets:mets/mets:dmdSec[@ID="ead"]) then
     index:getEadFacets($doc)
    else 
     index:getFacets($doc)
let $sorts:=
  if ($doc/mets:dmdSec[@ID="ead"]) then
     index:getEadSorts($doc/mets:dmdSec[@ID="ead"]/mets:mdWrap/mets:xmlData/ead:ead/ead:archdesc)
  else 
	 index:getSorts($doc/mets:dmdSec/mets:mdWrap[@MDTYPE="MODS"]/mets:xmlData/mods:mods)

let $ids:=index:getIds($doc)
let $notes:= index:getNotes($doc/mets:dmdSec/mets:mdWrap[@MDTYPE="MODS"]/mets:xmlData/mods:mods)
let $names:= index:getNames($doc/mets:dmdSec/mets:mdWrap[@MDTYPE="MODS"]/mets:xmlData/mods:mods)
let $topics:= index:getTopics($doc/mets:dmdSec/mets:mdWrap[@MDTYPE="MODS"]/mets:xmlData/mods:mods) 
let $display:=index:getDisplaySet($doc)


return 
<indexTerms version="20100707" >
    {$sorts}
    {$pubdates}
    {$facets}
    {$ids}
    {$topics}	
    {$names}
    {$notes}	
    {$display}

</indexTerms>
};
:)
