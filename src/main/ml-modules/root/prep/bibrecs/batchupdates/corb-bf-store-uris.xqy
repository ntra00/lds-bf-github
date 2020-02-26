xquery version "1.0-ml";
(: split marcxml collections :)
(:clay's old:
	let $uris := cts:uris((), (), cts:collection-query("/bibframe-process/"))

	my new :: 
		/bibframe-process/chunks/catalog01/split_0000000.xml

	ligature problems:, record 8415774
		"/bibframe-process/chunks/catalog08/split_0000790.xml"

	Full:
		let $uris := cts:uri-match("/bibframe-process/chunks/catalog*") 
	
	Deletes: catalog 20 one time load:
	   let $uris := cts:uri-match("/bibframe-process/chunks/catalog20/*")
    All but deletes:
 
        cts:uri-match("/bibframe-process/chunks/catalog0*"),
                cts:uri-match("/bibframe-process/chunks/catalog1*"))

:)

let $uris := ( cts:uri-match("/bibframe-process/chunks/catalog0*"),
                cts:uri-match("/bibframe-process/chunks/catalog1*"))

	return (fn:count($uris) , $uris)
