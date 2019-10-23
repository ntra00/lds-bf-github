xquery version "1.0-ml";

module namespace s = "info:lc/xq-modules/sru-utils";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
import module namespace search = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";
import module namespace marcutil = "info:lc/xq-modules/marc-utils" at "/xq/modules/marc-utils.xqy";
declare namespace sru = "http://docs.oasis-open.org/ns/search-ws/sruResponse";
declare namespace diag = "http://docs.oasis-open.org/ns/search-ws/diagnostic";
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace mxe2 = "http://www.loc.gov/mxe";
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace zr = "http://explain.z3950.org/dtd/2.1/";
declare namespace rel = "info:srw/extensions/2/rel-1.0";
declare namespace xsi = "http://www.w3.org/2001/XMLSchema-instance";
declare namespace mlhttp = "xdmp:http";


declare function s:cql($q as xs:string) as element(xcql) {
    let $cqluri := 'http://localhost:8675/exist/rest/db/cql/cql.xq?q='
    let $options := 
        <mlhttp:options>
            <mlhttp:authentication method="basic">
                <mlhttp:username>{xdmp:quote("natliba")}</mlhttp:username>
                <mlhttp:password>{xdmp:quote("natliba")}</mlhttp:password>
            </mlhttp:authentication>
         </mlhttp:options>
    let $uri := concat($cqluri, encode-for-uri($q))
    let $mycql := 
        try {
            xdmp:http-get($uri, $options)
        } catch ($exception) {
            $exception
        }
    let $cqlxml := $mycql[2]
    let $cqltext := $cqlxml/cqlResult/cql
    let $cqlxcql := $cqlxml/cqlResult/xcql
    return $cqlxcql
};

declare function s:searchRetrieve($op as xs:string, $ver as xs:string, $q as xs:string, $pack as xs:string?, $start as xs:string?, $max as xs:string?, $schema as xs:string?, $xpath as xs:string?, $sort as xs:string?, $ttl as xs:string?, $xsl as xs:string?, $ex as xs:string?, $facets as xs:string, $opts as element(search:options)) as element(sru:searchRetrieveResponse) {
    let $mymax :=
        if (xs:integer($max) gt 50) then
            "50"
        else
            $max
    let $search_config := xdmp:document-get("/marklogic/lcdemo/marklogic/searchConfig.xml")
    let $results_config := $search_config/search:wrapper/search:results-logic/search:options
    let $facets_config := $search_config/search:wrapper/search:facets-logic/search:options
    let $search_options :=
        if (count($opts/search:*) gt 0) then
            $opts
        else
            if (matches($facets, '(true|on|yes|1)', 'i')) then
                let $logic := 
                    <search:options>
                        {$facets_config/search:constraint}
                        <search:return-results>true</search:return-results>
                        <search:return-facets>true</search:return-facets>
                        {$facets_config/search:searchable-expression}
                    </search:options>
                return $logic
            else
                let $logic := $results_config
                return $logic
    let $longstart := $start cast as xs:unsignedLong
    let $longcount := $mymax cast as xs:unsignedLong
    let $mlsearch := search:search($q, $search_options, $longstart, $longcount)
    return
        s:serialize-searchapi($mlsearch, $ver, $schema, $pack, $longstart, $longcount)
};

declare function s:serialize-mets($hits as element(mets:mets)*, $ver as xs:string, $schema as xs:string, $pack as xs:string, $start as xs:integer, $mymax as xs:integer, $estimate as xs:integer) as element(sru:searchRetrieveResponse) {
        let $records :=
            for $rec at $i in $hits
            let $confidence := cts:confidence($rec)
            let $score := cts:score($rec)
            let $pct := concat(round-half-to-even(($confidence), 2) * 100, '%')
            let $mods := (:$rec/mets:dmdSec[@ID='dmd1']/mets:mdWrap[@MDTYPE='MODS']/mets:xmlData/mods:mods:) marcutil:mxe2-to-marcslim($rec/mets:dmdSec/mets:mdWrap[@MDTYPE='MARC']/mets:xmlData/mxe2:record)
            return 
                <sru:record>
                    <sru:recordSchema>{$schema}</sru:recordSchema>
                    <sru:recordPacking>{$pack}</sru:recordPacking>
                    <sru:recordData>
                    {
                        if ($pack eq 'string') then
                            xdmp:quote($mods)
                        else
                            $mods
                    }
                    </sru:recordData>
                    <sru:recordPosition>{$i}</sru:recordPosition>
                    <sru:extraRecordData>
                        <rel:percent>{$pct}</rel:percent>
                        <rel:score>{$score}</rel:score>
                        <rel:confidence>{$confidence}</rel:confidence>
                    </sru:extraRecordData>
                </sru:record>
        return
            <sru:searchRetrieveResponse xmlns="http://www.loc.gov/MARC21/slim" xmlns:rel="info:srw/extensions/2/rel-1.0" xmlns:sru="http://docs.oasis-open.org/ns/search-ws/sruResponse" xsi:schemaLocation="http://docs.oasis-open.org/ns/search-ws/sruResponse http://www.loc.gov/standards/sru/oasis/schemas/sruResponse.xsd http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
                <sru:version>{$ver}</sru:version>
                <sru:numberOfRecords>{$estimate}</sru:numberOfRecords>
                <sru:records>{$records}</sru:records>
                <sru:nextRecordPosition>{$start + $mymax}</sru:nextRecordPosition>
            </sru:searchRetrieveResponse>
};

declare function s:serialize-searchapi($hits as element(search:response), $ver as xs:string, $schema as xs:string, $pack as xs:string, $start as xs:integer, $mymax as xs:integer) as element(sru:searchRetrieveResponse) {
        let $records :=
            for $rec in $hits/search:result/@uri
            return 
                <sru:record>
                    <sru:recordSchema>{$schema}</sru:recordSchema>
                    <sru:recordPacking>{$pack}</sru:recordPacking>
                    <sru:recordData>
                    {
                      doc(string($rec))/mets:mets/mets:dmdSec[1]/mets:mdWrap/mets:xmlData/mods:mods 
                    }
                    </sru:recordData>
                </sru:record>
        return
            <sru:searchRetrieveResponse xmlns:sru="http://docs.oasis-open.org/ns/search-ws/sruResponse" xsi:schemaLocation="http://docs.oasis-open.org/ns/search-ws/sruResponse http://www.loc.gov/standards/sru/oasis/schemas/sruResponse.xsd http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
                <sru:version>{$ver}</sru:version>
                <sru:numberOfRecords>{data($hits/@total)}</sru:numberOfRecords>
                <sru:records>{$records}</sru:records>
                <sru:nextRecordPosition>{$start + $mymax}</sru:nextRecordPosition>
            </sru:searchRetrieveResponse>
};

declare function s:explain($op as xs:string, $ver as xs:string, $rp as xs:string, $xsl as xs:string?, $ex as xs:string?) as element(sru:explainResponse) {

    <sru:explainResponse xmlns:sru="http://www.loc.gov/zing/srw/">
     <sru:version>
         {$ver}
     </sru:version>
     <sru:record>
       <sru:recordPacking>
           {$rp}
       </sru:recordPacking>
       <sru:recordSchema>http://explain.z3950.org/dtd/2.0/</sru:recordSchema>
       <sru:recordData>
           <zr:explain xmlns:zr="http://explain.z3950.org/dtd/2.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://explain.z3950.org/dtd/2.0/ http://www.loc.gov/standards/sru/resources/zeerex-2.0.xsd">
             <zr:serverInfo protocol="SRU" version="1.2" transport="http" method="GET POST">
                <zr:host>marklogic1.loctest.gov</zr:host>
                <zr:port>8021</zr:port>
                <zr:database>sru</zr:database>
             </zr:serverInfo>
             <zr:databaseInfo>
               <zr:title lang="en" primary="true">MarkLogic SRU Gateway</zr:title>
               <zr:description lang="en" primary="true">The LC Demo database containing bibs and EADs.</zr:description>
             </zr:databaseInfo>
             <zr:indexInfo>
               <zr:set name="mods" identifier="info:srw/cql-context-set/1/mods-v3"/>
                <zr:index>
                  <zr:map>
                      <zr:name set="mods">titleInfo</zr:name>
                  </zr:map>
                </zr:index>
             </zr:indexInfo>
             <zr:schemaInfo>
                <zr:schema name="mods" identifier="info:srw/schema/1/mods-v3.3">
                  <zr:title>MODS version 3.3</zr:title>
                </zr:schema>
             </zr:schemaInfo>
             <zr:configInfo>
                <zr:default type="numberOfRecords">0</zr:default>
                <zr:setting type="maximumRecords">50</zr:setting>
                <zr:supports type="boolean"/>
                <zr:supports type="phrase"/>
                <zr:supports type="stemming"/>
                <zr:supports type="faceting"/>
             </zr:configInfo>
            </zr:explain>
       </sru:recordData>
     </sru:record>
    </sru:explainResponse>

};

declare function s:scan($op as xs:string, $ver as xs:string, $scan as xs:string, $respPos as xs:string?, $maxterms as xs:string?, $xsl as xs:string?, $extra as xs:string?) as element(sru:scanResponse) {

    <sru:scanResponse xmlns:sru="http://www.loc.gov/zing/srw/" xmlns:diag="http://www.loc.gov/zing/srw/diagnostic/" xmlns:mods="http://www.loc.gov/mods/v3">
        <sru:version>{$ver}</sru:version>
          <sru:terms>
            <sru:term>
              <sru:value>cartesian</sru:value>
              <sru:numberOfRecords>35645</sru:numberOfRecords>
              <sru:displayTerm>Carthesian</sru:displayTerm>
            </sru:term>
            <sru:term>
              <sru:value>carthesian</sru:value>
              <sru:numberOfRecords>2154</sru:numberOfRecords>
              <sru:displayTerm>Carthésian</sru:displayTerm>
            </sru:term>
            <sru:term>
              <sru:value>cat</sru:value>
              <sru:numberOfRecords>8739972</sru:numberOfRecords>
              <sru:displayTerm>Cat</sru:displayTerm>
            </sru:term>
            <sru:term>
              <sru:value>catholic</sru:value>
              <sru:numberOfRecords>35</sru:numberOfRecords>
              <sru:displayTerm>Catholic</sru:displayTerm>
              <sru:whereInList>last</sru:whereInList>
              <sru:extraTermData>
                <mods:mods>4456888</mods:mods>
              </sru:extraTermData>
            </sru:term>
          </sru:terms>
          <sru:echoedScanRequest>
            <sru:version>{$ver}</sru:version>
            <sru:scanClause>{$scan}</sru:scanClause> 
            <sru:responsePosition>{$respPos}</sru:responsePosition>
            <sru:maximumTerms>{$maxterms}</sru:maximumTerms>
            <sru:stylesheet>{$xsl}</sru:stylesheet>
          </sru:echoedScanRequest>
        </sru:scanResponse>

};(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)