<!-- 
    ART-DECOR® STANDARD COPYRIGHT AND LICENSE NOTE
    Copyright © ART-DECOR Expert Group and ART-DECOR Open Tools GmbH
    see https://docs.art-decor.org/copyright and https://docs.art-decor.org/licenses

    This file is part of the ART-DECOR® tools suite.    
-->
<xsl:stylesheet xmlns:xforms="http://www.w3.org/2002/xforms" xmlns:diff="http://art-decor.org/ns/decor/diff" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:uuid="java:java.util.UUID" xmlns:local="http://art-decor.org/functions" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" exclude-result-prefixes="#all">
    
    <!-- provide a mapping from string logLevel to numeric value -->
    <xsl:variable name="logALL" select="'ALL'"/>
    <xsl:variable name="logDEBUG" select="'DEBUG'"/>
    <xsl:variable name="logINFO" select="'INFO'"/>
    <xsl:variable name="logWARN" select="'WARN'"/>
    <xsl:variable name="logERROR" select="'ERROR'"/>
    <xsl:variable name="logFATAL" select="'FATAL'"/>
    <xsl:variable name="logOFF" select="'OFF'"/>
    <xsl:variable name="logLevelMap">
        <level xmlns="" name="{$logALL}" int="6" desc="The ALL has the lowest possible rank and is intended to turn on all logging."/>
        <level xmlns="" name="{$logDEBUG}" int="5" desc="The DEBUG Level designates fine-grained informational events that are most useful to debug an application."/>
        <level xmlns="" name="{$logINFO}" int="4" desc="The INFO level designates informational messages that highlight the progress of the application at coarse-grained level."/>
        <level xmlns="" name="{$logWARN}" int="3" desc="The WARN level designates potentially harmful situations."/>
        <level xmlns="" name="{$logERROR}" int="2" desc="The ERROR level designates error events that might still allow the application to continue running."/>
        <level xmlns="" name="{$logFATAL}" int="1" desc="The FATAL level designates very severe error events that will presumably lead the application to abort."/>
        <level xmlns="" name="{$logOFF}" int="0" desc="The OFF level has the highest possible rank and is intended to turn off logging."/>
    </xsl:variable>
    <xsl:variable name="chkdLogLevel" select="if (exists($logLevelMap/level[@name=$theLogLevel])) then $theLogLevel else $logINFO"/>
    
    <!-- the all and one art-decor.org website and the sourceforge svn -->
    <xsl:variable name="theARTDECORwebsite" select="'https://assets.art-decor.org'"/>
    <xsl:variable name="theARTDECORsourceforge" select="'https://sourceforge.net/p/artdecor'"/>
    
    <!-- cache full DECOR for resolving generic ids such as object/@id -->
    <xsl:variable xmlns="" name="allDECOR" select="//decor[1] | //decor-excerpt[1]" as="element()?"/>
    
    <!-- cache all ids for later processing -->
    <xsl:variable xmlns="" name="allIDs" select="//ids"/>
    
    <!-- cache all value sets for later processing, sorted descending order -->
    <xsl:variable name="allValueSets">
        <sortedValueSets xmlns="">
            <xsl:for-each select="//terminology/valueSet">
                <xsl:sort select="@name"/>
                <xsl:sort select="@effectiveDate" order="descending"/>
                <xsl:variable name="ref" select="@ref"/>
                <xsl:variable name="name" select="@name"/>
                <xsl:choose>
                    <xsl:when test="@id">
                        <xsl:copy>
                            <xsl:copy-of select="@*"/>
                            <xsl:copy-of select="* except conceptList"/>
                            <!-- print and/or calculate sourceCodeSystems -->
                            <xsl:if test="not(sourceCodeSystem)">
                                
                                <!-- check if sourceCodeSystem is used in this original value set, if not - create them -->
                                <xsl:for-each-group select=".//@codeSystem" group-by=".">
                                    <xsl:variable name="theId" select="."/>
                                    <xsl:variable name="theName">
                                        <xsl:call-template name="getIDDisplayName">
                                            <xsl:with-param name="root" select="$theId"/>
                                        </xsl:call-template>
                                        <!-- TODO: canonicalUri? -->
                                    </xsl:variable>
                                    <sourceCodeSystem id="{$theId}" identifierName="{$theName}"/>
                                </xsl:for-each-group>
                            </xsl:if>
                            <xsl:copy-of select="conceptList"/>
                        </xsl:copy>
                    </xsl:when>
                    <xsl:when test="@ref and not(exists(//terminology/valueSet[@id=$ref]))">
                        <!-- this a reference that could not be resolved, or this project has not been compiled before transform -->
                        <xsl:copy>
                            <xsl:copy-of select="@*"/>
                            <xsl:attribute name="missing" select="'true'"/>
                            <xsl:copy-of select="node()"/>
                        </xsl:copy>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- do not copy valueSet/@ref where valueSet/@id exists (compiled project) -->
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </sortedValueSets>
    </xsl:variable>

    <!-- cache all code systems for later processing, sorted descending order -->
    <xsl:variable name="allCodeSystems">
        <sortedCodeSystems xmlns="">
            <xsl:for-each select="//terminology/codeSystem">
                <xsl:sort select="@name"/>
                <xsl:sort select="@effectiveDate" order="descending"/>
                <xsl:variable name="ref" select="@ref"/>
                <xsl:variable name="name" select="@name"/>
                <codeSystem>
                    <xsl:copy-of select="@*"/>
                    <xsl:copy-of select="*"/>
                </codeSystem>
            </xsl:for-each>
        </sortedCodeSystems>
    </xsl:variable>
    
    <!-- cache all conceptmaps for later processing, sorted descending order -->
    <xsl:variable name="allConceptMaps" as="element(conceptMap)*">
        <xsl:for-each select="//terminology/conceptMap">
            <xsl:sort select="@displayName"/>
            <xsl:sort select="@effectiveDate" order="descending"/>
            <xsl:variable name="ref" select="@ref"/>
            <xsl:variable name="name" select="@displayName"/>
            <xsl:copy-of select="."/>
        </xsl:for-each>
    </xsl:variable>
    
    <!-- cache all terminology associations for later processing -->
    <xsl:variable name="allTerminologyAssociations">
        <terminologyAssociations xmlns="">
            <xsl:for-each select="//terminology/terminologyAssociation">
                <xsl:copy-of select="."/>
            </xsl:for-each>
        </terminologyAssociations>
    </xsl:variable>

    <!-- cache all base id of the project for later processing -->
    <xsl:variable xmlns="" name="allBaseIDs" select="//ids/baseId"/>

    <!-- cache all concepts for later processing -->
    <xsl:variable xmlns="" name="allCodedConcepts" select="//codedConcepts"/>

    <!-- cache all scenarios for later processing -->
    <xsl:variable name="allScenarios">
        <scenarios xmlns="">
            <!-- This gets us the declaration for the prefixes namespace::node() doesn't work although it should -->
            <!-- This is important for DECOR-templatefragment2schematron.xsl -->
            <xsl:copy-of select="$allDECOR/@*"/>
            <xsl:for-each-group select="//scenarios/scenario" group-by="@id">
                <xsl:sort select="@effectiveDate" order="descending"/>
                <xsl:copy-of select="."/>
            </xsl:for-each-group>
        </scenarios>
    </xsl:variable>
    
    <!-- cache all actors for later processing -->
    <xsl:variable xmlns="" name="allActors" select="//scenarios/actors"/>

    <!-- source directory for external rule sets -->
    <xsl:variable name="theSourceDir" select="concat($projectPrefix, 'source/')"/>

    <!-- template repository -->
    <xsl:variable name="projectTemplateRepository" select="concat($projectPrefix, 'template-repository.xml')"/>

    <!-- variables to create the output -->

    <!-- current date and time -->
    <xsl:variable name="currentDateTime">
        <xsl:value-of select="dateTime(current-date(), current-time())"/>
    </xsl:variable>
    <!-- time stamp format example 20120112T094340 -->
    <xsl:variable name="theTimeStamp">
        <xsl:choose>
            <xsl:when test="$inDevelopment=true()">
                <xsl:value-of select="'develop'"/>
            </xsl:when>
            <xsl:when test="$useLatestDecorVersion=true()">
                <xsl:value-of select="substring(translate(string($latestVersion), '[-:]', ''), 1, 15)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="substring(translate($currentDateTime, '[-:]', ''), 1, 15)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <!-- get the URL as a prefix for the reference to definitions -->
    <xsl:variable name="seeURLprefix" select="//project/reference/@url"/>

    <!-- get project name -->
    <xsl:variable xmlns="" name="projectName" select="(//project/name)[1]"/>

    <!-- get project id prefix -->
    <xsl:variable name="projectPrefix" select="//project/@prefix | (/*/template/@ident)[1]"/>

    <!-- get project contact email -->
    <xsl:variable name="projectContactEmail" select="//project/contact/@email"/>

    <!-- get project id (oid) -->
    <xsl:variable name="projectId" select="//project/@id"/>

    <!-- get project rest URIs -->
    <xsl:variable xmlns="" name="projectRestURIs" select="//project/restURI"/>
    
    <!-- only allow https:// schema for deep link prefix services -->
    <xsl:variable name="tmpservlink" select="$allDECOR/@deeplinkprefixservices"/>
    <xsl:variable name="deeplinkprefixservices">
        <xsl:choose>
            <xsl:when test="matches($tmpservlink, '^https?://?localhost')">
                <!-- leave localhost link alone -->
                <xsl:value-of select="$tmpservlink"/>
            </xsl:when>
            <xsl:when test="starts-with($tmpservlink, 'http://')">
                <!-- replace http with https -->
                <xsl:value-of select="concat('https://', substring-after($tmpservlink, 'http://'))"/>
            </xsl:when>
            <xsl:when test="starts-with($tmpservlink, 'https://')">
                <!-- link ok -->
                <xsl:value-of select="$tmpservlink"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- otherwise fail -->
                <xsl:value-of select="'DEEP-LINK-PREFIX-FAILURE'"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="not(ends-with($tmpservlink, '/'))">
            <xsl:value-of select="'/'"/>
        </xsl:if>
    </xsl:variable>
    
    <!-- 2023-09-12 added @deeplinkprefixservicesfhir to compilation process, don't just expect it to be there -->
    <xsl:variable name="deeplinkprefixservicesfhir" as="xs:string?">
        <xsl:variable name="theURI" select="$allDECOR/@deeplinkprefixservicesfhir"/>
        <xsl:choose>
            <xsl:when test="matches($theURI, '^https?://?localhost')">
                <!-- leave localhost link alone -->
                <xsl:value-of select="$theURI"/>
            </xsl:when>
            <xsl:when test="starts-with($theURI, 'http://')">
                <!-- replace http with https -->
                <xsl:value-of select="concat('https://', substring-after($theURI, 'http://'))"/>
            </xsl:when>
            <xsl:when test="starts-with($theURI, 'https://')">
                <!-- link ok -->
                <xsl:value-of select="$theURI"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- otherwise fail -->
                <xsl:value-of select="'DEEP-LINK-FHIR-PREFIX-FAILURE'"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="matches($theURI, '.+[^/]$')">
            <xsl:value-of select="'/'"/>
        </xsl:if>
    </xsl:variable>
    
    <!-- get project rest URI for index. Prepare basic parameters and let DECOR2html add id and format -->
    <xsl:variable name="projectRestUri" as="xs:string?">
        <xsl:variable name="theURI">
            <xsl:choose>
                <xsl:when test="$deeplinkprefixservices[string-length() > 0]">
                    <xsl:value-of select="concat($deeplinkprefixservices, 'ProjectIndex')"/>
                </xsl:when>
                <xsl:when test="$projectRestUriDS[string-length() > 0]">
                    <xsl:value-of select="concat(substring-before($projectRestUriDS, 'RetrieveTransaction'), 'ProjectIndex')"/>
                </xsl:when>
                <xsl:when test="$projectRestUriVS[string-length() > 0]">
                    <xsl:value-of select="concat(substring-before($projectRestUriVS, 'RetrieveValueSet'), 'ProjectIndex')"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="string-length($theURI) gt 0">
            <xsl:variable name="theFullURI">
                <xsl:value-of select="$theURI"/>
                <xsl:text>?</xsl:text>
                <xsl:text>prefix=</xsl:text>
                <xsl:value-of select="$projectPrefix"/>
                <xsl:text>&amp;language=</xsl:text>
                <xsl:value-of select="$defaultLanguage"/>
                <xsl:if test="$useLatestDecorVersion">
                    <xsl:text>&amp;version=</xsl:text>
                    <xsl:choose>
                        <xsl:when test="contains($latestVersion, 'develop')">development</xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="encode-for-uri(string($latestVersion))"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
            </xsl:variable>
            <xsl:value-of select="string-join($theFullURI, '')"/>
        </xsl:if>
    </xsl:variable>
    
    <!-- get project rest URI for datasets/transaction. Prepare basic parameters and let DECOR2html add id and format -->
    <xsl:variable name="projectRestUriDS" as="xs:string?">
        <xsl:variable name="theURI">
            <xsl:choose>
                <xsl:when test="$deeplinkprefixservices[string-length() > 0]">
                    <xsl:value-of select="concat($deeplinkprefixservices, 'RetrieveTransaction')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="tokenize($projectRestURIs[@for='DS'][1], '\?')[1]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="string-length($theURI)&gt;0">
            <xsl:variable name="theFullURI">
                <xsl:value-of select="$theURI"/>
                <xsl:text>?</xsl:text>
                <xsl:text>language=</xsl:text>
                <xsl:value-of select="$defaultLanguage"/>
                <xsl:if test="$useLatestDecorVersion">
                    <xsl:text>&amp;version=</xsl:text>
                    <xsl:choose>
                        <xsl:when test="contains($latestVersion, 'develop')">development</xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="encode-for-uri(string($latestVersion))"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
                <xsl:text>&amp;hidecolumns=</xsl:text>
                <xsl:value-of select="$hideColumns"/>
            </xsl:variable>
            <xsl:value-of select="string-join($theFullURI, '')"/>
        </xsl:if>
    </xsl:variable>
    
    <xsl:variable name="projectRestUriDSDiagram" as="xs:string?">
        <xsl:choose>
            <xsl:when test="string-length($projectRestUriDS) > 0">
                <xsl:variable name="theFullURI">
                    <xsl:value-of select="concat(substring-before($projectRestUriDS, 'RetrieveTransaction'), 'RetrieveConceptDiagram')"/>
                    <xsl:text>?</xsl:text>
                    <xsl:text>language=</xsl:text>
                    <xsl:value-of select="$defaultLanguage"/>
                    <xsl:if test="$useLatestDecorVersion">
                        <xsl:text>&amp;version=</xsl:text>
                        <xsl:choose>
                            <xsl:when test="contains($latestVersion, 'develop')">development</xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="encode-for-uri(string($latestVersion))"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                </xsl:variable>
                <xsl:value-of select="string-join($theFullURI, '')"/>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>
    
    <!-- get project rest URI for terminology/valueSet. TODO: rewrite logic so it becomes more like above -->
    <xsl:variable name="projectRestUriVS" as="xs:string?">
        <xsl:variable name="theURI">
            <xsl:choose>
                <xsl:when test="$deeplinkprefixservices[string-length() > 0]">
                    <xsl:value-of select="concat($deeplinkprefixservices, 'RetrieveValueSet')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="tokenize($projectRestURIs[@for='VS'][@format='XML'][1], '\?')[1]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="string-length($theURI)&gt;0">
            <xsl:variable name="theFullURI">
                <xsl:value-of select="$theURI"/>
                <xsl:text>?</xsl:text>
                <xsl:text>prefix=</xsl:text>
                <xsl:value-of select="$projectPrefix"/>
                <xsl:text>&amp;language=</xsl:text>
                <xsl:value-of select="$defaultLanguage"/>
                <xsl:if test="$useLatestDecorVersion">
                    <xsl:text>&amp;version=</xsl:text>
                    <xsl:choose>
                        <xsl:when test="contains($latestVersion, 'develop')">development</xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="encode-for-uri(string($latestVersion))"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
            </xsl:variable>
            <xsl:value-of select="string-join($theFullURI, '')"/>
        </xsl:if>
    </xsl:variable>
    
    <!-- get project rest URI for terminology/valueSet. TODO: rewrite logic so it becomes more like above -->
    <xsl:variable name="projectRestUriCS" as="xs:string?">
        <xsl:variable name="theURI">
            <xsl:choose>
                <xsl:when test="$deeplinkprefixservices[string-length() > 0]">
                    <xsl:value-of select="concat($deeplinkprefixservices, 'RetrieveCodeSystem')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="tokenize($projectRestURIs[@for='CS'][@format='XML'][1], '\?')[1]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="string-length($theURI)&gt;0">
            <xsl:variable name="theFullURI">
                <xsl:value-of select="$theURI"/>
                <xsl:text>?</xsl:text>
                <xsl:text>prefix=</xsl:text>
                <xsl:value-of select="$projectPrefix"/>
                <xsl:text>&amp;language=</xsl:text>
                <xsl:value-of select="$defaultLanguage"/>
                <xsl:if test="$useLatestDecorVersion">
                    <xsl:text>&amp;version=</xsl:text>
                    <xsl:choose>
                        <xsl:when test="contains($latestVersion, 'develop')">development</xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="encode-for-uri(string($latestVersion))"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
            </xsl:variable>
            <xsl:value-of select="string-join($theFullURI, '')"/>
        </xsl:if>
    </xsl:variable>
    
    <!-- get project rest URI for terminology/conceptMap. TODO: rewrite logic so it becomes more like above -->
    <xsl:variable name="projectRestUriMP" as="xs:string?">
        <xsl:variable name="theURI">
            <xsl:choose>
                <xsl:when test="$deeplinkprefixservices[string-length() &gt; 0]">
                    <xsl:value-of select="concat($deeplinkprefixservices, 'RetrieveConceptMap')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="tokenize($projectRestURIs[@for='MP'][@format='XML'][1], '\?')[1]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="string-length($theURI)&gt;0">
            <xsl:variable name="theFullURI">
                <xsl:value-of select="$theURI"/>
                <xsl:text>?</xsl:text>
                <xsl:text>prefix=</xsl:text>
                <xsl:value-of select="$projectPrefix"/>
                <xsl:text>&amp;language=</xsl:text>
                <xsl:value-of select="$defaultLanguage"/>
                <xsl:if test="$useLatestDecorVersion">
                    <xsl:text>&amp;version=</xsl:text>
                    <xsl:choose>
                        <xsl:when test="contains($latestVersion, 'develop')">development</xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="encode-for-uri(string($latestVersion))"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
            </xsl:variable>
            <xsl:value-of select="string-join($theFullURI, '')"/>
        </xsl:if>
    </xsl:variable>
    
    <!-- get project rest URI for FHIR. Prepare basic endpoint URI
            2023-09-12 added @deeplinkprefixservicesfhir to compilation process, don't just expect it to be there -->
    <xsl:template name="projectRestUriFHIR" as="xs:string?">
        <xsl:variable name="theInitialURI">
            <xsl:choose>
                <xsl:when test="matches($deeplinkprefixservicesfhir, '^https?://?localhost')">
                    <xsl:value-of select="$deeplinkprefixservicesfhir"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="replace((., $deeplinkprefixservicesfhir)[string-length() gt 0][1], 'http://', 'https://')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="theURI">
            <xsl:value-of select="$theInitialURI"/>
            <xsl:if test="not(ends-with($theInitialURI, '/'))">
                <xsl:text>/</xsl:text>
            </xsl:if>
            <xsl:if test="not(matches($theInitialURI, concat(@format, '/?$')))">
                <xsl:value-of select="@format"/>
                <xsl:text>/</xsl:text>
            </xsl:if>
            <xsl:value-of select="$projectPrefix"/>
            <xsl:if test="$useLatestDecorVersion">
                <xsl:choose>
                    <xsl:when test="contains($latestVersion, 'develop')">development</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="replace(string($latestVersion), '[^\d]', '')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            <xsl:text>/</xsl:text>
        </xsl:variable>
        <xsl:value-of select="string-join($theURI,'')"/>
    </xsl:template>
    <xsl:variable name="projectRestUriFHIR" as="element(restURI)*">
        <xsl:for-each select="$projectRestURIs[@for='FHIR'][string-length(.) gt 0] |
            $projectRestURIs[@for='FHIR'][string-length(.) = 0][string-length($deeplinkprefixservicesfhir) gt 0]">
            <restURI>
                <xsl:copy-of select="@*"/>
                <xsl:call-template name="projectRestUriFHIR"/>
            </restURI>
        </xsl:for-each>
    </xsl:variable>
    
    <!-- get project default element namespace -->
    <xsl:variable name="projectDefaultElementPrefix">
        <xsl:choose>
            <xsl:when test="string-length(//project/defaultElementNamespace/@ns)&gt;0">
                <xsl:value-of select="//project/defaultElementNamespace/@ns"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- guess the default: hl7: -->
                <xsl:text>hl7:</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <!-- get project default element namespace -->
    <xsl:variable name="projectDefaultElementNamespace">
        <xsl:variable name="prefix" select="replace($projectDefaultElementPrefix,':','')"/>
        <xsl:variable name="ns" select="namespace-uri-for-prefix($prefix,$allDECOR)"/>
        <xsl:choose>
            <xsl:when test="string-length($ns)&gt;0">
                <xsl:value-of select="$ns"/>
            </xsl:when>
            <xsl:when test="$prefix=('hl7','cda')">urn:hl7-org:v3</xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="logMessage">
                    <xsl:with-param name="level" select="$logFATAL"/>
                    <xsl:with-param name="terminate" select="true()"/>
                    <xsl:with-param name="msg">
                        <xsl:text>+++ Error: Could not determine namespace-uri for default prefix "</xsl:text>
                        <xsl:value-of select="$prefix"/>
                        <xsl:text>" - Please add the missing namespace declaration your project </xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <!-- html directory for html file objects -->
    <xsl:variable name="theHtmlDir" select="concat($outputBaseUriPrefix, $projectPrefix, 'html-', $theTimeStamp, '/')"/>
    
    <!-- docbook directory for docbook file objects -->
    <xsl:variable name="theDocbookDir" select="concat($outputBaseUriPrefix, $projectPrefix, 'docbook-', $theTimeStamp, '/')"/>

    <!-- 
        runtime directory for schematron file objects and vocabs etc 
        example
        
        peri20-runtime-20120117T114955
        +  schematron1.sch
        +  schematron2.sch
        +  include/  other types of schematrons
        +  include/  vocabs etc
    -->
    <xsl:variable name="theRuntimeDir">
        <xsl:choose>
            <xsl:when test="string-length($outputBaseUriPrefix)&gt;0">
                <xsl:value-of select="$outputBaseUriPrefix"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($outputBaseUriPrefix, $projectPrefix, 'runtime-', $theTimeStamp, '/')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="theRuntimeDirZIP">
        <xsl:choose>
            <xsl:when test="string-length($seeURLprefix)&gt;0">
                <xsl:value-of select="concat($seeURLprefix, $projectPrefix, 'runtime-', $theTimeStamp, '.zip')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat('../', $projectPrefix, 'runtime-', $theTimeStamp, '.zip')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="theRuntimeIncludeDir" select="concat($theRuntimeDir, 'include', '/')"/>
    <xsl:variable name="theRuntimeRelativeIncludeDir" select="concat('include', '/')">
        <!--
        <xsl:choose>
            <xsl:when test="string-length($outputBaseUriPrefix)>0">
                <xsl:value-of select="$theRuntimeIncludeDir"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of />
            </xsl:otherwise>
        </xsl:choose>
        -->
    </xsl:variable>

    <!-- the assets directory -->
    <!-- 
        2DO: versioning of assets
    -->
    <!--  old 
    <xsl:param name="theAssetsDir" select="concat('../assets', '', '/')"/>
    -->
    <!--xsl:variable name="theAssetsVersion" select="'v32'"/-->
    <xsl:variable name="theAssetsVersion" select="''"/>
    <xsl:variable name="decorCoreDir"/>
    
    <xsl:variable name="theAssetsDir">
        <xsl:choose>
            <xsl:when test="$useLocalAssets=true()">
                <xsl:choose>
                    <xsl:when test="contains($deeplinkprefixservices, 'localhost')">
                        <xsl:value-of select="concat(substring-before($deeplinkprefixservices, 'decor/services'), 'exist/apps/decor/core/assets', '', '/')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat(substring-before($deeplinkprefixservices, 'services'), 'core/assets', '', '/')"/>
                    </xsl:otherwise>
                </xsl:choose>
                
            </xsl:when>
            <xsl:otherwise>
                <!-- use ref to online version of assets -->
                <xsl:value-of select="concat($theARTDECORwebsite, '/ADAR/rv/assets', $theAssetsVersion, '/')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <!--<xsl:variable name="theBootstrapDir" select="concat($theAssetsDir, 'bootstrap-3.3.6/')"/>-->
    <!--<xsl:variable name="allDECOR" select="/decor"/>-->
    <!--<xsl:variable name="chapters" as="element()+">
        <a anchor="ch_introduction">Introductie</a>
        <a anchor="ch_scenario">Scenario</a>
        <a anchor="ch_indexes">Indexes</a>
    </xsl:variable>-->
    <xsl:variable name="theV2Scenarios" as="element(scenario)*">
        <!--<xsl:choose>
            <xsl:when test="string-length($scid) > 0 and string-length($sced) > 0">
                <xsl:copy-of select="//scenario[@id = $scid][@effectiveDate = $sced]"/>
            </xsl:when>
            <xsl:when test="string-length($scid) > 0">
                <xsl:copy-of select="//scenario[@id = $scid][@effectiveDate = max(//scenario[@id = $scid]/xs:dateTime(@effectiveDate))]"/>
            </xsl:when>
            <xsl:otherwise>-->
                <xsl:for-each select="//scenario">
                    <xsl:variable name="theRepresentingTemplates" as="element(template)*">
                        <xsl:for-each-group select=".//representingTemplate[@ref]" group-by="concat(@ref, @flexibility[not(. = 'dynamic')])">
                            <xsl:variable name="tmid" select="current-group()[1]/@ref"/>
                            <xsl:variable name="tmed" select="current-group()[1]/@flexibility"/>
                            <xsl:call-template name="getRulesetContent">
                                <xsl:with-param name="ruleset" select="$tmid"/>
                                <xsl:with-param name="flexibility" select="$tmed"/>
                                <xsl:with-param name="sofar" select="()"/>
                            </xsl:call-template>
                        </xsl:for-each-group>
                    </xsl:variable>
                    
                    <xsl:if test="$theRepresentingTemplates/classification[@format = 'hl7v2.5xml']">
                        <xsl:copy-of select="."/>
                    </xsl:if>
                </xsl:for-each>
            <!--</xsl:otherwise>
        </xsl:choose>-->
    </xsl:variable>
    <xsl:variable name="theV2Templates" as="element(template)*">
        <xsl:variable name="tempTemplates" as="element()*">
            <xsl:for-each-group select="$theV2Scenarios//representingTemplate[@ref]" group-by="concat(@ref, @flexibility[not(. = 'dynamic')])">
                <xsl:variable name="tmid" select="current-group()[1]/@ref"/>
                <xsl:variable name="tmed" select="current-group()[1]/@flexibility[not(. = 'dynamic')]"/>
                <xsl:variable name="rc" as="element(template)">
                    <xsl:call-template name="getRulesetContent">
                        <xsl:with-param name="ruleset" select="$tmid"/>
                        <xsl:with-param name="flexibility" select="$tmed"/>
                        <xsl:with-param name="sofar" select="()"/>
                    </xsl:call-template>
                </xsl:variable>
                
                <xsl:call-template name="getTemplateChain2">
                    <xsl:with-param name="template" select="$rc"/>
                    <xsl:with-param name="type" select="'reptemp'"/>
                    <xsl:with-param name="flex" select="$tmed"/>
                    <xsl:with-param name="sofar" select="concat($rc/@id, $rc/@effectiveDate)"/>
                </xsl:call-template>
            </xsl:for-each-group>
        </xsl:variable>
        <xsl:for-each-group select="$tempTemplates" group-by="concat(@id, @effectiveDate)">
            <xsl:copy-of select="current-group()[1]"/>
        </xsl:for-each-group>
    </xsl:variable>
    <xsl:variable name="doV2SegmentTemplates" select="$allDECOR/rules/template[classification/@type='segmentlevel'][concat(@id,@effectiveDate) = $theV2Templates/concat(@id,@effectiveDate)]" as="element(template)*"/>
    <!-- Include certain datatypes explicitly. Because there might not be a direct reference to these from a field, they would otherwise not be in the list -->
    <xsl:variable name="dtV2-CNE">2.16.840.1.113883.3.1937.777.10.15.62013-02-10T00:00:00</xsl:variable>
    <xsl:variable name="dtV2-NM">2.16.840.1.113883.3.1937.777.10.15.862013-02-10T00:00:00</xsl:variable>
    <xsl:variable name="dtV2-SN">2.16.840.1.113883.3.1937.777.10.15.592013-02-10T00:00:00</xsl:variable>
    <xsl:variable name="dtV2-TM">2.16.840.1.113883.3.1937.777.10.15.902013-02-10T00:00:00</xsl:variable>
    <xsl:variable name="doV2DatatypeTemplates" select="$allDECOR/rules/template[classification/@type = 'datatypelevel'][concat(@id,@effectiveDate) = ($theV2Templates/concat(@id,@effectiveDate), $dtV2-CNE, $dtV2-NM, $dtV2-SN, $dtV2-TM)]" as="element(template)*"/>
    
    <xd:doc>
        <xd:desc>Performance hog, and not pretty for testing on production server</xd:desc>
    </xd:doc>
    <xsl:param name="getMissingValueSetsFromRepo">true</xsl:param>
    
    <xsl:variable name="doV2ValueSets" as="element()*">
        <xsl:variable name="tempValueSets" as="element()*">
            <xsl:for-each-group group-by="concat(@valueSet | @value, @flexibility[not(. = 'dynamic')])" select="
                $allDECOR/rules/template[concat(@id, @effectiveDate) = $theV2Templates/concat(@id, @effectiveDate)]//vocabulary[@valueSet] |
                $allDECOR/rules/template[concat(@id, @effectiveDate) = $theV2Templates/concat(@id, @effectiveDate)]//attribute[@name = 'Table']">
                <!--<xsl:sort select="if (current-group()[1]/@value) then current-group()[1]/@value else concat('HL7', substring(concat('0000', tokenize(@valueSet,'\.')[last()]), string-length(concat('0000', tokenize(@valueSet,'\.')[last()])) - 4))"/>-->
                <xsl:variable name="vsref" select="current-group()[1]/(@valueSet | @value)"/>
                <xsl:variable name="vsflex" select="current-group()[1]/@flexibility[not(. = 'dynamic')]"/>
                <xsl:variable name="rc" as="element()?">
                    <xsl:call-template name="getValueset">
                        <xsl:with-param name="reference" select="$vsref"/>
                        <xsl:with-param name="flexibility" select="$vsflex"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="$rc">
                        <xsl:copy-of select="$rc"/>
                    </xsl:when>
                    <xsl:when test="$getMissingValueSetsFromRepo = 'true'">
                        <xsl:copy-of select="doc(concat('https://art-decor.org/decor/services/RetrieveValueSet?prefix=ad4bbr-&amp;ref=',$vsref,'&amp;effectiveDate=',if (string-length($vsflex)>0) then $vsflex else ('dynamic'),'&amp;format=xml'))//valueSet[@id][@effectiveDate]"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:variable>
        <xsl:for-each-group select="$tempValueSets" group-by="concat(@id, @effectiveDate)">
            <xsl:copy-of select="current-group()[1]"/>
        </xsl:for-each-group>
    </xsl:variable>
    
    <!-- where the logos are -->
    <xsl:variable name="theLogosDir">
        <xsl:choose>
            <xsl:when test="$useLocalLogos=true()">
                <xsl:choose>
                    <xsl:when test="$adram &gt;= 'v2.15'">
                        <!-- local logo dir is no longer next to HTML folder but IN the HTML folder from ADRM v2.14 on -->
                        <xsl:value-of select="concat($projectPrefix, 'logos/')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- old school project logo reference, for NON ADRAM calls also for backward compatibility -->   
                        <xsl:value-of select="concat('../', $projectPrefix, 'logos/')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <!-- use ref to online version of assets -->
                <xsl:value-of select="concat($seeURLprefix, '/', $projectPrefix, 'logos/')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <!-- cache all templates with a ref element around per template done by doGetAllTemplates for later processing -->
    <xsl:variable name="allTemplateWithIncludes">
        <!-- no point in building list of datatypes when we are not called to process rules -->
        <xsl:if test="//template">
            <templates xmlns="">
                <xsl:call-template name="doGetAllTemplates"/>
            </templates>
        </xsl:if>
    </xsl:variable>
    <xsl:variable name="allTemplates">
        <xsl:copy-of select="$allTemplateWithIncludes"/>
        <!-- does not work yet properly
        <xsl:apply-templates select="$allTemplateWithIncludes" mode="derefinclude"/>
        -->
    </xsl:variable>
    
    <!-- cache all templates with their id, name and effectiveDate only for later processing -->
    <xsl:variable name="allTemplateRefs">
        <xsl:variable name="rctmp">
            <tmp xmlns="">
                <xsl:call-template name="getRulesetContent24"/>
            </tmp>
        </xsl:variable>
        <templateRefs xmlns="">
            <!-- This gets us the declaration for the prefixes namespace::node() doesn't work although it should -->
            <!-- This is important for DECOR-templatefragment2schematron.xsl -->
            <xsl:copy-of select="$allDECOR/@*"/>
            <xsl:for-each select="$rctmp/*/template">
                <template>
                    <xsl:copy-of select="@id|@name|@effectiveDate"/>
                </template>
            </xsl:for-each>
        </templateRefs>
    </xsl:variable>
    
    <!-- cache all template associations for later processing -->
    <xsl:variable name="allTemplatesAssociations">
        <tmpassocs xmlns="">
            <xsl:for-each select="//rules/templateAssociation">
                <templateAssociation>
                    <xsl:copy-of select="@*"/>
                    <!-- get list of all concept associated with this template -->
                    <xsl:copy-of select="*"/>
                </templateAssociation>
            </xsl:for-each>
        </tmpassocs>
    </xsl:variable>

    <!-- cache all questionnaires for later processing, sorted descending order -->
    <xsl:variable name="allQuestionnaires" as="element(questionnaire)*" select="//questionnaire"/>
    
    <!-- cache all questionnaire associations for later processing, sorted descending order -->
    <xsl:variable name="allQuestionnaireAssociations" as="element(questionnaireAssociation)*" select="//questionnaireAssociation"/>

    <!-- cache all concepts with their id, name and desc for later processing -->
    <xsl:variable name="allDatasetConceptsFlat">
        <datasets xmlns="">
            <xsl:for-each select="//datasets/dataset">
                <xsl:sort select="@effectiveDate" order="descending"/>
                <dataset>
                    <xsl:copy-of select="@*"/>
                    <xsl:copy-of select="name"/>
                    <xsl:copy-of select="desc"/>
                    <!-- get the flat list of all concept names and descriptions -->
                    <xsl:apply-templates select="concept" mode="delist"/>
                </dataset>
            </xsl:for-each>
        </datasets>
    </xsl:variable>

    <!-- create a list of supported data types -->
    <xsl:variable name="supportedDatatypes">
        <!-- no point in building list of datatypes when we are not called to process rules -->
        <xsl:variable name="templateTypes" as="xs:string*">
            <xsl:choose>
                <xsl:when test="//template[not(classification/@format)]">
                    <xsl:for-each-group select="//template/classification/@format, 'hl7v3xml1'" group-by=".">
                        <xsl:value-of select="current-grouping-key()"/>
                    </xsl:for-each-group>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each-group select="//template/classification/@format" group-by=".">
                        <xsl:value-of select="current-grouping-key()"/>
                    </xsl:for-each-group>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:for-each select="$templateTypes">
            <xsl:variable name="datatypeFile" as="xs:string">
                <xsl:choose>
                    <xsl:when test=". = 'hl7v3xml1'">
                        <xsl:value-of select="concat($scriptBaseUriPrefix, 'DECOR-supported-datatypes.xml')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat($scriptBaseUriPrefix, 'DECOR-supported-datatypes-',.,'.xml')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:for-each select="doc($datatypeFile)//(dataType | flavor)[@name][not(ancestor-or-self::atomicDataType)]">
                <dt xmlns="" type="{ancestor::*[last()]/@type}">
                    <xsl:attribute name="name" select="@name"/>
                    <xsl:if test="self::flavor">
                        <xsl:attribute name="isFlavorOf" select="(ancestor-or-self::dataType/@name)[last()]"/>
                    </xsl:if>
                    <xsl:if test="@realm">
                        <xsl:attribute name="realm" select="@realm"/>
                    </xsl:if>
                </dt>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:variable>
    
    <!-- create list of supported atomic data types, i.e. applicable to attributes -->
    <!-- 2DO add to external file. Cannot currently do this as this would lead to side effects such as failure to write DTr1_dt.sch -->
    <xsl:variable name="supportedAtomicDatatypes">
        <xsl:variable name="templateTypes" as="xs:string*">
            <xsl:choose>
                <xsl:when test="//template[not(classification/@format)]">
                    <xsl:for-each-group select="//template/classification/@format, 'hl7v3xml1'" group-by=".">
                        <xsl:value-of select="current-grouping-key()"/>
                    </xsl:for-each-group>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each-group select="//template/classification/@format" group-by=".">
                        <xsl:value-of select="current-grouping-key()"/>
                    </xsl:for-each-group>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:for-each select="$templateTypes">
            <xsl:variable name="datatypeFile" as="xs:string">
                <xsl:choose>
                    <xsl:when test=". = 'hl7v3xml1'">
                        <xsl:value-of select="concat($scriptBaseUriPrefix, 'DECOR-supported-datatypes.xml')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat($scriptBaseUriPrefix, 'DECOR-supported-datatypes-',.,'.xml')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:for-each select="doc($datatypeFile)//atomicDataType[@name]">
                <dt xmlns="" type="{ancestor::*[last()]/@type}">
                    <xsl:attribute name="name" select="@name"/>
                    <xsl:if test="@realm">
                        <xsl:attribute name="realm" select="@realm"/>
                    </xsl:if>
                </dt>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:variable>
    
    <!-- some global params -->
    <xsl:variable name="valueSetReferenceErrors">
        <xsl:call-template name="getValueSetReferenceErrors"/>
    </xsl:variable>
    <!-- moved to DECOR2html for performance -->
    <!--<xsl:variable name="missingTemplates">
        <xsl:call-template name="getMissingTemplates"/>
    </xsl:variable>-->
    
    <!-- cache actual datasets -->
    <xsl:variable xmlns="" name="allDatasets" select="//datasets"/>
    
    <!-- cache actual issues -->
    <xsl:variable xmlns="" name="allIssues" select="//issues"/>
    
    <!-- cache actual template associations -->
    <xsl:variable name="allTemplateAssociation">
        <templateAssociations xmlns="">
            <xsl:copy-of select="//rules/templateAssociation"/>
        </templateAssociations>
    </xsl:variable>
    
    <!-- which random generator can be used? -->
    <xsl:variable name="useJAVArandomuuid" select="function-available('uuid:randomUUID')"/>
    
    <!-- is this project a repository? -->
    <xsl:variable name="projectIsRepository" select="exists($allDECOR[string(@repository)='true'])" as="xs:boolean"/>
    <!-- is this project marked private? -->
    <xsl:variable name="projectIsPrivate" select="exists($allDECOR[string(@private)='true'])" as="xs:boolean"/>
    <!-- is this project marked private? -->
    <xsl:variable name="projectIsExperimental" select="exists($allDECOR/project[string(@experimental)='true'])" as="xs:boolean"/>
    <!-- is the newest current project/(version|release) a version element or a release element? -->
    <xsl:variable name="latestVersionOrRelease" select="(//project/(version|release)[@date = $latestVersion])[1]" as="element()?"/>
    <xsl:variable name="publicationIsRelease" select="exists($latestVersionOrRelease/self::release)" as="xs:boolean"/>
    
    <!-- truncate limit for coded concetps in large value sets -->
    <xsl:variable name="truncateConceptListOutput" select="500"/>
    
    <!-- pattern definitions -->
    <xsl:variable name="INTdigits" select="'^-?[1-9]\d*$|^+?\d*$'"/>
    <xsl:variable name="REALdigits" select="'^[-+]?\d*\.?[0-9]+([eE][-+]?\d+)?$'"/>
    <xsl:variable name="OIDpattern" select="'^[0-2](\.(0|[1-9]\d*))*$'"/>
    <xsl:variable name="RUIDpattern" select="'^[A-Za-z][A-Za-z\d\-]*$'"/>
    <!-- Abstract datatypes 2.15.1
        The literal form for the UUID is defined according to the original specification of the UUID. 
        However, because the HL7 UIDs are case sensitive, for use with HL7, the hexadecimal digits A-F 
        in UUIDs must be converted to upper case.
        
        This being said: if we were to hold current implementations to this idea, then a lot would be 
        broken and not even the official HL7 datatypes check this requirement. Hence we knowingly allow 
        lower-case a-f.
    -->
    <xsl:variable name="UUIDpattern" select="'^[A-Fa-f\d]{8}-[A-Fa-f\d]{4}-[A-Fa-f\d]{4}-[A-Fa-f\d]{4}-[A-Fa-f\d]{12}$'"/>
    <!--Checking xs:ID, xs:IDREF, xs:IDREFS using castable as leads to errors when run through eXist-db with Saxon-PE-->
    <xsl:variable name="xsIDpattern" select="'^([\i-[:]][\c-[:]]*)$'"/>
    <xsl:variable name="xsIDREFSpattern" select="'^([\i-[:]][\c-[:]]*)+( [\i-[:]][\c-[:]]*)*$'"/>
    
    <!-- V3 Code system OID for NullFlavor -->
    <xsl:variable name="theNullFlavorCodeSystem">2.16.840.1.113883.5.1008</xsl:variable>
    
    <xd:doc>
        <xd:desc>Retrieves the list of template elements hanging from an input template</xd:desc>
        <xd:param name="template">Input template or representingTemplate element</xd:param>
        <xd:param name="type">Optional. Adds @type="..." to the returned templates. Contains how they are first called in the chain</xd:param>
        <xd:param name="flex">Optional. Adds @flexibility="..." to the returned templates. Contains with what @flexibility they are first called in the chain</xd:param>
        <xd:param name="sofar">Array of concat(@id, @effectiveDate) values to look up which template we have already seen. This avoids circular references</xd:param>
    </xd:doc>
    <xsl:template name="getTemplateChain2" as="element(template)*">
        <xsl:param name="template" as="element()"/>
        <xsl:param name="type"/>
        <xsl:param name="flex"/>
        <xsl:param name="sofar" as="xs:string*"/>
        
        <template>
            <xsl:copy-of select="$template/@*"/>
            <xsl:if test="string-length($type) > 0">
                <xsl:attribute name="type" select="$type"/>
            </xsl:if>
            <xsl:if test="string-length($flex) > 0">
                <xsl:attribute name="flexibility" select="$flex"/>
            </xsl:if>
            <xsl:copy-of select="$template/classification"/>
        </template>
        <!-- Get all distinct element/@contains and include/@ref that are required in some way. -->
        <xsl:for-each-group select="
            $template//element[@contains][count(ancestor-or-self::element) = count(ancestor-or-self::element[@minimumMultiplicity[. > 0] | @conformance[not(. = 'NP')] | @isMandatory[. = 'true']])] | 
            $template//include[@ref][     count(ancestor::element) + 1     = count(ancestor-or-self::*[@minimumMultiplicity[. > 0] | @conformance[not(. = 'NP')] | @isMandatory[. = 'true']])]" 
            group-by="concat(@contains|@ref, @flexibility[. = 'dynamic'])">
            <xsl:variable name="tmid" select="current-group()[1]/@contains | current-group()[1]/@ref"/>
            <xsl:variable name="tmed" select="current-group()[1]/@flexibility[not(. = 'dynamic')]"/>
            <xsl:choose>
                <xsl:when test="$sofar[. = concat($tmid,$tmed)]">
                    <!-- circular reference -->
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="rc" as="element()">
                        <xsl:call-template name="getRulesetContent">
                            <xsl:with-param name="ruleset" select="$tmid"/>
                            <xsl:with-param name="flexibility" select="$tmed"/>
                            <xsl:with-param name="sofar" select="()"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="$sofar[. = concat($rc/@id,$rc/@effectiveDate)]">
                            <!-- circular reference -->
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="getTemplateChain2">
                                <xsl:with-param name="template" select="$rc"/>
                                <xsl:with-param name="type">
                                    <xsl:choose>
                                        <xsl:when test="current-group()[1][name() = 'element']">contains</xsl:when>
                                        <xsl:when test="current-group()[1][name() = 'include']">include</xsl:when>
                                    </xsl:choose>
                                </xsl:with-param>
                                <xsl:with-param name="flex" select="@flexibility"/>
                                <xsl:with-param name="sofar" select="($sofar, concat($rc/@id,$rc/@effectiveDate))"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template name="getValueSetReferenceErrors">
        <!-- create a list of referenced value sets that cannot be found -->
        <errors xmlns="">
            <xsl:for-each select="$allTerminologyAssociations/*/terminologyAssociation[@valueSet]">
                <xsl:variable name="xvsref" select="@valueSet"/>
                <xsl:variable name="xvsflex" select="if (@flexibility) then (@flexibility) else ('dynamic')"/>
                <xsl:variable name="xvs">
                    <xsl:call-template name="getValueset">
                        <xsl:with-param name="reference" select="$xvsref"/>
                        <xsl:with-param name="flexibility" select="$xvsflex"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="id" select="@conceptId"/>
                <xsl:variable name="flexibility" select="@conceptFlexibility"/>
                <xsl:variable name="conceptOrConceptList" select="local:getConceptOrConceptList($id, (), (), ())"/>
                <xsl:variable name="name">
                    <xsl:choose>
                        <xsl:when test="$conceptOrConceptList/self::concept">
                            <xsl:copy-of select="$conceptOrConceptList/*/name"/>
                        </xsl:when>
                        <xsl:when test="$conceptOrConceptList/self::conceptList">
                            <xsl:copy-of select="$conceptOrConceptList/parent::*/parent::concept/name"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <xsl:if test="not(exists($xvs/valueSet))">
                    <error id="{$xvsref}" flexibility="{$xvsflex}" errortype="terminologyref" from-id="{$id}" from-effectiveDate="{$flexibility}">
                        <xsl:copy-of select="$name"/>
                    </error>
                </xsl:if>
            </xsl:for-each>
            <xsl:for-each select="$allValueSets/*/valueSet[@ref][@missing='true']">
                <xsl:variable name="xvsref" select="@ref"/>
                <xsl:variable name="xvsflex" select="if (@flexibility) then (@flexibility) else ('dynamic')"/>
                <xsl:variable name="id" select="@ref"/>
                <xsl:variable name="name" select="if (@displayName) then @displayName else (@name)"/>
                <error id="{$xvsref}" flexibility="{$xvsflex}" errortype="valuesetref" from-id="{$id}">
                    <name language="{$defaultLanguage}">
                        <xsl:value-of select="$name"/>
                    </name>
                </error>
            </xsl:for-each>
            <xsl:for-each select="$allTemplates//vocabulary[@valueSet]">
                <xsl:variable name="xvsref" select="@valueSet"/>
                <xsl:variable name="xvsflex" select="if (@flexibility) then (@flexibility) else ('dynamic')"/>
                <xsl:variable name="xvs">
                    <xsl:call-template name="getValueset">
                        <xsl:with-param name="reference" select="$xvsref"/>
                        <xsl:with-param name="flexibility" select="$xvsflex"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="id" select="ancestor::template[last()]/@id"/>
                <xsl:variable name="effectiveDate" select="ancestor::template[last()]/@ffectiveDate"/>
                <xsl:variable name="name" select="if (ancestor::template[last()]/@displayName) then ancestor::template[last()]/@displayName else (ancestor::template[last()]/@name)"/>
                <xsl:if test="not(exists($xvs/valueSet))">
                    <error id="{$xvsref}" flexibility="{$xvsflex}" errortype="templateref" from-id="{$id}" from-effectiveDate="{$effectiveDate}">
                        <name language="{$defaultLanguage}">
                            <xsl:value-of select="$name"/>
                        </name>
                    </error>
                </xsl:if>
            </xsl:for-each>
        </errors>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template name="getMissingTemplates">
        <!-- create list of missing templates from includes or contains -->
        <errors xmlns="">
            <xsl:for-each select="$allTemplates//include | $allTemplates//*[@contains]">
                <xsl:variable name="ref" select="@ref | @contains"/>
                <xsl:variable name="flex" select="if (@flexibility) then (@flexibility) else ('dynamic')"/>
                <xsl:variable name="rccontent" as="element()*">
                    <xsl:call-template name="getRulesetContent">
                        <xsl:with-param name="ruleset" select="$ref"/>
                        <xsl:with-param name="flexibility" select="$flex"/>
                        <xsl:with-param name="sofar" select="()"/>
                    </xsl:call-template>
                </xsl:variable>
                <!-- 2017-06-18 AH Added desc to the list. For a number of HL7 V2.5 datatype templates (ID, ID, SI, ST, NM, ...) it is perfectly normal to have just that -->
                <xsl:if test="count($rccontent/(desc|element|assert|report|defineVariable|let|include|choice))=0">
                    <error xmlns="">
                        <xsl:copy-of select="ancestor::template/@id"/>
                        <xsl:copy-of select="ancestor::template/@name"/>
                        <xsl:copy-of select="ancestor::template/@displayName"/>
                        <xsl:copy-of select="ancestor::template/@effectiveDate"/>
                        <xsl:copy-of select="ancestor::template/@statusCode"/>
                        <xsl:copy-of select="ancestor::template/@versionLabel"/>
                        <xsl:attribute name="ref" select="$ref"/>
                        <xsl:attribute name="flexibility" select="$flex"/>
                        <xsl:if test="$rccontent">
                            <xsl:attribute name="refdisplayName" select="if ($rccontent/@displayName) then $rccontent/@displayName else $rccontent/@name"/>
                            <xsl:attribute name="refstatusCode" select="$rccontent/@statusCode"/>
                            <xsl:attribute name="refversionLabel" select="$rccontent/@versionLabel"/>
                        </xsl:if>
                        <xsl:if test="count($rccontent/*)&gt;0">
                            <xsl:attribute name="empty" select="'true'"/>
                        </xsl:if>
                    </error>
                </xsl:if>
            </xsl:for-each>
        </errors>
    </xsl:template>

    <!-- get disclaimer -->
    <xsl:param name="disclaimer">
        <xsl:call-template name="getMessage">
            <xsl:with-param name="key" select="'disclaimer'"/>
            <xsl:with-param name="lang" select="$defaultLanguage"/>
            <xsl:with-param name="p1">
                <xsl:for-each select="//project/copyright[@by]">
                    <xsl:value-of select="@by"/>
                    <xsl:choose>
                        <xsl:when test="position() &lt; last() - 1">
                            <xsl:text>, </xsl:text>
                        </xsl:when>
                        <xsl:when test="position() = last()"/>
                        <xsl:otherwise>
                            <xsl:text> </xsl:text>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'andWord'"/>
                                <xsl:with-param name="lang" select="$defaultLanguage"/>
                            </xsl:call-template>
                            <xsl:text> </xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:param>
    
    <!-- cache all i18n messages -->
    <xsl:variable xmlns="" name="theMESSAGES" select="doc(concat($scriptBaseUriPrefix, 'DECOR-i18n.xml'))/messages" as="element()"/>
    <xsl:key name="i18nkeys" match="/messages/entry" use="@key"/>
    
    <xd:doc>
        <xd:desc/>
        <xd:param name="key"/>
        <xd:param name="lang"/>
        <xd:param name="p1"/>
        <xd:param name="p2"/>
        <xd:param name="p3"/>
        <xd:param name="p4"/>
        <xd:param name="p5"/>
    </xd:doc>
    <xsl:template name="getMessage">
        <xsl:param name="key" as="xs:string?"/>
        <xsl:param name="lang" as="xs:string?"/>
        <xsl:param name="p1" as="item()*"/>
        <xsl:param name="p2" as="item()*"/>
        <xsl:param name="p3" as="item()*"/>
        <xsl:param name="p4" as="item()*"/>
        <xsl:param name="p5" as="item()*"/>
        <xsl:variable name="tmp" select="$theMESSAGES/key('i18nkeys', $key)[1]" as="element()*"/>
        <xsl:variable name="tmp1">
            <tmp1 xmlns="">
                <xsl:choose>
                    <xsl:when test="not(empty($lang)) and $tmp/text[@language = $lang]">
                        <xsl:copy-of select="$tmp/text[@language = $lang]/node()"/>
                    </xsl:when>
                    <xsl:when test="$tmp/text[@language = $defaultLanguage]">
                        <xsl:copy-of select="$tmp/text[@language = $defaultLanguage]/node()"/>
                    </xsl:when>
                    <xsl:when test="$tmp/text[substring(@language, 1, 2)=substring($defaultLanguage, 1, 2)]">
                        <xsl:copy-of select="$tmp/text[substring(@language, 1, 2)=substring($defaultLanguage, 1, 2)][1]/node()"/>
                    </xsl:when>
                    <xsl:when test="$tmp/text[@language = 'en-US']">
                        <xsl:copy-of select="$tmp/text[@language = 'en-US']/node()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>+++Error: NOT FOUND in messages: MESSAGE key=</xsl:text>
                        <xsl:value-of select="$key"/>
                        <xsl:call-template name="logMessage">
                            <xsl:with-param name="level" select="$logERROR"/>
                            <xsl:with-param name="msg">
                                <xsl:text>+++ NOT FOUND in messages: MESSAGE key=</xsl:text>
                                <xsl:value-of select="$key"/>
                                <xsl:text> p1=</xsl:text>
                                <xsl:value-of select="$p1"/>
                                <xsl:text> p2=</xsl:text>
                                <xsl:value-of select="$p2"/>
                                <xsl:text> p3=</xsl:text>
                                <xsl:value-of select="$p3"/>
                                <xsl:text> p4=</xsl:text>
                                <xsl:value-of select="$p4"/>
                                <xsl:text> p5=</xsl:text>
                                <xsl:value-of select="$p5"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </tmp1>
        </xsl:variable>
        <xsl:variable name="tmp2">
            <xsl:apply-templates select="$tmp1" mode="substitute">
                <!-- 
                    compile all substitution strings
                    á la
                    <p n="1" v="(substitution for %%1)"/>
                    etc
                    CAVE don't use $ in the substitution strings, use \$ instead (regex)
                -->
                <xsl:with-param name="px" as="element(p)*">
                    <xsl:if test="not(empty($p1))">
                        <p xmlns="" n="1" v="{$p1}"/>
                    </xsl:if>
                    <xsl:if test="not(empty($p2))">
                        <p xmlns="" n="2" v="{$p2}"/>
                    </xsl:if>
                    <xsl:if test="not(empty($p3))">
                        <p xmlns="" n="3" v="{$p3}"/>
                    </xsl:if>
                    <xsl:if test="not(empty($p4))">
                        <p xmlns="" n="4" v="{$p4}"/>
                    </xsl:if>
                    <xsl:if test="not(empty($p5))">
                        <p xmlns="" n="5" v="{$p5}"/>
                    </xsl:if>
                </xsl:with-param>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:copy-of select="$tmp2"/>
    </xsl:template>
    
    <xsl:variable name="theDECORXSD" select="doc(concat($scriptBaseUriPrefix, 'DECOR.xsd'))/xs:schema" as="element(xs:schema)?"/>
    <xsl:variable name="theDECORDatatypesXSD" select="doc(concat($scriptBaseUriPrefix, 'DECOR-datatypes.xsd'))/xs:schema" as="element(xs:schema)?"/>
    <xsl:variable name="simpleTypes" select="$theDECORXSD/xs:simpleType | $theDECORDatatypesXSD/xs:simpleType" as="element(xs:simpleType)*"/>
    <xsl:key name="simpletypekeys" match="xs:simpleType" use="@name"/>
    
    <xd:doc>
        <xd:desc/>
        <xd:param name="simpleTypeKey"/>
        <xd:param name="lang"/>
        <xd:param name="simpleTypeValue"/>
    </xd:doc>
    <xsl:template name="getXFormsLabel">
        <xsl:param name="simpleTypeKey"/>
        <xsl:param name="lang"/>
        <xsl:param name="simpleTypeValue"/>
        
        <xsl:choose>
            <xsl:when test="$simpleTypes">
                <xsl:variable name="tmp" select="$simpleTypes/key('simpletypekeys', $simpleTypeKey)//xs:enumeration[@value = $simpleTypeValue]" as="element()*"/>
                <xsl:choose>
                    <xsl:when test="$tmp//xforms:label[@xml:lang=$lang]">
                        <xsl:value-of select="$tmp//xforms:label[@xml:lang=$lang]/text()"/>
                    </xsl:when>
                    <xsl:when test="$tmp//xforms:label[@xml:lang=$defaultLanguage]">
                        <xsl:value-of select="$tmp//xforms:label[@xml:lang=$defaultLanguage]/text()"/>
                    </xsl:when>
                    <xsl:when test="$tmp//xforms:label[substring(@xml:lang, 1, 2)=substring($defaultLanguage, 1, 2)]">
                        <xsl:copy-of select="$tmp/xforms:label[substring(@xml:lang, 1, 2)=substring($defaultLanguage, 1, 2)][1]/node()"/>
                    </xsl:when>
                    <xsl:when test="$tmp//xforms:label[@xml:lang='en-US']">
                        <xsl:value-of select="$tmp//xforms:label[@xml:lang='en-US']/text()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$simpleTypeValue"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$simpleTypeValue"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
        <xd:param name="px"/>
    </xd:doc>
    <xsl:template match="node()" mode="substitute">
        <xsl:param name="px" as="element(p)*"/>
        <!--
            use the text node (maybe a nodeset) of the message from getMessage
            and substitute all %%1..%%4 by parameter values p1..p4
            in all the text() and @* nodes of this node (set)
        -->
        <xsl:for-each select="node()">
            <xsl:choose>
                <xsl:when test="string-length(name()) gt 0">
                    <!-- recursively check nested elements and their attributes -->
                    <xsl:copy copy-namespaces="no">
                        <xsl:for-each select="@*">
                            <!-- do string replacement per attribute content -->
                            <xsl:attribute name="{name()}">
                                <xsl:call-template name="multipleReplace">
                                    <xsl:with-param name="in" select="."/>
                                    <xsl:with-param name="px" select="$px"/>
                                    <xsl:with-param name="ix" select="1"/>
                                </xsl:call-template>
                            </xsl:attribute>
                        </xsl:for-each>
                        <xsl:apply-templates select="." mode="substitute">
                            <xsl:with-param name="px" select="$px"/>
                        </xsl:apply-templates>
                    </xsl:copy>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="multipleReplace">
                        <xsl:with-param name="in" select="."/>
                        <xsl:with-param name="px" select="$px"/>
                        <xsl:with-param name="ix" select="1"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
        <xd:param name="in"/>
        <xd:param name="px"/>
        <xd:param name="ix"/>
    </xd:doc>
    <xsl:template name="multipleReplace">
        <xsl:param name="in"/>
        <xsl:param name="px" as="element(p)*"/>
        <xsl:param name="ix"/>
        <xsl:choose>
            <xsl:when test="$ix gt 0 and $ix le count($px)">
                <!-- The nasty second replace guards us from path predicates where a regular expression needs escaping, e.g.
                    hl7:prefix[tokenize(@qualifier,'\s')='VV'][following-sibling::hl7:family[1][@qualifier='BR']]
                    
                    Any \ without a following \ or $ needs escaping
                    Any $ without a leading backslash needs escaping
                -->
                <xsl:call-template name="multipleReplace">
                    <xsl:with-param name="in" select="replace($in, concat ('%%', $px[$ix]/@n), replace(replace($px[$ix]/@v, '([^\\])\\([^\\$])', '$1\\\\$2'), '([^\\])\$', '$1\\\$'))"/>
                    <xsl:with-param name="px" select="$px"/>
                    <xsl:with-param name="ix" select="$ix + 1"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$in"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc>for a given OID in param root get the HL7 V2 0396 mnemonic or just return the oid</xd:desc>
        <xd:param name="oid"/>
    </xd:doc>
    <xsl:template name="getIDHL7v2Table0396" as="xs:string?">
        <xsl:param name="oid"/>
        <xsl:variable name="hl7v2Table0396Key">HL7-V2-Table-0396-Code</xsl:variable>
        <xsl:choose>
            <xsl:when test="$allValueSets/sourceCodeSystem[@id = $oid]/@hl7v2table0396[string-length() gt 0]">
                <xsl:value-of select="($allValueSets/sourceCodeSystem[@id = $oid]/@hl7v2table0396[string-length() gt 0])[1]"/>
            </xsl:when>
            <xsl:when test="$allIDs/id[@root = $oid]/property[@name = $hl7v2Table0396Key]//text()[string-length() gt 0]">
                <xsl:value-of select="($allIDs/id[@root = $oid]/property[@name = $hl7v2Table0396Key]//text()[string-length() gt 0])[1]"/>
            </xsl:when>
            <xsl:when test="$allCodeSystems//codeSystem[@id = $oid]/@hl7v2table0396[string-length() gt 0]">
                <xsl:value-of select="($allCodeSystems//codeSystem[@id = $oid]/@hl7v2table0396[string-length() gt 0])[1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$oid"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
        <xd:param name="root"/>
        <xd:param name="lang"/>
    </xd:doc>
    <xsl:template name="getIDDisplayName" as="xs:string*">
        <!-- 
            for a given OID in param root get the identification (ids) or baseId displayName or description text
        -->
        <xsl:param name="root"/>
        <xsl:param name="lang"/>
        <xsl:variable name="theDesignations" select="$allIDs/id[@root = $root]/designation" as="element()*"/>
        <xsl:choose>
            <xsl:when test="$theDesignations[@language=$lang][string-length(@displayName) gt 0]">
                <xsl:value-of select="($theDesignations[@language=$lang][string-length(@displayName) gt 0])[1]/@displayName"/>
            </xsl:when>
            <xsl:when test="$theDesignations[@language=$lang][string-length(.) gt 0]">
                <xsl:value-of select="($theDesignations[@language=$lang][string-length(.) gt 0])[1]"/>
            </xsl:when>
            <xsl:when test="$theDesignations[@language=$defaultLanguage or not(@language)][string-length(@displayName) gt 0]">
                <xsl:value-of select="($theDesignations[@language=$defaultLanguage or not(@language)]/@displayName)[1]"/>
            </xsl:when>
            <xsl:when test="$theDesignations[@language=$defaultLanguage or not(@language)][string-length(.) gt 0]">
                <xsl:value-of select="($theDesignations[@language=$defaultLanguage or not(@language)][string-length(.) gt 0])[1]"/>
            </xsl:when>
            <xsl:when test="$theDesignations[@language='en-US'][string-length(@displayName) gt 0]">
                <xsl:value-of select="($theDesignations[@language='en-US'][string-length(@displayName) gt 0])[1]/@displayName"/>
            </xsl:when>
            <xsl:when test="$theDesignations[@language='en-US'][string-length(.) gt 0]">
                <xsl:value-of select="($theDesignations[@language='en-US'][string-length(.) gt 0])[1]"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
        <xd:param name="reference"/>
        <xd:param name="flexibility"/>
    </xd:doc>
    <xsl:template name="getValueset" as="element()*">
        <xsl:param name="reference" as="xs:string?"/>
        <xsl:param name="flexibility" as="xs:string?"/>
        <xsl:variable name="allByReference" select="$allValueSets/*/valueSet[(@name|@id)=$reference or @id=$allValueSets/*/valueSet[@name=$reference]/@ref]" as="element()*"/>
        <xsl:variable name="xvsflex" select="($flexibility, 'dynamic')[string-length() gt 0][1]"/>
        <xsl:variable name="xvslatest" select="max($allByReference/xs:dateTime(@effectiveDate))"/>
        <xsl:copy-of select="$allByReference[@id][($xvsflex='dynamic' and @effectiveDate=$xvslatest) or @effectiveDate=$xvsflex]"/>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
        <xd:param name="ruleset"/>
        <xd:param name="flexibility"/>
        <xd:param name="previousContext"/>
        <xd:param name="sofar"/>
    </xd:doc>
    <xsl:template name="getRulesetContent">
        <xsl:param name="ruleset"/>
        <xsl:param name="flexibility"/>
        <xsl:param name="previousContext" select="ancestor::template[1]/concat('template id=''',@id,''' effectiveDate=''',@effectiveDate,''' name=''',@name,'''')" as="xs:string?"/>
        <xsl:param name="sofar" as="xs:string*" required="yes"/>
        
        <xsl:variable name="flex">
            <xsl:choose>
                <xsl:when test="empty($flexibility) or $flexibility=''">
                    <xsl:value-of select="'dynamic'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$flexibility"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <!-- 
            input parameter is id or name of the rule set
            
            rule set as a template is returned - if found
        -->
        <xsl:variable name="rccontent" as="element(template)?">
            <xsl:choose>
                <xsl:when test="count($allTemplates/*/ref[@ref = $ruleset][not(@duplicateOf)][($flex = 'dynamic' and @newestForId = true()) or @effectiveDate = $flex]) &gt; 0">
                    <!-- original rule set, return first found content -->
                    <xsl:copy-of select="($allTemplates/*/ref[@ref = $ruleset and not(@duplicateOf)][($flex = 'dynamic' and @newestForId = true()) or @effectiveDate = $flex])[1]/template"/>
                </xsl:when>
                <xsl:when test="count($allTemplates/*/ref[@ref = $ruleset][@duplicateOf][($flex = 'dynamic' and @newestForName = true()) or @effectiveDate = $flex]) &gt; 0">
                    <!-- duplication of a ruleset with id, return this referenced one and first found content -->
                    <xsl:variable name="rs" select="$allTemplates/*/ref[@ref = $ruleset and @duplicateOf][($flex = 'dynamic' and @newestForName = true()) or @effectiveDate = $flex]/@duplicateOf"/>
                    <xsl:variable name="ed" select="$allTemplates/*/ref[@ref = $ruleset and @duplicateOf][($flex = 'dynamic' and @newestForName = true()) or @effectiveDate = $flex]/@effectiveDate"/>
                    <xsl:copy-of select="($allTemplates/*/ref[@ref = $rs][not(@duplicateOf)][@effectiveDate = $ed])[1]/template"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        
        <!--<xsl:if test="not($rccontent)">
            <xsl:call-template name="logMessage">
                <xsl:with-param name="level" select="$logFATAL"/>
                <xsl:with-param name="terminate" select="$onCircularReferences = 'die'"/>
                <xsl:with-param name="msg">
                    <xsl:text>+++ (name=getRulesetContent) Warning: template referred but missing ref/contains='</xsl:text>
                    <xsl:value-of select="$ruleset"/>
                    <xsl:text>' flexibility='</xsl:text>
                    <xsl:value-of select="$flexibility"/>
                    <xsl:text>'.</xsl:text>
                    <xsl:text>
</xsl:text>
                    <xsl:text>+++ Previous context: </xsl:text>
                    <xsl:value-of select="$previousContext"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>-->
        
        <!-- Kill or notify upon recurse. No point signalling upon every subsequent nesting of the same recursion so only signal the first time -->
        <xsl:if test="count($sofar[. = concat($rccontent/@id, '-', $rccontent/@effectiveDate)]) = 1">
            <xsl:if test="$onCircularReferences = ('report', 'die')">
                <xsl:call-template name="logMessage">
                    <xsl:with-param name="level" select="if ($onCircularReferences = 'die') then $logFATAL else $logWARN"/>
                    <xsl:with-param name="terminate" select="$onCircularReferences = 'die'"/>
                    <xsl:with-param name="msg">
                        <xsl:text>+++ (name=getRulesetContent) Template recursion detected to id='</xsl:text>
                        <xsl:value-of select="$rccontent/@id"/>
                        <xsl:text>' effectiveDate='</xsl:text>
                        <xsl:value-of select="$rccontent/@effectiveDate"/>
                        <xsl:text>' name='</xsl:text>
                        <xsl:value-of select="$rccontent/@name"/>
                        <xsl:text>'.</xsl:text>
                        <xsl:if test="string-length($previousContext) > 0">
                            <xsl:text>
</xsl:text>
                            <xsl:text>          +++ Context: </xsl:text>
                            <xsl:value-of select="$previousContext"/>
                        </xsl:if>
                        <xsl:text>
</xsl:text>
                        <xsl:text>          +++ Processing stopped=</xsl:text>
                        <xsl:value-of select="$onCircularReferences = 'die'"/>
                        <xsl:text>...</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
        </xsl:if>
        
        <xsl:choose>
            <xsl:when test="count($sofar[. = concat($rccontent/@id, '-', $rccontent/@effectiveDate)]) > 0">
                <template>
                    <xsl:copy-of select="$rccontent/@*"/>
                    <xsl:attribute name="recursionDetected">true</xsl:attribute>
                    <xsl:copy-of select="$rccontent/node()"/>
                </template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$rccontent"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
        <xd:param name="ruleset"/>
        <xd:param name="flexibility"/>
    </xd:doc>
    <xsl:template name="getRulesetContent24">
        <!-- 
            the rule set is either contained in a single external file
            or is part of this DECOR file
            
            for example
            <element name="hl7:pertinentInformation3" contains="2.16.840.1.113883.2.4.6.99999.90.2.4">
            means
            search for a file object named @contains.sch and look for template with that id
            or
            search in this DECOR file for a template with that id
            
            return the nodeset of the corresponding rule set
            or null if not found (with emiting an appropriate message)
            
            at this point in time only the MOST RECENT VERSION of a set of rule sets will be returned
        -->
        <xsl:param name="ruleset"/>
        <xsl:param name="flexibility"/>
        <xsl:variable name="flex">
            <xsl:choose>
                <xsl:when test="empty($flexibility) or $flexibility=''">
                    <xsl:value-of select="'dynamic'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$flexibility"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- external file reference (a guess) -->
        <xsl:variable name="p1">
            <xsl:choose>
                <xsl:when test="$flex='dynamic'">
                    <xsl:value-of select="concat($theBaseURI2DECOR, '/', $theSourceDir, $ruleset,'-DYNAMIC', '.xml')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($theBaseURI2DECOR, '/', $theSourceDir, $ruleset,'-',replace($flex,':',''), '.xml')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- template repository -->
        <xsl:variable name="p2" select="concat($theBaseURI2DECOR, '/', $projectTemplateRepository)"/>
        <xsl:choose>
            <xsl:when test="string-length($ruleset)=0">
                <!-- get them all, skip all template ref's as they have to present in resolved form as well with an @id -->
                <xsl:for-each select="//rules/template[not(@ref)]">
                    <xsl:sort select="@id"/>
                    <xsl:sort select="@effectiveDate" order="descending"/>
                    <xsl:copy-of select="."/>
                </xsl:for-each>
                <xsl:if test="doc-available($p2)">
                    <xsl:for-each select="doc($p2)//rules/template[not(@ref)]">
                        <xsl:sort select="@id"/>
                        <xsl:sort select="@effectiveDate" order="descending"/>
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="doc-available($p1)">
                    <xsl:for-each select="doc($p1)//rules/template[not(@ref)]">
                        <xsl:sort select="@id"/>
                        <xsl:sort select="@effectiveDate" order="descending"/>
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template name="doGetAllTemplates">
        
        <!-- get all templates in DECOR and repositories -->
        <xsl:variable name="rccontent">
            <tmp xmlns="">
                <xsl:call-template name="getRulesetContent24"/>
            </tmp>
        </xsl:variable>
        <xsl:variable name="list1">
            <list1 xmlns="">
                <xsl:apply-templates select="$rccontent/*/template" mode="FIND"/>
            </list1>
        </xsl:variable>
        <xsl:variable name="list2">
            <list2 xmlns="">
                <xsl:for-each select="$list1/*/ref">
                    <xsl:sort select="@ref"/>
                    <xsl:variable name="r" select="@ref"/>
                    <xsl:if test="string-length($r)&gt;0">
                        <xsl:choose>
                            <xsl:when test="$list1/*/ref[@ref=$r][not(@error)]">
                                <!--
                                    <xsl:message terminate="no">
                                    <xsl:text>doGetAllTemplates found: </xsl:text>
                                    <xsl:value-of select="@ref"/>
                                    <xsl:if test="@error">
                                    <xsl:text> ERRORFLAG</xsl:text>
                                    </xsl:if>
                                    <xsl:if test="@duplicateOf">
                                    <xsl:text> DUPLICATEOF=</xsl:text>
                                    <xsl:value-of select="@duplicateOf"/>
                                    </xsl:if>
                                    <xsl:text> tmp#=</xsl:text>
                                    <xsl:value-of select="count(template)"/>
                                    <xsl:text> elm#=</xsl:text>
                                    <xsl:value-of select="count(template/element)"/>
                                    </xsl:message>
                                -->
                                <xsl:if test="not(@error)">
                                    <xsl:copy-of select="."/>
                                </xsl:if>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="logMessage">
                                    <xsl:with-param name="level" select="$logERROR"/>
                                    <xsl:with-param name="msg">
                                        <xsl:text>+++ doGetAllTemplates template not found: </xsl:text>
                                        <xsl:value-of select="@ref"/>
                                        <xsl:text> </xsl:text>
                                        <xsl:value-of select="@flexibility"/>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                </xsl:for-each>
            </list2>
        </xsl:variable>
        <xsl:for-each select="$list2/*/ref">
            <xsl:variable name="tid" select="@id"/>
            <xsl:variable name="tnm" select="@name"/>
            <xsl:variable name="ted" select="@effectiveDate"/>
            <xsl:copy>
                <xsl:copy-of select="@*"/>
                <xsl:attribute name="newestForId" select="$ted=max($list2/*/ref[@id=$tid]/xs:dateTime(@effectiveDate))"/>
                <xsl:attribute name="newestForName" select="$ted=max($list2/*/ref[@name=$tnm]/xs:dateTime(@effectiveDate))"/>
                <xsl:copy-of select="node()"/>
            </xsl:copy>
            <!--
            <xsl:message>
                <xsl:value-of select="$tid"/>
                <t>
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="newestForId" select="$ted=max($list2/*/ref[@id=$tid]/xs:dateTime(@effectiveDate))"/>
                </t>
            </xsl:message>
            -->
            <!--
            <xsl:message terminate="no">
                <xsl:text>doGetAllTemplates all: </xsl:text>
                <xsl:value-of select="@ref"/>
                <xsl:if test="@error">
                    <xsl:text> ERRORFLAG</xsl:text>
                </xsl:if>
                <xsl:if test="@duplicateOf">
                    <xsl:text> DUPLICATEOF=</xsl:text>
                    <xsl:value-of select="@duplicateOf"/>
                </xsl:if>
                <xsl:text> tmp#=</xsl:text>
                <xsl:value-of select="count(template)"/>
                <xsl:text> elm#=</xsl:text>
                <xsl:value-of select="count(template/element)"/>
            </xsl:message>
            -->
        </xsl:for-each>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
        <xd:param name="qqid"/>
        <xd:param name="qqed"/>
    </xd:doc>
    <xsl:template name="getQuestionnaireContent" as="element(questionnaire)?">
        <xsl:param name="qqid"/>
        <xsl:param name="qqed"/>
        
        <xsl:variable name="qq" select="if ($qqed[. castable as xs:dateTime]) then $allQuestionnaires[@id = $qqid][@effectiveDate = $qqed] else $allQuestionnaires[@id = $qqid][@effectiveDate = max($allQuestionnaires/@effectiveDate)]" as="element(questionnaire)*"/>
        
        <xsl:choose>
            <xsl:when test="not($qq)">
                <xsl:call-template name="logMessage">
                    <xsl:with-param name="level" select="$logWARN"/>
                    <xsl:with-param name="terminate" select="false()"/>
                    <xsl:with-param name="msg">
                        <xsl:text>+++ (name=getQuestionnaireContent) Warning: questionnaire referred but missing id='</xsl:text>
                        <xsl:value-of select="$qqid"/>
                        <xsl:text>' effectiveDate='</xsl:text>
                        <xsl:value-of select="$qqed"/>
                        <xsl:text>'.</xsl:text>
                        <xsl:text>
</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="count($qq) gt 1">
                <xsl:call-template name="logMessage">
                    <xsl:with-param name="level" select="$logWARN"/>
                    <xsl:with-param name="terminate" select="false()"/>
                    <xsl:with-param name="msg">
                        <xsl:text>+++ (name=getQuestionnaireContent) Warning: questionnaire occurs more than once (</xsl:text>
                        <xsl:value-of select="count($qq)"/>
                        <xsl:text>): id='</xsl:text>
                        <xsl:value-of select="$qqid"/>
                        <xsl:text>' effectiveDate='</xsl:text>
                        <xsl:value-of select="$qq[1]/@effectiveDate"/>
                        <xsl:text>'.</xsl:text>
                        <xsl:text>
</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
        
        <xsl:copy-of select="$qq[1]"/>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="*" mode="derefinclude">
        <xsl:variable name="en" select="name()"/>
        <xsl:element name="{$en}">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="derefinclude"/>
        </xsl:element>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="include" mode="derefinclude">
        <xsl:comment>
            <xsl:text> dereferenced include: </xsl:text>
            <xsl:value-of select="@ref"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="@flexibility"/>
        </xsl:comment>
        <xsl:call-template name="getRulesetContent">
            <xsl:with-param name="ruleset" select="@ref"/>
            <xsl:with-param name="flexibility" select="@flexibility"/>
            <xsl:with-param name="sofar" select="()"/>
        </xsl:call-template>
        <xsl:apply-templates mode="derefinclude"/>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="template" mode="FIND">
        <!-- 
            create ref elements per template
            attributes
            - ref contains the reference (id or name of template) 
            - duplicateOf point to the original template if this a duplicate of template @id
            - error is true if there is no processable content
            
        -->
        <!--
            <xsl:message>
            <xsl:text>tmp FIND=</xsl:text>
            <xsl:value-of select="@id"/>
            <xsl:value-of select="@name"/>
            </xsl:message>
        -->
        <xsl:choose>
            <xsl:when test="string-length(@id) &gt; 0 and string-length(@name) &gt; 0">
                <ref xmlns="">
                    <xsl:attribute name="ref" select="@id"/>
                    <xsl:attribute name="id" select="@id"/>
                    <xsl:attribute name="name" select="@name"/>
                    <xsl:attribute name="effectiveDate" select="@effectiveDate"/>
                    <xsl:copy-of select="."/>
                </ref>
                <ref xmlns="">
                    <xsl:attribute name="ref" select="@name"/>
                    <xsl:attribute name="id" select="@id"/>
                    <xsl:attribute name="name" select="@name"/>
                    <xsl:attribute name="effectiveDate" select="@effectiveDate"/>
                    <xsl:attribute name="duplicateOf" select="@id"/>
                </ref>
            </xsl:when>
            <xsl:when test="string-length(@id) &gt; 0">
                <ref xmlns="">
                    <xsl:attribute name="ref" select="@id"/>
                    <xsl:attribute name="id" select="@id"/>
                    <xsl:attribute name="name" select="@name"/>
                    <xsl:attribute name="effectiveDate" select="@effectiveDate"/>
                    <xsl:copy-of select="."/>
                </ref>
            </xsl:when>
            <xsl:when test="string-length(@name) &gt; 0">
                <ref xmlns="">
                    <xsl:attribute name="ref" select="@name"/>
                    <xsl:attribute name="id" select="@id"/>
                    <xsl:attribute name="name" select="@name"/>
                    <xsl:attribute name="effectiveDate" select="@effectiveDate"/>
                    <xsl:copy-of select="."/>
                </ref>
            </xsl:when>
        </xsl:choose>
        <xsl:for-each select="*//include|*//element[@contains]">
            <xsl:variable name="include">
                <xsl:choose>
                    <xsl:when test="@ref">
                        <xsl:value-of select="@ref"/>
                    </xsl:when>
                    <xsl:when test="@contains">
                        <xsl:value-of select="@contains"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="flexibility" select="if (@flexibility) then (@flexibility) else ('dynamic')"/>
            <xsl:variable name="rccontent">
                <tmp xmlns="">
                    <xsl:call-template name="getRulesetContent24">
                        <xsl:with-param name="ruleset" select="$include"/>
                        <xsl:with-param name="flexibility" select="$flexibility"/>
                    </xsl:call-template>
                </tmp>
            </xsl:variable>
            <!-- 
                <xsl:message>
                <xsl:text>tmp FIND INC=</xsl:text>
                <xsl:value-of select="$include"/>
                <xsl:text> tmp#=</xsl:text>
                <xsl:value-of select="count($rccontent/*/template)"/>
                <xsl:text> elm#=</xsl:text>
                <xsl:value-of select="count($rccontent/*/template/element)"/>
                </xsl:message>
            -->
            <xsl:variable name="outt">
                <ref xmlns="">
                    <xsl:attribute name="ref" select="$include"/>
                    <xsl:attribute name="flexibility" select="$flexibility"/>
                    <xsl:if test="count($rccontent/*/template[@id=$include or @name=$include][$flexibility='dynamic' or @effectiveDate=$flexibility])=0">
                        <xsl:attribute name="error" select="'true'"/>
                    </xsl:if>
                    <xsl:copy-of select="$rccontent/*/*"/>
                </ref>
            </xsl:variable>
            <xsl:copy-of select="$outt"/>
            <xsl:apply-templates select="$rccontent/*/template" mode="FIND"/>
        </xsl:for-each>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="concept" mode="delist">
        <xsl:choose>
            <!-- Compilation already resolves inherit info. Check if this is the case by checking whether or we already have a name.
                The concept will not have a name in a normal inherit situation.
            -->
            <xsl:when test="inherit/@ref[string-length()&gt;0] and not(name)">
                <xsl:variable name="theconcept">
                    <xsl:apply-templates select="." mode="deinherit"/>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="$theconcept/concept/@id[string-length()=0]">
                        <!-- no nodes - this is an error -->
                        <table xmlns="http://www.w3.org/1999/xhtml" width="100%" border="0" cellspacing="3" cellpadding="2">
                            <tr>
                                <!-- show error in concept node -->
                                <td class="nodetype" align="center">
                                    <xsl:call-template name="showStatusDot">
                                        <xsl:with-param name="status" select="error"/>
                                    </xsl:call-template>
                                    <xsl:text> </xsl:text>
                                </td>
                                <!-- show the error message -->
                                <td valign="center" colspan="2" class="nodename tabtab">
                                    <table>
                                        <xsl:call-template name="doMessage">
                                            <xsl:with-param name="level" select="'error'"/>
                                            <xsl:with-param name="msg">
                                                <xsl:choose>
                                                    <xsl:when test="string-length(inherit/@effectiveDate)&gt;0">
                                                        <xsl:call-template name="getMessage">
                                                            <xsl:with-param name="key" select="'theReferencedConceptAsOfCannotBeFound'"/>
                                                            <xsl:with-param name="p1" select="inherit/@ref"/>
                                                            <xsl:with-param name="p2" select="inherit/@effectiveDate"/>
                                                        </xsl:call-template>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:call-template name="getMessage">
                                                            <xsl:with-param name="key" select="'theReferencedConceptCannotBeFound'"/>
                                                            <xsl:with-param name="p1" select="inherit/@ref"/>
                                                        </xsl:call-template>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:with-param>
                                        </xsl:call-template>
                                    </table>
                                </td>
                            </tr>
                        </table>
                        <xsl:call-template name="logMessage">
                            <xsl:with-param name="level" select="$logERROR"/>
                            <xsl:with-param name="msg">
                                <xsl:text>+++ The referenced concept cannot be found: id='</xsl:text>
                                <xsl:value-of select="@id"/>
                                <xsl:text>' effectiveDate='</xsl:text>
                                <xsl:value-of select="@effectiveDate"/>
                                <xsl:text>' inherit id='</xsl:text>
                                <xsl:value-of select="inherit/@ref"/>
                                <xsl:text>' effectiveDate='</xsl:text>
                                <xsl:value-of select="inherit/@effectiveDate"/>
                                <xsl:text>'</xsl:text>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="$theconcept/*" mode="delist"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@id[string-length()&gt;0]">
                <concept xmlns="">
                    <xsl:copy-of select="@*"/>
                    <xsl:copy-of select="* except concept"/>
                </concept>
                <xsl:apply-templates select="concept" mode="delist"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc>print out multi language descriptions/names. input:
            <xd:ul>
                <xd:li>node set of desc elements</xd:li>
                <xd:li>a specific language or null (which means process all languages)</xd:li>
            </xd:ul>
            <xd:p>output:</xd:p>
            <xd:ul>
                <xd:li>the descriptions</xd:li>
                <xd:li>in defaultLanguage or no language specified in black</xd:li>
                <xd:li>other languages in grey</xd:li>
                <xd:li>the defaultLanguage if present always first</xd:li>
                <xd:li>show small flag for "ART-DECOR well known languages"</xd:li>
            </xd:ul>
        </xd:desc>
        <xd:param name="ns"/>
        <xd:param name="shortDesc"/>
        <xd:param name="maxChars"/>
    </xd:doc>
    <xsl:template name="doDescription">
        <!-- the desc nodeset -->
        <xsl:param name="ns"/>
        <!-- do short desc, i.e. first X chars only, use for display inside h3 on datasets.html / scenarios.html etc.: forces text only... -->
        <xsl:param name="shortDesc" as="xs:boolean" select="false()"/>
        <!-- max chars. Max X chars will be retained per language. If input is bigger, then "..." is added -->
        <xsl:param name="maxChars" as="xs:integer" select="200"/>
        
        <!-- create a list of desc items to show -->
        <xsl:variable name="ns2" select="if ($ns instance of document-node()) then $ns/* else $ns" as="element()*"/>
        <xsl:variable name="descs" as="element()*">
            <xsl:choose>
                <xsl:when test="string-length($defaultLanguage) gt 0 and not($defaultLanguage = 'ALL')">
                    <!-- a specific language to be shown, if not present, show en-US, if not present, show first -->
                    <xsl:copy-of select="$ns2[@language = $defaultLanguage]" copy-namespaces="no"/>
                    <xsl:if test="count($ns2[@language = $defaultLanguage]) = 0">
                        <xsl:copy-of select="$ns2[@language = 'en-US']" copy-namespaces="no"/>
                        <xsl:if test="count($ns2[@language = 'en-US']) = 0">
                            <xsl:copy-of select="$ns2[1]" copy-namespaces="no"/>
                        </xsl:if>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <!-- no specific language to be shown, show all, projectDefaultLanguage first if present, then others -->
                    <xsl:copy-of select="$ns2[@language = $projectDefaultLanguage]" copy-namespaces="no"/>
                    <xsl:copy-of select="$ns2[not(@language = $projectDefaultLanguage)]" copy-namespaces="no"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- - ->
        <xsl:message>
            <xsl:text>==
</xsl:text>
            <xsl:value-of select="count($descs/d/*)"/>
            <xsl:copy-of select="$descs"/>
            <xsl:text>==
</xsl:text>
        </xsl:message>
        <!- - -->
        <xsl:for-each select="$descs">
            <xsl:variable name="desc">
                <xsl:choose>
                    <xsl:when test="$shortDesc">
                        <xsl:variable name="longdesc" select="string-join((text()|.//text()),' ')"/>
                        <xsl:value-of select="substring($longdesc,1,$maxChars)"/>
                        <xsl:if test="string-length($longdesc) gt $maxChars">
                            <xsl:text>...</xsl:text>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- exchanged KH 20210326
                        <xsl:copy-of select="node()" copy-namespaces="no"/>
                        -->
                        <!-- do a special description copy to eliminate training blanks after a new line, this spoils the wiki output -->
                        <xsl:apply-templates select="node()" mode="desccopy"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="@language = $defaultLanguage or not(@language)">
                    <!--<xsl:copy-of select="$desc" copy-namespaces="no"/>-->
                    <xsl:apply-templates select="$desc" mode="copyIntoXHTML"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- show in grey only -->
                    <span xmlns="http://www.w3.org/1999/xhtml" style="color: grey;">
                        <xsl:choose>
                            <!-- check for flags for ART-DECOR well known languages -->
                            <xsl:when test="@language = ('de-DE', 'en-US', 'nl-NL')">
                                <xsl:call-template name="showIcon">
                                    <xsl:with-param name="which" select="@language"/>
                                    <xsl:with-param name="tooltip" select="@language"/>
                                    <xsl:with-param name="style" select="''"/>
                                </xsl:call-template>
                                <xsl:text> </xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <i>
                                    <xsl:text>(</xsl:text>
                                    <xsl:value-of select="@language"/>
                                    <xsl:text>) </xsl:text>
                                </i>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:apply-templates select="$desc" mode="copyIntoXHTML"/>
                    </span>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="position()!=last()">
                <br xmlns="http://www.w3.org/1999/xhtml"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xd:doc>
        <xd:desc>special description copy to eliminate training blanks after a new line as this spoils the wiki output</xd:desc>
    </xd:doc>
    <xsl:template match="text()" mode="desccopy">
        <xsl:value-of select="replace(., '&#10;[ ]*', '&#10;')"/>
    </xsl:template>
    <xd:doc>
        <xd:desc>special description copy for proper wiki output</xd:desc>
    </xd:doc>
    <xsl:template match="element()" mode="desccopy">
        <xsl:element name="{name()}">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="node()" mode="desccopy"/>
        </xsl:element>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="text()|processing-instruction()|comment()" mode="copyIntoXHTML">
        <xsl:copy-of select="self::node()"/>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="*" mode="copyIntoXHTML">
        <xsl:choose>
            <xsl:when test="parent::diff:*">
                <!-- no output on children of diff: -->
            </xsl:when>
            <xsl:when test="namespace-uri()=''">
                <xsl:element name="{local-name()}" namespace="http://www.w3.org/1999/xhtml">
                    <xsl:copy-of select="@* except @clear[. = 'none']"/>
                    <xsl:apply-templates select="node()" mode="#current"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates select="node()" mode="#current"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
        <xd:param name="which"/>
        <xd:param name="tooltip"/>
        <xd:param name="style"/>
    </xd:doc>
    <xsl:template name="showIcon">
        <xsl:param name="which"/>
        <xsl:param name="tooltip"/>
        <xsl:param name="style"/>
        <xsl:variable name="imgprefix" select="$theAssetsDir"/>
        <img xmlns="http://www.w3.org/1999/xhtml">
            <!-- set default style width and height of img  -->
            <xsl:attribute name="style" select="concat($style, ' max-width: 1em; max-height: 1em;')"/>
            <xsl:choose>
                <xsl:when test="$which='info'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'info.png')"/>
                </xsl:when>
                <xsl:when test="$which='alert'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'alert.png')"/>
                </xsl:when>
                <xsl:when test="$which='notice'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'notice.png')"/>
                </xsl:when>
                <xsl:when test="$which='doublearrow'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'doublearrow.png')"/>
                </xsl:when>
                <xsl:when test="$which='arrowleft'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'arrowleft.png')"/>
                </xsl:when>
                <xsl:when test="$which='arrowright'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'arrowright.png')"/>
                </xsl:when>
                <xsl:when test="$which='tracking'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'tracking.png')"/>
                </xsl:when>
                <xsl:when test="$which='mail'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'mail.png')"/>
                </xsl:when>
                <xsl:when test="$which='folder'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'folder.png')"/>
                </xsl:when>
                <xsl:when test="$which='folderopen'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'folderopen.png')"/>
                </xsl:when>
                <!--<xsl:when test="$which='item'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'item.png')"/>
                </xsl:when>-->
                <xsl:when test="$which='attachment'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'attachment.png')"/>
                </xsl:when>
                <xsl:when test="$which='construction'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'construction.png')"/>
                </xsl:when>
                <xsl:when test="$which='document'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'document.png')"/>
                </xsl:when>
                <xsl:when test="$which='user'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'user.png')"/>
                </xsl:when>
                <xsl:when test="$which='users'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'users.png')"/>
                </xsl:when>
                <xsl:when test="$which='zoomin'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'zoominb.png')"/>
                </xsl:when>
                <xsl:when test="$which='zoomout'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'zoomoutb.png')"/>
                </xsl:when>
                <xsl:when test="$which='clock'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'clock.png')"/>
                </xsl:when>
                <xsl:when test="$which='blueclock'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'blueclock.png')"/>
                </xsl:when>
                <xsl:when test="$which='download'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'download.png')"/>
                </xsl:when>
                <xsl:when test="$which='flag'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'flag.png')"/>
                </xsl:when>
                <xsl:when test="$which='flag16'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'flag.png')"/>
                </xsl:when>
                <xsl:when test="$which='write'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'write.png')"/>
                </xsl:when>
                <xsl:when test="$which='target'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'target.png')"/>
                </xsl:when>
                <xsl:when test="$which='rotate'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'rotate.png')"/>
                </xsl:when>
                <xsl:when test="$which='treetree'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'treetree.png')"/>
                </xsl:when>
                <xsl:when test="$which='treeblank'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'treeblank.png')"/>
                </xsl:when>
                <xsl:when test="$which='link11'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'link.png')"/>
                </xsl:when>
                <xsl:when test="$which='link'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'link.png')"/>
                </xsl:when>
                <xsl:when test="$which='red'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'reddot.gif')"/>
                </xsl:when>
                <xsl:when test="$which='orange'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'orangedot.gif')"/>
                </xsl:when>
                <xsl:when test="$which='yellow'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'yellowdot.gif')"/>
                </xsl:when>
                <xsl:when test="$which='de-DE'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'de-DE.png')"/>
                </xsl:when>
                <xsl:when test="$which='nl-NL'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'nl-NL.png')"/>
                </xsl:when>
                <xsl:when test="$which='en-US'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'en-US.png')"/>
                </xsl:when>
                <xsl:when test="$which='partialpublication'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'partialpublication.png')"/>
                    <!-- override size -->
                    <xsl:attribute name="style" select="concat($style, ' max-width: 1.2em; max-height: 1.2em;')"/>
                </xsl:when>
                <xsl:when test="$which='repository'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'bbr.png')"/>
                </xsl:when>
                <xsl:when test="$which='experimental'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'experimental.png')"/>
                </xsl:when>
                <xsl:when test="$which='circleplus'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'circleplus.png')"/>
                </xsl:when>
                <xsl:when test="$which='circleminus'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'circleminus.png')"/>
                </xsl:when>
                <xsl:when test="$which='questionmark'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'questionmark.png')"/>
                </xsl:when>
                <xsl:when test="$which='dots'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'dots.png')"/>
                </xsl:when>
                <xsl:when test="$which='twitter'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, $which, '-logo.png')"/>
                    <!-- override size -->
                    <xsl:attribute name="style" select="concat($style, ' max-width: 1.1em; max-height: 1.1em;')"/>
                </xsl:when>
                <xsl:when test="$which='linkedin'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, $which, '-logo.png')"/>
                    <!-- override size -->
                    <xsl:attribute name="style" select="concat($style, ' max-width: 1.1em; max-height: 1.1em;')"/>
                </xsl:when>
                <xsl:when test="$which='facebook'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, $which, '-logo.png')"/>
                    <!-- override size -->
                    <xsl:attribute name="style" select="concat($style, ' max-width: 1.1em; max-height: 1.1em;')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="logMessage">
                        <xsl:with-param name="level" select="$logFATAL"/>
                        <xsl:with-param name="terminate" select="true()"/>
                        <xsl:with-param name="msg">
                            <xsl:text>+++ Internal error: xsl:template showIcon called with unsupported icon type: </xsl:text>
                            <xsl:value-of select="$which"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>

            <!-- assign the tooltip -->
            <xsl:if test="string-length($tooltip) gt 0">
                <!-- <img src="/..." alt="..." class="Tips1" title="Tips Title :: This is my tip content" /> -->
                
                <!--<xsl:attribute name="class" select="'tipz'"/>-->
                <xsl:attribute name="title" select="$tooltip"/>
                <!-- data-toggle and data-placement do nothing, unless you add bootstrap to your page, AND initialize the tooltips using
                    <script type="application/javascript">$(function () { $('[data-toggle="tooltip"]').tooltip() })</script>
                -->
                <xsl:attribute name="data-toggle" select="'tooltip'"/>
                <xsl:attribute name="data-placement" select="'right'"/>
            </xsl:if>
        </img>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>show status for issues</xd:p>
            <xd:pre>draft, feedback                 kyellow.png
            final                           kgreen.png
            new                             kgrey.png
            review, pending, inprogress     korange.png
            rejected, deferred              kpurple.png
            open                            kred.png
            cancelled                       kcancelledblue.png
            closed                          kvalidgreen.png
            deprecated, retired             kvalidblue.png</xd:pre>
        </xd:desc>
        <xd:param name="status"/>
        <xd:param name="title"/>
    </xd:doc>
    <xsl:template name="showStatusDot">
        <xsl:param name="status"/>
        <xsl:param name="title" select="$status"/>
        
        <xsl:variable name="size" select="'20px'"/>
        <xsl:variable name="imgprefix" select="$theAssetsDir"/>
        <img xmlns="http://www.w3.org/1999/xhtml" alt="{$status}">
            <xsl:choose>
                <xsl:when test="$status='new'">
                    <xsl:attribute name="src" select="concat($imgprefix, 'kgrey.png')"/>
                </xsl:when>
                <xsl:when test="$status='draft' or $status='feedback'">
                    <xsl:attribute name="src" select="concat($imgprefix, 'kyellow.png')"/>
                </xsl:when>
                <xsl:when test="$status='final' or $status='active'">
                    <xsl:attribute name="src" select="concat($imgprefix, 'kgreen.png')"/>
                </xsl:when>
                <xsl:when test="$status='open'">
                    <xsl:attribute name="src" select="concat($imgprefix, 'kred.png')"/>
                </xsl:when>
                <xsl:when test="$status='closed'">
                    <xsl:attribute name="src" select="concat($imgprefix, 'kvalidgreen.png')"/>
                </xsl:when>
                <xsl:when test="$status='rejected' or $status='deferred'">
                    <xsl:attribute name="src" select="concat($imgprefix, 'kpurple.png')"/>
                </xsl:when>
                <xsl:when test="$status='cancelled'">
                    <xsl:attribute name="src" select="concat($imgprefix, 'kcancelledblue.png')"/>
                </xsl:when>
                <xsl:when test="$status='pending' or $status='review' or $status='inprogress'">
                    <xsl:attribute name="src" select="concat($imgprefix, 'korange.png')"/>
                </xsl:when>
                <xsl:when test="$status='deprecated'">
                    <xsl:attribute name="src" select="concat($imgprefix, 'kblue.png')"/>
                </xsl:when>
                <xsl:when test="$status='retired'">
                    <xsl:attribute name="src" select="concat($imgprefix, 'kvalidblue.png')"/>
                </xsl:when>
                <!-- exception: archived -->
                <xsl:when test="$status='archived' or $status='inactive'">
                    <xsl:attribute name="src" select="concat($imgprefix, 'kgrey.png')"/>
                </xsl:when>
                <xsl:when test="$status='ref'">
                    <xsl:attribute name="src" select="concat($imgprefix, 'kblank.png')"/>
                </xsl:when>
                <xsl:otherwise>
                    <!--<xsl:attribute name="src" select="concat($imgprefix, 'kred.png')"/>-->
                    <xsl:attribute name="src" select="concat($imgprefix, 'kblank.png')"/>
                </xsl:otherwise>
            </xsl:choose>
            <!-- We don't want to control size fixed here, but using its class so so may adjust from there/localize it -->
            <!--xsl:attribute name="width" select="$size"/>
            <xsl:attribute name="height" select="$size"/-->
            <xsl:attribute name="class" select="'tipsz'"/>
            <xsl:attribute name="title" select="$title"/>
            <!-- data-toggle and data-placement do nothing, unless you add bootstrap to your page, AND initialize the tooltips using
                <script type="application/javascript">$(function () { $('[data-toggle="tooltip"]').tooltip() })</script>
            -->
            <xsl:attribute name="data-toggle" select="'tooltip'"/>
            <xsl:attribute name="data-placement" select="'bottom'"/>
        </img>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>make date more readable</xd:p>
            <xd:pre>2012-02-16T00:00:00       => 2012-02-16
            2012-02-16T19:24:11       => 2012-02-16 19:24:11
            2012-02-16T19:11:23+0100  => 2012-02-16 19:11:23 +01:00</xd:pre>
            
            <xd:p>also replace "-" by non-breaking hyphen</xd:p>
        </xd:desc>
        <xd:param name="date"/>
    </xd:doc>
    <xsl:template name="showDate">
        <xsl:param name="date"/>
        <xsl:variable name="predate" select="replace(string($date), '-', '‑')"/>
        <xsl:choose>
            <xsl:when test="$date = 'dynamic'">
                <xsl:call-template name="getMessage">
                    <xsl:with-param name="key" select="'associationDYNAMIC'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="matches(string($date), '\d\d\d\d-\d\d-\d\dT00:00:00.*')">
                <xsl:value-of select="replace(string($predate), 'T00:00:00.*', '')"/>
            </xsl:when>
            <xsl:when test="matches(string($date), '\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d.*')">
                <xsl:value-of select="replace(string($predate), 'T(\d\d:\d\d:\d\d).*', ' $1')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$predate"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc>print out multi language names. use template doDescription to do the work</xd:desc>
        <xd:param name="ns">the name nodeset</xd:param>
    </xd:doc>
    <xsl:template name="doName">
        <xsl:param name="ns"/>
        <xsl:call-template name="doDescription">
            <xsl:with-param name="ns" select="$ns"/>
            <!--<xsl:with-param name="lang" select="$lang"/>-->
        </xsl:call-template>
    </xsl:template>
    <xd:doc>
        <xd:desc>copy XML file from to</xd:desc>
        <xd:param name="from"/>
        <xd:param name="to"/>
    </xd:doc>
    <xsl:template name="doCopyFile">
        <xsl:param name="from"/>
        <xsl:param name="to"/>
        <xsl:variable name="cn" select="doc($from)"/>
        <xsl:result-document href="{$to}" format="xml" indent="yes">
            <xsl:copy-of select="$cn"/>
        </xsl:result-document>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
        <xd:param name="dir"/>
    </xd:doc>
    <xsl:template name="showDirection">
        <xsl:param name="dir"/>
        <xsl:choose>
            <xsl:when test="$dir='initial'">
                <xsl:call-template name="showIcon">
                    <xsl:with-param name="which">arrowright</xsl:with-param>
                    <xsl:with-param name="tooltip">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="concat('transactionDirection',$dir)"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$dir='back'">
                <xsl:call-template name="showIcon">
                    <xsl:with-param name="which">arrowleft</xsl:with-param>
                    <xsl:with-param name="tooltip">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="concat('transactionDirection',$dir)"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$dir='stationary'">
                <xsl:call-template name="showIcon">
                    <xsl:with-param name="which">rotate</xsl:with-param>
                    <xsl:with-param name="tooltip">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="concat('transactionDirection',$dir)"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>?</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
        <xd:param name="rccontent"/>
        <xd:param name="sofar"/>
        <xd:param name="templateFormat"/>
    </xd:doc>
    <xsl:template name="getWherePathFromNodeset">
        <xsl:param name="rccontent" as="element()*"/>
        <xsl:param name="sofar" as="xs:string*" required="yes"/>
        <xsl:param name="templateFormat" select="'hl7v3xml1'" as="xs:string?"/>
        <xsl:variable name="toplevelelementname" as="xs:string?">
            <xsl:choose>
                <!-- Template with one top level element and no other top level attributes/includes/choices -->
                <xsl:when test="$rccontent[self::template][count(element) = 1][not(attribute | include | choice)]">
                    <xsl:value-of select="($rccontent/element/@name)[1]"/>
                </xsl:when>
                <!-- Other templates... no top level possible -->
                <xsl:when test="$rccontent[self::template]">
                    <!--<xsl:text>*</xsl:text>-->
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="($rccontent/@name)[1]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="not($templateFormat = 'hl7v3xml1')">
                <!-- if we skip preciate creation or pathname already contains [] where => don't try to get a where selector -->
                <xsl:value-of select="$toplevelelementname"/>
            </xsl:when>
            <xsl:when test="$skipPredicateCreation = true() or contains($toplevelelementname, '[')">
                <!-- if we skip preciate creation or pathname already contains [] where => don't try to get a where selector -->
                <xsl:value-of select="concat($toplevelelementname, if ($rccontent[@isMandatory = 'true']) then '[not(@nullFlavor)]' else ())"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="dttype">
                    <xsl:choose>
                        <xsl:when test="$rccontent/ancestor-or-self::*/@templateformat">
                            <xsl:value-of select="($rccontent/ancestor-or-self::*/@templateformat)[1]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="local:getTemplateFormat($rccontent/ancestor-or-self::template[1])"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <!-- Unpack includes as they might lead to a template that has templateIds/codes we can use -->
                <xsl:variable name="rcunpacked" as="element()*">
                    <xsl:for-each select="$rccontent">
                        <xsl:call-template name="mergeTemplates">
                            <xsl:with-param name="rc" select="."/>
                            <xsl:with-param name="sofar" select="$sofar"/>
                            <xsl:with-param name="level" select="1"/>
                            <xsl:with-param name="maxlevel" select="3"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="not($rccontent[self::template][context/@id='*']) and count($rcunpacked[name() = 'element']) != 1">
                        <xsl:call-template name="logMessage">
                            <xsl:with-param name="level" select="$logWARN"/>
                            <xsl:with-param name="msg">
                                <xsl:text>+++ (getWherePathFromNodeset): Cannot determine a name. Input SHALL have exactly 1 element (found </xsl:text>
                                <xsl:value-of select="count($rcunpacked[name() = 'element'])"/>
                                <xsl:text> elements). </xsl:text>
                                <xsl:value-of select="$rccontent[1]/name()"/>
                                <xsl:text> </xsl:text>
                                <xsl:for-each select="$rccontent[1]/(@name, @id, @effectiveDate)">
                                    <xsl:value-of select="concat(name(),'=&quot;',.,'&quot;')"/>
                                </xsl:for-each>
                                <xsl:text>. Names: </xsl:text>
                                <xsl:value-of select="$rcunpacked[name() = 'element']/@name"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- THIS IS STILL IN TESTING MODE -->
                        <!-- pick all hl7:templateId element with attribute/@root populated as child of that element, if any 
                            only template with an explicit context * or ** can determined where clauses by template id
                            
                            supports element with multiple elements, at least one of which contains a templateId. Useful e.g. for 
                                hl7:author
                                    hl7:time
                                    hl7:assignedEntity[hl7:templateId] 
                            or 
                                hl7:entryRelationship
                                    hl7:sequenceNumber
                                    hl7:observation[hl7:templateId]
                                    
                            If for some reason there are multiple elements with templateId, it assumes the first only:
                                hl7:entryRelationship[not(hl7:templateId)]
                                    hl7:sequenceNumber
                                    hl7:entryRelationship[hl7:templateId]
                                    hl7:entryRelationship[hl7:templateId]
                        -->
                        <!-- expect hl7:templateId name, but in case hl7:templateId is not found, see if the current element happens to be some other 
                            kind of identifier element e.g. id, profileId, interactionId
                            For the fallback only test on current element or the one below that, because it makes no sense matching on deeper levels.
                        -->
                        <xsl:variable name="theIdElement" as="element(element)*">
                            <!-- initial name to look for -->
                            <xsl:variable name="telmname" as="xs:string?" select="':templateId'"/>
                            <!-- get templateId elements at max 2 levels starting from the top -->
                            <xsl:choose>
                                <xsl:when test="$rcunpacked[ends-with(@name, $telmname)][attribute[@root or (@name = 'root' and string-length(@value) > 0)][not(@isOptional = 'true')][not(@prohibited = 'true')]]">
                                    <!-- templateId -->
                                    <xsl:copy-of select="$rcunpacked[ends-with(@name, $telmname)][attribute[@root or (@name = 'root' and string-length(@value) > 0)][not(@isOptional = 'true')][not(@prohibited = 'true')]]"/>
                                </xsl:when>
                                <xsl:when test="$rcunpacked/element[@minimumMultiplicity > 0][ends-with(@name, $telmname)][attribute[@root or (@name = 'root' and string-length(@value) > 0)][not(@isOptional = 'true')][not(@prohibited = 'true')]]">
                                    <!-- element/templateId -->
                                    <xsl:copy-of select="$rcunpacked/element[@minimumMultiplicity > 0][ends-with(@name, $telmname)][attribute[@root or (@name = 'root' and string-length(@value) > 0)][not(@isOptional = 'true')][not(@prohibited = 'true')]]"/>
                                </xsl:when>
                                <xsl:when test="$rcunpacked/element[@minimumMultiplicity > 0]/element[@minimumMultiplicity > 0][ends-with(@name, $telmname)][attribute[@root or (@name = 'root' and string-length(@value) > 0)][not(@isOptional = 'true')][not(@prohibited = 'true')]]">
                                    <!-- element/element/templateId -->
                                    <xsl:copy-of select="$rcunpacked/element[@minimumMultiplicity > 0]/element[@minimumMultiplicity > 0][ends-with(@name, $telmname)][attribute[@root or (@name = 'root' and string-length(@value) > 0)][not(@isOptional = 'true')][not(@prohibited = 'true')]]"/>
                                </xsl:when>
                                <!--xsl:when test="$rcunpacked[name() = 'choice'][@minimumMultiplicity > 0]/element[ends-with(@name, $telmname)][attribute[@root or (@name = 'root' and string-length(@value) > 0)][not(@isOptional = 'true')][not(@prohibited = 'true')]]">
                                    <!-\- choice/templateId -\->
                                    <xsl:copy-of select="$rcunpacked[name() = 'choice'][@minimumMultiplicity > 0]/element[ends-with(@name, $telmname)][attribute[@root or (@name = 'root' and string-length(@value) > 0)][not(@isOptional = 'true')][not(@prohibited = 'true')]]"/>
                                </xsl:when>
                                <xsl:when test="$rcunpacked[name() = 'choice'][@minimumMultiplicity > 0]/element/element[ends-with(@name, $telmname)][@minimumMultiplicity > 0][attribute[@root or (@name = 'root' and string-length(@value) > 0)][not(@isOptional = 'true')][not(@prohibited = 'true')]]">
                                    <!-\- choice/element/templateId -\->
                                    <xsl:copy-of select="$rcunpacked[name() = 'choice'][@minimumMultiplicity > 0]/element/element[ends-with(@name, $telmname)][@minimumMultiplicity > 0][attribute[@root or (@name = 'root' and string-length(@value) > 0)][not(@isOptional = 'true')][not(@prohibited = 'true')]]"/>
                                </xsl:when>
                                <xsl:when test="$rcunpacked[name() = 'choice'][@minimumMultiplicity > 0]/element/element[@minimumMultiplicity > 0]/element[ends-with(@name, $telmname)][@minimumMultiplicity > 0][attribute[@root or (@name = 'root' and string-length(@value) > 0)][not(@isOptional = 'true')][not(@prohibited = 'true')]]">
                                    <!-\- choice/element/element/templateId -\->
                                    <xsl:copy-of select="$rcunpacked[name() = 'choice'][@minimumMultiplicity > 0]/element/element[@minimumMultiplicity > 0]/element[ends-with(@name, $telmname)][@minimumMultiplicity > 0][attribute[@root or (@name = 'root' and string-length(@value) > 0)][not(@isOptional = 'true')][not(@prohibited = 'true')]]"/>
                                </xsl:when>
                                <xsl:when test="$rcunpacked/choice[@minimumMultiplicity > 0]/element[ends-with(@name, $telmname)][attribute[@root or (@name = 'root' and string-length(@value) > 0)][not(@isOptional = 'true')][not(@prohibited = 'true')]]">
                                    <!-\- element/choice/templateId -\->
                                    <xsl:copy-of select="$rcunpacked/choice[@minimumMultiplicity > 0]/element[ends-with(@name, $telmname)][attribute[@root or (@name = 'root' and string-length(@value) > 0)][not(@isOptional = 'true')][not(@prohibited = 'true')]]"/>
                                </xsl:when>
                                <xsl:when test="$rcunpacked/choice[@minimumMultiplicity > 0]/element/element[ends-with(@name, $telmname)][@minimumMultiplicity > 0][attribute[@root or (@name = 'root' and string-length(@value) > 0)][not(@isOptional = 'true')][not(@prohibited = 'true')]]">
                                    <!-\- element/choice/element/templateId -\->
                                    <xsl:copy-of select="$rcunpacked/choice[@minimumMultiplicity > 0]/element/element[ends-with(@name, $telmname)][@minimumMultiplicity > 0][attribute[@root or (@name = 'root' and string-length(@value) > 0)][not(@isOptional = 'true')][not(@prohibited = 'true')]]"/>
                                </xsl:when>
                                <xsl:when test="$rcunpacked/element[@minimumMultiplicity > 0]/choice[@minimumMultiplicity > 0]/element[ends-with(@name, $telmname)][attribute[@root or (@name = 'root' and string-length(@value) > 0)][not(@isOptional = 'true')][not(@prohibited = 'true')]]">
                                    <!-\- element/element/choice/templateId -\->
                                    <xsl:copy-of select="$rcunpacked/element[@minimumMultiplicity > 0]/choice[@minimumMultiplicity > 0]/element[ends-with(@name, $telmname)][attribute[@root or (@name = 'root' and string-length(@value) > 0)][not(@isOptional = 'true')][not(@prohibited = 'true')]]"/>
                                </xsl:when>-->
                                <xsl:when test="$rcunpacked[@name][attribute[@root or (@name = 'root' and string-length(@value) > 0)][not(@isOptional = 'true')][not(@prohibited = 'true')]]">
                                    <!-- This is an id type element with at least a @root attribute with a fixed value -->
                                    <xsl:variable name="firstName" select="($rcunpacked[@name][attribute[@root or (@name = 'root' and string-length(@value) > 0)][not(@isOptional = 'true')][not(@prohibited = 'true')]]/@name)[1]"/>
                                    <xsl:copy-of select="$rcunpacked[@name = $firstName][attribute[@root or (@name = 'root' and string-length(@value) > 0)][not(@isOptional = 'true')][not(@prohibited = 'true')]]"/>
                                </xsl:when>
                                <xsl:when test="$rcunpacked/element[@name][@minimumMultiplicity > 0][attribute[@root or (@name = 'root' and string-length(@value) > 0)][not(@isOptional = 'true')][not(@prohibited = 'true')]]">
                                    <!-- This is an element containing an id type element with at least a @root attribute with a fixed value -->
                                    <xsl:variable name="firstName" select="($rcunpacked/element[@name][attribute[@root or (@name = 'root' and string-length(@value) > 0)][not(@isOptional = 'true')][not(@prohibited = 'true')]]/@name)[1]"/>
                                    <xsl:copy-of select="$rcunpacked/element[@name = $firstName][@minimumMultiplicity > 0][attribute[@root or (@name = 'root' and string-length(@value) > 0)][not(@isOptional = 'true')][not(@prohibited = 'true')]]"/>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:variable>
                        <!-- deal with codes, situations
                            
                            1. template
                               id
                               code
                               value
                              
                            then $pn is predicated with $pn[code]
                            
                            2. template
                               observation|procedure|substanceAdministration|supply|act etc = intermediatelement
                                 id
                                 code
                                  ...
                                  
                            then $pn is predicated with $pn[intermediatelement[code]]
                            
                            TODO: elements with attribute[code | codeSystem][vocabulary] - This vocabulary is usually assigned to attribute[@name = 'code'] but who knows what users do :-)
                        -->
                        <!-- expect hl7:code name, but in case hl7:code is not found, see if the current element happens to be some other 
                            kind of coded element e.g. processingCode, processingModeCode, statusCode, versionCode, reasonCode, formCode etc.
                            For the fallback only test on current element or the one below that, because it makes no sense matching on deeper levels. 
                            Final fallback is hl7:code which is then handled under variable clevel and further on.
                        -->
                        <xsl:variable name="theCodeElement" as="element(element)*">
                            <!-- initial name to look for -->
                            <xsl:variable name="telmname" select="':code'"/>
                            <!-- get other code element at top level -->
                            <xsl:variable name="telms-other1" select="$rcunpacked[not(@datatype = ('SC', 'hl7:SC', 'cda:SC'))][vocabulary[@code | @codeSystem | @valueSet] | attribute[not(@prohibited = 'true')][not(@isOptional = 'true')][@name = ('code','codeSystem')][string-length(@value) > 0]]"/>
                            <!-- get other required code element direct underneath top level -->
                            <xsl:variable name="telms-other2" select="$rcunpacked/element[@name][@minimumMultiplicity > 0][not(@datatype = ('SC', 'hl7:SC', 'cda:SC'))][vocabulary[@code | @codeSystem | @valueSet] | attribute[not(@prohibited = 'true')][not(@isOptional = 'true')][@name = ('code','codeSystem')][string-length(@value) > 0]]"/>
                            <xsl:choose>
                                <xsl:when test="$rcunpacked[ends-with(@name, $telmname)][not(@datatype = ('SC', 'hl7:SC', 'cda:SC'))][vocabulary[@code | @codeSystem | @valueSet] | attribute[not(@prohibited = 'true')][not(@isOptional = 'true')][@name = ('code','codeSystem')][string-length(@value) > 0]]">
                                    <!-- code -->
                                    <xsl:copy-of select="$rcunpacked[ends-with(@name, $telmname)][not(@datatype = ('SC', 'hl7:SC', 'cda:SC'))][vocabulary[@code | @codeSystem | @valueSet] | attribute[not(@prohibited = 'true')][not(@isOptional = 'true')][@name = ('code','codeSystem')][string-length(@value) > 0]]"/>
                                </xsl:when>
                                <xsl:when test="$rcunpacked/element[@minimumMultiplicity > 0][ends-with(@name, $telmname)][not(@datatype = ('SC', 'hl7:SC', 'cda:SC'))][vocabulary[@code | @codeSystem | @valueSet] | attribute[not(@prohibited = 'true')][not(@isOptional = 'true')][@name = ('code','codeSystem')][string-length(@value) > 0]]">
                                    <!-- element/code -->
                                    <xsl:copy-of select="$rcunpacked/element[@minimumMultiplicity > 0][ends-with(@name, $telmname)][not(@datatype = ('SC', 'hl7:SC', 'cda:SC'))][vocabulary[@code | @codeSystem | @valueSet] | attribute[not(@prohibited = 'true')][not(@isOptional = 'true')][@name = ('code','codeSystem')][string-length(@value) > 0]]"/>
                                </xsl:when>
                                <xsl:when test="$rcunpacked/element[@minimumMultiplicity > 0]/element[ends-with(@name, $telmname)][@minimumMultiplicity > 0][not(@datatype = ('SC', 'hl7:SC', 'cda:SC'))][vocabulary[@code | @codeSystem | @valueSet] | attribute[not(@prohibited = 'true')][not(@isOptional = 'true')][@name = ('code','codeSystem')][string-length(@value) > 0]]">
                                    <!-- element/element/code -->
                                    <xsl:copy-of select="$rcunpacked/element[@minimumMultiplicity > 0]/element[ends-with(@name, $telmname)][@minimumMultiplicity > 0][not(@datatype = ('SC', 'hl7:SC', 'cda:SC'))][vocabulary[@code | @codeSystem | @valueSet] | attribute[not(@prohibited = 'true')][not(@isOptional = 'true')][@name = ('code','codeSystem')][string-length(@value) > 0]]"/>
                                </xsl:when>
                                <!--<xsl:when test="$rcunpacked[name() = 'choice'][@minimumMultiplicity > 0]/element[ends-with(@name, $telmname)][vocabulary[@code | @codeSystem | @valueSet] | attribute[not(@prohibited = 'true')][not(@isOptional = 'true')][@name = ('code','codeSystem')][string-length(@value) > 0]]">
                                    <!-\- choice/code -\->
                                    <xsl:copy-of select="$rcunpacked[name() = 'choice'][@minimumMultiplicity > 0]/element[ends-with(@name, $telmname)][vocabulary[@code | @codeSystem | @valueSet] | attribute[not(@prohibited = 'true')][not(@isOptional = 'true')][@name = ('code','codeSystem')][string-length(@value) > 0]]"/>
                                </xsl:when>
                                <xsl:when test="$rcunpacked[name() = 'choice'][@minimumMultiplicity > 0]/element/element[ends-with(@name, $telmname)][@minimumMultiplicity > 0][vocabulary[@code | @codeSystem | @valueSet] | attribute[not(@prohibited = 'true')][not(@isOptional = 'true')][@name = ('code','codeSystem')][string-length(@value) > 0]]">
                                    <!-\- choice/element/code -\->
                                    <xsl:copy-of select="$rcunpacked[name() = 'choice'][@minimumMultiplicity > 0]/element/element[ends-with(@name, $telmname)][@minimumMultiplicity > 0][vocabulary[@code | @codeSystem | @valueSet] | attribute[not(@prohibited = 'true')][not(@isOptional = 'true')][@name = ('code','codeSystem')][string-length(@value) > 0]]"/>
                                </xsl:when>
                                <xsl:when test="$rcunpacked[name() = 'choice'][@minimumMultiplicity > 0]/element/element[@minimumMultiplicity > 0]/element[ends-with(@name, $telmname)][@minimumMultiplicity > 0][vocabulary[@code | @codeSystem | @valueSet] | attribute[not(@prohibited = 'true')][not(@isOptional = 'true')][@name = ('code','codeSystem')][string-length(@value) > 0]]">
                                    <!-\- choice/element/element/code -\->
                                    <xsl:copy-of select="$rcunpacked[name() = 'choice'][@minimumMultiplicity > 0]/element/element[@minimumMultiplicity > 0]/element[ends-with(@name, $telmname)][@minimumMultiplicity > 0][vocabulary[@code | @codeSystem | @valueSet] | attribute[not(@prohibited = 'true')][not(@isOptional = 'true')][@name = ('code','codeSystem')][string-length(@value) > 0]]"/>
                                </xsl:when>
                                <xsl:when test="$rcunpacked/choice[@minimumMultiplicity > 0]/element[ends-with(@name, $telmname)][vocabulary[@code | @codeSystem | @valueSet] | attribute[not(@prohibited = 'true')][not(@isOptional = 'true')][@name = ('code','codeSystem')][string-length(@value) > 0]]">
                                    <!-\- element/choice/code -\->
                                    <xsl:copy-of select="$rcunpacked/choice[@minimumMultiplicity > 0]/element[ends-with(@name, $telmname)][vocabulary[@code | @codeSystem | @valueSet] | attribute[not(@prohibited = 'true')][not(@isOptional = 'true')][@name = ('code','codeSystem')][string-length(@value) > 0]]"/>
                                </xsl:when>
                                <xsl:when test="$rcunpacked/choice[@minimumMultiplicity > 0]/element/element[ends-with(@name, $telmname)][@minimumMultiplicity > 0][vocabulary[@code | @codeSystem | @valueSet] | attribute[not(@prohibited = 'true')][not(@isOptional = 'true')][@name = ('code','codeSystem')][string-length(@value) > 0]]">
                                    <!-\- element/choice/element/code -\->
                                    <xsl:copy-of select="$rcunpacked/choice[@minimumMultiplicity > 0]/element/element[ends-with(@name, $telmname)][@minimumMultiplicity > 0][vocabulary[@code | @codeSystem | @valueSet] | attribute[not(@prohibited = 'true')][not(@isOptional = 'true')][@name = ('code','codeSystem')][string-length(@value) > 0]]"/>
                                </xsl:when>
                                <xsl:when test="$rcunpacked/element[@minimumMultiplicity > 0]/choice[@minimumMultiplicity > 0]/element[ends-with(@name, $telmname)][vocabulary[@code | @codeSystem | @valueSet] | attribute[not(@prohibited = 'true')][not(@isOptional = 'true')][@name = ('code','codeSystem')][string-length(@value) > 0]]">
                                    <!-\- element/element/choice/code -\->
                                    <xsl:copy-of select="$rcunpacked/element[@minimumMultiplicity > 0]/choice[@minimumMultiplicity > 0]/element[ends-with(@name, $telmname)][vocabulary[@code | @codeSystem | @valueSet] | attribute[not(@prohibited = 'true')][not(@isOptional = 'true')][@name = ('code','codeSystem')][string-length(@value) > 0]]"/>
                                </xsl:when>-->
                                <xsl:when test="$telms-other1">
                                    <!-- This is a code type element with vocabulary and/or attributes for code and/or codeSystem -->
                                    <xsl:variable name="firstName" select="($telms-other1/@name)[1]"/>
                                    <xsl:copy-of select="$telms-other1[@name = $firstName]"/>
                                </xsl:when>
                                <xsl:when test="$telms-other2">
                                    <!-- This is an element containing a code type element with vocabulary and/or attributes for code and/or codeSystem -->
                                    <xsl:variable name="firstName" select="($telms-other2/@name)[1]"/>
                                    <xsl:copy-of select="$telms-other2[@name = $firstName]"/>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:variable>
                        
                        <!-- get properties from this code attribute, either a single code/codeSystem or a set of values-->
                        <!-- now make the checks and output pathname -->
                        <xsl:variable name="predicate">
                            <xsl:choose>
                                <!-- give priority to template ids as where selectors if any -->
                                <xsl:when test="$theIdElement">
                                    <xsl:variable name="tlevel" select="($rcunpacked/descendant-or-self::element[deep-equal(., $theIdElement[1])])[1]/count(ancestor::element)" as="xs:integer?"/>
                                    <xsl:variable name="parentChoice" select="($rcunpacked/descendant-or-self::element[deep-equal(., $theIdElement[1])])[1]/parent::choice" as="element()?"/>
                                    <xsl:variable name="parent2Choice" select="($rcunpacked/descendant-or-self::element[deep-equal(., $theIdElement[1])])[1]/parent::element/parent::choice" as="element()?"/>
                                    <!-- add info for intermediate layer if there is one -->
                                    <xsl:if test="$tlevel gt 0">
                                        <xsl:choose>
                                            <xsl:when test="string-length($toplevelelementname) gt 0">
                                                <xsl:value-of select="$toplevelelementname"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:text>*</xsl:text>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:if>
                                    <xsl:choose>
                                        <xsl:when test="$parentChoice">
                                            <xsl:if test="$tlevel = 2">
                                                <xsl:text>[</xsl:text>
                                                <!-- Insert parent element for the templateId element -->
                                                <xsl:value-of select="($rcunpacked/descendant-or-self::element[deep-equal(., $theIdElement[1])])[1]/parent::choice/parent::element/@name"/>
                                            </xsl:if>
                                            <xsl:if test="$tlevel >= 1">
                                                <xsl:text>[</xsl:text>
                                            </xsl:if>
                                            <xsl:for-each select="$theIdElement">
                                                <xsl:value-of select="@name"/>
                                                <xsl:call-template name="doIdElementPredicate">
                                                    <xsl:with-param name="theElement" select="."/>
                                                </xsl:call-template>
                                                <xsl:if test="position() != last()">
                                                    <xsl:text> | </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                            <xsl:if test="$tlevel >= 1">
                                                <xsl:text>]</xsl:text>
                                            </xsl:if>
                                            <xsl:if test="$tlevel = 2">
                                                <xsl:text>]</xsl:text>
                                            </xsl:if>
                                        </xsl:when>
                                        <xsl:when test="$parent2Choice">
                                            <xsl:if test="$tlevel >= 1">
                                                <xsl:text>[</xsl:text>
                                            </xsl:if>
                                            <xsl:for-each select="$theIdElement">
                                                <xsl:variable name="theElement" select="."/>
                                                <!-- Insert parent element for the templateId element -->
                                                <xsl:value-of select="($rcunpacked/descendant-or-self::element[deep-equal(., $theElement)])[1]/parent::element/@name"/>
                                                <xsl:if test="$tlevel > 0">
                                                    <xsl:text>[</xsl:text>
                                                    <xsl:value-of select="@name"/>
                                                </xsl:if>
                                                <xsl:call-template name="doIdElementPredicate">
                                                    <xsl:with-param name="theElement" select="."/>
                                                </xsl:call-template>
                                                <xsl:if test="$tlevel > 0">
                                                    <xsl:text>]</xsl:text>
                                                </xsl:if>
                                                <xsl:if test="position() != last()">
                                                    <xsl:text> | </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                            <xsl:if test="$tlevel >= 1">
                                                <xsl:text>]</xsl:text>
                                            </xsl:if>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:if test="$tlevel = 2">
                                                <xsl:text>[</xsl:text>
                                                <!-- Insert parent element for the templateId element -->
                                                <xsl:value-of select="($rcunpacked/descendant-or-self::element[deep-equal(., $theIdElement[1])])[1]/parent::element/@name"/>
                                            </xsl:if>
                                            <xsl:if test="$tlevel > 0">
                                                <xsl:text>[</xsl:text>
                                            </xsl:if>
                                            <xsl:for-each select="$theIdElement">
                                                <xsl:value-of select="@name"/>
                                                <xsl:call-template name="doIdElementPredicate">
                                                    <xsl:with-param name="theElement" select="."/>
                                                </xsl:call-template>
                                                <xsl:if test="position() != last()">
                                                    <xsl:text> and </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                            <xsl:if test="$tlevel > 0">
                                                <xsl:text>]</xsl:text>
                                            </xsl:if>
                                            <xsl:if test="$tlevel = 2">
                                                <xsl:text>]</xsl:text>
                                            </xsl:if>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:when test="$theCodeElement">
                                    <xsl:variable name="clevel" select="($rcunpacked/descendant-or-self::element[deep-equal(., $theCodeElement[1])])[1]/count(ancestor::element)" as="xs:integer?"/>
                                    <xsl:variable name="parentChoice" select="($rcunpacked/descendant-or-self::element[deep-equal(., $theCodeElement[1])])[1]/parent::choice" as="element()?"/>
                                    <xsl:variable name="parent2Choice" select="($rcunpacked/descendant-or-self::element[deep-equal(., $theCodeElement[1])])[1]/parent::element/parent::choice" as="element()?"/>
                                    <!-- add info for intermediate layer if there is one -->
                                    <xsl:if test="$clevel gt 0">
                                        <xsl:choose>
                                            <xsl:when test="string-length($toplevelelementname) gt 0">
                                                <xsl:value-of select="$toplevelelementname"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:text>*</xsl:text>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:if>
                                    <xsl:choose>
                                        <xsl:when test="$parentChoice">
                                            <xsl:if test="$clevel = 2">
                                                <xsl:text>[</xsl:text>
                                                <!-- Insert parent element for the coded element -->
                                                <xsl:value-of select="$parentChoice/parent::element/@name"/>
                                            </xsl:if>
                                            <xsl:if test="$clevel >= 1">
                                                <xsl:text>[</xsl:text>
                                            </xsl:if>
                                            <xsl:for-each select="$theCodeElement">
                                                <!-- Prohibiting attribute nullFlavor is effectively saying that the item is mandatory in a different way. Difference:
                                                    element[@isMandatory = 'true'] 
                                                        element SHALL be present with a value and thus without @nullFlavor
                                                    element[@minimumMultiplicity = 0]/attribute[@name = 'nullFlavor'][@prohibited = 'true'][not(@value)]
                                                        element MAY be present, and SHALL NOT have a nullFlavor
                                                    element[@minimumMultiplicity = 0]/attribute[not(@name = ('nullFlavor','codeSystem','xsi:type'))][not(@prohibited = 'true')][not(@isOptional = 'true')]
                                                        element MAY be present, and SHALL NOT have a nullFlavor (since there is some required attribute, other than xsi:type or codeSystem)
                                                -->
                                                <xsl:variable name="isMandatoryAttr" select="exists(
                                                    .[@isMandatory = 'true'] | attribute[@name = 'nullFlavor'][@prohibited = 'true'][not(@value)] | 
                                                    attribute[not(@name = ('nullFlavor','codeSystem','xsi:type'))][not(@prohibited = 'true')][not(@isOptional = 'true')])"/>
                                                <xsl:variable name="whereselector" as="xs:string?">
                                                    <xsl:call-template name="doCodeElementPredicate">
                                                        <xsl:with-param name="theElement" select="."/>
                                                        <xsl:with-param name="isMandatoryAttr" select="$isMandatoryAttr"/>
                                                    </xsl:call-template>
                                                </xsl:variable>
                                                <xsl:value-of select="@name"/>
                                                <xsl:choose>
                                                    <xsl:when test="string-length($whereselector) = 0">
                                                        <xsl:if test="not(contains(@name, '[')) and $isMandatoryAttr">
                                                            <xsl:text>[not(@nullFlavor)]</xsl:text>
                                                        </xsl:if>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:text>[</xsl:text>
                                                        <xsl:value-of select="$whereselector"/>
                                                        <!-- add nullFlavor if applicable -->
                                                        <!-- If no nullFlavor was specified and current element was not mandatory then all nullFlavors are in scope -->
                                                        <xsl:if test="$whereselector[not(contains(., '@nullFlavor'))][not($isMandatoryAttr)]">
                                                            <xsl:text> or @nullFlavor</xsl:text>
                                                        </xsl:if>
                                                        <xsl:text>]</xsl:text>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                                <xsl:if test="position() != last()">
                                                    <xsl:text> | </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                            <xsl:if test="$clevel >= 1">
                                                <xsl:text>]</xsl:text>
                                            </xsl:if>
                                            <xsl:if test="$clevel = 2">
                                                <xsl:text>]</xsl:text>
                                            </xsl:if>
                                        </xsl:when>
                                        <xsl:when test="$parent2Choice">
                                            <xsl:if test="$clevel >= 1">
                                                <xsl:text>[</xsl:text>
                                            </xsl:if>
                                            <xsl:for-each select="$theCodeElement">
                                                <xsl:variable name="theElement" select="."/>
                                                <!-- Prohibiting attribute nullFlavor is effectively saying that the item is mandatory in a different way. Difference:
                                                    element[@isMandatory = 'true'] 
                                                        element SHALL be present with a value and thus without @nullFlavor
                                                    element[@minimumMultiplicity = 0]/attribute[@name = 'nullFlavor'][@prohibited = 'true'][not(@value)]
                                                        element MAY be present, and SHALL NOT have a nullFlavor
                                                    element[@minimumMultiplicity = 0]/attribute[not(@name = ('nullFlavor','codeSystem','xsi:type'))][not(@prohibited = 'true')][not(@isOptional = 'true')]
                                                        element MAY be present, and SHALL NOT have a nullFlavor (since there is some required attribute, other than xsi:type or codeSystem)
                                                -->
                                                <xsl:variable name="isMandatoryAttr" select="exists(
                                                    .[@isMandatory = 'true'] | attribute[@name = 'nullFlavor'][@prohibited = 'true'][not(@value)] | 
                                                    attribute[not(@name = ('nullFlavor','codeSystem','xsi:type'))][not(@prohibited = 'true')][not(@isOptional = 'true')])"/>
                                                <xsl:variable name="whereselector" as="xs:string?">
                                                    <xsl:call-template name="doCodeElementPredicate">
                                                        <xsl:with-param name="theElement" select="."/>
                                                        <xsl:with-param name="isMandatoryAttr" select="$isMandatoryAttr"/>
                                                    </xsl:call-template>
                                                </xsl:variable>
                                                
                                                <!-- Insert parent element for the coded element -->
                                                <xsl:value-of select="($rcunpacked/descendant-or-self::element[deep-equal(., $theElement)])[1]/parent::element/@name"/>
                                                <xsl:if test="$clevel > 0">
                                                    <xsl:text>[</xsl:text>
                                                    <xsl:value-of select="@name"/>
                                                </xsl:if>
                                                <xsl:choose>
                                                    <xsl:when test="string-length($whereselector) = 0">
                                                        <xsl:if test="not(contains(@name, '[')) and $isMandatoryAttr">
                                                            <xsl:text>[not(@nullFlavor)]</xsl:text>
                                                        </xsl:if>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:text>[</xsl:text>
                                                        <xsl:value-of select="$whereselector"/>
                                                        <!-- add nullFlavor if applicable -->
                                                        <!-- If no nullFlavor was specified and current element was not mandatory then all nullFlavors are in scope -->
                                                        <xsl:if test="$whereselector[not(contains(., '@nullFlavor'))][not($isMandatoryAttr)]">
                                                            <xsl:text> or @nullFlavor</xsl:text>
                                                        </xsl:if>
                                                        <xsl:text>]</xsl:text>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                                <xsl:if test="$clevel > 0">
                                                    <xsl:text>]</xsl:text>
                                                </xsl:if>
                                                <xsl:if test="position() != last()">
                                                    <xsl:text> | </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                            <xsl:if test="$clevel >= 1">
                                                <xsl:text>]</xsl:text>
                                            </xsl:if>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:if test="$clevel = 2">
                                                <xsl:text>[</xsl:text>
                                                <!-- Insert parent element for the templateId element -->
                                                <xsl:value-of select="($rcunpacked/descendant-or-self::element[deep-equal(., $theCodeElement[1])])[1]/parent::element/@name"/>
                                            </xsl:if>
                                            <xsl:if test="$clevel > 0">
                                                <xsl:text>[</xsl:text>
                                            </xsl:if>
                                            <xsl:for-each select="$theCodeElement">
                                                <!-- Prohibiting attribute nullFlavor is effectively saying that the item is mandatory in a different way. Difference:
                                                    element[@isMandatory = 'true'] 
                                                        element SHALL be present with a value and thus without @nullFlavor
                                                    element[@minimumMultiplicity = 0]/attribute[@name = 'nullFlavor'][@prohibited = 'true'][not(@value)]
                                                        element MAY be present, and SHALL NOT have a nullFlavor
                                                    element[@minimumMultiplicity = 0]/attribute[not(@name = ('nullFlavor','codeSystem','xsi:type'))][not(@prohibited = 'true')][not(@isOptional = 'true')]
                                                        element MAY be present, and SHALL NOT have a nullFlavor (since there is some required attribute, other than xsi:type or codeSystem)
                                                -->
                                                <xsl:variable name="isMandatoryAttr" select="exists(
                                                    .[@isMandatory = 'true'] | attribute[@name = 'nullFlavor'][@prohibited = 'true'][not(@value)] | 
                                                    attribute[not(@name = ('nullFlavor','codeSystem','xsi:type'))][not(@prohibited = 'true')][not(@isOptional = 'true')])"/>
                                                <xsl:variable name="whereselector" as="xs:string?">
                                                    <xsl:call-template name="doCodeElementPredicate">
                                                        <xsl:with-param name="theElement" select="."/>
                                                        <xsl:with-param name="isMandatoryAttr" select="$isMandatoryAttr"/>
                                                    </xsl:call-template>
                                                </xsl:variable>
                                                
                                                <xsl:value-of select="@name"/>
                                                <xsl:choose>
                                                    <xsl:when test="string-length($whereselector) = 0">
                                                        <xsl:if test="not(contains(@name, '[')) and $isMandatoryAttr">
                                                            <xsl:text>[not(@nullFlavor)]</xsl:text>
                                                        </xsl:if>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:text>[</xsl:text>
                                                        <xsl:value-of select="$whereselector"/>
                                                        <!-- add nullFlavor if applicable -->
                                                        <!-- If no nullFlavor was specified and current element was not mandatory then all nullFlavors are in scope -->
                                                        <xsl:if test="$whereselector[not(contains(., '@nullFlavor'))][not($isMandatoryAttr)]">
                                                            <xsl:text> or @nullFlavor</xsl:text>
                                                        </xsl:if>
                                                        <xsl:text>]</xsl:text>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                                <xsl:if test="position() != last()">
                                                    <xsl:text> and </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                            <xsl:if test="$clevel > 0">
                                                <xsl:text>]</xsl:text>
                                            </xsl:if>
                                            <xsl:if test="$clevel = 2">
                                                <xsl:text>]</xsl:text>
                                            </xsl:if>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <!-- no where found, return name -->
                                    <!-- add info for intermediate layer if there is one -->
                                    <xsl:choose>
                                        <xsl:when test="string-length($toplevelelementname) gt 0">
                                            <xsl:value-of select="$toplevelelementname"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>*</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:if test="@isMandatory = 'true'">
                                        <xsl:text>[not(@nullFlavor)]</xsl:text>
                                    </xsl:if>
                                    <xsl:call-template name="doAttributePredicate">
                                        <xsl:with-param name="rcunpacked" select="$rcunpacked"/>
                                        <xsl:with-param name="dttype" select="$dttype"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="doElementPredicate">
                                        <xsl:with-param name="theElements" select="$rcunpacked[1]/element"/>
                                    </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <!-- output it if it down not contain intensional value set definitions -->
                        <xsl:choose>
                            <xsl:when test="matches($predicate, 'containsIntensionalValueSets')">
                                <!-- do not emit a predicate (only base element name), we cannot handle intensional value set definitions properly yet -->
                                <xsl:choose>
                                    <xsl:when test="string-length($toplevelelementname) &gt; 0">
                                        <xsl:value-of select="$toplevelelementname"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>*</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$predicate"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc/>
        <xd:param name="rcunpacked"/>
        <xd:param name="dttype"/>
    </xd:doc>
    <xsl:template name="doAttributePredicate">
        <xsl:param name="rcunpacked" as="element()"/>
        <xsl:param name="dttype" as="xs:string?"/>
        
        <xsl:variable name="structuralAttributes" select="$rcunpacked[1]/attribute[@name = ('typeCode','classCode','moodCode','determinerCode','nullFlavor','negationInd','actionNegationInd','isCriterionInd','inversionInd','contextControlCode','contextConductionInd')]" as="item()*"/>
        
        <!-- If the template builder thought it important enough to set fixed values for these structural attributes, might as well add them to the predicate -->
        <!-- If the template builder thought it important enough to set prohibited attributes, might as well add them to the predicate -->
        <xsl:for-each select="$structuralAttributes[not(@isOptional = 'true')] | $rcunpacked[1]/attribute[not(@name = 'xsi:type')][@prohibited = 'true']">
            <xsl:sort select="@name"/>
            <xsl:variable name="theDatatype" as="xs:string">
                <xsl:choose>
                    <xsl:when test="@datatype">
                        <xsl:value-of select="@datatype"/>
                    </xsl:when>
                    <xsl:when test="@name = 'qualifier'">set_cs</xsl:when>
                    <xsl:when test="@name = 'use'">set_cs</xsl:when>
                    <!-- DTr2 -->
                    <xsl:when test="@name = 'capabilities'">set_cs</xsl:when>
                    <xsl:otherwise>st</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="theValues" as="xs:string*">
                <xsl:for-each select="@value | vocabulary/@code">
                    <xsl:for-each select="tokenize(., '\|')">
                        <xsl:if test="string-length(normalize-space(.)) gt 0">
                            <xsl:value-of select="replace(normalize-space(.), '''', '''''')"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="theExpr" as="xs:string*">
                <xsl:choose>
                    <xsl:when test="$theDatatype = 'set_cs'">
                        <xsl:text>tokenize(</xsl:text>
                        <xsl:text>@</xsl:text>
                        <xsl:value-of select="@name"/>
                        <xsl:text>, '\s')</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>@</xsl:text>
                        <xsl:value-of select="@name"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="count($theValues) gt 0">
                    <xsl:text> = </xsl:text>
                    <xsl:if test="count($theValues) gt 1">
                        <xsl:text>(</xsl:text>
                    </xsl:if>
                    <xsl:text>'</xsl:text>
                    <xsl:value-of select="string-join($theValues, ''', ''')"/>
                    <xsl:text>'</xsl:text>
                    <xsl:if test="count($theValues) gt 1">
                        <xsl:text>)</xsl:text>
                    </xsl:if>
                </xsl:if>
            </xsl:variable>
            <xsl:text>[</xsl:text>
            <xsl:choose>
                <xsl:when test="@prohibited = 'true'">
                    <xsl:text>not(</xsl:text>
                    <xsl:value-of select="string-join($theExpr, '')"/>
                    <xsl:text>)</xsl:text>
                </xsl:when>
                <xsl:when test="not(@isOptional = 'true')">
                    <xsl:value-of select="string-join($theExpr, '')"/>
                </xsl:when>
            </xsl:choose>
            <xsl:text>]</xsl:text>
        </xsl:for-each>
        <!-- Handle xsi:type -->
        <xsl:if test="$rcunpacked[1]/attribute[not(@prohibited = 'true')][not(@isOptional = 'true')][@name = ('xsi:type')]">
            <xsl:call-template name="xsiTypePredicate">
                <xsl:with-param name="dt">
                    <xsl:choose>
                        <xsl:when test="$rcunpacked[1]/attribute[not(@prohibited = 'true')][not(@isOptional = 'true')][@name = ('xsi:type')][string-length(@value)>0]">
                            <xsl:value-of select="($rcunpacked[1]/attribute[not(@prohibited = 'true')][not(@isOptional = 'true')][@name = ('xsi:type')][string-length(@value)>0]/@value)[1]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$rcunpacked[1]/@datatype"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
                <xsl:with-param name="dttype" select="$dttype"/>
                <xsl:with-param name="doAssert" select="false()"/>
                <xsl:with-param name="required" select="true()"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc/>
        <xd:param name="theElements"/>
    </xd:doc>
    <xsl:template name="doElementPredicate">
        <xsl:param name="theElements" as="element(element)*"/>
        
        <xsl:variable name="theElement" select="$theElements[not(@datatype)][@minimumMultiplicity > 0][not(@conformance = 'NP')]" as="element(element)*"/>
        
        <xsl:if test="count($theElement) = 1">
            <xsl:variable name="theExpr" as="xs:string*">
                <xsl:value-of select="$theElement/@name"/>
                <xsl:if test="not(contains($theElement/@name, '['))">
                    <xsl:call-template name="doAttributePredicate">
                        <xsl:with-param name="rcunpacked" select="$theElement"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:variable>
            <xsl:variable name="isRequiredNoNull" select="$theElement[not(@isMandatory = 'true')][not(attribute[@name = 'nullFlavor'][@prohibited = 'true'])]"/>
            
            <xsl:text>[</xsl:text>
            <xsl:choose>
                <xsl:when test="$theElement/@conformance = 'NP'">
                    <xsl:text>not(</xsl:text>
                    <xsl:value-of select="string-join($theExpr, '')"/>
                    <xsl:text>)</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="string-join($theExpr, '')"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>]</xsl:text>
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc/>
        <xd:param name="theElement"/>
    </xd:doc>
    <xsl:template name="doIdElementPredicate">
        <xsl:param name="theElement" as="element()"/>
        
        <xsl:if test="not(contains($theElement/@name, '['))">
            <xsl:text>[@root = '</xsl:text>
            <xsl:value-of select="($theElement/attribute/@root[string-length() &gt; 0] | $theElement/attribute[@name = 'root']/@value[string-length() &gt; 0])[1]"/>
            <xsl:text>']</xsl:text>
            <xsl:if test="$theElement/attribute[not(@prohibited = 'true')][not(@isOptional = 'true')][@extension[string-length() &gt; 0]] | $theElement/attribute[not(@prohibited = 'true')][not(@isOptional = 'true')][@name = 'extension'][@value[string-length() &gt; 0]]">
                <xsl:text>[@extension = '</xsl:text>
                <xsl:value-of select="($theElement/attribute[not(@prohibited = 'true')][not(@isOptional = 'true')]/@extension[string-length() &gt; 0] | $theElement/attribute[not(@prohibited = 'true')][not(@isOptional = 'true')][@name = 'extension']/@value[string-length() &gt; 0])[1]"/>
                <xsl:text>']</xsl:text>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc/>
        <xd:param name="theElement"/>
        <xd:param name="isMandatoryAttr"/>
    </xd:doc>
    <xsl:template name="doCodeElementPredicate">
        <xsl:param name="theElement" as="element()"/>
        <xsl:param name="isMandatoryAttr" as="xs:boolean"/>
        
        <xsl:if test="not(contains($theElement/@name, '['))">
            <xsl:variable name="selectors" as="xs:string*">
                <xsl:variable name="vocabs" select="$theElement/vocabulary[@code | @codeSystem | @valueSet]" as="element()*"/>
                <xsl:variable name="attribs" select="$theElement/attribute[not(@prohibited = 'true')][not(@isOptional = 'true')][@name = ('code', 'codeSystem')][string-length(@value) > 0]" as="element()*"/>
                <xsl:for-each select="$vocabs | $attribs">
                    <xsl:variable name="theItem" select="@name"/>
                    <xsl:variable name="selector" as="xs:string*">
                        <xsl:choose>
                            <xsl:when test=".[name() = 'vocabulary'][@code][@codeSystem]">
                                <xsl:text>(@code = '</xsl:text>
                                <xsl:value-of select="@code"/>
                                <xsl:text>' and @codeSystem = '</xsl:text>
                                <xsl:value-of select="@codeSystem"/>
                                <xsl:text>')</xsl:text>
                            </xsl:when>
                            <xsl:when test=".[name() = 'vocabulary'][@codeSystem]">
                                <xsl:text>@codeSystem = '</xsl:text>
                                <xsl:value-of select="@codeSystem"/>
                                <xsl:text>'</xsl:text>
                            </xsl:when>
                            <xsl:when test=".[name() = 'vocabulary'][@code]">
                                <!-- this is easliy be underdetermined -->
                                <xsl:text>@code = '</xsl:text>
                                <xsl:value-of select="@code"/>
                                <xsl:text>'</xsl:text>
                            </xsl:when>
                            <xsl:when test=".[name() = 'vocabulary'][@valueSet]">
                                <xsl:variable name="vsdatatype" select="../@datatype"/>
                                <xsl:variable name="xvsref" select="@valueSet"/>
                                <xsl:variable name="xvsflex">
                                    <xsl:choose>
                                        <xsl:when test="@flexibility">
                                            <xsl:value-of select="@flexibility"/>
                                        </xsl:when>
                                        <xsl:otherwise>dynamic</xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <xsl:variable name="xvs">
                                    <xsl:call-template name="getValueset">
                                        <xsl:with-param name="reference" select="$xvsref"/>
                                        <xsl:with-param name="flexibility" select="$xvsflex"/>
                                    </xsl:call-template>
                                </xsl:variable>
                                <xsl:variable name="xvsid">
                                    <xsl:choose>
                                        <xsl:when test="@vsid[string-length() &gt; 0]">
                                            <xsl:value-of select="@vsid"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="($xvs/valueSet)[1]/@id"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <xsl:variable name="valueSetFileObject">
                                    <xsl:choose>
                                        <xsl:when test="$xvsflex = 'dynamic' and $bindingBehaviorValueSets = 'preserve'">
                                            <!-- generate URL as location for truly dynamic value set binding -->
                                            <xsl:value-of select="concat($bindingBehaviorValueSetsURL,'&amp;id=',$xvsid,'&amp;effectiveDate=dynamic&amp;format=xml')"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="concat($theRuntimeRelativeIncludeDir, local:doHtmlName('VS', $projectPrefix, $xvsid, $xvsflex, (), (), (), (), '.xml', 'true'))"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <xsl:choose>
                                    <xsl:when test="$xvs/valueSet[1]/completeCodeSystem/filter | $xvs/valueSet[1]/conceptList/(include|exclude)">
                                        <!-- if an intensional value set definition is included, spoil the predicate so that it is not emitted at all -->
                                        <xsl:text> containsIntensionalValueSets </xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$vsdatatype = 'CS'">
                                        <!-- If CS we do not have a codeSystem. Can check code against conceptList, but cannot check codeSystem against completeCodeSystem -->
                                        <xsl:if test="$xvs/valueSet[1][conceptList/concept]">
                                            <xsl:text>@code = doc('</xsl:text>
                                            <xsl:value-of select="$valueSetFileObject"/>
                                            <xsl:text>')//valueSet[1]/conceptList/*/@code</xsl:text>
                                        </xsl:if>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <!-- If not CS, but no datatype given or any other (assumed coded) datatype, we should find a matching conceptList/code or completeCodeSystem -->
                                        <xsl:if test="$xvs/valueSet[1]/completeCodeSystem">
                                            <xsl:text>@codeSystem = doc('</xsl:text>
                                            <xsl:value-of select="$valueSetFileObject"/>
                                            <xsl:text>')//valueSet[1]/completeCodeSystem/@codeSystem</xsl:text>
                                        </xsl:if>
                                        <xsl:if test="$xvs/valueSet[1][conceptList/concept]">
                                            <xsl:if test="$xvs/valueSet[1][completeCodeSystem]">
                                                <xsl:text> or </xsl:text>
                                            </xsl:if>
                                            <xsl:text>concat(@code, @codeSystem) = doc('</xsl:text>
                                            <xsl:value-of select="$valueSetFileObject"/>
                                            <xsl:text>')//valueSet[1]/conceptList/concept/concat(@code, @codeSystem)</xsl:text>
                                        </xsl:if>
                                        <xsl:if test="$xvs/valueSet[1][conceptList/include/@codeSystem]">
                                            <xsl:if test="$xvs/valueSet[1][completeCodeSystem | conceptList/concept]">
                                                <xsl:text> or </xsl:text>
                                            </xsl:if>
                                            <xsl:text>concat(@codeSystem) = doc('</xsl:text>
                                            <xsl:value-of select="$valueSetFileObject"/>
                                            <xsl:text>')//valueSet[1]/conceptList/include/@codeSystem</xsl:text>
                                        </xsl:if>
                                        <xsl:if test="$xvs/valueSet[1][completeCodeSystem | conceptList/concept | conceptList/include][conceptList/exception][not($isMandatoryAttr)]">
                                            <xsl:text> or </xsl:text>
                                            <xsl:text>@nullFlavor = doc('</xsl:text>
                                            <xsl:value-of select="$valueSetFileObject"/>
                                            <xsl:text>')//valueSet[1]/conceptList/exception/@code</xsl:text>
                                        </xsl:if>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <!-- code and codeSystem -->
                            <xsl:when test=".[name() = 'attribute'][@name = 'code'] and $attribs[name() = 'attribute'][@name = 'codeSystem']">
                                <xsl:text>(@code = '</xsl:text>
                                <xsl:value-of select="@value"/>
                                <xsl:text>'</xsl:text>
                                <xsl:text> and @codeSystem = '</xsl:text>
                                <xsl:value-of select="$theElement/attribute[@name = 'codeSystem']/@value"/>
                                <xsl:text>')</xsl:text>
                            </xsl:when>
                            <!-- codeSystem and code -->
                            <xsl:when test=".[name() = 'attribute'][@name = 'codeSystem'] and $attribs[name() = 'attribute'][@name = 'code']">
                                <!-- Already done through code -->
                            </xsl:when>
                            <!-- just code, no codeSystem -->
                            <xsl:when test=".[name() = 'attribute'][@name = 'code'] and not($attribs[name() = 'attribute'][@name = 'codeSystem'])">
                                <xsl:choose>
                                    <xsl:when test="contains(@value, '|')">
                                        <xsl:text>@code = ('</xsl:text>
                                        <xsl:value-of select="string-join(for $v in tokenize(@value, '\|') return normalize-space($v), ''',''')"/>
                                        <xsl:text>')</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>@code = '</xsl:text>
                                        <xsl:value-of select="normalize-space(@value)"/>
                                        <xsl:text>'</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <!-- just codeSystem, no code -->
                            <xsl:when test=".[name() = 'attribute'][@name = 'codeSystem'] and not($attribs[name() = 'attribute'][@name = 'code'])">
                                <xsl:choose>
                                    <xsl:when test="contains(@value, '|')">
                                        <xsl:text>@codeSystem = ('</xsl:text>
                                        <xsl:value-of select="string-join(for $v in tokenize(@value, '\|') return normalize-space($v), ''',''')"/>
                                        <xsl:text>')</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>@codeSystem = '</xsl:text>
                                        <xsl:value-of select="normalize-space(@value)"/>
                                        <xsl:text>'</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="logMessage">
                                    <xsl:with-param name="level" select="$logFATAL"/>
                                    <xsl:with-param name="terminate" select="true()"/>
                                    <xsl:with-param name="msg">
                                        <xsl:text>+++ where selector (predicate) unhandled coded element: </xsl:text>
                                        <xsl:value-of select="$theElement/@name"/>
                                        <xsl:text> - inspecting </xsl:text>
                                        <xsl:value-of select="name()"/>
                                        <xsl:text> - elements</xsl:text>
                                        <xsl:for-each select="$theElement/vocabulary/@*">
                                            <xsl:text> - vocabulary</xsl:text>
                                            <xsl:value-of select="concat(' ',name(.),'=&quot;',.,'&quot;')"/>
                                        </xsl:for-each>
                                        <xsl:for-each select="$theElement/attribute/@*">
                                            <xsl:text> - attribute</xsl:text>
                                            <xsl:value-of select="concat(' ',name(.),'=&quot;',.,'&quot;')"/>
                                        </xsl:for-each>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:value-of select="if (empty($selector)) then () else string-join($selector, '')"/>
                </xsl:for-each>
            </xsl:variable>
            <xsl:value-of select="if (empty($selectors)) then () else string-join($selectors[not(.='')], ' or ')"/>
            
            <xsl:if test="empty($selectors)">
                <xsl:call-template name="logMessage">
                    <xsl:with-param name="level" select="$logWARN"/>
                    <xsl:with-param name="msg">
                        <xsl:text>+++ where selector (predicate) insufficient in: </xsl:text>
                        <xsl:value-of select="$theElement/@name"/>
                        <xsl:if test="@datatype">
                            <xsl:text> - datatype </xsl:text>
                            <xsl:value-of select="@datatype"/>
                        </xsl:if>
                        <xsl:for-each select="vocabulary/@*">
                            <xsl:text> - vocabulary</xsl:text>
                            <xsl:value-of select="concat(' ',name(.),'=&quot;',.,'&quot;')"/>
                        </xsl:for-each>
                        <xsl:for-each select="attribute/@*">
                            <xsl:text> - attribute</xsl:text>
                            <xsl:value-of select="concat(' ',name(.),'=&quot;',.,'&quot;')"/>
                        </xsl:for-each>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Get predicate string based on xsi:type which is a QName so requires some more logic</xd:desc>
        <xd:param name="dt">Main datatype of the element, if any</xd:param>
        <xd:param name="doAssert">If true returns an assertion, otherwise just the predicate string</xd:param>
        <xd:param name="assertItemLabel">The itemLabel to add to the assertion text</xd:param>
        <xd:param name="assertSeeUrl">The @see url to the assertion</xd:param>
        <xd:param name="dttype">hl7v3xml1 or any other supported type</xd:param>
        <xd:param name="required">default is false(). false() allows @xsi:type to be absent. true() requires presence of @xsi:type</xd:param>
    </xd:doc>
    <xsl:template name="xsiTypePredicate">
        <xsl:param name="dt" as="xs:string?"/>
        <xsl:param name="dttype" as="xs:string?"/>
        <xsl:param name="doAssert" select="false()" as="xs:boolean"/>
        <xsl:param name="assertItemLabel"/>
        <xsl:param name="assertSeeUrl"/>
        <xsl:param name="required" select="false()" as="xs:boolean"/>
        
        <xsl:variable name="datatypeName">
            <xsl:choose>
                <xsl:when test="contains($dt, ':')">
                    <xsl:value-of select="substring-after($dt, ':')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$dt"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="datatypeType" as="xs:string">
            <xsl:choose>
                <xsl:when test="string-length($dttype) = 0">hl7v3xml1</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$dttype"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- 
             check whether dt is supported
             if not $isSupportedDatatype will be empty
             if yes $isSupportedDatatype will contain the (unflavored) data type
         -->
        <xsl:variable name="supported" select="$supportedDatatypes/*[@type = $datatypeType][@name = ($datatypeName, $dt)]" as="element()*"/>
        <xsl:variable name="isSupportedDatatype">
            <xsl:choose>
                <xsl:when test="$supported[@name = $dt][not(@isFlavorOf)]">
                    <xsl:value-of select="$dt"/>
                </xsl:when>
                <xsl:when test="$supported[@name = $dt][@isFlavorOf]">
                    <xsl:value-of select="($supported[@name = $dt]/@isFlavorOf)[1]"/>
                </xsl:when>
                <xsl:when test="$supported[@name = $datatypeName][not(@isFlavorOf)]">
                    <xsl:value-of select="$datatypeName"/>
                </xsl:when>
                <xsl:when test="$supported[@name = $datatypeName][@isFlavorOf]">
                    <xsl:value-of select="($supported[@name = $datatypeName]/@isFlavorOf)[1]"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="string-length($isSupportedDatatype) > 0 and $switchCreateDatatypeChecks = true()">
            <!--
                Get namespace-uri for the @datatype.
                1. If has namespace prefix hl7: or cda:, then must be in namespace 'urn:hl7-org:v3'
                2. If has no namespace prefix, then must be in DECOR default namespace-uri
                3. If has namespace prefix then get the namespace-uri form DECOR file
            -->
            <xsl:variable name="dfltNS">
                <xsl:choose>
                    <xsl:when test="string-length($projectDefaultElementPrefix) = 0">
                        <xsl:value-of select="'urn:hl7-org:v3'"/>
                    </xsl:when>
                    <xsl:when test="$projectDefaultElementPrefix = 'hl7:' or $projectDefaultElementPrefix = 'cda:'">
                        <xsl:value-of select="'urn:hl7-org:v3'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="namespace-uri-for-prefix(substring-before($projectDefaultElementPrefix, ':'), .)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="dtPfx" select="substring-before($dt, ':')"/>
            <xsl:variable name="dtNS">
                <xsl:choose>
                    <xsl:when test="$dtPfx = 'hl7' or $dtPfx = 'cda'">
                        <xsl:value-of select="'urn:hl7-org:v3'"/>
                    </xsl:when>
                    <xsl:when test="$dtPfx = ''">
                        <xsl:value-of select="$dfltNS"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="namespace-uri-for-prefix($dtPfx, .)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="dtVal">
                <xsl:choose>
                    <xsl:when test="contains($isSupportedDatatype, ':')">
                        <xsl:value-of select="substring-after($isSupportedDatatype, ':')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$isSupportedDatatype"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <!-- check for the presence of xsi:type (if not "ANY") and if present check correct data type requested -->
            <!-- Note that different versions of Saxon interpret QName differently. You cannot assume that casting @xsi:type to QName works, hence the substring-* functions -->
            <xsl:if test="$isSupportedDatatype != 'ANY' and string-length(normalize-space($dtNS)) gt 0">
                <xsl:variable name="predicateString">
                    <xsl:if test="not($required)">
                        <xsl:text>empty(@xsi:type) or </xsl:text>
                    </xsl:if>
                    <xsl:text>resolve-QName(@xsi:type, .) = QName('</xsl:text>
                    <xsl:value-of select="$dtNS"/>
                    <xsl:text>', '</xsl:text>
                    <xsl:value-of select="$dtVal"/>
                    <xsl:text>')</xsl:text>
                </xsl:variable>
                
                <xsl:choose>
                    <xsl:when test="$doAssert">
                        <assert xmlns="http://purl.oclc.org/dsdl/schematron" role="error" see="{$assertSeeUrl}" test="{$predicateString}">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'datatypeXSIShallBe'"/>
                                <xsl:with-param name="p1" select="$assertItemLabel"/>
                                <xsl:with-param name="p2">
                                    <xsl:text>{</xsl:text>
                                    <xsl:value-of select="$dtNS"/>
                                    <xsl:text>}:</xsl:text>
                                    <xsl:value-of select="$dtVal"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </assert>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat('[',string-join($predicateString,''),']')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Merges two templates. At every level you first get the calling template attributes and then the called template attributes, after that first caller, then called template.</xd:p>
            <xd:p>Optionally stops merging at a given maxlevel. This is useful for getWherePathFromNodeset that doesn't go deeper than level 3. After reaching maxlevel the rest just copied in as-is.</xd:p>
        </xd:desc>
        <xd:param name="rc"/>
        <xd:param name="sofar"/>
        <xd:param name="level"/>
        <xd:param name="maxlevel"/>
    </xd:doc>
    <xsl:template name="mergeTemplates">
        <xsl:param name="rc" as="element()?"/>
        <xsl:param name="sofar" as="xs:string*"/>
        <xsl:param name="level" as="xs:integer"/>
        <xsl:param name="maxlevel" as="xs:integer?"/>
        
        <xsl:choose>
            <xsl:when test="not(empty($maxlevel)) and $level > $maxlevel">
                <xsl:copy>
                    <xsl:copy-of select="$rc/@* except (@contains | @flexibility)" copy-namespaces="no"/>
                    <xsl:copy-of select="$rc/attribute | $rc/element | $rc/include | $rc/choice | $rc/let | $rc/defineVariable | $rc/assert | $rc/report | $rc/vocabulary | $rc/text"/>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="$rc/self::attribute">
                <xsl:apply-templates select="$rc" mode="NORMALIZE"/>
            </xsl:when>
            <xsl:when test="$rc/self::element[@contains]">
                <!-- lookup contained template content -->
                <xsl:variable name="rctemp" as="element()?">
                    <xsl:call-template name="getRulesetContent">
                        <xsl:with-param name="ruleset" select="$rc/@contains"/>
                        <xsl:with-param name="flexibility" select="$rc/@flexibility"/>
                        <xsl:with-param name="sofar" select="$sofar"/>
                    </xsl:call-template>
                </xsl:variable>
                <!-- merge stuff -->
                <xsl:copy>
                    <xsl:copy-of select="$rc/@* except (@contains | @flexibility)" copy-namespaces="no"/>
                    <xsl:for-each select="$rc/vocabulary | $rctemp/vocabulary">
                        <xsl:call-template name="mergeTemplates">
                            <xsl:with-param name="rc" select="."/>
                            <xsl:with-param name="sofar" select="$sofar"/>
                            <xsl:with-param name="level" select="$level"/>
                            <xsl:with-param name="maxlevel" select="$maxlevel"/>
                        </xsl:call-template>
                    </xsl:for-each>
                    <xsl:for-each select="$rc/text | $rctemp/text">
                        <xsl:call-template name="mergeTemplates">
                            <xsl:with-param name="rc" select="."/>
                            <xsl:with-param name="sofar" select="$sofar"/>
                            <xsl:with-param name="level" select="$level"/>
                            <xsl:with-param name="maxlevel" select="$maxlevel"/>
                        </xsl:call-template>
                    </xsl:for-each>
                    <xsl:for-each select="$rc/attribute | $rctemp/attribute">
                        <xsl:call-template name="mergeTemplates">
                            <xsl:with-param name="rc" select="."/>
                            <xsl:with-param name="sofar" select="$sofar"/>
                            <xsl:with-param name="level" select="$level"/>
                            <xsl:with-param name="maxlevel" select="$maxlevel"/>
                        </xsl:call-template>
                    </xsl:for-each>
                    <xsl:for-each select="$rc/element | $rc/include | $rc/choice | $rc/let | $rc/defineVariable | $rc/assert | $rc/report">
                        <xsl:call-template name="mergeTemplates">
                            <xsl:with-param name="rc" select="."/>
                            <xsl:with-param name="sofar" select="$sofar"/>
                            <xsl:with-param name="level" select="$level"/>
                            <xsl:with-param name="maxlevel" select="$maxlevel"/>
                        </xsl:call-template>
                    </xsl:for-each>
                    <xsl:for-each select="$rctemp/element | $rctemp/include | $rctemp/choice | $rctemp/let | $rctemp/defineVariable | $rctemp/assert | $rctemp/report">
                        <xsl:call-template name="mergeTemplates">
                            <xsl:with-param name="rc" as="element()">
                                <xsl:choose>
                                    <!-- Do override of minimumMultiplicity only when not @conformance = 'NP', @minimumMultiplicity not already > 0 and if there are no other elements/includes/choices -->
                                    <xsl:when test="self::element[not(@minimumMultiplicity > 0)][not(@conformance = 'NP')][not(preceding-sibling::*[name() = ('element','include','choice')] | following-sibling::*[name() = ('element','include','choice')])]">
                                        <xsl:copy>
                                            <xsl:copy-of select="@*"/>
                                            <!-- Do override only when not @conformance = 'NP' -->
                                            <xsl:if test="not(@conformance = 'NP')">
                                                <xsl:attribute name="minimumMultiplicity" select="1"/>
                                                <xsl:attribute name="maximumMultiplicity" select="1"/>
                                            </xsl:if>
                                            <xsl:copy-of select="node()"/>
                                        </xsl:copy>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:copy-of select="."/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:with-param>
                            <xsl:with-param name="sofar" select="$sofar, concat($rctemp/@id,'-',$rctemp/@effectiveDate)"/>
                            <xsl:with-param name="level" select="$level + 1"/>
                            <xsl:with-param name="maxlevel" select="$maxlevel"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="$rc/self::element">
                <xsl:copy>
                    <xsl:copy-of select="$rc/@*" copy-namespaces="no"/>
                    <xsl:for-each select="$rc/attribute">
                        <xsl:call-template name="mergeTemplates">
                            <xsl:with-param name="rc" select="."/>
                            <xsl:with-param name="sofar" select="$sofar"/>
                            <xsl:with-param name="level" select="$level"/>
                            <xsl:with-param name="maxlevel" select="$maxlevel"/>
                        </xsl:call-template>
                    </xsl:for-each>
                    <xsl:for-each select="$rc/element | $rc/include | $rc/choice | $rc/let | $rc/defineVariable | $rc/assert | $rc/report | $rc/vocabulary | $rc/text">
                        <xsl:call-template name="mergeTemplates">
                            <xsl:with-param name="rc" select="."/>
                            <xsl:with-param name="sofar" select="$sofar"/>
                            <xsl:with-param name="level" select="$level"/>
                            <xsl:with-param name="maxlevel" select="$maxlevel"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="$rc/self::include">
                <xsl:variable name="min" select="@minimumMultiplicity[not(. = '')]"/>
                <xsl:variable name="max" select="@maximumMultiplicity[not(. = '')]"/>
                <xsl:variable name="conf" select="@conformance[not(. = '')]"/>
                <xsl:variable name="mand" select="@isMandatory[not(. = '')]"/>
                <xsl:variable name="rctemp" as="element()*">
                    <xsl:call-template name="getRulesetContent">
                        <xsl:with-param name="ruleset" select="@ref"/>
                        <xsl:with-param name="flexibility" select="@flexibility"/>
                        <xsl:with-param name="sofar" select="$sofar"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:for-each select="$rctemp/attribute">
                    <xsl:call-template name="mergeTemplates">
                        <xsl:with-param name="rc" select="."/>
                        <xsl:with-param name="sofar" select="$sofar, concat($rctemp/@id,'-',$rctemp/@effectiveDate)"/>
                        <xsl:with-param name="level" select="$level + 1"/>
                        <xsl:with-param name="maxlevel" select="$maxlevel"/>
                    </xsl:call-template>
                </xsl:for-each>
                <xsl:for-each select="$rctemp/element | $rctemp/include | $rctemp/choice | $rctemp/let | $rctemp/defineVariable | $rctemp/assert | $rctemp/report | $rctemp/vocabulary | $rctemp/text">
                    <xsl:call-template name="mergeTemplates">
                        <xsl:with-param name="rc" as="element()">
                            <xsl:choose>
                                <xsl:when test="self::element">
                                    <xsl:copy copy-namespaces="no">
                                        <xsl:copy-of select="@*" copy-namespaces="no"/>
                                        <!-- Do override only when not @conformance = 'NP' -->
                                        <xsl:if test="not(@conformance = 'NP')">
                                            <xsl:copy-of select="$min" copy-namespaces="no"/>
                                            <xsl:copy-of select="$max" copy-namespaces="no"/>
                                            <xsl:copy-of select="$conf" copy-namespaces="no"/>
                                            <xsl:copy-of select="$mand" copy-namespaces="no"/>
                                        </xsl:if>
                                        <xsl:copy-of select="node()" copy-namespaces="no"/>
                                    </xsl:copy>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:copy-of select="."/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                        <xsl:with-param name="sofar" select="$sofar, concat($rctemp/@id,'-',$rctemp/@effectiveDate)"/>
                        <xsl:with-param name="level" select="$level + 1"/>
                        <xsl:with-param name="maxlevel" select="$maxlevel"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$rc/self::choice">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:for-each select="$rc/attribute | $rc/element | $rc/include | $rc/choice | $rc/let | $rc/defineVariable | $rc/assert | $rc/report">
                        <xsl:call-template name="mergeTemplates">
                            <xsl:with-param name="rc" select="."/>
                            <xsl:with-param name="sofar" select="$sofar"/>
                            <xsl:with-param name="level" select="$level"/>
                            <xsl:with-param name="maxlevel" select="$maxlevel"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="$rc/self::template">
                <xsl:for-each select="$rc/attribute">
                    <xsl:call-template name="mergeTemplates">
                        <xsl:with-param name="rc" select="."/>
                        <xsl:with-param name="sofar" select="$sofar"/>
                        <xsl:with-param name="level" select="$level"/>
                        <xsl:with-param name="maxlevel" select="$maxlevel"/>
                    </xsl:call-template>
                </xsl:for-each>
                <xsl:for-each select="$rc/element | $rc/include | $rc/choice | $rc/let | $rc/defineVariable | $rc/assert | $rc/report | $rc/vocabulary | $rc/text">
                    <xsl:call-template name="mergeTemplates">
                        <xsl:with-param name="rc" select="."/>
                        <xsl:with-param name="sofar" select="$sofar"/>
                        <xsl:with-param name="level" select="$level"/>
                        <xsl:with-param name="maxlevel" select="$maxlevel"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$rc"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc/>
        <xd:param name="string"/>
        <xd:param name="char"/>
    </xd:doc>
    <xsl:template name="lastIndexOf">
        <!-- declare that it takes two parameters - the string and the char -->
        <xsl:param name="string"/>
        <xsl:param name="char"/>
        <xsl:choose>
            <!-- if the string contains the character... -->
            <xsl:when test="contains($string, $char)">
                <!-- call the template recursively... -->
                <xsl:call-template name="lastIndexOf">
                    <!-- with the string being the string after the character
                    -->
                    <xsl:with-param name="string" select="substring-after($string, $char)"/>
                    <!-- and the character being the same as before -->
                    <xsl:with-param name="char" select="$char"/>
                </xsl:call-template>
            </xsl:when>
            <!-- otherwise, return the value of the string -->
            <xsl:otherwise>
                <xsl:value-of select="$string"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
        <xd:param name="str"/>
        <xd:param name="del"/>
        <xd:param name="preceedIndent"/>
    </xd:doc>
    <xsl:template name="splitString">
        <xsl:param name="str"/>
        <xsl:param name="del"/>
        <xsl:param name="preceedIndent"/>
        <xsl:variable name="xstr1">
            <!-- never split / -->
            <xsl:value-of select="replace($str, '/', '%%1')"/>
        </xsl:variable>
        <xsl:variable name="xstr2">
            <!-- never split /@ attribute -->
            <xsl:value-of select="replace($xstr1, '/@', '%%2')"/>
        </xsl:variable>
        <xsl:variable name="x">
            <xsl:call-template name="tokenize">
                <xsl:with-param name="string" select="$xstr2"/>
                <xsl:with-param name="delimiters" select="$del"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:for-each select="$x/token">
            <xsl:call-template name="repeatString">
                <xsl:with-param name="number" select="count(preceding-sibling::node())"/>
                <xsl:with-param name="theString" select="$preceedIndent"/>
            </xsl:call-template>
            <!-- replace placeholders again -->
            <xsl:variable name="xstr3">
                <xsl:value-of select="replace(., '%%1', '/')"/>
            </xsl:variable>
            <xsl:value-of select="replace($xstr3, '%%2', '/@')"/>
            <br xmlns="http://www.w3.org/1999/xhtml"/>
        </xsl:for-each>
    </xsl:template>
    
    <xd:doc>
        <xd:desc> output # of strings (repeat) </xd:desc>
        <xd:param name="number"/>
        <xd:param name="theString"/>
    </xd:doc>
    <xsl:template name="repeatString">
        <xsl:param name="number"/>
        <xsl:param name="theString"/>
        <xsl:for-each select="1 to $number">
            <xsl:value-of select="$theString"/>
        </xsl:for-each>
    </xsl:template>
    
    <xd:doc>
        <xd:desc> tokenize functions </xd:desc>
        <xd:param name="string"/>
        <xd:param name="delimiters"/>
    </xd:doc>
    <xsl:template name="tokenize">
        <xsl:param name="string" select="''"/>
        <xsl:param name="delimiters" select="' &#x9;&#xA;'"/>
        <xsl:choose>
            <xsl:when test="not($string)"/>
            <xsl:when test="not($delimiters)">
                <xsl:call-template name="tokenize-characters">
                    <xsl:with-param name="string" select="$string"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="tokenize-delimiters">
                    <xsl:with-param name="string" select="$string"/>
                    <xsl:with-param name="delimiters" select="$delimiters"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
        <xd:param name="string"/>
    </xd:doc>
    <xsl:template name="tokenize-characters">
        <xsl:param name="string"/>
        <xsl:if test="$string">
            <token xmlns="">
                <xsl:value-of select="substring($string, 1, 1)"/>
            </token>
            <xsl:call-template name="tokenize-characters">
                <xsl:with-param name="string" select="substring($string, 2)"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
        <xd:param name="string"/>
        <xd:param name="delimiters"/>
    </xd:doc>
    <xsl:template name="tokenize-delimiters">
        <xsl:param name="string"/>
        <xsl:param name="delimiters"/>
        <xsl:variable name="delimiter" select="substring($delimiters, 1, 1)"/>
        <xsl:choose>
            <xsl:when test="not($delimiter)">
                <token xmlns="">
                    <xsl:value-of select="$string"/>
                </token>
            </xsl:when>
            <xsl:when test="contains($string, $delimiter)">
                <xsl:if test="not(starts-with($string, $delimiter))">
                    <xsl:call-template name="tokenize-delimiters">
                        <xsl:with-param name="string" select="substring-before($string, $delimiter)"/>
                        <xsl:with-param name="delimiters" select="substring($delimiters, 2)"/>
                    </xsl:call-template>
                </xsl:if>
                <xsl:call-template name="tokenize-delimiters">
                    <xsl:with-param name="string" select="substring-after($string, $delimiter)"/>
                    <xsl:with-param name="delimiters" select="$delimiters"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="tokenize-delimiters">
                    <xsl:with-param name="string" select="$string"/>
                    <xsl:with-param name="delimiters" select="substring($delimiters, 2)"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
        <xd:param name="elem"/>
        <xd:param name="rdm"/>
    </xd:doc>
    <xsl:function name="local:randomString2">
        <!-- gid parameter is dummy to prevent caching of doc() -->
        <xsl:param name="elem" as="element()"/>
        <xsl:param name="rdm" as="item()?"/>
        <xsl:variable name="gid" select="generate-id($elem)"/>
        <!--<xsl:value-of select="if (doc-available('https://art-decor.org/decor/services/modules/random-string.xquery')) then doc(concat('https://art-decor.org/decor/services/modules/random-string.xquery?', $gid))/random/text() else $gid"/>-->
        <xsl:variable name="rdmelm" as="element()">
            <xsl:element name="{$elem/name()}">
                <xsl:copy-of select="$elem/@*"/>
                <xsl:comment/>
                <xsl:copy-of select="$elem/node()"/>
            </xsl:element>
        </xsl:variable>
        <xsl:value-of select="string-join((generate-id($elem),string($rdm),generate-id($rdmelm)),'-')"/>
        <!--
        <xsl:message>
            <xsl:value-of select="$r"/>
        </xsl:message>
        -->
    </xsl:function>
    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template name="local:randomString">
        <!--
        <xsl:value-of select="uuid:randomUUID()"/>
        -->
    </xsl:template>
    <xd:doc>
        <xd:desc/>
        <xd:param name="msg"/>
        <xd:param name="level"/>
        <xd:param name="terminate"/>
    </xd:doc>
    <xsl:template name="logMessage">
        <xsl:param name="msg" as="item()*"/>
        <xsl:param name="level" select="$logINFO" as="xs:string"/>
        <xsl:param name="terminate" select="false()" as="xs:boolean"/>
        <xsl:variable name="term" select="if ($terminate) then 'yes' else 'no'"/>
        <xsl:if test="$term='yes'">
            <!-- we'll gonna die anyway, write a survivor document for later post processing -->
            <xsl:result-document href="{$theRuntimeDir}last-survivor-message.xml" format="xml" indent="yes">
                <last level="{$level}">
                    <xsl:copy-of select="$msg"/>
                </last>
            </xsl:result-document>
        </xsl:if>
        <xsl:if test="$term='yes' or ($logLevelMap/level[@name=$level]/number(@int) &lt;= $logLevelMap/level[@name=$chkdLogLevel]/number(@int))">
            <!-- must die if to be terminated on message -->
            <xsl:message terminate="{$term}">
                <!-- Avoid unnecessary strain on time service. Only log time based from INFO -->
                <!--<xsl:if test="$lvl=$logINFO">
                    <xsl:value-of select="doc('https://art-decor.org/decor/services/modules/current-milliseconds.xquery?format=string')"/>
                    <xsl:text> </xsl:text>
                </xsl:if>-->
                <xsl:value-of select="substring(concat($level,'        '),1,7)"/>
                <xsl:text>: </xsl:text>
                <xsl:copy-of select="$msg"/>
            </xsl:message>
        </xsl:if>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
        <xd:param name="id"/>
        <xd:param name="effectiveDate"/>
    </xd:doc>
    <xsl:function name="local:getDataset" as="element(dataset)?">
        <xsl:param name="id" as="xs:string"/>
        <xsl:param name="effectiveDate" as="xs:string?"/>
        <xsl:variable name="datasets" select="$allDatasets/dataset[@id=$id]" as="element(dataset)*"/>
        <xsl:choose>
            <xsl:when test="$effectiveDate castable as xs:dateTime">
                <xsl:copy-of select="$datasets[@effectiveDate=$effectiveDate]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$datasets[@effectiveDate=string(max($datasets/xs:dateTime(@effectiveDate)))][1]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xd:doc>
        <xd:desc/>
        <xd:param name="id"/>
        <xd:param name="effectiveDate"/>
    </xd:doc>
    <xsl:function name="local:getDatasetFlat" as="element(dataset)?">
        <xsl:param name="id" as="xs:string"/>
        <xsl:param name="effectiveDate" as="xs:string?"/>
        <xsl:variable name="datasets" select="$allDatasetConceptsFlat/*/dataset[@id=$id]" as="element(dataset)*"/>
        <xsl:choose>
            <xsl:when test="$effectiveDate castable as xs:dateTime">
                <xsl:copy-of select="$datasets[@effectiveDate=$effectiveDate]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$datasets[@effectiveDate=string(max($datasets/xs:dateTime(@effectiveDate)))][1]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xd:doc>
        <xd:desc/>
        <xd:param name="id"/>
        <xd:param name="effectiveDate"/>
    </xd:doc>
    <xsl:function name="local:getDatasetForConcept" as="element(dataset)?">
        <xsl:param name="id" as="xs:string?"/>
        <xsl:param name="effectiveDate" as="xs:string?"/>
        <xsl:variable name="datasets" select="$allDatasets/dataset" as="element(dataset)*"/>
        <xsl:variable name="concepts" select="$datasets//concept[@id=$id][not(ancestor::history)]" as="element(concept)*"/>
        <xsl:choose>
            <xsl:when test="$effectiveDate castable as xs:dateTime">
                <xsl:copy-of select="$concepts[@effectiveDate=$effectiveDate]/ancestor::dataset"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$concepts[@effectiveDate=string(max($concepts/xs:dateTime(@effectiveDate)))][1]/ancestor::dataset"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xd:doc>
        <xd:desc/>
        <xd:param name="id"/>
        <xd:param name="effectiveDate"/>
    </xd:doc>
    <xsl:function name="local:getDatasetFlatForConcept" as="element(dataset)?">
        <xsl:param name="id" as="xs:string"/>
        <xsl:param name="effectiveDate" as="xs:string?"/>
        <xsl:variable name="datasets" select="$allDatasetConceptsFlat/*/dataset" as="element(dataset)*"/>
        <xsl:variable name="concepts" select="$datasets//concept[@id=$id][not(ancestor::history)]" as="element(concept)*"/>
        <xsl:choose>
            <xsl:when test="$effectiveDate castable as xs:dateTime">
                <xsl:copy-of select="$concepts[@effectiveDate=$effectiveDate]/ancestor::dataset"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$concepts[@effectiveDate=string(max($concepts/xs:dateTime(@effectiveDate)))][1]/ancestor::dataset"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xd:doc>
        <xd:desc/>
        <xd:param name="id"/>
        <xd:param name="effectiveDate"/>
    </xd:doc>
    <xsl:function name="local:getConcept" as="element(concept)?">
        <xsl:param name="id" as="xs:string"/>
        <xsl:param name="effectiveDate" as="xs:string?"/>
        <xsl:copy-of select="local:getConcept($id, $effectiveDate, (), ())"/>
    </xsl:function>
    <xd:doc>
        <xd:desc/>
        <xd:param name="id"/>
        <xd:param name="effectiveDate"/>
        <xd:param name="datasetId"/>
        <xd:param name="datasetEffectiveDate"/>
    </xd:doc>
    <xsl:function name="local:getConcept" as="element(concept)?">
        <xsl:param name="id" as="xs:string"/>
        <xsl:param name="effectiveDate" as="xs:string?"/>
        <xsl:param name="datasetId" as="xs:string?"/>
        <xsl:param name="datasetEffectiveDate" as="xs:string?"/>
        <xsl:variable name="datasets" select="if (string-length($datasetId)&gt;0) then (local:getDataset($datasetId, $datasetEffectiveDate)) else $allDatasets/dataset" as="element(dataset)*"/>
        <xsl:variable name="concepts" select="$datasets//concept[@id=$id][not(ancestor::history)]" as="element(concept)*"/>
        <xsl:choose>
            <xsl:when test="$effectiveDate castable as xs:dateTime">
                <xsl:copy-of select="$concepts[@effectiveDate=$effectiveDate]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$concepts[@effectiveDate=string(max($concepts/xs:dateTime(@effectiveDate)))][1]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xd:doc>
        <xd:desc/>
        <xd:param name="id"/>
        <xd:param name="effectiveDate"/>
    </xd:doc>
    <xsl:function name="local:getConceptFlat" as="element(concept)?">
        <xsl:param name="id" as="xs:string"/>
        <xsl:param name="effectiveDate" as="xs:string?"/>
        <xsl:copy-of select="local:getConceptFlat($id, $effectiveDate, (), ())"/>
    </xsl:function>
    <xd:doc>
        <xd:desc/>
        <xd:param name="id"/>
        <xd:param name="effectiveDate"/>
        <xd:param name="datasetId"/>
        <xd:param name="datasetEffectiveDate"/>
    </xd:doc>
    <xsl:function name="local:getConceptFlat" as="element(concept)?">
        <xsl:param name="id" as="xs:string"/>
        <xsl:param name="effectiveDate" as="xs:string?"/>
        <xsl:param name="datasetId" as="xs:string?"/>
        <xsl:param name="datasetEffectiveDate" as="xs:string?"/>
        <xsl:variable name="datasets" select="if (string-length($datasetId)&gt;0) then (local:getDatasetFlat($datasetId, $datasetEffectiveDate)) else $allDatasetConceptsFlat/*/dataset" as="element(dataset)*"/>
        <xsl:variable name="concepts" select="$datasets//concept[@id=$id][not(ancestor::history)]" as="element(concept)*"/>
        <xsl:choose>
            <xsl:when test="$effectiveDate castable as xs:dateTime">
                <xsl:copy-of select="$concepts[@effectiveDate=$effectiveDate]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$concepts[@effectiveDate=string(max($concepts/xs:dateTime(@effectiveDate)))][1]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xd:doc>
        <xd:desc/>
        <xd:param name="id"/>
        <xd:param name="datasetId"/>
        <xd:param name="datasetEffectiveDate"/>
    </xd:doc>
    <xsl:function name="local:getConceptListConcept" as="element(concept)?">
        <xsl:param name="id" as="xs:string"/>
        <xsl:param name="datasetId" as="xs:string?"/>
        <xsl:param name="datasetEffectiveDate" as="xs:string?"/>
        <xsl:variable name="datasets" select="if (string-length($datasetId)&gt;0) then (local:getDataset($datasetId, $datasetEffectiveDate)) else $allDatasets/dataset" as="element(dataset)*"/>
        <xsl:copy-of select="$datasets//concept[@id=$id][not(ancestor::history)][ancestor::conceptList][1]"/>
    </xsl:function>
    <xd:doc>
        <xd:desc/>
        <xd:param name="id"/>
        <xd:param name="effectiveDate"/>
    </xd:doc>
    <xsl:function name="local:getConceptOrConceptList" as="element()?">
        <xsl:param name="id" as="xs:string"/>
        <xsl:param name="effectiveDate" as="xs:string?"/>
        <xsl:copy-of select="local:getConceptOrConceptList($id, $effectiveDate, (), ())"/>
    </xsl:function>
    <xd:doc>
        <xd:desc/>
        <xd:param name="id"/>
        <xd:param name="effectiveDate"/>
        <xd:param name="datasetId"/>
        <xd:param name="datasetEffectiveDate"/>
    </xd:doc>
    <xsl:function name="local:getConceptOrConceptList" as="element()?">
        <xsl:param name="id" as="xs:string"/>
        <xsl:param name="effectiveDate" as="xs:string?"/>
        <xsl:param name="datasetId" as="xs:string?"/>
        <xsl:param name="datasetEffectiveDate" as="xs:string?"/>
        <xsl:variable name="datasets" select="if (string-length($datasetId)&gt;0) then (local:getDataset($datasetId, $datasetEffectiveDate)) else $allDatasets/dataset" as="element(dataset)*"/>
        <xsl:variable name="concepts" select="$datasets//*[@id=$id][not(ancestor::history)]" as="element()*"/>
        <xsl:choose>
            <xsl:when test="$effectiveDate castable as xs:dateTime">
                <xsl:copy-of select="$concepts[@effectiveDate=$effectiveDate]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$concepts[@effectiveDate=string(max($concepts/xs:dateTime(@effectiveDate)))][1]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xd:doc>
        <xd:desc> 0..* or 0..* Mandatory (conformance therefor is optional) </xd:desc>
        <xd:param name="concept"/>
        <xd:param name="language"/>
    </xd:doc>
    <xsl:function name="local:getCardConf" as="xs:string">
        <xsl:param name="concept" as="element()"/>
        <xsl:param name="language" as="xs:string"/>
        <xsl:value-of select="string-join((concat(local:getMinimumMultiplicity($concept),'&#160;…&#160;',local:getMaximumMultiplicity($concept)),local:getConformance($concept, $language)),' ')"/>
    </xsl:function>
    <xd:doc>
        <xd:desc/>
        <xd:param name="minimumMultiplicity"/>
        <xd:param name="maximumMultiplicity"/>
        <xd:param name="conformance"/>
        <xd:param name="isMandatory"/>
    </xd:doc>
    <xsl:function name="local:getCardConf" as="xs:string">
        <xsl:param name="minimumMultiplicity" as="xs:string?"/>
        <xsl:param name="maximumMultiplicity" as="xs:string?"/>
        <xsl:param name="conformance" as="xs:string?"/>
        <xsl:param name="isMandatory" as="xs:string?"/>
        <xsl:variable name="concept" as="element()">
            <concept xmlns="">
                <xsl:if test="string-length($conformance) &gt; 0">
                    <xsl:attribute name="conformance" select="$conformance"/>
                </xsl:if>
                <xsl:if test="string-length($isMandatory) &gt; 0">
                    <xsl:attribute name="isMandatory" select="($isMandatory='true')"/>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="$conformance = 'C'">
                        <condition>
                            <xsl:if test="string-length($minimumMultiplicity) &gt; 0">
                                <xsl:attribute name="minimumMultiplicity" select="$minimumMultiplicity"/>
                            </xsl:if>
                            <xsl:if test="string-length($maximumMultiplicity) &gt; 0">
                                <xsl:attribute name="maximumMultiplicity" select="$maximumMultiplicity"/>
                            </xsl:if>
                        </condition>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="string-length($minimumMultiplicity) &gt; 0">
                            <xsl:attribute name="minimumMultiplicity" select="$minimumMultiplicity"/>
                        </xsl:if>
                        <xsl:if test="string-length($maximumMultiplicity) &gt; 0">
                            <xsl:attribute name="maximumMultiplicity" select="$maximumMultiplicity"/>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </concept>
        </xsl:variable>
        <xsl:variable name="card" as="xs:string?">
            <xsl:choose>
                <xsl:when test="$conformance='NP'">
                    <xsl:text>0&#160;…&#160;0</xsl:text>
                </xsl:when>
                <xsl:when test="string-length($minimumMultiplicity)&gt;0 or string-length($maximumMultiplicity)&gt;0">
                    <xsl:value-of select="string-join(($minimumMultiplicity,$maximumMultiplicity),'&#160;…&#160;')"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="conf" as="xs:string?">
            <xsl:choose>
                <xsl:when test="$isMandatory='true' and not($conformance='NP')">
                    <xsl:call-template name="getMessage">
                        <xsl:with-param name="key" select="'conformanceMandatory'"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="string-length($conformance)&gt;0">
                    <xsl:call-template name="getXFormsLabel">
                        <xsl:with-param name="simpleTypeKey" select="'ConformanceType'"/>
                        <xsl:with-param name="lang" select="$defaultLanguage"/>
                        <xsl:with-param name="simpleTypeValue" select="$conformance"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="string-join(($card,$conf),'&#160;')"/>
    </xsl:function>
    <xd:doc>
        <xd:desc/>
        <xd:param name="concept"/>
    </xd:doc>
    <xsl:function name="local:getMinimumMultiplicity" as="xs:string">
        <xsl:param name="concept" as="element()"/>
        
        <!-- Get (minimum) minimumMultiplicity, possibly from condition. Default if absent is 0 -->
        <xsl:choose>
            <xsl:when test="$concept[enableWhen] | $concept[@conformance='NP'] | $concept[condition/@conformance='NP'] | $concept[conditionalConcept/@conformance='NP'] | $concept[@prohibited='true'] | $concept[@isOptional='true']">
                <xsl:text>0</xsl:text>
            </xsl:when>
            <xsl:when test="$concept[self::attribute]">
                <xsl:text>1</xsl:text>
            </xsl:when>
            <xsl:when test="$concept[@minimumMultiplicity][not(condition | conditionalConcept)]">
                <xsl:value-of select="$concept/@minimumMultiplicity"/>
            </xsl:when>
            <xsl:when test="$concept[not(@minimumMultiplicity)][not(@conformance='C')]">
                <xsl:text>0</xsl:text>
            </xsl:when>
            <xsl:when test="$concept[@conformance='C'][condition[@minimumMultiplicity='0'] | conditionalConcept[@minimumMultiplicity='0']] | $concept[@conformance='C'][condition][not(condition[@minimumMultiplicity])] | $concept[@conformance='C'][conditionalConcept][not(conditionalConcept[@minimumMultiplicity])]">
                <xsl:text>0</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="min" select="string(min(($concept/condition[@minimumMultiplicity]/number(@minimumMultiplicity),$concept/conditionalConcept[@minimumMultiplicity]/number(@minimumMultiplicity))))"/>
                
                <xsl:choose>
                    <xsl:when test="$min = ''">0</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$min"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xd:doc>
        <xd:desc/>
        <xd:param name="concept"/>
    </xd:doc>
    <xsl:function name="local:getMaximumMultiplicity" as="xs:string">
        <xsl:param name="concept" as="element()"/>
        
        <!-- Get (maximum) maximumMultiplicity, possibly from condition. Default if absent is * -->
        <xsl:choose>
            <xsl:when test="$concept[@conformance='NP'] | $concept[@prohibited='true']">
                <xsl:text>0</xsl:text>
            </xsl:when>
            <xsl:when test="$concept[self::attribute]">
                <xsl:text>1</xsl:text>
            </xsl:when>
            <xsl:when test="$concept[@maximumMultiplicity][not(@conformance='C')]">
                <xsl:value-of select="$concept/@maximumMultiplicity"/>
            </xsl:when>
            <xsl:when test="$concept[not(@maximumMultiplicity)][not(@conformance='C')]">
                <xsl:text>*</xsl:text>
            </xsl:when>
            <xsl:when test="$concept[@conformance='C'][condition[@maximumMultiplicity='*'] | conditionalConcept[@maximumMultiplicity='*']] |  $concept[@conformance='C'][condition][not(condition[@maximumMultiplicity])] | $concept[@conformance='C'][conditionalConcept][not(conditionalConcept[@maximumMultiplicity])]">
                <xsl:text>*</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="max" select="string(max(($concept/condition[@maximumMultiplicity castable as xs:integer]/number(@maximumMultiplicity),$concept/conditionalConcept[@maximumMultiplicity castable as xs:integer]/number(@maximumMultiplicity))))"/>
                
                <xsl:choose>
                    <xsl:when test="$max = ''">*</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$max"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xd:doc>
        <xd:desc/>
        <xd:param name="concept"/>
        <xd:param name="language"/>
    </xd:doc>
    <xsl:function name="local:getConformance" as="xs:string?">
        <xsl:param name="concept" as="element()"/>
        <xsl:param name="language" as="xs:string"/>
        <xsl:variable name="conformance" as="xs:string?">
            <xsl:choose>
                <xsl:when test="$concept/@prohibited='true'">
                    <xsl:text>NP</xsl:text>
                </xsl:when>
                <xsl:when test="$concept/@isOptional='true'"/>
                <xsl:when test="$concept[string(@isMandatory) = 'true'][not(@conformance = 'NP')]">
                    <xsl:text>M</xsl:text>
                </xsl:when>
                <xsl:when test="$concept[string-length(@conformance) &gt; 0]">
                    <xsl:value-of select="$concept[1]/@conformance"/>
                </xsl:when>
                <xsl:when test="$concept[self::attribute]">
                    <xsl:text>R</xsl:text>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$conformance='M'">
                <xsl:call-template name="getMessage">
                    <xsl:with-param name="key" select="'conformanceMandatory'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="string-length($conformance)&gt;0">
                <xsl:call-template name="getXFormsLabel">
                    <xsl:with-param name="simpleTypeKey" select="'ConformanceType'"/>
                    <xsl:with-param name="lang" select="if (empty($language)) then $defaultLanguage else $language"/>
                    <xsl:with-param name="simpleTypeValue" select="$concept/@conformance"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    <xd:doc>
        <xd:desc>Get the first template/classification/@format available or default to 'hl7v3xml1'. Returns empty if no template</xd:desc>
        <xd:param name="template">template node</xd:param>
    </xd:doc>
    <xsl:function name="local:getTemplateFormat" as="xs:string?">
        <xsl:param name="template" as="element(template)?"/>
        <xsl:if test="$template">
            <xsl:choose>
                <xsl:when test="$template/classification/@format[string-length() gt 0]">
                    <xsl:value-of select="($template/classification/@format[string-length() gt 0])[1]"/>
                </xsl:when>
                <xsl:otherwise>hl7v3xml1</xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:function>
</xsl:stylesheet>