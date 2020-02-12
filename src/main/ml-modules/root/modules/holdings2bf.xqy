xquery version "1.0-ml";
(: 
	 module for holdings to bibframe
:)
module namespace hold2bf = "http://loc.gov/ndmso/hold-2-bf";


import module namespace 		bibframe2index   	= "info:lc/id-modules/bibframe2index#"   at "module.BIBFRAME-2-INDEX.xqy";
import module namespace 		bf4ts   			= "info:lc/xq-modules/bf4ts#"   		 at "module.BIBFRAME-4-Triplestore.xqy";

declare namespace 				rdf					= "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace   			mets       		 	= "http://www.loc.gov/METS/";
declare namespace  				marcxml             = "http://www.loc.gov/MARC21/slim";
declare namespace  				mxe					= "http://www.loc.gov/mxe";
declare namespace 				bf					= "http://id.loc.gov/ontologies/bibframe/";
declare namespace				bflc				= "http://id.loc.gov/ontologies/bflc/";
declare namespace 				index 				= "info:lc/xq-modules/lcindex";
declare namespace   mlerror	            = "http://marklogic.com/xdmp/error"; 
declare variable $BASE_COLLECTIONS:= ("/lscoll/lcdb/", "/lscoll/", "/catalog/", "/catalog/lscoll/", "/catalog/lscoll/lcdb/", "/catalog/lscoll/lcdb/hld/" );
(: 
	
	
 :)
    (:these properties are transformed as either literals or appended to the @uri parameter inside their @domain:)
declare variable $hold2bf:simple-properties:= (
	<properties>
  <!--holdings-->
         <node domain="holdings"			property="heldBy"	 	     tag="852" sfcodes="a" >heldBy </node>
         <node domain="holdings"			property="subLocation"	 	tag="852" sfcodes="b" >subLocation </node>
         <node domain="holdings"			property="barcode"	 	    tag="852" sfcodes="p" >bar code</node>         
         <node domain="holdings"			property="shelfMark"	 	tag="852" sfcodes="khlimt" >shelfMark code</node>
		 <node domain="helditem"			property="custodialHistory"			tag="561"	 sfcodes="a"                 >Copy specific custodial history</node>
  </properties>
	)	;
declare function hold2bf:generate-holdings-from-hld(
    $marcxml as element(marcxml:record)?,
    
    $workId as xs:string
    
    ) as element ()* 
{
let $holdings:=$marcxml//hld:holdings
let $heldBy:= if ($marcxml/marcxml:datafield[@tag="852"]/marcxml:subfield[@code="a"]) then
                    fn:string($marcxml/marcxml:datafield[@tag="852"][1]/marcxml:subfield[@code="a"])
                else ""
let $custodialHistory:=hold2bf:generate-simple-property($marcxml/marcxml:datafield[@tag="561"], "helditem")
for $hold in $holdings/hld:holding
    let $elm :=  "Item"
        (:if (  $hold/hld:volumes/hld:volume[2]) then "Item" else "HeldItem":)
    let $summary-set :=
            for $property in $hold/*
                return                 
                    if ( fn:matches(fn:local-name($property), "callNumber")) then
                        (element rdfs:label {fn:string($property)},
                        element bf:shelfMark {fn:string($property)})  
                    else if ( fn:matches(fn:local-name($property), "localLocation")) then
                        element bf:subLocation {fn:string($property)} 
                    else if ( fn:matches(fn:local-name($property), "(enumeration|enumAndChron)")) then
                        element bf:enumerationAndChronology {fn:string($property)}
                      
                    else if ( fn:matches( fn:local-name($property), "(publicNote|copyNumber)")) then
                        element {fn:concat("bf:", fn:local-name($property))} {fn:string($property)}
                    else ()
                        
   let $item-set :=
               if  ($hold/hld:volumes ) then
                        for $vol in $hold/hld:volumes/hld:volume
                            let $enum:=fn:normalize-space(fn:string($vol/hld:enumAndChron))
                            let $circs:= $vol/ancestor::hld:holding/hld:circulations
                            let $circ   := 
                                for $circulation in $circs/hld:circulation[fn:normalize-space(fn:string(hld:enumAndChron ))=$enum]
                                    let $status:= if ($circulation/hld:availableNow/@value="1") then "available" else  "not available" 
                                        return element circ {element bf:circulationStatus {$status},
                                                if ($circulation/hld:itemId) then element bf:itemId  {fn:string($circulation/hld:itemId )} else ()
                                                }
                                                
                                              
                           return            
                              element bf:heldItem {
                                element bf:HeldItem {
                                    if ($circ/bf:itemId!='') then 
                                         attribute rdf:about {fn:concat($workId,"/item",fn:string($circ/bf:itemId))}
                                    else (),
                                    element rdfs:label {fn:string($vol/hld:enumAndChron)},
                                    element bf:enumerationAndChronology  {$enum },     
                                     element bf:enumerationAndChronology {fn:string($vol/hld:enumeration)},
                                     $circ/*
                                  }
                               }
             else  (: no volumes,  just add circ  to the summary heldmaterial:)              
                        let $status:= if ($hold/hld:circulations/hld:circulation/hld:availableNow/@value="1") then "available" else  "not available" 
                        return  element bf:hasItem {
                                    element bf:Item {
                                        if ($hold/hld:circulations/hld:circulation/hld:itemId) then
                                            attribute rdf:about {fn:concat($workId,"/item",fn:string($hold/hld:circulations/hld:circulation/hld:itemId))}                                        
                                        else (),
                                        element bf:circulationStatus {$status},                                
                                            element bf:itemId  {fn:string($hold/hld:circulations/hld:circulation/hld:itemId )}
                                        }                                
                                    }
         
            
     return (
      if ($elm = "HeldItem" ) then
         element bf:hasItem {                               
            element bf:Item {            
            $item-set/bf:Item/@rdf:about,        
             $summary-set, $item-set//bf:HeldItem/*[fn:not(fn:local-name()='label')],
             $custodialHistory,             
             if ($heldBy!="") then element bf:heldBy {element bf:Agent {element rdfs:label {$heldBy}}} else ()
            }
            }
                     
      else
        element bf:hasItem{   
               element bf:Item {
                     $summary-set,                      
                     $item-set,
                     if ($heldBy!="") then element bf:heldBy {element bf:Agent {element rdfs:label {$heldBy}}} else ()
                    }
            }
    )
        
};
(:~
:   This is the function generates holdings properties from hld:holdings.
: 
:   @param  $marcxml        element is the MARCXML
:                           may also contain hld:holdings
:   @return bf:* as element()
:)
declare function hold2bf:generate-holdings-from-hrecords(
    $collection as element(marcxml:collection)?,
    
    $workId as xs:string
    
    ) as element ()* 
{


for $r in $collection/marcxml:record[2](:[fn:string(@type)="Holdings"]:)
    return element bf:hasItem { element bf:Item { 
            for $d in $r/marcxml:datafield
                return    mbhold2bf:generate-simple-property($d,"holdings")
         }
         }

};
(:~
:   This is the function generates holdings resources.
: 
:   @param  $marcxml        element is the MARCXML
:                           may also contain hld:holdings
:   @return bf:* as element()
:)
declare function hold2bf:generate-holdings(
    $marcxml as element(marcxml:record),
    $workID as xs:string
    ) as element ()* 
{
(:options: marcxml:records contains opacxml in hld:holdings, or marcxml:record/ancestor:collection contains 
marcxml:record[@type="Holdings"]:)
let $hld:= if ($marcxml//hld:holdings) then
                hold2bf:generate-holdings-from-hld($marcxml, $workID) 
            else if ($marcxml/ancestor::marcxml:collection/marcxml:record[@type='Holdings']) then
                    hold2bf:generate-holdings-from-hrecords($marcxml/ancestor::marcxml:collection, $workID)
            else ()

(:udc is subfields a,b,c; the rest are ab:) 
(:call numbers: if a is a class and b exists:)
 let $shelfmark:=  (: regex for call# "^[a-zA-Z]{1,3}[1-9].*$" :)        	        	         	         
	for $tag in $marcxml/marcxml:datafield[fn:matches(@tag,"(050|051|055|060|070|080|082|083|084)")]
(:	multiple $a is possible: 2017290 use $i to handle :)
		for $class at $i in $tag[marcxml:subfield[@code="b"]]/marcxml:subfield[@code="a"]
       		let $element:= 
       			if (fn:matches($class/../@tag,"(050|051|055|070)")) then "bf:shelfMarkLcc"
       			else if (fn:matches($class/../@tag,"060")) then "bf:shelfMarkNlm"
       			else if (fn:matches($class/../@tag,"080") ) then "bf:shelfMarkUdc"
       			else if (fn:matches($class/../@tag,"082") ) then "bf:shelfMarkDdc"
       			else if (fn:matches($class/../@tag,"083") ) then "bf:shelfMarkDdc"
       			else if (fn:matches($class/../@tag,"084") ) then "bf:shelfMark"
       				else ()
            let $value:= 
                if ($i=1) then  
                    fn:concat(fn:normalize-space(fn:string($class))," ",fn:normalize-space(fn:string($class/../marcxml:subfield[fn:matches(@code,"b")]))) 
                else
                    fn:normalize-space(fn:string($class))
        (:080 doesnt' have $c, so took this out::)
	       return (: if ($element!="bf:callno-udc") then:)
	        		element {$element } {$value}
	        		(:else 
	        		element {$element } {fn:normalize-space(fn:string-join($class/../marcxml:subfield[fn:matches(@code, "(a|b|c)")]," "))}:)
let $custodialHistory:=hold2bf:generate-simple-property($marcxml/marcxml:datafield[@tag="561"], "helditem")

let $d852:= 
    if ($marcxml/marcxml:datafield[@tag="852"]) then
        for $d in $marcxml/marcxml:datafield[@tag="852"]
        return 
            (
            for $s in $d/marcxml:subfield[@code="a"] return element bf:heldBy{fn:string($s)},
            for $s in $d/marcxml:subfield[@code="b"] return element bf:subLocation{fn:string($s)},
            
            if ($d/marcxml:subfield[fn:matches(@code,"(k|h|l|i|m|t)")]) then 
                    element bf:shelfMark{fn:string-join($d/marcxml:subfield[fn:matches(@code,"(k|h|i|l|m|t)")]," ")}
            else (),
                    hold2bf:handle-856u($d) 		      ,
            
            for $s in $d/marcxml:subfield[@code="z"] return element  bf:copyNote{fn:string($s)},
            for $s in $d/../marcxml:datafield[fn:matches(@tag,"(051|061|071)")]
                return element bf:copyNote {fn:string($s/marcxml:subfield[@code="c"]) }
            )
    else 
    ()
    
return 
        if (fn:not($hld) and ($shelfmark or $d852  )) then        
            element bf:heldItem{  
                element bf:HeldItem {       
                   (:this is for matching later:)
                    element rdfs:label{fn:string($shelfmark[1])},
         	    $shelfmark,
         	    $custodialHistory,
         	    $d852         	   	
                }
            }
            
      	else if ($hld) then $hld else ()
    
};
(:~
:   This is the function generates bf:uri or bf:doi or bf:hdl from856u
: 
:   @param  $marcxml        element is the MARCXML  datafield 856
:   @return bf:* as element()
:)
declare function hold2bf:handle-856u(
    $marcxml as element(marcxml:datafield)
    
    ) as element ()* 
{  
for $s in $marcxml/marcxml:subfield[@code="u"] return
                let $elm:=if (fn:contains(fn:string($s) ,"doi")) then "bf:doi"
                            else if (fn:contains(fn:string($s),"hdl")) then "bf:hdl" else "bf:uri"
                return element {$elm} { 
                            attribute rdf:resource{fn:string($s)}
                        }
};