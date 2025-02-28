<!-- 
    ART-DECOR® STANDARD COPYRIGHT AND LICENSE NOTE
    Copyright © ART-DECOR Expert Group and ART-DECOR Open Tools GmbH
    see https://docs.art-decor.org/copyright and https://docs.art-decor.org/licenses

    This file is part of the ART-DECOR® tools suite.    
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:f="http://hl7.org/fhir" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.0" exclude-result-prefixes="#all">
    
    <!--
        parameters
        ==========
        to this XSLT and all invoked scripts
    -->
    <xsl:param name="artdecordeeplinkprefix" as="xs:string?"/>
    <!-- 
        if this xsl is invoked by ADRAM service the adram variable is set to the version
    -->
    <xsl:param name="adram" as="xs:string?"/>
    <!-- if false return content table only -->
    <xsl:param name="displayHeader" select="'true'"/>
    
    <!-- not used yet, only by DECORbasics -->
    <xsl:param name="projectDefaultLanguage"/>
    <xsl:variable name="defaultLanguage" select="$projectDefaultLanguage"/>
    
    <!-- fixed parameters  -->
    <!-- base output prefix if any, must end on "/" or empty on "relative" outputs -->
    <xsl:param name="outputBaseUriPrefix"/>
    <!-- base uri to script (xsl) if any, must end on "/" or empty on "automatic" uri to scripts -->
    <xsl:param name="scriptBaseUriPrefix"/>
    <xsl:param name="switchCreateSchematron" select="false()"/>
    <xsl:param name="switchCreateSchematronWithWrapperIncludes" select="false()"/>
    <xsl:param name="switchCreateDocHTML" select="false()"/>
    <xsl:param name="switchCreateDocSVG" select="false()"/>
    <xsl:param name="switchCreateDocDocbook" select="false()"/>
    <xsl:param name="useLocalAssets" select="true()"/>
    <xsl:param name="useLocalLogos" select="true()"/>
    <xsl:param name="inDevelopmentString" select="'false'"/>
    <xsl:param name="inDevelopment" select="false()"/>
    <xsl:param name="switchCreateDatatypeChecks" select="false()"/>
    <xsl:param name="useCustomLogo" select="false()"/>
    <xsl:param name="useCustomLogoSRC" select="false()"/>
    <xsl:param name="useCustomLogoHREF" select="false()"/>
    <xsl:param name="createDefaultInstancesForRepresentingTemplates" select="false()"/>
    <xsl:param name="skipCardinalityChecks" select="false()"/>
    <xsl:param name="skipPredicateCreation" select="false()"/>
    <xsl:param name="useLatestDecorVersion" select="false()"/>
    <xsl:param name="latestVersion" select="''"/>
    <xsl:param name="hideColumns" select="false()"/>
    <xsl:param name="logLevel" select="'OFF'"/>
    <xsl:param name="theLogLevel" select="'OFF'"/>
    <xsl:param name="bindingBehaviorValueSetsURL"/>
    <xsl:param name="bindingBehaviorValueSets" select="'preserve'"/>
    <xsl:param name="theBaseURI2DECOR"/>
    
    <!-- die on circular references or not, values: 'continue' (default), 'die' -->
    <xsl:param name="onCircularReferences" select="'continue'"/>
    <xsl:param name="filtersfile" select="concat($theBaseURI2DECOR, '/', 'filters.xml')"/>
    <xsl:param name="filtersfileavailable" select="if (doc-available($filtersfile)) then exists(doc($filtersfile)/*[not(@filter = ('false', 'off'))][@label[not(. = '')]]) else false()" as="xs:boolean"/>
    
    
    <!-- see this URL in asserts and reports points to 'generated' HTML fiels or to the 'live' environment.
        It also determines context for any other HTML link.
    -->
    <xsl:param name="seeThisUrlLocation" select="'generated'"/>
    
    <!-- Do HTML with treetree/treeblank indenting (default. or set to false()) or treetable.js compatible indenting -->
    <xsl:param name="switchCreateTreeTableHtml"/>
    
    <!-- 
    
    -->
    <xsl:include href="DECOR-basics.xsl"/>
    <xsl:include href="DECOR2html.xsl"/>
    
    <!-- 
    
    -->
    <xsl:output method="xml" indent="no" version="1.0" encoding="UTF-8" exclude-result-prefixes="#all" name="xml"/>
    <xsl:output method="html" indent="no" version="4.01" encoding="UTF-8" doctype-public="-//W3C//DTD HTML 4.01//EN" doctype-system="http://www.w3.org/TR/html4/strict.dtd"/>
    <xsl:output method="xhtml" name="xhtml" indent="no" encoding="UTF-8" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
    <!-- 
    
    -->
    <xsl:template match="/">
        <xsl:for-each select="structuredefinition/f:StructureDefinition">
            <xsl:variable name="theName" select="if (ancestor::structuredefinition/@displayName) then ancestor::structuredefinition/@displayName else ancestor::structuredefinition/@id"/>
            <xsl:if test="$displayHeader = 'true'">
                <h1 xmlns="http://www.w3.org/1999/xhtml">
                    <xsl:call-template name="getMessage">
                        <xsl:with-param name="key" select="'StructureDefinition'"/>
                    </xsl:call-template>
                    <xsl:text> </xsl:text>
                    <i>
                        <xsl:value-of select="$theName"/>
                    </i>
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="showDate">
                        <xsl:with-param name="date" select="@effectiveDate"/>
                    </xsl:call-template>
                </h1>
            </xsl:if>
            <xsl:variable name="s">
                <xsl:apply-templates select=".">
                    <xsl:with-param name="view" select="if (f:snapshot) then 'snapshot' else 'differential'"/>
                </xsl:apply-templates>
            </xsl:variable>
            <xsl:copy-of select="$s"/>
            <!--
            <xsl:apply-templates select="$s" mode="simplify"/>
            -->
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>