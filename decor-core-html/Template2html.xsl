<!-- 
    Copyright © ART-DECOR Expert Group and ART-DECOR Open Tools
    see https://art-decor.org/mediawiki/index.php?title=Copyright
    
    Author: Dr. Kai U. Heitmann
    
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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.0" exclude-result-prefixes="#all">
    
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
    <xsl:param name="useLocalAssets" select="false()"/>
    <xsl:param name="useLocalLogos" select="false()"/>
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
    <xsl:param name="filtersfileavailable" select="doc-available($filtersfile)" as="xs:boolean"/>
    
    
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
    <xsl:template match="/">
        <xsl:variable name="tp" as="element()*">
            <xsl:copy-of select="/*/template/template[@id]" copy-namespaces="no"/>
        </xsl:variable>
        <xsl:for-each select="$tp">
            <xsl:variable name="theName" select="if (@displayName) then @displayName else @name"/>
            <xsl:if test="$displayHeader = 'true'">
                <h1 xmlns="http://www.w3.org/1999/xhtml">
                    <xsl:call-template name="getMessage">
                        <xsl:with-param name="key" select="'Template'"/>
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
            <xsl:variable name="t">
                <xsl:apply-templates select=".">
                    <xsl:with-param name="templatename" select="$theName"/>
                </xsl:apply-templates>
            </xsl:variable>
            <!--<xsl:copy-of select="$t" copy-namespaces="no"/>-->
            <xsl:apply-templates select="$t" mode="simplify"/>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="xhtml:table" mode="simplify">
        <table xmlns="http://www.w3.org/1999/xhtml" class="artdecor">
            <xsl:copy-of select="@*" copy-namespaces="no"/>
            <xsl:apply-templates mode="simplify"/>
        </table>
    </xsl:template>
    <xsl:template match="br | xhtml:br" mode="simplify">
        <br xmlns="http://www.w3.org/1999/xhtml"/>
    </xsl:template>
    <xsl:template match="xhtml:th | xhtml:tr | xhtml:font | xhtml:i | xhtml:tt | xhtml:span | xhtml:strong | xhtml:ul | xhtml:li | xhtml:p" mode="simplify">
        <xsl:element xmlns="http://www.w3.org/1999/xhtml" name="{name()}">
            <xsl:copy-of select="@*" copy-namespaces="no"/>
            <xsl:apply-templates mode="simplify"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="xhtml:td | xhtml:div" mode="simplify">
        <xsl:element xmlns="http://www.w3.org/1999/xhtml" name="{name()}">
            <xsl:copy-of select="@* except (@id | @onclick | @class)" copy-namespaces="no"/>
            <xsl:variable name="classes" as="xs:string*">
                <xsl:for-each select="tokenize(normalize-space(@class),'\s')">
                    <xsl:if test=". = ('conf', 'defvar', 'stron', 'tabtab', 'togglertreetable', 'explabelgreen', 'explabelred', 'explabelblue', 'note-box', 'repo', 'refonly', 'ad-diff-topbox', 'ad-diff-bottombox', 'nowrapinline', 'cdadocumentlevel', 'cdaheaderlevel', 'cdasectionlevel', 'cdaentrylevel', 'ad-templatetype',  'ad-dataset-itemnumber', 'ad-dataset-level1', 'ad-itemnumber-green', 'ad-itemnumber-blue') or starts-with(., 'column')">
                        <xsl:value-of select="."/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>
            <xsl:if test="not(empty($classes))">
                <xsl:attribute name="class" select="string-join($classes,' ')"/>
            </xsl:if>
            <xsl:apply-templates mode="simplify"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="xhtml:thead | xhtml:tbody" mode="simplify">
        <xsl:apply-templates mode="simplify"/>
    </xsl:template>
    <xsl:template match="xhtml:a" mode="simplify">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="simplify"/>
        </xsl:copy>
        <!--<xsl:apply-templates mode="simplify"/>-->
    </xsl:template>
    <xsl:template match="*" mode="simplify" priority="-2">
        <xsl:copy-of select="." copy-namespaces="no" exclude-result-prefixes="#all"/>
    </xsl:template>
    <xsl:template match="text()" mode="simplify" priority="-2">
        <xsl:value-of select="replace(., '\r?\n', ' ')"/>
    </xsl:template>
    <xsl:template match="processing-instruction() | comment()" mode="simplify" priority="-2">
        <xsl:copy/>
    </xsl:template>
    <xsl:template match="*" mode="simplify">
        <xsl:copy copy-namespaces="no">
            <xsl:copy-of select="@*" copy-namespaces="no"/>
            <xsl:apply-templates mode="simplify"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>