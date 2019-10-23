xquery version "1.0-ml";

module namespace resp = "info:lc/xq-modules/http-response-utils";
import module namespace cfg = "http://www.marklogic.com/ps/config" at "../../lds/config.xqy";
import module namespace functx = "http://www.functx.com" at "functx.xqy";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare function resp:expires($dur as xs:dayTimeDuration) as xs:string {
    (: let $dur := xs:dayTimeDuration("PT24H") :)
    format-dateTime((current-dateTime() + $dur), "[FNn,*-3], [D01] [MNn,*-3] [Y] [H01]:[m01]:[s01] [z]", "en", "AD", "US")
};

declare function resp:cache-control($dur as xs:dayTimeDuration) as xs:string {
    (: $dur := xs:dayTimeDuration("PT24H") :)
    concat("&quot;public, max-age=", functx:total-seconds-from-duration($dur), "&quot;")
};

declare function resp:private-loc-mlnode() as xs:string {
    (: Returns the integer 1, 2, or 3 representing which server served up the content: ml1, ml2, or ml3. :)
    (: Useful for directing requests to specific cluster nodes using sticky sessions.                    :)
    replace($cfg:HOST-NAME, "[^\d]", "")
};(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)