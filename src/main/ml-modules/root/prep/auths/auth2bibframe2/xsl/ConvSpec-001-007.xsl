<?xml version='1.0'?>
<xsl:stylesheet version="1.0"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:marc="http://www.loc.gov/MARC21/slim"
                xmlns:bf="http://id.loc.gov/ontologies/bibframe/"
                xmlns:bflc="http://id.loc.gov/ontologies/bflc/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#"
                exclude-result-prefixes="xsl marc">

  <!--
      Conversion specs for 001-007
  -->

  <xsl:template match="marc:controlfield[@tag='001']" mode="adminmetadata">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization= 'rdfxml'">
        <bf:identifiedBy>
          <bf:Local>
            <rdf:value><xsl:value-of select="."/></rdf:value>
            <bf:assigner>
                <bf:Agent>
                    <xsl:choose>
                        <xsl:when test="../marc:controlfield[@tag='003'] = 'DLC' or ../marc:controlfield[@tag='003'] = ''">
                            <xsl:attribute name="rdf:about">http://id.loc.gov/vocabulary/organizations/dlc</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="not(../marc:controlfield[@tag='003'])">
                            <xsl:attribute name="rdf:about">http://id.loc.gov/vocabulary/organizations/dlc</xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <bf:code><xsl:value-of select="../marc:controlfield[@tag='003']" /></bf:code>
                        </xsl:otherwise>
                    </xsl:choose>
                </bf:Agent>
            </bf:assigner>
          </bf:Local>
        </bf:identifiedBy>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="marc:controlfield[@tag='005']" mode="adminmetadata">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="changeDate" select="concat(substring(.,1,4),'-',substring(.,5,2),'-',substring(.,7,2),'T',substring(.,9,2),':',substring(.,11,2),':',substring(.,13,2))"/>
    <xsl:if test="not (starts-with($changeDate, '0000'))">
      <xsl:choose>
        <xsl:when test="$serialization= 'rdfxml'">
          <bf:changeDate>
            <xsl:attribute name="rdf:datatype"><xsl:value-of select="$xs"/>dateTime</xsl:attribute>
            <xsl:value-of select="$changeDate"/>
          </bf:changeDate>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template match="marc:controlfield[@tag='007']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="workType">
      <xsl:choose>
        <xsl:when test="substring(.,1,1) = 'a'">Cartography</xsl:when>
        <xsl:when test="substring(.,1,1) = 'd'">Cartography</xsl:when>
        <xsl:when test="substring(.,1,1) = 'g'">StillImage</xsl:when>
        <xsl:when test="substring(.,1,1) = 'k'">StillImage</xsl:when>
        <xsl:when test="substring(.,1,1) = 'm'">MovingImage</xsl:when>
        <xsl:when test="substring(.,1,1) = 's'">Audio</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <!-- map -->
      <xsl:when test="substring(.,1,1) = 'a'">
        <xsl:variable name="genreForm">
          <xsl:choose>
            <xsl:when test="substring(.,2,1) = 'd'">atlases</xsl:when>
            <xsl:when test="substring(.,2,1) = 'g'">diagrams</xsl:when>
            <xsl:when test="substring(.,2,1) = 'j'">maps</xsl:when>
            <xsl:when test="substring(.,2,1) = 'k'">profile</xsl:when>
            <xsl:when test="substring(.,2,1) = 'q'">models</xsl:when>
            <xsl:when test="substring(.,2,1) = 'r'">remote-sensing images</xsl:when>
            <xsl:when test="substring(.,2,1) = 's'">map section</xsl:when>
            <xsl:when test="substring(.,2,1) = 'y'">map view</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="genreUri">
          <xsl:choose>
            <xsl:when test="substring(.,2,1) = 'd'"><xsl:value-of select="concat($genreForms,'gf2011026058')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'g'"><xsl:value-of select="concat($genreForms,'gf2014026061')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'j'"><xsl:value-of select="concat($genreForms,'gf2011026387')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'k'"><xsl:value-of select="concat($genreForms,'gf2011026387')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'q'"><xsl:value-of select="concat($genreForms,'gf2017027245')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'r'"><xsl:value-of select="concat($genreForms,'gf2011026530')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 's'"><xsl:value-of select="concat($genreForms,'gf2011026295')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'y'"><xsl:value-of select="concat($genreForms,'gf2011026387')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="colorContent">
          <xsl:choose>
            <xsl:when test="substring(.,4,1) = 'a'">one color</xsl:when>
            <xsl:when test="substring(.,4,1) = 'c'">multicolored</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="colorContentUri">
          <xsl:choose>
            <xsl:when test="substring(.,4,1) = 'a'"><xsl:value-of select="concat($mcolor,'one')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'c'"><xsl:value-of select="concat($mcolor,'mul')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="baseMaterial">
          <xsl:choose>
            <xsl:when test="substring(.,5,1) = 'a'">paper</xsl:when>
            <xsl:when test="substring(.,5,1) = 'b'">wood</xsl:when>
            <xsl:when test="substring(.,5,1) = 'c'">stone</xsl:when>
            <xsl:when test="substring(.,5,1) = 'd'">metal</xsl:when>
            <xsl:when test="substring(.,5,1) = 'e'">synthetic</xsl:when>
            <xsl:when test="substring(.,5,1) = 'f'">skin</xsl:when>
            <xsl:when test="substring(.,5,1) = 'g'">textile</xsl:when>
            <xsl:when test="substring(.,5,1) = 'i'">plastic</xsl:when>
            <xsl:when test="substring(.,5,1) = 'j'">glass</xsl:when>
            <xsl:when test="substring(.,5,1) = 'l'">vinyl</xsl:when>
            <xsl:when test="substring(.,5,1) = 'n'">vellum</xsl:when>
            <xsl:when test="substring(.,5,1) = 'p'">plaster</xsl:when>
            <xsl:when test="substring(.,5,1) = 'v'">leather</xsl:when>
            <xsl:when test="substring(.,5,1) = 'w'">parchment</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="baseMaterialUri">
          <xsl:choose>
            <xsl:when test="substring(.,5,1) = 'a'"><xsl:value-of select="concat($mmaterial,'pap')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'b'"><xsl:value-of select="concat($mmaterial,'wod')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'c'"><xsl:value-of select="concat($mmaterial,'sto')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'd'"><xsl:value-of select="concat($mmaterial,'mtl')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'e'"><xsl:value-of select="concat($mmaterial,'syn')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'f'"><xsl:value-of select="concat($mmaterial,'ski')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'g'"><xsl:value-of select="concat($mmaterial,'tex')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'i'"><xsl:value-of select="concat($mmaterial,'pla')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'j'"><xsl:value-of select="concat($mmaterial,'gls')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'l'"><xsl:value-of select="concat($mmaterial,'vny')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'n'"><xsl:value-of select="concat($mmaterial,'vel')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'p'"><xsl:value-of select="concat($mmaterial,'plt')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'v'"><xsl:value-of select="concat($mmaterial,'lea')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'w'"><xsl:value-of select="concat($mmaterial,'par')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <xsl:if test="substring(../marc:leader,7,1) != 'e' and substring(../marc:leader,7,1) != 'f'">
              <rdf:type>
                <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,$workType)"/></xsl:attribute>
              </rdf:type>
            </xsl:if>
            <xsl:if test="$genreForm != ''">
              <bf:genreForm>
                <bf:GenreForm>
                  <xsl:if test="$genreUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$genreUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$genreForm"/></rdfs:label>
                </bf:GenreForm>
                </bf:genreForm>
            </xsl:if>
            <xsl:if test="$colorContent != ''">
              <bf:colorContent>
                <bf:ColorContent>
                  <xsl:if test="$colorContentUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$colorContentUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$colorContent"/></rdfs:label>
                </bf:ColorContent>
              </bf:colorContent>
            </xsl:if>
            <xsl:if test="$baseMaterial != ''">
              <bf:baseMaterial>
                <bf:BaseMaterial>
                  <xsl:if test="$baseMaterialUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$baseMaterialUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$baseMaterial"/></rdfs:label>
                </bf:BaseMaterial>
              </bf:baseMaterial>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- electronic resource -->
      <xsl:when test="substring(.,1,1) = 'c'">
        <xsl:variable name="colorContent">
          <xsl:choose>
            <xsl:when test="substring(.,4,1) = 'a'">one color</xsl:when>
            <xsl:when test="substring(.,4,1) = 'b'">black and white</xsl:when>
            <xsl:when test="substring(.,4,1) = 'c'">multicolored</xsl:when>
            <xsl:when test="substring(.,4,1) = 'g'">gray scale</xsl:when>
            <xsl:when test="substring(.,4,1) = 'm'">mixed</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="colorContentUri">
          <xsl:choose>
            <xsl:when test="substring(.,4,1) = 'a'"><xsl:value-of select="concat($mcolor,'one')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'b'"><xsl:value-of select="concat($mcolor,'blw')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'c'"><xsl:value-of select="concat($mcolor,'mul')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'g'"><xsl:value-of select="concat($mcolor,'gry')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'm'"><xsl:value-of select="concat($mcolor,'mix')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <xsl:if test="$colorContent != ''">
              <bf:colorContent>
                <bf:ColorContent>
                  <xsl:if test="$colorContentUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$colorContentUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$colorContent"/></rdfs:label>
                </bf:ColorContent>
              </bf:colorContent>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- globe -->
      <xsl:when test="substring(.,1,1) = 'd'">
        <xsl:variable name="genreForm">
          <xsl:choose>
            <xsl:when test="substring(.,2,1) = 'a'">celestial globe</xsl:when>
            <xsl:when test="substring(.,2,1) = 'b'">planetary or lunar globe</xsl:when>
            <xsl:when test="substring(.,2,1) = 'c'">terrestrial globe</xsl:when>
            <xsl:when test="substring(.,2,1) = 'e'">earth moon globe</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="genreFormURI">
          <xsl:choose>
            <xsl:when test="substring(.,2,1) = 'a'"><xsl:value-of select="concat($genreForms,'gf2011026117')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'b'"><xsl:value-of select="concat($genreForms,'gf2011026300')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'c'"><xsl:value-of select="concat($genreForms,'gf2011026300')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'e'"><xsl:value-of select="concat($genreForms,'gf2011026300')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="colorContent">
          <xsl:choose>
            <xsl:when test="substring(.,4,1) = 'a'">one color</xsl:when>
            <xsl:when test="substring(.,4,1) = 'c'">multicolored</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="colorContentUri">
          <xsl:choose>
            <xsl:when test="substring(.,4,1) = 'a'"><xsl:value-of select="concat($mcolor,'one')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'c'"><xsl:value-of select="concat($mcolor,'mul')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <xsl:if test="substring(../marc:leader,7,1) != 'e' and substring(../marc:leader,7,1) != 'f'">
              <rdf:type>
                <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,$workType)"/></xsl:attribute>
              </rdf:type>
            </xsl:if>
            <xsl:if test="$genreForm != ''">
              <bf:genreForm>
                <bf:GenreForm>
                  <xsl:if test="$genreFormURI != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$genreFormURI"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$genreForm"/></rdfs:label>
                </bf:GenreForm>
              </bf:genreForm>
            </xsl:if>
            <xsl:if test="$colorContent != ''">
              <bf:colorContent>
                <bf:ColorContent>
                  <xsl:if test="$colorContentUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$colorContentUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$colorContent"/></rdfs:label>
                </bf:ColorContent>
              </bf:colorContent>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- projected graphic -->
      <xsl:when test="substring(.,1,1) = 'g'">
        <xsl:variable name="colorContent">
          <xsl:choose>
            <xsl:when test="substring(.,4,1) = 'a'">one color</xsl:when>
            <xsl:when test="substring(.,4,1) = 'b'">black and white</xsl:when>
            <xsl:when test="substring(.,4,1) = 'c'">multicolored</xsl:when>
            <xsl:when test="substring(.,4,1) = 'h'">hand colored</xsl:when>
            <xsl:when test="substring(.,4,1) = 'm'">mixed</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="colorContentUri">
          <xsl:choose>
            <xsl:when test="substring(.,4,1) = 'a'"><xsl:value-of select="concat($mcolor,'one')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'b'"><xsl:value-of select="concat($mcolor,'blw')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'c'"><xsl:value-of select="concat($mcolor,'mul')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'g'"><xsl:value-of select="concat($mcolor,'hnd')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'm'"><xsl:value-of select="concat($mcolor,'mix')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <xsl:if test="substring(../marc:leader,7,1) != 'k'">
              <rdf:type>
                <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,$workType)"/></xsl:attribute>
              </rdf:type>
            </xsl:if>
            <xsl:if test="$colorContent != ''">
              <bf:colorContent>
                <bf:ColorContent>
                  <xsl:if test="$colorContentUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$colorContentUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$colorContent"/></rdfs:label>
                </bf:ColorContent>
              </bf:colorContent>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- microform -->
      <xsl:when test="substring(.,1,1) = 'h'">
        <xsl:variable name="colorContent">
          <xsl:choose>
            <xsl:when test="substring(.,10,1) = 'b'">black and white</xsl:when>
            <xsl:when test="substring(.,10,1) = 'c'">multicolored</xsl:when>
            <xsl:when test="substring(.,10,1) = 'm'">mixed</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="colorContentUri">
          <xsl:choose>
            <xsl:when test="substring(.,10,1) = 'b'"><xsl:value-of select="concat($mcolor,'blw')"/></xsl:when>
            <xsl:when test="substring(.,10,1) = 'c'"><xsl:value-of select="concat($mcolor,'mul')"/></xsl:when>
            <xsl:when test="substring(.,10,1) = 'm'"><xsl:value-of select="concat($mcolor,'mix')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <xsl:if test="$colorContent != ''">
              <bf:colorContent>
                <bf:ColorContent>
                  <xsl:if test="$colorContentUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$colorContentUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$colorContent"/></rdfs:label>
                </bf:ColorContent>
              </bf:colorContent>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- nonprojected graphic -->
      <xsl:when test="substring(.,1,1) = 'k'">
        <xsl:variable name="genreForm">
          <xsl:choose>
            <xsl:when test="substring(.,2,1) = 'a'">activity card</xsl:when>
            <xsl:when test="substring(.,2,1) = 'c'">collage</xsl:when>
            <xsl:when test="substring(.,2,1) = 'd'">drawing</xsl:when>
            <xsl:when test="substring(.,2,1) = 'e'">painting</xsl:when>
            <xsl:when test="substring(.,2,1) = 'f'">photomechanical print</xsl:when>
            <xsl:when test="substring(.,2,1) = 'g'">photonegative</xsl:when>
            <xsl:when test="substring(.,2,1) = 'h'">photoprint</xsl:when>
            <xsl:when test="substring(.,2,1) = 'i'">picture</xsl:when>
            <xsl:when test="substring(.,2,1) = 'j'">print</xsl:when>
            <xsl:when test="substring(.,2,1) = 'k'">poster</xsl:when>
            <xsl:when test="substring(.,2,1) = 'l'">technical drawing</xsl:when>
            <xsl:when test="substring(.,2,1) = 'n'">chart</xsl:when>
            <xsl:when test="substring(.,2,1) = 'o'">flash card</xsl:when>
            <xsl:when test="substring(.,2,1) = 'p'">postcard</xsl:when>
            <xsl:when test="substring(.,2,1) = 'q'">icon</xsl:when>
            <xsl:when test="substring(.,2,1) = 'r'">radiograph</xsl:when>
            <xsl:when test="substring(.,2,1) = 's'">print</xsl:when>
            <xsl:when test="substring(.,2,1) = 'v'">photograph</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="genreFormUri">
          <xsl:choose>
            <xsl:when test="substring(.,2,1) = 'a'"><xsl:value-of select="concat($genreForms,'gf2017027251')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'c'"><xsl:value-of select="concat($genreForms,'gf2017027227')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'd'"><xsl:value-of select="concat($graphicMaterials,'tgm003277')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'e'"><xsl:value-of select="concat($graphicMaterials,'tgm007391')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'f'"><xsl:value-of select="concat($graphicMaterials,'tgm007730')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'g'"><xsl:value-of select="concat($graphicMaterials,'tgm007028')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'h'"><xsl:value-of select="concat($graphicMaterials,'tgm007718')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'i'"><xsl:value-of select="concat($genreForms,'gf2017027251')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'j'"><xsl:value-of select="concat($genreForms,'gf2017027255')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'k'"><xsl:value-of select="concat($genreForms,'gf2014026152')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'l'"><xsl:value-of select="concat($graphicMaterials,'tgm003055')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'n'"><xsl:value-of select="concat($genreForms,'gf2016026011')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'o'"><xsl:value-of select="concat($marcgt,'fla')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'p'"><xsl:value-of select="concat($genreForms,'gf2014026151')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'q'"><xsl:value-of select="concat($graphicMaterials,'tgm005289')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'r'"><xsl:value-of select="concat($graphicMaterials,'tgm008530')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 's'"><xsl:value-of select="concat($genreForms,'gf2017027255')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'v'"><xsl:value-of select="concat($genreForms,'gf2017027249')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="colorContent">
          <xsl:choose>
            <xsl:when test="substring(.,4,1) = 'a'">one color</xsl:when>
            <xsl:when test="substring(.,4,1) = 'b'">black and white</xsl:when>
            <xsl:when test="substring(.,4,1) = 'c'">multicolored</xsl:when>
            <xsl:when test="substring(.,4,1) = 'h'">hand colored</xsl:when>
            <xsl:when test="substring(.,4,1) = 'm'">mixed</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="colorContentUri">
          <xsl:choose>
            <xsl:when test="substring(.,4,1) = 'a'"><xsl:value-of select="concat($mcolor,'one')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'b'"><xsl:value-of select="concat($mcolor,'blw')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'c'"><xsl:value-of select="concat($mcolor,'mul')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'h'"><xsl:value-of select="concat($mcolor,'hnd')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'm'"><xsl:value-of select="concat($mcolor,'mix')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <xsl:if test="substring(../marc:leader,7,1) != 'k'">
              <rdf:type>
                <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,$workType)"/></xsl:attribute>
              </rdf:type>
            </xsl:if>
            <xsl:if test="$genreForm != ''">
              <bf:genreForm>
                <bf:GenreForm>
                  <xsl:if test="$genreFormUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$genreFormUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$genreForm"/></rdfs:label>
                </bf:GenreForm>
              </bf:genreForm>
            </xsl:if>
            <xsl:if test="$colorContent != ''">
              <bf:colorContent>
                <bf:ColorContent>
                  <xsl:if test="$colorContentUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$colorContentUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$colorContent"/></rdfs:label>
                </bf:ColorContent>
              </bf:colorContent>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- motion picture -->
      <xsl:when test="substring(.,1,1) = 'm'">
        <xsl:variable name="colorContent">
          <xsl:choose>
            <xsl:when test="substring(.,4,1) = 'b'">black and white</xsl:when>
            <xsl:when test="substring(.,4,1) = 'c'">multicolored</xsl:when>
            <xsl:when test="substring(.,4,1) = 'h'">hand colored</xsl:when>
            <xsl:when test="substring(.,4,1) = 'm'">mixed</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="colorContentUri">
          <xsl:choose>
            <xsl:when test="substring(.,4,1) = 'b'"><xsl:value-of select="concat($mcolor,'blw')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'c'"><xsl:value-of select="concat($mcolor,'mul')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'h'"><xsl:value-of select="concat($mcolor,'hnd')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'm'"><xsl:value-of select="concat($mcolor,'mix')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="vAspectRatioURI">
          <xsl:choose>
            <xsl:when test="substring(.,5,1) = 'b'"><xsl:value-of select="concat($mmaspect,'nonana')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'd'"><xsl:value-of select="concat($mmaspect,'ana')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'e'"><xsl:value-of select="concat($mmaspect,'wide')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="vAspectRatioLabel">
          <xsl:choose>
            <xsl:when test="substring(.,5,1) = 'b'">non-anamorphic</xsl:when>
            <xsl:when test="substring(.,5,1) = 'd'">anamorphic</xsl:when>
            <xsl:when test="substring(.,5,1) = 'e'">wide-screen</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="vAspectRatioURI2">
          <xsl:choose>
            <xsl:when test="substring(.,5,1) = 'b'"><xsl:value-of select="concat($mmaspect,'wide')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'd'"><xsl:value-of select="concat($mmaspect,'wide')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="vAspectRatioLabel2">
          <xsl:choose>
            <xsl:when test="substring(.,5,1) = 'b'">wide-screen</xsl:when>
            <xsl:when test="substring(.,5,1) = 'd'">wide-screen</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="genreForm2">
          <xsl:choose>
            <xsl:when test="substring(.,10,1) = 'c'">outtakes</xsl:when>
            <xsl:when test="substring(.,10,1) = 'd'">rushes</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="genreForm2Uri">
          <xsl:choose>
            <xsl:when test="substring(.,10,1) = 'c'"><xsl:value-of select="concat($genreForms,'gf2011026435')"/></xsl:when>
            <xsl:when test="substring(.,10,1) = 'd'"><xsl:value-of select="concat($genreForms,'gf2011026551')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <xsl:if test="substring(../marc:leader,7,1) != 'g'">
              <rdf:type>
                <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,$workType)"/></xsl:attribute>
              </rdf:type>
            </xsl:if>
            <bf:genreForm>
              <bf:GenreForm>
                <xsl:attribute name="rdf:about">http://id.loc.gov/authorities/genreForms/gf2011026406</xsl:attribute>
                <rdfs:label>Motion pictures</rdfs:label>
              </bf:GenreForm>
            </bf:genreForm>
            <xsl:if test="$colorContent != ''">
              <bf:colorContent>
                <bf:ColorContent>
                  <xsl:if test="$colorContentUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$colorContentUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$colorContent"/></rdfs:label>
                </bf:ColorContent>
              </bf:colorContent>
            </xsl:if>
            <xsl:if test="$vAspectRatioURI != ''">
              <bf:aspectRatio>
                <bf:AspectRatio>
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$vAspectRatioURI"/></xsl:attribute>
                    <xsl:if test="$vAspectRatioLabel != ''">
                        <rdfs:label><xsl:value-of select="$vAspectRatioLabel"/></rdfs:label>
                    </xsl:if>
                </bf:AspectRatio>
              </bf:aspectRatio>
            </xsl:if>
            <xsl:if test="$vAspectRatioURI2 != ''">
              <bf:aspectRatio>
                <bf:AspectRatio>
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$vAspectRatioURI2"/></xsl:attribute>
                    <xsl:if test="$vAspectRatioLabel2 != ''">
                        <rdfs:label><xsl:value-of select="$vAspectRatioLabel2"/></rdfs:label>
                    </xsl:if>
                </bf:AspectRatio>
              </bf:aspectRatio>
            </xsl:if>
            <xsl:if test="$genreForm2 != ''">
              <bf:genreForm>
                <bf:GenreForm>
                  <xsl:if test="$genreForm2Uri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$genreForm2Uri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$genreForm2"/></rdfs:label>
                </bf:GenreForm>
              </bf:genreForm>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- sound recording -->
      <xsl:when test="substring(.,1,1) = 's'">
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <xsl:if test="substring(../marc:leader,7,1) != 'i' and substring(../marc:leader,7,1) != 'j'">
              <rdf:type>
                <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,$workType)"/></xsl:attribute>
              </rdf:type>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- videorecording -->
      <xsl:when test="substring(.,1,1) = 'v'">
        <xsl:variable name="colorContent">
          <xsl:choose>
            <xsl:when test="substring(.,4,1) = 'a'">one color</xsl:when>
            <xsl:when test="substring(.,4,1) = 'b'">black and white</xsl:when>
            <xsl:when test="substring(.,4,1) = 'c'">multicolored</xsl:when>
            <xsl:when test="substring(.,4,1) = 'm'">mixed</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="colorContentUri">
          <xsl:choose>
            <xsl:when test="substring(.,4,1) = 'b'"><xsl:value-of select="concat($mcolor,'one')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'b'"><xsl:value-of select="concat($mcolor,'blw')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'c'"><xsl:value-of select="concat($mcolor,'mul')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'm'"><xsl:value-of select="concat($mcolor,'mix')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <bf:genreForm>
              <bf:GenreForm>
                <xsl:attribute name="rdf:about">http://id.loc.gov/authorities/genreForms/gf2011026723</xsl:attribute>
              </bf:GenreForm>
            </bf:genreForm>
            <xsl:if test="$colorContent != ''">
              <bf:colorContent>
                <bf:ColorContent>
                  <xsl:if test="$colorContentUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$colorContentUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$colorContent"/></rdfs:label>
                </bf:ColorContent>
              </bf:colorContent>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="marc:controlfield[@tag='007']" mode="instance">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <!-- map -->
      <xsl:when test="substring(.,1,1) = 'a'">
        <xsl:variable name="generation">
          <xsl:choose>
            <xsl:when test="substring(.,6,1) = 'f'">facsimile</xsl:when>
            <xsl:when test="substring(.,6,1) = 'z'">other type of reproduction</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="generationURI">
          <xsl:choose>
            <xsl:when test="substring(.,6,1) = 'f'"><xsl:value-of select="concat($mgeneration,'facsimile')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'z'"><xsl:value-of select="concat($mgeneration,'mixedgen')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="productionMethod">
          <xsl:choose>
            <xsl:when test="substring(.,7,1) = 'a'">blueline print</xsl:when>
            <xsl:when test="substring(.,7,1) = 'b'">photocopy</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="productionMethodURI">
          <xsl:choose>
            <xsl:when test="substring(.,7,1) = 'a'"><xsl:value-of select="concat($mproduction,'blueline')"/></xsl:when>
            <xsl:when test="substring(.,7,1) = 'b'"><xsl:value-of select="concat($mproduction,'photocopy')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="polarity">
          <xsl:choose>
            <xsl:when test="substring(.,8,1) = 'a'">positive</xsl:when>
            <xsl:when test="substring(.,8,1) = 'b'">negative</xsl:when>
            <xsl:when test="substring(.,8,1) = 'm'">mixed polarity</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="polarityUri">
          <xsl:choose>
            <xsl:when test="substring(.,8,1) = 'a'"><xsl:value-of select="concat($mpolarity,'pos')"/></xsl:when>
            <xsl:when test="substring(.,8,1) = 'b'"><xsl:value-of select="concat($mpolarity,'neg')"/></xsl:when>
            <xsl:when test="substring(.,8,1) = 'm'"><xsl:value-of select="concat($mpolarity,'mix')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <xsl:if test="$generation != ''">
              <bf:generation>
                <bf:Generation>
                  <xsl:if test="$generationURI != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$generationURI"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$generation"/></rdfs:label>
                </bf:Generation>
              </bf:generation>
            </xsl:if>
            <xsl:if test="$productionMethod != ''">
              <bf:productionMethod>
                <bf:ProductionMethod>
                  <xsl:if test="$productionMethodURI != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$productionMethodURI"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$productionMethod"/></rdfs:label>
                </bf:ProductionMethod>
              </bf:productionMethod>
            </xsl:if>
            <xsl:if test="$polarity != ''">
              <bf:polarity>
                <bf:Polarity>
                  <xsl:if test="$polarityUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$polarityUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$polarity"/></rdfs:label>
                </bf:Polarity>
              </bf:polarity>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- electronic resource -->
      <xsl:when test="substring(.,1,1) = 'c'">
        <xsl:variable name="carrier">
          <xsl:choose>
            <xsl:when test="substring(.,2,1) = 'a'">computer tape cartridge</xsl:when>
            <xsl:when test="substring(.,2,1) = 'b'">computer chip cartridge</xsl:when>
            <xsl:when test="substring(.,2,1) = 'c'">computer disc cartridge</xsl:when>
            <xsl:when test="substring(.,2,1) = 'd'">computer disc</xsl:when>
            <xsl:when test="substring(.,2,1) = 'e'">computer disc cartridge</xsl:when>
            <xsl:when test="substring(.,2,1) = 'f'">computer tape cassette</xsl:when>
            <xsl:when test="substring(.,2,1) = 'h'">computer tape reel</xsl:when>
            <xsl:when test="substring(.,2,1) = 'j'">computer disc</xsl:when>
            <xsl:when test="substring(.,2,1) = 'k'">computer card</xsl:when>
            <xsl:when test="substring(.,2,1) = 'm'">computer disc</xsl:when>
            <xsl:when test="substring(.,2,1) = 'o'">computer disc</xsl:when>
            <xsl:when test="substring(.,2,1) = 'r'">online resource</xsl:when>
            <xsl:when test="substring(.,2,1) = 'z'">other electronic carrier</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="carrierUri">
          <xsl:choose>
            <xsl:when test="substring(.,2,1) = 'a'"><xsl:value-of select="concat($carriers,'ca')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'b'"><xsl:value-of select="concat($carriers,'cb')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'c'"><xsl:value-of select="concat($carriers,'ce')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'd'"><xsl:value-of select="concat($carriers,'cd')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'e'"><xsl:value-of select="concat($carriers,'ce')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'f'"><xsl:value-of select="concat($carriers,'cf')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'h'"><xsl:value-of select="concat($carriers,'ch')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'j'"><xsl:value-of select="concat($carriers,'ce')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'k'"><xsl:value-of select="concat($carriers,'ck')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'm'"><xsl:value-of select="concat($carriers,'cd')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'o'"><xsl:value-of select="concat($carriers,'cd')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'r'"><xsl:value-of select="concat($carriers,'cr')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'z'"><xsl:value-of select="concat($carriers,'cz')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="dimensions">
          <xsl:choose>
            <xsl:when test="substring(.,5,1) = 'a'">3 1/2 in.</xsl:when>
            <xsl:when test="substring(.,5,1) = 'e'">12 in.</xsl:when>
            <xsl:when test="substring(.,5,1) = 'g'">4 3/4 in. or 12 cm.</xsl:when>
            <xsl:when test="substring(.,5,1) = 'i'">1 1/8 x 2 3/8 in.</xsl:when>
            <xsl:when test="substring(.,5,1) = 'j'">3 7/8 x 2 1/2 in.</xsl:when>
            <xsl:when test="substring(.,5,1) = 'o'">5 1/4 in.</xsl:when>
            <xsl:when test="substring(.,5,1) = 'u'">unknown</xsl:when>
            <xsl:when test="substring(.,5,1) = 'v'">8 in.</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="soundContent">
          <xsl:choose>
            <xsl:when test="substring(.,6,1) = ' '">silent</xsl:when>
            <xsl:when test="substring(.,6,1) = 'a'">sound</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="soundContentURI">
          <xsl:choose>
            <xsl:when test="substring(.,6,1) = ' '"><xsl:value-of select="concat($msoundcontent,'silent')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'a'"><xsl:value-of select="concat($msoundcontent,'sound')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="imageBitDepth">
          <xsl:choose>
            <xsl:when test="substring(.,7,3) = 'mmm'"/>
            <xsl:when test="substring(.,7,3) = 'nnn'"/>
            <xsl:when test="substring(.,7,3) = '---'"/>
            <xsl:when test="substring(.,7,3) = '|||'"/>
            <xsl:otherwise><xsl:value-of select="substring(.,7,3)"/></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <xsl:if test="substring(../marc:leader,7,1) != 'm'">
              <rdf:type>
                <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,'Electronic')"/></xsl:attribute>
              </rdf:type>
            </xsl:if>
            <xsl:if test="count(../marc:datafield[@tag='337']) = 0">
              <bf:media>
                <bf:Media>
                  <xsl:attribute name="rdf:about">http://id.loc.gov/vocabulary/mediaTypes/c</xsl:attribute>
                  <rdfs:label>computer</rdfs:label>
                </bf:Media>
              </bf:media>
            </xsl:if>
            <xsl:if test="count(../marc:datafield[@tag='338']) = 0">
              <xsl:if test="$carrier != ''">
                <bf:carrier>
                  <bf:Carrier>
                    <xsl:if test="$carrierUri != ''">
                      <xsl:attribute name="rdf:about"><xsl:value-of select="$carrierUri"/></xsl:attribute>
                    </xsl:if>
                    <rdfs:label><xsl:value-of select="$carrier"/></rdfs:label>
                  </bf:Carrier>
                </bf:carrier>
              </xsl:if>
            </xsl:if>
            <xsl:if test="count(../marc:datafield[@tag='300']/marc:subfield[@code='c']) = 0">
                <xsl:if test="$dimensions != ''">
                    <bf:dimensions><xsl:value-of select="$dimensions"/></bf:dimensions>
                </xsl:if>
            </xsl:if>
            <xsl:if test="$soundContent != ''">
              <bf:soundContent>
                <bf:SoundContent>
                  <xsl:if test="$soundContentURI != ''">
                      <xsl:attribute name="rdf:about"><xsl:value-of select="$soundContentURI"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$soundContent"/></rdfs:label>
                </bf:SoundContent>
              </bf:soundContent>
            </xsl:if>
            <xsl:if test="$imageBitDepth != ''">
              <bf:digitalCharacteristic>
                <bf:DigitalCharacteristic>
                  <rdf:type>
                    <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bflc,'ImageBitDepth')"/></xsl:attribute>
                  </rdf:type>
                  <rdf:value><xsl:value-of select="$imageBitDepth"/></rdf:value>
                </bf:DigitalCharacteristic>
              </bf:digitalCharacteristic>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- globe -->
      <xsl:when test="substring(.,1,1) = 'd'">
        <xsl:variable name="baseMaterial">
          <xsl:choose>
            <xsl:when test="substring(.,5,1) = 'a'">paper</xsl:when>
            <xsl:when test="substring(.,5,1) = 'b'">wood</xsl:when>
            <xsl:when test="substring(.,5,1) = 'c'">stone</xsl:when>
            <xsl:when test="substring(.,5,1) = 'd'">metal</xsl:when>
            <xsl:when test="substring(.,5,1) = 'e'">synthetic</xsl:when>
            <xsl:when test="substring(.,5,1) = 'f'">skin</xsl:when>
            <xsl:when test="substring(.,5,1) = 'g'">textile</xsl:when>
            <xsl:when test="substring(.,5,1) = 'i'">plastic</xsl:when>
            <xsl:when test="substring(.,5,1) = 'j'">glass</xsl:when>
            <xsl:when test="substring(.,5,1) = 'l'">vinyl</xsl:when>
            <xsl:when test="substring(.,5,1) = 'n'">vellum</xsl:when>
            <xsl:when test="substring(.,5,1) = 'p'">plaster</xsl:when>
            <xsl:when test="substring(.,5,1) = 'v'">leather</xsl:when>
            <xsl:when test="substring(.,5,1) = 'w'">parchment</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="baseMaterialUri">
          <xsl:choose>
            <xsl:when test="substring(.,5,1) = 'a'"><xsl:value-of select="concat($mmaterial,'pap')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'b'"><xsl:value-of select="concat($mmaterial,'wod')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'c'"><xsl:value-of select="concat($mmaterial,'sto')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'd'"><xsl:value-of select="concat($mmaterial,'mtl')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'e'"><xsl:value-of select="concat($mmaterial,'syn')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'f'"><xsl:value-of select="concat($mmaterial,'ski')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'g'"><xsl:value-of select="concat($mmaterial,'tex')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'i'"><xsl:value-of select="concat($mmaterial,'pla')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'j'"><xsl:value-of select="concat($mmaterial,'gls')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'l'"><xsl:value-of select="concat($mmaterial,'vny')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'n'"><xsl:value-of select="concat($mmaterial,'vel')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'p'"><xsl:value-of select="concat($mmaterial,'plt')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'v'"><xsl:value-of select="concat($mmaterial,'lea')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'w'"><xsl:value-of select="concat($mmaterial,'par')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="generation">
          <xsl:choose>
            <xsl:when test="substring(.,6,1) = 'f'">facsimile</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="generationUri">
          <xsl:choose>
            <xsl:when test="substring(.,6,1) = 'f'"><xsl:value-of select="concat($mgeneration,'facsimile')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <xsl:if test="$baseMaterial != ''">
              <bf:baseMaterial>
                <bf:BaseMaterial>
                  <xsl:if test="$baseMaterialUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$baseMaterialUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$baseMaterial"/></rdfs:label>
                </bf:BaseMaterial>
              </bf:baseMaterial>
            </xsl:if>
            <xsl:if test="$generation != ''">
              <bf:generation>
                <bf:Generation>
                  <xsl:if test="$generationUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$generationUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$generation"/></rdfs:label>
                </bf:Generation>
              </bf:generation>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- projected graphic -->
      <xsl:when test="substring(.,1,1) = 'g'">
        <xsl:variable name="carrier">
          <xsl:choose>
            <xsl:when test="substring(.,2,1) = 'c'">filmstrip cartridge</xsl:when>
            <xsl:when test="substring(.,2,1) = 'd'">filmslip</xsl:when>
            <xsl:when test="substring(.,2,1) = 'f'">filmstrip</xsl:when>
            <xsl:when test="substring(.,2,1) = 'o'">film roll</xsl:when>
            <xsl:when test="substring(.,2,1) = 's'">slide</xsl:when>
            <xsl:when test="substring(.,2,1) = 't'">overhead transparency</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="carrierUri">
          <xsl:choose>
            <xsl:when test="substring(.,2,1) = 'c'"><xsl:value-of select="concat($carriers,'gc')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'd'"><xsl:value-of select="concat($carriers,'gd')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'f'"><xsl:value-of select="concat($carriers,'gf')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'o'"><xsl:value-of select="concat($carriers,'mo')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 's'"><xsl:value-of select="concat($carriers,'gs')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 't'"><xsl:value-of select="concat($carriers,'gt')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="baseMaterial">
          <xsl:choose>
            <xsl:when test="substring(.,5,1) = 'd'">glass</xsl:when>
            <xsl:when test="substring(.,5,1) = 'e'">synthetic</xsl:when>
            <xsl:when test="substring(.,5,1) = 'j'">safety film</xsl:when>
            <xsl:when test="substring(.,5,1) = 'k'">film base (not safety)</xsl:when>
            <xsl:when test="substring(.,5,1) = 'm'">mixed collection</xsl:when>
            <xsl:when test="substring(.,5,1) = 'o'">paper</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="baseMaterialUri">
          <xsl:choose>
            <xsl:when test="substring(.,5,1) = 'd'"><xsl:value-of select="concat($mmaterial,'gls')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'e'"><xsl:value-of select="concat($mmaterial,'syn')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'j'"><xsl:value-of select="concat($mmaterial,'saf')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'k'"><xsl:value-of select="concat($mmaterial,'nsf')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'm'"><xsl:value-of select="concat($mmaterial,'pap')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'o'"><xsl:value-of select="concat($mmaterial,'pap')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="soundContent">
          <xsl:choose>
            <xsl:when test="substring(.,6,1) = ' '">silent</xsl:when>
            <xsl:when test="substring(.,6,1) = 'a'">sound</xsl:when>
            <xsl:when test="substring(.,6,1) = 'b'">sound</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="soundContentURI">
          <xsl:choose>
            <xsl:when test="substring(.,6,1) = ' '"><xsl:value-of select="concat($msoundcontent,'silent')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'a'"><xsl:value-of select="concat($msoundcontent,'sound')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'b'"><xsl:value-of select="concat($msoundcontent,'sound')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="recordingMedium">
          <xsl:choose>
            <xsl:when test="substring(.,7,1) = 'a'">optical sound track on motion picture film</xsl:when>
            <xsl:when test="substring(.,7,1) = 'b'">magnetic sound track on motion picture film</xsl:when>
            <xsl:when test="substring(.,7,1) = 'c'">magnetic audio tape in cartridge</xsl:when>
            <xsl:when test="substring(.,7,1) = 'd'">sound disc</xsl:when>
            <xsl:when test="substring(.,7,1) = 'e'">magnetic audio tape on reel</xsl:when>
            <xsl:when test="substring(.,7,1) = 'f'">magnetic audio tape in cassette</xsl:when>
            <xsl:when test="substring(.,7,1) = 'g'">optical and magnetic sound track on motion picture film</xsl:when>
            <xsl:when test="substring(.,7,1) = 'h'">videotape</xsl:when>
            <xsl:when test="substring(.,7,1) = 'i'">videodisc</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="recordingMediumURI">
          <xsl:choose>
            <xsl:when test="substring(.,7,1) = 'a'"><xsl:value-of select="concat($mrecmedium,'opt')"/></xsl:when>
            <xsl:when test="substring(.,7,1) = 'b'"><xsl:value-of select="concat($mrecmedium,'mag')"/></xsl:when>
            <xsl:when test="substring(.,7,1) = 'c'"><xsl:value-of select="concat($mrecmedium,'mag')"/></xsl:when>
            <xsl:when test="substring(.,7,1) = 'd'"><xsl:value-of select="concat($mrecmedium,'magopt')"/></xsl:when>
            <xsl:when test="substring(.,7,1) = 'e'"><xsl:value-of select="concat($mrecmedium,'mag')"/></xsl:when>
            <xsl:when test="substring(.,7,1) = 'f'"><xsl:value-of select="concat($mrecmedium,'mag')"/></xsl:when>
            <xsl:when test="substring(.,7,1) = 'g'"><xsl:value-of select="concat($mrecmedium,'magopt')"/></xsl:when>
            <xsl:when test="substring(.,7,1) = 'h'"><xsl:value-of select="concat($mrecmedium,'mag')"/></xsl:when>
            <xsl:when test="substring(.,7,1) = 'i'"><xsl:value-of select="concat($mrecmedium,'opt')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="dimensions">
          <xsl:choose>
            <xsl:when test="substring(.,8,1) = 'a'">standard 8 mm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'b'">super 8 mm., single 8 mm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'c'">9.5 mm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'd'">16 mm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'e'">28 mm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'f'">35 mm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'g'">70 mm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'j'">2x2 in. or 5x5 cm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'k'">2 1/4 in. x 2 1/4 in. or 6x6 cm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 's'">4x5 in. or 10x13 cm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 't'">15x7 in. or 13x18 cm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'v'">18x10 in. or 21x26 cm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'w'">9x9 in. or 23x23 cm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'x'">10x10 in. or 26x26 cm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'y'">17x7 in. or 18x18 cm.</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="mount">
          <xsl:choose>
            <xsl:when test="substring(.,9,1) = 'c'">cardboard</xsl:when>
            <xsl:when test="substring(.,9,1) = 'd'">glass</xsl:when>
            <xsl:when test="substring(.,9,1) = 'e'">synthetic</xsl:when>
            <xsl:when test="substring(.,9,1) = 'h'">metal</xsl:when>
            <xsl:when test="substring(.,9,1) = 'j'">metal</xsl:when>
            <xsl:when test="substring(.,9,1) = 'k'">synthetic</xsl:when>
            <xsl:when test="substring(.,9,1) = 'm'">mixed collection</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="mount2">
          <xsl:choose>
            <xsl:when test="substring(.,9,1) = 'j'">glass</xsl:when>
            <xsl:when test="substring(.,9,1) = 'k'">glass</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="mountUri">
          <xsl:choose>
            <xsl:when test="substring(.,9,1) = 'c'"><xsl:value-of select="concat($mmaterial,'crd')"/></xsl:when>
            <xsl:when test="substring(.,9,1) = 'd'"><xsl:value-of select="concat($mmaterial,'gls')"/></xsl:when>
            <xsl:when test="substring(.,9,1) = 'e'"><xsl:value-of select="concat($mmaterial,'syn')"/></xsl:when>
            <xsl:when test="substring(.,9,1) = 'h'"><xsl:value-of select="concat($mmaterial,'mtl')"/></xsl:when>
            <xsl:when test="substring(.,9,1) = 'j'"><xsl:value-of select="concat($mmaterial,'mtl')"/></xsl:when>
            <xsl:when test="substring(.,9,1) = 'k'"><xsl:value-of select="concat($mmaterial,'syn')"/></xsl:when>
            <xsl:when test="substring(.,9,1) = 'm'"><xsl:value-of select="concat($mmaterial,'mix')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="mountUri2">
          <xsl:choose>
            <xsl:when test="substring(.,9,1) = 'j'"><xsl:value-of select="concat($mmaterial,'gls')"/></xsl:when>
            <xsl:when test="substring(.,9,1) = 'k'"><xsl:value-of select="concat($mmaterial,'gls')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <xsl:if test="count(../marc:datafield[@tag='337']) = 0">
              <bf:media>
                <bf:Media>
                  <xsl:attribute name="rdf:about">http://id.loc.gov/vocabulary/mediaTypes/g</xsl:attribute>
                  <rdfs:label>projected</rdfs:label>
                </bf:Media>
              </bf:media>
            </xsl:if>
            <xsl:if test="count(../marc:datafield[@tag='338']) = 0">
              <xsl:if test="$carrier != ''">
                <bf:carrier>
                  <bf:Carrier>
                    <xsl:if test="$carrierUri != ''">
                      <xsl:attribute name="rdf:about"><xsl:value-of select="$carrierUri"/></xsl:attribute>
                    </xsl:if>
                    <rdfs:label><xsl:value-of select="$carrier"/></rdfs:label>
                  </bf:Carrier>
                </bf:carrier>
              </xsl:if>
            </xsl:if>
            <xsl:if test="$baseMaterial != ''">
              <bf:baseMaterial>
                <bf:BaseMaterial>
                  <xsl:if test="$baseMaterialUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$baseMaterialUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$baseMaterial"/></rdfs:label>
                </bf:BaseMaterial>
              </bf:baseMaterial>
            </xsl:if>
            <xsl:if test="$soundContent != ''">
              <bf:soundContent>
                <bf:SoundContent>
                  <xsl:if test="$soundContentURI != ''">
                      <xsl:attribute name="rdf:about"><xsl:value-of select="$soundContentURI"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$soundContent"/></rdfs:label>
                </bf:SoundContent>
              </bf:soundContent>
            </xsl:if>
            <xsl:if test="$recordingMedium != ''">
              <bf:soundCharacteristic>
                <bf:RecordingMedium>
                  <xsl:if test="$recordingMediumURI != ''">
                      <xsl:attribute name="rdf:about"><xsl:value-of select="$recordingMediumURI"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$recordingMedium"/></rdfs:label>
                </bf:RecordingMedium>
              </bf:soundCharacteristic>
            </xsl:if>
            <xsl:if test="count(../marc:datafield[@tag='300']/marc:subfield[@code='c']) = 0">
                <xsl:if test="$dimensions != ''">
                    <bf:dimensions><xsl:value-of select="$dimensions"/></bf:dimensions>
                </xsl:if>
            </xsl:if>
            <xsl:if test="$mount != ''">
              <bf:mount>
                <bf:Mount>
                  <xsl:if test="$mountUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$mountUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$mount"/></rdfs:label>
                </bf:Mount>
              </bf:mount>
            </xsl:if>
            <xsl:if test="$mount2 != ''">
              <bf:mount>
                <bf:Mount>
                  <xsl:if test="$mountUri2 != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$mountUri2"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$mount2"/></rdfs:label>
                </bf:Mount>
              </bf:mount>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- microform -->
      <xsl:when test="substring(.,1,1) = 'h'">
        <xsl:variable name="carrierUri">
          <xsl:choose>
            <xsl:when test="substring(.,2,1) = 'a'"><xsl:value-of select="concat($carriers,'ha')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'b'"><xsl:value-of select="concat($carriers,'hb')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'c'"><xsl:value-of select="concat($carriers,'hc')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'd'"><xsl:value-of select="concat($carriers,'hd')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'e'"><xsl:value-of select="concat($carriers,'he')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'f'"><xsl:value-of select="concat($carriers,'hf')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'g'"><xsl:value-of select="concat($carriers,'hg')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'h'"><xsl:value-of select="concat($carriers,'hh')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'j'"><xsl:value-of select="concat($carriers,'hj')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="polarity">
          <xsl:choose>
            <xsl:when test="substring(.,4,1) = 'a'">positive</xsl:when>
            <xsl:when test="substring(.,4,1) = 'b'">negative</xsl:when>
            <xsl:when test="substring(.,4,1) = 'm'">mixed polarity</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="polarityUri">
          <xsl:choose>
            <xsl:when test="substring(.,4,1) = 'a'"><xsl:value-of select="concat($mpolarity,'pos')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'b'"><xsl:value-of select="concat($mpolarity,'neg')"/></xsl:when>
            <xsl:when test="substring(.,4,1) = 'm'"><xsl:value-of select="concat($mpolarity,'mix')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="dimensions">
          <xsl:choose>
            <xsl:when test="substring(.,5,1) = 'a'">8 mm.</xsl:when>
            <xsl:when test="substring(.,5,1) = 'd'">16 mm.</xsl:when>
            <xsl:when test="substring(.,5,1) = 'f'">35 mm.</xsl:when>
            <xsl:when test="substring(.,5,1) = 'g'">70 mm.</xsl:when>
            <xsl:when test="substring(.,5,1) = 'h'">105 mm.</xsl:when>
            <xsl:when test="substring(.,5,1) = 'l'">13x5 in. or 8x13 cm.</xsl:when>
            <xsl:when test="substring(.,5,1) = 'm'">4x6 in. or 11x15 cm.</xsl:when>
            <xsl:when test="substring(.,5,1) = 'o'">6x9 in. or 16x23 cm.</xsl:when>
            <xsl:when test="substring(.,5,1) = 'p'">3 1/4 x 7 3/8 in. or 9x19 cm.</xsl:when>
          </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="reductionRatioRangeValue"><xsl:value-of select="substring(.,6,1)" /></xsl:variable>
        <xsl:variable name="reductionRatioRange">
          <xsl:value-of select="$codeMaps/maps/reductionRatioRange/*[name() = $reductionRatioRangeValue]" />
        </xsl:variable>
        <xsl:variable name="reductionRatioRangeUri">
          <xsl:value-of select="$codeMaps/maps/reductionRatioRange/*[name() = $reductionRatioRangeValue]/@href" />
        </xsl:variable>
        <xsl:variable name="reductionRatio">
          <xsl:choose>
            <xsl:when test="substring(.,7,3) = '|||'"/>
            <xsl:when test="substring(.,7,3) = '---'"/>
            <xsl:otherwise><xsl:value-of select="substring(.,7,3)"/></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="emulsion">
          <xsl:choose>
            <xsl:when test="substring(.,11,1) = 'a'">silver halide</xsl:when>
            <xsl:when test="substring(.,11,1) = 'b'">diazo</xsl:when>
            <xsl:when test="substring(.,11,1) = 'c'">vesicular</xsl:when>
            <xsl:when test="substring(.,11,1) = 'm'">mixed emulsion</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="emulsionUri">
          <xsl:choose>
            <xsl:when test="substring(.,11,1) = 'a'"><xsl:value-of select="concat($mmaterial,'slh')"/></xsl:when>
            <xsl:when test="substring(.,11,1) = 'b'"><xsl:value-of select="concat($mmaterial,'dia')"/></xsl:when>
            <xsl:when test="substring(.,11,1) = 'c'"><xsl:value-of select="concat($mmaterial,'ves')"/></xsl:when>
            <xsl:when test="substring(.,11,1) = 'm'"><xsl:value-of select="concat($mmaterial,'mix')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="generation">
          <xsl:choose>
            <xsl:when test="substring(.,12,1) = 'a'">first generation (master)</xsl:when>
            <xsl:when test="substring(.,12,1) = 'b'">printing master</xsl:when>
            <xsl:when test="substring(.,12,1) = 'c'">service copy</xsl:when>
            <xsl:when test="substring(.,12,1) = 'm'">mixed generation</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="generationURI">
          <xsl:choose>
            <xsl:when test="substring(.,12,1) = 'a'"><xsl:value-of select="concat($mgeneration,'firstgen')"/></xsl:when>
            <xsl:when test="substring(.,12,1) = 'b'"><xsl:value-of select="concat($mgeneration,'printmaster')"/></xsl:when>
            <xsl:when test="substring(.,12,1) = 'c'"><xsl:value-of select="concat($mgeneration,'servcopy')"/></xsl:when>
            <xsl:when test="substring(.,12,1) = 'm'"><xsl:value-of select="concat($mgeneration,'mixedgen')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="baseMaterial">
          <xsl:choose>
            <xsl:when test="substring(.,13,1) = 'a'">safety base</xsl:when>
            <xsl:when test="substring(.,13,1) = 'c'">acetate</xsl:when>
            <xsl:when test="substring(.,13,1) = 'd'">diacetate</xsl:when>
            <xsl:when test="substring(.,13,1) = 'p'">polyester</xsl:when>
            <xsl:when test="substring(.,13,1) = 'r'">safety base, mixed</xsl:when>
            <xsl:when test="substring(.,13,1) = 't'">triacetate</xsl:when>
            <xsl:when test="substring(.,13,1) = 'i'">nitrate base</xsl:when>
            <xsl:when test="substring(.,13,1) = 'm'">mixed nitrate and safety base</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="baseMaterialUri">
          <xsl:choose>
            <xsl:when test="substring(.,13,1) = 'a'"><xsl:value-of select="concat($mmaterial,'saf')"/></xsl:when>
            <xsl:when test="substring(.,13,1) = 'c'"><xsl:value-of select="concat($mmaterial,'ace')"/></xsl:when>
            <xsl:when test="substring(.,13,1) = 'd'"><xsl:value-of select="concat($mmaterial,'dia')"/></xsl:when>
            <xsl:when test="substring(.,13,1) = 'p'"><xsl:value-of select="concat($mmaterial,'pol')"/></xsl:when>
            <xsl:when test="substring(.,13,1) = 'r'"><xsl:value-of select="concat($mmaterial,'saf')"/></xsl:when>
            <xsl:when test="substring(.,13,1) = 't'"><xsl:value-of select="concat($mmaterial,'tri')"/></xsl:when>
            <xsl:when test="substring(.,13,1) = 'i'"><xsl:value-of select="concat($mmaterial,'nit')"/></xsl:when>
            <xsl:when test="substring(.,13,1) = 'm'"><xsl:value-of select="concat($mmaterial,'mix')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <xsl:if test="count(../marc:datafield[@tag='337']) = 0">
              <bf:media>
                <bf:Media>
                  <xsl:attribute name="rdf:about">http://id.loc.gov/vocabulary/mediaTypes/h</xsl:attribute>
                  <rdfs:label>microform</rdfs:label>
                </bf:Media>
              </bf:media>
            </xsl:if>
            <xsl:if test="count(../marc:datafield[@tag='338']) = 0">
              <xsl:if test="$carrierUri != ''">
                <bf:carrier>
                  <bf:Carrier>
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$carrierUri"/></xsl:attribute>
                  </bf:Carrier>
                </bf:carrier>
              </xsl:if>
            </xsl:if>
            <xsl:if test="$polarity != ''">
              <bf:polarity>
                <bf:Polarity>
                  <xsl:if test="$polarityUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$polarityUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$polarity"/></rdfs:label>
                </bf:Polarity>
              </bf:polarity>
            </xsl:if>
            <xsl:if test="count(../marc:datafield[@tag='300']/marc:subfield[@code='c']) = 0">
                <xsl:if test="$dimensions != ''">
                    <bf:dimensions><xsl:value-of select="$dimensions"/></bf:dimensions>
                </xsl:if>
            </xsl:if>
            <xsl:if test="$reductionRatioRange != ''">
              <bf:reductionRatio>
                <bf:ReductionRatio>
                  <xsl:if test="$reductionRatioRangeUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$reductionRatioRangeUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$reductionRatioRange"/></rdfs:label>
                </bf:ReductionRatio>
              </bf:reductionRatio>
            </xsl:if>
            <xsl:if test="$reductionRatio != ''">
              <bf:reductionRatio>
                <bf:ReductionRatio>
                    <rdfs:label><xsl:value-of select="$reductionRatio"/></rdfs:label>
                </bf:ReductionRatio>
              </bf:reductionRatio>
            </xsl:if>
            <xsl:if test="$emulsion != ''">
              <bf:emulsion>
                <bf:Emulsion>
                  <xsl:if test="$emulsionUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$emulsionUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$emulsion"/></rdfs:label>
                </bf:Emulsion>
              </bf:emulsion>
            </xsl:if>
            <xsl:if test="$generation != ''">
              <bf:generation>
                <bf:Generation>
                  <xsl:if test="$generationURI != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$generationURI"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$generation"/></rdfs:label>
                </bf:Generation>
              </bf:generation>
            </xsl:if>
            <xsl:if test="$baseMaterial != ''">
              <bf:baseMaterial>
                <bf:BaseMaterial>
                  <xsl:if test="$baseMaterialUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$baseMaterialUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$baseMaterial"/></rdfs:label>
                </bf:BaseMaterial>
              </bf:baseMaterial>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- nonprojected graphic -->
      <xsl:when test="substring(.,1,1) = 'k'">
        <xsl:variable name="baseMaterial">
          <xsl:choose>
            <xsl:when test="substring(.,5,1) = 'a'">canvas</xsl:when>
            <xsl:when test="substring(.,5,1) = 'b'">bristol board</xsl:when>
            <xsl:when test="substring(.,5,1) = 'c'">cardboard</xsl:when>
            <xsl:when test="substring(.,5,1) = 'd'">glass</xsl:when>
            <xsl:when test="substring(.,5,1) = 'e'">synthetic</xsl:when>
            <xsl:when test="substring(.,5,1) = 'f'">skin</xsl:when>
            <xsl:when test="substring(.,5,1) = 'g'">textile</xsl:when>
            <xsl:when test="substring(.,5,1) = 'h'">metal</xsl:when>
            <xsl:when test="substring(.,5,1) = 'i'">plastic</xsl:when>
            <xsl:when test="substring(.,5,1) = 'l'">vinyl</xsl:when>
            <xsl:when test="substring(.,5,1) = 'm'">mixed collection</xsl:when>
            <xsl:when test="substring(.,5,1) = 'n'">vellum</xsl:when>
            <xsl:when test="substring(.,5,1) = 'o'">paper</xsl:when>
            <xsl:when test="substring(.,5,1) = 'p'">plaster</xsl:when>
            <xsl:when test="substring(.,5,1) = 'q'">hardboard</xsl:when>
            <xsl:when test="substring(.,5,1) = 'r'">porcelain</xsl:when>
            <xsl:when test="substring(.,5,1) = 's'">stone</xsl:when>
            <xsl:when test="substring(.,5,1) = 't'">wood</xsl:when>
            <xsl:when test="substring(.,5,1) = 'v'">leather</xsl:when>
            <xsl:when test="substring(.,5,1) = 'w'">parchment</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="baseMaterialUri">
          <xsl:choose>
            <xsl:when test="substring(.,5,1) = 'a'"><xsl:value-of select="concat($mmaterial,'can')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'b'"><xsl:value-of select="concat($mmaterial,'brb')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'c'"><xsl:value-of select="concat($mmaterial,'crd')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'd'"><xsl:value-of select="concat($mmaterial,'gla')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'e'"><xsl:value-of select="concat($mmaterial,'syn')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'f'"><xsl:value-of select="concat($mmaterial,'ski')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'g'"><xsl:value-of select="concat($mmaterial,'tex')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'h'"><xsl:value-of select="concat($mmaterial,'mtl')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'i'"><xsl:value-of select="concat($mmaterial,'pla')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'l'"><xsl:value-of select="concat($mmaterial,'vny')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'm'"><xsl:value-of select="concat($mmaterial,'mix')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'n'"><xsl:value-of select="concat($mmaterial,'vel')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'o'"><xsl:value-of select="concat($mmaterial,'pap')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'p'"><xsl:value-of select="concat($mmaterial,'plt')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'q'"><xsl:value-of select="concat($mmaterial,'hdb')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'r'"><xsl:value-of select="concat($mmaterial,'por')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 's'"><xsl:value-of select="concat($mmaterial,'sto')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 't'"><xsl:value-of select="concat($mmaterial,'wod')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'v'"><xsl:value-of select="concat($mmaterial,'lea')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'w'"><xsl:value-of select="concat($mmaterial,'par')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="mount">
          <xsl:choose>
            <xsl:when test="substring(.,6,1) = 'a'">canvas</xsl:when>
            <xsl:when test="substring(.,6,1) = 'b'">bristol board</xsl:when>
            <xsl:when test="substring(.,6,1) = 'c'">cardboard</xsl:when>
            <xsl:when test="substring(.,6,1) = 'd'">glass</xsl:when>
            <xsl:when test="substring(.,6,1) = 'e'">synthetic</xsl:when>
            <xsl:when test="substring(.,6,1) = 'f'">skin</xsl:when>
            <xsl:when test="substring(.,6,1) = 'g'">textile</xsl:when>
            <xsl:when test="substring(.,6,1) = 'h'">metal</xsl:when>
            <xsl:when test="substring(.,6,1) = 'i'">plastic</xsl:when>
            <xsl:when test="substring(.,6,1) = 'l'">vinyl</xsl:when>
            <xsl:when test="substring(.,6,1) = 'm'">mixed collection</xsl:when>
            <xsl:when test="substring(.,6,1) = 'n'">vellum</xsl:when>
            <xsl:when test="substring(.,6,1) = 'o'">paper</xsl:when>
            <xsl:when test="substring(.,6,1) = 'p'">plaster</xsl:when>
            <xsl:when test="substring(.,6,1) = 'q'">hardboard</xsl:when>
            <xsl:when test="substring(.,6,1) = 'r'">porcelain</xsl:when>
            <xsl:when test="substring(.,6,1) = 's'">stone</xsl:when>
            <xsl:when test="substring(.,6,1) = 't'">wood</xsl:when>
            <xsl:when test="substring(.,6,1) = 'v'">leather</xsl:when>
            <xsl:when test="substring(.,6,1) = 'w'">parchment</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="mountUri">
          <xsl:choose>
            <xsl:when test="substring(.,6,1) = 'a'"><xsl:value-of select="concat($mmaterial,'can')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'b'"><xsl:value-of select="concat($mmaterial,'brb')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'c'"><xsl:value-of select="concat($mmaterial,'crd')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'd'"><xsl:value-of select="concat($mmaterial,'gla')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'e'"><xsl:value-of select="concat($mmaterial,'syn')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'f'"><xsl:value-of select="concat($mmaterial,'ski')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'g'"><xsl:value-of select="concat($mmaterial,'tex')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'h'"><xsl:value-of select="concat($mmaterial,'mtl')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'i'"><xsl:value-of select="concat($mmaterial,'pla')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'l'"><xsl:value-of select="concat($mmaterial,'vny')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'm'"><xsl:value-of select="concat($mmaterial,'mix')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'n'"><xsl:value-of select="concat($mmaterial,'vel')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'o'"><xsl:value-of select="concat($mmaterial,'pap')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'p'"><xsl:value-of select="concat($mmaterial,'plt')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'q'"><xsl:value-of select="concat($mmaterial,'hdb')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'r'"><xsl:value-of select="concat($mmaterial,'por')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 's'"><xsl:value-of select="concat($mmaterial,'sto')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 't'"><xsl:value-of select="concat($mmaterial,'wod')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'v'"><xsl:value-of select="concat($mmaterial,'lea')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'w'"><xsl:value-of select="concat($mmaterial,'par')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <xsl:if test="$baseMaterial != ''">
              <bf:baseMaterial>
                <bf:BaseMaterial>
                  <xsl:if test="$baseMaterialUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$baseMaterialUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$baseMaterial"/></rdfs:label>
                </bf:BaseMaterial>
              </bf:baseMaterial>
            </xsl:if>
            <xsl:if test="$mount != ''">
              <bf:mount>
                <bf:Mount>
                  <xsl:if test="$mountUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$mountUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$mount"/></rdfs:label>
                </bf:Mount>
              </bf:mount>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- motion picture -->
      <xsl:when test="substring(.,1,1) = 'm'">
        <xsl:variable name="carrier">
          <xsl:choose>
            <xsl:when test="substring(.,2,1) = 'c'">film cartridge</xsl:when>
            <xsl:when test="substring(.,2,1) = 'f'">film cassette</xsl:when>
            <xsl:when test="substring(.,2,1) = 'o'">film roll</xsl:when>
            <xsl:when test="substring(.,2,1) = 'r'">film reel</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="carrierUri">
          <xsl:choose>
            <xsl:when test="substring(.,2,1) = 'c'"><xsl:value-of select="concat($carriers,'mc')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'f'"><xsl:value-of select="concat($carriers,'mf')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'o'"><xsl:value-of select="concat($carriers,'mo')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'r'"><xsl:value-of select="concat($carriers,'mr')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="vPresentationFormat">
          <xsl:choose>
            <xsl:when test="substring(.,5,1) = 'a'">standard sound aperture (reduced frame)</xsl:when>
            <xsl:when test="substring(.,5,1) = 'c'">3D</xsl:when>
            <xsl:when test="substring(.,5,1) = 'f'">standard silent aperture (full frame)</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="vPresentationFormatURI">
          <xsl:choose>
            <xsl:when test="substring(.,5,1) = 'a'"><xsl:value-of select="concat($mpresformat,'sound')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'c'"><xsl:value-of select="concat($mpresformat,'3d')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'f'"><xsl:value-of select="concat($mpresformat,'silent')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="soundContent">
          <xsl:choose>
            <xsl:when test="substring(.,6,1) = ' '">silent</xsl:when>
            <xsl:when test="substring(.,6,1) = 'a'">sound</xsl:when>
            <xsl:when test="substring(.,6,1) = 'b'">sound</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="soundContentURI">
          <xsl:choose>
            <xsl:when test="substring(.,6,1) = ' '"><xsl:value-of select="concat($msoundcontent,'silent')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'a'"><xsl:value-of select="concat($msoundcontent,'sound')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'b'"><xsl:value-of select="concat($msoundcontent,'sound')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="recordingMedium">
          <xsl:choose>
            <xsl:when test="substring(.,7,1) = 'a'">optical sound track on motion picture film</xsl:when>
            <xsl:when test="substring(.,7,1) = 'b'">magnetic sound track on motion picture film</xsl:when>
            <xsl:when test="substring(.,7,1) = 'c'">magnetic audio tape in cartridge</xsl:when>
            <xsl:when test="substring(.,7,1) = 'd'">sound disc</xsl:when>
            <xsl:when test="substring(.,7,1) = 'e'">magnetic audio tape on reel</xsl:when>
            <xsl:when test="substring(.,7,1) = 'f'">magnetic audio tape in cassette</xsl:when>
            <xsl:when test="substring(.,7,1) = 'g'">optical and magnetic sound track on motion picture film</xsl:when>
            <xsl:when test="substring(.,7,1) = 'h'">videotape</xsl:when>
            <xsl:when test="substring(.,7,1) = 'i'">videodisc</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="recordingMediumURI">
          <xsl:choose>
            <xsl:when test="substring(.,7,1) = 'a'"><xsl:value-of select="concat($mrecmedium,'opt')"/></xsl:when>
            <xsl:when test="substring(.,7,1) = 'b'"><xsl:value-of select="concat($mrecmedium,'mag')"/></xsl:when>
            <xsl:when test="substring(.,7,1) = 'c'"><xsl:value-of select="concat($mrecmedium,'mag')"/></xsl:when>
            <xsl:when test="substring(.,7,1) = 'd'"><xsl:value-of select="concat($mrecmedium,'magopt')"/></xsl:when>
            <xsl:when test="substring(.,7,1) = 'e'"><xsl:value-of select="concat($mrecmedium,'mag')"/></xsl:when>
            <xsl:when test="substring(.,7,1) = 'f'"><xsl:value-of select="concat($mrecmedium,'mag')"/></xsl:when>
            <xsl:when test="substring(.,7,1) = 'g'"><xsl:value-of select="concat($mrecmedium,'magopt')"/></xsl:when>
            <xsl:when test="substring(.,7,1) = 'h'"><xsl:value-of select="concat($mrecmedium,'mag')"/></xsl:when>
            <xsl:when test="substring(.,7,1) = 'i'"><xsl:value-of select="concat($mrecmedium,'opt')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="dimensions">
          <xsl:choose>
            <xsl:when test="substring(.,8,1) = 'a'">8 mm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'b'">super 8 mm., single 8 mm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'c'">9.5 mm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'd'">16 mm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'e'">28 mm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'f'">35 mm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'g'">70 mm.</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="playbackChannels">
          <xsl:choose>
            <xsl:when test="substring(.,9,1) = 'k'">mixed</xsl:when>
            <xsl:when test="substring(.,9,1) = 'm'">mono</xsl:when>
            <xsl:when test="substring(.,9,1) = 'q'">surround</xsl:when>
            <xsl:when test="substring(.,9,1) = 's'">stereo</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="playbackUri">
          <xsl:choose>
            <xsl:when test="substring(.,9,1) = 'k'"><xsl:value-of select="concat($mplayback,'mix')"/></xsl:when>
            <xsl:when test="substring(.,9,1) = 'm'"><xsl:value-of select="concat($mplayback,'mon')"/></xsl:when>
            <xsl:when test="substring(.,9,1) = 'q'"><xsl:value-of select="concat($mplayback,'mul')"/></xsl:when>
            <xsl:when test="substring(.,9,1) = 's'"><xsl:value-of select="concat($mplayback,'ste')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="polarity">
          <xsl:choose>
            <xsl:when test="substring(.,11,1) = 'a'">positive</xsl:when>
            <xsl:when test="substring(.,11,1) = 'b'">negative</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="polarityUri">
          <xsl:choose>
            <xsl:when test="substring(.,11,1) = 'a'"><xsl:value-of select="concat($mpolarity,'pos')"/></xsl:when>
            <xsl:when test="substring(.,11,1) = 'b'"><xsl:value-of select="concat($mpolarity,'neg')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="generation">
          <xsl:choose>
            <xsl:when test="substring(.,12,1) = 'd'">duplicate</xsl:when>
            <xsl:when test="substring(.,12,1) = 'e'">master</xsl:when>
            <xsl:when test="substring(.,12,1) = 'o'">original</xsl:when>
            <xsl:when test="substring(.,12,1) = 'r'">reference print, viewing copy</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="generationURI">
          <xsl:choose>
            <xsl:when test="substring(.,12,1) = 'd'"><xsl:value-of select="concat($mgeneration,'dupe')"/></xsl:when>
            <xsl:when test="substring(.,12,1) = 'e'"><xsl:value-of select="concat($mgeneration,'master')"/></xsl:when>
            <xsl:when test="substring(.,12,1) = 'o'"><xsl:value-of select="concat($mgeneration,'original')"/></xsl:when>
            <xsl:when test="substring(.,12,1) = 'r'"><xsl:value-of select="concat($mgeneration,'viewcopy')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="baseMaterial">
          <xsl:choose>
            <xsl:when test="substring(.,13,1) = 'a'">safety base</xsl:when>
            <xsl:when test="substring(.,13,1) = 'c'">acetate</xsl:when>
            <xsl:when test="substring(.,13,1) = 'd'">diacetate</xsl:when>
            <xsl:when test="substring(.,13,1) = 'p'">polyester</xsl:when>
            <xsl:when test="substring(.,13,1) = 'r'">safety base</xsl:when>
            <xsl:when test="substring(.,13,1) = 't'">triacetate</xsl:when>
            <xsl:when test="substring(.,13,1) = 'i'">nitrate base</xsl:when>
            <xsl:when test="substring(.,13,1) = 'm'">mixed nitrate and safety base</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="baseMaterialUri">
          <xsl:choose>
            <xsl:when test="substring(.,13,1) = 'a'"><xsl:value-of select="concat($mmaterial,'saf')"/></xsl:when>
            <xsl:when test="substring(.,13,1) = 'c'"><xsl:value-of select="concat($mmaterial,'ace')"/></xsl:when>
            <xsl:when test="substring(.,13,1) = 'd'"><xsl:value-of select="concat($mmaterial,'dia')"/></xsl:when>
            <xsl:when test="substring(.,13,1) = 'p'"><xsl:value-of select="concat($mmaterial,'pol')"/></xsl:when>
            <xsl:when test="substring(.,13,1) = 'r'"><xsl:value-of select="concat($mmaterial,'saf')"/></xsl:when>
            <xsl:when test="substring(.,13,1) = 't'"><xsl:value-of select="concat($mmaterial,'tri')"/></xsl:when>
            <xsl:when test="substring(.,13,1) = 'i'"><xsl:value-of select="concat($mmaterial,'nit')"/></xsl:when>
            <xsl:when test="substring(.,13,1) = 'm'"><xsl:value-of select="concat($mmaterial,'mix')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="completeness">
          <xsl:choose>
            <xsl:when test="substring(.,17,1) = 'c'">complete</xsl:when>
            <xsl:when test="substring(.,17,1) = 'i'">incomplete</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <xsl:if test="count(../marc:datafield[@tag='337']) = 0">
              <bf:media>
                <bf:Media>
                  <xsl:attribute name="rdf:about">http://id.loc.gov/vocabulary/mediaTypes/g</xsl:attribute>
                  <rdfs:label>projected</rdfs:label>
                </bf:Media>
              </bf:media>
            </xsl:if>
            <xsl:if test="count(../marc:datafield[@tag='338']) = 0">
              <xsl:if test="$carrier != ''">
                <bf:carrier>
                  <bf:Carrier>
                    <xsl:if test="$carrierUri != ''">
                      <xsl:attribute name="rdf:about"><xsl:value-of select="$carrierUri"/></xsl:attribute>
                    </xsl:if>
                    <rdfs:label><xsl:value-of select="$carrier"/></rdfs:label>
                  </bf:Carrier>
                </bf:carrier>
              </xsl:if>
            </xsl:if>
            <xsl:if test="$vPresentationFormat != ''">
              <bf:projectionCharacteristic>
                <bf:PresentationFormat>
                  <xsl:if test="$vPresentationFormatURI != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$vPresentationFormatURI"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$vPresentationFormat"/></rdfs:label>
                </bf:PresentationFormat>
              </bf:projectionCharacteristic>
            </xsl:if>
            <xsl:if test="$soundContent != ''">
              <bf:soundContent>
                <bf:SoundContent>
                  <xsl:if test="$soundContentURI != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$soundContentURI"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$soundContent"/></rdfs:label>
                </bf:SoundContent>
              </bf:soundContent>
            </xsl:if>
            <xsl:if test="$recordingMedium != ''">
              <bf:soundCharacteristic>
                <bf:RecordingMedium>
                  <xsl:if test="$recordingMediumURI != ''">
                      <xsl:attribute name="rdf:about"><xsl:value-of select="$recordingMediumURI"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$recordingMedium"/></rdfs:label>
                </bf:RecordingMedium>
              </bf:soundCharacteristic>
            </xsl:if>
            <xsl:if test="count(../marc:datafield[@tag='300']/marc:subfield[@code='c']) = 0">
                <xsl:if test="$dimensions != ''">
                    <bf:dimensions><xsl:value-of select="$dimensions"/></bf:dimensions>
                </xsl:if>
            </xsl:if>
            <xsl:if test="$playbackChannels != ''">
              <bf:soundCharacteristic>
                <bf:PlaybackChannels>
                  <xsl:if test="$playbackUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$playbackUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$playbackChannels"/></rdfs:label>
                </bf:PlaybackChannels>
              </bf:soundCharacteristic>
            </xsl:if>
            <xsl:if test="$polarity != ''">
              <bf:polarity>
                <bf:Polarity>
                  <xsl:if test="$polarityUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$polarityUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$polarity"/></rdfs:label>
                </bf:Polarity>
              </bf:polarity>
            </xsl:if>
            <xsl:if test="$generation != ''">
              <bf:generation>
                <bf:Generation>
                  <xsl:if test="$generationURI != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$generationURI"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$generation"/></rdfs:label>
                </bf:Generation>
              </bf:generation>
            </xsl:if>
            <xsl:if test="$baseMaterial != ''">
              <bf:baseMaterial>
                <bf:BaseMaterial>
                  <xsl:if test="$baseMaterialUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$baseMaterialUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$baseMaterial"/></rdfs:label>
                </bf:BaseMaterial>
              </bf:baseMaterial>
            </xsl:if>
            <xsl:if test="$completeness != ''">
              <bf:note>
                <bf:Note>
                  <bf:noteType>completeness</bf:noteType>
                  <rdfs:label><xsl:value-of select="$completeness"/></rdfs:label>
                </bf:Note>
              </bf:note>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- sound recording -->
      <xsl:when test="substring(.,1,1) = 's'">
        <xsl:variable name="carrier">
          <xsl:choose>
            <xsl:when test="substring(.,2,1) = 'd'">sound disc</xsl:when>
            <xsl:when test="substring(.,2,1) = 'e'">cylinder</xsl:when>
            <xsl:when test="substring(.,2,1) = 'g'">sound cartridge</xsl:when>
            <xsl:when test="substring(.,2,1) = 'i'">sound-track film</xsl:when>
            <xsl:when test="substring(.,2,1) = 'q'">roll</xsl:when>
            <xsl:when test="substring(.,2,1) = 'r'">remote</xsl:when>
            <xsl:when test="substring(.,2,1) = 's'">sound cassette</xsl:when>
            <xsl:when test="substring(.,2,1) = 't'">sound-tape reel</xsl:when>
            <xsl:when test="substring(.,2,1) = 'w'">wire recording</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="carrierUri">
          <xsl:choose>
            <xsl:when test="substring(.,2,1) = 'd'"><xsl:value-of select="concat($carriers,'sd')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'e'"><xsl:value-of select="concat($carriers,'se')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'g'"><xsl:value-of select="concat($carriers,'sg')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'i'"><xsl:value-of select="concat($carriers,'si')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'q'"><xsl:value-of select="concat($carriers,'sq')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'r'"><xsl:value-of select="concat($carriers,'cr')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 's'"><xsl:value-of select="concat($carriers,'sg')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 't'"><xsl:value-of select="concat($carriers,'st')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'w'"><xsl:value-of select="concat($carriers,'sw')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="playingSpeedValue"><xsl:value-of select="substring(.,4,1)" /></xsl:variable>
        <xsl:variable name="playingSpeed">
          <xsl:value-of select="$codeMaps/maps/playbackSpeed/*[name() = $playingSpeedValue]" />
        </xsl:variable>
        <xsl:variable name="playingSpeedUri">
            <xsl:value-of select="$codeMaps/maps/playbackSpeed/*[name() = $playingSpeedValue]/@href" />
        </xsl:variable>

        <xsl:variable name="playbackChannels">
          <xsl:choose>
            <xsl:when test="substring(.,5,1) = 'm'">mono</xsl:when>
            <xsl:when test="substring(.,5,1) = 'q'">surround</xsl:when>
            <xsl:when test="substring(.,5,1) = 's'">stereo</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="playbackUri">
          <xsl:choose>
            <xsl:when test="substring(.,5,1) = 'm'"><xsl:value-of select="concat($mplayback,'mon')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'q'"><xsl:value-of select="concat($mplayback,'mul')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 's'"><xsl:value-of select="concat($mplayback,'ste')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="grooveCharacteristic">
          <xsl:choose>
            <xsl:when test="substring(.,6,1) = 'm'">
              <xsl:choose>
                <xsl:when test="contains('abce', substring(.,4,1))">microgroove</xsl:when>
                <xsl:when test="substring(.,4,1) = 'i'">fine pitch</xsl:when>
                <xsl:otherwise>microgroove</xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:when test="substring(.,6,1) = 's'">
              <xsl:choose>
                <xsl:when test="substring(.,4,1) = 'd'">coarse groove</xsl:when>
                <xsl:when test="substring(.,4,1) = 'h'">standard pitch</xsl:when>
                <xsl:otherwise>coarse groove</xsl:otherwise>
              </xsl:choose>
            </xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="grooveCharacteristicURI">
          <xsl:choose>
            <xsl:when test="substring(.,6,1) = 'm'">
              <xsl:choose>
                <xsl:when test="contains('abce', substring(.,4,1))"><xsl:value-of select="concat($mgroove,'micro')"/></xsl:when>
                <xsl:when test="substring(.,4,1) = 'i'"><xsl:value-of select="concat($mgroove,'finepitch')"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="concat($mgroove,'micro')"/></xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:when test="substring(.,6,1) = 's'">
              <xsl:choose>
                <xsl:when test="substring(.,4,1) = 'd'"><xsl:value-of select="concat($mgroove,'coarse')"/></xsl:when>
                <xsl:when test="substring(.,4,1) = 'h'"><xsl:value-of select="concat($mgroove,'stanpitch')"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="concat($mgroove,'coarse')"/></xsl:otherwise>
              </xsl:choose>
            </xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="dimensions">
          <xsl:choose>
            <xsl:when test="substring(.,7,1) = 'a'">3 in.</xsl:when>
            <xsl:when test="substring(.,7,1) = 'b'">5 in.</xsl:when>
            <xsl:when test="substring(.,7,1) = 'c'">7 in.</xsl:when>
            <xsl:when test="substring(.,7,1) = 'd'">10 in.</xsl:when>
            <xsl:when test="substring(.,7,1) = 'e'">12 in.</xsl:when>
            <xsl:when test="substring(.,7,1) = 'f'">16 in.</xsl:when>
            <xsl:when test="substring(.,7,1) = 'g'">4 3/4 in. or 12 cm.</xsl:when>
            <xsl:when test="substring(.,7,1) = 'j'">3 7/8 x 2 1/2 in.</xsl:when>
            <xsl:when test="substring(.,7,1) = 'o'">5 1/4 x 3 7/8 in.</xsl:when>
            <xsl:when test="substring(.,7,1) = 's'">2 3/4 x 4 in.</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="tapeWidth">
          <xsl:choose>
            <xsl:when test="substring(.,8,1) = 'l'">1/8 in. tape width</xsl:when>
            <xsl:when test="substring(.,8,1) = 'm'">1/4 in. tape width</xsl:when>
            <xsl:when test="substring(.,8,1) = 'o'">1/2 in. tape width</xsl:when>
            <xsl:when test="substring(.,8,1) = 'p'">1 in. tape width</xsl:when>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="tapeConfigValue"><xsl:value-of select="substring(.,9,1)" /></xsl:variable>
        <xsl:variable name="tapeConfig">
          <xsl:value-of select="$codeMaps/maps/tapeConfig/*[name() = $tapeConfigValue]" />
        </xsl:variable>
        <xsl:variable name="tapeConfigUri">
            <xsl:value-of select="$codeMaps/maps/tapeConfig/*[name() = $tapeConfigValue]/@href" />
        </xsl:variable>

        <xsl:variable name="generation">
          <xsl:choose>
            <xsl:when test="substring(.,10,1) = 'a'">master tape</xsl:when>
            <xsl:when test="substring(.,10,1) = 'b'">tape duplication master</xsl:when>
            <xsl:when test="substring(.,10,1) = 'd'">disc master (negative)</xsl:when>
            <xsl:when test="substring(.,10,1) = 'r'">mother (positive)</xsl:when>
            <xsl:when test="substring(.,10,1) = 's'">stamper (negative)</xsl:when>
            <xsl:when test="substring(.,10,1) = 't'">test pressing</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="generationURI">
          <xsl:choose>
            <xsl:when test="substring(.,10,1) = 'a'"><xsl:value-of select="concat($mgeneration,'master')"/></xsl:when>
            <xsl:when test="substring(.,10,1) = 'b'"><xsl:value-of select="concat($mgeneration,'tapedupe')"/></xsl:when>
            <xsl:when test="substring(.,10,1) = 'd'"><xsl:value-of select="concat($mgeneration,'discmaster')"/></xsl:when>
            <xsl:when test="substring(.,10,1) = 'r'"><xsl:value-of select="concat($mgeneration,'mother')"/></xsl:when>
            <xsl:when test="substring(.,10,1) = 's'"><xsl:value-of select="concat($mgeneration,'stamper')"/></xsl:when>
            <xsl:when test="substring(.,10,1) = 't'"><xsl:value-of select="concat($mgeneration,'testpress')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="baseMaterial">
          <xsl:choose>
            <xsl:when test="substring(.,11,1) = 'b'">cellulose nitrate</xsl:when>
            <xsl:when test="substring(.,11,1) = 'c'">acetate tape</xsl:when>
            <xsl:when test="substring(.,11,1) = 'g'">glass</xsl:when>
            <xsl:when test="substring(.,11,1) = 'i'">aluminum</xsl:when>
            <xsl:when test="substring(.,11,1) = 'r'">paper</xsl:when>
            <xsl:when test="substring(.,11,1) = 'l'">metal</xsl:when>
            <xsl:when test="substring(.,11,1) = 'm'">plastic</xsl:when>
            <xsl:when test="substring(.,11,1) = 'p'">plastic</xsl:when>
            <xsl:when test="substring(.,11,1) = 's'">shellac</xsl:when>
            <xsl:when test="substring(.,11,1) = 'w'">wax</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="baseMaterialUri">
          <xsl:choose>
            <xsl:when test="substring(.,11,1) = 'b'"><xsl:value-of select="concat($mmaterial,'lac')"/></xsl:when>
            <xsl:when test="substring(.,11,1) = 'c'"><xsl:value-of select="concat($mmaterial,'ace')"/></xsl:when>
            <xsl:when test="substring(.,11,1) = 'g'"><xsl:value-of select="concat($mmaterial,'gla')"/></xsl:when>
            <xsl:when test="substring(.,11,1) = 'i'"><xsl:value-of select="concat($mmaterial,'alu')"/></xsl:when>
            <xsl:when test="substring(.,11,1) = 'r'"><xsl:value-of select="concat($mmaterial,'pap')"/></xsl:when>
            <xsl:when test="substring(.,11,1) = 'l'"><xsl:value-of select="concat($mmaterial,'mtl')"/></xsl:when>
            <xsl:when test="substring(.,11,1) = 'm'"><xsl:value-of select="concat($mmaterial,'pla')"/></xsl:when>
            <xsl:when test="substring(.,11,1) = 'p'"><xsl:value-of select="concat($mmaterial,'pla')"/></xsl:when>
            <xsl:when test="substring(.,11,1) = 's'"><xsl:value-of select="concat($mmaterial,'she')"/></xsl:when>
            <xsl:when test="substring(.,11,1) = 'w'"><xsl:value-of select="concat($mmaterial,'wax')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="emulsion">
          <xsl:choose>
            <xsl:when test="substring(.,11,1) = 'a'">lacquer coating</xsl:when>
            <xsl:when test="substring(.,11,1) = 'c'">ferrous oxide</xsl:when>
            <xsl:when test="substring(.,11,1) = 'g'">lacquer</xsl:when>
            <xsl:when test="substring(.,11,1) = 'i'">lacquer</xsl:when>
            <xsl:when test="substring(.,11,1) = 'm'">metal</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="emulsionUri">
          <xsl:choose>
            <xsl:when test="substring(.,11,1) = 'a'"><xsl:value-of select="concat($mmaterial,'lac')"/></xsl:when>
            <xsl:when test="substring(.,11,1) = 'c'"><xsl:value-of select="concat($mmaterial,'fer')"/></xsl:when>
            <xsl:when test="substring(.,11,1) = 'g'"><xsl:value-of select="concat($mmaterial,'lac')"/></xsl:when>
            <xsl:when test="substring(.,11,1) = 'i'"><xsl:value-of select="concat($mmaterial,'lac')"/></xsl:when>
            <xsl:when test="substring(.,11,1) = 'm'"><xsl:value-of select="concat($mmaterial,'mtl')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="cutting">
          <xsl:choose>
            <xsl:when test="substring(.,12,1) = 'h'">vertical cutting</xsl:when>
            <xsl:when test="substring(.,12,1) = 'l'">lateral or combined cutting</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="cuttingURI">
          <xsl:choose>
            <xsl:when test="substring(.,12,1) = 'h'"><xsl:value-of select="concat($mgroove,'vertical')"/></xsl:when>
            <xsl:when test="substring(.,12,1) = 'l'"><xsl:value-of select="concat($mgroove,'lateral')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="playbackCharacteristic">
          <xsl:choose>
            <xsl:when test="substring(.,13,1) = 'a'">NAB standard</xsl:when>
            <xsl:when test="substring(.,13,1) = 'b'">CCIR standard</xsl:when>
            <xsl:when test="substring(.,13,1) = 'c'">Dolby-B encoded</xsl:when>
            <xsl:when test="substring(.,13,1) = 'd'">dbx encoded</xsl:when>
            <xsl:when test="substring(.,13,1) = 'f'">Dolby-A encoded</xsl:when>
            <xsl:when test="substring(.,13,1) = 'g'">Dolby-C encoded</xsl:when>
            <xsl:when test="substring(.,13,1) = 'h'">CX encoded</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="playbackCharacteristicURI">
          <xsl:choose>
            <xsl:when test="substring(.,13,1) = 'a'"><xsl:value-of select="concat($mspecplayback,'nab')"/></xsl:when>
            <xsl:when test="substring(.,13,1) = 'b'"><xsl:value-of select="concat($mspecplayback,'ccir')"/></xsl:when>
            <xsl:when test="substring(.,13,1) = 'c'"><xsl:value-of select="concat($mspecplayback,'dolbyb')"/></xsl:when>
            <xsl:when test="substring(.,13,1) = 'd'"><xsl:value-of select="concat($mspecplayback,'dbx')"/></xsl:when>
            <xsl:when test="substring(.,13,1) = 'f'"><xsl:value-of select="concat($mspecplayback,'dolbya')"/></xsl:when>
            <xsl:when test="substring(.,13,1) = 'g'"><xsl:value-of select="concat($mspecplayback,'dolbyc')"/></xsl:when>
            <xsl:when test="substring(.,13,1) = 'h'"><xsl:value-of select="concat($mspecplayback,'cx')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="recordingMethod">
          <xsl:choose>
            <xsl:when test="substring(.,13,1) = 'e'">digital recording</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="recordingMethodURI">
          <xsl:choose>
            <xsl:when test="substring(.,13,1) = 'e'"><xsl:value-of select="concat($mrectype,'digital')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="captureStorageValue"><xsl:value-of select="substring(.,14,1)" /></xsl:variable>
        <xsl:variable name="captureStorage">
          <xsl:value-of select="$codeMaps/maps/captureStorage/*[name() = $captureStorageValue]" />
        </xsl:variable>
        <xsl:variable name="captureStorageUri">
            <xsl:value-of select="$codeMaps/maps/captureStorage/*[name() = $captureStorageValue]/@href" />
        </xsl:variable>
        
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <xsl:if test="count(../marc:datafield[@tag='337']) = 0">
              <bf:media>
                <bf:Media>
                  <xsl:attribute name="rdf:about">http://id.loc.gov/vocabulary/mediaTypes/s</xsl:attribute>
                  <rdfs:label>audio</rdfs:label>
                </bf:Media>
              </bf:media>
            </xsl:if>
            <xsl:if test="count(../marc:datafield[@tag='338']) = 0">
              <xsl:if test="$carrier != ''">
                <bf:carrier>
                  <bf:Carrier>
                    <xsl:if test="$carrierUri != ''">
                      <xsl:attribute name="rdf:about"><xsl:value-of select="$carrierUri"/></xsl:attribute>
                    </xsl:if>
                    <rdfs:label><xsl:value-of select="$carrier"/></rdfs:label>
                  </bf:Carrier>
                </bf:carrier>
              </xsl:if>
            </xsl:if>
            <xsl:if test="$playingSpeed != ''">
              <bf:soundCharacteristic>
                <bf:PlayingSpeed>
                  <xsl:if test="$playingSpeedUri != ''">
                      <xsl:attribute name="rdf:about"><xsl:value-of select="$playingSpeedUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$playingSpeed"/></rdfs:label>
                </bf:PlayingSpeed>
              </bf:soundCharacteristic>
            </xsl:if>
            <xsl:if test="$playbackChannels != ''">
              <bf:soundCharacteristic>
                <bf:PlaybackChannels>
                  <xsl:if test="$playbackUri != ''">
                      <xsl:attribute name="rdf:about"><xsl:value-of select="$playbackUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$playbackChannels"/></rdfs:label>
                </bf:PlaybackChannels>
              </bf:soundCharacteristic>
            </xsl:if>
            <xsl:if test="$grooveCharacteristic != ''">
              <bf:soundCharacteristic>
                <bf:GrooveCharacteristic>
                  <xsl:if test="$grooveCharacteristicURI != ''">
                      <xsl:attribute name="rdf:about"><xsl:value-of select="$grooveCharacteristicURI"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$grooveCharacteristic"/></rdfs:label>
                </bf:GrooveCharacteristic>
              </bf:soundCharacteristic>
            </xsl:if>
            <xsl:if test="count(../marc:datafield[@tag='300']/marc:subfield[@code='c']) = 0">
                <xsl:if test="$dimensions != ''">
                    <bf:dimensions><xsl:value-of select="$dimensions"/></bf:dimensions>
                </xsl:if>
                <xsl:if test="$tapeWidth != ''">
                    <bf:dimensions><xsl:value-of select="$tapeWidth"/></bf:dimensions>
                </xsl:if>
            </xsl:if>
            <xsl:if test="$tapeConfig != ''">
              <bf:soundCharacteristic>
                <bf:TapeConfig>
                  <xsl:if test="$tapeConfigUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$tapeConfigUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$tapeConfig"/></rdfs:label>
                </bf:TapeConfig>
              </bf:soundCharacteristic>
            </xsl:if>
            <xsl:if test="$generation != ''">
              <bf:generation>
                <bf:Generation>
                  <xsl:if test="$generationURI != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$generationURI"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$generation"/></rdfs:label>
                </bf:Generation>
              </bf:generation>
            </xsl:if>
            <xsl:if test="$baseMaterial != ''">
              <bf:baseMaterial>
                <bf:BaseMaterial>
                  <xsl:if test="$baseMaterialUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$baseMaterialUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$baseMaterial"/></rdfs:label>
                </bf:BaseMaterial>
              </bf:baseMaterial>
            </xsl:if>
            <xsl:if test="$emulsion != ''">
              <bf:emulsion>
                <bf:Emulsion>
                  <xsl:if test="$emulsionUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$emulsionUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$emulsion"/></rdfs:label>
                </bf:Emulsion>
              </bf:emulsion>
            </xsl:if>
            <xsl:if test="$cutting != ''">
              <bf:soundCharacteristic>
                <bf:GrooveCharacteristic>
                  <xsl:if test="$cuttingURI != ''">
                      <xsl:attribute name="rdf:about"><xsl:value-of select="$cuttingURI"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$cutting"/></rdfs:label>
                </bf:GrooveCharacteristic>
              </bf:soundCharacteristic>
            </xsl:if>
            <xsl:if test="$playbackCharacteristic != ''">
              <bf:soundCharacteristic>
                <bf:PlaybackCharacteristic>
                  <xsl:if test="$playbackCharacteristicURI != ''">
                      <xsl:attribute name="rdf:about"><xsl:value-of select="$playbackCharacteristicURI"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$playbackCharacteristic"/></rdfs:label>
                </bf:PlaybackCharacteristic>
              </bf:soundCharacteristic>
            </xsl:if>
            <xsl:if test="$recordingMethod != ''">
              <bf:soundCharacteristic>
                <bf:RecordingMethod>
                  <xsl:if test="$recordingMethodURI != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$recordingMethodURI"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$recordingMethod"/></rdfs:label>
                </bf:RecordingMethod>
              </bf:soundCharacteristic>
            </xsl:if>
            <xsl:if test="$captureStorage != ''">
              <bf:soundCharacteristic>
                <bflc:CaptureStorage>
                  <xsl:if test="$captureStorageUri != ''">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$captureStorageUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$captureStorage"/></rdfs:label>
                </bflc:CaptureStorage>
              </bf:soundCharacteristic>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- videorecording -->
      <xsl:when test="substring(.,1,1) = 'v'">
        <xsl:variable name="carrier">
          <xsl:choose>
            <xsl:when test="substring(.,2,1) = 'c'">videocartridge</xsl:when>
            <xsl:when test="substring(.,2,1) = 'd'">videodisc</xsl:when>
            <xsl:when test="substring(.,2,1) = 'f'">videocassette</xsl:when>
            <xsl:when test="substring(.,2,1) = 'r'">videotape reel</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="carrierUri">
          <xsl:choose>
            <xsl:when test="substring(.,2,1) = 'c'"><xsl:value-of select="concat($carriers,'vc')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'd'"><xsl:value-of select="concat($carriers,'vd')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'f'"><xsl:value-of select="concat($carriers,'vf')"/></xsl:when>
            <xsl:when test="substring(.,2,1) = 'r'"><xsl:value-of select="concat($carriers,'vr')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="videoFormat">
          <xsl:choose>
            <xsl:when test="substring(.,5,1) = 'a'">Beta (1/2 in.videocassette)</xsl:when>
            <xsl:when test="substring(.,5,1) = 'b'">VHS (1/2 in.videocassette)</xsl:when>
            <xsl:when test="substring(.,5,1) = 'c'">U-matic  (3/4 in.videocassette)</xsl:when>
            <xsl:when test="substring(.,5,1) = 'd'">EIAJ (1/2 in.reel)</xsl:when>
            <xsl:when test="substring(.,5,1) = 'e'">Type C  (1 in.reel)</xsl:when>
            <xsl:when test="substring(.,5,1) = 'f'">Quadruplex (1 in.or 2 in. reel)</xsl:when>
            <xsl:when test="substring(.,5,1) = 'g'">Laserdisc</xsl:when>
            <xsl:when test="substring(.,5,1) = 'h'">CED (Capacitance Electronic Disc)</xsl:when>
            <xsl:when test="substring(.,5,1) = 'i'">Betacam (1/2 in., videocassette)</xsl:when>
            <xsl:when test="substring(.,5,1) = 'j'">Betacam SP (1/2 in., videocassette)</xsl:when>
            <xsl:when test="substring(.,5,1) = 'k'">Super-VHS (1/2 in. videocassette)</xsl:when>
            <xsl:when test="substring(.,5,1) = 'm'">M-II (1/2 in., videocassette)</xsl:when>
            <xsl:when test="substring(.,5,1) = 'o'">D-2 (3/4 in., videocassette)</xsl:when>
            <xsl:when test="substring(.,5,1) = 'p'">8 mm.</xsl:when>
            <xsl:when test="substring(.,5,1) = 'q'">Hi-8 mm.</xsl:when>
            <xsl:when test="substring(.,5,1) = 's'">Blu-ray disc</xsl:when>
            <xsl:when test="substring(.,5,1) = 'v'">DVD</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="videoFormatURI">
          <xsl:choose>
            <xsl:when test="substring(.,5,1) = 'a'"><xsl:value-of select="concat($mvidformat,'betamax')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'b'"><xsl:value-of select="concat($mvidformat,'vhs')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'c'"><xsl:value-of select="concat($mvidformat,'umatic')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'd'"><xsl:value-of select="concat($mvidformat,'eiaj')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'e'"><xsl:value-of select="concat($mvidformat,'typec')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'f'"><xsl:value-of select="concat($mvidformat,'quad')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'g'"><xsl:value-of select="concat($mvidformat,'laser')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'h'"><xsl:value-of select="concat($mvidformat,'ced')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'i'"><xsl:value-of select="concat($mvidformat,'betacam')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'j'"><xsl:value-of select="concat($mvidformat,'betasp')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'k'"><xsl:value-of select="concat($mvidformat,'svhs')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'm'"><xsl:value-of select="concat($mvidformat,'mii')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'o'"><xsl:value-of select="concat($mvidformat,'d2')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'p'"><xsl:value-of select="concat($mvidformat,'8mm')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'q'"><xsl:value-of select="concat($mvidformat,'hi8mm')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 's'"><xsl:value-of select="concat($mvidformat,'bluray')"/></xsl:when>
            <xsl:when test="substring(.,5,1) = 'v'"><xsl:value-of select="concat($mvidformat,'dvd')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="soundContent">
          <xsl:choose>
            <xsl:when test="substring(.,6,1) = ' '">silent</xsl:when>
            <xsl:when test="substring(.,6,1) = 'a'">sound</xsl:when>
            <xsl:when test="substring(.,6,1) = 'b'">sound</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="soundContentURI">
          <xsl:choose>
            <xsl:when test="substring(.,6,1) = ' '"><xsl:value-of select="concat($msoundcontent,'silent')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'a'"><xsl:value-of select="concat($msoundcontent,'sound')"/></xsl:when>
            <xsl:when test="substring(.,6,1) = 'b'"><xsl:value-of select="concat($msoundcontent,'sound')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="recordingMedium">
          <xsl:choose>
            <xsl:when test="substring(.,7,1) = 'a'">optical sound track on motion picture film</xsl:when>
            <xsl:when test="substring(.,7,1) = 'b'">magnetic sound track on motion picture film</xsl:when>
            <xsl:when test="substring(.,7,1) = 'c'">magnetic audio tape in cartridge</xsl:when>
            <xsl:when test="substring(.,7,1) = 'd'">sound disc</xsl:when>
            <xsl:when test="substring(.,7,1) = 'e'">magnetic audio tape on reel</xsl:when>
            <xsl:when test="substring(.,7,1) = 'f'">magnetic audio tape in cassette</xsl:when>
            <xsl:when test="substring(.,7,1) = 'g'">optical and magnetic sound track on motion picture film</xsl:when>
            <xsl:when test="substring(.,7,1) = 'h'">videotape</xsl:when>
            <xsl:when test="substring(.,7,1) = 'i'">videodisc</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="recordingMediumURI">
          <xsl:choose>
            <xsl:when test="substring(.,7,1) = 'a'"><xsl:value-of select="concat($mrecmedium,'opt')"/></xsl:when>
            <xsl:when test="substring(.,7,1) = 'b'"><xsl:value-of select="concat($mrecmedium,'mag')"/></xsl:when>
            <xsl:when test="substring(.,7,1) = 'c'"><xsl:value-of select="concat($mrecmedium,'mag')"/></xsl:when>
            <xsl:when test="substring(.,7,1) = 'd'"><xsl:value-of select="concat($mrecmedium,'magopt')"/></xsl:when>
            <xsl:when test="substring(.,7,1) = 'e'"><xsl:value-of select="concat($mrecmedium,'mag')"/></xsl:when>
            <xsl:when test="substring(.,7,1) = 'f'"><xsl:value-of select="concat($mrecmedium,'mag')"/></xsl:when>
            <xsl:when test="substring(.,7,1) = 'g'"><xsl:value-of select="concat($mrecmedium,'magopt')"/></xsl:when>
            <xsl:when test="substring(.,7,1) = 'h'"><xsl:value-of select="concat($mrecmedium,'mag')"/></xsl:when>
            <xsl:when test="substring(.,7,1) = 'i'"><xsl:value-of select="concat($mrecmedium,'opt')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="dimensions">
          <xsl:choose>
            <xsl:when test="substring(.,8,1) = 'a'">8 mm.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'm'">1/4 in.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'o'">1/2 in.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'p'">1 in.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'q'">2 in.</xsl:when>
            <xsl:when test="substring(.,8,1) = 'r'">3/4 in.</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="playbackChannels">
          <xsl:choose>
            <xsl:when test="substring(.,9,1) = 'k'">mixed</xsl:when>
            <xsl:when test="substring(.,9,1) = 'm'">mono</xsl:when>
            <xsl:when test="substring(.,9,1) = 'q'">surround</xsl:when>
            <xsl:when test="substring(.,9,1) = 's'">stereo</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="playbackUri">
          <xsl:choose>
            <xsl:when test="substring(.,9,1) = 'k'"><xsl:value-of select="concat($mplayback,'mix')"/></xsl:when>
            <xsl:when test="substring(.,9,1) = 'm'"><xsl:value-of select="concat($mplayback,'mon')"/></xsl:when>
            <xsl:when test="substring(.,9,1) = 'q'"><xsl:value-of select="concat($mplayback,'mul')"/></xsl:when>
            <xsl:when test="substring(.,9,1) = 's'"><xsl:value-of select="concat($mplayback,'ste')"/></xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$serialization = 'rdfxml'">
            <xsl:if test="count(../marc:datafield[@tag='337']) = 0">
              <bf:media>
                <bf:Media>
                  <xsl:attribute name="rdf:about">http://id.loc.gov/vocabulary/mediaTypes/v</xsl:attribute>
                </bf:Media>
              </bf:media>
            </xsl:if>
            <xsl:if test="count(../marc:datafield[@tag='338']) = 0">
              <xsl:if test="$carrier != ''">
                <bf:carrier>
                  <bf:Carrier>
                    <xsl:if test="$carrierUri != ''">
                      <xsl:attribute name="rdf:about"><xsl:value-of select="$carrierUri"/></xsl:attribute>
                    </xsl:if>
                    <rdfs:label><xsl:value-of select="$carrier"/></rdfs:label>
                  </bf:Carrier>
                </bf:carrier>
              </xsl:if>
            </xsl:if>
            <xsl:if test="$videoFormat != ''">
              <bf:videoCharacteristic>
                <bf:VideoFormat>
                  <xsl:if test="$videoFormatURI != ''">
                      <xsl:attribute name="rdf:about"><xsl:value-of select="$videoFormatURI"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$videoFormat"/></rdfs:label>
                </bf:VideoFormat>
              </bf:videoCharacteristic>
            </xsl:if>
            <xsl:if test="$soundContent != ''">
              <bf:soundContent>
                <bf:SoundContent>
                  <xsl:if test="$soundContentURI != ''">
                      <xsl:attribute name="rdf:about"><xsl:value-of select="$soundContentURI"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$soundContent"/></rdfs:label>
                </bf:SoundContent>
              </bf:soundContent>
            </xsl:if>
            <xsl:if test="$recordingMedium != ''">
              <bf:soundCharacteristic>
                <bf:RecordingMedium>
                  <xsl:if test="$recordingMediumURI != ''">
                      <xsl:attribute name="rdf:about"><xsl:value-of select="$recordingMediumURI"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$recordingMedium"/></rdfs:label>
                </bf:RecordingMedium>
              </bf:soundCharacteristic>
            </xsl:if>
            <xsl:if test="count(../marc:datafield[@tag='300']/marc:subfield[@code='c']) = 0">
                <xsl:if test="$dimensions != ''">
                    <bf:dimensions><xsl:value-of select="$dimensions"/></bf:dimensions>
                </xsl:if>
            </xsl:if>
            <xsl:if test="$playbackChannels != ''">
              <bf:soundCharacteristic>
                <bf:PlaybackChannels>
                  <xsl:if test="$playbackUri != ''">
                      <xsl:attribute name="rdf:about"><xsl:value-of select="$playbackUri"/></xsl:attribute>
                  </xsl:if>
                  <rdfs:label><xsl:value-of select="$playbackChannels"/></rdfs:label>
                </bf:PlaybackChannels>
              </bf:soundCharacteristic>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
