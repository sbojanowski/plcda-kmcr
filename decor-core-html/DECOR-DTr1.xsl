<!-- 
    Copyright © ART-DECOR Expert Group and ART-DECOR Open Tools
    see https://art-decor.org/mediawiki/index.php?title=Copyright
    
    Author: Marc de Graauw, Alexander Henket, Dr. Kai U. Heitmann
    
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

--><!-- NOTE: Every single data MUST have at the very least the parameter xsiType and nullFlavor -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.0">
    <!-- DTr1 : ANY-->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : ANY is abstract and should be instantiated/typed through xsi:type. Get xsi:type and reroute to appropriate datatype</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="ANY">
        <xsl:variable name="xsiType">
            <xsl:choose>
                <xsl:when test="contains(@xsi:type, ':')">
                    <xsl:value-of select="substring-after(@xsi:type, ':')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@xsi:type"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$xsiType = 'AD'">
                <xsl:call-template name="AD">
                    <xsl:with-param name="xsiType" select="@xsi:type"/>
                    <xsl:with-param name="nullFlavor" select="@nullFlavor"/>
                    <xsl:with-param name="use" select="@use"/>
                    <xsl:with-param name="addressparts" select="* except *:useablePeriod"/>
                    <xsl:with-param name="useablePeriod" select="*:useablePeriod"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$xsiType = 'BL'">
                <xsl:call-template name="BL">
                    <xsl:with-param name="xsiType" select="@xsi:type"/>
                    <xsl:with-param name="nullFlavor" select="@nullFlavor"/>
                    <xsl:with-param name="value" select="@value"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$xsiType = ('CD', 'CE', 'CV', 'CO')">
                <xsl:call-template name="CD">
                    <xsl:with-param name="xsiType" select="@xsi:type"/>
                    <xsl:with-param name="nullFlavor" select="@nullFlavor"/>
                    <xsl:with-param name="code" select="@code"/>
                    <xsl:with-param name="codeSystem" select="@codeSystem"/>
                    <xsl:with-param name="codeSystemVersion" select="@codeSystemVersion"/>
                    <xsl:with-param name="displayName" select="@displayName"/>
                    <xsl:with-param name="originalText" select="hl7:originalText"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$xsiType = 'CS'">
                <xsl:call-template name="CS">
                    <xsl:with-param name="xsiType" select="@xsi:type"/>
                    <xsl:with-param name="nullFlavor" select="@nullFlavor"/>
                    <xsl:with-param name="code" select="@code"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$xsiType = 'ED'">
                <xsl:call-template name="ED">
                    <xsl:with-param name="xsiType" select="@xsi:type"/>
                    <xsl:with-param name="nullFlavor" select="@nullFlavor"/>
                    <xsl:with-param name="mediaType" select="@mediaType"/>
                    <xsl:with-param name="representation" select="@representation"/>
                    <xsl:with-param name="compression" select="@compression"/>
                    <xsl:with-param name="charset" select="@charset"/>
                    <xsl:with-param name="language" select="@language"/>
                    <xsl:with-param name="text" select="."/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$xsiType = ('EN', 'TN')">
                <xsl:call-template name="EN">
                    <xsl:with-param name="xsiType" select="@xsi:type"/>
                    <xsl:with-param name="nullFlavor" select="@nullFlavor"/>
                    <xsl:with-param name="use" select="@use"/>
                    <xsl:with-param name="value" select="@value"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$xsiType = 'II'">
                <xsl:call-template name="II">
                    <xsl:with-param name="xsiType" select="@xsi:type"/>
                    <xsl:with-param name="nullFlavor" select="@nullFlavor"/>
                    <xsl:with-param name="root" select="@root"/>
                    <xsl:with-param name="extension" select="@extension"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$xsiType = 'INT'">
                <xsl:call-template name="INT">
                    <xsl:with-param name="xsiType" select="@xsi:type"/>
                    <xsl:with-param name="nullFlavor" select="@nullFlavor"/>
                    <xsl:with-param name="value" select="@value"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$xsiType = ('IVL_INT', 'IVL_MO', 'IVL_PQ')">
                <xsl:call-template name="IVL">
                    <xsl:with-param name="xsiType" select="@xsi:type"/>
                    <xsl:with-param name="nullFlavor" select="@nullFlavor"/>
                    <xsl:with-param name="value" select="@value"/>
                    <xsl:with-param name="value.unit" select="@unit | @currency"/>
                    <xsl:with-param name="low" select="hl7:low/@value"/>
                    <xsl:with-param name="low.unit" select="hl7:low/@unit | hl7:low/@currency"/>
                    <xsl:with-param name="width" select="hl7:width/@value"/>
                    <xsl:with-param name="width.unit" select="hl7:width/@unit"/>
                    <xsl:with-param name="center" select="hl7:center/@value"/>
                    <xsl:with-param name="center.unit" select="hl7:center/@unit | hl7:center/@currency"/>
                    <xsl:with-param name="high" select="hl7:high/@value"/>
                    <xsl:with-param name="high.unit" select="hl7:high/@unit | hl7:high/@currency"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$xsiType = 'IVL_TS'">
                <xsl:call-template name="IVL_TS">
                    <xsl:with-param name="xsiType" select="@xsi:type"/>
                    <xsl:with-param name="nullFlavor" select="@nullFlavor"/>
                    <xsl:with-param name="value" select="@value"/>
                    <xsl:with-param name="low" select="hl7:low/@value"/>
                    <xsl:with-param name="width" select="hl7:width/@value"/>
                    <xsl:with-param name="center" select="hl7:center/@value"/>
                    <xsl:with-param name="high" select="hl7:high/@value"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$xsiType = 'MO'">
                <xsl:call-template name="MO">
                    <xsl:with-param name="xsiType" select="@xsi:type"/>
                    <xsl:with-param name="nullFlavor" select="@nullFlavor"/>
                    <xsl:with-param name="value" select="@value"/>
                    <xsl:with-param name="unit" select="@currency"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$xsiType = 'ON'">
                <xsl:call-template name="ON">
                    <xsl:with-param name="xsiType" select="@xsi:type"/>
                    <xsl:with-param name="nullFlavor" select="@nullFlavor"/>
                    <xsl:with-param name="value" select="@value"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$xsiType = 'PN'">
                <xsl:call-template name="PN">
                    <xsl:with-param name="xsiType" select="@xsi:type"/>
                    <xsl:with-param name="nullFlavor" select="@nullFlavor"/>
                    <xsl:with-param name="use" select="@use"/>
                    <xsl:with-param name="value" select="@value"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$xsiType = 'PQ'">
                <xsl:call-template name="PQ">
                    <xsl:with-param name="xsiType" select="@xsi:type"/>
                    <xsl:with-param name="nullFlavor" select="@nullFlavor"/>
                    <xsl:with-param name="value" select="@value"/>
                    <xsl:with-param name="unit" select="@unit"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$xsiType = ('RTO_MO_PQ', 'RTO_PQ_PQ', 'RTO_QTY_QTY')">
                <xsl:call-template name="RTO">
                    <xsl:with-param name="xsiType" select="@xsi:type"/>
                    <xsl:with-param name="nullFlavor" select="@nullFlavor"/>
                    <xsl:with-param name="numerator" select="hl7:numerator/@value"/>
                    <xsl:with-param name="numerator.unit" select="hl7:numerator/@unit | hl7:numerator/@currency"/>
                    <xsl:with-param name="numerator.xsiType" select="hl7:numerator/@xsi:type"/>
                    <xsl:with-param name="denominator" select="hl7:denominator/@value"/>
                    <xsl:with-param name="denominator.unit" select="hl7:denominator/@unit | hl7:denominator/@currency"/>
                    <xsl:with-param name="denominator.xsiType" select="hl7:denominator/@xsi:type"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$xsiType = 'SC'">
                <xsl:call-template name="SC">
                    <xsl:with-param name="xsiType" select="@xsi:type"/>
                    <xsl:with-param name="nullFlavor" select="@nullFlavor"/>
                    <xsl:with-param name="code" select="@code"/>
                    <xsl:with-param name="codeSystem" select="@codeSystem"/>
                    <xsl:with-param name="codeSystemVersion" select="@codeSystemVersion"/>
                    <xsl:with-param name="text" select="."/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$xsiType = 'ST'">
                <xsl:call-template name="ST">
                    <xsl:with-param name="xsiType" select="@xsi:type"/>
                    <xsl:with-param name="nullFlavor" select="@nullFlavor"/>
                    <xsl:with-param name="text" select="."/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$xsiType = 'SD.TEXT'">
                <xsl:call-template name="SD.TEXT">
                    <xsl:with-param name="xsiType" select="@xsi:type"/>
                    <xsl:with-param name="nullFlavor" select="@nullFlavor"/>
                    <xsl:with-param name="text" select="node()"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$xsiType = 'TEL'">
                <xsl:call-template name="TEL">
                    <xsl:with-param name="xsiType" select="@xsi:type"/>
                    <xsl:with-param name="nullFlavor" select="@nullFlavor"/>
                    <xsl:with-param name="use" select="@use"/>
                    <xsl:with-param name="value" select="@value"/>
                    <xsl:with-param name="useablePeriodLow" select="hl7:useablePeriod/hl7:low/@value"/>
                    <xsl:with-param name="useablePeriodHigh" select="hl7:useablePeriod/hl7:high/@value"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$xsiType = 'TS'">
                <xsl:call-template name="TS">
                    <xsl:with-param name="xsiType" select="@xsi:type"/>
                    <xsl:with-param name="nullFlavor" select="@nullFlavor"/>
                    <xsl:with-param name="value" select="@value"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!-- DTr1 : AD-->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : AD (Address) is an ordered collection of address components in datatype ADXP, OR an address string. Either <xd:ref name="adxp" type="parameter">adxp</xd:ref> or <xd:ref name="value" type="parameter">value</xd:ref> SHOULD be valued, or nullFlavor is written</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional. Contains the nullFlavor</xd:param>
        <xd:param name="use">Optional. Contains the address type (HP, WP, ...)</xd:param>
        <xd:param name="value">Contains the address string</xd:param>
    </xd:doc>
    <xsl:template name="AD">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="use"/>
        <xsl:param name="addressparts" as="element()*"/>
        <xsl:param name="useablePeriod" select="$addressparts[local-name() = 'useablePeriod']" as="element()?"/>
        <xsl:if test="string-length($xsiType) &gt; 0">
            <xsl:attribute name="xsi:type" select="$xsiType"/>
        </xsl:if>
        <xsl:if test="string-length($use) &gt; 0">
            <xsl:attribute name="use" select="$use"/>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="$addressparts[string-length(.) &gt; 0]">
                <xsl:for-each select="$addressparts except *:useablePeriod">
                    <xsl:call-template name="ADXP">
                        <xsl:with-param name="xsiType" select="@xsi:type"/>
                        <xsl:with-param name="nullFlavor" select="@nullFlavor"/>
                        <xsl:with-param name="value" select="."/>
                        <xsl:with-param name="code" select="@code"/>
                        <xsl:with-param name="codeSystem" select="@codeSystem"/>
                        <xsl:with-param name="codeSystemName" select="@codeSystemName"/>
                        <xsl:with-param name="codeSystemVersion" select="@codeSystemVersion"/>
                    </xsl:call-template>
                </xsl:for-each>
                <xsl:call-template name="IVL_TS">
                    <xsl:with-param name="xsiType" select="$useablePeriod/@xsi:type"/>
                    <xsl:with-param name="nullFlavor" select="$useablePeriod/@nullFlavor"/>
                    <xsl:with-param name="value" select="$useablePeriod/@value"/>
                    <xsl:with-param name="low" select="$useablePeriod/*:low/@value"/>
                    <xsl:with-param name="width" select="$useablePeriod/*:width/@value"/>
                    <xsl:with-param name="width.unit" select="$useablePeriod/*:width/@unit"/>
                    <xsl:with-param name="center" select="$useablePeriod/*:center/@value"/>
                    <xsl:with-param name="high" select="$useablePeriod/*:high/@value"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="string-length($nullFlavor) &gt; 0">
                        <xsl:attribute name="nullFlavor" select="$nullFlavor"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="nullFlavor" select="'UNK'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- DTr1 : AD.NL-->
    <!-- other AD.* datatypes differ in validation, not content model -->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : AD.NL</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional. Contains the nullFlavor</xd:param>
        <xd:param name="use">Optional. Contains the address type (L, OR, ...)</xd:param>
        <xd:param name="value">Contains the address string</xd:param>
    </xd:doc>
    <xsl:template name="AD.NL">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="use"/>
        <xsl:param name="addressparts" as="element()*"/>
        <xsl:param name="useablePeriod" select="$addressparts[local-name() = 'useablePeriod']" as="element()?"/>
        <xsl:call-template name="AD">
            <xsl:with-param name="xsiType" select="$xsiType"/>
            <xsl:with-param name="nullFlavor" select="$nullFlavor"/>
            <xsl:with-param name="addressparts" select="$addressparts"/>
            <xsl:with-param name="useablePeriod" select="$useablePeriod"/>
        </xsl:call-template>
    </xsl:template>
    <!-- DTr1 : ADXP-->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : ADXP (Address Part)</xd:p>
            <xd:p>In addition the adxp part may be coded with at least code and codeSystem and optionally codeSystemName, codeSystemVersion, or displayName</xd:p>
            <xd:p>NOTE: ADXP is officially comparable to ST, but in some countries like The Netherlands it is SC. Countries with the default ADXP would never populate code and without a code SC equals to ST</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional. Contains the nullFlavor</xd:param>
        <xd:param name="value">Contains the address part string</xd:param>
        <xd:param name="code">Code for the valued address part</xd:param>
        <xd:param name="codeSystem">Code system for the valued address part</xd:param>
        <xd:param name="codeSystemName">Code system name for the valued address part</xd:param>
        <xd:param name="codeSystemVersion">Code system version for the valued address part</xd:param>
        <xd:param name="displayName">Code display name for the valued address part</xd:param>
    </xd:doc>
    <xsl:template name="ADXP">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="value"/>
        <xsl:param name="code"/>
        <xsl:param name="codeSystem"/>
        <xsl:param name="codeSystemName"/>
        <xsl:param name="codeSystemVersion"/>
        <xsl:param name="displayName"/>
        <xsl:choose>
            <xsl:when test="string-length($value) &gt; 0">
                <xsl:call-template name="SC">
                    <xsl:with-param name="xsiType" select="$xsiType"/>
                    <xsl:with-param name="nullFlavor" select="$nullFlavor"/>
                    <xsl:with-param name="text" select="$value"/>
                    <xsl:with-param name="code" select="$code"/>
                    <xsl:with-param name="codeSystem" select="$codeSystem"/>
                    <xsl:with-param name="codeSystemName" select="$codeSystemName"/>
                    <xsl:with-param name="codeSystemVersion" select="$codeSystemVersion"/>
                    <xsl:with-param name="displayName" select="$displayName"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="string-length($nullFlavor) &gt; 0">
                        <xsl:attribute name="nullFlavor" select="$nullFlavor"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="nullFlavor" select="'UNK'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- DTr1 : BL-->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : BL (Boolean)</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional. Contains the nullFlavor</xd:param>
        <xd:param name="value"/>
    </xd:doc>
    <xsl:template name="BL">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="value"/>
        <xsl:if test="string-length($xsiType) &gt; 0">
            <xsl:attribute name="xsi:type" select="$xsiType"/>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="string-length($value) &gt; 0">
                <xsl:attribute name="value" select="$value"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="string-length($nullFlavor) &gt; 0">
                        <xsl:attribute name="nullFlavor" select="$nullFlavor"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="nullFlavor" select="'UNK'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- DTr1 : CD-->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : CD (Concept Descriptor)</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional. Contains the nullFlavor</xd:param>
        <xd:param name="code"/>
        <xd:param name="codeSystem"/>
        <xd:param name="codeSystemName"/>
        <xd:param name="codeSystemVersion"/>
        <xd:param name="displayName"/>
        <xd:param name="originalText"/>
    </xd:doc>
    <xsl:template name="CD">
        <!-- note: valueset resolution to be handled in caller -->
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="code"/>
        <xsl:param name="codeSystem"/>
        <xsl:param name="codeSystemName"/>
        <xsl:param name="codeSystemVersion"/>
        <xsl:param name="displayName"/>
        <xsl:param name="originalText"/>
        <xsl:if test="string-length($xsiType) &gt; 0">
            <xsl:attribute name="xsi:type" select="$xsiType"/>
        </xsl:if>
        <xsl:choose>
            <!-- If the codeSystem equals 'nullFlavor' or '2.16.840.1.113883.5.1008', write @nullFlavor -->
            <xsl:when test="$codeSystem = ('nullFlavor', '2.16.840.1.113883.5.1008')">
                <xsl:attribute name="nullFlavor" select="$code"/>
                <xsl:if test="string-length($originalText) &gt; 0">
                    <xsl:element name="originalText" namespace="urn:hl7-org:v3">
                        <xsl:value-of select="$originalText"/>
                    </xsl:element>
                </xsl:if>
            </xsl:when>
            <xsl:when test="string-length($nullFlavor) &gt; 0">
                <xsl:attribute name="nullFlavor" select="$nullFlavor"/>
                <xsl:if test="string-length($originalText) &gt; 0">
                    <xsl:element name="originalText" namespace="urn:hl7-org:v3">
                        <xsl:value-of select="$originalText"/>
                    </xsl:element>
                </xsl:if>
            </xsl:when>
            <xsl:when test="string-length($code) = 0">
                <xsl:attribute name="nullFlavor" select="'UNK'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="code" select="$code"/>
                <xsl:attribute name="codeSystem" select="$codeSystem"/>
                <xsl:if test="string-length($codeSystemName) &gt; 0">
                    <xsl:attribute name="codeSystemName" select="$codeSystemName"/>
                </xsl:if>
                <xsl:if test="string-length($codeSystemVersion) &gt; 0">
                    <xsl:attribute name="codeSystemVersion" select="$codeSystemVersion"/>
                </xsl:if>
                <xsl:if test="string-length($displayName) &gt; 0">
                    <xsl:attribute name="displayName" select="$displayName"/>
                </xsl:if>
                <xsl:if test="string-length($originalText) &gt; 0">
                    <xsl:element name="originalText" namespace="urn:hl7-org:v3">
                        <xsl:value-of select="$originalText"/>
                    </xsl:element>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- DTr1 : CE -->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : CE</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional. Contains the nullFlavor</xd:param>
        <xd:param name="code"/>
        <xd:param name="codeSystem"/>
        <xd:param name="codeSystemName"/>
        <xd:param name="codeSystemVersion"/>
        <xd:param name="displayName"/>
        <xd:param name="originalText"/>
    </xd:doc>
    <xsl:template name="CE">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="code"/>
        <xsl:param name="codeSystem"/>
        <xsl:param name="codeSystemName"/>
        <xsl:param name="codeSystemVersion"/>
        <xsl:param name="displayName"/>
        <xsl:param name="originalText"/>
        <xsl:call-template name="CD">
            <xsl:with-param name="xsiType" select="$xsiType"/>
            <xsl:with-param name="nullFlavor" select="$nullFlavor"/>
            <xsl:with-param name="code" select="$code"/>
            <xsl:with-param name="codeSystem" select="$codeSystem"/>
            <xsl:with-param name="codeSystemName" select="$codeSystemName"/>
            <xsl:with-param name="codeSystemVersion" select="$codeSystemVersion"/>
            <xsl:with-param name="displayName" select="$displayName"/>
            <xsl:with-param name="originalText" select="$originalText"/>
        </xsl:call-template>
    </xsl:template>
    <!-- DTr1 : CO-->
    <!-- no special handling yet, since instance editor will not support it -->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : CO</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional. Contains the nullFlavor</xd:param>
        <xd:param name="code"/>
        <xd:param name="codeSystem"/>
        <xd:param name="codeSystemName"/>
        <xd:param name="codeSystemVersion"/>
        <xd:param name="displayName"/>
        <xd:param name="originalText"/>
    </xd:doc>
    <xsl:template name="CO">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="code"/>
        <xsl:param name="codeSystem"/>
        <xsl:param name="codeSystemName"/>
        <xsl:param name="codeSystemVersion"/>
        <xsl:param name="displayName"/>
        <xsl:param name="originalText"/>
        <xsl:call-template name="CD">
            <xsl:with-param name="xsiType" select="$xsiType"/>
            <xsl:with-param name="nullFlavor" select="$nullFlavor"/>
            <xsl:with-param name="code" select="$code"/>
            <xsl:with-param name="codeSystem" select="$codeSystem"/>
            <xsl:with-param name="codeSystemName" select="$codeSystemName"/>
            <xsl:with-param name="codeSystemVersion" select="$codeSystemVersion"/>
            <xsl:with-param name="displayName" select="$displayName"/>
            <xsl:with-param name="originalText" select="$originalText"/>
        </xsl:call-template>
    </xsl:template>
    <!-- DTr1 : CS-->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : CS</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional. Contains the nullFlavor</xd:param>
        <xd:param name="code"/>
    </xd:doc>
    <xsl:template name="CS">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="code"/>
        <xsl:if test="string-length($xsiType) &gt; 0">
            <xsl:attribute name="xsi:type" select="$xsiType"/>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="string-length($code) &gt; 0">
                <xsl:attribute name="code" select="$code"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="string-length($nullFlavor) &gt; 0">
                        <xsl:attribute name="nullFlavor" select="$nullFlavor"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="nullFlavor" select="'UNK'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- DTr1 : CS.LANG-->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : CS.LANG</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional. Contains the nullFlavor</xd:param>
        <xd:param name="code"/>
    </xd:doc>
    <xsl:template name="CS.LANG">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="code"/>
        <xsl:call-template name="CS">
            <xsl:with-param name="xsiType" select="$xsiType"/>
            <xsl:with-param name="nullFlavor" select="$nullFlavor"/>
            <xsl:with-param name="code" select="$code"/>
        </xsl:call-template>
    </xsl:template>
    <!-- DTr1 : CV-->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : CV</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional. Contains the nullFlavor</xd:param>
        <xd:param name="code"/>
        <xd:param name="codeSystem"/>
        <xd:param name="codeSystemName"/>
        <xd:param name="codeSystemVersion"/>
        <xd:param name="displayName"/>
        <xd:param name="originalText"/>
    </xd:doc>
    <xsl:template name="CV">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="code"/>
        <xsl:param name="codeSystem"/>
        <xsl:param name="codeSystemName"/>
        <xsl:param name="codeSystemVersion"/>
        <xsl:param name="displayName"/>
        <xsl:param name="originalText"/>
        <xsl:call-template name="CD">
            <xsl:with-param name="xsiType" select="$xsiType"/>
            <xsl:with-param name="nullFlavor" select="$nullFlavor"/>
            <xsl:with-param name="code" select="$code"/>
            <xsl:with-param name="codeSystem" select="$codeSystem"/>
            <xsl:with-param name="codeSystemName" select="$codeSystemName"/>
            <xsl:with-param name="codeSystemVersion" select="$codeSystemVersion"/>
            <xsl:with-param name="displayName" select="$displayName"/>
            <xsl:with-param name="originalText" select="$originalText"/>
        </xsl:call-template>
    </xsl:template>
    <!-- DTr1 : ED-->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : ED (Encapsulated data)</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional. Contains the nullFlavor</xd:param>
        <xd:param name="mediaType">Values like text/plain</xd:param>
        <xd:param name="representation">B64 or TEXT</xd:param>
        <xd:param name="compression">GZ</xd:param>
        <xd:param name="charset">utf-8, cp-1252</xd:param>
        <xd:param name="language">nl, en-us</xd:param>
        <xd:param name="text">Mixed contents</xd:param>
    </xd:doc>
    <xsl:template name="ED">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="mediaType"/>
        <xsl:param name="representation"/>
        <xsl:param name="compression"/>
        <xsl:param name="charset"/>
        <xsl:param name="language"/>
        <xsl:param name="text"/>
        <xsl:if test="string-length($xsiType) &gt; 0">
            <xsl:attribute name="xsi:type" select="$xsiType"/>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="string-length($text) &gt; 0">
                <xsl:if test="string-length($mediaType) &gt; 0">
                    <xsl:attribute name="mediaType" select="$mediaType"/>
                </xsl:if>
                <xsl:if test="string-length($representation) &gt; 0">
                    <xsl:attribute name="mediaType" select="$representation"/>
                </xsl:if>
                <xsl:if test="string-length($compression) &gt; 0">
                    <xsl:attribute name="mediaType" select="$compression"/>
                </xsl:if>
                <xsl:if test="string-length($charset) &gt; 0">
                    <xsl:attribute name="mediaType" select="$charset"/>
                </xsl:if>
                <xsl:if test="string-length($language) &gt; 0">
                    <xsl:attribute name="mediaType" select="$language"/>
                </xsl:if>
                <xsl:copy-of select="$text"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="string-length($nullFlavor) &gt; 0">
                        <xsl:attribute name="nullFlavor" select="$nullFlavor"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="nullFlavor" select="'UNK'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- DTr1 : EN-->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : EN (Entity Name) is an ordered collection of name components in datatype ENXP, OR a name string. Either <xd:ref name="enxp" type="parameter">enxp</xd:ref> or <xd:ref name="value" type="parameter">value</xd:ref> SHOULD be valued, or nullFlavor is written</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional. Contains the nullFlavor</xd:param>
        <xd:param name="use">Optional. Contains the name type (L, OR, ...)</xd:param>
        <xd:param name="enxp">Contains the collection of ENXP datatyped elements created through the template ENXP</xd:param>
        <xd:param name="value">Contains the name string</xd:param>
    </xd:doc>
    <xsl:template name="EN">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="use"/>
        <xsl:param name="value"/>
        <xsl:if test="string-length($xsiType) &gt; 0">
            <xsl:attribute name="xsi:type" select="$xsiType"/>
        </xsl:if>
        <xsl:if test="string-length($use) &gt; 0">
            <xsl:attribute name="use" select="$use"/>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="string-length($value) > 0">
                <xsl:copy-of select="$value"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="string-length($nullFlavor) &gt; 0">
                        <xsl:attribute name="nullFlavor" select="$nullFlavor"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="nullFlavor" select="'UNK'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- DTr1 : ENXP-->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : ENXP (Entity Name Part)</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Not really useful, but added for consistency</xd:param>
        <xd:param name="nullFlavor">Optional. Contains the nullFlavor</xd:param>
        <xd:param name="value">Contains the name part string</xd:param>
        <xd:param name="qualifier">Optional qualifier for the name part</xd:param>
    </xd:doc>
    <xsl:template name="ENXP">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="value"/>
        <xsl:param name="qualifier"/>
        <xsl:if test="string-length($xsiType) &gt; 0">
            <xsl:attribute name="xsi:type" select="$xsiType"/>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="string-length($value) &gt; 0">
                <xsl:if test="string-length($qualifier) &gt; 0">
                    <xsl:attribute name="qualifier" select="$qualifier"/>
                </xsl:if>
                <xsl:call-template name="ST">
                    <xsl:with-param name="xsiType" select="$xsiType"/>
                    <xsl:with-param name="nullFlavor" select="$nullFlavor"/>
                    <xsl:with-param name="text" select="$value"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="string-length($nullFlavor) &gt; 0">
                        <xsl:attribute name="nullFlavor" select="$nullFlavor"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="nullFlavor" select="'UNK'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- DTr1 : II-->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : II (Instance identifier)</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional. Contains the nullFlavor</xd:param>
        <xd:param name="root"/>
        <xd:param name="extension"/>
    </xd:doc>
    <xsl:template name="II">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="root"/>
        <xsl:param name="extension"/>
        <xsl:if test="string-length($xsiType) &gt; 0">
            <xsl:attribute name="xsi:type" select="$xsiType"/>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="string-length($root) = 0">
                <xsl:choose>
                    <xsl:when test="string-length($extension) &gt; 0">
                        <xsl:attribute name="nullFlavor" select="'UNC'"/>
                    </xsl:when>
                    <xsl:when test="string-length($nullFlavor) &gt; 0">
                        <xsl:attribute name="nullFlavor" select="$nullFlavor"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="nullFlavor" select="'UNK'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="root" select="$root"/>
                <xsl:if test="string-length($extension) &gt; 0">
                    <xsl:attribute name="extension" select="$extension"/>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- other II.* datatypes differ in validation, not content model -->
    <!-- DTr1 : II.NL.AGB-->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : II.NL.AGB</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional. Contains the nullFlavor</xd:param>
        <xd:param name="root"/>
        <xd:param name="extension"/>
    </xd:doc>
    <xsl:template name="II.NL.AGB">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="root"/>
        <xsl:param name="extension"/>
        <xsl:call-template name="II">
            <xsl:with-param name="xsiType" select="$xsiType"/>
            <xsl:with-param name="nullFlavor" select="$nullFlavor"/>
            <xsl:with-param name="root" select="$root"/>
            <xsl:with-param name="extension" select="$extension"/>
        </xsl:call-template>
    </xsl:template>
    <!-- DTr1 : II.NL.BSN-->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : II.NL.BSN</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional. Contains the nullFlavor</xd:param>
        <xd:param name="root"/>
        <xd:param name="extension"/>
    </xd:doc>
    <xsl:template name="II.NL.BSN">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="root"/>
        <xsl:param name="extension"/>
        <xsl:call-template name="II">
            <xsl:with-param name="xsiType" select="$xsiType"/>
            <xsl:with-param name="nullFlavor" select="$nullFlavor"/>
            <xsl:with-param name="root" select="$root"/>
            <xsl:with-param name="extension" select="$extension"/>
        </xsl:call-template>
    </xsl:template>
    <!-- DTr1 : II.NL.URA-->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : II.NL.URA</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional. Contains the nullFlavor</xd:param>
        <xd:param name="root"/>
        <xd:param name="extension"/>
    </xd:doc>
    <xsl:template name="II.NL.URA">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="root"/>
        <xsl:param name="extension"/>
        <xsl:call-template name="II">
            <xsl:with-param name="xsiType" select="$xsiType"/>
            <xsl:with-param name="nullFlavor" select="$nullFlavor"/>
            <xsl:with-param name="root" select="$root"/>
            <xsl:with-param name="extension" select="$extension"/>
        </xsl:call-template>
    </xsl:template>
    <!-- DTr1 : II.NL.UZI-->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : II.NL.UZI</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional. Contains the nullFlavor</xd:param>
        <xd:param name="root"/>
        <xd:param name="extension"/>
    </xd:doc>
    <xsl:template name="II.NL.UZI">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="root"/>
        <xsl:param name="extension"/>
        <xsl:call-template name="II">
            <xsl:with-param name="xsiType" select="$xsiType"/>
            <xsl:with-param name="nullFlavor" select="$nullFlavor"/>
            <xsl:with-param name="root" select="$root"/>
            <xsl:with-param name="extension" select="$extension"/>
        </xsl:call-template>
    </xsl:template>
    <!-- DTr1 : INT-->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : INT</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional. Contains the nullFlavor</xd:param>
        <xd:param name="value"/>
    </xd:doc>
    <xsl:template name="INT">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="value"/>
        <xsl:if test="string-length($xsiType) &gt; 0">
            <xsl:attribute name="xsi:type" select="$xsiType"/>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="string-length($value) &gt; 0">
                <xsl:attribute name="value" select="$value"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="string-length($nullFlavor) &gt; 0">
                        <xsl:attribute name="nullFlavor" select="$nullFlavor"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="nullFlavor" select="'UNK'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- DTr1 : INT.NONNEG-->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : INT_NONNEG</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional. Contains the nullFlavor</xd:param>
        <xd:param name="value"/>
    </xd:doc>
    <xsl:template name="INT.NONNEG">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="value"/>
        <xsl:call-template name="INT">
            <xsl:with-param name="xsiType" select="$xsiType"/>
            <xsl:with-param name="nullFlavor" select="$nullFlavor"/>
            <xsl:with-param name="value" select="$value"/>
        </xsl:call-template>
    </xsl:template>
    <!-- DTr1 : INT.POS-->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : INT.POS</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional. Contains the nullFlavor</xd:param>
        <xd:param name="value"/>
    </xd:doc>
    <xsl:template name="INT.POS">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="value"/>
        <xsl:call-template name="INT">
            <xsl:with-param name="xsiType" select="$xsiType"/>
            <xsl:with-param name="nullFlavor" select="$nullFlavor"/>
            <xsl:with-param name="value" select="$value"/>
        </xsl:call-template>
    </xsl:template>
    <!-- DTr1 : IVL -->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : IVL (Interval) of timestamps/quantities/monetary units, potentially demoted to a single value, or nullFlavor 'UNK' if no parameter is valued. You can have any of these combinations of children: <xd:ul>
                    <xd:li>low</xd:li>
                    <xd:li>width</xd:li>
                    <xd:li>high</xd:li>
                    <xd:li>low, width</xd:li>
                    <xd:li>width, high</xd:li>
                    <xd:li>low, high</xd:li>
                    <xd:li>center</xd:li>
                    <xd:li>center, width</xd:li>
                </xd:ul>
            </xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional nullFlavor. Defaults to 'UNK' when applicable</xd:param>
        <xd:param name="value">If this is valued then IVL is demoted to a single value by writing to @value</xd:param>
        <xd:param name="value.unit">Optional @unit for the value</xd:param>
        <xd:param name="low">Low boundary of the interval</xd:param>
        <xd:param name="low.unit">Optional @unit for the low boundary</xd:param>
        <xd:param name="width">Width value</xd:param>
        <xd:param name="width.unit">Optional @unit for the width</xd:param>
        <xd:param name="center">Center value</xd:param>
        <xd:param name="center.unit">Optional @unit for the center value</xd:param>
        <xd:param name="high">High boundary of the interval</xd:param>
        <xd:param name="high.unit">Optional @unit for the high boundary</xd:param>
    </xd:doc>
    <xsl:template name="IVL">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="value"/>
        <xsl:param name="value.unit"/>
        <xsl:param name="low"/>
        <xsl:param name="low.unit"/>
        <xsl:param name="width"/>
        <xsl:param name="width.unit"/>
        <xsl:param name="center"/>
        <xsl:param name="center.unit"/>
        <xsl:param name="high"/>
        <xsl:param name="high.unit"/>
        <xsl:if test="string-length($xsiType) &gt; 0">
            <xsl:attribute name="xsi:type" select="$xsiType"/>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="string-length($value) &gt; 0">
                <xsl:attribute name="value" select="$value"/>
                <xsl:if test="string-length($value.unit) &gt; 0">
                    <xsl:attribute name="unit" select="$value.unit"/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="string-length($low) &gt; 0 or string-length($high) &gt; 0">
                <xsl:if test="string-length($low) &gt; 0">
                    <xsl:element name="low" namespace="urn:hl7-org:v3">
                        <xsl:attribute name="value" select="$low"/>
                        <xsl:if test="string-length($low.unit) &gt; 0">
                            <xsl:attribute name="unit" select="$low.unit"/>
                        </xsl:if>
                    </xsl:element>
                </xsl:if>
                <xsl:if test="string-length($width) &gt; 0">
                    <xsl:element name="width" namespace="urn:hl7-org:v3">
                        <xsl:attribute name="value" select="$width"/>
                        <xsl:if test="string-length($width.unit) &gt; 0">
                            <xsl:attribute name="unit" select="$width.unit"/>
                        </xsl:if>
                    </xsl:element>
                </xsl:if>
                <xsl:if test="string-length($high) &gt; 0">
                    <xsl:element name="high" namespace="urn:hl7-org:v3">
                        <xsl:attribute name="value" select="$high"/>
                        <xsl:if test="string-length($high.unit) &gt; 0">
                            <xsl:attribute name="unit" select="$high.unit"/>
                        </xsl:if>
                    </xsl:element>
                </xsl:if>
            </xsl:when>
            <xsl:when test="string-length($center) &gt; 0">
                <xsl:element name="center" namespace="urn:hl7-org:v3">
                    <xsl:attribute name="value" select="$center"/>
                    <xsl:if test="string-length($center.unit) &gt; 0">
                        <xsl:attribute name="unit" select="$center.unit"/>
                    </xsl:if>
                </xsl:element>
                <xsl:if test="string-length($width) &gt; 0">
                    <xsl:element name="width" namespace="urn:hl7-org:v3">
                        <xsl:attribute name="value" select="$width"/>
                        <xsl:if test="string-length($width.unit) &gt; 0">
                            <xsl:attribute name="unit" select="$width.unit"/>
                        </xsl:if>
                    </xsl:element>
                </xsl:if>
            </xsl:when>
            <xsl:when test="string-length($width) &gt; 0">
                <xsl:element name="width" namespace="urn:hl7-org:v3">
                    <xsl:attribute name="value" select="$width"/>
                    <xsl:if test="string-length($width.unit) &gt; 0">
                        <xsl:attribute name="unit" select="$width.unit"/>
                    </xsl:if>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="string-length($nullFlavor) &gt; 0">
                        <xsl:attribute name="nullFlavor" select="$nullFlavor"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="nullFlavor" select="'UNK'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- DTr1 : IVL_INT-->
    <!-- IVL_* types: pass in element, make high, low etc. -->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : IVL_INT (Interval of integers). See <xd:ref name="IVL" type="template">IVL</xd:ref> for more information</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional nullFlavor. Defaults to 'UNK' when applicable</xd:param>
        <xd:param name="value">If this is valued then IVL is demoted to a single value by writing to @value</xd:param>
        <xd:param name="low">Low boundary of the interval</xd:param>
        <xd:param name="width">Width value</xd:param>
        <xd:param name="center">Center value</xd:param>
        <xd:param name="high">High boundary of the interval</xd:param>
    </xd:doc>
    <xsl:template name="IVL_INT">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="value"/>
        <xsl:param name="low"/>
        <xsl:param name="width"/>
        <xsl:param name="center"/>
        <xsl:param name="high"/>
        <xsl:call-template name="IVL">
            <xsl:with-param name="xsiType" select="$xsiType"/>
            <xsl:with-param name="nullFlavor" select="$nullFlavor"/>
            <xsl:with-param name="value" select="$value"/>
            <xsl:with-param name="low" select="$low"/>
            <xsl:with-param name="width" select="$width"/>
            <xsl:with-param name="center" select="$center"/>
            <xsl:with-param name="high" select="$high"/>
        </xsl:call-template>
    </xsl:template>
    <!-- DTr1 : IVL_MO-->
    <!-- IVL_* types: pass in element, make high, low etc. -->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : IVL_MO (Interval of monetary units). See <xd:ref name="IVL" type="template">IVL</xd:ref> for more information</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional nullFlavor. Defaults to 'UNK' when applicable</xd:param>
        <xd:param name="value">If this is valued then IVL is demoted to a single value by writing to @value</xd:param>
        <xd:param name="value.unit">Optional @unit for the value</xd:param>
        <xd:param name="low">Low boundary of the interval</xd:param>
        <xd:param name="low.unit">Optional @unit for the low boundary</xd:param>
        <xd:param name="width">Width value</xd:param>
        <xd:param name="width.unit">Optional @unit for the width</xd:param>
        <xd:param name="center">Center value</xd:param>
        <xd:param name="center.unit">Optional @unit for the center value</xd:param>
        <xd:param name="high">High boundary of the interval</xd:param>
        <xd:param name="high.unit">Optional @unit for the high boundary</xd:param>
    </xd:doc>
    <xsl:template name="IVL_MO">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="value"/>
        <xsl:param name="value.unit"/>
        <xsl:param name="low"/>
        <xsl:param name="low.unit"/>
        <xsl:param name="width"/>
        <xsl:param name="width.unit"/>
        <xsl:param name="center"/>
        <xsl:param name="center.unit"/>
        <xsl:param name="high"/>
        <xsl:param name="high.unit"/>
        <xsl:call-template name="IVL">
            <xsl:with-param name="xsiType" select="$xsiType"/>
            <xsl:with-param name="nullFlavor" select="$nullFlavor"/>
            <xsl:with-param name="value" select="$value"/>
            <xsl:with-param name="value.unit" select="$value.unit"/>
            <xsl:with-param name="low" select="$low"/>
            <xsl:with-param name="low.unit" select="$low.unit"/>
            <xsl:with-param name="width" select="$width"/>
            <xsl:with-param name="width.unit" select="$width.unit"/>
            <xsl:with-param name="center" select="$center"/>
            <xsl:with-param name="center.unit" select="$center.unit"/>
            <xsl:with-param name="high" select="$high"/>
            <xsl:with-param name="high.unit" select="$high.unit"/>
        </xsl:call-template>
    </xsl:template>
    <!-- DTr1 : IVL_PQ-->
    <!-- IVL_* types: pass in element, make high, low etc. -->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : IVL_PQ (Interval of physical quantities). See <xd:ref name="IVL" type="template">IVL</xd:ref> for more information</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional nullFlavor. Defaults to 'UNK' when applicable</xd:param>
        <xd:param name="value">If this is valued then IVL is demoted to a single value by writing to @value</xd:param>
        <xd:param name="value.unit">Optional @unit for the value</xd:param>
        <xd:param name="low">Low boundary of the interval</xd:param>
        <xd:param name="low.unit">Optional @unit for the low boundary</xd:param>
        <xd:param name="width">Width value</xd:param>
        <xd:param name="width.unit">Optional @unit for the width</xd:param>
        <xd:param name="center">Center value</xd:param>
        <xd:param name="center.unit">Optional @unit for the center value</xd:param>
        <xd:param name="high">High boundary of the interval</xd:param>
        <xd:param name="high.unit">Optional @unit for the high boundary</xd:param>
    </xd:doc>
    <xsl:template name="IVL_PQ">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="value"/>
        <xsl:param name="value.unit"/>
        <xsl:param name="low"/>
        <xsl:param name="low.unit"/>
        <xsl:param name="width"/>
        <xsl:param name="width.unit"/>
        <xsl:param name="center"/>
        <xsl:param name="center.unit"/>
        <xsl:param name="high"/>
        <xsl:param name="high.unit"/>
        <xsl:call-template name="IVL">
            <xsl:with-param name="xsiType" select="$xsiType"/>
            <xsl:with-param name="nullFlavor" select="$nullFlavor"/>
            <xsl:with-param name="value" select="$value"/>
            <xsl:with-param name="value.unit" select="$value.unit"/>
            <xsl:with-param name="low" select="$low"/>
            <xsl:with-param name="low.unit" select="$low.unit"/>
            <xsl:with-param name="width" select="$width"/>
            <xsl:with-param name="width.unit" select="$width.unit"/>
            <xsl:with-param name="center" select="$center"/>
            <xsl:with-param name="center.unit" select="$center.unit"/>
            <xsl:with-param name="high" select="$high"/>
            <xsl:with-param name="high.unit" select="$high.unit"/>
        </xsl:call-template>
    </xsl:template>
    <!-- DTr1 : IVL_TS-->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : IVL_TS (Interval of timestamps). Creates an interval of timestamps. See <xd:ref name="IVL" type="template">IVL</xd:ref> for more information</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional nullFlavor. Defaults to 'UNK' when applicable</xd:param>
        <xd:param name="value">If this is valued then IVL is demoted to a single value by writing to @value</xd:param>
        <xd:param name="low">Low boundary of the interval</xd:param>
        <xd:param name="width">Width value</xd:param>
        <xd:param name="center">Center value</xd:param>
        <xd:param name="high">High boundary of the interval</xd:param>
    </xd:doc>
    <xsl:template name="IVL_TS">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="value"/>
        <xsl:param name="low"/>
        <xsl:param name="width"/>
        <xsl:param name="width.unit"/>
        <xsl:param name="center"/>
        <xsl:param name="high"/>
        <xsl:call-template name="IVL">
            <xsl:with-param name="xsiType" select="$xsiType"/>
            <xsl:with-param name="nullFlavor" select="$nullFlavor"/>
            <xsl:with-param name="value" select="$value"/>
            <xsl:with-param name="low" select="replace($low, '[T:-]', '')"/>
            <xsl:with-param name="width" select="$width"/>
            <xsl:with-param name="width.unit" select="$width.unit"/>
            <xsl:with-param name="center" select="replace($center, '[T:-]', '')"/>
            <xsl:with-param name="high" select="replace($high, '[T:-]', '')"/>
        </xsl:call-template>
    </xsl:template>
    <!-- DTr1 : MO-->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : MO (Money)</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional. Contains the nullFlavor</xd:param>
        <xd:param name="value"/>
        <xd:param name="currency"/>
    </xd:doc>
    <xsl:template name="MO">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="value"/>
        <xsl:param name="unit"/>
        <xsl:if test="string-length($xsiType) &gt; 0">
            <xsl:attribute name="xsi:type" select="$xsiType"/>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="string-length($value) &gt; 0">
                <xsl:attribute name="value" select="$value"/>
                <xsl:if test="string-length($unit) &gt; 0">
                    <xsl:attribute name="currency" select="$unit"/>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="string-length($nullFlavor) &gt; 0">
                        <xsl:attribute name="nullFlavor" select="$nullFlavor"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="nullFlavor" select="'UNK'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- ON, PN are names, pass in element -->
    <!-- DTr1 : ON-->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : ON (Organization name), passed off to Entity Name (EN)</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional. Contains the nullFlavor</xd:param>
        <xd:param name="value">Organization name string</xd:param>
    </xd:doc>
    <xsl:template name="ON">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="value"/>
        <xsl:call-template name="EN">
            <xsl:with-param name="xsiType" select="$xsiType"/>
            <xsl:with-param name="nullFlavor" select="$nullFlavor"/>
            <xsl:with-param name="value" select="$value"/>
        </xsl:call-template>
    </xsl:template>
    <!-- DTr1 : PN-->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : PN (Person Name) is an ordered collection of name components in datatype ENXP, OR a name string. Either <xd:ref name="enxp" type="parameter">enxp</xd:ref> or <xd:ref name="value" type="parameter">value</xd:ref> SHOULD be valued, or nullFlavor 'UNK' is written</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional. Contains the nullFlavor</xd:param>
        <xd:param name="use">Optional. Contains the name type (L, OR, ...)</xd:param>
        <xd:param name="enxp">Contains the collection of ENXP datatyped elements created through the template ENXP</xd:param>
        <xd:param name="value">Contains the name string</xd:param>
        <xd:param name="validTimeLow">Low boundary to the period in which this name was valid</xd:param>
        <xd:param name="validTimeHigh">High boundary to the period in which this name was valid</xd:param>
    </xd:doc>
    <xsl:template name="PN">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="use"/>
        <xsl:param name="value"/>
        <!--xsl:param name="validTimeLow"/>
        <xsl:param name="validTimeHigh"/-->
        <xsl:call-template name="EN">
            <xsl:with-param name="xsiType" select="$xsiType"/>
            <xsl:with-param name="nullFlavor" select="$nullFlavor"/>
            <xsl:with-param name="use" select="$use"/>
            <xsl:with-param name="value" select="$value"/>
            <!--xsl:with-param name="validTimeLow" select="$validTimeLow"/>
            <xsl:with-param name="validTimeHigh" select="$validTimeHigh"/-->
        </xsl:call-template>
    </xsl:template>
    <!-- DTr1 : PQ-->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : PQ</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional. Contains the nullFlavor</xd:param>
        <xd:param name="value"/>
        <xd:param name="unit"/>
    </xd:doc>
    <xsl:template name="PQ">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="value"/>
        <xsl:param name="unit"/>
        <xsl:if test="string-length($xsiType) &gt; 0">
            <xsl:attribute name="xsi:type" select="$xsiType"/>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="string-length($value) &gt; 0">
                <xsl:attribute name="value" select="$value"/>
                <xsl:if test="string-length($unit) &gt; 0">
                    <xsl:attribute name="unit" select="$unit"/>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="string-length($nullFlavor) &gt; 0">
                        <xsl:attribute name="nullFlavor" select="$nullFlavor"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="nullFlavor" select="'UNK'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- DTr1 : RTO-->
    <!-- pass in element, do numerator, denominator children -->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : RTO (Ratio)</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional. Contains the nullFlavor</xd:param>
        <xd:param name="numerator"/>
        <xd:param name="numerator.currency"/>
        <xd:param name="numerator.unit"/>
        <xd:param name="numerator.xsiType"/>
        <xd:param name="denominator"/>
        <xd:param name="denominator.unit"/>
        <xd:param name="denominator.xsiType"/>
    </xd:doc>
    <xsl:template name="RTO">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="numerator"/>
        <xsl:param name="numerator.currency"/>
        <xsl:param name="numerator.unit"/>
        <xsl:param name="numerator.xsiType"/>
        <xsl:param name="denominator"/>
        <xsl:param name="denominator.unit"/>
        <xsl:param name="denominator.xsiType"/>
        <xsl:if test="string-length($xsiType) &gt; 0">
            <xsl:attribute name="xsi:type" select="$xsiType"/>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="string-length($numerator) &gt; 0 and string-length($denominator) &gt; 0">
                <xsl:element name="numerator" namespace="urn:hl7-org:v3">
                    <xsl:if test="string-length($numerator.xsiType) &gt; 0">
                        <xsl:attribute name="xsi:type" select="$numerator.xsiType"/>
                    </xsl:if>
                    <xsl:attribute name="value" select="$numerator"/>
                    <xsl:if test="string-length($numerator.unit) &gt; 0">
                        <xsl:attribute name="unit" select="$numerator.unit"/>
                    </xsl:if>
                    <xsl:if test="string-length($numerator.currency) &gt; 0">
                        <xsl:attribute name="currency" select="$numerator.currency"/>
                    </xsl:if>
                </xsl:element>
                <xsl:element name="denominator" namespace="urn:hl7-org:v3">
                    <xsl:if test="string-length($denominator.xsiType) &gt; 0">
                        <xsl:attribute name="xsi:type" select="$denominator.xsiType"/>
                    </xsl:if>
                    <xsl:attribute name="value" select="$denominator"/>
                    <xsl:if test="string-length($denominator.unit) &gt; 0">
                        <xsl:attribute name="unit" select="$denominator.unit"/>
                    </xsl:if>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="string-length($nullFlavor) &gt; 0">
                        <xsl:attribute name="nullFlavor" select="$nullFlavor"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="nullFlavor" select="'UNK'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- DTr1 : RTO_MO_PQ -->
    <!-- pass in element, do numerator, denominator children -->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : RTO_MO_PQ (Ratio of money and physical quantity). See <xd:ref name="RTO" type="template">RTO</xd:ref> for more info</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional nullFlavor</xd:param>
        <xd:param name="numerator">Numerator value</xd:param>
        <xd:param name="numerator.unit">Numerator unit</xd:param>
        <xd:param name="denominator">Denominator value</xd:param>
        <xd:param name="denominator.unit">Denominator unit</xd:param>
    </xd:doc>
    <xsl:template name="RTO_MO_PQ">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="numerator"/>
        <xsl:param name="numerator.currency"/>
        <xsl:param name="denominator"/>
        <xsl:param name="denominator.unit"/>
        <xsl:call-template name="RTO">
            <xsl:with-param name="xsiType" select="$xsiType"/>
            <xsl:with-param name="nullFlavor" select="$nullFlavor"/>
            <xsl:with-param name="numerator" select="$numerator"/>
            <xsl:with-param name="numerator.currency" select="$numerator.currency"/>
            <xsl:with-param name="denominator" select="$denominator"/>
            <xsl:with-param name="denominator.unit" select="$denominator.unit"/>
        </xsl:call-template>
    </xsl:template>
    <!-- DTr1 : RTO_PQ_PQ -->
    <!-- pass in element, do numerator, denominator children -->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : RTO_PQ_PQ (Ratio of physical quantities). See <xd:ref name="RTO" type="template">RTO</xd:ref> for more info</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional nullFlavor</xd:param>
        <xd:param name="numerator">Numerator value</xd:param>
        <xd:param name="numerator.unit">Numerator unit</xd:param>
        <xd:param name="denominator">Denominator value</xd:param>
        <xd:param name="denominator.unit">Denominator unit</xd:param>
    </xd:doc>
    <xsl:template name="RTO_PQ_PQ">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="numerator"/>
        <xsl:param name="numerator.unit"/>
        <xsl:param name="denominator"/>
        <xsl:param name="denominator.unit"/>
        <xsl:call-template name="RTO">
            <xsl:with-param name="xsiType" select="$xsiType"/>
            <xsl:with-param name="nullFlavor" select="$nullFlavor"/>
            <xsl:with-param name="numerator" select="$numerator"/>
            <xsl:with-param name="numerator.unit" select="$numerator.unit"/>
            <xsl:with-param name="denominator" select="$denominator"/>
            <xsl:with-param name="denominator.unit" select="$denominator.unit"/>
        </xsl:call-template>
    </xsl:template>
    <!-- DTr1 : RTO_QTY_QTY -->
    <!-- pass in element, do numerator, denominator children -->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : RTO_QTY_QTY (Ratio of quantities). See <xd:ref name="RTO" type="template">RTO</xd:ref> for more info</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional nullFlavor</xd:param>
        <xd:param name="numerator">Numerator value</xd:param>
        <xd:param name="numerator.unit">Numerator unit</xd:param>
        <xd:param name="numerator.xsiType">Numerator xsi:type</xd:param>
        <xd:param name="denominator">Denominator value</xd:param>
        <xd:param name="denominator.unit">Denominator unit</xd:param>
        <xd:param name="denominator.xsiType">Denominator xsi:type</xd:param>
    </xd:doc>
    <xsl:template name="RTO_QTY_QTY">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="numerator"/>
        <xsl:param name="numerator.unit"/>
        <xsl:param name="numerator.xsiType"/>
        <xsl:param name="denominator"/>
        <xsl:param name="denominator.unit"/>
        <xsl:param name="denominator.xsiType"/>
        <xsl:call-template name="RTO">
            <xsl:with-param name="xsiType" select="'RTO_QTY_QTY'"/>
            <xsl:with-param name="nullFlavor" select="$nullFlavor"/>
            <xsl:with-param name="numerator" select="$numerator"/>
            <xsl:with-param name="numerator.unit" select="$numerator.unit"/>
            <xsl:with-param name="numerator.xsiType" select="$numerator.xsiType"/>
            <xsl:with-param name="denominator" select="$denominator"/>
            <xsl:with-param name="denominator.unit" select="$denominator.unit"/>
            <xsl:with-param name="denominator.xsiType" select="$denominator.xsiType"/>
        </xsl:call-template>
    </xsl:template>
    <!-- DTr1 : SC-->
    <!--  SC not supported in instances -->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : SC</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional. Contains the nullFlavor</xd:param>
        <xd:param name="code"/>
        <xd:param name="codeSystem"/>
        <xd:param name="codeSystemName"/>
        <xd:param name="codeSystemVersion"/>
        <xd:param name="displayName"/>
        <xd:param name="text"/>
    </xd:doc>
    <xsl:template name="SC">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="code"/>
        <xsl:param name="codeSystem"/>
        <xsl:param name="codeSystemName"/>
        <xsl:param name="codeSystemVersion"/>
        <xsl:param name="displayName"/>
        <xsl:param name="text"/>
        <!-- 
            text() is required, otherwise nullFlavor. If nullFlavor has a value is it clear, otherwise check contents of parameters text, displayName or code
            A value in code is the least desirable solution as it may not be a self explanatory code, but may suffice 
        -->
        <xsl:variable name="isNull" as="xs:boolean" select="string-length($nullFlavor) &gt; 0 or string-length(concat($text, $displayName, $code)) &gt; 0"/>
        <xsl:if test="string-length($xsiType) &gt; 0">
            <xsl:attribute name="xsi:type" select="$xsiType"/>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="$isNull">
                <xsl:choose>
                    <xsl:when test="string-length($nullFlavor) &gt; 0">
                        <xsl:attribute name="nullFlavor" select="$nullFlavor"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="nullFlavor" select="'UNK'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="string-length($text) &gt; 0">
                        <xsl:value-of select="$text"/>
                    </xsl:when>
                    <xsl:when test="string-length($displayName) &gt; 0">
                        <xsl:value-of select="$displayName"/>
                    </xsl:when>
                    <xsl:when test="string-length($code) &gt; 0">
                        <xsl:value-of select="$code"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- Should never get here, could write an attribute error -->
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="string-length($code) &gt; 0 and string-length($codeSystem)">
                    <xsl:attribute name="code" select="$code"/>
                    <xsl:attribute name="codeSystem" select="$codeSystem"/>
                    <xsl:if test="string-length($codeSystemName) &gt; 0">
                        <xsl:attribute name="codeSystemName" select="$codeSystemName"/>
                    </xsl:if>
                    <xsl:if test="string-length($codeSystemVersion) &gt; 0">
                        <xsl:attribute name="codeSystemVersion" select="$codeSystemVersion"/>
                    </xsl:if>
                    <xsl:if test="string-length($displayName) &gt; 0">
                        <xsl:attribute name="displayName" select="$displayName"/>
                    </xsl:if>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- DTr1 : ST-->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : ST</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional. Contains the nullFlavor</xd:param>
        <xd:param name="text"/>
    </xd:doc>
    <xsl:template name="ST">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="text"/>
        <xsl:if test="string-length($xsiType) &gt; 0">
            <xsl:attribute name="xsi:type" select="$xsiType"/>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="string-length($text) &gt; 0">
                <xsl:value-of select="$text"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="string-length($nullFlavor) &gt; 0">
                        <xsl:attribute name="nullFlavor" select="$nullFlavor"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="nullFlavor" select="'UNK'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- DTr1 : SD.TEXT-->
    <!-- Quick and dirty: needs more testing SD.TEXT is a mixed content collection of nodes -->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : SD.TEXT</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional. Contains the nullFlavor</xd:param>
        <xd:param name="text"/>
    </xd:doc>
    <xsl:template name="SD.TEXT">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="text" as="item()*"/>
        <xsl:if test="string-length($xsiType) &gt; 0">
            <xsl:attribute name="xsi:type" select="$xsiType"/>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="count($text//text()) &gt; 0">
                <xsl:copy-of select="$text"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="string-length($nullFlavor) &gt; 0">
                        <xsl:attribute name="nullFlavor" select="$nullFlavor"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="nullFlavor" select="'UNK'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- DTr1 : TEL-->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : TEL</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional. Contains the nullFlavor</xd:param>
        <xd:param name="use"/>
        <xd:param name="value"/>
    </xd:doc>
    <xsl:template name="TEL">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="use"/>
        <xsl:param name="value"/>
        <xsl:param name="useablePeriodLow"/>
        <xsl:param name="useablePeriodHigh"/>
        <xsl:if test="string-length($xsiType) &gt; 0">
            <xsl:attribute name="xsi:type" select="$xsiType"/>
        </xsl:if>
        <xsl:if test="string-length($use) &gt; 0">
            <xsl:attribute name="use" select="$use"/>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="string-length($value) &gt; 0">
                <xsl:attribute name="value" select="$value"/>
                <xsl:if test="string-length($useablePeriodLow) &gt; 0 or string-length($useablePeriodHigh) &gt; 0">
                    <xsl:element name="useablePeriod" namespace="urn:hl7-org:v3">
                        <xsl:call-template name="IVL_TS">
                            <xsl:with-param name="low" select="$useablePeriodLow"/>
                            <xsl:with-param name="high" select="$useablePeriodHigh"/>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="string-length($nullFlavor) &gt; 0">
                        <xsl:attribute name="nullFlavor" select="$nullFlavor"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="nullFlavor" select="'UNK'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- check how other dates are formatted in instance -->
    <!-- DTr1 : TN (Trivial Name) -->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : TN (Trivial Name), passed off to Entity Name (EN)</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional. Contains the nullFlavor</xd:param>
        <xd:param name="value">Trivial name string</xd:param>
    </xd:doc>
    <xsl:template name="TN">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="value"/>
        <xsl:call-template name="EN">
            <xsl:with-param name="xsiType" select="$xsiType"/>
            <xsl:with-param name="nullFlavor" select="$nullFlavor"/>
            <xsl:with-param name="value" select="$value"/>
        </xsl:call-template>
    </xsl:template>
    <!-- DTr1 : TS-->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : TS</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional. Contains the nullFlavor</xd:param>
        <xd:param name="value"/>
    </xd:doc>
    <xsl:template name="TS">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="value"/>
        <xsl:if test="string-length($xsiType) &gt; 0">
            <xsl:attribute name="xsi:type" select="$xsiType"/>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="string-length($value) &gt; 0">
                <xsl:attribute name="value" select="replace($value, '[T:-]', '')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="string-length($nullFlavor) &gt; 0">
                        <xsl:attribute name="nullFlavor" select="$nullFlavor"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="nullFlavor" select="'UNK'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- DTr1 : TS.DATE-->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : TS.DATE</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional. Contains the nullFlavor</xd:param>
        <xd:param name="value"/>
    </xd:doc>
    <xsl:template name="TS.DATE">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="value"/>
        <xsl:call-template name="TS">
            <xsl:with-param name="xsiType" select="$xsiType"/>
            <xsl:with-param name="nullFlavor" select="$nullFlavor"/>
            <xsl:with-param name="value" select="$value"/>
        </xsl:call-template>
    </xsl:template>
    <!-- DTr1 : TS.DATE.FULL-->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : TS.DATE.FULL</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional. Contains the nullFlavor</xd:param>
        <xd:param name="value"/>
    </xd:doc>
    <xsl:template name="TS.DATE.FULL">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="value"/>
        <xsl:call-template name="TS">
            <xsl:with-param name="xsiType" select="$xsiType"/>
            <xsl:with-param name="nullFlavor" select="$nullFlavor"/>
            <xsl:with-param name="value" select="$value"/>
        </xsl:call-template>
    </xsl:template>
    <!-- DTr1 : TS.DATE.MIN-->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : TS.DATE.MIN</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional. Contains the nullFlavor</xd:param>
        <xd:param name="value"/>
    </xd:doc>
    <xsl:template name="TS.DATE.MIN">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="value"/>
        <xsl:call-template name="TS">
            <xsl:with-param name="xsiType" select="$xsiType"/>
            <xsl:with-param name="nullFlavor" select="$nullFlavor"/>
            <xsl:with-param name="value" select="$value"/>
        </xsl:call-template>
    </xsl:template>
    <!-- DTr1 : TS.DATETIME.MIN-->
    <xd:doc>
        <xd:desc>
            <xd:p>DTr1 : TS.DATETIME.MIN</xd:p>
        </xd:desc>
        <xd:param name="xsiType">Optional. Causes @xsi:type to be written with this value</xd:param>
        <xd:param name="nullFlavor">Optional. Contains the nullFlavor</xd:param>
        <xd:param name="value"/>
    </xd:doc>
    <xsl:template name="TS.DATETIME.MIN">
        <xsl:param name="xsiType"/>
        <xsl:param name="nullFlavor"/>
        <xsl:param name="value"/>
        <xsl:call-template name="TS">
            <xsl:with-param name="xsiType" select="$xsiType"/>
            <xsl:with-param name="nullFlavor" select="$nullFlavor"/>
            <xsl:with-param name="value" select="$value"/>
        </xsl:call-template>
    </xsl:template>
</xsl:stylesheet>
