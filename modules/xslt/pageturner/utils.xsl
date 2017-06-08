<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" exclude-result-prefixes="mets mods xlink" xpath-default-namespace="local" default-validation="strip" input-type-annotations="unspecified" xmlns:mets="http://www.loc.gov/METS/" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/1999/xhtml">
	<xsl:param name="page" select="1"/>
	<xsl:param name="behavior">default</xsl:param>
	<xsl:param name="from"/>
	<xsl:param name="size">640</xsl:param>
	<xsl:param name="profile"/>
	<xsl:param name="itemID"/>
	<xsl:param name="section"/>
	<xsl:param name="hostname"/>

	<!-- thumbnail only (100), for locshare -->

	<xsl:variable name="jp2ThumbServer">http://lcweb2.loc.gov/diglib/jp2/thumbnailserver?res=1&amp;maxthumbnailheight=100&amp;maxthumbnailwidth=100&amp;rotation=0&amp;filename=</xsl:variable>

	<xsl:variable name="metsprofile">
		<xsl:choose>
			<xsl:when test="$profile!=''">
				<xsl:value-of select="$profile" disable-output-escaping="no"/>
			</xsl:when>
			<xsl:when test="/menu/profile!=''">
				<xsl:value-of select="/menu/profile" disable-output-escaping="no"/>
			</xsl:when>
			<xsl:when test="/pageTurner/descriptive/profile!=''">
				<xsl:value-of select="/pageTurner/descriptive/profile" disable-output-escaping="no"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="substring-after(/mets:mets/@PROFILE,'lc:')" disable-output-escaping="no"/>
			</xsl:otherwise>

		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="digid">
		<xsl:choose>
			<xsl:when test="starts-with(/mets:mets/@OBJID,'loc.natlib.ihas.')">
				<xsl:value-of select="substring-after(/mets:mets/@OBJID,'loc.natlib.ihas.')" disable-output-escaping="no"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="/mets:mets/@OBJID" disable-output-escaping="no"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<!--where does this get used???-->
	<xsl:variable name="ID">
		<xsl:value-of select="/mets:mets/@OBJID" disable-output-escaping="no"/>
	</xsl:variable>
	<xsl:variable name="pageCount">
		<xsl:choose>
			<xsl:when test="$metsprofile='photoObject' and count(/pageTurner/object/version) =1 ">
				<!-- count of versions -->
				<xsl:value-of select="count(/pageTurner//pages//page)" disable-output-escaping="no"/>
			</xsl:when>
			<xsl:when test="$metsprofile='photoObject' and $behavior='contactsheet'">
				<!-- count of versions -->
				<xsl:value-of select="count(/pageTurner/object/version)" disable-output-escaping="no"/>
			</xsl:when>

			<xsl:when test="$metsprofile='photoObject' ">
				<!-- count of versions -->
				<xsl:value-of select="count(/pageTurner/object/version)" disable-output-escaping="no"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="count(/pageTurner//pages/page)" disable-output-escaping="no"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="pageNum">
		<!-- if user selects a page above or below the page count, set it to 1 or the last one -->
		<xsl:choose>
			<xsl:when test="number($page) &gt; number($pageCount)">
				<xsl:value-of select="$pageCount" disable-output-escaping="no"/>
			</xsl:when>
			<xsl:when test="number($page) &lt;= 1">1</xsl:when>
			<!-- <xsl:when test="number($page) !=$page">1</xsl:when> not comparable in xslt2, not useful-->
			<xsl:when test="$page=''">1</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="round($page)" disable-output-escaping="no"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<!-- <xsl:variable name="imageServer">http://lcweb2.loc.gov/diglib/jp2/imageserver?res=1&amp;viewheight=200&amp;viewwidth=200&amp;filename=</xsl:variable> -->
	<xsl:variable name="jpegType">
		<xsl:choose>
			<xsl:when test="/pageTurner//pages//page[1]/image[contains(@href,'.jp2') or contains(@href,'.jpx')]">jpeg2000</xsl:when>
			<xsl:otherwise>jpeg</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="title" select="//pageTurner/descriptive/pagetitle"/>
	<xsl:variable name="sheet-title">
		<xsl:value-of select="$title" disable-output-escaping="no"/>
	</xsl:variable>
	<xsl:variable name="gmd">
		<xsl:call-template name="format"/>
	</xsl:variable>
	<xsl:variable name="composer">
		<xsl:for-each select="//mods:name[1]">
			<xsl:call-template name="displayName">
				<xsl:with-param name="name" select="string-join(mods:namePart[not(@type='date')],' ')"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="pagetitle">
		<!-- this might be better than sheet-title: comes from mods:default -->
		<xsl:value-of select="concat(//mods:mods/mods:titleInfo[1]/mods:nonSort,//mods:mods/mods:titleInfo[1]/mods:title)" disable-output-escaping="no"/>
		<xsl:choose>
			<xsl:when test="//mods:name/mods:role/mods:roleTerm='Interviewee'"/>
			<xsl:when test="//mods:mods/mods:typeOfResource = 'notated music'">
				<!-- <xsl:for-each select="//mods:mods/mods:name[translate(mods:role/mods:roleTerm,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='composer' or translate(mods:role/mods:roleTerm,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='creator']/mods:namePart[not(@type = 'date')]"> -->
				<xsl:for-each select="//mods:mods/mods:name[translate(mods:role/mods:roleTerm,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='composer' or translate(mods:role/mods:roleTerm,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='creator']">
					<xsl:if test="position()=1"><xsl:text disable-output-escaping="no"> / </xsl:text></xsl:if>
					<xsl:call-template name="displayName">
						<xsl:with-param name="name" select="string-join(mods:namePart[not(@type = 'date')],' ')"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="//mods:mods/mods:typeOfResource = 'sound recording-musical'">
				<!-- <xsl:for-each select="mods:mods/mods:name[lower-case(mods:role/mods:roleTerm)='performer']/mods:namePart[not(@type = 'date')]"> -->
				<xsl:for-each select="//mods:mods/mods:name[lower-case(mods:role/mods:roleTerm)='performer']">
					<xsl:if test="position()=1"><xsl:text disable-output-escaping="no"> / </xsl:text></xsl:if>
					<xsl:call-template name="displayName">
						<xsl:with-param name="name" select="string-join(mods:namePart[not(@type = 'date')],' ')"/>
					</xsl:call-template>)</xsl:for-each> <xsl:value-of select="$gmd" disable-output-escaping="no"/></xsl:when>
			<xsl:when test="//mods:mods/mods:typeOfResource = 'text'">
			<xsl:for-each select="//mods:mods/mods:name[mods:role[lower-case(mods:roleTerm)='author']]">
				<xsl:if test="position()=1"><xsl:text disable-output-escaping="no"> / </xsl:text></xsl:if>

				<xsl:call-template name="formatNames">
					<xsl:with-param name="names" select="string-join(mods:namePart[not(@type = 'date')],' ')"/>
					<!-- /mods:namePart[not(@type = 'date')] -->
					<xsl:with-param name="delimeter">
						<xsl:text disable-output-escaping="no"> and </xsl:text>
					</xsl:with-param>
				</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			
			<!-- <xsl:when test="//mods:mods/mods:name[lower-case(mods:role/mods:roleTerm)='composer' or lower-case(mods:role/mods:roleTerm)='creator']/mods:namePart[not(@type = 'date')]"> -->
			<xsl:when test="//mods:mods/mods:name[lower-case(mods:role/mods:roleTerm)='composer' or lower-case(mods:role/mods:roleTerm)='creator']">
				<!-- <xsl:for-each select="//mods:mods/mods:name[lower-case(mods:role/mods:roleTerm)='composer' or lower-case(mods:role/mods:roleTerm)='creator']/mods:namePart[not(@type = 'date')]"> -->
				<xsl:for-each select="//mods:mods/mods:name[lower-case(mods:role/mods:roleTerm)='composer' or lower-case(mods:role/mods:roleTerm)='creator']">
					<xsl:text disable-output-escaping="no"> / </xsl:text>
					<xsl:call-template name="displayName">
						<xsl:with-param name="name" select="string-join(mods:namePart[@type != 'date' or not(@type)],' ')"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="//mods:mods/mods:name">			
				<xsl:text disable-output-escaping="no"> / </xsl:text>
				<xsl:call-template name="displayName">
					<xsl:with-param name="name" select="string-join(//mods:mods/mods:name[1]/mods:namePart[not(@type) or @type!='date'],' ')"/>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="objectType">
		<xsl:choose>
			<xsl:when test="/mets:mets/@PROFILE='lc:article' or $metsprofile='article'">Article</xsl:when>
			<xsl:when test="/mets:mets/@PROFILE='lc:biography' or $metsprofile='biography'">Biography</xsl:when>
			<xsl:when test="/mets:mets/@PROFILE='lc:newCompactDisc' or $metsprofile='newCompactDisc'">Compact Disc</xsl:when>
			<xsl:when test="/mets:mets/@PROFILE='lc:compactDisc' or $metsprofile='compactDisc'">Compact Disc</xsl:when>
			<xsl:when test="/mets:mets/@PROFILE='lc:patriotismSongCollection' or $metsprofile='patriotismSongCollection'">Song Collection</xsl:when>
			<xsl:when test="/mets:mets/@PROFILE='lc:songOfAmericaCollection'or $metsprofile='songOfAmericaCollection'">Song Collection</xsl:when>
			<xsl:when test="/mets:mets/@PROFILE='lc:score' or $metsprofile='score'">Score &amp; Parts</xsl:when>
			<xsl:when test="/mets:mets/@PROFILE='lc:simplePhoto' or $metsprofile='simplePhoto'">Image</xsl:when>
			<xsl:when test="/mets:mets/@PROFILE='lc:photoObject' or $metsprofile='photoObject'">Image</xsl:when>
			<xsl:when test="/mets:mets/@PROFILE='lc:photoBatch' or $metsprofile='photoBatch'">Images</xsl:when>
			<xsl:when test="/mets:mets/@PROFILE='lc:pdfDoc' or $metsprofile='pdfDoc'">PDF</xsl:when>
			<xsl:when test="/mets:mets/@PROFILE='lc:videoProgram' or $metsprofile='videoProgram'">Video</xsl:when>
			<xsl:when test="/mets:mets/@PROFILE='lc:recordedEvent' or $metsprofile='recordedEvent'">Recording</xsl:when>
			<xsl:when test="/mets:mets/@PROFILE='lc:simpleAudio' or $metsprofile='simpleAudio'">Sound Recording</xsl:when>
			<xsl:when test="/mets:mets/@PROFILE='lc:bibRecord' or $metsprofile='bibRecord'">Bibliographic Record</xsl:when>
			<xsl:when test="/mets:mets/@PROFILE='lc:modsBibRecord' or $metsprofile='modsBibRecord'">Bibliographic Record</xsl:when>
			<xsl:when test="/mets:mets/@PROFILE='lc:collectionRecord' or $metsprofile='collectionRecord'">Set</xsl:when>
			<xsl:when test="/mets:mets/@PROFILE='lc:ead' or $metsprofile='ead'">Finding Aid</xsl:when>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="objectTypeLower" select="lower-case($objectType)"/>
	<xsl:variable name="index">
		<!--for searching??? needed in datastore???-->
		<xsl:choose>
			<xsl:when test="not(//mods:mods/mods:identifier[@type='index']) or //mods:mods/mods:identifier[@type='index']='IHAS'">/search</xsl:when>
			<!-- <xsl:when test="not(//mods:mods/mods:identifier[@type='index']='prok')">	<xsl:value-of select="//mods:mods/mods:identifier[@type='index']"/>-search</xsl:when> -->
			<xsl:otherwise>/search</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="behaviorType">
		<xsl:choose>
			<xsl:when test="$behavior='default'">Brief Display</xsl:when>
			<xsl:when test="$behavior='pageturner'">
				<xsl:choose>
					<xsl:when test="$section='ALLPARTS'">Page Turner (all parts)</xsl:when>
					<xsl:when test="$section">Page Turner (<xsl:value-of select="/pageTurner//pages/page[position()=$pageNum]/@label" disable-output-escaping="no"/>)</xsl:when>
					<xsl:otherwise>Page Turner</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$behavior='contactsheet'">Contact Sheet<xsl:if test="$section='ALLPARTS'"> (all parts)</xsl:if></xsl:when>
			<xsl:when test="$behavior='enlarge'">Enlargement</xsl:when>
			<xsl:when test="$behavior='full'">Full Description</xsl:when>
			<xsl:when test="$behavior='lyrics'">Lyrics</xsl:when>
			<xsl:when test="$behavior='transcript'">Transcript</xsl:when>
			<xsl:when test="$behavior='item'">Item</xsl:when>
			<xsl:when test="$behavior='track'">Track</xsl:when>
			<xsl:when test="$behavior='contents'">Contents</xsl:when>
			<xsl:when test="$behavior='simpleAudio'">Audio</xsl:when>

		</xsl:choose>
	</xsl:variable>


	<xsl:variable name="behaviorTypeLower" select="lower-case($behaviorType)"/>

	<xsl:variable name="objectHeader">
		<xsl:choose>
			<xsl:when test="$gmd='sound recording'">Audio</xsl:when>
			<xsl:when test="$gmd='video recording' or $gmd='video'">Video</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="translate($objectType,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','ABCDEFGHIJKLMNOPQRSTUVWXYZ')" disable-output-escaping="no"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:template name="behaviorLink" as="item()*">
		<xsl:param name="behavior">default</xsl:param>
		<xsl:param name="params"/>
		<xsl:param name="content"/>
		<xsl:variable name="additionalParams">
			<xsl:if test="$params">
				<xsl:value-of select="$params" disable-output-escaping="no"/>
			</xsl:if>
			<xsl:if test="$section">&amp;section=<xsl:value-of select="$section" disable-output-escaping="no"/></xsl:if>
		</xsl:variable>

		<xsl:variable name="linkString">
			<xsl:value-of select="concat(normalize-space($behavior),'.html')" disable-output-escaping="no"/>
			<xsl:if test="$additionalParams!=''">?<xsl:value-of select="$additionalParams" disable-output-escaping="no"/></xsl:if>
		</xsl:variable>

		<a href="{$linkString}">
			<xsl:copy-of select="$content" copy-namespaces="yes"/>
		</a>
	</xsl:template>

	<xsl:template name="makeHEAD" as="item()*">
		<head>
			<title><xsl:value-of select="$title" disable-output-escaping="no"/>:<xsl:value-of select="$objectType" disable-output-escaping="no"/><xsl:text disable-output-escaping="no"> </xsl:text><xsl:value-of select="$behaviorType" disable-output-escaping="no"/>: Library of Congress</title>
			<meta name="Keywords" content=" library congress "/>
			<meta name="Description" content="{$title} :{$objectType} {$behaviorType}  ( Library of Congress )"/>
			<xsl:if test="$behavior='pageturner' ">
				<link rel="stylesheet" type="text/css" href="http://lcweb2.loc.gov/natlib/ihas/web/css/loc_pae100_ss.css"/>
			</xsl:if>
			<xsl:if test="$behavior='full' ">
				<link rel="stylesheet" type="text/css" href="/static/natlibcat/css/mktree.css"/>
				<script src="/static/natlibcat/js/mktree.js" language="javascript" type="text/javascript" charset="utf-8" xml:space="preserve">
					<!--
						non - empty link-->
				</script>
			</xsl:if>
			<!-- is this an audio file? -->
			<xsl:if test="$behavior='item' or $behavior='track' or $metsprofile='simpleAudio'">
				<script type="text/javascript" src="/marklogic/static/mediaplayer/swfobject_2-2.js" xml:space="preserve"> 
				</script>
			</xsl:if>
			<link href="/unapi" title="unAPI" type="application/xml" rel="unapi-server"/>
		</head>
	</xsl:template>


	<xsl:template name="makeImageLink" as="item()*">
		<xsl:param name="URL"/>
		<xsl:param name="alt"/>
		<xsl:param name="width">
			<xsl:choose>
				<xsl:when test="$behavior='pageturner' and $jpegType='jpeg2000'">800</xsl:when>
				<xsl:when test="$behavior='pageturner' and starts-with($digid,'loc.law.law')">800</xsl:when>
				<xsl:when test="$behavior='pageturner'">500</xsl:when>
				<xsl:when test="$behavior='contactsheet'">150</xsl:when>
				<xsl:when test="$behavior='default'">200</xsl:when>
				<xsl:when test="$behavior='enlarge'">400</xsl:when>
				<xsl:otherwise>100</xsl:otherwise>
			</xsl:choose>
		</xsl:param>
		<xsl:param name="section"/>

		<xsl:variable name="jp2ImageServer">http://lcweb2.loc.gov/diglib/jp2/thumbnailserver?res=1&amp;maxthumbnailheight=2880&amp;maxthumbnailwidth=2880&amp;rotation=0&amp;filename=</xsl:variable>
		<xsl:variable name="jp2Longdesc">http://lcweb2.loc.gov/diglib/jp2/thumbnailserver?res=1&amp;maxthumbnailheight=3600&amp;maxthumbnailwidth=3600&amp;rotation=0&amp;filename=</xsl:variable>

		<xsl:variable name="imageCode">
			<xsl:choose>
				<!-- ammem derivs use 640 (r)  -->
				<xsl:when test="$behavior='pageturner' and (contains($URL,'/pnp/') or contains($URL,'/afcwip/') )">r</xsl:when>
				<xsl:when test="$behavior='pageturner'">p</xsl:when>
				<!-- ammem derivs use t.gif for 150 -->
				<xsl:when test="$behavior='contactsheet' and ($metsprofile='photoObject' or $metsprofile='printMaterial') ">t</xsl:when>
				<xsl:when test="$behavior='contactsheet'">c</xsl:when>
				<xsl:when test="$behavior='default'">t</xsl:when>
				<xsl:when test="$behavior='enlarge'">
					<xsl:choose>
						<xsl:when test="$width='640'">r</xsl:when>
						<xsl:when test="$width='1024'">v</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>t</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="src">
			<xsl:choose>
				<xsl:when test="contains($URL[1],'/rbc/')">
					<xsl:value-of select="$URL[1]" disable-output-escaping="no"/>/<xsl:value-of select="$width" disable-output-escaping="no"/>
				</xsl:when>
				<xsl:when test="contains($URL[1],'v.jpg') and  (contains($URL,'/pnp/') or contains($URL,'/afcwip/') ) and $imageCode='t'">
					<xsl:value-of select="concat(substring-before($URL,'v.jpg'),$imageCode,'.gif')" disable-output-escaping="no"/>
				</xsl:when>
				<xsl:when test="contains($URL[1],'v.jpg')">
					<xsl:value-of select="concat(substring-before($URL,'v.jpg'),$imageCode,'.jpg')" disable-output-escaping="no"/>
				</xsl:when>
				<xsl:when test="contains($URL[1],'.gif')">
					<xsl:value-of select="concat(substring-before($URL,'.gif'),$imageCode,'.jpg')" disable-output-escaping="no"/>
				</xsl:when>
				<xsl:when test="$jpegType='jpeg2000' and contains($URL,'loc.gov/gmd')">
					<xsl:value-of select="concat($jp2ImageServer,substring-after($URL[1],'loc.gov/gmd'))" disable-output-escaping="no"/>
				</xsl:when>
				<xsl:when test="$jpegType='jpeg2000'">
					<xsl:value-of select="concat($jp2ImageServer,substring-after($URL[1],'loc.gov'))" disable-output-escaping="no"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$URL" disable-output-escaping="no"/>/<xsl:value-of select="$width" disable-output-escaping="no"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:element name="img" inherit-namespaces="yes">
			<xsl:attribute name="style">maxwidth:<xsl:value-of select="$width" disable-output-escaping="no"/>;text-align:left;float:center;</xsl:attribute>
			<xsl:attribute name="src" select="$src"/>
			<xsl:attribute name="alt" select="$alt"/>
			<xsl:attribute name="class">
				<xsl:choose>
					<xsl:when test="$behavior='default'">brief</xsl:when>
					<xsl:otherwise>item</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:if test="not($metsprofile='simplePhoto' or $metsprofile='photoObject' ) ">
				<xsl:attribute name="width">
					<xsl:value-of select="$width" disable-output-escaping="no"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="$jpegType='jpeg2000' and contains($URL,'loc.gov/gmd')">
					<xsl:attribute name="longdesc">
						<xsl:value-of select="concat($jp2Longdesc,substring-after($URL,'loc.gov/gmd'))" disable-output-escaping="no"/>
					</xsl:attribute>
				</xsl:when>
				<xsl:when test="$jpegType='jpeg2000'">
					<xsl:attribute name="longdesc">
						<xsl:value-of select="concat($jp2Longdesc,substring-after($URL,'loc.gov'))" disable-output-escaping="no"/>
					</xsl:attribute>
				</xsl:when>
			</xsl:choose>

			<xsl:if test="$behavior!='contactsheet' and $behavior!='pageturner' and $behavior!='zoom'">
				<xsl:attribute name="class">
					<xsl:choose>
						<xsl:when test="$behavior='default'">brief</xsl:when>
						<xsl:when test="$width='1024'">largest</xsl:when>
						<xsl:otherwise>item</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</xsl:if>
		</xsl:element>
	</xsl:template>

	<xsl:template name="displayName" as="item()*">
		<xsl:param name="name"/>
		<xsl:variable name="sName">
			<xsl:value-of select="translate(string-join($name,' '),'[]?','')" disable-output-escaping="no"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="contains(substring-after($sName,', '),',')">
				<!-- Corporate Name with 2 commas -->
				<xsl:value-of select="$sName" disable-output-escaping="no"/>
			</xsl:when>
			<xsl:when test="contains($sName,',')">
				<xsl:value-of select="concat(substring-after($sName,', '),' ',substring-before($sName,','))" disable-output-escaping="no"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$sName" disable-output-escaping="no"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="formatNames" as="item()*">
		<xsl:param name="names"/>
		<xsl:param name="delimeter">
			<xsl:text disable-output-escaping="no"> </xsl:text>
		</xsl:param>
		<xsl:variable name="str">
			<xsl:for-each select="$names">
				<xsl:call-template name="displayName">
					<xsl:with-param name="name" select="string-join(mods:namePart[not(@type = 'date')],' ')"/>
				</xsl:call-template>
				<xsl:value-of select="$delimeter" disable-output-escaping="no"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:value-of select="substring($str,1,string-length($str)-string-length($delimeter))" disable-output-escaping="no"/>
	</xsl:template>
	<xsl:template name="format" as="item()*">
		<xsl:variable name="format">
			<xsl:choose>
				<!-- nate changed format by adding genre/form first 4/25/06 -->
				<xsl:when test="//mods:mods/mods:genre">
					<xsl:value-of select="(//mods:mods/mods:genre)[1]" disable-output-escaping="no"/>
				</xsl:when>
				<xsl:when test="//mods:mods/mods:typeOfResource='notated music'">
					<xsl:value-of select="//mods:mods/mods:typeOfResource[1]" disable-output-escaping="no"/>
					<xsl:if test="//mods:mods/mods:typeOfResource[1][@manuscript='yes']">
						<xsl:text disable-output-escaping="no"> manuscript</xsl:text>
					</xsl:if>
				</xsl:when>
				<xsl:when test="//mods:mods/mods:physicalDescription/mods:form">
					<xsl:value-of select="//mods:mods/mods:physicalDescription/mods:form[1]" disable-output-escaping="no"/>
				</xsl:when>

				<xsl:otherwise>
					<xsl:value-of select="$metsprofile" disable-output-escaping="no"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="lowerFormat">
			<!-- <xsl:value-of select="lower-case($format)"/> -->
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$lowerFormat='sheetmusic'">sheet music</xsl:when>
			<xsl:when test="$lowerFormat='sheetmusic2'">sheet music</xsl:when>
			<xsl:when test="$lowerFormat='manuscript'">manuscript</xsl:when>
			<xsl:when test="$lowerFormat='printmaterial'">print material</xsl:when>
			<xsl:when test="$lowerFormat='print'">print material</xsl:when>
			<xsl:when test="$lowerFormat='manuscriptscore'">manuscript score</xsl:when>
			<xsl:when test="$lowerFormat='manuscriptsketch'">manuscript sketch</xsl:when>
			<xsl:when test="$lowerFormat='score'">score</xsl:when>
			<xsl:when test="$lowerFormat='musicalscore'">musical score</xsl:when>
			<xsl:when test="$lowerFormat='scoreandparts'">musical score and parts</xsl:when>
			<xsl:when test="$lowerFormat='musicalscoreandparts'">musical score and parts</xsl:when>
			<xsl:when test="$lowerFormat='instrumentalparts'">instrumental parts</xsl:when>
			<xsl:when test="$lowerFormat='vocalscore'">vocal score</xsl:when>
			<xsl:when test="$lowerFormat='songsheet'">song sheet</xsl:when>
			<xsl:when test="$lowerFormat='simplephoto'">photograph</xsl:when>
			<xsl:when test="$lowerFormat='photoobject'">photograph</xsl:when>
			<xsl:when test="$lowerFormat='photobatch'">photographs</xsl:when>
			<xsl:when test="$lowerFormat='photograph'">photograph</xsl:when>
			<xsl:when test="$lowerFormat='simpleaudio'">sound recording</xsl:when>
			<xsl:when test="$lowerFormat='compactdisc'">compact disc</xsl:when>
			<xsl:when test="$lowerFormat='newcompactdisc'">compact disc</xsl:when>
			<xsl:when test="$lowerFormat='soundrecording'">sound recording</xsl:when>
			<xsl:when test="$lowerFormat='videoprogram'">video recording</xsl:when>

			<xsl:when test="$lowerFormat='motionpicture'">motion picture</xsl:when>
			<xsl:when test="$lowerFormat='videorecording'">video recording</xsl:when>
			<xsl:when test="$lowerFormat='video'">video recording</xsl:when>
			<xsl:when test="$lowerFormat='pdfdoc'">print material (PDF)</xsl:when>
			<xsl:when test="$lowerFormat='findingaid'">finding aid</xsl:when>
			<xsl:when test="$lowerFormat='bibrecord'">bibliographic record</xsl:when>
			<xsl:when test="$lowerFormat='concertprogram'">concert program</xsl:when>
			<xsl:when test="$lowerFormat='discography'">discography</xsl:when>
			<xsl:when test="$lowerFormat='filmography'">filmography</xsl:when>
			<xsl:when test="$lowerFormat='bibliography'">bibliography</xsl:when>
			<xsl:when test="$lowerFormat='specialcollection'">special collection</xsl:when>
			<xsl:when test="$lowerFormat='songofamericacollection'">Song Collection</xsl:when>
			<xsl:when test="$lowerFormat='collectionrecord'">Set</xsl:when>
			<xsl:when test="$lowerFormat='patriotismsongcollection'">Song Collection</xsl:when>
			<xsl:when test="$lowerFormat='webpresentation'">web presentation</xsl:when>
			<xsl:when test="$lowerFormat='resourcedescription'">resource description</xsl:when>
			<xsl:when test="$lowerFormat='recordedevent'">
				<xsl:choose>
					<xsl:when test="//mets:FLocat[contains(@xlink:href,'mp3')]">sound
						recording</xsl:when>
					<xsl:when test="//mets:FLocat[contains(@xlink:href,'mpg')]">video
						recording</xsl:when>
					<xsl:otherwise>recorded event</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<!-- <xsl:value-of select="lower-case($format)"/> -->
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="navbar" as="item()*">
		<!-- moved from pageturner so that enlarge can use it -->
		<xsl:param name="position"/>
		<xsl:param name="pageCount"/>
		<xsl:choose>
			<xsl:when test="$pageCount=1">
				<xsl:call-template name="imageSizer"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="navbarform">
					<xsl:with-param name="position" select="$position"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="navbarform" as="item()*">
		<xsl:param name="position">1</xsl:param>
		<xsl:variable name="pageLabel">
			<xsl:choose>
				<xsl:when test="$metsprofile='photoObject'">Side</xsl:when>
				<xsl:when test="$metsprofile='photoBatch'">Image</xsl:when>
				<xsl:otherwise>Page</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<form method="get" onsubmit="return validateForm(this)" action="" enctype="application/x-www-form-urlencoded">
			<span class="results_num">
				<xsl:value-of select="$pageLabel" disable-output-escaping="no"/> <xsl:value-of select="$pageNum" disable-output-escaping="no"/></span>
			<xsl:text disable-output-escaping="no"> of </xsl:text>
			<xsl:value-of select="$pageCount" disable-output-escaping="no"/>  <xsl:choose>
				<xsl:when test="$pageNum = 1"><img src="/marklogic/static/img/back_blue.gif" alt="Arrow back" width="11" height="11"/><a href="?page={$pageCount}&amp;section={$section}&amp;size={$size}">
						<!-- when at start,  "previous" = final page  -->Previous</a></xsl:when>
				<xsl:otherwise><img src="/marklogic/static/img/back_blue.gif" alt="Arrow back" width="11" height="11"/> <a href="?page={$pageNum - 1}&amp;section={$section}&amp;size={$size}">Previous</a></xsl:otherwise>
			</xsl:choose> | <xsl:choose>
				<xsl:when test="$pageNum = $pageCount"> <a href="?page=1&amp;section={$section}&amp;size={$size}">Next</a> <img src="/marklogic/static/img/forward_green.gif" alt="Arrow forward" width="11" height="11"/></xsl:when>
				<xsl:otherwise> <a href="?page={$pageNum + 1}&amp;section={$section}&amp;size={$size}">Next</a> <img src="/marklogic/static/img/forward_green.gif" alt="Arrow forward" width="11" height="11"/></xsl:otherwise>
			</xsl:choose>
			<xsl:text disable-output-escaping="no">  </xsl:text>
			<label for="go_to_page{$position}">Page:</label>
			<input name="page" id="go_to_page{$position}" type="text" size="3" maxlength="3"/>
			<input name="submit" class="button" type="submit" value="GO"/>
			<input type="hidden" name="section" value="{$section}"/>
			<input type="hidden" name="size" value="{$size}"/>
			<input type="hidden" name="from" value="{$behavior}"/>
			<xsl:call-template name="imageSizer"/>
			<!--<a href="page.pdf?start={$page}">Page PDF</a> -->
		</form>
	</xsl:template>
	<xsl:template name="imageSizer" as="item()*">
		<xsl:variable name="frompage">
			<xsl:choose>
				<xsl:when test="$from!=''">
					<xsl:value-of select="$from" disable-output-escaping="no"/>
				</xsl:when>
				<xsl:when test="$metsprofile='photoObject'">default</xsl:when>
				<xsl:otherwise>pageturner</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$behavior='pageturner'">
				<xsl:text disable-output-escaping="no">  Enlarge: </xsl:text>
				<!--<img src="/marklogic/static/img/plus.gif" alt="Plus Icon" width="9" height="9"/>-->
				<xsl:call-template name="behaviorLink">
					<xsl:with-param name="behavior">pageturner</xsl:with-param>
					<xsl:with-param name="params">page=<xsl:value-of select="$pageNum" disable-output-escaping="no"/><xsl:text disable-output-escaping="no">&amp;size=640</xsl:text></xsl:with-param>
					<xsl:with-param name="content">640</xsl:with-param>
				</xsl:call-template>
				<xsl:text disable-output-escaping="no"> | </xsl:text>
				<!--<img src="/marklogic/static/img/plus.gif" alt="Plus Icon" width="9" height="9"/>-->
				<xsl:call-template name="behaviorLink">
					<xsl:with-param name="behavior">enlarge</xsl:with-param>
					<xsl:with-param name="params">page=<xsl:value-of select="$pageNum" disable-output-escaping="no"/><xsl:text disable-output-escaping="no">&amp;size=1024</xsl:text></xsl:with-param>
					<xsl:with-param name="content">1024</xsl:with-param>
				</xsl:call-template>
				<xsl:if test="$jpegType='jpeg2000'">
					<xsl:text disable-output-escaping="no"> | </xsl:text>
					<!--<img src="/marklogic/static/img/plus.gif" alt="Plus Icon" width="9" height="9"/>-->
					<xsl:call-template name="behaviorLink">
						<xsl:with-param name="behavior">zoom</xsl:with-param>
						<xsl:with-param name="params">page=<xsl:value-of select="$pageNum" disable-output-escaping="no"/><xsl:text disable-output-escaping="no">&amp;size=400</xsl:text></xsl:with-param>
						<xsl:with-param name="content">zoom</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$behavior='zoom'">   <xsl:text disable-output-escaping="no">« </xsl:text>
				<xsl:call-template name="behaviorLink">
					<xsl:with-param name="behavior">
						<xsl:value-of select="$frompage" disable-output-escaping="no"/>
					</xsl:with-param>
					<xsl:with-param name="params">page=<xsl:value-of select="$pageNum" disable-output-escaping="no"/></xsl:with-param>
					<xsl:with-param name="content">Default view</xsl:with-param>
				</xsl:call-template>
				<xsl:text disable-output-escaping="no"> | </xsl:text>
				<!--<img src="/marklogic/static/img/plus.gif" alt="Plus Icon" width="9" height="9"/>-->
				<xsl:call-template name="behaviorLink">
					<xsl:with-param name="behavior">enlarge</xsl:with-param>
					<xsl:with-param name="params">page=<xsl:value-of select="$pageNum" disable-output-escaping="no"/><xsl:text disable-output-escaping="no">&amp;size=640</xsl:text></xsl:with-param>
					<xsl:with-param name="content">640</xsl:with-param>
				</xsl:call-template>
				<xsl:text disable-output-escaping="no"> | </xsl:text>
				<!--<img src="/marklogic/static/img/plus.gif" alt="Plus Icon" width="9" height="9"/>-->
				<xsl:call-template name="behaviorLink">
					<xsl:with-param name="behavior">pageturner</xsl:with-param>
					<xsl:with-param name="params">page=<xsl:value-of select="$pageNum" disable-output-escaping="no"/>
						<xsl:text disable-output-escaping="no">&amp;size=1024</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="content">1024</xsl:with-param>
				</xsl:call-template>
				<xsl:text disable-output-escaping="no"> | </xsl:text>
				<span class="results_num">Zoom</span>
			</xsl:when>
			<xsl:when test="number($size)=1024">   <xsl:text disable-output-escaping="no">« </xsl:text>
				<xsl:call-template name="behaviorLink">
					<xsl:with-param name="behavior">
						<xsl:value-of select="$frompage" disable-output-escaping="no"/>
					</xsl:with-param>
					<xsl:with-param name="params">page=<xsl:value-of select="$pageNum" disable-output-escaping="no"/></xsl:with-param>
					<xsl:with-param name="content">Default view</xsl:with-param>
				</xsl:call-template>
				<xsl:text disable-output-escaping="no"> | </xsl:text>
				<!--<img src="/marklogic/static/img/plus.gif" alt="Plus Icon" width="9" height="9"/>-->
				<xsl:call-template name="behaviorLink">
					<xsl:with-param name="behavior">enlarge</xsl:with-param>
					<xsl:with-param name="params">page=<xsl:value-of select="$pageNum" disable-output-escaping="no"/><xsl:text disable-output-escaping="no">&amp;size=640</xsl:text></xsl:with-param>
					<xsl:with-param name="content">640</xsl:with-param>
				</xsl:call-template>
				<xsl:text disable-output-escaping="no"> | </xsl:text>
				<span class="results_num">1024</span>
				<xsl:if test="$jpegType='jpeg2000'">
					<xsl:text disable-output-escaping="no"> | </xsl:text>
					<!--<img src="/marklogic/static/img/plus.gif" alt="Plus Icon" width="9" height="9"/>-->
					<xsl:call-template name="behaviorLink">
						<xsl:with-param name="behavior">zoom</xsl:with-param>
						<xsl:with-param name="params">page=<xsl:value-of select="$pageNum" disable-output-escaping="no"/>
							<xsl:text disable-output-escaping="no">&amp;size=400</xsl:text>
						</xsl:with-param>
						<xsl:with-param name="content">zoom</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text disable-output-escaping="no">  « </xsl:text>

				<xsl:call-template name="behaviorLink">
					<xsl:with-param name="behavior">
						<xsl:value-of select="$frompage" disable-output-escaping="no"/>
					</xsl:with-param>

					<xsl:with-param name="params">page=<xsl:value-of select="$pageNum" disable-output-escaping="no"/></xsl:with-param>
					<xsl:with-param name="content">default view</xsl:with-param>
				</xsl:call-template>
				<xsl:text disable-output-escaping="no"> | </xsl:text>
				<span class="results_num">640</span>
				<xsl:text disable-output-escaping="no"> | </xsl:text>
				<!--<img src="/marklogic/static/img/plus.gif" alt="Plus Icon" width="9" height="9"/>-->
				<xsl:call-template name="behaviorLink">
					<xsl:with-param name="behavior">enlarge</xsl:with-param>
					<xsl:with-param name="params">page=<xsl:value-of select="$pageNum" disable-output-escaping="no"/>
						<xsl:text disable-output-escaping="no">&amp;size=1024</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="content">1024</xsl:with-param>
				</xsl:call-template>

				<xsl:if test="$jpegType='jpeg2000'">
					<xsl:text disable-output-escaping="no"> | </xsl:text>
					<!--<img src="/marklogic/static/img/plus.gif" alt="Plus Icon" width="9" height="9"/>-->
					<xsl:call-template name="behaviorLink">
						<xsl:with-param name="behavior">enlarge</xsl:with-param>

						<xsl:with-param name="params">page=<xsl:value-of select="$pageNum" disable-output-escaping="no"/><xsl:text disable-output-escaping="no">&amp;size=400</xsl:text>
						</xsl:with-param>
						<xsl:with-param name="content">zoom</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="tiffLink" as="item()*">
		<xsl:param name="imageloc">1</xsl:param>
		<xsl:param name="clean">0</xsl:param>
		<xsl:choose>
			<xsl:when test="not(contains($imageloc , '.jp2'))">
				<xsl:variable name="tiff" select="concat(substring-before($imageloc,'/service'),'/warehouse/',concat(substring(substring-after($imageloc,'service/'),1,string-length(substring-after($imageloc,'service/'))-5),'.tif'))"/>
				<xsl:if test="not(number($clean))">
					<a href="{$tiff}">TIFF</a>
				</xsl:if>
				<xsl:if test="number($clean)">
					<xsl:value-of select="$tiff" disable-output-escaping="no"/>
				</xsl:if>
			</xsl:when>
			<xsl:when test="contains($imageloc, '.jp2')">
				<xsl:variable name="jp2" select="$imageloc"/>
				<xsl:if test="not(number($clean))">
					<a href="{$jp2}">JP2</a>
				</xsl:if>
				<xsl:if test="number($clean)">
					<xsl:value-of select="$jp2" disable-output-escaping="no"/>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>

				<xsl:variable name="tiff" select="concat(      substring-before($imageloc,'/service'),      '/warehouse/',      concat(substring(substring-after($imageloc,'service/'),1,string-length(substring-after($imageloc,'service/'))-4),'.tif')      )"/>

				<xsl:if test="not(number($clean))">
					<a href="{$tiff}">TIFF</a>
				</xsl:if>

				<xsl:if test="number($clean)">
					<xsl:value-of select="$tiff" disable-output-escaping="no"/>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="ellipsize" as="item()*">
		<xsl:param name="string"/>
		<xsl:choose>
			<xsl:when test="substring($string,string-length($string)) = ' '">
				<xsl:value-of select="substring($string,1,string-length($string)-1)" disable-output-escaping="no"/>...</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="ellipsize">
					<xsl:with-param name="string" select="substring($string,1,string-length($string)-1)"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="findLastSpace" as="item()*">
		<xsl:param name="titleChop"/>
		<xsl:choose>
			<xsl:when test="substring($titleChop,string-length($titleChop))!=' '">
				<xsl:call-template name="findLastSpace">
					<xsl:with-param name="titleChop" select="substring($titleChop, 1,string-length($titleChop)-1)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$titleChop" disable-output-escaping="no"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="locshare" as="item()*">
		<!--  encode the share tool with downloadable links -->
		<xsl:variable name="thumb">
			<xsl:choose>
				<xsl:when test="//pages/displayImage/page">
					<xsl:value-of select="//pages/displayImage/page[1]/image/@href" disable-output-escaping="no"/>
				</xsl:when>
				<xsl:when test="//pages/illustration">
					<xsl:value-of select="//pages/illustration[1]/image/@href" disable-output-escaping="no"/>
				</xsl:when>
				<xsl:when test="//pages/page">
					<xsl:value-of select="//pages/page[1]/image/@href" disable-output-escaping="no"/>
				</xsl:when>

				<xsl:otherwise>none</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="thumblink">
			<xsl:choose>
				<xsl:when test="$jpegType='jpeg2000'">
					<xsl:value-of select="concat($jp2ThumbServer,substring-after($thumb,'.loc.gov'))" disable-output-escaping="no"/>
				</xsl:when>
				<xsl:when test="$thumb!='none'">
					<xsl:value-of select="concat(substring-before($thumb, 'v.jpg'),'h.jpg')" disable-output-escaping="no"/>
				</xsl:when>

				<xsl:otherwise>none</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="thumblink1">
			<xsl:value-of select="translate($thumblink,'&amp;','&amp;amp;')" disable-output-escaping="no"/>
		</xsl:variable>
		<div class="locshare-this" id="page_toolbar">
			<code>{ <xsl:if test="$thumblink!='none'">embed_type: 'image', embed_detail:
						'<xsl:value-of select="$thumblink" disable-output-escaping="no"/>',
					<!-- embed_detail: 'http://lcweb2.loc.gov/diglib/jp2/thumbnailserver?res=1&amp;amp;maxthumbnailheight=100&amp;amp;maxthumbnailwidth=100&amp;amp;rotation=0&amp;amp;filename=/natlib/ihas/service/octavo/200154466/0001.jp2', -->
					embed_alt: '<xsl:call-template name="escape-apos">
						<xsl:with-param name="string">
							<xsl:value-of select="$title" disable-output-escaping="no"/>
						</xsl:with-param>
					</xsl:call-template>', thumbnail: { url: '<xsl:value-of select="$thumblink" disable-output-escaping="no"/>',
					alt: '<xsl:call-template name="escape-apos">
						<xsl:with-param name="string">
							<xsl:value-of select="$title" disable-output-escaping="no"/>
						</xsl:with-param>
					</xsl:call-template>' },</xsl:if>download_links:[ /* { label:'PDF', link:
					'<xsl:value-of select="$digid" disable-output-escaping="no"/>.pdf', meta: 'PDF file' }, */ <xsl:if test="$thumblink!='none'">{ label:'TIFF Master', link: '<xsl:call-template name="tiffLink">
						<xsl:with-param name="imageloc">
							<xsl:value-of select="$thumb" disable-output-escaping="no"/>
						</xsl:with-param>
						<xsl:with-param name="clean">1</xsl:with-param>
					</xsl:call-template>', meta: 'TIFF' },</xsl:if>{ label:'MODS Bibliographic
				Record', link: 'mods.xml', meta: 'XML' }, { label:'METS Object Description', link:
				'mets.xml', meta: 'XML' } ] }</code>
		</div>
	</xsl:template>

	<xsl:template name="mediaPlayer" as="item()*">
		<xsl:if test="$behavior='item' or $behavior='track' or $behavior='default'">
			<div style="width: 100%; text-align: center;">
				<div id="mediaplayer"> </div>
			</div>
			<br/>
			<br/>
			<xsl:choose>
				<xsl:when test="contains(//menu/items/item[@id=$itemID]/part/subItem/part/link/@file , '.mp3') or contains(//menu/items/item[@id=$itemID]/part/link/@file , '.mp3')">
					<xsl:call-template name="buildPlayer">
						<xsl:with-param name="metsID" select="$ID"/>
					</xsl:call-template>
				</xsl:when>

				<xsl:when test="$metsprofile='simpleAudio' and contains(//part/href/@file , '.mp3')">
					<xsl:call-template name="buildPlayer">
						<xsl:with-param name="metsID" select="none"/>
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	<xsl:template name="buildPlayer" as="item()*">
		<xsl:param name="metsID"/>
		<script type="text/javascript" language="javascript" xml:space="preserve">var flashvars =
			{
			'id':                                    	'mediaplayer',
			'playlistfile':                             '<xsl:value-of select="concat('media-playlist/' , $metsprofile , '/' , $behavior , '/' , $ID)" disable-output-escaping="no"/>',
			'playlist':									'bottom',
			'playlistsize':								55,
			//'skin': 									'../html/mediaplayer/modieus.swf',
			//'width':									450,
			//'height':									50,
			'autostart':                            	'false',
			'fullscreen':                            	'false'
			};	

			var params =
			{
			'allowfullscreen':                       'false',
			'allowscriptaccess':                     'always',
			'bgcolor':                               '#FFFFFF'
			};
	
			var attributes =
			{
			'id':                                    'mediaplayer',
			'name':                                  'mediaplayer'
			};	
			swfobject.embedSWF('../html/mediaplayer/player.swf', 
								'mediaplayer', 
								'450', 
								'79', 
								'9.0.124', 
								false, 
								flashvars, 
								params, 
								attributes);</script>
	</xsl:template>



	<!-- Thank you Jeni Tennison -->

	<!-- Found at: http://www.dpawson.co.uk/xsl/sect2/N7150.html#d9522e673 -->

	<xsl:template name="escape-apos" as="item()*">
		<xsl:param name="string"/>
		<xsl:variable name="apos" select="&quot;'&quot;"/>
		<xsl:choose>
			<xsl:when test="contains($string, $apos)">
				<xsl:value-of select="substring-before($string,$apos)" disable-output-escaping="no"/>
				<xsl:text disable-output-escaping="no">\'</xsl:text>
				<xsl:call-template name="escape-apos">
					<xsl:with-param name="string" select="substring-after($string, $apos)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$string" disable-output-escaping="no"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


</xsl:stylesheet>