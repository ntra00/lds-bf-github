xquery version "1.0-ml";

module namespace vp = "http://www.marklogic.com/ps/view/v-page";
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/xq/lscoll/config.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/xq/lscoll/lib/l-param.xqy";
import module namespace ssk = "info:lc/xq-modules/search-skin" at "/xq/modules/search-skin.xqy";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";

declare function vp:three-area($main as element(div)+, $facets as element(div)) as element(div) {
    <div id="ds-container" style="min-height: 1400px;">
        <div id="ds-body">
            {$main}
        </div>
        {$facets}
    </div>
};

declare function vp:output($content as element(div)+) as element(html) {
    let $mime := "application/xhtml+xml"
    let $myq := 
        if (exists(lp:get-param-single($lp:CUR-PARAMS,'q'))) then
            concat("Search results for: ", lp:get-param-single($lp:CUR-PARAMS,'q'))
        else
            "Search"
    let $myhead := ssk:header($myq)
    let $myfooter := ssk:footer()
    let $html :=
        <html xmlns="http://www.w3.org/1999/xhtml">
            {$myhead/head}
            <body>
                <div id="msgblock">
                    <div id="msgbox">
                        <div class="fright">
                            <a id="msgclose">
                                <img alt="Close" src="/static/natlibcat/images/close.jpg"/>
                            </a>
                        </div>
                        <break class="break"/>
                        <div id="msgcontainer">
                            <div id="msgcontent">&nbsp;</div>
                        </div>
                    </div>
                </div>
                {$myhead/body/div}
                {$content}
                {$myfooter/div}
                <!-- <script type='text/javascript' src='http://www.loc.gov:8081/global/s_code.js'></script> -->
            </body>
        </html>
    return $html
};
