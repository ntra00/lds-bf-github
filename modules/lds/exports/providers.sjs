const sem = require('/MarkLogic/semantics.xqy');
const json = require('/MarkLogic/json/json.xqy');

var ns_idx = "info:lc/xq-modules/lcindex";

var label = xdmp.getRequestField("label", "");
var start = xdmp.getRequestField("start", "0");
var pagesize = xdmp.getRequestField("pagesize", "10");

queryTypes = '\
PREFIX rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#> \
PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#> \
PREFIX bf: <http://id.loc.gov/ontologies/bibframe/> \
SELECT DISTINCT ?t \
WHERE { \
  ?a rdfs:label $label . \
  ?pa bf:agent ?a . \
  ?s bf:provisionActivity ?pa . \
  ?pa rdf:type ?t . \
}\
';

queryReferences = '\
PREFIX rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#> \
PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#> \
PREFIX bf: <http://id.loc.gov/ontologies/bibframe/> \
SELECT ?s ?lccn \
WHERE { \
  ?a rdfs:label $label . \
  ?pa bf:agent ?a . \
  ?pa rdf:type $t . \
  \
  ?s bf:provisionActivity ?pa . \
  ?s bf:identifiedBy ?i . \
  ?i rdf:type bf:Lccn . \
  ?i rdf:value ?lccn . \
}\
LIMIT 2 \
';

var values = 
    cts.elementValues(
      fn.QName(ns_idx, "imprint"),
      label,
      ["collation=http://marklogic.com/collation/en/S1"]
    );
var count = fn.count(values)

var stop = parseInt(start) + parseInt(pagesize) + 1
var selectValues = []
var pos = 1
for (var v of values) {
  if (pos > start && pos < stop) {
    selectValues.push(v.toString())
  }
  pos += 1
  if (pos > stop) {
      break;
  }
}

xdmp.log(selectValues)

skipFirst = true;
if (label == "") {
  skipFirst = false;
}

var pos = 0;
results = [];
for (var i=0; i < selectValues.length; i++) {
  pos += 1;
  var strv = selectValues[i];
  
  if (strv.trim() == "") { continue; }
  if (strv.replace(/‏/g, "").trim() == "") { continue; }
  
  var bindings = {'label': strv};
  rangeQuery = cts.elementRangeQuery(fn.QName(ns_idx, "imprint"), "=", strv, ["collation=http://marklogic.com/collation/en/S1", "uncached"]);
  store = sem.store(null, rangeQuery);
  queryResults = sem.sparql(queryTypes, bindings, "optimize=1", store);
  var types = [];
  for (var r of queryResults) {
    var tstr = r.t.toString();
    if (tstr != "http://id.loc.gov/ontologies/bibframe/ProvisionActivity" && tstr != "http://id.loc.gov/ontologies/bibframe/") {
      types.push(tstr);
    }
  }
  
  sources = [];
  for (var x=0; x < types.length; x++) {
    var t = types[x];
    var bindings = {'label': strv, "t": sem.iri(t)};
    queryResults = sem.sparql(queryReferences, bindings, null, store);
    for (var r of queryResults) {
      source = {"uri": r.s.toString(), "lccn": r.lccn.toString().trim(), "type": t};
      sources.push(source);
    }
  }
  result = {"label": strv, "sources": sources};
  results.push(result);
}

response = {"count": count, "results": results};
response 

