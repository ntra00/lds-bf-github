xquery version "1.0-ml";


module namespace vv = "http://www.marklogic.com/ps/view/v-viz";

import module namespace cfg = "http://www.marklogic.com/ps/config" at "../config.xqy";
import module namespace lq = "http://www.marklogic.com/ps/lib/l-query" at "../lib/l-query.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "../lib/l-param.xqy";
import module namespace md = "http://www.marklogic.com/ps/model/m-doc" at "../model/m-doc.xqy";

declare default element namespace "http://www.w3.org/1999/xhtml";

declare function vv:render() {

        let $return-string := lp:param-string(
            lp:param-replace-or-insert($lp:CUR-PARAMS,"/page","results"))
        let $viz-facet-string := lp:param-string(
            lp:param-apply-facet-page-control($lp:CUR-PARAMS))
        
        return
        <div id="content-results">
            <div class="ui-widget" style="height:2em;">
                <span id="section-title" class="fleft">Link Analysis</span>
                <span class="fright">            
                    <a id="viz-return-link" 
                       href="/?{$return-string}"
                       rel="{$return-string}">
                        Return to Results
                    </a>
                </span>
                <br class="clear"/>
            </div>
            
            <div id="viz">
                <applet codebase="/viz/classes" 
                        code="gov.dos.ta.viz.applet.CooccurGraphView" 
                        name="gov.dos.ta.viz.applet.CooccurGraphView" 
                        xmlns="http://www.w3.org/1999/xhtml" 
                        width="100%" 
                        height="500">
                    <param name="dataserviceurl" 
                           value="{$cfg:APP-LOCATION}viz/gml.xqy?{$return-string}"/>
                    <param name="name" value="gov.dos.ta.viz.applet.CooccurGraphView"/>
                    <param name="clickUrl" value="{$cfg:APP-LOCATION}?{$viz-facet-string}"/>
                </applet>
            </div>
        </div>
};