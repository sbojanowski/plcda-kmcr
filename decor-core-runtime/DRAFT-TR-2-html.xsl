<!-- 
    ART-DECOR® STANDARD COPYRIGHT AND LICENSE NOTE
    Copyright © ART-DECOR Expert Group and ART-DECOR Open Tools GmbH
    see https://docs.art-decor.org/copyright and https://docs.art-decor.org/licenses

    This file is part of the ART-DECOR® tools suite.    
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:local="http://art-decor.org/functions" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:ac="http://www.atlassian.com/schema/confluence/4/ac/" xmlns:ri="http://www.atlassian.com/schema/confluence/4/ri/"
    xmlns:svg="http://www.w3.org/2000/svg" xmlns:err="http://www.w3.org/2005/xqt-errors" version="2.0" exclude-result-prefixes="#all">
    <!-- 
    draft new transaction/dataset render engine
    will replace anything related in DECOR2wiki and in render xqueries
    KH 20200924
    -->

    <xsl:param name="lang" select="'de-DE'"/>

    <!-- 
    special new parameters
    -->
    <!-- inactiveStatusCodes" as ('cancelled','rejected','deprecated') already defined -->
    <xsl:param name="draftStatusCodes" select="tokenize('new,draft,pending', ',')" as="xs:string+"/>


    <!-- PUBLIC: indent for concepts hierarchy if true by priv_indent_amount px, no indent otherwise -->
    <xsl:param name="p_indent" select="'true'"/>
    <!-- PRIVATE: indent amount as nnpx, nn integer, for the CSS parameter of the prepending div -->
    <xsl:param name="priv_indent_amount" select="
            if ($p_indent = 'true') then
                '20px'
            else
                '0px'"/>
    <!-- PUBLIC: show item numbers -->
    <xsl:param name="p_show_item_numbers" select="'true'"/>
    <!-- PUBLIC: show description -->
    <xsl:param name="p_show_description" select="'true'"/>
    <!-- PUBLIC: show comment -->
    <xsl:param name="p_show_comment" select="'true'"/>
    <!-- PUBLIC: show synonym -->
    <xsl:param name="p_show_synonym" select="'true'"/>
    <!-- PUBLIC: show valueDomain -->
    <xsl:param name="p_show_valueDomain" select="'true'"/>
    <!-- PUBLIC: show property -->
    <xsl:param name="p_show_property" select="'true'"/>
    <!-- PUBLIC: show rationale -->
    <xsl:param name="p_show_rationale" select="'true'"/>
    <!-- PUBLIC: show example -->
    <xsl:param name="p_show_example" select="'true'"/>
    <!-- PUBLIC: show source -->
    <xsl:param name="p_show_source" select="'true'"/>
    <!-- PUBLIC: show operationalization -->
    <xsl:param name="p_show_operationalization" select="'true'"/>
    <!-- PUBLIC: show relationships -->
    <xsl:param name="p_show_relationships" select="'true'"/>
    <!-- PUBLIC: show terminologyassociations -->
    <xsl:param name="p_show_terminologyassociations" select="'true'"/>
    <!-- PUBLIC: show items with status 'cancelled','rejected','deprecated' -->
    <xsl:param name="p_show_bluestatus" select="'false'"/>
    <xsl:param name="p_bluestatusset" select="
            if ($p_show_bluestatus = 'false') then
                $inactiveStatusCodes
            else
                ()"/>
    <!-- PUBLIC: show multiplicity with tags instead of numbers -->
    <xsl:param name="p_show_multiplicity_tags" select="'false'"/>

    <!-- 
    end new parameters
    -->

    <xsl:include href="DECOR2wiki.xsl"/>

    <xsl:output method="xml" name="xml" indent="yes" version="1.0" encoding="UTF-8" exclude-result-prefixes="#all"/>
    <xsl:output method="text" name="text"/>
    <xsl:output method="html" name="html" indent="no" omit-xml-declaration="yes" version="4.01" encoding="UTF-8" doctype-system="http://www.w3.org/TR/html4/strict.dtd"/>
    <xsl:output method="xhtml" name="xhtml" indent="no" omit-xml-declaration="yes" encoding="UTF-8" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>

    <xsl:template match="/" priority="2">
        <!--
            check some private paraneters
        -->
        <xsl:if test="not(matches($priv_indent_amount, '\d*px'))">
            <xsl:message terminate="yes">
                <xsl:text>priv_indent_amount malformed</xsl:text>
            </xsl:message>
        </xsl:if>
        <xsl:if test="not(matches($p_show_item_numbers, '(true|false)'))">
            <xsl:message terminate="yes">
                <xsl:text>p_show_item_numbers malformed</xsl:text>
            </xsl:message>
        </xsl:if>
        <!-- layout starts here -->
        <html>
            <head>
                <link href="https://assets.art-decor.org/ADAR/rv/assets/css/default.css" rel="stylesheet" type="text/css"/>
                <link href="transaction_new.css" rel="stylesheet" type="text/css"/>
            </head>
            <body>
                <h1>
                    <xsl:value-of select="dataset/name"/>
                </h1>
                <xsl:text>&#10;</xsl:text>
                <xsl:if test="dataset/desc[@language = $language]">
                    <p>
                        <xsl:copy-of select="dataset/desc[@language = $language]/node()"/>
                    </p>
                    <xsl:text>&#10;</xsl:text>
                </xsl:if>
                <table class="artdecor zebra-table" width="100%" border="0" cellspacing="1" cellpadding="2" style="background: transparent; border: 1px solid #C0C0C0;">
                    <tr>
                        <th style="text-align: left;">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'dataSetId'"/>
                                <xsl:with-param name="lang" select="$lang"/>
                            </xsl:call-template>
                        </th>
                        <th>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'effectiveDate'"/>
                                <xsl:with-param name="lang" select="$lang"/>
                            </xsl:call-template>
                        </th>
                        <th>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'columnStatus'"/>
                                <xsl:with-param name="lang" select="$lang"/>
                            </xsl:call-template>
                        </th>
                        <th>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'columnVersionLabel'"/>
                                <xsl:with-param name="lang" select="$lang"/>
                            </xsl:call-template>
                        </th>
                    </tr>
                    <tr>
                        <td style="vertical-align: top; padding-right: 10px;">
                            <xsl:value-of select="dataset/@id"/>
                        </td>
                        <td style="vertical-align: top; padding-right: 10px;">
                            <xsl:call-template name="showDate">
                                <xsl:with-param name="date" select="dataset/@effectiveDate"/>
                            </xsl:call-template>
                        </td>
                        <td style="vertical-align: top; padding-right: 30px;">
                            <xsl:call-template name="modernDot">
                                <xsl:with-param name="status" select="dataset/@statusCode"/>
                            </xsl:call-template>
                        </td>
                        <td style="vertical-align: top;">
                            <xsl:value-of select="dataset/@versionLabel"/>
                        </td>
                    </tr>
                </table>
                <hr class="meta"/>
                <!-- do the top level concetpts -->
                <xsl:apply-templates select="dataset/concept" mode="here"/>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="concept" mode="here">
        <xsl:apply-templates select=".[not(@statusCode = $p_bluestatusset)]" mode="elementtransfer2">
            <xsl:with-param name="type" select="@type"/>
            <xsl:with-param name="hlevel" select="2"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="concept" mode="elementtransfer2">
        <xsl:param name="type"/>
        <xsl:param name="hlevel"/>
        <xsl:param name="headprefix"/>
        <xsl:param name="headsuffix"/>

        <xsl:variable name="ocid" select="@id"/>

        <xsl:variable name="statusColor">
            <xsl:choose>
                <xsl:when test="@statusCode = $inactiveStatusCodes">
                    <xsl:text> ad-itemnumber-blue </xsl:text>
                </xsl:when>
                <xsl:when test="@statusCode = $draftStatusCodes">
                    <xsl:text> ad-itemnumber-yellow </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text> ad-itemnumber-green </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="dename" select="name[@language = $language]"/>
        <!-- 
            heading 
            optional the level indictaed in parameter
        -->
        <div style="margin-left: {$priv_indent_amount};">
            <xsl:call-template name="doHeading">
                <xsl:with-param name="hlevel" select="$hlevel"/>
                <xsl:with-param name="heading" select="$dename"/>
                <xsl:with-param name="headprefix" select="$headprefix"/>
                <xsl:with-param name="headsuffix">
                    <xsl:text> </xsl:text>
                    <xsl:if test="@minimumMultiplicity | @maximumMultiplicity">
                        <xsl:choose>
                            <xsl:when test="$p_show_multiplicity_tags = 'true' and @minimumMultiplicity='0'">
                                <div class="ad-multiplicity-tag">
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'multiplicityOptional'"/>
                                        <xsl:with-param name="lang" select="$lang"/>
                                    </xsl:call-template>
                                </div>
                            </xsl:when>
                            <xsl:when test="$p_show_multiplicity_tags = 'true' and @minimumMultiplicity gt '0'">
                                <div class="ad-multiplicity-tag">
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'multiplicityNotOptional'"/>
                                        <xsl:with-param name="lang" select="$lang"/>
                                    </xsl:call-template>
                                </div>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="@minimumMultiplicity"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:choose>
                            <xsl:when test="$p_show_multiplicity_tags = 'true'">
                                <xsl:text> </xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>...</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:choose>
                            <xsl:when test="$p_show_multiplicity_tags = 'true' and @maximumMultiplicity gt '1'">
                                <div class="ad-multiplicity-tag">
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'multiplicityRepeatable'"/>
                                        <xsl:with-param name="lang" select="$lang"/>
                                    </xsl:call-template>
                                </div>
                            </xsl:when>
                            <xsl:when test="$p_show_multiplicity_tags = 'true'"></xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="@maximumMultiplicity"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text> </xsl:text>
                        <xsl:choose>
                            <xsl:when test="$p_show_multiplicity_tags = 'true' and @isMandatory = 'true'">
                                <div class="ad-multiplicity-tag">
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'conformancemandatory'"/>
                                        <xsl:with-param name="lang" select="$lang"/>
                                    </xsl:call-template>
                                </div>
                            </xsl:when>
                            <xsl:when test="@isMandatory = 'true'">
                                <xsl:text>M</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:choose>
                            <xsl:when test="$p_show_multiplicity_tags = 'true' and @conformance = 'C'">
                                <div class="ad-multiplicity-tag">
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'conformanceConditional'"/>
                                        <xsl:with-param name="lang" select="$lang"/>
                                    </xsl:call-template>
                                </div>
                            </xsl:when>
                            <xsl:when test="$p_show_multiplicity_tags = 'true' and @conformance = 'R'">
                                <div class="ad-multiplicity-tag">
                                    <img src="wrench.png" alt="wrench" style="width:12px !important;"/>
                                </div>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="@conformance"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                    <xsl:if test="$p_show_item_numbers = 'true'">
                        <div style="border-bottom: 1px solid #ccc;">
                            <div style="float: right; font-size: 12px;" class="{concat('ad-dataset-itemnumber ', $statusColor)}">
                                <xsl:value-of select="tokenize(@id, '\.')[last()]"/>
                            </div>
                        </div>
                    </xsl:if>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:text>&#10;</xsl:text>
            <xsl:if test="contains">
                <xsl:text>(</xsl:text>
                <xsl:call-template name="getMessage">
                    <xsl:with-param name="key" select="'Referencing'"/>
                    <xsl:with-param name="lang" select="$lang"/>
                </xsl:call-template>
                <xsl:text>)</xsl:text>
            </xsl:if>
            <xsl:text>&#10;</xsl:text>
            <xsl:if test="$p_show_description = 'true' and string-length(desc[@language = $language])">
                <p>
                    <xsl:copy-of select="desc[@language = $language]/node()"/>
                </p>
                <xsl:text>&#10;</xsl:text>
            </xsl:if>
            <xsl:if test="$p_show_comment = 'true' and comment[@language = $language]">
                <p>
                    <span style="font-weight: 900;">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'Comment'"/>
                            <xsl:with-param name="lang" select="$lang"/>
                        </xsl:call-template>
                    </span>
                </p>
                <xsl:for-each select="comment[@language = $language]">
                    <p>
                        <xsl:copy-of select="node()"/>
                    </p>
                    <xsl:text>&#10;</xsl:text>
                </xsl:for-each>
                <xsl:text>&#10;</xsl:text>
            </xsl:if>
            <xsl:if test="$p_show_synonym = 'true'">
                <xsl:if test="synonym[@language = $language]">
                    <p>
                        <span style="font-weight: 900;">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'Synonyms'"/>
                                <xsl:with-param name="lang" select="$lang"/>
                            </xsl:call-template>
                            <xsl:text>: </xsl:text>
                        </span>
                        <ul>
                            <xsl:for-each select="synonym[@language = $language]">
                                <li>
                                    <xsl:copy-of select="text()"/>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </p>
                    <xsl:text>&#10;</xsl:text>
                </xsl:if>
            </xsl:if>
            <!-- 
                valueDomain, rationale, source, operationalization of this element, if any
             -->
            <xsl:if test="$p_show_valueDomain = 'true'">
                <xsl:for-each select="valueDomain">
                    <xsl:variable name="datatype" select="@type"/>
                    <xsl:variable name="doMinInclude" select="property[@minInclude[not(. = '')]]"/>
                    <xsl:variable name="doMaxInclude" select="property[@maxInclude[not(. = '')]]"/>
                    <xsl:variable name="doMinLength" select="property[@minLength[not(. = '')]]"/>
                    <xsl:variable name="doMaxLength" select="property[@maxLength[not(. = '')]]"/>
                    <xsl:variable name="doFractionDigits" select="property[@fractionDigits[not(. = '')]]"/>
                    <xsl:variable name="doUnit" select="property[@unit[not(. = '')]]"/>
                    <xsl:variable name="doDefault" select="property[@default[not(. = '')]]"/>
                    <xsl:variable name="doFixed" select="property[@fixed[not(. = '')]]"/>
                    <p>
                        <span style="font-weight: 900;">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'ValueDomain'"/>
                                <xsl:with-param name="lang" select="$lang"/>
                            </xsl:call-template>
                            <xsl:text>: </xsl:text>
                        </span>
                        <xsl:call-template name="getXFormsLabel">
                            <xsl:with-param name="simpleTypeKey" select="'DataSetValueType'"/>
                            <xsl:with-param name="simpleTypeValue" select="@type"/>
                            <xsl:with-param name="lang" select="$lang"/>
                        </xsl:call-template>
                    </p>
                    <xsl:text>&#10;</xsl:text>
                    <xsl:if test="$p_show_property = 'true'">
                        <xsl:if test="property[@*[string-length() gt 0]]">
                            <p>
                                <b>
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'Property'"/>
                                        <xsl:with-param name="lang" select="$lang"/>
                                    </xsl:call-template>
                                    <xsl:text>: </xsl:text>
                                </b>
                            </p>
                            <xsl:text>&#10;</xsl:text>
                            <!-- select per type -->
                            <xsl:choose>
                                <xsl:when test="$datatype = 'count'">
                                    <table class="artdecor zebra-table" border="0" cellspacing="1" cellpadding="2" style="background: transparent; border: 1px solid #C0C0C0;">
                                        <tr>
                                            <xsl:if test="$doMinInclude">
                                                <th class="leftrightpadding">
                                                    <xsl:call-template name="getMessage">
                                                        <xsl:with-param name="key" select="'minInclude'"/>
                                                        <xsl:with-param name="lang" select="$lang"/>
                                                    </xsl:call-template>
                                                </th>
                                            </xsl:if>
                                            <xsl:if test="$doMaxInclude">
                                                <th class="leftrightpadding">
                                                    <xsl:call-template name="getMessage">
                                                        <xsl:with-param name="key" select="'maxInclude'"/>
                                                        <xsl:with-param name="lang" select="$lang"/>
                                                    </xsl:call-template>
                                                </th>
                                            </xsl:if>
                                            <xsl:if test="$doDefault">
                                                <th class="leftrightpadding">
                                                    <xsl:call-template name="getMessage">
                                                        <xsl:with-param name="key" select="'default'"/>
                                                        <xsl:with-param name="lang" select="$lang"/>
                                                    </xsl:call-template>
                                                </th>
                                            </xsl:if>
                                            <xsl:if test="$doFixed">
                                                <th class="leftrightpadding">
                                                    <xsl:call-template name="getMessage">
                                                        <xsl:with-param name="key" select="'fixed'"/>
                                                        <xsl:with-param name="lang" select="$lang"/>
                                                    </xsl:call-template>
                                                </th>
                                            </xsl:if>
                                            <xsl:for-each select="distinct-values(property/(@*[not(. = '')] except (@minInclude | @maxInclude | @default | @fixed))/name())">
                                                <th class="leftrightpadding">
                                                    <xsl:attribute name="title">
                                                        <xsl:call-template name="getMessage">
                                                            <xsl:with-param name="key" select="'unexpectedPropertyForDatatype'"/>
                                                            <xsl:with-param name="lang" select="$lang"/>
                                                        </xsl:call-template>
                                                    </xsl:attribute>
                                                    <i>
                                                        <xsl:call-template name="getMessage">
                                                            <xsl:with-param name="key" select="
                                                                    if (. = 'timeStampPrecision') then
                                                                        'TimestampPrecision'
                                                                    else
                                                                        (.)"/>
                                                            <xsl:with-param name="lang" select="$lang"/>
                                                        </xsl:call-template>
                                                    </i>
                                                </th>
                                            </xsl:for-each>
                                        </tr>
                                        <xsl:for-each select="property[@*[string-length() gt 0]]">
                                            <tr>
                                                <xsl:if test="$doMinInclude">
                                                    <td style="text-align: right;">
                                                        <xsl:value-of select="@minInclude"/>
                                                    </td>
                                                </xsl:if>
                                                <xsl:if test="$doMaxInclude">
                                                    <td style="text-align: right;">
                                                        <xsl:value-of select="@maxInclude"/>
                                                    </td>
                                                </xsl:if>
                                                <xsl:if test="$doDefault">
                                                    <td style="text-align: right;">
                                                        <xsl:value-of select="@default"/>
                                                    </td>
                                                </xsl:if>
                                                <xsl:if test="$doFixed">
                                                    <td style="text-align: right;">
                                                        <xsl:value-of select="@fixed"/>
                                                    </td>
                                                </xsl:if>
                                                <xsl:for-each select="@*[not(. = '')] except (@minInclude | @maxInclude | @default | @fixed)">
                                                    <td class="leftrightpadding">
                                                        <xsl:value-of select="."/>
                                                    </td>
                                                </xsl:for-each>
                                            </tr>
                                        </xsl:for-each>
                                    </table>
                                </xsl:when>
                                <xsl:when test="$datatype = 'text' or $datatype = 'string'">
                                    <table class="artdecor zebra-table" border="0" cellspacing="1" cellpadding="2" style="background: transparent; border: 1px solid #C0C0C0;">
                                        <tr>
                                            <xsl:if test="$doMinLength">
                                                <th class="leftrightpadding">
                                                    <xsl:call-template name="getMessage">
                                                        <xsl:with-param name="key" select="'minLength'"/>
                                                        <xsl:with-param name="lang" select="$lang"/>
                                                    </xsl:call-template>
                                                </th>
                                            </xsl:if>
                                            <xsl:if test="$doMaxLength">
                                                <th class="leftrightpadding">
                                                    <xsl:call-template name="getMessage">
                                                        <xsl:with-param name="key" select="'maxLength'"/>
                                                        <xsl:with-param name="lang" select="$lang"/>
                                                    </xsl:call-template>
                                                </th>
                                            </xsl:if>
                                            <xsl:if test="$doDefault">
                                                <th class="leftrightpadding">
                                                    <xsl:call-template name="getMessage">
                                                        <xsl:with-param name="key" select="'default'"/>
                                                        <xsl:with-param name="lang" select="$lang"/>
                                                    </xsl:call-template>
                                                </th>
                                            </xsl:if>
                                            <xsl:if test="$doFixed">
                                                <th class="leftrightpadding">
                                                    <xsl:call-template name="getMessage">
                                                        <xsl:with-param name="key" select="'fixed'"/>
                                                        <xsl:with-param name="lang" select="$lang"/>
                                                    </xsl:call-template>
                                                </th>
                                            </xsl:if>
                                            <xsl:for-each select="distinct-values(property/(@*[not(. = '')] except (@minLength | @maxLength | @default | @fixed))/name())">
                                                <th class="leftrightpadding">
                                                    <xsl:attribute name="title">
                                                        <xsl:call-template name="getMessage">
                                                            <xsl:with-param name="key" select="'unexpectedPropertyForDatatype'"/>
                                                            <xsl:with-param name="lang" select="$lang"/>
                                                        </xsl:call-template>
                                                    </xsl:attribute>
                                                    <i>
                                                        <xsl:call-template name="getMessage">
                                                            <xsl:with-param name="key" select="
                                                                    if (. = 'timeStampPrecision') then
                                                                        'TimestampPrecision'
                                                                    else
                                                                        (.)"/>
                                                            <xsl:with-param name="lang" select="$lang"/>
                                                        </xsl:call-template>
                                                    </i>
                                                </th>
                                            </xsl:for-each>
                                        </tr>
                                        <xsl:for-each select="property[@*[string-length() gt 0]]">
                                            <tr>
                                                <xsl:if test="$doMinLength">
                                                    <td style="text-align: right;">
                                                        <xsl:value-of select="@minLength"/>
                                                    </td>
                                                </xsl:if>
                                                <xsl:if test="$doMaxLength">
                                                    <td style="text-align: right;">
                                                        <xsl:value-of select="@maxLength"/>
                                                    </td>
                                                </xsl:if>
                                                <xsl:if test="$doDefault">
                                                    <td style="text-align: right;">
                                                        <xsl:value-of select="@default"/>
                                                    </td>
                                                </xsl:if>
                                                <xsl:if test="$doFixed">
                                                    <td style="text-align: right;">
                                                        <xsl:value-of select="@fixed"/>
                                                    </td>
                                                </xsl:if>
                                                <xsl:for-each select="@*[not(. = '')] except (@minLength | @maxLength | @default | @fixed)">
                                                    <td class="leftrightpadding">
                                                        <xsl:value-of select="."/>
                                                    </td>
                                                </xsl:for-each>
                                            </tr>
                                        </xsl:for-each>
                                    </table>
                                </xsl:when>
                                <xsl:when test="$datatype = 'date' or $datatype = 'datetime'">
                                    <!-- timeStampPrecision -->
                                    <table class="artdecor zebra-table" border="0" cellspacing="1" cellpadding="2" style="background: transparent; border: 1px solid #C0C0C0;">
                                        <tr>
                                            <th class="leftrightpadding">
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'TimestampPrecision'"/>
                                                    <xsl:with-param name="lang" select="$lang"/>
                                                </xsl:call-template>
                                            </th>
                                            <xsl:for-each select="distinct-values(property/(@*[not(. = '')] except (@timeStampPrecision))/name())">
                                                <th class="leftrightpadding">
                                                    <xsl:attribute name="title">
                                                        <xsl:call-template name="getMessage">
                                                            <xsl:with-param name="key" select="'unexpectedPropertyForDatatype'"/>
                                                            <xsl:with-param name="lang" select="$lang"/>
                                                        </xsl:call-template>
                                                    </xsl:attribute>
                                                    <i>
                                                        <xsl:call-template name="getMessage">
                                                            <xsl:with-param name="key" select="
                                                                    if (. = 'timeStampPrecision') then
                                                                        'TimestampPrecision'
                                                                    else
                                                                        (.)"/>
                                                            <xsl:with-param name="lang" select="$lang"/>
                                                        </xsl:call-template>
                                                    </i>
                                                </th>
                                            </xsl:for-each>
                                        </tr>
                                        <xsl:for-each select="property[@*[string-length() gt 0]]">
                                            <tr>
                                                <td style="text-align: left;">
                                                    <xsl:if test="@timeStampPrecision[not(. = '')]">
                                                        <xsl:call-template name="getMessage">
                                                            <xsl:with-param name="key" select="concat('timeStampPrecision-', @timeStampPrecision)"/>
                                                            <xsl:with-param name="lang" select="$lang"/>
                                                        </xsl:call-template>
                                                    </xsl:if>
                                                </td>
                                                <xsl:for-each select="@*[not(. = '')] except (@timeStampPrecision)">
                                                    <td class="leftrightpadding">
                                                        <xsl:value-of select="."/>
                                                    </td>
                                                </xsl:for-each>
                                            </tr>
                                        </xsl:for-each>
                                    </table>
                                </xsl:when>
                                <xsl:when test="$datatype = 'quantity' or $datatype = 'duration'">
                                    <!-- rangeFrom, rangeTo, unit(s), fractionDigits -->
                                    <table class="artdecor zebra-table" border="0" cellspacing="1" cellpadding="2" style="background: transparent; border: 1px solid #C0C0C0;">
                                        <tr>
                                            <xsl:if test="$doMinInclude">
                                                <th class="leftrightpadding">
                                                    <xsl:call-template name="getMessage">
                                                        <xsl:with-param name="key" select="'minInclude'"/>
                                                        <xsl:with-param name="lang" select="$lang"/>
                                                    </xsl:call-template>
                                                </th>
                                            </xsl:if>
                                            <xsl:if test="$doMaxInclude">
                                                <th class="leftrightpadding">
                                                    <xsl:call-template name="getMessage">
                                                        <xsl:with-param name="key" select="'maxInclude'"/>
                                                        <xsl:with-param name="lang" select="$lang"/>
                                                    </xsl:call-template>
                                                </th>
                                            </xsl:if>
                                            <xsl:if test="$doUnit">
                                                <th class="leftrightpadding">
                                                    <xsl:call-template name="getMessage">
                                                        <xsl:with-param name="key" select="'unit'"/>
                                                        <xsl:with-param name="lang" select="$lang"/>
                                                    </xsl:call-template>
                                                </th>
                                            </xsl:if>
                                            <xsl:if test="$doFractionDigits">
                                                <th class="leftrightpadding">
                                                    <xsl:call-template name="getMessage">
                                                        <xsl:with-param name="key" select="'fractionDigits'"/>
                                                        <xsl:with-param name="lang" select="$lang"/>
                                                    </xsl:call-template>
                                                </th>
                                            </xsl:if>
                                            <xsl:if test="$doDefault">
                                                <th class="leftrightpadding">
                                                    <xsl:call-template name="getMessage">
                                                        <xsl:with-param name="key" select="'default'"/>
                                                        <xsl:with-param name="lang" select="$lang"/>
                                                    </xsl:call-template>
                                                </th>
                                            </xsl:if>
                                            <xsl:if test="$doFixed">
                                                <th class="leftrightpadding">
                                                    <xsl:call-template name="getMessage">
                                                        <xsl:with-param name="key" select="'fixed'"/>
                                                        <xsl:with-param name="lang" select="$lang"/>
                                                    </xsl:call-template>
                                                </th>
                                            </xsl:if>
                                            <xsl:for-each select="distinct-values(property/(@*[not(. = '')] except (@minInclude | @maxInclude | @unit | @fractionDigits | @default | @fixed))/name())">
                                                <th class="leftrightpadding">
                                                    <xsl:attribute name="title">
                                                        <xsl:call-template name="getMessage">
                                                            <xsl:with-param name="key" select="'unexpectedPropertyForDatatype'"/>
                                                            <xsl:with-param name="lang" select="$lang"/>
                                                        </xsl:call-template>
                                                    </xsl:attribute>
                                                    <i>
                                                        <xsl:call-template name="getMessage">
                                                            <xsl:with-param name="key" select="
                                                                    if (. = 'timeStampPrecision') then
                                                                        'TimestampPrecision'
                                                                    else
                                                                        (.)"/>
                                                            <xsl:with-param name="lang" select="$lang"/>
                                                        </xsl:call-template>
                                                    </i>
                                                </th>
                                            </xsl:for-each>
                                        </tr>
                                        <xsl:for-each select="property[@*[string-length() gt 0]]">
                                            <tr>
                                                <xsl:if test="$doMinInclude">
                                                    <td style="text-align: right;">
                                                        <xsl:value-of select="@minInclude"/>
                                                    </td>
                                                </xsl:if>
                                                <xsl:if test="$doMaxInclude">
                                                    <td style="text-align: right;">
                                                        <xsl:value-of select="@maxInclude"/>
                                                    </td>
                                                </xsl:if>
                                                <xsl:if test="$doUnit">
                                                    <td style="text-align: right;">
                                                        <xsl:value-of select="@unit"/>
                                                    </td>
                                                </xsl:if>
                                                <xsl:if test="$doFractionDigits">
                                                    <td style="text-align: right;">
                                                        <xsl:choose>
                                                            <xsl:when test="string-length(@fractionDigits) = 0">&#160;</xsl:when>
                                                            <xsl:when test="matches(string(@fractionDigits), '!$')">
                                                                <!-- exact fraction digits -->
                                                                <xsl:value-of select="substring-before(@fractionDigits, '!')"/>
                                                            </xsl:when>
                                                            <xsl:when test="matches(string(@fractionDigits), '\.$')">
                                                                <!-- max fraction digits -->
                                                                <xsl:text>&lt;= </xsl:text>
                                                                <xsl:value-of select="substring-before(@fractionDigits, '.')"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <!-- min fraction digits -->
                                                                <xsl:text>&gt;= </xsl:text>
                                                                <xsl:value-of select="@fractionDigits"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </td>
                                                </xsl:if>
                                                <xsl:if test="$doDefault">
                                                    <td style="text-align: right;">
                                                        <xsl:value-of select="@default"/>
                                                    </td>
                                                </xsl:if>
                                                <xsl:if test="$doFixed">
                                                    <td style="text-align: right;">
                                                        <xsl:value-of select="@fixed"/>
                                                    </td>
                                                </xsl:if>
                                                <xsl:for-each select="@*[not(. = '')] except (@minInclude | @maxInclude | @unit | @fractionDigits | @default | @fixed)">
                                                    <td class="leftrightpadding">
                                                        <xsl:value-of select="."/>
                                                    </td>
                                                </xsl:for-each>
                                            </tr>
                                        </xsl:for-each>
                                    </table>
                                </xsl:when>
                                <xsl:when test="$datatype = 'identifier'">
                                    <table class="artdecor zebra-table" border="0" cellspacing="1" cellpadding="2" style="background: transparent; border: 1px solid #C0C0C0;">
                                        <tr>
                                            <xsl:if test="$doMinLength">
                                                <th class="leftrightpadding">
                                                    <xsl:call-template name="getMessage">
                                                        <xsl:with-param name="key" select="'minLength'"/>
                                                        <xsl:with-param name="lang" select="$lang"/>
                                                    </xsl:call-template>
                                                </th>
                                            </xsl:if>
                                            <xsl:if test="$doMaxLength">
                                                <th class="leftrightpadding">
                                                    <xsl:call-template name="getMessage">
                                                        <xsl:with-param name="key" select="'maxLength'"/>
                                                        <xsl:with-param name="lang" select="$lang"/>
                                                    </xsl:call-template>
                                                </th>
                                            </xsl:if>
                                            <xsl:for-each select="distinct-values(property/(@*[not(. = '')] except (@minLength | @maxLength))/name())">
                                                <th class="leftrightpadding">
                                                    <xsl:attribute name="title">
                                                        <xsl:call-template name="getMessage">
                                                            <xsl:with-param name="key" select="'unexpectedPropertyForDatatype'"/>
                                                            <xsl:with-param name="lang" select="$lang"/>
                                                        </xsl:call-template>
                                                    </xsl:attribute>
                                                    <i>
                                                        <xsl:call-template name="getMessage">
                                                            <xsl:with-param name="key" select="
                                                                    if (. = 'timeStampPrecision') then
                                                                        'TimestampPrecision'
                                                                    else
                                                                        (.)"/>
                                                            <xsl:with-param name="lang" select="$lang"/>
                                                        </xsl:call-template>
                                                    </i>
                                                </th>
                                            </xsl:for-each>
                                        </tr>
                                        <xsl:for-each select="property[@*[string-length() gt 0]]">
                                            <tr>
                                                <xsl:if test="$doMinLength">
                                                    <td style="text-align: right;">
                                                        <xsl:value-of select="@minLength"/>
                                                    </td>
                                                </xsl:if>
                                                <xsl:if test="$doMaxLength">
                                                    <td style="text-align: right;">
                                                        <xsl:value-of select="@maxLength"/>
                                                    </td>
                                                </xsl:if>
                                                <xsl:for-each select="@*[not(. = '')] except (@minLength | @maxLength)">
                                                    <td class="leftrightpadding">
                                                        <xsl:value-of select="."/>
                                                    </td>
                                                </xsl:for-each>
                                            </tr>
                                        </xsl:for-each>
                                    </table>
                                </xsl:when>
                                <xsl:when test="$datatype = 'blob'">
                                    <table class="artdecor zebra-table" border="0" cellspacing="1" cellpadding="2" style="background: transparent; border: 1px solid #C0C0C0;">
                                        <tr>
                                            <xsl:if test="$doMinLength">
                                                <th class="leftrightpadding">
                                                    <xsl:call-template name="getMessage">
                                                        <xsl:with-param name="key" select="'minLength'"/>
                                                        <xsl:with-param name="lang" select="$lang"/>
                                                    </xsl:call-template>
                                                </th>
                                            </xsl:if>
                                            <xsl:if test="$doMaxLength">
                                                <th class="leftrightpadding">
                                                    <xsl:call-template name="getMessage">
                                                        <xsl:with-param name="key" select="'maxLength'"/>
                                                        <xsl:with-param name="lang" select="$lang"/>
                                                    </xsl:call-template>
                                                </th>
                                            </xsl:if>
                                            <xsl:for-each select="@*[not(. = '')] except (@minLength | @maxLength)">
                                                <th class="leftrightpadding">
                                                    <xsl:attribute name="title">
                                                        <xsl:call-template name="getMessage">
                                                            <xsl:with-param name="key" select="'unexpectedPropertyForDatatype'"/>
                                                            <xsl:with-param name="lang" select="$lang"/>
                                                        </xsl:call-template>
                                                    </xsl:attribute>
                                                    <i>
                                                        <xsl:call-template name="getMessage">
                                                            <xsl:with-param name="key" select="
                                                                    if (. = 'timeStampPrecision') then
                                                                        'TimestampPrecision'
                                                                    else
                                                                        (.)"/>
                                                            <xsl:with-param name="lang" select="$lang"/>
                                                        </xsl:call-template>
                                                    </i>
                                                </th>
                                            </xsl:for-each>
                                        </tr>
                                        <tr>
                                            <xsl:if test="$doMinLength">
                                                <td style="text-align: right;">
                                                    <xsl:value-of select="@minLength"/>
                                                </td>
                                            </xsl:if>
                                            <xsl:if test="$doMaxLength">
                                                <td style="text-align: right;">
                                                    <xsl:value-of select="@maxLength"/>
                                                </td>
                                            </xsl:if>
                                            <xsl:for-each select="@*[not(. = '')] except (@minLength | @maxLength)">
                                                <td>
                                                    <xsl:value-of select="."/>
                                                </td>
                                            </xsl:for-each>
                                        </tr>
                                    </table>
                                </xsl:when>
                                <xsl:otherwise>
                                    <table class="artdecor zebra-table" width="100%" border="0" cellspacing="1" cellpadding="2" style="background: transparent; border: 1px solid #C0C0C0;">
                                        <tr>
                                            <xsl:for-each select="distinct-values(property/(@*[not(. = '')])/name())">
                                                <th class="leftrightpadding">
                                                    <xsl:attribute name="title">
                                                        <xsl:call-template name="getMessage">
                                                            <xsl:with-param name="key" select="'unexpectedPropertyForDatatype'"/>
                                                            <xsl:with-param name="lang" select="$lang"/>
                                                        </xsl:call-template>
                                                    </xsl:attribute>
                                                    <i>
                                                        <xsl:call-template name="getMessage">
                                                            <xsl:with-param name="key" select="
                                                                    if (. = 'timeStampPrecision') then
                                                                        'TimestampPrecision'
                                                                    else
                                                                        (.)"/>
                                                            <xsl:with-param name="lang" select="$lang"/>
                                                        </xsl:call-template>
                                                    </i>
                                                </th>
                                            </xsl:for-each>
                                        </tr>
                                        <xsl:for-each select="property[@*[string-length() gt 0]]">
                                            <tr>
                                                <xsl:for-each select="@*[not(. = '')]">
                                                    <td>
                                                        <xsl:value-of select="."/>
                                                    </td>
                                                </xsl:for-each>
                                            </tr>
                                        </xsl:for-each>
                                    </table>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="$p_show_example = 'true' and example[string-length() gt 0]">
                        <p>
                            <span style="font-weight: 900;">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'Example'"/>
                                    <xsl:with-param name="lang" select="$lang"/>
                                </xsl:call-template>
                                <xsl:text>: </xsl:text>
                            </span>
                        </p>
                        <table class="artdecor zebra-table" width="100%" border="0" cellspacing="1" cellpadding="2" style="background: transparent; border: 1px solid #C0C0C0;">
                            <xsl:for-each select="example">
                                <!-- 
                                show example pretty printed
                                if parent is template then different td's are used compared to in-element examples
                            -->
                                <xsl:variable name="expclass">
                                    <xsl:choose>
                                        <xsl:when test="@type = 'valid'">
                                            <!-- a valid example, render it green -->
                                            <xsl:text>explabelgreen</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="@type = 'error'">
                                            <!-- an invalid example, render it red -->
                                            <xsl:text>explabelred</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <!-- normal rendering otherwise -->
                                            <xsl:text>explabelblue</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <xsl:if test=".[@caption]">
                                    <tr>
                                        <th colspan="2">
                                            <div class="expcaption">
                                                <xsl:value-of select="@caption"/>
                                            </div>
                                        </th>
                                    </tr>
                                </xsl:if>
                                <tr>
                                    <td style="width: 2px;" class="{$expclass} !important"> </td>
                                    <td>
                                        <xsl:copy-of select="node()"/>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </table>
                    </xsl:if>
                    <p/>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="$p_show_rationale = 'true' and rationale[string-length(normalize-space()) gt 0]">
                <xsl:for-each select="rationale[@language = $language]">
                    <p>
                        <span style="font-weight: 900;">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'Rationale'"/>
                                <xsl:with-param name="lang" select="$lang"/>
                            </xsl:call-template>
                            <xsl:text>: </xsl:text>
                        </span>
                        <xsl:copy-of select="node()"/>
                    </p>
                    <xsl:text>&#10;</xsl:text>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="$p_show_source = 'true' and source[string-length(normalize-space()) gt 0]">
                <xsl:for-each select="source[@language = $language]">
                    <p>
                        <b>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'Source'"/>
                                <xsl:with-param name="lang" select="$lang"/>
                            </xsl:call-template>
                            <xsl:text>: </xsl:text>
                        </b>
                        <xsl:copy-of select="node()"/>
                    </p>
                    <xsl:text>&#10;</xsl:text>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="$p_show_operationalization = 'true'">
                <xsl:for-each select="operationalization[@language = $language]">
                    <p>
                        <span style="font-weight: 900;">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'Operationalization'"/>
                                <xsl:with-param name="lang" select="$lang"/>
                            </xsl:call-template>
                            <xsl:text>: </xsl:text>
                        </span>
                        <xsl:copy-of select="node()"/>
                    </p>
                    <xsl:text>&#10;</xsl:text>
                </xsl:for-each>
            </xsl:if>
            <!-- 
                show all terminology associations in a table if valueDomain is code and there are any terminology associations 
            -->
            <xsl:if test="$p_show_relationships = 'true' and relationship">
                <p>
                    <span style="font-weight: 900;">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'Relationship'"/>
                            <xsl:with-param name="lang" select="$lang"/>
                        </xsl:call-template>
                        <xsl:text>: </xsl:text>
                    </span>
                </p>
                <ul>
                    <xsl:for-each select="relationship">
                        <xsl:variable name="ref" select="@ref"/>
                        <xsl:variable name="flex" select="@flexibility"/>
                        <li>
                            <xsl:call-template name="getXFormsLabel">
                                <xsl:with-param name="simpleTypeKey" select="'RelationshipTypes'"/>
                                <xsl:with-param name="simpleTypeValue" select="@type"/>
                                <xsl:with-param name="lang" select="$lang"/>
                            </xsl:call-template>
                            <xsl:text>: </xsl:text>
                            <xsl:value-of select="name[@language = $language]"/>
                            <xsl:text> – </xsl:text>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'dataElement'"/>
                                <xsl:with-param name="lang" select="$lang"/>
                            </xsl:call-template>
                            <xsl:text> </xsl:text>
                            <xsl:variable name="dstext" as="xs:string*">
                                <xsl:call-template name="doShorthandId">
                                    <xsl:with-param name="id" select="$ref"/>
                                </xsl:call-template>
                                <xsl:text> - </xsl:text>
                                <xsl:choose>
                                    <xsl:when test="matches(@flexibility, '^\d{4}')">
                                        <xsl:call-template name="showDate">
                                            <xsl:with-param name="date" select="$flex"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="'associationDYNAMIC'"/>
                                            <xsl:with-param name="lang" select="$lang"/>
                                        </xsl:call-template>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:value-of select="string-join($dstext, '')"/>
                        </li>
                        <xsl:text>&#10;</xsl:text>
                    </xsl:for-each>
                </ul>
            </xsl:if>

            <xsl:variable name="cidta" select="$ocid | inherit/@ref"/>
            <xsl:if test="$p_show_terminologyassociations = 'true' and count(terminologyAssociation[@conceptId = ($cidta)][@code]) > 0">
                <!-- semantic annotations of concept -->
                <p>
                    <span style="font-weight: 900;">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'terminologyAssociations'"/>
                            <xsl:with-param name="lang" select="$lang"/>
                        </xsl:call-template>
                    </span>
                </p>
                <table class="artdecor zebra-table" width="100%" border="0" cellspacing="1" cellpadding="2" style="background: transparent; border: 1px solid #C0C0C0;">
                    <xsl:if test="terminologyAssociation[@conceptId = ($cidta)][@code]">
                        <xsl:variable name="bgcolor">
                            <!-- do the zebra -->
                            <xsl:choose>
                                <xsl:when test="position() mod 2">transparent</xsl:when>
                                <xsl:otherwise>#f7f7f7;</xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <th style="text-align: left;">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'Code'"/>
                                <xsl:with-param name="lang" select="$lang"/>
                            </xsl:call-template>
                        </th>
                        <th style="text-align: left;">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'DisplayName'"/>
                                <xsl:with-param name="lang" select="$lang"/>
                            </xsl:call-template>
                        </th>
                        <th style="text-align: left;">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'CodeSystem'"/>
                                <xsl:with-param name="lang" select="$lang"/>
                            </xsl:call-template>
                        </th>
                        <xsl:for-each-group select="terminologyAssociation[@conceptId = ($cidta)][@code]" group-by="concat(@code, @codeSystem)">
                            <tr style="background: {$bgcolor};">
                                <td>
                                    <xsl:value-of select="@code"/>
                                </td>
                                <td>
                                    <xsl:value-of select="@displayName"/>
                                </td>
                                <td>
                                    <xsl:choose>
                                        <xsl:when test="string-length(@codeSystemName) = 0">
                                            <xsl:value-of select="@codeSystem"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="@codeSystemName"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </td>
                            </tr>
                        </xsl:for-each-group>
                    </xsl:if>
                </table>
            </xsl:if>

            <xsl:if test="$p_show_valueDomain = 'true' and valueDomain/conceptList">
                <xsl:variable name="tas">
                    <xsl:if test="$p_show_terminologyassociations = 'true'">
                        <xsl:copy-of select="terminologyAssociation"/>
                    </xsl:if>
                </xsl:variable>
                <xsl:variable name="vas">
                    <xsl:copy-of select="valueSet[@id]"/>
                </xsl:variable>
                <xsl:variable name="noofdescs">
                    <xsl:copy-of select="count(valueDomain/conceptList/concept/desc[@language = $language])"/>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="count(valueDomain/conceptList/concept) > 0">
                        <p>
                            <b>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'ConceptList'"/>
                                    <xsl:with-param name="lang" select="$lang"/>
                                </xsl:call-template>
                            </b>
                        </p>
                        <xsl:for-each select="valueDomain[@type = 'code']">
                            <xsl:variable name="clid" select="conceptList/@id"/>
                            <xsl:if test="$p_show_terminologyassociations = 'true' and count($tas/terminologyAssociation[@conceptId = $clid][@valueSet]) > 0">
                                <table class="artdecor zebra-table" width="100%" border="0" cellspacing="1" cellpadding="2" style="background: transparent; border: 1px solid #C0C0C0;">
                                    <xsl:variable name="bgcolor">
                                        <!-- do the zebra -->
                                        <xsl:choose>
                                            <xsl:when test="position() mod 2">transparent</xsl:when>
                                            <xsl:otherwise>#f7f7f7;</xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>
                                    <th style="text-align: left;">
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="'valueSet'"/>
                                            <xsl:with-param name="lang" select="$lang"/>
                                        </xsl:call-template>
                                    </th>
                                    <th style="text-align: left;">
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="'Id'"/>
                                            <xsl:with-param name="lang" select="$lang"/>
                                        </xsl:call-template>
                                    </th>
                                    <th style="text-align: left;">
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="'effectiveDate'"/>
                                            <xsl:with-param name="lang" select="$lang"/>
                                        </xsl:call-template>
                                    </th>
                                    <xsl:for-each select="$tas/terminologyAssociation[@conceptId = $clid][@valueSet]">
                                        <xsl:variable name="tavsid" select="@valueSet"/>
                                        <tr style="background: {$bgcolor};">
                                            <td>
                                                <xsl:value-of select="($vas/valueSet[@id = $tavsid])[1]/(@displayName, @name)[1]"/>
                                            </td>
                                            <td>
                                                <xsl:value-of select="$tavsid"/>
                                            </td>
                                            <td>
                                                <xsl:call-template name="showDate">
                                                    <xsl:with-param name="date" select="@flexibility"/>
                                                </xsl:call-template>
                                            </td>
                                        </tr>
                                    </xsl:for-each>
                                </table>
                                <p/>
                            </xsl:if>
                            
                            <table class="artdecor zebra-table" width="100%" border="0" cellspacing="1" cellpadding="2" style="background: transparent; border: 1px solid #C0C0C0;">
                                <!-- head of table -->
                                <tr>
                                    <th style="text-align: left;">
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="'Concept'"/>
                                            <xsl:with-param name="lang" select="$lang"/>
                                        </xsl:call-template>
                                    </th>
                                    <xsl:if test="$noofdescs > 0">
                                        <th>
                                            <xsl:call-template name="getMessage">
                                                <xsl:with-param name="key" select="'Description'"/>
                                                <xsl:with-param name="lang" select="$lang"/>
                                            </xsl:call-template>
                                        </th>
                                    </xsl:if>
                                    <xsl:choose>
                                        <xsl:when test="count($tas/terminologyAssociation) > 0 and $p_show_terminologyassociations = 'true'">
                                            <th style="text-align: left;">
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'Code'"/>
                                                    <xsl:with-param name="lang" select="$lang"/>
                                                </xsl:call-template>
                                            </th>
                                            <th style="text-align: left;">
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'DisplayName'"/>
                                                    <xsl:with-param name="lang" select="$lang"/>
                                                </xsl:call-template>
                                            </th>
                                            <th style="text-align: left;">
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'CodeSystem'"/>
                                                    <xsl:with-param name="lang" select="$lang"/>
                                                </xsl:call-template>
                                            </th>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <th> </th>
                                            <th> </th>
                                            <th> </th>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </tr>
                                <!-- terminology associations -->
                                <xsl:for-each select="conceptList/concept">
                                    <xsl:variable name="cid" select="@id"/>
                                    <xsl:variable name="bgcolor">
                                        <!-- do the zebra -->
                                        <xsl:choose>
                                            <xsl:when test="position() mod 2">transparent</xsl:when>
                                            <xsl:otherwise>#f7f7f7;</xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>
                                    <xsl:variable name="rowspans">
                                        <xsl:choose>
                                            <xsl:when test="count($tas/terminologyAssociation[@conceptId = $cid]) > 1">
                                                <xsl:value-of select="count($tas/terminologyAssociation[@conceptId = $cid])"/>
                                            </xsl:when>
                                            <xsl:otherwise>1</xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>
                                    <xsl:variable name="firstcol">
                                        <xsl:choose>
                                            <xsl:when test="$rowspans = 1">
                                                <!-- only one terminology associations, normal table -->
                                                <td style="vertical-align: top;">
                                                    <xsl:value-of select="name[@language = $language]"/>
                                                </td>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <!-- more than one terminology associations and this is the first, normal table -->
                                                <td style="vertical-align: top;" rowspan="{$rowspans}">
                                                    <xsl:value-of select="name[@language = $language]"/>
                                                </td>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>
                                    <xsl:variable name="thisdesc">
                                        <xsl:copy-of select="desc[@language = $language]/node()"/>
                                    </xsl:variable>
                                    <!-- the concept first, maxbe with rowspans -->
                                    <!-- them all terminology associations in columns and rows behind it -->
                                    <xsl:choose>
                                        <xsl:when test="count($tas/terminologyAssociation[@conceptId = $cid]) > 0 and $p_show_terminologyassociations = 'true'">
                                            <xsl:for-each select="$tas/terminologyAssociation[@conceptId = $cid]">
                                                <tr style="background: {$bgcolor};">
                                                    <xsl:if test="position() = 1">
                                                        <xsl:copy-of select="$firstcol"/>
                                                        <xsl:if test="$noofdescs > 0">
                                                            <td>
                                                                <xsl:copy-of select="$thisdesc"/>
                                                            </td>
                                                        </xsl:if>
                                                    </xsl:if>
                                                    <xsl:if test="$noofdescs > 0 and position() > 1">
                                                        <td> </td>
                                                    </xsl:if>
                                                    <td>
                                                        <xsl:value-of select="@code"/>
                                                    </td>
                                                    <td>
                                                        <xsl:value-of select="@displayName"/>
                                                    </td>
                                                    <td>
                                                        <xsl:choose>
                                                            <xsl:when test="string-length(@codeSystemName) = 0">
                                                                <xsl:value-of select="@codeSystem"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:value-of select="@codeSystemName"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                        
                                                    </td>
                                                </tr>
                                            </xsl:for-each>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <tr>
                                                <td style="vertical-align: top;">
                                                    <xsl:value-of select="name[@language = $language]"/>
                                                </td>
                                                <xsl:if test="$noofdescs > 0">
                                                    <td>
                                                        <xsl:copy-of select="$thisdesc"/>
                                                    </td>
                                                </xsl:if>
                                                <td> </td>
                                                <td> </td>
                                                <td> </td>
                                            </tr>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:for-each>
                            </table>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <p>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'noConceptListYet'"/>
                                <xsl:with-param name="lang" select="$lang"/>
                            </xsl:call-template>
                        </p>
                    </xsl:otherwise>
                </xsl:choose>
                
            </xsl:if>
            <!-- 
            now run through all child concepts
            for an item show it's properties, heading one level up
            for a group item just show the name of the group and a link to the respective page
        -->
            <xsl:apply-templates select="concept[not(@statusCode = $p_bluestatusset)]" mode="elementtransfer2">
                <xsl:with-param name="type" select="@type"/>
                <xsl:with-param name="hlevel" select="$hlevel + 1"/>
            </xsl:apply-templates>

        </div>

    </xsl:template>

    <xsl:template name="modernDot">
        <xsl:param name="status"/>
        <xsl:variable name="class">
            <xsl:choose>
                <xsl:when test="$status = ('active', 'final')">
                    <xsl:text>dot active</xsl:text>
                </xsl:when>
                <xsl:when test="$status = 'draft'">
                    <xsl:text>dot draft</xsl:text>
                </xsl:when>
                <xsl:when test="$status = 'pending'">
                    <xsl:text>dot pending</xsl:text>
                </xsl:when>
                <xsl:when test="$status = 'pending'">
                    <xsl:text>dot pending</xsl:text>
                </xsl:when>
                <xsl:when test="$status = 'retired'">
                    <xsl:text>dot retired</xsl:text>
                </xsl:when>
                <xsl:when test="$status = ('rejected', 'cancelled')">
                    <xsl:text>dot cancelled</xsl:text>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <span>
            <span class="{$class}">
                <span style="padding: 20px;">
                    <xsl:call-template name="getXFormsLabel">
                        <xsl:with-param name="simpleTypeKey" select="'ItemStatusCodeLifeCycle'"/>
                        <xsl:with-param name="simpleTypeValue" select="$status"/>
                        <xsl:with-param name="lang" select="$lang"/>
                    </xsl:call-template>
                </span>
            </span>
        </span>
    </xsl:template>


</xsl:stylesheet>
