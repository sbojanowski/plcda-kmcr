<!-- 
    ART-DECOR® STANDARD COPYRIGHT AND LICENSE NOTE
    Copyright © ART-DECOR Expert Group and ART-DECOR Open Tools GmbH
    see https://docs.art-decor.org/copyright and https://docs.art-decor.org/licenses

    This file is part of the ART-DECOR® tools suite.    
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.0" exclude-result-prefixes="#all">
    <!-- 
        the param outputformat specifies output
        hgraph format returns the hierarchical graph of the template chain including classification
        hgraphwiki is the same as hgraph but the OIDs of the templates are in Mediawiki link style [[1.2.3...]]
        wikilist returns the list of templates in Mediawiki transclusion style, sorted by classification
        hgraph is the default
        
        coretableonly if true only the core table is emitted, not a whole HTML document.
    -->
    <xsl:param name="outputformat" as="xs:string"/>
    <xsl:param name="coretableonly" select="'false'" as="xs:string"/>
    <!-- 
        derived parameters
    -->
    <xsl:param name="wikilinks" as="xs:boolean">
        <!-- show links as wiki links [[ ]] -->
        <xsl:choose>
            <xsl:when test="$outputformat=('hgraphwiki', 'wikilist', 'transclusionwikilist')">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <xsl:param name="wikilist" as="xs:boolean">
        <xsl:choose>
            <xsl:when test="$outputformat=('wikilist', 'transclusionwikilist')">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <!-- 
        output methods
    -->
    <xsl:output method="xml" name="xml" indent="no" version="1.0" encoding="UTF-8" exclude-result-prefixes="#all"/>
    <xsl:output method="html" name="html" indent="no" version="4.01" encoding="UTF-8" doctype-public="-//W3C//DTD HTML 4.01//EN" doctype-system="http://www.w3.org/TR/html4/strict.dtd"/>
    <xsl:output method="xhtml" name="xhtml" indent="no" encoding="UTF-8" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
    <!-- 
        real start here
    -->
    <xsl:template match="/">
        <xsl:variable name="templatesraw" select="."/>
        <xsl:variable name="result">
            <html>
                <head>
                    <link href="https://assets.art-decor.org/ADAR/rv/assets/css/default.css" rel="stylesheet" type="text/css"/>
                    <style type="text/css">
                        <![CDATA[
                         ol.ad-nobullets { list-style-type: none;}
                         li.ad-dataset-group { font-weight: bold; padding: 7px 0 0 0; text-decoration: underline;}
                         li.ad-dataset-item, li.ad-template { list-style-type: none; padding: 7px 0 0 0; }
                         ul.ad-terminology-code { list-style-position: inside; padding: 7px 0 3px 20px; border: 0px; list-style-type: disc;  }
                         ul.ad-transaction-condition { padding: 7px 0 3px 20px; list-style-position: inside;}
                         li.ad-transaction-condition { list-style-type: circle; padding: 0 3px 0 5px; border-left: 5px solid #ddd; }
                         div.ad-dataset-itemnumber, div.ad-templatetype { margin: -2px 0 5px 6px; display: inline-block; border: 1px solid #c0c0c0; 
                            background-color: #eee; border-radius: 3px 3px 3px 3px; -moz-border-radius: 3px 3px 3px 3px; -webkit-border-radius: 3px 3px 3px 3px; 
                            padding: 1px 1px 1px 1px;width: auto !important; padding: 1px 5px 1px 5px;}
                         div.level1 { font-size: 2ex; font-weight: bold; text-decoration: underline;}
                         table.ad-transaction-table, table.ad-template-table {border: 1px solid #888; border-collapse: collapse; width:100%;}
                         
                         
                         div.cdadocumentlevel { background-color: #eef; }
                         div.cdaheaderlevel { background-color: #ffe; }
                         div.cdasectionlevel { background-color: #efe; }
                         div.cdaentrylevel { background-color: #fef; }
                        .nowrapinline{
                            display: inline;
                            white-space: nowrap !important;
                         }
                         ]]></style>
                </head>
                <body>
                    <xsl:choose>
                        <xsl:when test="$wikilist=true()">
                            <!-- return the list of templates in Mediawiki transclusion style, sorted by classification -->
                            <xsl:variable name="tflat">
                                <templates>
                                    <xsl:apply-templates select="$templatesraw" mode="flatten">
                                        <xsl:with-param name="nest" select="1"/>
                                    </xsl:apply-templates>
                                </templates>
                            </xsl:variable>
                            <xsl:choose>
                                <xsl:when test="$outputformat='transclusionwikilist'">
                                    <xsl:for-each select="('cdadocumentlevel', 'cdaheaderlevel', 'cdasectionlevel', 'cdaentrylevel')">
                                        <xsl:variable name="c" select="."/>
                                        <xsl:choose>
                                            <xsl:when test="$c = 'cdadocumentlevel'">
                                                <xsl:text>=CDA Document Level Templates=</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="$c = 'cdaheaderlevel'">
                                                <xsl:text>=CDA Header Level Templates=</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="$c = 'cdasectionlevel'">
                                                <xsl:text>=CDA Section Level Templates=</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="$c = 'cdaentrylevel'">
                                                <xsl:text>=CDA Entry Level Templates=</xsl:text>
                                            </xsl:when>
                                        </xsl:choose>
                                        <br/>
                                        <xsl:for-each-group select="$templatesraw//template[@classification=$c]" group-by="@id">
                                            <xsl:sort select="upper-case(@displayName)"/>
                                            <xsl:text>==</xsl:text>
                                            <xsl:value-of select="@displayName"/>
                                            <xsl:text>==</xsl:text>
                                            <br/>
                                            <xsl:text>{{:</xsl:text>
                                            <xsl:value-of select="@id"/>
                                            <xsl:text>/dynamic}}</xsl:text>
                                            <br/>
                                        </xsl:for-each-group>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:when test="$outputformat='wikilist'">
                                    <xsl:for-each-group select="$templatesraw//template" group-by="@id">
                                        <xsl:sort select="replace(replace(concat(@id, '.'), '\.', '.0000000000'), '.0*([0-9]{9,})', '.$1')"/>
                                        <xsl:text>*</xsl:text>
                                        <xsl:text> </xsl:text>
                                        <xsl:if test="$wikilinks=true()">
                                            <xsl:text>[[</xsl:text>
                                        </xsl:if>
                                        <xsl:value-of select="@id"/>
                                        <xsl:if test="$wikilinks=true()">
                                            <xsl:text>]]</xsl:text>
                                        </xsl:if>
                                        <xsl:text> </xsl:text>
                                        <xsl:value-of select="@displayName"/>
                                        <br/>
                                    </xsl:for-each-group>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- return the hierarchical graph (hiergraph or lovely hgraph) of the template chain including classification -->
                            <xsl:apply-templates select="$templatesraw" mode="hiergraphtable">
                                <xsl:with-param name="wikilinks" select="$wikilinks"/>
                            </xsl:apply-templates>
                        </xsl:otherwise>
                    </xsl:choose>
                </body>
            </html>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$coretableonly='true' and $wikilist=false()">
                <!-- works only for hgraph as of now -->
                <xsl:copy-of select="$result//html/body"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$result"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- 
        templates flattened list
    -->
    <xsl:template match="template" mode="flatten">
        <xsl:param name="nest"/>
        <template id="{@id}" displayName="{@displayName}" classification="{@classification}" nest="{$nest}"/>
        <xsl:apply-templates select="template" mode="flatten">
            <xsl:with-param name="nest" select="$nest+1"/>
        </xsl:apply-templates>
    </xsl:template>
    <xsl:template match="template" mode="hiergraphtable">
        <xsl:param name="wikilinks" as="xs:boolean"/>
        <!-- return the hierarchical graph (hiergraph or lovely hgraph) of the template chain including classification -->
        <table class="ad-template-table">
            <tr>
                <td style="padding: 7px 7px 17px 7px;">
                    <ol class="ad-nobullets" style="padding: 0px !important; margin: 0.3em 0 0 0;">
                        <xsl:apply-templates select="." mode="hiergraph">
                            <xsl:with-param name="wikilinks" select="$wikilinks"/>
                        </xsl:apply-templates>
                    </ol>
                </td>
            </tr>
        </table>
    </xsl:template>
    <!-- 
        hiergraph templates list
    -->
    <xsl:template match="template[string-length(tokenize(@id, '\.')[last()])&lt;=9]" mode="hiergraph">
        <xsl:param name="wikilinks" as="xs:boolean"/>
        <xsl:variable name="ctok" select="tokenize(@classification, ' ')"/>
        <xsl:variable name="c">
            <xsl:choose>
                <xsl:when test="@recurse='true'">
                    <xsl:value-of select="'@'"/>
                </xsl:when>
                <xsl:when test="count($ctok)=1">
                    <xsl:value-of select="$ctok[1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'*'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <li class="ad-template">
            <div class="{concat('nowrapinline ad-templatetype ', $c)}">
                <xsl:choose>
                    <xsl:when test="$c = 'cdadocumentlevel'">
                        <xsl:text> Document</xsl:text>
                    </xsl:when>
                    <xsl:when test="$c = 'cdaheaderlevel'">
                        <xsl:text> Header</xsl:text>
                    </xsl:when>
                    <xsl:when test="$c = 'cdasectionlevel'">
                        <xsl:text> Section</xsl:text>
                    </xsl:when>
                    <xsl:when test="$c = 'cdaentrylevel'">
                        <xsl:text> Entry</xsl:text>
                    </xsl:when>
                    <xsl:when test="string-length($c)=0">
                        <xsl:text>–</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="$c"/>
                        <xsl:text> </xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
            <xsl:value-of select="concat('&#xa0;', @displayName)"/>
            <xsl:text> (</xsl:text>
            <xsl:if test="$wikilinks=true()">
                <xsl:text>[[</xsl:text>
            </xsl:if>
            <xsl:value-of select="@id"/>
            <xsl:if test="$wikilinks=true()">
                <xsl:text>]]</xsl:text>
            </xsl:if>
            <xsl:text>)</xsl:text>
            <xsl:if test="template">
                <ol>
                    <xsl:apply-templates select="template" mode="hiergraph">
                        <xsl:with-param name="wikilinks" select="$wikilinks"/>
                    </xsl:apply-templates>
                </ol>
            </xsl:if>
        </li>
    </xsl:template>
</xsl:stylesheet>