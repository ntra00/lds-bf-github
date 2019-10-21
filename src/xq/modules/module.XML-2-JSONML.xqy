xquery version "1.0";

(:
:   Module Name: XML 2 JSON
:
:   Module Version: 1.0
:
:   Date: 2012 July 2
:
:   Copyright: Public Domain
:
:   Proprietary XQuery Extensions Used: none
:
:   Xquery Specification: January 2007
:
:   Module Overview:    Will attempt to take arbitrary XML and 
:       generate JSONML from it per the syntax expressed here:
        http://www.jsonml.org/syntax/ .
:
:)
   
(:~
:   Attempts to take arbitrary XML and 
:   generate JSONML from it per the syntax expressed here:
:   http://www.jsonml.org/syntax/ 
:
:   @author Kevin Ford (kefo@loc.gov)
:   @since July 2, 2012
:   @version 1.0
:)

module namespace xml2jsonml = 'info:lc/id-modules/xml2jsonml#';


(:~
:   This is the main function.  Takes XML and converts
:   it to JSON. 
:
:   @param  $xml         node() is the XML
:   @return xs:string       javascript
:)
declare function xml2jsonml:xml2jsonml
        ($xml) 
        as xs:string
{
    let $xml := 
        (: if (fn:namespace-uri($xml[1]) eq "http://www.w3.org/2005/Atom") then :)
            (: xdmp:http-get("http://rs5.loc.gov/findingaids/master/mss/eadxmlmss/2007/ms007005.xml")[2]/child::node()[fn:name()][1] :)
            (: xdmp:document-get("http://localhost:8281/authorities/subjects/sh94009583.rdf", 
                    <options xmlns="xdmp:document-get">
                        <format>xml</format>
                    </options>)/child::node() :)
            (: xdmp:http-get("http://localhost:8281/search/?q=dogs&amp;format=atom")[2]/child::node()[1] :)
            (: xdmp:http-get("http://lcweb2.loc.gov/diglib/ihas/loc.natlib.ihas.200033293/mods.xml")[2]/child::node()[fn:name()][1] :)
            (: xdmp:http-get("http://lcweb2.loc.gov/diglib/ihas/loc.natlib.ihas.200033293/mets.xml")[2]/child::node()[fn:name()][1] :)
        (: else :)
            $xml

    let $json := xml2jsonml:process-node($xml)
    return fn:string-join($json, ",
    ")

};

(:~
:   This function is called recursively, processing each node 
:   in turn. 
:
:   @param  $xml         node() is the XML
:   @return xs:string       javascript
:)
declare function xml2jsonml:process-node($n)
{
    
    let $nodename := fn:name($n)
    
    let $xmlnsprefix := fn:prefix-from-QName(fn:node-name($n))
    let $xmlnsprefix := 
        if ($xmlnsprefix != "") then
            fn:concat("xmlns:" , $xmlnsprefix)
        else
            "xmlns"
            
    let $xmlns := fn:namespace-uri-from-QName(fn:node-name($n))
    let $xmlns := 
        if ($xmlns != "") then
            fn:concat( '"' , $xmlnsprefix , '" : "' , $xmlns , '"' )
        else
            ""
    
    let $attributes := 
        for $a in $n/@*
        return fn:concat( '"' , fn:name($a) , '" : "' , fn:string-join($a, ' '), '"' )
    
    let $attributes := ($xmlns, $attributes)
   
    let $json-attributes := 
        fn:concat(
            "{
                " , fn:string-join($attributes, ", 
                ") , "
            }
            ")

    return 
        fn:concat('[
            "' , $nodename , '",
            ', $json-attributes,
            if ($n/child::node()[text() or fn:name()]) then
                let $cns := 
                    (:for $cn in $n/child::node()[fn:name()]
                    return xml2jsonml:xml2jsonml($cn) :)
                    for $cn in $n/child::node()
                    return 
                        typeswitch ($cn)
                        case text() return 
                            if ( fn:normalize-space(xs:string($cn)) != "" ) then
                                fn:concat('     "' , fn:replace(xs:string($cn), "\n|\t", " ") , '"')
                            else ""
                        case element() return xml2jsonml:xml2jsonml($cn)
                        default return ""
                let $cns := 
                    for $c in $cns
                    where fn:normalize-space(xs:string($c)) != ""
                    return $c
                return
                    if ( fn:count($cns) > 0 ) then
                        fn:concat(",
                        " , 
                            fn:string-join($cns, ",
                            ")
                        )
                    else ""
            else if ( xs:string($n) != "" ) then
                fn:concat(',
                "' , fn:replace(xs:string($n), "\n|\t", " ") , '"')
            else "",
            '
            ]')
};