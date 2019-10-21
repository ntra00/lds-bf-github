xquery version "1.0-ml";
(: load-error-list.xqy takes $start, $chunk, $type
start= 1st error to report (default=1)
chunk = offset after start (default=500)
type= count or "all" or "unknowns" (default=count)
							

:)
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace marc = "http://www.loc.gov/MARC21/slim";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare namespace idx = "info:lc/xq-modules/lcindex";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace ctry = "info:lc/xmlns/codelist-v1";
declare namespace mat = "info:lc/xq-modules/config/materials";
declare namespace mxe = "http://www.loc.gov/mxe";

import module namespace utils = "info:lc/xq-modules/mets-utils" at "/xq/modules/mets-utils.xqy";
import module namespace marcutil = "info:lc/xq-modules/marc-utils" at "/xq/modules/marc-utils.xqy";
import module namespace functx = "http://www.functx.com" at "/xq/modules/functx.xqy";
import module namespace matconf = "info:lc/xq-modules/config/materials" at "/xq/modules/config/materialtype.xqy";
import module namespace langs = "info:lc/xq-modules/config/languages" at "/xq/modules/config/languages.xqy";
import module namespace relators = "info:lc/xq-modules/config/relators" at "/xq/modules/config/relators.xqy";
import module namespace lcc = "info:lc/xq-modules/config/lcclass" at "/xq/modules/config/lcc2.xqy";


declare function local:chars-001($arg as xs:string?) as xs:string* {       
   for $ch in string-to-codepoints($arg) return codepoints-to-string($ch)
};

declare function local:delete-empty-dirs($xmluri as xs:string) {
    let $uris := replace($xmluri, "/\d+\.xml", "/")
    let $contents := xdmp:directory-properties($uris, "1")
    let $c := string-length($uris) - 2
    let $parent := substring($uris, 1, $c)
    return
        if (count($contents) ge 1) then 
            xdmp:log(concat("Stopped deleting directories at ", $uris), "info")
        else if (count($contents) eq 0) then
            (xdmp:directory-delete($uris), xdmp:log(concat("Deleting directory ", $uris), "info"), local:delete-empty-dirs($parent))
        else
            ()
};




(: load errors, probably marcslim-to-mets()
:)
(:


cts:uri-match("/errors/lscoll/lcdb/bib/*")

:)
declare function local:reload($doc as element()) {

for $mrc in $doc/marc:record
	let $batch:="errorcleanup"
	let $sub := xdmp:get-request-header("X-LOC-Batch")
	let $recstatus := substring($mrc/marc:leader, 6, 1)
	let $resclean := normalize-space($mrc/marc:controlfield[@tag='001']/string())
	let $dirtox := local:chars-001($resclean)
	let $dest := "/lscoll/lcdb/bib/"
	let $permissions := (xdmp:permission("lc_read", "read"), xdmp:permission("lc_read", "execute"))
	let $mets := 
    	try {
        		marcutil:marcslim-to-mets($mrc)
		    } catch($e) {
        	$e
	    }
return
    if ($recstatus eq "d") then
        let $del := "/deleted"
        let $destination-root := concat($del, $dest)
        let $dir := concat($destination-root, string-join($dirtox, '/'), '/')
        let $destination-uri := concat($dir, $resclean, '.xml')
        let $destination-collections := ($destination-root, "/deleted/lscoll/", "/deleted/", "/deleted/lscoll/lcdb/")
        let $origxml := substring-after($destination-uri, $del)
        return
            try {
                    (
                        xdmp:document-insert($destination-uri, $mets, $permissions, $destination-collections), 
                        xdmp:log(concat($batch, "-", $sub, " : ", "Deleted record at: ", $destination-uri), "notice"), 
                        if (exists(doc($origxml))) then
                            (
                                xdmp:document-delete(substring-after($destination-uri, $del)), 
                                xdmp:log(concat("Deleting ", $destination-uri), "notice")
                            )
                        else
                            xdmp:log(concat("No record to delete at ", $origxml), "notice")
                    )
            } catch($e) {
                xdmp:log($e, "error")
            }
    else if ($mets instance of element(mets:mets)) then
        let $destination-root := $dest
        let $dir := concat($destination-root, string-join($dirtox, '/'), '/')
        let $destination-uri := concat($dir, $resclean, '.xml')
        let $destination-collections := ($destination-root, "/lscoll/lcdb/", "/lscoll/", "/catalog/", "/catalog/lscoll/", "/catalog/lscoll/lcdb/", "/catalog/lscoll/lcdb/bib/")
        return
            try {
                    (
                        xdmp:document-insert($destination-uri, $mets, $permissions, $destination-collections),
                        concat("Saving ", $destination-uri), 
                        if ($recstatus eq "n") then
                            xdmp:log(concat($batch, "-", $sub, " : ", "New record at: ", $destination-uri), "notice")
                        else if ($recstatus eq "c") then
                            xdmp:log(concat($batch, "-", $sub, " : ", "Changed record at: ", $destination-uri), "notice")
                        else if (matches($recstatus, "a|p")) then
                            xdmp:log(concat($batch, "-", $sub, " : ", "Increase in encoding level record at: ", $destination-uri), "notice")
                        else
                            xdmp:log(concat($batch, "-", $sub, " : ", "Unknown status record with code ", $recstatus, " at: ", $destination-uri), "notice")
                    )
            } catch($e) {
                xdmp:log($e, "error")
            }
    else if ($mets instance of element(error:error)) then
        let $era := concat("/errors", $dest, string-join($dirtox, ''), ".xml")
        return
            (
                xdmp:log($mets, "error"), 
                xdmp:log(concat($batch, "-", $sub, " : ", "Problem record at: ", $era), "notice"), 
                xdmp:document-insert($era, <error xmlns="http://marklogic.com/xdmp/error"><mets:metsHdr LASTMODDATE="{current-dateTime()}"/>{$mrc}</error>, $permissions, concat("/errors", $dest)),
                concat("Problem record at: ", $era)
            )
    else
        "Uh oh, unknown error, not error:error or mets:mets or deleted record from LDR/06"
};


declare variable $st as xs:string := xdmp:get-request-field("start","1");
declare variable $type as xs:string := xdmp:get-request-field("type","count"); (:(count, all, unknowns):)
declare variable $chk as xs:string := xdmp:get-request-field("chunk","500"); (:(count, all, unknowns):)
declare variable $sort as xs:string := xdmp:get-request-field("sort","problem"); (:(problem, leader, date):)
declare variable $reload as xs:string := xdmp:get-request-field("reload","no"); (:(problem, leader, date):)
let $set := cts:uri-match("/errors/lscoll/lcdb/bib/*")
let $start := if ($st  castable as xs:integer ) then $st cast as xs:integer  else 1  (: change these to external vars :) 
let $chunk := if ($chk castable as xs:integer) then $chk  cast as xs:integer else 500
 (: # to look at, from $start ... change these to external vars :) 


let $errorlist:=
    if ($type="count") then 
       ()
      else 
          for $item in $set[$start to ($start + $chunk - 1)] (:$item is error:error:)
		      let $doc := doc($item)
				let $time:=substring($doc//mets:metsHdr/@LASTMODDATE/string(),1,10)
		      let $lccn := normalize-space($doc//marc:datafield[@tag = "010"][1]/marc:subfield[@code = "a"]/string())
			  let $leader07:=substring($doc//marc:leader/string(),8,1)
			  let $leader:=$doc//marc:leader/string()
		      let $link :=  <span class="lccn">{
		                            if (string-length($lccn) > 3) then 
		                                <a href="http://lccn.loc.gov/{ $lccn }">{ $lccn } </a>
		                            else 
		                                $lccn
		                            }
		                        </span>
		      let $bib := <span class="bibid">{ $doc//marc:controlfield[@tag = "001"]/string() }</span>
		      let $prob:=
		             if ($doc//marc:datafield[@tag = "006" or @tag = "007"]  ) then
		                   "006/007 is datafield, not controlfield"
		             else if ( $doc//marc:subfield[not(matches(@code,"[a-z0-9]"))] ) then								 
		                 "subfield code is invalid" 
		             else if ($doc//marc:datafield[not(matches(@tag,'^[0-9]+$'))]) then              
		                        "tag is nonnumeric:"
		             else if ($doc//marc:datafield[contains(@ind1,'*') or contains(@ind2,'*')]  ) then              
		                       "ind is *"
					 else if( $doc//marc:datafield[@tag = "010"]/marc:subfield[@code = "a"][2] ) then
									"multiple lccns in 010"
					 else if( $doc//marc:datafield[@tag = "245"][2]) then
					          		"multiple titles in 245s"
					 else if( $doc//marc:datafield[@tag = "100"][2]) then
					          		"multiple authors in 100"
					 else if( not($doc//marc:controlfield[@tag = "001"] )) then
					          		"No 001"
		             else if ($lccn="") then
						"no lccn"
					 else ()
            
		        let $tag:= 
		             if ( $doc//marc:subfield[not(matches(@code,"[a-z0-9]"))])  then
		                             <span class="tag">{ $doc//marc:subfield[not(matches(@code,"[a-z0-9]"))]/parent::marc:datafield/@tag/string() }</span>
						 else if ($doc//marc:datafield[not(matches(@tag,'^[0-9]+$'))]) then              
		                        $doc//marc:datafield[not(matches(@tag,'^[0-9]+$'))]/@tag/string()
		              else ()

		        return              (:to $$errorlist:)
		             if ( $type!="unknowns" and exists($prob) ) then
		                     <tr>
								<td>{$time}</td>
		                       <td>{ $link }</td>
		                       <td>{ $bib }</td>
							   <td>{ if ($leader07="s") then "serial" else if ($leader07="b") then "serial component" else "mono"} </td>                
		                       <td>  <span class="problem">{$prob}</span> </td>
		                           <td>  { $tag }</td>
								   <td>&#160;</td>

		                     </tr>
		             else if ( $type="unknowns" and exists($prob) ) then (: don't report prob if user only wants unknowns:)
		                        ()                        (:<li>known error: {$bib}</li>:)
		             else (:type=unknowns and prob exists, so :)
		                      <tr>
								<td>{$time}</td>
		                       <td> { $link }</td>
		                       <td> { $bib }   </td>  
							   <td>{ if ($leader07="s") then "serial" else if ($leader07="b") then "serial component" else "mono"} </td>                
								   <td><span class="problem">unknown</span>
									<br/>
									{if ( marcutil:marcslim-to-mets( doc($item)//marc:record ) instance of element(error:error) ) then
								  		marcutil:marcslim-to-mets( doc($item)//marc:record )
								   	else
								   		<span class="noerror" style="font-weight:bold;color:red;" uri="/errors/lscoll/lcdb/bib/{$bib/string()}">No errors if loaded now.</span>
									}</td>
								   <td>unknown</td>
								   <td>
								   <span class="uri">/errors/lscoll/lcdb/bib/{$bib/string()}.xml</span><br/>
									<span class="title">{ doc($item)//mods:titleInfo/string()} </span>         </td>                            
		                      </tr>

            return 
				<html xmlns="http://www.w3.org/1999/xhtml">
						<body><h1>Errors loading records from lcdb</h1>
						<h2>sorted by {$sort}</h2>
						<div>
							<table border="1">
<tr>
							<td colspan="7">Errors:{ count($set) }</td>
						</tr>
								<tr>
										<th width="10%">Date {if ($sort!='date') then <a href="/xq/load-error-list.xqy?type=all&amp;sort=date">sort</a> else()}</th>
										<th width="10%">LCCN Permalink</th>
										<th width="9%">Bib ID</th>
										<th width="5%">Leader {if ($sort!='leader') then <a href="/xq/load-error-list.xqy?type=all&amp;sort=leader">sort</a> else()}</th>
										<th width="20%">Problem {if ($sort!='problem') then <a href="/xq/load-error-list.xqy?type=all&amp;sort=problem">sort</a> else()}</th>
										<th width="5%">Tag</th>
										<th width="41%">Record</th>

						</tr>
						{ if ($sort="problem") then
									for $row in $errorlist
										 order by $row/*:td[5]/string(),$row/*:td[2]/string()		
										  return $row
								else
									if ($sort="leader") then
										for $row in $errorlist
											 order by $row/*:td[4]/string(),$row/*:td[5]/string()
											  return $row
else (:date:)
for $row in $errorlist
									 order by $row/*:td[1]/string(),$row/*:td[2]/string()
									  return $row

							}
					</table></div>
<div class="reload">
<ul>
{for $row in $errorlist//*:span[@class='noerror']
	let $bib:=tokenize($row/@uri/string(),"/")[last()]
	return (<li>xdmp:save( "/marklogic/sitemaps/loc.natlib.lcdb.{$bib}.xml",doc("{$row/@uri/string()}.xml"))</li>,
			if (reload="yes") then local:reload(doc("{$row/@uri/string()}.xml")) else ()
			)
}
</ul>
</div>
</body></html>

