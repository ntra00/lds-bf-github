xquery version "1.0-ml";

module namespace ld = "http://www.marklogic.com/ps/lib/l-date";
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/lds/config.xqy";
import module namespace functx = "http://www.functx.com" at "/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy"; 

declare function ld:convert-picker-to-date($pickerText as xs:string) as xs:date {
    functx:mmddyyyy-to-date($pickerText)
};

declare function ld:convert-date-to-picker($date as xs:date) as xs:string {
    let $parts := fn:tokenize(xs:string($date), "-")
    return
    fn:concat( $parts[2], "/", $parts[3] ,"/", $parts[1])
};

declare function ld:check-date($dateString as xs:string?) as xs:date? {
    let $date :=
        try {
            if($dateString) then 
                xs:date($dateString)
            else
                ()
        } catch ($e) {
            ()
        }
    return
    $date
};

declare function ld:check-dateTime($dateTimeString as xs:string?) as xs:dateTime? {
    let $dateTime :=
        try {
            if($dateTimeString) then 
                xs:dateTime($dateTimeString)
            else
                ()
        } catch ($e) {
            ()
        }
    return
    $dateTime
};

(: input in form August 5, 2010 :)
declare function ld:convert-daily-to-date($daily as xs:string) as xs:string? {
    let $parts := fn:tokenize($daily, " ")
    let $year := $parts[3]
    let $date := fn:substring-before($parts[2],",")
    let $month :=
      let $m := fn:lower-case($parts[1])
      return
      if($m eq "january") then "1" else
      if($m eq "february") then "2" else
      if($m eq "march") then "3" else
      if($m eq "april") then "4" else
      if($m eq "may") then "5" else
      if($m eq "june") then "6" else
      if($m eq "july") then "7" else
      if($m eq "august") then "8" else
      if($m eq "september") then "9" else
      if($m eq "october") then "10" else
      if($m eq "november") then "11" else
      if($m eq "december") then "12" else ""
    
    let $month := if(fn:string-length($month) eq 1) then fn:concat("0",$month) else $month
    let $date := if(fn:string-length($date) eq 1) then fn:concat("0",$date) else $date
    let $date-string := fn:string-join(($year,$month,$date),"-")
    return
    
    try {
        let $date := xs:date($date-string)
        return
        $date-string
    } catch ($e) { 
        xdmp:log(fn:concat("Could not convert date: ",$date-string))
    }
};

(: input format 2010/8/8 14:13:00 GMT :)
declare function ld:convert-msdoc-to-date($text) as element(time)? {
    try{
        let $parts := fn:tokenize($text," ")
        
        let $date-parts := fn:tokenize($parts[1],"/")
        let $year := $date-parts[1]
        let $month := $date-parts[2]
        let $day := $date-parts[3]
        let $month := if( fn:string-length($month) eq 1 ) then fn:concat("0",$month) else $month
        let $day := if( fn:string-length($day) eq 1 ) then fn:concat("0",$day) else $day
        let $date := fn:string-join(($year,$month,$day),"-")
        
        let $time := $parts[2]
        return
        element time {
            element date {$date},
            element dateTime { fn:concat($date,"T",$time) }
        }
    } catch ($e) {
        ()
    }
};
