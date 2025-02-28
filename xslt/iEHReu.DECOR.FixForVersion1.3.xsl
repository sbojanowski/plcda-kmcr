<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ffv13="urn:hitinn.eu:ffv13"
    xmlns:cda="urn:hl7-org:v3"
    exclude-result-prefixes="xs"
    version="2.0">

    <xsl:output method="xml" indent="yes"/>
   
    <xsl:variable name="ROOT_PATH" select="concat(string-join(tokenize(base-uri(),'/')[position()&lt;last()],'/'),'/')"/>
    <xsl:variable name="ROOT_TEMPLATE_ID" select="'2.16.840.1.113883.3.4424.13.10'"/>
    <xsl:variable name="EXAMPLES_INDEX_PATH" select="concat($ROOT_PATH,'examples/')"/>
    <xsl:variable name="EXAMPLES_INDEX_FILE" select="concat($ROOT_PATH,'examples/index.xml')"/>
    <xsl:variable name="CURRENT_EFFECTIVE_DATE" select="'2018-06-30T00:00:00'"/>
    <xsl:variable name="CURRENT_VERSION_LABEL" select="'1.3'"/>
    <xsl:variable name="ROOT" select="/"/>
   
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
    
    <xsl:function name="ffv13:isUsed">
        <xsl:param name="templateName"/>
        <xsl:variable name="templateId" select="$ROOT//template[@name=$templateName]/@id"/>
        <xsl:choose>
            <xsl:when test="$ROOT//template[@statusCode!='retired' and (.//include[@ref=($templateName,$templateId)] or .//element[@contains=($templateName,$templateId)])]">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when test="$ROOT//template[@statusCode!='retired' and relationship[@template=$templateId]]">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when test="$ROOT//scenario//representingTemplate[@ref=$templateId]">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    
    <xsl:function name="ffv13:getDocumentLevelContainingTemplates">
        <xsl:param name="templateId"/>
        <xsl:variable name="templateName" select="$ROOT//template[@id=$templateId]/@name"/>
        <xsl:choose>
            <xsl:when test="$ROOT//template[@id=$templateId]/classification/@type='cdadocumentlevel'">
                <documentTemplate><xsl:value-of select="$templateId"/></documentTemplate>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$ROOT//template[.//include[@ref=($templateName,$templateId)] or .//element[@contains=($templateName,$templateId)]]">            
                    <xsl:choose>
                        <xsl:when test="classification/@type='cdadocumentlevel'">
                            <documentTemplate><xsl:value-of select="(xs:string(@id))"/></documentTemplate>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="ffv13:getDocumentLevelContainingTemplates(@id)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>        
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="ffv13:getContentFromExampleFiles">
        <xsl:param name="templateId"/>
        <xsl:param name="exampleFiles"/>
        <xsl:param name="getAll"/>
        <xsl:param name="index"/>
        <xsl:if test="$exampleFiles[$index]">
            <xsl:variable name="filePath" select="concat($EXAMPLES_INDEX_PATH,$exampleFiles[$index])"/>
            <xsl:if test="doc-available($filePath)">
                <xsl:variable name="fileElement" select="doc($filePath)//cda:*[cda:templateId[@root=$templateId]][1]"/>
                <xsl:choose>
                    <xsl:when test="$fileElement">
                        <example>
                            <xsl:copy-of select="$fileElement"/>
                        </example>
                        <xsl:if test="$getAll">
                            <xsl:copy-of select="ffv13:getContentFromExampleFiles($templateId,$exampleFiles,$getAll,$index+1)"/>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="ffv13:getContentFromExampleFiles($templateId,$exampleFiles,$getAll,$index+1)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:if>
    </xsl:function>
    
    
    <xsl:template name="getExample">
        <xsl:param name="templateId"/>
        <xsl:param name="containingTemplates" select="distinct-values(ffv13:getDocumentLevelContainingTemplates($templateId))"/>
        <xsl:param name="index" select="1"/>
        
        <xsl:variable name="currentTemplate" select="$containingTemplates[$index]"/>
        
        <xsl:if test="$currentTemplate">
            <xsl:variable name="exampleFiles" select="$EXAMPLES_INDEX//template[@id=$currentTemplate]/example/@file"/>
            <xsl:variable name="getAll" select="$ROOT//template[@id=$templateId]/classification/@type='cdadocumentlevel'"/>
            <xsl:variable name="examples" select="ffv13:getContentFromExampleFiles($templateId,$exampleFiles,$getAll,1)"/>
            
            <xsl:choose>
                <xsl:when test="$examples">
                    <xsl:copy-of select="$examples"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="getExample">
                        <xsl:with-param name="templateId" select="$templateId"/>
                        <xsl:with-param name="containingTemplates" select="$containingTemplates"/>
                        <xsl:with-param name="index" select="$index+1"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose> 
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
        <xsl:copy-of select="."/>
    </xsl:template>
    
    
    <!-- Obsolete templateId removal and proper predication fix -->
    <xsl:template match="element[matches(@name,'^([a-zA-Z0-9]+):templateId')]">
        <xsl:param name="isMainTemplate" select="false()"/>
        <xsl:variable name="externalTemplateIdCount" select="count(parent::*/element[matches(@name,'^([a-zA-Z0-9]+):templateId') and not(contains(./attribute[@name='root']/@value,$ROOT_TEMPLATE_ID))])"/>
        <xsl:if test="not(contains(./attribute[@name='root']/@value,$ROOT_TEMPLATE_ID)) or $isMainTemplate=true()">
            <xsl:choose>
                <xsl:when test="$externalTemplateIdCount=0">
                    <xsl:element name="element">
                        <xsl:copy-of select="./@*"/>
                        <xsl:apply-templates select="./*"/>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="$externalTemplateIdCount&gt;0">
                    <xsl:choose>
                        <xsl:when test="not(matches(./@name,'^([a-zA-Z0-9]+):templateId(\[@root=.([0-9]+\.)+[0-9]+.\])'))">
                            <xsl:element name="element">
                                <xsl:attribute name="name">
                                    <xsl:value-of select="./@name"/>
                                    <xsl:text>[@root='</xsl:text>
                                    <xsl:value-of select="./attribute[@name='root']/@value"/>
                                    <xsl:text>']</xsl:text>
                                </xsl:attribute>
                                <xsl:copy-of select="./@*[name()!='name']"/>
                                <xsl:apply-templates select="./*"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Do nothing -->
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    <!-- // -->
    
    <xsl:template match="element[not(@contains) and not(matches(@name,'^([a-zA-Z0-9]+):templateId'))]">
       <xsl:element name="element">
           <xsl:copy-of select="./@*"/>
           <xsl:call-template name="processElement">
               <xsl:with-param name="rootNode" select="."/>
           </xsl:call-template>
        </xsl:element>
    </xsl:template>
    
    <!-- Conversion of name to id references fix -->
    <xsl:template match="element[@contains]">
        <xsl:variable name="templateId">
            <xsl:choose>
                <xsl:when test="not(contains(xs:string(@contains), $ROOT_TEMPLATE_ID))">
                    <xsl:value-of select="//template[@name=current()/@contains]/@id"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@contains"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:element name="element">
            <xsl:copy-of select="./@*[name()!='contains']"/>
            <xsl:attribute name="contains" select="$templateId"/>
            <xsl:call-template name="processElement">
                <xsl:with-param name="rootNode" select="."/>
            </xsl:call-template>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="include">
        <xsl:choose>
            <xsl:when test="not(contains(xs:string(@ref),$ROOT_TEMPLATE_ID))">
                <xsl:variable name="templateId" select="//template[@name=current()/@ref]/@id"/>
                <xsl:element name="include">
                    <xsl:attribute name="ref" select="$templateId"/>
                    <xsl:copy-of select="./@*[name()!='ref']"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- // -->
    
    <xsl:template match="attribute">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="assert">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="report">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="let">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="choice">
        <xsl:element name="choice">
            <xsl:copy-of select="./@*"/>
            <xsl:apply-templates select="./*"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="vocabulary">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="text">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="desc">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="classification">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="relationship">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="context">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="example">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    
    <xsl:template name="processElement">
        <xsl:param name="rootNode"/>
        
        <!--<xsl:variable name="templateName" select="$rootNode/ancestor::template/@name"/>
        <xsl:variable name="sameElementCount" select="count($rootNode/parent::*/element[not(@contains) and @name=$rootNode/@name])"/>
        <xsl:if test="ffv13:isUsed($templateName) and $sameElementCount>1">
            <xsl:message>
                <xsl:text>Warning: Multiple elements with the same name '</xsl:text>
                <xsl:value-of select="$rootNode/@name"/>
                <xsl:text>' in template '</xsl:text>
                <xsl:value-of select="$templateName"/>
                <xsl:text>'.</xsl:text>
            </xsl:message>
        </xsl:if>-->
        
        <xsl:choose>
            <xsl:when test="$rootNode/element[matches(@name,'^([a-zA-Z0-9]+):templateId')]">
                <xsl:call-template name="reorderTemplateIdNodes">
                    <xsl:with-param name="rootNode" select="$rootNode"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="./*"/>    
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="reorderTemplateIdNodes">
        <xsl:param name="rootNode"/>
        <xsl:variable name="firstTemplateIdNodeId" select="generate-id($rootNode/element[matches(@name,'^([a-zA-Z0-9]+):templateId')][1])"/>
        <xsl:choose>
            <xsl:when test="$firstTemplateIdNodeId">
                <xsl:variable name="lastTemplateIdNodeId" select="generate-id($rootNode/element[matches(@name,'^([a-zA-Z0-9]+):templateId')][last()])"/>
                <xsl:apply-templates select="$rootNode/*[following-sibling::element/generate-id()=$firstTemplateIdNodeId]"/>
                <xsl:apply-templates select="$rootNode/element[matches(@name,'^([a-zA-Z0-9]+):templateId')][last()]">
                    <xsl:with-param name="isMainTemplate" select="true()"/>
                </xsl:apply-templates>
                <xsl:apply-templates select="$rootNode/*[(self::node()/generate-id()=$firstTemplateIdNodeId or preceding-sibling::element/generate-id()=$firstTemplateIdNodeId) and self::node()/generate-id()!=$lastTemplateIdNodeId]"/>        
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$rootNode/*"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="rules">
        <rules>
            <xsl:for-each select="//template">
                <xsl:comment>
                    <xsl:value-of select="./@name"/>
                    <xsl:text> v</xsl:text>
                    <xsl:value-of select="$CURRENT_VERSION_LABEL"/>
                </xsl:comment>
                <template>
                    
                    <!-- Draft status code fix -->
                    <xsl:attribute name="statusCode">
                        <xsl:choose>
                            <xsl:when test="ffv13:isUsed(@name)=false()">
                                <xsl:text>retired</xsl:text>
                                <xsl:message>
                                    <xsl:text>Unused template found: </xsl:text>
                                    <xsl:value-of select="@name"/>
                                    <xsl:text> - setting statusCode to retired.</xsl:text>
                                </xsl:message>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test="./@statusCode='draft'">
                                        <xsl:text>active</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="./@statusCode"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    
                    <!-- Change effectiveDate and versionLabel fix -->
                    <xsl:attribute name="effectiveDate">
                        <xsl:value-of select="$CURRENT_EFFECTIVE_DATE"/>
                    </xsl:attribute>
                    <xsl:attribute name="versionLabel">
                        <xsl:value-of select="$CURRENT_VERSION_LABEL"/>
                    </xsl:attribute>
                    
                    
                    <xsl:copy-of select="./@*[not(name()=('statusCode','effectiveDate','versionLabel'))]"/>
                    <!-- // -->
                    
                    <!-- Remove old examples fix -->
                    <xsl:apply-templates select="./(desc|classification|relationship)"></xsl:apply-templates>
                    <!-- // -->
                    
                    <!-- Context id/path fix -->
                    <xsl:element name="context">
                        <xsl:choose>
                            <xsl:when test="classification/@type='cdadocumentlevel'">
                                <xsl:attribute name="path" select="'/'"/>
                            </xsl:when>
                            <xsl:when test="count(./(element|attribute|choice|include|assert|report))>1">
                                <xsl:attribute name="id" select="'*'"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="id" select="'**'"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                    
                    <!-- Examples from external files fix -->
                    <xsl:call-template name="getExample">
                        <xsl:with-param name="templateId" select="@id"/>
                    </xsl:call-template>
                    <!-- // -->
                    
                    <!-- First template id replacement fix --> 
                    <xsl:choose>
                        <xsl:when test="count(./(element|attribute|choice|include|assert|report))>1">
                            <xsl:call-template name="reorderTemplateIdNodes">
                                <xsl:with-param name="rootNode" select="."/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:element name="element">    
                                <xsl:copy-of select="./element[1]/@*"/>
                                <xsl:call-template name="reorderTemplateIdNodes">
                                    <xsl:with-param name="rootNode" select="./element[1]"/>
                                </xsl:call-template>
                            </xsl:element>
                        </xsl:otherwise>
                    </xsl:choose>
                    <!-- // -->
                    
                </template>
                                         
            </xsl:for-each>
        </rules>
    </xsl:template>
    

</xsl:stylesheet>