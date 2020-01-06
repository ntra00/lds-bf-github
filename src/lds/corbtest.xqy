xquery version "1.0-ml";

declare namespace idx = "info:lc/xq-modules/lcindex";
declare namespace mets = "http://www.loc.gov/METS/";

declare variable $URI as xs:string external;

(xdmp:node-delete(doc($URI)/mets:mets/mets:dmdSec[@ID='IDX1']/mets:mdWrap/mets:xmlData/idx:indexTerms/idx:lcc[position() > 1])(:, $URI:))