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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:local="http://art-decor.org/functions"
    xmlns:error="http://art-decor.org/ns/decor/template/error"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="#all"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Oct 30, 2017</xd:p>
            <xd:p><xd:b>Author:</xd:b> Alexander Henket</xd:p>
            <xd:p>
                <xd:b>Purpose:</xd:b> Expects a compiled DECOR project and transforms, starting from any specified template (<xd:ref name="tmid" type="parameter">tmid</xd:ref> and optionally <xd:ref name="tmed" type="parameter">tmid</xd:ref>) the specification into a technically conformant example fragment.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output indent="yes" omit-xml-declaration="yes"/>
    
    <xd:doc>
        <xd:desc>The template id for the template to start with. Required</xd:desc>
    </xd:doc>
    <xsl:param name="tmid" as="xs:string"/>
    <xd:doc>
        <xd:desc>The template effectiveDate for the template to start with. Optional. If omitted or not xs:dateTime, we assume dynamic and use the latest available version</xd:desc>
    </xd:doc>
    <xsl:param name="tmed" as="xs:string?"/>
    
    <xd:doc>
        <xd:desc>The element id in the template to start with. Optional</xd:desc>
    </xd:doc>
    <xsl:param name="elid" as="xs:string?"/>
    <xd:doc>
        <xd:desc>Default: false. Relevant only when you require an example for an in-memory template in the Template Editor. This template will have particles marked with @selected="" to indicate whether or not they are used. In creating the example this is respected</xd:desc>
    </xd:doc>
    <xsl:param name="doSelectedOnly" as="xs:string">false</xsl:param>
    <xd:doc>
        <xd:desc>Default: true. When true the example goes as deep as your specification or until a circular definition is encountered. When false there is not processing of @contains | include | choice</xd:desc>
    </xd:doc>
    <xsl:param name="doRecursive" as="xs:string">true</xsl:param>
    
    <xd:doc>
        <xd:desc>get project default element namespace prefix</xd:desc>
    </xd:doc>
    <xsl:param name="projectDefaultElementPrefix">
        <xsl:choose>
            <xsl:when test="string-length(//project/defaultElementNamespace/@ns)&gt;0">
                <xsl:value-of select="//project/defaultElementNamespace/@ns"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- guess the default: hl7: -->
                <xsl:text>hl7:</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    
    <xd:doc>
        <xd:desc>get project default element namespace uri</xd:desc>
    </xd:doc>
    <xsl:variable name="projectDefaultElementNamespace">
        <xsl:variable name="prefix" select="replace($projectDefaultElementPrefix,':','')"/>
        <xsl:variable name="ns" select="namespace-uri-for-prefix($prefix, $theDecor)"/>
        <xsl:choose>
            <xsl:when test="string-length($ns)&gt;0">
                <xsl:value-of select="$ns"/>
            </xsl:when>
            <xsl:when test="$prefix=('hl7','cda')">urn:hl7-org:v3</xsl:when>
            <xsl:otherwise>
                <!--<xsl:call-template name="logMessage">
                    <xsl:with-param name="level" select="$logFATAL"/>
                    <xsl:with-param name="terminate" select="true()"/>
                    <xsl:with-param name="msg">
                        <xsl:text>+++ Error: Could not determine namespace-uri for default prefix "</xsl:text>
                        <xsl:value-of select="$prefix"/>
                        <xsl:text>" - Please add the missing namespace declaration your project </xsl:text>
                    </xsl:with-param>
                </xsl:call-template>-->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>keep the current decor project available for various processing. The decor element might be wrapped in another element</xd:desc>
    </xd:doc>
    <xsl:variable name="theDecor" select="//decor[1]" as="element(decor)"/>
    
    <xd:doc>
        <xd:desc>Index templates by id</xd:desc>
    </xd:doc>
    <xsl:key name="allTemplatesById" match="template" use="@id"/>
    <xd:doc>
        <xd:desc>Index templates by name</xd:desc>
    </xd:doc>
    <xsl:key name="allTemplatesByName" match="template" use="@name"/>
    <xd:doc>
        <xd:desc>Index value sets by id</xd:desc>
    </xd:doc>
    <xsl:key name="allValuesetsById" match="valueSet" use="@id"/>
    <xd:doc>
        <xd:desc>Index value sets by name</xd:desc>
    </xd:doc>
    <xsl:key name="allValuesetsByName" match="valueSet" use="@name"/>
    
    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="decor" priority="+1">
        <xsl:variable name="theTemplate" select="local:getTemplate($tmid, $tmed)" as="element(template)?"/>
        <xsl:variable name="theFormat" select="if ($theTemplate/classification[@format]) then $theTemplate/classification[@format][1]/@format else ('hl7v3xml1')"/>
        <xsl:variable name="thePath" select="replace($theTemplate/context/@path,'[/\[].*','')"/>
        <xsl:variable name="theEelementName" select="if (string-length($thePath)>0) then $thePath else ('art:placeholder')"/>
        
        <xsl:variable name="theElement" as="element(template)">
            <template>
                <xsl:copy-of select="$theTemplate/@*"/>
                <element name="{$theEelementName}" xmlns:art="urn:art-decor:example" selected="">
                    <xsl:choose>
                        <xsl:when test="string-length($elid) = 0">
                            <xsl:copy-of select="$theTemplate/attribute | $theTemplate/element | $theTemplate/include | $theTemplate/choice"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="$theTemplate//element[@id = $elid]"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </element>
            </template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$theFormat = 'hl7v2.5xml'">
                <xsl:apply-templates select="$theElement/element" mode="doExampleHL7V2">
                    <xsl:with-param name="processedTemplates" select="concat($theTemplate/@id, $theTemplate/@effectiveDate)"/>
                    <xsl:with-param name="doSelected" select="$doSelectedOnly"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$theElement/element" mode="doExampleHL7V3XML1">
                    <xsl:with-param name="processedTemplates" select="concat($theTemplate/@id, $theTemplate/@effectiveDate)"/>
                    <xsl:with-param name="doSelected" select="$doSelectedOnly"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc/>
        <xd:param name="processedTemplates"/>
        <xd:param name="element"/>
        <xd:param name="doSelected"/>
    </xd:doc>
    <xsl:template match="attribute" mode="doExampleHL7V3XML1">
        <xsl:param name="processedTemplates" as="xs:string*"/>
        <xsl:param name="element" select="element(element)"/>
        <xsl:param name="doSelected" as="xs:string"/>
        
        <xsl:variable name="attributeName" select="@name"/>
        <xsl:variable name="attributeValue" select="@value"/>
        
        <xsl:variable name="attrpfx" select="substring-before(@name,':')"/>
        <xsl:variable name="attrns" select="if ($attrpfx=('hl7','cda','',())) then () else if ($attrpfx='art') then 'urn:art-decor:example' else (namespace-uri-for-prefix($attrpfx, $element))"/>
        <xsl:variable name="attrname" select="replace(@name,'^([^:]+:)?([^\s\[]+)\s*(\[.*)?','$2')"/>
        
        <xsl:choose>
            <xsl:when test="$attributeName = 'xsi:type'">
                <xsl:choose>
                    <xsl:when test="$element[(@originalType | @datatype) = 'ANY']"/>
                    <xsl:when test="$element[@datatype]">
                        <xsl:attribute name="{$attrname}" select="tokenize($element/@datatype,'\.')[1]" namespace="{if (empty($attrns)) then $projectDefaultElementNamespace else $attrns}"/>
                    </xsl:when>
                    <xsl:when test="$attributeValue">
                        <xsl:attribute name="{$attrname}" select="$attributeValue" namespace="{if (empty($attrns)) then $projectDefaultElementNamespace else $attrns}"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="{$attrname}" select="'--TODO--'" namespace="{if (empty($attrns)) then $projectDefaultElementNamespace else $attrns}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$attributeValue">
                <xsl:attribute name="{$attrname}" select="$attributeValue"/>
            </xsl:when>
            <!-- check element vocabulary -->
            <xsl:when test="vocabulary/@valueSet">
                <xsl:variable name="vsref" select="(vocabulary/@valueSet)[1]"/>
                <xsl:variable name="vsflex" select="(vocabulary[@valueSet])[1]/@flexibility"/>
                <xsl:variable name="firstCode" select="local:getValueset($vsref, $vsflex)//conceptList/concept[not(@type=('D','A'))]" as="element()*"/>
                
                <xsl:if test="$firstCode">
                    <xsl:choose>
                        <xsl:when test="string-length($attrpfx) = 0">
                            <xsl:attribute name="{$attrname}" select="$firstCode[1]/@code"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="{$attrname}" select="$firstCode[1]/@code" namespace="{if (empty($attrns)) then $projectDefaultElementNamespace else $attrns}"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
            </xsl:when>
            <xsl:when test="vocabulary/@code">
                <xsl:choose>
                    <xsl:when test="string-length($attrpfx) = 0">
                        <xsl:attribute name="{$attrname}" select="vocabulary[@code][1]/@code"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="{$attrname}" select="vocabulary[@code][1]/@code" namespace="{if (empty($attrns)) then $projectDefaultElementNamespace else $attrns}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@datatype=('bn','bl')">
                <xsl:choose>
                    <xsl:when test="string-length($attrpfx) = 0">
                        <xsl:attribute name="{$attrname}" select="'false'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="{$attrname}" select="'false'" namespace="{if (empty($attrns)) then $projectDefaultElementNamespace else $attrns}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@datatype=('set_cs','cs')">
                <xsl:choose>
                    <xsl:when test="string-length($attrpfx) = 0">
                        <xsl:attribute name="{$attrname}" select="'cs'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="{$attrname}" select="'cs'" namespace="{if (empty($attrns)) then $projectDefaultElementNamespace else $attrns}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@datatype=('int')">
                <xsl:variable name="int" select="if ($element/property/@minInclude) then ($element/property/@minInclude)[1] else (1)"/>
                <xsl:choose>
                    <xsl:when test="string-length($attrpfx) = 0">
                        <xsl:attribute name="{$attrname}" select="$int"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="{$attrname}" select="$int" namespace="{if (empty($attrns)) then $projectDefaultElementNamespace else $attrns}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@datatype=('real')">
                <xsl:variable name="int" select="if ($element/property[1]/@minInclude) then $element/property[1]/@minInclude else ('1')" as="xs:string"/>
                <xsl:variable name="intfrac" select="tokenize($int,'\.')[2]"/>
                <xsl:variable name="fractionDigits" select="if ($element/property[1]/@fractionDigits[matches(.,'\d')]) then xs:integer(replace($element/property[1]/@fractionDigits,'!','')) else (0)"/>
                <xsl:variable name="intfracadd" select="string-join(if (string-length($intfrac) lt $fractionDigits) then  for $i in (1 to ($fractionDigits - string-length($intfrac))) return '0' else (),'')"/>
                <xsl:variable name="real" select="concat($int, if (not(contains($int,'.')) and string-length($intfracadd) gt 0) then '.' else (), $intfracadd)"/>
                
                <xsl:choose>
                    <xsl:when test="string-length($attrpfx) = 0">
                        <xsl:attribute name="{$attrname}" select="$real"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="{$attrname}" select="$real" namespace="{if (empty($attrns)) then $projectDefaultElementNamespace else $attrns}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@datatype=('st')">
                <xsl:choose>
                    <xsl:when test="string-length($attrpfx) = 0">
                        <xsl:attribute name="{$attrname}" select="$attributeName"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="{$attrname}" select="$attributeName" namespace="{if (empty($attrns)) then $projectDefaultElementNamespace else $attrns}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@datatype=('ts')">
                <xsl:variable name="ts" select="format-dateTime(current-dateTime(),'[Y0001][M01][D01][H01][m01][s01]','en',(),())"/>
                <xsl:choose>
                    <xsl:when test="string-length($attrpfx) = 0">
                        <xsl:attribute name="{$attrname}" select="$ts"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="{$attrname}" select="$ts" namespace="{if (empty($attrns)) then $projectDefaultElementNamespace else $attrns}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@datatype=('uid','oid')">
                <xsl:choose>
                    <xsl:when test="string-length($attrpfx) = 0">
                        <xsl:attribute name="{$attrname}" select="'1.2.3.999'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="{$attrname}" select="'1.2.3.999'" namespace="{if (empty($attrns)) then $projectDefaultElementNamespace else $attrns}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@datatype=('uuid')">
                <xsl:choose>
                    <xsl:when test="string-length($attrpfx) = 0">
                        <xsl:attribute name="{$attrname}" select="'550e8400-e29b-41d4-a716-446655440000'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="{$attrname}" select="'550e8400-e29b-41d4-a716-446655440000'" namespace="{if (empty($attrns)) then $projectDefaultElementNamespace else $attrns}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@datatype=('ruid')">
                <xsl:choose>
                    <xsl:when test="string-length($attrpfx) = 0">
                        <xsl:attribute name="{$attrname}" select="'FsLo5xllxHinTYAGyEVldE'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="{$attrname}" select="'FsLo5xllxHinTYAGyEVldE'" namespace="{if (empty($attrns)) then $projectDefaultElementNamespace else $attrns}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="string-length($attrpfx) = 0">
                        <xsl:attribute name="{$attrname}" select="'--TODO--'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="{$attrname}" select="'--TODO--'" namespace="{if (empty($attrns)) then $projectDefaultElementNamespace else $attrns}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc/>
        <xd:param name="processedTemplates"/>
        <xd:param name="doSelected"/>
    </xd:doc>
    <xsl:template match="element" mode="doExampleHL7V3XML1">
        <xsl:param name="processedTemplates" as="xs:string*"/>
        <xsl:param name="doSelected" as="xs:string"/>
        
        <xsl:variable name="parentElement" select="."/>
        <xsl:variable name="attributes" select="local:normalizeAttributes(attribute)" as="element()*"/>
        <xsl:choose>
            <xsl:when test=".[@selected or not($doSelected = 'true')][not(@conformance='NP')]">
                <!-- strip namespace prefix and predicate from element/@name -->
                <xsl:variable name="elmpfx" select="substring-before(@name,':')"/>
                <xsl:variable name="elmns" select="if ($elmpfx=('hl7','cda','',())) then () else if ($elmpfx='art') then 'urn:art-decor:example' else (namespace-uri-for-prefix($elmpfx, ancestor::template))"/>
                <xsl:variable name="elmname" select="replace(@name,'^([^:]+:)?([^\s\[]+)\s*(\[.*)?','$2')"/>
                
                <!-- poor mans solution for INT.POS, AD.NL and other flavors. Should check DECOR-supported-datatypes.xml -->
                <xsl:variable name="theDatatype" select="if (@datatype) then tokenize(@datatype,'\.')[1] else ()"/>
                
                <xsl:element name="{if (empty($elmns)) then (if ($elmname = '') then 'noname' else $elmname) else QName($elmns, $elmname)}" namespace="{if (empty($elmns)) then $projectDefaultElementNamespace else $elmns}">
                    <xsl:if test="@originalType = 'ANY'">
                        <xsl:attribute name="xsi:type" select="$theDatatype"/>
                    </xsl:if>
                    <xsl:for-each-group select="$attributes[@selected or not($doSelected = 'true')][not(@prohibited='true')]" group-by="@name">
                        <xsl:if test="not($theDatatype = ('ADXP','SC')) or current-group()[1][not(@isOptional = 'true')]">
                            <xsl:apply-templates select="current-group()[1]" mode="#current">
                                <xsl:with-param name="processedTemplates" select="$processedTemplates"/>
                                <xsl:with-param name="element" select="$parentElement"/>
                                <xsl:with-param name="doSelected" select="$doSelected"/>
                            </xsl:apply-templates>
                        </xsl:if>
                    </xsl:for-each-group>
                    
                    <xsl:choose>
                        <!-- check element vocabulary -->
                        <xsl:when test="vocabulary/@valueSet">
                            <xsl:variable name="vsref" select="(vocabulary/@valueSet)[1]"/>
                            <xsl:variable name="vsflex" select="(vocabulary[@valueSet])[1]/@flexibility"/>
                            <xsl:variable name="firstCode" select="local:getValueset($vsref, $vsflex)//conceptList/concept[not(@type=('D','A'))]" as="element()*"/>
                            
                            <xsl:if test="$firstCode">
                                <xsl:copy-of select="$firstCode[1]/@code"/>
                                <xsl:if test="not($theDatatype = 'CS')">
                                    <xsl:copy-of select="$firstCode[1]/@codeSystem"/>
                                    <xsl:copy-of select="$firstCode[1]/@displayName"/>
                                </xsl:if>
                            </xsl:if>
                        </xsl:when>
                        <xsl:when test="vocabulary/@code">
                            <xsl:copy-of select="vocabulary[@code][1]/@code"/>
                            <xsl:if test="not($theDatatype = 'CS')">
                                <xsl:copy-of select="vocabulary[@code][1]/@codeSystem"/>
                                <xsl:copy-of select="vocabulary[@code][1]/@displayName"/>
                            </xsl:if>
                        </xsl:when>
                        <xsl:when test="vocabulary/@codeSystem">
                            <xsl:attribute name="code">--code--</xsl:attribute>
                            <xsl:if test="not($theDatatype = 'CS')">
                                <xsl:copy-of select="vocabulary[@codeSystem][1]/@codeSystem"/>
                                <xsl:copy-of select="vocabulary[@codeSystem][1]/@displayName"/>
                            </xsl:if>
                        </xsl:when>
                        
                        <xsl:when test="@contains or empty($theDatatype)">
                            <!-- Don't do it -->
                        </xsl:when>
                        <xsl:when test="$theDatatype = ('II') and not($attributes[@name = ('root', 'extension')])">
                            <xsl:attribute name="root">1.2.3.999</xsl:attribute>
                            <xsl:attribute name="extension">--example only--</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="$theDatatype = ('BL','BN') and not($attributes[@name = 'value'])">
                            <xsl:attribute name="value">false</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="@datatype = ('INT','INT.POS','INT.NONNEG') and not($attributes[@name = 'value'])">
                            <xsl:variable name="int" select="if (property[1]/@minInclude) then property[1]/@minInclude else ('1')" as="xs:string"/>
                            <xsl:variable name="intfrac" select="tokenize($int,'\.')[2]"/>
                            <xsl:variable name="fractionDigits" select="if (property[1]/@fractionDigits[matches(.,'\d')]) then xs:integer(replace(property[1]/@fractionDigits,'!','')) else (0)"/>
                            <xsl:variable name="intfracadd" select="string-join(if (string-length($intfrac) lt $fractionDigits) then  for $i in (1 to ($fractionDigits - string-length($intfrac))) return '0' else (),'')"/>
                            <xsl:variable name="real" select="concat($int,if (not(contains($int,'.')) and string-length($intfracadd)>0) then '.' else(),$intfracadd)"/>
                            
                            <xsl:attribute name="value" select="$real"/>
                        </xsl:when>
                        <xsl:when test="$theDatatype = ('TEL') and not($attributes[@name = 'value'])">
                            <xsl:attribute name="value">tel:+1-12345678</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="$theDatatype = ('URL') and not($attributes[@name = 'value'])">
                            <xsl:attribute name="value">http:mydomain.org</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="@datatype = ('TS','TS.DATETIME.MIN') and not($attributes[@name = 'value'])">
                            <xsl:attribute name="value" select="format-dateTime(current-dateTime(),'[Y0001][M01][D01][H01][m01][s01]','en',(),())"/>
                        </xsl:when>
                        <xsl:when test="@datatype = ('TS.DATE', 'TS.DATE.MIN', 'TS.DATE.FULL') and not($attributes[@name = 'value'])">
                            <xsl:attribute name="value" select="format-dateTime(current-dateTime(),'[Y0001][M01][D01]','en',(),())"/>
                        </xsl:when>
                        <xsl:when test="matches(@datatype, '^TS\..*TZ$') and not($attributes[@name = 'value'])">
                            <xsl:attribute name="value" select="format-dateTime(current-dateTime(),'[Y0001][M01][D01][H01][m01][s01][Z]','en',(),())"/>
                        </xsl:when>
                        <xsl:when test="$theDatatype = ('IVL_TS') and not($attributes[@name = 'value'] or .[@contains | element | include | choice])">
                            <xsl:element name="low" namespace="{$projectDefaultElementNamespace}">
                                <xsl:attribute name="value" select="format-dateTime(current-dateTime(), '[Y0001][M01][D01][H01][m01][s01]', 'en', (), ())"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="$theDatatype = ('PQ')">
                            <xsl:if test="not($attributes[@name = 'value'])">
                                <xsl:attribute name="value">1</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="not($attributes[@name = 'unit'])">
                                <xsl:copy-of select="property[1]/@unit"/>
                            </xsl:if>
                        </xsl:when>
                        <xsl:when test="$theDatatype = ('IVL_PQ') and not($attributes[@name = 'value'] or .[@contains | element | include | choice])">
                            <xsl:element name="low" namespace="{$projectDefaultElementNamespace}">
                                <xsl:if test="not($attributes[@name = 'value'])">
                                    <xsl:attribute name="value">1</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="not($attributes[@name = 'unit'])">
                                    <xsl:copy-of select="property[1]/@unit"/>
                                </xsl:if>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="$theDatatype = ('MO')">
                            <xsl:if test="not($attributes[@name = 'value'])">
                                <xsl:attribute name="value">1</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="not($attributes[@name = 'unit'])">
                                <xsl:copy-of select="property[1]/@currency"/>
                            </xsl:if>
                        </xsl:when>
                        <xsl:when test="$theDatatype = ('IVL_MO') and not($attributes[@name = 'value'] or .[@contains | element | include | choice])">
                            <xsl:element name="low" namespace="{$projectDefaultElementNamespace}">
                                <xsl:if test="not($attributes[@name = 'value'])">
                                    <xsl:attribute name="value">1</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="not($attributes[@name = 'unit'])">
                                    <xsl:copy-of select="property[1]/@currency"/>
                                </xsl:if>
                            </xsl:element>
                        </xsl:when>
                    </xsl:choose>
                    
                    <xsl:copy-of select="text[1]/node()"/>
                    
                    <xsl:if test=".[not(@contains | element  | include | choice | text)][$theDatatype = ('EN','ON','PN','TN','ADXP','ENXP','SC','AD','ENXP','ADXP','ST')]">
                        <xsl:choose>
                            <xsl:when test="$elmname = 'delimiter'">-</xsl:when>
                            <xsl:when test="$elmname = 'houseNumberNumeric'">1</xsl:when>
                            <xsl:when test="$elmname = 'postBox'">12345</xsl:when>
                            <xsl:otherwise><xsl:value-of select="$elmname"/></xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                    
                    <xsl:for-each select="element | include | choice">
                        <xsl:apply-templates select="." mode="#current">
                            <xsl:with-param name="processedTemplates" select="$processedTemplates"/>
                            <xsl:with-param name="doSelected" select="$doSelected"/>
                        </xsl:apply-templates>
                    </xsl:for-each>
                    
                    <xsl:if test="@contains">
                        <xsl:variable name="tmref" select="@contains"/>
                        <xsl:variable name="tmflex" select="if (@flexibility) then @flexibility else ('dynamic')"/>
                        <xsl:variable name="theTemplate" select="local:getTemplate($tmref, $tmflex)" as="element(template)?"/>
                        <xsl:variable name="chtmid">
                            <xsl:choose>
                                <xsl:when test="$theTemplate[@id]">
                                    <xsl:value-of select="$theTemplate/@id"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$tmref"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="chtmed">
                            <xsl:choose>
                                <xsl:when test="$theTemplate[@effectiveDate]">
                                    <xsl:value-of select="$theTemplate/@effectiveDate"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$tmflex"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="chtmnm">
                            <xsl:choose>
                                <xsl:when test="$theTemplate[@displayName]">
                                    <xsl:value-of select="$theTemplate/@displayName"/>
                                </xsl:when>
                                <xsl:when test="$theTemplate[@name]">
                                    <xsl:value-of select="$theTemplate/@name"/>
                                </xsl:when>
                                <xsl:otherwise>?</xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        
                        <xsl:choose>
                            <xsl:when test="$doRecursive = 'true'">
                                <xsl:choose>
                                    <xsl:when test="$processedTemplates = concat($chtmid, $chtmed)">
                                        <xsl:comment>
                                            <xsl:value-of select="concat('Recursion detected. Template ', $chtmid, ' ', $chtmnm, ' (', $chtmed,') has already been processed')"/>
                                        </xsl:comment>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:if test="$theTemplate[attribute]">
                                            <xsl:variable name="childattributes" select="local:normalizeAttributes($theTemplate/attribute)"/>
                                            <xsl:choose>
                                                <xsl:when test=".[text | element | include | choice]">
                                                    <xsl:copy-of select="error(xs:QName('error:AttributeOutsideOfElement'),concat('Template ', $parentElement/ancestor::template/@id, ' ', $parentElement/ancestor::template/@effectiveDate, '. Element ',$parentElement/@name, ' includes template ', $chtmid, ' ', $chtmed, ' with top level attributes, but element has child elements. The attribute would thus be created after the element, not on the element'))"/>
                                                </xsl:when>
                                                <!--<xsl:when test="$childattributes[@name = $attributes/@name]">
                                                    <xsl:copy-of select="error(xs:QName('error:AttributeDuplication'),concat('Template ', $parentElement/ancestor::template/@id, ' ', $parentElement/ancestor::template/@effectiveDate, '. Element ', $parentElement/@name, ' includes template ', $chtmid, ' ', $chtmed, ' with top level attributes that duplicate one or more attributes defined on the element: ', string-join($childattributes[@name = $attributes/@name]/@name, ' ')))"/>
                                                </xsl:when>-->
                                                <xsl:when test="$parentElement[@datatype]">
                                                    <!-- avoid risk of recreating attributes that were created before on the parent -->
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <!-- Don't recreate attributes from theTemplate if the parent already defined them -->
                                                    <xsl:for-each select="$childattributes[not(@name = $attributes/@name)][not(@prohibited='true')]">
                                                        <xsl:apply-templates select="." mode="#current">
                                                            <xsl:with-param name="processedTemplates" select="($processedTemplates, concat($chtmid, $chtmed))" as="xs:string*"/>
                                                            <xsl:with-param name="doSelected" select="'false'"/>
                                                        </xsl:apply-templates>
                                                    </xsl:for-each>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:if>
                                        
                                        <xsl:for-each select="$theTemplate/element | $theTemplate/include | $theTemplate/choice">
                                            <xsl:apply-templates select="." mode="#current">
                                                <xsl:with-param name="processedTemplates" select="$processedTemplates, concat($chtmid, $chtmed)"/>
                                                <xsl:with-param name="doSelected" select="'false'"/>
                                            </xsl:apply-templates>
                                        </xsl:for-each>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                        </xsl:choose>
                        
                        <xsl:text>&#10;</xsl:text>
                        <xsl:comment>
                            <xsl:value-of select="concat(' template ',$chtmid,' ''',$chtmnm,''' (',$chtmed,') ')"/>
                        </xsl:comment>
                    </xsl:if>
                </xsl:element>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc/>
        <xd:param name="processedTemplates"/>
    <xd:param name="doSelected"/>
    </xd:doc>
    <xsl:template match="include" mode="doExampleHL7V2 doExampleHL7V3XML1">
        <xsl:param name="processedTemplates" as="xs:string*"/>
        <xsl:param name="doSelected" as="xs:string"/>
        
        <xsl:variable name="prefix" select="(ancestor::template/@ident, ancestor::decor/project/@prefix)[1]"/>
        <xsl:variable name="tmref" select="@ref"/>
        <xsl:variable name="tmflex" select="if (@flexibility) then @flexibility else ('dynamic')"/>
        <xsl:variable name="theTemplate" select="local:getTemplate($tmref, $tmflex)" as="element(template)?"/>
        <xsl:variable name="chtmid">
            <xsl:choose>
                <xsl:when test="$theTemplate[@id]">
                    <xsl:value-of select="$theTemplate/@id"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$tmref"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="chtmed">
            <xsl:choose>
                <xsl:when test="$theTemplate[@effectiveDate]">
                    <xsl:value-of select="$theTemplate/@effectiveDate"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$tmflex"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="chtmnm">
            <xsl:choose>
                <xsl:when test="$theTemplate[@displayName]">
                    <xsl:value-of select="$theTemplate/@displayName"/>
                </xsl:when>
                <xsl:when test="$theTemplate[@name]">
                    <xsl:value-of select="$theTemplate/@name"/>
                </xsl:when>
                <xsl:otherwise>?</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="min" select="@minimumMultiplicity"/>
        <xsl:variable name="max" select="@maximumMultiplicity"/>
        <xsl:variable name="conf" select="@conformance"/>
        <xsl:variable name="mand" select="@isMandatory"/>
        
        <xsl:choose>
            <xsl:when test=".[@selected or not($doSelected = 'true')][not(@conformance='NP')]">
                <xsl:choose>
                    <xsl:when test="$doRecursive = 'true'">
                        <xsl:choose>
                            <xsl:when test="$processedTemplates = concat($chtmid, $chtmed)">
                                <xsl:comment>
                                    <xsl:value-of select="concat('Recursion detected. Template ', $chtmid, ' ', $chtmnm, ' (', $chtmed,') has already been processed')"/>
                                </xsl:comment>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:if test="$theTemplate[attribute]">
                                    <xsl:variable name="parentElement" select="ancestor::element[1]"/>
                                    <xsl:variable name="attributes" select="local:normalizeAttributes($parentElement/attribute[not(@prohibited='true')])"/>
                                    <xsl:variable name="childattributes" select="local:normalizeAttributes($theTemplate/attribute[not(@prohibited='true')])"/>
                                    
                                    <xsl:choose>
                                        <xsl:when test=".[preceding-sibling::text | preceding-sibling::element | preceding-sibling::include | preceding-sibling::choice]">
                                            <xsl:copy-of select="error(xs:QName('error:AttributeOutsideOfElement'),concat('Template ', $parentElement/ancestor::template/@id, ' ', $parentElement/ancestor::template/@effectiveDate, '. Element ',$parentElement/@name, ' includes template ', $chtmid, ' ', $chtmed, ' with top level attributes, but element has child elements. The attribute would thus be created after the element, not on the element'))"/>
                                        </xsl:when>
                                        <xsl:when test="$childattributes[@name = $attributes/@name]">
                                            <xsl:copy-of select="error(xs:QName('error:AttributeDuplication'),concat('Template ', $parentElement/ancestor::template/@id, ' ', $parentElement/ancestor::template/@effectiveDate, '. Element ', $parentElement/@name, ' includes template ', $chtmid, ' ', $chtmed, ' with top level attributes that dupliucate one or more attributes defined on the element: ', string-join($childattributes[@name = $attributes/@name]/@name, ' ')))"/>
                                        </xsl:when>
                                        <xsl:when test="$parentElement[@datatype]">
                                            <!-- avoid risk of recreating attributes that were created before on the parent -->
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:for-each-group select="$attributes[not(@prohibited='true')]" group-by="@name">
                                                <xsl:apply-templates select="current-group()[1]" mode="#current">
                                                    <xsl:with-param name="processedTemplates" select="($processedTemplates, concat($chtmid, $chtmed))" as="xs:string*"/>
                                                    <xsl:with-param name="element" select="$parentElement"/>
                                                    <xsl:with-param name="doSelected" select="'false'"/>
                                                </xsl:apply-templates>
                                            </xsl:for-each-group>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:if>
                                
                                <xsl:text>&#10;</xsl:text>
                                <xsl:comment><xsl:value-of select="concat(' include template ',$chtmid,' ''',$chtmnm,''' (',$chtmed,') ', local:processCardConf(.),' ')"/></xsl:comment>
                                
                                <xsl:for-each select="$theTemplate/element | $theTemplate/include | $theTemplate/choice">
                                    <xsl:choose>
                                        <xsl:when test="self::element">
                                            <xsl:variable name="child" as="element()">
                                                <template>
                                                    <xsl:copy-of select="$theTemplate/@*"/>
                                                    <element>
                                                        <xsl:copy-of select="@*"/>
                                                        <xsl:copy-of select="$min | $max | $conf | $mand"/>
                                                        <xsl:copy-of select="node()"/>
                                                    </element>
                                                </template>
                                            </xsl:variable>
                                            <xsl:apply-templates select="$child/*" mode="#current">
                                                <xsl:with-param name="processedTemplates" select="($processedTemplates, concat($chtmid, $chtmed))" as="xs:string*"/>
                                                <xsl:with-param name="doSelected" select="'false'"/>
                                            </xsl:apply-templates>
                                        </xsl:when>
                                        <xsl:when test="self::include">
                                            <xsl:variable name="child" as="element()">
                                                <template>
                                                    <xsl:copy-of select="$theTemplate/@*"/>
                                                    <include>
                                                        <xsl:copy-of select="@*"/>
                                                        <xsl:copy-of select="$min | $max | $conf | $mand"/>
                                                        <xsl:copy-of select="node()"/>
                                                    </include>
                                                </template>
                                            </xsl:variable>
                                            <xsl:apply-templates select="$child/*" mode="#current">
                                                <xsl:with-param name="processedTemplates" select="($processedTemplates, concat($chtmid, $chtmed))" as="xs:string*"/>
                                                <xsl:with-param name="doSelected" select="'false'"/>
                                            </xsl:apply-templates>
                                        </xsl:when>
                                        <xsl:when test="self::choice">
                                            <xsl:variable name="child" as="element()">
                                                <template>
                                                    <xsl:copy-of select="$theTemplate/@*"/>
                                                    <choice>
                                                        <xsl:copy-of select="@*"/>
                                                        <xsl:copy-of select="$min | $max"/>
                                                        <xsl:copy-of select="node()"/>
                                                    </choice>
                                                </template>
                                            </xsl:variable>
                                            <xsl:apply-templates select="$child/*" mode="#current">
                                                <xsl:with-param name="processedTemplates" select="($processedTemplates, concat($chtmid, $chtmed))" as="xs:string*"/>
                                                <xsl:with-param name="doSelected" select="'false'"/>
                                            </xsl:apply-templates>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <!-- Huh? -->
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:for-each>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>&#10;</xsl:text>
                        <xsl:comment>
                            <xsl:value-of select="concat(' include template ', $chtmid, ' ''', $chtmnm, ''' (', $tmflex, ') ', local:processCardConf(.), ' ')"/>
                        </xsl:comment>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>&#10;</xsl:text>
                <xsl:comment>
                    <xsl:value-of select="concat(' include template ', $chtmid, ' ''', $chtmnm, ''' (', $tmflex, ') ', local:processCardConf(.), ' ')"/>
                </xsl:comment>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc/>
        <xd:param name="processedTemplates"/>
        <xd:param name="doSelected"/>
    </xd:doc>
    <xsl:template match="choice" mode="doExampleHL7V2 doExampleHL7V3XML1">
        <xsl:param name="processedTemplates" as="xs:string*"/>
        <xsl:param name="doSelected" as="xs:string"/>
        
        <xsl:variable name="prefix" select="(ancestor::template/@ident, ancestor::decor/project/@prefix)[1]"/>
        <xsl:choose>
            <xsl:when test=".[@selected or not($doSelected = 'true')][not(@conformance='NP')]">
                <xsl:choose>
                    <xsl:when test="$doRecursive = 'true'">
                        <__CHOICE__>
                            <xsl:if test="@minimumMultiplicity"><xsl:attribute name="min" select="@minimumMultiplicity"/></xsl:if>
                            <xsl:if test="@maximumMultiplicity"><xsl:attribute name="max" select="@maximumMultiplicity"/></xsl:if>
                            
                            <xsl:for-each select="element[@selected or not($doSelected = 'true')] | include[@selected or not($doSelected = 'true')] | choice[@selected or not($doSelected = 'true')]">
                                <xsl:comment>start choice particle</xsl:comment>
                                
                                <xsl:apply-templates select="." mode="#current">
                                    <xsl:with-param name="processedTemplates" select="$processedTemplates"/>
                                    <xsl:with-param name="doSelected" select="$doSelected"/>
                                </xsl:apply-templates>
                                
                                <xsl:comment>end choice particle</xsl:comment>
                            </xsl:for-each>
                        </__CHOICE__>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>&#10;</xsl:text>,
                        <xsl:comment>
                            <xsl:text> choice: </xsl:text>
                            <xsl:value-of select="local:processCardConf(.)"/>
                            <xsl:text>&#10;</xsl:text>
                            <xsl:for-each select="element[@selected or not($doSelected = 'true')] | include[@selected or not($doSelected = 'true')] | choice[@selected or not($doSelected = 'true')]">
                                <xsl:variable name="tmref" select="@contains | @ref"/>
                                <xsl:variable name="tmflex" select="if (@flexibility) then @flexibility else ('dynamic')"/>
                                <xsl:variable name="template" select="local:getTemplate($tmref, $tmflex)" as="element(template)?"/>
                                <xsl:variable name="chtmid">
                                    <xsl:choose>
                                        <xsl:when test="$template[@id]">
                                            <xsl:value-of select="$template/@id"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$tmref"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <xsl:variable name="chtmnm">
                                    <xsl:choose>
                                        <xsl:when test="$template[@displayName]">
                                            <xsl:value-of select="$template/@displayName"/>
                                        </xsl:when>
                                        <xsl:when test="$template[@name]">
                                            <xsl:value-of select="$template/@name"/>
                                        </xsl:when>
                                        <xsl:otherwise>?</xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <xsl:choose>
                                    <xsl:when test="element">
                                        <xsl:value-of select="concat('    element ',@name, if (@contains) then concat(' containing template ', @contains, ' (', $tmflex,')') else (), '&#10;')"/>
                                    </xsl:when>
                                    <xsl:when test="include">
                                        <xsl:value-of select="concat('    include template ',$chtmid,' ''',$chtmnm,''' (',$tmflex,') ', local:processCardConf(.),'&#10;')"/>
                                    </xsl:when>
                                    <xsl:when test="choice">
                                        <xsl:value-of select="concat('    choice: ',local:processCardConf(.),'&#10;')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <!-- Huh? -->
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                            <xsl:text> </xsl:text>
                        </xsl:comment>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <!-- Don't do it... -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc/>
        <xd:param name="processedTemplates"/>
        <xd:param name="element"/>
        <xd:param name="doSelected"/>
    </xd:doc>
    <xsl:template match="attribute" mode="doExampleHL7V2">
        <xsl:param name="processedTemplates" as="xs:string*"/>
        <xsl:param name="element" select="element(element)"/>
        <xsl:param name="doSelected" as="xs:string"/>
        <xsl:variable name="attributeName" select="@name"/>
        <xsl:variable name="attributeValue" select="@value"/>
        <xsl:variable name="attrpfx" select="substring-before(@name,':')"/>
        <xsl:variable name="attrns" select="if ($attrpfx=('hl7','cda','',())) then () else if ($attrpfx='art') then 'urn:art-decor:example' else (namespace-uri-for-prefix($attrpfx, $element))"/>
        <xsl:variable name="attrname" select="replace(@name,'^([^:]+:)?([^\s\[]+)\s*(\[.*)?','$2')"/>
        <xsl:choose>
            <xsl:when test="$attributeValue">
                <xsl:attribute name="{$attrname}" select="$attributeValue"/>
            </xsl:when>
            <!-- check element vocabulary -->
            <xsl:when test="vocabulary/@valueSet">
                <xsl:variable name="vsref" select="(vocabulary/@valueSet)[1]"/>
                <xsl:variable name="vsflex" select="(vocabulary[@valueSet])[1]/@flexibility"/>
                <xsl:variable name="firstCode" select="local:getValueset($vsref, $vsflex)//conceptList/concept[not(@type=('D','A'))]" as="element()*"/>
                <xsl:if test="$firstCode">
                    <xsl:choose>
                        <xsl:when test="string-length($attrpfx) = 0">
                            <xsl:attribute name="{$attrname}" select="$firstCode[1]/@code"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="{$attrname}" select="$firstCode[1]/@code" namespace="{if (empty($attrns)) then $projectDefaultElementNamespace else $attrns}"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
            </xsl:when>
            <xsl:when test="vocabulary/@code">
                <xsl:choose>
                    <xsl:when test="string-length($attrpfx) = 0">
                        <xsl:attribute name="{$attrname}" select="vocabulary[@code][1]/@code"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="{$attrname}" select="vocabulary[@code][1]/@code" namespace="{if (empty($attrns)) then $projectDefaultElementNamespace else $attrns}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@datatype=('bn','bl')">
                <xsl:choose>
                    <xsl:when test="string-length($attrpfx) = 0">
                        <xsl:attribute name="{$attrname}" select="'false'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="{$attrname}" select="'false'" namespace="{if (empty($attrns)) then $projectDefaultElementNamespace else $attrns}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@datatype=('set_cs','cs')">
                <xsl:choose>
                    <xsl:when test="string-length($attrpfx) = 0">
                        <xsl:attribute name="{$attrname}" select="'cs'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="{$attrname}" select="'cs'" namespace="{if (empty($attrns)) then $projectDefaultElementNamespace else $attrns}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@datatype=('int')">
                <xsl:variable name="int" select="if ($element/property/@minInclude) then ($element/property/@minInclude)[1] else (1)"/>
                <xsl:choose>
                    <xsl:when test="string-length($attrpfx) = 0">
                        <xsl:attribute name="{$attrname}" select="$int"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="{$attrname}" select="$int" namespace="{if (empty($attrns)) then $projectDefaultElementNamespace else $attrns}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@datatype=('real')">
                <xsl:variable name="int" select="if ($element/property[1]/@minInclude) then $element/property[1]/@minInclude else ('1')" as="xs:string"/>
                <xsl:variable name="intfrac" select="tokenize($int,'\.')[2]"/>
                <xsl:variable name="fractionDigits" select="if ($element/property[1]/@fractionDigits[matches(.,'\d')]) then xs:integer(replace($element/property[1]/@fractionDigits,'!','')) else (0)"/>
                <xsl:variable name="intfracadd" select="string-join(if (string-length($intfrac) lt $fractionDigits) then for $i in (1 to ($fractionDigits - string-length($intfrac))) return '0' else (),'')"/>
                <xsl:variable name="real" select="concat($int, if (not(contains($int,'.')) and string-length($intfracadd) gt 0) then '.' else (), $intfracadd)"/>
                <xsl:choose>
                    <xsl:when test="string-length($attrpfx) = 0">
                        <xsl:attribute name="{$attrname}" select="$real"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="{$attrname}" select="$real" namespace="{if (empty($attrns)) then $projectDefaultElementNamespace else $attrns}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@datatype=('st')">
                <xsl:choose>
                    <xsl:when test="string-length($attrpfx) = 0">
                        <xsl:attribute name="{$attrname}" select="$attributeName"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="{$attrname}" select="$attributeName" namespace="{if (empty($attrns)) then $projectDefaultElementNamespace else $attrns}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@datatype=('ts')">
                <xsl:variable name="ts" select="format-dateTime(current-dateTime(),'[Y0001][M01][D01][H01][m01][s01]','en',(),())"/>
                <xsl:choose>
                    <xsl:when test="string-length($attrpfx) = 0">
                        <xsl:attribute name="{$attrname}" select="$ts"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="{$attrname}" select="$ts" namespace="{if (empty($attrns)) then $projectDefaultElementNamespace else $attrns}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@datatype=('uid','oid')">
                <xsl:choose>
                    <xsl:when test="string-length($attrpfx) = 0">
                        <xsl:attribute name="{$attrname}" select="'1.2.3.999'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="{$attrname}" select="'1.2.3.999'" namespace="{if (empty($attrns)) then $projectDefaultElementNamespace else $attrns}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@datatype=('uuid')">
                <xsl:choose>
                    <xsl:when test="string-length($attrpfx) = 0">
                        <xsl:attribute name="{$attrname}" select="'550e8400-e29b-41d4-a716-446655440000'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="{$attrname}" select="'550e8400-e29b-41d4-a716-446655440000'" namespace="{if (empty($attrns)) then $projectDefaultElementNamespace else $attrns}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@datatype=('ruid')">
                <xsl:choose>
                    <xsl:when test="string-length($attrpfx) = 0">
                        <xsl:attribute name="{$attrname}" select="'FsLo5xllxHinTYAGyEVldE'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="{$attrname}" select="'FsLo5xllxHinTYAGyEVldE'" namespace="{if (empty($attrns)) then $projectDefaultElementNamespace else $attrns}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="string-length($attrpfx) = 0">
                        <xsl:attribute name="{$attrname}" select="'--TODO--'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="{$attrname}" select="'--TODO--'" namespace="{if (empty($attrns)) then $projectDefaultElementNamespace else $attrns}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc/>
        <xd:param name="processedTemplates"/>
        <xd:param name="doSelected"/>
    </xd:doc>
    <xsl:template match="element" mode="doExampleHL7V2">
        <xsl:param name="processedTemplates" as="xs:string*"/>
        <xsl:param name="doSelected" as="xs:string"/>
        <xsl:variable name="parentElement" select="."/>
        <xsl:variable name="attributes" select="local:normalizeAttributes(attribute)" as="element()*"/>
        <xsl:choose>
            <xsl:when test=".[@selected or not($doSelected = 'true')][not(@conformance='NP')]">
                <!-- strip namespace prefix and predicate from element/@name -->
                <xsl:variable name="elmpfx" select="substring-before(@name,':')"/>
                <xsl:variable name="elmns" select="if ($elmpfx=('cda','',())) then () else if ($elmpfx='art') then 'urn:art-decor:example' else (namespace-uri-for-prefix($elmpfx, ancestor::template))"/>
                <xsl:variable name="elmname" select="replace(@name,'^([^:]+:)?([^\s\[]+)\s*(\[.*)?','$2')"/>
                
                <!-- poor mans solution for INT.POS, AD.NL and other flavors. Should check DECOR-supported-datatypes.xml -->
                <xsl:variable name="theDatatype">
                    <xsl:variable name="dt" as="item()*">
                        <xsl:choose>
                            <xsl:when test="@datatype">
                                <xsl:value-of select="@datatype"/>
                            </xsl:when>
                            <xsl:when test=".[$elmname = 'OBX.5']/preceding-sibling::element[replace(@name,'^([^:]+:)?([^\s\[]+)\s*(\[.*)?','$2') = 'OBX.2'][text]">
                                <xsl:value-of select="preceding-sibling::element[replace(@name,'^([^:]+:)?([^\s\[]+)\s*(\[.*)?','$2') = 'OBX.2']/text[1]"/>
                            </xsl:when>
                            <xsl:when test="$attributes[@name = 'Type'][@value]">
                                <xsl:value-of select="$attributes[@name = 'Type']/@value"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:value-of select="if (contains($dt[1],':')) then substring-after($dt[1],':') else data($dt[1])"/>
                </xsl:variable>
                <xsl:element name="{if (empty($elmns)) then (if ($elmname = '') then 'noname' else $elmname) else QName($elmns, $elmname)}" namespace="{if (empty($elmns)) then $projectDefaultElementNamespace else $elmns}">
                    <xsl:if test="@originalType = 'ANY'">
                        <xsl:attribute name="xsi:type" select="$theDatatype"/>
                    </xsl:if>
                    <!--<xsl:if test=".[not(@contains | include | choice | element | text)]">-->
                    <xsl:for-each-group select="$attributes[@selected or not($doSelected = 'true')][not(@prohibited = 'true')]" group-by="@name">
                        <xsl:if test="current-group()[1]">
                            <xsl:apply-templates select="current-group()[1]" mode="#current">
                                <xsl:with-param name="processedTemplates" select="$processedTemplates"/>
                                <xsl:with-param name="element" select="$parentElement"/>
                                <xsl:with-param name="doSelected" select="$doSelected"/>
                            </xsl:apply-templates>
                        </xsl:if>
                    </xsl:for-each-group>
                    <!--</xsl:if>-->
                    <xsl:choose>
                        <xsl:when test="(@contains | element | include | choice | text) or empty($theDatatype)">
                            <!-- Don't do it -->
                        </xsl:when>
                        <xsl:when test="$theDatatype[. = ('CD','CE','CNE','CWE','IS','ID')]">
                            <xsl:choose>
                                <!-- check element vocabulary -->
                                <xsl:when test="vocabulary/@valueSet">
                                    <xsl:variable name="vsref" select="(vocabulary/@valueSet)[1]"/>
                                    <xsl:variable name="vsflex" select="(vocabulary[@valueSet])[1]/@flexibility"/>
                                    <xsl:variable name="firstCode" select="local:getValueset($vsref, $vsflex)//conceptList/concept[not(@type = ('D','A'))]" as="element()*"/>
                                    <xsl:if test="$firstCode">
                                        <xsl:element name="{$theDatatype}.1" namespace="{if (empty($elmns)) then $projectDefaultElementNamespace else $elmns}">
                                            <xsl:value-of select="$firstCode[1]/@code"/>
                                        </xsl:element>
                                        <xsl:if test="not($theDatatype = ('ID', 'IS'))">
                                            <xsl:if test="$firstCode[1]/@codeSystem">
                                                <xsl:element name="{$theDatatype}.2" namespace="{if (empty($elmns)) then $projectDefaultElementNamespace else $elmns}">
                                                    <xsl:value-of select="$firstCode[1]/@displayName"/>
                                                </xsl:element>
                                            </xsl:if>
                                            <xsl:if test="$firstCode[1]/@codeSystem">
                                                <xsl:element name="{$theDatatype}.3" namespace="{if (empty($elmns)) then $projectDefaultElementNamespace else $elmns}">
                                                    <xsl:value-of select="$firstCode[1]/@codeSystem"/>
                                                </xsl:element>
                                            </xsl:if>
                                        </xsl:if>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="vocabulary/@code">
                                    <xsl:element name="{$theDatatype}.1" namespace="{if (empty($elmns)) then $projectDefaultElementNamespace else $elmns}">
                                        <xsl:value-of select="vocabulary[@code][1]/@code"/>
                                    </xsl:element>
                                    <xsl:if test="not($theDatatype = ('ID', 'IS'))">
                                        <xsl:if test="vocabulary[@code][1]/@displayName">
                                            <xsl:element name="{$theDatatype}.2" namespace="{if (empty($elmns)) then $projectDefaultElementNamespace else $elmns}">
                                                <xsl:value-of select="vocabulary[@codeSystem][1]/@displayName"/>
                                            </xsl:element>
                                        </xsl:if>
                                        <xsl:if test="vocabulary[@code][1]/@codeSystem">
                                            <xsl:element name="{$theDatatype}.3" namespace="{if (empty($elmns)) then $projectDefaultElementNamespace else $elmns}">
                                                <xsl:value-of select="vocabulary[@codeSystem][1]/@codeSystem"/>
                                            </xsl:element>
                                        </xsl:if>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="vocabulary/@codeSystem">
                                    <xsl:element name="{$theDatatype}.1" namespace="{if (empty($elmns)) then $projectDefaultElementNamespace else $elmns}">
                                        <xsl:value-of select="'--code--'"/>
                                    </xsl:element>
                                    <xsl:if test="not($theDatatype = ('ID', 'IS'))">
                                        <xsl:if test="vocabulary[@codeSystem][1]/@displayName">
                                            <xsl:element name="{$theDatatype}.2" namespace="{if (empty($elmns)) then $projectDefaultElementNamespace else $elmns}">
                                                <xsl:value-of select="vocabulary[@codeSystem][1]/@displayName"/>
                                            </xsl:element>
                                        </xsl:if>
                                        <xsl:if test="vocabulary[@codeSystem][1]/@codeSystem">
                                            <xsl:element name="{$theDatatype}.3" namespace="{if (empty($elmns)) then $projectDefaultElementNamespace else $elmns}">
                                                <xsl:value-of select="vocabulary[@codeSystem][1]/@codeSystem"/>
                                            </xsl:element>
                                        </xsl:if>
                                    </xsl:if>
                                </xsl:when>
                                <!-- these table indicators are textual references, e.g. HL70127 that likely do not resolve in a 
                                    normal fashion, hence we also check the repositories directly. The valueSet/@name should have 
                                    this reference in the appropriate repository -->
                                <xsl:when test="$attributes[@name = 'Table'][@value]">
                                    <xsl:variable name="vsref" select="$attributes[@name='Table']/@value"/>
                                    <xsl:variable name="vsflex" select="()"/>
                                    <xsl:variable name="firstCode" select="local:getValueset($vsref, $vsflex)//conceptList/concept[not(@type = ('D','A'))]" as="element()*"/>
                                    <xsl:if test="$firstCode">
                                        <xsl:element name="{if (empty($elmns)) then (if ($elmname = '') then 'noname' else $elmname) else QName($elmns, $elmname)}.1" namespace="{if (empty($elmns)) then $projectDefaultElementNamespace else $elmns}">
                                            <xsl:value-of select="$firstCode[1]/@code"/>
                                        </xsl:element>
                                        <xsl:if test="not($theDatatype = ('ID', 'IS'))">
                                            <xsl:if test="$firstCode[1]/@codeSystem">
                                                <xsl:element name="{if (empty($elmns)) then (if ($elmname = '') then 'noname' else $elmname) else QName($elmns, $elmname)}.2" namespace="{if (empty($elmns)) then $projectDefaultElementNamespace else $elmns}">
                                                    <xsl:value-of select="$firstCode[1]/@displayName"/>
                                                </xsl:element>
                                            </xsl:if>
                                            <xsl:if test="$firstCode[1]/@codeSystem">
                                                <xsl:element name="{if (empty($elmns)) then (if ($elmname = '') then 'noname' else $elmname) else QName($elmns, $elmname)}.3" namespace="{if (empty($elmns)) then $projectDefaultElementNamespace else $elmns}">
                                                    <xsl:value-of select="$firstCode[1]/@codeSystem"/>
                                                </xsl:element>
                                            </xsl:if>
                                        </xsl:if>
                                    </xsl:if>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="text">
                            <xsl:element name="{$theDatatype}.1" namespace="{if (empty($elmns)) then $projectDefaultElementNamespace else $elmns}">
                                <xsl:value-of select="text[1]"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="$theDatatype = ('AD','XAD')">
                            <xsl:element name="{$theDatatype}.1" namespace="{if (empty($elmns)) then $projectDefaultElementNamespace else $elmns}">
                                <xsl:value-of select="$elmname"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="$theDatatype = ('BL','BN')">
                            <xsl:element name="{$theDatatype}.1" namespace="{if (empty($elmns)) then $projectDefaultElementNamespace else $elmns}">
                                <xsl:value-of select="false()"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="$theDatatype = ('NM','NM.POS','NM.NONNEG')">
                            <xsl:variable name="int" select="if (property/@minInclude) then (property/@minInclude)[1] else (1)"/>
                            <xsl:element name="{tokenize($theDatatype, '\.')[1]}.1" namespace="{if (empty($elmns)) then $projectDefaultElementNamespace else $elmns}">
                                <xsl:value-of select="$int"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="$theDatatype = ('TN','XTN')">
                            <xsl:element name="{$theDatatype}.1" namespace="{if (empty($elmns)) then $projectDefaultElementNamespace else $elmns}">
                                <xsl:value-of select="'tel:+1-12345678'"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="$theDatatype = ('TS','DTM')">
                            <xsl:element name="{$theDatatype}.1" namespace="{if (empty($elmns)) then $projectDefaultElementNamespace else $elmns}">
                                <xsl:value-of select="format-dateTime(current-dateTime(),'[Y0001][M01][D01][H01][m01][s01]','en',(),())"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="$theDatatype = ('TS.DATE','DT')">
                            <xsl:element name="{tokenize($theDatatype, '\.')[1]}.1" namespace="{if (empty($elmns)) then $projectDefaultElementNamespace else $elmns}">
                                <xsl:value-of select="format-dateTime(current-dateTime(),'[Y0001][M01][D01]','en',(),())"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="$theDatatype = ('TM')">
                            <xsl:element name="{$theDatatype}.1" namespace="{if (empty($elmns)) then $projectDefaultElementNamespace else $elmns}">
                                <xsl:value-of select="format-dateTime(current-dateTime(),'[H01][m01][s01]','en',(),())"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="$theDatatype = ('SI')">
                            <!-- SetID -->
                            <xsl:element name="{$theDatatype}.1" namespace="{if (empty($elmns)) then $projectDefaultElementNamespace else $elmns}">
                                <xsl:value-of select="1"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when test="$theDatatype = ('ON','PN','XON','XPN')">
                            <xsl:element name="{$theDatatype}.1" namespace="{if (empty($elmns)) then $projectDefaultElementNamespace else $elmns}">
                                <xsl:value-of select="$elmname"/>
                            </xsl:element>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:if test=".[not(@contains | element  | include | choice | text)][$theDatatype = ('EN','ON','PN','TN','ADXP','ENXP','SC','AD','ENXP','ADXP','ST')]">
                        <xsl:choose>
                            <xsl:when test="$elmname = 'delimiter'">-</xsl:when>
                            <xsl:when test="$elmname = 'houseNumberNumeric'">1</xsl:when>
                            <xsl:when test="$elmname = 'postBox'">12345</xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$elmname"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                    <xsl:for-each select="element | include | choice">
                        <xsl:apply-templates select="." mode="#current">
                            <xsl:with-param name="processedTemplates" select="$processedTemplates"/>
                            <xsl:with-param name="doSelected" select="$doSelected"/>
                        </xsl:apply-templates>
                    </xsl:for-each>
                    <xsl:if test="@contains">
                        <xsl:variable name="tmref" select="@contains"/>
                        <xsl:variable name="tmflex" select="if (@flexibility) then @flexibility else ('dynamic')"/>
                        <xsl:variable name="theTemplate" select="local:getTemplate($tmref, $tmflex)" as="element(template)?"/>
                        <xsl:variable name="chtmid">
                            <xsl:choose>
                                <xsl:when test="$theTemplate[@id]">
                                    <xsl:value-of select="$theTemplate/@id"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$tmref"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="chtmed">
                            <xsl:choose>
                                <xsl:when test="$theTemplate[@effectiveDate]">
                                    <xsl:value-of select="$theTemplate/@effectiveDate"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$tmflex"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="chtmnm">
                            <xsl:choose>
                                <xsl:when test="$theTemplate[@displayName]">
                                    <xsl:value-of select="$theTemplate/@displayName"/>
                                </xsl:when>
                                <xsl:when test="$theTemplate[@name]">
                                    <xsl:value-of select="$theTemplate/@name"/>
                                </xsl:when>
                                <xsl:otherwise>?</xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="$doRecursive = 'true'">
                                <xsl:choose>
                                    <xsl:when test="$processedTemplates = concat($chtmid, $chtmed)">
                                        <xsl:comment>
                                            <xsl:value-of select="concat('Recursion detected. Template ', $chtmid, ' ', $chtmnm, ' (', $chtmed,') has already been processed')"/>
                                        </xsl:comment>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:if test="$theTemplate[attribute]">
                                            <xsl:variable name="parentElement" select="."/>
                                            <xsl:variable name="attributes" select="local:normalizeAttributes($parentElement/attribute[not(@prohibited='true')])"/>
                                            <xsl:variable name="childattributes" select="local:normalizeAttributes($theTemplate/attribute[not(@prohibited='true')])"/>
                                            <xsl:choose>
                                                <xsl:when test=".[text | element | include | choice]">
                                                    <xsl:copy-of select="error(xs:QName('error:AttributeOutsideOfElement'),concat('Template ', $parentElement/ancestor::template/@id, ' ', $parentElement/ancestor::template/@effectiveDate, '. Element ',$parentElement/@name, ' includes template ', $chtmid, ' ', $chtmed, ' with top level attributes, but element has child elements. The attribute would thus be created after the element, not on the element'))"/>
                                                </xsl:when>
                                                <xsl:when test="$childattributes[@name = $attributes/@name]">
                                                    <xsl:copy-of select="error(xs:QName('error:AttributeDuplication'),concat('Template ', $parentElement/ancestor::template/@id, ' ', $parentElement/ancestor::template/@effectiveDate, '. Element ', $parentElement/@name, ' includes template ', $chtmid, ' ', $chtmed, ' with top level attributes that dupliucate one or more attributes defined on the element: ', string-join($childattributes[@name = $attributes/@name]/@name, ' ')))"/>
                                                </xsl:when>
                                                <xsl:when test="$parentElement[@datatype]">
                                                    <!-- avoid risk of recreating attributes that were created before on the parent -->
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:for-each select="$attributes">
                                                        <xsl:apply-templates select="." mode="#current">
                                                            <xsl:with-param name="processedTemplates" select="($processedTemplates, concat($chtmid, $chtmed))" as="xs:string*"/>
                                                            <xsl:with-param name="doSelected" select="'false'"/>
                                                        </xsl:apply-templates>
                                                    </xsl:for-each>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:if>
                                        <xsl:for-each select="$theTemplate/element | $theTemplate/include | $theTemplate/choice">
                                            <xsl:apply-templates select="." mode="#current">
                                                <xsl:with-param name="processedTemplates" select="$processedTemplates, concat($chtmid, $chtmed)"/>
                                                <xsl:with-param name="doSelected" select="'false'"/>
                                            </xsl:apply-templates>
                                        </xsl:for-each>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:text>
</xsl:text>
                        <xsl:comment>
                            <xsl:value-of select="concat(' template ',$chtmid,' ''',$chtmnm,''' (',$chtmed,') ')"/>
                        </xsl:comment>
                    </xsl:if>
                </xsl:element>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc/>
        <xd:param name="id"/>
        <xd:param name="effectiveDate"/>
    </xd:doc>
    <xsl:function name="local:getTemplate" as="element(template)?">
        <xsl:param name="id" as="xs:string?"/>
        <xsl:param name="effectiveDate" as="xs:string?"/>
        <xsl:variable name="templates" as="element(template)*">
            <xsl:choose>
                <xsl:when test="matches($id, '^[\d\.]+$')">
                    <xsl:copy-of select="$theDecor/key('allTemplatesById', $id)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="$theDecor/key('allTemplatesByName', $id)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$effectiveDate castable as xs:dateTime">
                <xsl:copy-of select="$templates[@effectiveDate = $effectiveDate]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$templates[@effectiveDate = string(max($templates/xs:dateTime(@effectiveDate)))][1]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xd:doc>
        <xd:desc/>
        <xd:param name="id"/>
        <xd:param name="effectiveDate"/>
    </xd:doc>
    <xsl:function name="local:getValueset" as="element(valueSet)?">
        <xsl:param name="id" as="xs:string?"/>
        <xsl:param name="effectiveDate" as="xs:string?"/>
        <xsl:variable name="valuesets" as="element(valueSet)*">
            <xsl:choose>
                <xsl:when test="matches($id, '^[\d\.]+$')">
                    <xsl:copy-of select="$theDecor/key('allValuesetsById', $id)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="$theDecor/key('allValuesetsByName', $id)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$effectiveDate castable as xs:dateTime">
                <xsl:copy-of select="$valuesets[@effectiveDate = $effectiveDate]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$valuesets[@effectiveDate = string(max($valuesets/xs:dateTime(@effectiveDate)))][1]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xd:doc>
        <xd:desc/>
        <xd:param name="element"/>
    </xd:doc>
    <xsl:function name="local:processCardConf" as="xs:string">
        <xsl:param name="element" as="element()"/>
        
        <xsl:variable name="min" select="$element[not(@conformance = 'NP')]/@minimumMultiplicity"/>
        <xsl:variable name="max" select="$element[not(@conformance = 'NP')]/@maximumMultiplicity"/>
        <xsl:variable name="conf">
            <xsl:choose>
                <xsl:when test="$element[@isMandatory ='true']">M</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$element/@conformance"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:value-of select="string-join((string-join($min|$max,'..'),$conf),' ')"/>
    </xsl:function>
    <xd:doc>
        <xd:desc>in older (hand created) templates people may have used double declarations in one attribute element, e.g. &lt;attribute classCode="OBS" moodCode="EVN"/&gt;. Also we might encounter a mix of name/value versus shorthands. Normalize before processing to name/value</xd:desc>
        <xd:param name="attributes"/>
    </xd:doc>
    <xsl:function name="local:normalizeAttributes" as="element(attribute)*">
        <xsl:param name="attributes" as="element(attribute)*"/>
        
        <xsl:for-each select="$attributes">
            <xsl:for-each select="(@name | @classCode | @contextConductionInd | @contextControlCode | @determinerCode | @extension | @independentInd | @institutionSpecified | @inversionInd | @mediaType | @moodCode | @negationInd | @nullFlavor | @operator | @qualifier | @representation | @root | @typeCode | @unit | @use)[not(. = '')]">
                <xsl:variable name="attributeName">
                    <xsl:choose>
                        <xsl:when test="name() = 'name'">
                            <xsl:value-of select="."/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="name()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="attributeValue">
                    <xsl:choose>
                        <xsl:when test="name() = 'name'">
                            <xsl:value-of select="../@value"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <attribute name="{$attributeName}">
                    <xsl:if test="string-length($attributeValue) &gt; 0">
                        <xsl:attribute name="value" select="$attributeValue"/>
                    </xsl:if>
                    <xsl:copy-of select="../@isOptional"/>
                    <xsl:copy-of select="../@prohibited"/>
                    <xsl:copy-of select="../@datatype"/>
                    <xsl:copy-of select="../node()"/>
                </attribute>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:function>
</xsl:stylesheet>