xquery version "1.0-ml";

module namespace cfg = "http://www.marklogic.com/ps/config";

declare namespace mlapp = "http://www.marklogic.com/mlapp";
declare namespace e = "http://marklogic.com/entity";
declare namespace gml = "http://www.opengis.net/gml";


declare variable $APP-NAME as xs:string := "Example Application";
declare variable $PAGE-HEADING as xs:string := "Example Application";

declare variable $RESULTS-PER-PAGE as xs:integer := 10;
declare variable $FACETS-PER-BOX as xs:integer := 10;
declare variable $FACET-YEARS-BACK as xs:integer := 5;
declare variable $SHOW-ZERO-COUNT-FACETS as xs:boolean := fn:false();
declare variable $SHOW-WHOAMI as xs:boolean := fn:false();
declare variable $CACHE-FACETS as xs:boolean := fn:false();
declare variable $DEFAULT-COLLECTION as xs:string := "/catalog/";

declare variable $HTTP_EXPIRES_CACHE := xs:dayTimeDuration("PT12H");

declare variable $SEARCH-OPTIONS as node() :=
    <options xmlns="http://marklogic.com/appservices/search">
        <term-option>case-insensitive</term-option>
        <term-option>diacritic-insensitive</term-option>
        <term-option>punctuation-insensitive</term-option>
        <term-option>whitespace-insensitive</term-option>
        <term-option>stemmed</term-option>
    </options>;

declare variable $ATOM-SEARCH-OPTIONS as node() :=
    <options xmlns="http://marklogic.com/appservices/search">
        <return-qtext>true</return-qtext>
        <return-facets>false</return-facets>
        <term-option>case-insensitive</term-option>
        <term-option>diacritic-insensitive</term-option>
        <term-option>punctuation-insensitive</term-option>
        <term-option>whitespace-insensitive</term-option>
        <term-option>stemmed</term-option>
    </options>;

declare variable $FACET-PAGE-CONTROL as node() :=
    <page-controls>
        <page-control>
            <from>search</from>
            <to>results</to>
        </page-control>
        <page-control>
            <from>results</from>
            <to>results</to>
        </page-control>
        <page-control>
            <from>detail</from>
            <to>results</to>
        </page-control>
        <page-control>
            <from>viz</from>
            <to>results</to>
        </page-control>
    </page-controls>;

declare variable $DISPLAY-ELEMENTS as node() :=

    let $f-counter := 0
    return
    <display>
      <elt>
          <facet-id>{ xdmp:set($f-counter, $f-counter + 1), fn:concat("f",$f-counter) }</facet-id>
         <page>search</page>
          <page>results</page>
          <view-area>left</view-area>
          <view-name>Access</view-name>
          <starts-hidden>false</starts-hidden>
          <data-function>vf:facet-data</data-function>
          <facet-param>info:lc/xq-modules/lcindex</facet-param>
          <facet-param>digitized</facet-param>
          <facet-operation>or</facet-operation>
        </elt>
        
        <elt>
          <facet-id>{ xdmp:set($f-counter, $f-counter + 1), fn:concat("f",$f-counter) }</facet-id>
          <page>search</page>
          <page>results</page>
          <view-area>left</view-area>
          <view-name>Format</view-name>
          <starts-hidden>false</starts-hidden>
          <data-function>vf:facet-data</data-function>
          <facet-param>info:lc/xq-modules/lcindex</facet-param>
          <facet-param>materialGroup</facet-param>
          <facet-operation>or</facet-operation>
        </elt>
    <elt>
          <facet-id>{ xdmp:set($f-counter, $f-counter + 1), fn:concat("ft",$f-counter) }</facet-id>
          <page>search</page>
          <page>results</page>
          <view-area>left</view-area>
          <view-name>LC Classification</view-name>
          <starts-hidden>false</starts-hidden>
          <data-function>vf:facet-two-tier</data-function>
          <facet-param>info:lc/xq-modules/lcindex</facet-param>
          <!--facet-param>info:lc/xq-modules/index-utils</facet-param-->
          <facet-param>lcc1</facet-param>
          <facet-param>info:lc/xq-modules/lcindex</facet-param>
          <!--facet-param>info:lc/xq-modules/index-utils</facet-param-->
          <facet-param>lcc2</facet-param>
          <facet-operation>or</facet-operation>
        </elt>
        
        <elt>
          <facet-id>{ xdmp:set($f-counter, $f-counter + 1), fn:concat("f",$f-counter) }</facet-id>
          <page>search</page>
          <page>results</page>
          <view-area>left</view-area>
          <view-name>Language</view-name>
          <starts-hidden>false</starts-hidden>
          <data-function>vf:facet-data</data-function>
          <facet-param>info:lc/xq-modules/lcindex</facet-param>
          <facet-param>language</facet-param>
          <facet-operation>and</facet-operation>
        </elt>
        <elt>
          <facet-id>{ xdmp:set($f-counter, $f-counter + 1), fn:concat("f",$f-counter) }</facet-id>
          <page>search</page>
          <page>results</page>
          <view-area>left</view-area>
          <view-name>Publication Date</view-name>
          <starts-hidden>false</starts-hidden>
          <data-function>vf:facet-data</data-function>
          <facet-param>info:lc/xq-modules/lcindex</facet-param>
          <facet-param>beginpubdate</facet-param>
          <facet-operation>or</facet-operation>
        </elt>
        <elt>
          <facet-id>{ xdmp:set($f-counter, $f-counter + 1), fn:concat("f",$f-counter) }</facet-id>
          <page>search</page>
          <page>results</page>
          <view-area>left</view-area>
          <view-name>Reading Room</view-name>
          <starts-hidden>false</starts-hidden>
          <data-function>vf:facet-data</data-function>
          <facet-param>info:lc/xq-modules/lcindex</facet-param>
          <facet-param>location</facet-param>
          <facet-operation>or</facet-operation>
        </elt>
        <!--elt>
          <facet-id>{ xdmp:set($f-counter, $f-counter + 1), fn:concat("f",$f-counter) }</facet-id>
          <page>search</page>
          <page>results</page>
          <view-area>left</view-area>
          <view-name>Reading Room</view-name>
          <starts-hidden>false</starts-hidden>
          <data-function>vf:facet-data</data-function>
          <facet-param>info:lc/xq-modules/lcindex</facet-param>
          <facet-param>location</facet-param>
          <facet-operation>or</facet-operation>
        </elt-->
        <!--elt>
          <facet-id>{ xdmp:set($f-counter, $f-counter + 1), fn:concat("f",$f-counter) }</facet-id>
          <page>search</page>
          <page>results</page>
          <view-area>left</view-area>
          <view-name>LC Classification No.</view-name>
          <starts-hidden>true</starts-hidden>
          <data-function>vf:facet-data</data-function>
          <facet-param>info:lc/xq-modules/lcindex</facet-param>
          <facet-param>lcclass</facet-param>
          <facet-operation>or</facet-operation>
        </elt-->
         <!--elt>
          <facet-id>{ xdmp:set($f-counter, $f-counter + 1), fn:concat("f",$f-counter) }</facet-id>
          <page>search</page>
          <page>results</page>
          <view-area>left</view-area>
          <view-name>LC Class</view-name>
          <starts-hidden>false</starts-hidden>
          <data-function>vf:facet-data</data-function>
          <facet-param>info:lc/xq-modules/lcindex</facet-param>
          <facet-param>lccfacet</facet-param>
          <facet-operation>or</facet-operation>
        </elt-->
         
        <!-- <elt>
          <facet-id>{ xdmp:set($f-counter, $f-counter + 1), fn:concat("f",$f-counter) }</facet-id>
          <page>search</page>
          <page>results</page>
          <page>detail</page>
          <view-area>left</view-area>
          <view-name>Collection</view-name>
          <starts-hidden>false</starts-hidden>
          <data-function>vf:facet-data</data-function>
          <facet-param>info:lc/xq-modules/lcindex</facet-param>
          <facet-param>memberOf</facet-param>
          <facet-operation>or</facet-operation>
        </elt> -->
        
       <!--  <elt>
          <facet-id>{ xdmp:set($f-counter, $f-counter + 1), fn:concat("f",$f-counter) }</facet-id>
          <page>search</page>
          <page>results</page>
          
          <view-area>left</view-area>
          <view-name>Material Type</view-name>
          <starts-hidden>false</starts-hidden>
          <data-function>vf:facet-data</data-function>
          <facet-param>info:lc/xq-modules/lcindex</facet-param>
          <facet-param>materialGroup</facet-param>
          <facet-operation>or</facet-operation>
        </elt> -->
      
       
    </display>
;

      

