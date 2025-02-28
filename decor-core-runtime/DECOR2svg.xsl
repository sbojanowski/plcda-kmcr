<!-- 
    ART-DECOR® STANDARD COPYRIGHT AND LICENSE NOTE
    Copyright © ART-DECOR Expert Group and ART-DECOR Open Tools GmbH
    see https://docs.art-decor.org/copyright and https://docs.art-decor.org/licenses

    This file is part of the ART-DECOR® tools suite.    
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:svg="http://www.w3.org/2000/svg" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="#all" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Jan 13, 2012</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> ahenket</xd:p>
            <xd:p>
                <xd:ul>
                    <xd:li>Transaction group MUST have 0..* transactions</xd:li>
                    <xd:li>Transaction is of type 'initial', 'back', or 'stationary' <xd:ul>
                            <xd:li>Transaction MUST have 2..* actors for type 'initial'. At least 1 sending actor and 1 receiving actor.</xd:li>
                            <xd:li>Transaction MUST have 2..* actors for type 'back'. At least 1 sending actor and 1 receiving actor.</xd:li>
                            <xd:li>Transaction MUST have 1..1 actors for type 'stationary'</xd:li>
                        </xd:ul>
                    </xd:li>
                    <xd:li>Diagram will only be drawn, if there is 1..* transaction of type 'initial'.</xd:li>
                </xd:ul>
            </xd:p>
            <xd:p>Known issues (see FIXMEs): <xd:ul>
                    <xd:li>Transactions of type 'initial' with multiple sending actors will lead to drawing problems in functional SVG.</xd:li>
                </xd:ul>
            </xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:param name="doFunctionalView" select="true()"/>
    <xsl:param name="doTechnicalView" select="true()"/>
    <xsl:param name="transactionGroupId"/>
    <xsl:param name="transactionGroupEffectiveDate"/>
    <!--<xsl:param name="defaultLanguage" select="'nl-NL'"/>-->
    <xsl:param name="inline" select="false()"/>
    <xsl:param name="textFunctionalPerspective" select="'Functioneel perspectief'"/>
    <xsl:param name="textTechnicalPerspective" select="'Technisch perspectief'"/>
    <xsl:variable name="inactiveStatusCodes" select="tokenize('cancelled,rejected,deprecated',',')" as="xs:string+"/>
    <!-- Uncomment if you need to test outside of DECOR2schematron.xsl -->
    <!--<xsl:variable name="allDECOR" select="//decor | //decor-excerpt" as="element(decor)?"/>-->
    <xsl:variable name="transactionGroups" as="element(transaction)*">
        <xsl:choose>
            <xsl:when test="string-length($transactionGroupId) = 0">
                <xsl:for-each-group select="$allDECOR/scenarios/scenario/transaction[@type='group']" group-by="@id">
                    <xsl:for-each select="current-group()">
                        <xsl:copy-of select=".[@effectiveDate=string(max(current-group()/xs:dateTime(@effectiveDate)))]"/>
                    </xsl:for-each>
                </xsl:for-each-group>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="t" select="$allDECOR/scenarios/scenario/transaction[@type='group'][@id=$transactionGroupId]"/>
                <xsl:choose>
                    <xsl:when test="$transactionGroupEffectiveDate castable as xs:dateTime">
                        <xsl:copy-of select="$t[@effectiveDate=$transactionGroupEffectiveDate]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="$t[@effectiveDate=string(max($t/xs:dateTime(@effectiveDate)))]"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="arrowHeadPointingRight"> 0.2428,9.99706 c 3.8451,-1.75975 7.6902,-3.51949 11.5354,-5.27924 0,-0.002 0,-0.002 0,-0.002 0,0 0,0 -0,-0.002 -3.926,-1.57108 -7.852,-3.14216 -11.7781,-4.71324 z</xsl:variable>
    <xsl:variable name="arrowHeadPointingLeft"> 0.4062,-9.99174 c -3.3774,1.28641 -6.7547,2.57283 -10.132,3.85925 0,0 0,0 0,0 -0.4815,0.18338 -0.9629,0.36676 -1.4444,0.55014 0,0 0,0 0,0 -0.076,0.0291 -0.153,0.0583 -0.2295,0.0874 0,0 0,0 0,0 0,0 0,0 0,0 -0.015,0.0176 -0.029,0.0231 -0.043,0.0246 0,0 0,0 0,0 -0.01,5.5e-4 -0.01,5.8e-4 -0.015,4.1e-4 -0,-6e-5 -0,-6e-5 -0,-6e-5 0,0 0,0 0,9e-5 0.01,2.6e-4 0.01,6.3e-4 0.015,0.002 0,0 0,0 0,0 0.014,0.003 0.028,0.009 0.041,0.028 0,0 0,0 0,0 0,0 0,0 0,0 0.074,0.0353 0.1478,0.0705 0.2216,0.10576 0.465,0.22185 0.93,0.44371 1.395,0.66556 3.2617,1.55631 6.5235,3.11262 9.7853,4.66892 z</xsl:variable>
    <!--<xsl:template match="/">
        <xsl:variable name="theOutputDir" select="concat(string-join(tokenize(document-uri(.),'/')[position()!=last()],'/'),'/',$allDECOR/project/@prefix,'html-develop/')"/>
        <xsl:variable name="allSvg">
            <xsl:for-each select="//scenarios/scenario//transaction[@type='group']">
                <transaction id="{@id}">
                    <xsl:apply-templates select="self::node()" mode="transactionGroupToSVGFunctional"/>
                    <xsl:apply-templates select="self::node()" mode="transactionGroupToSVGTechnical"/>
                </transaction>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:for-each select="$allSvg/transaction">
            <xsl:if test="*">
                <xsl:result-document href="{$theOutputDir}tr-{string-join((@id,@effectiveDate),'-')}_functional.svg" method="xml" output-version="1.0" indent="yes">
                    <xsl:copy-of select="*[1]" copy-namespaces="no"/>
                </xsl:result-document>
            </xsl:if>
            <xsl:if test="*[2]">
                <xsl:result-document href="{$theOutputDir}tr-{string-join((@id,@effectiveDate),'-')}_technical.svg" method="xml" output-version="1.0" indent="yes">
                    <xsl:copy-of select="*[2]" copy-namespaces="no"/>
                </xsl:result-document>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>-->
    
    <xsl:template match="transaction[@type='group']" mode="transactionGroupToSVGTechnical">
        <xsl:variable name="transactionGroupName">
            <xsl:choose>
                <xsl:when test="name[@language=$defaultLanguage]">
                    <xsl:value-of select="name[@language=$defaultLanguage][1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="name[1]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="transactionGroupId" select="@id"/>
        <!-- denotes the number of actors that we need to draw boxes with lines for-->
        <xsl:variable name="countOfUniqueActors" select="count(distinct-values(transaction/actors/actor/@id))"/>
        <!-- denotes the number of initiated transactions -->
        <xsl:variable name="countOfInitialTransactions" select="count(distinct-values(transaction[@type='initial']/@model))"/>
        <!-- denotes the number of stationary transactions -->
        <xsl:variable name="countOfStationaryTransactions" select="count(distinct-values(transaction[@type='stationary']/@model))"/>
        <xsl:choose>
            <xsl:when test="($countOfInitialTransactions + $countOfStationaryTransactions) = 0">
                <xsl:text>+++ INFO: Not writing SVG diagram for transaction group '</xsl:text>
                <xsl:value-of select="$transactionGroupName"/>
                <xsl:text>' (id='</xsl:text>
                <xsl:value-of select="$transactionGroupId"/>
                <xsl:text>'), because there are no transactions of type='initial' or 'stationary' or attribute @model is not defined</xsl:text>
            </xsl:when>
            <xsl:when test="$countOfUniqueActors = 0">
                <xsl:text>+++ INFO: Not writing SVG diagram for transaction group '</xsl:text>
                <xsl:value-of select="$transactionGroupName"/>
                <xsl:text>' (id='</xsl:text>
                <xsl:value-of select="$transactionGroupId"/>
                <xsl:text>'), because there are no actors</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <!--xsl:value-of select="true()"/-->
                <xsl:variable name="svgMargin" select="21"/>
                <xsl:variable name="svgTitleHeight" select="10"/>
                <xsl:variable name="actorBoxMargin" select="30"/>
                <xsl:variable name="actorBoxHeight" select="50"/>
                <xsl:variable name="actorBoxMinWidth" select="80"/>
                <xsl:variable name="actorBoxXoffset" select="$svgMargin"/>
                <xsl:variable name="actorBoxYoffset" select="$svgMargin + $svgTitleHeight"/>
                <xsl:variable name="sequenceLineHeightBetweenActorBoxAndFirstBar" select="50"/>
                <xsl:variable name="sequenceLineHeightBetweenBars" select="30"/>
                <xsl:variable name="sequenceLineHeightAfterLastBar" select="10"/>
                <xsl:variable name="sequenceLineYoffset" select="$svgMargin + $svgTitleHeight + $actorBoxHeight"/>
                <xsl:variable name="sequenceBarWidth" select="10"/>
                <xsl:variable name="sequenceBarYoffset" select="$sequenceLineYoffset + $sequenceLineHeightBetweenActorBoxAndFirstBar"/>
                <xsl:variable name="sequenceBarMargin" select="20"/>
                <xsl:variable name="letterWidth" select="6"/>
                <xsl:variable name="letterHeight" select="10"/>
                <xsl:variable name="transactionModelMax" select="max(transaction/string-length(@model)) + 3"/>
                <xsl:variable name="pinkRectMargin" select="20"/>
                <xsl:variable name="pinkRectHeight" select="16"/>
                <xsl:variable name="pinkRectYoffset" select="$sequenceBarYoffset - $pinkRectHeight"/>
                <xsl:variable name="pinkRectName" select="concat('urn:hl7-org:v3/',($allDECOR/project)[1]/@prefix,@id)"/>
                <xsl:variable name="pinkRectWidth" select="($pinkRectMargin*2) + ((string-length($pinkRectName) + $transactionModelMax - 2)*$letterWidth)"/>
                <xsl:variable name="transactionNameMax">
                    <xsl:variable name="t" select="max(transaction/name/string-length()) + $transactionModelMax"/>
                    <xsl:choose>
                        <xsl:when test="$t &gt; (string-length($pinkRectName) + $transactionModelMax)">
                            <xsl:value-of select="$t"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="(string-length($pinkRectName) + $transactionModelMax)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="arrowMargin" select="30"/>
                <xsl:variable name="arrowLengthMin" select="350"/>
                <xsl:variable name="arrowYoffset" select="$sequenceBarYoffset + 20"/>
                <xsl:variable name="arrowHeadYoffset" select="$arrowYoffset - 5"/>
                <xsl:variable name="arrowTextYoffset" select="$arrowYoffset - 5"/>
                <xsl:variable name="arrowDistance" select="35"/>
                <xsl:variable name="arrowReturnYoffset" select="$arrowYoffset + $arrowDistance"/>
                <xsl:variable name="arrowReturnHeadYoffset" select="$arrowReturnYoffset + 5"/>
                <xsl:variable name="arrowReturnTextYoffset" select="$arrowReturnYoffset - 5"/>
                <xsl:variable name="clientName" select="'Client'"/>
                <xsl:variable name="serverName" select="'Server'"/>
                <xsl:variable name="sequenceBarHeight" select="75"/>
                <xsl:variable name="sequenceBarPlusLineHeight" select="$sequenceBarHeight + $sequenceLineHeightBetweenBars"/>
                <xsl:variable name="actorNameMax" select="string-length('Client')"/>
                <xsl:variable name="actorBoxWidth" select="if ( ($actorBoxMargin*2) + ($actorNameMax*$letterWidth) &gt; $actorBoxMinWidth) then ( ($actorBoxMargin*2) + ($actorNameMax*$letterWidth) ) else ($actorBoxMinWidth)"/>
                <xsl:variable name="sequenceLineHeight" select="$sequenceLineHeightBetweenActorBoxAndFirstBar + ($sequenceBarHeight*($countOfInitialTransactions + $countOfStationaryTransactions)) + ($sequenceLineHeightBetweenBars*($countOfInitialTransactions + $countOfStationaryTransactions - 1)) + $sequenceLineHeightAfterLastBar"/>
                <xsl:variable name="arrowLength" select="if ( ($arrowMargin*2) + ($transactionNameMax*$letterWidth) &gt; $arrowLengthMin) then ( ($arrowMargin*2) + ($transactionNameMax*$letterWidth) ) else ($arrowLengthMin)"/>
                <xsl:variable name="svgWidth" select="($svgMargin*2) + ($actorBoxWidth*2) + ( ($arrowLength - ($sequenceBarWidth div 2) - ($actorBoxWidth div 2))*(2 - 1))"/>
                <xsl:variable name="svgHeight" select="($svgMargin*2) + $svgTitleHeight + $actorBoxHeight + $sequenceLineHeight"/>
                <xsl:variable name="statusStyle" select="if (ancestor-or-self::*/@statusCode=$inactiveStatusCodes) then 'fill-opacity: 0.25; stroke-opacity: 0.25;' else 'fill-opacity: 1; stroke-opacity: 1;'"/>
                <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" id="{concat('svg_',$transactionGroupId)}" version="1.1" height="{$svgHeight}" width="{$svgWidth}" style="fill:white;stroke:black;stroke-width:0;{$statusStyle}">
                    <xsl:comment>Service Name</xsl:comment>
                    <xsl:text>
</xsl:text>
                    <text x="{($svgWidth div 2)}" y="{$svgMargin}" style="font-size:12px;font-weight:bold;text-align:start;line-height:125%;text-anchor:middle;fill:black;;stroke:none;font-family: Verdana, Arial, sans-serif;{$statusStyle}">
                        <desc>Title of scenario</desc>
                        <xsl:value-of select="$transactionGroupName"/>
                    </text>
                    <!-- Draw client and server actor boxes with sequence line -->
                    <g id="client_objects">
                        <xsl:comment> Client box (header) </xsl:comment>
                        <xsl:text>
</xsl:text>
                        <g id="client_box">
                            <rect x="{($svgWidth div 2) - ($arrowLength div 2) - ($sequenceBarWidth div 2) - ($actorBoxWidth div 2)}" y="{$actorBoxYoffset}" height="{$actorBoxHeight}" width="{$actorBoxWidth}" onmouseover="this.style.fill='LightSkyBlue';" onmouseout="this.style.fill='AliceBlue';" style="fill:AliceBlue;fill-rule:evenodd;stroke:black;stroke-width:0.2;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;{$statusStyle}"/>
                            <text x="{($svgWidth div 2) - ($arrowLength div 2) - ($sequenceBarWidth div 2)}" y="{$svgMargin + $svgTitleHeight + $actorBoxMargin}" style="font-size:{$letterHeight}px;font-weight:bold;text-align:middle;line-height:100%;text-anchor:middle;fill:black;stroke:none;font-family: Verdana, Arial, sans-serif;{$statusStyle}">
                                <xsl:value-of select="$clientName"/>
                            </text>
                        </g>
                        <xsl:comment> Client Box Sequence Line </xsl:comment>
                        <xsl:text>
</xsl:text>
                        <path style="fill:none;stroke:black;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;{$statusStyle}" d="m {($svgWidth div 2) - ($arrowLength div 2) - ($sequenceBarWidth div 2)}, {$sequenceLineYoffset} v {$sequenceLineHeight}"/>
                    </g>
                    <g id="server_objects">
                        <xsl:comment> Server box (header) </xsl:comment>
                        <xsl:text>
</xsl:text>
                        <g id="server_box">
                            <rect x="{($svgWidth div 2) + ($arrowLength div 2) + ($sequenceBarWidth div 2) - ($actorBoxWidth div 2)}" y="{$actorBoxYoffset}" height="{$actorBoxHeight}" width="{$actorBoxWidth}" onmouseover="this.style.fill='LightSkyBlue';" onmouseout="this.style.fill='AliceBlue';" style="fill:AliceBlue;fill-rule:evenodd;stroke:black;stroke-width:0.2;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;{$statusStyle}"/>
                            <text x="{($svgWidth div 2) + ($arrowLength div 2) + ($sequenceBarWidth div 2)}" y="{$svgMargin + $svgTitleHeight + $actorBoxMargin}" style="font-size:{$letterHeight}px;font-weight:bold;text-align:middle;line-height:100%;text-anchor:middle;fill:black;stroke:none;font-family: Verdana, Arial, sans-serif;{$statusStyle}">
                                <xsl:value-of select="$serverName"/>
                            </text>
                        </g>
                        <xsl:comment> Server Box Sequence Line </xsl:comment>
                        <xsl:text>
</xsl:text>
                        <path style="fill:none;stroke:black;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;{$statusStyle}" d="m {($svgWidth div 2) + ($arrowLength div 2) + ($sequenceBarWidth div 2)} , {$sequenceLineYoffset} v {$sequenceLineHeight}"/>
                    </g>

                    <!-- Build bars, lines with arrows, and text per initial transaction -->
                    <xsl:for-each select="transaction[@type='initial']">
                        <xsl:variable name="currentTransactionModel" select="@model"/>
                        <xsl:if test="not(preceding-sibling::transaction[@model=$currentTransactionModel])">
                            <g id="{generate-id(.)}">
                                <xsl:comment> Client bar </xsl:comment>
                                <xsl:text>
</xsl:text>
                                <rect x="{($svgWidth div 2) - ($arrowLength div 2) - $sequenceBarWidth}" y="{$sequenceLineYoffset + $sequenceLineHeightBetweenActorBoxAndFirstBar + (position()-1)*($sequenceBarHeight + $sequenceLineHeightBetweenBars)}" height="{$sequenceBarHeight}" width="{$sequenceBarWidth}" style="fill:AliceBlue;stroke:black;stroke-width:0.5;stroke-miterlimit:4;stroke-dasharray:none;{$statusStyle}"/>
                                <xsl:comment> Server bar </xsl:comment>
                                <xsl:text>
</xsl:text>
                                <rect x="{($svgWidth div 2) + ($arrowLength div 2)}" y="{$sequenceLineYoffset + $sequenceLineHeightBetweenActorBoxAndFirstBar + (position()-1)*($sequenceBarHeight + $sequenceLineHeightBetweenBars)}" height="{$sequenceBarHeight}" width="{$sequenceBarWidth}" style="fill:AliceBlue;fill-rule:evenodd;stroke:black;stroke-width:0.2;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;{$statusStyle}"/>
                                <xsl:comment> SOAP Action in pink background-color </xsl:comment>
                                <xsl:text>
</xsl:text>
                                <g>
                                    <rect x="{($svgWidth div 2) - ($pinkRectWidth div 2)}" y="{$pinkRectYoffset + ((position()-1) * $sequenceBarPlusLineHeight)}" height="{$pinkRectHeight}" width="{$pinkRectWidth}" style="fill:#ffaaaa;{$statusStyle}"/>
                                    <text x="{($svgWidth div 2) }" y="{$pinkRectYoffset + ((position()-1) * $sequenceBarPlusLineHeight) + ($pinkRectHeight div 2) + 3}" style="font-size:{$letterHeight}px;text-align:center;text-anchor:middle;line-height:125%;fill:black;stroke:none;font-family: Verdana, Arial, sans-serif;{$statusStyle}">
                                        <xsl:value-of select="concat($pinkRectName,'_',@model)"/>
                                    </text>
                                </g>
                                <xsl:comment> Arrow, with head, and label </xsl:comment>
                                <xsl:text>
</xsl:text>
                                <g id="{concat('clientToServer_',generate-id(.))}">
                                    <g id="{concat('initiatingTransaction_',generate-id(.))}">
                                        <xsl:comment> Arrow text client to server </xsl:comment>
                                        <xsl:text>
</xsl:text>
                                        <text x="{($svgWidth div 2)}" y="{$arrowTextYoffset + ((position()-1) * $sequenceBarPlusLineHeight)}" style="font-size:{$letterHeight}px;font-variant:normal;font-weight:bold;font-stretch:normal;text-align:center;line-height:125%;writing-mode:lr-tb;text-anchor:middle;fill:black;stroke:none;font-family: Verdana, Arial, sans-serif;{$statusStyle}">
                                            <xsl:choose>
                                                <xsl:when test="name[@language=$defaultLanguage]">
                                                    <xsl:value-of select="name[@language=$defaultLanguage][1]"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="name[1]"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            <xsl:text> (</xsl:text>
                                            <xsl:value-of select="$currentTransactionModel"/>
                                            <xsl:text>)</xsl:text>
                                        </text>
                                        <xsl:comment> Arrow line client to server </xsl:comment>
                                        <xsl:text>
</xsl:text>
                                        <path d="{concat('m ',($svgWidth div 2) - ($arrowLength div 2), ',', $arrowYoffset + ((position()-1) * $sequenceBarPlusLineHeight), ' h ', $arrowLength)}" style="fill:none;stroke:black;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;marker-end:none"/>
                                        <xsl:comment> Arrow head client to server </xsl:comment>
                                        <xsl:text>
</xsl:text>
                                        <path d="{concat('m ', ($svgWidth div 2) + ($arrowLength div 2) - 10, ',', $arrowHeadYoffset + ((position()-1) * $sequenceBarPlusLineHeight), ' 0.2428,9.99706 c 3.8451,-1.75975 7.6902,-3.51949 11.5354,-5.27924 0,-0.002 0,-0.002 0,-0.002 0,0 0,0 -0,-0.002 -3.926,-1.57108 -7.852,-3.14216 -11.7781,-4.71324 z')}" style="fill:black;fill-rule:evenodd;stroke:none"/>
                                    </g>
                                    <g id="{concat('respondingTransaction_',generate-id(.))}">
                                        <xsl:comment> Arrow text server to client </xsl:comment>
                                        <xsl:text>
</xsl:text>
                                        <text x="{($svgWidth div 2)}" y="{$arrowReturnTextYoffset + ((position()-1) * $sequenceBarPlusLineHeight)}" style="font-size:{$letterHeight}px;font-variant:normal;font-weight:bold;font-stretch:normal;text-align:center;line-height:125%;writing-mode:lr-tb;text-anchor:middle;fill:black;stroke:none;font-family: Verdana, Arial, sans-serif;{$statusStyle}">
                                            <xsl:variable name="currentTransactionId" select="@id"/>
                                            <xsl:variable name="positionOfInitialInGroup" select="count(../transaction[@id=$currentTransactionId]/preceding-sibling::transaction)+1"/>
                                            <xsl:variable name="positionOfResponseInGroup" select="count((../transaction[count(preceding-sibling::transaction)+1 &gt; $positionOfInitialInGroup][@type='back'])[1]/preceding-sibling::transaction)+1"/>
                                            <xsl:choose>
                                                <xsl:when test="../transaction[$positionOfResponseInGroup+1]/@type='back'">
                                                    <xsl:value-of select="concat(@model,'Response')"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:choose>
                                                        <xsl:when test="../transaction[$positionOfResponseInGroup]/name[@language=$defaultLanguage]">
                                                            <xsl:value-of select="../transaction[$positionOfResponseInGroup]/name[@language=$defaultLanguage][1]"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="../transaction[$positionOfResponseInGroup]/name[1]"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                    <xsl:if test="../transaction[$positionOfResponseInGroup]/@model">
                                                        <xsl:text> (</xsl:text>
                                                        <xsl:value-of select="../transaction[$positionOfResponseInGroup]/@model"/>
                                                        <xsl:text>)</xsl:text>
                                                    </xsl:if>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </text>
                                        <xsl:comment> Arrow line server to client </xsl:comment>
                                        <xsl:text>
</xsl:text>
                                        <path d="{concat('m ',($svgWidth div 2) - ($arrowLength div 2), ', ' , $arrowReturnYoffset + ((position()-1) * $sequenceBarPlusLineHeight), ' h ', $arrowLength)}" style="fill:none;stroke:black;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;marker-end:none;{$statusStyle}"/>
                                        <xsl:comment> Arrow head server to client </xsl:comment>
                                        <xsl:text>
</xsl:text>
                                        <path d="{concat('m ',($svgWidth div 2) - ($arrowLength div 2) + 10,',', $arrowReturnHeadYoffset + ((position()-1) * $sequenceBarPlusLineHeight), ' 0.4062,-9.99174 c -3.3774,1.28641 -6.7547,2.57283 -10.132,3.85925 0,0 0,0 0,0 -0.4815,0.18338 -0.9629,0.36676 -1.4444,0.55014 0,0 0,0 0,0 -0.076,0.0291 -0.153,0.0583 -0.2295,0.0874 0,0 0,0 0,0 0,0 0,0 0,0 -0.015,0.0176 -0.029,0.0231 -0.043,0.0246 0,0 0,0 0,0 -0.01,5.5e-4 -0.01,5.8e-4 -0.015,4.1e-4 -0,-6e-5 -0,-6e-5 -0,-6e-5 0,0 0,0 0,9e-5 0.01,2.6e-4 0.01,6.3e-4 0.015,0.002 0,0 0,0 0,0 0.014,0.003 0.028,0.009 0.041,0.028 0,0 0,0 0,0 0,0 0,0 0,0 0.074,0.0353 0.1478,0.0705 0.2216,0.10576 0.465,0.22185 0.93,0.44371 1.395,0.66556 3.2617,1.55631 6.5235,3.11262 9.7853,4.66892 z')}" style="fill:black;fill-rule:evenodd;stroke:none"/>
                                    </g>
                                </g>
                            </g>
                        </xsl:if>
                    </xsl:for-each>
                <!-- Build bars, lines with arrows, and text per stationary transaction -->
                    <xsl:for-each select="transaction[@type='stationary']">
                        <xsl:variable name="currentTransactionModel" select="@model"/>
                        <xsl:if test="not(preceding-sibling::transaction[@model=$currentTransactionModel])">
                            <g id="{generate-id(.)}">
                                <xsl:comment> Client bar </xsl:comment>
                                <xsl:text>
</xsl:text>
                                <rect x="{($svgWidth div 2) - ($arrowLength div 2) - $sequenceBarWidth}" y="{$sequenceLineYoffset + $sequenceLineHeightBetweenActorBoxAndFirstBar + (position()-1)*($sequenceBarHeight + $sequenceLineHeightBetweenBars)}" height="{$sequenceBarHeight}" width="{$sequenceBarWidth}" style="fill:AliceBlue;stroke:black;stroke-width:0.5;stroke-miterlimit:4;stroke-dasharray:none;{$statusStyle}"/>
                                <xsl:comment> Server bar </xsl:comment>
                                <xsl:text>
</xsl:text>
                                <rect x="{($svgWidth div 2) + ($arrowLength div 2)}" y="{$sequenceLineYoffset + $sequenceLineHeightBetweenActorBoxAndFirstBar + (position()-1)*($sequenceBarHeight + $sequenceLineHeightBetweenBars)}" height="{$sequenceBarHeight}" width="{$sequenceBarWidth}" style="fill:AliceBlue;fill-rule:evenodd;stroke:black;stroke-width:0.2;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;{$statusStyle}"/>
                                <xsl:comment> SOAP Action in pink background-color </xsl:comment>
                                <xsl:text>
</xsl:text>
                                <g>
                                    <rect x="{($svgWidth div 2) - ($pinkRectWidth div 2)}" y="{$pinkRectYoffset + ((position()-1) * $sequenceBarPlusLineHeight)}" height="{$pinkRectHeight}" width="{$pinkRectWidth}" style="fill:#ffaaaa;{$statusStyle}"/>
                                    <text x="{($svgWidth div 2) }" y="{$pinkRectYoffset + ((position()-1) * $sequenceBarPlusLineHeight) + ($pinkRectHeight div 2) + 3}" style="font-size:{$letterHeight}px;text-align:center;text-anchor:middle;line-height:125%;fill:black;stroke:none;font-family: Verdana, Arial, sans-serif;{$statusStyle}">
                                        <xsl:value-of select="concat($pinkRectName,'_',@model)"/>
                                    </text>
                                </g>
                                <xsl:comment> Arrow, with head, and label </xsl:comment>
                                <xsl:text>
</xsl:text>
                                <g id="{concat('clientToServer_',generate-id(.))}">
                                    <g id="{concat('initiatingTransaction_',generate-id(.))}">
                                        <xsl:comment> Arrow text client to server </xsl:comment>
                                        <xsl:text>
</xsl:text>
                                        <text x="{($svgWidth div 2)}" y="{$arrowTextYoffset + ((position()-1) * $sequenceBarPlusLineHeight)}" style="font-size:{$letterHeight}px;font-variant:normal;font-weight:bold;font-stretch:normal;text-align:center;line-height:125%;writing-mode:lr-tb;text-anchor:middle;fill:black;stroke:none;font-family: Verdana, Arial, sans-serif;{$statusStyle}">
                                            <xsl:choose>
                                                <xsl:when test="name[@language=$defaultLanguage]">
                                                    <xsl:value-of select="name[@language=$defaultLanguage][1]"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="name[1]"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            <xsl:text> (</xsl:text>
                                            <xsl:value-of select="$currentTransactionModel"/>
                                            <xsl:text>)</xsl:text>
                                        </text>
                                        <xsl:comment> Arrow line client to server </xsl:comment>
                                        <xsl:text>
</xsl:text>
                                        <path d="{concat('m ',($svgWidth div 2) - ($arrowLength div 2), ',', $arrowYoffset + ((position()-1) * $sequenceBarPlusLineHeight), ' h ', $arrowLength)}" style="fill:none;stroke:black;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;marker-end:none"/>
                                        <xsl:comment> Arrow head client to server </xsl:comment>
                                        <xsl:text>
</xsl:text>
                                        <path d="{concat('m ', ($svgWidth div 2) + ($arrowLength div 2) - 10, ',', $arrowHeadYoffset + ((position()-1) * $sequenceBarPlusLineHeight), ' 0.2428,9.99706 c 3.8451,-1.75975 7.6902,-3.51949 11.5354,-5.27924 0,-0.002 0,-0.002 0,-0.002 0,0 0,0 -0,-0.002 -3.926,-1.57108 -7.852,-3.14216 -11.7781,-4.71324 z')}" style="fill:black;fill-rule:evenodd;stroke:none"/>
                                    </g>
                                    <g id="{concat('respondingTransaction_',generate-id(.))}">
                                        <xsl:comment> Arrow text server to client </xsl:comment>
                                        <xsl:text>
</xsl:text>
                                        <text x="{($svgWidth div 2)}" y="{$arrowReturnTextYoffset + ((position()-1) * $sequenceBarPlusLineHeight)}" style="font-size:{$letterHeight}px;font-variant:normal;font-weight:bold;font-stretch:normal;text-align:center;line-height:125%;writing-mode:lr-tb;text-anchor:middle;fill:black;stroke:none;font-family: Verdana, Arial, sans-serif;{$statusStyle}">
                                            <xsl:variable name="currentTransactionId" select="@id"/>
                                            <xsl:variable name="positionOfInitialInGroup" select="count(../transaction[@id=$currentTransactionId]/preceding-sibling::transaction)+1"/>
                                            <xsl:variable name="positionOfResponseInGroup" select="count((../transaction[count(preceding-sibling::transaction)+1 &gt; $positionOfInitialInGroup][@type='back'])[1]/preceding-sibling::transaction)+1"/>
                                            <xsl:choose>
                                                <xsl:when test="../transaction[$positionOfResponseInGroup+1]/@type='back'">
                                                    <xsl:value-of select="concat(@model,'Response')"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:choose>
                                                        <xsl:when test="../transaction[$positionOfResponseInGroup]/name[@language=$defaultLanguage]">
                                                            <xsl:value-of select="../transaction[$positionOfResponseInGroup]/name[@language=$defaultLanguage][1]"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="../transaction[$positionOfResponseInGroup]/name[1]"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                    <xsl:if test="../transaction[$positionOfResponseInGroup]/@model">
                                                        <xsl:text> (</xsl:text>
                                                        <xsl:value-of select="../transaction[$positionOfResponseInGroup]/@model"/>
                                                        <xsl:text>)</xsl:text>
                                                    </xsl:if>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </text>
                                        <xsl:comment> Arrow line server to client </xsl:comment>
                                        <xsl:text>
</xsl:text>
                                        <path d="{concat('m ',($svgWidth div 2) - ($arrowLength div 2), ', ' , $arrowReturnYoffset + ((position()-1) * $sequenceBarPlusLineHeight), ' h ', $arrowLength)}" style="fill:none;stroke:black;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;marker-end:none;{$statusStyle}"/>
                                        <xsl:comment> Arrow head server to client </xsl:comment>
                                        <xsl:text>
</xsl:text>
                                        <path d="{concat('m ',($svgWidth div 2) - ($arrowLength div 2) + 10,',', $arrowReturnHeadYoffset + ((position()-1) * $sequenceBarPlusLineHeight), ' 0.4062,-9.99174 c -3.3774,1.28641 -6.7547,2.57283 -10.132,3.85925 0,0 0,0 0,0 -0.4815,0.18338 -0.9629,0.36676 -1.4444,0.55014 0,0 0,0 0,0 -0.076,0.0291 -0.153,0.0583 -0.2295,0.0874 0,0 0,0 0,0 0,0 0,0 0,0 -0.015,0.0176 -0.029,0.0231 -0.043,0.0246 0,0 0,0 0,0 -0.01,5.5e-4 -0.01,5.8e-4 -0.015,4.1e-4 -0,-6e-5 -0,-6e-5 -0,-6e-5 0,0 0,0 0,9e-5 0.01,2.6e-4 0.01,6.3e-4 0.015,0.002 0,0 0,0 0,0 0.014,0.003 0.028,0.009 0.041,0.028 0,0 0,0 0,0 0,0 0,0 0,0 0.074,0.0353 0.1478,0.0705 0.2216,0.10576 0.465,0.22185 0.93,0.44371 1.395,0.66556 3.2617,1.55631 6.5235,3.11262 9.7853,4.66892 z')}" style="fill:black;fill-rule:evenodd;stroke:none"/>
                                    </g>
                                </g>
                            </g>
                        </xsl:if>
                    </xsl:for-each>
                </svg>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="transaction[@type='group']" mode="transactionGroupToSVGFunctional">
        <xsl:variable name="transactionGroupName">
            <xsl:choose>
                <xsl:when test="name[@language=$defaultLanguage]">
                    <xsl:value-of select="name[@language=$defaultLanguage][1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="name[1]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="transactionGroupId" select="@id"/>
        <xsl:variable name="statusStyle" select="if (ancestor-or-self::*/@statusCode=$inactiveStatusCodes) then 'fill-opacity: 0.25; stroke-opacity: 0.25;' else 'fill-opacity: 1; stroke-opacity: 1;'"/>
        <!-- denotes the number of actors that we need to draw boxes with lines for-->
        <xsl:variable name="countOfUniqueActors" select="count(distinct-values(transaction/actors/actor/@id))"/>
        <!-- denotes the number of initiated transactions -->
        <xsl:variable name="countOfInitialTransactions" select="count(distinct-values(transaction[@type='initial']))"/>
        <!-- denotes the number of stationary transactions -->
        <xsl:variable name="countOfStationaryTransactions" select="count(distinct-values(transaction[@type='stationary']))"/>
        <xsl:choose>
            <xsl:when test="($countOfInitialTransactions + $countOfStationaryTransactions) = 0">
                <xsl:text>*** INFO: Not writing SVG diagram for transaction group '</xsl:text>
                <xsl:value-of select="$transactionGroupName"/>
                <xsl:text>' (id='</xsl:text>
                <xsl:value-of select="$transactionGroupId"/>
                <xsl:text>'), because there are no transactions of type='initial' or type='stationary'</xsl:text>
            </xsl:when>
            <xsl:when test="$countOfUniqueActors = 0">
                <xsl:text>*** INFO: Not writing SVG diagram for transaction group '</xsl:text>
                <xsl:value-of select="$transactionGroupName"/>
                <xsl:text>' (id='</xsl:text>
                <xsl:value-of select="$transactionGroupId"/>
                <xsl:text>'), because there are no actors</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <!--xsl:value-of select="true()"/-->
                <xsl:variable name="svgMargin" select="21"/>
                <xsl:variable name="svgTitleHeight" select="10"/>
                <xsl:variable name="actorBoxMargin" select="30"/>
                <xsl:variable name="actorBoxHeight" select="50"/>
                <xsl:variable name="actorBoxMinWidth" select="80"/>
                <xsl:variable name="actorBoxXoffset" select="$svgMargin"/>
                <xsl:variable name="actorBoxYoffset" select="$svgMargin + $svgTitleHeight"/>
                <xsl:variable name="sequenceLineHeightBetweenActorBoxAndFirstBar" select="50"/>
                <xsl:variable name="sequenceLineHeightBetweenBars" select="30"/>
                <xsl:variable name="sequenceLineHeightAfterLastBar" select="10"/>
                <xsl:variable name="sequenceLineYoffset" select="$svgMargin + $svgTitleHeight + $actorBoxHeight"/>
                <xsl:variable name="sequenceBarWidth" select="10"/>
                <xsl:variable name="sequenceBarYoffset" select="$sequenceLineYoffset + $sequenceLineHeightBetweenActorBoxAndFirstBar"/>
                <xsl:variable name="sequenceBarMargin" select="20"/>
                <xsl:variable name="letterWidth" select="6"/>
                <xsl:variable name="letterHeight" select="10"/>
                <xsl:variable name="pinkRectMargin" select="20"/>
                <xsl:variable name="pinkRectHeight" select="16"/>
                <xsl:variable name="pinkRectYoffset" select="$sequenceBarYoffset - $pinkRectHeight"/>
                <xsl:variable name="arrowMargin" select="30"/>
                <xsl:variable name="arrowLengthMin" select="350"/>
                <xsl:variable name="arrowYoffset" select="$sequenceBarYoffset + 20"/>
                <xsl:variable name="arrowHeadYoffset" select="$arrowYoffset - 5"/>
                <xsl:variable name="arrowTextYoffset" select="$arrowYoffset - 5"/>
                <xsl:variable name="arrowDistance" select="35"/>
                <xsl:variable name="arrowReturnYoffset" select="$arrowYoffset + $arrowDistance"/>
                <xsl:variable name="arrowReturnHeadYoffset" select="$arrowReturnYoffset + 5"/>
                <xsl:variable name="arrowReturnTextYoffset" select="$arrowReturnYoffset - 5"/>
                <!-- arrow stuff first for width count -->
                <xsl:variable name="transactionNames" as="element()*">
                    <xsl:for-each select="transaction">
                        <x>
                            <xsl:choose>
                                <xsl:when test="name[@language=$defaultLanguage]">
                                    <xsl:value-of select="name[@language=$defaultLanguage][1]"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="name[1]"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:if test="@model">
                                <xsl:text> (</xsl:text>
                                <xsl:value-of select="@model"/>
                                <xsl:text>)</xsl:text>
                            </xsl:if>
                        </x>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:variable name="transactionNameMax" select="max($transactionNames/string-length())"/>
                <xsl:variable name="arrowLength" select="if ( ($arrowMargin*2) + ($transactionNameMax*$letterWidth) &gt; $arrowLengthMin) then ( ($arrowMargin*2) + ($transactionNameMax*$letterWidth) - 10 ) else ($arrowLengthMin - 10)"/>

                <!-- actor variables -->
                <xsl:variable name="actorIds" select=".//actor/@id"/>
                <xsl:variable name="actorNameMax" select="max($allDECOR/scenarios/actors/actor[@id=$actorIds]/name[@language=$defaultLanguage or position()=1]/text()/string-length())"/>
                <xsl:variable name="actorBoxWidth" select="if ( ($actorBoxMargin*2) + ($actorNameMax*$letterWidth) &gt; $actorBoxMinWidth) then ( ($actorBoxMargin*2) + ($actorNameMax*$letterWidth) ) else ($actorBoxMinWidth)"/>
                <!-- Distance between top left corners of two actors -->
                <xsl:variable name="actorBoxXdistance" select="$arrowLength + $sequenceBarWidth"/>
                <!-- need to know later on where a certain actor was drawn, so place in variable first for reuse -->
                <xsl:variable name="actorsUnique" as="element()*">
                    <!-- Get all actors for this transaction group into a variable -->
                    <xsl:variable name="actorsUniqueTemp" as="element()*">
                        <xsl:for-each-group select="transaction/actors/actor" group-by="@id">
                            <xsl:variable name="actorId" select="current-grouping-key()"/>
                            <xsl:variable name="actorName">
                                <xsl:choose>
                                    <xsl:when test="$allDECOR/scenarios/actors/actor[@id = $actorId]/name[@language = $defaultLanguage]">
                                        <xsl:value-of select="$allDECOR/scenarios/actors/actor[@id = $actorId]/name[@language = $defaultLanguage][1]"/>
                                        </xsl:when>
                                <xsl:otherwise>
                                        <xsl:value-of select="$allDECOR/scenarios/actors/actor[@id = $actorId]/name[1]"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                                </xsl:variable>
                        <xsl:variable name="actorRole">
                                <xsl:choose>
                                    <xsl:when test="ancestor::transaction[@type = 'group']/transaction[@type = 'initial']//actor[@id = $actorId][@role = 'sender']">sender</xsl:when>
                                    <xsl:otherwise>receiver</xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <actor id="{$actorId}" name="{$actorName}">
                                <xsl:for-each-group select="ancestor::transaction[@type = 'group']/transaction[@type = 'initial']//actor[@id = $actorId]" group-by="@role">
                                    <xsl:attribute name="{current-grouping-key()}"/>
                                </xsl:for-each-group>
                            </actor>
                        </xsl:for-each-group>
                    </xsl:variable>
                    <!-- Sort by descending role. Sender first, then receiver -->
                    <xsl:for-each select="$actorsUniqueTemp">
                        <xsl:sort select="@role" order="descending"/>
                    <xsl:copy-of select="self::node()"/>
                    </xsl:for-each>
                    </xsl:variable>
                <xsl:variable name="actorBoxes" as="element(wrap)">
                    <wrap>
                        <xsl:for-each select="$actorsUnique">
                            <xsl:variable name="id" select="@id"/>
                            <xsl:variable name="statusStyle">
<xsl:choose>
                                    <xsl:when test="$transactionGroups//transaction[not(@statusCode = $inactiveStatusCodes)][actors/actor/@id = $id]">fill-opacity: 1; stroke-opacity: 1;</xsl:when>
                                    <xsl:otherwise>fill-opacity: 0.25; stroke-opacity: 0.25;</xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <g xmlns="http://www.w3.org/2000/svg" id="actor_{@id}">
                                <rect x="{$actorBoxXoffset + ((position()-1) * $actorBoxXdistance)}" y="{$actorBoxYoffset}" height="{$actorBoxHeight}" width="{$actorBoxWidth}" class="actorBox" style="{$statusStyle}"/>
                                <text x="{$actorBoxXoffset + ($actorBoxWidth div 2) + ((position()-1) * $actorBoxXdistance)}" y="{$actorBoxYoffset + $actorBoxMargin}" class="actorBoxText" style="{$statusStyle}">
                                    <xsl:value-of select="@name"/>
                                </text>
                            </g>
                        </xsl:for-each>
                    </wrap>
                </xsl:variable>
                <xsl:variable name="sequenceBars" as="element()*">
                    <g xmlns="http://www.w3.org/2000/svg" id="sequenceBars">
                        <!-- now loop through all transaction combinations -->
                    <xsl:for-each select="transaction">
                            <xsl:variable name="transactionId" select="@id"/>
                            <xsl:variable name="transactionModel" select="@model"/>
                            <xsl:variable name="transactionName">
                                <xsl:choose>
                                    <xsl:when test="name[@language=$defaultLanguage]">
                                        <xsl:value-of select="name[@language=$defaultLanguage][1]"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="name[1]"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:if test="@model">
                                    <xsl:text> (</xsl:text>
                                    <xsl:value-of select="@model"/>
                                    <xsl:text>)</xsl:text>
                                </xsl:if>
                            </xsl:variable>
                            <xsl:variable name="transactionPos" select="position()"/>
                            <xsl:variable name="transactionInitialPos" select="count(preceding-sibling::transaction[@type=('initial','stationary')])"/>
                            <xsl:choose>
                                <xsl:when test="@type='initial'">
                                    <xsl:for-each select="actors/actor[@role='sender']">
                                        <xsl:variable name="actorId" select="@id"/>
                                        <xsl:variable name="actorPos" select="position()"/>
                                        <xsl:variable name="actorReceiverCount" select="count(../actor[@role='receiver'][not(@id = $actorId)])"/>
                                        <xsl:variable name="sequenceBarY" as="xs:integer">
                                            <xsl:call-template name="getNewBarY">
                                                <xsl:with-param name="firstSequenceBarYoffset" select="$sequenceLineYoffset + $sequenceLineHeightBetweenActorBoxAndFirstBar"/>
                                                <xsl:with-param name="sequenceBarMargin" select="$sequenceBarMargin"/>
                                                <xsl:with-param name="arrowDistance" select="$arrowDistance"/>
                                                <xsl:with-param name="sequenceLineHeightBetweenBars" select="$sequenceLineHeightBetweenBars"/>
                                            </xsl:call-template>
                                        </xsl:variable>
                                        <xsl:for-each select="../actor[@role='receiver'][not(@id = $actorId)]">
                                            <xsl:variable name="actorIdBack" select="@id"/>
                                            <xsl:variable name="actorPosBack" select="position()"/>
                                            
                                            <!--<xsl:variable name="actorIdBack" select="parent::actors/actor[@role='receiver']/@id"/>-->
                                            <xsl:variable name="actorBoxNode" select="$actorBoxes/svg:g[@id=concat('actor_',$actorId)]" as="element()"/>
                                            <xsl:variable name="actorBoxNodeBack" select="$actorBoxes/svg:g[@id=concat('actor_',$actorIdBack)]" as="element()"/>
                                            <xsl:variable name="actorBoxSenderPos" select="count($actorBoxNode/preceding-sibling::svg:g) + 1"/>
                                            <xsl:variable name="actorBoxReceiverPos" select="count($actorBoxNodeBack/preceding-sibling::svg:g) + 1"/>
                                            <xsl:variable name="senderPos" select="$transactionInitialPos + $actorPosBack + (($actorPos - 1) * $actorReceiverCount)"/>
                                            <xsl:variable name="actorBoxSenderXoffset" select="$actorBoxes/svg:g[@id=concat('actor_',$actorId)]/svg:rect/@x"/>
                                            <xsl:variable name="actorBoxReceiverXoffset" select="$actorBoxes/svg:g[@id=concat('actor_',$actorIdBack)]/svg:rect/@x"/>
                                            <xsl:variable name="sequenceLineReceiverXoffset" select="$actorBoxReceiverXoffset + ($actorBoxWidth div 2)"/>
                                            <xsl:variable name="sequenceBarReceiverXoffset" select="$sequenceLineReceiverXoffset - ($sequenceBarWidth div 2)"/>
                                            <xsl:variable name="countBackTransactions" select="count(ancestor::transaction[@id=$transactionId]/following-sibling::transaction[@type='back'][actors/actor[@id=$actorId][@role='receiver']][actors/actor[@id=$actorIdBack][@role='sender']])"/>
                                            <xsl:variable name="sequenceBarHeight" select="($sequenceBarMargin*2) + ($countBackTransactions*$arrowDistance)"/>
                                            <xsl:variable name="sequenceLineX" select="$actorBoxSenderXoffset + ($actorBoxWidth div 2)"/>
                                            <xsl:variable name="sequenceBarX" select="$sequenceLineX - ($sequenceBarWidth div 2)"/>
                                            <!--<xsl:variable name="sequenceBarY" select="$sequenceLineYoffset + $sequenceLineHeightBetweenActorBoxAndFirstBar + (($senderPos - 1) * ($sequenceBarHeight + $sequenceLineHeightBetweenBars))"/>-->
                                            <xsl:variable name="sequenceLineY" select="$sequenceBarY + $sequenceBarHeight"/>
                                            <xsl:variable name="arrowLineX">
                                                <xsl:variable name="arrowLineXTemp" as="xs:integer">
                                                    <xsl:choose>
                                                        <xsl:when test="($sequenceBarX + $sequenceBarWidth) &lt; $sequenceBarReceiverXoffset">
                                                            <xsl:value-of select="$sequenceBarX + $sequenceBarWidth"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="$sequenceBarReceiverXoffset + $sequenceBarWidth"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:variable>
                                                <xsl:choose>
                                                    <xsl:when test="$actorBoxSenderPos lt $actorBoxReceiverPos">
                                                        <xsl:value-of select="$arrowLineXTemp"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="$arrowLineXTemp + $sequenceBarWidth"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:variable>
                                            <xsl:variable name="arrowLineY" select="$sequenceBarY + $sequenceBarMargin"/>
                                            <xsl:variable name="arrowLineTextX" select="$arrowLineX + ($arrowLength div 2) - 5"/>
                                            <xsl:variable name="arrowLineTextY" select="$arrowLineY - 10"/>
                                            <xsl:variable name="arrowLengthFull" select="if ($actorBoxSenderPos &lt; $actorBoxReceiverPos) then ($actorBoxReceiverXoffset - $actorBoxSenderXoffset - (2 * $sequenceBarWidth)) else ($actorBoxSenderXoffset - $actorBoxReceiverXoffset - (2 * $sequenceBarWidth))"/>
                                            <xsl:variable name="arrowType">
                                                <xsl:choose>
                                                    <xsl:when test="$actorBoxSenderPos lt $actorBoxReceiverPos">
                                                        <xsl:value-of select="concat('m ', $arrowLineX + $arrowLengthFull, ',', $arrowLineY - 5, $arrowHeadPointingRight)"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="concat('m ', $arrowLineX, ',', $arrowLineY + 5, $arrowHeadPointingLeft)"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:variable>
                                            <xsl:variable name="statusStyle" select="if (ancestor-or-self::*/@statusCode=$inactiveStatusCodes) then 'fill-opacity: 0.25; stroke-opacity: 0.25;' else 'fill-opacity: 1; stroke-opacity: 1;'"/>
                                            <xsl:comment> sequence bar client </xsl:comment>
                                            <xsl:text>
</xsl:text>
                                            <rect x="{$sequenceBarX}" y="{$sequenceBarY}" height="{$sequenceBarHeight}" width="{$sequenceBarWidth}" class="sequenceBarRect" style="{$statusStyle}"/>
                                            <g id="{concat('initiatingTransaction_',generate-id(.))}">
                                                <xsl:comment> Arrow text client to server </xsl:comment>
                                                <xsl:text>
</xsl:text>
                                                <text x="{$arrowLineTextX}" y="{$arrowLineTextY}" class="transactionLineText Center" style="{$statusStyle}">
                                                    <xsl:value-of select="$transactionName"/>
                                                </text>
                                                <xsl:comment> Arrow line client to server </xsl:comment>
                                                <xsl:text>
</xsl:text>
                                                <path d="{concat('m ',$arrowLineX, ',', $arrowLineY, ' h ', $arrowLengthFull)}" style="fill:none;stroke:black;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;marker-end:none;{$statusStyle}"/>
                                                <xsl:comment> Arrow head client to server </xsl:comment>
                                                <xsl:text>
</xsl:text>
                                                <path d="{$arrowType}" style="fill:black;fill-rule:evenodd;stroke:none;{$statusStyle}"/>
                                            </g>
                                            <xsl:if test="not(ancestor::transaction[@id=$transactionId]/following-sibling::transaction[@type='back'][actors/actor[@id=$actorId][@role='receiver']][actors/actor[@id=$actorIdBack][@role='sender']])">
                                                <xsl:comment> sequence bar server </xsl:comment>
                                                <xsl:text>
</xsl:text>
                                                <rect x="{$sequenceBarReceiverXoffset}" y="{$sequenceBarY}" height="{$sequenceBarHeight}" width="{$sequenceBarWidth}" class="sequenceBarRect" style="{$statusStyle}"/>
                                            </xsl:if>
                                            <xsl:for-each select="ancestor::transaction[@id=$transactionId]/following-sibling::transaction[@type='back'][actors/actor[@id=$actorId][@role='receiver']][actors/actor[@id=$actorIdBack][@role='sender']]">
                                                <xsl:variable name="transactionIdBack" select="@id"/>
                                                <xsl:variable name="transactionModelBack" select="@model"/>
                                                <xsl:variable name="transactionNameBack">
                                                    <xsl:choose>
                                                        <xsl:when test="name[@language=$defaultLanguage]">
                                                            <xsl:value-of select="name[@language=$defaultLanguage][1]"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="name[1]"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                    <xsl:if test="@model">
                                                        <xsl:text> (</xsl:text>
                                                        <xsl:value-of select="@model"/>
                                                        <xsl:text>)</xsl:text>
                                                    </xsl:if>
                                                </xsl:variable>
                                                <xsl:variable name="arrowLineXBack" select="if ($actorBoxSenderPos lt $actorBoxReceiverPos) then $arrowLineX + $sequenceBarWidth else $arrowLineX - $sequenceBarWidth"/>
                                                <xsl:variable name="arrowLineYBack" select="$arrowLineY + (position() * $arrowDistance)"/>
                                                <xsl:variable name="arrowLineTextXBack" select="$arrowLineXBack + ($arrowLength div 2) - 5"/>
                                                <xsl:variable name="arrowLineTextYBack" select="$arrowLineYBack - 10"/>
                                                <xsl:variable name="statusStyle" select="if (ancestor-or-self::*/@statusCode=$inactiveStatusCodes) then 'fill-opacity: 0.25; stroke-opacity: 0.25;' else 'fill-opacity: 1; stroke-opacity: 1;'"/>
                                                <xsl:variable name="arrowTypeBack">
                                                    <xsl:choose>
                                                        <xsl:when test="$actorBoxSenderPos lt $actorBoxReceiverPos">
                                                            <xsl:value-of select="concat('m ', $arrowLineXBack, ',', $arrowLineYBack + 5, $arrowHeadPointingLeft)"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="concat('m ', $arrowLineXBack + $arrowLengthFull, ',', $arrowLineYBack - 5, $arrowHeadPointingRight)"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:variable>
                                                <xsl:comment> sequence bar server </xsl:comment>
                                                <xsl:text>
</xsl:text>
                                                <rect x="{$sequenceBarReceiverXoffset}" y="{$sequenceBarY}" height="{$sequenceBarHeight}" width="{$sequenceBarWidth}" class="sequenceBarRect" style="{$statusStyle}"/>
                                                <g id="{concat('respondingTransaction_',$actorId,'_',generate-id(.))}">
                                                    <xsl:comment> Arrow text server to client </xsl:comment>
                                                    <xsl:text>
</xsl:text>
                                                    <text x="{$arrowLineTextXBack}" y="{$arrowLineTextYBack}" class="transactionLineText Center" style="{$statusStyle}">
                                                        <xsl:value-of select="$transactionNameBack"/>
                                                    </text>
                                                    <xsl:comment> Arrow line server to client </xsl:comment>
                                                    <xsl:text>
</xsl:text>
                                                    <path d="{concat('m ',$arrowLineXBack, ',', $arrowLineYBack, ' h ', $arrowLengthFull)}" style="fill:none;stroke:black;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;marker-end:none;{$statusStyle}"/>
                                                    <xsl:comment> Arrow head server to client </xsl:comment>
                                                    <xsl:text>
</xsl:text>
                                                    <path d="{$arrowTypeBack}" style="fill:black;fill-rule:evenodd;stroke:none;{$statusStyle}"/>
                                                </g>
                                            </xsl:for-each>
                                        </xsl:for-each>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:when test="@type='stationary'">
                                    <xsl:for-each select="actors/actor[@role=('sender','stationary')]">
                                        <xsl:variable name="actorId" select="@id"/>
                                        <xsl:variable name="actorPos" select="position()"/>
                                        <xsl:variable name="actorReceiverCount" select="count(../actor[@role='receiver'])"/>
                                        <xsl:variable name="sequenceBarY" as="xs:integer">
                                            <xsl:call-template name="getNewBarY">
                                                <xsl:with-param name="firstSequenceBarYoffset" select="$sequenceLineYoffset + $sequenceLineHeightBetweenActorBoxAndFirstBar"/>
                                                <xsl:with-param name="sequenceBarMargin" select="$sequenceBarMargin"/>
                                                <xsl:with-param name="arrowDistance" select="$arrowDistance"/>
                                                <xsl:with-param name="sequenceLineHeightBetweenBars" select="$sequenceLineHeightBetweenBars"/>
                                            </xsl:call-template>
                                        </xsl:variable>
                                        <xsl:if test="$actorReceiverCount &gt; 0 ">
                                            <xsl:comment> +++ Warning: Found <xsl:value-of select="$actorReceiverCount"/> receivers for stationary transaction. These are not rendered. </xsl:comment>
                                        </xsl:if>
                                        <xsl:variable name="actorIdBack" select="@id"/>
                                        <xsl:variable name="actorPosBack" select="position()"/>
                                            
                                        <!--<xsl:variable name="actorIdBack" select="parent::actors/actor[@role='receiver']/@id"/>-->
                                        <xsl:variable name="actorBoxSenderPos" select="count($actorBoxes/svg:g[@id=concat('actor_',$actorId)]/preceding-sibling::svg:g)+1"/>
                                        <xsl:variable name="actorBoxReceiverPos" select="count($actorBoxes/svg:g[@id=concat('actor_',$actorIdBack)]/preceding-sibling::svg:g)+1"/>
                                        <xsl:variable name="senderPos" select="$transactionInitialPos + $actorPosBack + (($actorPos - 1) * $actorReceiverCount)"/>
                                        <xsl:variable name="actorBoxSenderXoffset" select="$actorBoxes/svg:g[@id=concat('actor_',$actorId)]/svg:rect/@x"/>
                                        <xsl:variable name="actorBoxReceiverXoffset" select="$actorBoxes/svg:g[@id=concat('actor_',$actorIdBack)]/svg:rect/@x"/>
                                        <xsl:variable name="sequenceLineReceiverXoffset" select="$actorBoxReceiverXoffset + ($actorBoxWidth div 2)"/>
                                        <xsl:variable name="sequenceBarReceiverXoffset" select="$sequenceLineReceiverXoffset - ($sequenceBarWidth div 2)"/>
                                        <xsl:variable name="countBackTransactions" select="count(ancestor::transaction[@id=$transactionId]/following-sibling::transaction[@type='back'][actors/actor[@id=$actorId][@role='receiver']][actors/actor[@id=$actorIdBack][@role='sender']])"/>
                                        <xsl:variable name="sequenceBarHeight" select="($sequenceBarMargin*2) + ($countBackTransactions*$arrowDistance)"/>
                                        <xsl:variable name="sequenceLineX" select="$actorBoxSenderXoffset + ($actorBoxWidth div 2)"/>
                                        <xsl:variable name="sequenceBarX" select="$sequenceLineX - ($sequenceBarWidth div 2)"/>
                                        <!--<xsl:variable name="sequenceBarY" select="$sequenceLineYoffset + $sequenceLineHeightBetweenActorBoxAndFirstBar + (($senderPos - 1) * ($sequenceBarHeight + $sequenceLineHeightBetweenBars))"/>-->
                                        <xsl:variable name="sequenceLineY" select="$sequenceBarY + $sequenceBarHeight"/>
                                        <xsl:variable name="arrowLineX" select="if (($sequenceBarX + $sequenceBarWidth) &lt; $sequenceBarReceiverXoffset) then ($sequenceBarX + $sequenceBarWidth) else ($sequenceBarReceiverXoffset + $sequenceBarWidth)"/>
                                        <xsl:variable name="arrowLineY" select="$sequenceBarY + ($sequenceBarMargin div 2)"/>
                                        <xsl:variable name="arrowLineTextX" select="$arrowLineX + 20 + 5"/>
                                        <xsl:variable name="arrowLineTextY" select="$arrowLineY + ($sequenceBarMargin div 2) + 5"/>
                                        <xsl:variable name="arrowLengthFull" select="if ($actorBoxSenderPos &lt; $actorBoxReceiverPos) then ($actorBoxReceiverXoffset - $actorBoxSenderXoffset - (2 * $sequenceBarWidth)) else ($actorBoxSenderXoffset - $actorBoxReceiverXoffset - (2 * $sequenceBarWidth))"/>
                                        <xsl:variable name="statusStyle" select="if (ancestor-or-self::*/@statusCode=$inactiveStatusCodes) then 'fill-opacity: 0.25; stroke-opacity: 0.25;' else 'fill-opacity: 1; stroke-opacity: 1;'"/>
                                        <xsl:comment> sequence bar client </xsl:comment>
                                        <xsl:text>
</xsl:text>
                                        <rect x="{$sequenceBarX}" y="{$sequenceBarY}" height="{$sequenceBarHeight}" width="{$sequenceBarWidth}" class="sequenceBarRect" style="{$statusStyle}"/>
                                        <g id="{concat('initiatingTransaction_',generate-id(.))}">
                                            <xsl:comment> Arrow text client to server </xsl:comment>
                                            <xsl:text>
</xsl:text>
                                            <text x="{$arrowLineTextX}" y="{$arrowLineTextY}" class="transactionLineText Left" style="{$statusStyle}">
                                                <xsl:value-of select="$transactionName"/>
                                            </text>
                                            <xsl:comment> Arrow line client to server </xsl:comment>
                                            <xsl:text>
</xsl:text>
                                            <polyline points="{$arrowLineX},{$arrowLineY} {$arrowLineX + 20},{$arrowLineY} {$arrowLineX + 20},{$arrowLineY + 20} {$arrowLineX},{$arrowLineY + 20}" style="fill:white; stroke:black; stroke-width:1; {$statusStyle}"/>
                                            <xsl:comment> Arrow head client to server </xsl:comment>
                                            <xsl:text>
</xsl:text>
                                            <polyline points="{$arrowLineX},{$arrowLineY + 20} {$arrowLineX + 5},{$arrowLineY + 20 - 5} {$arrowLineX + 5},{$arrowLineY + 20 + 5}" style="fill:black; stroke:black; stroke-width:1; {$statusStyle}"/>
                                        </g>
                                        <xsl:if test="not(ancestor::transaction[@id=$transactionId]/following-sibling::transaction[@type='back'][actors/actor[@id=$actorId][@role='receiver']][actors/actor[@id=$actorIdBack][@role='sender']])">
                                            <xsl:comment> sequence bar server </xsl:comment>
                                            <xsl:text>
</xsl:text>
                                            <rect x="{$sequenceBarReceiverXoffset}" y="{$sequenceBarY}" height="{$sequenceBarHeight}" width="{$sequenceBarWidth}" class="sequenceBarRect" style="{$statusStyle}"/>
                                        </xsl:if>
                                        <xsl:for-each select="ancestor::transaction[@id=$transactionId]/following-sibling::transaction[@type='back'][actors/actor[@id=$actorId][@role='receiver']][actors/actor[@id=$actorIdBack][@role='sender']]">
                                            <xsl:variable name="transactionIdBack" select="@id"/>
                                            <xsl:variable name="transactionModelBack" select="@model"/>
                                            <xsl:variable name="transactionNameBack">
                                                <xsl:choose>
                                                    <xsl:when test="name[@language=$defaultLanguage]">
                                                        <xsl:value-of select="name[@language=$defaultLanguage][1]"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="name[1]"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                                <xsl:if test="@model">
                                                    <xsl:text> (</xsl:text>
                                                    <xsl:value-of select="@model"/>
                                                    <xsl:text>)</xsl:text>
                                                </xsl:if>
                                            </xsl:variable>
                                            <xsl:variable name="arrowLineXBack" select="$arrowLineX + 10"/>
                                            <xsl:variable name="arrowLineYBack" select="$arrowLineY + (position() * $arrowDistance)"/>
                                            <xsl:variable name="arrowLineTextXBack" select="$arrowLineXBack + ($arrowLength div 2) - 5"/>
                                            <xsl:variable name="arrowLineTextYBack" select="$arrowLineYBack - 10"/>
                                            <xsl:variable name="statusStyle" select="if (ancestor-or-self::*/@statusCode=$inactiveStatusCodes) then 'fill-opacity: 0.25; stroke-opacity: 0.25;' else 'fill-opacity: 1; stroke-opacity: 1;'"/>
                                            <xsl:comment> sequence bar server </xsl:comment>
                                            <xsl:text>
</xsl:text>
                                            <rect x="{$sequenceBarReceiverXoffset}" y="{$sequenceBarY}" height="{$sequenceBarHeight}" width="{$sequenceBarWidth}" class="sequenceBarRect" style="{$statusStyle}"/>
                                            <g id="{concat('respondingTransaction_',$actorId,'_',generate-id(.))}">
                                                <xsl:comment> Arrow text server to client </xsl:comment>
                                                <xsl:text>
</xsl:text>
                                                <text x="{$arrowLineTextXBack}" y="{$arrowLineTextYBack}" class="transactionLineText Left" style="{$statusStyle}">
                                                    <xsl:value-of select="$transactionNameBack"/>
                                                </text>
                                                <xsl:comment> Arrow line server to client </xsl:comment>
                                                <xsl:text>
</xsl:text>
                                                <path d="{concat('m ',$arrowLineXBack, ',', $arrowLineYBack, ' h ', $arrowLengthFull)}" style="fill:none;stroke:black;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;marker-end:none;{$statusStyle}"/>
                                                <xsl:comment> Arrow head server to client </xsl:comment>
                                                <xsl:text>
</xsl:text>
                                                <path d="{concat('m ', $arrowLineXBack, ',', $arrowLineYBack + 5, ' 0.4062,-9.99174 c -3.3774,1.28641 -6.7547,2.57283 -10.132,3.85925 0,0 0,0 0,0 -0.4815,0.18338 -0.9629,0.36676 -1.4444,0.55014 0,0 0,0 0,0 -0.076,0.0291 -0.153,0.0583 -0.2295,0.0874 0,0 0,0 0,0 0,0 0,0 0,0 -0.015,0.0176 -0.029,0.0231 -0.043,0.0246 0,0 0,0 0,0 -0.01,5.5e-4 -0.01,5.8e-4 -0.015,4.1e-4 -0,-6e-5 -0,-6e-5 -0,-6e-5 0,0 0,0 0,9e-5 0.01,2.6e-4 0.01,6.3e-4 0.015,0.002 0,0 0,0 0,0 0.014,0.003 0.028,0.009 0.041,0.028 0,0 0,0 0,0 0,0 0,0 0,0 0.074,0.0353 0.1478,0.0705 0.2216,0.10576 0.465,0.22185 0.93,0.44371 1.395,0.66556 3.2617,1.55631 6.5235,3.11262 9.7853,4.66892 z')}" style="fill:black;fill-rule:evenodd;stroke:none;{$statusStyle}"/>
                                            </g>
                                        </xsl:for-each>
                                    </xsl:for-each>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:for-each>
                    </g>
                </xsl:variable>
                <xsl:variable name="sequenceLineYmin" select="20"/>
                <xsl:variable name="sequenceLineYmax" select="max($sequenceBars/svg:rect/@y)"/>
                <xsl:variable name="sequenceLineHeight" select="if (empty($sequenceLineYmax)) then $sequenceLineYmin else ($sequenceLineYmax + ($sequenceBars/svg:rect[@y=$sequenceLineYmax])[last()]/@height) + $sequenceLineHeightAfterLastBar - $sequenceLineYoffset"/>
                <xsl:variable name="stationaryExtra" select="if (transaction[last()]/@type='stationary') then ($transactionNameMax * $letterWidth) else (0)"/>
                <xsl:variable name="svgWidth" select="($svgMargin*2) + ($actorBoxXdistance * ($countOfUniqueActors - 1)) + $actorBoxWidth + $stationaryExtra"/>
                <xsl:variable name="svgHeight" select="$svgMargin + $sequenceLineYoffset + $sequenceLineHeight"/>
                <xsl:variable name="pinkRectWidth" select="($pinkRectMargin*2) + ($transactionNameMax*$letterWidth)"/>
                <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" id="{concat('svg_',$transactionGroupId)}" version="1.1" height="{$svgHeight}" width="{$svgWidth}" style="fill:white;stroke:black;stroke-width:0;{$statusStyle}">
                    <defs>
                        <style type="text/css"><xsl:text>
                            .sequenceLine {
                                fill:none;stroke:black;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;
                            }
                            .sequenceBarRect {
                                fill:AliceBlue;fill-rule:evenodd;stroke:black;stroke-width:0.2;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;
                            }
                            .actorBox {
                                fill:AliceBlue;fill-rule:evenodd;stroke:black;stroke-width:0.2;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;
                            }
                            .actorBox:hover {
                                fill:LightSkyBlue;
                            }
                            .actorBoxText {
                                fill:black;stroke:none;font-size:</xsl:text>
                            <xsl:value-of select="$letterHeight"/>
                            <xsl:text>px;font-weight:bold;text-align:middle;line-height:100%;text-anchor:middle;font-family: Verdana, Arial, sans-serif;
                            }
                            .transactionLineText {
                                fill:black;stroke:none;font-size:</xsl:text>
                            <xsl:value-of select="$letterHeight"/>
                            <xsl:text>px;font-variant:normal;font-weight:bold;font-stretch:normal;line-height:125%;writing-mode:lr-tb;text-anchor:middle;font-family: Verdana, Arial, sans-serif;
                            }
                            .Left {
                                 text-align: left; text-anchor: initial;
                            }
                            .Center {
                                 text-align: center; text-anchor: middle;
                            }
                        </xsl:text></style>
                    </defs>
                    <xsl:comment>Service Name</xsl:comment>
                    <xsl:text>
</xsl:text>
                    <text x="{($svgWidth div 2)}" y="{$svgMargin}" style="font-size:12px;font-weight:bold;text-align:start;line-height:125%;text-anchor:middle;fill:black;stroke:none;font-family: Verdana, Arial, sans-serif;{$statusStyle}">
                        <xsl:value-of select="$transactionGroupName"/>
                    </text>
                    <g id="actorObjects">
                        <xsl:for-each select="$actorBoxes/svg:g">
                            <xsl:text>
      </xsl:text>
                            <xsl:comment> Actor box (header) - <xsl:value-of select="@name"/> </xsl:comment>
                            <xsl:text>
</xsl:text>
                            <xsl:copy-of select="."/>
                        </xsl:for-each>
                    </g>
                    <g id="sequenceLines">
                        <xsl:for-each select="$actorBoxes/svg:g">
                            <xsl:variable name="sequenceLineX" select="(svg:rect)[1]/@x + ((svg:rect)[1]/@width div 2)"/>
                            <path class="sequenceLine" style="{$statusStyle}" d="m {$sequenceLineX}, {$sequenceLineYoffset} v {$sequenceLineHeight}"/>
                        </xsl:for-each>
                    </g>
                    <xsl:copy-of select="$sequenceBars"/>
                </svg>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template name="getFullTitle">
        <xsl:call-template name="getProjectName"/>
        <xsl:if test="string-length($transactionGroupId)">
            <xsl:text> - </xsl:text>
            <xsl:call-template name="getTransactionGroupName"/>
        </xsl:if>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template name="getProjectName">
        <xsl:variable name="project" select="$allDECOR/project"/>
        <xsl:choose>
            <xsl:when test="$project/name[@language = $defaultLanguage]">
                <xsl:value-of select="$project/name[@language = $defaultLanguage]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$project/name[1]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
        <xd:param name="transactionGroup"/>
    </xd:doc>
    <xsl:template name="getTransactionGroupName">
        <xsl:param name="transactionGroup" select="$allDECOR/scenarios/scenario/transaction[@type='group'][@id=$transactionGroupId]"/>
        <xsl:choose>
            <xsl:when test="$transactionGroup/name[@language = $defaultLanguage]">
                <xsl:value-of select="$transactionGroup/name[@language = $defaultLanguage]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$transactionGroup/name[1]"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$transactionGroup[@versionLabel]">
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$transactionGroup/@versionLabel"/>
            <xsl:text>)</xsl:text>
        </xsl:if>
    </xsl:template>
<xd:doc>
        <xd:desc/>
        <xd:param name="firstSequenceBarYoffset"/>
        <xd:param name="sequenceLineHeightBetweenBars"/>
        <xd:param name="sequenceBarMargin"/>
    </xd:doc>
    <xsl:template name="getNewBarY" as="xs:integer">
        <xsl:param name="firstSequenceBarYoffset" as="xs:integer" required="yes"/>
        <xsl:param name="sequenceBarMargin" as="xs:integer" required="yes"/>
        <xsl:param name="arrowDistance" as="xs:integer" required="yes"/>
        <xsl:param name="sequenceLineHeightBetweenBars" as="xs:integer" required="yes"/>
        
        <xsl:variable name="actorId" select="@id"/>
        <xsl:variable name="transaction" select="ancestor::transaction[1]"/>
        <xsl:variable name="previousSenders" select="preceding-sibling::actor[@role = ('sender', 'stationary')]" as="element()*"/>
        <xsl:variable name="previousReceivers" select="../actor[@role = 'receiver'][not(@id = $previousSenders/@id)]" as="element()*"/>
        <xsl:variable name="previousReturns" select="$transaction/following-sibling::transaction[@type = 'back'][actors[actor[@id = $previousReceivers/@id][@role = 'sender']][actor[@id = $previousSenders/@id][@role = 'receiver']]]" as="element()*"/>
        <xsl:variable name="previousH" select="($sequenceBarMargin * 2) + (count($previousReturns) * $arrowDistance)"/>
        <xsl:variable name="previousSequenceBarHeights" as="xs:integer*">
            <xsl:for-each select="$previousSenders">
                <xsl:variable name="previousActorId" select="@id"/>
                <xsl:variable name="transactionId" select="$transaction/@id"/>
                <xsl:choose>
                    <xsl:when test="$transaction/@type = 'initial'">
                        <xsl:for-each select="$previousReceivers">
                            <xsl:variable name="actorIdBack" select="@id"/>
                            <xsl:variable name="countBackTransactions" select="count($transaction/following-sibling::transaction[@type = 'back'][actors[actor[@id = $actorIdBack][@role = 'sender']][actor[@id = $previousActorId][@role = 'receiver']]])"/>
                            
                            <xsl:value-of select="($sequenceBarMargin * 2) + ($countBackTransactions * $arrowDistance)"/>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="$transaction/@type = 'stationary'">
                        <xsl:variable name="actorIdBack" select="@id"/>
                        <xsl:variable name="countBackTransactions" select="count($transaction/following-sibling::transaction[@type = 'back'][actors[actor[@id = $actorIdBack][@role = 'sender']][actor[@id = $previousActorId][@role = 'receiver']]])"/>
                        
                        <xsl:value-of select="($sequenceBarMargin * 2) + ($countBackTransactions * $arrowDistance)"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
            <xsl:for-each select="$transaction/preceding-sibling::transaction">
                <xsl:variable name="transactionId" select="@id"/>
                <xsl:choose>
                    <xsl:when test="@type='initial'">
                        <xsl:for-each select="actors/actor[@role='sender']">
                            <xsl:variable name="actorId" select="@id"/>
                            <xsl:for-each select="../actor[@role='receiver'][not(@id = $actorId)]">
                                <xsl:variable name="actorIdBack" select="@id"/>
                                
                                <xsl:variable name="countBackTransactions" select="count(ancestor::transaction[@id=$transactionId]/following-sibling::transaction[@type='back'][actors/actor[@id=$actorId][@role='receiver']][actors/actor[@id=$actorIdBack][@role='sender']])"/>
                                
                                <xsl:value-of select="($sequenceBarMargin * 2) + ($countBackTransactions * $arrowDistance)"/>
                            </xsl:for-each>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="@type='stationary'">
                        <xsl:for-each select="actors/actor[@role=('sender','stationary')]">
                            <xsl:variable name="actorId" select="@id"/>
                            
                            <xsl:variable name="actorIdBack" select="@id"/>
                            
                            <xsl:variable name="countBackTransactions" select="count(ancestor::transaction[@id=$transactionId]/following-sibling::transaction[@type='back'][actors/actor[@id=$actorId][@role='receiver']][actors/actor[@id=$actorIdBack][@role='sender']])"/>
                            
                            <xsl:value-of select="($sequenceBarMargin * 2) + ($countBackTransactions * $arrowDistance)"/>
                        </xsl:for-each>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="empty($previousSequenceBarHeights)">
                <xsl:value-of select="$firstSequenceBarYoffset"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$firstSequenceBarYoffset + sum($previousSequenceBarHeights) + (count($previousSequenceBarHeights) * $sequenceLineHeightBetweenBars)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>