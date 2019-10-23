(:indexTerms.xqy Nate:)
xquery version "1.0-ml";

declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare  namespace idx="info:lc/xq-modules/lcindex";
declare namespace ead="urn:isbn:1-931666-22-9";
declare namespace mets="http://www.loc.gov/METS/";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skos="http://www.w3.org/2004/02/skos/core#";
declare namespace ctry="info:lc/xmlns/codelist-v1";
declare namespace mxe = "http://www.loc.gov/mxe";
(:prod:)
import module namespace utils="info:lc/xq-modules/mets-utils" at "/xq/modules/mets-utils.xqy";
import module namespace index="info:lc/xq-modules/index-utils" at "/xq/modules/index-utils.xqy";
(: cq: :)
(:
import module namespace utils="info:lc/xq-modules/mets-utils" at "/xq/modules/mets-utils.xqy";
:)
(: find best date for faceting and sorting :)
(: these modules are obsolete; running mets-util versions now :)


(: facets are multiple per doc, sorts are single per doc :)
(: prod: :)
declare default element namespace  "info:lc/xq-modules/lcindex";
declare variable $id as xs:string := xdmp:get-request-field("id","");

let $doc:=utils:mets($id) 

(: cq: :)
(:
let $doc:=doc("loc.natlib.lcdb.12037148.xml")
let $doc:=doc("/pae/loc.natlib.ihas.200003782.xml")
let $doc:=doc("/bib/loc.natlib.mrva0016.1899.xml")
let $doc:=xdmp:http-get("http://marklogic3.loctest.gov/loc.mss.eadmss.ms008066")[2]

:)
let $mods:=$doc//mods:mods
let $mxe:= $doc//mxe:record
let $profile:=substring-after($doc/mets:mets/@PROFILE,"lc:")
let $aboutdates:=index:getAboutDates($mods[//mods:subject/mods:temporal])


let $pubdates:= 
  if ($doc//mets:dmdSec[@ID="ead"]) then
    index:getEadPubDates($doc//ead:ead/ead:eadheader/ead:filedesc/ead:publicationstmt)
else
   index:getPubDates($mods/mods:originInfo)

let $facets:= 
  if ($doc//mets:dmdSec[@ID="ead"]) then
     index:getEadFacets($doc)
    else 
     index:getFacets($mods)
	 let $objectType := 
     index:getObjectType($mods, $profile)
	 let $hitlist:= index:getHitlist($mods,$mxe)
let $titles:= index:getTitles($mods)

let $ids:=index:getIds($mods)

let $notes:= index:getNotes($mods)
let $names:= index:getNames($mods)
let $topics:= index:getTopics($mods)
(:both pubplace and aboutplace (mods only, not ead for now) : :)
let $places:= index:getPlaces($mods)
let $nametitle:=index:getNameTitle($mods)
let $firstimage:=
    if ($doc//mets:structMap//mets:div[@LABEL="thumb"]) then 
        let $fileid:= $doc//mets:structMap//mets:div[@LABEL="thumb"]/mets:fptr[2]/@FILEID
        return $doc//mets:fileGrp[@USE="SERVICE"]/mets:file[@ID=$fileid]/mets:FLocat/@xlink:href/string()
    else $doc//mets:fileGrp[@USE="SERVICE"]/mets:file[contains(mets:FLocat/@xlink:href,".jpg")][1]/mets:FLocat/@xlink:href/string()

(: thumbnail is illustrative or a boilerplate image based on objectttype :)

let $digitized:=index:getDigitized($mods)

let $thumbnail := 
    if (matches($firstimage,"\.jp2$")) then
        $firstimage else
        if (matches($firstimage,"/afcwip/|/pnp/")  ) then
            replace ($firstimage,"v.jpg","t.gif")
        else if ($firstimage!="") then
            replace ($firstimage,"v.jpg","h.jpg")
        else "none"
(:let $typeofMaterial:= index:getMattype($mxe):)

   (:{$sorts} :)
return  

<idx:indexTerms version="20100930" xmlns:idx="info:lc/xq-modules/lcindex">
    {$hitlist}
    {$titles}
    {$objectType}
    <idx:thumbnail>{$thumbnail}</idx:thumbnail>
    {$pubdates}
    {$aboutdates}	
    {$facets/*}
    {$ids/*}
    {$names}
    {$notes}
    {$places}
   {$topics}
    {$nametitle}
 <idx:memberCode>
    	<idx:memberOf>catalog</idx:memberOf><idx:uri>http://loccatalog.loc.gov/memberships/catalog</idx:uri>
 </idx:memberCode>
{$digitized}
</idx:indexTerms>

(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)