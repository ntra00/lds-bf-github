xquery version "1.0-ml";

declare namespace marcxml = "http://www.loc.gov/MARC21/slim";

(: Just a convenience :)
let $cdt := fn:current-dateTime() cast as xs:string

(: This will assume that the content of the XML is coming in over HTTP POST :)
(: This gets the request body, which is our MARCXML collection :)
(: Also grabs our incoming request headers, used for naming files, collections, etc. :)
let $body := xdmp:get-request-body()/node()
let $header-batch := xdmp:get-request-header("X-bib2f-Batch")
let $header-docuri := xdmp:get-request-header("X-bib2f-DocURI", xdmp:md5($cdt))  
let $_x:=xdmp:log(fn:concat("???",$header-docuri),"info")
return

    (: If it's a MARCXML collection, we're good to process.  If not, reject the transmission :)
    if ($body instance of element(marcxml:collection)) then
        let $batch :=
            if (fn:string-length($header-batch) gt 0) then
                $header-batch
             else
                ()
        let $collections := ("/bibframe-process/", fn:concat("/bibframe-process/", $cdt, "/"))
        let $permissions := (
            xdmp:permission("id-user-role", "read"),
            xdmp:permission("id-admin-role", "update"),
            xdmp:permission("id-admin-role", "insert")
        )
        let $input-uri := $header-docuri
        let $uri := fn:concat("/bibframe-process/", $input-uri)
        let $quality := ()
        let $forest := (xdmp:forest("id-prep-bibframe-process-1"), xdmp:forest("id-prep-bibframe-process-2"))
        return
            try {
                (
                    xdmp:document-insert($uri, $body, $permissions, $collections, $quality, $forest),
                    xdmp:log(fn:concat("Successful insertion of MARCXML for BF processing at ", $uri), "info")
                )
            } catch($e) {
                xdmp:log(fn:concat("Failed insertion of MARCXML for BF processing at ", $uri), "error")
            }
    else
        (: If it's a MARCXML collection, we're good to process.  If not, reject the transmission :)
        fn:error(xs:QName("MARCXML_INPUT_EXCEPTION"), "Root node not an instance of element(marcxml:collection)")