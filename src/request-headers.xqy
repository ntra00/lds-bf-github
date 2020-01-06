xquery version "1.0-ml";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

for $z in xdmp:get-request-header-names()
return
    concat($z, ": ", xdmp:get-request-header($z))
