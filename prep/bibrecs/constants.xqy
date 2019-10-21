xquery version "1.0";

(:
:   Module Name: Application Constants
:
:   Module Version: 1.0
:
:   Date: 2011 Jan 04
:
:   Copyright: Public Domain
:
:   Proprietary XQuery Extensions Used: xdmp (MarkLogic)
:
:   Xquery Specification: January 2007
:
:   Module Overview:    Application constants.
:       No functions, just variables.
:
:)
   
(:~
:   Application constants.
:   No functions, just vars.
:
:   @author Kevin Ford (kefo@loc.gov)
:   @since January 04, 2011
:   @version 1.0
:)

module namespace constants = 'info:lc/id-modules/constants#'; 

(:~
:   This is the Base App URL - how are the below two used these days?
:)
declare variable $constants:BASE_APP_URL as xs:string := "http://mlvlp04.loc.gov:8081/";

(:~
:   This is the production URL
:)
(:declare variable $constants:BASE_APP_URL_PROD as xs:string := "http://id.loc.gov/";:)
declare variable $constants:BASE_APP_URL_PROD as xs:string := "http://idwebvlp03.loc.gov/";
(:~
:   This is the Base CoverArt URL
:   If off-site, use: http://lcweb2.loc.gov/diglib/media/
	http://loccatalog.loc.gov/nlc/
:)
declare variable $constants:BASE_COVERART_URL as xs:string := "http://marklogic4.loc.gov/media/";
(:~
:   This is the Base Resources URL
:   If off-site, use: http://lcweb2.loc.gov/diglib/lcds/
:)
declare variable $constants:BASE_RESOURCES_URL as xs:string := "http://mlvlp04.loc.gov:8230/";
(:~
:   This is the bib2lccn service URL
:)

declare variable $constants:BASE_BIB2LCCN_URL as xs:string := "http://mlvlp04.loc.gov:8230/convert/";

(:~
:   This is the Base URL for SRU searches
:)
declare variable $constants:BASE_OPAC_SRU_URL as xs:string := "http://lx2.loc.gov:210/";
(:~
:   This is the Base URL for bibframe 2 test searches
:)
declare variable $constants:BASE_TEST_SRU_URL as xs:string := "http://bibframe.indexdata.com/";
(:~
:   This is the Base URL for bibframe 2 staging searches (at indexdata, this could be http://bibframe.indexdata.com/ )
:)
declare variable $constants:BASE_DEV_SRU_URL as xs:string := "http://mprxyvls02.loc.gov:210/";
(:~
:   This is the Base URL for bibframe 2 staging  searches
:)
declare variable $constants:BASE_STAGING_SRU_URL as xs:string := "//mprxyvls01.loc.gov:210/";


(:~
:   This variable is used by the app to determine whether it is
:   undergoing maintenance or not.
:)
declare variable $constants:UNDERMAINTENANCE as xs:boolean := fn:false();

(:~
:   This variable is used by the app to determine whether it is
:   in production or development.
:)
declare variable $constants:DEBUG as xs:boolean := fn:true();

(:~
:   This variable is for email addresses of those who should be notified
:   in the event of an error.
:)
declare variable $constants:EMAIL_FROM as element() := 
    <addresses>
        <to email="id@loc.gov">The ID.LOC.GOV website</to>
    </addresses>;
    
(:~
:   This variable is for email addresses of those who should be notified
:   whenever someone fills out the general contact form or suggest
:   terminology form.
:)
declare variable $constants:EMAIL_TO as element() := 
    <addresses>
        <to email="ntra@loc.gov">Nate Trail</to>
		<to email="qtong@loc.gov">Qi Tong</to>
		<to email="khes@loc.gov">Kirk Hess</to>
    </addresses>;
    
(:~
:   This variable is for email addresses of those who should be notified
:   in the event of an error.
:)
declare variable $constants:ERROR_NOTIFY as element() := 
    <addresses>
        <to email="ntra@loc.gov">Nate Trail</to>
		<to email="qtong@loc.gov">Qi Tong</to>
		<to email="khes@loc.gov">Kirk Hess</to>
    </addresses>;

(:~
:   This variable is used by the app to determine whether RDF 
:   relation matching should be based on index:relation
:   or a triple store.  If true, the relevant functions are
:   in SearchML.xqy
:)
declare variable $constants:USE_TS as xs:boolean := fn:true();

(:~
:   For ML, root ID-TS App location
:)
declare variable $constants:SPARQL_SERVICE as xs:string := "http://localhost:8085/v1/graphs/sparql";

(:~
:   Filesystem downloads directory location
:)
declare variable $constants:DOWNLOADS_DIR as xs:string := "/marklogic/id/lds-id/src/static/data";

(:~
:   This variable is for cache control aging; currently 14 days, was 604800 (7 days).
:	Names could change daily but are flushed and reloaded. Subjects could change weekly 
:	so they should be flushed and reloaded too.
:
:)
declare variable $constants:CACHE-CONTROL as xs:string := "public, max-age=1209600";  

declare variable $constants:NSMAP as element() := 
    <nsmaps>
        <nsmap test="http://www.loc.gov/mads/rdf/v1" display="MADS/RDF">madsrdf</nsmap>
        <nsmap test="http://id.loc.gov/ontologies/lcc" display="LCC">lcc</nsmap>
        <nsmap test="http://www.w3.org/2004/02/skos/core" display="SKOS">skos</nsmap>
        <nsmap test="http://www.w3.org/2008/05/skos-xl" display="SKOSXL">skosxl</nsmap>
        <nsmap test="http://www.w3.org/1999/02/22-rdf-syntax-ns" display="RDF">rdf</nsmap>
        <nsmap test="http://www.w3.org/2000/01/rdf-schema" display="RDFS">rdfs</nsmap>
        <nsmap test="http://purl.org/dc/terms/" display="DCTERMS">dcterms</nsmap>
        <nsmap test="http://www.w3.org/2002/07/owl" display="OWL">owl</nsmap>
        <nsmap test="http://purl.org/vocab/changeset/schema" display="CS">cs</nsmap>
        <nsmap test="http://www.w3.org/2003/06/sw-vocab-status/ns" display="VS">vs</nsmap>
        <nsmap test="http://id.loc.gov/vocabulary/iso639-1/" display="ISO6391">iso6391</nsmap>
        <nsmap test="http://id.loc.gov/vocabulary/iso639-2/" display="ISO6392">iso6392</nsmap>
        <nsmap test="http://id.loc.gov/vocabulary/iso639-5/" display="ISO6395">iso6395</nsmap>
        <nsmap test="http://id.loc.gov/vocabulary/languages/" display="MARC">languages</nsmap>
        <nsmap test="http://id.loc.gov/vocabulary/countries/" display="MARC">countries</nsmap>
        <nsmap test="http://id.loc.gov/vocabulary/geographicAreas/" display="MARC">gacs</nsmap>
        <nsmap test="http://id.loc.gov/vocabulary/relators/" display="MARC">relators</nsmap>
        <nsmap test="http://id.loc.gov/vocabulary/classSchemes/" display="MARC">classchemes</nsmap>
        <nsmap test="http://id.loc.gov/vocabulary/subjectSchemes/" display="MARC">subjectschemes</nsmap>
		<nsmap test="http://id.loc.gov/vocabulary/genreFormSchemes/" display="MARC">genreformschemes</nsmap>
		<nsmap test="http://id.loc.gov/vocabulary/performanceMediums/" display="MARC">performancemediums</nsmap>
		<nsmap test="http://id.loc.gov/vocabulary/resourceComponents/" display="MARC">resourceComponents</nsmap>
        <nsmap test="http://id.loc.gov/vocabulary/targetAudiences/" display="MARC">audiences</nsmap>
        <nsmap test="http://id.loc.gov/vocabulary/descriptionConventions/" display="MARC">descriptionconventions</nsmap>
        <nsmap test="http://id.loc.gov/vocabulary/resourceTypes/" display="MARC">resourcetypes</nsmap>
        <nsmap test="http://id.loc.gov/vocabulary/identifiers/" display="MARC">identifiers</nsmap>
        <nsmap test="http://www.w3.org/2001/XMLSchema" display="XSD">xsd</nsmap>
        <nsmap test="http://www.loc.gov/premis/rdf/v1" display="PREMIS">premis</nsmap>
        <nsmap test="http://xmlns.com/foaf/0.1/" display="FOAF">foaf</nsmap>
        <nsmap test="http://www.openarchives.org/ore/terms/" display="ORE">ore</nsmap>        
        <nsmap test="http://bibframe.org/vocab/" display="bibframe">bibframe</nsmap>
        <nsmap test="http://id.loc.gov/resources" display="bibframe">bibframe Resources</nsmap>
        <nsmap test="http://id.loc.gov/authorities/demographicTerms/" display="MARC">demographicterms</nsmap>
        <nsmap test="http://id.loc.gov/vocabulary/ethnographicTerms/" display="MARC">ethnographicterms</nsmap>
 <!--       <nsmap test="http://id.loc.gov/vocabulary/preservation/rightsRelatedAgentRole" display="rightsRelatedAgentRole">rightsRelatedAgentRole</nsmap> -->
        <nsmap test="http://id.loc.gov/vocabulary/marcgt" display="MARC">genreterms</nsmap>
		<nsmap test="http://id.loc.gov/ontologies/bibframe/" display="BF">bf2</nsmap>
		<nsmap test="http://id.loc.gov/ontologies/bflc/" display="BF">bflc</nsmap>
    </nsmaps>;


(:~
:   This variable records all the MADS Schemes in the system and 
:   relevant information pertaining to accessing them and their
:   display.
:)
declare variable $constants:SCHEMES as element() :=
    <schemes>
        <scheme 
            uri="http://id.loc.gov/authorities/subjects" 
            relativeURI="/authorities/subjects"
            abbrev="subjects"
            abbrevName="LC Subject Headings"
            fullName="Library of Congress Subject Headings">
            <description><p></p>
                <!--
                <p>Library of Congress Subject Headings (LCSH) has been actively 
                maintained since 1898 to catalog materials held at the Library of 
                Congress. By virtue of cooperative cataloging other libraries around 
                the United States also use LCSH to provide subject access to their 
                collections. In addition LCSH is used internationally, often in translation. 
                LCSH in this service includes all Library of Congress Subject Headings, 
                free-floating subdivisions (topical and form), Genre/Form headings, 
                Children's (AC) headings, and validation strings* for which authority 
                records have been created. The content includes a few name headings 
                (personal and corporate), such as William Shakespeare, Jesus Christ, and 
                Harvard University, and geographic headings that are added to LCSH as they 
                are needed to establish subdivisions, provide a pattern for subdivision 
                practice, or provide reference structure for other terms. This content is 
                expanded beyond the print issue of LCSH (the "red books") with inclusion 
                of validation strings.</p>
                <p>*Validation strings: Some authority records are for headings that have 
                been built by adding subdivisions. These records are the result of an 
                ongoing project to programmatically create authority records for valid 
                subject strings from subject heading strings found in bibliographic records. 
                The authority records for these subject strings were created so the entire 
                string could be machine-validated. The strings do not have broader, 
                narrower, or related terms.</p>
                -->
            </description>
        </scheme>
        <scheme 
            uri="http://id.loc.gov/authorities/names" 
            relativeURI="/authorities/names"
            abbrev="names"
            abbrevName="LC Name Authority File"
            fullName="Library of Congress Name Authority File">
            <description><p></p>
            </description>
        </scheme>
        <scheme 
            uri="http://id.loc.gov/authorities/classification" 
            relativeURI="/authorities/classification"
            abbrev="classification"
            abbrevName="LC Classification"
            fullName="Library of Congress Classification">
            <description><p></p>
            </description>
        </scheme>
        <scheme 
            uri="http://id.loc.gov/authorities/childrensSubjects" 
            relativeURI="/authorities/childrensSubjects"
            abbrev="childrensSubjects"
            abbrevName="LC Children's Subject Headings"
            fullName="Library of Congress Children's Subject Headings">
            <description><p></p>
            </description>
        </scheme>
        <scheme 
            uri="http://id.loc.gov/authorities/genreForms" 
            relativeURI="/authorities/genreForms"
            abbrev="genreForms"
            abbrevName="LC Genre/Form Terms"
            fullName="Library of Congress Genre/Form Terms">
            <description><p></p>
            </description>
        </scheme>
        <scheme 
            uri="http://id.loc.gov/authorities/performanceMediums" 
            relativeURI="/authorities/performanceMediums"
            abbrev="performanceMediums"
            abbrevName="LC Medium of Performance Thesaurus for Music"
            fullName="Library of Congress Medium of Performance Thesaurus for Music">
            <description><p></p>
            </description>
        </scheme>
       <scheme 
            uri="http://id.loc.gov/authorities/demographicTerms" 
            relativeURI="/authorities/demographicTerms"
            abbrev="demographicTerms"
            abbrevName="LC Demographic Group Terms"
            fullName="Library of Congress Demographic Group Terms">
            <description><p></p>
            </description>
        </scheme> 
        <scheme 
            uri="http://id.loc.gov/vocabulary/graphicMaterials" 
            relativeURI="/vocabulary/graphicMaterials"
            abbrev="graphicMaterials"
            abbrevName="Thesaurus for Graphic Materials"
            fullName="Thesaurus for Graphic Materials">
            <description><p></p>
            </description>
        </scheme>
        <scheme 
            uri="http://id.loc.gov/vocabulary/ethnographicTerms" 
            relativeURI="/vocabulary/ethnographicTerms"
            abbrev="ethnographicTerms"
            abbrevName="AFS Ethnographic Thesaurus"
            fullName="AFS Ethnographic Thesaurus">
            <description><p></p>
            </description>
        </scheme>
        <scheme 
            uri="http://id.loc.gov/vocabulary/organizations" 
            relativeURI="/vocabulary/organizations"
            abbrev="organizations"
            abbrevName="Cultural Heritage Organizations"
            fullName="Cultural Heritage Organizations">
            <description><p></p>
            </description>
        </scheme>
         <!-- space needed? column 2 starts here:
         -->             
        <scheme 
            uri="http://id.loc.gov/vocabulary/relators" 
            relativeURI="/vocabulary/relators"
            abbrev="relators"
            abbrevName="MARC Relators"
            fullName="MARC List of Relator Terms">
            <description><p></p>
            </description>
        </scheme>
        <scheme 
            uri="http://id.loc.gov/vocabulary/countries" 
            relativeURI="/vocabulary/countries"
            abbrev="countries"
            abbrevName="MARC Countries"
            fullName="MARC List of Countries">
            <description><p></p>
            </description>
        </scheme>
        <scheme 
            uri="http://id.loc.gov/vocabulary/geographicAreas" 
            relativeURI="/vocabulary/geographicAreas"
            abbrev="geographicAreas"
            abbrevName="MARC Geographic Areas"
            fullName="MARC List of Geographic Areas">
            <description><p></p>
            </description>
        </scheme>
        <scheme 
            uri="http://id.loc.gov/vocabulary/languages" 
            relativeURI="/vocabulary/languages"
            abbrev="languages"
            abbrevName="MARC Languages"
            fullName="MARC List of Languages">
            <description><p></p>
            </description>
        </scheme>
        <scheme 
            uri="http://id.loc.gov/vocabulary/iso639-1" 
            relativeURI="/vocabulary/iso639-1"
            abbrev="iso639-1"
            abbrevName="ISO639-1 Languages"
            fullName="ISO 639-1: Codes for the Representation of Names of Languages - Part 1: Two-letter codes for languages">
            <description><p></p>
            </description>
        </scheme>
        <scheme 
            uri="http://id.loc.gov/vocabulary/iso639-2" 
            relativeURI="/vocabulary/iso639-2"
            abbrev="iso639-2"
            abbrevName="ISO639-2 Languages"
            fullName="ISO 639-2: Codes for the Representation of Names of Languages - Part 2: Alpha-3 Code for the Names of Languages">
            <description><p></p>
            </description>
        </scheme>
        <scheme 
            uri="http://id.loc.gov/vocabulary/iso639-5" 
            relativeURI="/vocabulary/iso639-5"
            abbrev="iso639-5"
            abbrevName="ISO639-5 Languages"
            fullName="ISO 639-5 Codes for the Representation of Names of Languages - Part 5: Alpha-3 Code for Language Families and Groups">
            <description><p></p>
            </description>
        </scheme>
        <scheme 
            uri="http://id.loc.gov/datatypes/edtf" 
            relativeURI="/datatypes/edtf"
            abbrev="edtf"
            abbrevName="Extended Date/Time Format"
            fullName="Extended Date/Time Format">
            <description><p></p>
            </description>
        </scheme>
         <!-- space needed? column 3 starts here: -->
         <scheme 
            uri="http://id.loc.gov/vocabulary/identifiers" 
            relativeURI="/vocabulary/identifiers"
            abbrev="identifiers"
            abbrevName="Identifiers"
            size="small"
            fullName="Standard Identifiers">
            <description><p></p>
            </description>
        </scheme>
         <scheme 
            uri="http://id.loc.gov/vocabulary/carriers" 
            relativeURI="/vocabulary/carriers"
            abbrev="carriers"
            abbrevName="Carriers"
            size="small"
            fullName="Carriers">
            <description><p></p>
            </description>
        </scheme>
		
         <scheme 
            uri="http://id.loc.gov/vocabulary/contentTypes" 
            relativeURI="/vocabulary/contentTypes"
            abbrev="contentTypes"
            abbrevName="Content Types"
            size="small"
            fullName="Content Types">
            <description><p></p>
            </description>
        </scheme>
         <scheme 
            uri="http://id.loc.gov/vocabulary/mediaTypes" 
            relativeURI="/vocabulary/mediaTypes"
            abbrev="mediaTypes"
            abbrevName="Media Types"
            size="small"
            fullName="Media Types">
            <description><p></p>
            </description>
        </scheme>
		 <scheme 
            uri="http://id.loc.gov/vocabulary/resourceTypes" 
            relativeURI="/vocabulary/resourceTypes"
            abbrev="resourceTypes"
            abbrevName="Resource Types"
            size="small"
            fullName="Resource Types">
            <description><p></p>
            </description>
        </scheme>
		<scheme 
            uri="http://id.loc.gov/vocabulary/genreFormSchemes" 
            relativeURI="/vocabulary/genreFormSchemes"
            abbrev="genreFormSchemes"
            abbrevName="MARC Genre/Form Schemes"
            size="small"
            fullName="MARC List of Genre/Form Schemes">
            <description><p></p>
            </description>
        </scheme>
       <scheme 
            uri="http://id.loc.gov/vocabulary/subjectSchemes" 
            relativeURI="/vocabulary/subjectSchemes"
            abbrev="subjectSchemes"
            abbrevName="MARC Subject Schemes"
            size="small"
            fullName="MARC List of Subject Schemes">
            <description><p></p>
            </description>
			</scheme>
       <scheme 
            uri="http://id.loc.gov/vocabulary/classSchemes" 
            relativeURI="/vocabulary/classSchemes"
            abbrev="classSchemes"
            abbrevName="Classification Schemes"
            size="small"
            fullName="List of Classification Schemes">
            <description><p></p>
            </description>
			</scheme>
       <scheme 
            uri="http://id.loc.gov/vocabulary/descriptionConventions" 
            relativeURI="/vocabulary/descriptionConventions"
            abbrev="descriptionConventions"
            abbrevName="Description Convention"
            size="small"
            fullName="List of Description Convention">
            <description><p></p>
            </description>
        </scheme>
		<scheme 
            uri="http://id.loc.gov/vocabulary/frequencies" 
            relativeURI="/vocabulary/frequencies"
            abbrev="frequencies"
            abbrevName="Publication Frequencies"
            size="small"
            fullName="List of Publication Frequencies">
            <description><p></p>
            </description>
        </scheme>
<scheme 
            uri="http://id.loc.gov/vocabulary/resourceComponents" 
            relativeURI="/vocabulary/resourceComponents"
            abbrev="resourceComponents"
            abbrevName="Resource Components"
            size="small"
            fullName="List of Resource Components">
            <description><p></p>
            </description>
        </scheme>
<scheme 
            uri="http://id.loc.gov/ontologies/bibframe/" 
            relativeURI="/ontologies/bibframe"
            abbrev="bibframe"
            abbrevName="BIBFRAME Ontology"
			size="small"
            fullName="Library of Congress BIBFRAME Ontology">
            <description>
			<p>Initiated by the Library of Congress, BIBFRAME provides a foundation for the future of bibliographic description, both on the web, and in the broader networked world. This site presents general information about the project, including presentations, FAQs, and links to working documents. In addition to being a replacement for MARC, BIBFRAME serves as a general model for expressing and connecting bibliographic data. A major focus of the initiative will be to determine a transition path for the MARC 21 formats while preserving a robust data exchange that has supported resource sharing and cataloging cost savings in recent decades.</p>
            </description>
        </scheme>
        <scheme 
            uri="http://id.loc.gov/vocabulary/marcgt" 
            relativeURI="/vocabulary/marcgt"
            abbrev="genreTerms" 
            abbrevName="MARC Genre Terms"
            fullName="MARC Genre Terms List">
            <description><p></p>
            </description>
        </scheme>
 		<scheme 
            uri="http://id.loc.gov/vocabulary/mcolor" 
            relativeURI="/vocabulary/mcolor"
            abbrev="color"
            abbrevName="MARC Color Content"
            size="small"
            fullName="MARC Color Content List">
            <description><p></p>
            </description>
        </scheme>
 		<scheme 
            uri="http://id.loc.gov/vocabulary/mpolarity" 
            relativeURI="/vocabulary/mpolarity"
            abbrev="polarity"
            abbrevName="MARC Polarity"
            size="small"
            fullName="MARC Polarity List">
            <description><p></p>
            </description>
        </scheme>
 		<scheme 
            uri="http://id.loc.gov/vocabulary/mplayback" 
            relativeURI="/vocabulary/mplayback"
            abbrev="playBack"
            abbrevName="MARC Playback Channels"
            size="small"
            fullName="MARC Playback Channels List">
            <description><p></p>
            </description>
        </scheme>
 		<scheme 
            uri="http://id.loc.gov/vocabulary/millus" 
            relativeURI="/vocabulary/millus"
            abbrev="illustrativeContent"
            abbrevName="MARC Illustrative Content"
            size="small"
            fullName="MARC Illustrative Content List">
            <description><p></p>
            </description>
        </scheme>
 		<scheme 
            uri="http://id.loc.gov/vocabulary/issuance" 
            relativeURI="/vocabulary/issuance"
            abbrev="issuance"
            abbrevName="MARC Issuance"
            size="small"
            fullName="MARC Issuance List">
            <description><p></p>
            </description>
        </scheme>
 		<scheme 
            uri="http://id.loc.gov/vocabulary/maudience" 
            relativeURI="/vocabulary/maudience"
            abbrev="audience"
            abbrevName="MARC Intended Audience"
            size="small"
            fullName="MARC Intended Audience List">
            <description><p></p>
            </description>
        </scheme>
 		<scheme 
            uri="http://id.loc.gov/vocabulary/mmaterial" 
            relativeURI="/vocabulary/mmaterial"
            abbrev="material"
            abbrevName="MARC Support Material"
            size="small"
            fullName="MARC Support Material List">
            <description><p></p>
            </description>
        </scheme>
 		<scheme 
            uri="http://id.loc.gov/vocabulary/marcauthen" 
            relativeURI="/vocabulary/marcauthen"
            abbrev="authentication"
            abbrevName="MARC Authentication Action"
            size="small"
            fullName="MARC Authentication Action List">
            <description><p></p>
            </description>
        </scheme>
 		<scheme 
            uri="http://id.loc.gov/vocabulary/menclvl" 
            relativeURI="/vocabulary/menclvl"
            abbrev="encoding"
            abbrevName="MARC Encoding Level"
            size="small"
            fullName="MARC Encoding Level List">
            <description><p></p>
            </description>
        </scheme>
 		<scheme 
            uri="http://id.loc.gov/vocabulary/maspect" 
            relativeURI="/vocabulary/maspect"
            abbrev="aspect"
            abbrevName="MARC Aspect Ratio Level"
            size="small"
            fullName="MARC Aspect Ratio List">
            <description><p></p>
            </description>
        </scheme>
  		<scheme 
            uri="http://id.loc.gov/vocabulary/mfiletype" 
            relativeURI="/vocabulary/mfiletype"
            abbrev="filetype"
            abbrevName="MARC File Type"
            size="small"
            fullName="MARC File Type List">
            <description><p></p>
            </description>
        </scheme>
  		<scheme 
            uri="http://id.loc.gov/vocabulary/mgeneration" 
            relativeURI="/vocabulary/mgeneration"
            abbrev="generation"
            abbrevName="MARC Generation"
            size="small"
            fullName="MARC Generation List">
            <description><p></p>
            </description>
        </scheme>
  		<scheme 
            uri="http://id.loc.gov/vocabulary/mgroove" 
            relativeURI="/vocabulary/mgroove"
            abbrev="groove"
            abbrevName="MARC Groove Width/Pitch/Cutting Level"
            size="small"
            fullName="MARC Groove Width/Pitch/Cutting List">
            <description><p></p>
            </description>
        </scheme>
  		<scheme 
            uri="http://id.loc.gov/vocabulary/mmusnotation" 
            relativeURI="/vocabulary/mmusnotation"
            abbrev="mmusnotation"
            abbrevName="MARC Music Notation"
            size="small"
            fullName="MARC Music Notation List">
            <description><p></p>
            </description>
        </scheme>
  		<scheme 
            uri="http://id.loc.gov/vocabulary/mproduction" 
            relativeURI="/vocabulary/mproduction"
            abbrev="mproduction"
            abbrevName="MARC Production Method Level"
            size="small"
            fullName="MARC Production Method List">
            <description><p></p>
            </description>
        </scheme>
  		<scheme 
            uri="http://id.loc.gov/vocabulary/mrecmedium" 
            relativeURI="/vocabulary/mrecmedium"
            abbrev="mrecmedium"
            abbrevName="MARC Recording Medium "
            size="small"
            fullName="MARC Recording Medium List">
            <description><p></p>
            </description>
        </scheme>
  		<scheme 
            uri="http://id.loc.gov/vocabulary/mspecplayback" 
            relativeURI="/vocabulary/mspecplayback"
            abbrev="mspecplayback"
            abbrevName="MARC Special Playback Characeristics "
            size="small"
            fullName="MARC Special Playback Characeristics List">
            <description><p></p>
            </description>
        </scheme>
  		<scheme 
            uri="http://id.loc.gov/vocabulary/mrectype" 
            relativeURI="/vocabulary/mrectype"
            abbrev="mrectype"
            abbrevName="MARC Recording Type "
            size="small"
            fullName="MARC Recording Type List">
            <description><p></p>
            </description>
        </scheme>
  		<scheme 
            uri="http://id.loc.gov/vocabulary/mlayout" 
            relativeURI="/vocabulary/mlayout"
            abbrev="mlayout"
            abbrevName="MARC Layout "
            size="small"
            fullName="MARC Layout List">
            <description><p></p>
            </description>
        </scheme>
  		<scheme 
            uri="http://id.loc.gov/vocabulary/msoundcontent" 
            relativeURI="/vocabulary/msoundcontent"
            abbrev="msoundcontent"
            abbrevName="MARC Sound Content"
            size="small"
            fullName="MARC Sound Content List">
            <description><p></p>
            </description>
        </scheme>
  		<scheme 
            uri="http://id.loc.gov/vocabulary/mstatus" 
            relativeURI="/vocabulary/mstatus"
            abbrev="mstatus"
            abbrevName="MARC Identifier Status"
            size="small"
            fullName="MARC Identifier Status List">
            <description><p></p>
            </description>
        </scheme>
  		<scheme 
            uri="http://id.loc.gov/vocabulary/mmusicformat" 
            relativeURI="/vocabulary/mmusicformat"
            abbrev="mmusicformat"
            abbrevName="MARC Notated Music Form"
            size="small"
            fullName="MARC Notated Music Form List">
            <description><p></p>
            </description>
        </scheme>
  		<scheme 
            uri="http://id.loc.gov/vocabulary/mbroadstd" 
            relativeURI="/vocabulary/mbroadstd"
            abbrev="mbroadstd"
            abbrevName="MARC Broadcast Standard "
            size="small"
            fullName="MARC Broadcast Standard  List">
            <description><p></p>
            </description>
        </scheme>
  		<scheme 
            uri="http://id.loc.gov/vocabulary/mregencoding" 
            relativeURI="/vocabulary/mregencoding"
            abbrev="mregencoding"
            abbrevName="MARC Regional Encoding"
            size="small"
            fullName="MARC Regional Encoding List">
            <description><p></p>
            </description>
        </scheme>
  		<scheme 
            uri="http://id.loc.gov/vocabulary/mvidformat" 
            relativeURI="/vocabulary/mvidformat"
            abbrev="mvidformat"
            abbrevName="MARC Video Format"
            size="small"
            fullName="MARC Video Format List">
            <description><p></p>
            </description>
        </scheme>
  		<scheme 
            uri="http://id.loc.gov/vocabulary/mtechnique" 
            relativeURI="/vocabulary/mtechnique"
            abbrev="mtechnique"
            abbrevName="MARC MARC Technique"
            size="small"
            fullName="MARC MARC Technique List">
            <description><p></p>
            </description>
        </scheme>
    </schemes>;    
(:~
:   This variable records all the MADS Schemes in the system and 
:   relevant information pertaining to accessing them and their
:   display **for the Preservation/PREMIS vocabs.**
:)
declare variable $constants:PRESERVATION_SCHEMES as element() :=
    <schemes>
    <!-- space -->
        <scheme 
            uri="http://id.loc.gov/vocabulary/preservation" 
            relativeURI="/vocabulary/preservation"
            abbrev="preservation"
            abbrevName="Preservation Vocabs (all)"
            fullName="Preservation Vocabs (all)">
            <description><p></p></description>
        </scheme>
        <scheme 
            uri="http://id.loc.gov/vocabulary/preservation/actionsGranted" 
            relativeURI="/vocabulary/preservation/actionsGranted"
            abbrev="actionsGranted"
            abbrevName="Actions Granted"
            fullName="Actions Granted">
            <description><p></p></description>
        </scheme>
        <scheme 
            uri="http://id.loc.gov/vocabulary/preservation/agentType" 
            relativeURI="/vocabulary/preservation/agentType"
            abbrev="agentType"
            abbrevName="Agent Type"
            fullName="Agent Type">
            <description><p></p></description>
        </scheme>       
        <scheme uri="http://id.loc.gov/vocabulary/preservation/contentLocationType"
            relativeURI="/vocabulary/preservation/contentLocationType"
            abbrev="contentLocationType" abbrevName="Content Location Type"
            fullName="Content Location Type">
            <description><p></p></description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/preservation/copyrightStatus"
            relativeURI="/vocabulary/preservation/copyrightStatus"
            abbrev="copyrightStatus" abbrevName="Copyright Status"
            fullName="Copyright Status">
            <description><p></p></description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/preservation/cryptographicHashFunctions" 
            relativeURI="/vocabulary/preservation/cryptographicHashFunctions" 
                abbrev="cryptographicHashFunctions" abbrevName="Cryptographic Hash Functions" 
            fullName="Cryptographic Hash Functions">
            <description><p></p></description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/preservation/environmentCharacteristic"
            relativeURI="/vocabulary/preservation/environmentCharacteristic"
            abbrev="environmentCharacteristic"
            abbrevName="Environment Characteristic"
            fullName="Environment Characteristic">
            <description><p></p></description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/preservation/environmentFunctionType"
            relativeURI="/vocabulary/preservation/environmentFunctionType"
            abbrev="environmentFunctionType"
            abbrevName="Environment Function Type"
            fullName="Environment Function Type">
            <description><p></p></description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/preservation/environmentPurpose"
            relativeURI="/vocabulary/preservation/environmentPurpose"
            abbrev="environmentPurpose" abbrevName="Environment Purpose"
            fullName="Environment Purpose">
            <description><p></p></description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/preservation/environmentRegistryRole"
            relativeURI="/vocabulary/preservation/environmentRegistryRole"
            abbrev="environmentRegistryRole" abbrevName="Environment Registry Role"
            fullName="Environment Registry Role">
            <description><p></p></description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/preservation/eventRelatedAgentRole"
            relativeURI="/vocabulary/preservation/eventRelatedAgentRole"
            abbrev="eventRelatedAgentRole" abbrevName="Event Related Agent Role"
            fullName="Event Related Agent Role">
            <description><p></p></description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/preservation/eventRelatedObjectRole"
            relativeURI="/vocabulary/preservation/eventRelatedObjectRole"
            abbrev="eventRelatedObjectRole" abbrevName="Event Related Object Role"
            fullName="Event Related Object Role">
            <description><p></p></description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/preservation/eventType"
            relativeURI="/vocabulary/preservation/eventType"
            abbrev="eventType" abbrevName="Event Type"
            fullName="Event Type">
            <description><p></p></description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/preservation/formatRegistryRole"
            relativeURI="/vocabulary/preservation/formatRegistryRole"
            abbrev="formatRegistryRole" abbrevName="Format Registry Role"
            fullName="Format Registry Role">
            <description><p></p></description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/preservation/hardwareType"
            relativeURI="/vocabulary/preservation/hardwareType"
            abbrev="hardwareType" abbrevName="Hardware Type"
            fullName="Hardware Type">
            <description><p></p></description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/preservation/inhibitorTarget"
            relativeURI="/vocabulary/preservation/inhibitorTarget"
            abbrev="inhibitorTarget" abbrevName="Inhibitor Target"
            fullName="Inhibitor Target">
            <description><p></p></description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/preservation/inhibitorType"
            relativeURI="/vocabulary/preservation/inhibitorType"
            abbrev="inhibitorType" abbrevName="Inhibitor Type"
            fullName="Inhibitor Type">
            <description><p></p></description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/preservation/linkingAgentRoleEvent"
            relativeURI="/vocabulary/preservation/linkingAgentRoleEvent"
            abbrev="linkingAgentRoleEvent" 
            abbrevName="linking Agent Role Event"
            fullName="linking Agent Role Event">
            <description><p></p></description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/preservation/linkingEnvironmentRole"
            relativeURI="/vocabulary/preservation/linkingEnvironmentRole"
            abbrev="linkingEnvironmentRole" 
            abbrevName="Linking Environment Role"
            fullName="Linking Environment Role">
            <description><p></p></description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/preservation/objectCategory"
            relativeURI="/vocabulary/preservation/objectCategory"
            abbrev="objectCategory" abbrevName="Object Category"
            fullName="Object Category">
            <description><p></p></description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/preservation/preservationLevelRole"
            relativeURI="/vocabulary/preservation/preservationLevelRole"
            abbrev="preservationLevelRole" abbrevName="Preservation Level Role"
            fullName="Preservation Level Role">
            <description><p></p></description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/preservation/relationshipSubType"
            relativeURI="/vocabulary/preservation/relationshipSubType"
            abbrev="relationshipSubType" abbrevName="Relationship SubType"
            fullName="Relationship SubType">
            <description><p></p></description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/preservation/relationshipType"
            relativeURI="/vocabulary/preservation/relationshipType"
            abbrev="relationshipType" abbrevName="Relationship Type"
            fullName="Relationship Type">
            <description><p></p></description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/preservation/rightsBasis"
            relativeURI="/vocabulary/preservation/rightsBasis"
            abbrev="rightsBasis" abbrevName="Rights Basis" fullName="Rights Basis">
            <description><p></p></description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/preservation/rightsRelatedAgentRole"
            relativeURI="/vocabulary/preservation/rightsRelatedAgentRole"
            abbrev="rightsRelatedAgentRole" abbrevName="Rights Related Agent Role"
            fullName="Rights Related Agent Role">
            <description><p></p></description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/preservation/signatureEncoding"
            relativeURI="/vocabulary/preservation/signatureEncoding"
            abbrev="signatureEncoding" abbrevName="Signature Encoding"
            fullName="Signature Encoding">
            <description><p></p></description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/preservation/signatureMethod"
            relativeURI="/vocabulary/preservation/signatureMethod"
            abbrev="signatureMethod" abbrevName="Signature Method"
            fullName="Signature Method">
            <description><p></p></description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/preservation/softwareType"
            relativeURI="/vocabulary/preservation/softwareType"
            abbrev="softwareType" abbrevName="Software Type"
            fullName="Software Type">
            <description><p></p></description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/preservation/storageMedium"
            relativeURI="/vocabulary/preservation/storageMedium"
            abbrev="storageMedium" abbrevName="Storage Medium"
            fullName="Storage Medium">
            <description><p></p></description>
        </scheme>
  		<scheme 
            uri="http://id.loc.gov/vocabulary/mpresformat" 
            relativeURI="/vocabulary/mpresformat"
            abbrev="mpresformat"
            abbrevName="MARC Presenation Format"
            size="small"
            fullName="MARC Presentation Format List">
            <description><p></p>
            </description>
        </scheme>
    </schemes>;
    
(:~
:   This variable records all the MADS Schemes in the system and 
:   relevant information pertaining to accessing them and their
:   display **for all bibframe-related sections.**
:)
declare variable $constants:BIBFRAME_SCHEMES as element() :=
    <schemes>
    <!-- space -->
        <scheme uri="http://id.loc.gov/resources"
            relativeURI="/resources"
            abbrev="resources" abbrevName="BIBFRAME Resources"
            fullName="BIBFRAME Resources">
            <description><p></p></description>
        </scheme>
        <scheme uri="http://id.loc.gov/resources/works"
            relativeURI="/resources/works"
            abbrev="works" abbrevName="BIBFRAME Works"
            fullName="BIBFRAME Works">
            <description><p></p></description>
        </scheme>
        <scheme uri="http://id.loc.gov/resources/instances"
            relativeURI="/resources/instances"
            abbrev="instances" abbrevName="BIBFRAME Instances"
            fullName="BIBFRAME Instances">
            <description><p></p></description>
        </scheme>
        <scheme uri="http://id.loc.gov/resources/annotations"
            relativeURI="/resources/annotations"
            abbrev="annotations" abbrevName="BIBFRAME Annotations"
            fullName="BIBFRAME Annotations">
            <description><p></p></description>
        </scheme>
    </schemes>;

    
declare variable $constants:RDA_SCHEMES as element() := 
    <schemes>
        <scheme uri="http://id.loc.gov/vocabulary/rda" relativeURI="/vocabulary/rda" abbrev="rda" abbrevName="RDA Schemes (all)" fullName="RDA Schemes (all)">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/AspectRatio" relativeURI="/vocabulary/rda/AspectRatio" abbrev="AspectRatio" abbrevName="RDA Aspect Ratio" fullName="RDA Aspect Ratio">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/baseMicro" relativeURI="/vocabulary/rda/baseMicro" abbrev="baseMicro" abbrevName="RDA Base Material for Microfilm, Microfiche, Photographic Film, and Motion Picture Film" fullName="RDA Base Material for Microfilm, Microfiche, Photographic Film, and Motion Picture Film">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/BibleBooks" relativeURI="/vocabulary/rda/BibleBooks" abbrev="BibleBooks" abbrevName="RDA Groups of Books in the Bible" fullName="RDA Groups of Books in the Bible">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/bookFormat" relativeURI="/vocabulary/rda/bookFormat" abbrev="bookFormat" abbrevName="RDA Book Format" fullName="RDA Book Format">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/broadcastStand" relativeURI="/vocabulary/rda/broadcastStand" abbrev="broadcastStand" abbrevName="RDA Broadcast Standard" fullName="RDA Broadcast Standard">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/Choruses" relativeURI="/vocabulary/rda/Choruses" abbrev="Choruses" abbrevName="RDA Choruses" fullName="RDA Choruses">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/col3D" relativeURI="/vocabulary/rda/col3D" abbrev="col3D" abbrevName="RDA Colour of Three-Dimensional Form" fullName="RDA Colour of Three-Dimensional Form">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/CollTitle" relativeURI="/vocabulary/rda/CollTitle" abbrev="CollTitle" abbrevName="RDA Conventional Collective Title" fullName="RDA Conventional Collective Title">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/colMovingImage" relativeURI="/vocabulary/rda/colMovingImage" abbrev="colMovingImage" abbrevName="RDA Colour of Moving Images" fullName="RDA Colour of Moving Images">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/colStillImage" relativeURI="/vocabulary/rda/colStillImage" abbrev="colStillImage" abbrevName="RDA Colour of Still Image" fullName="RDA Colour of Still Image">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/configPlayback" relativeURI="/vocabulary/rda/configPlayback" abbrev="configPlayback" abbrevName="RDA Configuration of Playback Channels" fullName="RDA Configuration of Playback Channels">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/digiRepCarto" relativeURI="/vocabulary/rda/digiRepCarto" abbrev="digiRepCarto" abbrevName="RDA Digital Representation of Cartographic Content" fullName="RDA Digital Representation of Cartographic Content">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/distCharMusical" relativeURI="/vocabulary/rda/distCharMusical" abbrev="distCharMusical" abbrevName="RDA Other Distinguishing Characteristics of the Expression of a Musical Work" fullName="RDA Other Distinguishing Characteristics of the Expression of a Musical Work">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/distCharReligious" relativeURI="/vocabulary/rda/distCharReligious" abbrev="distCharReligious" abbrevName="RDA Other Distinguishing Characteristics of the Expression of a Religious Work" fullName="RDA Other Distinguishing Characteristics of the Expression of a Religious Work">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/emulsionMicro" relativeURI="/vocabulary/rda/emulsionMicro" abbrev="emulsionMicro" abbrevName="RDA Emulsion on Microfilm and Microfiche" fullName="RDA Emulsion on Microfilm and Microfiche">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/encFormat" relativeURI="/vocabulary/rda/encFormat" abbrev="encFormat" abbrevName="RDA Encoding Format" fullName="RDA Encoding Format">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/extent" relativeURI="/vocabulary/rda/extent" abbrev="extent" abbrevName="RDA Extent" fullName="RDA Extent">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/extentCarto" relativeURI="/vocabulary/rda/extentCarto" abbrev="extentCarto" abbrevName="RDA Extent of Cartographic Resource" fullName="RDA Extent of Cartographic Resource">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/extentImage" relativeURI="/vocabulary/rda/extentImage" abbrev="extentImage" abbrevName="RDA Extent of Still Image" fullName="RDA Extent of Still Image">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/extentText" relativeURI="/vocabulary/rda/extentText" abbrev="extentText" abbrevName="RDA Extent of Text" fullName="RDA Extent of Text">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/extentThreeDim" relativeURI="/vocabulary/rda/extentThreeDim" abbrev="extentThreeDim" abbrevName="RDA Extent of Three-dimensional Form" fullName="RDA Extent of Three-dimensional Form">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/extenttNoteMus" relativeURI="/vocabulary/rda/extenttNoteMus" abbrev="extenttNoteMus" abbrevName="RDA Extent of Notated Music" fullName="RDA Extent of Notated Music">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/fileType" relativeURI="/vocabulary/rda/fileType" abbrev="fileType" abbrevName="RDA File Type" fullName="RDA File Type">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/fontSize" relativeURI="/vocabulary/rda/fontSize" abbrev="fontSize" abbrevName="RDA Font Size" fullName="RDA Font Size">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/FormatNoteMus" relativeURI="/vocabulary/rda/FormatNoteMus" abbrev="FormatNoteMus" abbrevName="RDA Format of Notated Music" fullName="RDA Format of Notated Music">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/frequency" relativeURI="/vocabulary/rda/frequency" abbrev="frequency" abbrevName="RDA Frequency" fullName="RDA Frequency">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/genAudio" relativeURI="/vocabulary/rda/genAudio" abbrev="genAudio" abbrevName="RDA Generation of Audio Recording" fullName="RDA Generation of Audio Recording">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/gender" relativeURI="/vocabulary/rda/gender" abbrev="gender" abbrevName="RDA Gender" fullName="RDA Gender">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/genDigital" relativeURI="/vocabulary/rda/genDigital" abbrev="genDigital" abbrevName="RDA Generation of Digital Resource" fullName="RDA Generation of Digital Resource">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/genMicroform" relativeURI="/vocabulary/rda/genMicroform" abbrev="genMicroform" abbrevName="RDA Generation for Microform" fullName="RDA Generation for Microform">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/genMoPic" relativeURI="/vocabulary/rda/genMoPic" abbrev="genMoPic" abbrevName="RDA Generation for Motion Picture" fullName="RDA Generation for Motion Picture">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/genVideo" relativeURI="/vocabulary/rda/genVideo" abbrev="genVideo" abbrevName="RDA Generation for Videotape" fullName="RDA Generation for Videotape">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/groovePitch" relativeURI="/vocabulary/rda/groovePitch" abbrev="groovePitch" abbrevName="RDA Groove Pitch of an Analog Cylinder" fullName="RDA Groove Pitch of an Analog Cylinder">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/grooveWidth" relativeURI="/vocabulary/rda/grooveWidth" abbrev="grooveWidth" abbrevName="RDA Groove Width of an Analog Disc" fullName="RDA Groove Width of an Analog Disc">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/groupsInstr" relativeURI="/vocabulary/rda/groupsInstr" abbrev="groupsInstr" abbrevName="RDA Groups of Instruments" fullName="RDA Groups of Instruments">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/IllusContent" relativeURI="/vocabulary/rda/IllusContent" abbrev="IllusContent" abbrevName="RDA Illustrative Content" fullName="RDA Illustrative Content">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/InstOrch" relativeURI="/vocabulary/rda/InstOrch" abbrev="InstOrch" abbrevName="RDA Instrumental Music for Orchestra, String Orchestra, or Band" fullName="RDA Instrumental Music for Orchestra, String Orchestra, or Band">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/layout" relativeURI="/vocabulary/rda/layout" abbrev="layout" abbrevName="RDA Layout" fullName="RDA Layout">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/layoutCartoImage" relativeURI="/vocabulary/rda/layoutCartoImage" abbrev="layoutCartoImage" abbrevName="RDA Layout of Cartographic Images" fullName="RDA Layout of Cartographic Images">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/layoutTacMusic" relativeURI="/vocabulary/rda/layoutTacMusic" abbrev="layoutTacMusic" abbrevName="RDA Layout of Tactile Musical Notation" fullName="RDA Layout of Tactile Musical Notation">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/medPerform" relativeURI="/vocabulary/rda/medPerform" abbrev="medPerform" abbrevName="RDA Medium of Performance" fullName="RDA Medium of Performance">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/ModeIssue" relativeURI="/vocabulary/rda/ModeIssue" abbrev="ModeIssue" abbrevName="RDA Mode of Issuance" fullName="RDA Mode of Issuance">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/MusNotation" relativeURI="/vocabulary/rda/MusNotation" abbrev="MusNotation" abbrevName="RDA Form of Musical Notation" fullName="RDA Form of Musical Notation">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/noteMove" relativeURI="/vocabulary/rda/noteMove" abbrev="noteMove" abbrevName="RDA Form of Notated Movement" fullName="RDA Form of Notated Movement">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/OtherCharExp" relativeURI="/vocabulary/rda/OtherCharExp" abbrev="OtherCharExp" abbrevName="RDA Other Distinguishing Characteristic of the Expression" fullName="RDA Other Distinguishing Characteristic of the Expression">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/OtherCharExpLegal" relativeURI="/vocabulary/rda/OtherCharExpLegal" abbrev="OtherCharExpLegal" abbrevName="RDA Other Distinguishing Characteristic of the Expression of a Legal Work" fullName="RDA Other Distinguishing Characteristic of the Expression of a Legal Work">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/presFormat" relativeURI="/vocabulary/rda/presFormat" abbrev="presFormat" abbrevName="RDA Presentation Format" fullName="RDA Presentation Format">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/prodManuscript" relativeURI="/vocabulary/rda/prodManuscript" abbrev="prodManuscript" abbrevName="RDA Production Method for Manuscripts" fullName="RDA Production Method for Manuscripts">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/prodTactile" relativeURI="/vocabulary/rda/prodTactile" abbrev="prodTactile" abbrevName="RDA Production Method for Tactile Resource" fullName="RDA Production Method for Tactile Resource">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/RDAappliedMaterial" relativeURI="/vocabulary/rda/RDAappliedMaterial" abbrev="RDAappliedMaterial" abbrevName="RDA Applied Material" fullName="RDA Applied Material">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/RDAbaseMaterial" relativeURI="/vocabulary/rda/RDAbaseMaterial" abbrev="RDAbaseMaterial" abbrevName="RDA Base Material" fullName="RDA Base Material">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/RDACarrierType" relativeURI="/vocabulary/rda/RDACarrierType" abbrev="RDACarrierType" abbrevName="RDA Carrier Type" fullName="RDA Carrier Type">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/RDAcolour" relativeURI="/vocabulary/rda/RDAcolour" abbrev="RDAcolour" abbrevName="RDA colour" fullName="RDA colour">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/RDAContentType" relativeURI="/vocabulary/rda/RDAContentType" abbrev="RDAContentType" abbrevName="RDA Content Type" fullName="RDA Content Type">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/RDAFontSize" relativeURI="/vocabulary/rda/RDAFontSize" abbrev="RDAFontSize" abbrevName="RDA Font Size" fullName="RDA Font Size">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/RDAMediaType" relativeURI="/vocabulary/rda/RDAMediaType" abbrev="RDAMediaType" abbrevName="RDA Media Type" fullName="RDA Media Type">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/RDAPolarity" relativeURI="/vocabulary/rda/RDAPolarity" abbrev="RDAPolarity" abbrevName="RDA Polarity" fullName="RDA Polarity">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/RDAproductionMethod" relativeURI="/vocabulary/rda/RDAproductionMethod" abbrev="RDAproductionMethod" abbrevName="RDA Production Method" fullName="RDA Production Method">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/RDAReductionRatio" relativeURI="/vocabulary/rda/RDAReductionRatio" abbrev="RDAReductionRatio" abbrevName="RDA Reduction Ratio" fullName="RDA Reduction Ratio">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/recMedium" relativeURI="/vocabulary/rda/recMedium" abbrev="recMedium" abbrevName="RDA Recording Medium" fullName="RDA Recording Medium">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/scale" relativeURI="/vocabulary/rda/scale" abbrev="scale" abbrevName="RDA Scale" fullName="RDA Scale">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/SoloVoices" relativeURI="/vocabulary/rda/SoloVoices" abbrev="SoloVoices" abbrevName="RDA Solo Voices" fullName="RDA Solo Voices">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/soundCont" relativeURI="/vocabulary/rda/soundCont" abbrev="soundCont" abbrevName="RDA Sound Content" fullName="RDA Sound Content">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/specPlayback" relativeURI="/vocabulary/rda/specPlayback" abbrev="specPlayback" abbrevName="RDA Special Playback Characteristics" fullName="RDA Special Playback Characteristics">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/StandCombInstr" relativeURI="/vocabulary/rda/StandCombInstr" abbrev="StandCombInstr" abbrevName="RDA Standard Combinations of Instruments" fullName="RDA Standard Combinations of Instruments">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/statIdentification" relativeURI="/vocabulary/rda/statIdentification" abbrev="statIdentification" abbrevName="RDA Status of Identification" fullName="RDA Status of Identification">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/TacNotation" relativeURI="/vocabulary/rda/TacNotation" abbrev="TacNotation" abbrevName="RDA Form of Tactile Notation" fullName="RDA Form of Tactile Notation">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/trackConfig" relativeURI="/vocabulary/rda/trackConfig" abbrev="trackConfig" abbrevName="RDA Track Configuration" fullName="RDA Track Configuration">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/typeRec" relativeURI="/vocabulary/rda/typeRec" abbrev="typeRec" abbrevName="RDA Type of Recording" fullName="RDA Type of Recording">
            <description>
                <p/>
            </description>
        </scheme>
        <scheme uri="http://id.loc.gov/vocabulary/rda/videoFormat" relativeURI="/vocabulary/rda/videoFormat" abbrev="videoFormat" abbrevName="RDA Video Format" fullName="RDA Video Format">
            <description>
                <p/>
            </description>
        </scheme>
    </schemes>;

(:~
:   This variable records all the MADS Collections in the system and 
:   relevant information pertaining to accessing them and their
:   display.
:
:	Changes:
: 	2012/09: 	Changed labels on "Subdivide Geographically" per CPSO.
:				Added Undifferentiated Names
:)
declare variable $constants:COLLECTIONS as element() :=
    <collections>
        <collection 
            uri="http://id.loc.gov/authorities/names/collection_LCNAF" 
            abbrev="LCNAF"
            fullName="LC Names Collection - General Collection"></collection>
        <collection 
            uri="http://id.loc.gov/authorities/subjects/collection_LCSH_General" 
            abbrev="LCSH"
            fullName="LCSH Collection - General Collection"></collection>
        <collection 
            uri="http://id.loc.gov/authorities/subjects/collection_LCSH_Childrens" 
            abbrev="LCSHSJ"
            fullName="LCSH Collection - Children's Headings"></collection>
        <collection 
            uri="http://id.loc.gov/authorities/subjects/collection_LCSHAuthorizedHeadings" 
            abbrev="LCSH_AuthHeadings"
            fullName="LCSH Collection - Authorized Headings"></collection>
        <collection 
            uri="http://id.loc.gov/authorities/names/collection_NamesAuthorizedHeadings" 
            abbrev="Names_AuthHeadings"
            fullName="Names Collection - Authorized Headings"></collection>
        <collection 
            uri="http://id.loc.gov/authorities/names/collection_NamesUndifferentiated" 
            abbrev="Names_Collection_NamesUndifferentiated"
            fullName="Names Collection - Undifferentiated Names"></collection>
		<collection 
            uri="http://id.loc.gov/authorities/names/collection_FRBRWork" 
            abbrev="Names_Collection_FRBRWork"
            fullName="Names Collection - FRBR Work"></collection>
        <collection 
            uri="http://id.loc.gov/authorities/names/collection_FRBRExpression" 
            abbrev="Names_Collection_FRBRExpression"
            fullName="Names Collection - FRBR Expression"></collection>
        <collection 
            uri="http://id.loc.gov/authorities/subjects/collection_Subdivisions" 
            abbrev="LCSH"
            fullName="LCSH Collection - Subdivisions"></collection>
        <collection 
            uri="http://id.loc.gov/authorities/subjects/collection_SubdivideGeographicalIndirect" 
            abbrev="LCSH_Collection_SubdivideGeographicalIndirect"
            fullName="LCSH Collection - Term Permitted to be Indirectly Subdivided Geographically"></collection>
        <collection 
            uri="http://id.loc.gov/authorities/subjects/collection_SubdivideGeographicalDirect" 
            abbrev="LCSH_Collection_SubdivideGeographicalDirect"
            fullName="LCSH Collection - Term Permitted to be Directly Subdivided Geographically"></collection>
        <collection 
            uri="http://id.loc.gov/authorities/subjects/collection_SubdivideGeographicalIndirect" 
            abbrev="LCSH_Collection_SubdivideGeographicalIndirect"
            fullName="LCSH Collection - May Subdivide Geographically"></collection>
        <collection 
            uri="http://id.loc.gov/authorities/subjects/collection_SubdivideGeographically" 
            abbrev="LCSH_Collection_SubdivideGeographically"
            fullName="LCSH Collection - May Subdivide Geographically"></collection>   
        <collection 
            uri="http://id.loc.gov/authorities/subjects/collection_TopicSubdivisions" 
            abbrev="LCSH_Collection_TopicSubdivisions"
            fullName="LCSH Collection - Topic Subdivisions"></collection>
        <collection 
            uri="http://id.loc.gov/authorities/subjects/collection_GenreFormSubdivisions" 
            abbrev="LCSH_Collection_GenreFormSubdivisions"
            fullName="LCSH Collection - GenreForm Subdivisions"></collection>
        <collection 
            uri="http://id.loc.gov/authorities/subjects/collection_TemporalSubdivisions" 
            abbrev="LCSH_Collection_TemporalSubdivisions"
            fullName="LCSH Collection - Temporal Subdivisions"></collection>
        <collection 
            uri="http://id.loc.gov/authorities/subjects/collection_GeographicSubdivisions" 
            abbrev="LCSH_Collection_GeographicSubdivisions"
            fullName="LCSH Collection - Geographic Subdivisions"></collection>
        <collection 
            uri="http://id.loc.gov/authorities/subjects/collection_LanguageSubdivisions" 
            abbrev="LCSH_Collection_LanguageSubdivisions"
            fullName="LCSH Collection - Language Subdivisions"></collection>
        <collection 
            uri="http://id.loc.gov/vocabulary/geographicAreas/collection_PastPresentGACSEntries" 
            abbrev="GACS_Collection_PastPresentEntries"
            fullName="GACS Collection - Past and Present Entries"></collection>
        <collection 
            uri="http://id.loc.gov/vocabulary/countries/collection_PastPresentCountriesEntries" 
            abbrev="Countries_Collection_PastPresentEntries"
            fullName="Countries Collection - Past and Present Entries"></collection>
        <collection 
            uri="http://id.loc.gov/vocabulary/languages/collection_PastPresentLanguagesEntries" 
            abbrev="Languages_Collection_PastPresentEntries"
            fullName="Languages Collection - Past and Present Entries"></collection>
     <collection 
            uri="http://id.loc.gov/authorities/names/collection_Jurisdictions" 
            abbrev="Collection_Jurisdictions"
            fullName="Names Collection - Jurisdiction">
    </collection>
    <collection 
            uri="http://id.loc.gov/authorities/demographicTerms/collection_LCDGT_General" 
            abbrev="collection_LCDGT_General"
            fullName="LCDGT - General Collection"> 
    </collection>
    <collection 
            uri="http://id.loc.gov/authorities/demographicTerms/collection_LCDGT_Age" 
            abbrev="collection_LCDGT_Age"
            fullName="LCDGT - Age">
    </collection>
    <collection 
            uri="http://id.loc.gov/authorities/demographicTerms/collection_LCDGT_Educational" 
            abbrev="collection_LCDGT_Educational"
            fullName="LCDGT - Educational Level">
    </collection>
    <collection 
            uri="http://id.loc.gov/authorities/demographicTerms/collection_LCDGT_Ethnic" 
            abbrev="collection_LCDGT_Ethnic"
            fullName="LCDGT - Ethnic or Cultural">
    </collection>
    <collection 
            uri="http://id.loc.gov/authorities/demographicTerms/collection_LCDGT_Gender" 
            abbrev="collection_LCDGT_Gender"
            fullName="LCDGT - Gender">
    </collection>
    <collection 
            uri="http://id.loc.gov/authorities/demographicTerms/collection_LCDGT_Language" 
            abbrev="collection_LCDGT_Language"
            fullName="LCDGT - Language">
    </collection>
    <collection 
            uri="http://id.loc.gov/authorities/demographicTerms/collection_LCDGT_Medical" 
            abbrev="collection_LCDGT_Medical"
            fullName="LCDGT - Medical, Psychological, and Disability">
    </collection>
    <collection 
            uri="http://id.loc.gov/authorities/demographicTerms/collection_LCDGT_Nationality" 
            abbrev="collection_LCDGT_Nationality"
            fullName="LCDGT - Nationality or Regional">
    </collection>
    <collection 
            uri="http://id.loc.gov/authorities/demographicTerms/collection_LCDGT_Occupational" 
            abbrev="collection_LCDGT_Occupational"
            fullName="LCDGT - Occupational or Field of Activity">
    </collection>
    <collection 
            uri="http://id.loc.gov/authorities/demographicTerms/collection_LCDGT_Religion" 
            abbrev="collection_LCDGT_Religion"
            fullName="LCDGT - Religion">
    </collection>
    <collection 
            uri="http://id.loc.gov/authorities/demographicTerms/collection_LCDGT_Sexual" 
            abbrev="collection_LCDGT_Sexual"
            fullName="LCDGT - Sexual Orientation">
    </collection>
    <collection 
            uri="http://id.loc.gov/authorities/demographicTerms/collection_LCDGT_Social" 
            abbrev="collection_LCDGT_Social"
            fullName="LCDGT - Social">
    </collection> 

    <collection 
            uri="http://id.loc.gov/vocabulary/ethnographicTerms/collection_ethnographicTerms" 
            abbrev="collection_ethnographicTerms_General"
            fullName="Ethnographic Thesaurus - General">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/graphicMaterials/collection_graphicMaterials" 
            abbrev="collection_graphicMaterials_General"
            fullName="Thesaurus for Graphic Materials - General">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/marcgt/collection_marcgt" 
            abbrev="collection_marcgt"
            fullName="MARC Genre Terms Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/mcolor/collection_mcolor" 
            abbrev="collection_mcolor"
            fullName="MARC Color Content Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/mpolarity/collection_mpolarity" 
            abbrev="collection_mpolarity"
            fullName="MARC Polarity Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/mplayback/collection_mplayback" 
            abbrev="collection_mplayback"
            fullName="MARC Playback Channels Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/millus/collection_millus" 
            abbrev="collection_millus"
            fullName="MARC Illustrative Content Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/issuance/collection_issuance" 
            abbrev="collection_issuance"
            fullName="MARC Issuance Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/maudience/collection_maudience" 
            abbrev="collection_maudience"
            fullName="MARC Intended Audience Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/mmaterial/collection_mmaterial" 
            abbrev="collection_mmaterial"
            fullName="MARC Support Material Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/mmaterial/collection_base" 
            abbrev="collection_base"
            fullName="MARC Base Material Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/mmaterial/collection_mount" 
            abbrev="collection_mount"
            fullName="MARC Mount Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/mmaterial/collection_emulsion" 
            abbrev="collection_emulsion"
            fullName="MARC Emulsion Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/mmaterial/collection_applied" 
            abbrev="collection_applied"
            fullName="MARC Applied Material Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/mmaterial/collection_marcauthen" 
            abbrev="collection_marcauthen"
            fullName="MARC Authentication Action Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/mmaterial/collection_menclvl" 
            abbrev="collection_menclvl"
            fullName="MARC Encoding Level Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/maspect/collection_maspect" 
            abbrev="collection_maspect"
            fullName="MARC Aspect Ratio Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/mfiletype/collection_mfiletype" 
            abbrev="collection_mfiletype"
            fullName="MARC File Type Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/mgeneration/collection_mgeneration" 
            abbrev="collection_mgeneration"
            fullName="MARC Generation Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/mgroove/collection_mgroove" 
            abbrev="collection_mgroove"
            fullName="MARC Groove Width/Pitch/Cutting Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/mmusnotation/collection_mmusnotation" 
            abbrev="collection_mmusnotation"
            fullName="MARC Music Notation Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/mproduction/collection_mproduction" 
            abbrev="collection_mproduction"
            fullName="MARC Production Method Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/mrecmedium/collection_mrecmedium" 
            abbrev="collection_mrecmedium"
            fullName="MARC Record Medium Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/mspecplayback/collection_mspecplayback" 
            abbrev="collection_mspecplayback"
            fullName="MARC Special Playback Characeristics Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/mstatus/collection_mstatus" 
            abbrev="collection_mstatus"
            fullName="MARC Identifier Status Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/msoundcontent/collection_msoundcontent" 
            abbrev="msoundcontent"
            fullName="MARC Sound Content Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/mrectype/collection_mrectype" 
            abbrev="mrectype"
            fullName="MARC Recording Type Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/mlayout/collection_mlayout" 
            abbrev="mlayout"
            fullName="MARC Layout Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/mmusicformat/collection_mmusicformat" 
            abbrev="mmusicformat"
            fullName="MARC Notated Music Form Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/mbroadstd/collection_mbroadstd" 
            abbrev="mbroadstd"
            fullName="MARC Broadcast Standard Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/mregencoding/collection_mregencoding" 
            abbrev="mregencoding"
            fullName="MARC Regional Encoding Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/mvidformat/collection_mvidformat" 
            abbrev="mvidformat"
            fullName="MARC Video Format Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/mpresformat/collection_mpresformat" 
            abbrev="mpresformat"
            fullName="MARC Presentation Format Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/mtechnique/collection_mtechnique" 
            abbrev="mtechnique"
            fullName="MARC Technique Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/descriptionConventions/collection_descriptionConventionSchemes" 
            abbrev="collection_descriptionConventionSchemes"
            fullName="Description Convention Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/contentTypes/collection_ContentTypes" 
            abbrev="collection_ContentTypes"
            fullName="Content Types Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/contentTypes/collection_RDAContentTypes" 
            abbrev="collection_RDAContentTypes"
            fullName="RDA Content Types Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/carriers/collection_Carriers" 
            abbrev="collection_Carriers"
            fullName="Carriers Collection">
    </collection>  
    <collection 
            uri="http://id.loc.gov/vocabulary/carriers/collection_ComputerCarriers" 
            abbrev="collection_ComputerCarriers"
            fullName="Computer Carriers Collection">
    </collection>  
    <collection 
            uri="http://id.loc.gov/vocabulary/carriers/collection_MicroformCarriers" 
            abbrev="collection_MicroformCarriers"
            fullName="Microform Carriers Collection">
    </collection>  
    <collection 
            uri="http://id.loc.gov/vocabulary/carriers/collection_MicroscopicCarriers" 
            abbrev="collection_MicroscopicCarriers"
            fullName="Microscopic Carriers Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/carriers/collection_ProjectedImageCarriers" 
            abbrev="collection_ProjectedImageCarriers"
            fullName="Projected Image Carriers Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/carriers/collection_RDACarriers" 
            abbrev="collection_RDACarriers"
            fullName="RDA Carriers Collection">
    </collection>  
    <collection 
            uri="http://id.loc.gov/vocabulary/carriers/collection_StereographicCarriers" 
            abbrev="collection_StereographicCarriers"
            fullName="Stereographic Carriers Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/carriers/collection_UnmediatedCarriers" 
            abbrev="collection_UnmediatedCarriers"
            fullName="Unmediated Carriers Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/carriers/collection_UnspecifiedCarriers" 
            abbrev="collection_UnspecifiedCarriers"
            fullName="Unspecified Carriers Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/carriers/collection_VideoCarriers" 
            abbrev="collection_VideoCarriers"
            fullName="Video Carriers Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/carriers/collection_AudioCarriers" 
            abbrev="collection_AudioCarriers"
            fullName="Audio Carriers Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/mediaTypes/collection_MediaTypes" 
            abbrev="collection_MediaTypes"
            fullName="Media Types Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/mediaTypes/collection_RDAMediaTypes" 
            abbrev="collection_RDAMediaTypes"
            fullName="RDA Media Types Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/subjectSchemes/collection_SubjectSchemes" 
            abbrev="collection_SubjectSchemes"
            fullName="Subject Schemes Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/frequencies/collection_publicationsFrequencies" 
            abbrev="collection_publicationsFrequencies"
            fullName="Publications Frequencies Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/datatypes/edtf/collection_EDTFTypes" 
            abbrev="collection_EDTFTypes"
            fullName="EDTF Types Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/identifiers/collection_StandardIdentifiers" 
            abbrev="collection_StandardIdentifiers"
            fullName="Standard Identifiers Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/genreFormSchemes/collection_GenreFormSchemes" 
            abbrev="collection_GenreFormSchemes"
            fullName="Genre Form Schemes Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/resourceComponents/collection_resourceComponents" 
            abbrev="collection_resourceComponents"
            fullName="Resource Components Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/resourceTypes/collection_ResourceTypes" 
            abbrev="collection_ResourceTypes"
            fullName="Resource Types Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/vocabulary/classSchemes/collection_ClassificationSchemes" 
            abbrev="collection_ClassificationSchemes"
            fullName="Classification Schemes Collection">
    </collection>
    <collection 
            uri="http://id.loc.gov/resources" 
            abbrev="BIBFRAME_Resources"
            fullName="BIBFRAME Resources">
    </collection>
    <collection 
            uri="http://id.loc.gov/resources/works" 
            abbrev="BIBFRAME_Works"
            fullName="BIBFRAME Works">
    </collection>
    <collection 
            uri="http://id.loc.gov/resources/instances" 
            abbrev="BIBFRAME_Instances"
            fullName="BIBFRAME Instances">
    </collection>
    <collection 
            uri="http://id.loc.gov/resources/annotations" 
            abbrev="BIBFRAME_Annotations"
            fullName="BIBFRAME Annotations">
    </collection>
	<collection         uri="http://id.loc.gov/authorities/subjects/collection_PatternHeadingH1095"     abbrev="PatternHeadingH1095"    fullName="Pattern Heading - Free-floating subdivisions (general application)"/>
	<collection         uri="http://id.loc.gov/authorities/subjects/collection_PatternHeadingH1100"     abbrev="PatternHeadingH1100"    fullName="Pattern Heading - Classes of Persons"/>
	<collection         uri="http://id.loc.gov/authorities/subjects/collection_PatternHeadingH1103"     abbrev="PatternHeadingH1103"    fullName="Pattern Heading - Ethnic Groups"/>
	<collection         uri="http://id.loc.gov/authorities/subjects/collection_PatternHeadingH1105"     abbrev="PatternHeadingH1105"    fullName="Pattern Heading - Corporate Bodies"/>
	<collection         uri="http://id.loc.gov/authorities/subjects/collection_PatternHeadingH1110"     abbrev="PatternHeadingH1110"    fullName="Pattern Heading - Names of Persons"/>
	<collection         uri="http://id.loc.gov/authorities/subjects/collection_PatternHeadingH1120"     abbrev="PatternHeadingH1120"    fullName="Pattern Heading - Names of Families"/>
	<collection         uri="http://id.loc.gov/authorities/subjects/collection_PatternHeadingH1140"     abbrev="PatternHeadingH1140"    fullName="Pattern Heading - Names of Places"/>
	<collection         uri="http://id.loc.gov/authorities/subjects/collection_PatternHeadingH1145.5"   abbrev="PatternHeadingH1145.5"  fullName="Pattern Heading - Bodies of Water"/>
	<collection         uri="http://id.loc.gov/authorities/subjects/collection_PatternHeadingH1146"     abbrev="PatternHeadingH1146"    fullName="Pattern Heading - Subdivisions Controlled by Pattern Headings"/>
	<collection         uri="http://id.loc.gov/authorities/subjects/collection_PatternHeadingH1147"     abbrev="PatternHeadingH1147"    fullName="Pattern Heading - Animals"/>
	<collection         uri="http://id.loc.gov/authorities/subjects/collection_PatternHeadingH1148"     abbrev="PatternHeadingH1148"    fullName="Pattern Heading - Art"/>
	<collection         uri="http://id.loc.gov/authorities/subjects/collection_PatternHeadingH1149"     abbrev="PatternHeadingH1149"    fullName="Pattern Heading - Chemicals"/>
	<collection         uri="http://id.loc.gov/authorities/subjects/collection_PatternHeadingH1149.5"    abbrev="PatternHeadingH1149.5" fullName="Pattern Heading - Colonies"/>
	<collection         uri="http://id.loc.gov/authorities/subjects/collection_PatternHeadingH1150"     abbrev="PatternHeadingH1150"    fullName="Pattern Heading - Diseases"/>
	<collection         uri="http://id.loc.gov/authorities/subjects/collection_PatternHeadingH1151"     abbrev="PatternHeadingH1151"    fullName="Pattern Heading - Individual Educational Institutions"/>
	<collection         uri="http://id.loc.gov/authorities/subjects/collection_PatternHeadingH1151.5"   abbrev="PatternHeadingH1151.5"  fullName="Pattern Heading - Types of Educational Institutions"/>
	<collection         uri="http://id.loc.gov/authorities/subjects/collection_PatternHeadingH1153"     abbrev="PatternHeadingH1153"    fullName="Pattern Heading - Industries"/>
	<collection         uri="http://id.loc.gov/authorities/subjects/collection_PatternHeadingH1154"     abbrev="PatternHeadingH1154"    fullName="Pattern Heading - Languages"/>
	<collection         uri="http://id.loc.gov/authorities/subjects/collection_PatternHeadingH1154.5"   abbrev="PatternHeadingH1154.5"  fullName="Pattern Heading - Legal Topics"/>
	<collection         uri="http://id.loc.gov/authorities/subjects/collection_PatternHeadingH1155"     abbrev="PatternHeadingH1155"    fullName="Pattern Heading - Legislative Bodies"/>
	<collection         uri="http://id.loc.gov/authorities/subjects/collection_PatternHeadingH1155.2"   abbrev="PatternHeadingH1155.2"  fullName="Pattern Heading - Groups of Literary Authors"/>
	<collection         uri="http://id.loc.gov/authorities/subjects/collection_PatternHeadingH1155.6"   abbrev="PatternHeadingH1155.6"  fullName="Pattern Heading - Literary Works Entered Under Author"/>
	<collection         uri="http://id.loc.gov/authorities/subjects/collection_PatternHeadingH1155.8"   abbrev="PatternHeadingH1155.8"  fullName="Pattern Heading - Literary Works Entered Under Title"/>
	<collection         uri="http://id.loc.gov/authorities/subjects/collection_PatternHeadingH1156"     abbrev="PatternHeadingH1156"    fullName="Pattern Heading - Literatures"/>
	<collection         uri="http://id.loc.gov/authorities/subjects/collection_PatternHeadingH1158"     abbrev="PatternHeadingH1158"    fullName="Pattern Heading - Materials"/>
	<collection         uri="http://id.loc.gov/authorities/subjects/collection_PatternHeadingH1159"     abbrev="PatternHeadingH1159"    fullName="Pattern Heading - Military Services"/>
	<collection         uri="http://id.loc.gov/authorities/subjects/collection_PatternHeadingH1160"     abbrev="PatternHeadingH1160"    fullName="Pattern Heading - Musical Compositions"/>
	<collection         uri="http://id.loc.gov/authorities/subjects/collection_PatternHeadingH1161"     abbrev="PatternHeadingH1161"    fullName="Pattern Heading - Musical Instruments"/>
	<collection         uri="http://id.loc.gov/authorities/subjects/collection_PatternHeadingH1164"     abbrev="PatternHeadingH1164"    fullName="Pattern Heading - Organs and Regions of the Body"/>
	<collection         uri="http://id.loc.gov/authorities/subjects/collection_PatternHeadingH1180"     abbrev="PatternHeadingH1180"    fullName="Pattern Heading - Plants and Crops"/>
	<collection         uri="http://id.loc.gov/authorities/subjects/collection_PatternHeadingH1185"     abbrev="PatternHeadingH1185"    fullName="Pattern Heading - Religions"/>
	<collection         uri="http://id.loc.gov/authorities/subjects/collection_PatternHeadingH1186"     abbrev="PatternHeadingH1186"    fullName="Pattern Heading - Religious and Monastic Orders"/>
	<collection         uri="http://id.loc.gov/authorities/subjects/collection_PatternHeadingH1187"     abbrev="PatternHeadingH1187"    fullName="Pattern Heading - Christian Denominations"/>
	<collection         uri="http://id.loc.gov/authorities/subjects/collection_PatternHeadingH1188"     abbrev="PatternHeadingH1188"    fullName="Pattern Heading - Sacred Works"/>
	<collection         uri="http://id.loc.gov/authorities/subjects/collection_PatternHeadingH1195"     abbrev="PatternHeadingH1195"    fullName="Pattern Heading - Land Vehicles"/>
	<collection         uri="http://id.loc.gov/authorities/subjects/collection_PatternHeadingH1200"     abbrev="PatternHeadingH1200"    fullName="Pattern Heading - Wars"/>
 </collections>;
    
(:~
:   This variable records all the MADSType types 
:)
declare variable $constants:MADSTYPES as element() :=
    <madstypes>
        <type class="PersonalName">Personal Name</type>
        <type class="FamilyName">Family Name</type>
        <type class="CorporateName">Corporate Name</type>
        <type class="ConferenceName">Conference Name</type>
        <type class="Occupation">Occupation</type>
        <type class="Title">Title</type>
        <type class="Temporal">Temporal</type>
        <type class="Topic">Topic</type>
        <type class="Geographic">Geographic</type>
        <type class="GenreForm">GenreForm</type>
        <type class="ComplexSubject">Complex Subject</type>
        <type class="NameTitle">Name/Title</type>
        <type class="HierarchicalGeographic">Hierarchical Geographic</type>
        <type class="MADSScheme">MADS Scheme</type>
        <type class="MADSCollection">MADS Collection</type>
        <type class="Authority">Authority</type>
        <type class="Variant">Variant</type>
        
        <type class="Work">bibframe Work</type>
        <type class="Instance">bibframe Instance</type>
        <type class="Annotation">bibframe Annotation</type>
    </madstypes>;
    
    
(:~
:   This variable records all special search fields
:   These should have some form of corresponding range index 
:)
declare variable $constants:FIELDS as element() :=
    <fields>
        <field prefix="cs">Scheme</field>
        <field prefix="memberOf">Collection</field>
        <field prefix="rdftype">Type</field>
        <field prefix="token">LCCN/CODE</field>
        <field prefix="status">Status</field>
        <field prefix="cdate">Created Date</field>
        <field prefix="mdate">Modified Date</field>
        <field prefix="aLabel">Authoritative Label</field>
        <field prefix="vLabel">Variant Label</field>
        <field prefix="relation">Relation</field>
    </fields>;


(:~
:   This variable records all pages
:   The URIs might be bogus, used in so far as
:   1) they provide a hook into this variable
:   and 2) allow page info to be captured here.
:   The "/search.xml" uri is one example. 
:)
declare variable $constants:PAGES as element() :=
    <pages>
        <page 
            uri="/index.xml" 
            url="/" 
            heading="LC Linked Data Service"/>
        <page 
            uri="/descriptions.xml" 
            url="/descriptions/" 
            heading="Dataset Descriptions"/>
        <page 
            uri="/search.xml" 
            url="/search/" 
            heading="Search"/>
        <page 
            uri="/download.xml" 
            url="/download/" 
            heading="Download"/>
        <page 
            uri="/contact.xml" 
            url="/contact/" 
            heading="Contact"/>
        <page 
            uri="/views/pages/about/main.xml" 
            url="/about/" 
            heading="About" 
            subheading="Main"/>
        <page 
            uri="/views/pages/about/presentations.xml" 
            url="/about/presentations.html" 
            heading="About" 
            subheading="Papers &amp; Presentations"/>
        <page 
            uri="/views/pages/techcenter/downloads.xml" 
            url="/techcenter/" 
            heading="Technical Center"
            subheading="Downloads"/>
        <page 
            uri="/views/pages/techcenter/metadata.xml" 
            url="/techcenter/metadata.html" 
            heading="Technical Center"
            subheading="Metadata"/>
        <page 
            uri="/views/pages/techcenter/searching.xml" 
            url="/techcenter/searching.html" 
            heading="Technical Center"
            subheading="Searching/Querying"/>
        <page 
            uri="/views/pages/techcenter/serializations.xml" 
            url="/techcenter/serializations.html" 
            heading="Technical Center"
            subheading="Serializations"/>
        <page 
            uri="/views/pages/bfi-ee-group.xml" 
            url="/bfi-ee-group/" 
            heading="BFI - Early Experimenters"/>
    </pages>;
    
(:~
:   This variable records the MADS 2 SKOS mapping.
:)
    declare variable $constants:MADS2SKOSMAP :=
        <relations>
            <relation prop="madsrdf:hasVariant" skos="skosxl:altLabel">Variants</relation>
            <relation prop="madsrdf:hasBroaderAuthority" skos="skos:broader">Broader Terms</relation>
            <relation prop="madsrdf:hasNarrowerAuthority" skos="skos:narrower">Narrower Terms</relation>
            <relation prop="madsrdf:hasLaterEstablishedForm" skos="rdfs:seeAlso">Later Established Forms</relation>
            <relation prop="madsrdf:hasEarlierEstablishedForm" skos="rdfs:seeAlso">Early Established Forms</relation>
            <relation prop="madsrdf:useInstead" skos="rdfs:seeAlso">Use Instead</relation>
            <relation prop="madsrdf:hasReciprocalAuthority" skos="skos:related">Related Terms</relation>
            <relation prop="madsrdf:hasRelatedAuthority" skos="skos:semanticRelation">Related Terms</relation>
            <relation prop="madsrdf:see" skos="rdfs:seeAlso">See Also</relation>
            <relation prop="madsrdf:hasBroaderExternalAuthority" skos="skos:broadMatch">Broader Concepts from Other Schemes</relation>
            <relation prop="madsrdf:hasNarrowerExternalAuthority" skos="skos:narrowMatch">Narrower Concepts from Other Schemes</relation>
            <relation prop="madsrdf:hasExactExternalAuthority" skos="skos:exactMatch">Exact Matching Concepts from Other Schemes</relation>
            <relation prop="madsrdf:hasCloseExternalAuthority" skos="skos:closeMatch">Closely Matching Concepts from Other Schemes</relation>
            <relation prop="madsrdf:hasReciprocalExternalAuthority" skos="skos:relatedMatch">Closely Matching Concepts from Other Schemes</relation>
            <relation prop="madsrdf:note" skos="skos:note">General Notes</relation>
            <relation prop="madsrdf:definitionNote" skos="skos:definition">Definition Notes</relation>
            <relation prop="madsrdf:scopeNote" skos="skos:scopeNote">Scope Notes</relation>     
            <relation prop="madsrdf:changeNote" skos="skos:changeNote">Change Notes</relation>
            <relation prop="madsrdf:deletionNote" skos="skos:changeNote">Deletion Notes</relation>
            <relation prop="madsrdf:editorialNote" skos="skos:editorial">Editorial Notes</relation>
            <relation prop="madsrdf:exampleNote" skos="skos:example">Example Notes</relation>
            <relation prop="madsrdf:historyNote" skos="skos:historyNote">History Notes</relation>
            <relation prop="madsrdf:MADSCollection" skos="skos:Collection">Collection memberships</relation>
            <relation prop="madsrdf:MADSSCheme" skos="skos:ConceptScheme">Scheme memberships</relation>
            <!-- <relation prop="madsrdf:classification" skos="skos:semanticRelation">Classification</relation> -->
            <relation prop="madsrdf:code" skos="skos:notation">Codes</relation>
            <relation prop="madsrdf:hasMADSCollectionMember" skos="skos:member">Collection Members</relation>
            <relation prop="madsrdf:hasTopMemberOfMADSScheme" skos="skos:hasTopConcept">Top Scheme Members</relation>
            <relation prop="madsrdf:isTopMemberOfMADSScheme" skos="skos:topConceptOf">Top Scheme Member Of</relation>
            <relation prop="madsrdf:isMemberOfMADSScheme" skos="skos:inScheme">Top Scheme Members</relation>
            <relation prop="madsrdf:hasMADSSchemeMember">Scheme Members</relation>
            <relation prop="rdfs:subClassOf">Subclass Of</relation>
            <relation prop="rdfs:subPropertyOf">SubProperty Of</relation>
            
            <relation prop="owl:imports">Imports</relation>
            
            <relation prop="lcc:synthesizedFromSchedule">Synthesized From Schedule</relation>
            <relation prop="lcc:synthesizedFromTable">Synthesized From Table</relation>
            <relation prop="lcc:useGuideTable">Use With Guide Table(s)</relation>
            <relation prop="lcc:isGuideTableFor">Is Guide Table For</relation>
            <relation prop="lcc:useTable">Use With Table(s)</relation>
            <relation prop="lcc:isTableFor">Is Table For</relation>
            <relation prop="lcc:useWithSchedule">Use With Schedule(s)</relation>
            
            <relation prop="bf:creator">Creator(s)</relation>
            <relation prop="relators:cre">Creator(s)</relation>
            <relation prop="relators:aut">Author(s)</relation>
            
            <relation prop="bf:contributor">Contributor(s)</relation>
            <relation prop="relators:lyr">Lyricist(s)</relation>
            <relation prop="relators:prf">Performer(s)</relation>
            <relation prop="relators:ive">Interviewee(s)</relation>
            <relation prop="relators:ivr">Interviewer(s)</relation>
            
            <relation prop="bf:name">Name(s)</relation>
            <relation prop="bf:provider">Provider(s)</relation>
            <relation prop="bf:place">Place(s)</relation>
            <relation prop="bf:providerPlace">Place(s) of Publication</relation>
            <relation prop="bf:subject">Subject(s)</relation>
            <relation prop="bf:classification">Classification</relation>
           <!-- <relation prop="bf:classificationLcc">LC Classification</relation> -->
           <!-- <relation prop="bf:classificationNlm">NLM Classification</relation> -->
            <relation prop="bf:instance">Instance(s)</relation>
			<relation prop="bf:hasInstance">Instance(s)</relation>
            <relation prop="bf:instanceOf">Instance of Work</relation>
            <relation prop="bf:hasAnnotation">Annotation(s)</relation>
        <!--    <relation prop="bf:annotation">Annotation(s)</relation> -->
            <relation prop="bf:annotates">Annotates Work</relation>
            <relation prop="bf:hasIllustration">Cover Art</relation>
            <relation prop="bf:hasHoldings">Holdings</relation>
            <relation prop="bf:link">Link(s)</relation>
            <relation prop="bf:annotation-service">Annotation Service</relation>
            <relation prop="bf:derivedFrom">Derives from MARC21 Record</relation>
            <relation prop="bf:consolidates">Consolidates MARC21 Record(s)</relation>
            <relation prop="bf2:consolidates">Consolidates MARC21 Record(s)</relation>
            <relation prop="bf:isTranslationOf">Is Translation Of</relation>
			<relation prop="bf:translationOf">Is Translation Of</relation>
            <relation prop="bf:isVersionOf">Is Version Of</relation>
            <relation prop="bf:relatedWork">Related Work(s)</relation>
            <relation prop="bf:includes">Includes Work(s)</relation>
			<relation prop="bf:intendedAudience">Intended Audience</relation>
		<!--	<relation prop="bf:language">Language</relation> -->
		    <relation prop="bf:descriptionConventions">Description Conventions</relation>
		    <relation prop="bf:descriptionLanguage">DescriptionLanguage</relation>
		    <relation prop="bf:descriptionSource">Description Source</relation>
			<relation prop="bf:workTitle">Work Title</relation>
			<relation prop="bf:continues">Continues</relation>
		 	<relation prop="bf:continuedBy">Continued by</relation>                        
        </relations>;         
(:~
:   This variable records Language to Country Flag mapping.
: 	this list takes the language code and maps it to the country code for the flag name . In the case of danish, da=dk Danish = Denmark.
:)
    declare variable $constants:LANG2FLAG :=
          <langs>
			<lang iso6391="ar">ar</lang>
            <lang iso6391="en">us</lang>
            <lang iso6391="fr">fr</lang>
            <lang iso6391="de">de</lang>
			<lang iso6391="da">dk</lang>
			<lang iso6391="es">es</lang>
			<lang iso6391="el">el</lang>
			<lang iso6391="fi">fi</lang>
			<lang iso6391="hr">ci</lang>
            <lang iso6391="it">it</lang>
			<lang iso6391="ja">ja</lang>            
            <lang iso6391="mi">mi</lang>
			<lang iso6391="nl">ne</lang>
			<lang iso6391="no">no</lang>
			<lang iso6391="pl">pl</lang>  
            <lang iso6391="pt">pt</lang>            
			<lang iso6391="ru">ru</lang>
            <lang iso6391="sl">sl</lang>            
            <lang iso6391="sv">sv</lang>
            <lang iso6391="zh">zh</lang>               			       
        </langs>;
        
(:~
:   This variable records the questions and answers for email forms.  It's a cheap captcha.
:)
    declare variable $constants:QUESTIONS := 
        <questions>
            <question num="1" answer="3|three">If you have three apples how many apples do you have?</question>
            <question num="2" answer="white|grey|gray">What color was George Washington's white horse?</question>
            <question num="3" answer="grant|ulyssessgrant|ulyssesgrant">Who is buried in Grant's tomb?</question>
            <question num="4" answer="1|one">How many floors does a one-story house have?</question>     
            <question num="5" answer="4|four">How many bedrooms in a four bedroom apartment?</question>
            <question num="6" answer="2|two">If you can only see a boy and his dad, how many people can you see?</question>
            <question num="7" answer="yes">Are midnight blue and navy blue similar colors?</question>
        </questions>;
        
        
(:~
:   Months mapping.
:)
    declare variable $constants:MONTHS := 
        <months>
            <month m="01" n="1" F="January" M="Jan"/>
            <month m="02" n="2" F="February" M="Feb"/>
            <month m="03" n="3" F="March" M="Mar"/>
            <month m="04" n="4" F="April" M="Apr"/>
            <month m="05" n="5" F="May" M="May"/>
            <month m="06" n="6" F="June" M="Jun"/>
            <month m="07" n="7" F="July" M="Jul"/>
            <month m="08" n="8" F="August" M="Aug"/>
            <month m="09" n="9" F="September" M="Sep"/>
            <month m="10" n="10" F="October" M="Oct"/>
            <month m="11" n="11" F="November" M="Nov"/>
            <month m="12" n="12" F="December" M="Dec"/>
        </months>;
                
