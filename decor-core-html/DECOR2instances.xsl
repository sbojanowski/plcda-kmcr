<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:hl7="urn:hl7-org:v3"
    exclude-result-prefixes="#all"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jun 17, 2015</xd:p>
            <xd:p><xd:b>Author:</xd:b> ahenket</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    
    <!--
        parameters
        ==========
        to this XSLT and all invoked scripts
    -->
    <xsl:param name="language" select="'nl-NL'"/>
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
    <xsl:param name="adram" as="xs:string?"/>
    <xsl:param name="inputStaticBaseUri" select="static-base-uri()"/>
    <xsl:param name="inputBaseUri" select="base-uri()"/>
    <xsl:param name="theBaseURI2DECOR" select="string-join(tokenize($inputBaseUri, '/')[position() &lt; last()], '/')"/>
    
    <!-- die on circular references or not, values: 'continue' (default), 'die' -->
    <xsl:param name="onCircularReferences" select="'continue'"/>
    
    <!-- see this URL in asserts and reports points to 'generated' HTML fiels or to the 'live' environment.
        It also determines context for any other HTML link.
    -->
    <xsl:param name="seeThisUrlLocation" select="'generated'"/>
    
    <!-- Do HTML with treetree/treeblank indenting (default. or set to false()) or treetable.js compatible indenting -->
    <xsl:param name="switchCreateTreeTableHtml" select="'true'"/>
    
    <xsl:param name="filtersfile" select="concat($theBaseURI2DECOR, '/', 'filters.xml')"/>
    <xsl:param name="filtersfileavailable" select="doc-available($filtersfile)" as="xs:boolean"/>
    
    <xsl:include href="DECOR2html.xsl"/>
    <xsl:include href="DECOR-basics.xsl"/>
    
    <xsl:output method="xml" name="xml" indent="yes" version="1.0" encoding="UTF-8" exclude-result-prefixes="#all"/>
    
    <xsl:output method="text" name="text"/>
    
    <xsl:output method="html" name="html" indent="no" omit-xml-declaration="yes" version="4.01" encoding="UTF-8"  doctype-system="http://www.w3.org/TR/html4/strict.dtd"/>
    
    <xsl:output method="xhtml" name="xhtml" indent="no" omit-xml-declaration="yes" encoding="UTF-8" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
    
    <xsl:template match="/">
        <xsl:variable name="fname" select="replace(tokenize(document-uri(.),'/')[last()],'\.xml','')"/>
        <xsl:result-document href="{$fname}.txt" format="text">
            <xsl:for-each select="instances/hl7:instance">
                <xsl:text>{| border="1" cellspacing="2" style="width:100%; background-color:#eeeeee;" class="wikitable"</xsl:text>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>|-</xsl:text>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>! XML !! Data type !! Card/Conf !! Concept ID !! Concept </xsl:text>
                <xsl:text>&#10;</xsl:text>
                <xsl:apply-templates select="*" mode="createOutputRowWiki">
                    <xsl:with-param name="nestinglevel" select="0"/>
                </xsl:apply-templates>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>|}</xsl:text>
                <xsl:text>&#10;</xsl:text>
            </xsl:for-each>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="*" mode="createOutputRowWiki">
        <xsl:param name="nestinglevel"/>
        <xsl:if test="not(self::community|self::concept|self::attribute)">
            <xsl:text>|-</xsl:text>
            <xsl:text>&#10;</xsl:text>
            <xsl:text>| &#10;{| </xsl:text>
            <xsl:text>&#10;</xsl:text>
            <xsl:text>| </xsl:text>
            <xsl:call-template name="doIndentLevelWiki">
                <xsl:with-param name="level" select="$nestinglevel"/>
            </xsl:call-template>
            <xsl:text> || </xsl:text>
            <xsl:choose>
                <xsl:when test="@withpredicate">
                    <xsl:call-template name="outputPathWiki">
                        <xsl:with-param name="pathname" select="@withpredicate"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="@original">
                    <xsl:call-template name="outputPathWiki">
                        <xsl:with-param name="pathname" select="@original"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="outputPathWiki">
                        <xsl:with-param name="pathname" select="name()"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:for-each select="@* except (@conceptId|@conceptText|@label|@datatype|@cardconf|@original|@withpredicate|@minimumMultiplicity|@maximumMultiplicity|@conformance|@isMandatory)">
                <xsl:text> </xsl:text>
                <xsl:value-of select="name()"/>
                <xsl:text>="</xsl:text>
                <xsl:value-of select="."/>
                <xsl:text>"</xsl:text>
            </xsl:for-each>
            <xsl:text>&#10;</xsl:text>
            <xsl:text>|}&#10;</xsl:text>
            <xsl:text> || </xsl:text>
            <xsl:value-of select="@datatype"/>
            <xsl:text> || </xsl:text>
            <xsl:value-of select="@cardconf"/>
            <xsl:text> || </xsl:text>
            <xsl:for-each select="concept">
                <xsl:text>&lt;div&gt;</xsl:text>
                <xsl:value-of select="if (string-length(@refname)>0) then @refname else @ref"/>
                <xsl:text>&lt;/div&gt;</xsl:text>
            </xsl:for-each>
            <xsl:text> || </xsl:text>
            <xsl:for-each select="concept">
                <xsl:text>&lt;div&gt;</xsl:text>
                <xsl:value-of select="@conceptText"/>
                <xsl:text>&lt;/div&gt;</xsl:text>
            </xsl:for-each>
            <xsl:text>&#10;</xsl:text>
            
            <xsl:for-each select="attribute[concept]">
                <xsl:text>|-</xsl:text>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>| &#10;{| </xsl:text>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>|</xsl:text>
                <xsl:call-template name="doIndentLevelWiki">
                    <xsl:with-param name="level" select="$nestinglevel"/>
                    <xsl:with-param name="icon" select="false()"/>
                </xsl:call-template>
                <xsl:text> || </xsl:text>
                <xsl:call-template name="outputPathWiki">
                    <xsl:with-param name="pathname" select="name()"/>
                </xsl:call-template>
                <xsl:text> </xsl:text>
                <xsl:value-of select="@name"/>
                <xsl:text>="</xsl:text>
                <xsl:value-of select="@value"/>
                <xsl:text>"</xsl:text>
                <xsl:text>&#10;</xsl:text>
                <xsl:text>|}&#10;</xsl:text>
                <xsl:text> || </xsl:text>
                <xsl:value-of select="@datatype"/>
                <xsl:text> || </xsl:text>
                <xsl:value-of select="@cardconf"/>
                <xsl:text> || </xsl:text>
                <xsl:for-each select="concept">
                    <xsl:text>&lt;div&gt;</xsl:text>
                    <xsl:value-of select="if (string-length(@refname)>0) then @refname else @ref"/>
                    <xsl:text>&lt;/div&gt;</xsl:text>
                </xsl:for-each>
                <xsl:text> || </xsl:text>
                <xsl:for-each select="concept">
                    <xsl:text>&lt;div&gt;</xsl:text>
                    <xsl:value-of select="@conceptText"/>
                    <xsl:text>&lt;/div&gt;</xsl:text>
                </xsl:for-each>
                <xsl:text>&#10;</xsl:text>
            </xsl:for-each>
            <!--<xsl:for-each select="concept[community]">
                <tr>
                    <td>&#160;</td>
                    <td colspan="5" style="vertical-align: top; border: 1px solid #CCCCA3;">
                        <table width="100%">
                            <tr>
                                <xsl:text>Community mappings voor concept: </xsl:text>
                                <xsl:call-template name="doShorthandId">
                                    <xsl:with-param name="id" select="@ref"/>
                                </xsl:call-template>
                                <xsl:for-each select="@* except (@ref|@refname)">
                                    <xsl:text> </xsl:text>
                                    <xsl:value-of select="name()"/>
                                    <xsl:text>="</xsl:text>
                                    <xsl:value-of select="."/>
                                    <xsl:text>"</xsl:text>
                                </xsl:for-each>
                            </tr>
                            <xsl:for-each select="community">
                                <tr>
                                    <td style="vertical-align: top; background-color: #FFEAEA;">
                                        <p>
                                            <xsl:text>Community: </xsl:text>
                                            <b>
                                                <xsl:choose>
                                                    <xsl:when test="string-length(@label)>0">
                                                        <xsl:value-of select="@label"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="@name"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </b>
                                        </p>
                                        <xsl:for-each select="data">
                                            <p>
                                                <div style="font-style: italic; width: 100%; border-bottom: 1px solid lightgrey; padding-bottom: 4px">
                                                    <xsl:choose>
                                                        <xsl:when test="string-length(@label)>0">
                                                            <xsl:value-of select="@label"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="@type"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </div>
                                                <!-\-hr style="height: 0.2px;"/-\->
                                                <xsl:copy-of select="node()"/>
                                            </p>
                                        </xsl:for-each>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </table>
                    </td>
                </tr>
            </xsl:for-each>-->
            <xsl:apply-templates select="*" mode="createOutputRowWiki">
                <xsl:with-param name="nestinglevel" select="$nestinglevel+1"/>
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="doIndentLevelWiki">
        <xsl:param name="level"/>
        <xsl:param name="icon" select="true()" as="xs:boolean"/>
        <xsl:for-each select="1 to $level - 1">
            <xsl:text> || [[File:treeblank.png|16px]] </xsl:text>
        </xsl:for-each>
        <xsl:if test="$level &gt; 0 and $icon">
            <xsl:text> | style="vertical-align: top;" | [[File:treetree.png|16px]] </xsl:text>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="outputPathWiki">
        <xsl:param name="pathname"/>
        <xsl:variable name="hasawhere" select="contains($pathname, '[')"/>
        <xsl:if test="$hasawhere">
            <xsl:text>'''</xsl:text>
            <xsl:value-of select="substring-before($pathname, '[')"/>
            <xsl:text>'''</xsl:text>
            <xsl:text>&lt;br/&gt;</xsl:text>
            <xsl:call-template name="getMessage">
                <xsl:with-param name="key" select="'whereX'"/>
            </xsl:call-template>
            <xsl:text>&lt;br/&gt;</xsl:text>
        </xsl:if>
        <!-- split up pathnames concatenated with | (or) and output them seperately -->
        <xsl:variable name="x">
            <xsl:call-template name="tokenize">
                <xsl:with-param name="string">
                    <xsl:value-of select="$pathname"/>
                </xsl:with-param>
                <xsl:with-param name="delimiters">
                    <xsl:value-of select="string('|')"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:for-each select="$x/token">
            <xsl:if test="count(preceding-sibling::node())">
                <xsl:call-template name="getMessage">
                    <xsl:with-param name="key" select="'orY'"/>
                </xsl:call-template>
                <xsl:text>&lt;br/&gt;</xsl:text>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="$hasawhere">
                    <xsl:text>''</xsl:text>
                    <xsl:variable name="thep">
                        <xsl:call-template name="splitString">
                            <xsl:with-param name="str" select="substring(., string-length(substring-before(., '[')) + 1)"/>
                            <xsl:with-param name="del" select="string('/')"/>
                            <xsl:with-param name="preceedIndent" select="string('_')"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:value-of select="replace($thep, '\[', ' [')"/>
                    <xsl:text>''</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>'''</xsl:text>
                    <xsl:call-template name="splitString">
                        <xsl:with-param name="str" select="."/>
                        <xsl:with-param name="del" select="string('/')"/>
                        <xsl:with-param name="preceedIndent" select="string('_')"/>
                    </xsl:call-template>
                    <xsl:text>'''</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>