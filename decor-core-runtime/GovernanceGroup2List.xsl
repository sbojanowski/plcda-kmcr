<!-- 
    ART-DECOR® STANDARD COPYRIGHT AND LICENSE NOTE
    Copyright © ART-DECOR Expert Group and ART-DECOR Open Tools GmbH
    see https://docs.art-decor.org/copyright and https://docs.art-decor.org/licenses

    This file is part of the ART-DECOR® tools suite.    
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:error="http://art-decor.org/ns/decor/template/error" xmlns:local="http://art-decor.org/functions" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="#all" version="2.0">   
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
    <xsl:include href="DECOR2html.xsl"/>
    <xsl:include href="DECOR-basics.xsl"/>
    
    <!-- 
    
    -->
    <xsl:output method="xml" indent="no" version="1.0" encoding="UTF-8" exclude-result-prefixes="#all" name="xml"/>
    <xsl:output method="html" indent="no" version="4.01" encoding="UTF-8" doctype-public="-//W3C//DTD HTML 4.01//EN" doctype-system="http://www.w3.org/TR/html4/strict.dtd"/>
    <xsl:output method="xhtml" name="xhtml" indent="no" encoding="UTF-8" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
    <!-- 
    
    -->
    <xsl:param name="language"/>
    <xsl:param name="resourcePath"/>
    <xsl:template match="/">
        <div xmlns="http://www.w3.org/1999/xhtml" id="tab-container" class="tab-container">
            <ul class="etabs">
                <li class="tab">
                    <a href="#tabs1-templates1">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'tabRulesTitleString'"/>
                        </xsl:call-template>
                        <xsl:text> 123</xsl:text>
                        <xsl:text> (</xsl:text>
                        <xsl:value-of select="count(//project/template)"/>
                        <xsl:text>)</xsl:text>
                    </a>
                </li>
                <li class="tab">
                    <a href="#tabs1-templatesa">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'tabRulesTitleString'"/>
                        </xsl:call-template>
                        <xsl:text> ABC</xsl:text>
                        <xsl:text> (</xsl:text>
                        <xsl:value-of select="count(//project/template)"/>
                        <xsl:text>)</xsl:text>
                    </a>
                </li>
                <li class="tab">
                    <a href="#tabs1-valuesets1">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'tabTerminologyTitleString'"/>
                        </xsl:call-template>
                        <xsl:text> 123</xsl:text>
                        <xsl:text> (</xsl:text>
                        <xsl:value-of select="count(//project/valueSet)"/>
                        <xsl:text>)</xsl:text>
                    </a>
                </li>
                <li class="tab">
                    <a href="#tabs1-valuesetsa">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'tabTerminologyTitleString'"/>
                        </xsl:call-template>
                        <xsl:text> ABC</xsl:text>
                        <xsl:text> (</xsl:text>
                        <xsl:value-of select="count(//project/valueSet)"/>
                        <xsl:text>)</xsl:text>
                    </a>
                </li>
            </ul>
            <xsl:apply-templates select="//group" mode="governancelist"/>
        </div>
    </xsl:template>
    <xsl:template match="group" mode="governancelist">
        <div xmlns="http://www.w3.org/1999/xhtml" id="tabs1-templates1">
            <table width="100%" class="treetable zebra-table" style="border: 1px solid #999; width=100%; border=0;" cellspacing="3" cellpadding="2">
                <tr class="headinglabel">
                        <!-- Id   Display Name   Versions / Status   Type   Project -->
                    <th style="text-align: left;">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'Id'"/>
                        </xsl:call-template>
                    </th>
                    <th style="text-align: left;">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'DisplayName'"/>
                        </xsl:call-template>
                    </th>
                    <th style="text-align: left;">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'Versions / Status'"/>
                        </xsl:call-template>
                    </th>
                    <th style="text-align: left;">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'Fromrepository'"/>
                        </xsl:call-template>
                    </th>
                    <th style="text-align: left;">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'Type'"/>
                        </xsl:call-template>
                    </th>
                    <th style="text-align: left;">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'Project(s)'"/>
                        </xsl:call-template>
                    </th>
                </tr>
                <!-- sort templates by id -->
                <xsl:for-each-group select="//project/template" group-by="@id|@ref">
                    <xsl:sort select="replace(replace (concat(@id|@ref, '.'), '\.', '.0000000000'), '.0*([0-9]{9,})', '.$1')"/>
                    <xsl:apply-templates select="." mode="governancelist">
                        <xsl:with-param name="group" select="current-group()"/>
                        <xsl:with-param name="bgcolor" select="if (position() mod 2 = 0) then '#eee' else '#fff'"/>
                        <xsl:with-param name="definingProject">
                            <xsl:choose>
                                <xsl:when test="@ref|@url">
                                    <xsl:value-of select="parent::project/@prefix"/>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:apply-templates>
                </xsl:for-each-group>
            </table>
        </div>
        <div xmlns="http://www.w3.org/1999/xhtml" id="tabs1-templatesa">
            <table width="100%" class="treetable zebra-table" style="border: 1px solid #999; width=100%; border=0;" cellspacing="3" cellpadding="2">
                <tr class="headinglabel">
                    <!-- Id   Display Name   Versions / Status   Type   Project -->
                    <th style="text-align: left;">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'Id'"/>
                        </xsl:call-template>
                    </th>
                    <th style="text-align: left;">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'DisplayName'"/>
                        </xsl:call-template>
                    </th>
                    <th style="text-align: left;">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'Versions / Status'"/>
                        </xsl:call-template>
                    </th>
                    <th style="text-align: left;">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'Fromrepository'"/>
                        </xsl:call-template>
                    </th>
                    <th style="text-align: left;">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'Type'"/>
                        </xsl:call-template>
                    </th>
                    <th style="text-align: left;">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'Project(s)'"/>
                        </xsl:call-template>
                    </th>
                </tr>
                <!-- sort templates by name -->
                <xsl:for-each-group select="//project/template" group-by="@id|@ref">
                    <xsl:sort select="(template[@id]/@displayName)[1]"/>
                    <xsl:apply-templates select="." mode="governancelist">
                        <xsl:with-param name="group" select="current-group()"/>
                        <xsl:with-param name="bgcolor" select="if (position() mod 2 = 0) then '#eee' else '#fff'"/>
                    </xsl:apply-templates>
                </xsl:for-each-group>
            </table>
        </div>
        <div xmlns="http://www.w3.org/1999/xhtml" id="tabs1-valuesets1">
            <table width="100%" class="treetable zebra-table" style="border: 1px solid #999; width=100%; border=0;" cellspacing="3" cellpadding="2">
                <tr class="headinglabel">
                    <!-- Id   Display Name   Versions / Status   Type   Project -->
                    <th style="text-align: left;">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'Id'"/>
                        </xsl:call-template>
                    </th>
                    <th style="text-align: left;">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'DisplayName'"/>
                        </xsl:call-template>
                    </th>
                    <th style="text-align: left;">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'Versions / Status'"/>
                        </xsl:call-template>
                    </th>
                    <th style="text-align: left;">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'Fromrepository'"/>
                        </xsl:call-template>
                    </th>
                    <!--<th style="text-align: left;">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'Type'"/>
                        </xsl:call-template>
                    </th>-->
                    <th style="text-align: left;">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'Project(s)'"/>
                        </xsl:call-template>
                    </th>
                </tr>
                <!-- sort value sets by id -->
                <xsl:for-each-group select="//project/valueSet" group-by="@id|@ref">
                    <xsl:sort select="replace(replace (concat(@id|@ref, '.'), '\.', '.0000000000'), '.0*([0-9]{9,})', '.$1')"/>
                    <xsl:apply-templates select="." mode="governancelist">
                        <xsl:with-param name="group" select="current-group()"/>
                        <xsl:with-param name="bgcolor" select="if (position() mod 2 = 0) then '#eee' else '#fff'"/>
                    </xsl:apply-templates>
                </xsl:for-each-group>
            </table>
        </div>
        <div xmlns="http://www.w3.org/1999/xhtml" id="tabs1-valuesetsa">
            <table width="100%" class="treetable zebra-table" style="border: 1px solid #999; width=100%; border=0;" cellspacing="3" cellpadding="2">
                <tr class="headinglabel">
                    <!-- Id   Display Name   Versions / Status   Type   Project -->
                    <th style="text-align: left;">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'Id'"/>
                        </xsl:call-template>
                    </th>
                    <th style="text-align: left;">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'DisplayName'"/>
                        </xsl:call-template>
                    </th>
                    <th style="text-align: left;">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'Versions / Status'"/>
                        </xsl:call-template>
                    </th>
                    <th style="text-align: left;">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'Fromrepository'"/>
                        </xsl:call-template>
                    </th>
                    <!-- <th style="text-align: left;">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'Type'"/>
                        </xsl:call-template>
                    </th>-->
                    <th style="text-align: left;">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'Project(s)'"/>
                        </xsl:call-template>
                    </th>
                </tr>
                <!-- sort value sets by name -->
                <xsl:for-each-group select="//project/valueSet" group-by="@id|@ref">
                    <xsl:sort select="(valueSet[@id]/@displayName)[1]"/>
                    <xsl:apply-templates select="." mode="governancelist">
                        <xsl:with-param name="group" select="current-group()"/>
                        <xsl:with-param name="bgcolor" select="if (position() mod 2 = 0) then '#eee' else '#fff'"/>
                    </xsl:apply-templates>
                </xsl:for-each-group>
            </table>
        </div>
    </xsl:template>
    <xsl:template match="template" mode="governancelist">
        <xsl:param name="group"/>
        <xsl:param name="bgcolor"/>
        <xsl:variable name="tid" select="@id|@ref"/>
        <xsl:variable name="puts">
            <puts>
                <xsl:for-each-group select="$group/ancestor::project" group-by="@prefix">
                    <xsl:variable name="dl" select="@defaultLanguage"/>
                    <put>
                        <xsl:copy-of select="@prefix"/>
                        <xsl:attribute name="name" select="name[$dl][1]/text()"/>
                        <xsl:choose>
                            <xsl:when test="template/template[@id=$tid][not(@ident)]">
                                <xsl:attribute name="isDefiningTemplate" select="'1'"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="isDefiningTemplate" select="'0'"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </put>
                </xsl:for-each-group>
            </puts>
        </xsl:variable>
        <xsl:variable name="definingProject" select="($puts/puts/put[@isDefiningTemplate='1']/@prefix)[1]"/>
        <tr style="vertical-align: top; background-color:{$bgcolor}" class="list">
            <xsl:variable name="theTemplates" select="if (count(template[@id])&gt;0) then template[@id] else template[@ref]"/>
            <td width="1%">
                <!-- Id -->
                <xsl:choose>
                    <xsl:when test="string-length($definingProject)&gt;0">
                        <a href="{concat($artdecordeeplinkprefix, '/decor-templates--', $definingProject, '?id=', $tid)}">
                            <xsl:value-of select="$tid"/>
                        </a>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$tid"/>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
            <td style="line-height: 150%;">
                <!-- Display Name -->
                <xsl:apply-templates select="$theTemplates" mode="governancelistname"/>
            </td>
            <td style="line-height: 150%;">
                <!-- Version / Status -->
                <xsl:apply-templates select="$theTemplates" mode="governancelistversion"/>
            </td>
            <td style="line-height: 150%;">
                <!-- from Repository -->
                <xsl:apply-templates select="$theTemplates" mode="governancelistrepo"/>
            </td>
            <td>
                <!-- Type -->
                <xsl:variable name="c" select="(template/classification/@type)[1]"/>
                <div class="{concat('nowrapinline ad-templatetype ', $c)}">
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
                        <xsl:when test="$c = 'messagelevel'">
                            <xsl:text> Message</xsl:text>
                        </xsl:when>
                        <xsl:when test="$c = 'segmentlevel'">
                            <xsl:text> Segment</xsl:text>
                        </xsl:when>
                        <xsl:when test="$c = 'clinicalstatementlevel'">
                            <xsl:text> Clinical Statement</xsl:text>
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
                </div>
               <!-- <xsl:call-template name="getXFormsLabel">
                    <xsl:with-param name="simpleTypeKey" select="'TemplateTypes'"/>
                    <xsl:with-param name="simpleTypeValue" select="template/classification/@type"/>
                    <xsl:with-param name="lang" select="$defaultLanguage"/>
                </xsl:call-template>-->
            </td>
            <td style="line-height: 150%;">
                <!-- Project -->
                <xsl:for-each select="$puts/puts/*">
                    <xsl:sort select="@isDefiningTemplate" order="descending"/>
                    <xsl:sort select="@prefix"/>
                    <xsl:choose>
                        <xsl:when test="@isDefiningTemplate='0'">
                            <span class="repobox nowrapinline">
                                <div class="repo refonly sspacing">ref</div>
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="@name"/>
                            </span>
                        </xsl:when>
                        <xsl:otherwise>
                            <span class="sspacing">
                                <xsl:value-of select="@name"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:if test="position()&lt;last()">
                        <br/>
                    </xsl:if>
                    <!--<span class="repobox nowrapinline">
                        <div class="repo refonly">ref</div>
                        <xsl:text> (</xsl:text>
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'fromrepository'"/>
                        </xsl:call-template>
                        <xsl:text>: </xsl:text>
                        <xsl:value-of select="@ident"/>
                        <xsl:text>)</xsl:text>
                    </span>-->
                </xsl:for-each>
                <xsl:if test="count(templat1e[@ref])&gt;0">
                    <span class="repobox" style="margin-right: 2px;">
                        <div class="repo refonly">
                            <xsl:value-of select="'ref'"/>
                            <!--<xforms:output class="auto-width" ref="'ref'">
                                <xforms:hint ref="concat($resources/from, ' ', $resources/repository,' ',$ident)"/>
                            </xforms:output>-->
                        </div>
                    </span>
                </xsl:if>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="template" mode="governancelistname">
        <xsl:value-of select="@displayName"/>
        <br/>
    </xsl:template>
    <xsl:template match="template" mode="governancelistversion">
        <span class="nowrapinline">
            <xsl:call-template name="showDate">
                <xsl:with-param name="date" select="@effectiveDate"/>
            </xsl:call-template>
            <xsl:text> </xsl:text>
            <span class="{concat('version-', @statusCode, ' ')}">
                <xsl:call-template name="getXFormsLabel">
                    <xsl:with-param name="simpleTypeKey" select="'TemplateStatusCodeLifeCycle'"/>
                    <xsl:with-param name="simpleTypeValue" select="@statusCode"/>
                    <xsl:with-param name="lang" select="$defaultLanguage"/>
                </xsl:call-template>
            </span>
        </span>
        <br/>
    </xsl:template>
    <xsl:template match="template" mode="governancelistrepo">
        <xsl:apply-templates select="." mode="buildReferenceBox"/>
        <!--<xsl:if test="@ref|@url">
            <span class="repobox">
                <div class="repo ref sspacing">
                    <xsl:value-of select="'ref'"/>
                </div>
                <div class="non-selectable repo refvalue sspacing">
                    <xsl:choose>
                        <xsl:when test="string-length(@ident)>0">
                            <xsl:value-of select="@ident"/>
                        </xsl:when>
                        <xsl:otherwise>?</xsl:otherwise>
                    </xsl:choose>
                </div>
            </span>
        </xsl:if>-->
        <br/>
    </xsl:template>
    <xsl:template match="valueSet" mode="governancelist">
        <xsl:param name="group"/>
        <xsl:param name="bgcolor"/>
        <xsl:variable name="vid" select="@id|@ref"/>
        <xsl:variable name="puts">
            <puts>
                <xsl:for-each-group select="$group/ancestor::project" group-by="@prefix">
                    <put>
                        <xsl:copy-of select="@prefix"/>
                        <xsl:if test="valueSet/valueSet[(@id)=$vid][not(@referencedFrom)]">
                            <xsl:attribute name="defs" select="'true'"/>
                        </xsl:if>
                    </put>
                </xsl:for-each-group>
            </puts>
        </xsl:variable>
        <tr style="vertical-align: top; background-color:{$bgcolor}" class="list">
            <td width="1%">
                <xsl:value-of select="$vid"/>
            </td>
            <td>
                <xsl:apply-templates select="if (count(valueSet[@id])&gt;0) then valueSet[@id] else valueSet[@ref]" mode="governancelistname"/>
            </td>
            <td>
                <xsl:apply-templates select="if (count(valueSet[@id])&gt;0) then valueSet[@id] else valueSet[@ref]" mode="governancelistversion"/>
            </td>
            <td>
                <xsl:apply-templates select="if (count(valueSet[@id])&gt;0) then valueSet[@id] else valueSet[@ref]" mode="governancelistrepo"/>
            </td>
            <td>
                <xsl:for-each select="$puts/puts/*">
                    <xsl:sort select="@defs" order="descending"/>
                    <xsl:sort select="@prefix"/>
                    <xsl:variable name="prefix" select="@prefix"/>
                    <xsl:if test="not(@defs)">
                        <span class="repobox nowrapinline sspacing">
                            <div class="repo refonly">ref</div>
                        </span>
                        <xsl:text> </xsl:text>
                    </xsl:if>
                    <span class="sspacing">
                        <xsl:choose>
                            <xsl:when test="$group/parent::project[@prefix=$prefix]/name[@language=parent::project/@defaultLanguage]">
                                <xsl:value-of select="$group/parent::project[@prefix=$prefix]/name[@language=parent::project/@defaultLanguage]"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="@prefix"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </span>
                    <xsl:if test="position()&lt;last()">
                        <br/>
                    </xsl:if>
                </xsl:for-each>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="valueSet" mode="governancelistname">
        <xsl:value-of select="@displayName"/>
        <br/>
    </xsl:template>
    <xsl:template match="valueSet" mode="governancelistversion">
        <span class="nowrapinline">
            <xsl:call-template name="showDate">
                <xsl:with-param name="date" select="@effectiveDate"/>
            </xsl:call-template>
            <xsl:text> </xsl:text>
            <span class="{(concat('version-', @statusCode, ' '))}">
                <xsl:call-template name="getXFormsLabel">
                    <xsl:with-param name="simpleTypeKey" select="'ItemStatusCodeLifeCycle'"/>
                    <xsl:with-param name="simpleTypeValue" select="@statusCode"/>
                    <xsl:with-param name="lang" select="$defaultLanguage"/>
                </xsl:call-template>
            </span>
        </span>
        <br/>
    </xsl:template>
    <xsl:template match="valueSet" mode="governancelistrepo">
        <xsl:apply-templates select="." mode="buildReferenceBox"/>
        <!--<xsl:if test="@ident">
            <span class="repobox">
                <div class="repo ref sspacing">
                    <xsl:value-of select="'ref'"/>
                </div>
                <div class="non-selectable repo refvalue sspacing">
                    <xsl:choose>
                        <xsl:when test="string-length(@ident)>0">
                            <xsl:value-of select="@ident"/>
                        </xsl:when>
                        <xsl:otherwise>?</xsl:otherwise>
                    </xsl:choose>
                </div>
            </span>
        </xsl:if>-->
        <br/>
    </xsl:template>
</xsl:stylesheet>