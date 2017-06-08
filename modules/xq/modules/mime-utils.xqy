xquery version "1.0-ml";

module namespace mime="info:lc/xq-modules/mime-utils";
declare namespace mlhttp="xdmp:http";
declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare namespace ead="urn:isbn:1-931666-22-9";
declare namespace marcxml="http://www.loc.gov/MARC21/slim";
declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace mxe="mxens";
declare namespace mets="http://www.loc.gov/METS/";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare function mime:safe-mime($inmime as xs:string) as xs:string {
    replace($inmime, ' ', '+', 'mi')
};

