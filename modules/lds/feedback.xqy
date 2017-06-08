xquery version "1.0-ml";

import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/nlc/lib/l-param.xqy";
import module namespace vs = "http://www.marklogic.com/ps/view/v-search" at "/nlc/view/v-search.xqy";
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/nlc/config.xqy";
import module namespace metsutils = "info:lc/xq-modules/mets-utils" at "/xq/modules/mets-utils.xqy";
import module namespace marcutils = "info:lc/xq-modules/marc-utils" at "/xq/modules/marc-utils.xqy";
import module namespace ssk = "info:lc/xq-modules/search-skin" at "/xq/modules/natlibcat-skin.xqy";
import module namespace resp = "info:lc/xq-modules/http-response-utils" at "/xq/modules/http-response-utils.xqy";
import module namespace mime = "info:lc/xq-modules/mime-utils" at "/xq/modules/mime-utils.xqy";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace error = "http://marklogic.com/xdmp/error";
declare namespace mxe2 = "http://www.loc.gov/mxe";

declare function local:output($msie as xs:boolean, $fbkuri as xs:string?, $title as xs:string?, $refer as xs:string?) as element(html) {
    let $detail-refer := 
        if (contains($refer, "/nlc/detail.xqy")) then
            (
                <span id="ds-searchresultcrumb">
                    <a href="{$refer}">Record View</a>
                </span>
            )
        else
            ()
    let $atom := ()   
    let $myq := concat("Feedback: ", $title)
    let $crumbs := ($detail-refer, <span>Feedback</span>)
    let $seo := ()
    let $myhead := ssk:header($myq, $crumbs, $msie, $atom, $seo,"","feedback")
    let $myfooter := ssk:footer()
    let $searchbar :=
        <div id="search-results">
            {vs:render()}
        </div>
    let $operators := ('plus', 'minus', 'multiplied by')
    let $rand1 := xdmp:random(9)
    let $rand2 := xdmp:random(4)
    let $rand3 := xdmp:random(3)
    let $operator :=
        if ($rand3 eq 0) then
            $operators[1]
        else
            $operators[$rand3]
    let $num1 :=
        if ($rand1 eq (0, 1, 2)) then
            5 cast as xs:string
        else if ($rand1 eq (3, 4)) then
            8 cast as xs:string
        else
            $rand1 cast as xs:string
    let $num2 := $rand2 cast as xs:string
    let $whatis := concat("What does ", $num1, " ", $operator, " ", $num2, " equal?")
    let $math := string-join(($num1, $operator, $num2), "::")
    let $formhtml :=
                <form action="/nlc/parts/feedback-mailer.xqy" accept-charset="utf-8" method="post" id="commentform" class="feedback">
                    <p>
                        <span class="required">*</span>
                        <label for="fbkname">Your Name</label>
                        <br />
                        <input name="fbkname" size="50" id="fbkname" value="" class="required"/>
                    </p>
                    <p>
                        <span class="required">*</span>
                        <label for="fbkemail">Your Email</label>
                        <br />
                        <input name="fbkemail" size="50" id="fbkemail" value="" class="required email"/>
                    </p>
                    <p>
                        <span class="required">*</span>
                        <label for="fbkquestion">Comments</label>
                        <br />
                        <textarea name="fbkquestion" id="fbkquestion" rows="15" cols="58" class="required">
                            {
                                if ($refer) then
                                    concat("Comments on URL &lt;", $refer, "&gt;")
                                else
                                    ()
                            }
                        </textarea>
                    </p>
                    <p>
                        <span class="required">*</span>
                        <label for="fbkauthenticate">{$whatis} (Enter digits only)</label>
                        <br />
                        <input name="fbkauthenticate" size="50" id="fbkauthenticate" value="" class="required digits"/>
                    </p>
                    <input value="{$refer}" type="hidden" alt="fbkrecord" name="fbkrecord"/>
                    <input value="{$math}" type="hidden" alt="fbkmath" name="fbkmath"/>
                    <p class="box-btns">
                        <button id="cancelB" type="reset" value="clear">Clear</button> &nbsp; <button id="submitB" type="submit" value="Submit" class="primary">Submit</button>
                    </p>
                </form>     
    return
        <html xmlns="http://www.w3.org/1999/xhtml">
            {$myhead/head}
            <body>
                {$myhead/body/div}
                <div id="ds-container">
                    <div id="ds-body">
                        {$searchbar}
                        <div id="dsresults">
                            <div id="content-feedback">
                                <h1>Send Us Your Feedback</h1>
                                <p>Please provide your suggestions and report errors using this form.  In order for us to get back to you, we ask that you provide your contact information along with your comments below. Alternatively, contact us directly at <a href="mailto:{$cfg:ADMIN-EMAIL}?subject=User Feedback">{$cfg:ADMIN-EMAIL}</a></p>
                                {$detail-refer[2]}
                                <p class="req">Required fields are indicated with an * asterisk.</p>
                                {$formhtml}
                            </div>
                        </div>
                    </div>                    
                <!-- end id:ds-container -->
                </div>
                {$myfooter/div}
                <!-- <script type='text/javascript' src='http://www.loc.gov:8081/global/s_code.js'></script> -->
            </body>
        </html>
};

let $duration := $cfg:HTTP_EXPIRES_CACHE
let $mime := mime:safe-mime(lp:get-param-single($lp:CUR-PARAMS, 'mime', 'text/html'))
let $uri as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'uri')
let $title as xs:string? := lp:get-param-single($lp:CUR-PARAMS, 'title')
let $refer as xs:string? := xdmp:get-request-header("Referer")
return 
    (
        xdmp:set-response-content-type(concat($mime, "; charset=utf-8")), 
        xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
        (:xdmp:add-response-header("Cache-Control", resp:cache-control($duration)),  :)
        '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">', 
        local:output(false(), $uri, $title, $refer)
    )