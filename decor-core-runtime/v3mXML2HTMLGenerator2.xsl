<?xml version="1.0" encoding="UTF-8"?>
<!--
    Copyright (c) 2002, Ramsey Systems Ltd. All rights reserved.
    
    Revised and adopted by K. Heitmann 2010
    
    Written by Charles McCay
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions
    are met:
    1. Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
    2. Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
    3. All advertising materials mentioning features or use of this software
    must display the following acknowledgement:
    This product includes software developed by Ramsey Systems Ltd..
    4. Neither the name of Ramsey Systems Ltd. nor the names of its contributors
    may be used to endorse or promote products derived from this software
    without specific prior written permission.
    
    THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
    ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
    IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
    ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
    FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
    DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
    OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
    HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
    OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
    SUCH DAMAGE.
-->
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:exslt="http://exslt.org/common" 
    xmlns:saxon="http://icl.com/saxon" 
    xmlns:xlink="http://www.w3.org/TR/WD-xlink" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:sch="http://www.ascc.net/xml/schematron" 
    extension-element-prefixes="saxon" 
    exclude-result-prefixes="#all" 
    version="2.0">
    <xsl:preserve-space elements="*"/>

    <!--	<xsl:template match="example">
		<xsl:apply-templates/>
	</xsl:template>-->
    <!-- Does pretty printing with tags surrounded by div that cause new lines in rendering -->
    <xsl:template name="doPrettyPrint" match="*" mode="explrender">
        <xsl:param name="indentation" select="0"/>
        <span style="display: block;" class="explrendered">
            <xsl:call-template name="doPrettyPrintInternal">
                <xsl:with-param name="indentation" select="$indentation"/>
            </xsl:call-template>
        </span>
    </xsl:template>
    <!-- Does pretty printing without tags being surrounded by div that cause new lines in rendering -->
    <xsl:template name="doPrettyPrintInternal">
        <xsl:param name="indentation" select="0"/>
        <xsl:param name="newlines"/>
        <!-- get namespace if it is there -->
        <xsl:variable name="theNS" select="substring-before(name(.), local-name(.))"/>
        <!-- do we have contents? -->
        <xsl:variable name="theContents" select="* | comment() | processing-instruction() | text()[string-length(normalize-space(.)) > 0]" as="node()*"/>
        <!-- indentation -->
        <xsl:call-template name="indent">
            <xsl:with-param name="indents" select="$indentation"/>
        </xsl:call-template>

        <!-- emit element name -->
        <span class="ppsign">&lt;</span>
        <xsl:if test="string-length($theNS)>0">
            <span class="ppnamespace">
                <xsl:value-of select="$theNS"/>
            </span>
        </xsl:if>
        <span class="ppelement">
            <xsl:value-of select="local-name(.)"/>
        </span>

        <!-- emit attributes -->
        <xsl:variable name="x">
            <xsl:for-each select="@*">
                <xsl:text> </xsl:text>
                <span class="ppattribute">
                    <xsl:value-of select="name(.)"/>
                </span>
                <span class="ppsign">="</span>
                <span class="ppcontent">
                    <xsl:value-of select="."/>
                </span>
                <span class="ppsign">"</span>
            </xsl:for-each>
        </xsl:variable>
        <xsl:copy-of select="$x"/>
        
        <xsl:if test="not($theContents)">
            <!-- close the element here -->
            <span class="ppsign">
                <xsl:text>/</xsl:text>
            </span>
        </xsl:if>
        <span class="ppsign">&gt;</span>
        
        <xsl:choose>
            <!-- text only? -->
            <xsl:when test="$theContents[self::text()] and not($theContents[self::* | self::comment() | self::processing-instruction()])">
                <span class="pptext">
                    <!-- This preserves new lines -->
                    <xsl:call-template name="insertBreaks">
                        <xsl:with-param name="text" select="$theContents"/>
                    </xsl:call-template>
                </span>
            </xsl:when>
            <xsl:when test="$theContents">
                <xsl:if test="not(string($newlines) = 'false')">
                    <br/>
                </xsl:if>
                <!-- all nodes, except text nodes  -->
                <xsl:apply-templates select="$theContents" mode="explrender">
                    <xsl:with-param name="indentation" select="$indentation+1"/>
                </xsl:apply-templates>
                <xsl:if test="* | comment() | processing-instruction()">
                    <xsl:call-template name="indent">
                        <xsl:with-param name="indents" select="$indentation"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:when>
        </xsl:choose>
        
        <xsl:if test="$theContents">
            <span class="ppsign">&lt;/</span>
            <span class="ppnamespace">
                <xsl:value-of select="$theNS"/>
            </span>
            <span class="ppelement">
                <xsl:value-of select="local-name(.)"/>
            </span>
            <span class="ppsign">&gt;</span>
        </xsl:if>
    </xsl:template>

    <!-- Emit namespace declarations -->
    <xsl:template name="namespaces">
        <xsl:for-each select="@*|.">
            <xsl:variable name="my_ns" select="namespace-uri()"/>
            <!-- Emit a namespace declaration if this element or attribute has a namespace and no ancestor already defines it.
                Currently this produces redundant declarations for namespaces used only on attributes. -->
            <xsl:if test="$my_ns and not(ancestor::*[namespace-uri() = $my_ns])">
                <xsl:variable name="prefix" select="substring-before(name(), local-name())"/>
                <span class="namespace"> xmlns<xsl:if test="$prefix">:<xsl:value-of select="substring-before($prefix, ':')"/>
                    </xsl:if>='<xsl:value-of select="namespace-uri()"/>'</span>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="indent">
        <xsl:param name="indents"/>
        <xsl:for-each select="1 to (2 * $indents)">
            <xsl:value-of select="'&#160;'"/>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="comment()" mode="explrender">
        <xsl:param name="indentation" select="0"/>
        <xsl:choose>
            <!-- This is to stop the xml declaration appearing in comment tags -->
            <xsl:when test="starts-with(., '&lt;?xml')">
                <xsl:value-of select="."/>
            </xsl:when>
            <!-- This matches on any other comment and puts it in a comment tag -->
            <xsl:otherwise>
                <span style="display: block;">
                    <xsl:call-template name="indent">
                        <xsl:with-param name="indents" select="$indentation"/>
                    </xsl:call-template>
                    <span style="color:green">
                        <xsl:text>&lt;!--</xsl:text>
                        <xsl:call-template name="insertBreaks">
                            <xsl:with-param name="text" select="."/>
                        </xsl:call-template>
                        <xsl:text>--&gt;</xsl:text>
                        <br/>
                    </span>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="processing-instruction()" mode="explrender">
        <xsl:param name="indentation" select="0"/>
        <span style="display: block;">
            <xsl:call-template name="indent">
                <xsl:with-param name="indents" select="$indentation"/>
            </xsl:call-template>
            <span style="color:purple;">
                <xsl:text>&lt;?</xsl:text>
                <xsl:call-template name="insertBreaks">
                    <xsl:with-param name="text" select="."/>
                </xsl:call-template>
                <xsl:text>?&gt;</xsl:text>
                <br/>
            </span>
        </span>
    </xsl:template>
    <xsl:template match="text()" mode="explrender">
        <xsl:param name="indentation" select="0"/>
        <xsl:if test="string-length(normalize-space(.))>0">
            <xsl:call-template name="indent">
                <xsl:with-param name="indents" select="$indentation"/>
            </xsl:call-template>
            <span class="pptext">
                <!-- This preserves new lines -->
                <xsl:call-template name="insertBreaks">
                    <xsl:with-param name="text" select="."/>
                </xsl:call-template>
            </span>
        </xsl:if>
    </xsl:template>
    <xsl:template name="insertBreaks">
        <xsl:param name="text"/>
        <xsl:choose>
            <xsl:when test="contains($text,'&#xA;')">
                <xsl:variable name="prefix">
                    <xsl:value-of select="substring-before($text,'&#xA;')"/>
                </xsl:variable>
                <xsl:variable name="suffix">
                    <xsl:value-of select="substring-after($text,'&#xA;')"/>
                </xsl:variable>
                <xsl:value-of select="$prefix"/>
                <br/>
                <xsl:call-template name="insertBreaks">
                    <xsl:with-param name="text">
                        <xsl:value-of select="$suffix"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>