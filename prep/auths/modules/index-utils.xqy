xquery version "1.0-ml";

(: 
module for conversion of mets/mods data to idx index terms
see main function call: function ldsindex:mods-to-idx
for version history
:)

module namespace ldsindex = "info:lc/xq-modules/index-utils";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare namespace xdmp              = "http://marklogic.com/xdmp";
declare namespace mets = "http://www.loc.gov/METS/";
declare namespace marc = "http://www.loc.gov/MARC21/slim";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare namespace idx = "info:lc/xq-modules/lcindex";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";                        
declare namespace ctry = "info:lc/xmlns/codelist-v1";
declare namespace mat = "info:lc/xq-modules/config/materials";
declare namespace mxe = "http://www.loc.gov/mxe";

declare namespace hld = "http://www.indexdata.com/turbomarc";
declare namespace loc = "info:lc/xq-modules/config/lclocations";
       
(:import module namespace utils = "info:lc/xq-modules/mets-utils" at "mets-utils.xqy";
import module namespace hold = "info:lc/xq-modules/holdings-utils" at "holdings-utils.xqy";:)
import module namespace functx = "http://www.functx.com"  at "functx.xqy";
import module namespace matconf = "info:lc/xq-modules/config/materials" at "config/materialtype.xqy";
import module namespace langs = "info:lc/xq-modules/config/languages" at "config/languages.xqy";
import module namespace relators = "info:lc/xq-modules/config/relators" at "config/relators.xqy";
import module namespace lcc = "info:lc/xq-modules/config/lcclass" at "config/lcc2.xqy";
import module namespace locs = "info:lc/xq-modules/config/lclocations" at "config/lclocations.xqy";
declare namespace xdmphttp = "xdmp:http";

(: -------------------------- index terms starts here: -------------------------- :)
(: This function chops the given punctuation from the end of the given string. useful for lopping off ending periods (but be careful!)
adapted from marcslim2modsutils.xsl
$punc to be chopped  can be passed in, or defaults to  ".:,;/" (not including the quotes)
:)
declare function ldsindex:chopPunctuation( $str as xs:string*,
    $punc as xs:string){
let $punc:= if (fn:string-length($punc)=0 ) then  ".:,;/" else $punc
let $str:=fn:normalize-space($str)

let $len:=fn:string-length($str)

return	if ($len=0) then
			()
	else if (fn:contains($punc, fn:substring($str,$len,1) )) then
			ldsindex:chopPunctuation(fn:substring($str,1,$len - 1),$punc)
	else if (fn:not($str)) then
			()
	else
		$str

};

declare function ldsindex:get-thumb($mets as element(), $uri as xs:string ) {
(: copied from mets-utils
this is only for digital objects that already have a mets file with filesec..
called by mets-files, requires having $mets in hand; could be written to stand alone

 :)

		let $thumbkey := (:skips monoSecment div:) 
		  	if ($mets/mets:structMap//mets:div[mets:fptr][@LABEL = "thumb"]) then
			 	(: from database:) 
			 	$mets/mets:structMap//mets:div[mets:fptr][@LABEL = "thumb"]/mets:fptr[2]/@FILEID/string()
		    else if ($mets//mets:div[matches(@TYPE, "illustration")]/mets:div[matches(@TYPE, "image")]) then 
					(: from file system illustration/image dir :) 
					$mets//mets:div[matches(@TYPE, "illustration")]/mets:div[matches(@TYPE, "image")]/mets:fptr[2]/@FILEID/string()
		         else 
				 	(: defaults to first image ; test if this really grabs #1 (skips pm:image if found) :)
				 	$mets/mets:structMap//mets:div[matches(@TYPE, ("page", "version"))][not(matches(@LABEL, "target"))][1]//mets:fptr[2]/@FILEID/string()

	  let $url := $mets/mets:fileSec/mets:fileGrp/mets:file[@ID = $thumbkey]/mets:FLocat/@xlink:href/string()
	  let $iipimage := concat(substring-before($url, $uri), $uri, "/iipimage")  
	  let $thumbpath := concat(xdmp:http-get($iipimage)[2], substring-after($url, $uri))
	  (: <l:thumb caption="{$mets//idx:titleSort/string()}">
	             <l:url>{ $url }</l:url>
    	          <l:dzi>{ $thumbpath }</l:dzi>
		    </l:thumb> :)
	  return <idx:thumbnail caption="{$mets//idx:titleSort/string()}">{ $thumbpath }</idx:thumbnail>
	  		 
  		
};

declare function ldsindex:get-lcc-facet($mods as element(mods:mods), $holdings as node()) {
(:
	lcclass is best found in holdings d852/sh, si,
	if not found, look in MXE 852/h,i
	if not found, look in mods (mods:classification[@authority="lcc"]) for digital stuff.

	2011/11/03 * Modified possibleLCC to add search string and display for browse link in idx:lcclass, so we don't need to look in holdings 
	for the browse link in the right nav 2011/11/03
	
	Returns the class in lcclass for browsing, returns a 3 layered structure based on the 
	alpha prefix or 'unclassed" or unclassed law.
	all should be invalid except hv below:
lc: 11649667
lca:5811627
law:10870361 (actually law is in bib991, so there's no class now that we're dropping 991s)
law in 050: 9060244
lc-: gottlieb loc.natlib.gottlieb.03361
CT 9017446
cta 12535489
rea, rda:12120540
daa: 11541481
"da ":1020320
hv, valid code:1756373

bf:
<mods:mods><mods:classification authority="lcc">{fn:string($e//bf:classificationPortion)}</mods:classification></mods:mods>
:)



let $validLCC:=("DAW","DJK","KBM","KBP","KBR","KBU","KDC","KDE","KDG","KDK","KDZ","KEA","KEB","KEM","KEN","KEO","KEP","KEQ","KES","KEY","KEZ","KFA","KFC","KFD","KFF","KFG","KFH","KFI","KFK","KFL","KFM","KFN","KFO","KFP","KFR","KFS","KFT","KFU","KFV","KFW","KFX","KFZ","KGA","KGB","KGC","KGD","KGE","KGF","KGG","KGH","KGJ","KGK","KGL","KGM","KGN","KGP","KGQ","KGR","KGS","KGT","KGU","KGV","KGW","KGX","KGY","KGZ","KHA","KHC","KHD","KHF","KHH","KHK","KHL","KHM","KHN","KHP","KHQ","KHS","KHU","KHW","KJA","KJC","KJE","KJG","KJH","KJJ","KJK","KJM","KJN","KJP","KJR","KJS","KJT","KJV","KJW","KKA","KKB","KKC","KKE","KKF","KKG","KKH","KKI","KKJ","KKK","KKL","KKM","KKN","KKP","KKQ","KKR","KKS","KKT","KKV","KKW","KKX","KKY","KKZ","KLA","KLB","KLD","KLE","KLF","KLH","KLM","KLN","KLP","KLQ","KLR","KLS","KLT","KLV","KLW","KMC","KME","KMF","KMG","KMH","KMJ","KMK","KML","KMM","KMN","KMP","KMQ","KMS","KMT","KMU","KMV","KMX","KMY","KNC","KNE","KNF","KNG","KNH","KNK","KNL","KNM","KNN","KNP","KNQ","KNR","KNS","KNT","KNU","KNV","KNW","KNX","KNY","KPA","KPC","KPE","KPF","KPG","KPH","KPJ","KPK","KPL","KPM","KPP","KPS","KPT","KPV","KPW","KQC","KQE","KQG","KQH","KQJ","KQK","KQM","KQP","KQT","KQV","KQW","KQX","KRB","KRC","KRE","KRG","KRK","KRL","KRM","KRN","KRP","KRR","KRS","KRU","KRV","KRW","KRX","KRY","KSA","KSC","KSE","KSG","KSH","KSK","KSL","KSN","KSP","KSR","KSS","KST","KSU","KSV","KSW","KSX","KSY","KSZ","KTA","KTC","KTD","KTE","KTF","KTG","KTH","KTJ","KTK","KTL","KTN","KTQ","KTR","KTT","KTU","KTV","KTW","KTX","KTY","KTZ","KUA","KUB","KUC","KUD","KUE","KUF","KUG","KUH","KUN","KUQ","KVB","KVC","KVE","KVH","KVL","KVM","KVN","KVP","KVQ","KVR","KVS","KVU","KVW","KWA","KWC","KWE","KWG","KWH","KWL","KWP","KWQ","KWR","KWT","KWW","KWX","KZA","KZD","AC","AE","AG","AI","AM","AN","AP","AS","AY","AZ","BC","BD","BF","BH","BJ","BL","BM","BP","BQ","BR","BS","BT","BV","BX","CB","CC", "CD","CE","CJ","CN","CR","CS","CT","DA","DB","DC","DD","DE","DF","DG","DH","DJ","DK","DL","DP","DQ","DR","DS","DT","DU","DX","GA","GB","GC","GE","GF","GN","GR","GT","GV","HA","HB","HC","HD","HE","HF","HG","HJ","HM","HN","HQ","HS","HT","HV","HX","JA","JC","JF","JJ","JK","JL","JN","JQ","JS","JV","JX","JZ","KB","KD","KE","KF","KG","KH","KJ","KK","KL","KM","KN","KP","KQ","KR","KS","KT","KU","KV","KW","KZ","LA","LB","LC","LD","LE",  "LF","LG","LH","LJ","LT","ML","MT","NA","NB","NC","ND","NE","NK","NX","PA","PB","PC","PD","PE","PF","PG","PH","PJ","PK","PL","PM","PN","PQ","PR","PS","PT","PZ","QA","QB","QC","QD","QE","QH","QK","QL","QM","QP","QR","RA","RB","RC","RD","RE","RF","RG",   "RJ","RK","RL","RM","RS","RT","RV","RX","RZ","SB","SD","SF","SH","SK","TA","TC","TD","TE","TF","TG","TH","TJ","TK","TL","TN","TP","TR","TS","TT","TX","UA","UB","UC","UD","UE","UF","UG","UH","VA","VB","VC","VD","VE","VF","VG","VK","VM","ZA","A","B","C","D","E","F","G","H","J","K","L","M","N","P","Q","R","S","T","U","V","Z")

let  $lcc:= (:sequence of location codes in hld:sh :)
		if (exists($holdings//hld:d852/hld:sh)) then
		   (:($holdings//hld:d852/hld:sh):)
		     for $class in $holdings//hld:d852
		       return <cl search="{$class/hld:sh/string()}">{string-join($class/*[local-name()!='sb'][local-name()!='s3'][local-name()!='st'][local-name()!='sz'][local-name()!='sx'],' ')}</cl>
		else
			for  $class in $mods/mods:classification[@authority="lcc"]
		
				return if (contains($class/string(), '.')) then
				     <cl search="{substring-before($class/string(),'.')}">{$class/string()}</cl>
					else 
				 		<cl search="{$class/string() }">{$class/string()}</cl>

let $possibleLCC:=
	<set>{
		 for $cl in $lcc
		 	return if (matches($cl,'^U.')) then
				()
			else
				let $strip := replace($cl/string(), "(\s+|\.).+$", "")			
				let $subclassCode := replace($strip, "\d", "")			
				return (
					(: lc classes don't have a space after the alpha prefix, like DA1 vs "DA 1" :)
    				if (substring(substring-after($cl/string(), $subclassCode),1,1)!=' ' and $subclassCode = $validLCC  ) then   				
							(<idx:lcclass search="{$cl/@search}">{$cl/string()}</idx:lcclass>,							
                               $cl,
							 <idx:lcc>{lcc:getLCClass($subclassCode)}</idx:lcc>)
					else if ($subclassCode="LAW") then
						<idx:invalid>{$subclassCode}</idx:invalid>(: allows you to see that there's at least one unclassed law later:)
					else 
						()
				   ) 
		}
	</set>
	
return (
         $possibleLCC//idx:lcclass,
			if ($possibleLCC//idx:lcc) then
			   $possibleLCC/idx:lcc[1]
			else 
			 if ($possibleLCC//idx:invalid/string()="LAW") then
			    <idx:lcc>
					<idx:lcc1>K - Law</idx:lcc1>
				 	<idx:lcc2>K~ - Unclassed</idx:lcc2>
				</idx:lcc>
			else
			    <idx:lcc>
					<idx:lcc1>~ - Unclassed</idx:lcc1>
				</idx:lcc>				
		)
	
};
declare function ldsindex:oldgetLcc($mods as element(mods:mods), $holdings as element()) {
(:
	lcclass is best found in holdings d852/sh, si,
	if not found, look in MXE 852/h,i
	if not found, look in mods (mods:classification[@authority="lcc"]) for digital stuff
:)
let  $lcc:= (:sequence of location codes????:)
		if (exists($holdings//hld:d852/hld:sh)) then
		   ($holdings//hld:d852/hld:sh)[1]		     			
		else
 			($mods//mods:classification[@authority="lcc"])[1]
return
	 for $cl in $lcc[1]
			let $strip := replace($cl/string(), "(\s+|\.).+$", "")
			let $subclassCode := replace($strip, "\d", "")
			let $validLCC:=("DAW","DJK","KBM","KBP","KBR","KBU","KDC","KDE","KDG","KDK","KDZ","KEA","KEB","KEM","KEN","KEO","KEP","KEQ","KES","KEY","KEZ","KFA","KFC","KFD","KFF","KFG","KFH","KFI","KFK","KFL","KFM","KFN","KFO","KFP","KFR","KFS","KFT","KFU","KFV","KFW","KFX","KFZ","KGA","KGB","KGC","KGD","KGE","KGF","KGG","KGH","KGJ","KGK","KGL","KGM","KGN","KGP","KGQ","KGR","KGS","KGT","KGU","KGV","KGW","KGX","KGY","KGZ","KHA","KHC","KHD","KHF","KHH","KHK","KHL","KHM","KHN","KHP","KHQ","KHS","KHU","KHW","KJA","KJC","KJE","KJG","KJH","KJJ","KJK","KJM","KJN","KJP","KJR","KJS","KJT","KJV","KJW","KKA","KKB","KKC","KKE","KKF","KKG","KKH","KKI","KKJ","KKK","KKL","KKM","KKN","KKP","KKQ","KKR","KKS","KKT","KKV","KKW","KKX","KKY","KKZ","KLA","KLB","KLD","KLE","KLF","KLH","KLM","KLN","KLP","KLQ","KLR","KLS","KLT","KLV","KLW","KMC","KME","KMF","KMG","KMH","KMJ","KMK","KML","KMM","KMN","KMP","KMQ","KMS","KMT","KMU","KMV","KMX","KMY","KNC","KNE","KNF","KNG","KNH","KNK","KNL","KNM","KNN","KNP","KNQ","KNR","KNS","KNT","KNU","KNV","KNW","KNX","KNY","KPA","KPC","KPE","KPF","KPG","KPH","KPJ","KPK","KPL","KPM","KPP","KPS","KPT","KPV","KPW","KQC","KQE","KQG","KQH","KQJ","KQK","KQM","KQP","KQT","KQV","KQW","KQX","KRB","KRC","KRE","KRG","KRK","KRL","KRM","KRN","KRP","KRR","KRS","KRU","KRV","KRW","KRX","KRY","KSA","KSC","KSE","KSG","KSH","KSK","KSL","KSN","KSP","KSR","KSS","KST","KSU","KSV","KSW","KSX","KSY","KSZ","KTA","KTC","KTD","KTE","KTF","KTG","KTH","KTJ","KTK","KTL","KTN","KTQ","KTR","KTT","KTU","KTV","KTW","KTX","KTY","KTZ","KUA","KUB","KUC","KUD","KUE","KUF","KUG","KUH","KUN","KUQ","KVB","KVC","KVE","KVH","KVL","KVM","KVN","KVP","KVQ","KVR","KVS","KVU","KVW","KWA","KWC","KWE","KWG","KWH","KWL","KWP","KWQ","KWR","KWT","KWW","KWX","KZA","KZD","AC","AE","AG","AI","AM","AN","AP","AS","AY","AZ","BC","BD","BF","BH","BJ","BL","BM","BP","BQ","BR","BS","BT","BV","BX","CB","CC", "CD","CE","CJ","CN","CR","CS","CT","DA","DB","DC","DD","DE","DF","DG","DH","DJ","DK","DL","DP","DQ","DR","DS","DT","DU","DX","GA","GB","GC","GE",    "GF","GN","GR","GT","GV","HA","HB","HC","HD","HE","HF","HG","HJ","HM","HN","HQ","HS","HT","HV","HX","JA","JC","JF","JJ","JK","JL","JN","JQ","JS","JV","JX","JZ","KB","KD","KE","KF","KG","KH","KJ","KK","KL","KM","KN","KP","KQ","KR","KS","KT","KU","KV","KW","KZ","LA","LB","LC","LD","LE",  "LF","LG","LH","LJ","LT","ML","MT","NA","NB","NC","ND","NE","NK","NX","PA","PB","PC","PD","PE","PF","PG","PH","PJ","PK","PL","PM","PN","PQ","PR","PS","PT","PZ","QA","QB","QC","QD","QE","QH","QK","QL","QM","QP","QR","RA","RB","RC","RD","RE","RF","RG",   "RJ","RK","RL","RM","RS","RT","RV","RX","RZ","SB","SD","SF","SH","SK","TA","TC","TD","TE","TF","TG","TH","TJ","TK","TL","TN","TP","TR","TS","TT","TX","UA","UB","UC","UD","UE","UF","UG","UH","VA","VB","VC","VD","VE","VF","VG","VK","VM","ZA","A","B","C","D","E","F","G","H","J","K","L","M","N","P","Q","R","S","T","U","V","Z")
			return (
				<idx:lcclass>{$cl/string()}</idx:lcclass>,
				<idx:lcc>
				    {if ($subclassCode = $validLCC) then        					
				        lcc:getLCClass($subclassCode)                                 
				    else if ($subclassCode="LAW") then								
								(<idx:lcc1>K - Law</idx:lcc1>,
								 <idx:lcc2>K~ - Unclassed</idx:lcc2>      )
					        
				    else <idx:lcc1>~ - Unclassed</idx:lcc1>
					}
				</idx:lcc>
				)
};

declare function ldsindex:findLastSpace($titleChop as xs:string ) as xs:string{
(:called by gethitlist():)    
     if ( substring($titleChop,string-length($titleChop))!=" ") then 
        ldsindex:findLastSpace(substring($titleChop, 1, string-length($titleChop)-1))
        else $titleChop
    };
(:---------------------------------------------------------------------------:)
declare function ldsindex:getModsDigitized($mods as element())  as element(wrap) {
(: mods is simpler than mxe digitized ; if there's a url, then it's online 

   always return 'at the library'?
:)

 <wrap>
	{if ($mods/mods:location/mods:url) then <idx:digitized>Online</idx:digitized>			
        else () }
		<idx:digitized>At the Library</idx:digitized>
    </wrap>
};
(:---------------------------------------------------------------------------:)
declare function ldsindex:getDigitized($mxe as element(), $holdings as element() )  as element()+ {
(: 
3/21/21: added "cip" category if there are no holdings yet, called "In process/Undetermined
holdings added 5/18/11: so do distinct values of holdings 856s, distinct values of bib 856, and distinct val of result

rules as of 2/3/11:

if 856 with http://hdl.loc.gov in $u, but $3 Finding aid then bucket B (bucket c?)

If 856 with http://hdl.loc.gov in $u, then put in bucket A.
        http://lccn.loc.gov/2002565134
 
If 856 with $d OR $f, then put in bucket A (there, hopefully, would be few of these that don't have hdl.loc.gov, but some could remain)
 
If 856 with $3 PDF, then put in bucket A.
 http://marklogic3.loctest.gov/xq/render.xqy?id=loc.natlib.lcdb.13173484&mime=application/marcxml+xml
  http://lccn.loc.gov/2003426863
If 856 with $3 Page view, then put in bucket A.
 
 http://lccn.loc.gov/2005552386
 
If 856 1st ind. = 4 AND 2nd ind. = 0, then put in bucket A.
 
If 856 1st ind. = 4 AND 2nd ind. = 1 WITHOUT $3, then put in bucket A.
        http://lccn.loc.gov/2006355448
______________________________________________________
 
If 856 with these character strings in $3, then put in bucket B:
http://marklogic3.loc.gov/lds/detail.xqy?q=Publisher description&qname=mxe:d856_subfield_3
http://marklogic3.loc.gov/xq/render.xqy?id=loc.natlib.lcdb.12582214&mime=index
Book review ...
                Contributor biographical data
                Publisher description
                Sample text
                Summary from book
                Table of contents
                Table of contents only
 
FYI, PSD says that these strings have been used consistently when supplied by LC; we may import copy that varies from these models, but if we aren't expecting perfection, this should work fairly well.
 
If 856 with other than purple (above the line if color doesn't mean anything to you), then put in bucket B.
 
If no 856, then do not put in bucket A or B.
 
Fully Online= Bucket A
Partially Online= Bucket B
At the Library = All
$result will contain a sequence of "online" or "partly online", or will be null.  add "At the Library" on return
:)

let $result:=
 (distinct-values(
 	for $link in $holdings//hld:d856
         return
            if (contains(string-join($link//hld:su," "),"hdl.loc.gov") and not( functx:contains-case-insensitive($link/hld:s3,"finding aid") ) ) then
            	  "full"
            else  if (matches(lower-case($link/hld:s3) ,"(pdf|page view) ") )  then
                        "full"            
            else  if ($link/@i1="4" and $link/@i2="0" ) then
                        "full"
            else  if ($link/@i1="4" and $link/@i2="1" and not(exists($link/hld:s3) ) ) then
                                "full"
            
                     else  if (functx:contains-case-insensitive($link/hld:s3,"finding aid") ) then
                                ()    
            else      "part"
	),   
	distinct-values(
        for $link in $mxe//mxe:datafield_856
         return
            if (contains(string-join($link//mxe:d856_subfield_u," "),"hdl.loc.gov") and not( functx:contains-case-insensitive($link/mxe:d856_subfield_3,"finding aid") ) ) then
              "full"
            else  if (matches(lower-case($link/mxe:d856_subfield_3) ,"(pdf|page view) ") )  then
                        "full"            
            else  if ($link/@ind1="4" and $link/@ind2="0" ) then
                        "full"
            else  if ($link/@ind1="4" and $link/@ind2="1" and not(exists($link/mxe:d856_subfield_3) ) ) then
                                "full"           
            else  if (functx:contains-case-insensitive($link/mxe:d856_subfield_3,"finding aid") ) then
                                ()    
            else      "part"
            )
	)
 return 

   (    for $item in distinct-values( $result ) 
   		return <idx:digitized>{
   					if ($item="full") then "Online" 
					else if ($item="part") then "Partly Online" 	
					else if ($item="cip") then "In Process/Undetermined" 					
					else ()			
				}</idx:digitized>
        ,
			if ( $holdings//*) then 
				<idx:digitized>At the Library</idx:digitized>
			else
				 <idx:digitized>No Holdings</idx:digitized>
    )
 
};
(:-----------------------------------------------------------------------:)
declare function ldsindex:parseDates( $date as element(),$type as xs:string )  as element() {
(:type of date is either about or pub :)
let $century:= if (matches($date," cent") ) then  "true" else "false"

let $bcIndicator:= if (matches($date,"^c[0-9]") or matches(lower-case($date),"b\.c")  ) then "true" else "false"
let $adIndicator:= if (matches($date,"^d[0-9]") or matches(lower-case($date),"a\.d")  ) then "true" else "false"

let $and := if (contains($date," and ") and not(contains($date,"-" )) )  then "true" else "false"

let $enddateonly:=
    if  ( starts-with(normalize-space(lower-case($date)),"to ") ) then 
        replace(lower-case($date),"\w* (\d*)[^0-9]*$","$1") 
    else ()

  
let $result:=
       if (matches($date,"(\d+)" )) then 
             if ($and="true") then  
                replace($date,"[^0-9]*(\d+)\w*(\d*)[^0-9]*","$1:$3") 
                else
                    replace($date,"^[^0-9]*(\d+)\w*[ ]*(-?)[ ]*(\d*)[^0-9]*","$1:$3") 


        else () (:"no date":)

let $begin:=
   if ($century="true" ) then
        if ( tokenize($result,":")[1]!="" ) then
          if ($bcIndicator="true") then
            (number(tokenize($result,":")[1]) * 100)  (:6th cent = 600-501bc:)
            else
            (number(tokenize($result,":")[1]) * 100) - 100
        else (:century but not a number   :)
            () 
   else
        if (not(empty($enddateonly))) then
            ()
        else
        (: substring in case it's more than  than 4 chars, normalize in case it was less :)
            normalize-space(substring(tokenize($result,":")[1],1,4)) (: in case it's less than 4 chars :)

(:even if there's an ad indicator, 1st value should be bc if bcindicator=true:)

let $begindate:= 
        if  ($bcIndicator="true"  and not(empty($begin) )) then concat("-",$begin) 
            else                        
              if (not(empty($begin)) ) then                 
                $begin
             else
                "Undetermined" (:"-9998":)

let $end:= 
    if ($century="true") then
        if ( not(tokenize($result,":")[2])  ) then
            (:end date range is base on begin century since end is null  and century is true:)
            if ( number(tokenize($result,":")[1]) ) then
              if ($bcIndicator="true") then           
                    (number(tokenize($result,":")[1]) * 100)-99
                else
                    (number(tokenize($result,":")[1]) * 100) -1 
            else (: result 1 not a number:)
               (: theres something in the enddate  :)
                if ( not(empty($enddateonly)) ) then
                 (: and it is a century :)
                         if ($bcIndicator="true") then          
                            (number(normalize-space($enddateonly))* 100) - 99
                        else
                            (number(normalize-space($enddateonly)) *100) - 1

                else () (:result 1 is not a number and there's nothing int endateonly :)

        else   (:there is something in the end date (result[2]) :)        
            if ( number(tokenize($result,":")[2])) then
                if ($bcIndicator="true") then             (:6th cent = 600-501bc:)
                    (number(tokenize($result,":")[2]) * 100) - 99
                else
                      (number(tokenize($result,":")[2]) * 100) -1 
            else        (:century yes, result[2] yes, but not  a  number :)
                    ()
   else (: century is false :)
       if ( not(empty($enddateonly))) then
              normalize-space(substring(normalize-space($enddateonly),1,4))
       else
             normalize-space(substring(tokenize($result,":")[2],1,4))

let $enddate:= if ($bcIndicator="true" and not($adIndicator="true") and not(empty($end)) ) then concat("-",$end) 
                else 
                    if (not(empty($end)) ) then                 
                        $end
                    else
                        "Undetermined" (:"-9998":)
return
 if ($enddate ) then            
            <idx:range>
                {element { concat("idx:begin",$type,"date") } {$begindate} }
                {element { concat("idx:end",$type,"date") } {$enddate} }
            </idx:range>
        else
          element { concat("idx:begin",$type,"date") } {$begindate}
                    
};
(:-----------------------------------------------------------------------:)
declare function ldsindex:getAboutDates($mods as element() )  as element()? {
(: find best date for faceting and sorting :)

let $aboutdates:= 
    for $temporalsubject in $mods//mods:subject[mods:temporal]            
                for $date in $temporalsubject/mods:temporal                    
                        return ldsindex:parseDates($date,"about")                      
   return 
   	if (exists($aboutdates)) then
		<idx:aboutdates>{$aboutdates}</idx:aboutdates>
	else <idx:aboutdates>Undetermined</idx:aboutdates>
   
     
};
(:-----------------------------------------------------------------------:)
declare function ldsindex:getPubDates($origin as element()) as element() {
(: find best date for faceting and sorting :)
let $begin:= if ( $origin/mods:dateIssued[@encoding="marc"][@point="start" or not(@point)]) then
                 $origin/mods:dateIssued[@encoding="marc"][@point="start" or not(@point)][1]/string() else 
                if ($origin/mods:dateCreated[@encoding="marc"][@point="start" or not(@point)]) then
                    $origin/mods:dateCreated[1][@encoding="marc"][@point="start" or not(@point)]/string() else
                if ($origin/mods:dateCaptured[@encoding="iso8601"][@point="start" or not(@point)]) then
                    $origin/mods:dateCaptured[1][@encoding="iso8601"][@point="start" or not(@point)]/string() else
         if ($origin/mods:dateCreated[@keyDate="yes"][@encoding="iso8601"][@point="start" or not(@point)])(: ammem  nonmarc keydates :)  then
            substring($origin/mods:dateCreated[@keyDate="yes"][@encoding="iso8601"][@point="start" or not(@point)],1,4) else
                if ($origin/mods:copyrightDate[@encoding="marc"][@point="start" or not(@point)]) then
                    $origin/mods:copyrightDate[@encoding="marc"][@point="start" or not(@point)]/string() 
                else ""
(: [198 ] 198- [19uu] :) 
let $range:= matches($begin,".*(-|u|\s+).*")

let $computedBegin:= if ($range) then  replace($begin,"(-|u|\s+)","0") else ()

let $begindate:= 
    if (exists($computedBegin)) then
        substring(replace($computedBegin,"\D+",""),1,4) 
    else
        if ( $begin!="") then
            substring(replace($begin,"\D+",""),1,4) 
        else 
            "Undetermined" (:"-9999":) (: cast as xs:gYear:)

let $end:= if ( $origin/mods:dateIssued[@encoding="marc"][@point="end"]) then
                 $origin/mods:dateIssued[1][@encoding="marc"][@point="end"]/string() else 
                if ($origin/mods:dateCreated[@encoding="marc"][@point="end"]) then
                    $origin/mods:dateCreated[1][@encoding="marc"][@point="end"]/string() else
                if ($origin/mods:dateCaptured[@encoding="iso8601"][@point="end"]) then
                    $origin/mods:dateCaptured[1][@encoding="iso8601"][@point="end"]/string() else
 if ($origin/mods:copyrightDate[@encoding="marc"][@point="end" ]) then
                    $origin/mods:copyrightDate[@encoding="marc"][@point="end" ]/string() else
                    if ($range) then replace($begin,"(-|u|\s+)","9")
                else ()

let $enddate:= 
    if (exists($end)) then
        substring(replace($end,"\D+",""),1,4)
    else
        "Undetermined" (:"-9998":)(: cast as xs:gYear :)
                
let $result:=
   if ($range) then
     <idx:range>
        <idx:beginpubdate>{$begindate}</idx:beginpubdate>
		<idx:begyear>{ldsindex:gyear($begindate)}</idx:begyear>        
        <idx:endpubdate>{$enddate}</idx:endpubdate>
		<idx:endyear>{ldsindex:gyear($enddate)}</idx:endyear>        
     </idx:range>
     else 
        (<idx:beginpubdate>{$begindate}</idx:beginpubdate>,
		<idx:begyear>{ldsindex:gyear($begindate)}</idx:begyear>        )
        
return 
   <idx:pubdates>
        {$result}
        {if (exists($computedBegin)) then 
			let $sort:=
				if ($computedBegin="Undetermined")  then 
		   			$computedBegin 
				else replace($computedBegin,"\D+","")
            return (<idx:pubdateSort>{$sort}</idx:pubdateSort>,
					<idx:pubyrSort>{ldsindex:gyear($sort)}</idx:pubyrSort>        )
        else if (exists($begindate)) then        
        	(<idx:pubdateSort>{$begindate}</idx:pubdateSort> ,
			      <idx:pubyrSort>{ldsindex:gyear($begindate)}</idx:pubyrSort>        )
        	else ()}        
    </idx:pubdates>
   
};

(:********************************** :)

(:-----------------------------------------------------------------------:)
declare function ldsindex:getCoverage($datefield as element()) as element() {
(: experimental holdings coverage:)

let $range:= matches($datefield,".*(-|u|\s+).*")

let $computedBegin:= if ($range) then  replace($datefield,"(-|u|\s+)","0") else ()

return $computedBegin

};
declare function ldsindex:gyear($date as xs:string ) as xs:gYear  {
(: assumes only positive dates for now:)

  if (number($date)) then
	if ( number($date) = 0 ) then
		"0001" cast as xs:gYear
	else if ($date="-9999" ) then
		$date cast as xs:gYear
  	else if (string-length($date) > 4) then (:19920101:)
			if (substring($date,1,4) castable as xs:gYear) then
				substring($date,1,4) cast as xs:gYear
  			else "-9999" cast as xs:gYear
 	else if (string-length($date) < 4) then
  			if (functx:pad-integer-to-length (number($date),4)) then
				functx:pad-integer-to-length (number($date),4) cast as xs:gYear
  			else "-9999" cast as xs:gYear
  	else if ($date castable as xs:gYear) then 
			$date cast as xs:gYear
  	else "-9999" cast as xs:gYear
 else "-9999" cast as xs:gYear (: not a number:)

(:if ( number($date) = 0 ) then
	"0001" cast as xs:gYear
  else  if ($date="-9999" ) then
			$date cast as xs:gYear
  else if (string-length($date) > 4) then (:"undetermined":)
			if (substring($date,1,4) castable as xs:gYear) then
				substring($date,1,4) cast as xs:gYear
  			else "-9999" cast as xs:gYear
 else if (string-length($date) < 4) then
  			if (functx:pad-integer-to-length (number($date),4)) then
				functx:pad-integer-to-length (number($date),4) cast as xs:gYear
  			else "-9999" cast as xs:gYear
  else if ($date castable as xs:gYear) then 
			$date cast as xs:gYear
  else "-9999" cast as xs:gYear
  :)
};

(:********************************** :)
declare function ldsindex:getObjectType($mods as element() ,$profile as xs:string )  {
(:genre or form or profile, in that order :)

let $form:=$mods/mods:physicalDescription/mods:form[1]
let $objectType:=
       if ($mods/mods:genre[@authority="marcgt"]) then
             $mods/mods:genre[@authority="marcgt"][1]/string()
        else if  ($mods/mods:genre) then
                $mods/mods:genre[1]/string()
        else  if ($mods/mods:form[@authority="marccategory"]) then
           $mods/mods:form[@authority="marccategory"][1]/string()
        else  if ($mods/mods:form) then
           $mods/mods:form[1]/string()
       else 
           "bibRecord" (: was $profile:)

let $gmd:= <idx:objectType>{$objectType}</idx:objectType>
let $physdesc:=$mods/mods:physicalDescription/string()
 let $bucketTerm:=
     if (contains($physdesc,"map")) then "map" else
     if ($mods/mods:typeOfResource="notated music") then "notated music" else
     if (contains($physdesc,"film")) then "video" else
     if (contains($physdesc,"sound")) then "audio" else
     if (contains($physdesc,"photo")) then "image" else
     if (contains($physdesc,"computer")) then "text" else 
     if ( $mods/mods:genre[@authority="marcgt"]="web site" ) then "text" else 
     if ( $mods/mods:genre[@authority="marcgt"]="article" ) then "text" else
     if ($mods/mods:originInfo/mods:issuance="continuing") then "text" else
     if (contains($physdesc ,"print")) then "text" else          
         ()

let $category:= 
    if (not(empty($bucketTerm)) ) then
        <idx:category>{$bucketTerm}</idx:category>
    else 
        <idx:categorized>false</idx:categorized>

 let $subcategory:= 
    if($category="text" and $mods/mods:originInfo/mods:issuance="continuing") then 
        <idx:subcategory>serial</idx:subcategory>
    else 
        if($category="text" and $mods/mods:genre[@authority="marcgt"]="web site" ) then 
        <idx:subcategory>web site</idx:subcategory>
            else
        if($category="text" and contains($physdesc,"computer") ) then 
        <idx:subcategory>electronic</idx:subcategory> 
        else
            ()
let $resource:=<idx:resourceType>{$mods/mods:typeOfResource/string()}</idx:resourceType>

return ($category, $subcategory, $resource, $gmd)

};

(: *************************************************:)
declare function ldsindex:getmarccountries($placeCode as xs:string ) {
 
let $countries:=doc("/config/marcCountries.xml")/ctry:codelist

return
    if ($placeCode!="") then
        (:$countries/ctry:country[@code=$placeCode]/string():)
        cts:search(doc("/config/marcCountries.xml")/ctry:codelist//ctry:country, $placeCode)/ctry:name[@authorized="yes"]/string()
        
    else
        replace($placeCode ,"\[\]","")
 
};
(: *************************************************:)
declare function ldsindex:getmarcgacs($placeCode as element()? ) {

    let $gacs:=doc("/config//gacs.skos.rdf")
    (:doc("/config/gacs.skos.rdf"):)
    let $code:=replace($placeCode,"--$","") 
    let $pc1:=
            $gacs//rdf:Description[skos:prefLabel[@xml:lang="zxx"]=$code]
    let $pterm1:=
        if (not(empty($pc1))) then
            $pc1/skos:prefLabel[@xml:lang="en"]/string()
        else ""
    let $pc2:=
         if ($pc1/skos:broader) then
             $gacs//rdf:Description[@rdf:about=$pc1/skos:broader/@rdf:resource]
         else ()
    let $pterm2:=
        if (not(empty($pc2))) then 
            $pc2/skos:prefLabel[@xml:lang="en"]/string() else ""

    let $pc3:=
        if ($pc2/skos:broader) then
            $gacs//rdf:Description[@rdf:about=$pc2/skos:broader/@rdf:resource] else ()
    let $pterm3:=
         if (not(empty($pc3))) then 
          $pc3/skos:prefLabel[@xml:lang="en"]/string() else "" 
    let $pc4:=
         if ($pc3/skos:broader) then
             $gacs//rdf:Description[@rdf:about=$pc3/skos:broader/@rdf:resource] else ()
    let $pterm4:=
         if (not(empty($pc4))) then 
          $pc4/skos:prefLabel[@xml:lang="en"]/string() else ""

return ( if ($pterm1!="") then $pterm1 else "",
       if ($pterm2!="") then $pterm2 else "",
       if ($pterm3!="") then $pterm3 else "",
       if ($pterm4!="") then $pterm4 else ""
     ) 

};

(: *************************************************:)
declare function ldsindex:getPlaces($mods as element()? ) as node()+ {
 (:
  mods has subject/geographic strings
 subject/hierarchicalGeographic nodes with subelements like "country" that will be idx: terms
 and subject/geographicCodes that must be translated from marccountries or gacs 
 All are deduped and returned as one or more idx:aboutPlace nodes and zero or more idx:country/state etc nodes:)

let $pubplaceCodes:=$mods//mods:place/mods:placeTerm[@type="code"]
let $pubplaceT:=$mods//mods:place/mods:placeTerm[@type="text"]
let $pubplaceTexts:= 
    for $item in distinct-values($pubplaceT) 
          return if(exists($item)) then
                 <idx:pubPlace>{$item}</idx:pubPlace>
               else ()
   
let $pubplaceTerms:= (: sequence of text terms :)
    if (exists($pubplaceCodes)) then
        for $pubplace in $pubplaceCodes
        return
            if ($pubplace/@authority="marccountry") then
                ldsindex:getmarccountries($pubplace)               
            else
                if ($pubplace/@authority="marcgac") then
                     ldsindex:getmarcgacs($pubplace)  
                else (:is03166 or unknown :)
                    $pubplace/string()          
    
    else
        for $place in $mods//mods:place/mods:placeTerm[@type="text"]
            return
                replace($place/text(),"\[\]","")
let $pubplaces:= 
    if (exists($pubplaceTerms)) then (: sequence of idx nodes :)
        for $item in distinct-values($pubplaceTerms) 
              return  if (exists($item)) then
               <idx:pubPlace>{$item}</idx:pubPlace>
               else ()
            else  if (not(exists($pubplaceCodes)) and not(exists($pubplaceTerms))) then
             <idx:pubPlace>Undetermined</idx:pubPlace>
             else ()
            
let $placeSet:=distinct-values($mods//mods:subject/mods:geographic/string())
let $placeCodeSet:=$mods//mods:subject/mods:geographicCode
let $hierachicalPlaces:= 
    for $hierachicalPlace in $mods//mods:subject/mods:hierarchicalGeographic/*[string()!='']
        return
            ( <idx:aboutPlace>{$hierachicalPlace/string()}</idx:aboutPlace>,
              element { concat("idx:",local-name($hierachicalPlace)) } 
                {$hierachicalPlace/string()}
            )

   (: sequence of mods:geographic strings, geocodes translated to strings :)
let $subjectPlaceCodes:= 
    ($placeSet,
       if (not(empty($placeCodeSet))) then 
             for $placeCode in $placeCodeSet
                return
                    if ($placeCode/@authority="marccountry") then
                        ldsindex:getmarccountries($placeCode/string())
                    else 
                        if ($placeCode/@authority="marcgac") then
                            (ldsindex:getmarcgacs($placeCode)  )
                        else (:no xwalk avail? :)
                          replace($placeCode/string(),"\[\]","")
             
      else ""
      )   
      (:combine with $hierachicalPlaces nodes :)
let $allSubjects:=(
            for $placeTerm in  distinct-values($subjectPlaceCodes[string()!=""])
                return  <idx:aboutPlace>{$placeTerm}</idx:aboutPlace>,
             $hierachicalPlaces 
          )
let $subjectSet:=
     if (not(empty($allSubjects))) then 
            $allSubjects
         else 
            <idx:aboutPlace>Undetermined</idx:aboutPlace>
return
 (: one or more aboutPlace nodes and one or more pubPlace nodes  :)
    ($subjectSet,$pubplaces,$pubplaceTexts)
};



(:********************************** :)

declare function ldsindex:languages($lang as element(mods:language)*) as element(idx:language)* {
(: takes mods:language or similar (may be sequence), returns de-coded if marclanguage, burst into individual idx:language terms
let $marcLangs:= doc("/config/marcLanguages.xml")/marcLanguages
language crosswalk:
let $skoslangs:=doc("/config/languages.skos.rdf")
languages: take all iso639-2b codes and convert,  one or more sequence <idx:language> nodes
<mods:language><mods:languageTerm type="code" authority="iso639-2b">tib</mods:languageTerm></mods:language>
:)

(:bucket all junk  to "Undetermined":
No linguistic content, invalid, none, Undetermined
:)
let $lang-strings:=
	for $l in $lang/mods:languageTerm
    	let $langLabel := 
			langs:getPrefLabels(
			               		langs:getLanguages(normalize-space($l/string()))
						   		)
		return  if ($langLabel) then
        	     $langLabel 
				else ()
return 
	if (count(distinct-values($lang-strings)) > 0) then
  		for $item in $lang-strings 
    		return <idx:language>{$item}</idx:language>
  	else
   		<idx:language>Undetermined</idx:language>



  (:  let $clean:= for $l in $lang return normalize-space($l/string())  
	let $langdv := distinct-values($clean)
    let $langRDF := langs:getLanguages($langdv)
    let $langLabels := langs:getPrefLabels($langRDF)
    return 
        if (count($langLabels) gt 0) then
            for $term in $langLabels
            return
                if ($term!="No linguistic content") then 
                        <idx:language>{$term}</idx:language>
                    else
                        <idx:language>Undetermined</idx:language>
        else             
            <idx:language>Undetermined</idx:language>           
:)
};




(:********************************** :)
declare function ldsindex:getLocations($mods as element(),$hold as element()? ) { 
(:lcc is the model:
look in holdings 852, then in mods for mxe translations, then mods for strings. if url, then "electronic resource"

mods only returns top level loc1 values right now...
:)
let $locs:=locs:locations()
return 
	if ($hold//hld:d852/hld:sb) then
		for $loc in distinct-values($hold//hld:d852/hld:sb/string())
	  		return
			  (<idx:loc source="hold">
						{for $item in $locs//loc:locationGroup/loc:location[loc:code/string()=$loc]
				        return (							
							<idx:loc2>{$item/loc:loc2/string()}</idx:loc2>,
							<idx:loc2code>{$loc}</idx:loc2code>,							
							<idx:loc1>{$item/ancestor::loc:locationGroup/loc:loc1/string()}</idx:loc1>
							)
						}</idx:loc>
				)
			
	else (:look in mods:) 		            
				if ($mods//mods:location/mods:physicalLocation) then
                    for $loc in distinct-values($mods//mods:location/mods:physicalLocation)                                  
                         return
						  if ($locs//loc:locationGroup/loc:location[loc:code/string()=$loc]) then (: location code from ils in bib852?:)							  
						  	for $item in $locs//loc:locationGroup/loc:location[loc:code/string()=$loc]
								return (
									<idx:loc2>{$item/loc:loc2/string()}</idx:loc2>,
									<idx:loc2code>{$loc}</idx:loc2code>,									
									<idx:loc1>{$item/ancestor::loc:locationGroup/loc:loc1/string()}</idx:loc1>
								)
						  else  <idx:loc><idx:loc1>{ldsindex:cleanLocation($loc)}</idx:loc1></idx:loc>
						  
	            (:else if ($mods//mods:location/mods:url[@xlink:href]) then :)
				else if ($mods//mods:location/mods:url ) then
						 <idx:loc>					 
							<idx:loc1>Electronic Resource</idx:loc1>
						</idx:loc>
					else
					   <idx:loc>					 
							<idx:loc1>Undetermined</idx:loc1>
						</idx:loc>
};


(:********************************** :)
declare function ldsindex:cleanLocation($locString as xs:string ) as xs:string {
(: this is mostly for mods strings...
trim out library address from reading rooms:)

(:actual values from mods:
<modsloc>
  <loc>       
    <loc>Library of Congress Washington, D.C. 20540 USA</loc>        
  </loc>
</modsloc>
:)

if (matches(lower-case($locString),"(prints|pnp|c-p&amp;p)")) then
        "Prints/Photographs Division" else   
        if (matches(lower-case($locString),"(european|-eur)")) then
        "European Division" else
    if (matches(lower-case($locString),"(manuscript|mss)")) then
        "Manuscripts Division" else
    if (matches(lower-case($locString),"(folk|-afc)")) then
        "American Folklife Center" else
        if (matches(lower-case($locString),"-catref")) then 
        "Acquisitions/Bibliographic Access" else
     if (matches(lower-case($locString),"-chlit")) then
        "Children's Literature" else
    if (matches(lower-case($locString),"(geography|map|g&amp;m|-gm/vault)")) then
        "Geography/Map" else
    if (matches(lower-case($locString),"(african|-amed|-afrref|-nreastre)")) then
        "African/Middle Eastern" else
    if (matches(lower-case($locString),"asian")) then
        "Asian Division" else
    if (matches(lower-case($locString),"veteran")) then
        "American Folklife Center" else
      if (matches(lower-case($locString),"la/cmd" ) ) then
        "General Collections" else
        if (matches(lower-case($locString),"la/mic" ) ) then
        "Stored Offiste" else
        if (matches(lower-case($locString),"-llrbr" ) ) then
        "Law Library" else
    if (matches(lower-case($locString),"(law|-ll|fm/ll)" ) ) then
        "Law Library" else
  if (matches(lower-case($locString),"fm/mn" ) ) then
        "Preservation Reformatting" else         
    if (matches(lower-case($locString),"(rare|rbscd)")) then
        "Rare Books" else
    if (matches(lower-case($locString),"serial")) then
        "Newspaper/Current Periodicals" else
    if (matches(lower-case($locString),"(-ser|-n&amp;cpr|/ser)")) then
        "Newspaper/Current Periodicals" else         
        if (matches(lower-case($locString),"-nlsbph")) then
        "NLS/BPH" else
    if (matches(lower-case($locString),"(performing|-mus|/mus)")) then
        "Performing Arts" else
    if (matches(lower-case($locString),"-busrr")) then
        "Science/Business" else
   if (matches(lower-case($locString),"(science|-scirr|-fm/gc/sm)")) then
        "Science/Business" else
  if (matches(lower-case($locString),"music division")) then
        "Performing Arts" else
         if (matches(lower-case($locString),"-mrr")) then
        "General Collections" else
  if (matches(lower-case($locString),"(microform|-micrr)")) then
        "Microform" else  
   if (matches(lower-case($locString),"-mp&amp;tv")) then
        "Motion Picture/TV" else
  if (matches(lower-case($locString),"moving image")) then
        "Motion Picture/TV" else
  if (matches(lower-case($locString),"motion")) then
        "Motion Picture/TV" else
  if (matches(lower-case($locString),"(recorded sound|recsound|-rsrc)")) then
       "Recorded Sound" else       
       if (matches(lower-case($locString),"(-mrc|-fm/mrc)")) then
       "General Collections" else
 if (matches(lower-case($locString),"newspaper")) then
        "Newspapers/Current Periodicals" else
 if (matches(lower-case($locString),"(general|-gencoll|fm/gc)")) then
        "General Collections" else     
        if (matches(lower-case($locString),"(online|-eser)")) then
        "Electronic Resource" else
    if (matches(lower-case($locString),"(library of congress|dlc)")) then
            "Library of Congress"
    else (: includes m-Problem :)
        "Miscellaneous"

};


(:********************************** :)
declare function ldsindex:getNameTitle($mods as node())  {
(: not called any more; see hitlist :)
let $title:=normalize-space(string($mods/mods:titleInfo[not(@type)][1]))
let $name:=$mods/mods:name[1]
let $nameDisplay:= 
    if ($mods/mods:name) then 
     for $node in $name
        return string-join ($node/*[local-name()!="role" and (@type!="date" or not(@type))]," ")     
         
    else ""

let $nameTitle:= if ($nameDisplay!="" and $title!="") then ($nameDisplay, " ", $title) else ""

return 
   element idx:nameTitle {$nameTitle}  
};


(: *************************************************:)
declare function ldsindex:getTitles($mods as element(), $membership ) {
(: may have more than one per term per doc :)
(:sort title, uniform title
add related titles as well 20110328
:)

let $titleSet:=$mods//mods:titleInfo
return 
 (  element idx:titleSort {
                if ( $titleSet[1]/mods:subTitle and $titleSet[1]/mods:nonSort) then 
                         concat($titleSet[1]/mods:title/string(),", ",$titleSet[1]/mods:nonSort/string(),"; ", $titleSet[1]/mods:subTitle/string())
                       else   if ( $titleSet[1]/mods:subTitle ) then
                          concat($titleSet[1]/mods:title/string(), "; ", $titleSet[1]/mods:subTitle/string())
						 else if ($titleSet[1]/mods:title/string()) then 
						 $titleSet[1]/mods:title/string()
						 else
						 "[Undetermined]"
                          },
    for $title in $titleSet
        return        
            (
			 if ($title/@type/string()="uniform") then
        		(<idx:uniformTitle>{string-join($title/*, " ")}</idx:uniformTitle>,
                <idx:title>{string-join($title/*, " ")}</idx:title>  )
        	else if ($title/parent::mods:relatedItem/@type/string()="series") then
        		(<idx:seriesTitle>{string-join($title/*," ")}</idx:seriesTitle>,
                <idx:title>{string-join($title/*," ")}</idx:title>  )
        	else if (exists($title)) then
         		<idx:title>{string-join($title/*," ")}</idx:title>
			else 
		 		<idx:title>[Undetermined]</idx:title>
		(:	,
			if (contains($membership,"pae")) then
				<idx:pae-titleLex>{string-join($title/*," ")}</idx:pae-titleLex>
				else ():)
			)
   )
};
(: *************************************************:)
declare function ldsindex:getNotes($mods as element() ) {
(: may have more than one per term per doc :)

let $noteSet:=$mods//mods:note[@type]

for $note in $noteSet[not(matches("(additionalphysicalform |systemdetails| venue|reproduction|local|language)",lower-case(replace(@type,"\W+","")) ) )]
  let $element:=lower-case(replace($note/@type,"\W+",""))
    return 
         element {concat("idx:", $element) } 
            {$note/string()}
  
};
(: *************************************************:)
declare function ldsindex:getRole($roleterm as element()  ) as xs:string {

    if ($roleterm/@type="text" or $roleterm[not(@type)]) then       
    
 if (ends-with($roleterm/string(),'.') and not(ends-with($roleterm/string(),'etc.'))) then       
            lower-case(substring($roleterm/string(),1, string-length($roleterm/string()) -1) )

        else
            lower-case($roleterm/string())
    else
        let $rels-rdf := relators:getRelators($roleterm/string())
        let $rels-label := relators:getPrefLabels($rels-rdf)
        return
            if (count($rels-label) gt 0) then
                 for $rl in $rels-label return lower-case($rl)
            else
                concat($roleterm[@type = "code"]/string(), " error")
};


(: *************************************************:)
declare function ldsindex:getNames($mods as element() , $membership as xs:string) {
(: may have more than one per term per doc :)

let $aboutSet:=$mods//mods:subject/mods:name
let $bySet:=($mods/mods:name[local-name(parent::*)!="subject"],
			$mods/mods:relatedItem[@type="constituent"]/mods:name)

(: removed namesort from the"for $name in $aboutSet" below; moved to maincreator section:
	,
    element idx:nameSort {
            $bySet[1]//mods:namePart[not(@type) or @type!="date"]/string()}     
:)
return  (
    for $name in $bySet              
               let $attrib:= 
                    if ($name/mods:role) then                
                      for $roleterm in $name/mods:role/mods:roleTerm
                        let $role:= ldsindex:getRole($roleterm)                    
                        return    
		                      if ( not(contains($role,"error"))  ) then                           
                                string($role)
		                      else  ()                           
                   else ()
                return
                    ( element idx:byName
                        { if (not(empty($attrib))) then
                           		attribute role {string-join($attrib,' | ')}
                           	else (),
                        if ($name/mods:role/mods:roleTerm[@type='code']) then
                           		attribute marcrels {string-join($name/mods:role/mods:roleTerm[@type='code'],' ')}
                           	else () ,    
                         	$name/*[local-name()!="role"]/string() 
                        },                      
                        <idx:name field_byName="byName">                              
                            {$name/*[local-name()!="role"]/string()}</idx:name>
                            
					)
    ,
    for $name in $aboutSet
        return   
            ( <idx:aboutName>{$name/*[local-name()!="role"]/string()}</idx:aboutName>,
				<idx:name field_aboutName="aboutName">{$name/*[local-name()!="role"]/string()}</idx:name>)
    )
};

declare function ldsindex:getMattype($mxe as element()  ) as element()+ {

let $leader6:= $mxe//mxe:leader/mxe:leader_cp06
let $leader6_2:= substring($mxe/mxe:leader,7,2)
let $control6:=$mxe/mxe:controlfield_006/mxe:c006_cp00
let $control7:= $mxe/mxe:controlfield_007/mxe:c007_cp00
let $control821:= $mxe/mxe:controlfield_008/mxe:c008_cp21
let $materials:=matconf:materials()
 
 let $mattype:=
       if ($materials//mat:materialtype[@tag='008_21_1'][@code=$control821]/mat:desc/string()!="" ) then
		    $materials//mat:materialtype[@tag='008_21_1'][@code=$control821]
      else if ($materials//mat:materialtype[@tag='000_06_2'][@code=$leader6_2]/mat:desc/string()!="" ) then
		    $materials//mat:materialtype[@tag='000_06_2'][@code=$leader6_2]
      else if ($materials//mat:materialtype[@tag='007_00_1'][@code=$control7]/mat:desc/string()!="") then
		    $materials//mat:materialtype[@tag='007_00_1'][@code=$control7]
      else if ($materials//mat:materialtype[@tag='006_00_1'][@code=$control6]/mat:desc/string()!="") then
                $materials//mat:materialtype[@tag='006_00_1'][@code=$control6]
       else ()
 
       return (<idx:typeOfMaterial>{$mattype/mat:desc/string()}</idx:typeOfMaterial>,
       <idx:materialGroup>{$mattype/mat:short/string()}</idx:materialGroup>)
       
};
declare function ldsindex:getModsMattype($mods as element()  ) as element()+ {

let $type:=$mods/mods:typeOfResource

let $tag:=lower-case(replace($type/string(),"\W","" ))
let $manuscript:=$type/@manuscript
let $collection:=$type/@collection
let $materials:=matconf:materials()//mat:materialtype[@code="mods"]

let $mattype:=     
   if ($materials[replace(@tag,"\W","")=$tag and not(@manuscript) and not(@collection) ])  then
          $materials[replace(@tag,"\W","")=$tag and not(@manuscript) and not(@collection) ]
   else if (exists($materials[replace(@tag,"\W","") = $tag and @manuscript=$manuscript ] ) ) then
          $materials[replace(@tag,"\W",())= $tag  and @manuscript=$manuscript] 
     else     if (exists($materials[replace(@tag,"\W","")=$tag and @collection=$collection]) ) then
          $materials[replace(@tag,"\W","")=$tag  and @collection=$collection]
      else
        (<mat:desc>Undetermined</mat:desc>,
		<mat:short>Undetermined</mat:short>)
		
return (<idx:typeOfMaterial>{$mattype/mat:desc/string()}</idx:typeOfMaterial>,
          <idx:materialGroup>{$mattype/mat:short/string()}</idx:materialGroup>)
       
};
(: *************************************************:)
declare function ldsindex:getTopics($mods as element() ) as element()* {
(: may have more than one per term per doc :)
(: not finished:)
let $subjectSet:=$mods//mods:subject[mods:topic[1]]
let $result:=
    ( if (empty($subjectSet)) then
       <idx:topic>Undetermined</idx:topic>
    else
                 for $topic in $subjectSet[@authority]       
            let $auth:=concat(normalize-space($topic/@authority),"Topic")
                       return 
                       (
               (:subjects from: xdmp:http-get("http://www.loc.gov/standards/sourcelist/subject.html") :)           
                (:if (matches(normalize-space($topic/@authority),"(aass|aat|abne|agrifors|agrovoc|agrovocf|agrovocs|afset|aiatsisl|aiatsisp|aiatsiss|aktp|albt|allars|apaist|asft|asrcrfcd|asrcseo|asrctoa|asth|atla|aucsh|barn|bella|bet|bhammf|bhashe|bibalex|biccbmc|bicssc|bidex|bisacmt|bisacrt|bisacsh|bjornson|blcpss|blmlsh|blnpn|bt|cabt|cash|cct|ccte|cctf|cdcng|ceeus|chirosh|cht|ciesiniv|cilla|conorsi|csahssa|csalsct|csapa|csh|csht|cstud|czenas|dcs|ddcri|ddcrit|dissao|dit|drama|dtict|ebfem|eclas|eet|eflch|eks|embne|ept|ericd|est|eum|eurovocen|eurovocsl|fast|finmesh|fire|fmesh|fnhl|francis|galestne|gccst|gem|georeft|gst|gtt|hamsun|hapi|helecon|henn|hkcan|hlasstg|hoidokki|hrvmesh|huc|ica|icpsr|idas|idsbb|idszbz|idszbzes|idszbzna|idszbzzg|idszbzzh|idszbzzk|iescs|iest|ilpt|inist|inspect|ipat|ipsp|isis|itglit|itrt|jhpb|jhpk|jlabsh|kaa|kao|kaunokki|kdm|kitu|kkts|kssbar|kta|ktpt|ktta|kula|kupu|lacnaf|larpcal|lcac|lcsh|lcshac|lcstt|lctgm|lemac|lemb|liv|lnmmbr|local|ltcsh|lua|maaq|mar|masa|mech|mesh|mipfesd|mmm|mpirdes|msc|msh|mtirdes|musa|muzeukc|muzeukn|muzvukci|naf|nal|nalnaf|nasat|ncjt|ndllsh|netc|nicem|nimacsc|nlgaf|nlgkk|nlgsh|nlmnaf|nsbncf|nskps|ntcpsc|ntcsd|ntissc|nzggn|nznb|ogst|opms|pascal|peri|pha|pmbok|pmcsg|pmont|pmt|poliscit|popinte|pkk|precis|prvt|psychit|qlsp|qrma|qrmak|qtglit|quiding|ram|rasuqam|renib|reo|rero|rerovoc|rma|rpe|rswk|rswkaf|rugeo|rurkp|rvm|sanb|sao|sbiao|sbt|scbi|scgdst|scisshl|scot|sears|sfit|sgc|sgce|shbe|she|sigle|sipri|sk|skon|slem|smda|snt|socio|sosa|spines|ssg|stw|swd|swemesh|taika|taxhs|tesa|test|tgn|tho|thub|tlka|tlsh|trt|trtsa|tsht|ttka|tucua|ulan|umitrist|unbisn|unbist|unescot|usaidt|vmj|waqaf|watrest|wgst|wot|wpicsh|ysa)") ):)  
                if (matches(normalize-space($topic/@authority),"^(georeft|hlasstg|hrvmesh|lacnaf|lcsh|lcshac|lcstt|lctgm|mesh|naf|nal|nalnaf|nlmnaf|swemesh|unescot|usaidt)$") )
                     then     
                   element { concat("idx:",$auth) }  {$topic/mods:topic/string()}                   
                     else ()
                ,
                <idx:topic>{$topic/mods:topic/string()}</idx:topic>
                ),  
    for $topic2 in $subjectSet[not(@authority)]  
           return    
        <idx:topic>{$topic2/mods:topic/string()}</idx:topic>    
    )
return $result
};
(: *************************************************:)
declare function ldsindex:getModsPub($mods as element() ){
let $pubPlace:=ldsindex:getPlaces($mods)/idx:pubPlace[1]/string()
(:(ldsindex:getPlaces($mods)[name()="idx:pubPlace"])[1]/string():)

let $pubDates:= ldsindex:getPubDates($mods/mods:originInfo) 
let $beginpub:= ($pubDates/idx:beginpubdate)[1]/string()

let $publisher:= ($mods/mods:originInfo/mods:publisher)[1]/string()
return
    (
    if ($pubPlace ne "Undetermined" and $publisher ne "Undetermined" and $beginpub ne "Undetermined") then
            element idx:pubinfo {concat($pubPlace,": ",$publisher,", ", $beginpub)} 
    else  if ($publisher ne "Undetermined" and $pubDates/idx:beginpubdate ne "Undetermined") then 
            element idx:pubinfo {concat($publisher,", ", $beginpub)} 
        else if ( $pubPlace ne "Undetermined" and $pubDates/idx:beginpubdate ne "Undetermined") then 
            element idx:pubinfo {concat( $pubPlace,": ", $beginpub)}
        else if ($pubPlace ne "Undetermined"  and $publisher ne "Undetermined") then
            element idx:pubinfo {concat($pubPlace,": ",$publisher)}
        else if ($pubPlace ne "Undetermined"  and $publisher ne "Undetermined") then
            element idx:pubinfo {concat($pubPlace,": ",$publisher)}
        else if ($beginpub ne "Undetermined" ) then
            element idx:pubinfo {$beginpub}
        else if ($pubPlace ne "Undetermined" ) then
            element idx:pubinfo {$pubPlace}
        else if ($publisher ne "Undetermined") then
            element idx:pubinfo {$publisher}
    else ()       
    ,$pubDates  )
       }  ;
(: *************************************************:)
declare function ldsindex:getModsHitlist($mods as element() ) as element() + {
(:digital objects may have no mxe, so use mods:)
let $modstitle:=normalize-space(string-join(($mods/mods:titleInfo[not(@type)])[1],' '))

let $modstitleText:= 
        if (string-length($modstitle) >200 ) then
                concat(ldsindex:findLastSpace(substring($modstitle,1,200)),"...")
        else if (substring($modstitle,string-length($modstitle),1) = "/") then
                    substring($modstitle,1,string-length($modstitle)-1) 
        else $modstitle
     let $modstitleText:=    element idx:title {$modstitleText} 
  
let $mxesubjectLex:=
    <subjects>{
                    for $subj in $mods//mods:subject[@authority='lcsh']
                           let $sub:=                     
                                string-join($subj/*,"--")                                    
                    return   
                    <idx:subjectLexicon  vocab_lcsh ="lcsh">{  normalize-space($sub) }</idx:subjectLexicon>
                    }
     </subjects>
                     (: remove $c roles/locations of meetings 1/30/2011 :)
let $modscreator:=
(: added support for family, given for nksip :)
 if ($mods/mods:name[1]/mods:namePart[@type='given'] and $mods/mods:name[1]/mods:namePart[@type='family'] ) then
 	concat($mods/mods:name[1]/mods:namePart[@type='family']/string(),', ', $mods/mods:name[1]/mods:namePart[@type='given']/string())
else 
   string-join($mods/mods:name[1]/mods:namePart[not(@type='date') and not(@type='role')],' ')
let $role:= if ($mods/mods:name[1]/mods:role) then
				ldsindex:getRole($mods/mods:name[1]/mods:role/mods:roleTerm)
			else ()
let $modscreator880:= 
        if ($mods/mods:name[@xml:lang]) then   string-join(($mods/mods:name[@xml:lang])[1]/mods:namePart[not(@type='date') and not(@type='role')],' ')
                        else ()          
let $namelang:= 
        if ($mods/mods:name[@xml:lang]) then   ($mods/mods:name[@xml:lang])[1]/@xml:lang/string()                         
                        else ()                  

let $nameTitle:= if (exists($modstitle) and $modscreator!='' )  then
                             element idx:nameTitle {concat($modscreator,". ",$modstitle)}
                        else ()

let $modspub:=ldsindex:getModsPub($mods)
						
(:let $mattype:=$mods/mods:typeOfResource/string() :)
(:needs work; add to matconff etc:)

let $mattype:=ldsindex:getModsMattype($mods)
(:let $uri:=$mods//mods:recordInfo[not(contains(mods:recordIdentifier, 'lcdb'))]/mods:recordIdentifier/string()
let $files:=    
    if ( $is-digitized ) then
  		    <idx:files format="json"><noindex xmlns="info:lc/xq-modules/noindex"> {utils:mets-files($uri,"json","all")}</noindex></idx:files>
  		else ():)
(:nameSort is the first name, zero or one per doc :)
return
        ( <idx:display>
               {$modstitleText} 
                  { if (exists($modscreator) ) then 
                          element idx:mainCreator
                           { attribute role {$role},                         
                         $modscreator}                          
                      else () ,
                     if (exists($modscreator880)  and exists($namelang)) then 
                         <idx:mainCreator xml:lang="{$namelang}"> { attribute role {$role},        $modscreator880} </idx:mainCreator>
                        else
                     if (exists($modscreator880) ) then 
                         element idx:mainCreator  { attribute role {$role},        $modscreator880}
                      else ()                  
                   } 
               {$modspub}
              
			   {if (exists($modscreator) ) then 
                          element idx:nameSort {$modscreator} 
                      else () 
					  }
               {$mattype}
           
        </idx:display>,             
        element idx:titleLexicon {$modstitle},            
        $mxesubjectLex/*,
        $nameTitle
		
		) 
};
declare function ldsindex:getHitlist($mods as element() ,$mxe as element()) as element()+ {

(: display terms for search hit list also includes mxe elements for title and subject lexicon indexes:)
(: 
          :)        
let $mxetitle:=
      for $subpart in $mxe//mxe:datafield_245     
       return    string-join($subpart/*[local-name()!="d245_subfield_c"][local-name()!="d245_subfield_6"]," ")
         
let $mxetitleText:= 
        if (string-length($mxetitle) >200 ) then
                concat(ldsindex:findLastSpace(substring($mxetitle,1,200)),"... / ",$mxe/mxe:datafield_245/mxe:d245_subfield_c[1])
        else if (substring($mxetitle,string-length($mxetitle),1) = "/") then
                    substring($mxetitle,1,string-length($mxetitle)-1) 
        else $mxetitle

let $mxetitleText:=element idx:title {if (exists($mxetitleText)) then $mxetitleText  else "[Unknown]"}        

let $mxetitleLex:=
       for $data in $mxe//mxe:datafield_245/*[local-name()!="d245_subfield_6"] return concat($data/string()," ")

                  (: subjects should be from known controlled lists, so  653  is out(uncontrolled index) :)

let $mxesubjectLex:=
    <subjects>{
                    for $subj in $mxe//*[(contains(local-name(),"datafield_6") and not(local-name()='datafield_653')) or (local-name()="datafield_880" and starts-with(mxe:d880_subfield_6,'6') )]
                           let $sub:=                     
                                string-join($subj/*[not(matches(local-name(),"(subfield_2|subfield_6)") )],"--")
							let $auth:= if ($subj/@ind2="0") then "lcsh" 
											else if  ($subj/@ind2="1") then "lcshac"  
											else if  ($subj/@ind2="2")  then "mesh"  
											else if  ($subj/@ind2="5")  then "csh"
											else if  ($subj/@ind2="3")  then "nal"
											else if  ($subj/@ind2="6")  then "rvm"
									   else ()  
				let $authattrib:=concat("vocab_",$auth)
                    return
                    	if ($auth!='') then
                     		<idx:subjectLexicon > {attribute {$authattrib} {$auth} } {  $sub }</idx:subjectLexicon>
                     	else
                     		<idx:subjectLexicon > { $sub }</idx:subjectLexicon>
                    }
     </subjects>
                     (: remove $c roles/locations of meetings 1/30/2011 :)
let $pname:= for $data in $mxe//mxe:datafield_100
                        return string-join($data/*[local-name()!="d100_subfield_e" and local-name()!="d100_subfield_4" and local-name()!="d100_subfield_6" and local-name()!="d100_subfield_c" ]," ")                      

let $corpname:=  for $data in $mxe//mxe:datafield_110
                            return string-join($data/*[local-name()!="d110_subfield_e" and local-name()!="d110_subfield_4" and local-name()!="d110_subfield_6" and local-name()!="d110_subfield_c"]," ")                             

let $meetname:= for $data in $mxe//mxe:datafield_111
                        return string-join($data/*[local-name()!="d111_subfield_j" and local-name()!="d111_subfield_4" and local-name()!="d111_subfield_6" and local-name()!="d111_subfield_c"]," ")                             

let $pname880 :=for $data in $mxe//mxe:datafield_880[starts-with(mxe:d880_subfield_6,'100')]
                        return string-join($data/*[local-name()!="d880_subfield_e" and local-name()!="d880_subfield_4" and local-name()!="d880_subfield_6" and local-name()!="d880_subfield_c"]," ")  

let $corpname880:=  for $data in $mxe//mxe:datafield_880[starts-with(mxe:d880_subfield_6,'110')]
                            return string-join($data/*[local-name()!="d880_subfield_e" and local-name()!="d880_subfield_4" and local-name()!="d880_subfield_6" and local-name()!="d880_subfield_c"]," ")                             

let $meetname880:= for $data in $mxe//mxe:datafield_880[starts-with(mxe:d880_subfield_6,'111')]
                        return string-join($data/*[local-name()!="d880_subfield_j" and local-name()!="d880_subfield_4" and local-name()!="d880_subfield_6" and local-name()!="d880_subfield_c"]," ")                             

let $namelang:= if ($mxe//mxe:datafield_880[matches(mxe:d880_subfield_6,'^(100|110|111)+') and contains(mxe:d880_subfield_6,'(2') ] ) then   "he" 
                        else if ($mxe//mxe:datafield_880[matches(mxe:d880_subfield_6,'^(100|110|111)+') and contains(mxe:d880_subfield_6,'(3')] ) then "ar" 
                        else ()                  

let $corpname:=  for $data in $mxe//mxe:datafield_110
                            return string-join($data/*[local-name()!="d110_subfield_e" and local-name()!="d110_subfield_4" and local-name()!="d110_subfield_6" and local-name()!="d100_subfield_c"]," ")                             
let $meetname:= for $data in $mxe//mxe:datafield_111
                        return string-join($data/*[local-name()!="d111_subfield_j" and local-name()!="d111_subfield_4" and local-name()!="d111_subfield_6" and local-name()!="d100_subfield_c"]," ")                             

let $mxecreator:= if ( exists($pname)) then $pname 
                            else  if (exists($corpname)) then $corpname
                            else $meetname
let $mxecreator880:= if ( exists($pname880)) then $pname880
                            else  if (exists($corpname880)) then $corpname880
                            else $meetname880
                            

let $nameTitle:= if (exists($mxetitle) and exists($mxecreator))  then
                             <idx:nameTitle>{concat($mxecreator,". ",$mxetitle)}</idx:nameTitle>
                        else ()
let $pubDates:= ldsindex:getPubDates($mods/mods:originInfo)
let $mxepub:= 		
				if ($mxe/mxe:datafield_260) then
				element idx:pubinfo {	string-join($mxe/mxe:datafield_260/*[local-name()!="d260_subfield_6"]," ")}
				else
					ldsindex:getModsPub($mods)			
				
(:let $mxepub:=element idx:pubinfo {string-join($mxe/mxe:datafield_260/*[local-name()!="d260_subfield_6"]," ")}:)
let $mattype:=ldsindex:getMattype($mxe)
(:potentially multiple mainCreators for lexicon, but max one namesort per doc:)

(:for files list (esp ia pages:)
(:let $uri:=$mods//mods:recordInfo[not(contains(mods:recordIdentifier, 'lcdb'))]/mods:recordIdentifier/string()
let $files:=    
    if ( $is-digitized ) then
  		    <idx:files format="json"><noindex xmlns="info:lc/xq-modules/noindex"> {utils:mets-files($uri,"json","all")}</noindex></idx:files>
  		else ():)
return
        ( <idx:display>
               {$mxetitleText} 
                  { if (exists($mxecreator) ) then 
                          element idx:mainCreator {$mxecreator} 
                      else () ,
                     if (exists($mxecreator880)  and exists($namelang)) then 
                         <idx:mainCreator xml:lang="{$namelang}"> {$mxecreator880} </idx:mainCreator>
                        else
                     if (exists($mxecreator880) ) then 
                         element idx:mainCreator880  {$mxecreator880}
                      else ()                  
                   } 
               {$mxepub}               
               {$mattype}
			   {if (exists($mxecreator) ) then 
                     element idx:nameSort {$mxecreator} 
                else () 
				}
        </idx:display>,
        if (exists($mxetitleLex)  ) then 
              element idx:titleLexicon {$mxetitleLex}
        else
			 (),
        $mxesubjectLex/*,
        $nameTitle,
  		$pubDates  		
  		)
};


(: *************************************************:)
declare function ldsindex:getFacets($mods as element()){

let $genreSet:=$mods/mods:genre
let $marcgt:=
  if ($genreSet[@authority="marcgt"]) then 
      for $term in distinct-values($genreSet[@authority="marcgt"])
        return <idx:marcgt>{replace(string($term),"[\.\[\]]","")}</idx:marcgt>
  else
            <idx:marcgt>Undetermined</idx:marcgt>

let $tgmgenre:=
    if ($genreSet[@authority="gmgpc" or @authority="tgm"]) then
          for $term in distinct-values($genreSet[@authority="gmgpc" or @authority="tgm"])
            return <idx:tgmgenre>{ replace(string($term),"[\.\[\]]","")} </idx:tgmgenre>
    else
            <idx:tgmterm>Undetermined</idx:tgmterm>

let $genres:=
  for $term in distinct-values($genreSet[not(@authority="marcgt" or @authority="gmgpc" or @authority="tgm")])
    return <idx:genre>{replace(string($term),"[\.\[\]]","")}</idx:genre>


let $formSet:=$mods//mods:form

let $forms:=
  for $term in distinct-values($formSet)
   order by string($term)
    return 
     <idx:form>{string($term)}</idx:form>

let $marcform:= 
    <idx:marcform>{
           if (empty($formSet[@authority=("marccategory","marcform")]/string()) ) then 
                "Undetermined" 
            else
                 $formSet[@authority=("marccategory","marcform")]/string() 
    }</idx:marcform>

let $resource:=$mods/mods:typeOfResource
let $collection:= if ($resource/@collection="yes") then "true" else "false"

let $manuscript:= if ($resource/@manuscript/string()="yes") then "true" else "false"
(: lcclass is handled in own function now to merge with holdings :)
(:
let $lcclass:=
            if ($mods//mods:classification[@authority="lcc"] ) then
                $mods//mods:classification[@authority="lcc"][1]/string()
            else "Undetermined"

let $strip := replace($lcclass, "(\s+|\.).+$", "")
let $subclassCode := replace($strip, "\d", "")

let $validLCC:=("DAW","DJK","KBM","KBP","KBR","KBU","KDC","KDE","KDG","KDK","KDZ","KEA","KEB","KEM","KEN","KEO","KEP","KEQ","KES","KEY","KEZ","KFA","KFC","KFD","KFF","KFG","KFH","KFI","KFK","KFL","KFM","KFN","KFO","KFP","KFR","KFS","KFT","KFU","KFV","KFW","KFX","KFZ","KGA","KGB","KGC","KGD","KGE","KGF","KGG","KGH","KGJ","KGK","KGL","KGM","KGN","KGP","KGQ","KGR","KGS","KGT","KGU","KGV","KGW","KGX","KGY","KGZ","KHA","KHC","KHD","KHF","KHH","KHK","KHL","KHM","KHN","KHP","KHQ","KHS","KHU","KHW","KJA","KJC","KJE","KJG","KJH","KJJ","KJK","KJM","KJN","KJP","KJR","KJS","KJT","KJV","KJW","KKA","KKB","KKC","KKE","KKF","KKG","KKH","KKI","KKJ","KKK","KKL","KKM","KKN","KKP","KKQ","KKR","KKS","KKT","KKV","KKW","KKX","KKY","KKZ","KLA","KLB","KLD","KLE","KLF","KLH","KLM","KLN","KLP","KLQ","KLR","KLS","KLT","KLV","KLW","KMC","KME","KMF","KMG","KMH","KMJ","KMK","KML","KMM","KMN","KMP","KMQ","KMS","KMT","KMU","KMV","KMX","KMY","KNC","KNE","KNF","KNG","KNH","KNK","KNL","KNM","KNN","KNP","KNQ","KNR","KNS","KNT","KNU","KNV","KNW","KNX","KNY","KPA","KPC","KPE","KPF","KPG","KPH","KPJ","KPK","KPL","KPM","KPP","KPS","KPT","KPV","KPW","KQC","KQE","KQG","KQH","KQJ","KQK","KQM","KQP","KQT","KQV","KQW","KQX","KRB","KRC","KRE","KRG","KRK","KRL","KRM","KRN","KRP","KRR","KRS","KRU","KRV","KRW","KRX","KRY","KSA","KSC","KSE","KSG","KSH","KSK","KSL","KSN","KSP","KSR","KSS","KST","KSU","KSV","KSW","KSX","KSY","KSZ","KTA","KTC","KTD","KTE","KTF","KTG","KTH","KTJ","KTK","KTL","KTN","KTQ","KTR","KTT","KTU","KTV","KTW","KTX","KTY","KTZ","KUA","KUB","KUC","KUD","KUE","KUF","KUG","KUH","KUN","KUQ","KVB","KVC","KVE","KVH","KVL","KVM","KVN","KVP","KVQ","KVR","KVS","KVU","KVW","KWA","KWC","KWE","KWG","KWH","KWL","KWP","KWQ","KWR","KWT","KWW","KWX","KZA","KZD","AC","AE","AG","AI","AM","AN","AP","AS","AY","AZ","BC","BD","BF","BH","BJ","BL","BM","BP","BQ","BR","BS","BT","BV","BX","CB","CC",      "CD","CE","CJ","CN","CR","CS","CT","DA","DB","DC","DD","DE","DF","DG","DH","DJ","DK","DL","DP","DQ","DR","DS","DT","DU","DX","GA","GB","GC","GE",    "GF","GN","GR","GT","GV","HA","HB","HC","HD","HE","HF","HG","HJ","HM","HN","HQ","HS","HT","HV","HX","JA","JC","JF","JJ","JK","JL","JN","JQ","JS","JV","JX","JZ","KB","KD","KE","KF","KG","KH","KJ","KK","KL","KM","KN","KP","KQ","KR","KS","KT","KU","KV","KW","KZ","LA","LB","LC","LD","LE",  "LF","LG","LH","LJ","LT","ML","MT","NA","NB","NC","ND","NE","NK","NX","PA","PB","PC","PD","PE","PF","PG","PH","PJ","PK","PL","PM","PN","PQ","PR","PS","PT","PZ","QA","QB","QC","QD","QE","QH","QK","QL","QM","QP","QR","RA","RB","RC","RD","RE","RF","RG",   "RJ","RK","RL","RM","RS","RT","RV","RX","RZ","SB","SD","SF","SH","SK","TA","TC","TD","TE","TF","TG","TH","TJ","TK","TL","TN","TP","TR","TS","TT","TX","UA","UB","UC","UD","UE","UF","UG","UH","VA","VB","VC","VD","VE","VF","VG","VK","VM","ZA","A","B","C","D","E","F","G","H","J","K","L","M","N","P","Q","R","S","T","U","V","Z")
let $classLabels:=
    if ($subclassCode = $validLCC) then        
        lcc:getLCClass($subclassCode)                                 
    else if ($subclassCode="LAW") then
        <idx:lcc1>Unclassed (Law)</idx:lcc1>      
        else <idx:lcc1>Unclassed</idx:lcc1>
		:)
let $deweyclass:=
            if ($mods//mods:classification[@authority="ddc"]) then
               concat($mods//mods:classification[@authority="ddc"][1]/string()," ",$mods//mods:classification[@authority="ddc"][1]/@edition)
            else "Undetermined"
let $noclass:=
            if ($mods//mods:classification[not(@authority)]) then
                <idx:noclass>{$mods//mods:classification[not(@authority)][1]/string()}</idx:noclass>
            else ()
let $otherclass:=
            if ($mods//mods:classification[(@authority!="ddc" and @authority!="lcc")]) then
                <idx:otherclass>{$mods//mods:classification[(@authority!="ddc" and @authority!="lcc")][1]/string()}</idx:otherclass>
            else ()

(:let $hasLink := 
		if ($mods/mods:identifier[@type="hdl"] or $mods/mods:location/mods:physicalLocation[@xlink] or  $mods/mods:location/mods:url   )  then 
                "true" else "false"
:)

let $lang:=$mods/mods:language[@objectPart!="translation" or not(@objectPart)][mods:languageTerm[@authority="iso639-2b"][@type="code"]]

let $language:= 
    if ($lang) then ldsindex:languages($lang)
     else if   ($mods/mods:language/mods:languageTerm[@type='text']) then
            <idx:language>{$mods/mods:language/mods:languageTerm[@type='text']/string()}</idx:language>
     else
     <idx:language>Undetermined</idx:language>
(: with holdings added, this is moved to getlocations :)

(:let $locationSet:= 
            if ($mods//mods:location/mods:physicalLocation[not(@xlink:href)]) then
                    (for $loc in distinct-values($mods//mods:location/mods:physicalLocation[not(@xlink:href)])                                  
                          return  ldsindex:cleanLocation($loc)
            else "Undetermined"
let $location:= for $place in distinct-values($locationSet)
                        return <idx:location>{$place}</idx:location>                     
:)
let $access:= if ($mods/mods:accessCondition) then 
    $mods/mods:accessCondition
  else "Undetermined"
let $abstract:=if ($mods/mods:abstract) then 
                          <idx:abstract>{$mods/mods:abstract[1]/string()}</idx:abstract>
                     else ()

return
   <idx:facets>
       {$marcgt}{$tgmgenre}{$genres}
       {$marcform}
       {$forms}    
       <idx:collection>{$collection}</idx:collection>
       <idx:manuscript>{$manuscript}</idx:manuscript>
        {$language} 
       <!--<idx:lcclass>{$lcclass}</idx:lcclass>
        <idx:lcc>{$classLabels}</idx:lcc>-->
       <idx:dewey>{$deweyclass}</idx:dewey>    
       {$noclass}
       {$otherclass}
       <!---{$location} -->
       <!--<idx:hasLink>{$hasLink}</idx:hasLink>-->
       {$abstract}
    </idx:facets>
};

(:********************************** :)
declare function ldsindex:getIsbn($isbn as xs:string ) as element()* {
(:
let $isbn1:="9780792312307" (:produces 0792312309 ok:)
let $isbn1:="0792312309" (:produces  9780792312307 ok:)
let $isbn1:="0-571-08989-5" (:produces 9780571089895  ok:)
let $isbn1:="0 571 08989 5" (:produces 9780571089895  ok:)
verify here:http://www.isbn.org/converterpub.asp
let $isbn:="paperback" (:produces "error"  ok:)
:) 

let $cleanIsbn:=replace($isbn,"[- ]+","")
(:let $isbnNum:=replace($cleanIsbn,"^[^0-9]*(\d+)[^0-9]*$","$1" ):) 
(: test on isbn 10, 13, hyphens, empty, strings only :)

let $isbnNum1:=  replace($cleanIsbn,"^[^0-9]*(\d+)[^0-9]*$","$1" ) 
let $isbnNum:= if (string-length($isbnNum1)=9) then concat($isbnNum1,'X') else $isbnNum1

(: test on isbn 10, 13, hyphens, empty, strings only :)

return
        if (number($isbnNum) or number($isbnNum1) ) then
    
	        if ( string-length($isbnNum) = 10  ) then
	            let $isbn12:= concat("978",substring($isbnNum,1,9))
	            let $odds:= number(substring($isbn12,1,1)) + number(substring($isbn12,3,1)) +number(substring($isbn12,5,1)) + number(substring($isbn12,7,1)) +number(substring($isbn12,9,1)) +number(substring($isbn12,11,1))
	            let $evens:= (number(substring($isbn12,2,1)) + number(substring($isbn12,4,1)) +number(substring($isbn12,6,1)) + number(substring($isbn12,8,1)) +number(substring($isbn12,10,1)) +number(substring($isbn12,12,1)) ) * 3      
	            let $chk:= if (  (($odds + $evens) mod 10) = 0)
        	                then 0 else 10 - (($odds + $evens) mod 10)
        
            return
                (<idx:identifier idtype="isbn">{$isbnNum}</idx:identifier>,
                 <idx:identifier idtype="isbn">{concat($isbn12,$chk)}</idx:identifier>      
                )
        else (: isbn13 to 10 :)

            let $isbn9:=substring($isbnNum,4,9) 
            
            let $sum:= (number(substring($isbn9,1,1)) * 1) 
                        + (number(substring($isbn9,2,1)) * 2)
                        + (number(substring($isbn9,3,1)) * 3)
                        + (number(substring($isbn9,4,1)) * 4) 
                        + (number(substring($isbn9,5,1)) * 5)
                        + (number(substring($isbn9,6,1)) * 6)
                        + (number(substring($isbn9,7,1)) * 7)
                        + (number(substring($isbn9,8,1)) * 8)
                        + (number(substring($isbn9,9,1)) * 9)
             
             let $check_dig:= if ( ($sum mod 11) = 10 ) then 'X'
                              else ($sum mod 11)
                              
            return
            (<idx:identifier idtype="isbn">{concat($isbn9,$check_dig)}</idx:identifier> ,
            <idx:identifier idtype="isbn">{$isbnNum}</idx:identifier>       
            )
    else (<idx:identifier idtype="isbn">error</idx:identifier>,<idx:identifier idtype="isbn">{$isbn}</idx:identifier>)
};
(:********************************** :)
declare function ldsindex:getIds($mods as element(), $uri as xs:string) as element(){

let $ids:=$mods/mods:identifier[@type][@type!="membership"][@type!="local"]
(: related item children are included, but see alsos are not :)
let $childids:=$mods//mods:relatedItem[@type="constituent"]/mods:identifier[@type][@type!="membership"][@type!="local"]
let $idSet:=
 for $id in ($ids,$childids)
   let $localname:= replace(string($id/@type),"\W+","") 
   order by $id/@type, string($id)
     return  
         if ($localname="isbn") then
            ldsindex:getIsbn(string($id))
         else
            if (matches($localname,"lccn") ) then                   
                    (<idx:identifier idtype="{$localname}">{string($id)}</idx:identifier>,<idx:lccn>{string($id)}</idx:lccn> )                               
            else 
            if (contains($localname,"issn") ) then                   
                    (<idx:identifier idtype="{$localname}">{string($id)}</idx:identifier>,<idx:issn>{string($id)}</idx:issn> )                               
            else 
            if (matches($localname,"[doi|hdl|isbn|isrc|stocknumber|upc]") ) then                    
                    <idx:identifier idtype="{$localname}">{string($id)}</idx:identifier>                                     
            else
				 <idx:identifier>{string($id)}</idx:identifier>

let $sets:=$mods//mods:identifier[ @type="membership" or @type="recordgroupID"]

(: need registered list of memberships and displayNames for all :)

let $memberships:=
 for $member in $sets
  order by string($member)
    return  
     element idx:memberCode {
      element idx:memberOf {string($member)},
      element idx:uri { concat("http://loccatalog.loc.gov/memberships/",replace(string($member),"\W+",""))}
     }
let $hosts:= for $member in $mods//mods:relatedItem[@type="host"]
				return 
					element idx:memberCode {
    				  element idx:memberOf {string($member/mods:titleInfo[@script="Latn" or not(@script)][1])},
      				  element idx:uri { concat("http://loccatalog.loc.gov/memberships/",replace(string($member),"\W+",""))}
     				}

let $objectid:=
    if (matches($uri,"^.+erms.+$")) then
		$uri
	else  if ($mods/mods:recordInfo/mods:recordContentSource[@authority="marcorg"]="DLC" or $mods/mods:recordInfo/mods:recordIdentfier[@source="DLC"]) 
     then
       concat("loc.natlib.lcdb.",$mods/mods:recordInfo/mods:recordIdentifier/string())
       else $mods/mods:recordInfo/mods:recordIdentifier/string()
         (:else add pae stuff here...:)
return
<idx:ids>
   {$idSet}
   <idx:identifier idtype="objectid">{$uri}</idx:identifier>
   {$memberships}
    <idx:memberCode>
      <idx:memberOf>catalog</idx:memberOf>
      <idx:uri>http://loccatalog.loc.gov/memberships/catalog</idx:uri>
    </idx:memberCode>
</idx:ids>

};
(: copied from mets-utils.xqy :)
declare function ldsindex:hold-bib($bibid as xs:integer, $set as xs:string)  {
(: given a bibid, get all holdings
   returns <collection><hld:r/><hld:r/></collection> or <error:error/> or ()
   $set is either erms or lcdb
:)
let $collection:=if ($set="lcdb") then "/lscoll/lcdb/holdings/" else"/lscoll/erms/holdings/"
let $holdings:=
	 try {
		cts:search(/hld:r, cts:and-query((cts:collection-query($collection), 
			cts:element-range-query(xs:QName("hld:c004"), "=", $bibid))))

	} 	catch($e) {
        	(xdmp:log(xdmp:quote($e)), ())
    }
return if ($holdings instance of element(error:error)) then
  		($holdings, xdmp:set-response-code(500, $holdings//error:message/string() ) )
  else 
  <collection  xmlns="http://www.indexdata.com/turbomarc">{$holdings}</collection>
};

declare function ldsindex:mods-to-idx ($mods as element(), $mxe as element()? , $uri as xs:string)  as element()  {  
(:
version 20120328: add uri to this call so we can better process it (esp for erms)
version 20120321: changed at the library Access facet to add cip and other stuff: In Process/Undetermined
version 20120316: fix holdings call to add erms, fix multiple classes in mods getlcc
version 20120315 : added auth terms and project name attributes to name, title, subjectLexicon,
					fixed getmarccountries
version 20120307 : added role to mods main creators as an attribute for hitlist 
version 20120207 : locations in mods: add 'division' to 'Asian' and 'manuscript' and 'European' esp for tohap
version 20120126 : filter 'U. S.' out of lcc valid stuff : http://marklogic3.loc.gov/loc.natlib.lcdb.11550384.index.xml
version 20120110 : added support for family, given for nksip 
version 20120106 : fix references to <mxe:record/>
version 20120104 : handle multiple languageTerms http://marklogic3.loc.gov/loc.natlib.lcwa0011.0037.index.xml
version 20111223 : fix idx:files (json) to work in utils:mets-files2 with $mets, so you can use
					a mets document from outside before storing it.
version 20111222 : fix idx:json
version 20111220 : added idx:name for any name search, not by or about
version 20111219 : fixed mods lcc computation, multiple titles and names (from nksip http://marklogic3.loc.gov/lscoll/detail.xqy?q=loc.natlib.asian.1003_13637)
version 20111214 : fixed punctuation,layout of idx:titlesort in ldsindex:getTitles added namespace to noindex (indexing updated today)
version 20111212 : added json files list for ia books speed-up.
version 20111201 : fix support for mods only (pubdates, empty pubplaces, test for empty/missing mxe )
version 20111110 : change gethitlist to test for <mxe:mxe/> before using mods version of function.
version 20111103 : change idx:lcclass to support building a link to the browse list for the right paned
                    so we don't need to call for holdings at that spot
version 20111101 : changes to locations and memberships
version 20111028 : add mods location
version 20111026 : improved mods mattype lookup for non-bib materials
version 20111025 : normalized space on languages http://marklogic3.loc.gov/loc.natlib.tohap.H0201.index.xml
version 20110930 : better deduping of pub places when there's a code and a text value (example?)
version 20110805 : fixed uniform title:  http://marklogic3.loc.gov/loc.natlib.lcdb.1791879.index.xml
version 20110725 : added loc1 for mods (digital content doesn't have holdings records 
version 20110715 : fixed getlcc to exclude invalid lcc's from lcclass and only get one valid lcc structure per doc
				 :  also, class prefixes like DA are now excluded (any alpha if they have a space after them)
version 20110708 : started adding idx:thumb, but it needs mets, so we need to write a module that does in-mem update or starts with an existing mets file
version 20110706 : dropped multiple lcc facets; multi-tier facets on multiple hits per doc work too hard, esp 3 layer, eating up list-cache
				 :  Only use multitier facets on "sort" type fields (one per doc)
version 20110622 : changed maincreator to include 880s, changed nameSort to be unique mainCreator for hitlist sort/display,
					fixed gYear funct
version 20110524 : holdings changes digitized, loc, and lcc (dropped hasLink)
version 20110509 : began faking in holdings
version 20110419? :
version 20110328 : add newspapers 008/21 to format facet
version 20110328 : add related item titles for series searches, improve pubdates and mattype for mods in ammem nonsort datasets
version 20110325 : add mods hitlist and idx:lccn for permalink
version 20110203 : fix to topic authorities regex, isbn, and 856 partial/full rules
version 20110202 : fix to pubdatesort so nulls are "undetermined" and sort to the end 
version 20110131 : fix to maincreator xml:lang and drop1xx $c 
version 20110118 : added lots to validlcc list after updating lcc.skos.rdf, esp in K** range

version 20110105:  moved this function into index-utils, fixes to subject browse set, removing 653
                also added locations and deduped them
                also fixed pubdatesort
:)
(:for files list (esp ia pages:)
let $uri:=if ($mods//mods:recordInfo[not(contains(mods:recordIdentifier, "lcdb"))]/mods:recordIdentifier/string() ) then
			$mods//mods:recordInfo[not(contains(mods:recordIdentifier, "lcdb"))]/mods:recordIdentifier/string() 
		else if (matches($mxe//mxe:datafield_035/mxe:d035_subfield_a/string(),"^\.b" ) ) then
			concat("loc.natlib.erms.",$mxe//mxe:datafield_035/mxe:d035_subfield_a/string() )
		else $mxe/mxe:controlfield_001/string()

let $holdings:= 
		if ( contains($uri,"erms") ) then 
			ldsindex:hold-bib(tokenize($uri,"\.")[last()]  cast as xs:integer, "erms")
	else  if ((  $mxe/*) and not(matches($mods//mods:recordIdentifier,'[a-zA-Z]') )) then 
			ldsindex:hold-bib($mxe//mxe:controlfield_001/string()  cast as xs:integer, "lcdb")
		else <hld:record/>
  let $digitized:= 		
		if ( not($mxe/*)  or empty($mxe) or not (exists($mxe) or $mxe=() )) then
			ldsindex:getModsDigitized($mods)/*
		else						
			ldsindex:getDigitized($mxe, $holdings)
    let $display:=     
        if ( not($mxe/*)  or empty($mxe) or not (exists($mxe) or string($mxe)='' )) then
           ldsindex:getModsHitlist($mods ) 
        else 
            ldsindex:getHitlist($mods,$mxe)

let $membership:=string-join(
							($mods//mods:identifier[@type='membership'],
				  			 $mods//mods:relatedItem[@type='host']/mods:identifer[@type='local'])
							,' ')
				  
(:let $files:=    
    if (matches(string-join($digitized, ' '),'Online')) then
  		    <idx:files format="json"><noindex xmlns="info:lc/xq-modules/noindex">{utils:mets-files($uri,"json","all")}</noindex></idx:files>			
  		else ()
    :)
	let $titles:= ldsindex:getTitles($mods, $membership)
    let $names:= ldsindex:getNames($mods, $membership) 
    let $aboutdates:=ldsindex:getAboutDates($mods)  
    let $facets := ldsindex:getFacets($mods)

	let $lcc:=ldsindex:get-lcc-facet($mods,$holdings)
	let $loc:=ldsindex:getLocations($mods,$holdings)
    let $ids:=ldsindex:getIds($mods, $uri)    
    let $topics:= ldsindex:getTopics($mods)
    let $notes:= ldsindex:getNotes($mods)
    let $places:= ldsindex:getPlaces($mods)

    let $obj:= ldsindex:getObjectType($mods, "bibRecord")
		
    return
        <idx:indexTerms version="20120328" xmlns:idx="info:lc/xq-modules/lcindex">
            {$display}
            {$titles}          
            {$names}            
            {$aboutdates}
            {$facets/*}
            {$ids/*}
            {$topics}
            {$notes}
            {$places}    
            {$digitized} 
			{$lcc}					
			{$loc}				
        </idx:indexTerms>
};