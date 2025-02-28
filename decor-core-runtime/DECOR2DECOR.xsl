<!-- 
    ART-DECOR® STANDARD COPYRIGHT AND LICENSE NOTE
    Copyright © ART-DECOR Expert Group and ART-DECOR Open Tools GmbH
    see https://docs.art-decor.org/copyright and https://docs.art-decor.org/licenses

    This file is part of the ART-DECOR® tools suite.    
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xforms="http://www.w3.org/2002/xforms" xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:uuid="java:java.util.UUID" xmlns:local="http://art-decor.org/functions" version="2.0" exclude-result-prefixes="#all">
    <!--
    This stylesheet takes the DECOR.xsd schema and generates a description of the Templates DSTU ITS in DECOR format
    
    K. Heitmann 2013-12, 2014-01, 2014-07
    A. Henket 2016-09 - added datasets
    -->    
    <xsl:output method="xml" omit-xml-declaration="yes" indent="yes" version="1.0" encoding="UTF-8" exclude-result-prefixes="#all"/>
    <xsl:output method="xml" omit-xml-declaration="yes" indent="yes" version="1.0" encoding="UTF-8" exclude-result-prefixes="#all" name="xml"/>
    
    <xsl:variable name="tops" select="/*"/>
    <xsl:variable name="adoid" select="'2.16.840.1.113883.3.1937.98'"/>
    
    <xsl:variable name="allDECOR" select="/* | doc(//xs:include/@schemaLocation)/*" as="element()*"/>
    <xsl:template match="/">
        <xsl:result-document format="xml" href="DECORasDECOR.xml">
            <decor-dataset-and-valueset-and-templates-only xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="DECORrulesonly.xsd">
                <datasets>
                    <xsl:variable name="temp">
                        <xsl:apply-templates select="//xs:element[@name = 'dataset']" mode="dataset"/>
                    </xsl:variable>
                    <xsl:apply-templates select="$temp/*" mode="replaceids"/>
                </datasets>
                
                <terminology>
                    <!-- could do associations here... -->
                    <xsl:for-each select="$tops/xs:simpleType[*/xs:enumeration]">
                        <xsl:variable name="pos" select="position()"/>
                        <valueSet name="{@name}" displayName="{@name}" id="{concat($adoid, '.11.', $pos)}" effectiveDate="2013-12-05T00:00:00" statusCode="draft">
                            <conceptList>
                                <xsl:for-each select="*/xs:enumeration">
                                    <xsl:variable name="dn" select="(xs:annotation/xs:appinfo/xforms:label[@xml:lang = 'en-US'])[1]"/>
                                    <concept code="{@value}" codeSystem="{concat($adoid, '.5.', $pos)}" displayName="{if (string-length($dn)&gt;0) then $dn else @value}" type="L" level="0"/>
                                </xsl:for-each>
                            </conceptList>
                        </valueSet>
                    </xsl:for-each>
                </terminology>
                <rules>
                    <xsl:variable name="temp">
                        <xsl:apply-templates select="//xs:complexType[@name = 'TemplateDefinition']" mode="template"/>
                    </xsl:variable>
                    <xsl:for-each select="$temp/template">
                        <xsl:variable name="pos" select="position()"/>
                        <template>
                            <xsl:attribute name="id" select="concat($adoid, '.10.', $pos)"/>
                            <xsl:copy-of select="@* except @id"/>
                            <xsl:copy-of select="*"/>
                        </template>
                    </xsl:for-each>
                </rules>
            </decor-dataset-and-valueset-and-templates-only>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="dorefs">
        <xsl:for-each-group select=".//xs:element[@ref]" group-by="@ref">
            <xsl:variable name="name" select="@ref"/>
            <xsl:apply-templates select="/*/xs:element[@name = $name]" mode="template"/>
        </xsl:for-each-group>
        <xsl:for-each-group select=".//xs:attribute[@ref]" group-by="@ref">
            <xsl:variable name="name" select="@ref"/>
            <xsl:apply-templates select="/*/xs:attribute[@name = $name]" mode="template"/>
        </xsl:for-each-group>
        <xsl:for-each-group select=".//xs:attributeGroup[@ref]" group-by="@ref">
            <xsl:variable name="name" select="@ref"/>
            <xsl:apply-templates select="/*/xs:attributeGroup[@name = $name]" mode="template"/>
        </xsl:for-each-group>
    </xsl:template>
    
    <xsl:template match="xs:element" mode="dataset">
        <dataset id="-will-be-replaced-" effectiveDate="2013-12-05T00:00:00" statusCode="draft">
            <name language="en-US">Data Set</name>
            <desc language="en-US">DECOR definitions to describe a DECOR data set as a DECOR data set</desc>
            <xsl:apply-templates select="xs:complexType/(xs:attribute | xs:attributeGroup)" mode="mainds"/>
            <xsl:apply-templates select="xs:complexType//(xs:element | xs:choice)" mode="mainds"/>
        </dataset>
    </xsl:template>
    <xsl:template match="xs:attribute" mode="mainds">
        <xsl:variable name="ref" select="@ref"/>
        <xsl:choose>
            <xsl:when test="@ref">
                <xsl:apply-templates select="$allDECOR//xs:attribute[parent::xs:schema][@name = $ref]" mode="mainds"/>
            </xsl:when>
            <xsl:when test="@name = 'refdisplay'"/>
            <xsl:when test="@name = 'iddisplay'"/>
            <xsl:when test="@name = 'shortName'"/>
            <xsl:otherwise>
                <concept id="-will-be-replaced-" type="item" effectiveDate="2013-12-05T00:00:00" statusCode="draft">
                    <name language="en-US">
                        <xsl:value-of select="@name | @ref"/>
                    </name>
                    <desc language="en-US">
                        <xsl:value-of select="xs:annotation/xs:documentation"/>
                    </desc>
                    <valueDomain type="string"/>
                </concept>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="xs:attributeGroup" mode="mainds">
        <xsl:variable name="ref" select="@ref"/>
        <xsl:choose>
            <xsl:when test="@ref">
                <xsl:apply-templates select="$allDECOR//xs:attributeGroup[parent::xs:schema][@name = $ref]/xs:attribute" mode="mainds"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="xs:attribute" mode="mainds"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="xs:choice" mode="mainds">
        <xsl:for-each-group select="xs:element" group-by="@name | @ref">
            <xsl:apply-templates select="current-group()[1]" mode="mainds"/>
        </xsl:for-each-group>
    </xsl:template>
    <xsl:template match="xs:element" mode="mainds">
        <xsl:variable name="ref" select="@ref"/>
        <xsl:variable name="type" select="@type"/>
        <xsl:choose>
            <xsl:when test=".[@name = 'concept'][ancestor::xs:complexType/@name = ('DataSetConcept', 'DataSetConceptHistory')]">
                <concept ref="concept" flexibility="2013-12-05T00:00:00" statusCode="draft"/>
            </xsl:when>
            <xsl:when test="@type">
                <xsl:variable name="typeTarget" select="$allDECOR//xs:complexType[parent::xs:schema][@name = $type]"/>
                <concept id="-will-be-replaced-" type="group" effectiveDate="2013-12-05T00:00:00" statusCode="draft">
                    <name language="en-US">
                        <xsl:value-of select="@name | @ref"/>
                    </name>
                    <desc language="en-US">
                        <xsl:value-of select="xs:annotation/xs:documentation"/>
                    </desc>
                    <xsl:apply-templates select="$typeTarget//(xs:attribute | xs:attributeGroup)" mode="#current"/>
                    <xsl:for-each-group select="$typeTarget//xs:element" group-by="@name | @ref">
                        <xsl:apply-templates select="current-group()[1]" mode="mainds"/>
                    </xsl:for-each-group>
                    <xsl:if test="$typeTarget/xs:simpleContent | $typeTarget/xs:complexContent">
                        <concept id="-will-be-replaced-" type="item" effectiveDate="2013-12-05T00:00:00" statusCode="draft">
                            <name language="en-US">Text</name>
                            <desc language="en-US">
                                <xsl:value-of select="xs:annotation/xs:documentation"/>
                            </desc>
                            <valueDomain type="string"/>
                        </concept>
                    </xsl:if>
                </concept>
            </xsl:when>
            <xsl:when test="@name and xs:complexType">
                <concept id="-will-be-replaced-" type="group" effectiveDate="2013-12-05T00:00:00" statusCode="draft">
                    <name language="en-US">
                        <xsl:value-of select="@name | @ref"/>
                    </name>
                    <desc language="en-US">
                        <xsl:value-of select="xs:annotation/xs:documentation"/>
                    </desc>
                    <xsl:apply-templates select="xs:complexType/(xs:attribute | xs:attributeGroup)" mode="#current"/>
                    <xsl:for-each-group select="xs:complexType//xs:element" group-by="@name | @ref">
                        <xsl:apply-templates select="current-group()[1]" mode="mainds"/>
                    </xsl:for-each-group>
                </concept>
            </xsl:when>
            <xsl:when test="@name and not(xs:complexType)">
                <concept id="-will-be-replaced-" type="item" effectiveDate="2013-12-05T00:00:00" statusCode="draft">
                    <name language="en-US">
                        <xsl:value-of select="@name | @ref"/>
                    </name>
                    <desc language="en-US">
                        <xsl:value-of select="xs:annotation/xs:documentation"/>
                    </desc>
                    <valueDomain type="string"/>
                </concept>
            </xsl:when>
            <xsl:when test="@ref">
                <xsl:apply-templates select="$allDECOR//xs:element[parent::xs:schema][@name = $ref]" mode="#current"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes">Huh?</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="xs:complexType" mode="template">
        <template id="-will-be-replaced-" name="DECOR" displayName="DECOR" effectiveDate="2013-12-05T00:00:00" statusCode="draft">
            <desc language="en-US">DECOR definitions to describe DECOR in DECOR</desc>
            <element name="hl7:template" minimumMultiplicity="0" maximumMultiplicity="*">
                <xsl:apply-templates select="xs:attribute | xs:attributeGroup" mode="main"/>
                <xsl:apply-templates select="xs:sequence//(xs:element | xs:choice)" mode="main"/>
            </element>
        </template>
        <xsl:call-template name="dorefs"/>
    </xsl:template>
    
    <xsl:template match="xs:complexType" mode="main">
        <xsl:apply-templates select="xs:attribute | xs:attributeGroup" mode="#current"/>
        <xsl:apply-templates select="xs:sequence/(xs:element | xs:choice)" mode="#current"/>
    </xsl:template>
    
    <xsl:template match="xs:attribute" mode="main">
        <xsl:choose>
            <xsl:when test="@name">
                <attribute name="{@name}">
                    <xsl:call-template name="doAttrCard"/>
                </attribute>
            </xsl:when>
            <xsl:when test="@ref">
                <attribute name="{@ref}">
                    <xsl:call-template name="doAttrCard"/>
                    <xsl:call-template name="doElmCard"/>
                </attribute>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="doAttrCard">
        <xsl:choose>
            <xsl:when test="@use = 'optional'">
                <xsl:attribute name="isOptional" select="'true'"/>
            </xsl:when>
            <xsl:when test="@use = 'required'">
                <xsl:attribute name="isOptional" select="'false'"/>
            </xsl:when>
        </xsl:choose>
        <xsl:if test="@type">
            <xsl:variable name="name" select="@type"/>
            <xsl:choose>
                <xsl:when test="$tops/xs:simpleType[@name = $name]/*/xs:enumeration">
                    <vocabulary valueSet="{@type}"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="datatype">
                        <xsl:attribute name="datatype" select="@type"/>
                    </xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="xs:attribute" mode="template">
        <template id="-will-be-replaced-" name="{@name}" displayName="{@name}" effectiveDate="2013-12-05T00:00:00" statusCode="draft">
            <attribute name="{@name}">
                <xsl:call-template name="doAttrCard"/>
            </attribute>
        </template>
        <xsl:call-template name="dorefs"/>
    </xsl:template>
    
    <xsl:template match="xs:attributeGroup" mode="main">
        <xsl:choose>
            <xsl:when test="@ref">
                <include ref="{@ref}"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="xs:attributeGroup" mode="template">
        <template id="-will-be-replaced-" name="{@name}" displayName="{@name}" effectiveDate="2013-12-05T00:00:00" statusCode="draft">
            <xsl:apply-templates select="xs:attribute | xs:attributeGroup" mode="main"/>
        </template>
        <xsl:call-template name="dorefs"/>
    </xsl:template>
    
    <xsl:template match="xs:choice" mode="main">
        <choice>
            <xsl:apply-templates select="xs:element" mode="main"/>
        </choice>
    </xsl:template>
    
    <xsl:template match="xs:element" mode="main">
        <xsl:choose>
            <xsl:when test="@name">
                <element name="{@name}">
                    <xsl:call-template name="doElmCard"/>
                    <xsl:apply-templates select="xs:complexType" mode="main"/>
                </element>
            </xsl:when>
            <xsl:when test="@ref">
                <include ref="{@ref}">
                    <xsl:call-template name="doElmCard"/>
                </include>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="doElmCard">
        <xsl:choose>
            <xsl:when test="@minOccurs = '0' and @maxOccurs = '0'">
                <xsl:attribute name="conformance" select="'NP'"/>
            </xsl:when>
            <xsl:when test="@minOccurs or @maxOccurs">
                <xsl:if test="@minOccurs">
                    <xsl:attribute name="minimumMultiplicity" select="@minOccurs"/>
                </xsl:if>
                <xsl:if test="@maxOccurs">
                    <xsl:attribute name="maximumMultiplicity">
                        <xsl:choose>
                            <xsl:when test="@maxOccurs = 'unbounded'">
                                <xsl:value-of select="'*'"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="@maxOccurs"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                </xsl:if>
            </xsl:when>
        </xsl:choose>
        <xsl:if test="@type">
            <xsl:variable name="name" select="@type"/>
            <xsl:choose>
                <xsl:when test="$tops/xs:complexType[@name = $name]">
                    <include ref="{@type}"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="datatype">
                        <xsl:value-of select="@type"/>
                    </xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="xs:element" mode="template">
        <template id="-will-be-replaced-" name="{@name}" displayName="{@name}" effectiveDate="2013-12-05T00:00:00" statusCode="draft">
            <element name="{@name}">
                <xsl:apply-templates select="xs:complexType" mode="main"/>
            </element>
        </template>
        <xsl:call-template name="dorefs"/>
    </xsl:template>
    
    <xsl:template match="dataset | dataset//node()" mode="replaceids">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="@id">
                <xsl:variable name="pos" select="count(preceding::concept | ancestor::concept) + 1"/>
                <xsl:attribute name="id" select="concat($adoid, if (self::dataset) then '.1.' else ('.2'), $pos)"/>
            </xsl:if>
            <xsl:if test="@ref">
                <xsl:variable name="name" select="@ref"/>
                <xsl:variable name="pos" select="//concept[name = $name]/count(preceding::concept | ancestor::concept)"/>
                <xsl:attribute name="ref" select="concat($adoid, if (self::dataset) then '.1.' else ('.2'), $pos[1])"/>
            </xsl:if>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text() | node() | xs:annotation | xs:documentation | xs:appinfo | sch:pattern" mode="#all"/>
</xsl:stylesheet>
