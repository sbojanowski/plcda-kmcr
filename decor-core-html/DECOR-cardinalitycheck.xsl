<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    Copyright © ART-DECOR Expert Group and ART-DECOR Open Tools
    see https://art-decor.org/mediawiki/index.php?title=Copyright
    
    This program is free software; you can redistribute it and/or modify it under the terms 
    of the GNU General Public License as published by the Free Software Foundation; 
    either version 3 of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
    See the GNU General Public License for more details.
    
    See http://www.gnu.org/licenses/gpl.html
-->
<xsl:stylesheet xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:local="http://art-decor.org/functions" version="2.0" exclude-result-prefixes="#all">
    
    <!-- 
        distinguish between
        - elements with regular names (and process them appropriately) 
        - includes with references to a ruleset (include or contains)
        - choice
        Process regular elements with name or includes and choices here only
    --> 

    <xsl:template match="element" mode="cardinalitycheck">
        <xsl:param name="itemlabel"/>
        <xsl:param name="currentContext"/>
        <xsl:param name="seethisthingurl"/>
        <xsl:param name="sofar" as="xs:string*" required="yes"/>
        <xsl:param name="templateFormat" as="xs:string"/>
        <!-- 
            this is a normal element with possible cardinality and conformance to be checked in current context
            
            examples:
            <element name="hl7:xx" minimumMultiplicity="1" maximumMultiplicity="1" isMandatory="true">
            <element name="hl7:yy" minimumMultiplicity="0" maximumMultiplicity="1">
            <element name="hl7:zz" conformance="NP">
        
        -->
        <!-- 
            don't do the predicated check for elements with a @strength that is liberating the actual content: we can't test that with predicate, do just the element name 
        -->
        <xsl:variable name="doInfoOnLooseStrength" select="self::element[@strength=('CWE','extensible','preferred','example')]"/>
        <xsl:variable name="theName">
            <xsl:call-template name="getWherePathFromNodeset">
                <xsl:with-param name="rccontent" select="."/>
                <xsl:with-param name="sofar" select="()"/>
                <xsl:with-param name="templateFormat" select="$templateFormat"/>
            </xsl:call-template>
        </xsl:variable>

        <!-- if theName is not empty then we found a ruleset -->
        <xsl:variable name="validRuleset" select="string-length($theName)>0"/>

        <xsl:choose>
            <xsl:when test="$validRuleset=false()">
                <!-- give up? if name is empty, for example because the include/contains ruleset cannot be found -->
                <xsl:call-template name="logMessage">
                    <xsl:with-param name="level" select="$logERROR"/>
                    <xsl:with-param name="msg">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'CannotFindOrEmptyTemplate'"/>
                            <xsl:with-param name="p1" select="concat(@contains,@ref)"/>
                            <xsl:with-param name="p2" select="$itemlabel"/>
                            <xsl:with-param name="p3" select="$currentContext"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <!-- name set, continue -->

                <!--
                    OBSOLETE: discourage it
                    solve references to concept defintions regarding multiplicity, conformance 
                    caught with a schema error also
                -->
                <xsl:if test="count(references)>0">
                    <xsl:call-template name="logMessage">
                        <xsl:with-param name="level" select="$logWARN"/>
                        <xsl:with-param name="msg">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'ErrorTemplateElementReferencesFound'"/>
                            </xsl:call-template>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:if>
                
                <xsl:variable name="minimumMultiplicityAttr">
                    <xsl:choose>
                        <xsl:when test="string-length(@minimumMultiplicity)>0">
                            <xsl:value-of select="@minimumMultiplicity"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="0"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="maximumMultiplicityAttr">
                    <xsl:choose>
                        <xsl:when test="string-length(@maximumMultiplicity)>0">
                            <xsl:value-of select="@maximumMultiplicity"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'*'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="isMandatoryAttr">
                    <xsl:choose>
                        <xsl:when test="string-length(@isMandatory)>0">
                            <xsl:value-of select="@isMandatory"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'false'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="conformanceAttr">
                    <xsl:choose>
                        <xsl:when test="string-length(@conformance)>0">
                            <xsl:value-of select="@conformance"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="0"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <!-- nullFlavorAllowed creates schematron xpath expression to be included later -->
                <!--<xsl:variable name="nullFlavorAllowed">
                    <xsl:if test="$isMandatory = 'true'">
                        <xsl:text>[not(@nullFlavor)]</xsl:text>
                    </xsl:if>
                </xsl:variable>-->

                <!-- create asserts for minimumMultiplicity -->
                <xsl:if test="$minimumMultiplicityAttr and $minimumMultiplicityAttr>0">
                    <xsl:choose>
                        <xsl:when test="$doInfoOnLooseStrength">
                            <xsl:choose>
                                <xsl:when test="self::element/@strength=('CWE','extensible','preferred')">
                                    <report role="warning" see="{$seethisthingurl}" test="count({$theName})&lt;{$minimumMultiplicityAttr}">
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="'minCardInfo1'"/>
                                            <xsl:with-param name="p1" select="$itemlabel"/>
                                            <xsl:with-param name="p2" select="@name"/>
                                            <xsl:with-param name="p3" select="self::element/@strength"/>
                                        </xsl:call-template>
                                    </report>
                                </xsl:when>
                                <xsl:otherwise>
                                    <!-- on example binding only info -->
                                    <report role="information" see="{$seethisthingurl}" test="count({$theName})&lt;{$minimumMultiplicityAttr}">
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="'minCardInfo2'"/>
                                            <xsl:with-param name="p1" select="$itemlabel"/>
                                            <xsl:with-param name="p2" select="@name"/>
                                            <xsl:with-param name="p3" select="self::element/@strength"/>
                                        </xsl:call-template>
                                    </report>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <assert role="error" see="{$seethisthingurl}" test="count({$theName})>={$minimumMultiplicityAttr}">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'minCard'"/>
                                    <xsl:with-param name="p1" select="$itemlabel"/>
                                    <xsl:with-param name="p2">
                                        <xsl:value-of select="$theName"/>
                                        <xsl:if test="item/@desc">
                                            <xsl:text> (</xsl:text>
                                            <xsl:value-of select="item/@desc"/>
                                            <xsl:text>) </xsl:text>
                                        </xsl:if>
                                    </xsl:with-param>
                                    <xsl:with-param name="p3">
                                        <xsl:choose>
                                            <xsl:when test="$isMandatoryAttr='true'">
                                                <xsl:text>mandatory</xsl:text>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:text>required</xsl:text>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:with-param>
                                    <xsl:with-param name="p4" select="$minimumMultiplicityAttr"/>
                                </xsl:call-template>
                            </assert>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
                <!-- create asserts for maximumMultiplicity -->
                <xsl:if test="$maximumMultiplicityAttr and $maximumMultiplicityAttr!='*'">
                    <assert role="error" see="{$seethisthingurl}" test="count({$theName})&lt;={$maximumMultiplicityAttr}">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'maxCard'"/>
                            <xsl:with-param name="p1" select="$itemlabel"/>
                            <xsl:with-param name="p2">
                                <xsl:value-of select="$theName"/>
                                <xsl:if test="item/@desc">
                                    <xsl:text> (</xsl:text>
                                    <xsl:value-of select="item/@desc"/>
                                    <xsl:text>) </xsl:text>
                                </xsl:if>
                            </xsl:with-param>
                            <xsl:with-param name="p3" select="$maximumMultiplicityAttr"/>
                        </xsl:call-template>
                    </assert>
                </xsl:if>
                <!-- create asserts for conformance NP not present -->
                <xsl:if test="$conformanceAttr='NP'">
                    <assert role="error" see="{$seethisthingurl}" test="count({$theName})=0">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'elmProhibited'"/>
                            <xsl:with-param name="p1" select="$itemlabel"/>
                            <xsl:with-param name="p2" select="$theName"/>
                        </xsl:call-template>
                    </assert>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>


    </xsl:template>

    <xsl:template match="include" mode="cardinalitycheck">
        <xsl:param name="itemlabel"/>
        <xsl:param name="currentContext"/>
        <xsl:param name="seethisthingurl"/>
        <xsl:param name="sofar" as="xs:string*" required="yes"/>
        <xsl:param name="templateFormat" as="xs:string"/>
        
        <!-- 
            this is an include, possible to have recursion in it, also choices
            get a list of top level elements to be checked regarding cardinality and conformance in current context
            
            examples:
            
            assume template A has 1 single top level element hl7:xx then
            <include ref="A" minimumMultiplicity="1" maximumMultiplicity="1" isMandatory="true">
            checks cardinalities: hl7:xx 1..1 M and overrides any card/conf given on hl7:xx
            
            assume template A has 2 top level element hl7:xx and hl7:yy then
            <include ref="A" minimumMultiplicity="1" maximumMultiplicity="1" isMandatory="true">
            checks cardinalities: the given card/conf for hl7:xx and hl7:yy if any
            CAVE: the card/conf at the include element is ignored as there are two elements in A, emit a processing warning, though
            
            assume template A has 2 top level includes B and C, both having 1 single top level element hl7:xx or hl7:yy respectively then
            <include ref="A" minimumMultiplicity="1" maximumMultiplicity="1" isMandatory="true">
            checks cardinalities: the given card/conf for hl7:xx from B and hl7:yy from C if any
            CAVE: the card/conf at the include element is ignored as there are two overall included elements in A, emit a processing warning, though
        
        -->
        
        <!-- lookup contained template content -->
        <xsl:variable name="rc">
            <xsl:call-template name="getRulesetContent">
                <xsl:with-param name="ruleset" select="@ref"/>
                <xsl:with-param name="flexibility" select="@flexibility"/>
                <xsl:with-param name="sofar" select="()"/>
            </xsl:call-template>
        </xsl:variable>
        
        <!-- cache card/conf of the include element -->
        <xsl:variable name="min" select="@minimumMultiplicity"/>
        <xsl:variable name="max" select="@maximumMultiplicity"/>
        <xsl:variable name="conf" select="@conformance"/>
        <xsl:variable name="mand" select="@isMandatory"/>
        
        <!-- process elements in template and override their card/conf/mand with that of the include, if any -->
        <xsl:for-each select="$rc/*/element|$rc/*/include|$rc/*/choice">
            <xsl:variable name="rcsub" as="element()">
                <xsl:element name="{name(.)}">
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="templateformat" select="local:getTemplateFormat(ancestor-or-self::template[1])"/>
                    <xsl:if test="string-length($min)>0">
                        <xsl:attribute name="minimumMultiplicity" select="$min"/>
                        <xsl:attribute name="minimumOverride"/>
                    </xsl:if>
                    <xsl:if test="string-length($max)>0">
                        <xsl:attribute name="maximumMultiplicity" select="$max"/>
                        <xsl:attribute name="maximumOverride"/>
                    </xsl:if>
                    <xsl:if test="string-length($conf)>0">
                        <xsl:attribute name="conformance" select="$conf"/>
                        <xsl:attribute name="conformanceOverride"/>
                    </xsl:if>
                    <xsl:if test="string-length($mand)>0">
                        <xsl:attribute name="isMandatory" select="$mand"/>
                        <xsl:attribute name="isMandatoryOverride"/>
                    </xsl:if>
                    <xsl:copy-of select="*"/>
                </xsl:element>
            </xsl:variable>
            
            <xsl:apply-templates select="$rcsub" mode="cardinalitycheck">
                <xsl:with-param name="itemlabel" select="$itemlabel"/>
                <xsl:with-param name="currentContext" select="$currentContext"/>
                <xsl:with-param name="seethisthingurl" select="$seethisthingurl"/>
                <xsl:with-param name="sofar" select="$sofar"/>
                <xsl:with-param name="templateFormat" select="$templateFormat"/>
            </xsl:apply-templates>
        </xsl:for-each>  
    </xsl:template>

    <xsl:template match="choice" mode="cardinalitycheck">
        <xsl:param name="itemlabel"/>
        <xsl:param name="currentContext"/>
        <xsl:param name="seethisthingurl"/>
        <xsl:param name="sofar" as="xs:string*" required="yes"/>
        <xsl:param name="templateFormat" as="xs:string"/>
        
        <!-- 
            this is a choice, possible to have recursion in it, also includes
            get a list of top level elements of the choice to be checked regarding cardinality and conformance in current context
            CAVE: it may contain includes
        -->
        
        <!-- cache card of the choice element -->
        <xsl:variable name="min" select="@minimumMultiplicity[string-length()>0]"/>
        <xsl:variable name="max" select="@maximumMultiplicity[string-length()>0]"/>
        <xsl:variable name="minoverride" select="@minimumOverride"/>
        <xsl:variable name="maxoverride" select="@maximumOverride"/>
        
        <xsl:variable name="childmintotal" select="sum((element|include|choice)[@minimumMultiplicity castable as xs:integer]/xs:integer(@minimumMultiplicity))" as="xs:integer?"/>
        
        <xsl:if test="$min and $min castable as xs:integer and $childmintotal and $childmintotal > xs:integer($min)">
            <xsl:call-template name="logMessage">
                <xsl:with-param name="level" select="$logWARN"/>
                <xsl:with-param name="msg">
                    <xsl:text>+++ </xsl:text>
                    <xsl:value-of select="name()"/>
                    <xsl:text>/@minimumMultiplicity='</xsl:text>
                    <xsl:value-of select="$min"/>
                    <xsl:text>'</xsl:text>
                    <xsl:if test="$minoverride">
                        <xsl:text> (via include override)</xsl:text>
                    </xsl:if>
                    <xsl:text> is lower than the sum of minimumMultiplicities of its constituents: </xsl:text>
                    <xsl:value-of select="$childmintotal"/>
                    <xsl:text>'. context: </xsl:text>
                    <xsl:value-of select="$currentContext"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        
        <xsl:if test="string-length(concat($min, $max))>0">
            
            <xsl:variable name="allTopLevelElements">
                <xsl:for-each select="element|include|choice">
                    <xsl:choose>
                        <xsl:when test="name() = 'element'">
                            <!-- simple element, just copy it -->
                            <xsl:copy-of select="."/>
                        </xsl:when>
                        <xsl:when test="name() = 'include'">
                            <!-- include, get all top level elements -->
                            <!-- NOTE (AH): Could retrieve nested choice from included template here too... FIXME? -->
                            <xsl:call-template name="getTopLevelElementsFromInclude">
                                <xsl:with-param name="currentContext" select="."/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="logMessage">
                                <xsl:with-param name="level" select="$logERROR"/>
                                <xsl:with-param name="msg">
                                    <xsl:text>+++ Nested choice inside choice is NOT supported, context: </xsl:text>
                                    <xsl:value-of select="$currentContext"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:variable>
            
            <xsl:variable name="elemsinchoice">
                <xsl:for-each select="$allTopLevelElements/*">
                    
                    <!--
                    <xsl:message>
                        <xsl:text>CHOICE </xsl:text>
                        <xsl:value-of select="@name"/>
                        <xsl:text> :: </xsl:text>
                        <xsl:call-template name="getWherePathFromNodeset">
                            <xsl:with-param name="rccontent" select="."/>
                            <xsl:with-param name="templateFormat" select="$templateFormat"/>
                        </xsl:call-template>
                    </xsl:message>
                    -->
                    <xsl:call-template name="getWherePathFromNodeset">
                        <xsl:with-param name="rccontent" select="."/>
                        <xsl:with-param name="sofar" select="()"/>
                        <xsl:with-param name="templateFormat" select="$templateFormat"/>
                    </xsl:call-template>
                    
                    <xsl:if test="position()!=last()">
                        <xsl:text> | </xsl:text>
                    </xsl:if>

                </xsl:for-each>
            </xsl:variable>

            <let name="elmcount" value="count({$elemsinchoice})"/>

            <xsl:variable name="ors">
                <xsl:text> </xsl:text>
                <xsl:call-template name="getMessage">
                    <xsl:with-param name="key" select="'orWord'"/>
                </xsl:call-template>
                <xsl:text> </xsl:text>
            </xsl:variable>

            <xsl:if test="@minimumMultiplicity>0">
                <assert role="error" see="{$seethisthingurl}" test="$elmcount>={@minimumMultiplicity}">
                    <xsl:call-template name="getMessage">
                        <xsl:with-param name="key" select="'choiceNotEnough'"/>
                        <xsl:with-param name="p1" select="$itemlabel"/>
                        <xsl:with-param name="p2">
                            <xsl:value-of select="replace($elemsinchoice, '\|', $ors)"/>
                        </xsl:with-param>
                        <xsl:with-param name="p3" select="@minimumMultiplicity"/>
                    </xsl:call-template>
                </assert>
            </xsl:if>
            <xsl:if test="@maximumMultiplicity!='*'">
                <assert role="error" see="{$seethisthingurl}" test="$elmcount&lt;={@maximumMultiplicity}">
                    <xsl:call-template name="getMessage">
                        <xsl:with-param name="key" select="'choiceTooMany'"/>
                        <xsl:with-param name="p1" select="$itemlabel"/>
                        <xsl:with-param name="p2">
                            <xsl:value-of select="replace($elemsinchoice, '\|', $ors)"/>
                        </xsl:with-param>
                        <xsl:with-param name="p3" select="@maximumMultiplicity"/>
                    </xsl:call-template>
                </assert>
            </xsl:if>
        </xsl:if>
        
        <!-- process elements in choice and check their card with that of the choice, if any -->
        <!-- NOTE (AH): What does it mean when a choice has min=0 and element min=1, or choice has max=2 and element has max=3? -->
        <xsl:for-each select="element|include|choice">
            <xsl:variable name="childmin" select="@minimumMultiplicity[string-length()>0]"/>
            <xsl:variable name="childmax" select="@maximumMultiplicity[string-length()>0]"/>
            
            <xsl:if test="$min castable as xs:integer and $childmin">
                <xsl:if test="(not($childmin = '*') and xs:integer($childmin) > xs:integer($min)) or $childmin = '*'">
                    <xsl:call-template name="logMessage">
                        <xsl:with-param name="level" select="$logWARN"/>
                        <xsl:with-param name="msg">
                            <xsl:text>+++ Found </xsl:text>
                            <xsl:value-of select="name()"/>
                            <xsl:text>/@minimumMultiplicity='</xsl:text>
                            <xsl:value-of select="$childmin"/>
                            <xsl:text>' that is higher than the parent choice/@minimumMultiplicity '</xsl:text>
                            <xsl:value-of select="$min"/>
                            <xsl:text>'</xsl:text>
                            <xsl:if test="$minoverride">
                                <xsl:text> (via include override)</xsl:text>
                            </xsl:if>
                            <xsl:text>. context: </xsl:text>
                            <xsl:value-of select="$currentContext"/>
                            <xsl:text>. &lt;</xsl:text>
                            <xsl:value-of select="name()"/>
                            <xsl:for-each select="@*">
                                <xsl:value-of select="concat(' ',name(),'=&quot;',.,'&quot;')"/>
                            </xsl:for-each>
                            <xsl:text>/&gt;</xsl:text>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:if>
            </xsl:if>
            <xsl:if test="$max castable as xs:integer and $childmax">
                <xsl:if test="(not($childmax = '*') and xs:integer($childmax) > xs:integer($max)) or $childmax = '*'">
                    <xsl:call-template name="logMessage">
                        <xsl:with-param name="level" select="$logWARN"/>
                        <xsl:with-param name="msg">
                            <xsl:text>+++ Found </xsl:text>
                            <xsl:value-of select="name()"/>
                            <xsl:text>/@maximumMultiplicity='</xsl:text>
                            <xsl:value-of select="$childmax"/>
                            <xsl:text>' that is higher than the parent choice/@maximumMultiplicity '</xsl:text>
                            <xsl:value-of select="$max"/>
                            <xsl:text>'</xsl:text>
                            <xsl:if test="$maxoverride">
                                <xsl:text> (via include override)</xsl:text>
                            </xsl:if>
                            <xsl:text>. context: </xsl:text>
                            <xsl:value-of select="$currentContext"/>
                            <xsl:text>. &lt;</xsl:text>
                            <xsl:value-of select="name()"/>
                            <xsl:for-each select="@*">
                                <xsl:value-of select="concat(' ',name(),'=&quot;',.,'&quot; ')"/>
                            </xsl:for-each>
                            <xsl:text>/&gt;</xsl:text>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:if>
            </xsl:if>
            
            <xsl:if test="string-length(@minimumMultiplicity) >0 or string-length(@maximumMultiplicity) >0">
                <xsl:apply-templates select="." mode="cardinalitycheck">
                    <xsl:with-param name="itemlabel" select="$itemlabel"/>
                    <xsl:with-param name="currentContext" select="$currentContext"/>
                    <xsl:with-param name="seethisthingurl" select="$seethisthingurl"/>
                    <xsl:with-param name="sofar" select="$sofar"/>
                    <xsl:with-param name="templateFormat" select="$templateFormat"/>
                </xsl:apply-templates>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="getTopLevelElementsFromInclude">
        <xsl:param name="currentContext"/>
        <!-- 
            get all top level elements from an include statement
            context shall be an include element with a ref
        -->
        <xsl:variable name="rccontent">
            <xsl:call-template name="getRulesetContent">
                <xsl:with-param name="ruleset" select="$currentContext/@ref"/>
                <xsl:with-param name="flexibility" select="$currentContext/@flexibility"/>
                <xsl:with-param name="sofar" select="()"/>
            </xsl:call-template>
        </xsl:variable>
        
         <xsl:for-each select="$rccontent/*/(element|include|choice)">
            <xsl:choose>
                <xsl:when test="name() = 'element'">
                    <!-- a top level element, copy it -->
                    <xsl:copy-of select="."/>
                </xsl:when>
                <xsl:when test="name() = 'include'">
                    <!-- another include, process it -->
                    <xsl:call-template name="getTopLevelElementsFromInclude">
                        <xsl:with-param name="currentContext" select="."/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="name() = 'choice'">
                    <!-- a choice, checked elsewhere???? -->
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
