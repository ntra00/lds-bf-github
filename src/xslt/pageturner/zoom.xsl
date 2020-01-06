<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" exclude-result-prefixes="xsi" xpath-default-namespace="local" default-validation="strip" input-type-annotations="unspecified" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xdmp="http://marklogic.com/xdmp" xmlns:lh="http://www.marklogic.com/ps/lib/l-highlight" xmlns:lq="http://www.marklogic.com/ps/lib/l-query" xmlns:cts="http://marklogic.com/cts">
	
	<xsl:include href="utils.xsl"/>	
	<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
	<!--	<xsl:param name="size">640</xsl:param>
	<xsl:param name="from">pageturner</xsl:param>
<xsl:param name="behavior"/>-->

	<xsl:variable name="pages" select="$pageCount"/>


	<xsl:template match="/" as="item()*">
		<xsl:choose>
			<xsl:when test="$section!='' and $profile='score'">

				<xsl:apply-templates select="pageTurner//pages/page[position()=$pageNum]"/>
			</xsl:when>
			<xsl:when test="$section!=''  and $profile='photoObject'">
				<xsl:apply-templates select="pageTurner//pages/version[@ID=$section]/pages/page[position()=$pageNum]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="pageTurner//pages/page[position()=$pageNum]"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="page" as="item()*">
		<xsl:variable name="filepath" select="concat('/',substring-after(substring-after(image/@href,'//'),'/'))"/>
				
				<xsl:choose>
					<xsl:when test="contains(/pageTurner/descriptive/full/element[contains(@label,'Collection')]/value,'Chasanoff/Elozua')">
						<div id="page_head_search">
							<span id="skip_menu"/>
							<h1>The Chasanoff/Elozua Amazing Grace Collection <br/><span>A searchable catalog of more than 3000 published recordings of Amazing Grace</span></h1>
						</div>
					</xsl:when>
					<xsl:when test="contains(image/@href,'afc9999005')">
						<div id="page_head_search">
							<h1>Traditional Music and Spoken Word Catalog <br/><span> from the American Folklife Center</span></h1>
						</div>
					</xsl:when>
					<xsl:when test="contains(/pageTurner/descriptive/full/element[contains(@label,'Source')]/value,'Jazz on the Screen')">
						<div id="page_head_search">
							<h1>Jazz on the Screen <br/><span>A jazz and blues filmography by David Meeker</span></h1>
						</div>
					</xsl:when>
				</xsl:choose>
			
		<div id="ds-bibrecord">	
			<h1 id="title-top"><xsl:choose>
								<xsl:when test="$profile='photoBatch' and @label!=''">
									<xsl:value-of select="@label" disable-output-escaping="no"/>
								</xsl:when>
								<xsl:when test="$profile='photoBatch'">Image <xsl:value-of select="$pageNum" disable-output-escaping="no"/></xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$sheet-title" disable-output-escaping="no"/>
								</xsl:otherwise>
							</xsl:choose></h1>
				<div id="main_fullwidth">
				<!--<xsl:call-template name="locshare"/>-->
					<div id="main_body">

						
						<div class="main_nav2_top">
							<xsl:call-template name="navbar">
								<xsl:with-param name="position">1</xsl:with-param>
								<xsl:with-param name="pageCount">
									<xsl:value-of select="$pageCount" disable-output-escaping="no"/>
								</xsl:with-param>
							</xsl:call-template>
						</div>
						<div class="zoom-container">


							<p><strong>To view details:</strong> Mouse over the object to activate the zoom window and magnification will appear to the right below.</p>

							<script type="text/javascript" src="http://lcweb2.loc.gov/natlib/cred/jqzoom/js/jquery.js">
								<xsl:text disable-output-escaping="no"> </xsl:text>
								<!-- fill -->
							</script>
							<script type="text/javascript" src="http://lcweb2.loc.gov/natlib/cred/jqzoom/js/jquery.jqzoom.min.js">
								<xsl:text disable-output-escaping="no"> </xsl:text>
								<!-- fill -->
							</script>
							<script type="text/javascript">$(document).ready(function(){
                $(".jqzoom").jqueryzoom({
                    xzoom: 500, //zooming div default width(default width value is 500)
                    yzoom: 275, //zooming div default width(default height value is 275)
                    offset: 10, //zooming div default offset(default offset value is 10)
                    position: "right", //zooming div position(default position value is "right")
                    preload:1,
                    lens:1
                });
            });</script>
							<div class="jqzoom">
								<!-- 	<a href="zoom.html?page={$page}&amp;section={$section}&amp;size=1024&amp;from={$from}"> -->
								<xsl:call-template name="makeImageLink">
									<xsl:with-param name="URL" select="image/@href"/>
									<xsl:with-param name="width" select="$size"/>
								</xsl:call-template>
								<!-- </a> -->
							</div>
						</div>

						<p class="clear"/> 
						
					</div>
					<!--id="main_body_fixed"-->
				</div>
				<!--id="main_menu"-->
<!-- end id="ds-bibrecord: --></div>
	</xsl:template>
</xsl:stylesheet>