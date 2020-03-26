xquery version "1.0-ml";

module namespace cfg = "http://www.marklogic.com/ps/config";
declare namespace mlapp = "http://www.marklogic.com/mlapp";
declare namespace e = "http://marklogic.com/entity";
declare namespace gml = "http://www.opengis.net/gml";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "lib/l-param.xqy";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare variable $META-TITLE := "BIBFRAME Database (beta): Search Library of Congress BIBFRAME Descriptions";
declare variable $ADMIN-EMAIL := "bibframepilot@loc.gov";
declare variable $BLANK-SEARCH-STUB-TEXT := "Enter search word(s)";
declare variable $DEFAULT-POLYGON-ROI as cts:polygon := cts:polygon((cts:point(39, -21), cts:point(39, 55), cts:point(-38, 55), cts:point(-38, -21)));
declare variable $BLANK-SEARCH-STUB-JS := fn:concat('var defaultsearchtext = "', $BLANK-SEARCH-STUB-TEXT, '";');
declare variable $RESULTS-PER-PAGE as xs:integer := 10;
declare variable $SPARQL-LIMIT as xs:integer := 25;

declare variable $FACETS-PER-BOX as xs:integer := 15;
declare variable $FACET-YEARS-BACK as xs:integer := 5;
declare variable $MORE-COLUMN-COUNT as xs:integer := 5;
declare variable $MORE-COLUMN-LENGTH as xs:integer := $FACETS-PER-BOX * 12;
declare variable $SHOW-ZERO-COUNT-FACETS as xs:boolean := fn:false();
declare variable $SHOW-WHOAMI as xs:boolean := fn:false();
declare variable $CACHE-FACETS as xs:boolean := fn:false();
declare variable $HTTP_EXPIRES_CACHE := xs:dayTimeDuration("PT12H");
(:if you look up links at id  using the preprocessing varnish, the result will be thehost name and port  $ID-LOOKUP-CACHE-BASE , which needs to be converted to ID-BASE :)
declare variable $ID-VARNISH-BASE := "http://idwebvlp03.loc.gov";
declare variable $ID-LOOKUP-CACHE-BASE := "http://mlvlp04.loc.gov:8080";
declare variable $ID-BASE := "http://id.loc.gov";

declare variable $BF-VARNISH-BASE := "http://idwebvlp03.loc.gov:8230";
declare variable $BF-BASE := "http://mlvlp04.loc.gov:8230";

declare variable $HOST-NAME := xdmp:host-name(xdmp:host());
(:~
:   This variable is used by the app to determine whether it is
:   in production or development. (from id-main)
:)
declare variable $cfg:DEBUG as xs:boolean := fn:true();

declare variable $DISPLAY-SUBDOMAIN :=
(:2016 07 13 nate changed from marklogic3:)
    if (fn:contains($cfg:HOST-NAME, "mlvlp04")) then
        (:$cfg:HOST-NAME:) "mlvlp04.loc.gov:8230"
    else
        fn:replace($cfg:HOST-NAME, "marklogic\d", "loccatalog", "m");

declare variable $DEFAULT-BRANDING as xs:string :="lds" ;
(:2016 07 13 nate NOT changed from marklogic3 to mlvlp04; maybe later.... :)
declare variable $DEFAULT-COLLECTION as xs:string :=
    if (fn:contains($cfg:HOST-NAME, "mlvlp04")) then
         "/catalog/"
    else
        "/catalog/";

(:site branding is used to get the label for html head, crumbs, etc:)
declare variable $SITES as node() :=
  <sites xmlns="http://www.marklogic.com/ps/config">
        <site> <!--test version of ml1-->
            <branding>lds</branding>
            <label>BIBFRAME Database</label>
			<prefix>/lds/</prefix>
			<collection>/catalog/</collection> <!--translates to /catalog on ml1, /lscoll on ml3-->
        </site>
		<site> <!--everything on ML3: test or dev -->
            <branding>lscoll</branding>
            <label>Library Services Collections</label>
			<prefix>/lscoll/</prefix>
			<!--<collection>all</collection>--> <!--translates to /catalog on ml1, /lscoll on ml3-->
			<collection>/lscoll/</collection>
        </site>
		 <site>
            <branding>tohap</branding>
            <label>Tibetan Oral History and Archive Project (TOHAP)</label>
			<prefix>/tohap/</prefix>
			<collection>/lscoll/tohap/</collection>
        </site>
		<site>
            <branding>lcwa</branding>
            <label>Library of Congress Web Archives</label>
			<collection>/lscoll/lcwa/</collection>
			<prefix>/lcwa/</prefix>
        </site>		
		<site>
            <branding>lcwa0002</branding>
           <label>United States 107th Congress Web Archive</label>
			<collection>/lscoll/lcwa/lcwa0002/</collection>
			<prefix>/lcwa0002/</prefix>
			<image-url>/static/natlibcat/images/107th.jpg</image-url>
			<subsite branding="lcwa"/>
        </site>	
		<site>
            <branding>lcwa0003</branding>
            <label>Iraq War, 2003 Web Archive</label>
			<collection>/lscoll/lcwa/lcwa0003/</collection>
			<prefix>/lcwa0003/</prefix>
			<image-url>/static/natlibcat/images/iraq-map.gif</image-url>
			<subsite branding="lcwa"/>
        </site>		
	<site>
		<branding>lcwa0011</branding>
		<label>Crisis in Darfur, Sudan, Web Archive, 2006</label>
		<prefix>/lcwa0011/</prefix>
		<collection>/lscoll/lcwa/lcwa0011/</collection>
		<subsite branding="lcwa"/>
	</site>
	<site>
		<branding>lcwa0015</branding>
		<label>Law Library Legal Blawgs Web Archive</label>
		<prefix>/lcwa0015/</prefix>
		<collection>/lscoll/lcwa/lcwa0015/</collection>
		<subsite branding="lcwa"/>
	</site>
	<site>
		<branding>lcwa0012</branding>
		<label>Library of Congress Manuscript Division Archive of Organizational Web Sites</label>
		<prefix>/lcwa0012/</prefix>
		<collection>/lscoll/lcwa/lcwa0012/</collection>
		<subsite branding="lcwa"/>
		</site>
	<site>
		<branding>lcwa0010</branding>
		<label>Papal Transition 2005 Web Archive</label>
		<prefix>/lcwa0010/</prefix>
		<collection>/lscoll/lcwa/lcwa0010/</collection>
		<subsite branding="lcwa"/>
	</site>
	<site>
		<branding>lcwa0000</branding>
		<label>United States Elections Web Sites</label>
		<prefix>/lcwa0000/</prefix>
		<collection>/lscoll/lcwa/lcwa0000/</collection>
		<subsite branding="lcwa"/>
	</site>	
	<!--<site>
		<branding>lcwa0001</branding>
		<label>September 11th, 2001 Web Archive</label>
		<prefix>/lcwa0001/</prefix>
		<collection>/lscoll/lcwa/lcwa0001/</collection>
	</site>-->
	<site>
		<branding>lcwa0013</branding>
		<label>Single Sites Web Archive</label>
		<prefix>/lcwa0013/</prefix>
		<collection>/lscoll/lcwa/lcwa0013/</collection>
		<subsite branding="lcwa"/>
	</site>
	<site>
		<branding>lcwa0005</branding>
		<label>United States 108th Congress Web Archive</label>
		<prefix>/lcwa0005/</prefix>
		<collection>/lscoll/lcwa/lcwa0005/</collection>
		<subsite branding="lcwa"/>
	</site>
	<site>
		<branding>lcwa0007</branding>
		<label>Election 2000 Web Archive</label>
		<prefix>/lcwa00##/</prefix>
		<collection>/lscoll/lcwa/lcwa0007/</collection>
		<image-url>/static/natlibcat/images/elec2000.gif</image-url>
		<subsite branding="lcwa"/>
	</site>
	<site>
		<branding>lcwa0006</branding>
		<label>Election 2002 Web Archive</label>
		<prefix>/lcwa0006/</prefix>
		<collection>/lscoll/lcwa/lcwa0006/</collection>
		<image-url>/static/natlibcat/images/elec2002.gif</image-url>
		<subsite branding="lcwa"/>
	</site>

	<site>
		<branding>lcwa0016</branding>
		<label>Election 2004 Web Archive</label>
		<prefix>/lcwa0016/</prefix>
		<collection>/lscoll/lcwa/lcwa0016/</collection>
		<subsite branding="lcwa"/>
	</site>

	<site>
		<branding>lcwa0017</branding>
		<label>Election 2006 Web Archive</label>
		<prefix>/lcwa0017/</prefix>
		<collection>/lscoll/lcwa/lcwa0017/</collection>
		<subsite branding="lcwa"/>
	</site>

	<site>
		<branding>lcwa0014</branding>
		<label>Visual Image Web Sites Archive</label>
		<prefix>/lcwa0014/</prefix>
		<collection>/lscoll/lcwa/lcwa0014/</collection>
		<subsite branding="lcwa"/>
	</site>
	<site>
		<branding>lcwa0008</branding>
		<label>Election 2008 Web Archive</label>
		<prefix>/lcwa0008/</prefix>
		<collection>/lscoll/lcwa/lcwa0008/</collection>
		<subsite branding="lcwa"/>
	</site>
	<site>
		<branding>lcwa0032</branding>
		<label>Indonesian General Elections 2009 Web Archive</label>
		<prefix>/lcwa0032/</prefix>
		<collection>/lscoll/lcwa/lcwa0032/</collection>
		<subsite branding="lcwa"/>
	</site>
<!--<site>
		<branding>lcwa0033</branding>
		<label>Public Policy Topics Web Archive</label>
		<prefix>/lcwa0033/</prefix>
		<collection>/lscoll/lcwa/lcwa0033/</collection>
		<subsite branding="lcwa"/>
	</site>-->
	
<site>
		<branding>lcwa0020</branding>
		<label>Egypt 2008 Web Archive</label>
		<prefix>/lcwa0020/</prefix>
		<collection>/lscoll/lcwa/lcwa0020/</collection>
		<subsite branding="lcwa"/>
	</site>	
	<site>
		<branding>lcwa0031</branding>
		<label>Indian General Elections 2009 Web Archive</label>
		<prefix>/lcwa0031/</prefix>
		<collection>/lscoll/lcwa/lcwa0031/</collection>
		<subsite branding="lcwa"/>
	</site>
	<site>
            <branding>fulltext</branding>
            <label>Full Text Online</label>
			<prefix>/fulltext/</prefix>
			<collection>/lscoll/fulltext/</collection>
			<blurb><p>Full text Online is a special subset of online materials that contain searchable full text in schemas such as TEI, ALTO, DejaVu etc...</p></blurb>
			<about><h2>About Full Text Selections</h2><p>This site currently contains over 500 full text books from the sloan scanning project plus full text transcriptions and audio from the Tibetan Oral History Project. Coming soon are VHP Recordings with transcripts.</p></about>
        </site>
		<site>
            <branding>vets</branding>
            <label>Veterans History Recordings</label>
			<prefix>/vets/</prefix>
			<collection>/lscoll/afc2001001/</collection>
        </site>
		<site>
            <branding>performingarts</branding>
            <label>Performing Arts Encyclopedia</label>
			<prefix>/performingarts/</prefix>
			<collection>/lscoll/pae/</collection>
			<about>
About PAE...
			</about>
        </site>
		<site>
            <branding>afc9999005</branding>
            <label>Traditional Music &amp; Spoken Word</label>
			<prefix>/afc9999005/</prefix>
			<collection>/lscoll/pae/afc9999005/</collection>			
			<subsite branding="performingarts"/>
			<about>
About AFC Cards...
			</about>
        </site>
		<site>
            <branding>civilwar</branding>
            <label>Civil War Sheet Music</label>
			<prefix>/civilwar/</prefix>
			<collection>/lscoll/pae/civilwar/</collection>
			<subsite branding="performingarts"/>
        </site>
		<site>
            <branding>graham</branding>
            <label>Martha Graham</label>
			<prefix>/graham/</prefix>
			<collection>/lscoll/pae/graham/</collection>
			<subsite branding="performingarts"/>
        </site>
		
		<site> 
            <branding>asian</branding>
            <label>Asian Collections</label>
			<prefix>/asian/</prefix>
			<collection>/lscoll/asian/</collection> 
        </site>
		
		<site> 
            <branding>korbib</branding>
            <label>Korean Bibliography</label>
			<prefix>/korbib/</prefix>
			<blurb><p>This dataset is a subset of the Korean materials at the Library, marked up with searchable keyword terms from the tables of contents.</p>
			<p>Coverage is from 19xx to 1995.</p>
			<p>Originally maintained on the Asian Division <a href="http://lcweb2.loc.gov/misc/korhtml/korbibhome.html">website</a></p></blurb>
			<collection>/lscoll/korbib/</collection> 
			<subsite branding="asian"/>
        </site>
		<site> 
            <branding>nksip</branding>
            <label>North Korean Serials Articles</label>
			<prefix>/nksip/</prefix>
			<collection>/lscoll/asian/nksip/</collection>
			<subsite branding="asian"/>
			<search-fields><select name="field" size="6" id="in">
			  <option value="all" selected="selected">Everything</option>
			  <option>-------------------------------------</option>
			  <option value="idx:name">Name</option>
			  <option value="idx:title">Title</option>
			  <option value="idx:topic">Subject</option>			  
			  <option value="idx:beginpubdate">Publication Date</option>			  
			</select>
			</search-fields>
			<blurb><p>The Library of Congress began to acquire Korean materials in 1950, the year that the Korean War broke out.  The Library began acquiring materials in a systematic and regular basis by forging relationships with various Korean dealers.  On September 24, 1966, the United States and the Republic of Korea signed a significant exchange agreement that allowed the Library to collect government publications on a range of topics including economics, politics, local history, statistics, philosophy, and literature; since this agreement, these items have provided a strong foundation for the Korean collection.</p> 
<p>With over 281,000 volumes of monographs and some 10,000 items from North Korea, this collection has become a focal point for scholars and government officials to understand and interpret North Korea. The Library of Congress contains the largest collection of North Korean serials, especially those published in the 1940s-60s, which may not exist even in North Korea.</p>  
<p>In 2008, The Korean Team at the Library of Congress launched the North Korean Serials Indexing Project (NKSIP) with support from the Korea Foundation.      
 </p></blurb>
			<about>					
				<p>Welcome to the new North Korean Serials Indexing Project (NKSIP), a searchable index database system for the Library's North Korean serials. This database system will provide researchers access to specific articles and topics of interest included in the North Korean serials collection. </p>
<p>The NKSIP is a pioneering project that will provide users world-wide access to these rare North Korean serials.</p>
<p>The catalog currently only provides journal titles. Enabling to do keyword, author, article titles, subject, date of publication searches, the NKSIP allows the researchers to locate articles more effectively. </p>
<p>The NKSIP offers the possibility of increasing the understanding of North Korea and making the information accessible scholars and researchers, both at the Library and remotely via the Library of Congress' Web site</p>

			</about>

			<using>
			<div >
			<h2>Differences in the Korean Language between North and South Korea</h2>			
			<p >There are a small number of differences in the standard forms of the Korean language used in North Korea and South Koreasince the country divided at the end of the Korean War.  (For a more detailed description see <a href="http://en.wikipedia.org/wiki/North%E2%80%93South_differences_in_the_Korean_language">North-South differences in the Korean Language</a>.)</p>
		<p>The primary differences between the two languages are for Korean words that begin with [L]. In North Korean, when a word begins with the character of [L], it is changed into [&#12601;]; on the other hand, in South Korean, [L] changes into [&#12615;] or [&#12596;] according to the word. For example: </p>
			<h2>Converting North Korean words to South Korean words</h2>
<table style="width:50%;padding:10px; "><tr>
				<th width="30px"  style="text-align:right; padding-right: 5px;"><strong>North Korean</strong></th>
					<th width="30px"><strong>South Korean</strong></th></tr>
<tr><td width="30px" style="text-align:right; padding-right: 5px;">&#47196;&#49440;</td><td width="30px" style="padding-left: 5px;">&#45432;&#49440;</td></tr>
<tr><td style="text-align:right;padding-right:5px;">&#47196;&#46041;&#45817;</td><td style="padding-left:5px;">&#45432;&#46041;&#45817;</td></tr>
<tr><td style="text-align:right;padding-right:5px;">&#47532;&#46301;</td><td style="padding-left:5px;">&#51060;&#46301;</td></tr>
<tr><td style="text-align:right;padding-right:5px;">&#47308;&#47532;</td><td style="padding-left:5px;">&#50836;&#47532;</td></tr>
</table>

<h2>How to Search NKSIP</h2>
<h3>Diacritics, Punctuation, and Case insensitivity</h3>
<p>Diacritics, uppercase letters, and all other forms of punctuation are ignored when entered as part of your search. </p>
<p>Example:</p>
<p>A search for "chollima" would find "Ch'ollima," "Ch'&#335;llima", and/or "Chollima".</p>
<h3>Exact Phrase Searching</h3>
<p>An "exact phrase" is when two or more words occur in the order entered. Use quotation marks to indicate that an exact phrase search (e.g., "&#47196;&#46041; &#49373;&#49328;"). </p>
<h3>Boolean Logic </h3>
<p>By default, the Boolean AND operator is turned on in NKSIP. If multiple words are entered in the search box, then "all of the words entered" will be present in each search result.</p>

<p>The Boolean NOT operator is expressed using a "minus" immediately prior to the search word that you wish to negate.</p>

<p>Example:</p>
<p>A search for &#47196;&#46041; -&#49373;&#49328; will find results where "&#47196;&#46041;" is present, but will eliminate all results which also contain the word "&#49373;&#49328;".</p>

<p><em>Please Note:</em> Do not enter a space between the "minus" and the word being negated.</p>
<h3>Transcriptions of Korean</h3>
<p>According to the practice of the Library of Congress, NKSIP uses the McCune-Reischauer Romanizing system. (For more information: <a href="http://www.loc.gov/catdir/cpso/romanization/korean.pdf">http://www.loc.gov/catdir/cpso/romanization/korean.pdf</a>).</p>
<h3>Refine Results</h3>
<p><strong>Facets</strong> (limits) allow the user to refine results to better match the requested search. </p>
<p>When viewing search results, several categories of facets (limits) will be displayed in the left column. The following search refinements are available: LC Classification; Publication Year; and Format.</p>

<p>For more searching tips please visit the <a href="/static/natlibcat/html/help.html">help</a> page. </p>

<p>The Library of Congress is eager to get feedback from researchers. Please <a href="/nksip/feedback.xqy">contact us</a> to provide your comments.</p>
		</div>
		</using>
		<credits>
<h3>Acknowledgement and Special Thanks</h3>
<p>The Library of Congress wishes to acknowledge the support of the Korea Foundation, which provided funding for the compilation of the North Korean Serials Indexing Project. </p>
<p>Project Coordinator is Sonya Lee of the Korea Team, Asian Division.</p>
<p>Technical functionality and programming was done by Nate Trail, Network Development and MARC Standards Office.</p>
		
		</credits>
        </site>
		<site> 
            <branding>copland</branding>
            <label>Aaron Copland Collection</label>
			<prefix>/copland/</prefix>
			<collection>/lscoll/pae/copland/</collection> 
			<subsite branding="performingarts"/>
        </site>
		<site> 
            <branding>bernstein</branding>
            <label>Leonard Bernstein Collection</label>
			<prefix>/bernstein/</prefix>
			<collection>/lscoll/pae/bernstein/</collection> 
        </site>
		<site>
            <branding>gottlieb</branding>
            <label>Gottlieb Photos</label>
			<collection>/lscoll/gottlieb/</collection>
			<prefix>/gottlieb/</prefix>
			<subsite branding="performingarts"/>
        </site>	
				<site>
            <branding>ggbain</branding>
            <label>GG Bain Photos</label>
			<collection>/lscoll/ggbain/</collection>
			<prefix>/ggbain/</prefix>
        </site>		
        	<site>
            <branding>erms</branding>
            <label>Library of Congress E-Resources Online Catalog</label>
			<collection>/lscoll/erms/</collection>
			<prefix>/erms/</prefix>
        </site>		
		<site>
		<branding>ONIX Pre-MARC</branding>
		<collection>/lscoll/onix/</collection>
		<prefix>/onix/</prefix>
		<blurb>M<p>Onix data converted to MARC</p></blurb>
		</site>
		<site>
            <branding>sanborn</branding>
            <label>Sanborn Fire Insurance Maps</label>
			<collection>/lscoll/sanborn/</collection>
			<biburi>loc.natlib.lcdb.15875135</biburi>
			<prefix>/sanborn/</prefix>
			<blurb><p>The Sanborn Fire Insurance Maps Online Checklist provides a searchable database of the fire insurance maps published by the Sanborn Map Company housed in the collections of the Geography and Map Division. The online checklist is based upon the Library's 1981 publication Fire Insurance Maps in the Library of Congress and will be continually updated to reflect new acquisitions. The online checklist also contains links to existing digital images from our collection and will be updated as new images are added. If you have any questions, comments, or are interested in obtaining reproductions from the collection, please <a href="">Ask A Librarian</a>. </p>
        <p>To date, over 6000 sheets are online in the following states: AK, AL, AZ, CA, CT, DC, GA, IL, IN, KY, LA, MA, MD, ME, MI, MO, MS, NC, NE, NH, NJ, NV, OH, PA, TX, VA, VT, WY and Canada, Mexico, Cuba sugar warehouses, and U.S. whiskey warehouses. </p>
        </blurb>
        <using><p>
<table border="1" cellpadding="3" cellspacing="3">
              <tr>
                <th colspan="2" scope="col">INTERPRETATION</th>
                <th colspan="2" scope="col">ESSAYS</th>
              </tr>

              <tr>
                <td><a href="san12.html">Keys &amp; Colors</a></td>
                <td><a href="san2a10.html">Indexes</a></td>
                <td><a href="san4a1.html">Introduction to the Collection</a></td>
                <td>Dr. Walter W. Ristow</td>
              </tr>

              <tr>
                <td><a href="san2a.html">Symbols</a></td>
                <td><a href="san2a2.html">Line Style</a></td>
                <td><a href="san4a2.html">Sanborn Samplers</a></td>
                <td>Gary Fitzpatrick</td>
              </tr>
              <tr>

                <td><a href="san2a3.html">Title Pages</a></td>
                <td><a href="san2a2.html">Abbreviations</a></td>
                <td><a href="san4a3.html">Sanborn Time Series</a></td>
                <td>Gary Fitzpatrick</td>
              </tr>
              <tr>
                <td><a href="san2a4.html">Reports</a></td>

                <td><a href="san2a5.html">Congested Districts</a></td>
                <th colspan="2" scope="col">OTHER</th>
              </tr>
              <tr>
                <td><a href="san2a6.html">Scales</a></td>
                <td><a href="san2a7.html">Publications Dates</a></td>
                <td><a href="san3.html">Related Resources</a></td>

                <td><a href="san5.html">FAQs</a></td>
              </tr>
              <tr>
                <td><a href="san2a9.html">Sheet Numbering</a></td>
                <td><a href="san2a11.html">Water Systems</a></td>
                <td><a href="san6.html">About the Collection</a></td>
                <td><a href="san7.html">Copyright &amp; Restrictions</a></td>

              </tr>
            </table>
Ask a Librarian </p>
</using>
        </site>	
        
		</sites>
       ;

declare variable $MY-SITE  :=
	let $branding as xs:string := 
		lp:get-param-single($lp:CUR-PARAMS, 'branding', $cfg:DEFAULT-BRANDING)	
	return 
		if (exists($cfg:SITES//*:site[*:branding=$branding])) then
			$cfg:SITES//*:site[*:branding=$branding]
		 else $cfg:SITES//*:site[*:branding="lds"]

;
declare variable $SITE-NAMES :=	
	 concat('(',string-join($cfg:SITES//*:site/*:branding/string(),'|'),')')

;
declare variable $SEARCH-OPTIONS as node() :=
    <options xmlns="http://marklogic.com/appservices/search">
        <term-option>case-insensitive</term-option>
        <term-option>diacritic-insensitive</term-option>
        <term-option>punctuation-insensitive</term-option>
        <term-option>whitespace-insensitive</term-option>
        <term-option>stemmed</term-option>
    </options>;
declare variable $FACET-PAGE-CONTROL as node() :=
    <page-controls>
        <page-control>
            <from>search</from>
            <to>results</to>
        </page-control>
        <page-control>
            <from>results</from>
            <to>results</to>
        </page-control>
        <page-control>
            <from>detail</from>
            <to>results</to>
        </page-control>
        <page-control>
            <from>viz</from>
            <to>results</to>
        </page-control>
    </page-controls>;

declare variable $DISPLAY-ELEMENTS as node() :=
    let $f-counter := 0
    return
    <display>
     <!--  <elt>
          <facet-id>{ xdmp:set($f-counter, $f-counter + 1), fn:concat("f",$f-counter) }</facet-id>
            <page>search</page>
          <page>results</page>
          <view-area>left</view-area>
          <view-name>Access</view-name>
          <description>Library of Congress materials are available to users in one of three ways: 'Online' indicates that the material is completely digitized and accessible online; 'Partly Online' indicates that some further information about the material (e.g., table of contents, publisher's description, finding aid, etc.) is linked from the item description; 'At the Library' indicates that the material is only available on site at the Library of Congress. It is possible to select one or more 'Access' filters at a time. Remove the filter by selecting the X icon.</description>
          <longdesc>
            <div xmlns="http://www.w3.org/1999/xhtml">
                Library of Congress materials are available to users in one of three ways<br />
                <strong>Online</strong> - material is completely digitized and accessible from this system<br />
                <strong>Partly Online</strong> - linked information is available (e.g., table of contents, abstracts, etc.)<br />
                <strong>At the Library</strong> - material is only available in hard copy at the Library<br />
                <br />
                It is possible to select one or more Access filters at a time.<br />
                Remove the filter by selecting the X icon.
            </div>
          </longdesc>
          <starts-hidden>true</starts-hidden>
          <data-function>vf:facet-data</data-function>
          <facet-param>info:lc/xq-modules/lcindex</facet-param>
          <facet-param>digitized</facet-param>
          <facet-operation>or</facet-operation>
        </elt> -->
        <elt>
          <facet-id>{ xdmp:set($f-counter, $f-counter + 1), fn:concat("f",$f-counter) }</facet-id>
          <page>search</page>
          <page>results</page>
          <view-area>left</view-area>
          <view-name>Format</view-name>
          <description>To refine results by format, select a material type from the list provided. Currently, it is only possible to filter by one format at a time. Remove the filter by selecting the X icon.</description>
          <longdesc>
            <div xmlns="http://www.w3.org/1999/xhtml">
                To refine results by format, select a material type from the list provided.<br />
                <br />
                It is only possible to filter by one format at a time.<br />
                Remove the filter by selecting the X icon.
            </div>
          </longdesc>
          <starts-hidden>false</starts-hidden>
          <data-function>vf:facet-data</data-function>
          <facet-param>info:lc/xq-modules/lcindex</facet-param>
          <facet-param>materialGroup</facet-param>
          <facet-operation>or</facet-operation>
        </elt>
		 <elt>
          <facet-id>{ xdmp:set($f-counter, $f-counter + 1), fn:concat("ft",$f-counter) }</facet-id>
          <page>search</page>
          <page>results</page>
          <view-area>left</view-area>
          <view-name>LC Classification</view-name>
          <description>The LC Classification system is a topical arrangement of all knowledge into 21 broad subject areas. It is used to organize materials at the Library of Congress (chiefly book collections) and has been adopted broadly in many U.S. academic and research libraries.  To refine results by 'LC Classification,' select any broad class from the list.  Sub-classes may then appear, allowing further refining of results. Remove the filter by selecting the X icon.</description>
          <longdesc>
            <div xmlns="http://www.w3.org/1999/xhtml">
                Library of Congress Classification is a topical arrangement of all knowledge into 21 broad subject areas. The Library uses it to organize materials (chiefly book collections) and it has been adopted broadly in many U.S. academic and research libraries.<br />
                <br />
                It is only possible to filter by one LC Classification at a time.<br />
                Sub-classes may then appear, allowing further refining of results.<br />
                Remove the filter by selecting the X icon.
            </div>
          </longdesc>
          <starts-hidden>false</starts-hidden>
          <data-function>vf:facet-multi-tier</data-function>
          <facet-param>info:lc/xq-modules/lcindex</facet-param>
          <facet-param>lcc1</facet-param>
          <facet-param>info:lc/xq-modules/lcindex</facet-param>
          <facet-param>lcc2</facet-param>
          <facet-param>info:lc/xq-modules/lcindex</facet-param>
          <facet-param>lcc3</facet-param>
          <facet-operation>or</facet-operation>
        </elt>      
		 <elt>
          <facet-id>{ xdmp:set($f-counter, $f-counter + 1), fn:concat("f",$f-counter) }</facet-id>
          <page>search</page>
          <page>results</page>
          <view-area>left</view-area>
          <view-name>Language</view-name>
          <description>To refine results by language(s), select any language from the list provided.  The first ten languages are shown (based on frequency), but more can be displayed by selecting the 'more languages' link. It is possible to select multiple languages at a time. Remove the filter by selecting the X (remove filter icon).</description>
          <longdesc>
            <div xmlns="http://www.w3.org/1999/xhtml">
                To refine results by language(s), select any language from the list provided.<br />
                The first ten languages are shown (based on frequency), but more can be displayed by selecting the <em>more languages</em> link.<br />
                <br />
                It is possible to select more than one language at a time.<br />
                Remove the filter by selecting the X icon.
            </div>
          </longdesc>
          <starts-hidden>false</starts-hidden>
          <data-function>vf:facet-data</data-function>
          <facet-param>info:lc/xq-modules/lcindex</facet-param>
          <facet-param>language</facet-param>
          <facet-operation>and</facet-operation>
        </elt>

        <elt>
          <facet-id>{ xdmp:set($f-counter, $f-counter + 1), fn:concat("f",$f-counter) }</facet-id>
          <page>search</page>
          <page>results</page>
          <view-area>left</view-area>
          <view-name>Subject</view-name>
          <description>Topics in your seearch. Remove the filter by selecting the X icon.</description>
          <longdesc>
            <div xmlns="http://www.w3.org/1999/xhtml">
              Topics in your seearch. Remove the filter by selecting the X icon.  
               
            </div>
          </longdesc>
          <starts-hidden>false</starts-hidden>
          <data-function>vf:facet-data</data-function>
          <facet-param>info:lc/xq-modules/lcindex</facet-param>
          <facet-param>subjectLexicon</facet-param>
          <facet-operation>or</facet-operation>
        </elt>
        <elt>
          <facet-id>{ xdmp:set($f-counter, $f-counter + 1), fn:concat("f",$f-counter) }</facet-id>
          <page>search</page>
          <page>results</page>
          <view-area>left</view-area>
          <view-name>Content types</view-name>
          <description>Content types</description>
          <longdesc>
            <div xmlns="http://www.w3.org/1999/xhtml">
              Conten types in your seearch. Remove the filter by selecting the X icon.  
               
            </div>
          </longdesc>
          <starts-hidden>false</starts-hidden>
          <data-function>vf:facet-data</data-function>
          <facet-param>info:lc/xq-modules/lcindex</facet-param>
          <facet-param>content</facet-param>
          <facet-operation>or</facet-operation>
        </elt>
       
        <elt>
          <facet-id>{ xdmp:set($f-counter, $f-counter + 1), fn:concat("f",$f-counter) }</facet-id>
          <page>search</page>
          <page>results</page>
          <view-area>left</view-area>
          <view-name>Publication Year (bf:Instance)</view-name>
          <description>To refine results by year, select any year from the list provided.  While the most common occurance is the 'year of publication', this filter may also refer to year of issuance, creation, copyright, etc.  The first ten years are shown (based on frequency), but more can be displayed by selecting the 'more publication years' link. It is only possible to select one year at a time. Remove the filter by selecting the X icon.</description>
          <longdesc>
            <div xmlns="http://www.w3.org/1999/xhtml">
                To refine results by year, select any year from the list provided.  While the most common occurance is the <em>year of publication</em>, this filter may also refer to year of <em>issuance</em>, <em>creation</em>, <em>copyright</em>, etc.  The first ten years are shown (based on frequency), but more can be displayed by selecting the <em>more publication years</em> link.<br />
                <br />
                It is only possible to select one year at a time.<br />
                Remove the filter by selecting the X icon.
            </div>
          </longdesc>
          <starts-hidden>false</starts-hidden>
          <data-function>vf:facet-data</data-function>
          <facet-param>info:lc/xq-modules/lcindex</facet-param>
          <facet-param>beginpubdate</facet-param>
          <facet-operation>or</facet-operation>
        </elt>
		 <elt>
          <facet-id>{ xdmp:set($f-counter, $f-counter + 1), fn:concat("f",$f-counter) }</facet-id>
          <page>search</page>
          <page>results</page>
          <view-area>left</view-area>
          <view-name>Media (bf:Instance)</view-name>
          <description>Media types</description>
          <longdesc>
            <div xmlns="http://www.w3.org/1999/xhtml">
                To refine results by media type, select any media from the list provided. <br />
                <br />
                It is only possible to select one type at a time.<br />
                Remove the filter by selecting the X icon.
            </div>
          </longdesc>
          <starts-hidden>false</starts-hidden>
          <data-function>vf:facet-data</data-function>
          <facet-param>info:lc/xq-modules/lcindex</facet-param>
          <facet-param>media</facet-param>
          <facet-operation>or</facet-operation>
        </elt>
		<elt>
          <facet-id>{ xdmp:set($f-counter, $f-counter + 1), fn:concat("f",$f-counter) }</facet-id>
          <page>search</page>
          <page>results</page>
          <view-area>left</view-area>
          <view-name>Carrier (bf:Instance)</view-name>
          <description>Carrier types</description>
          <longdesc>
            <div xmlns="http://www.w3.org/1999/xhtml">
                To refine results by media type, select any carrier from the list provided. <br />
                <br />
                It is only possible to select one carrier at a time.<br />
                Remove the filter by selecting the X icon.
            </div>
          </longdesc>
          <starts-hidden>false</starts-hidden>
          <data-function>vf:facet-data</data-function>
          <facet-param>info:lc/xq-modules/lcindex</facet-param>
          <facet-param>carrier</facet-param>
          <facet-operation>or</facet-operation>
        </elt>
        <elt>
          <facet-id>{ xdmp:set($f-counter, $f-counter + 1), fn:concat("f",$f-counter) }</facet-id>
          <page>search</page>
          <page>results</page>
          <view-area>left</view-area>
          <view-name>Library Location (bf:Item)</view-name>
          <description>Materials available at the Library are located in several different curatorial locations.  Most materials are part of the 'General Collections' and can be requested in any Jefferson or Adams building reading room.  However, some materials are available only from specialized reading rooms.  This filter is additive (one or more locations can be selected at a time). Remove any location filter by selecting the X icon.</description>
          <longdesc>
            <div xmlns="http://www.w3.org/1999/xhtml">
                Materials available at the Library are located in several different curatorial locations.  Most materials are part of the <em>General Collections</em> and can be requested in any Jefferson or Adams building reading room.  However, some materials are available only from specialized reading rooms.<br />
                <br />
                It is possible to select more than one location at a time.<br />
                Remove the filter by selecting the X icon.
            </div>
          </longdesc>
          <starts-hidden>true</starts-hidden>
          <data-function>vf:facet-data</data-function>
          <facet-param>info:lc/xq-modules/lcindex</facet-param>
          <facet-param>loc1</facet-param>
          <facet-operation>or</facet-operation>
        </elt>
        <!-- <elt>
          <facet-id>{ xdmp:set($f-counter, $f-counter + 1), fn:concat("ft",$f-counter) }</facet-id>
          <page>search</page>
          <page>results</page>
          <view-area>left</view-area>
          <view-name>Library Location</view-name>
          <description>The Library location is the reading room or physical location that is the custodial owner of the material. To refine results by 'Library Location,' select any entry from the list.  Sub-locations may then appear, allowing further refining of results. Remove the filter by selecting the X icon.</description>
          <longdesc>
            <div xmlns="http://www.w3.org/1999/xhtml">
                Library of Congress Location is a custodial view of all materials. Material is either housed there physically or is custodially owned by that unit.<br />
                <br />
                It is only possible to filter by one Location at a time.<br />
                Sub-locations may then appear, allowing further refining of results.<br />
                Remove the filter by selecting the X icon.
            </div>
          </longdesc>
          <starts-hidden>false</starts-hidden>
          <data-function>vf:facet-multi-tier</data-function>
          <facet-param>info:lc/xq-modules/lcindex</facet-param>
          <facet-param>loc1</facet-param>
          <facet-param>info:lc/xq-modules/lcindex</facet-param>
          <facet-param>loc2</facet-param>
          <facet-operation>or</facet-operation>
        </elt> -->
        { (:if (contains($cfg:HOST-NAME, "marklogic3")) then:)
         if ( contains($cfg:HOST-NAME,"mlvlp04") and xdmp:get-request-header('X-LOC-Environment')!='Staging') then
		
		<elt>
          <facet-id>{ xdmp:set($f-counter, $f-counter + 1), concat("f",$f-counter) }</facet-id>
          <page>search</page>
          <page>results</page>
          <view-area>left</view-area>
          <view-name>Geographic Scale</view-name>
          <description>Materials available at the Library are located in several different curatorial locations.  Most materials are part of the 'General Collections' and can be requested in any Jefferson or Adams building reading room.  However, some materials are available only from specialized reading rooms.  This filter is additive (one or more locations can be selected at a time). Remove any location filter by selecting the X icon.</description>
          <longdesc>
            <div xmlns="http://www.w3.org/1999/xhtml">
                Materials available at the Library are located in several different curatorial locations.  Most materials are part of the <em>General Collections</em> and can be requested in any Jefferson or Adams building reading room.  However, some materials are available only from specialized reading rooms.<br />
                <br />
                It is possible to select more than one location at a time.<br />
                Remove the filter by selecting the X icon.
            </div>
          </longdesc>
          <starts-hidden>false</starts-hidden>
          <data-function>vf:facet-data</data-function>
          <facet-param>info:lc/xq-modules/lcindex</facet-param>
          <facet-param>geoScale</facet-param>
          <facet-operation>and</facet-operation>
        </elt>
		else ()
		}
        <!--elt>
          <facet-id>{ xdmp:set($f-counter, $f-counter + 1), fn:concat("f",$f-counter) }</facet-id>
          <page>search</page>
          <page>results</page>
          <view-area>left</view-area>
          <view-name>Reading Room</view-name>
          <starts-hidden>false</starts-hidden>
          <data-function>vf:facet-data</data-function>
          <facet-param>info:lc/xq-modules/lcindex</facet-param>
          <facet-param>location</facet-param>
          <facet-operation>or</facet-operation>
        </elt-->
        <!--elt>
          <facet-id>{ xdmp:set($f-counter, $f-counter + 1), fn:concat("f",$f-counter) }</facet-id>
          <page>search</page>
          <page>results</page>
          <view-area>left</view-area>
          <view-name>LC Classification No.</view-name>
          <starts-hidden>true</starts-hidden>
          <data-function>vf:facet-data</data-function>
          <facet-param>info:lc/xq-modules/lcindex</facet-param>
          <facet-param>lcclass</facet-param>
          <facet-operation>or</facet-operation>
        </elt-->
         <!--elt>
          <facet-id>{ xdmp:set($f-counter, $f-counter + 1), fn:concat("f",$f-counter) }</facet-id>
          <page>search</page>
          <page>results</page>
          <view-area>left</view-area>
          <view-name>LC Class</view-name>
          <starts-hidden>false</starts-hidden>
          <data-function>vf:facet-data</data-function>
          <facet-param>info:lc/xq-modules/lcindex</facet-param>
          <facet-param>lccfacet</facet-param>
          <facet-operation>or</facet-operation>
        </elt-->
        
       <!--  <elt>
          <facet-id>{ xdmp:set($f-counter, $f-counter + 1), fn:concat("f",$f-counter) }</facet-id>
          <page>search</page>
          <page>results</page>
          <page>detail</page>
          <view-area>left</view-area>
          <view-name>Collection</view-name>
          <starts-hidden>false</starts-hidden>
          <data-function>vf:facet-data</data-function>
          <facet-param>info:lc/xq-modules/lcindex</facet-param>
          <facet-param>memberOf</facet-param>
          <facet-operation>or</facet-operation>
        </elt> -->
		 <elt>
          <facet-id>{ xdmp:set($f-counter, $f-counter + 1), fn:concat("f",$f-counter) }</facet-id>
          <page>search</page>
          <page>results</page>
          <view-area>left</view-area>
          <view-name>Role</view-name>
          <description>To refine results by role, select a role from the list provided. Currently, it is only possible to filter by one role at a time. Remove the filter by selecting the X icon.</description>
          <longdesc>
            <div xmlns="http://www.w3.org/1999/xhtml">
                To refine results by role, select a material type from the list provided.<br />
                <br />
                It is only possible to filter by one role at a time.<br />
                Remove the filter by selecting the X icon.
            </div>
          </longdesc>
          <starts-hidden>false</starts-hidden>
          <data-function>vf:facet-data</data-function>
          <facet-param>info:lc/xq-modules/lcindex</facet-param>
          <facet-param>role</facet-param>
          <facet-operation>or</facet-operation>
        </elt>
        
       <!--  <elt>
          <facet-id>{ xdmp:set($f-counter, $f-counter + 1), fn:concat("f",$f-counter) }</facet-id>
          <page>search</page>
          <page>results</page>
          
          <view-area>left</view-area>
          <view-name>Material Type</view-name>
          <starts-hidden>false</starts-hidden>
          <data-function>vf:facet-data</data-function>
          <facet-param>info:lc/xq-modules/lcindex</facet-param>
          <facet-param>materialGroup</facet-param>
          <facet-operation>or</facet-operation>
        </elt> -->
    </display>;
    declare variable $DIGITAL-OBJECT-CONTROL as node() :=
   <object-controls xmlns="http://www.marklogic.com/ps/config">
  <object-control><profile>recordedEvent</profile>    
    <page><behavior>default</behavior><noattributes/></page>
    <page><behavior>item</behavior>
      <attribute>itemID</attribute>
      <description>child related items may have audio, see tohap, if tei is in parts, show tei with itemid (plus relatedItem level bib data)
        if no tei, just show  relatedItem level bib data</description>
    </page>             
    <page><behavior>contents</behavior>
      <noattributes/>
      <description>all child related items listed</description>
    </page>
    <page><behavior>track</behavior>
      <attribute>itemID</attribute>
      <description>child related items have related items (movements containing pieces in a concert?)</description>
    </page>
    <page><behavior>transcript</behavior><noattributes/>
      <description>transcript of the whole thing, see greatconv</description>
    </page>
    <example><name>tohap</name>http://marklogic3.loctest.gov/lds/detail.xqy?q=tohap%20jigme&amp;collection=all&amp;count=10&amp;pg=1&amp;mime=text%2Fhtml&amp;sort=score-desc&amp;qname=keyword&amp;uri=loc.natlib.tohap.H0202&amp;index=3</example>
      <example><name>beaux arts</name>http://lcweb2.loc.gov/diglib/ihas/loc.natlib.ihas.200003788/contents.html</example>
      <example><name>greatconv</name>http://lcweb2.loc.gov/diglib/ihas/loc.natlib.ihas.200031107/default.html</example>              
  </object-control>
  <object-control><profile>modsBibRecord</profile>
    <page><behavior>default</behavior><noattributes/></page>
    <page><behavior>enlarge</behavior>
      <attribute>page</attribute>
      <attribute>from</attribute>
      <attribute>size</attribute>
      <description> may not need page and from; there's only one page</description>
    </page>
    <example><name>afccards</name>http://lcweb2.loc.gov/diglib/ihas/loc.afc.afc9999005.18151/enlarge.html?page=1&amp;size=1024&amp;from=default</example>
      <example><name>scdb</name>http://lcweb2.loc.gov/diglib/ihas/loc.natlib.scdb.200033852/default.html</example>
  </object-control>
  <object-control> <profile>photoObject</profile>
    <page><behavior>default</behavior><noattributes/></page>
    <page><behavior>contactsheet</behavior><noattributes/></page>
    <page><behavior>enlarge</behavior>
      <attribute>page</attribute>             
      <attribute>size</attribute>
      <attribute>section</attribute>
      <description> may not need "from"</description>
      <note>does not pageturn, but has page=1.  tracks the correct image with section=ver01, hands it back to pageturner </note>
    </page>
    <page><behavior>pageturner</behavior>
      <attribute>page</attribute>                         
      <attribute>section</attribute>
       
      <description> may not need page and from; there's only one page may need section if multiple versions. has  no size but size is 500 </description>
    </page>
    <example><name>multipleversions</name>http://lcweb2.loc.gov/diglib/ihas/loc.natlib.gottlieb.02741/default.html</example>
    <example><name>single</name>http://lcweb2.loc.gov/diglib/ihas/loc.natlib.gottlieb.11231/enlarge.html?page=1&amp;size=1024&amp;from=default&amp;section=ver02</example>
  </object-control>
</object-controls>
;(: Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
:)