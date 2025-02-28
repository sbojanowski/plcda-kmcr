<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">

	<xsl:output method="xml" indent="yes"/>
	
	<xsl:param name="templateName"/>
	
	<xsl:variable name="templateId" select="xs:string(//template[@name=$templateName][1]/@id)"/>
	
	<xsl:variable name="processedTemplateIds">
		<xsl:call-template name="processTemplateIds">
			<xsl:with-param name="id" select="$templateId"/>
		</xsl:call-template>
	</xsl:variable>

	<xsl:template name="processTemplateIds">
		<xsl:param name="id"/>
		
		<xsl:variable name="latestVersion" select="max(//template[@id=$id]/xs:dateTime(@effectiveDate))"/>
		<xsl:variable name="template" select="//template[@id=$id and @effectiveDate=$latestVersion]"/>

		<!-- Process all included and contained templates -->
		<xsl:variable name="includedTemplateIds">
			<xsl:for-each select="$template//(include[@ref]|element[@contains])">
				<xsl:call-template name="processTemplateIds">
					<xsl:with-param name="id">
						<xsl:choose>
							<xsl:when test="@ref"><xsl:value-of select="@ref"/></xsl:when>
							<xsl:when test="@contains"><xsl:value-of select="@contains"/></xsl:when>
						</xsl:choose>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>
		</xsl:variable>
		
		<xsl:value-of select="(($id), ($includedTemplateIds))"/>
	</xsl:template>
	
	<xsl:template name="copyTemplates">
		<xsl:param name="templateList" select="distinct-values(tokenize($processedTemplateIds,' '))"/>
		<xsl:for-each select="//template[@id=$templateList]">
			<xsl:variable name="latestVersion" select="max(//template[@id=current()/@id]/xs:dateTime(@effectiveDate))"/>
			<xsl:if test="current()/@effectiveDate=$latestVersion">
				<xsl:copy-of select="current()"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="copyValueSets">
		<xsl:param name="templateNumber" select="1"/>
		<xsl:param name="templateList" select="distinct-values(tokenize($processedTemplateIds,' '))"/>
		<xsl:param name="processedValueSets"/>
		
		<xsl:if test="$templateNumber&lt;=count($templateList)">
			<xsl:variable name="templateId" select="$templateList[$templateNumber]"/>
			<xsl:variable name="latestVersion" select="max(//template[@id=$templateId]/xs:dateTime(@effectiveDate))"/>
			<xsl:variable name="template" select="//template[@id=$templateId and @effectiveDate=$latestVersion]"/>
				
			<xsl:variable name="valueSets" select="$template//vocabulary/@valueSet"/>
			
			<xsl:for-each select="$valueSets">
				<xsl:if test="not(current()=$processedValueSets)">
					<xsl:variable name="valueSetLatestVersion" select="max(//valueSet[@name=current()]/xs:dateTime(@effectiveDate))"/>
					<xsl:copy-of select="//valueSet[@name=current() and xs:dateTime(@effectiveDate)=$valueSetLatestVersion]"/>
				</xsl:if>
			</xsl:for-each>
			
			<xsl:call-template name="copyValueSets">
				<xsl:with-param name="templateNumber" select="$templateNumber+1"/>
				<xsl:with-param name="templateList" select="$templateList"/>
				<xsl:with-param name="processedValueSets" select="($processedValueSets, $valueSets)"/>
			</xsl:call-template>
			
		</xsl:if>
	</xsl:template>

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
		<scenarios>
			<xsl:copy-of select="scenario[.//representingTemplate/@ref=$templateId]"/>
		</scenarios>
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
			
			<xsl:call-template name="copyValueSets">
				<xsl:with-param name="processedValueSets" select="()"></xsl:with-param>
			</xsl:call-template>
		</terminology>
	</xsl:template>

	<xsl:template match="rules">
		<rules>
			<xsl:call-template name="copyTemplates"/>
		</rules>
	</xsl:template>
	
</xsl:stylesheet>
