xquery version "1.0-ml";
(:uri list of individual marc bib records:)
(:
let $uris := cts:uris((), (), cts:collection-query("/bibframe-process/records/"))
return (fn:count($uris) , $uris[1 to 10] )
:)

(: finn,  mergeable records
vietnamese: 16938761
"/bibframe-process/records/16938761.xml",
"/bibframe-process/records/18159222.xml",
"/bibframe-process/records/12963137.xml",
"/bibframe-process/records/13998011.xml",
"/bibframe-process/records/4734235.xml")
cradle:
"/bibframe-process/records/8113983.xml",

kyrie:
"/bibframe-process/records/5647841.xml",
haydn:
(1, "/bibframe-process/records/7229752.xml")





let $uris := cts:uris((), (), cts:collection-query("/bibframe-process/records/"))
return (fn:count($uris) , $uris)
:)
(: used to just fake the load program into working, for now :)
(1, "/bibframe-process/records/5226.xml")
