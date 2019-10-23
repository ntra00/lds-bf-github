xquery version "1.0";

(:
:   Module Name: Shared Functions
:
:   Module Version: 1.0
:
:   Date: 2011 Jan 04
:
:   Copyright: Public Domain
:
:   Proprietary XQuery Extensions Used: none
:
:   Xquery Specification: January 2007
:
:   Module Overview:    Shared Functions
:
:)
   
(:~
:   Shared Functions
:
:   @author Kevin Ford (kefo@loc.gov)
:   @since April 18, 2011
:   @version 1.0
:)

module namespace shared = 'info:lc/id-modules/shared#';

(: MODULES :)
(:import module namespace constants           = "info:lc/id-modules/constants#" at "../constants.xqy";:)
import module namespace cfg = "http://www.marklogic.com/ps/config" at "../../lds/config.xqy";
(: NAMESPACES :)
declare namespace xhtml     = "http://www.w3.org/1999/xhtml";

(:FUNCTIONS :)
(:~
:   This function rewrites URIs so that the app works
:   properly in a production or test environment.
:   If the APP is in production, the URL is not rewritten.
:
:   @param  $uri      as xs:string is the URI
:   @return link as string
:)
declare function shared:rewrite-uri($uri as xs:string)
    as xs:string
{
    fn:replace($uri , 'http://id.loc.gov/', $cfg:BF-BASE)
};

(:~
:   This function rewrites URIs so that the app works
:   properly in a production or test environment.
:   If the APP is in production, the URL is not rewritten.
:
:   @param  $uri      as xs:string is the URI
:   @return link as string
:)
declare function shared:dburi2httpuri($uri as xs:string)
    as xs:string
{
    let $u := fn:replace($uri[1], ".xml", "")
    let $u := 
        if ( fn:substring($u, 1, 1) = "/" ) then
            fn:concat( $cfg:BF-BASE , fn:substring($u, 2) )
        else
            fn:concat( $cfg:BF-BASE , $u )
    return $u
};

(:~
:   This function rewrites HTTP URIs in order to determine
:   the database uri fromthe HTTP uri.
:
:   @param  $uri      as xs:string is the URI
:   @return link as string
:)
declare function shared:httpuri2dburi($uri as xs:string)
    as xs:string
{
    let $u := fn:replace($uri,$cfg:BF-BASE, "/")
    let $u := fn:concat($u, ".xml")
    return $u
};

(:~
:   This function generates an IMG element for links 
:   when it is determined the link will take the 
:   user to an external website 
:
:   @param  $link      as xs:string is the link
:   @return xhtml:img element, or not
:)
declare function shared:insert-img-offsite($link as xs:string)
    as element(xhtml:span)*
{
    if (fn:not( fn:contains( $link , 'loc.gov/' ) )) then
        element xhtml:span {
            text {" "},
            element xhtml:img {
                attribute src { "/static/images/newsite.gif" },
                attribute alt { "Offsite link" }
            }
        }
    else ()
};


(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)