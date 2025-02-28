<!-- 
    ART-DECOR® STANDARD COPYRIGHT AND LICENSE NOTE
    Copyright © ART-DECOR Expert Group and ART-DECOR Open Tools GmbH
    see https://docs.art-decor.org/copyright and https://docs.art-decor.org/licenses

    This file is part of the ART-DECOR® tools suite.    
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:local="http://art-decor.org/functions" xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:ac="http://www.atlassian.com/schema/confluence/4/ac/" xmlns:ri="http://www.atlassian.com/schema/confluence/4/ri/"
    xmlns:svg="http://www.w3.org/2000/svg" xmlns:err="http://www.w3.org/2005/xqt-errors" version="2.0" exclude-result-prefixes="#all">
    
    <!--
        parameters
        ==========
        to this XSLT and all invoked scripts
    -->
    <xsl:param name="language" select="'de-DE'"/>
    <xsl:param name="tmpdir" select="'tmp'"/>
    
    <xsl:param name="processDatasets" select="'false'"/>
    <xsl:param name="processDatasetsStartheadlevel" select="'1'"/>
    <xsl:param name="processScenarios" select="'false'"/>
    <xsl:param name="processScenariosStartheadlevel" select="'1'"/>
    <xsl:param name="processTerminologyAssociations" select="'false'"/>
    <xsl:param name="processTerminologyAssociationsStartheadlevel" select="'1'"/>
    <xsl:param name="processValueSets" select="'true'"/>
    <xsl:param name="processValueSetsStartheadlevel" select="'1'"/>
    <xsl:param name="processTemplates" select="'true'"/>
    <xsl:param name="processTemplatesStartheadlevel" select="'1'"/>
    <xsl:param name="processProfiles" select="'false'"/>
    <xsl:param name="processProfilesStartheadlevel" select="'1'"/>
    <xsl:param name="processCodeSystems" select="'true'"/>
    <xsl:param name="processCodeSystemsStartheadlevel" select="'1'"/>
    
    
    <!-- not used yet, only by DECORbasics -->
    <xsl:variable name="defaultLanguage" select="(//project/@defaultLanguage)[1]"/>
    <xsl:variable name="projectDefaultLanguage" select="(//project/@defaultLanguage)[1]"/>
    
    
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
    <xsl:param name="bindingBehaviorValueSets" select="'freeze'"/>
    <xsl:param name="bindingBehaviorValueSetsURL"/>
    <xsl:param name="hideColumns" select="false()"/>
    <xsl:param name="logLevel" select="'INFO'"/>
    <xsl:param name="theLogLevel" select="'INFO'"/>
    <!-- ADRAM deeplink prefix for issues etc -->
    <xsl:param name="artdecordeeplinkprefix" as="xs:string?">
        <xsl:choose>
            <xsl:when test="$allDECOR/@deeplinkprefix">
                <xsl:value-of select="$allDECOR/@deeplinkprefix"/>
            </xsl:when>
        </xsl:choose>
    </xsl:param>
    <!-- 
        if this xsl is invoked by ADRAM service the adram variable is set to the version
    -->
    <xsl:param name="adram" as="xs:string?" select="'confluence'"/>
    <xsl:param name="inputStaticBaseUri" select="static-base-uri()"/>
    <xsl:param name="inputBaseUri" select="base-uri()"/>
    <xsl:param name="theBaseURI2DECOR" select="string-join(tokenize($inputBaseUri, '/')[position() &lt; last()], '/')"/>
    
    <!-- die on circular references or not, values: 'continue' (default), 'die' -->
    <xsl:param name="onCircularReferences" select="'continue'"/>
    
    <xsl:param name="filtersfile" select="concat($theBaseURI2DECOR, '/', 'filters.xml')"/>
    <xsl:param name="filtersfileavailable" select="if (doc-available($filtersfile)) then exists(doc($filtersfile)/*[not(@filter = ('false', 'off'))][@label[not(. = '')]]) else false()" as="xs:boolean"/>
    
    <!-- see this URL in asserts and reports points to 'generated' HTML fields or to the 'live' environment.
        It also determines context for any other HTML link.
    -->
    <xsl:param name="seeThisUrlLocation" select="'generated'"/>
    
    <!-- Do HTML with treetree/treeblank indenting (default. or set to false()) or treetable.js compatible indenting -->
    <!--xsl:param name="switchCreateTreeTableHtml" select="'false'"/-->
    <xsl:param name="switchCreateTreeTableHtml" select="'false'"/>
       
       
    <!-- additional internal switches -->
    <xsl:param name="processHierarchicalGraphs" select="'false'"/>
    
    
    <xsl:include href="DECOR2html.xsl"/>
    <xsl:include href="DECOR-basics.xsl"/>
        
    <xsl:output method="xml" name="xml" indent="yes" version="1.0" encoding="UTF-8" exclude-result-prefixes="#all"/>
    <xsl:output method="text" name="text"/>
    <xsl:output method="html" name="html" indent="no" omit-xml-declaration="yes" version="4.01" encoding="UTF-8"  doctype-system="http://www.w3.org/TR/html4/strict.dtd"/>
    <xsl:output method="xhtml" name="xhtml" indent="no" omit-xml-declaration="yes" encoding="UTF-8" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>   

    <!-- store all value sets and templates of this projects for later reference -->
    <xsl:variable name="allvs" select="//valueSet"/>
    <xsl:variable name="alltmp" select="//template"/>
    <xsl:variable name="allcs" select="//codeSystem"/>
    
    <xsl:variable name="includerefs">
        <xsl:if test="doc-available(concat($theBaseURI2DECOR, '/includerefs.xml'))">
            <xsl:copy-of select="doc(concat($theBaseURI2DECOR, '/includerefs.xml'))"/>
        </xsl:if>
    </xsl:variable>
    <xsl:variable name="identOfGovernanceGroup" select="//identOfGovernanceGroup"/>
    
    <!-- only allow https:// schema for deep link prefix services -->
    <xsl:variable name="tmpservlinkcascade" select="(//decor/@deeplinkprefixservices)[1]"/>
    <xsl:variable name="deeplinkprefixservicescascaded">
        <xsl:choose>
            <xsl:when test="starts-with($tmpservlinkcascade, 'http://')">
                <!-- replace http with https -->
                <xsl:value-of select="concat('https://', substring-after($tmpservlink, 'http://'))"/>
            </xsl:when>
            <xsl:when test="starts-with($tmpservlinkcascade, 'https://')">
                <!-- link ok -->
                <xsl:value-of select="$tmpservlinkcascade"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- otherwise fail -->
                <xsl:value-of select="'DEEP-LINK-PREFIX-FAILURE'"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="not(ends-with($tmpservlinkcascade, '/'))">
            <xsl:value-of select="'/'"/>
        </xsl:if>
    </xsl:variable>
    
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
        
        <!-- write params to check file -->
        <xsl:result-document href="{$tmpdir}/params.xml" format="xml" method="xml">
            <parameters>
                <dataset process="{$processDatasets}" hlevel="{$processDatasetsStartheadlevel}"/>
                <sceanrio process="{$processScenarios}" hlevel="{$processScenariosStartheadlevel}"/>
                <terminologyAssociation process="{$processTerminologyAssociations}" hlevel="{$processTerminologyAssociationsStartheadlevel}"/>
                <valueSet process="{$processValueSets}" hlevel="{$processValueSetsStartheadlevel}"/>
                <template process="{$processTemplates}" hlevel="{$processTemplatesStartheadlevel}"/>
                <profile process="{$processProfiles}" hlevel="{$processProfilesStartheadlevel}"/>
            </parameters>
        </xsl:result-document>
        
        <!-- start the index file -->
        <xsl:result-document href="{$tmpdir}/index.xml" format="xml" method="xml">
            <index>
                <!-- 
                     phase 1: templates 
                     =====
                -->
                <xsl:if test="$processTemplates='true'">
                     <!-- 
                         phase Ia: templates static 
                         =====
                     -->
                     <xsl:for-each-group select="//template[(@id and not(@ident)) or (@id and local:identOfGovernanceGroup(@ident)) or local:matchesExplicitIncludes(@id)]" group-by="concat(@id,@effectiveDate)">
                         <xsl:variable name="tid" select="@id"/>
                        <xsl:variable name="statusCode" select="@statusCode"/>
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
                         <ix artefact="TM" fn="{$fns}" wiki="{$wikis}" type="html" id="{$tid}" statusCode="{$statusCode}">
                             <name>
                                 <xsl:copy-of select="$templatename"/>
                             </name>
                         </ix>
                         <!--
                             <xsl:result-document href="{concat($fns, '.xhtml')}" method="xhtml" indent="no" omit-xml-declaration="yes">
                                 <xsl:copy-of select="$t"/>
                             </xsl:result-document>
                             -->
                         <xsl:result-document href="{$fns}" method="xhtml" indent="no" omit-xml-declaration="yes">
                             <!--<xsl:copy-of select="$t"/>-->
                             <xsl:apply-templates select="$t" mode="simplify"/>
                             <xsl:text>&#10;</xsl:text>
                         </xsl:result-document>
                         <xsl:if test="string-length($xeffshort)>0">
                             <xsl:choose>
                                 <xsl:when test="$adram='mediawiki'">
                                     <xsl:variable name="fndx" select="concat($tmpdir, '/tmp-', $tid, '-', $ed, '-redirect.txt')"/>
                                     <ix artefact="TM" fn ="{$fndx}" wiki="{concat(@id, '/static-', $xeffshort)}" type="text" id="{$tid}" statusCode="{$statusCode}">
                                         <name>
                                             <xsl:copy-of select="$templatename"/>
                                         </name>
                                         <date>
                                             <xsl:value-of select="$xeffshort"/>
                                         </date>
                                     </ix>
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
                                 </xsl:when>
                                 <xsl:when test="$adram='confluence'">
                                     <xsl:variable name="fndx" select="concat($tmpdir, '/tmp-', $tid, '-', $ed, '-redirect.html')"/>
                                     <ix artefact="TM" fn ="{$fndx}" wiki="{concat(@id, '/static-', $xeffshort)}" type="html" id="{$tid}" statusCode="{$statusCode}">
                                         <name>
                                             <xsl:copy-of select="$templatename"/>
                                         </name>
                                         <date>
                                             <xsl:value-of select="$xeffshort"/>
                                         </date>
                                     </ix>
                                     <xsl:result-document href="{$fndx}" format="xhtml">
                                         <xsl:call-template name="doConfluenceIncludePageMacro">
                                             <xsl:with-param name="page" select="$wikis"/>
                                         </xsl:call-template>
                                     </xsl:result-document>
                                 </xsl:when>
                                 <xsl:when test="$adram='wordpress'">
                                     <xsl:variable name="fndx" select="concat($tmpdir, '/tmp-', $tid, '-', $ed, '-redirect.html')"/>
                                     <ix artefact="TM" fn ="{$fndx}" wiki="{concat(@id, '/static-', $xeffshort)}" type="html" id="{$tid}" statusCode="{$statusCode}">
                                         <name>
                                             <xsl:copy-of select="$templatename"/>
                                         </name>
                                         <date>
                                             <xsl:value-of select="$xeffshort"/>
                                         </date>
                                     </ix>
                                     <xsl:result-document href="{$fndx}" format="xhtml">
                                         <xsl:call-template name="doWordpressIncludePageMacro">
                                             <xsl:with-param name="page" select="$wikis"/>
                                         </xsl:call-template>
                                     </xsl:result-document>
                                 </xsl:when>
                             </xsl:choose>
                         </xsl:if>
                     </xsl:for-each-group>    
                     <!-- 
                         phase Ib: templates dynamic and summary
                         =====
                     -->
                     <xsl:for-each-group select="//template[(@id and not(@ident)) or (@id and local:identOfGovernanceGroup(@ident)) or local:matchesExplicitIncludes(@id)]" group-by="@id">
                         <!-- template dynamic -->
                         <xsl:variable name="tid" select="@id"/>
                         <xsl:variable name="statusCode" select="@statusCode"/>
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
                         <!-- most recent template version with status code any of draft active review pending -->
                         <xsl:variable name="maxstaticdate" select="max($alltmp[(@id=$tid)][@statusCode = ('draft', 'active', 'review', 'pending')]/xs:dateTime(@effectiveDate))"/>
                         <xsl:variable name="maxstatic" select="replace(string($maxstaticdate),':','')"/>
                         <xsl:variable name="wikid" select="concat(@id, '/dynamic')"/>
                         
                         <!-- create the result document "dynamic" which is a wiki redirect only -->
                         <xsl:choose>
                             <xsl:when test="$adram='mediawiki'">
                                 <xsl:variable name="fnd" select="concat($tmpdir, '/tmp-', $tid, '-dynamic.txt')"/>
                                 <!-- write info to index file with ix elements -->
                                 <ix artefact="TM" fn ="{$fnd}" wiki="{$wikid}" type="text" id="{@id}" statusCode="{$statusCode}">
                                     <name>
                                         <xsl:copy-of select="$templatename"/>
                                     </name>
                                     <date>
                                         <xsl:text>dynamic (</xsl:text>
                                         <xsl:value-of select="$maxstatic"/>
                                         <xsl:text>)</xsl:text>
                                     </date>
                                 </ix>
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
                             </xsl:when>
                             <xsl:when test="$adram='confluence'">
                                 <xsl:variable name="fnd" select="concat($tmpdir, '/tmp-', $tid, '-dynamic.html')"/>
                                 <!-- write info to index file with ix elements -->
                                 <ix artefact="TM" fn ="{$fnd}" wiki="{$wikid}" type="html" id="{@id}" statusCode="{$statusCode}">
                                     <name>
                                         <xsl:copy-of select="$templatename"/>
                                     </name>
                                     <date>
                                         <xsl:text>dynamic (</xsl:text>
                                         <xsl:value-of select="$maxstatic"/>
                                         <xsl:text>)</xsl:text>
                                     </date>
                                 </ix>
                                 <xsl:result-document href="{$fnd}" format="xhtml">
                                     <xsl:choose>
                                         <xsl:when test="string-length($maxstatic)>0">
                                             <div>
                                                 <xsl:call-template name="doConfluenceIncludePageMacro">
                                                     <xsl:with-param name="page" select="concat(@id, '/static-', $maxstatic)"/>
                                                 </xsl:call-template>
                                             </div>
                                         </xsl:when>
                                         <xsl:otherwise>
                                             <div>
                                                 <xsl:call-template name="getMessage">
                                                     <xsl:with-param name="key" select="'wikilistnoactualversions'"/>
                                                 </xsl:call-template>
                                             </div>
                                         </xsl:otherwise>
                                     </xsl:choose>
                                 </xsl:result-document>
                             </xsl:when>
                             <xsl:when test="$adram='wordpress'">
                                 <xsl:variable name="fnd" select="concat($tmpdir, '/tmp-', $tid, '-dynamic.html')"/>
                                 <!-- write info to index file with ix elements -->
                                 <ix artefact="TM" fn ="{$fnd}" wiki="{$wikid}" type="html" id="{@id}" statusCode="{$statusCode}">
                                     <name>
                                         <xsl:copy-of select="$templatename"/>
                                     </name>
                                     <date>
                                         <xsl:text>dynamic (</xsl:text>
                                         <xsl:value-of select="$maxstatic"/>
                                         <xsl:text>)</xsl:text>
                                     </date>
                                 </ix>
                                 <xsl:result-document href="{$fnd}" format="xhtml">
                                     <xsl:choose>
                                         <xsl:when test="string-length($maxstatic)>0">
                                             <p>
                                                 <xsl:call-template name="doWordpressIncludePageMacro">
                                                     <xsl:with-param name="page" select="concat(@id, '/static-', $maxstatic)"/>
                                                 </xsl:call-template>
                                             </p>
                                         </xsl:when>
                                         <xsl:otherwise>
                                             <p>
                                                 <xsl:call-template name="getMessage">
                                                     <xsl:with-param name="key" select="'wikilistnoactualversions'"/>
                                                 </xsl:call-template>
                                             </p>
                                         </xsl:otherwise>
                                     </xsl:choose>
                                 </xsl:result-document>
                             </xsl:when>
                         </xsl:choose>
                         
                         <!-- create the result document "summary" -->
                         <xsl:variable name="wikir" select="@id"/>
                         <!-- write info to index file -->
                         <xsl:choose>
                             <xsl:when test="$adram='mediawiki'">
                                 <xsl:variable name="fnr" select="concat($tmpdir, '/tmp-', $tid, '-summary.txt')"/>
                                 <ix artefact="TM" fn ="{$fnr}" wiki="{$wikir}" type="text" id="{@id}" statusCode="{$statusCode}">
                                     <summary>
                                         <xsl:copy-of select="$templatename"/>
                                     </summary>
                                 </ix>
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
                                         <!--<xsl:text>==</xsl:text>
                                         <xsl:call-template name="getMessage">
                                             <xsl:with-param name="key" select="'wikidescription'"/>
                                         </xsl:call-template>
                                         <xsl:text>==</xsl:text>-->
                                         <xsl:text>&#10;</xsl:text>
                                         <xsl:text>&lt;p></xsl:text>
                                         <xsl:copy-of select="desc[@language=$language]"/>
                                         <xsl:text>&lt;/p></xsl:text>
                                         <xsl:text>&#10;</xsl:text>
                                     </xsl:if>
                                     <xsl:text>==</xsl:text>
                                     <xsl:call-template name="getMessage">
                                         <xsl:with-param name="key" select="'wikiactualversion'"/>
                                     </xsl:call-template>
                                     <xsl:text>==</xsl:text>
                                     <xsl:text>&#10;</xsl:text>
                                     <xsl:text>{{:{{BASEPAGENAME}}/dynamic}}</xsl:text>
                                     <xsl:text>&#10;</xsl:text>
                                     <xsl:text>&#10;</xsl:text>
                                     <xsl:text>==</xsl:text>
                                     <xsl:call-template name="getMessage">
                                         <xsl:with-param name="key" select="'wikilisttemplateversions'"/>
                                     </xsl:call-template>
                                     <xsl:text>==</xsl:text>
                                     <xsl:text>&#10;</xsl:text>
                                     <xsl:choose>
                                         <xsl:when test="count($alltmp[(@id=$tid and not(@ident)) or (@id=$tid and local:matchesExplicitIncludes(@id))]) &lt;= 0">
                                             <xsl:text>(bisher keine weiteren Angaben)</xsl:text>
                                         </xsl:when>
                                         <xsl:otherwise>
                                             <xsl:for-each-group select="$alltmp[(@id=$tid and not(@ident)) or (@id=$tid and local:matchesExplicitIncludes(@id))]" group-by="concat(@id, @effectiveDate)">
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
                                                 <xsl:text>*</xsl:text>
                                                 <xsl:call-template name="doLinkItem">
                                                     <xsl:with-param name="page">
                                                         <xsl:value-of select="@id"/>
                                                         <xsl:text>/static-</xsl:text>
                                                         <xsl:value-of select="replace(@effectiveDate,':','')"/>
                                                     </xsl:with-param>
                                                     <xsl:with-param name="label">
                                                         <xsl:value-of select="$edd"/>
                                                         <xsl:text> (</xsl:text>
                                                         <xsl:call-template name="getMessage">
                                                             <xsl:with-param name="key" select="concat('TemplateStatusCodeLifeCycle-',@statusCode)"/>
                                                         </xsl:call-template>
                                                         <xsl:text>)</xsl:text>
                                                     </xsl:with-param>
                                                 </xsl:call-template>
                                                 <xsl:text>&#10;</xsl:text>
                                             </xsl:for-each-group>
                                         </xsl:otherwise>
                                     </xsl:choose>
                                 </xsl:result-document>
                             </xsl:when>
                             <xsl:when test="$adram='confluence'">
                                 <xsl:variable name="fnr" select="concat($tmpdir, '/tmp-', $tid, '-summary.html')"/>
                                 <ix artefact="TM" fn ="{$fnr}" wiki="{$wikir}" type="html" id="{@id}" statusCode="{$statusCode}">
                                     <summary>
                                         <xsl:copy-of select="$templatename"/>
                                     </summary>
                                 </ix>
                                 <xsl:result-document href="{$fnr}" format="xhtml">
                                     <div>
                                         <h1>
                                             <xsl:text>Template </xsl:text>
                                             <xsl:value-of select="@name"/>
                                         </h1>
                                         <xsl:if test="desc[@language=$language]">
                                             <!--<h2>
                                                 <xsl:call-template name="getMessage">
                                                     <xsl:with-param name="key" select="'wikidescription'"/>
                                                 </xsl:call-template>
                                             </h2>-->
                                             <p>
                                                 <xsl:copy-of select="desc[@language=$language]"/>
                                             </p>
                                         </xsl:if>
                                         <h2>
                                             <xsl:call-template name="getMessage">
                                                 <xsl:with-param name="key" select="'wikiactualversion'"/>
                                             </xsl:call-template>
                                         </h2>
                                         <p>
                                             <xsl:call-template name="doConfluenceIncludePageMacro">
                                                 <xsl:with-param name="page" select="concat($wikir, '/dynamic')"/>
                                             </xsl:call-template>
                                         </p>
                                         <h2>
                                             <xsl:call-template name="getMessage">
                                                 <xsl:with-param name="key" select="'wikilisttemplateversions'"/>
                                             </xsl:call-template>
                                         </h2>
                                         <xsl:choose>
                                             <xsl:when test="count($alltmp[(@id=$tid and not(@ident)) or (@id=$tid and local:matchesExplicitIncludes(@id))]) &lt;= 0">
                                                 <xsl:text>(bisher keine weiteren Angaben)</xsl:text>
                                             </xsl:when>
                                             <xsl:otherwise>
                                                 <xsl:for-each-group select="$alltmp[(@id=$tid and not(@ident)) or (@id=$tid and local:matchesExplicitIncludes(@id))]" group-by="concat(@id, @effectiveDate)">
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
                                                     <xsl:variable name="tt">
                                                         <xsl:value-of select="@id"/>
                                                         <xsl:text>/static-</xsl:text>
                                                         <xsl:value-of select="replace(@effectiveDate,':','')"/>
                                                     </xsl:variable>
                                                     <xsl:variable name="cdt">
                                                         <xsl:text>&lt;![CDATA[</xsl:text>
                                                         <xsl:value-of select="$edd"/>
                                                         <xsl:text>]]&gt;</xsl:text>
                                                     </xsl:variable>
                                                     <ul>
                                                         <li>  
                                                             <xsl:call-template name="doLinkItem">
                                                                 <xsl:with-param name="page" select="$tt"/>
                                                                 <xsl:with-param name="label" select="$edd"/>
                                                             </xsl:call-template>
                                                             <xsl:text> (</xsl:text>
                                                             <xsl:call-template name="getMessage">
                                                                 <xsl:with-param name="key" select="concat('TemplateStatusCodeLifeCycle-',@statusCode)"/>
                                                             </xsl:call-template>
                                                             <xsl:text>)</xsl:text>
                                                         </li>
                                                     </ul>
                                                 </xsl:for-each-group>
                                             </xsl:otherwise>
                                         </xsl:choose>
                                     </div>
                                 </xsl:result-document>
                             </xsl:when>
                             <xsl:when test="$adram='wordpress'">
                                 <xsl:variable name="fnr" select="concat($tmpdir, '/tmp-', $tid, '-summary.html')"/>
                                 <ix artefact="TM" fn ="{$fnr}" wiki="{$wikir}" type="html" id="{@id}" statusCode="{$statusCode}">
                                     <summary>
                                         <xsl:copy-of select="$templatename"/>
                                     </summary>
                                 </ix>
                                 <xsl:result-document href="{$fnr}" format="xhtml">
                                     <p>
                                         <h1>
                                             <xsl:text>Template </xsl:text>
                                             <xsl:value-of select="@name"/>
                                         </h1>
                                         <xsl:if test="desc[@language=$language]">
                                             <p>
                                                 <xsl:copy-of select="desc[@language=$language]"/>
                                             </p>
                                         </xsl:if>
                                         <h2>
                                             <xsl:call-template name="getMessage">
                                                 <xsl:with-param name="key" select="'wikiactualversion'"/>
                                             </xsl:call-template>
                                         </h2>
                                         <p>
                                             <xsl:call-template name="doWordpressIncludePageMacro">
                                                 <xsl:with-param name="page" select="concat($wikir, '/dynamic')"/>
                                             </xsl:call-template>
                                         </p>
                                         <h2>
                                             <xsl:call-template name="getMessage">
                                                 <xsl:with-param name="key" select="'wikilisttemplateversions'"/>
                                             </xsl:call-template>
                                         </h2>
                                         <xsl:choose>
                                             <xsl:when test="count($alltmp[(@id=$tid and not(@ident)) or (@id=$tid and local:matchesExplicitIncludes(@id))]) &lt;= 0">
                                                 <xsl:text>(bisher keine weiteren Angaben)</xsl:text>
                                             </xsl:when>
                                             <xsl:otherwise>
                                                 <xsl:for-each-group select="$alltmp[(@id=$tid and not(@ident)) or (@id=$tid and local:matchesExplicitIncludes(@id))]" group-by="concat(@id, @effectiveDate)">
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
                                                     <xsl:variable name="tt">
                                                         <xsl:value-of select="@id"/>
                                                         <xsl:text>/static-</xsl:text>
                                                         <xsl:value-of select="replace(@effectiveDate,':','')"/>
                                                     </xsl:variable>
                                                     <xsl:variable name="cdt">
                                                         <xsl:text>&lt;![CDATA[</xsl:text>
                                                         <xsl:value-of select="$edd"/>
                                                         <xsl:text>]]&gt;</xsl:text>
                                                     </xsl:variable>
                                                     <ul>
                                                         <li>  
                                                             <xsl:call-template name="doLinkItem">
                                                                 <xsl:with-param name="page" select="$tt"/>
                                                                 <xsl:with-param name="label" select="$edd"/>
                                                             </xsl:call-template>
                                                             <xsl:text> (</xsl:text>
                                                             <xsl:call-template name="getMessage">
                                                                 <xsl:with-param name="key" select="concat('TemplateStatusCodeLifeCycle-',@statusCode)"/>
                                                             </xsl:call-template>
                                                             <xsl:text>)</xsl:text>
                                                         </li>
                                                     </ul>
                                                 </xsl:for-each-group>
                                             </xsl:otherwise>
                                         </xsl:choose>
                                     </p>
                                 </xsl:result-document>
                             </xsl:when>
                         </xsl:choose>
                         
                         <!-- create the hiergraph files for templates -->
                         <xsl:if test="$processHierarchicalGraphs='true'">
                             <xsl:variable name="fnh" select="concat($tmpdir, '/tmp-', $tid, '-hgraph.html')"/>
                             <xsl:variable name="wikihg" select="concat(@id, '/hgraph')"/>
                             <xsl:variable name="theHgraph">
                                 <xsl:copy-of select="doc(concat($deeplinkprefixservicescascaded, 'RetrieveTemplateDiagram?project=', @referencedFrom, '&amp;id=',
                                     $tid, '&amp;effectiveDate=', $maxstaticdate, '&amp;language=', $language, '&amp;format=hgraph'))"/>
                             </xsl:variable>
                             <xsl:variable name="hct">
                                 <xsl:choose>
                                     <xsl:when test="count($theHgraph)>0">
                                         <xsl:copy-of select="$theHgraph"/>
                                     </xsl:when>
                                     <xsl:otherwise>
                                         <xsl:message>WARN : +++ RetrieveTemplateDiagram failed for project <xsl:value-of select="@referencedFrom"/>: Template id <xsl:value-of select="$tid"/> effectiveDate: <xsl:value-of select="$maxstaticdate"/>
                                         </xsl:message>
                                     </xsl:otherwise>
                                 </xsl:choose>
                             </xsl:variable>
                             <xsl:if test="count($hct//body/table)>0">
                                 <ix artefact="TM" fn ="{$fnh}" wiki="{$wikihg}" type="html" id="{@id}" statusCode="{$statusCode}">
                                     <hgraph>
                                         <xsl:copy-of select="$templatename"/>
                                     </hgraph>
                                 </ix>
                                 <xsl:result-document href="{$fnh}" method="xhtml" indent="no" omit-xml-declaration="yes">
                                     <xsl:copy-of select="$hct//body/table"/>
                                     <xsl:text>&#10;</xsl:text>
                                 </xsl:result-document>
                             </xsl:if>
                         </xsl:if>
                     </xsl:for-each-group>
                 </xsl:if>
           
                <!-- 
                     phase 2: value sets 
                     =====
                -->
                <xsl:if test="$processValueSets='true'">
                    <!--
                            per value set with id and effective date
                            - create one rendering per effective date (version) with that id, e.g. 2.16.840.1.113883.1.11.1/static-2012-07-24
                            - create one redirect as the dynamic rendering, i.e. 2.16.840.1.113883.1.11.1/dynamic
                            - create one summary 2.16.840.1.113883.1.11.1
                            - create one redirect to the summary page named as the name of the value set
                        -->
                    
                    <!-- 
                        phase IIa: value set static; cave duplicate id+effectiveDate combinations due to multiple repository references
                        =====
                    -->
                    <xsl:for-each-group select="//terminology/valueSet[(@id and not(@ident)) or (@id and local:identOfGovernanceGroup(@ident)) or local:matchesExplicitIncludes(@id)]" group-by="concat(@id, @effectiveDate)">
                        <xsl:variable name="vid" select="@id"/>
                        <xsl:variable name="statusCode" select="@statusCode"/>
                        <xsl:variable name="valuesetname">
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
                        <xsl:if test="string-length($vid)>0">
                            <!-- create a time stamp based on effectiveDate as YYYY-MM-DDThhmmss (without the :) and an alternative shortcut timepstamp YYYY-MM-DD if time is T00:00:00 -->
                            <xsl:variable name="ed" select="replace(@effectiveDate,':','')"/>
                            <xsl:variable name="xeffshort">
                                <xsl:choose>
                                    <xsl:when test="string-length(substring-before(@effectiveDate, 'T00:00:00'))>0">
                                        <xsl:value-of select="substring-before(@effectiveDate, 'T00:00:00')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="replace(@effectiveDate, 'T', ' ')"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:variable name="fns" select="concat($tmpdir, '/vs-', @id, '-', $ed, '.html')"/>
                            <xsl:variable name="wikis" select="concat(@id, '/static-', replace(@effectiveDate,':',''))"/>
                            <!-- write info to index file -->
                            <ix artefact="VS" fn ="{$fns}" wiki="{$wikis}" type="html" cat="vs" id="{@id}" effectiveDate="{@effectiveDate}" statusCode="{$statusCode}">
                                <name>
                                    <xsl:copy-of select="$valuesetname"/>
                                </name>
                                <date>
                                    <xsl:value-of select="$xeffshort"/>
                                </date>
                            </ix>
                            <xsl:variable name="t">
                                <xsl:apply-templates select=".">
                                    <xsl:with-param name="showOtherVersionsList" select="false()"/>
                                </xsl:apply-templates>
                            </xsl:variable>
                            <xsl:result-document href="{$fns}" format="xhtml" indent="no" omit-xml-declaration="yes">
                                <xsl:apply-templates select="$t" mode="simplify"/>
                                <xsl:text>&#10;</xsl:text>
                            </xsl:result-document>
                            <xsl:choose>
                                <xsl:when test="$adram='mediawiki'">
                                    <xsl:if test="string-length($xeffshort)>0">
                                        <xsl:variable name="fndx" select="concat($tmpdir, '/vs-', @id, '-', $ed, '-redirect.txt')"/>
                                        <!-- write info to index file -->
                                        <ix artefact="VS" fn ="{$fndx}" wiki="{concat(@id, '/static-', $xeffshort)}" type="text" id="{@id}" statusCode="{$statusCode}">
                                            <name>
                                                <xsl:copy-of select="$valuesetname"/>
                                            </name>
                                        </ix>
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
                                </xsl:when>
                                <xsl:when test="$adram='confluence'">
                                    <xsl:if test="string-length($xeffshort)>0">
                                        <xsl:variable name="fndx" select="concat($tmpdir, '/vs-', @id, '-', $ed, '-redirect.html')"/>
                                        <!-- write info to index file with ix elements -->
                                        <ix artefact="VS" fn ="{$fndx}"  wiki="{concat(@id, '/static-', $xeffshort)}" type="html" id="{@id}">
                                            <name>
                                                <xsl:copy-of select="$valuesetname"/>
                                            </name>
                                        </ix>
                                        <xsl:result-document href="{$fndx}" format="xhtml">
                                            <xsl:call-template name="doConfluenceIncludePageMacro">
                                                <xsl:with-param name="page" select="$wikis"/>
                                            </xsl:call-template>
                                        </xsl:result-document>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="$adram='wordpress'">
                                    <xsl:if test="string-length($xeffshort)>0">
                                        <xsl:variable name="fndx" select="concat($tmpdir, '/vs-', @id, '-', $ed, '-redirect.html')"/>
                                        <!-- write info to index file with ix elements -->
                                        <ix artefact="VS" fn ="{$fndx}"  wiki="{concat(@id, '/static-', $xeffshort)}" type="html" id="{@id}" statusCode="{$statusCode}">
                                            <name>
                                                <xsl:copy-of select="$valuesetname"/>
                                            </name>
                                        </ix>
                                        <xsl:result-document href="{$fndx}" format="xhtml">
                                            <xsl:call-template name="doWordpressIncludePageMacro">
                                                <xsl:with-param name="page" select="$wikis"/>
                                            </xsl:call-template>
                                        </xsl:result-document>
                                    </xsl:if>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:if>
                    </xsl:for-each-group>             
                    <!-- 
                        phase IIb: value set dynamic and summary
                        =====
                    -->
                    <xsl:for-each-group select="//terminology/valueSet[(@id and not(@ident)) or (@id and local:identOfGovernanceGroup(@ident)) or local:matchesExplicitIncludes(@id)]" group-by="@id">
                        <!-- dynamic -->
                        <xsl:variable name="vid" select="@id"/>
                        <xsl:variable name="statusCode" select="@statusCode"/>
                        <xsl:variable name="valuesetname">
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
                        <xsl:if test="string-length($vid)>0">
                            <!-- most recent value set version with status code any of new draft final review pending -->
                            <xsl:variable name="maxstaticdate" select="max($allvs[(@id=$vid) and @statusCode = ('new', 'draft', 'final', 'review', 'pending')]/xs:dateTime(@effectiveDate))"/>
                            <xsl:variable name="maxstatic" select="replace(string($maxstaticdate),':','')"/>
                            <xsl:variable name="wikid" select="concat(@id, '/dynamic')"/>
                            <!-- create the result document "dynamic" which is a wiki redirect only -->
                            <xsl:choose>
                                <xsl:when test="$adram='mediawiki'">
                                    <xsl:variable name="fnd" select="concat($tmpdir, '/vs-', $vid, '-dynamic.txt')"/>
                                    <!-- write info to index file -->
                                    <ix artefact="VS" fn ="{$fnd}" wiki="{$wikid}" type="text" id="{@id}" statusCode="{$statusCode}">
                                        <name>
                                            <xsl:copy-of select="$valuesetname"/>
                                        </name>
                                        <date>
                                            <xsl:text>dynamic (</xsl:text>
                                            <xsl:value-of select="$maxstatic"/>
                                            <xsl:text>)</xsl:text>
                                        </date>
                                    </ix>
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
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'wikilistnoactualversions'"/>
                                                </xsl:call-template>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:result-document>
                                </xsl:when>
                                <xsl:when test="$adram='confluence'">
                                    <xsl:variable name="fnd" select="concat($tmpdir, '/vs-', $vid, '-dynamic.html')"/>
                                    <!-- write info to index file with ix elements -->
                                    <ix artefact="VS" fn ="{$fnd}" wiki="{$wikid}" type="html" id="{@id}" statusCode="{$statusCode}">
                                        <name>
                                            <xsl:copy-of select="$valuesetname"/>
                                        </name>
                                        <date>
                                            <xsl:text>dynamic (</xsl:text>
                                            <xsl:value-of select="$maxstatic"/>
                                            <xsl:text>)</xsl:text>
                                        </date>
                                    </ix>
                                    <xsl:result-document href="{$fnd}" format="xhtml">
                                        <xsl:choose>
                                            <xsl:when test="string-length($maxstatic)>0">
                                                <div>
                                                    <xsl:call-template name="doConfluenceIncludePageMacro">
                                                        <xsl:with-param name="page" select="concat(@id, '/static-', $maxstatic)"/>
                                                    </xsl:call-template>
                                                </div>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <div>
                                                    <xsl:call-template name="getMessage">
                                                        <xsl:with-param name="key" select="'wikilistnoactualversions'"/>
                                                    </xsl:call-template>
                                                </div>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:result-document>
                                </xsl:when>
                                <xsl:when test="$adram='wordpress'">
                                    <xsl:variable name="fnd" select="concat($tmpdir, '/vs-', $vid, '-dynamic.html')"/>
                                    <!-- write info to index file with ix elements -->
                                    <ix artefact="VS" fn ="{$fnd}" wiki="{$wikid}" type="html" id="{@id}" statusCode="{$statusCode}">
                                        <name>
                                            <xsl:copy-of select="$valuesetname"/>
                                        </name>
                                        <date>
                                            <xsl:text>dynamic (</xsl:text>
                                            <xsl:value-of select="$maxstatic"/>
                                            <xsl:text>)</xsl:text>
                                        </date>
                                    </ix>
                                    <xsl:result-document href="{$fnd}" format="xhtml">
                                        <xsl:choose>
                                            <xsl:when test="string-length($maxstatic)>0">
                                                <div>
                                                    <xsl:call-template name="doWordpressIncludePageMacro">
                                                        <xsl:with-param name="page" select="concat(@id, '/static-', $maxstatic)"/>
                                                    </xsl:call-template>
                                                </div>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <div>
                                                    <xsl:call-template name="getMessage">
                                                        <xsl:with-param name="key" select="'wikilistnoactualversions'"/>
                                                    </xsl:call-template>
                                                </div>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:result-document>
                                </xsl:when>
                            </xsl:choose>
                            
                            <!-- create the result document "summary" -->
                            <xsl:choose>
                                <xsl:when test="$adram='mediawiki'">
                                    <xsl:variable name="fnr" select="concat($tmpdir, '/vs-', $vid, '-summary.txt')"/>
                                    <xsl:variable name="wikir" select="@id"/>
                                    <ix artefact="VS" fn ="{$fnr}" wiki="{$wikir}" type="text" id="{@id}" statusCode="{$statusCode}">
                                        <summary>
                                            <xsl:copy-of select="$valuesetname"/>
                                        </summary>
                                    </ix>
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
                                            <!--<xsl:text>==</xsl:text>
                                            <xsl:call-template name="getMessage">
                                                <xsl:with-param name="key" select="'wikidescription'"/>
                                            </xsl:call-template>
                                            <xsl:text>==</xsl:text>
                                            <xsl:text>&#10;</xsl:text>-->
                                            <xsl:text>&lt;p></xsl:text>
                                            <xsl:copy-of select="desc[@language=$language]"/>
                                            <xsl:text>&lt;/p></xsl:text>
                                            <xsl:text>&#10;</xsl:text>
                                        </xsl:if>
                                        <xsl:text>==</xsl:text>
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="'wikiactualversion'"/>
                                        </xsl:call-template>
                                        <xsl:text>==</xsl:text>
                                        <xsl:text>&#10;</xsl:text>
                                        <xsl:text>{{:{{BASEPAGENAME}}/dynamic}}</xsl:text>
                                        <xsl:text>&#10;</xsl:text>
                                        <xsl:text>&#10;</xsl:text>
                                        <xsl:text>==</xsl:text>
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="'wikilistvaluesetversions'"/>
                                        </xsl:call-template>
                                        <xsl:text>==</xsl:text>
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
                                                    <xsl:text>* </xsl:text>
                                                    <xsl:call-template name="doLinkItem">
                                                        <xsl:with-param name="page">
                                                            <xsl:value-of select="@id"/>
                                                            <xsl:text>/static-</xsl:text>
                                                            <xsl:value-of select="replace(@effectiveDate,':','')"/>
                                                        </xsl:with-param>
                                                        <xsl:with-param name="label">
                                                            <xsl:value-of select="$edd"/>
                                                            <xsl:text> (</xsl:text>
                                                            <xsl:call-template name="getMessage">
                                                                <xsl:with-param name="key" select="concat('ItemStatusCodeLifeCycle-', @statusCode)"/>
                                                            </xsl:call-template>
                                                            <xsl:text>)</xsl:text>
                                                        </xsl:with-param>
                                                    </xsl:call-template>
                                                    <xsl:text>&#10;</xsl:text>
                                                </xsl:for-each-group>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:result-document>
                                </xsl:when>
                                <xsl:when test="$adram='confluence'">
                                    <xsl:variable name="fnr" select="concat($tmpdir, '/vs-', $vid, '-summary.html')"/>
                                    <xsl:variable name="wikir" select="@id"/>
                                    <ix artefact="VS" fn ="{$fnr}" wiki="{$wikir}" type="html" id="{@id}" statusCode="{$statusCode}">
                                        <summary>
                                            <xsl:copy-of select="$valuesetname"/>
                                        </summary>
                                    </ix>
                                    <xsl:result-document href="{$fnr}" format="xhtml">
                                        <div>
                                            <h1>
                                                <xsl:text>Value Set </xsl:text>
                                                <xsl:value-of select="@name"/>
                                            </h1>
                                            <xsl:if test="desc[@language=$language]">
                                                <!--<h2>
                                                    <xsl:call-template name="getMessage">
                                                        <xsl:with-param name="key" select="'wikidescription'"/>
                                                    </xsl:call-template>
                                                </h2>-->
                                                <p>
                                                    <xsl:copy-of select="desc[@language=$language]"/>
                                                </p>
                                            </xsl:if>
                                            <h2>
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'wikiactualversion'"/>
                                                </xsl:call-template>
                                            </h2>
                                            <p>
                                                <xsl:call-template name="doConfluenceIncludePageMacro">
                                                    <xsl:with-param name="page" select="concat($wikir, '/dynamic')"/>
                                                </xsl:call-template>
                                            </p>
                                            <h2>
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'wikilistvaluesetversions'"/>
                                                </xsl:call-template>
                                            </h2>
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
                                                        <xsl:variable name="tt">
                                                            <xsl:value-of select="@id"/>
                                                            <xsl:text>/static-</xsl:text>
                                                            <xsl:value-of select="replace(@effectiveDate,':','')"/>
                                                        </xsl:variable>
                                                        <xsl:variable name="cdt">
                                                            <xsl:text>&lt;![CDATA[</xsl:text>
                                                            <xsl:value-of select="$edd"/>
                                                            <xsl:text>]]&gt;</xsl:text>
                                                        </xsl:variable>
                                                        <ul>
                                                            <li>  
                                                                <xsl:call-template name="doLinkItem">
                                                                    <xsl:with-param name="page" select="$tt"/>
                                                                    <xsl:with-param name="label" select="$edd"/>
                                                                </xsl:call-template>
                                                                <xsl:text> (</xsl:text>
                                                                <xsl:call-template name="getMessage">
                                                                    <xsl:with-param name="key" select="concat('ItemStatusCodeLifeCycle-', @statusCode)"/>
                                                                </xsl:call-template>
                                                                <xsl:text>)</xsl:text>
                                                            </li>
                                                        </ul>
                                                    </xsl:for-each-group>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </div>
                                    </xsl:result-document>
                                </xsl:when>
                                <xsl:when test="$adram='wordpress'">
                                    <xsl:variable name="fnr" select="concat($tmpdir, '/vs-', $vid, '-summary.html')"/>
                                    <xsl:variable name="wikir" select="@id"/>
                                    <ix artefact="VS" fn ="{$fnr}" wiki="{$wikir}" type="html" id="{@id}" statusCode="{$statusCode}">
                                        <summary>
                                            <xsl:copy-of select="$valuesetname"/>
                                        </summary>
                                    </ix>
                                    <xsl:result-document href="{$fnr}" format="xhtml">
                                        <p>
                                            <h1>
                                                <xsl:text>Value Set </xsl:text>
                                                <xsl:value-of select="@name"/>
                                            </h1>
                                            <xsl:if test="desc[@language=$language]">
                                                <p>
                                                    <xsl:copy-of select="desc[@language=$language]"/>
                                                </p>
                                            </xsl:if>
                                            <h2>
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'wikiactualversion'"/>
                                                </xsl:call-template>
                                            </h2>
                                            <p>
                                                <xsl:call-template name="doWordpressIncludePageMacro">
                                                    <xsl:with-param name="page" select="concat($wikir, '/dynamic')"/>
                                                </xsl:call-template>
                                            </p>
                                            <h2>
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'wikilistvaluesetversions'"/>
                                                </xsl:call-template>
                                            </h2>
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
                                                        <xsl:variable name="tt">
                                                            <xsl:value-of select="@id"/>
                                                            <xsl:text>/static-</xsl:text>
                                                            <xsl:value-of select="replace(@effectiveDate,':','')"/>
                                                        </xsl:variable>
                                                        <xsl:variable name="cdt">
                                                            <xsl:text>&lt;![CDATA[</xsl:text>
                                                            <xsl:value-of select="$edd"/>
                                                            <xsl:text>]]&gt;</xsl:text>
                                                        </xsl:variable>
                                                        <ul>
                                                            <li>  
                                                                <xsl:call-template name="doLinkItem">
                                                                    <xsl:with-param name="page" select="$tt"/>
                                                                    <xsl:with-param name="label" select="$edd"/>
                                                                </xsl:call-template>
                                                                <xsl:text> (</xsl:text>
                                                                <xsl:call-template name="getMessage">
                                                                    <xsl:with-param name="key" select="concat('ItemStatusCodeLifeCycle-', @statusCode)"/>
                                                                </xsl:call-template>
                                                                <xsl:text>)</xsl:text>
                                                            </li>
                                                        </ul>
                                                    </xsl:for-each-group>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </p>
                                    </xsl:result-document>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:if>
                    </xsl:for-each-group>
                </xsl:if>
                <!-- 
                     phase 3: scenarios/transactions 
                     =====
                -->
                <xsl:if test="$processScenarios='true'">
                    <!-- go through all unique transactions and create the index page -->
                    <xsl:for-each-group select="//scenario//transaction" group-by="@id">
                        <xsl:variable name="tid" select="@id"/>
                        <xsl:variable name="statusCode" select="@statusCode"/>
                        <xsl:variable name="tname" select="name[@language=$language]"/>
                        <xsl:variable name="ttype">
                            <xsl:choose>
                                <xsl:when test="@type='group'">
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'Group'"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:when test="@type='initial'">
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'transactionDirectioninitial'"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:when test="@type='back'">
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'transactionDirectionback'"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:when test="@type='stationary'">
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'transactionDirectionstationary'"/>
                                    </xsl:call-template>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="$adram='mediawiki'">
                                <xsl:variable name="fnixtxt" select="concat($tmpdir, '/tr-', $tid, '.txt')"/>
                                <ix artefact="TR" fn ="{$fnixtxt}" wiki="{$tid}" type="text" id="{$tid}" statusCode="{$statusCode}">
                                    <name>
                                        <xsl:value-of select="$tname"/>
                                        <xsl:value-of select="concat(' (', $ttype, ')')"/>
                                    </name>
                                </ix>
                                <xsl:result-document href="{$fnixtxt}" method="text" indent="no" omit-xml-declaration="yes">
                                    <xsl:text>__NOTOC__</xsl:text>
                                    <xsl:call-template name="nomanualeditstext"/>
                                    <xsl:text>&#10;</xsl:text>
                                    <xsl:text>[[Category:Transaction]]</xsl:text>
                                    <xsl:text>&#10;</xsl:text>
                                    <xsl:text>=</xsl:text>
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'Transaction'"/>
                                    </xsl:call-template>
                                    <xsl:text>'' </xsl:text>
                                    <xsl:value-of select="$tname"/>
                                    <xsl:text>'' (</xsl:text>
                                    <xsl:value-of select="$ttype"/>                            
                                    <xsl:text>)=</xsl:text>
                                    <xsl:text>&#10;</xsl:text>
                                    <xsl:if test="desc[@language=$language]">
                                        <!--
                                        <xsl:text>==</xsl:text>
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="'wikidescription'"/>
                                        </xsl:call-template>
                                        <xsl:text>==</xsl:text>
                                        <xsl:text>&#10;</xsl:text>
                                        -->
                                        <xsl:text>&lt;p></xsl:text>
                                        <xsl:copy-of select="desc[@language=$language]"/>
                                        <xsl:text>&lt;/p></xsl:text>
                                        <xsl:text>&#10;</xsl:text>
                                    </xsl:if>
                                    <xsl:text>&#10;</xsl:text>
                                    <xsl:text>==</xsl:text>
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'wikilisttransactionversions'"/>
                                    </xsl:call-template>
                                    <xsl:text>==</xsl:text>
                                    <xsl:text>&#10;</xsl:text>
                                    <xsl:for-each select="//scenario//transaction[@id=$tid]">
                                        <xsl:variable name="edd" select="@effectiveDate"/>
                                        <xsl:text>* </xsl:text>
                                        <xsl:call-template name="doLinkItem">
                                            <xsl:with-param name="page">
                                                <xsl:value-of select="$tid"/>
                                                <xsl:text>/static-</xsl:text>
                                                <xsl:value-of select="replace(@effectiveDate,':','')"/>
                                            </xsl:with-param>
                                            <xsl:with-param name="label">
                                                <xsl:value-of select="$edd"/>
                                                <xsl:text> (</xsl:text>
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="concat('ItemStatusCodeLifeCycle-',@statusCode)"/>
                                                </xsl:call-template>
                                                <xsl:text>)</xsl:text>
                                            </xsl:with-param>
                                        </xsl:call-template>
                                        <xsl:text>&#10;</xsl:text>
                                    </xsl:for-each>
                                    <xsl:if test="@type!='group'">
                                        <xsl:text>==</xsl:text>
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="'Hierarchicallist'"/>
                                        </xsl:call-template>
                                        <xsl:text>==</xsl:text>
                                        <xsl:text>&#10;</xsl:text>
                                        <xsl:text>{{:{{BASEPAGENAME}}/hlist}}</xsl:text>
                                        <xsl:text>&#10;</xsl:text>
                                    </xsl:if>
                                </xsl:result-document>
                            </xsl:when>
                            <xsl:when test="$adram='confluence'">
                                <xsl:variable name="fnr" select="concat($tmpdir, '/tr-', $tid, '.html')"/>
                                <ix artefact="TR" fn ="{$fnr}" wiki="{$tid}" type="html" id="{@id}" statusCode="{$statusCode}">
                                    <name>
                                        <xsl:value-of select="$tname"/>
                                        <xsl:value-of select="concat(' (', $ttype, ')')"/>
                                    </name>
                                </ix>
                                <xsl:result-document href="{$fnr}" format="xhtml">
                                    <div>
                                        <h1>
                                            <xsl:call-template name="getMessage">
                                                <xsl:with-param name="key" select="'Transaction'"/>
                                            </xsl:call-template>
                                            <i>
                                                <xsl:value-of select="$tname"/>
                                            </i>
                                            <xsl:text> (</xsl:text>
                                            <xsl:value-of select="$ttype"/>                            
                                            <xsl:text>)</xsl:text>
                                        </h1>
                                        <xsl:if test="desc[@language=$language]">
                                            <!--
                                            <h2>
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'wikidescription'"/>
                                                </xsl:call-template>
                                            </h2>
                                            <xsl:text>&#10;</xsl:text>
                                            -->
                                            <p>
                                                <xsl:copy-of select="desc[@language=$language]"/>
                                            </p>
                                            <xsl:text>&#10;</xsl:text>
                                        </xsl:if>
                                        <xsl:text>&#10;</xsl:text>
                                        <h2>
                                            <xsl:call-template name="getMessage">
                                                <xsl:with-param name="key" select="'wikilisttransactionversions'"/>
                                            </xsl:call-template>
                                        </h2>
                                        <xsl:text>&#10;</xsl:text>
                                        <ul>
                                            <xsl:for-each select="//scenario//transaction[@id=$tid]">
                                                <xsl:variable name="edd" select="@effectiveDate"/>
                                                <li>  
                                                    <xsl:call-template name="doLinkItem">
                                                        <xsl:with-param name="page" select="concat($tid, '/static-', replace(@effectiveDate,':',''))"/>
                                                        <xsl:with-param name="label" select="$edd"/>
                                                    </xsl:call-template>
                                                    <xsl:text> (</xsl:text>
                                                    <xsl:call-template name="getMessage">
                                                        <xsl:with-param name="key" select="concat('TemplateStatusCodeLifeCycle-',@statusCode)"/>
                                                    </xsl:call-template>
                                                    <xsl:text>)</xsl:text>
                                                </li>
                                            </xsl:for-each>
                                        </ul>
                                        <xsl:text>&#10;</xsl:text>
                                        <xsl:if test="@type!='group'">
                                            <h2>
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'Hierarchicallist'"/>
                                                </xsl:call-template>
                                            </h2>
                                            <xsl:text>&#10;</xsl:text>
                                            <xsl:call-template name="doConfluenceIncludePageMacro">
                                                <xsl:with-param name="page" select="concat($tid, '/hlist')"/>
                                            </xsl:call-template>
                                            <xsl:text>&#10;</xsl:text>
                                        </xsl:if>
                                    </div>
                                </xsl:result-document>
                            </xsl:when>
                            <xsl:when test="$adram='wordpress'">
                                <xsl:variable name="fnr" select="concat($tmpdir, '/tr-', $tid, '.html')"/>
                                <ix artefact="TR" fn ="{$fnr}" wiki="{$tid}" type="html" id="{@id}" statusCode="{$statusCode}">
                                    <name>
                                        <xsl:value-of select="$tname"/>
                                        <xsl:value-of select="concat(' (', $ttype, ')')"/>
                                    </name>
                                </ix>
                                <xsl:result-document href="{$fnr}" format="xhtml">
                                    <p>
                                        <h1>
                                            <xsl:call-template name="getMessage">
                                                <xsl:with-param name="key" select="'Transaction'"/>
                                            </xsl:call-template>
                                            <i>
                                                <xsl:value-of select="$tname"/>
                                            </i>
                                            <xsl:text> (</xsl:text>
                                            <xsl:value-of select="$ttype"/>                            
                                            <xsl:text>)</xsl:text>
                                        </h1>
                                        <xsl:if test="desc[@language=$language]">
                                            <!--
                                            <h2>
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'wikidescription'"/>
                                                </xsl:call-template>
                                            </h2>
                                            <xsl:text>&#10;</xsl:text>
                                            -->
                                            <p>
                                                <xsl:copy-of select="desc[@language=$language]"/>
                                            </p>
                                            <xsl:text>&#10;</xsl:text>
                                        </xsl:if>
                                        <xsl:text>&#10;</xsl:text>
                                        <h2>
                                            <xsl:call-template name="getMessage">
                                                <xsl:with-param name="key" select="'wikilisttransactionversions'"/>
                                            </xsl:call-template>
                                        </h2>
                                        <xsl:text>&#10;</xsl:text>
                                        <ul>
                                            <xsl:for-each select="//scenario//transaction[@id=$tid]">
                                                <xsl:variable name="edd" select="@effectiveDate"/>
                                                <li>  
                                                    <xsl:call-template name="doLinkItem">
                                                        <xsl:with-param name="page" select="concat($tid, '/static-', replace(@effectiveDate,':',''))"/>
                                                        <xsl:with-param name="label" select="$edd"/>
                                                    </xsl:call-template>
                                                    <xsl:text> (</xsl:text>
                                                    <xsl:call-template name="getMessage">
                                                        <xsl:with-param name="key" select="concat('TemplateStatusCodeLifeCycle-',@statusCode)"/>
                                                    </xsl:call-template>
                                                    <xsl:text>)</xsl:text>
                                                </li>
                                            </xsl:for-each>
                                        </ul>
                                        <xsl:text>&#10;</xsl:text>
                                        <xsl:if test="@type!='group'">
                                            <h2>
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'Hierarchicallist'"/>
                                                </xsl:call-template>
                                            </h2>
                                            <xsl:text>&#10;</xsl:text>
                                            <xsl:call-template name="doWordpressIncludePageMacro">
                                                <xsl:with-param name="page" select="concat($tid, '/hlist')"/>
                                            </xsl:call-template>
                                            <xsl:text>&#10;</xsl:text>
                                        </xsl:if>
                                    </p>
                                </xsl:result-document>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each-group>
                    <!-- go through all versions of all transactions -->
                    <xsl:for-each select="//scenario//transaction">
                        <xsl:variable name="tid" select="@id"/>
                        <xsl:variable name="statusCode" select="@statusCode"/>
                        <xsl:variable name="tname" select="name[@language=$language]"/>
                        <xsl:variable name="oed" select="@effectiveDate"/>
                        <xsl:variable name="ed" select="replace($oed,':','')"/>
                        <xsl:variable name="prefix" select="ancestor::decor/project/@prefix"/>
                        <!-- type is "group" (type G of the graph), or one of "initial", "back" "stationary" (type L of the graph) -->
                        <xsl:variable name="tty" select="@type"/>
                        <!-- base transation file -->
                        <xsl:variable name="fnhtml" select="concat($tmpdir, '/tr-', $tid, '-', $ed, '.html')"/>
                        <xsl:variable name="wikihtml" select="concat($tid, '/static-', $ed)"/>
                        <!-- corresponding svg file -->
                        <xsl:variable name="fnsvg" select="concat($tmpdir, '/tr-', $tid, '-', $ed, '.svg')"/>
                        <xsl:variable name="wikisvg" select="concat('TR-', $tid, '-', $ed, '.svg')"/>
                        <xsl:choose>
                            <xsl:when test="$adram='mediawiki'">
                                <xsl:result-document href="{$fnhtml}" method="xhtml" indent="no" omit-xml-declaration="yes">
                                    <xsl:comment>
                                        <xsl:text>TRANSACTION </xsl:text>
                                        <xsl:value-of select="$tid"/>
                                        <xsl:text> as of </xsl:text>
                                        <xsl:value-of select="$oed"/>
                                        <xsl:text> (</xsl:text>
                                        <xsl:value-of select="@type"/>
                                        <xsl:text>)</xsl:text>
                                    </xsl:comment>
                                    <xsl:text>&#10;</xsl:text>
                                    <xsl:text>[[File:</xsl:text>
                                    <xsl:value-of select="$wikisvg"/>
                                    <xsl:text>|class=art-decor-responsive-img]]</xsl:text>
                                </xsl:result-document>
                            </xsl:when>
                            <xsl:when test="$adram='confluence'">
                                <xsl:result-document href="{$fnhtml}" method="xhtml" indent="no" omit-xml-declaration="yes">
                                    <img class="confluence art-decor-responsive-img" role="img" src="{$wikisvg}" alt="Automatic ADBot image" />
                                </xsl:result-document>
                            </xsl:when>
                            <xsl:when test="$adram='wordpress'">
                                <xsl:result-document href="{$fnhtml}" method="xhtml" indent="no" omit-xml-declaration="yes">
                                    <img class="alignnone art-decor-responsive-img" role="img" src="/wp-content/uploads/{$wikisvg}" alt="Automatic ADBot image" />
                                </xsl:result-document>
                            </xsl:when>
                        </xsl:choose>
                        
                        <xsl:variable name="theSVG">
                            <xsl:choose>
                                <xsl:when test="$tty='group'">
                                    <!-- retrieve transaction group svg -->
                                    <xsl:copy-of select="doc(concat($deeplinkprefixservicescascaded, 'RetrieveTransactionGroupDiagram?prefix=', $prefix, '&amp;id=',
                                        $tid, '&amp;effectiveDate=', $oed, '&amp;language=', $language, '&amp;format=hgraph&amp;inline=true'))"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <!-- retrieve transaction item svg -->
                                    <xsl:copy-of select="doc(concat($deeplinkprefixservicescascaded, 'RetrieveConceptDiagram?transactionId=',
                                        $tid, '&amp;transactionEffectiveDate=', $oed, '&amp;language=', $language, '&amp;interactive=false'))"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="tsvg">
                            <xsl:choose>
                                <xsl:when test="count($theSVG)>0">
                                    <xsl:copy-of select="$theSVG//*[namespace-uri()='http://www.w3.org/2000/svg' and local-name()='svg']"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:message>WARN : +++ RetrieveTransactionGroupDiagram / RetrieveConceptDiagram failed for project <xsl:value-of select="$prefix"/>: Transaction id <xsl:value-of select="$tid"/> effectiveDate: <xsl:value-of select="$oed"/>
                                    </xsl:message>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:if test="count($tsvg)>0">
                            <ix artefact="TR" fn="{$fnhtml}" wiki="{$wikihtml}" type="html" id="{$tid}" statusCode="{$statusCode}">
                                <diagram>
                                    <xsl:value-of select="$tname"/>
                                </diagram>
                            </ix>
                            <ix artefact="TR" fn="{$fnsvg}" img="{$wikisvg}" type="svg" id="{$tid}" statusCode="{$statusCode}">
                                <diagram>
                                    <xsl:value-of select="$tname"/>
                                </diagram>
                            </ix>
                            <xsl:result-document href="{$fnsvg}" method="xml" indent="no" omit-xml-declaration="yes">
                                <xsl:copy-of select="$tsvg"/>
                                <xsl:text>&#10;</xsl:text>
                            </xsl:result-document>
                        </xsl:if>
                        
                        <!--
                        https://art-decor.org/decor/services/RetrieveTransactionGroupDiagram?prefix=demo5-&id=2.16.840.1.113883.3.1937.99.60.5.4.100&effectiveDate=2014-07-08T00%3A00%3A00&language=en-US
                        https://art-decor.org/decor/services/RetrieveConceptDiagram?id=2.16.840.1.113883.3.1937.99.60.5.2.20&effectiveDate=2014-07-08T00:00:00&transactionEffectiveDate=2014-07-08T00:00:00&language=en-US&transactionId=2.16.840.1.113883.3.1937.99.60.5.4.101
                        https://art-decor.org/decor/services/RetrieveConceptDiagram?transactionEffectiveDate=2014-07-08T00:00:00&language=en-US&transactionId=2.16.840.1.113883.3.1937.99.60.5.4.101
                        
                        https://art-decor.org/decor/services/RetrieveTransaction?id=2.16.840.1.113883.3.1937.99.60.5.4.101&language=en-US&effectiveDate=&format=hlist&hidecolumns=o
                        -->
                        <!-- create hierarchical list for transaction (no groups) -->
                        <xsl:if test="$processHierarchicalGraphs='true' and $tty!='group'">
                            <xsl:variable name="fnhghtml" select="concat($tmpdir, '/tr-', $tid, '-hlist.html')"/>
                            <xsl:variable name="wikitrhg" select="concat($tid, '/hlist')"/>
                            <xsl:variable name="theHgraph">
                                <xsl:copy-of select="doc(concat($deeplinkprefixservicescascaded, 'RetrieveTransaction?id=', $tid,
                                    '&amp;effectiveDate=&amp;language=', $language, '&amp;format=hlist&amp;hidecolumns=o'))"/>
                            </xsl:variable>
                            <xsl:variable name="hct">
                                <xsl:choose>
                                    <xsl:when test="count($theHgraph)>0">
                                        <xsl:copy-of select="$theHgraph"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:message>WARN : +++ RetrieveTransaction failed for project <xsl:value-of select="$prefix"/>: Transaction id <xsl:value-of select="$tid"/>
                                        </xsl:message>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:if test="count($hct//body/table[2])>0">
                                <ix artefact="TR" fn ="{$fnhghtml}" wiki="{$wikitrhg}" type="html" id="{@id}" statusCode="{$statusCode}">
                                    <hlist>
                                        <xsl:value-of select="$tname"/>
                                    </hlist>
                                </ix>
                                <xsl:result-document href="{$fnhghtml}" method="xhtml" indent="no" omit-xml-declaration="yes">
                                    <xsl:copy-of select="$hct//body/table[2]"/>
                                    <xsl:text>&#10;</xsl:text>
                                </xsl:result-document>
                            </xsl:if>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:if>
                <!-- 
                    redirect for "named object" for value sets and templates HAS BEEN DEPRECATED SINCE 2020 
                -->
                <!-- 
                     phase 4: datasets 
                     =====
                -->
                <xsl:if test="$processDatasets='true'">
                    <xsl:for-each select="//datasets//dataset">
                        <xsl:variable name="dsid" select="@id"/>
                        <xsl:variable name="statusCode" select="@statusCode"/>
                        <xsl:variable name="dsname" select="name[@language=$language]"/>
                        <xsl:variable name="oed" select="@effectiveDate"/>
                        <xsl:variable name="ed" select="replace($oed,':','')"/>
                        <xsl:variable name="dshtml" select="concat($tmpdir, '/ds-', $dsid, '-', $ed, '.html')"/>
                        <xsl:variable name="wikihtml" select="concat($dsid, '/static-', $ed)"/>
                        <!--
                            first write an index file for that very data set
                        -->
                        <ix artefact="DS" fn ="{$dshtml}" wiki="{$wikihtml}" type="html" id="{$dsid}" statusCode="{$statusCode}">
                            <name>
                                <xsl:value-of select="$dsname"/>
                            </name>
                        </ix>
                        <xsl:choose>
                            <xsl:when test="$adram='mediawiki'">
                                <xsl:result-document href="{$dshtml}" method="xhtml" indent="no" omit-xml-declaration="yes">
                                    <xsl:call-template name="nomanualedits"/>
                                    <xsl:text>&#10;</xsl:text>
                                    <xsl:text>[[Category:Dataset]]</xsl:text>
                                    <xsl:text>&#10;</xsl:text>
                                    <xsl:text>=</xsl:text>
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'Dataset'"/>
                                    </xsl:call-template>
                                    <xsl:text>'' </xsl:text>
                                    <xsl:value-of select="$dsname"/>
                                    <xsl:text>''=</xsl:text>
                                    <xsl:text>&#10;</xsl:text>
                                    <xsl:if test="desc[@language=$language]">
                                        <p>
                                            <xsl:copy-of select="desc[@language=$language]/node()"/>
                                        </p>
                                        <xsl:text>&#10;</xsl:text>
                                    </xsl:if>
                                    <xsl:text>&#10;</xsl:text>
                                    <xsl:text>==</xsl:text>
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'DatasetContents'"/>
                                    </xsl:call-template>
                                    <xsl:text>==</xsl:text>
                                    <xsl:text>&#10;</xsl:text>
                                    <ul>
                                        <xsl:for-each select="concept">
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
                                            <li>
                                                <xsl:value-of select="name[@language=$language]"/>
                                                <xsl:text> (</xsl:text>
                                                <xsl:value-of select="@type"/>
                                                <xsl:text>)</xsl:text>
                                                <xsl:call-template name="doLinkItem">
                                                    <xsl:with-param name="page">
                                                        <xsl:value-of select="@id"/>
                                                        <xsl:text>/static-</xsl:text>
                                                        <xsl:value-of select="replace(@effectiveDate,':','')"/>
                                                    </xsl:with-param>
                                                    <xsl:with-param name="label">
                                                        <xsl:call-template name="getMessage">
                                                            <xsl:with-param name="key" select="'xAsOfy'"/>
                                                        </xsl:call-template>
                                                        <xsl:value-of select="$edd"/>
                                                        <xsl:text> (</xsl:text>
                                                        <xsl:call-template name="getMessage">
                                                            <xsl:with-param name="key" select="concat('ItemStatusCodeLifeCycle-',@statusCode)"/>
                                                        </xsl:call-template>
                                                        <xsl:text>)</xsl:text>
                                                    </xsl:with-param>
                                                </xsl:call-template>
                                            </li>
                                        </xsl:for-each>
                                    </ul>
                                </xsl:result-document>
                            </xsl:when>
                            <xsl:when test="$adram='confluence'">
                                <xsl:result-document href="{$dshtml}" method="xhtml" indent="no" omit-xml-declaration="yes">
                                    <xsl:call-template name="nomanualedits"/>
                                    <xsl:text>&#10;</xsl:text>
                                    <h1>
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="'Dataset'"/>
                                        </xsl:call-template>
                                        <xsl:text> </xsl:text>
                                        <i>
                                            <xsl:value-of select="$dsname"/>
                                        </i>
                                    </h1>
                                    <xsl:text>&#10;</xsl:text>
                                    <xsl:if test="desc[@language=$language]">
                                        <p>
                                            <xsl:copy-of select="desc[@language=$language]/node()"/>
                                        </p>
                                        <xsl:text>&#10;</xsl:text>
                                    </xsl:if>
                                    <xsl:text>&#10;</xsl:text>
                                    <h2>
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="'DatasetContents'"/>
                                        </xsl:call-template>
                                    </h2>
                                    <xsl:text>&#10;</xsl:text>
                                    <ul>
                                        <xsl:for-each select="concept">
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
                                            <li>
                                                <xsl:value-of select="name[@language=$language]"/>
                                                <xsl:text> (</xsl:text>
                                                <xsl:value-of select="@type"/>
                                                <xsl:text>)</xsl:text>
                                                <xsl:call-template name="doLinkItem">
                                                    <xsl:with-param name="page">
                                                        <xsl:value-of select="@id"/>
                                                        <xsl:text>/static-</xsl:text>
                                                        <xsl:value-of select="replace(@effectiveDate,':','')"/>
                                                    </xsl:with-param>
                                                    <xsl:with-param name="label">
                                                        <xsl:call-template name="getMessage">
                                                            <xsl:with-param name="key" select="'xAsOfy'"/>
                                                        </xsl:call-template>
                                                        <xsl:value-of select="$edd"/>
                                                        <xsl:text> (</xsl:text>
                                                        <xsl:call-template name="getMessage">
                                                            <xsl:with-param name="key" select="concat('ItemStatusCodeLifeCycle-',@statusCode)"/>
                                                        </xsl:call-template>
                                                        <xsl:text>)</xsl:text>
                                                    </xsl:with-param>
                                                </xsl:call-template>
                                            </li>
                                        </xsl:for-each>
                                    </ul>
                                </xsl:result-document>
                            </xsl:when>
                        </xsl:choose>
                        
                        <xsl:for-each select="//concept[@type='group']">
                            <xsl:variable name="deid" select="@id"/>
                            <xsl:variable name="statusCode" select="@statusCode"/>
                            <xsl:variable name="dename" select="name[@language=$language]"/>
                            <xsl:variable name="deed" select="replace(@effectiveDate,':','')"/>
                            <xsl:variable name="xeffshort">
                                <xsl:choose>
                                    <xsl:when test="string-length(substring-before(@effectiveDate, 'T00:00:00'))>0">
                                        <xsl:value-of select="substring-before(@effectiveDate, 'T00:00:00')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="replace(@effectiveDate, 'T', ' ')"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:variable name="fndx" select="concat($tmpdir, '/de-', $deid, '-', $deed, '.html')"/>
                            <!-- write info to index file -->
                            <ix artefact="DE" fn ="{$fndx}" wiki="{concat($deid, '/static-', $deed)}" type="html" id="{@id}" statusCode="{$statusCode}">
                                <name>
                                    <xsl:value-of select="$dename"/>
                                </name>
                                <date>
                                    <xsl:value-of select="$xeffshort"/>
                                </date>
                            </ix>
                            <!-- create the result document "redirect" which is a wiki redirect -->
                            <xsl:result-document href="{$fndx}" format="xhtml">
                                <p>
                                <xsl:apply-templates select="." mode="elementtransfer">
                                    <xsl:with-param name="type" select="@type"/>
                                    <xsl:with-param name="hlevel" select="3"/>
                                </xsl:apply-templates>
                                <xsl:text>&#10;</xsl:text>
                                <!--
                                        <xsl:apply-templates select="//concept[@id='2.16.840.1.113883.3.1937.99.60.5.2.2840']" mode="elementtransfer">
                                            <xsl:with-param name="type" select="@type"/>
                                            <xsl:with-param name="hlevel" select="4"/>
                                        </xsl:apply-templates>
                                        <xsl:call-template name="nomanualeditstext"/>
                                        -->
                                </p>
                            </xsl:result-document>
                        </xsl:for-each>
                    </xsl:for-each>
                </xsl:if>
                <!-- 
                     phase 5: code systems 
                     =====
                -->
                <xsl:if test="$processCodeSystems='true'">
                    <!--
                            per code system with id and effective date
                            - create one rendering per effective date (version) with that id, e.g. 2.16.840.1.113883.1.11.1/static-2012-07-24
                            - create one redirect as the dynamic rendering, i.e. 2.16.840.1.113883.1.11.1/dynamic
                            - create one summary 2.16.840.1.113883.1.11.1
                            - create one redirect to the summary page named as the name of the code system
                        -->
                    
                    <!-- 
                        phase IIa: code system static; cave duplicate id+effectiveDate combinations due to multiple repository references
                        =====
                    -->
                    <xsl:for-each-group select="//terminology/codeSystem[(@id and not(@ident)) or (@id and local:identOfGovernanceGroup(@ident)) or local:matchesExplicitIncludes(@id)]" group-by="concat(@id, @effectiveDate)">
                        <xsl:variable name="csid" select="@id"/>
                        <xsl:variable name="statusCode" select="@statusCode"/>
                        <xsl:variable name="codesystemname">
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
                        <xsl:if test="string-length($csid)>0">
                            <!-- create a time stamp based on effectiveDate as YYYY-MM-DDThhmmss (without the :) and an alternative shortcut timepstamp YYYY-MM-DD if time is T00:00:00 -->
                            <xsl:variable name="ed" select="replace(@effectiveDate,':','')"/>
                            <xsl:variable name="xeffshort">
                                <xsl:choose>
                                    <xsl:when test="string-length(substring-before(@effectiveDate, 'T00:00:00'))>0">
                                        <xsl:value-of select="substring-before(@effectiveDate, 'T00:00:00')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="replace(@effectiveDate, 'T', ' ')"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:variable name="fns" select="concat($tmpdir, '/cs-', @id, '-', $ed, '.html')"/>
                            <xsl:variable name="wikis" select="concat(@id, '/static-', replace(@effectiveDate,':',''))"/>
                            <!-- write info to index file -->
                            <ix artefact="CS" fn ="{$fns}" wiki="{$wikis}" type="html" cat="cs" id="{@id}" effectiveDate="{@effectiveDate}" statusCode="{$statusCode}">
                                <name>
                                    <xsl:copy-of select="$codesystemname"/>
                                </name>
                                <date>
                                    <xsl:value-of select="$xeffshort"/>
                                </date>
                            </ix>
                            <xsl:variable name="t">
                                <xsl:apply-templates select=".">
                                    <xsl:with-param name="showOtherVersionsList" select="false()"/>
                                </xsl:apply-templates>
                            </xsl:variable>
                            <xsl:result-document href="{$fns}" format="xhtml" indent="no" omit-xml-declaration="yes">
                                <xsl:apply-templates select="$t" mode="simplify"/>
                                <xsl:text>&#10;</xsl:text>
                            </xsl:result-document>
                            <xsl:choose>
                                <xsl:when test="$adram='mediawiki'">
                                    <xsl:if test="string-length($xeffshort)>0">
                                        <xsl:variable name="fndx" select="concat($tmpdir, '/cs-', @id, '-', $ed, '-redirect.txt')"/>
                                        <!-- write info to index file -->
                                        <ix artefact="CS" fn ="{$fndx}" wiki="{concat(@id, '/static-', $xeffshort)}" type="text" id="{@id}" statusCode="{$statusCode}">
                                            <name>
                                                <xsl:copy-of select="$codesystemname"/>
                                            </name>
                                        </ix>
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
                                </xsl:when>
                                <xsl:when test="$adram='confluence'">
                                    <xsl:if test="string-length($xeffshort)>0">
                                        <xsl:variable name="fndx" select="concat($tmpdir, '/cs-', @id, '-', $ed, '-redirect.html')"/>
                                        <!-- write info to index file with ix elements -->
                                        <ix artefact="CS" fn ="{$fndx}"  wiki="{concat(@id, '/static-', $xeffshort)}" type="html" id="{@id}">
                                            <name>
                                                <xsl:copy-of select="$codesystemname"/>
                                            </name>
                                        </ix>
                                        <xsl:result-document href="{$fndx}" format="xhtml">
                                            <xsl:call-template name="doConfluenceIncludePageMacro">
                                                <xsl:with-param name="page" select="$wikis"/>
                                            </xsl:call-template>
                                        </xsl:result-document>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="$adram='wordpress'">
                                    <xsl:if test="string-length($xeffshort)>0">
                                        <xsl:variable name="fndx" select="concat($tmpdir, '/cs-', @id, '-', $ed, '-redirect.html')"/>
                                        <!-- write info to index file with ix elements -->
                                        <ix artefact="CS" fn ="{$fndx}"  wiki="{concat(@id, '/static-', $xeffshort)}" type="html" id="{@id}" statusCode="{$statusCode}">
                                            <name>
                                                <xsl:copy-of select="$codesystemname"/>
                                            </name>
                                        </ix>
                                        <xsl:result-document href="{$fndx}" format="xhtml">
                                            <xsl:call-template name="doWordpressIncludePageMacro">
                                                <xsl:with-param name="page" select="$wikis"/>
                                            </xsl:call-template>
                                        </xsl:result-document>
                                    </xsl:if>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:if>
                    </xsl:for-each-group>             
                    <!-- 
                        phase IIb: code system dynamic and summary
                        =====
                    -->
                    <xsl:for-each-group select="//terminology/codeSystem[(@id and not(@ident)) or (@id and local:identOfGovernanceGroup(@ident)) or local:matchesExplicitIncludes(@id)]" group-by="@id">
                        <!-- dynamic -->
                        <xsl:variable name="csid" select="@id"/>
                        <xsl:variable name="statusCode" select="@statusCode"/>
                        <xsl:variable name="codesystemname">
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
                        <xsl:if test="string-length($csid)>0">
                            <!-- most recent value set version with status code any of new draft final review pending -->
                            <xsl:variable name="maxstaticdate" select="max($allcs[(@id=$csid) and @statusCode = ('new', 'draft', 'final', 'review', 'pending')]/xs:dateTime(@effectiveDate))"/>
                            <xsl:variable name="maxstatic" select="replace(string($maxstaticdate),':','')"/>
                            <xsl:variable name="wikid" select="concat(@id, '/dynamic')"/>
                            <!-- create the result document "dynamic" which is a wiki redirect only -->
                            <xsl:choose>
                                <xsl:when test="$adram='mediawiki'">
                                    <xsl:variable name="fnd" select="concat($tmpdir, '/cs-', $csid, '-dynamic.txt')"/>
                                    <!-- write info to index file -->
                                    <ix artefact="CS" fn ="{$fnd}" wiki="{$wikid}" type="text" id="{@id}" statusCode="{$statusCode}">
                                        <name>
                                            <xsl:copy-of select="$codesystemname"/>
                                        </name>
                                        <date>
                                            <xsl:text>dynamic (</xsl:text>
                                            <xsl:value-of select="$maxstatic"/>
                                            <xsl:text>)</xsl:text>
                                        </date>
                                    </ix>
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
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'wikilistnoactualversions'"/>
                                                </xsl:call-template>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:result-document>
                                </xsl:when>
                                <xsl:when test="$adram='confluence'">
                                    <xsl:variable name="fnd" select="concat($tmpdir, '/cs-', $csid, '-dynamic.html')"/>
                                    <!-- write info to index file with ix elements -->
                                    <ix artefact="CS" fn ="{$fnd}" wiki="{$wikid}" type="html" id="{@id}" statusCode="{$statusCode}">
                                        <name>
                                            <xsl:copy-of select="$codesystemname"/>
                                        </name>
                                        <date>
                                            <xsl:text>dynamic (</xsl:text>
                                            <xsl:value-of select="$maxstatic"/>
                                            <xsl:text>)</xsl:text>
                                        </date>
                                    </ix>
                                    <xsl:result-document href="{$fnd}" format="xhtml">
                                        <xsl:choose>
                                            <xsl:when test="string-length($maxstatic)>0">
                                                <div>
                                                    <xsl:call-template name="doConfluenceIncludePageMacro">
                                                        <xsl:with-param name="page" select="concat(@id, '/static-', $maxstatic)"/>
                                                    </xsl:call-template>
                                                </div>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <div>
                                                    <xsl:call-template name="getMessage">
                                                        <xsl:with-param name="key" select="'wikilistnoactualversions'"/>
                                                    </xsl:call-template>
                                                </div>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:result-document>
                                </xsl:when>
                                <xsl:when test="$adram='wordpress'">
                                    <xsl:variable name="fnd" select="concat($tmpdir, '/cs-', $csid, '-dynamic.html')"/>
                                    <!-- write info to index file with ix elements -->
                                    <ix artefact="CS" fn ="{$fnd}" wiki="{$wikid}" type="html" id="{@id}" statusCode="{$statusCode}">
                                        <name>
                                            <xsl:copy-of select="$codesystemname"/>
                                        </name>
                                        <date>
                                            <xsl:text>dynamic (</xsl:text>
                                            <xsl:value-of select="$maxstatic"/>
                                            <xsl:text>)</xsl:text>
                                        </date>
                                    </ix>
                                    <xsl:result-document href="{$fnd}" format="xhtml">
                                        <xsl:choose>
                                            <xsl:when test="string-length($maxstatic)>0">
                                                <div>
                                                    <xsl:call-template name="doWordpressIncludePageMacro">
                                                        <xsl:with-param name="page" select="concat(@id, '/static-', $maxstatic)"/>
                                                    </xsl:call-template>
                                                </div>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <div>
                                                    <xsl:call-template name="getMessage">
                                                        <xsl:with-param name="key" select="'wikilistnoactualversions'"/>
                                                    </xsl:call-template>
                                                </div>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:result-document>
                                </xsl:when>
                            </xsl:choose>
                            
                            <!-- create the result document "summary" -->
                            <xsl:choose>
                                <xsl:when test="$adram='mediawiki'">
                                    <xsl:variable name="fnr" select="concat($tmpdir, '/cs-', $csid, '-summary.txt')"/>
                                    <xsl:variable name="wikir" select="@id"/>
                                    <ix artefact="CS" fn ="{$fnr}" wiki="{$wikir}" type="text" id="{@id}" statusCode="{$statusCode}">
                                        <summary>
                                            <xsl:copy-of select="$codesystemname"/>
                                        </summary>
                                    </ix>
                                    <xsl:result-document href="{$fnr}" format="text">
                                        <xsl:text>__NOTOC__</xsl:text>
                                        <xsl:call-template name="nomanualeditstext"/>
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="'wikiterminologynote'"/>
                                        </xsl:call-template>
                                        <xsl:text>&#10;</xsl:text>
                                        <xsl:text>[[Category:Code System]]</xsl:text>
                                        <xsl:text>&#10;</xsl:text>
                                        <xsl:text>=Code System ''</xsl:text>
                                        <xsl:value-of select="@name"/>
                                        <xsl:text>''=</xsl:text>
                                        <xsl:text>&#10;</xsl:text>
                                        <xsl:if test="desc[@language=$language]">
                                            <!--<xsl:text>==</xsl:text>
                                            <xsl:call-template name="getMessage">
                                                <xsl:with-param name="key" select="'wikidescription'"/>
                                            </xsl:call-template>
                                            <xsl:text>==</xsl:text>
                                            <xsl:text>&#10;</xsl:text>-->
                                            <xsl:text>&lt;p></xsl:text>
                                            <xsl:copy-of select="desc[@language=$language]"/>
                                            <xsl:text>&lt;/p></xsl:text>
                                            <xsl:text>&#10;</xsl:text>
                                        </xsl:if>
                                        <xsl:text>==</xsl:text>
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="'wikiactualversion'"/>
                                        </xsl:call-template>
                                        <xsl:text>==</xsl:text>
                                        <xsl:text>&#10;</xsl:text>
                                        <xsl:text>{{:{{BASEPAGENAME}}/dynamic}}</xsl:text>
                                        <xsl:text>&#10;</xsl:text>
                                        <xsl:text>&#10;</xsl:text>
                                        <xsl:text>==</xsl:text>
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="'wikilistvaluesetversions'"/>
                                        </xsl:call-template>
                                        <xsl:text>==</xsl:text>
                                        <xsl:text>&#10;</xsl:text>
                                        <xsl:choose>
                                            <xsl:when test="count($allcs[(@id=$csid and not(@ident)) or (@id=$csid and local:matchesExplicitIncludes(@id))]) &lt;= 0">
                                                <xsl:text>(bisher keine weiteren Angaben)</xsl:text>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:for-each-group select="$allcs[(@id=$csid and not(@ident)) or (@id=$csid and local:matchesExplicitIncludes(@id))]" group-by="concat(@id, @effectiveDate)">
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
                                                    <xsl:text>* </xsl:text>
                                                    <xsl:call-template name="doLinkItem">
                                                        <xsl:with-param name="page">
                                                            <xsl:value-of select="@id"/>
                                                            <xsl:text>/static-</xsl:text>
                                                            <xsl:value-of select="replace(@effectiveDate,':','')"/>
                                                        </xsl:with-param>
                                                        <xsl:with-param name="label">
                                                            <xsl:value-of select="$edd"/>
                                                            <xsl:text> (</xsl:text>
                                                            <xsl:call-template name="getMessage">
                                                                <xsl:with-param name="key" select="concat('ItemStatusCodeLifeCycle-', @statusCode)"/>
                                                            </xsl:call-template>
                                                            <xsl:text>)</xsl:text>
                                                        </xsl:with-param>
                                                    </xsl:call-template>
                                                    <xsl:text>&#10;</xsl:text>
                                                </xsl:for-each-group>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:result-document>
                                </xsl:when>
                                <xsl:when test="$adram='confluence'">
                                    <xsl:variable name="fnr" select="concat($tmpdir, '/cs-', $csid, '-summary.html')"/>
                                    <xsl:variable name="wikir" select="@id"/>
                                    <ix artefact="CS" fn ="{$fnr}" wiki="{$wikir}" type="html" id="{@id}" statusCode="{$statusCode}">
                                        <summary>
                                            <xsl:copy-of select="$codesystemname"/>
                                        </summary>
                                    </ix>
                                    <xsl:result-document href="{$fnr}" format="xhtml">
                                        <div>
                                            <h1>
                                                <xsl:text>Code System </xsl:text>
                                                <xsl:value-of select="@name"/>
                                            </h1>
                                            <xsl:if test="desc[@language=$language]">
                                                <!--<h2>
                                                    <xsl:call-template name="getMessage">
                                                        <xsl:with-param name="key" select="'wikidescription'"/>
                                                    </xsl:call-template>
                                                </h2>-->
                                                <p>
                                                    <xsl:copy-of select="desc[@language=$language]"/>
                                                </p>
                                            </xsl:if>
                                            <h2>
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'wikiactualversion'"/>
                                                </xsl:call-template>
                                            </h2>
                                            <p>
                                                <xsl:call-template name="doConfluenceIncludePageMacro">
                                                    <xsl:with-param name="page" select="concat($wikir, '/dynamic')"/>
                                                </xsl:call-template>
                                            </p>
                                            <h2>
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'wikilistvaluesetversions'"/>
                                                </xsl:call-template>
                                            </h2>
                                            <xsl:choose>
                                                <xsl:when test="count($allcs[(@id=$csid and not(@ident)) or (@id=$csid and local:matchesExplicitIncludes(@id))]) &lt;= 0">
                                                    <xsl:text>(bisher keine weiteren Angaben)</xsl:text>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:for-each-group select="$allcs[(@id=$csid and not(@ident)) or (@id=$csid and local:matchesExplicitIncludes(@id))]" group-by="concat(@id, @effectiveDate)">
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
                                                        <xsl:variable name="tt">
                                                            <xsl:value-of select="@id"/>
                                                            <xsl:text>/static-</xsl:text>
                                                            <xsl:value-of select="replace(@effectiveDate,':','')"/>
                                                        </xsl:variable>
                                                        <xsl:variable name="cdt">
                                                            <xsl:text>&lt;![CDATA[</xsl:text>
                                                            <xsl:value-of select="$edd"/>
                                                            <xsl:text>]]&gt;</xsl:text>
                                                        </xsl:variable>
                                                        <ul>
                                                            <li>  
                                                                <xsl:call-template name="doLinkItem">
                                                                    <xsl:with-param name="page" select="$tt"/>
                                                                    <xsl:with-param name="label" select="$edd"/>
                                                                </xsl:call-template>
                                                                <xsl:text> (</xsl:text>
                                                                <xsl:call-template name="getMessage">
                                                                    <xsl:with-param name="key" select="concat('ItemStatusCodeLifeCycle-', @statusCode)"/>
                                                                </xsl:call-template>
                                                                <xsl:text>)</xsl:text>
                                                            </li>
                                                        </ul>
                                                    </xsl:for-each-group>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </div>
                                    </xsl:result-document>
                                </xsl:when>
                                <xsl:when test="$adram='wordpress'">
                                    <xsl:variable name="fnr" select="concat($tmpdir, '/cs-', $csid, '-summary.html')"/>
                                    <xsl:variable name="wikir" select="@id"/>
                                    <ix artefact="CS" fn ="{$fnr}" wiki="{$wikir}" type="html" id="{@id}" statusCode="{$statusCode}">
                                        <summary>
                                            <xsl:copy-of select="$codesystemname"/>
                                        </summary>
                                    </ix>
                                    <xsl:result-document href="{$fnr}" format="xhtml">
                                        <p>
                                            <h1>
                                                <xsl:text>Code System </xsl:text>
                                                <xsl:value-of select="@name"/>
                                            </h1>
                                            <xsl:if test="desc[@language=$language]">
                                                <p>
                                                    <xsl:copy-of select="desc[@language=$language]"/>
                                                </p>
                                            </xsl:if>
                                            <h2>
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'wikiactualversion'"/>
                                                </xsl:call-template>
                                            </h2>
                                            <p>
                                                <xsl:call-template name="doWordpressIncludePageMacro">
                                                    <xsl:with-param name="page" select="concat($wikir, '/dynamic')"/>
                                                </xsl:call-template>
                                            </p>
                                            <h2>
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'wikilistvaluesetversions'"/>
                                                </xsl:call-template>
                                            </h2>
                                            <xsl:choose>
                                                <xsl:when test="count($allcs[(@id=$csid and not(@ident)) or (@id=$csid and local:matchesExplicitIncludes(@id))]) &lt;= 0">
                                                    <xsl:text>(bisher keine weiteren Angaben)</xsl:text>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:for-each-group select="$allcs[(@id=$csid and not(@ident)) or (@id=$csid and local:matchesExplicitIncludes(@id))]" group-by="concat(@id, @effectiveDate)">
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
                                                        <xsl:variable name="tt">
                                                            <xsl:value-of select="@id"/>
                                                            <xsl:text>/static-</xsl:text>
                                                            <xsl:value-of select="replace(@effectiveDate,':','')"/>
                                                        </xsl:variable>
                                                        <xsl:variable name="cdt">
                                                            <xsl:text>&lt;![CDATA[</xsl:text>
                                                            <xsl:value-of select="$edd"/>
                                                            <xsl:text>]]&gt;</xsl:text>
                                                        </xsl:variable>
                                                        <ul>
                                                            <li>  
                                                                <xsl:call-template name="doLinkItem">
                                                                    <xsl:with-param name="page" select="$tt"/>
                                                                    <xsl:with-param name="label" select="$edd"/>
                                                                </xsl:call-template>
                                                                <xsl:text> (</xsl:text>
                                                                <xsl:call-template name="getMessage">
                                                                    <xsl:with-param name="key" select="concat('ItemStatusCodeLifeCycle-', @statusCode)"/>
                                                                </xsl:call-template>
                                                                <xsl:text>)</xsl:text>
                                                            </li>
                                                        </ul>
                                                    </xsl:for-each-group>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </p>
                                    </xsl:result-document>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:if>
                    </xsl:for-each-group>
                </xsl:if>
            </index>
        </xsl:result-document>
    </xsl:template>
    <!-- 
        emit data element of type "group" of a dataset
        - Show group element properties
        - walk through all child elements in given sequence
          - if a group is found tell it is a group and add the link to that group file
          - if it is an item show it on heading level higher wioth all properties
    -->
    <xsl:template match="concept" mode="elementtransfer">
        <xsl:param name="type"/>
        <xsl:param name="hlevel"/>
        <xsl:param name="headprefix"/>
        
        <xsl:variable name="dename" select="name[@language=$language]"/>
        <!-- 
            heading with the level indictaed in parameter
        -->
        <xsl:call-template name="doHeading">
            <xsl:with-param name="hlevel" select="$hlevel"/>
            <xsl:with-param name="heading" select="$dename"/>
            <xsl:with-param name="headprefix" select="$headprefix"/>
        </xsl:call-template>
        <xsl:text>&#10;</xsl:text>
        <!--
            description of this element, if any 
        -->
        <xsl:if test="desc[@language=$language]">
            <p>
                <xsl:copy-of select="desc[@language=$language]/node()"/>
            </p>
            <xsl:text>&#10;</xsl:text>
        </xsl:if>
        <!-- 
            valueDomain, rationale, source, operationalization of this element, if any
        -->
        <xsl:for-each select="valueDomain">
            <p>
                <b>
                    <xsl:call-template name="getMessage">
                        <xsl:with-param name="key" select="'ValueDomain'"/>
                    </xsl:call-template>
                    <xsl:text>: </xsl:text>
                </b>
                <xsl:value-of select="@type"/>
            </p>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
        <xsl:for-each select="rationale[@language=$language]">
            <p>
                <b>
                    <xsl:call-template name="getMessage">
                        <xsl:with-param name="key" select="'Rationale'"/>
                    </xsl:call-template>
                    <xsl:text>: </xsl:text>
                </b>
                <xsl:copy-of select="node()"/>
            </p>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
        <xsl:for-each select="source[@language=$language]">
            <p>
                <b>
                    <xsl:call-template name="getMessage">
                        <xsl:with-param name="key" select="'Source'"/>
                    </xsl:call-template>
                    <xsl:text>: </xsl:text>
                </b>
                <xsl:copy-of select="node()"/>
            </p>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
        <xsl:for-each select="operationalization[@language=$language]">
            <p>
                <b>
                    <xsl:call-template name="getMessage">
                        <xsl:with-param name="key" select="'Operationalization'"/>
                    </xsl:call-template>
                    <xsl:text>: </xsl:text>
                </b>
                <xsl:copy-of select="node()"/>
            </p>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
        <!-- 
            show all terminology associations in a table if valueDomain is code and there are any terminology associations 
        -->
        <xsl:variable name="tas">
            <xsl:copy-of select="terminologyAssociation"/>
        </xsl:variable>
        <xsl:if test="count(valueDomain/conceptList/concept)>0">
            <p>
                <b>
                    <xsl:call-template name="getMessage">
                        <xsl:with-param name="key" select="'ConceptList'"/>
                    </xsl:call-template>
                </b>
            </p>
            <xsl:for-each select="valueDomain[@type='code'][conceptList/concept]">
                <table class="artdecor zebra-table" width="100%" border="0" cellspacing="1" cellpadding="2" style="background: transparent; border: 1px solid #C0C0C0;">
                    <!-- head of table -->
                    <tr>
                        <th style="text-align: left;">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'Concept'"/>
                            </xsl:call-template>
                        </th>
                        <th style="text-align: left;">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'Code'"/>
                            </xsl:call-template>
                        </th>
                        <th style="text-align: left;">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'DisplayName'"/>
                            </xsl:call-template>
                        </th>
                        <th style="text-align: left;">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'CodeSystem'"/>
                            </xsl:call-template>
                        </th>
                    </tr>
                    <!-- terminology associations -->
                    <xsl:for-each select="conceptList/concept">
                        <xsl:variable name="cid" select="@id"/>
                        <xsl:variable name="bgcolor">
                            <!-- do the zebra -->
                            <xsl:choose>
                                <xsl:when test="position() mod 2">transparent</xsl:when>
                                <xsl:otherwise>#f7f7f7;</xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="rowspans" select="count($tas/terminologyAssociation[@conceptId=$cid])"/>
                        <xsl:variable name="firstcol">
                            <xsl:choose>
                                <xsl:when test="$rowspans = 1">
                                    <!-- only one terminology associations, normal table -->
                                    <td style="vertical-align: top;">
                                        <xsl:value-of select="name[@language=$language]"/>
                                    </td>
                                </xsl:when>
                                <xsl:otherwise>
                                    <!-- more than one terminology associations and this is the first, normal table -->
                                    <td style="vertical-align: top;" rowspan="{$rowspans}">
                                        <xsl:value-of select="name[@language=$language]"/>
                                    </td>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <!-- the concept first, maxbe with rowspans -->
                        <!-- them all terminology associations in columns and rows behind it -->
                        <xsl:for-each select="$tas/terminologyAssociation[@conceptId=$cid]">
                            <tr style="background: {$bgcolor};">
                                <xsl:if test="position()=1">
                                    <xsl:copy-of select="$firstcol"/>
                                </xsl:if>
                                <td>
                                    <xsl:value-of select="@code"/>
                                </td>
                                <td>
                                    <xsl:value-of select="@displayName"/>
                                </td>
                                <td>
                                    <xsl:choose>
                                        <xsl:when test="string-length(@codeSystemName)=0">
                                            <xsl:value-of select="@codeSystem"/>   
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="@codeSystemName"/>   
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    
                                </td>
                            </tr>
                        </xsl:for-each>
                    </xsl:for-each>
                </table>
            </xsl:for-each>
        </xsl:if>
        <!-- 
            now run through all child concepts
            for an item show it's properties, heading one level up
            for a group item just show the name of the group and a link to the respective page
        -->
        <xsl:for-each select="concept">
            <xsl:variable name="dename" select="name[@language=$language]"/>
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
            <xsl:choose>
                <xsl:when test="@type='item'">
                    <xsl:apply-templates select="." mode="elementtransfer">
                        <xsl:with-param name="type" select="@type"/>
                        <xsl:with-param name="hlevel" select="$hlevel+1"/>
                    </xsl:apply-templates>
                    <xsl:text>&#10;</xsl:text>
                </xsl:when>
                <xsl:when test="@type='group'">
                    <xsl:call-template name="doHeading">
                        <xsl:with-param name="hlevel" select="$hlevel"/>
                        <xsl:with-param name="heading" select="$dename"/>
                    </xsl:call-template>
                    <xsl:text>&#10;</xsl:text>
                    <xsl:call-template name="getMessage">
                        <xsl:with-param name="key" select="'GroupOfDataelements'"/>
                    </xsl:call-template>
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="getMessage">
                        <xsl:with-param name="key" select="'xAsOfy'"/>
                    </xsl:call-template>
                    <xsl:call-template name="doLinkItem">
                        <xsl:with-param name="page">
                            <xsl:value-of select="@id"/>
                            <xsl:text>/static-</xsl:text>
                            <xsl:value-of select="replace(@effectiveDate,':','')"/>
                        </xsl:with-param>
                        <xsl:with-param name="label">
                            <xsl:value-of select="$edd"/>
                            <xsl:text> (</xsl:text>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="concat('ItemStatusCodeLifeCycle-',@statusCode)"/>
                            </xsl:call-template>
                            <xsl:text>)</xsl:text>
                        </xsl:with-param>
                    </xsl:call-template>
                    <xsl:text>&#10;</xsl:text>
                    
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    <!-- 
        helpers
        =====
    -->
    <xsl:template match="xhtml:table" mode="simplify">
        <table xmlns="http://www.w3.org/1999/xhtml">
            <xsl:copy-of select="@* except (@class|@style)"/>
            <xsl:attribute name="class" select="concat('artdecor ', @class)"/>
            <xsl:attribute name="style" select="concat('background: transparent;', @style)"/>
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
    <xsl:template match="xhtml:a-NOTYETUSED[starts-with(@href, 'https://art-decor.org/mediawiki/index.php?title=DTr1')]" mode="simplify" priority="+2">
        <xsl:choose>
            <xsl:when test="$adram='mediawiki'">
                <xsl:text>[</xsl:text>
                <xsl:value-of select="@href"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="text()"/>
                <xsl:text>]</xsl:text>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="a" mode="simplify">
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
    <xsl:template name="matchSrc">
        <xsl:param name="imgsrc"/>
        <xsl:choose>
            <xsl:when test="$adram='mediawiki'">
                <xsl:choose>
                    <xsl:when test="$imgsrc='treeblank.png'">
                        <xsl:text>[[File:Treeblank.png|16px]]</xsl:text>
                    </xsl:when>
                    <xsl:when test="$imgsrc='treetree.png'">
                        <xsl:text>[[File:Treetree.png|16px]]</xsl:text>
                    </xsl:when>
                    <xsl:when test="$imgsrc='notice.png'">
                        <xsl:text>[[File:Notice.png|16px]]</xsl:text>
                    </xsl:when>
                    <xsl:when test="$imgsrc='kyellow.png'">
                        <xsl:text>[[File:Kyellow.png|14px]]</xsl:text>
                    </xsl:when>
                    <xsl:when test="$imgsrc='kvalidgreen.png'">
                        <xsl:text>[[File:Kvalidgreen.png|14px]]</xsl:text>
                    </xsl:when>
                    <xsl:when test="$imgsrc='kvalidblue.png'">
                        <xsl:text>[[File:Kvalidblue.png|12px]]</xsl:text>
                    </xsl:when>
                    <xsl:when test="$imgsrc='kred.png'">
                        <xsl:text>[[File:Kred.png|12px]]</xsl:text>
                    </xsl:when>
                    <xsl:when test="$imgsrc='kpurple.png'">
                        <xsl:text>[[File:Kpurple.png|14px]]</xsl:text>
                    </xsl:when>
                    <xsl:when test="$imgsrc='korange.png'">
                        <xsl:text>[[File:Korange.png|14px]]</xsl:text>
                    </xsl:when>
                    <xsl:when test="$imgsrc='kgrey.png'">
                        <xsl:text>[[File:Kgrey.png|14px]]</xsl:text>
                    </xsl:when>
                    <xsl:when test="$imgsrc='kgreen.png'">
                        <xsl:text>[[File:Kgreen.png|14px]]</xsl:text>
                    </xsl:when>
                    <xsl:when test="$imgsrc='kblue.png'">
                        <xsl:text>[[File:Kblue.png|14px]]</xsl:text>
                    </xsl:when>
                    <xsl:when test="$imgsrc='kcancelledblue.png'">
                        <xsl:text>[[File:Kcancelledblue.png|14px]]</xsl:text>
                    </xsl:when>
                    <xsl:when test="$imgsrc='kblank.png'">
                        <xsl:text>[[File:Kblank.png|14px]]</xsl:text>
                    </xsl:when>
                    <xsl:when test="$imgsrc='link.png'">
                        <xsl:text>[[File:Link.png|14px]]</xsl:text>
                    </xsl:when>
                    <xsl:when test="$imgsrc='en-US.png'">
                        <xsl:text>[[File:EN-US.png]]</xsl:text>
                    </xsl:when>
                    <xsl:when test="$imgsrc='de-DE.png'">
                        <xsl:text>[[File:DE-DE.png]]</xsl:text>
                    </xsl:when>
                    <xsl:when test="$imgsrc='nl-NL.png'">
                        <xsl:text>[[File:NL-NL.png]]</xsl:text>
                    </xsl:when>
                    <xsl:when test="$imgsrc='alert.png'">
                        <xsl:text>[[File:Alert.png|16px]]</xsl:text>
                    </xsl:when>
                    <xsl:when test="$imgsrc='target.png'">
                        <xsl:text>[[File:Target.png|14px]]</xsl:text>
                    </xsl:when>
                    <xsl:when test="$imgsrc='kred.png'">
                        <xsl:text>[[File:Kred.png|14px]]</xsl:text>
                    </xsl:when>
                    <xsl:when test="$imgsrc='korange.png'">
                        <xsl:text>[[File:Korange.png|14px]]</xsl:text>
                    </xsl:when>
                    <xsl:when test="$imgsrc='kyellow.png'">
                        <xsl:text>[[File:Kyellow.png|14px]]</xsl:text>
                    </xsl:when>
                    <xsl:when test="$imgsrc='circleplus.png'">
                        <xsl:text>[[File:Circleplus.png|14px]]</xsl:text>
                    </xsl:when>
                    <xsl:when test="$imgsrc='circleminus.png'">
                        <xsl:text>[[File:Circleminus.png|14px]]</xsl:text>
                    </xsl:when>
                    <xsl:when test="$imgsrc='download.png'">
                        <xsl:text>[[File:Download.png|14px]]</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$adram='confluence'">
                <!--
                <ac:image ac:thumbnail="true" ac:width="16"><ri:attachment ri:filename="{$imgsrc}" ri:version-at-save="1" /></ac:image>
                -->
                <ac:image ac:width="16"><ri:attachment ri:filename="{$imgsrc}" ri:version-at-save="2"><ri:page ri:content-title="Images"/></ri:attachment></ac:image>
            </xsl:when>
            <xsl:when test="$adram='wordpress'">
                <img style="width: 16px; display: inline !important;" src="/wp-content/uploads/{$imgsrc}" alt=""> </img>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/treeblank.png')]" mode="simplify">
        <xsl:call-template name="matchSrc">
            <xsl:with-param name="imgsrc" select="'treeblank.png'"/>
        </xsl:call-template>
        <xsl:apply-templates mode="simplify"/>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, 'treetree.png')]" mode="simplify">
        <xsl:call-template name="matchSrc">
            <xsl:with-param name="imgsrc" select="'treetree.png'"/>
        </xsl:call-template>
        <xsl:apply-templates mode="simplify"/>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/notice.png')]" mode="simplify">
        <xsl:call-template name="matchSrc">
            <xsl:with-param name="imgsrc" select="'notice.png'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/kyellow.png')]" mode="simplify">
        <xsl:call-template name="matchSrc">
            <xsl:with-param name="imgsrc" select="'kyellow.png'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/kvalidgreen.png')]" mode="simplify">
        <xsl:call-template name="matchSrc">
            <xsl:with-param name="imgsrc" select="'kvalidgreen.png'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/kvalidblue.png')]" mode="simplify">
        <xsl:call-template name="matchSrc">
            <xsl:with-param name="imgsrc" select="'kvalidblue.png'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/kred.png')]" mode="simplify">
        <xsl:call-template name="matchSrc">
            <xsl:with-param name="imgsrc" select="'kred.png'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/kpurple.png')]" mode="simplify">
        <xsl:call-template name="matchSrc">
            <xsl:with-param name="imgsrc" select="'kpurple.png'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/korange.png')]" mode="simplify">
        <xsl:call-template name="matchSrc">
            <xsl:with-param name="imgsrc" select="'korange.png'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/kgrey.png')]" mode="simplify">
        <xsl:call-template name="matchSrc">
            <xsl:with-param name="imgsrc" select="'kgrey.png'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/kgreen.png')]" mode="simplify">
        <xsl:call-template name="matchSrc">
            <xsl:with-param name="imgsrc" select="'kgreen.png'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/kblue.png')]" mode="simplify">
        <xsl:call-template name="matchSrc">
            <xsl:with-param name="imgsrc" select="'kblue.png'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/kcancelledblue.png')]" mode="simplify">
        <xsl:call-template name="matchSrc">
            <xsl:with-param name="imgsrc" select="'kcancelledblue.png'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/kblank.png')]" mode="simplify">
        <xsl:call-template name="matchSrc">
            <xsl:with-param name="imgsrc" select="'kblank.png'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/link.png')]" mode="simplify">
        <xsl:call-template name="matchSrc">
            <xsl:with-param name="imgsrc" select="'link.png'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/en-US.png')]" mode="simplify">
        <xsl:call-template name="matchSrc">
            <xsl:with-param name="imgsrc" select="'en-US.png'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/de-DE.png')]" mode="simplify">
        <xsl:call-template name="matchSrc">
            <xsl:with-param name="imgsrc" select="'de-DE.png'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/nl-NL.png')]" mode="simplify">
        <xsl:call-template name="matchSrc">
            <xsl:with-param name="imgsrc" select="'nl-NL.png'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/alert.png')]" mode="simplify">
        <xsl:call-template name="matchSrc">
            <xsl:with-param name="imgsrc" select="'alert.png'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/target.png')]" mode="simplify">
        <xsl:call-template name="matchSrc">
            <xsl:with-param name="imgsrc" select="'target.png'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/reddot.gif')]" mode="simplify">
        <xsl:call-template name="matchSrc">
            <xsl:with-param name="imgsrc" select="'reddot.png'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/orangedot.gif')]" mode="simplify">
        <xsl:call-template name="matchSrc">
            <xsl:with-param name="imgsrc" select="'orangedot.png'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/yellowdot.gif')]" mode="simplify">
        <xsl:call-template name="matchSrc">
            <xsl:with-param name="imgsrc" select="'yellowdot.png'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/circleplus.png')]" mode="simplify">
        <xsl:call-template name="matchSrc">
            <xsl:with-param name="imgsrc" select="'circleplus.png'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/circleminus.png')]" mode="simplify">
        <xsl:call-template name="matchSrc">
            <xsl:with-param name="imgsrc" select="'circleminus.png'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="xhtml:img[ends-with(@src, '/download.png')]" mode="simplify">
        <xsl:call-template name="matchSrc">
            <xsl:with-param name="imgsrc" select="'download.png'"/>
        </xsl:call-template>
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
    <!--
        mediawiki and confluence support
    -->
    <xsl:template name="doHeading">
        <xsl:param name="hlevel"/>
        <xsl:param name="heading"/>
        <xsl:param name="headprefix"/>
        <xsl:param name="headsuffix"/>
        <xsl:choose>
            <xsl:when test="$adram='mediawiki'">
                <xsl:choose>
                    <xsl:when test="$hlevel=1">
                        <xsl:text>=</xsl:text>
                        <xsl:copy-of select="$headprefix"/>
                        <xsl:value-of select="$heading"/>
                        <xsl:copy-of select="$headsuffix"/>
                        <xsl:text>=</xsl:text>
                    </xsl:when>
                    <xsl:when test="$hlevel=2">
                        <xsl:text>==</xsl:text>
                        <xsl:copy-of select="$headprefix"/>
                        <xsl:value-of select="$heading"/>
                        <xsl:copy-of select="$headsuffix"/>
                        <xsl:text>==</xsl:text>
                    </xsl:when>
                    <xsl:when test="$hlevel=3">
                        <xsl:text>===</xsl:text>
                        <xsl:copy-of select="$headprefix"/>
                        <xsl:value-of select="$heading"/>
                        <xsl:copy-of select="$headsuffix"/>
                        <xsl:text>===</xsl:text>
                    </xsl:when>
                    <xsl:when test="$hlevel=4">
                        <xsl:text>====</xsl:text>
                        <xsl:copy-of select="$headprefix"/>
                        <xsl:value-of select="$heading"/>
                        <xsl:copy-of select="$headsuffix"/>
                        <xsl:text>====</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>=====</xsl:text>
                        <xsl:copy-of select="$headprefix"/>
                        <xsl:value-of select="$heading"/>
                        <xsl:copy-of select="$headsuffix"/>
                        <xsl:text>=====</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$adram='confluence' or $adram='wordpress'">
                <xsl:choose>
                    <xsl:when test="$hlevel=1">
                        <h1 class="ad-heading">
                            <xsl:copy-of select="$headprefix"/>
                            <xsl:value-of select="$heading"/>
                            <xsl:copy-of select="$headsuffix"/>
                        </h1>
                    </xsl:when>
                    <xsl:when test="$hlevel=2">
                        <h2 class="ad-heading">
                            <xsl:copy-of select="$headprefix"/>
                            <xsl:value-of select="$heading"/>
                            <xsl:copy-of select="$headsuffix"/>
                        </h2>
                    </xsl:when>
                    <xsl:when test="$hlevel=3">
                        <h3 class="ad-heading">
                            <xsl:copy-of select="$headprefix"/>
                            <xsl:value-of select="$heading"/>
                            <xsl:copy-of select="$headsuffix"/>
                        </h3>
                    </xsl:when>
                    <xsl:when test="$hlevel=4">
                        <h4 class="ad-heading">
                            <xsl:copy-of select="$headprefix"/>
                            <xsl:value-of select="$heading"/>
                            <xsl:copy-of select="$headsuffix"/>
                        </h4>
                    </xsl:when>
                    <xsl:otherwise>
                        <h5 class="ad-heading">
                            <xsl:copy-of select="$headprefix"/>
                            <xsl:value-of select="$heading"/>
                            <xsl:copy-of select="$headsuffix"/>
                        </h5>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="doConfluenceIncludePageMacro">
        <xsl:param name="page"/>
        <ac:structured-macro ac:name="include" ac:schema-version="1" ac:macro-id="027055c0-e359-4e56-9382-30b4cec04a9e">
            <ac:parameter ac:name="">
                <ac:link><ri:page ri:content-title="{$page}" /></ac:link>
            </ac:parameter>
        </ac:structured-macro>
    </xsl:template>
    
    <xsl:template name="doWordpressIncludePageMacro">
        <xsl:param name="page"/>
        <p>
            <xsl:text>[insert page='</xsl:text>
            <xsl:value-of select="local:sluggy($page)"/>
            <xsl:text>' display='content']</xsl:text>
        </p>
    </xsl:template>
    
    <xsl:template name="doLinkItem">
        <xsl:param name="page"/>
        <xsl:param name="label"/>
        <xsl:choose>
            <xsl:when test="$adram='mediawiki'">
                <xsl:text>[[</xsl:text>
                <xsl:value-of select="$page"/>
                <xsl:text>|</xsl:text>
                <xsl:value-of select="$label"/>
                <xsl:text>]]</xsl:text>
            </xsl:when>
            <xsl:when test="$adram='confluence'">
                <ac:link>
                    <ri:page ri:content-title="{$page}"/>
                    <ac:plain-text-link-body>
                        <xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
                        <xsl:value-of select="$label"/>    
                        <xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
                    </ac:plain-text-link-body>
                </ac:link>
            </xsl:when>
            <xsl:when test="$adram='wordpress'">
                <a href="{concat('/', local:sluggy($page))}">
                    <xsl:value-of select="$label"/>
                </a>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:function name="local:sluggy" as="xs:string">
        <xsl:param name="page"/>
        <xsl:value-of select="replace(lower-case($page), '[./]', '-')"/>
    </xsl:function>
    
    <xsl:template name="addConfluenceStyleItem">
        <xsl:param name="css"/>
        <ac:structured-macro ac:name="style" ac:schema-version="1" >
            <ac:parameter ac:name="import">
                <xsl:value-of select="$css"/>    
            </ac:parameter>
            <ac:parameter ac:name="media">text/css</ac:parameter>
        </ac:structured-macro>
    </xsl:template>
</xsl:stylesheet>