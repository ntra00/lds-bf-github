xquery version "1.0-ml";

(: Contains functions to convert between mxe and marcxml, etc. :)

module namespace marcutil = "info:lc/xq-modules/marc-utils";
import module namespace index="info:lc/xq-modules/index-utils" at "/src/xq/modules/index-utils.xqy";
import module namespace xslt="info:lc/xq-modules/xslt" at "/xq/modules/xslt.xqy";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.loc.gov/MARC21/slim";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace marc = "http://www.loc.gov/MARC21/slim";
declare namespace mxe = "http://www.loc.gov/mxe";
declare namespace mxe1 = "mxens";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace idx="info:lc/xq-modules/lcindex";
declare namespace ead="urn:isbn:1-931666-22-9";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skos="http://www.w3.org/2004/02/skos/core#";
declare namespace ctry="info:lc/xmlns/codelist-v1";
declare namespace xdmp="http://marklogic.com/xdmp";

declare function marcutil:char2element($string as xs:string, $prefix as xs:string) as node()+ {
    let $cps := string-to-codepoints($string)
    for $cp at $count in $cps
    let $cpe := if ($count < 11) then (concat('0', $count -1)) else ($count -1)
    let $char := codepoints-to-string($cp)
    return 
        element {concat('mxe:', $prefix, '_cp', $cpe)}
            {$char}
};


declare function marcutil:marcslim-to-mxe1($marcslim as element(marc:record)) as element(mxe1:record) {
    <mxe1:record>
      <mxe1:leader>{data($marcslim/leader)}</mxe1:leader>
       {
       for $controlfield in $marcslim/controlfield
       return
       element {concat('mxe1:controlfield_', $controlfield/@tag)}{data($controlfield)}
       }
    
       {
       for $datafield in $marcslim/datafield
       return
       element {concat('mxe1:datafield_', $datafield/@tag)}
         {attribute {'ind1'} {$datafield/@ind1}, attribute {'ind2'} {$datafield/@ind2},
    
          for $subfield in $datafield/subfield
          return
          element {concat('mxe1:subfield_', $subfield/@code)}{data($subfield)}
         }
       }
    </mxe1:record>
};




declare function marcutil:marcslim-to-mxe2($marcslim as element(marc:record)) as element(mxe:record) {
try {

let $leader := $marcslim/leader
let $c001 := $marcslim/controlfield[@tag='001']
let $c003 := $marcslim/controlfield[@tag='003']
let $c005 := $marcslim/controlfield[@tag='005']
let $c007 := $marcslim/controlfield[@tag='007']
let $c008 := $marcslim/controlfield[@tag='008']
return

    <mxe:record>
     <mxe:leader>{marcutil:char2element(data($leader), 'leader')}</mxe:leader>
     <mxe:controlfield_001>{data($c001)}</mxe:controlfield_001>
      {
       if ($c003)
       then
       (
        <mxe:controlfield_003>{data($c003)}</mxe:controlfield_003>
       )
       else ()
      }
    
      {
       if ($c005)
       then
       (
        <mxe:controlfield_005>{data($c005)}</mxe:controlfield_005>
       )
       else ()
      }
    
      {
       if ($c007)
       then
       (
        for $c in $c007
        return
        <mxe:controlfield_007>{marcutil:char2element(data($c), 'c007')}</mxe:controlfield_007>
       )
       else ()
      }
    
      {
       if ($c008)
       then
       (
        <mxe:controlfield_008>{marcutil:char2element(data($c008), 'c008')}</mxe:controlfield_008>
       )
       else ()
      }
    
    
       {
       for $datafield in $marcslim/datafield
       return
       element {concat('mxe:datafield_', $datafield/@tag)}
         {attribute {'ind1'} {$datafield/@ind1}, attribute {'ind2'} {$datafield/@ind2},
    
          for $subfield in $datafield/subfield
          return
          element {concat('mxe:', 'd', $datafield/@tag, '_subfield_', $subfield/@code)}{data($subfield)}
         }
       }       
    </mxe:record>
	}
	catch($e){<mxe:record>Conversion Error </mxe:record>}
};

declare function marcutil:mxe1-to-marcslim($mxe1 as element(mxe1:record)) as element(marc:record) {
    <marc:record> {
        let $elements := $mxe1/mxe1:*
        for $element in $elements
        let $name := local-name($element)
        return 
        if (matches($name, 'leader'))
          then
          (<marc:leader>{data($element)}</marc:leader>)
          else if (matches($name, 'controlfield'))
            then
            (<marc:controlfield tag="{substring-after($name, '_')}">{data($element)}</marc:controlfield>)
            else if (matches($name, 'datafield'))
              then
              (<marc:datafield tag="{substring-after($name, '_')}" ind1="{data($element/@ind1)}" ind2="{data($element/@ind2)}">
               {
                let $subfields := $element/mxe1:*
                for $subfield in $subfields
                let $name := local-name($subfield)
                return 
                <marc:subfield code="{substring-after($name, '_')}">{data($subfield)}</marc:subfield>	 
               }
               </marc:datafield>
              )
              else ()
    }
    </marc:record>
};



(: start marcslim-to-mods-xslt function :)
declare function marcutil:marcslim-to-mods-xslt($marcslim as element(marc:record)) as element(mods:mods) {
    let $params := <parameters><param name="title" value="Nate"/><param name="thing" value="I am feeling tired!"/></parameters>
    let $lc_centric := "/config/MARC21slim2MODS3-3HldgsML.xsl"
    let $modsPrefix := "/db/xslt/modsPrefix.xsl"
    let $httpmods := xslt:transform($marcslim, $lc_centric, $params)
    let $mods := $httpmods/mods:mods
    let $httpmodsPre :=  xslt:transform($mods, $modsPrefix, $params)
    return
        $httpmodsPre/mods:mods
};
declare function marcutil:marc-to-srwdc($marcslim )  {
let $srwStyle:= "/config/MARC21slim2SRWDC.xsl"
return 
        try { 
                xdmp:xslt-invoke($srwStyle,document{$marcslim})                
        	   } 
        catch ($exception) {
            	<error>{$exception}</error>
             }
  
};

(: start mods-to-idx :)

(: start marcslim-to-mods function :)
(: 1/5/2011 nate moved this into index to allow changes to only the index module with each version:)
declare function marcutil:mods-to-idx ($mods as element(), $mxe as element(), $uri as xs:string)  as element()
{
index:mods-to-idx ($mods , $mxe,$uri ) 

};


(: start marcslim-to-mets :)
declare function marcutil:marcslim-to-mets($marcslim as element(marc:record)) as element(mets:mets) {
    let $mods := $marcslim/mods:mods
    let $mxe := marcutil:marcslim-to-mxe2($marcslim)
    let $id := $mxe/mxe:controlfield_001
	let $uri:=concat("loc.natlib.lcdb.",data($id))
    let $idx := marcutil:mods-to-idx($mods, $mxe, $uri)    
    return 
        <mets:mets PROFILE="lc:bibRecord" OBJID="{$uri}" xsi:schemaLocation="http://www.loc.gov/METS/ http://www.loc.gov/standards/mets/mets.xsd http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd" xmlns:mxe="http://www.loc.gov/mxe" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:lc="http://www.loc.gov/mets/profiles/" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:bibRecord="http://www.loc.gov/mets/profiles/bibRecord" xmlns:mets="http://www.loc.gov/METS/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:idx="info:lc/xq-modules/lcindex">
	    <mets:metsHdr LASTMODDATE="{current-dateTime()}"/>
            <mets:dmdSec ID="dmd1">
                <mets:mdWrap MDTYPE="MODS">
                    <mets:xmlData>
                        {$mods}
                    </mets:xmlData>
                </mets:mdWrap>
            </mets:dmdSec>
            <mets:dmdSec ID="dmd2">
                <mets:mdWrap MDTYPE="MARC">
                    <mets:xmlData>
                        {$mxe}	    
                    </mets:xmlData>
                </mets:mdWrap>
            </mets:dmdSec>    
            <mets:dmdSec ID="IDX1">
                <mets:mdWrap MDTYPE="OTHER">
                    <mets:xmlData>
                        {$idx}
                    </mets:xmlData>
                </mets:mdWrap>
            </mets:dmdSec>    
            <mets:structMap>
                <mets:div TYPE="bib:bibRecord" DMDID="dmd1 dmd2 IDX1"/>
            </mets:structMap>
        </mets:mets>
};
declare function marcutil:ermsmarc-to-mets($marcslim as element(marc:record), $uri as xs:string) as element(mets:mets) {
    let $mods := $marcslim/mods:mods

    let $mxe := marcutil:marcslim-to-mxe2($marcslim)
let $rights:=$marcslim//mets:amdSec
    let $idx := marcutil:mods-to-idx($mods, $mxe, $uri)
    (:erms bibs have 035a[1] as  .b[bibid], 001 contains ssj# suitable for permalink but not uri/objid:)
    (:let $id := $mxe/mxe:controlfield_001:)    
(:    let $id:= substring-after($mxe/mxe:datafield_035[1]/mxe:d035_subfield_a/string(),'.b'):)
let $object-type:=if (matches($uri,"^loc\.natlib\.erms\.e.+$")) then
	"lc:ermsResourceRecord"
else
	"lc:ermsBibRecord"
let $mets:= 
<wrap><mets:metsHdr LASTMODDATE="{current-dateTime()}"/>
            <mets:dmdSec ID="dmd1">
                <mets:mdWrap MDTYPE="MODS">
                    <mets:xmlData>
                        {$mods}
                    </mets:xmlData>
                </mets:mdWrap>
            </mets:dmdSec>
            <mets:dmdSec ID="dmd2">
                <mets:mdWrap MDTYPE="MARC">
                    <mets:xmlData>
                        {$mxe}	    
                    </mets:xmlData>
                </mets:mdWrap>
            </mets:dmdSec>    
            <mets:dmdSec ID="IDX1">
                <mets:mdWrap MDTYPE="OTHER">
                    <mets:xmlData>
                        {$idx}
                    </mets:xmlData>
                </mets:mdWrap>
            </mets:dmdSec> 
{$rights}   
</wrap>
return 
if (matches($uri,"^loc\.natlib\.erms\.e.+$")) then
       <mets:mets PROFILE="lc:ermsResourceRecord" xmlns:bib="http://www.loc.gov/mets/profiles/ermsResourceRecord" OBJID="{$uri}" xsi:schemaLocation="http://www.loc.gov/METS/ http://www.loc.gov/standards/mets/mets.xsd http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd" xmlns:mxe="http://www.loc.gov/mxe" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:lc="http://www.loc.gov/mets/profiles/" xmlns:mods="http://www.loc.gov/mods/v3"  xmlns:mets="http://www.loc.gov/METS/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:idx="info:lc/xq-modules/lcindex"
xmlns:rights="http://www.loc.gov/rights/">
			{$mets/*}	    
            <mets:structMap>
                <mets:div TYPE="bib:ermsResourceRecord" DMDID="dmd1 dmd2 IDX1"/>
            </mets:structMap>
        </mets:mets>
else
   <mets:mets PROFILE="lc:ermsBibRecord" xmlns:bib="http://www.loc.gov/mets/profiles/ermsBibRecord" OBJID="{$uri}" xsi:schemaLocation="http://www.loc.gov/METS/ http://www.loc.gov/standards/mets/mets.xsd http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd" xmlns:mxe="http://www.loc.gov/mxe" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:lc="http://www.loc.gov/mets/profiles/" xmlns:mods="http://www.loc.gov/mods/v3"  xmlns:mets="http://www.loc.gov/METS/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:idx="info:lc/xq-modules/lcindex"
xmlns:rights="http://www.loc.gov/rights/" >
			{$mets/*}	    
            <mets:structMap>
                <mets:div TYPE="bib:ermsBibRecord" DMDID="dmd1 dmd2 IDX1"/>
            </mets:structMap>
        </mets:mets>

};

(: mxe2-to-marcslim :)

declare function marcutil:mxe2-to-marcslim($mxe2 as element(mxe:record)) as element(record) {
    <record> {
        let $elements := $mxe2/mxe:*
        for $element in $elements
        let $name := local-name($element)
        return
        if (matches($name, 'leader'))
          then
          
          (

          <leader>
	  {string-join($element/*, '')}
           </leader>

          )


          else if (matches($name, 'controlfield'))
            then
            (if ($element/*) then (<controlfield tag="{substring-after($name, '_')}">{string-join($element/*, '')}</controlfield>) else (<controlfield tag="{substring-after($name, '_')}">{data($element)}</controlfield>))


            else if (matches($name, 'datafield'))
              then
              (<datafield tag="{substring-after($name, '_')}" ind1="{data($element/@ind1)}" ind2="{data($element/@ind2)}">
               {
                let $subfields := $element/mxe:*
                for $subfield in $subfields
                let $name := local-name($subfield)
                return
                <subfield code="{substring-after($name, 'subfield_')}">{data($subfield)}</subfield>       
               }
               </datafield>
              )
              else ()
    }
    </record>
};
(:--------------------------------------------------------
Function to turn marcslim subfields into strings with <strong> for codes .
Usage: strip out the <sub> wrapper and display in a <td> tag
:)
declare function marcutil:getSubfields($datafields  )  {

for $subfield in $datafields/marc:subfield
  return 
  	<sub>
  		<strong>{string($subfield/@code)}</strong>{$subfield/text()}
	</sub>

};

(:--------------------------------------------------------
Function to take any marcslim data and display as an html table
To a given document's mxe record and display as html with marc tags:
  declare variable $id as xs:string() ....
  let  $q:=doc("loc.natlib.lcdb.12037148.xml")//mxe:record (mxe1)
  let  $z:=xdmp:http-get("http://lcweb2.loc.gov/diglib/ihas/loc.natlib.gottlieb.14331/mets.xml")[2]//mxe:record
(mxe2)
	let $x:= marcutil:mxe1-to-marcslim($q)
	let $a:= marcutil:marcslim2HTML($x)
	return 
		<html>
			<body> {$a}</body>
		</html>
:)
declare function marcutil:marcslim2HTML($marcslim as element() ) as element() {
let $controls:=
  for $c in $marcslim/marc:controlfield
   return 
		<tr>
		  <th nowrap="true" align="right" valign="top">{string($c/@tag)}</th>
		  <td>{string($c)}</td>
		</tr>

let $datafields:=
  for $data in $marcslim/marc:datafield
   return 
		<tr>
		  	<th nowrap="true" align="right" valign="top">{string($data/@tag)}</th>
			<td>
			{string($data/@ind1)}
			{string($data/@ind2)}
				{ for $sub in marcutil:getSubfields($data)
					return ($sub/*, $sub/text())}
			</td>
		</tr>

return
<table>
	<tr>
		<th nowrap="true" align="right" valign="top">000</th>
		<td>
		{string($marcslim/marc:leader)}
		</td>
	</tr>
	{$controls}
	{$datafields}
</table>

};
(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)