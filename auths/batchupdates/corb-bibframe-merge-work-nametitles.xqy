xquery version "1.0-ml";

declare namespace marcxml="http://www.loc.gov/MARC21/slim";
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace index = "id_index#";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace bf = "http://bibframe.org/vocab/";
declare namespace bf2 = "http://bibframe.org/vocab2/";


declare variable $URI external;
(:
2015 10 /20 bibs and name/titles have been synched according to 240 rules in "conversion.docx" 
need to review and modify the comparison. check if hash matching also works?
:)
declare function local:merge($docs as document-node(element(mets:mets))+) {
	 (:fill in your merge code here, or import from existing modules and call those functions :)
(: for each doc in docs, find the lw one. 
        if there are two lw's, log and quit this set
        for each c* doc, 
            grab all the subjects, classes, dedup, add to this lw one
            for each hasInstance .... find and change the "instanceOf to the lw uri
            add to collection "/bibframe/mergedWork"
            remove from the /bibframe collection, so it's not findable but not deleted??
            for each hasAnnotation, change...
            
            store the new lw, instances, annots.
        
:)
if (count($docs[fn:matches(fn:string(mets:mets/@OBJID),"works/lw")]) gt 1) then
    xdmp:log(fn:concat("skipping multiple works", fn:string($docs[1]/mets:mets/@OBJID)), "info")
else
    for $w in $docs[fn:matches(fn:string(mets:mets/@OBJID),"works/lw")]
        
            let $subjects-new :=
                for $s in $docs[fn:not(fn:matches(fn:string(mets:mets/@OBJID),"works/lw"))]//bf:subject
                    let $sLabel := xs:string($s/bf:*[1]/madsrdf:authoritativeLabel)
                    return
                        if ($w/bf:subject/bf:*[1]/madsrdf:authoritativeLabel[xs:string(.) = $sLabel]) then
                            ()
                        else
                            $s
            
            let $classes-new :=
                for $c in $docs[fn:not(fn:matches(fn:string(mets:mets/@OBJID),"works/lw")]//*[fn:starts-with(fn:local-name(),"classification")]
                    let $cAbout := fn:concat(fn:string($c/@rdf:resource),fn:string($c/bf:*[1]/@rdf:about))				
                    return
                        if ($w/bf:*[fn:starts-with(fn:local-name(),"classification")]/bf:*[1]/@rdf:about[xs:string(.) = $cAbout]) then
                            ()
                        else if ($w/bf:*[fn:starts-with(fn:local-name(),"classification")]/@rdf:resource[xs:string(.) = $cAbout]) then
    						()
    					else
                            $c
            let $consolidates:= for $derived in $docs[fn:not(fn:matches(fn:string(mets:mets/@OBJID),"works/lw")]//bf:derivedFrom
                                    return
                                        element bf2:consolidates{$derived/@rdf:resource}
            (:
            let $consolidates := if (fn:not($w/bf:consolidates[fn:string(@rdf:resource)=fn:concat("http://id.loc.gov/resources/bibs/", $BIBURI)] )) then
                element bf2:consolidates {
                    attribute rdf:resource { fn:concat("http://id.loc.gov/resources/bibs/", $BIBURI) }
                }
				else ()
            :)
            return
                element {fn:name($w)} {
                    $w/@*,
                    $w/*[fn:not(fn:local-name()="hasAnnotation")],
					element bf:hasAnnotation {element bf:Annotation{
							$w/bf:hasAnnotation/bf:Annotation/@*,
							$w/bf:hasAnnotation/bf:Annotation/*,
							$consolidates
						}
					},
					
                    $subjects-new,
                    $classes-new
                   
                }
};

declare function local:main() {
	let $doc := fn:doc($URI)
	let $workhash := $doc//index:WorkHash[1]
	return
		if (fn:count($workhash) gt 0) then
			let $hashstr := fn:normalize-space($workhash) 
			let $hashvalue := cts:element-values(xs:QName("index:WorkHash"), $hashstr, ("collation=http://marklogic.com/collation/codepoint"))
			let $frequency := cts:frequency($hashvalue)
			return
				if ($frequency gt 1) then
					let $q := cts:element-range-query(xs:QName("index:WorkHash"), "=", $hashvalue, ("collation=http://marklogic.com/collation/codepoint"))
					(: This is somewhat tricky. It will return the WorkTitle record as well.  So forget that our in-scope $doc even exists -- just pass the one from $mergeable-docs for merging. :)
					let $mergeable-docs := cts:search(fn:doc(), $q)
					let $log-uris := for $d in $mergeable-docs return xdmp:node-uri($d)
					let $_ := xdmp:log(fn:concat("Preparing URIs for merge: ", fn:string-join(($log-uris), "; ")))
					return
						local:merge($mergeable-docs)
				else
					xdmp:log(fn:concat("Skipping merge for Work record at: ", $URI, "due to no matching docs"), "info")
		else
			xdmp:log(fn:concat("Skipping merge for Work record with no hash at: ", $URI), "info")
};

let $start := xdmp:elapsed-time()
let $work := local:main()
return

	xdmp:log(fn:concat("CORB-BIBFRAME-MERGE-RECORDS-EXECUTION: ", (xdmp:elapsed-time() - $start) cast as xs:string), "info")

(:let $quality := ()
let $forest := (xdmp:forest("id-prep-bibframe-process-1"), xdmp:forest("id-prep-bibframe-process-2"))
let $evs := 
	for $val in cts:element-values(xs:QName("index:WorkHash"), (), ("frequency-order", "collation=http://marklogic.com/collation/codepoint"), cts:collection-query("/bibframe-process/records/"), $quality, $forest) 
	where cts:frequency($val) > 1 
	return
		$val
let $and-query := 
	cts:and-query((
		cts:collection-query("/bibframe-process/records/"),
		cts:element-range-query(xs:QName("index:WorkHash"), "=", $evs, ("min-occurs=2", "collation=http://marklogic.com/collation/codepoint"))
	))
let $uris := cts:uris((), ("frequency-order"), $and-query, $quality, $forest)
return 
	(fn:count($uris), $uris):)
