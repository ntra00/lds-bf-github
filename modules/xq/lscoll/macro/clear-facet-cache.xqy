xquery version "1.0-ml";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

import module namespace vf = "http://www.marklogic.com/ps/view/v-facets" at "/xq/lscoll/view/v-facets.xqy";
import module namespace lfc = "http://www.marklogic.com/ps/lib/l-facet-cache" at "/xq/lscoll/lib/l-facet-cache.xqy";
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/xq/lscoll/config.xqy";

lfc:clear-facet-cache()
    
