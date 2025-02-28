<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:local="http://art-decor.org/functions"
    exclude-result-prefixes="#all"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Oct 12, 2016</xd:p>
            <xd:p><xd:b>Author:</xd:b> ahenket</xd:p>
            <xd:p><xd:b>Purpose:</xd:b> Starter for HL7 V 2 Implementation Guide (IG) generation based on bootstrap (currently through CDN, might go local). Currently not linked from anywhere. 
                Depends on a compiled project just like the other publication tools. Creates a one HTML page IG with a scenario id and effectiveDate as input parameters.</xd:p>
            <xs:p><xd:b>Assumptions:</xd:b></xs:p>
            <xd:ul>
                <xd:li>Project pulls content from <xd:a href="http://art-decor.org/art-decor/decor-project--ad4bbr-">the HL7 V 2.5 building block repository</xd:a> -- this is relevant for pulling in missing ValueSets due to missing formal bindings in the templates</xd:li>
                <xd:li>Scenario is ultimately linked to transactions with a representingTemplate that in turn have bindings to templates</xd:li>
                <xd:li>Links to dataset concepts from templates point to the dataset rendering from the regular publication process</xd:li>
                <xd:li>Value sets are rendered inline in the document at the moment. This is due to the differences in rendering Tables versus proper Value Sets</xd:li>
            </xd:ul>
            <xs:p><xd:b>History:</xd:b> 2016-10-18</xs:p>
            <xd:ul>
                <xd:li>Implemented messages, segments, datatypes, value sets (tables), template associations</xd:li>
            </xd:ul>
            <xs:p><xd:b>History:</xd:b> 2016-10-19</xs:p>
            <xd:ul>
                <xd:li>Implemented concept terminology associations (codes/value set) inline where value sets link to the target set</xd:li>
                <xd:li>Made internal links from segment table to the respective fields more reliable.</xd:li>
                <xd:li>Added internal links from datatype table to the respective fields.</xd:li>
                <xd:li>Fixed a problem that caused too many template associations to come up.</xd:li>
                <xd:li>Improved readability/usuability of navigation bar by providing direct links and moving it to the left instead of top right.</xd:li>
            </xd:ul>
            <xs:p><xd:b>TODO:</xd:b></xs:p>
            <xd:ul>
                <xd:li>figure out how to make obvious what codesystem string to use for value set contents.</xd:li>
            </xd:ul>
        </xd:desc>
    </xd:doc>
    <!--<xsl:output method="xhtml" indent="yes" encoding="UTF-8"/>-->
    <!--<xsl:include href="DECOR2schematron.xsl"/>-->
    
    <xd:doc>
        <xd:desc>
            <xd:p>Lab2Lab 2.16.840.1.113883.2.4.3.11.60.25.3.2 2014-11-28T10:06:07</xd:p>
            <xd:p>Lab2PublicHealth 2.16.840.1.113883.2.4.3.11.60.25.3.3 2014-12-02T14:45:58</xd:p>
        </xd:desc>
    </xd:doc>
    <!--<xsl:param name="scid">2.16.840.1.113883.2.4.3.11.60.25.3.2</xsl:param>
    <xsl:param name="sced">2014-11-28T10:06:07</xsl:param>-->
    <!--<xsl:param name="scid"/>
    <xsl:param name="sced"/>-->
    
    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template name="doV2ImplementationGuidesAndConformanceProfiles">
        <!--<xsl:variable name="fileName">
            <xsl:choose>
                <xsl:when test="count($theV2Scenarios) = 0">
                    <xsl:value-of select="'Unknown scenario'"/>
                </xsl:when>
                <xsl:when test="count($theV2Scenarios) = 1">
                    <xsl:variable name="theName">
                        <xsl:call-template name="doName">
                            <xsl:with-param name="ns" select="$theV2Scenarios/name"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:value-of select="string-join(($theName, $theV2Scenarios/@versionLabel), ' - ')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat(count($theV2Scenarios),' Scenarios')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>-->
        <xsl:if test="$switchCreateDocHTML">
            <!-- a little milestoning -->
            <xsl:call-template name="logMessage">
                <xsl:with-param name="level" select="$logINFO"/>
                <xsl:with-param name="msg">
                    <xsl:text>*** Creating HTML For V2 Implementation Guides (</xsl:text>
                    <xsl:value-of select="count($theV2Scenarios)"/>
                    <xsl:text> scenarios)</xsl:text>
                    <xsl:if test="$switchCreateDocSVG=true()">
                        <xsl:text> + svg</xsl:text>
                    </xsl:if>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="doV2ImplementationGuides"/>
        </xsl:if>
        <xsl:if test="$switchCreateSchematron">
            <!-- a little milestoning -->
            <xsl:call-template name="logMessage">
                <xsl:with-param name="level" select="$logINFO"/>
                <xsl:with-param name="msg">
                    <xsl:text>*** Creating V2 Conformance Profiles and Tables for </xsl:text>
                    <xsl:value-of select="count($theV2Scenarios)"/>
                    <xsl:text> scenarios</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="doV2ConformanceProfiles"/>
        </xsl:if>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template name="doV2ConformanceProfiles">
        <!-- Create Conformance Profile per scenario -->
        <xsl:for-each select="$theV2Scenarios">
            <xsl:variable name="profileName">
                <xsl:call-template name="doName">
                    <xsl:with-param name="ns" select="name"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="profileStatus" select="local:getProfileStatusCode(@statusCode)" as="xs:string?"/>
            <xsl:variable name="profileVersion" select="@versionLabel" as="xs:string?"/>
            <xsl:variable name="profileDescription">
                <xsl:call-template name="doDescription">
                    <xsl:with-param name="ns" select="desc"/>
                </xsl:call-template>
            </xsl:variable>
            <!-- {$theHtmlDir}{$profileName}_ConformanceProfile.xml -->
            <xsl:result-document href="{$theHtmlDir}{local:doHtmlName('SC', $projectPrefix, @id, @effectiveDate, (), (), (), (), '_HL7V2-CP.xml', 'false')}" method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="yes">
                <xsl:processing-instruction name="xml-stylesheet">type="text/xsl" href="http://gazelle.ihe.net/xsl/mp2htm.xsl"</xsl:processing-instruction>
                <xsl:processing-instruction name="xml-model">href="http://gazelle.ihe.net/xsd/HL7MessageProfileSchema.xsd" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
                <xsl:text>&#x0a;</xsl:text>
                <xsl:comment>
                        <xsl:text> Conformance Profile generated from ART-DECOR </xsl:text>
                        <xsl:value-of select="name()"/>
                        <xsl:text> at: </xsl:text>
                        <xsl:value-of select="$currentDateTime"/>
                        <xsl:text>&#x0a;=====================================</xsl:text>
                        <xsl:text>&#x0a; ID           : </xsl:text>
                        <xsl:value-of select="@id"/>
                        <xsl:text>&#x0a; EFFECTIVEDATE: </xsl:text>
                        <xsl:value-of select="@effectiveDate"/>
                        <xsl:text>&#x0a; NAME         : </xsl:text>
                        <xsl:value-of select="if (name[@language = $defaultLanguage]) then name[@language = $defaultLanguage] else name[1]"/>
                    </xsl:comment>
                <xsl:text>&#x0a;</xsl:text>
                <HL7v2xConformanceProfile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://gazelle.ihe.net/xsd/HL7MessageProfileSchema.xsd" HL7Version="2.5" ProfileType="Constrainable">
                    <MetaData>
                        <xsl:attribute name="Name" select="$profileName"/>
                        <xsl:attribute name="OrgName">Nictiz</xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="not(empty($profileVersion))">
                                <xsl:attribute name="Version" select="$profileVersion"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- Required attribute according to Message Workbench -->
                                <xsl:attribute name="Version" select="0.1"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="not(empty($profileStatus))">
                            <xsl:attribute name="Status" select="$profileStatus"/>
                        </xsl:if>
                        <!-- This provides a list of key-words that relate to the profile and that may be useful in profile searches. -->
                        <xsl:attribute name="Topics">confsig-Nictiz-2.5-profile-accNE_accAL-Immediate</xsl:attribute>
                    </MetaData>
                    <UseCase>
                        <Purpose>
                            <xsl:value-of select="$profileDescription"/>
                        </Purpose>
                        <xsl:for-each-group select=".//actor" group-by="@id">
                            <xsl:variable name="actorNode" select="$allActors/actor[@id = current()[1]/@id][1]" as="element(actor)"/>
                            <xsl:variable name="actorName">
                                <xsl:call-template name="doName">
                                    <xsl:with-param name="ns" select="$actorNode/name"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:variable name="actorDescription">
                                <xsl:call-template name="doDescription">
                                    <xsl:with-param name="ns" select="$actorNode/desc"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <Actor Name="{$actorName}"><xsl:value-of select="$actorDescription"/></Actor>
                        </xsl:for-each-group>
                    </UseCase>
                    <Encodings>
                        <Encoding>ER7</Encoding>
                        <xsl:comment><Encoding>XML</Encoding></xsl:comment>
                    </Encodings>
                    <DynamicDef AccAck="AL" AppAck="NE" MsgAckMode="Immediate"/>
                    <xsl:for-each select=".//transaction[representingTemplate/@ref]">
                        <xsl:variable name="MsgStructID" select="@model"/>
                        <xsl:variable name="MsgType" select="tokenize($MsgStructID,'[_-]')[1]"/>
                        <xsl:variable name="EventType" select="(trigger/@id)[1]"/>
                        <xsl:variable name="EventDesc">
                            <xsl:call-template name="doName">
                                <xsl:with-param name="ns" select="name"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <!-- Or should we get template/@id here? -->
                        <xsl:variable name="Identifier" select="@id"/>
                        <xsl:variable name="Role">
                            <xsl:choose>
                                <xsl:when test="@type = 'initial'">Sender</xsl:when>
                                <xsl:when test="@type = 'stationary'">Sender</xsl:when>
                                <xsl:otherwise>Receiver</xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="transactionName">
                            <xsl:call-template name="doName">
                                <xsl:with-param name="ns" select="name"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:variable name="transactionStatus" select="local:getProfileStatusCode(@statusCode)" as="xs:string?"/>
                        <xsl:variable name="transactionVersion" select="(@versionLabel, $profileVersion)[1]" as="xs:string?"/>
                        
                        <HL7v2xStaticDef MsgType="{$MsgType}" EventType="{$EventType}" MsgStructID="{$MsgStructID}" EventDesc="{$EventDesc}" Identifier="{$Identifier}" Role="{$Role}">
                            <MetaData Name="{$transactionName}">
                                <xsl:attribute name="OrgName">Nictiz</xsl:attribute>
                                <xsl:if test="not(empty($transactionVersion))">
                                    <xsl:attribute name="Version" select="$transactionVersion"/>
                                </xsl:if>
                                <xsl:if test="not(empty($transactionStatus))">
                                    <xsl:attribute name="Status" select="$transactionStatus"/>
                                </xsl:if>
                                <!-- This provides a list of key-words that relate to the profile and that may be useful in profile searches. -->
                                <!--<xsl:attribute name="Topics">confsig-Nictiz-2.5-profile-accNE_accAL-Immediate</xsl:attribute>-->
                            </MetaData>
                            <xsl:apply-templates select="representingTemplate" mode="conformanceProfile"/>
                        </HL7v2xStaticDef>
                    </xsl:for-each>
                </HL7v2xConformanceProfile>
            </xsl:result-document>
            <!-- Create Tables file -->
            <!-- {$theHtmlDir}{$profileName}_Tables.xml -->
            <xsl:result-document href="{$theHtmlDir}{local:doHtmlName('SC', $projectPrefix, @id, @effectiveDate, (), (), (), (), '_HL7V2-CP-Tables.xml', 'false')}" method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="yes">
                <xsl:processing-instruction name="xml-stylesheet">type="text/xsl" href="http://gazelle.ihe.net/xsl/HL7TableStylesheet.xsl"</xsl:processing-instruction>
                <xsl:text>&#x0a;</xsl:text>
                <xsl:comment>
                        <xsl:text> Tables for Conformance Profile generated from ART-DECOR </xsl:text>
                        <xsl:value-of select="name()"/>
                        <xsl:text> at: </xsl:text>
                        <xsl:value-of select="$currentDateTime"/>
                        <xsl:text>&#x0a;=====================================</xsl:text>
                        <xsl:text>&#x0a; ID           : </xsl:text>
                        <xsl:value-of select="@id"/>
                        <xsl:text>&#x0a; EFFECTIVEDATE: </xsl:text>
                        <xsl:value-of select="@effectiveDate"/>
                        <xsl:text>&#x0a; NAME         : </xsl:text>
                        <xsl:value-of select="if (name[@language = $defaultLanguage]) then name[@language = $defaultLanguage] else name[1]"/>
                    </xsl:comment>
                <xsl:text>&#x0a;</xsl:text>
                <Specification xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://gazelle.ihe.net/xsd/HL7TableSchema.xsd">
                    <xsl:attribute name="SpecName" select="$profileName"/>
                    <xsl:attribute name="OrgName" select="($allDECOR/project/copyright/@by)[1]"/>
                    <xsl:attribute name="HL7Version" select="5"/>
                    <xsl:attribute name="SpecVersion" select="if (string-length(@versionLabel) gt 0) then replace(@versionLabel, '[^\d\.]' , '') else replace(substring-before($latestVersionOrRelease/@date, 'T'), '[^\d]', '')"/>
                    <xsl:attribute name="Status" select="@statusCode"/>
                    <!-- Fixed value: what's this? TODO: ask IHE/HL7 Germany -->
                    <xsl:attribute name="ConformanceType" select="'Tolerant'"/>
                    <!-- Fixed value: what's this? TODO: ask IHE/HL7 Germany. Why do I care about this in a Tables file? -->
                    <xsl:attribute name="Role" select="'Sender'"/>
                    <!-- Fixed value: what's this? TODO: ask IHE/HL7 Germany. Why do I care about this in a Tables file? -->
                    <xsl:attribute name="HL7OID" select="''"/>
                    <!-- Fixed value: what's this? TODO: ask IHE/HL7 Germany. Why do I care about this in a Tables file? -->
                    <xsl:attribute name="ProcRule" select="'HL7'"/>
                    <!-- Fixed value: what's this? TODO: ask IHE/HL7 Germany. Why do I care about this in a Tables file? -->
                    <Conformance AccAck="NE" AppAck="AL" StaticID="{generate-id(.)}" DynamicID="{generate-id(.)}" MsgAckMode="Deferred" QueryStatus="Event" QueryMode="Non Query"/>
                    <Encodings>
                        <Encoding>ER7 </Encoding>
                    </Encodings>
                    <hl7tables>
                        <xsl:for-each select="$doV2ValueSets">
                            <xsl:sort select="xs:integer(replace(@id, '[^\d]',''))"/>
                            <xsl:apply-templates select="." mode="valueSet2table"/>
                        </xsl:for-each>
                    </hl7tables>
                </Specification>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template name="doV2ImplementationGuides">
        <xsl:for-each select="$theV2Scenarios">
            <xsl:variable name="theScenario" select="." as="element(scenario)"></xsl:variable>
            <xsl:variable name="fileName">
                <xsl:variable name="theName">
                    <xsl:call-template name="doName">
                        <xsl:with-param name="ns" select="name"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:value-of select="string-join(($theName, @versionLabel), ' - ')"/>
            </xsl:variable>
            <!-- {$theHtmlDir}{$fileName}.html -->
            <xsl:result-document href="{$theHtmlDir}{local:doHtmlName('SC', $projectPrefix, @id, @effectiveDate, (), (), (), (), '_HL7V2-IG.html', 'false')}" method="xhtml" indent="yes" encoding="UTF-8" omit-xml-declaration="yes" doctype-system="about:legacy-compat">
                <html xml:lang="{substring($defaultLanguage,1,2)}" lang="{substring($defaultLanguage,1,2)}" xmlns="http://www.w3.org/1999/xhtml">
                    <head>
                        <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
                        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"/>
                        <title>
                            <xsl:value-of select="$fileName"/>
                        </title>
                        <link href="{$theAssetsDir}favicon.ico" rel="shortcut icon" type="image/x-icon"/>
                        <!-- Latest compiled and minified CSS -->
                        <link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous"/>
                        <!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->
                        <link href="https://maxcdn.bootstrapcdn.com/css/ie10-viewport-bug-workaround.css" rel="stylesheet"/>
                        <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
                        <xsl:comment>[if lt IE 9]>&lt;script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js">&lt;/script>&lt;script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js">&lt;/script>&lt;![endif]</xsl:comment>
                        <style type="text/css" media="print">
                            body{
                                font-size: smaller !important;
                            }
                            /* gimme me background-colors upon print. this is not the default */
                            .table-striped tbody tr:nth-of-type(odd) td{
                                background-color: #ddd !important;
                                -webkit-print-color-adjust: exact;
                            }
                            /* do not print buttons. maybe this method is too crude? */
                            button,
                            a.btn{
                                display: none !important;
                            }</style>
                        <style type="text/css">
                        /* === from dashboard.css === */
                        /* Move down content because we have a fixed navbar that is 50px tall */
                        body{
                            padding-top: 50px;
                            -webkit-print-color-adjust: exact;
                        }
                        /* Global add-ons */
                        .sub-header{
                            padding-bottom: 10px;
                            border-bottom: 1px solid #eee;
                            -webkit-print-color-adjust: exact;
                        }
                        /* Top navigation
                        * Hide default border to remove 1px line.
                        */
                        .navbar-fixed-top{
                            border: 0;
                        }
                        /* Main content */
                        .main{
                            padding: 20px;
                        }
                        @media (min-width : 768px){
                            .main{
                                padding-right: 40px;
                                padding-left: 40px;
                            }
                        }
                        .main .page-header{
                            margin-top: 0;
                        }
                        /* === end from dashboard.css === */
                        div.dcm-title-img{
                            padding-top: 3em;
                            padding-bottom: 3em;
                        }
                        div.dcm-title-img .row{
                            padding-bottom: 1em;
                        }
                        .dcm-color-h1{
                            font-size: 20px;
                            color: #003f80 !important;
                            -webkit-print-color-adjust: exact;
                        }
                        .dcm-color-h2{
                            font-size: 18px;
                            color: #003f80 !important;
                            -webkit-print-color-adjust: exact;
                        }
                        .dcm-color-h3{
                            font-size: 16px;
                            color: #003f80 !important;
                            -webkit-print-color-adjust: exact;
                        }
                        table.dcm-font-size{
                            font-size: inherit;
                        }
                        tr.dcm-concept-header th,
                        th.dcm-concept-header{
                            background-color: #003f80 !important;
                            color: white !important;
                            -webkit-print-color-adjust: exact;
                        }
                        tr.dcm-concept-label td,
                        td.dcm-concept-label{
                            background-color: #c0c0c0 !important;
                            color: black !important;
                            -webkit-print-color-adjust: exact;
                        }
                        div.dcm-par{
                            margin: 10px 5%;
                        }
                        strong{
                            background-color: inherit !important;
                            color: inherit !important;
                            -webkit-print-color-adjust: exact;
                        }
                        p.note-box,
                        div.note-box{
                            padding: 2px;
                            border: 1px solid black;
                        }
                        .dcm-panel-heading {
                            padding: 5px !important; // override bulky bootstrap of 5px 15px;
                        }
                        .dcm-panel-body {
                            padding: 5px !important; // override bulky bootstrap of 15px;
                        }</style>
                        <!-- HTML/XML pretty printer -->
                        <style type="text/css">
                            .ppsign{
                                color: #000080;
                            }
                            .ppelement{
                                color: #000080;
                            }
                            .ppattribute{
                                color: #ffa500;
                            }
                            .ppcontent{
                                color: #a52a2a;
                            }
                            .pptext{
                                color: #808080;
                            }
                            .ppnamespace{
                                color: #0000ff;
                            }</style>
                    </head>
                    <body>
                        <nav class="navbar navbar-default navbar-fixed-top">
                            <div class="container-fluid">
                                <!-- Brand and toggle get grouped for better mobile display -->
                                <div class="navbar-header navbar-right">
                                    <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#bs-navbar-collapse-1" aria-expanded="false">
                                        <span class="sr-only">
                                            <xsl:call-template name="getMessage">
                                                <xsl:with-param name="key" select="'ToggleNavigation'"/>
                                            </xsl:call-template>
                                        </span>
                                        <span class="icon-bar"/>
                                        <span class="icon-bar"/>
                                        <span class="icon-bar"/>
                                    </button>
                                    <!--<a class="navbar-brand" href="#">
                                    <xsl:value-of select="$fileName"/>
                                </a>-->
                                </div>
                                <!-- Collect the nav links, forms, and other content for toggling -->
                                <div class="collapse navbar-collapse" id="bs-navbar-collapse-1">
                                    <ul class="nav navbar-nav">
                                        <li class="dropdown">
                                            <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">
                                                <xsl:call-template name="doName">
                                                    <xsl:with-param name="ns" select="name"/>
                                                </xsl:call-template>
                                                <xsl:text> </xsl:text>
                                                <span class="caret"/>
                                            </a>
                                            <ul class="dropdown-menu">
                                                <xsl:apply-templates select="transaction" mode="doDropDownMenu"/>
                                            </ul>
                                            <!--<xsl:choose>
                                                <xsl:when test="count($theV2Scenarios) = 1">
                                                    <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">
                                                        <xsl:call-template name="doName">
                                                            <xsl:with-param name="ns" select="$theV2Scenarios/name"/>
                                                        </xsl:call-template>
                                                        <xsl:text> </xsl:text>
                                                        <span class="caret"/>
                                                    </a>
                                                    <ul class="dropdown-menu">
                                                        <xsl:apply-templates select="$theV2Scenarios/transaction" mode="doDropDownMenu"/>
                                                    </ul>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">
                                                        <xsl:call-template name="getMessage">
                                                            <xsl:with-param name="key" select="'Scenarios'"/>
                                                        </xsl:call-template>
                                                        <xsl:text>&#160;</xsl:text>
                                                        <span class="badge">
                                                            <xsl:value-of select="count($theV2Scenarios)"/>
                                                        </span>
                                                        <xsl:text>&#160;</xsl:text>
                                                        <span class="caret"/>
                                                    </a>
                                                    <ul class="dropdown-menu">
                                                        <xsl:apply-templates select="$theV2Scenarios" mode="doDropDownMenu"/>
                                                    </ul>
                                                </xsl:otherwise>
                                            </xsl:choose>-->
                                        </li>
                                        <li>
                                            <a href="#segments">
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'Segments'"/>
                                                </xsl:call-template>
                                                <xsl:text>&#160;</xsl:text>
                                                <span class="badge">
                                                    <xsl:value-of select="count($doV2SegmentTemplates)"/>
                                                </span>
                                            </a>
                                        </li>
                                        <li>
                                            <a href="#datatypes">
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'Datatypes'"/>
                                                </xsl:call-template>
                                                <xsl:text>&#160;</xsl:text>
                                                <span class="badge">
                                                    <xsl:value-of select="count($doV2DatatypeTemplates)"/>
                                                </span>
                                            </a>
                                        </li>
                                        <li>
                                            <a href="#valuesets">
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'valueSets'"/>
                                                </xsl:call-template>
                                                <xsl:text>&#160;</xsl:text>
                                                <span class="badge">
                                                    <xsl:value-of select="count($doV2ValueSets)"/>
                                                </span>
                                            </a>
                                        </li>
                                    </ul>
                                </div>
                                <!-- /.navbar-collapse -->
                            </div>
                            <!-- /.container-fluid -->
                        </nav>
                        <div class="container-fluid">
                            <div class="main">
                                <div class="row center-block text-center">
                                    <h1 id="title" class="dcm-color-h1">
                                        <xsl:value-of select="$fileName"/>
                                    </h1>
                                    <!--<h2 class="text-capitalize dcm-color-h2">
                                    <xsl:value-of select="ancestor::dataset/@statusCode"/>
                                </h2>-->
                                </div>
                                <!-- Images max 4 per row -->
                                <xsl:variable name="copyrights" select="$allDECOR/project/copyright[@logo[string-length() > 0]]"/>
                                <xsl:variable name="copycnt" select="count($copyrights)" as="xs:integer"/>
                                <xsl:variable name="maxperrow" select="2"/>
                                <xsl:if test="$copyrights">
                                    <div class="well well-sm">
                                        <xsl:for-each select="$copyrights">
                                            <xsl:variable name="pos" select="position()" as="xs:integer"/>
                                            <xsl:variable name="posinrow" select="xs:integer($pos - (floor(($pos - 1) div $maxperrow) * $maxperrow))" as="xs:integer"/>
                                            <xsl:if test="$posinrow = 1">
                                                <div class="row" style="padding: 5px 0px;">
                                                    <div class="col col-sm-{12 div $maxperrow} text-center">
                                                        <xsl:apply-templates select="." mode="doImage"/>
                                                    </div>
                                                    <!-- get the rest for this row -->
                                                    <xsl:for-each select="1 to ($maxperrow - 1)">
                                                        <xsl:variable name="p" select="."/>
                                                        <div class="col col-sm-{12 div $maxperrow} text-center">
                                                            <xsl:apply-templates select="$copyrights[$pos + $p]" mode="doImage"/>
                                                        </div>
                                                    </xsl:for-each>
                                                </div>
                                            </xsl:if>
                                        </xsl:for-each>
                                    </div>
                                </xsl:if>
                                <div class="row left-block text-left">
                                    <strong>
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="'PublicationDate'"/>
                                            <xsl:with-param name="p1" select="substring($currentDateTime, 1, 10)"/>
                                        </xsl:call-template>
                                    </strong>
                                </div>
                                <!--<xsl:apply-templates select="$theV2Scenarios" mode="hl7v2ig"/>-->
                                <xsl:apply-templates select="." mode="hl7v2ig"/>
                                <!--<xsl:variable name="segmentElements" as="element()*">
                                    <xsl:variable name="topLevelTemplates" as="element(template)*">
                                        <xsl:for-each select="$theV2Scenarios//representingTemplate[@ref]">
                                            <xsl:variable name="tmid" select="@ref"/>
                                            <xsl:variable name="tmed" select="@flexibility"/>
                                            <xsl:call-template name="getRulesetContent">
                                                <xsl:with-param name="ruleset" select="$tmid"/>
                                                <xsl:with-param name="flexibility" select="$tmed"/>
                                            </xsl:call-template>
                                        </xsl:for-each>
                                    </xsl:variable>
                                    <xsl:for-each-group select="$topLevelTemplates//element[string-length(substring-after(@name,':')) = 3]" group-by="if (@contains) then @contains else if (@ref) then @ref else substring-after(@name,':')">
                                        <xsl:sort select="substring-after(@name,':')"/>
                                        <xsl:copy-of select=".[1]"/>
                                    </xsl:for-each-group>
                                </xsl:variable>-->
                                <div class="bs-docs-section">
                                    <h2 id="segments" class="sub-header dcm-color-h2">
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="'Segments'"/>
                                        </xsl:call-template>
                                        <xsl:text>&#160;</xsl:text>
                                        <span class="badge">
                                            <xsl:value-of select="count($doV2SegmentTemplates)"/>
                                        </span>
                                    </h2>
                                </div>
                                <xsl:for-each select="$doV2SegmentTemplates">
                                    <xsl:sort select="@name"/>
                                    <xsl:apply-templates select="self::template" mode="doSegment">
                                        <xsl:with-param name="theScenario" select="$theScenario"/>
                                        <xsl:with-param name="templateType">segmentlevel</xsl:with-param>
                                    </xsl:apply-templates>
                                </xsl:for-each>
                                <div class="bs-docs-section">
                                    <h2 id="datatypes" class="sub-header dcm-color-h2">
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="'Datatypes'"/>
                                        </xsl:call-template>
                                        <xsl:text>&#160;</xsl:text>
                                        <span class="badge">
                                            <xsl:value-of select="count($doV2DatatypeTemplates)"/>
                                        </span>
                                    </h2>
                                </div>
                                <xsl:for-each select="$doV2DatatypeTemplates">
                                    <xsl:sort select="@name"/>
                                    <xsl:apply-templates select="self::template" mode="doSegment">
                                        <xsl:with-param name="theScenario" select="$theScenario"/>
                                        <xsl:with-param name="templateType">datatypelevel</xsl:with-param>
                                    </xsl:apply-templates>
                                </xsl:for-each>
                                <xsl:variable name="segmentAnchor" select="'valuesets'"/>
                                <xsl:variable name="segmentAnchorTitle">
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'valueSets'"/>
                                    </xsl:call-template>
                                </xsl:variable>
                                <div class="bs-docs-section">
                                    <h2 id="valuesets" class="sub-header dcm-color-h2">
                                        <xsl:value-of select="$segmentAnchorTitle"/>
                                        <xsl:text>&#160;</xsl:text>
                                        <span class="badge">
                                            <xsl:value-of select="count($doV2ValueSets)"/>
                                        </span>
                                    </h2>
                                </div>
                                <xsl:for-each select="$doV2ValueSets">
                                    <xsl:sort select="@name"/>
                                    <xsl:apply-templates select="." mode="doTable">
                                        <xsl:with-param name="segmentAnchor" select="$segmentAnchor"/>
                                        <xsl:with-param name="segmentAnchorTitle" select="$segmentAnchorTitle"/>
                                    </xsl:apply-templates>
                                </xsl:for-each>
                            </div>
                        </div>
                        <!-- Bootstrap core JavaScript
                        ================================================== -->
                        <!-- Placed at the end of the document so the pages load faster -->
                        <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"/>
                        <script>window.jQuery || document.write('&lt;script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js">&lt;/script>')</script>
                        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"/>
                        <!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->
                        <script src="https://maxcdn.bootstrapcdn.com/js/ie10-viewport-bug-workaround.js"/>
                        <!-- Extra https://getbootstrap.com/javascript/#tooltips -->
                        <script type="application/javascript">$(function () { $('[data-toggle="tooltip"]').tooltip() })</script>
                    </body>
                </html>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="copyright" mode="doImage">
        <xsl:variable name="tempimg" as="element()">
            <img src="http://decor.nictiz.nl/decor/services/ProjectLogo?prefix={$allDECOR/project/@prefix}&amp;logo={@logo}" height="50" alt="{@by}" xmlns="http://www.w3.org/1999/xhtml">
                <xsl:if test="addrLine">
                    <xsl:attribute name="data-toggle" select="'tooltip'"/>
                    <xsl:attribute name="data-placement" select="'bottom'"/>
                    <xsl:attribute name="title" select="string-join(addrLine, '&#13;&#10;')"/>
                </xsl:if>
                <xsl:if test="addrLine[@type = 'uri']">
                    <xsl:attribute name="onclick" select="addrLine[@type = 'uri'][1]"/>
                </xsl:if>
            </img>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="addrLine[@type = 'uri'][starts-with(., 'http')]">
                <a href="{addrLine[@type = 'uri'][starts-with(.,'http')][1]}" alt="" xmlns="http://www.w3.org/1999/xhtml">
                    <xsl:copy-of select="$tempimg"/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$tempimg"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="scenario" mode="doDropDownMenu">
        <li xmlns="http://www.w3.org/1999/xhtml">
            <a href="#{local:doHtmlAnchor(@id,@effectiveDate)}">
                <xsl:call-template name="getMessage">
                    <xsl:with-param name="key" select="'Scenario'"/>
                </xsl:call-template>
                <xsl:text>: </xsl:text>
                <xsl:call-template name="doName">
                    <xsl:with-param name="ns" select="name"/>
                </xsl:call-template>
            </a>
        </li>
        <xsl:apply-templates select="transaction" mode="#current"/>
        <xsl:if test="following-sibling::scenario">
            <li role="separator" class="divider" xmlns="http://www.w3.org/1999/xhtml"/>
        </xsl:if>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="transaction" mode="doDropDownMenu">
        <xsl:variable name="indent" select="20"/>
        <xsl:variable name="model" select="@model"/>
        <li xmlns="http://www.w3.org/1999/xhtml">
            <a href="#{local:doHtmlAnchor(@id,@effectiveDate)}" style="padding-left: {$indent + (count(ancestor::transaction) * $indent)}px;">
                <xsl:choose>
                    <xsl:when test="@type[. = 'group'] | transaction">
                        <xsl:call-template name="showIcon">
                            <xsl:with-param name="which">doublearrow</xsl:with-param>
                            <xsl:with-param name="tooltip">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'Group'"/>
                                </xsl:call-template>
                            </xsl:with-param>
                        </xsl:call-template>
                        <xsl:text>&#160;</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="showDirection">
                            <xsl:with-param name="dir" select="@type"/>
                        </xsl:call-template>
                        <xsl:text>&#160;</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="$model">
                        <xsl:value-of select="$model"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="if (@type='group') then 'TransactionGroup' else 'Transaction'"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text> - </xsl:text>
                <xsl:call-template name="doName">
                    <xsl:with-param name="ns" select="name"/>
                </xsl:call-template>
            </a>
        </li>
        <xsl:apply-templates select="transaction" mode="#current"/>
        <!-- <li role="separator" class="divider"></li> -->
    </xsl:template>
    
    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="scenario" mode="hl7v2ig">
        <xsl:variable name="scid" select="@id"/>
        <xsl:variable name="sced" select="@effectiveDate"/>
        <div class="bs-docs-section" xmlns="http://www.w3.org/1999/xhtml">
            <h2 id="{local:doHtmlAnchor($scid,$sced)}" class="sub-header dcm-color-h2">
                <xsl:call-template name="getMessage">
                    <xsl:with-param name="key" select="'Scenario'"/>
                </xsl:call-template>
                <xsl:text>: </xsl:text>
                <xsl:call-template name="doName">
                    <xsl:with-param name="ns" select="name"/>
                </xsl:call-template>
            </h2>
            <xsl:apply-templates select="." mode="doMeta"/>
            <div class="row dcm-par">
                <xsl:call-template name="doDescription">
                    <xsl:with-param name="ns" select="desc"/>
                </xsl:call-template>
            </div>
        </div>
        <xsl:apply-templates select="transaction" mode="#current"/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="transaction" mode="hl7v2ig">
        <xsl:variable name="trid" select="@id"/>
        <xsl:variable name="tred" select="@effectiveDate"/>
        <xsl:variable name="model" select="@model"/>
        
        <div class="bs-docs-section" xmlns="http://www.w3.org/1999/xhtml">
            <h2 id="{local:doHtmlAnchor($trid,$tred)}" class="sub-header dcm-color-h2">
                <xsl:choose>
                    <xsl:when test="@type[.='group'] | transaction">
                        <xsl:call-template name="showIcon">
                            <xsl:with-param name="which">doublearrow</xsl:with-param>
                            <xsl:with-param name="tooltip">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'Group'"/>
                                </xsl:call-template>
                            </xsl:with-param>
                        </xsl:call-template>
                        <xsl:text>&#160;</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="showDirection">
                            <xsl:with-param name="dir" select="@type"/>
                        </xsl:call-template>
                        <xsl:text>&#160;</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="$model">
                        <xsl:value-of select="$model"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="if (@type='group') then 'TransactionGroup' else 'Transaction'"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text> - </xsl:text>
                <xsl:call-template name="doName">
                    <xsl:with-param name="ns" select="name"/>
                </xsl:call-template>
            </h2>
            <xsl:apply-templates select="." mode="doMeta"/>
            <xsl:if test="desc[not(string-join(.//normalize-space(text()),'') = ('','-'))]">
                <div class="row dcm-par">
                    <xsl:call-template name="doDescription">
                        <xsl:with-param name="ns" select="desc"/>
                    </xsl:call-template>
                </div>
            </xsl:if>
            <xsl:if test="@type[. = 'group'] | transaction">
                <!-- If we created at least one SVG, assume its the functional variant -->
                <xsl:if test="$allSvg/transaction[@id = $trid][not(@effectiveDate) or @effectiveDate = $tred]/*">
                    <h3 class="sub-header dcm-color-h3">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'Diagram'"/>
                        </xsl:call-template>
                    </h3>
                    <div class="row center-block text-center">
                        <!-- Write functional and technical SVGs. Could not do this inside the variable because older versions of Saxon do not support switching output from within a variable -->
                        <!--<xsl:for-each select="$allSvg/transaction[@id = $trid][not(@effectiveDate) or @effectiveDate = $tred]">
                            <xsl:if test="*[1]">
                                <xsl:result-document format="xml" href="{$theHtmlDir}{local:doHtmlName('TR',@id,@effectiveDate,'_functional.svg','true')}">
                                    <xsl:copy-of select="*[1]" copy-namespaces="no"/>
                                </xsl:result-document>
                            </xsl:if>
                            <xsl:if test="*[2]">
                                <xsl:result-document format="xml" href="{$theHtmlDir}{local:doHtmlName('TR',@id,@effectiveDate,'_technical.svg','true')}">
                                    <xsl:copy-of select="*[2]" copy-namespaces="no"/>
                                </xsl:result-document>
                            </xsl:if>
                        </xsl:for-each>-->
                        <img src="{local:doHtmlName('TR',@id,@effectiveDate,'_functional.svg','true')}">
                            <xsl:attribute name="alt">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'needBrowserWithSvgSupport'"/>
                                </xsl:call-template>
                            </xsl:attribute>
                        </img>
                    </div>
                </xsl:if>
            </xsl:if>
        </div>
        <xsl:apply-templates select="transaction" mode="#current"/>
        <xsl:apply-templates select="representingTemplate" mode="doMessageTable"/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="representingTemplate" mode="doMessageTable">
        <xsl:variable name="model" select="../@model"/>
        <xsl:variable name="tmid" select="@ref"/>
        <xsl:variable name="tmed" select="@flexibility"/>
        <xsl:variable name="topLevelTemplate" as="element(template)?">
            <xsl:call-template name="getRulesetContent">
                <xsl:with-param name="ruleset" select="$tmid"/>
                <xsl:with-param name="flexibility" select="$tmed"/>
                <xsl:with-param name="sofar" select="()"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="tmdn" select="if ($topLevelTemplate[@displayName]) then $topLevelTemplate/@displayName else $topLevelTemplate/@name"/>
        <xsl:if test="$topLevelTemplate/desc">
            <div class="row dcm-par panel panel-default" xmlns="http://www.w3.org/1999/xhtml">
                <xsl:call-template name="doDescription">
                    <xsl:with-param name="ns" select="$topLevelTemplate/desc"/>
                </xsl:call-template>
            </div>
        </xsl:if>
        <div class="table-responsive dcm-par" xmlns="http://www.w3.org/1999/xhtml">
            <table class="table table-striped table-condensed dcm-font-size">
                <thead>
                    <tr>
                        <th>
                            <xsl:value-of select="$model"/>
                        </th>
                        <th>
                            <xsl:value-of select="$tmdn"/>
                        </th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:apply-templates select="$topLevelTemplate/element[@minimumMultiplicity[. > 0] | @conformance[not(. = 'NP')] | @isMandatory[. = 'true']]" mode="doMessageTable">
                        <xsl:with-param name="model" select="$model"/>
                    </xsl:apply-templates>
                </tbody>
            </table>
        </div>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
        <xd:param name="level"/>
        <xd:param name="model"/>
    </xd:doc>
    <xsl:template match="element" mode="doMessageTable">
        <xsl:param name="level" select="0"/>
        <xsl:param name="model"/>
        <xsl:variable name="indent" select="$level * 30"/>
        <xsl:variable name="tableitemid" select="concat('_table_', string-join(for $a in ancestor::*[not(descendant-or-self::template)] return string(count($a/preceding-sibling::*) + 1),'_'),'_',string(count(preceding-sibling::*) + 1))"/>
        <xsl:variable name="eligibleElements" select="element[@minimumMultiplicity[. > 0] | @conformance[not(. = 'NP')] | @isMandatory[. = 'true']]" as="element()*"/>
        <xsl:choose>
            <xsl:when test="$eligibleElements">
                <xsl:choose>
                    <xsl:when test="count($eligibleElements) = 1 and count($eligibleElements[string-length(replace(@name, '^[^:]+:', '')) = 3]) = 1">
                        <tr xmlns="http://www.w3.org/1999/xhtml">
                            <td>
                                <!-- GROUP OPT/RPT -->
                                <xsl:if test="$indent > 0">
                                    <xsl:attribute name="style" select="concat('padding-left: ', $indent, 'px;')"/>
                                </xsl:if>
                                <a id="{$tableitemid}"/>
                                <xsl:if test="not(@minimumMultiplicity) or @minimumMultiplicity = 0">
                                    <xsl:text>[</xsl:text>
                                </xsl:if>
                                <xsl:if test="not(@maximumMultiplicity) or @maximumMultiplicity = '*' or @maximumMultiplicity > 1">
                                    <xsl:text>{</xsl:text>
                                </xsl:if>
                                <!-- ELEMENT OPT/RPT -->
                                <xsl:if test="$eligibleElements[not(@minimumMultiplicity) or @minimumMultiplicity = 0]">
                                    <xsl:text>[</xsl:text>
                                </xsl:if>
                                <xsl:if test="$eligibleElements[not(@maximumMultiplicity) or @maximumMultiplicity = '*' or @maximumMultiplicity > 1]">
                                    <xsl:text>{</xsl:text>
                                </xsl:if>
                                <xsl:text> </xsl:text>
                                <xsl:choose>
                                    <xsl:when test="$eligibleElements[@contains]">
                                        <xsl:variable name="theTemplate" as="element(template)">
                                            <xsl:call-template name="getRulesetContent">
                                                <xsl:with-param name="ruleset" select="$eligibleElements/@contains"/>
                                                <xsl:with-param name="flexibility" select="$eligibleElements/@flexibility"/>
                                                <xsl:with-param name="sofar" select="()"/>
                                            </xsl:call-template>
                                        </xsl:variable>
                                        <!--<xsl:if test="not($theTemplate)">
                                            <xsl:message terminate="yes">
                                                <xsl:text>Element contains not resolved: </xsl:text>
                                                <xsl:value-of select="string-join(for $att in @* return concat(name($att),'=&quot;',$att,'&quot;'),' ')"/>
                                            </xsl:message>
                                        </xsl:if>-->
                                        <a href="#{local:doHtmlAnchor($theTemplate/@id,$theTemplate/@effectiveDate)}">
                                            <xsl:call-template name="doElementName">
                                                <xsl:with-param name="element" select="$eligibleElements"/>
                                                <xsl:with-param name="model" select="$model"/>
                                            </xsl:call-template>
                                        </a>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:call-template name="doElementName">
                                            <xsl:with-param name="element" select="$eligibleElements"/>
                                            <xsl:with-param name="model" select="$model"/>
                                        </xsl:call-template>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:text> </xsl:text>
                                <xsl:if test="$eligibleElements[not(@maximumMultiplicity) or @maximumMultiplicity = '*' or @maximumMultiplicity > 1]">
                                    <xsl:text>}</xsl:text>
                                </xsl:if>
                                <xsl:if test="$eligibleElements[not(@minimumMultiplicity) or @minimumMultiplicity = 0]">
                                    <xsl:text>]</xsl:text>
                                </xsl:if>
                                <!-- / ELEMENT OPT/RPT -->
                                <!-- GROUP OPT/RPT -->
                                <xsl:if test="not(@maximumMultiplicity) or @maximumMultiplicity = '*' or @maximumMultiplicity > 1">
                                    <xsl:text>}</xsl:text>
                                </xsl:if>
                                <xsl:if test="not(@minimumMultiplicity) or @minimumMultiplicity = 0">
                                    <xsl:text>]</xsl:text>
                                </xsl:if>
                            </td>
                            <td>
                                <xsl:text>--- </xsl:text>
                                <xsl:call-template name="doElementName">
                                    <xsl:with-param name="element" select="."/>
                                    <xsl:with-param name="model" select="$model"/>
                                </xsl:call-template>
                                <xsl:text> - </xsl:text>
                                <xsl:call-template name="doElementDescription">
                                    <xsl:with-param name="element" select="$eligibleElements"/>
                                </xsl:call-template>
                            </td>
                        </tr>
                    </xsl:when>
                    <xsl:otherwise>
                        <tr xmlns="http://www.w3.org/1999/xhtml">
                            <td>
                                <xsl:if test="$indent > 0">
                                    <xsl:attribute name="style" select="concat('padding-left: ', $indent, 'px;')"/>
                                </xsl:if>
                                <xsl:if test="not(@minimumMultiplicity) or @minimumMultiplicity = 0">
                                    <xsl:text>[</xsl:text>
                                </xsl:if>
                                <xsl:if test="not(@maximumMultiplicity) or @maximumMultiplicity = '*' or @maximumMultiplicity > 1">
                                    <xsl:text>{</xsl:text>
                                </xsl:if>
                            </td>
                            <td>
                                <xsl:text>--- </xsl:text>
                                <xsl:call-template name="doElementName">
                                    <xsl:with-param name="element" select="."/>
                                    <xsl:with-param name="model" select="$model"/>
                                </xsl:call-template>
                                <xsl:text> begin</xsl:text>
                            </td>
                        </tr>
                        <xsl:apply-templates select="$eligibleElements" mode="#current">
                            <xsl:with-param name="level" select="$level + 1"/>
                            <xsl:with-param name="model" select="$model"/>
                        </xsl:apply-templates>
                        <tr xmlns="http://www.w3.org/1999/xhtml">
                            <td>
                                <xsl:if test="$indent > 0">
                                    <xsl:attribute name="style" select="concat('padding-left: ', $indent, 'px;')"/>
                                </xsl:if>
                                <xsl:if test="not(@maximumMultiplicity) or @maximumMultiplicity = '*' or @maximumMultiplicity > 1">
                                    <xsl:text>}</xsl:text>
                                </xsl:if>
                                <xsl:if test="not(@minimumMultiplicity) or @minimumMultiplicity = 0">
                                    <xsl:text>]</xsl:text>
                                </xsl:if>
                            </td>
                            <td>
                                <xsl:text>--- </xsl:text>
                                <xsl:call-template name="doElementName">
                                    <xsl:with-param name="element" select="."/>
                                    <xsl:with-param name="model" select="$model"/>
                                </xsl:call-template>
                                <xsl:text> end</xsl:text>
                            </td>
                        </tr>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <tr xmlns="http://www.w3.org/1999/xhtml">
                    <td>
                        <xsl:if test="$indent > 0">
                            <xsl:attribute name="style" select="concat('padding-left: ', $indent, 'px;')"/>
                        </xsl:if>
                        <a id="{$tableitemid}"/>
                        <xsl:if test="not(@minimumMultiplicity) or @minimumMultiplicity = 0">
                            <xsl:text>[</xsl:text>
                        </xsl:if>
                        <xsl:if test="not(@maximumMultiplicity) or @maximumMultiplicity = '*' or @maximumMultiplicity > 1">
                            <xsl:text>{</xsl:text>
                        </xsl:if>
                        <xsl:text> </xsl:text>
                        <xsl:choose>
                            <xsl:when test="@contains">
                                <xsl:variable name="theTemplate" as="element(template)">
                                    <xsl:call-template name="getRulesetContent">
                                        <xsl:with-param name="ruleset" select="@contains"/>
                                        <xsl:with-param name="flexibility" select="@flexibility"/>
                                        <xsl:with-param name="sofar" select="()"/>
                                    </xsl:call-template>
                                </xsl:variable>
                                <a href="#{local:doHtmlAnchor($theTemplate/@id,$theTemplate/@effectiveDate)}">
                                    <xsl:call-template name="doElementName">
                                        <xsl:with-param name="element" select="."/>
                                        <xsl:with-param name="model" select="$model"/>
                                    </xsl:call-template>
                                </a>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="doElementName">
                                    <xsl:with-param name="element" select="."/>
                                    <xsl:with-param name="model" select="$model"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text> </xsl:text>
                        <xsl:if test="not(@maximumMultiplicity) or @maximumMultiplicity = '*' or @maximumMultiplicity > 1">
                            <xsl:text>}</xsl:text>
                        </xsl:if>
                        <xsl:if test="not(@minimumMultiplicity) or @minimumMultiplicity = 0">
                            <xsl:text>]</xsl:text>
                        </xsl:if>
                    </td>
                    <td>
                        <xsl:call-template name="doElementDescription">
                            <xsl:with-param name="element" select="."/>
                        </xsl:call-template>
                    </td>
                </tr>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc/>
        <xd:param name="theScenario"/>
    </xd:doc>
    <xsl:template match="template" mode="doSegment">
        <xsl:param name="theScenario" as="element(scenario)*"/>
        <xsl:variable name="templateType" select="classification/@type"/>
        <xsl:variable name="tmid" select="@id"/>
        <xsl:variable name="tmed" select="@effectiveDate"/>
        <xsl:variable name="name" select="substring-before(@name,'_')"/>
        <xsl:variable name="tmdn" select="if (@displayName) then @displayName else @name"/>
        <xsl:variable name="tmassocs" select="$allDECOR/rules/templateAssociation[@templateId = $tmid][@effectiveDate = $tmed]" as="element(templateAssociation)*"/>
        <xsl:variable name="sectionType">
            <xsl:choose>
                <xsl:when test="$templateType='messagelevel'">Message</xsl:when>
                <xsl:when test="$templateType='segmentlevel'">Segment</xsl:when>
                <xsl:when test="$templateType='datatypelevel'">Datatype</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="tableType">
            <xsl:choose>
                <xsl:when test="$templateType='messagelevel'"/>
                <xsl:when test="$templateType='segmentlevel'">HL7 Attribute Table</xsl:when>
                <xsl:when test="$templateType='datatypelevel'">HL7 Component Table</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="segmentAnchor" select="local:doHtmlAnchor($tmid,$tmed)"/>
        <xsl:variable name="segmentAnchorTitle">
            <xsl:call-template name="getMessage">
                <xsl:with-param name="key" select="$sectionType"/>
            </xsl:call-template>
            <xsl:text>: </xsl:text>
            <xsl:if test="not(contains($tmdn, $name))">
                <xsl:value-of select="$name"/>
                <xsl:text> - </xsl:text>
            </xsl:if>
            <xsl:value-of select="$tmdn"/>
        </xsl:variable>
        <!-- h2 - header and (comparable to how the V2 guides work, 
            the metadata of the template (messages only), 
            the top level description text (if any) above the table of segment/datatype contents only (not for datatypes, only for messages/segments)  -->
        <div class="bs-docs-section" xmlns="http://www.w3.org/1999/xhtml">
            <h2 id="{$segmentAnchor}" class="sub-header dcm-color-h2">
                <xsl:value-of select="$segmentAnchorTitle"/>
                <xsl:if test="$templateType = 'segmentlevel'">
                    <xsl:for-each-group select="$allDECOR//template[classification/@type = 'messagelevel'][concat(@id, @effectiveDate) = $theV2Templates/concat(@id, @effectiveDate)]//*[(@ref | @contains) = $tmid][@minimumMultiplicity[. > 0] | @conformance[not(. = 'NP')] | @isMandatory[. = 'true']]" group-by="ancestor::template/concat(@id, @effectiveDate)">
                        <xsl:variable name="tableitemid" select="concat('_table_', string-join(for $a in current-group()[1]/ancestor::*[not(descendant-or-self::template)] return string(count($a/preceding-sibling::*) + 1),'_'),'_',string(count(preceding-sibling::*) + 1))"/>
                        <xsl:variable name="segmentAnchorTitle">
                            <xsl:choose>
                                <xsl:when test="count(current-group()) &gt; 1">
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'backToXwithYoccurences'"/>
                                        <xsl:with-param name="p1" select="ancestor::template/@displayName"/>
                                        <xsl:with-param name="p2" select="count(current-group())"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'backToX'"/>
                                        <xsl:with-param name="p1" select="ancestor::template/@displayName"/>
                                    </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <a href="#{$tableitemid}" class="btn btn-default btn-xs pull-right" data-toggle="tooltip" data-placement="left" title="{$segmentAnchorTitle}">
                            <span class="glyphicon glyphicon-arrow-up" aria-hidden="true"/>
                            <xsl:text> </xsl:text>
                            <xsl:if test="count(current-group()) &gt; 1">
                                <span class="badge">
                                    <xsl:value-of select="count(current-group())"/>
                                </span>
                            </xsl:if>
                        </a>
                    </xsl:for-each-group>
                </xsl:if>
            </h2>
            <xsl:if test="$templateType = 'messagelevel'">
                <xsl:apply-templates select="." mode="doMeta"/>
            </xsl:if>
            <xsl:if test="desc[not($templateType = 'datatypelevel')]">
                <div class="row dcm-par">
                    <xsl:call-template name="doDescription">
                        <xsl:with-param name="ns" select="desc"/>
                    </xsl:call-template>
                </div>
            </xsl:if>
        </div>
        <!-- table of contents with segment/datatype contents,
             the top level description text (if any) below the table of segment/datatype contents only (datatypes only),
             all fields/components with their descriptions and bindings
        -->
        <xsl:if test="(element[@datatype] | include | choice)">
            <!-- table with segment/datatype contents -->
            <div class="table-responsive dcm-par" xmlns="http://www.w3.org/1999/xhtml">
                <table class="table table-striped table-condensed dcm-font-size">
                    <caption class="text-center"><xsl:value-of select="$tableType"/> - <xsl:value-of select="$name"/> - <xsl:value-of select="$tmdn"/></caption>
                    <thead>
                        <tr>
                            <th>SEQ</th>
                            <!--<th>LEN</th>-->
                            <th>DT</th>
                            <th>OPT</th>
                            <xsl:if test="$templateType = 'segmentlevel'">
                                <th>RP/#</th>
                            </xsl:if>
                            <th>TBL#</th>
                            <xsl:if test="$templateType = 'segmentlevel'">
                                <th>ITEM#</th>
                            </xsl:if>
                            <th>ELEMENT NAME</th>
                        </tr>
                    </thead>
                    <tbody>
                        <!-- elements with a datatype have content. without datatype they are a group of some kind -->
                        <xsl:for-each select="element[@datatype] | include | choice">
                            <xsl:variable name="elid" select="@id"/>
                            <xsl:variable name="conceptAssociations" select="$allTemplateAssociation/*/templateAssociation[@templateId=$tmid][@effectiveDate=$tmed]/concept[@elementId = $elid]" as="element()*"/>
                            
                            <xsl:if test="@minimumMultiplicity[. > 0] | @isMandatory[. = 'true'] | @conformance[not(. = 'NP')] | text | assert | report | vocabulary | $conceptAssociations | $templateType[. = 'datatypelevel']">
                                <xsl:apply-templates select="." mode="doSegmentTableContents">
                                    <xsl:with-param name="segmentAnchor" select="$segmentAnchor"/>
                                    <xsl:with-param name="segmentAnchorTitle" select="$segmentAnchorTitle"/>
                                    <xsl:with-param name="templateType" select="$templateType"/>
                                </xsl:apply-templates>
                            </xsl:if>
                        </xsl:for-each>
                    </tbody>
                </table>
            </div>
        </xsl:if>
        <xsl:if test="desc[$templateType = 'datatypelevel']">
            <div class="row dcm-par" xmlns="http://www.w3.org/1999/xhtml">
                <xsl:call-template name="doDescription">
                    <xsl:with-param name="ns" select="desc"/>
                </xsl:call-template>
            </div>
        </xsl:if>
        <xsl:if test="(element[@datatype] | include | choice)">
            <div class="bs-docs-section" xmlns="http://www.w3.org/1999/xhtml">
                <xsl:if test="not($templateType = 'datatypelevel')">
                    <h3 class="sub-header dcm-color-h3">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'parFieldDefinitions'"/>
                            <xsl:with-param name="p1" select="$segmentAnchorTitle"/>
                        </xsl:call-template>
                    </h3>
                </xsl:if>
                <!-- elements with a datatype have content. without datatype they are a group of some kind -->
                <xsl:for-each select="element[@datatype] | include | choice">
                    <xsl:variable name="elid" select="@id"/>
                    <xsl:variable name="conceptAssociations" select="$allTemplateAssociation/*/templateAssociation[@templateId=$tmid][@effectiveDate=$tmed]/concept[@elementId = $elid]" as="element()*"/>
                    
                    <xsl:if test="@minimumMultiplicity[. > 0] | @isMandatory[. = 'true'] | @conformance[not(. = 'NP')] | text | assert | report | vocabulary | $conceptAssociations | $templateType[. = 'datatypelevel']">
                        <xsl:apply-templates select="." mode="doSegmentField">
                            <xsl:with-param name="segmentAnchor" select="$segmentAnchor"/>
                            <xsl:with-param name="segmentAnchorTitle" select="$segmentAnchorTitle"/>
                            <xsl:with-param name="theScenario" select="$theScenario"/>
                            <xsl:with-param name="templateAssociations" select="$tmassocs"/>
                        </xsl:apply-templates>
                    </xsl:if>
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
        <xd:param name="segmentAnchor"/>
        <xd:param name="templateType"/>
    </xd:doc>
    <xsl:template match="element" mode="doSegmentTableContents">
        <xsl:param name="segmentAnchor"/>
        <xsl:param name="templateType"/>
        <xsl:variable name="containedTemplate" as="element(template)*">
            <xsl:call-template name="getRulesetContent">
                <xsl:with-param name="ruleset" select="@contains"/>
                <xsl:with-param name="flexibility" select="@flexibility"/>
                <xsl:with-param name="sofar" select="()"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="datatypeAttr">
            <xsl:choose>
                <xsl:when test="@datatype">
                    <xsl:value-of select="@datatype"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="attribute[@name = 'Type']/@value"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="itemNumber" select="local:getFormattedItemNumber(attribute[@name='Item']/@value)"/>
        <tr xmlns="http://www.w3.org/1999/xhtml">
            <!-- sequence number -->
            <td><xsl:value-of select="substring-after(@name,'.')"/></td>
            <!--<td>LEN</td>-->
            <!-- datatype -->
            <td>
                <xsl:choose>
                    <xsl:when test="$containedTemplate and not(@conformance = 'NP')">
                        <a href="#{local:doHtmlAnchor($containedTemplate/@id, $containedTemplate/@effectiveDate)}" data-toggle="tooltip" data-placement="right" title="{$containedTemplate/@displayName}">
                            <xsl:value-of select="$datatypeAttr"/>
                        </a>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$datatypeAttr"/>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
            <!-- conformance -->
            <td>
                <xsl:choose>
                    <xsl:when test="@conformance = 'NP'">
                        <span data-toggle="tooltip" data-placement="right" title="{local:getDisplayNameForCode($hl7v2OptionalityTable, 'X')}">X</span>
                    </xsl:when>
                    <xsl:when test="@conformance = 'C'">
                        <span data-toggle="tooltip" data-placement="right" title="{local:getDisplayNameForCode($hl7v2OptionalityTable, 'C')}">C</span>
                    </xsl:when>
                    <xsl:when test="@isMandatory = 'true'">
                        <span data-toggle="tooltip" data-placement="right" title="{local:getDisplayNameForCode($hl7v2OptionalityTable, 'R')}">R</span>
                    </xsl:when>
                    <xsl:when test="@conformance = 'R'">
                        <span data-toggle="tooltip" data-placement="right" title="{local:getDisplayNameForCode($hl7v2OptionalityTable, 'R')}">R</span>
                    </xsl:when>
                    <xsl:when test="@minimumMulitplicity > 0">
                        <span data-toggle="tooltip" data-placement="right" title="{local:getDisplayNameForCode($hl7v2OptionalityTable, 'R')}">R</span>
                    </xsl:when>
                    <xsl:otherwise>
                        <span data-toggle="tooltip" data-placement="right" title="{local:getDisplayNameForCode($hl7v2OptionalityTable, 'O')}">O</span>
                        <!--<xsl:variable name="elid" select="@id"/>
                        <xsl:variable name="tmid" select="ancestor::template[1]/@id"/>
                        <xsl:variable name="tmed" select="ancestor::template[1]/@effectiveDate"/>
                        <xsl:variable name="de" select="ancestor::template[1]/preceding-sibling::templateAssociation[@templateId = $tmid][@effectiveDate = $tmed]/concept[@elementId = $elid]"/>
                        <xsl:variable name="trde" select="$theV2Scenarios//representingTemplate/concept[@ref = $de/@ref]"/>
                        <xsl:choose>
                            <xsl:when test="$trde">
                                <span data-toggle="tooltip" data-placement="right" title="{local:getDisplayNameForCode($hl7v2OptionalityTable, 'O')}">O</span>
                            </xsl:when>
                            <xsl:otherwise>
                                <span data-toggle="tooltip" data-placement="right" title="{local:getDisplayNameForCode($hl7v2OptionalityTable, 'O')}">O</span>
                            </xsl:otherwise>
                        </xsl:choose>-->
                    </xsl:otherwise>
                </xsl:choose>
            </td>
            <!-- repeats -->
            <xsl:if test="$templateType = 'segmentlevel'">
                <td>
                    <xsl:if test="not(@conformance = 'NP')">
                        <xsl:choose>
                            <xsl:when test="not(@maximumMultiplicity) or @maximumMultiplicity = '*' or @maximumMultiplicity > 1">
                                <xsl:text>Y</xsl:text>
                                <xsl:if test="@maximumMultiplicity castable as xs:integer and @maximumMultiplicity > 1">
                                    <xsl:text>/</xsl:text>
                                    <xsl:value-of select="@maximumMultiplicity"/>
                                </xsl:if>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:if>
                </td>
            </xsl:if>
            <!-- table -->
            <td>
                <xsl:variable name="tableName" select="replace(attribute[@name = 'Table']/@value, '^HL7(\d{4,})$', '$1')"/>
                <xsl:variable name="table" select="$doV2ValueSets[@name = $tableName][@effectiveDate = max($doV2ValueSets[@name = $tableName]/xs:dateTime(@effectiveDate))]" as="element()?"/>
                <xsl:choose>
                    <xsl:when test="$table and not(@conformance = 'NP')">
                        <a href="#{local:doHtmlAnchor($table/@id, $table/@effectiveDate)}" data-toggle="tooltip" data-placement="right" title="{$table/@displayName}">
                            <xsl:value-of select="replace($tableName,'HL7','')"/>
                        </a>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="replace($tableName,'HL7','')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
            <!-- item number -->
            <xsl:if test="$templateType = 'segmentlevel'">
                <td>
                    <xsl:choose>
                        <xsl:when test="not(@conformance = 'NP')">
                            <a href="#{concat($segmentAnchor,'_',generate-id(.))}"><xsl:value-of select="$itemNumber"/></a>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$itemNumber"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </xsl:if>
            <!-- longname -->
            <td>
                <xsl:choose>
                    <xsl:when test="$templateType = 'datatypelevel'">
                        <a href="#{concat($segmentAnchor,'_',generate-id(.))}"><xsl:value-of select="attribute[@name='LongName']/@value"/></a>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="attribute[@name='LongName']/@value"/>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
        </tr>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
        <xd:param name="segmentAnchor"/>
    </xd:doc>
    <xsl:template match="include | choice" mode="doSegmentTableContents">
        <xsl:param name="segmentAnchor"/>
        <xsl:call-template name="logMessage">
            <xsl:with-param name="level" select="$logERROR"/>
            <xsl:with-param name="msg">
                <xsl:text>+++ doSegmentTableContents found unhandled contents: name='</xsl:text>
                <xsl:value-of select="name(.)"/>
                <xsl:text>'</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:pre>In: hl7v2:OML_O21.OBSERVATION_REQUEST      Out: OBSERVATION_REQUEST</xd:pre>
            <br/>
            <xd:pre>In: hl7v2:MSH                              Out: MSH</xd:pre>
        </xd:desc>
        <xd:param name="element">Template element. We use @name, e.g. hl7v2:OML_O21.OBSERVATION_REQUEST</xd:param>
        <xd:param name="model"/>
    </xd:doc>
    <xsl:template name="doElementName">
        <xsl:param name="element" as="element()"/>
        <xsl:param name="model"/>
        <xsl:variable name="nopfx" select="replace($element/@name,'^[^:]+:','')"/>
        <xsl:value-of select="if (starts-with($nopfx, concat($model,'.'))) then substring-after($nopfx, concat($model,'.')) else $nopfx"/>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
        <xd:param name="element"/>
    </xd:doc>
    <xsl:template name="doElementDescription">
        <xsl:param name="element" as="element()"/>
        <xsl:choose>
            <xsl:when test="$element/@contains">
                <xsl:variable name="theTemplate" as="element(template)">
                    <xsl:call-template name="getRulesetContent">
                        <xsl:with-param name="ruleset" select="$element/@contains"/>
                        <xsl:with-param name="flexibility" select="$element/@flexibility"/>
                        <xsl:with-param name="sofar" select="()"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:value-of select="if ($theTemplate[@displayName]) then $theTemplate/@displayName else $theTemplate/@name"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="doDescription">
                    <xsl:with-param name="ns" select="$element/desc"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
        <!-- example -->
        <xsl:apply-templates select="example" mode="doDiv"/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="*" mode="doMeta">
        <!-- Properties -->
        <xsl:variable name="properties" as="element()*">
            <xsl:if test="@id | @ref">
                <property name="Id">
                    <xsl:value-of select="@id | @ref"/>
                </property>
            </xsl:if>
            <xsl:if test="@statusCode">
                <property name="LifecycleStatus">
                    <xsl:value-of select="@statusCode/concat(upper-case(substring(., 1, 1)), substring(., 2))"/>
                </property>
            </xsl:if>
            <!--<property name="Name">
                <xsl:call-template name="doName">
                    <xsl:with-param name="ns" select="name"/>
                </xsl:call-template>
            </property>-->
            <xsl:if test="@effectiveDate">
                <property name="CreationDate">
                    <xsl:value-of select="@effectiveDate"/>
                </property>
            </xsl:if>
            <xsl:if test="@expirationDate">
                <property name="DeprecatedDate">
                    <xsl:value-of select="@expirationDate"/>
                </property>
            </xsl:if>
            <xsl:if test="@versionLabel">
                <property name="VersionLabel">
                    <xsl:value-of select="@versionLabel"/>
                </property>
            </xsl:if>
            <xsl:for-each select="actors/actor">
                <xsl:variable name="acid" select="@id"/>
                <property name="Actor{concat(upper-case(substring(@role,1,1)),substring(@role,2))}">
                    <xsl:call-template name="doName">
                        <xsl:with-param name="ns" select="$allDECOR/scenarios/actors/actor[@id = $acid]/name"/>
                    </xsl:call-template>
                </property>
            </xsl:for-each>
            <xsl:copy-of select="property"/>
        </xsl:variable>
        <xsl:if test="$properties">
            <div class="table-responsive dcm-par" xmlns="http://www.w3.org/1999/xhtml">
                <table class="table table-striped table-condensed dcm-font-size">
                    <tbody>
                        <xsl:for-each-group select="$properties" group-by="@name">
                            <xsl:sort select="@name"/>
                            <tr>
                                <td>
                                    <xsl:value-of select="current-grouping-key()"/>
                                </td>
                                <td>
                                    <xsl:value-of select="current-group()[string-length() > 0][1]"/>
                                </td>
                            </tr>
                        </xsl:for-each-group>
                    </tbody>
                </table>
            </div>
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc/>
        <xd:param name="segmentAnchor"/>
        <xd:param name="segmentAnchorTitle"/>
        <xd:param name="theScenario"/>
        <xd:param name="templateAssociations"/>
    </xd:doc>
    <xsl:template match="element" mode="doSegmentField">
        <xsl:param name="segmentAnchor"/>
        <xsl:param name="segmentAnchorTitle"/>
        <xsl:param name="theScenario" as="element(scenario)*"/>
        <xsl:param name="templateAssociations" as="element(templateAssociation)*"/>
        <xsl:variable name="containedTemplate" as="element(template)*">
            <xsl:call-template name="getRulesetContent">
                <xsl:with-param name="ruleset" select="@contains"/>
                <xsl:with-param name="flexibility" select="@flexibility"/>
                <xsl:with-param name="sofar" select="()"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="nameAttr" select="replace(replace(@name,'^[^:]+:',''),'\.','-')"/>
        <xsl:variable name="datatypeAttr">
            <xsl:choose>
                <xsl:when test="@datatype">
                    <xsl:value-of select="@datatype"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="attribute[@name='Type']/@value"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="itemNumber" select="local:getFormattedItemNumber(attribute[@name='Item']/@value)"/>
        <xsl:variable name="longName" select="attribute[@name='LongName']/@value"/>
        <!-- MSH-1 Field Separator (ST) 00001 -->
        <h3 id="{concat($segmentAnchor,'_',generate-id(.))}" class="sub-header dcm-color-h3" xmlns="http://www.w3.org/1999/xhtml">
            <xsl:value-of select="$nameAttr"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="attribute[@name='LongName']/@value"/>
            <xsl:text> (</xsl:text>
            <xsl:choose>
                <xsl:when test="$containedTemplate">
                    <a href="#{local:doHtmlAnchor($containedTemplate/@id, $containedTemplate/@effectiveDate)}" data-toggle="tooltip" data-placement="right" title="{$containedTemplate/@displayName}">
                        <xsl:value-of select="$datatypeAttr"/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$datatypeAttr"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>) </xsl:text>
            <xsl:value-of select="$itemNumber"/>
            <a href="#{$segmentAnchor}" class="btn btn-default btn-xs pull-right" data-toggle="tooltip" data-placement="left" title="{$segmentAnchorTitle}"><span class="glyphicon glyphicon-arrow-up" aria-hidden="true"/></a>
        </h3>
        <xsl:if test="desc[text()[not(. = $longName)]]">
            <div class="row dcm-par" xmlns="http://www.w3.org/1999/xhtml">
                <xsl:call-template name="doDescription">
                    <xsl:with-param name="ns" select="desc"/>
                </xsl:call-template>
            </div>
        </xsl:if>
        <!-- constraint -->
        <xsl:if test="constraint[.//text()]">
            <div class="row dcm-par" xmlns="http://www.w3.org/1999/xhtml">
                <div class="panel panel-warning">
                    <div class="panel-heading dcm-panel-heading">
                        <span class="glyphicon glyphicon-warning-sign" aria-hidden="true" data-toggle="tooltip" data-placement="bottom">
                            <xsl:attribute name="title">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'constraintLabel'"/>
                                </xsl:call-template>
                            </xsl:attribute>
                        </span>
                        <xsl:text> </xsl:text>
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'constraintLabel'"/>
                        </xsl:call-template>
                    </div>
                    <div class="panel-body dcm-panel-body">
                        <xsl:call-template name="doDescription">
                            <xsl:with-param name="ns" select="constraint"/>
                        </xsl:call-template>
                    </div>
                </div>
            </div>
        </xsl:if>
        <!-- example -->
        <xsl:apply-templates select="example" mode="doDiv"/>
        <!-- vocabulary -->
        <xsl:variable name="theVocabularies" select="vocabulary | text"/>
        <xsl:if test="$theVocabularies">
            <xsl:call-template name="doVocabulary">
                <xsl:with-param name="vocabularies" select="$theVocabularies"/>
                <xsl:with-param name="fieldName" select="$nameAttr"/>
            </xsl:call-template>
        </xsl:if>
        <!-- template associations -->
        <xsl:variable name="elid" select="@id"/>
        <xsl:variable name="de" select="$templateAssociations/concept[@ref = $theScenario//concept/@ref][@elementId = $elid]" as="element()*"/>
        <xsl:variable name="theConcepts" as="element(concept)*">
            <xsl:for-each-group select="$de" group-by="concat(@ref, @effectiveDate)">
                <xsl:variable name="deid" select=".[1]/@ref"/>
                <xsl:variable name="deed" select=".[1]/@effectiveDate"/>
                <xsl:choose>
                    <xsl:when test="concept">
                        <xsl:copy-of select="concept[1]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="local:getConceptFlat($deid[1], $deed[1])"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:variable>
        <xsl:if test="$de">
            <div class="row dcm-par" xmlns="http://www.w3.org/1999/xhtml">
                <div class="cell table-responsive">
                    <table class="table table-striped table-condensed dcm-font-size">
                        <xsl:for-each select="$theConcepts">
                            <xsl:variable name="deid" select="@id"/>
                            <xsl:variable name="deed" select="@effectiveDate"/>
                            <xsl:variable name="theConcept" select="." as="element()"/>
                            <xsl:variable name="dataset" select="local:getDatasetForConcept($deid, $deed)"/>
                            <xsl:variable name="dsid">
                                <xsl:choose>
                                    <xsl:when test="@datasetId">
                                        <xsl:value-of select="@datasetId"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$dataset/@id"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:variable name="dsef">
                                <xsl:choose>
                                    <xsl:when test="@datasetEffectiveDate">
                                        <xsl:value-of select="@datasetEffectiveDate"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$dataset/@effectiveDate"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:variable name="dspath">
                                <xsl:choose>
                                    <xsl:when test="@path">
                                        <xsl:value-of select="@path"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:for-each select="$dataset//concept[(@id | @ref) = $theConcept/(@id | @ref)][(@effectiveDate | @flexibility) = $theConcept/(@effectiveDate | @flexibility)]/ancestor::concept">
                                            <xsl:value-of select="local:getConceptFlat((@id | @ref), (@effectiveDate | @flexibility))/name[1]"/>
                                            <xsl:text> / </xsl:text>
                                        </xsl:for-each>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:variable name="dsname">
                                <xsl:choose>
                                    <xsl:when test="@datasetName">
                                        <xsl:value-of select="@datasetName"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:call-template name="doName">
                                            <!-- will not exist on RetrieveTemplate expanded templates -->
                                            <xsl:with-param name="ns" select="$dataset/name"/>
                                        </xsl:call-template>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:variable name="deiddisplay">
                                <xsl:choose>
                                    <xsl:when test="@refdisplay">
                                        <xsl:value-of select="@refdisplay"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:call-template name="doShorthandId">
                                            <xsl:with-param name="id" select="$deid"/>
                                        </xsl:call-template>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:variable name="originalInSet" select="if ($theConcept[inherit]) then ($theConcepts[concat(@id, @effectiveDate) = $theConcept/inherit/concat(@ref, @effectiveDate)]) else ()" as="element()?"/>
                            <xsl:variable name="matchingInherits" select="if ($theConcept[inherit]) then ($theConcepts[inherit/concat(@ref, @effectiveDate) = $theConcept/inherit/concat(@ref, @effectiveDate)]) else ()" as="element()*"/>
                            <xsl:variable name="isFirstInherit" select="if ($theConcept[inherit]) then (index-of($matchingInherits/concat(@id, @effectiveDate),concat($deid, $deed)) = 1) else (true())" as="xs:boolean"/>
                            <tr id="_ta_{generate-id(.)}_{generate-id($de[@conceptId = $theConcept/@id][1])}">
                                <td style="vertical-align: top; width: 18px">
                                    <xsl:call-template name="showIcon">
                                        <xsl:with-param name="which">target</xsl:with-param>
                                    </xsl:call-template>
                                </td>
                                <td style="vertical-align: top; width: 12em;">
                                    <a href="{local:doHtmlName('DS', $projectPrefix, $dsid, $dsef, $deid, $deed, (), (), '.html', 'false')}" onclick="target='_blank';">
                                        <xsl:copy-of select="$deiddisplay"/>
                                    </a>
                                </td>
                                <td style="vertical-align: top; width: 32%;">
                                    <xsl:if test="string-length($dspath) > 0">
                                        <xsl:attribute name="title" select="$dspath"/>
                                    </xsl:if>
                                    <xsl:call-template name="doName">
                                        <xsl:with-param name="ns" select="$theConcept/name"/>
                                    </xsl:call-template>
                                </td>
                                <td style="vertical-align: top;">
                                    <xsl:for-each select="$theConcept/valueDomain">
                                        <xsl:call-template name="getXFormsLabel">
                                            <xsl:with-param name="simpleTypeKey" select="'DataSetValueType'"/>
                                            <xsl:with-param name="simpleTypeValue" select="@type"/>
                                            <xsl:with-param name="lang" select="$defaultLanguage"/>
                                        </xsl:call-template>
                                    </xsl:for-each>
                                </td>
                                <td style="vertical-align: top;">
                                    <xsl:copy-of select="$dsname"/>
                                </td>
                            </tr>
                            <tr>
                                <td style="vertical-align: top; width: 18px"/>
                                <td style="vertical-align: top; width: 12em;"/>
                                <td colspan="3">
                                    <xsl:if test="string-length($dspath) > 0">
                                        <div>
                                            <strong>
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'pathWithColon'"/>
                                                </xsl:call-template>
                                            </strong>
                                            <i>
                                                <xsl:value-of select="$dspath"/>
                                            </i>
                                        </div>
                                    </xsl:if>
                                    <!-- Don't repeat the same description over and over. Just apply it to the original, if available -->
                                    <xsl:choose>
                                        <xsl:when test="$originalInSet | $matchingInherits[not($isFirstInherit)]">
                                            <div>
                                                <strong>
                                                    <xsl:call-template name="getMessage">
                                                        <xsl:with-param name="key" select="'Definition'"/>
                                                    </xsl:call-template>
                                                </strong>
                                                <xsl:text>: </xsl:text>
                                                <xsl:choose>
                                                    <xsl:when test="$originalInSet">
                                                        <xsl:call-template name="getMessage">
                                                            <xsl:with-param name="key" select="'inheritedFrom'"/>
                                                        </xsl:call-template>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:call-template name="getMessage">
                                                            <xsl:with-param name="key" select="'see'"/>
                                                        </xsl:call-template>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                                <xsl:text> </xsl:text>
                                                <xsl:choose>
                                                    <xsl:when test="$originalInSet">
                                                        <a href="#_ta_{generate-id($originalInSet)}_{generate-id($de[@conceptId = $originalInSet/@id][1])}">
                                                        <xsl:choose>
                                                            <xsl:when test="$originalInSet[@refdisplay]">
                                                                <xsl:value-of select="$originalInSet/@refdisplay"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:call-template name="doShorthandId">
                                                                    <xsl:with-param name="id" select="$originalInSet/@id"/>
                                                                </xsl:call-template>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                        </a>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <a href="#_ta_{generate-id($matchingInherits[1])}_{generate-id($de[@conceptId = $matchingInherits[1]/@id][1])}">
                                                        <xsl:choose>
                                                            <xsl:when test="$matchingInherits[1][@refdisplay]">
                                                                <xsl:value-of select="$matchingInherits[1]/@refdisplay"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:call-template name="doShorthandId">
                                                                    <xsl:with-param name="id" select="$matchingInherits[1]/@id"/>
                                                                </xsl:call-template>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                        </a>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </div>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:if test="$theConcept/desc[node()]">
                                                <div>
                                                    <strong>
                                                        <xsl:call-template name="getMessage">
                                                            <xsl:with-param name="key" select="'Definition'"/>
                                                        </xsl:call-template>
                                                    </strong>
                                                    <xsl:text>: </xsl:text>
                                                    <xsl:call-template name="doDescription">
                                                        <xsl:with-param name="ns" select="$theConcept/desc"/>
                                                    </xsl:call-template>
                                                </div>
                                            </xsl:if>
                                            <!-- vocabulary.... -->
                                            <!-- compiled projects will have them in the concept. otherwise go look for ourselves. xsl:choose with xsl:copy-of would be nicer to read but looses context that we need later one -->
                                            <xsl:variable name="conceptAssociations" select="if ($theConcept[terminologyAssociation]) then $theConcept/terminologyAssociation[@code] else $allTerminologyAssociations/*/terminologyAssociation[@conceptId = ($deid | $theConcept/inherit/@ref)][@code]" as="element(terminologyAssociation)*"/>
                                            <!-- compiled projects will have them in the concept. otherwise go look for ourselves. xsl:choose with xsl:copy-of would be nicer to read but looses context that we need later one-->
                                            <xsl:variable name="conceptDomainAssociations" select="if ($theConcept[valueSet/terminologyAssociation]) then $theConcept/valueSet/terminologyAssociation[@valueSet] else $allTerminologyAssociations/*/terminologyAssociation[@conceptId = ($theConcept/valueDomain/conceptList/@id | $theConcept/valueDomain/conceptList/@ref)][@valueSet]" as="element(terminologyAssociation)*"/>
                                            
                                            <!-- If there is and active element level vocabulary: skip writing concept bindings -->
                                            <xsl:choose>
                                                <xsl:when test="$theVocabularies"/>
                                                <xsl:otherwise>
                                                    <xsl:for-each select="$conceptAssociations">
                                                        <xsl:variable name="expiredLook">
                                                            <xsl:if test="@expirationDate castable as xs:dateTime and xs:dateTime(@expirationDate) &lt;= current-dateTime()">text-decoration: line-through;</xsl:if>
                                                        </xsl:variable>
                                                        <div>
                                                            <xsl:if test="$theVocabularies">
                                                                <xsl:attribute name="style">text-decoration: line-through;</xsl:attribute>
                                                            </xsl:if>
                                                            <strong>
                                                                <xsl:call-template name="getMessage">
                                                                    <xsl:with-param name="key" select="'terminologyAssociation'"/>
                                                                </xsl:call-template>
                                                            </strong>
                                                            <xsl:text>: </xsl:text>
                                                            <span style="{$expiredLook}">
                                                                <xsl:choose>
                                                                    <xsl:when test="string-length(@displayName) > 0">
                                                                        <xsl:call-template name="getMessage">
                                                                            <xsl:with-param name="key" select="'conceptRepresentationLineWithDisplay'"/>
                                                                            <xsl:with-param name="p1" select="@code"/>
                                                                            <xsl:with-param name="p2" select="@codeSystem"/>
                                                                            <xsl:with-param name="p3" select="@displayName"/>
                                                                        </xsl:call-template>
                                                                    </xsl:when>
                                                                    <xsl:otherwise>
                                                                        <xsl:call-template name="getMessage">
                                                                            <xsl:with-param name="key" select="'conceptRepresentationLine'"/>
                                                                            <xsl:with-param name="p1" select="@code"/>
                                                                            <xsl:with-param name="p2" select="@codeSystem"/>
                                                                        </xsl:call-template>
                                                                    </xsl:otherwise>
                                                                </xsl:choose>
                                                                <xsl:text> </xsl:text>
                                                                <i>
                                                                    <xsl:call-template name="getIDDisplayName">
                                                                        <xsl:with-param name="root" select="@codeSystem"/>
                                                                    </xsl:call-template>
                                                                </i>
                                                                <xsl:if test="@expirationDate">
                                                                    <xsl:text> (</xsl:text>
                                                                    <xsl:call-template name="getMessage">
                                                                        <xsl:with-param name="key" select="'toY'"/>
                                                                    </xsl:call-template>
                                                                    <xsl:call-template name="showDate">
                                                                        <xsl:with-param name="date" select="@expirationDate"/>
                                                                    </xsl:call-template>
                                                                    <xsl:text>)</xsl:text>
                                                                </xsl:if>
                                                            </span>
                                                        </div>
                                                    </xsl:for-each>
                                                    <xsl:for-each select="$conceptDomainAssociations">
                                                        <xsl:variable name="expiredLook">
                                                            <xsl:if test="@expirationDate castable as xs:dateTime and xs:dateTime(@expirationDate) &lt;= current-dateTime()">text-decoration: line-through;</xsl:if>
                                                        </xsl:variable>
                                                        <xsl:variable name="xvsref" select="@valueSet"/>
                                                        <xsl:variable name="xvsflex" select="
                                                                if (@flexibility) then
                                                                    (@flexibility)
                                                                else
                                                                    ('dynamic')"/>
                                                        <xsl:variable name="vs" as="element()?">
                                                            <xsl:choose>
                                                                <!-- compiled projects will have them here -->
                                                                <xsl:when test="parent::valueSet">
                                                                    <xsl:copy-of select="parent::valueSet"/>
                                                                </xsl:when>
                                                                <!-- otherwise go look for ourselves -->
                                                                <xsl:otherwise>
                                                                    <xsl:call-template name="getValueset">
                                                                        <xsl:with-param name="reference" select="$xvsref"/>
                                                                        <xsl:with-param name="flexibility" select="$xvsflex"/>
                                                                    </xsl:call-template>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </xsl:variable>
                                                        <div>
                                                            <xsl:if test="$theVocabularies">
                                                                <xsl:attribute name="style">text-decoration: line-through;</xsl:attribute>
                                                            </xsl:if>
                                                            <strong>
                                                                <xsl:call-template name="getMessage">
                                                                    <xsl:with-param name="key" select="'terminologyAssociation'"/>
                                                                </xsl:call-template>
                                                            </strong>
                                                            <xsl:text>: </xsl:text>
                                                            <span style="{$expiredLook}">
                                                                <!-- %%1 Value Set (display) name, %%2 ValueSet id, %%3 Value Set flexibility, %%4 URL for Value Set (or #) -->
                                                                <xsl:call-template name="getMessage">
                                                                    <xsl:with-param name="key" select="'conceptValuesRepresentationLine'"/>
                                                                    <xsl:with-param name="p1"
                                                                        select="
                                                                            if ($vs) then
                                                                                (if ($vs/@displayName) then
                                                                                    $vs/@displayName
                                                                                else
                                                                                    $vs/@name)
                                                                            else
                                                                                $xvsref"/>
                                                                    <xsl:with-param name="p2" select="$vs/@id"/>
                                                                    <xsl:with-param name="p3">
                                                                        <xsl:choose>
                                                                            <xsl:when test="$xvsflex = 'dynamic'">
                                                                                <xsl:call-template name="getMessage">
                                                                                    <xsl:with-param name="key" select="'associationDYNAMIC'"/>
                                                                                </xsl:call-template>
                                                                            </xsl:when>
                                                                            <xsl:otherwise>
                                                                                <xsl:value-of select="$xvsflex"/>
                                                                            </xsl:otherwise>
                                                                        </xsl:choose>
                                                                    </xsl:with-param>
                                                                    <xsl:with-param name="p4" select="local:doHtmlName('VS', $vs/@id, $xvsflex, '.html')"/>
                                                                </xsl:call-template>
                                                                <xsl:if test="@expirationDate">
                                                                    <xsl:text> (</xsl:text>
                                                                    <xsl:call-template name="getMessage">
                                                                        <xsl:with-param name="key" select="'toY'"/>
                                                                    </xsl:call-template>
                                                                    <xsl:call-template name="showDate">
                                                                        <xsl:with-param name="date" select="@expirationDate"/>
                                                                    </xsl:call-template>
                                                                    <xsl:text>)</xsl:text>
                                                                </xsl:if>
                                                            </span>
                                                        </div>
                                                    </xsl:for-each>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            <xsl:if test="$theConcept/valueDomain/conceptList[not($conceptDomainAssociations)]">
                                                <xsl:message>*** WARNING Missing value set(s) for concept "<xsl:value-of select="$theConcept/name[1]"/>" with id "<xsl:value-of select="$deid"/>" and value domain of type code</xsl:message>
                                                <xsl:if test="$theConcept/operationalization[node()]">
                                                    <div>
                                                        <strong>
                                                            <xsl:call-template name="getMessage">
                                                                <xsl:with-param name="key" select="'Operationalization'"/>
                                                            </xsl:call-template>
                                                        </strong>
                                                        <xsl:text>: </xsl:text>
                                                        <xsl:call-template name="doDescription">
                                                            <xsl:with-param name="ns" select="$theConcept/operationalization"/>
                                                        </xsl:call-template>
                                                    </div>
                                                </xsl:if>
                                            </xsl:if>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </td>
                            </tr>
                        </xsl:for-each>
                    </table>
                </div>
            </div>
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc/>
        <xd:param name="segmentAnchor"/>
        <xd:param name="segmentAnchorTitle"/>
    </xd:doc>
    <xsl:template match="valueSet" mode="doTable">
        <xsl:param name="segmentAnchor"/>
        <xsl:param name="segmentAnchorTitle"/>
        <!-- ToedieningHulpmiddelCodelijst        OID: 2.16.840.1.113883.2.4.3.11.60.40.2.12.5.4
             Concept Name             Concept Code    CodeSys. Name   CodeSystem OID              Description
             Oxygen nasal cannula     336623009       SNOMED CT       2.16.840.1.11388 3.6.96     Neusbril
        -->
        <!-- HL7 Table 0190 - Address type
            Value           Description             Comment
            BA              Bad address
        -->
        <!-- <div title="V2 TABLE TYPE DO NOT REMOVE. VALUES (See chapter 2): &#34;HL7&#34; (HL7 Table) or &#34;User&#34; (User-defined)" itemprop="HL7v2TableType">HL7</div> -->
        <xsl:variable name="tableType" select="local:getTableType(.)"/>
        <xsl:variable name="tableName" select="local:getTableName(., $tableType)"/>
        <xsl:variable name="doCodeSystem" select="$tableType = 'External' or completeCodeSystem" as="xs:boolean"/>
        <xsl:variable name="doTranslation" select="exists(conceptList//designation[@type = 'preferred'])" as="xs:boolean"/>
        <xsl:variable name="doDescription" select="exists(conceptList//desc)" as="xs:boolean"/>
        <xsl:variable name="colWidthCode" select="'10%'"/>
        <xsl:variable name="colWidthDisplayName" select="if ($doCodeSystem and $doDescription) then '20%' else if ($doCodeSystem or $doDescription) then '30%' else if ($doTranslation) then '45%' else '90%'"/>
        <xsl:variable name="colWidthTranslation" select="$colWidthDisplayName"/>
        <xsl:variable name="vsid" select="@id"/>
        <xsl:variable name="vsed" select="@effectiveDate"/>
        <xsl:variable name="vsdn" select="if (@displayName) then @displayName else @name"/>
        <xsl:variable name="segmentAnchor" select="local:doHtmlAnchor($vsid,$vsed)"/>
        <xsl:variable name="sectionType" select="'valueSet'"/>
        <div class="bs-docs-section" xmlns="http://www.w3.org/1999/xhtml">
            <h3 id="{$segmentAnchor}" class="sub-header dcm-color-h2">
                <xsl:call-template name="getMessage">
                    <xsl:with-param name="key" select="$sectionType"/>
                </xsl:call-template>
                <xsl:text>: </xsl:text>
                <xsl:value-of select="$tableName"/>
                <xsl:text> - </xsl:text>
                <xsl:value-of select="$vsdn"/>
                <a href="#{$segmentAnchor}" class="btn btn-default btn-xs pull-right" data-toggle="tooltip" data-placement="left" title="{$segmentAnchorTitle}"><span class="glyphicon glyphicon-arrow-up" aria-hidden="true"/></a>
            </h3>
        </div>
        <div class="table-responsive dcm-par" xmlns="http://www.w3.org/1999/xhtml">
            <table class="table table-striped table-condensed dcm-font-size">
                <caption class="text-center">
                    <xsl:call-template name="getMessage">
                        <xsl:with-param name="key" select="concat('TableType',$tableType)"/>
                        <xsl:with-param name="p1" select="$tableName"/>
                        <xsl:with-param name="p2" select="@displayName"/>
                    </xsl:call-template>
                </caption>
                <thead>
                    <tr>
                        <td style="width: {$colWidthCode}">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'Code'"/>
                            </xsl:call-template>
                        </td>
                        <td style="width: {$colWidthDisplayName}">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'DisplayName'"/>
                            </xsl:call-template>
                        </td>
                        <xsl:if test="$doTranslation">
                            <td style="width: {$colWidthTranslation}">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'Designations'"/>
                                </xsl:call-template>
                            </td>
                        </xsl:if>
                        <xsl:if test="$doCodeSystem">
                            <td style="width: 10%;">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'CodeSystemId'"/>
                                </xsl:call-template>
                            </td>
                            <td style="width: 10%;">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'CodeSystemName'"/>
                                </xsl:call-template>
                            </td>
                        </xsl:if>
                        <xsl:if test="$doDescription">
                            <td>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'Description'"/>
                                </xsl:call-template>
                            </td>
                        </xsl:if>
                    </tr>
                </thead>
                <tbody>
                    <xsl:choose>
                        <xsl:when test="completeCodeSystem | conceptList/concept | conceptList/exception">
                            <xsl:for-each select="completeCodeSystem">
                                <xsl:variable name="csoid" select="@codeSystem"/>
                                <tr>
                                    <td colspan="{if ($doTranslation) then 3 else 2}"/>
                                    <td>
                                        <xsl:value-of select="$csoid"/>
                                    </td>
                                    <td>
                                        <xsl:call-template name="decorCodesystemOID2Codesystemname">
                                            <xsl:with-param name="oid" select="$csoid"/>
                                            <xsl:with-param name="sourceCodeSystems" select="ancestor::valueSet/sourceCodeSystem"/>
                                        </xsl:call-template>
                                    </td>
                                    <td/>
                                </tr>
                            </xsl:for-each>
                            <xsl:for-each select="conceptList/concept | conceptList/exception">
                                <xsl:variable name="csoid" select="@codeSystem"/>
                                <tr>
                                    <td>
                                        <xsl:value-of select="@code"/>
                                    </td>
                                    <td>
                                        <xsl:value-of select="@displayName"/>
                                    </td>
                                    <xsl:if test="$doTranslation">
                                        <td>
                                            <xsl:for-each select="designation[@type = 'preferred'][@language = ('nl-NL', 'nl')]">
                                                <div>
                                                    <xsl:choose>
                                                        <xsl:when test="@language=('de-DE','nl-NL','en-US')">
                                                            <xsl:call-template name="showIcon">
                                                                <xsl:with-param name="which" select="@language"/>
                                                                <xsl:with-param name="tooltip" select="@language"/>
                                                                <xsl:with-param name="style" select="'margin-right: 4px;'"/>
                                                            </xsl:call-template>
                                                            <xsl:text> </xsl:text>
                                                        </xsl:when>
                                                        <xsl:when test="@language=('nl')">
                                                            <xsl:call-template name="showIcon">
                                                                <xsl:with-param name="which" select="'nl-NL'"/>
                                                                <xsl:with-param name="tooltip" select="'nl-NL'"/>
                                                                <xsl:with-param name="style" select="'margin-right: 4px;'"/>
                                                            </xsl:call-template>
                                                            <xsl:text> </xsl:text>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="@language"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                    <xsl:value-of select="@displayName"/>
                                                </div>
                                            </xsl:for-each>
                                        </td>
                                    </xsl:if>
                                    <xsl:if test="$doCodeSystem">
                                        <td>
                                            <xsl:value-of select="$csoid"/>
                                        </td>
                                        <td>
                                            <xsl:call-template name="decorCodesystemOID2Codesystemname">
                                                <xsl:with-param name="oid" select="$csoid"/>
                                                <xsl:with-param name="sourceCodeSystems" select="ancestor::valueSet/sourceCodeSystem"/>
                                            </xsl:call-template>
                                        </td>
                                    </xsl:if>
                                    <xsl:if test="$doDescription">
                                        <td>
                                            <xsl:call-template name="doDescription">
                                                <xsl:with-param name="ns" select="desc"/>
                                            </xsl:call-template>
                                        </td>
                                    </xsl:if>
                                </tr>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <tr>
                                <td>...</td>
                                <td>
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'NoSuggestedValues'"/>
                                    </xsl:call-template>
                                </td>
                                <xsl:if test="$doCodeSystem">
                                    <td/>
                                    <td/>
                                </xsl:if>
                                <xsl:if test="$doDescription">
                                    <td/>
                                </xsl:if>
                            </tr>
                        </xsl:otherwise>
                    </xsl:choose>
                </tbody>
            </table>
        </div>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>show example pretty printed<br/>
            if parent is template then different td's are used compared to in-element examples
        </xd:desc>
    </xd:doc>
    <xsl:template match="example" mode="doDiv">
        <div xmlns="http://www.w3.org/1999/xhtml" class="row dcm-par">
            <div class="panel panel-success">
                <xsl:choose>
                    <xsl:when test="@type = 'valid'">
                        <xsl:attribute name="class">panel panel-success</xsl:attribute>
                    </xsl:when>
                    <xsl:when test="@type = 'error'">
                        <xsl:attribute name="class">panel panel-danger</xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="class">panel panel-info</xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                <div class="panel-heading dcm-panel-heading">
                    <xsl:choose>
                        <xsl:when test="@type = 'valid'">
                            <span class="glyphicon glyphicon-ok-circle" aria-hidden="true"/>
                            <xsl:text> </xsl:text>
                        </xsl:when>
                        <xsl:when test="@type = 'error'">
                            <span class="glyphicon glyphicon-remove-circle" aria-hidden="true" data-toggle="tooltip" data-placement="bottom">
                                <xsl:attribute name="title">
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'ExampleInvalid'"/>
                                    </xsl:call-template>
                                </xsl:attribute>
                            </span>
                            <xsl:text> </xsl:text>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:call-template name="getMessage">
                        <xsl:with-param name="key" select="'Example'"/>
                    </xsl:call-template>
                    <xsl:if test="@caption">
                        <xsl:text>: </xsl:text>
                        <xsl:value-of select="@caption"/>
                    </xsl:if>
                </div>
                <div class="panel-body dcm-panel-body">
                    <xsl:apply-templates mode="explrender"/>
                </div>
            </div>
        </div>
    </xsl:template>
    <xd:doc>
        <xd:desc>Show vocabulary</xd:desc>
        <xd:param name="vocabularies"/>
        <xd:param name="fieldName"/>
    </xd:doc>
    <xsl:template name="doVocabulary">
        <xsl:param name="vocabularies" as="element()*"/>
        <xsl:param name="fieldName" as="xs:string?"/>
        <div xmlns="http://www.w3.org/1999/xhtml" class="row dcm-par">
            <div class="panel panel-success">
                <div class="panel-heading dcm-panel-heading">
                    <span class="glyphicon glyphicon-warning-sign" aria-hidden="true" data-toggle="tooltip" data-placement="bottom">
                        <xsl:attribute name="title">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'constraintLabel'"/>
                            </xsl:call-template>
                        </xsl:attribute>
                    </span>
                    <xsl:text> </xsl:text>
                    <xsl:choose>
                        <xsl:when test="$vocabularies[self::text] and $vocabularies[self::vocabulary]">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'terminologyAssociationsAndFixedTexts'"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="count($vocabularies[self::text]) > 1">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'fixedTexts'"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="count($vocabularies[self::text]) = 1">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'fixedText'"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="count($vocabularies[self::vocabulary]) > 1">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'terminologyAssociations'"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="count($vocabularies[self::vocabulary]) = 1">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'terminologyAssociation'"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                </div>
                <div class="panel-body dcm-panel-body">
                    <xsl:for-each select="$vocabularies[self::text]">
                        <xsl:variable name="textValue" select="."/>
                        <div>
                            <xsl:if test="$vocabularies[self::vocabulary]">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'fixedText'"/>
                                </xsl:call-template>
                                <xsl:text>: </xsl:text>
                            </xsl:if>
                            <xsl:choose>
                                <xsl:when test="$fieldName = 'OBX-2'">
                                    <xsl:variable name="containedTemplate" select="$doV2DatatypeTemplates[@name = concat($textValue, '_datatype')]" as="element(template)"/>
                                    <a href="#{local:doHtmlAnchor($containedTemplate/@id, $containedTemplate/@effectiveDate)}" data-toggle="tooltip" data-placement="right" title="{$containedTemplate/@displayName}">
                                        <xsl:value-of select="$textValue"/>
                                    </a>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$textValue"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </div>
                    </xsl:for-each>
                    <xsl:for-each select="$vocabularies[self::vocabulary]">
                        <xsl:variable name="theCodeSystemName">
                            <xsl:choose>
                                <xsl:when test="@codeSystemName">
                                    <xsl:value-of select="concat('&quot;',@codeSystemName,'&quot;')"/>
                                </xsl:when>
                                <xsl:when test="@codeSystem = '2.16.840.1.113883.6.96'"><!-- SNOMED CT -->
                                    <xsl:value-of select="concat('&quot;','SNM','&quot;')"/>
                                </xsl:when>
                                <xsl:when test="@codeSystem = '2.16.840.1.113883.6.1'"><!-- LOINC -->
                                    <xsl:value-of select="concat('&quot;','LN','&quot;')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="concat('&quot;','?','&quot; (',@codeSystem,')')"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <div>
                            <xsl:if test="$vocabularies[self::text]">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'terminologyAssociation'"/>
                                </xsl:call-template>
                                <xsl:text>: </xsl:text>
                            </xsl:if>
                            <xsl:choose>
                                <xsl:when test="@valueSet">
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
                                    <!-- possible candidates for information in already expanded template format -->
                                    <xsl:variable name="expvsid" select="@vsid"/>
                                    <xsl:variable name="expvsdisplayName" select="@vsdisplayName"/>
                                    <xsl:variable name="expvsname" select="@vsname"/>
                                    <xsl:for-each select="@*">
                                        <xsl:choose>
                                            <xsl:when test="name(.) = 'valueSet'">
                                                <xsl:variable name="xvsid">
                                                    <xsl:choose>
                                                        <xsl:when test="string-length($expvsid) = 0">
                                                            <xsl:value-of select="$xvsref"/>
                                                        </xsl:when>
                                                        <xsl:when test="string-length($expvsid) &gt; 0">
                                                            <xsl:value-of select="$expvsid"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="($xvs/valueSet)[1]/@id"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:variable>
                                                <xsl:variable name="xvsname">
                                                    <xsl:choose>
                                                        <xsl:when test="string-length(($xvs/valueSet)[1]/@displayName) &gt; 0">
                                                            <xsl:value-of select="($xvs/valueSet)[1]/@displayName"/>
                                                        </xsl:when>
                                                        <xsl:when test="$expvsdisplayName">
                                                            <xsl:value-of select="$expvsdisplayName"/>
                                                        </xsl:when>
                                                        <xsl:when test="$expvsname">
                                                            <xsl:value-of select="$expvsname"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="($xvs/valueSet)[1]/@name"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:variable>
                                                <xsl:variable name="ahref">
                                                    <xsl:choose>
                                                        <xsl:when test="string-length($xvsid) = 0">
                                                            <xsl:value-of select="''"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="local:doHtmlName('VS', $xvsid, $xvsflex, '.html')"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:variable>
                                                <xsl:variable name="vs" select="."/>
                                                <xsl:call-template name="getMessage">
                                                    <xsl:with-param name="key" select="'valueSet'"/>
                                                </xsl:call-template>
                                                <xsl:text> </xsl:text>
                                                <!-- link to vocab html, if any -->
                                                <xsl:choose>
                                                    <xsl:when test="string-length($ahref) &gt; 0">
                                                        <a href="{$ahref}" onclick="target='_blank';">
                                                            <xsl:value-of select="$xvsid"/>
                                                        </a>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="$xvsid"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                                <xsl:text> </xsl:text>
                                                <xsl:if test="string-length($xvsname) &gt; 0">
                                                    <i>
                                                        <xsl:value-of select="$xvsname"/>
                                                        <xsl:text>&#160;</xsl:text>
                                                    </i>
                                                </xsl:if>
                                                <xsl:text>(</xsl:text>
                                                <xsl:choose>
                                                    <xsl:when test="matches($xvsflex, '^\d{4}')">
                                                        <xsl:call-template name="showDate">
                                                            <xsl:with-param name="date" select="$xvsflex"/>
                                                        </xsl:call-template>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:call-template name="getMessage">
                                                            <xsl:with-param name="key" select="'associationDYNAMIC'"/>
                                                        </xsl:call-template>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                                <xsl:text>)</xsl:text>
                                                <!-- show "value set not found" message if not found -->
                                                <xsl:if test="count($valueSetReferenceErrors/*/error[@id = $vs]) &gt; 0">
                                                    <table style="border: 0;">
                                                        <xsl:call-template name="doMessage">
                                                            <xsl:with-param name="msg">
                                                                <xsl:call-template name="getMessage">
                                                                    <xsl:with-param name="key" select="'CannotFindValueSet'"/>
                                                                    <xsl:with-param name="p1" select="$vs"/>
                                                                </xsl:call-template>
                                                            </xsl:with-param>
                                                        </xsl:call-template>
                                                    </table>
                                                </xsl:if>
                                            </xsl:when>
                                            <xsl:when test="name(.) = 'flexibility'">
                                                <!-- Skip. Is handled within other when leaves -->
                                            </xsl:when>
                                            <xsl:when test="name(.) = ('vsid', 'vsname', 'vsdisplayName', 'vseffectiveDate', 'vsstatusCode', 'linkedartefactmissing')">
                                                <!-- Relax and skip: as this may be included in already exapnded template representations -->
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:call-template name="logMessage">
                                                    <xsl:with-param name="level" select="$logERROR"/>
                                                    <xsl:with-param name="msg">
                                                        <xsl:text>+++ Found unknown vocabulary attribute </xsl:text>
                                                        <xsl:value-of select="name(.)"/>
                                                        <xsl:text>="</xsl:text>
                                                        <xsl:value-of select="."/>
                                                        <xsl:text>" template id "</xsl:text>
                                                        <xsl:value-of select="ancestor::template/@id"/>
                                                        <xsl:text>"</xsl:text>
                                                    </xsl:with-param>
                                                </xsl:call-template>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:for-each>
                                </xsl:when>
                                <!-- Assumption: @codeSystemName if present, holds the V2 mnemonic -->
                                <xsl:when test="@code and @displayName and (@codeSystem or @codeSystemName) and @codeSystemVersion">
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'codeCodeSystemNameVersionDisplayNameShallBeX-v2'"/>
                                        <xsl:with-param name="p1" select="@code"/>
                                        <xsl:with-param name="p2" select="@displayName"/>
                                        <xsl:with-param name="p3" select="$theCodeSystemName"/>
                                        <xsl:with-param name="p4" select="@codeSystemVersion"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:when test="@code and @displayName and (@codeSystem or @codeSystemName)">
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'codeCodeSystemNameDisplayNameShallBeX-v2'"/>
                                        <xsl:with-param name="p1" select="@code"/>
                                        <xsl:with-param name="p2" select="@displayName"/>
                                        <xsl:with-param name="p3" select="$theCodeSystemName"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:when test="@code and (@codeSystem or @codeSystemName) and @codeSystemVersion">
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'codeCodeSystemNameVersionShallBeX-v2'"/>
                                        <xsl:with-param name="p1" select="@code"/>
                                        <xsl:with-param name="p2" select="$theCodeSystemName"/>
                                        <xsl:with-param name="p3" select="@codeSystemVersion"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:when test="@code and (@codeSystem or @codeSystemName)">
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'codeCodeSystemNameVersionShallBeX-v2'"/>
                                        <xsl:with-param name="p1" select="@code"/>
                                        <xsl:with-param name="p2">
                                            <xsl:choose>
                                                <xsl:when test="@codeSystemName">
                                                    <xsl:value-of select="concat('&quot;',@codeSystemName,'&quot;')"/>
                                                </xsl:when>
                                                <xsl:when test="@codeSystem = '2.16.840.1.113883.6.96'"><!-- SNOMED CT -->
                                                    <xsl:value-of select="concat('&quot;','SNM','&quot;')"/>
                                                </xsl:when>
                                                <xsl:when test="@codeSystem = '2.16.840.1.113883.6.1'"><!-- LOINC -->
                                                    <xsl:value-of select="concat('&quot;','LN','&quot;')"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="concat('&quot;','?','&quot; (',@codeSystem,')')"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:with-param>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:when test="(@codeSystem or @codeSystemName) and @codeSystemVersion">
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'codeSystemNameVersionShallBeX-v2'"/>
                                        <xsl:with-param name="p1" select="$theCodeSystemName"/>
                                        <xsl:with-param name="p2" select="@codeSystemVersion"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:when test="(@codeSystem or @codeSystemName)">
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'codeCodeSystemNameVersionShallBeX-v2'"/>
                                        <xsl:with-param name="p1" select="$theCodeSystemName"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:when test="@code">
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="'codeorsoShallBeX-v2'"/>
                                        <xsl:with-param name="p1" select="'Identifier'"/>
                                        <xsl:with-param name="p2" select="@code"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="logMessage">
                                        <xsl:with-param name="level" select="$logERROR"/>
                                        <xsl:with-param name="msg">
                                            <xsl:text>+++ doVocabulary found unhandled contents: '</xsl:text>
                                            <xsl:value-of select="
                                                    string-join(for $att in @*
                                                    return
                                                        concat(name($att), '=&quot;', $att, '&quot;'), ' ')"/>
                                            <xsl:text>'</xsl:text>
                                        </xsl:with-param>
                                    </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>
                        </div>
                    </xsl:for-each>
                </div>
            </div>
        </div>
    </xsl:template>
    
    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="representingTemplate" mode="conformanceProfile">
        <xsl:variable name="model" select="../@model"/>
        <xsl:variable name="tmid" select="@ref"/>
        <xsl:variable name="tmed" select="@flexibility"/>
        <xsl:variable name="topLevelTemplate" as="element(template)?">
            <xsl:call-template name="getRulesetContent">
                <xsl:with-param name="ruleset" select="$tmid"/>
                <xsl:with-param name="flexibility" select="$tmed"/>
                <xsl:with-param name="sofar" select="()"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="tmdn" select="if ($topLevelTemplate[@displayName]) then $topLevelTemplate/@displayName else $topLevelTemplate/@name"/>
        
        <xsl:apply-templates select="$topLevelTemplate/element[@minimumMultiplicity[. > 0] | @conformance[not(. = 'NP')] | @isMandatory[. = 'true']]" mode="#current">
            <xsl:with-param name="model" select="$model"/>
        </xsl:apply-templates>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
        <xd:param name="level"/>
        <xd:param name="model"/>
    </xd:doc>
    <xsl:template match="element" mode="conformanceProfile">
        <xsl:param name="level" select="0"/>
        <xsl:param name="model"/>
        <xsl:variable name="indent" select="$level * 30"/>
        
        <xsl:variable name="theTemplate" as="element(template)?">
            <xsl:call-template name="getRulesetContent">
                <xsl:with-param name="ruleset" select="@contains"/>
                <xsl:with-param name="flexibility" select="@flexibility"/>
                <xsl:with-param name="sofar" select="()"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:variable name="segmentType">
            <xsl:choose>
                <xsl:when test="element">SegGroup</xsl:when>
                <xsl:otherwise>Segment</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="segmentName">
            <xsl:call-template name="doElementName">
                <xsl:with-param name="element" select="."/>
                <xsl:with-param name="model" select="$model"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="segmentLongName">
            <xsl:choose>
                <xsl:when test="$theTemplate">
                    <xsl:value-of select="$theTemplate/@displayName"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$segmentName"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="segmentDescription" as="item()*">
            <xsl:call-template name="doDescription">
                <xsl:with-param name="ns">
                    <xsl:choose>
                        <xsl:when test="desc">
                            <xsl:copy-of select="desc"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="$theTemplate/desc"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:element name="{$segmentType}">
            <xsl:attribute name="Name" select="$segmentName"/>
            <xsl:attribute name="LongName" select="$segmentLongName"/>
            <xsl:attribute name="Usage" select="local:getProfileUsage(.)"/>
            <xsl:attribute name="Min" select="local:getMinimumMultiplicity(.)"/>
            <xsl:attribute name="Max" select="local:getMaximumMultiplicity(.)"/>
            <xsl:if test="$segmentDescription">
                <Description><xsl:value-of select="data($segmentDescription)"/></Description>
            </xsl:if>
            <xsl:apply-templates select="element" mode="#current">
                <xsl:with-param name="level" select="$level + 1"/>
                <xsl:with-param name="model" select="$model"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="$theTemplate" mode="conformanceProfileFields">
                <xsl:with-param name="fieldlevel">Field</xsl:with-param>
            </xsl:apply-templates>
        </xsl:element>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
        <xd:param name="fieldlevel"/>
    </xd:doc>
    <xsl:template match="template" mode="conformanceProfileFields">
        <xsl:param name="fieldlevel" as="xs:string"/>
        <xsl:variable name="templateType" select="classification/@type"/>
        <xsl:variable name="tmid" select="@id"/>
        <xsl:variable name="tmed" select="@effectiveDate"/>
        <xsl:variable name="tmnm" select="substring-before(@name,'_')"/>
        <xsl:variable name="tmdn" select="if (@displayName) then @displayName else @name"/>
        <xsl:variable name="tmassocs" select="$allDECOR/rules/templateAssociation[@templateId = $tmid][@effectiveDate = $tmed]" as="element(templateAssociation)*"/>
        <xsl:variable name="sectionType">
            <xsl:choose>
                <xsl:when test="$templateType='messagelevel'">Message</xsl:when>
                <xsl:when test="$templateType='segmentlevel'">Segment</xsl:when>
                <xsl:when test="$templateType='datatypelevel'">Datatype</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="tableType">
            <xsl:choose>
                <xsl:when test="$templateType='messagelevel'"/>
                <xsl:when test="$templateType='segmentlevel'">HL7 Attribute Table</xsl:when>
                <xsl:when test="$templateType='datatypelevel'">HL7 Component Table</xsl:when>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:for-each select="element">
            <xsl:variable name="theTemplate" as="element(template)?">
                <xsl:call-template name="getRulesetContent">
                    <xsl:with-param name="ruleset" select="@contains"/>
                    <xsl:with-param name="flexibility" select="@flexibility"/>
                    <xsl:with-param name="sofar" select="()"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="fieldUsage" select="local:getProfileUsage(.)"/>
            
            <xsl:variable name="fieldName" select="attribute[@name='LongName']/@value" as="xs:string?"/>
            <xsl:if test="$fieldName">
                <xsl:element name="{$fieldlevel}">
                    <xsl:attribute name="Name" select="$fieldName"/>
                    <xsl:attribute name="Usage" select="$fieldUsage"/>
                    <xsl:choose>
                        <xsl:when test="$fieldlevel = 'Field'">
                            <xsl:attribute name="Min" select="local:getMinimumMultiplicity(.)"/>
                            <xsl:attribute name="Max" select="(@maximumMultiplicity, local:getMaximumMultiplicity(.))[1]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="count(text) = 1">
                                <xsl:attribute name="ConstantValue" select="text"/>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:attribute name="Datatype" select="@datatype"/>
                    <!--<xsl:attribute name="Length" select="..."/>-->
                    <xsl:if test="attribute[@name = 'Table']/@value">
                        <xsl:attribute name="Table" select="replace(attribute[@name = 'Table']/@value, '^HL7(\d{4,})$', '$1')"/>
                    </xsl:if>
                    <xsl:if test="attribute[@name = 'Item']">
                        <xsl:attribute name="ItemNo" select="local:getFormattedItemNumber(attribute[@name = 'Item']/@value)"/>
                    </xsl:if>
                    <xsl:if test="desc">
                        <xsl:variable name="nodes">
                            <xsl:call-template name="doDescription">
                                <xsl:with-param name="ns" select="desc"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <Description>
                            <xsl:value-of select="data($nodes)"/>
                        </Description>
                    </xsl:if>
                    <xsl:if test="constraint or $fieldUsage = ('CE', 'C')">
                        <xsl:variable name="nodes">
                            <xsl:call-template name="doDescription">
                                <xsl:with-param name="ns" select="constraint"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <Predicate>
                            <xsl:value-of select="data($nodes)"/>
                        </Predicate>
                    </xsl:if>
                    <xsl:if test="$theTemplate and not($fieldlevel = 'SubComponent')">
                        <xsl:apply-templates select="$theTemplate" mode="conformanceProfileFields">
                            <xsl:with-param name="fieldlevel">
                                <xsl:choose>
                                    <xsl:when test="$fieldlevel = 'Field'">Component</xsl:when>
                                    <xsl:when test="$fieldlevel = 'Component'">SubComponent</xsl:when>
                                </xsl:choose>
                            </xsl:with-param>
                        </xsl:apply-templates>
                    </xsl:if>
                </xsl:element>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="valueSet" mode="valueSet2table">
        <xsl:variable name="tableType" select="local:getTableType(.)"/>
        <xsl:variable name="tableName" select="local:getTableName(., $tableType)"/>
        <hl7table>
            <xsl:attribute name="id" select="if ($tableName castable as xs:integer) then $tableName else replace($tableName, '[^\d]', '')"/>
            <xsl:attribute name="name" select="if (string-length(@displayName) gt 0) then @displayName else @name"/>
            <!-- TODO: ask IHE/HL7 Germany. Where/how is this used? What if multiple live in a Value Set/Table? Raise error? -->
            <xsl:attribute name="codeSys">
                <xsl:choose>
                    <xsl:when test="matches(@id, '^2\.16\.840\.1\.113883\.3\.1937\.777\.10\.11\.\d+$')">
                        <xsl:value-of select="concat('2.16.840.1.113883.12.', tokenize(@id, '\.')[last()])"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@id"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="type" select="$tableType"/>
            <xsl:for-each select="conceptList/concept | conceptList/exception">
                <tableElement>
                    <xsl:attribute name="order" select="position()"/>
                    <xsl:attribute name="code" select="@code"/>
                    <xsl:attribute name="description" select="if (desc[@language = $defaultLanguage]) then desc[@language = $defaultLanguage] else desc[1]"/>
                    <xsl:attribute name="displayName" select="@displayName"/>
                    <!-- Fixed value: what's this? TODO: ask IHE/HL7 Germany -->
                    <xsl:attribute name="source" select="'ART-DECOR'"/>
                    <xsl:attribute name="usage" select="if (@type = ('A','D')) then 'Forbidden' else 'Optional'"/>
                    <xsl:attribute name="creator" select="''"/>
                    <xsl:attribute name="date" select="''"/>
                    <xsl:attribute name="instruction" select="''"/>
                </tableElement>
            </xsl:for-each>
        </hl7table>
    </xsl:template>
    
    <!-- ************ -->
    <!-- HELPER STUFF -->
    <!-- ************ -->
    <xd:doc>
        <xd:desc/>
        <xd:param name="dt"/>
    </xd:doc>
    <xsl:template name="decorDatatype2dcmDatatype">
        <xsl:param name="dt" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="$dt = '' or empty($dt)"/>
            <xsl:when test="$dt = 'complex'">ANY</xsl:when>
            <xsl:when test="$dt = 'boolean'">BL</xsl:when>
            <xsl:when test="$dt = 'code'">CD</xsl:when>
            <xsl:when test="$dt = 'ordinal'">CO</xsl:when>
            <xsl:when test="$dt = 'blob'">ED</xsl:when>
            <xsl:when test="$dt = 'identifier'">II</xsl:when>
            <xsl:when test="$dt = 'count'">INT</xsl:when>
            <xsl:when test="$dt = 'quantity'">PQ</xsl:when>
            <xsl:when test="$dt = 'string'">ST</xsl:when>
            <xsl:when test="$dt = 'datetime'">TS</xsl:when>
            <xsl:when test="$dt = 'code'">UCUM</xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="logMessage">
                    <xsl:with-param name="level" select="$logERROR"/>
                    <xsl:with-param name="msg">
                        <xsl:text>+++ Unsupported DECOR datatype </xsl:text>
                        <xsl:value-of select="$dt"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
        <xd:param name="oid"/>
        <xd:param name="sourceCodeSystems"/>
    </xd:doc>
    <xsl:template name="decorCodesystemOID2Codesystemname">
        <xsl:param name="oid"/>
        <xsl:param name="sourceCodeSystems" as="element()*"/>
        <xsl:choose>
            <xsl:when test="$oid = '' or empty($oid)"/>
            <xsl:when test="$sourceCodeSystems[@id = $oid]">
                <xsl:value-of select="$sourceCodeSystems[@id = $oid][1]/@identifierName"/>
            </xsl:when>
            <xsl:when test="$oid = '2.16.840.1.113883.6.254'">ICF</xsl:when>
            <xsl:when test="$oid = '2.16.840.1.113883.6.1'">LOINC</xsl:when>
            <xsl:when test="$oid = '2.16.840.1.113883.6.96'">SNOMED CT</xsl:when>
            <xsl:when test="$oid = '2.16.840.1.113883.5.1008'">NullFlavor</xsl:when>
            <xsl:when test="$allDECOR/ids/id[@root=$oid]">
                <xsl:value-of select="$allDECOR/ids/id[@root=$oid]/designation[@type='preferred'][1]/@displayName"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="logMessage">
                    <xsl:with-param name="level" select="$logERROR"/>
                    <xsl:with-param name="msg">
                        <xsl:text>+++ Unsupported DECOR Code System OID </xsl:text>
                        <xsl:value-of select="$oid"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="node()" name="doCopyIntoHtmlNamespace" mode="doCopyIntoHtmlNamespace">
        <xsl:choose>
            <xsl:when test="self::text() | self::comment() | self::processing-instruction()">
                <xsl:copy-of select="self::node()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="{local-name()}" namespace="http://www.w3.org/1999/xhtml">
                    <xsl:copy-of select="@*" copy-namespaces="no"/>
                    <xsl:for-each select="node()">
                        <xsl:call-template name="doCopyIntoHtmlNamespace"/>
                    </xsl:for-each>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:variable name="hl7v2OptionalityTable" as="element(table)">
        <table>
            <definition language="en-US">Whether the field is required, optional, or conditional in a segment. In the segment attribute tables this information is provided in the column labeled OPT.</definition>
            <concept code="R" displayName="Required"/>
            <concept code="O" displayName="Optional"/>
            <concept code="C" displayName="Conditional on the trigger event or on some other field(s). The field definitions following the segment attribute table should specify the algorithm that defines the conditionality for this field."/>
            <concept code="X" displayName="not used with this trigger event"/>
            <concept code="B" displayName="left in for backward compatibility with previous versions of HL7. The field definitions following the segment attribute table should denote the optionality of the field for prior versions."/>
            <concept code="W" displayName="withdrawn"/>
        </table>
    </xsl:variable>
    <xsl:variable name="hl7v2ConformanceUsageTable" as="element(table)">
        <table>
            <definition>Usage identifies the circumstances under which an element appears in a message. Possible values are:</definition>
            <concept code="R" displayName="Required (must always be present);"/>
            <concept code="RE" displayName="Required or Empty (must be present if available);"/>
            <concept code="O" displayName="Optional (no guidance on when the element should appear);"/>
            <concept code="C" displayName="Conditional (the element is required or allowed to be present when the condition specified in the Predicate element is true);"/>
            <concept code="CE" displayName="Conditional or Empty (the element is required or allowed to be present when the condition specified in the Predicate element is true and the information is available)"/>
            <concept code="X" displayName="Not supported (the element will not be sent)"/>
        </table>
    </xsl:variable>
    <xd:doc>
        <xd:desc/>
        <xd:param name="table"/>
        <xd:param name="code"/>
    </xd:doc>
    <xsl:function name="local:getDisplayNameForCode" as="xs:string?">
        <xsl:param name="table"/>
        <xsl:param name="code"/>
        <xsl:value-of select="$table//*[@code = $code]/@displayName"/>
    </xsl:function>
    <xd:doc>
        <xd:desc/>
        <xd:param name="code"/>
    </xd:doc>
    <xsl:function name="local:getFormattedItemNumber" as="xs:string?">
        <xsl:param name="code"/>
        <xsl:choose>
            <xsl:when test="string-length($code) = 0"/>
            <xsl:when test="matches($code, '^Z')">
                <xsl:value-of select="$code"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="substring(concat('0000',$code), string-length(concat('0000',$code)) - 4)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xd:doc>
        <xd:desc>Status of this profile, as assigned by the author.  There is no prescribed status scheme at this time.  Possible values might include: 'Draft', 'Active', 'Superceded', 'Withdrawn'</xd:desc>
        <xd:param name="code">Scenario statusCode (rejected pending new final draft deprecated cancelled)</xd:param>
    </xd:doc>
    <xsl:function name="local:getProfileStatusCode" as="xs:string?">
        <xsl:param name="code" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="$code = ('final')">Active</xsl:when>
            <xsl:when test="$code = ('pending')">Active</xsl:when>
            <xsl:when test="$code = ('cancelled')">Withdrawn</xsl:when>
            <xsl:when test="$code = ('rejected')">Withdrawn</xsl:when>
            <xsl:when test="$code = ('deprecated')">Draft</xsl:when>
            <xsl:when test="$code = ('new')">Draft</xsl:when>
            <xsl:when test="$code = ('draft')">Draft</xsl:when>
        </xsl:choose>
    </xsl:function>
    <xd:doc>
        <xd:desc></xd:desc>
        <xd:param name="element">Generally an element</xd:param>
    </xd:doc>
    <xsl:function name="local:getProfileUsage">
        <xsl:param name="element" as="element(element)"/>
        
        <xsl:choose>
            <xsl:when test="$element/@conformance = 'NP'">X</xsl:when>
            <xsl:when test="$element/@isMandatory = 'true'">R</xsl:when>
            <xsl:when test="$element/@conformance = 'R'">RE</xsl:when>
            <xsl:when test="$element/@conformance = 'C'">CE</xsl:when>
            <xsl:when test="$element/@minimumMultiplicity > 0">RE</xsl:when>
            <xsl:otherwise>O</xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xd:doc>
        <xd:desc></xd:desc>
        <xd:param name="valueSet"/>
    </xd:doc>
    <xsl:function name="local:getTableType" as="xs:string">
        <xsl:param name="valueSet" as="element(valueSet)"/>
        <xsl:choose>
            <xsl:when test="$valueSet/desc/div[@itemprop = 'HL7v2TableType'][. = 'HL7'] or $valueSet/desc[not(*)][contains(.,'itemprop=&quot;HL7v2TableType&quot;&gt;HL7&lt;')]">HL7</xsl:when>
            <xsl:when test="$valueSet/desc/div[@itemprop = 'HL7v2TableType'][. = 'User'] or $valueSet/desc[not(*)][contains(.,'itemprop=&quot;HL7v2TableType&quot;&gt;User&lt;')]">User</xsl:when>
            <xsl:otherwise>External</xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xd:doc>
        <xd:desc></xd:desc>
        <xd:param name="valueSet"/>
        <xd:param name="tableType"/>
    </xd:doc>
    <xsl:function name="local:getTableName" as="xs:string">
        <xsl:param name="valueSet" as="element(valueSet)"/>
        <xsl:param name="tableType" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="$tableType = 'HL7'"><xsl:value-of select="replace($valueSet/@name, 'HL7', '')"/></xsl:when>
            <xsl:when test="$tableType = 'User'"><xsl:value-of select="replace($valueSet/@name, 'HL7', '')"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="$valueSet/@id"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>