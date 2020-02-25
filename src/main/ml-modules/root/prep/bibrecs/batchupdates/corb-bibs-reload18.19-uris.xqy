xquery version '1.0-ml';
      declare namespace mxe  = 'http://www.loc.gov/mxe';
      declare namespace idx  = 'info:lc/xq-modules/lcindex';
      declare namespace bf   = 'http://id.loc.gov/ontologies/bibframe/';
      declare namespace bflc = 'http://id.loc.gov/ontologies/bflc/';
      declare namespace   index               = "info:lc/xq-modules/lcindex";
      declare namespace   mets       		 	= "http://www.loc.gov/METS/";
      declare namespace marcxml       = "http://www.loc.gov/MARC21/slim";



import module namespace bibs2mets 			= "http://loc.gov/ndmso/bibs-2-mets" at "modules/module.bibs2mets.xqy";
(: NAMESPACES :)

declare namespace   rdf                 = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace   rdfs                = "http://www.w3.org/2000/01/rdf-schema#";
(: in catalog 18 and 19, find stuff that didnt' load (no instance uri):)
let $uris:=
for $chunk in xdmp:directory("/bibframe-process/chunks/catalog19/")
     for $record in $chunk//marcxml:record/marcxml:controlfield[@tag="001"]
     let $bibid:=fn:normalize-space(fn:string($record))
     let $marcxml:=fn:concat("/bibframe-process/records/",$bibid,".xml")
     let $instance-id:=fn:concat("c0",$bibid)
      let $dirtox := bibs2mets:chars-001($instance-id)
    let $destination-root := "/lscoll/lcdb/instances/"
	let $dir := fn:concat($destination-root, string-join($dirtox, '/'), '/')
  
    let $instance-id:=fn:concat($dir,$instance-id, "0001.xml")
return
  if (fn:doc-available($marcxml)) then
      if (fn:doc-available($instance-id ))
      then ()
      
      else  $marcxml
   
    else ()
  
  return (count($uris)  , $uris)
	