<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright (C) 2009-2014 Dr. Kai U. Heitmann, Alexander Henket This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published 
	by the Free Software Foundation; either version 3 of the License, or (at your option) any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without 
	even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. See http://www.gnu.org/licenses/gpl.html Icons by Axialis Team <a 
	href="http://www.axialis.com/free/icons">Icons</a> by <a href="http://www.axialis.com">Axialis Team</a> **** Modifications for Polish National HL7 CDA Implementation Guide Releases Copyright (C) 2014 Sebastian 
	Bojanowski, iEHR.eu **** -->
<!DOCTYPE stylesheet [
<!ENTITY termColorDark "#ECCCFF">
<!ENTITY termColorLight "#FFEAFF">
<!ENTITY infmColorDark "#FFCCCC">
<!ENTITY infmColorLight "#FFEAEA">
<!ENTITY mediColorDark "#E0FFE0">
<!ENTITY mediColorLight "#F4FFF4">
<!ENTITY sandColorDark "#ECE9E4">
<!ENTITY sandColorLight "#F6F3EE">
]>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:uuid="java:java.util.UUID" xmlns:local="http://art-decor.org/functions" xmlns:xs="http://www.w3.org/2001/XMLSchema">

	<!-- This stylesheet converts the rule set from a DECOR file into an appropriate HTML representation Note: this file cannot be used alone, it's called by the schematron conversion stylesheet -->
	<xsl:include href="v3mXML2HTMLGenerator2.xsl" />
	<!-- This stylesheet renders transaction groups into SVG for the Scenarios tab -->
	<xsl:include href="DECOR2svg.xsl" />

	<!-- Directory name with additional data sources for Polish release (eg. business-rules.xml) -->
	<xsl:variable name="dataDir" select="'data/'" />

	<!-- Additional data sources file relative paths -->
	<xsl:variable name="abstractTemplatesPath" select="concat($dataDir, 'abstract-templates.xml')" />
	
	<!--07.11.2015 - Business rules support removed --> 
	<!--<xsl:variable name="businessRulesPath" select="concat($dataDir, 'business-rules.xml')" /> -->
	<!--<xsl:variable name="isBusinessRulesFileAvailable" select="doc-available($businessRulesPath)" />-->
	
	<xsl:variable name="oidRegistryPath" select="concat($dataDir, 'oid-registry.xml')" />
	<xsl:variable name="extensionsSchemaPath" select="concat($dataDir, 'extPL_r1.xsd')" />

	<!-- Flags with additional data sources availability -->
	<xsl:variable name="isAbstractTemplatesFileAvailable" select="doc-available($abstractTemplatesPath)" />
	<xsl:variable name="isOidRegistryFileAvailable" select="doc-available($oidRegistryPath)" />
	<xsl:variable name="isExtensionsSchemaFileAvailable" select="doc-available($extensionsSchemaPath)" />


	<!-- Current release (iEHR.eu extension)-->
	<xsl:variable name="currentRelease" select="$allDECOR/project/release[@date&gt;=$latestVersion]"/>

	<!-- make a list of tab names (keys for messages) and their corresponsing file names -->
	<xsl:variable name="tabnameslist">
		<tabs>
			<tab key="tabFrontPage" filename="index.html" />
			<tab key="tabDocumentTemplates" filename="document-templates.html"/>
			<xsl:if test="//rules/*">
				<tab key="tabRules" filename="rules.html" />
			</xsl:if>
			<xsl:if test="//terminology/*">
				<tab key="tabTerminology" filename="terminology.html" />
			</xsl:if>
			<xsl:if test="$isExtensionsSchemaFileAvailable = true()">
				<tab key="tabExtensionsSchema" filename="extensions-schema.html" />
			</xsl:if>
			<!-- TEMP: Temporary removal on 04.12.2017
			<xsl:if test="$isOidRegistryFileAvailable = true()">
				<tab key="tabOidRegistry" filename="oid-registry.html" />
			</xsl:if>-->
			<!-- TEMP: Temporary removal on 04.12.2017
			<tab key="tabVisualization" filename="xslt.html"/>
			-->
<!-- 			<xsl:if test="count($dictionaries/dictionary)>0"> -->
<!-- 				<tab key="tabDictionaries" filename="dictionaries.html"/> -->
<!-- 			</xsl:if> -->
			-->
		</tabs>
	</xsl:variable>
	
	<!-- OID registry constants (iEHR.eu extension) -->
	<xsl:variable name="indentSize" select="4"/>
	<xsl:variable name="rootOidPartsCount" select="count(tokenize(document($oidRegistryPath)//oid[1]/dotNotation/@value,'\.'))"/> 

	<!-- Do SVG -->
	<xsl:variable name="allSvg">
		<xsl:if test="$switchCreateDocSVG=true()">
			<!-- Need at least 1 initial and 1 back for a webservice -->
			<xsl:for-each select="//scenarios/scenario//transaction[@type='group'][transaction[@type='initial']]">
				<transaction id="{@id}">
					<xsl:apply-templates select="self::node()" mode="transactionGroupToSVG">
						<xsl:with-param name="theOutputDir" select="$theHtmlDir" />
					</xsl:apply-templates>
				</transaction>
			</xsl:for-each>
		</xsl:if>
	</xsl:variable>

	<!-- Calculate missing issues/labels/labe definitions. Needed on Issues and Compile tab -->
	<xsl:variable name="allMissingLabels">
		<wrap>
			<xsl:for-each select="$allIssues/issue/(tracking|assignment)[@labels]">
				<xsl:variable name="issueId" select="parent::issue/@id" />
				<xsl:variable name="issuename">
					<xsl:choose>
						<xsl:when test="string-length(parent::issue/@displayName)>0">
							<xsl:value-of select="parent::issue/@displayName" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'notLabeled'" />
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="labelCodes" select="@labels" />
				<xsl:for-each select="distinct-values(tokenize($labelCodes,' '))">
					<xsl:variable name="labelCode" select="." />
					<xsl:if test="not($allIssues/labels/label[@code=$labelCode])">
						<missingCode ref="{$issueId}" refName="{$issuename}" labelCode="{$labelCode}" />
					</xsl:if>
				</xsl:for-each>
			</xsl:for-each>
		</wrap>
	</xsl:variable>

	<xsl:template name="doTabs4ThisTab">
		<!-- the name of the actual tab to build tabs for, see variable tabnames -->
		<xsl:param name="actualtab" />
		<!-- the actual content -->
		<xsl:param name="actualcontent" />
		<!-- iEHR.eu extension - explicit fileName -->
		<xsl:param name="fileName" />

		<xsl:variable name="fn">
			<xsl:value-of select="$theHtmlDir" />
			<xsl:choose>
				<xsl:when test="$fileName and $fileName!=''">
					<xsl:value-of select="$fileName"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$tabnameslist/*/tab[@key=$actualtab]/@filename" />
				</xsl:otherwise>
			</xsl:choose>
			
		</xsl:variable>

		<xsl:result-document href="{$fn}" method="html">
			<html>

				<xsl:text>&#10;&#10;</xsl:text>

				<head>
					<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />

					<title>
						<xsl:call-template name="getMessage">
							<xsl:with-param name="key" select="$actualtab" />
						</xsl:call-template>
						<xsl:text>: </xsl:text>
 						<xsl:value-of select="$allDECOR/project/@prefix" /> 
						<xsl:text> </xsl:text>
						<xsl:call-template name="getMessage">
							<xsl:with-param name="key" select="'decorTitleString'" />
						</xsl:call-template>
					</title>

					<xsl:call-template name="addAssetsHeader" />

				</head>

				<xsl:text>&#10;&#10;</xsl:text>

				<body>

					<xsl:text>&#10;&#10;</xsl:text>

					<table class="title">
						<tr>
							<td align="left">
								<h1>
									<xsl:value-of select="$allDECOR/project/name[@language=$defaultLanguage or not(@language)][1]"/>
									<xsl:text> (</xsl:text>
									<xsl:value-of select="$allDECOR/project/@prefix" />
									<xsl:text>)</xsl:text>
								</h1>
							</td>
						 	<td align="right">
						 		<!-- Release logos -->
								<xsl:for-each select="$customLogos/logo">
									<img src="{concat('../',@src)}" href="{@href}" alt="{@title}" />
								</xsl:for-each>
						 	</td>
						</tr>
					</table>

					<ul id="TabbedPanel">

						<xsl:for-each select="$tabnameslist/*/tab">
							<xsl:variable name="thistab" select="@key" />
							<xsl:variable name="thisfn" select="@filename" />
							<xsl:choose>
								<xsl:when test="$actualtab=$thistab">
									<li class="TabbedPanelsTabSelected">
										<xsl:call-template name="getMessage">
											<xsl:with-param name="key" select="$thistab" />
										</xsl:call-template>
									</li>
								</xsl:when>
								<xsl:otherwise>
									<li class="TabbedPanelsTabNotSelected">
										<a href="{$thisfn}">
											<xsl:call-template name="getMessage">
												<xsl:with-param name="key" select="$thistab" />
											</xsl:call-template>
										</a>
									</li>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>

					</ul>
					
					<xsl:copy-of select="$actualcontent" />
					<xsl:call-template name="addAssetsBottom" />
					
				</body>
			</html>
		</xsl:result-document>

	</xsl:template>

	<xsl:template name="convertDECOR2HTML">
		<!-- build html documentation, consists of - front page (index) - project information page (project) - data sets page (datasets) - scenarios page (scenarios) - identifiers page (identifiers) - terminology 
			page (terminology) - rules page (rules) - issues page (issues) - compile time page (compiletime) - legal page (legal) -->

		

		<!-- RELEASE.txt or VERSION.txt This file helps publication on a website -->
		<xsl:variable name="releaseType" select="if ($publicationIsRelease=true()) then ('RELEASE') else ('VERSION')" />
		<xsl:result-document href="{$theHtmlDir}{$releaseType}.txt" method="text">
			<xsl:value-of select="(//project/(version|release)[@date=max(parent::project/(version|release)/xs:dateTime(@date))]/@versionLabel)[1]" />
		</xsl:result-document>

		<!-- Front Page ============ -->
		<xsl:call-template name="doFrontPageTab" />
		
		<!-- Document templates (iEHR.eu extension) ============ -->
		<xsl:call-template name="doDocumentTemplatesTab" />
		
		<!-- Business rules generation (doBusinessRule) called from doFrontPageTab per template id -->
		<xsl:call-template name="doExamples" />

		<!-- Rules ======= -->
		<xsl:call-template name="doRulesTab" />

		<!-- Terminology ============= -->
		<xsl:call-template name="doTerminologyTab" />

		<!-- Dictionaries (iEHReu extension -->
		<!-- 27.01.2015: dictionaries list moved to the terminology tab -->
<!-- 		<xsl:if test="count($dictionaries/dictionary)>0"> -->
<!-- 			<xsl:call-template name="doDictionaries" /> -->
<!-- 		</xsl:if> -->

		<!-- TODO: extPL CDA extensions tab (iEHR.eu extension) -->
		<xsl:call-template name="doExtensionsSchemaTab"/>

		<!-- OID registry tab (iEHR.eu extension)-->
		<!-- TEMP: Temporary removal on 04.12.2017
		<xsl:call-template name="doOidRegistryTab"/>
		-->
		<!-- Visualization (XSLT) tab (iEHR.eu extension) -->
		<!-- TEMP: Temporary removal on 04.12.2017
		<xsl:call-template name="doVisualizationTab"/>
		-->
		
		<!-- Change log file (iEHR.eu extension) -->
		<xsl:call-template name="doChangeLog"/>

	</xsl:template>

	<xsl:template name="doFrontPageTab">
		<xsl:call-template name="logMessage">
			<xsl:with-param name="level" select="$logINFO" />
			<xsl:with-param name="msg">
				<xsl:text>*** Creating HTML For Front Page Tab</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
		
		<xsl:variable name="content">
			<div class="TabbedPanelsContent">
				<!-- Release title -->
				<div>
					<h1>
						<xsl:call-template name="getMessage">
							<xsl:with-param name="key" select="'frontPageHeader'"/>
							<xsl:with-param name="p1" select="$currentRelease/note[@language=$defaultLanguage]"/>
							<xsl:with-param name="p2" select="$currentRelease/@versionLabel"/>
						</xsl:call-template>
					</h1>
					<h4>
						<xsl:call-template name="getMessage">
							<xsl:with-param name="key" select="'frontPageReleaseDate'"/>
							<xsl:with-param name="p1" select="$currentRelease/@date"/>
						</xsl:call-template>
					</h4>
				</div>
				<!-- Content of the home page source if available -->
				<xsl:if test="$homePageSrc">
					<xsl:copy-of select="doc($homePageSrc)/html/body/*"/>
				</xsl:if>
			</div>
		</xsl:variable>
		<xsl:call-template name="doTabs4ThisTab">
			<xsl:with-param name="actualtab" select="'tabFrontPage'" />
			<xsl:with-param name="actualcontent" select="$content" />
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="doDocumentTemplatesTab">
		<xsl:call-template name="logMessage">
			<xsl:with-param name="level" select="$logINFO" />
			<xsl:with-param name="msg">
				<xsl:text>*** Creating HTML file for Document Templates tab (iEHR.eu extension)</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
		
		<xsl:variable name="abstractTemplates">
			<xsl:if test="$isAbstractTemplatesFileAvailable">
				<xsl:copy-of select="document($abstractTemplatesPath)//template" />
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="content">
			<div class="TabbedPanelsContent">
				<!-- List of non-abstract templates in current release -->
				<div>
					<h2>
						<xsl:call-template name="getMessage">
							<xsl:with-param name="key" select="'documentTemplatesHeader'"/>
						</xsl:call-template>
					</h2>
					<table class="document-templates">
						<xsl:for-each select="$allDECOR/rules/template[classification/@type='cdadocumentlevel' and xs:dateTime(@effectiveDate)=$latestVersion]">
							<xsl:sort select="@displayName"/>
							<xsl:variable name="fileSuffix" select="concat(@id,'-',translate(@effectiveDate,':', ''))"/>
							<xsl:if test="not($abstractTemplates/template[@id=current()/@id])">
								<!--07.11.2015: Business rules support removed -->
								<!--<xsl:call-template name="doBusinessRules">
									<xsl:with-param name="template" select="."/>
								</xsl:call-template>-->
								<tr>
									<td>
										<xsl:call-template name="showStatusDot">
											<xsl:with-param name="status" select="@statusCode"/>
										</xsl:call-template>
									</td>
									<td>
										<xsl:value-of select="@displayName"/>
									</td>
									<td>
										<xsl:value-of select="desc[@language=$defaultLanguage]"/>
									</td>
									<!--07.11.2015: Business rules support removed -->
									<!--<td>
										<a href="business-rules-{$fileSuffix}.html" target="_blank">
											<xsl:call-template name="getMessage">
												<xsl:with-param name="key" select="'tabBusinessRules'"/>
											</xsl:call-template>
										</a>
									</td>-->
									<!-- TEMP: Temporary removal on 04.12.2017
									<td>
										<a href="../{$projectPrefix}schematrons-{$defaultLanguage}/{$fileSuffix}.zip">Schematron</a>
									</td>
									-->
									<td>
										<a href="tmp-{$fileSuffix}.html" target="_blank">DECOR</a>
									</td>
									<td>
										<a href="examples-{$fileSuffix}.html">
											<xsl:call-template name="getMessage">
												<xsl:with-param name="key" select="'tabExamples'"/>
											</xsl:call-template>
										</a>
									</td>
								</tr>
							</xsl:if>
						</xsl:for-each>
						<!-- TEMP: Temporaty removal on 04.12.2017 
						<tr>
							 11.11.2015: New fake tamplate as a group of nursery assesment entries
							<td colspan="6">
								<div id="Accordionrl" class="Accordion" tabindex="0">
								<div class="AccordionPanel">
									<div class="AccordionPanelTab">
										<h3 id="nursing_templates" class="acco" onclick="toggleZoomImg(this,'zoomout','../assets/');">
										<xsl:call-template name="getMessage">
											<xsl:with-param name="key" select="'nurseryTemplatesLink'"/>
										</xsl:call-template>
										</h3>
									</div>
									<div class="AccordionPanelContent">
										<table class="document-templates">
										<xsl:for-each select="$allDECOR/rules/template[contains(@name,'plCdaNursing') and contains(@name,'Entry')]">
											<xsl:variable name="fileSuffix" select="concat(@id,'-',translate(@effectiveDate,':', ''))"/>
											<tr>
												<td>
													<xsl:value-of select="@displayName"/>
												</td>
												<td>
													<xsl:value-of select="desc[@language=$defaultLanguage]"/>
												</td>
												<td>
													<a href="tmp-{$fileSuffix}.html" target="_blank">DECOR</a>
												</td>
											</tr>
										</xsl:for-each>
										</table>
									</div>
								</div>
								</div>
							</td>
						</tr>
						-->
					</table>
				</div>
			</div>
		</xsl:variable>
		<xsl:call-template name="doTabs4ThisTab">
			<xsl:with-param name="actualtab" select="'tabDocumentTemplates'" />
			<xsl:with-param name="actualcontent" select="$content" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="doProjectTab">

		<!-- a little milestoning -->
		<xsl:call-template name="logMessage">
			<xsl:with-param name="level" select="$logINFO" />
			<xsl:with-param name="msg">
				<xsl:text>*** Creating HTML For Project Page Tab</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:variable name="content2">
			<div class="TabbedPanelsContent">
				<h2>
					<a name="labelProject">
						<xsl:call-template name="getMessage">
							<xsl:with-param name="key" select="'tabProjectInfoTitleString'" />
						</xsl:call-template>
					</a>
				</h2>
				<xsl:call-template name="doProjectInfo" />
			</div>
		</xsl:variable>
		<xsl:call-template name="doTabs4ThisTab">
			<xsl:with-param name="actualtab" select="'tabProjectInformation'" />
			<xsl:with-param name="actualcontent" select="$content2" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="doScenarioTab">
		<xsl:if test="//scenarios/*">
			<!-- a little milestoning -->
			<xsl:call-template name="logMessage">
				<xsl:with-param name="level" select="$logINFO" />
				<xsl:with-param name="msg">
					<xsl:text>*** Creating HTML For Scenarios Tab</xsl:text>
				</xsl:with-param>
			</xsl:call-template>

			<xsl:variable name="content4">
				<div class="TabbedPanelsContent">
					<h2>
						<a name="labelScenarios">
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'tabScenariosTitleString'" />
							</xsl:call-template>
						</a>
					</h2>
					<div id="Accordionsc" class="Accordion" tabindex="0">
						<xsl:if test="count(//scenarios)=0">
							<table border="0">
								<xsl:call-template name="doMessage">
									<xsl:with-param name="level" select="'info'" />
									<xsl:with-param name="msg">
										<xsl:call-template name="getMessage">
											<xsl:with-param name="key" select="'issueNoScenariosDefinedYet'" />
										</xsl:call-template>
									</xsl:with-param>
								</xsl:call-template>
							</table>
						</xsl:if>
						<xsl:for-each select="//scenarios/scenario">
							<xsl:sort select="@effectiveDate" order="descending" />
							<xsl:text>&#10;&#10;</xsl:text>
							<div class="AccordionPanel">
								<div class="AccordionPanelTab">
									<h3 class="acco" onclick="toggleZoomImg(this,'zoomout','{$theAssetsDir}');">
										<xsl:call-template name="showStatusDot">
											<xsl:with-param name="status" select="@statusCode" />
										</xsl:call-template>
										<xsl:text>&#160;</xsl:text>
										<xsl:call-template name="doName">
											<xsl:with-param name="ns" select="name" />
											<!--<xsl:with-param name="lang" select="$defaultLanguage"/> -->
										</xsl:call-template>
										<xsl:if test="@versionLabel">
											<xsl:text> - v</xsl:text>
											<xsl:value-of select="@versionLabel" />
											<xsl:text> /</xsl:text>
										</xsl:if>
										<xsl:text>&#160;</xsl:text>
										<xsl:call-template name="showDate">
											<xsl:with-param name="date" select="@effectiveDate" />
										</xsl:call-template>
										<table border="0">
											<tr>
												<td class="comment">
													<xsl:call-template name="doDescription">
														<xsl:with-param name="ns" select="desc" />
														<xsl:with-param name="shortDesc" select="true()" />
													</xsl:call-template>
												</td>
											</tr>
										</table>
									</h3>
								</div>
								<div class="AccordionPanelContent">
									<table border="0" cellspacing="2" cellpadding="2" width="100%">
										<tr valign="top">
											<td class="tabtab">
												<xsl:call-template name="doScenarios">
													<xsl:with-param name="nestingWithTables" select="true()" />
												</xsl:call-template>
											</td>
										</tr>
									</table>
								</div>
							</div>
						</xsl:for-each>
					</div>

					<!-- then show a summary of scenario table -->
					<h2>
						<a name="labelRules">
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'scenarioSummary'" />
							</xsl:call-template>
						</a>
					</h2>
					<xsl:text>&#10;&#10;</xsl:text>
					<table width="50%" border="0" cellspacing="2" cellpadding="2">
						<tr valign="top">
							<td class="tabtab">
								<table width="100%" border="0" cellspacing="3" cellpadding="2">
									<tr bgcolor="#CCFFCC">
										<td>
											<xsl:call-template name="getMessage">
												<xsl:with-param name="key" select="'scenarios'" />
											</xsl:call-template>
										</td>
										<td colspan="2">
											<xsl:value-of select="count($allScenarios/scenarios/scenario)" />
										</td>
									</tr>
									<tr bgcolor="#CCFFCC">
										<td>
											<xsl:call-template name="getMessage">
												<xsl:with-param name="key" select="'transactionGroups'" />
											</xsl:call-template>
										</td>
										<td colspan="2">
											<xsl:value-of select="count($allScenarios/scenarios/scenario//transaction[@type='group'])" />
										</td>
									</tr>
									<tr bgcolor="#CCFFCC">
										<td>
											<xsl:call-template name="getMessage">
												<xsl:with-param name="key" select="'transactions'" />
											</xsl:call-template>
										</td>
										<td colspan="2">
											<xsl:value-of select="count($allScenarios/scenarios/scenario//transaction[not(@type='group')])" />
										</td>
									</tr>
								</table>
							</td>
						</tr>
					</table>

					<!-- create rule lists per scenario x -->
					<h2>
						<a name="labelRules">
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'transactionsPerActor'" />
							</xsl:call-template>
						</a>
					</h2>
					<xsl:for-each select="$allActors/actors/actor">
						<xsl:variable name="actorid" select="@id" />
						<xsl:variable name="actorname">
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="concat('actorType-',@type)" />
							</xsl:call-template>
							<xsl:text>:&#160;</xsl:text>
							<xsl:call-template name="doName">
								<xsl:with-param name="ns" select="name" />
							</xsl:call-template>
						</xsl:variable>
						<h3>
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'transactionsForActor'" />
							</xsl:call-template>
							<xsl:text> </xsl:text>
							<i>
								<xsl:value-of select="$actorname" />
							</i>
						</h3>
						<table width="100%" border="0" cellspacing="2" cellpadding="2">
							<tr valign="top">
								<td class="tabtab">
									<table width="100%" border="0" cellspacing="3" cellpadding="2">
										<tr>
											<th>
												<xsl:call-template name="getMessage">
													<xsl:with-param name="key" select="'actorRole'" />
												</xsl:call-template>
											</th>
											<th>
												<xsl:call-template name="getMessage">
													<xsl:with-param name="key" select="'Type'" />
												</xsl:call-template>
											</th>
											<th>
												<xsl:call-template name="getMessage">
													<xsl:with-param name="key" select="'Transaction'" />
												</xsl:call-template>
											</th>
											<th>
												<xsl:call-template name="getMessage">
													<xsl:with-param name="key" select="'Model'" />
												</xsl:call-template>
											</th>
											<th>
												<xsl:call-template name="getMessage">
													<xsl:with-param name="key" select="'representingTemplate'" />
												</xsl:call-template>
											</th>
										</tr>
										<xsl:for-each select="$allScenarios/scenarios/scenario//transaction[@type='group'][transaction/actors/actor/@id=$actorid]">
											<tr>
												<td align="left">&#160;</td>
												<td align="left">
													<i>
														<xsl:call-template name="getMessage">
															<xsl:with-param name="key" select="'Group'" />
														</xsl:call-template>
													</i>
												</td>
												<td align="left">
													<i>
														<xsl:value-of select="(name[@language=$defaultLanguage or not(@language)])[1]" />
													</i>
												</td>
												<td align="left">&#160;</td>
												<td align="left">&#160;</td>
											</tr>
											<!-- <actors> <actor id="2.16.840.1.113883.2.4.3.11.60.100.5.8" role="sender"/> <actor id="2.16.840.1.113883.2.4.3.11.60.100.5.7" role="receiver"/> </actors> -->
											<xsl:for-each select="transaction[actors/actor/@id=$actorid]">
												<tr>
													<!-- Role -->
													<td align="left">
														<xsl:for-each select="actors/actor[@id=$actorid]">
															<xsl:choose>
																<xsl:when test="@role='sender' or @role='receiver'">
																	<xsl:call-template name="getMessage">
																		<xsl:with-param name="key" select="concat('actorRole-',@role)" />
																	</xsl:call-template>
																</xsl:when>
																<xsl:otherwise>
																	<xsl:value-of select="@role" />
																</xsl:otherwise>
															</xsl:choose>
															<xsl:if test="position()!=last()">
																<xsl:text> / </xsl:text>
															</xsl:if>
														</xsl:for-each>
													</td>
													<!-- Transaction type -->
													<td align="left">
														<xsl:call-template name="getMessage">
															<xsl:with-param name="key" select="concat('transactionDirection',@type)" />
														</xsl:call-template>
													</td>
													<!-- Transaction name -->
													<td align="left">
														<xsl:text>&#160;&#160;&#160;</xsl:text>
														<xsl:value-of select="(name[@language=$defaultLanguage or not(@language)])[1]" />
													</td>
													<!-- Model -->
													<td align="left">
														<xsl:value-of select="@model" />
													</td>
													<!-- Representing template -->
													<td align="left">
														<xsl:for-each select="representingTemplate[@ref]">
															<xsl:variable name="xref" select="@ref" />
															<xsl:variable name="xflex" select="@flexibility" />
															<xsl:variable name="rccontent">
																<xsl:call-template name="getRulesetContent">
																	<xsl:with-param name="ruleset" select="$xref" />
																	<xsl:with-param name="flexibility" select="$xflex" />
																</xsl:call-template>
															</xsl:variable>
															<xsl:variable name="ahref">
																<xsl:choose>
																	<xsl:when test="matches($xflex,'^\d{4}')">
																		<xsl:value-of select="concat('tmp-',$xref,'-',replace($xflex,':',''),'.html')" />
																	</xsl:when>
																	<xsl:otherwise>
																		<xsl:value-of select="concat('tmp-',$xref,'-DYNAMIC.html')" />
																	</xsl:otherwise>
																</xsl:choose>
															</xsl:variable>
															<xsl:variable name="ahrefcontent">
																<xsl:choose>
																	<xsl:when test="$rccontent/*[@displayName]">
																		<xsl:value-of select="$rccontent/*/@displayName" />
																	</xsl:when>
																	<xsl:when test="$rccontent/*[@name]">
																		<xsl:value-of select="$rccontent/*/@name" />
																	</xsl:when>
																	<xsl:otherwise>
																		<xsl:value-of select="$xref" />
																	</xsl:otherwise>
																</xsl:choose>
															</xsl:variable>
															<a href="{$ahref}" target="_blank">
																<xsl:attribute name="title">
                                                                    <xsl:call-template name="getMessage">
                                                                        <xsl:with-param name="key" select="'Id'" />
                                                                    </xsl:call-template>
                                                                    <xsl:text>: </xsl:text>
                                                                    <xsl:value-of select="$rccontent/*/@id" />
                                                                </xsl:attribute>
																<xsl:value-of select="$ahrefcontent" />
															</a>
															<xsl:text>&#160;</xsl:text>
															<i>
																<xsl:text>(</xsl:text>
																<xsl:choose>
																	<xsl:when test="matches($xflex,'^\d{4}')">
																		<xsl:call-template name="showDate">
																			<xsl:with-param name="date" select="$xflex" />
																		</xsl:call-template>
																	</xsl:when>
																	<xsl:otherwise>
																		<xsl:call-template name="getMessage">
																			<xsl:with-param name="key" select="'associationDYNAMIC'" />
																		</xsl:call-template>
																	</xsl:otherwise>
																</xsl:choose>
																<xsl:text>)</xsl:text>
															</i>
															<xsl:if test="position()!=last()">
																<br />
															</xsl:if>
														</xsl:for-each>
													</td>
												</tr>
											</xsl:for-each>
										</xsl:for-each>
									</table>
								</td>
							</tr>
						</table>
					</xsl:for-each>
				</div>
			</xsl:variable>
			<xsl:call-template name="doTabs4ThisTab">
				<xsl:with-param name="actualtab" select="'tabScenarios'" />
				<xsl:with-param name="actualcontent" select="$content4" />
			</xsl:call-template>

			<xsl:call-template name="logMessage">
				<xsl:with-param name="level" select="$logDEBUG" />
				<xsl:with-param name="msg">
					<xsl:text>*** Creating SVG</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
			<!-- Write functional and technical SVGs. Could not do this inside the variable because older versions of Saxon do not support switching output from within a variable -->
			<xsl:for-each select="$allSvg/transaction">
				<xsl:if test="*[1]">
					<xsl:result-document method="xml" output-version="1.0" indent="yes" href="{$theHtmlDir}tg-{@id}_functional.svg">
						<xsl:copy-of select="*[1]" copy-namespaces="no" />
					</xsl:result-document>
				</xsl:if>
				<xsl:if test="*[2]">
					<xsl:result-document method="xml" output-version="1.0" indent="yes" href="{$theHtmlDir}tg-{@id}_technical.svg">
						<xsl:copy-of select="*[2]" copy-namespaces="no" />
					</xsl:result-document>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>

	<xsl:template name="doDatasetsTab">
		<xsl:if test="//datasets/dataset">
			<!-- a little milestoning -->
			<xsl:call-template name="logMessage">
				<xsl:with-param name="level" select="$logINFO" />
				<xsl:with-param name="msg">
					<xsl:text>*** Creating HTML For Data Sets Tab</xsl:text>
				</xsl:with-param>
			</xsl:call-template>

			<xsl:variable name="content3">
				<div class="TabbedPanelsContent">
					<h2>
						<a name="labelDataSets">
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'tabDataSetsTitleString'" />
							</xsl:call-template>
						</a>
					</h2>
					<xsl:choose>
						<xsl:when test="count(//datasets)=0">
							<table border="0">
								<xsl:call-template name="doMessage">
									<xsl:with-param name="level" select="'info'" />
									<xsl:with-param name="msg">
										<xsl:call-template name="getMessage">
											<xsl:with-param name="key" select="'issueNoDataSetsDefinedYet'" />
										</xsl:call-template>
									</xsl:with-param>
								</xsl:call-template>
							</table>
						</xsl:when>
						<xsl:otherwise>
							<table width="100%">
								<thead>
									<tr>
										<th>XML</th>
										<th>
											<xsl:call-template name="getMessage">
												<xsl:with-param name="key" select="'columnAllView'" />
											</xsl:call-template>
										</th>
										<th>
											<xsl:call-template name="getMessage">
												<xsl:with-param name="key" select="'columnCareView'" />
											</xsl:call-template>
										</th>
										<th>
											<xsl:call-template name="getMessage">
												<xsl:with-param name="key" select="'columnName'" />
											</xsl:call-template>
										</th>
										<th>
											<xsl:call-template name="getMessage">
												<xsl:with-param name="key" select="'effectiveDate'" />
											</xsl:call-template>
										</th>
										<th>
											<xsl:call-template name="getMessage">
												<xsl:with-param name="key" select="'expirationDate'" />
											</xsl:call-template>
										</th>
										<th>
											<xsl:call-template name="getMessage">
												<xsl:with-param name="key" select="'columnStatus'" />
											</xsl:call-template>
										</th>
										<th>
											<xsl:call-template name="getMessage">
												<xsl:with-param name="key" select="'columnVersionLabel'" />
											</xsl:call-template>
										</th>
									</tr>
								</thead>
								<tbody>
									<xsl:for-each select="//datasets/dataset">
										<xsl:sort select="@effectiveDate" order="descending" />

										<tr style="background-color:#f6f3ee" onMouseover="this.style.backgroundColor='lightblue';" onMouseout="this.style.backgroundColor='#f6f3ee';">
											<td>
												<xsl:if test="$projectRestURIs[@for='DS'][@format='HTML']">
													<a href="ovds-{@id}.xml">xml</a>
												</xsl:if>
											</td>
											<td>
												<a href="ds-{@id}.html">html</a>
											</td>
											<td>
												<xsl:if test="$projectRestURIs[@for='DS'][@format='HTML']">
													<a href="ovds-{@id}.html">html</a>
												</xsl:if>
											</td>
											<td>
												<xsl:call-template name="doName">
													<xsl:with-param name="ns" select="name" />
												</xsl:call-template>
											</td>
											<td>
												<xsl:call-template name="showDate">
													<xsl:with-param name="date" select="@effectiveDate" />
												</xsl:call-template>
											</td>
											<td>
												<xsl:call-template name="showDate">
													<xsl:with-param name="date" select="@expirationDate" />
												</xsl:call-template>
											</td>
											<td align="center">
												<xsl:variable name="theStatus">
													<xsl:choose>
														<xsl:when test="@statusCode">
															<xsl:value-of select="@statusCode" />
														</xsl:when>
														<xsl:otherwise>
															<xsl:variable name="ndcount" select="count(.//concept[@statusCode='new' or @statusCode='draft'])" />
															<xsl:choose>
																<xsl:when test="$ndcount>0">
																	<xsl:text>draft</xsl:text>
																</xsl:when>
																<xsl:otherwise>
																	<xsl:text>final</xsl:text>
																</xsl:otherwise>
															</xsl:choose>
															<!-- if any item is new draft - > data set is draft if any item is rejected cancelled deprecated - > data set is final otherwise the data set is final -->
														</xsl:otherwise>
													</xsl:choose>
												</xsl:variable>
												<xsl:call-template name="showStatusDot">
													<xsl:with-param name="status" select="$theStatus" />
												</xsl:call-template>
											</td>
											<td>
												<xsl:value-of select="@versionLabel" />
											</td>
										</tr>
									</xsl:for-each>
								</tbody>
							</table>
						</xsl:otherwise>
					</xsl:choose>


					<h2>
						<xsl:call-template name="getMessage">
							<xsl:with-param name="key" select="'dataSetDataSetsPerTransaction'" />
						</xsl:call-template>

					</h2>
					<xsl:choose>
						<xsl:when test="count(//scenarios/scenario//transaction[@model]/representingTemplate)=0">
							<table border="0">
								<xsl:call-template name="doMessage">
									<xsl:with-param name="level" select="'info'" />
									<xsl:with-param name="msg">
										<xsl:call-template name="getMessage">
											<xsl:with-param name="key" select="'issueNoTransactionsWithAnUnderlyingModelDefinedYet'" />
										</xsl:call-template>
									</xsl:with-param>
								</xsl:call-template>
							</table>
						</xsl:when>
						<xsl:otherwise>
							<table width="100%">
								<thead>
									<tr>
										<th>XML</th>
										<th>
											<xsl:call-template name="getMessage">
												<xsl:with-param name="key" select="'columnAllView'" />
											</xsl:call-template>
										</th>
										<th>
											<xsl:call-template name="getMessage">
												<xsl:with-param name="key" select="'columnCareView'" />
											</xsl:call-template>
										</th>
										<th>
											<xsl:call-template name="getMessage">
												<xsl:with-param name="key" select="'columnName'" />
											</xsl:call-template>
										</th>
										<!--<th> <xsl:call-template name="getMessage"> <xsl:with-param name="key" select="'effectiveDate'"/> </xsl:call-template> </th> -->
										<th>
											<xsl:call-template name="getMessage">
												<xsl:with-param name="key" select="'columnStatus'" />
											</xsl:call-template>
										</th>
										<th>
											<xsl:call-template name="getMessage">
												<xsl:with-param name="key" select="'columnVersionLabel'" />
											</xsl:call-template>
										</th>
										<th>
											<xsl:call-template name="getMessage">
												<xsl:with-param name="key" select="'columnScenario'" />
											</xsl:call-template>
										</th>
										<th>
											<xsl:call-template name="getMessage">
												<xsl:with-param name="key" select="'columnDataset'" />
											</xsl:call-template>
										</th>
									</tr>
								</thead>
								<tbody>
									<xsl:for-each select="//scenarios/scenario">
										<xsl:sort select="@effectiveDate" order="descending" />
										<xsl:text>&#10;&#10;</xsl:text>
										<xsl:variable name="scstatus" select="@statusCode" />
										<xsl:for-each select=".//transaction[@model][representingTemplate]">

											<xsl:variable name="trid" select="@id" />
											<!-- cache transaction/@effectiveDate. This is relatively new so might not be present -->
											<xsl:variable name="treff" select="@effectiveDate" />
											<xsl:variable name="dsid" select="representingTemplate/@sourceDataset" />
											<xsl:variable name="reptc" select="representingTemplate" />

											<!-- create the data set filtered with concept mentioned in the representingTemplate only -->
											<xsl:variable name="tmp1">
												<tmp>
													<xsl:for-each select="$allDatasets/dataset[@id=$dsid]">
														<xsl:apply-templates select="concept" mode="filter">
															<xsl:with-param name="representingTemplate" select="$reptc" />
														</xsl:apply-templates>
													</xsl:for-each>
												</tmp>
											</xsl:variable>

											<xsl:variable name="filtereddataset">
												<filtereddataset>
													<xsl:apply-templates select="$tmp1/tmp/concept" mode="eliminatedHiddenConcepts" />
												</filtereddataset>
											</xsl:variable>

											<xsl:variable name="fname" select="concat('dstr-', $trid, if (matches($treff,'^\d{4}')) then concat('-',replace($treff,':','')) else () )" />
											<tr style="background-color:#f6f3ee" onMouseover="this.style.backgroundColor='lightblue';" onMouseout="this.style.backgroundColor='#f6f3ee';">
												<td>
													<!-- Prevent link here so it saves the user pointless clicking into an HTML without content -->
													<xsl:if test="count($filtereddataset/filtereddataset/concept)>0 and count(representingTemplate/concept)>0">
														<xsl:if test="$projectRestURIs[@for='DS'][@format='HTML']">
															<a href="ovtr-{@id}.xml">xml</a>
														</xsl:if>
													</xsl:if>
												</td>
												<!-- FIXME? the ProjectIndex has a different understanding of "All" than this link has... -->
												<td>
													<!-- Prevent link here so it saves the user pointless clicking into an HTML without content -->
													<xsl:if test="count($filtereddataset/filtereddataset/concept)>0 and count(representingTemplate/concept)>0">
														<a href="{$fname}.html">html</a>
													</xsl:if>
												</td>
												<!-- FIXME? the ProjectIndex offers 2 flavors of care view. We only offer one version here... -->
												<td>
													<!-- Prevent link here so it saves the user pointless clicking into an HTML without content -->
													<xsl:if test="count($filtereddataset/filtereddataset/concept)>0 and count(representingTemplate/concept)>0">
														<xsl:if test="$projectRestURIs[@for='DS'][@format='HTML']">
															<a href="ovtr-{@id}.html">html</a>
														</xsl:if>
													</xsl:if>
												</td>
												<td>
													<xsl:call-template name="doName">
														<xsl:with-param name="ns" select="name" />
													</xsl:call-template>
													<!-- Add this here so it saves the user pointless clicking into an HTML with the same notice -->
													<xsl:if test="count($filtereddataset/filtereddataset/concept)=0 or count(representingTemplate/concept)=0">
														<table border="0">
															<xsl:call-template name="doMessage">
																<xsl:with-param name="level" select="'info'" />
																<xsl:with-param name="msg">
																	<xsl:call-template name="getMessage">
																		<xsl:with-param name="key" select="'issueNoUnderlyingModelWithThisScenarioTransactionDefinedYet'" />
																	</xsl:call-template>
																</xsl:with-param>
															</xsl:call-template>
														</table>
													</xsl:if>
												</td>
												<!--<td> <xsl:call-template name="showDate"> <xsl:with-param name="date" select="@effectiveDate"/> </xsl:call-template> </td> -->
												<td align="center">
													<xsl:call-template name="showStatusDot">
														<xsl:with-param name="status" select="$scstatus" />
													</xsl:call-template>
												</td>
												<td>
													<xsl:value-of select="@versionLabel" />
												</td>
												<td>
													<xsl:call-template name="doName">
														<xsl:with-param name="ns" select="ancestor::scenario[1]/name" />
													</xsl:call-template>
												</td>
												<td>
													<xsl:call-template name="doName">
														<xsl:with-param name="ns" select="$allDatasets/dataset[@id=$dsid]/name" />
													</xsl:call-template>
												</td>
											</tr>

										</xsl:for-each>
									</xsl:for-each>
								</tbody>
							</table>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</xsl:variable>
			<xsl:call-template name="doTabs4ThisTab">
				<xsl:with-param name="actualtab" select="'tabDataSet'" />
				<xsl:with-param name="actualcontent" select="$content3" />
			</xsl:call-template>

			<!-- if rest URIs are defined show the overview page -->
			<xsl:if test="$projectRestURIs[@for='DS'][@format='HTML']">
				<xsl:variable name="restUriBase" select="substring-before($projectRestURIs[@for='DS'][1], '?')" />
				<!-- get and create all overview dataset representations -->
				<xsl:for-each select="//datasets/dataset">
					<xsl:sort select="@effectiveDate" order="descending" />
					<xsl:variable name="dsid" select="@id" />

					<!-- Use RetrieveTransaction to get the content -->
					<xsl:result-document href="{$theHtmlDir}ovds-{$dsid}.html" method="html">
						<xsl:variable name="theUri">
							<xsl:value-of select="$restUriBase" />
							<xsl:text>?id=</xsl:text>
							<xsl:value-of select="$dsid" />
							<xsl:text>&amp;language=</xsl:text>
							<xsl:value-of select="$defaultLanguage" />
							<xsl:if test="$useLatestDecorVersion">
								<xsl:text>&amp;version=</xsl:text>
								<xsl:value-of select="$latestVersion" />
							</xsl:if>
							<xsl:text>&amp;format=html</xsl:text>
							<xsl:text>&amp;hidecolumns=</xsl:text>
							<xsl:value-of select="$hideColumns" />
							<xsl:text>&amp;useLocalAssets=</xsl:text>
							<xsl:value-of select="$useLocalAssets" />
						</xsl:variable>
						<xsl:call-template name="logMessage">
							<xsl:with-param name="level" select="$logDEBUG" />
							<xsl:with-param name="msg">
								<xsl:text>*** HTML by calling: </xsl:text>
								<xsl:value-of select="iri-to-uri($theUri)" />
							</xsl:with-param>
						</xsl:call-template>
						<xsl:copy-of select="document($theUri)" />
					</xsl:result-document>
					<!-- Use RetrieveTransaction to get the content -->
					<xsl:result-document href="{$theHtmlDir}ovds-{$dsid}.xml" format="xml">
						<xsl:variable name="theUri">
							<xsl:value-of select="$restUriBase" />
							<xsl:text>?id=</xsl:text>
							<xsl:value-of select="$dsid" />
							<xsl:text>&amp;language=</xsl:text>
							<xsl:value-of select="$defaultLanguage" />
							<xsl:if test="$useLatestDecorVersion">
								<xsl:text>&amp;version=</xsl:text>
								<xsl:value-of select="$latestVersion" />
							</xsl:if>
							<xsl:text>&amp;format=xml</xsl:text>
							<xsl:text>&amp;hidecolumns=</xsl:text>
							<xsl:value-of select="$hideColumns" />
							<xsl:text>&amp;useLocalAssets=</xsl:text>
							<xsl:value-of select="$useLocalAssets" />
						</xsl:variable>
						<xsl:call-template name="logMessage">
							<xsl:with-param name="level" select="$logDEBUG" />
							<xsl:with-param name="msg">
								<xsl:text>*** XML by calling: </xsl:text>
								<xsl:value-of select="iri-to-uri($theUri)" />
							</xsl:with-param>
						</xsl:call-template>
						<xsl:copy-of select="document($theUri)" />
					</xsl:result-document>
				</xsl:for-each>

				<!-- get and create all overview transaction representations -->
				<xsl:for-each select="//transaction[representingTemplate]">
					<xsl:variable name="trid" select="@id" />

					<!-- Write the static variant for include/contains with static flexibility -->
					<xsl:result-document href="{$theHtmlDir}ovtr-{$trid}.html" method="html">
						<xsl:variable name="theUri">
							<xsl:value-of select="$restUriBase" />
							<xsl:text>?id=</xsl:text>
							<xsl:value-of select="$trid" />
							<xsl:text>&amp;language=</xsl:text>
							<xsl:value-of select="$defaultLanguage" />
							<xsl:if test="$useLatestDecorVersion">
								<xsl:text>&amp;version=</xsl:text>
								<xsl:value-of select="$latestVersion" />
							</xsl:if>
							<xsl:text>&amp;format=html&amp;hidecolumns=</xsl:text>
							<xsl:value-of select="$hideColumns" />
							<xsl:text>&amp;useLocalAssets=</xsl:text>
							<xsl:value-of select="$useLocalAssets" />
						</xsl:variable>
						<xsl:call-template name="logMessage">
							<xsl:with-param name="level" select="$logDEBUG" />
							<xsl:with-param name="msg">
								<xsl:text>*** HTML by calling: </xsl:text>
								<xsl:value-of select="iri-to-uri($theUri)" />
							</xsl:with-param>
						</xsl:call-template>
						<xsl:copy-of select="document($theUri)" />
					</xsl:result-document>
					<!-- Write the static variant for include/contains with static flexibility -->
					<xsl:result-document href="{$theHtmlDir}ovtr-{$trid}.xml" format="xml">
						<xsl:variable name="theUri">
							<xsl:value-of select="$restUriBase" />
							<xsl:text>?id=</xsl:text>
							<xsl:value-of select="$trid" />
							<xsl:text>&amp;language=</xsl:text>
							<xsl:value-of select="$defaultLanguage" />
							<xsl:if test="$useLatestDecorVersion">
								<xsl:text>&amp;version=</xsl:text>
								<xsl:value-of select="$latestVersion" />
							</xsl:if>
							<xsl:text>&amp;format=xml&amp;hidecolumns=</xsl:text>
							<xsl:value-of select="$hideColumns" />
							<xsl:text>&amp;useLocalAssets=</xsl:text>
							<xsl:value-of select="$useLocalAssets" />
						</xsl:variable>
						<xsl:call-template name="logMessage">
							<xsl:with-param name="level" select="$logDEBUG" />
							<xsl:with-param name="msg">
								<xsl:text>*** XML by calling: </xsl:text>
								<xsl:value-of select="iri-to-uri($theUri)" />
							</xsl:with-param>
						</xsl:call-template>
						<xsl:copy-of select="document($theUri)" />
					</xsl:result-document>
				</xsl:for-each>
			</xsl:if>

			<!-- create all dataset html representations -->
			<xsl:for-each select="//datasets/dataset">
				<xsl:sort select="@effectiveDate" order="descending" />
				<xsl:variable name="dsid" select="@id" />

				<xsl:call-template name="logMessage">
					<xsl:with-param name="level" select="$logDEBUG" />
					<xsl:with-param name="msg">
						<xsl:text>*** HTML for dataset: name='</xsl:text>
						<xsl:value-of select="name[1]" />
						<xsl:text>' id='</xsl:text>
						<xsl:value-of select="$dsid" />
						<xsl:text>'</xsl:text>
					</xsl:with-param>
				</xsl:call-template>

				<!-- Write the static variant for include/contains with static flexibility -->
				<xsl:result-document href="{$theHtmlDir}ds-{$dsid}.html" method="html">
					<html>
						<xsl:text>&#10;&#10;</xsl:text>
						<head>
							<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
							<title>
								<xsl:call-template name="getMessage">
									<xsl:with-param name="key" select="'Dataset'" />
								</xsl:call-template>
								<xsl:text> </xsl:text>
								<xsl:value-of select="@id" />
								<xsl:text> - </xsl:text>
								<xsl:call-template name="doName">
									<xsl:with-param name="ns" select="name" />
									<!--<xsl:with-param name="lang" select="$defaultLanguage"/> -->
								</xsl:call-template>
							</title>

							<xsl:call-template name="addAssetsHeader" />
							<!--link href="{$theAssetsDir}decor.css" rel="stylesheet" type="text/css"/ -->

						</head>
						<xsl:text>&#10;&#10;</xsl:text>
						<body>
							<div class="indexline">
								<a href="index.html">
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'backToIndex'" />
									</xsl:call-template>
								</a>
								<xsl:text> &#160;&lt;&lt;&#160; </xsl:text>
								<a href="dataset.html">
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'backToDatasets'" />
									</xsl:call-template>
								</a>
							</div>
							<h1>
								<xsl:call-template name="showStatusDot">
									<xsl:with-param name="status" select="@statusCode" />
								</xsl:call-template>
								<xsl:text>&#160;</xsl:text>
								<xsl:call-template name="getMessage">
									<xsl:with-param name="key" select="'Dataset'" />
								</xsl:call-template>
								<xsl:text> </xsl:text>
								<xsl:value-of select="$dsid" />
								<xsl:text>&#160;</xsl:text>
								<i>
									<xsl:call-template name="doName">
										<xsl:with-param name="ns" select="name" />
										<!--<xsl:with-param name="lang" select="$defaultLanguage"/> -->
									</xsl:call-template>
								</i>

							</h1>
							<h2>
								<xsl:call-template name="showDate">
									<xsl:with-param name="date" select="@effectiveDate" />
								</xsl:call-template>
							</h2>
							<table border="0" cellspacing="2" cellpadding="2">
								<tr valign="top">
									<td class="tabtab">

										<xsl:call-template name="doDataset">
											<xsl:with-param name="nestingWithTables" select="true()" />
										</xsl:call-template>

									</td>
								</tr>
							</table>
							<xsl:call-template name="addAssetsBottom" />
						</body>
					</html>
				</xsl:result-document>
			</xsl:for-each>

			<!-- create all scenario html representations from a dataset view -->
			<xsl:for-each select="//scenarios/scenario">
				<xsl:sort select="@effectiveDate" order="descending" />
				<xsl:text>&#10;&#10;</xsl:text>
				<xsl:variable name="scstatus" select="@statusCode" />
				<xsl:for-each select=".//transaction[@model][representingTemplate]">

					<xsl:variable name="trid" select="@id" />
					<!-- cache transaction/@effectiveDate. This is relatively new so might not be present -->
					<xsl:variable name="treff" select="@effectiveDate" />
					<xsl:variable name="dsid" select="representingTemplate/@sourceDataset" />
					<xsl:variable name="dsname" select="//dataset[@id=$dsid]/name" />
					<xsl:variable name="reptc" select="representingTemplate" />

					<!-- create the data set filtered with concept mentioned in the representingTemplate only -->
					<xsl:variable name="tmp1">
						<tmp>
							<xsl:for-each select="$allDatasets/dataset[@id=$dsid]">
								<xsl:apply-templates select="concept" mode="filter">
									<xsl:with-param name="representingTemplate" select="$reptc" />
								</xsl:apply-templates>
							</xsl:for-each>
						</tmp>
					</xsl:variable>

					<xsl:variable name="filtereddataset">
						<filtereddataset>
							<xsl:apply-templates select="$tmp1/tmp/concept" mode="eliminatedHiddenConcepts" />
						</filtereddataset>
					</xsl:variable>

					<xsl:variable name="fname" select="concat('dstr-', $trid, if (matches($treff,'^\d{4}')) then concat('-',replace($treff,':','')) else () )" />

					<xsl:call-template name="logMessage">
						<xsl:with-param name="level" select="$logDEBUG" />
						<xsl:with-param name="msg">
							<xsl:text>*** HTML for dataset based on transaction: name='</xsl:text>
							<xsl:value-of select="name[1]" />
							<xsl:text>' id='</xsl:text>
							<xsl:value-of select="$trid" />
							<xsl:text>' effectiveDate='</xsl:text>
							<xsl:value-of select="$treff" />
							<xsl:text>' dataset name='</xsl:text>
							<xsl:value-of select="$dsname" />
							<xsl:text>' id='</xsl:text>
							<xsl:value-of select="$dsid" />
							<xsl:text>'</xsl:text>
						</xsl:with-param>
					</xsl:call-template>

					<!-- Write the static variant for include/contains with static flexibility -->
					<xsl:result-document href="{$theHtmlDir}{$fname}.html" method="html">
						<html>
							<xsl:text>&#10;&#10;</xsl:text>
							<head>
								<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
								<title>
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'dataSetDataSetForTransaction'" />
									</xsl:call-template>
									<xsl:text> </xsl:text>
									<xsl:value-of select="@id" />
									<xsl:text> - </xsl:text>
									<xsl:call-template name="doName">
										<xsl:with-param name="ns" select="name" />
										<!--<xsl:with-param name="lang" select="$defaultLanguage"/> -->
									</xsl:call-template>
								</title>

								<xsl:call-template name="addAssetsHeader" />
								<!--link href="{$theAssetsDir}decor.css" rel="stylesheet" type="text/css"/ -->

							</head>
							<xsl:text>&#10;&#10;</xsl:text>
							<body>
								<div class="indexline">
									<a href="index.html">
										<xsl:call-template name="getMessage">
											<xsl:with-param name="key" select="'backToIndex'" />
										</xsl:call-template>
									</a>
									<xsl:text> &#160;&lt;&lt;&#160; </xsl:text>
									<a href="scenarios.html">
										<xsl:call-template name="getMessage">
											<xsl:with-param name="key" select="'backToScenarios'" />
										</xsl:call-template>
									</a>
								</div>
								<h1>
									<xsl:call-template name="showStatusDot">
										<xsl:with-param name="status" select="@statusCode" />
									</xsl:call-template>
									<xsl:text>&#160;</xsl:text>
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'Transaction'" />
									</xsl:call-template>
									<xsl:text> </xsl:text>
									<xsl:value-of select="$trid" />
									<xsl:text>&#160;</xsl:text>
									<i>
										<xsl:call-template name="doName">
											<xsl:with-param name="ns" select="name" />
											<!--<xsl:with-param name="lang" select="$defaultLanguage"/> -->
										</xsl:call-template>
									</i>
								</h1>
								<h2>
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'Dataset'" />
									</xsl:call-template>
									<xsl:text> </xsl:text>
									<xsl:value-of select="$dsid" />
									<xsl:text>&#160;</xsl:text>
									<i>
										<xsl:call-template name="doName">
											<xsl:with-param name="ns" select="$dsname" />
											<!--<xsl:with-param name="lang" select="$defaultLanguage"/> -->
										</xsl:call-template>
									</i>
								</h2>
								<xsl:choose>
									<xsl:when test="count($filtereddataset/filtereddataset/concept)=0 or count(representingTemplate/concept)=0">
										<table border="0">
											<xsl:call-template name="doMessage">
												<xsl:with-param name="level" select="'info'" />
												<xsl:with-param name="msg">
													<xsl:call-template name="getMessage">
														<xsl:with-param name="key" select="'issueNoUnderlyingModelWithThisScenarioTransactionDefinedYet'" />
													</xsl:call-template>
												</xsl:with-param>
											</xsl:call-template>
										</table>
									</xsl:when>
									<xsl:otherwise>

										<table width="100%" border="0" cellspacing="2" cellpadding="2">
											<tr valign="top">
												<td class="tabtab">
													<xsl:apply-templates select="$filtereddataset/filtereddataset/concept" mode="dataset">
														<xsl:with-param name="level" select="1" />
													</xsl:apply-templates>
												</td>
											</tr>
										</table>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:call-template name="addAssetsBottom" />
							</body>
						</html>
					</xsl:result-document>
				</xsl:for-each>

			</xsl:for-each>
		</xsl:if>
	</xsl:template>

	<xsl:template name="doIdentificationTab">
		<xsl:if test="//ids/id">
			<!-- a little milestoning -->
			<xsl:call-template name="logMessage">
				<xsl:with-param name="level" select="$logINFO" />
				<xsl:with-param name="msg">
					<xsl:text>*** Creating HTML For Identifiers Tab</xsl:text>
				</xsl:with-param>
			</xsl:call-template>

			<xsl:variable name="content4b">
				<div class="TabbedPanelsContent">
					<xsl:call-template name="doIdentifiers" />
				</div>
			</xsl:variable>
			<xsl:call-template name="doTabs4ThisTab">
				<xsl:with-param name="actualtab" select="'tabIdentifiers'" />
				<xsl:with-param name="actualcontent" select="$content4b" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template name="doTerminologyTab">
		<xsl:if test="//terminology/*">
			<!-- a little milestoning -->
			<xsl:call-template name="logMessage">
				<xsl:with-param name="level" select="$logINFO" />
				<xsl:with-param name="msg">
					<xsl:text>*** Creating HTML For Terminology Tab</xsl:text>
				</xsl:with-param>
			</xsl:call-template>

			<xsl:variable name="content5">
				<div class="TabbedPanelsContent">
					<h2>
						<xsl:call-template name="getMessage">
							<xsl:with-param name="key" select="'tabTerminologyTitleString'" />
						</xsl:call-template>
					</h2>
					<div id="Accordionvs" class="Accordion" tabindex="0">
						<xsl:if test="count(//terminology)=0">
							<table border="0">
								<xsl:call-template name="doMessage">
									<xsl:with-param name="level" select="'info'" />
									<xsl:with-param name="msg">
										<xsl:call-template name="getMessage">
											<xsl:with-param name="key" select="'issueNoCodesValueSetsDefinedYet'" />
										</xsl:call-template>
									</xsl:with-param>
								</xsl:call-template>
							</table>
						</xsl:if>
						<!-- only first value set of most recent version -->
						<xsl:for-each select="$allValueSets/*/valueSet[@id]">
							<xsl:sort select="@displayName"/>
							<xsl:variable name="vsname" select="@name" />
							<xsl:variable name="vsid" select="@id" />
							<xsl:text>&#10;&#10;</xsl:text>
							<div class="AccordionPanel">
								<div class="AccordionPanelTab">
									<h3 class="acco" onclick="toggleZoomImg(this,'zoomout','{$theAssetsDir}');">
										<xsl:call-template name="showStatusDot">
											<xsl:with-param name="status" select="@statusCode" />
										</xsl:call-template>
										<xsl:text>&#160;</xsl:text>
										<xsl:choose>
											<xsl:when test="string-length(@displayName)>0">
												<xsl:value-of select="@displayName" />
												<xsl:if test="@name and (@name != @displayName)">
													<i>
														<xsl:text> / </xsl:text>
														<xsl:value-of select="@name" />
													</i>
												</xsl:if>
											</xsl:when>
											<xsl:when test="string-length(@name)>0">
												<i>
													<xsl:value-of select="@name" />
												</i>
											</xsl:when>
											<xsl:otherwise>
												<xsl:call-template name="getMessage">
													<xsl:with-param name="key" select="'rulesNoNameOrDisplaynameDefinedYet'" />
												</xsl:call-template>
											</xsl:otherwise>
										</xsl:choose>
										<xsl:text>&#160;</xsl:text>
										<xsl:call-template name="showDate">
											<xsl:with-param name="date" select="@effectiveDate" />
										</xsl:call-template>
										<table border="0">
											<tr>
												<td class="comment">
													<xsl:call-template name="doDescription">
														<xsl:with-param name="ns" select="desc" />
														<xsl:with-param name="shortDesc" select="true()" />
													</xsl:call-template>
												</td>
											</tr>
										</table>
									</h3>
								</div>
								<div class="AccordionPanelContent">
									<xsl:apply-templates select="." />
								</div>
							</div>

						</xsl:for-each>
					</div>

					<!-- then show a summary of scenario table -->
					<h2>
						<a name="labelRules">
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'terminologySummary'" />
							</xsl:call-template>
						</a>
					</h2>
					<xsl:text>&#10;&#10;</xsl:text>
					<table width="50%" border="0" cellspacing="2" cellpadding="2">
						<tr valign="top">
							<td class="tabtab">
								<table width="100%" border="0" cellspacing="3" cellpadding="2">
									<tr bgcolor="#CCFFCC">
										<td>
											<xsl:call-template name="getMessage">
												<xsl:with-param name="key" select="'valueSets'" />
											</xsl:call-template>
										</td>
										<td colspan="2">
											<xsl:value-of select="count($allValueSets/*/valueSet[@id])" />
										</td>
									</tr>
									<tr bgcolor="#CCFFCC">
										<td>
											<xsl:call-template name="getMessage">
												<xsl:with-param name="key" select="'terminologyAssociations'" />
											</xsl:call-template>
										</td>
										<td colspan="2">
											<xsl:value-of select="count($allTerminologyAssociations/*/terminologyAssociation)" />
										</td>
									</tr>
								</table>
							</td>
						</tr>
					</table>
					<xsl:if test="count($dictionaries/dictionary)>0">
						<div id="Accordionrl" class="Accordion" tabindex="0">
							<h2>
								<xsl:call-template name="getMessage">
									<xsl:with-param name="key" select="'dictionariesHeader'"/>
								</xsl:call-template>
							</h2>
							<xsl:for-each select="$dictionaries/dictionary">
								<xsl:sort select="@title"/>			
								<div class="AccordionPanelTab">
									<h3 id="dictionary-{generate-id(.)}" class="acco" onclick="toggleZoomImg(this,'zoomout','{$theAssetsDir}');">
										<xsl:value-of select="@title" />
									</h3>
								</div>
								<div class="AccordionPanelContent">
									<xsl:apply-templates select="document(@src)/ClaML"/>
								</div>
							</xsl:for-each>
						</div>
					</xsl:if>
				</div>
			</xsl:variable>
			<xsl:call-template name="doTabs4ThisTab">
				<xsl:with-param name="actualtab" select="'tabTerminology'" />
				<xsl:with-param name="actualcontent" select="$content5" />
			</xsl:call-template>

			<!-- create all value set html representations -->
			<xsl:for-each-group select="$allValueSets/*/valueSet" group-by="concat((@id|@ref),'#',@effectiveDate)">
				<xsl:variable name="vsid" select="(@id|@ref)" />
				<xsl:variable name="vsnm" select="@name" />
				<xsl:variable name="vsed" select="@effectiveDate" />
				<xsl:variable name="vsIsNewest" select="$vsed=max($allValueSets/*/valueSet[(@id|@ref)=$vsid]/xs:dateTime(@effectiveDate))" />

				<xsl:call-template name="logMessage">
					<xsl:with-param name="level" select="$logDEBUG" />
					<xsl:with-param name="msg">
						<xsl:text>*** HTML for value set: name='</xsl:text>
						<xsl:value-of select="$vsnm" />
						<xsl:text>' id='</xsl:text>
						<xsl:value-of select="$vsid" />
						<xsl:text>' effectiveDate='</xsl:text>
						<xsl:value-of select="$vsed" />
						<xsl:text>'</xsl:text>
					</xsl:with-param>
				</xsl:call-template>

				<xsl:result-document href="{$theHtmlDir}voc-{$vsid}-{replace($vsed,':','')}.html" method="html">
					<html>
						<xsl:text>&#10;&#10;</xsl:text>
						<head>
							<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
							<title>
								<xsl:call-template name="getMessage">
									<xsl:with-param name="key" select="'terminologyValueSetHeader'" />
									<xsl:with-param name="p1" select="$vsnm" />
								</xsl:call-template>
							</title>

							<link href="{$theAssetsDir}decor.css" rel="stylesheet" type="text/css" />
							<link href="{$theAssetsDir}favicon.ico" rel="shortcut icon" type="image/x-icon" />

						</head>
						<xsl:text>&#10;&#10;</xsl:text>
						<body>
							<div class="indexline">
								<a href="index.html">
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'backToIndex'" />
									</xsl:call-template>
								</a>
								<xsl:text> &#160;&lt;&lt;&#160; </xsl:text>
								<a href="terminology.html">
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'backToTerminology'" />
									</xsl:call-template>
								</a>
							</div>
							<h1>
								<xsl:call-template name="showStatusDot">
									<xsl:with-param name="status" select="@statusCode" />
								</xsl:call-template>
								<xsl:text>&#160;</xsl:text>
								<xsl:call-template name="getMessage">
									<xsl:with-param name="key" select="'valueSet'" />
								</xsl:call-template>
								<xsl:text>&#160;</xsl:text>
								<xsl:value-of select="@name" />
								<xsl:if test="string-length(@displayName)>0 and (@name != @displayName)">
									<xsl:text>&#160;</xsl:text>
									<i>
										<xsl:value-of select="@displayName" />
									</i>
								</xsl:if>
								<xsl:text>&#160;</xsl:text>
								<xsl:call-template name="showDate">
									<xsl:with-param name="date" select="@effectiveDate" />
								</xsl:call-template>
								<table border="0">
									<tr>
										<td class="comment">
											<xsl:call-template name="doDescription">
												<xsl:with-param name="ns" select="desc" />
												<xsl:with-param name="shortDesc" select="true()" />
											</xsl:call-template>
										</td>
									</tr>
								</table>
							</h1>
							<table border="0">
								<tr>
									<td>
									</td>
									<td>
										<xsl:apply-templates select="." />
									</td>
								</tr>
							</table>
						</body>
					</html>
				</xsl:result-document>
				<xsl:if test="$vsIsNewest=true()">
					<xsl:result-document href="{$theHtmlDir}voc-{$vsid}-DYNAMIC.html" method="html">
						<meta http-equiv="refresh" content="0; URL=voc-{$vsid}-{replace($vsed,':','')}.html" />
						<meta name="robots" content="noindex, nofollow" />
						<meta http-equiv="expires" content="0" />
					</xsl:result-document>
				</xsl:if>
			</xsl:for-each-group>
		</xsl:if>
	</xsl:template>

	<xsl:template name="doRulesTab">
		<xsl:if test="//rules/*">
			<!-- a little milestoning -->
			<xsl:call-template name="logMessage">
				<xsl:with-param name="level" select="$logINFO" />
				<xsl:with-param name="msg">
					<xsl:text>*** Creating HTML For Rules/Templates Tab</xsl:text>
				</xsl:with-param>
			</xsl:call-template>

			<xsl:variable name="content6">
				<div class="TabbedPanelsContent">
					<div id="Accordionrl" class="Accordion" tabindex="0">
						<!-- show all templates that are a part of an representing template for an scenario transaction first -->
<!-- 						<h2> -->
<!-- 							<xsl:call-template name="getMessage"> -->
<!-- 								<xsl:with-param name="key" select="'tabRepresentingTemplatesString'" /> -->
<!-- 							</xsl:call-template> -->
<!-- 						</h2> -->
<!-- 						<xsl:for-each select="$allScenarios//representingTemplate"> -->
<!-- 							<xsl:sort select="replace(replace (concat(@id, '.'), '\.', '.0000000000'), '.0*([0-9]{9,})', '.$1')"/> -->

<!-- 							<xsl:variable name="rtid" select="@ref" /> -->
<!-- 							concat for backward compatibility -->
<!-- 							<xsl:variable name="theTemplate"> -->
<!-- 								<xsl:call-template name="getRulesetContent"> -->
<!-- 									<xsl:with-param name="ruleset" select="$rtid" /> -->
<!-- 									<xsl:with-param name="flexibility" select="@flexilibity" /> -->
<!-- 								</xsl:call-template> -->
<!-- 							</xsl:variable> -->
<!-- 							<xsl:variable name="theTransaction" select="parent::transaction" /> -->

<!-- 							<xsl:apply-templates select="$theTemplate" mode="showpreliminaries"> -->
<!-- 								submit also the underlying model of this template, drawn from the parent transaction's @model and the resulting rule name drawn from the parent transaction's @label for later display -->
<!-- 								<xsl:with-param name="underlyingModel" select="$theTransaction/@model" /> -->
<!-- 								<xsl:with-param name="resultingRule" select="$theTransaction/@label" /> -->
<!-- 								<xsl:with-param name="direction" select="$theTransaction/@type" /> -->
<!-- 							</xsl:apply-templates> -->
<!-- 						</xsl:for-each> -->

						<!-- then show all other templates -->
						<h2>
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'TemplatesTitle'" />
							</xsl:call-template>
						</h2>

						<!-- create a list of already shown template to not show them again -->
						<!-- TODO @flexibility -->
<!-- 						<xsl:variable name="alreadyShownTemplates"> -->
<!-- 							<xsl:for-each select="$allScenarios//representingTemplate"> -->
<!-- 								<xsl:text>&#160;</xsl:text> -->
<!-- 								<xsl:value-of select="@ref" /> -->
<!-- 								<xsl:text>&#160;</xsl:text> -->
<!-- 							</xsl:for-each> -->
<!-- 						</xsl:variable> -->
						<xsl:for-each select="$allTemplates/*/ref/template">
							<xsl:sort select="@displayName" />
							<!-- <xsl:sort select="replace(replace (concat(@id, '.'), '\.', '.0000000000'), '.0*([0-9]{9,})', '.$1')"/> do not sort by OID -->

<!-- 							<xsl:if test="not(contains($alreadyShownTemplates, @id))"> -->
								<xsl:apply-templates select="." mode="showpreliminaries" />
<!-- 							</xsl:if> -->

						</xsl:for-each>

						<!-- then show a summary of rules table -->
						<h2>
							<a name="labelRules">
								<xsl:call-template name="getMessage">
									<xsl:with-param name="key" select="'templateSummary'" />
								</xsl:call-template>
							</a>
						</h2>
						<xsl:text>&#10;&#10;</xsl:text>
						<table width="50%" border="0" cellspacing="2" cellpadding="2">
							<tr valign="top">
								<td class="tabtab">
									<table width="100%" border="0" cellspacing="3" cellpadding="2">
										<tr bgcolor="#CCFFCC">
											<td>
												<xsl:call-template name="getMessage">
													<xsl:with-param name="key" select="'templates'" />
												</xsl:call-template>
											</td>
											<td colspan="2">
												<xsl:value-of select="count($allTemplates/*/ref/template)" />
											</td>
										</tr>
										<!-- <tr bgcolor="#CCFFCC"> <td> <xsl:text>Schematron</xsl:text> </td> <td colspan="2"> <xsl:value-of select="count($allTemplates/*/ref/rule)"/> </td> </tr> -->
										<!--tr bgcolor="#CCFFCC"> <td> <xsl:call-template name="getMessage"> <xsl:with-param name="key" select="'templatesTotal'"/> </xsl:call-template> </td> <td colspan="2"> <xsl:value-of select="count($allTemplates/*/ref/template)"/> 
											</td> </tr -->
									</table>
								</td>
							</tr>
						</table>

						<!-- create rule lists per scenario x -->
<!-- 						<h2> -->
<!-- 							<a name="labelRules"> -->
<!-- 								<xsl:call-template name="getMessage"> -->
<!-- 									<xsl:with-param name="key" select="'templatesPerScenario'" /> -->
<!-- 								</xsl:call-template> -->
<!-- 							</a> -->
<!-- 						</h2> -->
<!-- 						<xsl:for-each select="$allScenarios/scenarios/scenario"> -->
<!-- 							<xsl:variable name="scenarioname"> -->
<!-- 								<xsl:value-of select="@id" /> -->
<!-- 								xsl:if test="@displayName"> <xsl:text>&#160;</xsl:text> <i> <xsl:value-of select="@displayName"/> </i> </xsl:if -->
<!-- 								<xsl:text>&#160;</xsl:text> -->
<!-- 								<xsl:call-template name="getMessage"> -->
<!-- 									<xsl:with-param name="key" select="'xAsOfy'" /> -->
<!-- 								</xsl:call-template> -->
<!-- 								<xsl:call-template name="showDate"> -->
<!-- 									<xsl:with-param name="date" select="@effectiveDate" /> -->
<!-- 								</xsl:call-template> -->
<!-- 							</xsl:variable> -->
<!-- 							<h3> -->
<!-- 								<xsl:call-template name="getMessage"> -->
<!-- 									<xsl:with-param name="key" select="'templatesForScenario'" /> -->
<!-- 								</xsl:call-template> -->
<!-- 								<i> -->
<!-- 									<xsl:value-of select="$scenarioname" /> -->
<!-- 								</i> -->
<!-- 							</h3> -->
<!-- 							<table width="50%" border="0" cellspacing="2" cellpadding="2"> -->
<!-- 								<tr valign="top"> -->
<!-- 									<td class="tabtab"> -->
<!-- 										<table width="100%" border="0" cellspacing="3" cellpadding="2"> -->
<!-- 											<tr> -->
<!-- 												<th> -->
<!-- 													<xsl:call-template name="getMessage"> -->
<!-- 														<xsl:with-param name="key" select="'representingTemplate'" /> -->
<!-- 													</xsl:call-template> -->
<!-- 												</th> -->
<!-- 												<th> -->
<!-- 													<xsl:call-template name="getMessage"> -->
<!-- 														<xsl:with-param name="key" select="'Link'" /> -->
<!-- 													</xsl:call-template> -->
<!-- 												</th> -->
<!-- 												<th> -->
<!-- 													<xsl:call-template name="getMessage"> -->
<!-- 														<xsl:with-param name="key" select="'xAsOfy'" /> -->
<!-- 													</xsl:call-template> -->
<!-- 												</th> -->
<!-- 											</tr> -->
<!-- 											<xsl:for-each select=".//representingTemplate"> -->
<!-- 												<xsl:variable name="rid" select="@ref" /> -->
<!-- 												<xsl:variable name="xflex" select="if (@flexilibity) then (@flexilibity) else ('dynamic')" /> -->
<!-- 												<xsl:variable name="rccontent"> -->
<!-- 													<xsl:call-template name="getRulesetContent"> -->
<!-- 														<xsl:with-param name="ruleset" select="$rid" /> -->
<!-- 														<xsl:with-param name="flexibility" select="$xflex" /> -->
<!-- 													</xsl:call-template> -->
<!-- 												</xsl:variable> -->
<!-- 												<xsl:variable name="tmpname"> -->
<!-- 													<xsl:choose> -->
<!-- 														<xsl:when test="$xflex='dynamic'"> -->
<!-- 															<xsl:value-of select="concat('tmp-',$rccontent/template/@id,'-DYNAMIC.html')" /> -->
<!-- 														</xsl:when> -->
<!-- 														<xsl:otherwise> -->
<!-- 															<xsl:value-of select="concat('tmp-',$rccontent/template/@id,'-',replace($xflex,':',''),'.html')" /> -->
<!-- 														</xsl:otherwise> -->
<!-- 													</xsl:choose> -->
<!-- 												</xsl:variable> -->
<!-- 												<xsl:variable name="rttdn"> -->
<!-- 													<xsl:choose> -->
<!-- 														<xsl:when test="string-length($rccontent/template/@displayName)>0"> -->
<!-- 															<xsl:value-of select="$rccontent/template/@displayName" /> -->
<!-- 														</xsl:when> -->
<!-- 														<xsl:otherwise> -->
<!-- 															<xsl:value-of select="$rccontent/template/@name" /> -->
<!-- 														</xsl:otherwise> -->
<!-- 													</xsl:choose> -->
<!-- 												</xsl:variable> -->
<!-- 												<xsl:variable name="rtted" select="$rccontent/template/@effectiveDate" /> -->

<!-- 												<tr> -->
<!-- 													<td align="left"> -->
<!-- 														<xsl:call-template name="doShorthandId"> -->
<!-- 															<xsl:with-param name="id" select="$rid" /> -->
<!-- 														</xsl:call-template> -->
<!-- 													</td> -->
<!-- 													<xsl:choose> -->
<!-- 														<xsl:when test="string-length($rttdn)>0"> -->
<!-- 															<td align="left"> -->
<!-- 																<a href="{$tmpname}" target="_blank"> -->
<!-- 																	<xsl:value-of select="$rttdn" /> -->
<!-- 																</a> -->
<!-- 															</td> -->
<!-- 															<td align="left"> -->
<!-- 																<xsl:call-template name="showDate"> -->
<!-- 																	<xsl:with-param name="date" select="$rtted" /> -->
<!-- 																</xsl:call-template> -->
<!-- 															</td> -->
<!-- 														</xsl:when> -->
<!-- 														<xsl:otherwise> -->
<!-- 															<td align="left" colspan="2"> -->
<!-- 																<xsl:call-template name="getMessage"> -->
<!-- 																	<xsl:with-param name="key" select="'ruleNotDefinedYet'" /> -->
<!-- 																</xsl:call-template> -->
<!-- 															</td> -->
<!-- 														</xsl:otherwise> -->
<!-- 													</xsl:choose> -->
<!-- 												</tr> -->
<!-- 											</xsl:for-each> -->
<!-- 										</table> -->
<!-- 									</td> -->
<!-- 								</tr> -->
<!-- 							</table> -->
<!-- 						</xsl:for-each> -->

<!-- 						create list of item labels in templates -->
<!-- 						<h2> -->
<!-- 							<xsl:call-template name="getMessage"> -->
<!-- 								<xsl:with-param name="key" select="'itemLabelsPerTemplate'" /> -->
<!-- 							</xsl:call-template> -->
<!-- 						</h2> -->
<!-- 						get all item labels in all registered templates and cache them -->
<!-- 						<xsl:variable name="allitemlabels"> -->
<!-- 							<labels> -->
<!-- 								<xsl:for-each select="$allTemplates/*/ref/template"> -->
<!-- 									<xsl:variable name="tid" select="@id" /> -->
<!-- 									<xsl:variable name="ted" select="@effectiveDate" /> -->
<!-- 									<xsl:variable name="tdn"> -->
<!-- 										<xsl:choose> -->
<!-- 											<xsl:when test="string-length(@displayName)>0"> -->
<!-- 												<xsl:value-of select="@displayName" /> -->
<!-- 											</xsl:when> -->
<!-- 											<xsl:otherwise> -->
<!-- 												<xsl:value-of select="@name" /> -->
<!-- 											</xsl:otherwise> -->
<!-- 										</xsl:choose> -->
<!-- 									</xsl:variable> -->
<!-- 									<xsl:for-each select=".//item[@label]"> -->
<!-- 										<label> -->
<!-- 											<xsl:attribute name="label"> -->
<!--                                                 <xsl:value-of select="@label" /> -->

<!--                                             </xsl:attribute> -->
<!-- 											<xsl:attribute name="tid"> -->
<!--                                                 <xsl:value-of select="$tid" /> -->
<!--                                             </xsl:attribute> -->
<!-- 											<xsl:attribute name="ted"> -->
<!--                                                 <xsl:value-of select="$ted" /> -->
<!--                                             </xsl:attribute> -->
<!-- 											<xsl:attribute name="tdn"> -->
<!--                                                 <xsl:value-of select="$tdn" /> -->
<!--                                             </xsl:attribute> -->
<!-- 										</label> -->
<!-- 									</xsl:for-each> -->
<!-- 								</xsl:for-each> -->
<!-- 							</labels> -->
<!-- 						</xsl:variable> -->
<!-- 						<xsl:text>&#10;&#10;</xsl:text> -->
<!-- 						<table width="50%" border="0" cellspacing="2" cellpadding="2"> -->
<!-- 							<tr valign="top"> -->
<!-- 								<td class="tabtab"> -->
<!-- 									<table width="100%" border="0" cellspacing="3" cellpadding="2"> -->
<!-- 										<tr> -->
<!-- 											<th> -->
<!-- 												<xsl:call-template name="getMessage"> -->
<!-- 													<xsl:with-param name="key" select="'itemReference'" /> -->
<!-- 												</xsl:call-template> -->
<!-- 											</th> -->
<!-- 											<th colspan="2"> -->
<!-- 												<xsl:call-template name="getMessage"> -->
<!-- 													<xsl:with-param name="key" select="'templateId'" /> -->
<!-- 												</xsl:call-template> -->
<!-- 											</th> -->
<!-- 											<th> -->
<!-- 												<xsl:call-template name="getMessage"> -->
<!-- 													<xsl:with-param name="key" select="'RuleName'" /> -->
<!-- 												</xsl:call-template> -->
<!-- 											</th> -->
<!-- 											<th> -->
<!-- 												<xsl:call-template name="getMessage"> -->
<!-- 													<xsl:with-param name="key" select="'Link'" /> -->
<!-- 												</xsl:call-template> -->
<!-- 											</th> -->
<!-- 											<th> -->
<!-- 												<xsl:call-template name="getMessage"> -->
<!-- 													<xsl:with-param name="key" select="'xAsOfy'" /> -->
<!-- 												</xsl:call-template> -->
<!-- 											</th> -->
<!-- 										</tr> -->
<!-- 										<xsl:for-each select="$allitemlabels/*/label"> -->
<!-- 											<xsl:sort select="@label" /> -->
<!-- 											<tr> -->
<!-- 												<td align="left"> -->
<!-- 													<xsl:value-of select="replace(string(@label), '-', '&#8209;')" /> -->
<!-- 												</td> -->
<!-- 												<td align="left"> -->
<!-- 													<xsl:call-template name="showIcon"> -->
<!-- 														<xsl:with-param name="which"> -->
<!-- 															link11 -->
<!-- 														</xsl:with-param> -->
<!-- 													</xsl:call-template> -->
<!-- 												</td> -->
<!-- 												<td align="left"> -->
<!-- 													<xsl:call-template name="doShorthandId"> -->
<!-- 														<xsl:with-param name="id" select="@tid" /> -->
<!-- 													</xsl:call-template> -->
<!-- 												</td> -->
<!-- 												<td align="left"> -->
<!-- 													<i> -->
<!-- 														<xsl:value-of select="@tdn" /> -->
<!-- 													</i> -->
<!-- 												</td> -->
<!-- 												<td align="left"> -->
<!-- 													<a href="tmp-{@tid}-DYNAMIC.html" target="_blank"> -->
<!-- 														<xsl:value-of select="@tid" /> -->
<!-- 													</a> -->
<!-- 												</td> -->
<!-- 												<td align="left"> -->
<!-- 													<xsl:call-template name="showDate"> -->
<!-- 														<xsl:with-param name="date" select="@ted" /> -->
<!-- 													</xsl:call-template> -->
<!-- 												</td> -->
<!-- 											</tr> -->
<!-- 										</xsl:for-each> -->
<!-- 									</table> -->
<!-- 								</td> -->
<!-- 							</tr> -->
<!-- 						</table> -->
					</div>
				</div>
			</xsl:variable>
			<xsl:call-template name="doTabs4ThisTab">
				<xsl:with-param name="actualtab" select="'tabRules'" />
				<xsl:with-param name="actualcontent" select="$content6" />
			</xsl:call-template>

			<!-- create all template html representations, all 4 have the exact same contents, they are just written for referencing -->
			<xsl:for-each select="$allTemplates/*/ref/template">
				<xsl:variable name="tid" select="@id" />
				<xsl:variable name="tnm" select="@name" />
				<xsl:variable name="ted" select="@effectiveDate" />

				<xsl:call-template name="logMessage">
					<xsl:with-param name="level" select="$logDEBUG" />
					<xsl:with-param name="msg">
						<xsl:text>*** HTML for template: name='</xsl:text>
						<xsl:value-of select="$tnm" />
						<xsl:text>' id='</xsl:text>
						<xsl:value-of select="$tid" />
						<xsl:text>' effectiveDate='</xsl:text>
						<xsl:value-of select="$ted" />
						<xsl:text>'</xsl:text>
					</xsl:with-param>
				</xsl:call-template>

				<!-- Write the static variant for include/contains with static flexibility -->
				<xsl:result-document href="{$theHtmlDir}tmp-{$tid}-{replace(@effectiveDate,':','')}.html" method="html">
					<html>
						<xsl:text>&#10;&#10;</xsl:text>
						<head>
							<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
							<title>
								<xsl:call-template name="getMessage">
									<xsl:with-param name="key" select="'Template'" />
								</xsl:call-template>
								<xsl:value-of select="concat(@id, ' - ', @name)" />
							</title>

							<xsl:call-template name="addAssetsHeader" />
							<!--link href="{$theAssetsDir}decor.css" rel="stylesheet" type="text/css"/ -->

						</head>
						<xsl:text>&#10;&#10;</xsl:text>
						<body>
							<div class="indexline">
								<a href="index.html">
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'backToIndex'" />
									</xsl:call-template>
								</a>
								<xsl:text> &#160;&lt;&lt;&#160; </xsl:text>
								<a href="rules.html">
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'backToRules'" />
									</xsl:call-template>
								</a>
							</div>
							<h1>
								<xsl:call-template name="showStatusDot">
									<xsl:with-param name="status" select="@statusCode" />
								</xsl:call-template>
								<xsl:text>&#160;</xsl:text>
								<xsl:call-template name="getMessage">
									<xsl:with-param name="key" select="'Template'" />
								</xsl:call-template>
								<!--xsl:value-of select="$tid"/ -->
								<!--xsl:if test="string-length(@displayName)>0 and (@name != @displayName)" -->
								<xsl:text>&#160;</xsl:text>
								<i>
									<xsl:value-of select="if (string-length(@displayName)>0) then (@displayName) else (@name)" />
								</i>
								<!--/xsl:if -->
							</h1>
							<!--h2> <xsl:call-template name="showDate"> <xsl:with-param name="date" select="@effectiveDate"/> </xsl:call-template> </h2 -->
							<table width="100%" border="0">
								<tr>
									<td class="tabtab">
										<xsl:apply-templates select=".">
											<xsl:with-param name="templatename" select="concat(@id, ' - ', @name)" />
										</xsl:apply-templates>
									</td>
								</tr>
							</table>

							<xsl:call-template name="addAssetsBottom" />
						</body>
					</html>
				</xsl:result-document>
				<!-- Write the whole thing again in a 'DYNAMIC' file for references in include/contains -->
				<xsl:if test="../@newestForId=true()">
					<xsl:result-document href="{$theHtmlDir}tmp-{$tid}-DYNAMIC.html" method="html">
						<meta http-equiv="refresh" content="0; URL=tmp-{$tid}-{replace(@effectiveDate,':','')}.html" />
						<meta name="robots" content="noindex, nofollow" />
						<meta http-equiv="expires" content="0" />
					</xsl:result-document>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>

	<xsl:template name="doIssuesTab">
		<xsl:if test="//issues/issue">
			<!-- a little milestoning -->
			<xsl:call-template name="logMessage">
				<xsl:with-param name="level" select="$logINFO" />
				<xsl:with-param name="msg">
					<xsl:text>*** Creating HTML For Issues Tab</xsl:text>
				</xsl:with-param>
			</xsl:call-template>

			<xsl:variable name="content7">
				<div class="TabbedPanelsContent">

					<xsl:choose>
						<xsl:when test="count(//issues)=0">
							<!-- no issues at all -->
							<h2>
								<a name="labelIssues">
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'tabIssuesTitleString'" />
									</xsl:call-template>
								</a>
							</h2>
							<div id="Accordionis" class="Accordion" tabindex="0">
								<table border="0">
									<xsl:call-template name="doMessage">
										<xsl:with-param name="level" select="'info'" />
										<xsl:with-param name="msg">
											<xsl:call-template name="getMessage">
												<xsl:with-param name="key" select="'issueNoIssuesDocumentedYet'" />
											</xsl:call-template>
										</xsl:with-param>
									</xsl:call-template>
								</table>
							</div>
						</xsl:when>
						<xsl:otherwise>
							<div id="Accordionis" class="Accordion" tabindex="0">

								<!-- show all issues sorted -->
								<xsl:call-template name="doShowIssues" />

							</div>
						</xsl:otherwise>
					</xsl:choose>

				</div>
			</xsl:variable>
			<xsl:call-template name="doTabs4ThisTab">
				<xsl:with-param name="actualtab" select="'tabIssues'" />
				<xsl:with-param name="actualcontent" select="$content7" />
			</xsl:call-template>

			<!-- create all issue html representation -->
			<xsl:for-each-group select="//issues/issue" group-by="@id">
				<xsl:variable name="isid" select="@id" />
				<xsl:if test="string-length($isid)>0">
					<xsl:call-template name="logMessage">
						<xsl:with-param name="level" select="$logDEBUG" />
						<xsl:with-param name="msg">
							<xsl:text>*** HTML for issue: id='</xsl:text>
							<xsl:value-of select="$isid" />
							<xsl:text>' name='</xsl:text>
							<xsl:value-of select="@displayName" />
							<xsl:text>'</xsl:text>
						</xsl:with-param>
					</xsl:call-template>

					<xsl:result-document href="{$theHtmlDir}iss-{$isid}.html" method="html">
						<html>
							<xsl:text>&#10;&#10;</xsl:text>
							<head>
								<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
								<title>
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'issuesHeader'" />
										<xsl:with-param name="p1" select="$isid" />
									</xsl:call-template>
								</title>

								<link href="{$theAssetsDir}decor.css" rel="stylesheet" type="text/css" />
								<link href="{$theAssetsDir}favicon.ico" rel="shortcut icon" type="image/x-icon" />

							</head>
							<xsl:text>&#10;&#10;</xsl:text>
							<body>
								<div class="indexline">
									<a href="index.html">
										<xsl:call-template name="getMessage">
											<xsl:with-param name="key" select="'backToIndex'" />
										</xsl:call-template>
									</a>
									<xsl:text> &#160;&lt;&lt;&#160; </xsl:text>
									<a href="issues.html">
										<xsl:call-template name="getMessage">
											<xsl:with-param name="key" select="'backToIssues'" />
										</xsl:call-template>
									</a>
								</div>
								<xsl:apply-templates select="." />
							</body>
						</html>
					</xsl:result-document>
				</xsl:if>
			</xsl:for-each-group>
		</xsl:if>
	</xsl:template>

	<xsl:template name="doCompileTimeTab">
        <!-- a little milestoning -->
        <xsl:call-template name="logMessage">
            <xsl:with-param name="level" select="$logINFO"/>
            <xsl:with-param name="msg">
            <xsl:text>*** Creating HTML For Compilation Tab</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:variable name="content8">
            <div class="TabbedPanelsContent">

                <div id="Accordionce" class="Accordion" tabindex="0">

                    <!--h2>
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'tabCompileTimeInfoTitleString'"/>
                        </xsl:call-template>
                    </h2-->

                    <!-- 
                        the follwing div id runtimezipavailable will be shown the download
                        button if a $theRuntimeDirZIP object is available for download
                        and nothing otherwise
                        2DO : show message that the runtime is not available yet.
                    -->
                    <!--div class="AccordionPanel">
                        <div class="AccordionPanelTab">
                            <h3 class="acco" onclick="toggleZoomImg(this,'zoomout','{$theAssetsDir}');" id="runtimezipalert">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'tabCompileTimeInfoSchematronRuntime'"/>
                                </xsl:call-template>
                            </h3>
                        </div>
                        <div class="AccordionPanelContent" id="runtimezipavailable" zipfile="{$theRuntimeDirZIP}"-->

                    <!-- show the download button if there is a downloadable runtime zip -->
                    <!--
                        <xsl:call-template name="showIcon">
                            <xsl:with-param name="which">download</xsl:with-param>
                        </xsl:call-template>
                        <xsl:text>&#160;</xsl:text>
                        <a href="{$theRuntimeDirZIP}">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'tabCompileTimeInfoDownlaod'"/>
                            </xsl:call-template>
                        </a>
                    -->

                    <!--xsl:call-template name="showIcon">
                                <xsl:with-param name="which">download</xsl:with-param>
                            </xsl:call-template>
                            <xsl:text>&#160;</xsl:text>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'tabCompileTimeInfoDownlaodNotAvailableHere'"/>
                            </xsl:call-template>

                        </div>
                    </div-->

                    <h2>
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'tabCompileTimeIssuesTitleString'"/>
                        </xsl:call-template>
                    </h2>

                    <!--  List of referenced value sets that cannot be found - list already created, show it -->
                    <div class="AccordionPanel">
                        <div class="AccordionPanelTab">
                            <h3 class="acco" onclick="toggleZoomImg(this,'zoomout','{$theAssetsDir}');">
                                <xsl:choose>
                                    <xsl:when test="count($valueSetReferenceErrors/*/error)=0">
                                        <xsl:call-template name="showIcon">
                                            <xsl:with-param name="which">info</xsl:with-param>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:call-template name="showIcon">
                                            <xsl:with-param name="which">notice</xsl:with-param>
                                        </xsl:call-template>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:text>&#160;</xsl:text>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'compileTimeIssueReferencedValueSetButNotFound'"/>
                                </xsl:call-template>
                            </h3>
                        </div>
                        <xsl:text>&#10;&#10;</xsl:text>
                        <div class="AccordionPanelContent">
                            <xsl:choose>
                                <xsl:when test="count($valueSetReferenceErrors/*/error)=0">
                                    <table border="0">
                                        <xsl:call-template name="doMessage">
                                            <xsl:with-param name="level" select="'info'"/>
                                            <xsl:with-param name="msg">
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'issueAllReferencedValueSetsWereFound'"/>
                                                </xsl:call-template>
                                            </xsl:with-param>
                                        </xsl:call-template>
                                    </table>
                                </xsl:when>
                                <xsl:otherwise>
                                    <table width="50%" border="0" cellspacing="2" cellpadding="2">
                                        <tr valign="top">
                                            <td class="tabtab">
                                                <table width="100%" border="0" cellspacing="3" cellpadding="2">
                                                    <tr bgcolor="#FFCCCC">
                                                        <td>
                                                            <xsl:call-template name="getMessage">
                                                                <xsl:with-param name="key" select="'compileTimeIssueReferencedValueSetButNotFoundNumber'"/>
                                                            </xsl:call-template>
                                                        </td>
                                                        <td>
                                                            <xsl:value-of select="count($valueSetReferenceErrors/*/error)"/>
                                                        </td>
                                                    </tr>
                                                    <xsl:for-each-group select="$valueSetReferenceErrors/*/error" group-by="concat(@id,@flexibility,@errortype)">
                                                        <xsl:variable name="id" select="@id"/>
                                                        <tr>
                                                            <td class="tabtab" colspan="2">
                                                                <table width="100%">
                                                                    <tr class="desclabel">
                                                                        <td>
                                                                            <strong>
                                                                                <xsl:value-of select="$id"/>
                                                                            </strong>
                                                                            <xsl:call-template name="getMessage">
                                                                                <xsl:with-param name="key" select="'xInBraces'"/>
                                                                                <xsl:with-param name="p1" select="@flexibility"/>
                                                                            </xsl:call-template>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td valign="top">
                                                                            <xsl:variable name="compileTimeIssueKey">
                                                                                <xsl:choose>
                                                                                    <xsl:when test="@errortype='terminologyref'">compileTimeIssueReferencedFromTerminologyAssociation</xsl:when>
                                                                                    <xsl:when test="@errortype='valuesetref'">compileTimeIssueReferencedFromValueSetRef</xsl:when>
                                                                                    <xsl:when test="@errortype='templateref'">compileTimeIssueReferencedFromTemplate</xsl:when>
                                                                                    <xsl:otherwise>compileTimeIssueReferencedFromOther</xsl:otherwise>
                                                                                </xsl:choose>
                                                                            </xsl:variable>
                                                                            <xsl:call-template name="getMessage">
                                                                                <xsl:with-param name="key" select="$compileTimeIssueKey"/>
                                                                            </xsl:call-template>
                                                                            <ul>
                                                                                <xsl:for-each select="current-group()">
                                                                                    <xsl:variable name="idEff" select="normalize-space(string-join(@from-id|@from-effectiveDate,' '))"/>
                                                                                    <li>
                                                                                        <xsl:choose>
                                                                                            <xsl:when test="name and @from-id">
                                                                                                <xsl:value-of select="name[@language=$defaultLanguage]"/>
                                                                                                <xsl:call-template name="getMessage">
                                                                                                    <xsl:with-param name="key" select="'xInBraces'"/>
                                                                                                    <xsl:with-param name="p1" select="$idEff"/>
                                                                                                </xsl:call-template>
                                                                                            </xsl:when>
                                                                                            <xsl:otherwise>
                                                                                                <xsl:value-of select="name[@language=$defaultLanguage]"/>
                                                                                                <xsl:value-of select="$idEff"/>
                                                                                            </xsl:otherwise>
                                                                                        </xsl:choose>
                                                                                    </li>
                                                                                </xsl:for-each>
                                                                            </ul>
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </td>
                                                        </tr>
                                                    </xsl:for-each-group>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </xsl:otherwise>
                            </xsl:choose>
                        </div>
                    </div>
                    
                    <!-- The arbitrary limitation on the combination of completeCodeSystem and concepts has been lifted -->
                    <!--<xsl:variable name="vsWithCodeSystemRefAndConcepts" select="count($allValueSets//valueSet[completeCodeSystem and conceptList/concept])"/>

                    <!-\- List them -\->
                    <div class="AccordionPanel">
                        <div class="AccordionPanelTab">
                            <h3 class="acco" onclick="toggleZoomImg(this,'zoomout','{$theAssetsDir}');">
                                <xsl:choose>
                                    <xsl:when test="$vsWithCodeSystemRefAndConcepts=0">
                                        <xsl:call-template name="showIcon">
                                            <xsl:with-param name="which">info</xsl:with-param>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:call-template name="showIcon">
                                            <xsl:with-param name="which">alert</xsl:with-param>
                                        </xsl:call-template>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:text>&#160;</xsl:text>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'compileTimeIssueValueSetWithCodeSystemRefAndConcepts'"/>
                                </xsl:call-template>
                            </h3>
                        </div>
                        <xsl:text>&#10;&#10;</xsl:text>
                        <div class="AccordionPanelContent">
                            <xsl:choose>
                                <xsl:when test="$vsWithCodeSystemRefAndConcepts=0">
                                    <table border="0">
                                        <xsl:call-template name="doMessage">
                                            <xsl:with-param name="level" select="'info'"/>
                                            <xsl:with-param name="msg">
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'issueNoValueSetWithCodeSystemRefAndConceptsFound'"/>
                                                </xsl:call-template>
                                            </xsl:with-param>
                                        </xsl:call-template>
                                    </table>
                                </xsl:when>
                                <xsl:otherwise>
                                    <table width="50%" border="0" cellspacing="2" cellpadding="2">
                                        <tr valign="top">
                                            <td class="tabtab">
                                                <table width="100%" border="0" cellspacing="3" cellpadding="2">
                                                    <tr bgcolor="#FFCCCC">
                                                        <td>
                                                            <xsl:call-template name="getMessage">
                                                                <xsl:with-param name="key" select="'compileTimeIssueValueSetWithCodeSystemRefAndConceptsNumber'"/>
                                                            </xsl:call-template>
                                                        </td>
                                                        <td>
                                                            <xsl:value-of select="$vsWithCodeSystemRefAndConcepts"/>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td class="tabtab" colspan="2">
                                                            <ul>
                                                                <xsl:for-each select="$allValueSets//valueSet[completeCodeSystem and conceptList/concept]">
                                                                    <xsl:variable name="vsid" select="@id"/>
                                                                    <xsl:variable name="vseff" select="@effectiveDate"/>

                                                                    <li>
                                                                        <a href="{concat('voc-',$vsid,'-',replace($vseff,':',''),'.html')}">
                                                                            <xsl:value-of select="@name"/>
                                                                            <xsl:call-template name="getMessage">
                                                                                <xsl:with-param name="key" select="'xInBraces'"/>
                                                                                <xsl:with-param name="p1" select="$vsid"/>
                                                                            </xsl:call-template>
                                                                        </a>
                                                                    </li>
                                                                </xsl:for-each>
                                                            </ul>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </xsl:otherwise>
                            </xsl:choose>
                        </div>
                    </div>-->

                    <!--  List of included templates without a corresponding or empty template - list already created, show it -->
                    <div class="AccordionPanel">
                        <div class="AccordionPanelTab">
                            <h3 class="acco" onclick="toggleZoomImg(this,'zoomout','{$theAssetsDir}');">
                                <xsl:choose>
                                    <xsl:when test="count($missingTemplates/*/error)=0">
                                        <xsl:call-template name="showIcon">
                                            <xsl:with-param name="which">info</xsl:with-param>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:call-template name="showIcon">
                                            <xsl:with-param name="which">alert</xsl:with-param>
                                        </xsl:call-template>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:text>&#160;</xsl:text>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'compileTimeIssueIncludedTemplatesWithoutCorrespondingOrEmptyTemplate'"/>
                                </xsl:call-template>
                            </h3>
                        </div>
                        <xsl:text>&#10;&#10;</xsl:text>
                        <div class="AccordionPanelContent">
                            <xsl:choose>
                                <xsl:when test="count($missingTemplates/*/error)=0">
                                    <table border="0">
                                        <xsl:call-template name="doMessage">
                                            <xsl:with-param name="level" select="'info'"/>
                                            <xsl:with-param name="msg">
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'issueNoIncludedTemplatesWithoutACorrespondingOrEmptyTemplateFound'"/>
                                                </xsl:call-template>
                                            </xsl:with-param>
                                        </xsl:call-template>
                                    </table>
                                </xsl:when>
                                <xsl:otherwise>
                                    <table width="50%" border="0" cellspacing="2" cellpadding="2">
                                        <tr valign="top">
                                            <td class="tabtab">
                                                <table width="100%" border="0" cellspacing="3" cellpadding="2">
                                                    <tr bgcolor="#FFCCCC">
                                                        <td>
                                                            <xsl:call-template name="getMessage">
                                                                <xsl:with-param name="key" select="'compileTimeIssueIncludedTemplatesWithoutCorrespondingOrEmptyTemplateNumber'"/>
                                                            </xsl:call-template>
                                                        </td>
                                                        <td>
                                                            <xsl:value-of select="count($missingTemplates/*/error)"/>
                                                        </td>
                                                    </tr>
                                                    <xsl:for-each select="$missingTemplates/*/error">
                                                        <xsl:variable name="inc" select="@ref"/>
                                                        <xsl:variable name="empty" select="@empty"/>
                                                        <xsl:variable name="id" select="@id"/>
                                                        <tr>
                                                            <td class="tabtab" colspan="2">
                                                                <table width="100%">
                                                                    <tr class="desclabel">
                                                                        <td>
                                                                            <strong>
                                                                                <xsl:value-of select="$inc"/>
                                                                            </strong>
                                                                            <xsl:if test="$empty">
                                                                                <xsl:call-template name="getMessage">
                                                                                    <xsl:with-param name="key" select="'registeredButEmpty'"/>
                                                                                </xsl:call-template>
                                                                            </xsl:if>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td valign="top">
                                                                            <xsl:call-template name="getMessage">
                                                                                <xsl:with-param name="key" select="'compileTimeIssueReferencedInTemplate'"/>
                                                                            </xsl:call-template>
                                                                            <ul>
                                                                                <xsl:for-each select="($allTemplates//include[@ref=$inc]/ancestor::template)[last()] | ($allTemplates//*[@contains=$inc]/ancestor::template)[last()]">
                                                                                    <li>
                                                                                        <xsl:choose>
                                                                                            <xsl:when test="@id">
                                                                                                <a href="tmp-{@id}-{replace(@effectiveDate,':','')}.html">
                                                                                                    <xsl:value-of select="if (string-length(@displayName)>0) then @displayName else @name"/>
                                                                                                </a>
                                                                                                <xsl:call-template name="getMessage">
                                                                                                    <xsl:with-param name="key" select="'xInBraces'"/>
                                                                                                    <xsl:with-param name="p1" select="@id"/>
                                                                                                </xsl:call-template>
                                                                                            </xsl:when>
                                                                                            <xsl:otherwise>
                                                                                                <xsl:value-of select="@name"/>
                                                                                                <xsl:value-of select="@ref"/>
                                                                                            </xsl:otherwise>
                                                                                        </xsl:choose>
                                                                                        <xsl:if test="$empty">
                                                                                            <xsl:call-template name="getMessage">
                                                                                                <xsl:with-param name="key" select="'registeredButEmpty'"/>
                                                                                            </xsl:call-template>
                                                                                        </xsl:if>
                                                                                    </li>
                                                                                </xsl:for-each>
                                                                            </ul>
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </td>
                                                        </tr>
                                                    </xsl:for-each>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </xsl:otherwise>
                            </xsl:choose>
                        </div>
                    </div>


                    <!-- create a list of ids with missing designation -->
                    <xsl:variable name="missingIds">
                        <ids>
                            <xsl:for-each select="//@codeSystem[not(ancestor::example)]">
                                <xsl:for-each select="tokenize(., '\|')">
                                    <xsl:variable name="theOID" select="."/>
                                    <xsl:if test="count($allIDs//id[@root=$theOID])=0">
                                        <missingId oid="{$theOID}" type="code system" count="1"/>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:for-each>
                            <xsl:for-each select="//@root[not(ancestor::example)]">
                                <xsl:for-each select="tokenize(., '\|')">
                                    <xsl:variable name="theOID" select="."/>
                                    <xsl:if test="count($allIDs//id[@root=$theOID]) + count($allTemplates//template[@id=$theOID]) = 0">
                                        <missingId oid="{$theOID}" type="id root" count="1"/>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:for-each>
                        </ids>
                    </xsl:variable>

                    <!-- List them -->
                    <div class="AccordionPanel">
                        <div class="AccordionPanelTab">
                            <h3 class="acco" onclick="toggleZoomImg(this,'zoomout','{$theAssetsDir}');">
                                <xsl:choose>
                                    <xsl:when test="count($missingIds/*/missingId)=0">
                                        <xsl:call-template name="showIcon">
                                            <xsl:with-param name="which">info</xsl:with-param>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:call-template name="showIcon">
                                            <xsl:with-param name="which">notice</xsl:with-param>
                                        </xsl:call-template>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:text>&#160;</xsl:text>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'compileTimeIssueMissingIdentifierDescriptionsFromDesignations'"/>
                                </xsl:call-template>
                            </h3>
                        </div>
                        <xsl:text>&#10;&#10;</xsl:text>
                        <div class="AccordionPanelContent">
                            <xsl:choose>
                                <xsl:when test="count($missingIds/*/missingId)=0">
                                    <table border="0">
                                        <xsl:call-template name="doMessage">
                                            <xsl:with-param name="level" select="'info'"/>
                                            <xsl:with-param name="msg">
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'issueNoMissingIdentifierDescriptionsFromDesignations'"/>
                                                </xsl:call-template>
                                            </xsl:with-param>
                                        </xsl:call-template>
                                    </table>
                                </xsl:when>
                                <xsl:otherwise>
                                    <table width="50%" border="0" cellspacing="2" cellpadding="2">
                                        <tr valign="top">
                                            <td class="tabtab">
                                                <table width="100%" border="0" cellspacing="3" cellpadding="2">

                                                    <tr bgcolor="#FFCCCC">
                                                        <td align="left">
                                                            <xsl:call-template name="getMessage">
                                                                <xsl:with-param name="key" select="'OID'"/>
                                                            </xsl:call-template>
                                                        </td>
                                                        <td align="left">
                                                            <xsl:call-template name="getMessage">
                                                                <xsl:with-param name="key" select="'Type'"/>
                                                            </xsl:call-template>
                                                        </td>
                                                        <td align="right">
                                                            <xsl:call-template name="getMessage">
                                                                <xsl:with-param name="key" select="'used'"/>
                                                            </xsl:call-template>
                                                        </td>
                                                    </tr>

                                                    <xsl:for-each-group select="$missingIds/*/missingId" group-by="@oid">
                                                        <xsl:sort select="replace(replace (concat(@oid, '.'), '\.', '.0000000000'), '.0*([0-9]{9,})', '.$1')"/>
                                                        <xsl:variable name="theOID" select="@oid"/>

                                                        <tr>
                                                            <td>
                                                                <xsl:value-of select="$theOID"/>
                                                            </td>
                                                            <td>
                                                                <xsl:value-of select="@type"/>
                                                            </td>
                                                            <td align="right">
                                                                <xsl:value-of select="count($missingIds/*/missingId[@oid=$theOID])"/>
                                                                <xsl:text>x</xsl:text>
                                                            </td>
                                                        </tr>
                                                    </xsl:for-each-group>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </xsl:otherwise>
                            </xsl:choose>
                        </div>
                    </div>


                    <!--  List of issue element present in any of the templates, show them -->
                    <div class="AccordionPanel">
                        <div class="AccordionPanelTab">
                            <h3 class="acco" onclick="toggleZoomImg(this,'zoomout','{$theAssetsDir}');">
                                <xsl:choose>
                                    <xsl:when test="count($allTemplates//issue)=0">
                                        <xsl:call-template name="showIcon">
                                            <xsl:with-param name="which">info</xsl:with-param>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:call-template name="showIcon">
                                            <xsl:with-param name="which">notice</xsl:with-param>
                                        </xsl:call-template>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:text>&#160;</xsl:text>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'listOfIssuesInTemplateSources'"/>
                                </xsl:call-template>
                            </h3>
                        </div>
                        <xsl:text>&#10;&#10;</xsl:text>
                        <div class="AccordionPanelContent">
                            <xsl:choose>
                                <xsl:when test="count($allTemplates//issue)=0">
                                    <table border="0">
                                        <xsl:call-template name="doMessage">
                                            <xsl:with-param name="level" select="'info'"/>
                                            <xsl:with-param name="msg">
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'issueNoIssuesDocumentedInTemplateSources'"/>
                                                </xsl:call-template>
                                            </xsl:with-param>
                                        </xsl:call-template>
                                    </table>
                                </xsl:when>
                                <xsl:otherwise>
                                    <table width="50%" border="0" cellspacing="2" cellpadding="2">
                                        <tr valign="top">
                                            <td class="tabtab">
                                                <table width="100%" border="0" cellspacing="3" cellpadding="2">
                                                    <tr bgcolor="#FFCCCC">
                                                        <td>
                                                            <xsl:call-template name="getMessage">
                                                                <xsl:with-param name="key" select="'listOfIssuesInTemplateSourcesNumber'"/>
                                                            </xsl:call-template>
                                                        </td>
                                                        <td>
                                                            <xsl:value-of select="count($allTemplates//issue)"/>
                                                        </td>
                                                    </tr>
                                                    <xsl:for-each select="$allTemplates//issue">
                                                        <tr valign="top">
                                                            <td colspan="2" class="tabtab">
                                                                <table border="0" cellspacing="2" cellpadding="2" width="100%">
                                                                    <tr>
                                                                        <td colspan="2" valign="top">
                                                                            <xsl:call-template name="getMessage">
                                                                                <xsl:with-param name="key" select="'compileTimeIssueReferencedInTemplate'"/>
                                                                            </xsl:call-template>
                                                                            <xsl:for-each select="(ancestor-or-self::template)[last()]">
                                                                                <xsl:choose>
                                                                                    <xsl:when test="@name and @id">
                                                                                        <xsl:value-of select="@name"/>
                                                                                        <xsl:call-template name="getMessage">
                                                                                            <xsl:with-param name="key" select="'xInBraces'"/>
                                                                                            <xsl:with-param name="p1" select="@id"/>
                                                                                        </xsl:call-template>
                                                                                    </xsl:when>
                                                                                    <xsl:otherwise>
                                                                                        <xsl:value-of select="@name"/>
                                                                                        <xsl:value-of select="@id"/>
                                                                                    </xsl:otherwise>
                                                                                </xsl:choose>
                                                                            </xsl:for-each>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td colspan="2" valign="top">
                                                                            <xsl:call-template name="getMessage">
                                                                                <xsl:with-param name="key" select="'pathWithColon'"/>
                                                                            </xsl:call-template>
                                                                            <xsl:for-each select="ancestor-or-self::element">
                                                                                <xsl:value-of select="@name"/>
                                                                                <xsl:if test="position()!=last()">
                                                                                    <xsl:text>/</xsl:text>
                                                                                </xsl:if>
                                                                            </xsl:for-each>
                                                                        </td>
                                                                    </tr>
                                                                    <xsl:for-each select="tracking">
                                                                        <tr class="desclabel">
                                                                            <td width="30px">
                                                                                <xsl:call-template name="showStatusDot">
                                                                                    <xsl:with-param name="status" select="@statusCode"/>
                                                                                </xsl:call-template>
                                                                            </td>
                                                                            <td valign="top">
                                                                                <xsl:call-template name="showDate">
                                                                                    <xsl:with-param name="date" select="@effectiveDate"/>
                                                                                </xsl:call-template>
                                                                                <xsl:text>&#160;</xsl:text>
                                                                                <xsl:for-each select="author">
                                                                                    <xsl:value-of select="."/>
                                                                                    <xsl:if test="position()!=last()">
                                                                                        <xsl:text> / </xsl:text>
                                                                                    </xsl:if>
                                                                                </xsl:for-each>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td/>
                                                                            <td>
                                                                                <xsl:call-template name="doDescription">
                                                                                    <xsl:with-param name="ns" select="desc"/>
                                                                                </xsl:call-template>
                                                                            </td>
                                                                        </tr>
                                                                    </xsl:for-each>
                                                                </table>
                                                            </td>
                                                        </tr>
                                                    </xsl:for-each>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </xsl:otherwise>
                            </xsl:choose>
                        </div>
                    </div>


                    <!-- create a list of duplicate ids of concepts in a single dataset -->
                    <xsl:variable name="duplicateKeyIds">
                        <duplicates>
                            <xsl:for-each select="$allDatasets/dataset">
                                <xsl:variable name="dsid" select="@id"/>
                                <xsl:for-each-group select="$allDatasets//concept[not(ancestor::conceptList|ancestor::history)]" group-by="@id">
                                    <xsl:variable name="nid" select="@id"/>
                                    <xsl:variable name="cnt" select="count($allDatasets//concept[@id=$nid and not(ancestor::conceptList|ancestor::history)])"/>
                                    <xsl:if test="$cnt>1">
                                        <dup id="{$nid}" dataset="{$dsid}" count="{$cnt}"/>
                                    </xsl:if>
                                </xsl:for-each-group>
                            </xsl:for-each>
                        </duplicates>
                    </xsl:variable>
                    <!-- List them -->
                    <div class="AccordionPanel">
                        <div class="AccordionPanelTab">
                            <h3 class="acco" onclick="toggleZoomImg(this,'zoomout','{$theAssetsDir}');">
                                <xsl:choose>
                                    <xsl:when test="count($duplicateKeyIds/*/dup)=0">
                                        <xsl:call-template name="showIcon">
                                            <xsl:with-param name="which">info</xsl:with-param>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:call-template name="showIcon">
                                            <xsl:with-param name="which">notice</xsl:with-param>
                                        </xsl:call-template>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:text>&#160;</xsl:text>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'duplicateKeyIdsInDataConcepts'"/>
                                </xsl:call-template>
                            </h3>
                        </div>
                        <xsl:text>&#10;&#10;</xsl:text>
                        <div class="AccordionPanelContent">
                            <xsl:choose>
                                <xsl:when test="count($duplicateKeyIds/*/dup)=0">
                                    <table border="0">
                                        <xsl:call-template name="doMessage">
                                            <xsl:with-param name="level" select="'info'"/>
                                            <xsl:with-param name="msg">
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'issueNoDuplicateKeyIdsInDataConcepts'"/>
                                                </xsl:call-template>
                                            </xsl:with-param>
                                        </xsl:call-template>
                                    </table>
                                </xsl:when>
                                <xsl:otherwise>
                                    <table width="50%" border="0" cellspacing="2" cellpadding="2">
                                        <tr valign="top">
                                            <td class="tabtab">
                                                <table width="100%" border="0" cellspacing="3" cellpadding="2">

                                                    <tr bgcolor="#FFCCCC">
                                                        <td align="left">
                                                            <xsl:call-template name="getMessage">
                                                                <xsl:with-param name="key" select="'DuplicateId'"/>
                                                            </xsl:call-template>
                                                        </td>
                                                        <td align="left">
                                                            <xsl:call-template name="getMessage">
                                                                <xsl:with-param name="key" select="'inDataSet'"/>
                                                            </xsl:call-template>
                                                        </td>
                                                        <td align="right">
                                                            <xsl:call-template name="getMessage">
                                                                <xsl:with-param name="key" select="'timesUsed'"/>
                                                            </xsl:call-template>
                                                        </td>
                                                    </tr>

                                                    <xsl:for-each-group select="$duplicateKeyIds/*/dup" group-by="@id">
                                                        <xsl:sort select="replace(replace (concat(@id, '.'), '\.', '.0000000000'), '.0*([0-9]{9,})', '.$1')"/>
                                                        <tr>
                                                            <td>
                                                                <xsl:value-of select="@id"/>
                                                            </td>
                                                            <td>
                                                                <xsl:value-of select="@dataset"/>
                                                            </td>
                                                            <td align="right">
                                                                <xsl:value-of select="@count"/>
                                                                <xsl:text>x</xsl:text>
                                                            </td>
                                                        </tr>
                                                    </xsl:for-each-group>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </xsl:otherwise>
                            </xsl:choose>
                        </div>
                    </div>

                    <!-- create a list of data types used that are NOT in supported data types -->
                    <xsl:variable name="missingDatatypes">
                        <dts>
                            <xsl:for-each select="//*[local-name()!='attribute']/@datatype">
                                <xsl:variable name="theDT" select="."/>
                                <dt name="{$theDT}">
                                    <xsl:choose>
                                        <xsl:when test="count($supportedDatatypes/dt[@name=$theDT])>0">
                                            <xsl:attribute name="supported" select="true()"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:attribute name="supported" select="false()"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </dt>
                            </xsl:for-each>
                            <xsl:for-each select="//attribute/@datatype">
                                <xsl:variable name="theDT" select="."/>
                                <dt name="{$theDT}">
                                    <xsl:choose>
                                        <xsl:when test="count($supportedAtomicDatatypes/dt[@name=$theDT])>0">
                                            <xsl:attribute name="supported" select="true()"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:attribute name="supported" select="false()"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </dt>
                            </xsl:for-each>
                        </dts>
                    </xsl:variable>

                    <!-- List them -->
                    <div class="AccordionPanel">
                        <div class="AccordionPanelTab">
                            <h3 class="acco" onclick="toggleZoomImg(this,'zoomout','{$theAssetsDir}');">
                                <xsl:choose>
                                    <xsl:when test="count($missingDatatypes/*/dt[@supported='false'])=0">
                                        <xsl:call-template name="showIcon">
                                            <xsl:with-param name="which">info</xsl:with-param>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:call-template name="showIcon">
                                            <xsl:with-param name="which">alert</xsl:with-param>
                                        </xsl:call-template>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:text>&#160;</xsl:text>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'compileTimeIssueDatatypeFlavors'"/>
                                </xsl:call-template>
                            </h3>
                        </div>
                        <xsl:text>&#10;&#10;</xsl:text>
                        <div class="AccordionPanelContent">
                            <xsl:choose>
                                <xsl:when test="count($missingDatatypes/*/dt)=0">
                                    <table border="0">
                                        <xsl:call-template name="doMessage">
                                            <xsl:with-param name="level" select="'info'"/>
                                            <xsl:with-param name="msg">
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'issueNoDatatypesOrDatatypeFlavorsUsed'"/>
                                                </xsl:call-template>
                                            </xsl:with-param>
                                        </xsl:call-template>
                                    </table>
                                </xsl:when>
                                <xsl:otherwise>
                                    <table width="50%" border="0" cellspacing="2" cellpadding="2">
                                        <tr valign="top">
                                            <td class="tabtab">
                                                <table width="100%" border="0" cellspacing="3" cellpadding="2">

                                                    <tr bgcolor="#FFCCCC">
                                                        <td align="left">
                                                            <xsl:call-template name="getMessage">
                                                                <xsl:with-param name="key" select="'compileTimeIssueDatatypeHeading'"/>
                                                            </xsl:call-template>
                                                        </td>
                                                        <td align="left">
                                                            <xsl:call-template name="getMessage">
                                                                <xsl:with-param name="key" select="'compileTimeIssueDatatypeDefined'"/>
                                                            </xsl:call-template>
                                                        </td>
                                                        <td align="right">
                                                            <xsl:call-template name="getMessage">
                                                                <xsl:with-param name="key" select="'compileTimeIssueDatatypeUsed'"/>
                                                            </xsl:call-template>
                                                        </td>
                                                    </tr>

                                                    <xsl:for-each-group select="$missingDatatypes/*/dt" group-by="@name">
                                                        <xsl:sort select="@name"/>
                                                        <xsl:variable name="theDT" select="@name"/>
                                                        <tr>
                                                            <xsl:if test="@supported='true'">
                                                                <xsl:attribute name="bgcolor" select="'#FFEEEE'"/>
                                                            </xsl:if>
                                                            <td>
                                                                <xsl:choose>
                                                                    <xsl:when test="contains($theDT, '.')">
                                                                        <!-- indent a data type flavor -->
                                                                        <xsl:call-template name="repeatString">
                                                                            <xsl:with-param name="number" select="2"/>
                                                                            <xsl:with-param name="theString" select="'&#160;'"/>
                                                                        </xsl:call-template>
                                                                        <xsl:value-of select="$theDT"/>
                                                                    </xsl:when>
                                                                    <xsl:otherwise>
                                                                        <xsl:value-of select="$theDT"/>
                                                                    </xsl:otherwise>
                                                                </xsl:choose>
                                                            </td>
                                                            <td>
                                                                <xsl:choose>
                                                                    <xsl:when test="@supported='true'">
                                                                        <xsl:call-template name="getMessage">
                                                                            <xsl:with-param name="key" select="'yes'"/>
                                                                        </xsl:call-template>
                                                                    </xsl:when>
                                                                    <xsl:otherwise>
                                                                        <xsl:call-template name="getMessage">
                                                                            <xsl:with-param name="key" select="'no'"/>
                                                                        </xsl:call-template>
                                                                    </xsl:otherwise>
                                                                </xsl:choose>
                                                            </td>
                                                            <td align="right">
                                                                <xsl:value-of select="count($missingDatatypes/*/dt[@name=$theDT])"/>
                                                                <xsl:text>x</xsl:text>
                                                            </td>
                                                        </tr>
                                                    </xsl:for-each-group>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </xsl:otherwise>
                            </xsl:choose>
                        </div>
                    </div>

                    <!-- create a list of references thru @ref anywhere that are not resolvable within this DECOR project -->
                    <xsl:variable name="refs">
                        <refs>
                            <xsl:for-each-group select="//*[@ref and not(ancestor::history)]" group-by="@ref">
                                <xsl:variable name="theRef" select="@ref"/>
                                <ref ref="{$theRef}">
                                    <xsl:choose>
                                        <xsl:when test="matches(string($theRef), '[1-9][0-9]*(\.[0-9]+)*')">
                                            <xsl:attribute name="type" select="'oid'"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:attribute name="type" select="'name'"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:for-each select="//*[@id=$theRef and not(ancestor::history)]">
                                        <id id="{@id}"/>
                                    </xsl:for-each>
                                    <xsl:for-each select="//*[@name=$theRef and not(ancestor::history)]">
                                        <id name="{@name}"/>
                                    </xsl:for-each>
                                    <usage>
                                        <xsl:for-each select="ancestor-or-self::node()">
                                            <xsl:value-of select="name()"/>
                                            <xsl:if test="position()!=last()">
                                                <xsl:text>/</xsl:text>
                                            </xsl:if>
                                        </xsl:for-each>
                                    </usage>
                                </ref>
                            </xsl:for-each-group>
                        </refs>
                    </xsl:variable>
                    <!-- List them -->
                    <div class="AccordionPanel">
                        <div class="AccordionPanelTab">
                            <h3 class="acco" onclick="toggleZoomImg(this,'zoomout','{$theAssetsDir}');">
                                <xsl:choose>
                                    <xsl:when test="count($refs/*[not]/ref[not(id)])=0">
                                        <xsl:call-template name="showIcon">
                                            <xsl:with-param name="which">info</xsl:with-param>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:call-template name="showIcon">
                                            <xsl:with-param name="which">notice</xsl:with-param>
                                        </xsl:call-template>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:text>&#160;</xsl:text>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'RefsWithoutId'"/>
                                </xsl:call-template>
                            </h3>
                        </div>
                        <xsl:text>&#10;&#10;</xsl:text>
                        <div class="AccordionPanelContent">
                            <xsl:choose>
                                <xsl:when test="count($refs/*[not]/ref[not(id)])=0">
                                    <table border="0">
                                        <xsl:call-template name="doMessage">
                                            <xsl:with-param name="level" select="'info'"/>
                                            <xsl:with-param name="msg">
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'issueNoIdForRef'"/>
                                                </xsl:call-template>
                                            </xsl:with-param>
                                        </xsl:call-template>
                                    </table>
                                </xsl:when>
                                <xsl:otherwise>
                                    <table width="50%" border="0" cellspacing="2" cellpadding="2">
                                        <tr valign="top">
                                            <td class="tabtab">
                                                <table width="100%" border="0" cellspacing="3" cellpadding="2">

                                                    <tr bgcolor="#FFCCCC">
                                                        <td align="left">
                                                            <xsl:call-template name="getMessage">
                                                                <xsl:with-param name="key" select="'References'"/>
                                                            </xsl:call-template>
                                                        </td>
                                                        <td>#</td>
                                                    </tr>

                                                    <xsl:for-each-group select="$refs/*/ref[not(id)]" group-by="@ref">
                                                        <xsl:sort select="replace(replace (concat(@ref, '.'), '\.', '.0000000000'), '.0*([0-9]{9,})', '.$1')"/>
                                                        <tr>
                                                            <td>
                                                                <xsl:value-of select="@ref"/>
                                                                <br/>
                                                                <xsl:call-template name="getMessage">
                                                                    <xsl:with-param name="key" select="'pathWithColon'"/>
                                                                </xsl:call-template>
                                                                <xsl:value-of select="usage"/>
                                                            </td>
                                                            <td>
                                                                <xsl:value-of select="count(id)"/>
                                                            </td>
                                                        </tr>
                                                    </xsl:for-each-group>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </xsl:otherwise>
                            </xsl:choose>
                        </div>
                    </div>


                    <!-- create a list of concept/@ref within a representingTemplate that do not belong to the data set stated in @sourceDataset -->
                    <xsl:variable name="conref">
                        <conrefs>
                            <xsl:for-each select="//scenarios/scenario[@statusCode=('draft','final','new')]//representingTemplate">
                                <xsl:variable name="theRepresentingTemplate" select="@ref"/>
                                <xsl:variable name="thelabel" select="normalize-space(concat(@displayName, ' ', parent::transaction/name[@language=$defaultLanguage]))"/>
                                <xsl:variable name="theSourceDataSet" select="@sourceDataset"/>
                                <xsl:for-each select="concept">
                                    <xsl:variable name="theRef" select="@ref"/>
                                    <xsl:if test="count($allDatasetConceptsFlat/*/dataset[@id=$theSourceDataSet]//concept[@id=$theRef and not(ancestor::history)])=0">
                                        <xsl:variable name="locid" select="$allDatasetConceptsFlat/dataset[//concept[@id=$theRef and not(ancestor::history)]]/@id"/>
                                        <ref ref="{$theRef}" representingTemplate="{$theRepresentingTemplate}" label="{$thelabel}" sourceDataset="{$theSourceDataSet}" location="{$locid}"/>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:for-each>
                        </conrefs>
                    </xsl:variable>
                    <!-- List them -->
                    <div class="AccordionPanel">
                        <div class="AccordionPanelTab">
                            <h3 class="acco" onclick="toggleZoomImg(this,'zoomout','{$theAssetsDir}');">
                                <xsl:choose>
                                    <xsl:when test="count($conref/*/ref)=0">
                                        <xsl:call-template name="showIcon">
                                            <xsl:with-param name="which">info</xsl:with-param>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:call-template name="showIcon">
                                            <xsl:with-param name="which">notice</xsl:with-param>
                                        </xsl:call-template>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:text>&#160;</xsl:text>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'RepTemConceptsNotInSourceDataSet'"/>
                                </xsl:call-template>
                            </h3>
                        </div>
                        <xsl:text>&#10;&#10;</xsl:text>
                        <div class="AccordionPanelContent">
                            <xsl:choose>
                                <xsl:when test="count($conref/*/ref)=0">
                                    <table border="0">
                                        <xsl:call-template name="doMessage">
                                            <xsl:with-param name="level" select="'info'"/>
                                            <xsl:with-param name="msg">
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'issueNoRepTemConceptsNotInSourceDataSet'"/>
                                                </xsl:call-template>
                                            </xsl:with-param>
                                        </xsl:call-template>
                                    </table>
                                </xsl:when>
                                <xsl:otherwise>
                                    <table width="50%" border="0" cellspacing="2" cellpadding="2">
                                        <tr valign="top">
                                            <td class="tabtab">
                                                <table width="100%" border="0" cellspacing="3" cellpadding="2">

                                                    <tr bgcolor="#FFCCCC">
                                                        <td align="left" colspan="3">
                                                            <xsl:call-template name="getMessage">
                                                                <xsl:with-param name="key" select="'RepTemConceptsNotInSourceDataSet'"/>
                                                            </xsl:call-template>
                                                        </td>
                                                    </tr>
                                                    <xsl:for-each-group select="$conref/*/ref" group-by="@representingTemplate">
                                                        <xsl:sort select="replace(replace (concat(@representingTemplate, '.'), '\.', '.0000000000'), '.0*([0-9]{9,})', '.$1')"/>
                                                        <xsl:variable name="reptid" select="@representingTemplate"/>
                                                        <tr bgcolor="#FFEEEE">
                                                            <td align="left" colspan="3">
                                                                <b>
                                                                    <xsl:call-template name="getMessage">
                                                                        <xsl:with-param name="key" select="'representingTemplate'"/>
                                                                    </xsl:call-template>
                                                                    <xsl:text>: </xsl:text>
                                                                </b>
                                                                <xsl:value-of select="$reptid"/>
                                                                <xsl:text> </xsl:text>
                                                                <i>
                                                                    <xsl:value-of select="@label"/>
                                                                </i>
                                                                <br/>
                                                                <b>
                                                                    <xsl:call-template name="getMessage">
                                                                        <xsl:with-param name="key" select="'sourceDataSetId'"/>
                                                                    </xsl:call-template>
                                                                    <xsl:text>: </xsl:text>
                                                                </b>
                                                                <xsl:value-of select="@sourceDataset"/>
                                                            </td>
                                                        </tr>
                                                        <xsl:for-each select="$conref/*/ref[@representingTemplate=$reptid]">
                                                            <xsl:sort select="replace(replace (concat(@ref, '.'), '\.', '.0000000000'), '.0*([0-9]{9,})', '.$1')"/>
                                                            <tr>
                                                                <td>
                                                                    <xsl:call-template name="getMessage">
                                                                        <xsl:with-param name="key" select="'conceptIdLabel'"/>
                                                                    </xsl:call-template>
                                                                    <xsl:value-of select="@ref"/>
                                                                </td>
                                                                <td>
                                                                    <xsl:call-template name="getMessage">
                                                                        <xsl:with-param name="key" select="'compileTimeShallBeInDataset'"/>
                                                                    </xsl:call-template>
                                                                </td>
                                                                <td>
                                                                    <xsl:value-of select="@sourceDataset"/>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>&#160;</td>
                                                                <xsl:choose>
                                                                    <xsl:when test="string-length(@location)=0">
                                                                        <td colspan="2">
                                                                            <xsl:call-template name="getMessage">
                                                                                <xsl:with-param name="key" select="'compileTimeIsInNoDataset'"/>
                                                                            </xsl:call-template>
                                                                        </td>
                                                                    </xsl:when>
                                                                    <xsl:otherwise>
                                                                        <td>
                                                                            <xsl:call-template name="getMessage">
                                                                                <xsl:with-param name="key" select="'compileTimeButIsInDataset'"/>
                                                                            </xsl:call-template>
                                                                        </td>
                                                                        <td>
                                                                            <xsl:value-of select="@location"/>
                                                                        </td>
                                                                    </xsl:otherwise>
                                                                </xsl:choose>
                                                            </tr>
                                                        </xsl:for-each>
                                                    </xsl:for-each-group>

                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </xsl:otherwise>
                            </xsl:choose>
                        </div>
                    </div>

                    <div class="AccordionPanel">
                        <div class="AccordionPanelTab">
                            <h3 class="acco" onclick="toggleZoomImg(this,'zoomout','{$theAssetsDir}');">
                                <xsl:choose>
                                    <xsl:when test="count($allMissingLabels/*/missingCode)=0">
                                        <xsl:call-template name="showIcon">
                                            <xsl:with-param name="which">info</xsl:with-param>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:call-template name="showIcon">
                                            <xsl:with-param name="which">notice</xsl:with-param>
                                        </xsl:call-template>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:text>&#160;</xsl:text>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'compileTimeIssueReferencedLabelNotDefined'"/>
                                </xsl:call-template>
                            </h3>
                        </div>
                        <xsl:text>&#10;&#10;</xsl:text>
                        <div class="AccordionPanelContent">
                            <xsl:choose>
                                <xsl:when test="count($allMissingLabels/*/missingCode)=0">
                                    <table border="0">
                                        <xsl:call-template name="doMessage">
                                            <xsl:with-param name="level" select="'info'"/>
                                            <xsl:with-param name="msg">
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'issueAllUsedIssueLabelWereDefined'"/>
                                                </xsl:call-template>
                                            </xsl:with-param>
                                        </xsl:call-template>
                                    </table>
                                </xsl:when>
                                <xsl:otherwise>
                                    <table width="50%" border="0" cellspacing="2" cellpadding="2">
                                        <tr valign="top">
                                            <td class="tabtab">
                                                <table width="100%" border="0" cellspacing="3" cellpadding="2">

                                                    <tr bgcolor="#FFCCCC">
                                                        <td align="left">
                                                            <xsl:call-template name="getMessage">
                                                                <xsl:with-param name="key" select="'compileTimeIssueReferencedLabelNotDefined'"/>
                                                            </xsl:call-template>
                                                        </td>
                                                    </tr>

                                                    <tr>
                                                        <td>
                                                            <table width="100%">
                                                                <thead>
                                                                    <tr>
                                                                        <th>
                                                                            <xsl:call-template name="getMessage">
                                                                                <xsl:with-param name="key" select="'definedCode'"/>
                                                                            </xsl:call-template>
                                                                        </th>
                                                                        <th>
                                                                            <xsl:call-template name="getMessage">
                                                                                <xsl:with-param name="key" select="'Name'"/>
                                                                            </xsl:call-template>
                                                                        </th>
                                                                        <th>
                                                                            <xsl:call-template name="getMessage">
                                                                                <xsl:with-param name="key" select="'Issue'"/>
                                                                            </xsl:call-template>
                                                                        </th>
                                                                    </tr>
                                                                </thead>
                                                                <tbody>
                                                                    <xsl:for-each select="$allMissingLabels/wrap/missingCode">
                                                                        <tr>
                                                                            <td>
                                                                                <xsl:value-of select="@labelCode"/>
                                                                            </td>
                                                                            <td>
                                                                                <xsl:value-of select="@refName"/>
                                                                            </td>
                                                                            <td>
                                                                                <xsl:call-template name="doShorthandId">
                                                                                    <xsl:with-param name="id" select="@ref"/>
                                                                                </xsl:call-template>
                                                                            </td>
                                                                        </tr>
                                                                    </xsl:for-each>
                                                                </tbody>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </xsl:otherwise>
                            </xsl:choose>
                        </div>
                    </div>
                
                    <div class="AccordionPanel">
                        <div class="AccordionPanelTab">
                            <h3 class="acco" onclick="toggleZoomImg(this,'zoomout','{$theAssetsDir}');">
                                <xsl:call-template name="showIcon">
                                    <xsl:with-param name="which">info</xsl:with-param>
                                </xsl:call-template>
                                <xsl:text> </xsl:text>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'transformationProtocol'"/>
                                </xsl:call-template>
                            </h3>
                        </div>
                        <xsl:text>&#10;&#10;</xsl:text>
                        <div class="AccordionPanelContent">
                            <tt>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'transformationProtocolNotRegistered'"/>
                                </xsl:call-template>
                            </tt>
                        </div>
                    </div>
                </div>
            </div>
        </xsl:variable>
        <xsl:call-template name="doTabs4ThisTab">
            <xsl:with-param name="actualtab" select="'tabCompileTime'"/>
            <xsl:with-param name="actualcontent" select="$content8"/>
        </xsl:call-template>
    </xsl:template>

	<xsl:template name="doLegalTab">
		<!-- a little milestoning -->
		<xsl:call-template name="logMessage">
			<xsl:with-param name="level" select="$logINFO" />
			<xsl:with-param name="msg">
				<xsl:text>*** Creating HTML For Legal Tab</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:variable name="content9">
			<div class="TabbedPanelsContent">
				<table width="50%" border="0" cellspacing="20" cellpadding="20">
					<tr>
						<td>
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'licenseNoticeGPL'" />
							</xsl:call-template>
						</td>
					</tr>
					<tr>
						<td>
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'furtherContentToBeDetermined'" />
							</xsl:call-template>
						</td>
					</tr>
					<tr>
						<td>
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'decorIconsBy'" />
								<xsl:with-param name="p1" select="'http://www.axialis.com/free/icons'" />
								<xsl:with-param name="p2" select="'http://www.axialis.com'" />
								<xsl:with-param name="p3" select="'Axialis Team'" />
							</xsl:call-template>
						</td>
					</tr>
				</table>
			</div>
		</xsl:variable>
		<xsl:call-template name="doTabs4ThisTab">
			<xsl:with-param name="actualtab" select="'tabLegal'" />
			<xsl:with-param name="actualcontent" select="$content9" />
		</xsl:call-template>
	</xsl:template>
	
	<!-- iEHR.eu extension: Business rules -->
	<xsl:template name="getParentTemplates">
		<xsl:param name="templateId"/>		
		<xsl:param name="effectiveDate"/>
		<xsl:if test="$templateId">
			<xsl:variable name="parentTemplateId" select="//rules/template[@id=$templateId and @effectiveDate=$effectiveDate]/relationship[@type='SPEC']/@template"/>
			<xsl:variable name="parentTemplateEffectiveDate" select="//rules/template[@id=$templateId and @effectiveDate=$effectiveDate]/relationship[@type='SPEC']/@flexibility"/>
			<xsl:if test="$parentTemplateId">
				<xsl:call-template name="getParentTemplates">
					<xsl:with-param name="templateId" select="$parentTemplateId"/>
					<xsl:with-param name="effectiveDate" select="$parentTemplateEffectiveDate"/>
				</xsl:call-template>
				<template>
					<name><xsl:value-of select="//rules/template[@id=$parentTemplateId and @effectiveDate=$effectiveDate]/@name"/></name>
					<effectiveDate><xsl:value-of select="$effectiveDate"/></effectiveDate>
				</template>
			</xsl:if>
		</xsl:if>		
	</xsl:template>

	<!-- 07.11.2015: Business rules support removed -->
	<!--<xsl:template name="doBusinessRules">
		<xsl:param name="template" />
		<xsl:if test="$isBusinessRulesFileAvailable and $template">
			<xsl:variable name="outputFileName" select="concat('business-rules-',$template/@id, '-', replace($template/@effectiveDate,':',''),'.html')"/>
			<xsl:variable name="templateNames">
				<xsl:call-template name="getParentTemplates">
					<xsl:with-param name="templateId" select="$template/@id" />
					<xsl:with-param name="effectiveDate" select="$template/@effectiveDate"/>
				</xsl:call-template>
				<template>
					<name><xsl:value-of select="$template/@name" /></name>
					<effectiveDate><xsl:value-of select="$template/@effectiveDate"/></effectiveDate>
				</template>
			</xsl:variable>
			<xsl:variable name="businessRules" select="document($businessRulesPath)/businessRules/template[@name=$templateNames/template/name]/rule" />
			<xsl:variable name="replacedRules" select="$businessRules[@replacedRuleId]/@replacedRuleId" />
			<xsl:variable name="notApplicableRules" select="$businessRules[boolean(@notApplicable)=true()]/@id"/>

			<xsl:call-template name="logMessage">
				<xsl:with-param name="level" select="$logINFO" />
				<xsl:with-param name="msg">
					<xsl:text>*** Creating HTML file with business rules for template </xsl:text>
					<xsl:value-of select="$template/@id" />
					<xsl:text> (iEHR.eu extension)</xsl:text>
				</xsl:with-param>
			</xsl:call-template>

			<xsl:variable name="content">
				<div class="TabbedPanelsContent">
					<h2>
						<xsl:call-template name="getMessage">
							<xsl:with-param name="key" select="'businessRulesHeader'"/>
							<xsl:with-param name="p1" select="$template/@displayName"/>
						</xsl:call-template>
					</h2>
					<table class="business-rules">
						<xsl:for-each select="$businessRules">
							<xsl:variable name="isDeprecated" select="@deprecated and boolean(@deprecated) = true()"/>
							<xsl:if test="not(@id=$replacedRules) and not(@id=$notApplicableRules)">
								<tr>
									<td>
										<xsl:if test="$isDeprecated = true()">
											<xsl:attribute name="class" select="'deprecated'"/>
										</xsl:if>
										<xsl:value-of select="@id" />
									</td>
									<td>
										<xsl:choose>
											<xsl:when test="$isDeprecated = true()">
												<xsl:attribute name="class" select="'deprecated'"/>
												<xsl:call-template name="getMessage">
													<xsl:with-param name="key" select="'deprecatedBusinessRule'"/>
												</xsl:call-template>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="text[@language=$defaultLanguage]" />
											</xsl:otherwise>
										</xsl:choose>
									</td>
								</tr>
							</xsl:if>
						</xsl:for-each>
					</table>
				</div>
			</xsl:variable>
			<xsl:call-template name="doTabs4ThisTab">
				<xsl:with-param name="actualtab" select="'tabBusinessRules'" />
				<xsl:with-param name="actualcontent" select="$content" />
				<xsl:with-param name="fileName" select="$outputFileName" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>-->
	
	<!-- iEHR.eu extension: CDA examples -->
	<xsl:template name="doExamples">
		<xsl:if test="count($examples/example)>0">

			<xsl:call-template name="logMessage">
				<xsl:with-param name="level" select="$logINFO" />
				<xsl:with-param name="msg">
					<xsl:text>*** Creating HTML files for CDA examples (iEHR.eu extension)</xsl:text>
				</xsl:with-param>
			</xsl:call-template>

			<xsl:for-each select="distinct-values($examples/example/@templateId)">				
				<xsl:variable name="examples" select="$examples/example[@templateId=current()]" />
				<xsl:variable name="template" select="$allDECOR/rules/template[@id=current() and xs:dateTime(@effectiveDate)=$latestVersion]"/>
				<xsl:if test="$template">
					<xsl:variable name="outputFileName" select="concat('examples-', $template/@id, '-', replace($template/@effectiveDate,':',''),'.html')" />
					<xsl:variable name="content">
						<div class="TabbedPanelsContent">
							<div id="Accordionrl" class="Accordion" tabindex="0">
								<h2>
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'examplesHeader'"/>
										<xsl:with-param name="p1" select="$template/@displayName"/>
									</xsl:call-template>
								</h2>
								<xsl:for-each select="$examples">			
									<div class="AccordionPanelTab">
										<h3 id="example-{generate-id(.)}" class="acco" onclick="toggleZoomImg(this,'zoomout','{$theAssetsDir}');">
											<xsl:value-of select="@title" />
											<xsl:text> </xsl:text>
											<!-- TEMP: Temporaty removal on 04.12.2017
											<a>
												<xsl:attribute name="href" select="concat('../',@src)"/>
												<xsl:call-template name="getMessage">
													<xsl:with-param name="key" select="'examplesPreview'"/>
												</xsl:call-template>
											</a>
											-->
										</h3>
									</div>
									<div class="AccordionPanelContent example-content">
										<xsl:apply-templates select="document(@src)/(*|comment())" mode="explrender"/>
									</div>
								</xsl:for-each>
							</div>
						</div>
					</xsl:variable>
					
					<xsl:call-template name="doTabs4ThisTab">
						<xsl:with-param name="actualtab" select="'tabExamples'" />
						<xsl:with-param name="actualcontent" select="$content" />
						<xsl:with-param name="fileName" select="$outputFileName"/>
					</xsl:call-template>
				</xsl:if>

			</xsl:for-each>
		</xsl:if>
	</xsl:template>
	
	<!-- iEHR.eu extension: Change log -->
	<xsl:template name="doChangeLog">
		<xsl:call-template name="logMessage">
			<xsl:with-param name="level" select="$logINFO" />
			<xsl:with-param name="msg">
				<xsl:text>*** Creating HTML file for version change log (iEHR.eu extension)</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
		
		
		<xsl:variable name="content">
			<div class="TabbedPanelsContent">
				<h2>
					<xsl:call-template name="getMessage">
						<xsl:with-param name="key" select="'changeLogHeader'"/>
					</xsl:call-template>
				</h2>
				<xsl:for-each select="$allDECOR/project/version">
					<xsl:sort select="xs:dateTime(@date)" order="descending"/>
					<xsl:if test="desc[@language=$defaultLanguage]">
						<div>
							<xsl:copy-of select="desc[@language=$defaultLanguage]"/>
						</div>
					</xsl:if>	
				</xsl:for-each>
			</div>
		</xsl:variable>
			
		<xsl:call-template name="doTabs4ThisTab">
			<xsl:with-param name="actualtab" select="'tabChangeLog'" />
			<xsl:with-param name="actualcontent" select="$content" />
			<xsl:with-param name="fileName" select="'changelog.html'"/>
		</xsl:call-template>
	</xsl:template>
	
	<!-- iEHR.eu extension: ClaML dictionaries list -->
	<xsl:template name="doDictionaries">
		<xsl:if test="count($dictionaries/dictionary)>0">

			<xsl:call-template name="logMessage">
				<xsl:with-param name="level" select="$logINFO" />
				<xsl:with-param name="msg">
					<xsl:text>*** Creating HTML file for coding systems (iEHR.eu extension)</xsl:text>
				</xsl:with-param>
			</xsl:call-template>

			<xsl:variable name="content">
				<div class="TabbedPanelsContent">
					<div id="Accordionrl" class="Accordion" tabindex="0">
						<h2>
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'dictionariesHeader'"/>
							</xsl:call-template>
						</h2>
						<xsl:for-each select="$dictionaries/dictionary">
							<xsl:sort select="@title"/>			
							<div class="AccordionPanelTab">
								<h3 id="dictionary-{generate-id(.)}" class="acco" onclick="toggleZoomImg(this,'zoomout','{$theAssetsDir}');">
									<xsl:value-of select="@title" />
								</h3>
							</div>
							<div class="AccordionPanelContent">
								<xsl:apply-templates select="document(@src)/ClaML"/>
							</div>
						</xsl:for-each>
					</div>
				</div>
			</xsl:variable>
			
			<xsl:call-template name="doTabs4ThisTab">
				<xsl:with-param name="actualtab" select="'tabDictionaries'" />
				<xsl:with-param name="actualcontent" select="$content" />
			</xsl:call-template>

		</xsl:if>
	</xsl:template>
	

	<!-- iEHR.eu extension: CDA extensions schema tab -->
	<xsl:template name="doExtensionsSchemaTab">
		<xsl:if test="$isExtensionsSchemaFileAvailable = true()">

			<xsl:call-template name="logMessage">
				<xsl:with-param name="level" select="$logINFO" />
				<xsl:with-param name="msg">
					<xsl:text>*** Creating HTML file for CDA extensions schema (iEHR.eu extension)</xsl:text>
				</xsl:with-param>
			</xsl:call-template>

			<xsl:variable name="content">
				<div class="TabbedPanelsContent">
					<h2>
						<xsl:call-template name="getMessage">
							<xsl:with-param name="key" select="'extensionsSchemaHeader'"/>
						</xsl:call-template>
						<xsl:text> </xsl:text>
						<a>
							<xsl:attribute name="href" select="concat('../',$extensionsSchemaPath)"/>
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'extensionsSchemaDownload'"/>
							</xsl:call-template>
						</a>
					</h2>
					<div class="example-content">
						<xsl:apply-templates select="document($extensionsSchemaPath)/(*|comment())" mode="explrender" />
					</div>
				</div>
			</xsl:variable>
			<xsl:call-template name="doTabs4ThisTab">
				<xsl:with-param name="actualtab" select="'tabExtensionsSchema'" />
				<xsl:with-param name="actualcontent" select="$content" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- iEHR.eu extension: OID registry tab -->
	<xsl:template name="doOidRegistryTab">
		<xsl:if test="$isOidRegistryFileAvailable = true()">

			<xsl:call-template name="logMessage">
				<xsl:with-param name="level" select="$logINFO" />
				<xsl:with-param name="msg">
					<xsl:text>*** Creating HTML file for OID registry (iEHR.eu extension)</xsl:text>
				</xsl:with-param>
			</xsl:call-template>

			<xsl:variable name="content">
				<div class="TabbedPanelsContent">
					<xsl:if test="$oidSpecificationFileName">
						<a>
							<xsl:attribute name="href">
								<xsl:text>../</xsl:text>
								<xsl:value-of select="$oidSpecificationFileName"/>
							</xsl:attribute>
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'actualProposalDownload'"/>
							</xsl:call-template>
						</a>
					</xsl:if>
					<xsl:apply-templates select="document($oidRegistryPath)/myoidregistry"/>
				</div>
			</xsl:variable>

			<xsl:call-template name="doTabs4ThisTab">
				<xsl:with-param name="actualtab" select="'tabOidRegistry'" />
				<xsl:with-param name="actualcontent" select="$content" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<!-- (XSLT)) -->
	<xsl:template name="doVisualizationTab">
		<xsl:variable name="ROOT_PATH" select="concat(string-join(tokenize(base-uri(),'/')[position()&lt;last()],'/'),'/')"/>
		<xsl:variable name="EXAMPLES_INDEX_PATH" select="concat($ROOT_PATH,'examples/')"/>
		<xsl:variable name="EXAMPLES_INDEX_FILE" select="concat($ROOT_PATH,'examples/index.xml')"/>
		
		<xsl:variable name="EXAMPLES_INDEX">
			<xsl:choose>
				<xsl:when test="doc-available($EXAMPLES_INDEX_FILE)">
					<xsl:copy-of select="doc($EXAMPLES_INDEX_FILE)/*"/>
				</xsl:when>
				<xsl:otherwise>
					<Index/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		
		<xsl:if test="count($EXAMPLES_INDEX//example)>0">
			
			<xsl:call-template name="logMessage">
				<xsl:with-param name="level" select="$logINFO" />
				<xsl:with-param name="msg">
					<xsl:text>*** Creating HTML file for Visualization (XSLT) tab (iEHR.eu extension)</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
			
				
			<xsl:variable name="content">
				<div class="TabbedPanelsContent">
					<div id="Accordionrl" class="Accordion" tabindex="0">
						<h2>
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'visualizationHeader'"/>
							</xsl:call-template>
						</h2>
						<h3>
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'visualizationPageIntroSubheader'"/>
							</xsl:call-template>
						</h3>
						<xsl:call-template name="getMessage">
							<xsl:with-param name="key" select="'visualizationPageIntro'"/>
							<xsl:with-param name="p1">
								<xsl:text>../data/Transformata_XSLT_CDA_PL_IG_</xsl:text>
								<xsl:value-of select="$currentRelease/@versionLabel"/>
								<xsl:text>.zip</xsl:text>
							</xsl:with-param>
						</xsl:call-template>
						<h3>
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'visualizationExamplesSubheader'"/>
							</xsl:call-template>
						</h3>
						<table class="document-templates">
						<xsl:for-each select="$examples/example">			
							<tr>
								<td>
									<xsl:text>[</xsl:text>
									<xsl:value-of select="position()"/>
									<xsl:text>]</xsl:text>
								</td>
								<td>
									<a>
										<xsl:attribute name="href" select="concat('../',@src)"/>
										<xsl:value-of select="@title" />
									</a>
								</td>
							</tr>
						</xsl:for-each>
						</table>
					</div>
				</div>
			</xsl:variable>
			<xsl:call-template name="doTabs4ThisTab">
				<xsl:with-param name="actualtab" select="'tabVisualization'" />
				<xsl:with-param name="actualcontent" select="$content" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	

	<xsl:template name="doProjectInfo">

		<!--h3> <xsl:call-template name="getMessage"> <xsl:with-param name="key" select="'tabProjectInfoProject'"/> </xsl:call-template> </h3> <strong> <xsl:call-template name="doName"> <xsl:with-param name="ns" 
			select="//project/name"/> </xsl:call-template> </strong -->

		<!--h3> <xsl:call-template name="getMessage"> <xsl:with-param name="key" select="'tabProjectInfoDefaultLanguage'"/> </xsl:call-template> </h3> <xsl:value-of select="//project/@defaultLanguage"/ -->
		<xsl:choose>
			<xsl:when test="count(//project/desc[string-length(.)&gt;0])">
				<!--h3> <xsl:call-template name="getMessage"> <xsl:with-param name="key" select="'tabProjectInfoDescription'"/> </xsl:call-template> </h3 -->
				<xsl:call-template name="doDescription">
					<xsl:with-param name="ns" select="//project/desc[string-length(.)&gt;0]" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="getMessage">
					<xsl:with-param name="key" select="'tabProjectInfoMissing'" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>

		<h3>
			<xsl:call-template name="getMessage">
				<xsl:with-param name="key" select="'tabProjectInfoAdditional'" />
			</xsl:call-template>
		</h3>
		<table border="0">
			<tr>
				<td class="tabtab">
					<table width="100%" border="0" cellspacing="3" cellpadding="2">

						<xsl:if test="$projectIsRepository or $projectIsPrivate">
							<tr>
								<th align="left" colspan="3">
									<xsl:call-template name="doPrivateRepositoryNotice" />
								</th>
							</tr>
						</xsl:if>
						<tr class="headinglabel">
							<th align="left">
								<xsl:call-template name="getMessage">
									<xsl:with-param name="key" select="'tabProjectInfoArtifactPrefix'" />
								</xsl:call-template>
							</th>
							<th colspan="2" align="left">
								<xsl:call-template name="getMessage">
									<xsl:with-param name="key" select="'tabProjectInfoReferenceURI'" />
								</xsl:call-template>
							</th>
						</tr>
						<tr>
							<td>
								<xsl:value-of select="//project/@prefix" />
							</td>
							<td align="left" colspan="2">
								<a href="{$seeURLprefix}">
									<xsl:value-of select="$seeURLprefix" />
								</a>
							</td>
						</tr>

						<tr class="headinglabel">
							<th align="left">
								<xsl:call-template name="getMessage">
									<xsl:with-param name="key" select="'tabProjectInfoDefaultLanguage'" />
								</xsl:call-template>
							</th>
							<th colspan="2" align="left">
								<xsl:call-template name="getMessage">
									<xsl:with-param name="key" select="'tabProjectTemplateElementNamespace'" />
								</xsl:call-template>
							</th>
						</tr>
						<tr>
							<td>
								<xsl:value-of select="//project/@defaultLanguage" />
							</td>
							<td colspan="2" align="left">
								<xsl:value-of select="$projectDefaultElementNamespace" />
							</td>
						</tr>

						<tr class="headinglabel">
							<th align="left" colspan="3">
								<xsl:call-template name="getMessage">
									<xsl:with-param name="key" select="'tabProjectInfoDisclaimer'" />
								</xsl:call-template>
							</th>
						</tr>
						<tr>
							<td align="left" colspan="3">
								<xsl:value-of select="$disclaimer" />
							</td>
						</tr>

						<xsl:if test="//project/author">
							<tr class="headinglabel">
								<th colspan="3" align="left">
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'tabProjectInfoAuthorList'" />
									</xsl:call-template>
								</th>
							</tr>
							<tr>
								<td align="left" colspan="3">
									<ul>
										<xsl:for-each select="//project/author">
											<li>
												<xsl:value-of select="." />
											</li>
										</xsl:for-each>
									</ul>
								</td>
							</tr>
						</xsl:if>

					</table>
				</td>
			</tr>
		</table>

		<h3>
			<xsl:call-template name="getMessage">
				<xsl:with-param name="key" select="'tabProjectInfoVersionInfo'" />
			</xsl:call-template>
		</h3>
		<table width="100%" border="0">
			<tr>
				<td class="tabtab">
					<table width="100%" border="0" cellspacing="3" cellpadding="2">

						<tr class="headinglabel">
							<th align="left">
								<xsl:call-template name="getMessage">
									<xsl:with-param name="key" select="'tabProjectInfoAuthorDate'" />
								</xsl:call-template>
							</th>
							<th align="left">
								<xsl:call-template name="getMessage">
									<xsl:with-param name="key" select="'tabProjectInfoAuthorBy'" />
								</xsl:call-template>
							</th>
							<th align="left">
								<xsl:call-template name="getMessage">
									<xsl:with-param name="key" select="'tabProjectInfoAuthorDescription'" />
								</xsl:call-template>
							</th>
						</tr>
						<xsl:for-each select="//project/version | //project/release">
							<xsl:sort select="@date" order="descending" />
							<xsl:choose>
								<xsl:when test="name()='release'">
									<tr>
										<th valign="top">
											<xsl:call-template name="showDate">
												<xsl:with-param name="date" select="@date" />
											</xsl:call-template>
										</th>
										<th valign="top">
											<xsl:value-of select="@by" />
										</th>
										<td valign="top">
											<b>
												<xsl:call-template name="getMessage">
													<xsl:with-param name="key" select="'tabProjectInfoReleaseLabel'" />
												</xsl:call-template>
												<xsl:if test="@versionLabel">
													<xsl:text>: </xsl:text>
													<xsl:value-of select="@versionLabel" />
												</xsl:if>
											</b>
											<br />
											<xsl:call-template name="doDescription">
												<xsl:with-param name="ns" select="desc|note" />
											</xsl:call-template>
										</td>
									</tr>
								</xsl:when>
								<xsl:otherwise>
									<tr>
										<td valign="top">
											<xsl:call-template name="showDate">
												<xsl:with-param name="date" select="@date" />
											</xsl:call-template>
										</td>
										<td valign="top">
											<xsl:value-of select="@by" />
										</td>
										<td valign="top">
											<xsl:call-template name="doDescription">
												<xsl:with-param name="ns" select="desc" />
											</xsl:call-template>
										</td>
									</tr>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</table>
				</td>
			</tr>
		</table>
	</xsl:template>

	<xsl:template name="doPrivateRepositoryNotice">
		<xsl:variable name="projectIsRepository" select="/decor[string(@repository)='true']" />
		<xsl:variable name="projectIsPrivate" select="/decor[string(@private)='true']" />

		<xsl:choose>
			<xsl:when test="$projectIsRepository and $projectIsPrivate">
				<xsl:call-template name="showIcon">
					<xsl:with-param name="which">
						notice
					</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="getMessage">
					<xsl:with-param name="key" select="'noticeIsPrivateRepository'" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$projectIsRepository">
				<xsl:call-template name="showIcon">
					<xsl:with-param name="which">
						notice
					</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="getMessage">
					<xsl:with-param name="key" select="'noticeIsRepository'" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$projectIsPrivate">
				<xsl:call-template name="showIcon">
					<xsl:with-param name="which">
						notice
					</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="getMessage">
					<xsl:with-param name="key" select="'noticeIsPrivate'" />
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="doDataset">
		<xsl:param name="nestingWithTables" select="true()" />

		<!-- show data set meta data -->
		<table width="100%" border="0" cellspacing="3" cellpadding="2">

			<tr class="headinglabel">
				<th align="left">
					<xsl:call-template name="getMessage">
						<xsl:with-param name="key" select="'dataSetName'" />
					</xsl:call-template>
				</th>
				<th align="left">
					<xsl:call-template name="getMessage">
						<xsl:with-param name="key" select="'dataSetId'" />
					</xsl:call-template>
				</th>
			</tr>
			<tr>
				<td align="left">
					<xsl:call-template name="doName">
						<xsl:with-param name="ns" select="name" />
					</xsl:call-template>
				</td>
				<td align="left" valign="top">
					<xsl:value-of select="@id" />
					<xsl:value-of select="@ref" />
				</td>
			</tr>
			<tr class="headinglabel">
				<th valign="top" align="left" colspan="2">
					<xsl:call-template name="getMessage">
						<xsl:with-param name="key" select="'Description'" />
					</xsl:call-template>
				</th>
			</tr>
			<tr>
				<td align="left" colspan="2">
					<xsl:call-template name="doDescription">
						<xsl:with-param name="ns" select="desc" />
					</xsl:call-template>
				</td>
			</tr>

			<xsl:if test="count(source)>0">
				<tr class="headinglabel">
					<th align="left" colspan="2">
						<xsl:call-template name="getMessage">
							<xsl:with-param name="key" select="'Source'" />
						</xsl:call-template>
					</th>
				</tr>
				<tr>
					<td align="left" colspan="2">
						<xsl:value-of select="source" />
					</td>
				</tr>
			</xsl:if>

			<xsl:if test="count(rationale)>0">
				<tr class="headinglabel">
					<th align="left" colspan="2">
						<xsl:call-template name="getMessage">
							<xsl:with-param name="key" select="'Rationale'" />
						</xsl:call-template>
					</th>
				</tr>
				<tr>
					<td align="left" colspan="2">
						<xsl:value-of select="rationale" />
					</td>
				</tr>
			</xsl:if>

			<xsl:if test="count(operationalization)>0">
				<tr class="headinglabel">
					<th align="left" colspan="2">
						<xsl:call-template name="getMessage">
							<xsl:with-param name="key" select="'Operationalizations'" />
						</xsl:call-template>
					</th>
				</tr>
				<tr>
					<td align="left" colspan="2">
						<xsl:value-of select="operationalization" />
					</td>
				</tr>
			</xsl:if>
			<!-- <tr class="headinglabel"> <th align="left" colspan="2"> <xsl:call-template name="getMessage"> <xsl:with-param name="key" select="'contentWithColon'"/> </xsl:call-template> </th> </tr> -->
			<xsl:if test="$nestingWithTables=true()">
				<tr>
					<td colspan="2">
						<table width="100%" border="0" cellspacing="2" cellpadding="2">
							<tr valign="top">
								<td class="tabtab">
									<xsl:apply-templates select="concept" mode="dataset">
										<xsl:with-param name="level" select="1" />
									</xsl:apply-templates>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</xsl:if>
		</table>

		<xsl:if test="$nestingWithTables=false()">
			<xsl:apply-templates select="concept" mode="dataset">
				<xsl:with-param name="level" select="1" />
				<xsl:with-param name="nestingWithTables" select="$nestingWithTables" />
			</xsl:apply-templates>
		</xsl:if>

	</xsl:template>

	<xsl:template name="doScenarios">

		<!-- param not yet implemented -->
		<xsl:param name="nestingWithTables" select="true()" />

		<!-- whether contained concept appear in a toggler -->
		<xsl:param name="conceptToggler" select="true()" />

		<xsl:if test="not($nestingWithTables=true())">
			<xsl:call-template name="logMessage">
				<xsl:with-param name="level" select="$logINFO" />
				<xsl:with-param name="msg">
					<xsl:text>+++ TODO (DECOR2html.xsl), feature called but not implemented yet: template name="doScenarios" with nestingWithTables!=true()</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>

		<!-- show data set meta data -->
		<table width="100%" border="0" cellspacing="3" cellpadding="2">

			<tr class="headinglabel">
				<th align="left">
					<xsl:call-template name="getMessage">
						<xsl:with-param name="key" select="'Name'" />
					</xsl:call-template>
				</th>
				<th align="left">
					<xsl:call-template name="getMessage">
						<xsl:with-param name="key" select="'Id'" />
					</xsl:call-template>
				</th>
			</tr>
			<tr>
				<td align="left">
					<xsl:call-template name="doName">
						<xsl:with-param name="ns" select="name" />
					</xsl:call-template>
				</td>
				<td align="left" valign="top">
					<xsl:call-template name="doShorthandId">
						<xsl:with-param name="id" select="@id" />
					</xsl:call-template>
				</td>
			</tr>
			<xsl:if test="string-length(desc[1])>0">
				<tr class="headinglabel">
					<th valign="top" align="left" colspan="2">
						<xsl:call-template name="getMessage">
							<xsl:with-param name="key" select="'Description'" />
						</xsl:call-template>
					</th>
				</tr>
				<tr>
					<td align="left" colspan="2">
						<xsl:call-template name="doDescription">
							<xsl:with-param name="ns" select="desc" />
						</xsl:call-template>
					</td>
				</tr>
			</xsl:if>
			<xsl:if test="trigger">
				<tr>
					<td>
						<xsl:call-template name="getMessage">
							<xsl:with-param name="key" select="'scenarioTrigger'" />
						</xsl:call-template>
					</td>
					<td>
						<xsl:call-template name="doDescription">
							<xsl:with-param name="ns" select="trigger" />
						</xsl:call-template>
					</td>
				</tr>
			</xsl:if>
			<xsl:if test="condition">
				<tr>
					<td>
						<xsl:call-template name="getMessage">
							<xsl:with-param name="key" select="'scenarioCondition'" />
						</xsl:call-template>
					</td>
					<td>
						<xsl:call-template name="doDescription">
							<xsl:with-param name="ns" select="condition" />
						</xsl:call-template>
					</td>
				</tr>
			</xsl:if>

			<xsl:if test="$nestingWithTables=true()">
				<xsl:for-each select="transaction">
					<tr>
						<td colspan="2" class="tabtab">
							<table width="100%" border="0" cellspacing="3" cellpadding="2">
								<xsl:apply-templates select=".">
									<xsl:with-param name="nestingWithTables" select="$nestingWithTables" />
									<xsl:with-param name="conceptToggler" select="$conceptToggler" />
								</xsl:apply-templates>
							</table>
						</td>
					</tr>
				</xsl:for-each>
			</xsl:if>
		</table>

		<xsl:if test="$nestingWithTables=false()">
			<xsl:apply-templates select="transaction" mode="scenario">
				<xsl:with-param name="level" select="1" />
				<xsl:with-param name="nestingWithTables" select="$nestingWithTables" />
				<xsl:with-param name="conceptToggler" select="$conceptToggler" />
			</xsl:apply-templates>
		</xsl:if>

	</xsl:template>

	<xsl:template name="doIdentifiers">
        <h2>
            <a name="labelIdentifiers">
                <xsl:call-template name="getMessage">
                    <xsl:with-param name="key" select="'tabIdentifiersTitleString'"/>
                </xsl:call-template>
            </a>
        </h2>
        <p>
            <xsl:call-template name="getMessage">
                <xsl:with-param name="key" select="'tabIdentifiersRenderingRemark'"/>
            </xsl:call-template>
        </p>

        <xsl:variable name="sortedID">
            <sortedID>
                <xsl:for-each select="//ids/id">
                    <xsl:sort select="replace(replace (concat(@root, '.'), '\.', '.0000000000'), '.0*([0-9]{9,})', '.$1')"/>
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </sortedID>
        </xsl:variable>

        <div id="Accordionid" class="Accordion" tabindex="0">

            <xsl:for-each select="$sortedID/sortedID/id">
                <xsl:variable name="theRoot" select="@root"/>
                <div class="AccordionPanel">
                    <div class="AccordionPanelTab">
                        <h3 class="acco" onclick="toggleZoomImg(this,'zoomout','{$theAssetsDir}');">
                            <xsl:choose>
                                <xsl:when test="count(designation[@language=$defaultLanguage])>0">
                                    <i>
                                        <xsl:value-of select="designation[@language=$defaultLanguage]/@displayName"/>
                                    </i>
                                </xsl:when>
                                <!-- Do we have en-US at all? -->
                                <xsl:when test="count(designation[@language='en-US'])>0">
                                    <i>
                                        <xsl:value-of select="designation[@language='en-US']/@displayName"/>
                                    </i>
                                </xsl:when>
                                <xsl:when test="count(designation[@language='en-EN'])>0">
                                    <i>
                                        <xsl:value-of select="designation[@language='en-EN']/@displayName"/>
                                    </i>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:text>&#160;</xsl:text>
                            <xsl:value-of select="$theRoot"/>
                        </h3>
                    </div>
                    <div class="AccordionPanelContent">
                        <table border="0" cellspacing="10">
                            <tr>
                                <td class="tabtab">
                                    <table width="100%" border="0" cellspacing="3" cellpadding="2">
                                        <tr class="headinglabel" valign="top">
                                            <th align="left">
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'idLanguage'"/>
                                                </xsl:call-template>
                                            </th>
                                            <th align="left">
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'DisplayName'"/>
                                                </xsl:call-template>
                                            </th>
                                            <th valign="top" align="left">
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'Description'"/>
                                                </xsl:call-template>
                                            </th>
                                            <th align="left">
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'idPreferred'"/>
                                                </xsl:call-template>
                                            </th>
                                        </tr>
                                        <xsl:for-each select="designation">
                                            <tr>
                                                <td>
                                                    <xsl:value-of select="@language"/>
                                                </td>
                                                <td>
                                                    <xsl:value-of select="@displayName"/>
                                                </td>
                                                <td>
                                                    <xsl:value-of select="text()"/>
                                                </td>
                                                <td>
                                                    <xsl:choose>
                                                        <xsl:when test="@preferredForLanguage='true'">
                                                            <xsl:call-template name="getMessage">
                                                                <xsl:with-param name="key" select="'yes'"/>
                                                            </xsl:call-template>
                                                        </xsl:when>
                                                    </xsl:choose>
                                                </td>
                                            </tr>
                                        </xsl:for-each>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
            </xsl:for-each>
        </div>

        <h2>
            <xsl:call-template name="getMessage">
                <xsl:with-param name="key" select="'listOfTemplateIdentifiersInThisProject'"/>
            </xsl:call-template>
        </h2>

        <xsl:variable name="sortedTMPID">
            <xsl:for-each select="//template">
                <xsl:sort select="replace(replace (concat(@id, '.'), '\.', '.0000000000'), '.0*([0-9]{9,})', '.$1')"/>
                <sortedTMPID>
                    <xsl:copy-of select="@id|@displayName|@effectiveDate|@name"/>
                </sortedTMPID>
            </xsl:for-each>
        </xsl:variable>
        <table border="0" cellspacing="10">
            <tr>
                <td class="tabtab">
                    <table width="100%" border="0" cellspacing="3" cellpadding="2">
                        <tr class="headinglabel" valign="top">
                            <th align="left">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'Id'"/>
                                </xsl:call-template>
                            </th>
                            <th align="left">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'DisplayName'"/>
                                </xsl:call-template>
                            </th>
                            <th align="left">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'Name'"/>
                                </xsl:call-template>
                            </th>
                            <th align="left">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'EffectiveDate'"/>
                                </xsl:call-template>
                            </th>
                            <th align="left">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'Type'"/>
                                </xsl:call-template>
                            </th>
                        </tr>
                        <xsl:for-each select="$sortedTMPID/sortedTMPID">
                            <xsl:variable name="id" select="@id"/>
                            <xsl:variable name="name" select="@name"/>
                            <xsl:variable name="efd" select="@effectiveDate"/>
                            <tr valign="top">
                                <td valign="top">
                                    <a href="tmp-{@id}-{replace($efd,':','')}.html" target="_blank">
                                        <xsl:value-of select="@id"/>
                                    </a>
                                </td>
                                <td valign="top">
                                    <xsl:value-of select="@displayName"/>
                                </td>
                                <td valign="top">
                                    <xsl:value-of select="@name"/>
                                </td>
                                <td valign="top">
                                    <xsl:call-template name="showDate">
                                        <xsl:with-param name="date" select="@effectiveDate"/>
                                    </xsl:call-template>
                                </td>
                                <td valign="top">
                                    <xsl:value-of select="classification/@type"/>
                                </td>
                            </tr>
                            <xsl:variable name="errmsg">
                                <xsl:if test="count(../*[@id = $id][@effectiveDate = $efd])>1">
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'possibleConflictingDuplicateIds'"/>
                                    </xsl:call-template>
                                </xsl:if>
                                <xsl:if test="count(../*[@name = $name][not((@id|@ref) = $id)])>1">
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'possibleConflictingDuplicateNames'"/>
                                    </xsl:call-template>
                                </xsl:if>
                            </xsl:variable>
                            <xsl:if test="string-length($errmsg)>0">
                                <tr>
                                    <td> </td>
                                    <td colspan="3">
                                        <table border="0">
                                            <xsl:call-template name="doMessage">
                                                <xsl:with-param name="level" select="'warning'"/>
                                                <xsl:with-param name="msg" select="$errmsg"/>
                                            </xsl:call-template>
                                        </table>
                                    </td>
                                </tr>
                            </xsl:if>

                        </xsl:for-each>

                    </table>
                </td>
            </tr>
        </table>

        <h2>
            <xsl:call-template name="getMessage">
                <xsl:with-param name="key" select="'listOfValueSetIdentifiersInThisProject'"/>
            </xsl:call-template>
        </h2>

        <xsl:variable name="sortedVSID">
            <xsl:for-each select="$allValueSets/*/valueSet">
                <xsl:sort select="replace(replace (concat((@id|@ref), '.'), '\.', '.0000000000'), '.0*([0-9]{9,})', '.$1')"/>
                <xsl:sort select="@name"/>
                <xsl:sort select="@effectiveDate"/>
                <sortedVSID>
                    <xsl:copy-of select="@id|@ref|@displayName|@effectiveDate|@name"/>
                </sortedVSID>
            </xsl:for-each>
        </xsl:variable>
        <table border="0" cellspacing="10">
            <tr>
                <td class="tabtab">
                    <table width="100%" border="0" cellspacing="3" cellpadding="2">
                        <tr class="headinglabel" valign="top">
                            <th align="left">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'Id'"/>
                                </xsl:call-template>
                            </th>
                            <th align="left">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'DisplayName'"/>
                                </xsl:call-template>
                            </th>
                            <th align="left">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'Name'"/>
                                </xsl:call-template>
                            </th>
                            <th align="left">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'EffectiveDate'"/>
                                </xsl:call-template>
                            </th>
                        </tr>
                        <xsl:for-each select="$sortedVSID/sortedVSID">
                            <xsl:variable name="id" select="(@id|@ref)"/>
                            <xsl:variable name="name" select="@name"/>
                            <xsl:variable name="efd" select="@effectiveDate"/>
                            <tr valign="top">
                                <td valign="top">
                                    <a href="voc-{$id}-{replace($efd,':','')}.html" target="_blank">
                                        <xsl:value-of select="$id"/>
                                    </a>
                                </td>
                                <td valign="top">
                                    <xsl:value-of select="@displayName"/>
                                </td>
                                <td valign="top">
                                    <xsl:value-of select="@name"/>
                                </td>
                                <td valign="top">
                                    <xsl:call-template name="showDate">
                                        <xsl:with-param name="date" select="@effectiveDate"/>
                                    </xsl:call-template>
                                </td>
                            </tr>
                            <xsl:variable name="errmsg">
                                <xsl:if test="count(../*[@id = $id][@effectiveDate = $efd])>1">
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'possibleConflictingDuplicateIds'"/>
                                    </xsl:call-template>
                                </xsl:if>
                                <xsl:if test="count(../*[@name = $name][not((@id|@ref) = $id)])>1">
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'possibleConflictingDuplicateNames'"/>
                                    </xsl:call-template>
                                </xsl:if>
                            </xsl:variable>
                            <xsl:if test="string-length($errmsg)>0">
                                <tr>
                                    <td> </td>
                                    <td colspan="3">
                                        <table border="0">
                                            <xsl:call-template name="doMessage">
                                                <xsl:with-param name="level" select="'warning'"/>
                                                <xsl:with-param name="msg" select="$errmsg"/>
                                            </xsl:call-template>
                                        </table>
                                    </td>
                                </tr>
                            </xsl:if>
                        </xsl:for-each>

                    </table>
                </td>
            </tr>
        </table>
    </xsl:template>

	<xsl:template match="template" mode="showpreliminaries">

        <xsl:param name="underlyingModel"/>
        <xsl:param name="resultingRule"/>
        <xsl:param name="direction"/>
        <xsl:param name="onespacebetweenheaderparticlesonly" select="false()"/>

        <xsl:text>&#10;&#10;</xsl:text>
        <!-- 
            create the template name description
            an @id and a @name is mandatory per template
            give human readable @displayName preference (if present) over pure @name
            if @name and @displayName are identical, print only once
        -->
        <xsl:variable name="templatename">
            <xsl:choose>
                <xsl:when test="string-length(@displayName)>0">
                    <xsl:value-of select="@displayName"/>
                    <xsl:if test="@name and (@name != @displayName)">
                        <i>
                            <xsl:text> / </xsl:text>
                            <xsl:value-of select="@name"/>
                        </i>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="string-length(@name)>0">
                    <i>
                        <xsl:value-of select="@name"/>
                    </i>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="getMessage">
                        <xsl:with-param name="key" select="'rulesNoNameOrDisplaynameDefinedYet'"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!--div class="AccordionPanel">
            <div class="AccordionPanelTab"-->
        <h3 class="acco" onclick="window.open('tmp-{@id}-{replace(@effectiveDate,':','')}.html')">

            <xsl:call-template name="showStatusDot">
                <xsl:with-param name="status">
                    <xsl:choose>
                        <xsl:when test="@ident">
                            <xsl:value-of select="'ref'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="@statusCode"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
            </xsl:call-template>

            <xsl:text>&#160;</xsl:text>
            <xsl:copy-of select="$templatename"/>

            <xsl:if test="$onespacebetweenheaderparticlesonly=false()">
                <!-- correction for printing re/ spaces between headline particles -->
                <xsl:text>&#160;</xsl:text>
            </xsl:if>
            <xsl:text>&#160;</xsl:text>
            <xsl:value-of select="@id"/>
            
            <xsl:if test="$onespacebetweenheaderparticlesonly=false()">
                <!-- correction for printing re/ spaces between headline particles -->
                <xsl:text>&#160;</xsl:text>
            </xsl:if>

            <xsl:text>&#160;-</xsl:text>
            <xsl:if test="@versionLabel">
                <xsl:text> v</xsl:text>
                <xsl:value-of select="@versionLabel"/>
                <xsl:text> /</xsl:text>
            </xsl:if>

            <xsl:text>&#160;</xsl:text>
            <xsl:call-template name="showDate">
                <xsl:with-param name="date" select="@effectiveDate"/>
            </xsl:call-template>
            
            <xsl:if test="@ident">
                <xsl:text> </xsl:text>
                <span style="padding: 0px 5px 0px 5px; text-align: center; background-color: darkgrey; color: white; font-weight: bold;">ref</span>
                <xsl:text> (</xsl:text>
                <xsl:call-template name="getMessage">
                    <xsl:with-param name="key" select="'fromrepository'"/>
                </xsl:call-template>
                <xsl:text>: </xsl:text>
                <xsl:value-of select="@ident"/>
                <xsl:text>)</xsl:text>
            </xsl:if>

            <!-- in case this is a scenario transaction rule, show data -->
            <xsl:if test="string-length(concat($underlyingModel, $resultingRule))>0">
                <p/>
                <table border="0" cellspacing="2" cellpadding="5" bgcolor="#FFFFFF">
                    <tr class="headinglable">
                        <th colspan="2">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'Direction'"/>
                            </xsl:call-template>
                        </th>
                        <th>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'UnderlyingModel'"/>
                            </xsl:call-template>
                        </th>
                        <th>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'RuleName'"/>
                            </xsl:call-template>
                        </th>
                        <th>Schematron</th>
                    </tr>
                    <tr>
                        <td>
                            <xsl:call-template name="showDirection">
                                <xsl:with-param name="dir" select="$direction"/>
                            </xsl:call-template>
                        </td>
                        <td>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="concat('transactionDirection', $direction)"/>
                            </xsl:call-template>
                        </td>
                        <td>
                            <xsl:value-of select="$underlyingModel"/>
                        </td>
                        <td>
                            <xsl:value-of select="$resultingRule"/>
                        </td>
                        <td>
                            <xsl:value-of select="concat($projectPrefix, $resultingRule, '.sch')"/>
                        </td>
                    </tr>
                </table>
            </xsl:if>
        </h3>
        <!--/div>
            <xsl:text>&#10;&#10;</xsl:text>
            <div class="AccordionPanelContent">
                <xsl:apply-templates select=".">
                    <xsl:with-param name="templatename" select="$templatename"/>
                </xsl:apply-templates>
            </div>
        </div-->
    </xsl:template>

	<xsl:template match="template">
        <xsl:param name="templatename"/>
        <xsl:param name="label"/>

        <!-- cache id, name, effectiveDate and calculate if we're the newest version of the template -->
        <xsl:variable name="tid" select="@id"/>
        <xsl:variable name="teff" select="@effectiveDate"/>
        <xsl:variable name="tname" select="@name"/>
        <xsl:variable name="tIsNewest" select="max($allTemplates/*/ref/template[@id=$tid]/xs:dateTime(@effectiveDate))=$teff"/>

        <!-- create item label to show -->
        <xsl:variable name="itemlabel">
            <xsl:choose>
                <xsl:when test="string-length(item/@label)>0">
                    <!-- use item/@label -->
                    <xsl:value-of select="item/@label"/>
                </xsl:when>
                <xsl:when test="string-length($label)>0">
                    <!-- use inherited label if present -->
                    <xsl:value-of select="$label"/>
                </xsl:when>
                <xsl:when test="string-length(@name)>0">
                    <!-- use (template/@name) as a substitute-->
                    <xsl:text>(</xsl:text>
                    <xsl:value-of select="@name"/>
                    <xsl:text>)</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <!-- use leave it empty -->
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <table width="100%" border="0" cellspacing="3" cellpadding="2">
            <tr>
                <th style="border:1px solid #C0C0C0; width: 107pt;" align="left">
                    <strong>
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'Template'"/>
                        </xsl:call-template>
                        <xsl:if test="count(context)=0">
                            <!-- no context means: internal template -->
                            <xsl:text> (</xsl:text>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'internal'"/>
                            </xsl:call-template>
                            <xsl:text>)</xsl:text>
                        </xsl:if>
                    </strong>
                </th>
                <td align="left" style="background-color: &sandColorLight;">
                    <xsl:copy-of select="$templatename"/>
               
                    <xsl:if test="@ident">
                        <xsl:text> </xsl:text>
                        <span style="padding: 0px 5px 0px 5px; text-align: center; background-color: darkgrey; color: white; font-weight: bold;">ref</span>
                        <xsl:text> (</xsl:text>
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'fromrepository'"/>
                        </xsl:call-template>
                        <xsl:value-of select="@ident"/>
                        <xsl:text>)</xsl:text>
                    </xsl:if>
                </td>
            </tr>

            <!-- show template meta data -->
            <xsl:if test="string-length($tid)>0">
                <tr>
                    <th align="left">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'Id'"/>
                        </xsl:call-template>
                    </th>
                    <td align="left" style="background-color: &sandColorLight;">
                        <xsl:value-of select="$tid"/>
                    </td>
                </tr>
            </xsl:if>

            <!-- classification -->
            <xsl:if test="classification">
                <tr>
                    <th align="left">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'Classification'"/>
                        </xsl:call-template>
                    </th>
                    <td align="left" style="background-color: &sandColorLight;">
                        <xsl:for-each select="classification">
                            <xsl:call-template name="getXFormsLabel">
                                <xsl:with-param name="simpleTypeKey" select="'TemplateTypes'"/>
                                <xsl:with-param name="simpleTypeValue" select="@type"/>
                            </xsl:call-template>
                            <xsl:if test="position()!=last()">
                                <br/>
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
            </xsl:if>

            <!-- relationship -->
            <!-- <relationship type="SPEC" model="" template="" flexibility=""/> -->
            <!-- 2DO model resolving comparable problem to transaction/@model -->
            <!-- 2DO implement links to templates/models if possible -->
            <xsl:if test="relationship">
                <tr>
                    <th align="left">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'Relationship'"/>
                        </xsl:call-template>
                    </th>
                    <td align="left" style="background-color: &sandColorLight;">
                        <xsl:for-each select="relationship">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'tmpRelationship'"/>
                                <xsl:with-param name="p1">
                                    <xsl:call-template name="getXFormsLabel">
                                        <xsl:with-param name="simpleTypeKey" select="'RelationshipTypes'"/>
                                        <xsl:with-param name="simpleTypeValue" select="@type"/>
                                    </xsl:call-template>
                                </xsl:with-param>
                                <xsl:with-param name="p2">
                                    <xsl:choose>
                                        <xsl:when test="@template">
                                            <xsl:call-template name="getMessage">
                                                <xsl:with-param name="key" select="'tmpArtifactTypeTemplate'"/>
                                            </xsl:call-template>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:call-template name="getMessage">
                                                <xsl:with-param name="key" select="'tmpArtifactTypeModel'"/>
                                            </xsl:call-template>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:with-param>
                                <xsl:with-param name="p3">
                                    <xsl:choose>
                                        <xsl:when test="@template">
                                            <xsl:value-of select="@template"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="@model"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:with-param>
                                <xsl:with-param name="p4">
                                    <xsl:choose>
                                        <xsl:when test="matches(@flexibility,'^\d{4}')">
                                            <xsl:call-template name="showDate">
                                                <xsl:with-param name="date" select="@flexibility"/>
                                            </xsl:call-template>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:call-template name="getMessage">
                                                <xsl:with-param name="key" select="'associationDYNAMIC'"/>
                                            </xsl:call-template>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:with-param>
                            </xsl:call-template>
                            <xsl:if test="position()!=last()">
                                <br/>
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
            </xsl:if>

            <!-- context of this template -->
            <xsl:if test="context">
                <xsl:variable name="cid">
                    <xsl:choose>
                        <xsl:when test="context/@id='*'">
                            <!-- use siblings of template's id -->
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'tmpContextSibling'"/>
                                <xsl:with-param name="p1" select="@id"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="context/@id='**'">
                            <!-- use parent of current template's id -->
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'tmpContextParent'"/>
                                <xsl:with-param name="p1" select="@id"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="context/@path">
                            <xsl:variable name="cctxpth">
                                <xsl:call-template name="outputPath">
                                    <xsl:with-param name="pathname">
                                        <xsl:value-of select="context/@path"/>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'tmpContextPath'"/>
                                <xsl:with-param name="p1" select="$cctxpth"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="context/@id"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <tr>
                    <th align="left">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'context'"/>
                        </xsl:call-template>
                    </th>
                    <td align="left" style="background-color: &sandColorLight;">
                        <xsl:value-of select="$cid"/>
                    </td>
                </tr>
            </xsl:if>

            <!-- item labels -->
            <xsl:if test="item/@label">
                <tr>
                    <th align="left" valign="top">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'itemReference'"/>
                        </xsl:call-template>
                    </th>
                    <td align="left" style="background-color: &sandColorLight;">
                        <xsl:value-of select="replace(string(item/@label), '-', '&#8209;')"/>
                        <xsl:if test="count(desc)>0">
                            <br/>
                        </xsl:if>
                        <xsl:call-template name="doDescription">
                            <xsl:with-param name="ns" select="item/desc"/>
                        </xsl:call-template>
                    </td>
                </tr>
            </xsl:if>

            <!-- version information -->
            <xsl:if test="@versionLabel or @effectiveDate or @expirationDate">
                <tr>
                    <th align="left">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'templateVersion'"/>
                        </xsl:call-template>
                    </th>
                    <td align="left" style="background-color: &sandColorLight;">
                        <xsl:value-of select="@versionLabel"/>
                        <xsl:if test="@effectiveDate">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'templateValidFrom'"/>
                            </xsl:call-template>
                            <xsl:call-template name="showDate">
                                <xsl:with-param name="date" select="@effectiveDate"/>
                            </xsl:call-template>
                        </xsl:if>
                        <xsl:if test="@expirationDate">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'templateValidTo'"/>
                            </xsl:call-template>
                            <xsl:call-template name="showDate">
                                <xsl:with-param name="date" select="@expirationDate"/>
                            </xsl:call-template>
                        </xsl:if>
                        <xsl:if test="@statusCode">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'templateStatus'"/>
                            </xsl:call-template>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="concat('TemplateStatusCodeLifeCycle-',@statusCode)"/>
                            </xsl:call-template>
                        </xsl:if>
                        <xsl:if test="count($allTemplateRefs/*/template[@id=$tid])>1">
                            <p/>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'versionsOfTemplatesWithThisId'"/>
                            </xsl:call-template>
                            <ul>
                                <xsl:for-each select="$allTemplateRefs/*/template[@id=$tid]">
                                    <li>
                                        <xsl:value-of select="@name"/>
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="'xAsOfy'"/>
                                        </xsl:call-template>
                                        <xsl:call-template name="showDate">
                                            <xsl:with-param name="date" select="@effectiveDate"/>
                                        </xsl:call-template>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </xsl:if>
                    </td>
                </tr>
            </xsl:if>

            <!-- @closed -->
            <tr valign="top">
                <th align="left">
                    <xsl:call-template name="getMessage">
                        <xsl:with-param name="key" select="'openClosedLabel'"/>
                    </xsl:call-template>
                </th>
                <td style="background-color: &sandColorLight;">
                    <xsl:choose>
                        <xsl:when test="string(@isClosed)='true'">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'templateIsClosed'"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'templateIsOpen'"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </tr>

            <!-- description if given -->
            <xsl:if test="desc">
                <tr valign="top">
                    <th align="left">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'templateDescription'"/>
                        </xsl:call-template>
                    </th>
                    <td>
                        <xsl:call-template name="doDescription">
                            <xsl:with-param name="ns" select="desc"/>
                        </xsl:call-template>
                    </td>
                </tr>
            </xsl:if>

            <xsl:call-template name="check4Issue">
                <xsl:with-param name="id" select="@id"/>
                <xsl:with-param name="colspans" select="1"/>
            </xsl:call-template>

            <!-- 
                temporarily: show the whole template def 
            -->
            <!--
            <xsl:variable name="ttt">
                <xsl:copy-of select="*"/>
            </xsl:variable>
            <tr>
                <td colspan="3" class="tabtab">
                    <table>
                        <tr>
                            <td>
                                <tt>
                                    <xsl:apply-templates select="$ttt/*"/>
                                </tt>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            -->

            <!--
                is associated with what concepts?
                
                <templateAssociation templateId="2.999.999.993.77.10.900100" effectiveDate="2012-04-10T00:00:00">
                    <concept ref="2.999.999.993.77.2.1.100060" effectiveDate="2012-04-10T00:00:00" elementId="2.999.999.993.77.9.900100.1"/>
                </templateAssociation>
                
            -->
            <xsl:for-each select="$allTemplatesAssociations/*/templateAssociation[@templateId=$tid][@effectiveDate=$teff]">

                <tr valign="top">
                    <th align="left">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'AssociatedWith'"/>
                        </xsl:call-template>
                    </th>

                    <td valign="top" colspan="3">

                        <xsl:variable name="elid" select="local:randomString2(generate-id())"/>
                        <xsl:variable name="elidtoggler" select="concat('toggler-', $elid)"/>
                        <xsl:variable name="reffedconcepts" select="concept"/>
                        <xsl:variable name="knownconcepts" select="$allDatasetConceptsFlat/*/*/concept[concat(@id,@effectiveDate)=$reffedconcepts/concat(@ref,@effectiveDate)]"/>
                        
                        <table width="100%" border="0" cellspacing="3" cellpadding="2">
                            <tr class="desclabel">
                                <td id="{$elidtoggler}" class="toggler" onclick="return toggleZoom('{$elid}','{$elidtoggler}', '{$theAssetsDir}')" colspan="2" height="30px">
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'AssociatedWith'"/>
                                    </xsl:call-template>
                                    <xsl:text> </xsl:text>
                                    <xsl:choose>
                                        <xsl:when test="count($knownconcepts) = 1">
                                            <xsl:call-template name="getMessage">
                                                <xsl:with-param name="key" select="'numberOfConcept'"/>
                                                <xsl:with-param name="p1" select="count($knownconcepts)"/>
                                            </xsl:call-template>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:call-template name="getMessage">
                                                <xsl:with-param name="key" select="'numberOfConcepts'"/>
                                                <xsl:with-param name="p1" select="count($knownconcepts)"/>
                                            </xsl:call-template>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <div id="{$elid}" class="toggle">
                                        <table width="100%" border="0" cellspacing="1" cellpadding="6">
                                            <tr>
                                                <th width="20%" align="left">
                                                    <xsl:call-template name="getMessage">
                                                        <xsl:with-param name="key" select="'Id'"/>
                                                    </xsl:call-template>
                                                </th>
                                                <th width="60%" align="left">
                                                    <xsl:call-template name="getMessage">
                                                        <xsl:with-param name="key" select="'Name'"/>
                                                    </xsl:call-template>
                                                </th>
                                                <th width="20%" align="left">
                                                    <xsl:call-template name="getMessage">
                                                        <xsl:with-param name="key" select="'Dataset'"/>
                                                    </xsl:call-template>
                                                </th>
                                            </tr>
                                            <xsl:for-each select="$knownconcepts">
                                                <tr>
                                                    <td align="left" valign="top" width="1%">
                                                        <xsl:call-template name="doShorthandId">
                                                            <xsl:with-param name="id" select="@id"/>
                                                        </xsl:call-template>
                                                    </td>
                                                    <td align="left" valign="top">
                                                        <xsl:call-template name="doName">
                                                            <xsl:with-param name="ns" select="name"/>
                                                        </xsl:call-template>
                                                    </td>
                                                    <td align="left" valign="top">
                                                        <xsl:call-template name="doName">
                                                            <xsl:with-param name="ns" select="ancestor::dataset/name"/>
                                                        </xsl:call-template>
                                                    </td>
                                                </tr>
                                            </xsl:for-each>
                                        </table>
                                    </div>
                                </td>
                            </tr>
                        </table>

                    </td>

                </tr>

            </xsl:for-each>

            <!-- used in what other templates? -->
            <xsl:variable name="tclist">
                <wrap>
                    <!-- used by first -->
                    <xsl:for-each select="
                        $allTemplates/*/ref[template//include[@ref=$tid or @ref=$tname][($tIsNewest and (not(@flexibility) or string(@flexibility)='dynamic')) or @flexibility=$teff]]|
                        $allTemplates/*/ref[template//*[@contains=$tid or @contains=$tname][($tIsNewest and (not(@flexibility) or string(@flexibility)='dynamic')) or @flexibility=$teff]]">
                        <xsl:variable name="xti" select="template/@id"/>
                        <xsl:variable name="xtn" select="template/@name"/>
                        <xsl:variable name="xte" select="template/@effectiveDate"/>
                        <xsl:variable name="xdn" select="template/@displayName"/>
                        <xsl:variable name="xin" select="max($allTemplates/*/ref/template[@id=$xti]/xs:dateTime(@effectiveDate))=$xte"/>

                        <direct id="{$xti}" name="{$xtn}" effectiveDate="{$xte}" displayName="{$xdn}" newestForId="{$xin}"/>

                        <!-- get Template Chain recursively, submit template id and name  -->
                        <xsl:call-template name="getTemplateChain">
                            <xsl:with-param name="yti" select="$xti"/>
                            <xsl:with-param name="ytn" select="$xtn"/>
                            <xsl:with-param name="yte" select="$xte"/>
                            <xsl:with-param name="ydn" select="$xdn"/>
                            <xsl:with-param name="yin" select="$xin"/>
                            <xsl:with-param name="sofar" select="concat (':', $xti, ':', $xtn, ':')"/>
                        </xsl:call-template>
                    </xsl:for-each>
                    <!-- now template uses -->
                    <xsl:for-each select=".//element[@contains] | .//include[@ref]">
                        
                        <xsl:variable name="xid" select="concat(@contains, @ref)"/>
                        
                        <xsl:variable name="flex" select="if (@flexibility) then @flexibility else ('dynamic')"/>
                        <xsl:variable name="effd" select="if (matches($flex,'^\d{4}')) then $flex else string(max($allTemplates/*/ref[template[@id=$xid or @name=$xid]]/xs:dateTime(@effectiveDate)))"/>
                        <xsl:variable name="tmpl" select="$allTemplates/*/ref[template[@id=$xid][@effectiveDate=$effd]] | $allTemplates/*/ref[template[@name=$xid][@effectiveDate=$effd]]"/>
                        <xsl:for-each select="$tmpl">
                            <uses id="{@id}" name="{@name}" displayName="{@displayName}" effectiveDate="{@effectiveDate}" flexibility="{$flex}"/>
                        </xsl:for-each>
                    </xsl:for-each>
                </wrap>
            </xsl:variable>

            <xsl:if test="count($tclist/*/*)>0">
                <tr valign="top">
                    <th align="left">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'UsedBy'"/>
                        </xsl:call-template>
                        <xsl:text> / </xsl:text>
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'Uses'"/>
                        </xsl:call-template>
                    </th>
                    <td valign="top" colspan="3">
                        <xsl:variable name="elid" select="local:randomString2(generate-id())"/>
                        <xsl:variable name="elidtoggler" select="concat('toggler-', $elid)"/>

                        <table width="100%" border="0" cellspacing="3" cellpadding="2">
                            <tr class="desclabel">
                                <td id="{$elidtoggler}" class="toggler" onclick="return toggleZoom('{$elid}','{$elidtoggler}', '{$theAssetsDir}')" colspan="2" height="30px">
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'UsedBy'"/>
                                    </xsl:call-template>
                                    <xsl:text> / </xsl:text>
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'Uses'"/>
                                    </xsl:call-template>
                                    <xsl:text> </xsl:text>
                                    <xsl:choose>
                                        <xsl:when test="count($tclist/*/(direct|uses)) = 1">
                                            <xsl:call-template name="getMessage">
                                                <xsl:with-param name="key" select="'numberOfTemplate'"/>
                                                <xsl:with-param name="p1" select="count($tclist/*/(direct|uses))"/>
                                            </xsl:call-template>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:call-template name="getMessage">
                                                <xsl:with-param name="key" select="'numberOfTemplates'"/>
                                                <xsl:with-param name="p1" select="count($tclist/*/(direct|uses))"/>
                                            </xsl:call-template>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <div id="{$elid}" class="toggle">
                                        <table width="100%" border="0" cellspacing="1" cellpadding="6">
                                            <xsl:for-each select="$tclist/*/direct | $tclist/*/uses">
                                                <xsl:variable name="xti" select="@id"/>
                                                <xsl:variable name="xtn" select="@name"/>
                                                <xsl:variable name="xte" select="@effectiveDate"/>
                                                <xsl:variable name="xdn" select="@displayName"/>
                                                <xsl:variable name="xin" select="@newestForId"/>
                                                <xsl:variable name="xflx" select="@flexibility"/>
                                                <xsl:variable name="ename" select="name()"/>
                                                
                                                <xsl:if test="not(preceding-sibling::*[name()=$ename])">
                                                    <tr>
                                                        <th width="20%" align="left">
                                                            <xsl:choose>
                                                                <xsl:when test="$ename='direct'">
                                                                    <xsl:call-template name="getMessage">
                                                                        <xsl:with-param name="key" select="'UsedBy'"/>
                                                                    </xsl:call-template>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <xsl:call-template name="getMessage">
                                                                        <xsl:with-param name="key" select="'Uses'"/>
                                                                    </xsl:call-template>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:call-template name="getMessage">
                                                                <xsl:with-param name="key" select="'templateId'"/>
                                                            </xsl:call-template>
                                                        </th>
                                                        <th width="60%" align="left">
                                                            <xsl:call-template name="getMessage">
                                                                <xsl:with-param name="key" select="'Name'"/>
                                                            </xsl:call-template>
                                                        </th>
                                                        <th width="20%" align="left">
                                                            <xsl:call-template name="getMessage">
                                                                <xsl:with-param name="key" select="'Version'"/>
                                                            </xsl:call-template>
                                                        </th>
                                                    </tr>
                                                </xsl:if>
                                                
                                                <xsl:if test="not(preceding-sibling::*[@id=$xti][@effectiveDate=$xte])">
                                                    <xsl:choose>
                                                        <xsl:when test="@circularForId">
                                                            <tr>
                                                                <td align="left" colspan="3">
                                                                    <xsl:call-template name="showIcon">
                                                                        <xsl:with-param name="which">notice</xsl:with-param>
                                                                    </xsl:call-template>
                                                                    <xsl:text>&#160;</xsl:text>
                                                                    <xsl:call-template name="getMessage">
                                                                        <xsl:with-param name="key" select="'tmpCircularReference'"/>
                                                                        <xsl:with-param name="p1">
                                                                            <xsl:call-template name="doShorthandId">
                                                                                <xsl:with-param name="id" select="$xti"/>
                                                                            </xsl:call-template>
                                                                        </xsl:with-param>
                                                                    </xsl:call-template>
                                                                </td>
                                                            </tr>
                                                        </xsl:when>
                                                        <xsl:when test="@circularForName">
                                                            <tr>
                                                                <td align="left" colspan="3">
                                                                    <xsl:call-template name="showIcon">
                                                                        <xsl:with-param name="which">notice</xsl:with-param>
                                                                    </xsl:call-template>
                                                                    <xsl:text>&#160;</xsl:text>
                                                                    <xsl:call-template name="getMessage">
                                                                        <xsl:with-param name="key" select="'tmpCircularReference'"/>
                                                                        <xsl:with-param name="p1">
                                                                            <xsl:call-template name="doShorthandId">
                                                                                <xsl:with-param name="id" select="$xtn"/>
                                                                            </xsl:call-template>
                                                                        </xsl:with-param>
                                                                    </xsl:call-template>
                                                                </td>
                                                            </tr>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <tr>
                                                                <td align="left">
                                                                    <xsl:if test="self::reference">
                                                                        <xsl:call-template name="showIcon">
                                                                            <xsl:with-param name="which">link11</xsl:with-param>
                                                                        </xsl:call-template>
                                                                        <xsl:text>&#160;</xsl:text>
                                                                        <xsl:call-template name="getMessage">
                                                                            <xsl:with-param name="key" select="'tmpDependency'"/>
                                                                        </xsl:call-template>
                                                                        <xsl:text>: </xsl:text>
                                                                    </xsl:if>
                                                                    <a href="tmp-{$xti}-{replace($xte,':','')}.html" target="_blank">
                                                                        <xsl:value-of select="$xti"/>
                                                                    </a>
                                                                </td>
                                                                <td align="left">
                                                                    <i>
                                                                        <xsl:choose>
                                                                            <xsl:when test="string-length($xdn)>0">
                                                                                <xsl:value-of select="$xdn"/>
                                                                            </xsl:when>
                                                                            <xsl:otherwise>
                                                                                <xsl:value-of select="$xtn"/>
                                                                            </xsl:otherwise>
                                                                        </xsl:choose>
                                                                    </i>
                                                                </td>
                                                                <td align="left">
                                                                    <xsl:choose>
                                                                        <xsl:when test="$ename='uses' and matches($xflx,'^\d')">
                                                                            <xsl:call-template name="showDate">
                                                                                <xsl:with-param name="date" select="$xflx"/>
                                                                            </xsl:call-template>
                                                                        </xsl:when>
                                                                        <xsl:when test="$ename='uses' and $xflx">
                                                                            <xsl:call-template name="getMessage">
                                                                                <xsl:with-param name="key" select="'associationDYNAMIC'"/>
                                                                            </xsl:call-template>
                                                                        </xsl:when>
                                                                        <xsl:otherwise>
                                                                            <xsl:call-template name="showDate">
                                                                                <xsl:with-param name="date" select="$xte"/>
                                                                            </xsl:call-template>
                                                                        </xsl:otherwise>
                                                                    </xsl:choose>
                                                                </td>
                                                            </tr>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </table>
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </xsl:if>

            <!-- template examples always first if any -->
            <xsl:apply-templates select="example" mode="templateparticle"/>

            <!-- if there is at least one element or attribute or one choice or one include in a template, process it -->
            <xsl:choose>
                <xsl:when test="count(element|attribute|include|choice)>0">
                    <tr>
                        <td colspan="2" class="tabtab">
                            <table width="100%" border="0" cellspacing="1" cellpadding="6">
                                <thead>
                                    <tr>
                                        <th align="left" width="1%">
                                            <xsl:call-template name="getMessage">
                                                <xsl:with-param name="key" select="'itemLabel'"/>
                                            </xsl:call-template>
                                        </th>
                                        <th align="left" width="1%">
                                            <xsl:call-template name="getMessage">
                                                <xsl:with-param name="key" select="'datatypeLabel'"/>
                                            </xsl:call-template>
                                        </th>
                                        <th align="left" width="1%">
                                            <xsl:call-template name="getMessage">
                                                <xsl:with-param name="key" select="'cardinalityLabel'"/>
                                            </xsl:call-template>
                                        </th>
                                        <th align="left" width="1%">
                                            <xsl:call-template name="getMessage">
                                                <xsl:with-param name="key" select="'conformanceLabel'"/>
                                            </xsl:call-template>
                                        </th>
                                        <th align="left">
                                            <xsl:call-template name="getMessage">
                                                <xsl:with-param name="key" select="'descLabel'"/>
                                            </xsl:call-template>
                                        </th>
                                        <th align="left" width="1%">
                                            <xsl:call-template name="getMessage">
                                                <xsl:with-param name="key" select="'Label'"/>
                                            </xsl:call-template>
                                        </th>
                                    </tr>
                                </thead>
                                <xsl:apply-templates select="element|attribute|include|choice" mode="templateparticle">
                                    <xsl:with-param name="level" select="0"/>
                                    <xsl:with-param name="label" select="$itemlabel"/>
                                </xsl:apply-templates>
                            </table>
                        </td>
                    </tr>
                </xsl:when>
                <xsl:otherwise>
                    <tr>
                        <td colspan="2">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'noElemsAttribInclChoiceDefined'"/>
                            </xsl:call-template>
                        </td>
                    </tr>
                </xsl:otherwise>
            </xsl:choose>

        </table>
    </xsl:template>

	<xsl:template name="getTemplateChain">
		<!-- get template chain (dependencies), params are current template id $xti and name $ytn and the chain so far in $sofar to detect circular references $sofar concats every id and name node visited so 
			far surrounded by : -->
		<xsl:param name="yti" />
		<xsl:param name="ytn" />
		<xsl:param name="yte" />
		<xsl:param name="ydn" />
		<xsl:param name="yin" />
		<xsl:param name="sofar" />

		<xsl:call-template name="logMessage">
			<xsl:with-param name="level" select="$logALL" />
			<xsl:with-param name="msg">
				<xsl:text>R====</xsl:text>
				<xsl:value-of select="$yti" />
				<xsl:text>/</xsl:text>
				<xsl:value-of select="$ytn" />
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="logMessage">
			<xsl:with-param name="level" select="$logALL" />
			<xsl:with-param name="msg">
				<xsl:text>SOFAR(</xsl:text>
				<xsl:value-of select="$sofar" />
				<xsl:text>)   SUB(</xsl:text>
				<xsl:value-of select="substring-after($sofar, $yti)" />
				<xsl:text>)   CIRC: </xsl:text>
				<xsl:value-of select="contains(substring-after($sofar, $yti), concat(':', $yti, ':'))" />
				<xsl:text>&#160;</xsl:text>
				<xsl:value-of select="contains(substring-after($sofar, $ytn), concat(':', $ytn, ':'))" />
			</xsl:with-param>
		</xsl:call-template>
		-->

		<xsl:choose>
			<xsl:when test="contains(substring-after($sofar, $yti), concat(':', $yti, ':'))">
				<!-- circular reference by id -->
				<reference id="{$yti}" name="{$ytn}" effectiveDate="{$yte}" displayName="{$ydn}" newestForId="{$yin}" circularForId="{true()}" />
			</xsl:when>
			<xsl:when test="contains(substring-after($sofar, $ytn), concat(':', $ytn, ':'))">
				<!-- circular reference by name -->
				<reference id="{$yti}" name="{$ytn}" effectiveDate="{$yte}" displayName="{$ydn}" newestForId="{$yin}" circularForName="{true()}" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each
					select="
                    $allTemplates/*/ref[template//include[@ref=$yti or @ref=$ytn][($yin and (not(@flexibility) or string(@flexibility)='dynamic')) or @flexibility=$yte]]|
                    $allTemplates/*/ref[template//*[@contains=$yti or @contains=$ytn][($yin and (not(@flexibility) or string(@flexibility)='dynamic')) or @flexibility=$yte]]">
					<xsl:variable name="xti" select="template/@id" />
					<xsl:variable name="xtn" select="template/@name" />
					<xsl:variable name="xte" select="template/@effectiveDate" />
					<xsl:variable name="xdn" select="template/@displayName" />
					<xsl:variable name="xin" select="max($allTemplates/*/ref/template[@id=$xti]/xs:dateTime(@effectiveDate))=$xte" />

					<reference id="{$xti}" name="{$xtn}" effectiveDate="{$xte}" displayName="{$xdn}" newestForId="{$xin}" />

					<xsl:call-template name="getTemplateChain">
						<xsl:with-param name="yti" select="$xti" />
						<xsl:with-param name="ytn" select="$xtn" />
						<xsl:with-param name="yte" select="$xte" />
						<xsl:with-param name="ydn" select="$xdn" />
						<xsl:with-param name="yin" select="$xin" />
						<xsl:with-param name="sofar" select="concat ($sofar, ':', $yti, ':', $ytn)" />
					</xsl:call-template>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>


	</xsl:template>

	<xsl:template match="*" mode="templateparticle">
		<xsl:text>OOPS: </xsl:text>
		<xsl:value-of select="name()" />
	</xsl:template>

	<xsl:template match="transaction">

		<!-- whether contained concept appear in a toggler -->
		<xsl:param name="conceptToggler" select="true()" />

		<!-- ==== Start of description (direction icon and id) ==== -->
		<xsl:choose>
			<xsl:when test="@type='group'">
				<tr>
					<td>
						<xsl:call-template name="showIcon">
							<xsl:with-param name="which">
								doublearrow
							</xsl:with-param>
						</xsl:call-template>
					</td>
					<td>
						<xsl:call-template name="getMessage">
							<xsl:with-param name="key" select="'transactionGroupId'" />
						</xsl:call-template>
						<xsl:text>:</xsl:text>
					</td>
					<td>
						<xsl:call-template name="doShorthandId">
							<xsl:with-param name="id" select="@id" />
						</xsl:call-template>
					</td>
				</tr>
			</xsl:when>
			<xsl:otherwise>
				<tr class="desclabel">
					<th>
						<xsl:call-template name="showDirection">
							<xsl:with-param name="dir" select="@type" />
						</xsl:call-template>
					</th>
					<th>
						<xsl:call-template name="getMessage">
							<xsl:with-param name="key" select="'transactionId'" />
						</xsl:call-template>
						<xsl:text>:</xsl:text>
					</th>
					<th>
						<xsl:call-template name="doShorthandId">
							<xsl:with-param name="id" select="@id" />
						</xsl:call-template>
					</th>
				</tr>
			</xsl:otherwise>
		</xsl:choose>

		<!-- ==== Generics for any transaction type ==== -->
		<!-- versionLabel / statusCode / effectiveDate / expirationDate -->
		<xsl:if test="@statusCode">
			<tr>
				<td>
					<xsl:call-template name="getMessage">
						<xsl:with-param name="key" select="'Status'" />
					</xsl:call-template>
				</td>
				<td colspan="2">
					<xsl:call-template name="showStatusDot">
						<xsl:with-param name="status" select="@statusCode" />
					</xsl:call-template>
					<xsl:text>&#160;</xsl:text>
					<xsl:call-template name="getMessage">
						<xsl:with-param name="key" select="concat('ItemStatusCodeLifeCycle-', @statusCode)" />
					</xsl:call-template>
				</td>
			</tr>
			<tr>
				<td>
					<xsl:call-template name="getMessage">
						<xsl:with-param name="key" select="'VersionEffectiveDate'" />
					</xsl:call-template>
				</td>
				<td colspan="2">
					<xsl:if test="@versionLabel">
						<xsl:value-of select="@versionLabel" />
						<xsl:text> - </xsl:text>
					</xsl:if>
					<xsl:call-template name="showDate">
						<xsl:with-param name="date" select="@effectiveDate" />
					</xsl:call-template>
				</td>
			</tr>
			<xsl:if test="@expirationDate">
				<tr>
					<td>
						<xsl:call-template name="getMessage">
							<xsl:with-param name="key" select="'ExpirationDate'" />
						</xsl:call-template>
					</td>
					<td colspan="2">
						<xsl:call-template name="showDate">
							<xsl:with-param name="date" select="@expirationDate" />
						</xsl:call-template>
					</td>
				</tr>
			</xsl:if>
		</xsl:if>
		<!-- Name -->
		<tr>
			<td>
				<xsl:call-template name="getMessage">
					<xsl:with-param name="key" select="'Name'" />
				</xsl:call-template>
			</td>
			<td colspan="2">
				<xsl:call-template name="doDescription">
					<xsl:with-param name="ns" select="name" />
				</xsl:call-template>
			</td>
		</tr>
		<!-- Description -->
		<xsl:if test="string-length(desc[1])>0">
			<tr>
				<td valign="top">
					<xsl:call-template name="getMessage">
						<xsl:with-param name="key" select="'Description'" />
					</xsl:call-template>
				</td>
				<td colspan="2">
					<xsl:call-template name="doDescription">
						<xsl:with-param name="ns" select="desc" />
					</xsl:call-template>
				</td>
			</tr>
		</xsl:if>
		<!-- Trigger -->
		<xsl:if test="trigger">
			<tr>
				<td>
					<xsl:call-template name="getMessage">
						<xsl:with-param name="key" select="'transactionTrigger'" />
					</xsl:call-template>
				</td>
				<!-- TODO: handle triggers with different ids? -->
				<xsl:choose>
					<xsl:when test="trigger[@id]">
						<td>
							<xsl:value-of select="trigger/@id[1]" />
						</td>
						<td>
							<xsl:call-template name="doDescription">
								<xsl:with-param name="ns" select="trigger" />
							</xsl:call-template>
						</td>
					</xsl:when>
					<xsl:otherwise>
						<td colspan="2">
							<xsl:call-template name="doDescription">
								<xsl:with-param name="ns" select="trigger" />
							</xsl:call-template>
						</td>
					</xsl:otherwise>
				</xsl:choose>
			</tr>
		</xsl:if>
		<!-- Condition -->
		<xsl:if test="condition">
			<tr>
				<td>
					<xsl:call-template name="getMessage">
						<xsl:with-param name="key" select="'transactionCondition'" />
					</xsl:call-template>
				</td>
				<td colspan="2">
					<xsl:call-template name="doDescription">
						<xsl:with-param name="ns" select="condition" />
					</xsl:call-template>
				</td>
			</tr>
		</xsl:if>
		<!-- Dependencies -->
		<xsl:if test="dependencies">
			<tr>
				<td>
					<xsl:call-template name="getMessage">
						<xsl:with-param name="key" select="'transactionDependencies'" />
					</xsl:call-template>
				</td>
				<td colspan="2">
					<xsl:call-template name="doDescription">
						<xsl:with-param name="ns" select="dependencies" />
					</xsl:call-template>
				</td>
			</tr>
		</xsl:if>

		<!-- ==== Specifics of description (groups loop into content, other transactions get documented internally) ==== -->
		<xsl:choose>
			<xsl:when test="@type='group'">
				<xsl:if test="$switchCreateDocSVG = true()">
					<xsl:variable name="tgId" select="@id" />
					<!-- If we created at least one SVG, assume its the functional variant -->
					<xsl:if test="count($allSvg/transaction[@id=$tgId]/*) &gt; 0">
						<tr valign="top">
							<td colspan="3">
								<img src="tg-{@id}_functional.svg">
									<xsl:attribute name="alt">
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="'needBrowserWithSvgSupport'" />
                                        </xsl:call-template>
                                    </xsl:attribute>
								</img>
							</td>
						</tr>
					</xsl:if>
				</xsl:if>
				<tr valign="top">
					<!-- slightly different layout when no concept toggler is present (for print) -->
					<xsl:if test="$conceptToggler=true()">
						<td>
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'Content'" />
							</xsl:call-template>
						</td>
					</xsl:if>
					<td class="desclabel tabtab">
						<xsl:choose>
							<xsl:when test="$conceptToggler=true()">
								<xsl:attribute name="colspan" select="'2'" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="colspan" select="'3'" />
							</xsl:otherwise>
						</xsl:choose>
						<table width="100%" border="0" cellspacing="2" cellpadding="2">
							<xsl:apply-templates select="transaction">
								<xsl:with-param name="conceptToggler" select="$conceptToggler" />
							</xsl:apply-templates>
						</table>
					</td>
				</tr>
			</xsl:when>
			<xsl:when test="not(@type='group')">
				<!-- <transaction id="2.16.840.1.113883.2.4.3.11.60.100.4.2" type="stationary" displayName="BDS - Registratie" label="label" model="djkfhsjfh"> -->
				<xsl:if test="@model">
					<tr>
						<td>
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'Model'" />
							</xsl:call-template>
						</td>
						<td colspan="3">
							<xsl:value-of select="@model" />
							<xsl:text>&#160;</xsl:text>
							<!--i> <xsl:value-of select="@dislayName"/> </i -->
						</td>
					</tr>
				</xsl:if>
				<xsl:if test="@label">
					<tr>
						<td>
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'Label'" />
							</xsl:call-template>
						</td>
						<td colspan="3">
							<xsl:value-of select="@label" />
							<xsl:text>&#160;</xsl:text>
							<!--i> <xsl:value-of select="@dislayName"/> </i -->
						</td>
					</tr>
				</xsl:if>
				<xsl:for-each select="actors/actor">
					<xsl:variable name="aid" select="@id" />
					<xsl:variable name="theActor" select="$allActors/actors/actor[@id=$aid]" />
					<tr class="desclabel">
						<th valign="top" colspan="3">
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'Actor'" />
							</xsl:call-template>
							<xsl:text> - </xsl:text>
							<xsl:choose>
								<xsl:when test="@role='sender' or @role='receiver'">
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="concat('actorRole-',@role)" />
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="@role" />
								</xsl:otherwise>
							</xsl:choose>
							<xsl:text> (</xsl:text>
							<xsl:choose>
								<xsl:when test="$theActor/@type='device' or $theActor/@type='person' or $theActor/@type='organization'">
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="concat('actorType-',$theActor/@type)" />
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$theActor/@type" />
								</xsl:otherwise>
							</xsl:choose>
							<xsl:text>)</xsl:text>
						</th>
					</tr>
					<tr>
						<td>
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'Name'" />
							</xsl:call-template>
						</td>
						<td colspan="3">
							<xsl:call-template name="doDescription">
								<xsl:with-param name="ns" select="$theActor/name" />
							</xsl:call-template>
						</td>
					</tr>
					<xsl:if test="$theActor/desc">
						<tr>
							<td valign="top">
								<xsl:call-template name="getMessage">
									<xsl:with-param name="key" select="'Description'" />
								</xsl:call-template>
							</td>
							<td colspan="3">
								<xsl:call-template name="doDescription">
									<xsl:with-param name="ns" select="$theActor/desc" />
								</xsl:call-template>
							</td>
						</tr>
					</xsl:if>
				</xsl:for-each>
				<xsl:for-each select="representingTemplate">

					<xsl:variable name="xref" select="@ref" />
					<xsl:variable name="xflex" select="if (@flexilibity) then (@flexilibity) else ('dynamic')" />
					<xsl:variable name="did" select="@sourceDataset" />
					<xsl:variable name="reptc" select="." />
					<xsl:variable name="rccontent">
						<xsl:call-template name="getRulesetContent">
							<xsl:with-param name="ruleset" select="$xref" />
							<xsl:with-param name="flexibility" select="$xflex" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:variable name="ahref">
						<xsl:choose>
							<xsl:when test="matches($xflex,'^\d{4}')">
								<xsl:value-of select="concat('tmp-',$rccontent/template/@id,'-',replace($xflex,':',''),'.html')" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat('tmp-',$rccontent/template/@id,'-DYNAMIC.html')" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="ahrefcontent">
						<xsl:choose>
							<xsl:when test="$rccontent/template[@displayName]">
								<xsl:value-of select="$rccontent/template/@displayName" />
							</xsl:when>
							<xsl:when test="$rccontent/*[@name]">
								<xsl:value-of select="$rccontent/template/@name" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$xref" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

					<tr class="desclabel">
						<th valign="top" colspan="3">
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'representingTemplate'" />
							</xsl:call-template>
						</th>
					</tr>
					<xsl:if test="string-length($xref)">
						<tr>
							<td valign="top">
								<xsl:call-template name="getMessage">
									<xsl:with-param name="key" select="'Template'" />
								</xsl:call-template>
							</td>
							<td colspan="2">
								<a href="{$ahref}" target="_blank">
									<xsl:value-of select="$ahrefcontent" />
								</a>
								<xsl:text>&#160;(</xsl:text>
								<xsl:choose>
									<xsl:when test="matches($xflex,'^\d{4}')">
										<xsl:call-template name="showDate">
											<xsl:with-param name="date" select="$xflex" />
										</xsl:call-template>
									</xsl:when>
									<xsl:otherwise>
										<xsl:call-template name="getMessage">
											<xsl:with-param name="key" select="'associationDYNAMIC'" />
										</xsl:call-template>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:text>)&#160;</xsl:text>
								<!--i> <xsl:call-template name="doDescription"> <xsl:with-param name="ns" select="$rccontent/template/desc"/> </xsl:call-template> </i -->
							</td>
						</tr>
					</xsl:if>
					<xsl:if test="string-length($did)>0">
						<tr>
							<td valign="top">
								<xsl:call-template name="getMessage">
									<xsl:with-param name="key" select="'sourceDataSet'" />
								</xsl:call-template>
							</td>
							<td colspan="2">
								<a href="ds-{$did}.html" target="_blank">
									<xsl:call-template name="doName">
										<xsl:with-param name="ns" select="$allDatasets/dataset[@id=$did]/name" />
										<!--<xsl:with-param name="lang" select="$defaultLanguage"/> -->
									</xsl:call-template>
								</a>
								<i>
									<xsl:text>&#160;(</xsl:text>
									<xsl:value-of select="$did" />
									<xsl:text>)</xsl:text>
								</i>
							</td>
						</tr>
					</xsl:if>
					<xsl:if test="count(concept)>0">
						<!-- prepare toggling -->
						<xsl:variable name="elid" select="local:randomString2(generate-id())" />
						<xsl:variable name="elidtoggler" select="concat('toggler-', $elid)" />

						<xsl:if test="$conceptToggler=false()">
							<tr>
								<th valign="top" colspan="3">
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'ContainedConcepts'" />
									</xsl:call-template>
								</th>
							</tr>
						</xsl:if>

						<!-- create the data set filtered with concept mentioned in the representingTemplate only -->
						<xsl:variable name="tmp1">
							<tmp>
								<xsl:for-each select="$allDatasets/dataset[@id=$did]">
									<xsl:apply-templates select="concept" mode="filter">
										<xsl:with-param name="representingTemplate" select="$reptc" />
									</xsl:apply-templates>
								</xsl:for-each>
							</tmp>
						</xsl:variable>

						<xsl:variable name="filtereddataset">
							<filtereddataset>
								<xsl:apply-templates select="$tmp1/tmp/concept" mode="eliminatedHiddenConcepts" />
							</filtereddataset>
						</xsl:variable>

						<tr>
							<td class="tabtab" valign="top" colspan="3">
								<table width="100%" border="0" cellspacing="3" cellpadding="2">
									<xsl:if test="$conceptToggler=true()">
										<tr class="desclabel">
											<td id="{$elidtoggler}" class="toggler" onclick="return toggleZoom('{$elid}','{$elidtoggler}', '{$theAssetsDir}')" colspan="2" height="30px">
												<xsl:call-template name="getMessage">
													<xsl:with-param name="key" select="'ContainedConcepts'" />
												</xsl:call-template>
											</td>
										</tr>
									</xsl:if>
									<tr>
										<td colspan="2">
											<div id="{$elid}">
												<xsl:if test="$conceptToggler=true()">
													<xsl:attribute name="class" select="'toggle'" />
												</xsl:if>
												<table width="100%" border="0" cellspacing="3" cellpadding="2">
													<tr>
														<th>
															<xsl:call-template name="getMessage">
																<xsl:with-param name="key" select="'Concept'" />
															</xsl:call-template>
														</th>
														<th>
															<xsl:call-template name="getMessage">
																<xsl:with-param name="key" select="'cardinalityConformanceLabel'" />
															</xsl:call-template>
														</th>
														<th>
															<xsl:call-template name="getMessage">
																<xsl:with-param name="key" select="'Id'" />
															</xsl:call-template>
														</th>
													</tr>

													<xsl:apply-templates select="$filtereddataset/filtereddataset/concept" mode="scenarioview">
														<xsl:with-param name="level" select="0" />
													</xsl:apply-templates>

												</table>
											</div>

										</td>
									</tr>
								</table>

							</td>
						</tr>

						<xsl:if test="$conceptToggler=false() and false()">
							<th valign="top" colspan="3">
								<xsl:call-template name="getMessage">
									<xsl:with-param name="key" select="'ContainedConcepts'" />
								</xsl:call-template>
							</th>
							<tr>
								<td class="tabtab" valign="top" colspan="3">
									<xsl:apply-templates select="$filtereddataset/filtereddataset/concept" mode="dataset">
										<xsl:with-param name="level" select="0" />
										<xsl:with-param name="nestingWithTables" select="false()" />
									</xsl:apply-templates>
								</td>
							</tr>
						</xsl:if>

					</xsl:if>
				</xsl:for-each>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="concept" mode="scenarioview">
		<xsl:param name="level" />

		<xsl:variable name="conditionals">
			<conditionals>
				<!-- copy the extra pre-processed conditions -->
				<xsl:copy-of select="conditionalConcept" />
			</conditionals>
		</xsl:variable>

		<tr valign="top">
			<td rowspan="2">
				<table border="0" cellpadding="1">
					<tr>
						<xsl:call-template name="doIndentLevel">
							<xsl:with-param name="level" select="$level" />
						</xsl:call-template>
						<td valign="top">
							<xsl:choose>
								<xsl:when test="@type='group'">
									<xsl:call-template name="showIcon">
										<xsl:with-param name="which">
											folder
										</xsl:with-param>
									</xsl:call-template>
								</xsl:when>
								<xsl:when test="@type='item'">
									<xsl:call-template name="showStatusDot">
										<xsl:with-param name="status" select="@statusCode" />
									</xsl:call-template>
									<xsl:text>&#160;</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="@type" />
								</xsl:otherwise>
							</xsl:choose>
						</td>
						<td>
							<xsl:choose>
								<xsl:when test="@conformance='NP'">
									<strike>
										<xsl:call-template name="doName">
											<xsl:with-param name="ns" select="name" />
										</xsl:call-template>
									</strike>
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="doName">
										<xsl:with-param name="ns" select="name" />
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
						</td>
					</tr>
				</table>
			</td>
			<td valign="top">
				<b>
					<xsl:call-template name="doCardConf">
						<xsl:with-param name="minimumMultiplicity" select="@minimumMultiplicity" />
						<xsl:with-param name="maximumMultiplicity" select="@maximumMultiplicity" />
						<xsl:with-param name="isMandatory" select="@isMandatory" />
						<xsl:with-param name="conformance" select="@conformance" />
					</xsl:call-template>
				</b>
			</td>
			<td valign="top">
				<xsl:call-template name="doShorthandId">
					<xsl:with-param name="id" select="@id" />
				</xsl:call-template>
			</td>
		</tr>
		<tr>
			<td colspan="2">
				<xsl:call-template name="doDescription">
					<xsl:with-param name="ns" select="desc" />
				</xsl:call-template>
				<xsl:if test="count(operationalization)>0">
					<xsl:value-of select="operationalization[1]" />
				</xsl:if>
			</td>
		</tr>
		<tr>
			<td />
			<td colspan="2" valign="top">
				<xsl:apply-templates select="$conditionals/conditionals" />
			</td>
		</tr>
		<xsl:if test="'SHOWCOMMENTS'=''">
			<tr>
				<td />
				<td colspan="2" valign="top" style="background-color: yellow;">COMMENT</td>
			</tr>
		</xsl:if>

		<tr>
			<td />
			<td colspan="2" valign="top" style="border-bottom: 1px solid #ECE9E4;">
			</td>
		</tr>

		<xsl:apply-templates select="concept" mode="scenarioview">
			<xsl:with-param name="level" select="$level+1" />
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="conditionals">
		<xsl:if test="count(conditionalConcept)>0">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" align="right">
				<tr>
					<td class="tabtab">
                        <!---->
						<table width="100%" border="0" cellspacing="3" cellpadding="2">
							<tr>
								<th>
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'conditionLabel'" />
									</xsl:call-template>
								</th>
								<th width="125px">
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'cardinalityConformanceLabel'" />
									</xsl:call-template>
								</th>
							</tr>
							<xsl:for-each select="conditionalConcept">
								<tr>
									<td>
										<xsl:choose>
											<xsl:when test="string-length(text())=0">
												<xsl:call-template name="getMessage">
													<xsl:with-param name="key" select="'otherwise'" />
												</xsl:call-template>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="text()" />
											</xsl:otherwise>
										</xsl:choose>
									</td>
									<td width="125px" valign="top">
										<xsl:call-template name="doCardConf">
											<xsl:with-param name="minimumMultiplicity" select="@minimumMultiplicity" />
											<xsl:with-param name="maximumMultiplicity" select="@maximumMultiplicity" />
											<xsl:with-param name="isMandatory" select="@isMandatory" />
											<xsl:with-param name="conformance" select="@conformance" />
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
						</table>
                        <!---->
					</td>
				</tr>
			</table>
		</xsl:if>
	</xsl:template>

	<xsl:template match="attribute" mode="templateparticle">
        <xsl:param name="level"/>

        <!-- cache attribute isOptional, datatytpe, value, vocabulary -->
        <xsl:variable name="elmDatatype" select="parent::element/@datatype"/>

        <xsl:variable name="isOptional" select="@isOptional"/>
        <xsl:variable name="prohibited" select="@prohibited"/>
        <xsl:variable name="theDatatype" select="@datatype"/>
        <xsl:variable name="theValue" select="@value"/>
        <xsl:variable name="descriptions" select="desc"/>
        <xsl:variable name="vocabulary" select="vocabulary"/>

        <xsl:for-each select="@* except (@isOptional|@datatype|@value|@prohibited)">
            <!-- cache attribute name and value of attribute -->
            <xsl:variable name="theAttName" select="name(.)"/>
            <xsl:variable name="theAttValue" select="."/>
            <tr>
                <td>
                    <table border="0" cellpadding="1">
                        <tr>
                            <xsl:call-template name="doIndentLevel">
                                <xsl:with-param name="level" select="$level"/>
                            </xsl:call-template>
                            <td>
                                <xsl:text>@</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="$theAttName='name'">
                                        <xsl:call-template name="outputPath">
                                            <xsl:with-param name="pathname" select="$theAttValue"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:call-template name="outputPath">
                                            <xsl:with-param name="pathname" select="$theAttName"/>
                                        </xsl:call-template>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </td>
                        </tr>
                    </table>
                </td>
                <td>
                    <!-- data type if given -->
                    <xsl:if test="string-length($theDatatype)>0">
                        <xsl:value-of select="$theDatatype"/>
                    </xsl:if>
                </td>
                <!-- cardinality 0..1 or 1..1 or not present -->
                <td>
                    <xsl:choose>
                        <xsl:when test="$prohibited='true'">
                            <xsl:text>0</xsl:text>
                        </xsl:when>
                        <xsl:when test="$isOptional='true'">
                            <xsl:text>0&#160;..&#160;1</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>1&#160;..&#160;1</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
                <!-- conformance -->
                <td>
                    <xsl:choose>
                        <!-- choice -->
                        <xsl:when test="contains($theAttValue, '|')">
                            <xsl:text>&#160;</xsl:text>
                        </xsl:when>
                        <xsl:when test="$theAttName='name' and string-length($theAttValue)=0">
                            <xsl:text>&#160;</xsl:text>
                        </xsl:when>
                        <xsl:when test="$prohibited='true'">
                            <xsl:text>NP</xsl:text>
                        </xsl:when>
                        <xsl:when test="$theAttName='name' and $theAttValue='xsi:type' and string-length($elmDatatype)>0">
                            <xsl:text>F</xsl:text>
                        </xsl:when>
                        <xsl:when test="$theAttName='name' and string-length($theValue)>0 and not(contains($theValue, '|'))">
                            <xsl:text>F</xsl:text>
                        </xsl:when>
                        <xsl:when test="not($theAttName='name') and string-length($theAttValue)>0">
                            <xsl:text>F</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>&#160;</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
                <td colspan="2">
                    <xsl:choose>
                        <xsl:when test="$prohibited='true'">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'conformanceNotPresent'"/>
                            </xsl:call-template>
                        </xsl:when>
                        <!-- choice -->
                        <xsl:when test="contains($theAttValue, '|')">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'attribShallChoice'"/>
                                <xsl:with-param name="p1" select="$theAttName"/>
                            </xsl:call-template>
                            <ul>
                                <xsl:for-each select="tokenize($theAttValue, '\|')">
                                    <li>
                                        <xsl:value-of select="."/>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </xsl:when>
                        <!-- attribute name -->
                        <xsl:when test="$theAttName='name'">
                            <xsl:choose>
                                <xsl:when test="contains($theValue, '|')">
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'attribShallChoice'"/>
                                        <xsl:with-param name="p1" select="$theAttValue"/>
                                    </xsl:call-template>
                                    <ul>
                                        <xsl:for-each select="tokenize($theValue, '\|')">
                                            <li>
                                                <xsl:value-of select="."/>
                                            </li>
                                        </xsl:for-each>
                                    </ul>
                                </xsl:when>
                                <xsl:when test="$theAttValue='xsi:type' and (starts-with($elmDatatype,'SD.TEXT') or starts-with($elmDatatype,'StrucDoc.Text'))">
                                    <!-- In DTr1, xsi:type for CDA Narrative Block is 'StrucDoc.Text', but DECOR carries 'SD.TEXT' -->
                                    <xsl:value-of select="'StrucDoc.Text'"/>
                                </xsl:when>
                                <xsl:when test="$theAttValue='xsi:type'">
                                    <!-- In DTr1, xsi:type should not be a flavorId, but the real datatype -->
                                    <xsl:value-of select="tokenize($elmDatatype,'\.')[1]"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$theValue"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$theAttValue"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </tr>

            <xsl:if test="$descriptions">
                <tr>
                    <td style="background-color: white" colspan="4">&#160;</td>
                    <td colspan="2">
                        <xsl:call-template name="doDescription">
                            <xsl:with-param name="ns" select="$descriptions"/>
                        </xsl:call-template>
                    </td>
                </tr>
            </xsl:if>

            <!-- do vocabulary or name+value of attribute -->
            <xsl:if test="$theAttName='name' and count($vocabulary)>0">
                <!-- only attributes with a name may have a vocabulary or property -->
                <tr>
                    <td style="background-color: white">&#160;</td>
                    <td class="conf" valign="top">
                        <xsl:text>CONF </xsl:text>
                    </td>
                    <td colspan="4">
                        <table width="100%" border="0" cellspacing="2" cellpadding="2">

                            <xsl:for-each select="$vocabulary">
                                <xsl:call-template name="doVocabularyAttributes">
                                    <xsl:with-param name="targetAttributeName" select="$theAttValue"/>
                                </xsl:call-template>
                                <xsl:if test="position()!=last()">
                                    <tr valign="top">
                                        <td>
                                            <xsl:call-template name="getMessage">
                                                <xsl:with-param name="key" select="'orWord'"/>
                                            </xsl:call-template>
                                        </td>
                                    </tr>
                                </xsl:if>
                            </xsl:for-each>

                        </table>
                    </td>
                </tr>
            </xsl:if>


        </xsl:for-each>

    </xsl:template>

	<xsl:template match="element|include|choice" mode="templateparticle">
        <xsl:param name="level"/>
        <!-- item label -->
        <xsl:param name="label"/>
        <xsl:param name="inheritedminimumMultiplicity"/>
        <xsl:param name="inheritedmaximumMultiplicity"/>
        <xsl:param name="inheritedConformance"/>
        <xsl:param name="inheritedIsMandatory"/>

        <xsl:variable name="itemlabel">
            <xsl:choose>
                <xsl:when test="string-length(item/@label)>0">
                    <!-- use item/@label -->
                    <xsl:value-of select="replace(string(item/@label), '-', '&#8209;')"/>
                </xsl:when>
                <xsl:when test="string-length($label)>0">
                    <!-- use inherited label if present -->
                    <xsl:value-of select="$label"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- use leave it empty -->
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- solve references to concept defintions regarding multiplicity, conformance -->
        <!-- AH: deactivated. Not only does reference not exist anymore, it also disregards multiple connections through templateAssociation/concept -->
        <!--xsl:variable name="cid" select="references/@concept"/-->
        <xsl:variable name="cid" select="'bogus'"/>
        <xsl:variable name="tid" select="(ancestor-or-self::template/@id)[last()]"/>
        <xsl:variable name="tnm" select="(ancestor-or-self::template/@name)[last()]"/>
        <xsl:variable name="teff" select="(ancestor-or-self::template/@effectiveDate)[last()]"/>
        <xsl:variable name="templateIsNewest" select="$allTemplates/*/ref[template[@id=$tid][@effectiveDate=$teff]]/@newestForId"/>
        <xsl:variable name="rpt" select="$allScenarios//representingTemplate[@ref=$tid or @ref=$tnm][((not(@flexibility) or @flexibility='dynamic') and string($templateIsNewest)='true') or @flexilibity=$teff]"/>

        <!-- get the cardinalities conformances etc -->
        <xsl:variable name="minimumMultiplicity">
            <xsl:choose>
                <xsl:when test="string-length($inheritedminimumMultiplicity)>0">
                    <xsl:value-of select="$inheritedminimumMultiplicity"/>
                </xsl:when>
                <xsl:when test="string-length(@minimumMultiplicity)>0">
                    <xsl:value-of select="@minimumMultiplicity"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="maximumMultiplicity">
            <xsl:choose>
                <xsl:when test="string-length($inheritedmaximumMultiplicity)>0">
                    <xsl:value-of select="$inheritedmaximumMultiplicity"/>
                </xsl:when>
                <xsl:when test="string-length(@maximumMultiplicity)>0">
                    <xsl:value-of select="@maximumMultiplicity"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="isMandatory">
            <xsl:choose>
                <xsl:when test="string-length($inheritedIsMandatory)>0">
                    <xsl:value-of select="$inheritedIsMandatory"/>
                </xsl:when>
                <!--xsl:when test="string-length($rpt/concept[@id=$cid]/@isMandatory)>0">
                    <xsl:value-of select="$rpt/concept[@id=$cid]/@isMandatory"/>
                </xsl:when-->
                <xsl:when test="string-length(@isMandatory)>0">
                    <xsl:value-of select="@isMandatory"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'false'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="conformance">
            <xsl:choose>
                <xsl:when test="string-length($inheritedConformance)>0">
                    <xsl:value-of select="$inheritedConformance"/>
                </xsl:when>
                <!--xsl:when test="string-length($rpt/concept[@id=$cid]/@conformance)>0">
                    <xsl:value-of select="$rpt/concept[@id=$cid]/@conformance"/>
                </xsl:when-->
                <xsl:when test="string-length(@conformance)>0">
                    <xsl:value-of select="@conformance"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- get a possible include candidate -->
        <xsl:variable name="xref">
            <xsl:choose>
                <xsl:when test="self::element[@contains]">
                    <xsl:value-of select="@contains"/>
                </xsl:when>
                <xsl:when test="name()='include'">
                    <xsl:value-of select="@ref"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- deprecated -->
                    <xsl:value-of select="@include"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- get the flexilibity -->
        <xsl:variable name="xflex" select="@flexibility"/>

        <xsl:variable name="rccontent">
            <xsl:call-template name="getRulesetContent">
                <xsl:with-param name="ruleset" select="$xref"/>
                <xsl:with-param name="flexibility" select="$xflex"/>
            </xsl:call-template>
        </xsl:variable>

        <!-- make sure we have the id and not the name for file reference -->
        <xsl:variable name="xtid" select="$rccontent/template/@id"/>
        <!-- get the template displayName or name, or the original reference as fallback -->
        <xsl:variable name="xtnm">
            <xsl:choose>
                <xsl:when test="$rccontent/*[@displayName]">
                    <xsl:value-of select="$rccontent/*/@displayName"/>
                </xsl:when>
                <xsl:when test="$rccontent/*[@name]">
                    <xsl:value-of select="$rccontent/*/@name"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$xref"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- this is an include or @contains, show where from included (ref) and create a link to it -->
        <xsl:variable name="ahref">
            <xsl:choose>
                <xsl:when test="matches($xflex,'^\d{4}')">
                    <xsl:value-of select="concat('tmp-',$xtid,'-',replace($xflex,':',''),'.html')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('tmp-',$xtid,'-DYNAMIC.html')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- 
            output 
            - on elements: name of element and card
            - include references: show from where included and original (black font) or overridden (grey font) cardinality
            - choices
        -->


        <!-- 
            this is an element with @name and @contains, show name and path (with possible where clause)
            or a include or a choice statement
        -->
        <xsl:choose>
            <xsl:when test="self::include">
                <tr>
                    <td style="background-color: white" colspan="6">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'Included'"/>
                        </xsl:call-template>
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'fromLabel'"/>
                        </xsl:call-template>
                        <!-- jump to tab panel with templates to the right vocab and open the accordion -->
                        <a href="{$ahref}" target="_blank">
                            <xsl:value-of select="$xtid"/>
                        </a>
                        <xsl:text> </xsl:text>
                        <i>
                            <xsl:value-of select="$xtnm"/>
                        </i>
                        <xsl:text> (</xsl:text>
                        <xsl:choose>
                            <xsl:when test="matches($xflex,'^\d{4}')">
                                <xsl:call-template name="showDate">
                                    <xsl:with-param name="date" select="$xflex"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'associationDYNAMIC'"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>)</xsl:text>
                        <xsl:text> </xsl:text>
                        <xsl:call-template name="doCardConf">
                            <xsl:with-param name="minimumMultiplicity" select="$minimumMultiplicity"/>
                            <xsl:with-param name="maximumMultiplicity" select="$maximumMultiplicity"/>
                            <xsl:with-param name="isMandatory" select="$isMandatory"/>
                            <xsl:with-param name="conformance" select="$conformance"/>
                        </xsl:call-template>
                    </td>
                </tr>
            </xsl:when>
            <xsl:when test="self::choice">
                <!-- this is a choice with -->
                <tr>
                    <td style="background-color: white" colspan="6">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'choiceLabel'"/>
                        </xsl:call-template>
                        <xsl:if test="@minimumMultiplicity">
                            <xsl:text> </xsl:text>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'choiceElementsMin'"/>
                                <xsl:with-param name="p1" select="@minimumMultiplicity"/>
                            </xsl:call-template>
                        </xsl:if>
                        <xsl:if test="@minimumMultiplicity and @maximumMultiplicity">
                            <xsl:text> </xsl:text>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'andWord'"/>
                            </xsl:call-template>
                        </xsl:if>
                        <xsl:if test="@maximumMultiplicity">
                            <xsl:text> </xsl:text>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'choiceElementsMax'"/>
                                <xsl:with-param name="p1" select="@maximumMultiplicity"/>
                            </xsl:call-template>
                        </xsl:if>
                        <xsl:text>. </xsl:text>
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'choiceElements'"/>
                        </xsl:call-template>
                        <ul>
                            <xsl:for-each select="element|include">
                                <li>
                                    <xsl:choose>
                                        <xsl:when test="self::include">
                                            <xsl:variable name="rccontent">
                                                <xsl:call-template name="getRulesetContent">
                                                    <xsl:with-param name="ruleset" select="@ref"/>
                                                    <xsl:with-param name="flexibility" select="@flexibility"/>
                                                </xsl:call-template>
                                            </xsl:variable>

                                            <xsl:call-template name="getMessage">
                                                <xsl:with-param name="key" select="'including'"/>
                                                <xsl:with-param name="p1">
                                                    <xsl:choose>
                                                        <xsl:when test="string-length(($rccontent/*/element/@name)[1])>0">
                                                            <xsl:value-of select="($rccontent/*/element/@name)[1]"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <!-- undetermined element -->
                                                            <xsl:call-template name="getMessage">
                                                                <xsl:with-param name="key" select="'anElement'"/>
                                                            </xsl:call-template>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:with-param>
                                                <xsl:with-param name="p2">
                                                    <xsl:choose>
                                                        <xsl:when test="$rccontent/*[@displayName]">
                                                            <xsl:value-of select="$rccontent/*/@displayName"/>
                                                        </xsl:when>
                                                        <xsl:when test="$rccontent/*[@name]">
                                                            <xsl:value-of select="$rccontent/*/@name"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="@ref"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:with-param>
                                                <xsl:with-param name="p3">
                                                    <xsl:choose>
                                                        <xsl:when test="matches(@flexibility,'^\d{4}')">
                                                            <xsl:call-template name="showDate">
                                                                <xsl:with-param name="date" select="@flexibility"/>
                                                            </xsl:call-template>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:call-template name="getMessage">
                                                                <xsl:with-param name="key" select="'associationDYNAMIC'"/>
                                                            </xsl:call-template>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:with-param>
                                            </xsl:call-template>
                                        </xsl:when>

                                        <xsl:when test="self::element[@name and @contains]">
                                            <xsl:variable name="rccontent">
                                                <xsl:call-template name="getRulesetContent">
                                                    <xsl:with-param name="ruleset" select="@contains"/>
                                                    <xsl:with-param name="flexibility" select="@flexibility"/>
                                                </xsl:call-template>
                                            </xsl:variable>
                                            <xsl:call-template name="getMessage">
                                                <xsl:with-param name="key" select="'containment'"/>
                                                <xsl:with-param name="p1" select="@name"/>
                                                <xsl:with-param name="p2" select="($rccontent/*/element/@name)[1]"/>
                                                <xsl:with-param name="p3">
                                                    <xsl:choose>
                                                        <xsl:when test="$rccontent/*[@displayName]">
                                                            <xsl:value-of select="$rccontent/*/@displayName"/>
                                                        </xsl:when>
                                                        <xsl:when test="$rccontent/*[@name]">
                                                            <xsl:value-of select="$rccontent/*/@name"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="@contains"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:with-param>
                                                <xsl:with-param name="p4">
                                                    <xsl:choose>
                                                        <xsl:when test="matches(@flexibility,'^\d{4}')">
                                                            <xsl:call-template name="showDate">
                                                                <xsl:with-param name="date" select="@flexibility"/>
                                                            </xsl:call-template>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:call-template name="getMessage">
                                                                <xsl:with-param name="key" select="'associationDYNAMIC'"/>
                                                            </xsl:call-template>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:with-param>
                                            </xsl:call-template>
                                        </xsl:when>

                                        <xsl:when test="self::element[@contains]">
                                            <xsl:variable name="rccontent">
                                                <xsl:call-template name="getRulesetContent">
                                                    <xsl:with-param name="ruleset" select="@contains"/>
                                                    <xsl:with-param name="flexibility" select="@flexibility"/>
                                                </xsl:call-template>
                                            </xsl:variable>
                                            <xsl:call-template name="getMessage">
                                                <xsl:with-param name="key" select="'containment'"/>
                                                <xsl:with-param name="p1" select="@name"/>
                                                <xsl:with-param name="p2">
                                                    <xsl:choose>
                                                        <xsl:when test="string-length(($rccontent/*/element/@name)[1])>0">
                                                            <xsl:value-of select="($rccontent/*/element/@name)[1]"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <!-- undetermined element -->
                                                            <xsl:call-template name="getMessage">
                                                                <xsl:with-param name="key" select="'anElement'"/>
                                                            </xsl:call-template>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:with-param>
                                                <xsl:with-param name="p3">
                                                    <xsl:choose>
                                                        <xsl:when test="$rccontent/*[@displayName]">
                                                            <xsl:value-of select="$rccontent/*/@displayName"/>
                                                        </xsl:when>
                                                        <xsl:when test="$rccontent/*[@name]">
                                                            <xsl:value-of select="$rccontent/*/@name"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="@contains"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:with-param>
                                                <xsl:with-param name="p4">
                                                    <xsl:choose>
                                                        <xsl:when test="matches(@flexibility,'^\d{4}')">
                                                            <xsl:call-template name="showDate">
                                                                <xsl:with-param name="date" select="@flexibility"/>
                                                            </xsl:call-template>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:call-template name="getMessage">
                                                                <xsl:with-param name="key" select="'associationDYNAMIC'"/>
                                                            </xsl:call-template>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:with-param>
                                            </xsl:call-template>
                                        </xsl:when>

                                        <xsl:when test="self::element">
                                            <xsl:call-template name="getWherePathFromNodeset">
                                                <xsl:with-param name="rccontent" select="."/>
                                            </xsl:call-template>
                                        </xsl:when>

                                    </xsl:choose>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </td>
                </tr>
            </xsl:when>
            <xsl:otherwise>
                <!-- this is a normal element -->
                <tr bgcolor="&infmColorLight;">
                    <td style="vertical-align: top;">
                        <xsl:if test="@id">
                            <a>
                                <xsl:attribute name="name">
                                    <xsl:call-template name="getAnchorName">
                                        <xsl:with-param name="id" select="@id"/>
                                    </xsl:call-template>
                                </xsl:attribute>
                            </a>
                        </xsl:if>
                        <table border="0" cellpadding="1">
                            <!-- show pathname or so-->
                            <xsl:choose>
                                <xsl:when test="@name and @contains">
                                    <tr>
                                        <xsl:call-template name="doIndentLevel">
                                            <xsl:with-param name="level" select="$level"/>
                                        </xsl:call-template>
                                        <td>
                                            <xsl:call-template name="outputPath">
                                                <xsl:with-param name="pathname">
                                                    <xsl:call-template name="getWherePathFromNodeset">
                                                        <xsl:with-param name="rccontent" select="."/>
                                                    </xsl:call-template>
                                                </xsl:with-param>
                                            </xsl:call-template>
                                        </td>
                                    </tr>
                                </xsl:when>
                                <xsl:when test="@name">
                                    <tr>
                                        <xsl:call-template name="doIndentLevel">
                                            <xsl:with-param name="level" select="$level"/>
                                        </xsl:call-template>
                                        <td>
                                            <xsl:call-template name="outputPath">
                                                <xsl:with-param name="pathname" select="@name"/>
                                            </xsl:call-template>
                                        </td>
                                    </tr>
                                </xsl:when>
                                <xsl:otherwise>
                                    <tr>
                                        <td> </td>
                                    </tr>
                                </xsl:otherwise>
                            </xsl:choose>
                        </table>
                    </td>

                    <!-- do datatype -->
                    <td style="vertical-align: top;">
                        <strong>
                            <xsl:value-of select="@datatype"/>
                        </strong>
                    </td>

                    <!-- original multiplicity and conformance, 2DO only if different from inherited cardinality -->
                    <xsl:variable name="fontcolor">
                        <xsl:choose>
                            <!-- if calc cards has been shown already, orig cardinality is shown in grey font only... -->
                            <!--xsl:when test="count($cid)>0">
                                <xsl:text>gray</xsl:text>
                            </xsl:when-->
                            <xsl:when test="0=1"/>
                            <!-- ...black otherwise -->
                            <xsl:otherwise>
                                <xsl:text>black</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>

                    <!-- show cardinality -->
                    <td style="vertical-align: top;">
                        <span style="color: {$fontcolor};">
                            <strong>
                                <xsl:value-of select="$minimumMultiplicity"/>
                                <xsl:if test="string-length(concat($minimumMultiplicity,$maximumMultiplicity))>0">
                                    <xsl:text>&#160;..&#160;</xsl:text>
                                </xsl:if>
                                <xsl:value-of select="$maximumMultiplicity"/>
                            </strong>
                        </span>
                    </td>

                    <!-- show conformance -->
                    <td style="vertical-align: top;">
                        <span style="color: {$fontcolor};">
                            <strong>
                                <xsl:choose>
                                    <xsl:when test="string($isMandatory)='true'">
                                        <xsl:text>M</xsl:text>
                                    </xsl:when>
                                    <!-- 2DO conditional -->
                                    <xsl:otherwise>
                                        <xsl:value-of select="$conformance"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </strong>
                        </span>
                    </td>

                    <!-- show description or include/choice content -->
                    <td>

                        <xsl:call-template name="doDescription">
                            <xsl:with-param name="ns" select="desc"/>
                        </xsl:call-template>
                        <!-- show error message if minimumMultiplicity=0 and isMandatory=true -->
                        <xsl:if test="@minimumMultiplicity=0 and @isMandatory='true'">
                            <p>
                                <table border="0">
                                    <xsl:call-template name="doMessage">
                                        <xsl:with-param name="level" select="'warning'"/>
                                        <xsl:with-param name="msg">
                                            <xsl:call-template name="getMessage">
                                                <xsl:with-param name="key" select="'issueIfIsMandatoryTrueMinimumMultiplicityGreaterThanZero'"/>
                                            </xsl:call-template>
                                        </xsl:with-param>
                                    </xsl:call-template>
                                </table>
                            </p>
                        </xsl:if>
                    </td>

                    <!-- show item label -->
                    <td style="background-color: #FFEEEE">
                        <xsl:if test="string-length($itemlabel)>0">
                            <xsl:value-of select="$itemlabel"/>
                            <!--
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'xInBraces'"/>
                                <xsl:with-param name="p1" select="$itemlabel"/>
                            </xsl:call-template>
                            -->
                        </xsl:if>
                    </td>

                </tr>
            </xsl:otherwise>
        </xsl:choose>

        <!-- do all subsequent attributes first -->
        <xsl:apply-templates select="attribute" mode="templateparticle">
            <xsl:with-param name="level" select="$level+1"/>
        </xsl:apply-templates>

        <!-- do constraints -->
        <xsl:for-each select="constraint">
            <tr bgcolor="#FAFAD2" valign="top">
                <td style="background-color: white"> </td>
                <td class="conf">
                    <xsl:call-template name="getMessage">
                        <xsl:with-param name="key" select="'constraintLabel'"/>
                    </xsl:call-template>
                </td>
                <td style="background-color: #FAFAD2" colspan="4">
                    <xsl:call-template name="doDescription">
                        <xsl:with-param name="ns" select="."/>
                    </xsl:call-template>
                </td>
            </tr>
        </xsl:for-each>

        <!-- do schematron extras
        <xsl:apply-templates select="assert|report|defineVariable|let" mode="templateparticle"/>
        -->

        <!-- show overridden cardinality, drawn from a concept if present -->
        <xsl:if test="string-length($cid[1])>1000000000000">
            <tr>
                <td style="background-color: #FFEEEE">
                    <xsl:call-template name="getMessage">
                        <xsl:with-param name="key" select="'cardinalityByOverride'"/>
                    </xsl:call-template>
                </td>
                <td style="background-color: #FFEEEE">
                    <xsl:value-of select="$minimumMultiplicity"/>
                    <xsl:text> .. </xsl:text>
                    <xsl:value-of select="$maximumMultiplicity"/>
                    <xsl:if test="$isMandatory='true'">
                        <xsl:text>&#160;</xsl:text>
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'conformanceMandatory'"/>
                        </xsl:call-template>
                    </xsl:if>
                    <xsl:if test="$minimumMultiplicity=0 and $isMandatory='true'">
                        <table border="0">
                            <xsl:call-template name="doMessage">
                                <xsl:with-param name="level" select="'warning'"/>
                                <xsl:with-param name="msg">
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'issueIfIsMandatoryTrueMinimumMultiplicityGreaterThanZero'"/>
                                    </xsl:call-template>
                                </xsl:with-param>
                            </xsl:call-template>
                        </table>
                    </xsl:if>
                    <xsl:if test="$conformance">
                        <!-- TODO: work on facets like NP not present, etc. -->
                        <xsl:text>&#160;</xsl:text>
                        <xsl:choose>
                            <xsl:when test="$conformance='NP'">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'conformanceNPWithCardinality'"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="getXFormsLabel">
                                    <xsl:with-param name="simpleTypeKey" select="'ConformanceType'"/>
                                    <xsl:with-param name="lang" select="$defaultLanguage"/>
                                    <xsl:with-param name="simpleTypeValue" select="$conformance"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                    <xsl:for-each select="$cid">
                        <xsl:variable name="conceptId" select="."/>
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'drawnFromConcept'"/>
                            <xsl:with-param name="p1" select="$conceptId"/>
                            <xsl:with-param name="p2" select="$allDatasetConceptsFlat//concept[@id=$conceptId]/name"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </td>
            </tr>
        </xsl:if>

        <!-- do vocabularies -->
        <xsl:choose>
            <xsl:when test="count(vocabulary)=1 and not(vocabulary[@valueSet or @domain])">
                <xsl:variable name="theCode" select="vocabulary/@code"/>
                <xsl:variable name="theCodeSystem" select="vocabulary/@codeSystem"/>
                <xsl:variable name="theDisplayName">
                    <xsl:choose>
                        <xsl:when test="@displayName">
                            <xsl:value-of select="@displayName"/>
                        </xsl:when>
                        <xsl:when test="@code and @codeSystem">
                            <xsl:value-of select="($allValueSets/*/valueSet/conceptList/concept[@code=$theCode and @codeSystem=$theCodeSystem]/@displayName)[1]"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <xsl:for-each select="vocabulary/@*">
                    <!-- cache attribute name and value of attribute -->
                    <xsl:variable name="theAttName" select="name(.)"/>
                    <xsl:variable name="theAttValue" select="."/>
                    <tr>
                        <td>
                            <table border="0" cellpadding="1">
                                <tr>
                                    <xsl:call-template name="doIndentLevel">
                                        <xsl:with-param name="level" select="$level+1"/>
                                    </xsl:call-template>
                                    <td>
                                        <xsl:text>@</xsl:text>
                                        <xsl:call-template name="outputPath">
                                            <xsl:with-param name="pathname" select="$theAttName"/>
                                        </xsl:call-template>
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td> </td>
                        <!-- cardinality is always 1..1 -->
                        <td>
                            <xsl:text>1&#160;..&#160;1</xsl:text>
                        </td>
                        <!-- conformance -->
                        <td>
                            <xsl:choose>
                                <!-- choice -->
                                <xsl:when test="contains($theAttValue, '|')">
                                    <xsl:text>&#160;</xsl:text>
                                </xsl:when>
                                <xsl:when test="string-length($theAttValue)>0">
                                    <xsl:text>F</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>&#160;</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                        <td colspan="2">
                            <xsl:choose>
                                <!-- choice -->
                                <xsl:when test="contains($theAttValue, '|')">
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'attribShallChoice'"/>
                                        <xsl:with-param name="p1" select="$theAttName"/>
                                    </xsl:call-template>
                                    <ul>
                                        <xsl:for-each select="tokenize($theAttValue, '\|')">
                                            <li>
                                                <xsl:value-of select="."/>
                                            </li>
                                        </xsl:for-each>
                                    </ul>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$theAttValue"/>
                                    <xsl:if test="string-length($theDisplayName)>0 and name(.)='code'">
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="'xInBraces'"/>
                                            <xsl:with-param name="p1" select="$theDisplayName"/>
                                        </xsl:call-template>
                                    </xsl:if>
                                </xsl:otherwise>
                            </xsl:choose>

                            <xsl:if test="$theAttName='codeSystem'">
                                <xsl:variable name="theName">
                                    <xsl:call-template name="getIDDisplayName">
                                        <xsl:with-param name="root" select="$theCodeSystem"/>
                                    </xsl:call-template>
                                </xsl:variable>

                                <xsl:if test="string-length($theName)>0">
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'xInBraces'"/>
                                        <xsl:with-param name="p1" select="$theName"/>
                                    </xsl:call-template>
                                </xsl:if>
                            </xsl:if>
                        </td>
                    </tr>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="count(vocabulary)>0">
                <tr>
                    <td style="background-color: white"> </td>
                    <td class="conf" valign="top">
                        <xsl:text>CONF </xsl:text>
                    </td>
                    <td colspan="4">
                        <table width="100%" border="0" cellspacing="2" cellpadding="2">

                            <xsl:for-each select="vocabulary">
                                <xsl:call-template name="doVocabularyAttributes">
                                    <xsl:with-param name="targetAttributeName" select="'code'"/>
                                </xsl:call-template>
                                <xsl:if test="position()!=last()">
                                    <tr valign="top">
                                        <td>
                                            <xsl:call-template name="getMessage">
                                                <xsl:with-param name="key" select="'orWord'"/>
                                            </xsl:call-template>
                                        </td>
                                    </tr>
                                </xsl:if>
                            </xsl:for-each>

                        </table>
                    </td>
                </tr>
            </xsl:when>
        </xsl:choose>

        <!-- do properties -->
        <xsl:if test="count(property)>0">
            <tr>
                <td style="background-color: white"> </td>
                <td class="conf" valign="top">
                    <xsl:text>CONF </xsl:text>
                </td>
                <td colspan="4">
                    <table width="100%" border="0" cellspacing="2" cellpadding="2">
                        <xsl:for-each select="property">
                            <xsl:for-each select="@*">
                                <xsl:variable name="tdcontent">
                                    <xsl:choose>
                                        <xsl:when test="name(.)='value'">
                                            <td>
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'attribIs'"/>
                                                    <xsl:with-param name="p1" select="name(.)"/>
                                                    <xsl:with-param name="p2" select="."/>
                                                </xsl:call-template>
                                            </td>
                                        </xsl:when>
                                        <xsl:when test="name(.)='unit'">
                                            <td>
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'attribIs'"/>
                                                    <xsl:with-param name="p1" select="name(.)"/>
                                                    <xsl:with-param name="p2" select="."/>
                                                </xsl:call-template>
                                            </td>
                                        </xsl:when>
                                        <xsl:when test="name(.)='currency'">
                                            <td>
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'attribIs'"/>
                                                    <xsl:with-param name="p1" select="name(.)"/>
                                                    <xsl:with-param name="p2" select="."/>
                                                </xsl:call-template>
                                            </td>
                                        </xsl:when>
                                        <xsl:when test="name(.)='fractionDigits'">
                                            <td>
                                                <xsl:choose>
                                                    <xsl:when test="string-length(.)=0">
                                                        <xsl:call-template name="getMessage">
                                                            <xsl:with-param name="key" select="'attribFracDigits'"/>
                                                        </xsl:call-template>
                                                    </xsl:when>
                                                    <xsl:when test="matches(string(.), '!$')">
                                                        <!-- exact fraction digits -->
                                                        <xsl:call-template name="getMessage">
                                                            <xsl:with-param name="key" select="'attribFracDigitsExact'"/>
                                                            <xsl:with-param name="p1" select="substring-before(., '!')"/>
                                                        </xsl:call-template>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <!-- minimum no of digits -->
                                                        <xsl:call-template name="getMessage">
                                                            <xsl:with-param name="key" select="'attribFracDigitsMin'"/>
                                                            <xsl:with-param name="p1" select="."/>
                                                        </xsl:call-template>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </td>
                                        </xsl:when>
                                        <xsl:when test="name(.)='minInclude'">
                                            <td>
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'attribMinIncludeIs'"/>
                                                    <xsl:with-param name="p1" select="name(.)"/>
                                                    <xsl:with-param name="p2" select="."/>
                                                </xsl:call-template>
                                            </td>
                                        </xsl:when>
                                        <xsl:when test="name(.)='maxInclude'">
                                            <td>
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'attribMaxIncludeIs'"/>
                                                    <xsl:with-param name="p1" select="name(.)"/>
                                                    <xsl:with-param name="p2" select="."/>
                                                </xsl:call-template>
                                            </td>
                                        </xsl:when>
                                        <xsl:when test="name(.)='minLength'">
                                            <td>
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'attribMinLengthIs'"/>
                                                    <xsl:with-param name="p1" select="name(.)"/>
                                                    <xsl:with-param name="p2" select="."/>
                                                </xsl:call-template>
                                            </td>
                                        </xsl:when>
                                        <xsl:when test="name(.)='maxLength'">
                                            <td>
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'attribMaxLengthIs'"/>
                                                    <xsl:with-param name="p1" select="name(.)"/>
                                                    <xsl:with-param name="p2" select="."/>
                                                </xsl:call-template>
                                            </td>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <td>?</td>
                                            <!-- Don't silently fail this...question marks hard to spot in large specifications -->
                                            <xsl:call-template name="logMessage">
                                                <xsl:with-param name="level" select="$logERROR"/>
                                                <xsl:with-param name="msg">
                                                    <xsl:text>+++ found unrecognized property attribute "@</xsl:text>
                                                    <xsl:value-of select="name(.)"/>=<xsl:value-of select="."/>
                                                    <xsl:text>" in template id "</xsl:text>
                                                    <xsl:value-of select="ancestor::template/@id"/>
                                                    <xsl:text>"</xsl:text>
                                                </xsl:with-param>
                                            </xsl:call-template>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <xsl:if test="count($tdcontent)>0">
                                    <tr valign="top">
                                        <xsl:copy-of select="$tdcontent"/>
                                    </tr>
                                </xsl:if>
                            </xsl:for-each>
                            <xsl:if test="position()!=last()">
                                <tr valign="top">
                                    <td>
                                        <xsl:text>-</xsl:text>
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="'orWord'"/>
                                        </xsl:call-template>
                                        <xsl:text>-</xsl:text>
                                    </td>
                                </tr>
                            </xsl:if>
                        </xsl:for-each>
                    </table>
                </td>
            </tr>
        </xsl:if>

        <!-- do text -->
        <xsl:if test="count(text)>0">
            <tr bgcolor="#FFEEEE" valign="top">
                <td style="background-color: white"> </td>
                <td class="conf" valign="top">
                    <xsl:text>CONF </xsl:text>
                </td>
                <td colspan="4" style="background-color: white">
                    <table width="100%" border="0" cellspacing="2" cellpadding="2">
                        <xsl:for-each select="text">
                            <tr valign="top">
                                <td>
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'elementContentShallBe'"/>
                                        <xsl:with-param name="p1" select="text()"/>
                                    </xsl:call-template>
                                </td>
                            </tr>
                            <xsl:if test="position()!=last()">
                                <tr valign="top">
                                    <td>
                                        <xsl:text>-</xsl:text>
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="'orWord'"/>
                                        </xsl:call-template>
                                        <xsl:text>-</xsl:text>
                                    </td>
                                </tr>
                            </xsl:if>
                        </xsl:for-each>
                    </table>
                </td>
            </tr>
        </xsl:if>

        <!-- @closed, only displaying closed for now, to avoid clutter... -->
        <xsl:if test="string(@isClosed)='true'">
            <tr valign="top">
                <td style="background-color: white"> </td>
                <td valign="top" align="left">
                    <xsl:call-template name="getMessage">
                        <xsl:with-param name="key" select="'openClosedLabel'"/>
                    </xsl:call-template>
                </td>
                <td colspan="4" class="tabtab">
                    <xsl:choose>
                        <xsl:when test="string(@isClosed)='true'">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'elementIsClosed'"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'elementIsOpen'"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </tr>
        </xsl:if>

        <!-- do target id (element id as a target for a concept) -->
        <xsl:if test="@id">
            <xsl:variable name="theId" select="@id"/>
            <!-- As discussed: this is purely of technical 'under water' nature and holds no information to anyone except perhaps the developer/author of the Decor file -->
            <!--tr>
                <td bgcolor="white"> </td>
                <td>
                    <xsl:call-template name="getMessage">
                        <xsl:with-param name="key" select="'idAsTarget'"/>
                    </xsl:call-template>
                </td>
                <td colspan="4">
                    <xsl:value-of select="$theId"/>
                </td>
            </tr-->

            <!-- do template associations -->
            <xsl:if test="count($allTemplateAssociation/*/templateAssociation[@templateId=$tid][@effectiveDate=$teff]/concept[@elementId = $theId])>0">
                <tr>
                    <td style="background-color: white"> </td>
                    <td valign="top" align="center">
                        <xsl:call-template name="showIcon">
                            <xsl:with-param name="which">target</xsl:with-param>
                        </xsl:call-template>
                    </td>
                    <td colspan="4" class="tabtab" style="background-color: &mediColorLight;">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'targetOfConceptIds'"/>
                        </xsl:call-template>

                        <table width="100%" border="0" cellspacing="2" cellpadding="2">
                            <xsl:for-each-group select="$allTemplateAssociation/*/templateAssociation[@templateId=$tid][@effectiveDate=$teff]/concept[@elementId = $theId]" group-by="@ref">

                                <xsl:variable name="targetConceptId" select="@ref"/>
                                <xsl:variable name="targetConceptEff">
                                    <xsl:choose>
                                        <xsl:when test="@effectiveDate">
                                            <!-- Use if present -->
                                            <xsl:value-of select="@effectiveDate"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <!-- Get the latest @effectiveDate for this concept -->
                                            <xsl:value-of select="string(max($allDatasetConceptsFlat//concept[@id=$targetConceptId][not(ancestor::history)][not(parent::conceptList)]/xs:dateTime(@effectiveDate)))"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>

                                <xsl:for-each select="$allDatasetConceptsFlat/*/*/concept[@id=$targetConceptId]">
                                    <tr style="background-color: &mediColorLight;">
                                        <td valign="top" width="25%">
                                            <a>
                                                <xsl:attribute name="href">
                                                    <xsl:text>ds-</xsl:text>
                                                    <xsl:value-of select="ancestor::dataset/@id"/>
                                                    <xsl:text>.html#</xsl:text>
                                                    <xsl:call-template name="getAnchorName">
                                                        <xsl:with-param name="id" select="$targetConceptId"/>
                                                        <xsl:with-param name="effectiveDate" select="$targetConceptEff"/>
                                                    </xsl:call-template>
                                                </xsl:attribute>
                                                <xsl:call-template name="doShorthandId">
                                                    <xsl:with-param name="id" select="$targetConceptId"/>
                                                </xsl:call-template>
                                            </a>
                                        </td>
                                        <td valign="top">
                                            <xsl:call-template name="doName">
                                                <xsl:with-param name="ns" select="name"/>
                                            </xsl:call-template>
                                        </td>
                                    </tr>
                                </xsl:for-each>

                            </xsl:for-each-group>

                        </table>

                    </td>
                </tr>
            </xsl:if>
        </xsl:if>

        <xsl:apply-templates select="example" mode="templateparticle"/>

        <xsl:if test="@contains">
            <tr bgcolor="#FFEEEE" valign="top">
                <td style="background-color: white"> </td>
                <td style="background-color: #FFEEEE">
                    <xsl:call-template name="getMessage">
                        <xsl:with-param name="key" select="'Contains'"/>
                    </xsl:call-template>
                </td>
                <td style="background-color: #FFEEAA" colspan="3">
                    <xsl:choose>
                        <xsl:when test="count($rccontent/*/(element|assert|report|defineVariable|let))>0">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'inheritedRulesetWithTemplate'"/>
                                <xsl:with-param name="p1" select="$ahref"/>
                                <xsl:with-param name="p2" select="$xtid"/>
                                <xsl:with-param name="p3" select="$xtnm"/>
                                <xsl:with-param name="p4">
                                    <xsl:choose>
                                        <xsl:when test="matches($xflex,'^\d{4}')">
                                            <xsl:call-template name="showDate">
                                                <xsl:with-param name="date" select="$xflex"/>
                                            </xsl:call-template>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:call-template name="getMessage">
                                                <xsl:with-param name="key" select="'associationDYNAMIC'"/>
                                            </xsl:call-template>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'anElementWithTemplate'"/>
                                <xsl:with-param name="p1">
                                    <xsl:choose>
                                        <xsl:when test="$rccontent/*[@displayName]">
                                            <xsl:value-of select="$rccontent/*/@displayName"/>
                                        </xsl:when>
                                        <xsl:when test="$rccontent/*[@name]">
                                            <xsl:value-of select="$rccontent/*/@name"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$xref"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:with-param>
                                <xsl:with-param name="p2">
                                    <xsl:choose>
                                        <xsl:when test="matches($xflex,'^\d{4}')">
                                            <xsl:call-template name="showDate">
                                                <xsl:with-param name="date" select="$xflex"/>
                                            </xsl:call-template>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:call-template name="getMessage">
                                                <xsl:with-param name="key" select="'associationDYNAMIC'"/>
                                            </xsl:call-template>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                    
                    <!-- no longer exposed in this way KH 20141103
                    <xsl:if test="$minimumMultiplicity or $maximumMultiplicity">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'withOverriddenCardinality'"/>
                        </xsl:call-template>
                        <xsl:call-template name="doCardConf">
                            <xsl:with-param name="minimumMultiplicity" select="$minimumMultiplicity"/>
                            <xsl:with-param name="maximumMultiplicity" select="$maximumMultiplicity"/>
                            <xsl:with-param name="isMandatory" select="$isMandatory"/>
                            <xsl:with-param name="conformance" select="$conformance"/>
                        </xsl:call-template>
                    </xsl:if>
                    -->
                </td>
            </tr>

            <!-- show embedded elements etc in the contains rule -->
            <xsl:if test="count(element|assert|report|defineVariable|let)>11111111110">
                <xsl:apply-templates select="element|assert|report|defineVariable|let" mode="templateparticle">
                    <xsl:with-param name="level" select="$level+1"/>
                </xsl:apply-templates>
            </xsl:if>
            <!-- 
                hoe omgaan met element @contains
                ========?????????
            -->
            <!--
            <tr bgcolor="#FFEEEE" valign="top">
                <td>Elements</td>
                <td bgcolor="#FFEEEE" colspan="2">
                    <table width="100%" border="0" cellspacing="2" cellpadding="2">
                        <tr valign="top">
                            <td class="tabtab">
                                <table width="100%" border="0" cellspacing="3" cellpadding="2">
                                    <xsl:variable name="rccontent">
                                        <xsl:call-template name="getRulesetContent">
                                            <xsl:with-param name="ruleset" select="$contains"/>
                                        </xsl:call-template>
                                    </xsl:variable>
                                    <xsl:choose>
                                        <xsl:when test="count($rccontent/*/(element|assert|report|defineVariable))>0">
                                            <xsl:apply-templates select="$rccontent/*/(element|assert|report|defineVariable)"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:call-template name="doMessage">
                                                <xsl:with-param name="msg">
                                                    <xsl:text>Cannot find ruleset '</xsl:text>
                                                    <xsl:value-of select="@contains"/>
                                                <xsl:text>'</xsl:text>
                                                </xsl:with-param>
                                            </xsl:call-template>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </table>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            -->

        </xsl:if>

        <xsl:if test="name()='include'">
            <xsl:variable name="rccontent">
                <xsl:call-template name="getRulesetContent">
                    <xsl:with-param name="ruleset" select="$xref"/>
                    <xsl:with-param name="flexibility" select="$xflex"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="count($rccontent/*/(attribute|element|include|choice))>0">
                    <!--
                        <xsl:apply-templates select="$rccontent/*/(element|assert|report|defineVariable|include|choice)" mode="templateparticle"/>
                    -->
                    <!-- get a possible new item label -->
                    <xsl:variable name="newitemlabel">
                        <xsl:choose>
                            <xsl:when test="string-length($rccontent/*/item/@label)>0">
                                <xsl:value-of select="$rccontent/*/item/@label"/>
                            </xsl:when>
                            <!--
                            <xsl:when test="string-length($rccontent/*/attribute/item/@label)>0">
                                <xsl:value-of select="$rccontent/*/attribute/item/@label"/>
                            </xsl:when>
                            <xsl:when test="string-length($rccontent/*/element/item/@label)>0">
                                <xsl:value-of select="$rccontent/*/element/item/@label"/>
                            </xsl:when>
                            -->
                            <xsl:otherwise>
                                <xsl:value-of select="$itemlabel"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:apply-templates select="$rccontent/*/(attribute|element|include|choice)" mode="templateparticle">
                        <xsl:with-param name="level" select="$level"/>
                        <xsl:with-param name="label" select="$newitemlabel"/>
                        <xsl:with-param name="inheritedminimumMultiplicity" select="$minimumMultiplicity"/>
                        <xsl:with-param name="inheritedmaximumMultiplicity" select="$maximumMultiplicity"/>
                        <xsl:with-param name="inheritedConformance" select="$conformance"/>
                        <xsl:with-param name="inheritedIsMandatory" select="$isMandatory"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <tr>
                        <td style="background-color: white"> </td>
                        <td colspan="4">
                            <table border="0">
                                <xsl:call-template name="doMessage">
                                    <xsl:with-param name="msg">
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="'cannotFindRuleSet'"/>
                                            <xsl:with-param name="p1" select="$xref"/>
                                        </xsl:call-template>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </table>
                        </td>
                    </tr>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>

        <!-- <xsl:if test="following-sibling::element|following-sibling::include|following-sibling::choice">
            <tr>
                <td colspan="3">
                    <hr/>
                </td>
            </tr>
        </xsl:if>
        -->

        <xsl:apply-templates select="element|include|choice|assert|report|let" mode="templateparticle">
            <xsl:with-param name="level" select="$level+1"/>
            <xsl:with-param name="label" select="$itemlabel"/>
        </xsl:apply-templates>
    </xsl:template>
    
	<xsl:template name="doVocabularyAttributes">
		<xsl:param name="targetAttributeName" />
		<xsl:variable name="xvsref" select="@valueSet" />
		<xsl:variable name="xvsflex" select="if (@flexibility) then (@flexibility) else ('dynamic')" />
		<xsl:variable name="xvs">
			<xsl:call-template name="getValueset">
				<xsl:with-param name="reference" select="$xvsref" />
				<xsl:with-param name="flexibility" select="$xvsflex" />
			</xsl:call-template>
		</xsl:variable>

		<xsl:for-each select="@*">
			<xsl:variable name="tdcontent">
				<xsl:choose>
					<xsl:when test="name(.)='valueSet'">
						<xsl:variable name="xvsid" select="($xvs/valueSet)[1]/@id" />
						<xsl:variable name="xvsname">
							<xsl:choose>
								<xsl:when test="string-length(($xvs/valueSet)[1]/@displayName)>0">
									<xsl:value-of select="($xvs/valueSet)[1]/@displayName" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="($xvs/valueSet)[1]/@name" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="ahref">
							<xsl:choose>
								<xsl:when test="$xvsflex='dynamic'">
									<xsl:value-of select="concat('voc-', $xvsid, '-DYNAMIC.html')" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat('voc-', $xvsid, '-',replace($xvsflex,':',''),'.html')" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>

						<td>
							<xsl:variable name="vs" select="." />
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'codeShallBeFromValueSet'" />
								<xsl:with-param name="p1" select="$targetAttributeName" />
							</xsl:call-template>

							<!-- link to vocab html -->
							<a href="{$ahref}" target="_blank">
								<xsl:value-of select="$xvsid" />
							</a>
							<xsl:text> </xsl:text>

							<!--xsl:if test="string-length(parent::*/@flexibility)>0"> <xsl:call-template name="getMessage"> <xsl:with-param name="key" select="'flexibilityLabel'"/> </xsl:call-template> <xsl:text>&#160;</xsl:text> 
								<xsl:value-of select="parent::*/@flexibility"/> </xsl:if -->
							<i>
								<xsl:value-of select="$xvsname" />
								<xsl:text>&#160;</xsl:text>
								<xsl:text>(</xsl:text>
								<xsl:choose>
									<xsl:when test="matches($xvsflex,'^\d{4}')">
										<xsl:call-template name="showDate">
											<xsl:with-param name="date" select="$xvsflex" />
										</xsl:call-template>
									</xsl:when>
									<xsl:otherwise>
										<xsl:call-template name="getMessage">
											<xsl:with-param name="key" select="'associationDYNAMIC'" />
										</xsl:call-template>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:text>)</xsl:text>
							</i>

							<!-- show "value set not found" message if not found -->
							<xsl:if test="count($valueSetReferenceErrors/*/error[@id=$vs])>0">
								<table border="0">
									<xsl:call-template name="doMessage">
										<xsl:with-param name="msg">
											<xsl:call-template name="getMessage">
												<xsl:with-param name="key" select="'CannotFindValueSet'" />
												<xsl:with-param name="p1" select="$vs" />
											</xsl:call-template>
										</xsl:with-param>
									</xsl:call-template>
								</table>
							</xsl:if>

						</td>
					</xsl:when>
					<xsl:when test="name(.)='code'">
						<td>
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'codeorsoShallBeX'" />
								<xsl:with-param name="p1" select="$targetAttributeName" />
								<xsl:with-param name="p2" select="." />
							</xsl:call-template>
						</td>
					</xsl:when>
					<xsl:when test="name(.)='codeSystem'">
						<td>
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'codeSystemShallBeX'" />
								<xsl:with-param name="p1" select="." />
							</xsl:call-template>
						</td>
					</xsl:when>
					<xsl:when test="name(.)='displayName'">
						<td>
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'displayNameShallBeX'" />
								<xsl:with-param name="p1" select="." />
							</xsl:call-template>
						</td>
					</xsl:when>
					<xsl:when test="name(.)='codeSystemVersion'">
						<td>
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'codeSystemVersionShallBeX'" />
								<xsl:with-param name="p1" select="." />
							</xsl:call-template>
						</td>
					</xsl:when>
					<xsl:when test="name(.)='domain'">
						<td>
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'domainIsX'" />
								<xsl:with-param name="p1" select="." />
							</xsl:call-template>
						</td>
					</xsl:when>
					<xsl:when test="name(.)='flexibility'">
						<!-- Skip. Is handled within other when leaves -->
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="logMessage">
							<xsl:with-param name="level" select="$logERROR" />
							<xsl:with-param name="msg">
								<xsl:text>+++ found unknown vocabulary attribute "</xsl:text>
								<xsl:value-of select="name(.)" />
								<xsl:text>=</xsl:text>
								<xsl:value-of select="." />
								<xsl:text>" template id "</xsl:text>
								<xsl:value-of select="ancestor::template/@id" />
								<xsl:text>"</xsl:text>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:if test="count($tdcontent/td)>0">
				<tr valign="top">
					<xsl:copy-of select="$tdcontent" />
				</tr>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="example" mode="templateparticle">
        <!-- 
            show example pretty printed
            if parent is template then different td's are used compared to in-element examples
        -->
        <xsl:variable name="expclass">
            <xsl:choose>
                <xsl:when test="@type='valid'">
                    <!-- a valid example, render it green -->
                    <xsl:text>explabelgreen</xsl:text>
                </xsl:when>
                <xsl:when test="@type='error'">
                    <!-- an invalid example, render it red -->
                    <xsl:text>explabelred</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <!-- normal rendering otherwise -->
                    <xsl:text>explabelblue</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="parent::template">
                <tr class="explabel" valign="top">
                    <td>
                        <xsl:choose>
                            <xsl:when test="@type='error'">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'ExampleInvalid'"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'Example'"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </td>
                    <td class="{$expclass}">
                        <xsl:if test="@caption">
                            <div class="expcaption">
                                <xsl:value-of select="@caption"/>
                            </div>
                        </xsl:if>
                        <tt>
                            <xsl:apply-templates select="./(node()|comment())" mode="explrender"/>
                        </tt>
                    </td>
                </tr>
            </xsl:when>
            <xsl:otherwise>
                <tr class="explabel" valign="top">
                    <td style="background-color: white"> </td>
                    <td>
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'Example'"/>
                        </xsl:call-template>
                    </td>
                    <td class="{$expclass}" colspan="4">
                        <xsl:if test="@caption">
                            <div class="expcaption">
                                <xsl:value-of select="@caption"/>
                            </div>
                        </xsl:if>
                        <tt>
                            <xsl:apply-templates select="./(node()|comment())" mode="explrender"/>
                        </tt>
                    </td>
                </tr>
            </xsl:otherwise>
        </xsl:choose>

        <!-- -->
    </xsl:template>

	<xsl:template name="doIndentLevel">
		<xsl:param name="level" />
		<xsl:for-each select="1 to $level - 1">
			<td valign="top">
				<xsl:call-template name="showIcon">
					<xsl:with-param name="which">
						treeblank
					</xsl:with-param>
				</xsl:call-template>
			</td>
		</xsl:for-each>
		<xsl:if test="$level > 0">
			<td valign="top">
				<xsl:call-template name="showIcon">
					<xsl:with-param name="which">
						treetree
					</xsl:with-param>
				</xsl:call-template>
			</td>
		</xsl:if>
	</xsl:template>

	<xsl:template name="doShowIssues">

		<!-- correction for printing, no extended h3 tag when printing, some more when HTML rendering -->
		<xsl:param name="extendedh3" select="true()" />

		<!-- create a new nodeset with all issues that are not closed and not cancelled wrapped in <open> and all other issues wrapped in <closed> -->
		<xsl:variable name="newnodeset">
			<issues>
				<xsl:for-each select="$allIssues/issue">
					<xsl:variable name="startDate" select="min((tracking|assignment)/xs:dateTime(@effectiveDate))" />
					<xsl:variable name="newestTrackingOrAssignment" select="max((tracking|assignment)/xs:dateTime(@effectiveDate))" />
					<xsl:variable name="currentStatus" select="((tracking|assignment)[@statusCode][@effectiveDate=max(../(tracking|assignment)[@statusCode]/xs:dateTime(@effectiveDate))]/@statusCode)[1]" />
					<xsl:variable name="newestTracking" select="(tracking[@effectiveDate=max(../tracking/xs:dateTime(@effectiveDate))])[1]" />
					<xsl:variable name="newestAssignment" select="(assignment[@effectiveDate=max(../assignment/xs:dateTime(@effectiveDate))])[1]" />
					<xsl:variable name="assignedTo" select="$newestAssignment/@to" />
					<xsl:variable name="assignedName" select="$newestAssignment/@name" />
					<xsl:variable name="elmName">
						<xsl:choose>
							<xsl:when test="$currentStatus = ('closed','cancelled')">
								closed
							</xsl:when>
							<xsl:otherwise>
								open
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:element name="{$elmName}">
						<xsl:attribute name="currentStatus" select="$currentStatus" />
						<xsl:attribute name="startDate" select="$startDate" />
						<xsl:attribute name="newestTrackingOrAssignment" select="$newestTrackingOrAssignment" />
						<xsl:if test="exists($newestTracking)">
							<xsl:attribute name="newestTracking" select="$newestTracking/@effectiveDate" />
						</xsl:if>
						<xsl:if test="exists($newestAssignment)">
							<xsl:attribute name="newestAssignment" select="$newestAssignment/@effectiveDate" />
							<xsl:attribute name="assignedTo" select="$assignedTo" />
							<xsl:attribute name="assignedName" select="$assignedName" />
						</xsl:if>
						<xsl:copy-of select="." />
					</xsl:element>
				</xsl:for-each>
			</issues>
		</xsl:variable>

		<!-- emit issues grouped by assigned vs not assigned (existence of assignment) sorted by assignee (@to) sorted by status code (all trackings) 1 new open 2 inprogress feedback 3 closed rejected deferred 
			cancelled sorted by tracking[1]/@effectiveDate sorted by @displayName -->
		<h2>
			<xsl:call-template name="getMessage">
				<xsl:with-param name="key" select="'issuesAlreadyAssigned'" />
			</xsl:call-template>
		</h2>
		<xsl:for-each-group select="$newnodeset/*/open[@assignedTo]" group-by="@assignedTo">
			<h3>
				<xsl:call-template name="getMessage">
					<xsl:with-param name="key" select="'actuallyAssignedTo'" />
					<xsl:with-param name="p1" select="@assignedTo" />
					<xsl:with-param name="p2" select="@assignedName" />
				</xsl:call-template>
			</h3>
			<xsl:for-each select="current-group()/issue">
				<xsl:sort select="parent::*/@currentStatus" />
				<xsl:sort select="parent::*/@startDate" />
				<xsl:sort select="@displayName" />

				<xsl:apply-templates select=".">
					<xsl:with-param name="extendedh3" select="$extendedh3" />
				</xsl:apply-templates>
			</xsl:for-each>
		</xsl:for-each-group>

		<h2>
			<xsl:call-template name="getMessage">
				<xsl:with-param name="key" select="'issuesNotYetAssigned'" />
			</xsl:call-template>
		</h2>
		<!-- issues with no assignment -->
		<xsl:for-each select="$newnodeset/*/open[not(@assignedTo)]/issue">
			<xsl:sort select="parent::*/@currentStatus" />
			<xsl:sort select="parent::*/@startDate" />
			<xsl:sort select="@displayName" />
			<xsl:apply-templates select=".">
				<xsl:with-param name="extendedh3" select="$extendedh3" />
			</xsl:apply-templates>
		</xsl:for-each>

		<h2>
			<xsl:call-template name="getMessage">
				<xsl:with-param name="key" select="'issuesNotActive'" />
			</xsl:call-template>
		</h2>
		<xsl:for-each select="$newnodeset/*/closed/issue">
			<xsl:sort select="parent::*/@currentStatus" />
			<xsl:sort select="@displayName" />
			<xsl:apply-templates select=".">
				<xsl:with-param name="extendedh3" select="$extendedh3" />
			</xsl:apply-templates>
		</xsl:for-each>

		<xsl:if test="$allIssues/labels/label">
			<h2>
				<xsl:call-template name="getMessage">
					<xsl:with-param name="key" select="'definedLabels'" />
				</xsl:call-template>
			</h2>
			<table width="100%">
				<thead>
					<tr>
						<th>
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'definedColor'" />
							</xsl:call-template>
						</th>
						<th>
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'definedCode'" />
							</xsl:call-template>
						</th>
						<th>
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'definedName'" />
							</xsl:call-template>
						</th>
						<th>
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'Description'" />
							</xsl:call-template>
						</th>
						<th>
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'IsUsed'" />
							</xsl:call-template>
						</th>
					</tr>
				</thead>
				<tbody>
					<xsl:for-each select="$allIssues/labels/label">
						<xsl:sort select="@code" />
						<xsl:apply-templates select="." mode="definition" />
					</xsl:for-each>
				</tbody>
			</table>
		</xsl:if>

		<xsl:if test="$allMissingLabels/wrap/missingCode">
			<h2>
				<xsl:call-template name="getMessage">
					<xsl:with-param name="key" select="'usedButUndefinedLabels'" />
				</xsl:call-template>
			</h2>
			<table width="100%">
				<thead>
					<tr>
						<th>
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'definedCode'" />
							</xsl:call-template>
						</th>
						<th>
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'Issue'" />
							</xsl:call-template>
						</th>
					</tr>
				</thead>
				<tbody>
					<xsl:for-each select="$allMissingLabels/wrap/missingCode">
						<tr>
							<td>
								<xsl:value-of select="@labelCode" />
							</td>
							<td>
								<xsl:text>(</xsl:text>
								<xsl:call-template name="doShorthandId">
									<xsl:with-param name="id" select="@ref" />
								</xsl:call-template>
								<xsl:text>) </xsl:text>
								<xsl:value-of select="@refName" />
							</td>
						</tr>
					</xsl:for-each>
				</tbody>
			</table>
		</xsl:if>

	</xsl:template>

	<xsl:template match="issue">
		<!-- correction for printing, no extended h3 tag when printing new 2014-03-13: don't show issue tracking or assignments with content, only headings and link to live issue in ART. -->
		<xsl:param name="extendedh3" select="true()" />

		<xsl:text>&#10;&#10;</xsl:text>
		<xsl:variable name="newestTracking" select="max(tracking/xs:dateTime(@effectiveDate))" />
		<xsl:variable name="newestAssignment" select="max(assignment/xs:dateTime(@effectiveDate))" />
		<xsl:variable name="newestTrackingOrAssignment" select="max((tracking|assignment)/xs:dateTime(@effectiveDate))" />
		<xsl:variable name="currentStatus" select="((tracking|assignment)[@statusCode][@effectiveDate=max(../(tracking|assignment)[@statusCode]/xs:dateTime(@effectiveDate))]/@statusCode)[1]" />
		<xsl:variable name="issuename">
			<xsl:choose>
				<xsl:when test="string-length(@displayName)>0">
					<xsl:value-of select="@displayName" />
				</xsl:when>
				<xsl:otherwise>
					<span style="color: grey;">
						<xsl:call-template name="getMessage">
							<xsl:with-param name="key" select="'notLabeled'" />
						</xsl:call-template>
					</span>
				</xsl:otherwise>
			</xsl:choose>
			<!-- <xsl:text> (</xsl:text> <xsl:value-of select="@type"/> <xsl:text>)</xsl:text> -->
		</xsl:variable>
		<div class="AccordionPanel">
			<div class="AccordionPanelTab">
				<h3 class="acco" onclick="toggleZoomImg(this,'zoomout','{$theAssetsDir}');">
					<xsl:call-template name="showStatusDot">
						<xsl:with-param name="status" select="(tracking[@effectiveDate=$newestTracking]/@statusCode)[last()]" />
					</xsl:call-template>
					<xsl:text>&#160;(</xsl:text>
					<xsl:call-template name="doShorthandId">
						<xsl:with-param name="id" select="@id" />
					</xsl:call-template>
					<xsl:text>)&#160;</xsl:text>
					<xsl:copy-of select="$issuename" />

					<!-- is this issue already assigned to someone, if so, get the last assignment -->
					<xsl:variable name="assignedTo">
						<xsl:choose>
							<xsl:when test="string-length(assignment[@effectiveDate=$newestAssignment]/@name)>0">
								<xsl:value-of select="assignment[@effectiveDate=$newestAssignment]/@name" />
							</xsl:when>
							<xsl:when test="string-length(assignment[@effectiveDate=$newestAssignment]/@to)>0">
								<xsl:call-template name="getMessage">
									<xsl:with-param name="key" select="'entityNumber'" />
									<xsl:with-param name="p1" select="assignment[@effectiveDate=$newestAssignment]/@to" />
								</xsl:call-template>
							</xsl:when>
						</xsl:choose>
					</xsl:variable>

					<xsl:if test="$extendedh3=true()">
						<table border="0">
							<tr>
								<td class="comment">
									<xsl:call-template name="showIssueType">
										<xsl:with-param name="it" select="@type" />
									</xsl:call-template>
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'issueIdX'" />
										<xsl:with-param name="p1" select="@id" />
									</xsl:call-template>
								</td>
							</tr>
							<tr>
								<td class="comment">
									<xsl:choose>
										<xsl:when test="string-length($assignedTo)=0">
											<xsl:call-template name="getMessage">
												<xsl:with-param name="key" select="'notAssignedYet'" />
											</xsl:call-template>
										</xsl:when>
										<xsl:otherwise>
											<xsl:call-template name="getMessage">
												<xsl:with-param name="key" select="'lastAssignedTo'" />
												<xsl:with-param name="p1" select="$assignedTo" />
											</xsl:call-template>
										</xsl:otherwise>
									</xsl:choose>
								</td>
							</tr>
						</table>
					</xsl:if>

				</h3>
			</div>
			<xsl:text>&#10;&#10;</xsl:text>
			<div class="AccordionPanelContent">

				<table width="100%" border="0" cellspacing="3" cellpadding="2">

					<tr>
						<th style="border:1px solid #C0C0C0; width: 107pt;" align="left">
							<strong>
								<xsl:call-template name="getMessage">
									<xsl:with-param name="key" select="'Issue'" />
								</xsl:call-template>
							</strong>
						</th>
						<td style="background-color: &sandColorLight;" colspan="2">
							<xsl:copy-of select="$issuename" />
						</td>
					</tr>
					<tr valign="top">
						<th align="left">
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'Id'" />
							</xsl:call-template>
						</th>
						<td style="background-color: &sandColorLight;" colspan="2">
							<xsl:call-template name="doShorthandId">
								<xsl:with-param name="id" select="@id" />
							</xsl:call-template>
						</td>
					</tr>
					<tr valign="top">
						<th align="left">
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'Type'" />
							</xsl:call-template>
						</th>
						<td style="background-color: &sandColorLight;" colspan="2">
							<xsl:call-template name="showIssueType">
								<xsl:with-param name="it" select="@type" />
							</xsl:call-template>
						</td>
					</tr>
					<tr valign="top">
						<th align="left">
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'Status'" />
							</xsl:call-template>
						</th>
						<td style="background-color: &sandColorLight;" colspan="2">
							<xsl:call-template name="showStatusDot">
								<xsl:with-param name="status" select="$currentStatus" />
							</xsl:call-template>
							<xsl:text>&#160;</xsl:text>
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="concat('IssueStatusCodeLifeCycle-', $currentStatus)" />
							</xsl:call-template>
							<xsl:if test="count(assignment)>0">
								<xsl:call-template name="getMessage">
									<xsl:with-param name="key" select="'commaAssigned'" />
								</xsl:call-template>
							</xsl:if>
						</td>
					</tr>
					<tr valign="top">
						<th align="left">
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'Priority'" />
							</xsl:call-template>
						</th>
						<td style="background-color: &sandColorLight;" colspan="2">
							<xsl:variable name="iprio" select="tracking[@effectiveDate=$newestTracking]/@priority" />
							<xsl:choose>
								<xsl:when test="$iprio='HH'">
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'highest'" />
									</xsl:call-template>
								</xsl:when>
								<xsl:when test="$iprio='H'">
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'high'" />
									</xsl:call-template>
								</xsl:when>
								<xsl:when test="$iprio='L'">
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'low'" />
									</xsl:call-template>
								</xsl:when>
								<xsl:when test="$iprio='LL'">
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'lowest'" />
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'normal'" />
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
						</td>
					</tr>
					<xsl:if test="((tracking|assignment)[@effectiveDate=$newestTrackingOrAssignment]/@labels)[last()] != ''">
						<tr valign="top">
							<th align="left">
								<xsl:call-template name="getMessage">
									<xsl:with-param name="key" select="'Labels'" />
								</xsl:call-template>
							</th>
							<td style="background-color: &sandColorLight;" colspan="2">
								<xsl:call-template name="showLabels">
									<xsl:with-param name="labels" select="((tracking|assignment)[@effectiveDate=$newestTrackingOrAssignment]/@labels)[last()]" />
								</xsl:call-template>
							</td>
						</tr>
					</xsl:if>
					<xsl:for-each select="object">
						<xsl:variable name="objectId" select="@id" />
						<xsl:variable name="objectDate" select="@effectiveDate" />
						<xsl:variable name="object" select="($allDECOR//*[@id=$objectId][@effectiveDate=$objectDate or string-length($objectDate)=0])[1]" />
						<tr valign="top">
							<th align="left" valign="top">
								<xsl:if test="position()=1">
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'objectsLabel'" />
									</xsl:call-template>
								</xsl:if>
							</th>
							<td style="background-color: &sandColorLight;" colspan="2">
								<xsl:choose>
									<xsl:when test="@type='VS'">
										<xsl:call-template name="getMessage">
											<xsl:with-param name="key" select="'issueOnVS'" />
										</xsl:call-template>
										<xsl:text>&#160;</xsl:text>
										<xsl:call-template name="doShorthandId">
											<xsl:with-param name="id" select="$object/@id" />
										</xsl:call-template>
										<xsl:if test="@effectiveDate">
											<xsl:text>&#160;(</xsl:text>
											<xsl:call-template name="showDate">
												<xsl:with-param name="date" select="@effectiveDate" />
											</xsl:call-template>
											<xsl:text>)</xsl:text>
										</xsl:if>
										<xsl:apply-templates select="$object" />
									</xsl:when>
									<xsl:when test="@type='CS'">
										<xsl:call-template name="getMessage">
											<xsl:with-param name="key" select="'issueOnCS'" />
										</xsl:call-template>
										<xsl:text>&#160;</xsl:text>
										<xsl:call-template name="doShorthandId">
											<xsl:with-param name="id" select="$object/@id" />
										</xsl:call-template>
										<xsl:if test="@effectiveDate">
											<xsl:text>&#160;(</xsl:text>
											<xsl:call-template name="showDate">
												<xsl:with-param name="date" select="@effectiveDate" />
											</xsl:call-template>
											<xsl:text>)</xsl:text>
										</xsl:if>
									</xsl:when>
									<xsl:when test="@type='DE'">
										<xsl:call-template name="getMessage">
											<xsl:with-param name="key" select="'issueOnDE'" />
										</xsl:call-template>
										<xsl:text>&#160;</xsl:text>
										<xsl:call-template name="doShorthandId">
											<xsl:with-param name="id" select="$object/@id" />
										</xsl:call-template>
										<xsl:text>&#160;</xsl:text>
										<xsl:text>"</xsl:text>
										<xsl:call-template name="doName">
											<xsl:with-param name="ns" select="$object/name" />
										</xsl:call-template>
										<xsl:text>"</xsl:text>
										<xsl:call-template name="getMessage">
											<xsl:with-param name="key" select="'fromDatasetLabel'" />
										</xsl:call-template>
										<xsl:text>"</xsl:text>
										<xsl:call-template name="doName">
											<xsl:with-param name="ns" select="$object/ancestor::dataset/name" />
										</xsl:call-template>
										<xsl:text>"</xsl:text>
										<xsl:text>&#160;</xsl:text>
										<xsl:call-template name="showDate">
											<xsl:with-param name="date" select="$object/ancestor::dataset/@effectiveDate" />
										</xsl:call-template>
										<xsl:if test="count($object/ancestor::concept)>0">
											<br />
											<xsl:call-template name="getMessage">
												<xsl:with-param name="key" select="'pathToElement'" />
											</xsl:call-template>
											<xsl:text>: </xsl:text>
											<xsl:for-each select="$object/ancestor::concept">
												<xsl:call-template name="doName">
													<xsl:with-param name="ns" select="name" />
												</xsl:call-template>
												<xsl:if test="position()!=last()">
													<xsl:text> / </xsl:text>
												</xsl:if>
											</xsl:for-each>
										</xsl:if>
										<table width="100%" border="0" cellspacing="10" cellpadding="2">
											<tr valign="top">
												<td class="tabtab">
													<xsl:apply-templates select="$object" mode="dataset">
														<xsl:with-param name="level" select="1" />
													</xsl:apply-templates>
												</td>
											</tr>
										</table>

									</xsl:when>
									<xsl:when test="@type='DS'">
										<xsl:call-template name="getMessage">
											<xsl:with-param name="key" select="'issueOnDS'" />
										</xsl:call-template>
										<xsl:text>&#160;</xsl:text>
										<xsl:call-template name="doName">
											<xsl:with-param name="ns" select="$object/name" />
										</xsl:call-template>
										<xsl:text>&#160;</xsl:text>
										<xsl:call-template name="doShorthandId">
											<xsl:with-param name="id" select="$object/@id" />
										</xsl:call-template>
										<xsl:if test="@effectiveDate">
											<xsl:text>&#160;(</xsl:text>
											<xsl:call-template name="showDate">
												<xsl:with-param name="date" select="@effectiveDate" />
											</xsl:call-template>
											<xsl:text>)</xsl:text>
										</xsl:if>
									</xsl:when>
									<xsl:when test="@type='TM'">
										<xsl:call-template name="getMessage">
											<xsl:with-param name="key" select="'issueOnTM'" />
										</xsl:call-template>
										<xsl:text>&#160;</xsl:text>
										<xsl:value-of select="if ($object/@displayName) then $object/@displayName else ($object/@name)" />
										<xsl:text>&#160;</xsl:text>
										<xsl:call-template name="doShorthandId">
											<xsl:with-param name="id" select="$object/@id" />
										</xsl:call-template>
										<xsl:if test="@effectiveDate">
											<xsl:text>&#160;(</xsl:text>
											<xsl:call-template name="showDate">
												<xsl:with-param name="date" select="@effectiveDate" />
											</xsl:call-template>
											<xsl:text>)</xsl:text>
										</xsl:if>
									</xsl:when>
									<xsl:when test="@type='EL'">
										<xsl:call-template name="getMessage">
											<xsl:with-param name="key" select="'issueOnEL'" />
										</xsl:call-template>
										<xsl:text>&#160;</xsl:text>
										<xsl:if test="exists($object/@name)">
											<xsl:value-of select="$object/@name" />
											<xsl:text>&#160;</xsl:text>
										</xsl:if>
										<xsl:call-template name="doShorthandId">
											<xsl:with-param name="id" select="$object/@id" />
										</xsl:call-template>
										<xsl:if test="@effectiveDate">
											<xsl:text>&#160;(</xsl:text>
											<xsl:call-template name="showDate">
												<xsl:with-param name="date" select="@effectiveDate" />
											</xsl:call-template>
											<xsl:text>)</xsl:text>
										</xsl:if>
									</xsl:when>
									<xsl:when test="@type='SC'">
										<xsl:call-template name="getMessage">
											<xsl:with-param name="key" select="'issueOnSC'" />
										</xsl:call-template>
										<xsl:text>&#160;</xsl:text>
										<xsl:call-template name="doName">
											<xsl:with-param name="ns" select="$object/name" />
										</xsl:call-template>
										<xsl:text>&#160;</xsl:text>
										<xsl:call-template name="doShorthandId">
											<xsl:with-param name="id" select="$object/@id" />
										</xsl:call-template>
										<xsl:if test="@effectiveDate">
											<xsl:text>&#160;(</xsl:text>
											<xsl:call-template name="showDate">
												<xsl:with-param name="date" select="@effectiveDate" />
											</xsl:call-template>
											<xsl:text>)</xsl:text>
										</xsl:if>
									</xsl:when>
									<xsl:when test="@type='IS'">
										<xsl:call-template name="getMessage">
											<xsl:with-param name="key" select="'issueOnIS'" />
										</xsl:call-template>
										<xsl:text>&#160;</xsl:text>
										<xsl:if test="exists($object/@displayName)">
											<xsl:value-of select="$object/@displayName" />
											<xsl:text>&#160;</xsl:text>
										</xsl:if>
										<xsl:call-template name="doShorthandId">
											<xsl:with-param name="id" select="$object/@id" />
										</xsl:call-template>
										<xsl:if test="@effectiveDate">
											<xsl:text>&#160;(</xsl:text>
											<xsl:call-template name="showDate">
												<xsl:with-param name="date" select="@effectiveDate" />
											</xsl:call-template>
											<xsl:text>)</xsl:text>
										</xsl:if>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="@type" />
										<xsl:text>&#160;</xsl:text>
										<xsl:choose>
											<xsl:when test="exists($object/name)">
												<xsl:call-template name="doName">
													<xsl:with-param name="ns" select="$object/name" />
												</xsl:call-template>
												<xsl:text>&#160;</xsl:text>
											</xsl:when>
											<xsl:when test="exists($object/@displayName)">
												<xsl:value-of select="$object/@displayName" />
												<xsl:text>&#160;</xsl:text>
											</xsl:when>
											<xsl:when test="exists($object/@name)">
												<xsl:value-of select="$object/@name" />
												<xsl:text>&#160;</xsl:text>
											</xsl:when>
										</xsl:choose>
										<xsl:call-template name="doShorthandId">
											<xsl:with-param name="id" select="@id" />
										</xsl:call-template>
										<xsl:if test="@effectiveDate">
											<xsl:text>&#160;(</xsl:text>
											<xsl:call-template name="showDate">
												<xsl:with-param name="date" select="@effectiveDate" />
											</xsl:call-template>
											<xsl:text>)</xsl:text>
										</xsl:if>
									</xsl:otherwise>
								</xsl:choose>
							</td>
						</tr>
					</xsl:for-each>
					<!-- new 2014-03-13: don't show tracking|assignment with content, only live link to ART -->
					<xsl:for-each select="tracking-notused|assignment-notused">
						<xsl:sort select="xs:dateTime(@effectiveDate)" order="descending" />
						<xsl:choose>
							<xsl:when test="name()='tracking'">
								<tr valign="top">
									<th width="137px" align="center">
										<xsl:call-template name="showIcon">
											<xsl:with-param name="which">
												tracking
											</xsl:with-param>
										</xsl:call-template>
									</th>
									<th align="left" colspan="2">
										<xsl:call-template name="showStatusDot">
											<xsl:with-param name="status" select="@statusCode" />
										</xsl:call-template>
										<xsl:call-template name="getMessage">
											<xsl:with-param name="key" select="'trackingStatus'" />
											<xsl:with-param name="p1">
												<xsl:call-template name="showDate">
													<xsl:with-param name="date" select="@effectiveDate" />
												</xsl:call-template>
											</xsl:with-param>
											<xsl:with-param name="p2">
												<xsl:call-template name="getMessage">
													<xsl:with-param name="key" select="concat('IssueStatusCodeLifeCycle-',@statusCode)" />
												</xsl:call-template>
											</xsl:with-param>
										</xsl:call-template>
									</th>
								</tr>
								<tr valign="top">
									<td>&#160;</td>
									<th width="107px" align="left">
										<xsl:call-template name="getMessage">
											<xsl:with-param name="key" select="'authorLabel'" />
										</xsl:call-template>
									</th>
									<td style="background-color: &sandColorLight;">
										<xsl:value-of select="author/text()" />
									</td>
								</tr>
								<xsl:if test="@labels">
									<tr valign="top">
										<td>
										</td>
										<th width="107px" align="left">
											<xsl:call-template name="getMessage">
												<xsl:with-param name="key" select="'Labels'" />
											</xsl:call-template>
										</th>
										<td style="background-color: &sandColorLight;">
											<xsl:call-template name="showLabels">
												<xsl:with-param name="labels" select="@labels" />
											</xsl:call-template>
										</td>
									</tr>
								</xsl:if>
								<xsl:if test="desc">
									<tr valign="top">
										<td>
										</td>
										<th valign="top" width="107px" align="left">
											<xsl:call-template name="getMessage">
												<xsl:with-param name="key" select="'Description'" />
											</xsl:call-template>
										</th>
										<td class="descitem">
											<xsl:choose>
												<xsl:when test="@statusCode='new'">
													<span style="color: grey;">
														<xsl:call-template name="doDescription">
															<xsl:with-param name="ns" select="desc" />
														</xsl:call-template>
													</span>
												</xsl:when>
												<xsl:otherwise>
													<xsl:call-template name="doDescription">
														<xsl:with-param name="ns" select="desc" />
													</xsl:call-template>
												</xsl:otherwise>
											</xsl:choose>
										</td>
									</tr>
								</xsl:if>
							</xsl:when>
							<xsl:when test="name()='assignment'">
								<!-- <assignment to="6" effectiveDate="2011-12-11T00:00:00">Redactieraad perinatologie <author id="1">Kai Heitmann</author> <desc language="nl-NL">Op welke manier wordt deze value set uitgebreid?</desc> 
									</assignment> -->
								<tr valign="top">
									<th width="137px" align="center">
										<xsl:call-template name="showIcon">
											<xsl:with-param name="which">
												arrowright
											</xsl:with-param>
										</xsl:call-template>
									</th>
									<th colspan="2" bgcolor="&sandColorLight;">
										<xsl:call-template name="getMessage">
											<xsl:with-param name="key" select="'assignedToEntity'" />
											<xsl:with-param name="p1" select="@name" />
											<xsl:with-param name="p2" select="@to" />
										</xsl:call-template>
										<xsl:call-template name="getMessage">
											<xsl:with-param name="key" select="'onDate'" />
											<xsl:with-param name="p1">
												<xsl:call-template name="showDate">
													<xsl:with-param name="date" select="@effectiveDate" />
												</xsl:call-template>
											</xsl:with-param>
										</xsl:call-template>
									</th>
								</tr>
								<tr valign="top">
									<td>&#160;</td>
									<th width="107px">
										<xsl:call-template name="getMessage">
											<xsl:with-param name="key" select="'authorLabel'" />
										</xsl:call-template>
									</th>
									<td style="background-color: &sandColorLight;">
										<xsl:call-template name="getMessage">
											<xsl:with-param name="key" select="'assignedByEntity'" />
											<xsl:with-param name="p1" select="author/text()" />
											<xsl:with-param name="p2" select="author/@id" />
										</xsl:call-template>
									</td>
								</tr>
								<xsl:if test="@labels">
									<tr valign="top">
										<td>&#160;</td>
										<th width="107px" align="left">
											<xsl:call-template name="getMessage">
												<xsl:with-param name="key" select="'Labels'" />
											</xsl:call-template>
										</th>
										<td style="background-color: &sandColorLight;">
											<xsl:call-template name="showLabels">
												<xsl:with-param name="labels" select="@labels" />
											</xsl:call-template>
										</td>
									</tr>
								</xsl:if>
								<xsl:if test="string-length(normalize-space(desc))>0">
									<tr valign="top">
										<td>&#160;</td>
										<th valign="top" width="107px">
											<xsl:call-template name="getMessage">
												<xsl:with-param name="key" select="'Description'" />
											</xsl:call-template>
										</th>
										<td class="descitem">
											<xsl:choose>
												<xsl:when test="@statusCode='new'">
													<span style="color: grey;">
														<xsl:call-template name="doDescription">
															<xsl:with-param name="ns" select="desc" />
														</xsl:call-template>
													</span>
												</xsl:when>
												<xsl:otherwise>
													<xsl:call-template name="doDescription">
														<xsl:with-param name="ns" select="desc" />
													</xsl:call-template>
												</xsl:otherwise>
											</xsl:choose>
										</td>
									</tr>
								</xsl:if>
							</xsl:when>
						</xsl:choose>
					</xsl:for-each>

					<xsl:if test="string-length($artdecordeeplinkprefix)>0">
						<tr valign="top">
							<th align="left" valign="top">
								<xsl:call-template name="getMessage">
									<xsl:with-param name="key" select="'Link'" />
								</xsl:call-template>
							</th>
							<td style="background-color: &sandColorLight;" colspan="2">
								<a href="{$artdecordeeplinkprefix}decor-issues--{$projectPrefix}?issueId={@id}&amp;serclosed=true&amp;language={$defaultLanguage}">
									<xsl:call-template name="showIcon">
										<xsl:with-param name="which">
											arrowright
										</xsl:with-param>
									</xsl:call-template>
								</a>
							</td>
						</tr>
					</xsl:if>


					<!-- Email link -->
					<xsl:if test="string-length($projectContactEmail)>0">
						<tr valign="middle">
							<td>
								<xsl:call-template name="showIcon">
									<xsl:with-param name="which">
										flag
									</xsl:with-param>
								</xsl:call-template>
							</td>
							<td colspan="2">
								<i>
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'notTheInteractiveVersion-1'" />
									</xsl:call-template>
									<a>
										<xsl:attribute name="href">
                                            <!-- email address -->
                                            <xsl:text>mailto:</xsl:text>
                                            <xsl:value-of select="$projectContactEmail" />
                                            <!-- subject -->
                                            <xsl:text>?subject=</xsl:text>
                                            <xsl:variable name="subj">
                                                <xsl:text>New comment on issue #</xsl:text>
                                                <xsl:value-of select="@id" />
                                                <xsl:text>&#160;</xsl:text>
                                                <xsl:value-of select="$issuename" disable-output-escaping="yes" />
                                                <xsl:text> (Project: </xsl:text>
                                                <xsl:value-of select="$projectName" disable-output-escaping="yes" />
                                                <xsl:text>)</xsl:text>
                                            </xsl:variable>
                                            <xsl:value-of select="$subj" disable-output-escaping="yes" />
                                        </xsl:attribute>
										<xsl:text>email  </xsl:text>
										<xsl:call-template name="showIcon">
											<xsl:with-param name="which">
												mail
											</xsl:with-param>
										</xsl:call-template>
									</a>
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'notTheInteractiveVersion-2'" />
									</xsl:call-template>
								</i>
							</td>
						</tr>
					</xsl:if>
				</table>
			</div>
		</div>
	</xsl:template>

	<xsl:template name="showLabels">
		<xsl:param name="labels" />

		<xsl:if test="$labels != ''">
			<xsl:for-each select="tokenize($labels,' ')">
				<xsl:variable name="labelCode" select="." />
				<xsl:variable name="labelName">
					<xsl:choose>
						<xsl:when test="$allIssues/labels/label[@code=$labelCode]">
							<xsl:value-of select="$allIssues/labels/label[@code=$labelCode]/@name" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$labelCode" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="labelColor">
					<xsl:choose>
						<xsl:when test="$allIssues/labels/label[@code=$labelCode]">
							<xsl:value-of select="$allIssues/labels/label[@code=$labelCode]/@color" />
						</xsl:when>
						<xsl:otherwise>
							<!-- default color is white. Could read the DECOR.xsd schema for this to be configurable -->
							<xsl:value-of select="'white'" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<div class="issuelabel-outer" title="{$labelName}">
					<div class="issuelabel-color" style="background-color: {$labelColor}">&#160;</div>
					<div class="issuelabel-text">
						<xsl:value-of select="concat('&#160;(',$labelCode,')&#160;',$labelName,'&#160;')" />
					</div>
				</div>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>

	<xsl:template match="label" mode="definition">
		<!-- correction for printing, no extended h3 tag when printing -->
		<xsl:param name="extendedh3" select="true()" />

		<xsl:variable name="labelCode" select="@code" />
		<xsl:variable name="isUsed" select="exists(ancestor::issues[last()]//(tracking|assignment)[count(index-of(tokenize(@labels,' '),$labelCode))&gt;=1])" />
		<tr>
			<td>
				<a name="labelCode{@code}" />
				<div class="issuelabel-color" style="background-color: {@color}">&#160;</div>
				<div class="issuelabel-text">
					<xsl:value-of select="@color" />
				</div>
			</td>
			<td>
				<xsl:value-of select="@code" />
			</td>
			<td>
				<xsl:value-of select="@name" />
			</td>
			<td>
				<xsl:call-template name="doDescription">
					<xsl:with-param name="ns" select="desc" />
				</xsl:call-template>
			</td>
			<td>
				<xsl:choose>
					<xsl:when test="$isUsed">
						<xsl:call-template name="getMessage">
							<xsl:with-param name="key" select="'yes'" />
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="getMessage">
							<xsl:with-param name="key" select="'no'" />
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</td>
		</tr>

	</xsl:template>

	<xsl:template match="assert|report|defineVariable|let" mode="templateparticle">
		<xsl:choose>
			<xsl:when test="name()='defineVariable'">
				<tr valign="top">
					<td style="background-color: white">
					</td>
					<td class="defvar" rowspan="2">
						<xsl:call-template name="getMessage">
							<xsl:with-param name="key" select="'Variable'" />
						</xsl:call-template>
					</td>
					<td style="background-color: #FFEEEE">
						<xsl:call-template name="getMessage">
							<xsl:with-param name="key" select="'name'" />
						</xsl:call-template>
					</td>
					<td colspan="3">
						<xsl:value-of select="@name" />
					</td>
				</tr>
				<xsl:if test="string-length(@path)>0">
					<tr valign="top">
						<td style="background-color: white">
						</td>
						<td>
						</td>
						<td style="background-color: #FFEEEE">
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'contextPath'" />
							</xsl:call-template>
						</td>
						<td colspan="3">
							<xsl:value-of select="@path" />
						</td>
					</tr>
				</xsl:if>
				<xsl:if test="string-length(code/@code)>0 or string-length(code/@codeSystem)>0">
					<tr valign="top">
						<td style="background-color: white">
						</td>
						<td>
						</td>
						<td style="background-color: #FFEEEE">
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'code'" />
							</xsl:call-template>
						</td>
						<td colspan="3">
							<xsl:if test="code/@code">
								<xsl:call-template name="getMessage">
									<xsl:with-param name="key" select="'code'" />
								</xsl:call-template>
								<xsl:value-of select="code/@code" />
							</xsl:if>
							<xsl:if test="code/@codeSystem">
								<xsl:call-template name="getMessage">
									<xsl:with-param name="key" select="'codeSystem'" />
								</xsl:call-template>
								<xsl:value-of select="code/@codeSystem" />
							</xsl:if>
						</td>
					</tr>
				</xsl:if>
				<xsl:if test="count(use)>0">
					<tr valign="top">
						<td style="background-color: white">
						</td>
						<td>
						</td>
						<td style="background-color: #FFEEEE">
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'use'" />
							</xsl:call-template>
						</td>
						<td colspan="3">
							<xsl:value-of select="use/@path" />
							<xsl:if test="use/@as">
								<xsl:call-template name="getMessage">
									<xsl:with-param name="key" select="'as'" />
								</xsl:call-template>
								<xsl:value-of select="use/@as" />
							</xsl:if>
						</td>
					</tr>
				</xsl:if>
			</xsl:when>
			<xsl:when test="name()='assert' or name()='report'">

				<xsl:variable name="rowspans" select="count(@flag|@see)+3" />

				<tr valign="top">
					<td style="background-color: white">
					</td>
					<td class="stron" rowspan="{$rowspans}">
						<xsl:call-template name="getMessage">
							<xsl:with-param name="key" select="'Schematron'" />
						</xsl:call-template>
						<xsl:text>&#160;</xsl:text>
						<xsl:value-of select="name()" />
					</td>
					<td style="background-color: #FFEEEE">
						<xsl:call-template name="getMessage">
							<xsl:with-param name="key" select="'roleLabel'" />
						</xsl:call-template>
					</td>
					<td colspan="2">
						<xsl:choose>
							<xsl:when test="@role='error'">
								<xsl:call-template name="showIcon">
									<xsl:with-param name="which">
										red
									</xsl:with-param>
								</xsl:call-template>
							</xsl:when>
							<xsl:when test="@role='warning'">
								<xsl:call-template name="showIcon">
									<xsl:with-param name="which">
										orange
									</xsl:with-param>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="showIcon">
									<xsl:with-param name="which">
										yellow
									</xsl:with-param>
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:text>&#160;</xsl:text>
						<xsl:value-of select="@role" />
					</td>
				</tr>

				<xsl:if test="@flag">
					<tr>
						<td style="background-color: white">
						</td>
						<td style="background-color: #FFEEEE">
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'flagLabel'" />
							</xsl:call-template>
						</td>
						<td colspan="2">
							<xsl:value-of select="@flag" />
						</td>
					</tr>
				</xsl:if>

				<!--xsl:if test="@role"> <tr> <td bgcolor="white"> </td> <td bgcolor="#FFEEEE"> <xsl:call-template name="getMessage"> <xsl:with-param name="key" select="'roleLabel'"/> </xsl:call-template> </td> <td 
					colspan="2"> <xsl:choose> <xsl:when test="@role='error'"> <xsl:call-template name="showIcon"> <xsl:with-param name="which">red</xsl:with-param> </xsl:call-template> </xsl:when> <xsl:when test="@role='warning'"> 
					<xsl:call-template name="showIcon"> <xsl:with-param name="which">orange</xsl:with-param> </xsl:call-template> </xsl:when> <xsl:otherwise> <xsl:call-template name="showIcon"> <xsl:with-param name="which">yellow</xsl:with-param> 
					</xsl:call-template> </xsl:otherwise> </xsl:choose> <xsl:text>&#160;</xsl:text> <xsl:value-of select="@role"/> </td> </tr> </xsl:if -->
				<xsl:if test="@see">
					<tr>
						<td style="background-color: white">
						</td>
						<td style="background-color: #FFEEEE">
							<xsl:call-template name="getMessage">
								<xsl:with-param name="key" select="'seeLabel'" />
							</xsl:call-template>
						</td>
						<td colspan="2">
							<xsl:value-of select="@see" />
						</td>
					</tr>
				</xsl:if>
				<tr valign="top">
					<td style="background-color: white">
					</td>
					<td style="background-color: #FFEEEE">
						<xsl:call-template name="getMessage">
							<xsl:with-param name="key" select="'Test'" />
						</xsl:call-template>
					</td>
					<td colspan="2">
						<xsl:value-of select="@test" />
						<!--xsl:call-template name="splitString"> <xsl:with-param name="str" select="@test"/> <xsl:with-param name="del"> <xsl:choose> <xsl:when test="string-length(@test)>80"> <xsl:text>&#160;</xsl:text> 
							</xsl:when> <xsl:otherwise> <xsl:text>&#x9;</xsl:text> </xsl:otherwise> </xsl:choose> </xsl:with-param> <xsl:with-param name="preceedIndent" select="''"/> </xsl:call-template -->
					</td>
				</tr>
				<tr valign="top">
					<td style="background-color: white">
					</td>
					<td style="background-color: #FFEEEE">
						<xsl:call-template name="getMessage">
							<xsl:with-param name="key" select="'Message'" />
						</xsl:call-template>
					</td>
					<td colspan="2">
						<xsl:for-each select="text()|*">
							<xsl:choose>
								<xsl:when test="string-length(.)>0">
									<!--div -->
									<span class="pptext">
										<xsl:value-of select="." />
									</span>
									<!--/div -->
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="doPrettyPrintInternal">
										<xsl:with-param name="newlines" select="'false'" />
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</td>
				</tr>
			</xsl:when>
			<xsl:when test="name()='let'">
				<xsl:variable name="rowspans" select="count(@*)" />

				<tr valign="top">
					<td style="background-color: white">
					</td>
					<td class="defvar" rowspan="{$rowspans}">
						<xsl:call-template name="getMessage">
							<xsl:with-param name="key" select="'Variable'" />
						</xsl:call-template>
						<xsl:text>&#160;</xsl:text>
						<xsl:value-of select="name()" />
					</td>
					<td style="background-color: #FFEEEE">
						<xsl:call-template name="getMessage">
							<xsl:with-param name="key" select="'nameLabel'" />
						</xsl:call-template>
					</td>
					<td colspan="2">
						<xsl:value-of select="@name" />
					</td>
				</tr>
				<tr valign="top">
					<td style="background-color: white">
					</td>
					<td style="background-color: #FFEEEE">
						<xsl:call-template name="getMessage">
							<xsl:with-param name="key" select="'valueLabel'" />
						</xsl:call-template>
					</td>
					<td colspan="2">
						<xsl:value-of select="@value" />
					</td>
				</tr>
				<xsl:for-each select="@* except (@name|@value)">
					<tr valign="top">
						<td style="background-color: #FFEEEE">
							<xsl:value-of select="name(.)" />
						</td>
						<td colspan="2">
							<xsl:value-of select="." />
						</td>
					</tr>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="logMessage">
					<xsl:with-param name="level" select="$logERROR" />
					<xsl:with-param name="msg">
						<xsl:text>+++ found unhandled element in definition "</xsl:text>
						<xsl:value-of select="name()" />
						<xsl:text>" template id "</xsl:text>
						<xsl:value-of select="ancestor::template/@id" />
						<xsl:text>"</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="concept|exception" mode="valueset">
		<xsl:param name="language" />

		<xsl:variable name="theCode" select="@code" />
		<xsl:variable name="theCS" select="@codeSystem" />
		<xsl:variable name="theName">
			<xsl:call-template name="getIDDisplayName">
				<xsl:with-param name="root" select="$theCS" />
			</xsl:call-template>
		</xsl:variable>

		<tr>
			<td valign="top">
				<xsl:choose>
					<xsl:when test="self::concept">
						<!-- level/type -->
						<xsl:value-of select="@level" />
						<xsl:text>-</xsl:text>
						<xsl:choose>
							<xsl:when test="@type='L'">
								L
							</xsl:when>
							<xsl:when test="@type='A'">
								A
							</xsl:when>
							<xsl:when test="@type='S'">
								S
							</xsl:when>
							<xsl:when test="@type='D'">
								D
							</xsl:when>
							<xsl:otherwise>
								(?)
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>&#160;</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td valign="top">
				<xsl:choose>
					<xsl:when test="self::concept">
						<!-- code -->
						<xsl:call-template name="repeatString">
							<xsl:with-param name="number">
								<xsl:choose>
									<xsl:when test="@level">
										<xsl:value-of select="@level" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="0" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
							<xsl:with-param name="theString" select="'&#160;'" />
						</xsl:call-template>
						<xsl:choose>
							<xsl:when test="@type='A' or @type='D'">
								<!-- abstract and deprecated codes in normalface grey -->
								<span style="color: grey;">
									<i>
										<xsl:value-of select="$theCode" />
									</i>
								</span>
							</xsl:when>
							<xsl:otherwise>
								<!-- all other codes in boldface -->
								<strong>
									<xsl:value-of select="$theCode" />
								</strong>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="self::exception">
						<!-- exceptions = null flavors in boldface grey -->
						<span style="color: grey;">
							<i>
								<strong>
									<xsl:value-of select="@code" />
								</strong>
							</i>
						</span>
					</xsl:when>
				</xsl:choose>
			</td>
			<td valign="top">
				<xsl:choose>
					<xsl:when test="self::concept">
						<!-- display name as defined in the value set -->
						<xsl:value-of select="@displayName" />
					</xsl:when>
					<xsl:when test="self::exception">
						<!-- exceptions = null flavors in boldface grey -->
						<span style="color: grey;">
							<i>
								<strong>
									<xsl:choose>
										<xsl:when test="string-length(@displayName)>0">
											<xsl:value-of select="@displayName" />
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="@code" />
										</xsl:otherwise>
									</xsl:choose>
								</strong>
							</i>
						</span>
					</xsl:when>
				</xsl:choose>
			</td>
			<td valign="top">
				<!-- code system -->
				<xsl:choose>
					<xsl:when test="string-length($theName)>0">
						<xsl:value-of select="$theName" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$theCS" />
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<xsl:if test="../*[@codeSystemVersion]">
				<td>
					<xsl:value-of select="@codeSystemVersion" />
				</td>
			</xsl:if>
			<td valign="top">
				<xsl:choose>
					<xsl:when test=".[desc]">
						<xsl:call-template name="doDescription">
							<xsl:with-param name="ns" select="desc[@language=$language or not(@language)][1]" />
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="doDescription">
							<xsl:with-param name="ns" select="($allCodedConcepts/codedConcept[@code=$theCode][@codeSystem=$theCS]/designation[@language=$language])[1]" />
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</td>
		</tr>

	</xsl:template>

	<xsl:template match="concept" mode="deinherit">

		<xsl:variable name="dsref" select="inherit/@ref" />
		<xsl:variable name="dsed" select="inherit/@effectiveDate" />
		<xsl:variable name="dsrefconcept" select="$allDatasets//concept[@id=$dsref][string-length($dsed)=0 or @effectiveDate=$dsed][not(ancestor::history)][not(parent::conceptList)]" />

		<!-- get the node of this referenced concept inherit/@ref and @effectiveDate determines concept node create a new concept node - with all attributes of the original node - with @ref and @effectiveDate 
			of the inherit element as attributed inheritedId and inheritedEffectiveDate - copy all elements of the referenced (inherited) node - copy comments and sub concepts from the original node definition (these 
			are the only allowed node in a referencing concept) -->
		<!-- original node @id, @effectiveDate, @minimumMultiplicity, @maximumMultiplicity, @isMandatory, @conformance, comments and sub concepts -->
		<xsl:variable name="origid">
			<xsl:value-of select="@id" />
		</xsl:variable>
		<xsl:variable name="origed">
			<xsl:value-of select="@effectiveDate" />
		</xsl:variable>
		<xsl:variable name="origsc">
			<xsl:value-of select="@statusCode" />
		</xsl:variable>
		<xsl:variable name="origmi">
			<xsl:value-of select="@minimumMultiplicity" />
		</xsl:variable>
		<xsl:variable name="origmx">
			<xsl:value-of select="@maximumMultiplicity" />
		</xsl:variable>
		<xsl:variable name="origma">
			<xsl:value-of select="@isMandatory" />
		</xsl:variable>
		<xsl:variable name="origcf">
			<xsl:value-of select="@conformance" />
		</xsl:variable>
		<xsl:variable name="origcomments">
			<xsl:copy-of select="comment" />
		</xsl:variable>
		<xsl:variable name="origconcepts">
			<xsl:copy-of select="concept" />
		</xsl:variable>
		<concept>
			<!-- copy ref and effectiveDate of the inherit data element as attributes but use the name inheritedId and inheritedEffectiveDate -->
			<xsl:attribute name="id" select="$origid" />
			<xsl:attribute name="effectiveDate" select="$origed" />
			<xsl:if test="string-length($origsc)>0">
				<!-- original statuscode, override inherited one -->
				<xsl:attribute name="statusCode" select="$origsc" />
			</xsl:if>
			<xsl:attribute name="minimumMultiplicity" select="$origmi" />
			<xsl:attribute name="maximumMultiplicity" select="$origmx" />
			<xsl:attribute name="isMandatory" select="$origma" />
			<xsl:attribute name="conformance" select="$origcf" />
			<xsl:attribute name="inheritedId" select="$dsref" />
			<xsl:attribute name="inheritedEffectiveDate" select="$dsed" />
			<xsl:choose>
				<xsl:when test="exists($dsrefconcept)">
					<!-- it is an error if more than one concept has the same id and effective time -->
					<xsl:if test="count($dsrefconcept)>1">
						<xsl:call-template name="logMessage">
							<xsl:with-param name="level" select="$logFATAL" />
							<xsl:with-param name="terminate" select="true()" />
							<xsl:with-param name="msg">
								<xsl:text>!!! more than 1 concept with same id and effectiveDate found: </xsl:text>
								<xsl:value-of select="$dsref" />
								<xsl:text>&#160;</xsl:text>
								<xsl:value-of select="$dsed" />
							</xsl:with-param>
						</xsl:call-template>
					</xsl:if>
					<xsl:for-each select="$dsrefconcept[1]">
						<xsl:copy-of select="@* except(@id|@effectiveDate|@statusCode)" />
						<xsl:if test="string-length($origsc)=0">
							<xsl:copy-of select="@statusCode" />
						</xsl:if>
						<xsl:copy-of select="name|desc|source|rationale|inherit" />
						<xsl:copy-of select="comment" />
						<xsl:copy-of select="$origcomments" />
						<xsl:copy-of select="operationalization|valueDomain" />
						<xsl:copy-of select="$origconcepts" />
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="./node() except inherit" />
				</xsl:otherwise>
			</xsl:choose>
		</concept>
	</xsl:template>

	<xsl:template match="concept" mode="dataset">
		<xsl:param name="level" />
		<xsl:param name="nestingWithTables" select="true()" />

		<!-- show concept properties for concepts with an id directly for concept with an inherited concept do copying of properties of the referenced conept first and then show it -->

		<xsl:choose>

			<!-- Compilation already resolves inherit info. Check if this is the case by checking whether or we already have a name. The concept will not have a name in a normal inherit situation. -->
			<xsl:when test="inherit/@ref[string-length()>0] and not(name)">

				<xsl:variable name="dsref" select="inherit/@ref" />
				<xsl:variable name="dsed" select="inherit/@effectiveDate" />

				<xsl:variable name="theconcept">
					<xsl:apply-templates select="." mode="deinherit" />
				</xsl:variable>

				<xsl:choose>
					<xsl:when test="string-length($theconcept/concept/@id)=0">
						<!-- no nodes - this is an error -->

						<table width="100%" border="0" cellspacing="3" cellpadding="2">
							<tr>
								<!-- show error in concept node -->
								<td class="nodetype" align="center">
									<xsl:call-template name="showStatusDot">
										<xsl:with-param name="status" select="error" />
									</xsl:call-template>
									<xsl:text>&#160;</xsl:text>
								</td>
								<!-- show the error message -->
								<td valign="middle" colspan="2" class="nodename tabtab">
									<table border="0">
										<xsl:call-template name="doMessage">
											<xsl:with-param name="level" select="'error'" />
											<xsl:with-param name="msg">
												<xsl:choose>
													<xsl:when test="string-length($dsed)&gt;0">
														<xsl:call-template name="getMessage">
															<xsl:with-param name="key" select="'theReferencedConceptAsOfCannotBeFound'" />
															<xsl:with-param name="p1" select="$dsref" />
															<xsl:with-param name="p2" select="$dsed" />
														</xsl:call-template>
													</xsl:when>
													<xsl:otherwise>
														<xsl:call-template name="getMessage">
															<xsl:with-param name="key" select="'theReferencedConceptCannotBeFound'" />
															<xsl:with-param name="p1" select="$dsref" />
														</xsl:call-template>
													</xsl:otherwise>
												</xsl:choose>
											</xsl:with-param>
										</xsl:call-template>
									</table>
								</td>
							</tr>
						</table>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="$theconcept/*" mode="dataset">
							<xsl:with-param name="level" select="$level" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>

			</xsl:when>

			<!-- this is a concept with an id, show it -->
			<xsl:when test="string-length(@id)>0">

				<xsl:variable name="conceptId" select="@id" />
				<xsl:variable name="conceptEffectiveDate" select="@effectiveDate" />

				<!-- prepare toggling -->
				<xsl:variable name="elid" select="local:randomString2(generate-id())" />
				<xsl:variable name="elidtoggler" select="concat('toggler-', $elid)" />

				<xsl:if test="$nestingWithTables=false()">
					<!-- no table nesting but html <Hx>, build it -->
					<xsl:variable name="hlevel">
						<xsl:choose>
							<xsl:when test="$level + 2 > 8">
								<!-- no deeper nesting than <h8> -->
								<xsl:value-of select="'h8'" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat('h', $level+2)" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:element name="{$hlevel}">
						<xsl:value-of select="name[1]" />
					</xsl:element>
				</xsl:if>

				<a>
					<xsl:attribute name="name">
                        <xsl:call-template name="getAnchorName">
                            <xsl:with-param name="id" select="$conceptId" />
                            <xsl:with-param name="effectiveDate" select="$conceptEffectiveDate" />
                        </xsl:call-template>
                    </xsl:attribute>
				</a>
				<table width="100%" border="0" cellspacing="3" cellpadding="2">

					<xsl:if test="@statusCode='deprecated' or @statusCode='cancelled'">
						<!-- if concept is deprecated, cancelled... make strips in the background -->
						<xsl:attribute name="class" select="'bgstrips'" />
					</xsl:if>

					<xsl:if test="not(@hidden)">

						<!-- header -->
						<tr>
							<!-- show type of concept node -->
							<!-- toogle: -->
							<td id="{$elidtoggler}" class="toggler nodetype" onclick="return toggleZoom('{$elid}','{$elidtoggler}', '{$theAssetsDir}')" align="right">
								<!-- <td class="nodetype" align="center"> -->
								<xsl:choose>
									<xsl:when test="@type='group'">
										<xsl:call-template name="showIcon">
											<xsl:with-param name="which">
												folder
											</xsl:with-param>
										</xsl:call-template>
										<xsl:text>&#160;</xsl:text>
										<xsl:call-template name="showStatusDot">
											<xsl:with-param name="status" select="@statusCode" />
										</xsl:call-template>
									</xsl:when>
									<xsl:when test="@type='item'">
										<xsl:call-template name="showStatusDot">
											<xsl:with-param name="status" select="@statusCode" />
										</xsl:call-template>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="@type" />
									</xsl:otherwise>
								</xsl:choose>
							</td>
							<!-- show the concept -->
							<td valign="middle" class="nodename tabtab">
								<!-- EXCEPTION: IF name STARTS WITH "(" OR statusCode=deprecated THEN SHOW NAME IN GREY ONLY (it is an internal item not to be shown in a dataset at all) -->
								<xsl:choose>
									<xsl:when test="substring(name[1],1,1)='('">
										<span style="color: grey;">
											<xsl:call-template name="doName">
												<xsl:with-param name="ns" select="name" />
											</xsl:call-template>
										</span>
									</xsl:when>
									<xsl:when test="@conformance='NP'">
										<strike>
											<xsl:call-template name="doName">
												<xsl:with-param name="ns" select="name" />
											</xsl:call-template>
										</strike>
									</xsl:when>
									<xsl:otherwise>
										<xsl:call-template name="doName">
											<xsl:with-param name="ns" select="name" />
										</xsl:call-template>
									</xsl:otherwise>
								</xsl:choose>


								<xsl:if test="string-length($projectContactEmail)>0">
									<!-- vooralsnog: email om issue in te dienen -->
									<xsl:variable name="tooltiptext">
										<xsl:call-template name="getMessage">
											<xsl:with-param name="key" select="'tooltiptext'" />
										</xsl:call-template>
									</xsl:variable>
									<xsl:call-template name="repeatString">
										<xsl:with-param name="number" select="7" />
										<xsl:with-param name="theString" select="'&#160;'" />
									</xsl:call-template>
									<a>
										<xsl:attribute name="href">
                                            <!-- email address -->
                                            <xsl:text>mailto:</xsl:text>
                                            <xsl:value-of select="$projectContactEmail" />
                                            <!-- subject -->
                                            <xsl:text>?subject=</xsl:text>
                                            <xsl:variable name="subj">
                                                <xsl:text>New issue on data element #</xsl:text>
                                                <xsl:value-of select="$conceptId" />
                                                <xsl:text>&#160;</xsl:text>
                                                <xsl:value-of select="name[1]" disable-output-escaping="yes" />
                                                <xsl:text> (Project: </xsl:text>
                                                <xsl:value-of select="$projectName" disable-output-escaping="yes" />
                                                <xsl:text>)</xsl:text>
                                            </xsl:variable>
                                            <xsl:value-of select="$subj" disable-output-escaping="yes" />
                                        </xsl:attribute>
										<xsl:call-template name="showIcon">
											<xsl:with-param name="which">
												flag16
											</xsl:with-param>
											<xsl:with-param name="tooltip" select="$tooltiptext" />
										</xsl:call-template>
									</a>
								</xsl:if>


							</td>
						</tr>

						<tr>
							<td colspan="2">
								<div id="{$elid}" class="toggle">
									<table width="100%" border="0" cellspacing="1" cellpadding="6">
										<tr>
											<td class="nodeproperty" valign="top">
												<xsl:call-template name="getMessage">
													<xsl:with-param name="key" select="'Id'" />
												</xsl:call-template>
											</td>
											<td colspan="2">
												<strong>
													<xsl:call-template name="doShorthandId">
														<xsl:with-param name="id" select="$conceptId" />
													</xsl:call-template>
												</strong>
												<xsl:if test="$conceptEffectiveDate">
													<xsl:text> (</xsl:text>
													<xsl:call-template name="showDate">
														<xsl:with-param name="date" select="$conceptEffectiveDate" />
													</xsl:call-template>
													<xsl:text>)</xsl:text>
												</xsl:if>
											</td>
										</tr>

										<!-- show cardinality conformance if present (only for scenario transaction dataset compilations) -->
										<xsl:if test="string-length(concat(@minimumMultiplicity, @maximumMultiplicity, @isMandatory, @conformance))>0 or count(conditionalConcept)>0">
											<tr>
												<td class="nodeproperty" valign="top">
													<xsl:call-template name="getMessage">
														<xsl:with-param name="key" select="'Cardinality'" />
													</xsl:call-template>
												</td>
												<td colspan="2">
													<strong>
														<xsl:call-template name="doCardConf">
															<xsl:with-param name="minimumMultiplicity" select="@minimumMultiplicity" />
															<xsl:with-param name="maximumMultiplicity" select="@maximumMultiplicity" />
															<xsl:with-param name="isMandatory" select="@isMandatory" />
															<xsl:with-param name="conformance" select="@conformance" />
														</xsl:call-template>
													</strong>
													<xsl:variable name="conditionals">
														<conditionals>
															<!-- copy the extra pre-processed conditions -->
															<xsl:copy-of select="conditionalConcept" />
														</conditionals>
													</xsl:variable>
													<p />
													<xsl:apply-templates select="$conditionals/conditionals" />
												</td>
											</tr>
										</xsl:if>

										<!-- Compilation already resolves inherit info, but leaves the element in -->
										<xsl:if test="(inherit | @inheritedId)">
											<xsl:variable name="inheritedId" select="if (@inheritedId) then @inheritedId else (inherit/@ref)" />
											<xsl:variable name="inheritedEff" select="if (@inheritedEffectiveDate) then @inheritedEffectiveDate else (inherit/@effectiveDate)" />
											<xsl:variable name="inheritedConcept">
												<xsl:choose>
													<xsl:when test="string-length($inheritedEff)=0">
														<xsl:copy-of select="$allDatasets//concept[@id=$inheritedId and @effectiveDate=max($allDatasets//concept[@id=$inheritedId]/xs:dateTime(@effectiveDate))]" />
													</xsl:when>
													<xsl:otherwise>
														<xsl:copy-of select="$allDatasets//concept[@id=$inheritedId and @effectiveDate=$inheritedEff]" />
													</xsl:otherwise>
												</xsl:choose>
											</xsl:variable>

											<tr>
												<td class="nodeproperty" valign="top">
													<xsl:call-template name="getMessage">
														<xsl:with-param name="key" select="'conceptInheritsFrom'" />
													</xsl:call-template>
												</td>
												<td colspan="2">
													<i>
														<!-- In a compiled situation it is very well possible that we cannot resolve the concept, but add link in case we do -->
														<xsl:choose>
															<xsl:when test="exists($inheritedConcept/concept)">
																<a>
																	<xsl:attribute name="href">
                                                                        <xsl:text>ds-</xsl:text>
                                                                        <xsl:value-of select="$allDatasetConceptsFlat//dataset[.//concept[@id=$inheritedId][@effectiveDate=$inheritedEff]]/@id" />
                                                                        <xsl:text>.html#</xsl:text>
                                                                        <xsl:call-template name="getAnchorName">
                                                                            <xsl:with-param name="id" select="$inheritedId" />
                                                                            <xsl:with-param name="effectiveDate" select="$inheritedConcept/*/@effectiveDate" />
                                                                        </xsl:call-template>
                                                                    </xsl:attribute>
																	<xsl:call-template name="doShorthandId">
																		<xsl:with-param name="id" select="$inheritedId" />
																	</xsl:call-template>
																</a>
															</xsl:when>
															<xsl:otherwise>
																<xsl:call-template name="doShorthandId">
																	<xsl:with-param name="id" select="$inheritedId" />
																</xsl:call-template>
															</xsl:otherwise>
														</xsl:choose>
													</i>
													<xsl:if test="string-length($inheritedEff)&gt;0">
														<xsl:text> (</xsl:text>
														<xsl:call-template name="showDate">
															<xsl:with-param name="date" select="$inheritedEff" />
														</xsl:call-template>
														<xsl:text>)</xsl:text>
													</xsl:if>
												</td>
											</tr>
										</xsl:if>

										<xsl:call-template name="check4Issue">
											<xsl:with-param name="id" select="$conceptId" />
											<xsl:with-param name="colspans" select="2" />
										</xsl:call-template>

										<tr>
											<td class="nodeproperty" valign="top">
												<xsl:call-template name="getMessage">
													<xsl:with-param name="key" select="'Description'" />
												</xsl:call-template>
											</td>
											<td colspan="2">
												<xsl:call-template name="doDescription">
													<xsl:with-param name="ns" select="desc" />
												</xsl:call-template>
											</td>
										</tr>

										<xsl:for-each select="rationale">
											<tr>
												<td class="nodeproperty" valign="top">
													<xsl:call-template name="getMessage">
														<xsl:with-param name="key" select="'Rationale'" />
													</xsl:call-template>
												</td>
												<td colspan="2">
													<xsl:copy-of select="node()" />
												</td>
											</tr>
										</xsl:for-each>

										<xsl:for-each select="source">
											<tr>
												<td class="nodeproperty" valign="top">
													<xsl:choose>
														<xsl:when test="position()=1">
															<xsl:call-template name="getMessage">
																<xsl:with-param name="key" select="'Source'" />
															</xsl:call-template>
														</xsl:when>
														<xsl:otherwise>
															<xsl:text>&#160;</xsl:text>
														</xsl:otherwise>
													</xsl:choose>
												</td>
												<td colspan="2">
													<xsl:copy-of select="node()" />
												</td>
											</tr>
										</xsl:for-each>

										<xsl:for-each select="comment">
											<tr>
												<td class="nodeproperty" valign="top">
													<xsl:call-template name="getMessage">
														<xsl:with-param name="key" select="'Comment'" />
													</xsl:call-template>
												</td>
												<td colspan="2">
													<xsl:copy-of select="node()" />
												</td>
											</tr>
										</xsl:for-each>

										<xsl:for-each select="operationalization">
											<tr>
												<td class="nodeproperty" valign="top">
													<xsl:call-template name="getMessage">
														<xsl:with-param name="key" select="'Operationalization'" />
													</xsl:call-template>
												</td>
												<td colspan="2">
													<xsl:copy-of select="node()" />
												</td>
											</tr>
										</xsl:for-each>

										<!--<xsl:for-each select="code"> <tr> <td valign="top">(Proposed) code</td> <td colspan="2"> <xsl:text>"</xsl:text> <xsl:value-of select="@code"/> <xsl:text>" from code system </xsl:text> <xsl:value-of 
											select="@codeSystem"/> <xsl:text>&#160;</xsl:text> <xsl:call-template name="getIDDisplayName"> <xsl:with-param name="root" select="@codeSystem"/> </xsl:call-template> </td> </tr> </xsl:for-each> -->

										<xsl:variable name="conceffd" select="@effectiveDate" />
										<xsl:for-each select="$allTerminologyAssociations/*/terminologyAssociation[@conceptId = $conceptId][@code]">
											<tr>
												<td class="nodeproperty" valign="top">
													<xsl:call-template name="getMessage">
														<xsl:with-param name="key" select="'terminologyAssociation'" />
													</xsl:call-template>
												</td>
												<td style="background-color: &termColorLight;" colspan="2">
													<xsl:call-template name="getMessage">
														<xsl:with-param name="key" select="'conceptRepresentationLine'" />
														<xsl:with-param name="p1" select="@code" />
														<xsl:with-param name="p2" select="@codeSystem" />
													</xsl:call-template>
													<xsl:text>&#160;</xsl:text>
													<i>
														<xsl:call-template name="getIDDisplayName">
															<xsl:with-param name="root" select="@codeSystem" />
														</xsl:call-template>
													</i>
													<xsl:if test="@effectiveDate">
														<xsl:text>&#160;</xsl:text>
														<xsl:call-template name="getMessage">
															<xsl:with-param name="key" select="'fromX'" />
														</xsl:call-template>
														<xsl:call-template name="showDate">
															<xsl:with-param name="date" select="@effectiveDate" />
														</xsl:call-template>
													</xsl:if>
													<xsl:if test="@expirationDate">
														<xsl:text>&#160;</xsl:text>
														<xsl:call-template name="getMessage">
															<xsl:with-param name="key" select="'toY'" />
														</xsl:call-template>
														<xsl:call-template name="showDate">
															<xsl:with-param name="date" select="@expirationDate" />
														</xsl:call-template>
													</xsl:if>
												</td>
											</tr>
										</xsl:for-each>

										<xsl:for-each select="valueDomain">
											<xsl:variable name="valueType" select="@type" />

											<tr>
												<td class="nodeproperty" valign="top">
													<xsl:call-template name="getMessage">
														<xsl:with-param name="key" select="'ValueDomain'" />
													</xsl:call-template>
												</td>
												<td width="100px">
													<xsl:call-template name="getMessage">
														<xsl:with-param name="key" select="'Type'" />
													</xsl:call-template>
												</td>
												<td>
													<xsl:value-of select="$valueType" />
												</td>
											</tr>

											<xsl:for-each select="property[@*[string-length()>0]]">
												<tr>
													<td class="nodeproperty" valign="top">
														<xsl:if test="position()=1">
															<xsl:call-template name="getMessage">
																<xsl:with-param name="key" select="'Property'" />
															</xsl:call-template>
														</xsl:if>
													</td>
													<!-- select per type -->
													<xsl:choose>
														<xsl:when test="$valueType='count'">
															<xsl:if test="@minInclude or @minInclude">
																<td colspan="2" class="tabtab">
																	<table border="0" cellspacing="3" cellpadding="5">
																		<tr>
																			<th colspan="2">
																				<xsl:call-template name="getMessage">
																					<xsl:with-param name="key" select="'Range'" />
																				</xsl:call-template>
																			</th>
																		</tr>
																		<tr>
																			<th>
																				<xsl:call-template name="getMessage">
																					<xsl:with-param name="key" select="'minInclude'" />
																				</xsl:call-template>
																			</th>
																			<th>
																				<xsl:call-template name="getMessage">
																					<xsl:with-param name="key" select="'maxInclude'" />
																				</xsl:call-template>
																			</th>
																			<th>
																				<xsl:call-template name="getMessage">
																					<xsl:with-param name="key" select="'default'" />
																				</xsl:call-template>
																			</th>
																			<th>
																				<xsl:call-template name="getMessage">
																					<xsl:with-param name="key" select="'fixed'" />
																				</xsl:call-template>
																			</th>
																		</tr>
																		<tr>
																			<td align="right">
																				<xsl:value-of select="@minInclude" />
																			</td>
																			<td align="right">
																				<xsl:value-of select="@maxInclude" />
																			</td>
																			<td align="right">
																				<xsl:value-of select="@default" />
																			</td>
																			<td align="right">
																				<xsl:value-of select="@fixed" />
																			</td>
																		</tr>
																	</table>
																</td>
															</xsl:if>
														</xsl:when>
														<xsl:when test="$valueType='text' or $valueType='string'">
															<xsl:if test="@minLength or @maxLength">
																<td colspan="2" class="tabtab">
																	<table border="0" cellspacing="3" cellpadding="5">
																		<tr>
																			<th colspan="2">
																				<xsl:call-template name="getMessage">
																					<xsl:with-param name="key" select="'Length'" />
																				</xsl:call-template>
																			</th>
																		</tr>
																		<tr>
																			<th>
																				<xsl:call-template name="getMessage">
																					<xsl:with-param name="key" select="'minLength'" />
																				</xsl:call-template>
																			</th>
																			<th>
																				<xsl:call-template name="getMessage">
																					<xsl:with-param name="key" select="'maxLength'" />
																				</xsl:call-template>
																			</th>
																			<th>
																				<xsl:call-template name="getMessage">
																					<xsl:with-param name="key" select="'default'" />
																				</xsl:call-template>
																			</th>
																			<th>
																				<xsl:call-template name="getMessage">
																					<xsl:with-param name="key" select="'fixed'" />
																				</xsl:call-template>
																			</th>
																		</tr>
																		<tr>
																			<td align="right">
																				<xsl:value-of select="@minLength" />
																			</td>
																			<td align="right">
																				<xsl:value-of select="@maxLength" />
																			</td>
																			<td align="right">
																				<xsl:value-of select="@default" />
																			</td>
																			<td align="right">
																				<xsl:value-of select="@fixed" />
																			</td>
																		</tr>
																	</table>
																</td>
															</xsl:if>
														</xsl:when>
														<xsl:when test="$valueType='date' or $valueType='datetime'">
															<!-- timeStampPrecision -->
															<xsl:if test="@timeStampPrecision">
																<td colspan="2" class="tabtab">
																	<table border="0" cellspacing="3" cellpadding="5">
																		<tr>
																			<th>
																				<xsl:call-template name="getMessage">
																					<xsl:with-param name="key" select="'TimestampPrecision'" />
																				</xsl:call-template>
																			</th>
																		</tr>
																		<tr>
																			<td align="left">
																				<xsl:call-template name="getMessage">
																					<xsl:with-param name="key" select="concat('timeStampPrecision-', @timeStampPrecision)" />
																				</xsl:call-template>
																			</td>
																		</tr>
																	</table>
																</td>
															</xsl:if>
														</xsl:when>
														<xsl:when test="$valueType='quantity' or $valueType='duration'">
															<!-- rangeFrom, rangeTo, unit(s), fractionDigits -->
															<xsl:if test="@minInclude or @maxInclude or @unit or @fractionDigits">
																<td colspan="2" class="tabtab">
																	<table border="0" cellspacing="3" cellpadding="5">
																		<tr>
																			<th colspan="2">
																				<xsl:call-template name="getMessage">
																					<xsl:with-param name="key" select="'Range'" />
																				</xsl:call-template>
																			</th>
																			<th>
																				<xsl:call-template name="getMessage">
																					<xsl:with-param name="key" select="'unit'" />
																				</xsl:call-template>
																			</th>
																			<th>
																				<xsl:call-template name="getMessage">
																					<xsl:with-param name="key" select="'minFractionDigits'" />
																				</xsl:call-template>
																			</th>
																			<th>
																				<xsl:call-template name="getMessage">
																					<xsl:with-param name="key" select="'default'" />
																				</xsl:call-template>
																			</th>
																			<th>
																				<xsl:call-template name="getMessage">
																					<xsl:with-param name="key" select="'fixed'" />
																				</xsl:call-template>
																			</th>
																		</tr>
																		<tr>
																			<th>
																				<xsl:call-template name="getMessage">
																					<xsl:with-param name="key" select="'minInclude'" />
																				</xsl:call-template>
																			</th>
																			<th>
																				<xsl:call-template name="getMessage">
																					<xsl:with-param name="key" select="'maxInclude'" />
																				</xsl:call-template>
																			</th>
																			<th>
																			</th>
																			<th>
																			</th>
																			<th>
																			</th>
																			<th>
																			</th>
																		</tr>
																		<tr>
																			<td align="right">
																				<xsl:value-of select="@minInclude" />
																			</td>
																			<td align="right">
																				<xsl:value-of select="@maxInclude" />
																			</td>
																			<td align="right">
																				<xsl:value-of select="@unit" />
																			</td>
																			<td align="right">
																				<xsl:choose>
																					<xsl:when test="string-length(@fractionDigits)=0">
																					</xsl:when>
																					<xsl:when test="matches(string(@fractionDigits), '!$')">
																						<!-- exact fraction digits -->
																						<xsl:text>exact </xsl:text>
																						<xsl:value-of select="substring-before(@fractionDigits, '!')" />
																					</xsl:when>
																					<xsl:otherwise>
																						<xsl:text>min </xsl:text>
																						<xsl:value-of select="@fractionDigits" />
																					</xsl:otherwise>
																				</xsl:choose>
																			</td>
																			<td align="right">
																				<xsl:value-of select="@default" />
																			</td>
																			<td align="right">
																				<xsl:value-of select="@fixed" />
																			</td>
																		</tr>
																	</table>
																</td>
															</xsl:if>
														</xsl:when>
														<xsl:when test="$valueType='complex'">
															<td colspan="2" />
														</xsl:when>
														<xsl:when test="$valueType='code'">
															<td colspan="2" />
														</xsl:when>
														<xsl:when test="$valueType='identifier'">
															<xsl:if test="@minLength or @maxLength">
																<td colspan="2" class="tabtab">
																	<table border="0" cellspacing="3" cellpadding="5">
																		<tr>
																			<th colspan="2">
																				<xsl:call-template name="getMessage">
																					<xsl:with-param name="key" select="'Length'" />
																				</xsl:call-template>
																			</th>
																		</tr>
																		<tr>
																			<th>
																				<xsl:call-template name="getMessage">
																					<xsl:with-param name="key" select="'minLength'" />
																				</xsl:call-template>
																			</th>
																			<th>
																				<xsl:call-template name="getMessage">
																					<xsl:with-param name="key" select="'maxLength'" />
																				</xsl:call-template>
																			</th>
																		</tr>
																		<tr>
																			<td align="right">
																				<xsl:value-of select="@minLength" />
																			</td>
																			<td align="right">
																				<xsl:value-of select="@maxLength" />
																			</td>
																		</tr>
																	</table>
																</td>
															</xsl:if>
														</xsl:when>
														<xsl:when test="$valueType='boolean'">
															<td colspan="2" />
														</xsl:when>
														<xsl:when test="$valueType='blob'">
															<xsl:if test="@minLength or @maxLength">
																<td colspan="2" class="tabtab">
																	<table border="0" cellspacing="3" cellpadding="5">
																		<tr>
																			<th colspan="2">
																				<xsl:call-template name="getMessage">
																					<xsl:with-param name="key" select="'Length'" />
																				</xsl:call-template>
																			</th>
																		</tr>
																		<tr>
																			<th>
																				<xsl:call-template name="getMessage">
																					<xsl:with-param name="key" select="'minLength'" />
																				</xsl:call-template>
																			</th>
																			<th>
																				<xsl:call-template name="getMessage">
																					<xsl:with-param name="key" select="'maxLength'" />
																				</xsl:call-template>
																			</th>
																		</tr>
																		<tr>
																			<td align="right">
																				<xsl:value-of select="@minLength" />
																			</td>
																			<td align="right">
																				<xsl:value-of select="@maxLength" />
																			</td>
																		</tr>
																	</table>
																</td>
															</xsl:if>
														</xsl:when>
														<xsl:otherwise>
															<td>
																<xsl:text>(</xsl:text>
																<xsl:call-template name="getMessage">
																	<xsl:with-param name="key" select="'undefValueType'" />
																</xsl:call-template>
																<xsl:text>)</xsl:text>
															</td>
															<td>
																<xsl:value-of select="$valueType" />
															</td>
														</xsl:otherwise>
													</xsl:choose>
												</tr>
											</xsl:for-each>

											<xsl:apply-templates select="conceptList" />

											<xsl:for-each select="example">
												<tr>
													<td class="nodeproperty" valign="top">
														<xsl:call-template name="getMessage">
															<xsl:with-param name="key" select="'Example'" />
														</xsl:call-template>
													</td>
													<td class="{if (@type='error') then 'explabelred' else if (@type='valid') then 'explabelgreen' else 'explabel'}" colspan="2">
														<xsl:if test=".[@caption]">
															<div class="expcaption">
																<xsl:value-of select="@caption" />
															</div>
														</xsl:if>
														<xsl:copy-of select="node()" />
													</td>
												</tr>
											</xsl:for-each>

										</xsl:for-each>

										<!-- used in what scenarios? -->
										<xsl:variable name="sccount" select="count($allScenarios/scenarios/scenario[transaction//representingTemplate/concept[@ref=$conceptId]])" />
										<xsl:variable name="ihcount" select="count($allDatasets/dataset//inherit[@ref=$conceptId])" />
										<xsl:if test="$sccount+$ihcount>0">
											<tr>
												<td class="nodeproperty" valign="top">
													<xsl:call-template name="getMessage">
														<xsl:with-param name="key" select="'UsedBy'" />
													</xsl:call-template>
												</td>
												<td colspan="2">
													<xsl:choose>
														<xsl:when test="$sccount = 1 and $ihcount = 1">
															<xsl:call-template name="getMessage">
																<xsl:with-param name="key" select="'scenarioInheritCount'" />
															</xsl:call-template>
														</xsl:when>
														<xsl:when test="$sccount != 1 and $ihcount = 1">
															<xsl:call-template name="getMessage">
																<xsl:with-param name="key" select="'scenariosInheritCount'" />
																<xsl:with-param name="p1" select="$sccount" />
															</xsl:call-template>
														</xsl:when>
														<xsl:when test="$sccount = 1 and $ihcount != 1">
															<xsl:call-template name="getMessage">
																<xsl:with-param name="key" select="'scenarioInheritCounts'" />
																<xsl:with-param name="p1" select="$ihcount" />
															</xsl:call-template>
														</xsl:when>
														<xsl:otherwise>
															<xsl:call-template name="getMessage">
																<xsl:with-param name="key" select="'scenariosInheritCounts'" />
																<xsl:with-param name="p1" select="$sccount" />
																<xsl:with-param name="p2" select="$ihcount" />
															</xsl:call-template>
														</xsl:otherwise>
													</xsl:choose>
												</td>
											</tr>
											<xsl:for-each select="$allScenarios/scenarios/scenario/transaction//representingTemplate/concept[@ref=$conceptId]">
												<tr>
													<td class="nodeproperty" valign="top" align="center">
														<xsl:call-template name="showIcon">
															<xsl:with-param name="which">
																target
															</xsl:with-param>
														</xsl:call-template>
													</td>
													<td colspan="2" style="background-color: &infmColorLight;">
														<xsl:call-template name="getMessage">
															<xsl:with-param name="key" select="'conceptTransactionAssocLine'" />
															<xsl:with-param name="p1">
																<xsl:variable name="trid" select="../../@id" />
																<xsl:variable name="treff" select="../../@effectiveDate" />
																<!-- Transaction href -->
																<xsl:value-of select="concat('dstr-',$trid, if (matches($treff,'^\d{4}')) then concat('-',replace($treff,':','')) else (),'.html')" />
															</xsl:with-param>
															<xsl:with-param name="p2">
																<!-- Transaction Name -->
																<xsl:choose>
																	<xsl:when test="../../name[@language=$defaultLanguage]">
																		<xsl:value-of select="../../name[@language=$defaultLanguage][1]" />
																	</xsl:when>
																	<xsl:otherwise>
																		<xsl:value-of select="../../name[1]" />
																	</xsl:otherwise>
																</xsl:choose>
															</xsl:with-param>
															<xsl:with-param name="p3">
																<!-- Min/Max/Conf/Mand -->
																<!-- Get (minimum) minimumMultiplicity, possibly from condition. Default if absent is 0 -->
																<xsl:choose>
																	<xsl:when test="@conformance='NP'">
																		<xsl:text>0</xsl:text>
																	</xsl:when>
																	<xsl:when test="not(@conformance='C') and not(@minimumMultiplicity)">
																		<xsl:text>0</xsl:text>
																	</xsl:when>
																	<xsl:when test="not(@conformance='C')">
																		<xsl:value-of select="@minimumMultiplicity" />
																	</xsl:when>
																	<xsl:when test="@conformance='C' and condition[not(@conformance='NP')][not(@minimumMultiplicity)]">
																		<xsl:text>0</xsl:text>
																	</xsl:when>
																	<xsl:otherwise>
																		<xsl:value-of select="min(condition[not(@conformance='NP')][@minimumMultiplicity]/number(@minimumMultiplicity))" />
																	</xsl:otherwise>
																</xsl:choose>
																<xsl:text>..</xsl:text>
																<!-- Get (maximum) maximumMultiplicity, possibly from condition. Default if absent is * -->
																<xsl:choose>
																	<xsl:when test="@conformance='NP'">
																		<xsl:text>0</xsl:text>
																	</xsl:when>
																	<xsl:when test="not(@conformance='C') and (@maximumMultiplicity='*' or not(@maximumMultiplicity))">
																		<xsl:text>*</xsl:text>
																	</xsl:when>
																	<xsl:when test="not(@conformance='C')">
																		<xsl:value-of select="@maximumMultiplicity" />
																	</xsl:when>
																	<xsl:when test="@conformance='C' and (condition[not(@conformance='NP')][@maximumMultiplicity='*' or not(@maximumMultiplicity)])">
																		<xsl:text>*</xsl:text>
																	</xsl:when>
																	<xsl:otherwise>
																		<xsl:value-of select="max(condition[not(@conformance='NP')][@maximumMultiplicity]/number(@maximumMultiplicity))" />
																	</xsl:otherwise>
																</xsl:choose>
																<xsl:if test="@conformance">
																	<xsl:text> </xsl:text>
																	<xsl:call-template name="getXFormsLabel">
																		<xsl:with-param name="simpleTypeKey" select="'ConformanceType'" />
																		<xsl:with-param name="lang" select="$defaultLanguage" />
																		<xsl:with-param name="simpleTypeValue" select="@conformance" />
																	</xsl:call-template>
																</xsl:if>
																<xsl:if test="@isMandatory=true()">
																	<xsl:text> </xsl:text>
																	<xsl:call-template name="getMessage">
																		<xsl:with-param name="key" select="'conformanceMandatory'" />
																	</xsl:call-template>
																</xsl:if>
															</xsl:with-param>
															<xsl:with-param name="p4">
																<!-- Scenario Name -->
																<xsl:choose>
																	<xsl:when test="name[@language=$defaultLanguage]">
																		<xsl:value-of select="name[@language=$defaultLanguage][1]" />
																	</xsl:when>
																	<xsl:otherwise>
																		<xsl:value-of select="name[1]" />
																	</xsl:otherwise>
																</xsl:choose>
															</xsl:with-param>
														</xsl:call-template>
													</td>
												</tr>
											</xsl:for-each>
										</xsl:if>

										<xsl:for-each select="$allTemplateAssociation/*/templateAssociation[concept[@ref = $conceptId]]">
											<xsl:for-each select="concept[@ref = $conceptId and (not(@effectiveDate) or @effectiveDate = $conceffd)]">
												<tr>
													<td class="nodeproperty" valign="top" align="center">
														<xsl:call-template name="showIcon">
															<xsl:with-param name="which">
																target
															</xsl:with-param>
														</xsl:call-template>
													</td>
													<td colspan="2" style="background-color: &infmColorLight;">

														<xsl:call-template name="getMessage">
															<xsl:with-param name="key" select="'conceptTemplateAssocLine'" />
															<xsl:with-param name="p1">
																<xsl:value-of select="concat('tmp-', parent::templateAssociation/@templateId,'-',replace(parent::templateAssociation/@effectiveDate,':',''), '.html#')" />
																<xsl:call-template name="getAnchorName">
																	<xsl:with-param name="id" select="$conceptId" />
																	<xsl:with-param name="effectiveDate" select="$conceffd" />
																</xsl:call-template>
															</xsl:with-param>
															<xsl:with-param name="p2">
																<xsl:call-template name="doShorthandId">
																	<xsl:with-param name="id" select="parent::templateAssociation/@templateId" />
																</xsl:call-template>
															</xsl:with-param>
															<xsl:with-param name="p3">
																<xsl:call-template name="doShorthandId">
																	<xsl:with-param name="id" select="@elementId" />
																</xsl:call-template>
															</xsl:with-param>
														</xsl:call-template>
													</td>
												</tr>
											</xsl:for-each>
										</xsl:for-each>

										<xsl:variable name="hccount" select="count(history)" />
										<xsl:if test="$hccount > 0">
											<tr>
												<td valign="top" align="center">
													<xsl:call-template name="showIcon">
														<xsl:with-param name="which">
															blueclock
														</xsl:with-param>
													</xsl:call-template>
												</td>
												<td colspan="2">
													<xsl:call-template name="getMessage">
														<xsl:with-param name="key" select="'historicDefinition'" />
														<xsl:with-param name="p1" select="$hccount" />
													</xsl:call-template>
												</td>
											</tr>
										</xsl:if>

									</table>
								</div>
							</td>
						</tr>
					</xsl:if>

					<xsl:if test="count(concept)>0">

						<xsl:if test="$nestingWithTables=true()">
							<tr>
								<td valign="top">
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'Concept'" />
									</xsl:call-template>
								</td>
								<td colspan="2" class="tabtab">
									<xsl:apply-templates select="concept" mode="dataset">
										<xsl:with-param name="level" select="$level+1" />
										<xsl:with-param name="nestingWithTables" select="$nestingWithTables" />
									</xsl:apply-templates>
								</td>
							</tr>
						</xsl:if>

					</xsl:if>

				</table>

				<xsl:if test="$nestingWithTables=false()">
					<xsl:apply-templates select="concept" mode="dataset">
						<xsl:with-param name="level" select="$level+1" />
						<xsl:with-param name="nestingWithTables" select="$nestingWithTables" />
					</xsl:apply-templates>
				</xsl:if>
				<!-- <script type="text/javascript"> // toggle all elids //toggle('{$elidtoggled}','{$elidtoggler}'); <xsl:text>toggle("fold","tr",'</xsl:text> <xsl:value-of select="$elidtoggled"/> <xsl:text>');</xsl:text> 
					</script> -->

			</xsl:when>

			<xsl:otherwise>
				<xsl:call-template name="logMessage">
					<xsl:with-param name="level" select="$logWARN" />
					<xsl:with-param name="msg">
						<xsl:text>+++ not processing dataset concept that does not have an @id or inherit/@id "</xsl:text>
						<xsl:copy copy-namespaces="no">
							<xsl:copy-of select="@*" copy-namespaces="no" />
						</xsl:copy>
						<xsl:text>"</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template match="concept" mode="filter">
		<xsl:param name="representingTemplate" />
		<!-- copy filtered concept (concept data is taken from allDatasetConceptsFlat as they are already de-refed) -->
		<!-- cache current concept id and effectiveDate -->
		<xsl:variable name="cid" select="@id" />
		<xsl:variable name="ceff" select="@effectiveDate" />
		<!-- de-ref'd concept -->
		<xsl:variable name="theConcept" select="($allDatasetConceptsFlat/*/*/concept[@id=$cid])[1]" />

		<!-- make a copy of the concept data -->
		<concept>
			<!-- copy attributes -->
			<xsl:copy-of select="$theConcept/@*" />

			<xsl:if test="count($representingTemplate/concept[@ref=$cid])=0 and ($theConcept/@type!='group')">
				<!-- set hidden flag for this concept if not present if this is an item (not a group concept, empty groups are eliminated later) -->
				<xsl:attribute name="hidden" select="'true'" />
			</xsl:if>

			<xsl:if test="count($representingTemplate/concept[@ref=$cid])>0">
				<!-- concept present, copy cardinality conformance if present -->
				<xsl:for-each select="$representingTemplate/concept[@ref=$cid]/(@minimumMultiplicity|@maximumMultiplicity|@isMandatory|@conformance)">
					<xsl:variable name="attname" select="name()" />
					<xsl:attribute name="{$attname}" select="." />
				</xsl:for-each>
				<!-- copy conditions of conditional concept as conditionalConcept -->
				<xsl:for-each select="$representingTemplate/concept[@ref=$cid]/condition">
					<conditionalConcept>
						<xsl:copy-of select="@*" />
						<xsl:copy-of select="text()" />
					</conditionalConcept>
				</xsl:for-each>
			</xsl:if>

			<!-- copy all elements of the concept, no sub-concepts are copied (done later recursively), no history -->
			<xsl:for-each select="$theConcept/* except $theConcept/history">
				<xsl:copy-of select="." />
			</xsl:for-each>

			<!-- process subconcepts -->
			<xsl:apply-templates select="concept" mode="filter">
				<xsl:with-param name="representingTemplate" select="$representingTemplate" />
			</xsl:apply-templates>

		</concept>

	</xsl:template>

	<xsl:template match="concept" mode="eliminatedHiddenConcepts">

		<xsl:choose>
			<xsl:when test="@type='item' and not(@hidden)">
				<xsl:copy-of select="." />
			</xsl:when>
			<xsl:when test="@type='group'">
				<!-- if all concept items are hidden don't copy this group -->
				<xsl:variable name="hiddenitems" select="count(.//concept[@hidden and @type='item'])" />
				<xsl:variable name="allitems" select="count(.//concept[@type='item'])" />
				<xsl:if test="($allitems - $hiddenitems) > 0">
					<concept>
						<xsl:copy-of select="@*" />
						<xsl:copy-of select="* except (concept|history)" />
						<xsl:apply-templates select="concept" mode="eliminatedHiddenConcepts" />
					</concept>
				</xsl:if>
			</xsl:when>
		</xsl:choose>

	</xsl:template>

	<xsl:template match="conceptList">
		<!-- if conceptList has no @ref (ie and @id or neither an @id nor a @ref) show concept list with all concepts and exceptions if conceptList has a @ref then first resolve the @ref within the current data 
			set and then show concept list with all concepts and exceptions -->
		<!-- get the right list -->
		<xsl:variable name="theConceptList">
			<xsl:choose>
				<!-- a @ref, resolve first, then process -->
				<xsl:when test="@ref">
					<xsl:variable name="clref" select="@ref" />
					<!-- get id of parent dataset -->
					<xsl:variable name="pardsid" select="$allDatasetConceptsFlat/datasets/dataset[//conceptList[@ref=$clref]]/@id" />
					<!-- get conceptList (the first one just in case there are multiple) with id specified in @ref here, maybe empty -->
					<xsl:copy-of select="($allDatasetConceptsFlat/datasets/dataset[@id=$pardsid]//conceptList[not(ancestor::history) and @id=$clref])[1]" />
				</xsl:when>
				<!-- otherwise simply make a copy and process it -->
				<xsl:otherwise>
					<xsl:copy-of select="." />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="clid" select="($theConceptList/conceptList/@id)[last()]" />
		<xsl:if test="$theConceptList/conceptList/concept[name] or $allTerminologyAssociations/*/terminologyAssociation[@conceptId = $clid][@valueSet]">
			<tr>
				<td valign="top">
					<xsl:call-template name="getMessage">
						<xsl:with-param name="key" select="'choiceList'" />
					</xsl:call-template>
				</td>
				<td class="tabtab" valign="top" colspan="2">
					<table width="100%" border="0" cellspacing="3" cellpadding="2">
						<tr class="headinglabel">
							<th>
								<xsl:call-template name="getMessage">
									<xsl:with-param name="key" select="'ConceptList'" />
								</xsl:call-template>
							</th>
							<th colspan="2">
								<xsl:call-template name="doShorthandId">
									<xsl:with-param name="id" select="$clid" />
								</xsl:call-template>
							</th>
						</tr>
						<xsl:if test="$theConceptList/conceptList/concept[name]">
							<tr bgcolor="&sandColorLight;">
								<td>
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'choiceListConcept'" />
									</xsl:call-template>
								</td>
								<td>
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'choiceListDescription'" />
									</xsl:call-template>
								</td>
								<td>
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'choiceListResolvedRefs'" />
									</xsl:call-template>
								</td>
							</tr>
							<xsl:for-each select="$theConceptList/conceptList/concept[name]">
								<xsl:variable name="cid" select="@id" />
								<tr>
									<td valign="top">
										<xsl:call-template name="doName">
											<xsl:with-param name="ns" select="name" />
										</xsl:call-template>
									</td>
									<td valign="top">
										<xsl:if test="@exception='true'">
											<xsl:call-template name="getMessage">
												<xsl:with-param name="key" select="'exceptionalConcept'" />
											</xsl:call-template>
										</xsl:if>
										<xsl:call-template name="doDescription">
											<xsl:with-param name="ns" select="desc" />
										</xsl:call-template>
									</td>
									<td valign="top">
										<!--xsl:call-template name="getMessage"> <xsl:with-param name="key" select="'toBeDetermined'"/> </xsl:call-template -->
										<!-- 2DO check if assumption on code/codeSystem is correct -->
										<xsl:for-each select="$allTerminologyAssociations/*/terminologyAssociation[@conceptId = $cid]">
											<xsl:variable name="theName">
												<xsl:call-template name="getIDDisplayName">
													<xsl:with-param name="root" select="@codeSystem" />
												</xsl:call-template>
											</xsl:variable>

											<xsl:call-template name="getMessage">
												<xsl:with-param name="key" select="'conceptInConceptListRepresentationLine'" />
												<xsl:with-param name="p1" select="@code" />
												<xsl:with-param name="p2">
													<xsl:choose>
														<xsl:when test="string-length($theName)>0">
															<xsl:value-of select="$theName" />
														</xsl:when>
														<xsl:otherwise>
															<xsl:value-of select="@codeSystem" />
														</xsl:otherwise>
													</xsl:choose>
												</xsl:with-param>
												<!--xsl:with-param name="p3" select="@codeSystem"/ -->
											</xsl:call-template>
											<xsl:if test="position()!=last()">
												<br />
											</xsl:if>
										</xsl:for-each>
									</td>
								</tr>
							</xsl:for-each>
						</xsl:if>
						<!-- show coded concept associations = value sets - if already defined -->
						<xsl:for-each select="$allTerminologyAssociations/*/terminologyAssociation[@conceptId = $clid][@valueSet]">
							<xsl:variable name="xvsref" select="@valueSet" />
							<xsl:variable name="xvsflex" select="if (@flexibility) then (@flexibility) else ('dynamic')" />
							<xsl:variable name="xvs">
								<xsl:call-template name="getValueset">
									<xsl:with-param name="reference" select="$xvsref" />
									<xsl:with-param name="flexibility" select="$xvsflex" />
								</xsl:call-template>
							</xsl:variable>
							<xsl:variable name="xvsid" select="($xvs/valueSet)[1]/@id" />
							<xsl:variable name="xvsdn" select="($xvs/valueSet)[1]/@displayName" />
							<xsl:variable name="valueSetFileObject">
								<xsl:choose>
									<xsl:when test="$xvsflex='dynamic'">
										<xsl:value-of select="concat('voc-', $xvsid, '-DYNAMIC.html')" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat('voc-', $xvsid, '-',replace($xvsflex,':',''),'.html')" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<tr>
								<td colspan="3">
									<hr />
								</td>
							</tr>
							<tr>
								<td colspan="3" valign="top" style="background-color: &termColorLight;">
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'terminologyAssociation'" />
									</xsl:call-template>
									<xsl:text>: </xsl:text>
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'conceptListRepresentationLine'" />
										<xsl:with-param name="p1" select="$valueSetFileObject" />
										<xsl:with-param name="p2" select="@valueSet" />
										<xsl:with-param name="p3">
											<xsl:choose>
												<xsl:when test="matches($xvsflex,'^\d{4}')">
													<xsl:call-template name="showDate">
														<xsl:with-param name="date" select="$xvsflex" />
													</xsl:call-template>
												</xsl:when>
												<xsl:otherwise>
													<xsl:call-template name="getMessage">
														<xsl:with-param name="key" select="'associationDYNAMIC'" />
													</xsl:call-template>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:with-param>
									</xsl:call-template>
									<xsl:if test="@effectiveDate">
										<xsl:call-template name="getMessage">
											<xsl:with-param name="key" select="'fromX'" />
										</xsl:call-template>
										<xsl:call-template name="showDate">
											<xsl:with-param name="date" select="@effectiveDate" />
										</xsl:call-template>
									</xsl:if>
									<xsl:if test="@expirationDate">
										<xsl:call-template name="getMessage">
											<xsl:with-param name="key" select="'toY'" />
										</xsl:call-template>
										<xsl:call-template name="showDate">
											<xsl:with-param name="date" select="@expirationDate" />
										</xsl:call-template>
									</xsl:if>
									<!--<xsl:if test="not(@effectiveDate or @expirationDate)"> <xsl:call-template name="getMessage"> <xsl:with-param name="key" select="'terminologyAssociationDYNAMIC'"/> </xsl:call-template> </xsl:if> -->
								</td>
							</tr>
						</xsl:for-each>
					</table>
				</td>
			</tr>
		</xsl:if>
	</xsl:template>

	<xsl:template match="valueSet">
		<!-- language, not yet used -->
		<xsl:param name="language" />
		<!-- whether to show other versions of this value set at the end as a list, default is true -->
		<xsl:param name="showOtherVersionsList" select="true()" />

		<xsl:variable name="vsname" select="@name" />
		<xsl:variable name="vsid" select="(@id|@ref)" />
		<xsl:variable name="vsed" select="@effectiveDate" />
		<xsl:variable name="numcol" select="4" />
		<table border="0" cellspacing="10">
			<tr>
				<td class="tabtab">
					<table width="100%" border="0" cellspacing="3" cellpadding="2">
						<thead>
							<xsl:if test="desc">
								<tr valign="top">
									<th valign="top" colspan="{$numcol}">
										<xsl:call-template name="getMessage">
											<xsl:with-param name="key" select="'Description'" />
										</xsl:call-template>
									</th>
								</tr>
								<tr>
									<td colspan="{$numcol}">
										<xsl:call-template name="doDescription">
											<xsl:with-param name="ns" select="desc" />
										</xsl:call-template>
									</td>
								</tr>
							</xsl:if>
							<tr class="headinglabel">
								<th align="left">
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'ValueSetName'" />
									</xsl:call-template>
								</th>
								<th align="left">
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'ValueSetId'" />
									</xsl:call-template>
								</th>
								<th align="left">
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'VersionEffectiveDate'" />
									</xsl:call-template>
								</th>
								<th align="left">
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'Status'" />
									</xsl:call-template>
								</th>
							</tr>
							<tr bgcolor="&sandColorLight;">
								<td>
									<i>
										<xsl:value-of select="@name" />
									</i>
								</td>
								<td>
									<xsl:value-of select="$vsid" />
								</td>
								<td>
									<xsl:if test="@versionLabel">
										<xsl:value-of select="@versionLabel" />
										<xsl:text> - </xsl:text>
									</xsl:if>
									<xsl:call-template name="showDate">
										<xsl:with-param name="date" select="$vsed" />
									</xsl:call-template>
								</td>
								<td>
									<xsl:if test="@statusCode">
										<xsl:call-template name="getMessage">
											<xsl:with-param name="key" select="concat('ItemStatusCodeLifeCycle-',@statusCode)" />
										</xsl:call-template>
									</xsl:if>
								</td>
							</tr>
							<xsl:call-template name="check4Issue">
								<xsl:with-param name="id" select="$vsid" />
								<xsl:with-param name="colspans" select="$numcol - 1" />
							</xsl:call-template>
						</thead>
						<tbody>
							<xsl:if test="completeCodeSystem">
								<tr>
									<td colspan="{$numcol}">
										<xsl:choose>
											<xsl:when test="count(completeCodeSystem)=1">
												<b>
													<xsl:call-template name="getMessage">
														<xsl:with-param name="key" select="'xCompleteCodeSystem'" />
													</xsl:call-template>
												</b>
											</xsl:when>
											<xsl:when test="count(completeCodeSystem)>1">
												<b>
													<xsl:call-template name="getMessage">
														<xsl:with-param name="key" select="'xCompleteCodeSystems'" />
														<xsl:with-param name="p1" select="count(completeCodeSystem)" />
													</xsl:call-template>
												</b>
											</xsl:when>
										</xsl:choose>
										<table width="100%" border="0" cellspacing="3" cellpadding="2">
											<tr bgcolor="&sandColorLight;">
												<td width="200px" align="left">
													<xsl:call-template name="getMessage">
														<xsl:with-param name="key" select="'CodeSystemName'" />
													</xsl:call-template>
												</td>
												<td width="200px" align="left">
													<xsl:call-template name="getMessage">
														<xsl:with-param name="key" select="'CodeSystemId'" />
													</xsl:call-template>
												</td>
												<td align="left">
													<xsl:call-template name="getMessage">
														<xsl:with-param name="key" select="'CodeSystemVersion'" />
													</xsl:call-template>
												</td>
												<xsl:if test="completeCodeSystem[@flexibility]">
													<td>
														<xsl:call-template name="getMessage">
															<xsl:with-param name="key" select="'Flexibility'" />
														</xsl:call-template>
													</td>
												</xsl:if>
											</tr>
											<xsl:for-each select="completeCodeSystem">
												<tr>
													<td align="left">
														<xsl:variable name="theId" select="@codeSystem" />
														<xsl:variable name="theName">
															<xsl:call-template name="getIDDisplayName">
																<xsl:with-param name="root" select="$theId" />
															</xsl:call-template>
														</xsl:variable>
														<xsl:choose>
															<xsl:when test="string-length(@codeSystemName)>0">
																<xsl:text>&#160;</xsl:text>
																<i>
																	<xsl:value-of select="@codeSystemName" />
																</i>
															</xsl:when>
															<xsl:when test="string-length($theName)>0">
																<xsl:text>&#160;</xsl:text>
																<i>
																	<xsl:value-of select="$theName" />
																</i>
															</xsl:when>
														</xsl:choose>
													</td>
													<td align="left">
														<xsl:value-of select="@codeSystem" />
													</td>
													<td align="left">
														<xsl:value-of select="@codeSystemVersion" />
													</td>
													<xsl:if test="../completeCodeSystem[@flexibility]">
														<td align="left">
															<xsl:choose>
																<xsl:when test="matches(@flexibility,'^\d{4}')">
																	<xsl:call-template name="showDate">
																		<xsl:with-param name="date" select="@flexibility" />
																	</xsl:call-template>
																</xsl:when>
																<xsl:otherwise>
																	<xsl:call-template name="getMessage">
																		<xsl:with-param name="key" select="'terminologyAssociationDYNAMIC'" />
																	</xsl:call-template>
																</xsl:otherwise>
															</xsl:choose>
														</td>
													</xsl:if>
												</tr>
											</xsl:for-each>
										</table>
									</td>
								</tr>
							</xsl:if>
							<xsl:if test="completeCodeSystem and conceptList">
								<tr>
									<td colspan="{$numcol}">
										<b>
											<xsl:call-template name="getMessage">
												<xsl:with-param name="key" select="'orOneOfTheFollowing'" />
											</xsl:call-template>
										</b>
									</td>
								</tr>
							</xsl:if>
							<xsl:if test="conceptList">
								<!-- print and/or calculate sourceCodeSystems -->
								<xsl:if test="conceptList/concept">
									<!-- check if sourceCodeSystem is used in this original value set, if not - create them -->
									<xsl:variable name="sourceCodeSystem">
										<xsl:choose>
											<xsl:when test="count(sourceCodeSystem)>1">
												<xsl:copy-of select="sourceCodeSystem" />
											</xsl:when>
											<xsl:otherwise>
												<xsl:for-each-group select="conceptList/concept" group-by="@codeSystem">
													<sourceCodeSystem id="{@codeSystem}" />
												</xsl:for-each-group>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:variable>
									<tr>
										<td>
											<xsl:choose>
												<xsl:when test="count($sourceCodeSystem) = 1">
													<xsl:call-template name="getMessage">
														<xsl:with-param name="key" select="'xSourceCodeSystem'" />
													</xsl:call-template>
												</xsl:when>
												<xsl:otherwise>
													<xsl:call-template name="getMessage">
														<xsl:with-param name="key" select="'xSourceCodeSystems'" />
														<xsl:with-param name="p1" select="string(count($sourceCodeSystem))" />
													</xsl:call-template>
												</xsl:otherwise>
											</xsl:choose>
											<xsl:text>:</xsl:text>
											<ul>
												<xsl:for-each select="$sourceCodeSystem/*">
													<li>
														<xsl:variable name="theId" select="@id" />
														<xsl:value-of select="$theId" />

														<xsl:variable name="theName">
															<xsl:call-template name="getIDDisplayName">
																<xsl:with-param name="root" select="$theId" />
															</xsl:call-template>
														</xsl:variable>
														<xsl:if test="string-length($theName)>0">
															<xsl:text>&#160;</xsl:text>
															<i>
																<xsl:value-of select="$theName" />
															</i>
														</xsl:if>
													</li>
												</xsl:for-each>
											</ul>
										</td>
									</tr>
								</xsl:if>
								<tr>
									<td colspan="{$numcol}">
										<xsl:variable name="numcolcodes" select="if (conceptList/(concept|exception)[@codeSystemVersion]) then (6) else (5)" />
										<!-- outputput concepts and exceptions -->
										<table width="100%" border="0" cellspacing="3" cellpadding="2">
											<thead>
												<tr bgcolor="&sandColorLight;">
													<td width="100px" align="left">
														<xsl:call-template name="getMessage">
															<xsl:with-param name="key" select="'LevelSlashType'" />
														</xsl:call-template>
													</td>
													<td width="100px" align="left">
														<xsl:call-template name="getMessage">
															<xsl:with-param name="key" select="'Code'" />
														</xsl:call-template>
													</td>
													<td align="left">
														<xsl:call-template name="getMessage">
															<xsl:with-param name="key" select="'DisplayName'" />
														</xsl:call-template>
													</td>
													<td width="200px" align="left">
														<xsl:call-template name="getMessage">
															<xsl:with-param name="key" select="'CodeSystem'" />
														</xsl:call-template>
													</td>
													<xsl:if test="conceptList/(concept|exception)[@codeSystemVersion]">
														<td align="left">
															<xsl:call-template name="getMessage">
																<xsl:with-param name="key" select="'CodeSystemVersion'" />
															</xsl:call-template>
														</td>
													</xsl:if>
													<td valign="top" align="left">
														<xsl:call-template name="getMessage">
															<xsl:with-param name="key" select="'Description'" />
														</xsl:call-template>
													</td>
												</tr>
											</thead>

											<!-- first list all valid concepts -->
											<xsl:for-each select="./conceptList/concept">
												<xsl:apply-templates select="." mode="valueset">
													<xsl:with-param name="language" select="$defaultLanguage" />
												</xsl:apply-templates>
											</xsl:for-each>

											<!-- list allowed null flavors -->
											<xsl:if test="count(./conceptList/exception)>0">
												<xsl:if test="conceptList/concept">
													<tr>
														<td colspan="{$numcolcodes}">
															<hr />
														</td>
													</tr>
												</xsl:if>
												<xsl:for-each select="./conceptList/exception">
													<xsl:apply-templates select="." mode="valueset">
														<xsl:with-param name="language" select="$defaultLanguage" />
													</xsl:apply-templates>
												</xsl:for-each>
												<tr>
													<td colspan="{$numcolcodes}">&#160;</td>
												</tr>
											</xsl:if>
										</table>
									</td>
								</tr>
							</xsl:if>

							<!-- Print legenda line -->
							<tr class="desclabel">
								<td colspan="{$numcol}">
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'CodeSystemLegendaLine'" />
									</xsl:call-template>
								</td>
							</tr>

							<!-- if rest URIs are defined show them for download hier -->
							<xsl:if test="count($projectRestURIs)>0">
								<tr>
									<td colspan="{$numcol}">
										<table width="100%" border="0" cellspacing="3" cellpadding="2">
											<td width="50px">
												<xsl:call-template name="showIcon">
													<xsl:with-param name="which">
														download
													</xsl:with-param>
													<xsl:with-param name="tooltip" select="'Download'" />
												</xsl:call-template>
											</td>
											<td class="tabtab" align="left">
												<xsl:for-each select="$projectRestURIs[@for='VS']">
													<xsl:variable name="temp1" select="replace(text(), '__PFX__', $projectPrefix)" />
													<xsl:variable name="temp2" select="replace($temp1, '__LANG__', $defaultLanguage)" />
													<xsl:variable name="temp3" select="replace($temp2, '__ID__', $vsid)" />
													<xsl:variable name="theHref" select="replace($temp3, '__ED__', string($vsed))" />
													<a>
														<xsl:attribute name="href" select="$theHref" />
														<xsl:value-of select="@format" />
													</a>
													<xsl:text>&#160;</xsl:text>
												</xsl:for-each>
											</td>
										</table>
									</td>
								</tr>
							</xsl:if>

							<!-- Summarize other versions of this valueSet -->
							<xsl:if test="$showOtherVersionsList=true()">
								<xsl:if test="count($allValueSets/*/valueSet[@name=$vsname or @id=$vsid])>1">
									<xsl:variable name="effd" select="@effectiveDate" />
									<tr>
										<td colspan="{$numcol}">&#160;</td>
									</tr>
									<tr>
										<th align="left" colspan="{$numcol}">
											<xsl:call-template name="getMessage">
												<xsl:with-param name="key" select="'OtherVersionsOfThisValueSet'" />
											</xsl:call-template>
										</th>
									</tr>
									<tr>
										<td colspan="{$numcol}">
											<ul>
												<xsl:for-each select="$allValueSets/*/valueSet[@name=$vsname or @id=$vsid]">
													<xsl:sort select="@effectiveDate" order="descending" />
													<xsl:if test="@effectiveDate != $effd">
														<li>
															<xsl:value-of select="@name" />
															<xsl:text>&#160;</xsl:text>
															<xsl:if test="@versionLabel">
																<xsl:value-of select="@versionLabel" />
																<xsl:text> - </xsl:text>
															</xsl:if>
															<xsl:call-template name="showDate">
																<xsl:with-param name="date" select="@effectiveDate" />
															</xsl:call-template>
														</li>
													</xsl:if>
												</xsl:for-each>
											</ul>
										</td>
									</tr>
								</xsl:if>
							</xsl:if>

						</tbody>
					</table>
				</td>
			</tr>
		</table>
	</xsl:template>

	<xsl:template name="getAnchorName">
		<!-- build an HTML anchor that is unique AND stable over multiple builds. Don't include # so we can reuse for href too -->
		<!-- Dataset concepts: id + effectiveTime -->
		<!-- Template elements: id -->
		<xsl:param name="id" required="yes" />
		<xsl:param name="effectiveDate" required="no" />
		<xsl:param name="status" required="no" />

		<xsl:call-template name="doShorthandId">
			<xsl:with-param name="id" select="$id" />
		</xsl:call-template>
		<xsl:if test="string-length(string($effectiveDate[last()]))&gt;0">
			<xsl:text>_</xsl:text>
			<xsl:value-of select="replace(string($effectiveDate[last()]),'-|T|:','')" />
		</xsl:if>
		<xsl:if test="string-length($status)&gt;0">
			<xsl:text>_</xsl:text>
			<xsl:value-of select="$status" />
		</xsl:if>
	</xsl:template>

	<xsl:template name="doShorthandId">
		<xsl:param name="id" />
		<!-- show an OID, replace shorthand id's of the project of possible -->

		<xsl:if test="count($id)&gt;1">
			<xsl:call-template name="logMessage">
				<xsl:with-param name="level" select="$logINFO" />
				<xsl:with-param name="msg">
					<xsl:text>+++ technical problem in DECOR2html.xsl. doShortHandId got multiple ids '</xsl:text>
					<xsl:value-of select="$id" />
					<xsl:text>'</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:variable name="allbids">
			<xsl:for-each select="$allBaseIDs">
				<xsl:sort select="string-length(@id)" order="descending" />
				<xsl:if test="matches(string($id), concat('^', @id, '.'))">
					<bid id="{@id}" prefix="{@prefix}" />
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>

		<xsl:choose>

			<xsl:when test="string-length(($allbids/bid/@prefix)[1])>0">
				<xsl:variable name="thebidi" select="($allbids/bid/@id)[1]" />
				<xsl:variable name="thebidp" select="($allbids/bid/@prefix)[1]" />
				<span style="color: grey;">
					<xsl:value-of select="$thebidp" />
				</span>
				<xsl:value-of select="replace($id, concat('^', $thebidi, '.'), '')" />
			</xsl:when>

			<xsl:when test="matches(string($id), concat('^', $projectId, '.77.2'))">
				<span style="color: grey;">
					<xsl:value-of select="concat($projectPrefix, 'concept-')" />
				</span>
				<xsl:value-of select="replace($id, concat('^', $projectId, '.77.2.'), '')" />
			</xsl:when>

			<xsl:when test="matches(string($id), concat('^', $projectId))">
				<span style="color: grey;">
					<xsl:value-of select="$projectPrefix" />
				</span>
				<xsl:value-of select="replace($id, concat('^', $projectId, '.'), '')" />
			</xsl:when>

			<xsl:otherwise>
				<xsl:value-of select="$id" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="check4Issue">
		<xsl:param name="id" />
		<xsl:param name="colspans" />

		<xsl:variable name="cis" select="count($allIssues/issue/object[@id=$id])" />

		<xsl:if test="$cis>0">

			<!-- from all issue status codes: new open inprogress feedback closed rejected deferred cancelled issues where no immediate action is required ("closed") are: closed rejected cancelled and "open" issues 
				are: new open inprogress feedback deferred -->

			<xsl:variable name="statuscd">
				<xsl:for-each select="$allIssues/issue[object[@id=$id]]">
					<xsl:text>&#160;</xsl:text>
					<xsl:value-of select="(tracking[@effectiveDate=max(parent::issue/tracking/xs:dateTime(@effectiveDate))]/@statusCode)[last()]" />
					<xsl:text>&#160;</xsl:text>
				</xsl:for-each>
			</xsl:variable>

			<xsl:if test="matches(string($statuscd), '(new|open|inprogress|feedback|deferred)')">
				<tr valign="top">
					<td align="center">
						<xsl:call-template name="showIcon">
							<xsl:with-param name="which">
								notice
							</xsl:with-param>
						</xsl:call-template>
					</td>
					<td>
						<xsl:if test="$colspans>1">
							<xsl:attribute name="colspan" select="$colspans" />
						</xsl:if>
						<xsl:choose>
							<xsl:when test="$cis=1">
								<xsl:call-template name="getMessage">
									<xsl:with-param name="key" select="'ThereIsAnOpenIssueWithThisItem'" />
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="getMessage">
									<xsl:with-param name="key" select="'ThereAreOpenIssuesWithThisItem'" />
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
						<ul>
							<xsl:for-each select="$allIssues/issue[object[@id=$id]]">
								<li>
									<a href="iss-{@id}.html" target="_blank">
										<xsl:call-template name="doShorthandId">
											<xsl:with-param name="id" select="@id" />
										</xsl:call-template>
									</a>
									<xsl:text>: </xsl:text>
									<i>
										<xsl:value-of select="@displayName" />
									</i>
									<xsl:text> (</xsl:text>
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key"
											select="concat('IssueStatusCodeLifeCycle-', 
                                            (tracking[@effectiveDate=max(parent::issue/tracking/xs:dateTime(@effectiveDate))]/@statusCode)[last()])" />
									</xsl:call-template>
									<xsl:text>)</xsl:text>
								</li>
							</xsl:for-each>
						</ul>
					</td>
				</tr>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template name="doMessage">
		<xsl:param name="level" select="'error'" />
		<xsl:param name="msg" />
		<!-- show message msg as an info, warning or error context: a table row within a <table> -->

		<xsl:if test="string-length($msg)>0">
			<xsl:choose>
				<xsl:when test="$level='info'">
					<tr>
						<td valign="top">
							<xsl:call-template name="showIcon">
								<xsl:with-param name="which">
									info
								</xsl:with-param>
							</xsl:call-template>
						</td>
						<td valign="top">
							<span style="color: #99CCFF;">
								<strong>
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'infoWord'" />
									</xsl:call-template>
									<xsl:text>: </xsl:text>
									<xsl:value-of select="$msg" />
								</strong>
							</span>
						</td>
					</tr>
				</xsl:when>
				<xsl:when test="$level='warning'">
					<tr>
						<td valign="top">
							<xsl:call-template name="showIcon">
								<xsl:with-param name="which">
									notice
								</xsl:with-param>
							</xsl:call-template>
						</td>
						<td valign="top">
							<span style="color: orange;">
								<strong>
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'warningWord'" />
									</xsl:call-template>
									<xsl:text>: </xsl:text>
									<xsl:value-of select="$msg" />
								</strong>
							</span>
						</td>
					</tr>
				</xsl:when>
				<xsl:when test="$level='issue'">
					<tr>
						<td valign="top">
							<xsl:call-template name="showIcon">
								<xsl:with-param name="which">
									notice
								</xsl:with-param>
							</xsl:call-template>
						</td>
						<td valign="top">
							<span style="color: orange;">
								<strong>
									<xsl:value-of select="$msg" />
								</strong>
							</span>
						</td>
					</tr>
				</xsl:when>
				<xsl:otherwise>
					<!-- handle this as an error -->
					<tr>
						<td valign="top">
							<xsl:call-template name="showIcon">
								<xsl:with-param name="which">
									alert
								</xsl:with-param>
							</xsl:call-template>
						</td>
						<td valign="top">
							<span style="color: red;">
								<strong>
									<xsl:call-template name="getMessage">
										<xsl:with-param name="key" select="'errorWord'" />
									</xsl:call-template>
									<xsl:text>: </xsl:text>
									<xsl:value-of select="$msg" />
								</strong>
							</span>
						</td>
					</tr>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>

	</xsl:template>

	<xsl:template name="doCardConf">
		<xsl:param name="minimumMultiplicity" />
		<xsl:param name="maximumMultiplicity" />
		<xsl:param name="isMandatory" />
		<xsl:param name="conformance" />

		<xsl:value-of select="$minimumMultiplicity" />
		<xsl:if test="string-length(concat($minimumMultiplicity, $maximumMultiplicity))>0">
			<xsl:text>&#160;..&#160;</xsl:text>
		</xsl:if>
		<xsl:value-of select="$maximumMultiplicity" />

		<xsl:if test="string-length($conformance)>0">
			<xsl:if test="string-length(concat($minimumMultiplicity, $maximumMultiplicity))>0">
				<xsl:text>&#160;</xsl:text>
			</xsl:if>
			<!-- TODO: work on facets like NP not present, etc. -->
			<xsl:call-template name="getXFormsLabel">
				<xsl:with-param name="simpleTypeKey" select="'ConformanceType'" />
				<xsl:with-param name="lang" select="$defaultLanguage" />
				<xsl:with-param name="simpleTypeValue" select="$conformance" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="$isMandatory='true'">
			<xsl:if test="string-length(concat($minimumMultiplicity, $maximumMultiplicity, $conformance))>0">
				<xsl:text>&#160;</xsl:text>
			</xsl:if>
			<xsl:call-template name="getMessage">
				<xsl:with-param name="key" select="'conformanceMandatory'" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template name="showIssueType">
		<xsl:param name="it" />
		<xsl:choose>
			<xsl:when test="$it='INC'">
				<xsl:call-template name="getMessage">
					<xsl:with-param name="key" select="'issueTypeINC'" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$it='RFC'">
				<xsl:call-template name="getMessage">
					<xsl:with-param name="key" select="'issueTypeRFC'" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$it='CLF'">
				<xsl:call-template name="getMessage">
					<xsl:with-param name="key" select="'issueTypeCLF'" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$it='FUT'">
				<xsl:call-template name="getMessage">
					<xsl:with-param name="key" select="'issueTypeFUT'" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$it" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="outputPath">
		<xsl:param name="pathname" />
		<xsl:variable name="hasawhere" select="contains($pathname, '[')" />
		<xsl:if test="$hasawhere">
			<tt>
				<strong>
					<xsl:value-of select="substring-before($pathname, '[')" />
				</strong>
			</tt>
			<br />
			<xsl:call-template name="getMessage">
				<xsl:with-param name="key" select="'whereX'" />
			</xsl:call-template>
			<br />
		</xsl:if>
		<!-- split up pathnames concatenated with | (or) and output them seperately -->
		<xsl:variable name="x">
			<xsl:call-template name="tokenize">
				<xsl:with-param name="string">
					<xsl:value-of select="$pathname" />
				</xsl:with-param>
				<xsl:with-param name="delimiters">
					<xsl:value-of select="string('|')" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:for-each select="$x/token">
			<xsl:if test="count(preceding-sibling::node())">
				<xsl:call-template name="getMessage">
					<xsl:with-param name="key" select="'orY'" />
				</xsl:call-template>
				<br />
			</xsl:if>
			<xsl:choose>
				<xsl:when test="$hasawhere">
					<i>
						<xsl:variable name="thep">
							<xsl:call-template name="splitString">
								<xsl:with-param name="str" select="substring(., string-length(substring-before(., '['))+1)" />
								<xsl:with-param name="del" select="string('/')" />
								<xsl:with-param name="preceedIndent" select="string('_')" />
							</xsl:call-template>
						</xsl:variable>
						<xsl:value-of select="replace($thep, '\[', ' [')" />
					</i>
				</xsl:when>
				<xsl:otherwise>
					<tt>
						<strong>
							<xsl:call-template name="splitString">
								<xsl:with-param name="str" select="." />
								<xsl:with-param name="del" select="string('/')" />
								<xsl:with-param name="preceedIndent" select="string('_')" />
							</xsl:call-template>
						</strong>
					</tt>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>

	</xsl:template>

	<xsl:template name="addAssetsHeader">

		<link href="{$theAssetsDir}decor.css" rel="stylesheet" type="text/css" />
		<link href="{$theAssetsDir}favicon.ico" rel="shortcut icon" type="image/x-icon" />

		<script type="text/javascript" src="{$theAssetsDir}motoggle.js">
		</script>
		<script src="{$theAssetsDir}mootools-core.js" type="text/javascript" />
		<script src="{$theAssetsDir}mootools-more.js" type="text/javascript" />
		<script src="{$theAssetsDir}mootools-TabSwapper.js" type="text/javascript" />

	</xsl:template>

	<xsl:template name="addAssetsBottom">

		<script type="text/javascript">
			function RefreshAccordion (theAccId) {
			new Fx.Accordion($(theAccId), '#' + theAccId + ' .AccordionPanelTab', '#' + theAccId + ' .AccordionPanelContent', {
			display: -1,
			alwaysHide: true
			});
			};
			window.addEvent('domready', function(){
			// init accordions
			// Accordionds Accordionsi Accordionsc Accordionvs Accordionid Accordionrl Accordionis Accordionce

			RefreshAccordion('Accordionds');
			RefreshAccordion('Accordionsi');
			RefreshAccordion('Accordionsc');
			RefreshAccordion('Accordionvs');
			RefreshAccordion('Accordionid');
			RefreshAccordion('Accordionrl');
			RefreshAccordion('Accordionis');
			RefreshAccordion('Accordionce');
			//2DO: schematron zip met xhr HEAD
			});
		</script>
		<script type="text/javascript">
			/* init all tooltips */
			//store titles and text
			$$('a.tipz').each(function(element,index) {
			var content = element.get('title').split('::');
			element.store('tip:title', content[0]);
			element.store('tip:text', content[1]);
			});

			//create the tooltips
			var tipz = new Tips('.tipz',{
			className: 'tip',
			fixed: true,
			hideDelay: 50,
			showDelay: 50
			});
		</script>

	</xsl:template>

	<!-- OID registry templates (iEHR.eu extension) -->

	<xsl:template name="showOidRegistryStatusDot">
		<xsl:param name="status" />
		<xsl:variable name="size" select="'20px'" />
		<xsl:variable name="imgprefix" select="$theAssetsDir" />
		<img>
			<xsl:choose>
				<xsl:when test="$status='pending'">
					<xsl:attribute name="src" select="concat($imgprefix, 'kyellow.png')" />
				</xsl:when>
				<xsl:when test="$status='completed'">
					<xsl:attribute name="src" select="concat($imgprefix, 'kgreen.png')" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="src" select="concat($imgprefix, 'kred.png')" />
				</xsl:otherwise>
			</xsl:choose>
			<xsl:attribute name="class" select="'tipsz'" />
			<xsl:attribute name="title" select="$status" />
		</img>
	</xsl:template>
	
	<xsl:template name="showOidRegistryIndent">
        <xsl:param name="oid"/>
        <xsl:variable name="oidPartsCount" select="count(tokenize($oid,'\.'))"/>
        <xsl:for-each select="1 to ($indentSize * ($oidPartsCount - $rootOidPartsCount))">
            <xsl:value-of select="'&#160;'"/>
        </xsl:for-each>
    </xsl:template>

	<xsl:template match="myoidregistry">
		<h1>
			<xsl:value-of select="@name" />
		</h1>
		<xsl:apply-templates select="registry" />
	</xsl:template>

	<xsl:template match="registry">
		<h2>
			<xsl:value-of select="description[@language=$defaultLanguage]/@value" />
		</h2>
		<table class="oid-registry">
			<xsl:for-each select="oid">
				<xsl:apply-templates select="." />
			</xsl:for-each>
		</table>
	</xsl:template>

	<xsl:template match="oid">
		<tr>
			<td>
				<xsl:call-template name="showOidRegistryIndent">
					<xsl:with-param name="oid" select="dotNotation/@value"/>
				</xsl:call-template>
				<xsl:call-template name="showOidRegistryStatusDot">
					<xsl:with-param name="status" select="status/@code" />
				</xsl:call-template>
				<xsl:value-of select="'&#160;'"/>
				<xsl:value-of select="dotNotation/@value" />
			</td>
			<td>
				<xsl:value-of select="category/@code" />
			</td>
			<td>
				<xsl:value-of select="description[@language=$defaultLanguage]/@value" />
			</td>
		</tr>
	</xsl:template>
	
	<!-- ClaML templates (iEHR.eu extension) -->
	<xsl:template name="showDictionaryIndent">
        <xsl:param name="level"/>
        <xsl:for-each select="1 to ($indentSize * $level)">
            <xsl:value-of select="'&#160;'"/>
        </xsl:for-each>
    </xsl:template>
	
	<xsl:template match="ClaML">
		<table class="dictionary">
			<xsl:apply-templates select="//Class[not(SuperClass)]">
				<xsl:with-param name="level" select="1"/>
			</xsl:apply-templates>
		</table>
	</xsl:template>
	
	<xsl:template match="Class">
		<xsl:param name="level"/>
		<tr>
			<td>
				<xsl:call-template name="showDictionaryIndent">
					<xsl:with-param name="level" select="$level"/>
				</xsl:call-template>
				<xsl:value-of select="@code"/>
			</td>
			<td>
				<xsl:value-of select="Rubric[@kind='preferred']/Label/text()"/>
			</td>
		</tr>
		<xsl:apply-templates select="../Class[SuperClass/@code=current()/@code]">
			<xsl:with-param name="level" select="$level+1"/>
		</xsl:apply-templates>
	</xsl:template>

</xsl:stylesheet>
