<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    
    DECOR to wiki
    Copyright © ART-DECOR Expert Group and ART-DECOR Open Tools
    see https://art-decor.org/mediawiki/index.php?title=Copyright
    
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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:local="http://art-decor.org/functions" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="2.0" exclude-result-prefixes="#all">
    
    <!--
        parameters
        ==========
        to this XSLT and all invoked scripts
    -->
    <xsl:param name="language" select="'de-DE'"/>
    <xsl:param name="tmpdir" select="'tmp'"/>
    
    <!-- not used yet, only by DECORbasics -->
    <xsl:variable name="defaultLanguage" select="//project/@defaultLanguage"/>
    <xsl:variable name="projectDefaultLanguage" select="//project/@defaultLanguage"/>
    
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
    <xsl:param name="bindingBehaviorValueSets" select="'freeze'"/>
    <xsl:param name="bindingBehaviorValueSetsURL"/>
    <xsl:param name="hideColumns" select="false()"/>
    <xsl:param name="logLevel" select="'INFO'"/>
    <xsl:param name="theLogLevel" select="'INFO'"/>
    <!-- ADRAM deeplink prefix for issues etc -->
    <xsl:param name="artdecordeeplinkprefix" as="xs:string?">
        <xsl:choose>
            <xsl:when test="(//decor/@deeplinkprefix)[1]">
                <xsl:value-of select="(//decor/@deeplinkprefix)[1]"/>
            </xsl:when>
        </xsl:choose>
    </xsl:param>
    <!-- 
        if this xsl is invoked by ADRAM service the adram variable is set to the version
    -->
    <xsl:param name="adram" as="xs:string?" select="'wiki'"/>
    <xsl:param name="inputStaticBaseUri" select="static-base-uri()"/>
    <xsl:param name="inputBaseUri" select="base-uri()"/>
    <xsl:param name="theBaseURI2DECOR" select="string-join(tokenize($inputBaseUri, '/')[position() &lt; last()], '/')"/>
    
    <!-- die on circular references or not, values: 'continue' (default), 'die' -->
    <xsl:param name="onCircularReferences" select="'continue'"/>
    
    <xsl:param name="filtersfile" select="concat($theBaseURI2DECOR, '/', 'filters.xml')"/>
    <xsl:param name="filtersfileavailable" select="doc-available($filtersfile)" as="xs:boolean"/>
    
    <!-- see this URL in asserts and reports points to 'generated' HTML fiels or to the 'live' environment.
        It also determines context for any other HTML link.
    -->
    <xsl:param name="seeThisUrlLocation" select="'generated'"/>
    
    <!-- Do HTML with treetree/treeblank indenting (default. or set to false()) or treetable.js compatible indenting -->
    <!--xsl:param name="switchCreateTreeTableHtml" select="'false'"/-->
    <xsl:param name="switchCreateTreeTableHtml" select="'false'"/>
       
    
    <xsl:include href="DECOR2html.xsl"/>
    <xsl:include href="DECOR-basics.xsl"/>
    <xsl:include href="DECOR-cardinalitycheck.xsl"/>
    <xsl:include href="DECOR-attributecheck.xsl"/>
        
    <xsl:output method="xml" name="xml" indent="yes" version="1.0" encoding="UTF-8" exclude-result-prefixes="#all"/>
    <xsl:output method="text" name="text"/>
    <xsl:output method="html" name="html" indent="no" omit-xml-declaration="yes" version="4.01" encoding="UTF-8"  doctype-system="http://www.w3.org/TR/html4/strict.dtd"/>
    <xsl:output method="xhtml" name="xhtml" indent="no" omit-xml-declaration="yes" encoding="UTF-8" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>   

    <!-- store all value sets and templates of this projects for later reference -->
    <xsl:variable name="allvs" select="//valueSet"/>
    <xsl:variable name="alltmp" select="//template"/>
    
    <xsl:variable name="includerefs">
        <xsl:if test="doc-available(concat($theBaseURI2DECOR, '/includerefs.xml'))">
            <xsl:copy-of select="doc(concat($theBaseURI2DECOR, '/includerefs.xml'))"/>
        </xsl:if>
    </xsl:variable>
    <xsl:variable name="identOfGovernanceGroup" select="//identOfGovernanceGroup"/>
    
    <xsl:variable name="deeplinkprefixservices" select="//decor/@deeplinkprefixservices"/>
    
    <xsl:function name="local:matchesExplicitIncludes" as="xs:boolean">
        <xsl:param name="id"/>
        <xsl:choose>
            <xsl:when test="count($includerefs//*[@ref=$id])>0">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="local:identOfGovernanceGroup" as="xs:boolean">
        <xsl:param name="ident"/>
        <xsl:choose>
            <xsl:when test="string-length($ident)=0">
                <!-- always include non indent templates -->
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when test="count($identOfGovernanceGroup[@ident=$ident])>0">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template match="/">
        
        <!--<xsl:for-each select="//template[@id=('2.16.840.1.113883.10.22.4.27', '2.16.840.1.113883.10.22.4.29')]">
            <xsl:variable name="templatename">
                <xsl:choose>
                    <xsl:when test="string-length(@displayName)>0">
                        <xsl:value-of select="@displayName"/>
                        <xsl:if test="@name and (@name != @displayName)">
                            <i>
                                <xsl:text> / </xsl:text>
                                <xsl:value-of select="@name"/>
                            </i>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="string-length(@name)>0">
                        <i>
                            <xsl:value-of select="@name"/>
                        </i>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'rulesNoNameOrDisplaynameDefinedYet'"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="t">
                <xsl:apply-templates select=".">
                    <xsl:with-param name="templatename" select="$templatename"/>
                </xsl:apply-templates>
            </xsl:variable>
            <xsl:result-document href="{concat('___', @id, '.html')}" method="xhtml" indent="no" omit-xml-declaration="yes">
                <xsl:apply-templates select="$t" mode="simplify"/>
                <xsl:text>&#10;</xsl:text>
            </xsl:result-document>
        </xsl:for-each>-->
        
        <xsl:result-document href="{$tmpdir}/index.xml" format="xml" method="xml">
            <index>
                <!-- phase Ia: templates static -->
                <xsl:for-each-group select="//template[(@id and not(@ident)) or (@id and local:identOfGovernanceGroup(@ident)) or local:matchesExplicitIncludes(@id)]" group-by="concat(@id,@effectiveDate)">
                    <xsl:variable name="tid" select="@id"/>
                    <xsl:variable name="templatename">
                        <xsl:choose>
                            <xsl:when test="string-length(@displayName)>0">
                                <xsl:value-of select="@displayName"/>
                                <xsl:if test="@name and (@name != @displayName)">
                                    <i>
                                        <xsl:text> / </xsl:text>
                                        <xsl:value-of select="@name"/>
                                    </i>
                                </xsl:if>
                            </xsl:when>
                            <xsl:when test="string-length(@name)>0">
                                <i>
                                    <xsl:value-of select="@name"/>
                                </i>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'rulesNoNameOrDisplaynameDefinedYet'"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="t">
                        <xsl:apply-templates select=".">
                            <xsl:with-param name="templatename" select="$templatename"/>
                        </xsl:apply-templates>
                    </xsl:variable>
                    <!-- create a time stamp based on effectiveDate as YYYY-MM-DDThhmmss (without the :) and an alternative shortcut timepstamp YYYY-MM-DD if time is T00:00:00 -->
                    <xsl:variable name="ed" select="replace(@effectiveDate,':','')"/>
                    <xsl:variable name="xeffshort">
                        <xsl:if test="string-length(substring-before(@effectiveDate, 'T00:00:00'))>0">
                            <xsl:value-of select="substring-before(@effectiveDate, 'T00:00:00')"/>
                        </xsl:if>
                    </xsl:variable>
                    <xsl:variable name="fns" select="concat($tmpdir, '/tmp-', $tid, '-', $ed, '.html')"/>
                    <xsl:variable name="wikis" select="concat($tid, '/static-', $ed)"/>
                    <ix fn="{$fns}" wiki="{$wikis}" type="html" id="{$tid}"/>
                    <!--
                    <xsl:result-document href="{concat($fns, '.xhtml')}" method="xhtml" indent="no" omit-xml-declaration="yes">
                        <xsl:copy-of select="$t"/>
                    </xsl:result-document>
                    -->
                    <xsl:result-document href="{$fns}" method="xhtml" indent="no" omit-xml-declaration="yes">
                        <xsl:apply-templates select="$t" mode="simplify"/>
                        <xsl:text>&#10;</xsl:text>
                    </xsl:result-document>
                    <xsl:if test="string-length($xeffshort)>0">
                        <xsl:variable name="fndx" select="concat($tmpdir, '/tmp-', $tid, '-', $ed, '-redirect.txt')"/>
                        <ix fn ="{$fndx}" wiki="{concat(@id, '/static-', $xeffshort)}" type="text" id="{$tid}"/>
                        <xsl:result-document href="{$fndx}" format="text">
                            <xsl:text>#REDIRECT [[</xsl:text>
                            <xsl:value-of select="$wikis"/>
                            <xsl:text>]]</xsl:text>
                            <xsl:text>&#10;</xsl:text>
                            <xsl:text>&lt;!-- </xsl:text>
                            <xsl:value-of select="@name"/>
                            <xsl:text> --&gt;</xsl:text>
                            <xsl:call-template name="nomanualeditstext"/>
                        </xsl:result-document>
                    </xsl:if>
                </xsl:for-each-group>
                
                <!-- phase Ib: templates dynamic and summary -->
                <xsl:for-each-group select="//template[(@id and not(@ident)) or (@id and local:identOfGovernanceGroup(@ident)) or local:matchesExplicitIncludes(@id)]" group-by="@id">
                    <!-- template dynamic -->
                    <xsl:variable name="tid" select="@id"/>
                    <!-- most recent template version with status code any of draft active review pending -->
                    <xsl:variable name="maxstaticdate" select="max($alltmp[(@id=$tid)][@statusCode = ('draft', 'active', 'review', 'pending')]/xs:dateTime(@effectiveDate))"/>
                    <xsl:variable name="maxstatic" select="replace(string($maxstaticdate),':','')"/>
                    <xsl:variable name="fnd" select="concat($tmpdir, '/tmp-', $tid, '-dynamic.txt')"/>
                    <xsl:variable name="wikid" select="concat(@id, '/dynamic')"/>
                    <!-- write info to index file -->
                    <ix fn ="{$fnd}" wiki="{$wikid}" type="text" id="{@id}"/>
                    <!-- create the result document "dynamic" which is a wiki redirect only -->
                    <xsl:result-document href="{$fnd}" format="text">
                        <xsl:choose>
                            <xsl:when test="string-length($maxstatic)>0">
                                <xsl:text>#REDIRECT [[</xsl:text>
                                <xsl:value-of select="concat(@id, '/static-', $maxstatic)"/>
                                <xsl:text>]]</xsl:text>
                                <xsl:text>&#10;</xsl:text>
                                <xsl:text>&lt;!-- </xsl:text>
                                <xsl:value-of select="@name"/>
                                <xsl:text> --&gt;</xsl:text>
                                <xsl:call-template name="nomanualeditstext"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>Keine Versionen mit Status draft, active, review oder pending.</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:result-document>
                    <!-- create the result document "summary" -->
                    <xsl:variable name="fnr" select="concat($tmpdir, '/tmp-', $tid, '-summary.txt')"/>
                    <xsl:variable name="wikir" select="@id"/>
                    <!-- write info to index file -->
                    <ix fn ="{$fnr}" wiki="{$wikir}" type="text" id="{@id}"/>
                    <xsl:result-document href="{$fnr}" format="text">
                        <xsl:text>__NOTOC__</xsl:text>
                        <xsl:call-template name="nomanualeditstext"/>
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'wikitemplatenote'"/>
                        </xsl:call-template>
                        <xsl:text>&#10;</xsl:text>
                        <xsl:text>[[Category:Template]]</xsl:text>
                        <xsl:text>&#10;</xsl:text>
                        <xsl:text>=Template ''</xsl:text>
                        <xsl:value-of select="@name"/>
                        <xsl:text>''=</xsl:text>
                        <xsl:text>&#10;</xsl:text>
                        <xsl:if test="desc[@language=$language]">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'wikidescription'"/>
                            </xsl:call-template>
                            <xsl:text>&#10;</xsl:text>
                            <xsl:text>&lt;p></xsl:text>
                            <xsl:copy-of select="desc[@language=$language]"/>
                            <xsl:text>&lt;/p></xsl:text>
                            <xsl:text>&#10;</xsl:text>
                        </xsl:if>
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'wikiactualversion'"/>
                        </xsl:call-template>
                        <xsl:text>&#10;</xsl:text>
                        <xsl:text>{{:{{BASEPAGENAME}}/dynamic}}</xsl:text>
                        <xsl:text>&#10;</xsl:text>
                        <xsl:text>&#10;</xsl:text>
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'wikilisttemplateversions'"/>
                        </xsl:call-template>
                        <xsl:text>&#10;</xsl:text>
                        <xsl:choose>
                            <xsl:when test="count($alltmp[(@id=$tid and not(@ident)) or (@id=$tid and local:matchesExplicitIncludes(@id))]) &lt;= 0">
                                <xsl:text>(bisher keine weiteren Angaben)</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:for-each select="$alltmp[(@id=$tid and not(@ident)) or (@id=$tid and local:matchesExplicitIncludes(@id))]">
                                    <xsl:sort select="@effectiveDate" order="descending"/>
                                    <xsl:variable name="edd">
                                        <xsl:choose>
                                            <xsl:when test="string-length(substring-before(@effectiveDate, 'T00:00:00'))>0">
                                                <xsl:value-of select="substring-before(@effectiveDate, 'T00:00:00')"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="replace(@effectiveDate, 'T', ' ')"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>
                                    <xsl:text>* [[</xsl:text>
                                    <xsl:value-of select="@id"/>
                                    <xsl:text>/static-</xsl:text>
                                    <xsl:value-of select="replace(@effectiveDate,':','')"/>
                                    <xsl:text>|</xsl:text>
                                    <xsl:value-of select="$edd"/>
                                    <xsl:text> (</xsl:text>
                                    <!-- 
                                        <xsl:value-of select="@statusCode"/>
                                    -->
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="concat('TemplateStatusCodeLifeCycle-',@statusCode)"/>
                                    </xsl:call-template>
                                    <xsl:text>)</xsl:text>
                                    <xsl:text>]]</xsl:text>
                                    <xsl:text>&#10;</xsl:text>
                                </xsl:for-each>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:result-document>
                
                    <!-- create the hiergraph files for templates -->
                    <xsl:variable name="fnh" select="concat($tmpdir, '/tmp-', $tid, '-hgraph.html')"/>
                    <xsl:variable name="wikihg" select="concat(@id, '/hgraph')"/>
                    <xsl:if test="true()">
                        <ix fn ="{$fnh}" wiki="{$wikihg}" type="html" id="{@id}"/>
                        <xsl:variable name="hct">
                            <xsl:copy-of select="doc(concat($deeplinkprefixservices, '/RetrieveTemplateDiagram?project=', @referencedFrom, '&amp;id=',
                                $tid, '&amp;effectiveDate=', $maxstaticdate, '&amp;language=', $language, '&amp;format=hgraph'))"/>
                        </xsl:variable>
                        <xsl:if test="$hct//body/table">
                            <xsl:result-document href="{$fnh}" method="xhtml" indent="no" omit-xml-declaration="yes">
                                <xsl:copy-of select="$hct//body/table"/>
                                <xsl:text>&#10;</xsl:text>
                            </xsl:result-document>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each-group>
                
                <!--
                        per value set with id and effective date
                        - create one rendering per effective date (version) with that id, e.g. 2.16.840.1.113883.1.11.1/static-2012-07-24
                        - create one redirect as the dynamic rendering, i.e. 2.16.840.1.113883.1.11.1/dynamic
                        - create one summary 2.16.840.1.113883.1.11.1
                        - create one redirect to the summary page named as the name of the value set
                    -->
                
                <!-- phase IIa: value set static; cave duplicate id+effectiveDate combinations due to multiple repository references -->
                <xsl:for-each-group select="//valueSet[(@id and not(@ident)) or (@id and local:identOfGovernanceGroup(@ident)) or local:matchesExplicitIncludes(@id)]" group-by="concat(@id, @effectiveDate)">
                    <xsl:variable name="vid" select="@id"/>
                    <xsl:if test="string-length($vid)>0">
                        <!-- create a time stamp based on effectiveDate as YYYY-MM-DDThhmmss (without the :) and an alternative shortcut timepstamp YYYY-MM-DD if time is T00:00:00 -->
                        <xsl:variable name="ed" select="replace(@effectiveDate,':','')"/>
                        <xsl:variable name="xeffshort">
                            <xsl:if test="string-length(substring-before(@effectiveDate, 'T00:00:00'))>0">
                                <xsl:value-of select="substring-before(@effectiveDate, 'T00:00:00')"/>
                            </xsl:if>
                        </xsl:variable>
                        <xsl:variable name="fns" select="concat($tmpdir, '/vs-', @id, '-', $ed, '.html')"/>
                        <xsl:variable name="wikis" select="concat(@id, '/static-', replace(@effectiveDate,':',''))"/>
                        <!-- write info to index file -->
                        <ix fn ="{$fns}" wiki="{$wikis}" type="html" cat="vs" id="{@id}" effectiveDate="{@effectiveDate}"/>
                        <xsl:variable name="t">
                            <xsl:apply-templates select=".">
                                <xsl:with-param name="showOtherVersionsList" select="false()"/>
                            </xsl:apply-templates>
                        </xsl:variable>
                        <xsl:result-document href="{$fns}" format="xhtml" indent="no" omit-xml-declaration="yes">
                            <xsl:apply-templates select="$t" mode="simplify"/>
                            <xsl:text>&#10;</xsl:text>
                        </xsl:result-document>
                        <xsl:if test="string-length($xeffshort)>0">
                            <xsl:variable name="fndx" select="concat($tmpdir, '/vs-', @id, '-', $ed, '-redirect.txt')"/>
                            <!-- write info to index file -->
                            <ix fn ="{$fndx}" wiki="{concat(@id, '/static-', $xeffshort)}" type="text" id="{@id}"/>
                            <!-- create the result document "redirect" which is a wiki redirect -->
                            <xsl:result-document href="{$fndx}" format="text">
                                <xsl:text>#REDIRECT [[</xsl:text>
                                <xsl:value-of select="$wikis"/>
                                <xsl:text>]]</xsl:text>
                                <xsl:text>&#10;</xsl:text>
                                <xsl:text>&lt;!-- </xsl:text>
                                <xsl:value-of select="@name"/>
                                <xsl:text> --&gt;</xsl:text>
                                <xsl:call-template name="nomanualeditstext"/>
                            </xsl:result-document>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each-group>
                
                <!-- phase IIb: value set dynamic and summary -->
                <xsl:for-each-group select="//valueSet[(@id and not(@ident)) or (@id and local:identOfGovernanceGroup(@ident)) or local:matchesExplicitIncludes(@id)]" group-by="@id">
                    <!-- dynamic -->
                    <xsl:variable name="vid" select="@id"/>
                    <xsl:if test="string-length($vid)>0">
                        <!-- most recent value set version with status code any of new draft final review pending -->
                        <xsl:variable name="maxstaticdate" select="max($allvs[(@id=$vid) and @statusCode = ('new', 'draft', 'final', 'review', 'pending')]/xs:dateTime(@effectiveDate))"/>
                        <xsl:variable name="maxstatic" select="replace(string($maxstaticdate),':','')"/>
                        <xsl:variable name="fnd" select="concat($tmpdir, '/vs-', $vid, '-dynamic.txt')"/>
                        <xsl:variable name="wikid" select="concat(@id, '/dynamic')"/>
                        <!-- write info to index file -->
                        <ix fn ="{$fnd}" wiki="{$wikid}" type="text" id="{@id}"/>
                        <!-- create the result document "dynamic" which is a wiki redirect only -->
                        <xsl:result-document href="{$fnd}" format="text">
                            <xsl:choose>
                                <xsl:when test="string-length($maxstatic)>0">
                                    <xsl:text>#REDIRECT [[</xsl:text>
                                    <xsl:value-of select="concat(@id, '/static-', $maxstatic)"/>
                                    <xsl:text>]]</xsl:text>
                                    <xsl:text>&#10;</xsl:text>
                                    <xsl:text>&lt;!-- </xsl:text>
                                    <xsl:value-of select="@name"/>
                                    <xsl:text> --&gt;</xsl:text>
                                    <xsl:call-template name="nomanualeditstext"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>Keine Versionen mit Status new, draft, final, review or pending.</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:result-document>
                        <!-- create the result document "summary" -->
                        <xsl:variable name="fnr" select="concat($tmpdir, '/vs-', $vid, '-summary.txt')"/>
                        <xsl:variable name="wikir" select="@id"/>
                        <ix fn ="{$fnr}" wiki="{$wikir}" type="text" id="{@id}"/>
                        <xsl:result-document href="{$fnr}" format="text">
                            <xsl:text>__NOTOC__</xsl:text>
                            <xsl:call-template name="nomanualeditstext"/>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'wikiterminologynote'"/>
                            </xsl:call-template>
                            <xsl:text>&#10;</xsl:text>
                            <xsl:text>[[Category:Value Set]]</xsl:text>
                            <xsl:text>&#10;</xsl:text>
                            <xsl:text>=Value Set ''</xsl:text>
                            <xsl:value-of select="@name"/>
                            <xsl:text>''=</xsl:text>
                            <xsl:text>&#10;</xsl:text>
                            <xsl:if test="desc[@language=$language]">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'wikidescription'"/>
                                </xsl:call-template>
                                <xsl:text>&#10;</xsl:text>
                                <xsl:text>&lt;p></xsl:text>
                                <xsl:copy-of select="desc[@language=$language]"/>
                                <xsl:text>&lt;/p></xsl:text>
                                <xsl:text>&#10;</xsl:text>
                            </xsl:if>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'wikiactualversion'"/>
                            </xsl:call-template>
                            <xsl:text>&#10;</xsl:text>
                            <xsl:text>{{:{{BASEPAGENAME}}/dynamic}}</xsl:text>
                            <xsl:text>&#10;</xsl:text>
                            <xsl:text>&#10;</xsl:text>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'wikilistvaluesetversions'"/>
                            </xsl:call-template>
                            <xsl:text>&#10;</xsl:text>
                            <xsl:choose>
                                <xsl:when test="count($allvs[(@id=$vid and not(@ident)) or (@id=$vid and local:matchesExplicitIncludes(@id))]) &lt;= 0">
                                    <xsl:text>(bisher keine weiteren Angaben)</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:for-each-group select="$allvs[(@id=$vid and not(@ident)) or (@id=$vid and local:matchesExplicitIncludes(@id))]" group-by="concat(@id, @effectiveDate)">
                                        <xsl:sort select="@effectiveDate" order="descending"/>
                                        <xsl:variable name="edd">
                                            <xsl:choose>
                                                <xsl:when test="string-length(substring-before(@effectiveDate, 'T00:00:00'))>0">
                                                    <xsl:value-of select="substring-before(@effectiveDate, 'T00:00:00')"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="replace(@effectiveDate, 'T', ' ')"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:variable>
                                        <xsl:text>* [[</xsl:text>
                                        <xsl:value-of select="@id"/>
                                        <xsl:text>/static-</xsl:text>
                                        <xsl:value-of select="replace(@effectiveDate,':','')"/>
                                        <xsl:text>|</xsl:text>
                                        <xsl:value-of select="$edd"/>
                                        <xsl:text> (</xsl:text>
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="concat('ItemStatusCodeLifeCycle-', @statusCode)"/>
                                        </xsl:call-template>
                                        <xsl:text>)</xsl:text>
                                        <xsl:text>]]</xsl:text>
                                        <xsl:text>&#10;</xsl:text>
                                    </xsl:for-each-group>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:result-document>
                    </xsl:if>
                </xsl:for-each-group>
                
                <!-- redirect for named object for value sets and templates (maybe depracated in the future) -->
                <xsl:for-each-group select="//valueSet[@name][(@id and not(@ident)) or local:matchesExplicitIncludes(@id)]" group-by="@name">
                    <xsl:variable name="fnl" select="concat($tmpdir, '/vs-', @name, '-name.txt')"/>
                    <xsl:variable name="wikil" select="concat(@name, ' (Value Set)')"/>
                    <xsl:if test="string-length(@id)>0">
                        <ix fn ="{$fnl}" wiki="{$wikil}" type="text" id="{@id}"/>
                        <xsl:result-document href="{$fnl}" format="text">
                            <xsl:text>#REDIRECT [[</xsl:text>
                            <xsl:value-of select="@id"/>
                            <xsl:text>]]</xsl:text>
                            <xsl:text>&#10;[[Category:Value Set]]&#10;</xsl:text>
                            <xsl:text>&lt;!-- </xsl:text>
                            <xsl:value-of select="@name"/>
                            <xsl:text> --&gt;</xsl:text>
                            <xsl:call-template name="nomanualeditstext"/>
                        </xsl:result-document>
                    </xsl:if>
                </xsl:for-each-group>
                <xsl:for-each-group select="//template[@name][(@id and not(@ident)) or local:matchesExplicitIncludes(@id)]" group-by="@name">
                    <xsl:variable name="fnl" select="concat($tmpdir, '/tmp-', @name, '-name.txt')"/>
                    <xsl:variable name="wikil" select="concat(@name, ' (Template)')"/>
                    <xsl:if test="string-length(@id)>0">
                        <ix fn ="{$fnl}" wiki="{$wikil}" type="text" id="{@id}"/>
                        <xsl:result-document href="{$fnl}" format="text">
                            <xsl:text>#REDIRECT [[</xsl:text>
                            <xsl:value-of select="@id"/>
                            <xsl:text>]]</xsl:text>
                            <xsl:text>&#10;[[Category:Template]]&#10;</xsl:text>
                            <xsl:text>&lt;!-- </xsl:text>
                            <xsl:value-of select="@name"/>
                            <xsl:text> --&gt;</xsl:text>
                            <xsl:call-template name="nomanualeditstext"/>
                        </xsl:result-document>
                    </xsl:if>
                </xsl:for-each-group>
            
            </index>
        </xsl:result-document>
    </xsl:template>
    <!-- 
        helpers
    -->
    <xsl:template match="xhtml:table" mode="simplify">
        <table xmlns="http://www.w3.org/1999/xhtml" class="artdecor">
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="style" select="'background: transparent;'"/>
            <xsl:apply-templates mode="simplify"/>
        </table>
    </xsl:template>
    <xsl:template match="br|xhtml:br" mode="simplify">
        <br xmlns="http://www.w3.org/1999/xhtml"/>
    </xsl:template>
    <xsl:template match="xhtml:th|xhtml:tr|xhtml:font|xhtml:i|xhtml:tt|xhtml:span|xhtml:strong|xhtml:ul|xhtml:li|xhtml:p" mode="simplify">
        <xsl:element xmlns="http://www.w3.org/1999/xhtml" name="{name()}">
            <xsl:copy-of select="@* except (@data-tt-id|@data-tt-parent-id)"/>
            <xsl:apply-templates mode="simplify"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="xhtml:td|xhtml:div" mode="simplify">
        <xsl:element xmlns="http://www.w3.org/1999/xhtml" name="{name()}">
            <xsl:copy-of select="@* except (@id | @onclick | @class)" copy-namespaces="no"/>
            <xsl:variable name="classes" as="xs:string*">
                <xsl:for-each select="tokenize(normalize-space(@class),'\s')">
                    <xsl:if test=". = ('conf', 'defvar', 'stron', 'tabtab', 'togglertreetable', 'explabelgreen', 'explabelred', 'explabelblue', 'note-box', 'repo', 'refonly',
                        'ad-diff-topbox', 'ad-diff-bottombox', 'nowrapinline', 'cdadocumentlevel', 'cdaheaderlevel', 'cdasectionlevel', 'cdaentrylevel',
                        'ad-templatetype',  'ad-dataset-itemnumber', 'ad-dataset-level1', 'ad-itemnumber-green', 'ad-itemnumber-blue') or starts-with(., 'column')">
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
    <xsl:template match="xhtml:thead|xhtml:tbody" mode="simplify">
        <xsl:apply-templates mode="simplify"/>
    </xsl:template>
    <xsl:template match="xhtml:a" mode="simplify">
        <xsl:apply-templates mode="simplify"/>
    </xsl:template>
    <xsl:template match="*" mode="simplify" priority="-2">
        <xsl:copy-of select="." copy-namespaces="no" exclude-result-prefixes="#all"/>
    </xsl:template>
    <xsl:template match="*/text()[normalize-space(.)][../*]" mode="simplify">
        <xsl:value-of select="translate(., '&#xA;&#xD;', ' ')"/>
    </xsl:template>
    <xsl:template match="text()" mode="simplify" priority="-2">
        <xsl:value-of select="translate(., '&#xA;&#xD;', ' ')"/>
    </xsl:template>
    <xsl:template match="@*|node()" mode="simplify">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="simplify"/>
        </xsl:copy>
    </xsl:template>
    
    <!--
    <xsl:template match="text()" mode="simplify">
        <xsl:value-of select="."/>
        <xsl:apply-templates mode="simplify"/>
    </xsl:template>
    -->
    <xsl:template match="xhtml:img[ends-with(@src, '/treeblank.png')]" mode="simplify">
        <xsl:text>[[File:Treeblank.png|16px]]</xsl:text>
        <xsl:apply-templates mode="simplify"/>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, 'treetree.png')]" mode="simplify">
        <xsl:text>[[File:Treetree.png|16px]]</xsl:text>
        <xsl:apply-templates mode="simplify"/>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/notice.png')]" mode="simplify">
        <xsl:text>[[File:Notice.png|16px]]</xsl:text>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/link.png')]" mode="simplify">
        <xsl:text>[[File:Link.png|14px]]</xsl:text>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/en-US.png')]" mode="simplify">
        <xsl:text>[[File:EN-US.png]]</xsl:text>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/de-DE.png')]" mode="simplify">
        <xsl:text>[[File:DE-DE.png]]</xsl:text>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/nl-NL.png')]" mode="simplify">
        <xsl:text>[[File:NL-NL.png]]</xsl:text>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/alert.png')]" mode="simplify">
        <xsl:text>[[File:Alert.png|16px]]</xsl:text>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/target.png')]" mode="simplify">
        <xsl:text>[[File:Target.png|14px]]</xsl:text>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/reddot.gif')]" mode="simplify">
        <xsl:text>[[File:Kred.png|14px]]</xsl:text>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/orangedot.gif')]" mode="simplify">
        <xsl:text>[[File:Korange.png|14px]]</xsl:text>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/yellowdot.gif')]" mode="simplify">
        <xsl:text>[[File:Kyellow.png|14px]]</xsl:text>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/kyellow.png')]" mode="simplify">
        <xsl:text>[[File:Kyellow.png|14px]]</xsl:text>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/kvalidgreen.png')]" mode="simplify">
        <xsl:text>[[File:Kvalidgreen.png|14px]]</xsl:text>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/kvalidblue.png')]" mode="simplify">
        <xsl:text>[[File:Kvalidblue.png|12px]]</xsl:text>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/kred.png')]" mode="simplify">
        <xsl:text>[[File:Kred.png|12px]]</xsl:text>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/kpurple.png')]" mode="simplify">
        <xsl:text>[[File:Kpurple.png|14px]]</xsl:text>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/korange.png')]" mode="simplify">
        <xsl:text>[[File:Korange.png|14px]]</xsl:text>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/kgrey.png')]" mode="simplify">
        <xsl:text>[[File:Kgrey.png|14px]]</xsl:text>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/kgreen.png')]" mode="simplify">
        <xsl:text>[[File:Kgreen.png|14px]]</xsl:text>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/kblue.png')]" mode="simplify">
        <xsl:text>[[File:Kblue.png|14px]]</xsl:text>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/kcancelledblue.png')]" mode="simplify">
        <xsl:text>[[File:Kcancelledblue.png|14px]]</xsl:text>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/kblank.png')]" mode="simplify">
        <xsl:text>[[File:Kblank.png|14px]]</xsl:text>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/circleplus.png')]" mode="simplify">
        <xsl:text>[[File:Circleplus.png|14px]]</xsl:text>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/circleminus.png')]" mode="simplify">
        <xsl:text>[[File:Circleminus.png|14px]]</xsl:text>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/dots.png')]" mode="simplify">
        <xsl:text>...</xsl:text>
    </xsl:template>
    <xsl:template name="nomanualedits">
        <xsl:text>&#10;</xsl:text>
        <xsl:comment> ****** CAUTION Manual changes on this page are ineffective: the page is automagically generated by a transformer from an ART-DECOR project by a bot (ADBot). ****** </xsl:comment>
    </xsl:template>
    <xsl:template name="nomanualeditstext">
        <xsl:text>&#10;</xsl:text>
        <xsl:text>&lt;!-- ****** CAUTION Manual changes on this page are ineffective: the page is automagically generated by a transformer from an ART-DECOR project by a bot (ADBot). ****** --&gt;</xsl:text>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>
</xsl:stylesheet>