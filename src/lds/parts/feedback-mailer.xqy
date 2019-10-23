xquery version "1.0-ml";

import module namespace cfg = "http://www.marklogic.com/ps/config" at "../config.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "../lib/l-param.xqy";
declare namespace em = "URN:ietf:params:email-xml:";
declare namespace rf = "URN:ietf:params:rfc822:";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";

declare function local:mailer($name as xs:string?, $email as xs:string?, $question as xs:string?, $record-refer as xs:string?) as element(em:Message) {
    <em:Message xmlns:em="URN:ietf:params:email-xml:" xmlns:rf="URN:ietf:params:rfc822:">
        <rf:subject>User Feedback</rf:subject>
        <rf:from>
            <em:Address>
                <em:name>{$name}</em:name>
                <em:adrs>{$email}</em:adrs>
            </em:Address>
        </rf:from>
        <rf:to>
            <em:Address>
                <em:name>National Library Catalog Administrator</em:name>
                <em:adrs>{$cfg:ADMIN-EMAIL}</em:adrs>
            </em:Address>
        </rf:to>
        <em:content>{concat($question, "&#x000A;&#x000A;&#x000A;", xdmp:get-request-header("X-Forwarded-For"), "&#x000A;", xdmp:get-request-header("User-Agent"))}</em:content>
    </em:Message>
};

declare function local:validate($type as xs:string, $value as xs:string?) as xs:boolean {
    if (matches($type, '(name|question)')) then
        if (string-length(normalize-space($value)) gt 0) then
            true()
        else
            false()
    else if ($type eq 'email') then
        if (matches(normalize-space($value), "^[A-Za-z0-9._%+-]+@[a-zA-Z0-9.-]+\.[A-Za-z]{2,6}$")) then
            true()
        else
            false()
    else
        false()
};

declare function local:validate-math($math as xs:string, $auth as xs:int?) as xs:boolean {
    let $newmath := tokenize($math, "::")
    let $one := $newmath[1] cast as xs:int
    let $two := $newmath[3] cast as xs:int
    let $total :=
        if ($newmath[2] eq 'plus') then
            $one + $two
        else if ($newmath[2] eq 'multiplied by') then
            $one * $two
        else
            $one - $two
    return
        if ($total eq $auth) then
            true()
        else
            false()        
};

let $name as xs:string? := lp:get-param-single($lp:CUR-PARAMS, "fbkname")
let $email as xs:string? := lp:get-param-single($lp:CUR-PARAMS, "fbkemail")
let $question as xs:string? := lp:get-param-single($lp:CUR-PARAMS, "fbkquestion")
let $record-refer := lp:get-param-single($lp:CUR-PARAMS, "fbkrecord", "/")
let $math as xs:string? := lp:get-param-single($lp:CUR-PARAMS, "fbkmath")
let $auth as xs:string? := lp:get-param-single($lp:CUR-PARAMS, "fbkauthenticate", "1")
let $validname := local:validate("name", $name)
let $validemail := local:validate("email", $email)
let $validquestion := local:validate("question", $question)
let $validauth := local:validate-math($math, $auth cast as xs:int)
let $sendmail := 
    if ($validquestion eq true() and $validemail eq true() and $validname eq true() and $validauth eq true()) then
        try {
            xdmp:email(local:mailer($name, $email, $question, $record-refer))
        } catch($e) {
            $e
        }
    else
        <error:error>Error</error:error>
return
    if ($sendmail instance of element(error:error)) then
        let $msg := "Please specify a VALID email address.  The existence of server domains is checked during the attempt to validate email addresses.  Also, make sure the 'name' and 'comment' fields are not blank, and that you answer the math question correctly.  Otherwise this will cause an error."
        return
            (xdmp:set-response-code(400, "Bad Request"), xdmp:set-response-content-type(concat("text/html", "; charset=utf-8")), $msg)
    else
        xdmp:redirect-response($record-refer)(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)