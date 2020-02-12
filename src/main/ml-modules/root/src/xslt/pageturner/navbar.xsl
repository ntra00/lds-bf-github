<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" exclude-result-prefixes="mets mods xlink tei" xpath-default-namespace="local" default-validation="strip" input-type-annotations="unspecified" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mets="http://www.loc.gov/METS/" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns="http://www.w3.org/1999/xhtml">
	<!--input is local  menu from navigation output is xhtml-->
	<!--this is being used to chunk out a div of the right nav
	called by mods-metadata for lcwa and other sets-->
	<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>

	<!-- <xsl:include href="utils.xsl"/> -->
	<!-- not used:-->
	<xsl:variable name="base-url">
		<xsl:value-of select="concat('http://', $hostname,'/nlc/detail.xqy?')" disable-output-escaping="no"/>
	</xsl:variable>
	<xsl:template match="/" as="item()*">
		<div id="sidebar">

			<!-- use this to link to the collection/collections for the digital item -->
			<div id="collection">
				<h2 class="hidden">Related Resources</h2>
				<h3>Collection</h3>
				<ul class="std">
					<li>
						<a href="#">Such and Such Collection</a>
					</li>
				</ul>
			</div>
			<!-- end id:#sidebar #collection -->

			<!-- use this to link to browses for related subjects, names and LC classes -->
			<div id="related">
				<h3>Browse More Like This</h3>

				<div id="browse-subjects">
					<h4>Subjects</h4>
					<ul class="std">
						<li>
							<a href="http://loccatalog.loc.gov/nlc/browse.xqy?dtitle=First%20in%2C%20last%20out%20%3A%20stories%20by%20the%20Wild%20Weasels%20&amp;q=weasels&amp;qname=keyword&amp;uri=loc.natlib.lcdb.13990048&amp;index=4&amp;browse-order=ascending&amp;bq=Electronic%20warfare%20aircraft.&amp;browse=subject">Electronic warfare aircraft.</a>
						</li>
						<li>
							<a href="http://loccatalog.loc.gov/nlc/browse.xqy?dtitle=First%20in%2C%20last%20out%20%3A%20stories%20by%20the%20Wild%20Weasels%20&amp;q=weasels&amp;qname=keyword&amp;uri=loc.natlib.lcdb.13990048&amp;index=4&amp;browse-order=ascending&amp;bq=Vietnam%20War%2C%201961-1975--Aerial%20operations%2C%20American.&amp;browse=subject">Vietnam War, 1961-1975--Aerial operations, American.</a>
						</li>
						<li>
							<a href="http://loccatalog.loc.gov/nlc/browse.xqy?dtitle=First%20in%2C%20last%20out%20%3A%20stories%20by%20the%20Wild%20Weasels%20&amp;q=weasels&amp;qname=keyword&amp;uri=loc.natlib.lcdb.13990048&amp;index=4&amp;browse-order=ascending&amp;bq=Vietnam%20War%2C%201961-1975--Personal%20narratives%2C%20American.&amp;browse=subject">Vietnam War, 1961-1975--Personal narratives, American.</a>
						</li>
					</ul>
				</div>

				<div id="browse-names">
					<h4>Names</h4>
					<ul class="std">
						<li>
							<a href="http://loccatalog.loc.gov/nlc/browse.xqy?dtitle=First%20in%2C%20last%20out%20%3A%20stories%20by%20the%20Wild%20Weasels%20&amp;q=weasels&amp;qname=keyword&amp;uri=loc.natlib.lcdb.13990048&amp;index=4&amp;browse-order=ascending&amp;bq=Vietnam%20War%2C%201961-1975--Personal%20narratives%2C%20American.&amp;browse=subject">Smith, Elaine Martha, 1910-</a>
						</li>
					</ul>
				</div>

				<div id="browse-class">
					<h4>LC Classifications</h4>
					<ul class="std">

						<li>
							<a href="http://loccatalog.loc.gov/nlc/browse.xqy?dtitle=First%20in%2C%20last%20out%20%3A%20stories%20by%20the%20Wild%20Weasels%20&amp;q=weasels&amp;qname=keyword&amp;uri=loc.natlib.lcdb.13990048&amp;index=4&amp;browse-order=ascending&amp;bq=UG1242.E43&amp;browse=class">UG1242.E43</a>
						</li>
					</ul>
				</div>
			</div>
			<!-- end id:#sidebar #collection -->

			<div id="not-online">
				<h3 class="hidden">Not Online</h3>
				<p>This [item] [collection] [etc] is not available online. For more information on accessing this material: <a href="http://www.loc.gov/rr/askalib/">Ask a Librarian</a></p>
			</div>
			<div id="duplication">
				<h3>Obtain Copies</h3>
				<ul class="std">
					<li>
						<a href="#">Duplication Services</a>
					</li>
				</ul>
			</div>
			<div id="feedback">
				<h3>Comments</h3>
				<ul class="std">
					<li>
						<a href="#">Send us your feedback/suggestions</a>
					</li>
				</ul>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="/old" as="item()*">
		<div id="ds-bibviews">
			<xsl:apply-templates select="menu/whole/part"/>

			<!-- some items have no left nav -->


			<xsl:if test=" $metsprofile='bibRecord'">
				<xsl:choose>
					<xsl:when test="$metsprofile='bibRecord' and menu/whole/items">
						<!--single item track -->
						<xsl:apply-templates select="menu/whole/items"/>
					</xsl:when>
					<xsl:when test="$behavior='lyrics' and not(//@id=$itemID)">
						<!-- lyrics for items like sheet music have no track (lower level) segments; lyrics is the whole thing) -->
						<xsl:apply-templates select="menu/whole"/>
					</xsl:when>
					<xsl:when test="$behavior='lyrics'">
						<!--single item track -->
						<xsl:apply-templates select="menu/tracks/item[@id=$itemID]"/>
					</xsl:when>

					<xsl:when test="$behavior='item'">
						<!--single item track  below main menu?-->
						<xsl:apply-templates select="menu/tracks/item[@id=$itemID]"/>
					</xsl:when>
					<!-- full, brief, transcript etc-->
					<xsl:when test="$behavior!='track'">
					</xsl:when>
					<xsl:otherwise>
						<!-- item views, show item level-->
						<xsl:apply-templates select="menu/items"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>

			<!-- page level links go here -->
			<xsl:if test="//pages/page[position()=$pageNum]/href">
				<h2>Page-level related items:</h2>
				<ul>
					<xsl:apply-templates select="//pages/page[position()=$pageNum]/href">
						<xsl:sort select="text()" data-type="text" order="ascending"/>
					</xsl:apply-templates>
				</ul>
			</xsl:if>
			<!--end ds-bibviews : -->
		</div>
	</xsl:template>

	<xsl:template match="whole" as="item()*">
		<xsl:apply-templates select="sectionTitle | part"/>
	</xsl:template>
	<xsl:template match="part" as="item()*">
		<xsl:apply-templates select="sectionTitle | select | partTitle"/>
		<xsl:if test="*[not(local-name()='sectionTitle')][not(local-name()='select')][not(local-name()='partTitle')][not(local-name()='content')][not(contains(text(), 'back'))][not(local-name()='comment')]">
			<ul>
				<xsl:apply-templates select="*[not(local-name()='sectionTitle')][not(local-name()='select')][not(local-name()='partTitle')][not(local-name()='content')][not(contains(text(), 'back'))][not(local-name()='comment')]"/>
			</ul>
		</xsl:if>
		<xsl:apply-templates select="comment"/>
	</xsl:template>

	<xsl:template match="menu/items" as="item()*">
		<xsl:apply-templates select="item[@id=$itemID]"/>
	</xsl:template>

	<xsl:template match="menu/whole/items" as="item()*">
		<xsl:apply-templates select="item//href[@behavior='item']"/>
	</xsl:template>

	<xsl:template match="sectionTitle" as="item()*">
		<h2>
			<xsl:if test="contains(text(),'View')">
				<xsl:attribute name="class">top</xsl:attribute>
			</xsl:if>
			<xsl:value-of select="." disable-output-escaping="no"/>
		</h2>
	</xsl:template>


	<xsl:template match="item | subItem" as="item()*">
		<xsl:apply-templates select="*|text()"/>
	</xsl:template>

	<xsl:template name="leftnav" as="item()*">
		<xsl:if test="/pageTurner/menu/whole/part/*[not(local-name()='content')] or $profile='bibRecord'">
			<!-- some items have no left nav -->
			<div id="border">
				<xsl:choose>
					<xsl:when test="$profile='bibRecord' and /pageTurner/menu/whole/items">
						<!--single item track -->
						<xsl:apply-templates select="/pageTurner/menu/whole/items"/>
					</xsl:when>
					<xsl:when test="$behavior='lyrics' and not(//@id=$ID)">
						<!-- lyrics for items like sheet music have no track (lower level) segments; lyrics is the whole thing) -->
						<xsl:apply-templates select="/pageTurner/menu/whole"/>
					</xsl:when>
					<xsl:when test="$behavior='lyrics'">
						<!--single item track -->
						<xsl:apply-templates select="/pageTurner/menu/tracks/item[@id=$ID]"/>
					</xsl:when>
					<xsl:when test="$behavior='item'">
						<!--single item track -->
						<xsl:apply-templates select="/pageTurner/menu/tracks/item[@id=$ID]"/>
					</xsl:when>
					<!-- full, brief, transcript etc-->
					<xsl:when test="$behavior!='track'">
						<xsl:apply-templates select="/pageTurner/menu/whole"/>
					</xsl:when>
					<xsl:otherwise>
						<!-- track views, show item level-->
						<!--<xsl:variable name="trackNum">ID=<xsl:value-of select="$ID"/></xsl:variable>-->
						<!--<xsl:apply-templates select="/pageTurner/menu/items/part/href[@parameters=$trackNum]"/>-->
						<xsl:apply-templates select="/pageTurner/menu/items"/>
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</xsl:if>
		<!--border-->
		<!-- page level links go here -->
		<xsl:if test="//pages/page[position()=$pageNum]/href">
			<div id="border_related">
				<h3>Page-level related items:</h3>
				<ul>
					<xsl:apply-templates select="//pages/page[position()=$pageNum]/href">
						<xsl:sort select="text()" data-type="text" order="ascending"/>
					</xsl:apply-templates>
				</ul>
			</div>
		</xsl:if>

		<span id="skip_menu"></span>
	</xsl:template>
	<xsl:template match="select" as="item()*">
		<form name="select-part" method="get" action="script-by-corey" enctype="application/x-www-form-urlencoded">
			<xsl:variable name="optionText">
				<xsl:choose>
					<xsl:when test="$metsprofile='simplePhoto' or $metsprofile='photoObject'">select a version</xsl:when>
					<xsl:otherwise>select a part</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<select style="width: 155px;" name="select" onchange="window.location.href=this.options[this.selectedIndex].value">
				<option>
					<xsl:value-of select="$optionText" disable-output-escaping="no"/>
				</option>
				<xsl:for-each select="href">
					<option>
						<xsl:attribute name="value">
							<xsl:value-of select="concat(normalize-space(@behavior),'.html?',@parameters)" disable-output-escaping="no"/>
						</xsl:attribute>
						<xsl:if test="substring-after(@parameters,'=')=$section">
							<xsl:attribute name="selected">selected</xsl:attribute>
						</xsl:if>
						<xsl:value-of select="." disable-output-escaping="no"/>
					</option>
				</xsl:for-each>
			</select>
		</form>
	</xsl:template>
	<xsl:template match="comment" as="item()*">
		<p>
			<xsl:copy-of select="*|text()" copy-namespaces="yes"/>
		</p>
	</xsl:template>

	<xsl:template match="partTitle" as="item()*">
		<h4>
			<xsl:copy-of select="*|text()" copy-namespaces="yes"/>
		</h4>
	</xsl:template>
	<xsl:template match="line" as="item()*">
		<xsl:copy-of select="." copy-namespaces="yes"/>
	</xsl:template>

	<xsl:template match="href" mode="deeplinks" as="item()*">
		<a href="{@file}" rel="no-follow">
			<xsl:value-of select="title | text()" disable-output-escaping="no"/>
		</a>
	</xsl:template>
	<!--top level:  @behavior can be default, contents, pageturner, enlarge, contactsheet
		  tem level:  @behavior item = recordedevent track=recordedevent, compactdisc, newcompactdisc
		  lyrics, transcript are item level as well
		@file means there are lots of params or it's out of nlc
		can have @behavior and @file
		
		if $behavior = @behavior then your class should be "in view" (gray)
		copy rel (for nofollow)
		-->
  <!--  not sure if this was used; conflicts with mods-metadata match for "href": 
		renamed from match="href" to match=junk-->
	<xsl:template match="junk" as="item()*">		
		<xsl:choose>
			<xsl:when test="@behavior='default'">
				<xsl:variable name="class">
					<xsl:choose>
						<xsl:when test="$behavior='default'">view</xsl:when>
						<xsl:otherwise>on</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<li class="{$class}">
					<xsl:choose>
						<xsl:when test="$class='view'">
							<xsl:apply-templates select="title |text()"/>
						</xsl:when>
						<xsl:otherwise>
							<a href="{concat($base-url,@parameters)}">
								<xsl:apply-templates select="title |text()"/>
								<xsl:apply-templates select="@icon"/>
							</a>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:apply-templates select="comment"/>
				</li>
			</xsl:when>
			<xsl:when test="@behavior='pageturner'">
				<xsl:variable name="class">
					<xsl:choose>
						<xsl:when test="$behavior='pageturner' and contains(@parameters,concat('section=',$section))">view</xsl:when>
						<xsl:when test="$behavior='pageturner' and exists($section)">on</xsl:when>
						<xsl:when test="$behavior='pageturner'">view</xsl:when>
						<xsl:otherwise>on</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<li class="{$class}">
					<xsl:choose>
						<xsl:when test="$class='view'">
							<xsl:apply-templates select="title |text()"/>
						</xsl:when>
						<xsl:otherwise>
							<a href="{concat($base-url,@parameters)}">
								<xsl:apply-templates select="title |text()"/>
								<xsl:apply-templates select="@icon"/>
							</a>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:apply-templates select="comment"/>
				</li>
			</xsl:when>
			<xsl:when test="@behavior='contactsheet'">
				<xsl:variable name="class">
					<xsl:choose>
						<xsl:when test="$behavior='contactsheet'">view</xsl:when>
						<xsl:otherwise>on</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<li class="{$class}">
					<xsl:choose>
						<xsl:when test="$class='view'">
							<xsl:apply-templates select="title |text()"/>
						</xsl:when>
						<xsl:otherwise>
							<a href="{concat($base-url,@parameters)}">
								<xsl:apply-templates select="title |text()"/>
								<xsl:apply-templates select="@icon"/>
							</a>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:apply-templates select="comment"/>
				</li>
			</xsl:when>

			<xsl:when test="@behavior='item'">
				<xsl:variable name="class">
					<xsl:choose>
						<xsl:when test="$behavior='item'  and contains(@parameters,concat('itemID=',$itemID))">view</xsl:when>
						<xsl:otherwise>on</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<li class="{$class}">
					<!--main link:-->
					<xsl:choose>
						<xsl:when test="$class='view'">
							<!--	gray main, show subparts as links-->
							<xsl:apply-templates select="title |text()"/>
							<xsl:apply-templates select="comment"/>
							<xsl:for-each select="/menu/items/item[@id=$itemID]/part/href[@file]">
								<!-- show the subpart of this item indented below it-->
								<br/>
								<xsl:text disable-output-escaping="no">   </xsl:text>
								<a href="{@file}">
									<xsl:apply-templates select="title |text()"/>
								</a>
								<xsl:apply-templates select="@icon"/>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="@icon"/>
							<!--link to main item behavior-->
							<!--<a href="{concat(@file,@parameters)}">-->
							<a href="{concat($base-url,@parameters)}">
								<xsl:apply-templates select="title |text()"/>
								<xsl:apply-templates select="@icon"/>
							</a>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:apply-templates select="comment "/>
					<xsl:copy-of select="." copy-namespaces="yes"/>
				</li>
			</xsl:when>

			<!--toc view:-->
			<!--<xsl:when test="$behavior=@behavior and  ( not(contains(@parameters,$section))  )">-->
			<xsl:when test="$behavior=@behavior  and (not(contains(@parameters,$section)) or  number(substring-after(@parameters,'page='))!=$pageNum)">
				<!-- multiple versions photoOBject, pageturner -->
				<xsl:variable name="class">
					<xsl:choose>
						<xsl:when test="@behavior='pageturner' and number(substring-after(@parameters,'page='))!=$pageNum">on</xsl:when>
						<xsl:when test="@behavior='item' and not(contains(@parameters, concat('itemID=',$itemID)))">on</xsl:when>
						<xsl:otherwise>view</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<li class="{$class}">
					<xsl:variable name="parameters">
						<xsl:if test="@parameters">?<xsl:value-of select="@parameters" disable-output-escaping="no"/></xsl:if>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="$class='view'">
							<xsl:apply-templates select="title |text()"/>
						</xsl:when>
						<xsl:otherwise>
							<a href="{normalize-space(@behavior)}.html{$parameters}">
								<xsl:apply-templates select="title |text()"/>
							</a>
						</xsl:otherwise>
					</xsl:choose>

					<xsl:if test="@icon">
						<img src="{@icon}" alt=""/>
					</xsl:if>
					<xsl:apply-templates select="comment |part"/>
					<!--this is teh main listing for recevent<xsl:copy-of select="."/>	-->
				</li>
			</xsl:when>


			<xsl:when test="@behavior='lyricspdf'">
				<li class="on">
					<a href="javascript:document.pdf.submit()">
						<xsl:value-of select="." disable-output-escaping="no"/>
					</a>
					<form name="pdf" method="get" action="lyrics.pdf" enctype="application/x-www-form-urlencoded">
						<input type="hidden" name="file" value="{/pageTurner/pages/lyrics/text/@href}"/>
					</form>
					<xsl:apply-templates select="comment"/>
				</li>
			</xsl:when>
			<xsl:when test="@behavior='lyrics'">
				<li class="on">
					<xsl:variable name="parameters">
						<xsl:if test="@parameters">?<xsl:value-of select="@parameters" disable-output-escaping="no"/></xsl:if>
					</xsl:variable>
					<a href="{normalize-space(@behavior)}.html{$parameters}">
						<xsl:apply-templates select="title |text()"/>
					</a>
					<xsl:apply-templates select="comment"/>
				</li>
			</xsl:when>

			<xsl:when test="@file and $behavior='track'">
				<li class="on">
					<!-- play item -->
					<a href="{@file}">
						<xsl:apply-templates select="title |text()"/>
					</a>
					<xsl:if test="@icon">
						<img src="{@icon}" alt=""/>
					</xsl:if>
					<xsl:apply-templates select="comment |part"/>
				</li>
			</xsl:when>
			<xsl:when test="@behavior='track' and $behavior='lyrics'">
				<!-- on lyrics, show the track link -->
				<li class="on">
					<xsl:variable name="parameters">
						<xsl:if test="@parameters">?<xsl:value-of select="@parameters" disable-output-escaping="no"/></xsl:if>
					</xsl:variable>

					<a href="{normalize-space(@behavior)}.html{$parameters}">Description</a>
					<xsl:if test="@icon">
						<img src="{@icon}" alt=""/>
					</xsl:if>
					<xsl:apply-templates select="comment | part"/>
				</li>
				<xsl:apply-templates select="href"/>
			</xsl:when>

			<xsl:when test="@file">
				<!-- not track tei items????  -->
				<xsl:variable name="url">
					<xsl:choose>
						<xsl:when test="@parameters">
							<xsl:value-of select="concat(@file,'&amp;', @parameters)" disable-output-escaping="no"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@file" disable-output-escaping="no"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<li class="on">
					<a href="{$url}">
						<xsl:copy-of select="@rel|@target" copy-namespaces="yes"/>
						<xsl:apply-templates select="title |text()"/>
					</a>
					<xsl:if test="@icon">
						<img src="{@icon}" alt=""/>
					</xsl:if>
					<xsl:apply-templates select="comment"/>
				</li>
			</xsl:when>
			<xsl:otherwise>
				<!-- default view -->
				<li class="on">
					<xsl:variable name="parameters">
						<xsl:if test="@parameters">?<xsl:value-of select="@parameters" disable-output-escaping="no"/></xsl:if>
					</xsl:variable>
					<a href="{normalize-space(@behavior)}.html{$parameters}">
						<xsl:copy-of select="@rel|@target" copy-namespaces="yes"/>
						<!--		<xsl:value-of select="concat(title ,  string(.))"/> -->
						<xsl:apply-templates select="title |text()"/>
					</a>
					<xsl:if test="@icon">
						<img src="{@icon}" alt=""/>
					</xsl:if>
					<xsl:apply-templates select="comment | part"/>
				</li>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="text()" as="item()*">
		<xsl:value-of select="." disable-output-escaping="no"/>
	</xsl:template>
	<xsl:template match="@icon" as="item()*">
		<img src="{.}" alt=""/>
	</xsl:template>
</xsl:stylesheet>

