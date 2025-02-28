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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:error="http://art-decor.org/ns/decor/template/error" xmlns:local="http://art-decor.org/functions" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="#all" version="2.0">
    
    <xsl:output method="xhtml" name="xhtml" indent="no" encoding="UTF-8" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select="//group" mode="governancelist"/>
    </xsl:template>
    
    <xsl:template match="group" mode="governancelist">
        <table class="treetable zebra-table" style="border: 1px solid #999; width=100%; border=0;" cellspacing="3" cellpadding="2">
            <tr class="headinglabel">
                <th style="text-align: left;">Id</th>
                <th style="text-align: left;">Name</th>
                <th style="text-align: left;">Use</th>
            </tr>
            <xsl:choose>
                <xsl:when test="false()">
                    <!-- sort value sets by id -->
                    <xsl:for-each-group select="//project/valueSet" group-by="@id|@ref">
                        <xsl:sort select="replace(replace (concat(@id|@ref, '.'), '\.', '.0000000000'), '.0*([0-9]{9,})', '.$1')"/>
                        <xsl:apply-templates select="." mode="governancelist">
                            <xsl:with-param name="group" select="current-group()"/>
                            <xsl:with-param name="bgcolor" select="if (position() mod 2 = 0) then '#eee' else '#fff'"/>
                        </xsl:apply-templates>
                    </xsl:for-each-group>
                </xsl:when>
                <xsl:when test="false()">
                    <!-- sort value sets by name -->
                    <xsl:for-each-group select="//project/valueSet" group-by="@id|@ref">
                        <xsl:sort select="(valueSet[@id]/@displayName)[1]"/>
                        <xsl:apply-templates select="." mode="governancelist">
                            <xsl:with-param name="group" select="current-group()"/>
                            <xsl:with-param name="bgcolor" select="if (position() mod 2 = 0) then '#eee' else '#fff'"/>
                        </xsl:apply-templates>
                    </xsl:for-each-group>
                </xsl:when>
                <xsl:when test="true()">
                    <!-- sort templates by id -->
                    <xsl:for-each-group select="//project/template" group-by="@id|@ref">
                        <xsl:sort select="replace(replace (concat(@id|@ref, '.'), '\.', '.0000000000'), '.0*([0-9]{9,})', '.$1')"/>
                        <xsl:apply-templates select="." mode="governancelist">
                            <xsl:with-param name="group" select="current-group()"/>
                            <xsl:with-param name="bgcolor" select="if (position() mod 2 = 0) then '#eee' else '#fff'"/>
                        </xsl:apply-templates>
                    </xsl:for-each-group>
                </xsl:when>
                <xsl:otherwise>
                    <!-- sort templates by name -->
                    <xsl:for-each-group select="//project/template" group-by="@id|@ref">
                        <xsl:sort select="(template[@id]/@displayName)[1]"/>
                        <xsl:apply-templates select="." mode="governancelist">
                            <xsl:with-param name="group" select="current-group()"/>
                            <xsl:with-param name="bgcolor" select="if (position() mod 2 = 0) then '#eee' else '#fff'"/>
                        </xsl:apply-templates>
                    </xsl:for-each-group>
                </xsl:otherwise>
            </xsl:choose> 
        </table>
    </xsl:template>
    
    <xsl:template match="template" mode="governancelist">
        <xsl:param name="group"/>
        <xsl:param name="bgcolor"/>
        <xsl:variable name="tid" select="@id|@ref"/>
        <tr style="vertical-align: top; background-color:{$bgcolor}" class="list">
            <td width="1%">
                <xsl:value-of select="$tid"/>
            </td>
            <td>
                <xsl:apply-templates select="if (count(template[@id])>0) then template[@id] else template[@ref]" mode="governancelistversion"/>
            </td>
            <td>
                <xsl:variable name="puts">
                    <puts>
                        <xsl:for-each-group select="$group/ancestor::project" group-by="@prefix">
                            <put>
                                <xsl:copy-of select="@prefix"/>
                                <xsl:if test="template/template[(@id|@ref)=$tid][not(@ident)]">
                                    <xsl:attribute name="defs" select="'true'"/>
                                </xsl:if>
                            </put>
                        </xsl:for-each-group>
                    </puts>
                </xsl:variable>
                <xsl:for-each select="$puts/puts/*">
                    <xsl:sort select="@defs" order="descending"/>
                    <xsl:sort select="@prefix"/>
                    <xsl:if test="not(@defs)">
                        <span class="repobox nowrapinline">
                            <div class="repo refonly">ref</div>
                        </span>
                        <xsl:text> </xsl:text>
                    </xsl:if>
                    <xsl:value-of select="@prefix"/>
                    <xsl:if test="position()&lt;last()">
                        <br />
                    </xsl:if>
                </xsl:for-each>
            </td>
        </tr>
    </xsl:template>
    
    <xsl:template match="template" mode="governancelistversion">
        <xsl:value-of select="@displayName"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="@effectiveDate"/>
        <br />
    </xsl:template>
    
    <xsl:template match="valueSet" mode="governancelist">
        <xsl:param name="group"/>
        <xsl:param name="bgcolor"/>
        <xsl:variable name="vid" select="@id|@ref"/>
        <tr style="vertical-align: top; background-color:{$bgcolor}" class="list">
            <td width="1%">
                <xsl:value-of select="$vid"/>
            </td>
            <td>
                <xsl:apply-templates select="if (count(valueSet[@id])>0) then valueSet[@id] else valueSet[@ref]" mode="governancelistversion"/>
            </td>
            <td>
                <xsl:variable name="puts">
                    <puts>
                        <xsl:for-each-group select="$group/ancestor::project" group-by="@prefix">
                            <put>
                                <xsl:copy-of select="@prefix"/>
                                <xsl:if test="valueSet/valueSet[(@id)=$vid][not(@referencedFrom)]">
                                    <xsl:attribute name="defs" select="'true'"/>
                                </xsl:if>
                            </put>
                        </xsl:for-each-group>
                    </puts>
                </xsl:variable>
                <xsl:for-each select="$puts/puts/*">
                    <xsl:sort select="@defs" order="descending"/>
                    <xsl:sort select="@prefix"/>
                    <xsl:if test="not(@defs)">
                        <span class="repobox nowrapinline">
                            <div class="repo refonly">ref</div>
                        </span>
                        <xsl:text> </xsl:text>
                    </xsl:if>
                    <xsl:value-of select="@prefix"/>
                    <xsl:if test="position()&lt;last()">
                        <br />
                    </xsl:if>
                </xsl:for-each>
            </td>
        </tr>
    </xsl:template>
    
    <xsl:template match="valueSet" mode="governancelistversion">
        <xsl:value-of select="@displayName"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="@effectiveDate"/>
        <br />
    </xsl:template>
    
</xsl:stylesheet>