<!-- 
    ART-DECOR® STANDARD COPYRIGHT AND LICENSE NOTE
    Copyright © ART-DECOR Expert Group and ART-DECOR Open Tools GmbH
    see https://docs.art-decor.org/copyright and https://docs.art-decor.org/licenses

    This file is part of the ART-DECOR® tools suite.    
--><xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.0" exclude-result-prefixes="#all">
    <!-- 
        the param outputformat specifies output
        hgraph format returns the hierarchical graph of the template chain including classification
        hgraphwiki is the same as hgraph but the OIDs of the templates are in Mediawiki link style [[1.2.3...]]
        wikilist returns the list of templates in Mediawiki transclusion style, sorted by classification
        hgraph is the default
        
        coretableonly if true only the core table is emitted, not a whole HTML document.
    -->
    <xsl:param name="outputformat" select="'fshlogicalmodel'" as="xs:string"/>
    <xsl:param name="title" select="'x,y,z'" as="xs:string"/>
    <!-- 
        derived parameters
    -->
    <xsl:param name="fsh-logical-model" as="xs:boolean">
        <!-- return a FHIR short hand (fsh) logical model -->
        <xsl:choose>
            <xsl:when test="$outputformat=('fshlogicalmodel')">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <!-- 
        output methods
    -->
    <xsl:output method="xml" name="xml" indent="no" version="1.0" encoding="UTF-8" exclude-result-prefixes="#all"/>
    <xsl:output method="html" name="html" indent="no" version="4.01" encoding="UTF-8" doctype-public="-//W3C//DTD HTML 4.01//EN" doctype-system="http://www.w3.org/TR/html4/strict.dtd"/>
    <xsl:output method="xhtml" name="xhtml" indent="no" encoding="UTF-8" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
    <xsl:output method="text" name="text"/>
    <!-- 
        real start here
        
        gets something like this
        <template id="2.16.840.1.113883.10.22.1.2" name="HL7-IPS" displayName="International Patient Summary"
       	effectiveDate="2024‑08‑02" by="template" len="55" classification="cdadocumentlevel">
       	<template id="2.16.840.1.113883.10.22.2.1" name="IPSCDArecordTarget" displayName="IPS CDA recordTarget"
       		effectiveDate="2021‑09‑02" by="include" len="55" classification="cdaheaderlevel">
       		<template id="2.16.840.1.113883.10.22.11" name="IPSAddress" displayName="IPS Address" effectiveDate="2018‑04‑04"
       			by="include" len="54" classification="datatypelevel" />
       		<template id="2.16.840.1.113883.10.22.11" name="IPSAddress" displayName="IPS Address" effectiveDate="2018‑04‑04"
       			by="include" len="54" classification="datatypelevel" />
       	</template>
       	...
        </template>
    -->
    <xsl:template match="/">
        <xsl:variable name="templatesraw" select="."/>
        <xsl:variable name="result">
            <xsl:choose>
                <xsl:when test="$fsh-logical-model=true()">
                    <!-- return the hierarchical logical model in fsh format of the template chain including classification -->
                    <xsl:apply-templates select="$templatesraw" mode="fsh-lm">
                        <xsl:with-param name="title" select="$title"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:copy-of select="$result"/>
    </xsl:template>
    <!-- 
        fsh format logical model
    -->
    <xsl:template match="template" mode="fsh-lm">
        <xsl:param name="title"/>
        <!-- return the hierarchical logical model in fsh format of the template chain including classification -->
        <xsl:variable name="fsh">
            <artifact>
                <fsh>
                    <xsl:text>Logical: </xsl:text>
                    <xsl:value-of select="$title"/>
                </fsh>
                <fsh>Parent:  Element</fsh>
                <fsh>Id:      test-lm</fsh>
                <fsh>Title:  "Test LogicalModel"</fsh>
                <fsh>Description:  "Test LogicalModel"</fsh>
                <xsl:apply-templates select="." mode="fsh-lm-hier">
                    <xsl:with-param name="nesting" select="0"/>
                </xsl:apply-templates>
            </artifact>
        </xsl:variable>
        <xsl:call-template name="serveSushi">
            <xsl:with-param name="fsh" select="$fsh"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="template[string-length(tokenize(@id, '\.')[last()])&lt;=9]" mode="fsh-lm-hier">
        <xsl:param name="nesting"/>
        <xsl:variable name="ctok" select="tokenize(@classification, ' ')"/>
        <xsl:variable name="c">
            <xsl:choose>
                <xsl:when test="@recurse='true'">
                    <xsl:value-of select="'@'"/>
                </xsl:when>
                <xsl:when test="count($ctok)=1">
                    <xsl:value-of select="$ctok[1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'*'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <fsh>
            <xsl:for-each select="1 to $nesting">
                <xsl:text>  </xsl:text>
            </xsl:for-each>
            <xsl:text>* </xsl:text>
            <xsl:value-of select="@name"/>
            <!--<xsl:call-template name="shortName">
                <xsl:with-param name="name">
                    <xsl:value-of select="@name"/>
                </xsl:with-param>
            </xsl:call-template>-->
            <xsl:text> </xsl:text>
            <xsl:text>0..* StructureDefinition</xsl:text>
            <xsl:text> </xsl:text>
            <xsl:text>"</xsl:text>
            <xsl:value-of select="@displayName"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="@id"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="@effectiveDate"/>
            <xsl:text>)</xsl:text>
            <!--
            <xsl:choose>
                <xsl:when test="$c = 'cdadocumentlevel'">
                    <xsl:text> Document</xsl:text>
                </xsl:when>
                <xsl:when test="$c = 'cdaheaderlevel'">
                    <xsl:text> Header</xsl:text>
                </xsl:when>
                <xsl:when test="$c = 'cdasectionlevel'">
                    <xsl:text> Section</xsl:text>
                </xsl:when>
                <xsl:when test="$c = 'cdaentrylevel'">
                    <xsl:text> Entry</xsl:text>
                </xsl:when>
                <xsl:when test="$c = 'datatypelevel'">
                    <xsl:text> Datatype</xsl:text>
                </xsl:when>
                <xsl:when test="string-length($c)=0">
                    <xsl:text>–</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="$c"/>
                    <xsl:text> </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            -->
            <xsl:text>"</xsl:text>
        </fsh>
        <xsl:if test="template">
            <xsl:apply-templates select="template" mode="fsh-lm-hier">
                <xsl:with-param name="nesting" select="$nesting+1"/>
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>
    <xsl:template name="serveSushi">
        <xsl:param name="fsh"/>
        <xsl:for-each select="$fsh/artifact/fsh">
            <xsl:value-of select="."/>
            <xsl:text>&#10;</xsl:text>
            <br/>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="shortName">
        <xsl:param name="name" as="item()?"/>
        <!-- add some readability to CamelCased names. E.g. MedicationStatement to Medication_Statement. -->
        <xsl:variable name="r0" select="replace($name, '([a-z])([A-Z])', '$1_$2')"/>
        
        <!-- find matching alternatives for &lt;=? smaller(equal) and >=? greater(equal) -->
        <xsl:variable name="r1" select="replace($r0, '&lt;\s*=', 'le')"/>
        <xsl:variable name="r2" select="replace($r1, '&lt;', 'lt')"/>
        <xsl:variable name="r3" select="replace($r2, '&gt;\s*=', 'ge')"/>
        <xsl:variable name="r4" select="replace($r3, '&gt;', 'gt')"/>
        
        <!-- find matching alternatives for more or less common diacriticals, replace single spaces with _ , replace ? with q (same name occurs quite often twice, with and without '?') -->
        <xsl:variable name="r5" select="translate(normalize-space(lower-case($r4)),' àáãäåèéêëìíîïòóôõöùúûüýÿç€ßñ?','_aaaaaeeeeiiiiooooouuuuyycEsnq')"/>
        <!-- ditch anything that's not alpha numerical or underscore -->
        <xsl:variable name="r6" select="replace($r5,'[^a-zA-Z\d_]','')"/>
        <!-- make sure we do not start with a digit -->
        <xsl:variable name="r7" select="replace($r6, '^(\d)' , '_$1')"/>
        
        <xsl:value-of select="if (matches($r7, '^[a-zA-Z_][a-zA-Z\d_]+$')) then $r7 else ()"/>
    </xsl:template>
    
</xsl:stylesheet>