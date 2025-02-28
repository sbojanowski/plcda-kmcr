<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dyn="http://exslt.org/dynamic">
	
	<xsl:param name="ad1bbrTemplateIdPrefix" select="'2.16.840.1.113883.10.12'"/>
	<xsl:param name="baseTemplatePrefix" select="'plCdaBase'"/>
	<xsl:param name="latestVersion" select="max(//project/(release|version)/xs:dateTime(@date))" as="xs:dateTime"/>
	
	<xsl:template name="getParentTemplates">
		<xsl:param name="template"/>
		
		<xsl:variable name="parentTemplateId" select="$template/relationship[@type='SPEC']/@template"/>
		
		<xsl:if test="$parentTemplateId">
			<xsl:message><xsl:text>Parent template:</xsl:text><xsl:value-of select="$parentTemplateId"/></xsl:message>
			<xsl:variable name="parentTemplate">
				<xsl:choose>
					<xsl:when test="contains($parentTemplateId, $ad1bbrTemplateIdPrefix)">
<!-- 						<xsl:variable name="ad1bbrDocumentPath"> -->
<!-- 							<xsl:text><![CDATA[http://art-decor.org/decor/services/modules/RetrieveTemplate.xquery?id=]]></xsl:text> -->
<!-- 							<xsl:value-of select="$parentTemplateId"/> -->
<!-- 							<xsl:text><![CDATA[&prefix=ad1bbr-&format=xml]]></xsl:text> -->
<!-- 						</xsl:variable> -->
<!-- 						<xsl:message><xsl:value-of disable-output-escaping="yes" select="$ad1bbrDocumentPath"/></xsl:message> -->
<!-- 						<xsl:copy-of select="doc($ad1bbrDocumentPath)//template[1]"/> -->
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy-of select="//template[@id=$parentTemplateId]"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:if test="$parentTemplate">
				<xsl:call-template name="getParentTemplates">
					<xsl:with-param name="template" select="$parentTemplate/template"/>
				</xsl:call-template>
				<xsl:copy-of select="$parentTemplate"/>			
			</xsl:if>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="getPath">
		<xsl:param name="element"/>
		<xsl:if test="$element">
			<xsl:variable name="parentNode" select="$element/parent::*[name()!='template']"/>
			<xsl:if test="$parentNode">
				<xsl:call-template name="getPath">
					<xsl:with-param name="element" select="$parentNode"/>
				</xsl:call-template>
				<xsl:text>/</xsl:text>
			</xsl:if>
			<xsl:variable name="count">
				<xsl:choose>
					<xsl:when test="$element/name()='include'">
						<xsl:value-of select="count($element/parent::*/*[(name()=name($element)) and (@ref=$element/@ref)])"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="count($element/parent::*/*[(name()=name($element)) and (@name=$element/@name)])"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="conditions">
				<xsl:choose>
					<xsl:when test="$element/name()='choice'">
						<!-- TODO choice handling -->
					</xsl:when>
					<xsl:when test="$element/name()='include'">
						<xsl:value-of select="concat('contains(@ref,''',replace($element/@ref,$baseTemplatePrefix,''),''')')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat('@name=''',$element/@name,'''')"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="$count &gt; 1">
					<xsl:choose>
						<xsl:when test="$element/@datatype='II'">
							<xsl:if test="$element/attribute[@name='root' and (not(@isOptional) or @isOptional=false()) and @value]">
								<xsl:value-of select="concat(' and attribute[@name=''root'' and @value=''',$element/attribute[@name='root']/@value,''']')"/>
							</xsl:if>
						</xsl:when>
						<xsl:when test="not($element/@datatype)">
							<xsl:if test="$element/@contains">
								<xsl:value-of select="concat(' and contains(@contains,''',replace($element/@contains,$baseTemplatePrefix,''),''')')"/>
							</xsl:if>
						</xsl:when>
					</xsl:choose>
				</xsl:if>
			</xsl:variable>
			
			<xsl:value-of select="concat(name($element),'[',$conditions,']')"/>
			
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="/">
		<decor xmlns:extPL="http://www.csioz.gov.pl/xsd/extPL/r1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" repository="true" private="false" xsi:noNamespaceSchemaLocation="Decor/DECOR.xsd">
			<!-- TODO: Copying namespaces automaticaly -->
			<xsl:apply-templates select="/decor/rules"/>
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
		<!-- TODO: Latest version management -->
		<xsl:apply-templates select="./template[@id='2.16.840.1.113883.3.4424.13.10.1.3']"/>
	</xsl:template>
	
	<xsl:template match="template">
		<xsl:variable name="relevantTemplates">
			<xsl:call-template name="getParentTemplates">
				<xsl:with-param name="template" select="."/>
			</xsl:call-template>
			<xsl:copy-of select="."/>
		</xsl:variable>
		
		<xsl:variable name="baseTemplate" select="$relevantTemplates/template[1]"/>
		<xsl:copy-of select="$relevantTemplates"/>
		<xsl:variable name="childTemplates" select="$relevantTemplates/template[position()&gt;1]"/>
		
		<!-- Copying template attributes and metadata elements -->
		<template>
			<xsl:copy-of select="(@*|desc|classification|relationship|context)"/>
		</template>
		
		<!-- Processing template rules -->
		<xsl:call-template name="processElements">
			<xsl:with-param name="elements" select="$baseTemplate/element"/>
		</xsl:call-template>
		
	</xsl:template>
	
	<xsl:template name="processElements">
		<xsl:param name="elements"/>
		<xsl:for-each select="$elements">
			<xsl:variable name="elementPath">
				<xsl:call-template name="getPath">
					<xsl:with-param name="element" select="."/>
				</xsl:call-template>
			</xsl:variable>
			
			<xsl:value-of select="dyn:evaluate($elementPath)"/>
			
			<xsl:message><xsl:value-of select="$elementPath"/></xsl:message>
			<xsl:call-template name="processElements">
				<xsl:with-param name="elements" select="child::*[name()=('element','include','choice')]"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="getOverridingElementByPath">
		<xsl:param name="path"/>
		<xsl:param name="childTemplates"/>
	</xsl:template>
	
</xsl:stylesheet>