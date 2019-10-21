declare namespace cqlparser = "java:org.z3950.zing.cql.CQLParser";
declare namespace cqlnode = "java:org.z3950.zing.cql.CQLNode";
declare namespace javastr = "java:java.lang.String";
declare namespace javaint = "java:java.lang.Integer";

declare variable $q := request:get-parameter("q", ());
declare variable $as := request:get-parameter("as", "xcql");

let $space := javaint:valueOf("0")
let $cqlquery := $q
let $stringConstructor := javastr:new($cqlquery)
let $cqlConstructor := cqlparser:new()
let $parse := cqlparser:parse($cqlConstructor, $stringConstructor)
let $cql := cqlnode:toCQL($parse)
return
    if (matches($as, 'xcql', 'i')) then
        <cqlResult>
            <cql>{$cql}</cql>
            <xcql>{util:parse(cqlnode:toXCQL($parse, $space))}</xcql>
        </cqlResult>
    else if (matches($as, "cql", 'i')) then 
        util:serialize(<string>{$cql}</string>, "media-type=text/plain encoding=UTF-8 method=text")
    else
        "Error"