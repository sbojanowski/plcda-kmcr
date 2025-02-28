<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">

	<xsl:output method="xml" indent="yes"/>

	<xsl:template name="getElementPath">
		<xsl:param name="element"/>
		<xsl:text>self::</xsl:text>
		<xsl:value-of select="$element/@name"/>
		
		<!-- Path part from attributes -->
		<xsl:if test="$element/attribute[(not(@prohibited) or @prohibited = 'false') and (not(@isOptional) or @isOptional='false')]">
			<xsl:text>[</xsl:text>
			<xsl:for-each select="$element/attribute[(not(@prohibited) or @prohibited = 'false') and (not(@isOptional) or @isOptional='false')]">
				<xsl:text>@</xsl:text>
				<xsl:value-of select="./@name"/>
				<xsl:if test="./@value">
					<xsl:text>='</xsl:text>
					<xsl:value-of select="./@value"/>
					<xsl:text>'</xsl:text>
				</xsl:if>
				<xsl:if test="position() &lt; last()">
					<xsl:text> and </xsl:text>
				</xsl:if>
			</xsl:for-each>
			<xsl:text>]</xsl:text>
		</xsl:if>

		<!-- Path part from vocabulary -->
		<xsl:if test="$element/vocabulary">
			<xsl:text>[</xsl:text>
			<xsl:for-each select="$element/vocabulary">
				<xsl:if test="count($element/vocabulary) > 1">
					<xsl:text>(</xsl:text>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="@valueSet">
						<xsl:variable name="effectiveDate">
							<xsl:choose>
								<xsl:when test="not(./@flexibility) or ./@flexibility='dynamic'">
									<xsl:value-of select="max(//valueSet[@name=current()/@valueSet]/xs:dateTime(@effectiveDate))"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="xs:dateTime(current()/@flexibility)"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:text>@codeSystem='</xsl:text>
						<xsl:value-of select="//valueSet[@name=current()/@valueSet and @effectiveDate=$effectiveDate]/conceptList/concept[1]/@codeSystem"/>
						<xsl:text>'</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="./@*">
							<xsl:text>@</xsl:text>
							<xsl:value-of select="./name()"/>
							<xsl:text>='</xsl:text>
							<xsl:value-of select="."/>
							<xsl:text>'</xsl:text>
							<xsl:if test="position() &lt; last()">
								<xsl:text> and </xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="count($element/vocabulary) > 1">
					<xsl:text>)</xsl:text>
				</xsl:if>
				<xsl:if test="position() &lt; last()">
					<xsl:text> or </xsl:text>
				</xsl:if>
			</xsl:for-each>
			<xsl:text>]</xsl:text>
		</xsl:if>

		<!-- Path part from node text -->
		<xsl:if test="$element/text">
			<xsl:text>['</xsl:text>
			<xsl:value-of select="$element/text"/>
			<xsl:text>']</xsl:text>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="attribute" mode="process">
		<xsl:copy-of select="."/>
	</xsl:template>
	
	<!--<xsl:template match="attribute" mode="path">
		<path>
			<xsl:call-template name="getElementPath">
				<xsl:with-param name="element" select="."/>
			</xsl:call-template>
		</path>
	</xsl:template>-->
	
	<xsl:template match="vocabulary" mode="process">
		<xsl:copy-of select="."/>
	</xsl:template>
	
	<xsl:template match="text" mode="process">
		<xsl:copy-of select="."/>
	</xsl:template>
	
	<xsl:template match="assert" mode="process">
		<xsl:copy-of select="."/>
	</xsl:template>
	
	<xsl:template match="report" mode="process">
		<xsl:copy-of select="."/>
	</xsl:template>
	
	<xsl:template match="element" mode="path">
		<path>
			<xsl:call-template name="getElementPath">
				<xsl:with-param name="element" select="."/>
			</xsl:call-template>
		</path>
	</xsl:template>

	
	<xsl:template match="element" mode="process">
		<xsl:param name="rootElement"/>
		<xsl:param name="currentPath"/>
		<xsl:param name="template"/>
		<element>
			<xsl:copy-of select="./(@*|desc|item|vocabulary|property|text)"/>
			<xsl:call-template name="processElements">
				<xsl:with-param name="rootElement" select="."/>
				<xsl:with-param name="currentPath">
					<xsl:choose>
						<xsl:when test="$rootElement = $template and ($template/context/@id = '**' or not($template/context))">
							<xsl:value-of select="$currentPath"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat($currentPath,@name,'/')"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
				<xsl:with-param name="template" select="$template"/>
			</xsl:call-template>
		</element>
	</xsl:template>
	
	<xsl:template match="choice" mode="path">
		<xsl:call-template name="getChildElementPaths">
			<xsl:with-param name="rootElement" select="."/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="choice" mode="process">
		<xsl:copy-of select="."/>
	</xsl:template>
	
	<xsl:template match="include" mode="path">
		<xsl:variable name="effectiveDate">
			<xsl:choose>
				<xsl:when test="not(./@flexibility) or ./@flexibility='dynamic'">
					<xsl:value-of select="max(//template[@id=current()/@ref]/xs:dateTime(@effectiveDate))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="xs:dateTime(current()/@flexibility)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<!-- For includes - getting path of the root (or first) element of referenced template-->
		<path>
			<xsl:call-template name="getElementPath">
				<xsl:with-param name="element" select="//template[@id=current()/@ref and @effectiveDate=$effectiveDate]/element[1]"></xsl:with-param>
			</xsl:call-template>
		</path>
	</xsl:template>
	
	<xsl:template match="include" mode="process">
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template name="getChildElementPaths">
		<xsl:param name="rootElement"/>
		<xsl:apply-templates select="$rootElement/(element | choice | include)" mode="path"/>
	</xsl:template>
	
	<xsl:template name="processElements">
		<xsl:param name="rootElement"/>
		<xsl:param name="currentPath"/>
		<xsl:param name="template"/>
		
		<!-- Getting list of all child element paths -->
		<xsl:variable name="elementPaths">
			<xsl:call-template name="getChildElementPaths">
				<xsl:with-param name="rootElement" select="."/>
			</xsl:call-template>
		</xsl:variable>
		
		<!-- Iterating throgh elements -->
		<xsl:apply-templates select="$rootElement/(element | attribute | choice | include | assert | report)" mode="process">
			<xsl:with-param name="rootElement" select="$rootElement"/>
			<xsl:with-param name="currentPath" select="$currentPath"/>
			<xsl:with-param name="template" select="$template"/>
		</xsl:apply-templates>
		
		<!-- Creating schematron rule to fix closed templates validation -->
		<xsl:if test="$elementPaths/path and ($rootElement != $template or ($rootElement = $template and $template/context/@id='*'))">
			<xsl:comment>Closed Templates Fix</xsl:comment>
			<assert role="error">
				<xsl:attribute name="test">
					<xsl:text>not(./*[not(</xsl:text>
					<xsl:for-each select="distinct-values($elementPaths/path)">
						<xsl:value-of select="."/>
						<xsl:if test="position() &lt; last()">
							<xsl:text> | </xsl:text>
						</xsl:if>
					</xsl:for-each>
					<xsl:text>)])</xsl:text>
				</xsl:attribute>
				<xsl:text>We fragmencie dokumentu zgodnym z szablonem "</xsl:text>
				<xsl:value-of select="$template/@displayName"/>
				<xsl:text>" występują niedozwolone elementy.</xsl:text>
			</assert>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="template" mode="default">
		<xsl:copy-of select="."/>
	</xsl:template>
	
	<xsl:template match="template" mode="fix">
		<template>
			<!-- Coping unchanged elements of the template -->
			<xsl:copy-of select="./(@*|*)[not(self::element | self::attribute | self::choice | self::include | self::assert | self::report)]" />
			
			<!-- Iterating through elements -->
			<xsl:call-template  name="processElements">
				<xsl:with-param name="rootElement" select="."/>
				<xsl:with-param name="currentPath" select="'/'"></xsl:with-param>
				<xsl:with-param name="template" select="."/>
			</xsl:call-template>
		</template>
	</xsl:template>

	<xsl:template match="/">
		<decor xmlns:extPL="http://www.csioz.gov.pl/xsd/extPL/r1"
			xmlns:pharm="urn:ihe:pharm"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" repository="true" private="false"
			xsi:noNamespaceSchemaLocation="Decor/DECOR.xsd">
			<!-- TODO: Copying namespaces automaticaly -->
			<xsl:apply-templates select="/decor/*"/>
		</decor>
	</xsl:template>

	<xsl:template match="project">
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template match="datasets">
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template match="scenarios">
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template match="ids">
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template match="terminology">
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template match="issues">
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template match="rules">
		<rules>
		<xsl:for-each select="//template">
			<xsl:variable name="latestVersion" select="max(//template[@name=current()/@name]/xs:dateTime(@effectiveDate))"/>
			<xsl:comment>
				<xsl:value-of select="@name"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select="@versionLabel"/>
				<xsl:choose>
					<xsl:when test="@isClosed = 'true'">
						<xsl:text> (Closed) </xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text> (Open) </xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:comment>
			<xsl:choose>
				<xsl:when test="not(@isClosed) or @isClosed='false'">
					<xsl:apply-templates select="." mode="default"/>
				</xsl:when>
				<xsl:when test="@isClosed='true' and not(xs:dateTime(@effectiveDate)=$latestVersion)">
					<xsl:apply-templates select="." mode="default"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="." mode="fix"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
		</rules>
	</xsl:template>

</xsl:stylesheet>
