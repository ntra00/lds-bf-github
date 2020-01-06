xquery version "1.0-ml";

module namespace json-utils = "info:lc/xq-modules/json-utils";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

(: Need to backslash escape any double quotes, backslashes, and newlines :)
declare function json-utils:escape($s as xs:string) as xs:string {
(:  let $s := replace($s, "\\", "\\") :)
  let $s := replace($s, "&quot;&quot;", "\""")
  let $s := replace($s, codepoints-to-string((13, 10)), "\n")
  let $s := replace($s, codepoints-to-string(13), "\n")
  let $s := replace($s, codepoints-to-string(10), "\n")
  return $s
};

declare function json-utils:atomize($x as element()) as xs:string {
  if (count($x/node()) = 0) then 
      'null'
  else if ($x/@type = "number") then
        let $castable := $x castable as xs:float or $x castable as xs:double or $x castable as xs:decimal
        return
            if ($castable) then
                xs:string($x)
            else
                error(concat("Not a number: ", xdmp:describe($x)))
  else if ($x/@type = "boolean") then
        let $castable := $x castable as xs:boolean
        return
            if ($castable) then
                xs:string(xs:boolean($x))
            else
                error(concat("Not a boolean: ", xdmp:describe($x)))
  else concat('"', json-utils:escape($x), '"')
};

(: Print the thing that comes after the colon :)
declare function json-utils:print-value($x as element()) as xs:string {
  if (count($x/*) = 0) then
    json-utils:atomize($x)
  else if ($x/@quote = "true") then
    concat('"', json-utils:escape(xdmp:quote($x/node())), '"')
  else
    string-join(('{',
      string-join(for $i in $x/* return json-utils:print-name-value($i), ","),
    '}'), "")
};

(: Print the name and value both :)
declare function json-utils:print-name-value($x as element()) as xs:string? {
  let $name := name($x)
  let $first-in-array :=
    count($x/preceding-sibling::*[name(.) = $name]) = 0 and
    (count($x/following-sibling::*[name(.) = $name]) > 0 or $x/@array = "true")
  let $later-in-array := count($x/preceding-sibling::*[name(.) = $name]) > 0
  return

  if ($later-in-array) then
    ()  (: I was handled previously :)
  else if ($first-in-array) then
    string-join(('"', json-utils:escape($name), '":[',
      string-join((for $i in ($x, $x/following-sibling::*[name(.) = $name]) return json-utils:print-value($i)), ","),
    ']'), "")
  else
    string-join(('"', json-utils:escape($name), '":', json-utils:print-value($x)), "")
};
(:~
  Transforms an XML element into a JSON string representation.  See http://json.org.
  <p/>
  Sample usage:
  <pre>
    import module namespace json="http://marklogic.com/json" at "json.xqy"
    json-utils:serialize(<foo><bar>kid</bar></foo>)
  </pre>
  Sample transformations:
  <pre>
  <e/> becomes {"e":null}
  <e>text</e> becomes {"e":"text"}
  <e>quote " escaping</e> becomes {"e":"quote \" escaping"}
  <e>backslash \ escaping</e> becomes {"e":"backslash \\ escaping"}
  <e><a>text1</a><b>text2</b></e> becomes {"e":{"a":"text1","b":"text2"}}
  <e><a>text1</a><a>text2</a></e> becomes {"e":{"a":["text1","text2"]}}
  <e><a array="true">text1</a></e> becomes {"e":{"a":["text1"]}}
  <e><a type="boolean">false</a></e> becomes {"e":{"a":false}}
  <e><a type="number">123.5</a></e> becomes {"e":{"a":123.5}}
  <e quote="true"><div attrib="value"/></e> becomes {"e":"<div attrib=\"value\"/>"}
  </pre>
  <p/>
  Namespace URIs are ignored.  Namespace prefixes are included in the JSON name.
  <p/>
  Attributes are ignored, except for the special attribute @array="true" that
  indicates the JSON serialization should write the node, even if single, as an
  array, and the attribute @type that can be set to "boolean" or "number" to
  dictate the value should be written as that type (unquoted).  There's also
  an @quote attribute that when set to true writes the inner content as text
  rather than as structured JSON, useful for sending some XHTML over the
  wire.
  <p/>
  Text nodes within mixed content are ignored.

  @param $x Element node to convert
  @return String holding JSON serialized representation of $x

  @author Jason Hunter
  @version 1.0
:)
declare function json-utils:serialize($x as element())  as xs:string {
  string-join(('{', json-utils:print-name-value($x), '}'), "")
};

