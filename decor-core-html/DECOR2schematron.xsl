<!-- 
    
    DECOR2schematron
    Copyright (C) 2009-2017 Dr. Kai U. Heitmann, Alexander Henket
    
    This program is free software; you can redistribute it and/or modify it under the terms 
    of the GNU General Public License as published by the Free Software Foundation; 
    either version 3 of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
    See the GNU General Public License for more details.
    
    See http://www.gnu.org/licenses/gpl.html
  
-->
<xsl:stylesheet xmlns:xforms="http://www.w3.org/2002/xforms" xmlns:cda="urn:hl7-org:v3" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:uuid="java:java.util.UUID" xmlns:local="http://art-decor.org/functions" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" xmlns:sch="http://www.ascc.net/xml/schematron" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" exclude-result-prefixes="#all">

    <!--
        parameters
        ==========
        to this XSLT and all invoked scripts
    -->
    <!-- check existence of  -->
    
    <!-- base output prefix if any, must end on "/" or empty on "relative" outputs -->
    <xsl:param name="outputBaseUriPrefix"/>
    <!-- base uri to script (xsl) if any, must end on "/" or empty on "automatic" uri to scripts -->
    <xsl:param name="scriptBaseUriPrefix"/>
        
    <!-- path names to current DECOR -->
    <xsl:param name="inputStaticBaseUri" select="static-base-uri()"/>
    <xsl:param name="inputBaseUri" select="base-uri()"/>

    <xsl:param name="theBaseURI2DECOR" select="string-join(tokenize($inputBaseUri, '/')[position() &lt; last()], '/')"/>
    
    <!-- die on circular references or not, values: 'continue' (default), 'report' (continues and issues a warning), 'die' -->
    <xsl:param name="onCircularReferences" as="xs:string?">
        <xsl:choose>
            <xsl:when test="$parameterfileavailable and doc($parameterfile)/*/onCircularReferences">
                <xsl:value-of select="doc($parameterfile)/*/onCircularReferences"/>
            </xsl:when>
            <!-- default -->
            <xsl:otherwise>continue</xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <!-- see this URL in asserts and reports points to 'generated' HTML fiels or to the 'live' environment.
        It also determines context for any other HTML link.
    -->
    <xsl:param name="seeThisUrlLocation" select="'generated'"/>
    
    <!-- parameterfile processing -->
    <xsl:variable name="parameterfile" select="concat($theBaseURI2DECOR, '/', 'decor-parameters.xml')"/>
    <xsl:variable name="parameterfileavailable" select="doc-available($parameterfile)" as="xs:boolean"/>
    <xsl:param name="logLevel" as="xs:string?"/>
    <xsl:param name="theLogLevel" as="xs:string">
        <xsl:choose>
            <xsl:when test="exists($logLevelMap/level[@name=$logLevel])">
                <xsl:value-of select="$logLevel"/>
            </xsl:when>
            <xsl:when test="$parameterfileavailable=false()">
                <!-- default -->
                <xsl:value-of select="$logINFO"/>
            </xsl:when>
            <xsl:when test="doc($parameterfile)/*/logLevel">
                <xsl:value-of select="doc($parameterfile)/*/logLevel"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$logINFO"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <!-- create schematron? -->
    <xsl:param name="switchCreateSchematron" as="xs:boolean">
        <xsl:choose>
            <xsl:when test="$parameterfileavailable=false()">
                <!-- default -->
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when test="doc($parameterfile)/*/switchCreateSchematron1">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <!-- add transmission/controlact wrapper includes for given locale if available? -->
    <xsl:param name="switchCreateSchematronWithWrapperIncludes" as="xs:boolean">
        <xsl:choose>
            <xsl:when test="$switchCreateSchematron=false()">
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:when test="$parameterfileavailable=false()">
                <!-- default -->
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:when test="doc($parameterfile)/*/switchCreateSchematronWithWrapperIncludes1">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <!-- switchCreateSchematronWithWarningsOnOpen. This switch causes the schematron to contain warnings on encountered instance parts 
        that were not defined. While legal from the perspective of open templates, you may still want to be warned when this occurs during 
        testing/qualification -->
    <xsl:param name="switchCreateSchematronWithWarningsOnOpenString" as="xs:string" select="'false'"/>
    <xsl:param name="switchCreateSchematronWithWarningsOnOpen" as="xs:boolean">
        <xsl:choose>
            <xsl:when test="$switchCreateSchematronWithWarningsOnOpenString='true'">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when test="$parameterfileavailable=false()">
                <!-- default -->
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:when test="doc($parameterfile)/*/switchCreateSchematronWithWarningsOnOpen1">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <!-- create switchCreateSchematronClosed -->
    <xsl:param name="switchCreateSchematronClosedString" as="xs:string" select="'false'"/>
    <xsl:param name="switchCreateSchematronClosed" as="xs:boolean">
        <xsl:choose>
            <xsl:when test="$switchCreateSchematronClosedString='true'">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when test="$parameterfileavailable=false()">
                <!-- default -->
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:when test="doc($parameterfile)/*/switchCreateSchematronClosed1">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <!-- create switchCreateSchematronWithExplicitIncludes -->
    <xsl:param name="switchCreateSchematronWithExplicitIncludesString" as="xs:string" select="'false'"/>
    <xsl:param name="switchCreateSchematronWithExplicitIncludes" as="xs:boolean">
        <xsl:choose>
            <xsl:when test="$switchCreateSchematronWithExplicitIncludesString='true'">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when test="$parameterfileavailable=false()">
                <!-- default -->
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:when test="doc($parameterfile)/*/switchCreateSchematronClosed1">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when test="doc($parameterfile)/*/switchCreateSchematronWithExplicitIncludes1">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <!-- create documentation HTML? -->
    <xsl:param name="switchCreateDocHTML" as="xs:boolean">
        <xsl:choose>
            <xsl:when test="$parameterfileavailable=false()">
                <!-- default -->
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when test="doc($parameterfile)/*/switchCreateDocHTML1">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <!-- create documentation HTML with SVG? If switchCreateDocHTML is false, this parameter is pointless -->
    <xsl:param name="switchCreateDocSVG" as="xs:boolean">
        <xsl:choose>
            <xsl:when test="$switchCreateDocHTML=false()">
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:when test="$parameterfileavailable=false()">
                <!-- default -->
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when test="doc($parameterfile)/*/switchCreateDocSVG1">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <!-- create documentation Docbook? -->
    <xsl:param name="switchCreateDocDocbook" as="xs:boolean">
        <xsl:choose>
            <xsl:when test="$parameterfileavailable=false()">
                <!-- default -->
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:when test="doc($parameterfile)/*/switchCreateDocDocbook1">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <!-- create documentation PDF? -->
    <xsl:param name="switchCreateDocPDF" as="xs:string">
        <xsl:choose>
            <xsl:when test="$parameterfileavailable=false()">
                <!-- default -->
                <xsl:value-of select="''"/>
            </xsl:when>
            <xsl:when test="doc($parameterfile)/*/switchCreateDocPDF1">
                <xsl:choose>
                    <xsl:when test="doc($parameterfile)/*/switchCreateDocPDF1/@include">
                        <xsl:value-of select="doc($parameterfile)/*/switchCreateDocPDF1/@include"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'dsntri'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="''"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <!-- use local assets dir ../assets instead of online version -->
    <xsl:param name="useLocalAssets" as="xs:boolean">
        <xsl:choose>
            <xsl:when test="$parameterfileavailable=false()">
                <!-- default -->
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:when test="doc($parameterfile)/*/useLocalAssets1">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <!-- use local logos dir ../pfx-logos instead of online version -->
    <xsl:param name="useLocalLogos" as="xs:boolean">
        <xsl:choose>
            <xsl:when test="$parameterfileavailable=false()">
                <!-- default -->
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:when test="doc($parameterfile)/*/useLocalLogos1">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <!-- use latest version from ART -->
    <xsl:param name="useLatestDecorVersionString" as="xs:string" select="'false'"/>
    <xsl:param name="useLatestDecorVersion" as="xs:boolean">
        <xsl:choose>
            <xsl:when test="$useLatestDecorVersionString = 'true'">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when test="$parameterfileavailable=false()">
                <!-- default -->
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:when test="doc($parameterfile)/*/useLatestDecorVersion1">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <!-- hidecolumns for RetrieveTransaction -->
    <xsl:param name="hideColumns" as="xs:string">
        <xsl:choose>
            <xsl:when test="$parameterfileavailable=false()">
                <!-- default -->
                <xsl:value-of select="'45gh'"/>
            </xsl:when>
            <xsl:when test="doc($parameterfile)/*/useCustomRetrieve1/@hidecolumns">
                <xsl:value-of select="doc($parameterfile)/*/useCustomRetrieve1/@hidecolumns"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'45ghi'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <!-- create artefacts without timestamp directories as we are in development -->
    <xsl:param name="inDevelopmentString" as="xs:string" select="'false'"/>
    <xsl:param name="inDevelopment" as="xs:boolean">
        <xsl:choose>
            <xsl:when test="$inDevelopmentString='true'">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when test="$parameterfileavailable=false()">
                <!-- default -->
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:when test="doc($parameterfile)/*/inDevelopment1">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <!-- cache project default language as fall back -->
    <xsl:param name="projectDefaultLanguage" select="//project/@defaultLanguage" as="xs:string"/>
    <xsl:param name="latestVersion" select="max(//project/(release|version)/xs:dateTime(@date))" as="xs:dateTime?"/>
    <!-- get default language that overrides projectDefaultLanguage -->
    <xsl:param name="defaultLanguage" as="xs:string">
        <xsl:choose>
            <xsl:when test="$parameterfileavailable=true() and doc($parameterfile)/*/defaultLanguage[string-length()&gt;0]">
                <xsl:value-of select="doc($parameterfile)/*/defaultLanguage"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- default -->
                <!-- TODO: find out why just calling $projectDefaultLanguage can make both this 
                    value and projectDefaultLanguage go to the wrong language. I've seen it happen right 
                    in front of me in the Oxygen debugger on bccdapilot- with defaultLanguage=en-US, but 
                    both variables got nl-NL -->
                <xsl:value-of select="//project/@defaultLanguage"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <!-- create data type checks? -->
    <xsl:param name="switchCreateDatatypeChecksString" as="xs:string" select="'true'"/>
    <xsl:param name="switchCreateDatatypeChecks" as="xs:boolean">
        <xsl:choose>
            <xsl:when test="$switchCreateDatatypeChecksString = 'false'">
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:when test="$parameterfileavailable=false()">
                <!-- default -->
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when test="doc($parameterfile)/*/switchCreateDatatypeChecks0">
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="true()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <!-- add custom logo to HTML pages? -->
    <xsl:param name="useCustomLogo" as="xs:boolean">
        <xsl:choose>
            <xsl:when test="$parameterfileavailable=false()">
                <!-- default -->
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:when test="doc($parameterfile)/*/useCustomLogo1">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <!-- logo SRC is mandatory and may be relative local path or full URL -->
    <xsl:param name="useCustomLogoSRC" as="xs:anyURI">
        <xsl:choose>
            <xsl:when test="$parameterfileavailable=false()">
                <!-- default -->
                <xsl:value-of select="''"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="doc($parameterfile)/*/useCustomLogo1/@src"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <!-- logo may have URL -->
    <xsl:param name="useCustomLogoHREF" as="xs:anyURI">
        <xsl:choose>
            <xsl:when test="$parameterfileavailable=false()">
                <!-- default -->
                <xsl:value-of select="''"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="doc($parameterfile)/*/useCustomLogo1/@href"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <!-- create default instances in xml and html for representingTemplates? -->
    <xsl:param name="createDefaultInstancesForRepresentingTemplates" as="xs:boolean">
        <xsl:choose>
            <xsl:when test="$parameterfileavailable=false()">
                <!-- default -->
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:when test="doc($parameterfile)/*/createDefaultInstancesForRepresentingTemplates1">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <!-- 
        internal debug en test parameters
        for production mode all skip* should be set to false()
    -->
    
    <!-- whether to skip cardinality checks or not (testing) -->
    <xsl:param name="skipCardinalityChecks" select="false()" as="xs:boolean"/>
    <!-- whether to always skip predication -->
    <xsl:param name="skipPredicateCreation" select="false()" as="xs:boolean"/>
    
    <!-- ADRAM deeplink prefix for issues etc -->
    <xsl:param name="artdecordeeplinkprefix" as="xs:string?">
        <xsl:choose>
            <xsl:when test="/decor/@deeplinkprefix">
                <xsl:value-of select="/decor/@deeplinkprefix"/>
            </xsl:when>
            <xsl:when test="/decor-excerpt/@deeplinkprefix">
                <xsl:value-of select="/decor-excerpt/@deeplinkprefix"/>
            </xsl:when>
            <xsl:when test="$parameterfileavailable=true() and doc($parameterfile)/*/artdecordeeplinkprefix">
                <xsl:value-of select="doc($parameterfile)/*/artdecordeeplinkprefix/string()"/>
            </xsl:when>
        </xsl:choose>
    </xsl:param>
    <!-- if this xsl is invoked by ADRAM service the adram variable is set to the version -->
    <xsl:param name="adram" as="xs:string?"/>
    
    <!-- Binding behavior -->
    <xsl:param name="bindingBehaviorValueSetsURL" as="xs:anyURI">
        <xsl:choose>
            <xsl:when test="$projectRestUriVS[string-length()>0]">
                <xsl:value-of select="$projectRestUriVS"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'?'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <xsl:param name="bindingBehaviorValueSets" as="xs:string?">
        <xsl:choose>
            <xsl:when test="$parameterfileavailable=false()">
                <!-- default -->
                <xsl:value-of select="'freeze'"/>
            </xsl:when>
            <xsl:when test="doc($parameterfile)/*/bindingBehavior/@valueSets='preserve'">
                <xsl:choose>
                    <xsl:when test="$bindingBehaviorValueSetsURL='?'">
                        <xsl:value-of select="'insufficienturi4preserve'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'preserve'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'freeze'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    
    <!-- Do HTML with treetree/treeblank indenting (default. or set to false()) or treetable.js compatible indenting -->
    <xsl:param name="switchCreateTreeTableHtml">
        <xsl:choose>
            <xsl:when test="$parameterfileavailable=false()">
                <!-- default -->
                <xsl:value-of select="'true'"/>
            </xsl:when>
            <xsl:when test="doc($parameterfile)/*/switchCreateTreeTableHtml0">
                <xsl:value-of select="'false'"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- default -->
                <xsl:value-of select="'true'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    
    <!-- filtersfile processing -->
    <xsl:param name="filtersfile" select="concat($theBaseURI2DECOR, '/', 'filters.xml')"/>
    <xsl:param name="filtersfileavailable" select="doc-available($filtersfile)" as="xs:boolean"/>
    
    <!-- -->
    <xsl:include href="DECOR2html.xsl"/>
    <xsl:include href="DECOR2hl7v2ig.xsl"/>
    <xsl:include href="DECOR2docbook.xsl"/>
    <xsl:include href="DECOR-basics.xsl"/>
    <xsl:include href="DECOR-cardinalitycheck.xsl"/>
    <xsl:include href="DECOR-attributecheck.xsl"/>

    <!-- -->
    <xsl:output name="xml" method="xml" indent="yes" version="1.0" encoding="UTF-8" exclude-result-prefixes="#all"/>
    <xsl:output name="html" method="html" indent="yes" version="4.01" encoding="UTF-8" doctype-public="-//W3C//DTD HTML 4.01//EN" doctype-system="http://www.w3.org/TR/html4/strict.dtd"/>
    <xsl:output method="xhtml" name="xhtml" indent="yes" encoding="UTF-8" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
    <!--
    <xsl:output method="xml" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
    -->

    <!--
        some global params
    -->
    
    <!--
        some global variables
    -->
    <xsl:variable name="hasARTDECORconnection" select="doc-available('http://art-decor.org/decor/services/modules/current-milliseconds.xquery?1')" as="xs:boolean"/>
    <xsl:variable name="maxmaxmax" select="999999"/>
    <xsl:variable name="warning">THIS FILE HAS BEEN GENERATED AUTOMAGICALLY. DON'T EDIT IT.</xsl:variable>
    <xsl:variable name="maxNestingLevel" select="30"/>
    <xsl:variable name="maxRecursionLevel" select="3"/>
    
    <xd:doc>
        <xd:desc>start template for the process</xd:desc>
    </xd:doc>
    <xsl:template match="/">

        <!-- a little milestoning -->
        <xsl:variable name="processstarttime">
            <xsl:choose>
                <xsl:when test="$hasARTDECORconnection=true()">
                    <xsl:value-of select="xs:double(doc('http://art-decor.org/decor/services/modules/current-milliseconds.xquery?1'))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="0"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="xnow" select="current-dateTime()"/>
        <xsl:call-template name="logMessage">
            <xsl:with-param name="level" select="$logINFO"/>
            <xsl:with-param name="msg">
                <xsl:text>*** Started </xsl:text>
                <xsl:value-of select="$xnow"/>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:if test="decor[not(@compilationDate)]">
            <xsl:call-template name="logMessage">
                <xsl:with-param name="level" select="$logWARN"/>
                <xsl:with-param name="msg">
                    <xsl:text>+++ This DECOR project is missing decor/@compilationDate which means it is not compiled and could be incomplete due to missing referenced artefacts.</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="$parameterfileavailable">
                <xsl:call-template name="logMessage">
                    <xsl:with-param name="level" select="$logINFO"/>
                    <xsl:with-param name="msg">
                        <xsl:text>*** Reading DECOR Parameter File</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="logMessage">
                    <xsl:with-param name="level" select="$logINFO"/>
                    <xsl:with-param name="msg">
                        <xsl:text>*** No DECOR Parameter File Found. Proceeding With Defaults</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="logMessage">
            <xsl:with-param name="level" select="$logINFO"/>
            <xsl:with-param name="msg">
                <xsl:text>
</xsl:text>
                <xsl:text>    Parameter switchCreateSchematron: </xsl:text>
                <xsl:value-of select="$switchCreateSchematron"/>
                <xsl:text>
</xsl:text>
                <xsl:text>    Parameter switchCreateSchematronWithWrapperIncludes: </xsl:text>
                <xsl:value-of select="$switchCreateSchematronWithWrapperIncludes"/>
                <xsl:text>
</xsl:text>
                <xsl:text>    Parameter switchCreateSchematronWithWarningsOnOpen: </xsl:text>
                <xsl:value-of select="$switchCreateSchematronWithWarningsOnOpen"/>
                <xsl:text>
</xsl:text>
                <xsl:text>    Parameter switchCreateSchematronClosed: </xsl:text>
                <xsl:value-of select="$switchCreateSchematronClosed"/>
                <xsl:if test="$switchCreateSchematronClosed">
                    <xsl:text> -- NOTE: this setting overrides switchCreateSchematronWithWarningsOnOpen</xsl:text>
                </xsl:if>
                <xsl:text>
</xsl:text>
                <xsl:text>    Parameter switchCreateSchematronWithExplicitIncludes: </xsl:text>
                <xsl:value-of select="$switchCreateSchematronWithExplicitIncludes"/>
                <xsl:text>
</xsl:text>
                <xsl:text>    Parameter switchCreateDocHTML: </xsl:text>
                <xsl:value-of select="$switchCreateDocHTML"/>
                <xsl:text>
</xsl:text>
                <xsl:text>    Parameter switchCreateDocSVG: </xsl:text>
                <xsl:value-of select="$switchCreateDocSVG"/>
                <xsl:text>
</xsl:text>
                <xsl:text>    Parameter switchCreateDocDocbook: </xsl:text>
                <xsl:value-of select="$switchCreateDocDocbook"/>
                <xsl:text>
</xsl:text>
                <xsl:text>    Parameter switchCreateDocPDF: </xsl:text>
                <xsl:value-of select="$switchCreateDocPDF"/>
                <xsl:text>
</xsl:text>
                <xsl:text>    Parameter useLocalAssets: </xsl:text>
                <xsl:value-of select="$useLocalAssets"/>
                <xsl:text>
</xsl:text>
                <xsl:text>    Parameter useLocalLogos: </xsl:text>
                <xsl:value-of select="$useLocalLogos"/>
                <xsl:text>
</xsl:text>
                <xsl:text>    Parameter inDevelopment: </xsl:text>
                <xsl:value-of select="$inDevelopment"/>
                <xsl:text>
</xsl:text>
                <xsl:text>    Parameter defaultLanguage: </xsl:text>
                <xsl:value-of select="$defaultLanguage"/>
                <xsl:text>
</xsl:text>
                <xsl:text>    Parameter switchCreateDatatypeChecks: </xsl:text>
                <xsl:value-of select="$switchCreateDatatypeChecks"/>
                <xsl:text>
</xsl:text>
                <xsl:text>    Parameter useCustomLogo: </xsl:text>
                <xsl:value-of select="$useCustomLogo"/>
                <xsl:text>
</xsl:text>
                <xsl:text>    Parameter useCustomLogoSRC: </xsl:text>
                <xsl:value-of select="$useCustomLogoSRC"/>
                <xsl:text>
</xsl:text>
                <xsl:text>    Parameter useCustomLogoHREF: </xsl:text>
                <xsl:value-of select="$useCustomLogoHREF"/>
                <xsl:text>
</xsl:text>
                <xsl:text>    Parameter createDefaultInstancesForRepresentingTemplates: </xsl:text>
                <xsl:value-of select="$createDefaultInstancesForRepresentingTemplates"/>
                <xsl:text>
</xsl:text>
                <xsl:text>    Parameter artdecordeeplinkprefix: </xsl:text>
                <xsl:value-of select="$artdecordeeplinkprefix"/>
                <xsl:if test="string-length($artdecordeeplinkprefix)=0">
                    <xsl:text> &lt;-- WARNING: should not be empty!</xsl:text>
                </xsl:if>
                <xsl:text>
</xsl:text>
                <xsl:text>    Parameter bindingBehavior: valueSets </xsl:text>
                <xsl:value-of select="$bindingBehaviorValueSets"/>
                <xsl:if test="string-length($bindingBehaviorValueSets)=0">
                    <xsl:text> &lt;-- WARNING: should not be empty!</xsl:text>
                </xsl:if>
                <xsl:if test="$bindingBehaviorValueSets='insufficienturi4preserve'">
                    <xsl:text> &lt;-- WARNING: (ignored: preserve) you must define an approriate restURI in the project for truly dynamic value set bindings!</xsl:text>
                </xsl:if>
                <xsl:text>
</xsl:text>
                <xsl:text>    Parameter logLevel: </xsl:text>
                <xsl:value-of select="$theLogLevel"/>
                <xsl:text>
</xsl:text>
                <xsl:text>    Parameter switchCreateTreeTableHtml: </xsl:text>
                <xsl:value-of select="$switchCreateTreeTableHtml"/>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:if test="$parameterfileavailable=false() and string-length($outputBaseUriPrefix)=0">
            <xsl:call-template name="logMessage">
                <xsl:with-param name="level" select="$logINFO"/>
                <xsl:with-param name="msg">
                    <xsl:text>*** Creating decor-parameters.xml with default values</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:result-document href="decor-parameters.xml" format="xml">
                <decor-parameters xmlns="" xsi:noNamespaceSchemaLocation="{$theAssetsDir}../decor-parameters.xsd">
                    <xsl:comment> create Schematron1 or not (Schematron0) </xsl:comment>
                    <xsl:choose>
                        <xsl:when test="$switchCreateSchematron">
                            <switchCreateSchematron1/>
                        </xsl:when>
                        <xsl:otherwise>
                            <switchCreateSchematron0/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:comment> create WithWrapperIncludes1 or not (WithWrapperIncludes0) </xsl:comment>
                    <xsl:choose>
                        <xsl:when test="$switchCreateSchematronWithWrapperIncludes">
                            <switchCreateSchematronWithWrapperIncludes1/>
                        </xsl:when>
                        <xsl:otherwise>
                            <switchCreateSchematronWithWrapperIncludes0/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="$switchCreateSchematronWithWarningsOnOpen">
                            <switchCreateSchematronWithWarningsOnOpen1/>
                        </xsl:when>
                        <xsl:otherwise>
                            <switchCreateSchematronWithWarningsOnOpen0/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="$switchCreateSchematronClosed">
                            <switchCreateSchematronClosed1/>
                        </xsl:when>
                        <xsl:otherwise>
                            <switchCreateSchematronClosed0/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="$switchCreateSchematronWithExplicitIncludes">
                            <switchCreateSchematronWithExplicitIncludes1/>
                        </xsl:when>
                        <xsl:otherwise>
                            <switchCreateSchematronWithExplicitIncludes0/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:comment> create DocHTML1 or not (DocHTML0) </xsl:comment>
                    <xsl:choose>
                        <xsl:when test="$switchCreateDocHTML">
                            <switchCreateDocHTML1/>
                        </xsl:when>
                        <xsl:otherwise>
                            <switchCreateDocHTML0/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:comment> create SVG1 or not (SVG0) </xsl:comment>
                    <xsl:choose>
                        <xsl:when test="$switchCreateDocSVG">
                            <switchCreateDocSVG1/>
                        </xsl:when>
                        <xsl:otherwise>
                            <switchCreateDocSVG0/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:comment> create DocBook1 or not (DocBook0) </xsl:comment>
                    <xsl:choose>
                        <xsl:when test="$switchCreateDocDocbook">
                            <switchCreateDocDocbook1/>
                        </xsl:when>
                        <xsl:otherwise>
                            <switchCreateDocDocbook0/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:comment> create PDF1 or not (PDF0) </xsl:comment>
                    <xsl:choose>
                        <xsl:when test="string-length($switchCreateDocPDF)&gt;0">
                            <switchCreateDocPDF1 include="{$switchCreateDocPDF}"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <switchCreateDocPDF0/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:comment> use local assets dir ../assets instead of online version </xsl:comment>
                    <xsl:choose>
                        <xsl:when test="$useLocalAssets">
                            <useLocalAssets1/>
                        </xsl:when>
                        <xsl:otherwise>
                            <useLocalAssets0/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:comment> use local logos dir ../pfx-logos instead of online version </xsl:comment>
                    <xsl:choose>
                        <xsl:when test="$useLocalLogos">
                            <useLocalLogos1/>
                        </xsl:when>
                        <xsl:otherwise>
                            <useLocalLogos0/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:comment> useCustomLogo </xsl:comment>
                    <xsl:choose>
                        <xsl:when test="$useCustomLogo">
                            <useCustomLogo1 src="{$useCustomLogoSRC}" href="{$useCustomLogoHREF}"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <useCustomLogo0 src="{$useCustomLogoSRC}" href="{$useCustomLogoHREF}"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="$useLatestDecorVersion">
                            <useLatestDecorVersion1/>
                        </xsl:when>
                        <xsl:otherwise>
                            <useLatestDecorVersion0/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:comment> create artefacts without timestamp directories as we are in development </xsl:comment>
                    <xsl:choose>
                        <xsl:when test="$inDevelopment">
                            <inDevelopment1/>
                        </xsl:when>
                        <xsl:otherwise>
                            <inDevelopment0/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:comment> override /decor/project/@language default language, or set if not given there </xsl:comment>
                    <xsl:comment> &lt;defaultLanguage&gt;nl-NL&lt;defaultLanguage&gt; </xsl:comment>
                    <xsl:comment> need to keep those off for big projects due to memory constraints, but active otherwise </xsl:comment>
                    <xsl:choose>
                        <xsl:when test="$switchCreateDatatypeChecks">
                            <switchCreateDatatypeChecks1/>
                        </xsl:when>
                        <xsl:otherwise>
                            <switchCreateDatatypeChecks0/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:comment> create instances that mimic the specification </xsl:comment>
                    <xsl:choose>
                        <xsl:when test="$createDefaultInstancesForRepresentingTemplates">
                            <createDefaultInstancesForRepresentingTemplates0/>
                        </xsl:when>
                        <xsl:otherwise>
                            <createDefaultInstancesForRepresentingTemplates0/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:comment> determine binding behavior </xsl:comment>
                    <xsl:choose>
                        <xsl:when test="$bindingBehaviorValueSets='preserve'">
                            <bindingBehavior valueSets="preserve"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <bindingBehavior valueSets="freeze"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>
    </xsl:text>
                    <xsl:comment> log at level (ALL, DEBUG, INFO, WARN, ERROR, FATAL, OFF) </xsl:comment>
                    <logLevel>
                        <xsl:value-of select="$theLogLevel"/>
                    </logLevel>
                    <xsl:text>
</xsl:text>
                    <xsl:comment> Relevant for HTML only. Implements treetable.js based table views if 'switchCreateTreeTableHtml1' or traditional tables otherwise </xsl:comment>
                    <xsl:choose>
                        <xsl:when test="$switchCreateTreeTableHtml='true'">
                            <switchCreateTreeTableHtml1/>
                        </xsl:when>
                        <xsl:otherwise>
                            <switchCreateTreeTableHtml0/>
                        </xsl:otherwise>
                    </xsl:choose>
                </decor-parameters>
            </xsl:result-document>
        </xsl:if>
        
        <xsl:if test="$switchCreateSchematron=true()">
            <!-- a little milestoning -->
            <xsl:call-template name="logMessage">
                <xsl:with-param name="level" select="$logINFO"/>
                <xsl:with-param name="msg">
                    <xsl:text>*** Creating Schematrons Based On Scenario Transaction Representing Templates</xsl:text>
                    <xsl:if test="$switchCreateSchematronWithWrapperIncludes=true()">
                        <xsl:text> with wrapper includes if available</xsl:text>
                    </xsl:if>
                </xsl:with-param>
            </xsl:call-template>

            <!-- first get some benchmarking parameters -->
            <!-- number of templates, includes and elements with @contains -->
            <xsl:variable name="overallTemplateReferenceCount" select="count(//rules/template) + count(//rules//include) + count(//rules//*[@contains])"/>
            <xsl:call-template name="logMessage">
                <xsl:with-param name="level" select="$logINFO"/>
                <xsl:with-param name="msg">
                    <xsl:text>*** Overall Benchmarking Indicator: </xsl:text>
                    <xsl:value-of select="$overallTemplateReferenceCount"/>
                </xsl:with-param>
            </xsl:call-template>
            
            <!-- apply transformation to rules in DECOR file, make Runtime Environment -->
            <xsl:apply-templates select="decor"/>
            
            <!-- create one sch file for each scenario transaction representing template with a model -->
            <xsl:for-each select="$allScenarios/scenarios/scenario//transaction[representingTemplate/@ref]">
                <xsl:variable name="rlabel" select="if (@label) then (normalize-space(@label)) else (@id)"/>
                <xsl:variable name="theTemplate" as="element(template)*">
                    <xsl:call-template name="getRulesetContent">
                        <xsl:with-param name="ruleset" select="representingTemplate/@ref"/>
                        <xsl:with-param name="flexibility" select="representingTemplate/@flexibility"/>
                        <xsl:with-param name="sofar" select="()"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="theDatatypeType" select="local:getTemplateFormat($theTemplate)" as="xs:string?"/>
                <xsl:result-document href="{$theRuntimeDir}{$projectPrefix}{$rlabel}.sch" format="xml">

                    <!-- include the xsl proc instr to easily convert the resulting sch file into xsl -->
                    <schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
                        <title>
                            <xsl:text> Schematron file for </xsl:text>
                            <xsl:value-of select="@model"/>
                            <xsl:text> - </xsl:text>
                            <xsl:value-of select="name[@language=$defaultLanguage]"/>
                            <xsl:text> </xsl:text>
                        </title>

                        <!-- default namespaces -->
                        <ns uri="urn:hl7-org:v3" prefix="hl7"/>
                        <ns uri="urn:hl7-org:v3" prefix="cda"/>
                        <ns uri="http://www.w3.org/2001/XMLSchema-instance" prefix="xsi"/>
                        <ns uri="http://www.w3.org/2001/XMLSchema" prefix="xs"/>
                        <xsl:comment> Add extra namespaces </xsl:comment>

                        <!-- get the other "foreign" namespaces of the DECOR root element -->
                        <xsl:for-each-group select="namespace::node() | $allTemplates//ref/template/namespace::node()" group-by=".">
                            <xsl:if test="not(current-group()[1] = ('urn:hl7-org:v3', 'http://www.w3.org/2001/XMLSchema', 'http://www.w3.org/2001/XMLSchema-instance'))">
                                <ns uri="{current-group()[1]}" prefix="{name(current-group()[1])}"/>
                            </xsl:if>
                        </xsl:for-each-group>

                        <!-- do print copyright stuff etc -->
                        <xsl:apply-templates select="//project">
                            <xsl:with-param name="what">
                                <xsl:value-of select="concat('Schematron schema for ', name[@language=$defaultLanguage], ' (', $rlabel, ')')"/>
                            </xsl:with-param>
                        </xsl:apply-templates>
                        <xsl:comment> Include realm specific schematron </xsl:comment>
                        <!-- this is the include directory -->
                        <xsl:variable name="theIncludeDir" select="concat('include', '/')"/>
                        
                        <xsl:if test="$switchCreateSchematronWithWrapperIncludes=true()">
                            <xsl:text>
</xsl:text>
                            <xsl:choose>
                                <xsl:when test="$supportedDatatypes/*[@type = 'hl7v3xml1'] and $defaultLanguage='nl-NL'">
                                    <!-- Include wrapper schematrons -->
                                    <include href="{concat($theIncludeDir, 'DTr1_XML.NL.sch')}"/>
                                    <include href="{concat($theIncludeDir, 'transmission-wrapper.NL.sch')}"/>
                                    <!--<include href="{concat($theIncludeDir, 'attentionLine.NL.sch')}"/>-->
                                    <include href="{concat($theIncludeDir, 'controlAct-wrapper.NL.sch')}"/>
                                    <pattern is-a="transmission-wrapper" id="{@model}-wrapper">
                                        <param name="element" value="{concat($projectDefaultElementPrefix, @model)}"/>
                                    </pattern>
                                    <pattern is-a="controlAct-wrapper" id="{@model}-controlAct">
                                        <param name="element" value="{concat($projectDefaultElementPrefix, @model, '/', $projectDefaultElementPrefix, 'ControlActProcess')}"/>
                                    </pattern>
                                    <pattern>
                                        <!-- profileId -->
                                        <rule context="{concat($projectDefaultElementPrefix, @model, '/', $projectDefaultElementPrefix, 'profileId')}">
                                            <extends rule="II"/>
                                            <assert role="error" test="@root='2.16.840.1.113883.2.4.3.11.1' and @extension='810'">In de transmission wrapper moet het element profileId worden gevuld met de waarde '810'</assert>
                                        </rule>
                                    </pattern>
                                </xsl:when>
                                <xsl:otherwise>
                                    <!-- nothing to be included here 2DO: multi lang support -->
                                    <xsl:comment> none </xsl:comment>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                        <xsl:if test="$projectPrefix= ('elga-', 'elgasandox-', 'elgabbr-')">
                            <include href="{concat($theIncludeDir, 'check-CDA-tables.AT.sch')}"/>
                        </xsl:if>
                        <xsl:comment> Include datatype abstract schematrons </xsl:comment>
                        <xsl:text>
</xsl:text>
                        
                        <pattern>
                            <!-- DONE: used to work only for HL7 V3/CDA datatypes. Now works for all template/classification/@format -->
                            <xsl:for-each-group select="$supportedDatatypes/*[@type = $theDatatypeType]" group-by="@name">
                                <xsl:sort select="@type"/>
                                <xsl:sort select="lower-case(@name)"/>
                                <xsl:variable name="thePFX" as="xs:string">
                                    <xsl:call-template name="SupportedDatatypeToPrefix">
                                        <xsl:with-param name="type" select="@type"/>
                                    </xsl:call-template>
                                </xsl:variable>
                                <xsl:variable name="theDT" select="concat($thePFX, replace(@name,':','-'), '.sch')"/>
                                <include href="{$theIncludeDir}{replace($theDT,':','-')}"/>
                                <xsl:text>
</xsl:text>
                            </xsl:for-each-group>
                        </pattern>
                        <xsl:text>
</xsl:text>
                        <xsl:text>
</xsl:text>

                        <!-- 2DO REALM SPECIFIC SCHEMATRON INCLUDES -->
                        <xsl:comment>
                            <xsl:text> Include the project schematrons related to scenario </xsl:text>
                            <xsl:value-of select="$rlabel"/>
                            <xsl:text> </xsl:text>
                        </xsl:comment>
                        <xsl:text>

</xsl:text>

                        <!-- 
                            a transaction with a model has 0..1 representingTemplate ref's
                            this template is to be included anyway, if present
                            if it has no context (because then it will be included later with context)
                        -->
                        <xsl:for-each select="representingTemplate[@ref]">
                            <xsl:variable name="rtid" select="@ref"/>
                            <xsl:variable name="rtflex" select="if (@flexibility) then (@flexibility) else ('dynamic')"/>
                            <xsl:variable name="rccontent" as="element()?">
                                <xsl:call-template name="getRulesetContent">
                                    <xsl:with-param name="ruleset" select="$rtid"/>
                                    <xsl:with-param name="flexibility" select="$rtflex"/>
                                    <xsl:with-param name="sofar" select="()"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:variable name="rtin" select="$rccontent/@name"/>
                            <xsl:variable name="rted" select="$rccontent/@effectiveDate"/>
                            <xsl:if test="$rccontent">
                                <!-- a template exists, include it -->
                                <xsl:comment>
                                    <xsl:text> </xsl:text>
                                    <xsl:value-of select="$rtin"/>
                                    <xsl:text> </xsl:text>
                                </xsl:comment>
                                <xsl:text>
</xsl:text>
                                <include href="{$theIncludeDir}{$rtid}-{replace($rted,':','')}.sch"/>
                                <include href="{$theIncludeDir}{$rtid}-{replace($rted,':','')}-closed.sch"/>
                                <xsl:text>
</xsl:text>
                            </xsl:if>
                            <xsl:variable name="templatesInThisRepresentingTemplate" as="element()*">
                                <xsl:call-template name="getAssociatedTemplates">
                                    <xsl:with-param name="rccontent" select="$rccontent"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:variable name="currentTemplateReferenceCount" select="count($templatesInThisRepresentingTemplate/descendant-or-self::template)"/>
                            <xsl:variable name="currentTemplateRecursionCount" select="count($templatesInThisRepresentingTemplate/descendant-or-self::recurse)"/>
                            <xsl:variable name="currentTemplateNestingCount" select="count($templatesInThisRepresentingTemplate/descendant-or-self::tooDeeplyNested)"/>
                            
                            <xsl:call-template name="logMessage">
                                <xsl:with-param name="level" select="$logINFO"/>
                                <xsl:with-param name="msg">
                                    <xsl:text>*** Benchmarking Indicator For Transaction '</xsl:text>
                                    <xsl:value-of select="parent::transaction/name[@language=$defaultLanguage][1]"/>
                                    <xsl:if test="parent::transaction/@versionLabel">
                                        <xsl:value-of select="concat(' (', parent::transaction/@versionLabel, ')')"/>
                                    </xsl:if>
                                    <xsl:text>': </xsl:text>
                                    <xsl:value-of select="$currentTemplateReferenceCount"/>
                                    <xsl:if test="$currentTemplateRecursionCount>0">
                                        <xsl:text> (recursions</xsl:text>
                                        <!--
                                        <xsl:text>: </xsl:text>
                                        <xsl:value-of select="$currentTemplateRecursionCount"/>
                                        -->
                                        <xsl:text>) </xsl:text>
                                        <xsl:value-of select="$currentTemplateNestingCount"/>
                                    </xsl:if>
                                    <xsl:if test="$currentTemplateNestingCount>0">
                                        <xsl:text> (+++too deeply nested)</xsl:text>
                                    </xsl:if>
                                    <!--
                                    <xsl:copy-of select="$templatesInThisRepresentingTemplate"/>
                                    -->
                                </xsl:with-param>
                            </xsl:call-template>
                            <!-- Don't bark for MCCI_IN000002 as the count is usually 0 there... -->
                            <xsl:if test="$currentTemplateReferenceCount = 0 and not($rccontent[context[contains(@path,'MCCI_IN000002')] | element[contains(@name,'MCCI_IN000002')]] or $rccontent[element | include | choice])">
                                <xsl:call-template name="logMessage">
                                    <xsl:with-param name="level" select="$logWARN"/>
                                    <xsl:with-param name="terminate" select="false()"/>
                                    <xsl:with-param name="msg">
                                        <xsl:text>+++ Suspicious benchmark 0 for transaction '</xsl:text>
                                        <xsl:value-of select="parent::transaction/name[@language=$defaultLanguage][1]"/>
                                        <xsl:text>'! Wrong or bad refererence for/with representingTemplate id=</xsl:text>
                                        <xsl:value-of select="$rtid"/>
                                        <xsl:text> flexibility=</xsl:text>
                                        <xsl:value-of select="$rtflex"/>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </xsl:if>

                            <!-- all templates with an explicit context as a template id, latest version only -->

                            <!-- store includes and phase in a variable first -->
                            <xsl:variable name="tobeincluded" >
                                <xsl:for-each-group select="$allTemplates/*/ref" group-by="concat(@ref,@effectiveDate)">
                                    <xsl:sort select="@ref"/>
                                    <xsl:sort select="@effectiveDate"/>
                                    <xsl:if test="not(@duplicateOf) and template[not(@id=$rtid and @effectiveDate=$rted)]/context[@id=('*','**')]">
                                        <xsl:variable name="tid" select="template/@id"/>
                                        <xsl:variable name="tin" select="template/@name"/>
                                        <xsl:variable name="tif" select="template/@effectiveDate"/>
                                        <xsl:variable name="tcl" select="template/@isClosed='true'" as="xs:boolean"/>
                                        <xsl:variable name="tIsNewestForId" select="parent::ref/@newestForId"/>
                                        <xsl:if test="count($allScenarios//representingTemplate[@id=$tid or @ref=$tid][((not(@flexibility) or @flexibility='dynamic') and $tIsNewestForId) or @flexibility=$tif])=0">
                                            <!-- using id of ref is for backward compatibility -->
                                            <!-- a template exists and is not a representingTemplate,  -->
                                            <xsl:if test="$switchCreateSchematronWithExplicitIncludes = false() or $templatesInThisRepresentingTemplate/descendant-or-self::template[@id=$tid][@effectiveDate=$tif]">
                                                <!-- 
                                                    still in testing mode...
                                                    it is part of it, include it as an include 
                                                -->
                                                <xsl:comment>
                                                    <xsl:text> </xsl:text>
                                                    <xsl:value-of select="$tin"/>
                                                    <xsl:text> </xsl:text>
                                                </xsl:comment>
                                                <include href="{$theIncludeDir}{$tid}-{replace($tif,':','')}.sch"/>
                                                <xsl:if test="$tcl">
                                                    <include href="{$theIncludeDir}{$tid}-{replace($tif,':','')}-closed.sch"/>
                                                </xsl:if>
                                                <xsl:text>
</xsl:text>
                                                <!-- 
                                                    add it as a selectable phase, also to keep used memory per phase 
                                                    and not all in one for large projects with many templates 
                                                -->
                                                <phase id="{$tin}">
                                                    <active pattern="template-{$tid}-{replace($tif,':','')}"/>
                                                </phase>
                                                <xsl:if test="$tcl">
                                                    <phase id="{$tin}-closed">
                                                        <active pattern="template-{$tid}-{replace($tif,':','')}-closed"/>
                                                    </phase>
                                                </xsl:if>
                                                <xsl:text>
</xsl:text>
                                            </xsl:if>
                                        </xsl:if>
                                    </xsl:if>
                                </xsl:for-each-group>
                            </xsl:variable>
                            <xsl:text>
</xsl:text>
                            
                            <!-- TODO: $currentTemplateReferenceCount yields totally different numbers than $overallTemplateReferenceCount. -->
                            <!-- For reference: Jeugdgezondheidszorg has oTRC of 1286 and cTRC of 599 -->
                            <xsl:if test="($switchCreateSchematronWithExplicitIncludes = false() and $overallTemplateReferenceCount &gt;= 1000) or
                                          ($switchCreateSchematronWithExplicitIncludes = true() and $currentTemplateReferenceCount &gt;= 500)">
                                <!-- 
                                    rough estimation: if benchmarker too high, use phases to prevent too
                                    much memory to be used for validation because it is done stepwise 
                                -->
                                <!-- emit phases -->
                                <xsl:text>
</xsl:text>
                                <xsl:comment> Create phases for more targeted validation on large instances </xsl:comment>
                                <xsl:text>
</xsl:text>
                                <xsl:if test="$tobeincluded[*:phase]">
                                    <xsl:variable name="allExcepClosedPhaseName">
                                        <xsl:choose>
                                            <xsl:when test="$tobeincluded/*:phase[@name='AllExceptClosed']">
                                                <xsl:value-of select="concat('AllExceptClosed-',generate-id())"/>
                                            </xsl:when>
                                            <xsl:otherwise>AllExceptClosed</xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>
                                    <phase id="{$allExcepClosedPhaseName}">
                                        <active pattern="template-{$rtid}-{replace($rted,':','')}"/>
                                        <xsl:copy-of select="$tobeincluded/*:phase[not(ends-with(@id,'-closed'))]/*"/>
                                    </phase>
                                    <phase id="{$rtin}">
                                        <active pattern="template-{$rtid}-{replace($rted,':','')}"/>
                                    </phase>
                                    <phase id="{$rtin}-closed">
                                        <active pattern="template-{$rtid}-{replace($rted,':','')}-closed"/>
                                    </phase>
                                </xsl:if>
                                <xsl:copy-of select="$tobeincluded/*:phase"/>
                            </xsl:if>

                            <!-- emit includes -->
                            <xsl:text>
</xsl:text>
                            <xsl:text>
</xsl:text>
                            <xsl:comment> Include schematrons from templates with explicit * or ** context (but no representing templates), only those used in scenario template </xsl:comment>
                            <xsl:text>
</xsl:text>
                            <xsl:text>
</xsl:text>
                            <xsl:for-each select="$tobeincluded/*:include|$tobeincluded/comment()">
                                <xsl:copy-of select="self::node()"/>
                                <xsl:if test="self::comment() and position()!=last()">
                                    <xsl:text>
</xsl:text>
                                </xsl:if>
                            </xsl:for-each>

                            <xsl:call-template name="logMessage">
                                <xsl:with-param name="level" select="$logINFO"/>
                                <xsl:with-param name="msg">
                                    <xsl:text>    Included templates: </xsl:text>
                                    <xsl:value-of select="count($tobeincluded/*:include)"/>
                                </xsl:with-param>
                            </xsl:call-template>
                            
                        </xsl:for-each>
                        <xsl:text>

</xsl:text>
                    </schema>
                </xsl:result-document>
            </xsl:for-each>
            
            <!-- build instance2schematron.xml -->
            <xsl:call-template name="buildInstanceToSchematron"/>
            
            <!-- 
                copy all supported data types schematrons to the runtime environment
                test output
            -->
            <!--<xsl:message terminate="yes">
                <x>
                    <e1>
                        <xsl:copy-of select="$supportedDatatypes"/>
                    </e1>
                    <e2>
                        <xsl:copy-of select="$supportedAtomicDatatypes"/>
                    </e2>
                </x>
            </xsl:message>-->
            <!-- DONE: used to work only for HL7 V3/CDA datatypes. Now works for all template/classification/@format -->
            <xsl:for-each-group select="$supportedDatatypes/*" group-by="concat(@type, @name)">
                <xsl:variable name="thePFX" as="xs:string">
                    <xsl:call-template name="SupportedDatatypeToPrefix">
                        <xsl:with-param name="type" select="@type"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="theDIR" as="xs:string">
                    <xsl:call-template name="SupportedDatatypeToDir">
                        <xsl:with-param name="type" select="@type"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="theDT" select="concat($thePFX, replace(@name,':','-'), '.sch')"/>
                <xsl:call-template name="logMessage">
                    <xsl:with-param name="level" select="$logALL"/>
                    <xsl:with-param name="msg">
                        <xsl:value-of select="concat($theDIR, $theDT)"/>
                        <xsl:text> - </xsl:text>
                        <xsl:value-of select="concat($theRuntimeDir, $theDT)"/>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="doCopyFile">
                    <xsl:with-param name="from" select="concat($theDIR, replace($theDT,':','-'))"/>
                    <xsl:with-param name="to" select="concat($theRuntimeIncludeDir, replace($theDT,':','-'))"/>
                </xsl:call-template>
                <xsl:text>
</xsl:text>
            </xsl:for-each-group>
            
            <!-- copy all UCUM codes for validation-->
            <xsl:call-template name="doCopyFile">
                <xsl:with-param name="from" select="'DECOR-ucum.xml'"/>
                <xsl:with-param name="to" select="concat($theRuntimeIncludeDir, 'voc-UCUM.xml')"/>
            </xsl:call-template>
            
            <!-- 2DO: temporary for DUTCH IMPLEMENTATIONS !!!!!!!!!!!!!! -->
            <xsl:if test="$switchCreateSchematronWithWrapperIncludes=true()">
                <xsl:choose>
                    <xsl:when test="$defaultLanguage='nl-NL'">
                        <xsl:call-template name="doCopyFile">
                            <xsl:with-param name="from" select="concat('coreschematrons/','DTr1_XML.NL.sch')"/>
                            <xsl:with-param name="to" select="concat($theRuntimeIncludeDir, 'DTr1_XML.NL.sch')"/>
                        </xsl:call-template>
                        <xsl:call-template name="doCopyFile">
                            <xsl:with-param name="from" select="concat('coreschematrons/','transmission-wrapper.NL.sch')"/>
                            <xsl:with-param name="to" select="concat($theRuntimeIncludeDir, 'transmission-wrapper.NL.sch')"/>
                        </xsl:call-template>
                        <xsl:call-template name="doCopyFile">
                            <xsl:with-param name="from" select="concat('coreschematrons/','controlAct-wrapper.NL.sch')"/>
                            <xsl:with-param name="to" select="concat($theRuntimeIncludeDir, 'controlAct-wrapper.NL.sch')"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$defaultLanguage='de-DE'">
                        <xsl:call-template name="doCopyFile">
                            <xsl:with-param name="from" select="concat('coreschematrons/','DTr1_XML.DE.sch')"/>
                            <xsl:with-param name="to" select="concat($theRuntimeIncludeDir, 'DTr1_XML.DE.sch')"/>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </xsl:if>
            <!-- 2DO: temporary for AUSTRIAN IMPLEMENTATIONS !!!!!!!!!!!!!! -->
            <xsl:if test="$projectPrefix = ('elga-', 'elgasandbox-', 'elgabbr-')">
                <xsl:call-template name="doCopyFile">
                    <xsl:with-param name="from" select="concat('coreschematrons/','check-CDA-tables.AT.sch')"/>
                    <xsl:with-param name="to" select="concat($theRuntimeIncludeDir, 'check-CDA-tables.AT.sch')"/>
                </xsl:call-template>
            </xsl:if>
            
            <!-- a little milestoning -->
            <xsl:call-template name="logMessage">
                <xsl:with-param name="level" select="$logINFO"/>
                <xsl:with-param name="msg">
                    <xsl:text>*** Creating Schematron mapping file</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>

        <!-- rendered all DECOR objects as HTML using special stylesheet, write it to html dir as index.html -->
        <xsl:if test="$switchCreateDocHTML=true()">
            <!-- a little milestoning -->
            <xsl:call-template name="logMessage">
                <xsl:with-param name="level" select="$logINFO"/>
                <xsl:with-param name="msg">
                    <xsl:text>*** Creating Documentation html</xsl:text>
                    <xsl:if test="$switchCreateDocSVG=true()">
                        <xsl:text> + svg</xsl:text>
                    </xsl:if>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="convertDECOR2HTML"/>
            <html xml:lang="{substring($defaultLanguage,1,2)}" lang="{substring($defaultLanguage,1,2)}" xmlns="http://www.w3.org/1999/xhtml">
                <head>
                    <meta http-equiv="refresh" content="0; URL={$theHtmlDir}index.html"/>
                    <meta name="robots" content="noindex, nofollow"/>
                    <meta http-equiv="expires" content="0"/>
                    <!-- xhtml requirement -->
                    <title>Index</title>
                </head>
                <!-- xhtml requirement -->
                <body/>
            </html>
        </xsl:if>
        
        <!-- template checks HTML and Schematron switches -->
        <xsl:call-template name="doV2ImplementationGuidesAndConformanceProfiles"/>
        
        <!--
            render all DECOR objects as DOCBOOK using special stylesheet, write it to docbook file object as docbook-test.xml
        -->
        <xsl:if test="$switchCreateDocDocbook=true()">
            <!-- a little milestoning -->
            <xsl:call-template name="logMessage">
                <xsl:with-param name="level" select="$logINFO"/>
                <xsl:with-param name="msg">
                    <xsl:text>*** Creating Documentation docbook</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="convertDECOR2DOCBOOKPDF">
                <xsl:with-param name="doDocbook" select="true()"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="string-length($switchCreateDocPDF)&gt;0">
            <!-- a little milestoning -->
            <xsl:call-template name="logMessage">
                <xsl:with-param name="level" select="$logINFO"/>
                <xsl:with-param name="msg">
                    <xsl:text>*** Creating Documentation PDF</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="convertDECOR2DOCBOOKPDF">
                <xsl:with-param name="projectinformation" select="true()"/>
                <xsl:with-param name="datasetinfornation" select="contains($switchCreateDocPDF, 'd')"/>
                <xsl:with-param name="scenarioinformation" select="contains($switchCreateDocPDF, 's')"/>
                <xsl:with-param name="identifierinformation" select="contains($switchCreateDocPDF, 'n')"/>
                <xsl:with-param name="terminologyinformation" select="contains($switchCreateDocPDF, 't')"/>
                <xsl:with-param name="rulesinformation" select="contains($switchCreateDocPDF, 'r')"/>
                <xsl:with-param name="issuesinformation" select="contains($switchCreateDocPDF, 'i')"/>
                <xsl:with-param name="doPDF" select="true()"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="$createDefaultInstancesForRepresentingTemplates=true()">
            <!-- test create instance -->
            <!-- a little milestoning -->
            <xsl:call-template name="logMessage">
                <xsl:with-param name="level" select="$logINFO"/>
                <xsl:with-param name="msg">
                    <xsl:text>*** Creating default instances for representing templates</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:for-each select="$allScenarios//representingTemplate[@ref]">
                <xsl:variable name="trid" select="parent::transaction/@id"/>
                <!-- cache transaction/@effectiveDate. This is relatively new so might not be present -->
                <xsl:variable name="treff" select="parent::transaction/@effectiveDate"/>
                <xsl:variable name="tid" select="@ref"/>
                <xsl:variable name="tflex" select="@flexibility"/>
                <xsl:variable name="rccontent" as="element(template)?">
                    <xsl:call-template name="getRulesetContent">
                        <xsl:with-param name="ruleset" select="$tid"/>
                        <xsl:with-param name="flexibility" select="$tflex"/>
                        <xsl:with-param name="sofar" select="()"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="tef" select="$rccontent/@effectiveDate"/>
                <xsl:choose>
                    <xsl:when test="$rccontent">
                        <xsl:call-template name="logMessage">
                            <xsl:with-param name="level" select="$logDEBUG"/>
                            <xsl:with-param name="msg">
                                <xsl:text>*** Instance files HTML/XML for transaction: name='</xsl:text>
                                <xsl:value-of select="parent::transaction/name[1]"/>
                                <xsl:text>' id='</xsl:text>
                                <xsl:value-of select="$trid"/>
                                <xsl:text>' effectiveDate='</xsl:text>
                                <xsl:value-of select="parent::transaction/@effectiveDate"/>
                                <xsl:text>'</xsl:text>
                            </xsl:with-param>
                        </xsl:call-template>
                        
                        <!-- Build instances first leaving references in for the second round of (fairly simple) processing
                            The second step builds child elements under relevant elements. We cannot do that in one go
                            because includes that reference templates that start with <attributes .../> would create
                            attributes after the element is already closed.
                        -->
                        <xsl:variable name="instancesStep1">
                            <instances xmlns="">
                                <xsl:copy-of select="parent::transaction/@*" copy-namespaces="no"/>
                                <xsl:if test="@sourceDataset">
                                    <xsl:variable name="dsid" select="@sourceDataset"/>
                                    <xsl:variable name="dsed" select="@sourceDatasetFlexibility"/>
                                    <xsl:variable name="dataset" select="if ($dsid) then local:getDataset($dsid, $dsed) else ()" as="element()?"/>
                                    <dataset id="{@sourceDataset}">
                                        <xsl:copy-of select="$dataset/(@* except (@id))" copy-namespaces="no"/>
                                        <xsl:copy-of select="$dataset/name" copy-namespaces="no"/>
                                    </dataset>
                                </xsl:if>
                                <xsl:apply-templates select="$rccontent" mode="createDefaultInstance">
                                    <xsl:with-param name="rt" select="."/>
                                    <xsl:with-param name="sofar" select="concat($rccontent/@id,'-',$rccontent/@effectiveDate)" as="xs:string*"/>
                                    <xsl:with-param name="templateFormat" select="local:getTemplateFormat($rccontent)"/>
                                </xsl:apply-templates>
                            </instances>
                        </xsl:variable>
                        <!-- Build instances -->
                        <xsl:variable name="instances">
                            <xsl:apply-templates select="$instancesStep1" mode="resolveInstanceElements">
                                <xsl:with-param name="rt" select="."/>
                            </xsl:apply-templates>
                        </xsl:variable>
                        <xsl:result-document href="{$theHtmlDir}{local:doHtmlName('TR',$trid,$treff,'_instance.xml','true')}" format="xml">
                            <xsl:copy-of select="$instances/*"/>
                        </xsl:result-document>
                        <xsl:result-document href="{$theHtmlDir}{local:doHtmlName('TR',$trid,$treff,'_instance.html','true')}" format="xhtml">
                            <html xml:lang="{substring($defaultLanguage,1,2)}" lang="{substring($defaultLanguage,1,2)}" xmlns="http://www.w3.org/1999/xhtml">
                                <head>
                                    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
                                    <title>
                                        <xsl:text>Mapping: </xsl:text>
                                        <xsl:value-of select="$projectPrefix"/>
                                        <xsl:text> </xsl:text>
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="'decorTitleString'"/>
                                        </xsl:call-template>
                                    </title>
                                    <link href="../assets/decor.css" rel="stylesheet" type="text/css"/>
                                    <style type="text/css">
                                        th,
                                        td,
                                        span,
                                        div{
                                            font-family: Verdana, Arial, sans-serif;
                                            font-size:11px;
                                        }</style>
                                </head>
                                <xsl:text>

</xsl:text>
                                <body>
                                    <xsl:for-each select="$instances/*/hl7:instance">
                                        <div class="landscapeshrinktofit">
                                            <div class="indexline">
                                                <a href="index.html">
                                                    <xsl:call-template name="getMessage">
                                                        <xsl:with-param name="key" select="'backToIndex'"/>
                                                    </xsl:call-template>
                                                </a>
                                                <xsl:if test="$tabnameslist//tab[@key = 'tabDataSet']">
                                                    <xsl:text> &#160;&lt;&lt;&#160; </xsl:text>
                                                    <a href="{local:doHtmlName('tabDataSet',(),(),'.html')}">
                                                        <xsl:call-template name="getMessage">
                                                            <xsl:with-param name="key" select="'backToDatasets'"/>
                                                        </xsl:call-template>
                                                    </a>
                                                </xsl:if>
                                                <xsl:if test="$tabnameslist//tab[@key = 'tabScenarios']">
                                                    <xsl:text> &#160;&lt;&lt;&#160; </xsl:text>
                                                    <a href="{local:doHtmlName('tabScenarios',(),(),'.html')}">
                                                        <xsl:call-template name="getMessage">
                                                            <xsl:with-param name="key" select="'backToScenarios'"/>
                                                        </xsl:call-template>
                                                    </a>
                                                </xsl:if>
                                                <xsl:if test="$tabnameslist//tab[@key = 'tabRules']">
                                                    <xsl:text> &#160;&lt;&lt;&#160; </xsl:text>
                                                    <a href="{local:doHtmlName('tabRules',(),(),'.html')}">
                                                        <xsl:call-template name="getMessage">
                                                            <xsl:with-param name="key" select="'backToRules'"/>
                                                        </xsl:call-template>
                                                    </a>
                                                </xsl:if>
                                            </div>
                                            <h1>
                                                <xsl:value-of select="$rccontent/@displayName"/>
                                                <xsl:text> (</xsl:text>
                                                <xsl:value-of select="@name"/>
                                                <xsl:text>)</xsl:text>
                                            </h1>
                                            <xsl:if test="@path">
                                                <div style="margin-bottom: 10px;">
                                                    <strong>Path that leads to this instance: <xsl:value-of select="@path"/>
                                                    </strong>
                                                </div>
                                            </xsl:if>
                                            <table cellpadding="5">
                                                <tr style="background-color: #bbbbbb;">
                                                    <th align="left">XML</th>
                                                    <th align="left">Data type</th>
                                                    <th align="left">Card/Conf</th>
                                                    <th align="left">Concept ID</th>
                                                    <th align="left">Concept</th>
                                                    <th align="left">Label</th>
                                                </tr>
                                                <xsl:apply-templates select="*" mode="createOutputRow">
                                                    <xsl:with-param name="nestinglevel" select="0"/>
                                                </xsl:apply-templates>
                                            </table>
                                        </div>
                                    </xsl:for-each>
                                </body>
                            </html>
                        </xsl:result-document>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="logMessage">
                            <xsl:with-param name="level" select="$logERROR"/>
                            <xsl:with-param name="msg">
                                <xsl:text>+++ Could not create default instance for transaction '</xsl:text>
                                <xsl:value-of select="$trid"/>
                                <xsl:text>'. Need exactly 1 template, found 0 (ref='</xsl:text>
                                <xsl:value-of select="$tid"/>
                                <xsl:text>' flexibility='</xsl:text>
                                <xsl:value-of select="if (empty($tflex)) then 'dynamic' else $tflex"/>
                                <xsl:text>')</xsl:text>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:if>
        <xsl:variable name="processendtime">
            <xsl:choose>
                <xsl:when test="$hasARTDECORconnection=true()">
                    <xsl:value-of select="xs:double(doc('http://art-decor.org/decor/services/modules/current-milliseconds.xquery?2'))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="1"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <!-- <xsl:variable name="processendtime" select="1"/>
        -->
        <xsl:call-template name="logMessage">
            <xsl:with-param name="level" select="$logINFO"/>
            <xsl:with-param name="msg">
                <xsl:text>*** Finished </xsl:text>
                <!--<xsl:value-of select="$processendtime"/>-->
            </xsl:with-param>
        </xsl:call-template>
        <xsl:if test="$hasARTDECORconnection=true()">
            <xsl:call-template name="logMessage">
                <xsl:with-param name="level" select="$logINFO"/>
                <xsl:with-param name="msg">
                    <xsl:text>*** Total Processing Time </xsl:text>
                    <xsl:value-of select="$processendtime - $processstarttime"/>
                    <xsl:text>ms - </xsl:text>
                    <xsl:variable name="elapsedtime" select="($processendtime - $processstarttime) * xs:dayTimeDuration('PT0.001S')"/>
                    <xsl:variable name="hours-from-millis" select="hours-from-duration($elapsedtime)"/>
                    <xsl:variable name="minutes-from-millis" select="minutes-from-duration($elapsedtime)"/>
                    <xsl:variable name="seconds-from-millis" select="floor(seconds-from-duration($elapsedtime))"/>
                    <xsl:value-of select="concat($hours-from-millis, 'h ', $minutes-from-millis, 'm ', $seconds-from-millis, 's')"/>
                    <!--<xsl:text>See: https://saxonica.plan.io/issues/1816</xsl:text>-->
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Builds the mapping file for mapping instances onto the right schematron</xd:desc>
    </xd:doc>
    <xsl:template name="buildInstanceToSchematron">
        <xsl:variable name="dfltNS">
            <xsl:choose>
                <xsl:when test="string-length($projectDefaultElementPrefix)=0">
                    <xsl:value-of select="'urn:hl7-org:v3'"/>
                </xsl:when>
                <xsl:when test="$projectDefaultElementPrefix='hl7:' or $projectDefaultElementPrefix='cda:'">
                    <xsl:value-of select="'urn:hl7-org:v3'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="namespace-uri-for-prefix(substring-before($projectDefaultElementPrefix,':'),/decor)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- output of the the mainfest -->
        <xsl:result-document href="{$theRuntimeDir}{$projectPrefix}instance2schematron.xml" format="xml">
            <mappings xmlns="">
                <xsl:text>&#10;    </xsl:text>
                <xsl:comment> Chapter 1: Release Info (if publication is a release) </xsl:comment>
                <xsl:text>&#10;    </xsl:text>
                <xsl:comment> ========= </xsl:comment>
                <xsl:if test="$publicationIsRelease">
                    <release xmlns="" project="{$projectId}" prefix="{$projectPrefix}" signature="{$theTimeStamp}" date="{$latestVersionOrRelease/@date}">
                        <xsl:if test="string-length($latestVersionOrRelease/@versionLabel)>0">
                            <xsl:attribute name="versionLabel" select="$latestVersionOrRelease/@versionLabel"/>
                        </xsl:if>
                        <xsl:copy-of select="$latestVersionOrRelease/(note|desc)"/>
                    </release>
                </xsl:if>
                <xsl:text>&#10;    </xsl:text>
                <xsl:text>&#10;    </xsl:text>
                <xsl:comment> Chapter 2: Mapping based on model list </xsl:comment>
                <xsl:text>&#10;    </xsl:text>
                <xsl:comment> ========= </xsl:comment>
                <xsl:text>&#10;    </xsl:text>
                <xsl:comment> Used to map an instance to a specific Schematron. How to read:
- For every template-id that is used in instances there is an element map, e.g.
  &lt;map model="REPC_IN004110UV01" namespace="urn:hl7-org:v3" sch="peri20-counseling-fase-1c.sch" schsvrl="peri20-counseling-fase-1c.xsl"/&gt;
  or
  &lt;map templateRoot="2.16.840.1.113883.2.4.6.10.90.59" templateExt="2017-03-27" sch="peri20-counseling-fase-1c.sch" schsvrl="peri20-counseling-fase-1c.xsl"/&gt;
  &lt;map templateRoot="2.16.840.1.113883.2.4.6.10.90.59" sch="peri20-counseling-fase-1c.sch" schsvrl="peri20-counseling-fase-1c.xsl"/&gt;
  or 
  &lt;map rootelement="REPC_IN004110UV01" namespace="urn:hl7-org:v3" sch="peri20-counseling-fase-1c.sch" schsvrl="peri20-counseling-fase-1c.xsl"/&gt;
  
  - @model       - optional    - hint as to the XML Schema that could be used
  - @namespace   - mandatory   - default namespace-uri() of the project and of the instance unless specified otherwise
  or
  - templateRoot - mandatory   - in HL7v3 this would be an OID. In other instance types it might be something else, but then this mapping file might need adjusted setup
  - templateExt  - optional    - in HL7v3 this would be any string found in templateId/@extension
  or
  - @rootelement - required    - local-name() of the root element of the instance
  - @namespace   - mandatory   - namespace-uri() of the root element
  
  One of the following is required, normally schsvrl makes sense:
  - @schsvrl     - conditional - path+file name of the SVRL XSL. The path should be relative to this index/map file
  - @schtext     - conditional - path+file name of the Text XSL. The path should be relative to this index/map file
  - @sch         - conditional - path+file name of the original Schematron file. The path should be relative to this index/map file
    
  Note that the same template may be part of multiple transactions, hence multiple map element could be present for the same template. The attached Schematron
  will have different names, but will have the exact same rules (same template, same rules) hence only the first match is needed for validation.
  
- As final fallback, when no template-id is found in the instance, code should rely on root element of the instance to determine the Schematron file name ... </xsl:comment>
                <xsl:for-each select="$allScenarios/scenarios/scenario//transaction[@label]/representingTemplate[@ref]">
                    <xsl:sort select="parent::transaction/@model"/>
                    <xsl:variable name="modelAttr" select="parent::transaction/@model"/>
                    <xsl:variable name="modelPfx" select="if (contains($modelAttr,':')) then (substring-before($modelAttr,':')) else ('')"/>
                    <xsl:variable name="modelName" select="if (contains($modelAttr,':')) then (substring-after($modelAttr,':')) else ($modelAttr)"/>
                    <xsl:variable name="modelNS">
                        <xsl:choose>
                            <xsl:when test="$modelPfx='hl7' or $modelPfx='cda'">
                                <xsl:value-of select="'urn:hl7-org:v3'"/>
                            </xsl:when>
                            <xsl:when test="$modelPfx=''">
                                <xsl:value-of select="$dfltNS"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="namespace-uri-for-prefix($modelPfx,$allScenarios/scenarios/scenario//transaction[@model=$modelAttr])"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    
                    <xsl:variable name="rlabel" select="parent::transaction/normalize-space(@label)"/>
                    <xsl:variable name="tref" select="@ref"/>
                    <xsl:variable name="tflex" select="@flexibility"/>
                    <xsl:variable name="rccontent" as="element()?">
                        <xsl:call-template name="getRulesetContent">
                            <xsl:with-param name="ruleset" select="$tref"/>
                            <xsl:with-param name="flexibility" select="$tflex"/>
                            <xsl:with-param name="sofar" select="()"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="tid" select="$rccontent/@id"/>
                    <xsl:variable name="tname" select="$rccontent/@name"/>
                    <xsl:if test="string-length($tid)&gt;0">
                        <xsl:variable name="rootElm" as="element()*">
                            <xsl:variable name="telmname" select="':templateId'"/>
                            <xsl:choose>
                                <xsl:when test="$rccontent[context/@path[not(matches(.,'^/+$'))]]">
                                    <!-- specific path name given or // (root element) -->
                                    <root rootelement="{replace($rccontent/context/@path,'/*([^\[/]+)(/.*)?','$1')}">
                                        <xsl:if test="$rccontent[count(element)=1][not(choice|include|attribute)]">
                                            <xsl:variable name="roots" as="element()*">
                                                <xsl:call-template name="getRootElementAndTemplateIds">
                                                    <xsl:with-param name="elem" select="$rccontent/element"/>
                                                </xsl:call-template>
                                            </xsl:variable>
                                            <xsl:copy-of select="$roots/templateId"/>
                                        </xsl:if>
                                    </root>
                                </xsl:when>
                                <xsl:when test="$rccontent[count(element)=1][not(choice|include|attribute)]">
                                    <xsl:call-template name="getRootElementAndTemplateIds">
                                        <xsl:with-param name="elem" select="$rccontent/element"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:when test="$rccontent[choice[include|element][not(choice)]]">
                                    <xsl:for-each select="$rccontent/choice/(include|element)">
                                        <xsl:choose>
                                            <xsl:when test="self::element">
                                                <xsl:call-template name="getRootElementAndTemplateIds">
                                                    <xsl:with-param name="elem" select="."/>
                                                </xsl:call-template>
                                            </xsl:when>
                                            <xsl:when test="self::include">
                                                <xsl:variable name="xref" select="@ref"/>
                                                <xsl:variable name="xflex" select="@flexibility"/>
                                                <xsl:variable name="rccontent2" as="element()?">
                                                    <xsl:call-template name="getRulesetContent">
                                                        <xsl:with-param name="ruleset" select="@ref"/>
                                                        <xsl:with-param name="flexibility" select="@flexibility"/>
                                                        <xsl:with-param name="sofar" select="()"/>
                                                    </xsl:call-template>
                                                </xsl:variable>
                                                <xsl:choose>
                                                    <xsl:when test="$rccontent2[context/@path[not(matches(.,'^/+$'))]]">
                                                        <!-- specific path name given or // (root element) -->
                                                        <root rootelement="{replace($rccontent2/context/@path,'/*([^\[/]+)(/.*)?','$1')}">
                                                            <xsl:if test="$rccontent2[count(element)=1][not(choice|include|attribute)]">
                                                                <xsl:variable name="roots" as="element()*">
                                                                    <xsl:call-template name="getRootElementAndTemplateIds">
                                                                        <xsl:with-param name="elem" select="$rccontent2/element"/>
                                                                    </xsl:call-template>
                                                                </xsl:variable>
                                                                <xsl:copy-of select="$roots/templateId"/>
                                                            </xsl:if>
                                                        </root>
                                                    </xsl:when>
                                                    <xsl:when test="$rccontent2[element][count(element)=1][not(choice|include|attribute)]">
                                                        <xsl:call-template name="getRootElementAndTemplateIds">
                                                            <xsl:with-param name="elem" select="$rccontent2/element"/>
                                                        </xsl:call-template>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:call-template name="logMessage">
                                                            <xsl:with-param name="level" select="$logWARN"/>
                                                            <xsl:with-param name="msg">
                                                                <xsl:text>+++ Encountered a representingTemplate that we could not determine </xsl:text>
                                                                <xsl:text>all root elements for in the choice it offers. </xsl:text>
                                                                <xsl:text>This leads to an incomplete instance2schematron.xml. </xsl:text>
                                                                <xsl:text>This in turn may lead to validation problems. TEMPLATE id='</xsl:text>
                                                                <xsl:value-of select="$rccontent/@id"/>
                                                                <xsl:text>' effectiveDate '</xsl:text>
                                                                <xsl:value-of select="$rccontent/@effectiveDate"/>
                                                                <xsl:text>' name '</xsl:text>
                                                                <xsl:value-of select="$rccontent/@name"/>
                                                                <xsl:text>' displayName '</xsl:text>
                                                                <xsl:value-of select="$rccontent/@displayName"/>
                                                                <xsl:text>'. Missing root element in include ref='</xsl:text>
                                                                <xsl:value-of select="$xref"/>
                                                                <xsl:text> flexibility '</xsl:text>
                                                                <xsl:value-of select="$xflex"/>
                                                                <xsl:text>'.</xsl:text>
                                                            </xsl:with-param>
                                                        </xsl:call-template>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:when>
                                        </xsl:choose>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="logMessage">
                                        <xsl:with-param name="level" select="$logWARN"/>
                                        <xsl:with-param name="msg">
                                            <xsl:text>+++ Encountered a representingTemplate that we could not determine </xsl:text>
                                            <xsl:text>the root element for. This leads to an incomplete instance2schematron.xml. </xsl:text>
                                            <xsl:text>This in turn may lead to validation problems. TEMPLATE id='</xsl:text>
                                            <xsl:value-of select="$rccontent/@id"/>
                                            <xsl:text>' effectiveDate '</xsl:text>
                                            <xsl:value-of select="$rccontent/@effectiveDate"/>
                                            <xsl:text>' name '</xsl:text>
                                            <xsl:value-of select="$rccontent/@name"/>
                                            <xsl:text>' displayName '</xsl:text>
                                            <xsl:value-of select="$rccontent/@displayName"/>
                                            <xsl:text>'.</xsl:text>
                                        </xsl:with-param>
                                    </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:comment>
                            <xsl:text> template name: </xsl:text>
                            <xsl:value-of select="$tname"/>
                            <xsl:text> </xsl:text>
                        </xsl:comment>
                        <xsl:for-each select="$rootElm">
                            <xsl:variable name="rootPfx" select="if (contains(@rootelement,':')) then (substring-before(@rootelement,':')) else ('')"/>
                            <xsl:variable name="rootName" select="if (contains(@rootelement,':')) then (substring-after(@rootelement,':')) else (@rootelement)"/>
                            <xsl:variable name="rootNS">
                                <xsl:choose>
                                    <xsl:when test="$rootPfx='hl7' or $rootPfx='cda'">
                                        <xsl:value-of select="'urn:hl7-org:v3'"/>
                                    </xsl:when>
                                    <xsl:when test="$rootPfx=''">
                                        <xsl:value-of select="$dfltNS"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="namespace-uri-for-prefix($rootPfx,$rccontent)"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:text>&#10;    </xsl:text>
                            <xsl:for-each select="templateId">
                                <map>
                                    <xsl:if test="string-length($modelName) > 0">
                                        <xsl:attribute name="model" select="$modelName"/>
                                    </xsl:if>
                                    <xsl:attribute name="rootelement" select="$rootName"/>
                                    <xsl:attribute name="namespace" select="$rootNS"/>
                                    <xsl:copy-of select="@templateRoot"/>
                                    <xsl:copy-of select="@templateExt"/>
                                    <xsl:attribute name="sch" select="concat($projectPrefix, $rlabel, '.sch')"/>
                                    <xsl:attribute name="schsvrl" select="concat($projectPrefix, $rlabel, '.xsl')"/>
                                    <xsl:attribute name="xsd" select="concat($rootName, '.xsd')"/>
                                </map>
                            </xsl:for-each>
                            <map>
                                <xsl:if test="string-length($modelName) > 0">
                                    <xsl:attribute name="model" select="$modelName"/>
                                </xsl:if>
                                <xsl:attribute name="rootelement" select="$rootName"/>
                                <xsl:attribute name="namespace" select="$rootNS"/>
                                <xsl:attribute name="sch" select="concat($projectPrefix,$rlabel,'.sch')"/>
                                <xsl:attribute name="schsvrl" select="concat($projectPrefix,$rlabel,'.xsl')"/>
                                <xsl:attribute name="xsd" select="concat($rootName, '.xsd')"/>
                            </map>
                        </xsl:for-each>
                        <xsl:if test="count($rootElm) = 0 and string-length($modelName) > 0">
                            <map>
                                <xsl:attribute name="model" select="$modelName"/>
                                <xsl:attribute name="namespace" select="$modelNS"/>
                                <xsl:attribute name="templateRoot" select="$tid"/>
                                <xsl:attribute name="sch" select="concat($projectPrefix, $rlabel, '.sch')"/>
                                <xsl:attribute name="schsvrl" select="concat($projectPrefix, $rlabel, '.xsl')"/>
                            </map>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
                
                <xsl:text>&#10;    </xsl:text>
                <xsl:text>&#10;    </xsl:text>
                <xsl:comment> Chapter 3: Mapping based on representing templates </xsl:comment>
                <xsl:text>&#10;    </xsl:text>
                <xsl:comment> ========= </xsl:comment>
                <xsl:text>&#10;    </xsl:text>
                <xsl:comment> Used to map a representing template to a specific Schematron. How to read:
- For every representing template the schematron file and sch svrl xsl conversion file is mentioned
- The corresponding root element plus its namespace is mentioned 
- Every transaction represented by this template is named</xsl:comment>
                <xsl:for-each select="$allScenarios/scenarios/scenario[@statusCode = ('draft', 'final', 'new', 'pending')]//transaction[@statusCode = ('draft', 'final', 'new', 'pending')]/representingTemplate[@ref]">
                    <xsl:variable name="rlabel" select="parent::transaction/normalize-space(@label)"/>
                    <xsl:variable name="transid" select="parent::transaction/@id"/>
                    <xsl:variable name="transed" select="parent::transaction/@effectiveDate"/>
                    <xsl:variable name="transsc" select="parent::transaction/@statusCode"/>
                    <xsl:variable name="translb" select="parent::transaction/@versionLabel"/>
                    <xsl:variable name="transnm" select="parent::transaction/name[@language=$defaultLanguage]"/>
                    <xsl:variable name="tref" select="@ref"/>
                    <xsl:variable name="tflex" select="@flexibility"/>
                    <xsl:variable name="rccontent" as="element()?">
                        <xsl:call-template name="getRulesetContent">
                            <xsl:with-param name="ruleset" select="$tref"/>
                            <xsl:with-param name="flexibility" select="$tflex"/>
                            <xsl:with-param name="sofar" select="()"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="tid" select="$rccontent/@id"/>
                    <xsl:variable name="tname" select="$rccontent/@name"/>
                    <xsl:if test="string-length($tid)&gt;0">
                        <xsl:variable name="rootElm" as="xs:string*">
                            <xsl:choose>
                                <xsl:when test="$rccontent[context/@id='**'][element][count(element)=1][not(choice|include|attribute)]">
                                    <xsl:value-of select="normalize-space(replace($rccontent/element/@name,'([^\[]+)\[.*',''))"/>
                                </xsl:when>
                                <xsl:when test="$rccontent[context/@path[not(matches(.,'^/+$'))]]">
                                    <!-- specific path name given or // (root element) -->
                                    <xsl:value-of select="replace($rccontent/context/@path,'/*([^\[/]+)(/.*)?','$1')"/>
                                </xsl:when>
                                <xsl:when test="$rccontent[count(element)=1][not(choice|include|attribute)]">
                                    <xsl:value-of select="normalize-space(replace($rccontent/element/@name,'([^\[]+)\[.*',''))"/>
                                </xsl:when>
                                <xsl:when test="$rccontent[choice[include|element][not(choice)]]">
                                    <xsl:for-each select="$rccontent/choice/(include|element)">
                                        <xsl:choose>
                                            <xsl:when test="self::element">
                                                <xsl:value-of select="normalize-space(replace(@name,'([^\[]+)\[.*',''))"/>
                                            </xsl:when>
                                            <xsl:when test="self::include">
                                                <xsl:variable name="xref" select="@ref"/>
                                                <xsl:variable name="xflex" select="@flexibility"/>
                                                <xsl:variable name="rccontent2" as="element()?">
                                                    <xsl:call-template name="getRulesetContent">
                                                        <xsl:with-param name="ruleset" select="@ref"/>
                                                        <xsl:with-param name="flexibility" select="@flexibility"/>
                                                        <xsl:with-param name="sofar" select="()"/>
                                                    </xsl:call-template>
                                                </xsl:variable>
                                                <xsl:choose>
                                                    <xsl:when test="$rccontent2[context/@id='**'][element][count(element)=1][not(choice|include|attribute)]">
                                                        <xsl:value-of select="normalize-space(replace($rccontent2/element/@name,'([^\[]+)\[.*',''))"/>
                                                    </xsl:when>
                                                    <xsl:when test="$rccontent2[context/@path[not(matches(.,'^/+$'))]]">
                                                        <!-- specific path name given or // (root element) -->
                                                        <xsl:value-of select="replace($rccontent2/context/@path,'/*([^\[/]+)(/.*)?','$1')"/>
                                                    </xsl:when>
                                                    <xsl:when test="$rccontent2[element][count(element)=1][not(choice|include|attribute)]">
                                                        <xsl:value-of select="normalize-space(replace($rccontent2/element/@name,'([^\[]+)\[.*',''))"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:call-template name="logMessage">
                                                            <xsl:with-param name="level" select="$logWARN"/>
                                                            <xsl:with-param name="msg">
                                                                <xsl:text>+++ Encountered a representingTemplate that we could not determine </xsl:text>
                                                                <xsl:text>all root elements for in the choice it offers. </xsl:text>
                                                                <xsl:text>This leads to an incomplete instance2schematron.xml. </xsl:text>
                                                                <xsl:text>This in turn may lead to validation problems. TEMPLATE id='</xsl:text>
                                                                <xsl:value-of select="$rccontent/@id"/>
                                                                <xsl:text>' effectiveDate '</xsl:text>
                                                                <xsl:value-of select="$rccontent/@effectiveDate"/>
                                                                <xsl:text>' name '</xsl:text>
                                                                <xsl:value-of select="$rccontent/@name"/>
                                                                <xsl:text>' displayName '</xsl:text>
                                                                <xsl:value-of select="$rccontent/@displayName"/>
                                                                <xsl:text>'. Missing root element in include ref='</xsl:text>
                                                                <xsl:value-of select="$xref"/>
                                                                <xsl:text> flexibility '</xsl:text>
                                                                <xsl:value-of select="$xflex"/>
                                                                <xsl:text>'.</xsl:text>
                                                            </xsl:with-param>
                                                        </xsl:call-template>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:when>
                                        </xsl:choose>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="logMessage">
                                        <xsl:with-param name="level" select="$logWARN"/>
                                        <xsl:with-param name="msg">
                                            <xsl:text>+++ Encountered a representingTemplate that we could not determine </xsl:text>
                                            <xsl:text>the root element for. This leads to an incomplete instance2schematron.xml. </xsl:text>
                                            <xsl:text>This in turn may lead to validation problems. TEMPLATE id='</xsl:text>
                                            <xsl:value-of select="$rccontent/@id"/>
                                            <xsl:text>' effectiveDate '</xsl:text>
                                            <xsl:value-of select="$rccontent/@effectiveDate"/>
                                            <xsl:text>' name '</xsl:text>
                                            <xsl:value-of select="$rccontent/@name"/>
                                            <xsl:text>' displayName '</xsl:text>
                                            <xsl:value-of select="$rccontent/@displayName"/>
                                            <xsl:text>'.</xsl:text>
                                        </xsl:with-param>
                                    </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <template xmlns="" id="{$tid}" effectiveDate="{$tflex}" sch="{$projectPrefix}{$rlabel}.sch" schsvrl="{$projectPrefix}{$rlabel}.xsl">
                            <xsl:for-each select="$rootElm">
                                <xsl:variable name="rootPfx" select="if (contains(.,':')) then (substring-before(.,':')) else ('')"/>
                                <xsl:variable name="rootName" select="if (contains(.,':')) then (substring-after(.,':')) else (.)"/>
                                <xsl:variable name="rootNS">
                                    <xsl:choose>
                                        <xsl:when test="$rootPfx='hl7' or $rootPfx='cda'">
                                            <xsl:value-of select="'urn:hl7-org:v3'"/>
                                        </xsl:when>
                                        <xsl:when test="$rootPfx=''">
                                            <xsl:value-of select="$dfltNS"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="namespace-uri-for-prefix($rootPfx,$rccontent)"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <root xmlns="" rootelement="{$rootName}" namespace="{$rootNS}"/>
                            </xsl:for-each>
                            <transaction xmlns="" id="{$transid}" effectiveDate="{$transed}" statusCode="{$transsc}">
                                <xsl:if test="string-length($translb)>0">
                                    <xsl:attribute name="versionLabel" select="$translb"/>
                                </xsl:if>
                                <xsl:if test="string-length($transnm)>0">
                                    <xsl:attribute name="name" select="$transnm"/>
                                </xsl:if>
                            </transaction>
                        </template>
                    </xsl:if>
                </xsl:for-each>
            </mappings>
        </xsl:result-document>
    </xsl:template>
    <xd:doc>
        <xd:desc>Returns element root with the clean name (without predicates) in @rootelement. The element root will have as many templateId children as there are defined *:templateId children. Each templateId child element will have at least @templateRoot and optionally a @templateExt. Example:
        <xd:pre><root rootelement="hl7:observation">
            <templateId templateRoot="1.2.3" templateExt="2017-04-15"/>
        </root></xd:pre></xd:desc>
        <xd:param name="elem">Element that carries defined templateId child elements</xd:param>
    </xd:doc>
    <xsl:template name="getRootElementAndTemplateIds" as="element()">
        <xsl:param name="elem" as="element(element)"/>
        
        <root rootelement="{normalize-space(replace($elem/@name,'([^\[]+)\[.*',''))}">
            <xsl:variable name="telmname" select="':templateId'"/>
            <xsl:for-each select="$elem/element[ends-with(@name, $telmname)][@minimumMultiplicity > 0]">
                <xsl:variable name="tmproot" select="(attribute/@root[string-length() &gt; 0] | attribute[@name = 'root']/@value[string-length() &gt; 0])[1]"/>
                <xsl:variable name="tmpext" select="(attribute/@extension[string-length() &gt; 0] | attribute[@name = 'extension']/@value[string-length() &gt; 0])[1]"/>
                <templateId templateRoot="{$tmproot}">
                    <xsl:if test="$tmpext">
                        <xsl:attribute name="templateExt" select="$tmpext"/>
                    </xsl:if>
                </templateId>
            </xsl:for-each>
        </root>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Get templateList with template copies of all templates that are tied to the current template</xd:desc>
        <xd:param name="rccontent">Content that we should calculate the list from</xd:param>
    </xd:doc>
    <xsl:template name="getAssociatedTemplates" as="element()*">
        <xsl:param name="rccontent" as="element(template)?" required="yes"/>
        <xsl:variable name="listWithDuplicates" as="element()*">
            <!-- template id="" name="" effectiveDate="" -->
            <xsl:for-each select="$rccontent//(element[@contains] | include)">
                <xsl:call-template name="getTemplateList">
                    <xsl:with-param name="sofar" select="concat($rccontent/@id, '-', $rccontent/@effectiveDate)"/>
                    <xsl:with-param name="nesting" select="1"/>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:variable>
        <xsl:for-each-group select="$listWithDuplicates" group-by="concat(@id,'-',@effectiveDate)">
            <xsl:copy-of select="current-group()[1]"/>
        </xsl:for-each-group>
    </xsl:template>
    <xd:doc>
        <xd:desc>Recursive template that gets/returns all referenced templates until no more templates or only duplicates can be found</xd:desc>
        <xd:param name="sofar">Array of templates found so far where every array item is concat(template/@id,'-',template/@effectiveDate)</xd:param>
        <xd:param name="nesting">Nesting level. If recursion nests deeper than param <xd:ref name="maxNestingLevel" type="parameter"/> than this adds an element tooDeeplyNested to the list of returned elements</xd:param>
    </xd:doc>
    <xsl:template name="getTemplateList">
        <xsl:param name="sofar" as="xs:string*" required="yes"/>
        <xsl:param name="nesting" required="yes"/>
        <xsl:choose>
            <xsl:when test="self::element[@contains] | self::include">
                <xsl:variable name="tid" select="@contains|@ref"/>
                <xsl:variable name="tflex" select="if (@flexibility) then (@flexibility) else ('dynamic')"/>
                <xsl:variable name="rccontent" as="element()?">
                    <xsl:call-template name="getRulesetContent">
                        <xsl:with-param name="ruleset" select="$tid"/>
                        <xsl:with-param name="flexibility" select="$tflex"/>
                        <xsl:with-param name="sofar" select="$sofar"/>
                    </xsl:call-template>
                </xsl:variable>
                <!-- recursion protection -->
                <xsl:variable name="recurrents" select="string-join(for $i in 1 to count($sofar) return if ($sofar[$i] = $sofar[last()]) then 'X' else '', '')"/>
                <xsl:choose>
                    <xsl:when test="$nesting >= $maxNestingLevel">
                        <tooDeeplyNested id="{$rccontent/@id}" name="{$rccontent/@name}" effectiveDate="{$rccontent/@effectiveDate}"/>
                    </xsl:when>
                    <!--
                    <xsl:when test="count(distinct-values($sofar)) = count($sofar)">
                    -->
                        <!--
                    <xsl:when test="not($sofar[. = concat($rccontent/@id,'-',$rccontent/@effectiveDate)])">
                    -->
                    <xsl:when test="string-length($recurrents) > $maxRecursionLevel">
                        <recurse xmlns="" id="{$rccontent/@id}" name="{$rccontent/@name}" effectiveDate="{$rccontent/@effectiveDate}"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <template xmlns="" id="{$rccontent/@id}" name="{$rccontent/@name}" effectiveDate="{$rccontent/@effectiveDate}" standalone="{exists($rccontent/context[@id])}">
                            <xsl:for-each select="$rccontent//(element[@contains]|include)">
                                <xsl:call-template name="getTemplateList">
                                    <xsl:with-param name="sofar" select="$sofar, concat($rccontent/@id,'-',$rccontent/@effectiveDate)"/>
                                    <xsl:with-param name="nesting" select="$nesting+1"/>
                                </xsl:call-template>
                            </xsl:for-each>
                        </template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc>Get basic project info as comment for listing in a schematron files and valueSet lookup files</xd:desc>
        <xd:param name="what">Top level line in the generated comment</xd:param>
    </xd:doc>
    <xsl:template match="project">
        <xsl:param name="what"/>
        <!-- print copyright stuff etc -->
        <xsl:comment>
            <xsl:text>
==================================</xsl:text>
            <xsl:text>
</xsl:text>
            <xsl:value-of select="$what"/>
            <xsl:text>

Project: </xsl:text>
            <xsl:value-of select="@name"/>
            <xsl:for-each select="//project/copyright">
                <xsl:text>

Copyright </xsl:text>
                <xsl:value-of select="@years"/>
                <xsl:text> by </xsl:text>
                <xsl:value-of select="@by"/>
            </xsl:for-each>
            <xsl:text>

</xsl:text>
            <xsl:for-each select="author">
                <xsl:text>
Author: </xsl:text>
                <xsl:value-of select="text()"/>
            </xsl:for-each>
            <xsl:text>

Version information:</xsl:text>
            <xsl:for-each select="version">
                <xsl:text>
  </xsl:text>
                <xsl:value-of select="@date"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="@by"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="@desc"/>
            </xsl:for-each>
            <xsl:text>

DISCLAIMER:
</xsl:text>
            <xsl:value-of select="$disclaimer"/>
            <xsl:text>

WARNING:
</xsl:text>
            <xsl:value-of select="$warning"/>
            <xsl:text>

Creation date: </xsl:text>
            <xsl:choose>
                <xsl:when test="$inDevelopment=true()">
                    <xsl:text>(in development)</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="dateTime(current-date(), current-time())"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>
==================================</xsl:text>
            <xsl:text>

</xsl:text>
        </xsl:comment>
    </xsl:template>
    <xd:doc>
        <xd:desc>Kick off schematron generation for all templates and valueSets (as lookup file)</xd:desc>
    </xd:doc>
    <xsl:template match="decor">
        <!-- Always generate schematron when a template is called from a transaction -->
        <xsl:variable name="representingTemplateTemplates" as="xs:string*">
            <xsl:for-each-group select="$allScenarios//transaction/representingTemplate[@ref]" group-by="concat(@ef,'-',if (@flexibility) then @flexibility else 'dynamic')">
                <xsl:variable name="rccontent" as="element()?">
                    <xsl:call-template name="getRulesetContent">
                        <xsl:with-param name="ruleset" select="@ref"/>
                        <xsl:with-param name="flexibility" select="@flexibility"/>
                        <xsl:with-param name="sofar" select="()"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:value-of select="$rccontent/concat(@id,'-',@effectiveDate)"/>
            </xsl:for-each-group>
        </xsl:variable>
        
        <!--
            apply the generation of templates for all template definitions
            don't do that for duplicates of another template and don't do
            that for templates that do not have a context defined
            2DO recent version only only multiple versions! 
        -->
        <xsl:for-each select="$allTemplates/*/ref">
            <xsl:if test="not(@duplicateOf) and (template[@id][context] or template[@id][concat(@id,'-',@effectiveDate) = $representingTemplateTemplates])">
                <xsl:call-template name="logMessage">
                    <xsl:with-param name="level" select="$logDEBUG"/>
                    <xsl:with-param name="msg">
                        <xsl:text>*** SCH for template: name='</xsl:text>
                        <xsl:value-of select="template/@name"/>
                        <xsl:text>' id='</xsl:text>
                        <xsl:value-of select="template/@id"/>
                        <xsl:text>' effectiveDate='</xsl:text>
                        <xsl:value-of select="template/@effectiveDate"/>
                        <xsl:text>'</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:apply-templates select="template" mode="GEN"/>
            </xsl:if>
        </xsl:for-each>
        
        <!-- extract all value set (references) to runtime directory -->
        
        <!-- a little milestoning -->
        <xsl:call-template name="logMessage">
            <xsl:with-param name="level" select="$logINFO"/>
            <xsl:with-param name="msg">
                <xsl:text>*** Creating Terminology Files</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
        
        <!-- 
            extract value set most recent one (dynamic) 
            NOTE: a value set has a name and an id
            a value set of the same name may have different ids
            thus dynamic with respect to name may mean another set than dynamic with respect to id
            
            -!!: only flexiblity based on id is now implemented. It is the responsability of the 
                 conversion to correctly find the right id for a given name
            
            example
            value set name=A id=1 contains=X,Y,Z
            value set name=A id=2 contains=X,Z
            value set name=A id=2 contains=X,Z,Ö
            value set name=A id=3 contains=X,Y
            
            then dynamic with respect to name A means value set id 3
            dynamic with respect to id 2 contains X,Z,Ö
            
            for simplicity only names of value sets maybe bound to dynamic
        -->
        <xsl:for-each-group select="$allValueSets/*/valueSet" group-by="concat((@id|@ref),'#',@effectiveDate)">
            <xsl:variable name="vsid" select="(@id|@ref)"/>
            <xsl:variable name="vsed" select="@effectiveDate"/>
            <xsl:variable name="isNewest" select="$vsed=max($allValueSets/*/valueSet[(@id|@ref)=$vsid]/xs:dateTime(@effectiveDate))"/>
            <xsl:call-template name="logMessage">
                <xsl:with-param name="level" select="$logDEBUG"/>
                <xsl:with-param name="msg">
                    <xsl:text>*** SCH vocab file (value set): name='</xsl:text>
                    <xsl:value-of select="@name"/>
                    <xsl:text>' id='</xsl:text>
                    <xsl:value-of select="$vsid"/>
                    <xsl:text>' effectiveDate='</xsl:text>
                    <xsl:value-of select="$vsed"/>
                    <xsl:text>'</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:result-document href="{$theRuntimeIncludeDir}{local:doHtmlName('VS', $vsid, $vsed, '.xml', 'true')}" format="xml">
                <!-- do print copyright stuff etc -->
                <xsl:apply-templates select="//project">
                    <xsl:with-param name="what">
                        <xsl:value-of select="concat('Value Set ', $vsid, ' (STATIC ', $vsed, ')')"/>
                    </xsl:with-param>
                </xsl:apply-templates>
                <valueSets xmlns="">
                    <xsl:copy-of select="."/>
                </valueSets>
            </xsl:result-document>
            <xsl:if test="$isNewest=true()">
                <xsl:result-document href="{$theRuntimeIncludeDir}{local:doHtmlName('VS', $vsid, 'DYNAMIC', '.xml', 'true')}" format="xml">
                    <!-- do print copyright stuff etc -->
                    <xsl:apply-templates select="//project">
                        <xsl:with-param name="what">
                            <xsl:value-of select="concat('Value Set ', $vsid, ' (DYNAMIC) as of ', $vsed)"/>
                        </xsl:with-param>
                    </xsl:apply-templates>
                    <valueSets xmlns="">
                        <xsl:copy-of select="."/>
                    </valueSets>
                </xsl:result-document>
            </xsl:if>
        </xsl:for-each-group>
        <!-- 
            Code System export - as is
        -->
        <xsl:for-each-group select="$allCodeSystems/*/codeSystem" group-by="concat((@id|@ref),'#',@effectiveDate)">
            <xsl:variable name="csid" select="(@id|@ref)"/>
            <xsl:variable name="csed" select="@effectiveDate"/>
            <xsl:variable name="isNewest" select="$csed=max($allCodeSystems/*/codeSystem[(@id|@ref)=$csid]/xs:dateTime(@effectiveDate))"/>
            <xsl:call-template name="logMessage">
                <xsl:with-param name="level" select="$logDEBUG"/>
                <xsl:with-param name="msg">
                    <xsl:text>*** SCH vocab file (code system): name='</xsl:text>
                    <xsl:value-of select="@name"/>
                    <xsl:text>' id='</xsl:text>
                    <xsl:value-of select="$csid"/>
                    <xsl:text>' effectiveDate='</xsl:text>
                    <xsl:value-of select="$csed"/>
                    <xsl:text>'</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:result-document href="{$theRuntimeIncludeDir}{local:doHtmlName('CS', $csid, $csed, '.xml', 'true')}" format="xml">
                <!-- do print copyright stuff etc -->
                <xsl:apply-templates select="//project">
                    <xsl:with-param name="what">
                        <xsl:value-of select="concat('Code System ', $csid, ' (STATIC ', $csed, ')')"/>
                    </xsl:with-param>
                </xsl:apply-templates>
                <codeSystems xmlns="">
                    <xsl:copy-of select="."/>
                </codeSystems>
            </xsl:result-document>
            <xsl:if test="$isNewest=true()">
                <xsl:result-document href="{$theRuntimeIncludeDir}{local:doHtmlName('CS', $csid, 'DYNAMIC', '.xml', 'true')}" format="xml">
                    <!-- do print copyright stuff etc -->
                    <xsl:apply-templates select="//project">
                        <xsl:with-param name="what">
                            <xsl:value-of select="concat('Code System ', $csid, ' (DYNAMIC) as of ', $csed)"/>
                        </xsl:with-param>
                    </xsl:apply-templates>
                    <codeSystems xmlns="">
                        <xsl:copy-of select="."/>
                    </codeSystems>
                </xsl:result-document>
            </xsl:if>
        </xsl:for-each-group>
    </xsl:template>
    <xd:doc>
        <xd:desc>Generates top level schematron and kicks off an optional second top level schematron for closed logic.</xd:desc>
    </xd:doc>
    <xsl:template match="template" mode="GEN">
        <xsl:call-template name="logMessage">
            <xsl:with-param name="level" select="$logDEBUG"/>
            <xsl:with-param name="msg">
                <xsl:text>+++ xsl:template mode GEN template=</xsl:text>
                <xsl:value-of select="@name"/>
                <xsl:text> effectiveDate=</xsl:text>
                <xsl:value-of select="@effectiveDate"/>
                <xsl:text> id=</xsl:text>
                <xsl:value-of select="@id"/>
                <xsl:text> isClosed=</xsl:text>
                <xsl:value-of select="string(@isClosed='true')"/>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:apply-templates select="." mode="ATTRIBCHECK"/>
        <xsl:variable name="uniqueId">
            <xsl:choose>
                <xsl:when test="string-length(@id)=0">
                    <xsl:value-of select="$projectPrefix"/>
                    <xsl:value-of select="generate-id()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat(@id,'-',replace(@effectiveDate,':',''))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="isTopLevelTemplate" as="xs:boolean">
            <xsl:variable name="tid" select="@id"/>
            <xsl:variable name="tnm" select="@name"/>
            <xsl:variable name="ted" select="@effectiveDate"/>
            <xsl:variable name="isNewestId" select="($allTemplates/templates/ref[@id=$tid][@effectiveDate=$ted][not(@duplicateOf)]/@newestForId)[1]" as="xs:boolean"/>
            <xsl:variable name="isNewestName" select="($allTemplates/templates/ref[@name=$tnm][@effectiveDate=$ted][not(@duplicateOf)]/@newestForName)[1]" as="xs:boolean"/>
            <xsl:value-of select="                 $allScenarios//representingTemplate[@ref=$tid and (@flexibility=$ted or (@flexibility='dynamic' and $isNewestId) or (not(@flexibility) and $isNewestId))] or                  $allScenarios//representingTemplate[@ref=$tnm and (@flexibility=$ted or (@flexibility='dynamic' and $isNewestName) or (not(@flexibility) and $isNewestName))]             "/>
        </xsl:variable>
        <xsl:if test="$isTopLevelTemplate">
            <xsl:call-template name="logMessage">
                <xsl:with-param name="level" select="$logDEBUG"/>
                <xsl:with-param name="msg">
                    <xsl:text>+++ xsl:template mode GEN template is a top level template=</xsl:text>
                    <xsl:value-of select="$isTopLevelTemplate"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        <xsl:result-document href="{$theRuntimeIncludeDir}{$uniqueId}.sch" format="xml">
            <xsl:apply-templates select="//project">
                <xsl:with-param name="what">
                    <xsl:value-of select="concat($uniqueId, ' (fragment schematron) &#xA;  ', @name, ' ')"/>
                    <xsl:call-template name="doDescription">
                        <xsl:with-param name="ns" select="desc"/>
                        <!--<xsl:with-param name="lang" select="$defaultLanguage"/>-->
                    </xsl:call-template>
                </xsl:with-param>
            </xsl:apply-templates>
            <xsl:variable name="comment">
                <xsl:text>
</xsl:text>
                <xsl:text>Template derived pattern</xsl:text>
                <xsl:text>
</xsl:text>
                <xsl:text>===========================================</xsl:text>
                <xsl:text>
</xsl:text>
                <xsl:text>ID: </xsl:text>
                <xsl:value-of select="@id"/>
                <xsl:text>
</xsl:text>
                <xsl:text>Name: </xsl:text>
                <xsl:value-of select="if (string-length(@displayName)&gt;0) then @displayName else @name"/>
                <xsl:text>
</xsl:text>
                <xsl:text>Description: </xsl:text>
                <xsl:value-of select="substring(string-join(desc[1]//text(),' '),1, 1000)"/>
                <xsl:text>
</xsl:text>
            </xsl:variable>
            <xsl:comment select="$comment"/>
            <xsl:text>
</xsl:text>
            <pattern xmlns="http://purl.oclc.org/dsdl/schematron" id="template-{$uniqueId}">
                <title>
                    <xsl:value-of select="if (string-length(@displayName)&gt;0) then @displayName else @name"/>
                </title>
                <xsl:call-template name="doTemplateRules">
                    <xsl:with-param name="rc" select="."/>
                    <xsl:with-param name="isClosedAttr" select="$switchCreateSchematronClosed or xs:boolean(@isClosed)"/>
                    <xsl:with-param name="nestinglevel" select="0"/>
                    <xsl:with-param name="checkIsClosed" select="false()"/>
                    <xsl:with-param name="sofar" select="concat(@id,'-',@effectiveDate)"/>
                    <xsl:with-param name="templateFormat" select="local:getTemplateFormat(.)"/>
                </xsl:call-template>
            </pattern>
        </xsl:result-document>
        <xsl:if test="$isTopLevelTemplate=true() or @isClosed='true'">
            <xsl:result-document href="{$theRuntimeIncludeDir}{$uniqueId}-closed.sch" format="xml">
                <xsl:apply-templates select="//project">
                    <xsl:with-param name="what">
                        <xsl:value-of select="concat($uniqueId, ' (fragment schematron) &#xA;  ', @name, ' ')"/>
                        <xsl:call-template name="doDescription">
                            <xsl:with-param name="ns" select="desc"/>
                            <!--<xsl:with-param name="lang" select="$defaultLanguage"/>-->
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:apply-templates>
                <xsl:variable name="comment">
                    <xsl:text>
</xsl:text>
                    <xsl:text>Template derived pattern</xsl:text>
                    <xsl:text>
</xsl:text>
                    <xsl:text>===========================================</xsl:text>
                    <xsl:text>
</xsl:text>
                    <xsl:text>ID: </xsl:text>
                    <xsl:value-of select="@id"/>
                    <xsl:text>
</xsl:text>
                    <xsl:text>Name: </xsl:text>
                    <xsl:value-of select="if (string-length(@displayName)&gt;0) then @displayName else @name"/>
                    <xsl:text>
</xsl:text>
                    <xsl:text>Description: </xsl:text>
                    <xsl:value-of select="substring(string-join(desc[1]//text(),' '),1, 1000)"/>
                    <xsl:text>
</xsl:text>
                </xsl:variable>
                <xsl:comment select="$comment"/>
                <xsl:text>
</xsl:text>
                <pattern xmlns="http://purl.oclc.org/dsdl/schematron" id="template-{$uniqueId}-closed">
                    <title>
                        <xsl:value-of select="if (string-length(@displayName)&gt;0) then @displayName else @name"/>
                    </title>
                    <xsl:call-template name="doTemplateRules">
                        <xsl:with-param name="rc" select="."/>
                        <xsl:with-param name="isClosedAttr" select="$switchCreateSchematronClosed or xs:boolean(@isClosed)"/>
                        <xsl:with-param name="nestinglevel" select="0"/>
                        <xsl:with-param name="checkIsClosed" select="true()"/>
                        <xsl:with-param name="sofar" select="concat(@id, '-', @effectiveDate)"/>
                        <xsl:with-param name="templateFormat" select="local:getTemplateFormat(.)"/>
                    </xsl:call-template>
                </pattern>
            </xsl:result-document>
        </xsl:if>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
        <xd:param name="rc"/>
        <xd:param name="previousitemlabel"/>
        <xd:param name="previousContext"/>
        <xd:param name="previousUniqueId"/>
        <xd:param name="previousUniqueEffectiveTime"/>
        <xd:param name="isClosedAttr">Are we currently in or under @isClosed='true'</xd:param>
        <xd:param name="checkIsClosed">Are we in the cycle for checking closed logic</xd:param>
        <xd:param name="nestinglevel">The nesting level we are currently at</xd:param>
        <xd:param name="sofar">Array of templates found so far where every array item is concat(template/@id,'-',template/@effectiveDate)</xd:param>
        <xd:param name="templateFormat">Format for the whole template chain. Default 'hl7v3xml1'</xd:param>
    </xd:doc>
    <xsl:template name="doTemplateRules">
        <!-- this is the context of the current rule node as a param -->
        <xsl:param name="rc" as="element()"/>
        <xsl:param name="previousitemlabel"/>
        <xsl:param name="previousContext"/>
        <xsl:param name="previousUniqueId"/>
        <xsl:param name="previousUniqueEffectiveTime"/>
        <xsl:param name="isClosedAttr" select="false()" as="xs:boolean"/>
        <xsl:param name="templateFormat" as="xs:string"/>
        <!-- param relevant for @isClosed calculation. This is only done for top level templates as @isClosed calculations 
            need to be in context. When isClosed=true AND checkIsClosed=true then these checks are performed
        -->
        <xsl:param name="checkIsClosed" select="false()" as="xs:boolean"/>
        
        <!-- this param for too deep nestings, detect recursion and give up if nestinglevel > maxNestingLevel -->
        <xsl:param name="nestinglevel"/>
        
        <!-- this param to keep track of where we have been to detect recursion -->
        <xsl:param name="sofar" as="xs:string*" required="yes"/>
        
        <xsl:variable name="recurrents" select="string-join(for $i in 1 to count($sofar) return if ($sofar[$i] = $sofar[last()]) then 'X' else '', '')"/>
        
        <xsl:choose>
            <!-- When we are really deep, but we don't have any recursion yet, we go on until we are really deep AND have recursion -->
            <xsl:when test="$nestinglevel >= $maxNestingLevel">
                <!-- too deeply nested, signalled somewhere already, be silent here -->
            </xsl:when>
            <xsl:when test="string-length($recurrents) >= $maxRecursionLevel">
                <!-- too many recursions, signalled somewhere already, be silent here -->
            </xsl:when>
            <xsl:otherwise>
                <!--
                    get item reference or description (to be shown in every assert/report)
                    an item desc has priority over an item ref number, so
                    - if item/desc is given use it
                    - if item/@label is not given then take it over from previous (previousitemlabel)
                    - if item/@label is given use it and build it with possible project prefix
                -->
                <xsl:variable name="itemlabel">
                    <xsl:call-template name="getNewItemLabel">
                        <xsl:with-param name="rc" select="$rc"/>
                        <xsl:with-param name="default">
                            <xsl:choose>
                                <xsl:when test="$checkIsClosed = true() and $rc/@mergeLabel">
                                    <xsl:value-of select="$rc/@mergeLabel"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$previousitemlabel"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:variable>
                
                <!-- get or set unique ID for this pattern
                     :: if context/@id is given use user defined @uniqueId + templateId
                     :: if user defiined @uniqueId is given use uniqueId
                     :: otherwise generate a unique id
                -->
                <xsl:variable name="uniqueId">
                    <xsl:choose>
                        <xsl:when test="string-length($previousUniqueId)&gt;1">
                            <xsl:value-of select="$previousUniqueId"/>
                        </xsl:when>
                        <xsl:when test="string-length($rc/@id)&gt;1">
                            <xsl:value-of select="$rc/@id"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- generate one -->
                            <xsl:value-of select="$projectPrefix"/>
                            <xsl:value-of select="generate-id()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="uniqueIdEffectiveTime">
                    <xsl:choose>
                        <xsl:when test="string-length($previousUniqueEffectiveTime)&gt;1">
                            <xsl:value-of select="$previousUniqueEffectiveTime"/>
                        </xsl:when>
                        <xsl:when test="string-length($rc/@effectiveDate)&gt;1">
                            <xsl:value-of select="$rc/@effectiveDate"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>DYNAMIC</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <!-- create the see url, typically a direct link to the template definition documentation in HTML -->
                <xsl:variable name="seethisthingurl">
                    <xsl:choose>
                        <xsl:when test="$seeThisUrlLocation=('live', 'live-services')">
                            <xsl:value-of select="concat($artdecordeeplinkprefix, 'decor-templates--', $projectPrefix, '?id=', $uniqueId)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$seeURLprefix"/>
                            <xsl:value-of select="$theHtmlDir"/>
                            <xsl:value-of select="local:doHtmlName('TM', $uniqueId, $uniqueIdEffectiveTime, '.html', 'true')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <!-- get context
                    situations:
                     - if this is a template with id, context is defined initially by the templateId expr itself, subsequently by adding @name
                     - if this is a template with a context path, use the path as the context with some tricks
                     - if this is an element with a name only, take over the previous context, cave //
                     - if this is an include with a ref
                -->
                
                <xsl:variable name="currentContext">
                    <xsl:choose>
                        <xsl:when test="$rc[self::defineVariable | self::let | self::assert| self::report]">
                            <!-- schematron does not change context, take previous one -->
                            <xsl:value-of select="$previousContext"/>
                        </xsl:when>
                        <xsl:when test="$rc[self::include]">
                            <!-- includes do not change context, take previous one -->
                            <!-- INCLUDE_CONTEXT - for include -->
                            <xsl:value-of select="$previousContext"/>
                        </xsl:when>
                        <xsl:when test="$rc[self::choice]">
                            <!-- choices do not change context, take previous one -->
                            <!-- CHOICE_CONTEXT - for choice -->
                            <xsl:value-of select="$previousContext"/>
                        </xsl:when>
                        <xsl:when test="$rc[self::template][not(context/@id)]">
                            <!-- specific path name given or // (root element) -->
                            <xsl:choose>
                                <xsl:when test="$rc[context[string-length(@path) > 0]]">
                                    <xsl:value-of select="$rc/context[1]/@path"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>//</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="$rc[self::template][context[@id]] | $rc[string-length(@name) > 0]">
                            <!-- Get current context part. Works on any element type -->
                            <xsl:variable name="finalPart">
                                <xsl:call-template name="getWherePathFromNodeset">
                                    <xsl:with-param name="rccontent" select="$rc"/>
                                    <xsl:with-param name="sofar" select="()"/>
                                    <xsl:with-param name="templateFormat" select="$templateFormat"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <!-- name of an element given -->
                            <!-- 
                                if previousContext is "/" only then the root element is meant
                                make it: /elementname
                                if previousContext is "//" only then any element is meant
                                make it: //elementname
                                in all other cases construct the context as
                                concat of previousContext and the element
                            -->
                            <xsl:choose>
                                <xsl:when test="$previousContext='/'">
                                    <xsl:text>/</xsl:text>
                                </xsl:when>
                                <xsl:when test="$previousContext='//'">
                                    <xsl:text>//</xsl:text>
                                </xsl:when>
                                <xsl:when test="$rc[self::template][context[@id='*']]">
                                    <xsl:text>*[</xsl:text>
                                </xsl:when>
                                <xsl:when test="$rc[self::template][context[@id='**']]">
                                    <xsl:text>*[</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$previousContext"/>
                                    <xsl:text>/</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:value-of select="$finalPart"/>
                            <xsl:choose>
                                <xsl:when test="$rc[self::template][context[@id='*']]">
                                    <xsl:text>]</xsl:text>
                                </xsl:when>
                                <xsl:when test="$rc[self::template][context[@id='**']]">
                                    <xsl:text>]</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                        <!-- DEPRECATED!!!!, includes don't have a context -->
                        <xsl:when test="$rc[string-length(@include)&gt;0]">
                            <!-- INCLUDE_CONTEXT - for include -->
                            <xsl:value-of select="@include"/>
                        </xsl:when>
                        <!-- ERROR -->
                        <xsl:otherwise>
                            <xsl:text>ERROR_IN_CONTEXT - previous context </xsl:text>
                            <xsl:value-of select="$previousContext"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="contextSuffix">
                    <xsl:call-template name="lastIndexOf">
                        <xsl:with-param name="string" select="$currentContext"/>
                        <xsl:with-param name="char" select="'/'"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="comment">
                    <xsl:text>
</xsl:text>
                    <xsl:text>Template derived rules for ID: </xsl:text>
                    <xsl:value-of select="$uniqueId"/>
                    <xsl:text>
</xsl:text>
                    <xsl:if test="string-length($currentContext)&gt;0">
                        <xsl:text>Context: </xsl:text>
                        <xsl:value-of select="$currentContext"/>
                        <xsl:text>
</xsl:text>
                    </xsl:if>
                    <xsl:text>Item: </xsl:text>
                    <xsl:value-of select="$itemlabel"/>
                    <xsl:if test="$rc/@scenario">
                        <xsl:text> - scenario(s): </xsl:text>
                        <xsl:value-of select="$rc/@scenario"/>
                    </xsl:if>
                    <xsl:text>
</xsl:text>
                </xsl:variable>
                <xsl:call-template name="logMessage">
                    <xsl:with-param name="level" select="$logALL"/>
                    <xsl:with-param name="msg">
                        <xsl:text>Processing Rule: </xsl:text>
                        <xsl:value-of select="name()"/>
                        <xsl:text> -context </xsl:text>
                        <xsl:value-of select="$currentContext"/>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:choose>
                    <!-- closed template / element inherited from parent -->
                    <!-- 2DO: Fix temporary solution:
                         Always check for undefined elements, and
                            When this a true closed element we'll issue an error in the context of the 'offending' element
                            When this an open element we'll issue a warning in the context of the 'offending' element
                            
                         Desired solution:
                            When this is a true closed element we'll issue an error in the context of the 'offending' element
                            When this is an open element issue a warning through lookahead. If an unexpected element is encountered, issue a warning
                    -->
                    <xsl:when test="$checkIsClosed=true() and (($isClosedAttr=true() or string(@isClosed)='true') or $switchCreateSchematronWithWarningsOnOpen)">
                        <xsl:variable name="assertRole">
                            <xsl:choose>
                                <xsl:when test="$isClosedAttr=true() or string(@isClosed)='true'">
                                    <xsl:text>error</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>warning</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <!-- Output different message for error vs. warning -->
                        <xsl:variable name="assertMessageKey">
                            <xsl:choose>
                                <xsl:when test="$assertRole='error'">
                                    <xsl:text>closedElementOrTemplateError</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>closedElementOrTemplateWarning</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        
                        <xsl:if test="count($rc/element)&gt;0">
                            <xsl:call-template name="logMessage">
                                <xsl:with-param name="level" select="$logALL"/>
                                <xsl:with-param name="msg">
                                    <xsl:text>closed template context </xsl:text>
                                    <xsl:value-of select="$currentContext"/>
                                    <xsl:text> :: ==== reject * except </xsl:text>
                                    <xsl:for-each select="element">
                                        <xsl:variable name="theName">
                                            <xsl:call-template name="getWherePathFromNodeset">
                                                <xsl:with-param name="rccontent" select="."/>
                                                <xsl:with-param name="sofar" select="()"/>
                                                <xsl:with-param name="templateFormat" select="$templateFormat"/>
                                            </xsl:call-template>
                                        </xsl:variable>
                                        <xsl:value-of select="$theName"/>
                                        <xsl:text> </xsl:text>
                                    </xsl:for-each>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:if>
                        
                        <xsl:choose>
                            <xsl:when test="$rc/self::choice">
                                <!-- skip -->
                            </xsl:when>
                            <xsl:when test="$rc/self::include">
                                <xsl:apply-templates select="$rc" mode="doTemplateRulesForClosed">
                                    <xsl:with-param name="rc" select="."/>
                                    <xsl:with-param name="itemlabel" select="$itemlabel"/>
                                    <xsl:with-param name="currentContext" select="$currentContext"/>
                                    <xsl:with-param name="uniqueId" select="$uniqueId"/>
                                    <xsl:with-param name="uniqueEffectiveTime" select="$uniqueIdEffectiveTime"/>
                                    <xsl:with-param name="isClosedAttr" select="$switchCreateSchematronClosed or xs:boolean(@isClosed) or $isClosedAttr"/>
                                    <xsl:with-param name="checkIsClosed" select="$checkIsClosed"/>
                                    <xsl:with-param name="nestinglevel" select="if (self::choice) then ($nestinglevel) else ($nestinglevel + 1)"/>
                                    <!--<xsl:with-param name="predicatetest" select="$predicatetest"/>-->
                                    <xsl:with-param name="seethisthingurl" select="$seethisthingurl"/>
                                    <xsl:with-param name="contextSuffix" select="$contextSuffix"/>
                                    <xsl:with-param name="sofar" select="$sofar"/>
                                    <xsl:with-param name="templateFormat" select="$templateFormat"/>
                                </xsl:apply-templates>
                            </xsl:when>
                            <xsl:when test="$rc/self::element | $rc/self::template">
                                <!--
                                    If this an element or template that is closed either specifically or by inheritance,
                                    get all underlying elements and add a check that counts any elements not in the defined set.
                                    To get underlying elements we should get all immediate elements, and all immediate elements 
                                    under include and choice
                                -->
                                <xsl:if test="count($rc/element|$rc/include|$rc/choice) &gt; 0">
                                    <!-- 2016-02-04 AH There is no point in checking a path like //*[not(hl7:REPC_IN020910NL)] as that would fit any path -->
                                    <xsl:if test="not($currentContext='//')">
                                        <!-- create rules for every element but only if this is not a template in ** context -->
                                        <xsl:variable name="elementList">
                                            <xsl:variable name="ttt">
                                                <!-- Will have one trailing pipe symbol | too many. Strip that later on -->
                                                <xsl:apply-templates select="$rc/element|$rc/include|$rc/choice" mode="getNamesForIsClosed">
                                                    <xsl:with-param name="sofar" select="$sofar"/>
                                                    <xsl:with-param name="templateFormat" select="$templateFormat"/>
                                                </xsl:apply-templates>
                                                <!-- Suppose this is an element with contains, then we should take what's in @contains also into account -->
                                                <xsl:if test="$rc/self::element[@contains]">
                                                    <xsl:variable name="rccontent" as="element()?">
                                                        <xsl:call-template name="getRulesetContent">
                                                            <xsl:with-param name="ruleset" select="$rc/@contains"/>
                                                            <xsl:with-param name="flexibility" select="$rc/@flexibility"/>
                                                            <xsl:with-param name="previousContext" select="$currentContext"/>
                                                            <xsl:with-param name="sofar" select="$sofar"/>
                                                        </xsl:call-template>
                                                    </xsl:variable>
                                                    <xsl:apply-templates select="$rccontent/element|$rccontent/include|$rccontent/choice" mode="getNamesForIsClosedTemplate">
                                                        <xsl:with-param name="sofar" select="$sofar, concat($rccontent/@id,'-',$rccontent/@effectiveDate)"/>
                                                        <xsl:with-param name="templateFormat" select="$templateFormat"/>
                                                    </xsl:apply-templates>
                                                </xsl:if>
                                            </xsl:variable>
                                            <xsl:variable name="tttt" select="replace($ttt,'\s*\|\s*$','')"/>
                                            <xsl:choose>
                                                <xsl:when test="$tttt = ''">*</xsl:when>
                                                <xsl:otherwise><xsl:value-of select="$tttt"/></xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:variable>
                                        <xsl:variable name="ruleid" select="local:randomString2(.,$checkIsClosed)"/>
                                        <xsl:text>

</xsl:text>
                                        <xsl:comment>
                                            <xsl:text> Checking undefined contents for template/element @isClosed="</xsl:text>
                                            <xsl:value-of select="($isClosedAttr = true() or string(@isClosed) = 'true')"/>
                                            <xsl:text>". Match context that we did not already match </xsl:text>
                                        </xsl:comment>
                                        <xsl:text>
</xsl:text>
                                        <rule xmlns="http://purl.oclc.org/dsdl/schematron" context="{$currentContext}{if (not(ends-with($currentContext,'/'))) then ('/') else ()}*[not({$elementList})]" id="{$ruleid}">
                                            <assert role="{$assertRole}" see="{$seethisthingurl}" test="not(.)">
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="$assertMessageKey"/>
                                                    <xsl:with-param name="p1">
                                                        <xsl:value-of select="$itemlabel"/>
                                                        <xsl:if test="not(starts-with($ruleid,'tmp-'))">
                                                            <xsl:text>/</xsl:text>
                                                            <xsl:value-of select="$ruleid"/>
                                                        </xsl:if>
                                                    </xsl:with-param>
                                                    <xsl:with-param name="p2" select="replace($elementList, 'self::', '')"/>
                                                </xsl:call-template>
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of select="concat('(rule-reference: ', $ruleid, ')')"/>
                                            </assert>
                                        </rule>
                                    </xsl:if>
                                </xsl:if>
                            </xsl:when>
                        </xsl:choose>
                        
                        <!--
                             If current node is a closed element in an open parent (template or element) and
                             has a generated predicate name that does not equal its actual @name, e.g.
                             actual    hl7:section                                   vs. 
                             generated hl7:section[hl7:templateId/@root='1.2.3.4']
                             then additionally check that there are no siblings by this @name other than those
                             matching that predicate.
                             Note: this means you cannot have something like:
                             
                             <choice minimumMultiplicity="1" maximumMultiplicity="*">
                                 <element name="hl7:component" contains="Section1" isClosed="true"/>
                                 <element name="hl7:component" contains="Section2" isClosed="true"/>
                             </choice>
                             
                             as the component with Section1 would not allow the component with Section2 as 
                             sibling and vice versa. For this example you should add isClosed to one of its parents.
                             
                             AH: For this reason I've disabled this part for now...
                         -->
                        <!--<xsl:if test="0=1 and $rc/self::element and string(@isClosed)='true' and (string($isClosed)='false' or string($isClosed)='')">
                            <xsl:variable name="theName">
                                <xsl:call-template name="getWherePathFromNodeset">
                                    <xsl:with-param name="rccontent" select="$rc"/>
                                    <xsl:with-param name="templateFormat" select="$templateFormat"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:if test="$theName != @name">
                                <xsl:call-template name="logMessage">
                                    <xsl:with-param name="level" select="$logALL"/>
                                    <xsl:with-param name="msg">
                                        <xsl:text>closed self, element context </xsl:text>
                                        <xsl:value-of select="$context"/>
                                        <xsl:text> ::====reject </xsl:text>
                                        <xsl:value-of select="@name"/>
                                        <xsl:text> except </xsl:text>
                                        <xsl:value-of select="$theName"/>
                                    </xsl:with-param>
                                </xsl:call-template>
                                <xsl:variable name="tt">
                                    <xsl:value-of select="concat('../', @name)"/>
                                    <xsl:text> except (</xsl:text>
                                    <xsl:value-of select="concat('../', $theName)"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:variable>
                                <assert xmlns="http://purl.oclc.org/dsdl/schematron" role="warning" see="{$seethisthingurl}" test="count({$tt})=0">
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'closedElementOrTemplateNoSiblings'"/>
                                        <xsl:with-param name="p1" select="$itemlabel"/>
                                        <xsl:with-param name="p2" select="name()"/>
                                        <xsl:with-param name="p3" select="$theName"/>
                                    </xsl:call-template>
                                </assert>
                            </xsl:if>
                        </xsl:if>-->
                    </xsl:when>
                    <!-- create rules, except if context is "//" -->
                    <xsl:when test="$checkIsClosed=false() and $currentContext != '//'">
                        <xsl:text>
</xsl:text>
                        <xsl:comment select="$comment"/>
                        <xsl:text>
</xsl:text>
                        <xsl:choose>
                            <!--<xsl:when test="$rc/self::defineVariable">
                                <xsl:apply-templates select="$rc" mode="doTemplateRules">
                                    <xsl:with-param name="sofar" select="$sofar"/>
                                    <xsl:with-param name="templateFormat" select="$templateFormat"/>
                                </xsl:apply:templates>
                            </xsl:when>
                            <xsl:when test="$rc/self::let">
                                <xsl:apply-templates select="$rc" mode="doTemplateRules">
                                    <xsl:with-param name="sofar" select="$sofar"/>
                                    <xsl:with-param name="templateFormat" select="$templateFormat"/>
                                </xsl:apply:templates>
                            </xsl:when>
                            <xsl:when test="$rc/self::assert|$rc/self::report">
                                <xsl:apply-templates select="$rc" mode="doTemplateRules">
                                    <xsl:with-param name="seethisthingurl" select="$seethisthingurl"/>
                                    <xsl:with-param name="itemlabel" select="$itemlabel"/>
                                    <xsl:with-param name="sofar" select="$sofar"/>
                                    <xsl:with-param name="templateFormat" select="$templateFormat"/>
                                </xsl:apply-templates>
                            </xsl:when>-->
                            <xsl:when test="$rc/self::desc | $rc/self::item | $rc/self::classification | $rc/self::relationship">
                                <!-- skip -->
                            </xsl:when>
                            <xsl:when test="$rc/self::attribute">
                                <!-- handled elsewhere -->
                            </xsl:when>
                            <xsl:when test="$rc/self::include | $rc/self::choice">
                                <!-- handle an include or a choice on top level template -->
                                <!-- skip -->
                                <!--<xsl:apply-templates select="." mode="doTemplateRules">
                                    <xsl:with-param name="rc" select="."/>
                                    <xsl:with-param name="itemlabel" select="$itemlabel"/>
                                    <xsl:with-param name="currentContext" select="$currentContext"/>
                                    <xsl:with-param name="uniqueId" select="$uniqueId"/>
                                    <xsl:with-param name="uniqueEffectiveTime" select="$uniqueIdEffectiveTime"/>
                                    <xsl:with-param name="isClosedAttr" select="$switchCreateSchematronClosed or xs:boolean(@isClosed) or $isClosed"/>
                                    <xsl:with-param name="checkIsClosed" select="$checkIsClosed"/>
                                    <xsl:with-param name="nestinglevel" select="if (self::choice) then ($nestinglevel) else ($nestinglevel+1)"/>
                                    <xsl:with-param name="predicatetest" select="$predicatetest"/>
                                    <xsl:with-param name="seethisthingurl" select="$seethisthingurl"/>
                                    <xsl:with-param name="contextSuffix" select="$contextSuffix"/>
                                    <xsl:with-param name="sofar" select="$sofar"/>
                                    <xsl:with-param name="templateFormat" select="$templateFormat"/>
                                </xsl:apply-templates>-->
                            </xsl:when>
                            <xsl:when test="$rc/self::template | $rc/self::element">
                                <!-- it shall be an element or so -->
                                <xsl:variable name="ruleroot" as="element()">
                                    <xsl:variable name="ruleid" select="local:randomString2(.,$checkIsClosed)"/>
                                    <rule xmlns="http://purl.oclc.org/dsdl/schematron" context="{$currentContext}" id="{$ruleid}">
        
                                        <!-- first look thru all includes and put their attribute checks into this context -->
                                        <xsl:for-each select="$rc/include">
                                            <!-- make a look-ahead of all attributes and add them in this context here -->
                                            <xsl:variable name="rccontent" as="element()?">
                                                <xsl:call-template name="getRulesetContent">
                                                    <xsl:with-param name="ruleset" select="@ref"/>
                                                    <xsl:with-param name="flexibility" select="@flexibility"/>
                                                    <xsl:with-param name="previousContext" select="$currentContext"/>
                                                    <xsl:with-param name="sofar" select="$sofar"/>
                                                </xsl:call-template>
                                            </xsl:variable>
                                            <xsl:if test="not($rccontent/context[@id])">
                                                <!-- process attributes first -->
                                                <xsl:variable name="theattributechecks">
                                                    <xsl:apply-templates select="$rccontent/attribute" mode="GEN">
                                                        <xsl:with-param name="itemlabel" select="$itemlabel"/>
                                                        <xsl:with-param name="currentContext" select="$currentContext"/>
                                                        <xsl:with-param name="uniqueId" select="$uniqueId"/>
                                                        <xsl:with-param name="seethisthingurl" select="$seethisthingurl"/>
                                                        <xsl:with-param name="contextSuffix" select="$contextSuffix"/>
                                                    </xsl:apply-templates>
                                                </xsl:variable>
                                                <xsl:for-each select="$theattributechecks/node()">
                                                    <xsl:call-template name="doCopyIntoSchematronNamespace"/>
                                                </xsl:for-each>
                                            </xsl:if>
                                        </xsl:for-each>
                                        <xsl:choose>
                                            <!-- if this is an element do the following things -->
                                            <xsl:when test="$rc/self::element">
                                                <!-- then do @datatype of an element
                                                     ================================
                                                -->
                                                <!-- preserve strength if any -->
                                                <xsl:variable name="strength" select="$rc/@strength"/>
                                                <!-- @datatype -->
                                                <xsl:if test="$rc/@datatype">
            
                                                    <!-- 
                                                        FIXME: Hack to support CDA specs that import the HL7 datatypes into their own namespace
                                                        The assumption here is that if you remove the namspace an HL7 default DTr1 emerges. E.g. 
                                                        epsos:PQ equals PQ. This will fail if some spec Y comes along and defines y:PQ where PQ != HL7 DTr1 PQ
                                                    -->
                                                    <xsl:variable name="dt" select="$rc/@datatype"/>
                                                    <xsl:variable name="datatypeName">
                                                        <xsl:choose>
                                                            <xsl:when test="contains($dt, ':')">
                                                                <xsl:value-of select="substring-after($dt, ':')"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:value-of select="$dt"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </xsl:variable>
                                                    <xsl:variable name="datatypeType" as="xs:string?">
                                                        <xsl:choose>
                                                            <xsl:when test="$rc/ancestor-or-self::*/@templateformat[string-length() > 0]">
                                                                <xsl:value-of select="($rc/ancestor-or-self::*/@templateformat[string-length() > 0])[1]"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:value-of select="local:getTemplateFormat($rc/ancestor-or-self::template[1])"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </xsl:variable>
                                                    
                                                    <!-- 
                                                         check whether dt is supported
                                                         if not $isSupportedDatatype will be empty
                                                         if yes $isSupportedDatatype will contain the (unflavored) data type
                                                     -->
                                                    <xsl:variable name="supported" select="$supportedDatatypes/*[@type = $datatypeType][@name = ($datatypeName, $dt)]" as="element()*"/>
                                                    <xsl:variable name="isSupportedDatatype">
                                                        <xsl:choose>
                                                            <xsl:when test="$supported[@name = $dt][not(@isFlavorOf)]">
                                                                <xsl:value-of select="$dt"/>
                                                            </xsl:when>
                                                            <xsl:when test="$supported[@name = $dt][@isFlavorOf]">
                                                                <xsl:value-of select="($supported[@name = $dt]/@isFlavorOf)[1]"/>
                                                            </xsl:when>
                                                            <xsl:when test="$supported[@name = $datatypeName][not(@isFlavorOf)]">
                                                                <xsl:value-of select="$datatypeName"/>
                                                            </xsl:when>
                                                            <xsl:when test="$supported[@name = $datatypeName][@isFlavorOf]">
                                                                <xsl:value-of select="($supported[@name = $datatypeName]/@isFlavorOf)[1]"/>
                                                            </xsl:when>
                                                        </xsl:choose>
                                                    </xsl:variable>
                                                    <xsl:if test="string-length($isSupportedDatatype) > 0 and $switchCreateDatatypeChecks=true()">
                                                        <xsl:choose>
                                                            <xsl:when test="$dt = $isSupportedDatatype">
                                                                <!-- 
                                                                    FIXME: Hack to support CDA specs that import the HL7 datatypes into their own namespace
                                                                    The assumption here is that if you remove the namspace an HL7 default DTr1 emerges. E.g. 
                                                                    epsos:PQ equals PQ. This will fail if some spec Y comes along and defines y:PQ where PQ != HL7 DTr1 PQ
                                                                -->
                                                                <extends rule="{replace($isSupportedDatatype,':','-')}"/>
                                                            </xsl:when>
                                                            <xsl:when test="$supported[@name = $dt]">
                                                                <!-- include extends if datatype is supported -->
                                                                <extends rule="{$dt}"/>
                                                            </xsl:when>
                                                        </xsl:choose>
                                                        <!-- If the specification says that xsi:type is required then the context will already preselect 
                                                            that part through getWherePartFromNodeSet. No use repeating that part in that case. -->
                                                        <xsl:if test="not($rc/attribute[not(@prohibited = 'true')][not(@isOptional = 'true')][@name = ('xsi:type')])">
                                                            <xsl:call-template name="xsiTypePredicate">
                                                                <xsl:with-param name="dt" select="$rc/@datatype"/>
                                                                <xsl:with-param name="dttype" select="$datatypeType"/>
                                                                <xsl:with-param name="doAssert" select="true()"/>
                                                                <xsl:with-param name="assertItemLabel" select="$itemlabel"/>
                                                                <xsl:with-param name="assertSeeUrl" select="$seethisthingurl"/>
                                                                <xsl:with-param name="required" select="false()"/>
                                                            </xsl:call-template>
                                                        </xsl:if>
                                                        <xsl:if test="$isSupportedDatatype = 'TS'">
                                                            <assert role="error" see="{$seethisthingurl}" test="not(*)">
                                                                <xsl:call-template name="getMessage">
                                                                    <xsl:with-param name="key" select="'validTSdatatype'"/>
                                                                    <xsl:with-param name="p1" select="$itemlabel"/>
                                                                    <xsl:with-param name="p2" select="$dt"/>
                                                                </xsl:call-template>
                                                            </assert>
                                                        </xsl:if>
                                                    </xsl:if>
            
                                                    <!-- check properties -->
                                                    <xsl:if test="count(property[@*])&gt;0">
                                                        <!-- get text() if this is a type of string or so, @value otherwise (DTr1) -->
                                                        <xsl:variable name="theValue" as="xs:string">
                                                            <xsl:choose>
                                                                <xsl:when test="$isSupportedDatatype=('SC','ST','ED')">text()</xsl:when>
                                                                <xsl:otherwise>@value</xsl:otherwise>
                                                            </xsl:choose>
                                                        </xsl:variable>
                                                        <!-- do the first round for properties: minLength or @maxLength or @value or @unit or @currency -->
                                                        <xsl:variable name="pqexpr">
                                                            <xsl:for-each select="property[@minLength or @maxLength or @value or @unit or @currency]">
                                                                <xsl:text>(@nullFlavor or (</xsl:text>
                                                                <xsl:if test="@minLength">
                                                                    <xsl:text>string-length(string(</xsl:text>
                                                                    <xsl:value-of select="$theValue"/>
                                                                    <xsl:text>))&gt;=</xsl:text>
                                                                    <xsl:value-of select="@minLength"/>
                                                                </xsl:if>
                                                                <xsl:if test="@maxLength">
                                                                    <xsl:if test="@minLength">
                                                                        <xsl:text> and </xsl:text>
                                                                    </xsl:if>
                                                                    <xsl:text>string-length(string(</xsl:text>
                                                                    <xsl:value-of select="$theValue"/>
                                                                    <xsl:text>))&lt;=</xsl:text>
                                                                    <xsl:value-of select="@maxLength"/>
                                                                </xsl:if>
                                                                <xsl:if test="@value">
                                                                    <xsl:if test="@minLength or @maxLength">
                                                                        <xsl:text> and </xsl:text>
                                                                    </xsl:if>
                                                                    <xsl:value-of select="$theValue"/>
                                                                    <xsl:text>='</xsl:text>
                                                                    <xsl:value-of select="@value"/>
                                                                    <xsl:text>'</xsl:text>
                                                                </xsl:if>
                                                                <xsl:if test="@unit">
                                                                    <xsl:if test="@minLength or @maxLength or @value">
                                                                        <xsl:text> and </xsl:text>
                                                                    </xsl:if>
                                                                    <xsl:text>@unit='</xsl:text>
                                                                    <xsl:value-of select="@unit"/>
                                                                    <xsl:text>'</xsl:text>
                                                                </xsl:if>
                                                                <xsl:if test="@currency">
                                                                    <xsl:if test="@minLength or @maxLength or @value or @unit">
                                                                        <xsl:text> and </xsl:text>
                                                                    </xsl:if>
                                                                    <xsl:text>@currency='</xsl:text>
                                                                    <xsl:value-of select="@currency"/>
                                                                    <xsl:text>'</xsl:text>
                                                                </xsl:if>
                                                                <xsl:text>))</xsl:text>
                                                                <xsl:if test="position() != last()">
                                                                    <xsl:text> or </xsl:text>
                                                                </xsl:if>
                                                            </xsl:for-each>
                                                        </xsl:variable>
                                                        <xsl:variable name="pqerr">
                                                            <xsl:call-template name="getMessage">
                                                                <xsl:with-param name="key" select="'elmShall'"/>
                                                                <xsl:with-param name="p1" select="$itemlabel"/>
                                                                <xsl:with-param name="p2" select="'value'"/>
                                                            </xsl:call-template>
                                                            <xsl:for-each select="property[@minLength or @maxLength or @value or @unit]">
                                                                <xsl:if test="@minLength or @maxLength">
                                                                    <xsl:call-template name="getMessage">
                                                                        <xsl:with-param name="key" select="'beStringLengthRange'"/>
                                                                        <xsl:with-param name="p1">
                                                                            <xsl:choose>
                                                                                <xsl:when test="@minLength">
                                                                                    <xsl:value-of select="@minLength"/>
                                                                                </xsl:when>
                                                                                <xsl:otherwise>
                                                                                    <xsl:value-of select="'0'"/>
                                                                                </xsl:otherwise>
                                                                            </xsl:choose>
                                                                        </xsl:with-param>
                                                                        <xsl:with-param name="p2">
                                                                            <xsl:choose>
                                                                                <xsl:when test="@maxLength">
                                                                                    <xsl:value-of select="@maxLength"/>
                                                                                </xsl:when>
                                                                                <xsl:otherwise>
                                                                                    <xsl:value-of select="'*'"/>
                                                                                </xsl:otherwise>
                                                                            </xsl:choose>
                                                                        </xsl:with-param>
                                                                    </xsl:call-template>
                                                                </xsl:if>
                                                                <xsl:if test="@value">
                                                                    <xsl:call-template name="getMessage">
                                                                        <xsl:with-param name="key" select="'useValue'"/>
                                                                        <xsl:with-param name="p1" select="@value"/>
                                                                    </xsl:call-template>
                                                                </xsl:if>
                                                                <xsl:if test="@unit">
                                                                    <xsl:call-template name="getMessage">
                                                                        <xsl:with-param name="key" select="'useUnit'"/>
                                                                        <xsl:with-param name="p1" select="@unit"/>
                                                                    </xsl:call-template>
                                                                    <xsl:if test="@minInclude or @maxInclude or @fractionDigits">
                                                                        <xsl:call-template name="getMessage">
                                                                            <xsl:with-param name="key" select="'andWord'"/>
                                                                        </xsl:call-template>
                                                                        <xsl:text> </xsl:text>
                                                                    </xsl:if>
                                                                </xsl:if>
                                                                <xsl:if test="position() != last()">
                                                                    <xsl:text> </xsl:text>
                                                                    <xsl:call-template name="getMessage">
                                                                        <xsl:with-param name="key" select="'orWord'"/>
                                                                    </xsl:call-template>
                                                                    <xsl:text> </xsl:text>
                                                                </xsl:if>
                                                            </xsl:for-each>
                                                        </xsl:variable>
                                                        <xsl:if test="string-length($pqexpr)&gt;0">
                                                            <assert role="error" see="{$seethisthingurl}" test="{$pqexpr}">
                                                                <xsl:value-of select="$pqerr"/>
                                                            </assert>
                                                        </xsl:if>
                                                        <!-- repeat for minInclude or @maxInclude or @fractionDigits but issue a warning instead of an error-->
                                                        <xsl:variable name="pqexpr2">
                                                            <xsl:for-each select="property[@minInclude or @maxInclude or @fractionDigits]">
                                                                <xsl:text>(@nullFlavor or (</xsl:text>
                                                                <xsl:if test="@minInclude">
                                                                    <xsl:text>number(</xsl:text>
                                                                    <xsl:value-of select="$theValue"/>
                                                                    <xsl:text>)&gt;=</xsl:text>
                                                                    <xsl:value-of select="@minInclude"/>
                                                                </xsl:if>
                                                                <xsl:if test="@maxInclude">
                                                                    <xsl:if test="@minInclude">
                                                                        <xsl:text> and </xsl:text>
                                                                    </xsl:if>
                                                                    <xsl:text>number(</xsl:text>
                                                                    <xsl:value-of select="$theValue"/>
                                                                    <xsl:text>)&lt;=</xsl:text>
                                                                    <xsl:value-of select="@maxInclude"/>
                                                                </xsl:if>
                                                                <xsl:if test="string-length(@fractionDigits) &gt; 0">
                                                                    <xsl:variable name="theFractionDigits" select="replace(@fractionDigits, '!', '') cast as xs:integer"/>
                                                                    <xsl:variable name="exact" select="contains(@fractionDigits, '!')"/>
                                                                    <xsl:if test="@minInclude or @maxInclude">
                                                                        <xsl:text> and </xsl:text>
                                                                    </xsl:if>
                                                                    <xsl:text>(matches(string(</xsl:text>
                                                                    <xsl:value-of select="$theValue"/>
                                                                    <xsl:text>), '^[-+]?[0-9]*</xsl:text>
                                                                    <xsl:if test="$theFractionDigits &gt; 0">
                                                                        <xsl:text>\.[0-9]{</xsl:text>
                                                                        <xsl:value-of select="$theFractionDigits"/>
                                                                        <xsl:text>,</xsl:text>
                                                                        <xsl:choose>
                                                                            <xsl:when test="$exact = true()">
                                                                                <xsl:value-of select="$theFractionDigits"/>
                                                                            </xsl:when>
                                                                            <xsl:otherwise>
                                                                                <!-- some xpath eval engines don't like {n,} (upper undet) so always make this fraction digit thing to {n,99} -->
                                                                                <xsl:text>99</xsl:text>
                                                                            </xsl:otherwise>
                                                                        </xsl:choose>
                                                                        <xsl:text>}</xsl:text>
                                                                    </xsl:if>
                                                                    <xsl:text>$</xsl:text>
                                                                    <xsl:text>'))</xsl:text>
                                                                </xsl:if>
                                                                <xsl:text>))</xsl:text>
                                                                <xsl:if test="position() != last()">
                                                                    <xsl:text> or </xsl:text>
                                                                </xsl:if>
                                                            </xsl:for-each>
                                                        </xsl:variable>
                                                        <xsl:variable name="pqerr2">
                                                            <xsl:call-template name="getMessage">
                                                                <xsl:with-param name="key" select="'elmShall'"/>
                                                                <xsl:with-param name="p1" select="$itemlabel"/>
                                                                <xsl:with-param name="p2" select="'value'"/>
                                                            </xsl:call-template>
                                                            <xsl:for-each select="property[@minInclude or @maxInclude or @fractionDigits]">
                                                                <xsl:if test="@minInclude or @maxInclude">
                                                                    <xsl:call-template name="getMessage">
                                                                        <xsl:with-param name="key" select="'beRange'"/>
                                                                        <xsl:with-param name="p1" select="concat(@minInclude, '')"/>
                                                                        <xsl:with-param name="p2" select="concat(@maxInclude, '')"/>
                                                                    </xsl:call-template>
                                                                    <xsl:text> </xsl:text>
                                                                    <xsl:if test="@fractionDigits">
                                                                        <xsl:call-template name="getMessage">
                                                                            <xsl:with-param name="key" select="'andWord'"/>
                                                                        </xsl:call-template>
                                                                        <xsl:text> </xsl:text>
                                                                    </xsl:if>
                                                                </xsl:if>
                                                                <xsl:if test="string-length(@fractionDigits) &gt; 0">
                                                                    <xsl:variable name="theFractionDigits" select="replace(@fractionDigits, '!', '')"/>
                                                                    <xsl:variable name="exact" select="contains(@fractionDigits, '!')"/>
                                                                    <xsl:call-template name="getMessage">
                                                                        <xsl:with-param name="key">
                                                                            <xsl:choose>
                                                                                <xsl:when test="$exact">
                                                                                    <xsl:value-of select="'fracDigitsExact'"/>
                                                                                </xsl:when>
                                                                                <xsl:otherwise>
                                                                                    <xsl:value-of select="'fracDigitsMin'"/>
                                                                                </xsl:otherwise>
                                                                            </xsl:choose>
                                                                        </xsl:with-param>
                                                                        <xsl:with-param name="p1" select="$theFractionDigits"/>
                                                                    </xsl:call-template>
                                                                </xsl:if>
                                                                <xsl:if test="position() != last()">
                                                                    <xsl:text> </xsl:text>
                                                                    <xsl:call-template name="getMessage">
                                                                        <xsl:with-param name="key" select="'orWord'"/>
                                                                    </xsl:call-template>
                                                                    <xsl:text> </xsl:text>
                                                                </xsl:if>
                                                            </xsl:for-each>
                                                        </xsl:variable>
                                                        <xsl:if test="string-length($pqexpr2)&gt;0">
                                                            <assert role="warning" see="{$seethisthingurl}" test="{$pqexpr2}">
                                                                <xsl:value-of select="$pqerr2"/>
                                                            </assert>
                                                        </xsl:if>
                                                    </xsl:if>
                                                    <xsl:if test="$switchCreateDatatypeChecks=true()">
                                                        <!-- check PQ / INT properties -->
                                                        <xsl:if test="$isSupportedDatatype = 'PQ' or $isSupportedDatatype = 'INT'">
                                                            <assert role="error" see="{$seethisthingurl}" test="not(@value) or matches(@value, '{if ($isSupportedDatatype = 'INT') then $INTdigits else $REALdigits}')">
                                                                <xsl:call-template name="getMessage">
                                                                    <xsl:with-param name="key" select="'attribNotAValidNumber'"/>
                                                                    <xsl:with-param name="p1" select="$itemlabel"/>
                                                                    <xsl:with-param name="p2" select="$isSupportedDatatype"/>
                                                                </xsl:call-template>
                                                                <value-of select="@value"/>
                                                            </assert>
                                                        </xsl:if>
                                                        
                                                        <!-- check IVL_PQ properties ... should be done by the corresponding data type flavor schematrons -->
                                                        <xsl:if test="$isSupportedDatatype = 'IVL_PQ'">
                                                            <assert role="error" see="{$seethisthingurl}" test="not({$projectDefaultElementPrefix}low/@value) or matches(string({$projectDefaultElementPrefix}low/@value), '{$REALdigits}')">
                                                                <xsl:call-template name="getMessage">
                                                                    <xsl:with-param name="key" select="'attribNotAValidPQ'"/>
                                                                    <xsl:with-param name="p1" select="$itemlabel"/>
                                                                    <xsl:with-param name="p2" select="'value/low'"/>
                                                                </xsl:call-template>
                                                                <value-of select="{$projectDefaultElementPrefix}low/@value"/>
                                                            </assert>
                                                            <assert role="error" see="{$seethisthingurl}" test="not({$projectDefaultElementPrefix}high/@value) or matches(string({$projectDefaultElementPrefix}high/@value), '{$REALdigits}')">
                                                                <xsl:call-template name="getMessage">
                                                                    <xsl:with-param name="key" select="'attribNotAValidPQ'"/>
                                                                    <xsl:with-param name="p1" select="$itemlabel"/>
                                                                    <xsl:with-param name="p2" select="'value/high'"/>
                                                                </xsl:call-template>
                                                                <value-of select="{$projectDefaultElementPrefix}high/@value"/>
                                                            </assert>
                                                            <assert role="error" see="{$seethisthingurl}" test="not({$projectDefaultElementPrefix}center/@value) or matches(string({$projectDefaultElementPrefix}center/@value), '{$REALdigits}')">
                                                                <xsl:call-template name="getMessage">
                                                                    <xsl:with-param name="key" select="'attribNotAValidPQ'"/>
                                                                    <xsl:with-param name="p1" select="$itemlabel"/>
                                                                    <xsl:with-param name="p2" select="'value/center'"/>
                                                                </xsl:call-template>
                                                                <value-of select="{$projectDefaultElementPrefix}center/@value"/>
                                                            </assert>
                                                        </xsl:if>
                                                        
                                                        <!-- test for valid UCUM units for data type PQ -->
                                                        <xsl:if test="$isSupportedDatatype = 'PQ'">
                                                            <xsl:variable name="UCUMSetFileObject" select="concat($theRuntimeRelativeIncludeDir, 'voc-UCUM.xml')"/>
                                                            <let name="theUnit" value="@unit"/>
                                                            <let name="UCUMtest" value="doc('{$UCUMSetFileObject}')/*/ucum[@unit=$theUnit]/@message"/>
                                                            
                                                            <!-- @value SHALL contain a valid UCUM unit -->
                                                            <assert role="warning" see="{$seethisthingurl}" test="$UCUMtest='OK' or string-length($UCUMtest)=0">
                                                                <xsl:call-template name="getMessage">
                                                                    <xsl:with-param name="key" select="'attribNotAValidUCUMUnit'"/>
                                                                    <xsl:with-param name="p1" select="$itemlabel"/>
                                                                </xsl:call-template>
                                                                <xsl:text>(</xsl:text>
                                                                <value-of select="$UCUMtest"/>
                                                                <xsl:text>).</xsl:text>
                                                            </assert>
                                                        </xsl:if>
                                                    </xsl:if>
                                                </xsl:if>
                                                
                                                <!-- then do vocabulary of an element
                                                     ============================
                                                 -->
                                                <xsl:if test="count(vocabulary[@code | @codeSystem | @valueSet]) gt 0">
                                                    <!-- 
                                                        handle vocabulary
                                                        @code and @codeSystem
                                                        
                                                        datatypes CS CV CE CD CO
                                                        
                                                        examples:
                                                        
                                                        <x datatype="CE">
                                                          <vocabulary code="Gravidity" codeSystem="2.16.840.1.113883.2.4.4.13.15"/>
                                                          <vocabulary code="11996-6" codeSystem="2.16.840.1.113883.6.1"/>
                                                        </x>
                                                        @code shall be Gravidity and @codeSystem shall be 2.16.840.1.113883.2.4.4.13.15
                                                        -or-
                                                        @code shall be 11996-6 and @codeSystem shall be 2.16.840.1.113883.6.1
                                                        
                                                        <x datatype="CV">
                                                          <vocabulary code="123"/>
                                                          <vocabulary code="243"/>
                                                        </x>
                                                        @code shall be 123 or 243
                                                        
                                                        <x datatype="CE">
                                                          <vocabulary codeSystem="2.16.840.1.113883.6.1"/>
                                                        </x>
                                                        @codesystem shall be 2.16.840.1.113883.6.1
                                                        
                                                    -->
                                                    <!-- 
                                                         @valueSet
                                                         
                                                         examples:
                                                         CONF-ex2:	A code element SHALL be present where the value of @code is selected from Value Set 2.16.840.1.113883.19.3 LoincDocumentTypeCode DYNAMIC.
                                                         CONF-ex3:	A code element SHALL be present where the value of @code is selected from Value Set 2.16.840.1.113883.19.3 LoincDocumentTypeCode STATIC 20061017.
                                                         
                                                         DYNAMIC assumed (as of now), means most recent version of the value set
                                                         
                                                     -->
                                                    <xsl:variable name="vsdatatype" select="@datatype"/>
                                                    <xsl:variable name="vsdatatypeType" as="xs:string?">
                                                        <xsl:choose>
                                                            <xsl:when test="$rc/ancestor-or-self::*/@templateformat">
                                                                <xsl:value-of select="($rc/ancestor-or-self::*/@templateformat)[1]"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:value-of select="local:getTemplateFormat($rc/ancestor-or-self::template[1])"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </xsl:variable>
                                                    
                                                    <!-- 
                                                        create expression for one or multiple codes and/or codeSystems given
                                                        
                                                        (C)
                                                        (C and S)
                                                        (C or C)
                                                        (C and S) or (C and S)
                                                        etc
                                                    -->
                                                    <xsl:variable name="vsexpr">
                                                        <vsx xmlns="">
                                                            <xsl:for-each select="vocabulary[@valueSet]">
                                                                <xsl:variable name="xvsref" select="@valueSet"/>
                                                                <xsl:variable name="xvsflex" select="if (@flexibility) then (@flexibility) else ('dynamic')"/>
                                                                <xsl:variable name="xvs" as="element()*">
                                                                    <xsl:call-template name="getValueset">
                                                                        <xsl:with-param name="reference" select="$xvsref"/>
                                                                        <xsl:with-param name="flexibility" select="$xvsflex"/>
                                                                    </xsl:call-template>
                                                                </xsl:variable>
                                                                <xsl:variable name="xvsid" select="$xvs[1]/@id"/>
                                                                <xsl:variable name="xvsdn" select="$xvs[1]/@displayName"/>
                                                                <xsl:choose>
                                                                    <xsl:when test="empty($xvsid) or $xvsid=''">
                                                                        <xsl:call-template name="logMessage">
                                                                            <xsl:with-param name="level" select="$logERROR"/>
                                                                            <xsl:with-param name="msg">
                                                                                <xsl:text>+++ value set skipped for use in schematron because the value set contents are missing - </xsl:text>
                                                                                <xsl:text>value set </xsl:text>
                                                                                <xsl:value-of select="$xvsref"/>
                                                                                <xsl:text>: </xsl:text>
                                                                                <xsl:value-of select="$xvsflex"/>
                                                                                <xsl:text> in rule </xsl:text>
                                                                                <xsl:value-of select="ancestor::template/@name"/>
                                                                                <xsl:text>: </xsl:text>
                                                                                <xsl:value-of select="ancestor::template/@effectiveDate"/>
                                                                                <xsl:text> (context=</xsl:text>
                                                                                <xsl:value-of select="$currentContext"/>
                                                                                <xsl:text>)</xsl:text>
                                                                            </xsl:with-param>
                                                                        </xsl:call-template>
                                                                    </xsl:when>
                                                                    <xsl:when test="$xvs[1]/conceptList/(include|exclude)">
                                                                        <xsl:call-template name="logMessage">
                                                                            <xsl:with-param name="level" select="$logERROR"/>
                                                                            <xsl:with-param name="msg">
                                                                                <xsl:text>+++ value set skipped for use in schematron because intentional value sets are not yet implemented for schematron - </xsl:text>
                                                                                <xsl:text>value set </xsl:text>
                                                                                <xsl:value-of select="$xvsref"/>
                                                                                <xsl:text>: </xsl:text>
                                                                                <xsl:value-of select="$xvsflex"/>
                                                                                <xsl:text> in rule </xsl:text>
                                                                                <xsl:value-of select="ancestor::template/@name"/>
                                                                                <xsl:text>: </xsl:text>
                                                                                <xsl:value-of select="ancestor::template/@effectiveDate"/>
                                                                                <xsl:text> (context=</xsl:text>
                                                                                <xsl:value-of select="$currentContext"/>
                                                                                <xsl:text>)</xsl:text>
                                                                            </xsl:with-param>
                                                                        </xsl:call-template>
                                                                        <!-- signal that there is an intentional value set definition -->
                                                                        <containsIntentionalValueSets/>
                                                                    </xsl:when>
                                                                    <xsl:when test="$vsdatatype='CS' and not($xvs[1]/conceptList/concept)">
                                                                        <xsl:call-template name="logMessage">
                                                                            <xsl:with-param name="level" select="$logWARN"/>
                                                                            <xsl:with-param name="msg">
                                                                                <xsl:text>+++ Value set ref='</xsl:text>
                                                                                <xsl:value-of select="$xvsref"/>
                                                                                <xsl:text>' flexibility='</xsl:text>
                                                                                <xsl:value-of select="$xvsflex"/>
                                                                                <xsl:text>' </xsl:text>
                                                                                <xsl:if test="$xvsdn">
                                                                                    <xsl:text> displayName='</xsl:text>
                                                                                    <xsl:value-of select="$xvsdn"/>
                                                                                    <xsl:text>' </xsl:text>
                                                                                </xsl:if>
                                                                                <xsl:text>skipped for use in schematron as it binds to datatype CS, but has no concepts - in rule </xsl:text>
                                                                                <xsl:value-of select="ancestor::template/@name"/>
                                                                                <xsl:text>: </xsl:text>
                                                                                <xsl:value-of select="ancestor::template/@effectiveDate"/>
                                                                                <xsl:text> (context=</xsl:text>
                                                                                <xsl:value-of select="$currentContext"/>
                                                                                <xsl:text>)</xsl:text>
                                                                            </xsl:with-param>
                                                                        </xsl:call-template>
                                                                    </xsl:when>
                                                                    <xsl:otherwise>
                                                                        <xsl:variable name="valueSetFileObject">
                                                                            <xsl:choose>
                                                                                <xsl:when test="$xvsflex='dynamic' and $bindingBehaviorValueSets='preserve'">
                                                                                    <!-- generate URL as location for truly dynamic value set binding -->
                                                                                    <xsl:value-of select="concat($bindingBehaviorValueSetsURL,'&amp;id=',$xvsid,'&amp;effectiveDate=dynamic')"/>
                                                                                </xsl:when>
                                                                                <xsl:otherwise>
                                                                                    <xsl:value-of select="concat($theRuntimeRelativeIncludeDir, local:doHtmlName('VS', $xvsid, $xvsflex, '.xml', 'true'))"/>
                                                                                </xsl:otherwise>
                                                                            </xsl:choose>
                                                                        </xsl:variable>
                                                                        <item>
                                                                            <xsl:attribute name="vs" select="$xvsref"/>
                                                                            <xsl:attribute name="fl" select="$xvsflex"/>
                                                                            <xsl:attribute name="dp" select="$xvsdn"/>
            
                                                                            <!-- dn will check will return boolean true/false base on whether or not a matching 
                                                                                conceptList/concept or completeCodeSystem could be found in the referenced valueSet file -->
                                                                            <xsl:attribute name="dn">
                                                                                <xsl:text>exists(doc('</xsl:text>
                                                                                <xsl:value-of select="$valueSetFileObject"/>
                                                                                <xsl:text>')//valueSet[1]</xsl:text>
                                                                                <xsl:choose>
                                                                                    <xsl:when test="$vsdatatype='CS'">
                                                                                        <!-- If CS we do not have a codeSystem. Can check code against conceptList, but cannot check codeSystem against completeCodeSystem -->
                                                                                        <xsl:text>/conceptList/concept[@code = $theCode] or completeCodeSystem</xsl:text>
                                                                                    </xsl:when>
                                                                                    <xsl:otherwise>
                                                                                        <!-- If not CS, but no datatype given or any other (assumed coded) datatype, we should find a matching conceptList/code or completeCodeSystem -->
                                                                                        <xsl:text>[</xsl:text>
                                                                                        <xsl:if test="$xvs[1]/conceptList/concept">
                                                                                            <xsl:text>conceptList/concept[@code = $theCode][@codeSystem = $theCodeSystem][not(@codeSystemVersion) or @codeSystemVersion=$theCodeSystemVersion]</xsl:text>
                                                                                        </xsl:if>
                                                                                        <xsl:if test="$xvs[1]/conceptList/include">
                                                                                            <xsl:if test="$xvs[1]/conceptList/concept">
                                                                                                <xsl:text> | </xsl:text>
                                                                                            </xsl:if>
                                                                                            <xsl:text>conceptList/include[@codeSystem = $theCodeSystem][not(@codeSystemVersion) or @codeSystemVersion=$theCodeSystemVersion]</xsl:text>
                                                                                        </xsl:if>
                                                                                        <xsl:if test="$xvs[1]/completeCodeSystem">
                                                                                            <xsl:if test="$xvs[1]/conceptList/concept | $xvs[1]/conceptList/include">
                                                                                                <xsl:text> | </xsl:text>
                                                                                            </xsl:if>
                                                                                            <xsl:text>completeCodeSystem[@codeSystem=$theCodeSystem][not(@codeSystemVersion) or @codeSystemVersion=$theCodeSystemVersion]</xsl:text>
                                                                                        </xsl:if>
                                                                                        <xsl:text>]</xsl:text>
                                                                                    </xsl:otherwise>
                                                                                </xsl:choose>
                                                                                <xsl:text>)</xsl:text>
                                                                            </xsl:attribute>
                                                                            <xsl:attribute name="dn-human">
                                                                                <xsl:text>with a code from value set </xsl:text>
                                                                                <xsl:value-of select="$xvsid"/>
                                                                                <xsl:text> </xsl:text>
                                                                                <xsl:value-of select="$xvsdn"/>
                                                                            </xsl:attribute>
                                                                            <xsl:if test="$xvs[1]//exception[@code][@codeSystem = $theNullFlavorCodeSystem]">
                                                                                <xsl:attribute name="nf">
                                                                                    <xsl:text>exists(doc('</xsl:text>
                                                                                    <xsl:value-of select="$valueSetFileObject"/>
                                                                                    <xsl:text>')//valueSet[1]</xsl:text>
                                                                                    <xsl:text>/conceptList/exception[@code = $theNullFlavor][@codeSystem = '</xsl:text>
                                                                                    <xsl:value-of select="$theNullFlavorCodeSystem"/>
                                                                                    <xsl:text>']</xsl:text>
                                                                                    <xsl:text>)</xsl:text>
                                                                                </xsl:attribute>
                                                                            </xsl:if>
                                                                        </item>
                                                                    </xsl:otherwise>
                                                                </xsl:choose>
                                                            </xsl:for-each>
                                                        </vsx>
                                                    </xsl:variable>
                                                    <xsl:variable name="cdexpr">
                                                        <xsl:for-each select="vocabulary[@code or @codeSystem]">
                                                            <xsl:text>(</xsl:text>
                                                            <xsl:if test="@code">
                                                                <xsl:text>@code='</xsl:text>
                                                                <xsl:value-of select="@code"/>
                                                                <xsl:text>'</xsl:text>
                                                            </xsl:if>
                                                            <xsl:if test="@code and @codeSystem">
                                                                <xsl:text> and </xsl:text>
                                                            </xsl:if>
                                                            <xsl:if test="@codeSystem">
                                                                <xsl:text>@codeSystem='</xsl:text>
                                                                <xsl:value-of select="@codeSystem"/>
                                                                <xsl:text>'</xsl:text>
                                                            </xsl:if>
                                                            <!-- check displayName/codeSystemName, there is already a @code or @codeSystem check so use AND -->
                                                            <xsl:if test="@displayName">
                                                                <xsl:text> and @displayName='</xsl:text>
                                                                <xsl:value-of select="replace(@displayName,'''','''''')"/>
                                                                <xsl:text>'</xsl:text>
                                                            </xsl:if>
                                                            <xsl:if test="@codeSystemName">
                                                                <xsl:text> and @codeSystemName='</xsl:text>
                                                                <xsl:value-of select="replace(@codeSystemName,'''','''''')"/>
                                                                <xsl:text>'</xsl:text>
                                                            </xsl:if>
                                                            <xsl:text>)</xsl:text>
                                                            <xsl:if test="position() != last()">
                                                                <xsl:text> or </xsl:text>
                                                            </xsl:if>
                                                        </xsl:for-each>
                                                        <xsl:if test="vocabulary[@code or @codeSystem] and $vsexpr/*/*[@vs]">
                                                            <xsl:text> or </xsl:text>
                                                        </xsl:if>
                                                        <xsl:for-each select="$vsexpr/*/*[@dn]">
                                                            <xsl:value-of select="@dn"/>
                                                            <xsl:if test="position() != last()">
                                                                <xsl:text> or </xsl:text>
                                                            </xsl:if>
                                                        </xsl:for-each>
                                                    </xsl:variable>
                                                    <xsl:variable name="cdobj">
                                                        <xsl:choose>
                                                            <xsl:when test="count(vocabulary[@code and @codeSystem])&gt;0">
                                                                <xsl:text>@code/@codeSystem</xsl:text>
                                                            </xsl:when>
                                                            <xsl:when test="count(vocabulary[@code])&gt;0">
                                                                <xsl:text>@code</xsl:text>
                                                            </xsl:when>
                                                            <xsl:when test="count(vocabulary[@codeSystem])&gt;0">
                                                                <xsl:text>@codeSystem</xsl:text>
                                                            </xsl:when>
                                                        </xsl:choose>
                                                    </xsl:variable>
                                                    <xsl:variable name="vserr">
                                                        <xsl:for-each select="$vsexpr/*/*[@vs]">
                                                            <xsl:value-of select="@vs"/>
                                                            <xsl:if test="string-length(@dp)&gt;0 and (@dp != @vs)">
                                                                <xsl:text> </xsl:text>
                                                                <xsl:value-of select="@dp"/>
                                                            </xsl:if>
                                                            <xsl:text> (</xsl:text>
                                                            <xsl:choose>
                                                                <xsl:when test="matches(@fl,'^\d{4}')">
                                                                    <xsl:value-of select="@fl"/>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <xsl:call-template name="getMessage">
                                                                        <xsl:with-param name="key" select="'associationDYNAMIC'"/>
                                                                    </xsl:call-template>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                            <xsl:text>)</xsl:text>
                                                            <xsl:if test="position() != last()">
                                                                <xsl:text> </xsl:text>
                                                                <xsl:call-template name="getMessage">
                                                                    <xsl:with-param name="key" select="'orWord'"/>
                                                                </xsl:call-template>
                                                                <xsl:text> </xsl:text>
                                                            </xsl:if>
                                                        </xsl:for-each>
                                                    </xsl:variable>
                                                    <xsl:variable name="cderr">
                                                        <xsl:for-each select="vocabulary[@code or @codeSystem]">
                                                            <xsl:choose>
                                                                <xsl:when test="@code and @codeSystem">
                                                                    <xsl:text>code '</xsl:text>
                                                                    <xsl:value-of select="@code"/>
                                                                    <xsl:text>' codeSystem '</xsl:text>
                                                                    <xsl:value-of select="@codeSystem"/>
                                                                    <xsl:text>'</xsl:text>
                                                                </xsl:when>
                                                                <xsl:when test="@code">
                                                                    <xsl:text>code '</xsl:text>
                                                                    <xsl:value-of select="@code"/>
                                                                    <xsl:text>'</xsl:text>
                                                                </xsl:when>
                                                                <xsl:when test="@codeSystem">
                                                                    <xsl:text>codeSystem '</xsl:text>
                                                                    <xsl:value-of select="@codeSystem"/>
                                                                    <xsl:text>'</xsl:text>
                                                                </xsl:when>
                                                            </xsl:choose>
                                                            <xsl:if test="@displayName">
                                                                <xsl:text> displayName='</xsl:text>
                                                                <xsl:value-of select="replace(@displayName,'''','''''')"/>
                                                                <xsl:text>'</xsl:text>
                                                            </xsl:if>
                                                            <xsl:if test="@codeSystemName">
                                                                <xsl:text> codeSystemName='</xsl:text>
                                                                <xsl:value-of select="replace(@codeSystemName,'''','''''')"/>
                                                                <xsl:text>'</xsl:text>
                                                            </xsl:if>
                                                            <xsl:if test="@codeSystemVersion">
                                                                <xsl:text> codeSystemVersion='</xsl:text>
                                                                <xsl:value-of select="replace(@codeSystemVersion,'''','''''')"/>
                                                                <xsl:text>'</xsl:text>
                                                            </xsl:if>
                                                            <xsl:if test="position() != last()">
                                                                <xsl:text> </xsl:text>
                                                                <xsl:call-template name="getMessage">
                                                                    <xsl:with-param name="key" select="'orWord'"/>
                                                                </xsl:call-template>
                                                                <xsl:text> </xsl:text>
                                                            </xsl:if>
                                                        </xsl:for-each>
                                                        <xsl:if test="vocabulary[@code or @codeSystem] and $vsexpr/*/*[@vs]">
                                                            <xsl:text> </xsl:text>
                                                            <xsl:call-template name="getMessage">
                                                                <xsl:with-param name="key" select="'orWord'"/>
                                                            </xsl:call-template>
                                                            <xsl:text> </xsl:text>
                                                        </xsl:if>
                                                        <xsl:copy-of select="$vserr"/>
                                                    </xsl:variable>
                                                    
                                                    <!-- prepare to handle explicit exceptions (nullFlavors for now) within value set binding -->
                                                    <xsl:variable name="explicitNulls">
                                                        <xsl:text>(</xsl:text>
                                                        <xsl:variable name="nullsInValueSet" as="attribute()*">
                                                            <xsl:for-each select="attribute[@name='nullFlavor'][not(@prohibited='true')]/vocabulary[@valueSet]">
                                                                <xsl:variable name="xvsref" select="@valueSet"/>
                                                                <xsl:variable name="xvsflex" select="if (@flexibility) then (@flexibility) else ('dynamic')"/>
                                                                <xsl:variable name="xvs">
                                                                    <xsl:call-template name="getValueset">
                                                                        <xsl:with-param name="reference" select="$xvsref"/>
                                                                        <xsl:with-param name="flexibility" select="$xvsflex"/>
                                                                    </xsl:call-template>
                                                                </xsl:variable>
                                                                <xsl:copy-of select="$xvs/valueSet//*[@codeSystem=$theNullFlavorCodeSystem]/@code"/>
                                                            </xsl:for-each>
                                                        </xsl:variable>
                                                        <xsl:for-each select="
                                                            vocabulary[@valueSet]/exception[string-length(@code)&gt;0][@codeSystem=$theNullFlavorCodeSystem]/@code | 
                                                            attribute[@nullFlavor][not(@prohibited='true')]/@nullFlavor | attribute[@name='nullFlavor'][not(@prohibited='true')]/@value | 
                                                            attribute[@name='nullFlavor'][not(@prohibited='true')]/vocabulary[string-length(@code)&gt;0][not(@codeSystem) or @codeSystem=$theNullFlavorCodeSystem]/@code | 
                                                            $nullsInValueSet">
                                                            <xsl:value-of select="concat('''',string-join(tokenize(.,'\|'),''','''),'''')"/>
                                                            <xsl:if test="position()!=last()">
                                                                <xsl:text>,</xsl:text>
                                                            </xsl:if>
                                                        </xsl:for-each>
                                                        <xsl:text>)</xsl:text>
                                                    </xsl:variable>
                                                    
                                                    <!-- Need to check whether or not we have something to check. If we don't we get an illegal assert/@test. This happens when e.g. 
                                                        there's only a valueSet that either cannot be found or contains completeCodeSystem while the datatype is CS -->
                                                    <xsl:if test="string-length($cdexpr) &gt; 0 and not($vsexpr//containsIntentionalValueSets)">
                                                        <xsl:if test="vocabulary[@valueSet]">
                                                            <let name="theCode" value="@code"/>
                                                            <let name="theCodeSystem" value="@codeSystem"/>
                                                            <let name="theCodeSystemVersion" value="@codeSystemVersion"/>
                                                        </xsl:if>
                                                        
                                                        <!-- With an SC there is no requirement in the datatype to code it, hence we cannot just assume @nullFlavor or @code
                                                            Note that this also means you need an explicit assert in your specification if you *need* coded SC, e.g.
                                                            <assert test="@nullFlavor or @code"/>
                                                        -->
                                                        <xsl:variable name="scOrOther">
                                                            <xsl:choose>
                                                                <xsl:when test="$vsdatatype='SC' or $supportedDatatypes//*[@type = $vsdatatypeType][@name = $vsdatatype][@isFlavorOf='SC']">@nullFlavor or not(@code)</xsl:when>
                                                                <xsl:otherwise>@nullFlavor</xsl:otherwise>
                                                            </xsl:choose>
                                                        </xsl:variable>
                                                        <assert role="error" see="{$seethisthingurl}" test="{$scOrOther} or {$cdexpr}">
                                                            <xsl:call-template name="getMessage">
                                                                <xsl:with-param name="key" select="'attribValue2'"/>
                                                                <xsl:with-param name="p1" select="$itemlabel"/>
                                                                <xsl:with-param name="p2" select="$cderr"/>
                                                                <!--
                                                                <xsl:with-param name="key" select="'attribCode'"/>
                                                                <xsl:with-param name="p1" select="$itemlabel"/>
                                                                <xsl:with-param name="p2" select="'@code'"/>
                                                                <xsl:with-param name="p3" select="vocabulary/@valueSet"/>
                                                                -->
                                                            </xsl:call-template>
                                                        </assert>
                                                    </xsl:if>
                                                    <xsl:choose>
                                                        <xsl:when test="$vsexpr/*/*[@nf]">
                                                            <let name="theNullFlavor" value="@nullFlavor"/>
                                                            <let name="validNullFlavorsFound">
                                                                <xsl:attribute name="value">
                                                                    <xsl:for-each select="$vsexpr/*/*[@nf]">
                                                                        <xsl:value-of select="@nf"/>
                                                                        <xsl:if test="position() != last()">
                                                                            <xsl:text> or </xsl:text>
                                                                        </xsl:if>
                                                                    </xsl:for-each>
                                                                    <xsl:if test="not($vsexpr/*/*[@nf])">
                                                                        <xsl:text>()</xsl:text>
                                                                    </xsl:if>
                                                                </xsl:attribute>
                                                            </let>
                                                            <assert role="error" see="{$seethisthingurl}" test="not(@nullFlavor) or $validNullFlavorsFound{if ($explicitNulls!='()') then (concat(' or @nullFlavor=',$explicitNulls)) else ()}">
                                                                <xsl:call-template name="getMessage">
                                                                    <xsl:with-param name="key" select="'validNullCode'"/>
                                                                    <xsl:with-param name="p1" select="$itemlabel"/>
                                                                    <xsl:with-param name="p2" select="'@code'"/>
                                                                    <xsl:with-param name="p3" select="$vserr"/>
                                                                </xsl:call-template>
                                                            </assert>
                                                        </xsl:when>
                                                        <xsl:when test="$explicitNulls!='()'">
                                                            <assert role="error" see="{$seethisthingurl}" test="not(@nullFlavor) or @nullFlavor={$explicitNulls}">
                                                                <xsl:call-template name="getMessage">
                                                                    <xsl:with-param name="key" select="'validNullCode'"/>
                                                                    <xsl:with-param name="p1" select="$itemlabel"/>
                                                                    <xsl:with-param name="p2" select="'@code'"/>
                                                                    <xsl:with-param name="p3" select="$vserr"/>
                                                                </xsl:call-template>
                                                            </assert>
                                                        </xsl:when>
                                                    </xsl:choose>
                                                </xsl:if>
            
                                                <!-- then do text of an element
                                                     ==========================
                                                 -->
                                                <xsl:if test="count(text)&gt;0">
                                                    <xsl:variable name="elmcntexpr">
                                                        <xsl:for-each select="text">
                                                            <xsl:text>text()='</xsl:text>
                                                            <xsl:value-of select="text()"/>
                                                            <xsl:text>'</xsl:text>
                                                            <xsl:if test="position() != last()">
                                                                <xsl:text> or </xsl:text>
                                                            </xsl:if>
                                                        </xsl:for-each>
                                                    </xsl:variable>
                                                    <xsl:variable name="elmcnterr">
                                                        <xsl:for-each select="text">
                                                            <xsl:text>'</xsl:text>
                                                            <xsl:value-of select="text()"/>
                                                            <xsl:text>'</xsl:text>
                                                            <xsl:if test="position() != last()">
                                                                <xsl:text> </xsl:text>
                                                                <xsl:call-template name="getMessage">
                                                                    <xsl:with-param name="key" select="'orWord'"/>
                                                                </xsl:call-template>
                                                                <xsl:text> </xsl:text>
                                                            </xsl:if>
                                                        </xsl:for-each>
                                                    </xsl:variable>
                                                    <assert role="error" see="{$seethisthingurl}" test="{$elmcntexpr}">
                                                        <xsl:call-template name="getMessage">
                                                            <xsl:with-param name="key" select="'attribElmContent'"/>
                                                            <xsl:with-param name="p1" select="$itemlabel"/>
                                                            <xsl:with-param name="p2" select="$contextSuffix"/>
                                                            <xsl:with-param name="p3" select="$elmcnterr"/>
                                                        </xsl:call-template>
                                                    </assert>
                                                </xsl:if>
            
                                                <!-- then do all attributes of an element
                                                     ====================================
                                                 -->
                                                <xsl:variable name="theattributechecks">
                                                    <xsl:apply-templates select="$rc/attribute" mode="GEN">
                                                        <xsl:with-param name="itemlabel" select="$itemlabel"/>
                                                        <xsl:with-param name="currentContext" select="$currentContext"/>
                                                        <xsl:with-param name="uniqueId" select="$uniqueId"/>
                                                        <xsl:with-param name="seethisthingurl" select="$seethisthingurl"/>
                                                        <xsl:with-param name="contextSuffix" select="$contextSuffix"/>
                                                    </xsl:apply-templates>
                                                </xsl:variable>
                                                <xsl:for-each select="$theattributechecks/node()">
                                                    <xsl:call-template name="doCopyIntoSchematronNamespace"/>
                                                </xsl:for-each>
            
                                                <!-- then do all define variable statements
                                                     ======================================
                                                -->
            
                                                <!-- 
                                                    create lets for the definition of variables used later;
                                                    2DO remove duplicate source in SCH en TMP rules, 
                                                    create a template call doDefineVariables,
                                                    get namespaces right and be happy
                                                -->
                                                <xsl:for-each select="$rc/defineVariable|$rc/let|$rc/assert|$rc/report">
                                                    <xsl:choose>
                                                        <xsl:when test="self::defineVariable | self::let">
                                                            <xsl:apply-templates select="." mode="doTemplateRules">
                                                                <xsl:with-param name="sofar" select="$sofar"/>
                                                                <xsl:with-param name="templateFormat" select="$templateFormat"/>
                                                            </xsl:apply-templates>
                                                        </xsl:when>
                                                        <xsl:when test="self::assert | self::report">
                                                            <xsl:apply-templates select="." mode="doTemplateRules">
                                                                <xsl:with-param name="seethisthingurl" select="$seethisthingurl"/>
                                                                <xsl:with-param name="itemlabel" select="$itemlabel"/>
                                                                <xsl:with-param name="sofar" select="$sofar"/>
                                                                <xsl:with-param name="templateFormat" select="$templateFormat"/>
                                                            </xsl:apply-templates>
                                                        </xsl:when>
                                                    </xsl:choose>
                                                </xsl:for-each>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <!-- interspersed schematrons -->
                                                <xsl:for-each select="$rc/defineVariable|$rc/let|$rc/assert|$rc/report">
                                                    <xsl:choose>
                                                        <xsl:when test="self::defineVariable | self::let">
                                                            <xsl:apply-templates select="." mode="doTemplateRules">
                                                                <xsl:with-param name="sofar" select="$sofar"/>
                                                                <xsl:with-param name="templateFormat" select="$templateFormat"/>
                                                            </xsl:apply-templates>
                                                        </xsl:when>
                                                        <xsl:when test="self::assert | self::report">
                                                            <xsl:apply-templates select="." mode="doTemplateRules">
                                                                <xsl:with-param name="seethisthingurl" select="$seethisthingurl"/>
                                                                <xsl:with-param name="itemlabel" select="$itemlabel"/>
                                                                <xsl:with-param name="sofar" select="$sofar"/>
                                                                <xsl:with-param name="templateFormat" select="$templateFormat"/>
                                                            </xsl:apply-templates>
                                                        </xsl:when>
                                                    </xsl:choose>
                                                </xsl:for-each>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <xsl:for-each select="$rc/element|$rc/include|$rc/choice">
                                            <!-- then do all elements or includes or choices
                                                - first generate cardinality checks only
                                                ========================================
                                            -->
                                            <xsl:if test="$skipCardinalityChecks=false()">
                                                <!-- create the cardinality checks -->
                                                <xsl:variable name="thecardchecks">
                                                    <xsl:apply-templates select="." mode="cardinalitycheck">
                                                        <xsl:with-param name="itemlabel" select="$itemlabel"/>
                                                        <xsl:with-param name="currentContext" select="$currentContext"/>
                                                        <xsl:with-param name="seethisthingurl" select="$seethisthingurl"/>
                                                        <xsl:with-param name="sofar" select="$sofar"/>
                                                        <xsl:with-param name="templateFormat" select="$templateFormat"/>
                                                    </xsl:apply-templates>
                                                </xsl:variable>
                                                <xsl:for-each select="$thecardchecks/node()">
                                                    <xsl:call-template name="doCopyIntoSchematronNamespace"/>
                                                </xsl:for-each>
                                            </xsl:if>
                                            
                                            <!-- Populate in this context all schematron defineVariable|let|assert|report
                                                 that may live in (nested) included templates at top level
                                                 ========================================
                                            -->
                                            <xsl:if test="self::include">
                                                <xsl:apply-templates select="." mode="doTemplateRules">
                                                    <xsl:with-param name="itemlabel" select="$itemlabel"/>
                                                    <xsl:with-param name="currentContext" select="$currentContext"/>
                                                    <xsl:with-param name="uniqueId" select="$uniqueId"/>
                                                    <xsl:with-param name="uniqueEffectiveTime" select="$uniqueIdEffectiveTime"/>
                                                    <xsl:with-param name="isClosedAttr" select="$isClosedAttr"/>
                                                    <xsl:with-param name="checkIsClosed" select="$checkIsClosed"/>
                                                    <xsl:with-param name="nestinglevel" select="$nestinglevel"/>
                                                    <!--<xsl:with-param name="predicatetest" select="$predicatetest"/>-->
                                                    <xsl:with-param name="seethisthingurl" select="$seethisthingurl"/>
                                                    <xsl:with-param name="contextSuffix" select="$contextSuffix"/>
                                                    <xsl:with-param name="doSchematron" select="true()"/>
                                                    <xsl:with-param name="sofar" select="$sofar"/>
                                                    <xsl:with-param name="templateFormat" select="$templateFormat"/>
                                                </xsl:apply-templates>
                                            </xsl:if>
                                        </xsl:for-each>
                                        <xsl:text>
</xsl:text>
                                    </rule>
                                </xsl:variable>
                                <xsl:if test="$ruleroot/*">
                                    <xsl:text>
</xsl:text>
                                    <xsl:copy-of select="$ruleroot"/>
                                </xsl:if>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="logMessage">
                                    <xsl:with-param name="level" select="$logFATAL"/>
                                    <xsl:with-param name="terminate" select="true()"/>
                                    <xsl:with-param name="msg">
                                        <xsl:text>+++ Error: Unexpected rule to process </xsl:text>
                                        <xsl:text>Processing Rule: </xsl:text>
                                        <xsl:value-of select="$rc/name()"/>
                                        <xsl:text> -context </xsl:text>
                                        <xsl:value-of select="$currentContext"/>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- 2DO give warning? Leave as-is? -->
                    </xsl:otherwise>
                </xsl:choose>
                
                <!-- then do all elements or includes or choices
                     - now generate the rest beyond cardinalities
                     ============================================
                -->
                <xsl:for-each select="$rc/element|$rc/include|$rc/choice">
                    <!--<xsl:for-each select="$rc/(element|include|choice)[not(@mergedContent='true')]">-->
                    <!-- 
                        distinguish between
                        - elements with regular names (and process them appropriately) 
                        - elements with references to a ruleset (contains)
                        - includes with references to a ruleset (ref) 
                        @name and @contains may appear at the same time
                        @where allows to construct a @name further specified (where clause)
                    -->
                    <xsl:choose>
                        <xsl:when test="$checkIsClosed = false()">
                            <xsl:apply-templates select="." mode="doTemplateRules">
                                <xsl:with-param name="rc" select="."/>
                                <xsl:with-param name="itemlabel" select="$itemlabel"/>
                                <xsl:with-param name="currentContext" select="$currentContext"/>
                                <xsl:with-param name="uniqueId" select="$uniqueId"/>
                                <xsl:with-param name="uniqueEffectiveTime" select="$uniqueIdEffectiveTime"/>
                                <xsl:with-param name="isClosedAttr" select="$switchCreateSchematronClosed or xs:boolean(@isClosed) or $isClosedAttr"/>
                                <xsl:with-param name="checkIsClosed" select="$checkIsClosed"/>
                                <xsl:with-param name="nestinglevel" select="if (self::choice) then ($nestinglevel) else ($nestinglevel+1)"/>
                                <!--<xsl:with-param name="predicatetest" select="$predicatetest"/>-->
                                <xsl:with-param name="seethisthingurl" select="$seethisthingurl"/>
                                <xsl:with-param name="contextSuffix" select="$contextSuffix"/>
                                <xsl:with-param name="sofar" select="$sofar"/>
                                <xsl:with-param name="templateFormat" select="$templateFormat"/>
                            </xsl:apply-templates>
                        </xsl:when>
                        <xsl:when test="self::element | self::include | self::choice">
                            <xsl:apply-templates select="." mode="doTemplateRulesForClosed">
                                <xsl:with-param name="rc" select="."/>
                                <xsl:with-param name="itemlabel" select="$itemlabel"/>
                                <xsl:with-param name="currentContext" select="$currentContext"/>
                                <xsl:with-param name="uniqueId" select="$uniqueId"/>
                                <xsl:with-param name="uniqueEffectiveTime" select="$uniqueIdEffectiveTime"/>
                                <xsl:with-param name="isClosedAttr" select="$switchCreateSchematronClosed or xs:boolean(@isClosed) or $isClosedAttr"/>
                                <xsl:with-param name="checkIsClosed" select="$checkIsClosed"/>
                                <xsl:with-param name="nestinglevel" select="if (self::choice) then ($nestinglevel) else ($nestinglevel+1)"/>
                                <!--<xsl:with-param name="predicatetest" select="$predicatetest"/>-->
                                <xsl:with-param name="seethisthingurl" select="$seethisthingurl"/>
                                <xsl:with-param name="contextSuffix" select="$contextSuffix"/>
                                <xsl:with-param name="sofar" select="$sofar"/>
                                <xsl:with-param name="templateFormat" select="$templateFormat"/>
                            </xsl:apply-templates>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- Nothing to do -->
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
        <xd:param name="itemlabel">The item label we are currently at</xd:param>
        <xd:param name="currentContext"/>
        <xd:param name="uniqueId"/>
        <xd:param name="uniqueEffectiveTime"/>
        <xd:param name="isClosedAttr">Are we currently in or under @isClosed='true'</xd:param>
        <xd:param name="checkIsClosed">Are we in the cycle for checking closed logic</xd:param>
        <xd:param name="nestinglevel">The nesting level we are currently at</xd:param>
        <xd:param name="predicatetest"/>
        <xd:param name="seethisthingurl">What URL should we point a user to in case of failed assertions?</xd:param>
        <xd:param name="contextSuffix"/>
        <xd:param name="doSchematron"/>
        <xd:param name="sofar">Array of templates found so far where every array item is concat(template/@id,'-',template/@effectiveDate)</xd:param>
        <xd:param name="templateFormat"/>
    </xd:doc>
    <xsl:template match="element|include" mode="doTemplateRules">
        <xsl:param name="itemlabel"/>
        <xsl:param name="currentContext"/>
        <xsl:param name="uniqueId"/>
        <xsl:param name="uniqueEffectiveTime"/>
        <xsl:param name="isClosedAttr" as="xs:boolean"/>
        <xsl:param name="checkIsClosed" as="xs:boolean"/>
        <xsl:param name="nestinglevel"/>
        <xsl:param name="predicatetest" select="false()" as="xs:boolean"/>
        <xsl:param name="seethisthingurl"/>
        <xsl:param name="contextSuffix"/>
        <xsl:param name="doSchematron" select="false()" as="xs:boolean"/>
        <xsl:param name="sofar" as="xs:string*" required="yes"/>
        <xsl:param name="templateFormat" as="xs:string"/>
        
        <xsl:variable name="recurrents" select="string-join(for $i in 1 to count($sofar) return if ($sofar[$i] = $sofar[last()]) then 'X' else '', '')"/>
        
        <xsl:choose>
            <!-- When we are really deep, but we don't have any recursion yet, we go on until we are really deep AND have recursion -->
            <xsl:when test="$nestinglevel >= $maxNestingLevel">
                <!-- too deeply nested, signalled somewhere already, be silent here -->
            </xsl:when>
            <xsl:when test="string-length($recurrents) >= $maxRecursionLevel">
                <!-- too many recursions, signalled somewhere already, be silent here -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <!-- an element with both name and contains -->
                    <xsl:when test="@name and @contains">
                        <xsl:variable name="elemname">
                            <xsl:call-template name="getWherePathFromNodeset">
                                <xsl:with-param name="rccontent" select="."/>
                                <xsl:with-param name="sofar" select="()"/>
                                <xsl:with-param name="templateFormat" select="$templateFormat"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:call-template name="logMessage">
                            <xsl:with-param name="level" select="$logALL"/>
                            <xsl:with-param name="msg">
                                <xsl:text>CONTAINS </xsl:text>
                                <xsl:value-of select="$elemname"/>
                                <xsl:text> containing '</xsl:text>
                                <xsl:value-of select="@contains"/>
                                <xsl:text>' flexibility '</xsl:text>
                                <xsl:value-of select="@flexibility"/>
                                <xsl:text>'</xsl:text>
                            </xsl:with-param>
                        </xsl:call-template>
        
                        <!-- 
                            the included processable rules (contains) are turned into an abstract rule
                            and included by extension in the processable rules of this element
                        -->
                        <xsl:variable name="ns1">
                            <!-- create an element corresponding to the original element and process it normally -->
                            <element xmlns="">
                                <xsl:attribute name="name" select="$elemname"/>
                                <!--<xsl:copy-of select="@*"/>-->
                                <xsl:copy-of select="*"/>
                            </element>
                        </xsl:variable>
                        <xsl:variable name="newitemlabel1">
                            <xsl:call-template name="getNewItemLabel">
                                <xsl:with-param name="rc" select="$ns1"/>
                                <xsl:with-param name="default" select="$itemlabel"/>
                            </xsl:call-template>
                        </xsl:variable>
        
                        <!-- get the original content rules -->
                        <xsl:variable name="rs1">
                            <rs1 xmlns="">
                                <xsl:call-template name="doTemplateRules">
                                    <xsl:with-param name="rc" select="$ns1/node()"/>
                                    <xsl:with-param name="previousitemlabel" select="$newitemlabel1"/>
                                    <xsl:with-param name="previousContext" select="$currentContext"/>
                                    <xsl:with-param name="previousUniqueId" select="$uniqueId"/>
                                    <xsl:with-param name="previousUniqueEffectiveTime" select="$uniqueEffectiveTime"/>
                                    <xsl:with-param name="isClosedAttr" select="$isClosedAttr"/>
                                    <xsl:with-param name="nestinglevel" select="$nestinglevel"/>
                                    <xsl:with-param name="checkIsClosed" select="$checkIsClosed"/>
                                    <xsl:with-param name="sofar" select="$sofar"/>
                                    <xsl:with-param name="templateFormat" select="$templateFormat"/>
                                </xsl:call-template>
                            </rs1>
                        </xsl:variable>
        
                        <!-- lookup contained template content -->
                        <xsl:variable name="rccontent" as="element()?">
                            <xsl:call-template name="getRulesetContent">
                                <xsl:with-param name="ruleset" select="@contains"/>
                                <xsl:with-param name="flexibility" select="@flexibility"/>
                                <xsl:with-param name="previousContext" select="$currentContext"/>
                                <xsl:with-param name="sofar" select="$sofar"/>
                            </xsl:call-template>
                        </xsl:variable>
                        
                        <!-- 2DO: if available and has the template id element defined check it only don't include it -->
                        <xsl:variable name="ns2" as="element()">
                            <element xmlns="">
                                <xsl:attribute name="name" select="$elemname"/>
                                <!--<xsl:copy-of select="@*"/>-->
                                <xsl:copy-of select="$rccontent/*"/>
                            </element>
                        </xsl:variable>
                        <xsl:variable name="newitemlabel2">
                            <xsl:call-template name="getNewItemLabel">
                                <xsl:with-param name="rc" select="$rccontent"/>
                                <xsl:with-param name="default" select="$itemlabel"/>
                            </xsl:call-template>
                        </xsl:variable>
        
                        <!-- get the contained content rules -->
                        <xsl:variable name="rs2">
                            <xsl:choose>
                                <xsl:when test="$rccontent/context[@id]">
                                    <!-- if contained template has a context id don't merge it as it is triggered on its own -->
                                    <empty xmlns=""/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <rs2 xmlns="">
                                        <xsl:call-template name="doTemplateRules">
                                            <xsl:with-param name="rc" select="$ns2"/>
                                            <xsl:with-param name="previousitemlabel" select="$newitemlabel2"/>
                                            <xsl:with-param name="previousContext" select="$currentContext"/>
                                            <xsl:with-param name="previousUniqueId" select="$rccontent/@id"/>
                                            <xsl:with-param name="previousUniqueEffectiveTime" select="$rccontent/@effectiveDate"/>
                                            <xsl:with-param name="isClosedAttr" select="$isClosedAttr"/>
                                            <xsl:with-param name="nestinglevel" select="$nestinglevel"/>
                                            <xsl:with-param name="checkIsClosed" select="$checkIsClosed"/>
                                            <xsl:with-param name="sofar" select="$sofar, concat($rccontent/@id,'-',$rccontent/@effectiveDate)"/>
                                            <xsl:with-param name="templateFormat" select="$templateFormat"/>
                                        </xsl:call-template>
                                    </rs2>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
        
                        <!-- do the merger of the rules and emit them -->
                        <xsl:call-template name="mergeRulesets">
                            <xsl:with-param name="rs1" select="$rs1"/>
                            <xsl:with-param name="rs2">
                                <xsl:copy-of select="$rs2"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:when>
                    <!-- an element with a name only -->
                    <xsl:when test="@name">
                        <xsl:choose>
                            <!-- 2DO add documentation for the reason why hl7:section is treated differently -->
                            <xsl:when test="@name='hl7:section' and $predicatetest=true()">
                                <xsl:call-template name="logMessage">
                                    <xsl:with-param name="level" select="$logALL"/>
                                    <xsl:with-param name="msg">
                                        <xsl:text> NODE: </xsl:text>
                                        <xsl:value-of select="name()"/>
                                        <xsl:text> :: </xsl:text>
                                        <xsl:value-of select="@name"/>
                                        <xsl:text> e: </xsl:text>
                                        <xsl:for-each select="*/*">
                                            <xsl:value-of select="name()"/>
                                            <xsl:text> </xsl:text>
                                        </xsl:for-each>
                                    </xsl:with-param>
                                </xsl:call-template>
                                <xsl:for-each select="*/*">
                                    <xsl:choose>
                                        <xsl:when test="self::attribute">
                                            <xsl:variable name="ruleid" select="local:randomString2(.,$checkIsClosed)"/>
                                            <rule xmlns="http://purl.oclc.org/dsdl/schematron" context="{$currentContext}" id="{$ruleid}">
                                                <xsl:variable name="theattributechecks">
                                                    <xsl:apply-templates select="." mode="GEN">
                                                        <xsl:with-param name="itemlabel" select="$itemlabel"/>
                                                        <xsl:with-param name="currentContext" select="$currentContext"/>
                                                        <xsl:with-param name="uniqueId" select="$uniqueId"/>
                                                        <xsl:with-param name="seethisthingurl" select="$seethisthingurl"/>
                                                        <xsl:with-param name="contextSuffix" select="$contextSuffix"/>
                                                    </xsl:apply-templates>
                                                </xsl:variable>
                                                <xsl:for-each select="$theattributechecks/node()">
                                                    <xsl:call-template name="doCopyIntoSchematronNamespace"/>
                                                </xsl:for-each>
                                            </rule>
                                        </xsl:when>
                                        <xsl:when test="self::element or self::include or self::choice">
                                            <xsl:call-template name="doTemplateRules">
                                                <xsl:with-param name="rc" select="."/>
                                                <xsl:with-param name="previousitemlabel" select="$itemlabel"/>
                                                <xsl:with-param name="previousContext" select="$currentContext"/>
                                                <xsl:with-param name="previousUniqueId" select="$uniqueId"/>
                                                <xsl:with-param name="previousUniqueEffectiveTime" select="$uniqueEffectiveTime"/>
                                                <xsl:with-param name="isClosedAttr" select="$switchCreateSchematronClosed or xs:boolean(@isClosed) or $isClosedAttr"/>
                                                <xsl:with-param name="nestinglevel" select="$nestinglevel+1"/>
                                                <xsl:with-param name="checkIsClosed" select="$checkIsClosed"/>
                                                <xsl:with-param name="sofar" select="$sofar"/>
                                                <xsl:with-param name="templateFormat" select="$templateFormat"/>
                                            </xsl:call-template>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="doTemplateRules">
                                    <xsl:with-param name="rc" select="."/>
                                    <xsl:with-param name="previousitemlabel" select="$itemlabel"/>
                                    <xsl:with-param name="previousContext" select="$currentContext"/>
                                    <xsl:with-param name="previousUniqueId" select="$uniqueId"/>
                                    <xsl:with-param name="previousUniqueEffectiveTime" select="$uniqueEffectiveTime"/>
                                    <xsl:with-param name="isClosedAttr" select="$isClosedAttr"/>
                                    <xsl:with-param name="nestinglevel" select="$nestinglevel"/>
                                    <xsl:with-param name="checkIsClosed" select="$checkIsClosed"/>
                                    <xsl:with-param name="sofar" select="$sofar"/>
                                    <xsl:with-param name="templateFormat" select="$templateFormat"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <!-- an include with a ref -->
                    <xsl:when test="@ref">
                        <xsl:variable name="rccontent" as="element()?">
                            <xsl:call-template name="getRulesetContent">
                                <xsl:with-param name="ruleset" select="@ref"/>
                                <xsl:with-param name="flexibility" select="@flexibility"/>
                                <xsl:with-param name="previousContext" select="$currentContext"/>
                                <xsl:with-param name="sofar" select="$sofar"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:call-template name="logMessage">
                            <xsl:with-param name="level" select="$logDEBUG"/>
                            <xsl:with-param name="msg">
                                <xsl:text>INCLUDE (mode=doTemplateRules) '</xsl:text>
                                <xsl:value-of select="@ref"/>
                                <xsl:text>' flexibility '</xsl:text>
                                <xsl:value-of select="@flexibility"/>
                                <xsl:text>' include element count=</xsl:text>
                                <xsl:value-of select="count($rccontent/*)"/>
                                <xsl:text> doSchematron=</xsl:text>
                                <xsl:value-of select="$doSchematron"/>
                            </xsl:with-param>
                        </xsl:call-template>
                        <xsl:variable name="newitemlabel">
                            <xsl:call-template name="getNewItemLabel">
                                <xsl:with-param name="rc" select="$rccontent"/>
                                <xsl:with-param name="default" select="$itemlabel"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:if test="not($rccontent/context[@id])">
                            <xsl:call-template name="logMessage">
                                <xsl:with-param name="level" select="$logDEBUG"/>
                                <xsl:with-param name="msg">
                                    <xsl:text>PROCESSING INCLUDE ...</xsl:text>
                                </xsl:with-param>
                            </xsl:call-template>
                            <xsl:for-each select="$rccontent/(element|include|choice|defineVariable|let|assert|report)">
                                <xsl:choose>
                                    <xsl:when test="self::defineVariable | self::let">
                                        <xsl:if test="$doSchematron">
                                            <xsl:apply-templates select="." mode="doTemplateRules">
                                                <xsl:with-param name="sofar" select="$sofar, concat($rccontent/@id,'-',$rccontent/@effectiveDate)"/>
                                                <xsl:with-param name="templateFormat" select="$templateFormat"/>
                                            </xsl:apply-templates>
                                        </xsl:if>
                                    </xsl:when>
                                    <xsl:when test="self::assert | self::report">
                                        <xsl:if test="$doSchematron">
                                            <xsl:apply-templates select="." mode="doTemplateRules">
                                                <xsl:with-param name="seethisthingurl" select="$seethisthingurl"/>
                                                <xsl:with-param name="itemlabel" select="$itemlabel"/>
                                                <xsl:with-param name="sofar" select="$sofar, concat($rccontent/@id,'-',$rccontent/@effectiveDate)"/>
                                                <xsl:with-param name="templateFormat" select="$templateFormat"/>
                                            </xsl:apply-templates>
                                        </xsl:if>
                                    </xsl:when>
                                    <xsl:when test="self::include">
                                        <xsl:apply-templates select="." mode="doTemplateRules">
                                            <xsl:with-param name="itemlabel" select="$itemlabel"/>
                                            <xsl:with-param name="currentContext" select="$currentContext"/>
                                            <xsl:with-param name="uniqueId" select="$uniqueId"/>
                                            <xsl:with-param name="uniqueEffectiveTime" select="$uniqueEffectiveTime"/>
                                            <xsl:with-param name="isClosedAttr" select="$isClosedAttr"/>
                                            <xsl:with-param name="checkIsClosed" select="$checkIsClosed"/>
                                            <xsl:with-param name="nestinglevel" select="$nestinglevel + 1"/>
                                            <xsl:with-param name="predicatetest" select="$predicatetest"/>
                                            <xsl:with-param name="seethisthingurl" select="$seethisthingurl"/>
                                            <xsl:with-param name="contextSuffix" select="$contextSuffix"/>
                                            <xsl:with-param name="doSchematron" select="$doSchematron"/>
                                            <xsl:with-param name="sofar" select="$sofar, concat($rccontent/@id,'-',$rccontent/@effectiveDate)"/>
                                            <xsl:with-param name="templateFormat" select="$templateFormat"/>
                                        </xsl:apply-templates>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:if test="not($doSchematron)">
                                            <xsl:call-template name="doTemplateRules">
                                                <xsl:with-param name="rc" select="."/>
                                                <xsl:with-param name="previousitemlabel" select="$newitemlabel"/>
                                                <xsl:with-param name="previousContext" select="$currentContext"/>
                                                <xsl:with-param name="previousUniqueId" select="$rccontent/@id"/>
                                                <xsl:with-param name="previousUniqueEffectiveTime" select="$rccontent/@effectiveDate"/>
                                                <xsl:with-param name="isClosedAttr" select="$isClosedAttr"/>
                                                <xsl:with-param name="nestinglevel" select="$nestinglevel"/>
                                                <xsl:with-param name="checkIsClosed" select="$checkIsClosed"/>
                                                <xsl:with-param name="sofar" select="$sofar, concat($rccontent/@id,'-',$rccontent/@effectiveDate)"/>
                                                <xsl:with-param name="templateFormat" select="$templateFormat"/>
                                            </xsl:call-template>
                                        </xsl:if>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="logMessage">
                            <xsl:with-param name="level" select="$logERROR"/>
                            <xsl:with-param name="msg">
                                <xsl:text>+++ Element '</xsl:text>
                                <xsl:value-of select="name()"/>
                                <xsl:text>' with attributes "</xsl:text>
                                <xsl:for-each select="@*">
                                    <xsl:text>@</xsl:text>
                                    <xsl:value-of select="name()"/>
                                    <xsl:text>='</xsl:text>
                                    <xsl:value-of select="."/>
                                    <xsl:text>'</xsl:text>
                                    <xsl:if test="position()!=last()">
                                        <xsl:text> </xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                                <xsl:text>" will NOT be processed... context=</xsl:text>
                                <xsl:value-of select="$currentContext"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
        <xd:param name="itemlabel">The item label we are currently at</xd:param>
        <xd:param name="currentContext"/>
        <xd:param name="uniqueId"/>
        <xd:param name="uniqueEffectiveTime"/>
        <xd:param name="isClosedAttr">Are we currently in or under @isClosed='true'</xd:param>
        <xd:param name="checkIsClosed">Are we in the cycle for checking closed logic</xd:param>
        <xd:param name="nestinglevel">The nesting level we are currently at</xd:param>
        <xd:param name="predicatetest"/>
        <xd:param name="seethisthingurl">What URL should we point a user to in case of failed assertions?</xd:param>
        <xd:param name="contextSuffix"/>
        <xd:param name="sofar">Array of templates found so far where every array item is concat(template/@id,'-',template/@effectiveDate)</xd:param>
        <xd:param name="templateFormat"/>
    </xd:doc>
    <xsl:template match="choice" mode="doTemplateRules">
        <xsl:param name="itemlabel"/>
        <xsl:param name="currentContext"/>
        <xsl:param name="uniqueId"/>
        <xsl:param name="uniqueEffectiveTime"/>
        <xsl:param name="isClosedAttr" as="xs:boolean"/>
        <xsl:param name="checkIsClosed" as="xs:boolean"/>
        <xsl:param name="nestinglevel"/>
        <xsl:param name="predicatetest" select="false()" as="xs:boolean"/>
        <xsl:param name="seethisthingurl"/>
        <xsl:param name="contextSuffix"/>
        <xsl:param name="sofar" as="xs:string*" required="yes"/>
        <xsl:param name="templateFormat" as="xs:string"/>
        <xsl:for-each select="element|include|choice">
            <!-- cardinality already checked by another rule -->
            <xsl:apply-templates select="." mode="doTemplateRules">
                <xsl:with-param name="rc" select="."/>
                <xsl:with-param name="itemlabel" select="$itemlabel"/>
                <xsl:with-param name="currentContext" select="$currentContext"/>
                <xsl:with-param name="uniqueId" select="$uniqueId"/>
                <xsl:with-param name="uniqueEffectiveTime" select="$uniqueEffectiveTime"/>
                <xsl:with-param name="isClosedAttr" select="$switchCreateSchematronClosed or xs:boolean(@isClosed) or $isClosedAttr"/>
                <xsl:with-param name="checkIsClosed" select="$checkIsClosed"/>
                <xsl:with-param name="nestinglevel" select="if (self::choice) then ($nestinglevel) else ($nestinglevel+1)"/>
                <xsl:with-param name="predicatetest" select="$predicatetest"/>
                <xsl:with-param name="seethisthingurl" select="$seethisthingurl"/>
                <xsl:with-param name="contextSuffix" select="$contextSuffix"/>
                <xsl:with-param name="sofar" select="$sofar"/>
                <xsl:with-param name="templateFormat" select="$templateFormat"/>
            </xsl:apply-templates>
        </xsl:for-each>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
        <xd:param name="sofar">Array of templates found so far where every array item is concat(template/@id,'-',template/@effectiveDate)</xd:param>
        <xd:param name="templateFormat"/>
    </xd:doc>
    <xsl:template match="defineVariable" mode="doTemplateRules">
        <xsl:param name="sofar" as="xs:string*" required="yes"/>
        <xsl:param name="templateFormat" as="xs:string"/>
        <xsl:variable name="theCode">
            <xsl:if test="string-length(code/@code)&gt;0 or string-length(code/@codeSystem)&gt;0">
                <xsl:text>[</xsl:text>
                <xsl:value-of select="$projectDefaultElementPrefix"/>
                <xsl:text>code</xsl:text>
            </xsl:if>
            <xsl:if test="string-length(code/@code)&gt;0">
                <xsl:text>[@code='</xsl:text>
                <xsl:value-of select="code/@code"/>
                <xsl:text>']</xsl:text>
            </xsl:if>
            <xsl:if test="string-length(code/@codeSystem)&gt;0">
                <xsl:text>[@codeSystem='</xsl:text>
                <xsl:value-of select="code/@codeSystem"/>
                <xsl:text>']</xsl:text>
            </xsl:if>
            <xsl:if test="string-length(code/@code)&gt;0 or string-length(code/@codeSystem)&gt;0">
                <xsl:text>]</xsl:text>
            </xsl:if>
        </xsl:variable>
        <!-- assertion: use/@name is not empty and contains a valid xpath to a data type value, typed INT or CE or TS -->
        <xsl:variable name="rln" select="name()"/>
        <let xmlns="http://purl.oclc.org/dsdl/schematron" name="temp1_{@name}" value="{@path}{$theCode}/{use/@path}"/>
        <xsl:choose>
            <xsl:when test="use/@as='INT'">
                <let xmlns="http://purl.oclc.org/dsdl/schematron" name="{@name}" value="if ($temp1_{@name} castable as xs:integer) then ($temp1_{@name} cast as xs:integer) else false"/>
            </xsl:when>
            <xsl:when test="use/@as='CE'">
                <let xmlns="http://purl.oclc.org/dsdl/schematron" name="{@name}" value="$temp1_{@name}"/>
            </xsl:when>
            <xsl:when test="use/@as='TS.JULIAN'">
                <let xmlns="http://purl.oclc.org/dsdl/schematron" name="temp2_{@name}" value="concat(substring($temp1_{@name}, 1, 4), '-', substring($temp1_{@name}, 5, 2), '-', substring($temp1_{@name}, 7, 2))"/>
                <let xmlns="http://purl.oclc.org/dsdl/schematron" name="temp3_{@name}" value="if ($temp2_{@name} castable as xs:date) then ($temp2_{@name} cast as xs:date) else false"/>
                <!-- modified julian day, days after Nov 17, 1858 -->
                <let xmlns="http://purl.oclc.org/dsdl/schematron" name="{@name}" value="days-from-duration($temp3_{@name} - xs:date('1858-11-17'))"/>
            </xsl:when>
            <xsl:when test="use/@as='TS'">
                <let xmlns="http://purl.oclc.org/dsdl/schematron" name="{@name}" value="$temp1_{@name}"/>
            </xsl:when>
            <xsl:otherwise>
                <let xmlns="http://purl.oclc.org/dsdl/schematron" name="{@name}" value="false"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
        <xd:param name="sofar">Array of templates found so far where every array item is concat(template/@id,'-',template/@effectiveDate)</xd:param>
        <xd:param name="templateFormat"/>
    </xd:doc>
    <xsl:template match="let" mode="doTemplateRules">
        <xsl:param name="sofar" as="xs:string*" required="yes"/>
        <xsl:param name="templateFormat" as="xs:string"/>
        <xsl:variable name="rln" select="name()"/>
        <xsl:element name="{$rln}" namespace="http://purl.oclc.org/dsdl/schematron">
            <xsl:attribute name="name" select="@name"/>
            <xsl:attribute name="value" select="@value"/>
        </xsl:element>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
        <xd:param name="seethisthingurl">What URL should we point a user to in case of failed assertions?</xd:param>
        <xd:param name="itemlabel">The item label we are currently at</xd:param>
        <xd:param name="sofar">Array of templates found so far where every array item is concat(template/@id,'-',template/@effectiveDate)</xd:param>
        <xd:param name="templateFormat"/>
    </xd:doc>
    <xsl:template match="assert|report" mode="doTemplateRules">
        <xsl:param name="seethisthingurl" as="xs:string?"/>
        <xsl:param name="itemlabel" as="xs:string?"/>
        <xsl:param name="sofar" as="xs:string*" required="yes"/>
        <xsl:param name="templateFormat" as="xs:string"/>
        <xsl:variable name="rln" select="name()"/>
        <xsl:element name="{$rln}" namespace="http://purl.oclc.org/dsdl/schematron">
            <xsl:copy-of select="@flag"/>
            <xsl:copy-of select="@role"/>
            <xsl:choose>
                <xsl:when test="@see">
                    <!-- locally configured.. -->
                    <xsl:copy-of select="@see"/>
                </xsl:when>
                <xsl:when test="$seethisthingurl">
                    <!-- write default, .. -->
                    <xsl:attribute name="see" select="$seethisthingurl"/>
                </xsl:when>
            </xsl:choose>
            <xsl:copy-of select="@test"/>
            <xsl:value-of select="$itemlabel"/>
            <xsl:text>: </xsl:text>
            <xsl:for-each select="node()">
                <xsl:call-template name="doCopyIntoSchematronNamespace"/>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
        <xd:param name="itemlabel">The item label we are currently at</xd:param>
        <xd:param name="currentContext"/>
        <xd:param name="uniqueId"/>
        <xd:param name="uniqueEffectiveTime"/>
        <xd:param name="isClosedAttr">Are we currently in or under @isClosed='true'</xd:param>
        <xd:param name="checkIsClosed">Are we in the cycle for checking closed logic</xd:param>
        <xd:param name="nestinglevel">The nesting level we are currently at</xd:param>
        <xd:param name="predicatetest"/>
        <xd:param name="seethisthingurl">What URL should we point a user to in case of failed assertions?</xd:param>
        <xd:param name="contextSuffix"/>
        <xd:param name="sofar">Array of templates found so far where every array item is concat(template/@id,'-',template/@effectiveDate)</xd:param>
        <xd:param name="templateFormat"/>
    </xd:doc>
    <xsl:template match="element|include" mode="doTemplateRulesForClosed">
        <xsl:param name="itemlabel"/>
        <xsl:param name="currentContext"/>
        <xsl:param name="uniqueId"/>
        <xsl:param name="uniqueEffectiveTime"/>
        <xsl:param name="isClosedAttr" as="xs:boolean"/>
        <xsl:param name="checkIsClosed" as="xs:boolean"/>
        <xsl:param name="nestinglevel"/>
        <xsl:param name="predicatetest" select="false()" as="xs:boolean"/>
        <xsl:param name="seethisthingurl"/>
        <xsl:param name="contextSuffix"/>
        <xsl:param name="sofar" as="xs:string*" required="yes"/>
        <xsl:param name="templateFormat" as="xs:string"/>
        
        <xsl:variable name="recurrents" select="string-join(for $i in 1 to count($sofar) return if ($sofar[$i] = $sofar[last()]) then 'X' else '', '')"/>
        
        <xsl:choose>
            <!-- When we are really deep, but we don't have any recursion yet, we go on until we are really deep AND have recursion -->
            <xsl:when test="$nestinglevel >= $maxNestingLevel">
                <!-- too deeply nested, signalled somewhere already, be silent here -->
            </xsl:when>
            <xsl:when test="string-length($recurrents) >= $maxRecursionLevel">
                <!-- too many recursions, signalled somewhere already, be silent here -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <!-- an element with both name and contains -->
                    <xsl:when test="@name and @contains">
                        <!-- 
                            Merge rc with @contains before continuing, or leave rc as-is
                        -->
                        <!-- lookup contained template content -->
                        <xsl:variable name="rccontent" as="element()?">
                            <xsl:call-template name="getRulesetContent">
                                <xsl:with-param name="ruleset" select="@contains"/>
                                <xsl:with-param name="flexibility" select="@flexibility"/>
                                <xsl:with-param name="previousContext" select="$currentContext"/>
                                <xsl:with-param name="sofar" select="$sofar"/>
                            </xsl:call-template>
                        </xsl:variable>
                        
                        <xsl:variable name="rcmerged" as="element()">
                            <!-- merge stuff -->
                            <xsl:apply-templates select="." mode="mergeTemplates">
                                <xsl:with-param name="containedTemplate" select="$rccontent"/>
                                <xsl:with-param name="currentItemLabel" select="$itemlabel"/>
                                <xsl:with-param name="sofar" select="$sofar"/>
                                <xsl:with-param name="templateFormat" select="$templateFormat"/>
                            </xsl:apply-templates>
                        </xsl:variable>
                        <xsl:call-template name="doTemplateRules">
                            <xsl:with-param name="rc" select="$rcmerged"/>
                            <xsl:with-param name="previousitemlabel" select="$itemlabel"/>
                            <xsl:with-param name="previousContext" select="$currentContext"/>
                            <xsl:with-param name="previousUniqueId" select="$uniqueId"/>
                            <xsl:with-param name="previousUniqueEffectiveTime" select="$uniqueEffectiveTime"/>
                            <xsl:with-param name="isClosedAttr" select="$isClosedAttr"/>
                            <xsl:with-param name="nestinglevel" select="$nestinglevel"/>
                            <xsl:with-param name="checkIsClosed" select="$checkIsClosed"/>
                            <xsl:with-param name="sofar" select="$sofar, concat($rccontent/@id,'-',$rccontent/@effectiveDate)"/>
                            <xsl:with-param name="templateFormat" select="$templateFormat"/>
                        </xsl:call-template>
                    </xsl:when>
                    <!-- an element with a name only -->
                    <xsl:when test="@name">
                        <xsl:if test="not(string(@conformance)='NP')">
                            <!-- ??? not for NP's -->
                        </xsl:if>
                        <xsl:call-template name="doTemplateRules">
                            <xsl:with-param name="rc" select="."/>
                            <xsl:with-param name="previousitemlabel" select="$itemlabel"/>
                            <xsl:with-param name="previousContext" select="$currentContext"/>
                            <xsl:with-param name="previousUniqueId" select="$uniqueId"/>
                            <xsl:with-param name="previousUniqueEffectiveTime" select="$uniqueEffectiveTime"/>
                            <xsl:with-param name="isClosedAttr" select="$isClosedAttr"/>
                            <xsl:with-param name="nestinglevel" select="$nestinglevel"/>
                            <xsl:with-param name="checkIsClosed" select="$checkIsClosed"/>
                            <xsl:with-param name="sofar" select="$sofar"/>
                            <xsl:with-param name="templateFormat" select="$templateFormat"/>
                        </xsl:call-template>
                    </xsl:when>
                    <!-- an include with a ref -->
                    <xsl:when test="@ref">
                        <xsl:variable name="rccontent" as="element()?">
                            <xsl:call-template name="getRulesetContent">
                                <xsl:with-param name="ruleset" select="@ref"/>
                                <xsl:with-param name="flexibility" select="@flexibility"/>
                                <xsl:with-param name="previousContext" select="$currentContext"/>
                                <xsl:with-param name="sofar" select="$sofar"/>
                            </xsl:call-template>
                        </xsl:variable>
                        
                        <xsl:call-template name="logMessage">
                            <xsl:with-param name="level" select="$logDEBUG"/>
                            <xsl:with-param name="msg">
                                <xsl:text>INCLUDE (mode=doTemplateRulesForClosed) '</xsl:text>
                                <xsl:value-of select="@ref"/>
                                <xsl:text>' flexibility '</xsl:text>
                                <xsl:value-of select="@flexibility"/>
                                <xsl:text>' include element count=</xsl:text>
                                <xsl:value-of select="count($rccontent/*)"/>
                            </xsl:with-param>
                        </xsl:call-template>
                        <xsl:variable name="newitemlabel">
                            <xsl:call-template name="getNewItemLabel">
                                <xsl:with-param name="rc" select="$rccontent"/>
                                <xsl:with-param name="default" select="$itemlabel"/>
                            </xsl:call-template>
                        </xsl:variable>
                        
                        <!--<xsl:if test="not($rccontent/context[@id])">-->
                        <xsl:call-template name="logMessage">
                            <xsl:with-param name="level" select="$logDEBUG"/>
                            <xsl:with-param name="msg">
                                <xsl:text>PROCESSING INCLUDE ...</xsl:text>
                            </xsl:with-param>
                        </xsl:call-template>
                        <xsl:for-each select="$rccontent/(element|include|choice)">
                            <xsl:call-template name="doTemplateRules">
                                <xsl:with-param name="rc" select="."/>
                                <xsl:with-param name="previousitemlabel" select="$newitemlabel"/>
                                <xsl:with-param name="previousContext" select="$currentContext"/>
                                <xsl:with-param name="previousUniqueId" select="$rccontent/@id"/>
                                <xsl:with-param name="previousUniqueEffectiveTime" select="$rccontent/@effectiveDate"/>
                                <xsl:with-param name="isClosedAttr" select="$isClosedAttr"/>
                                <xsl:with-param name="nestinglevel" select="$nestinglevel"/>
                                <xsl:with-param name="checkIsClosed" select="$checkIsClosed"/>
                                <xsl:with-param name="sofar" select="$sofar, concat($rccontent/@id,'-',$rccontent/@effectiveDate)"/>
                                <xsl:with-param name="templateFormat" select="$templateFormat"/>
                            </xsl:call-template>
                        </xsl:for-each>
                        <!--</xsl:if>-->
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="logMessage">
                            <xsl:with-param name="level" select="$logERROR"/>
                            <xsl:with-param name="msg">
                                <xsl:text>+++ Element with attributes "</xsl:text>
                                <xsl:for-each select="@*">
                                    <xsl:text>@</xsl:text>
                                    <xsl:value-of select="name()"/>
                                    <xsl:text>='</xsl:text>
                                    <xsl:value-of select="."/>
                                    <xsl:text>'</xsl:text>
                                    <xsl:if test="position()!=last()">
                                        <xsl:text> </xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                                <xsl:text>" will NOT be processed... context=</xsl:text>
                                <xsl:value-of select="$currentContext"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
        <xd:param name="itemlabel">The item label we are currently at</xd:param>
        <xd:param name="currentContext"/>
        <xd:param name="uniqueId"/>
        <xd:param name="uniqueEffectiveTime"/>
        <xd:param name="isClosedAttr">Are we currently in or under @isClosed='true'</xd:param>
        <xd:param name="checkIsClosed">Are we in the cycle for checking closed logic</xd:param>
        <xd:param name="nestinglevel">The nesting level we are currently at</xd:param>
        <xd:param name="predicatetest"/>
        <xd:param name="seethisthingurl">What URL should we point a user to in case of failed assertions?</xd:param>
        <xd:param name="contextSuffix"/>
        <xd:param name="sofar">Array of templates found so far where every array item is concat(template/@id,'-',template/@effectiveDate)</xd:param>
        <xd:param name="templateFormat"/>
    </xd:doc>
    <xsl:template match="choice" mode="doTemplateRulesForClosed">
        <xsl:param name="itemlabel"/>
        <xsl:param name="currentContext"/>
        <xsl:param name="uniqueId"/>
        <xsl:param name="uniqueEffectiveTime"/>
        <xsl:param name="isClosedAttr" as="xs:boolean"/>
        <xsl:param name="checkIsClosed" as="xs:boolean"/>
        <xsl:param name="nestinglevel"/>
        <xsl:param name="predicatetest" select="false()" as="xs:boolean"/>
        <xsl:param name="seethisthingurl"/>
        <xsl:param name="contextSuffix"/>
        <xsl:param name="sofar" as="xs:string*" required="yes"/>
        <xsl:param name="templateFormat" as="xs:string"/>
        <xsl:for-each select="element|include|choice">
            <!-- cardinality already checked by another rule -->
            <xsl:apply-templates select="." mode="doTemplateRulesForClosed">
                <xsl:with-param name="rc" select="."/>
                <xsl:with-param name="itemlabel" select="$itemlabel"/>
                <xsl:with-param name="currentContext" select="$currentContext"/>
                <xsl:with-param name="uniqueId" select="$uniqueId"/>
                <xsl:with-param name="uniqueEffectiveTime" select="$uniqueEffectiveTime"/>
                <xsl:with-param name="isClosedAttr">
                    <xsl:choose>
                        <xsl:when test="$switchCreateSchematronClosed=true()">
                            <xsl:value-of select="true()"/>
                        </xsl:when>
                        <xsl:when test="@isClosed">
                            <xsl:value-of select="xs:boolean(@isClosed)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$isClosedAttr"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
                <xsl:with-param name="checkIsClosed" select="$checkIsClosed"/>
                <xsl:with-param name="nestinglevel" select="if (self::choice) then ($nestinglevel) else ($nestinglevel+1)"/>
                <xsl:with-param name="predicatetest" select="$predicatetest"/>
                <xsl:with-param name="seethisthingurl" select="$seethisthingurl"/>
                <xsl:with-param name="contextSuffix" select="$contextSuffix"/>
                <xsl:with-param name="sofar" select="$sofar"/>
                <xsl:with-param name="templateFormat" select="$templateFormat"/>
            </xsl:apply-templates>
        </xsl:for-each>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Entry point for merging a template. Prelude: there is an element[@contains] and we have already figured out the template that it points to in <xd:ref name="containedTemplate"/></xd:desc>
        <xd:param name="containedTemplate">The template pointed to by element/@contains and @flexibility</xd:param>
        <xd:param name="currentItemLabel">The item label leading to this point</xd:param>
        <xd:param name="sofar">The list of template/concat(@id-@effectiveDate) sofar so we know we're looping if applicable</xd:param>
        <xd:param name="templateFormat"/>
    </xd:doc>
    <xsl:template match="element" mode="mergeTemplates">
        <xsl:param name="containedTemplate" as="element(template)*"/>
        <xsl:param name="currentItemLabel" as="xs:string?"/>
        <xsl:param name="sofar" as="xs:string*" required="yes"/>
        <xsl:param name="templateFormat" as="xs:string"/>
        
        <!-- get item label for this template -->
        <xsl:variable name="newitemlabel">
            <xsl:call-template name="getNewItemLabel">
                <xsl:with-param name="rc" select="$containedTemplate"/>
                <xsl:with-param name="default" select="$currentItemLabel"/>
            </xsl:call-template>
        </xsl:variable>
        
        <!-- merge stuff -->
        <xsl:copy>
            <xsl:copy-of select="@* except (@contains | @flexibility)" copy-namespaces="no"/>
            <xsl:copy-of select="item | vocabulary | $containedTemplate/vocabulary | text | $containedTemplate/text"/>
            <xsl:for-each select="attribute | $containedTemplate/attribute">
                <xsl:apply-templates select="." mode="NORMALIZE"/>
            </xsl:for-each>
            <xsl:apply-templates select="node()" mode="mergeContainingTemplate">
                <xsl:with-param name="mergeNodes" select="$containedTemplate/(element | include | choice)"/>
                <xsl:with-param name="mergeContext" select="exists($containedTemplate/context[@id = ('*', '**')])"/>
                <xsl:with-param name="mergeLabel" select="$newitemlabel"/>
                <xsl:with-param name="sofar" select="$sofar, concat($containedTemplate/@id, '-', $containedTemplate/@effectiveDate)"/>
                <xsl:with-param name="templateFormat" select="$templateFormat"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="$containedTemplate/(element | include | choice)" mode="mergeContainedTemplate">
                <xsl:with-param name="mergeNodes" select="element | include | choice"/>
                <xsl:with-param name="mergeContext" select="exists($containedTemplate/context[@id = ('*', '**')])"/>
                <xsl:with-param name="mergeLabel" select="$newitemlabel"/>
                <xsl:with-param name="sofar" select="$sofar, concat($containedTemplate/@id, '-', $containedTemplate/@effectiveDate)"/>
                <xsl:with-param name="templateFormat" select="$templateFormat"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>This template should be called in the context of an element with @contains. Context choices and includes are copied as-is. Context 
                element walks through the child nodes and compares each with the list in <xd:ref name="mergeNodes" type="parameter">mergeNodes</xd:ref>
                This is done by calculating the name including predicates and a string compare. 
                <xd:ul>
                    <xd:li>If the node matches any node in the mergeNodes then the node with its children is added to the result as-is.</xd:li>
                    <xd:li>Else the node is added to the result merging its child nodes in the same fashion by recursing and then the child nodes of the matching node by calling in mode 'mergeContainedTemplate'</xd:li>
                </xd:ul>
            </xd:p>
        </xd:desc>
        <xd:param name="mergeNodes">node set containing child nodes from the called template via @contains at the same level as the context node children</xd:param>
        <xd:param name="mergeContext">boolean that tells us whether or not the mergeNodes are from a context * / ** template. See counterpart template with mode 'mergeContainedTemplate'</xd:param>
        <xd:param name="mergeLabel">string with calculated item label for the assert/report user text</xd:param>
        <xd:param name="sofar">Array of templates found so far where every array item is concat(template/@id,'-',template/@effectiveDate)</xd:param>
        <xd:param name="templateFormat"/>
    </xd:doc>
    <xsl:template match="*" mode="mergeContainingTemplate">
        <xsl:param name="mergeNodes" as="node()*"/>
        <xsl:param name="mergeContext" as="xs:boolean"/>
        <xsl:param name="mergeLabel"/>
        <xsl:param name="sofar" as="xs:string*" required="yes"/>
        <!-- SBFIX-->
        <xsl:param name="templateFormat" as="xs:string" select="'hl7v3xml1'"/>
        <!--/SBFIX-->
        <xsl:choose>
            <xsl:when test="self::element">        B
                <xsl:variable name="elemname">
                    <xsl:call-template name="getWherePathFromNodeset">
                        <xsl:with-param name="rccontent" select="."/>
                        <xsl:with-param name="sofar" select="()"/>
                        <xsl:with-param name="templateFormat" select="$templateFormat"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="comparenames" as="xs:string*">
                    <xsl:apply-templates select="$mergeNodes[self::element]" mode="getNamesForMerge">
                        <xsl:with-param name="sofar" select="$sofar"/>
                        <xsl:with-param name="templateFormat" select="$templateFormat"/>
                    </xsl:apply-templates>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="not($comparenames[. = $elemname])">
                        <xsl:copy-of select="self::node()" copy-namespaces="no"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="comparenode">
                            <xsl:for-each select="$mergeNodes[self::element]">
                                <xsl:variable name="elemnametmpl">
                                    <xsl:call-template name="getWherePathFromNodeset">
                                        <xsl:with-param name="rccontent" select="."/>
                                        <xsl:with-param name="sofar" select="()"/>
                                    </xsl:call-template>
                                </xsl:variable>
                                <xsl:if test="$elemnametmpl = $elemname">
                                    <xsl:copy-of select="."/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:copy>
                            <xsl:copy-of select="@*" copy-namespaces="no"/>
                            <!-- Copy these as they have use for determining predicates/item labels -->
                            <!--xsl:copy-of select="item|attribute|vocabulary" copy-namespaces="no"/-->
                            <xsl:apply-templates select="node()" mode="mergeContainingTemplate">
                                <xsl:with-param name="mergeNodes" select="$comparenode/*/(element|include|choice)"/>
                                <xsl:with-param name="mergeContext" select="$mergeContext"/>
                                <xsl:with-param name="mergeLabel" select="$mergeLabel"/>
                                <xsl:with-param name="sofar" select="$sofar"/>
                            </xsl:apply-templates>
                            <xsl:apply-templates select="$comparenode/*/(element|include|choice)" mode="mergeContainedTemplate">
                                <xsl:with-param name="mergeNodes" select="element | include | choice"/>
                                <xsl:with-param name="mergeContext" select="$mergeContext"/>
                                <xsl:with-param name="mergeLabel" select="$mergeLabel"/>
                                <xsl:with-param name="sofar" select="$sofar"/>
                            </xsl:apply-templates>
                        </xsl:copy>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <!-- 2DO Try to merge choices between element[@contains] and the contained template? -->
                <!-- 2DO Try to merge includes between element[@contains] and the contained template? -->
                <xsl:copy-of select="." copy-namespaces="no"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>This template should be called in the context of an element that is called via @contains. Context choices and includes are copied as-is with 
                an additional attribute @mergedContent and @mergeLabel, so that may be used as a hint in further processing. Context 
                element walks through the child nodes and compares each with the list in <xd:ref name="mergeNodes" type="parameter">mergeNodes</xd:ref>
                This is done by calculating the name including predicates and a string compare. 
                <xd:ul>
                    <xd:li>If the node matches any node in the mergeNodes then the node with its children is added to the result as-is.</xd:li>
                    <xd:li>Else the node is skipped as it may be assumed that it is already merged by the counterpart template 'mergeContainingTemplate'</xd:li>
                </xd:ul>
            </xd:p>
        </xd:desc>
        <xd:param name="mergeNodes">node set containing child nodes from the calling template via @contains at the same level as the context node children</xd:param>
        <xd:param name="mergeContext">boolean that tells us whether or not the context node is from a context * / ** template</xd:param>
        <xd:param name="mergeLabel">string with calculated item label for the assert/report user text</xd:param>
        <xd:param name="sofar">Array of templates found so far where every array item is concat(template/@id,'-',template/@effectiveDate)</xd:param>
        <xd:param name="templateFormat"/>
    </xd:doc>
    <xsl:template match="*" mode="mergeContainedTemplate">
        <xsl:param name="mergeNodes" as="node()*"/>
        <xsl:param name="mergeContext" as="xs:boolean"/>
        <xsl:param name="mergeLabel"/>
        <xsl:param name="sofar" as="xs:string*" required="yes"/>
        <!--SBFIX-->
        <xsl:param name="templateFormat" as="xs:string" select="'hl7v3xml1'"/>
        <!--/SBFIX-->
        <xsl:choose>
            <xsl:when test="self::element">
                <xsl:variable name="elemname">
                    <xsl:call-template name="getWherePathFromNodeset">
                        <xsl:with-param name="rccontent" select="."/>
                        <xsl:with-param name="sofar" select="$sofar"/>
                        <xsl:with-param name="templateFormat" select="$templateFormat"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="comparenames" as="xs:string*">
                    <xsl:apply-templates select="$mergeNodes[self::element]" mode="getNamesForMerge">
                        <xsl:with-param name="sofar" select="$sofar"/>
                        <xsl:with-param name="templateFormat" select="$templateFormat"/>
                    </xsl:apply-templates>
                </xsl:variable>
                <xsl:if test="not($comparenames[. = $elemname])">
                    <xsl:copy copy-namespaces="no">
                        <xsl:copy-of select="@*" copy-namespaces="no"/>
                        <!-- Do override of minimumMultiplicity only when not @conformance = 'NP' -->
                        <xsl:if test="not(@conformance = 'NP') and not(@minimumMultiplicity > 0) and not(preceding-sibling::*[name() = ('element','include','choice')] | following-sibling::*[name() = ('element','include','choice')])">
                            <xsl:attribute name="minimumMultiplicity">1</xsl:attribute>
                        </xsl:if>
                        <xsl:attribute name="mergedContent" select="$mergeContext"/>
                        <xsl:if test="string-length($mergeLabel)&gt;0">
                            <xsl:attribute name="mergedLabel" select="$mergeLabel"/>
                        </xsl:if>
                        <xsl:copy-of select="node()" copy-namespaces="no"/>
                    </xsl:copy>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <!-- 2DO: Try to merge choices between element[@contains] and the contained template? -->
                <!-- 2DO: Try to merge includes between element[@contains] and the contained template? -->
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <!-- Do override of minimumMultiplicity only when not @conformance = 'NP', @minimumMultiplicity not already > 0 and if there are no other elements/includes/choices -->
                    <xsl:if test="not(@conformance = 'NP') and not(@minimumMultiplicity > 0) and not(preceding-sibling::*[name() = ('element','include','choice')] | following-sibling::*[name() = ('element','include','choice')])">
                        <xsl:attribute name="minimumMultiplicity">1</xsl:attribute>
                    </xsl:if>
                    <xsl:attribute name="mergedContent" select="'true'"/>
                    <xsl:if test="string-length($mergeLabel)&gt;0">
                        <xsl:attribute name="mergedLabel" select="$mergeLabel"/>
                    </xsl:if>
                    <xsl:copy-of select="node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc/>
        <xd:param name="sofar">Array of templates found so far where every array item is concat(template/@id,'-',template/@effectiveDate)</xd:param>
        <xd:param name="templateFormat"/>
    </xd:doc>
    <xsl:template match="element|include|choice" mode="getNamesForMerge" as="xs:string*">
        <xsl:param name="sofar" as="xs:string*" required="yes"/>
        <xsl:param name="templateFormat" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="self::element">
                <xsl:call-template name="getWherePathFromNodeset">
                    <xsl:with-param name="rccontent" select="."/>
                    <xsl:with-param name="sofar" select="()"/>
                    <xsl:with-param name="templateFormat" select="$templateFormat"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="self::include">
                <xsl:variable name="rccontent" as="element()?">
                    <xsl:call-template name="getRulesetContent">
                        <xsl:with-param name="ruleset" select="@ref"/>
                        <xsl:with-param name="flexibility" select="@flexibility"/>
                        <xsl:with-param name="sofar" select="$sofar"/>
                    </xsl:call-template>
                </xsl:variable>
                
                <xsl:apply-templates select="$rccontent/element|$rccontent/include|$rccontent/choice" mode="getNamesForIsClosedTemplate">
                    <xsl:with-param name="sofar" select="$sofar, concat($rccontent/@id,'-',$rccontent/@effectiveDate)"/>
                    <xsl:with-param name="templateFormat" select="$templateFormat"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="self::choice">
                <xsl:apply-templates select="element|include|choice" mode="getNamesForIsClosed">
                    <xsl:with-param name="sofar" select="$sofar"/>
                    <xsl:with-param name="templateFormat" select="$templateFormat"/>
                </xsl:apply-templates>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Get the (predicated) names that a closed element should expect in a given context</xd:desc>
        <xd:param name="sofar">Array of templates found so far where every array item is concat(template/@id,'-',template/@effectiveDate)</xd:param>
        <xd:param name="templateFormat"/>
    </xd:doc>
    <xsl:template match="element|include|choice" mode="getNamesForIsClosed">
        <xsl:param name="sofar" as="xs:string*" required="yes"/>
        <xsl:param name="templateFormat" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="self::element[@strength=('CWE','extensible','preferred','example')]">
                <!-- 
                    don't do the predicated check for elements with a @strength that is liberating the actual content: we can't test that with predicate, do just the element name 
                -->
                <xsl:text>self::</xsl:text>
                <xsl:value-of select="@name"/>
                <xsl:text> | </xsl:text>
            </xsl:when>
            <xsl:when test="self::element">
                <xsl:text>self::</xsl:text>
                <xsl:call-template name="getWherePathFromNodeset">
                    <xsl:with-param name="rccontent" select="."/>
                    <xsl:with-param name="sofar" select="()"/>
                    <xsl:with-param name="templateFormat" select="$templateFormat"/>
                </xsl:call-template>
                <xsl:text> | </xsl:text>
            </xsl:when>
            <xsl:when test="self::include">
                <xsl:variable name="rccontent" as="element()?">
                    <xsl:call-template name="getRulesetContent">
                        <xsl:with-param name="ruleset" select="@ref"/>
                        <xsl:with-param name="flexibility" select="@flexibility"/>
                        <xsl:with-param name="sofar" select="$sofar"/>
                    </xsl:call-template>
                </xsl:variable>
                
                <xsl:apply-templates select="$rccontent/element|$rccontent/include|$rccontent/choice" mode="getNamesForIsClosedTemplate">
                    <xsl:with-param name="sofar" select="$sofar, concat($rccontent/@id,'-',$rccontent/@effectiveDate)"/>
                    <xsl:with-param name="templateFormat" select="$templateFormat"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="self::choice">
                <xsl:apply-templates select="element|include|choice" mode="getNamesForIsClosed">
                    <xsl:with-param name="sofar" select="$sofar"/>
                    <xsl:with-param name="templateFormat" select="$templateFormat"/>
                </xsl:apply-templates>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Get the (predicated) names that a closed template should expect in a given context</xd:desc>
        <xd:param name="previousContext"/>
        <xd:param name="sofar">Array of templates found so far where every array item is concat(template/@id,'-',template/@effectiveDate)</xd:param>
        <xd:param name="templateFormat"/>
    </xd:doc>
    <xsl:template match="element|include|choice" mode="getNamesForIsClosedTemplate">
        <xsl:param name="previousContext"/>
        <xsl:param name="sofar" as="xs:string*" required="yes"/>
        <xsl:param name="templateFormat" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="self::element">
                <xsl:choose>
                    <xsl:when test="string-length($previousContext)">
                        <xsl:value-of select="$previousContext"/>
                        <xsl:text>/</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>self::</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:call-template name="getWherePathFromNodeset">
                    <xsl:with-param name="rccontent" select="."/>
                    <xsl:with-param name="sofar" select="()"/>
                    <xsl:with-param name="templateFormat" select="$templateFormat"/>
                </xsl:call-template>
                <!--xsl:value-of select="$context"/-->
                <xsl:text> | </xsl:text>
            </xsl:when>
            <xsl:when test="self::include">
                <xsl:variable name="rccontent" as="element()?">
                    <xsl:call-template name="getRulesetContent">
                        <xsl:with-param name="ruleset" select="@ref"/>
                        <xsl:with-param name="flexibility" select="@flexibility"/>
                        <xsl:with-param name="previousContext" select="$previousContext"/>
                        <xsl:with-param name="sofar" select="$sofar"/>
                    </xsl:call-template>
                </xsl:variable>
                
                <xsl:apply-templates select="$rccontent/element|$rccontent/include|$rccontent/choice" mode="getNamesForIsClosedTemplate">
                    <xsl:with-param name="previousContext" select="$previousContext"/>
                    <xsl:with-param name="sofar" select="$sofar, concat($rccontent/@id,'-',$rccontent/@effectiveDate)"/>
                    <xsl:with-param name="templateFormat" select="$templateFormat"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="self::choice">
                <xsl:apply-templates select="element|include|choice" mode="getNamesForIsClosedTemplate">
                    <xsl:with-param name="sofar" select="$sofar"/>
                    <xsl:with-param name="templateFormat" select="$templateFormat"/>
                </xsl:apply-templates>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Get item reference or description (to be shown in every assert/report).<xd:br/>an item desc has priority over an item ref number, so</xd:p>
            <xd:ul>
                <xd:li>if item/desc is given use it</xd:li>
                <xd:li>if item/@label is not given then take it over from previous (previousitemlabel)</xd:li>
                <xd:li>if item/@label is given use it and build it with possible project prefix</xd:li>
            </xd:ul>
        </xd:desc>
        <xd:param name="rc"/>
        <xd:param name="default"/>
    </xd:doc>
    <xsl:template name="getNewItemLabel">
        <!-- node set shall be a template -->
        <xsl:param name="rc"/>
        <!-- the default if getting a new item failed -->
        <xsl:param name="default"/>
        <xsl:choose>
            <xsl:when test="$rc[name()='item']/desc[@language=$defaultLanguage][string-length(.)&gt;0]">
                <xsl:value-of select="($rc[name()='item']/desc[@language=$defaultLanguage][string-length(.)&gt;0])[1]"/>
            </xsl:when>
            <xsl:when test="$rc[name()='item']/@label[string-length(.)&gt;0]">
                <!-- 
                        item @label available, use it
                        if it is a simple number or string without "-"
                        use the original item and preceed it with
                        then project prefix
                        if it has a "-" in it just take it as it is
                    -->
                <xsl:variable name="xitem" select="$rc[name()='item']/@label"/>
                <xsl:value-of select="$xitem"/>
                <!--
                    <xsl:choose>
                        <xsl:when test="contains($xitem, '-')">
                            <xsl:value-of select="$xitem"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat($projectPrefix, $xitem)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    -->
            </xsl:when>
            <xsl:when test="$rc/name()='template' and count($rc/context)&gt;0">
                <!-- item/@label is not available but this is in a template context * or **, use this name or id -->
                <xsl:text>(</xsl:text>
                <xsl:choose>
                    <xsl:when test="$rc/@name">
                        <!-- use template name -->
                        <xsl:value-of select="$rc/@name"/>
                    </xsl:when>
                    <xsl:when test="$rc/@id">
                        <!-- use template id -->
                        <xsl:value-of select="$rc/@id"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>conf</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>)</xsl:text>
            </xsl:when>
            <xsl:when test="$rc/name()='template'">
                <!-- item/@label is not available take template name -->
                <xsl:text>(</xsl:text>
                <xsl:choose>
                    <xsl:when test="$rc/@name">
                        <!-- use template name -->
                        <xsl:value-of select="$rc/@name"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>conf</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>)</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <!-- is empty here, inherit from parent -->
                <xsl:value-of select="$default"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc>Merge two rulesets into 1 based on rule context</xd:desc>
        <xd:param name="rs1">First ruleset</xd:param>
        <xd:param name="rs2">Second ruleset</xd:param>
    </xd:doc>
    <xsl:template name="mergeRulesets">
        <!-- 
            merge the two rulesets 1 and 2
        -->
        <xsl:param name="rs1"/>
        <xsl:param name="rs2"/>

        <!--
        <RULESET1>
            <xsl:copy-of select="$rs1"/>
        </RULESET1>
        <RULESET2>
            <xsl:copy-of select="$rs2"/>
        </RULESET2>
        -->

        <!-- first find out all rules in set 1 and 2 with the same context -->
        <xsl:variable name="listOfSameContext">
            <ctx xmlns="">
                <xsl:for-each select="$rs1/*/*">
                    <xsl:variable name="c1" select="@context"/>
                    <xsl:variable name="i1" select="@id"/>
                    <xsl:for-each select="$rs2/*/*">
                        <xsl:variable name="c2" select="@context"/>
                        <xsl:variable name="i2" select="@id"/>
                        <xsl:if test="$c1=$c2">
                            <same context="{$c1}" ruleid1="{$i1}" ruleid2="{$i2}"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:for-each>
            </ctx>
        </xsl:variable>
        <!--
        <xsl:text>
</xsl:text>
        <xsl:text>
</xsl:text>
        <xsl:text>
</xsl:text>
        <xsl:text>
</xsl:text>
        <xsl:text>
</xsl:text>
        <xsl:text>
</xsl:text>
        
        <MERGERCONTEXT>
            <xsl:for-each select="$listOfSameContext/*">
                <xsl:copy-of select="same"/>
            </xsl:for-each>
        </MERGERCONTEXT>
        
        <xsl:text>
</xsl:text>
        <xsl:text>
</xsl:text>
        <xsl:text>
</xsl:text>
        -->
        <!-- 
            run thru all rules in set 1 (including comments)
        -->
        <xsl:for-each select="$rs1/*/(comment()|*)">
            <xsl:variable name="ctx" select="@context"/>
            <xsl:choose>
                <xsl:when test="self::comment()">
                    <xsl:text>
</xsl:text>
                    <xsl:text>
</xsl:text>
                    <xsl:copy-of select="."/>
                </xsl:when>
                <xsl:when test="self::*:rule">
                    <xsl:text>
</xsl:text>
                    <xsl:choose>
                        <xsl:when test="count($listOfSameContext/*/same[@context=$ctx])&gt;0">
                            <!-- 
                                this rule 1 has another rule 2 with the same context
                                copy rule 1 to output with an extends rule statement
                                to the corresponding rule in set 2
                            -->
                            <!--
                            <RULE1WITHEXTENDS context="{$ctx}">
                                <xsl:copy-of select="."/>
                            </RULE1WITHEXTENDS>
                            -->
                            <xsl:copy exclude-result-prefixes="#all">
                                <xsl:copy-of select="@* except @id" exclude-result-prefixes="#all"/>
                                <extends xmlns="http://purl.oclc.org/dsdl/schematron" rule="{($listOfSameContext/*/same[@context=$ctx])[1]/@ruleid2}"/>
                                <xsl:copy-of select="./*"/>
                            </xsl:copy>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- 
                                this rule 1 has no rule 2 with the same context
                                copy rule 1 to output
                            -->
                            <!--
                            <RULE1 context="{$ctx}"/>
                            -->
                            <xsl:copy exclude-result-prefixes="#all">
                                <xsl:choose>
                                    <xsl:when test="@abstract='true'">
                                        <xsl:copy-of select="@*" exclude-result-prefixes="#all"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:copy-of select="@* except @id" exclude-result-prefixes="#all"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:copy-of select="./*"/>
                            </xsl:copy>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>

        <!-- 
            run thru all rules in set 2 (including comments)
        -->
        <xsl:for-each select="$rs2/*/(comment()|*)">
            <xsl:variable name="ctx" select="@context"/>
            <xsl:choose>
                <xsl:when test="self::comment()">
                    <xsl:text>
</xsl:text>
                    <xsl:text>
</xsl:text>
                    <xsl:copy-of select="."/>
                </xsl:when>
                <xsl:when test="self::*:rule">
                    <xsl:text>
</xsl:text>
                    <xsl:choose>
                        <xsl:when test="count($listOfSameContext/*/same[@context=$ctx])&gt;0">
                            <!-- 
                                this rule 2 has another rule 1 with the same context
                                copy rule 2 to output and turn it into an abstract rule
                                (that is extended by the corresponding rule in set 1)
                            -->
                            <!-- this rule 2 has another rule 1 with the same context -->
                            <!--
                            <RULE2WITHABSTRACT context="{$ctx}">
                                <xsl:copy-of select="."/>
                            </RULE2WITHABSTRACT>
                            -->
                            <xsl:copy>
                                <xsl:copy-of select="@* except @context" copy-namespaces="no"/>
                                <xsl:attribute name="abstract" select="true()"/>
                                <xsl:copy-of select="./*"/>
                            </xsl:copy>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- 
                                this rule 2 has no rule 1 with the same context
                                copy rule 2 to output
                            -->
                            <!--
                            <RULE2 context="{$ctx}"/>
                            -->
                            <xsl:copy exclude-result-prefixes="#all">
                                <xsl:choose>
                                    <xsl:when test="@abstract='true'">
                                        <xsl:copy-of select="@*" exclude-result-prefixes="#all"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:copy-of select="@* except @id" exclude-result-prefixes="#all"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:copy-of select="./*"/>
                            </xsl:copy>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="logMessage">
                        <xsl:with-param name="level" select="$logFATAL"/>
                        <xsl:with-param name="terminate" select="true()"/>
                        <xsl:with-param name="msg">
                            <xsl:text>Internal error. Unknown generated schematron found: </xsl:text>
                            <xsl:copy-of select="."/>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    <xd:doc>
        <xd:desc>Copy a structure into the schematron namespace</xd:desc>
    </xd:doc>
    <xsl:template name="doCopyIntoSchematronNamespace">
        <xsl:choose>
            <xsl:when test="self::text()|self::comment()|self::processing-instruction()">
                <xsl:copy-of select="self::node()"/>
            </xsl:when>
            <xsl:when test="self::*[namespace-uri()='' or namespace-uri()='http://purl.oclc.org/dsdl/schematron']">
                <xsl:element xmlns="http://purl.oclc.org/dsdl/schematron" name="{local-name()}">
                    <xsl:copy-of select="@*"/>
                    <xsl:for-each select="node()">
                        <xsl:call-template name="doCopyIntoSchematronNamespace"/>
                    </xsl:for-each>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:for-each select="node()">
                        <xsl:call-template name="doCopyIntoSchematronNamespace"/>
                    </xsl:for-each>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--<xsl:template name="doDefineVariable-not-used">
        <xsl:variable name="theCode">
            <xsl:if test="string-length(code/@code)&gt;0 or string-length(code/@codeSystem)&gt;0">
                <xsl:text>[</xsl:text>
                <xsl:value-of select="$projectDefaultElementPrefix"/>
                <xsl:text>code</xsl:text>
            </xsl:if>
            <xsl:if test="string-length(code/@code)&gt;0">
                <xsl:text>[@code='</xsl:text>
                <xsl:value-of select="code/@code"/>
                <xsl:text>']</xsl:text>
            </xsl:if>
            <xsl:if test="string-length(code/@codeSystem)&gt;0">
                <xsl:text>[@codeSystem='</xsl:text>
                <xsl:value-of select="code/@codeSystem"/>
                <xsl:text>']</xsl:text>
            </xsl:if>
            <xsl:if test="string-length(code/@code)&gt;0 or string-length(code/@codeSystem)&gt;0">
                <xsl:text>]</xsl:text>
            </xsl:if>
        </xsl:variable>
        <!-\- assertion: use/@name is not empty and contains a valid xpath to a data type value, typed INT or CE or TS -\->
        <let xmlns="http://purl.oclc.org/dsdl/schematron" name="temp1_{@name}" value="{@path}{$theCode}/{use/@path}"/>
        <xsl:choose>
            <xsl:when test="use/@as='INT'">
                <let xmlns="http://purl.oclc.org/dsdl/schematron" name="{@name}" value="if ($temp1_{@name} castable as xs:integer) then ($temp1_{@name} cast as xs:integer) else false"/>
            </xsl:when>
            <xsl:when test="use/@as='CE'">
                <let xmlns="http://purl.oclc.org/dsdl/schematron" name="{@name}" value="$temp1_{@name}"/>
            </xsl:when>
            <xsl:when test="use/@as='TS.JULIAN'">
                <let xmlns="http://purl.oclc.org/dsdl/schematron" name="temp2_{@name}" value="concat(substring($temp1_{@name}, 1, 4), '-', substring($temp1_{@name}, 5, 2), '-', substring($temp1_{@name}, 7, 2))"/>
                <let xmlns="http://purl.oclc.org/dsdl/schematron" name="temp3_{@name}" value="if ($temp2_{@name} castable as xs:date) then ($temp2_{@name} cast as xs:date) else false"/>
                <!-\- modified julian day, days after Nov 17, 1858 -\->
                <let xmlns="http://purl.oclc.org/dsdl/schematron" name="{@name}" value="days-from-duration($temp3_{@name} - xs:date('1858-11-17'))"/>
            </xsl:when>
            <xsl:when test="use/@as='TS'">
                <let xmlns="http://purl.oclc.org/dsdl/schematron" name="{@name}" value="$temp1_{@name}"/>
            </xsl:when>
            <xsl:otherwise>
                <let xmlns="http://purl.oclc.org/dsdl/schematron" name="{@name}" value="false"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>-->
    <xd:doc>
        <xd:desc>Handle template in default instance</xd:desc>
        <xd:param name="rt"/>
        <xd:param name="sofar">Array of templates found so far where every array item is concat(template/@id,'-',template/@effectiveDate)</xd:param>
        <xd:param name="templateFormat"/>
    </xd:doc>
    <xsl:template match="template" mode="createDefaultInstance">
        <xsl:param name="rt"/>
        <xsl:param name="sofar" as="xs:string*" required="yes"/>
        <xsl:param name="templateFormat" as="xs:string"/>
        <xsl:call-template name="logMessage">
            <xsl:with-param name="level" select="$logALL"/>
            <xsl:with-param name="msg">
                <xsl:text>template match="template" mode="createDefaultInstance" writing for template id=</xsl:text>
                <xsl:value-of select="(@id|@ref)"/>
                <xsl:text> effectiveDate</xsl:text>
                <xsl:value-of select="(@effectiveDate|@flexibility)"/>
                <xsl:text> name=</xsl:text>
                <xsl:value-of select="@name"/>
                <xsl:text> displayName=</xsl:text>
                <xsl:value-of select="@displayName"/>
            </xsl:with-param>
        </xsl:call-template>
        <hl7:instance name="{@name}">
            <xsl:copy-of select="$allDECOR/namespace::node()"/>
            <xsl:copy-of select="context/@path"/>
            <xsl:apply-templates select="element|include|choice" mode="createDefaultInstance">
                <xsl:with-param name="rt" select="$rt"/>
                <xsl:with-param name="tid" select="@id"/>
                <xsl:with-param name="tef" select="@effectiveDate"/>
                <xsl:with-param name="previousitemlabel" select="@name"/>
                <xsl:with-param name="sofar" select="$sofar"/>
                <xsl:with-param name="templateFormat" select="$templateFormat"/>
            </xsl:apply-templates>
        </hl7:instance>
    </xsl:template>
    <xd:doc>
        <xd:desc>Handle element in default instance</xd:desc>
        <xd:param name="rt"/>
        <xd:param name="tid">Template/@id of the template we're in</xd:param>
        <xd:param name="tef">Template/@effectiveDate of the template we're in</xd:param>
        <xd:param name="previousitemlabel"/>
        <xd:param name="inheritedminimumMultiplicity"/>
        <xd:param name="inheritedmaximumMultiplicity"/>
        <xd:param name="inheritedConformance"/>
        <xd:param name="inheritedIsMandatory"/>
        <xd:param name="sofar">Array of templates found so far where every array item is concat(template/@id,'-',template/@effectiveDate)</xd:param>
        <xd:param name="templateFormat"/>
    </xd:doc>
    <xsl:template match="element" mode="createDefaultInstance">
        <xsl:param name="rt"/>
        <xsl:param name="tid"/>
        <xsl:param name="tef"/>
        <xsl:param name="previousitemlabel"/>
        <xsl:param name="inheritedminimumMultiplicity"/>
        <xsl:param name="inheritedmaximumMultiplicity"/>
        <xsl:param name="inheritedConformance"/>
        <xsl:param name="inheritedIsMandatory"/>
        <xsl:param name="sofar" as="xs:string*" required="yes"/>
        <xsl:param name="templateFormat" as="xs:string"/>
        <xsl:call-template name="logMessage">
            <xsl:with-param name="level" select="$logALL"/>
            <xsl:with-param name="msg">
                <xsl:text>template match="element" mode="createDefaultInstance" writing for template id=</xsl:text>
                <xsl:value-of select="ancestor::template/(@id|@ref)"/>
                <xsl:text> effectiveDate</xsl:text>
                <xsl:value-of select="ancestor::template/(@effectiveDate|@flexibility)"/>
                <xsl:text> name=</xsl:text>
                <xsl:value-of select="ancestor::template/@name"/>
                <xsl:text> displayName=</xsl:text>
                <xsl:value-of select="ancestor::template/@displayName"/>
                <xsl:text>
    </xsl:text>
                <xsl:value-of select="string-join(ancestor-or-self::*[ancestor::template]/concat(name(),'[',@name,']'),' / ')"/>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:variable name="elmname">
            <xsl:choose>
                <xsl:when test="contains(@name, '[')">
                    <xsl:value-of select="substring-before(@name, '[')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@name"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="elmprefix">
            <xsl:choose>
                <xsl:when test="contains($elmname, ':')">
                    <xsl:value-of select="substring-before($elmname, ':')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="hl7"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="elmns">
            <xsl:choose>
                <xsl:when test="$elmprefix='hl7' or $elmprefix='cda'">
                    <xsl:value-of select="'urn:hl7-org:v3'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="namespace-uri-for-prefix($elmprefix,.)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- get the cardinalities conformances etc -->
        <xsl:variable name="minimumMultiplicityAttr">
            <xsl:choose>
                <xsl:when test="string-length($inheritedminimumMultiplicity)&gt;0 and not(@conformance = 'NP')">
                    <xsl:value-of select="$inheritedminimumMultiplicity"/>
                </xsl:when>
                <xsl:when test="string-length(@minimumMultiplicity)&gt;0">
                    <xsl:value-of select="@minimumMultiplicity"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="maximumMultiplicityAttr">
            <xsl:choose>
                <xsl:when test="string-length($inheritedmaximumMultiplicity)&gt;0 and not(@conformance = 'NP')">
                    <xsl:value-of select="$inheritedmaximumMultiplicity"/>
                </xsl:when>
                <xsl:when test="string-length(@maximumMultiplicity)&gt;0">
                    <xsl:value-of select="@maximumMultiplicity"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="isMandatoryAttr">
            <xsl:choose>
                <xsl:when test="string-length($inheritedIsMandatory)&gt;0 and not(@conformance = 'NP')">
                    <xsl:value-of select="$inheritedIsMandatory"/>
                </xsl:when>
                <xsl:when test="string-length(@isMandatory)&gt;0">
                    <xsl:value-of select="@isMandatory"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'false'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="conformanceAttr">
            <xsl:choose>
                <xsl:when test="string-length($inheritedConformance)&gt;0 and not(@conformance = 'NP')">
                    <xsl:value-of select="$inheritedConformance"/>
                </xsl:when>
                <xsl:when test="string-length(@conformance)&gt;0">
                    <xsl:value-of select="@conformance"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="cardconf" select="local:getCardConf($minimumMultiplicityAttr, $maximumMultiplicityAttr, $conformanceAttr, $isMandatoryAttr)"/>
        <xsl:choose>
            <xsl:when test="@name and @contains">
                <!-- lookup contained template content -->
                <xsl:variable name="rccontent" as="element()?">
                    <xsl:call-template name="getRulesetContent">
                        <xsl:with-param name="ruleset" select="@contains"/>
                        <xsl:with-param name="flexibility" select="@flexibility"/>
                        <xsl:with-param name="sofar" select="$sofar"/>
                    </xsl:call-template>
                </xsl:variable>
                
                <!-- 
                    Merge rc with @contains before continuing, or leave rc as-is
                -->
                <xsl:variable name="rcmerged" as="element()">
                    <!-- merge stuff -->
                    <xsl:choose>
                        <xsl:when test="$sofar[. = concat($rccontent/@id, '-', $rccontent/@effectiveDate)]">
                            <xsl:copy>
                                <xsl:copy-of select="@*"/>
                                <!-- place a recursion marker -->
                                <xsl:attribute name="recurse">true</xsl:attribute>
                                <xsl:copy-of select="node()"/>
                            </xsl:copy>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- merge stuff -->
                            <xsl:apply-templates select="." mode="mergeTemplates">
                                <xsl:with-param name="containedTemplate" select="$rccontent"/>
                                <xsl:with-param name="currentItemLabel" select="$previousitemlabel"/>
                                <xsl:with-param name="sofar" select="$sofar"/>
                                <xsl:with-param name="templateFormat" select="$templateFormat"/>
                            </xsl:apply-templates>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="itemlabel">
                    <xsl:call-template name="getNewItemLabel">
                        <xsl:with-param name="rc" select="$rccontent"/>
                        <xsl:with-param name="default" select="$previousitemlabel"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:element name="{$elmname}" namespace="{$elmns}">
                    <xsl:if test="@id">
                        <xsl:attribute name="elementId" select="@id"/>
                        <xsl:attribute name="templateId" select="$tid"/>
                        <xsl:attribute name="templateEffectiveDate" select="$tef"/>
                    </xsl:if>
                    <xsl:attribute name="original" select="@name"/>
                    <xsl:attribute name="withpredicate">
                        <xsl:call-template name="getWherePathFromNodeset">
                            <xsl:with-param name="rccontent" select="."/>
                            <xsl:with-param name="sofar" select="()"/>
                            <xsl:with-param name="templateFormat" select="$templateFormat"/>
                        </xsl:call-template>
                    </xsl:attribute>
                    <xsl:attribute name="label" select="$itemlabel"/>
                    <xsl:if test="string-length($cardconf)&gt;0">
                        <xsl:attribute name="cardconf" select="$cardconf"/>
                    </xsl:if>
                    <xsl:copy-of select="@datatype"/>
                    <xsl:if test="string-length($minimumMultiplicityAttr)&gt;0">
                        <xsl:attribute name="minimumMultiplicity" select="$minimumMultiplicityAttr"/>
                    </xsl:if>
                    <xsl:if test="string-length($maximumMultiplicityAttr)&gt;0">
                        <xsl:attribute name="maximumMultiplicity" select="$maximumMultiplicityAttr"/>
                    </xsl:if>
                    <xsl:if test="string-length($conformanceAttr)&gt;0">
                        <xsl:attribute name="conformance" select="$conformanceAttr"/>
                    </xsl:if>
                    <xsl:if test="string($isMandatoryAttr)='true'">
                        <xsl:attribute name="isMandatory" select="'true'"/>
                    </xsl:if>
                    <xsl:apply-templates select="$rcmerged/attribute" mode="createDefaultInstance">
                        <xsl:with-param name="sofar" select="$sofar, concat($rccontent/@id,'-',$rccontent/@effectiveDate)"/>
                        <xsl:with-param name="templateFormat" select="$templateFormat"/>
                    </xsl:apply-templates>
                    <!--<xsl:apply-templates select="$rcmerged/attribute" mode="createDefaultInstance2">
                        <xsl:with-param name="tid" select="$tid"/>
                        <xsl:with-param name="tef" select="$tef"/>
                    </xsl:apply-templates>-->
                    <xsl:apply-templates select="$rcmerged/(element|include|choice)" mode="createDefaultInstance">
                        <xsl:with-param name="rt" select="$rt"/>
                        <xsl:with-param name="tid" select="$rccontent/@id"/><!-- REVISIT THIS LOGIC -->
                        <xsl:with-param name="tef" select="$rccontent/@effectiveDate"/><!-- REVISIT THIS LOGIC -->
                        <xsl:with-param name="previousitemlabel" select="$itemlabel"/>
                        <xsl:with-param name="sofar" select="$sofar, concat($rccontent/@id,'-',$rccontent/@effectiveDate)"/>
                        <xsl:with-param name="templateFormat" select="$templateFormat"/>
                    </xsl:apply-templates>
                </xsl:element>
            </xsl:when>
            <xsl:when test="@name">
                <xsl:element name="{$elmname}" namespace="{$elmns}">
                    <xsl:if test="@id">
                        <xsl:attribute name="elementId" select="@id"/>
                        <xsl:attribute name="templateId" select="$tid"/>
                        <xsl:attribute name="templateEffectiveDate" select="$tef"/>
                    </xsl:if>
                    <xsl:attribute name="original" select="@name"/>
                    <xsl:attribute name="withpredicate">
                        <xsl:call-template name="getWherePathFromNodeset">
                            <xsl:with-param name="rccontent" select="."/>
                            <xsl:with-param name="sofar" select="()"/>
                            <xsl:with-param name="templateFormat" select="$templateFormat"/>
                        </xsl:call-template>
                    </xsl:attribute>
                    <xsl:attribute name="label" select="$previousitemlabel"/>
                    <xsl:if test="string-length($cardconf)&gt;0">
                        <xsl:attribute name="cardconf" select="$cardconf"/>
                    </xsl:if>
                    <xsl:copy-of select="@datatype"/>
                    <xsl:if test="string-length($minimumMultiplicityAttr)&gt;0">
                        <xsl:attribute name="minimumMultiplicity" select="$minimumMultiplicityAttr"/>
                    </xsl:if>
                    <xsl:if test="string-length($maximumMultiplicityAttr)&gt;0">
                        <xsl:attribute name="maximumMultiplicity" select="$maximumMultiplicityAttr"/>
                    </xsl:if>
                    <xsl:if test="string-length($conformanceAttr)&gt;0">
                        <xsl:attribute name="conformance" select="$conformanceAttr"/>
                    </xsl:if>
                    <xsl:if test="string($isMandatoryAttr)='true'">
                        <xsl:attribute name="isMandatory" select="'true'"/>
                    </xsl:if>
                    <xsl:apply-templates select="attribute" mode="createDefaultInstance">
                        <xsl:with-param name="sofar" select="$sofar"/>
                        <xsl:with-param name="templateFormat" select="$templateFormat"/>
                    </xsl:apply-templates>
                    <xsl:apply-templates select="include" mode="createDefaultInstance">
                        <xsl:with-param name="rt" select="$rt"/>
                        <xsl:with-param name="tid" select="$tid"/>
                        <xsl:with-param name="tef" select="$tef"/>
                        <xsl:with-param name="previousitemlabel" select="$previousitemlabel"/>
                        <xsl:with-param name="doAttributes" select="true()"/>
                        <xsl:with-param name="sofar" select="$sofar"/>
                        <xsl:with-param name="templateFormat" select="$templateFormat"/>
                    </xsl:apply-templates>
                    <xsl:apply-templates select="vocabulary|property" mode="createDefaultInstance">
                        <xsl:with-param name="sofar" select="$sofar"/>
                        <xsl:with-param name="templateFormat" select="$templateFormat"/>
                    </xsl:apply-templates>
                    <xsl:apply-templates select="attribute" mode="createDefaultInstance2">
                        <xsl:with-param name="tid" select="$tid"/>
                        <xsl:with-param name="tef" select="$tef"/>
                        <xsl:with-param name="sofar" select="$sofar"/>
                        <xsl:with-param name="templateFormat" select="$templateFormat"/>
                    </xsl:apply-templates>
                    <xsl:apply-templates select="element|include|choice" mode="createDefaultInstance">
                        <xsl:with-param name="rt" select="$rt"/>
                        <xsl:with-param name="tid" select="$tid"/>
                        <xsl:with-param name="tef" select="$tef"/>
                        <xsl:with-param name="previousitemlabel" select="$previousitemlabel"/>
                        <xsl:with-param name="sofar" select="$sofar"/>
                        <xsl:with-param name="templateFormat" select="$templateFormat"/>
                    </xsl:apply-templates>
                </xsl:element>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc>Get concept/community info for every element with an @id</xd:desc>
        <xd:param name="rt"/>
    </xd:doc>
    <xsl:template match="node()" mode="resolveInstanceElements">
        <xsl:param name="rt"/>
        <xsl:copy>
            <xsl:copy-of select="@* except (@elementId|@templateId|@templateEffectiveDate)"/>
            <xsl:if test="@elementId">
                <xsl:call-template name="doId">
                    <xsl:with-param name="elid" select="@elementId"/>
                    <xsl:with-param name="rt" select="$rt"/>
                    <xsl:with-param name="tid" select="@templateId"/>
                    <xsl:with-param name="tef" select="@templateEffectiveDate"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates select="node()" mode="resolveInstanceElements">
                <xsl:with-param name="rt" select="$rt"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Get concept info for a given attribute/@id or element/@id</xd:desc>
        <xd:param name="elid">Attribute/@id or element/@id to lookup concept info for</xd:param>
        <xd:param name="rt"/>
        <xd:param name="tid">Template/@id of the template we're in</xd:param>
        <xd:param name="tef">Template/@effectiveDate of the template we're in</xd:param>
    </xd:doc>
    <xsl:template name="doId">
        <xsl:param name="elid"/>
        <xsl:param name="rt"/>
        <xsl:param name="tid"/>
        <xsl:param name="tef"/>
        <xsl:if test="not(empty($elid) or $elid='')">
            <xsl:for-each-group select="$allTemplateAssociation/*/templateAssociation[@templateId=$tid][@effectiveDate=$tef]/concept[@elementId = $elid]" group-by="concat(@ref,@effectiveDate)">
                <xsl:variable name="deid" select="@ref"/>
                <xsl:variable name="deed" select="@effectiveDate"/>
                <xsl:variable name="templateConcept" select="local:getConceptFlat($deid, $deed)" as="element(concept)?"/>
                <xsl:variable name="conceptIsInTransaction" as="xs:boolean">
                    <xsl:choose>
                        <xsl:when test="$rt/concept[@ref=$deid]">
                            <xsl:variable name="transactionConcept" select="local:getConcept($deid, $rt/concept[@ref=$deid]/@flexibility, $rt/@sourceDataset, $rt/@sourceDatasetFlexibility)" as="element(concept)"/>
                            <xsl:value-of select="exists($transactionConcept[@effectiveDate=$templateConcept/@effectiveDate])"/>
                        </xsl:when>
                        <xsl:otherwise>false</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="tt" select="$templateConcept/name[1]"/>
                <xsl:if test="$conceptIsInTransaction">
                    <!--xsl:attribute name="conceptId">
                        <xsl:value-of select="$ta"/>
                    </xsl:attribute-->
                    <concept xmlns="" ref="{$deid}" effectiveDate="{if ($templateConcept/@effectiveDate) then $templateConcept/@effectiveDate else $deed}">
                        <xsl:attribute name="refname">
                            <xsl:call-template name="doShorthandId">
                                <xsl:with-param name="id" select="$deid"/>
                            </xsl:call-template>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="string-length($tt)&gt;0">
                                <xsl:attribute name="conceptText" select="$tt"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:if test="false()">
                                    <!-- set this to true() if you want hints shown in the concept column -->
                                    <xsl:attribute name="conceptText">
                                        <xsl:text>****** template element id </xsl:text>
                                        <xsl:value-of select="$elid"/>
                                        <xsl:text> associated in template </xsl:text>
                                        <xsl:call-template name="doShorthandId">
                                            <xsl:with-param name="id" select="$tid"/>
                                        </xsl:call-template>
                                        <xsl:text> (</xsl:text>
                                        <xsl:value-of select="$tef"/>
                                        <xsl:text>) but no reference in representingTemplate found. </xsl:text>
                                        <xsl:text>All concept Ids found in templateAssociation: </xsl:text>
                                        <xsl:for-each select="$allTemplatesAssociations/*/templateAssociation[@templateId=$tid and @effectiveDate=$tef]/concept[@elementId=$elid]">
                                            <xsl:value-of select="@ref"/>
                                            <xsl:if test="position()!=last()">
                                                <xsl:text>, </xsl:text>
                                            </xsl:if>
                                        </xsl:for-each>
                                    </xsl:attribute>
                                </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:call-template name="doCommunity">
                            <xsl:with-param name="id" select="$deid"/>
                            <xsl:with-param name="rt" select="$rt"/>
                            <xsl:with-param name="tid" select="$tid"/>
                            <xsl:with-param name="tef" select="$tef"/>
                        </xsl:call-template>
                    </concept>
                </xsl:if>
            </xsl:for-each-group>
        </xsl:if>
    </xsl:template>
    <xd:doc>
        <xd:desc>Get community info for a given concept/@id</xd:desc>
        <xd:param name="id">Concept/@id to lookup up community info for</xd:param>
        <xd:param name="rt"/>
        <xd:param name="tid">Template/@id of the template we're in</xd:param>
        <xd:param name="tef">Template/@effectiveDate of the template we're in</xd:param>
    </xd:doc>
    <xsl:template name="doCommunity">
        <xsl:param name="id"/>
        <xsl:param name="rt"/>
        <xsl:param name="tid"/>
        <xsl:param name="tef"/>
        <xsl:if test="not(empty($id) or $id='')">
            <!-- Check every community-*.xml file that is a sibling to our input file. Do not recurse into dirs -->
            <xsl:for-each select="collection(iri-to-uri(concat($theBaseURI2DECOR,'?select=community-*.xml;recurse=no')))">
                <xsl:sort select="tokenize(document-uri(.), '/')[last()]"/>
                <xsl:variable name="communityfile" select="tokenize(document-uri(.), '/')[last()]"/>
                <xsl:variable name="communityitems" select="."/>
                <xsl:variable name="communityname" select="$communityitems/*/@name"/>
                <xsl:if test="count($communityitems//associations/association[object[@type='DE' and @ref=$id]]/data)&gt;0">
                    <xsl:variable name="comlabel" select="($communityitems/*/desc)[1]"/>
                    <community xmlns="" name="{$communityname}" label="{$comlabel}">
                        <xsl:for-each select="$communityitems//associations/association[object[@type='DE' and @ref=$id]]/data">
                            <xsl:variable name="typeAttr" select="@type"/>
                            <xsl:variable name="label" select="$communityitems/*/prototype/data[@type=$typeAttr]/@label"/>
                            <data type="{$typeAttr}" label="{$label}">
                                <xsl:copy-of select="node()"/>
                            </data>
                        </xsl:for-each>
                    </community>
                </xsl:if>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    <xd:doc>
        <xd:desc>Handle include in default instance</xd:desc>
        <xd:param name="rt"/>
        <xd:param name="tid">Template/@id of the template we're in</xd:param>
        <xd:param name="tef">Template/@effectiveDate of the template we're in</xd:param>
        <xd:param name="previousitemlabel"/>
        <xd:param name="doAttributes"/>
        <xd:param name="sofar">Array of templates found so far where every array item is concat(template/@id,'-',template/@effectiveDate)</xd:param>
        <xd:param name="templateFormat"/>
    </xd:doc>
    <xsl:template match="include" mode="createDefaultInstance">
        <xsl:param name="rt"/>
        <xsl:param name="tid"/>
        <xsl:param name="tef"/>
        <xsl:param name="previousitemlabel"/>
        <xsl:param name="doAttributes" select="false()" as="xs:boolean"/>
        <xsl:param name="sofar" as="xs:string*" required="yes"/>
        <xsl:param name="templateFormat" as="xs:string"/>
        <xsl:call-template name="logMessage">
            <xsl:with-param name="level" select="$logALL"/>
            <xsl:with-param name="msg">
                <xsl:text>template match="include" mode="createDefaultInstance" writing for template id=</xsl:text>
                <xsl:value-of select="ancestor::template/(@id|@ref)"/>
                <xsl:text> effectiveDate</xsl:text>
                <xsl:value-of select="ancestor::template/(@effectiveDate|@flexibility)"/>
                <xsl:text> name=</xsl:text>
                <xsl:value-of select="ancestor::template/@name"/>
                <xsl:text> displayName=</xsl:text>
                <xsl:value-of select="ancestor::template/@displayName"/>
                <xsl:text>
    </xsl:text>
                <xsl:value-of select="string-join(ancestor-or-self::*[ancestor::template]/concat(name(),'[',@name,']'),' / ')"/>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:variable name="rccontent" as="element()?">
            <xsl:call-template name="getRulesetContent">
                <xsl:with-param name="ruleset" select="@ref"/>
                <xsl:with-param name="flexibility" select="@flexibility"/>
                <xsl:with-param name="sofar" select="$sofar"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="itemlabel">
            <xsl:call-template name="getNewItemLabel">
                <xsl:with-param name="rc" select="$rccontent"/>
                <xsl:with-param name="default" select="$previousitemlabel"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$doAttributes">
                <xsl:apply-templates select="$rccontent/attribute" mode="createDefaultInstance">
                    <xsl:with-param name="sofar" select="$sofar, concat($rccontent/@id,'-',$rccontent/@effectiveDate)"/>
                    <xsl:with-param name="templateFormat" select="$templateFormat"/>
                </xsl:apply-templates>
                <xsl:apply-templates select="include" mode="createDefaultInstance">
                    <xsl:with-param name="rt" select="$rt"/>
                    <xsl:with-param name="tid" select="$tid"/>
                    <xsl:with-param name="tef" select="$tef"/>
                    <xsl:with-param name="previousitemlabel" select="$previousitemlabel"/>
                    <xsl:with-param name="doAttributes" select="true()"/>
                    <xsl:with-param name="sofar" select="$sofar, concat($rccontent/@id,'-',$rccontent/@effectiveDate)"/>
                    <xsl:with-param name="templateFormat" select="$templateFormat"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="count($rccontent/element|$rccontent/include|$rccontent/choice)=1">
                        <xsl:apply-templates select="$rccontent/element|$rccontent/include|$rccontent/choice" mode="createDefaultInstance">
                            <xsl:with-param name="rt" select="$rt"/>
                            <xsl:with-param name="tid" select="$rccontent/@id"/>
                            <xsl:with-param name="tef" select="$rccontent/@effectiveDate"/>
                            <xsl:with-param name="previousitemlabel" select="$itemlabel"/>
                            <xsl:with-param name="inheritedminimumMultiplicity" select="@minimumMultiplicity"/>
                            <xsl:with-param name="inheritedmaximumMultiplicity" select="@maximumMultiplicity"/>
                            <xsl:with-param name="inheritedConformance" select="@conformance"/>
                            <xsl:with-param name="inheritedIsMandatory" select="@isMandatory"/>
                            <xsl:with-param name="sofar" select="$sofar, concat($rccontent/@id,'-',$rccontent/@effectiveDate)"/>
                            <xsl:with-param name="templateFormat" select="$templateFormat"/>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="$rccontent/element|$rccontent/include|$rccontent/choice" mode="createDefaultInstance">
                            <xsl:with-param name="rt" select="$rt"/>
                            <xsl:with-param name="tid" select="$rccontent/@id"/>
                            <xsl:with-param name="tef" select="$rccontent/@effectiveDate"/>
                            <xsl:with-param name="previousitemlabel" select="$itemlabel"/>
                            <xsl:with-param name="sofar" select="$sofar, concat($rccontent/@id,'-',$rccontent/@effectiveDate)"/>
                            <xsl:with-param name="templateFormat" select="$templateFormat"/>
                        </xsl:apply-templates>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc>Create choice in default instance</xd:desc>
        <xd:param name="rt"/>
        <xd:param name="tid">Template/@id of the template we're in</xd:param>
        <xd:param name="tef">Template/@effectiveDate of the template we're in</xd:param>
        <xd:param name="previousitemlabel"/>
        <xd:param name="sofar">Array of templates found so far where every array item is concat(template/@id,'-',template/@effectiveDate)</xd:param>
        <xd:param name="templateFormat"/>
    </xd:doc>
    <xsl:template match="choice" mode="createDefaultInstance">
        <xsl:param name="rt"/>
        <xsl:param name="tid"/>
        <xsl:param name="tef"/>
        <xsl:param name="previousitemlabel"/>
        <xsl:param name="sofar" as="xs:string*" required="yes"/>
        <xsl:param name="templateFormat" as="xs:string"/>
        <xsl:call-template name="logMessage">
            <xsl:with-param name="level" select="$logALL"/>
            <xsl:with-param name="msg">
                <xsl:text>template match="choice" mode="createDefaultInstance" writing for template id=</xsl:text>
                <xsl:value-of select="ancestor::template/(@id|@ref)"/>
                <xsl:text> effectiveDate</xsl:text>
                <xsl:value-of select="ancestor::template/(@effectiveDate|@flexibility)"/>
                <xsl:text> name=</xsl:text>
                <xsl:value-of select="ancestor::template/@name"/>
                <xsl:text> displayName=</xsl:text>
                <xsl:value-of select="ancestor::template/@displayName"/>
                <xsl:text>
    </xsl:text>
                <xsl:value-of select="string-join(ancestor-or-self::*[ancestor::template]/concat(name(),'[',@name,']'),' / ')"/>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:variable name="cardconf" select="local:getCardConf(@minimumMultiplicity, @maximumMultiplicity, @conformance, @isMandatory)"/>
        <choice xmlns="">
            <xsl:copy-of select="@minimumMultiplicity|@maximumMultiplicity"/>
            <xsl:if test="string-length($cardconf)&gt;0">
                <xsl:attribute name="cardconf" select="$cardconf"/>
            </xsl:if>
            <xsl:apply-templates select="element|include|choice" mode="createDefaultInstance">
                <xsl:with-param name="rt" select="$rt"/>
                <xsl:with-param name="tid" select="$tid"/>
                <xsl:with-param name="tef" select="$tef"/>
                <xsl:with-param name="previousitemlabel" select="$previousitemlabel"/>
                <xsl:with-param name="sofar" select="$sofar"/>
                <xsl:with-param name="templateFormat" select="$templateFormat"/>
            </xsl:apply-templates>
        </choice>
    </xsl:template>
    <xd:doc>
        <xd:desc>Create vocabulary element based attributes in default instance</xd:desc>
        <xd:param name="sofar">Array of templates found so far where every array item is concat(template/@id,'-',template/@effectiveDate)</xd:param>
        <xd:param name="templateFormat"/>
    </xd:doc>
    <xsl:template match="vocabulary|property" mode="createDefaultInstance">
        <xsl:param name="sofar" as="xs:string*"/>
        <xsl:param name="templateFormat" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="name()='vocabulary'">
                <xsl:for-each select="@code|@codeSystem|@valueSet|@flexibility">
                    <xsl:attribute name="{name()}" select="."/>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Create attributes on element in default instance</xd:desc>
        <xd:param name="sofar">Array of templates found so far where every array item is concat(template/@id,'-',template/@effectiveDate)</xd:param>
        <xd:param name="templateFormat"/>
    </xd:doc>
    <xsl:template match="attribute" mode="createDefaultInstance">
        <xsl:param name="sofar" as="xs:string*"/>
        <xsl:param name="templateFormat" as="xs:string"/>
        <xsl:call-template name="logMessage">
            <xsl:with-param name="level" select="$logALL"/>
            <xsl:with-param name="msg">
                <xsl:text>template match="attribute" mode="createDefaultInstance" writing for template id=</xsl:text>
                <xsl:value-of select="ancestor::template/(@id|@ref)"/>
                <xsl:text> effectiveDate</xsl:text>
                <xsl:value-of select="ancestor::template/(@effectiveDate|@flexibility)"/>
                <xsl:text>
</xsl:text>
                <xsl:copy-of select="."/>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:for-each select="@classCode|@contextConductionInd|@contextControlCode|@determinerCode|@extension|@independentInd|@institutionSpecified|@inversionInd|@mediaType|@moodCode|@negationInd|@nullFlavor|@operator|@qualifier|@representation|@root|@typeCode|@unit|@use">
            <!-- cache attribute name and value -->
            <xsl:variable name="attname" select="name(.)"/>
            <xsl:variable name="attvalue" select="."/>
            <xsl:attribute name="{$attname}" select="$attvalue"/>
        </xsl:for-each>
        <xsl:if test="@name">
            <xsl:variable name="an" select="@name"/>
            <xsl:variable name="av" select="@value"/>
            <xsl:variable name="anPfx" select="if (contains($an,':')) then (substring-before($an,':')) else ('')"/>
            <xsl:variable name="anName" select="if (contains($an,':')) then (substring-after($an,':')) else ($an)"/>
            <xsl:variable name="dfltNS">
                <xsl:choose>
                    <xsl:when test="string-length($projectDefaultElementPrefix)=0">
                        <xsl:value-of select="'urn:hl7-org:v3'"/>
                    </xsl:when>
                    <xsl:when test="$projectDefaultElementPrefix='hl7:' or $projectDefaultElementPrefix='cda:'">
                        <xsl:value-of select="'urn:hl7-org:v3'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="namespace-uri-for-prefix(substring-before($projectDefaultElementPrefix,':'),/decor)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="anNS">
                <xsl:choose>
                    <xsl:when test="$anPfx='hl7' or $anPfx='cda'">
                        <xsl:value-of select="'urn:hl7-org:v3'"/>
                    </xsl:when>
                    <xsl:when test="$anPfx=''">
                        <xsl:value-of select="$dfltNS"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="namespace-uri-for-prefix($anPfx,$allDECOR)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="string-length($av)&gt;0 and string-length($anPfx)&gt;0">
                    <xsl:attribute name="{$an}" select="$av" namespace="{$anNS}"/>
                </xsl:when>
                <xsl:when test="string-length($av)=0 and string-length($anPfx)&gt;0">
                    <xsl:attribute name="{$an}" select="'…'" namespace="{$anNS}"/>
                </xsl:when>
                <xsl:when test="string-length($av)&gt;0">
                    <xsl:attribute name="{$an}" select="$av"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="{$an}" select="'…'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>add attribute to connect @id to (and add other properties while we're at it)</xd:desc>
        <xd:param name="tid">Template/@id of the template we're in</xd:param>
        <xd:param name="tef">Template/@effectiveDate of the template we're in</xd:param>
    </xd:doc>
    <xsl:template match="attribute" mode="createDefaultInstance2">
        <xsl:param name="tid"/>
        <xsl:param name="tef"/>
        <xsl:variable name="cardconf" select="local:getConformance(., $defaultLanguage)"/>
        <xsl:for-each select="@name|@classCode|@contextConductionInd|@contextControlCode|@determinerCode|@extension|@independentInd|@institutionSpecified|@inversionInd|@mediaType|@moodCode|@negationInd|@nullFlavor|@operator|@qualifier|@representation|@root|@typeCode|@unit|@use">
            <!-- cache attribute name and value -->
            <xsl:variable name="attname" select="if (name()='name') then . else (name())"/>
            <xsl:variable name="attvalue" select="if (name()='name') then ../@value else (.)"/>
            <attribute xmlns="" name="{$attname}">
                <xsl:if test="string-length($attvalue)&gt;0">
                    <xsl:attribute name="value" select="$attvalue"/>
                </xsl:if>
                <xsl:if test="string-length($cardconf)&gt;0">
                    <xsl:attribute name="cardconf" select="$cardconf"/>
                </xsl:if>
                <xsl:copy-of select="../@datatype"/>
                <xsl:if test="../@id">
                    <xsl:attribute name="elementId" select="../@id"/>
                    <xsl:attribute name="templateId" select="$tid"/>
                    <xsl:attribute name="templateEffectiveDate" select="$tef"/>
                </xsl:if>
            </attribute>
        </xsl:for-each>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
        <xd:param name="nestinglevel">The nesting level we are currently at</xd:param>
    </xd:doc>
    <xsl:template match="*" mode="createOutputRow">
        <xsl:param name="nestinglevel"/>
        <xsl:if test="not(self::community|self::concept|self::attribute)">
            <tr style="background-color:#eeeeee;" xmlns="http://www.w3.org/1999/xhtml">
                <td style="vertical-align: top;">
                    <table>
                        <tr>
                            <xsl:call-template name="doIndentLevel">
                                <xsl:with-param name="level" select="$nestinglevel"/>
                            </xsl:call-template>
                            <td>
                                <tt>
                                    <!--xsl:text><</xsl:text-->
                                    <xsl:choose>
                                        <xsl:when test="@withpredicate">
                                            <xsl:call-template name="outputPath">
                                                <xsl:with-param name="pathname" select="@withpredicate"/>
                                            </xsl:call-template>
                                        </xsl:when>
                                        <xsl:when test="@original">
                                            <xsl:call-template name="outputPath">
                                                <xsl:with-param name="pathname" select="@original"/>
                                            </xsl:call-template>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:call-template name="outputPath">
                                                <xsl:with-param name="pathname" select="name()"/>
                                            </xsl:call-template>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:for-each select="@* except (@conceptId|@conceptText|@label|@datatype|@cardconf|@original|@withpredicate|@minimumMultiplicity|@maximumMultiplicity|@conformance|@isMandatory)">
                                        <xsl:text> </xsl:text>
                                        <xsl:value-of select="name()"/>
                                        <xsl:text>="</xsl:text>
                                        <xsl:value-of select="."/>
                                        <xsl:text>"</xsl:text>
                                    </xsl:for-each>
                                    <!--xsl:text>></xsl:text-->
                                </tt>
                            </td>
                        </tr>
                    </table>
                </td>
                <td style="vertical-align: top;">
                    <xsl:value-of select="@datatype"/>
                </td>
                <td style="vertical-align: top;">
                    <xsl:value-of select="@cardconf"/>
                </td>
                <td style="vertical-align: top;">
                    <xsl:for-each select="concept">
                        <a>
                            <xsl:attribute name="href">
                                <xsl:value-of select="local:doHtmlName('TR', $projectPrefix, /instances/@id, /instances/@effectiveDate, @id, @effectiveDate, (), (), '.html', 'false')"/>
                            </xsl:attribute>
                            <xsl:call-template name="doShorthandId">
                                <xsl:with-param name="id" select="@ref"/>
                            </xsl:call-template>
                        </a>
                        <xsl:if test="position() != last()">
                            <br/>
                        </xsl:if>
                    </xsl:for-each>
                </td>
                <td style="vertical-align: top;">
                    <xsl:for-each select="concept">
                        <xsl:value-of select="@conceptText"/>
                        <xsl:if test="position() != last()">
                            <br/>
                        </xsl:if>
                    </xsl:for-each>
                </td>
                <td style="vertical-align: top;">
                    <xsl:value-of select="@label"/>
                </td>
            </tr>
            <xsl:for-each select="attribute[concept]">
                <tr style="background-color: #eeeeee;" xmlns="http://www.w3.org/1999/xhtml">
                    <td style="vertical-align: top;">
                        <table>
                            <tr>
                                <xsl:call-template name="doIndentLevel">
                                    <xsl:with-param name="level" select="$nestinglevel + 1"/>
                                    <xsl:with-param name="icon" select="false()"/>
                                </xsl:call-template>
                                <td>
                                    <tt>
                                        <xsl:call-template name="outputPath">
                                            <xsl:with-param name="pathname" select="name()"/>
                                        </xsl:call-template>
                                        <xsl:text> </xsl:text>
                                        <xsl:value-of select="@name"/>
                                        <xsl:text>="</xsl:text>
                                        <xsl:value-of select="@value"/>
                                        <xsl:text>"</xsl:text>
                                    </tt>
                                </td>
                            </tr>
                        </table>
                    </td>
                    <td style="vertical-align: top;">
                        <xsl:value-of select="@datatype"/>
                    </td>
                    <td style="vertical-align: top;">
                        <xsl:value-of select="@cardconf"/>
                    </td>
                    <td style="vertical-align: top;">
                        <xsl:for-each select="concept">
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:value-of select="local:doHtmlName('TR', $projectPrefix, /instances/@id, /instances/@effectiveDate, @ref, @effectiveDate, (), (), '.html', 'false')"/>
                                </xsl:attribute>
                                <xsl:call-template name="doShorthandId">
                                    <xsl:with-param name="id" select="@ref"/>
                                </xsl:call-template>
                            </a>
                            <xsl:if test="position() != last()">
                                <br/>
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                    <td style="vertical-align: top;">
                        <xsl:for-each select="concept">
                            <xsl:value-of select="@conceptText"/>
                            <xsl:if test="position() != last()">
                                <br/>
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                    <td style="vertical-align: top;">
                        <xsl:value-of select="@label"/>
                    </td>
                </tr>
            </xsl:for-each>
            <xsl:for-each select="concept[community]">
                <tr xmlns="http://www.w3.org/1999/xhtml">
                    <td>&#160;</td>
                    <td colspan="5" style="vertical-align: top; border: 1px solid #CCCCA3;">
                        <table width="100%">
                            <tr>
                                <xsl:text>Community mappings voor concept: </xsl:text>
                                <xsl:call-template name="doShorthandId">
                                    <xsl:with-param name="id" select="@ref"/>
                                </xsl:call-template>
                                <xsl:for-each select="@* except (@ref|@refname)">
                                    <xsl:text> </xsl:text>
                                    <xsl:value-of select="name()"/>
                                    <xsl:text>="</xsl:text>
                                    <xsl:value-of select="."/>
                                    <xsl:text>"</xsl:text>
                                </xsl:for-each>
                            </tr>
                            <xsl:for-each select="community">
                                <tr>
                                    <td style="vertical-align: top; background-color: #FFEAEA;">
                                        <p>
                                            <xsl:text>Community: </xsl:text>
                                            <b>
                                                <xsl:choose>
                                                    <xsl:when test="string-length(@label)&gt;0">
                                                        <xsl:value-of select="@label"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="@name"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </b>
                                        </p>
                                        <xsl:for-each select="data">
                                            <p>
                                                <div style="font-style: italic; width: 100%; border-bottom: 1px solid lightgrey; padding-bottom: 4px">
                                                    <xsl:choose>
                                                        <xsl:when test="string-length(@label)&gt;0">
                                                            <xsl:value-of select="@label"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="@type"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </div>
                                                <!--hr style="height: 0.2px;"/-->
                                                <xsl:copy-of select="node()"/>
                                            </p>
                                        </xsl:for-each>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </table>
                    </td>
                </tr>
            </xsl:for-each>
            <xsl:apply-templates select="*" mode="createOutputRow">
                <xsl:with-param name="nestinglevel" select="$nestinglevel+1"/>
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>
    <xd:doc>
        <xd:desc>All datatype files have a prefix that may be deducted from the /supportedDataTypes/@type. This helps copying the right parts to the includedir and calling those as inclusions from  the top level schematron.</xd:desc>
        <xd:param name="type">/supportedDataTypes/@type</xd:param>
    </xd:doc>
    <xsl:template name="SupportedDatatypeToPrefix">
        <xsl:param name="type" as="xs:string?"/>
        
        <xsl:choose>
            <xsl:when test="$type = 'hl7v3xml1'">DTr1_</xsl:when>
            <xsl:when test="$type = 'hl7v2.5xml'">DTv25_</xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="logMessage">
                    <xsl:with-param name="level" select="$logFATAL"/>
                    <xsl:with-param name="msg">
                        <xsl:text>+++ DECOR2schematron does not support datatypes of type </xsl:text>
                        <xsl:value-of select="@type"/>
                        <xsl:text> yet. Cannot continue.</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc>All datatype files have a directory they reside in that may be deducted from the /supportedDataTypes/@type. This helps copying the right parts to the includedir and calling those as inclusions from  the top level schematron.</xd:desc>
        <xd:param name="type">/supportedDataTypes/@type</xd:param>
    </xd:doc>
    <xsl:template name="SupportedDatatypeToDir">
        <xsl:param name="type" as="xs:string?"/>
        
        <xsl:choose>
            <xsl:when test="$type = 'hl7v3xml1'">coreschematrons/</xsl:when>
            <xsl:when test="$type = 'hl7v2.5xml'">coreschematrons-hl7v2.5xml/</xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="logMessage">
                    <xsl:with-param name="level" select="$logFATAL"/>
                    <xsl:with-param name="msg">
                        <xsl:text>+++ DECOR2schematron does not support datatypes of type </xsl:text>
                        <xsl:value-of select="@type"/>
                        <xsl:text> yet. Cannot continue.</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>