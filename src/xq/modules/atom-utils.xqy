xquery version "1.0-ml";

module namespace feed = "info:lc/xq-modules/atom-utils";
import module namespace mets-utils = "info:lc/xq-modules/mets-utils" at "mets-utils.xqy";
import module namespace search = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";
(:declare namespace search = "http://marklogic.com/appservices/search";:)
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace mxe = "http://www.loc.gov/mxe";
declare namespace mxe2 = "http://www.loc.gov/mxe";
declare namespace idx = "info:lc/xq-modules/lcindex";
declare namespace index = "info:lc/xq-modules/lcindex";
declare namespace bf = "http://id.loc.gov/ontologies/bibframe/";
declare namespace atom = "http://www.w3.org/2005/Atom";
declare namespace prop = "http://marklogic.com/xdmp/property";
declare namespace georss = "http://www.georss.org/georss";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";
(:~
:   Get index document
:	Currently generates index from madsrdf if its not bf and on test
: from id, format:get-index
:
:   @param  $uri            is DB uri of METS document
:   @return element
:)
declare function feed:get-index(
    $uri as xs:string
    ) as element()
{
    (: name title works hav both indexes; 
		/resources/works/n2018040054
	:)
	
	if(mets-utils:get-mets-dmdSec('ldsindex', $uri)!= <empty/>) then
			mets-utils:get-mets-dmdSec('ldsindex', $uri) 
      else if(mets-utils:get-mets-dmdSec('index', $uri)!= <empty/>) then
        mets-utils:get-mets-dmdSec('index', $uri)    
      else 
        element index:index{} 

};
declare variable $feed:idx :=
	<idx:indexTerms version="20101105">
	  <idx:display>
	    <idx:title>Die Geschichte der 4. Klasse u. ihrer Fahrzeuge (D-Wagen).</idx:title>
	    <idx:mainCreator>Dost, Paul. [from old catalog]</idx:mainCreator>
	    <idx:pubinfo>Dortmund, W. Böttcher [1968?]</idx:pubinfo>
	    <idx:typeOfMaterial>Book (Print, Microform, Electronic, etc.)</idx:typeOfMaterial>
	    <idx:materialGroup>Book</idx:materialGroup>
	  </idx:display>
	</idx:indexTerms>
;

declare variable $feed:test :=
<search:response total="265" start="1" page-length="10" xmlns:search="http://marklogic.com/appservices/search">
  <search:result index="1" uri="/catalog/lscoll/lcdb/bib/1/4/1/8/0/8/4/1/14180841.xml" path="fn:doc('/catalog/lscoll/lcdb/bib/1/4/1/8/0/8/4/1/14180841.xml')" score="1530" confidence="0.784646" fitness="0.969261">
    <search:snippet>
      <search:match path="fn:doc('/catalog/lscoll/lcdb/bib/1/4/1/8/0/8/4/1/14180841.xml')/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:titleInfo/mods:subTitle">...on the law of property, chiefly founded on the writings of the late Sir Chaloner <search:highlight>Alabaster</search:highlight></search:match>
      <search:match path="fn:doc('/catalog/lscoll/lcdb/bib/1/4/1/8/0/8/4/1/14180841.xml')/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:name[1]/mods:namePart[1]"><search:highlight>Alabaster</search:highlight>, Ernest</search:match>
      <search:match path="fn:doc('/catalog/lscoll/lcdb/bib/1/4/1/8/0/8/4/1/14180841.xml')/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:name[2]/mods:namePart[1]"><search:highlight>Alabaster</search:highlight>, Chaloner</search:match>
      <search:match path="fn:doc('/catalog/lscoll/lcdb/bib/1/4/1/8/0/8/4/1/14180841.xml')/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:note">by Ernest <search:highlight>Alabaster</search:highlight>.</search:match>
    </search:snippet>
  </search:result>
  <search:result index="2" uri="/catalog/lscoll/lcdb/bib/4/8/9/9/0/3/489903.xml" path="fn:doc('/catalog/lscoll/lcdb/bib/4/8/9/9/0/3/489903.xml')" score="1530" confidence="0.784646" fitness="0.969261">
    <search:snippet>
      <search:match path="fn:doc('/catalog/lscoll/lcdb/bib/4/8/9/9/0/3/489903.xml')/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:titleInfo/mods:title">English medieval <search:highlight>alabasters</search:highlight></search:match>
      <search:match path="fn:doc('/catalog/lscoll/lcdb/bib/4/8/9/9/0/3/489903.xml')/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:subject[2]/mods:topic"><search:highlight>Alabaster</search:highlight> sculpture, English</search:match>
      <search:match path="fn:doc('/catalog/lscoll/lcdb/bib/4/8/9/9/0/3/489903.xml')/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:subject[3]/mods:topic"><search:highlight>Alabaster</search:highlight> sculpture, Medieval</search:match>
      <search:match path="fn:doc('/catalog/lscoll/lcdb/bib/4/8/9/9/0/3/489903.xml')/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:subject[4]/mods:topic"><search:highlight>Alabaster</search:highlight> sculpture</search:match>
    </search:snippet>
  </search:result>
  <search:result index="3" uri="/catalog/lscoll/lcdb/bib/9/2/9/5/2/3/929523.xml" path="fn:doc('/catalog/lscoll/lcdb/bib/9/2/9/5/2/3/929523.xml')" score="1530" confidence="0.784646" fitness="0.969261">
    <search:snippet>
      <search:match path="fn:doc('/catalog/lscoll/lcdb/bib/9/2/9/5/2/3/929523.xml')/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:name/mods:namePart">Thompson High School (<search:highlight>Alabaster</search:highlight>, Ala.)</search:match>
      <search:match path="fn:doc('/catalog/lscoll/lcdb/bib/9/2/9/5/2/3/929523.xml')/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:originInfo/mods:place[2]/mods:placeTerm"><search:highlight>Alabaster</search:highlight>, Ala</search:match>
      <search:match path="fn:doc('/catalog/lscoll/lcdb/bib/9/2/9/5/2/3/929523.xml')/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:subject[2]/mods:geographic"><search:highlight>Alabaster</search:highlight> (Ala.)</search:match>
      <search:match path="fn:doc('/catalog/lscoll/lcdb/bib/9/2/9/5/2/3/929523.xml')/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:subject[3]/mods:geographic"><search:highlight>Alabaster</search:highlight> (Ala.)</search:match>
    </search:snippet>
  </search:result>
  <search:result index="4" uri="/catalog/lscoll/lcdb/bib/1/3/4/8/9/0/9/1/13489091.xml" path="fn:doc('/catalog/lscoll/lcdb/bib/1/3/4/8/9/0/9/1/13489091.xml')" score="1530" confidence="0.784646" fitness="0.969261">
    <search:snippet>
      <search:match path="fn:doc('/catalog/lscoll/lcdb/bib/1/3/4/8/9/0/9/1/13489091.xml')/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:titleInfo/mods:title">closer look at William <search:highlight>Alabaster</search:highlight> (1568-1640)</search:match>
      <search:match path="fn:doc('/catalog/lscoll/lcdb/bib/1/3/4/8/9/0/9/1/13489091.xml')/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:name/mods:namePart"><search:highlight>Alabaster</search:highlight>, John S.</search:match>
      <search:match path="fn:doc('/catalog/lscoll/lcdb/bib/1/3/4/8/9/0/9/1/13489091.xml')/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:originInfo/mods:publisher"><search:highlight>Alabaster</search:highlight> Society</search:match>
      <search:match path="fn:doc('/catalog/lscoll/lcdb/bib/1/3/4/8/9/0/9/1/13489091.xml')/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:note[1]">by John S. <search:highlight>Alabaster</search:highlight>.</search:match>
    </search:snippet>
  </search:result>
  <search:result index="5" uri="/catalog/lscoll/lcdb/bib/1/4/1/8/0/8/5/1/14180851.xml" path="fn:doc('/catalog/lscoll/lcdb/bib/1/4/1/8/0/8/5/1/14180851.xml')" score="1530" confidence="0.784646" fitness="0.969261">
    <search:snippet>
      <search:match path="fn:doc('/catalog/lscoll/lcdb/bib/1/4/1/8/0/8/5/1/14180851.xml')/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:titleInfo/mods:subTitle">...on the law of property, chiefly founded on the writings of the late Sir Chaloner <search:highlight>Alabaster</search:highlight></search:match>
      <search:match path="fn:doc('/catalog/lscoll/lcdb/bib/1/4/1/8/0/8/5/1/14180851.xml')/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:name[1]/mods:namePart[1]"><search:highlight>Alabaster</search:highlight>, Ernest</search:match>
      <search:match path="fn:doc('/catalog/lscoll/lcdb/bib/1/4/1/8/0/8/5/1/14180851.xml')/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:name[2]/mods:namePart[1]"><search:highlight>Alabaster</search:highlight>, Chaloner</search:match>
      <search:match path="fn:doc('/catalog/lscoll/lcdb/bib/1/4/1/8/0/8/5/1/14180851.xml')/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:note[1]">by Ernest <search:highlight>Alabaster</search:highlight>.</search:match>
    </search:snippet>
  </search:result>
  <search:result index="6" uri="/catalog/lscoll/lcdb/bib/3/6/5/0/5/0/365050.xml" path="fn:doc('/catalog/lscoll/lcdb/bib/3/6/5/0/5/0/365050.xml')" score="1440" confidence="0.761219" fitness="0.940322">
    <search:snippet>
      <search:match path="fn:doc('/catalog/lscoll/lcdb/bib/3/6/5/0/5/0/365050.xml')/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:titleInfo/mods:title">Medieval effigial <search:highlight>alabaster</search:highlight> tombs in Yorkshire</search:match>
      <search:match path="fn:doc('/catalog/lscoll/lcdb/bib/3/6/5/0/5/0/365050.xml')/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:subject[2]/mods:topic"><search:highlight>Alabaster</search:highlight> sculpture, English</search:match>
      <search:match path="fn:doc('/catalog/lscoll/lcdb/bib/3/6/5/0/5/0/365050.xml')/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:subject[3]/mods:topic"><search:highlight>Alabaster</search:highlight> sculpture, Medieval</search:match>
      <search:match path="fn:doc('/catalog/lscoll/lcdb/bib/3/6/5/0/5/0/365050.xml')/mets:mets/mets:dmdSec[2]/mets:mdWrap/mets:xmlData/mxe2:record/mxe2:datafield_245/mxe2:d245_subfield_a">Medieval effigial <search:highlight>alabaster</search:highlight> tombs in Yorkshire /</search:match>
    </search:snippet>
  </search:result>
  <search:result index="7" uri="/catalog/lscoll/lcdb/bib/4/6/1/8/2/1/7/4618217.xml" path="fn:doc('/catalog/lscoll/lcdb/bib/4/6/1/8/2/1/7/4618217.xml')" score="1440" confidence="0.761219" fitness="0.940322">
    <search:snippet>
      <search:match path="fn:doc('/catalog/lscoll/lcdb/bib/4/6/1/8/2/1/7/4618217.xml')/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:titleInfo/mods:title">English medieval <search:highlight>alabasters</search:highlight></search:match>
      <search:match path="fn:doc('/catalog/lscoll/lcdb/bib/4/6/1/8/2/1/7/4618217.xml')/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:subject[2]/mods:topic"><search:highlight>Alabaster</search:highlight> sculpture, English</search:match>
      <search:match path="fn:doc('/catalog/lscoll/lcdb/bib/4/6/1/8/2/1/7/4618217.xml')/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:subject[3]/mods:topic"><search:highlight>Alabaster</search:highlight> sculpture, Medieval</search:match>
      <!-- <search:match path="fn:doc('/catalog/lscoll/lcdb/bib/4/6/1/8/2/1/7/4618217.xml')/mets:mets/mets:dmdSec[2]/mets:mdWrap/mets:xmlData/mxe2:record/mxe2:datafield_245/mxe2:d245_subfield_a">English medieval <search:highlight>alabasters</search:highlight> /</search:match> -->
    </search:snippet>
  </search:result>
  <search:result index="8" uri="/catalog/lscoll/lcdb/bib/1/2/4/3/0/8/8/4/12430884.xml" path="fn:doc('/catalog/lscoll/lcdb/bib/1/2/4/3/0/8/8/4/12430884.xml')" score="1440" confidence="0.761219" fitness="0.940322">
    <search:snippet>
      <search:match path="fn:doc('/catalog/lscoll/lcdb/bib/1/2/4/3/0/8/8/4/12430884.xml')/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:titleInfo/mods:title">Maps of Shelby County with Montevallo, Columbiana, <search:highlight>Alabaster</search:highlight> &amp; Pelham, Alabama</search:match>
      <search:match path="fn:doc('/catalog/lscoll/lcdb/bib/1/2/4/3/0/8/8/4/12430884.xml')/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:tableOfContents">Shelby County -- Columbiana -- Pelham -- Montevallo -- <search:highlight>Alabaster</search:highlight>.</search:match>
      <search:match path="fn:doc('/catalog/lscoll/lcdb/bib/1/2/4/3/0/8/8/4/12430884.xml')/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:note[3]">...indexes to Columbiana, Montevallo and <search:highlight>Alabaster</search:highlight> and...</search:match>
    </search:snippet>
  </search:result>
  <search:result index="9" uri="/catalog/lscoll/lcdb/bib/1/2/4/3/0/8/3/1/12430831.xml" path="fn:doc('/catalog/lscoll/lcdb/bib/1/2/4/3/0/8/3/1/12430831.xml')" score="1440" confidence="0.761219" fitness="0.940322">
    <search:snippet>
      <search:match path="fn:doc('/catalog/lscoll/lcdb/bib/1/2/4/3/0/8/3/1/12430831.xml')/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:titleInfo/mods:title">Maps of Shelby County with Montevallo, Columbiana, <search:highlight>Alabaster</search:highlight>, and Calera, Alabama</search:match>
      <search:match path="fn:doc('/catalog/lscoll/lcdb/bib/1/2/4/3/0/8/3/1/12430831.xml')/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:tableOfContents">Shelby County -- Columbiana -- Calera -- Montevallo -- <search:highlight>Alabaster</search:highlight>.</search:match>
      <search:match path="fn:doc('/catalog/lscoll/lcdb/bib/1/2/4/3/0/8/3/1/12430831.xml')/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:note[3]">...to Columbiana, Montevallo and <search:highlight>Alabaster</search:highlight>...</search:match>
    </search:snippet>
  </search:result>
  <search:result index="10" uri="/catalog/lscoll/lcdb/bib/1/2/4/3/0/9/4/1/12430941.xml" path="fn:doc('/catalog/lscoll/lcdb/bib/1/2/4/3/0/9/4/1/12430941.xml')" score="1440" confidence="0.761219" fitness="0.940322">
    <search:snippet>
      <search:match path="fn:doc('/catalog/lscoll/lcdb/bib/1/2/4/3/0/9/4/1/12430941.xml')/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:titleInfo/mods:title">Maps of Shelby County with Montevallo, Columbiana, <search:highlight>Alabaster</search:highlight>, Calera, and Pelham, Alabama</search:match>
      <search:match path="fn:doc('/catalog/lscoll/lcdb/bib/1/2/4/3/0/9/4/1/12430941.xml')/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:tableOfContents">Shelby County -- Columbiana -- Pelham -- Montevallo -- Calera -- <search:highlight>Alabaster</search:highlight>.</search:match>
      <search:match path="fn:doc('/catalog/lscoll/lcdb/bib/1/2/4/3/0/9/4/1/12430941.xml')/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods/mods:note[3]">...Montevallo and <search:highlight>Alabaster</search:highlight>...</search:match>
    </search:snippet>
  </search:result>
  <search:qtext>alabaster</search:qtext>
  <search:metrics>
    <search:query-resolution-time>PT1.052807S</search:query-resolution-time>
    <search:facet-resolution-time>PT0.000073S</search:facet-resolution-time>
    <search:snippet-resolution-time>PT0.080329S</search:snippet-resolution-time>
    <search:total-time>PT1.616547S</search:total-time>
  </search:metrics>
</search:response>
;
(:~
:   Feed search 
:
:   @param  $directory          is the directory to search (changed to collection in BF Db., ie. /resources/works/)
:   @param  $search-start       is start position
:   @param  $search-count       is number of hits to return
:   @return search:response as element
:)
declare function feed:search-feed(
    $directory as xs:string,
    $search-start as xs:integer,
    $search-count as xs:integer
    )
    as element(search:response)
{
    let $search-options :=       
        <options xmlns="http://marklogic.com/appservices/search">         
            <additional-query>{cts:collection-query($directory)}</additional-query>
             <sort-order type="xs:date" direction="descending">
                <search:element ns="info:lc/xq-modules/lcindex" name="mDate"/>
            </sort-order>
            <sort-order type="xs:date" direction="descending">
                <search:element ns="info:lc/xq-modules/lcindex" name="cDate"/>
            </sort-order>
			<transform-results apply="empty-snippet" />
			<return-metrics>{fn:false()}</return-metrics>
        </options>
    return search:search("",$search-options,$search-start,$search-count)
};
(:
feed based on director (names, subjects etc
field, (040a)
value (CMalG)

:)
declare function feed:search-advanced-feed(
    $directory as xs:string,
    $field as xs:string,
    $value as xs:string,
    $search-start as xs:integer,
    $search-count as xs:integer
    )
    as element(search:response)
{ 
let $opts:=("case-insensitive","diacritic-insensitive",    "punctuation-insensitive",   "wildcarded")
    
    let $search-options :=
    if (fn:contains($field,"subfield")) then (:mxe:d100_subfield_a means search this subfield, can use element-value-query :) 
        <options xmlns="http://marklogic.com/appservices/search">         
             <additional-query>{cts:collection-query($directory)}</additional-query>
             <additional-query>{cts:element-value-query( xs:QName( $field),$value,$opts)}</additional-query>
            <sort-order type="xs:date" direction="descending">
                <element ns="info:lc/xq-modules/lcindex" name="mDate"/>
            </sort-order>
            <sort-order type="xs:date" direction="descending">
                <element ns="info:lc/xq-modules/lcindex" name="cDate"/>
            </sort-order>
        </options>
        
        else (:mxe:datafield_100 means search all subfields, can't use element-value-query :)
        <options xmlns="http://marklogic.com/appservices/search">         
             <additional-query>{cts:collection-query($directory)}</additional-query>
             <additional-query>{cts:element-query( xs:QName( $field),$value)}</additional-query>
            <sort-order type="xs:date" direction="descending">
                <element ns="info:lc/xq-modules/lcindex" name="mDate"/>
            </sort-order>
            <sort-order type="xs:date" direction="descending">
                <element ns="info:lc/xq-modules/lcindex" name="cDate"/>
            </sort-order>
        </options>
        
    return
     search:search("",$search-options,$search-start,$search-count)

};
(: not used in BF database? see AtomPub.xqy :)
declare function feed:search-api-to-Atom($content as element(search:response), $query as xs:string) as element(atom:feed) {
    let $queryStr := 
        if ($content/search:qtext) then
            string($content/search:qtext)
        else
            $query
    let $dateTime := current-dateTime()
    return
        <atom:feed xmlns:atom="http://www.w3.org/2005/Atom">
            <atom:title>BIBFRAME LDS search results for: '{$queryStr}'</atom:title>
            <atom:updated>{$dateTime}</atom:updated>
            <atom:link rel="self" href="http://example.org/" type="application/atom+xml"/>
            <atom:id>info:lc/</atom:id>
            <atom:author>
                <atom:name>Library of Congress</atom:name>
                <atom:email>info@loc.gov</atom:email>
            </atom:author>
            {
                for $pt in $content/search:result
                let $uri := string($pt/@uri)                
                let $mets := doc($uri)/mets:mets
				let $edit:=string($mets//mets:metsHdr/@LASTMODDATE)
                let $mods := $mets//mods:mods
                let $objid := string($mets/@OBJID)
                let $idx := $mets/mets:dmdSec[@ID="index"]/mets:mdWrap[@MDTYPE="OTHER"]/mets:xmlData/idx:*
                let $display := $idx/idx:display
                let $link := concat("http://mlvlp04.loc.gov:8230/", $objid)
                let $id :=  $objid
                let $title := 
                    <a href="{$link}">                    
                    {
                        if (exists($display/idx:title)) then
                            string($display/idx:title)
                        else                                
                            normalize-space($mods/mods:titleInfo[not(@type)][1])
                    }
                    </a>
                let $creator := 
                    <span class="author">
                    {
                        if (exists($display/idx:mainCreator)) then
                            string($display/idx:mainCreator)
                        else
                            string($idx/idx:byName[1])
                    }
                    </span>
                let $publisher :=
                    <span class="publisher">
                    {
                        if (exists($display/idx:pubinfo)) then
                            string($display/idx:pubinfo)
                        else
                            string-join($mets/mets:dmdSec[@ID="dmd2"]/mets:mdWrap[@MDTYPE="MARC"]/mets:xmlData/mxe:record/mxe:datafield_260/child::*, " ")
                    }
                    </span>
				let $pubdate:=string($mets/mets:dmdSec[@ID="bibframe"]//bf:provisionActivity[1]/bf:ProvisionActivity[1]//bf:date[1])

				let $lccn :=
                    <span class="lccn">
                    {
                        if (exists($idx/idx:lccn)) then
                            string($idx/idx:lccn)
                        else
                            ()
                    }
                    </span>
                let $typeOfMaterial :=
                    <span class="format">
                    {
                        if (exists($display/idx:typeOfMaterial)) then
                            string($display/idx:typeOfMaterial) 
                        else if (exists($idx/idx:rdftype)) then
						 	string($idx/idx:rdftype[1])
						else
                            string($idx/idx:form[1])
                    }
                    </span>
                (:<div>Main Title: {$title}</div>:)
				let $html :=
                    (
                        <div xmlns="http://www.w3.org/1999/xhtml" class="details">                            
                            <div>Type of Material: {$typeOfMaterial}</div>
                            <div>Creator/Contributor: {$creator}</div>
                            <div>Published/Created: {$publisher}</div>
							<div>LCCN: {$lccn}</div>                         
                        </div>
                    )
                return
                    <atom:entry>
                        <atom:title>{$display/idx:title/string()}</atom:title>
						<atom:author><atom:name>{string($creator)}</atom:name></atom:author>
						<atom:category>{string($typeOfMaterial)}</atom:category>
                        <atom:updated>{$edit}</atom:updated>
						<atom:published>{$pubdate}</atom:published>
                        <atom:link href="{$link}"/>
                        <atom:id>{if ($lccn) then string($lccn) else $id}</atom:id>
                        <atom:summary  type="xhtml">{$html}</atom:summary>
                    </atom:entry>
            }
        </atom:feed>
};

declare function feed:mets-to-atom($content, $query as xs:string) as element(atom:feed) {
    let $queryStr := $query
    let $dateTime := current-dateTime()
    return
        <atom:feed xmlns:georss="http://www.georss.org/georss" xmlns:atom="http://www.w3.org/2005/Atom">
            <atom:title>bf database search results for: "{$queryStr}"</atom:title>
            <atom:updated>{$dateTime}</atom:updated>
            <atom:link rel="self" href="http://blah.org/" type="application/atom+xml"/>
            <atom:id>info:lc/blah</atom:id>
            <atom:author>
                <atom:name>Library of Congress</atom:name>
                <atom:email>info@loc.gov</atom:email>
            </atom:author>
            {
                for $mets in $content/mets:mets
                let $uri := xdmp:node-uri($mets)
                let $props := string($mets/mets:metsHdr/@LASTMODDATE)
                let $mets := doc($uri)/mets:mets
                let $mods := $mets//mods:mods
                let $objid := string($mets/@OBJID)
                let $idx := $mets/mets:dmdSec[@ID="IDX1"]/mets:mdWrap[@MDTYPE="OTHER"]/mets:xmlData/idx:indexTerms
                let $display := $idx/idx:display
                let $host-name := xdmp:host-name(xdmp:host())
                let $baseuri :=
                    if (contains($host-name, "mlvlp04")) then
                        $host-name
                    else
                        replace($host-name, "marklogic\d", "loccatalog", "m")
                let $link := concat("http://", $baseuri, "/", $objid)
                let $id := concat("info:lc/", $objid)
                let $title := 
                    <a href="{$link}">                    
                    {
                        if (exists($display/idx:title)) then
                            string($display/idx:title)
                        else                                
                            normalize-space($mods/mods:titleInfo[not(@type)][1])
                    }
                    </a>
                let $creator := 
                    <span class="author">
                    {
                        if (exists($display/idx:mainCreator)) then
                            string($display/idx:mainCreator[1])
                        else
                            string($idx/idx:byName[1])
                    }
                    </span>
                let $publisher :=
                    <span class="publisher">
                    {
                        if (exists($display/idx:pubinfo)) then
                            string($display/idx:pubinfo)
                        else
                            string-join($mets/mets:dmdSec[@ID="dmd2"]/mets:mdWrap[@MDTYPE="MARC"]/mets:xmlData/mxe2:record/mxe2:datafield_260/child::*, " ")
                    }
                    </span>
                let $typeOfMaterial :=
                    <span class="format">
                    {
                        if (exists($display/idx:typeOfMaterial)) then
                            string($display/idx:typeOfMaterial) 
                        else
                            string($idx/idx:form[1])
                    }
                    </span>
                let $html :=
                    (
                        <div xmlns="http://www.w3.org/1999/xhtml">
                            <div>Main Title: {$title}</div>
                            <div>Type of Material: {$typeOfMaterial}</div>
                            <div>Personal Name: {$creator}</div>
                            <div>Published/Created: {$publisher}</div>
                            <hr />
                        </div>
                    )
                return
                    <atom:entry>
                        <atom:title>{$display/idx:title/string()}</atom:title>
                        <atom:updated>{$props}</atom:updated>
                        <atom:link href="{$link}"/>
                        <atom:id>{$id}</atom:id>
                        <atom:summary type="xhtml">{$html}</atom:summary>
                    </atom:entry>
            }
        </atom:feed>
};

declare function feed:makeAtom($atom as element(atom:atom)) as element(atom:atom) {
    xdmp:xslt-invoke("/xslt/atom1_rss2.xsl", document {$atom}, map:map())
};