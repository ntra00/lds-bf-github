xquery version "1.0-ml";

module namespace hold = "info:lc/xq-modules/holdings-utils";
import module namespace utils = "info:lc/xq-modules/mets-utils" at "/xq/modules/mets-utils.xqy";
import module namespace locs ="info:lc/xq-modules/config/lclocations" at "/xq/modules/config/lclocations.xqy";
import	module namespace index = "info:lc/xq-modules/index-utils" at "/xq/modules/index-utils.xqy";
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/lds/config.xqy";
	 

declare namespace idx="info:lc/xq-modules/lcindex" ;
declare namespace xhtml="http://www.w3.org/1999/xhtml" ;
declare namespace hld="http://www.indexdata.com/turbomarc" ;

declare default element namespace "http://www.loc.gov/holdings";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare function hold:lookup($bibid as xs:int) as element(bib)* {
    cts:search(collection("/lscoll/lcdb/holdings/")/bib, cts:element-range-query(xs:QName("bibid"), "=", $bibid))
};
declare function hold:lookup_erms($bibid as xs:int) as element(bib)* {
    cts:search(collection("/lscoll/erms/holdings/")/bib, cts:element-range-query(xs:QName("c004"), "=", $bibid))
};

declare function hold:display($uri as xs:string?, $status as xs:string ) as element(xhtml:div)* {

(: display holdings based on each 852; seems weird to base it on hte 852 instead of the whole record, but 852 is repeatable 
$erms: "erms" or "no" for lcdb 
:)
let $bibid:= tokenize($uri,"\.")[last()]
let $set:=tokenize($uri,"\.")[3] (:erms or lcdb:)
let $hostname :=  $cfg:DISPLAY-SUBDOMAIN
let $holdings:= if (not(matches($bibid, "^[A-Za-z]"))  ) then
				 	utils:hold-bib(xs:integer($bibid), $set) 
				 else ()
let $locs:=locs:locations()

let $current-statuses:=
	if ($status="yes") then
				xdmp:http-get(concat("http://lcweb2.loc.gov:8081/diglib/voyager/",$bibid,"/statuses"))[2]
	else ()

return 
    if (not($holdings/hld:r)) then		
        <div class="holdings" xmlns="http://www.w3.org/1999/xhtml">

        	<dt class="label">
            </dt>
            <dd class="bibdata">
            	<span class="noholdings">Library of Congress Holdings Information Not Available.</span>
            </dd>
        </div>
    else
        <div class="holdings" xmlns="http://www.w3.org/1999/xhtml">
        {for $d852 in $holdings/hld:r/hld:d852
			let $mfhd:= $d852/ancestor::hld:r/hld:c001/string()
            let $callno:=string-join($d852/*[local-name()!='s3'][local-name()!='sb'][local-name()!='st'][local-name()!='sx'][local-name()!='sz'],' ')
            let $callno-text:=
				if (starts-with($callno,"DLC ")) then
						substring-after($callno,"DLC ")
					else  if ($d852/hld:sh and normalize-space($callno)!='') then
		        		  $callno		
        	   else "Not Available"
            return        	   
        		(	<div class="hr">
        				<hr/>
        			</div>,
            		<dt class="label">Call Number</dt>,
            		<dd class="bibdata">
            			{$callno-text}
            			{for $sub in $d852/*[local-name()="st" or  local-name()="sz" or local-name()="s2"]
            				return (<br/>,$sub/string())
            			}		
            		</dd>,
               		if (not($d852/ancestor-or-self::hld:r/hld:d856)) then
               			(:<!-- suppress the "request in" field for online; that info is in item level locations, which we don't have,
               			plus it's online, so you request it by clicking on the 856 -->:)					
               			for $sb in $d852/hld:sb
               				let $this-location:=$sb/string()
               				return
               					(<dt class="label">Request in</dt>,
               					<dd class="bibdata">
               						{if ($sb/../hld:sh/string()='Electronic Resource') then "Online"
               						else if	 ($locs//locs:location[locs:code=$this-location]/locs:display) then
               								$locs//locs:location[locs:code=$this-location]/locs:display/string()
               							else
               								(: highlight holdings that should be suppressed: :)
               								<span class="noholdings">
               									{$this-location}
               								</span>
               						}
               				   </dd>)
               			else ()
               		,
               		 for $sub in $d852/ancestor::hld:r/*[local-name()="d866" or local-name()="d867"]
               			return (<dt class="label">
               					 {if ( $sub/self::*[local-name() = "d866"]) then
               						"Contains" 
               						else "Supplements"
               					 }</dt>,
               					 (:<dd>{concat($sub/hld:sz/string(),' ',$sub/hld:sa/string())}</dd>:)
								 <dd>{(string-join($sub//hld:sa," "),  string-join($sub//hld:sz," ") )}</dd>
								 )
               		 ,
               		 for $sub in $d852/ancestor::hld:r/hld:d868
               			return (<dt class="label">Older Receipts</dt>,
               					<dd>{$sub/hld:sa/string()}</dd>)
               		 ,
               		for $sub in $d852/ancestor::hld:r/hld:d856
               			return (<dt class="label">Links</dt>,
               					<dd class="bibdata">
               						<a href="{$sub/hld:su[1]/string()}" target="_new">
               							{if ($sub/hld:s3) then
               									$sub/hld:s3/string()
               								else
               									$sub/hld:su[1]/string()
               							}	
               						</a>
               						<br/>
               						{$sub/hld:sz/string()}
               					</dd>)
               		,
               		for $sub at $x in $d852/ancestor::hld:r/hld:d014
               			return	
               				if (normalize-space($sub/hld:sa)!= normalize-space($bibid) and $x!=1 ) then
               					(<dt class="label">Bound with</dt>,
               					<dd style="color:red">
               						<a href="{concat("http://",$hostname,$uri,$sub/hld:sa/string(),".html") }">
               							{$sub/hld:sa/string()}
               						</a>
               					</dd>)
               				else ()	
               		 ,     
               		for  $sub in $d852/ancestor::hld:r/hld:*[starts-with(local-name(),"d")
               		 and local-name()!= "d014" and local-name()!="d035" 
					 and local-name()!="d852" and local-name()!="d856" 
               		 and local-name()!="d866" and local-name()!="d867" and local-name()!="d868"  and local-name()!="d986"]
               			return ( (:temporarily red to highlight for users, to see if there might be a better label  :)
               					<dt class="label">Other</dt>,
               					<dd style="color:red">
               					{string-join($sub/hld:*,' ')}
               					</dd>)
       ,
	   if (exists($current-statuses) and $current-statuses//*:row[*:MFHD_ID = $mfhd]  and not(exists($d852/ancestor::hld:r/hld:d856))) then
	   		(: holdings with electronic links don't show status :)
	   		let $statii := string-join(distinct-values($current-statuses//*:row[*:MFHD_ID = $mfhd]//*:STATUS),'. ')
	   		return (<dt class="label">Status</dt>,
               					<dd style="color:red">
               					{$statii}.
               					</dd>)	   
		else ()
	    )			
	}			
  </div>
 
};
 (: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)