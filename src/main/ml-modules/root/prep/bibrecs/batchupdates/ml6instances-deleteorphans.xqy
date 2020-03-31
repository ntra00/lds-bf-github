xquery version "1.0-ml";
declare variable $URI as xs:string external;  
try {(xdmp:document-delete($URI),
 xdmp:log(fn:concat("CORB shell delete orphan instance uri",$URI), "info")
)}
catch($e) { xdmp:log(fn:concat("CORB shell delete orphan instance error on ",$URI), "info")
}
