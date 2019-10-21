xquery version "1.0-ml";
declare  namespace l= "local";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

import module namespace locs = "info:lc/xq-modules/config/lclocations" 
at "/xq/modules/config/lclocations.xqy";
(: 
Code to find diffs between locations in ml and ILS
add codes need tobe added to the /xq/modules/config/lclocations.xqy 
under their appropriate grouping
and removals must be removed.
This should be run weekly?
:)
let $new-codes:=xdmp:http-get("http://lcweb2.loc.gov:8081/diglib/admin/natlib/ils-locations.xml?suppressed=N")[2]
let $codes:= locs:locations()
let $add-codes:= 
		for $newcode in $new-codes//l:code
			return
				if ($newcode=$codes//locs:code) then 
					()
				else 
       				$newcode
let $add:=		
	for $loc in $add-codes
		return $new-codes//l:location[l:code=$loc]
return
	<location-updates xmlns="local" time="{current-dateTime()}">
		<remove-old-locs>{$new-codes}
			{for $oldcode in $codes//locs:code
				return
					if ($oldcode=$new-codes//l:code) then 
						()
					else 
       					$oldcode}</remove-old-locs>
		<add-new-codes>{$add}</add-new-codes>
	</location-updates>
