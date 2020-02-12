<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" exclude-result-prefixes="tei xlink term l"
	xpath-default-namespace="http://www.w3.org/1999/xhtml" default-validation="strip"
	input-type-annotations="unspecified" extension-element-prefixes="xdmp"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns="http://www.w3.org/1999/xhtml" xmlns:l="local" xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:term="tohap.terms" xmlns:xdmp="http://marklogic.com/xdmp">
	<!--xmlns:tei="http://lcweb2.loc.gov/natlib/schemas/teixlite.dtd"-->


	<xsl:output method="xml" encoding="UTF-8" indent="no"/>


	<!--<xsl:variable name="glossary" select="document('file:///home/ntra/Downloads/tohapGlossary.xml')/terms"/>-->
	<!-- <xsl:variable name="glossary" select="document('/config/tohapGlossary.xml')/term:terms"/> -->
	<!--<xsl:variable name="glossary" select="doc('/config/tohapGlossary.xml')/term:terms"/>-->
	<xsl:variable name="gloss" select="document('/config/tohapGlossary.xml')/term:terms/term:div"/>

	<!-- template to render TEI as HTML  (cd booklets)
		
	-->
	<!-- <xsl:template match="/x/l:tei"><h1>hello world<xsl:copy-of select="."/></h1>	</xsl:template> -->
	<xsl:template match="/" as="item()*">
		<div id="allparts">
			<xsl:apply-templates select="child::node()"/>
		</div>
	</xsl:template>
	<xsl:template match="l:part" as="item()*">
		<div class="tohap" id="{l:meta/l:key/string()}">
			<xsl:apply-templates select="tei:TEI"/>
		</div>
	</xsl:template>
	<xsl:template match="tei:TEI" as="item()*">
		<xsl:apply-templates select="tei:text"/>
	</xsl:template>
	<xsl:template match="tei:text" as="item()*">

		<xsl:apply-templates select="tei:front"/>
		<xsl:apply-templates select="tei:body"/>
		<xsl:apply-templates select="tei:back"/>
		<xsl:if test="descendant-or-self::tei:note[@place='end']">
			<hr/>
			<p>
				<a href="#content" class="noline">
					<img src="/static/natlibcat/images/arrow_up.gif" alt="Back to top" height="9"
						width="9"/>
					<!-- <img src="/marklogic/static/img/arrow_up.gif" alt="top" height="9" width="9"/> -->
				</a>
				<a href="#content">Back to top</a>
			</p>
			<!--<a href="#content"><img src="/marklogic/static/img/arrow_up.gif"  alt="Back to top"  height="9" width="9"/></a>-->
			<br/>
			<h3 id="footnotes">FOOTNOTES:</h3>

			<xsl:for-each select="descendant-or-self::tei:note[@place='end']">
				<p>
					<a class="noline" name="{number(@n)}">
						<xsl:value-of select="number(@n)" disable-output-escaping="no"/>
					</a>
					<xsl:text disable-output-escaping="no"> </xsl:text>
					<xsl:apply-templates select="child::node()"/>
					<a href="javascript:history.back()">Back to transcript</a>
				</p>
			</xsl:for-each>
		</xsl:if>
		<p>
			<a href="#content" class="noline">
				<!-- <img src="/marklogic/static/img/arrow_up.gif" alt="Back to top" height="9" width="9"/> -->
				<img src="/static/natlibcat/images/arrow_up.gif" alt="Back to top" height="9"
					width="9"/>
			</a>
			<a href="#content">Back to top</a>
		</p>
	</xsl:template>

	<xsl:template match="tei:body" as="item()*">
		<xsl:if test="//tei:div[@type!=''][@n!='']">
			<ul>
				<xsl:for-each select="//tei:div[@type!=''][@n!='']">
					<li>
						<a href="{concat('#',@type,@n)}">
							<xsl:value-of select="concat(@type, ' ', @n,'. ', head)"
								disable-output-escaping="no"/>
						</a>
					</li>
				</xsl:for-each>
				<li>
					<a href="#footnotes">FOOTNOTES</a>
				</li>
			</ul>
		</xsl:if>

		<xsl:apply-templates select="child::node()"/>
	</xsl:template>
	<xsl:template match="tei:lb" as="item()*">
		<br/>
	</xsl:template>
	<xsl:template match="@*" as="item()*">
		<xsl:copy-of select="." copy-namespaces="yes"/>
	</xsl:template>
	<xsl:template match="@xml:id" as="item()*">
		<xsl:attribute name="id">
			<xsl:value-of select="." disable-output-escaping="no"/>
		</xsl:attribute>
	</xsl:template>
	<xsl:template match="@TEIform" as="item()*"/>
	<xsl:template match="tei:lg" as="item()*">
		<dl>
			<xsl:for-each select="tei:l">
				<dt>
					<xsl:apply-templates select="child::node()"/>
				</dt>
			</xsl:for-each>
		</dl>
	</xsl:template>
	<xsl:template match="tei:front" as="item()*">
		<xsl:for-each select="tei:div[@type='abstract']">

				<xsl:apply-templates select="child::node()"/>

			<xsl:for-each select="tei:div[@type!='abstract' or not(@type)]">
				<xsl:apply-templates select="child::node()"/>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="tei:head" as="item()*">
		<xsl:if test="../tei:div[@type!='body']">
			<div align="left">
				<h3>
					<xsl:value-of select="." disable-output-escaping="no"/>
				</h3>
			</div>
		</xsl:if>
	</xsl:template>
	<xsl:template match="tei:term" as="item()*">
		<xsl:variable name="lowerOrth" select="lower-case(.)"/>
		<!--<xsl:variable name="termNode" select="$glossary//term:entry[@lc_orth=$lowerOrth]"/>-->
		<xsl:variable name="termNode" select="$gloss/term:entry[term:form/term:lc_orth=$lowerOrth]"/>
		<!-- per morgan, if 2 defs, use second (1st is "see" ref) -->
		<!-- per morgan, if 2 prons, use first  -->
		<xsl:variable name="def">
			<xsl:choose>
				<xsl:when test="count($termNode//term:def) &gt; 1">
					<xsl:value-of select="$termNode/term:def[2]"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$termNode/term:def[1]"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="pron" select="$termNode/term:form/term:pron[1]"/>

		<xsl:variable name="tip">
			<xsl:if test="$def!=''">Definition: <xsl:value-of select="$def[1]"/>
				<xsl:if test="substring($def[1], string-length($def[1] ))!='.'">.</xsl:if>
			</xsl:if>
			<xsl:if test="$pron!=''"> Romanization: <xsl:value-of select="$pron[1]"/>
				<xsl:if test="substring($pron[1], string-length($pron[1] ))!='.'">.</xsl:if>
			</xsl:if>
		</xsl:variable>
		<!-- old: -->
		<a class="info" title="{$tip}">
			<span class="term-highlight">
				<xsl:value-of select="." disable-output-escaping="no"/>
			</span>
			<!--<span class="def-box" style="display:none">
				<xsl:value-of select="$def" disable-output-escaping="no"/>
				<br/>
				<xsl:if test="$pron!=''">
					<span class="pron">
						<strong>Romanization:</strong>
						<xsl:value-of select="$pron" disable-output-escaping="no"/>
					</span>
				</xsl:if>
			</span>-->
		</a>
		<!-- <xsl:variable name="defpron"><xsl:value-of select="$def" disable-output-escaping="no"/><br/>Romanization:<xsl:value-of select="$pron" disable-output-escaping="no"/></xsl:variable>
		<a class="info" href="#" title="{$defpron}"><span class="term-highlight"><xsl:value-of select="." disable-output-escaping="no"/></span>
		<span class="def-box" style="display:none"><xsl:value-of select="$def" disable-output-escaping="no"/><br/>
		<xsl:if test="$pron!=''"><span class="pron"><strong>Romanization:</strong><xsl:value-of select="$pron" disable-output-escaping="no"/></span>
		</xsl:if></span></a>  -->
		<!-- new but no css: -->
		<!-- <span class="glossary-tei" style="text-decoration: underline">		
			<span class="def-label">
				<xsl:value-of select="."/>
			</span>
			<span class="def-box" style="display:none">
				<xsl:value-of select="$def"/>
				<br/>
				<xsl:if test="$pron!=''">
					<span class="pron">
						<strong>Romanization:</strong>
						<xsl:value-of select="$pron"/>
					</span>
				</xsl:if>
			</span> 
		</span>-->

	</xsl:template>

	<xsl:template match="tei:sp/tei:speaker" as="item()*">
		<em>
			<xsl:value-of select="." disable-output-escaping="no"/>:</em>
	</xsl:template>
	<xsl:template match="tei:list" as="item()*">
		<xsl:variable name="listTag">
			<xsl:choose>
				<xsl:when test=" @type='ordered'">ol</xsl:when>
				<xsl:otherwise>ul</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:element name="{$listTag}" inherit-namespaces="yes">
			<xsl:call-template name="rendClass"/>
			<xsl:apply-templates select="tei:item"/>
		</xsl:element>
	</xsl:template>
	<xsl:template name="rendClass" as="item()*">
		<xsl:choose>
			<xsl:when test="@rend and starts-with(@rend,'class:')">
				<xsl:attribute name="class">
					<xsl:value-of select="substring-after(@rend,'class:')"
						disable-output-escaping="no"/>
				</xsl:attribute>
			</xsl:when>
			<xsl:when test="@rend">
				<xsl:attribute name="class">
					<xsl:value-of select="@rend" disable-output-escaping="no"/>
				</xsl:attribute>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="tei:item/tei:label" as="item()*">
		<xsl:choose>
			<xsl:when test="@rend">
				<xsl:attribute name="class">
					<xsl:value-of select="@rend" disable-output-escaping="no"/>
				</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<strong>
					<xsl:apply-templates select="child::node()"/>
				</strong>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="tei:item" as="item()*">
		<li>
			<xsl:if test="@target and tei:ref">
				<a>
					<xsl:attribute name="href">
						<xsl:value-of select="concat('#',tei:ref/@target)"
							disable-output-escaping="no"/>
					</xsl:attribute>
					<xsl:value-of select="tei:ref" disable-output-escaping="no"/>
				</a>
			</xsl:if>
			<xsl:text disable-output-escaping="no"> </xsl:text>
			<xsl:apply-templates select="child::node()"/>
		</li>
	</xsl:template>
	<xsl:template match="tei:lb" as="item()*">
		<br/>
		<xsl:apply-templates select="child::node()"/>
	</xsl:template>
	<xsl:template match="tei:pb" as="item()*">
		<xsl:if test="number(@n)&gt;1">
			<span class="center">
				<xsl:value-of select="number(@n)-1" disable-output-escaping="no"/>
			</span>
		</xsl:if>
	</xsl:template>
	<xsl:template match="tei:back" as="item()*">
		<xsl:for-each select="tei:div">
			<div>
				<xsl:call-template name="addLink"/>
				<xsl:apply-templates select="tei:head"/>
				<xsl:apply-templates select="tei:p"/>
			</div>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="tei:title" as="item()*">
		<em>
			<xsl:apply-templates select="child::node()"/>
		</em>
	</xsl:template>
	<xsl:template match="tei:note" as="item()*">
		<a>
			<xsl:attribute name="href">
				<xsl:value-of select="concat('#',@n)" disable-output-escaping="no"/>
			</xsl:attribute>
			<sup>
				<strong>
					<xsl:value-of select="@n" disable-output-escaping="no"/>
				</strong>
			</sup>
		</a>
	</xsl:template>
	<xsl:template match="tei:sp" as="item()*">
		<dt>
			<xsl:if test="tei:speaker">
				<xsl:value-of select="tei:speaker" disable-output-escaping="no"/>:</xsl:if>
		</dt>
		<dd>
			<xsl:apply-templates select="tei:p"/>
		</dd>
	</xsl:template>
	<xsl:template match="tei:emph | tei:foreign" as="item()*">
		<em>
			<xsl:value-of select="." disable-output-escaping="no"/>
		</em>
	</xsl:template>
	<xsl:template match="tei:hi" as="item()*">
		<xsl:choose>
			<xsl:when test="@rend='italic'">
				<em>
					<xsl:apply-templates select="child::node()"/>
				</em>
			</xsl:when>
			<xsl:when test="@rend='bold'">
				<b>
					<xsl:apply-templates select="child::node()"/>
				</b>
			</xsl:when>
			<xsl:when test="@rend='center'">
				<span class="center">
					<xsl:apply-templates select="child::node()"/>
				</span>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="tei:p" as="item()*">
		<p>
			<xsl:apply-templates select="@* |* |node() "/>
		</p>
	</xsl:template>
	<xsl:template match="tei:div" as="item()*">
		<xsl:if test="@type!='' and @n!='' and @n!='1'">
			<p>
				<a href="#content" class="noline">
					<!-- <img src="/marklogic/static/img/arrow_up.gif" alt="Back to top" height="9" width="9"/> -->
					<img src="/static/natlibcat/images/arrow_up.gif" alt="Back to top" height="9"
						width="9"/>
				</a>
				<a href="#content">Back to top</a>
			</p>
			<h3>
				<span id="{concat(@type,@n)}">
					<xsl:value-of select="concat(@type, '  ', @n,'.  ',tei:head)"
						disable-output-escaping="no"/>
				</span>
			</h3>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="tei:sp">
				<dl>
					<xsl:apply-templates select="child::node()"/>
				</dl>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="child::node()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="tei:table" as="item()*">
		<table>
			<xsl:call-template name="rendClass"/>
			<xsl:for-each select="tei:row">
				<tr>
					<xsl:for-each select="tei:cell">
						<td rowspan="1" colspan="1">
							<xsl:apply-templates select="child::node()"/>
						</td>
					</xsl:for-each>
				</tr>
			</xsl:for-each>
		</table>
	</xsl:template>
	<xsl:template name="addLink" as="item()*">
		<xsl:choose>
			<!-- add linking tag if necessary -->
			<xsl:when test="@id">
				<a>
					<xsl:attribute name="name">
						<xsl:value-of select="@id" disable-output-escaping="no"/>
					</xsl:attribute>
				</a>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="span" as="item()*">
		<xsl:copy-of select="." copy-namespaces="yes"/>
	</xsl:template>
	<xsl:template match="tei:span" as="item()*">
		<xsl:copy-of select="." copy-namespaces="yes"/>
	</xsl:template>
</xsl:stylesheet>
