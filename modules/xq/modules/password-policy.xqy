xquery version "1.0-ml";

module namespace pp = "info:lc/xq-modules/password-policy";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare variable $pp:SPECIALCHARS as xs:string := "`!&quot;?$%^&amp;*()_-+={[}]:;@'~#|\<,>./";
(: Password must be at least 8 characters long and include at least three of the following character types: uppercase letter, lower case letter, numeral, special character. :)

declare function pp:check-password($password as xs:string) as xs:boolean {
    if (string-length($password) ge 8) then
        let $seq := for $ch in string-to-codepoints($password) return codepoints-to-string($ch)
        let $all := for $c in $seq return pp:character-regex-check($c)
        let $distinct := distinct-values($all)
        let $dstr := string-join($distinct, " ")
        return
            if (contains($dstr, "Error")) then
                false()
            else if (count($distinct) lt 3) then
                false()
            else if (count($distinct) eq 3 and not(contains($dstr, "Error"))) then
                true()
            else
                false()
    else
        false()
};

declare function pp:character-regex-check($char as xs:string) as xs:string {
    if (matches($char, "[a-z]")) then
        "lowercase"
    else if (matches($char, "[A-Z]")) then
        "uppercase"
    else if (matches($char, "[0-9]")) then
        "digit"
    else if (contains($pp:SPECIALCHARS, $char)) then
        "special"
    else
        "Error"
};
