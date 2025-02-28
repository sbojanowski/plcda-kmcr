<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    
    DECOR2schematron
    Copyright (C) 2009-2014 Dr. Kai U. Heitmann, Alexander Henket
    
    This program is free software; you can redistribute it and/or modify it under the terms 
    of the GNU General Public License as published by the Free Software Foundation; 
    either version 3 of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
    See the GNU General Public License for more details.
    
    See http://www.gnu.org/licenses/gpl.html
  
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" xmlns:cda="urn:hl7-org:v3" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sch="http://www.ascc.net/xml/schematron" xmlns:local="http://art-decor.org/functions" xmlns:uuid="java:java.util.UUID" xmlns:jdate="java:java.util.Date" xmlns:System="java:java.lang.System" version="2.0" exclude-result-prefixes="#all">

    <!--
        parameters
        ==========
        to this XSLT and all invoked scripts
    -->
    <!-- check existence of  -->
    <xsl:variable name="parameterfile" select="'decor-parameters.xml'"/>
    <xsl:variable name="parameterfileavailable" select="doc-available($parameterfile)" as="xs:boolean"/>
    <xsl:param name="logLevel" as="xs:string">
        <xsl:choose>
            <xsl:when test="$parameterfileavailable=false()">
                <!-- default -->
                <xsl:value-of select="$logINFO"/>
            </xsl:when>
            <xsl:when test="document($parameterfile)/*/logLevel">
                <xsl:value-of select="document($parameterfile)/*/logLevel"/>
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
            <xsl:when test="document($parameterfile)/*/switchCreateSchematron1">
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
            <xsl:when test="document($parameterfile)/*/switchCreateSchematronWithWrapperIncludes1">
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
    <xsl:param name="switchCreateSchematronWithWarningsOnOpen" as="xs:boolean">
        <xsl:choose>
            <xsl:when test="$parameterfileavailable=false()">
                <!-- default -->
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:when test="document($parameterfile)/*/switchCreateSchematronWithWarningsOnOpen1">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <!-- create switchCreateSchematronClosed -->
    <xsl:param name="switchCreateSchematronClosed" as="xs:boolean">
        <xsl:choose>
            <xsl:when test="$parameterfileavailable=false()">
                <!-- default -->
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:when test="document($parameterfile)/*/switchCreateSchematronClosed1">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <!-- create switchCreateSchematronWithExplicitIncludes -->
    <xsl:param name="switchCreateSchematronWithExplicitIncludes" as="xs:boolean">
        <xsl:choose>
            <xsl:when test="$parameterfileavailable=false()">
                <!-- default -->
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:when test="document($parameterfile)/*/switchCreateSchematronClosed1">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when test="document($parameterfile)/*/switchCreateSchematronWithExplicitIncludes1">
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
            <xsl:when test="document($parameterfile)/*/switchCreateDocHTML1">
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
            <xsl:when test="document($parameterfile)/*/switchCreateDocSVG1">
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
            <xsl:when test="document($parameterfile)/*/switchCreateDocDocbook1">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
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
            <xsl:when test="document($parameterfile)/*/useLocalAssets1">
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
            <xsl:when test="document($parameterfile)/*/useLocalLogos1">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <!-- use latest version from ART -->
    <xsl:param name="useLatestDecorVersion" as="xs:boolean">
        <xsl:choose>
            <xsl:when test="$parameterfileavailable=false()">
                <!-- default -->
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:when test="document($parameterfile)/*/useLatestDecorVersion1">
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
            <xsl:when test="document($parameterfile)/*/useCustomRetrieve1/@hidecolumns">
                <xsl:value-of select="document($parameterfile)/*/useCustomRetrieve1/@hidecolumns"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'45ghi'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <!-- create artefacts without timestamp directories as we are in development -->
    <xsl:param name="inDevelopment" as="xs:boolean">
        <xsl:choose>
            <xsl:when test="$parameterfileavailable=false()">
                <!-- default -->
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:when test="document($parameterfile)/*/inDevelopment1">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <!-- cache project default language as fall back -->
    <xsl:param name="projectDefaultLanguage" select="//project/@defaultLanguage" as="xs:string"/>
    
    <!-- Changed by iEHR.eu - take into account version only (without releases) -->
    <xsl:param name="latestVersion" select="max(//project/version/xs:dateTime(@date))" as="xs:dateTime"/>
    <!-- get default language that overrides projectDefaultLanguage -->
    <xsl:param name="defaultLanguage" as="xs:string">
        <xsl:choose>
            <xsl:when test="$parameterfileavailable=true() and string-length(document($parameterfile)/*/defaultLanguage)>0">
                <xsl:value-of select="document($parameterfile)/*/defaultLanguage"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- default -->
                <xsl:value-of select="$projectDefaultLanguage"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <!-- create data type checks? -->
    <xsl:param name="switchCreateDatatypeChecks" as="xs:boolean">
        <xsl:choose>
            <xsl:when test="$parameterfileavailable=false()">
                <!-- default -->
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when test="document($parameterfile)/*/switchCreateDatatypeChecks1">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    
    <!-- List of custom logos to be used in html export -->
    <xsl:param name="customLogos">
    	<xsl:if test="$parameterfileavailable=true()">
    		<xsl:copy-of select="document($parameterfile)/*/customLogos/logo"/>
    	</xsl:if>
    </xsl:param>
	     
    <!-- create default instances in xml and html for representingTemplates? -->
    <xsl:param name="createDefaultInstancesForRepresentingTemplates" as="xs:boolean">
        <xsl:choose>
            <xsl:when test="$parameterfileavailable=false()">
                <!-- default -->
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:when test="document($parameterfile)/*/createDefaultInstancesForRepresentingTemplates1">
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
    <!-- wheter to always skip predication -->
    <xsl:param name="skipPredicateCreation" select="false()" as="xs:boolean"/>
    
    <!-- ADRAM deeplink prefix for issues etc -->
    <xsl:param name="artdecordeeplinkprefix" as="xs:string?">
        <xsl:choose>
            <xsl:when test="/decor/@deeplinkprefix">
                <xsl:value-of select="/decor/@deeplinkprefix"/>
            </xsl:when>
            <xsl:when test="$parameterfileavailable=true() and document($parameterfile)/*/artdecordeeplinkprefix">
                <xsl:value-of select="document($parameterfile)/*/artdecordeeplinkprefix/string()"/>
            </xsl:when>
        </xsl:choose>
    </xsl:param>
    
    <!-- Home page configuration (iEHR.eu extension) -->
    <xsl:param name="homePageSrc">
    	<xsl:if test="$parameterfileavailable=true()">
    		<xsl:value-of select="document($parameterfile)/*/homePage[@language=$defaultLanguage]/@src"/>
    	</xsl:if>
    </xsl:param>
    
    <!-- CDA examples configuration (iEHR.eu extension) -->
    <xsl:param name="examples">
    	<xsl:if test="$parameterfileavailable=true()">
    		<xsl:copy-of select="document($parameterfile)/*/examples/example"/>
    	</xsl:if>
    </xsl:param>
    
    <!-- Dictionaries configuration (iEHR.eu extension) -->
	<xsl:param name="dictionaries">
		<xsl:if test="$parameterfileavailable=true()">
			<xsl:copy-of select="document($parameterfile)/*/dictionaries/dictionary"/>
		</xsl:if>
	</xsl:param>
	
	<!-- Oid specification file name configuration -->
	<xsl:param name="oidSpecificationFileName">
		<xsl:if test="$parameterfileavailable=true()">
			<xsl:value-of select="document($parameterfile)/*/oidSpecificationFile/@src"/>
		</xsl:if>
	</xsl:param>
    
    <!-- -->
    <xsl:include href="iEHReu.DECOR2html.xsl"/>
    <xsl:include href="DECOR2docbook.xsl"/>
    <xsl:include href="DECOR-basics.xsl"/>
    <xsl:include href="DECOR-cardinalitycheck.xsl"/>
    <xsl:include href="DECOR-attributecheck.xsl"/>

    <!-- -->

    <xsl:output method="xml" indent="yes" version="1.0" encoding="UTF-8" exclude-result-prefixes="#all" name="xml"/>
    <xsl:output method="html" indent="yes" version="4.01" encoding="UTF-8" doctype-public="-//W3C//DTD HTML 4.01//EN" doctype-system="http://www.w3.org/TR/html4/strict.dtd"/>
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
    
    <!-- pattern definitions -->

    <xsl:variable name="INTdigits" select="'^-?[1-9][0-9]*$|^+?[0-9]*$'"/>
    <xsl:variable name="REALdigits" select="'^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$'"/>

    <xsl:variable name="OIDpattern" select="'^[0-2](\.(0|[1-9][0-9]*))*$'"/>
    <xsl:variable name="UUIDpattern" select="'^[0-9a-zA-Z]{8}-[0-9a-zA-Z]{4}-[0-9a-zA-Z]{4}-[0-9a-zA-Z]{4}-[0-9a-zA-Z]{12}$'"/>
    
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
                <xsl:text>&#10;</xsl:text>
                <xsl:text>    Parameter switchCreateSchematron: </xsl:text>
                <xsl:value-of select="$switchCreateSchematron"/>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>    Parameter switchCreateSchematronWithWrapperIncludes: </xsl:text>
                <xsl:value-of select="$switchCreateSchematronWithWrapperIncludes"/>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>    Parameter switchCreateSchematronWithWarningsOnOpen: </xsl:text>
                <xsl:value-of select="$switchCreateSchematronWithWarningsOnOpen"/>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>    Parameter switchCreateSchematronClosed: </xsl:text>
                <xsl:value-of select="$switchCreateSchematronClosed"/>
                <xsl:if test="$switchCreateSchematronClosed">
                    <xsl:text> -- NOTE: this setting overrides switchCreateSchematronWithWarningsOnOpen</xsl:text>
                </xsl:if>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>    Parameter switchCreateSchematronWithExplicitIncludes: </xsl:text>
                <xsl:value-of select="$switchCreateSchematronWithExplicitIncludes"/>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>    Parameter switchCreateDocHTML: </xsl:text>
                <xsl:value-of select="$switchCreateDocHTML"/>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>    Parameter switchCreateDocSVG: </xsl:text>
                <xsl:value-of select="$switchCreateDocSVG"/>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>    Parameter switchCreateDocDocbook: </xsl:text>
                <xsl:value-of select="$switchCreateDocDocbook"/>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>    Parameter useLocalAssets: </xsl:text>
                <xsl:value-of select="$useLocalAssets"/>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>    Parameter useLocalLogos: </xsl:text>
                <xsl:value-of select="$useLocalLogos"/>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>    Parameter inDevelopment: </xsl:text>
                <xsl:value-of select="$inDevelopment"/>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>    Parameter defaultLanguage: </xsl:text>
                <xsl:value-of select="$defaultLanguage"/>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>    Parameter switchCreateDatatypeChecks: </xsl:text>
                <xsl:value-of select="$switchCreateDatatypeChecks"/>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>    Parameter createDefaultInstancesForRepresentingTemplates: </xsl:text>
                <xsl:value-of select="$createDefaultInstancesForRepresentingTemplates"/>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>    Parameter artdecordeeplinkprefix: </xsl:text>
                <xsl:value-of select="$artdecordeeplinkprefix"/>
                <xsl:if test="string-length($artdecordeeplinkprefix)=0">
                    <xsl:text> &lt;-- WARNING: should not be empty!</xsl:text>
                </xsl:if>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>    Parameter logLevel: </xsl:text>
                <xsl:value-of select="$logLevel"/>
            </xsl:with-param>
        </xsl:call-template>

        <xsl:if test="$parameterfileavailable=false()">
            <xsl:call-template name="logMessage">
                <xsl:with-param name="level" select="$logINFO"/>
                <xsl:with-param name="msg">
                    <xsl:text>*** Creating decor-parameters.xml with default values</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:result-document format="xml" href="decor-parameters.xml">
                <decor-parameters xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="{$theAssetsDir}../decor-parameters.xsd">
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
                    <xsl:comment> &lt;defaultLanguage>nl-NL&lt;defaultLanguage> </xsl:comment>
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
                    <xsl:text>&#10;    </xsl:text>
                    <xsl:comment> log at level (ALL, DEBUG, INFO, WARN, ERROR, FATAL, OFF) </xsl:comment>
                    <logLevel>
                        <xsl:value-of select="$logLevel"/>
                    </logLevel>
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

            <!-- 
                copy all supported data types schematrons to the runtime environment
            -->
            <!-- test output
            <xsl:message terminate="yes">
                <x>
                    <e1>
                        <xsl:copy-of select="$supportedDatatypes"/>
                    </e1>
                    <e2>
                        <xsl:copy-of select="$supportedDatatypes2"/>
                    </e2>
                </x>
            </xsl:message>
            -->
            <xsl:for-each-group select="$supportedDatatypes/*" group-by="@name">
                <xsl:variable name="theDT" select="concat('DTr1_', @name, '.sch')"/>
                
                <xsl:call-template name="logMessage">
                    <xsl:with-param name="level" select="$logALL"/>
                    <xsl:with-param name="msg">
                        <xsl:value-of select="concat('coreschematrons/', $theDT)"/>
                        <xsl:text> - </xsl:text>
                        <xsl:value-of select="concat($theRuntimeDir, $theDT)"/>
                    </xsl:with-param>
                </xsl:call-template>
                
                <xsl:call-template name="doCopyFile">
                    <xsl:with-param name="from" select="concat('coreschematrons/', $theDT)"/>
                    <xsl:with-param name="to" select="concat($theRuntimeIncludeDir, $theDT)"/>
                </xsl:call-template>
                <xsl:text>&#10;</xsl:text>
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
                </xsl:choose>
            </xsl:if>

            <!-- 
                create one sch file for each scenario transaction representing template with a model
            -->

            <xsl:for-each select="$allScenarios/scenarios/scenario//transaction[@model]">

                <xsl:variable name="rlabel" select="@label"/>

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

                        <xsl:comment> Add extra namespaces </xsl:comment>

                        <!-- get the other "foreign" namespaces of the DECOR root element -->
                        <xsl:for-each select="namespace::node()">
                            <xsl:if test="not (name(.) = 'xsi') and not( . = 'urn:hl7-org:v3')">
                                <ns uri="{.}" prefix="{name(.)}"/>
                            </xsl:if>
                        </xsl:for-each>

                        <!-- do print copyright stuff etc -->
                        <xsl:apply-templates select="//project">
                            <xsl:with-param name="what">
                                <xsl:value-of select="concat('Schematron schema for ', name[@language=$defaultLanguage], ' (', $rlabel, ')')"/>
                            </xsl:with-param>
                        </xsl:apply-templates>

                        <xsl:comment> Include realm specific schematron </xsl:comment>
                        <xsl:if test="$switchCreateSchematronWithWrapperIncludes=true()">
                            <xsl:text>&#10;</xsl:text>
                            <xsl:choose>
                                <xsl:when test="$defaultLanguage='nl-NL'">
                                    <!-- Include wrapper schematrons -->
                                    <include href="include/DTr1_XML.NL.sch"/>
                                    <include href="include/transmission-wrapper.NL.sch"/>
                                    <include href="include/controlAct-wrapper.NL.sch"/>

                                    <pattern is-a="transmission-wrapper" id="{@model}-wrapper">
                                        <param name="element" value="{concat($projectDefaultElementNamespace, @model)}"/>
                                    </pattern>

                                    <pattern is-a="controlAct-wrapper" id="{@model}-controlAct">
                                        <param name="element" value="{concat($projectDefaultElementNamespace, @model, '/', $projectDefaultElementNamespace, 'ControlActProcess')}"/>
                                    </pattern>

                                    <pattern>
                                        <!-- profileId -->
                                        <rule context="{concat($projectDefaultElementNamespace, @model, '/', $projectDefaultElementNamespace, 'profileId')}">
                                            <extends rule="II"/>
                                            <assert role="error" test="@root='2.16.840.1.113883.2.4.3.11.1' and @extension='810'">In de transmission wrapper moet het element profileId worden gevuld met de waarde '810'</assert>
                                        </rule>
                                    </pattern>
                                </xsl:when>
                                <xsl:otherwise>
                                    <!-- nothing to be included here
                                    2DO: multi lang support
                                -->
                                    <xsl:comment> none </xsl:comment>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>

                        <xsl:comment> Include datatype abstract schematrons </xsl:comment>
                        <xsl:text>&#10;</xsl:text>

                        <!-- this is the include directory -->
                        <xsl:variable name="theIncludeDir" select="concat('include', '/')"/>

                        <pattern>
                            <xsl:for-each select="$supportedDatatypes/*">
                                <xsl:variable name="theDT" select="concat('DTr1_', @name, '.sch')"/>
                                <include href="{$theIncludeDir}{$theDT}"/>
                                <xsl:text>&#10;</xsl:text>
                            </xsl:for-each>
                        </pattern>

                        <xsl:text>&#10;</xsl:text>
                        <xsl:text>&#10;</xsl:text>

                        <!-- 2DO REALM SPECIFIC SCHEMATRON INCLUDES -->

                        <xsl:comment>
                            <xsl:text> Include the project schematrons related to scenario </xsl:text>
                            <xsl:value-of select="$rlabel"/>
                            <xsl:text> </xsl:text>
                        </xsl:comment>
                        <xsl:text>&#10;&#10;</xsl:text>

                        <!-- 
                            a transaction with a model has 0..1 representingTemplate ref's
                            this template is to be included anyway, if present
                            if it has no context (because then it will be included later with context)
                        -->
                        <xsl:for-each select="representingTemplate[@ref]">
                            <xsl:variable name="rtid" select="@ref"/>
                            <xsl:variable name="rtflex" select="if (@flexibility) then (@flexibility) else ('dynamic')"/>
                            <xsl:variable name="rccontent">
                                <xsl:call-template name="getRulesetContent">
                                    <xsl:with-param name="ruleset" select="$rtid"/>
                                    <xsl:with-param name="flexibility" select="$rtflex"/>
                                </xsl:call-template>
                            </xsl:variable>

                            <xsl:if test="$rccontent/template">
                                <xsl:variable name="rtin" select="$rccontent/template/@name"/>
                                <xsl:variable name="rted" select="$rccontent/template/@effectiveDate"/>
                                <!-- a template exists, include it -->
                                <xsl:comment><xsl:text> </xsl:text><xsl:value-of select="$rtin"/><xsl:text> </xsl:text></xsl:comment>
                                <xsl:text>&#10;</xsl:text>
                                <include href="{$theIncludeDir}{$rtid}-{replace($rted,':','')}.sch"/>
                                <xsl:text>&#10;</xsl:text>
                            </xsl:if>

                            <xsl:variable name="templatesInThisRepresentingTemplate">
                                <xsl:if test="$rccontent/template">
                                    <xsl:call-template name="getAssociatedTemplates">
                                        <xsl:with-param name="rccontent" select="$rccontent/template"/>
                                    </xsl:call-template>
                                </xsl:if>
                            </xsl:variable>
                            <xsl:variable name="currentTemplateReferenceCount" select="count($templatesInThisRepresentingTemplate//template)"/>

                            <xsl:call-template name="logMessage">
                                <xsl:with-param name="level" select="$logINFO"/>
                                <xsl:with-param name="msg">
                                    <xsl:text>*** Benchmarking Indicator For Transaction '</xsl:text>
                                    <xsl:value-of select="parent::transaction/name[@language=$defaultLanguage][1]"/>
                                    <xsl:text>': </xsl:text>
                                    <xsl:value-of select="$currentTemplateReferenceCount"/>
                                </xsl:with-param>
                            </xsl:call-template>

                            <!-- all templates with an explicit context as a template id, latest version only -->

                            <!-- store includes and phase in a variable first -->
                            <xsl:variable name="tobeincluded">
                                <xsl:for-each-group select="$allTemplates/*/ref" group-by="@ref">
                                    <xsl:sort select="@ref"/>
                                    <xsl:if test="not(@duplicateOf) and (template/context/@id='*' or template/context/@id='**')">
                                        <xsl:variable name="tid" select="template/@id"/>
                                        <xsl:variable name="tin" select="template/@name"/>
                                        <xsl:variable name="tif" select="template/@effectiveDate"/>
                                        <xsl:variable name="tIsNewestForId" select="parent::ref/@newestForId"/>
                                        <xsl:if test="count($allScenarios//representingTemplate[@id=$tid or @ref=$tid][((not(@flexibility) or @flexibility='dynamic') and $tIsNewestForId) or @flexibility=$tif])=0">
                                            <!-- using id of ref is for backward compatibility -->
                                            <!-- a template exists and is not a representingTemplate,  -->

                                            <xsl:if test="$switchCreateSchematronWithExplicitIncludes=false() or $templatesInThisRepresentingTemplate//template[@id=$tid][@effectiveDate=$tif]">
                                                <!-- 
                                                    still in testing mode...
                                                    it is part of it, include it as an include 
                                                -->
                                                <xsl:comment><xsl:text> </xsl:text><xsl:value-of select="$tin"/><xsl:text> </xsl:text></xsl:comment>
                                                <include href="{$theIncludeDir}{$tid}-{replace($tif,':','')}.sch"/>
                                                <xsl:text>&#10;</xsl:text>
                                                <!-- 
                                                    add it as a selectable phase, also to keep used memory per phase 
                                                    and not all in one for large projects with many templates 
                                                -->
                                                <phase id="{$tin}">
                                                    <active pattern="template-{$tid}-{replace($tif,':','')}"/>
                                                </phase>
                                                <xsl:text>&#10;</xsl:text>
                                            </xsl:if>
                                        </xsl:if>
                                    </xsl:if>
                                </xsl:for-each-group>
                            </xsl:variable>

                            <xsl:text>&#10;</xsl:text>
                            <xsl:comment> Include schematrons from templates with explicit * or ** context (but no representing templates), only those used in scenario template </xsl:comment>
                            <xsl:text>&#10;</xsl:text>

                            <!-- TODO: $currentTemplateReferenceCount yields totally different numbers than $overallTemplateReferenceCount. -->
                            <!-- For reference: Jeugdgezondheidszorg has oTRC of 1286 and cTRC of 599 -->
                            <xsl:if test="($switchCreateSchematronWithExplicitIncludes=false() and $overallTemplateReferenceCount >= 1000) or 
                                ($switchCreateSchematronWithExplicitIncludes=true() and $currentTemplateReferenceCount >= 500)">
                                <!-- 
                                    rough estimation: if benchmarker too high, use phases to prevent too
                                    much memory to be used for validation because it is done stepwise 
                                -->
                                <!-- emit phases -->
                                <xsl:text>&#10;</xsl:text>
                                <xsl:comment> phases first </xsl:comment>
                                <xsl:text>&#10;</xsl:text>
                                <xsl:copy-of select="$tobeincluded/*[name()='phase']"/>
                            </xsl:if>

                            <!-- emit includes -->
                            <xsl:text>&#10;</xsl:text>
                            <xsl:text>&#10;</xsl:text>
                            <xsl:text>&#10;</xsl:text>
                            <xsl:comment> includes </xsl:comment>
                            <xsl:text>&#10;</xsl:text>
                            <xsl:for-each select="$tobeincluded/*[name()='include']|$tobeincluded/comment()">
                                <xsl:copy-of select="self::node()"/>
                                <xsl:if test="self::comment() and position()!=last()">
                                    <xsl:text>&#10;</xsl:text>
                                </xsl:if>
                            </xsl:for-each>

                        </xsl:for-each>

                        <xsl:text>&#10;&#10;</xsl:text>

                    </schema>

                </xsl:result-document>

            </xsl:for-each>

            <!-- 
                apply transformation to rules in DECOR file, make Runtime Environment"
            -->

            <xsl:apply-templates select="decor"/>

            <!-- a little milestoning -->
            <xsl:call-template name="logMessage">
                <xsl:with-param name="level" select="$logINFO"/>
                <xsl:with-param name="msg">
                    <xsl:text>*** Creating Schematron mapping file</xsl:text>
                </xsl:with-param>
            </xsl:call-template>

            <xsl:variable name="modelList" select="distinct-values($allScenarios/scenarios/scenario//transaction/@model)"/>
            <xsl:variable name="dfltNS">
                <xsl:choose>
                    <xsl:when test="string-length($projectDefaultElementNamespace)=0">
                        <xsl:value-of select="'urn:hl7-org:v3'"/>
                    </xsl:when>
                    <xsl:when test="$projectDefaultElementNamespace='hl7:' or $projectDefaultElementNamespace='cda:'">
                        <xsl:value-of select="'urn:hl7-org:v3'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="namespace-uri-for-prefix(substring-before($projectDefaultElementNamespace,':'),/decor)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <xsl:result-document href="{$theRuntimeDir}{$projectPrefix}instance2schematron.xml" format="xml">
                <xsl:comment> Used to map an instance to a specific Schematron. How to read:
    - For every template-id that is used in instances there is an element map, e.g.
      &lt;map model="REPC_IN004110UV01" namespace="urn:hl7-org:v3" templateRoot="2.16.840.1.113883.2.4.6.10.90.59" sch="peri20-counseling-fase-1c.sch" schsvrl="peri20-counseling-fase-1c.xsl"/&gt;
      
      - @model       - optional    - hint as to the XML Schema that could be used
      - @namespace   - mandatory   - default namespace-uri() of the project and of the instance unless specified otherwise
      - templateRoot - mandatory   - in HL7v3 this would be an OID. In other instance types it might be something else, but then this mapping file might need adjusted setup
      
      One of the following is required, normally schsvrl makes sense:
      - @schsvrl     - conditional - path+file name of the SVRL XSL. The path should be relative to this index/map file
      - @schtext     - conditional - path+file name of the Text XSL. The path should be relative to this index/map file
      - @sch         - conditional - path+file name of the original Schematron file. The path should be relative to this index/map file
        
      Note that the same template may be part of multiple transactions, hence multiple map element could be present for the same template. The attached Schematron
      will have different names, but will have the exact same rules (same template, same rules) hence only the first match is needed for validation.
      
    - As final fallback, when no template-id is found in the instance, code should rely on root element of the instance to determine the Schematron file name ... </xsl:comment>
                <xsl:text>&#10;</xsl:text>
                <mappings>
                    <xsl:for-each select="$modelList">
                        <xsl:variable name="model" select="."/>
                        <xsl:variable name="modelPfx" select="if (contains($model,':')) then (substring-before(.,':')) else ('')"/>
                        <xsl:variable name="modelName" select="if (contains($model,':')) then (substring-after(.,':')) else ($model)"/>
                        <xsl:variable name="modelNS">
                            <xsl:choose>
                                <xsl:when test="$modelPfx='hl7' or $modelPfx='cda'">
                                    <xsl:value-of select="'urn:hl7-org:v3'"/>
                                </xsl:when>
                                <xsl:when test="$modelPfx=''">
                                    <xsl:value-of select="$dfltNS"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="namespace-uri-for-prefix($modelPfx,$allScenarios/scenarios/scenario//transaction[@model=$model])"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>

                        <xsl:for-each select="$allScenarios/scenarios/scenario//transaction[@model=$model]/representingTemplate[@ref]">
                            <xsl:variable name="rlabel" select="parent::transaction/@label"/>
                            <xsl:variable name="tref" select="@ref"/>
                            <xsl:variable name="tflex" select="@flexibility"/>
                            <xsl:variable name="rccontent">
                                <xsl:call-template name="getRulesetContent">
                                    <xsl:with-param name="ruleset" select="$tref"/>
                                    <xsl:with-param name="flexibility" select="$tflex"/>
                                </xsl:call-template>
                            </xsl:variable>

                            <xsl:variable name="tid" select="$rccontent/template/@id"/>
                            <xsl:variable name="tname" select="$rccontent/template/@name"/>
                            <xsl:if test="string-length($tid)>0">
                                <xsl:text>&#10;</xsl:text>
                                <xsl:comment><xsl:text> template name: </xsl:text><xsl:value-of select="$tname"/><xsl:text> </xsl:text></xsl:comment>
                                <map model="{$modelName}" namespace="{$modelNS}" templateRoot="{$tid}" sch="{$projectPrefix}{$rlabel}.sch" schsvrl="{$projectPrefix}{$rlabel}.xsl"/>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:for-each>
                </mappings>
            </xsl:result-document>
        </xsl:if>

        <!--
            rendered all DECOR objects as HTML using special stylesheet, write it to html dir as index.html
        -->

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

            <meta HTTP-EQUIV="Refresh" Content="0; URL={$theHtmlDir}index.html"> </meta>
            <meta name="robots" content="noindex, nofollow"> </meta>
            <meta http-equiv="expires" content="0"> </meta>

        </xsl:if>

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
            <xsl:call-template name="convertDECOR2DOCBOOK"/>
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
                <xsl:variable name="rccontent">
                    <xsl:call-template name="getRulesetContent">
                        <xsl:with-param name="ruleset" select="$tid"/>
                        <xsl:with-param name="flexibility" select="$tflex"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="tef" select="$rccontent/template/@effectiveDate"/>
                <xsl:variable name="tcnt" select="count($rccontent/template)"/>
                <xsl:choose>
                    <xsl:when test="$tcnt=1">
                        <!-- Build instances first leaving references in for the second round of (fairly simple) processing
                            The second step builds child elements under relevant elements. We cannot do that in one go
                            because includes that reference templates that start with <attributes .../> would create
                            attributes after the element is already closed.
                        -->
                        <xsl:variable name="instancesStep1">
                            <instances>
                                <xsl:copy-of select="parent::transaction/@*" copy-namespaces="no"/>
                                <xsl:apply-templates select="$rccontent/template" mode="createDefaultInstance">
                                    <xsl:with-param name="rt" select="."/>
                                </xsl:apply-templates>
                            </instances>
                        </xsl:variable>
                        <!-- Build instances -->
                        <xsl:variable name="instances">
                            <xsl:apply-templates select="$instancesStep1" mode="resolveInstanceElements">
                                <xsl:with-param name="rt" select="."/>
                            </xsl:apply-templates>
                        </xsl:variable>
                        
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
                        
                        <xsl:variable name="fname" select="concat('instance-', $trid, if (matches($treff,'^\d{4}')) then concat('-',replace($treff,':','')) else () )"/>
                        <xsl:result-document href="{$theHtmlDir}{$projectPrefix}{$fname}.xml" format="xml" indent="yes">
                            <xsl:copy-of select="$instances/*"/>
                        </xsl:result-document>
                        <xsl:result-document href="{$theHtmlDir}{$projectPrefix}{$fname}.html" format="html" indent="yes" exclude-result-prefixes="#all" doctype-public="-//W3C//DTD XHTML 1.1//EN" doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
                            <html xmlns="http://www.w3.org/1999/xhtml">
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

                                    <style type="text/css">
                                        th,
                                        td,
                                        span,
                                        div{
                                            font-family:Verdana;
                                            font-size:11px;
                                        }</style>
                                </head>

                                <xsl:text>&#10;&#10;</xsl:text>

                                <body>
                                    <xsl:for-each select="$instances/*/*">
                                        <div class="landscapeshrinktofit">
                                            <h1>
                                                <xsl:value-of select="$rccontent/template/@displayName"/>
                                                <xsl:text> (</xsl:text>
                                                <xsl:value-of select="@name"/>
                                                <xsl:text>)</xsl:text>
                                            </h1>
                                            <table cellpadding="5">
                                                <tr bgcolor="#bbbbbb">
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
                                <xsl:text>'. Need exactly 1 template, found </xsl:text>
                                <xsl:value-of select="$tcnt"/>
                                <xsl:text> (id '</xsl:text>
                                <xsl:value-of select="$tid"/>
                                <xsl:text>' and calculated effectiveDate='</xsl:text>
                                <xsl:value-of select="$tef"/>
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
    
    <!-- Get templateList with template copies of all templates that are tied to the current template -->
    <xsl:template name="getAssociatedTemplates" as="element()">
        <xsl:param name="rccontent" as="element(template)" required="yes"/>
        
        <xsl:variable name="listWithDuplicates">
            <templateList>
                <!-- template id="" name="" effectiveDate="" -->
                <xsl:for-each select="$rccontent//(element[@contains]|include)">
                    <xsl:call-template name="getTemplateList">
                        <xsl:with-param name="sofar" select="concat($rccontent/template/@id,'-',$rccontent/template/@effectiveDate)"/>
                    </xsl:call-template>
                </xsl:for-each>
            </templateList>
        </xsl:variable>
        <templateList>
            <xsl:for-each select="$listWithDuplicates/*/template">
                <xsl:variable name="ttid" select="@id"/>
                <xsl:variable name="ttif" select="@effectiveDate"/>
                <xsl:if test="not(preceding-sibling::template[@id=$ttid][@effectiveDate=$ttif])">
                    <xsl:copy-of select="."/>
                </xsl:if>
            </xsl:for-each>
        </templateList>
    </xsl:template>
    
    <xsl:template name="getTemplateList">
        <xsl:param name="sofar"/>
        
        <xsl:choose>
            <xsl:when test="self::element[@contains] | self::include">
                <xsl:variable name="tid" select="@contains|@ref"/>
                <xsl:variable name="tflex" select="if (@flexibility) then (@flexibility) else ('dynamic')"/>
                <xsl:variable name="rccontent">
                    <xsl:call-template name="getRulesetContent">
                        <xsl:with-param name="ruleset" select="$tid"/>
                        <xsl:with-param name="flexibility" select="$tflex"/>
                    </xsl:call-template>
                </xsl:variable>
                
                <xsl:if test="not(contains($sofar,concat($rccontent/template/@id,'-',$rccontent/template/@effectiveDate)))">
                    <template id="{$rccontent/template/@id}" name="{$rccontent/template/@name}" effectiveDate="{$rccontent/template/@effectiveDate}" standalone="{exists($rccontent/template/context[@id])}"/>
                    
                    <xsl:for-each select="$rccontent//(element[@contains]|include)">
                        <xsl:call-template name="getTemplateList">
                            <xsl:with-param name="sofar" select="concat($sofar,' ',$rccontent/template/@id,'-',$rccontent/template/@effectiveDate)"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:if>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="project">
        <xsl:param name="what"/>
        <!-- print copyright stuff etc -->
        <xsl:comment>
            <xsl:text>&#10;==================================</xsl:text>
            <xsl:text>&#10;</xsl:text>
            <xsl:value-of select="$what"/>
            <xsl:text>&#10;&#10;Project: </xsl:text>
            <xsl:value-of select="@name"/>
            <xsl:for-each select="//project/copyright">
                <xsl:text>&#10;&#10;Copyright </xsl:text>

                <xsl:value-of select="@years"/>
                <xsl:text> by </xsl:text>
                <xsl:value-of select="@by"/>
            </xsl:for-each>
            <xsl:text>&#10;&#10;</xsl:text>
            <xsl:for-each select="author">
                <xsl:text>&#10;Author: </xsl:text>
                <xsl:value-of select="text()"/>
            </xsl:for-each>
            <xsl:text>&#10;&#10;Version information:</xsl:text>
            <xsl:for-each select="version">
                <xsl:text>&#10;  </xsl:text>
                <xsl:value-of select="@date"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="@by"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="@desc"/>
            </xsl:for-each>
            <xsl:text>&#10;&#10;DISCLAIMER:&#10;</xsl:text>
            <xsl:value-of select="$disclaimer"/>
            <xsl:text>&#10;&#10;WARNING:&#10;</xsl:text>
            <xsl:value-of select="$warning"/>
            <xsl:text>&#10;&#10;Creation date: </xsl:text>
            <xsl:choose>
                <xsl:when test="$inDevelopment=true()">
                    <xsl:text>(in development)</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="dateTime(current-date(), current-time())"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>&#10;==================================</xsl:text>
            <xsl:text>&#10;&#10;</xsl:text>
        </xsl:comment>
    </xsl:template>

    <xsl:template match="decor">

        <!--
            apply the generation of templates for all template definitions
            don't do that for duplicates of another template and don't do
            that for templates that do not have a context defined
            2DO recent version only only multiple versions! 
        -->

        <xsl:for-each select="$allTemplates/*/ref">
            <xsl:if test="not(@duplicateOf) and ( exists(template/context) and exists(template/@id) )">
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
        

        <!-- 
            
            extract all value set (references) to runtime directory 
        
        -->
        
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
            <xsl:variable name="id" select="(@id|@ref)"/>
            <xsl:variable name="efd" select="@effectiveDate"/>
            <xsl:variable name="isNewest" select="$efd=max($allValueSets/*/valueSet[(@id|@ref)=$id]/xs:dateTime(@effectiveDate))"/>
            
            <xsl:call-template name="logMessage">
                <xsl:with-param name="level" select="$logDEBUG"/>
                <xsl:with-param name="msg">
                    <xsl:text>*** SCH vocab file: name='</xsl:text>
                    <xsl:value-of select="@name"/>
                    <xsl:text>' id='</xsl:text>
                    <xsl:value-of select="$id"/>
                    <xsl:text>' effectiveDate='</xsl:text>
                    <xsl:value-of select="$efd"/>
                    <xsl:text>'</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
            
            <xsl:result-document href="{$theRuntimeIncludeDir}voc-{$id}-{replace($efd,':','')}.xml" format="xml">
                <!-- do print copyright stuff etc -->
                <xsl:apply-templates select="//project">
                    <xsl:with-param name="what">
                        <xsl:value-of select="concat('Value Set ', $id, ' (STATIC ', $efd, ')')"/>
                    </xsl:with-param>
                </xsl:apply-templates>
                <valueSets>
                    <xsl:copy-of select="."/>
                </valueSets>
            </xsl:result-document>
            <xsl:if test="$isNewest=true()">
                <xsl:result-document href="{$theRuntimeIncludeDir}voc-{$id}-DYNAMIC.xml" format="xml">
                    <!-- do print copyright stuff etc -->
                    <xsl:apply-templates select="//project">
                        <xsl:with-param name="what">
                            <xsl:value-of select="concat('Value Set ', $id, ' (DYNAMIC) as of ', $efd)"/>
                        </xsl:with-param>
                    </xsl:apply-templates>
                    <valueSets>
                        <xsl:copy-of select="."/>
                    </valueSets>
                </xsl:result-document>
            </xsl:if>
        </xsl:for-each-group>
        
    </xsl:template>

    <xsl:template match="template" mode="GEN">
        
        <xsl:call-template name="logMessage">
            <xsl:with-param name="level" select="$logDEBUG"/>
            <xsl:with-param name="msg">
                <xsl:text>+++ xsl:template mode GEN template=</xsl:text>
                <xsl:value-of select="@name"/>
                <xsl:text> effectiveDate=</xsl:text>
                <xsl:value-of select="@effectiveDate"/>
                <xsl:text> id=@id</xsl:text>
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
            <xsl:value-of select="
                $allScenarios//representingTemplate[@ref=$tid and (@flexibility=$ted or (@flexibility='dynamic' and $isNewestId) or (not(@flexibility) and $isNewestId))] or 
                $allScenarios//representingTemplate[@ref=$tnm and (@flexibility=$ted or (@flexibility='dynamic' and $isNewestName) or (not(@flexibility) and $isNewestName))]
            "/>
        </xsl:variable>
        
        <xsl:result-document href="{$theRuntimeIncludeDir}{$uniqueId}.sch" format="xml">

            <xsl:apply-templates select="//project">
                <xsl:with-param name="what">
                    <xsl:value-of select="concat($uniqueId, ' (fragment schematron) &#10;  ', @name, ' ')"/>
                    <xsl:call-template name="doDescription">
                        <xsl:with-param name="ns" select="desc"/>
                        <!--<xsl:with-param name="lang" select="$defaultLanguage"/>-->
                    </xsl:call-template>
                </xsl:with-param>
            </xsl:apply-templates>

            <xsl:variable name="comment">
                <xsl:text>&#10;</xsl:text>
                <xsl:text>Template derived pattern</xsl:text>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>===========================================</xsl:text>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>ID: </xsl:text>
                <xsl:value-of select="@id"/>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>Name: </xsl:text>
                <xsl:value-of select="if (string-length(@displayName)>0) then @displayName else @name"/>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>Description: </xsl:text>
                <xsl:value-of select="substring(string-join(desc[1]//text(),' '),1, 1000)"/>
                <xsl:text>&#10;</xsl:text>
            </xsl:variable>
            <xsl:comment select="$comment"/>
            <xsl:text>&#10;</xsl:text>

            <pattern xmlns="http://purl.oclc.org/dsdl/schematron" id="template-{$uniqueId}">
                <title>
                    <xsl:value-of select="if (string-length(@displayName)>0) then @displayName else @name"/>
                </title>
                <xsl:for-each select=".">
                    <xsl:call-template name="doTemplateRules">
                        <xsl:with-param name="rc" select="."/>
                        <xsl:with-param name="isClosed" select="if ($switchCreateSchematronClosed=true() or string(@isClosed)='true') then (true()) else (false())"/>
                        <xsl:with-param name="nestinglevel" select="0"/>
                        <xsl:with-param name="checkIsClosed" select="false()"/>
                    </xsl:call-template>
                    <xsl:if test="$isTopLevelTemplate=true()">
                        <!--<xsl:variable name="templatesInThisRepresentingTemplate">
                            <xsl:call-template name="getAssociatedTemplates">
                                <xsl:with-param name="rccontent" select="."/>
                            </xsl:call-template>
                        </xsl:variable>-->
                        <xsl:for-each select=".">
                        <!--<xsl:for-each select=". | $templatesInThisRepresentingTemplate//template[@standalone='true']">-->
                            <xsl:variable name="rccontent">
                                <xsl:choose>
                                    <xsl:when test="@standalone">
                                        <xsl:call-template name="getRulesetContent">
                                            <xsl:with-param name="ruleset" select="@id"/>
                                            <xsl:with-param name="flexibility" select="@effectiveDate"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:copy-of select="."/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:call-template name="doTemplateRules">
                                <xsl:with-param name="rc" select="$rccontent/template"/>
                                <xsl:with-param name="isClosed" select="if ($switchCreateSchematronClosed=true() or $rccontent/template[@isClosed='true']) then (true()) else (false())"/>
                                <xsl:with-param name="nestinglevel" select="0"/>
                                <xsl:with-param name="checkIsClosed" select="$isTopLevelTemplate"/>
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:if>
                </xsl:for-each>
            </pattern>

        </xsl:result-document>

    </xsl:template>

    <xsl:template name="SCH">

        <!-- Check based on specical schematron asserts -->

        <xsl:param name="context" select="context/@path"/>

        <!-- item reference label -->
        <xsl:param name="itemlabel" select="item/@label"/>

        <!-- item = free text describing the item for display in case of an error -->
        <!-- 2DO multiple language desc -->
        <xsl:param name="item" select="item/desc[@language=$defaultLanguage or not(@language)][1]"/>

        <!-- pseudo pathname for display in case of an error -->
        <xsl:param name="pPath" select="pathHint/@text"/>

        <!-- pathname = node / xpath to check -->
        <xsl:param name="pathname" select="pathname/@path"/>

        <!-- get or set unique ID for this pattern -->
        <xsl:variable name="uniqueId">
            <xsl:choose>
                <xsl:when test="string-length(@uniqueId)=0">
                    <xsl:value-of select="$projectPrefix"/>
                    <xsl:value-of select="generate-id()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@uniqueId"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="comment">
            <xsl:text>&#10;</xsl:text>
            <xsl:text>Check based on special schematron asserts</xsl:text>
            <xsl:text>&#10;</xsl:text>
            <xsl:text>=========================================</xsl:text>
            <xsl:text>&#10;</xsl:text>
            <xsl:text>Item: </xsl:text>
            <xsl:value-of select="$itemlabel"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="$item"/>
            <xsl:text> - scenario(s): </xsl:text>
            <xsl:value-of select="./@scenario"/>
            <xsl:text>&#10;</xsl:text>
            <xsl:text>Context: </xsl:text>
            <xsl:value-of select="$context"/>
            <xsl:text>&#10;</xsl:text>
            <xsl:text>Id: </xsl:text>
            <xsl:value-of select="$uniqueId"/>
            <xsl:text>&#10;</xsl:text>
        </xsl:variable>
        <xsl:comment select="$comment"/>
        <xsl:text>&#10;</xsl:text>

        <pattern xmlns="http://purl.oclc.org/dsdl/schematron" id="{$uniqueId}">
            <title>
                <xsl:value-of select="$item"/>
                <xsl:text> - scenario(s): </xsl:text>
                <xsl:value-of select="./@scenario"/>
            </title>
            <xsl:text>&#10;</xsl:text>

            <xsl:variable name="ruleid" select="concat('tmp-', local:randomString2(generate-id()))"/>
            <rule xmlns="http://purl.oclc.org/dsdl/schematron" context="{$context}" id="{$ruleid}">

                <!-- 
                    create lets for the definition of variables used later;
                    2DO remove duplicate source in SCH en TMP rules, 
                    create a template call doDefineVariables,
                    get namespaces right and be happy
                -->
                <xsl:for-each select="defineVariable">
                    <xsl:variable name="theCode">
                        <xsl:if test="string-length(code/@code)>0 or string-length(code/@codeSystem)>0">
                            <xsl:text>[</xsl:text>
                            <xsl:value-of select="$projectDefaultElementNamespace"/>
                            <xsl:text>code</xsl:text>
                        </xsl:if>
                        <xsl:if test="string-length(code/@code)>0">
                            <xsl:text>[@code='</xsl:text>
                            <xsl:value-of select="code/@code"/>
                            <xsl:text>']</xsl:text>
                        </xsl:if>
                        <xsl:if test="string-length(code/@codeSystem)>0">
                            <xsl:text>[@codeSystem='</xsl:text>
                            <xsl:value-of select="code/@codeSystem"/>
                            <xsl:text>']</xsl:text>
                        </xsl:if>
                        <xsl:if test="string-length(code/@code)>0 or string-length(code/@codeSystem)>0">
                            <xsl:text>]</xsl:text>
                        </xsl:if>
                    </xsl:variable>
                    <!-- assertion: use/@name is not empty and contains a valid xpath to a data type value, typed INT or CE or TS -->
                    <let name="temp1_{@name}" value="{@path}{$theCode}/{use/@path}"/>
                    <xsl:choose>
                        <xsl:when test="use/@as='INT'">
                            <let name="{@name}" value="if ($temp1_{@name} castable as xs:integer) then ($temp1_{@name} cast as xs:integer) else false"/>
                        </xsl:when>
                        <xsl:when test="use/@as='CE'">
                            <let name="{@name}" value="$temp1_{@name}"/>
                        </xsl:when>
                        <xsl:when test="use/@as='TS.JULIAN'">
                            <let name="temp2_{@name}" value="concat(substring($temp1_{@name}, 1, 4), '-', substring($temp1_{@name}, 5, 2), '-', substring($temp1_{@name}, 7, 2))"/>
                            <let name="temp3_{@name}" value="if ($temp2_{@name} castable as xs:date) then ($temp2_{@name} cast as xs:date) else false"/>
                            <!-- modified julian day, days after Nov 17, 1858 -->
                            <let name="{@name}" value="days-from-duration($temp3_{@name} - xs:date('1858-11-17'))"/>
                        </xsl:when>
                        <xsl:when test="use/@as='TS'">
                            <let name="{@name}" value="$temp1_{@name}"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <let name="{@name}" value="false"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
                <!-- end create lets -->

                <xsl:for-each select="let|assert|report">
                    <xsl:variable name="rln" select="./name()"/>
                    <xsl:choose>
                        <xsl:when test="$rln='let'">
                            <xsl:element name="let">
                                <xsl:attribute name="name" select="@name"/>
                                <xsl:attribute name="value" select="@value"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:element name="{$rln}">
                                <xsl:if test="@flag">
                                    <xsl:attribute name="flag" select="@flag"/>
                                </xsl:if>
                                <xsl:if test="@see">
                                    <xsl:attribute name="see" select="@see"/>
                                </xsl:if>
                                <xsl:if test="@role">
                                    <!--<xsl:attribute name="role" select="concat(./@role, ':', $uniqueId)"/>-->
                                    <xsl:attribute name="role" select="@role"/>
                                </xsl:if>
                                <xsl:attribute name="test" select="@test"/>
                                <xsl:value-of select="$item"/>
                                <xsl:text> (</xsl:text>
                                <xsl:value-of select="$pPath"/>
                                <xsl:text>) </xsl:text>
                                <xsl:for-each select="node()">
                                    <xsl:call-template name="doCopyIntoSchematronNamespace"/>
                                </xsl:for-each>
                            </xsl:element>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </rule>
            <xsl:text>&#10;</xsl:text>
        </pattern>

    </xsl:template>

    <xsl:template name="doTemplateRules">
        <!-- this is the context of the current rule node as a param -->
        <xsl:param name="rc" as="element()"/>
        <xsl:param name="previousitemlabel"/>
        <xsl:param name="previousContext"/>
        <xsl:param name="previousUniqueId"/>
        <xsl:param name="previousUniqueEffectiveTime"/>
        <xsl:param name="isClosed" select="false()" as="xs:boolean"/>
        <!-- param relevant for @isClosed calculation. This is only done for top level templates as @isClosed calculations 
            need to be in context. When isClosed=true AND checkIsClosed=true then these checks are performed
        -->
        <xsl:param name="checkIsClosed" select="false()" as="xs:boolean"/>
        
        <!-- this param for too deep nestings, detect recursion and give up if nestinglevel > maxNestingLevel -->
        <xsl:param name="nestinglevel"/>
        
        <xsl:if test="$nestinglevel > $maxNestingLevel">
            <xsl:call-template name="logMessage">
                <xsl:with-param name="level" select="$logFATAL"/>
                <xsl:with-param name="terminate" select="true()"/>
                <xsl:with-param name="msg">
                    <xsl:text>+++ Error: Nesting level too high (more than </xsl:text>
                    <xsl:value-of select="$maxNestingLevel"/>
                    <xsl:text>). Possible circular references thru include statements in templates, context: </xsl:text>
                    <xsl:value-of select="$rc/name()"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="$rc/@name"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="$rc/@id"/><xsl:text>&#010;</xsl:text>
                    <xsl:text>+++ Previous uniqueId: </xsl:text>
                    <xsl:value-of select="$previousUniqueId"/>
                    <xsl:text> :: </xsl:text>
                    <xsl:value-of select="$previousUniqueEffectiveTime"/>
                    <xsl:text>&#010;</xsl:text>
                    <xsl:text>+++ Previous context: </xsl:text>
                    <xsl:value-of select="$previousContext"/>
                    <xsl:text>&#010;</xsl:text>
                    <xsl:text>+++ Processing stopped...</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        
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

        <!-- 
            create the see url, typically a direct link to the template defintion documentation in HTML
        -->
        <xsl:variable name="seethisthingurl">
            <xsl:value-of select="$seeURLprefix"/>
            <xsl:value-of select="$theHtmlDir"/>
            <xsl:text>tmp-</xsl:text>
            <xsl:value-of select="$uniqueId"/>
            <xsl:text>-</xsl:text>
            <xsl:value-of select="replace($uniqueIdEffectiveTime,':','')"/>
            <xsl:text>.html</xsl:text>
        </xsl:variable>

        <!-- 
            get context
            situations:
             - if this is a template with id, context is defined initially by the templateId expr itself, subsequently by adding @name
             - if this is a template with a context path, use the path as the context with some tricks
             - if this is an element with a name only, take over the previous context, cave //
             - if this is an include with a ref
        -->
        
        <!-- a predicate test variable, if no testing this is false() -->
        <xsl:variable name="predicatetest" select="false()"/>
        <xsl:variable name="context">
            <xsl:choose>
                <xsl:when test="($predicatetest=true()) and ($rc/context/@id='**' and $rc/name()='template')">
                    <xsl:variable name="templateIdNamespace" select="substring-before($rc/element/element[matches(@name,'^[a-zA-Z0-9]*:templateId')][1]/@name,':')"/>
                    <!-- test mode -->
                    
                    <!-- the template id -->
                    <xsl:text>*[</xsl:text>
                    <xsl:value-of select="$templateIdNamespace"/>
                    <xsl:text>:</xsl:text>
                    <xsl:text>templateId/@root='</xsl:text>
                    <xsl:value-of select="$rc/@id"/>
                    <xsl:text>']</xsl:text>
                    
                    <xsl:if test="string-length($rc/@id)=0">
                        <xsl:call-template name="logMessage">
                            <xsl:with-param name="level" select="$logFATAL"/>
                            <xsl:with-param name="terminate" select="true()"/>
                            <xsl:with-param name="msg">
                                <xsl:text> </xsl:text>
                                <!-- CANNOT BE! -->
                                <xsl:copy-of select="$rc"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:if>
                    
                </xsl:when>
                
                <xsl:when test="$rc/context/@id='**' and $rc/name()='template'">
                    <xsl:variable name="templateIdNamespace" select="substring-before($rc/element/element[matches(@name,'^[a-zA-Z0-9]*:templateId')][1]/@name,':')"/>

                    <!-- initially template id is given, construct the context expr *[*[... -->
                    <xsl:choose>
                        <xsl:when test="count($rc/element)=1 and string-length($rc/element[1]/@name)>0">
                            <!-- intermediate element is present,  put it in between -->
                            <xsl:text>*[</xsl:text>
                            <xsl:value-of select="$rc/element[1]/@name"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- no intermediate or so found, just preserve context -->
                            <xsl:text>*[*</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                    
                    <!-- the template id -->
                    <xsl:text>[</xsl:text>
                    <xsl:choose>
                        <xsl:when test="$templateIdNamespace">
                            <xsl:value-of select="$templateIdNamespace"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>hl7</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>:</xsl:text>
                    <xsl:text>templateId/@root='</xsl:text>
                    <xsl:value-of select="$rc/@id"/>
                    <xsl:text>']</xsl:text>
                    <xsl:text>]</xsl:text>
                    
                    <xsl:if test="string-length($rc/@id)=0">
                        <xsl:call-template name="logMessage">
                            <xsl:with-param name="level" select="$logFATAL"/>
                            <xsl:with-param name="terminate" select="true()"/>
                            <xsl:with-param name="msg">
                                <xsl:text> </xsl:text>
                                <!-- CANNOT BE! -->
                                <xsl:copy-of select="$rc"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:if>
                    
                </xsl:when>

                <xsl:when test="$rc/context/@id='*' and $rc/name()='template'">
                    <xsl:variable name="templateIdNamespace" select="substring-before($rc/element[matches(@name,'^[a-zA-Z0-9]*:templateId')][1]/@name,':')"/>

                    <!-- initially template id is given, construct the context expr *[... -->
                    <xsl:text>*[</xsl:text>
                    <xsl:choose>
                        <xsl:when test="$templateIdNamespace">
                            <xsl:value-of select="$templateIdNamespace"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>hl7</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>:</xsl:text>
                    <xsl:text>templateId/@root='</xsl:text>
                    <xsl:value-of select="$rc/@id"/>
                    <xsl:text>']</xsl:text>
                </xsl:when>

                <xsl:when test="string-length($rc/context/@path)&gt;0">
                    <!-- specific path name given or // (root element) -->
                    <xsl:value-of select="$rc/context/@path"/>
                </xsl:when>

                <xsl:when test="string-length($rc/@name)&gt;1">
                    <!-- Get current context part. Works on any element type -->
                    <xsl:variable name="finalPart">
                        <xsl:call-template name="getWherePathFromNodeset">
                            <xsl:with-param name="rccontent" select="$rc"/>
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
                        <xsl:otherwise>
                            <xsl:value-of select="$previousContext"/>
                            <xsl:text>/</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:value-of select="$finalPart"/>
                    <!--<xsl:choose>
                        <!-\- Skip predicate 'calculation' if previousContext already decisively determined context,
                            i.e. has a predicate and current element is a complexType, e.g. observation -\->
                        <xsl:when test="not(contains(tokenize($previousContext,'/')[last()],$finalPart))">
                            <xsl:value-of select="$finalPart"/>
                        </xsl:when>
                        <!-\- This is either a complexType, e.g. observation, in which case doAddWhere4Id will do nothing,
                            or this is a datatyped element, in which case doAddWhere4Id only really acts on II / id -\->
                        <xsl:otherwise>
                            <xsl:value-of select="$rc/@name"/>
                        </xsl:otherwise>
                    </xsl:choose>-->
                </xsl:when>

                <xsl:when test="string-length($rc/@include)&gt;0">
                    <!-- DEPRECATED!!!!, includes don't have a context -->
                    <!-- INCLUDE_CONTEXT - for include -->
                    <xsl:value-of select="@include"/>
                </xsl:when>

                <xsl:when test="name($rc) = 'include' and string-length($rc/@ref)&gt;0">
                    <!-- includes do not change context, take previous one -->
                    <!-- INCLUDE_CONTEXT - for include -->
                    <xsl:value-of select="$previousContext"/>
                </xsl:when>
                
                <xsl:when test="string-length($previousContext)&gt;0">
                    <!-- includes do not change context, take previous one -->
                    <!-- INCLUDE_CONTEXT - for include -->
                    <xsl:value-of select="$previousContext"/>
                </xsl:when>

                <xsl:when test="name($rc) = 'choice'">
                    <!-- choices do not change context, take previous one -->
                    <!-- CHOICE_CONTEXT - for choice -->
                    <xsl:value-of select="$previousContext"/>
                </xsl:when>

                <xsl:otherwise>
                    <xsl:text>ERROR_IN_CONTEXT - previous context </xsl:text>
                    <xsl:value-of select="$previousContext"/>
                </xsl:otherwise>

            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="contextSuffix">
            <xsl:call-template name="lastIndexOf">
                <xsl:with-param name="string" select="$context"/>
                <xsl:with-param name="char" select="'/'"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="comment">
            <xsl:text>&#10;</xsl:text>
            <xsl:text>Template derived rules for ID: </xsl:text>
            <xsl:value-of select="$uniqueId"/>
            <xsl:text>&#10;</xsl:text>
            <xsl:if test="string-length($context)>0">
                <xsl:text>Context: </xsl:text>
                <xsl:value-of select="$context"/>
                <xsl:text>&#10;</xsl:text>
            </xsl:if>

            <xsl:text>Item: </xsl:text>
            <xsl:value-of select="$itemlabel"/>
            <xsl:if test="$rc/@scenario">
                <xsl:text> - scenario(s): </xsl:text>
                <xsl:value-of select="$rc/@scenario"/>
            </xsl:if>
            <xsl:text>&#10;</xsl:text>
        </xsl:variable>
        
        <xsl:call-template name="logMessage">
            <xsl:with-param name="level" select="$logALL"/>
            <xsl:with-param name="msg">
                <xsl:text>Processing Rule: </xsl:text>
                <xsl:value-of select="name()"/>
                <xsl:text> -context </xsl:text>
                <xsl:value-of select="$context"/>
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
            <xsl:when test="$checkIsClosed=true() and (($isClosed=true() or string(@isClosed)='true') or $switchCreateSchematronWithWarningsOnOpen)">
                <xsl:variable name="assertRole">
                    <xsl:choose>
                        <xsl:when test="($isClosed=true() or string(@isClosed)='true')">
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
                        <xsl:when test="($isClosed=true() or string(@isClosed)='true')">
                            <xsl:text>closedElementOrTemplateError</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>closedElementOrTemplateWarning</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <xsl:if test="count(element)>0">
                    <xsl:call-template name="logMessage">
                        <xsl:with-param name="level" select="$logALL"/>
                        <xsl:with-param name="msg">
                            <xsl:text>closed template context </xsl:text>
                            <xsl:value-of select="$context"/>
                            <xsl:text> ::====reject * except </xsl:text>
                            <xsl:for-each select="element">
                                <xsl:variable name="theName">
                                    <xsl:call-template name="getWherePathFromNodeset">
                                        <xsl:with-param name="rccontent" select="."/>
                                    </xsl:call-template>
                                </xsl:variable>
                                <xsl:value-of select="$theName"/>
                                <xsl:text> </xsl:text>
                            </xsl:for-each>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:if>

                <!--
                    If this an element or template that is closed either specifically or by inheritance,
                    get all underlying elements and add a check that counts any elements not in the defined set.
                    To get underlying elements we should get all immediate elements, and all immediate elements 
                    under include and choice
                -->
                <xsl:if test="count($rc/element|$rc/include|$rc/choice)>0 and not(name($rc)='choice')">
                    <!-- create rules for every element but only if this is not a template in ** context -->
                    <xsl:variable name="tt">
                        <xsl:variable name="ttt">
                            <!-- Will have one trailing pipe symbol | too many. Strip that later on -->
                            <xsl:apply-templates select="$rc/element|$rc/include|$rc/choice" mode="getNamesForIsClosed"/>
                            <!-- Suppose this is an element with contains, then we should take what's in @contains also into account -->
                            <xsl:if test="$rc/self::element[@contains]">
                                <xsl:variable name="rccontent">
                                    <xsl:call-template name="getRulesetContent">
                                        <xsl:with-param name="ruleset" select="$rc/@contains"/>
                                        <xsl:with-param name="flexibility" select="$rc/@flexibility"/>
                                    </xsl:call-template>
                                </xsl:variable>
                                <xsl:apply-templates select="$rccontent/template/element|$rccontent/template/include|$rccontent/template/choice" mode="getNamesForIsClosedTemplate"/>
                            </xsl:if>
                        </xsl:variable>

                        <xsl:text>*[not(</xsl:text>
                        <xsl:value-of select="substring($ttt,1,string-length($ttt)-1)"/>
                        <xsl:text>)]</xsl:text>
                    </xsl:variable>
                    <xsl:variable name="ruleid" select="concat('tmp-', local:randomString2(concat(generate-id(),$checkIsClosed)))"/>

                    <xsl:text>&#10;&#10;</xsl:text>
                    <xsl:comment><xsl:text> </xsl:text>Checking undefined contents for template/element @isClosed="<xsl:value-of select="($isClosed=true() or string(@isClosed)='true')"/>". Match context that we did not already match<xsl:text> </xsl:text></xsl:comment>
                    <xsl:text>&#10;</xsl:text>
                    <rule xmlns="http://purl.oclc.org/dsdl/schematron" context="{$context}{if (not(ends-with($context,'/'))) then ('/') else ()}{$tt}" id="{$ruleid}">
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
                            </xsl:call-template>
                            <xsl:text> </xsl:text>
                            <xsl:value-of select="concat('(rule-reference: ', $ruleid, ')')"/>
                        </assert>
                    </rule>
                </xsl:if>

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
                <xsl:if test="0=1 and $rc/self::element and string(@isClosed)='true' and (string($isClosed)='false' or string($isClosed)='')">
                    <xsl:variable name="theName">
                        <xsl:call-template name="getWherePathFromNodeset">
                            <xsl:with-param name="rccontent" select="$rc"/>
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
                        <assert role="warning" see="{$seethisthingurl}" test="count({$tt})=0">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'closedElementOrTemplateNoSiblings'"/>
                                <xsl:with-param name="p1" select="$itemlabel"/>
                                <xsl:with-param name="p2" select="name()"/>
                                <xsl:with-param name="p3" select="$theName"/>
                            </xsl:call-template>
                        </assert>
                    </xsl:if>
                </xsl:if>
            </xsl:when>
            <!-- create rules, except if context is "//" -->
            <xsl:when test="$checkIsClosed=false() and $context != '//'">
                <xsl:text>&#10;</xsl:text>
                <xsl:comment select="$comment"/>
                <xsl:text>&#10;</xsl:text>
                
                <xsl:choose>
                    <xsl:when test="self::desc | self::item | self::classification | self::relationship">
                        <!-- skip -->
                    </xsl:when>
                    <xsl:when test="self::attribute">
                        <!-- handled elsewhere -->
                    </xsl:when>
                    <xsl:when test="self::include | self::choice">
                        <!-- handle an include or a choice on top level template -->
                        <xsl:choose>
                            <xsl:when test="$checkIsClosed = false()">
                                <!-- skip -->
                                <!--<xsl:apply-templates select="." mode="doTemplateRules">
                                    <xsl:with-param name="rc" select="."/>
                                    <xsl:with-param name="itemlabel" select="$itemlabel"/>
                                    <xsl:with-param name="context" select="$context"/>
                                    <xsl:with-param name="uniqueId" select="$uniqueId"/>
                                    <xsl:with-param name="uniqueEffectiveTime" select="$uniqueIdEffectiveTime"/>
                                    <xsl:with-param name="isClosed">
                                        <xsl:choose>
                                            <xsl:when test="$switchCreateSchematronClosed=true()">
                                                <xsl:value-of select="'true'"/>
                                            </xsl:when>
                                            <xsl:when test="@isClosed">
                                                <xsl:value-of select="@isClosed"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="$isClosed"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:with-param>
                                    <xsl:with-param name="checkIsClosed" select="$checkIsClosed"/>
                                    <xsl:with-param name="nestinglevel" select="if (self::choice) then ($nestinglevel) else ($nestinglevel+1)"/>
                                    <xsl:with-param name="predicatetest" select="$predicatetest"/>
                                    <xsl:with-param name="seethisthingurl" select="$seethisthingurl"/>
                                    <xsl:with-param name="contextSuffix" select="$contextSuffix"/>
                                </xsl:apply-templates>-->
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="." mode="doTemplateRulesForClosed">
                                    <xsl:with-param name="rc" select="."/>
                                    <xsl:with-param name="itemlabel" select="$itemlabel"/>
                                    <xsl:with-param name="context" select="$context"/>
                                    <xsl:with-param name="uniqueId" select="$uniqueId"/>
                                    <xsl:with-param name="uniqueEffectiveTime" select="$uniqueIdEffectiveTime"/>
                                    <xsl:with-param name="isClosed">
                                        <xsl:choose>
                                            <xsl:when test="$switchCreateSchematronClosed=true()">
                                                <xsl:value-of select="'true'"/>
                                            </xsl:when>
                                            <xsl:when test="@isClosed">
                                                <xsl:value-of select="@isClosed"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="$isClosed"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:with-param>
                                    <xsl:with-param name="checkIsClosed" select="$checkIsClosed"/>
                                    <xsl:with-param name="nestinglevel" select="if (self::choice) then ($nestinglevel) else ($nestinglevel+1)"/>
                                    <xsl:with-param name="predicatetest" select="$predicatetest"/>
                                    <xsl:with-param name="seethisthingurl" select="$seethisthingurl"/>
                                    <xsl:with-param name="contextSuffix" select="$contextSuffix"/>
                                </xsl:apply-templates>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- it shall be an element or so -->
                        <xsl:variable name="ruleroot">

                            <xsl:text>&#10;</xsl:text>
                            <xsl:variable name="ruleid" select="concat('tmp-', local:randomString2(concat(generate-id(),$checkIsClosed)))"/>
                            <rule xmlns="http://purl.oclc.org/dsdl/schematron" context="{$context}" id="{$ruleid}">

                                <!-- first look trhu all includes and put their attribute checks into this context -->
                                <xsl:for-each select="$rc/include">
                                    <!-- make a look-ahead of all attributes and add them in this context here -->
                                    <xsl:variable name="rccontent">
                                        <xsl:call-template name="getRulesetContent">
                                            <xsl:with-param name="ruleset" select="@ref"/>
                                            <xsl:with-param name="flexibility" select="@flexibility"/>
                                        </xsl:call-template>
                                    </xsl:variable>
                                    <xsl:if test="not($rccontent/template/context[@id])">
                                        <!-- process attributes first -->
                                        <xsl:variable name="theattributechecks">
                                            <xsl:apply-templates select="$rccontent/*/attribute" mode="GEN">
                                                <xsl:with-param name="itemlabel" select="$itemlabel"/>
                                                <xsl:with-param name="context" select="$context"/>
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

                                <!-- if this is an element do the following things -->
                                <xsl:if test="self::element">
                                    <!--
                                        then do @datatype of an element
                                        ================================
                                    -->
                                    <!-- @datatype -->
                                    <xsl:if test="@datatype">

                                        <!-- 
                                            FIXME: Hack to support CDA specs that import the HL7 datatypes into their own namespace
                                            The assumption here is that if you remove the namspace an HL7 default DTr1 emerges. E.g. 
                                            epsos:PQ equals PQ. This will fail if some spec Y comes along and defines y:PQ where PQ != HL7 DTr1 PQ
                                        -->
                                        <xsl:variable name="datatype" select="@datatype"/>
                                        <xsl:variable name="datatypeNme" select="if (contains(@datatype,':')) then (substring-after(@datatype,':')) else (@datatype)"/>

                                        <!-- 
                                             check whether dt is supported
                                             if not $isSupportedDatatype will be empty
                                             if yes $isSupportedDatatype will contain the (unflavored) data type
                                         -->
                                        <xsl:variable name="isSupportedDatatype">
                                            <xsl:for-each-group select="$supportedDatatypes/*" group-by="@name">
                                                <xsl:if test="$datatypeNme = @name">
                                                    <xsl:choose>
                                                        <xsl:when test="@isFlavorOf">
                                                            <xsl:value-of select="@isFlavorOf"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="@name"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:if>
                                            </xsl:for-each-group>
                                        </xsl:variable>

                                        <xsl:if test="string-length($isSupportedDatatype)>0 and $switchCreateDatatypeChecks=true()">

                                            <!-- 
                                                 Get namespace-uri for the @datatype.
                                                 1. If has namespace prefix hl7: or cda:, then must be in namespace 'urn:hl7-org:v3'
                                                 2. If has no namespace prefix, then must be in DECOR default namespace-uri
                                                 3. If has namespace prefix then get the namespace-uri form DECOR file
                                             -->
                                            <xsl:variable name="dfltNS">
                                                <xsl:choose>
                                                    <xsl:when test="string-length($projectDefaultElementNamespace)=0">
                                                        <xsl:value-of select="'urn:hl7-org:v3'"/>
                                                    </xsl:when>
                                                    <xsl:when test="$projectDefaultElementNamespace='hl7:' or $projectDefaultElementNamespace='cda:'">
                                                        <xsl:value-of select="'urn:hl7-org:v3'"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="namespace-uri-for-prefix(substring-before($projectDefaultElementNamespace,':'),.)"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:variable>
                                            <xsl:variable name="dtPfx" select="substring-before($datatype,':')"/>
                                            <xsl:variable name="dtNS">
                                                <xsl:choose>
                                                    <xsl:when test="$dtPfx='hl7' or $dtPfx='cda'">
                                                        <xsl:value-of select="'urn:hl7-org:v3'"/>
                                                    </xsl:when>
                                                    <xsl:when test="$dtPfx=''">
                                                        <xsl:value-of select="$dfltNS"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="namespace-uri-for-prefix($dtPfx,.)"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:variable>
                                            <xsl:variable name="dtVal" select="if (contains($isSupportedDatatype,':')) then (substring-after($isSupportedDatatype,':')) else ($isSupportedDatatype)"/>

                                            <!-- check for the presence of xsi:type and if present check correct data type requested -->
                                            <!-- Note that different versions of Saxon interpret QName differently. You cannot assume that casting @xsi:type to QName works, hence the substring-* functions -->
                                            <assert role="error" see="{$seethisthingurl}" test="(local-name-from-QName(resolve-QName(@xsi:type,.))='{$dtVal}' and namespace-uri-from-QName(resolve-QName(@xsi:type,.))='{$dtNS}') or not(@xsi:type)">
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'datatypeXSIShallBe'"/>
                                                    <xsl:with-param name="p1" select="$itemlabel"/>
                                                    <xsl:with-param name="p2">
                                                        <xsl:text>{</xsl:text>
                                                        <xsl:value-of select="$dtNS"/>
                                                        <xsl:text>}:</xsl:text>
                                                        <xsl:value-of select="$dtVal"/>
                                                    </xsl:with-param>
                                                </xsl:call-template>
                                            </assert>

                                            <!-- include extends if datatype is supported -->

                                            <!-- include datatype (flavor) -->
                                            <!-- 
                                                FIXME: Hack to support CDA specs that import the HL7 datatypes into their own namespace
                                                The assumption here is that if you remove the namspace an HL7 default DTr1 emerges. E.g. 
                                                epsos:PQ equals PQ. This will fail if some spec Y comes along and defines y:PQ where PQ != HL7 DTr1 PQ
                                            -->
                                            <extends xmlns="http://purl.oclc.org/dsdl/schematron" rule="{$datatypeNme}"/>

                                        </xsl:if>

                                        <xsl:choose>
                                            <!-- get text() if this is a type of string or so, @value otherwise (DTr1) -->
                                            <xsl:when test="$isSupportedDatatype='SC' or $isSupportedDatatype='ST' or $isSupportedDatatype='ED'">
                                                <let name="theValue" value="text()"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <let name="theValue" value="@value"/>
                                            </xsl:otherwise>
                                        </xsl:choose>

                                        <!-- check properties -->
                                        <xsl:if test="count(property[@*])>0">
                                            <xsl:variable name="pqexpr">
                                                <xsl:for-each select="property[@minLength or @maxLength or @value or @unit or @currency or @minInclude or @maxInclude or @fractionDigits]">
                                                    <xsl:text>(@nullFlavor or (</xsl:text>

                                                    <xsl:if test="@minLength">
                                                        <xsl:text>string-length(string($theValue))&gt;=</xsl:text>
                                                        <xsl:value-of select="@minLength"/>
                                                    </xsl:if>

                                                    <xsl:if test="@maxLength">
                                                        <xsl:if test="@minLength">
                                                            <xsl:text> and </xsl:text>
                                                        </xsl:if>
                                                        <xsl:text>string-length(string($theValue))&lt;=</xsl:text>
                                                        <xsl:value-of select="@maxLength"/>
                                                    </xsl:if>

                                                    <xsl:if test="@value">
                                                        <xsl:if test="@minLength or @maxLength">
                                                            <xsl:text> and </xsl:text>
                                                        </xsl:if>
                                                        <xsl:text>$theValue='</xsl:text>
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
                                                        <xsl:if test="@minLength or @maxLength or @value">
                                                            <xsl:text> and </xsl:text>
                                                        </xsl:if>
                                                        <xsl:text>@currency='</xsl:text>
                                                        <xsl:value-of select="@currency"/>
                                                        <xsl:text>'</xsl:text>
                                                    </xsl:if>

                                                    <xsl:if test="@minInclude">
                                                        <xsl:if test="@minLength or @maxLength or @value or @unit">
                                                            <xsl:text> and </xsl:text>
                                                        </xsl:if>
                                                        <xsl:text>number($theValue)&gt;=</xsl:text>
                                                        <xsl:value-of select="@minInclude"/>
                                                    </xsl:if>
                                                    <xsl:if test="@maxInclude">
                                                        <xsl:if test="@minLength or @maxLength or @value or @unit or @minInclude">
                                                            <xsl:text> and </xsl:text>
                                                        </xsl:if>
                                                        <xsl:text>number($theValue)&lt;=</xsl:text>
                                                        <xsl:value-of select="@maxInclude"/>
                                                    </xsl:if>

                                                    <xsl:if test="string-length(@fractionDigits)>0">
                                                        <xsl:variable name="theFractionDigits" select="replace(@fractionDigits, '!', '') cast as xs:integer"/>
                                                        <xsl:variable name="exact" select="contains(@fractionDigits, '!')"/>
                                                        <xsl:if test="@minLength or @maxLength or @value or @unit or @minInclude or @maxInclude">
                                                            <xsl:text> and </xsl:text>
                                                        </xsl:if>
                                                        <xsl:text>(matches(string($theValue), '^[-+]?[0-9]*</xsl:text>
                                                        <xsl:if test="$theFractionDigits>0">
                                                            <xsl:text>\.[0-9]{</xsl:text>
                                                            <xsl:value-of select="$theFractionDigits"/>
                                                            <xsl:text>,</xsl:text>
                                                            <xsl:choose>
                                                                <xsl:when test="$exact=true()">
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
                                            <xsl:variable name="pqerr">
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'elmShall'"/>
                                                    <xsl:with-param name="p1" select="$itemlabel"/>
                                                    <xsl:with-param name="p2" select="'value'"/>
                                                </xsl:call-template>
                                                <xsl:for-each select="property[@minLength or @maxLength or @value or @unit or @minInclude or @maxInclude or @fractionDigits]">

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

                                                    <xsl:if test="string-length(@fractionDigits)>0">
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

                                            <assert role="error" see="{$seethisthingurl}" test="{$pqexpr}">
                                                <xsl:value-of select="$pqerr"/>
                                            </assert>

                                        </xsl:if>

                                        <xsl:if test="$switchCreateDatatypeChecks=true()">
                                            <!-- check PQ / INT properties -->
                                            <xsl:if test="$isSupportedDatatype = 'PQ' or $isSupportedDatatype = 'INT'">
                                                <xsl:choose>
                                                    <xsl:when test="$isSupportedDatatype = 'INT'">
                                                        <let name="digitok" value="matches(string($theValue), '{$INTdigits}')"/>
                                                    </xsl:when>
                                                    <xsl:when test="$isSupportedDatatype = 'PQ'">
                                                        <let name="digitok" value="matches(string($theValue), '{$REALdigits}')"/>
                                                    </xsl:when>
                                                </xsl:choose>
                                                <assert role="error" see="{$seethisthingurl}" test="$digitok or @nullFlavor">
                                                    <xsl:call-template name="getMessage">
                                                        <xsl:with-param name="key" select="'attribNotAValidNumber'"/>
                                                        <xsl:with-param name="p1" select="$itemlabel"/>
                                                        <xsl:with-param name="p2" select="$isSupportedDatatype"/>
                                                    </xsl:call-template>
                                                    <value-of select="$theValue"/>
                                                </assert>
                                            </xsl:if>

                                            <!-- check IVL_PQ properties ... should be done by the corresponding data type flavor schematrons -->
                                            <xsl:if test="$isSupportedDatatype = 'IVL_PQ'">
                                                <assert role="error" see="{$seethisthingurl}" test="not({$projectDefaultElementNamespace}low/@value) or matches(string({$projectDefaultElementNamespace}low/@value), '{$REALdigits}')">
                                                    <xsl:call-template name="getMessage">
                                                        <xsl:with-param name="key" select="'attribNotAValidPQ'"/>
                                                        <xsl:with-param name="p1" select="$itemlabel"/>
                                                        <xsl:with-param name="p2" select="'value/low'"/>
                                                    </xsl:call-template>
                                                    <value-of select="{$projectDefaultElementNamespace}low/@value"/>
                                                </assert>
                                                <assert role="error" see="{$seethisthingurl}" test="not({$projectDefaultElementNamespace}high/@value) or matches(string({$projectDefaultElementNamespace}high/@value), '{$REALdigits}')">
                                                    <xsl:call-template name="getMessage">
                                                        <xsl:with-param name="key" select="'attribNotAValidPQ'"/>
                                                        <xsl:with-param name="p1" select="$itemlabel"/>
                                                        <xsl:with-param name="p2" select="'value/high'"/>
                                                    </xsl:call-template>
                                                    <value-of select="{$projectDefaultElementNamespace}high/@value"/>
                                                </assert>
                                                <assert role="error" see="{$seethisthingurl}" test="not({$projectDefaultElementNamespace}center/@value) or matches(string({$projectDefaultElementNamespace}center/@value), '{$REALdigits}')">
                                                    <xsl:call-template name="getMessage">
                                                        <xsl:with-param name="key" select="'attribNotAValidPQ'"/>
                                                        <xsl:with-param name="p1" select="$itemlabel"/>
                                                        <xsl:with-param name="p2" select="'value/center'"/>
                                                    </xsl:call-template>
                                                    <value-of select="{$projectDefaultElementNamespace}center/@value"/>
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

                                    <!-- 
                                          then do vocabulary of an element
                                          ============================
                                     -->
                                    <xsl:if test="count(vocabulary[@code or @codeSystem or @valueSet])>0">
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

                                        <!-- 
                                            create expression for one or multiple codes and/or codeSystems given
                                            
                                            (C)
                                            (C and S)
                                            (C or C)
                                            (C and S) or (C and S)
                                            etc
                                        -->
                                        <xsl:variable name="vsexpr">
                                            <vsx>
                                                <xsl:for-each select="vocabulary[@valueSet]">

                                                    <xsl:variable name="xvsref" select="@valueSet"/>
                                                    <xsl:variable name="xvsflex" select="if (@flexibility) then (@flexibility) else ('dynamic')"/>
                                                    <xsl:variable name="xvs">
                                                        <xsl:call-template name="getValueset">
                                                            <xsl:with-param name="reference" select="$xvsref"/>
                                                            <xsl:with-param name="flexibility" select="$xvsflex"/>
                                                        </xsl:call-template>
                                                    </xsl:variable>
                                                    <xsl:variable name="xvsid" select="($xvs/valueSet)[1]/@id"/>
                                                    <xsl:variable name="xvsdn" select="($xvs/valueSet)[1]/@displayName"/>
                                                    
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
                                                                    <xsl:value-of select="$context"/>
                                                                    <xsl:text>)</xsl:text>
                                                                </xsl:with-param>
                                                            </xsl:call-template>
                                                        </xsl:when>
                                                        <xsl:when test="$vsdatatype='CS' and not(($xvs/valueSet)[1]/conceptList/concept)">
                                                            <xsl:call-template name="logMessage">
                                                                <xsl:with-param name="level" select="$logWARN"/>
                                                                <xsl:with-param name="msg">
                                                                    <xsl:text>+++ value set skipped for use in schematron as it binds to datatype CS, but has no concepts - </xsl:text>
                                                                    <xsl:text>value set </xsl:text>
                                                                    <xsl:value-of select="$xvsref"/>
                                                                    <xsl:text>: </xsl:text>
                                                                    <xsl:value-of select="$xvsflex"/>
                                                                    <xsl:text> in rule </xsl:text>
                                                                    <xsl:value-of select="ancestor::template/@name"/>
                                                                    <xsl:text>: </xsl:text>
                                                                    <xsl:value-of select="ancestor::template/@effectiveDate"/>
                                                                    <xsl:text> (context=</xsl:text>
                                                                    <xsl:value-of select="$context"/>
                                                                    <xsl:text>)</xsl:text>
                                                                </xsl:with-param>
                                                            </xsl:call-template>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:variable name="valueSetFileObject">
                                                                <xsl:choose>
                                                                    <xsl:when test="$xvsflex='dynamic'">
                                                                        <xsl:value-of select="concat($theRuntimeRelativeIncludeDir, 'voc-', $xvsid, '-DYNAMIC.xml')"/>
                                                                    </xsl:when>
                                                                    <xsl:otherwise>
                                                                        <xsl:value-of select="concat($theRuntimeRelativeIncludeDir, 'voc-', $xvsid, '-',replace($xvsflex,':',''),'.xml')"/>
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
                                                                    <xsl:text>')/*/valueSet</xsl:text>
                                                                    <xsl:choose>
                                                                        <xsl:when test="$vsdatatype='CS'">
                                                                            <!-- If CS we do not have a codeSystem. Can check code against conceptList, but cannot check codeSystem against completeCodeSystem -->
                                                                            <xsl:text>/conceptList/concept[@code = $theCode] or completeCodeSystem</xsl:text>
                                                                        </xsl:when>
                                                                        <xsl:otherwise>
                                                                            <!-- If not CS, but no datatype given or any other (assumed coded) datatype, we should find a matching conceptList/code or completeCodeSystem -->
                                                                            <xsl:text>[</xsl:text>
                                                                            <xsl:text>conceptList/concept[@code = $theCode][@codeSystem = $theCodeSystem][not(@codeSystemVersion) or @codeSystemVersion=$theCodeSystemVersion]</xsl:text>
                                                                            <xsl:text> or </xsl:text>
                                                                            <xsl:text>completeCodeSystem[@codeSystem=$theCodeSystem][not(@codeSystemVersion) or @codeSystemVersion=$theCodeSystemVersion]</xsl:text>
                                                                            <xsl:text>]</xsl:text>
                                                                        </xsl:otherwise>
                                                                    </xsl:choose>
                                                                    <xsl:text>)</xsl:text>
                                                                </xsl:attribute>

                                                                <xsl:attribute name="nf">
                                                                    <xsl:text>exists(doc('</xsl:text>
                                                                    <xsl:value-of select="$valueSetFileObject"/>
                                                                    <xsl:text>')/*/valueSet</xsl:text>
                                                                    <xsl:text>/conceptList/exception[@code = $theNullFlavor][@codeSystem = '2.16.840.1.113883.5.1008']</xsl:text>
                                                                    <xsl:text>)</xsl:text>
                                                                </xsl:attribute>

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
                                                    <xsl:value-of select="@displayName"/>
                                                    <xsl:text>'</xsl:text>
                                                </xsl:if>
                                                <xsl:if test="@codeSystemName">
                                                    <xsl:text> and @codeSystemName='</xsl:text>
                                                    <xsl:value-of select="@codeSystemName"/>
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
                                                <xsl:when test="count(vocabulary[@code and @codeSystem])>0">
                                                    <xsl:text>@code/@codeSystem</xsl:text>
                                                </xsl:when>
                                                <xsl:when test="count(vocabulary[@code])>0">
                                                    <xsl:text>@code</xsl:text>
                                                </xsl:when>
                                                <xsl:when test="count(vocabulary[@codeSystem])>0">
                                                    <xsl:text>@codeSystem</xsl:text>
                                                </xsl:when>
                                            </xsl:choose>
                                        </xsl:variable>

                                        <xsl:variable name="vserr">
                                            <xsl:for-each select="$vsexpr/*/*[@vs]">
                                                <xsl:value-of select="@vs"/>
                                                <xsl:if test="string-length(@dp)>0 and (@dp != @vs)">
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
                                                    <xsl:value-of select="@displayName"/>
                                                    <xsl:text>'</xsl:text>
                                                </xsl:if>
                                                <xsl:if test="@codeSystemName">
                                                    <xsl:text> codeSystemName='</xsl:text>
                                                    <xsl:value-of select="@codeSystemName"/>
                                                    <xsl:text>'</xsl:text>
                                                </xsl:if>
                                                <xsl:if test="@codeSystemVersion">
                                                    <xsl:text> codeSystemVersion='</xsl:text>
                                                    <xsl:value-of select="@codeSystemVersion"/>
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
                                            <xsl:variable name="nullsInValueSet">
                                                <xsl:for-each select="attribute[@name='nullFlavor']/vocabulary[@valueSet]">
                                                    <xsl:variable name="xvsref" select="@valueSet"/>
                                                    <xsl:variable name="xvsflex" select="if (@flexibility) then (@flexibility) else ('dynamic')"/>
                                                    <xsl:variable name="xvs">
                                                        <xsl:call-template name="getValueset">
                                                            <xsl:with-param name="reference" select="$xvsref"/>
                                                            <xsl:with-param name="flexibility" select="$xvsflex"/>
                                                        </xsl:call-template>
                                                    </xsl:variable>
                                                    <xsl:copy-of select="$xvs/valueSet"/>
                                                </xsl:for-each>
                                            </xsl:variable>
                                            <xsl:for-each select="
                                                vocabulary[@valueSet]/exception[string-length(@code)>0][@codeSystem='2.16.840.1.113883.5.1008']/@code |
                                                attribute[@nullFlavor][not(@prohibited='true')]/@nullFlavor |
                                                attribute[@name='nullFlavor'][not(@prohibited='true')]/@value |
                                                attribute[@name='nullFlavor'][not(@prohibited='true')]/vocabulary[string-length(@code)>0][not(@codeSystem) or @codeSystem='2.16.840.1.113883.5.1008']/@code |
                                                $nullsInValueSet//*[@codeSystem='2.16.840.1.113883.5.1008']/@code">
                                                <xsl:value-of select="concat('''',string-join(tokenize(.,'\|'),''','''),'''')"/>
                                                <xsl:if test="position()!=last()">
                                                    <xsl:text>,</xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                            <xsl:text>)</xsl:text>
                                        </xsl:variable>

                                        <!-- Need to check whether or not we have something to check. If we don't we get an illegal assert/@test. This happens when e.g. 
                                            there's only a valueSet that either cannot be found or contains completeCodeSystem while the datatype is CS -->
                                        <xsl:if test="string-length($cdexpr) > 0">
                                            <xsl:if test="vocabulary[@valueSet]">
                                                <let name="theCode" value="@code"/>
                                                <let name="theCodeSystem" value="@codeSystem"/>
                                                <let name="theCodeSystemVersion" value="@codeSystemVersion"/>
                                            </xsl:if>

                                            <assert role="error" see="{$seethisthingurl}" test="@nullFlavor or {$cdexpr}">
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'attribValue2'"/>
                                                    <xsl:with-param name="p1" select="$itemlabel"/>
                                                    <xsl:with-param name="p2" select="$cderr"/>
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
                                                <assert role="error" see="{$seethisthingurl}" test="not(@nullFlavor) or not(empty(($validNullFlavorsFound))) {if ($explicitNulls!='()') then (concat('or @nullFlavor=',$explicitNulls)) else ()}">
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

                                    <!-- 
                                         then do text of an element
                                         ==========================
                                     -->
                                    <xsl:if test="count(text)>0">
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

                                    <!--
                                         then do all attributes of an element
                                         ====================================
                                     -->

                                    <xsl:variable name="theattributechecks">
                                        <xsl:apply-templates select="$rc/attribute" mode="GEN">
                                            <xsl:with-param name="itemlabel" select="$itemlabel"/>
                                            <xsl:with-param name="context" select="$context"/>
                                            <xsl:with-param name="uniqueId" select="$uniqueId"/>
                                            <xsl:with-param name="seethisthingurl" select="$seethisthingurl"/>
                                            <xsl:with-param name="contextSuffix" select="$contextSuffix"/>
                                        </xsl:apply-templates>
                                    </xsl:variable>
                                    <xsl:for-each select="$theattributechecks/node()">
                                        <xsl:call-template name="doCopyIntoSchematronNamespace"/>
                                    </xsl:for-each>

                                    <!--
                                        then do all define variable statements
                                        ======================================
                                    -->

                                    <!-- 
                                        create lets for the definition of variables used later;
                                        2DO remove duplicate source in SCH en TMP rules, 
                                        create a template call doDefineVariables,
                                        get namespaces right and be happy
                                    -->
                                    <xsl:for-each select="defineVariable">
                                        <xsl:variable name="theCode">
                                            <xsl:if test="string-length(code/@code)>0 or string-length(code/@codeSystem)>0">
                                                <xsl:text>[</xsl:text>
                                                <xsl:value-of select="$projectDefaultElementNamespace"/>
                                                <xsl:text>code</xsl:text>
                                            </xsl:if>
                                            <xsl:if test="string-length(code/@code)>0">
                                                <xsl:text>[@code='</xsl:text>
                                                <xsl:value-of select="code/@code"/>
                                                <xsl:text>']</xsl:text>
                                            </xsl:if>
                                            <xsl:if test="string-length(code/@codeSystem)>0">
                                                <xsl:text>[@codeSystem='</xsl:text>
                                                <xsl:value-of select="code/@codeSystem"/>
                                                <xsl:text>']</xsl:text>
                                            </xsl:if>
                                            <xsl:if test="string-length(code/@code)>0 or string-length(code/@codeSystem)>0">
                                                <xsl:text>]</xsl:text>
                                            </xsl:if>
                                        </xsl:variable>
                                        <!-- assertion: use/@name is not empty and contains a valid xpath to a data type value, typed INT or CE or TS -->
                                        <let name="temp1_{@name}" value="{@path}{$theCode}/{use/@path}"/>
                                        <xsl:choose>
                                            <xsl:when test="use/@as='INT'">
                                                <let name="{@name}" value="if ($temp1_{@name} castable as xs:integer) then ($temp1_{@name} cast as xs:integer) else false"/>
                                            </xsl:when>
                                            <xsl:when test="use/@as='CE'">
                                                <let name="{@name}" value="$temp1_{@name}"/>
                                            </xsl:when>
                                            <xsl:when test="use/@as='TS.JULIAN'">
                                                <let name="temp2_{@name}" value="concat(substring($temp1_{@name}, 1, 4), '-', substring($temp1_{@name}, 5, 2), '-', substring($temp1_{@name}, 7, 2))"/>
                                                <let name="temp3_{@name}" value="if ($temp2_{@name} castable as xs:date) then ($temp2_{@name} cast as xs:date) else false"/>
                                                <!-- modified julian day, days after Nov 17, 1858 -->
                                                <let name="{@name}" value="days-from-duration($temp3_{@name} - xs:date('1858-11-17'))"/>
                                            </xsl:when>
                                            <xsl:when test="use/@as='TS'">
                                                <let name="{@name}" value="$temp1_{@name}"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <let name="{@name}" value="false"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:for-each>
                                    <!-- end create lets -->

                                    <!--
                                       then do all schematron 
                                       let
                                       asserts and reports
                                       ==========================================
                                    -->

                                    <xsl:for-each select="$rc/let|$rc/assert|$rc/report">
                                        <xsl:variable name="rln" select="name()"/>
                                        <xsl:choose>
                                            <xsl:when test="$rln='let'">
                                                <xsl:element name="let">
                                                    <xsl:attribute name="name" select="@name"/>
                                                    <xsl:attribute name="value" select="@value"/>
                                                </xsl:element>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:element name="{$rln}">
                                                    <xsl:if test="@flag">
                                                        <xsl:attribute name="flag" select="@flag"/>
                                                    </xsl:if>
                                                    <xsl:if test="@role">
                                                        <!--<xsl:attribute name="role" select="concat(./@role, ':', $uniqueId)"/>-->
                                                        <xsl:attribute name="role" select="@role"/>
                                                    </xsl:if>
                                                    <!-- first write default, .. -->
                                                    <xsl:if test="self::assert|self::report">
                                                        <xsl:attribute name="see" select="$seethisthingurl"/>
                                                    </xsl:if>
                                                    <!-- then potentially overwrite if configured.. -->
                                                    <xsl:if test="@see">
                                                        <xsl:attribute name="see" select="@see"/>
                                                    </xsl:if>
                                                    <xsl:attribute name="test" select="@test"/>
                                                    <xsl:value-of select="$itemlabel"/>
                                                    <xsl:text>: </xsl:text>
                                                    <xsl:for-each select="node()">
                                                        <xsl:call-template name="doCopyIntoSchematronNamespace"/>
                                                    </xsl:for-each>
                                                </xsl:element>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:for-each>

                                </xsl:if>

                                <!--
                                    then do all elements or includes or choices
                                    - first generate cardinality checks only
                                    ========================================
                                -->
                                <xsl:if test="$skipCardinalityChecks=false()">
                                    <!-- create the cardinality checks -->
                                    <xsl:variable name="thecardchecks">
                                        <xsl:apply-templates select="$rc/element|$rc/include|$rc/choice" mode="cardinalitycheck">
                                            <xsl:with-param name="itemlabel" select="$itemlabel"/>
                                            <xsl:with-param name="context" select="$context"/>
                                            <xsl:with-param name="seethisthingurl" select="$seethisthingurl"/>
                                        </xsl:apply-templates>
                                    </xsl:variable>
                                    <xsl:for-each select="$thecardchecks/node()">
                                        <xsl:call-template name="doCopyIntoSchematronNamespace"/>
                                    </xsl:for-each>
                                </xsl:if>

                                <xsl:text>&#10;</xsl:text>
                            </rule>
                        </xsl:variable>
                        <xsl:if test="count($ruleroot/*/*)>0">
                            <xsl:copy-of select="$ruleroot"/>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <!-- 2DO give warning? Leave as-is? -->
            </xsl:otherwise>
        </xsl:choose>
        
        <!--
            then do all elements or includes or choices
            - now generate the rest beyond cardinalities
            ============================================
        -->
        <xsl:for-each select="$rc/(element|include|choice)">
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
                        <xsl:with-param name="context" select="$context"/>
                        <xsl:with-param name="uniqueId" select="$uniqueId"/>
                        <xsl:with-param name="uniqueEffectiveTime" select="$uniqueIdEffectiveTime"/>
                        <xsl:with-param name="isClosed">
                            <xsl:choose>
                                <xsl:when test="$switchCreateSchematronClosed=true()">
                                    <xsl:value-of select="'true'"/>
                                </xsl:when>
                                <xsl:when test="@isClosed">
                                    <xsl:value-of select="@isClosed"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$isClosed"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                        <xsl:with-param name="checkIsClosed" select="$checkIsClosed"/>
                        <xsl:with-param name="nestinglevel" select="if (self::choice) then ($nestinglevel) else ($nestinglevel+1)"/>
                        <xsl:with-param name="predicatetest" select="$predicatetest"/>
                        <xsl:with-param name="seethisthingurl" select="$seethisthingurl"/>
                        <xsl:with-param name="contextSuffix" select="$contextSuffix"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="." mode="doTemplateRulesForClosed">
                        <xsl:with-param name="rc" select="."/>
                        <xsl:with-param name="itemlabel" select="$itemlabel"/>
                        <xsl:with-param name="context" select="$context"/>
                        <xsl:with-param name="uniqueId" select="$uniqueId"/>
                        <xsl:with-param name="uniqueEffectiveTime" select="$uniqueIdEffectiveTime"/>
                        <xsl:with-param name="isClosed">
                            <xsl:choose>
                                <xsl:when test="$switchCreateSchematronClosed=true()">
                                    <xsl:value-of select="'true'"/>
                                </xsl:when>
                                <xsl:when test="@isClosed">
                                    <xsl:value-of select="@isClosed"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$isClosed"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                        <xsl:with-param name="checkIsClosed" select="$checkIsClosed"/>
                        <xsl:with-param name="nestinglevel" select="if (self::choice) then ($nestinglevel) else ($nestinglevel+1)"/>
                        <xsl:with-param name="predicatetest" select="$predicatetest"/>
                        <xsl:with-param name="seethisthingurl" select="$seethisthingurl"/>
                        <xsl:with-param name="contextSuffix" select="$contextSuffix"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="element|include" mode="doTemplateRules">
        <xsl:param name="itemlabel"/>
        <xsl:param name="context"/>
        <xsl:param name="uniqueId"/>
        <xsl:param name="uniqueEffectiveTime"/>
        <xsl:param name="isClosed" as="xs:boolean"/>
        <xsl:param name="checkIsClosed" as="xs:boolean"/>
        <xsl:param name="nestinglevel"/>
        <xsl:param name="predicatetest" select="false()" as="xs:boolean"/>
        <xsl:param name="seethisthingurl"/>
        <xsl:param name="contextSuffix"/>
        
        <xsl:choose>
            <!-- an element with both name and contains -->
            <xsl:when test="@name and @contains">

                <xsl:variable name="elemname">
                    <xsl:call-template name="getWherePathFromNodeset">
                        <xsl:with-param name="rccontent" select="."/>
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
                    <element>
                        <xsl:attribute name="name" select="$elemname"/>
                        <!--<xsl:copy-of select="@*"/>-->
                        <xsl:copy-of select="./*"/>
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
                    <rs1>
                        <xsl:call-template name="doTemplateRules">
                            <xsl:with-param name="rc" select="$ns1/node()"/>
                            <xsl:with-param name="previousitemlabel" select="$newitemlabel1"/>
                            <xsl:with-param name="previousContext" select="$context"/>
                            <xsl:with-param name="previousUniqueId" select="$uniqueId"/>
                            <xsl:with-param name="previousUniqueEffectiveTime" select="$uniqueEffectiveTime"/>
                            <xsl:with-param name="isClosed" select="$isClosed"/>
                            <xsl:with-param name="nestinglevel" select="$nestinglevel"/>
                            <xsl:with-param name="checkIsClosed" select="$checkIsClosed"/>
                        </xsl:call-template>
                    </rs1>
                </xsl:variable>

                <!-- lookup contained template content -->
                <xsl:variable name="rccontent">
                    <xsl:call-template name="getRulesetContent">
                        <xsl:with-param name="ruleset" select="@contains"/>
                        <xsl:with-param name="flexibility" select="@flexibility"/>
                    </xsl:call-template>
                </xsl:variable>
                <!-- 2DO: if available and has the template id element defined check it only don't include it -->

                <xsl:variable name="ns2" as="element()">
                    <element>
                        <xsl:attribute name="name" select="$elemname"/>
                        <!--<xsl:copy-of select="@*"/>-->
                        <xsl:copy-of select="$rccontent/template/*"/>
                    </element>
                </xsl:variable>

                <xsl:variable name="newitemlabel2">
                    <xsl:call-template name="getNewItemLabel">
                        <xsl:with-param name="rc" select="$rccontent/template"/>
                        <xsl:with-param name="default" select="$itemlabel"/>
                    </xsl:call-template>
                </xsl:variable>

                <!-- get the contained content rules -->
                <xsl:variable name="rs2">
                    <xsl:choose>
                        <xsl:when test="$rccontent/template/context[@id]">
                            <!-- if contained template has a context id don't merge it as it is triggered on its own -->
                            <empty/>
                        </xsl:when>
                        <xsl:otherwise>
                            <rs2>
                                <xsl:call-template name="doTemplateRules">
                                    <xsl:with-param name="rc" select="$ns2"/>
                                    <xsl:with-param name="previousitemlabel" select="$newitemlabel2"/>
                                    <xsl:with-param name="previousContext" select="$context"/>
                                    <xsl:with-param name="previousUniqueId" select="$rccontent/template/@id"/>
                                    <xsl:with-param name="previousUniqueEffectiveTime" select="$rccontent/template/@effectiveDate"/>
                                    <xsl:with-param name="isClosed" select="$isClosed"/>
                                    <xsl:with-param name="nestinglevel" select="$nestinglevel"/>
                                    <xsl:with-param name="checkIsClosed" select="$checkIsClosed"/>
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
                                    <xsl:variable name="ruleid" select="concat('tmp-', local:randomString2(concat(generate-id(),$checkIsClosed)))"/>
                                    <rule xmlns="http://purl.oclc.org/dsdl/schematron" context="{$context}" id="{$ruleid}">
                                        <xsl:variable name="theattributechecks">
                                            <xsl:apply-templates select="." mode="GEN">
                                                <xsl:with-param name="itemlabel" select="$itemlabel"/>
                                                <xsl:with-param name="context" select="$context"/>
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
                                        <xsl:with-param name="previousContext" select="$context"/>
                                        <xsl:with-param name="previousUniqueId" select="$uniqueId"/>
                                        <xsl:with-param name="previousUniqueEffectiveTime" select="$uniqueEffectiveTime"/>
                                        <xsl:with-param name="isClosed">
                                            <xsl:choose>
                                                <xsl:when test="$switchCreateSchematronClosed=true()">
                                                    <xsl:value-of select="'true'"/>
                                                </xsl:when>
                                                <xsl:when test="@isClosed">
                                                    <xsl:value-of select="@isClosed"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="$isClosed"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:with-param>
                                        <xsl:with-param name="nestinglevel" select="$nestinglevel+1"/>
                                        <xsl:with-param name="checkIsClosed" select="$checkIsClosed"/>
                                    </xsl:call-template>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="doTemplateRules">
                            <xsl:with-param name="rc" select="."/>
                            <xsl:with-param name="previousitemlabel" select="$itemlabel"/>
                            <xsl:with-param name="previousContext" select="$context"/>
                            <xsl:with-param name="previousUniqueId" select="$uniqueId"/>
                            <xsl:with-param name="previousUniqueEffectiveTime" select="$uniqueEffectiveTime"/>
                            <xsl:with-param name="isClosed" select="$isClosed"/>
                            <xsl:with-param name="nestinglevel" select="$nestinglevel"/>
                            <xsl:with-param name="checkIsClosed" select="$checkIsClosed"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- an include with a ref -->
            <xsl:when test="@ref">
                <xsl:variable name="rccontent">
                    <xsl:call-template name="getRulesetContent">
                        <xsl:with-param name="ruleset" select="@ref"/>
                        <xsl:with-param name="flexibility" select="@flexibility"/>
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
                        <xsl:value-of select="count($rccontent/*/*)"/>
                    </xsl:with-param>
                </xsl:call-template>
                
                <xsl:variable name="newitemlabel">
                    <xsl:call-template name="getNewItemLabel">
                        <xsl:with-param name="rc" select="$rccontent/template"/>
                        <xsl:with-param name="default" select="$itemlabel"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:if test="not($rccontent/template/context[@id])">
                    <xsl:call-template name="logMessage">
                        <xsl:with-param name="level" select="$logDEBUG"/>
                        <xsl:with-param name="msg">
                            <xsl:text>PROCESSING INCLUDE ...</xsl:text>
                        </xsl:with-param>
                    </xsl:call-template>
                    <xsl:for-each select="$rccontent/*/(element|include|choice)">
                        <xsl:call-template name="doTemplateRules">
                            <xsl:with-param name="rc" select="."/>
                            <xsl:with-param name="previousitemlabel" select="$newitemlabel"/>
                            <xsl:with-param name="previousContext" select="$context"/>
                            <xsl:with-param name="previousUniqueId" select="$rccontent/template/@id"/>
                            <xsl:with-param name="previousUniqueEffectiveTime" select="$rccontent/template/@effectiveDate"/>
                            <xsl:with-param name="isClosed" select="$isClosed"/>
                            <xsl:with-param name="nestinglevel" select="$nestinglevel"/>
                            <xsl:with-param name="checkIsClosed" select="$checkIsClosed"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:if>
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
                        <xsl:value-of select="$context"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="choice" mode="doTemplateRules">
        <xsl:param name="itemlabel"/>
        <xsl:param name="context"/>
        <xsl:param name="uniqueId"/>
        <xsl:param name="uniqueEffectiveTime"/>
        <xsl:param name="isClosed" as="xs:boolean"/>
        <xsl:param name="checkIsClosed" as="xs:boolean"/>
        <xsl:param name="nestinglevel"/>
        <xsl:param name="predicatetest" select="false()" as="xs:boolean"/>
        <xsl:param name="seethisthingurl"/>
        <xsl:param name="contextSuffix"/>
        
        <xsl:for-each select="element|include|choice">
            <!-- cardinality already checked by another rule -->
            <xsl:apply-templates select="." mode="doTemplateRules">
                <xsl:with-param name="rc" select="."/>
                <xsl:with-param name="itemlabel" select="$itemlabel"/>
                <xsl:with-param name="context" select="$context"/>
                <xsl:with-param name="uniqueId" select="$uniqueId"/>
                <xsl:with-param name="uniqueEffectiveTime" select="$uniqueEffectiveTime"/>
                <xsl:with-param name="isClosed">
                    <xsl:choose>
                        <xsl:when test="$switchCreateSchematronClosed=true()">
                            <xsl:value-of select="'true'"/>
                        </xsl:when>
                        <xsl:when test="@isClosed">
                            <xsl:value-of select="@isClosed"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$isClosed"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
                <xsl:with-param name="checkIsClosed" select="$checkIsClosed"/>
                <xsl:with-param name="nestinglevel" select="if (self::choice) then ($nestinglevel) else ($nestinglevel+1)"/>
                <xsl:with-param name="predicatetest" select="$predicatetest"/>
                <xsl:with-param name="seethisthingurl" select="$seethisthingurl"/>
                <xsl:with-param name="contextSuffix" select="$contextSuffix"/>
            </xsl:apply-templates>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="element|include" mode="doTemplateRulesForClosed">
        <xsl:param name="itemlabel"/>
        <xsl:param name="context"/>
        <xsl:param name="uniqueId"/>
        <xsl:param name="uniqueEffectiveTime"/>
        <xsl:param name="isClosed" as="xs:boolean"/>
        <xsl:param name="checkIsClosed" as="xs:boolean"/>
        <xsl:param name="nestinglevel"/>
        <xsl:param name="predicatetest" select="false()" as="xs:boolean"/>
        <xsl:param name="seethisthingurl"/>
        <xsl:param name="contextSuffix"/>
        
        <xsl:choose>
            <!-- an element with both name and contains -->
            <xsl:when test="@name and @contains">
                <!-- 
                    Merge rc with @contains before continuing, or leave rc as-is
                -->
                <xsl:variable name="rcmerged">
                    <!-- lookup contained template content -->
                    <xsl:variable name="rccontent">
                        <xsl:call-template name="getRulesetContent">
                            <xsl:with-param name="ruleset" select="@contains"/>
                            <xsl:with-param name="flexibility" select="@flexibility"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <!-- get item label for this template -->
                    <xsl:variable name="newitemlabel">
                        <xsl:call-template name="getNewItemLabel">
                            <xsl:with-param name="rc" select="$rccontent/template"/>
                            <xsl:with-param name="default" select="$itemlabel"/>
                        </xsl:call-template>
                    </xsl:variable>
                    
                    <!-- merge stuff -->
                    <element>
                        <xsl:copy-of select="@* except (@contains|@flexibility)" copy-namespaces="no"/>
                        <xsl:apply-templates select="./node()" mode="mergeContainingTemplate">
                            <xsl:with-param name="mergeNodes" select="$rccontent/template/(element|include|choice)"/>
                            <xsl:with-param name="mergeContext" select="exists($rccontent/template/context[@id=('*','**')])"/>
                            <xsl:with-param name="mergeLabel" select="$newitemlabel"/>
                        </xsl:apply-templates>
                        <xsl:apply-templates select="$rccontent/template/(element|include|choice)" mode="mergeContainedTemplate">
                            <xsl:with-param name="mergeNodes" select="./(element|include|choice)"/>
                            <xsl:with-param name="mergeContext" select="exists($rccontent/template/context[@id=('*','**')])"/>
                            <xsl:with-param name="mergeLabel" select="$newitemlabel"/>
                        </xsl:apply-templates>
                    </element>
                </xsl:variable>
                
                <xsl:call-template name="doTemplateRules">
                    <xsl:with-param name="rc" select="$rcmerged/element"/>
                    <xsl:with-param name="previousitemlabel" select="$itemlabel"/>
                    <xsl:with-param name="previousContext" select="$context"/>
                    <xsl:with-param name="previousUniqueId" select="$uniqueId"/>
                    <xsl:with-param name="previousUniqueEffectiveTime" select="$uniqueEffectiveTime"/>
                    <xsl:with-param name="isClosed" select="$isClosed"/>
                    <xsl:with-param name="nestinglevel" select="$nestinglevel"/>
                    <xsl:with-param name="checkIsClosed" select="$checkIsClosed"/>
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
                    <xsl:with-param name="previousContext" select="$context"/>
                    <xsl:with-param name="previousUniqueId" select="$uniqueId"/>
                    <xsl:with-param name="previousUniqueEffectiveTime" select="$uniqueEffectiveTime"/>
                    <xsl:with-param name="isClosed" select="$isClosed"/>
                    <xsl:with-param name="nestinglevel" select="$nestinglevel"/>
                    <xsl:with-param name="checkIsClosed" select="$checkIsClosed"/>
                </xsl:call-template>
            </xsl:when>
            <!-- an include with a ref -->
            <xsl:when test="@ref">
                <xsl:variable name="rccontent">
                    <xsl:call-template name="getRulesetContent">
                        <xsl:with-param name="ruleset" select="@ref"/>
                        <xsl:with-param name="flexibility" select="@flexibility"/>
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
                        <xsl:value-of select="count($rccontent/*/*)"/>
                    </xsl:with-param>
                </xsl:call-template>
                
                <xsl:variable name="newitemlabel">
                    <xsl:call-template name="getNewItemLabel">
                        <xsl:with-param name="rc" select="$rccontent/template"/>
                        <xsl:with-param name="default" select="$itemlabel"/>
                    </xsl:call-template>
                </xsl:variable>
                
                <!--<xsl:if test="not($rccontent/template/context[@id])">-->
                    <xsl:call-template name="logMessage">
                        <xsl:with-param name="level" select="$logDEBUG"/>
                        <xsl:with-param name="msg">
                            <xsl:text>PROCESSING INCLUDE ...</xsl:text>
                        </xsl:with-param>
                    </xsl:call-template>
                    <xsl:for-each select="$rccontent/*/(element|include|choice)">
                        <xsl:call-template name="doTemplateRules">
                            <xsl:with-param name="rc" select="."/>
                            <xsl:with-param name="previousitemlabel" select="$newitemlabel"/>
                            <xsl:with-param name="previousContext" select="$context"/>
                            <xsl:with-param name="previousUniqueId" select="$rccontent/template/@id"/>
                            <xsl:with-param name="previousUniqueEffectiveTime" select="$rccontent/template/@effectiveDate"/>
                            <xsl:with-param name="isClosed" select="$isClosed"/>
                            <xsl:with-param name="nestinglevel" select="$nestinglevel"/>
                            <xsl:with-param name="checkIsClosed" select="$checkIsClosed"/>
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
                    <xsl:value-of select="$context"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="choice" mode="doTemplateRulesForClosed">
        <xsl:param name="itemlabel"/>
        <xsl:param name="context"/>
        <xsl:param name="uniqueId"/>
        <xsl:param name="uniqueEffectiveTime"/>
        <xsl:param name="isClosed" as="xs:boolean"/>
        <xsl:param name="checkIsClosed" as="xs:boolean"/>
        <xsl:param name="nestinglevel"/>
        <xsl:param name="predicatetest" select="false()" as="xs:boolean"/>
        <xsl:param name="seethisthingurl"/>
        <xsl:param name="contextSuffix"/>
        
        <xsl:for-each select="element|include|choice">
            <!-- cardinality already checked by another rule -->
            <xsl:apply-templates select="." mode="doTemplateRulesForClosed">
                <xsl:with-param name="rc" select="."/>
                <xsl:with-param name="itemlabel" select="$itemlabel"/>
                <xsl:with-param name="context" select="$context"/>
                <xsl:with-param name="uniqueId" select="$uniqueId"/>
                <xsl:with-param name="uniqueEffectiveTime" select="$uniqueEffectiveTime"/>
                <xsl:with-param name="isClosed">
                    <xsl:choose>
                        <xsl:when test="$switchCreateSchematronClosed=true()">
                            <xsl:value-of select="'true'"/>
                        </xsl:when>
                        <xsl:when test="@isClosed">
                            <xsl:value-of select="@isClosed"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$isClosed"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
                <xsl:with-param name="checkIsClosed" select="$checkIsClosed"/>
                <xsl:with-param name="nestinglevel" select="if (self::choice) then ($nestinglevel) else ($nestinglevel+1)"/>
                <xsl:with-param name="predicatetest" select="$predicatetest"/>
                <xsl:with-param name="seethisthingurl" select="$seethisthingurl"/>
                <xsl:with-param name="contextSuffix" select="$contextSuffix"/>
            </xsl:apply-templates>
        </xsl:for-each>
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
    </xd:doc>
    <xsl:template match="*" mode="mergeContainingTemplate">
        <xsl:param name="mergeNodes" as="node()*"/>
        <xsl:param name="mergeContext" as="xs:boolean"/>
        <xsl:param name="mergeLabel"/>
        
        <xsl:choose>
            <xsl:when test="self::element">
                <xsl:variable name="elemname">
                    <xsl:call-template name="getWherePathFromNodeset">
                        <xsl:with-param name="rccontent" select="."/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="comparenames">
                    <xsl:apply-templates select="$mergeNodes[self::element]" mode="getNamesForMerge"/>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="not($elemname=tokenize($comparenames,' @@ '))">
                        <xsl:copy-of select="self::node()" copy-namespaces="no"/>        
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="comparenode">
                            <xsl:for-each select="$mergeNodes[self::element]">
                                <xsl:variable name="elemnametmpl">
                                    <xsl:call-template name="getWherePathFromNodeset">
                                        <xsl:with-param name="rccontent" select="."/>
                                    </xsl:call-template>
                                </xsl:variable>
                                <xsl:if test="$elemnametmpl=$elemname">
                                    <xsl:copy-of select="." copy-namespaces="no"/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:variable>
                        <element>
                            <xsl:copy-of select="@*" copy-namespaces="no"/>
                            <!-- Copy these as they have use for determining predicates/item labels -->
                            <!--xsl:copy-of select="item|attribute|vocabulary" copy-namespaces="no"/-->
                            <xsl:apply-templates select="node()" mode="mergeContainingTemplate">
                                <xsl:with-param name="mergeNodes" select="$comparenode/*/(element|include|choice)"/>
                                <xsl:with-param name="mergeContext" select="$mergeContext"/>
                                <xsl:with-param name="mergeLabel" select="$mergeLabel"/>
                            </xsl:apply-templates>
                            <xsl:apply-templates select="$comparenode/*/(element|include|choice)" mode="mergeContainedTemplate">
                                <xsl:with-param name="mergeNodes" select="./(element|include|choice)"/>
                                <xsl:with-param name="mergeContext" select="$mergeContext"/>
                                <xsl:with-param name="mergeLabel" select="$mergeLabel"/>
                            </xsl:apply-templates>
                        </element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <!-- 2DO Try to merge choices between element[@contains] and the contained template? -->
                <!-- 2DO Try to merge includes between element[@contains] and the contained template? -->
                <xsl:copy-of select="self::node()" copy-namespaces="no"/>
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
    </xd:doc>
    <xsl:template match="*" mode="mergeContainedTemplate">
        <xsl:param name="mergeNodes" as="node()*"/>
        <xsl:param name="mergeContext" as="xs:boolean"/>
        <xsl:param name="mergeLabel"/>
        
        <xsl:choose>
            <xsl:when test="self::element">
                <xsl:variable name="elemname">
                    <xsl:call-template name="getWherePathFromNodeset">
                        <xsl:with-param name="rccontent" select="."/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="comparenames">
                    <xsl:apply-templates select="$mergeNodes[self::element]" mode="getNamesForMerge"/>
                </xsl:variable>
                <xsl:if test="not($elemname=tokenize($comparenames,' @@ '))">
                    <xsl:copy copy-namespaces="no">
                        <xsl:copy-of select="@*" copy-namespaces="no"/>
                        <xsl:attribute name="mergedContent" select="$mergeContext"/>
                        <xsl:if test="string-length($mergeLabel)>0">
                            <xsl:attribute name="mergedLabel" select="$mergeLabel"/>
                        </xsl:if>
                        <xsl:copy-of select="node()" copy-namespaces="no"/>
                    </xsl:copy>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <!-- 2DO: Try to merge choices between element[@contains] and the contained template? -->
                <!-- 2DO: Try to merge includes between element[@contains] and the contained template? -->
                <xsl:copy copy-namespaces="no">
                    <xsl:copy-of select="@*" copy-namespaces="no"/>
                    <xsl:attribute name="mergedContent" select="'true'"/>
                    <xsl:if test="string-length($mergeLabel)>0">
                        <xsl:attribute name="mergedLabel" select="$mergeLabel"/>
                    </xsl:if>
                    <xsl:copy-of select="node()" copy-namespaces="no"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Should add recursion loop check? -->
    <xsl:template match="element|include|choice" mode="getNamesForMerge">
        <xsl:choose>
            <xsl:when test="self::element">
                <xsl:call-template name="getWherePathFromNodeset">
                    <xsl:with-param name="rccontent" select="."/>
                </xsl:call-template>
                <xsl:text> @@ </xsl:text>
            </xsl:when>
            <xsl:when test="self::include">
                <xsl:variable name="rccontent">
                    <xsl:call-template name="getRulesetContent">
                        <xsl:with-param name="ruleset" select="@ref"/>
                        <xsl:with-param name="flexibility" select="@flexibility"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:apply-templates select="$rccontent/template/element|$rccontent/template/include|$rccontent/template/choice" mode="getNamesForIsClosedTemplate"/>
            </xsl:when>
            <xsl:when test="self::choice">
                <xsl:apply-templates select="element|include|choice" mode="getNamesForIsClosed"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <!-- Should add recursion loop check? -->
    <xsl:template match="element|include|choice" mode="getNamesForIsClosed">
        <xsl:choose>
            <xsl:when test="self::element">
                <xsl:text>self::</xsl:text>
                <xsl:call-template name="getWherePathFromNodeset">
                    <xsl:with-param name="rccontent" select="."/>
                </xsl:call-template>
                <xsl:text>|</xsl:text>
            </xsl:when>
            <xsl:when test="self::include">
                <xsl:variable name="rccontent">
                    <xsl:call-template name="getRulesetContent">
                        <xsl:with-param name="ruleset" select="@ref"/>
                        <xsl:with-param name="flexibility" select="@flexibility"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:apply-templates select="$rccontent/template/element|$rccontent/template/include|$rccontent/template/choice" mode="getNamesForIsClosedTemplate"/>
            </xsl:when>
            <xsl:when test="self::choice">
                <xsl:apply-templates select="element|include|choice" mode="getNamesForIsClosed"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <!-- Should add recursion loop check? -->
    <xsl:template match="element|include|choice" mode="getNamesForIsClosedTemplate">
        <xsl:param name="previousContext"/>
        
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
                </xsl:call-template>
                <!--xsl:value-of select="$context"/-->
                <xsl:text>|</xsl:text>
            </xsl:when>
            <xsl:when test="self::include">
                <xsl:variable name="rccontent">
                    <xsl:call-template name="getRulesetContent">
                        <xsl:with-param name="ruleset" select="@ref"/>
                        <xsl:with-param name="flexibility" select="@flexibility"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:apply-templates select="$rccontent/template/element|$rccontent/template/include|$rccontent/template/choice" mode="getNamesForIsClosedTemplate">
                    <xsl:with-param name="previousContext" select="$previousContext"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="self::choice">
                <xsl:apply-templates select="element|include|choice" mode="getNamesForIsClosedTemplate"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="getNewItemLabel">
        <!--
            get item reference or description (to be shown in every assert/report)
            an item desc has priority over an item ref number, so
            - if item/desc is given use it
            - if item/@label is not given then take it over from previous (previousitemlabel)
            - if item/@label is given use it and build it with possible project prefix
        -->
        <!-- node set shall be a template -->
        <xsl:param name="rc"/>
        <!-- the default if getting a new item failed -->
        <xsl:param name="default"/>
       
        <xsl:choose>
            <xsl:when test="$rc[name()='item']/desc[@language=$defaultLanguage][string-length(.)>0]">
                <xsl:value-of select="($rc[name()='item']/desc[@language=$defaultLanguage][string-length(.)>0])[1]"/>
            </xsl:when>
            <xsl:when test="$rc[name()='item']/@label[string-length(.)>0]">
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
            <xsl:when test="$rc/name()='template' and count($rc/context)>0">
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
            <ctx>
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
        <xsl:text>&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>
        
        <MERGERCONTEXT>
            <xsl:for-each select="$listOfSameContext/*">
                <xsl:copy-of select="same"/>
            </xsl:for-each>
        </MERGERCONTEXT>
        
        <xsl:text>&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>
        -->
        <!-- 
            run thru all rules in set 1 (including comments)
        -->
        <xsl:for-each select="$rs1/*/(comment()|*)">
            <xsl:variable name="ctx" select="@context"/>
            <xsl:choose>
                <xsl:when test="self::comment()">
                    <xsl:text>&#10;</xsl:text>
                    <xsl:text>&#10;</xsl:text>
                    <xsl:copy-of select="."/>
                </xsl:when>
                <xsl:when test="self::*:rule">
                    <xsl:text>&#10;</xsl:text>
                    <xsl:choose>
                        <xsl:when test="count($listOfSameContext/*/same[@context=$ctx])>0">
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
                    <xsl:text>&#10;</xsl:text>
                    <xsl:text>&#10;</xsl:text>
                    <xsl:copy-of select="."/>
                </xsl:when>
                <xsl:when test="self::*:rule">
                    <xsl:text>&#10;</xsl:text>
                    <xsl:choose>
                        <xsl:when test="count($listOfSameContext/*/same[@context=$ctx])>0">
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

    <xsl:template name="doCopyIntoSchematronNamespace">
        <xsl:choose>
            <xsl:when test="self::text()|self::comment()|self::processing-instruction()">
                <xsl:copy-of select="self::node()"/>
            </xsl:when>
            <xsl:when test="self::*[namespace-uri()='' or namespace-uri()='http://purl.oclc.org/dsdl/schematron']">
                <xsl:element name="{local-name()}" xmlns="http://purl.oclc.org/dsdl/schematron">
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
    
    <xsl:template name="doDefineVariable-not-used">
        <xsl:variable name="theCode">
            <xsl:if test="string-length(code/@code)>0 or string-length(code/@codeSystem)>0">
                <xsl:text>[</xsl:text>
                <xsl:value-of select="$projectDefaultElementNamespace"/>
                <xsl:text>code</xsl:text>
            </xsl:if>
            <xsl:if test="string-length(code/@code)>0">
                <xsl:text>[@code='</xsl:text>
                <xsl:value-of select="code/@code"/>
                <xsl:text>']</xsl:text>
            </xsl:if>
            <xsl:if test="string-length(code/@codeSystem)>0">
                <xsl:text>[@codeSystem='</xsl:text>
                <xsl:value-of select="code/@codeSystem"/>
                <xsl:text>']</xsl:text>
            </xsl:if>
            <xsl:if test="string-length(code/@code)>0 or string-length(code/@codeSystem)>0">
                <xsl:text>]</xsl:text>
            </xsl:if>
        </xsl:variable>
        <!-- assertion: use/@name is not empty and contains a valid xpath to a data type value, typed INT or CE or TS -->
        <let name="temp1_{@name}" value="{@path}{$theCode}/{use/@path}"/>
        <xsl:choose>
            <xsl:when test="use/@as='INT'">
                <let name="{@name}" value="if ($temp1_{@name} castable as xs:integer) then ($temp1_{@name} cast as xs:integer) else false"/>
            </xsl:when>
            <xsl:when test="use/@as='CE'">
                <let name="{@name}" value="$temp1_{@name}"/>
            </xsl:when>
            <xsl:when test="use/@as='TS.JULIAN'">
                <let name="temp2_{@name}" value="concat(substring($temp1_{@name}, 1, 4), '-', substring($temp1_{@name}, 5, 2), '-', substring($temp1_{@name}, 7, 2))"/>
                <let name="temp3_{@name}" value="if ($temp2_{@name} castable as xs:date) then ($temp2_{@name} cast as xs:date) else false"/>
                <!-- modified julian day, days after Nov 17, 1858 -->
                <let name="{@name}" value="days-from-duration($temp3_{@name} - xs:date('1858-11-17'))"/>
            </xsl:when>
            <xsl:when test="use/@as='TS'">
                <let name="{@name}" value="$temp1_{@name}"/>
            </xsl:when>
            <xsl:otherwise>
                <let name="{@name}" value="false"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="template" mode="createDefaultInstance">
        <xsl:param name="rt"/>
        <hl7:instance name="{@name}">
            <xsl:choose>
                <xsl:when test="context[@path][not(matches(@path,'^/+$'))]">
                    <xsl:variable name="elmname">
                        <xsl:choose>
                            <xsl:when test="contains(context/@path, '[')">
                                <xsl:value-of select="replace(substring-before(context/@path, '['),'^/+','')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="replace(context/@path,'^/+','')"/>
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
                    
                    <xsl:element name="{$elmname}" namespace="{$elmns}">
                        <xsl:attribute name="original" select="context/@path"/>
                        <xsl:attribute name="withpredicate" select="context/@path"/>
                        
                        <xsl:apply-templates select="element|include|choice" mode="createDefaultInstance">
                            <xsl:with-param name="rt" select="$rt"/>
                            <xsl:with-param name="tid" select="@id"/>
                            <xsl:with-param name="tef" select="@effectiveDate"/>
                            <xsl:with-param name="previousitemlabel" select="@name"/>
                        </xsl:apply-templates>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="element|include|choice" mode="createDefaultInstance">
                        <xsl:with-param name="rt" select="$rt"/>
                        <xsl:with-param name="tid" select="@id"/>
                        <xsl:with-param name="tef" select="@effectiveDate"/>
                        <xsl:with-param name="previousitemlabel" select="@name"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
        </hl7:instance>
    </xsl:template>
    
    <xsl:template match="element" mode="createDefaultInstance">
        <xsl:param name="rt"/>
        <xsl:param name="tid"/>
        <xsl:param name="tef"/>
        <xsl:param name="previousitemlabel"/>
        <xsl:param name="inheritedminimumMultiplicity"/>
        <xsl:param name="inheritedmaximumMultiplicity"/>
        <xsl:param name="inheritedConformance"/>
        <xsl:param name="inheritedIsMandatory"/>
        
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
        <xsl:variable name="minimumMultiplicity">
            <xsl:choose>
                <xsl:when test="string-length($inheritedminimumMultiplicity)>0">
                    <xsl:value-of select="$inheritedminimumMultiplicity"/>
                </xsl:when>
                <xsl:when test="string-length(@minimumMultiplicity)>0">
                    <xsl:value-of select="@minimumMultiplicity"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="maximumMultiplicity">
            <xsl:choose>
                <xsl:when test="string-length($inheritedmaximumMultiplicity)>0">
                    <xsl:value-of select="$inheritedmaximumMultiplicity"/>
                </xsl:when>
                <xsl:when test="string-length(@maximumMultiplicity)>0">
                    <xsl:value-of select="@maximumMultiplicity"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="isMandatory">
            <xsl:choose>
                <xsl:when test="string-length($inheritedIsMandatory)>0">
                    <xsl:value-of select="$inheritedIsMandatory"/>
                </xsl:when>
                <xsl:when test="string-length(@isMandatory)>0">
                    <xsl:value-of select="@isMandatory"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'false'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="conformance">
            <xsl:choose>
                <xsl:when test="string-length($inheritedConformance)>0">
                    <xsl:value-of select="$inheritedConformance"/>
                </xsl:when>
                <xsl:when test="string-length(@conformance)>0">
                    <xsl:value-of select="@conformance"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="cardconf">
            <xsl:call-template name="doCardConf">
                <xsl:with-param name="minimumMultiplicity" select="$minimumMultiplicity"/>
                <xsl:with-param name="maximumMultiplicity" select="$maximumMultiplicity"/>
                <xsl:with-param name="isMandatory" select="$isMandatory"/>
                <xsl:with-param name="conformance" select="$conformance"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="@name and @contains">
                <!-- lookup contained template content -->
                <xsl:variable name="rccontent">
                    <xsl:call-template name="getRulesetContent">
                        <xsl:with-param name="ruleset" select="@contains"/>
                        <xsl:with-param name="flexibility" select="@flexibility"/>
                    </xsl:call-template>
                </xsl:variable>
                <!-- 
                    Merge rc with @contains before continuing, or leave rc as-is
                -->
                <xsl:variable name="rcmerged">
                    <!-- get item label for this template -->
                    <xsl:variable name="newitemlabel">
                        <xsl:call-template name="getNewItemLabel">
                            <xsl:with-param name="rc" select="$rccontent/template"/>
                            <xsl:with-param name="default" select="$previousitemlabel"/>
                        </xsl:call-template>
                    </xsl:variable>
                    
                    <!-- merge stuff -->
                    <element>
                        <xsl:copy-of select="@* except (@contains|@flexibility)" copy-namespaces="no"/>
                        <xsl:apply-templates select="./node()" mode="mergeContainingTemplate">
                            <xsl:with-param name="mergeNodes" select="$rccontent/template/(element|include|choice)"/>
                            <xsl:with-param name="mergeContext" select="exists($rccontent/template/context[@id=('*','**')])"/>
                            <xsl:with-param name="mergeLabel" select="$newitemlabel"/>
                        </xsl:apply-templates>
                        <xsl:apply-templates select="$rccontent/template/(element|include|choice)" mode="mergeContainedTemplate">
                            <xsl:with-param name="mergeNodes" select="./(element|include|choice)"/>
                            <xsl:with-param name="mergeContext" select="exists($rccontent/template/context[@id=('*','**')])"/>
                            <xsl:with-param name="mergeLabel" select="$newitemlabel"/>
                        </xsl:apply-templates>
                    </element>
                </xsl:variable>
                
                <xsl:variable name="itemlabel">
                    <xsl:call-template name="getNewItemLabel">
                        <xsl:with-param name="rc" select="$rccontent/template"/>
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
                        </xsl:call-template>
                    </xsl:attribute>
                    <xsl:attribute name="label" select="$itemlabel"/>
                    <xsl:if test="string-length($cardconf)>0">
                        <xsl:attribute name="cardconf" select="$cardconf"/>
                    </xsl:if>
                    <xsl:copy-of select="@datatype"/>
                    <xsl:if test="string-length($minimumMultiplicity)>0">
                        <xsl:attribute name="minimumMultiplicity" select="$minimumMultiplicity"/>
                    </xsl:if>
                    <xsl:if test="string-length($maximumMultiplicity)>0">
                        <xsl:attribute name="maximumMultiplicity" select="$maximumMultiplicity"/>
                    </xsl:if>
                    <xsl:if test="string-length($conformance)>0">
                        <xsl:attribute name="conformance" select="$conformance"/>
                    </xsl:if>
                    <xsl:if test="string($isMandatory)='true'">
                        <xsl:attribute name="isMandatory" select="'true'"/>
                    </xsl:if>
                    <xsl:apply-templates select="$rcmerged/element/attribute" mode="createDefaultInstance"/>
                    <xsl:apply-templates select="$rcmerged/element/(element|include|choice)" mode="createDefaultInstance">
                        <xsl:with-param name="rt" select="$rt"/>
                        <xsl:with-param name="tid" select="$rccontent/template/@id"/><!-- REVISIT THIS LOGIC -->
                        <xsl:with-param name="tef" select="$rccontent/template/@effectiveDate"/><!-- REVISIT THIS LOGIC -->
                        <xsl:with-param name="previousitemlabel" select="$itemlabel"/>
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
                        </xsl:call-template>
                    </xsl:attribute>
                    <xsl:attribute name="label" select="$previousitemlabel"/>
                    <xsl:if test="string-length($cardconf)>0">
                        <xsl:attribute name="cardconf" select="$cardconf"/>
                    </xsl:if>
                    <xsl:copy-of select="@datatype"/>
                    <xsl:if test="string-length($minimumMultiplicity)>0">
                        <xsl:attribute name="minimumMultiplicity" select="$minimumMultiplicity"/>
                    </xsl:if>
                    <xsl:if test="string-length($maximumMultiplicity)>0">
                        <xsl:attribute name="maximumMultiplicity" select="$maximumMultiplicity"/>
                    </xsl:if>
                    <xsl:if test="string-length($conformance)>0">
                        <xsl:attribute name="conformance" select="$conformance"/>
                    </xsl:if>
                    <xsl:if test="string($isMandatory)='true'">
                        <xsl:attribute name="isMandatory" select="'true'"/>
                    </xsl:if>
                    <xsl:apply-templates select="attribute" mode="createDefaultInstance"/>
                    <xsl:apply-templates select="vocabulary|property" mode="createDefaultInstance"/>
                    <xsl:apply-templates select="element|include|choice" mode="createDefaultInstance">
                        <xsl:with-param name="rt" select="$rt"/>
                        <xsl:with-param name="tid" select="$tid"/>
                        <xsl:with-param name="tef" select="$tef"/>
                        <xsl:with-param name="previousitemlabel" select="$previousitemlabel"/>
                    </xsl:apply-templates>
                </xsl:element>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
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
    
    <xsl:template name="doId">
        <xsl:param name="elid"/>
        <xsl:param name="rt"/>
        <xsl:param name="tid"/>
        <xsl:param name="tef"/>
        <xsl:if test="not(empty($elid) or $elid='')">
            <xsl:for-each select="($allTemplatesAssociations/*/templateAssociation[@templateId=$tid and @effectiveDate=$tef])[1]/concept[@elementId=$elid]">
                <xsl:variable name="ref" select="@ref"/>
                <!-- get concept ref within representingTemplate -->
                <xsl:variable name="ta" select="$rt/concept[@ref=$ref]/@ref"/>
                <xsl:variable name="tt">
                    <xsl:value-of select="($allDatasetConceptsFlat//concept[@id=$ta]/name)[1]"/>
                </xsl:variable>
                <xsl:if test="string-length($ta)>0">
                    <!--xsl:attribute name="conceptId">
                        <xsl:value-of select="$ta"/>
                    </xsl:attribute-->
                    <concept ref="{$ta}">
                        <xsl:attribute name="refname">
                            <xsl:call-template name="doShorthandId">
                                <xsl:with-param name="id" select="$ta"/>
                            </xsl:call-template>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="string-length($tt)>0">
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
                            <xsl:with-param name="id" select="$ta"/>
                            <xsl:with-param name="rt" select="$rt"/>
                            <xsl:with-param name="tid" select="$tid"/>
                            <xsl:with-param name="tef" select="$tef"/>
                        </xsl:call-template>
                    </concept>
                </xsl:if>
            </xsl:for-each>            
        </xsl:if>
    </xsl:template>
    
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
                
                <xsl:if test="count($communityitems//associations/association[object[@type='DE' and @ref=$id]]/data)>0">
                    <xsl:variable name="comlabel" select="($communityitems/*/desc)[1]"/>
                    <community name="{$communityname}" label="{$comlabel}">
                        <xsl:for-each select="$communityitems//associations/association[object[@type='DE' and @ref=$id]]/data">
                            <xsl:variable name="type" select="@type"/>
                            <xsl:variable name="label" select="$communityitems/*/prototype/data[@type=$type]/@label"/>
                            <data type="{$type}" label="{$label}">
                                <xsl:copy-of select="node()"/>
                            </data>
                        </xsl:for-each>
                    </community>
                </xsl:if>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="include" mode="createDefaultInstance">
        <xsl:param name="rt"/>
        <xsl:param name="tid"/>
        <xsl:param name="tef"/>
        <xsl:param name="previousitemlabel"/>
        <xsl:variable name="rccontent">
            <xsl:call-template name="getRulesetContent">
                <xsl:with-param name="ruleset" select="@ref"/>
                <xsl:with-param name="flexibility" select="@flexibility"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="itemlabel">
            <xsl:call-template name="getNewItemLabel">
                <xsl:with-param name="rc" select="$rccontent/*"/>
                <xsl:with-param name="default" select="$previousitemlabel"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:apply-templates select="$rccontent/template/attribute" mode="createDefaultInstance"/>
        <xsl:choose>
            <xsl:when test="count($rccontent/template/element|$rccontent/template/include|$rccontent/template/choice)=1">
                <xsl:apply-templates select="$rccontent/template/element|$rccontent/template/include|$rccontent/template/choice" mode="createDefaultInstance">
                    <xsl:with-param name="rt" select="$rt"/>
                    <xsl:with-param name="tid" select="$rccontent/template/@id"/>
                    <xsl:with-param name="tef" select="$rccontent/template/@effectiveDate"/>
                    <xsl:with-param name="previousitemlabel" select="$itemlabel"/>
                    <xsl:with-param name="inheritedminimumMultiplicity" select="@minimumMultiplicity"/>
                    <xsl:with-param name="inheritedmaximumMultiplicity" select="@maximumMultiplicity"/>
                    <xsl:with-param name="inheritedConformance" select="@conformance"/>
                    <xsl:with-param name="inheritedIsMandatory" select="@isMandatory"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$rccontent/template/element|$rccontent/template/include|$rccontent/template/choice" mode="createDefaultInstance">
                    <xsl:with-param name="rt" select="$rt"/>
                    <xsl:with-param name="tid" select="$rccontent/template/@id"/>
                    <xsl:with-param name="tef" select="$rccontent/template/@effectiveDate"/>
                    <xsl:with-param name="previousitemlabel" select="$itemlabel"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="choice" mode="createDefaultInstance">
        <xsl:param name="rt"/>
        <xsl:param name="tid"/>
        <xsl:param name="tef"/>
        <xsl:param name="previousitemlabel"/>
        
        <xsl:variable name="cardconf">
            <xsl:call-template name="doCardConf">
                <xsl:with-param name="minimumMultiplicity" select="@minimumMultiplicity"/>
                <xsl:with-param name="maximumMultiplicity" select="@maximumMultiplicity"/>
                <xsl:with-param name="isMandatory" select="@isMandatory"/>
                <xsl:with-param name="conformance" select="@conformance"/>
            </xsl:call-template>
        </xsl:variable>
        
        <choice>
            <xsl:copy-of select="@minimumMultiplicity|@maximumMultiplicity"/>
            <xsl:if test="string-length($cardconf)>0">
                <xsl:attribute name="cardconf" select="$cardconf"/>
            </xsl:if>
            <xsl:apply-templates select="element|include|choice" mode="createDefaultInstance">
                <xsl:with-param name="rt" select="$rt"/>
                <xsl:with-param name="tid" select="$tid"/>
                <xsl:with-param name="tef" select="$tef"/>
                <xsl:with-param name="previousitemlabel" select="$previousitemlabel"/>
            </xsl:apply-templates>
        </choice>
    </xsl:template>
    
    <xsl:template match="vocabulary|property" mode="createDefaultInstance">
        <xsl:choose>
            <xsl:when test="name()='vocabulary'">
                <xsl:for-each select="@code|@codeSystem|@valueSet|@flexibility">
                    <xsl:attribute name="{name()}" select="."/>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="attribute" mode="createDefaultInstance">
        <xsl:for-each select="@extension|@operator|@contextControlCode|@institutionSpecified|@independentInd|@determinerCode|@contextConductionInd|@inversionInd|@negationInd">
            <!-- cache attribute name and value -->
            <xsl:variable name="attname" select="name(.)"/>
            <xsl:variable name="attvalue" select="."/>
            <xsl:attribute name="{$attname}" select="$attvalue"/>
        </xsl:for-each>
        <xsl:for-each select="@unit|@code|@classCode|@moodCode|@typeCode|@mediaType|@representation|@use|@qualifier|@nullFlavor">
            <xsl:variable name="attname" select="name(.)"/>
            <xsl:variable name="attvalue" select="."/>
            <xsl:attribute name="{$attname}" select="$attvalue"/>
        </xsl:for-each>
        <xsl:if test="@name">
            <xsl:variable name="an" select="@name"/>
            <xsl:variable name="av" select="@value"/>
            <xsl:choose>
                <xsl:when test="string-length($av)>0">
                    <xsl:attribute name="{$an}" select="$av"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="{$an}" select="'…'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*" mode="createOutputRow">
        <xsl:param name="nestinglevel"/>
        <xsl:if test="not(name()='community' or name()='concept')">
            <tr bgcolor="#eeeeee">
                <td valign="top">
                    <table>
                        <xsl:call-template name="doIndentLevel">
                            <xsl:with-param name="level" select="$nestinglevel"/>
                        </xsl:call-template>
                        <td>
                            <tt>
                                <!--xsl:text>&lt;</xsl:text-->
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
                                <!--xsl:text>&gt;</xsl:text-->
                            </tt>
                        </td>
                    </table>
                </td>
                <td valign="top">
                    <xsl:value-of select="@datatype"/>
                </td>
                <td valign="top">
                    <xsl:value-of select="@cardconf"/>
                </td>
                <td valign="top">
                    <xsl:for-each select="concept">
                        <xsl:call-template name="doShorthandId">
                            <xsl:with-param name="id" select="@ref"/>
                        </xsl:call-template>
                        <xsl:if test="position() != last()">
                            <br/>
                        </xsl:if>
                    </xsl:for-each>
                </td>
                <td valign="top">
                    <xsl:for-each select="concept">
                    <xsl:value-of select="@conceptText"/>
                        <xsl:if test="position() != last()">
                            <br/>
                        </xsl:if>
                    </xsl:for-each>
                </td>
                <td valign="top">
                    <xsl:value-of select="@label"/>
                </td>
            </tr>
            <xsl:for-each select="concept[community]">
                <tr>
                    <td>&#160;</td>
                    <td valign="top" colspan="5" style="border: 1px solid #CCCCA3;">
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
                                    <td valign="top" bgcolor="#FFEAEA">
                                        <p>
                                            <xsl:text>Community: </xsl:text>
                                            <b>
                                                <xsl:choose>
                                                    <xsl:when test="string-length(@label)>0">
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
                                                        <xsl:when test="string-length(@label)>0">
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

</xsl:stylesheet>
