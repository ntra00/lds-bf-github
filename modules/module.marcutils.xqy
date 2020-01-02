xquery version "1.0-ml";

(: Contains functions to convert between mxe and marcxml, etc. :)
module namespace marcutil = "info:lc/xq-modules/marc-utils";
declare namespace   marc             = "http://www.loc.gov/MARC21/slim";
declare namespace   mxe					= "http://www.loc.gov/mxe";

declare function marcutil:char2element($string as xs:string, $prefix as xs:string) as node()+ {
    let $cps := string-to-codepoints($string)
    for $cp at $count in $cps
    let $cpe := if ($count < 11) then (concat('0', $count -1)) else ($count -1)
    let $char := codepoints-to-string($cp)
    return 
        element {concat('mxe:', $prefix, '_cp', $cpe)}
            {$char}
};

declare function marcutil:marcslim-to-mxe2($marcslim as element(marc:record)) as element(mxe:record) {

try {

let $leader := $marcslim/marc:leader
let $c001 := $marcslim/marc:controlfield[@tag='001']
let $c003 := $marcslim/marc:controlfield[@tag='003']
let $c005 := $marcslim/marc:controlfield[@tag='005']
let $c007 := $marcslim/marc:controlfield[@tag='007']
let $c008 := $marcslim/marc:controlfield[@tag='008']
return

    <mxe:record>
     <mxe:leader>{marcutil:char2element(data($leader), 'leader')}</mxe:leader>
     <mxe:controlfield_001>{data($c001)}</mxe:controlfield_001>
      {
       if ($c003)
       then
       (
        <mxe:controlfield_003>{data($c003)}</mxe:controlfield_003>
       )
       else ()
      }
    
      {
       if ($c005)
       then
       (
        <mxe:controlfield_005>{data($c005)}</mxe:controlfield_005>
       )
       else ()
      }
    
      {
       if ($c007)
       then
       (
        for $c in $c007
        return
        <mxe:controlfield_007>{marcutil:char2element(data($c), 'c007')}</mxe:controlfield_007>
       )
       else ()
      }
    
      {
       if ($c008)
       then
       (
        <mxe:controlfield_008>{marcutil:char2element(data($c008), 'c008')}</mxe:controlfield_008>
       )
       else ()
      }
    
    
       {
       for $datafield in $marcslim/marc:datafield
       return
       element {concat('mxe:datafield_', $datafield/@tag)}
         {attribute {'ind1'} {$datafield/@ind1}, attribute {'ind2'} {$datafield/@ind2},
    
          for $subfield in $datafield/marc:subfield
          return
          element {concat('mxe:', 'd', $datafield/@tag, '_subfield_', $subfield/@code)}{data($subfield)}
         }
       }       
    </mxe:record>
	}
	catch($e){<mxe:record>Conversion Error </mxe:record>}
};
