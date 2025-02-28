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
<xsl:stylesheet xmlns:local="http://art-decor.org/functions" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" exclude-result-prefixes="#all">
    <xsl:template match="attribute" mode="GEN">
        <xsl:param name="itemlabel"/>
        <xsl:param name="currentContext"/>
        <xsl:param name="uniqueId"/>
        <xsl:param name="seethisthingurl"/>
        <xsl:param name="contextSuffix"/>

        <!-- use the attribute's item/@label if any -->
        <xsl:variable name="attitem">
            <xsl:choose>
                <xsl:when test="item/@label">
                    <xsl:value-of select="item/@label"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$itemlabel"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- cache @isOptional -->
        <xsl:variable name="isOptional" select="@isOptional='true'" as="xs:boolean"/>
        <!-- cache @prohibited -->
        <xsl:variable name="isProhibited" select="@prohibited='true'" as="xs:boolean"/>
        
        <!-- get normalized attribute elements. Might be multiple in case of e.g.
             <attribute classCode="X" moodCode="Y"/>
        -->
        <xsl:variable name="attributes" as="element(attribute)*">
            <xsl:apply-templates select="." mode="NORMALIZE"/>
        </xsl:variable>
        
        <!-- 
            special
            @name
            @name + @value
            
            attribute specified in @name is required
            no choices
            if @value is present check whether attribute @name is valued correctly
        -->
        <!-- element/vocabulary[@valueSet] logic already handles nullFlavor, don't duplicate that here -->
        <xsl:variable name="parentHasValueSet" select="exists(../vocabulary[@valueSet])" as="xs:boolean"/>
        <xsl:for-each select="$attributes[@name][not(@name='nullFlavor' and $parentHasValueSet)]">
            <xsl:variable name="an" select="@name"/>
            
            <!-- This supports (even though we technically don't want to) constructs like
                <attribute name="root" value="1.2.3|4.5.6|7.8.9"/>
            -->
            <xsl:variable name="av" as="xs:string">
                <xsl:variable name="values" as="xs:string*">
                    <xsl:for-each select="tokenize(@value,'\|')">
                        <xsl:value-of select="replace(normalize-space(.),'''','''''')"/>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:value-of select="string-join($values,''',''')"/>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="$an='xsi:type' and string-length(@value)&gt;0">
                    <!-- 
                        Get namespace-uri for the @datatype.
                        1. If has namespace prefix hl7: or cda:, then must be in namespace 'urn:hl7-org:v3'
                        2. If has no namespace prefix, then must be in DECOR default namespace-uri
                        3. If has namespace prefix then get the namespace-uri form DECOR file
                    -->
                    <xsl:variable name="dfltNS">
                        <xsl:choose>
                            <xsl:when test="string-length($projectDefaultElementPrefix)=0">
                                <xsl:value-of select="'urn:hl7-org:v3'"/>
                            </xsl:when>
                            <xsl:when test="$projectDefaultElementPrefix=('hl7:','cda:')">
                                <xsl:value-of select="'urn:hl7-org:v3'"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="namespace-uri-for-prefix(substring-before($projectDefaultElementPrefix,':'),.)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="dtPfx" select="substring-before(@value,':')"/>
                    <xsl:variable name="dtNS">
                        <xsl:choose>
                            <xsl:when test="$dtPfx='hl7' or $dtPfx='cda'">
                                <xsl:value-of select="'urn:hl7-org:v3'"/>
                            </xsl:when>
                            <xsl:when test="$dtPfx=''">
                                <xsl:value-of select="$dfltNS"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="namespace-uri-for-prefix($dtPfx,$allDECOR)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="dtVal" select="if (contains(@value,':')) then (substring-after(@value,':')) else (@value)"/>

                    <!-- Note that different versions of Saxon interpret QName differently. You cannot assume that casting @xsi:type to QName works, hence the substring-* functions -->
                    <let name="xsiLocalName" value="if (contains(@xsi:type, ':')) then substring-after(@xsi:type,':') else @xsi:type"/>
                    <let name="xsiLocalNS" value="if (contains(@xsi:type, ':')) then namespace-uri-for-prefix(substring-before(@xsi:type,':'),.) else namespace-uri-for-prefix('',.)"/>

                    <!-- check for the presence of xsi:type and if present check correct data type requested -->
                    <xsl:variable name="theTest">
                        <xsl:text>@nullFlavor or ($xsiLocalName='</xsl:text>
                        <xsl:value-of select="$dtVal"/>
                        <xsl:text>' and $xsiLocalNS='</xsl:text>
                        <xsl:value-of select="$dtNS"/>
                        <xsl:text>')</xsl:text>
                        <xsl:if test="$isOptional=true()">
                            <xsl:text> or not(@</xsl:text>
                            <xsl:value-of select="$an"/>
                            <xsl:text>)</xsl:text>
                        </xsl:if>
                    </xsl:variable>
                    <assert role="error" see="{$seethisthingurl}" test="{$theTest}">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'datatypeXSIShallBe'"/>
                            <xsl:with-param name="p1" select="$itemlabel"/>
                            <xsl:with-param name="p2">
                                <xsl:value-of select="$dtVal"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </assert>
                </xsl:when>
                <!-- check for @name @value pair, then attribute @name SHALL be of value @value -->
                <xsl:when test="string-length(@value)&gt;0">
                    <xsl:variable name="theTest">
                        <xsl:text>string(@</xsl:text>
                        <xsl:value-of select="$an"/>
                        <xsl:text>)=('</xsl:text>
                        <xsl:value-of select="$av"/>
                        <xsl:text>')</xsl:text>
                        <xsl:if test="$isOptional=true()">
                            <xsl:text> or not(@</xsl:text>
                            <xsl:value-of select="$an"/>
                            <xsl:text>)</xsl:text>
                        </xsl:if>
                    </xsl:variable>
                    <assert role="error" see="{$seethisthingurl}" test="{$theTest}">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'attribValue'"/>
                            <xsl:with-param name="p1" select="$attitem"/>
                            <xsl:with-param name="p2" select="concat('@', $an)"/>
                            <xsl:with-param name="p3" select="$av"/>
                        </xsl:call-template>
                    </assert>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="not($isProhibited or $isOptional)">
                        <xsl:variable name="theTest">
                            <xsl:text>@</xsl:text>
                            <xsl:value-of select="$an"/>
                        </xsl:variable>
                        <assert role="error" see="{$seethisthingurl}" test="{$theTest}">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'attribPresent'"/>
                                <xsl:with-param name="p1" select="$attitem"/>
                                <xsl:with-param name="p2" select="$an"/>
                            </xsl:call-template>
                        </assert>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        
        <!-- 
            special
            @prohibited
            
            attributes specified along with @prohibited are not permitted
            no choices
        -->
        <xsl:if test="$isProhibited">
            <assert role="error" see="{$seethisthingurl}" test="not(@{./@name})">
                <xsl:call-template name="getMessage">
                    <xsl:with-param name="key" select="'attribProhibited'"/>
                    <xsl:with-param name="p1" select="$attitem"/>
                    <xsl:with-param name="p2" select="@name"/>
                </xsl:call-template>
            </assert>
        </xsl:if>
        
        <!-- 
            element content DEPRECATED
            no choices
        -->
        <xsl:if test="@elementContent">
            <assert role="error" see="{$seethisthingurl}" test="text()='{@elementContent}'">
                <xsl:call-template name="getMessage">
                    <xsl:with-param name="key" select="'attribElmContent'"/>
                    <xsl:with-param name="p1" select="$attitem"/>
                    <xsl:with-param name="p2" select="$contextSuffix"/>
                    <xsl:with-param name="p3" select="@elementContent"/>
                </xsl:call-template>
            </assert>
        </xsl:if>

        <!-- special @datatype (for attribute). no need to check datatype when there is a fixed value -->
        <xsl:if test="string-length(@datatype)&gt;0">
            <xsl:variable name="hasFixedContents" select="string-length(@value) = 0 and not(vocabulary[@code | @codeSystem | @valueSet])"/>

            <!--
                for attributes this is only a very restricted set of data types
                a data type is allowed in context of <attribute name="..."... only
                then
                   <attribute name="x" datatype="st"/>
                means that @name must be of data type st.
                Allowed data types so far are: 
                bl (boolean)
                st (string, the default) 
                ts (timestamp)
                int (integer)
                real (real)
                cs (code)
                
                some not yet checked. 2DO
            -->
            <xsl:if test="string-length(@name)&gt;0">
                <!-- do data type check only if name is given -->
                <xsl:choose>
                    <xsl:when test="@datatype=('bl','bn')">
                        <xsl:if test="$attributes[@value][not(@value = ('true','false'))]">
                            <xsl:call-template name="logMessage">
                                <xsl:with-param name="level" select="$logERROR"/>
                                <xsl:with-param name="msg">
                                    <xsl:text>+++ Found attribute with a fixed value '</xsl:text>
                                    <xsl:value-of select="$attributes/@value"/>
                                    <xsl:text>' that is incompatible with the specified datatype '</xsl:text>
                                    <xsl:value-of select="@datatype"/>
                                    <xsl:text>' on attribute '</xsl:text>
                                    <xsl:value-of select="@name"/>
                                    <xsl:text>' (template '</xsl:text>
                                    <xsl:value-of select="ancestor::template/@name"/>
                                    <xsl:text>' </xsl:text>
                                    <xsl:value-of select="ancestor::template/@effectiveDate"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:if>
                        <xsl:if test="$hasFixedContents">
                            <assert role="error" see="{$seethisthingurl}" test="not(@{@name}) or string(@{@name})=('true','false')">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'attribShallBeOfDatatype'"/>
                                    <xsl:with-param name="p1" select="$attitem"/>
                                    <xsl:with-param name="p2" select="concat('@', @name)"/>
                                    <xsl:with-param name="p3" select="@datatype"/>
                                </xsl:call-template>
                            </assert>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="@datatype='uid'">
                        <xsl:if test="$attributes[@value][not(matches(@value, $OIDpattern) or matches(@value, $UUIDpattern) or matches(@value, $RUIDpattern))]">
                            <xsl:call-template name="logMessage">
                                <xsl:with-param name="level" select="$logERROR"/>
                                <xsl:with-param name="msg">
                                    <xsl:text>+++ Found attribute with a fixed value '</xsl:text>
                                    <xsl:value-of select="$attributes/@value"/>
                                    <xsl:text>' that is incompatible with the specified datatype '</xsl:text>
                                    <xsl:value-of select="@datatype"/>
                                    <xsl:text>' on attribute '</xsl:text>
                                    <xsl:value-of select="@name"/>
                                    <xsl:text>' (template '</xsl:text>
                                    <xsl:value-of select="ancestor::template/@name"/>
                                    <xsl:text>' </xsl:text>
                                    <xsl:value-of select="ancestor::template/@effectiveDate"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:if>
                        <xsl:if test="$hasFixedContents">
                            <assert role="error" see="{$seethisthingurl}" test="not(@{@name}) or matches(@{@name},'{$OIDpattern}') or matches(@{@name},'{$UUIDpattern}') or matches(@{@name},'{$RUIDpattern}')">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'attribShallBeOfDatatype'"/>
                                    <xsl:with-param name="p1" select="$attitem"/>
                                    <xsl:with-param name="p2" select="concat('@', @name)"/>
                                    <xsl:with-param name="p3" select="@datatype"/>
                                </xsl:call-template>
                            </assert>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="@datatype='oid'">
                        <xsl:if test="$attributes[@value][not(matches(@value, $OIDpattern))]">
                            <xsl:call-template name="logMessage">
                                <xsl:with-param name="level" select="$logERROR"/>
                                <xsl:with-param name="msg">
                                    <xsl:text>+++ Found attribute with a fixed value '</xsl:text>
                                    <xsl:value-of select="$attributes/@value"/>
                                    <xsl:text>' that is incompatible with the specified datatype '</xsl:text>
                                    <xsl:value-of select="@datatype"/>
                                    <xsl:text>' on attribute '</xsl:text>
                                    <xsl:value-of select="@name"/>
                                    <xsl:text>' (template '</xsl:text>
                                    <xsl:value-of select="ancestor::template/@name"/>
                                    <xsl:text>' </xsl:text>
                                    <xsl:value-of select="ancestor::template/@effectiveDate"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:if>
                        <xsl:if test="$hasFixedContents">
                            <assert role="error" see="{$seethisthingurl}" test="not(@{@name}) or matches(@{@name},'{$OIDpattern}')">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'attribShallBeOfDatatype'"/>
                                    <xsl:with-param name="p1" select="$attitem"/>
                                    <xsl:with-param name="p2" select="concat('@', @name)"/>
                                    <xsl:with-param name="p3" select="@datatype"/>
                                </xsl:call-template>
                            </assert>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="@datatype='uuid'">
                        <xsl:if test="$attributes[@value][not(matches(@value, $UUIDpattern))]">
                            <xsl:call-template name="logMessage">
                                <xsl:with-param name="level" select="$logERROR"/>
                                <xsl:with-param name="msg">
                                    <xsl:text>+++ Found attribute with a fixed value '</xsl:text>
                                    <xsl:value-of select="$attributes/@value"/>
                                    <xsl:text>' that is incompatible with the specified datatype '</xsl:text>
                                    <xsl:value-of select="@datatype"/>
                                    <xsl:text>' on attribute '</xsl:text>
                                    <xsl:value-of select="@name"/>
                                    <xsl:text>' (template '</xsl:text>
                                    <xsl:value-of select="ancestor::template/@name"/>
                                    <xsl:text>' </xsl:text>
                                    <xsl:value-of select="ancestor::template/@effectiveDate"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:if>
                        <xsl:if test="$hasFixedContents">
                            <assert role="error" see="{$seethisthingurl}" test="not(@{@name}) or matches(@{@name},'{$UUIDpattern}')">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'attribShallBeOfDatatype'"/>
                                    <xsl:with-param name="p1" select="$attitem"/>
                                    <xsl:with-param name="p2" select="concat('@', @name)"/>
                                    <xsl:with-param name="p3" select="@datatype"/>
                                </xsl:call-template>
                            </assert>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="@datatype='ruid'">
                        <xsl:if test="$attributes[@value][not(matches(@value, $RUIDpattern))]">
                            <xsl:call-template name="logMessage">
                                <xsl:with-param name="level" select="$logERROR"/>
                                <xsl:with-param name="msg">
                                    <xsl:text>+++ Found attribute with a fixed value '</xsl:text>
                                    <xsl:value-of select="$attributes/@value"/>
                                    <xsl:text>' that is incompatible with the specified datatype '</xsl:text>
                                    <xsl:value-of select="@datatype"/>
                                    <xsl:text>' on attribute '</xsl:text>
                                    <xsl:value-of select="@name"/>
                                    <xsl:text>' (template '</xsl:text>
                                    <xsl:value-of select="ancestor::template/@name"/>
                                    <xsl:text>' </xsl:text>
                                    <xsl:value-of select="ancestor::template/@effectiveDate"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:if>
                        <xsl:if test="$hasFixedContents">
                            <assert role="error" see="{$seethisthingurl}" test="not(@{@name}) or matches(@{@name},'{$RUIDpattern}')">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'attribShallBeOfDatatype'"/>
                                    <xsl:with-param name="p1" select="$attitem"/>
                                    <xsl:with-param name="p2" select="concat('@', @name)"/>
                                    <xsl:with-param name="p3" select="@datatype"/>
                                </xsl:call-template>
                            </assert>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="@datatype=('bin','st')">
                        <assert role="error" see="{$seethisthingurl}" test="not(@{@name}) or string-length(@{@name})&gt;0">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'attribShallBeOfDatatype'"/>
                                <xsl:with-param name="p1" select="$attitem"/>
                                <xsl:with-param name="p2" select="concat('@',@name)"/>
                                <xsl:with-param name="p3" select="@datatype"/>
                            </xsl:call-template>
                        </assert>
                    </xsl:when>
                    <xsl:when test="@datatype='cs'">
                        <xsl:if test="$attributes[@value][matches(@value, '\s')]">
                            <xsl:call-template name="logMessage">
                                <xsl:with-param name="level" select="$logERROR"/>
                                <xsl:with-param name="msg">
                                    <xsl:text>+++ Found attribute with a fixed value '</xsl:text>
                                    <xsl:value-of select="$attributes/@value"/>
                                    <xsl:text>' that is incompatible with the specified datatype '</xsl:text>
                                    <xsl:value-of select="@datatype"/>
                                    <xsl:text>' on attribute '</xsl:text>
                                    <xsl:value-of select="@name"/>
                                    <xsl:text>' (template '</xsl:text>
                                    <xsl:value-of select="ancestor::template/@name"/>
                                    <xsl:text>' </xsl:text>
                                    <xsl:value-of select="ancestor::template/@effectiveDate"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:if>
                        <xsl:if test="$hasFixedContents">
                            <assert role="error" see="{$seethisthingurl}" test="not(@{@name}) or (string-length(@{@name})&gt;0 and not(matches(@{@name},'\s')))">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'attribShallBeOfDatatype'"/>
                                    <xsl:with-param name="p1" select="$attitem"/>
                                    <xsl:with-param name="p2" select="concat('@', @name)"/>
                                    <xsl:with-param name="p3" select="@datatype"/>
                                </xsl:call-template>
                            </assert>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="@datatype='set_cs'">
                        <xsl:if test="$hasFixedContents">
                            <assert role="error" see="{$seethisthingurl}" test="not(@{@name}) or string-length(@{@name})&gt;0">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'attribShallBeOfDatatype'"/>
                                    <xsl:with-param name="p1" select="$attitem"/>
                                    <xsl:with-param name="p2" select="concat('@', @name)"/>
                                    <xsl:with-param name="p3" select="@datatype"/>
                                </xsl:call-template>
                            </assert>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="@datatype='ts'">
                        <xsl:if test="$attributes[@value][not(matches(@value, '^[0-9]{4,14}'))]">
                            <xsl:call-template name="logMessage">
                                <xsl:with-param name="level" select="$logERROR"/>
                                <xsl:with-param name="msg">
                                    <xsl:text>+++ Found attribute with a fixed value '</xsl:text>
                                    <xsl:value-of select="$attributes/@value"/>
                                    <xsl:text>' that is incompatible with the specified datatype '</xsl:text>
                                    <xsl:value-of select="@datatype"/>
                                    <xsl:text>' on attribute '</xsl:text>
                                    <xsl:value-of select="@name"/>
                                    <xsl:text>' (template '</xsl:text>
                                    <xsl:value-of select="ancestor::template/@name"/>
                                    <xsl:text>' </xsl:text>
                                    <xsl:value-of select="ancestor::template/@effectiveDate"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:if>
                        <xsl:if test="$hasFixedContents">
                            <assert role="error" see="{$seethisthingurl}" test="not(@{@name}) or matches(string(@{@name}), '^[0-9]{{4,14}}')">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'attribShallBeOfDatatype'"/>
                                    <xsl:with-param name="p1" select="$attitem"/>
                                    <xsl:with-param name="p2" select="concat('@', @name)"/>
                                    <xsl:with-param name="p3" select="@datatype"/>
                                </xsl:call-template>
                            </assert>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="@datatype='int'">
                        <xsl:if test="$attributes[@value][not(matches(@value, $INTdigits))]">
                            <xsl:call-template name="logMessage">
                                <xsl:with-param name="level" select="$logERROR"/>
                                <xsl:with-param name="msg">
                                    <xsl:text>+++ Found attribute with a fixed value '</xsl:text>
                                    <xsl:value-of select="$attributes/@value"/>
                                    <xsl:text>' that is incompatible with the specified datatype '</xsl:text>
                                    <xsl:value-of select="@datatype"/>
                                    <xsl:text>' on attribute '</xsl:text>
                                    <xsl:value-of select="@name"/>
                                    <xsl:text>' (template '</xsl:text>
                                    <xsl:value-of select="ancestor::template/@name"/>
                                    <xsl:text>' </xsl:text>
                                    <xsl:value-of select="ancestor::template/@effectiveDate"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:if>
                        <xsl:if test="$hasFixedContents">
                            <assert role="error" see="{$seethisthingurl}" test="not(@{@name}) or matches(string(@{@name}), '{$INTdigits}')">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'attribNotAValidDatatypeNumber'"/>
                                    <xsl:with-param name="p1" select="$attitem"/>
                                    <xsl:with-param name="p2" select="concat('@', @name)"/>
                                    <xsl:with-param name="p3" select="@datatype"/>
                                </xsl:call-template>
                                <value-of select="@{@name}"/>
                            </assert>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="@datatype='real'">
                        <xsl:if test="$attributes[@value][not(matches(@value, $REALdigits))]">
                            <xsl:call-template name="logMessage">
                                <xsl:with-param name="level" select="$logERROR"/>
                                <xsl:with-param name="msg">
                                    <xsl:text>+++ Found attribute with a fixed value '</xsl:text>
                                    <xsl:value-of select="$attributes/@value"/>
                                    <xsl:text>' that is incompatible with the specified datatype '</xsl:text>
                                    <xsl:value-of select="@datatype"/>
                                    <xsl:text>' on attribute '</xsl:text>
                                    <xsl:value-of select="@name"/>
                                    <xsl:text>' (template '</xsl:text>
                                    <xsl:value-of select="ancestor::template/@name"/>
                                    <xsl:text>' </xsl:text>
                                    <xsl:value-of select="ancestor::template/@effectiveDate"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:if>
                        <xsl:if test="$hasFixedContents">
                            <assert role="error" see="{$seethisthingurl}" test="not(@{@name}) or matches(string(@{@name}), '{$REALdigits}')">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'attribNotAValidDatatypeNumber'"/>
                                    <xsl:with-param name="p1" select="$attitem"/>
                                    <xsl:with-param name="p2" select="concat('@', @name)"/>
                                    <xsl:with-param name="p3" select="@datatype"/>
                                </xsl:call-template>
                                <value-of select="@{@name}"/>
                            </assert>
                        </xsl:if>
                    </xsl:when>
                    <!-- CDA -->
                    <xsl:when test="@datatype=('xs:ID','xs:IDREF','xs:IDREFS')">
                        <!--Fixed checking xs:ID, xs:IDREF, xs:IDREFS so it does not lead to errors when run through eXist-db with Saxon-PE-->
                        <xsl:if test="(@datatype=('xs:ID','xs:IDREF') and not($attributes[matches(@value, '^([\i-[:]][\c-[:]]*)$')])) or
                                      (@datatype=('xs:IDREFS') and not($attributes[matches(@value, '^([\i-[:]][\c-[:]]*)+( [\i-[:]][\c-[:]]*)*$')]))">
                        <!--<xsl:if test="$attributes[@value][@value castable as xs:ID or @value castable as xs:IDREF or @value castable as xs:IDREFS)]">-->
                            <xsl:call-template name="logMessage">
                                <xsl:with-param name="level" select="$logERROR"/>
                                <xsl:with-param name="msg">
                                    <xsl:text>+++ Found attribute with a fixed value '</xsl:text>
                                    <xsl:value-of select="$attributes/@value"/>
                                    <xsl:text>' that is incompatible with the specified datatype '</xsl:text>
                                    <xsl:value-of select="@datatype"/>
                                    <xsl:text>' on attribute '</xsl:text>
                                    <xsl:value-of select="@name"/>
                                    <xsl:text>' (template '</xsl:text>
                                    <xsl:value-of select="ancestor::template/@name"/>
                                    <xsl:text>' </xsl:text>
                                    <xsl:value-of select="ancestor::template/@effectiveDate"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:if>
                        <xsl:if test="$hasFixedContents">
                            <assert role="error" see="{$seethisthingurl}" test="not(@{@name}) or string(@{@name}) castable as {@datatype}">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'attribShallBeOfDatatype'"/>
                                    <xsl:with-param name="p1" select="$attitem"/>
                                    <xsl:with-param name="p2" select="concat('@', @name)"/>
                                    <xsl:with-param name="p3" select="@datatype"/>
                                </xsl:call-template>
                                <value-of select="@{@name}"/>
                            </assert>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="@datatype='url'">
                        <xsl:if test="$attributes[@value][not(@value castable as xs:anyURI)]">
                            <xsl:call-template name="logMessage">
                                <xsl:with-param name="level" select="$logERROR"/>
                                <xsl:with-param name="msg">
                                    <xsl:text>+++ Found attribute with a fixed value '</xsl:text>
                                    <xsl:value-of select="$attributes/@value"/>
                                    <xsl:text>' that is incompatible with the specified datatype '</xsl:text>
                                    <xsl:value-of select="@datatype"/>
                                    <xsl:text>' on attribute '</xsl:text>
                                    <xsl:value-of select="@name"/>
                                    <xsl:text>' (template '</xsl:text>
                                    <xsl:value-of select="ancestor::template/@name"/>
                                    <xsl:text>' </xsl:text>
                                    <xsl:value-of select="ancestor::template/@effectiveDate"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:if>
                        <xsl:if test="$hasFixedContents">
                            <assert role="error" see="{$seethisthingurl}" test="not(@{@name}) or string(@{@name} castable as xs:anyURI)">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'attribShallBeOfDatatype'"/>
                                    <xsl:with-param name="p1" select="$attitem"/>
                                    <xsl:with-param name="p2" select="concat('@', @name)"/>
                                    <xsl:with-param name="p3" select="@datatype"/>
                                </xsl:call-template>
                                <value-of select="@{@name}"/>
                            </assert>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="logMessage">
                            <xsl:with-param name="level" select="$logWARN"/>
                            <xsl:with-param name="msg">
                                <xsl:text>+++ Found unsupported datatype '</xsl:text>
                                <xsl:value-of select="@datatype"/>
                                <xsl:text>' on attribute '</xsl:text>
                                <xsl:value-of select="@name"/>
                                <xsl:text>' (template '</xsl:text>
                                <xsl:value-of select="ancestor::template/@name"/>
                                <xsl:text>' </xsl:text>
                                <xsl:value-of select="ancestor::template/@effectiveDate"/>
                                <xsl:text>)</xsl:text>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:if>

        <!-- element/vocabulary[@valueSet] logic already handles nullFlavor, don't duplicate that here -->
        <xsl:if test="@name[not(.='nullFlavor' and ../vocabulary[@valueSet])] and vocabulary[@code | @valueSet]">
            <!-- 
                handle vocabulary @code for attributes, e.g.
                <attribute name="mediaType">
                  <vocabulary code="image/gif"/>
                  <vocabulary code="image/jpg"/>
                  <vocabulary code="image/png"/>
                </attribute>
            -->
            <xsl:variable name="theAttName" select="@name"/>
            <xsl:variable name="cdexpr">
                <xpr>
                    <xsl:if test="vocabulary[@code]">
                        <code>
                            <xsl:attribute name="dn">
                                <xsl:text>for $code in tokenize(@</xsl:text>
                                <xsl:value-of select="$theAttName"/>
                                <xsl:text>,' ') return if ($code=('</xsl:text>
                                <xsl:value-of select="string-join(vocabulary/@code,''',''')"/>
                                <xsl:text>')) then ($code) else ()</xsl:text>
                            </xsl:attribute>
                        </code>
                    </xsl:if>
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
                                        <xsl:value-of select="$currentContext"/>
                                        <xsl:text>)</xsl:text>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="($xvs/valueSet)[1]/conceptList/concept">
                                <xsl:variable name="valueSetFileObject" select="concat($theRuntimeRelativeIncludeDir, local:doHtmlName('VS', $projectPrefix, $xvsid, $xvsflex, (), (), (), (), '.xml', 'true'))"/>
                                
                                <valueset>
                                    <xsl:attribute name="dn">
                                        <xsl:text>doc('</xsl:text>
                                        <xsl:value-of select="$valueSetFileObject"/>
                                        <xsl:text>')/*/valueSet</xsl:text>
                                        <xsl:text>/conceptList/concept[@code = $theAttValue]</xsl:text>
                                        <xsl:text>/@code</xsl:text>
                                    </xsl:attribute>
                                </valueset>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="logMessage">
                                    <xsl:with-param name="level" select="$logWARN"/>
                                    <xsl:with-param name="msg">
                                        <xsl:text>+++ value set skipped for use in schematron as it binds to an attribute but has no concepts - </xsl:text>
                                        <xsl:text>value set </xsl:text>
                                        <xsl:value-of select="$xvsref"/>
                                        <xsl:text>: </xsl:text>
                                        <xsl:value-of select="$xvsflex"/>
                                        <xsl:text> in rule </xsl:text>
                                        <xsl:value-of select="ancestor::template/@name"/>
                                        <xsl:text>: </xsl:text>
                                        <xsl:value-of select="ancestor::template/@effectiveDate"/>
                                        <xsl:text> (context=</xsl:text>
                                        <xsl:value-of select="$currentContext"/>
                                        <xsl:text>)</xsl:text>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xpr>
            </xsl:variable>
            <xsl:variable name="cderr">
                <xsl:for-each select="vocabulary[@code]">
                    <xsl:variable name="codeWord">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'code'"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:value-of select="normalize-space($codeWord)"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="@code"/>
                    <xsl:if test="position() != last()">
                        <xsl:text> </xsl:text>
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'orWord'"/>
                        </xsl:call-template>
                        <xsl:text> </xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <xsl:if test="vocabulary[@code] and vocabulary[@valueSet]">
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="getMessage">
                        <xsl:with-param name="key" select="'orWord'"/>
                    </xsl:call-template>
                    <xsl:text> </xsl:text>
                </xsl:if>
                <xsl:for-each select="vocabulary[@valueSet]">
                    <xsl:variable name="xvsref" select="@valueSet"/>
                    <xsl:variable name="xvsflex" select="if (@flexibility) then (@flexibility) else ('dynamic')"/>
                    <xsl:variable name="xvs">
                        <xsl:call-template name="getValueset">
                            <xsl:with-param name="reference" select="$xvsref"/>
                            <xsl:with-param name="flexibility" select="$xvsflex"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="xvsdn" select="($xvs/valueSet)[1]/@displayName"/>
                    <xsl:call-template name="getMessage">
                        <xsl:with-param name="key" select="'valueset'"/>
                    </xsl:call-template>
                    <xsl:text> '</xsl:text>
                    <xsl:value-of select="$xvsref"/>
                    <xsl:text>'</xsl:text>
                    <xsl:if test="string-length($xvsdn)&gt;0 and ($xvsdn != $xvsref)">
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="$xvsdn"/>
                    </xsl:if>
                    <xsl:text> (</xsl:text>
                    <xsl:choose>
                        <xsl:when test="matches($xvsflex,'^\d{4}')">
                            <xsl:value-of select="$xvsflex"/>
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
            
            <!-- Need to check whether or not we have something to check. If we don't we get an illegal theAttCheck distinct-value() -->
            <xsl:if test="$cdexpr/*/*[@dn]">
                <let name="theAttValue" value="distinct-values(tokenize(normalize-space(@{@name}),' '))"/>
                <let name="theAttCheck">
                    <xsl:attribute name="value">
                        <xsl:text>distinct-values(</xsl:text>
                        <xsl:for-each select="$cdexpr/*/*[@dn]">
                            <xsl:value-of select="@dn"/>
                            <xsl:if test="position() != last()">
                                <xsl:text> | </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </let>
                <assert role="error" see="{$seethisthingurl}" test="not(@{@name}) or count($theAttValue) = count($theAttCheck)">
                    <xsl:choose>
                        <xsl:when test="$cdexpr/*[count(*)=1][code]">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'attribValue'"/>
                                <xsl:with-param name="p1" select="$attitem"/>
                                <xsl:with-param name="p2" select="$theAttName"/>
                                <xsl:with-param name="p3" select="$cderr"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'attribCodeCS'"/>
                                <xsl:with-param name="p1" select="$attitem"/>
                                <xsl:with-param name="p2" select="$theAttName"/>
                                <xsl:with-param name="p3" select="$cderr"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </assert>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <xsl:template match="template" mode="ATTRIBCHECK">
        <xsl:variable name="tmpId" select="@id"/>
        <xsl:variable name="tmpName" select="@name"/>
        <xsl:variable name="tmpDate" select="@effectiveDate"/>
        <xsl:for-each select=".//attribute/parent::*">
            <xsl:variable name="attributeNodes" as="element(attribute)*">
                <xsl:apply-templates select="attribute" mode="NORMALIZE"/>
            </xsl:variable>
            <xsl:if test="count(distinct-values($attributeNodes/@name)) != count($attributeNodes/@name)">
                <xsl:call-template name="logMessage">
                    <xsl:with-param name="level" select="$logFATAL"/>
                    <xsl:with-param name="terminate" select="true()"/>
                    <xsl:with-param name="msg">
                        <xsl:text>+++ xsl:template mode ATTRIBCHECK template=</xsl:text>
                        <xsl:value-of select="$tmpName"/>
                        <xsl:text> effectiveDate=</xsl:text>
                        <xsl:value-of select="$tmpDate"/>
                        <xsl:text> contains a duplicate attribute declaration. This will lead to schematron errors so we cannot continue. </xsl:text>
                        <xsl:text> Context: </xsl:text>
                        <xsl:value-of select="string-join(ancestor-or-self::element/@name,'/')"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="attribute" mode="NORMALIZE" as="element(attribute)*">
        <xsl:for-each select="(@name|@classCode|@contextConductionInd|@contextControlCode|@determinerCode|@extension|@independentInd|@institutionSpecified|@inversionInd|@mediaType|@moodCode|@negationInd|@nullFlavor|@operator|@qualifier|@representation|@root|@typeCode|@unit|@use)[not(.='')]">
            <xsl:variable name="anme" select="if (.[name()='name']) then ./string() else (./name())"/>
            <xsl:variable name="aval" select="if (.[name()='name']) then ./../@value/string() else (./string())"/>
            <attribute name="{$anme}">
                <xsl:if test="string-length($aval)&gt;0">
                    <xsl:attribute name="value" select="$aval"/>
                </xsl:if>
                <xsl:copy-of select="../@isOptional"/>
                <xsl:copy-of select="../@prohibited"/>
                <xsl:copy-of select="../@datatype"/>
                <xsl:copy-of select="../node()"/>
            </attribute>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>