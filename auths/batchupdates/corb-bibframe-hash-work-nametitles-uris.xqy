xquery version "1.0-ml";

let $uris := cts:uris((),(),               
              cts:and-not-query( 
                  cts:and-not-query( 
                                  cts:collection-query("/bibframe/transformedTitles"),                                 
                                  cts:collection-query("/bibframe/mergeFoundBibWorks")
                    )
                    ,
                    cts:collection-query("/bibframe/mergeDone")
                    )
                 )
           )

	return
		(fn:count($uris), $uris) 

(:
all:

let $uris := cts:uri-match("/resources/works/lw*", ("ascending", "concurrent"))
	return
		(fn:count($uris), $uris) 

(1,"/resources/works/lw2002032255.xml")

austen?
(1,"/resources/works/lw98081015.xml")
twain huck finn:
(1,"/resources/works/lw79132705.xml")
haydn, symph, sel:
(1,"/resources/works/lw99269797.xml")


(1,"/resources/works/lw09701867.xml")

name titles that have not been merged:
cts:uris((),(),               
              cts:and-not-query( 
                  cts:and-not-query( 
                                  cts:collection-query("/bibframe/transformedTitles"),                                 
                                  cts:collection-query("/bibframe/mergeFoundBibWorks")
                    )
                    ,
                    cts:collection-query("/bibframe/mergeDone")
                    )
                    )
                    )

:)


