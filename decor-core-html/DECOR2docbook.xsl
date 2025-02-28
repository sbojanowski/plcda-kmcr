<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    
    DECOR
    Copyright (C) 2009-2017 Dr. Kai U. Heitmann
    
    This program is free software; you can redistribute it and/or modify it under the terms 
    of the GNU General Public License as published by the Free Software Foundation; 
    either version 3 of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
    See the GNU General Public License for more details.
    
    See http://www.gnu.org/licenses/gpl.html
    
    
    Icons by Axialis Team
    <a href="http://www.axialis.com/free/icons">Icons</a> by <a href="http://www.axialis.com">Axialis Team</a>
    
-->
<!DOCTYPE stylesheet [
<!ENTITY nbsp "&#xa0;">
<!ENTITY termColorDark "#ECCCFF">
<!ENTITY termColorLight "#FFEAFF">
<!ENTITY infmColorDark "#FFCCCC">
<!ENTITY infmColorLight "#FFEAEA">
<!ENTITY mediColorDark "#E0FFE0">
<!ENTITY mediColorLight "#F4FFF4">
<!ENTITY sandColorDark "#ECE9E4">
<!ENTITY sandColorLight "#F6F3EE">
<!ENTITY deprecatedBackground "#EAEFEE">
]>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:db="http://docbook.org/ns/docbook" xmlns:local="http://art-decor.org/functions" version="2.0">


    <!-- TEST -->

    <!-- STRUCTURE
    <book xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xi="http://www.w3.org/2001/XInclude" version="5.0" status="draft">
        
        <xi:include href="bookinfo.xml"/>
        <xi:include href="bookinfo.xml"/>
        <xi:include href="bookinfo.xml"/>
        
    </book>
    -->


    <!--<xsl:output method="xml" name="xml" indent="yes" version="1.0" encoding="UTF-8" exclude-result-prefixes="#all" />
   
    <xsl:output method="html" name="html" indent="yes" version="4.01" encoding="UTF-8" doctype-public="-//W3C//DTD HTML 4.01//EN" doctype-system="http://www.w3.org/TR/html4/strict.dtd"/>
    
    <xsl:output method="xhtml" name="xhtml" indent="yes" encoding="UTF-8"
        doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
        doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>-->

    <xsl:template name="convertDECOR2DOCBOOKPDF">
        <xsl:param name="contributorpage" select="false()"/>
        <xsl:param name="projectinformation" select="true()"/>
        <xsl:param name="datasetinfornation" select="false()"/>
        <xsl:param name="scenarioinformation" select="true()"/>
        <xsl:param name="identifierinformation" select="false()"/>
        <xsl:param name="terminologyinformation" select="true()"/>
        <xsl:param name="rulesinformation" select="true()"/>
        <xsl:param name="issuesinformation" select="false()"/>
        <xsl:param name="compiletimeinformation" select="false()"/>
        <xsl:param name="legalinformation" select="false()"/>
        <xsl:param name="doDocbook" select="false()"/>
        <xsl:param name="doPDF" select="false()"/>
        
        <!-- first create the main docbook book -->
        <xsl:if test="$doDocbook">

            <xsl:result-document href="{$theDocbookDir}decordocbook.xml" method="xml" format="xml" version="1.0">

                <xsl:processing-instruction name="xml-model">href="http://www.oasis-open.org/docbook/xml/5.0/rng/docbook.rng"
                schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction>
                <xsl:processing-instruction name="xml-stylesheet">type="text/xsl" href="decor2xhtml.xsl"</xsl:processing-instruction>

                <book xmlns="http://docbook.org/ns/docbook" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xi="http://www.w3.org/2001/XInclude" version="5.0" status="draft">

                    <title>
                        <xsl:choose>
                            <xsl:when test="string-length(//project/name[@language=$defaultLanguage or not(@language)])=0">
                                <!-- fallback -->
                                <xsl:value-of select="(//project/name)[1]"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="//project/name[@language=$defaultLanguage or not(@language)][1]"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </title>
                    <subtitle>
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'decorTitleString'"/>
                        </xsl:call-template>
                    </subtitle>

                    <info>
                        <!-- authorgroup -->
                        <authorgroup>
                            <xsl:for-each select="//project/copyright">
                                <author>
                                    <orgname>
                                        <xsl:value-of select="@by"/>
                                    </orgname>
                                </author>
                            </xsl:for-each>
                        </authorgroup>

                        <cover>
                            <mediaobject>
                                <imageobject>
                                    <imagedata fileref="http://art-decor.org/ADAR/rv/assets/art-decor-logo-small.jpg"/>
                                </imageobject>
                            </mediaobject>
                        </cover>

                        <!--
                    <revhistory>
                        <xsl:for-each select="//project/version">
                            <revision>
                                <date>
                                    <xsl:call-template name="showDate">
                                        <xsl:with-param name="date" select="@date"/>
                                    </xsl:call-template>
                                </date>
                                <revremark>
                                    <xsl:value-of select="@by"/>
                                    <xsl:text>: </xsl:text>
                                    <xsl:call-template name="doDescription">
                                        <xsl:with-param name="ns" select="desc"/>
                                    </xsl:call-template>
                                </revremark>
                            </revision>
                        </xsl:for-each>
                    </revhistory>
                    
                    <itemizedlist>
                    <listitem>
                    <para>RFE <link xlink:href="https://sourceforge.net/tracker/index.php?func=detail&amp;group_id=21935&amp;atid=384107&amp;aid=1679665">1679665</link> Add better support for modular
                    documentation </para>
                    </listitem>
                    </itemizedlist>
                    -->

                        <pubdate>
                            <xsl:call-template name="showDate">
                                <xsl:with-param name="date" select="$currentDateTime"/>
                            </xsl:call-template>
                        </pubdate>

                        <releaseinfo>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'decorProjectVersionAsOf'"/>
                                <xsl:with-param name="p1">
                                    <xsl:call-template name="showDate">
                                        <xsl:with-param name="date" select="//project/version[last()]/@date"/>
                                    </xsl:call-template>
                                </xsl:with-param>
                            </xsl:call-template>
                        </releaseinfo>

                        <legalnotice>
                            <para>
                                <xsl:value-of select="$disclaimer"/>
                            </para>
                        </legalnotice>


                    </info>

                    <preface>
                        <title>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'doc.par.Preface'"/>
                            </xsl:call-template>
                        </title>
                        <sect1>
                            <title>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'doc.par.Organizations'"/>
                                </xsl:call-template>
                            </title>

                            <xsl:for-each select="//project/copyright">
                                <sect2>
                                    <title>
                                        <xsl:value-of select="@by"/>
                                    </title>
                                    <xsl:if test="string-length(@logo) > 0">
                                        <xsl:variable name="theLogo">
                                            <xsl:value-of select="$theLogosDir"/>
                                            <xsl:value-of select="@logo"/>
                                        </xsl:variable>
                                        <mediaobject>
                                            <imageobject>
                                                <imagedata fileref="{$theLogo}" width="200px"/>
                                            </imageobject>
                                        </mediaobject>
                                    </xsl:if>
                                    <xsl:for-each select="addrLine">
                                        <para>
                                            <xsl:value-of select="."/>
                                        </para>
                                    </xsl:for-each>
                                </sect2>
                            </xsl:for-each>
                        </sect1>

                    </preface>

                    <!-- 
                <xi:include href="project.xml"/>
                <xi:include href="dataset.xml"/>
                <xi:include href="scenario.xml"/>
                <xi:include href="identifier.xml"/>
                <xi:include href="terminology.xml"/>
                <xi:include href="rules.xml"/>
                <xi:include href="issues.xml"/>
                <xi:include href="legal.xml"/>
                <xi:include href="appendix.xml"/>
-->
                </book>

            </xsl:result-document>

            <!-- now create the sub chapters: project, dataset, scenario, identifier, terminology, rules, issues, legal, appendix -->

            <xsl:if test="false()">
                <xsl:result-document href="{$theDocbookDir}project.xml" method="xml" format="xml" version="1.0">
                    <!-- Project Information -->
                    <chapter xmlns="http://docbook.org/ns/docbook" version="5.0">
                        <title>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'tabProjectInformation'"/>
                            </xsl:call-template>
                        </title>
                        <sect1>
                            <title>Project</title>
                            <para>
                                <xsl:choose>
                                    <xsl:when test="string-length(//project/name[@language=$defaultLanguage or not(@language)])=0">
                                        <!-- fallback -->
                                        <xsl:value-of select="(//project/name)[1]"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="//project/name[@language=$defaultLanguage or not(@language)][1]"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:choose>
                                    <xsl:when test="string-length(//project/desc[@language=$defaultLanguage or not(@language)])=0">
                                        <!-- fallback -->
                                        <xsl:value-of select="(//project/desc)[1]"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="//project/desc[@language=$defaultLanguage or not(@language)][1]"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </para>
                            <para>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'decorProjectVersionAsOf'"/>
                                    <xsl:with-param name="p1">
                                        <xsl:call-template name="showDate">
                                            <xsl:with-param name="date" select="//project/version[last()]/@date"/>
                                        </xsl:call-template>
                                    </xsl:with-param>
                                </xsl:call-template>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'htmlExtractAsOf'"/>
                                </xsl:call-template>
                                <xsl:call-template name="showDate">
                                    <xsl:with-param name="date" select="$currentDateTime"/>
                                </xsl:call-template>
                            </para>
                        </sect1>
                        <sect1>
                            <title>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'tabProjectInfoDefaultLanguage'"/>
                                </xsl:call-template>
                            </title>
                            <para>
                                <xsl:value-of select="//project/@defaultLanguage"/>
                            </para>
                        </sect1>
                        <sect1>
                            <title>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'tabProjectInfoDescription'"/>
                                </xsl:call-template>
                            </title>
                            <para>
                                <xsl:choose>
                                    <xsl:when test="string-length(//project/desc[@language=$defaultLanguage or not(@language)])=0">
                                        <!-- fallback -->
                                        <xsl:value-of select="(//project/desc)[1]"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="//project/desc[@language=$defaultLanguage or not(@language)][1]"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </para>
                        </sect1>
                        <sect1>
                            <title>Artifact Prefix</title>
                            <para>$$TEXT$$</para>
                        </sect1>
                        <sect1>
                            <title>Reference URI</title>
                            <para>$$TEXT$$</para>
                        </sect1>
                        <sect1>
                            <title>Disclaimer</title>
                            <para>$$TEXT$$</para>
                        </sect1>
                        <sect1>
                            <title>List of Authors</title>
                            <para>$$TEXT$$</para>
                        </sect1>
                        <sect1>
                            <title>Version History</title>
                            <para>$$TEXT$$</para>
                        </sect1>
                    </chapter>
                </xsl:result-document>
                <xsl:result-document href="{$theDocbookDir}dataset.xml" method="xml" format="xml" version="1.0">
                    <!-- Dataset -->
                    <chapter xmlns="http://docbook.org/ns/docbook" version="5.0">
                        <title>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'tabDataSet'"/>
                            </xsl:call-template>
                        </title>
                        <sect1>
                            <title>Dataset (generic)</title>
                            <para>$$TEXT$$</para>
                            <sect2>
                                <title>Dataset #1</title>
                                <para>$$TEXT$$</para>
                            </sect2>
                            <sect2>
                                <title>Dataset #2</title>
                                <para>$$TEXT$$</para>
                            </sect2>
                        </sect1>
                        <sect1>
                            <title>Dataset (per transaction)</title>
                            <para>$$TEXT$$</para>
                            <sect2>
                                <title>Transaction #1</title>
                                <para>$$TEXT$$</para>
                            </sect2>
                            <sect2>
                                <title>Transaction #2</title>
                                <para>$$TEXT$$</para>
                            </sect2>
                        </sect1>
                    </chapter>
                </xsl:result-document>
                <xsl:result-document href="{$theDocbookDir}scenario.xml" method="xml" format="xml" version="1.0">
                    <!-- Scenarios -->
                    <chapter xmlns="http://docbook.org/ns/docbook" version="5.0">
                        <title>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'tabScenarios'"/>
                            </xsl:call-template>
                        </title>
                        <sect1>
                            <title>Scenario #1</title>
                            <para>$$TEXT$$</para>
                            <sect2>
                                <title>Transaction Group #1</title>
                                <para>$$TEXT$$</para>
                                <sect3>
                                    <title>Transaction #1</title>
                                    <para>$$TEXT$$</para>
                                </sect3>
                            </sect2>
                        </sect1>
                    </chapter>
                </xsl:result-document>
                <xsl:result-document href="{$theDocbookDir}identifier.xml" method="xml" format="xml" version="1.0">
                    <!-- Identifiers -->
                    <chapter xmlns="http://docbook.org/ns/docbook" version="5.0">
                        <title>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'tabIdentifiers'"/>
                            </xsl:call-template>
                        </title>
                        <sect1>
                            <title>Identifiers</title>
                            <para>$$TEXT$$</para>
                        </sect1>
                        <sect1>
                            <title>List of Template Identifiers used in this project</title>
                            <para>$$TEXT$$</para>
                        </sect1>
                        <sect1>
                            <title>List of Value Set Identifiers used in this project</title>
                            <para>$$TEXT$$</para>
                        </sect1>
                    </chapter>
                </xsl:result-document>
                <xsl:result-document href="{$theDocbookDir}terminology.xml" method="xml" format="xml" version="1.0">
                    <!-- Terminology -->
                    <chapter xmlns="http://docbook.org/ns/docbook" version="5.0">
                        <title>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'tabTerminology'"/>
                            </xsl:call-template>
                        </title>
                        <sect1>
                            <title>Value sets</title>
                            <xsl:for-each select="//terminology/valueSet[@id]">
                                <xsl:sort select="@name"/>
                                <xsl:sort select="@effectiveDate" order="descending"/>
                                <sect2>
                                    <title>
                                        <xsl:call-template name="showStatusDotDBK">
                                            <xsl:with-param name="status" select="@statusCode"/>
                                            <xsl:with-param name="title">
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="concat('ItemStatusCodeLifeCycle-', @statusCode)"/>
                                                </xsl:call-template>
                                            </xsl:with-param>
                                        </xsl:call-template>
                                        <xsl:text> </xsl:text>
                                        <xsl:value-of select="@name"/>
                                        <xsl:if test="string-length(@displayName) > 0 and (@name != @displayName)">
                                            <xsl:text> </xsl:text>
                                            <emphasis role="italic">
                                                <xsl:text> / </xsl:text>
                                                <xsl:value-of select="@displayName"/>
                                            </emphasis>
                                        </xsl:if>

                                        <xsl:text> -</xsl:text>
                                        <xsl:if test="version">
                                            <xsl:text> v</xsl:text>
                                            <xsl:value-of select="@version"/>
                                            <xsl:text> /</xsl:text>
                                        </xsl:if>

                                        <xsl:text> </xsl:text>
                                        <xsl:call-template name="showDate">
                                            <xsl:with-param name="date" select="@effectiveDate"/>
                                        </xsl:call-template>
                                    </title>
                                    <xsl:variable name="t">
                                        <xsl:apply-templates select="."/>
                                    </xsl:variable>
                                    <xsl:apply-templates select="$t" mode="DBKcopy"/>
                                </sect2>
                            </xsl:for-each>
                        </sect1>
                    </chapter>
                </xsl:result-document>
                <xsl:result-document href="{$theDocbookDir}rules.xml" method="xml" format="xml" version="1.0">
                    <!-- Rules -->
                    <chapter xmlns="http://docbook.org/ns/docbook" version="5.0">
                        <title>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'tabRules'"/>
                            </xsl:call-template>
                        </title>

                        <sect1>
                            <title>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'tabRepresentingTemplatesString'"/>
                                </xsl:call-template>
                            </title>

                            <xsl:for-each select="$allScenarios//representingTemplate">
                                <!-- 
                                 <xsl:sort select="replace(replace (concat(@id, '.'), '\.', '.0000000000'), '.0*([0-9]{9,})', '.$1')"/>
                             -->

                                <xsl:variable name="rtid" select="@ref"/>
                                <!-- concat for backward compatibility -->
                                <xsl:variable name="theTemplate">
                                    <xsl:call-template name="getRulesetContent">
                                        <xsl:with-param name="ruleset" select="$rtid"/>
                                        <xsl:with-param name="flexibility" select="@flexibility"/>
                                        <xsl:with-param name="sofar" select="()"/>
                                    </xsl:call-template>
                                </xsl:variable>
                                <xsl:variable name="theTransaction" select="parent::transaction"/>

                                <xsl:apply-templates select="$theTemplate" mode="showpreliminariesDBK">
                                    <!-- 
                                     submit also the underlying model of this template, drawn from 
                                     the parent transaction's @model
                                     and the resulting rule name drawn from 
                                     the parent transaction's @label
                                     for later display
                                 -->
                                    <xsl:with-param name="underlyingModel" select="$theTransaction/@model"/>
                                    <xsl:with-param name="resultingRule" select="$theTransaction/normalize-space(@label)"/>
                                    <xsl:with-param name="direction" select="$theTransaction/@type"/>
                                </xsl:apply-templates>
                            </xsl:for-each>
                        </sect1>

                        <!-- create a list of already shown template to not show them again -->
                        <!-- TODO: @flexibility -->
                        <xsl:variable name="alreadyShownTemplates">
                            <xsl:for-each select="$allScenarios//representingTemplate">
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="@ref"/>
                                <xsl:text> </xsl:text>
                            </xsl:for-each>
                        </xsl:variable>

                        <sect1>
                            <title>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'TemplatesTitle'"/>
                                </xsl:call-template>
                            </title>

                            <xsl:for-each select="$allTemplates/*/ref/template">
                                <!--
                                 <xsl:sort select="replace(replace (concat(@id, '.'), '\.', '.0000000000'), '.0*([0-9]{9,})', '.$1')"/>
                                 do not sort by OID
                             -->
                                <xsl:sort select="@name"/>
                                <!-- TODO: @flexibility -->
                                <xsl:if test="not(contains($alreadyShownTemplates, @id))">
                                    <sect2>
                                        <title>
                                            <xsl:value-of select="@name"/>
                                        </title>
                                        <para>
                                            <xsl:variable name="t">
                                                <xsl:apply-templates select="." mode="showpreliminaries">
                                                    <xsl:with-param name="templatename" select="@name"/>
                                                </xsl:apply-templates>
                                            </xsl:variable>
                                            <xsl:apply-templates select="$t" mode="DBKcopy"/>
                                        </para>
                                    </sect2>
                                </xsl:if>

                            </xsl:for-each>

                        </sect1>

                        <sect1>
                            <title>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'templatesPerScenario'"/>
                                </xsl:call-template>
                            </title>
                            <para>$$TEXT$$</para>
                        </sect1>

                        <sect1>
                            <title>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'templateSummary'"/>
                                </xsl:call-template>
                            </title>
                            <para>$$TEXT$$</para>
                        </sect1>
                    </chapter>
                </xsl:result-document>
                <xsl:result-document href="{$theDocbookDir}issues.xml" method="xml" format="xml" version="1.0">
                    <!-- Issues -->
                    <chapter xmlns="http://docbook.org/ns/docbook" version="5.0">
                        <title>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'tabIssues'"/>
                            </xsl:call-template>
                        </title>
                        <!--
                     <sect1>
                         <title>Issues already assigned</title>
                         <para>$$TEXT$$</para>
                     </sect1>
                     <sect1>
                         <title>Issues not yet assigned</title>
                         <para>$$TEXT$$</para>
                     </sect1>
                     <sect1>
                         <title>Issues dealt with</title>
                         <para>$$TEXT$$</para>
                     </sect1>
                     -->
                        <para>
                            <xsl:variable name="t">
                                <xsl:call-template name="doShowIssues"/>
                            </xsl:variable>
                            <xsl:apply-templates select="$t" mode="DBKcopy"/>
                        </para>

                    </chapter>
                </xsl:result-document>
                <xsl:result-document href="{$theDocbookDir}legal.xml" method="xml" format="xml" version="1.0">
                    <!-- Legal -->
                    <chapter xmlns="http://docbook.org/ns/docbook" version="5.0">
                        <title>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'tabLegal'"/>
                            </xsl:call-template>
                        </title>
                        <sect1>
                            <title>Legal</title>
                            <para>text1</para>
                        </sect1>
                    </chapter>
                </xsl:result-document>
                <xsl:result-document href="{$theDocbookDir}appendix.xml" method="xml" format="xml" version="1.0">
                    <!-- Appendices -->
                    <appendix xmlns="http://docbook.org/ns/docbook">
                        <title>Appendix 1</title>
                        <para>$$TEXT$$</para>
                    </appendix>
                </xsl:result-document>
            </xsl:if>

        </xsl:if>

        <!-- HTML/PDF -->
        <xsl:if test="$doPDF">
            <xsl:result-document href="{$theDocbookDir}adecorbook.html" method="html">
                <xsl:text disable-output-escaping="yes">&lt;!ENTITY nbsp "&amp;#x2007;"></xsl:text>
                <html xmlns="http://www.w3.org/1999/xhtml">
                    <xsl:text>&#10;&#10;</xsl:text>
                    <head>
                        <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
                        <link href="{$theAssetsDir}decorprint.css" rel="stylesheet" type="text/css"/>
                        <title>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'decorTitleString'"/>
                            </xsl:call-template>
                        </title>



                        <!--
                    <meta name="author" content="John Smith"/>
                    <meta name="subject" content="An interesting book about food"/>
                    <meta name="keywords" content="cabbage, cooking, eating"/>
<meta name="date" content="2002-02-10T10:00:00Z">
<meta name="generator" content="MyReportingApp"/>
                    
                    <meta name="DC.title" content="SELFHTML: Meta-Angaben">
<meta name="DC.creator" content="Stefan M&#252;nz">
<meta name="DC.subject" content="Meta-Angaben">
<meta name="DC.description" content="Heute bekannte Meta-Angaben in HTML">
<meta name="DC.publisher" content="TeamOne">
<meta name="DC.contributor" content="Wolfgang Nefzger">
<meta name="DC.date" content="2001-12-15T08:49:37+02:00" scheme="DCTERMS.W3CDTF">
<meta name="DC.type" content="Text" scheme="DCTERMS.DCMIType">
<meta name="DC.format" content="text/html" scheme="DCTERMS.IMT">
<meta name="DC.identifier"
      content="http://de.selfhtml.org/html/kopfdaten/meta.htm"
      scheme="DCTERMS.URI">
<meta name="DC.source"
      content="http://www.w3.org/TR/html401/struct/global.html#h-7.4.4"
      scheme="DCTERMS.URI">
<meta name="DC.language" content="de" scheme="DCTERMS.RFC3066">
<meta name="DC.relation" content="http://dublincore.org/" scheme="DCTERMS.URI">
<meta name="DC.coverage" content="Munich" scheme="DCTERMS.TGN">
<meta name="DC.rights" content="Alle Rechte liegen beim Autor">

                    -->

                        <script type="text/javascript" src="{$theAssetsDir}decorprinttoc.js"/>

                        <!-- invisible tag to provide some info for printing -->
                        <style type="text/css">
                         <xsl:comment>
                             <xsl:text>body { /* parameter for printing only */ string-set: projecttitle "</xsl:text>
                              <xsl:choose>
                                    <xsl:when test="string-length(//project/name[@language=$defaultLanguage or not(@language)])=0">
                                        <!-- fallback -->
                                        <xsl:value-of select="(//project/name)[1]"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="//project/name[@language=$defaultLanguage or not(@language)][1]"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                             <xsl:text>";}</xsl:text>
                         </xsl:comment>
                    </style>

                    </head>
                    <xsl:text>&#10;&#10;</xsl:text>
                    <body onload="maketoc();">

                        <div id="titlepage">
                            <table width="100%">
                                <tr>
                                    <td align="right">
                                        <xsl:choose>
                                            <xsl:when test="1 = 1">
                                                <img src="{$theAssetsDir}3dartdecor2016.jpg" class="right" style="width:250pt;"/>
                                            </xsl:when>
                                            <xsl:otherwise> </xsl:otherwise>
                                        </xsl:choose>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="left" class="head">
                                        <xsl:choose>
                                            <xsl:when test="string-length(//project/name[@language=$defaultLanguage or not(@language)])=0">
                                                <!-- fallback -->
                                                <xsl:value-of select="(//project/name)[1]"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="//project/name[@language=$defaultLanguage or not(@language)][1]"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="left" class="text">
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="'titelpageSubtitle'"/>
                                            <xsl:with-param name="p1">
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'titelpageImplementationGuideline'"/>
                                                </xsl:call-template>
                                                <xsl:if test="$filtersfileavailable=true()">
                                                    <xsl:text> (</xsl:text>
                                                    <xsl:call-template name="getMessage">
                                                        <xsl:with-param name="key" select="'partialPublication'"/>
                                                        <xsl:with-param name="lang" select="$defaultLanguage"/>
                                                    </xsl:call-template>
                                                    <xsl:text>)</xsl:text>
                                                </xsl:if>
                                            </xsl:with-param>
                                        </xsl:call-template>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="left" class="version">
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="'decorProjectVersionAsOf'"/>
                                            <xsl:with-param name="p1">
                                                <xsl:call-template name="showDate">
                                                    <xsl:with-param name="date" select="$latestVersionOrRelease/@date"/>
                                                </xsl:call-template>
                                            </xsl:with-param>
                                        </xsl:call-template>
                                        <br/>
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="'pdfExtractAsOf'"/>
                                        </xsl:call-template>
                                        <xsl:call-template name="showDate">
                                            <xsl:with-param name="date" select="$currentDateTime"/>
                                        </xsl:call-template>
                                    </td>
                                </tr>
                            </table>
                        </div>

                        <div id="license">
                            <xsl:if test="$filtersfileavailable=true()">
                                <div style="display:block; background-color: #fbcbf4; padding: 10px;">
                                    <xsl:call-template name="showIcon">
                                        <xsl:with-param name="which">partialpublication</xsl:with-param>
                                    </xsl:call-template>
                                    <xsl:text>&#160;</xsl:text>
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'partialPublication'"/>
                                        <xsl:with-param name="lang" select="$defaultLanguage"/>
                                    </xsl:call-template>
                                    <hr/>
                                    <xsl:value-of select="doc($filtersfile)/*/normalize-space(@label)"/>
                                </div>
                                <hr style="padding-bottom: 20px;"/>
                            </xsl:if>
                            <table width="100%">
                                <tr>
                                    <td align="left" class="head">
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="'2ndpageLincenses'"/>
                                        </xsl:call-template>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="left" class="text">
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="'licenseNoticeGPL'"/>
                                        </xsl:call-template>
                                        <a xmlns="http://www.w3.org/1999/xhtml" href="http://www.gnu.org/licenses/gpl.html">http://www.gnu.org/licenses/gpl.html</a>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="left" class="text">
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="'licenseNoticeContent'"/>
                                        </xsl:call-template>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="left" class="head">
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="'2ndpageDisclaimer'"/>
                                        </xsl:call-template>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="left" class="text">
                                        <xsl:value-of select="$disclaimer"/>
                                    </td>
                                </tr>
                            </table>
                        </div>

                        <div id="toctitle">TOC</div>
                        <div id="tocContainer" class="toc"/>
                        <!-- empty container to be filled in by JavaScript -->



                        <xsl:if test="$contributorpage">
                            <h1>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'projectContributors'"/>
                                </xsl:call-template>
                            </h1>

                            <table border="0" cellspacing="7" cellpadding="11" bgcolor="#FFFFFF">
                                <xsl:for-each select="//project/copyright">
                                    <tr>
                                        <td width="3pt" bgcolor="#cecbc6">
                                            <!-- place a grey line before each logo/address -->
                                        </td>
                                        <td width="220pt" valign="top">
                                            <!-- place a logo if specified, check projectprefix-logo/@logo -->
                                            <xsl:if test="@logo">
                                                <xsl:variable name="theLogo">
                                                    <xsl:value-of select="$theLogosDir"/>
                                                    <xsl:value-of select="@logo"/>
                                                </xsl:variable>
                                                <img src="{$theLogo}" style="width:200px;" alt="logo"/>
                                            </xsl:if>
                                        </td>
                                        <td valign="top">
                                            <!-- show all adrress lines -->
                                            <xsl:for-each select="addrLine">
                                                <xsl:value-of select="."/>
                                                <br/>
                                            </xsl:for-each>
                                        </td>
                                    </tr>
                                </xsl:for-each>
                            </table>

                        </xsl:if>

                        <xsl:if test="$projectinformation">
                            <!-- Project Information -->
                            <h1>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'tabProjectInformation'"/>
                                </xsl:call-template>
                            </h1>
                            <h2>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'tabProjectInfoProject'"/>
                                </xsl:call-template>
                            </h2>
                            <xsl:call-template name="doProjectInfo"/>
                        </xsl:if>

                        <xsl:if test="$datasetinfornation">
                            <h1>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'tabDataSetsTitleString'"/>
                                </xsl:call-template>
                            </h1>

                            <xsl:for-each select="//datasets/dataset">
                                <xsl:sort select="@effectiveDate" order="descending"/>
                                <h2>
                                    <xsl:choose>
                                        <xsl:when test="@ref">
                                            <xsl:call-template name="showStatusDot">
                                                <xsl:with-param name="status" select="'archived'"/>
                                            </xsl:call-template>
                                            <xsl:call-template name="getMessage">
                                                <xsl:with-param name="key" select="'tabDataSetsDataSetsArchived'"/>
                                            </xsl:call-template>
                                            <xsl:value-of select="@ref"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:variable name="theStatus">
                                                <xsl:choose>
                                                    <xsl:when test="@statusCode">
                                                        <xsl:value-of select="@statusCode"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:variable name="ndcount" select="count(.//concept[@statusCode = 'new' or @statusCode = 'draft'])"/>
                                                        <xsl:choose>
                                                            <xsl:when test="$ndcount > 0">
                                                                <xsl:text>draft</xsl:text>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:text>final</xsl:text>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                        <!-- 
                                                 if any item is new draft - > data set is draft
                                                 if any item is rejected cancelled deprecated - > data set is final
                                               otherwise the data set is final
                                            -->
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:variable>
                                            <xsl:call-template name="showStatusDot">
                                                <xsl:with-param name="status" select="$theStatus"/>
                                                <xsl:with-param name="title">
                                                    <xsl:call-template name="getMessage">
                                                        <xsl:with-param name="key" select="concat('ItemStatusCodeLifeCycle-', $theStatus)"/>
                                                    </xsl:call-template>
                                                </xsl:with-param>
                                            </xsl:call-template>
                                            <xsl:text>&nbsp;</xsl:text>
                                            <xsl:call-template name="doName">
                                                <xsl:with-param name="ns" select="name"/>
                                                <!--<xsl:with-param name="lang" select="//project/@defaultLanguage"/>-->
                                            </xsl:call-template>
                                            <xsl:if test="version">
                                                <xsl:text> - v</xsl:text>
                                                <xsl:value-of select="@version"/>
                                                <xsl:text> /</xsl:text>
                                            </xsl:if>
                                            <xsl:text>&nbsp;</xsl:text>
                                            <xsl:call-template name="showDate">
                                                <xsl:with-param name="date" select="@effectiveDate"/>
                                            </xsl:call-template>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </h2>
                                <xsl:call-template name="doDataset">
                                    <xsl:with-param name="nestingWithTables" select="false()"/>
                                </xsl:call-template>
                            </xsl:for-each>

                        </xsl:if>

                        <xsl:if test="$scenarioinformation">
                            <!-- Identifiers -->
                            <h1>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'tabScenariosTitleString'"/>
                                </xsl:call-template>
                            </h1>
                            <xsl:for-each select="//scenarios/scenario">
                                <xsl:sort select="@effectiveDate" order="descending"/>
                                <xsl:variable name="scstatus" select="@statusCode"/>
                                <div class="acco">
                                    <h2>
                                        <xsl:call-template name="showStatusDot">
                                            <xsl:with-param name="status" select="@statusCode"/>
                                            <xsl:with-param name="title">
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="concat('ItemStatusCodeLifeCycle-', @statusCode)"/>
                                                </xsl:call-template>
                                            </xsl:with-param>
                                        </xsl:call-template>
                                        <xsl:text>&nbsp;</xsl:text>
                                        <xsl:call-template name="doName">
                                            <xsl:with-param name="ns" select="name"/>
                                            <!--<xsl:with-param name="lang" select="$defaultLanguage"/>-->
                                        </xsl:call-template>
                                        <xsl:if test="version">
                                            <xsl:text> - v</xsl:text>
                                            <xsl:value-of select="@version"/>
                                            <xsl:text> /</xsl:text>
                                        </xsl:if>
                                        <xsl:text>&nbsp;</xsl:text>
                                        <xsl:call-template name="showDate">
                                            <xsl:with-param name="date" select="@effectiveDate"/>
                                        </xsl:call-template>
                                    </h2>
                                    <table border="0">
                                        <tr>
                                            <td class="comment">
                                                <xsl:call-template name="doDescription">
                                                    <xsl:with-param name="ns" select="desc"/>
                                                </xsl:call-template>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                                <table border="0" cellspacing="2" cellpadding="2">
                                    <tr valign="top">
                                        <td class="tabtab">
                                            <xsl:call-template name="doScenarios"/>
                                        </td>
                                    </tr>
                                </table>


                            </xsl:for-each>



                        </xsl:if>

                        <xsl:if test="$identifierinformation">
                            <!-- Identifiers -->
                            <h1>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'tabIdentifiersTitleString'"/>
                                </xsl:call-template>
                            </h1>
                            <xsl:call-template name="doIdentifiers"/>
                        </xsl:if>

                        <div class="landscape">
                        <xsl:if test="$terminologyinformation">
                            <!-- Terminology -->
                            
                            <h1>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'tabTerminology'"/>
                                </xsl:call-template>
                            </h1>
                            <h2>Value sets</h2>
                            <!-- 20160716: KH ONLY artefacts in certain "up" status -->
                            <xsl:for-each select="//terminology/valueSet[@id][@statusCode = ('new', 'draft', 'final', 'review', 'pending')]">
                                <xsl:sort select="@name"/>
                                <xsl:sort select="@effectiveDate" order="descending"/>
                                <h3>
                                    <xsl:call-template name="showStatusDot">
                                        <xsl:with-param name="status">
                                            <xsl:choose>
                                                <xsl:when test="not(@ident=$projectPrefix)">
                                                    <xsl:value-of select="'ref'"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="@statusCode"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:with-param>
                                        <xsl:with-param name="title">
                                            <xsl:call-template name="getMessage">
                                                <xsl:with-param name="key" select="concat('ItemStatusCodeLifeCycle-', @statusCode)"/>
                                            </xsl:call-template>
                                        </xsl:with-param>
                                    </xsl:call-template>
                                    <xsl:text> </xsl:text>
                                    <xsl:choose>
                                        <xsl:when test="string-length(@displayName) > 0">
                                            <xsl:value-of select="@displayName"/>
                                        </xsl:when>
                                        <xsl:when test="string-length(@name) > 0">
                                            <xsl:value-of select="@name"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:call-template name="getMessage">
                                                <xsl:with-param name="key" select="'rulesNoNameOrDisplaynameDefinedYet'"/>
                                            </xsl:call-template>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:text> </xsl:text>
                                    <xsl:value-of select="@id"/>
                                    <xsl:text> - </xsl:text>
                                    <xsl:call-template name="showDate">
                                        <xsl:with-param name="date" select="@effectiveDate"/>
                                    </xsl:call-template>
                                    <xsl:if test="@versionLabel">
                                        <xsl:text> (</xsl:text>
                                        <xsl:value-of select="@versionLabel"/>
                                        <xsl:text>)</xsl:text>
                                    </xsl:if>
                                    <xsl:if test="@url and @ident and not(@ident=$projectPrefix)">
                                        <xsl:text> </xsl:text>
                                        <span class="repobox nowrapinline">
                                            <div class="repo refonly">ref</div>
                                            <xsl:text> (</xsl:text>
                                            <xsl:call-template name="getMessage">
                                                <xsl:with-param name="key" select="'fromrepository'"/>
                                            </xsl:call-template>
                                            <xsl:text>: </xsl:text>
                                            <xsl:value-of select="@ident"/>
                                            <xsl:text>)</xsl:text>
                                        </span>
                                    </xsl:if>
                                </h3>
                                
                                <xsl:apply-templates select=".">
                                    <xsl:with-param name="useSecondaryTHEAD" select="true()"/>
                                </xsl:apply-templates>
                                
                            </xsl:for-each>
                            
                        </xsl:if>

                        <xsl:if test="$rulesinformation">
                            <!-- Rules -->

                            <h1>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'tabRules'"/>
                                </xsl:call-template>
                            </h1>
                            
                            <h2>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'tabRepresentingTemplatesString'"/>
                                </xsl:call-template>
                            </h2>
                            
                            <xsl:for-each select="$allScenarios//representingTemplate">
                                
                                <xsl:variable name="rtid" select="@ref"/>
                                <!-- concat for backward compatibility -->
                                <xsl:variable name="theTemplate">
                                    <xsl:call-template name="getRulesetContent">
                                        <xsl:with-param name="ruleset" select="$rtid"/>
                                        <xsl:with-param name="flexibility" select="@flexibility"/>
                                        <xsl:with-param name="sofar" select="()"/>
                                    </xsl:call-template>
                                </xsl:variable>
                                <xsl:variable name="theTransaction" select="parent::transaction"/>
                                
                                <xsl:apply-templates select="$theTemplate" mode="showpreliminaries">
                                    <!-- 
                                submit also the underlying model of this template, drawn from 
                                the parent transaction's @model and the resulting rule name drawn from
                                the parent transaction's @label for later display
                            -->
                                    <xsl:with-param name="underlyingModel" select="$theTransaction/@model"/>
                                    <xsl:with-param name="resultingRule" select="$theTransaction/@label"/>
                                    <xsl:with-param name="direction" select="$theTransaction/@type"/>
                                    <xsl:with-param name="breakbetweennameandid" select="true()"/>
                                </xsl:apply-templates>
                                <xsl:variable name="xtname">
                                    <xsl:if test="$theTemplate/template/@displayName">
                                        <xsl:value-of select="$theTemplate/template/@displayName"/>
                                        <xsl:text> / </xsl:text>
                                    </xsl:if>
                                    <xsl:value-of select="$theTemplate/template/@name"/>
                                </xsl:variable>
                                <p/>
                                <xsl:variable name="t">
                                    <table width="100%" border="0">
                                        <tr>
                                            <td class="tabtab">
                                                <xsl:apply-templates select="$theTemplate/template">
                                                    <xsl:with-param name="templatename" select="$xtname"/>
                                                </xsl:apply-templates>
                                            </td>
                                        </tr>
                                    </table>
                                </xsl:variable>
                                <xsl:copy-of select="$t"/>
                            </xsl:for-each>
                            
                            <!-- create a list of already shown template to not show them again -->
                            <!-- TODO: @flexibility -->
                            <xsl:variable name="alreadyShownTemplates">
                                <xsl:for-each select="$allScenarios//representingTemplate">
                                    <xsl:text> </xsl:text>
                                    <xsl:value-of select="@ref"/>
                                    <xsl:text> </xsl:text>
                                </xsl:for-each>
                            </xsl:variable>
                            
                            <h2>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'TemplatesTitle'"/>
                                </xsl:call-template>
                            </h2>
                            
                            <!-- 20160716: KH ONLY artefacts in certain "up" status -->
                            <xsl:for-each select="$allTemplates/*/ref/template[@statusCode = ('draft', 'active', 'review')]">
                                <!--
                            <xsl:sort select="replace(replace (concat(@id, '.'), '\.', '.0000000000'), '.0*([0-9]{9,})', '.$1')"/>
                            do not sort by OID
                        -->
                                <xsl:sort select="@name"/>
                                
                                <!--
                                    TESTING: SHOW ONLY FIRST x TEMPLATES 
                                    and position() &lt; 50
                                -->
                                <!-- TODO: @flexibility -->
                                <xsl:variable name="xtname">
                                    <xsl:if test="@displayName">
                                        <xsl:value-of select="@displayName"/>
                                        <xsl:text> / </xsl:text>
                                    </xsl:if>
                                    <xsl:value-of select="@name"/>
                                </xsl:variable>
                                <xsl:if test="not(contains($alreadyShownTemplates, @id))">
                                    
                                    <p/>
                                    <xsl:variable name="t">
                                        <xsl:apply-templates select="." mode="showpreliminaries">
                                            <xsl:with-param name="onespacebetweenheaderparticlesonly" select="true()"/>
                                        </xsl:apply-templates>
                                        <!-- show the template(s) -->
                                        <table width="100%" border="0">
                                            <tr>
                                                <td class="tabtab">
                                                    <xsl:apply-templates select=".">
                                                        <xsl:with-param name="templatename" select="$xtname"/>
                                                    </xsl:apply-templates>
                                                </td>
                                            </tr>
                                        </table>
                                    </xsl:variable>
                                    <xsl:copy-of select="$t"/>
                                    
                                </xsl:if>
                                
                            </xsl:for-each>
                           
                        </xsl:if>
                        
                        </div>

                        <xsl:if test="$issuesinformation">
                            <!-- Issues -->
                            <h1>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'tabIssues'"/>
                                </xsl:call-template>
                            </h1>
                            <xsl:call-template name="doShowIssues">
                                <xsl:with-param name="extendedh3" select="false()"/>
                            </xsl:call-template>
                        </xsl:if>
                        
                        <xsl:if test="$filtersfileavailable=true()">
                            <!-- filters information in appendix -->
                            <h1>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'partialPublication'"/>
                                    <xsl:with-param name="lang" select="$defaultLanguage"/>
                                </xsl:call-template>
                            </h1>
                            <xsl:call-template name="showIcon">
                                <xsl:with-param name="which">partialpublication</xsl:with-param>
                            </xsl:call-template>
                            <xsl:text>&#160;</xsl:text>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'partialPublicationInfolist'"/>
                                <xsl:with-param name="lang" select="$defaultLanguage"/>
                                <xsl:with-param name="p1" select="doc($filtersfile)/*/@label"/>
                            </xsl:call-template>
                            <p/>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'partialPublicationArtefactlist'"/>
                                <xsl:with-param name="lang" select="$defaultLanguage"/>
                            </xsl:call-template>
                            <ul>
                                <xsl:for-each select="doc($filtersfile)/filters/*[name()=('dataset','scenario','transaction','valueSet','template')]">
                                    <xsl:variable name="artefactlabel">
                                        <xsl:choose>
                                            <xsl:when test="name()='dataset'">Dataset</xsl:when>
                                            <xsl:when test="name()='scenario'">Scenario</xsl:when>
                                            <xsl:when test="name()='transaction'">Transaction</xsl:when>
                                            <xsl:when test="name()='valueSet'">valueSet</xsl:when>
                                            <xsl:when test="name()='template'">Template</xsl:when>
                                        </xsl:choose>
                                    </xsl:variable>
                                    <li>
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="$artefactlabel"/>
                                            <xsl:with-param name="lang" select="$defaultLanguage"/>
                                        </xsl:call-template>
                                        <xsl:text> </xsl:text>
                                        <xsl:value-of select="@ref"/>
                                        <xsl:if test="string-length(@name)>0">
                                            <xsl:text> (</xsl:text>
                                            <xsl:value-of select="@name"/>
                                            <xsl:text>)</xsl:text>
                                        </xsl:if>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </xsl:if>

                    </body>
                </html>

            </xsl:result-document>

            <xsl:for-each select="$allSvg/transaction">
                <xsl:if test="*[1]">
                    <xsl:result-document href="{$theDocbookDir}{local:doHtmlName('TR',@id,@effectiveDate,'_functional.svg')}" method="xml" output-version="1.0" indent="yes">
                        <xsl:copy-of select="*[1]" copy-namespaces="no"/>
                    </xsl:result-document>
                </xsl:if>
                <xsl:if test="*[2]">
                    <xsl:result-document href="{$theDocbookDir}{local:doHtmlName('TR',@id,@effectiveDate,'_technical.svg')}" method="xml" output-version="1.0" indent="yes">
                        <xsl:copy-of select="*[2]" copy-namespaces="no"/>
                    </xsl:result-document>
                </xsl:if>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <xsl:template match="template" mode="showpreliminariesDBK">

        <xsl:param name="underlyingModel"/>
        <xsl:param name="resultingRule"/>
        <xsl:param name="direction"/>

        <!-- 
            create the template name description
            an @id and a @name is mandatory per template
            give human readable @displayName preference (if present) over pure @name
        -->
        <xsl:variable name="templatename">
            <xsl:choose>
                <xsl:when test="string-length(@displayName) > 0">
                    <xsl:value-of select="@displayName"/>
                    <xsl:if test="@name and (@name != @displayName)">
                        <emphasis xmlns="http://docbook.org/ns/docbook" role="italic">
                            <xsl:text> / </xsl:text>
                            <xsl:value-of select="@name"/>
                        </emphasis>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="string-length(@name) > 0">
                    <emphasis xmlns="http://docbook.org/ns/docbook" role="italic">
                        <xsl:value-of select="@name"/>
                    </emphasis>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="getMessage">
                        <xsl:with-param name="key" select="'rulesNoNameOrDisplaynameDefinedYet'"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <sect2 xmlns="http://docbook.org/ns/docbook">
            <title>
                <xsl:call-template name="showStatusDotDBK">
                    <xsl:with-param name="status" select="@statusCode"/>
                    <xsl:with-param name="title">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="concat('TemplateStatusCodeLifeCycle-', @statusCode)"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:text> </xsl:text>
                <xsl:copy-of select="$templatename"/>
                <xsl:if test="@id">
                    <xsl:text> [</xsl:text>
                    <xsl:value-of select="@id"/>
                    <xsl:text>]</xsl:text>
                </xsl:if>

                <xsl:text> -</xsl:text>
                <xsl:if test="version">
                    <xsl:text> v</xsl:text>
                    <xsl:value-of select="@version"/>
                    <xsl:text> /</xsl:text>
                </xsl:if>

                <xsl:text> </xsl:text>
                <xsl:call-template name="showDate">
                    <xsl:with-param name="date" select="@effectiveDate"/>
                </xsl:call-template>

                <!-- in case this is a scenario transaction rule, show data -->

            </title>
            <para>
                <xsl:if test="string-length(concat($underlyingModel, $resultingRule)) > 0">
                    <informaltable frame="none" colsep="0" rowsep="0">
                        <tgroup cols="4">
                            <colspec colnum="1" colname="col1" colwidth=""/>
                            <colspec colnum="2" colname="col2" colwidth=""/>
                            <colspec colnum="3" colname="col3" colwidth=""/>
                            <colspec colnum="4" colname="col4" colwidth=""/>
                            <thead>
                                <row class="headinglabel">
                                    <entry>
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="'Direction'"/>
                                        </xsl:call-template>
                                    </entry>
                                    <entry>
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="'UnderlyingModel'"/>
                                        </xsl:call-template>
                                    </entry>
                                    <entry>
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="'RuleName'"/>
                                        </xsl:call-template>
                                    </entry>
                                    <entry>Schematron</entry>
                                </row>
                            </thead>
                            <tbody>
                                <row>
                                    <entry>
                                        <xsl:call-template name="showDirectionDBK">
                                            <xsl:with-param name="dir" select="$direction"/>
                                        </xsl:call-template>
                                        <xsl:text> </xsl:text>
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="concat('transactionDirection', $direction)"/>
                                        </xsl:call-template>
                                    </entry>
                                    <entry>
                                        <xsl:value-of select="$underlyingModel"/>
                                    </entry>
                                    <entry>
                                        <xsl:value-of select="$resultingRule"/>
                                    </entry>
                                    <entry>
                                        <xsl:value-of select="concat($projectPrefix, $resultingRule, '.sch')"/>
                                    </entry>
                                </row>
                            </tbody>
                        </tgroup>
                    </informaltable>
                </xsl:if>
            </para>
            <para>
                <xsl:variable name="t">
                    <xsl:apply-templates select=".">
                        <xsl:with-param name="templatename" select="$templatename"/>
                    </xsl:apply-templates>
                </xsl:variable>
                <xsl:apply-templates select="$t" mode="DBKcopy"/>
            </para>

        </sect2>

    </xsl:template>



    <xsl:template match="table" mode="DBKcopy">
        <xsl:variable name="columncount">
            <xsl:value-of select="'0'"/>
            <xsl:for-each select="tr">
                <xsl:sort select="count(td | th)" order="descending"/>
                <xsl:if test="position() = 1">
                    <xsl:value-of select="count(td | th)"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <informaltable xmlns="http://docbook.org/ns/docbook" frame="none" colsep="0" rowsep="0">
            <xsl:copy-of select="@bgcolor | @class"/>
            <tgroup>
                <xsl:attribute name="cols">
                    <xsl:value-of select="number($columncount)"/>
                </xsl:attribute>
                <xsl:if test="number($columncount) > 1">
                    <xsl:call-template name="generate-colspecs">
                        <xsl:with-param name="count" select="$columncount"/>
                    </xsl:call-template>
                </xsl:if>
                <tbody>
                    <xsl:apply-templates mode="DBKcopy"/>
                </tbody>
            </tgroup>
        </informaltable>
    </xsl:template>

    <xsl:template name="generate-colspecs">
        <xsl:param name="count" select="0"/>
        <xsl:param name="number" select="1"/>
        <xsl:choose>
            <xsl:when test="$count &lt; $number"/>
            <xsl:otherwise>
                <colspec xmlns="http://docbook.org/ns/docbook">
                    <xsl:attribute name="colnum">
                        <xsl:value-of select="$number"/>
                    </xsl:attribute>
                    <xsl:attribute name="colname">
                        <xsl:value-of select="concat('col', $number)"/>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="tr[1]/th[$number]/@width">
                            <xsl:attribute name="colwidth">
                                <xsl:value-of select="replace(tr[1]/th[$number]/@width, '%', '*')"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- defaults to auto size -->
                            <xsl:attribute name="colwidth" select="''"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </colspec>
                <xsl:call-template name="generate-colspecs">
                    <xsl:with-param name="count" select="$count"/>
                    <xsl:with-param name="number" select="$number + 1"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tr" mode="DBKcopy">
        <row xmlns="http://docbook.org/ns/docbook">
            <!--
            <xsl:copy-of select="@*"/>
            -->
            <xsl:copy-of select="@align | @valign"/>
            <xsl:apply-templates mode="DBKcopy"/>
        </row>
    </xsl:template>

    <xsl:template match="th | td" mode="DBKcopy">
        <entry xmlns="http://docbook.org/ns/docbook">
            <!--
            <xsl:copy-of select="@* except @colspan"/>
            -->
            <xsl:copy-of select="@align | @valign"/>
            <xsl:if test="@colspan">
                <xsl:variable name="colspan" select="@colspan - 1"/>
                <xsl:if test="$colspan > 0">
                    <xsl:attribute name="namest" select="concat('col', position())"/>
                    <xsl:attribute name="nameend" select="concat('col', position() + $colspan)"/>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates mode="DBKcopy"/>
        </entry>
    </xsl:template>

    <xsl:template match="td[@class = 'explabelblue']" mode="DBKcopy">
        <!-- no examples yet -->
        <entry xmlns="http://docbook.org/ns/docbook">
            <xsl:copy-of select="@align | @valign"/>
            <xsl:if test="@colspan">
                <xsl:variable name="colspan" select="@colspan - 1"/>
                <xsl:if test="$colspan > 0">
                    <xsl:attribute name="namest" select="concat('col', position())"/>
                    <xsl:attribute name="nameend" select="concat('col', position() + $colspan)"/>
                </xsl:if>
            </xsl:if>
            <xsl:call-template name="exmpleDBK"/>
        </entry>
    </xsl:template>

    <xsl:template name="exmpleDBK">
        <literal xmlns="http://docbook.org/ns/docbook">FAKE EXAMPLE: &lt;observation classCode="OBS"/&gt;</literal>
    </xsl:template>

    <xsl:template match="ul" mode="DBKcopy">
        <para xmlns="http://docbook.org/ns/docbook">
            <itemizedlist>
                <xsl:apply-templates mode="DBKcopy"/>
            </itemizedlist>
        </para>
    </xsl:template>

    <xsl:template match="li" mode="DBKcopy">
        <listitem xmlns="http://docbook.org/ns/docbook">
            <para>
                <xsl:apply-templates mode="DBKcopy"/>
            </para>
        </listitem>
    </xsl:template>

    <xsl:template match="strong" mode="DBKcopy">
        <emphasis xmlns="http://docbook.org/ns/docbook" role="bold">
            <xsl:apply-templates mode="DBKcopy"/>
        </emphasis>
    </xsl:template>

    <xsl:template match="i" mode="DBKcopy">
        <emphasis xmlns="http://docbook.org/ns/docbook" role="italic">
            <xsl:apply-templates mode="DBKcopy"/>
        </emphasis>
    </xsl:template>

    <!-- swallow the following -->
    <xsl:template match="a | p | br | tt | div | span" mode="DBKcopy">
        <xsl:apply-templates mode="DBKcopy"/>
    </xsl:template>

    <xsl:template match="*" mode="DBKcopy">
        <xsl:copy-of select="." copy-namespaces="no" exclude-result-prefixes="#all"/>
    </xsl:template>

    <xsl:template match="text()" mode="DBKcopy">
        <xsl:choose>
            <xsl:when test="normalize-space(.) = ''"/>
            <xsl:otherwise>
                <xsl:copy/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="img" mode="DBKcopy">
        <inlinemediaobject xmlns="http://docbook.org/ns/docbook">
            <imageobject>
                <imagedata fileref="{@src}" width="8px"/>
            </imageobject>
        </inlinemediaobject>
    </xsl:template>

    <xsl:template match="font[@color = 'grey']" mode="DBKcopy">
        <emphasis xmlns="http://docbook.org/ns/docbook" role="greytext">
            <xsl:if test="img">
                <inlinemediaobject>
                    <imageobject>
                        <imagedata fileref="{img/@src}" width="8px"/>
                    </imageobject>
                </inlinemediaobject>
                <literal> </literal>
            </xsl:if>
            <xsl:copy-of select="node() except img" copy-namespaces="no"/>
        </emphasis>
    </xsl:template>

    <xsl:template match="font" mode="DBKcopy">
        <xsl:apply-templates mode="DBKcopy"/>
    </xsl:template>

    <xsl:template name="showStatusDotDBK">
        <xsl:param name="status"/>
        <xsl:param name="title" select="$status"/>
        <xsl:variable name="t">
            <xsl:call-template name="showStatusDot">
                <xsl:with-param name="status" select="$status"/>
                <xsl:with-param name="title" select="$title"/>
            </xsl:call-template>
        </xsl:variable>
        <inlinemediaobject xmlns="http://docbook.org/ns/docbook">
            <imageobject>
                <imagedata fileref="{$t/img/@src}" width="8px"/>
            </imageobject>
        </inlinemediaobject>
    </xsl:template>

    <xsl:template name="showDirectionDBK">
        <xsl:param name="dir"/>
        <xsl:variable name="t">
            <xsl:call-template name="showDirection">
                <xsl:with-param name="dir" select="$dir"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:for-each select="$t[img]">
            <inlinemediaobject xmlns="http://docbook.org/ns/docbook">
                <imageobject>
                    <imagedata fileref="{img/@src}" width="8px"/>
                </imageobject>
            </inlinemediaobject>
        </xsl:for-each>
    </xsl:template>


</xsl:stylesheet>
