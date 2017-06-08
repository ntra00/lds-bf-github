xquery version "1.0-ml";
(: cribbed from ingest-voyager-bib to load ia book records

calculate json files array for idx:files[noindex]
 :)

import module namespace marcutil = "info:lc/xq-modules/marc-utils" at "/xq/modules/marc-utils.xqy";
import module namespace utils = "info:lc/xq-modules/mets-utils" at "/xq/modules/mets-utils.xqy";
import module namespace mem = "http://xqdev.com/in-mem-update" at "/xq/modules/in-mem-update.xqy";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace marc = "http://www.loc.gov/MARC21/slim";
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace idx="info:lc/xq-modules/lcindex";
declare namespace mxe = "http://www.loc.gov/mxe";
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace split = "http://xmltwig.com/xml_split";
declare namespace error = "http://marklogic.com/xdmp/error";
declare namespace djvu = "http://www.loc.gov/djvu";

declare variable $body := xdmp:get-request-body("xml")/node();

let $batch:= "IA Books update"
let $href:=$body//mets:file[1]/mets:FLocat/@xlink:href/string()
 (:$href = "/media/loc.natlib.ia.10000551_00091594870/0001.tif":)
 

let $uri:= substring-before(tokenize($href,'/')[3],'_')
	(:concat('loc',substring-before(substring-after($href,'/loc'),'_')
						):)
let $bib-uri:=concat('loc.natlib.lcdb.',tokenize($uri,'\.')[4])

let $volumes:=distinct-values($body//mets:file/@GROUPID/string())
let $bibmets:=<mets:mets OBJID="{$uri}">{utils:mets($bib-uri)//mets:dmdSec}</mets:mets> 
let $bibmets:= mem:node-replace($bibmets//mods:recordInfo[1]/mods:recordIdentifier[1],<mods:recordIdentifier>{$uri}</mods:recordIdentifier>)

(:let $mods:=$bibmets//mods:mods
let $mxe:=$bibmets//mxe:record:)
(:refresh idx from the original bib version :)
(:can't calculate idx:files using the idx program, because it's based on getting the content from the stored doc
have to send it the mets we have:)
(:mets has to be fully formed before we get the json list; bibmets is only the bib data.....:)


(: Transform original DjVu XML into the different XML chunks we need :)
let $text_dmd :=
    <mets:dmdSec ID="IA1">
        <mets:mdWrap MDTYPE="OTHER">
            <mets:xmlData>
                {for $xmldata in $body//djvu:PAGECOLUMN
                return 
                <PAGECOLUMN n="{$xmldata/@n/string()}" id="{$uri}_{$xmldata/@n/string()}">
                    { for $word in $xmldata/djvu:WORD
                    return
                    normalize-space($word/text())
                    }
                </PAGECOLUMN>
                }
            </mets:xmlData>
        </mets:mdWrap>
    </mets:dmdSec>
  
let $djvuset :=
    <DjVuXMLSet xmlns="http://www.loc.gov/djvu">
       {for $metsfile in $body//mets:file
        return
            <PAGECOLUMN n="{$metsfile//djvu:PAGECOLUMN/@n/string()}" gid="{$metsfile/@GROUPID/string()}" id="{$metsfile/@GROUPID/string()}_{$metsfile/@ID/string()}">
            { for $word in $metsfile//djvu:WORD
                return
                    <WORD>
                        {$word/text()}
                        <noindex_ia xmlns="info:lc/xq-modules/noindex">
                        <x>{$word/@x/string()}</x>
                        <y>{$word/@y/string()}</y>
                        <width>{$word/@width/string()}</width>
                        <height>{$word/@height/string()}</height>
                    </noindex_ia>
                    </WORD>
            }
            </PAGECOLUMN>
        }
    </DjVuXMLSet>

let  $mets:=
<mets:mets PROFILE="lc:printMaterial" OBJID="{$uri}" 
		xsi:schemaLocation="http://www.loc.gov/METS/ http://www.loc.gov/standards/mets/mets.xsd http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd" xmlns:mxe="http://www.loc.gov/mxe" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:lc="http://www.loc.gov/mets/profiles/" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:bibRecord="http://www.loc.gov/mets/profiles/bibRecord" xmlns:mets="http://www.loc.gov/METS/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
		xmlns:idx="info:lc/xq-modules/lcindex">
	<mets:metsHdr LASTMODDATE="{current-dateTime()}"/>
	{$bibmets//mets:dmdSec}
	{$text_dmd}
	<mets:structMap>
			<mets:div DMDID="dmd1 dmd2 IDX1" TYPE="pm:printMaterial">
				{ for $volume in $volumes 
					return
					 <mets:div TYPE="pm:volume" ID="{$volume}">
					    {for $file in $body//mets:file[@GROUPID=$volume]
					 		return 
							 <mets:div TYPE="pm:page">
								<mets:fptr FILEID="{$file/@ID/string()}"/>
							</mets:div>
						 }
					 </mets:div>
				}
			</mets:div>
	</mets:structMap>
	<mets:fileSec>{xdmp:xslt-invoke('/xslt/ia/createFileGrp.xsl',$body)}</mets:fileSec>
</mets:mets>
let $files:=    
        <idx:files format="json"><noindex xmlns="info:lc/xq-modules/noindex">{utils:mets-files2($mets,"json","all")}</noindex></idx:files>			  	

let $newidx:=  
	<mets:dmdSec ID="IDX1">
        <mets:mdWrap MDTYPE="OTHER">
            <mets:xmlData>
				{marcutil:mods-to-idx($mets//mods:mods, $mets//mxe:record )}
			</mets:xmlData>
		</mets:mdWrap>
	</mets:dmdSec>
	
	let $newidx:= mem:node-insert-after($newidx//idx:display,$files)
	let $mets:= mem:node-replace($mets//mets:dmdSec[@ID="IDX1"],$newidx)

let $dest:="/lscoll/fulltext/ia/"
  let $destination-uri:=concat($dest,  $uri, '.xml')                       
		let $destination-collections := ($dest, "/lscoll/fulltext/", "/lscoll/") (:, "/catalog/") don't include catalog:)        
		let $permissions := (xdmp:permission("lc_read", "read"), xdmp:permission("lc_read", "execute"))

    return 
	 if ($mets instance of element(mets:mets)) then        
(:store all at root( of /lscoll/ia :)
        (: $dest = /lscoll/fulltext/ added /ia/ in case we add other full text :)
        
      
		
		(: For separate file with word coordinates :)
		let $djvu_dest := '/lscoll/fulltext/ia/djvu/'
		let $djvu_destination-uri:=concat($djvu_dest,  $uri, '.xml')                       
		(:let $djvu_destination-collections := ($djvu_dest):)
		
		return 

            try {
                    (
                        xdmp:document-insert($destination-uri, $mets,   $permissions , $destination-collections),                            
							xdmp:log(concat($batch, " : ", "New IABooks record at: ", $destination-uri) ,"notice"),
					    
					    xdmp:document-insert($djvu_destination-uri, $djvuset, $permissions, $djvu_dest),                            
							xdmp:log(concat($batch, " : ", "New IABooks DjVuXMLSet record at: ", $djvu_destination-uri) ,"notice")
                    )
            } catch($e) {
                xdmp:log($e, "error")
            }

    else if ($mets instance of element(error:error)) then
       let $era := concat("/errors", $dest, $uri, ".xml")
        return
            (
                xdmp:log($mets, "error"), 
                xdmp:log(concat($batch,  " : ", "Problem record at: ", $era), "notice"),
                xdmp:document-insert($era, <error xmlns="http://marklogic.com/xdmp/error"><mets:metsHdr LASTMODDATE="{current-dateTime()}"/></error>, $permissions, concat("/errors", $dest)),
                
                concat("Problem record at: ", $era)
            )
    else ($uri, 
        "-Uh oh, unknown error, not error:error or mets:mets or deleted record from LDR/06")
