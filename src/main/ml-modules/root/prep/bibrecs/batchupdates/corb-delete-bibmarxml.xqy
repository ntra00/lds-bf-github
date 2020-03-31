xquery version "1.0-ml";

declare default element namespace "http://www.loc.gov/MARC21/slim";
declare  namespace marcxml="http://www.loc.gov/MARC21/slim";
declare variable $TODAY := fn:format-date(fn:current-date(),"[Y0001]-[M01]-[D01]");
                 
(:chunks are now in "/bibframe-process/chunks/catalog##/*" (01-19) 

:)
(: corb will pass in a URI of a MARCXML collection document from the /bibframe-process/ collection :)
declare variable $URI as xs:string external;
declare variable $delete-marcxml-collections := fn:false();

if (doc-available($URI)) then
(xdmp:document-delete($URI)
else
xdmp:log(fn:concat("CORB deletes, doc not found:",$URI),"info")

