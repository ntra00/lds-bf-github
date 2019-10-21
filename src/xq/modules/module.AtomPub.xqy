xquery version "1.0";

(:
:   Module Name: AtomPub for schemes
:
:   Module Version: 1.0
:
:   Date: 2011 July 20
:
:   Copyright: Public Domain
:
:   Proprietary XQuery Extensions Used: xdmp (MarkLogic), cts (MarkLogic)
:
:   Xquery Specification: January 2007
:
:   Module Overview:    Generates an Atom feed for the
:       given scheme.  Provides a way for users to keep
:       local versions synchronized.
:
:)
   
(:~
:   Generates an Atom feed for the
:   given scheme.  Provides a way for users to keep
:   local versions synchronized.
:
:   @author Kevin Ford (kefo@loc.gov)
:   @since July 20, 2011
:   @version 1.0
:)

module namespace atompub = 'info:lc/xq-modules/atom#';

declare namespace xdmp      = "http://marklogic.com/xdmp";
declare namespace search    = "http://marklogic.com/appservices/search";
declare namespace cts       = "http://marklogic.com/cts";
declare namespace index     = "info:lc/xq-modules/lcindex";
declare namespace atom      = "http://www.w3.org/2005/Atom";
declare namespace dcterms   = "http://purl.org/dc/terms/";
declare namespace at        = "http://purl.org/atompub/tombstones/1.0";

(: Imported Modules :)
(:import module namespace constants = "info:lc/id-modules/constants#" at "../constants.xqy";
import module namespace format      = "info:lc/id-modules/format#" at "module.Format.xqy";:)

import module namespace cfg = "http://www.marklogic.com/ps/config" at "/lds/config.xqy";
import module namespace feed  		= "info:lc/xq-modules/atom-utils" at "atom-utils.xqy";
import module namespace shared      = "info:lc/id-modules/shared#" at "module.Shared.xqy";
declare variable $COUNT as xs:integer := 100;
(:~
:   Get Advanced Atom feed
:

asdafdadfa
:   @param  $scheme         is the scheme requested
:   @param  $page           is the page requested
:   @param  $field          is the mxe field to search
:   @param  $value          is the value to find
:   @return element         as atom:feed element
:)
(: this is the main production bf feed, called by page-service :)
declare function atompub:get-feed-results(
  $scheme as xs:string,
    $page as xs:string,
    $field as xs:string,
    $value as xs:string
  
    ) as element(atom:feed)
{

let $schemes:=
<schemes>
	<scheme uri="/resources/works/">Library of Congress BIBFRAME Works Feed</scheme>
	<scheme uri="/resources/instances/">Library of Congress BIBFRAME Instances Feed</scheme>
	<scheme uri="/resources/items/">Library of Congress BIBFRAME Items Feed</scheme>
	<scheme uri="/resources/imprints/">Library of Congress BIBFRAME Imprints Feed</scheme>
	<scheme uri="/resources/subjects/">Library of Congress BIBFRAME Subjects Feed</scheme>
	<scheme uri="/resources/agents/">Library of Congress BIBFRAME Agents Feed</scheme>
</schemes>
    let $start := ( (xs:integer($page) - 1) * $COUNT) + 1
        
    let $schemeName := fn:string($schemes/scheme[@uri=$scheme])

    
    let $search-results := 
            (:get-search-results($scheme,$start,$COUNT):)
			   
			   feed:search-feed($scheme,$start,$COUNT)
	
	let $feedURL :=if ($field!="" and $value!="") then
                    fn:concat($cfg:BF-VARNISH-BASE , "tools/my", $scheme, "/",$value, "/feed/")                    
                else
                    fn:concat($cfg:BF-VARNISH-BASE , $scheme, "feed/")
		
return
        atompub:make-feed($scheme,$page,$search-results, $schemeName,$feedURL)

};
(:~
:   Get Atom feed
:
:   @param  $scheme         is the scheme requested
:   @param  $page           is the page requested
:   @param  $search-results is the set to display
:   schemdName, feedurl
:   @return element         as atom:feed element
:)
declare function atompub:make-feed(
    $schemeURI as xs:string,
    $page as xs:string,
    $search-results,    
    $schemeName,
    $feedURL
    
    ) as element(atom:feed)
{
       
    (:let $feedURL := fn:concat($cfg:BF-VARNISH-BASE , fn:substring-after($schemeURI, "/") , "/feed/"):)
    
    let $nextPage := xs:integer($page) + 1
    let $nextPageURL := fn:concat($feedURL , xs:string( $nextPage ) )
    
    let $totalPages := total-scheme-pages($search-results, $COUNT)
    let $totalPagesURL := fn:concat( $feedURL , xs:string($totalPages) )
    
	(: format the search results as atom: :)
    let $entries := atompub:create-atom-entries($search-results)
    
	(: There is an opensearch URL in the feed :) 

    return 
      
        <atom:feed xmlns:atom="http://www.w3.org/2005/Atom"
		 xmlns:dcterms="http://purl.org/dc/terms/">{
            element atom:title {$schemeName},
            element atom:link {
                attribute href {fn:concat($feedURL , $page)},
                attribute rel {"self"}
            },
            if ( $nextPage < $totalPages ) then
                element atom:link {
                    attribute href {$nextPageURL},
                    attribute rel {"next"}
                }
            else (),
            element atom:link {
                attribute href {$totalPagesURL},
                attribute rel {"last"}
            },
            element atom:id {fn:concat("info:lc", $schemeURI , "feed")},
            element atom:updated {fn:current-dateTime()},
            $entries
        }
		</atom:feed>
};



(:~
:   Get entries converts search results to atom entry nodes
:
:   @param  $results        is the result XML from the search
:   @return items
:)
declare function atompub:create-atom-entries(
    $results as element(search:response)
    )
{   
  
     for $r in $results/search:result
        let $index := feed:get-index($r/@uri)
       
      return if(fn:empty($index/index:uri)) then 
	  
	  	()
      else  (:loc.natlib.works.c020553551:)
	    let $uri := xs:string($index/index:uri)
		let $uri:=fn:replace($uri,"loc.natlib.","/resources/")
		let $uri:=fn:replace($uri,"\.","/")
	    let $rewrite-uri := shared:rewrite-uri(fn:concat($cfg:BF-VARNISH-BASE,$uri))
	    let $linkMain := 
	        element atom:link {
	            attribute rel {"alternate"},
	            attribute href {$rewrite-uri}
	        }
	    let $linkRDFXML := 
	        element atom:link {
	            attribute rel {"alternate"},
	            attribute type {"application/rdf+xml"},
	            attribute href { fn:concat($rewrite-uri , ".rdf") }
	        }
	    let $linkJSON := 
	        element atom:link {
	            attribute rel {"alternate"},
	            attribute type {"application/json"},
	            attribute href { fn:concat($rewrite-uri , ".json") }
	        }
		let $linkJSONLD := 
	        element atom:link {
	            attribute rel {"alternate"},
	            attribute type {"application/json"},
	            attribute href { fn:concat($rewrite-uri , ".jsonld") }
	        }
	    let $linkNT := 
	        element atom:link {
	            attribute rel {"alternate"},
	            attribute type {"text/plain"},
	            attribute href { fn:concat($rewrite-uri , ".nt") }
	        }
	    (:let $linkMARCXML :=
	        if ( fn:matches(xs:string($index/index:uri), '/authorities/' ) ) then
	            element atom:link {
	                attribute rel {"alternate"},
	                attribute type {"application/marc+xml"},
	                attribute href { fn:concat($rewrite-uri , ".marcxml.xml") }
	            }
	        else ()
	    let $linkMADSXML :=
	        if ( fn:matches(xs:string($index/index:uri), '/authorities/' ) ) then
	            element atom:link {
	                attribute rel {"alternate"},
	                attribute type {"application/mads+xml"},
	                attribute href { fn:concat($rewrite-uri , ".madsxml.xml") }
	            }
	        else ()
	    :)
		let $atomid := element atom:id {  fn:concat("info/lc:",$uri)  }
            
	    let $deprecated := $index/index:rdftype[. = "DeprecatedAuthority"]
	    let $cDate := 
	        if ($index/index:cDate) then
	            element dcterms:created {
	                fn:string( $index/index:cDate[1])
	            }
	        else ()
	    let $mDate := 
	        if ($index/index:mDate[text()]) then
	            (: last() may not be the latest, but it should be  c016161505 was not, so changing it to first ... :)
	            element atom:updated {
	                fn:concat($index/index:mDate[1], "T00:00:00-04:00")
	            }
	        else if ($cDate) then
	            element atom:updated {
	                  fn:concat($index/index:cDate, "T00:00:00-04:00")
	            }
	        else ()

	    let $mDateString := 
	        if ($index/index:mDate) then
	              fn:string($index/index:mDate[fn:last()])
	        else ""
	    let $label := $index/index:aLabel|$index/index:nameTitle[1]|$index/index:uniformTitle[1]|$index/index:display/index:title|$index/index:mTitle|<wrap>{$uri}</wrap>
	    let $label := element atom:title {xs:string($label[1])}
	    let $author := 
	        element atom:author {
	            element atom:name {fn:string($index/index:contributor[1])}
	        }
	    return
	        if ( $deprecated ) then
	            element at:deleted-entry {
	                $label,
	                $mDate,
				    $linkMain,
	                $linkRDFXML,
	                $linkNT,
	                $linkJSON,
					$linkJSONLD,                
	                $atomid,
	                $author,	               
	                $cDate,
	                element atom:content { fn:concat("This item was deleted at " , $mDateString) }
	            }
	        else
	            element atom:entry {
	                $label,
					$mDate,
	                $linkMain,
	                $linkRDFXML,
	                $linkNT,
	                $linkJSON,             
	                $linkJSONLD,            
	                $atomid,
	                $author,	             
	                $cDate
	            }
};

(:~
:   Get Search results.  Build options here, pass to 
:   SearchML function.
:
:   @param  $schemeURI      is the relative schemeURI 
:   @param  $start          is the search results start position
:   @param  $count          is the number of search results to return
:   @return element         as search:response element
: 
overkill, dropped by nate
:)
(:declare function get-search-results(
    $schemeURI as xs:string,     
    $start as xs:integer,
    $count as xs:integer
    ) as element(search:response)
{
    
     feed:search-feed($schemeURI,$start,$count)
};
:)


(:~
:   Get Advanced Search results.  Build options here, pass to 
:   feed function.
:
:   @param  $schemeURI      is the relative schemeURI
:   @param  $field         is the field to search (040a) currently assumes mxe
:   @param  $value         is the text searched for (cmalg)
:   @param  $start          is the search results start position
:   @param  $count          is the number of search results to return
:   @return element         as search:response element
:)
declare function get-advanced-search-results(
    $schemeURI as xs:string,
    $field as xs:string,
    $value as xs:string,
    $start as xs:integer,
    $count as xs:integer
    ) as element(search:response)
{
    let $directory := fn:concat($schemeURI , "/")
    
    let $node:= 
			if (fn:string-length($field) = 4) then
                 		fn:concat("mxe:d",fn:substring($field, 1,3),"_subfield_",fn:substring($field, 4,1)) 
            else if (fn:string-length($field) gt 4) then
				           $field
			      else
                   fn:concat("mxe:datafield_",$field) 
   
    return feed:search-advanced-feed($directory,$node, $value,$start,$count)
};
(:~
:   Get Total number of pages. Number of records per page
:   is an option.  Currently set to 100.
:
:   @param  $results        is the result XML from the search, contains the total hits
:   @param  $perPage        is how many records per atom page
:   @return $totalPage      as integer         
:)
declare function total-scheme-pages(
    $results as element(search:response),
    $perPage as xs:integer
    ) as xs:integer
{
    let $totalRecords := xs:integer($results/@total) 
    let $totalPages := fn:floor($totalRecords div $perPage)
    return 
		if ($totalPages =0 ) then 1 
		else $totalPages 
};
