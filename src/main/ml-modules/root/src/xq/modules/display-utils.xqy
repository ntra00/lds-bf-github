xquery version "1.0-ml";
module namespace display = "info:lc/xq-modules/display-utils";
(: 
 

:)
import module namespace functx	="http://www.functx.com" 				 at "functx.xqy";
import module namespace ssk 	= "info:lc/xq-modules/search-skin"		 at "search-skin.xqy";
import module namespace utils	= "info:lc/xq-modules/mets-utils"		 at "mets-utils.xqy";
import module namespace marcutil= "info:lc/xq-modules/marc-utils"		 at "marc-utils.xqy";
import module namespace matconf = "info:lc/xq-modules/config/materials"		 at "config/materialtype.xqy";
import module namespace cfg 	= "http://www.marklogic.com/ps/config"		 at "../../lds/config.xqy";

declare namespace marc    		=	"http://www.loc.gov/MARC21/slim";
declare namespace mxe       	=	"http://www.loc.gov/mxe";
declare namespace xdmp     		=	"http://marklogic.com/xdmp";
declare namespace bf       		=	"http://id.loc.gov/ontologies/bibframe/";
declare namespace bflc    		=	"http://id.loc.gov/ontologies/bflc/";
declare namespace rdfs     	 	=	"http://www.w3.org/2000/01/rdf-schema#";
declare namespace rdf     		=	"http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace madsrdf  		=	"http://www.loc.gov/mads/rdf/v1#";
declare namespace pmo  			=	"http://performedmusicontology.org/ontology/";
declare namespace xhtml			=	"http://www.w3.org/1999/xhtml" ; (:for output:)
declare namespace mat			=	"info:lc/xq-modules/config/materials";
declare namespace lclocal		=	"http://id.loc.gov/ontologies/lclocal/";

declare default function namespace 	"http://www.w3.org/2005/xpath-functions";
declare default element namespace 	"http://www.w3.org/1999/xhtml" ; (:for output:)

(:
declare  variable $id as xs:string := xdmp:get-request-field("id",""); 
declare variable $behavior as xs:string := xdmp:get-request-field("behavior",""); (:default, pageturner, contactsheet, etc. :)
declare variable $kmlurl as xs:string := xdmp:get-request-field("kmlurl",""); (: geodefault url :)
declare variable $words as xs:string := xdmp:get-request-field("words","");  (:hit highlight words (optional) :)
declare variable $part as xs:string := xdmp:get-request-field("part","");  (: labels, xml, navigation, ?? :)
declare variable $mime as xs:string := xdmp:get-request-field("mime","text/xhtml");  (: mxe, mets, mods, marcxml...dc? :)
declare variable $view as xs:string := xdmp:get-request-field("view","html");  (: could be "marctags" for bibdisplay, or "ajax" for ajax div view :)
:)



(:declare variable $CAPITAL-ALPHA as xs:string  :="ABCDEFGHIJKLMNOPQRSTUVWXYZ"; :)

declare variable $display:Relationships as element() :=
<set>
		<!--<rel><name>relatedTo</name><inverse>relatedTo</inverse></rel>-->
		<!--<rel><name>relationship</name><inverse>relatedTo</inverse></rel>-->
		<!--<rel><name>hasInstance</name><inverse>instanceOf</inverse></rel>-->
		<rel><name>instanceOf</name><inverse>hasInstance</inverse></rel>
		<rel><name>hasExpression</name><inverse>expressionOf</inverse></rel>
		<rel><name>expressionOf</name><inverse>hasExpression</inverse></rel>
		<rel><name>hasItem</name><inverse>itemOf</inverse></rel>
		<rel><name>itemOf</name><inverse>hasItem</inverse></rel>
		<rel><name>eventContent</name><inverse>eventContentOf</inverse></rel>
		<rel><name>eventContentOf</name><inverse>eventContent</inverse></rel>
		<rel><name>hasEquivalent</name><inverse>hasEquivalent</inverse></rel>
		<rel><name>hasPart</name><inverse>partOf</inverse></rel>
		<rel><name>partOf</name><inverse>hasPart</inverse></rel>
		<rel><name>accompaniedBy</name><inverse>accompanies</inverse></rel>
		<rel><name>accompanies</name><inverse>accompaniedBy</inverse></rel>
		<rel><name>hasDerivative</name><inverse>derivativeOf</inverse></rel>
		<rel><name>derivativeOf</name><inverse>hasDerivative</inverse></rel>
		<rel><name>precededBy</name>	<inverse>succeededBy</inverse></rel>
		<rel><name>succeededBy</name>	<inverse>precededBy</inverse></rel>
		<rel><name>references</name><inverse>referencedBy</inverse></rel>
		<rel><name>referencedBy</name><inverse>references</inverse></rel>
		<rel><name>issuedWith</name>	<inverse>issuedWith</inverse></rel>		
		<rel><name>otherPhysicalFormat</name><inverse>otherPhysicalFormat</inverse></rel>
		<rel><name>hasReproduction</name><inverse>reproductionOf</inverse></rel>
		<rel><name>reproductionOf</name><inverse>hasReproduction</inverse></rel>
		<rel><name>hasSeries</name><inverse>seriesOf</inverse></rel>
		<rel><name>seriesOf</name><inverse>hasSeries</inverse></rel>
		<rel><name>hasSubseries</name><inverse>subseriesOf</inverse></rel>
		<rel><name>subseriesOf</name><inverse>hasSubseries</inverse></rel>
		<rel><name>supplement</name><inverse>supplementTo</inverse></rel>
		<rel><name>supplementTo</name><inverse>supplement</inverse></rel>
		<rel><name>translation</name><inverse>translationOf</inverse></rel>
		<rel><name>translationOf</name><inverse>translation</inverse></rel>
		<rel><name>originalVersion</name><inverse>originalVersionOf</inverse></rel>
		<rel><name>originalVersionOf</name><inverse>originalVersion</inverse></rel>
		<rel><name>index</name><inverse>indexOf</inverse></rel>
		<rel><name>indexOf</name><inverse>index</inverse></rel>
		<rel><name>otherEdition</name><inverse>otherEdition</inverse></rel>
		<rel><name>findingAid</name><inverse>findingAidOf</inverse></rel>
		<rel><name>findingAidOf</name><inverse>findingAid</inverse></rel>
		<rel><name>replacementOf</name><inverse>replacedBy</inverse></rel>
		<rel><name>replacedBy</name><inverse>replacementOf</inverse></rel>
		<rel><name>mergerOf</name><inverse>mergedToForm</inverse></rel>
		<rel><name>mergedToForm</name><inverse>mergerOf</inverse></rel>
		<rel><name>continues</name><inverse>continuedBy</inverse></rel>
		<rel><name>continuedBy</name><inverse>continues</inverse></rel>
		<rel><name>continuesInPart</name><inverse>splitInto</inverse></rel>
		<rel><name>splitInto</name><inverse>continuesInPart</inverse></rel>
		<rel><name>absorbed</name><inverse>absorbedBy</inverse></rel>
		<rel><name>absorbedBy</name><inverse>absorbed</inverse></rel>
		<rel><name>separatedFrom</name><inverse>continuedInPartBy</inverse></rel>
		<rel><name>continuedInPartBy</name><inverse>separatedFrom</inverse></rel>
</set>;
declare variable $display:Ignores as element() :=
<properties> 
	<property name="bflc:titleSortKey"/>
	<property name="bflc:title00MarcKey"/>
	<property name="bflc:title00MatchKey"/>
	<property name="bflc:title10MarcKey"/>
	<property name="bflc:title10MatchKey"/>
	<property name="bflc:title11MarcKey"/>
	<property name="bflc:title11MatchKey"/>
	<property name="bflc:title30MarcKey"/>
	<property name="bflc:title30MatchKey"/>
	<property name="bflc:title40MarcKey"/>
	<property name="bflc:title40MatchKey"/>
	<property name="bflc:primaryContributorName00MatchKey"/>
	<property name="bflc:primaryContributorName10MatchKey"/>
	<property name="bflc:primaryContributorName11MatchKey"/>
	<property name="bflc:name00MarcKey"/>
	<property name="bflc:name00MatchKey"/>
	<property name="bflc:name10MarcKey"/>
	<property name="bflc:name10MatchKey"/>
	<property name="bflc:name11MarcKey"/>
	<property name="bflc:name11MatchKey"/>
	<property name="bflc:relatorMatchKey"/>
	<property name="rdf:type"/>
	<property name="rdf:value"/>
	<property name="rdfs:label"/>
	<property name="bf:code"/>
	<property name="bf:mainTitle"/>
</properties>;

declare variable $display:RDFprops as element () :=
<properties> 
	<property name="rdf:about" sort="01c">uri</property>
	<property name="label" range="literal" sort="0c">label</property>
	<property name="rdf:resource"  sort="01c">uri</property>
	<property name="type" range="rdfs:Class" sort="01c">Type</property>
	<property name="value" range="literal" sort="01d">Value</property><!--rdf:value -->	
	<property name="identifiedBy" range="Identifier" sort="03g">Identifier</property>
	<property name="identifies" range="rdfs:Resource" sort="03gb">Resouce identified</property>
	<property name="qualifier" range="literal" sort="03h">Qualifier</property>
	<property name="date" range="literal" sort="03j">Date</property>
	<property name="place" range="Place" sort="03k">Place</property>
	<property name="agent" range="Agent" sort="03l">Associated agent</property>
	<property name="count" range="literal" sort="03m">Number of units</property>
	<property name="unit" range="Unit" sort="03n">Type of unit</property>
	<property name="code" range="literal" sort="03o">Code</property>
	<property name="source" range="Source" sort="03q">Source</property>
	<property name="note" range="Note" sort="03r">Note</property>
	<property name="status" range="Status" sort="03s">Status</property>
	<property name="part" range="literal" sort="03t">Part</property>
	<property name="language" range="Language" sort="03u">Language information</property>
	<property name="content" range="Content" sort="05c">Content type</property>
	<property name="media" range="Media" sort="02d">Media type</property>
	<property name="carrier" range="Carrier" sort="02e">Carrier type</property>
	
	<property name="genreForm" range="GenreForm" sort="02f">Genre/form</property>
	<property name="title" range="Title" sort="01c">Title </property>
	<property name="mainTitle" range="literal" sort="01d">Main title</property>
	
	<property name="subtitle" range="literal" sort="01e">Subtitle</property>
	<property name="partNumber" range="literal" sort="01f">Part number</property>
	<property name="partName" range="literal" sort="01g">Part title</property>
	<property name="variantType" range="literal" sort="01h">Variant title type</property>
	<property name="originDate" range="literal" sort="01c">Date of work</property>
	<property name="originPlace" range="Place" sort="01d">Associated title place</property>
	<property name="historyOfWork" range="literal" sort="09e">History of the work</property>
	<property name="musicMedium" range="MusicMedium" sort="09g">Music medium of performance</property>
	<property name="instrument" range="MusicInstrument" sort="09h">Instrument</property>
	<property name="instrumentalType" range="literal" sort="09i">Instrument role</property>
	<property name="ensemble" range="MusicEnsemble" sort="09j">Ensemble</property>
	<property name="ensembleType" range="literal" sort="09k">Ensemble type</property>
	<property name="voice" range="MusicVoice" sort="09l">Voice</property>
	<property name="voiceType" range="literal" sort="09m">Type of voice</property>
	<property name="musicSerialNumber" range="literal" sort="09n">Music serial number</property>
	<property name="musicOpusNumber" range="literal" sort="09o">Music opus number</property>
	<property name="musicThematicNumber" range="literal" sort="09p">Music thematic number</property>
	<property name="musicKey" range="literal" sort="09q">Music key</property>
	<property name="legalDate" range="literal" sort="09r">Date of legal work</property>
	<property name="version" range="literal" sort="09s">Version</property>
	<property name="natureOfContent" range="literal" sort="11c">Content nature</property>
	<property name="geographicCoverage"  range="GeographicCoverage" sort="11d">Geographic coverage</property>
	<property name="temporalCoverage" range="literal" sort="11e">Temporal coverage</property>
	<property name="intendedAudience" range="IntendedAudience" sort="11f">Intended audience</property>
	<property name="arrangement" range="Arrangement" sort="11g">Organization/arrangement</property><!-- and arrangement -->
	<property name="pattern" range="literal" sort="11h">Arrangement of material</property>
	<property name="hierarchicalLevel" range="literal" sort="11i">Hierarchical level of material</property>
	<property name="organization" range="literal" sort="11j">Organization</property>
	<property name="dissertation" range="Dissertation" sort="11k">Dissertation Information</property>
	<property name="degree" range="literal" sort="11l">Degree</property>
	<property name="grantingInstitution" range="Agent" sort="11m">Degree issuing institution</property>
	<property name="summary" range="Summary" sort="11n">Summary content</property>
	<property name="capture" range="Capture" sort="11o">Capture of content</property>
	<property name="notation" range="Notation" sort="11pa">Notation system</property>
	<property name="contentAccessibility" range="ContentAccessibility" sort="11pb">Content accessibility information</property>
	<property name="illustrativeContent" range="Illustration" sort="11pc">Illustrative content information</property>
	<property name="supplementaryContent" range="rdfs:Resource" sort="11pd">Supplementary material</property>
	<property name="colorContent" range="ColorContent" sort="11pe">Color content</property>
	<property name="soundContent" range="SoundContent" sort="11pf">Sound content</property>
	<property name="aspectRatio" range="AspectRatio" sort="11pg">Aspect ratio</property>
	<property name="musicFormat" range="MusicFormat" sort="11ph">Format of notated music</property>
	<property name="duration" range="literal" sort="11pi">Duration</property>
	<property name="scale" range="Scale" sort="11pj">Scale</property>
	<property name="cartographicAttributes" range="Cartographic" sort="11qa">Cartographic data</property>
	<property name="ascensionAndDeclination" range="literal" sort="11qb">Cartographic ascension and declination</property>
	<property name="coordinates" range="literal" sort="11qc">Cartographic coordinates</property>
	<property name="equinox" range="literal" sort="11qd">Cartographic equinox</property>
	<property name="exclusionGRing" range="literal" sort="11qe">Cartographic G ring area excluded</property>
	<property name="outerGRing" range="literal" sort="11qf">Cartographic outer G ring area covered</property>
	<property name="projection" range="Projection" sort="11qg">Cartographic projection</property>
	<property name="credits" range="literal" sort="11r">Credits note</property>
	<property name="awards" range="literal" sort="11r">Award note</property>
	<property name="subject" range="rdfs:Resource" sort="13c">Subject</property>
	<property name="classification" range="Classification" sort="13d">Classification</property>
	<property name="schedulePart" range="literal" sort="13e">Classification designation</property>
	<property name="edition" range="literal" sort="13j">Classification scheme edition</property>
	
	<property name="classificationPortion" range="literal" sort="13g">Classification number</property> 
	<property name="itemPortion" range="literal" sort="13h">Classification item number</property>
	<property name="spanEnd" range="literal" sort="13i">Classification number span end</property>
	<property name="table" range="literal" sort="13j">Classification table identification</property>
	<property name="tableSeq" range="literal" sort="13k">Classification table sequence number</property>
	<property name="responsibilityStatement" range="literal" sort="15d">Creative responsibility statement</property>
	<property name="editionStatement" range="literal" sort="15e">Edition statement</property>
	<property name="editionEnumeration" range="literal" sort="15f">Edition enumeration</property>
	<property name="provisionActivityStatement" range="literal" sort="15g">Provider statement</property>
	<property name="seriesStatement" range="literal" sort="15h">Series statement</property>
	<property name="seriesEnumeration" range="literal" sort="15i">Series enumeration</property>
	<property name="subseriesStatement" range="literal" sort="15j">Subseries statement</property>
	<property name="subseriesEnumeration" range="literal" sort="15k">Subseries enumeration</property>
	<property name="frequency" range="Frequency" sort="17c">Frequency</property>
	<property name="preferredCitation" range="literal" sort="17d">Preferred citation</property>
	<property name="issuance" range="Issuance" sort="17e">Mode of issuance</property>
	<property name="firstIssue" range="literal" sort="17f">Multipart first issue</property>
	<property name="lastIssue" range="literal" sort="17g">Multipart last issue</property>
	<property name="provisionActivity" range="ProvisionActivity" sort="17h">Provision activity</property>
	<property name="copyrightDate" range="literal" sort="17i">Copyright date</property>
	<property name="custodialHistory" range="literal" sort="19c">Custodial history</property>
	<property name="acquisitionTerms" range="literal" sort="19d">Terms of acquisition</property>
	<property name="acquisitionSource" range="AcquisitionSource" sort="19e">Source of acquisition</property>
	<property name="copyrightRegistration" range="CopyrightRegistration" sort="19f">Copyright registration information</property>
	<property name="coverArt" range="CoverArt" sort="19g">Cover art</property>
	<property name="review" range="Review" sort="19h">Review content</property>
	<property name="tableOfContents" range="TableOfContents" sort="19i">Table of contents content</property>
	<property name="extent" range="Extent" sort="21c">Extent</property>
	<property name="dimensions" range="literal" sort="21d">Dimensions</property>
	<property name="baseMaterial" range="BaseMaterial" sort="21e">Base material</property>
	<property name="appliedMaterial" range="AppliedMaterial" sort="21f">Applied material</property>
	<property name="emulsion" range="Emulsion" sort="21g">Emulsion</property>
	<property name="mount" range="Mount" sort="21h">Mount material</property>
	<property name="productionMethod" range="ProductionMethod" sort="21i">Production method</property>
	<property name="generation" range="Generation" sort="21j">Generation</property>
	<property name="layout" range="Layout" sort="21k">Layout</property>
	<property name="bookFormat" range="BookFormat" sort="21l">Book format</property>
	<property name="fontSize" range="FontSize" sort="21m">Font size</property>
	<property name="polarity" range="Polarity" sort="21n">Polarity</property>
	<property name="reductionRatio" range="ReductionRatio" sort="21o">Reduction ratio</property>
	<property name="soundCharacteristic" range="SoundCharacteristic" sort="21p">Sound characteristic</property>
	<property name="projectionCharacteristic" range="ProjectionCharacteristic" sort="21q">Projection characteristic </property>
	<property name="videoCharacteristic" range="VideoCharacteristic" sort="21r">Video characteristic</property>
	<property name="digitalCharacteristic" range="DigitalCharacteristic" sort="21s">Digital characteristic</property>
	<property name="systemRequirement" range="SystemRequirement" sort="21t">Equipment or system requirements</property>
	<property name="enumerationAndChronology" range="EnumerationAndChronology" sort="23c">Numbering or other enumeration and dates associated with issues or items held.</property>
	<property name="heldBy" range="Agent" sort="23d">Held by</property>
	<property name="sublocation" range="Sublocation" sort="23e">Held in sublocation</property>
	<property name="physicalLocation" range="literal" sort="23f">Storing or shelving location</property>
	<property name="shelfMark" range="ShelfMark" sort="23g">Shelf mark</property>
	<property name="electronicLocator" range="rdfs:Resource" sort="23h">Electronic location</property>
	<property name="usageAndAccessPolicy" range="UsageAndAccessPolicy" sort="23j">Use and access condition</property>
	<property name="immediateAcquisition" range="ImmediateAcquisition" sort="23k">Immediate acquisition</property>
	<property name="noteType" range="literal" sort="25c">Note type</property>
	<!-- <property name="relatedTo" range="rdfs:Resource" sort="27b">Related resource</property> -->
	<property name="relatedTo" range="bf:Work" sort="27b">Related resource</property>
	<property name="hasInstance" range="Instance" sort="27c">Has Instance</property>
	<property name="instanceOf" range="Work" sort="27d">Instance of</property>
	<property name="hasExpression" range="Work" sort="27e">Has Expression</property>
	<property name="expressionOf" range="Work" sort="27f">Expression of</property>
	<property name="itemOf" range="Instance" sort="27g">Item of</property>
	<property name="hasItem" range="Item" sort="27h">Has Item</property>
	<property name="eventContent" range="Work" sort="29c">Event content</property>
	<property name="eventContentOf" range="Event" sort="29d">Has event content</property>
	<property name="hasEquivalent" range="Core" sort="29e">Equivalence</property>
	<property name="hasPart" range="Core" sort="29f">Has part</property>
	<property name="partOf" range="Core" sort="29g">Is part of</property>
	<property name="accompaniedBy" range="Core" sort="29h">Accompanied by</property>
	<property name="accompanies" range="Core" sort="29i">Accompanies</property>
	<property name="hasDerivative" range="Work or Instance" sort="29j">Has derivative</property>
	<property name="derivativeOf" range="Work or Instance" sort="29k">Is derivative of</property>
	<property name="precededBy" range="Work or Instance" sort="29l">Preceded by</property>
	<property name="succeededBy" range="Work or Instance" sort="29m">Succeeded by</property>
	<property name="references" range="Core" sort="29n">References</property>
	<property name="referencedBy" range="Core" sort="29o">Referenced by</property>
	<property name="issuedWith" range="Instance" sort="31b">Issued with</property>
	<property name="otherPhysicalFormat" range="Instance" sort="31c">Has other physical format</property>
	<property name="hasReproduction" range="Instance" sort="31d">Reproduced as</property>
	<property name="reproductionOf" range="Instance" sort="31e">Reproduction of</property>
	<property name="dataSource" range="Work or Instance" sort="31f">Data source</property>
	<property name="hasSeries" range="Work or Instance" sort="31g">In series</property>
	<property name="seriesOf" range="Work or Instance" sort="31h">Series container of</property>
	<property name="hasSubseries" range="Work or Instance" sort="31i">Subseries</property>
	<property name="subseriesOf" range="Work or Instance" sort="31j">Subseries of</property>
	<property name="supplement" range="Work or Instance" sort="31k">Supplement</property>
	<property name="supplementTo" range="Work or Instance" sort="31l">Supplement to</property>
	<property name="translation" range="Work or Instance" sort="31m">Translated as</property>
	<property name="translationOf" range="Work or Instance" sort="31n">Translation of</property>
	<property name="originalVersion" range="Work or Instance" sort="31o">Original version</property>
	<property name="originalVersionOf" range="Work or Instance" sort="31p">Original version of </property>
	<property name="index" range="Work or Instance" sort="31q">Has index </property>
	<property name="indexOf" range="Work or Instance" sort="31r">Index to</property>
	<property name="otherEdition" range="Work or Instance" sort="31s">Other edition</property>
	<property name="findingAid" range="Work or Instance" sort="31u">Finding aid</property>
	<property name="findingAidOf" range="Work or Instance" sort="31v">Finding aid for</property>
	<property name="separatedFrom" range="Work or Instance" sort="31wa">Separated from</property>
	<property name="splitInto" range="Work or Instance" sort="31wb">Split into</property>
	<property name="replacementOf" range="Work or Instance" sort="31wc">Preceded by</property>
	<property name="replacedBy" range="Work or Instance" sort="31wd">Succeeded by</property>
	<property name="mergerOf" range="Work or Instance" sort="31we">Merger of</property>
	<property name="mergedToForm" range="Work or Instance" sort="31wf">Merged to form</property>
	<property name="continues" range="Work or Instance" sort="31wg">Continues</property>
	<property name="continuesInPart" range="Work or Instance" sort="31wh">Continues in part</property>
	<property name="absorbed" range="Work or Instance" sort="31wi">Absorption of</property>
	<property name="absorbedBy" range="Work or Instance" sort="31wj">Absorbed by</property>
	<property name="continuedBy" range="Work or Instance" sort="31wk">Continued by</property>
	<property name="continuedInPartBy" range="Work or Instance" sort="31wl">Continued in part by</property>
	<property name="contribution" range="Contribution" sort="03d">Contributor and role</property>
	<property name="role" range="Role" sort="33e">Contributor role</property>
	<property name="assigner" range="Agent" sort="35c">Assigner</property>
	<property name="derivedFrom" range="literal" sort="35d">Source metadata</property>
	<property name="changeDate" range="literal" sort="35e">Description change date</property>
	<property name="creationDate" range="literal" sort="35f">Description creation date</property>
	<property name="descriptionConventions" range="DescriptionConventions" sort="35g">Description conventions</property>
	<property name="descriptionLanguage" range="Language" sort="35h">Description language</property>
	<!-- <property name="generationProcess" range="GenerationProcess" sort="35i">Description generation</property> 
	temp fix literal: -->
	<property name="generationProcess" range="literal" sort="35i">Description generation</property>
	<property name="descriptionModifier" range="Agent" sort="35j">Description modifier</property>
	<property name="descriptionAuthentication" range="DescriptionAuthentication" sort="35k">Description authentication</property>
	<property name="generationDate" range="literal" sort="35l">Date generated</property>
	<property name="adminMetadata" range="AdminMetadata" sort="99a">Administrative metadata</property>
	<property name="authoritativeLabel" range="literal" sort="99a">MADS Auth label</property>
	<property name="componentList" range="Topic" sort="04a">Components</property>
	
	<!-- bflc starts:  -->
	<property name="demographicGroup" range="DemographicGroup" sort="33d">Demographic group</property>
	<property name="creatorCharacteristic" range="CreatorCharacteristic" sort="33">Creator characteristic</property>
	<property name="projectedProvisionDate"  sort="33">Projected publication date</property>
	<property name="metadataLicensor" domain="AdminMetadata" range="MetadataLicensor" sort="33">Metadata licensor</property>
	<property name="encodingLevel" domain="AdminMetadata" range="EncodingLevel" sort="99a" >Encoding level</property>	
	<property name="appliesTo" range="AppliesTo" sort="33">Applies to</property>
	<property name="applicableInstitution" range="Agent">Applicable institution</property>
	<property name="relationship" range="Relationship" sort="33">Related resource and relationship</property>
	<property name="relation" range="rdfs:Resource" sort="33">Specific relationship</property>
	<property name="seriesTreatment" sort="55a">Series treatment</property>
	<property name="consolidates" sort="99a">Consolidates </property>
	<property name="profile" sort="99a"  range="literal">Editor Profile Used </property>
	<property name="procInfo" sort="99a"  range="literal">Processing Information</property>
	<property name="target" sort="99a" >Resource URL</property>
	<property name="catalogerId" sort="99a"  range="literal">Cataloger code </property>
	
	<property name="indexedIn" sort="99a" >Indexed In </property>
	
	<property name="alternateMediumOfPerformance" sort="99a" >Alternate Medium </property>
	<!-- pmo starts -->
	<property name="hasMedium" sort="99a" >has Medium </property>
	<property name="hasDoublingMediumOfPerformance" sort="99a" >Doubling Medium </property>
	<property name="hasMediumPart" sort="99z" >Medium Part </property>
	<property name="hasDistinctPartCount" sort="99a" range="literal" >Distinct Part Count </property>
	<property name="hasMediumOfPerformance" sort="99b" > has Medium Of Performance  </property>
	<property name="hasRequiredPerformerCount" sort="99c" range="literal" >Required Performer Count </property>
	<property name="hasEnsembleCount" sort="99c" range="literal" >Ensemble Count </property>
	<!-- suppress display of marc, match, sort -->
	
</properties>;
declare variable $display:RDFclasses as element () :=
<classes>
<class name="bf:AbbreviatedTitle" subclassof="VariantTitle" sort="13h">Abbreviated title</class>
<class name="bf:AccessPolicy" subclassof="UsageAndAccessPolicy" sort="28l">Access policy</class> 
<class name="bf:AcquisitionSource" subclassof="rdfs:Resource" sort="22c">Acquisition source</class>
<class name="bf:AdminMetadata" subclassof="rdfs:Resource" sort="32c">Administrative metadata</class>
<class name="bf:Agent" subclassof="foaf:Agent" sort="09c">Agent</class>
<class name="bf:Ansi" subclassof="Identifier" sort="30c">ANSI number</class>
<class name="bf:AppliedMaterial" subclassof="rdfs:Resource" sort="24e">Applied material</class>
<class name="bf:Archival" subclassof="Instance" sort="05p">Archival controlled</class>
<class name="bf:Arrangement" subclassof="rdfs:Resource" sort="18d">Organization of material</class>
<class name="bf:AspectRatio" subclassof="rdfs:Resource" sort="18q">Aspect ratio</class>
<class name="bf:Audio" subclassof="Work" sort="05e">Audio</class>
<class name="bf:AudioIssueNumber" subclassof="Identifier" sort="30c">Audio issue number</class>
<class name="bf:AudioTake" subclassof="Identifier" sort="30c">Audio recording take</class>
<class name="bf:Barcode" subclassof="Identifier" sort="30c">Barcode</class>
<class name="bf:BaseMaterial" subclassof="rdfs:Resource" sort="24d">Base material</class>
<class name="bf:BookFormat" subclassof="rdfs:Resource" sort="24k">Book format</class>
<class name="bf:BroadcastStandard" subclassof="VideoCharacteristic" sort="26p">Broadcast standard</class>
<class name="bf:Capture" subclassof="rdfs:Resource" sort="18g">Capture of content</class>
<class name="bf:Carrier" subclassof="rdfs:Resource" sort="11e">Carrier type</class>
<class name="bf:Cartographic" subclassof="rdfs:Resource" sort="18s">Cartographic information</class>
<class name="bf:CartographicDataType" subclassof="DigitalCharacteristic" sort="26qi">Digital cartographic data type</class>
<class name="bf:CartographicObjectType" subclassof="DigitalCharacteristic" sort="26qj">Digital cartographic object type</class>
<class name="bf:Cartography" subclassof="Work" sort="05d">Cartography</class>
<class name="bf:Chronology" subclassof="EnumerationAndChronology" sort="28cb">Chronology</class>
<class name="bf:Classification" subclassof="rdfs:Resource" sort="18t">Classification</class>
<class name="bf:ClassificationDdc" subclassof="Classification" sort="18u">DDC Classification</class>
<class name="bf:ClassificationLcc" subclassof="Classification" sort="18v">LCC Classification</class>
<class name="bf:ClassificationNlm" subclassof="Classification" sort="18x">NLM classification</class>
<class name="bf:ClassificationUdc" subclassof="Classification" sort="18w">UDC Classification</class>
<class name="bf:Coden" subclassof="Identifier" sort="30c">CODEN</class>
<class name="bf:Collection" subclassof="rdfs:Resource" sort="05r">Collection</class>
<class name="bf:CollectiveTitle" subclassof="VariantTitle" sort="13j">Collective title</class>
<class name="bf:ColorContent" subclassof="rdfs:Resource" sort="18o">Color content</class>
<class name="bf:Content" subclassof="rdfs:Resource" sort="11c">Content type</class>
<class name="bf:ContentAccessibility" subclassof="rdfs:Resource" sort="18hb">Content accessibility information</class>
<class name="bf:Contribution" subclassof="rdfs:Resource" sort="09m">Contribution</class>
<class name="bf:CopyrightNumber" subclassof="Identifier" sort="30c">Copyright-legal deposit number</class>
<class name="bf:CopyrightRegistration" subclassof="rdfs:Resource" sort="22ca">Copyright registration</class>
<class name="bf:CoverArt" subclassof="rdfs:Resource" sort="22d">Cover art </class>
<class name="bf:Dataset" subclassof="Work" sort="05h">Dataset</class>
<class name="bf:DescriptionAuthentication" subclassof="AdminMetadata" sort="32f">Metadata authentication</class>
<class name="bf:DescriptionConventions" subclassof="AdminMetadata" sort="32d">Description conventions</class>
<class name="bf:DigitalCharacteristic" subclassof="rdfs:Resource" sort="26qa">Digital characteristic</class>
<class name="bf:Dissertation" subclassof="rdfs:Resource" sort="18e">Dissertation information</class>
<class name="bf:DissertationIdentifier" subclassof="Identifier" sort="30c">Dissertation Identifier</class>
<class name="bf:Distribution" subclassof="ProvisionActivity" sort="20f">Distributor</class>
<class name="bf:Doi" subclassof="Identifier" sort="30c">DOI</class>
<class name="bf:Ean" subclassof="Identifier" sort="30c">EAN</class>
<class name="bf:Electronic" subclassof="Instance" sort="05s">Electronic</class>
<class name="bf:Emulsion" subclassof="rdfs:Resource" sort="24f">Emulsion</class>
<class name="bf:EncodedBitrate" subclassof="DigitalCharacteristic" sort="26qh">Encoded bitrate</class>
<class name="bf:EncodingFormat" subclassof="DigitalCharacteristic" sort="26qd">Encoding format</class>
<class name="bf:Enumeration" subclassof="EnumerationAndChronology" sort="28ca">Enumeration</class>
<class name="bf:EnumerationAndChronology" subclassof="rdfs:Resource" sort="28c">Enumeration and chronology</class>
<class name="bf:Event" subclassof="rdfs:Resource" sort="09l">Event</class>
<class name="bf:Extent" subclassof="rdfs:Resource" sort="24c">Extent</class>
<class name="bf:Family" subclassof="Agent" sort="09e">Family</class>
<class name="bf:FileSize" subclassof="DigitalCharacteristic" sort="26qe">File size</class>
<class name="bf:FileType" subclassof="DigitalCharacteristic" sort="26qc">File type</class>
<class name="bf:Fingerprint" subclassof="Identifier" sort="30c">Fingerprint identifier</class>
<class name="bf:FontSize" subclassof="rdfs:Resource" sort="24l">Font size</class>
<class name="bf:Frequency" subclassof="rdfs:Resource" sort="20c">Frequency</class>
<class name="bf:Generation" subclassof="rdfs:Resource" sort="24i">Generation</class>
<class name="bf:GenerationProcess" subclassof="AdminMetadata" sort="32e">Generation process</class>
<class name="bf:GenreForm" subclassof="rdfs:Resource" sort="11f">Genre/form</class>
<class name="bf:GeographicCoverage" subclassof="rdfs:Resource" sort="18c">Geographic coverage</class>
<class name="bf:GrooveCharacteristic" subclassof="SoundCharacteristic" sort="26f">Groove characteristic</class>
<class name="bf:Gtin14Number" subclassof="Identifier" sort="30c">Global Trade Item Number 14</class>
<class name="bf:Hdl" subclassof="Identifier" sort="30c">Handle</class>
<class name="bf:Identifier" subclassof="rdfs:Resource" sort="07d">Identifier</class>
<class name="bf:Illustration" subclassof="rdfs:Resource" sort="18m">Illustrative content</class>
<class name="bf:ImmediateAcquisition" subclassof="rdfs:Resource" sort="28o">Immediate acquisition</class>
<class name="bf:Instance" subclassof="rdfs:Resource" sort="03d">Instance</class>
<class name="bf:IntendedAudience" subclassof="rdfs:Resource" sort="18cb">Intended audience information</class>
<class name="bf:Isan" subclassof="Identifier" sort="30c">ISAN</class>
<class name="bf:Isbn" subclassof="Identifier" sort="09a">ISBN</class>
<class name="bf:Ismn" subclassof="Identifier" sort="30c">ISMN</class>
<class name="bf:Isni" subclassof="Identifier" sort="30c">ISNI</class>
<class name="bf:Iso" subclassof="Identifier" sort="30c">ISO number</class>
<class name="bf:Isrc" subclassof="Identifier" sort="30c">ISRC</class>
<class name="bf:Issn" subclassof="Identifier" sort="09a">ISSN</class>
<class name="bf:IssnL" subclassof="Identifier" sort="09a">ISSN-L</class>
<class name="bf:Issuance" subclassof="rdfs:Resource" sort="20d">Mode of issuance</class>
<class name="bf:Istc" subclassof="Identifier" sort="30c">ISTC</class>
<class name="bf:Iswc" subclassof="Identifier" sort="30c">ISWC</class>
<class name="bf:Item" subclassof="rdfs:Resource" sort="03e">Item</class>
<class name="bf:Jurisdiction" subclassof="Agent" sort="09g">Jurisdiction</class>
<class name="bf:KeyTitle" subclassof="VariantTitle" sort="13g">Key title</class>
<class name="bf:Language" subclassof="rdfs:Resource" sort="15c">Language</class>
<class name="bf:Layout" subclassof="rdfs:Resource" sort="24j">Layout</class>
<class name="bf:Lccn" subclassof="Identifier" sort="09a">LCCN</class>
<class name="bf:LcOverseasAcq" subclassof="Identifier" sort="30c">LC acquisition program</class>
<class name="bf:Local" subclassof="Identifier" sort="30c">Local identifier</class>
<class name="bf:Manufacture" subclassof="ProvisionActivity" sort="20g">Manufacturer</class>
<class name="bf:Manuscript" subclassof="Instance" sort="05o">Manuscript</class>
<class name="bf:MatrixNumber" subclassof="Identifier" sort="30c">Audio matrix number </class>
<class name="bf:Media" subclassof="rdfs:Resource" sort="11d">Media type</class>
<class name="bf:Meeting" subclassof="Agent" sort="09h">Meeting</class>
<class name="bf:MixedMaterial" subclassof="Work" sort="05m">Mixed material</class>
<class name="bf:Mount" subclassof="rdfs:Resource" sort="24g">Mount</class>
<class name="bf:MovementNotation" subclassof="Notation" sort="18l">Movement notation used</class>
<class name="bf:MovingImage" subclassof="Work" sort="05j">Moving image</class>
<class name="bf:Multimedia" subclassof="Work" sort="05l">Software or multimedia</class>
<class name="bf:MusicDistributorNumber" subclassof="Identifier" sort="30c">Music distributor number</class>
<class name="bf:MusicEnsemble" subclassof="rdfs:Resource" sort="15f">Music ensemble</class>
<class name="bf:MusicFormat" subclassof="rdfs:Resource" sort="18r">Notated music format</class>
<class name="bf:MusicInstrument" subclassof="rdfs:Resource" sort="15e">Musical instrument</class>
<class name="bf:MusicMedium" subclassof="rdfs:Resource" sort="15d">Music medium information</class>
<class name="bf:MusicNotation" subclassof="Notation" sort="18j">Music notation used</class>
<class name="bf:MusicPlate" subclassof="Identifier" sort="30c">Music plate number</class>
<class name="bf:MusicPublisherNumber" subclassof="Identifier" sort="30c">Music publisher number</class>
<class name="bf:MusicVoice" subclassof="rdfs:Resource" sort="15g">Music voice</class>
<class name="bf:Nbn" subclassof="Identifier" sort="30c">NBN</class>
<class name="bf:NotatedMovement" subclassof="Work" sort="05g">Notated movement</class>
<class name="bf:NotatedMusic" subclassof="Work" sort="05f">Notated music</class>
<class name="bf:Notation" subclassof="rdfs:Resource" sort="18h">Notation</class>
<class name="bf:Note" subclassof="rdfs:Resource" sort="07c">Note</class>
<class name="bf:Object" subclassof="Work" sort="05k">Three-dimensional object</class>
<class name="bf:ObjectCount" subclassof="DigitalCharacteristic" sort="26qk">Digital cartographic object count</class>
<class name="bf:Organization" subclassof="Agent" sort="09f">Organization</class>
<class name="bf:ParallelTitle" subclassof="VariantTitle" sort="13i">Parallel title</class>
<class name="bf:Person" subclassof="Agent" sort="09d">Person</class>
<class name="bf:Place" subclassof="rdfs:Resource" sort="09k">Place</class>
<class name="bf:PlaybackChannels" subclassof="SoundCharacteristic" sort="26i">Configuration of playback channels</class>
<class name="bf:PlaybackCharacteristic" subclassof="SoundCharacteristic" sort="26j">Special playback characteristics</class>
<class name="bf:PlayingSpeed" subclassof="SoundCharacteristic" sort="26e">Playing speed</class>
<class name="bf:Polarity" subclassof="rdfs:Resource" sort="24m">Polarity</class>
<class name="bf:PostalRegistration" subclassof="Identifier" sort="30c">Postal registration number</class>
<class name="bf:PresentationFormat" subclassof="ProjectionCharacteristic" sort="26l">Presentation format</class>
<class name="bf:Print" subclassof="Instance" sort="05n">Printed</class>
<class name="bf:Production" subclassof="ProvisionActivity" sort="20i">Producer</class>
<class name="bf:ProductionMethod" subclassof="rdfs:Resource" sort="24h">Production method</class>
<class name="bf:Projection" subclassof="rdfs:Resource" sort="18sb">Projection</class>
<class name="bf:ProjectionCharacteristic" subclassof="rdfs:Resource" sort="26k">Projection characteristic</class>
<class name="bf:ProjectionSpeed" subclassof="ProjectionCharacteristic" sort="26m">Projection speed</class>
<class name="bf:ProvisionActivity" subclassof="rdfs:Resource" sort="20e">Provider </class>
<class name="bf:Publication" subclassof="ProvisionActivity" sort="20h">Publisher</class> 
<class name="bf:PublisherNumber" subclassof="Identifier" sort="30c">Other publisher number</class>
<class name="bf:RecordingMedium" subclassof="SoundCharacteristic" sort="26d">Recording medium</class>
<class name="bf:RecordingMethod" subclassof="SoundCharacteristic" sort="26c">Type of recording</class>
<class name="bf:ReductionRatio" subclassof="rdfs:Resource" sort="24n">Reduction ratio</class>
<class name="bf:RegionalEncoding" subclassof="DigitalCharacteristic" sort="26qg">Regional encoding</class>
<class name="bf:ReportNumber" subclassof="Identifier" sort="30c">Technical report number</class>
<class name="bf:Resolution" subclassof="DigitalCharacteristic" sort="26qf">Resolution</class>
<class name="bf:Retention Policy" subclassof="UsageAndAccessPolicy" sort="28n">Retention policy</class>
<class name="bf:Review" subclassof="rdfs:Resource" sort="22e">Review</class>
<class name="bf:Role" subclassof="rdfs:Resource" sort="07eb">Role</class>
<class name="bf:Scale" subclassof="rdfs:Resource" sort="18rb">Scale</class>
<class name="bf:Script" subclassof="Notation" sort="18i">Script used</class>
<class name="bf:ShelfMark" subclassof="Identifier" sort="28e">Shelf location</class>
<class name="bf:ShelfMarkDdc" subclassof="ShelfMark" sort="28f">DDC call number</class>
<class name="bf:ShelfMarkLcc" subclassof="ShelfMark" sort="28g">LCC call number</class>
<class name="bf:ShelfMarkNlm" subclassof="ShelfMark" sort="28i">NLM call number</class>
<class name="bf:ShelfMarkUdc" subclassof="ShelfMark" sort="28h">UDC call number</class>
<class name="bf:Sici" subclassof="Identifier" sort="30c">SICI</class>
<class name="bf:SoundCharacteristic" subclassof="rdfs:Resource" sort="26b">Sound characteristic</class>
<class name="bf:SoundContent" subclassof="rdfs:Resource" sort="18p">Sound content</class>
<class name="bf:Source" subclassof="rdfs:Resource" sort="07f">Source</class>
<class name="bf:Status" subclassof="rdfs:Resource" sort="07g">Status</class>
<class name="bf:StillImage" subclassof="Work" sort="05i">Still image</class>
<class name="bf:StockNumber" subclassof="Identifier" sort="30c">Stock number</class>
<class name="bf:Strn" subclassof="Identifier" sort="30c">STRN</class>
<class name="bf:StudyNumber" subclassof="Identifier" sort="30c">Study number</class>
<class name="bf:Sublocation" subclassof="rdfs:Resource" sort="28d">Sublocation</class>
<class name="bf:Summary" subclassof="rdfs:Resource" sort="18f">Summary </class>
<class name="bf:SupplementaryContent" subclassof="rdfs:Resource" sort="18n">Supplementary material</class>
<class name="bf:SystemRequirement" subclassof="rdfs:Resource" sort="26ql">System Requirement</class>
<class name="bf:TableOfContents" subclassof="rdfs:Resource" sort="22f">Table of contents</class>
<class name="bf:Tactile" subclassof="Instance" sort="05q">Tactile material</class>
<class name="bf:TactileNotation" subclassof="Notation" sort="18k">Tactile notation used</class>
<class name="bf:TapeConfig" subclassof="SoundCharacteristic" sort="26h">Tape configuration</class>
<class name="bf:Temporal" subclassof="rdfs:Resource" sort="09j">Temporal concept</class>
<class name="bf:Text" subclassof="Work" sort="05c">Text</class>
<class name="bf:Title" subclassof="rdfs:Resource" sort="1">Title </class>
<class name="bf:Topic" subclassof="rdfs:Resource" sort="09i">Topic</class>
<class name="bf:TrackConfig" subclassof="SoundCharacteristic" sort="26g">Track configuration</class>
<class name="bf:Unit" subclassof="rdfs:Resource" sort="07e">Unit</class>
<class name="bf:Upc" subclassof="Identifier" sort="30c">UPC</class>
<class name="bf:Urn" subclassof="Identifier" sort="30c">URN</class>
<class name="bf:UsageAndAccessPolicy" subclassof="rdfs:Resource" sort="28k">Use and access conditions</class>
<class name="bf:UsePolicy" subclassof="UsageAndAccessPolicy" sort="28m">Use policy</class>
<class name="bf:VariantTitle" subclassof="Title" sort="2">Title variation</class>
<class name="bf:VideoCharacteristic" subclassof="rdfs:Resource" sort="26n">Video characteristic</class>
<class name="bf:VideoFormat" subclassof="VideoCharacteristic" sort="26o">Video format</class>
<class name="bf:VideoRecordingNumber" subclassof="Identifier" sort="30c">Video recording number</class>
<class name="bf:Work" subclassof="rdfs:Resource" sort="03c">Work</class>

	<class name="bf:AppliesTo">Applies to</class>
	<class name="bf:EncodingLevel">Encoding level</class>
	<class name="bf:Eidr">EIDR</class>
	<class name="bf:MetadataLicensor" subclassof="Agent">Metadata licensor</class>
	<!--<class name="bf:PrimaryContribution" subclassof="Contribution" sort="02">Primary contribution</class>-->
	<!--<class name="bf:Relation">Relation</class>-->
	
	<class name="bf:DemographicGroup">Demographic group</class>
	<class name="bf:CreatorCharacteristic">Creator characteristic</class>
	<class name="bf:MachineModel" subclassof="SystemRequirement">Model</class>
	<class name="bf:ProgrammingLanguage" subclassof="SystemRequirement">Programming language</class>
	<class name="bf:OperatingSystem" subclassof="SystemRequirement">Operating system</class>
	<class name="bf:ImageBitDepth" subclassof="DigitalCharacteristic">Image bit depth</class>
<!-- bflc: -->
<class name="bflc:PrimaryContribution" subclassof="Contribution" sort="02">Primary contribution</class>
	<!-- auths -->
	<class name="bflc:TransliteratedTitle" sort="01" >Transliterated title</class>
	<class name="bflc:SeriesAnalysis" sort="55a">Series analysis</class> 
	<class name="bflc:SeriesTracing" sort="55a">Series tracing</class>
	<class name="bflc:SeriesClassification" sort="55a">Series classification</class>
	<class name="bflc:SeriesNumbering" sort="55a">Series numbering</class>
	<class name="bflc:SeriesProvider" sort="55a">Series provider</class>
	
	<!-- auths -->
	<class name="bflc:Relationship">Relationship</class>
	<class name="bflc:Relation">Relation</class>
	<!-- madsrdf -->
	<class name="madsrdf:Geographic" namespace="madsrdf" sort="24i">Geographic</class>
<class name="madsrdf:HierarchicalGeographic" namespace="madsrdf" sort="24i">Hierarchical Geographic</class>
<class name="madsrdf:PersonalName" namespace="madsrdf" sort="24i">Name</class>
<class name="madsrdf:ConferenceName" namespace="madsrdf" sort="24i">Conference</class> 
<class name="madsrdf:CorporateName" namespace="madsrdf"  sort="24i">Corporation</class>
<class name="madsrdf:GenreForm" namespace="madsrdf" sort="24i">Genre/Form</class>
<class name="madsrdf:Topic" namespace="madsrdf" sort="24i">Topic</class>
<class name="madsrdf:Temporal" namespace="madsrdf" sort="24i">Temporal</class>
<!-- pmo -->
<class name="pmo:DeclaredMedium" namespace="pmo" sort="24i">Declared Medium</class>
<class name="pmo:MediumPart" namespace="pmo" sort="24i">MediumPart</class>
<class name="pmo:IndividualInstrument" namespace="pmo" sort="24i">Individual Instrument</class>
<class name="pmo:EnsembleMediumOfPerformance" namespace="pmo" sort="24i">Ensemble Medium</class>
<class name="pmo:IndividualMediumOfPerformance" namespace="pmo" sort="24i">Individual Medium</class>
<class name="pmo:IndividualVoice"  namespace="pmo" sort="24i">Individual Voice</class>
<class name="pmo:InstrumentEnsemble"  namespace="pmo" sort="24i">Instrument Ensemble</class> 
<class name="pmo:VoiceEnsemble"  namespace="pmo" sort="24i">Voice Ensemble</class> 

</classes>;
declare variable  $relations :=
	for $prop in $display:Relationships/rel
			return fn:string($prop/name);

declare variable  $ignores :=
	for $prop in $display:Ignores/*			
			return fn:string($prop/@name);

declare variable  $literal-props :=
	for $prop in $display:RDFprops/*[fn:string(@range)="literal"]
			order by $prop/@sort
			return fn:string($prop/@name);

declare variable $props-order:=
		for $prop in $display:RDFprops/*
			order by $prop/@sort
			return fn:string($prop/@name);
declare variable $class-order:=
		for $class in $display:RDFclasses/*
			order by $class/@sort
			return fn:string($class/@name);

(: top level new  MAIN function 
items:
<bf:electronicLocator><rdfs:Resource><bflc:target rdf:resource="http://hdl.loc.gov/loc.pnp/ds.06154"/><bf:note>
<bf:electronicLocator><rdfs:Resource><bflc:target rdf:resource="http://hdl.loc.gov/loc.pnp/ds.06154"/>
http://cdn.loc.gov/service/pnp/ds/06100/06154r.jpg
:)
declare function display:display-rdf($rdf, $indent ) {
(
 if ($rdf instance of element(rdf:RDF)) then
 let $uri:=fn:string($rdf/*[1]/@rdf:about)
 
 let $bgcolor:=if (fn:contains($uri, "works") ) then "SeaGreen" 
			 else if (fn:contains($uri, "instances") ) then "DarkBlue" 
			else "SandyBrown"
			return
    <dl class="record" style="border-style: solid;border-width:4px;border-color:{$bgcolor};" >{
	
			(
			for $i in $rdf//bf:supplementaryContent 
				return display:cover($i),
			for $i in $rdf//bf:electronicLocator/rdfs:Resource[bflc:locator[fn:contains(fn:string(@rdf:resource),'hdl.loc.gov/loc.pnp')]]
				return display:cover($i),			
				for $i in $rdf//bf:electronicLocator/rdfs:Resource[bflc:target[fn:contains(fn:string(@rdf:resource),'hdl.loc.gov/loc.pnp')]]
				return display:cover($i),			
			for $i in $rdf/child::node()
                   			return ( display:display-rdf($i, $indent +10) )
			)}			
			</dl>
		
	else if ($rdf instance of element(bf:Work) or $rdf instance of element(bf:Instance) or $rdf instance of element(bf:Item) or $rdf instance of element(bf:Hub)  ) then
		<div>{display:class($rdf, $indent )		}</div>
		(:<div class="boxed" >{display:class($rdf, $indent )		}</div>:)
			
		else()
) 						

};
(:declare function display:display-rdf-simple($rdf, $indent ) {
( 
 if ($rdf instance of element(rdf:RDF)) then
	(		<dl  class="record" test="nate">{
			(for $i in $rdf//bf:supplementaryContent 
				return display:cover($i),
			for $i in $rdf//bf:electronicLocator[rdfs:Resource/bflc:locator[fn:string(@rdf:resource)='hdl.loc.gov/loc.pnp']]
				return display:cover($i),			
			for $i in $rdf/child::node()
                   			return ( display:display-rdf($i, $indent +10) )
			)}			
			</dl>,

			<div class="boxed">{display:class($rdf/*, $indent )}</div>)
		
	else if ($rdf instance of element(bf:Work) or $rdf instance of element(bf:Instance) or $rdf instance of element(bf:Item) ) then
		<div class="boxed">{display:class($rdf, $indent )}</div>
			
		else()
) 						

};
:)
(: not used?? :)
 declare function display:attributes($rdf ) {
 ( 
 for $a in $rdf/@*
         return
		 		if (fn:name($a)  eq "rdf:resource" and fn:contains(fn:string($a),"ontologies/b")) then
                 (<dt class="label">type</dt>,
				 <dd class="bibdata">{fn:tokenize(fn:string($a),"/")[fn:last()]}</dd>
				 )
                else   if ($a instance of attribute(rdf:about) or $a instance of attribute(rdf:resource) ) then
                 (<dt class="label">{ fn:string($display:RDFprops/property[fn:string(@name)=fn:name($a)])}</dt>,
				 <dd class="bibdata">{fn:string($a)}</dd>
				 )
                    
               else if ($a instance of attribute(rdf:datatype)) then
                  (<dt class="label">Datatype </dt>,
				  <dt class="label">{fn:substring-after(fn:string($a/parent::*), "#")} </dt>)
               else
                 (<dt class="label">{ fn:name($a)}</dt>,
				 <dd class="bibdata">{fn:string($a)}</dd>)
	               )             
};
declare function display:dd-attributes($rdf ) {
 (
 for $a in $rdf/@*
         return

		 	 if ($a instance of attribute(rdf:resource) and fn:contains(fn:string($a),"ontologies/b")) then         
				 <dd class="bibdata">{fn:tokenize(fn:string($a),"/")[fn:last()]}</dd>				 
			(: else   if (($a instance of attribute(rdf:about) or
			 			 $a instance of attribute(rdf:resource)
						 ) and 
						 fn:contains(fn:string($a),"id.loc.gov/")						 
						 
						 ) then    
				 
				 	<dd class="bibdata"><a href="{fn:replace(fn:string($a),$cfg:BF-BASE, $cfg:BF-VARNISH-BASE)}">{fn:string($a)}</a></dd>
					
		:)
			 else   if (($a instance of attribute(rdf:about) or
			 			 $a instance of attribute(rdf:resource) ) and 
						 fn:contains(fn:string($a),"id.loc.gov/") ) then  

					let $link:=fn:replace(fn:string($a),$cfg:BF-BASE, $cfg:BF-VARNISH-BASE)
					let $ajax-link:=fn:concat(fn:replace(fn:string($a),$cfg:ID-BASE,'http://mlvlp04.loc.gov:8287'),'.displaylabel.html')
					let $short-node:=fn:tokenize(fn:string($a),"/")[fn:last()]
					
					return 
						(:<a href="{$link}" displayhref="{xdmp:http-head($a)//*:x-preflabel}" >{ $short-node}</a>															:)
					<dd class="bibdata">								 
						<div>
							<strong class="resolver"></strong>							 
							 <a href="{$link}" displayhref="{$ajax-link}" >{ $short-node}</a>					
						</div>
					</dd>		
                else   if ($a instance of attribute(rdf:about) or $a instance of attribute(rdf:resource) ) then                 
				 <dd class="bibdata"><a href="{fn:replace(fn:string($a),$cfg:BF-BASE, $cfg:BF-VARNISH-BASE)}">{fn:string($a)}</a></dd>
               else if (fn:string($rdf/@rdf:datatype)="http://id.loc.gov/datatypes/edtf") then
                    <dd class="bibdata"><a href="{$rdf/@rdf:datatype}">(EDTF)</a> {fn:string($a/parent::*)}</dd>
               else if ($rdf/@rdf:datatype) then               
				 <dd class="bibdata">({fn:substring-after($rdf/@rdf:datatype,"#")}) {fn:string($a/parent::*)}</dd>
                else 
				 <dd class="bibdata">{fn:string($a/parent::*)}</dd>	
				
)
	                        
};
declare function display:cdn-pnp($link){
	let $grp-item:=fn:substring-after($link,"http://hdl.loc.gov/loc.pnp/")
	let $grp:= fn:tokenize($grp-item,"\.")[1] (: ds :)
	let $item:= fn:tokenize($grp-item,"\.")[fn:last()] (: 06154:)
	let $itemdir:=fn:concat(fn:substring($item,1,3),"00")
	let $size:="r.jpg"

	return  
		fn:concat("http://cdn.loc.gov/service/pnp/",$grp,"/",$itemdir,"/",$item,$size)
};
(: from class with locator or target property:)
declare function display:cover($rdf){
(
	for $c in $rdf[self::* instance of element (bf:SupplementaryContent)][fn:matches(fn:string(bf:note/bf:Note/rdfs:label),"cover", "i")]

		let $link:= ($c/bflc:locator/@rdf:resource | $c/bflc:target/@rdf:resource)[1]
		let $link := if ($link = "" or fn:not($link) and fn:starts-with($c/rdfs:label,"http") ) then
						$c/rdfs:label
					else $link

    return if ($link != "" ) then 
			<img src="{$link}" style="align:right;"  alt="cover image"/>
			else ()
			
			,
	for $ppimage in $rdf[self::* instance of element (rdfs:Resource)]
		
		let $link:= ($ppimage/bflc:locator/@rdf:resource | $ppimage/bflc:target/@rdf:resource)[1]
		let $link:=fn:string($link)
			return if ($link="http://hdl.loc.gov/loc.pnp/pp.print") then
					()
		else

		let $link1 := if ($link = "" or fn:not($link) and fn:starts-with($ppimage/rdfs:label,"http") ) then
						$ppimage/rdfs:label
					else 
						$link
		let $link2:=display:cdn-pnp($link1)
		
		let $label:=if ($ppimage/bf:note/bf:Note/rdfs:label) then
						fn:string($ppimage/bf:note/bf:Note/rdfs:label)
					else
						 "item image"

    	return 
			if ($link != "" ) then 
					<img src="{$link2}" style="align:right;"  alt="{$label}" />
					else ()
			
)
 
};
declare function display:source($rdf, $indent){

(  <dt class="label">{ fn:string($display:RDFclasses/class[@name=fn:name($rdf)]),
                        if ( ($rdf/bf:agent) or ($rdf/rdf:type/@rdf:resource = "http://id.loc.gov/ontologies/bibframe/Agent") ) then
                        " (Agent)"
                        else ()
                        }</dt>,
   				if ($rdf/@rdf:about="http://id.loc.gov/vocabulary/organizations/dlc") then					
                    (:  <a href="http://id.loc.gov/vocabulary/organizations/dlc" displayhref="{xdmp:http-head('http://id.loc.gov/vocabulary/organizations/dlc')//*:x-preflabel}" >DLC</a>
						
					:)
						
					<dd class="bibdata">								
						<div>
							<strong class="resolver">
							</strong>														  
							   <a href="http://id.loc.gov/vocabulary/organizations/dlc" displayhref="http://mlvlp04.loc.gov:8287/vocabulary/organizations/dlc.displaylabel.html" >DLC</a>
						</div>
					</dd>		

                          else if ($rdf/@rdf:about) then
                                   <dd class="bibdata"> {fn:string($rdf/@rdf:about)}</dd>
                          else  if ($rdf/rdf:type/@rdf:resource ="http://id.loc.gov/ontologies/bibframe/Agent" and $rdf/rdfs:label="DLC") then
							(:             	<a href="http://id.loc.gov/vocabulary/organizations/dlc" displayhref="{xdmp:http-head('http://id.loc.gov/vocabulary/organizations/dlc')//*:x-preflabel}">DLC</a>
								<!-- <a href="http://id.loc.gov/vocabulary/organizations/dlc" displayhref="http://mlvlp04.loc.gov:8287/vocabulary/organizations/dlc.displaylabel.html" >DLC</a> -->
							:)
								<dd class="bibdata">								 
									<div>	<strong class="resolver"></strong>
											<a href="http://id.loc.gov/vocabulary/organizations/dlc" displayhref="http://mlvlp04.loc.gov:8287/vocabulary/organizations/dlc.displaylabel.html" >DLC</a>
									</div>
								</dd>		

                                else  if ($rdf/rdf:type/@rdf:resource ="http://id.loc.gov/ontologies/bibframe/Agent" ) then
                                <dd class="bibdata"> {fn:string($rdf/rdfs:label)  }</dd>                       
                           else if ($rdf/bf:agent/bf:Agent/@rdf:about) then
						    	<dd class="bibdata">			{display:linkme($rdf/bf:agent/bf:Agent,"value")}</dd>
								
						  else if (fn:string($rdf/bf:code)!="") then
						  		<dd class="bibdata">{fn:string($rdf/bf:code)}</dd>
						  else <dd class="bibdata">{fn:string($rdf)}</dd>
                        
    			,
    if ($rdf/*[fn:not(self::* instance of element (rdf:type))][fn:not(self::* instance of element (rdfs:label))][fn:not(self::* instance of element (bf:code))][fn:not(self::* instance of element (bf:agent))]) then
	           <dl  style="margin-left: {$indent}px">{
			   (:<dl  class ="boxed" style="margin-left: {$indent}px">{:)
			   display:properties($rdf, $indent ) 
        	       
              	}</dl>
    else ()
   
    )
};
declare  function display:subject($rdf,$indent, $parent){
let $label:=$rdf//*[self::* instance of  element(madsrdf:authoritativeLabel) or self::* instance of  element(rdfs:label)  ][1]

let $label:=if ($label) then 
				$label 
			else if ($rdf/@*) then 
					fn:string($rdf/@*[1]) 
			else	"."
let $topictype:=fn:string($display:RDFclasses/class[@name=fn:name($rdf) ]) 

	return ( 
		 <dt class="label">{
							if ($topictype!="Topic" and $parent!="genreForm" and  $topictype!="Genre/Form")  then 
										fn:concat("Topic (",$topictype,")" ) 
							else	$topictype
							}</dt>,
	       <dd class="bibdata"> { 
					 			display:linkme($rdf,"value")	                          		
	                              }
			</dd>,    
		   if ($rdf/madsrdf:componentList) then 	        
		           <dl style="margin-left: {$indent}px">{
				   (:<dl  class ="boxed" style="margin-left: {$indent}px">{:)
	        	        for $i in $rdf/madsrdf:componentList/*
	        				order by index-of($class-order,fn:local-name($i))
	                           	return ( display:class($i, $indent +10) )
	              	}</dl>
            
		   else ()	   
	    )
};
declare  function display:link2issn($rdf,$indent){
let $issn:=fn:string($rdf/rdf:value)
let $issn-portal-link:=fn:concat("https://issn.org/resource/ISSN/",$issn)

return
(  <dt class="label">{if ( $rdf/rdf:type) then  								
								for $type in $rdf/rdf:type[1] 
									return display:linkme($type,"label")
									
						else
						 			fn:string($display:RDFclasses/class[@name=fn:name($rdf)]) 
						}
						
						</dt>,
	        
			<dd class="bibdata"> {  
									(
									display:linkme($rdf,fn:local-name($rdf)),
									
									if ($issn) then
										<img src="static/lds/images/externallink.png" alt="el" width="10" height="10"/>
									else ()
									)
	                            } 
								
	        </dd>,    
		   if ($rdf/*[fn:not(index-of($ignores,fn:name(self::*)))]) then
		   				(:and fn:not(self::* instance of element (rdf:type)) and fn:not(self::* instance of element (bf:mainTitle))][ fn:not(self::* instance of element (rdfs:label))]) then:)
		        display:properties($rdf,$indent)	
            
		   else ()	   
	    )
};
declare  function display:title($rdf,$indent){
  
  (  <dt class="label">{if ( fn:name($rdf)="bf:Title" and  ( not($rdf/rdf:type) or $rdf/rdf:type="http://id.loc.gov/ontologies/bibframe/Title") ) then  																						
							fn:string($display:RDFclasses/class[@name=fn:name($rdf)]) 
							(:="http://www.loc.gov/mads/rdf/v1#CorporateName":)
						else if ($rdf instance of element(madsrdf:Authority) and $rdf/rdf:type[contains(fn:string(@rdf:resource),"#")]) then
										fn:tokenize(fn:string( $rdf/rdf:type/@rdf:resource		)	,"#")[fn:last()		]									
						else if ($rdf instance of element(madsrdf:Authority) and $rdf/rdf:type[contains(fn:string(@rdf:resource),"/")]) then
										fn:tokenize(fn:string( $rdf/rdf:type/@rdf:resource		)	,"/")[fn:last()		]	
						else  if ( fn:name($rdf)!="bf:Title") then  															
									 fn:string($display:RDFclasses/class[@name=fn:name($rdf)]) 

						else if ( fn:name($rdf)="bf:Title" and   $rdf/rdf:type!="http://id.loc.gov/ontologies/bibframe/Title") then  								  							
									for $type in $rdf/rdf:type[1] 
									return display:linkme($type,"label")  	
																
						else
						( 			fn:string($display:RDFclasses/class[@name=fn:name($rdf)]) )
						}
						</dt>,
	        
			<dd class="bibdata"> {  if (fn:string($rdf/bf:mainTitle)!="") then
	                               			fn:string($rdf/bf:mainTitle)
									else if ($rdf[self::* instance of element(bf:Agent) or  self::* instance of element(madsrdf:CorporateName) ] and fn:contains(fn:string($rdf/@rdf:about),"example.org") ) then
												(display:linkme($rdf,"value"))
												
									else if ($rdf[self::* instance of element(bf:Agent) ] and $rdf/@rdf:about) then
												(display:linkme($rdf,"value") )												  (: was "label":)
	                                else  if($rdf/rdfs:label)  then
								   			<strong>{fn:string($rdf/rdfs:label)}</strong> 
								    else "[blank]"
	                            }
	        </dd>,    
		   if ($rdf/*[fn:not(index-of($ignores,fn:name(self::*)))]) then
		   				(:and fn:not(self::* instance of element (rdf:type)) and fn:not(self::* instance of element (bf:mainTitle))][ fn:not(self::* instance of element (rdfs:label))]) then:)
		        display:properties($rdf,$indent)	
            
		   else ()	   
	    )
};
(: NEW:: replace all links with this!
:  this takes a node with either rdf:about or rdf:resource and links to it (displaying the final node after /:)
(:  if ($rdf/@rdf:resource or $rdf/@rdf:about) 
:	now accounts for varnish cache instead of ID link
:)

declare function display:linkme($node, $displaytype) {

let $issn:= if (fn:contains($displaytype,"Issn")) then
		fn:string($node/rdf:value)
		else ()
let $issn-portal-link:= if (fn:contains($displaytype,"Issn")) then
			fn:concat("https://issn.org/resource/issn/",$issn)
			else ()

let $url:= fn:string($node/@rdf:*[1])
	
let $link:= if (fn:contains($url,"id.loc.gov/resources/")) then
				fn:replace($url,$cfg:BF-BASE, $cfg:BF-VARNISH-BASE)
			else if (fn:contains($displaytype,"Issn")) then
					$issn-portal-link
			else
				$url
let $shortnode:=fn:tokenize($link,"/")[fn:last()]

let $link:=if (fn:contains($link,"id.loc.gov/vocabulary/organizations")) then
					fn:lower-case($link)
			else $link

let $label:= if (fn:not( fn:contains($displaytype,"Issn"))) then
				fn:string($node/rdfs:label[@xml:lang='eng' or not(@xml:lang)][1])
			else $issn

let $label:=if ($label!="") then 
				$label
			else if ($node/madsrdf:authoritativeLabel) then
					$node/madsrdf:authoritativeLabel[1]
			else if ($node/bf:code) then
					$node/bf:code[1]
			else if ($node/bf:value) then
					fn:string($node/rdf:value[1])
			else if (fn:starts-with($url, "http://id.loc.gov/ontologies/") ) then
						fn:tokenize($url,"/")[fn:last()]
			else if (fn:starts-with($url, "http://www.loc.gov/mads/rdf/v1") ) then												
						fn:tokenize($url,"#")[fn:last()]
			else	
						$url
(: don't look up display labels of labels for ontol/bf  until i get it working :)
let $ajax-link:= if (fn:contains($link,"id.loc.gov/")  and $displaytype ne "label") then
						fn:concat(	fn:replace($link, "id.loc.gov","mlvlp04.loc.gov:8287"),".displaylabel.html") 
				    else ()


let $display-label:=
				 if ($displaytype="plain-url") then
						<a href="{fn:replace(fn:string($link),$cfg:ID-BASE, $cfg:BF-BASE)}">{$label	}</a>
				  else if  (fn:not($url) or $url="") then
						$label
				 else if  (fn:contains($url,"example.org")) then
					$label
				else if  (fn:matches($url,"(works|instances)" ) ) then
					$label
				else if ($link and $ajax-link) then					
				(:<!-- <a href="{$link}" displayhref="{<div>{fn:string(xdmp:http-head($link)//*:x-preflabel)}</div>}" > {$shortnode}</a>							 
				<a href="{$link}" displayhref="{$ajax-link}" > {$shortnode}</a>-->:)
					(
					<div>
							<strong class="resolver"></strong>
						<a href="{$link}" displayhref="{$ajax-link}" > {$shortnode}</a>	
							 
							
					</div>					)
				else if ($link ) then
				
					<a href="{$link}">{	($label	)}</a>
				else $label

	return 	$display-label
											
};
(:
declare function display:class-simple($rdf, $indent){

let $css-class:=if ($rdf instance of element (bf:AdminMetadata ) ) then "boxed" else "blanknode"
let $result:= (<dt class="label" >{

						if ($rdf/rdf:type) then
									for $type in $rdf/rdf:type[@rdf:resource]
										return (display:linkme($type,"label"), " ")
								else
						 			fn:string($display:RDFclasses/class[@name=fn:name($rdf)]) }</dt>,
									 <dd class="bibdata">{if ($rdf/rdf:type) then	                            	
	                             	<br/>		
								
								   else if (fn:string($rdf/rdf:value)!="") then
	                               	fn:string($rdf/rdf:value)
	                              else  if ($rdf/@rdf:resource or $rdf/@rdf:about) then
	                                   
										display:linkme($rdf,"value")
	                              else if (fn:string($rdf/rdfs:label[1])!="") then
								  	fn:string($rdf/rdfs:label[1])								
								  else if ($rdf instance of element(bf:Language)  and $rdf/bf:identifiedBy) then
								  		(:action happens below :)
											<br/>										
								  else  <br/>																		
	                            }
	        </dd>,
            		   		
				 if ($rdf/*[fn:not(index-of(ignores,fn:local-name(self::*)) )]) then
						display:properties($rdf,$indent)	        	            
		   else ()	   

	    )
		

return
	if (count($result) > 2) then
		<dl  class ="{$css-class}" style="margin-left: {$indent}px">{
		if ($css-class!="boxed") then 
				<div class="facet-box"><div class="title hidden">{$result}<h3 id="title-facet-1">test</h3>{$result}</div></div>
			else
				$result			
  		}</dl>
	else 
			$result	

};
:)
declare function display:class($rdf, $indent){
(: bflc:Relationship:)
let $css-class:=if ($rdf instance of element (bf:AdminMetadata ) ) then "boxed" else "blanknode"
let $width:= (100 - $indent )
let $result:=
	if ($rdf instance of element(bf:Source) ) then
	    if (fn:string($rdf/@rdf:about)="http://id.loc.gov/vocabulary/languages"  and 
			fn:starts-with($rdf/ancestor::bf:Identifier/rdf:value/@rdf:resource,"http://id.loc.gov/vocabulary/languages")) then
	        ()
	    else 
	        display:source($rdf, $indent)		
	else if ($rdf instance of element(bf:Issn) or $rdf instance of element(bf:IssnL)) then
			display:link2issn($rdf, $indent)

	else if ($rdf/rdf:type[1][@rdf:resource="http://www.loc.gov/mads/rdf/v1#ComplexSubject"] or
			$rdf/rdf:type[1][@rdf:resource="http://www.loc.gov/mads/rdf/v1#Topic"] or
			$rdf/self::* instance of element(bf:GenreForm) or
			$rdf/self::* instance of element(madsrdf:GenreForm)  
			) then
	    		display:subject($rdf,$indent, fn:local-name($rdf/parent::*))    
	
	else if ($rdf instance of element(bf:Title) or
			 $rdf instance of element(bf:ParallelTitle) or
			 $rdf instance of element(bf:AbbreviatedTitle) or
			 $rdf instance of element(bflc:TransliteratedTitle) or
			 $rdf instance of element(bf:VariantTitle) or
			 $rdf instance of element(bf:KeyTitle) or
			 $rdf instance of element(bf:CollectiveTitle) or			 			
			 $rdf instance of element(madsrdf:CorporateName) or		
			 $rdf instance of element(madsrdf:Authority)  or
			  $rdf instance of element(bf:Organization)  or
			 $rdf instance of element(bf:Agent) ) then
	    		display:title($rdf,$indent) 
	
		else
		    (  <dt class="label">{if ($rdf/rdf:type) then
									for $type in $rdf/rdf:type[@rdf:resource]
										return (display:linkme($type,"label"), " ")
								else if (fn:name($rdf) = "rdfs:Resource" and fn:name($rdf/parent::*) = "bf:supplementaryContent") then
									fn:string($display:RDFclasses/class[@name="bf:SupplementaryContent"]) 
								else
						 			fn:string($display:RDFclasses/class[@name=fn:name($rdf)])
							 }</dt>,
	        <dd class="bibdata">{if ($rdf/rdf:type) then	                            	
	                             	<br/>		
								  else 	  (:compensating for bad rdf:)
								   if ($rdf/rdf:value/@rdf:resource) then
	                               	display:linkme($rdf/rdf:value,"value")
								   else if (fn:string($rdf/rdf:value)!="") then
	                               	fn:string($rdf/rdf:value)
									(: why do  I need this? Instance works correctly w/o it :)
	                              else  if ($rdf instance of element(bf:Item) and  	$rdf/@rdf:about) then
	                                    fn:string($rdf/@rdf:about)
								  else  if ($rdf/@rdf:resource or $rdf/@rdf:about) then
	                                   
										display:linkme($rdf,"value")
										
	                              else if (fn:string($rdf/rdfs:label[1])!="") then
								  	fn:string($rdf/rdfs:label[1])								
								  else if ($rdf instance of element(bf:Language)  and $rdf/bf:identifiedBy) then
								  		(:action happens below :)
											<br/>										
								  else  <br/>																								
	                            }
	        </dd>,
            		   		
				 if ($rdf/*[fn:not(index-of($ignores,fn:local-name(self::*)) )]) then
						display:properties($rdf,$indent)	        	
            
		   else ()	   
	    )

return
	if (count($result) > 2) then
(:		<dl  class ="{$css-class}" style="margin-left: {$indent}px">{:)
			if ($rdf instance of element (bf:AdminMetadata ) )  then 
				<div class="facet-box " style="margin-left: {$indent}px; width:90%">
					<div class="title " >
					<h3 id="title-facet-1" class="title-name">Admin Metadata</h3>
					<a class="title-toggle" href="javascript:initFacetToggles();">
						<img id="toggle-facet-1" src="/static/lds/images/accordion-closed.png" alt="Toggle"/>
					</a><br class="break"/>
					</div><!-- title -->
					<div class="content" id="facet-1" style="display: none;">
							 <dl  id="facet-1" class ="{$css-class}" style="margin-left: {$indent}px;">{$result}</dl>	
							 				</div>	
					</div>
			else
				<dl style="margin-left: {$indent}px;margin-right: {$indent}px;">{$result}</dl>
				(:<dl  class ="{$css-class}" style="margin-left: {$indent}px;margin-right: {$indent}px;">{$result}</dl>:)
  		
	else 
			$result	
			
  		
};
(: not used yet :)
(:
declare function display:properties-simple($rdf-block, $indent ) {

for $rdf in $rdf-block/*[fn:not(index-of($ignores,fn:name(self::*)))]
        				order by index-of($props-order,fn:local-name($rdf))
return                        

  if ( index-of($literal-props, fn:local-name($rdf) ) ) then
                if ($rdf instance of element(rdfs:label) and ( $rdf/parent::bf:Title or  $rdf/parent::bf:Work or $rdf/parent::bf:Topic ) ) then
                        <br/>
                else
				    (<dt class="label">{ fn:string($display:RDFprops/property[@name=fn:local-name($rdf)]) }</dt>,
				    <dd class="bibdata">{if (fn:string($rdf)!="") then fn:string($rdf) else <br/> }</dd>
				    )	
else (:rdf:resource :)
			(<dt class="label">{ fn:string($display:RDFprops/property[@name=fn:local-name($rdf)]) }</dt>,
			<dd class="bibdata"> {
					 display:linkme($rdf,"value")
										}</dd>

	)
};
:)
declare function display:properties($rdf-block, $indent ) {

(:$display:Relationships/set/rel/name :) 

for $rdf in $rdf-block/*[fn:not(index-of($ignores,fn:name(self::*)))]
						[fn:not(index-of($relations,fn:local-name(self::*))   )]
        				order by index-of($props-order,fn:local-name($rdf))
return                        

( 
if ($rdf instance of element (bf:instanceOf) or
	 $rdf instance of element (bflc:itemOf)  or 
	 $rdf instance of element (bf:itemOf) or 
	$rdf instance of element (bflc:consolidates) or
	$rdf instance of element (lclocal:consolidates) or
	$rdf instance of element (bf:hasPart) or 
	$rdf instance of element (bf:translationOf) or 
	$rdf instance of element (bf:hasItem) or 
	(:$rdf instance of element (bf:expressionOf) or 
	$rdf instance of element (bf:hasExpression) or :)
	$rdf instance of element(bflc:derivedFrom)  	or  
	(:$rdf instance of element (bf:relatedTo) or:)
	fn:starts-with(fn:name($rdf), "lclocal:")
	 or  ($rdf instance of element (bf:relatedTo) and not($rdf/parent::* instance of element (bflc:Relationship)))
 ) then
        ()
    
    else if ( ( $rdf instance of element (bf:subject) 	and $rdf/*)
	 )  then
		display:subject($rdf/*,$indent, fn:local-name($rdf/self::*))
	else if ($rdf instance of element (bf:geographicCoverage)) then
	(<dt class="label">{ fn:string($display:RDFprops/property[@name=fn:local-name($rdf)]) }</dt>,
      <dd class="bibdata"> { if ( $rdf/@rdf:resource ) then
		 							display:linkme($rdf,"value")
									else if ( $rdf/*/@rdf:about ) then
										display:linkme($rdf/child::*[1],"value")
		 						else  
									fn:string-join($rdf/*," ")
									 
							}</dd>)
	(: data property ( resource uri ) :)
  	else if ( $rdf/@rdf:resource  or $rdf/@rdf:about or $rdf/@rdf:datatype )  then
				(<dt class="label">{ fn:string($display:RDFprops/property[@name=fn:local-name($rdf)]) }</dt>,
				   display:dd-attributes($rdf), " ",
				   for $i in $rdf/*
							order by index-of($class-order,fn:local-name($i))
	                   			return  if ($rdf instance of element(bf:adminMetadata) )  then
	                   			             (:<div class="boxed">{display:class($i, $indent +10)}</div>:)
											 <div >{display:class($i, $indent +10)}</div>
	                   			          else
	                   			             ("123",display:class($i, $indent +10) )					)
	(: literal property :)			                       
  else if ( index-of($literal-props, fn:local-name($rdf) ) ) then
                if ($rdf instance of element(rdfs:label) and ( $rdf/parent::bf:Title or  $rdf/parent::bf:Work   or  $rdf/parent::bf:Hub or $rdf/parent::bf:Topic ) ) then
                        <br/>
                else
				    (<dt class="label">{ fn:string($display:RDFprops/property[@name=fn:local-name($rdf)]) }</dt>,
				    <dd class="bibdata">{if (fn:string($rdf)!="") then fn:string($rdf) else <br/> }</dd>
				    )	
  else if ($rdf/bf:Work[@rdf:about]) then 
              (<dt class="label">{ fn:string($display:RDFprops/property[@name=fn:local-name($rdf)]) }</dt>,
			  
				 <dd class="bibdata"> (Work) { display:linkme($rdf/bf:Work,"plain-url")}</dd>,
				 (:<div class="boxed">{display:class($rdf/bf:Work, $indent+5 )}</div>:)
				 <div >{display:class($rdf/bf:Work, $indent+5 )}</div>
				)
  (: blank node property or text related? :)
  else if ($rdf/bf:Work) then 
              (<dt class="label">{ fn:string($display:RDFprops/property[@name=fn:local-name($rdf)]) }</dt>,
				 <dd class="bibdata"> (Work) </dd>,
				 <div>{display:class($rdf/bf:Work, $indent+5 )}</div>
				 (:<div class="boxed">{display:class($rdf/bf:Work, $indent+5 )}</div>:)
				)
	else if ($rdf/bf:Hub) then 
              (<dt class="label">{ fn:string($display:RDFprops/property[@name=fn:local-name($rdf)]) }</dt>,
				 <dd class="bibdata"> (Hub) </dd>,
				 <div>{display:class($rdf/bf:Hub, $indent+5 )}</div>
				 
				)
  else if ($rdf/bf:Instance) then 
              (<dt class="label">{ fn:string($display:RDFprops/property[@name=fn:local-name($rdf)]) }</dt>,
				 <dd class="bibdata"> (Instance) </dd>,
				 <div >{display:class($rdf/bf:Instance, $indent+5 )}</div>
				 (:<div class="boxed">{display:class($rdf/bf:Instance, $indent+5 )}</div>:)
				)
	else if ($rdf/bf:Item) then 
              (<dt class="label">{ fn:string($display:RDFprops/property[@name=fn:local-name($rdf)]) }</dt>,
				 <dd class="bibdata"> (Item) </dd>,
				 <div>{display:class($rdf/bf:Item, $indent+5 )}</div>
				 (:<div class="boxed">{display:class($rdf/bf:Item, $indent+5 )}</div>:)
				)
	
  else if ($rdf instance of element(bf:identifiedBy)  ) then
         display:class($rdf/child::*[1], $indent +10 )
 
 else  if ($rdf instance of element(bf:descriptionModifier) or 
			 $rdf instance of element(bflc:applicableInstitution) or			 
			 $rdf instance of element(bf:heldBy)
			  )   then
	    (<dt class="label">{ fn:string($display:RDFprops/property[@name=fn:local-name($rdf)]) } (Agent)</dt>,

         <dd class="bibdata"> {
		 
									display:linkme($rdf/child::*[1],"value")
							}</dd>)
 else if ($rdf instance of element(bf:title)) then
 		( display:class($rdf/*, $indent+5 ))
		
 else  if ($rdf instance of element(bflc:encodingLevel)  or
			 $rdf instance of element(bf:descriptionConventions ) or 
			 $rdf instance of element(bf:status )  or 
			 $rdf instance of element(bf:mediaType )  or 
			 ($rdf instance of element(bf:genreForm)  and fn:not($rdf/*/@*) )  or			 
			 $rdf instance of element(bf:note )   
		  ) then
	    (<dt class="label">{ if (fn:not($rdf/bf:Note/bf:noteType)) then 
								fn:string($display:RDFprops/property[@name=fn:local-name($rdf)]) 
							else
								fn:string($rdf/bf:Note/bf:noteType)
			}</dt>,
         <dd class="bibdata">{
							 (if ($rdf/*/@rdf:about) then
							 	display:linkme($rdf/child::*[1],"value")
									
								else
								(
							 		fn:string($rdf/*/bf:code),
							 	
									if ($rdf/*/bf:code and $rdf/*/rdfs:label ) then ": " else (),
							 	
									for $label in $rdf/*/rdfs:label 
										return fn:string($label)
								)
							 ,(: is this really needed?? :)
							 if ($rdf/madsrdf:componentList) then 	        
						           <dl  style="margin-left: {$indent}px;background-color: 'coral';">{
								   (:<dl  class ="boxed" style="margin-left: {$indent}px;background-color: 'coral';">{:)
					        	        for $i in $rdf/madsrdf:componentList/*
					        				order by index-of($class-order,fn:local-name($i))
					                           	return ( display:class($i, $indent +10) )
					              	}</dl>
					  		else ()
				
            
		
		   )
			}
		</dd>)        			          
 else if (fn:not(index-of( $props-order, fn:local-name($rdf) )) ) then
 		(<dt class="label">3{fn:name($rdf)}</dt>,
 		 <dd class="bibdata">{if (fn:string($rdf)) then fn:string($rdf) else display:linkme($rdf, "value")}</dd>
		)
		(: need to fix: why is this property not selected above someplace? bflc??? :)
else if ($rdf  instance of element(bflc:relation )) then
		(<dt class="label"> Role</dt>,
 		 <dd class="bibdata">{$rdf/*/rdfs:label}</dd>
		)
 else for $i in $rdf/*
 		order by index-of($class-order,fn:local-name($i))
return 	 		display:class($i, $indent+5 ))
				
				
}; 
(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios ><scenario default="yes" name="Scenario1" userelativepaths="yes" externalpreview="no" useresolver="no" url="" outputurl="" processortype="internal" tcpport="0" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" host="" port="0" user="" password="" validateoutput="no" validator="internal" customvalidator=""/></scenarios><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)