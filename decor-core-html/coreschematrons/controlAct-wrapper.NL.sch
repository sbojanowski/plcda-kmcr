<?xml version="1.0" encoding="UTF-8"?>
<pattern abstract="true" id="controlAct-wrapper" xmlns="http://purl.oclc.org/dsdl/schematron">
    <title>ControlActProcess</title>
    <rule context="$element">
        <let name="interactionId" value="local-name(..)"/>
        <let name="interactionVocab" value="'../vocab/2.16.840.1.113883.1.6.xml'"/>
        <let name="interactionTrustLevel" value="document($interactionVocab)/*/hl7:code[@code=$interactionId]/hl7:qualifier[@name='Vertrouwensniveau']/@value"/>
        <let name="interactionSendType" value="document($interactionVocab)/*/hl7:code[@code=$interactionId]/hl7:qualifier[@name='Verzendtype']/@value"/>
        <assert role="error" test="hl7:authorOrPerformer[hl7:participant/hl7:AssignedPerson] or not($interactionTrustLevel) or $interactionTrustLevel='Laag'"
            >Control Act: ControlActProcess/authorOrPerformer moet een persoon bevatten in berichten met vertrouwensniveau midden of hoog</assert>
        <assert role="error" test="hl7:overseer or not($interactionTrustLevel) or $interactionTrustLevel='Laag'"
            >Control Act: ControlActProcess/overseer moet de mandaterende persoon bevatten in berichten met vertrouwensniveau midden of hoog</assert>
        <assert role="error" test="not(hl7:queryByParameter) or @moodCode='EVN'"
            >Control Act: ControlActProcess moodCode moet EVN zijn bij queries</assert>
    </rule>
    <rule context="$element/hl7:id">
        <extends rule="II"/>
    </rule>
    <rule context="$element/hl7:code">
        <extends rule="CD"/>
        <assert role="error" test="@codeSystem='2.16.840.1.113883.1.18'"
        >ControlActProcess/code moet uit codeSystem '2.16.840.1.113883.1.18' komen</assert>
        <let name="codeValue" value="@code"/>
        <let name="interactionId" value="../../hl7:interactionId/@extension"/>
        <let name="vocabFile" value="concat('../vocab/',../../hl7:interactionId/@root,'.xml')"/>
        <assert role="error" test="document($vocabFile)/*/hl7:code[@code=$interactionId]/hl7:reference[@extension=$codeValue]"
            >Control Act: ControlActProcess/code (Trigger Event) moet bij deze interactie 
            '<value-of select="document($vocabFile)/*/hl7:code[@code=$interactionId]/hl7:reference/@extension"/>'
            zijn, gevonden is echter '<value-of select="$codeValue"/>'</assert>
    </rule>
    <rule context="$element/hl7:text">
        <assert role="warning" test="false()"
            ><value-of select="local-name(..)"/>/<value-of select="local-name()"/> niet gebruiken</assert>
    </rule>
    <rule context="$element/hl7:effectiveTime">
        <extends rule="TS"/>
        <assert role="error" test="(@xsi:type='TS' or ends-with(@xsi:type,':TS')) or (not(@xsi:type) and @value)"
            >Control Act: ControlActProcess/effectiveTime moet datatype TS hebben</assert>
    </rule>
    <rule context="$element/hl7:reasonCode">
        <assert role="warning" test="false()"
            ><value-of select="local-name(..)"/>/<value-of select="local-name()"/> niet gebruiken</assert>
    </rule>
    <rule context="$element/hl7:languageCode">
        <assert role="warning" test="false()"
            ><value-of select="local-name(..)"/>/<value-of select="local-name()"/> niet gebruiken</assert>
    </rule>
    
    <title>ControlActProcess/reason en ControlActProcess/reasonOf</title>
    <rule context="$element/*[self::hl7:reasonOf or self::hl7:reason]/*[self::hl7:justifiedDetectedIssue or self::hl7:justifyingDetectedIssueEvent]">
        <report role="warning" test="not(hl7:code[@code and @displayName] or hl7:text or hl7:value)"
            >Control Act: Bij voorkeur moet code/@displayName, text of value een uitgebreidere toelichting op de fout/waarschuwing hebben</report>
    </rule>
    <rule context="$element/*[self::hl7:reasonOf or self::hl7:reason]/*[self::hl7:justifiedDetectedIssue or self::hl7:justifyingDetectedIssueEvent]/hl7:code[not(@xsi:type or @xsi:type='CD' or ends-with(@xsi:type,':CD'))]">
        <extends rule="CD"/>
        <assert role="error" test="not(hl7:translation)">code mag geen translation bevatten</assert>
        <report role="warning" test="not(@codeSystem='2.16.840.1.113883.5.4') and not(@displayName) and not(following-sibling::hl7:value or following-sibling::hl7:text)"
            >Control Act: Als de code niet uit het standaard codesysteem '2.16.840.1.113883.5.4' komt is het @displayName attribuut verplicht, of er moet een value/text element zijn met aanvullende informatie</report>
    </rule>
    <rule context="$element/*[self::hl7:reasonOf or self::hl7:reason]/*[self::hl7:justifiedDetectedIssue or self::hl7:justifyingDetectedIssueEvent]/hl7:value[@xsi:type='CE' or ends-with(@xsi:type,':CE')]">
        <extends rule="CE"/>
    </rule>
    <rule context="$element/*[self::hl7:reasonOf or self::hl7:reason]/*[self::hl7:justifiedDetectedIssue or self::hl7:justifyingDetectedIssueEvent]/hl7:targetOf">
        <assert role="error" test="../hl7:code[@code and @codeSystem]"
            >Control Act: Als IssueManagement aanwezig is dan is de justifiedDetectedIssue/code verplicht</assert>
    </rule>
    
    <title>ControlActProcess/registrationProcess</title>
    <!-- Exact check of registrationProcess/@moodCode must be done per interaction -->
    <!-- Exact check of registrationProcess/code must be done per interaction, if so required -->
    <!-- Exact check of registrationProcess/statusCode must be done per interaction -->
    <!-- Exact check of registrationProcess/effectiveTime must be done per interaction -->
    <rule context="$element/hl7:subject/hl7:registrationProcess">
        <assert role="error" test="not(@classCode) or @classCode='REG'"  see="http://www.hl7.org/v3ballot/html/infrastructure/vocabulary/ActClass.htm#REG"
            >Control Act: registrationProcess/@classCode moet indien aanwezig 'REG' zijn</assert>
    </rule>
    
    <title>ControlActProcess/registrationProcess/id</title>
    <rule context="$element/hl7:subject/hl7:registrationProcess/hl7:id">
        <extends rule="II"/>
        
        <let name="sendingApplicationIdRoot" value="../../../../hl7:sender/hl7:device/hl7:id/@root"/>
        <let name="sendingApplicationIdExt" value="../../../../hl7:sender/hl7:device/hl7:id/@extension"/>
        <assert role="error" test="($sendingApplicationIdRoot='2.16.840.1.113883.2.4.6.6' and $sendingApplicationIdExt='1') or @nullFlavor='UNK'"
            >Control Act: registrationProcess/id/@nullFlavor moet 'UNK' zijn als de afzender niet de ZIM is</assert>
        <assert role="error" test="not($sendingApplicationIdRoot='2.16.840.1.113883.2.4.6.6' and $sendingApplicationIdExt='1') or @root"
            >Control Act: registrationProcess/id/@nullFlavor moet 'UNK' zijn als de afzender niet de ZIM is</assert>
    </rule>
    
    <title>ControlActProcess/registrationProcess/code</title>
    <rule context="$element/hl7:subject/hl7:registrationProcess/hl7:code">
        <let name="codeValue" value="@code"/>
        <let name="codeSystem" value="@codeSystem"/>
        <let name="displayName" value="document(concat('../vocab/',$codeSystem,'.xml'))/*/hl7:code[@code=$codeValue]/@displayName"/>
        <assert role="error" test="$codeSystem='2.16.840.1.113883.2.4.15.4' or $codeSystem='2.16.840.1.113883.6.1'"
            >Control Act: registrationProcess/code moet uit ActRegistrycodeNL (2.16.840.1.113883.2.4.15.4) of LOINC (2.16.840.1.113883.6.1) komen.</assert>
        <assert role="error" test="document(concat('../vocab/',$codeSystem,'.xml'))/*/hl7:code[@code=$codeValue]"
            >Control Act: registrationProcess/code '<value-of select="$codeValue"/>' is niet geldig binnen codeSystem '<value-of select="$codeSystem"/>' (ActRegistryCodeNL of LOINC).</assert>
        <assert role="error" test="if ($codeValue='117117' or $codeValue='118118' or $codeValue='118400' or $codeValue='603508' or $codeValue='302850') then (
                ../hl7:subject1) else (../hl7:subject2)"
            >Control Act: registrationProcess/code '<value-of select="$codeValue"/>' (<value-of select="$displayName"/>) komt niet overeen met het gebruikte type register. Rollen
            horen in subject1 en Act's in subject2.</assert>
    </rule>
    
    <title>ControlActProcess/registrationProcess/statusCode</title>
    <rule context="$element/hl7:subject/hl7:registrationProcess/hl7:statusCode">
        <extends rule="CS"/>
    </rule>
    
    <title>ControlActProcess/registrationProcess/effectiveTime</title>
    <rule context="$element/hl7:subject/hl7:registrationProcess/hl7:effectiveTime">
        <extends rule="IVL_TS"/>
        <assert role="error" test="not(@nullFlavor) or @nullFlavor='UNK'"
            >Control Act: registrationProcess/effectiveTime/@nullFlavor moet, indien aanwezig, 'UNK' zijn.</assert>
        <assert role="error" test="not(hl7:*/@nullFlavor) or hl7:*/@nullFlavor='UNK'"
            >Control Act: registrationProcess/effectiveTime/<value-of select="local-name()"/>/@nullFlavor moet, indien aanwezig, 'UNK' zijn.</assert>
        <assert role="error" test="@nullFlavor or hl7:*[local-name()='low' or local-name()='high']"
            >Control Act: registrationProcess/effectiveTime mag alleen bestaan uit datum eerste aanmelding (effectiveTime/low) en een einde van de geldigheidsperiode (effectiveTime/high).</assert>
    </rule>
    
    <title>ControlActProcess/queryByParameter</title>
    <rule context="$element/hl7:queryByParameter">
        <let name="interactionId" value="local-name(../..)"/>
        <assert role="warning" test="hl7:executionAndDeliveryTime or
            $interactionId='PRPA_IN900111NL' or 
            $interactionId='PRPA_IN900112NL' or
            $interactionId='QUMT_IN020010' or
            $interactionId='QUMT_IN020011NL' or
            $interactionId='QUMT_IN020011NL02' or
            $interactionId='QUMT_IN900008NL' or
            $interactionId='QUMT_IN900013NL' or
            $interactionId='QUPA_IN101101' or 
            $interactionId='QUPA_IN101102' or
            $interactionId='QUPA_IN101103' or 
            $interactionId='QUPA_IN101104'"
            >Control Act: Waarschuwing: queryByParameter/executionAndDeliveryTime is verplicht vanaf AORTA 6 indien hier een waarde voor is ingesteld in het XIS.</assert>
        <assert role="error" test="hl7:responsePriorityCode or $interactionId='PRPA_IN900111NL' or $interactionId='PRPA_IN900112NL'"
            >Control Act: queryByParameter/responsePriorityCode is verplicht vanaf AORTA 6</assert>
        <assert role="error" test="hl7:responseModalityCode or $interactionId='PRPA_IN900111NL' or $interactionId='PRPA_IN900112NL'"
            >Control Act: responseModalityCode is verplicht vanaf AORTA 6</assert>
    </rule>
    <rule context="$element/hl7:queryByParameter/hl7:statusCode">
        <extends rule="CS"/>
        <let name="interactionId" value="local-name(../../..)"/>
        <assert role="error" test="@code='executing' or @code='aborted' or @code='waitContinuedQueryResponse'"
            >Control Act: queryByParameter/statusCode moet 'executing', 'aborted', of 'waitContinuedQueryResponse' zijn</assert>
        <assert role="error" test="@code='executing' or
            $interactionId='QUQI_IN000003' or
            $interactionId='QUQI_IN000003UV'"
            >Control Act: queryByParameter/statusCode moet 'executing' zijn, behalve bij QUQI_IN000003(UV)</assert>
        <assert role="error" test="@code='aborted' or @code='waitContinuedQueryResponse' or not( 
            $interactionId='QUQI_IN000003' or
            $interactionId='QUQI_IN000003UV')"
            >Control Act: queryByParameter/statusCode moet 'aborted' of 'waitContinuedQueryResponse' zijn bij QUQI_IN000003(UV)</assert>
    </rule>
    <rule context="$element/hl7:queryByParameter/hl7:modifyCode">
        <extends rule="CS"/>
        <assert role="error" test="@code='M' or @code='N'"
            >Control Act: queryByParameter/modifyCode moet 'M' (Modified) of 'N' (New) zijn</assert>
    </rule>
    <rule context="$element/hl7:queryByParameter/hl7:responseElementGroupId">
        <extends rule="II"/>
        <assert role="error" test="not(.)"
            >Control Act: queryByParameter/responseElementGroupId mag niet gebruikt worden</assert>
    </rule>
    <rule context="$element/hl7:queryByParameter/hl7:responseModalityCode">
        <extends rule="CS"/>
        <assert role="error" test="@code='R' or @code='B'"
            >Control Act: queryByParameter/responseModalityCode moet 'R' (Realtime) of 'B' (Batch) zijn</assert>
        
        <!-- Queries van type indirect opvragen -->
        <let name="interactionId" value="local-name(../../..)"/>
        <let name="interactionVocab" value="'../vocab/2.16.840.1.113883.1.6.xml'"/>
        <let name="interactionSendType" value="document($interactionVocab)/*/hl7:code[@code=$interactionId]/hl7:qualifier[@name='Verzendtype']/@value"/>
        <let name="interactionQueryType" value="document($interactionVocab)/*/hl7:code[@code=$interactionId]/hl7:qualifier[@name='Vraagtype']/@value"/>
        <let name="receivingApplication" value="../../../hl7:receiver/hl7:device/hl7:id[@root='2.16.840.1.113883.2.4.6.6']/@extension"/>
        <let name="sendingApplication" value="../../../hl7:sender/hl7:device/hl7:id[@root='2.16.840.1.113883.2.4.6.6']/@extension"/>
        <assert role="error" test="not(@code='R') or not($interactionSendType='Initiërend') or $interactionQueryType='Direct' or $sendingApplication='1'"
            >Control Act: queryByParameter/responseModalityCode/@code moet 'B' zijn bij indirecte vragen aan de ZIM</assert>
        <assert role="error" test="not(@code='B') or ($interactionQueryType='Indirect' and not($sendingApplication='1'))"
            >Control Act: queryByParameter/responseModalityCode/@code moet 'R' zijn bij directe vragen en bij vragen verstuurd door de ZIM (in feite ook een directe vraag)</assert>
    </rule>
    <rule context="$element/hl7:queryByParameter/hl7:responsePriorityCode">
        <extends rule="CS"/>
        <assert role="error" test="@code='I'"
            >Control Act: queryByParameter/responsePriorityCode moet 'I' (Immediate) zijn</assert>
    </rule>
    <rule context="$element/hl7:queryByParameter/hl7:initialQuantity">
        <extends rule="INT"/>
        <assert role="error" test="not(.)"
            >Control Act: queryByParameter/initialQuantity mag niet gebruikt worden</assert>
        <assert role="error" test="../hl7:initialQuantityCode"
            >Control Act: queryByParameter/initialQuantityCode is verplicht indien initialQuantity wordt gebruikt</assert>
    </rule>
    <rule context="$element/hl7:queryByParameter/hl7:initialQuantityCode">
        <extends rule="CE"/>
        <assert role="error" test="../hl7:initialQuantity"
            >Control Act: queryByParameter/initialQuantity is verplicht indien initialQuantityCode wordt gebruikt</assert>
        <!--assert role="error" test="@code='MC' and @codeSystem='2.16.840.1.113883.5.1112'"
            >Control Act: queryByParameter/initialQuantityCode/@code moet 'MC' (Matching Classes) en @codeSystem moet '2.16.840.1.113883.5.1112' zijn</assert-->
    </rule>
    <rule context="$element/hl7:queryByParameter/hl7:executionAndDeliveryTime">
        <extends rule="TS"/>
        <assert role="error" test="not(../../../hl7:profileId[@root='2.16.840.1.113883.2.4.3.11.1' and (@extension='608' or @extension='705' or @extension='805')])"
            >Control Act: queryByParameter/executionAndDeliveryTime is pas toegestaan vanaf profileId 810</assert>
        <assert role="error" test="@value"
            >Control Act: queryByParameter/executionAndDeliveryTime/@value moet een waarde hebben</assert>
        <assert role="error" test="matches(@value,'^[0-9]{12}')"
            >Control Act: queryByParameter/executionAndDeliveryTime/@value moet tenminste tot op de minuten nauwkeurig zijn</assert>
        <let name="creationTime" value="../../../hl7:creationTime/@value"/>
        <report role="warning" test="not(string-length(@value)=string-length($creationTime))"
            >Control Act: queryByParameter/executionAndDeliveryTime/@value '<value-of select="@value"/>' en creationTime '<value-of select="$creationTime"/>' hebben niet dezelfde precisie. Aanbevolen is om ze dezelfde precisie te geven</report>
        <assert role="error" test="if ((string-length(@value)=14 and string-length($creationTime)=14) or
            (string-length(@value)=12 and string-length($creationTime)=12)) then (
            (number(@value) - number($creationTime)) &gt;= 5) else ( 1=1 )"
            >Control Act: queryByParameter/executionAndDeliveryTime/@value '<value-of select="@value"/>' ligt niet 5 seconden of meer na creationTime '<value-of select="$creationTime"/>'</assert>
        <!-- controles voor als creationTime en/of executionAndDeliveryTime een tijdzone of subseconden heeft -->
    </rule>
    <rule context="$element/hl7:queryByParameter//hl7:semanticsText">
        <extends rule="ST"/>
        <assert role="warning" test="false()"
            >Control Act: het queryParameter element semanticsText bij voorkeur niet gebruiken</assert>
    </rule>
    <rule context="$element/hl7:queryByParameter/hl7:sortControl">
        <assert role="error" test="not(.)"
            >Control Act: queryByParameter/sortControl mag niet gebruikt worden</assert>
    </rule>
    
    <title>ControlActProcess/queryAck</title>
    <rule context="$element/hl7:queryAck">
        <assert role="error" test="hl7:resultTotalQuantity"
            >Control Act: queryAck/resultTotalQuantity ontbreekt</assert>
        <assert role="error" test="hl7:resultCurrentQuantity"
            >Control Act: queryAck/resultCurrentQuantity ontbreekt</assert>
        <assert role="error" test="hl7:resultRemainingQuantity"
            >Control Act: queryAck/resultRemainingQuantity ontbreekt</assert>
    </rule>
    <rule context="$element/hl7:queryAck/hl7:id">
        <extends rule="II"/>
        <assert role="error" test="@root and @extension"
            >Control Act: queryAck/queryId mist root en/of extension</assert>
    </rule>
    <rule context="$element/hl7:queryAck/hl7:statusCode">
        <extends rule="CS"/>
        <let name="interactionId" value="local-name(../../..)"/>
        <assert role="error" test="@code='aborted' or @code='deliveredResponse'"
            >Control Act: queryAck/statusCode moet 'aborted', of 'deliveredResponse' zijn</assert>
        <!--assert role="error" test="@code='deliveredResponse' or
            $interactionId='QUQI_IN000002UV'"
            >Control Act: queryByParameter/statusCode moet 'deliveredResponse' zijn, behalve bij QUQI_IN000002UV</assert>
        <assert role="error" test="@code='aborted' or @code='deliveredResponse' or not( 
            $interactionId='QUQI_IN000002UV')"
            >Control Act: queryByParameter/statusCode moet 'aborted' of 'deliveredResponse' zijn bij QUQI_IN000002UV</assert-->
    </rule>
    <rule context="$element/hl7:queryAck/hl7:queryResponseCode">
        <extends rule="CS"/>
        <assert role="error" test="@code='NF' or @code='AE' or @code='QE' or @code='OK'"
            >Control Act: queryAck/queryResponsecode/code moet NF (Nothing found), AE (Application Error), QE (Query error) of OK bevatten</assert>
        
        <let name="acknowledgementTypeCode" value="../../../hl7:acknowledgement/@typeCode"/>
        <assert role="error" test="if ($acknowledgementTypeCode='AA') then (
            @code='NF' or @code='OK' ) else (
            @code='AE' or @code='QE'
            )">Control Act: queryAck/queryResponseCode moet bij een positief antwoord 'OK' of 'NF' zijn, anders moet deze 'AE' of 'QE' zijn</assert>
        
        <let name="resultCurrentQuantity" value="../hl7:resultCurrentQuantity/@value"/>
        <assert role="error" test="not(@code='OK') or ($acknowledgementTypeCode='AA' and $resultCurrentQuantity &gt; 0)"
            >Control Act: queryAck/queryResponseCode moet 'OK' bevatten indien er op basis van de queryParameters resultaten gevonden konden 
            worden (resultCurrentQuantity/@value='<value-of select="$resultCurrentQuantity"/>') en de query valide
            is (acknowledgement/@typeCode='<value-of select="$acknowledgementTypeCode"/>')</assert>
        <assert role="error" test="not(@code='NF') or ($acknowledgementTypeCode='AA' and $resultCurrentQuantity = 0)"
            >Control Act: queryAck/queryResponseCode moet 'NF' bevatten indien er op basis van de queryParameters geen resultaten gevonden konden 
            worden (resultCurrentQuantity/@value='<value-of select="$resultCurrentQuantity"/>') en de query valide
            is (acknowledgement/@typeCode='<value-of select="$acknowledgementTypeCode"/>')</assert>
    </rule>
    <rule context="$element/hl7:queryAck/hl7:resultTotalQuantity">
        <extends rule="INT"/>
        <assert role="error" test="number(@value) &gt;= 0 or @nullFlavor='NAV'"
            >Control Act: queryAck/resultTotalQuantity moet 0 of groter zijn, of nullFlavor moet 'NAV' zijn</assert>
        
        <let name="resultCurrentQuantity" value="number(../hl7:resultCurrentQuantity/@value)"/>
        <assert role="error" test="if (@value and $resultCurrentQuantity) then (number(@value) &gt;= $resultCurrentQuantity) else (1=1)"
            >Control Act: queryAck/resultTotalQuantity '<value-of select="@value"/>' moet groter zijn dan resultCurrentQuantity '<value-of select="$resultCurrentQuantity"/>'</assert>
    </rule>
    <!-- (verplicht te vullen voor zenders van antwoordberichten met ingang van de onderhoudsrelease AORTA 2008; 
        verplicht te gebruiken voor zowel zenders als ontvangers met ingang van de onderhoudsrelease AORTA 2009) 
        Dit attribuut mag geen nullFlavor bevatten. -->
    <rule context="$element/hl7:queryAck/hl7:resultCurrentQuantity">
        <extends rule="INT"/>
        <assert role="error" test="not(@nullFlavor) and @value"
            >Control Act: queryAck/resultCurrentQuantity moet 0 of groter zijn</assert>
        
        <let name="resultCurrentQuantity" value="count(../../hl7:subject)"/>
        <assert role="error" test="@value=$resultCurrentQuantity"
            >Control Act: queryAck/resultCurrentQuantity '<value-of select="@value"/>' moet gelijk zijn aan het aantal subject elementen ('<value-of select="$resultCurrentQuantity"/>')</assert>
    </rule>
    <rule context="$element/hl7:queryAck/hl7:resultRemainingQuantity">
        <extends rule="INT"/>
        <assert role="error" test="@nullFlavor='NAV' or @value &gt;= 0"
            >Control Act: queryAck/resultRemainingQuantity moet 0 of groter zijn, of nullFlavor moet 'NAV' zijn</assert>
        
        <let name="resultTotalQuantity" value="number(../hl7:resultTotalQuantity/@value)"/>
        <assert role="error"
            test="if (@value and $resultTotalQuantity) then (number(@value) &lt;= $resultTotalQuantity) else (1=1)"
            >Control Act: queryAck/resultRemainingQuantity '<value-of select="@value"/>' moet kleiner dan of gelijk aan resultTotalQuantity '<value-of select="$resultTotalQuantity"/>' zijn</assert>
        
        <!--report test="@value = 0 or (@value = 0 and
            preceding-sibling::hl7:resultCurrentQuantity/@value &lt;= preceding-sibling::hl7:resultTotalQuantity/@value)"
            >Control Act: resultRemainingQuantity is 0, maar resultTotalQuantity is groter dan resultCurrentQuantity. Dit kan alleen als gedoseerd opleveren niet wordt ondersteund.</report-->
    </rule>
    
    <title>ControlActProcess/informationRecipient</title>
    <rule context="$element/hl7:informationRecipient">
        <assert role="warning" test="not(.)"
            >Control Act: informationRecipient is niet gespecificeerd in de Nederlandse Implementatiehandleiding Wrappers.</assert>
    </rule>
    
    <title>ControlActProcess/dataEnterer</title>
    <rule context="$element/hl7:dataEnterer">
        <assert role="warning" test="not(.)"
            >Control Act: dataEnterer is niet gespecificeerd in de Nederlandse Implementatiehandleiding Wrappers.</assert>
    </rule>
    
    
    <title>ControlActProcess/authorOrPerformer</title>
    <rule context="$element/hl7:authorOrPerformer">
        <assert role="error" test="@typeCode='AUT' or @typeCode='PRF'"
            >Control Act: authorOrPerformer/@typeCode moet AUT or PRF zijn</assert>
    </rule>
    
    <title>ControlActProcess/authorOrPerformer/AssignedPerson</title>
    <rule context="$element/hl7:authorOrPerformer/hl7:participant/hl7:AssignedPerson">        
        <assert role="error" test="count(hl7:id[@root='2.16.528.1.1007.3.1' or @root='2.16.840.1.113883.2.4.6.3' or @root='2.16.840.1.113883.2.4.3.11.7.3' or @root='2.16.528.1.1003.1.3.5.4.1'])&gt;=1"
            >Control Act: authorOrPerformer/*/AssignedPerson/id. Tenminste één id moet als root 2.16.528.1.1007.3.1 (UZI), 2.16.840.1.113883.2.4.6.3 (BSN) of 2.16.840.1.113883.2.4.3.11.7.3 (batch inzage auteur), of 2.16.528.1.1003.1.3.5.4.1 (Nictiz-klantenloket met PKIO-pas van Getronics) hebben</assert>
        
        <assert role="warning" test="not(hl7:id[@root='2.16.528.1.1007.3.1']) or hl7:code[@codeSystem='2.16.840.1.113883.2.4.15.111']"
            >Control Act: authorOrPerformer/*/AssignedPerson/code ontbreekt. Dit is alleen toegestaan als de rolcode 00.000 is.</assert>
        
        <!-- Organization/id test -->
        <assert role="error" test="not(hl7:id[@root='2.16.528.1.1007.3.1']) or hl7:Organization/hl7:id[@root='2.16.528.1.1007.3.3' and @extension]"
            >Control Act: authorOrPerformer/*/AssignedPerson/Organization/id moet de zorgaanbieder van de persoon identificeren</assert>
        <assert role="error" test="not(hl7:id[@root='2.16.840.1.113883.2.4.6.3']) or hl7:Organization/hl7:id[@root='2.16.840.1.113883.2.4.3.11.25']"
            >Control Act: authorOrPerformer/*/AssignedPerson/Organization/id/@root moet '2.16.840.1.113883.2.4.3.11.25' bevatten</assert>
        <assert role="error" test="not(hl7:id[@root='2.16.840.1.113883.2.4.3.11' or @root='2.16.528.1.1003.1.3.5.4.1']) or hl7:Organization/hl7:id[@root='2.16.840.1.113883.2.4.3.11' and @extension='7']"
            >Control Act: authorOrPerformer/*/AssignedPerson/Organization/id moet de Nictiz-klantenloket organisatie identificeren</assert>
        
        <!-- Organization/name test -->
        <assert role="error" test="not(hl7:Organization/hl7:id[@root='2.16.528.1.1007.3.3']) or hl7:Organization/hl7:name"
            >Control Act: authorOrPerformer/*/AssignedPerson/Organization/name moet de zorgaanbieder/organisatienaam bevatten</assert>
        <assert role="error" test="not(hl7:Organization/hl7:id[@root='2.16.840.1.113883.2.4.3.11' and @extension='7']) or hl7:Organization/hl7:name"
            >Control Act: authorOrPerformer/*/AssignedPerson/Organization/name moet de Nictiz-klantenloket organisatienaam bevatten</assert>
    </rule>
    
    <title>ControlActProcess/authorOrPerformer/participant/AssignedPerson/id</title>
    <rule context="$element/hl7:authorOrPerformer/hl7:participant/hl7:AssignedPerson/hl7:id">
        <extends rule="II"/>
        <assert role="error" test="@root='2.16.528.1.1007.3.1' or @root='2.16.840.1.113883.2.4.6.3' or @root='2.16.840.1.113883.2.4.3.11.7.3' or @root='2.16.528.1.1003.1.3.5.4.1' or @root='2.16.840.1.113883.2.4.6.1'"
            >Control Act: authorOrPerformer/*/AssignedPerson/id. @root moet 2.16.528.1.1007.3.1 (UZI), 2.16.840.1.113883.2.4.6.3 (BSN) of 2.16.840.1.113883.2.4.3.11.7.3 (batch inzage auteur), 2.16.528.1.1003.1.3.5.4.1 (Nictiz-klantenloket met PKIO-pas van Getronics), of 2.16.840.1.113883.2.4.6.1 (AGB-code) zijn</assert>
        
        <assert role="error" test="not(@root='2.16.840.1.113883.2.4.6.3') or following-sibling::hl7:code[@codeSystem='2.16.840.1.113883.2.4.3.11.8'][@code='P']"
            >Control Act: authorOrPerformer/*/AssignedPerson/code/@code moet "P" (Patiënt) zijn. Wettelijke vertegenwoordigers moet dit via het Klantenloket doen en kunnen dus niet als auteur optreden</assert>
        <assert role="warning" test="not(@root='2.16.840.1.113883.2.4.6.3') or 
            not(../../../../*[local-name()='queryByParameter' or local-name()='subject']//hl7:*[@root='2.16.840.1.113883.2.4.6.3']) or 
            ../../../../../hl7:attentionLine"
            >Control Act: patiëntgebonden interacties, verzonden vanuit een patiëntenportaal (GBP), moeten een attentionLine hebben</assert>
        
        <assert role="error" test="not(@root='2.16.840.1.113883.2.4.3.11.7.3' or @root='2.16.528.1.1003.1.3.5.4.1') or following-sibling::hl7:code[@codeSystem='2.16.840.1.113883.2.4.3.11.8'][@code='KLANTENLOKET']"
            >Control Act: authorOrPerformer/*/AssignedPerson/code/@code moet "KLANTENLOKET" zijn voor klantenloketmedewerkers</assert>
        <assert role="error" test="not(@root='2.16.840.1.113883.2.4.3.11.7.3' or @root='2.16.528.1.1003.1.3.5.4.1') or 
            not(../../../../*[local-name()='queryByParameter' or local-name()='subject']//hl7:*[@root='2.16.840.1.113883.2.4.6.3']) or 
            ../../../../../hl7:attentionLine"
            >Control Act: patiëntgebonden interacties, verzonden vanuit het klantenloket (GBK), moeten een attentionLine hebben</assert>
    </rule>
    
    <rule context="$element/hl7:authorOrPerformer/hl7:participant/hl7:AssignedPerson/hl7:code">
        <extends rule="CE"/>
    </rule>
    
    <rule context="$element/hl7:authorOrPerformer/hl7:participant/hl7:AssignedPerson/hl7:telecom">
        <extends rule="TEL"/>
    </rule>
    
    <rule context="$element/hl7:authorOrPerformer/hl7:participant/hl7:AssignedPerson/hl7:name">
        <extends rule="PN"/>
    </rule>
    
    <rule context="$element/hl7:authorOrPerformer/hl7:noteText">
        <assert role="warning" test="false()"
            ><value-of select="local-name(..)"/>/<value-of select="local-name()"/> niet gebruiken</assert>
    </rule>
    <rule context="$element/hl7:authorOrPerformer/hl7:time">
        <assert role="warning" test="false()"
            ><value-of select="local-name(..)"/>/<value-of select="local-name()"/> niet gebruiken</assert>
    </rule>
    <rule context="$element/hl7:authorOrPerformer/hl7:modeCode">
        <assert role="warning" test="false()"
            ><value-of select="local-name(..)"/>/<value-of select="local-name()"/> niet gebruiken</assert>
    </rule>
    <rule context="$element/hl7:authorOrPerformer/hl7:signatureCode">
        <assert role="warning" test="false()"
            ><value-of select="local-name(..)"/>/<value-of select="local-name()"/> niet gebruiken</assert>
    </rule>
    <rule context="$element/hl7:authorOrPerformer/hl7:signatureText">
        <assert role="warning" test="false()"
            ><value-of select="local-name(..)"/>/<value-of select="local-name()"/> niet gebruiken</assert>
    </rule>
    
    <rule context="$element/hl7:authorOrPerformer/hl7:participant/hl7:AssignedPerson/hl7:Organization/hl7:id">
        <extends rule="II"/>
    </rule>
    
    <rule context="$element/hl7:authorOrPerformer/hl7:participant/hl7:AssignedPerson/hl7:Organization/hl7:code">
        <extends rule="CE"/>
    </rule>
    
    <rule context="$element/hl7:authorOrPerformer/hl7:participant/hl7:AssignedPerson/hl7:Organization/hl7:telecom">
        <extends rule="TEL"/>
    </rule>
    
    <rule context="$element/hl7:authorOrPerformer/hl7:participant/hl7:AssignedPerson/hl7:Organization/hl7:name">
        <extends rule="ON"/>
    </rule>
    
    <rule context="$element/hl7:authorOrPerformer/hl7:participant/hl7:AssignedPerson/hl7:Organization/hl7:addr">
        <extends rule="AD"/>
    </rule>
    
    <title>ControlActProcess/authorOrPerformer/AssignedDevice</title>
    <rule context="$element/hl7:authorOrPerformer/hl7:participant/hl7:AssignedDevice">
        <assert role="error" test="count(hl7:id[@root='2.16.528.1.1007.3.2' or @root='2.16.840.1.113883.2.4.6.6' or @root='2.16.528.1.1007.4'])&gt;=1"
            >Control Act: authorOrPerformer/*/AssignedDevice/id. Tenminste één id moet als root 2.16.528.1.1007.3.2 (UZI-systemen), 2.16.840.1.113883.2.4.6.6 (Applicatie-id) of 2.16.528.1.1007.4 (SBV-Z) hebben</assert>
        
        <assert role="error" test="not(hl7:Organization/hl7:id[@root='2.16.528.1.1007.3.3']) or hl7:id[@root='2.16.528.1.1007.3.2']"
            >Control Act: authorOrPerformer/*/AssignedDevice/id moet tenminste het UZI-nummer systemen bevatten voor een XIS in een GBZ</assert>
        
        <assert role="error" test="not(hl7:id[@root='2.16.528.1.1007.3.2']) or hl7:Organization/hl7:id[@root='2.16.528.1.1007.3.3' and @extension]"
            >Control Act: authorOrPerformer/*/AssignedDevice/Organization/id moet de zorgaanbieder van het XIS identificeren</assert>
        
        <assert role="warning" test="hl7:id[(@root='2.16.840.1.113883.2.4.6.6' and @extension='1') or @root='2.16.528.1.1007.4'] or hl7:Organization/hl7:id"
            >Control Act: authorOrPerformer/*/AssignedDevice moet een geïdentificeerde organisatie hebben, tenzij het de ZIM of het SBV-Z betreft.</assert>
    </rule>
    
    <title>ControlActProcess/authorOrPerformer/participant/AssignedDevice/id</title>
    <rule context="$element/hl7:authorOrPerformer/hl7:participant/hl7:AssignedDevice/hl7:id">
        <extends rule="II"/>
        <let name="autIdExt" value="@extension"/>
        <let name="sendIdExt" value="../../../../../hl7:sender/hl7:device/hl7:id[@root='2.16.840.1.113883.2.4.6.6']/@extension"/>
        
        <assert role="error" test="@root='2.16.528.1.1007.3.2' or @root='2.16.840.1.113883.2.4.6.6' or @root='2.16.528.1.1007.4'"
            >Control Act: authorOrPerformer/*/AssignedDevice/id. @root 2.16.528.1.1007.3.2 (UZI-systemen), 2.16.840.1.113883.2.4.6.6 (Applicatie-id) of 2.16.528.1.1007.4 (SBV-Z) zijn</assert>
        <assert role="error" test="$sendIdExt=$autIdExt or not(@root='2.16.840.1.113883.2.4.6.6') or empty($sendIdExt) or $sendIdExt='1'"
            >Control Act: authorOrPerformer/*/AssignedDevice/id. Applicatie-id <value-of select="$autIdExt"/> komt niet overeen met Transmission-wrapper sender <value-of select="$sendIdExt"/>.</assert>
            
        <assert role="error" test="not(@root='2.16.840.1.113883.2.4.6.6' and @extension='1' and following-sibling::hl7:Organization)"
            >Control Act: authorOrPerformer/*/AssignedDevice/id. De verantwoordelijke organisatie voor de ZIM moet niet worden meegegeven</assert>
    </rule>
    
    <rule context="$element/hl7:authorOrPerformer/hl7:participant/hl7:AssignedDevice/hl7:code">
        <extends rule="CV"/>
    </rule>
    
    <rule context="$element/hl7:authorOrPerformer/hl7:participant/hl7:AssignedDevice/hl7:Organization/hl7:id">
        <extends rule="II"/>
        
        <assert role="warning" test="@root='2.16.528.1.1007.3.3' or @root='2.16.840.1.113883.2.4.3.11.25' or (@root='2.16.840.1.113883.2.4.3.11' and @extension='7') or (@root ='2.16.528.1.1007' and @extension='4')"
            >Control Act: authorOrPerformer/*/AssignedDevice/Organization/id heeft onbekende waarde '@root=&quot;<value-of select="@root"/>&quot; @extension=&quot;<value-of select="@extension"/>&quot; @nullFlavor=&quot;<value-of select="@nullFlavor"/>&quot;'. Dit is geen GBZ (2.16.528.1.1007.3.3), GBO/GBP (2.16.840.1.113883.2.4.3.11.25), GBK (2.16.840.1.113883.2.4.3.11 / 7), SBV_Z (2.16.528.1.1007 / 4)</assert>
        
        <assert test="not(@root) or ../hl7:name"
            >Control Act: authorOrPerformer/*/AssignedDevice/Organization/name is verplicht voor GBx organisaties.</assert>
    </rule>
    
    <rule context="$element/hl7:authorOrPerformer/hl7:participant/hl7:AssignedDevice/hl7:Organization/hl7:code">
        <extends rule="CV"/>
    </rule>
    
    <rule context="$element/hl7:authorOrPerformer/hl7:participant/hl7:AssignedDevice/hl7:Organization/hl7:name">
        <extends rule="ON"/>
    </rule>
    
    <title>ControlActProcess/overseer</title>
    <rule context="$element/hl7:overseer">
        <assert role="error" test="@typeCode='RESP'"
            >Control Act: overseer/@typeCode moet RESP zijn</assert>
    </rule>
    
    <rule context="$element/hl7:overseer/hl7:noteText">
        <assert role="warning" test="false()"
            ><value-of select="local-name(..)"/>/<value-of select="local-name()"/> niet gebruiken</assert>
    </rule>
    <rule context="$element/hl7:overseer/hl7:time">
        <extends rule="IVL_TS"/>
    </rule>
    <rule context="$element/hl7:overseer/hl7:modeCode">
        <assert role="warning" test="false()"
            ><value-of select="local-name(..)"/>/<value-of select="local-name()"/> niet gebruiken</assert>
    </rule>
    <rule context="$element/hl7:overseer/hl7:signatureCode">
        <assert role="warning" test="false()"
            ><value-of select="local-name(..)"/>/<value-of select="local-name()"/> niet gebruiken</assert>
    </rule>
    <rule context="$element/hl7:overseer/hl7:signatureText">
        <assert role="warning" test="false()"
            ><value-of select="local-name(..)"/>/<value-of select="local-name()"/> niet gebruiken</assert>
    </rule>
    
    <title>ControlActProcess/overseer/AssignedPerson en ControlActProcess/overseer/assignedEntity</title>
    <rule context="$element/hl7:overseer//hl7:*[local-name()='AssignedPerson' or local-name()='assignedEntity']">
        <assert role="error" test="hl7:id[@root='2.16.528.1.1007.3.1' or @root='2.16.840.1.113883.2.4.6.3']"
            >Control Act: overseer/*/<value-of select="local-name(.)"/>/id. Tenminste één id moet als root 2.16.528.1.1007.3.1 (UZI), 2.16.840.1.113883.2.4.6.3 (BSN) hebben</assert>
        <assert role="error" test="hl7:code"
            >Control Act: overseer/*/<value-of select="local-name(.)"/>/code is verplicht</assert>

        <assert role="error" test="not(hl7:id[@root='2.16.528.1.1007.3.1']) or hl7:assignedPrincipalChoiceList/hl7:assignedPerson/hl7:name"
            >Control Act: overseer/*/<value-of select="local-name(.)"/>/name is verplicht</assert>
        <assert role="error" test="not(hl7:id[@root='2.16.528.1.1007.3.1']) or hl7:Organization/hl7:id[@root='2.16.528.1.1007.3.3' and @extension]"
            >Control Act: overseer/*/<value-of select="local-name(.)"/>/Organization/id moet de zorgaanbieder van de persoon identificeren</assert>
      <!--<assert role="error" test="not(hl7:id[@root='2.16.840.1.113883.2.4.6.3']) or hl7:Organization/hl7:id[@root='2.16.840.1.113883.2.4.3.11.25']"
            >Control Act: overseer/*/<value-of select="local-name(.)"/>/Organization/id/@root moet '2.16.840.1.113883.2.4.3.11.25' bevatten</assert>
        -->
        <assert role="error" test="not(hl7:id[@root='2.16.528.1.1007.3.1']) or hl7:Organization/hl7:name"
            >Control Act: overseer/*/<value-of select="local-name(.)"/>/Organization/name moet de zorgaanbiedernaam bevatten</assert>
        
        <assert role="error" test="not(hl7:id[@root='2.16.528.1.1007.3.1']) or hl7:Organization/hl7:addr/hl7:city"
            >Control Act: overseer/*/<value-of select="local-name(.)"/>/Organization/addr moet tennminste de vestigingsplaats bevatten</assert>
    </rule>
    
    <rule context="$element/hl7:overseer//hl7:*[local-name()='AssignedPerson' or local-name()='assignedEntity']/hl7:id">
        <extends rule="II"/>
        <assert role="error" test="@root='2.16.528.1.1007.3.1' or @root='2.16.840.1.113883.2.4.6.3' or @root='2.16.840.1.113883.2.4.6.1'"
            >Control Act: overseer//<value-of select="local-name(..)"/>/id. @root moet 2.16.528.1.1007.3.1 (UZI), 2.16.840.1.113883.2.4.6.3 (BSN), of  or 2.16.840.1.113883.2.4.6.1 (AGB) zijn</assert>
        
        <assert role="error" test="not(@root='2.16.840.1.113883.2.4.6.3') or 
            following-sibling::hl7:code[@codeSystem='2.16.840.1.113883.2.4.3.11.8'][@code='P'] or
            following-sibling::hl7:code[@codeSystem='2.16.840.1.113883.2.4.3.11.6']"
            >Control Act: overseer//<value-of select="local-name(..)"/>/code/@code moet "P" (Patiënt) zijn of een geldige waarde uit RoleCodeWettelijkeVertegenwoordigerNL</assert>
    </rule>
        
        
    <rule context="$element/hl7:overseer//hl7:*[local-name()='AssignedPerson' or local-name()='assignedEntity']/hl7:code">
        <extends rule="CE"/>
    </rule>
    
    <rule context="$element/hl7:overseer//hl7:*[local-name()='AssignedPerson' or local-name()='assignedEntity']/hl7:telecom">
        <extends rule="TEL"/>
    </rule>
    
    <rule context="$element/hl7:overseer//hl7:*[local-name()='AssignedPerson' or local-name()='assignedEntity']/hl7:assignedPrincipalChoiceList/hl7:assignedPerson/hl7:name">
        <extends rule="PN"/>
    </rule>
    
    <rule context="$element/hl7:overseer//hl7:*[local-name()='AssignedPerson' or local-name()='assignedEntity']/hl7:Organization/hl7:id">
        <extends rule="II"/>
        <let name="overseerRoot" value="@root"/>
        <let name="overseerExt" value="@extension"/>
        <let name="authorExt" value="ancestor::hl7:*[hl7:authorOrPerformer]/hl7:authorOrPerformer//hl7:Organization/hl7:id[@root=$overseerRoot]/@extension"/>
        <assert role="error" test="@nullFlavor or $authorExt=$overseerExt or ancestor::hl7:*[hl7:authorOrPerformer]/hl7:authorOrPerformer//hl7:AssignedDevice"
            >Control Act: overseer//<value-of select="local-name(../..)"/>/Organization/id. Organisatie van de overseer (<value-of select="$overseerRoot"/>#<value-of select="$overseerExt"/>) moet gelijk zijn aan die van de authorOrPerformer (<value-of select="$authorExt"/>)</assert>
    </rule>
    
    <rule context="$element/hl7:overseer//hl7:*[local-name()='AssignedPerson' or local-name()='assignedEntity']/hl7:Organization/hl7:code">
        <extends rule="CE"/>
    </rule>
    
    <rule context="$element/hl7:overseer//hl7:*[local-name()='AssignedPerson' or local-name()='assignedEntity']/hl7:Organization/hl7:telecom">
        <extends rule="TEL"/>
    </rule>
    
    <rule context="$element/hl7:overseer//hl7:*[local-name()='AssignedPerson' or local-name()='assignedEntity']/hl7:Organization/hl7:name">
        <extends rule="ON"/>
    </rule>
    
    <rule context="$element/hl7:overseer//hl7:*[local-name()='AssignedPerson' or local-name()='assignedEntity']/hl7:Organization/hl7:addr">
        <extends rule="AD"/>
    </rule>
</pattern>
