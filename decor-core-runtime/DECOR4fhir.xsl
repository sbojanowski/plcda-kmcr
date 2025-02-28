<!-- 
    ART-DECOR® STANDARD COPYRIGHT AND LICENSE NOTE
    Copyright © ART-DECOR Expert Group and ART-DECOR Open Tools GmbH
    see https://docs.art-decor.org/copyright and https://docs.art-decor.org/licenses

    This file is part of the ART-DECOR® tools suite.    
-->
<xsl:stylesheet xmlns:xforms="http://www.w3.org/2002/xforms" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:f="http://hl7.org/fhir" xmlns:diff="http://art-decor.org/ns/decor/diff" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:uuid="java:java.util.UUID" xmlns:local="http://art-decor.org/functions" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.0" exclude-result-prefixes="#all">
    <xsl:param name="fhir-external-exist" select="''"/>
    <!-- 
    
    -->
    <xsl:variable name="fWidth" select="'20em'"/>
    <!-- 
    
    -->
    <xsl:template match="f:StructureDefinition">
        <!-- what view to generate -->
        <xsl:param name="view" as="xs:string" select="if (f:snapshot) then 'snapshot' else 'differential'"/>
        <!-- 
        
        -->
        <table xmlns="http://www.w3.org/1999/xhtml" width="100%" border="0" cellspacing="3" cellpadding="2">
            <tbody>
                <!-- issues -->
                <xsl:call-template name="check4Issue">
                    <xsl:with-param name="id" select="@id"/>
                    <xsl:with-param name="effectiveDate" select="@effectiveDate"/>
                    <xsl:with-param name="colspans" select="3"/>
                </xsl:call-template>
                <!-- 
                    preliminaries
                -->
                <xsl:apply-templates select="." mode="showpreliminaries"/>
                <tr style="vertical-align: top;">
                    <td colspan="4">
                        <xsl:choose>
                            <xsl:when test="(f:snapshot|f:differential)/f:element">
                                <div id="tab-container" class="tab-container">
                                    <ul class="etabs">
                                        <xsl:if test="f:snapshot/f:element">
                                            <li class="tab">
                                                <a href="#tabs1-snapshot">Snapshot</a>
                                            </li>
                                        </xsl:if>
                                        <xsl:if test="f:differential/f:element">
                                            <li class="tab">
                                                <a href="#tabs1-differential">Differential</a>
                                            </li>
                                        </xsl:if>
                                        <li class="tab">
                                            <a href="#tabs1-details">Details</a>
                                        </li>
                                        <li class="tab">
                                            <a href="#tabs1-table">Table</a>
                                        </li>
                                        <li class="tab">
                                            <a href="#tabs1-xml">XML</a>
                                        </li>
                                    </ul>
                                    <xsl:if test="f:snapshot/f:element">
                                        <div id="tabs1-snapshot">
                                            <!--<xsl:if test="$switchCreateTreeTableHtml = 'true'">
                                                <div>
                                                    <button id="expandAll" type="button">
                                                        <xsl:call-template name="getMessage">
                                                            <xsl:with-param name="key" select="'buttonExpandAll'"/>
                                                        </xsl:call-template>
                                                    </button>
                                                    <button id="collapseAll" type="button">
                                                        <xsl:call-template name="getMessage">
                                                            <xsl:with-param name="key" select="'buttonCollapseAll'"/>
                                                        </xsl:call-template>
                                                    </button>
                                                    <input id="nameSearch">
                                                        <xsl:attribute name="placeholder">
                                                            <xsl:call-template name="getMessage">
                                                                <xsl:with-param name="key" select="'textSearch'"/>
                                                            </xsl:call-template>
                                                        </xsl:attribute>
                                                    </input>
                                                </div>
                                            </xsl:if>-->
                                            <table id="transactionTable" class="treetable" width="100%" border="0" cellspacing="3" cellpadding="2">
                                                <thead>
                                                    <xsl:call-template name="doHeader"/>
                                                </thead>
                                                <!-- do the elements -->
                                                <xsl:variable name="conceptmaps" select="ancestor::structuredefinition/concept"/>
                                                <tbody class="list">
                                                    <xsl:variable name="elements">
                                                        <xsl:copy-of select="f:snapshot/f:element" copy-namespaces="yes"/>
                                                    </xsl:variable>
                                                    <xsl:for-each select="$elements/*">
                                                        <xsl:variable name="id" select="@id"/>
                                                        <xsl:variable name="mappings" select="$conceptmaps[@elementId = $id]"/>
                                                        <xsl:apply-templates select="." mode="overview">
                                                            <xsl:with-param name="mappings" select="$mappings"/>
                                                            <xsl:with-param name="level" select="0"/>
                                                            <xsl:with-param name="parent-id" select="''"/>
                                                        </xsl:apply-templates>
                                                    </xsl:for-each>
                                                </tbody>
                                            </table>
                                        </div>
                                    </xsl:if>
                                    <xsl:if test="f:differential/f:element">
                                        <div id="tabs1-differential">
                                            <table id="transactionTable" class="treetable" width="100%" border="0" cellspacing="3" cellpadding="2">
                                                <thead>
                                                    <xsl:call-template name="doHeader"/>
                                                </thead>
                                                <tbody class="list">
                                                    <!-- do the elements -->
                                                    <xsl:variable name="conceptmaps" select="ancestor::structuredefinition/concept"/>
                                                    <xsl:variable name="elements">
                                                        <xsl:copy-of select="f:differential/f:element" copy-namespaces="yes"/>
                                                    </xsl:variable>
                                                    <xsl:for-each select="$elements/*">
                                                        <xsl:variable name="id" select="@id"/>
                                                        <xsl:variable name="mappings" select="$conceptmaps[@elementId = $id]"/>
                                                        <xsl:apply-templates select="." mode="overview">
                                                            <xsl:with-param name="mappings" select="$mappings"/>
                                                            <xsl:with-param name="level" select="0"/>
                                                            <xsl:with-param name="parent-id" select="''"/>
                                                        </xsl:apply-templates>
                                                    </xsl:for-each>
                                                </tbody>
                                            </table>
                                        </div>
                                    </xsl:if>
                                    <div id="tabs1-details">
                                        <table id="transactionTable" class="treetable zebra-table" style="border: 1px solid #F2F2F2;" width="100%" border="0" cellspacing="3" cellpadding="2">
                                            <thead>
                                                
                                            </thead>
                                            <tbody class="list">
                                                <xsl:variable name="elements" as="element()*">
                                                    <xsl:choose>
                                                        <xsl:when test="f:snapshot/f:element">
                                                            <xsl:copy-of select="f:snapshot/f:element" copy-namespaces="yes"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:copy-of select="f:differential/f:element" copy-namespaces="yes"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:variable>
                                                <xsl:apply-templates select="$elements[not(f:slicing)]" mode="details"/>
                                            </tbody>
                                        </table>
                                    </div>
                                    <div id="tabs1-table">
                                        <table id="transactionTable" class="treetable zebra-table" style="border: 1px solid #999;" width="100%" border="0" cellspacing="3" cellpadding="2">
                                            <thead>
                                               
                                            </thead>
                                            <tbody class="list">
                                                <xsl:variable name="elements" as="element()*">
                                                    <xsl:choose>
                                                        <xsl:when test="f:snapshot/f:element">
                                                            <xsl:copy-of select="f:snapshot/f:element" copy-namespaces="yes"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:copy-of select="f:differential/f:element" copy-namespaces="yes"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:variable>
                                                <xsl:apply-templates select="$elements" mode="table">
                                                    <xsl:with-param name="bgcolor" select="if (position() mod 2 = 0) then '#eee' else '#fff'"/>
                                                </xsl:apply-templates>
                                            </tbody>
                                        </table>
                                    </div>
                                    <div id="tabs1-xml">
                                        <xsl:apply-templates select="." mode="explrender"/>
                                    </div>
                                </div>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>No elements defined</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </td>
                </tr>
            </tbody>
        </table>
    </xsl:template>
    <!-- 
        redefinition of a single element
    -->
    <xsl:template match="f:element" mode="details">
        <!-- 
        -->
        <xsl:variable name="elementId" select="@id"/>
        <xsl:variable name="path" select="f:path/@value"/>
        <tr xmlns="http://www.w3.org/1999/xhtml" style="border: 0px; padding: 0px; background-color: #EFEFEF;">
            <td colspan="2" style="font-weight: bold;">
                <xsl:value-of select="$path"/>
            </td>
        </tr>
        <xsl:if test="f:definition">
            <tr xmlns="http://www.w3.org/1999/xhtml">
                <td style="padding-right: 2em;">Definition</td>
                <td>
                    <xsl:value-of select="f:definition/@value"/>
                </td>
            </tr>
        </xsl:if>
        <xsl:if test="f:min | f:max">
            <tr xmlns="http://www.w3.org/1999/xhtml">
                <td style="padding-right: 2em;">Control</td>
                <td>
                    <xsl:value-of select="f:min/@value"/>...<xsl:value-of select="f:max/@value"/>
                </td>
            </tr>
        </xsl:if>
        <xsl:if test="f:binding">
            <tr xmlns="http://www.w3.org/1999/xhtml">
                <td style="padding-right: 2em;">Binding</td>
                <td>
                    <xsl:for-each select="f:binding">
                        <div>
                            <xsl:value-of select="f:description/@value"/>
                        </div>
                        <div>
                            <xsl:choose>
                                <xsl:when test="f:strength[@value = 'required']">
                                    <xsl:text>The codes SHALL be taken from </xsl:text>
                                </xsl:when>
                                <xsl:when test="f:strength[@value = 'preferred']">
                                    <xsl:text>The codes SHOULD be taken from </xsl:text>
                                </xsl:when>
                                <xsl:when test="f:strength[@value = 'extensible']">
                                    <xsl:text>The codes SHOULD be taken from </xsl:text>
                                </xsl:when>
                                <xsl:when test="f:strength[@value = 'extensible']">
                                    <xsl:text>Examples of codes be found in </xsl:text>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:choose>
                                <xsl:when test="f:valueSetReference[f:reference]">
                                    <a href="{f:valueSetReference/f:reference/@value}" title="{f:valueSetReference/f:reference/@value}">
                                        <xsl:choose>
                                            <xsl:when test="f:valueSetReference[f:display]">
                                                <xsl:value-of select="f:valueSetReference/f:display/@value"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="f:valueSetReference/f:reference/@value"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </a>
                                </xsl:when>
                                <xsl:when test="f:valueSetReference[f:identifier]">
                                    <i>TODO reference by identifier</i>
                                </xsl:when>
                            </xsl:choose>
                        </div>
                    </xsl:for-each>
                </td>
            </tr>
        </xsl:if>
        <xsl:if test="f:type">
            <tr xmlns="http://www.w3.org/1999/xhtml">
                <td style="padding-right: 2em;">Type</td>
                <td>
                    <xsl:if test="count(f:type) gt 1">
                        <xsl:text>Choice of: </xsl:text>
                    </xsl:if>
                    <xsl:for-each select="f:type">
                        <xsl:choose>
                            <xsl:when test="f:code[@value = 'Reference']">
                                <xsl:text>Reference(</xsl:text>
                                <a href="{f:targetProfile/@value}" title="{f:targetProfile/@value}">
                                    <xsl:value-of select="f:targetProfile/tokenize(@value, '/')[last()]"/>
                                </a>
                                <xsl:text>)</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="f:code/@value"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="f:profile">
                            <xsl:text> (</xsl:text>
                            <a href="{f:profile/@value}" title="{f:profile/@value}">
                                <xsl:value-of select="f:profile/tokenize(@value, '/')[last()]"/>
                            </a>
                            <xsl:text>)</xsl:text>
                        </xsl:if>
                        <xsl:if test="position() != last()">
                            <xsl:text> | </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </td>
            </tr>
        </xsl:if>
        <xsl:if test="f:isModifier">
            <tr xmlns="http://www.w3.org/1999/xhtml">
                <td style="padding-right: 2em;">Is modifier</td>
                <td>
                    <xsl:value-of select="f:isModifier/@value"/>
                </td>
            </tr>
        </xsl:if>
        <xsl:if test="f:isSummary">
            <tr xmlns="http://www.w3.org/1999/xhtml">
                <td style="padding-right: 2em;">Is summary</td>
                <td>
                    <xsl:value-of select="f:isSummary/@value"/>
                </td>
            </tr>
        </xsl:if>
        <xsl:if test="f:alias">
            <tr xmlns="http://www.w3.org/1999/xhtml">
                <td style="padding-right: 2em;">Alternate Names</td>
                <td>
                    <xsl:value-of select="string-join(f:alias/@value, ', ')"/>
                </td>
            </tr>
        </xsl:if>
        <xsl:if test="f:comments">
            <tr xmlns="http://www.w3.org/1999/xhtml">
                <td style="padding-right: 2em;">Comments</td>
                <td>
                    <xsl:value-of select="f:comments/@value"/>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>
    <xsl:template match="f:element" mode="overview">
        <xsl:param name="mappings"/>
        <!-- 
        
        -->
        <xsl:variable name="elementId" select="@id"/>
        <xsl:variable name="path" select="f:path/@value"/>
        <xsl:variable name="currentIsSlice" select="if (preceding-sibling::f:element[f:slicing]/f:path[starts-with($path,@value)]) then 1 else 0"/>
        <xsl:variable name="dotcnt" select="count(tokenize($path,'\.')) + $currentIsSlice"/>
        <xsl:variable name="nextcnt" select="for $fs in ./following-sibling::f:element/f:path return if ($fs[starts-with(@value,$path)]) then ($fs/count(tokenize(@value,'\.')) + 1) else ($fs/count(tokenize(@value,'\.')))"/>
        <xsl:variable name="nextdotcnt" select="$nextcnt[1]"/>
        <xsl:variable name="imgbck" select="string-join(('tbl_bck',if ($dotcnt &lt; 2) then '0' else (), for $i in (2 to $dotcnt) return if (count(index-of($nextcnt, $i)) &gt; 0 and (count(index-of($nextcnt, $i - 1)) = 0 or index-of($nextcnt, $i)[1] &lt; index-of($nextcnt, $i - 1)[1])) then '1' else '0','.png'),'')"/>
        <xsl:variable name="img" select="if (ends-with($imgbck, '0.png')) then 'tbl_vjoin_end.png' else 'tbl_vjoin.png'"/>
        <xsl:variable name="basepath" select="f:base/f:path/@value"/>
        <xsl:variable name="fontcolor">
            <xsl:choose>
                <xsl:when test="starts-with($basepath, 'Resource.')">color:grey;</xsl:when>
                <xsl:when test="starts-with($basepath, 'Element.')">color:grey;</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="strikethrough">
            <xsl:if test="f:max/@value='0'">text-decoration: line-through</xsl:if>
        </xsl:variable>
        <tr xmlns="http://www.w3.org/1999/xhtml" style="border: 0px; padding: 0px; vertical-align: top; {if (ends-with($basepath, '.id')) then 'display:none;' else ()}" class="zebra-row-{if (position() mod 2 = 0) then 'even' else 'odd'}">
            <td style="vertical-align: top; text-align : left; background-color: white; border: 0px #F0F0F0 solid; padding:0px 4px 0px 4px; white-space: nowrap; background-image: url('http://hl7.org/fhir/{$imgbck}')" class="hierarchy">
                <img alt="." class="hierarchy" src="http://hl7.org/fhir/tbl_spacer.png"/>
                <!--
                <xsl:if test="$dotcnt = 1">
                    <img style="background-color: inherit" alt="." class="hierarchy" src="http://hl7.org/fhir/{$img}"/>
                </xsl:if>
                -->
                <xsl:if test="$dotcnt = 2">
                    <img style="background-color: inherit" alt="." class="hierarchy" src="http://hl7.org/fhir/{$img}"/>
                </xsl:if>
                <xsl:if test="$dotcnt = 3">
                    <img alt="." class="hierarchy" src="http://hl7.org/fhir/tbl_blank.png"/>
                    <img style="background-color: inherit" alt="." class="hierarchy" src="http://hl7.org/fhir/{$img}"/>
                </xsl:if>
                <xsl:if test="$dotcnt = 4">
                    <img alt="." class="hierarchy" src="http://hl7.org/fhir/tbl_blank.png"/>
                    <img alt="." class="hierarchy" src="http://hl7.org/fhir/tbl_blank.png"/>
                    <img style="background-color: inherit" alt="." class="hierarchy" src="http://hl7.org/fhir/{$img}"/>
                </xsl:if>
                <xsl:if test="$dotcnt = 5">
                    <img alt="." class="hierarchy" src="http://hl7.org/fhir/tbl_blank.png"/>
                    <img alt="." class="hierarchy" src="http://hl7.org/fhir/tbl_blank.png"/>
                    <img alt="." class="hierarchy" src="http://hl7.org/fhir/tbl_blank.png"/>
                    <img style="background-color: inherit" alt="." class="hierarchy" src="http://hl7.org/fhir/{$img}"/>
                </xsl:if>
                <xsl:if test="$dotcnt = 6">
                    <img alt="." class="hierarchy" src="http://hl7.org/fhir/tbl_blank.png"/>
                    <img alt="." class="hierarchy" src="http://hl7.org/fhir/tbl_blank.png"/>
                    <img alt="." class="hierarchy" src="http://hl7.org/fhir/tbl_blank.png"/>
                    <img alt="." class="hierarchy" src="http://hl7.org/fhir/tbl_blank.png"/>
                    <img style="background-color: inherit" alt="." class="hierarchy" src="http://hl7.org/fhir/{$img}"/>
                </xsl:if>
                <xsl:if test="$dotcnt = 1 or f:type/f:code[@value='DomainResource']">
                    <img alt="." class="hierarchy" src="http://hl7.org/fhir/icon_resource.png">
                        <xsl:attribute name="title">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'fhir-resource'"/>
                            </xsl:call-template>
                        </xsl:attribute>
                    </img>
                </xsl:if>
                <xsl:if test="count(f:type)=0 and $dotcnt != 1 and not(f:slicing)">
                    <img alt="." class="hierarchy" src="http://hl7.org/fhir/icon_element.gif">
                        <xsl:attribute name="title">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'fhir-element'"/>
                            </xsl:call-template>
                        </xsl:attribute>
                    </img>
                </xsl:if>
                <xsl:if test="count(f:type)=0 and $dotcnt != 1 and f:slicing">
                    <img alt="." class="hierarchy" src="http://hl7.org/fhir/icon_slice.png">
                        <xsl:attribute name="title">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'fhir-slice-definition'"/>
                            </xsl:call-template>
                        </xsl:attribute>
                    </img>
                </xsl:if>
                <xsl:if test="count(f:type)=1 and $dotcnt != 1 and f:type/f:code[matches(@value,'^[a-z]')]">
                    <img alt="." class="hierarchy" src="http://hl7.org/fhir/icon_primitive.png">
                        <xsl:attribute name="title">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'fhir-primitive-datatype'"/>
                            </xsl:call-template>
                        </xsl:attribute>
                    </img>
                </xsl:if>
                <xsl:if test="count(f:type)=1 and $dotcnt != 1 and f:type/f:code[@value='Extension']">
                    <img alt="." class="hierarchy" src="http://hl7.org/fhir/icon_extension_simple.png">
                        <xsl:attribute name="title">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'fhir-simple-extension'"/>
                            </xsl:call-template>
                        </xsl:attribute>
                    </img>
                </xsl:if>
                <xsl:if test="count(f:type)=1 and $dotcnt != 1 and f:type/f:code[matches(@value,'^[A-Z]')] and not(f:type/f:code[@value=('DomainResource','Reference','Extension')])">
                    <img alt="." class="hierarchy" src="http://hl7.org/fhir/icon_datatype.gif">
                        <xsl:attribute name="title">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'fhir-datatype'"/>
                            </xsl:call-template>
                        </xsl:attribute>
                    </img>
                </xsl:if>
                <xsl:if test="count(f:type)&gt;=1 and $dotcnt != 1 and f:type/f:code[@value='Reference'] and not(f:type/f:code[not(@value='Reference')])">
                    <img alt="." class="hierarchy" src="http://hl7.org/fhir/icon_reference.png">
                        <xsl:attribute name="title">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'fhir-reference-to-another-resource'"/>
                            </xsl:call-template>
                        </xsl:attribute>
                    </img>
                </xsl:if>
                <xsl:if test="count(f:type)&gt;1 and $dotcnt != 1 and f:type[f:code[not(@value='Reference')]]">
                    <img alt="." class="hierarchy" src="http://hl7.org/fhir/icon_choice.gif">
                        <xsl:attribute name="title">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'fhir-choice-of-datatypes'"/>
                            </xsl:call-template>
                        </xsl:attribute>
                    </img>
                </xsl:if>
                <span title="{f:definition/@value}" style="margin-left: 5px; {$fontcolor} {$strikethrough}">
                    <xsl:value-of select="if (f:type[f:code/@value='Extension']/f:profile) then f:type[f:code/@value='Extension']/f:profile/tokenize(@value,'/')[last()] else f:path/tokenize(@value,'\.')[last()]"/>
                </span>
                <a name="{$path}"/>
            </td>
            <!-- modifier | summary | invariant -->
            <xsl:variable name="mtable">
                <xsl:if test="f:isModifier[@value='true']">
                    <td style="padding: 3px; color: #645a52; background-color: #fae3cf">
                        <xsl:attribute name="title">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'fhir-this-element-is-a-modifier'"/>
                            </xsl:call-template>
                        </xsl:attribute>
                        <xsl:text>?!</xsl:text>
                    </td> 
                </xsl:if>
                <xsl:if test="f:mustSupport[@value='true']">
                    <td style="padding: 3px; color: #ffe9e9; background-color: #ff9595">
                        <xsl:attribute name="title">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'fhir-this-element-must-be-supported'"/>
                            </xsl:call-template>
                        </xsl:attribute>
                        <xsl:text>S</xsl:text>
                    </td>
                </xsl:if>
                <xsl:if test="f:isSummary[@value='true']">
                    <td style="padding: 3px; color: #525c64; background-color: #cfe6fa">
                        <xsl:attribute name="title">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'fhir-this-element-is-included-in-summaries'"/>
                            </xsl:call-template>
                        </xsl:attribute>
                        <xsl:text>Σ</xsl:text>
                    </td> 
                </xsl:if>
                <xsl:if test="f:constraint">
                    <td style="padding: 3px; color: #52645a; background-color: #d1facf">
                        <xsl:attribute name="title">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'fhir-this-element-is-affected-by-contstraints'"/>
                            </xsl:call-template>
                        </xsl:attribute>
                        <xsl:text>I</xsl:text>
                    </td>
                </xsl:if>
            </xsl:variable>
            <td style="vertical-align: top; text-align : left; padding:0px 4px 0px 4px; {$fontcolor} {$strikethrough}" class="hierarchy">
                <xsl:if test="count($mtable/*)&gt;0">
                    <table>
                        <tr>
                            <xsl:copy-of select="$mtable/td"/>
                        </tr>
                    </table>
                </xsl:if>
            </td>
            <!-- cardinality -->
            <td style="vertical-align: top; text-align : left; padding:0px 4px 0px 4px; {$fontcolor} {$strikethrough}" class="hierarchy">
                <xsl:if test="f:min | f:max">
                    <xsl:value-of select="f:min/@value"/>…<xsl:value-of select="f:max/@value"/>
                </xsl:if>
            </td>
            <!-- type -->
            <td style="vertical-align: top; text-align : left; padding:0px 4px 0px 4px; {$strikethrough}" class="hierarchy">
                <xsl:if test="f:type[f:code/@value='Extension']">
                    <div>
                        <xsl:text>Extension</xsl:text>
                        <xsl:variable name="e" select="if (contains(@id, ':')) then tokenize(@id,':')[last()] else ()"/>
                        <xsl:if test="string-length($e)&gt;0">
                            <xsl:text> (</xsl:text>
                            <xsl:value-of select="$e"/>
                            <xsl:text>)</xsl:text>
                        </xsl:if>
                        <!--
                        <xsl:for-each select="f:type[f:code/@value='Extension']/f:profile/@value">
                            <a href="{$fhir-external-exist}/StructureDefinition?url={encode-for-uri(.)}">
                                <xsl:value-of select="concat(tokenize(.,'/')[last()], if (position()=last()) then () else ' | ')"/>
                            </a>
                        </xsl:for-each>
                        <xsl:text>)</xsl:text>
                        -->
                    </div>
                </xsl:if>
                <xsl:if test="f:type[f:code/@value='Reference']/f:targetProfile/@value">
                    <div>
                        <xsl:text>Reference (</xsl:text>
                        <xsl:for-each select="f:type[f:code/@value='Reference']/f:targetProfile/@value">
                            <a href="{$fhir-external-exist}/StructureDefinition?url={encode-for-uri(.)}">
                                <xsl:value-of select="concat(tokenize(.,'/')[last()], if (position()=last()) then () else ' | ')"/>
                            </a>
                        </xsl:for-each>
                        <xsl:text>)</xsl:text>
                    </div>
                </xsl:if>
                <xsl:if test="f:type[not(f:code/@value=('Extension','Reference'))]">
                    <div style="max-width:200px;">
                        <xsl:for-each select="f:type[not(f:code/@value=('Extension','Reference'))]">
                            <a href="{if (f:profile) then f:profile/@value else concat('http://hl7.org/fhir/',lower-case(f:code/@value),'.html')}">
                                <xsl:value-of select="concat(if (f:profile) then (if (f:profile[contains(@value,'StructureDefinition/')]) then (substring-after(f:profile/@value,'StructureDefinition/')) else tokenize(f:profile/@value,'/')[last()]) else f:code/@value, if (position()=last()) then () else ' | ')"/>
                            </a>
                        </xsl:for-each>
                    </div>
                </xsl:if>
            </td>
            <!-- Description and stuff -->
            <td style="vertical-align: top; text-align : left; padding:0px 4px 0px 4px;" class="hierarchy">
                <xsl:if test="not(f:short)">
                    <div>
                        <xsl:value-of select="f:name/@value"/>
                    </div>
                </xsl:if>
                <xsl:value-of select="f:short/@value"/>
                <xsl:if test="f:type[f:code/@value='Extension']/f:profile/@value">
                    <table>
                        <tr>
                            <td class="url-label">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'fhir-url'"/>
                                </xsl:call-template>
                            </td>
                            <td>
                                <a href="{f:type/f:profile/@value}">
                                    <xsl:value-of select="f:type/f:profile/@value"/>
                                </a>
                            </td>
                        </tr>
                    </table>
                </xsl:if>
                <xsl:for-each select="f:binding">
                    <table>
                        <tr>
                            <td class="binding-label">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'fhir-binding'"/>
                                </xsl:call-template>
                            </td>
                            <td rowspan="2">
                                <a href="{f:valueSetReference/f:reference/@value | f:valueSetUri/@value}">
                                    <xsl:value-of select="if (f:valueSetReference/f:display/@value) then f:valueSetReference/f:display/@value else ( f:valueSetReference/f:reference/@value | f:valueSetUri/@value )"/>
                                </a>
                                <xsl:variable name="btable">
                                    <xsl:if test="f:strength[@value='required']">
                                        <a href="http://hl7.org/fhir/terminologies.html#required">
                                            <xsl:attribute name="title">
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'fhir-binding-strength-required'"/>
                                                </xsl:call-template>
                                            </xsl:attribute>
                                            <xsl:call-template name="getMessage">
                                                <xsl:with-param name="key" select="'Required'"/>
                                            </xsl:call-template>
                                        </a>
                                    </xsl:if>
                                    <xsl:if test="f:strength[@value='extensible']">
                                        <a href="http://hl7.org/fhir/terminologies.html#extensible">
                                            <xsl:attribute name="title">
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'fhir-binding-strength-extensible'"/>
                                                </xsl:call-template>
                                            </xsl:attribute>
                                            <xsl:call-template name="getMessage">
                                                <xsl:with-param name="key" select="'Extensible'"/>
                                            </xsl:call-template>
                                        </a>
                                    </xsl:if>
                                    <xsl:if test="f:strength[@value='example']">
                                        <a href="http://hl7.org/fhir/terminologies.html#example">
                                            <xsl:attribute name="title">
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'fhir-binding-strength-example'"/>
                                                </xsl:call-template>
                                            </xsl:attribute>
                                            <xsl:call-template name="getMessage">
                                                <xsl:with-param name="key" select="'Example'"/>
                                            </xsl:call-template>
                                        </a>
                                    </xsl:if>
                                    <xsl:if test="f:strength[@value='preferred']">
                                        <a href="http://hl7.org/fhir/terminologies.html#preferred">
                                            <xsl:attribute name="title">
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'fhir-binding-strength-preferred'"/>
                                                </xsl:call-template>
                                            </xsl:attribute>
                                            <xsl:call-template name="getMessage">
                                                <xsl:with-param name="key" select="'Preferred'"/>
                                            </xsl:call-template>
                                        </a>
                                    </xsl:if>
                                </xsl:variable>
                                <xsl:if test="count($btable/*)&gt;0">
                                    <xsl:text> (</xsl:text>
                                    <xsl:copy-of select="$btable/*"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:if>
                            </td>
                        </tr>
                        <tr>
                            <td rowspan="1"/>
                        </tr>
                    </table>
                </xsl:for-each>
                <xsl:for-each select="f:fixedCode|f:fixedUri">
                    <table>
                        <tr>
                            <td class="fixed-label">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'fhir-fixed-value'"/>
                                </xsl:call-template>
                            </td>
                            <td rowspan="2">
                                <xsl:value-of select="@value"/>
                            </td>
                        </tr>
                        <tr>
                            <td rowspan="1"/>
                        </tr>
                    </table>
                </xsl:for-each>
                <xsl:for-each select="f:constraint[not(f:key/@value = ('ele-1','ext-1','dom-1','dom-2','dom-3','dom-4'))]">
                    <table>
                        <tr>
                            <td class="conf-label">Constraint</td>
                            <td rowspan="2">
                                <i>
                                    <xsl:value-of select="f:human/@value"/>
                                </i>
                            </td>
                        </tr>
                        <tr>
                            <td rowspan="1"/>
                        </tr>
                    </table>
                </xsl:for-each>
            </td>
        </tr>
        <xsl:if test="$mappings">
            <tr xmlns="http://www.w3.org/1999/xhtml" style="vertical-align: top; text-align : left; background-color: white; border: 0px #F0F0F0 solid; padding:0px 4px 0px 4px; white-space: nowrap;" class="hierarchy">
                <td colspan="3" style="vertical-align: top; text-align : left; background-color: white; border: 0px #F0F0F0 solid; padding:0px 4px 0px 4px; white-space: nowrap; background-image: url('http://hl7.org/fhir/{$imgbck}')" class="hierarchy"/>
                <td colspan="2" style="vertical-align: top; text-align : left; padding:0px 4px 0px 4px;" class="hierarchy">
                    <!-- table of associated concepts -->
                    <table width="100%" border="0" cellspacing="2" cellpadding="2">
                        <tr style="vertical-align: top;">
                            <td style="vertical-align: top; text-align: left;">
                                <xsl:call-template name="showIcon">
                                    <xsl:with-param name="which">target</xsl:with-param>
                                </xsl:call-template>
                            </td>
                            <td class="tabtab" style="background-color: #F4FFF4;">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'targetOfConceptIds'"/>
                                </xsl:call-template>
                                <table width="100%" border="0" cellspacing="2" cellpadding="2">
                                    <xsl:for-each-group select="$mappings" group-by="concat(@ref,@effectiveDate)">
                                        <xsl:variable name="deid" select="@ref"/>
                                        <xsl:variable name="deed" select="@effectiveDate"/>
                                        <xsl:variable name="concept" select="concept"/>
                                        <xsl:if test="empty($concept)">
                                            <tr style="background-color: #F4FFF4;">
                                                <td style="width: 25%; vertical-align: top;" colspan="3">
                                                    <xsl:call-template name="getMessage">
                                                        <xsl:with-param name="key" select="'theReferencedConceptAsOfCannotBeFound'"/>
                                                        <xsl:with-param name="p1" select="$deid"/>
                                                        <xsl:with-param name="p2" select="$deed"/>
                                                    </xsl:call-template>
                                                </td>
                                            </tr>
                                        </xsl:if>
                                        <xsl:for-each select="$concept">
                                            <tr style="background-color: #F4FFF4;">
                                                <td style="width: 25%; vertical-align: top;">
                                                    <!-- id -->
                                                    <!--
                                                    <ul>
                                                        <xsl:for-each select="@*">
                                                            <li>
                                                                <xsl:value-of select="name(.)"/>
                                                                <xsl:text>=</xsl:text>
                                                                <xsl:value-of select="."/>
                                                            </li>
                                                        </xsl:for-each>
                                                    </ul>
                                                    <ul>
                                                        <xsl:for-each select="*">
                                                            <li>
                                                                <xsl:value-of select="name(.)"/>
                                                                <xsl:text>=</xsl:text>
                                                                <xsl:value-of select="."/>
                                                            </li>
                                                        </xsl:for-each>
                                                    </ul>
                                                    -->
                                                    <a href="{local:doHtmlName('DS', @prefix, @datasetId, @datasetEffectiveDate, $deid, $deed, (), (), '.html', 'false')}" onclick="target='_blank';">
                                                        <xsl:value-of select="@shorthandId"/>
                                                    </a>
                                                </td>
                                                <td style="vertical-align: top;">
                                                    <!-- name -->
                                                    <xsl:call-template name="doName">
                                                        <xsl:with-param name="ns" select="name"/>
                                                    </xsl:call-template>
                                                </td>
                                                <td style="width: 35%; vertical-align: top;">
                                                    <!-- dataset name -->
                                                    <xsl:value-of select="@datasetName"/>
                                                    <xsl:text> </xsl:text>
                                                    <xsl:value-of select="@datasetVersionLabel"/>
                                                </td>
                                            </tr>
                                        </xsl:for-each>
                                    </xsl:for-each-group>
                                </table>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>
    <xsl:template match="f:element" mode="table">
        <xsl:param name="bgcolor"/>
        <!-- 
        -->
        <xsl:variable name="elementId" select="@id"/>
        <xsl:variable name="path" select="f:path/@value"/>
        <tr xmlns="http://www.w3.org/1999/xhtml" style="{concat('border: 0px; padding: 0px; background-color: ', $bgcolor)}">
            <xsl:variable name="ppath" select="tokenize($path,'\.')"/>
            <td>
                <xsl:choose>
                    <xsl:when test="count($ppath)=1">
                        <span style="display: inline; font-family: monospace; color:red;">
                            <xsl:value-of select="$ppath[1]"/>
                        </span>
                    </xsl:when>
                    <xsl:otherwise>
                        <span style="display: inline; font-family: monospace;">
                            <xsl:for-each select="$ppath">
                                <xsl:if test="position()!=last()">
                                    <xsl:value-of select="."/>
                                    <xsl:text>.</xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                            <span style="font-family: monospace; color:red;">
                                <xsl:value-of select="$ppath[last()]"/>
                            </span>
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
            <td>
                <xsl:if test="f:min | f:max">
                    <xsl:value-of select="f:min/@value"/>...<xsl:value-of select="f:max/@value"/>
                </xsl:if>
            </td>
        </tr>
    </xsl:template>
    <!-- 
        preliminaries (meta data)
    -->
    <xsl:template match="f:StructureDefinition" mode="showpreliminaries">
        <tr style="vertical-align: top;">
            <!-- Name -->
            <th style="width: {$fWidth}; text-align: left;">
                <xsl:call-template name="getMessage">
                    <xsl:with-param name="key" select="'Name'"/>
                </xsl:call-template>
            </th>
            <td style="text-align: left;">
                <xsl:value-of select="f:name/@value"/>
            </td>
            <!-- displayName -->
            <th style="width: {$fWidth}; text-align: left;">
                <xsl:call-template name="getMessage">
                    <xsl:with-param name="key" select="'fhir-title'"/>
                </xsl:call-template>
            </th>
            <td style="text-align: left;">
                <xsl:value-of select="f:title/@value"/>
            </td>
        </tr>
        <tr style="vertical-align: top;">
            <th style="width: {$fWidth}; text-align: left;">
                <xsl:call-template name="getMessage">
                    <xsl:with-param name="key" select="'fhir-date'"/>
                </xsl:call-template>
            </th>
            <td style="text-align: left;">
                <xsl:call-template name="showDate">
                    <xsl:with-param name="date" select="f:date/@value"/>
                </xsl:call-template>
            </td>
            <th style="width: {$fWidth}; text-align: left;">
                <xsl:call-template name="getMessage">
                    <xsl:with-param name="key" select="'Status'"/>
                </xsl:call-template>
            </th>
            <td style="text-align: left;">
                <xsl:call-template name="showStatusDot">
                    <xsl:with-param name="status" select="f:status/@value"/>
                    <xsl:with-param name="title">
                        <xsl:call-template name="getXFormsLabel">
                            <xsl:with-param name="simpleTypeKey" select="'TemplateStatusCodeLifeCycle'"/>
                            <xsl:with-param name="lang" select="$defaultLanguage"/>
                            <xsl:with-param name="simpleTypeValue" select="f:status/@value"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:text> </xsl:text>
                <xsl:call-template name="getXFormsLabel">
                    <xsl:with-param name="simpleTypeKey" select="'TemplateStatusCodeLifeCycle'"/>
                    <xsl:with-param name="simpleTypeValue" select="f:status/@value"/>
                    <xsl:with-param name="lang" select="$defaultLanguage"/>
                </xsl:call-template>
            </td>
        </tr>
        <tr style="vertical-align: top;">
            <th style="width: {$fWidth}; text-align: left;">
                <xsl:call-template name="getMessage">
                    <xsl:with-param name="key" select="'fhir-url'"/>
                </xsl:call-template>
            </th>
            <td style="text-align: left;" colspan="3">
                <xsl:call-template name="showDate">
                    <xsl:with-param name="date" select="f:url/@value"/>
                </xsl:call-template>
            </td>
        </tr>
        <tr style="vertical-align: top;">
            <th style="width: {$fWidth}; text-align: left;">
                <xsl:call-template name="getMessage">
                    <xsl:with-param name="key" select="'Description'"/>
                </xsl:call-template>
            </th>
            <td style="text-align: left;" colspan="3">
                <xsl:call-template name="showDate">
                    <xsl:with-param name="date" select="f:description/@value"/>
                </xsl:call-template>
            </td>
        </tr>
    </xsl:template>
    <xsl:template name="doHeader">
        <tr>
            <th style="padding-bottom: 4px; text-align: left;">
                <xsl:call-template name="getMessage">
                    <xsl:with-param name="key" select="'Name'"/>
                </xsl:call-template>
                <a href="http://hl7.org/fhir/formats.html#table">
                    <xsl:call-template name="showIcon">
                        <xsl:with-param name="which" select="'info'"/>
                        <xsl:with-param name="tooltip">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'fhir-logical-name-for-the-element'"/>
                            </xsl:call-template>
                        </xsl:with-param>
                    </xsl:call-template>
                </a>
            </th>
            <th style="text-align: left;">
                <xsl:call-template name="getMessage">
                    <xsl:with-param name="key" select="'Markers'"/>
                </xsl:call-template>
                <a href="http://hl7.org/fhir/formats.html#table">
                    <xsl:call-template name="showIcon">
                        <xsl:with-param name="which" select="'info'"/>
                        <xsl:with-param name="tooltip">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'fhir-information-about-the-use-of-element'"/>
                            </xsl:call-template>
                        </xsl:with-param>
                    </xsl:call-template>
                </a>
            </th>
            <th style="text-align: left;">
                <xsl:call-template name="getMessage">
                    <xsl:with-param name="key" select="'Card'"/>
                </xsl:call-template>
                <a href="http://hl7.org/fhir/formats.html#table">
                    <xsl:call-template name="showIcon">
                        <xsl:with-param name="which" select="'info'"/>
                        <xsl:with-param name="tooltip">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'fhir-min-max-occurence'"/>
                            </xsl:call-template>
                        </xsl:with-param>
                    </xsl:call-template>
                </a>
            </th>
            <th style="text-align: left;">
                <xsl:call-template name="getMessage">
                    <xsl:with-param name="key" select="'Type'"/>
                </xsl:call-template>
                <a href="http://hl7.org/fhir/formats.html#table">
                    <xsl:call-template name="showIcon">
                        <xsl:with-param name="which" select="'info'"/>
                        <xsl:with-param name="tooltip">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'fhir-reference-to-the-type-of-the-element'"/>
                            </xsl:call-template>
                        </xsl:with-param>
                    </xsl:call-template>
                </a>
            </th>
            <th style="text-align: left;">
                <xsl:call-template name="getMessage">
                    <xsl:with-param name="key" select="'Description'"/>
                </xsl:call-template>
                <xsl:text> &amp; </xsl:text>
                <xsl:call-template name="getMessage">
                    <xsl:with-param name="key" select="'Constraints'"/>
                </xsl:call-template>
                <a href="http://hl7.org/fhir/formats.html#table">
                    <xsl:call-template name="showIcon">
                        <xsl:with-param name="which" select="'info'"/>
                        <xsl:with-param name="tooltip">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'fhir-additional-information-about-the-element'"/>
                            </xsl:call-template>
                        </xsl:with-param>
                    </xsl:call-template>
                </a>
                <span style="float: right">
                    <a href="http://hl7.org/fhir/formats.html#table">
                        <xsl:call-template name="showIcon">
                            <xsl:with-param name="which" select="'questionmark'"/>
                            <xsl:with-param name="tooltip">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'fhir-legend-for-this-format'"/>
                                </xsl:call-template>
                            </xsl:with-param>
                        </xsl:call-template>
                    </a>
                </span>
            </th>
        </tr>
    </xsl:template>
</xsl:stylesheet>