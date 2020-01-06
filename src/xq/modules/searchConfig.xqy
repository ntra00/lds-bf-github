xquery version "1.0-ml";

module namespace sc = "info:lc/xq-modules/search-config";
declare default element namespace "http://www.w3.org/1999/xhtml";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace search = "http://marklogic.com/appservices/search";

declare variable $sc:OLD-GLOBAL-SEARCH-CONFIG as element(search:wrapper) :=
    <search:wrapper xmlns:search="http://marklogic.com/appservices/search">
        <search:results-logic>
            <search:options>
                <search:constraint name="languageTerm">
                    <search:value>
                        <search:element ns="http://www.loc.gov/mods/v3" name="languageTerm"/>
                    </search:value>
                    <search:range type="xs:string" collation="http://marklogic.com/collation/en/S1" facet="true">
                        <search:element ns="http://www.loc.gov/mods/v3" name="languageTerm"/>
                    </search:range>
                </search:constraint>
                <search:constraint name="typeOfResource">
                    <search:value>
                        <search:element ns="http://www.loc.gov/mods/v3" name="typeOfResource"/>
                    </search:value>
                    <search:range type="xs:string" collation="http://marklogic.com/collation/" facet="true">
                        <search:element ns="http://www.loc.gov/mods/v3" name="typeOfResource"/>
                    </search:range>
                </search:constraint>
                <search:constraint name="profile">
                    <search:value>
                        <search:attribute ns="" name="PROFILE"/>
                        <search:element ns="http://www.loc.gov/METS/" name="mets"/>
                    </search:value>
                    <search:range type="xs:string" collation="http://marklogic.com/collation/en/S1" facet="true">
                        <search:element ns="http://www.loc.gov/METS/" name="mets"/>
                        <search:attribute ns="" name="PROFILE"/>
                    </search:range>
                </search:constraint>
                <search:constraint name="dateIssued">
                    <search:value>
                        <search:element ns="http://www.loc.gov/mods/v3" name="dateIssued"/>
                    </search:value>
                    <!--<search:range type="xs:string" collation="http://marklogic.com/collation/en/S1" facet="true">
                        <search:element ns="http://www.loc.gov/mods/v3" name="dateIssued"/>
                    </search:range>-->
                </search:constraint>
                <search:constraint name="digitized">
                    <search:value>
                        <search:element ns="info:lc/xq-modules/lcindex" name="digitized"/>
                    </search:value>
                    <search:range type="xs:string" collation="http://marklogic.com/collation/en/S1" facet="true">
                        <search:element ns="info:lc/xq-modules/lcindex" name="digitized"/>
                    </search:range>
                </search:constraint>
                <search:constraint name="location">
                    <search:value>
                        <search:element ns="info:lc/xq-modules/lcindex" name="location"/>
                    </search:value>
                    <search:range type="xs:string" collation="http://marklogic.com/collation/en/S1" facet="true">
                        <search:element ns="info:lc/xq-modules/lcindex" name="location"/>
                    </search:range>
                </search:constraint>
                <search:constraint name="language">
                    <search:value>
                        <search:element ns="info:lc/xq-modules/lcindex" name="language"/>
                    </search:value>
                    <search:range type="xs:string" collation="http://marklogic.com/collation/en/S1" facet="true">
                        <search:element ns="info:lc/xq-modules/lcindex" name="language"/>
                    </search:range>
                </search:constraint>
                <search:constraint name="publicationDate">
                    <search:value>
                        <search:element ns="info:lc/xq-modules/lcindex" name="beginpubdate"/>
                    </search:value>
                    <search:range type="xs:string" collation="http://marklogic.com/collation/en/S1" facet="true">
                        <search:element ns="info:lc/xq-modules/lcindex" name="beginpubdate"/>
                    </search:range>
                </search:constraint>
                <search:constraint name="shortName">
                    <search:value>
                        <search:element ns="info:lc/xq-modules/lcindex" name="shortName"/>
                    </search:value>
                    <search:range type="xs:string" collation="http://marklogic.com/collation/en/S1" facet="true">
                        <search:element ns="info:lc/xq-modules/lcindex" name="shortName"/>
                    </search:range>
                </search:constraint>
                <search:term>
                    <search:empty apply="no-results" />
                    <!--<search:term-option>diacritic-insensitive</search:term-option>
					<search:term-option>punctuation-insensitive</search:term-option>
                    <search:term-option>case-insensitive</search:term-option>-->
                </search:term>
                <search:return-results>true</search:return-results>
                <search:return-facets>false</search:return-facets>
                <search:searchable-expression>/mets:mets/mets:dmdSec/mets:mdWrap/mets:xmlData/(mods:mods|ead:ead)</search:searchable-expression>
                <search:default-suggestion-source>
                    <!-- <search:range collation="http://marklogic.com/collation/" type="xs:string" facet="true">
                        <search:element ns="http://www.loc.gov/mods/v3" name="topic"/>
                        </search:range> -->
                    <search:range collation="http://marklogic.com/collation/" type="xs:string" facet="true">
                        <search:element ns="http://www.loc.gov/mods/v3" name="title"/>
                    </search:range>
                </search:default-suggestion-source>
                <search:sort-order direction="descending">
                    <search:score/>
                </search:sort-order>
                <search:sort-order direction="ascending">
                    <search:score/>
                </search:sort-order>
                <search:sort-order type="xs:string" collation="http://marklogic.com/collation/en/S1" direction="descending">
                    <search:element ns="info:lc/xq-modules/lcindex" name="datesort"/>
                </search:sort-order>
                <search:sort-order type="xs:string" collation="http://marklogic.com/collation/en/S1" direction="ascending">
                    <search:element ns="info:lc/xq-modules/lcindex" name="datesort"/>
                </search:sort-order>
                <search:sort-order type="xs:string" collation="http://marklogic.com/collation/" direction="descending">
                    <search:element ns="http://www.loc.gov/mods/v3" name="namePart"/>
                </search:sort-order>
                <search:sort-order type="xs:string" collation="http://marklogic.com/collation/" direction="ascending">
                    <search:element ns="http://www.loc.gov/mods/v3" name="namePart"/>
                </search:sort-order>
                <search:debug>true</search:debug>
            </search:options>
        </search:results-logic>
        <search:facets-logic>
            <search:options>
                <search:constraint name="digitized">
                    <search:range type="xs:string" collation="http://marklogic.com/collation/en/S1" facet="true">
                        <search:element ns="info:lc/xq-modules/lcindex" name="digitized"/>
                    </search:range>
                </search:constraint>
                <search:constraint name="typeOfResource">
                    <search:range type="xs:string" collation="http://marklogic.com/collation/" facet="true">
                        <search:element ns="http://www.loc.gov/mods/v3" name="typeOfResource"/>
                    </search:range>
                </search:constraint>
                <search:constraint name="profile">
                    <search:range type="xs:string" collation="http://marklogic.com/collation/en/S1" facet="true">
                        <search:element ns="http://www.loc.gov/METS/" name="mets"/>
                        <search:attribute ns="" name="PROFILE"/>
                    </search:range>
                </search:constraint>
                <!--<search:constraint name="dateIssued">
                    <search:range type="xs:string" collation="http://marklogic.com/collation/en/S1" facet="true">
                        <search:element ns="http://www.loc.gov/mods/v3" name="dateIssued"/>
                        <search:bucket name="pre19" ge="0" le="1799" anchor="0">Pre-19th century</search:bucket>
                        <search:bucket name="19th" ge="1800" lt="1899" anchor="0">19th century</search:bucket>
                        <search:bucket name="20th" ge="1900" le="1999" anchor="0">20th century</search:bucket>
                        <search:bucket name="21st" ge="2000" le="2099" anchor="0">21st century</search:bucket>
                    </search:range>
                </search:constraint>-->
                <search:constraint name="languageTerm">
                    <search:range type="xs:string" collation="http://marklogic.com/collation/en/S1" facet="true">
                        <search:element ns="http://www.loc.gov/mods/v3" name="languageTerm"/>
                        <!--<search:bucket name="eng" ge="eng" le="eng" anchor="A">English</search:bucket>
                        <search:bucket name="ara" ge="ara" le="ara" anchor="A">Arabic</search:bucket>
                        <search:bucket name="chi" ge="chi" le="chi" anchor="A">Chinese</search:bucket>
                        <search:bucket name="fre" ge="fre" le="fre" anchor="A">French</search:bucket>
                        <search:bucket name="rus" ge="rus" le="rus" anchor="A">Russian</search:bucket>
                        <search:bucket name="spa" ge="spa" le="spa" anchor="A">Spanish</search:bucket>
                        <search:bucket name="all" ge="aaa" le="zzz" anchor="A">All languages</search:bucket>-->
                    </search:range>
                </search:constraint>
                <search:constraint name="classification">
                    <search:range type="xs:string" collation="http://marklogic.com/collation/" facet="true">
                        <search:element ns="http://www.loc.gov/mods/v3" name="classification"/>
                        <search:bucket name="LCC_A-M" ge="A" le="M" anchor="A">A-M LC Classification</search:bucket>
                        <search:bucket name="LCC_N-Z" ge="N" le="Z" anchor="A">N-Z LC Classification</search:bucket>
                        <search:bucket name="Non-LCC" ge="0" le="9" anchor="A">Non-LC Classification</search:bucket>
                    </search:range>
                </search:constraint>
                <search:constraint name="location">
                    <search:range type="xs:string" collation="http://marklogic.com/collation/en/S1" facet="true">
                        <search:element ns="info:lc/xq-modules/lcindex" name="location"/>
                    </search:range>
                </search:constraint>
                <search:constraint name="language">
                    <search:range type="xs:string" collation="http://marklogic.com/collation/en/S1" facet="true">
                        <search:element ns="info:lc/xq-modules/lcindex" name="language"/>
                    </search:range>
                </search:constraint>
                <search:constraint name="publicationDate">
                    <search:range type="xs:string" collation="http://marklogic.com/collation/en/S1" facet="true">
                        <search:element ns="info:lc/xq-modules/lcindex" name="beginpubdate"/>
                    </search:range>
                </search:constraint>
                <search:constraint name="shortName">
                    <search:range type="xs:string" collation="http://marklogic.com/collation/en/S1" facet="true">
                        <search:element ns="info:lc/xq-modules/lcindex" name="shortName"/>
                    </search:range>
                </search:constraint>
                <search:return-results>false</search:return-results>
                <search:return-facets>true</search:return-facets>
            </search:options>
        </search:facets-logic>
    </search:wrapper>
;

declare function sc:global-search-config($searchable_expr as xs:string) as element(search:wrapper) {
    let $se := 
        if (matches($searchable_expr, "ead", "i")) then
            <search:searchable-expression>collection("/catalog/lscoll/ead/")</search:searchable-expression>
        else if (matches($searchable_expr, "bib", "i")) then
            <search:searchable-expression>collection("/catalog/lscoll/lcdb/bib")</search:searchable-expression>
        else
            ()
    return
        <search:wrapper xmlns:search="http://marklogic.com/appservices/search">
            <search:results-logic>
                <search:options>
                    <search:constraint name="memberOf">
                        <search:value>
                            <search:element ns="info:lc/xq-modules/lcindex" name="memberOf"/>
                        </search:value>
                        <search:range type="xs:string" collation="http://marklogic.com/collation/en/S1" facet="true">
                            <search:element ns="info:lc/xq-modules/lcindex" name="memberOf"/>
                        </search:range>
                    </search:constraint>
                    <search:constraint name="digitized">
                        <search:range type="xs:string" collation="http://marklogic.com/collation/en/S1" facet="true">
                            <search:element ns="info:lc/xq-modules/lcindex" name="digitized"/>
                        </search:range>
                    </search:constraint>
                    <search:constraint name="language">
                        <search:value>
                            <search:element ns="info:lc/xq-modules/lcindex" name="language"/>
                        </search:value>
                        <search:range type="xs:string" collation="http://marklogic.com/collation/en/S1" facet="true">
                            <search:facet-option>limit=10</search:facet-option> 
                            <search:element ns="info:lc/xq-modules/lcindex" name="language"/>
                            <search:facet-option>frequency-order</search:facet-option>
                            <search:facet-option>descending</search:facet-option> 
                        </search:range>
                    </search:constraint>
                    <search:term>
                        <search:empty apply="no-results" />
                           <search:term-option>diacritic-insensitive</search:term-option>
					<search:term-option>punctuation-insensitive</search:term-option>
                    <search:term-option>case-insensitive</search:term-option>
                    </search:term>
                    <search:sort-order direction="descending">
                        <search:score/>
                    </search:sort-order>
                    <search:sort-order direction="ascending">
                        <search:score/>
                    </search:sort-order>
                    <search:sort-order type="xs:string" collation="http://marklogic.com/collation/en/S1" direction="descending">
                        <search:element ns="info:lc/xq-modules/lcindex" name="dateSort"/>
                    </search:sort-order>
                    <search:sort-order type="xs:string" collation="http://marklogic.com/collation/en/S1" direction="ascending">
                        <search:element ns="info:lc/xq-modules/lcindex" name="dateSort"/>
                    </search:sort-order>
                    <search:sort-order type="xs:string" collation="http://marklogic.com/collation/en/S1" direction="descending">
                        <search:element ns="info:lc/xq-modules/lcindex" name="nameSort"/>
                    </search:sort-order>
                    <search:sort-order type="xs:string" collation="http://marklogic.com/collation/en/S1" direction="ascending">
                        <search:element ns="info:lc/xq-modules/lcindex" name="nameSort"/>
                    </search:sort-order>
                    <search:sort-order type="xs:string" collation="http://marklogic.com/collation/en/S1" direction="descending">
                        <search:element ns="info:lc/xq-modules/lcindex" name="pubdateSort"/>
                    </search:sort-order>
                    <search:sort-order type="xs:string" collation="http://marklogic.com/collation/en/S1" direction="ascending">
                        <search:element ns="info:lc/xq-modules/lcindex" name="pubdateSort"/>
                    </search:sort-order>
                    <search:return-results>true</search:return-results>
                    <search:return-facets>true</search:return-facets>
                    {$se}
                    <search:debug>true</search:debug>
                </search:options>
            </search:results-logic>
            <search:facets-logic>
                <search:options>
                </search:options>
            </search:facets-logic>
        </search:wrapper>
};(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)