<?xml version='1.0'?>
<xsl:stylesheet version="1.0" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:marc="http://www.loc.gov/MARC21/slim"
  xmlns:bf="http://id.loc.gov/ontologies/bibframe/" xmlns:bflc="http://id.loc.gov/ontologies/bflc/"
  xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="xsl marc" xmlns="http://www.loc.gov/MARC21/slim">

  <!--
      Conversion specs for names from 1XX, 6XX, 7XX, and 8XX fields adapted from bib spec, uses bib spec where possible.
	  fixed 4xx , should now be variant title, not related
	  includes 500 unlike  for bibs
  -->
  <!-- <xsl:include href="../xsl/ConvSpec-1XX,6XX,7XX,8XX-names.xsl"/> -->
  
  <!-- bf:Work properties from name fields -->
  <xsl:template match="marc:datafield[@tag='100' or @tag='110' or @tag='111']" mode="work">
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
   <xsl:variable name="agentiri">
      <xsl:apply-templates mode="generateUri" select=".">
        <xsl:with-param name="pDefaultUri"><xsl:value-of select="$recordid"/>#Agent<xsl:value-of select="@tag"/>-<xsl:value-of select="position()"/></xsl:with-param>
        <xsl:with-param name="pEntity">bf:Agent</xsl:with-param>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:apply-templates mode="workName" select=".">
      <xsl:with-param name="agentiri" select="$agentiri"/>
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
	  <xsl:if test="marc:subfield[@code='t']">
      <xsl:apply-templates mode="workUnifTitle" select=".">
        <xsl:with-param name="serialization" select="$serialization"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>

  <!-- override the bib spec, so we can process 4xx differently 
    4xx with $t is a variant title, not another work
	5xx with a $t is a different work
	-->
  
  <!-- 4xx or 5xx w/o $t is  a contribution -->
  <xsl:template  match="marc:datafield[ @tag='400' or @tag='410' or @tag='411'  or @tag='500' or @tag='510' or @tag='511'][not(marc:subfield[@code='t'])]" mode="work">  
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="agentiri"><xsl:value-of select="$recordid"/>#Agent<xsl:value-of select="@tag"/>-<xsl:value-of select="position()"/></xsl:variable>
   <!--  <xsl:variable name="workiri"><xsl:value-of select="$recordid"/>#Work<xsl:value-of select="@tag"   />-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:apply-templates mode="work4XX" select=".">
      <xsl:with-param name="agentiri" select="$agentiri"/>
      <xsl:with-param name="workiri" select="$workiri"/>
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates> -->
	<xsl:apply-templates mode="workName" select=".">
                    <xsl:with-param name="agentiri" select="$agentiri"/>
                    <xsl:with-param name="serialization" select="$serialization"/>
                  </xsl:apply-templates>
	
	 <!-- <xsl:apply-templates mode="work">
            <xsl:with-param name="recordid" select="$recordid"/>
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates> -->
  </xsl:template>
  <!-- 4xx with a $t is a variant title and maybe a contribution -->
   <xsl:template  match="marc:datafield[ @tag='400' or @tag='410' or @tag='411' ][marc:subfield[@code='t']]" mode="work">  
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="agentiri"><xsl:value-of select="$recordid"/>#Agent<xsl:value-of    select="@tag"/>-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:variable name="workiri"><xsl:value-of select="$recordid"/>#Work<xsl:value-of select="@tag"   />-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:apply-templates mode="work4XX" select=".">
      <xsl:with-param name="agentiri" select="$agentiri"/>
      <xsl:with-param name="workiri" select="$workiri"/>
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
	 
  </xsl:template>
  <!-- 5xx with a $t is a related work -->
  <xsl:template  match="marc:datafield[ @tag='500' or @tag='510' or @tag='511'][marc:subfield[@code='t']]" mode="work">  
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="agentiri"><xsl:value-of select="$recordid"/>#Agent<xsl:value-of    select="@tag"/>-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:variable name="workiri"><xsl:value-of select="$recordid"/>#Work<xsl:value-of select="@tag"   />-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:apply-templates mode="work4XX" select=".">
      <xsl:with-param name="agentiri" select="$agentiri"/>
      <xsl:with-param name="workiri" select="$workiri"/>
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
	 <!-- <xsl:apply-templates mode="work">
            <xsl:with-param name="recordid" select="$recordid"/>
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates> -->
  </xsl:template>
  <xsl:template  match="marc:datafield[ @tag='430' ]" mode="work">  
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="agentiri"><xsl:value-of select="$recordid"/>#Agent<xsl:value-of    select="@tag"/>-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:variable name="workiri"><xsl:value-of select="$recordid"/>#Work<xsl:value-of select="@tag"   />-<xsl:value-of select="position()"/></xsl:variable>
    
	<xsl:apply-templates mode="work430" select=".">
      <xsl:with-param name="agentiri" select="$agentiri"/>
      <xsl:with-param name="workiri" select="$workiri"/>
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template>

 <xsl:template  match="marc:datafield[ @tag='530' ]" mode="work">  
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>    
    <xsl:variable name="workiri"><xsl:value-of select="$recordid"/>#Work<xsl:value-of select="@tag"   />-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:apply-templates mode="work530" select=".">      
      <xsl:with-param name="workiri" select="$workiri"/>
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
	
  </xsl:template>
   <!-- from work8xx for 4xx  -->
  <xsl:template match="marc:datafield" mode="work4XX">
    <xsl:param name="agentiri"/>
    <xsl:param name="workiri"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang">
      <xsl:apply-templates select="." mode="xmllang"/>
    </xsl:variable>
	
    <xsl:choose>
      <xsl:when test="$serialization='rdfxml'">

        <!--  if name matches 1xx  name, it's a variant title,
              if not,  its a related work
              If there is no title, it's a contributor to the main work. -->
        <xsl:choose>
          <xsl:when test="marc:subfield[@code='t']">
            <xsl:variable name="vNameLabel">
              <xsl:apply-templates select="." mode="tNameLabel"/>
            </xsl:variable>
 		  	<xsl:variable name="vTitleLabel">
              <xsl:apply-templates select="." mode="tTitleLabel"/>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="$primaryNameLabel=$vNameLabel">
			  				
                <bf:title>			                      
                  <bf:Title>
                    <rdf:type>
                      <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,'VariantTitle')"/></xsl:attribute>
                    </rdf:type>
                    <bf:mainTitle>
                      <xsl:if test="$vXmlLang != ''">
                        <xsl:attribute name="xml:lang">
                          <xsl:value-of select="$vXmlLang"/>
                        </xsl:attribute>
                      </xsl:if>
                      <xsl:value-of select="$vTitleLabel"/>
                    </bf:mainTitle>
                  </bf:Title>
                </bf:title>
              </xsl:when>
              <!--end name=primaryname-->
              <xsl:otherwise><!-- name is a contributor to main work -->
			  <xsl:apply-templates mode="workName" select=".">
                      <xsl:with-param name="agentiri" select="$agentiri"/>
                      <xsl:with-param name="serialization" select="$serialization"/>
                    </xsl:apply-templates>	
                <!--names don't match, related work testing removal of the whole otherwise-->				  
				<!-- 2018-11-13 : nate embedded the work instead of linking to it  and change the $i to "IF" from for-each -->

			 <xsl:if test="marc:subfield[@code='i']"> <!-- from 787 bibs -->			 
              <bflc:relationship>
                <bflc:Relationship>
                  <bflc:relation>
                    <rdfs:Resource>
                      <rdfs:label>
                        <xsl:if test="$vXmlLang != ''">
                          <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                        </xsl:if>
                        <xsl:call-template name="chopPunctuation">
                          <xsl:with-param name="chopString">
                            <xsl:value-of select="marc:subfield[@code='i']"/>
                          </xsl:with-param>
                        </xsl:call-template>
                      </rdfs:label>
                    </rdfs:Resource>
                  </bflc:relation>
                  <!-- <bf:relatedTo> -->
                    <!-- <xsl:attribute name="rdf:resource"><xsl:value-of select="$workiri"/></xsl:attribute> -->
<xsl:variable name="vRelation"> <!-- copied from 530 -->
          	  <xsl:choose>
			  <xsl:when test="not(marc:subfield[@code='i'] ) and not(marc:subfield[@code='4']) ">bf:relatedTo</xsl:when>
              	 <xsl:when test="substring(marc:subfield[@code='w'],1,1)='f' ">bf:derivativeOf</xsl:when>
				  <xsl:when test="substring(marc:subfield[@code='w'],1,1)='i' ">bf:relatedTo</xsl:when>
				  <xsl:when test="substring(marc:subfield[@code='w'],1,1)='r' ">bf:relatedTo</xsl:when>
				  <xsl:otherwise>bf:relatedTo</xsl:otherwise>
			  </xsl:choose>
            </xsl:variable>
              <xsl:element name="{$vRelation}">
                   <bf:Work>   <xsl:attribute name="rdf:about"><xsl:value-of select="$workiri"/></xsl:attribute>				   
                 <xsl:apply-templates mode="workUnifTitle" select=".">
              		<xsl:with-param name="serialization" select="$serialization"/>
            	</xsl:apply-templates>						  
					 <xsl:apply-templates mode="workName" select=".">
                      <xsl:with-param name="agentiri" select="$agentiri"/>
                      <xsl:with-param name="serialization" select="$serialization"/>
                    </xsl:apply-templates>					
                  </bf:Work> 
                </xsl:element>
                 <!--  </bf:relatedTo> -->
                </bflc:Relationship>
              </bflc:relationship>
            </xsl:if>
<!-- related  work used to be here -->         	
              </xsl:otherwise>
              <!--name=primaryname-->
            </xsl:choose>
          </xsl:when> <!--t-->
          <xsl:otherwise> <!--no t-->
              <!--no $t, so it's a contributor to the main work-->
              <!-- related name -->      
                  <xsl:apply-templates mode="workName" select=".">
                    <xsl:with-param name="agentiri" select="$agentiri"/>
                    <xsl:with-param name="serialization" select="$serialization"/>
                  </xsl:apply-templates>
				   <!-- this is outside the contrib: ntra 2018-10-30 fix -->
                 <!--  <xsl:if test="not(marc:subfield[@code='4' or @code='e'])">
                    <bf:role rdf:resource="http://id.loc.gov/relators/ctr"/>
                  </xsl:if>     -->       
            </xsl:otherwise>
            <!--no $t, so it's a contributor to the main work-->
        </xsl:choose>
		</xsl:when>
        
        </xsl:choose>
       <!--serialization-->
  </xsl:template>

   <!-- fromwork4XX -->
  <xsl:template match="marc:datafield" mode="work430">
    <xsl:param name="agentiri"/>
    <xsl:param name="workiri"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang">
      <xsl:apply-templates select="." mode="xmllang"/>
    </xsl:variable>
	  <xsl:variable name="vNameLabel">
              <xsl:if test="@tag!='430'"><xsl:apply-templates select="." mode="tNameLabel"/></xsl:if>
            </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization='rdfxml'">
        <!--  if name matches 1xx  name, it's a variant title,
              if not,  its a related work
              If there is no title, it's a contributor to the main work.
			  continue here nate!! -->                     
 		  	<xsl:variable name="vTitleLabel">
            <xsl:apply-templates select="." mode="tTitleLabel"/>		
            </xsl:variable>                         
                <bf:title>			                      
                  <bf:Title>
                    <rdf:type>
                      <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,'VariantTitle')"/></xsl:attribute>
                    </rdf:type>
                    <bf:mainTitle>
                      <xsl:if test="$vXmlLang != ''">
                        <xsl:attribute name="xml:lang">
                          <xsl:value-of select="$vXmlLang"/>
                        </xsl:attribute>
                      </xsl:if>
                      <xsl:value-of select="$vTitleLabel"/>
                    </bf:mainTitle>
                  </bf:Title>
                </bf:title>
              </xsl:when>
          <!--serialization-->
        </xsl:choose>
     
  </xsl:template>
  <!-- from  work4XX -->
  <xsl:template match="marc:datafield" mode="work530">    
    <xsl:param name="workiri"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang">
      <xsl:apply-templates select="." mode="xmllang"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization='rdfxml'">        
			<xsl:variable name="vRelation">
          	  <xsl:choose>
			  <xsl:when test="not(marc:subfield[@code='i'] ) and not(marc:subfield[@code='4']) ">bf:relatedTo</xsl:when>
              	 <xsl:when test="substring(marc:subfield[@code='w'],1,1)='f' ">bf:derivativeOf</xsl:when>
				  <xsl:when test="substring(marc:subfield[@code='w'],1,1)='i' ">bf:relatedTo</xsl:when>
				  <xsl:when test="substring(marc:subfield[@code='w'],1,1)='r' ">bf:relatedTo</xsl:when>
				  <xsl:otherwise>bf:relatedTo</xsl:otherwise>
			  </xsl:choose>
            </xsl:variable>
              <xsl:element name="{$vRelation}">
                   <bf:Work>
				    <xsl:attribute name="rdf:about"><xsl:value-of select="$workiri"/></xsl:attribute>					
                 <xsl:apply-templates mode="workUnifTitle" select=".">				 
              		<xsl:with-param name="serialization" select="$serialization"/>
            	</xsl:apply-templates>
				
				  <!-- <xsl:for-each select="marc:subfield[@code='4']"><bflc:relation rdf:resource="{.}"/></xsl:for-each>
					<xsl:for-each select="marc:subfield[@code='i']"><bflc:relation><bflc:Relation><rdfs:label><xsl:value-of select="."/></rdfs:label></bflc:Relation></bflc:relation></xsl:for-each> -->
                  </bf:Work> 
                </xsl:element>              
        
        </xsl:when>
          <!--serialization-->
        </xsl:choose>
     
  </xsl:template>
  <xsl:template match="marc:datafield" mode="workName">
    <xsl:param name="agentiri"/>
    <xsl:param name="recordid"/>
    <xsl:param name="serialization"/>
    <xsl:variable name="tag">
      <xsl:choose>
        <xsl:when test="@tag=880">
          <xsl:value-of select="substring(marc:subfield[@code='6'],1,3)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@tag"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="rolesFromSubfields">
      <xsl:choose>
        <xsl:when test="substring($tag,2,2)='11'">
          <xsl:apply-templates select="marc:subfield[@code='j']" mode="contributionRole">
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
        </xsl:when>		
        <xsl:otherwise>
          <xsl:apply-templates select="marc:subfield[@code='e']" mode="contributionRole">
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="marc:subfield[@code='4']" mode="contributionRoleCode">
        <xsl:with-param name="serialization" select="$serialization"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization='rdfxml'">
        <bf:contribution>
          <bf:Contribution>
            <xsl:if test="substring($tag,1,1) = '1'">
              <rdf:type>
                <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bflc,'PrimaryContribution')"/></xsl:attribute>
              </rdf:type>
            </xsl:if>
            <bf:agent>
              <xsl:apply-templates mode="agent" select=".">
                <xsl:with-param name="agentiri" select="$agentiri"/>
                <xsl:with-param name="serialization" select="$serialization"/>
              </xsl:apply-templates>
            </bf:agent>
            <xsl:choose>
              <xsl:when test="substring($tag,1,1)='6'">
                <bf:role>
                  <bf:Role>
                    <xsl:attribute name="rdf:about"><xsl:value-of select="concat($relators,'ctb')"/></xsl:attribute>
                  </bf:Role>
                </bf:role>
              </xsl:when>
			    <!-- 5xx roles -->
			    <xsl:when test="substring($tag,1,1)='5' and not(marc:subfield[@code='t']) ">
                <bf:role>
                  <bf:Role>
				  <rdfs:label><xsl:value-of select="marc:subfield[@code='i']"/></rdfs:label>                    
                  </bf:Role>
                </bf:role>
              </xsl:when>
              <xsl:otherwise>
                <xsl:choose>
                  <xsl:when test="(substring($tag,3,1) = '0' and marc:subfield[@code='e']) or
                                  (substring($tag,3,1) = '1' and marc:subfield[@code='j']) or
                                  marc:subfield[@code='4']">
                    <xsl:copy-of select="$rolesFromSubfields"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <bf:role>
                      <bf:Role>
                        <xsl:attribute name="rdf:about"><xsl:value-of select="concat($relators,'ctb')"/></xsl:attribute>
                      </bf:Role>
                    </bf:role>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </bf:Contribution>
        </bf:contribution>
      </xsl:when>
    </xsl:choose>
	<!-- 410 dups issue  -->
    <!-- <xsl:if test="marc:subfield[@code='t']">
      <xsl:apply-templates mode="workUnifTitle" select=".">
        <xsl:with-param name="serialization" select="$serialization"/>
      </xsl:apply-templates>
    </xsl:if> -->
  </xsl:template>
  
  <!-- build bf:role properties from $4 -->
  <xsl:template match="marc:subfield[@code='4']" mode="contributionRoleCode">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:role>
          <bf:Role>
            <xsl:attribute name="rdf:about">
              <xsl:value-of select="concat($relators,substring(.,1,3))"/>
            </xsl:attribute>
          </bf:Role>
        </bf:role>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- build bf:role properties from $e or $j -->
  <xsl:template match="marc:subfield" mode="contributionRole">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="pMode" select="'role'"/>
    <xsl:param name="pRelatedTo"/>
    <xsl:variable name="vXmlLang">
      <xsl:apply-templates select="parent::*" mode="xmllang"/>
    </xsl:variable>
    <xsl:call-template name="splitRole">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="roleString" select="."/>
      <xsl:with-param name="pMode" select="$pMode"/>
      <xsl:with-param name="pRelatedTo" select="$pRelatedTo"/>
      <xsl:with-param name="pXmlLang" select="$vXmlLang"/>
    </xsl:call-template>
  </xsl:template>
<!-- auth change -->
  <xsl:template match="marc:datafield" mode="tNameLabel">
    <xsl:variable name="tag">
      <xsl:choose>
        <xsl:when test="@tag=880">
          <xsl:value-of select="substring(marc:subfield[@code='6'],1,3)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@tag"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
     
      <!-- auth change  for 4xx? nate suppressed $w-->
      <xsl:when test="$tag='400' or $tag='410'">
        <xsl:apply-templates mode="concat-nodes-space"
          select="marc:subfield[@code='t']/preceding-sibling::marc:subfield[not(@code='e' or @code=4 or @code='h' or @code='w')]"
        />
      </xsl:when><!-- nate fixed $n coming through onto names -->
	   <xsl:when test="marc:subfield[@code='t'] and $tag='100' or $tag='110' or $tag='111'">
        <xsl:apply-templates mode="concat-nodes-space"
          select="marc:subfield[@code='t']/preceding-sibling::marc:subfield[not(@code='e' or @code=4 or @code='h' or @code='j')]"
        />
      </xsl:when>
	      <!-- auth change  for 4xx nate suppressed $w-->
      <xsl:when test="$tag='411'">
        <xsl:apply-templates mode="concat-nodes-space"
          select="marc:subfield[@code='t']/preceding-sibling::marc:subfield[not(@code='e' or @code=4 or @code='h' or @code='j' or @code='w' )]"
        />
      </xsl:when>
	  <xsl:when test="$tag='500'  and not(marc:subfield[@code='t'])">
        <xsl:apply-templates mode="concat-nodes-space"  select="marc:subfield[@code='a' or @code='b' or @code='c' or @code='d' or @code='q']"/>
      </xsl:when>
      <xsl:when test="$tag='510' and not(marc:subfield[@code='t'])">
        <xsl:apply-templates mode="concat-nodes-space"  select="marc:subfield[@code='a' or @code='b' or @code='c' or @code='d' or @code='g' or   @code='n' ]"/>
      </xsl:when>
      <!-- auth change  for 5xx nate suppressed $i,w-->
	  <xsl:when test="$tag='511' and not(marc:subfield[@code='t'])">        
			<xsl:apply-templates mode="concat-nodes-space"  select="marc:subfield[@code='a' or @code='c' or @code='e' or @code='q' or @code='d' or @code='g'  or @code='n' ]"     />
		</xsl:when>
	  <xsl:when test="$tag='510'">
        <xsl:apply-templates mode="concat-nodes-space"    select="marc:subfield[@code='t']/preceding-sibling::marc:subfield[@code='a' or @code='b' or @code='c' or @code='d' or @code='g'  or @code='n' ]"/>
        </xsl:when>
		<xsl:when test="$tag='511'">
       <xsl:apply-templates mode="concat-nodes-space"
          select="marc:subfield[@code='t']/preceding-sibling::marc:subfield[@code='a' or @code='c' or @code='e' or @code='q' or @code='d' or @code='g'  or @code='n' ]"    />
      </xsl:when>
	      <!-- auth change  for 5xx nate suppressed $w-->
      
      
      <xsl:otherwise>

        <xsl:apply-templates mode="concat-nodes-space"
          select="marc:subfield[@code='a' or
                                         @code='c' or
                                         @code='d' or
                                         @code='e' or
                                         @code='n' or
                                         @code='g' or
                                         @code='q']"
        />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- recursive template to split bf:role properties out of a $e or $j -->
  <xsl:template name="splitRole">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="roleString"/>
    <xsl:param name="pMode" select="'role'"/>
    <xsl:param name="pRelatedTo"/>
    <xsl:param name="pXmlLang"/>
    <xsl:choose>
      <xsl:when test="contains($roleString,',')">
        <xsl:if test="string-length(normalize-space(substring-before($roleString,','))) &gt; 0">
          <xsl:variable name="vRole"><xsl:value-of select="normalize-space(substring-before($roleString,','))"/></xsl:variable>
          <xsl:choose>
            <xsl:when test="$serialization='rdfxml'">
              <xsl:choose>
                <xsl:when test="$pMode='role'">
                  <bf:role>
                    <bf:Role>
                      <rdfs:label>
                        <xsl:if test="$pXmlLang != ''">
                          <xsl:attribute name="xml:lang"><xsl:value-of select="$pXmlLang"/></xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="$vRole"/>
                      </rdfs:label>
                    </bf:Role>
                  </bf:role>
                </xsl:when>
                <xsl:when test="$pMode='relationship'">
                  <bflc:relationship>
                    <bflc:Relationship>
                      <bflc:relation>
                        <rdfs:Resource>
                          <rdfs:label>
                            <xsl:if test="$pXmlLang != ''">
                              <xsl:attribute name="xml:lang"><xsl:value-of select="$pXmlLang"/></xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="$vRole"/>
                          </rdfs:label>
                        </rdfs:Resource>
                      </bflc:relation>
                      <xsl:if test="$pRelatedTo != ''">
                        <bf:relatedTo>
                          <xsl:attribute name="rdf:resource"><xsl:value-of select="$pRelatedTo"/></xsl:attribute>
                        </bf:relatedTo>
                      </xsl:if>
                    </bflc:Relationship>
                  </bflc:relationship>
                </xsl:when>
              </xsl:choose>
            </xsl:when>
          </xsl:choose>
        </xsl:if>
        <xsl:if test="string-length(normalize-space(substring-after($roleString,','))) &gt; 0">
          <xsl:call-template name="splitRole">
            <xsl:with-param name="serialization" select="$serialization"/>
            <xsl:with-param name="roleString" select="substring-after($roleString,',')"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:when>
      <xsl:when test="contains($roleString,' and')">
        <xsl:if test="string-length(normalize-space(substring-before($roleString,' and'))) &gt; 0">
          <xsl:variable name="vRole"><xsl:value-of select="normalize-space(substring-before($roleString,' and'))"/></xsl:variable>
          <xsl:choose>
            <xsl:when test="$serialization='rdfxml'">
              <xsl:choose>
                <xsl:when test="$pMode='role'">
                  <bf:role>
                    <bf:Role>
                      <rdfs:label>
                        <xsl:if test="$pXmlLang != ''">
                          <xsl:attribute name="xml:lang"><xsl:value-of select="$pXmlLang"/></xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="normalize-space(substring-before($roleString,' and'))"/>
                      </rdfs:label>
                    </bf:Role>
                  </bf:role>
                </xsl:when>
                <xsl:when test="$pMode='relationship'">
                  <bflc:relationship>
                    <bflc:Relationship>
                      <bflc:relation>
                        <rdfs:Resource>
                          <rdfs:label>
                            <xsl:if test="$pXmlLang != ''">
                              <xsl:attribute name="xml:lang"><xsl:value-of select="$pXmlLang"/></xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="$vRole"/>
                          </rdfs:label>
                        </rdfs:Resource>
                      </bflc:relation>
                      <xsl:if test="$pRelatedTo != ''">
                        <bf:relatedTo>
                          <xsl:attribute name="rdf:resource"><xsl:value-of select="$pRelatedTo"/></xsl:attribute>
                        </bf:relatedTo>
                      </xsl:if>
                    </bflc:Relationship>
                  </bflc:relationship>
                </xsl:when>
              </xsl:choose>
            </xsl:when>
          </xsl:choose>
        </xsl:if>
        <xsl:call-template name="splitRole">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="roleString" select="substring-after($roleString,' and')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($roleString,'&amp;')">
        <xsl:if test="string-length(normalize-space(substring-before($roleString,'&amp;'))) &gt; 0">
          <xsl:variable name="vRole"><xsl:value-of select="normalize-space(substring-before($roleString,'&amp;'))"/></xsl:variable>
          <xsl:choose>
            <xsl:when test="$serialization='rdfxml'">
              <xsl:choose>
                <xsl:when test="$pMode='role'">
                  <bf:role>
                    <bf:Role>
                      <rdfs:label>
                        <xsl:if test="$pXmlLang != ''">
                          <xsl:attribute name="xml:lang"><xsl:value-of select="$pXmlLang"/></xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="normalize-space(substring-before($roleString,'&amp;'))"/>
                      </rdfs:label>
                    </bf:Role>
                  </bf:role>
                </xsl:when>
                <xsl:when test="$pMode='relationship'">
                  <bflc:relationship>
                    <bflc:Relationship>
                      <bflc:relation>
                        <rdfs:Resource>
                          <rdfs:label>
                            <xsl:if test="$pXmlLang != ''">
                              <xsl:attribute name="xml:lang"><xsl:value-of select="$pXmlLang"/></xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="$vRole"/>
                          </rdfs:label>
                        </rdfs:Resource>
                      </bflc:relation>
                      <xsl:if test="$pRelatedTo != ''">
                        <bf:relatedTo>
                          <xsl:attribute name="rdf:resource"><xsl:value-of select="$pRelatedTo"/></xsl:attribute>
                        </bf:relatedTo>
                      </xsl:if>
                    </bflc:Relationship>
                  </bflc:relationship>
                </xsl:when>
              </xsl:choose>
            </xsl:when>
          </xsl:choose>
        </xsl:if>
        <xsl:call-template name="splitRole">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="roleString" select="substring-after($roleString,'&amp;')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$serialization='rdfxml'">
            <xsl:choose>
              <xsl:when test="$pMode='role'">
                <bf:role>
                  <bf:Role>
                    <rdfs:label>
                      <xsl:if test="$pXmlLang != ''">
                        <xsl:attribute name="xml:lang"><xsl:value-of select="$pXmlLang"/></xsl:attribute>
                      </xsl:if>
                      <xsl:value-of select="normalize-space($roleString)"/>
                    </rdfs:label>
                  </bf:Role>
                </bf:role>
              </xsl:when>
                <xsl:when test="$pMode='relationship'">
                  <bflc:relationship>
                    <bflc:Relationship>
                      <bflc:relation>
                        <rdfs:Resource>
                          <rdfs:label>
                            <xsl:if test="$pXmlLang != ''">
                              <xsl:attribute name="xml:lang"><xsl:value-of select="$pXmlLang"/></xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="normalize-space($roleString)"/>
                          </rdfs:label>
                        </rdfs:Resource>
                      </bflc:relation>
                      <xsl:if test="$pRelatedTo != ''">
                        <bf:relatedTo>
                          <xsl:attribute name="rdf:resource"><xsl:value-of select="$pRelatedTo"/></xsl:attribute>
                        </bf:relatedTo>
                      </xsl:if>
                    </bflc:Relationship>
                  </bflc:relationship>
                </xsl:when>
              </xsl:choose>
          </xsl:when>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- build a bf:Agent entity -->
  <xsl:template match="marc:datafield" mode="agent">
  <!-- note: in a 4xx or 5xx that is a related work, do we want primarycontributor? will i it help? 
   -->
    <xsl:param name="agentiri"/>
    <xsl:param name="pMADSClass"/>
    <xsl:param name="pSource"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="recordid"/>
    <xsl:variable name="tag">
      <xsl:choose>
        <xsl:when test="@tag=880">
          <xsl:value-of select="substring(marc:subfield[@code='6'],1,3)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@tag"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:variable name="label">
      <xsl:apply-templates select="." mode="tNameLabel"/>
    </xsl:variable>
   
    <xsl:variable name="marckey">
      <xsl:apply-templates mode="marcKey"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization='rdfxml'">
        <bf:Agent>
          <xsl:attribute name="rdf:about"><xsl:value-of select="$agentiri"/></xsl:attribute>
          <rdf:type>
            <xsl:choose>                
              <xsl:when test="substring($tag,2,2)='00'">
                <xsl:choose>
                  <xsl:when test="@ind1='3'">
                    <xsl:attribute name="rdf:resource"><xsl:value-of select="$bf"/>Family</xsl:attribute>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:attribute name="rdf:resource"><xsl:value-of select="$bf"/>Person</xsl:attribute>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:when test="substring($tag,2,2)='10'">
                <xsl:choose>
                  <xsl:when test="@ind1='1'">
                    <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,'Jurisdiction')"/></xsl:attribute>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,'Organization')"/></xsl:attribute>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:when test="substring($tag,2,2)='11'">
                <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,'Meeting')"/></xsl:attribute>
              </xsl:when>
            </xsl:choose>
          </rdf:type>
         
            <xsl:if test="$pSource != ''">
              <xsl:copy-of select="$pSource"/>
            </xsl:if>
            <xsl:if test="not(marc:subfield[@code='t'])">
              <xsl:choose>
                <xsl:when test="substring($tag,2,2)='11'">
                  <xsl:apply-templates select="marc:subfield[@code='j']" mode="contributionRole">
                    <xsl:with-param name="serialization" select="$serialization"/>
                    <xsl:with-param name="pMode">relationship</xsl:with-param>
                    <xsl:with-param name="pRelatedTo"><xsl:value-of select="$recordid"/>#Work</xsl:with-param>
                  </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select="marc:subfield[@code='e']" mode="contributionRole">
                    <xsl:with-param name="serialization" select="$serialization"/>
                    <xsl:with-param name="pMode">relationship</xsl:with-param>
                    <xsl:with-param name="pRelatedTo"><xsl:value-of select="$recordid"/>#Work</xsl:with-param>
                  </xsl:apply-templates>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:for-each select="marc:subfield[@code='4']">
                <bflc:relationship>
                  <bflc:Relationship>
                    <bflc:relation>
                      <rdfs:Resource>
                        <xsl:attribute name="rdf:about"><xsl:value-of select="concat($relators,substring(.,1,3))"/></xsl:attribute>
                      </rdfs:Resource>
                    </bflc:relation>
                    <bf:relatedTo>
                      <xsl:attribute name="rdf:resource"><xsl:value-of select="$recordid"/>#Work</xsl:attribute>
                    </bf:relatedTo>
                  </bflc:Relationship>
                </bflc:relationship>
              </xsl:for-each>
            </xsl:if>
          
          <xsl:choose>
            <xsl:when test="substring($tag,2,2)='00'">
              <xsl:if test="$label != ''">
                <bflc:name00MatchKey><xsl:value-of select="normalize-space($label)"/></bflc:name00MatchKey>
                <xsl:if test="substring($tag,1,1) = '1'">
                  <bflc:primaryContributorName00MatchKey><xsl:value-of select="normalize-space($label)"/></bflc:primaryContributorName00MatchKey>
                </xsl:if>
              </xsl:if>
              <bflc:name00MarcKey><xsl:value-of select="concat(@tag,@ind1,@ind2,normalize-space($marckey))"/></bflc:name00MarcKey>
            </xsl:when>
            <xsl:when test="substring($tag,2,2)='10'">
              <xsl:if test="$label != ''">
                <bflc:name10MatchKey><xsl:value-of select="normalize-space($label)"/></bflc:name10MatchKey>
              </xsl:if>
              <bflc:name10MarcKey><xsl:value-of select="concat(@tag,@ind1,@ind2,normalize-space($marckey))"/></bflc:name10MarcKey>
                <xsl:if test="substring($tag,1,1) = '1'">
                  <bflc:primaryContributorName10MatchKey><xsl:value-of select="normalize-space($label)"/></bflc:primaryContributorName10MatchKey>
                </xsl:if>
            </xsl:when>
            <xsl:when test="substring($tag,2,2)='11'">
              <xsl:if test="$label != ''">
                <bflc:name11MatchKey><xsl:value-of select="normalize-space($label)"/></bflc:name11MatchKey>
              </xsl:if>
              <bflc:name11MarcKey><xsl:value-of select="concat(@tag,@ind1,@ind2,normalize-space($marckey))"/></bflc:name11MarcKey>
                <xsl:if test="substring($tag,1,1) = '1'">
                  <bflc:primaryContributorName11MatchKey><xsl:value-of select="normalize-space($label)"/></bflc:primaryContributorName11MatchKey>
                </xsl:if>
            </xsl:when>
          </xsl:choose>
          <xsl:if test="$label != ''">
            <rdfs:label>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:value-of select="normalize-space($label)"/>
            </rdfs:label>
          </xsl:if>
          <xsl:choose>
            <xsl:when test="marc:subfield[@code='t']">
              <xsl:for-each select="marc:subfield[@code='t']/preceding-sibling::marc:subfield[@code='0' or @code='w'][starts-with(text(),'(uri)') or starts-with(text(),'http')]">
                <xsl:if test="position() != 1">
                  <xsl:apply-templates mode="subfield0orw" select=".">
                    <xsl:with-param name="serialization" select="$serialization"/>
                  </xsl:apply-templates>
                </xsl:if>
              </xsl:for-each>
              
			  <xsl:for-each select="marc:subfield[@code='t']/preceding-sibling::marc:subfield[@code='0' or @code='w'][string-length(text() ) >  1 ]">
                <xsl:if test="substring(text(),1,5) != '(uri)' and substring(text(),1,4) != 'http'">
                  <xsl:apply-templates mode="subfield0orw" select=".">
                    <xsl:with-param name="serialization" select="$serialization"/>
                  </xsl:apply-templates>
                </xsl:if>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:for-each select="marc:subfield[@code='0' or @code='w'][starts-with(text(),'(uri)') or starts-with(text(),'http')][string-length(text())  > 1 ]">
                <xsl:if test="position() != 1">
                  <xsl:apply-templates mode="subfield0orw" select=".">
                    <xsl:with-param name="serialization" select="$serialization"/>
                  </xsl:apply-templates>
                </xsl:if>
              </xsl:for-each>
			  <!-- auth 4xx and 5xx $w= single char code; suppress -->
              <xsl:for-each select="marc:subfield[@code='0' or @code='w'][string-length(text())  > 1]">
                <xsl:if test="substring(text(),1,5) != '(uri)' and substring(text(),1,4) != 'http'">
                  <xsl:apply-templates mode="subfield0orw" select=".">
                    <xsl:with-param name="serialization" select="$serialization"/>
                  </xsl:apply-templates>
                </xsl:if>
              </xsl:for-each>
              <xsl:apply-templates mode="subfield3" select="marc:subfield[@code='3']">
                <xsl:with-param name="serialization" select="$serialization"/>
              </xsl:apply-templates>
              <xsl:apply-templates mode="subfield5" select="marc:subfield[@code='5']">
                <xsl:with-param name="serialization" select="$serialization"/>
              </xsl:apply-templates>
            </xsl:otherwise>
          </xsl:choose>
        </bf:Agent>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

<!--
      create a bflc:applicableInstitution property from a subfield $5, overrides bib controlsubfields for dlc link
  -->
  <xsl:template match="marc:subfield" mode="subfield5auth">
    <xsl:param name="serialization" select="'rdfxml'"/>
	
    <xsl:choose>
      <xsl:when test="$serialization='rdfxml'">
        <bflc:applicableInstitution>
          <bf:Agent>
		  <xsl:choose>
		  		<xsl:when test="starts-with(.,'DLC')">
					<xsl:attribute  name="rdf:about"><xsl:value-of select="concat($organizations,translate(.,concat($vUpper,'- ' ),$vLower))"/></xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
            		<bf:code><xsl:value-of select="."/></bf:code>
				</xsl:otherwise>
			</xsl:choose>
          </bf:Agent>
        </bflc:applicableInstitution>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>

<!-- Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios ><scenario default="yes" name="Scenario1" userelativepaths="yes" externalpreview="no" url="..\..\..\marcxml.xml" htmlbaseurl="" outputurl="" processortype="internal" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal" customvalidator=""/></scenarios><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
-->