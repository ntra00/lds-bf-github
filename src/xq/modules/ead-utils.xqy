xquery version "1.0-ml";

module namespace utils = "info:lc/xq-modules/ead-utils";
import module namespace metsutil = "info:lc/xq-modules/mets-utils" at "mets-utils.xqy";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare  namespace idx="info:lc/xq-modules/lcindex";

declare function utils:check-digital-id($filename as xs:string) as xs:boolean {
    true()
};

declare function utils:get-dmdid($svcid as xs:string) as xs:string {
    let $mets := metsutil:mets($svcid)
    return $mets/mets:structMap[@LABEL='categories']//mets:div[@TYPE='overview']/mets:div[@TYPE='did']/@DMDID/string()
};

declare function utils:get-href($digID as xs:string) as xs:string {
    concat("/marklogic/ead.xqy?_xq=searchMfer02.xq&amp;_id=", $digID, "&amp;_faSection=overview&amp;_faSubsection=did&amp;_dmdid=", utils:get-dmdid($digID))
};

 
 