xquery version "1.0-ml";

(:
:   Module Name: Generate a mets doc from bf:rdf and idx index data.
:
:   Module Version: 1.0
:
:   Date: 2011 July 21
:
:   Copyright: Public Domain
:
:   Proprietary XQuery Extensions Used: cts, xdmp (Marklogic)
:
:   Xquery Specification: January 2007
:
:   Module Overview:    Generates a list of uris for a scheme.
:       Having an index on URIs is mandatory.
:
:)
   
(:~
:   Generates a list of uris for a scheme.
:   Having an index on URIs is mandatory.
:
:   @author Kevin Ford (kefo@loc.gov)
:   @since July 21, 2011
:   @version 1.0
:)

(: Namespaces :)
declare namespace mets      = "http://www.loc.gov/METS/";
declare namespace bf        = "http://bibframe.org/vocab/";
declare namespace bf2		= "http://bibframe.org/vocab2/" ;
declare namespace rdf       = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace index     = "id_index#";
declare namespace xdmp      = "http://marklogic.com/xdmp";
declare namespace dir       = "http://marklogic.com/xdmp/directory";
declare namespace mlerror	= "http://marklogic.com/xdmp/error";
declare namespace log       =  "info:lc/bibframe/logging#";

import module namespace format              =       "info:lc/id-modules/format#" at "modules/module.Format.xqy";
import module namespace madsrdf2bibframe    =       "info:lc/id-modules/madsrdf2bibframe#" at "modules/module.MADSRDF-2-BIBFRAME.xqy";
import module namespace madsrdf2index   	=       "info:lc/id-modules/madsrdf2index#" at "modules/module.MADSRDF-2-INDEX.xqy";
import module namespace marcauth2bibframe   =       "info:lc/id-modules/marcauth2bibframe#" at "marc2bibframe/modules/module.MARCXMLAUTH-2-BIBFRAME.xqy";
import module namespace mets-funcs          = 		"info:lc/id-modules/mets-functions#" at "modules/module.METS-functions.xqy";
import module namespace RDFXMLnested2flat   =       "info:lc/bf-modules/RDFXMLnested2flat#" at "marc2bibframe/modules/module.RDFXMLnested-2-flat.xqy";
import module namespace bibframe2index      =       "info:lc/id-modules/bibframe2index#" at "modules/module.BIBFRAME-2-INDEX.xqy";
import module namespace bibframeenhance  	=       "info:lc/id-modules/bibframe-enhance#" at "modules/module.BIBFRAME-Enhance-ML.xqy";

declare variable $URI as xs:string external;
declare variable $idfile as xs:string := "/marklogic/id/id-prep/bfi/workid.txt";

(: work uris:
/authorities/names/n00000103.xml--/resources/works/lw00000103.xml
:)

declare function local:get-annotations(
        $bfraw as element(rdf:RDF), 
        $workDBURI as xs:string, 
        $paddedID as xs:string
    )
{
    
    (: INSTANCES :)
(:padded id ends in .xml ; strip it off for annotationuri, add back for dburi (objid) :)    
    let $paddedID:=fn:replace($workDBURI, ".xml", "")
    let $annotates := 
        element bf:annotates {
            attribute rdf:resource { fn:concat("http://id.loc.gov", fn:replace($workDBURI, ".xml", "")) }
        }

    (: Go through instances, create new id, create mets :)    
    let $annotations := 
        for $i at $pos in $bfraw//bf:Annotation
		        let $iNumStr := xs:string($pos)
		        let $iNumLen := fn:string-length($iNumStr)
		        let $iID := 
		            if ( $iNumLen eq 1 ) then
		                fn:concat( $paddedID, "000", $iNumStr )
		            else if ( $iNumLen eq 2 ) then
		                fn:concat( $paddedID, "00", $iNumStr )
		            else if ( $iNumLen eq 3 ) then
		                fn:concat( $paddedID, "0", $iNumStr )
		            else
		                fn:concat( $paddedID, $iNumStr )
		        let $iID:=fn:replace($iID,"/works/","/annotations/")
		        let $annotationDBURI:=fn:concat($iID,".xml")
        
		        (:let $annotationDBURI := fn:concat("/resources/annotations/" , $iID ):)
		        let $annotationURI := fn:concat("http://id.loc.gov",  $iID)
		        let $annotation-modified := 
		            element bf:Annotation {
		                attribute rdf:about {$annotationURI},
		                $i/*[fn:local-name() ne "annotationOf"],
		                $annotates
		            }
		        let $annotation-indexbf := bibframe2index:bibframe2index( element rdf:RDF { $annotation-modified } )
				(:let $annotation-index := madsrdf2index:madsrdf2index( element rdf:RDF { $annotation-modified } ):)
				
		      return 
		            <mets:mets 
		                PROFILE="annotationRecord" 
		                OBJID="{$annotationDBURI}" 
		                xsi:schemaLocation="http://www.loc.gov/METS/ http://www.loc.gov/standards/mets/mets.xsd" 
		                xmlns:mets="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink" 
		               	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 		 
						xmlns:rdfs  = "http://www.w3.org/2000/01/rdf-schema#"
						xmlns:bf="http://bibframe.org/vocab/" 
						xmlns:bf2="http://bibframe.org/vocab2/" 
		        		xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#" 
						xmlns:relators      = "http://id.loc.gov/vocabulary/relators/"
		                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
		                xmlns:index="id_index#">
		                <mets:metsHdr LASTMODDATE="{fn:current-dateTime()}"/>
		                <mets:dmdSec ID="bibframe">
		                    <mets:mdWrap MDTYPE="OTHER">
		                        <mets:xmlData>
		                            <rdf:RDF>
		                                {$annotation-modified}
		                            </rdf:RDF>
		                        </mets:xmlData>
		                    </mets:mdWrap>
		                </mets:dmdSec>
		               
						 <mets:dmdSec ID="index">
		                    <mets:mdWrap MDTYPE="OTHER">
		                        <mets:xmlData>
		                            {$annotation-indexbf}
		                        </mets:xmlData>
		                    </mets:mdWrap>
		                </mets:dmdSec>
		                <mets:structMap>
		                    <mets:div TYPE="annotationRecord" DMDID="bibframe index"/>
		                </mets:structMap>
		            </mets:mets>
		
            
    return $annotations
                           
};


 
 (:bibframe flat doesnt' help ; we need nested or we have to go finding all the pieces for display! :)
 (:uri comes in like: authorities/names/wo2010059348
  authorities/names/no2010059348--1
  authorities/names/no2010059349--2
 
 :)
(: this works with the above pattern; changed to lw... 20150708
let $paddedID:=fn:substring-after($URI,"works/")

let $URI-parts := fn:tokenize($URI, "--")

let $URI := $URI-parts[1]


let $workid := $URI-parts[2]

let $workidLen := fn:string-length( xs:string($workid) )
let $paddedID := 
    if ( $workidLen eq 1 ) then
        fn:concat("00000000" , $workid)
    else if ( $workidLen eq 2 ) then
        fn:concat("0000000" , $workid)
    else if ( $workidLen eq 3 ) then
        fn:concat("000000" , $workid)
    else if ( $workidLen eq 4 ) then
        fn:concat("00000" , $workid)
    else if ( $workidLen eq 5 ) then
        fn:concat("0000" , $workid)
    else if ( $workidLen eq 6 ) then
        fn:concat("000" , $workid)
    else if ( $workidLen eq 7 ) then
        fn:concat("00" , $workid)
    else if ( $workidLen eq 8 ) then
        fn:concat("0" , $workid)
    else 
        $workid

let $workURI := fn:concat("http://id.loc.gov/resources/works/" , $paddedID)
let $workDBURI := fn:concat("/resources/works/" , $paddedID, ".xml")
let $marcuri:=fn:replace($URI, "names/w","names/n") ????? doesnt' look right; check if you uncomment this!
let $marcuri:=$URI
let $enhanceURI:=fn:replace($marcuri,".xml","")

 let $URI := fn:replace($URI, ".xml", "") 
            

:)

(:-----------------------------main program ------------------:)

(:
this works with the pattern:
/authorities/names/n00000103.xml--/resources/works/lw00000103.xml
:)
let $URI-parts := fn:tokenize($URI, "--")

let $marcuri := $URI-parts[1]

		(:/resources/works/lw00000103.xml:)
let $workDBURI := $URI-parts[2]
let $workURI := fn:concat("http://id.loc.gov" , fn:substring-before($workDBURI,".xml"))
let $paddedID:= fn:replace(fn:substring-after($workDBURI,"works/"),".xml","")
(:
let $index := format:get-bibframe-index($marcuri)
let $bibframe-raw := format:get-bibframe-raw($marcuri, $workURI)
:)
  
  let $marcxml:=<marcxml:collection xmlns:marcxml="http://www.loc.gov/MARC21/slim" >{mets-funcs:get-mets-dmdSec('marcxml', $marcuri)}</marcxml:collection>


let $baseuri:="http://id.loc.gov/"
let $usebnodes:="true"
let $colls:=xdmp:document-get-collections($workDBURI)

let $loaded:= 
    if (fn:contains(fn:string-join($colls, " "), "/bibframe/2015-10-23reload"))  then   
				fn:true()
			else
 				()		
 
 return 
 if ($loaded =fn:true()) then
			xdmp:log(fn:concat("skipping ",$workDBURI," already loaded 2015-10-23"),"info")
		else
			let $bibframe-raw := 
				try{
				marcauth2bibframe:marcauth2bibframe($marcxml,  fn:replace( $workURI,".xml","") )
				}
			 catch ($e) {
                        (: ML provides the full stack, but for brevity only take the spawning error. :)
                        (:  let $stack1 := $e/mlerror:stack/mlerror:frame[1]
                        let $vars := 
                            for $v in $stack1/mlerror:variables/mlerror:variable
                            return
                                element log:error-variable {
                                    element log:error-name { xs:string($v/mlerror:name) },
                                    element log:error-value { xs:string($v/mlerror:value) }
                                }:)
                        let $logmsg := 
                            element log:error {
                                attribute marcuri {$marcuri},
								attribute workuri {$workURI},
                                attribute datetime { fn:current-dateTime() }
								(:,
                                element log:error-details {
                                    (: ML appears to be the actual err:* code in mlerror:name :)
                                    element log:error-enginecode { xs:string($e/mlerror:code) },
                                    element log:error-xcode { xs:string($e/mlerror:name) },
                                    element log:error-msg { xs:string($e/mlerror:message) },
                                    element log:error-description { xs:string($e/mlerror:format-string) },
                                    element log:error-expression { xs:string($e/mlerror:expr) },
                                    element log:error-file { xs:string($stack1/mlerror:uri) },
                                    element log:error-line { xs:string($stack1/mlerror:line) },
                                    element log:error-column { xs:string($stack1/mlerror:column) },
                                    element log:error-operation { xs:string($stack1/mlerror:operation) }    
                                },
                                element log:offending-record {
                                    $marcxml
                                }
								:)
                            }
					return (xdmp:log(fn:concat($workDBURI ," not loaded")   , "info"),
                            element result {
                               element logmsg {$logmsg}
                            }        )
		          }


return 
		if ($bibframe-raw instance of element(rdf:RDF)) then        				

				let $bibframe-enhanced:= bibframeenhance:bibframe-enhance($bibframe-raw) 
				(: this is probably the right thing to use, but I'm not for now, so we can find eveyrthing in one document:)
				(: let $bibframe-eflat:= RDFXMLnested2flat:RDFXMLnested2flat($bibframe-enhanced, $baseuri, $usebnodes) :)

				let $index := bibframe2index:bibframe2index($bibframe-enhanced)
				(:use marcxml to recalc workhas based on conversion.docx:)
				let $index_update:= bibframe2index:update_aaps($marcxml , "auth")

				let $index := <index:index>{
								$index//*[local-name()!="WorkHash"][local-name()!="Workaap"],
								$index_update//index:*
							  }
							  </index:index>

				
				 (:strip out annotations, add back links to them, add additional Works (ie expressions), titles, orgs, places, etc
				 annotations/rdf:about is in ref to works/000*, needs to be annotations/000* :)
				(: I'm skipping this parsing out of hte annotation; we really need to do it all or none, not just annotations by themselves:)
				
				(:let $bibframe-work:=
					element rdf:RDF {	
							element bf:Work {$bibframe-eflat/bf:Work[1]/@rdf:about,
						 		$bibframe-eflat/bf:Work[1]/*[fn:local-name()!='hasAnnotation'],
								$bibframe-eflat/*[fn:local-name()!='Annotation'][fn:local-name()!='Work'],
								for $ann  at $pos in $bibframe-eflat/bf:Annotation
									let $annotation-uri:=fn:replace($workURI,"works","annotations")								
									let $annotation-uri:=fn:concat($annotation-uri, fn:string(fn:format-number($pos,"0000")))
									 return ( element bf:hasAnnotation {attribute rdf:resource {$annotation-uri}	},
									 			element bf:Annotation {attribute rdf:about {$annotation-uri},
																$ann/*
													}
											)
									,
								for $work in $bibframe-eflat/bf:Work[fn:not(fn:position()=1)][fn:local-name()!='Annotation']
									return $work
									

							}
						}
				:)
				(:should be bibframe-work below, later!:)
				let $mets := 
				    <mets:mets 
				        PROFILE="workRecord" 
				        OBJID="{$workDBURI}" 
				        xsi:schemaLocation="http://www.loc.gov/METS/ http://www.loc.gov/standards/mets/mets.xsd" 
				        xmlns:mets="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink" 
				        xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 		 
						xmlns:rdfs  = "http://www.w3.org/2000/01/rdf-schema#"
						xmlns:bf1="http://bibframe.org/vocab/" 
						xmlns:bf="http://id.loc.gov/ontologies/bibframe/" 
				        xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#" 
						xmlns:relators      = "http://id.loc.gov/vocabulary/relators/"
				        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
				        xmlns:index="id_index#">
				        <mets:metsHdr LASTMODDATE="{fn:current-dateTime()}"/>		
						<mets:dmdSec ID="bibframe">
				            <mets:mdWrap MDTYPE="OTHER">
				                <mets:xmlData>
				                    {$bibframe-enhanced}
				                </mets:xmlData>
				            </mets:mdWrap>
				        </mets:dmdSec>
						 <mets:dmdSec ID="index">
				            <mets:mdWrap MDTYPE="OTHER">
				                <mets:xmlData>
				                    {$index}
				                </mets:xmlData>
				            </mets:mdWrap>
				        </mets:dmdSec>
				         
						
				      
				        <mets:structMap>
				            <mets:div TYPE="workRecord" DMDID="bibframe index"/>
				        </mets:structMap>
				    </mets:mets>

			    let $annotations := local:get-annotations($bibframe-raw,$workDBURI,$paddedID)
			      let $annotations-debug := 
			        for $i at $pos in $bibframe-raw//bf:Annotation[1]
			        let $paddedID:=fn:replace($paddedID,".xml","")
			        let $iNumStr := xs:string($pos)
			        let $iNumLen := fn:string-length($iNumStr)
			        let $iID := 
			            if ( $iNumLen eq 1 ) then
			                fn:concat( $paddedID, "000", $iNumStr )
			            else if ( $iNumLen eq 2 ) then
			                fn:concat( $paddedID, "00", $iNumStr )
			            else if ( $iNumLen eq 3 ) then
			                fn:concat( $paddedID, "0", $iNumStr )
			            else
			                fn:concat( $paddedID, $iNumStr )
			        return  $iNumLen
    
    
			(:    let $annotation-collections := "/resources/annotations/" 
			  	let $insert-annotations :=
			        for $i in $annotations
			        return
			           try{  ( 
						xdmp:document-insert(
			                xs:string($i/@OBJID),
			                $i,
			                (
			                    xdmp:permission("id-user-role", "read"), 
			                    xdmp:permission("id-admin-role", "update"),
			                    xdmp:permission("id-admin-role", "insert")
			                ),
			             $annotation-collections
			            ),
			        	xdmp:log(fn:concat("loaded annotation : ",xs:string($i/@OBJID) )   , "info")
			        	)
						}
						 catch($e) {
xdmp:log(fn:concat("not loaded annotation : ",xs:string($i/@OBJID)," : ", fn:string($e) )   , "info")
						}
			:)
			let $destination-collections := ("/resources/works","/bibframe","/bibframe/transformedTitles", "/bibframe/2015-10-23reload")
			return
			    try{ (	
			        xdmp:document-insert(
			            $workDBURI, 
			            $mets,
			            (
			                xdmp:permission("id-user-role", "read"), 
			                xdmp:permission("id-admin-role", "update"),
			                xdmp:permission("id-admin-role", "insert")
			            ),
			             $destination-collections
			        ),
			        (:$insert-annotations,:)
					xdmp:log(fn:concat("loaded work doc : ",$workDBURI, " from auth doc : ",$marcuri )   , "info")			        
			    )
			    } catch($e) {
xdmp:log(fn:concat("not loaded work : ",$workDBURI," : ", fn:string($e) )   , "info")
						}


else (:bibframe-raw is error:error, already logged, do nothing:)
	xdmp:log(fn:concat("bibframe-raw is error:error, already logged, do nothing", fn:node-name($bibframe-raw/element())," this doc"), "info")
	
    
   