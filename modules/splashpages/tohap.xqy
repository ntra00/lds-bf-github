xquery version "1.0-ml";
(: splash page for tohap:)
import module namespace cfg = "http://www.marklogic.com/ps/config" at "/nlc/config.xqy";
import module namespace resp = "info:lc/xq-modules/http-response-utils" at "/xq/modules/http-response-utils.xqy";
import module namespace lp = "http://www.marklogic.com/ps/lib/l-param" at "/nlc/lib/l-param.xqy";
import module namespace mime = "info:lc/xq-modules/mime-utils" at "/xq/modules/mime-utils.xqy";
import module namespace splash = "info:lc/splashpages/splash-utils" at "/splashpages/splash-utils.xqy";
import module namespace ssk = "info:lc/xq-modules/search-skin" at "/xq/modules/natlibcat-skin.xqy";
import module namespace mem = "http://xqdev.com/in-mem-update" at "/xq/modules/in-mem-update.xqy";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

(: get the facet param name (i.e. f5 ) of the 'digitized' facet :)
declare variable $digitizedfacet as xs:string := string($cfg:DISPLAY-ELEMENTS/elt[facet-param/text() eq 'digitized']/facet-id) ;
(: auto populate form with these values :)
declare variable $query as xs:string? := xdmp:get-request-field("q", ());
declare variable $qname as xs:string? := xdmp:get-request-field("qname", "keyword");
declare variable $digitized as xs:string? := xdmp:get-request-field($digitizedfacet, "");
declare variable $starting-text := $query;
declare variable $browse-query as xs:string? := xdmp:get-request-field("bq", ());
declare variable $browse as xs:string? := xdmp:get-request-field("browse", "");
(: sometimes users will come in with out the trailing slash, so all references to executables need the urlprefix ie., action="tohap/search.xqy":)

let $doctype := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">'
let $duration := $cfg:HTTP_EXPIRES_CACHE
let $collection:= lp:get-param-single($lp:CUR-PARAMS, "collection") 
let $header := splash:header("Tibetan Oral History and Archive Project (TOHAP) at the Library of Congress","tohap")
let $meta-desc:=<metas xmlns="http://www.w3.org/1999/xhtml"><meta content="tibetan, oral history, archive project, tohap, chinese, officials, society, monks, transcript, library of congress, melvin goldstein, professor goldstein, interviews, common folk, political, case western" name="keywords" />
<meta content="Tibetan Oral History and Archive Project (TOHAP) at the Library of Congress. TOHAP is a digital archive of oral history interviews with accompanying written transcripts (translated into English) documenting  the social and political history of modern Tibet. It includes a large  collection of interviews from common folk, monks, and Tibetan and Chinese  officials speaking about their lives and modern Tibetan society and history. These interviews were collected by Professor Melvyn C. Goldstein and his assistants during a series of research projects on modern Tibet history and society that were funded by the National Endowment for the Humanities and during a large Tibetan Oral History Project funded by the Henry Luce Foundation and the National Endowment for the Humanities. Professor Goldstein is the John Reynolds Harkness Professor of Anthropology and Co-Director of the Center for Research on Tibet at Case Western Reserve University, Cleveland, Ohio. He is a member of the National Academy of Sciences." name="description" /></metas>
let $header:=mem:node-insert-after($header//*:title,$meta-desc/*)
let $site-title:=$cfg:MY-SITE/cfg:label/string()
let $html :=

	<html xmlns="http://www.w3.org/1999/xhtml">
    	{$header/head}
		
		<body>
		{splash:topnav-div($site-title)/div}
		<div id="ds-container">
			<div id="ds-body">
					<!--<div id="dsresults">
					<div id="content-results">-->
						
						<!--<p>add sharetool</p>-->
						<!-- END ds-bibrecord-nav -->
					<!-- </div>-->
					<!-- END content-results -->

					<!-- New Bib Item Stuff Begins -->

					<div id="container">
						<!-- this is the title and statement of responsibility for the object -->
						<h1>Tibetan Oral History and Archive Project (TOHAP)</h1>
						<!-- END title -->
						

						<div id="ds-maincontent">
							<!-- the tabs are for collection framing materials -->
							<ul class="tabnav">
								<li class="first">
									<a href="#overview">Overview</a>
								</li>
								<li>
									<a href="#about">About TOHAP</a>
								</li>
								
								<li>
									<a href="#glossary">Glossary of Terms</a>
								</li>
								<li><a href="#credits">Acknowledgments</a></li>
								
							</ul>
							<!-- end class:tabnav -->
							<div class="tab_container">
								<div id="overview" class="tab_content">
									<h2 class="hidden">Overview</h2>

									<div id="collection_image">
										<img src="/static/tohap/images/tohap-collage.jpg" alt="A collage of images showing Professor Goldstein and his students conducting interviews in Tibet and India." width="200" height="299"/>
										<div>A collage of images showing Professor Goldstein and his students conducting interviews in Tibet and India.</div>
									</div>
									<p>The <em>Tibetan Oral History and Archive Project (TOHAP)</em> is a digital archive  of oral history interviews with accompanying written transcripts (translated into English) documenting  the social and political history of modern Tibet. It includes a large  collection of interviews from common folk, monks, and Tibetan and Chinese  officials speaking about their lives and modern Tibetan society and history.</p>

									<h2>
								  <label for="searchcollection">Search Oral Histories by Keyword</label></h2>
								<div class="searchnav">
									<form action="/tohap/search.xqy" id="collectionsearch" method="GET" onSubmit="return validateForm();">
									<p><input name="q" type="text" size="30" class="txt" value="Search this collection" onFocus="this.value=''" id="searchcollection"/><button id="submit">GO</button><br/><label for="field">Contained in:</label><br/><select size="5" name="qname" id="field">
									<option selected="selected" value="keyword">Full text (includes transcript)</option>
									<option value="idx:titleLexicon">Interview Title</option>
									<option value="mods:dateCaptured">Date Recorded</option>
									<option value="idx:abstract">Abstract</option>
									<option value="idx:aboutPlace">Place of Recording</option>
									</select></p>
									</form>
								</div>
									<p>These interviews were collected by Professor Melvyn C. Goldstein and his assistants during a series of research projects on modern Tibet history and society that were funded by the National Endowment for the Humanities (RO-20261-82, RO-20886-85, RO-21860-89, RO-22251-91, RO-22754-94) and during a large <em>Tibetan Oral History Project</em> funded by the Henry Luce Foundation and the National Endowment for the Humanities (RZ-20585-00, RZ-50326-05, RZ-50845-08). Professor Goldstein is the John Reynolds Harkness Professor of Anthropology and Co-Director of the Center for Research on Tibet at Case Western Reserve University, Cleveland, Ohio. He is a member of the National Academy of Sciences.</p>
					<p>NOTE: This archive is being released to the public in installments beginning in the Spring of 2012. The first release includes a series of interviews on pre-1951 Tibet from the <em>Political Oral History Collection</em>. Subsequent installments will be released every 6-12 months as the editing of the interview transcripts is completed.</p>

								</div>
								<div id="about" class="tab_content">
									<h2 class="hidden">Rights and Restrictions</h2>

									<h2>About the <span class="oneline">Project</span></h2>
									<p>
										<img src="/static/tohap/images/goldstein-photo-small.jpg" alt="Image of Melvyn Goldstein conducting and interview" width="274" height="211" align="right"/>Knowledge of the social and political history of Tibet during the second half of the Twentieth Century has been limited by the absence of the voices of everyday Tibetans. The <em>Tibetan Oral History and Archive Project</em> was undertaken by Professor Melvyn C. Goldstein, Director, Center for Research on Tibet (Case Western Reserve University) to collect and preserve these voices and with it a record of the diversity of life as it was lived in Tibet in the traditional and socialist eras.</p>
									<p>The ensuing Oral History Archive consists of the original recordings in Tibetan and the English transcripts of the interviews of almost 700 Tibetans (and a few Chinese) living in the Tibet Autonomous Region of China and in exile in India about their lives and modern history. This archive, the largest of its type in the world, contains three collections: the Common Folk Oral History collection, the Political Collection and the Drepung Monastery Collection.</p>
									<p>
										<strong>The Common Folk Collection</strong> consists of  recorded interviews with over 600 Tibetans from all walks of life.  in Tibet and in India.</p>

									<p>
										<strong>The Political Collection</strong> consists of recorded interviews with former Tibetan government officials who played important roles in Tibet's history. The topics discussed include historical events in both the traditional and socialist periods.</p>
									<p>
										<strong>The Drepung Monastery Collection</strong> consists of recorded interviews on monastic social and economic life with roughly 100 monks who were members of Drepung monastery in the traditional era. Drepung monastery is located 5 miles outside of Lhasa and was Tibet 's largest monastery, housing about 10,000 monks in 1959 at the end of the traditional era. <br/>
										<br/>Melvyn C. Goldstein<br/>
         John Reynolds Harkness Professor in Anthropology<br/>

         Co-Director, Center for Research on Tibet<br/>
         Case Western Reserve University<br/>
         Cleveland, Ohio 44106<br/>
         Ph. 216 368-2265, Fx. 216 368-5334<br/>
         Center for Research on Tibet: <a href="http://www.cwru.edu/affil/tibet/">http://www.cwru.edu/affil/tibet/</a><img alt="External Link" src="http://www.loc.gov/images/icon-ext2.gif" height="10" width="8" /> </p>
		 
								</div>
								<div id="tab3" class="tab_content">
									<h2>Using the Collection</h2>
									<p>Donec sed tellus eget sapien fringilla nonummy. Mauris a ante. Suspendisse quam sem, consequat at, commodo vitae, feugiat in, nunc. Morbi imperdiet augue quis tellus.</p>
								</div>
								<div id="glossary" class="tab_content">
									<h2>Glossary</h2>

									<p class="alpha-list">
										<a href="#a">A</a>&#xA0; <a href="#b">B</a>&#xA0; <a href="#c">C</a>&#xA0; <a href="#d">D</a> &#xA0;<a href="#e">E</a>&#xA0; <a href="#f">F</a>&#xA0; <a href="#g">G</a>&#xA0; <a href="#h">H</a>&#xA0; <a href="#">I</a> &#xA0;<a href="#j">J</a>&#xA0; <a href="#k">K</a>&#xA0; <a href="#l">L</a>&#xA0; <a href="#m">M</a> &#xA0;<a href="#n">N</a> &#xA0;<a href="#o">O</a> &#xA0;<a href="#p">P</a>&#xA0; <a href="#q">Q</a>&#xA0; <a href="#r">R</a> &#xA0;<a href="#s">S</a> &#xA0;<a href="#t">T</a> &#xA0;<a href="#u">U</a> &#xA0;&#xA0;V&#xA0;&#xA0;&#xA0;<a href="#w">W</a> &#xA0;<a href="#x">X</a> &#xA0;<a href="#y">Y</a> &#xA0;<a href="#z">Z</a> &#xA0;<a href="#uu">&#xDC;</a></p>

									<div class="alpha" id="a">
										<span class="letter">A</span>
										<p class="term">
											<span class="orth">accumulation grain</span>
											<span class="romanization">[tib. trabso dru (grabs gsog 'bru)]</span>
											<br/>
											<span class="definition">A type of grain tax collected by the government and collectives to create a surplus grain fund that could be used when needed. It was often used to provide welfare to households who faced hardships.</span>
										</p>
										<p class="term">
											<span class="orth">adrung</span>
											<span class="romanization">[a drung]</span>
											<br/>

											<span class="definition">official government messengers who carried government messages traveling from post stop to post stop using corvee animals and people.</span>
										</p>
										<p class="term">
											<span class="orth">Agriculture and Husbandry Bureau</span>
											<span class="romanization">[ch. nong mu ju]</span>
											<br/>
											<span class="definition">an office in post 1959 Tibet that was concerned with farmers and pastoral nomads.</span>
										</p>
										<p class="term">
											<span class="orth">amban</span>
											<span class="romanization">[tib. am ban ]</span>
											<br/>

											<span class="definition">A Manchu term for the Imperial Resident sent by the Qing Dynasty to Lhasa to represent the Qing authority over the Tibetan government. Their real authority varied depending on the times and the ability of the amban.</span>
										</p>
										<p class="term">
											<span class="orth">Amdo</span>
											<span class="romanization">[tib. a mdo]</span>
											<br/>
											<span class="definition">a Tibetan ethnic region now mostly in Qinghai Province.</span>
										</p>
										<p class="term">
											<span class="orth">Amdo Jayan sheba</span>
											<span class="romanization">[tib. a mdo 'jam yang bzhad pa]</span>
											<br/>

											<span class="definition">a famous Gelukpa incarnation line whose main monastery is Labrang located in today's Gansu Province.</span>
										</p>
										<p class="term">
											<span class="orth">ani</span>
											<span class="romanization">[tib. a ne]</span>
											<br/>
											<span class="definition">1. the Tibetan term for a nun.  2. the famous nun from Nyemo who led an uprising there in 1969 during the Cultural Revolution. Her name was Trinley Ch&#xF6;dr&#xF6;n ('phrin las chos sgron). After her capture, she was publicly executed in Lhasa.</span>
										</p>

										<p class="term">
											<span class="orth">apdru</span>
											<span class="romanization">[tib. a phrug]</span>
											<br/>
											<span class="definition">Young men accompanying someone on a trip as a kind of bodyguard; young men who were hangers-on/bodyguards of a rich or powerful figure, for example a rich trader.</span>
										</p>
										<p class="term">
											<span class="orth">apju</span>
											<span class="romanization">[tib. a ljug]</span>
											<br/>

											<span class="definition">a type of child's game played with the shin bones of the front legs of sheep and goats.</span>
										</p>
										<p class="term">
											<span class="orth">arka</span>
											<span class="romanization">[tib. ]</span>
											<br/>
											<span class="definition">A type of traditional floor surfacing that was a powdered rock that was pounded down on the floor to produce a hard shiny surface.</span>
										</p>
									</div>

									<div class="alpha" id="b">
										<span class="letter">B</span>
										<p class="term">
											<span class="orth">bag</span>
											<span class="romanization">[tib. spags]</span>
											<br/>
											<span class="definition">A Tibetan stable food made by mixing tsamba (roasted flour) with tea (or beer or water) and kneading it into balls with a dough-like consistency.</span>
										</p>
										<p class="term">
											<span class="orth">bagchen</span>
											<span class="romanization">[sbag chen]</span>
											<br/>

											<span class="definition">a form of majong in which the tiles have circles of different numbers on that (like dominos) and each (of 4) persons is dealt a fixed hand and plays it out until the end.</span>
										</p>
										<p class="term">
											<span class="orth">bagthug</span>
											<span class="romanization">[tib. bag  thug]</span>
											<br/>
											<span class="definition">a soup that contains a mixture of tiny dough (flour) balls the size of a fingernail  (and if available cheese, meat, and radish).</span>
										</p>
										<p class="term">
											<span class="orth">Banagsh&#xF6;</span>
											<span class="romanization">[tib. sbra nag zhol]</span>
											<br/>

											<span class="definition">a neighborhood in the northeast of Lhasa.</span>
										</p>
										<p class="term">
											<span class="orth">Bargor</span>
											<span class="romanization">[tib. bar skor]</span>
											<br/>
											<span class="definition">The name of a xiang and county in Nyemo that played an important role in the nun Trinley Ch&#xF6;dr&#xF6;n's uprising of 1968-69</span>
										</p>

										<p class="term">
											<span class="orth">Barkor</span>
											<span class="romanization">[tib. bar skor]</span>
											<br/>
											<span class="definition">the inner circumambulation road that goes around the Tsuglagang (Jokhang) Temple in Lhasa. This circular road was a main market area.</span>
										</p>
										<p class="term">
											<span class="orth">batuk</span>
											<span class="romanization">[tib. bag thug] [tib. bag  thug]</span>
											<br/>

											<span class="definition">[bagthug] a soup that contains a mixture of tiny dough (flour) balls the size of a fingernail  (and if available cheese, meat, and radish).</span>
										</p>
										<p class="term">
											<span class="orth">bawma</span>
											<span class="romanization">[tib. bogs ma]</span>
											<br/>
											<span class="definition">a lease agreement (in traditional Tibet).</span>
										</p>
										<p class="term">
											<span class="orth">Big Three Monastic Seats</span>
											<span class="romanization">[tib. gdan sa gsum ]</span>
											<br/>

											<span class="definition">The three great monasteries around Lhasa: Drepung, Sera and Ganden</span>
										</p>
										<p class="term">
											<span class="orth">bo</span>
											<span class="romanization">[tib. 'bo ] [tib. khal]</span>
											<br/>
											<span class="definition">see khe [khe] a traditional volume measurement for measuring grain in the traditional Tibetan society. Sizes varied somewhat, but the official government khe (called mkhar ru or bstan dzin mkha ru) weighed about 31 pounds for barley. It was universally used in traditional Tibet as a land measurement in that fields would be said to be of a size able to use a certain number of  khe of seed (called s&#xF6;nkhe).</span>
										</p>
										<p class="term">
											<span class="orth">b&#xF6;bashung</span>
											<span class="romanization">[tib. bod pa gzhung] [tib. bod pa gzhung]</span>
											<br/>

											<span class="definition">[b&#xF6;pashung] the name of a mitsen in both Loseling and Goman tratsang (in Drepung monastery).</span>
										</p>
										<p class="term">
											<span class="orth">B&#xF6;nsh&#xF6;</span>
											<span class="romanization">[tib. bon shod]</span>
											<br/>
											<span class="definition">the name of an aristocratic family and official.</span>
										</p>

										<p class="term">
											<span class="orth">booli</span>
											<span class="romanization">[tib. bo'o li ? ]</span>
											<br/>
											<span class="definition">a competitive child's game played by trying to throw coins in a hole</span>
										</p>
										<p class="term">
											<span class="orth">b&#xF6;pa</span>
											<span class="romanization">[tib. bod pa]</span>
											<br/>

											<span class="definition">1. a person from political Tibet in contrast to a person from Kham and Amdo.  2. also used for an ethnic Tibetan.</span>
										</p>
										<p class="term">
											<span class="orth">b&#xF6;pashung</span>
											<span class="romanization">[tib. bod pa gzhung]</span>
											<br/>
											<span class="definition">the name of a mitsen in both Loseling and Goman tratsang (in Drepung monastery).</span>
										</p>
										<p class="term">
											<span class="orth">brigade</span>
											<span class="romanization">[tib. ruga [tib. ru khag; ch. dui]</span>
											<br/>

											<span class="definition">An large administrative unit in Tibetan communes that consisted of several villages. The full name for brigade was &quot;production brigade&quot; (tib. thon skyed ru khang; ch. shengchan dui), although most Tibetans just used the abbreviation &quot;ruga.&quot; In Tibet, communes/brigades were initiated in the mid to late 1960s.</span>
										</p>
										<p class="term">
											<span class="orth">bugdam</span>
											<span class="romanization">[tib. sbug dam]</span>
											<br/>

											<span class="definition">the seal of the Dalai Lama and thus also the name for edict promulgated by the Dalai Lama directly (over his seal).</span>
										</p>
									</div>
									<div class="alpha" id="c">
										<span class="letter">C</span>
										<p class="term">
											<span class="orth">chabril</span>
											<span class="romanization">[tib. chab ril]</span>
											<br/>
											<span class="definition">a monastic official.</span>
										</p>

										<p class="term">
											<span class="orth">chabu</span>
											<span class="romanization">[tib. phyag sbug]</span>
											<br/>
											<span class="definition">a manager-like official in monasteries.</span>
										</p>
										<p class="term">
											<span class="orth">chabyog</span>
											<span class="romanization">[tib. chab gyog]</span>
											<br/>

											<span class="definition">assistant/servant of the chabu.</span>
										</p>
										<p class="term">
											<span class="orth">Chadang</span>
											<span class="romanization">[tib. cha dang]</span>
											<br/>
											<span class="definition">A regiment in the traditional Tibetan army. It was specialized in artillery</span>
										</p>
										<p class="term">
											<span class="orth">chadrung</span>
											<span class="romanization">[tib. phyag drung]</span>
											<br/>

											<span class="definition">the head of the chanang clerks in the Tseja and Laja supply offices/treasuries of the traditional Tibetan government</span>
										</p>
										<p class="term">
											<span class="orth">cham</span>
											<span class="romanization">[tib. 'cham ]</span>
											<br/>
											<span class="definition">a religious prayer dance performed by monks</span>
										</p>
										<p class="term">
											<span class="orth">chanang</span>
											<span class="romanization">[tib. phyag nang ]</span>
											<br/>

											<span class="definition">a clerk in the Tseja and Laja supply offices/treasuries of the traditional Tibetan government</span>
										</p>
										<p class="term">
											<span class="orth">chandz&#xF6;</span>
											<span class="romanization">[phyag mdzod]</span>
											<br/>
											<span class="definition">a senior manager/treasurer of an estate or lord or monastery. Generally chandz&#xF6; handle both inner and external issues and are considered higher in power and status then nyerpa, who only handle the storerooms.</span>
										</p>

										<p class="term">
											<span class="orth">chang</span>
											<span class="romanization">1.. [tib. chang], 2. [tib. byang]</span>
											<br/>
											<span class="definition">1. Tibetan locally brewed barley beer. 2. north; nomad areas north of Lhasa in Nagchuka Prefecture 3. ch. factory.</span>
										</p>
										<p class="term">
											<span class="orth">changji</span>
											<span class="romanization">[tib. byang spyi ]</span>
											<br/>

											<span class="definition">the Governor-General of Northern Tibet</span>
										</p>
										<p class="term">
											<span class="orth">Changkyim</span>
											<span class="romanization">[tib. chang khyim]</span>
											<br/>
											<span class="definition">a Tibetan aristocratic family and official.</span>
										</p>
										<p class="term">
											<span class="orth">changpa</span>
											<span class="romanization">[tib. byang pa]</span>
											<br/>

											<span class="definition">a person (nomad) from Nakchuka prefecture north of Lhasa</span>
										</p>
										<p class="term">
											<span class="orth">chekha</span>
											<span class="romanization">[tib. phyed khag]</span>
											<br/>
											<span class="definition">literally means &quot;half,&quot; but when used in terms of tax obligations, means a family whose land and tax obligation is one half of the full obligation.</span>
										</p>

										<p class="term">
											<span class="orth">chemmo</span>
											<span class="romanization">[tib. chen mo]</span>
											<br/>
											<span class="definition">1. title for highest status among wood block carvers and most craftsmen in traditional Tibet. 2. abbreviation for the title of the Dalai Lama's Lord Chamberlain.</span>
										</p>
										<p class="term">
											<span class="orth">chenmo</span>
											<span class="romanization">[tib. chen mo]</span>
											<br/>

											<span class="definition">[chemmo] 1. title for highest status among wood block carvers and most craftsmen in traditional Tibet. 2. abbreviation for the title of the Dalai Lama's Lord Chamberlain.</span>
										</p>
										<p class="term">
											<span class="orth">chid&#xF6;n</span>
											<span class="romanization">[tib. phyi 'don] [tib. 'don]</span>
											<br/>
											<span class="definition">an outer d&#xF6;n. [d&#xF6;n] a volume measurement used for land in the old society for the estates of aristocrats. One don was equal to two gang.</span>
										</p>

										<p class="term">
											<span class="orth">chitre</span>
											<span class="romanization">[tib. phyi khral]</span>
											<br/>
											<span class="definition">The taxes and corvee labor serives one provides to the government as opposed to nangtre which are provided to one's lord.</span>
										</p>
										<p class="term">
											<span class="orth">ch&#xF6;bak&#xF6;n</span>
											<span class="romanization">[tib. chos 'bag gyon]</span>
											<br/>

											<span class="definition">a phrase meaning &quot;wearing a religious mask.&quot;</span>
										</p>
										<p class="term">
											<span class="orth">ch&#xF6;dr&#xF6;</span>
											<span class="romanization">[tib. chos 'khrol]</span>
											<br/>
											<span class="definition">Generally means &quot;release to become a monk.&quot; It refers to the permission a person needed to secure from his lord to leave the estate and become a monk. Usually a small gift was given to the lord. The person's obligation to his lord then ceased so long as he/she remains a monk or nun. Should one leave the monastic order, however, one reverted to his/her original status as a subject of the lord.</span>
										</p>

										<p class="term">
											<span class="orth">ch&#xF6;ndze</span>
											<span class="romanization">[tib. chos mdzad]</span>
											<br/>
											<span class="definition">title of monks who make a payment to become exempt from the normal monks' work obligations.</span>
										</p>
										<p class="term">
											<span class="orth">ch&#xF6;ra</span>
											<span class="romanization">[tib. chos ra]]</span>
											<br/>

											<span class="definition">the grove (or dharma grove) in monasteries where monks meet to practice debating.</span>
										</p>
										<p class="term">
											<span class="orth">ch&#xF6;shi</span>
											<span class="romanization">[tib. chos gshis ]</span>
											<br/>
											<span class="definition">a monastic estate held by a lama or monastery</span>
										</p>
										<p class="term">
											<span class="orth">ch&#xF6;thog</span>
											<span class="romanization">[tib. chos thog]</span>
											<br/>

											<span class="definition">a semester in the monastic curriculum, in other words a period of time when monks are engaged in studying their curricuklum. There are usually eight such semesters in a year, e.g., dach&#xF6; [tib. zla chos), nyishu ch&#xF6;thog [tib. nyi shu chos thog), j&#xF6;nga ch&#xF6;thog [bco lnga chos thog].</span>
										</p>
										<p class="term">
											<span class="orth">chu</span>
											<span class="romanization">[ch. qu]</span>
											<br/>
											<span class="definition">1. an administrative unit that is under a county but has authority over several xiang. Use of this unit was ended in the late 1980s throughout most of Tibet.
                      2. water</span>
										</p>

										<p class="term">
											<span class="orth">chudrang</span>
											<span class="romanization">[ch. qu zhang]</span>
											<br/>
											<span class="definition">the head of a chu [qu].</span>
										</p>
										<p class="term">
											<span class="orth">chuma</span>
											<span class="romanization">[chu ma]</span>
											<br/>

											<span class="definition">the title of people whose job it is to fetch water in monasteries.</span>
										</p>
										<p class="term">
											<span class="orth">chupa</span>
											<span class="romanization">[tib. phyu pa]</span>
											<br/>
											<span class="definition">the traditional Tibetan men and women's dress. It is like a robe that is tied at the waist. Both men an women wear such dresses although they differ slightly in color and in style.</span>
										</p>
										<p class="term">
											<span class="orth">Chushigandru</span>
											<span class="romanization">[tib. chu bzhi sgang drug]</span>
											<br/>

											<span class="definition">the anti-Chinese rebel force in Tibet that began in 1958 in Lhasa and then moved to Lhoka where they started an uprising against the Chinese. The name means &quot;four rivers and six mountain ranges&quot; and refers to Eastern Tibet (Kham and Amdo), and consisted mainly of Khampas.</span>
										</p>
										<p class="term">
											<span class="orth">Chushi gandrug</span>
											<span class="romanization">[tib. chu bzhi sgang drug]</span>
											<br/>
											<span class="definition">[Chushigandru] the anti-Chinese rebel force in Tibet that began in 1958 in Lhasa and then moved to Lhoka where they started an uprising against the Chinese. The name means &quot;four rivers and six mountain ranges&quot; and refers to Eastern Tibet (Kham and Amdo), and consisted mainly of Khampas.</span>
										</p>

										<p class="term">
											<span class="orth">class enemy</span>
											<span class="romanization">[tib. trerim [gral rim]]</span>
											<br/>
											<span class="definition">trerim is actually a translation of jie ji (&quot;class&quot;) in Chinese but it came to be used in Tibet to mean &quot;class enemy,&quot; which in Chinese is really jie ji di ren.</span>
										</p>
										<p class="term">
											<span class="orth">consultation grain</span>
											<span class="romanization">[tib. gros 'bru]</span>
											<br/>

											<span class="definition">Grain that was sold to the government after consultation between the xiang leaders and the people regarding the amount to be sold.</span>
										</p>
									</div>
									<div class="alpha" id="d">
										<span class="letter">D</span>
										<p class="term">
											<span class="orth">da biao</span>
											<span class="romanization">[ch]</span>
											<br/>
											<span class="definition">a representative.</span>
										</p>

										<p class="term">
											<span class="orth">dagnyer</span>
											<span class="romanization">[tib. bdag gnyer]</span>
											<br/>
											<span class="definition">a manager, usually in a commune/brigade.</span>
										</p>
										<p class="term">
											<span class="orth">da ming da fang</span>
											<span class="romanization">[ch.] [tib. rgyas bshad rgyas gleng]</span>
											<br/>

											<span class="definition">a political jargon phrase meaning Any viewpoint can be expressed; a free airing of views.</span>
										</p>
										<p class="term">
											<span class="orth">Damji</span>
											<span class="romanization">[tib. 'dam spyi]</span>
											<br/>
											<span class="definition">The governor of the Damshung [tib. 'dam gzhung] region north of Lhasa.</span>
										</p>
										<p class="term">
											<span class="orth">Dartsedo</span>
											<span class="romanization">[tib. dar rtse mdo ]</span>
											<br/>

											<span class="definition">the last Tibetan town in Kham; the prefectural seat of Ganzi Prefecture</span>
										</p>
										<p class="term">
											<span class="orth">daso</span>
											<span class="romanization">[tib. zla zo]</span>
											<br/>
											<span class="definition">a wooden container used as a measurement unit in some locales that is a little bit bigger than a dre [bre].</span>
										</p>
										<p class="term">
											<span class="orth">dayan</span>
											<span class="romanization">[ch.]</span>
											<br/>

											<span class="definition">a Chinese silver coin that came into widespread use in the 1950's.</span>
										</p>
										<p class="term">
											<span class="orth">dayang</span>
											<span class="romanization">[ch. da yang ] [ch.]</span>
											<br/>
											<span class="definition">a Chinese silver coin used widely in Tibet in the 1950s [dayan] a Chinese silver coin that came into widespread use in the 1950's.</span>
										</p>
										<p class="term">
											<span class="orth">dechang</span>
											<span class="romanization">[tib. lde 'chang ]</span>
											<br/>

											<span class="definition">A manager/treasurer of a Labrang.</span>
										</p>
										<p class="term">
											<span class="orth">ded&#xF6;n tshogpa</span>
											<span class="romanization">[tib. bde don tshogs pa ]</span>
											<br/>
											<span class="definition">the Tibet Welfare Association started by Shakabpa, Gyalo Thondup and Lobsang Gyentsen in India in 1954.</span>
										</p>
										<p class="term">
											<span class="orth">dekyi lingka</span>
											<span class="romanization">[tib. bde skyid gling pa ]</span>
											<br/>

											<span class="definition">The name of the office of the British Indian colonial government's bureau office in Lhasa. After Indian independence, the Indian government continued the office with the same name until 1954 when it became an Indian government consulate due to the Sino-Indian Agreement of 1954.</span>
										</p>
										<p class="term">
											<span class="orth">dekyi lingpa</span>
											<span class="romanization">[tib. bde skyid gling pa ]</span>
											<br/>
											<span class="definition">The name of the office of the British Indian colonial government's bureau office in Lhasa. After Indian independence, the Indian government continued the office with the same name until 1954 when it became an Indian government consulate due to the Sino-Indian Agreement of 1954.</span>
										</p>
										<p class="term">
											<span class="orth">democratic reforms</span>
											<span class="romanization">[tib. dmangs gtso bcos sgyur; ch. minzhu gaige]</span>
											<br/>

											<span class="definition">This term refers to the socialst reforms that began immediately after the failed 1959 uprising and the flight of the Dalai Lama into exile. At this time the traditional Tibetan government and feudal-like estate system were ended and replaced with new political and administrative structures as well as a new class system. The &quot;democratic reforms&quot; primarily involved confiscating land, animals, and other property from the feudal landlord class and those who were involved in the rebellion and redistributing these to poor peasants.</span>
										</p>
										<p class="term">
											<span class="orth">denshu</span>
											<span class="romanization">[tib. 1. gdan zhu; 2. gtan zhu]</span>
											<br/>
											<span class="definition">1. an invitation (sometimes also used to mean &quot;welcome reception ceremony); 2. long-life ceremony</span>
										</p>

										<p class="term">
											<span class="orth">densung thangla magar</span>
											<span class="romanization">[tib. bstan srung dang blangs dmag sgar]</span>
											<br/>
											<span class="definition">volunteer army to defend religion (the anti Chinese volunteer fighters)</span>
										</p>
										<p class="term">
											<span class="orth">dep&#xF6;n</span>
											<span class="romanization">[mda' dpon]</span>
											<br/>

											<span class="definition">a commander or general in charge of a regiment in the traditional Tibetan army. If a regiment had only 500 troops there was usually only one dep&#xF6;n but if there were 1,000 troops, there were usually two.</span>
										</p>
										<p class="term">
											<span class="orth">derga</span>
											<span class="romanization">[sder ka]</span>
											<br/>
											<span class="definition">a type of fried cookies that are set out in tall stacks.</span>
										</p>
										<p class="term">
											<span class="orth">deship</span>
											<span class="romanization">[tib. sde zhib ]</span>
											<br/>

											<span class="definition">An office in the Tibet Government concerned with settling law cases regarding land ownership in villages</span>
										</p>
										<p class="term">
											<span class="orth">dewashung</span>
											<span class="romanization">[tib. sde ba gzhung]</span>
											<br/>
											<span class="definition">the name of the Tibetan government</span>
										</p>
										<p class="term">
											<span class="orth">dharma grove</span>
											<span class="romanization">[chos ra]</span>
											<br/>

											<span class="definition">the walled in grove in monasteries (monastic colleges) where monks go to study/practice debating.</span>
										</p>
										<p class="term">
											<span class="orth">Dictatorship Team</span>
											<span class="romanization">[ch. zhuan zheng xiao zu; tib. srid dbang sger 'dzin  tshogs chung]</span>
											<br/>
											<span class="definition">team that was concerned with public security and judicial actions. In theory it was part of class dictatorship.</span>
										</p>
										<p class="term">
											<span class="orth">dingp&#xF6;n</span>
											<span class="romanization">[tib. lding dpon]</span>
											<br/>

											<span class="definition">a minor military officer in the traditional Tibetan army in charge of  25 soldiers.</span>
										</p>
										<p class="term">
											<span class="orth">district commissioners</span>
											<span class="romanization">[dzongb&#xF6;n (rdzong dpon)] [tib. rdzong]</span>
											<br/>
											<span class="definition">[dzong] A district or county  in the traditional Tibetan governmental structure. This large administrative unit was headed by one or two District Commissioners (dzongp&#xF6;n [rdzong dpon]) appointed by the Tibetan government in Lhasa. Typically there were one lay official and one monk official sent from Lhasa for three year terms. They were responsible for collecting taxes and adjudicating disputes in their district.  They are roughly equivalent to counties (ch. xian) in the current system of administration. The system of dzong began during the time of the Phamodrupa Kings of Tibet in the late 14th century. At the end of the traditional system in 1959, there were approximately XX dzong in Tibet.</span>
										</p>

										<p class="term">
											<span class="orth">diu</span>
											<span class="romanization">[tib. rde'u]</span>
											<br/>
											<span class="definition">The traditional method of Tibetan counting using a board and a variety of items like beans and sticks and stones.</span>
										</p>
										<p class="term">
											<span class="orth">dobdo</span>
											<span class="romanization">[tib. rdab rdob]</span>
											<br/>

											<span class="definition">a  deviant type of fighting or &quot;punk&quot; monk who engages in fighting and other unusual behaviors for monks</span>
										</p>
										<p class="term">
											<span class="orth">doji</span>
											<span class="romanization">[tib. mdo spyi ]</span>
											<br/>
											<span class="definition">The governor-general of Eastern Tibet under the traditional Tibetan government. (Abbreviation for dome jigyab--mdo smad spyi khyab). His headquarters was at Chamdo.</span>
										</p>

										<p class="term">
											<span class="orth">Dombor</span>
											<span class="romanization">[tib. gdong por]</span>
											<br/>
											<span class="definition">an aristocratic official and family name (also knowsn as Tashi lingpa [bkris gling pa].</span>
										</p>
										<p class="term">
											<span class="orth">dome</span>
											<span class="romanization">[tib. mdo smad ]</span>
											<br/>

											<span class="definition">The Kham region of Eastern Tibet.</span>
										</p>
										<p class="term">
											<span class="orth">d&#xF6;n</span>
											<span class="romanization">[tib. 'don]</span>
											<br/>
											<span class="definition">a volume measurement used for land in the old society for the estates of aristocrats. One don was equal to two gang.</span>
										</p>
										<p class="term">
											<span class="orth">donation grain</span>
											<span class="romanization">[tib. rgyal gces gzhung 'bru; ch. gong liang]</span>
											<br/>

											<span class="definition">[patriotic donation grain] A kind of tax collected by the government during the commune and mutual aid team eras. It was grain that families or brigades had to give the government out of &quot;patriotism&quot; without any payment. The amount was initially based on real yields but then was set by the government based on presumed yields.</span>
										</p>
										<p class="term">
											<span class="orth">donggo</span>
											<span class="romanization">[tib. btong sgo]</span>
											<br/>
											<span class="definition">An obligation to carry out a rite or prayer session in a monastery, for example, providing food and tea for all the monks in one's monastery college at a prayer assembly in addition to the materials needed for the actual ritual. Or it could be an obligation to give all the monks a set amount of grain. For example, when a monastery office holder left office, he usually had to do (fund) a certain kind of donggo. There were also endowments that monks were by turns to use for a limited period of time in order to fund a donggo from the income they collected from the endowment.</span>
										</p>

										<p class="term">
											<span class="orth">dongke</span>
											<span class="romanization">[tib. dong khal] [tib. dong pa]</span>
											<br/>
											<span class="definition">[dongpa] 1. a local volume measurement equal to 1/8th of a kharu. 2. a volume measure used in Tsang equal to half of a ke.??</span>
										</p>
										<p class="term">
											<span class="orth">dongpa</span>
											<span class="romanization">[tib. dong pa]</span>
											<br/>

											<span class="definition">1. a local volume measurement equal to 1/8th of a kharu. 2. a volume measure used in Tsang equal to half of a ke.??</span>
										</p>
										<p class="term">
											<span class="orth">dot&#xF6;</span>
											<span class="romanization">[tib. mdo stod ]</span>
											<br/>
											<span class="definition">The Amdo region of Eastern Tibet.</span>
										</p>
										<p class="term">
											<span class="orth">dotse</span>
											<span class="romanization">[tib. rdo tshad]</span>
											<br/>

											<span class="definition">a currency unit in traditional Tibet that was equal to 50 ng&#xFC;lsang.</span>
										</p>
										<p class="term">
											<span class="orth">dowa</span>
											<span class="romanization">[tib. do ba]</span>
											<br/>
											<span class="definition">a volume measure in Panam dzong. 4 dowa = 6 drong ??[grong]</span>
										</p>
										<p class="term">
											<span class="orth">dre</span>
											<span class="romanization">[tib. bre]</span>
											<br/>

											<span class="definition">a unit of traditional measurement in Tibet, 20 of which usually equaled one khe, although in some areas there were only 16 dre in one khe</span>
										</p>
										<p class="term">
											<span class="orth">dri</span>
											<span class="romanization">[tib. 'bri ]</span>
											<br/>
											<span class="definition">A female yak.</span>
										</p>
										<p class="term">
											<span class="orth">Drichu</span>
											<span class="romanization">[tib. 'bri chu ]</span>
											<br/>

											<span class="definition">the Upper Yangtse River that formed the boundary between political Tibet and China in the later 1930s and 40s</span>
										</p>
										<p class="term">
											<span class="orth">dringpa</span>
											<span class="romanization">[tib. 'bring pa]</span>
											<br/>
											<span class="definition">middle class in the communist period in Tibet (one of the classifications of people).</span>
										</p>
										<p class="term">
											<span class="orth">Droma</span>
											<span class="romanization">[tib. sgrol ma]</span>
											<br/>

											<span class="definition">the goddess Tara.</span>
										</p>
										<p class="term">
											<span class="orth">droma dresi</span>
											<span class="romanization">[tib. gro ma 'bras sil]</span>
											<br/>
											<span class="definition">a special dish consisting of sweetened rice, melted butter and miniature sweet potatoes (gro ma).</span>
										</p>
										<p class="term">
											<span class="orth">Drongdrag</span>
											<span class="romanization">[tib. grong drag]</span>
											<br/>

											<span class="definition">The army regiment created during the 13th Dalai Lama's reign whose members were recruited from better famililes. As a result, the name &quot;Drongdrag&quot; means &quot;better families.&quot;</span>
										</p>
										<p class="term">
											<span class="orth">drong khe</span>
											<span class="romanization">[grong khal]</span>
											<br/>
											<span class="definition">a volume measure in Panam. 1 drong khe = 4 dowa??</span>
										</p>

										<p class="term">
											<span class="orth">dr&#xF6;nyer</span>
											<span class="romanization">[tib. mgron gnyer ]</span>
											<br/>
											<span class="definition">The steward of an aristocrat or labrang.</span>
										</p>
										<p class="term">
											<span class="orth">dr&#xF6;nyerchemmo</span>
											<span class="romanization">[tib. mgron gnyer chen mo ] [tib. drung yig chen mo]</span>
											<br/>

											<span class="definition">[trunyichemmo] TOne of the four heads of the yigtshang office (Ecclesiasitics Office) of the traditional Tibetan government. This was the highest office that dealt with monastic and religious affairs and the office in charge of the recruitment and promotion of monk officials.</span>
										</p>
										<p class="term">
											<span class="orth">droso</span>
											<span class="romanization">[tib. gro so phye mar ] [tib. thamdzing tsondu ('thab 'dzing tshogs 'du); ch. douzheng hui]</span>
											<br/>
											<span class="definition">The traditional ceremonial wood box that is divided into two sections, one side filled with tsampa and butter and the other with popped grain. [struggle session] Public accusation meetings at which the masses criticized and attacked (struggled against) class enemies and reactionaries, etc. Typically, the object of a struggle session would stand in front of the meeting bent over at the waist while the masses questioned and criticized, and often beat, him or her.</span>
										</p>
										<p class="term">
											<span class="orth">droso-chemar</span>
											<span class="romanization">[tib. gro so phye mar]</span>
											<br/>

											<span class="definition">the traditional Tibetan New Year offering box with two sections, one section is filled with mixture of Tsampa and butter, another with the wheat.</span>
										</p>
										<p class="term">
											<span class="orth">drungja</span>
											<span class="romanization">[tib. drung ja]</span>
											<br/>
											<span class="definition">[trungja] 1. the rite of daily tea served to Tibetan monk officials. It started at about 9 and lasted for an hour or so. When the Tsega was in Potala it was held there and then it was in Norbulinga it was held there. All monk officials in Lhasa were expected to attend. This can also refer to other formal morning tea prayer ceremonies, for example, when the regent was traveling.</span>
										</p>
										<p class="term">
											<span class="orth">drungkor</span>
											<span class="romanization">[tib. drung 'khor ]</span>
											<br/>

											<span class="definition">the lay officials (in contrast to the monk officials) in the traditional Tibetan governmnet</span>
										</p>
										<p class="term">
											<span class="orth">Drungtsab</span>
											<span class="romanization">[tib. drung tshab]</span>
											<br/>
											<span class="definition">acting Trunyichemmo.</span>
										</p>
										<p class="term">
											<span class="orth">drungtsi</span>
											<span class="romanization">[tib. drung rtsis] [tib. drung rtsis ]</span>
											<br/>

											<span class="definition">[trungtsi] The eight trunyichemmo and tsip&#xF6;n; these eight officials (the four trunyichemmo and four tsip&#xF6;n) were often called to meet with the Kashag to discuss important issues. They also were the smallest of the Tibetan traditional government assemblies.</span>
										</p>
										<p class="term">
											<span class="orth">drungtsigye</span>
											<span class="romanization">[tib. drung rtsis brgyad]</span>
											<br/>
											<span class="definition">[trungtsigye] the eight trunyichemmo and tsip&#xF6;n; these eight officials (the four trunyichemmo and four tsip&#xF6;n) were often called to meet with the Kashag to discuss important issues. They were the smallest of the Tibetan traditional government assemblies.</span>
										</p>

										<p class="term">
											<span class="orth">drunyichemmo</span>
											<span class="romanization">[tib. drung yig chen mo]</span>
											<br/>
											<span class="definition">[trunyichemmo] TOne of the four heads of the yigtshang office (Ecclesiasitics Office) of the traditional Tibetan government. This was the highest office that dealt with monastic and religious affairs and the office in charge of the recruitment and promotion of monk officials.</span>
										</p>
										<p class="term">
											<span class="orth">d&#xFC;chen</span>
											<span class="romanization">[tib. bsdus chen]</span>
											<br/>

											<span class="definition">The third class in the d&#xFC;dra monastic curriculum.</span>
										</p>
										<p class="term">
											<span class="orth">d&#xFC;dra</span>
											<span class="romanization">[tib. bsdus grwa]</span>
											<br/>
											<span class="definition">The first curriculum in Buddhist dialectics in Gelugpa monasteries. It is an abbreviated course in logic (tsema [tshad ma]). There are 6 classes and monks ideally study one class each year. The first class is khatog garmar [tib. kha dog dkar dmar], then d&#xFC;dring [tib. bsdus 'bring], then d&#xFC;chen [tib. bsdus chen], then tagrik [tib. rtags rig], and then lurik [tib. blu rig].</span>
										</p>

										<p class="term">
											<span class="orth">d&#xFC;dring</span>
											<span class="romanization">[tib. bsdus 'bring]</span>
											<br/>
											<span class="definition">The second class in the d&#xFC;dra monastic curriculum.</span>
										</p>
										<p class="term">
											<span class="orth">d&#xFC;jung</span>
											<span class="romanization">[tib. dud chung]</span>
											<br/>

											<span class="definition">A type of serf (miser) household in traditional Tibetan society. D&#xFC;jung belonged to a a lord, but did not hold tax-base land (tib. khral rten). They usually were poor and survived by working for others or leasing land from treba (taxpayer) households.</span>
										</p>
										<p class="term">
											<span class="orth">durgang</span>
											<span class="romanization">[tib. 'dur rkang]</span>
											<br/>
											<span class="definition">a type of tax-base land that requires its owner to provide corvee carrying animals.</span>
										</p>
										<p class="term">
											<span class="orth">d&#xFC;trang</span>
											<span class="romanization">[ch.]</span>
											<br/>

											<span class="definition">head/ leader of an office.</span>
										</p>
										<p class="term">
											<span class="orth">dzadrung</span>
											<span class="romanization">[tib.rdza drung]</span>
											<br/>
											<span class="definition">Abbr. Dzasa and Drunyichemmo. Frequently refers to the two officials, Dzasa Kusangtse and Drunyichemmo Lha'utara who were sent from Yadong to negotiatie in 1951 in Beijing.</span>
										</p>
										<p class="term">
											<span class="orth">dzasa</span>
											<span class="romanization">[tib. rdza sa]</span>
											<br/>

											<span class="definition">1. a high rank in the Tibetan government. 2. a top manager-like official for the labrang of important incarnate lamas.</span>
										</p>
										<p class="term">
											<span class="orth">dzo</span>
											<span class="romanization">[tib. mdzo]</span>
											<br/>
											<span class="definition">a cross between a yak and a cow/ox.</span>
										</p>
										<p class="term">
											<span class="orth">dzomo</span>
											<span class="romanization">[tib. mdzo mo]</span>
											<br/>

											<span class="definition">a female dzo.</span>
										</p>
										<p class="term">
											<span class="orth">dzong</span>
											<span class="romanization">[tib. rdzong]</span>
											<br/>
											<span class="definition">A district or county  in the traditional Tibetan governmental structure. This large administrative unit was headed by one or two District Commissioners (dzongp&#xF6;n [rdzong dpon]) appointed by the Tibetan government in Lhasa. Typically there were one lay official and one monk official sent from Lhasa for three year terms. They were responsible for collecting taxes and adjudicating disputes in their district.  They are roughly equivalent to counties (ch. xian) in the current system of administration. The system of dzong began during the time of the Phamodrupa Kings of Tibet in the late 14th century. At the end of the traditional system in 1959, there were approximately XX dzong in Tibet.</span>
										</p>
										<p class="term">
											<span class="orth">dzongp&#xF6;n</span>
											<span class="romanization">[tib. rdzong dpon]</span>
											<br/>

											<span class="definition">District commissioner or governor in charge of a dzong in the traditional Tibetan government.</span>
										</p>
									</div>
									<div class="alpha" id="e">
										<span class="letter">E</span>
										<p class="term">
											<span class="orth">Ecclesiastic Office</span>
											<span class="romanization">[tib. yigtsang (yig tshang)]</span>
											<br/>
											<span class="definition">the highest office dealing with monastic and religious affairs in the traditional Tibetan government. It was headed by 4 fourth rank monk officials called trunyichemmo. The seniotn trunyichemmo was called Ta Lama.</span>
										</p>

										<p class="term">
											<span class="orth">Education through Labor</span>
											<span class="romanization">[tib. ngal rtsol slob gso; ch. lao jiao]</span>
											<br/>
											<span class="definition">A kind of compulsory educational reform applied towards persons who violated the law and shirked responsibility for their offenses (and who care able bodied). The term of labor is 1-3 years usually, and can be extended if necessary.  It joins doing productive labor and educating or reforming ones thinking.  After the term of labor is completed, the individual is not discriminated against in employment or school.  These people are not ones who first when to prison (mostly prositiutes and thieves).</span>
										</p>
										<p class="term">
											<span class="orth">Ench&#xF6;ndze</span>
											<span class="romanization">[tib. dben chos mdzad]</span>
											<br/>

											<span class="definition">a monastic term for higher status monks that included, ch&#xF6;ndze, abbots, shungshab (monk officials), ex-umdze, ex-jiso, ex-phodrang depa, ex-chandz&#xF6;.</span>
										</p>
									</div>
									<div class="alpha" id="f">
										<span class="letter">F</span>
										<p class="term">
											<span class="orth">fen</span>
											<span class="romanization">[ch.]</span>
											<br/>

											<span class="definition">1/100th of a yuan, one cent.</span>
										</p>
									</div>
									<div class="alpha" id="g">
										<span class="letter">G</span>
										<p class="term">
											<span class="orth">Gadang</span>
											<span class="romanization">[tib.ga dang]</span>
											<br/>
											<span class="definition">the traditional Tibetan army numbered its regiments alphabetically rather than numerically. Consequently, the Gadang regiment refers to the &quot;ga&quot; regiment or the 3rd Regiment since &quot;ga&quot; is the third letter of the Tibetan alphabet.  It was also known as the Shigatse Regiment.</span>
										</p>

										<p class="term">
											<span class="orth">gadrukpa</span>
											<span class="romanization">[tib. gar phrug pa]</span>
											<br/>
											<span class="definition">the ceremonial dance troupe of the Dalai and Panchen Lamas. Young boys were conscripted as a corvee levy for this from serf families who were compensated for the loss of a son by a reduction in their other taxes. Such boys left their families and moved either to Lhasa or Shigatse.</span>
										</p>
										<p class="term">
											<span class="orth">gadrung</span>
											<span class="romanization">[tib. bka' drung] [tib. bka' drung]</span>
											<br/>

											<span class="definition">Gadrung were important administrative aides to the Kal&#xF6;ns. See Kadrung [kadrung] Kadrung were important administrative aides to the Kashag Ministers. There were usually two of these, both aristocratic lay officials. Their job was to assist the ministers any way the mionisters needed, but their usual work involved writing whatever letters, documents, orders, recommendations the Kashag sent to the Dalai Lama and other offices and the edicts the Kashag sent to counties. By custom, the the seal of the Kashag could only be applied by the 2 Kadrung, even if the ministers were there. People of officials under the 5th rank had to sumbit their petitions first through the Kadrung (or kandr&#xF6;n). There were also two kandr&#xF6;n [bka' mgron] in the Kashag office. They were also aristocratic lay officials and generally were less powerful than the kadrung, handling lessor requests to the Kashag. Their office was called the Dr&#xF6;ndrung khang [tib. mgron drung khang].</span>
										</p>
										<p class="term">
											<span class="orth">gag</span>
											<span class="romanization">[tib. 'gag ]</span>
											<br/>
											<span class="definition">The secretariate office of either the Dalai Lama (rtse 'gag) or the Regent [zhol 'gag].</span>
										</p>

										<p class="term">
											<span class="orth">gagpa</span>
											<span class="romanization">[tib. 'gag pa]</span>
											<br/>
											<span class="definition">an official in the traditional Tibetan government of the ordinary rank  (tib. dkyus ma) that served as a bodyguard for the Council Ministers (Kal&#xF6;n [hyperlink) and Prime Minister (Sitsab [hyperlink]). They did not carry guns but carried a whip and preceeded the ministers when they were traveling outside. They also had other tasks at ceremonies, etc.</span>
										</p>
										<p class="term">
											<span class="orth">Ganden Ngamj&#xF6;</span>
											<span class="romanization">[tib. dga' ldan lnga mchod]</span>
											<br/>

											<span class="definition">the holiday commemorating the deat of Tsongkhaa. It falls on the 25th of the 10 Tibetan lunar month.</span>
										</p>
										<p class="term">
											<span class="orth">Ganden Potrang</span>
											<span class="romanization">[tib. dga' ldan pho brang]</span>
											<br/>
											<span class="definition">the official name of the traditional Tibetan government founded by the 5th Dalai Lama in 1642.</span>
										</p>
										<p class="term">
											<span class="orth">Ganden Tripa</span>
											<span class="romanization">[tib. dga' ldan khri pa ]</span>
											<br/>

											<span class="definition">The chief abbot of Ganden Monastery who is considered to be hold the throne of Tsongkapa, the founder of the Gelupa sect.</span>
										</p>
										<p class="term">
											<span class="orth">gandr&#xF6;n</span>
											<span class="romanization">[tib. bka' mgron] [tib. bka; mgron ]</span>
											<br/>
											<span class="definition">lay aristocratic official who was an aide to the Kashag, see gandr&#xF6;n [kandr&#xF6;n] Kand&#xF6;n were administrative aides to the Kashag. There were usually three of these, all aristocratic lay officials. They were in charge of petitions to the Kashag.  
                      See also definition of Kadrung.</span>
										</p>

										<p class="term">
											<span class="orth">gandru</span>
											<span class="romanization">[tib. skar 'bru] [tib. gandru (skar 'bru); ch. gong fen liang]</span>
											<br/>
											<span class="definition">[work point grain] grain paid by a production team/ brigade according to the number of work points that one accumulated through work performance.</span>
										</p>
										<p class="term">
											<span class="orth">gang</span>
											<span class="romanization">[tib. rkang]</span>
											<br/>

											<span class="definition">the basic land measurement unit for tax obligations in the old society. One gang was considered a full tax unit of land. A gang was measured by volume, specifically by the amount of seed (s&#xF6;nkhe) that could be sown. This amount was not standardized and the size of one gang varied under different lords.</span>
										</p>
										<p class="term">
											<span class="orth">gantsang</span>
											<span class="romanization">[tib. 'gan gtsang; ch. cheng bao]</span>
											<br/>
											<span class="definition">[gentsang] The new economic system that replaced the communal system in the early 1980's. It literally means &quot;complete responsiblity&quot; (system). Under this new system, the commune/brigade's land was divided among individual households under a long-term lease arrangement and households were given complete responsibility over their own production.</span>
										</p>

										<p class="term">
											<span class="orth">Gantshang</span>
											<span class="romanization">[tib. 'gan gtsang; ch. cheng bao]</span>
											<br/>
											<span class="definition">[gentsang] The new economic system that replaced the communal system in the early 1980's. It literally means &quot;complete responsiblity&quot; (system). Under this new system, the commune/brigade's land was divided among individual households under a long-term lease arrangement and households were given complete responsibility over their own production.</span>
										</p>
										<p class="term">
											<span class="orth">gao</span>
											<span class="romanization">[tib. ga'u ]</span>
											<br/>

											<span class="definition">1. a small box/pendant for keeping religious objects, small staues, etc. 2. a small jewekery box worn by women as a necklace. 3 a small box worn on the hair of lay officials.</span>
										</p>
										<p class="term">
											<span class="orth">Gashag</span>
											<span class="romanization">[tib. bka' shag]</span>
											<br/>
											<span class="definition">[kashag] the Council of Ministers. The highest office in the traditional Tibetan government. It usually consisted of 4 or more ministers (kal&#xF6;n) who collectively made decisions.</span>
										</p>
										<p class="term">
											<span class="orth">gashib</span>
											<span class="romanization">[tib. bka' zhib]</span>
											<br/>

											<span class="definition">a government investigation committee</span>
										</p>
										<p class="term">
											<span class="orth">gatsab</span>
											<span class="romanization">[tib. bka' tshab] [tib. bka' tshab]</span>
											<br/>
											<span class="definition">[katsab] acting kal&#xF6;n.</span>
										</p>
										<p class="term">
											<span class="orth">gegen</span>
											<span class="romanization">[tib. dge rgan]</span>
											<br/>

											<span class="definition">1. teacher in a school.  2. in monastic settings it also refers to the adult monk who acts as a guardian to a younger monk. In such cases the younger monk typically lives with him in his apartment (shag). In monasteries, however, it can also mean a real teacher, or the monk.who served as the guarantor for a new monk.</span>
										</p>
										<p class="term">
											<span class="orth">geg&#xF6;</span>
											<span class="romanization">[tib. dge skos ]</span>
											<br/>
											<span class="definition">A disciplinary official in the monastery</span>
										</p>
										<p class="term">
											<span class="orth">gelong</span>
											<span class="romanization">[tib. dge slong]</span>
											<br/>

											<span class="definition">Full monk's vows. A monk who has taken full vows.</span>
										</p>
										<p class="term">
											<span class="orth">gembo</span>
											<span class="romanization">[tib. rgan po]</span>
											<br/>
											<span class="definition">[gempo] A village headman. Such headmen were responsible for organizing the different households in their village to pay the village's in-kind and labor taxes. The also played a role in settling minor disputes and were the link between the village and the higher authorities. In some areas they were elected by the village households, while in others the position was hereditary or appointed.</span>
										</p>
										<p class="term">
											<span class="orth">gempo</span>
											<span class="romanization">[tib. rgan po]</span>
											<br/>

											<span class="definition">A village headman. Such headmen were responsible for organizing the different households in their village to pay the village's in-kind and labor taxes. The also played a role in settling minor disputes and were the link between the village and the higher authorities. In some areas they were elected by the village households, while in others the position was hereditary or appointed.</span>
										</p>
										<p class="term">
											<span class="orth">gentsang</span>
											<span class="romanization">[tib. 'gan gtsang; ch. cheng bao]</span>
											<br/>
											<span class="definition">The new economic system that replaced the communal system in the early 1980's. It literally means &quot;complete responsiblity&quot; (system). Under this new system, the commune/brigade's land was divided among individual households under a long-term lease arrangement and households were given complete responsibility over their own production.</span>
										</p>

										<p class="term">
											<span class="orth">gepo</span>
											<span class="romanization">[tib. dge po]</span>
											<br/>
											<span class="definition">a minor official on an estate something like a headman</span>
										</p>
										<p class="term">
											<span class="orth">gerpa</span>
											<span class="romanization">[sger pa]</span>
											<br/>

											<span class="definition">1. aristocrats. 2. private students in the tse labdra monk official training school.</span>
										</p>
										<p class="term">
											<span class="orth">gertshab</span>
											<span class="romanization">[tib. sger tshab] [tib. mnga' tshab; ch. lingzhu dailiren (dailiren)]</span>
											<br/>
											<span class="definition">[ngatshab] agent/representative of the serf lord.</span>
										</p>
										<p class="term">
											<span class="orth">geshe</span>
											<span class="romanization">[tib. dge shes]</span>
											<br/>

											<span class="definition">an advanced degree earned by scholar monks</span>
										</p>
										<p class="term">
											<span class="orth">gets&#xFC;l</span>
											<span class="romanization">[tib. dge tshul ]</span>
											<br/>
											<span class="definition">the novice vows that Buddhist monks and nuns take</span>
										</p>
										<p class="term">
											<span class="orth">geyog</span>
											<span class="romanization">[tib. dge g.yog ]</span>
											<br/>

											<span class="definition">Assistants to the disciplinary official (shengo) in monasteries.</span>
										</p>
										<p class="term">
											<span class="orth">gidru</span>
											<span class="romanization">[tib. dge phrug]</span>
											<br/>
											<span class="definition">1. student. 2. disciple. Usually used for monks.</span>
										</p>
										<p class="term">
											<span class="orth">GMD</span>
											<span class="romanization">[ch. abbr. Guomindang ]</span>
											<br/>

											<span class="definition">The Nationalist Party of Chiang Kaishek.</span>
										</p>
										<p class="term">
											<span class="orth">Gomang</span>
											<span class="romanization">[tib.sgo mang]</span>
											<br/>
											<span class="definition">one of the larger Tradzang (Colleges) in Drepung Monastery.</span>
										</p>
										<p class="term">
											<span class="orth">gombo</span>
											<span class="romanization">[tib. mgon po ba ]</span>
											<br/>

											<span class="definition">the monk who does the prayers to propitiate the protective deities</span>
										</p>
										<p class="term">
											<span class="orth">gombokhang</span>
											<span class="romanization">[tib. mgon po khang]</span>
											<br/>
											<span class="definition">the chapel of the protector deity Gompo in Norbulingka</span>
										</p>
										<p class="term">
											<span class="orth">gongja</span>
											<span class="romanization">[tib. kong phyag]</span>
											<br/>

											<span class="definition">the manager of Kongpo khamtsen in Drepung monastery</span>
										</p>
										<p class="term">
											<span class="orth">g&#xF6;nkhang</span>
											<span class="romanization">[tib. mgon khang]</span>
											<br/>
											<span class="definition">The chapel or room devoted to a protector deity.</span>
										</p>
										<p class="term">
											<span class="orth">g&#xF6;ph&#xFC; jusur</span>
											<span class="romanization">[tib. bgos phud bcu zur]</span>
											<br/>

											<span class="definition">a terms that means the judge in a law case confiscates one tenth of the things that were divided for himself.</span>
										</p>
										<p class="term">
											<span class="orth">government (donation) grain</span>
											<span class="romanization">[tib. tshong 'bru; ch. shang ping liang] [tib. rgyal gces gzhung 'bru; ch. gong liang]</span>
											<br/>
											<span class="definition">[patriotic donation grain] A kind of tax collected by the government during the commune and mutual aid team eras. It was grain that families or brigades had to give the government out of &quot;patriotism&quot; without any payment. The amount was initially based on real yields but then was set by the government based on presumed yields.</span>
										</p>

										<p class="term">
											<span class="orth">grain quota tax</span>
											<span class="romanization">[tib. tshong 'bru; ch. shang ping liang] [tib. tsongdru (tshong 'bru); ch. shang ping liang]</span>
											<br/>
											<span class="definition">[selling grain tax] Tsongdru was a government set quota of grain that villages (and in turn households in the villages) had sell to the government at a government set price. This was collected during the Mutual Aid Team and Commune periods (1960-the later 1970s).</span>
										</p>
										<p class="term">
											<span class="orth">gusung</span>
											<span class="romanization">[tib. sku srung]</span>
											<br/>

											<span class="definition">1. bodyguard. 2. the &quot;bodyguard&quot; regiment of the Dalai Lama that was also known as the Kadang (tib. ka dang)regiment. 2. the bodyguard regiment of the Panchen Lama.</span>
										</p>
										<p class="term">
											<span class="orth">gutor</span>
											<span class="romanization">[tib. dgu gtor ]</span>
											<br/>
											<span class="definition">The ritual religious dance on the 29th day of the 12th Tibetan lunar month at which time the past year's sins were expelled</span>
										</p>

										<p class="term">
											<span class="orth">gyab</span>
											<span class="romanization">[tib.]</span>
											<br/>
											<span class="definition">a roof like projection or verandah located on the top of  a house.</span>
										</p>
										<p class="term">
											<span class="orth">gyabden</span>
											<span class="romanization">[tib. skyabs rten]</span>
											<br/>

											<span class="definition">(&quot;present of asking help&quot;) gifts given to a judge or official hearing a case to ask his help in settling it in your favor.</span>
										</p>
										<p class="term">
											<span class="orth">gyagp&#xF6;n</span>
											<span class="romanization">[tib. brgya dpon]</span>
											<br/>
											<span class="definition">1. an army (NCO) officer in the traditional Tibetan army who was in charge of a gyashog or unit of 100 troops. 2. a minor official on an estate.</span>
										</p>

										<p class="term">
											<span class="orth">gyakag</span>
											<span class="romanization">[tib. rgya khag]</span>
											<br/>
											<span class="definition">A monk guard or bodyguard.</span>
										</p>
										<p class="term">
											<span class="orth">gyama</span>
											<span class="romanization">[tib. rgya ma]</span>
											<br/>

											<span class="definition">a jin [ch.] that is equal to 1.1 lbs. (half a kilogram].</span>
										</p>
										<p class="term">
											<span class="orth">gyarshib</span>
											<span class="romanization">[tib. skyar zhib; ch. fucha]</span>
											<br/>
											<span class="definition">the reinvestigation campaign that started in 1960 to re-examine the initial classifications of people into different class categories in 1959.</span>
										</p>
										<p class="term">
											<span class="orth">gyashog</span>
											<span class="romanization">[tib. brgya shog]</span>
											<br/>

											<span class="definition">an army unit in the traditional Tibetan army consisting of 100 soldiers.</span>
										</p>
										<p class="term">
											<span class="orth">Gyatso</span>
											<span class="romanization">[tib.rgya mtsho]</span>
											<br/>
											<span class="definition">1. a local official similar to a gembo (headman).
                      2. an area in the Tsang region of Central Tibet [gembo]</span>
										</p>
										<p class="term">
											<span class="orth">gye</span>
											<span class="romanization">[tib. 'gye ]</span>
											<br/>

											<span class="definition">alms (in money) given directly to monks</span>
										</p>
										<p class="term">
											<span class="orth">Gyenlo</span>
											<span class="romanization">[tib. gyan log]</span>
											<br/>
											<span class="definition">one of the two major revolutionary organizations during the Cultural Revolution in Tibet. It is sometimes translated in English as the &quot;Rebels.&quot; Of the two dominant revolutionary groups in Tibet, it was the less &quot;establishment&quot; and more leftist oriented.</span>
										</p>

										<p class="term">
											<span class="orth">Gyenlog</span>
											<span class="romanization">[tib. gyan log]</span>
											<br/>
											<span class="definition">[Gyenlo] one of the two major revolutionary organizations during the Cultural Revolution in Tibet. It is sometimes translated in English as the &quot;Rebels.&quot; Of the two dominant revolutionary groups in Tibet, it was the less &quot;establishment&quot; and more leftist oriented.</span>
										</p>

										<p class="term">
											<span class="orth">gyetor</span>
											<span class="romanization">[tib. brgyad gtor ]</span>
											<br/>
											<span class="definition">The government ceremony held on the eighth day of the Third lunar month in the Potala. It was the day when officials forally switched from their winter outfits to their summer ones.</span>
										</p>
										<p class="term">
											<span class="orth">Gyetse luding</span>
											<span class="romanization">[tib. skyed tshal klu lding]</span>
											<br/>

											<span class="definition">It is considered respectful to welcome [phebs bsu] visiting high officials some ways outside of Lhasa, much as we in the U.S. would go to meet someone at the airport. Gyetse luding was the standard reception site for this. It was located on the main road west of Lhasa between Drepung and the Norbulinga palace.</span>
										</p>
										<p class="term">
											<span class="orth">gyewo</span>
											<span class="romanization">[tib. sgye bo]</span>
											<br/>
											<span class="definition">In some areas, the assistants to the lep&#xF6;n. In other areas the same as a lep&#xF6;n or work supervisor.</span>
										</p>

										<p class="term">
											<span class="orth">gyorp&#xF6;n</span>
											<span class="romanization">[skyor dpon]</span>
											<br/>
											<span class="definition">the monastic official who functions as the main teacher in the Dharma Grove (Ch&#xF6;ra) where monks go to study debating and logic. He is called gyrop&#xF6;n because he recities the texts by heart to the monk students.</span>
										</p>
										<p class="term">
											<span class="orth">Gy&#xFC; d&#xF6;(pa)</span>
											<span class="romanization">[tib. rgyud stod pa]</span>
											<br/>

											<span class="definition">The Upper Tantric Monastic College in Lhasa.</span>
										</p>
										<p class="term">
											<span class="orth">Gy&#xFC; me(pa)</span>
											<span class="romanization">[tib. rgyud smad pa]</span>
											<br/>
											<span class="definition">The Lower Tantric Monastic College in Lhasa.</span>
										</p>

										<p class="term">
											<span class="orth">Gy&#xFC;pa</span>
											<span class="romanization">[tib. rgyud pa]</span>
											<br/>
											<span class="definition">The Tantric Colleges in Lhasa, of which there were two, the Upper Tantric Colleg and the Lower Tantric College.</span>
										</p>
										<p class="term">
											<span class="orth">gy&#xFC;shi</span>
											<span class="romanization">[tib. rgyud bzhi]</span>
											<br/>

											<span class="definition">the name of the four basic medical texts.</span>
										</p>
									</div>
									<div class="alpha" id="h">
										<span class="letter">H</span>
										<p class="term">
											<span class="orth">Hamdong</span>
											<span class="romanization">[tib. har gdong]</span>
											<br/>
											<span class="definition">a khamtsen in Gomand tratsang of Drepung Monastery.</span>
										</p>

										<p class="term">
											<span class="orth">hat</span>
											<span class="romanization">[tib. zhwa mo; ch. dai mao]</span>
											<br/>
											<span class="definition">This was a common political slang term (label) used for people who were classified as class enemies or reactionaries. It was used as, &quot;They put the hat on him&quot;, or &quot;They never took his hat off.&quot;</span>
										</p>
										<p class="term">
											<span class="orth">HH</span>
											<span class="romanization"/>
											<br/>
											<span class="definition">abbreviation: His Holiness (the Dalai Lama).</span>
										</p>
										<p class="term">
											<span class="orth">hragdu gyepa</span>
											<span class="romanization">[tib. hrag bsdus rgyas pa]</span>
											<br/>
											<span class="definition">The enlarged abbreviated assembly of the traditional Tibetan governmnet. It included the trungtsigye, the abbots and ex-abbots of Sendregasum, and representative from all the government ranks.</span>
										</p>
										<p class="term">
											<span class="orth">human lease serf</span>
											<span class="romanization">[tib. mibo, (mi bogs)]</span>
											<br/>

											<span class="definition">a type of serf who secured his freedom to leave the estate and go where he/she wanted for a lee paid annually to the lord in perpetuity. Children of the same sex (i.e., sons of a male) inherited this status.</span>
										</p>
									</div>
									<div class="alpha" id="i">
										<span class="letter">I</span>
										<p class="term">
											<span class="orth">inner tax</span>
											<span class="romanization">[nang khral]</span>
											<br/>
											<span class="definition">the tax that serfs pay to their lord in contrast to the &quot;outer tax&quot; that they pay to the government.</span>
										</p>
									</div>
									<div class="alpha" id="j">
										<span class="letter">J</span>
										<p class="term">
											<span class="orth">Jadang</span>
											<span class="romanization">[tib. ja dang]</span>
											<br/>
											<span class="definition">One of the regiments in the trazditional Tibetan army. At the time of the Chamdo war, its commander was Phulungwa. etc.</span>
										</p>
										<p class="term">
											<span class="orth">jagd&#xFC;</span>
											<span class="romanization">[tib. ljags mdud]</span>
											<br/>

											<span class="definition">A thin ribbon/scarf that lamas and oracles and the Dalai Lama give out to people for protection.</span>
										</p>
										<p class="term">
											<span class="orth">jama</span>
											<span class="romanization">[tib. ja ma]</span>
											<br/>
											<span class="definition">the monk(s) in charge of the monastery's kitchen.</span>
										</p>
										<p class="term">
											<span class="orth">jamthu</span>
											<span class="romanization">[tib. 'jam thug]</span>
											<br/>

											<span class="definition">a porridge made by adding tsampa to tea to make a loose paste.</span>
										</p>
										<p class="term">
											<span class="orth">Jang</span>
											<span class="romanization">[tib. 'jang] [tib. 'jang  dgun chos]</span>
											<br/>
											<span class="definition">[Jang g&#xFC;nch&#xF6;] the special winter debating session for monks that is held annually in the area called Jang.</span>
										</p>

										<p class="term">
											<span class="orth">Jang g&#xFC;nch&#xF6;</span>
											<span class="romanization">[tib. 'jang  dgun chos]</span>
											<br/>
											<span class="definition">the special winter debating session for monks that is held annually in the area called Jang.</span>
										</p>
										<p class="term">
											<span class="orth">Je</span>
											<span class="romanization">[tib. byes]</span>
											<br/>

											<span class="definition">One of the largest colleges (tratsang) in Sera monastery. It was the college of Reting Rimpoche.</span>
										</p>
										<p class="term">
											<span class="orth">jeda</span>
											<span class="romanization">[tib. dpyad brda]</span>
											<br/>
											<span class="definition">a document settling a dispute or law case in the traditional Tibetan government.</span>
										</p>
										<p class="term">
											<span class="orth">jen</span>
											<span class="romanization">[tib. can]</span>
											<br/>

											<span class="definition">a class enemy or representative of the serf owner.</span>
										</p>
										<p class="term">
											<span class="orth">Jenkhentsisum</span>
											<span class="romanization">[tib. gcen mkhan rtsis gsum ]</span>
											<br/>
											<span class="definition">Abbreviation of the titales of the three heads of the major anti-Chinese, Tibetan nationalist group in India in the 1953-59 period: Jen refers to the &quot;older brother&quot; (the older brother of the Dalai Lama, Gyalo Thondup), khen refers to the monk official of the rank khenjung (Lobsang Gyentsen), and tsi refers to the lay offical of the tsigang rank (Shakabpa). Sum means the three (of them).</span>
										</p>

										<p class="term">
											<span class="orth">jensal</span>
											<span class="romanization">[tib. spyan bsal]</span>
											<br/>
											<span class="definition">a favorite (commonly used for the powerful favorites of the 13th Dalai Lama).</span>
										</p>
										<p class="term">
											<span class="orth">Jigje mahe</span>
											<span class="romanization">[tib. 'jigs byed ma he]</span>
											<br/>

											<span class="definition">A protective talismen from the protective deity Yamantaka.</span>
										</p>
										<p class="term">
											<span class="orth">Jigyab khempo</span>
											<span class="romanization">[tib. spyi khyab mkhan po]</span>
											<br/>
											<span class="definition">the highest monk official in the traditional Tibetan government.  He was the head of monk official segment and was also in charge of the Dalai Lama's household staff such as the Ch&#xF6;sims&#xF6;sum [Ch&#xF6;p&#xF6;n, S&#xF6;p&#xF6;n, Simp&#xF6;n] and private storeroom [tib. Z&#xF6;bug]. The Chikyab Khembo is entitled to sit with the Kashag but does not go there daily. However, he will meet with them for important issues (for example if the Dalai Lama has something to say to the Kashag). In these cases he has the same rank as the Kal&#xF6;ns although he sits at the end of their row.</span>
										</p>

										<p class="term">
											<span class="orth">jin</span>
											<span class="romanization">[ch.]</span>
											<br/>
											<span class="definition">1.1 pounds (half of a kilogram).</span>
										</p>
										<p class="term">
											<span class="orth">jiso</span>
											<span class="romanization">[tib. spyi bso]</span>
											<br/>

											<span class="definition">The head managers/stewards of monasteries as a whole, especially the large Gelugpa monasteries like Sera and Drepung.</span>
										</p>
										<p class="term">
											<span class="orth">Jola</span>
											<span class="romanization">[tib. jo lags ]</span>
											<br/>
											<span class="definition">1. term of address for elder brother. 2. a term of address for older males in general.</span>
										</p>
										<p class="term">
											<span class="orth">J&#xF6;nga Ch&#xF6;pa</span>
											<span class="romanization">[tib. bco lnga mchod pa]</span>
											<br/>

											<span class="definition">The festival on the 15th of the First Tibetan Month when the butter sculptures are exhibited.</span>
										</p>
										<p class="term">
											<span class="orth">jub&#xF6;n</span>
											<span class="romanization">[tib. bcu dpon] [tib. bcu dpon]</span>
											<br/>
											<span class="definition">[jugp&#xF6;n] 1. a minor army officer in charge of a squad of 10 troops in the traditional Tibetan army. 2. a minor official.</span>
										</p>

										<p class="term">
											<span class="orth">jugp&#xF6;n</span>
											<span class="romanization">[tib. bcu dpon]</span>
											<br/>
											<span class="definition">1. a minor army officer in charge of a squad of 10 troops in the traditional Tibetan army. 2. a minor official.</span>
										</p>
										<p class="term">
											<span class="orth">junqu</span>
											<span class="romanization">[tib. dmag khul khang; ch. jun qu]</span>
											<br/>

											<span class="definition">military headquarters</span>
										</p>
										<p class="term">
											<span class="orth">jushog</span>
											<span class="romanization">[tib. bcu shog]</span>
											<br/>
											<span class="definition">a unit in the traditional Tibet army comprsed of 10 troops.</span>
										</p>
									</div>

									<div class="alpha" id="k">
										<span class="letter">K</span>
										<p class="term">
											<span class="orth">kadang</span>
											<span class="romanization">[tib. ka dang]</span>
											<br/>
											<span class="definition">The &quot;ka&quot; army regiment. In the traditional Tibetan army regiments were numbered alphabetically rather than numerically. Consequently, the Kadang regiment refers to the 1rd Regiment since &quot;ka&quot; is the third letter of the Tibetan alphabet. It was the Bodyguard (Kusung [sku srung]) Regiment for the Dalai Lama.</span>
										</p>

										<p class="term">
											<span class="orth">kadrung</span>
											<span class="romanization">[tib. bka' drung]</span>
											<br/>
											<span class="definition">Kadrung were important administrative aides to the Kashag Ministers. There were usually two of these, both aristocratic lay officials. Their job was to assist the ministers any way the mionisters needed, but their usual work involved writing whatever letters, documents, orders, recommendations the Kashag sent to the Dalai Lama and other offices and the edicts the Kashag sent to counties. By custom, the the seal of the Kashag could only be applied by the 2 Kadrung, even if the ministers were there. People of officials under the 5th rank had to sumbit their petitions first through the Kadrung (or kandr&#xF6;n). There were also two kandr&#xF6;n [bka' mgron] in the Kashag office. They were also aristocratic lay officials and generally were less powerful than the kadrung, handling lessor requests to the Kashag. Their office was called the Dr&#xF6;ndrung khang [tib. mgron drung khang].</span>
										</p>
										<p class="term">
											<span class="orth">kal&#xF6;n</span>
											<span class="romanization">[tib. bka' blon]</span>
											<br/>

											<span class="definition">One of the heads or ministers of the Kashag [bka' shag] or Council of Ministers. There were usually 4 kal&#xF6;n, although in the 1950s the number increased at various times to 6 or 7. The ministers made decisions collectively, and had no fixed term of office.</span>
										</p>
										<p class="term">
											<span class="orth">kal&#xF6;n lama</span>
											<span class="romanization">[tib. bka' blon bla ma]</span>
											<br/>
											<span class="definition">The Kal&#xF6;n who was a monk official.</span>
										</p>

										<p class="term">
											<span class="orth">kal&#xF6;n tripa</span>
											<span class="romanization">[tib. bka' blon khri pa]</span>
											<br/>
											<span class="definition">the leading member of the Kashag.</span>
										</p>
										<p class="term">
											<span class="orth">kandr&#xF6;n</span>
											<span class="romanization">[tib. bka; mgron ]</span>
											<br/>

											<span class="definition">Kand&#xF6;n were administrative aides to the Kashag. There were usually three of these, all aristocratic lay officials. They were in charge of petitions to the Kashag.  
                      See also definition of Kadrung.</span>
										</p>
										<p class="term">
											<span class="orth">kang</span>
											<span class="romanization">[tib. rkang] [tib. rkang]</span>
											<br/>
											<span class="definition">[gang] the basic land measurement unit for tax obligations in the old society. One gang was considered a full tax unit of land. A gang was measured by volume, specifically by the amount of seed (s&#xF6;nkhe) that could be sown. This amount was not standardized and the size of one gang varied under different lords.</span>
										</p>

										<p class="term">
											<span class="orth">kangdro</span>
											<span class="romanization">[tib. rkang 'gro]</span>
											<br/>
											<span class="definition">corvee labor tax in the traditional Tibetan government.</span>
										</p>
										<p class="term">
											<span class="orth">kangyur</span>
											<span class="romanization">[tib. bka' 'gyur]</span>
											<br/>

											<span class="definition">one of the main Buddhist scriptures that consists of 108 volumes.</span>
										</p>
										<p class="term">
											<span class="orth">karma</span>
											<span class="romanization">[tib. skar ma]</span>
											<br/>
											<span class="definition">1. The smallest currency unit (copper coin) in the traditional Tibetan currency system. Ten karma equaled 1 sho [zho].  2. a work point in post-1959 Tibet. 3. A person's name.</span>
										</p>
										<p class="term">
											<span class="orth">kashag</span>
											<span class="romanization">[tib. bka' shag]</span>
											<br/>

											<span class="definition">the Council of Ministers. The highest office in the traditional Tibetan government. It usually consisted of 4 or more ministers (kal&#xF6;n) who collectively made decisions.</span>
										</p>
										<p class="term">
											<span class="orth">kasur</span>
											<span class="romanization">[tib. bka' zur ]</span>
											<br/>
											<span class="definition">A former or ex-kal&#xF6;n.</span>
										</p>

										<p class="term">
											<span class="orth">katsab</span>
											<span class="romanization">[tib. bka' tshab]</span>
											<br/>
											<span class="definition">acting kal&#xF6;n.</span>
										</p>
										<p class="term">
											<span class="orth">ke</span>
											<span class="romanization">[tib. khal]</span>
											<br/>

											<span class="definition">[khe] a traditional volume measurement for measuring grain in the traditional Tibetan society. Sizes varied somewhat, but the official government khe (called mkhar ru or bstan dzin mkha ru) weighed about 31 pounds for barley. It was universally used in traditional Tibet as a land measurement in that fields would be said to be of a size able to use a certain number of  khe of seed (called s&#xF6;nkhe).</span>
										</p>
										<p class="term">
											<span class="orth">khadang</span>
											<span class="romanization">[tib. kha dang]</span>
											<br/>
											<span class="definition">the &quot;kha&quot; army regiment. In the traditional Tibetan army regiments were numbered alphabetically rather than numerically. Consequently, the Kadang regiment refers to the 2rd Regiment since &quot;kha&quot; is the third letter of the Tibetan alphabet. It was also known as the Drapchi regiment (tib. grwa bzhi) because its regimental headquarters were located in Drapchi, just below Sera Monastery. Regiment for the Dalai Lama.</span>
										</p>

										<p class="term">
											<span class="orth">khag&#xF6;n</span>
											<span class="romanization">[tib. kha gon ]</span>
											<br/>
											<span class="definition">The outer red coat worn by lay officials above the 5th rank in the traditional Tibetan governmnet.</span>
										</p>
										<p class="term">
											<span class="orth">Khamba</span>
											<span class="romanization">[tib. khams pa ]</span>
											<br/>

											<span class="definition">a person from the Kham region, a Tibetan person from the Khamba ethnic grouping</span>
										</p>
										<p class="term">
											<span class="orth">khampa</span>
											<span class="romanization">[tib. khams pa ]</span>
											<br/>
											<span class="definition">a person from Kham (Eastern Tibet)</span>
										</p>
										<p class="term">
											<span class="orth">khamtsen</span>
											<span class="romanization">[tib. khang tshan]</span>
											<br/>

											<span class="definition">the name of the residential units in which monks lived in monasteries. These were corporate entities with property and internal officials. They generally accepted monks only from specified geographic areas.</span>
										</p>
										<p class="term">
											<span class="orth">khamtsen gegen</span>
											<span class="romanization">[tib. khang tshan dge rgan]</span>
											<br/>
											<span class="definition">the title of the head of a khamtsen</span>
										</p>
										<p class="term">
											<span class="orth">khangy&#xF6; khangchung</span>
											<span class="romanization">[tib. khang yod khang chung]</span>
											<br/>

											<span class="definition">People in charge of tenants. Something like an apartment manager.</span>
										</p>
										<p class="term">
											<span class="orth">kharu</span>
											<span class="romanization">[tib. mkhar ru] [tib. khal]</span>
											<br/>
											<span class="definition">[khe] a traditional volume measurement for measuring grain in the traditional Tibetan society. Sizes varied somewhat, but the official government khe (called mkhar ru or bstan dzin mkha ru) weighed about 31 pounds for barley. It was universally used in traditional Tibet as a land measurement in that fields would be said to be of a size able to use a certain number of  khe of seed (called s&#xF6;nkhe).</span>
										</p>
										<p class="term">
											<span class="orth">khata</span>
											<span class="romanization">[tib. kha btags]</span>
											<br/>

											<span class="definition">the Tibetan ceremonial scarves given to lamas, visitors, etc.</span>
										</p>
										<p class="term">
											<span class="orth">khatog garmar</span>
											<span class="romanization">[tib. kha dog dkar dmar]</span>
											<br/>
											<span class="definition">the first class in the monastic d&#xFC;dra curriculum.</span>
										</p>
										<p class="term">
											<span class="orth">khe</span>
											<span class="romanization">[tib. khal]</span>
											<br/>

											<span class="definition">a traditional volume measurement for measuring grain in the traditional Tibetan society. Sizes varied somewhat, but the official government khe (called mkhar ru or bstan dzin mkha ru) weighed about 31 pounds for barley. It was universally used in traditional Tibet as a land measurement in that fields would be said to be of a size able to use a certain number of  khe of seed (called s&#xF6;nkhe).</span>
										</p>
										<p class="term">
											<span class="orth">khempo</span>
											<span class="romanization">[tib. mkhan po]</span>
											<br/>
											<span class="definition">Abbot of a monastery.</span>
										</p>
										<p class="term">
											<span class="orth">khenche</span>
											<span class="romanization">[tib. mkhan che]</span>
											<br/>

											<span class="definition">A monk official of the third rank in the traditional Tibetan governmnet.</span>
										</p>
										<p class="term">
											<span class="orth">Khendr&#xF6;nlosum</span>
											<span class="romanization">[tib. mkhan mgron lo gsum ]</span>
											<br/>
											<span class="definition">The three monk officials (the mkhan chung, rtse mgron, and lo rtsa ba) sent to Beijing during the Qing Dynasty by the Tibetan 's time initially to teach the Qing royal family some written Tibetan so that they could read prayer books as well as perform rituals for the royal family. After the Qing dynasty fell, the Tibetan government continued to station three such monk officials in Beijing and they fundtioned as a quasi-governmnet bureau office fot the Tibetan governmnet in China.</span>
										</p>
										<p class="term">
											<span class="orth">khenjung</span>
											<span class="romanization">[tib. mkhan chung]</span>
											<br/>

											<span class="definition">a rank and title for monk officials that was equal to 4th rank (rim bzhi) officials in the lay side of the traditional government bureaucracy.</span>
										</p>
										<p class="term">
											<span class="orth">k&#xF6;nyer</span>
											<span class="romanization">[tib. dkon gnyer ]</span>
											<br/>
											<span class="definition">the monk caretaker of a chapel/temple [tib. lha khang]</span>
										</p>
										<p class="term">
											<span class="orth">Korchagpa</span>
											<span class="romanization">[tib. skor 'chag pa]</span>
											<br/>

											<span class="definition">A low level government worker who patrolled the streets and delivered messages/notices for the office of the mayor of Lhasa.</span>
										</p>
										<p class="term">
											<span class="orth">kudrak</span>
											<span class="romanization">[tib. sku drag ]</span>
											<br/>
											<span class="definition">1. a member of the lay aristocracy.
                      2. terms referring to to government lay and monk officials.
                      3. a name occasionally used for the top leaders in a monastery.</span>
										</p>
										<p class="term">
											<span class="orth">kujar</span>
											<span class="romanization">[tib. sku bcar]</span>
											<br/>

											<span class="definition">1. a favorite; someone who works/stays in the close presence of another important figure. 2. The name commonly used for Kunphel-la (tib. kun 'phel lags), the close favorite of the 13th Dalai Lama who became politically powerful during the latter period of the 13th Dalai Lama's reign.</span>
										</p>
										<p class="term">
											<span class="orth">kung&#xF6;</span>
											<span class="romanization">[tib. sku ngo]</span>
											<br/>
											<span class="definition">the respectful term of address for aristocratcs.and monk officials. It is something like &quot;Your Excellency.&quot;</span>
										</p>
										<p class="term">
											<span class="orth">kungre</span>
											<span class="romanization">[ch. kung she]</span>
											<br/>

											<span class="definition">people's commune.</span>
										</p>
										<p class="term">
											<span class="orth">kungshe</span>
											<span class="romanization">[ch. kung she]</span>
											<br/>
											<span class="definition">[kungre] people's commune.</span>
										</p>
										<p class="term">
											<span class="orth">Kyichog Kund&#xFC;</span>
											<span class="romanization">[tib. skyid phyogs kun 'dus]</span>
											<br/>

											<span class="definition">The name of the party started by Lungshar after the death of the 13th Dalai Lama. It translates roughly as &quot;all joined together in happiness.&quot;</span>
										</p>
										<p class="term">
											<span class="orth">kyidu</span>
											<span class="romanization">[tib. skyid sdug ]</span>
											<br/>
											<span class="definition">An association, club.</span>
										</p>
										<p class="term">
											<span class="orth">Kyit&#xF6;pa</span>
											<span class="romanization">[tib. skyid stod pa]</span>
											<br/>

											<span class="definition">The name of the house in  Lhasa where the Guomindang government's offices and school were located.</span>
										</p>
									</div>
									<div class="alpha" id="l">
										<span class="letter">L</span>
										<p class="term">
											<span class="orth">labor unit/camp</span>
											<span class="romanization">[tib. las mi ru khag; ch. jiu ye zhi gong]</span>
											<br/>
											<span class="definition">a type of detention camp.  Some prisoners in the 1959-80 period were not released free into society but were kept/sent to a labor camp where they worked and received salaries.</span>
										</p>

										<p class="term">
											<span class="orth">labrang</span>
											<span class="romanization">[tib. bla brang]</span>
											<br/>
											<span class="definition">1. the property and wealth owning corporate entity of an incarnate lama. 2. the corporation/government of the Panchen Lama.</span>
										</p>
										<p class="term">
											<span class="orth">lag</span>
											<span class="romanization">[tib. lag]</span>
											<br/>

											<span class="definition">a traditional Tibetan unit comprising ten transport animals. This is normally used for mules and donkeys.</span>
										</p>
										<p class="term">
											<span class="orth">lagthe</span>
											<span class="romanization">[tib. lag thel]</span>
											<br/>
											<span class="definition">a woven bracelet made from cotton that was given to all Tibetan army soldiers.  The army put its wax seal on this and soldiers were required to keep it as proof of their official registration as a soldier.</span>
										</p>
										<p class="term">
											<span class="orth">lagy&#xFC;ba</span>
											<span class="romanization">[tib. bla rgyud pa]</span>
											<br/>

											<span class="definition">a term for the mass of common monks in a monastery (in contrast to the scholar monks actively studying Buddhism)</span>
										</p>
										<p class="term">
											<span class="orth">Laja (Treasury office)</span>
											<span class="romanization">[tib. bla phyag bla brang phyag mdzod]</span>
											<br/>
											<span class="definition">A major treasury office that was located on the second floor of the Tsuglagkang. Taxes from various parts of Tibet would be sent annually to it.</span>
										</p>
										<p class="term">
											<span class="orth">laji</span>
											<span class="romanization">[tib. bla spyi]</span>
											<br/>

											<span class="definition">The highest administrative council in large monasteries like Drepung. It consisted of the Abbots, the Tshogchen Umdze, the Shengo and the Jiso.</span>
										</p>
										<p class="term">
											<span class="orth">la khe</span>
											<span class="romanization">[tib. gla khal]</span>
											<br/>
											<span class="definition">a khe used when paying salary. In some areas it was equal to only half of the normal khe.</span>
										</p>
										<p class="term">
											<span class="orth">lalag</span>
											<span class="romanization">[tib. lag sdod pa; lag lags]</span>
											<br/>

											<span class="definition">A traditional religious practitioner in rural Tibet who was a specialist in blocking hail from falling on argicultural fields.</span>
										</p>
										<p class="term">
											<span class="orth">Lama Gy&#xFC;pa</span>
											<span class="romanization">[tib. bla ma rgyud pa]</span>
											<br/>
											<span class="definition">a name used for the Upper and Lower Tantric Monastic College (gy&#xFC;me and gy&#xFC;d&#xF6;).</span>
										</p>

										<p class="term">
											<span class="orth">lamyik</span>
											<span class="romanization">[tib. lam yig]</span>
											<br/>
											<span class="definition">a government document (permit) that permits the holder to receive corve&#xE8; transportation and riding animals when traveling. This was theoretically to be used by governmnet officials on official buisiness but was often given to traders who provided bribes. It was a major source of hardship for the serfs who had to provide the horses and yaks.</span>
										</p>
										<p class="term">
											<span class="orth">lene</span>
											<span class="romanization">[tib. las sne ]</span>
											<br/>

											<span class="definition">a monastic official</span>
										</p>
										<p class="term">
											<span class="orth">lep&#xF6;n</span>
											<span class="romanization">[tib. las dpon]</span>
											<br/>
											<span class="definition">supervisor of work on an estate.</span>
										</p>
										<p class="term">
											<span class="orth">letsenpa</span>
											<span class="romanization">[tib. las tshan pa]</span>
											<br/>

											<span class="definition">the name for officials of the 5th rank in the traditional Tibetan government.</span>
										</p>
										<p class="term">
											<span class="orth">leyshing</span>
											<span class="romanization">[tib. las zhing]</span>
											<br/>
											<span class="definition">Fields given to a person to plant, harvest and keep the yield as payment for work done on the owner's fields. These owners could be other rich peasants or aristocratic and monastic lords. Generally the agreement specified that the worker was required to work for a certain number of days without pay. This was a common way that peasants who had no land (or not enough land) could supplement their income.</span>
										</p>
										<p class="term">
											<span class="orth">lhaps&#xF6;</span>
											<span class="romanization">[tib. lha gsol ]</span>
											<br/>

											<span class="definition">a religious offering ceremony to the gods that usually involves buring incense</span>
										</p>
										<p class="term">
											<span class="orth">lobso sum</span>
											<span class="romanization">[tib slob gso gsum] [tib. lobso sum (tib. slob gso gsum; ch. san jiao)]</span>
											<br/>
											<span class="definition">[Three Education Campaign] a campaign that started in Tibet in 1964-65 and included education on class, education on the prospects for socialism, and education on patriotism. It involved criticizing and holding struggle sessions against senior cadre. It was also called the Three Great Education Campaign</span>
										</p>
										<p class="term">
											<span class="orth">logj&#xF6;pa</span>
											<span class="romanization">[tib. log spyod pa; ch. Sandong fenzi]</span>
											<br/>

											<span class="definition">reactionary, someone who was involved in an organization that opposed the CCP.</span>
										</p>
										<p class="term">
											<span class="orth">lopa</span>
											<span class="romanization">[tib. klo pa ]</span>
											<br/>
											<span class="definition">The tribal hunting and gathering ethnic group in Southeast Tibet.</span>
										</p>
										<p class="term">
											<span class="orth">lord</span>
											<span class="romanization">[tib. dpon po, mnga' bdag] [tib. mnga' bdag; ch. lingzhu]</span>
											<br/>

											<span class="definition">[ngadag] The person or institution (monastery, labrang) that owned manorial estates and serfs. Sometimes this is translated as lord and sometimes as serf-owner. From the peasant's perspective, it refered to his or her hereditary lord to whom he/she was obliged to provide corv&#xE9;e services or other taxes. In traditional Tibet, there were three main categories of lord: aristocratic lords, religious lords (monasteries or labrang), and the government as a lord. A person's link to a lord was hereditary and was passed on via parallel descent, that is to say, the sons of a couple belonged to the lord of the father and the daughters to the lord of his wife (if they had different lords).</span>
										</p>
										<p class="term">
											<span class="orth">lugu</span>
											<span class="romanization">[tib. slu gu]</span>
											<br/>
											<span class="definition">a measurement unit equal to half of a donpo.</span>
										</p>
										<p class="term">
											<span class="orth">Lukhangwa</span>
											<span class="romanization">[tib. klu khang ba]</span>
											<br/>

											<span class="definition">an aristocratic official; one of the two Sitsab in 1950-52.</span>
										</p>
										<p class="term">
											<span class="orth">Lunyo sij&#xFC;</span>
											<span class="romanization">[tib. blu nyo'i srid jus; ch. shumai zhengce]</span>
											<br/>
											<span class="definition">[redeeming policy] The &quot;buy-out&quot; policy of gradually nationalizing the means of production while compensating the bourgeoisie who owned the property for the loss of their resources. In Tibet, this policy was applied to progressive lords and elites.</span>
										</p>

										<p class="term">
											<span class="orth">lurik</span>
											<span class="romanization">[tib. blo rigs]</span>
											<br/>
											<span class="definition">the last class in the d&#xFC;dra monastic curriculum. This is the end of the prayer text memorization phase.</span>
										</p>
										<p class="term">
											<span class="orth">lurik d&#xFC;sang</span>
											<span class="romanization">[tib. blo rig dus bzang]</span>
											<br/>

											<span class="definition">the prayer assembly that occurs at the end of the lurik class in monasteries.</span>
										</p>
										<p class="term">
											<span class="orth">lu zhang</span>
											<span class="romanization">[ch.]</span>
											<br/>
											<span class="definition">brigade commander  in the PLA.</span>
										</p>
									</div>

									<div class="alpha" id="m">
										<span class="letter">M</span>
										<p class="term">
											<span class="orth">magang</span>
											<span class="romanization">[tib. dmag rkang]</span>
											<br/>
											<span class="definition">A military &quot;gang.&quot; A category of land that obligated the household holding the land to provide a corv&#xE9;e soldier for the Tibetan army. This could either be one of its own family members or someone they hired specially to fulfill their corv&#xE9; obligation.</span>
										</p>

										<p class="term">
											<span class="orth">magba</span>
											<span class="romanization">[tib. mag pa ]</span>
											<br/>
											<span class="definition">[magpa] A groom who moves at marriage to the household of his bride and becomes part of her household. In Tibet, the norm is the opposite, i.e., for women to move to the households of their husband at marriage.</span>
										</p>
										<p class="term">
											<span class="orth">magji</span>
											<span class="romanization">[tib. dmag spyi]</span>
											<br/>

											<span class="definition">the Commander-in-Chief of the Tibetan Army.</span>
										</p>
										<p class="term">
											<span class="orth">magjigang</span>
											<span class="romanization">[tib. dmag spyi khang]</span>
											<br/>
											<span class="definition">The main military headquarters of the Tibetan army.</span>
										</p>
										<p class="term">
											<span class="orth">magpa</span>
											<span class="romanization">[tib. mag pa ]</span>
											<br/>

											<span class="definition">A groom who moves at marriage to the household of his bride and becomes part of her household. In Tibet, the norm is the opposite, i.e., for women to move to the households of their husband at marriage.</span>
										</p>
										<p class="term">
											<span class="orth">mangja</span>
											<span class="romanization">[tib. mang ja ]</span>
											<br/>
											<span class="definition">the tea served to monks at the tshogchen (monastery as a whole)prayer assembly meeting</span>
										</p>
										<p class="term">
											<span class="orth">maotse</span>
											<span class="romanization"/>
											<br/>

											<span class="definition">a Chinese currency unit. 10 maotse = 1 yuan. 10 fen = one maotse.</span>
										</p>
										<p class="term">
											<span class="orth">marke</span>
											<span class="romanization">[tib. mar khal]</span>
											<br/>
											<span class="definition">a traditional measure for weighing butter.</span>
										</p>
										<p class="term">
											<span class="orth">markhe</span>
											<span class="romanization">[tib. mar khal] [tib. mar khal]</span>
											<br/>

											<span class="definition">[marke] a traditional measure for weighing butter.</span>
										</p>
										<p class="term">
											<span class="orth">mendredensum</span>
											<span class="romanization">[tib. mendre rten gsum ]</span>
											<br/>
											<span class="definition">a type of religious offering given to lamas that symbolizes the body (via a statueO, the mind (via a text) and the mind (via a stupa)</span>
										</p>
										<p class="term">
											<span class="orth">mendrel tensum</span>
											<span class="romanization">[tib. mendre rten gsum ]</span>
											<br/>

											<span class="definition">a type of religious offering given to lamas that symbolizes the body (via a statue), the mind (via a text) and the mind (via a stupa)</span>
										</p>
										<p class="term">
											<span class="orth">mentsigang</span>
											<span class="romanization">[tib. sman rtsis khang]</span>
											<br/>
											<span class="definition">the Tibetan traditional medical and astrological center.</span>
										</p>
										<p class="term">
											<span class="orth">mibo</span>
											<span class="romanization">[tib. mi bogs] [tib. mibo, (mi bogs)]</span>
											<br/>

											<span class="definition">[human lease serf] a type of serf who secured his freedom to leave the estate and go where he/she wanted for a lee paid annually to the lord in perpetuity. Children of the same sex (i.e., sons of a male) inherited this status.</span>
										</p>
										<p class="term">
											<span class="orth">mimang</span>
											<span class="romanization">[tib. mi dmangs] [tib. mi dmangs tshogs pa]</span>
											<br/>
											<span class="definition">1. Refers to &quot;the people&quot; in the collective sense. 2. also is used to ferf specifically to the People's Associations that existed in Lhasa in the 1950s. [mimang tshogpa] People's Association.</span>
										</p>

										<p class="term">
											<span class="orth">mimang tshogpa</span>
											<span class="romanization">[tib. mi dmangs tshogs pa]</span>
											<br/>
											<span class="definition">People's Association.</span>
										</p>
										<p class="term">
											<span class="orth">mip&#xF6;n</span>
											<span class="romanization">[tib. mi dpon]</span>
											<br/>

											<span class="definition">The office of mayor of Lhasa during the traditional governmnet.</span>
										</p>
										<p class="term">
											<span class="orth">miser</span>
											<span class="romanization">[tib. mi ser]</span>
											<br/>
											<span class="definition">a term that can means serf or bound subject as well as citizen depending on context. For example, the miser of a lord would connote the serfs of that lord, whereas the miser of Tibet would connote citizens of Tibet.</span>
										</p>
										<p class="term">
											<span class="orth">mitsen</span>
											<span class="romanization">[tib. mi tshan]</span>
											<br/>

											<span class="definition">a sub-unit of a khamtsen.</span>
										</p>
										<p class="term">
											<span class="orth">mitshan</span>
											<span class="romanization">[tib. mi tshan]</span>
											<br/>
											<span class="definition">[mitsen] a sub-unit of a khamtsen.</span>
										</p>
										<p class="term">
											<span class="orth">m&#xF6;nlam (chemmo)</span>
											<span class="romanization">[tib. smon lam (chen mo) ]</span>
											<br/>

											<span class="definition">the (great) prayer festival in the first Tibetan month</span>
										</p>
										<p class="term">
											<span class="orth">monng&#xF6;</span>
											<span class="romanization">[tib. rmod brngos]</span>
											<br/>
											<span class="definition">a type of tax in the old society that required payment of tsampa and grain used for fodder for he horses of the Tibetan government.</span>
										</p>
										<p class="term">
											<span class="orth">morang</span>
											<span class="romanization">[tib. mo rang]</span>
											<br/>

											<span class="definition">sometimes refers to a woman living alone. Sometimes refers to an unmarried or divorced or widowed woman who does not have any arable land.</span>
										</p>
										<p class="term">
											<span class="orth">morangga</span>
											<span class="romanization">[tib. mo hrang ma] [tib. mo rang]</span>
											<br/>
											<span class="definition">[morang] sometimes refers to a woman living alone. Sometimes refers to an unmarried or divorced or widowed woman who does not have any arable land.</span>
										</p>
										<p class="term">
											<span class="orth">mu</span>
											<span class="romanization"/>
											<br/>

											<span class="definition">a Chinese land measurement equal to 0.67 hectartes and 0.17 acres.  In contemporary Tibet, a mu is roughly equivalent to a khe, and both are often used interchangeably.</span>
										</p>
										<p class="term">
											<span class="orth">Muru</span>
											<span class="romanization">[tib. rme ru]</span>
											<br/>
											<span class="definition">name of a monastery in the north of Lhasa.</span>
										</p>
										<p class="term">
											<span class="orth">Mutual Aid Team</span>
											<span class="romanization">[tib. rogs res tshogs chung]</span>
											<br/>

											<span class="definition">Type of cooperative production unit started in 1960-61 as a precursor to full communes. In farm areas, 5-6 poorer families would be joined with one or two better off families and would cooperate in all aspects of farming, although each family would keep all its yield. Thease teams used a system of work points (garma) to record the number of days each household worked and the number of animals used. At the end of a year, families that had amassed more work points were compensated by those that amassed less (i.e., did less work). In urban areas there were also Mutual Aid Teams, for example, a group of tailors would be so organized.</span>
										</p>
										<p class="term">
											<span class="orth">Mutual Help Team</span>
											<span class="romanization">[tib. rogs res tshogs chung]</span>
											<br/>
											<span class="definition">[Mutual Aid Team] Type of cooperative production unit started in 1960-61 as a precursor to full communes. In farm areas, 5-6 poorer families would be joined with one or two better off families and would cooperate in all aspects of farming, although each family would keep all its yield. Thease teams used a system of work points (garma) to record the number of days each household worked and the number of animals used. At the end of a year, families that had amassed more work points were compensated by those that amassed less (i.e., did less work). In urban areas there were also Mutual Aid Teams, for example, a group of tailors would be so organized.</span>
										</p>
									</div>

									<div class="alpha" id="n">
										<span class="letter">N</span>
										<p class="term">
											<span class="orth">nagchuka</span>
											<span class="romanization">[tib. nag chu kha]</span>
											<br/>
											<span class="definition">large nomad prefecture north and northwest of Lhasa</span>
										</p>
										<p class="term">
											<span class="orth">nambu</span>
											<span class="romanization">[tib. snam bu]</span>
											<br/>

											<span class="definition">hand woven wool cloth</span>
										</p>
										<p class="term">
											<span class="orth">Namgye Tratsang</span>
											<span class="romanization">[tib. rnam rgyal grwa tshang ]</span>
											<br/>
											<span class="definition">The monastery of the Dalai Lama located in the Potala Palace in Lhasa.</span>
										</p>
										<p class="term">
											<span class="orth">Namseling</span>
											<span class="romanization">[tib. rnam gsal gling]</span>
											<br/>

											<span class="definition">1. a Tibetan aristocratic family. 2. a place name associated with an estate of Namseling.</span>
										</p>
										<p class="term">
											<span class="orth">nancha</span>
											<span class="romanization">[tib. gnangs chag]</span>
											<br/>
											<span class="definition">the corvee labor tax where a household has to send someone to work every other days (instead of every day).</span>
										</p>
										<p class="term">
											<span class="orth">nangd&#xF6;n</span>
											<span class="romanization">[tib. nang 'don]</span>
											<br/>

											<span class="definition">a land measurement unit in the old society used with estates of aristocrats and monasteries. Inner d&#xF6;n referred to land from which taxes were paid to the immediate lord of the estate.</span>
										</p>
										<p class="term">
											<span class="orth">nangmagang</span>
											<span class="romanization">[tib. nangma sgang]</span>
											<br/>
											<span class="definition">the top administrative council of the Panchen Lama's government.</span>
										</p>
										<p class="term">
											<span class="orth">nangsen</span>
											<span class="romanization">[tib. nang zan]</span>
											<br/>

											<span class="definition">The lowest type of serf who lived in the house of their lord and worked as servants. They were completely dependent on their lord for food and clothing and had no separate source of income. In some cases, rich peasant families also also had nangsen.</span>
										</p>
										<p class="term">
											<span class="orth">nangtre</span>
											<span class="romanization">[tib. mang khral ]</span>
											<br/>
											<span class="definition">The taxes and corvee labor serivices one provides to one's own lord (as opposed to chitre which are paid to the government).</span>
										</p>
										<p class="term">
											<span class="orth">Nangtsesha</span>
											<span class="romanization">[tib. snang rtse shag]</span>
											<br/>

											<span class="definition">the main administrative office overseeing Lhasa city.</span>
										</p>
										<p class="term">
											<span class="orth">Nechung</span>
											<span class="romanization">[tib. gnas chung]</span>
											<br/>
											<span class="definition">1. One of the main protector deities of the government and the Dalai Lama.  Also called Nechung Ch&#xF6;gyong [tib. gnas chuung chos skyong]. 2. the medium/oracle of the Nechung protector deity. 3. The monastery of the medium/oracle of the Nechung protective deity.</span>
										</p>
										<p class="term">
											<span class="orth">neighborhood committee</span>
											<span class="romanization">[tib. u yon lhan khang]</span>
											<br/>

											<span class="definition">a major administrative unit in cities.</span>
										</p>
										<p class="term">
											<span class="orth">nendr&#xF6;n</span>
											<span class="romanization">[tib. sne mgron]</span>
											<br/>
											<span class="definition">the monk official who served as the lord chamberlain of the regent's secretariate (sh&#xF6;ga). The nendr&#xF6;n had several monk officials called sh&#xF6;ndr&#xF6;n [zhol mgron] under him. During the time of the two Sitsab, the regent's secretariate continued to function.</span>
										</p>

										<p class="term">
											<span class="orth">ngadag</span>
											<span class="romanization">[tib. mnga' bdag; ch. lingzhu]</span>
											<br/>
											<span class="definition">The person or institution (monastery, labrang) that owned manorial estates and serfs. Sometimes this is translated as lord and sometimes as serf-owner. From the peasant's perspective, it refered to his or her hereditary lord to whom he/she was obliged to provide corv&#xE9;e services or other taxes. In traditional Tibet, there were three main categories of lord: aristocratic lords, religious lords (monasteries or labrang), and the government as a lord. A person's link to a lord was hereditary and was passed on via parallel descent, that is to say, the sons of a couple belonged to the lord of the father and the daughters to the lord of his wife (if they had different lords).</span>
										</p>
										<p class="term">
											<span class="orth">Ngadang</span>
											<span class="romanization">[tib. nga dang ]</span>
											<br/>

											<span class="definition">The Gyantse regiment of the traditional Tibetan army.</span>
										</p>
										<p class="term">
											<span class="orth">ngagpa</span>
											<span class="romanization">[tib. sngags pa]</span>
											<br/>
											<span class="definition">1. lay exorcists (mantrists) who are usually concerned with controlling rain and hail. 2. one of the colleges in Sera Monastery.</span>
										</p>
										<p class="term">
											<span class="orth">ngatshab</span>
											<span class="romanization">[tib. mnga' tshab; ch. lingzhu dailiren (dailiren)]</span>
											<br/>

											<span class="definition">agent/representative of the serf lord.</span>
										</p>
										<p class="term">
											<span class="orth">ngoten</span>
											<span class="romanization">[tib. bsngo rten]</span>
											<br/>
											<span class="definition">monney or things given to a lama to ask him to do a dedication for the deceased</span>
										</p>
										<p class="term">
											<span class="orth">ngotre</span>
											<span class="romanization">[tib. sngo khral]</span>
											<br/>

											<span class="definition">a kind if summer tax that required the delivery of butter to the local landlord [yul dpon] and the lama who was protecting the crops from hail.</span>
										</p>
										<p class="term">
											<span class="orth">Ngulchu</span>
											<span class="romanization">[tib. rngul chu ]</span>
											<br/>
											<span class="definition">the Salween River</span>
										</p>
										<p class="term">
											<span class="orth">ng&#xFC;sang</span>
											<span class="romanization">[tib. dngul srang]</span>
											<br/>

											<span class="definition">a unit in the traditional Tibetan currency system. 50 ngusang equals to 1 dotse.</span>
										</p>
										<p class="term">
											<span class="orth">Norbulinga</span>
											<span class="romanization">[tib. nor bu gling kha]</span>
											<br/>
											<span class="definition">the summer palace of the Dalai Lama on the outskirts of Lhasa.</span>
										</p>
										<p class="term">
											<span class="orth">Norbulinga ga</span>
											<span class="romanization">[tib.nor bu gling kha 'gag]</span>
											<br/>

											<span class="definition">the Secretariate of the Dalai Lama held in Norbulinga.</span>
										</p>
										<p class="term">
											<span class="orth">nyaga</span>
											<span class="romanization">[tib. nya ga]</span>
											<br/>
											<span class="definition">a measurement unit. About 10 nyaga were equal to one gyama (1.1 lbs.).</span>
										</p>
										<p class="term">
											<span class="orth">Nyamdre</span>
											<span class="romanization">[tib. mnyam sbrel; ch..da lian zhi]</span>
											<br/>

											<span class="definition">one of the two major revolutionary organizations during the Cultural Revolution in Tibet. It is sometimes translated in English as the &quot;Alliance&quot; or the &quot;Great Alliance.&quot; Of the two dominant revolutionary groups in Tibet, it was the more &quot;establishment&quot; oriented and was supported by most of the party organs and the army in Tibet.</span>
										</p>
										<p class="term">
											<span class="orth">nyerba</span>
											<span class="romanization">[tib. gnyer pa]</span>
											<br/>

											<span class="definition">[nyerpa] A steward or manager who usually handled issues concerning storerooms or supplies. In some monasteries the nyerpa were under the authority of a higher manager called a Chandz&#xF6;.</span>
										</p>
										<p class="term">
											<span class="orth">nyerpa</span>
											<span class="romanization">[tib. gnyer pa]</span>
											<br/>
											<span class="definition">A steward or manager who usually handled issues concerning storerooms or supplies. In some monasteries the nyerpa were under the authority of a higher manager called a Chandz&#xF6;.</span>
										</p>

										<p class="term">
											<span class="orth">nyik&#xFC;</span>
											<span class="romanization">[tib. nyis skul]</span>
											<br/>
											<span class="definition">the name of a corvese tax that reuired sending a worker during the harvest and plowing periods.</span>
										</p>
									</div>
									<div class="alpha" id="o">
										<span class="letter">O</span>
										<p class="term">
											<span class="orth">ochen</span>
											<span class="romanization">[tib. dbu chen]</span>
											<br/>

											<span class="definition">middle level title for the top carvers of wood blocks.</span>
										</p>
										<p class="term">
											<span class="orth">ochung</span>
											<span class="romanization">[tib. dbu chung]</span>
											<br/>
											<span class="definition">lowest level title for the top carvers of wood blocks.</span>
										</p>
										<p class="term">
											<span class="orth">offspring of serf owners/aristocrats</span>
											<span class="romanization">[tib. phutru (bu phrug)]</span>
											<br/>

											<span class="definition">the children aged 18 or 20 in serf owner families were categorized as the class called, &quot;offspring of the serf owner&quot; (phutru [bu phrug]) while the offspring over that age would be classified as &quot;representative of the serf owner.&quot;</span>
										</p>
										<p class="term">
											<span class="orth">Oppose Three, Exempt Two</span>
											<span class="romanization">[tib. ngo rgol gsum dang chag yang gnyis]</span>
											<br/>
											<span class="definition">a campaign started at the beginning of democratic reforms in 1959 that was aimed at teaching Tibetans to oppose the three major exploiters, the aristocrats, the monastic leaders/lamas and the Tibetan government), and that there were exemptions from loans and taxes.</span>
										</p>

										<p class="term">
											<span class="orth">Oppose Three and Exempt Two</span>
											<span class="romanization">[tib. ngo rgol gsum dang chag yang gnyis; ch. san  fan shuang jian] [tib. ngo rgol gsum dang chag yang gnyis]</span>
											<br/>
											<span class="definition">[Oppose Three, Exempt Two] a campaign started at the beginning of democratic reforms in 1959 that was aimed at teaching Tibetans to oppose the three major exploiters, the aristocrats, the monastic leaders/lamas and the Tibetan government), and that there were exemptions from loans and taxes.</span>
										</p>
										<p class="term">
											<span class="orth">outer tax</span>
											<span class="romanization">[phyi khral]</span>
											<br/>

											<span class="definition">the tax that serfs pay to the government as opposed to their lord (the inner tax).</span>
										</p>
									</div>
									<div class="alpha" id="p">
										<span class="letter">P</span>
										<p class="term">
											<span class="orth">pag</span>
											<span class="romanization">[tib. lpags]</span>
											<br/>
											<span class="definition">standard Tibetan dish of tsampa mixed with tea into a dough-like consistency and eaten. Tsampa balls.</span>
										</p>

										<p class="term">
											<span class="orth">pai zhang</span>
											<span class="romanization">[ch.]</span>
											<br/>
											<span class="definition">platoon leader in the PLA.</span>
										</p>
										<p class="term">
											<span class="orth">patriotic common grain</span>
											<span class="romanization">[tib. rgyal gces spyi 'bru] [tib. rgyal gces gzhung 'bru; ch. gong liang]</span>
											<br/>

											<span class="definition">[patriotic donation grain] A kind of tax collected by the government during the commune and mutual aid team eras. It was grain that families or brigades had to give the government out of &quot;patriotism&quot; without any payment. The amount was initially based on real yields but then was set by the government based on presumed yields.</span>
										</p>
										<p class="term">
											<span class="orth">patriotic donation grain</span>
											<span class="romanization">[tib. rgyal gces gzhung 'bru; ch. gong liang]</span>
											<br/>
											<span class="definition">A kind of tax collected by the government during the commune and mutual aid team eras. It was grain that families or brigades had to give the government out of &quot;patriotism&quot; without any payment. The amount was initially based on real yields but then was set by the government based on presumed yields.</span>
										</p>

										<p class="term">
											<span class="orth">patrug</span>
											<span class="romanization">[tib. spa phrug]</span>
											<br/>
											<span class="definition">woman's traditional headdress ornament.</span>
										</p>
										<p class="term">
											<span class="orth">PCTAR</span>
											<span class="romanization"/>
											<br/>

											<span class="definition">Abbr. of: Preparatory Committee for [the implementation of] the Tibet Autonomous Region.</span>
										</p>
										<p class="term">
											<span class="orth">pecha</span>
											<span class="romanization">[dpe cha]</span>
											<br/>
											<span class="definition">a religious book/text.</span>
										</p>
										<p class="term">
											<span class="orth">pechai gegan</span>
											<span class="romanization">[dpe cha'i dge rgan]</span>
											<br/>

											<span class="definition">a monk teacher.</span>
										</p>
										<p class="term">
											<span class="orth">pechawa</span>
											<span class="romanization">[dpe cha ba]</span>
											<br/>
											<span class="definition">a monk studying the Buddhism philosophic curriculum.</span>
										</p>
										<p class="term">
											<span class="orth">phebsu</span>
											<span class="romanization">[tib. phebs gsu]</span>
											<br/>

											<span class="definition">custom of going to welcome someone</span>
										</p>
										<p class="term">
											<span class="orth">phog</span>
											<span class="romanization">[tib. phogs ]</span>
											<br/>
											<span class="definition">1. salary. 2. the money or grain &quot;salary&quot; distributed to monks from their monastery's endowment.</span>
										</p>

										<p class="term">
											<span class="orth">phorang</span>
											<span class="romanization">[tib. pho rang]</span>
											<br/>
											<span class="definition">refers to a man living alone. Sometimes to a man living alone who does not have arable land.</span>
										</p>
										<p class="term">
											<span class="orth">phul</span>
											<span class="romanization">[tib. phul]</span>
											<br/>

											<span class="definition">a unit of volume measurement. six phul equal one dre, and 120 phul equal one khe</span>
										</p>
										<p class="term">
											<span class="orth">phutru</span>
											<span class="romanization">[tib. bu phrug]</span>
											<br/>
											<span class="definition">Classification of a juvenile member of a class enemy or bad class status like representative of the lord or lord.</span>
										</p>
										<p class="term">
											<span class="orth">PLA</span>
											<span class="romanization"/>
											<br/>

											<span class="definition">abbreviation: People's Liberation Army.</span>
										</p>
										<p class="term">
											<span class="orth">platoon leader</span>
											<span class="romanization">[ch.]</span>
											<br/>
											<span class="definition">[pai zhang] platoon leader in the PLA.</span>
										</p>
										<p class="term">
											<span class="orth">political officer in Sikkim</span>
											<span class="romanization">[tib. 'bras spyi blon chen]</span>
											<br/>

											<span class="definition">the representative of the colonial Indian government in Sikkim who also had responsibility for British-Indian relations with Tibet.</span>
										</p>
										<p class="term">
											<span class="orth">p&#xF6;n</span>
											<span class="romanization">[tib. dpon ] [tib. mnga' bdag; ch. lingzhu]</span>
											<br/>
											<span class="definition">[ngadag] The person or institution (monastery, labrang) that owned manorial estates and serfs. Sometimes this is translated as lord and sometimes as serf-owner. From the peasant's perspective, it refered to his or her hereditary lord to whom he/she was obliged to provide corv&#xE9;e services or other taxes. In traditional Tibet, there were three main categories of lord: aristocratic lords, religious lords (monasteries or labrang), and the government as a lord. A person's link to a lord was hereditary and was passed on via parallel descent, that is to say, the sons of a couple belonged to the lord of the father and the daughters to the lord of his wife (if they had different lords).</span>
										</p>
										<p class="term">
											<span class="orth">progressives</span>
											<span class="romanization">[tib. yard&#xF6;nba (yar thon pa)]</span>
											<br/>

											<span class="definition">individuals from the better classes who were sympathetic or favorable to the communist party.</span>
										</p>
										<p class="term">
											<span class="orth">Publicity Team</span>
											<span class="romanization">[tib. dril bsgrags ru khag]]</span>
											<br/>
											<span class="definition">a unit that performs shows (songs and dances, etc.) to educate the masses about general ideology and specific campaigns</span>
										</p>
									</div>

									<div class="alpha" id="q">
										<span class="letter">Q</span>
										<p class="term">
											<span class="orth">qu</span>
											<span class="romanization">[ch.] [ch. qu]</span>
											<br/>
											<span class="definition">an administrative unit in post-1959 Tibet that is above the xiang and below the xian. [chu] 1. an administrative unit that is under a county but has authority over several xiang. Use of this unit was ended in the late 1980s throughout most of Tibet.
                      2. water</span>
										</p>
									</div>
									<div class="alpha" id="r">
										<span class="letter">R</span>

										<p class="term">
											<span class="orth">Ragashar</span>
											<span class="romanization">[rag kha shar]</span>
											<br/>
											<span class="definition">An aristocratic official and family name that is also called Dokhara [mdo mkhar ba].</span>
										</p>
										<p class="term">
											<span class="orth">ragyapa</span>
											<span class="romanization">[tib. rags rgyab pa]</span>
											<br/>

											<span class="definition">an untouchable hereditary group (caste) who take corpses to the sky burial in Lhasa</span>
										</p>
										<p class="term">
											<span class="orth">ration grain</span>
											<span class="romanization">[tib. sandru (bza' 'bru); ch. kou liang]</span>
											<br/>
											<span class="definition">The standard amount of grain that each member in a production team or brigade was provided regardless of work performed.</span>
										</p>
										<p class="term">
											<span class="orth">Rebels</span>
											<span class="romanization">[tib. gyenlo (gyen log); ch. zao fan]</span>
											<br/>

											<span class="definition">one of the two revolutionary groups in Tibet during the Cultural Revolution.</span>
										</p>
										<p class="term">
											<span class="orth">redeeming policy</span>
											<span class="romanization">[tib. blu nyo'i srid jus; ch. shumai zhengce]</span>
											<br/>
											<span class="definition">The &quot;buy-out&quot; policy of gradually nationalizing the means of production while compensating the bourgeoisie who owned the property for the loss of their resources. In Tibet, this policy was applied to progressive lords and elites.</span>
										</p>

										<p class="term">
											<span class="orth">residence card</span>
											<span class="romanization">[ch. huo kou; tib. themdo [them tho)]</span>
											<br/>
											<span class="definition">the card that identifies all individuals and their official place of residence. Until recently, people had to remain in the area specified in their residence card and it was difficult to get that changed, for example, from a rural area to an urban area.</span>
										</p>
										<p class="term">
											<span class="orth">responsibility system</span>
											<span class="romanization">[tib. 'gan gtsang; ch. cheng bao]</span>
											<br/>

											<span class="definition">[gentsang] The new economic system that replaced the communal system in the early 1980's. It literally means &quot;complete responsiblity&quot; (system). Under this new system, the commune/brigade's land was divided among individual households under a long-term lease arrangement and households were given complete responsibility over their own production.</span>
										</p>
										<p class="term">
											<span class="orth">rimshi</span>
											<span class="romanization">[tib. rim bzhi ]</span>
											<br/>
											<span class="definition">A fourth rank official in the Tibetan government.</span>
										</p>

										<p class="term">
											<span class="orth">rukhag</span>
											<span class="romanization">[tib. ru khag]</span>
											<br/>
											<span class="definition">a brigade (in a commune).</span>
										</p>
										<p class="term">
											<span class="orth">rukhe</span>
											<span class="romanization">[tib. ru khal ]</span>
											<br/>

											<span class="definition">the name of the official government size khe (abbreviation of tenzin kharu)</span>
										</p>
										<p class="term">
											<span class="orth">rungkhang</span>
											<span class="romanization">[tib. rung khang]</span>
											<br/>
											<span class="definition">kitchen in monasteries.</span>
										</p>
										<p class="term">
											<span class="orth">rup&#xF6;n</span>
											<span class="romanization">[tib. ru dpon]</span>
											<br/>

											<span class="definition">an military officer in the traditional Tibetan army just under a dep&#xF6;n. They were usually in charge of a half of a regiment (something like a battalion).</span>
										</p>
									</div>
									<div class="alpha" id="s">
										<span class="letter">S</span>
										<p class="term">
											<span class="orth">samadrok</span>
											<span class="romanization">[tib. sa ma 'brog]</span>
											<br/>

											<span class="definition">a type of subsistence economy that replies heavily on animal husbandry and farming. Usually involves having substantial herds of sheep/goats and or yak.</span>
										</p>
										<p class="term">
											<span class="orth">samtra</span>
											<span class="romanization">[tib. sam kkra]</span>
											<br/>
											<span class="definition">The traditional rectangular wooden/slate message board. This board was covered with chalk dust and then a stylus was used to clear away the chalk in the shape of the letters.</span>
										</p>
										<p class="term">
											<span class="orth">sandru</span>
											<span class="romanization">[tib. bza' bru] [tib. sandru (bza' 'bru); ch. kou liang]</span>
											<br/>

											<span class="definition">[ration grain] The standard amount of grain that each member in a production team or brigade was provided regardless of work performed.</span>
										</p>
										<p class="term">
											<span class="orth">sang</span>
											<span class="romanization">[tib. srang]</span>
											<br/>
											<span class="definition">unit of traditional Tibetan currency. Iwas was also called ng&#xFC;sang [dngul srang]. 50 ng&#xFC;sang = 1 dotse; 10 sho = 1 ng&#xFC;sang; 20 5-karma coins= 1 ng&#xFC;sang] There was no one sang coin, only a 3 sang coin called sangsum coin [srang gsum sgor mo]. However, more recently, paper currency notes of 7-sang, 25-sang, and 10-sang denominations were printed.</span>
										</p>

										<p class="term">
											<span class="orth">sarjel</span>
											<span class="romanization">[tib.gsar mjal]</span>
											<br/>
											<span class="definition">The audience-ceremony when an official gets a top positon that involves going to have an audience with the Dalai Lama or Regent. 2. The ceremony when a person first enters government service.</span>
										</p>
										<p class="term">
											<span class="orth">saship</span>
											<span class="romanization">[tib. sa zhib]</span>
											<br/>

											<span class="definition">a survey of land</span>
										</p>
										<p class="term">
											<span class="orth">satsig</span>
											<span class="romanization">[tib. sa tshigs]</span>
											<br/>
											<span class="definition">a station in the Tibetan government's corvee transportation network which was used to move goods throughout the country. Villagers were required to provide carrying animals as a corvee tax and transport the goods from their satsig to the next one where another group of villagers were obligated to move the goods to the next station. Satsig were situated half a day's trip from each other so that the villagers could return to their homes the same day. In addition to carrying animals, the villagers had to also provide people to accompany the animals and in many cases riding horses for the permit holders.</span>
										</p>
										<p class="term">
											<span class="orth">Sawang</span>
											<span class="romanization">[tib. sa dbang]</span>
											<br/>

											<span class="definition">a term of address used for a kal&#xF6;n.</span>
										</p>
										<p class="term">
											<span class="orth">sawangchemmo</span>
											<span class="romanization">[tib. sa dbang chen mo ]</span>
											<br/>
											<span class="definition">One of the members (called kal&#xF6;n or shape) of the Kashag, the highest office in the traditional Tibetan government. Sawangchemo was usually a term of address used for kal&#xF6;n or shape.</span>
										</p>

										<p class="term">
											<span class="orth">Sawangchemo</span>
											<span class="romanization">[tib. sa dbang chen mo]</span>
											<br/>
											<span class="definition">One of the members (called kal&#xF6;n or shape) of the Kashag, the highest office in the traditional Tibetan government. Sawangchemo was usually a term of address used for kal&#xF6;n or shape.</span>
										</p>
										<p class="term">
											<span class="orth">selling grain</span>
											<span class="romanization">[tib. tsongdru (tshong 'bru); ch. shang ping liang]</span>
											<br/>

											<span class="definition">[selling grain tax] Tsongdru was a government set quota of grain that villages (and in turn households in the villages) had sell to the government at a government set price. This was collected during the Mutual Aid Team and Commune periods (1960-the later 1970s).</span>
										</p>
										<p class="term">
											<span class="orth">selling grain tax</span>
											<span class="romanization">[tib. tsongdru (tshong 'bru); ch. shang ping liang]</span>
											<br/>
											<span class="definition">Tsongdru was a government set quota of grain that villages (and in turn households in the villages) had sell to the government at a government set price. This was collected during the Mutual Aid Team and Commune periods (1960-the later 1970s).</span>
										</p>
										<p class="term">
											<span class="orth">senampa</span>
											<span class="romanization">[tib. sras rnam pa ]</span>
											<br/>

											<span class="definition">A rank just below the 4th rank (rimshi) held by young officials from the upper level of the aristocracy when they first join the government.</span>
										</p>
										<p class="term">
											<span class="orth">Sendregasum</span>
											<span class="romanization">[tib. se 'bras dga' gsum]</span>
											<br/>
											<span class="definition">the abbreviation used for the three great monastic seats in Lhasa: Sera, Drepung and Ganden monasteries</span>
										</p>
										<p class="term">
											<span class="orth">senriy</span>
											<span class="romanization">[tib. zan ril]</span>
											<br/>

											<span class="definition">A divine lottery. Multiple answers to a question are written on paper of the same size and rolled in dough balls of the same size and weight. These are rolloed in a plate or bowl in front of a statue of a deity until one of the balls pops out. The ball that pops out is considered to have been selected by the diety before whom the lottery is done.</span>
										</p>
										<p class="term">
											<span class="orth">Sera je</span>
											<span class="romanization">[tib. se ra byes]</span>
											<br/>
											<span class="definition">One of the main colleges in Sera Monastery.</span>
										</p>
										<p class="term">
											<span class="orth">Sera mey</span>
											<span class="romanization">[tib. se ra smad]</span>
											<br/>

											<span class="definition">One of the of the main colleges in Sera monastery.</span>
										</p>
										<p class="term">
											<span class="orth">serf-owner</span>
											<span class="romanization">[tib. mnga' bdag; ch. lingzhu]</span>
											<br/>
											<span class="definition">[ngadag] The person or institution (monastery, labrang) that owned manorial estates and serfs. Sometimes this is translated as lord and sometimes as serf-owner. From the peasant's perspective, it refered to his or her hereditary lord to whom he/she was obliged to provide corv&#xE9;e services or other taxes. In traditional Tibet, there were three main categories of lord: aristocratic lords, religious lords (monasteries or labrang), and the government as a lord. A person's link to a lord was hereditary and was passed on via parallel descent, that is to say, the sons of a couple belonged to the lord of the father and the daughters to the lord of his wife (if they had different lords).</span>
										</p>
										<p class="term">
											<span class="orth">serf-servant</span>
											<span class="romanization">[tib. bran g.yog] [tib. bran g.yog]</span>
											<br/>

											<span class="definition">[trenyog] the lowest stratum of serf in Tibet. These were permanent/heredity house servants who had no separate means of subsistence. They were fed and clothed by their lord.  These were servants summoned involuntarily from among a lord's serfs and who received food and clothing but not wages per se. Thus the servants in the manor house on an estate or in the lrod's house in the capital were normally Trenyog.</span>
										</p>
										<p class="term">
											<span class="orth">Seven-One (7.1) State Farm</span>
											<span class="romanization">[ch. qi yi nong chang]</span>
											<br/>
											<span class="definition">one of the first state farms started in Tibet in the Nort&#xF6;lingka area opposite Drepung monastery.</span>
										</p>
										<p class="term">
											<span class="orth">shabd&#xF6;ba</span>
											<span class="romanization">[tib. zhabs sdod pa]]</span>
											<br/>

											<span class="definition">&quot;common&quot; rank monk and lay officials (those lower than seynamba)</span>
										</p>
										<p class="term">
											<span class="orth">shag</span>
											<span class="romanization">[tib. 1. shag;  2. zhag ]</span>
											<br/>
											<span class="definition">1. The apartment of a monk. 2. The butter fat that coagulates on the top of butter-tea in a teacup when the tea is left to sit for some time. If the tea had been made with a lot of butter, this layer could be thick enough to scoop off and save, sell or eat separately.</span>
										</p>

										<p class="term">
											<span class="orth">shagtsang</span>
											<span class="romanization">[tib. shag tshang]</span>
											<br/>
											<span class="definition">1. The &quot;corporate&quot; household of a monk or lama. 2. The apartment of a monk.</span>
										</p>
										<p class="term">
											<span class="orth">shamo</span>
											<span class="romanization">[tib. zhwa mo] [tib. zhwa mo; ch. dai mao]</span>
											<br/>

											<span class="definition">[hat] This was a common political slang term (label) used for people who were classified as class enemies or reactionaries. It was used as, &quot;They put the hat on him&quot;, or &quot;They never took his hat off.&quot;</span>
										</p>
										<p class="term">
											<span class="orth">shamtab</span>
											<span class="romanization">[tib. sham thabs]</span>
											<br/>
											<span class="definition">The lower part of a monk's robe.</span>
										</p>

										<p class="term">
											<span class="orth">shape</span>
											<span class="romanization">[tib. bka' blon]</span>
											<br/>
											<span class="definition">[kal&#xF6;n] One of the heads or ministers of the Kashag [bka' shag] or Council of Ministers. There were usually 4 kal&#xF6;n, although in the 1950s the number increased at various times to 6 or 7. The ministers made decisions collectively, and had no fixed term of office.</span>
										</p>
										<p class="term">
											<span class="orth">Sharchenjog</span>
											<span class="romanization">[tib. shar chen ljogs]</span>
											<br/>

											<span class="definition">The prison used for political prisoners that was located in the east wing of the Potala Palace in traditional Tibet.</span>
										</p>
										<p class="term">
											<span class="orth">Shash&#xF6;changsum</span>
											<span class="romanization">[sha zhol chang gsum]</span>
											<br/>
											<span class="definition">the three sil&#xF6;n appointed to rule in the 13th Dalai Lama's place while he was in exile.</span>
										</p>

										<p class="term">
											<span class="orth">Shatra</span>
											<span class="romanization">[tib. bshad sgra]</span>
											<br/>
											<span class="definition">family name of a Tibetan aristocratic official.</span>
										</p>
										<p class="term">
											<span class="orth">sheltawa</span>
											<span class="romanization">[zhal tab a]</span>
											<br/>

											<span class="definition">a servant who serves the monks serves the monks during their summer retreat.</span>
										</p>
										<p class="term">
											<span class="orth">shendama</span>
											<span class="romanization">[tib. zhal ta ma]</span>
											<br/>
											<span class="definition">maid-servant of an aristocrat.</span>
										</p>
										<p class="term">
											<span class="orth">shengo</span>
											<span class="romanization">[tib. zhal ngo]</span>
											<br/>

											<span class="definition">1. a minor officer in the traditional Tibetan army in charge of a platoon consisting of 25 soldiers. 2. the main disciplinary official for the monastery as a whole (rather than for a single college) in large monasteries.</span>
										</p>
										<p class="term">
											<span class="orth">shey</span>
											<span class="romanization">[tib. 1. shas; 2. she ]</span>
											<br/>
											<span class="definition">1. a type of lease for agricultural land where the leasee pays half of the yield to the leasee. 2. a type of arrangement wherein nomads are given female animals and have pay a tax every year in butter. Sometimes this tax is based on the actual number of lactating animals and sometimes it is fixed regardless of the number of lactating animals.</span>
										</p>
										<p class="term">
											<span class="orth">sheyngo</span>
											<span class="romanization">[tib. zhal ngo] [tib. zhal ngo]</span>
											<br/>

											<span class="definition">[shengo] 1. a minor officer in the traditional Tibetan army in charge of a platoon consisting of 25 soldiers. 2. the main disciplinary official for the monastery as a whole (rather than for a single college) in large monasteries.</span>
										</p>
										<p class="term">
											<span class="orth">Shide</span>
											<span class="romanization">[tib. bzhi sde]</span>
											<br/>
											<span class="definition">name of the monastery of Reting Rimpoche in the north of Lhasa.</span>
										</p>
										<p class="term">
											<span class="orth">shid&#xFC;</span>
											<span class="romanization">[tib. gzhis sdod]</span>
											<br/>

											<span class="definition">A manorial estate manager. This was usually the person who lived on the estate and managed the corv&#xE9;e work for the lord who possessed the estate.</span>
										</p>
										<p class="term">
											<span class="orth">shiga</span>
											<span class="romanization">[tib. gzhis ka]</span>
											<br/>
											<span class="definition">an estate</span>
										</p>
										<p class="term">
											<span class="orth">shinyer</span>
											<span class="romanization">[tib. gzhis gnyer]</span>
											<br/>

											<span class="definition">estate steward, the official who ran an estate under a lord.</span>
										</p>
										<p class="term">
											<span class="orth">sho</span>
											<span class="romanization">[tib. zho]</span>
											<br/>
											<span class="definition">a unit in the traditional Tibetan currency system. 10 sho equaled to 1 sang and 10 karma equaled one sho.</span>
										</p>
										<p class="term">
											<span class="orth">shock brigade</span>
											<span class="romanization">[tib. 'phral sgrub ru khag ]</span>
											<br/>

											<span class="definition">organization of activists who undertook difficult and laborious tasks and often who took the lead in political campaigns</span>
										</p>
										<p class="term">
											<span class="orth">Shod&#xF6;n</span>
											<span class="romanization">[zho ston]</span>
											<br/>
											<span class="definition">The &quot;yogurt&quot; festival at which time the Tibetan Opera was performed in Lhasa. The main opera performance in Lhasa was at the Norbulinga Palace grounds.</span>
										</p>

										<p class="term">
											<span class="orth">sh&#xF6; ga</span>
											<span class="romanization">[tib. shod  'gag]</span>
											<br/>
											<span class="definition">the secretariat office of the regent</span>
										</p>
										<p class="term">
											<span class="orth">sh&#xF6;gor</span>
											<span class="romanization">[tib. shod skor]</span>
											<br/>

											<span class="definition">The lay (aristocratic) officials of the Tibetan government.</span>
										</p>
										<p class="term">
											<span class="orth">Shol</span>
											<span class="romanization">[tib. Zhol ] [tib. Zhol]</span>
											<br/>
											<span class="definition">[Sh&#xF6;l] 1. The walled town beneath the Potala Palace in Lhasa. 2. The office that is responsible for law and order in Sh&#xF6;l and the areas around Lhasa.</span>
										</p>

										<p class="term">
											<span class="orth">Sh&#xF6;l</span>
											<span class="romanization">[tib. Zhol]</span>
											<br/>
											<span class="definition">1. The walled town beneath the Potala Palace in Lhasa. 2. The office that is responsible for law and order in Sh&#xF6;l and the areas around Lhasa.</span>
										</p>
										<p class="term">
											<span class="orth">Sh&#xF6;lkhang</span>
											<span class="romanization">[tib. zhol khang]</span>
											<br/>

											<span class="definition">a Tibetan aristocratic official.</span>
										</p>
										<p class="term">
											<span class="orth">Sh&#xF6;l legung</span>
											<span class="romanization">[tib. zhol las khungs]</span>
											<br/>
											<span class="definition">the main Tibetan government office for the areas in the vicinity of Lhasa but outside Lhasa proper. There were 18 dzong under this office.</span>
										</p>
										<p class="term">
											<span class="orth">sh&#xF6;ndre</span>
											<span class="romanization">[tib. gzhon khral]</span>
											<br/>

											<span class="definition">the work obligations all young monks have to do for the monastery (literally, it means &quot;youth tax&quot;).</span>
										</p>
										<p class="term">
											<span class="orth">sh&#xF6;ndr&#xF6;n</span>
											<span class="romanization">[tib. shod mgron]</span>
											<br/>
											<span class="definition">monk official aides working in the Secretariat of the Regent</span>
										</p>

										<p class="term">
											<span class="orth">sh&#xF6;ntrel</span>
											<span class="romanization">[tib. gzhon khral]</span>
											<br/>
											<span class="definition">the work obligation (tax) that all young monks have to perform in the monastery for a period of years.</span>
										</p>
										<p class="term">
											<span class="orth">Shot&#xF6;n</span>
											<span class="romanization">[zho ston] [zho ston]</span>
											<br/>

											<span class="definition">[Shod&#xF6;n] The &quot;yogurt&quot; festival at which time the Tibetan Opera was performed in Lhasa. The main opera performance in Lhasa was at the Norbulinga Palace grounds.</span>
										</p>
										<p class="term">
											<span class="orth">shung</span>
											<span class="romanization">[tib. gzhung]</span>
											<br/>
											<span class="definition">1. government.  2. the government of the Dalai Lama.</span>
										</p>

										<p class="term">
											<span class="orth">Shungba</span>
											<span class="romanization">[gzhung pa]</span>
											<br/>
											<span class="definition">the name for all those monk official students in the tse labdra who came from the tax on certain monasteries.</span>
										</p>
										<p class="term">
											<span class="orth">shungshab</span>
											<span class="romanization">[tib. gzhung zhabs]</span>
											<br/>

											<span class="definition">government official.</span>
										</p>
										<p class="term">
											<span class="orth">shungyupa</span>
											<span class="romanization">[tib. gzhung rgyugs pa]</span>
											<br/>
											<span class="definition">A type of peasant/serf whose lord was the government rather than an aristocrat or monastery/lama. They usually had sizable land holdings and were primarily responsible for providing corv&#xE9;e transport and riding animals for the Tibetan government's transportation system.</span>
										</p>
										<p class="term">
											<span class="orth">sil&#xF6;n</span>
											<span class="romanization">[tib. srid blon ]</span>
											<br/>

											<span class="definition">the title of the chief minister in the Tibetan government. These are usually only filled when the Dalai Lama is out of Lhasa in exile. WHen there is a sil&#xF6;n, the Kashag reports to him</span>
										</p>
										<p class="term">
											<span class="orth">simgag</span>
											<span class="romanization">[tib. gzim 'gag]</span>
											<br/>
											<span class="definition">a governmnet official who serves as a kind of &quot;bodyguard&quot; for a high official.</span>
										</p>

										<p class="term">
											<span class="orth">simkhang depa</span>
											<span class="romanization">[tib.gzim khang sde pa]</span>
											<br/>
											<span class="definition">A monastic official in Sendregasum.</span>
										</p>
										<p class="term">
											<span class="orth">simp&#xF6;n</span>
											<span class="romanization">[tib. gzim dpon]</span>
											<br/>

											<span class="definition">personal servant of a male lord.</span>
										</p>
										<p class="term">
											<span class="orth">simp&#xF6;n khempo</span>
											<span class="romanization">[tib. gzim dpon mkhan po ]</span>
											<br/>
											<span class="definition">The monk attendent in charge of the Dalai Lama's clothing.</span>
										</p>
										<p class="term">
											<span class="orth">sitsab</span>
											<span class="romanization">[tib. srid tshab]</span>
											<br/>

											<span class="definition">Acting Chief Minister. A custom begun in 1903/4 when the 13 Dalai Lama fled to China and Outer Mongolia. In his place he appointed several officials as sil&#xF6;n (srid blon) or chief ministers to assume the paramount ruling position while he was away. They functioned like a regent when the Dalai Lama was a child. In 1950, when the 14th Dalai Lama fled to Yadong on the Sikkim border, he appointed two acting sil&#xF6;n who were called sitsab, tsab meaning acting.</span>
										</p>
										<p class="term">
											<span class="orth">slob gso gsum</span>
											<span class="romanization">[tib. slob gso gsum] [tib. lobso sum (tib. slob gso gsum; ch. san jiao)]</span>
											<br/>
											<span class="definition">[Three Education Campaign] a campaign that started in Tibet in 1964-65 and included education on class, education on the prospects for socialism, and education on patriotism. It involved criticizing and holding struggle sessions against senior cadre. It was also called the Three Great Education Campaign</span>
										</p>

										<p class="term">
											<span class="orth">small householder</span>
											<span class="romanization">[tib. d&#xFC;jung (dud chung)] [tib. dud chung]</span>
											<br/>
											<span class="definition">[d&#xFC;jung] A type of serf (miser) household in traditional Tibetan society. D&#xFC;jung belonged to a a lord, but did not hold tax-base land (tib. khral rten). They usually were poor and survived by working for others or leasing land from treba (taxpayer) households.</span>
										</p>
										<p class="term">
											<span class="orth">Society School</span>
											<span class="romanization">[tib. spyi tshogs slob grwa]</span>
											<br/>

											<span class="definition">New school jointed started in 1952 by the Chinese and the Tbetan Government that was open to students from all classes in &quot;society.&quot; Thus the name.</span>
										</p>
										<p class="term">
											<span class="orth">s&#xF6;ndre</span>
											<span class="romanization">[tib. son bre ]</span>
											<br/>
											<span class="definition">a dre is a volume measure used for grains, and a s&#xF6;ndre is a dre of grain that was used as seed for planting a field. Twenty dre are equal to one khe or about 31 pounds of barley. Tibetans used this volume measure to delimit the size of their fields. A field of 3 s&#xF6;ndre in size, therefore, meant that it was a field that could be sown with 3 dre of seed.</span>
										</p>

										<p class="term">
											<span class="orth">s&#xF6;nkhe</span>
											<span class="romanization">[tib. son khal]</span>
											<br/>
											<span class="definition">A khe was the basic container Tibetans used to measure and exchange grain. The volume of one khe of barley was equal to roughly 31 pounds. S&#xF6;n means seed, so the term s&#xF6;nkhe meant a khe of seed. This term was used to delimit the size of fields in Tibet so that a field whose size was said to be 3 s&#xF6;nkhe, was a field on which 3 khe of seed should be sown.</span>
										</p>
										<p class="term">
											<span class="orth">s&#xF6;p&#xF6;n</span>
											<span class="romanization">[tib. gsol dpon ]</span>
											<br/>

											<span class="definition">a lama's servant</span>
										</p>
										<p class="term">
											<span class="orth">struggle meeting</span>
											<span class="romanization">[tib. thamdzing tsondu ('thab 'dzing tshogs 'du); ch. douzheng hui]</span>
											<br/>
											<span class="definition">[struggle session] Public accusation meetings at which the masses criticized and attacked (struggled against) class enemies and reactionaries, etc. Typically, the object of a struggle session would stand in front of the meeting bent over at the waist while the masses questioned and criticized, and often beat, him or her.</span>
										</p>
										<p class="term">
											<span class="orth">struggle sess</span>
											<span class="romanization">[tib. thamdzing tsondu ] [tib. thamdzing tsondu ('thab 'dzing tshogs 'du); ch. douzheng hui]</span>
											<br/>

											<span class="definition">meeting at which the masses criticized and attacked (struggled against) class enemies and reactionaries, etc. [struggle session] Public accusation meetings at which the masses criticized and attacked (struggled against) class enemies and reactionaries, etc. Typically, the object of a struggle session would stand in front of the meeting bent over at the waist while the masses questioned and criticized, and often beat, him or her.</span>
										</p>
										<p class="term">
											<span class="orth">struggle session</span>
											<span class="romanization">[tib. thamdzing tsondu ('thab 'dzing tshogs 'du); ch. douzheng hui]</span>
											<br/>
											<span class="definition">Public accusation meetings at which the masses criticized and attacked (struggled against) class enemies and reactionaries, etc. Typically, the object of a struggle session would stand in front of the meeting bent over at the waist while the masses questioned and criticized, and often beat, him or her.</span>
										</p>
									</div>

									<div class="alpha" id="t">
										<span class="letter">T</span>
										<p class="term">
											<span class="orth">tabyok</span>
											<span class="romanization">[tib. thab g.yog]</span>
											<br/>
											<span class="definition">cook's assistant</span>
										</p>
										<p class="term">
											<span class="orth">tagrik</span>
											<span class="romanization">[tib. rtags rigs]</span>
											<br/>

											<span class="definition">the next to last class in the d&#xFC;dra monastic curriculum.</span>
										</p>
										<p class="term">
											<span class="orth">Taktra</span>
											<span class="romanization">[tib. stag brag ] [tib. stag lung brag ]</span>
											<br/>
											<span class="definition">[Talungdra] the regent of Tibet who replaced Reting in 1941 and served until 1950 when the 14th Dalai Lama assumed power</span>
										</p>
										<p class="term">
											<span class="orth">talama</span>
											<span class="romanization">[tib. ta bla ma ]</span>
											<br/>

											<span class="definition">a title given to trunyichemmo and oracles/mediums</span>
										</p>
										<p class="term">
											<span class="orth">ta lama ( or talama)</span>
											<span class="romanization">[tib. ta bla ma]</span>
											<br/>
											<span class="definition">1. the title of the senior-most official (Trunyichemmo) in the Yigtsang Office. 2. a high title for monk officials.</span>
										</p>
										<p class="term">
											<span class="orth">Talungdra</span>
											<span class="romanization">[tib. stag lung brag ]</span>
											<br/>

											<span class="definition">the regent of Tibet who replaced Reting in 1941 and served until 1950 when the 14th Dalai Lama assumed power</span>
										</p>
										<p class="term">
											<span class="orth">tanjur</span>
											<span class="romanization">[tib. bstan 'gyur]</span>
											<br/>
											<span class="definition">the collection of 225 violues of commentary on the Buddha's teaching</span>
										</p>
										<p class="term">
											<span class="orth">tapa</span>
											<span class="romanization">[tib. rta pa ]</span>
											<br/>

											<span class="definition">a person riding a horse</span>
										</p>
										<p class="term">
											<span class="orth">TAR</span>
											<span class="romanization"/>
											<br/>
											<span class="definition">abbreviation: Tibet Autonomous Region</span>
										</p>
										<p class="term">
											<span class="orth">Tartsedo</span>
											<span class="romanization">[tib. dar rtse mdo]] [tib. dar rtse mdo ]</span>
											<br/>

											<span class="definition">see Dartsedo [Dartsedo] the last Tibetan town in Kham; the prefectural seat of Ganzi Prefecture</span>
										</p>
										<p class="term">
											<span class="orth">taxpayer</span>
											<span class="romanization">[tib. treba (khral pa)] [tib. khral pa]</span>
											<br/>
											<span class="definition">[treba] The class of peasant serf households who held farmland and had to fulfill large tax obligations to their lords. They are often called taxpayer households in English. While some of these were well off by local standards, many were poor due a variety of factors such as heavy debts and a dearth of able-bodied workers in their households.</span>
										</p>
										<p class="term">
											<span class="orth">tayok</span>
											<span class="romanization">[tib. rta g.yog]</span>
											<br/>

											<span class="definition">stable boy, groom for horses.</span>
										</p>
										<p class="term">
											<span class="orth">tentshig gyama</span>
											<span class="romanization">[tib. bstan tshigs rgya ma or gtan tshigs rgya ma]</span>
											<br/>
											<span class="definition">a weighing scale made from wood. It was the standard scale in traditional Tibet and had the seal of the Tibetan Government on it.</span>
										</p>
										<p class="term">
											<span class="orth">tenzin kharu</span>
											<span class="romanization">[tib. bstan dzin mkha' ru or gtan tshigs mkha' ru] [tib. khal]</span>
											<br/>

											<span class="definition">a volume measure for grains. For barley it weighed about 31 pounds. [khe] a traditional volume measurement for measuring grain in the traditional Tibetan society. Sizes varied somewhat, but the official government khe (called mkhar ru or bstan dzin mkha ru) weighed about 31 pounds for barley. It was universally used in traditional Tibet as a land measurement in that fields would be said to be of a size able to use a certain number of  khe of seed (called s&#xF6;nkhe).</span>
										</p>
										<p class="term">
											<span class="orth">thabyog</span>
											<span class="romanization">[tib. thab g.yog ]</span>
											<br/>
											<span class="definition">Monks who work in the kitchen.</span>
										</p>
										<p class="term">
											<span class="orth">thamdzing</span>
											<span class="romanization">[tib. 'thab 'dzing] [tib. thamdzing tsondu ('thab 'dzing tshogs 'du); ch. douzheng hui]</span>
											<br/>

											<span class="definition">[struggle session] Public accusation meetings at which the masses criticized and attacked (struggled against) class enemies and reactionaries, etc. Typically, the object of a struggle session would stand in front of the meeting bent over at the waist while the masses questioned and criticized, and often beat, him or her.</span>
										</p>
										<p class="term">
											<span class="orth">thanggu</span>
											<span class="romanization">[tib. thang khug]</span>
											<br/>
											<span class="definition">skin bag in which tsampa is mixed (and sometimes sold in towns).</span>
										</p>
										<p class="term">
											<span class="orth">theiji</span>
											<span class="romanization">tib. th'e ji ]</span>
											<br/>

											<span class="definition">A Third rank title in the Tibetan governmnet. The wprd derives from Mongolian.</span>
										</p>
										<p class="term">
											<span class="orth">tho</span>
											<span class="romanization">[tib. mtho]</span>
											<br/>
											<span class="definition">a traditional Tibetan measure that was equal to the span from the thumb to the middle finger outstretched.</span>
										</p>
										<p class="term">
											<span class="orth">th&#xF6;nja</span>
											<span class="romanization">[tib. thon phyag ]</span>
											<br/>

											<span class="definition">The official departure audience of a traditional Tibetan government official with the ruler before leaving for a post outside of Lhasa.</span>
										</p>
										<p class="term">
											<span class="orth">Three Big Mountains</span>
											<span class="romanization">[tib. ri bo chen po gsum]</span>
											<br/>
											<span class="definition">slogan used in 1959-60 for the three great serf owners: the Tibetan government, the aristocracy and the monasteries/lamas.</span>
										</p>
										<p class="term">
											<span class="orth">Three Education Campaign</span>
											<span class="romanization">[tib. lobso sum (tib. slob gso gsum; ch. san jiao)]</span>
											<br/>

											<span class="definition">a campaign that started in Tibet in 1964-65 and included education on class, education on the prospects for socialism, and education on patriotism. It involved criticizing and holding struggle sessions against senior cadre. It was also called the Three Great Education Campaign</span>
										</p>
										<p class="term">
											<span class="orth">Three Great Education</span>
											<span class="romanization">[tib. lobso sum (tib. slob gso gsum; ch. san jiao)]</span>
											<br/>
											<span class="definition">[Three Education Campaign] a campaign that started in Tibet in 1964-65 and included education on class, education on the prospects for socialism, and education on patriotism. It involved criticizing and holding struggle sessions against senior cadre. It was also called the Three Great Education Campaign</span>
										</p>
										<p class="term">
											<span class="orth">Three Great Education Campaign</span>
											<span class="romanization">[tib. lobso chempo sum (tib. slob gso chen po gsum; ch. san da jiao)] [tib. lobso sum (tib. slob gso gsum; ch. san jiao)]</span>
											<br/>

											<span class="definition">[Three Education Campaign] a campaign that started in Tibet in 1964-65 and included education on class, education on the prospects for socialism, and education on patriotism. It involved criticizing and holding struggle sessions against senior cadre. It was also called the Three Great Education Campaign</span>
										</p>
										<p class="term">
											<span class="orth">Three Oppositions and Two Concessions</span>
											<span class="romanization">[tib. ngog&#xF6;sum dang chayan nyi (ngo rgol gsum dang chag yang gnyis); ch. san fan shuang jian]</span>
											<br/>
											<span class="definition">this slogan refers to the 1959 campaign that advocated the need to oppose rebellion, corvee taxes, and enslavement and the provision of concessions on land taxes and loan interest.</span>
										</p>
										<p class="term">
											<span class="orth">Three Oppositions and Two Exemptions</span>
											<span class="romanization">[tib. ngog&#xF6;sum dang chayan nyi (ngo rgol gsum dang chag yang gnyis); ch. san fan shuang jian]</span>
											<br/>

											<span class="definition">[Three Oppositions and Two Concessions] this slogan refers to the 1959 campaign that advocated the need to oppose rebellion, corvee taxes, and enslavement and the provision of concessions on land taxes and loan interest.</span>
										</p>
										<p class="term">
											<span class="orth">th&#xFC;</span>
											<span class="romanization">[tib. thud]</span>
											<br/>
											<span class="definition">a Tibetan food made from a mixture of butter and cheese. Often sugar or congealed molasses sugar [bu ram] is added.</span>
										</p>
										<p class="term">
											<span class="orth">thukpa</span>
											<span class="romanization">[tib.thug pa]</span>
											<br/>

											<span class="definition">1. Porridges or gruel-like soups. 2. noodle dishes in broth.</span>
										</p>
										<p class="term">
											<span class="orth">thukpa bagthuk</span>
											<span class="romanization">[tib. thug pa bag thug]</span>
											<br/>
											<span class="definition">traditional soup with small dumplings of dough.</span>
										</p>
										<p class="term">
											<span class="orth">T&#xF6;</span>
											<span class="romanization">[tib. stod]</span>
											<br/>

											<span class="definition">the traditional name for the region of Far Western Tibet.</span>
										</p>
										<p class="term">
											<span class="orth">tonggang</span>
											<span class="romanization">[tib. stongs rkang]</span>
											<br/>
											<span class="definition">a gang for which the household holding it has become extinct or run away. The remaining households therefore, collectively planted their land and collectively paid its taxes.</span>
										</p>
										<p class="term">
											<span class="orth">tonggo</span>
											<span class="romanization">[gtong sgo]</span>
											<br/>

											<span class="definition">A monastic obligation to provide the food and other necessary items served at a monastic prayer assembly meeting or some other rite; this was often a required obligation for monastic officials at the end of their term of office.</span>
										</p>
										<p class="term">
											<span class="orth">torgya</span>
											<span class="romanization">[tib. gtor rgyag]</span>
											<br/>
											<span class="definition">1. An ritiual exorcism to ward away evil. 2. The exorcism that ends the M&#xF6;nlam Prayer Festival.</span>
										</p>
										<p class="term">
											<span class="orth">torma</span>
											<span class="romanization">[tib. gtor ma]</span>
											<br/>

											<span class="definition">a ritual offering made by monks from tsampa and water.</span>
										</p>
										<p class="term">
											<span class="orth">trachag</span>
											<span class="romanization">[tib. grwa 'phyags]</span>
											<br/>
											<span class="definition">monks recruited by the governmnet to undergo training to become monk officials in the traditional Tibetan government</span>
										</p>
										<p class="term">
											<span class="orth">tragy&#xFC;n</span>
											<span class="romanization">[tib. grwa rgyun]</span>
											<br/>

											<span class="definition">the name for monks who come to Drepung, Ganden and Sera from long distances such as Kham and Amdo.</span>
										</p>
										<p class="term">
											<span class="orth">traja</span>
											<span class="romanization">[tib. grwa ja]</span>
											<br/>
											<span class="definition">The prayer session sponsored by the tratsang (college) at which tea was served to the monks. , etc.</span>
										</p>
										<p class="term">
											<span class="orth">trangga</span>
											<span class="romanization">[trang ka]</span>
											<br/>

											<span class="definition">A unit in the traditional Tibetan currency system that was equal to 4 sang</span>
										</p>
										<p class="term">
											<span class="orth">trangga garpo</span>
											<span class="romanization">[trang ka dkar po]</span>
											<br/>
											<span class="definition">a unit in the traditional Tibetan currency system that was equal to 4 sang.</span>
										</p>
										<p class="term">
											<span class="orth">tranka</span>
											<span class="romanization">[tib. tram kha]</span>
											<br/>

											<span class="definition">a Tibetan coin.</span>
										</p>
										<p class="term">
											<span class="orth">Trapchi</span>
											<span class="romanization">[tib. grwa bzhi]</span>
											<br/>
											<span class="definition">1. an area below Sera monastery. 2. the location of the Tibetan Armory-Mint Office and the regimental headquarters of the Khadang regiment which was also called the Trapchi  regiment.</span>
										</p>
										<p class="term">
											<span class="orth">tratsang</span>
											<span class="romanization">[tib. grwa tshang]</span>
											<br/>

											<span class="definition">A monastic college within a monastery, foe example, in Drepung monastery there were four main tratsang: Gomang, Loseling, Deyang and Ngagpa. These tratsang were property owning corpoate entities and included monks who were organized into Residential dormatories called khamtsen.</span>
										</p>
										<p class="term">
											<span class="orth">tratsang tr&#xFC;ku</span>
											<span class="romanization">[tib. grwa tshang sprul sku ]</span>
											<br/>
											<span class="definition">low rank tr&#xFC;ku who does not have government recognition</span>
										</p>

										<p class="term">
											<span class="orth">treba</span>
											<span class="romanization">[tib. khral pa]</span>
											<br/>
											<span class="definition">The class of peasant serf households who held farmland and had to fulfill large tax obligations to their lords. They are often called taxpayer households in English. While some of these were well off by local standards, many were poor due a variety of factors such as heavy debts and a dearth of able-bodied workers in their households.</span>
										</p>
										<p class="term">
											<span class="orth">Tregang</span>
											<span class="romanization">[tib. bkras khang]</span>
											<br/>

											<span class="definition">name of an aristocratic family.</span>
										</p>
										<p class="term">
											<span class="orth">tregang</span>
											<span class="romanization">[tib. khral rkang]</span>
											<br/>
											<span class="definition">the main tax unit for arable land in the traditional society in Tibet.</span>
										</p>
										<p class="term">
											<span class="orth">trema</span>
											<span class="romanization">[tib. sran ma]</span>
											<br/>

											<span class="definition">lentil</span>
										</p>
										<p class="term">
											<span class="orth">trenyog</span>
											<span class="romanization">[tib. bran g.yog]</span>
											<br/>
											<span class="definition">the lowest stratum of serf in Tibet. These were permanent/heredity house servants who had no separate means of subsistence. They were fed and clothed by their lord.  These were servants summoned involuntarily from among a lord's serfs and who received food and clothing but not wages per se. Thus the servants in the manor house on an estate or in the lrod's house in the capital were normally Trenyog.</span>
										</p>
										<p class="term">
											<span class="orth">trerim</span>
											<span class="romanization">[tib. gral rim]</span>
											<br/>

											<span class="definition">1. a social class.  2. in Tibet was also used to convey class enemy. In some areas class enemy was called &quot;drawo&quot; [tib. dgra bo].</span>
										</p>
										<p class="term">
											<span class="orth">trimgo rangtsen</span>
											<span class="romanization">[tib. khrims 'go rang btsan]</span>
											<br/>
											<span class="definition">The right of a lord or monastery to exercise judicial authority over one's serfs/subjects or monks.</span>
										</p>

										<p class="term">
											<span class="orth">trinj&#xFC;</span>
											<span class="romanization">[tib. 'phrin bcol ]</span>
											<br/>
											<span class="definition">an offering to a protector deity accompanied by prayers</span>
										</p>
										<p class="term">
											<span class="orth">Trogawa</span>
											<span class="romanization">[tib. khro dga' ba]</span>
											<br/>

											<span class="definition">A lay aristocratic official fanily in the Tibetan governmnet.</span>
										</p>
										<p class="term">
											<span class="orth">Trokhang,</span>
											<span class="romanization">[tib. spro khang]</span>
											<br/>
											<span class="definition">A summer cottage.</span>
										</p>
										<p class="term">
											<span class="orth">Tromo</span>
											<span class="romanization">[tib. gro mo]</span>
											<br/>

											<span class="definition">[Yadong] the Chinese name for the Tibetan town called Tromo located on the Sikkim border. It was the location where the 14th Dalai Lama stayed for several months in 1950-51 after fleeing from Lhasa.</span>
										</p>
										<p class="term">
											<span class="orth">Tromsikang</span>
											<span class="romanization">[tib. khrom gzigs khang]</span>
											<br/>
											<span class="definition">An open market located at the north of the Jokhang and the Nangtsesha (prison and office of the Lhasa mayor). It traditionally sold miscellaneous foodstuffs and new and old goods.</span>
										</p>
										<p class="term">
											<span class="orth">tr&#xFC;ku</span>
											<span class="romanization">[tib. sprul sku]</span>
											<br/>

											<span class="definition">an incarnate lama.</span>
										</p>
										<p class="term">
											<span class="orth">trungja</span>
											<span class="romanization">[tib. drung ja]</span>
											<br/>
											<span class="definition">1. the rite of daily tea served to Tibetan monk officials. It started at about 9 and lasted for an hour or so. When the Tsega was in Potala it was held there and then it was in Norbulinga it was held there. All monk officials in Lhasa were expected to attend. This can also refer to other formal morning tea prayer ceremonies, for example, when the regent was traveling.</span>
										</p>
										<p class="term">
											<span class="orth">trungtsi</span>
											<span class="romanization">[tib. drung rtsis ]</span>
											<br/>

											<span class="definition">The eight trunyichemmo and tsip&#xF6;n; these eight officials (the four trunyichemmo and four tsip&#xF6;n) were often called to meet with the Kashag to discuss important issues. They also were the smallest of the Tibetan traditional government assemblies.</span>
										</p>
										<p class="term">
											<span class="orth">trungtsigye</span>
											<span class="romanization">[tib. drung rtsis brgyad]</span>
											<br/>
											<span class="definition">the eight trunyichemmo and tsip&#xF6;n; these eight officials (the four trunyichemmo and four tsip&#xF6;n) were often called to meet with the Kashag to discuss important issues. They were the smallest of the Tibetan traditional government assemblies.</span>
										</p>

										<p class="term">
											<span class="orth">trunyichemmo</span>
											<span class="romanization">[tib. drung yig chen mo]</span>
											<br/>
											<span class="definition">TOne of the four heads of the yigtshang office (Ecclesiasitics Office) of the traditional Tibetan government. This was the highest office that dealt with monastic and religious affairs and the office in charge of the recruitment and promotion of monk officials.</span>
										</p>
										<p class="term">
											<span class="orth">tsamba</span>
											<span class="romanization">[tib. rtsam pa]</span>
											<br/>

											<span class="definition">the traditional Tibetan staple food that consists of grain that is roasted in sand and then ground into a flour-like consistency.</span>
										</p>
										<p class="term">
											<span class="orth">tsampa</span>
											<span class="romanization">[tib. rtsam phogs] [tib. rtsam pa]</span>
											<br/>
											<span class="definition">[tsamba] the traditional Tibetan staple food that consists of grain that is roasted in sand and then ground into a flour-like consistency.</span>
										</p>
										<p class="term">
											<span class="orth">tsampa balls</span>
											<span class="romanization">[tib. spag]</span>
											<br/>

											<span class="definition">a Tibetan staple is to mix tea with tsampa flour in a bowl and knead it into a ball the constituency of bread dough.</span>
										</p>
										<p class="term">
											<span class="orth">tsampa soup</span>
											<span class="romanization">[tib. rtsam thug]</span>
											<br/>
											<span class="definition">a soup made from water and tsampa. Can also include meat, cheese, etc. depending on wealth.</span>
										</p>
										<p class="term">
											<span class="orth">Tsang</span>
											<span class="romanization">[tib. gtsang]</span>
											<br/>

											<span class="definition">one of the major areas of Tibet. It covers a large area in southwest Tibet whose main city is Shigatse.</span>
										</p>
										<p class="term">
											<span class="orth">Tsangpa</span>
											<span class="romanization">[tib. gtsang pa ]</span>
											<br/>
											<span class="definition">a person from Tsang</span>
										</p>
										<p class="term">
											<span class="orth">tse</span>
											<span class="romanization">[tib. rtse]</span>
											<br/>

											<span class="definition">Potala Palace</span>
										</p>
										<p class="term">
											<span class="orth">tse ga</span>
											<span class="romanization">[tib. rtse 'gag ]</span>
											<br/>
											<span class="definition">the Secretariat of the Dalai Lama</span>
										</p>
										<p class="term">
											<span class="orth">tsegutor</span>
											<span class="romanization">[tib. rtse dgu gtor ]</span>
											<br/>

											<span class="definition">The exorcism rite held in the Potala on the 29th of the 12th Tibetan month.</span>
										</p>
										<p class="term">
											<span class="orth">tseja</span>
											<span class="romanization">[tib. rtse phyag]</span>
											<br/>
											<span class="definition">1. The treasury office in the Potala that supplied things for the Dalai Lama. 2. The name/title of the official that headed the Tseja office.</span>
										</p>
										<p class="term">
											<span class="orth">tse labdra</span>
											<span class="romanization">[rtse slob grwa]</span>
											<br/>

											<span class="definition">the school for training monk officials in the Potala that was run by the Yigtsang Office.</span>
										</p>
										<p class="term">
											<span class="orth">tsema</span>
											<span class="romanization">[tib. tshad ma]</span>
											<br/>
											<span class="definition">logic (in Buddhist dialectics).</span>
										</p>
										<p class="term">
											<span class="orth">tsendr&#xF6;n</span>
											<span class="romanization">[tib. rtse mgron]</span>
											<br/>

											<span class="definition">the monk official aides (ADC's) in the tse ga, the Secretariat of the Dalai Lama.</span>
										</p>
										<p class="term">
											<span class="orth">Tsenshab</span>
											<span class="romanization">[tib.. mtshan zhabs]</span>
											<br/>
											<span class="definition">The debating assistant for the Dalai Lama.</span>
										</p>
										<p class="term">
											<span class="orth">tsenyi</span>
											<span class="romanization">[mtshan nyid]</span>
											<br/>

											<span class="definition">Buddhist dialectics. This is taught following the six year curriculum in d&#xFC;dra.</span>
										</p>
										<p class="term">
											<span class="orth">Tshaja</span>
											<span class="romanization">[tib. tsha phyag]</span>
											<br/>
											<span class="definition">the manager of Tsha khamtsen in Drepung monastery</span>
										</p>
										<p class="term">
											<span class="orth">tshasho</span>
											<span class="romanization">[tib. tsha zho]</span>
											<br/>

											<span class="definition">salt and wool tax collector for the traditional Tibetan government.</span>
										</p>
										<p class="term">
											<span class="orth">Tsheba Lhakang</span>
											<span class="romanization">[tib. tshe dpag lha khang]</span>
											<br/>
											<span class="definition">the temple of Tshe dpal med, the Longevity Deity that was located in front of the Ramoche temple in Lhasa.</span>
										</p>
										<p class="term">
											<span class="orth">tsho</span>
											<span class="romanization">[tib. tsho]</span>
											<br/>

											<span class="definition">a group or administrative unit, typically used in nomad areas</span>
										</p>
										<p class="term">
											<span class="orth">tshog</span>
											<span class="romanization">[tib. tshog]</span>
											<br/>
											<span class="definition">A cone-shaped religious offering made predominantly of tsampa</span>
										</p>
										<p class="term">
											<span class="orth">tshogchen</span>
											<span class="romanization">[tib. tshogs chen]</span>
											<br/>

											<span class="definition">the assembly hall of the monastery as a whole.</span>
										</p>
										<p class="term">
											<span class="orth">Tshogchen Umdze</span>
											<span class="romanization">[tib. tshogs chen dbu mdzad]</span>
											<br/>
											<span class="definition">the prayer/chant leader of the monastery as a whole.</span>
										</p>
										<p class="term">
											<span class="orth">tshogpa</span>
											<span class="romanization">[tib. tshogs pa ]</span>
											<br/>

											<span class="definition">an organization, an association, a group</span>
										</p>
										<p class="term">
											<span class="orth">Tshom&#xF6;nling</span>
											<span class="romanization">[tib. mtsho smon gling]</span>
											<br/>
											<span class="definition">The name of a famous lama and labrang in the north of Lhasa.</span>
										</p>
										<p class="term">
											<span class="orth">tshong 'bru</span>
											<span class="romanization">[tib. tshong 'bru] [tib. tshong 'bru; ch. shang ping liang]</span>
											<br/>

											<span class="definition">[grain quota tax]</span>
										</p>
										<p class="term">
											<span class="orth">tshongji</span>
											<span class="romanization">[tib. tshong spyi]</span>
											<br/>
											<span class="definition">Trade Agent at Gyantse (this was a fourth rank government official)</span>
										</p>
										<p class="term">
											<span class="orth">tshongj&#xF6;</span>
											<span class="romanization">[tib.tshogs mchod]</span>
											<br/>

											<span class="definition">The name of the religious prayer festival held in Lhasa in the 2nd Tibetan lunar month.</span>
										</p>
										<p class="term">
											<span class="orth">tshop&#xF6;n</span>
											<span class="romanization">[tib. tsho dpon ]</span>
											<br/>
											<span class="definition">the head of a Tsho</span>
										</p>
										<p class="term">
											<span class="orth">tsidrug</span>
											<span class="romanization">[tib. rtsis phrug pa ]</span>
											<br/>

											<span class="definition">a trainee studying for admission as a full governmnet official in the lay aristocratic segment of the Tibetan government. They were part of the Tsikhang (finance) office.</span>
										</p>
										<p class="term">
											<span class="orth">tsidrung</span>
											<span class="romanization">[tib. rtse drung]</span>
											<br/>
											<span class="definition">a monk official in the Tibetan government.</span>
										</p>
										<p class="term">
											<span class="orth">Tsidrung Lingka</span>
											<span class="romanization">[rtse drung gling ka]</span>
											<br/>

											<span class="definition">a park/grove in the southeast part of Lhasa by the river.</span>
										</p>
										<p class="term">
											<span class="orth">Tsikhang</span>
											<span class="romanization">[tib. rtsis khang]</span>
											<br/>
											<span class="definition">the revenue/finance department of the traditional Tibetan government.</span>
										</p>
										<p class="term">
											<span class="orth">tsip&#xF6;n</span>
											<span class="romanization">[tib. rtsis dpon]</span>
											<br/>

											<span class="definition">One of the four head of the Tsikhang office in the tradsitional Tibetan government. This was the second most powerful lay office, falling just below the Kashag.</span>
										</p>
										<p class="term">
											<span class="orth">tsodrag</span>
											<span class="romanization">[tib. gtso drag]</span>
											<br/>
											<span class="definition">an important local district (county) official in the old soceity who was selected from among the rich peasant households.</span>
										</p>
										<p class="term">
											<span class="orth">tsog</span>
											<span class="romanization">[tib. tshogs]</span>
											<br/>

											<span class="definition">1. an offering made of tsamba and burtter and dry cheese in the shape of a triable with rounded sides. 2. a prayer assembly meeting in monasteries when all the monk come to an assembly hall and chant prayers together. This is one of the main continuning activities in monasteries.</span>
										</p>
										<p class="term">
											<span class="orth">tsogchen</span>
											<span class="romanization">[tib. tshogs chen]</span>
											<br/>
											<span class="definition">the prayer assembly for the monastery as a whole (including all the colleges). Also used to refer to the monastery as a whole.</span>
										</p>
										<p class="term">
											<span class="orth">tsogchen tr&#xFC;ku</span>
											<span class="romanization">[tib. tshog chen sprul sku]</span>
											<br/>

											<span class="definition">middle rank tr&#xFC;ku who are exempt from all obligations and taxes in the monastery</span>
										</p>
										<p class="term">
											<span class="orth">tsogjen</span>
											<span class="romanization">[tib. tshogs chen]</span>
											<br/>
											<span class="definition">[tsogchen] the prayer assembly for the monastery as a whole (including all the colleges). Also used to refer to the monastery as a whole.</span>
										</p>
										<p class="term">
											<span class="orth">tsomja</span>
											<span class="romanization">[tib. tshom ja]</span>
											<br/>

											<span class="definition">the tea served to monks at the khamtsen's prayer assembly meetings</span>
										</p>
										<p class="term">
											<span class="orth">Ts&#xF6;na</span>
											<span class="romanization">[tib. mtsho sna]</span>
											<br/>
											<span class="definition">an area in southern Tibet. [M.0001.01]</span>
										</p>
										<p class="term">
											<span class="orth">tsondo</span>
											<span class="romanization">[tib. gtso 'du]</span>
											<br/>

											<span class="definition">the Assembly of the Tibetan Government.</span>
										</p>
										<p class="term">
											<span class="orth">tsondu</span>
											<span class="romanization">[tib. tshogs 'du]</span>
											<br/>
											<span class="definition">1. An assembly meeting. 2. The general name for the various level official &quot;assembly&quot; meetings.</span>
										</p>

										<p class="term">
											<span class="orth">tsondu gyendzom</span>
											<span class="romanization">[tib. tshogs 'du rgyas 'dzoms]</span>
											<br/>
											<span class="definition">the largest Assembly of the traditional Tibetan government.</span>
										</p>
										<p class="term">
											<span class="orth">tsondu hragdu</span>
											<span class="romanization">[tib. tshogs 'du hrag bsdus]</span>
											<br/>

											<span class="definition">The Abbreviated Assembly of the Tibetan government. It consisted of the trungtsigye and the abbots of Sendregasum.</span>
										</p>
										<p class="term">
											<span class="orth">tsondu hragdu gyeba</span>
											<span class="romanization">[tib. tshogs 'du hrag bsdus rgyas pa]</span>
											<br/>
											<span class="definition">the Enlarged Abbreviated Assembly of the Tibetan Government that included the trungtsigye, the abbots and ex-abbots of a select number of monasteries such as Sera, Ganden and Drepung, and representatives of ranks of the Tibetan government.</span>
										</p>
										<p class="term">
											<span class="orth">tsondzin</span>
											<span class="romanization">[tib. 'tsho  'dzin]</span>
											<br/>

											<span class="definition">A kind of &quot;trustee&quot; for a family or labrang who oversaw economics and gave advice to make sure that things were going in the right direction, but was not directly involved in the sense of holding a title or staff position. For example, when the father of the 14th Dalai Lama died, the government appointed two officials to act as tsondzin for the family.</span>
										</p>
										<p class="term">
											<span class="orth">tsongdu</span>
											<span class="romanization">[tib. tshogs 'du]</span>
											<br/>
											<span class="definition">[tsondu] 1. An assembly meeting. 2. The general name for the various level official &quot;assembly&quot; meetings.</span>
										</p>

										<p class="term">
											<span class="orth">tsugchen</span>
											<span class="romanization"/>
											<br/>
											<span class="definition">a type of intermediate size script that Tibetans learn in school.</span>
										</p>
										<p class="term">
											<span class="orth">tsugdrang</span>
											<span class="romanization">[ch. zhu zhang]</span>
											<br/>

											<span class="definition">team leader.</span>
										</p>
										<p class="term">
											<span class="orth">Tsugiphodrang</span>
											<span class="romanization">tib. mtsho dkyil pho brang]</span>
											<br/>
											<span class="definition">a small palace in the Norbukinga Palace grounds.</span>
										</p>
										<p class="term">
											<span class="orth">Tsuglagang</span>
											<span class="romanization"/>
											<br/>

											<span class="definition">the famous temple in center of Lhasa that also housed important government offices like the Kashag. The Jokang is part of this temple, and frequently that terms is used for the entire temple. The Barkor cicular (circumambulation) road goes around the Tsuglagang.</span>
										</p>
										<p class="term">
											<span class="orth">tuan</span>
											<span class="romanization">[ch.]</span>
											<br/>
											<span class="definition">regiment.</span>
										</p>
										<p class="term">
											<span class="orth">t&#xFC;lku</span>
											<span class="romanization">[tib. sprul sku] [tib. sprul sku]</span>
											<br/>

											<span class="definition">[tr&#xFC;ku] an incarnate lama.</span>
										</p>
									</div>
									<div class="alpha" id="u">
										<span class="letter">U</span>
										<p class="term">
											<span class="orth">uch&#xF6;</span>
											<span class="romanization">[tib. dbu chos]</span>
											<br/>

											<span class="definition">a term referring to the umdze (chant/prayer leader) and the geg&#xF6; (disciplinary chief -in large monasteries of a tratsang) in monasteries.</span>
										</p>
										<p class="term">
											<span class="orth">uchung</span>
											<span class="romanization">[tib. dbu chung]</span>
											<br/>
											<span class="definition">second highest title for title for wood-block carvers in traditional Tibet.</span>
										</p>

										<p class="term">
											<span class="orth">ula</span>
											<span class="romanization">['ul lag]</span>
											<br/>
											<span class="definition">a generic term for corvee labor.</span>
										</p>
										<p class="term">
											<span class="orth">umdze</span>
											<span class="romanization">[dbu mdzad]</span>
											<br/>

											<span class="definition">chant/prayer leader in a monastery.</span>
										</p>
										<p class="term">
											<span class="orth">upong</span>
											<span class="romanization">[tib. dbul phongs]</span>
											<br/>
											<span class="definition">the communist word for the poor class.</span>
										</p>
										<p class="term">
											<span class="orth">uy&#xF6;n</span>
											<span class="romanization">[tib. u yon, ch. wei yuan]</span>
											<br/>

											<span class="definition">member of a committee or varying levels</span>
										</p>
									</div>
									<div class="alpha" id="w">
										<span class="letter">W</span>
										<p class="term">
											<span class="orth">Women's Federation</span>
											<span class="romanization">[tib. p&#xFC;me nyamdrel lhentsog (bud med mnyam 'brel lhan tshogs); ch. fu n&#xFC; lian he hui]</span>
											<br/>

											<span class="definition">the women's organization that deals with women's affairs and family matters including family planning.</span>
										</p>
										<p class="term">
											<span class="orth">work point grain</span>
											<span class="romanization">[tib. gandru (skar 'bru); ch. gong fen liang]</span>
											<br/>
											<span class="definition">grain paid by a production team/ brigade according to the number of work points that one accumulated through work performance.</span>
										</p>
										<p class="term">
											<span class="orth">work point money</span>
											<span class="romanization">[tib. gang&#xFC; (skar dngul); ch. gong fen qian]</span>
											<br/>

											<span class="definition">money paid by a production team/ brigade according to the number of work points that one accumulated through work performance.</span>
										</p>
										<p class="term">
											<span class="orth">work points</span>
											<span class="romanization">[tib. skar ma]</span>
											<br/>
											<span class="definition">The accounting system in collective units like communes in which work was rated by difficulty and workers were assigned &quot;points&quot; for the work they did daily.</span>
										</p>

										<p class="term">
											<span class="orth">work team</span>
											<span class="romanization">[tib. las don ru khag; ch. gongzuo zu]</span>
											<br/>
											<span class="definition">A group of officials from one or more offices who are sent to an area to investigate a problem or launch a new campaign.</span>
										</p>
									</div>
									<div class="alpha" id="x">
										<span class="letter">X</span>
										<p class="term">
											<span class="orth">xian</span>
											<span class="romanization">[ch.] [tib. dzong (rdzong)]</span>
											<br/>

											<span class="definition">A rural administrative unit in post-1959 Tibet that is comprised of several xiang. It is normally translated as a county and is roughly equivalent to a dzong in the traditional society.</span>
										</p>
										<p class="term">
											<span class="orth">xiang</span>
											<span class="romanization">[ch.]</span>
											<br/>
											<span class="definition">an administrative unit that contains several villages. It is sometimes called a rural township in the literature on China. Several xiang are part of a xian (county).</span>
										</p>
										<p class="term">
											<span class="orth">xiang zhang</span>
											<span class="romanization">[ch.]</span>
											<br/>

											<span class="definition">the head of a xiang.</span>
										</p>
										<p class="term">
											<span class="orth">xian zhang</span>
											<span class="romanization">[ch.]</span>
											<br/>
											<span class="definition">the head of a xian.</span>
										</p>
									</div>

									<div class="alpha" id="y">
										<span class="letter">Y</span>
										<p class="term">
											<span class="orth">Yabshi</span>
											<span class="romanization">[tib. yab gzhis]</span>
											<br/>
											<span class="definition">1. the title given to the family of a Dalai Lama. 2. when used by itself, e.g., Yabshi's house, it refers to the family of the current (14th) Dalai Lama.</span>
										</p>
										<p class="term">
											<span class="orth">Yadong</span>
											<span class="romanization"/>
											<br/>

											<span class="definition">the Chinese name for the Tibetan town called Tromo located on the Sikkim border. It was the location where the 14th Dalai Lama stayed for several months in 1950-51 after fleeing from Lhasa.</span>
										</p>
										<p class="term">
											<span class="orth">yarsor</span>
											<span class="romanization">[tib. ya sor]</span>
											<br/>
											<span class="definition">The title of the two officials who acted as generals of the ancient army during the ritual military activities that were performed during the time of the M&#xF6;nlam Prayer Festival.</span>
										</p>
										<p class="term">
											<span class="orth">yigtsag</span>
											<span class="romanization">[tib. yig tshags]</span>
											<br/>

											<span class="definition">1. An official in charge of documents, records. 2. the officials in charge of the documents and records of the Tibetan Assembly. This included taking notes dictated by the assembly leaders and writing the assembly's documents.</span>
										</p>
										<p class="term">
											<span class="orth">Yigtsang</span>
											<span class="romanization">[tib. yig tshang] [tib. yigtsang (yig tshang)]</span>
											<br/>
											<span class="definition">[Ecclesiastic Office] the highest office dealing with monastic and religious affairs in the traditional Tibetan government. It was headed by 4 fourth rank monk officials called trunyichemmo. The seniotn trunyichemmo was called Ta Lama.</span>
										</p>
										<p class="term">
											<span class="orth">ying</span>
											<span class="romanization">[tib. dbyings]</span>
											<br/>

											<span class="definition">infantry battalion in PLA. Three battalions were in one tuan.</span>
										</p>
										<p class="term">
											<span class="orth">y&#xF6;</span>
											<span class="romanization">[tib. yos]</span>
											<br/>
											<span class="definition">roasted barley kernels that have popped like pop corn. Tsampa is made by grinding this, and y&#xF6; is also eaten as a snack.</span>
										</p>

										<p class="term">
											<span class="orth">Yongdzin</span>
											<span class="romanization">[tib. yongs 'dzin ]</span>
											<br/>
											<span class="definition">A tutor of a hiigh lama or Dalai Lama.</span>
										</p>
										<p class="term">
											<span class="orth">yuan</span>
											<span class="romanization">[ch.]</span>
											<br/>

											<span class="definition">China's basic currency unit. It ahd an exchange rate equal to $8.2 USD in 2004. A yuan is divided into 100 fen and 10 jiao. It is also known as renminbi or &quot;people's currency.&quot;</span>
										</p>
										<p class="term">
											<span class="orth">Y&#xFC;gye Tashi Delek</span>
											<span class="romanization">[tib. g.yul rgyal bkra shis bde legs ]</span>
											<br/>
											<span class="definition">The Tibetan Government's &quot;Victory Congratulations&quot; mission sent in 1946 to congratulate the allies after their victory in World War II.</span>
										</p>
									</div>
									<div class="alpha" id="z">
										<span class="letter">Z</span>
										<p class="term">
											<span class="orth">zhongyang</span>
											<span class="romanization">[ch.]</span>
											<br/>
											<span class="definition">1. the central committee of the CCP; 2. the central government of China.</span>
										</p>
										<p class="term">
											<span class="orth">zhuren</span>
											<span class="romanization"/>
											<br/>

											<span class="definition">director of a unit or office</span>
										</p>
										<p class="term">
											<span class="orth">zi</span>
											<span class="romanization">[tib. gzi]</span>
											<br/>
											<span class="definition">a valuable agate-like stone that has designs (usually black and white) that are called &quot;eyes.&quot;</span>
										</p>
									</div>

									<div class="alpha" id="uu">
										<span class="letter">&#xDC;</span>
										<p class="term">
											<span class="orth">&#xFC;-tsang</span>
											<span class="romanization">[tib. dbus gtsang ]</span>
											<br/>
											<span class="definition">the two main Central Tibet areas of &#xFC; and tsang (the main cities of which are respectively Lhasa and Shigatse).</span>
										</p>
									</div>

<!--end glossary: -->								</div>
<div style="display: block;" id="credits" class="tab_content">
	<h2>Acknowledgments and Special Thanks</h2>
		<!--<img src="/static/tohap/images/goldstein-intent.jpg" alt="Professor Goldstein conducting interviews in a tent." height="217" width="300" align="right"/>
		<div>Professor Goldstein conducting interviews in a tent.</div>
	
	<p>Melvyn C. Goldstein,<em> Editor-in-Chief</em><br/>
Linda Cantara and Ke Liao, <em>Technical Editors</em><br/>
Tsewang Namgyal Shelling, <em>Tibetan Editor</em></p>-->	
<p><img src="/static/tohap/images/goldstein-intent.jpg" alt="Professor Goldstein conducting interviews in a tent." height="217" width="300" align="right" />Melvyn C. Goldstein,<em> Editor-in-Chief</em><br/>
Linda Cantara and Ke Liao, <em>Technical Editors</em><br/>
Tsewang Namgyal Shelling, <em>Tibetan Editor</em></p>

	<h2>Library of Congress Staff</h2>
	<p>
		<strong>Technical functionality and programming</strong> was performed by Morgan Cundiff, Kevin Ford, Nathan Trail, Clay Redding, and Rashmi Singhal of the Network Development and MARC Standards Office.</p>
	<p>
		<strong>Web site design and user interface</strong> was created by Elizabeth F. Miller of the Network Development and   MARC Standards Office based on user-centered design principles and using the Library of Congress' Standard Design.</p>
	<p>
		<em>For information, please contact:</em>
	</p>
	<p>Melvyn C. Goldstein<br/>
  John Reynolds Harkness Professor in Anthropology<br/>
  Co-Director, Center for Research on Tibet<br/>
  Case Western Reserve University<br/>
  Cleveland, Ohio 44106<br/>
  Ph. 216 368-2265, Fx. 216 368-5334<br/>
  Center for Research on Tibet: <a href="http://www.cwru.edu/affil/tibet/">http://www.cwru.edu/affil/tibet/</a><img alt="External Link" src="http://www.loc.gov/images/icon-ext2.gif" height="10" width="8" /></p>						
  <!-- end credits --></div>
							</div>
							<!-- end class:tab_container -->
						</div>
						<!-- end #ds-maincontent -->
					</div>
					<!-- end #container -->

					{ssk:feedback-link(false())}                       
                        {ssk:footer()/div}
					<!-- end dsresults -->
				<!--</div>-->
				<!-- id="ds-body"> -->
			</div>
			<!-- end id:ds-container -->
		</div>
	</body>
</html>

 
(:let $new-params := lp:param-replace-or-insert($lp:CUR-PARAMS, "collection", mime:safe-mime("/lscoll/tohap/") ) :)
                                   
return
        (
            xdmp:set-response-content-type("text/html; charset=utf-8"), 
            xdmp:add-response-header("X-LOC-MLNode", resp:private-loc-mlnode()),
            xdmp:add-response-header("Cache-Control", resp:cache-control($duration)), 
            xdmp:add-response-header("Expires", resp:expires($duration)),
            $doctype, 
            $html
        )
  