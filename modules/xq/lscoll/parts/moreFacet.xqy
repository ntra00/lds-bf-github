xquery version "1.0-ml";

declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace mlapp = "http://www.marklogic.com/mlapp";
declare namespace e = "http://marklogic.com/entity";

import module namespace cfg = "http://www.marklogic.com/ps/config" at "/xq/lscoll/config.xqy";
import module namespace lq = "http://www.marklogic.com/ps/lib/l-query" at "/xq/lscoll/lib/l-query.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/xq/lscoll/lib/l-param.xqy";
import module namespace vf = "http://www.marklogic.com/ps/view/v-facets" at "/xq/lscoll/view/v-facets.xqy";

let $params := $lp:CUR-PARAMS
let $id := lp:get-param-single($params, 'id')
let $params := lp:param-remove-all($params, 'id')
return
    vf:facet-data-more($params,  $id)