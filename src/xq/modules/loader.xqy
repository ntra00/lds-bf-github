xquery version "1.0-ml";

module namespace load = "info:lc/xq-modules/loader";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare namespace dir = "http://marklogic.com/xdmp/directory";
declare namespace dlopts = "xdmp:document-load";
declare namespace mets = "http://www.loc.gov/METS/";

declare function load:pae-from-fs($path as xs:string) as empty-sequence() {
    load:from-fs($path, "/pae/", false())
};

declare function load:from-fs($fspath as xs:string, $mldir as xs:string, $recurse as xs:boolean) {

(: Takes a directory path that resides on marklogic1 as a string and loads XML files, but no dirs. :)  
(: XML files with only certain file extensions are accepted.  Extension rules are case-insensitive.:)
(: Only files stored at the top level of the directory will be loaded -- no recursion occurs.      :)
(: After loading, the function sleeps to prevent too many files from opening. `ulimit -n` problem? :)

    let $dirlist := xdmp:filesystem-directory($fspath)
    for $entry in $dirlist/dir:entry
    let $type := $entry/dir:type/string()
    let $file := $entry/dir:filename/string()
    let $path := $entry/dir:pathname/string()
    let $newmldir := concat($mldir, $file, '/')
    let $options :=
        <dlopts:options>
          <dlopts:uri>{$newmldir}</dlopts:uri>
        </dlopts:options>
    let $logic :=
        if ($recurse eq true()) then
            if ($type eq "directory") then (
                xdmp:directory-create($newmldir), 
                load:from-fs($path, $newmldir, true())
            )
            else if ($type eq 'file') then
                load:file($file, $options)
            else
                "This only works on files and directories..."
        else
            (: $recurse eq false()  :)
            let $out :=
                if ($type eq 'file') then
                    load:file($file, $options)
                else ()
            return $out
    return $logic
};

declare function load:file($file as xs:string, $options as element(dlopts:options)){
    let $filename := $file
    let $file_ext := tokenize($filename, '\.')[last()]
    let $filepattern := '(xqy|xml|kml|gml|georss|trix|rdf|skos|atom|rss|marcxml|mods|mets|ead|mxe|alto)'
    let $try :=
        if (contains($filename, '.') and matches($file_ext, $filepattern, 'i')) then
            (xdmp:document-load($file, $options), xdmp:sleep(200))
        else
            "Error"
    return $try
};
