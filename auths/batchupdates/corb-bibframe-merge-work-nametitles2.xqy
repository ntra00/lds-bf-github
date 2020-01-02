xquery version "1.0-ml";

declare namespace marcxml="http://www.loc..gov/MARC21/slim";
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace index = "id_index#";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace bf = "http://bibframe.org/vocab/";
declare namespace bf2 = "http://bibframe.org/vocab2/";
declare namespace madsrdf       = "http://www.loc.gov/mads/rdf/v1#";
(: lcp = lc processing namespace :)
declare namespace lcp       = "http://www.loc.gov/bibframe/lc_processing#";

(:2015-10-20
this version works on the work aap, not the workhash, for now; reworked based on conversion.docx

rachmaninoff: needs work?lw81131501
:)


declare variable  $SKIPABLES:=
	<ids>
	<!--<id>lw2002032255</id>
<id>lw2002024744</id>
<id>lw2002017402</id>
<id>lw2001093546</id>
		<id>lw2001080759</id>
		<id>lw00076290</id>
		<id>lw2001025942</id>
		<id>lw2001034155</id>
		<id>lw2001013885</id>
		<id>lw00069928</id>
		<id>lw2001084638</id>
		<id>lw2001085074</id>
		<id>lw2001085097</id>
		<id>lw2001089054</id>		
		<id>lw2001089061</id>
		<id>lw2001089056</id>
		<id>lw2001089055</id>
		<id>lw2001089060</id>
		<id>lw2001089059</id>
		<id>lw2001089431</id>
		<id>lw2001089416</id>
		<id>lw2001090577</id>
		<id>lw2001091261</id>
		<id>lw2001091498</id>
		<id>lw2001091812</id>
		<id>lw2001093498</id>-->
	</ids>;


declare variable $URI external;

declare variable  $CLASS-NODES := 
<nodes>
	<node name="classification">classification</node>
	<node name="classificationLcc">classificationLcc</node>
	<node name="classificationUdc">classificationUdc</node>
	<node name="classificationDdc">classificationDdc</node>
	<node name="classificationNlm">classificationNlm</node>
</nodes>;

(:
search the database for the  workaap from the  nametitle work
for each converted bib that matches, process the merge
:)

declare function local:mergeable($nametitle-uri, $batch,$skips) {
	
		
  let $nametitle-lccn:=fn:substring-after($nametitle-uri,"works/")
  let $nametitle-lccn:=fn:substring-before($nametitle-lccn,".xml")
  
   return
  			if  (fn:matches($skips,$nametitle-lccn)) then
					xdmp:log(fn:concat("CORB-BIBFRAME-MERGE-NAMETITLES-GET-BIBS: ",$nametitle-uri, " skippped; creates conflicts! "), "info")
			else
				let $doc := fn:doc($nametitle-uri)
			 	return			
					 if (fn:contains(fn:string-join($doc//index:generation," "), $batch)) then							 			
						xdmp:log(fn:concat("CORB-BIBFRAME-MERGE-NAMETITLES-GET-BIBS: ",$nametitle-uri, " skippped; already processed "), "info")			
					else  
			 			for $d in $doc//index:Workaap
			             let $text:=xdmp:diacritic-less(fn:string($d))			             
			             let $query :=              
			                          cts:element-value-query(
									  		xs:QName("index:Workaap"),fn:concat('"',$text,'"') ,
									  		( "case-insensitive", "diacritic-insensitive","punctuation-insensitive")
									  )
			             let $set:=  cts:uris((), ("frequency-order"), $query, ())
      
   					   return					 	
							(for $uri in $set[fn:starts-with(.,"/resources/works/c")][1]
								return	local:merge($set, $nametitle-uri, $batch)
							,

	                      for $uri in $set[fn:not(fn:starts-with(.,"/resources/works/c")) and fn:not(fn:contains(.,$nametitle-lccn))]
    	                    return 
             						xdmp:log(fn:concat("CORB-BIBFRAME-MERGE-NAMETITLES-GET-BIBS: ",$uri, " matching nametitle not merged "), "info")
                						
					)
		
				

};

declare function local:merge($set, $nametitle-uri, $batch) {

	let $mergeable-docs:=
		for  $uri in $set[fn:starts-with(.,"/resources/works/c") or fn:matches(., $nametitle-uri)]
			return fn:doc($uri)
	
	let $name-title-doc:=  
		for $w in $mergeable-docs[fn:matches(fn:string(mets:mets/@OBJID),"works/lw")]	
				return $w
	let $subjects-new :=
             ( 			(:madsrdf subjects deduped:)
			 for $x in fn:distinct-values($mergeable-docs//bf:subject//madsrdf:authoritativeLabel)         
          			let $s:= $mergeable-docs//bf:subject[*/bf:hasAuthority//madsrdf:Authority/madsrdf:authoritativeLabel=$x]
              			return $s[fn:index-of($s,.)[1]]
			,
						(:$uncontrolled-subjects not deduped:)
			for $uncontrolled-subjects in $mergeable-docs//bf:subject[fn:not(//madsrdf:authoritativeLabel)]
          		return $uncontrolled-subjects
			)

	
	let $all-classifications:= 
		for $classnode in $CLASS-NODES//node 
			return 	$mergeable-docs[fn:matches(fn:string(mets:mets/@OBJID),"works/c")]//*[fn:matches($classnode,fn:local-name())]
	let $class-uris:=  $all-classifications[@rdf:resource]
	let $class-blanknodes:= $all-classifications[fn:not(@rdf:resource)   ] 
		(:doesnt' dedup blank nodes....consider merging on rdfs:label eventually:)
   	let $classes-new :=
         	(			
			for $x in distinct-values($class-uris/@rdf:resource)                 
                    let $c:= $class-uris[fn:string(@rdf:resource)=$x]
                     return $c[fn:index-of($c,.)[1]]
				,
				$class-blanknodes
              )

    let $consolidates:=
		(
		for $derived in $mergeable-docs//bf:derivedFrom[fn:not(fn:matches(@rdf:resource,"authorities/names"))]
			let $uri:=fn:replace (fn:string($derived/@rdf:resource), "^(http://id.loc.gov/resources/works/)(c)(0*)([1-9]*)(.+)$","http://id.loc.gov/resources/bibs/$4$5")
			return <bf2:consolidates>{$uri}</bf2:consolidates>
             (:return <bf2:consolidates>{$derived/@rdf:resource}</bf2:consolidates>:)
			 )
	let $rdftypes:= 
		(
		for $type in  distinct-values($mergeable-docs//bf:Work/rdf:type/@rdf:resource)
			return <bf2:bibworkType rdf:resource="{$type}"/>
		)
	let $instance-links:= 		
	 		$mergeable-docs//bf:Work[fn:starts-with(@rdf:about,"http://id.loc.gov/resources/works/c")]/bf:hasInstance[@rdf:resource]
	 	
	let $annotation-links:= 
			$mergeable-docs//bf:Work[fn:starts-with(@rdf:about,"http://id.loc.gov/resources/works/c")]/bf:hasAnnotation[@rdf:resource]											
			

	let $merged-bibs:=
	    if ($mergeable-docs[fn:string(//mets:mets/@OBJID) != $nametitle-uri]) then
	       ( xdmp:spawn(xdmp:document-add-collections( $nametitle-uri,"/bibframe/mergeFoundBibWorks")),
	       for $d  at $x in $mergeable-docs[fn:string(//mets:mets/@OBJID) != $nametitle-uri]
				return 		
				  local:process-merge($d, $nametitle-uri, $batch)
			)
            
	    else
	           xdmp:spawn(xdmp:document-add-collections( $nametitle-uri,"/bibframe/mergeNoBibWorks"))
		
	let $_x:=	for $node in $name-title-doc//bf:classificationLcc return xdmp:spawn(xdmp:node-delete($node) )
	let $_x:=	for $node in $name-title-doc//bf:classificationDdc return xdmp:spawn(xdmp:node-delete($node))
	let $_x:=	for $node in $name-title-doc//bf:classificationUdc return xdmp:spawn(xdmp:node-delete($node))
	let $_x:=	for $node in $name-title-doc//bf:classificationNlm return xdmp:spawn(xdmp:node-delete($node))
	let $_x:=	for $node in $name-title-doc//bf:classification return xdmp:spawn(xdmp:node-delete($node))
	let $_x:=	for $node in $name-title-doc//bf2:consolidates return xdmp:spawn(xdmp:node-delete($node))
	let $_x:=	for $node in $name-title-doc//bf:subject return xdmp:spawn(xdmp:node-delete($node))
	let $_x:=	for $node in $name-title-doc//bf:hasInstance[@rdf:resource]  return xdmp:spawn(xdmp:node-delete($node))
	let $_x:=	for $node in $name-title-doc//index:generation[text()="DLC nametitle2bib matcher 2015-10-01"] return xdmp:spawn(xdmp:node-delete($node))
	let $_x:=	for $node in $name-title-doc//bf:hasAnnotation[@rdf:resource] return xdmp:spawn(xdmp:node-delete($node))
		
	(: updates to lw, name title doc :)
	let $_x:=	xdmp:spawn(xdmp:node-insert-child($name-title-doc//index:index,$batch))
	let $_x:=	xdmp:spawn(xdmp:node-insert-child($name-title-doc//rdf:RDF/bf:Work,$subjects-new))
	let $_x:=	xdmp:spawn(xdmp:node-insert-child($name-title-doc//rdf:RDF/bf:Work,$classes-new))
	let $_x:=	xdmp:spawn(xdmp:node-insert-child($name-title-doc//rdf:RDF/bf:Work,$consolidates))
	let $_x:=	for $l in $instance-links 
					return xdmp:spawn(xdmp:node-insert-child($name-title-doc//rdf:RDF/bf:Work,$l))
	let $_x:=	for $l in $annotation-links
					return xdmp:spawn(xdmp:node-insert-child($name-title-doc//rdf:RDF/bf:Work,$l))
	let $_x:=	xdmp:spawn(xdmp:node-insert-child($name-title-doc//rdf:RDF/bf:Work,$rdftypes))
	(:let $_x:=xdmp:spawn(xdmp:node-replace($name-title-doc/mets:mets/mets:metsHdr,  <mets:metsHdr LASTMODDATE="{fn:current-dateTime()}"/>)		):)
	let $_x:=xdmp:spawn(xdmp:node-delete($name-title-doc/mets:mets/mets:metsHdr))
	let $_x:=xdmp:spawn(xdmp:node-insert-child($name-title-doc/mets:mets,  <mets:metsHdr LASTMODDATE="{fn:current-dateTime()}"/>	))
		
	return ()
	
};


(: on a mergeable bib, this works's subjects and classes have been moved to the lw
	
	* need to remove it's collection /bibframe/works ?? and add it to /bibframe/mergedoutWorks 
	* to make it not-searchable, in main searches for bf, remove index:scheme /resources/works
	
	* need to add batch index:generation
	* need to reorient it's instances and annotations to the lw number, $nametitle-uri
	??
	:)
declare function local:process-merge($bibdoc, $nametitle-uri, $batch) {

	let $biburi:=fn:string($bibdoc/mets:mets/@OBJID)
	let $nametitle-resource:=fn:concat("http://id.loc.gov",fn:replace($nametitle-uri,".xml",""))
	let $instanceOf:=  <bf:instanceOf rdf:resource="{$nametitle-resource}"/>
		
	let $instances:= 
		for $instance-uri in $bibdoc//bf:hasInstance/@rdf:resource
			let $instance-id:=fn:replace(fn:string($instance-uri),"http://id.loc.gov","")
			let $instance:=fn:doc(fn:concat(fn:string($instance-id),".xml") )
			return 
				(
				xdmp:spawn(xdmp:node-replace($instance//bf:instanceOf,$instanceOf)),
				xdmp:spawn(xdmp:node-insert-child($instance//index:index,$batch)),
				xdmp:log(fn:concat("CORB-BIBFRAME-MERGE-NAMETITLES-GET-BIBS: ",$instance-uri," onto ",$nametitle-uri, " partial "), "info")
				)

	let $annotates:=  <bf:annotates rdf:resource="{$nametitle-resource}"/>						 

	let $annotations:= 
			for $annotation-uri in $bibdoc//bf:hasAnnotation/@rdf:resource								
				let $annotation-id:=fn:replace(fn:string($annotation-uri),"http://id.loc.gov","")
				let $annotation:=fn:doc(fn:concat(fn:string($annotation-id),".xml") )
				return 
					(
					(: xdmp:spawn(xdmp:node-replace($annotation//bf:annotates,$annotates)), :)
					for $node in $annotation//bf:annotates return xdmp:spawn(xdmp:node-delete($node)),
					xdmp:spawn(xdmp:node-insert-child($annotation//bf:Annotation,$annotates)), (: annotation/c073803167001 annotates 2 works???? :)
					xdmp:spawn(xdmp:node-insert-child($annotation//index:index,$batch)),
					xdmp:log(fn:concat("CORB-BIBFRAME-MERGE-NAMETITLES-GET-BIBS: ",$annotation-uri," onto ",$nametitle-uri, " partial "), "info")
					)
return
	try {

	let $_x:=xdmp:spawn(xdmp:node-delete($bibdoc/mets:mets/mets:metsHdr))
	let $_x:=xdmp:spawn(xdmp:node-insert-child($bibdoc/mets:mets,  <mets:metsHdr LASTMODDATE="{fn:current-dateTime()}"/>)		)
	
	let $_x:=xdmp:spawn(xdmp:node-delete($bibdoc//index:generation[text()= $batch]))
			
			(: these 3 are for multiple runs; not using lcp after all... :)
	let $_x:=xdmp:spawn(xdmp:node-delete($bibdoc//lcp:note))
	let $_x:=xdmp:spawn(xdmp:node-delete($bibdoc//bf2:processingNote))
	let $_x:=xdmp:spawn(xdmp:node-delete($bibdoc//madsrdf:useInstead))
	
	let $_x:=xdmp:spawn(xdmp:node-insert-child($bibdoc//rdf:RDF/bf:Work,<bf2:processingNote>{fn:concat("This record has been merged with ",$nametitle-resource, " and is no longer valid.")}</bf2:processingNote> ))
	let $_x:=xdmp:spawn(xdmp:node-insert-child($bibdoc//rdf:RDF/bf:Work,<madsrdf:useInstead rdf:resource="{$nametitle-resource}"/>))
	let $_x:= xdmp:spawn(xdmp:document-add-collections($biburi,"/bibframe/mergedoutWorks"))
	let $_x:= xdmp:spawn(xdmp:document-remove-collections($biburi, "/resources/works"))
	let $_x:=xdmp:spawn(xdmp:node-replace($bibdoc//index:scheme[text()='http://id.loc.gov/resources/works'],<index:scheme>http://id.loc.gov/resources/mergedoutWorks</index:scheme>))


	return	xdmp:log(fn:concat("CORB-BIBFRAME-MERGE-NAMETITLES-GET-BIBS: ", $biburi, " onto ", $nametitle-resource, " complete "), "info")
	
	}
	catch ($e) {
			xdmp:log(fn:concat("CORB-BIBFRAME-MERGE-NAMETITLES-GET-BIBS: ", $biburi, " failed ", $nametitle-resource, " complete "), "info")
	}	
	
};
(:--------------------------------- MAIN PROGRAM :)

let $start := xdmp:elapsed-time()
(:let $URI:="/resources/works/lw2002032255.xml":)

let $batch:=<index:generation>DLC nametitle2bib matcher 2015-11-02</index:generation>

let $skips:=fn:concat('"(',fn:string-join($SKIPABLES//id,'|'), ')"') 
return 
 try{
	(  	local:mergeable($URI, $batch, $skips),
		xdmp:document-add-collections($URI,"/bibframe/mergeDone"))
		xdmp:log(
			fn:concat(
				"CORB-BIBFRAME-MERGE-NAMETITLES-GET-BIBS: "
				,$URI,
				" complete in ",
				(xdmp:elapsed-time() - $start) cast as xs:string
				)
				, "info"
			)
		)
	}
	catch ($e) {
                    ($e
                    ,xdmp:log(fn:concat("CORB-BIBFRAME-MERGE-NAMETITLES-GET-BIBS: ",$URI, " failed in ",(xdmp:elapsed-time() - $start) cast as xs:string), "info")
                    )
	}
