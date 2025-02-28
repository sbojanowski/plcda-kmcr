<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs">

	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="/">
		<decor xmlns:extPL="http://www.csioz.gov.pl/xsd/extPL/r1" xmlns:pharm="urn:ihe:pharm"
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
	
	<xsl:template match="issues">
		<xsl:copy-of select="."/>
	</xsl:template>
	
	<xsl:template match="codeSystem">
		<xsl:copy-of select="."/>
	</xsl:template>
	
	<xsl:template match="terminology">
		<terminology>
			<xsl:apply-templates select="codeSystem"/>
			
			<xsl:for-each select="//valueSet">
				<xsl:variable name="latestVersion" select="max(//valueSet[@id=current()/@id]/xs:dateTime(@effectiveDate))"/>
				<xsl:choose>
					<xsl:when test="not(@ref) and xs:dateTime(@effectiveDate)=$latestVersion">
						<xsl:copy-of select="."/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:comment>
							<xsl:text>Value set </xsl:text>
							<xsl:value-of select="@id"/>
							<xsl:text> ver. </xsl:text>
							<xsl:value-of select="@versionLabel"/>
							<xsl:text> was removed (newer version available)</xsl:text>
						</xsl:comment>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</terminology>
	</xsl:template>

	<xsl:template match="rules">
		<rules>
			<xsl:for-each select="//template">
				<xsl:variable name="latestVersion" select="max(//template[@id=current()/@id]/xs:dateTime(@effectiveDate))"/>
				<xsl:choose>
					<xsl:when test="xs:dateTime(@effectiveDate)=$latestVersion">
						<xsl:copy-of select="."/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:comment>
							<xsl:text>Template </xsl:text>
							<xsl:value-of select="@id"/>
							<xsl:text> ver. </xsl:text>
							<xsl:value-of select="@versionLabel"/>
							<xsl:text> was removed (newer version available)</xsl:text>
						</xsl:comment>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</rules>
	</xsl:template>
	
</xsl:stylesheet>
