<xsl:stylesheet xmlns="urn:hl7-org:v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="http://art-decor.org/functions" exclude-result-prefixes="xs" version="2.0">
<!-- 
    DECOR template fragement to schematron package
    Copyright (C) 2015-2017 Dr. Kai U. Heitmann
    
    This program is free software; you can redistribute it and/or modify it under the terms 
    of the GNU General Public License as published by the Free Software Foundation; 
    either version 3 of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
    See the GNU General Public License for more details.
    
    See http://www.gnu.org/licenses/gpl.html
  
-->
    <!-- borrow all usual schematron engine xsl procedures -->
    <xsl:include href="DECOR2schematron.xsl"/>
    <!-- 
        additional parameter:
        - createSchematronbasedOn template|scenario
          whether to create the schematron package based on single template(s) which is the default  or on whole scenario's
    -->
    <xsl:param name="createSchematronbasedOn" select="'template'"/>
    <!-- 
        intro and wrapper
    -->
    <xsl:template match="/" priority="+1">
        <wrapper>
            <xsl:copy-of select="*/@*"/>
            <xsl:attribute name="base" select="$outputBaseUriPrefix"/>
            <xsl:attribute name="runtime" select="$theRuntimeDir"/>
            <xsl:variable name="fn" select="concat($theRuntimeDir, 'orig.xml')"/>
            <!--
            <xsl:result-document href="{$fn}">
                <xsl:copy-of select="."/>
            </xsl:result-document>
            -->
            <!-- TODO: this only works for HL7 V3/CDA datatypes. Should make it work for all template/classification/@format -->
            <xsl:for-each-group select="$supportedDatatypes/*[@type = 'hl7v3xml1']" group-by="@name">
                <xsl:variable name="theDT" select="concat('DTr1_', replace(current-grouping-key(),':','-'), '.sch')"/>
                <xsl:call-template name="logMessage">
                    <xsl:with-param name="level" select="$logALL"/>
                    <xsl:with-param name="msg">
                        <xsl:value-of select="concat('coreschematrons/', $theDT)"/>
                        <xsl:text> - </xsl:text>
                        <xsl:value-of select="concat($theRuntimeDir, $theDT)"/>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="doCopyFile">
                    <xsl:with-param name="from" select="concat($scriptBaseUriPrefix, 'coreschematrons/', replace($theDT,':','-'))"/>
                    <xsl:with-param name="to" select="concat($theRuntimeIncludeDir, replace($theDT,':','-'))"/>
                </xsl:call-template>
            </xsl:for-each-group>
            <xsl:call-template name="doCopyFile">
                <xsl:with-param name="from" select="concat($scriptBaseUriPrefix, 'DECOR-ucum.xml')"/>
                <xsl:with-param name="to" select="concat($theRuntimeIncludeDir, 'voc-UCUM.xml')"/>
            </xsl:call-template>
            <!--
            <decor-original>
                <xsl:copy-of select="decor-excerpt/@* | decor/@*"/>
                <xsl:copy-of select="decor-excerpt/* | decor/*"/>
            </decor-original>
            -->
            <xsl:variable name="instancefragment">
                <decor-excerpt>
                    <xsl:copy-of select="decor-excerpt/@* | decor/@*"/>
                    <xsl:variable name="pid">
                        <xsl:choose>
                            <xsl:when test="decor//project/@id">
                                <xsl:value-of select="decor//project/@id"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'1.999.999'"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="plang">
                        <xsl:choose>
                            <xsl:when test="decor//project/@defaultLanguage">
                                <xsl:value-of select="decor//project/@defaultLanguage"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'en-US'"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="prefix">
                        <xsl:choose>
                            <xsl:when test="decor//project/@prefix">
                                <xsl:value-of select="decor//project/@prefix"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'decor-excerpt-live-'"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <project defaultLanguage="{$plang}" prefix="{$prefix}" id="{$pid}">
                        <xsl:choose>
                            <xsl:when test="decor//project">
                                <xsl:copy-of select="decor//project/name"/>
                                <xsl:copy-of select="decor//project/desc"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <name language="en-US">none</name>
                                <desc language="en-US">none</desc>
                            </xsl:otherwise>
                        </xsl:choose>
                        <copyright years="2016"/>
                    </project>
                    <!-- copy all scenarios just in case we need to create schematrons based on the scenarios -->
                    <xsl:copy-of select="decor-excerpt/scenarios | decor/scenarios"/>
                    <xsl:copy-of select="decor-excerpt/rules | decor/rules"/>
                    <xsl:copy-of select="decor-excerpt/terminology | decor/terminology"/>
                </decor-excerpt>
            </xsl:variable>
            <xsl:copy-of select="$instancefragment"/>
            <xsl:apply-templates select="$instancefragment//rules"/>
            <xsl:apply-templates select="$instancefragment//terminology"/>
            <!-- build instance2schematron.xml -->
            <xsl:call-template name="buildInstanceToSchematron"/>
        </wrapper>
    </xsl:template>
    <!-- 
    
        emit terminologies
    
    -->
    <xsl:template match="terminology">
        <xsl:call-template name="logMessage">
            <xsl:with-param name="level" select="$logINFO"/>
            <xsl:with-param name="msg">
                <xsl:text>*** Schematron vocab generation to </xsl:text>
                <xsl:value-of select="$theRuntimeIncludeDir"/>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:for-each-group select="$allValueSets/*/valueSet" group-by="concat((@id|@ref),'#',@effectiveDate)">
            <xsl:variable name="id" select="(@id|@ref)"/>
            <xsl:variable name="efd" select="@effectiveDate"/>
            <xsl:variable name="isNewest" select="$efd=max($allValueSets/*/valueSet[(@id|@ref)=$id]/xs:dateTime(@effectiveDate))"/>
            <xsl:call-template name="logMessage">
                <xsl:with-param name="level" select="$logDEBUG"/>
                <xsl:with-param name="msg">
                    <xsl:text>*** Schematron vocab file: name='</xsl:text>
                    <xsl:value-of select="@name"/>
                    <xsl:text>' id='</xsl:text>
                    <xsl:value-of select="$id"/>
                    <xsl:text>' effectiveDate='</xsl:text>
                    <xsl:value-of select="$efd"/>
                    <xsl:text>'</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:result-document href="{$theRuntimeIncludeDir}{local:doHtmlName('VS', $projectPrefix, $id, $efd, (), (), (), (), '.xml', 'true')}" format="xml">
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
                <xsl:result-document href="{$theRuntimeIncludeDir}{local:doHtmlName('VS', $projectPrefix, $id, 'DYNAMIC', (), (), (), (), '.xml', 'true')}" format="xml">
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
                <codeSystems>
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
                    <codeSystems>
                        <xsl:copy-of select="."/>
                    </codeSystems>
                </xsl:result-document>
            </xsl:if>
        </xsl:for-each-group>
    </xsl:template>
    <!-- 
    
        emit rules
    
    -->
    <xsl:template match="rules">
        <xsl:call-template name="logMessage">
            <xsl:with-param name="level" select="$logINFO"/>
            <xsl:with-param name="msg">
                <xsl:text>*** Schematron template generation to </xsl:text>
                <xsl:value-of select="$theRuntimeIncludeDir"/>
            </xsl:with-param>
        </xsl:call-template>
        <!-- switch createSchematronbasedOn template or scenario -->
        <xsl:choose>
            <xsl:when test="$createSchematronbasedOn='template'">
                <xsl:for-each select="$allTemplates/*/ref">
                    <xsl:choose>
                        <xsl:when test="not(@duplicateOf) and ( exists(template/context) and exists(template/@id) )">
                            <xsl:apply-templates select="template" mode="genfragment"/>
                        </xsl:when>
                        <xsl:when test="@duplicateOf">
                            <!-- no message -->
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="logMessage">
                                <xsl:with-param name="level" select="$logINFO"/>
                                <xsl:with-param name="msg">
                                    <xsl:text>*** Schematron template generation skipped for </xsl:text>
                                    <xsl:value-of select="template/@id"/>
                                    <xsl:text>: template has no context or no id or both is missing</xsl:text>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$createSchematronbasedOn='scenario'">
                <xsl:apply-templates select="$allScenarios/scenarios/scenario//transaction[representingTemplate/@ref]" mode="genfragment"/>
                <!-- 
                apply transformation to rules in DECOR file, make Runtime Environment"
                -->
                <xsl:for-each select="$allTemplates/*/ref">
                    <xsl:variable name="isTopLevelTemplate" as="xs:boolean">
                        <xsl:variable name="tid" select="@id"/>
                        <xsl:variable name="tnm" select="@name"/>
                        <xsl:variable name="ted" select="@effectiveDate"/>
                        <xsl:variable name="isNewestId" select="($allTemplates/templates/ref[@id=$tid][@effectiveDate=$ted][not(@duplicateOf)]/@newestForId)[1]" as="xs:boolean"/>
                        <xsl:variable name="isNewestName" select="($allTemplates/templates/ref[@name=$tnm][@effectiveDate=$ted][not(@duplicateOf)]/@newestForName)[1]" as="xs:boolean"/>
                        <xsl:value-of select="$allScenarios//representingTemplate[@ref=$tid and (@flexibility=$ted or (@flexibility='dynamic' and $isNewestId) or (not(@flexibility) and $isNewestId))] or                  $allScenarios//representingTemplate[@ref=$tnm and (@flexibility=$ted or (@flexibility='dynamic' and $isNewestName) or (not(@flexibility) and $isNewestName))]             "/>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="not(@duplicateOf) and ( exists(template/context) and exists(template/@id) )">
                            <xsl:apply-templates select="template" mode="GEN"/>
                        </xsl:when>
                        <xsl:when test="not(@duplicateOf) and $isTopLevelTemplate and exists(template/@id) ">
                            <!-- always generate SCH for representing template (if not already done in the statement above) -->
                            <xsl:apply-templates select="template" mode="GEN"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="logMessage">
                    <xsl:with-param name="level" select="$logFATAL"/>
                    <xsl:with-param name="msg">
                        <xsl:text>*** Schematron generation skipped for unknown instruction based-on: </xsl:text>
                        <xsl:value-of select="$createSchematronbasedOn"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- 
        helpers
    -->
    <xsl:template match="template" mode="genfragment">
        <xsl:variable name="rlabel" select="'?'"/>
        <xsl:variable name="isTopLevelTemplate" as="xs:boolean" select="true()"/>
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
        <xsl:call-template name="logMessage">
            <xsl:with-param name="level" select="$logINFO"/>
            <xsl:with-param name="msg">
                <xsl:text>*** Schematron template generation for </xsl:text>
                <xsl:value-of select="@id"/>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:result-document href="{$theRuntimeDir}{$uniqueId}.sch" format="xml">
            <schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
                <title>
                    <xsl:text>Template: </xsl:text>
                    <xsl:value-of select="@id"/>
                    <xsl:text> - </xsl:text>
                    <xsl:value-of select="@displayName"/>
                </title>
                
                <!-- default namespaces -->
                <ns uri="urn:hl7-org:v3" prefix="hl7"/>
                <ns uri="urn:hl7-org:v3" prefix="cda"/>
                <ns uri="http://www.w3.org/2001/XMLSchema-instance" prefix="xsi"/>
                <xsl:comment> Add extra namespaces </xsl:comment>
                
                <!-- get the other "foreign" namespaces of the DECOR root element -->
                <xsl:for-each-group select="namespace::node() | $allTemplates//ref/template/namespace::node()" group-by=".">
                    <xsl:if test="not(current-group()[1] = ('urn:hl7-org:v3', 'http://www.w3.org/2001/XMLSchema', 'http://www.w3.org/2001/XMLSchema-instance'))">
                        <ns uri="{current-group()[1]}" prefix="{name(current-group()[1])}"/>
                    </xsl:if>
                </xsl:for-each-group>
                <pattern>
                    <!-- TODO: this only works for HL7 V3/CDA datatypes. Should make it work for all template/classification/@format -->
                    <xsl:for-each-group select="$supportedDatatypes/*[@type = 'hl7v3xml1']" group-by="@name">
                        <xsl:variable name="theDT" select="concat('DTr1_', replace(current-grouping-key(),':','-'), '.sch')"/>
                        <include href="{$theRuntimeRelativeIncludeDir}{$theDT}"/>
                        <xsl:text>
</xsl:text>
                        <!--
                        <xsl:copy-of select="doc(concat('coreschematrons/',$theDT))/*"/>
                       
                        -->
                    </xsl:for-each-group>
                </pattern>
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
                <pattern id="template-{$uniqueId}">
                    <title>
                        <xsl:value-of select="if (string-length(@displayName)&gt;0) then @displayName else @name"/>
                    </title>
                    <xsl:call-template name="doTemplateRules">
                        <xsl:with-param name="rc" select="."/>
                        <xsl:with-param name="isClosedAttr" select="if ($switchCreateSchematronClosed=true() or string(@isClosed)='true') then (true()) else (false())"/>
                        <xsl:with-param name="nestinglevel" select="0"/>
                        <xsl:with-param name="checkIsClosed" select="false()"/>
                        <xsl:with-param name="sofar" select="()"/>
                        <xsl:with-param name="templateFormat" select="local:getTemplateFormat(.)"/>
                    </xsl:call-template>
                    <xsl:if test="$isTopLevelTemplate=true() or @isClosed='true'">
                        <!--<xsl:variable name="templatesInThisRepresentingTemplate">
                            <xsl:call-template name="getAssociatedTemplates">
                                <xsl:with-param name="rccontent" select="."/>
                            </xsl:call-template>
                        </xsl:variable>-->
                        <xsl:for-each select=".">
                            <!--<xsl:for-each select=". | $templatesInThisRepresentingTemplate//template[@standalone='true']">-->
                            <xsl:variable name="rccontent" as="element()?">
                                <xsl:choose>
                                    <xsl:when test="@standalone">
                                        <xsl:call-template name="getRulesetContent">
                                            <xsl:with-param name="ruleset" select="@id"/>
                                            <xsl:with-param name="flexibility" select="@effectiveDate"/>
                                            <xsl:with-param name="sofar" select="()"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:copy-of select="."/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:call-template name="doTemplateRules">
                                <xsl:with-param name="rc" select="$rccontent"/>
                                <xsl:with-param name="isClosedAttr" select="if ($switchCreateSchematronClosed=true() or $rccontent[@isClosed='true']) then (true()) else (false())"/>
                                <xsl:with-param name="nestinglevel" select="0"/>
                                <xsl:with-param name="checkIsClosed" select="true()"/>
                                <xsl:with-param name="sofar" select="()"/>
                                <xsl:with-param name="templateFormat" select="local:getTemplateFormat(.)"/>
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:if>
                </pattern>
            </schema>
        </xsl:result-document>
    </xsl:template>
    <xsl:template match="transaction" mode="genfragment">
        <xsl:variable name="rlabel" select="if (@label) then (normalize-space(@label)) else (@id)"/>
        <xsl:variable name="theTemplate" as="element(template)*">
            <xsl:call-template name="getRulesetContent">
                <xsl:with-param name="ruleset" select="@ref"/>
                <xsl:with-param name="flexibility" select="@flexibility"/>
                <xsl:with-param name="sofar" select="()"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:result-document href="{$theRuntimeDir}{$projectPrefix}{$rlabel}.sch" format="xml">
            
            <!-- include the xsl proc instr to easily convert the resulting sch file into xsl -->
            <schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
                <title>
                    <xsl:text>Scenario: </xsl:text>
                    <xsl:value-of select="$rlabel"/>
                    <xsl:text> - </xsl:text>
                    <xsl:value-of select="name[@language=$defaultLanguage]"/>
                    <xsl:value-of select="if (not(@label)) then '' else concat(' (', @id, ')')"/>
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
                <xsl:if test="$switchCreateSchematronWithWrapperIncludes=true()">
                    <xsl:text>
</xsl:text>
                    <xsl:choose>
                        <xsl:when test="$defaultLanguage='nl-NL'">
                            <!-- Include wrapper schematrons -->
                            <include href="{concat($theRuntimeRelativeIncludeDir, 'DTr1_XML.NL.sch')}"/>
                            <include href="{concat($theRuntimeRelativeIncludeDir, 'transmission-wrapper.NL.sch')}"/>
                            <!--<include href="include/attentionLine.NL.sch"/>-->
                            <include href="{concat($theRuntimeRelativeIncludeDir, 'controlAct-wrapper.NL.sch')}"/>
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
                            <!-- nothing to be included here
                                    2DO: multi lang support
                                -->
                            <xsl:comment> none </xsl:comment>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
                <xsl:comment> Include datatype abstract schematrons </xsl:comment>
                <xsl:text>
</xsl:text>
                
                <!-- this is the include directory -->
                <pattern>
                    <!-- TODO: this only works for HL7 V3/CDA datatypes. Should make it work for all template/classification/@format -->
                    <xsl:for-each-group select="$supportedDatatypes/*[@type = 'hl7v3xml1']" group-by="@name">
                        <xsl:variable name="theDT" select="concat('DTr1_', replace(current-grouping-key(),':','-'), '.sch')"/>
                        <include href="{$theRuntimeRelativeIncludeDir}{$theDT}"/>
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
                    <xsl:variable name="rccontent">
                        <xsl:call-template name="getRulesetContent">
                            <xsl:with-param name="ruleset" select="$rtid"/>
                            <xsl:with-param name="flexibility" select="$rtflex"/>
                            <xsl:with-param name="sofar" select="()"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="rtin" select="$rccontent/template/@name"/>
                    <xsl:variable name="rted" select="$rccontent/template/@effectiveDate"/>
                    <xsl:if test="$rccontent/template">
                        <!-- a template exists, include it -->
                        <xsl:comment>
                            <xsl:text> </xsl:text>
                            <xsl:value-of select="$rtin"/>
                            <xsl:text> </xsl:text>
                        </xsl:comment>
                        <xsl:text>
</xsl:text>
                        <include href="{$theRuntimeRelativeIncludeDir}{$rtid}-{replace($rted,':','')}.sch"/>
                        <include href="{$theRuntimeRelativeIncludeDir}{$rtid}-{replace($rted,':','')}-closed.sch"/>
                        <xsl:text>
</xsl:text>
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
                    <xsl:if test="$currentTemplateReferenceCount=0">
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
                    <xsl:variable name="tobeincluded">
                        <xsl:for-each-group select="$allTemplates/*/ref" group-by="@ref">
                            <xsl:sort select="@ref"/>
                            <xsl:if test="not(@duplicateOf) and (template/context/@id='*' or template/context/@id='**')">
                                <xsl:variable name="tid" select="template/@id"/>
                                <xsl:variable name="tin" select="template/@name"/>
                                <xsl:variable name="tif" select="template/@effectiveDate"/>
                                <xsl:variable name="tcl" select="template/@isClosed='true'" as="xs:boolean"/>
                                <xsl:variable name="tIsNewestForId" select="parent::ref/@newestForId"/>
                                <xsl:if test="count($allScenarios//representingTemplate[@id=$tid or @ref=$tid][((not(@flexibility) or @flexibility='dynamic') and $tIsNewestForId) or @flexibility=$tif])=0">
                                    <!-- using id of ref is for backward compatibility -->
                                    <!-- a template exists and is not a representingTemplate,  -->
                                    <xsl:if test="$switchCreateSchematronWithExplicitIncludes = false() or $templatesInThisRepresentingTemplate//template[@id=$tid][@effectiveDate=$tif]">
                                        <!-- 
                                                    still in testing mode...
                                                    it is part of it, include it as an include 
                                                -->
                                        <xsl:comment>
                                            <xsl:text> </xsl:text>
                                            <xsl:value-of select="$tin"/>
                                            <xsl:text> </xsl:text>
                                        </xsl:comment>
                                        <include href="{$theRuntimeRelativeIncludeDir}{$tid}-{replace($tif,':','')}.sch"/>
                                        <xsl:if test="$tcl">
                                            <include href="{$theRuntimeRelativeIncludeDir}{$tid}-{replace($tif,':','')}-closed.sch"/>
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
                </xsl:for-each>
                <xsl:text>

</xsl:text>
            </schema>
        </xsl:result-document>
    </xsl:template>
    <!-- 
        tests
    -->
    <xsl:template name="t">
        <xsl:for-each-group select="terminology/valueSet-XXXXXXXX" group-by="concat((@id|@ref),'#',@effectiveDate)">
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
            <xsl:result-document href="{$theRuntimeIncludeDir}{local:doHtmlName('VS', $projectPrefix, $id, $efd, (), (), (), (), '.xml', 'true')}" format="xml">
                <!-- do print copyright stuff etc -->
                <xsl:apply-templates select="//project">
                    <xsl:with-param name="what">
                        <xsl:value-of select="concat('Value Set ', $id, ' (STATIC ', $efd, ')')"/>
                    </xsl:with-param>
                </xsl:apply-templates>
                <valueSets xmlns="">
                    <xsl:copy-of select="."/>
                </valueSets>
            </xsl:result-document>
            <xsl:if test="$isNewest=true()">
                <xsl:result-document href="{$theRuntimeIncludeDir}{local:doHtmlName('VS', $projectPrefix, $id, 'DYNAMIC', (), (), (), (), '.xml', 'true')}" format="xml">
                    <!-- do print copyright stuff etc -->
                    <xsl:apply-templates select="//project">
                        <xsl:with-param name="what">
                            <xsl:value-of select="concat('Value Set ', $id, ' (DYNAMIC) as of ', $efd)"/>
                        </xsl:with-param>
                    </xsl:apply-templates>
                    <valueSets xmlns="">
                        <xsl:copy-of select="."/>
                    </valueSets>
                </xsl:result-document>
            </xsl:if>
        </xsl:for-each-group>
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
                <codeSystems>
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
                    <codeSystems>
                        <xsl:copy-of select="."/>
                    </codeSystems>
                </xsl:result-document>
            </xsl:if>
        </xsl:for-each-group>
    </xsl:template>
</xsl:stylesheet>