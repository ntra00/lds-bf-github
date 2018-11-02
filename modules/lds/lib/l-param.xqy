xquery version "1.0-ml";

module namespace lp = "http://www.marklogic.com/ps/lib/l-param";
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/lds/config.xqy";
declare namespace param = "http://www.marklogic.com/ps/params";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare function lp:get-params() as element(param:params) {
    let $params :=
        element param:params {
            for $field in xdmp:get-request-field-names()
            return            
                for $value in xdmp:get-request-field($field)
                return
                    element param:param {
                        element param:name {$field},
                        element param:value {$value}
                    }
            }
    
    return
        $params
    
};

declare function lp:get-params-matches($params as element(param:params), $regex as xs:string) as element(param:params) {
    <param:params>
    {
        $params/param:param[matches(param:name, $regex)]
    }
    </param:params>
};

declare function lp:get-param-integer($params as element(param:params), $name as xs:string, $default as xs:integer) as xs:integer? {
    let $strval := lp:get-param-single($params, $name)
    return
        if( $strval castable as xs:integer) then
            xs:integer($strval)
        else
            $default
};


declare function lp:get-param-single($params as element(param:params), $name as xs:string, $default as xs:string?) as xs:string? {
    let $val := lp:get-param-single($params,$name)
    return
    if($val) then $val else $default
};

declare function lp:get-param-single($params as element(param:params), $name as xs:string) as xs:string? {
    lp:get-param-multiple($params, $name)[1]
};

declare function lp:get-param-multiple($params as element(param:params), $name as xs:string) as xs:string* {
    ($params/param:param[param:name eq $name])/param:value/text()
};


declare function lp:param-string($params as element(param:params)) as xs:string? {
    let $param-parts :=
        for $param in $params/param:param
        return
            concat($param/param:name/text(), "=", fn:encode-for-uri( $param/param:value/text() ))
    return    
        string-join($param-parts, "&amp;")        
};

declare function lp:param-insert($params as element(param:params), $name as xs:string, $value) as element(param:params) {
    let $alreadyContains := 
        if($params/param[(param:name eq $name) and (param:value eq $value)]) then 
            true() 
        else 
            false()        
    return
        if($alreadyContains) then
            $params
        else            
            let $ret-params :=
                element param:params {
                    for $param in $params/param:param
                    return
                        $param,
                        element param:param {
                            element param:name {$name},
                            element param:value {xs:string($value)}
                            
                        }
                }            
            
            return
                $ret-params
};

declare function lp:param-apply-facet-page-control($params as element(param:params)) as element(param:params) {
    let $current-page := lp:get-param-single($params,"/page")
    let $next := ($cfg:FACET-PAGE-CONTROL//*:page-control[*:from eq $current-page])[1]/*:to/text()
    let $next := if(not($next) or $next eq "") then "results" else $next
    return
        lp:param-replace-or-insert($params,"/page",$next)
};

declare function lp:param-replace-or-insert($params as element(param:params), $name as xs:string, $value) as element(param:params) {
    let $replaceHappened := false()
    let $ret-params :=
        element param:params {
            for $param in $params/param:param
            return            
                if($param/param:name eq $name) then (
                    xdmp:set($replaceHappened, true()),
                    element param:param {
                        element param:name {$name},
                        element param:value { xs:string($value) }
                    }
                )
                else
                    $param,                    
                if($replaceHappened) then
                    ()
                else
                    element param:param {
                        element param:name {$name},
                        element param:value { xs:string($value) }
                    }
        }    
    
    return
        $ret-params
};

declare function lp:param-remove-all($params as element(param:params), $name as xs:string) as element(param:params) {
    let $ret-params :=
        element param:params {
            for $param in $params/param:param
            return
                if($param/param:name eq $name ) then
                    ()
                else
                    $param
        }    
    
    return
        $ret-params
};

declare function lp:param-remove($params as element(param:params), $name as xs:string, $value as xs:string) as element(param:params) {
    let $ret-params :=
        element param:params {
            for $param in $params/param:param
            return
                if(($param/param:name eq $name) and ($param/param:value eq $value) ) then
                    ()
                else
                    $param
        }    
    
    return
        $ret-params    
};

declare function lp:param-has-value-for($params as element(param:params), $name as xs:string) as xs:boolean {
    let $val := ($params/param:param[param:name eq $name])/param:value/text()
    return
        if($val) then
            true()
        else
            false()
};

declare function lp:param-value-contains($params as element(param:params), $name as xs:string, $value as xs:string) as xs:boolean {
    let $val := ($params/param:param[param:name eq $name])/param:value/text()
    return
        if($val = $value) then
            true()
        else
            false()    
};

declare function lp:param-remove-all-multi($params as element(param:params), $names ) as element(param:params) {

    let $ret-params :=
        element param:params {
            for $param in $params/param:param
                return
                    if($param/param:name eq $names ) then
                        ()
                    else
                    $param
        }    
    (:let $_ := xdmp:log(concat("param-remove-all-multi: ",xdmp:quote($ret-params)),'fine')    :)
    return
        $ret-params
};

declare function lp:remove-digital-params($metsprofile as xs:string? )  as element(param:params) {
(:
    if metsprofile is null, remove all, else remove just the profile's stuff
:)
    let $drops:= 
        if (exists($metsprofile)) then
             distinct-values( $cfg:DIGITAL-OBJECT-CONTROL/cfg:object-control[cfg:profile=$metsprofile]//cfg:attribute/string() )
        else   
              distinct-values($cfg:DIGITAL-OBJECT-CONTROL/cfg:object-control//cfg:attribute/string()    )               

    return  lp:param-remove-all-multi($lp:CUR-PARAMS, $drops ) 
};



declare function lp:set-digital-params($params , $nextbehavior as xs:string, $metsprofile as xs:string , $desired-params as node()) as element(param:params)  {
(:
assumes all digital params for this profile are cleaned out previously.
as element(param:params)
returns clean params based on page controls , current behavior, next behavior, profile
:)

  let $thisobject:=$cfg:DIGITAL-OBJECT-CONTROL/cfg:object-control[cfg:profile=$metsprofile]
  (:remove all valid parms for this page control:)
              
        (: if you're on a subpage that needs params, set them :)
  let $new-params :=
      if ($nextbehavior ne "('default','contents','contactsheet')" ) then
      (:cycle thru all  $desired-param, set them if valid in object control:)
         element param:params {
            for $p in $params/param:param
                return
                     $p,  
                        for $newparm in $desired-params//param:param
                            let $pname:=$newparm/param:name/string()  (: ie., itemID :)
                            return                             
                                  if ($thisobject/cfg:page[cfg:behavior=$nextbehavior]/cfg:attribute/string()=$pname) then                                                                       
                                      $newparm   
                                  else ()                        
            }  
                           
      else  $params                              
 let $ret-params:= lp:param-replace-or-insert($new-params,"behavior",$nextbehavior)      
 
 return  $ret-params
};

declare variable $CUR-PARAMS := lp:get-params();