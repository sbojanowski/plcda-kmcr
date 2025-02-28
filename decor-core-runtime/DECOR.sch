<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:fhir="http://hl7.org/fhir" xmlns:sqf="http://www.schematron-quickfix.com/validator/process" xmlns:xs="http://www.w3.org/2001/XMLSchema" xml:lang="en-US" queryBinding="xslt2">
    <sch:ns uri="http://purl.oclc.org/dsdl/schematron" prefix="sch"/>
    <sch:ns uri="http://www.w3.org/2001/XMLSchema" prefix="xs"/>
    
    <sch:let name="allDECOR" value="//decor[1] | //decor-excerpt[1]"/>
    
    <sch:let name="isDecorCompiled" value="exists($allDECOR[@versionDate])"/>
    <sch:let name="deeplinkprefixservices" value="$allDECOR/@deeplinkprefixservices"/>
    <sch:let name="projectCompileLanguage" value="$allDECOR/@language"/>
    <sch:let name="projectDefaultLanguage" value="$allDECOR/project/@defaultLanguage"/>
    <sch:let name="projectLanguages" value="$allDECOR/project/name/@language"/>
    <sch:let name="projectId" value="$allDECOR/project/@id"/>
    <sch:let name="projectPrefix" value="$allDECOR/project/@prefix"/>
    <sch:let name="statusCodesInactive" value="('deprecated', 'cancelled', 'inactive', 'rejected', 'retired')"/>
    <sch:let name="statusCodesInactiveFinal" value="('deprecated', 'cancelled', 'inactive', 'rejected', 'retired','final','active')"/>
    
    <sch:let name="allDatasets" value="$allDECOR/datasets/dataset"/>
    <sch:let name="allDatasetConcepts" value="$allDatasets//concept[not(ancestor::history | ancestor::conceptList)]"/>
    <sch:let name="allDatasetConceptLists" value="$allDatasetConcepts/valueDomain/conceptList"/>
    <sch:let name="allDatasetConceptListConcepts" value="$allDatasetConceptLists/concept"/>
    <sch:let name="allValueSets" value="$allDECOR/terminology/valueSet"/>
    <sch:let name="allCodeSystems" value="$allDECOR/terminology/codeSystem"/>
    <sch:let name="allTerminologyAssociations" value="$allDECOR/terminology/terminologyAssociation"/>
    <sch:let name="allScenarioActors" value="$allDECOR/scenarios/actors/actor"/>
    <sch:let name="allScenarios" value="$allDECOR/scenarios/scenario"/>
    <sch:let name="allTransactions" value="$allDECOR/scenarios//transaction"/>
    <sch:let name="allTransactionRepresentingTemplates" value="$allDECOR/scenarios//representingTemplate"/>
    <sch:let name="allIDs" value="$allDECOR/ids"/>
    <sch:let name="allIdentifierAssociations" value="$allDECOR/ids/identifierAssociation"/>
    <sch:let name="allTemplates" value="$allDECOR/rules/template"/>
    <sch:let name="allTemplateAssociations" value="$allDECOR/rules/templateAssociation"/>
    <sch:let name="allQuestionnaires" value="$allDECOR/rules/questionnaire"/>
    <sch:let name="allQuestionnaireAssociations" value="$allDECOR/rules/questionnaireAssociation"/>
    <sch:let name="allIssues" value="$allDECOR/issues/issue"/>
    
    <sch:let name="oidNullFlavor" value="'2.16.840.1.113883.5.1008'"/>
    
    <!-- pattern definitions -->
    <sch:let name="INTdigits" value="'^-?[1-9]\d*$|^+?\d*$'"/>
    <sch:let name="REALdigits" value="'^[-+]?\d*\.?[0-9]+([eE][-+]?\d+)?$'"/>
    <sch:let name="OIDpattern" value="'^[0-2](\.(0|[1-9]\d*))*$'"/>
    <sch:let name="RUIDpattern" value="'^[A-Za-z][A-Za-z\d\-]*$'"/>
    <!-- Abstract datatypes 2.15.1
        The literal form for the UUID is defined according to the original specification of the UUID. 
        However, because the HL7 UIDs are case sensitive, for use with HL7, the hexadecimal digits A-F 
        in UUIDs must be converted to upper case.
        
        This being said: if we were to hold current implementations to this idea, then a lot would be 
        broken and not even the official HL7 datatypes check this requirement. Hence we knowingly allow 
        lower-case a-f.
    -->
    <sch:let name="UUIDpattern" value="'^[A-Fa-f\d]{8}-[A-Fa-f\d]{4}-[A-Fa-f\d]{4}-[A-Fa-f\d]{4}-[A-Fa-f\d]{12}$'"/>
    <sch:let name="TSpattern" value="'^[0-9]{4,14}'"/>
    
    <!-- Validate DECOR -->
    <sch:pattern>
        <!-- ++++++++++++++++++++++ -->
        <!-- +++    PROJECT     +++ -->
        <!-- ++++++++++++++++++++++ -->
        <sch:title>Validate Project</sch:title>
        <sch:rule context="project/name">
            <sch:extends rule="FreeFormMarkupWithLanguage"/>
        </sch:rule>
        <sch:rule context="project/desc">
            <sch:extends rule="FreeFormMarkupWithLanguage"/>
        </sch:rule>
        
        <sch:rule context="project/copyright">
            <sch:assert role="error" test="@years[string-length() gt 0]"
                >ERROR: At least one year SHALL be present in copyright by <sch:value-of select="@by"/></sch:assert>
        </sch:rule>
        
        <sch:rule context="project/buildingBlockRepository">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;buildingBlockRepository ', string-join(for $att in @* 
                return 
                concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')"/>
            <sch:assert role="error" sqf:fix="addSlashToURL" test="substring(@url, string-length(@url), 1) = '/'"
                >ERROR: Project repository URL "<sch:value-of select="@url"/>" SHALL end with "/".<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" sqf:fix="addHyphenToIdent" test="not(@ident) or @format[not(. = 'decor')] or substring(@ident, string-length(@ident), 1) = '-'"
                >ERROR: Project repository ident "<sch:value-of select="@ident"/>" SHALL end with "-".<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="@format[not(. = 'decor')] or @ident"
                >ERROR: Project repository ident SHALL have a value when @format = 'decor' (this is the default value).<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(@format = 'fhir') or @ident"
                >ERROR: Project repository ident SHALL have a value when @format = 'fhir'.<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        
        <sch:rule context="project/release/note">
            <sch:extends rule="FreeFormMarkupWithLanguage"/>
        </sch:rule>
        
        <sch:rule context="project/version/desc">
            <sch:extends rule="FreeFormMarkupWithLanguage"/>
        </sch:rule>
        
        <!-- ++++++++++++++++++++++ -->
        <!-- +++      IDS       +++ -->
        <!-- ++++++++++++++++++++++ -->
        <!-- validation of unique datasets and dataset concepts is done in xs:schema. No need to repeat here -->
        <!--<sch:title>Validate Unique Dataset Concept Ids</sch:title>-->
        <!--<sch:rule context="$allDatasetConcepts">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;concept ', string-join(for $att in ancestor-or-self::concept[1]/(@id, @ref, @name, name[string-length() gt 0][1], @displayName, @effectiveDate, @flexibility)
                return
                concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')"/>
            <sch:let name="deid" value="@id"/>
            <sch:let name="deed" value="@effectiveDate"/>
            <sch:assert role="error" test="count($allDatasetConcepts[@id = $deid][@effectiveDate = $deed]) = 1"
                >ERROR: The <sch:name/>/@id '<sch:value-of select="$deid"/>' effectiveDate='<sch:value-of select="$deed"/>' SHALL be unique.<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>-->
        <sch:title>Validate Ids</sch:title>
        <sch:let name="allTypes"      value="for $t in ('DS','DE','SC','TR','CS','IS','AC','CL','EL','TM','VS','RL','TX','SX','EX','QX','CM','MP','SD','QQ','QR','IG') return $t"/>
        <sch:let name="allExtensions" value="for $t in ('1' ,'2' ,'3' ,'4' ,'5' ,'6' ,'7' ,'8' ,'9' ,'10','11','16','17','18','19','20','21','24','26','27','28','29') return $t"/>
        <sch:let name="allTypesCount" value="count($allTypes)"/>
        <sch:rule context="ids">
            <sch:let name="locationContext" value="concat(' | Location &lt;ids ', '/&gt;')"/>
            <sch:let name="idsBaseIdTypes" value="distinct-values(baseId/@type)"/>
            <sch:let name="idsDefaultBaseIdTypes" value="distinct-values(defaultBaseId/@type)"/>
            <sch:let name="idsBaseIdTypesMissing" value="$allTypes[not(. = $idsBaseIdTypes)]"/>
            <sch:let name="idsDefaultBaseIdTypesMissing" value="$allTypes[not(. = $idsDefaultBaseIdTypes)]"/>
            <sch:assert role="warning" sqf:fix="addMissingBaseIds" test="empty($idsBaseIdTypesMissing)"
                >WARNING: Project SHOULD define a baseId for every possible type. Every missing type might lead to unexpected results. Expected '<sch:value-of select="$allTypesCount"/>', found '<sch:value-of select="count($idsBaseIdTypes)"/>'. Missing '<sch:value-of select="$idsBaseIdTypesMissing"/>'.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" sqf:fix="addMissingDefaultBaseIds" test="empty($idsDefaultBaseIdTypesMissing)"
                >ERROR: Project SHALL define a defaultBaseId for every possible type. Every missing type might lead to unexpected results. Expected '<sch:value-of select="$allTypesCount"/>', found '<sch:value-of select="count($idsDefaultBaseIdTypes)"/>'. Missing '<sch:value-of select="$idsDefaultBaseIdTypesMissing"/>'.<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        
        <sch:title>Validate baseId</sch:title>
        <sch:rule context="ids/baseId">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;baseId ', string-join(for $att in @*
                return
                concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')"/>
            <sch:assert role="error" sqf:fix="addHyphenToPrefix" test="substring(@prefix, string-length(@prefix), 1) = '-'"
                >ERROR: baseId prefix "<sch:value-of select="@prefix"/>" SHALL end with "-".<sch:value-of select="$locationContext"/></sch:assert>
            <sch:let name="baseId" value="@id"/>
            <sch:let name="baseType" value="@type"/>
            <sch:let name="basePrefix" value="@prefix"/>
            <!--
                We're in transition some project will be old style, some new.
                Old style:
                    <baseId id="1.2.3" type="DS" prefix="xyz"/>
                    <defaultBaseId id="1.2.3" type="DS"/>
                New style:
                    <baseId id="1.2.3" type="DS" prefix="xyz" default="true"/>
            -->
            <!--Support old style-->
            <sch:assert role="error" sqf:fix="addMissingDefaultBaseIds" test="not(../defaultBaseId) or count(parent::ids/defaultBaseId[@type = $baseType]) = 1"
                >ERROR: Exactly one of type '<sch:value-of select="$baseType"/>' SHALL be marked as default base id.<sch:value-of select="$locationContext"/></sch:assert>
            <!--Support new style-->
            <sch:assert role="error" test="../defaultBaseId or count(parent::ids/baseId[@type = $baseType][@default = 'true']) = 1"
                >ERROR: Exactly one of type '<sch:value-of select="$baseType"/>' SHALL be marked with @default='true'.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="warning" test="count(../baseId[@prefix = $basePrefix]) = 1"
                >WARNING: The baseId/@prefix "<sch:value-of select="$basePrefix"/>" with type "<sch:value-of select="$baseType"/>" is not unique. This could lead to ambiguous situations if people use the display version of an id.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(@id = preceding-sibling::baseId/@id)"
                >ERROR: <sch:name/> "<sch:value-of select="@id"/>" SHALL be unique.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(../defaultBaseId[@id = $baseId]) or ../defaultBaseId[@id = $baseId][@type = $baseType]"
                >ERROR: <sch:name/> "<sch:value-of select="$baseId"/>" has different type "<sch:value-of select="$baseType"/>" than defaultBaseId type "<sch:value-of select="../defaultBaseId[@id = $baseId]/@type"/>". This will lead to ambiguous situations if people use the display version of an id.<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        
        <sch:title>Validate defaultBaseId type</sch:title>
        <sch:rule context="ids/defaultBaseId">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;defaultBaseId ', string-join(for $att in @*
                return
                concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')"/>
            <sch:let name="idType" value="@type"/>
            <sch:assert role="error" test="not(preceding-sibling::defaultBaseId/@type = @type)"
                >ERROR: <sch:name/> type "<sch:value-of select="@type"/>" SHALL be unique.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(@id = preceding-sibling::defaultBaseId/@id)"
                >ERROR: <sch:name/> "<sch:value-of select="@id"/>" SHALL be unique.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="@id = ../baseId[@type = $idType]/@id"
                >ERROR: <sch:name/> type "<sch:value-of select="@type"/>" and id "<sch:value-of select="@id"/>" SHALL match a baseId of the same type.<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        
        <!-- ++++++++++++++++++++++ -->
        <!-- +++    DATASETS    +++ -->
        <!-- ++++++++++++++++++++++ -->
        <sch:title>Validate Unique Dataset ConceptList Ids</sch:title>
        <sch:title>Validate Unique Dataset ConceptList Concept Ids</sch:title>
        <sch:rule context="datasets">
            <sch:let name="duplicateConceptListIds" value="
                for $id in $allDatasetConceptLists[not(ancestor::history)]/@id
                return if (count($allDatasetConceptLists[not(ancestor::history)][@id = $id]) gt 1) then $id else ()"/>
            <sch:assert role="error" test="$isDecorCompiled or empty($duplicateConceptListIds)"
                >ERROR: Project SHALL NOT have duplicate conceptList/@id values. Found <sch:value-of select="count(distinct-values($duplicateConceptListIds))"/>: '<sch:value-of select="string-join(distinct-values($duplicateConceptListIds), ', ')"/>'.</sch:assert>
            <sch:let name="duplicateConceptListConceptIds" value="
                for $id in $allDatasetConceptListConcepts[not(ancestor::history)]/@id
                return if (count($allDatasetConceptListConcepts[not(ancestor::history)][@id = $id]) gt 1) then $id else ()"/>
            <sch:assert role="error" test="$isDecorCompiled or empty($duplicateConceptListConceptIds)"
                >ERROR: Project SHALL NOT have duplicate conceptList/concept/@id values. Found <sch:value-of select="count(distinct-values($duplicateConceptListConceptIds))"/>: '<sch:value-of select="string-join(distinct-values($duplicateConceptListConceptIds), ', ')"/>'.</sch:assert>
        </sch:rule>
        
        <sch:title>Validate Dataset</sch:title>
        <sch:rule context="dataset[not(ancestor-or-self::*[@statusCode = $statusCodesInactive])]">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;dataset ', string-join(for $att in (@id, @ref, @name, name[string-length() gt 0][1], @displayName, @effectiveDate, @flexibility, ancestor-or-self::dataset[1]/@url[not(. = $deeplinkprefixservices)], ancestor-or-self::dataset[1]/@ident)
                return
                concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')"/>
            <sch:assert role="error" test="(@id and @effectiveDate) or @ref"
                >ERROR: <sch:name/> SHALL have an @id and @effectiveDate, or a @ref.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(@id and @ref)"
                >ERROR: <sch:name/> SHALL NOT have both @id and @ref.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(@canonicalUri and @ref)"
                >ERROR: <sch:name/> SHALL NOT have both @canonicalUri and @ref.<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        
        <sch:rule context="dataset[not(ancestor-or-self::*[@statusCode = $statusCodesInactive])]/name">
            <sch:extends rule="FreeFormMarkupWithLanguage"/>
        </sch:rule>
        <sch:rule context="dataset[not(ancestor-or-self::*[@statusCode = $statusCodesInactive])]/desc">
            <sch:extends rule="FreeFormMarkupWithLanguage"/>
        </sch:rule>
        
        <sch:title>Validate Dataset Concept</sch:title>
        <sch:rule context="dataset//concept[not(ancestor::history | ancestor::conceptList | ancestor-or-self::*[@statusCode = $statusCodesInactive])]">
            <sch:let name="dsid" value="ancestor::dataset[1]/@id"/>
            <sch:let name="dsed" value="ancestor::dataset[1]/@effectiveDate"/>
            <sch:let name="dsedmax" value="max($allDatasets[@id = $dsid]/xs:dateTime(@effectiveDate))"/>
            
            <sch:let name="de" value="."/>
            <sch:let name="deid" value="@id"/>
            <sch:let name="deed" value="@effectiveDate"/>
            <sch:let name="deedmax" value="max($allDatasetConcepts[@id = $dsid]/xs:dateTime(@effectiveDate))"/>
            <sch:let name="isInTransactionWithConnectedTemplate" value="
                if ($dsed = $dsedmax) then 
                    $allTransactionRepresentingTemplates[@sourceDataset = $dsid][@sourceDatasetFlexibility = $dsed or not(@sourceDatasetFlexibility castable as xs:dateTime)][@ref]/concept[@ref = $deid][not(ancestor::*/@statusCode = $statusCodesInactive)]
                else
                    $allTransactionRepresentingTemplates[@sourceDataset = $dsid][@sourceDatasetFlexibility = $dsed][@ref]/concept[@ref = $deid][not(ancestor::*/@statusCode = $statusCodesInactive)]
                "/>
            <sch:let name="isInTemplate" value="$allTemplateAssociations/concept[@ref = $deid][@effectiveDate = $deed]"/>
            <sch:let name="isInTransactionWithConnectedQuestionnaire" value="
                if ($dsed = $dsedmax) then 
                $allTransactionRepresentingTemplates[@sourceDataset = $dsid][@sourceDatasetFlexibility = $dsed or not(@sourceDatasetFlexibility castable as xs:dateTime)][@representingQuestionnaire]/concept[@ref = $deid][not(ancestor::*/@statusCode = $statusCodesInactive)]
                else
                $allTransactionRepresentingTemplates[@sourceDataset = $dsid][@sourceDatasetFlexibility = $dsed][@representingQuestionnaire]/concept[@ref = $deid][not(ancestor::*/@statusCode = $statusCodesInactive)]
                "/>
            <sch:let name="isInQuestionnaire" value="$allQuestionnaireAssociations/concept[@ref = $deid][@effectiveDate = $deed]"/>
            
            <sch:let name="inhbyid1" value="if ($de[@type]) then () else $allDatasetConcepts[@id = $de/inherit/@ref]"/>
            <sch:let name="inhc1" value="if ($de[@type]) then () else if ($de/inherit/@effectiveDate) then $inhbyid1[@effectiveDate = $de/inherit/@effectiveDate] else $inhbyid1[@effectiveDate = max($inhbyid1/xs:dateTime(@effectiveDate))]"/>
            <sch:let name="inhbyid2" value="if ($de[@type]) then () else $allDatasetConcepts[@id = $inhc1/inherit/@ref]"/>
            <sch:let name="inhc2" value="if ($de[@type]) then () else if ($inhc1/inherit/@effectiveDate) then $inhbyid2[@effectiveDate = $inhc1/inherit/@effectiveDate] else $inhbyid2[@effectiveDate = max($inhbyid2/xs:dateTime(@effectiveDate))]"/>
            <sch:let name="inhbyid3" value="if ($de[@type]) then () else $allDatasetConcepts[@id = $inhc2/inherit/@ref]"/>
            <sch:let name="inhc3" value="if ($de[@type]) then () else if ($inhc2/inherit/@effectiveDate) then $inhbyid3[@effectiveDate = $inhc2/inherit/@effectiveDate] else $inhbyid3[@effectiveDate = max($inhbyid3/xs:dateTime(@effectiveDate))]"/>
            <sch:let name="detype" value="($de, $inhc1, $inhc2, $inhc3)[@type][1]"/>
            <sch:let name="dename" value="($de, $inhc1, $inhc2, $inhc3)[name][1]/name[not(. = '')][1]"/>
            
            <sch:let name="locationContext" value="
                concat(' | Location &lt;concept ', string-join((
                    for $att in ancestor-or-self::concept[1]/(@id, @ref, $detype/@type, $dename, @displayName, @effectiveDate, @flexibility, @statusCode, @versionLabel, ancestor-or-self::dataset[1]/@url[not(. = $deeplinkprefixservices)], ancestor-or-self::dataset[1]/@ident)
                    return
                        concat(name($att), '=&#34;', $att, '&#34;'),
                    for $att in ancestor-or-self::dataset/(@id, @effectiveDate, @versionLabel, @statusCode, name[not(. = '')][1])
                    return
                        concat('dataset', upper-case(substring(name($att), 1, 1)), substring(name($att), 2), '=&#34;', $att, '&#34;')
                ), ' '), '/&gt;')"/>
            
            <sch:assert role="error" test="$isDecorCompiled or not(inherit and contains)"
                >ERROR: <sch:name/> SHALL NOT have both inherit and contains.<sch:value-of select="$locationContext"/></sch:assert>
            <!-- if not inherit/@ref then @type and @statusCode SHALL be present -->
            <sch:assert role="error" test="@type or (inherit | contains)"
                >ERROR: <sch:name/> SHALL have @type if the concept does not inherit or reference another concept (contains).<sch:value-of select="$locationContext"/></sch:assert>
            <!-- if inherit/@ref then @type is prohibited -->
            <sch:assert role="error" test="$isDecorCompiled or not(@type and (inherit | contains))" sqf:fix="removeTypeAttribute"
                >ERROR: <sch:name/> SHALL NOT have @type if concept inherits or is a reference.<sch:value-of select="$locationContext"/></sch:assert>
            <!-- if inherit/@ref then @effectiveDate is required -->
            <sch:assert role="error" test="not(inherit) or (inherit[@ref][@effectiveDate])"
                >ERROR: <sch:name/>/inherit SHALL have both @ref and @effectiveDate.<sch:value-of select="$locationContext"/></sch:assert>
            <!-- if not inherit then name and desc SHALL be present-->
            <sch:assert role="error" test="inherit | contains | .[name]"
                >ERROR: <sch:name/> SHALL have at least name, or have an inherit or contains.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(contains) or not(* except (comment | concept | rationale | contains | history)) or $isDecorCompiled"
                >ERROR: <sch:name/> SHALL only have a comment when it has a contains.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(inherit) or not(* except (comment | concept | rationale | inherit | history)) or $isDecorCompiled"
                >ERROR: <sch:name/> SHALL only have a comment and/or child concepts when it has a inherit.<sch:value-of select="$locationContext"/></sch:assert>
            
            <sch:let name="emptynames" value="name[string-length(normalize-space()) = 0]/@language"/>
            <sch:let name="emptydescriptions" value="desc[string-join(.//text()/normalize-space(), '') = '']/@language"/>
            <sch:let name="missingnames" value="$projectLanguages[not(. = $de/name/@language)]"/>
            <sch:let name="missingdescriptions" value="$projectLanguages[not(. = $de/desc/@language)]"/>
            <!-- if name then it shall be non empty -->
            <sch:report role="error" test="not(inherit | contains) and $emptynames"
                >ERROR: <sch:name/> name SHALL NOT be empty. Found empty for language(s): <sch:value-of select="string-join($emptynames, ', ')"/>.<sch:value-of select="$locationContext"/></sch:report>
            <sch:report role="error" test="(inherit | contains) and $emptynames"
                >ERROR: <sch:name/> SHALL have at least one non-empty name in a compiled project. Empty names are usually a sign that the inherit or contains did not resolve.<sch:value-of select="$locationContext"/></sch:report>
            <!-- if desc then it shall be non empty -->
            <sch:report role="warning" test="not($de[@statusCode = 'final']) and $emptydescriptions"
                >WARNING: <sch:name/> desc (definition) SHOULD NOT be empty. Found empty for language(s): <sch:value-of select="string-join($emptydescriptions, ', ')"/><sch:value-of select="$locationContext"/>
            </sch:report>
            
            <!--<sch:assert role="warning" test="$isDecorCompiled or not((name and empty($missingnames)) or (desc and empty($missingdescriptions)))"
                >WARNING: <sch:name/> <sch:value-of select="$dename"/> SHOULD have a name and desc in all project languages. Found: name <sch:value-of select="name/@language"/> and desc <sch:value-of select="desc/@language"/>. Missing: name <sch:value-of select="$missingnames"/> and desc <sch:value-of select="$missingdescriptions"/>.<sch:value-of select="$locationContext"/></sch:assert>-->
            <sch:assert role="warning" test="$isDecorCompiled or $de[@statusCode = 'final'] or empty(name) or empty($missingnames)"
                >WARNING: <sch:name/> SHOULD have a name in all project languages. Found: <sch:value-of select="name/@language"/>. Missing: <sch:value-of select="$missingnames"/>.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="warning" test="$isDecorCompiled or $de[@statusCode = 'final'] or not(empty($missingnames)) or empty(desc) or empty($missingdescriptions)"
                >WARNING: <sch:name/> SHOULD have a desc in all project languages. Found: <sch:value-of select="desc/@language"/>. Missing: <sch:value-of select="$missingdescriptions"/>.<sch:value-of select="$locationContext"/></sch:assert>
            
            <sch:assert role="info" test="not($isDecorCompiled) or $projectCompileLanguage = '*' or name[@language = $projectCompileLanguage]"
                >INFO: <sch:name/> SHOULD have a name in the language it was compiled for (<sch:value-of select="$projectCompileLanguage"/>). Found: <sch:value-of select="name/@language"/>.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="info" test="not($isDecorCompiled) or $de[@statusCode = 'final'] or $projectCompileLanguage = '*' or empty(desc) or desc[@language = $projectCompileLanguage]"
                >INFO: <sch:name/> SHOULD have a desc in the language it was compiled for (<sch:value-of select="$projectCompileLanguage"/>). Found: <sch:value-of select="desc/@language"/>.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:report role="info" test="$isDecorCompiled and $projectCompileLanguage = '*' and not(empty($missingnames))"
                >INFO: <sch:name/> SHOULD have a name in all project languages because that's what it was compiled for. Found: <sch:value-of select="name/@language"/>. Missing: <sch:value-of select="$missingnames"/>.<sch:value-of select="$locationContext"/></sch:report>
            <sch:report role="info" test="$isDecorCompiled and not($de[@statusCode = 'final']) and $projectCompileLanguage = '*' and not(empty($missingdescriptions))"
                >INFO: <sch:name/> SHOULD have a desc in all project languages because that's what it was compiled for. Found: <sch:value-of select="desc/@language"/>. Missing: <sch:value-of select="$missingdescriptions"/>.<sch:value-of select="$locationContext"/></sch:report>
            
            <sch:assert role="warning" test="not($detype[@type = 'group']) or $de[@statusCode = 'final'] or ($detype[@type = 'group'] and concept and not(valueDomain)) or contains"
                >WARNING: <sch:name/> of (inherited) type group SHOULD have concept child definition(s).<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not($detype[@type = 'item']) or ($detype[@type = 'item'] and not(concept)) or contains"
                >ERROR: <sch:name/> of (inherited) type item SHALL NOT have concept child definition(s).<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not((inherit | contains) and valueDomain) or $isDecorCompiled"
                >ERROR: <sch:name/> of inherits or references another concept SHALL NOT have a value domain definition.<sch:value-of select="$locationContext"/></sch:assert>
            <!--<sch:assert role="info" test="not($inhc/inherit)" sqf:fix="replaceInheritWithIdOfOriginalConcept"
                >INFO: This concept inherits from a concept that inherits. For performance reasons it SHOULD inherit from the original concept ref="<sch:value-of select="$inhc/inherit/@ref"/>" effectiveDate="<sch:value-of select="$inhc/inherit/@effectiveDate"/>".<sch:value-of select="$locationContext"/></sch:assert>-->
            
            <sch:assert role="info" test="$isDecorCompiled or (not($isInTransactionWithConnectedTemplate and $allTemplates) or $isInTemplate)"
                >INFO: <sch:name/><sch:value-of select="if ($detype/@type) then concat(' (type=''', $detype/@type, ''')') else ()"/> is used in at least one transaction connected to a template, but does not have a templateAssociation. This 'may' resolve itself in compilation.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not($isDecorCompiled) or (not($isInTransactionWithConnectedTemplate and $allTemplates and $allTemplates[empty(usage)]) or $isInTemplate)"
                >ERROR: <sch:name/><sch:value-of select="if ($detype/@type) then concat(' (type=''', $detype/@type, ''')') else ()"/> is used in at least one transaction connected to a template, but does not have a templateAssociation.<sch:value-of select="$locationContext"/></sch:assert>
            
            <!--<sch:let name="associatedTemplates" value="$allTemplates[concat(@id, @effectiveDate) = $isInTemplate/../concat(@templateId, @effectiveDate)]"/>
            <sch:let name="missingtransactions" value="
                for $transaction in $isInTransactionWithConnectedTemplate/ancestor-or-self::transaction[1] 
                return 
                    if ($associatedTemplates/usage//transactionAssociation[concat(@transactionId, @transactionEffectiveDate) = $transaction/concat(@id, @effectiveDate)]) then () else concat($transaction/@id, ' ''', data($transaction/(name[@language = $projectDefaultLanguage], name)[1]), '''')"/>
            <sch:report role="error" test="$isInTransactionWithConnectedTemplate and $allTemplates[usage] and $missingtransactions"
                >ERROR: <sch:name/><sch:value-of select="if ($detype/@type) then concat(' (type=''', $detype/@type, ''')') else ()"/> is not associated to any template connected to the transaction<sch:value-of select="if (count($missingtransactions) gt 1) then '(s)' else ()"/> "<sch:value-of select="string-join($missingtransactions, ', ')"/>".<sch:value-of select="$locationContext"/></sch:report>-->
            
            <sch:assert role="info" test="$isDecorCompiled or (not($isInTransactionWithConnectedQuestionnaire and $allQuestionnaires) or $isInQuestionnaire)"
                >INFO: <sch:name/><sch:value-of select="if ($detype/@type) then concat(' (type=''', $detype/@type, ''')') else ()"/> is used in at least one transaction connected to a questionnaire, but does not have a questionnaireAssociation. This 'may' resolve itself in compilation.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not($isDecorCompiled) or (not($isInTransactionWithConnectedQuestionnaire and $allQuestionnaires) or $isInQuestionnaire)"
                >ERROR: <sch:name/><sch:value-of select="if ($detype/@type) then concat(' (type=''', $detype/@type, ''')') else ()"/> is used in at least one transaction connected to a questionnaire, but does not have a questionnaireAssociation.<sch:value-of select="$locationContext"/></sch:assert>
            
            
            <!-- assume this is ok when concept is final anyway, or ids match, or the final part of ids match. They would be versions of eachother and normally that would mean the older version could be deprecated when the new one came into play -->
            <sch:assert role="warning" test="$de[@statusCode = $statusCodesInactiveFinal] or $inhc1[@id = $deid] or $inhc1[tokenize(@id, '\.')[last()] = tokenize($deid, '\.')[last()]] or not($inhc1[ancestor-or-self::*/@statusCode = $statusCodesInactive])"
                >WARNING: <sch:name/> SHOULD NOT inherit from a concept that has or is under an inactive status (<sch:value-of select="$inhc1/ancestor-or-self::*[@statusCode = $statusCodesInactive][1]/@statusCode"/>).<sch:value-of select="$locationContext"/>
            </sch:assert>
            
            <sch:report role="error" test="terminologyAssociation[@expirationDate]"
                >ERROR: <sch:name/> contains <sch:value-of select="count(terminologyAssociation[@expirationDate])"/> expired terminologyAssociation(s). This constitutes a compilation error.<sch:value-of select="$locationContext"/></sch:report>
            <sch:report role="warning" test="terminologyAssociation[@strength[not(. = 'required')]][not(@valueSet)]"
                >WARNING: <sch:name/> SHOULD NOT carry a terminologyAssociation specifying a binding strength unless it concerns a value set binding.<sch:value-of select="$locationContext"/></sch:report>
            
            <sch:assert role="warning" test="not(terminologyAssociation[@valueSet]) or count(terminologyAssociation[@valueSet]) = count(valueSet)"
                >WARNING: <sch:name/> SHOULD carry as many valueSets as terminologyAssociations pointing to a valueSet. In a compiled project, references should have been resolved.<sch:value-of select="$locationContext"/></sch:assert>
            
            <sch:report role="error" test="terminologyAssociation[not(@code | @valueSet)]"
                >ERROR: <sch:name/>/terminologyAssociation SHALL have a @code or a @valueSet.<sch:value-of select="$locationContext"/></sch:report>
            <sch:report role="error" test="terminologyAssociation[@code][@valueSet]"
                >ERROR: <sch:name/>/terminologyAssociation SHALL NOT have both @code and @valueSet.<sch:value-of select="$locationContext"/></sch:report>
            <sch:report role="error" test="terminologyAssociation[@flexibility][not(@valueSet)]"
                >ERROR: <sch:name/>/terminologyAssociation SHALL NOT have @flexibility without @valueSet.<sch:value-of select="$locationContext"/></sch:report>
            <!-- prepare for FHIR canonicals, but beware: we don't know how to get $vs yet if we get one... -->
            <sch:report role="error" test="terminologyAssociation[@valueSet][not(matches(@valueSet, '^[0-9\.]+$') or starts-with(@valueSet, 'http'))]"
                >ERROR: <sch:name/>/terminologyAssociation SHALL have valueSet reference based on valueSet/@id. References by @name quickly become ambiguous.<sch:value-of select="$locationContext"/></sch:report>
        </sch:rule>
        
        <sch:rule context="dataset//concept[not(ancestor::history | ancestor::conceptList | ancestor-or-self::*[@statusCode = $statusCodesInactive])]/name">
            <sch:extends rule="FreeFormMarkupWithLanguage"/>
        </sch:rule>
        <sch:rule context="dataset//concept[not(ancestor::history | ancestor::conceptList | ancestor-or-self::*[@statusCode = $statusCodesInactive])]/desc">
            <sch:extends rule="FreeFormMarkupWithLanguage"/>
        </sch:rule>
        <sch:rule context="dataset//concept[not(ancestor::history | ancestor::conceptList | ancestor-or-self::*[@statusCode = $statusCodesInactive])]/source">
            <sch:extends rule="FreeFormMarkupWithLanguage"/>
        </sch:rule>
        <sch:rule context="dataset//concept[not(ancestor::history | ancestor::conceptList | ancestor-or-self::*[@statusCode = $statusCodesInactive])]/rationale">
            <sch:extends rule="FreeFormMarkupWithLanguage"/>
        </sch:rule>
        <sch:rule context="dataset//concept[not(ancestor::history | ancestor::conceptList | ancestor-or-self::*[@statusCode = $statusCodesInactive])]/operationalization">
            <sch:extends rule="FreeFormMarkupWithLanguage"/>
        </sch:rule>
        
        <!-- Compilation of concept/relationship element so we know what it refers to was introduced around 2019-06-21 -->
        <sch:rule context="dataset//concept[not(ancestor::history | ancestor::conceptList | ancestor-or-self::*[@statusCode = $statusCodesInactive])][ancestor::decor[@compilationDate castable as xs:dateTime]/xs:dateTime(@compilationDate) ge xs:dateTime('2019-06-21T09:00:00')]/relationship">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;concept ', string-join((
                for $att in ancestor-or-self::concept[1]/(@id, @ref, name[not(. = '')][1], @displayName, @effectiveDate, @flexibility, @statusCode, @versionLabel, ancestor-or-self::dataset[1]/@url[not(. = $deeplinkprefixservices)], ancestor-or-self::dataset[1]/@ident)
                return
                    concat(name($att), '=&#34;', $att, '&#34;'), 
                for $att in ancestor-or-self::dataset/(@id, @effectiveDate, @versionLabel, @statusCode, name[not(. = '')][1])
                return
                    concat('dataset', upper-case(substring(name($att), 1, 1)), substring(name($att), 2), '=&#34;', $att, '&#34;')
                ), ' '), '/&gt;')"/>
            <sch:assert role="warning" test="@prefix"
                >WARNING: concept has <sch:name/> that does not resolve to any concept. In a compiled project, references are expected to resolve.<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        
        <sch:title>Validate Dataset Concept List @ref</sch:title>
        <sch:rule context="dataset//valueDomain/conceptList[@ref][not(ancestor::history | ancestor::*[@statusCode = $statusCodesInactive])]">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;concept ', string-join((
                for $att in ancestor-or-self::concept[1]/(@id, @ref, name[not(. = '')][1], @displayName, @effectiveDate, @flexibility, @statusCode, @versionLabel, ancestor-or-self::dataset[1]/@url[not(. = $deeplinkprefixservices)], ancestor-or-self::dataset[1]/@ident)
                return
                    concat(name($att), '=&#34;', $att, '&#34;'), 
                for $att in ancestor-or-self::dataset/(@id, @effectiveDate, @versionLabel, @statusCode, name[not(. = '')][1])
                return
                    concat('dataset', upper-case(substring(name($att), 1, 1)), substring(name($att), 2), '=&#34;', $att, '&#34;')
                ), ' '), '/&gt;')"/>
            <sch:let name="clid" value="@ref"/>
            <sch:assert role="error" test="$allDatasetConcepts/valueDomain/conceptList[@id = $clid]"
                >ERROR: <sch:name/> ref='<sch:value-of select="$clid"/>' SHALL have a corresponding conceptList element in the same project.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(*)"
                >ERROR: <sch:name/> ref='<sch:value-of select="$clid"/>' SHALL NOT have children.<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        
        <sch:title>Validate Dataset Concept List @id</sch:title>
        <sch:rule context="dataset//valueDomain/conceptList[@id][not(ancestor::history | ancestor::*[@statusCode = $statusCodesInactive])]">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;concept ', string-join((
                for $att in ancestor-or-self::concept[1]/(@id, @ref, name[not(. = '')][1], @displayName, @effectiveDate, @flexibility, @statusCode, @versionLabel, ancestor-or-self::dataset[1]/@url[not(. = $deeplinkprefixservices)], ancestor-or-self::dataset[1]/@ident)
                return
                    concat(name($att), '=&#34;', $att, '&#34;'), 
                for $att in ancestor-or-self::dataset/(@id, @effectiveDate, @versionLabel, @statusCode, name[not(. = '')][1])
                return
                    concat('dataset', upper-case(substring(name($att), 1, 1)), substring(name($att), 2), '=&#34;', $att, '&#34;')
                ), ' '), '/&gt;')"/>
            <sch:let name="clid" value="@id"/>
            <sch:assert role="warning" test="$isDecorCompiled or $allTerminologyAssociations[@conceptId = $clid][@valueSet][not(@expirationDate)]"
                >WARNING: <sch:name/> id='<sch:value-of select="$clid"/>' SHOULD have an active terminologyAssociation for a valueSet.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="warning" test="not($isDecorCompiled) or ancestor::concept[1]/terminologyAssociation[@conceptId = $clid][@valueSet][not(@expirationDate)]"
                >WARNING: <sch:name/> id='<sch:value-of select="$clid"/>' SHOULD have an active terminologyAssociation for a valueSet compiled with the concept.<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        
        <sch:title>Validate Dataset Concept TerminologyAssociation</sch:title>
        <sch:rule context="dataset//valueDomain/conceptList/concept[@id][not(ancestor::history | ancestor::*[@statusCode = $statusCodesInactive])]">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;concept ', string-join((
                for $att in ancestor-or-self::concept[1]/(@id, @ref, name[not(. = '')][1], @displayName, @effectiveDate, @flexibility, @statusCode, @versionLabel, ancestor-or-self::dataset[1]/@url[not(. = $deeplinkprefixservices)], ancestor-or-self::dataset[1]/@ident)
                return
                    concat(name($att), '=&#34;', $att, '&#34;'), 
                for $att in ancestor-or-self::dataset/(@id, @effectiveDate, @versionLabel, @statusCode, name[not(. = '')][1])
                return
                    concat('dataset', upper-case(substring(name($att), 1, 1)), substring(name($att), 2), '=&#34;', $att, '&#34;')
                ), ' '), '/&gt;')"/>
            <sch:let name="deid" value="ancestor::concept[1]/@id"/>
            <sch:let name="clid" value="parent::conceptList/(@id | @ref)"/>
            <sch:let name="clHasTerminoloyAssocation" value="if ($isDecorCompiled) then ancestor::concept[1]/terminologyAssociation[@conceptId = $clid] else $allTerminologyAssociations[@conceptId = $clid]"/>
            <sch:let name="cid" value="@id"/>
            <sch:let name="cHasTerminoloyAssocation" value="if ($isDecorCompiled) then ancestor::concept[1]/terminologyAssociation[@conceptId = $cid] else $allTerminologyAssociations[@conceptId = $cid]"/>
            
            <sch:assert role="warning" test="$isDecorCompiled or not($clHasTerminoloyAssocation[not(@expirationDate)]) or $cHasTerminoloyAssocation[not(@expirationDate)]"
                >WARNING: conceptList/<sch:name/> '<sch:value-of select="name[1]"/>' SHOULD have an active terminologyAssociation as the conceptList has an active valueSet binding.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="warning" test="not($isDecorCompiled) or not($clHasTerminoloyAssocation[not(@expirationDate)]) or $cHasTerminoloyAssocation[not(@expirationDate)]"
                >WARNING: <sch:name/> id='<sch:value-of select="$clid"/>' SHOULD have an active terminologyAssociation compiled with the concept as the conceptList has an active valueSet binding.<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        
        <!-- ++++++++++++++++++++++ -->
        <!-- +++   SCENARIOS    +++ -->
        <!-- ++++++++++++++++++++++ -->
        <sch:title>Validate Scenario</sch:title>
        <sch:rule context="scenario[not(ancestor-or-self::*/@statusCode = $statusCodesInactive)]">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;scenario ', string-join(for $att in (@id, @ref, @name, name[string-length() gt 0][1], @displayName, @effectiveDate, @flexibility, @statusCode, @versionLabel, @url[not(. = $deeplinkprefixservices)], @ident)
                return
                concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')"/>
            <sch:extends rule="VersionAttributeConsistency"/>
        </sch:rule>
        
        <sch:rule context="scenario[not(ancestor-or-self::*/@statusCode = $statusCodesInactive)]/name">
            <sch:extends rule="FreeFormMarkupWithLanguage"/>
        </sch:rule>
        <sch:rule context="scenario[not(ancestor-or-self::*/@statusCode = $statusCodesInactive)]/desc">
            <sch:extends rule="FreeFormMarkupWithLanguage"/>
        </sch:rule>
        <sch:rule context="scenario[not(ancestor-or-self::*/@statusCode = $statusCodesInactive)]/trigger">
            <sch:extends rule="FreeFormMarkupWithLanguage"/>
        </sch:rule>
        <sch:rule context="scenario[not(ancestor-or-self::*/@statusCode = $statusCodesInactive)]/condition">
            <sch:extends rule="FreeFormMarkupWithLanguage"/>
        </sch:rule>
        
        <!-- ++++++++++++++++++++++ -->
        <!-- +++  TRANSACTIONS  +++ -->
        <!-- ++++++++++++++++++++++ -->
        <sch:title>Validate Transaction</sch:title>
        <sch:rule context="transaction[not(ancestor-or-self::*/@statusCode = $statusCodesInactive)]">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;', name(), ' ', string-join(for $att in (@id, @ref, @name, name[string-length() gt 0][1], @displayName, @effectiveDate, @flexibility, @statusCode, @versionLabel, @url[not(. = $deeplinkprefixservices)], @ident)
                return
                concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')"/>
            <sch:extends rule="VersionAttributeConsistency"/>
            
            <sch:assert role="error" test="not(@model) or @type"
                >ERROR: <sch:name/> with an underlying model SHALL have a @type.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(@label and (transaction or @type = 'group'))"
                >ERROR: <sch:name/> groups SHALL NOT have a schematron label.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(representingTemplate[@ref]) or @label"
                >ERROR: <sch:name/> with a representing template SHALL have a schematron label.<sch:value-of select="$locationContext"/></sch:assert>
            
            <!-- Validate transaction label -->
            <sch:let name="scenarioStatus" value="ancestor::scenario/@statusCode"/>
            <sch:let name="allLabels" value="$allTransactions/@label"/>
            <sch:let name="currentLabel" value="@label"/>
            <sch:report role="error" test="count($allLabels[. = $currentLabel]) gt 1"
                >ERROR: <sch:name/> @label '<sch:value-of select="$currentLabel"/>' SHALL be unique in this DECOR file.<sch:value-of select="$locationContext"/>
            </sch:report>
            <!-- Validate Transaction Type group -->
            <sch:assert role="error" test="not(@type = 'group') or parent::scenario"
                >ERROR: <sch:name/> groups SHALL be immediate children of scenario.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(@type = 'group' and transaction[@type = 'group'])"
                >ERROR: <sch:name/> groups SHALL NOT contain transaction groups.<sch:value-of select="$locationContext"/></sch:assert>
            <!-- Validate Transaction Type initial -->
            <sch:assert role="error" test="not(@type = 'initial') or parent::transaction[@type = 'group']"
                >ERROR: <sch:name/> of type 'initial' SHALL be immediate children of a transaction group.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(@type = 'initial') or (count(actors/actor[@role = 'sender']) ge 1 and count(actors/actor[@role = 'receiver']) ge 1)"
                >ERROR: <sch:name/> of type 'initial' SHALL have at least 1 'sender' actor and at least 1 'receiver' actor.<sch:value-of select="$locationContext"/></sch:assert>
            <!-- Validate Transaction Type back -->
            <sch:assert role="error" test="not(@type = 'back') or parent::transaction[@type = 'group']"
                >ERROR: <sch:name/> of type 'back' SHALL be immediate children of a transaction group.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(@type = 'back') or preceding-sibling::transaction[@type = 'initial'][not(@statusCode = $statusCodesInactive)]"
                >ERROR: <sch:name/> of type 'back' SHALL be preceded by a transaction of type 'initial'.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(@type = 'back') or (count(actors/actor[@role = 'sender']) ge 1 and count(actors/actor[@role = 'receiver']) ge 1)"
                >ERROR: <sch:name/> of type 'back' SHALL have at least 1 'sender' actor and at least 1 'receiver' actor.<sch:value-of select="$locationContext"/></sch:assert>
            <!-- Validate Transaction Type stationary -->
            <sch:assert role="error" test="not(@type = 'stationary') or parent::transaction[@type = 'group']"
                >ERROR: <sch:name/> of type 'stationary' SHALL be immediate children of a transaction group.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(@type = 'stationary') or not(preceding-sibling::transaction[position() = 1][@type = 'back'][not(@statusCode = $statusCodesInactive)] | following-sibling::transaction[position() = 1][@type = 'back'][not(@statusCode = $statusCodesInactive)])"
                >ERROR: <sch:name/> of type 'stationary' SHALL NOT be preceded or followed by a transaction of type 'back'.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(@type = 'stationary') or (empty(actors/actor[not(@role = ('sender', 'stationary'))]) and actors/actor)"
                >ERROR: <sch:name/> of type 'stationary' SHALL have only actors of type 'stationary'. Found: <sch:value-of select="string-join(distinct-values(actors/actor[not(@role = ('sender', 'stationary'))]/@role), ', ')"/>.<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        
        <sch:rule context="transaction[not(ancestor-or-self::*/@statusCode = $statusCodesInactive)]/name">
            <sch:extends rule="FreeFormMarkupWithLanguage"/>
        </sch:rule>
        <sch:rule context="transaction[not(ancestor-or-self::*/@statusCode = $statusCodesInactive)]/desc">
            <sch:extends rule="FreeFormMarkupWithLanguage"/>
        </sch:rule>
        <sch:rule context="transaction[not(ancestor-or-self::*/@statusCode = $statusCodesInactive)]/condition">
            <sch:extends rule="FreeFormMarkupWithLanguage"/>
        </sch:rule>
        <sch:rule context="transaction[not(ancestor-or-self::*/@statusCode = $statusCodesInactive)]/dependencies">
            <sch:extends rule="FreeFormMarkupWithLanguage"/>
        </sch:rule>
        <sch:rule context="transaction[not(ancestor-or-self::*/@statusCode = $statusCodesInactive)]/trigger">
            <sch:extends rule="FreeFormMarkupWithLanguage"/>
        </sch:rule>
        
        <sch:title>Validate Transaction Actor Reference</sch:title>
        <sch:rule context="transaction[not(ancestor-or-self::*/@statusCode = $statusCodesInactive)]/actors/actor">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;transaction ', string-join(for $att in ancestor-or-self::transaction[1]/(@id, @ref, @name, name[string-length() gt 0][1], @displayName, @effectiveDate, @flexibility, @versionLabel, @url[not(. = $deeplinkprefixservices)], @ident)
                return
                concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')"/>
            <sch:let name="actorId" value="@id"/>
            <sch:assert role="error" test="$allScenarioActors[@id = $actorId]"
                >ERROR: An actor reference SHALL reference an actor in the main list of actors for all scenarios. <sch:value-of select="$actorId"/> (type='<sch:value-of select="@type"/>') does not exist.<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        
        <sch:title>Validate Transaction sourceDataset with concepts</sch:title>
        <sch:rule context="representingTemplate[not(ancestor-or-self::*/@statusCode = $statusCodesInactiveFinal)]">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;transaction ', string-join(for $att in ancestor-or-self::transaction[1]/(@id, @ref, @name, name[string-length() gt 0][1], @displayName, @effectiveDate, @flexibility, @versionLabel, @url[not(. = $deeplinkprefixservices)], @ident)
                return
                concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')"/>
            <sch:let name="dsid" value="@sourceDataset"/>
            <sch:let name="dsed" value="@sourceDatasetFlexibility[not(. = 'dynamic')]"/>
            <sch:let name="tmid" value="@ref"/>
            <sch:let name="tmed" value="@flexibility[not(. = 'dynamic')]"/>
            <sch:let name="qqid" value="@representingQuestionnnaire"/>
            <sch:let name="qqed" value="@representingQuestionnnaireFlexibility[not(. = 'dynamic')]"/>
            
            <sch:let name="dsbyid" value="$allDatasets[@id = $dsid]"/>
            <sch:let name="ds" value="if ($dsed) then $dsbyid[@effectiveDate = $dsed] else $dsbyid[@effectiveDate = max($dsbyid/xs:dateTime(@effectiveDate))]"/>
            <sch:let name="dsref" value="$allDatasets[@ref = $dsid]"/>
            <sch:let name="tmbyid" value="$allTemplates[@id = $tmid]"/>
            <sch:let name="tm" value="if ($tmed) then $tmbyid[@effectiveDate = $tmed] else $tmbyid[@effectiveDate = max($tmbyid/xs:dateTime(@effectiveDate))]"/>
            <sch:let name="tmref" value="$allTemplates[@ref = $tmid]"/>
            <sch:let name="qqbyid" value="$allQuestionnaires[@id = $qqid]"/>
            <sch:let name="qq" value="if ($qqed) then $qqbyid[@effectiveDate = $qqed] else $qqbyid[@effectiveDate = max($qqbyid/xs:dateTime(@effectiveDate))]"/>
            <sch:let name="qqref" value="$allQuestionnaires[@ref = $qqid]"/>
            
            <!-- dataset references are not really supported yet, so don't raise more than warning -->
            <sch:report role="error" test="starts-with($dsid, concat($projectId, '.')) and not($ds | $dsref)"
                >ERROR: <sch:name/> SHALL point to an existing dataset or dataset reference @sourceDataset='<sch:value-of select="$dsid"/>' @sourceDatasetFlexibility='<sch:value-of select="($dsed, 'dynamic')[1]"/>'.<sch:value-of select="$locationContext"/></sch:report>
            <sch:assert role="error" test="$dsed or count($dsbyid) le 1"
                >ERROR: <sch:name/>/@sourceDatasetFlexibility SHALL be present when multiple versions of the dataset exist.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not($tmid) or ($tm | $tmref)"
                >ERROR: <sch:name/> SHALL point to an existing template or template reference @ref='<sch:value-of select="$tmid"/>' @flexibility='<sch:value-of select="($tmed, 'dynamic')[1]"/>'.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not($dsid and $isDecorCompiled) or $ds"
                >ERROR: <sch:name/> SHALL, in a compiled project, point to an existing dataset @sourceDataset='<sch:value-of select="$dsid"/>' @sourceDatasetFlexibility='<sch:value-of select="($dsed, 'dynamic')[1]"/>'.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not($tmid and $isDecorCompiled) or $tm"
                >ERROR: <sch:name/> SHALL, in a compiled project, point to an existing template @ref='<sch:value-of select="$tmid"/>' @flexibility='<sch:value-of select="($tmed, 'dynamic')[1]"/>'.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not($tm) or $tm[context]"
                >ERROR: <sch:name/> SHALL point to a template with a context element.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not($qqid) or ($qq | $qqref)"
                >ERROR: <sch:name/> SHALL point to an existing questionnaire or questionnaire reference @representingQuestionnaire='<sch:value-of select="$qqid"/>' @representingQuestionnaireFlexibility='<sch:value-of select="($qqed, 'dynamic')[1]"/>'.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not($qqid and $isDecorCompiled) or $qq"
                >ERROR: <sch:name/> SHALL, in a compiled project, point to an existing questionnaire @representingQuestionnaire='<sch:value-of select="$qqid"/>' @representingQuestionnaireFlexibility='<sch:value-of select="($qqed, 'dynamic')[1]"/>'.<sch:value-of select="$locationContext"/></sch:assert>
            
            <sch:assert role="warning" test="not($ds/@statusCode = $statusCodesInactive)"
                >WARNING: <sch:name/>/@sourceDataset='<sch:value-of select="$dsid"/>' SHOULD while you may still edit it point to a new, draft, pending or final dataset. Found '<sch:value-of select="$ds/@statusCode"/>'.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="warning" test="not($tm/@statusCode = $statusCodesInactive)"
                >WARNING: <sch:name/>/@ref='<sch:value-of select="$tmid"/>' SHOULD while you may still edit it point to a new, draft, pending or final template. Found '<sch:value-of select="$tm/@statusCode"/>'.<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        <sch:rule context="representingTemplate[not(ancestor-or-self::*/@statusCode = $statusCodesInactiveFinal)]/concept">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;transaction ', string-join(for $att in ancestor-or-self::transaction[1]/(@id, @ref, @name, name[string-length() gt 0][1], @displayName, @effectiveDate, @flexibility, @versionLabel, @url[not(. = $deeplinkprefixservices)], @ident)
                return
                concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')"/>
            <sch:extends rule="MultiplicityRange"/>
            <sch:extends rule="ValidateConformance"/>
            
            <sch:let name="rt" value="ancestor::representingTemplate[1]"/>
            <sch:let name="dsid" value="$rt/@sourceDataset"/>
            <sch:let name="dsed" value="$rt/@sourceDatasetFlexibility[not(. = 'dynamic')]"/>
            <sch:let name="deid" value="@ref"/>
            <sch:let name="deed" value="@flexibility[not(. = 'dynamic')]"/>
            
            <sch:let name="dsbyid" value="$allDatasets[@id = $dsid]"/>
            <sch:let name="ds" value="if ($dsed) then $dsbyid[@effectiveDate = $dsed] else $dsbyid[@effectiveDate = max($dsbyid/xs:dateTime(@effectiveDate))]"/>
            <!-- mind performance and assume that every dataset contains only one version of a concept -->
            <sch:let name="de" value="$allDatasetConcepts[@id = $dsid]"/>
            
            <sch:assert role="error" test="not($ds) or $ds//concept[@id = $deid][not(ancestor::history | parent::conceptList)] or $ds//concept[@ref]"
                >ERROR: transaction concept ref="<sch:value-of select="$deid"/>", SHALL exist in dataset/@id='<sch:value-of select="$dsid"/>' @effectiveDate='<sch:value-of select="$ds/@effectiveDate"/>' (<sch:value-of select="$ds/name[string-length() gt 0][1]"/>).<sch:value-of select="$locationContext"/></sch:assert>
            <!-- Scenario currently has statusCode and transaction currently doesn't. Check should still work if transaction is to have a statusCode -->
            <sch:report role="warning" test="$de[@statusCode = $statusCodesInactive]"
                >WARNING: transaction concept ref="<sch:value-of select="$deid"/>", SHOULD, while you may still edit it, point to a new, draft, pending or final concept, but found '<sch:value-of select="$de/@statusCode"/>'.<sch:value-of select="$locationContext"/></sch:report>
            <sch:let name="missingParentLevel" value="$de/parent::concept[not(@id = $rt/concept/@ref)]"/>
            <sch:assert role="error" sqf:fix="addConceptParentsInTransaction" test="not($de) or not($missingParentLevel)"
                >ERROR: transaction concept ref="<sch:value-of select="$deid"/>" is missing one or more parent groups active in the transaction. This may have happened because of moved concepts in the dataset. You should check this transaction and activate the missing parent concept groups.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:report role="warning" test="not(@enableBehavior) and count(enableWhen) gt 1"
                >WARNING: transaction concept ref="<sch:value-of select="$deid"/>" SHOULD specify enableBehavior (all | any) if you have more than one enableWhen defined.<sch:value-of select="$locationContext"/></sch:report>
            <sch:report role="warning" test="count(terminologyAssociation) gt 1"
                >WARNING: transaction concept ref="<sch:value-of select="$deid"/>" SHOULD NOT specify multiple value set bindings. Only 1 is allowed in FHIR profiles - unless you are slicing and the value sets are mutually exclusive - and questionnaires, and especially for the binding strength the semantics are unclear.<sch:value-of select="$locationContext"/></sch:report>
            <sch:report role="warning" test="terminologyAssociation/@strength = 'example'"
                >WARNING: transaction concept ref="<sch:value-of select="$deid"/>" SHOULD NOT specify binding strength example as example is unimplementable.<sch:value-of select="$locationContext"/></sch:report>
        </sch:rule>
        <sch:rule context="representingTemplate[not(ancestor-or-self::*/@statusCode = $statusCodesInactiveFinal)]/concept/condition">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;transaction ', string-join(for $att in ancestor-or-self::transaction[1]/(@id, @ref, @name, name[string-length() gt 0][1], @displayName, @effectiveDate, @flexibility, @versionLabel, @url[not(. = $deeplinkprefixservices)], @ident)
                return
                concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')"/>
            <sch:extends rule="MultiplicityRange"/>
            <sch:extends rule="ValidateConformance"/>
            
            <sch:let name="textContents" value="empty(normalize-space(string-join(text(), '')))"/>
            <sch:report role="error" test="* and $textContents"
                >ERROR: transaction concept ref="<sch:value-of select="../@ref"/>", SHALL have conditions with text only or element only (no mixed content).<sch:value-of select="$locationContext"/></sch:report>
        </sch:rule>
        <sch:rule context="representingTemplate[not(ancestor-or-self::*/@statusCode = $statusCodesInactiveFinal)]/concept/condition/desc">
            <sch:extends rule="FreeFormMarkupWithLanguage"/>
        </sch:rule>
        <sch:rule context="representingTemplate[not(ancestor-or-self::*/@statusCode = $statusCodesInactiveFinal)]/concept/enableWhen">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;transaction ', string-join(for $att in ancestor-or-self::transaction[1]/(@id, @ref, @name, name[string-length() gt 0][1], @displayName, @effectiveDate, @flexibility, @versionLabel, @url[not(. = $deeplinkprefixservices)], @ident)
                return
                concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')"/>
            
            <sch:let name="questionId" value="@question"/>
            <sch:report role="error" test="ancestor::concept[@ref = $questionId]"
                >ERROR: transaction concept ref="<sch:value-of select="../@ref"/>", SHALL NOT depend on itself for enableWhen.<sch:value-of select="$locationContext"/></sch:report>
            <sch:assert role="error" test="ancestor::representingTemplate/concept[@ref = $questionId]"
                >ERROR: transaction concept ref="<sch:value-of select="../@ref"/>", SHALL depend on a concept contained in the same transaction for enableWhen. Found: <sch:value-of select="$questionId"/>.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:report role="error" test=".[@operator = ('&lt;', '&lt;=', '&gt;', '&gt;=')][answerBoolean | answerString | answerCoding]"
                >ERROR: transaction concept ref="<sch:value-of select="../@ref"/>", SHALL NOT depend on being <sch:value-of select="@operator"/> than a boolean, string or coding value for enableWhen.<sch:value-of select="$locationContext"/></sch:report>
        </sch:rule>
        
        <sch:title>Validate identifierAssociation</sch:title>
        <sch:rule context="ids/identifierAssociation[not(@expirationDate)] | representingTemplate/concept/identifierAssociation[not(@expirationDate)]">
            <sch:let name="deid" value="@conceptId"/>
            <sch:let name="deed" value="@conceptFlexibility[. castable as xs:dateTime]"/>
            <sch:let name="dsid" value="ancestor::representingTemplate/@sourceDataset"/>
            <sch:let name="dsed" value="ancestor::representingTemplate/@sourceDatasetFlexibility[. castable as xs:dateTime]"/>
            
            <sch:let name="dsbyid" value="$allDatasets[@id = $dsid]"/>
            <sch:let name="ds" value="if ($dsbyid and $dsed) then $dsbyid[@effectiveDate = $dsed] else if ($dsbyid) then $dsbyid[@effectiveDate = max($dsbyid/xs:dateTime(@effectiveDate))] else $allDatasets"/>
            
            <sch:let name="debyid" value="$ds//concept[@id = $deid]"/>
            <sch:let name="de" value="if ($deed) then $debyid[@effectiveDate = $deed] else $debyid[@effectiveDate = max($debyid/xs:dateTime(@effectiveDate))]"/>
            
            <sch:let name="inhbyid1" value="if ($de[@type]) then () else $allDatasetConcepts[@id = $de/inherit/@ref]"/>
            <sch:let name="inhc1" value="if ($de[@type]) then () else if ($de/inherit/@effectiveDate) then $inhbyid1[@effectiveDate = $de/inherit/@effectiveDate] else $inhbyid1[@effectiveDate = max($inhbyid1/xs:dateTime(@effectiveDate))]"/>
            <sch:let name="inhbyid2" value="if ($de[@type]) then () else $allDatasetConcepts[@id = $inhc1/inherit/@ref]"/>
            <sch:let name="inhc2" value="if ($de[@type]) then () else if ($inhc1/inherit/@effectiveDate) then $inhbyid2[@effectiveDate = $inhc1/inherit/@effectiveDate] else $inhbyid2[@effectiveDate = max($inhbyid2/xs:dateTime(@effectiveDate))]"/>
            <sch:let name="inhbyid3" value="if ($de[@type]) then () else $allDatasetConcepts[@id = $inhc2/inherit/@ref]"/>
            <sch:let name="inhc3" value="if ($de[@type]) then () else if ($inhc2/inherit/@effectiveDate) then $inhbyid3[@effectiveDate = $inhc2/inherit/@effectiveDate] else $inhbyid3[@effectiveDate = max($inhbyid3/xs:dateTime(@effectiveDate))]"/>
            <sch:let name="detype" value="($de, $inhc1, $inhc2, $inhc3)[@type][1]"/>
            <sch:let name="dename" value="($de, $inhc1, $inhc2, $inhc3)[name][1]/name[not(. = '')][1]"/>
            
            <sch:let name="locationContext" value="
                concat(' | Location &lt;identifierAssociation ', string-join((
                for $att in @*
                return
                    concat(name($att), '=&#34;', $att, '&#34;'),
                for $att in $de[1]/(@id, @ref, $detype/@type, $dename, @displayName, @effectiveDate, @flexibility, @statusCode, @versionLabel, ancestor-or-self::dataset[1]/@url[not(. = $deeplinkprefixservices)], ancestor-or-self::dataset[1]/@ident)
                return
                    concat('concept', upper-case(substring(name($att), 1, 1)), substring(name($att), 2), '=&#34;', $att, '&#34;'),
                for $att in $de[1]/ancestor-or-self::dataset/(@id, @effectiveDate, @versionLabel, @statusCode, name[not(. = '')][1])
                return
                    concat('dataset', upper-case(substring(name($att), 1, 1)), substring(name($att), 2), '=&#34;', $att, '&#34;'),
                for $att in ancestor-or-self::transaction/(@id, @effectiveDate, @versionLabel, @statusCode, name[not(. = '')][1])
                return
                    concat('transaction', upper-case(substring(name($att), 1, 1)), substring(name($att), 2), '=&#34;', $att, '&#34;')
                ), ' '), '/&gt;')"/>
            
            <!-- In inheritance situations from another project, there is no conceptList in this project, so skip check if conceptList id is not from this project -->
            <sch:report role="info" test="starts-with($deid, concat($projectId, '.')) and not($de)"
                >INFO: <sch:name/> SHOULD point to an existing concept @id='<sch:value-of select="$deid"/>'. <sch:value-of select="$locationContext"/></sch:report>
            <sch:report role="warning" test="$isDecorCompiled and $deid and not($de)"
                >WARNING: <sch:name/> SHOULD point to an existing dataset concept. In a compiled project, references should have been resolved.<sch:value-of select="$locationContext"/></sch:report>
            
            <sch:assert role="warning" test="not($de) or $de[valueDomain[@type = 'identifier'] | inherit]"
                >WARNING: <sch:name/> SHOULD point to a concept with a value domain of type identifier. <sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        
        <!-- ++++++++++++++++++++++ -->
        <!-- +++  TERMINOLOGY   +++ -->
        <!-- ++++++++++++++++++++++ -->
        <sch:title>Validate terminologyAssociation</sch:title>
        <sch:rule context="terminology/terminologyAssociation[not(@expirationDate)] | representingTemplate/concept/terminologyAssociation[not(@expirationDate)]">
            <sch:let name="deid" value="@conceptId"/>
            <sch:let name="deed" value="@conceptFlexibility[not(. = 'dynamic')]"/>
            <sch:let name="dsid" value="ancestor::representingTemplate/@sourceDataset"/>
            <sch:let name="dsed" value="ancestor::representingTemplate/@sourceDatasetFlexibility[. castable as xs:dateTime]"/>
            
            <sch:let name="dsbyid" value="$allDatasets[@id = $dsid]"/>
            <sch:let name="ds" value="if ($dsbyid and $dsed) then $dsbyid[@effectiveDate = $dsed] else if ($dsbyid) then $dsbyid[@effectiveDate = max($dsbyid/xs:dateTime(@effectiveDate))] else $allDatasets"/>
            
            <sch:let name="debyid" value="$ds//concept[@id = $deid]"/>
            <sch:let name="de" value="if ($deed) then $debyid[@effectiveDate = $deed] else $debyid[@effectiveDate = max($debyid/xs:dateTime(@effectiveDate))]"/>
            
            <sch:let name="vsid" value="@valueSet"/>
            <sch:let name="vsed" value="@flexibility[not(. = 'dynamic')]"/>
            
            <sch:let name="clbyid" value="$allDatasetConceptLists[@id = $deid]"/>
            <sch:let name="clcbyid" value="$allDatasetConceptListConcepts[@id = $deid]"/>
            
            <sch:let name="inhbyid1" value="if ($de[@type]) then () else $allDatasetConcepts[@id = $de/inherit/@ref]"/>
            <sch:let name="inhc1" value="if ($de[@type]) then () else if ($de/inherit/@effectiveDate) then $inhbyid1[@effectiveDate = $de/inherit/@effectiveDate] else $inhbyid1[@effectiveDate = max($inhbyid1/xs:dateTime(@effectiveDate))]"/>
            <sch:let name="inhbyid2" value="if ($de[@type]) then () else $allDatasetConcepts[@id = $inhc1/inherit/@ref]"/>
            <sch:let name="inhc2" value="if ($de[@type]) then () else if ($inhc1/inherit/@effectiveDate) then $inhbyid2[@effectiveDate = $inhc1/inherit/@effectiveDate] else $inhbyid2[@effectiveDate = max($inhbyid2/xs:dateTime(@effectiveDate))]"/>
            <sch:let name="inhbyid3" value="if ($de[@type]) then () else $allDatasetConcepts[@id = $inhc2/inherit/@ref]"/>
            <sch:let name="inhc3" value="if ($de[@type]) then () else if ($inhc2/inherit/@effectiveDate) then $inhbyid3[@effectiveDate = $inhc2/inherit/@effectiveDate] else $inhbyid3[@effectiveDate = max($inhbyid3/xs:dateTime(@effectiveDate))]"/>
            <sch:let name="detype" value="($de, $inhc1, $inhc2, $inhc3)[@type][1]"/>
            <sch:let name="dename" value="($de, $inhc1, $inhc2, $inhc3)[name][1]/name[not(. = '')][1]"/>
            
            <sch:let name="vsbyid" value="$allValueSets[@id = $vsid]"/>
            <sch:let name="vs" value="if ($vsed) then $vsbyid[@effectiveDate = $vsed] else $vsbyid[@effectiveDate = max($vsbyid/xs:dateTime(@effectiveDate))]"/>
            <sch:let name="vsref" value="$allValueSets[@ref = $vsid]"/>
            
            <sch:let name="locationContext" value="
                concat(' | Location &lt;terminologyAssociation ', string-join((
                for $att in @*
                return
                        concat(name($att), '=&#34;', $att, '&#34;'),
                for $att in $de[1]/(@id, @ref, $detype/@type, $dename, @displayName, @effectiveDate, @flexibility, @statusCode, @versionLabel, ancestor-or-self::dataset[1]/@url[not(. = $deeplinkprefixservices)], ancestor-or-self::dataset[1]/@ident)
                return
                        concat('concept', upper-case(substring(name($att), 1, 1)), substring(name($att), 2), '=&#34;', $att, '&#34;'),
                for $att in $de[1]/ancestor-or-self::dataset/(@id, @effectiveDate, @versionLabel, @statusCode, name[not(. = '')][1])
                return
                    concat('dataset', upper-case(substring(name($att), 1, 1)), substring(name($att), 2), '=&#34;', $att, '&#34;'),
                for $att in ancestor-or-self::transaction/(@id, @effectiveDate, @type, @versionLabel, @statusCode, name[not(. = '')][1])
                return
                    concat('transaction', upper-case(substring(name($att), 1, 1)), substring(name($att), 2), '=&#34;', $att, '&#34;')
                ), ' '), '/&gt;')"/>
            
            <!-- In inheritance situations from another project, there is no conceptList in this project, so skip check if conceptList id is not from this project -->
            <sch:report role="info" test="(starts-with($deid, concat($projectId, '.')) or $isDecorCompiled) and $vsid and not($clbyid)"
                >INFO: <sch:name/> SHOULD point to an existing conceptList.<sch:value-of select="$locationContext"/></sch:report>
            <!--<sch:report role="info" test="not(starts-with($deid, concat($projectId, '.'))) and $vsid and not($clbyid)"
                >INFO: <sch:name/>/@conceptId='<sch:value-of select="$deid"/>' from different project is not pointing to an existing conceptList.<sch:value-of select="$locationContext"/></sch:report>-->
            
            <sch:report role="info" test="(starts-with($deid, concat($projectId, '.')) or $isDecorCompiled) and @code and not($de | $clcbyid)"
                >INFO: <sch:name/> SHOULD point to an existing concept or concept within a conceptList.<sch:value-of select="$locationContext"/></sch:report>
            <!--<sch:report role="info" test="not(starts-with($deid, concat($projectId, '.'))) and @code and not($de | $clcbyid)"
                >INFO: <sch:name/>/@conceptId='<sch:value-of select="$deid"/>' from different project is not pointing to an existing concept or concept within a conceptList.<sch:value-of select="$locationContext"/></sch:report>-->
            
            <sch:assert role="warning" test="not(@strength[not(. = 'required')]) or $vsid"
                >WARNING: <sch:name/> SHOULD NOT specify a binding strength unless it concerns a value set binding.<sch:value-of select="$locationContext"/></sch:assert>
            
            <sch:report role="warning" test="starts-with($vsid, concat($projectId, '.')) and $vsid and not($vs | $vsref)"
                >WARNING: <sch:name/> SHOULD point to an existing valueSet or valueSet reference.<sch:value-of select="$locationContext"/></sch:report>
            <!--<sch:report role="info" test="not(starts-with($vsid, concat($projectId, '.'))) and $vsid and not($vs | $vsref)"
                >INFO: <sch:name/> from different project is not pointing to an existing valueSet.<sch:value-of select="$locationContext"/></sch:report>-->
            <sch:report role="error" test="$isDecorCompiled and $clbyid and $vsid and not($vs)"
                >ERROR: <sch:name/> SHOULD point to an existing valueSet. In a compiled project, references should have been resolved.<sch:value-of select="$locationContext"/></sch:report>
            
            <sch:assert role="error" test="@code | @valueSet | ancestor::transaction"
                >ERROR: <sch:name/> SHALL have a @code or a @valueSet.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(@code and @valueSet)"
                >ERROR: <sch:name/> SHALL NOT have both @code and @valueSet.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="@valueSet or not(@flexibility)"
                >ERROR: <sch:name/> SHALL NOT have @flexibility without @valueSet.<sch:value-of select="$locationContext"/></sch:assert>
            <!-- prepare for FHIR canonicals, but beware: we don't know how to get $vs yet if we get one... -->
            <sch:assert role="error" test="not($vsid) or matches($vsid, '^[0-9\.]+$') or starts-with($vsid, 'http')"
                >ERROR: <sch:name/>/@valueSet='<sch:value-of select="$vsid"/>' references SHALL be based on valueSet/@id. References by @name quickly become ambiguous.<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        
        <sch:title>Validate ValueSet</sch:title>
        <sch:rule context="terminology/valueSet[not(@statusCode = $statusCodesInactive)]">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;valueSet ', string-join(for $att in ancestor-or-self::valueSet[1]/(@id, @ref, @name, name[string-length() gt 0][1], @displayName, @effectiveDate, @flexibility, @versionLabel, ancestor-or-self::valueSet[1]/@url[not(. = $deeplinkprefixservices)], ancestor-or-self::valueSet[1]/@ident)
                return
                concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')"/>
            <sch:extends rule="VersionAttributeConsistency"/>
            
            <sch:let name="HL7ValueSetIds" value="'2.16.840.1.113883.1.11.'"/>
            <sch:let name="NullFlavorValueSetIds" value="('2.16.840.1.113883.1.11.10609', '2.16.840.1.113883.1.11.10610', '2.16.840.1.113883.1.11.10612', '2.16.840.1.113883.1.11.10614', '2.16.840.1.113883.1.11.10616', '2.16.840.1.113883.1.11.20352')"/>
            <sch:report role="error" test="not(starts-with(@id, $HL7ValueSetIds)) and (conceptList/concept[@codeSystem = $oidNullFlavor] | conceptList/*[@ref = $NullFlavorValueSetIds][not(@exception = 'true')])"
                >ERROR: <sch:name/> SHALL NOT contain NullFlavor codes as concepts. NullFlavor SHALL be exception.<sch:value-of select="$locationContext"/></sch:report>
        </sch:rule>
        <!--<sch:rule context="terminology/valueSet[not(@statusCode = $statusCodesInactive)]/conceptList/exception">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;valueSet ', string-join(for $att in ancestor-or-self::valueSet[1]/(@id, @ref, @name, name[string-length() gt 0][1], @displayName, @effectiveDate, @flexibility, ancestor-or-self::valueSet[1]/@url[not(. = $deeplinkprefixservices)], ancestor-or-self::valueSet[1]/@ident)
                return
                concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')"/>
            <sch:let name="theCode" value="@code"/>
            <sch:let name="theCodeSystem" value="@codeSystem"/>
            <sch:assert role="error" test="not(preceding-sibling::exception[@code = $theCode][@codeSystem = $theCodeSystem])"
                >ERROR: <sch:name/> exception "<sch:value-of select="$theCode"/>" SHALL be unique within the same value set.<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>-->
        
        <sch:title>Validate Value Set concept list include and exclude statements</sch:title>
        <sch:rule context="terminology/valueSet[not(@statusCode = $statusCodesInactive)]/conceptList/include | terminology/valueSet[not(@statusCode = $statusCodesInactive)]/conceptList/exclude">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;valueSet ', string-join(for $att in ancestor-or-self::valueSet[1]/(@id, @ref, @name, name[string-length() gt 0][1], @displayName, @effectiveDate, @flexibility, @versionLabel, ancestor-or-self::valueSet[1]/@url[not(. = $deeplinkprefixservices)], ancestor-or-self::valueSet[1]/@ident)
                return
                concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')"/>
            <sch:assert role="error" test="not(@flexibility) or (@ref | @codeSystem)"
                >ERROR: <sch:name/> SHALL NOT have @flexibility without @ref | @codeSystem.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(@ref and (@op | @code | @codeSystem))"
                >ERROR: <sch:name/> SHALL NOT have both @ref and (@op | @code | @codeSystem).<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        
        <sch:rule context="terminology/valueSet[not(@statusCode = $statusCodesInactiveFinal)]/conceptList/concept/desc">
            <sch:extends rule="FreeFormMarkupWithLanguage"/>
        </sch:rule>
        <sch:rule context="terminology/valueSet[not(@statusCode = $statusCodesInactiveFinal)]/conceptList/include/desc">
            <sch:extends rule="FreeFormMarkupWithLanguage"/>
        </sch:rule>
        <sch:rule context="terminology/valueSet[not(@statusCode = $statusCodesInactiveFinal)]/conceptList/exception/desc">
            <sch:extends rule="FreeFormMarkupWithLanguage"/>
        </sch:rule>
        
        <sch:title>Validate CodeSystem</sch:title>
        <sch:rule context="terminology/codeSystem[not(@statusCode = $statusCodesInactive)]">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;codeSystem ', string-join(for $att in (@id, @ref, @name, name[string-length() gt 0][1], @displayName, @effectiveDate, @flexibility, @versionLabel, ancestor-or-self::codeSystem[1]/@url[not(. = $deeplinkprefixservices)], ancestor-or-self::codeSystem[1]/@ident)
                return
                concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')"/>
            <sch:extends rule="VersionAttributeConsistency"/>
            
            <sch:let name="duplicateCodes" value="distinct-values(conceptList/codedConcept[@code = preceding-sibling::codedConcept/@code]/@code)"/>
            <sch:assert role="error" test="empty($duplicateCodes)"
                >ERROR: <sch:name/> <sch:value-of select="(@displayName, @name)[1]"/> SHALL NOT define duplicate codes. Found: <sch:value-of select="$duplicateCodes"/>.<sch:value-of select="$locationContext"/></sch:assert>
            
            <sch:report role="warning" test="empty(conceptList/codedConcept[parent | child]) and conceptList/codedConcept[@level[not(. = '0')]]"
                >WARNING: <sch:name/> <sch:value-of select="(@displayName, @name)[1]"/> SHOULD define parent relationships instead of relying on levels. This is new from ART-DECOR v3.5.0 and up. Please consider upgrading the codeSystem.<sch:value-of select="$locationContext"/></sch:report>
            <sch:report role="warning" test="conceptList/codedConcept[empty(@statusCode)]"
                >WARNING: <sch:name/> <sch:value-of select="(@displayName, @name)[1]"/> SHOULD define statusCode on every codedConcept. This is new from ART-DECOR v3.5.0 and up. Please consider upgrading the codeSystem.<sch:value-of select="$locationContext"/></sch:report>
        </sch:rule>
        <sch:rule context="terminology/codeSystem[not(@statusCode = $statusCodesInactive)]/conceptList/codedConcept">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;codeSystem ', string-join(for $att in ancestor::codeSystem[1]/(@id, @ref, @name, name[string-length() gt 0][1], @displayName, @effectiveDate, @flexibility, @versionLabel, ancestor-or-self::codeSystem[1]/@url[not(. = $deeplinkprefixservices)], ancestor-or-self::codeSystem[1]/@ident)
                return
                concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')"/>
            
            <sch:let name="theCode" value="@code"/>
            <sch:let name="theType" value="@type"/>
            <sch:let name="theLevel" value="if (@level castable as xs:integer) then xs:integer(@level) else ()"/>
            <sch:let name="checkParentChild" value="exists(../codedConcept[parent | child])"/>
            <sch:let name="checkLevelType" value="not($checkParentChild)"/>
            <sch:let name="childConceptsOfThisConceptByParent" value="../codedConcept/parent[@code = $theCode]"/>
            <sch:let name="parentConceptsOfThisConceptByParent" value="parent"/>
            
            <!-- Based on level a codedConcept is only a direct child of the current concept if it has current level+1, and is following the current concept, and does not also follow a concept with the same or lower level than the current concept -->
            <sch:let name="nextFirstOtherHierarchy" value="if ($checkParentChild) then () else (following-sibling::codedConcept[@level castable as xs:integer][xs:integer(@level) le $theLevel])[1]"/>
            <sch:let name="childConceptsOfThisConceptByLevel" value="if ($checkParentChild) then () else following-sibling::codedConcept[@level castable as xs:integer][xs:integer(@level) = ($theLevel + 1)][not(preceding-sibling::codedConcept[@code = $nextFirstOtherHierarchy/@code])]"/>
            
            <!-- Based on level a codedConcept is only a direct parent of the current concept if it has current level-1, and is preceding the current concept, and does not also preceed a concept with the same or higher level than the current concept -->
            <sch:let name="parentByLevel" value="if ($checkParentChild) then () else if ($theLevel gt 0) then preceding-sibling::codedConcept[@level castable as xs:integer][xs:integer(@level) lt $theLevel][1] else ()"/>
            
            <!-- Generic checks -->
            <sch:assert role="error" test="not(preceding-sibling::codedConcept[@code = $theCode] | following-sibling::codedConcept[@code = $theCode])"
                >ERROR Code system concept code '<sch:value-of select="$theCode"/>' SHALL be unique in the code system.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(@expirationDate[. castable as xs:dateTime][xs:dateTime(.) le current-dateTime()]) or not(@statusCode = ('active', 'final'))"
                >ERROR Code system concept code '<sch:value-of select="@code"/>' SHALL NOT have an expiration date and have status code <sch:value-of select="@statusCode"/>.<sch:value-of select="$locationContext"/></sch:assert>
            
            <!-- Level/type based checks -->
            <sch:assert role="error" test="$checkParentChild or not(@type = 'L' and $childConceptsOfThisConceptByLevel)"
                >ERROR Code system concept code '<sch:value-of select="$theCode"/>' SHALL NOT have type <sch:value-of select="$theType"/> and have children. Expected A, S or D.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="$checkParentChild or not($theLevel gt 0) or $parentByLevel[xs:integer(@level) = ($theLevel - 1)]"
                >ERROR Code system concept code '<sch:value-of select="$theCode"/>' at level '<sch:value-of select="$theLevel"/>' SHALL have a parent on level '<sch:value-of select="$theLevel - 1"/>'. Found: <sch:value-of select="if ($parentByLevel) then concat('concept ''', $parentByLevel/@code, ''' at level ''', $parentByLevel/@level, '''') else 'none'"/>.<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        <sch:rule context="terminology/codeSystem[not(@statusCode = $statusCodesInactive)]/conceptList/codedConcept/parent">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;codeSystem ', string-join(for $att in ancestor::codeSystem[1]/(@id, @ref, @name, name[string-length() gt 0][1], @displayName, @effectiveDate, @flexibility, @versionLabel, ancestor-or-self::codeSystem[1]/@url[not(. = $deeplinkprefixservices)], ancestor-or-self::codeSystem[1]/@ident)
                return
                concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')"/>
            
            <sch:let name="theCode" value="../@code"/>
            <sch:let name="theParentCode" value="@code"/>
            
            <sch:assert role="error" test="not($theCode = $theParentCode)"
                >ERROR Code system concept code '<sch:value-of select="$theCode"/>' SHALL NOT declare itself as parent.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="../../codedConcept/@code = $theParentCode"
                >ERROR Code system concept code '<sch:value-of select="$theCode"/>' SHALL declare an existing parent. Parent <sch:value-of select="$theParentCode"/> not found in the code system.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="empty(../../codedConcept/child) or ../../codedConcept[@code = $theParentCode]/child/@code = $theCode"
                >ERROR Code system concept code '<sch:value-of select="$theCode"/>' declares parent <sch:value-of select="$theParentCode"/> but that parent does not claim <sch:value-of select="$theCode"/> as its child.<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        <sch:rule context="terminology/codeSystem[not(@statusCode = $statusCodesInactive)]/conceptList/codedConcept/child">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;codeSystem ', string-join(for $att in ancestor::codeSystem[1]/(@id, @ref, @name, name[string-length() gt 0][1], @displayName, @effectiveDate, @flexibility, @versionLabel, ancestor-or-self::codeSystem[1]/@url[not(. = $deeplinkprefixservices)], ancestor-or-self::codeSystem[1]/@ident)
                return
                concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')"/>
            
            <sch:let name="theCode" value="../@code"/>
            <sch:let name="theChildCode" value="@code"/>
            
            <sch:assert role="error" test="not($theCode = $theChildCode)"
                >ERROR Code system concept code '<sch:value-of select="$theCode"/>' SHALL NOT declare itself as child.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="../../codedConcept/@code = $theChildCode"
                >ERROR Code system concept code '<sch:value-of select="$theCode"/>' SHALL declare an existing child. Child <sch:value-of select="$theChildCode"/> not found in the code system.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="empty(../../codedConcept/parent) or ../../codedConcept[@code = $theChildCode]/parent/@code = $theCode"
                >ERROR Code system concept code '<sch:value-of select="$theCode"/>' declares child <sch:value-of select="$theChildCode"/> but that child does not claim <sch:value-of select="$theCode"/> as its parent.<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        <sch:rule context="terminology/codeSystem[not(@statusCode = $statusCodesInactive)]/conceptList/codedConcept/property">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;codeSystem ', string-join(for $att in ancestor::codeSystem[1]/(@id, @ref, @name, name[string-length() gt 0][1], @displayName, @effectiveDate, @flexibility, @versionLabel, ancestor-or-self::codeSystem[1]/@url[not(. = $deeplinkprefixservices)], ancestor-or-self::codeSystem[1]/@ident)
                return
                concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')"/>
            
            <sch:let name="theCode" value="../@code"/>
            <sch:let name="thePropertyCode" value="@code"/>
            <sch:let name="theDefinedProperty" value="ancestor::codeSystem/property[@code = $thePropertyCode]"/>
            <sch:let name="thePropertyType" value="if (*) then name(*[1]) else ()"/>
            
            <sch:assert role="error" test="$theDefinedProperty"
                >ERROR Code system concept code '<sch:value-of select="$theCode"/>' SHALL only use declared properties. Property <sch:value-of select="$thePropertyCode"/> not found in the code system properties.<sch:value-of select="$locationContext"/></sch:assert>
            
            <sch:assert role="error" test="not($theDefinedProperty) or $theDefinedProperty[upper-case(concat('value', @type)) = upper-case($thePropertyType)]"
                >ERROR Code system concept code '<sch:value-of select="$theCode"/>' SHALL have property type "<sch:value-of select="$theDefinedProperty/@type"/>". Found "<sch:value-of select="$thePropertyType"/>".<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        
        <!-- ++++++++++++++++++++++ -->
        <!-- +++     RULES      +++ -->
        <!-- ++++++++++++++++++++++ -->
        <sch:title>Validate Template Association Definition</sch:title>
        <!-- <templateAssociation templateId="2.16.840.1.113883.2.4.6.10.100.13" effectiveDate="2012-05-09T00:00:00"> -->
        <sch:rule context="rules/templateAssociation">
            <sch:let name="tmid" value="@templateId"/>
            <sch:let name="tmed" value="@effectiveDate"/>
            
            <sch:let name="tmbyid" value="$allTemplates[@id = $tmid]"/>
            <sch:let name="tm" value="if ($tmed) then $tmbyid[@effectiveDate = $tmed] else $tmbyid[@effectiveDate = max($tmbyid/xs:dateTime(@effectiveDate))]"/>
            <sch:let name="tmref" value="$allTemplates[@ref = $tmid]"/>
            <sch:let name="locationContext" value="
                concat(' | Location &lt;templateAssociation ', string-join(for $att in (@*, ($tm, $tmref)[1]/(@name, @statusCode, @versionLabel))
                return
                concat(name($att), '=&#34;', $att, '&#34;')
                , ' '), '/&gt;')"/>
            
            <sch:assert role="error" test="$tm | $tmref"
                >ERROR: <sch:name/> SHALL be bound to an existing template or template reference.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="count($allTemplateAssociations[@templateId = $tmid][@effectiveDate = $tmed]) le 1"
                >ERROR: There SHALL be 0..1 template association per template (<sch:value-of select="$tmid"/> - <sch:value-of select="$tmed"/>).<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        
        <sch:title>Validate Template Association Concept</sch:title>
        <!-- <concept ref="2.16.840.1.113883.2.4.3.11.60.100.2.4.472" effectiveDate="2012-05-20T14:12:37" elementId="2.16.840.1.113883.2.4.3.11.60.100.9.13.2"/> -->
        <sch:rule context="rules/templateAssociation/concept">
            <sch:let name="deid" value="@ref"/>
            <sch:let name="deed" value="@effectiveDate[not(. = 'dynamic')]"/>
            <sch:let name="tmid" value="parent::templateAssociation/@templateId"/>
            <sch:let name="tmed" value="parent::templateAssociation/@effectiveDate"/>
            <sch:let name="elid" value="@elementId"/>
            
            <sch:let name="debyid" value="$allDatasetConcepts[@id = $deid]"/>
            <sch:let name="deNewest" value="max($debyid/xs:dateTime(@effectiveDate))"/>
            <sch:let name="de" value="if ($deed) then $debyid[@effectiveDate = $deed] else $debyid[@effectiveDate = $deNewest]"/>
            <sch:let name="deIsNewest" value="$de/@effectiveDate = $deNewest"/>
            
            <sch:let name="inhbyid1" value="if ($de[@type]) then () else $allDatasetConcepts[@id = $de/inherit/@ref]"/>
            <sch:let name="inhc1" value="if ($de[@type]) then () else if ($de/inherit/@effectiveDate) then $inhbyid1[@effectiveDate = $de/inherit/@effectiveDate] else $inhbyid1[@effectiveDate = max($inhbyid1/xs:dateTime(@effectiveDate))]"/>
            <sch:let name="inhbyid2" value="if ($de[@type]) then () else $allDatasetConcepts[@id = $inhc1/inherit/@ref]"/>
            <sch:let name="inhc2" value="if ($de[@type]) then () else if ($inhc1/inherit/@effectiveDate) then $inhbyid2[@effectiveDate = $inhc1/inherit/@effectiveDate] else $inhbyid2[@effectiveDate = max($inhbyid2/xs:dateTime(@effectiveDate))]"/>
            <sch:let name="inhbyid3" value="if ($de[@type]) then () else $allDatasetConcepts[@id = $inhc2/inherit/@ref]"/>
            <sch:let name="inhc3" value="if ($de[@type]) then () else if ($inhc2/inherit/@effectiveDate) then $inhbyid3[@effectiveDate = $inhc2/inherit/@effectiveDate] else $inhbyid3[@effectiveDate = max($inhbyid3/xs:dateTime(@effectiveDate))]"/>
            <sch:let name="detype" value="($de, $inhc1, $inhc2, $inhc3)[@type][1]"/>
            <sch:let name="dename" value="($de, $inhc1, $inhc2, $inhc3)[name][1]/name[not(. = '')][1]"/>
            
            <sch:let name="tmbyid" value="$allTemplates[@id = $tmid]"/>
            <sch:let name="tm" value="if ($tmed) then $tmbyid[@effectiveDate = $tmed] else $tmbyid[@effectiveDate = max($tmbyid/xs:dateTime(@effectiveDate))]"/>
            <sch:let name="tmref" value="$allTemplates[@ref = $tmid]"/>
            <sch:let name="locationContext" value="
                concat(' | Location &lt;templateAssociation ', string-join(for $att in (ancestor::templateAssociation/(@templateId, @effectiveDate), ($tm, $tmref)[1]/(@name, @statusCode, @versionLabel)) return concat(name($att), '=&#34;', $att, '&#34;'), ' '),
                    ' ',
                    string-join((
                    for $att in (@ref, @effectiveDate, $detype/@type, $dename, $de/@statusCode, $de/@versionLabel, @url[not(. = $deeplinkprefixservices)], @ident) 
                        return 
                            concat('concept', upper-case(substring(name($att), 1, 1)), substring(name($att), 2), '=&#34;', $att, '&#34;')
                    ), ' '),
                    '/&gt;')"/>
            
            <sch:let name="el" value="$tm//element[@id = $elid] | $tm//attribute[@id = $elid]"/>
            <sch:assert role="error" test="@elementId and not(@elementPath)"
                >ERROR: templateAssociation <sch:name/> SHALL only have an @elementId.<sch:value-of select="$locationContext"/></sch:assert>
            <!-- skip @ident as these are compiled in and not a problem -->
            <sch:assert role="info" test="$isDecorCompiled or $tm[@statusCode = $statusCodesInactive] | @ident | $de"
                >INFO: templateAssociation <sch:name/> SHOULD be bound to a dataset concept.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not($tm) or $tm[@statusCode = $statusCodesInactive] or $el"
                >ERROR: templateAssociation <sch:name/><sch:value-of select="if ($tm/@ident) then concat(' (repository ', $tm/@ident, ')') else ()"/> SHALL be bound to an element with the indicated id '<sch:value-of select="$elid"/>' in the indicated template with the same id and effectiveDate.<sch:value-of select="$locationContext"/></sch:assert>
            
            <sch:assert role="warning" test="not($el) or not($detype[@type = 'item']) or ($detype/valueDomain[@type = 'boolean'] | $el[@datatype] | $el/attribute[@name = 'negationInd'] | $el/attribute[@negationInd])"
                >WARNING: templateAssociation <sch:name/><sch:value-of select="if ($tm/@ident) then concat(' (repository ', $tm/@ident, ')') else ()"/> '<sch:value-of select="$detype/name[1]"/>' type='item' (<sch:value-of select="$detype/valueDomain/@type"/>) corresponds to template <sch:value-of select="name($el[1])"/> (<sch:value-of select="$el[1]/@name"/>) without datatype or negationInd.<sch:value-of select="$locationContext"/></sch:assert>
            
            <sch:let name="assocsbyid" value="if ($isDecorCompiled) then $de/terminologyAssociation[@conceptId = $deid] else $allTerminologyAssociations[@conceptId = $de/@id]"/>
            <sch:let name="assocs" value="if ($deIsNewest) then $assocsbyid[@conceptFlexibility = $de/@effectiveDate] | $assocsbyid[not(@conceptFlexibility)] | $assocsbyid[@conceptFlexibility = 'dynamic'] else $assocsbyid[@conceptFlexibility = $de/@effectiveDate]"/>
            <sch:let name="tempElement" value="$el[matches(@name, '^[^:]+:value')][matches(parent::element/lower-case(@name), '^[^:]+:\S*observation')]/preceding-sibling::element[matches(@name, '^[^:]+:code')]"/>
            <sch:let name="theCodes" value="$tempElement/vocabulary/concat(@code, ' / ', @codeSystem), string-join(($tempElement/attribute[@name = 'code']/@value, $tempElement/attribute[@name = 'codeSystem']/@value), ' / ')[not(. = '')]"/>
            
            <sch:report role="info" test="starts-with($deid, concat($projectId, '.')) and @code and not($de)"
                >INFO: templateAssociation <sch:name/>/@conceptId='<sch:value-of select="$deid"/>' SHOULD point to an existing concept.<sch:value-of select="$locationContext"/></sch:report>
            <sch:report role="info" test="not(starts-with($deid, concat($projectId, '.'))) and @code and not($de)"
                >INFO: templateAssociation <sch:name/>/@conceptId='<sch:value-of select="$deid"/>' from different project is not pointing to an existing concept.<sch:value-of select="$locationContext"/></sch:report>
            <!-- debug check only -->
            <!--<sch:assert role="error" test="not($de) or not($assocsbyid) or $assocs"
                >WARNING: Template association <sch:name/>/@conceptId='<sch:value-of select="$deid"/>' <sch:value-of select="concat('''', $de/name[string-length() gt 0][1], '''')"/> SHOULD have a concept terminology association.<sch:value-of select="$locationContext"/></sch:assert>-->
            
            <sch:assert role="warning" test="not($tempElement) or not($assocs) or $tm[@statusCode = $statusCodesInactive] or $assocs[concat(@code, ' / ', @codeSystem) = $theCodes]"
                >WARNING: templateAssociation element '<sch:value-of select="$el/../@name"/>/<sch:value-of select="$el/@name"/>' is under an observation with a different code than the dataset concept <sch:value-of select="$deid"/> <sch:value-of select="concat(' ''', $detype/name[string-length() gt 0][1], '''')"/>. Found code / codeSystem="<sch:value-of select="string-join($theCodes, ' or ')"/>", expected code / codeSystem="<sch:value-of select="string-join(distinct-values($assocs/concat(@code, ' / ', @codeSystem)), ' or ')"/>".<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        
        <sch:title>Validate Questionnaire Association Definition</sch:title>
        <sch:rule context="rules/questionnaireAssociation">
            <sch:let name="tmid" value="@questionnaireId"/>
            <sch:let name="tmed" value="@questionnaiteEffectiveDate"/>
            
            <sch:let name="tmbyid" value="$allQuestionnaires[@id = $tmid]"/>
            <sch:let name="tm" value="if ($tmed) then $tmbyid[@effectiveDate = $tmed] else $tmbyid[@effectiveDate = max($tmbyid/xs:dateTime(@effectiveDate))]"/>
            <sch:let name="tmref" value="$allQuestionnaires[@ref = $tmid]"/>
            <sch:let name="locationContext" value="
                concat(' | Location &lt;questionnaireAssociation ', string-join(for $att in (@*, ($tm, $tmref)[1]/(@name, @statusCode, @versionLabel))
                return
                concat(name($att), '=&#34;', $att, '&#34;')
                , ' '), '/&gt;')"/>
            
            <sch:assert role="error" test="$tm | $tmref"
                >ERROR: <sch:name/> SHALL be bound to an existing questionnaire or questionnaire reference.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="count($allQuestionnaireAssociations[@templateId = $tmid][@effectiveDate = $tmed]) le 1"
                >ERROR: There SHALL be 0..1 questionnaire association per questionnaire (<sch:value-of select="$tmid"/> - <sch:value-of select="$tmed"/>).<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        
        <sch:title>Validate Questionnaire Association Concept</sch:title>
        <sch:rule context="rules/questionnaireAssociation/concept">
            <sch:let name="deid" value="@ref"/>
            <sch:let name="deed" value="@effectiveDate[not(. = 'dynamic')]"/>
            <sch:let name="tmid" value="parent::questionnaireAssociation/@questionnaireId"/>
            <sch:let name="tmed" value="parent::questionnaireAssociation/@questionnaireEffectiveDate"/>
            <sch:let name="elid" value="@elementId"/>
            
            <sch:let name="debyid" value="$allDatasetConcepts[@id = $deid]"/>
            <sch:let name="deNewest" value="max($debyid/xs:dateTime(@effectiveDate))"/>
            <sch:let name="de" value="if ($deed) then $debyid[@effectiveDate = $deed] else $debyid[@effectiveDate = $deNewest]"/>
            <sch:let name="deIsNewest" value="$de/@effectiveDate = $deNewest"/>
            
            <sch:let name="inhbyid1" value="if ($de[@type]) then () else $allDatasetConcepts[@id = $de/inherit/@ref]"/>
            <sch:let name="inhc1" value="if ($de[@type]) then () else if ($de/inherit/@effectiveDate) then $inhbyid1[@effectiveDate = $de/inherit/@effectiveDate] else $inhbyid1[@effectiveDate = max($inhbyid1/xs:dateTime(@effectiveDate))]"/>
            <sch:let name="inhbyid2" value="if ($de[@type]) then () else $allDatasetConcepts[@id = $inhc1/inherit/@ref]"/>
            <sch:let name="inhc2" value="if ($de[@type]) then () else if ($inhc1/inherit/@effectiveDate) then $inhbyid2[@effectiveDate = $inhc1/inherit/@effectiveDate] else $inhbyid2[@effectiveDate = max($inhbyid2/xs:dateTime(@effectiveDate))]"/>
            <sch:let name="inhbyid3" value="if ($de[@type]) then () else $allDatasetConcepts[@id = $inhc2/inherit/@ref]"/>
            <sch:let name="inhc3" value="if ($de[@type]) then () else if ($inhc2/inherit/@effectiveDate) then $inhbyid3[@effectiveDate = $inhc2/inherit/@effectiveDate] else $inhbyid3[@effectiveDate = max($inhbyid3/xs:dateTime(@effectiveDate))]"/>
            <sch:let name="detype" value="($de, $inhc1, $inhc2, $inhc3)[@type][1]"/>
            <sch:let name="dename" value="($de, $inhc1, $inhc2, $inhc3)[name][1]/name[not(. = '')][1]"/>
            
            <sch:let name="tmbyid" value="$allQuestionnaires[@id = $tmid]"/>
            <sch:let name="tm" value="if ($tmed) then $tmbyid[@effectiveDate = $tmed] else $tmbyid[@effectiveDate = max($tmbyid/xs:dateTime(@effectiveDate))]"/>
            <sch:let name="tmref" value="$allQuestionnaires[@ref = $tmid]"/>
            <sch:let name="locationContext" value="
                concat(' | Location &lt;questionnaireAssociation ', string-join(for $att in (ancestor::questionnaireAssociation/(@templateId, @effectiveDate), ($tm, $tmref)[1]/(@name, @statusCode, @versionLabel)) return concat(name($att), '=&#34;', $att, '&#34;'), ' '),
                ' ',
                string-join((
                for $att in (@ref, @effectiveDate, $detype/@type, $dename, $de/@statusCode, $de/@versionLabel, @url[not(. = $deeplinkprefixservices)], @ident) 
                return 
                concat('concept', upper-case(substring(name($att), 1, 1)), substring(name($att), 2), '=&#34;', $att, '&#34;')
                ), ' '),
                '/&gt;')"/>
            
            <sch:let name="el" value="$tm//item[@linkId = $elid]"/>
            <sch:assert role="error" test="@elementId and not(@elementPath)"
                >ERROR: questionnaireAssociation <sch:name/> SHALL only have an @elementId.<sch:value-of select="$locationContext"/></sch:assert>
            <!-- skip @ident as these are compiled in and not a problem -->
            <sch:assert role="info" test="$tm[@statusCode = $statusCodesInactive] | @ident | $de"
                >INFO: questionnaireAssociation <sch:name/> SHOULD be bound to a dataset concept.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not($tm) or $tm[@statusCode = $statusCodesInactive] or $el"
                >ERROR: questionnaireAssociation <sch:name/><sch:value-of select="if ($tm/@ident) then concat(' (repository ', $tm/@ident, ')') else ()"/> SHALL be bound to an item with the indicated linkId '<sch:value-of select="$elid"/>' in the indicated questionnaire with the same id and effectiveDate.<sch:value-of select="$locationContext"/></sch:assert>
            
            <!--<sch:assert role="warning" test="not($el) or not($detype[@type = 'item']) or ($detype/valueDomain[@type = 'boolean'] | $el[@datatype] | $el/attribute[@name = 'negationInd'] | $el/attribute[@negationInd])"
                >WARNING: questionnaireAssociation <sch:name/><sch:value-of select="if ($tm/@ident) then concat(' (repository ', $tm/@ident, ')') else ()"/> '<sch:value-of select="$detype/name[1]"/>' type='item' (<sch:value-of select="$detype/valueDomain/@type"/>) corresponds to questionnaire <sch:value-of select="name($el[1])"/> (<sch:value-of select="$el[1]/@name"/>) without type.<sch:value-of select="$locationContext"/></sch:assert>-->
            
            <sch:let name="assocsbyid" value="if ($isDecorCompiled) then $de/questionnaireAssociation[@conceptId = $deid] else $allTerminologyAssociations[@conceptId = $de/@id]"/>
            <sch:let name="assocs" value="if ($deIsNewest) then $assocsbyid[@conceptFlexibility = $de/@effectiveDate] | $assocsbyid[not(@conceptFlexibility)] | $assocsbyid[@conceptFlexibility = 'dynamic'] else $assocsbyid[@conceptFlexibility = $de/@effectiveDate]"/>
            <sch:let name="theCodes" value="$el/code/@code"/>
            
            <sch:report role="info" test="$isDecorCompiled or starts-with($deid, concat($projectId, '.')) and @code and not($de)"
                >INFO: questionnaireAssociation <sch:name/>/@conceptId='<sch:value-of select="$deid"/>' SHOULD point to an existing concept.<sch:value-of select="$locationContext"/></sch:report>
            <sch:report role="info" test="not(starts-with($deid, concat($projectId, '.'))) and @code and not($de)"
                >INFO: questionnaireAssociation <sch:name/>/@conceptId='<sch:value-of select="$deid"/>' from different project is not pointing to an existing concept.<sch:value-of select="$locationContext"/></sch:report>
            <!-- debug check only -->
            <!--<sch:assert role="error" test="not($de) or not($assocsbyid) or $assocs"
                >WARNING: Template association <sch:name/>/@conceptId='<sch:value-of select="$deid"/>' <sch:value-of select="concat('''', $de/name[string-length() gt 0][1], '''')"/> SHOULD have a concept terminology association.<sch:value-of select="$locationContext"/></sch:assert>-->
            
            <sch:assert role="warning" test="not($assocs) or $tm[@statusCode = $statusCodesInactive] or $assocs[@code = $theCodes]"
                >WARNING: questionnaireAssociation item '<sch:value-of select="$el/@linkId"/>/<sch:value-of select="$el/text[1]"/>' has a different code than the dataset concept <sch:value-of select="$deid"/> <sch:value-of select="concat(' ''', $detype/name[string-length() gt 0][1], '''')"/>. Found code="<sch:value-of select="string-join($theCodes, ' or ')"/>", expected code="<sch:value-of select="string-join(distinct-values($assocs/@code), ' or ')"/>".<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        
        <sch:title>Validate StructureDefinition Association Concept</sch:title>
        <sch:rule context="rules/structuredefinition/concept">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;structuredefinition ', string-join(for $att in ancestor::structuredefinition/(@displayName, @id, @version, @url[not(. = $deeplinkprefixservices)])
                return
                concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')"/>
            <sch:assert role="error" test="(@elementId | @elementPath) and not(@elementId and @elementPath)"
                >ERROR: A structuredefinition association SHALL have exclusively either @elementId or @elementPath, not both.<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        
        <sch:title>Validate Template</sch:title>
        <sch:rule context="rules/template[not(@statusCode = $statusCodesInactive)]">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;template ', string-join(for $att in ancestor-or-self::template[1]/(@id, @ref, @name, @displayName, @effectiveDate, @statusCode, @versionLabel, @url[not(. = $deeplinkprefixservices)], @ident)
                return
                concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')"/>
            <sch:extends rule="VersionAttributeConsistency"/>
            <sch:let name="tmid" value="@id"/>
            
            <sch:let name="contextElementTop" value="element[matches(@name, '^([^:]+:)?templateId(\[.*)?$')][attribute[not(@isOptional = 'true')][not(@prohibited = 'true')][@root = $tmid or (@name = 'root' and @value = $tmid)]]"/>
            <sch:let name="contextElementSub" value="*/element[matches(@name, '^([^:]+:)?templateId(\[.*)?$')][attribute[not(@isOptional = 'true')][not(@prohibited = 'true')][@root = $tmid or (@name = 'root' and @value = $tmid)]]"/>
            
            <sch:report role="warning" test="(context[@id = '*'] and $contextElementTop[empty(@minimumMultiplicity) or @minimumMultiplicity = '0']) or (context[@id = '**'] and $contextElementSub[empty(@minimumMultiplicity) or @minimumMultiplicity = '0'])"
                >WARNING: template/context <sch:value-of select="context/@id"/> with the matching templateId element with @root=<sch:value-of select="$tmid"/> has minimum cardinality 0 instead of 1.<sch:value-of select="$locationContext"/></sch:report>
            <sch:assert role="error" test="not(context[@id = '*']) or $contextElementTop"
                >ERROR: template/context <sch:value-of select="context/@id"/> SHALL have a top level, element with minimum cardinality > 0, named templateId (e.g. hl7:templateId) with a required attribute @root id (or name value pair) of that template.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(context[@id = '**']) or $contextElementSub"
                >ERROR: template/context <sch:value-of select="context/@id"/> SHALL have, immediately under the top level element, an element with minimum cardinality > 0, named templateId (e.g. hl7:templateId) with a required attribute @root id (or name value pair) of that template.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(context[@path = ('*', '**')])"
                >ERROR: Template context path SHALL be '/','//', or an xpath expression. Found '<sch:value-of select="context/@path"/>'.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(context[@path = ('**')]) or .[element][count(attribute | element | include | choice) = 1]"
                >ERROR: If template context id = '**' then template SHALL have exactly 1 element and SHALL NOT have other top level attributes/includes/choices. Found '<sch:value-of select="count(attribute | element | include | choice)"/>'.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(@id and (@*[name() = ('ref', 'flexibility')]))"
                >ERROR: A template with a @id SHALL NOT have attributes @ref or @flexibility.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(@ref and (@*[not(name() = ('ref', 'name', 'displayName', 'url', 'ident'))][empty(namespace-uri())] or *[not(name() = 'desc')]))"
                >ERROR: A template with a @ref SHALL NOT have other attributes than @name or @displayName and MAY have a description.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="@ref or (@effectiveDate and @statusCode)"
                >ERROR: A template SHALL have @ref or (@effectiveDate and @statusCode).<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="warning" test="not(ends-with(element[1]/@name, 'ClinicalDocument')) or context"
                >ERROR: A CDA Document Level Template with a ClinicalDocument element as root SHALL have a context, e.g. &lt;context path='/'/&gt;.<sch:value-of select="$locationContext"/></sch:assert>
            
            <sch:let name="allElementIds" value=".//element/@id | .//attribute/@id"/>
            <sch:let name="duplicateIds" value="for $elementId in $allElementIds return if (count($allElementIds[. = $elementId]) gt 1) then $elementId else ()"/>
            <sch:assert role="error" test="empty($duplicateIds)"
                >ERROR: Template element and attribute ids SHALL be unique with the same template id/version. Found duplicates: '<sch:value-of select="distinct-values($duplicateIds)"/>'.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:let name="format" value="(classification/@format, 'hl7v3xml1')[1]"/>
            <sch:let name="artdecor" value="'https://assets.art-decor.org/ADAR/rv/'"/>
            <sch:let name="datatypeFile" value="if ($format = 'hl7v3xml1') then ('DECOR-supported-datatypes.xml') else concat('DECOR-supported-datatypes-', $format, '.xml')"/>
            <!-- Extra $artdecor is necessary for supported in check-decor.xquery that will not resolve the file next to us (...sigh) -->
            <sch:let name="supportedDatatypes" value="if (doc-available($datatypeFile)) then doc($datatypeFile) else if (doc-available(concat($artdecor, $datatypeFile))) then doc(concat($artdecor, $datatypeFile)) else ()"/>
            <sch:assert role="error" test="$supportedDatatypes"
                >ERROR: Template does not have a supported classification/@format "<sch:value-of select="$format"/>" or <sch:value-of select="$datatypeFile"/> is missing.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:let name="isBBR" value="ancestor::*/@repository = 'true'"/>
            <sch:let name="isfromBBR" value="@url and @ident"/>
            <sch:report role="error" test="$isBBR and not($isfromBBR) and (.//element[not(@id)] | .//attribute[not(@id)])"
                >ERROR: Template is part of a building block repository and is missing one or more @id attributes on &lt;element/&gt; and/or &lt;attribute/&gt;. This may lead to problems on templates that use this template as prototype.<sch:value-of select="$locationContext"/>
            </sch:report>
            <sch:report role="warning" test="$isfromBBR and (.//element[not(@id)] | .//attribute[not(@id)])"
                >WARNING: Template is part of a foreign building block repository and is missing one or more @id attributes on &lt;element/&gt; and/or &lt;attribute/&gt;. This may lead to problems on templates that use this template as prototype. Please request the BBR maintaining parties to update their templates (@url="<sch:value-of select="@url"/>" and @prefix="<sch:value-of select="@ident"/>").<sch:value-of select="$locationContext"/>
            </sch:report>
        </sch:rule>
        
        <sch:title>Validate Template example</sch:title>
        <sch:rule context="rules/template[not(@statusCode = $statusCodesInactive)]/example[not(@type = 'error')]">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;template ', string-join(for $att in ancestor-or-self::template[1]/(@id, @ref, @name, @displayName, @effectiveDate, @statusCode, @versionLabel, @url[not(. = $deeplinkprefixservices)], @ident)
                return
                concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')"/>
            <sch:let name="tmid" value="../@id"/>
            
            <!-- https://art-decor.atlassian.net/browse/AD30-1467 When a template defines top level attributes but no top level element, 
                the example may or may not contain a top level element with those attributes. This means we also need to change perspective on where the code/templateId lives 
                When there is no top level example element, there will be no invalid top level attributes so skipping that check.
            -->
            
            <sch:let name="attributesTop" value="../attribute[@name][not(@prohibited = 'true')][@value | vocabulary/@code]"/>
            <sch:let name="valueSetsTop" value="
                for $vs in $allValueSets
                return 
                if ($attributesTop/vocabulary[@valueSet = $vs/@id][@flexibility = $vs/@effectiveDate]) then $vs else if ($attributesTop/vocabulary[@valueSet = $vs/@id]) then ($allValueSets[@id = $vs/@id][@effectiveDate = max($allValueSets[@id = $vs/@id]/xs:dateTime(@effectiveDate))]) else ()"/>
            
            <sch:let name="attributesSub" value="..[empty(attribute)][count(element) = 1]/element/attribute[@name][not(@prohibited = 'true')][@value | vocabulary/@code][not(vocabulary/@valueSet)]"/>
            <sch:let name="valueSetsSub" value="
                for $vs in $allValueSets
                return 
                if ($attributesSub/vocabulary[@valueSet = $vs/@id][@flexibility = $vs/@effectiveDate]) then $vs else if ($attributesSub/vocabulary[@valueSet = $vs/@id]) then ($allValueSets[@id = $vs/@id][@effectiveDate = max($allValueSets[@id = $vs/@id]/xs:dateTime(@effectiveDate))]) else ()"/>
            
            <!--<sch:let name="contextElementTop" value="..[empty(attribute)][count(element) = 1]/element[matches(@name, '^([^:]+:)?templateId(\[.*)?$')]/attribute[not(@isOptional = 'true')][not(@prohibited = 'true')][@root = $tmid or (@name = 'root' and @value = $tmid)]/(@root | @value)"/>
            <sch:let name="contextElementSub" value="..[count(element) = 1]/element/element[matches(@name, '^([^:]+:)?templateId(\[.*)?$')]/attribute[not(@isOptional = 'true')][not(@prohibited = 'true')][@root = $tmid or (@name = 'root' and @value = $tmid)]/(@root | @value)"/>-->
            <sch:let name="contextElementTop" value="(..[attribute], ..[empty(attribute)][count(element) = 1])[1]/element[matches(@name, '^([^:]+:)?templateId(\[.*)?$')]/attribute[not(@isOptional = 'true')][not(@prohibited = 'true')]/(@root | @value)"/>
            <sch:let name="contextElementSub" value="..[count(element) = 1]/element/element[matches(@name, '^([^:]+:)?templateId(\[.*)?$')]/attribute[not(@isOptional = 'true')][not(@prohibited = 'true')]/(@root | @value)"/>
            
            <sch:let name="codeElementTop" value="(..[attribute], ..[empty(attribute)][count(element) = 1])[1]/element[matches(@name, '^([^:]+:)?code(\[.*)?$')]/vocabulary[@code | @codeSystem]"/>
            <sch:let name="codeElementSub" value="..[count(element) = 1]/element/element[matches(@name, '^([^:]+:)?code(\[.*)?$')]/vocabulary[@code | @codeSystem]"/>
            
            <!-- When a template has a toplevel attribute defined, the example will have a root element e.g. art:placeholder so the templateId/code will be one level lower than expected -->
            <sch:let name="topLevelAttribute" value="exists($attributesTop)"/>
            <sch:let name="exampleAttributes" value="if ($attributesTop | $attributesSub) then */@* else ()"/>
            <sch:let name="misMatchingAttributesTop" value="if (count(*) = 1 and empty($valueSetsTop[.//completeCodeSystem | .//include | .//exclude])) then for $attr in $attributesTop return $exampleAttributes[name() = $attr/@name][not(. = ($attr/@value | $attr/vocabulary/@code | $valueSetsTop//@code))] else ()"/>
            <sch:let name="misMatchingAttributesSub" value="if ($topLevelAttribute or empty($valueSetsSub[.//completeCodeSystem | .//include | .//exclude])) then () else (for $attr in $attributesSub return $exampleAttributes[name() = $attr/@name][not(. = ($attr/@value | $attr/vocabulary/@code | $valueSetsSub//@code))])"/>
            <sch:let name="exampleTemplateId" value="
                if ($topLevelAttribute and count(*) = 1) then (
                    if ($contextElementTop) then */*:templateId else if ($contextElementSub) then */*/*:templateId else ()
                ) else
                if ($topLevelAttribute) then (
                    if ($contextElementTop) then *:templateId else if ($contextElementSub) then */*:templateId else ()
                ) else
                if ($contextElementTop) then *:templateId else 
                if ($contextElementSub) then */*:templateId else ()
            "/>
            <sch:let name="exampleCode" value="
                if ($topLevelAttribute and count(*) = 1) then (
                    if ($codeElementTop) then */*:code else if ($codeElementSub) then */*/*:code else ()
                ) else 
                if ($topLevelAttribute) then (
                    if ($codeElementTop) then *:code else if ($codeElementSub) then */*:code else ()
                ) else
                if ($codeElementTop) then *:code else if ($codeElementSub) then */*:code else ()"/>
            
            <sch:report role="error" test="count($misMatchingAttributesTop | $misMatchingAttributesSub) = 1"
                >ERROR: Example <sch:value-of select="count(preceding-sibling::example) + 1"/> attribute <sch:value-of select="($misMatchingAttributesTop | $misMatchingAttributesSub)/string-join(concat(name(), '=''', ., ''''), ' ')"/> does not match specified attribute value(s): <sch:value-of select="($attributesTop | $attributesSub)[@name = ($misMatchingAttributesTop | $misMatchingAttributesSub)/name()]/string-join(concat(@name, '=''', string-join((@value, vocabulary/@code), ' or '), ''''), ' ')"/>.<sch:value-of select="$locationContext"/></sch:report>
            <sch:report role="error" test="count($misMatchingAttributesTop | $misMatchingAttributesSub) gt 1"
                >ERROR: Example <sch:value-of select="count(preceding-sibling::example) + 1"/> attribute <sch:value-of select="($misMatchingAttributesTop | $misMatchingAttributesSub)/string-join(concat(name(), '=''', ., ''''), ' ')"/> do not match specified attribute values: <sch:value-of select="($attributesTop | $attributesSub)[@name = ($misMatchingAttributesTop | $misMatchingAttributesSub)/name()]/string-join(concat(@name, '=''', string-join((@value, vocabulary/@code), ' or '), ''''), ' ')"/>.<sch:value-of select="$locationContext"/></sch:report>
            
            <sch:report role="error" test="$contextElementTop and $exampleTemplateId/@root[not(. = $contextElementTop)]
                ">ERROR: Example <sch:value-of select="count(preceding-sibling::example) + 1"/> templateId/@root=<sch:value-of select="string-join(for $v in $exampleTemplateId/@root[not(. = $contextElementTop)] return concat('''', $v, ''''), ' or ')"/> does not match specified templateId/@root=<sch:value-of select="string-join(for $v in $contextElementTop return concat('''', $v, ''''), ' or ')"/>.<sch:value-of select="$locationContext"/></sch:report>
            <sch:report role="error" test="$contextElementSub and $exampleTemplateId/@root[not(. = $contextElementSub)]"
                >ERROR: Example <sch:value-of select="count(preceding-sibling::example) + 1"/> templateId/@root=<sch:value-of select="string-join(for $v in $exampleTemplateId/@root[not(. = $contextElementSub)] return concat('''', $v, ''''), ' or ')"/> does not match specified templateId/@root=<sch:value-of select="string-join(for $v in $contextElementSub return concat('''', $v, ''''), ' or ')"/>.<sch:value-of select="$locationContext"/></sch:report>
            
            <sch:report role="error" test="$codeElementTop[@code][@codeSystem] and not($codeElementTop/string-join((@code, @codeSystem), '') = $exampleCode/string-join((@code, @codeSystem), ''))"
                >ERROR: Example <sch:value-of select="count(preceding-sibling::example) + 1"/> code/@code='<sch:value-of select="$exampleCode/@code"/>' @codeSystem='<sch:value-of select="$exampleCode/@codeSystem"/>' does not match specified <sch:value-of select="for $v in $codeElementTop return concat('@code=''', $v/@code, ''' @codeSystem=''', $v/@codeSystem, '''')"/>.<sch:value-of select="$locationContext"/></sch:report>
            <sch:report role="error" test="$codeElementSub[@code][@codeSystem] and not($codeElementSub/string-join((@code, @codeSystem), '') = $exampleCode/string-join((@code, @codeSystem), ''))"
                >ERROR: Example <sch:value-of select="count(preceding-sibling::example) + 1"/> code/@code='<sch:value-of select="$exampleCode/@code"/>' @codeSystem='<sch:value-of select="$exampleCode/@codeSystem"/>' does not match specified <sch:value-of select="for $v in $codeElementSub return concat('@code=''', $v/@code, ''' @codeSystem=''', $v/@codeSystem, '''')"/>.<sch:value-of select="$locationContext"/></sch:report>
            
            <sch:report role="error" test="$codeElementTop[@codeSystem][empty(@code)] and not($codeElementTop/@codeSystem = $exampleCode/@codeSystem)"
                >ERROR: Example <sch:value-of select="count(preceding-sibling::example) + 1"/> code/@codeSystem='<sch:value-of select="$exampleCode/@codeSystem"/>' does not match specified <sch:value-of select="for $v in $codeElementTop return concat('@codeSystem=''', $v/@codeSystem, '''')"/>.<sch:value-of select="$locationContext"/></sch:report>
            <sch:report role="error" test="$codeElementSub[@codeSystem][empty(@code)] and not($codeElementSub/@codeSystem = $exampleCode/@codeSystem)"
                >ERROR: Example <sch:value-of select="count(preceding-sibling::example) + 1"/> code/@codeSystem='<sch:value-of select="$exampleCode/@codeSystem"/>' does not match specified <sch:value-of select="for $v in $codeElementSub return concat('@codeSystem=''', $v/@codeSystem, '''')"/>.<sch:value-of select="$locationContext"/></sch:report>
            
            <sch:report role="error" test="$codeElementTop[@code][empty(@codeSystem)] and not($codeElementTop/@code = $exampleCode/@code)"
                >ERROR: Example <sch:value-of select="count(preceding-sibling::example) + 1"/> code/@code='<sch:value-of select="$exampleCode/@code"/>' does not match specified <sch:value-of select="for $v in $codeElementTop return concat('@codeSystem=''', $v/@code, '''')"/>.<sch:value-of select="$locationContext"/></sch:report>
            <sch:report role="error" test="$codeElementSub[@code][empty(@codeSystem)] and not($codeElementSub/@code = $exampleCode/@code)"
                >ERROR: Example <sch:value-of select="count(preceding-sibling::example) + 1"/> code/@code='<sch:value-of select="$exampleCode/@code"/>' does not match specified <sch:value-of select="for $v in $codeElementSub return concat('@codeSystem=''', $v/@code, '''')"/>.<sch:value-of select="$locationContext"/></sch:report>
        </sch:rule>
        
        <sch:title>Validate Template context</sch:title>
        <sch:rule context="rules/template[not(@statusCode = $statusCodesInactive)]/context">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;template ', string-join(for $att in ancestor-or-self::template[1]/(@id, @ref, @name, @displayName, @effectiveDate, @flexibility, @statusCode, @versionLabel, @url[not(. = $deeplinkprefixservices)], @ident)
                return
                concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')"/>
            <sch:assert role="error" test="not(@id and @path)"
                >ERROR: template context SHALL have @id or @path, not both.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(@id) or @id = ('*', '**')"
                >ERROR: template context/@id SHALL be '*' or '**'.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(@path = '')"
                >ERROR: template context/@path SHALL NOT be empty.<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        
        <sch:title>Validate Template Relationship</sch:title>
        <sch:rule context="rules/template[not(@statusCode = $statusCodesInactive)]/relationship">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;template ', string-join(for $att in ancestor-or-self::template[1]/(@id, @ref, @name, @displayName, @effectiveDate, @flexibility, @statusCode, @versionLabel, @url[not(. = $deeplinkprefixservices)], @ident)
                return
                concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')"/>
            <sch:assert role="error" test="(@template or @model) and not(@template and @model)"
                >ERROR: template relationship SHALL have either <sch:name/>/@template or <sch:name/>/@model, and not both.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(@model) or @type = 'DRIV'"
                >ERROR: template relationship to a model SHALL be 'DRIV' (derived).<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(@template) or matches(@template, '^[0-9\.]+$')"
                >ERROR: template relationship/@template='<sch:value-of select="@template"/>' references SHALL be based on template/@id. References by @name quickly become ambiguous.<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        
        <sch:title>Validate Template Element</sch:title>
        <sch:rule context="rules/template[not(@statusCode = $statusCodesInactive)]//element">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;template ', string-join(for $att in ancestor-or-self::template[1]/(@id, @ref, @name, @displayName, @effectiveDate, @flexibility, @statusCode, @versionLabel, @url[not(. = $deeplinkprefixservices)], @ident)
                return
                concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')"/>
            <sch:extends rule="MultiplicityRange"/>
            <sch:extends rule="ValidateConformance"/>
            <sch:extends rule="ValidateIncludedOrContainedTemplate"/>
            <sch:extends rule="ValidateChoice"/>
            <sch:extends rule="ValidateTemplateParticleIdentity"/>
            
            <sch:assert role="error" test="not(references)"
                >ERROR: template &lt;references/&gt; SHALL NOT be used any more. Use rules/templateAssociation instead.<sch:value-of select="$locationContext"/></sch:assert>
            
            <sch:let name="format" value="(ancestor::template/classification/@format, 'hl7v3xml1')[1]"/>
            <sch:let name="artdecor" value="'https://assets.art-decor.org/ADAR/rv/'"/>
            <sch:let name="datatypeFile" value="if ($format = 'hl7v3xml1') then ('DECOR-supported-datatypes.xml') else concat('DECOR-supported-datatypes-', $format, '.xml')"/>
            <!-- Extra $artdecor is necessary for supported in check-decor.xquery that will not resolve the file next to us (...sigh) -->
            <sch:let name="supportedDatatypes" value="if (doc-available($datatypeFile)) then doc($datatypeFile) else if (doc-available(concat($artdecor, $datatypeFile))) then doc(concat($artdecor, $datatypeFile)) else ()"/>
            <sch:let name="dt" value="@datatype"/>
            <sch:let name="dtName" value="if (contains($dt, ':')) then substring-after($dt, ':') else ($dt)"/>
            
            <sch:assert role="error" test="not($supportedDatatypes) or not(@datatype) or $supportedDatatypes//(dataType | flavor)[@name = ($dt, $dtName)]"
                >ERROR: template element/@datatype '<sch:value-of select="@datatype"/>' SHALL be a supported datatype (reference file: <sch:value-of select="$datatypeFile"/>).<sch:value-of select="$locationContext"/></sch:assert>
            <sch:let name="elmpfx" value="substring-before(@name, ':')"/>
            <sch:let name="elmns" value="if ($elmpfx = ('hl7', 'cda')) then ('urn:hl7-org:v3') else if (string-length($elmpfx) gt 0) then (namespace-uri-for-prefix($elmpfx, .)) else ()"/>
            <!-- Filthy hack because eXist-db 2.2 will not yield data on in-memory nodes with namespace-uri-for-prefix(). The namespace declaration might exist nonetheless, e.g. as @sdtc:dummy-1, on the template node (compiled project), or the decor root node -->
            <!--<sch:report role="error" test=".[@name][$format = 'hl7v3xml1'][string-length($elmpfx) = 0 or string-length($elmns) = 0]"
                >ERROR: template element/@name='<sch:value-of select="@name"/>' SHALL have a known namespace prefix. Suggested prefix is hl7 or cda. Default namespace is 'urn:hl7-org:v3'. Found prefix / namespace: '<sch:value-of select="$elmpfx"/>' / '<sch:value-of select="$elmns"/>'.<sch:value-of select="$locationContext"/></sch:report>
            <sch:report role="error" test=".[@name][$format = 'hl7v2.5xml'][string-length($elmpfx) = 0 or string-length($elmns) = 0]"
                >ERROR: template element/@name='<sch:value-of select="@name"/>' SHALL have a known namespace prefix. Suggested prefix is hl7v2. Default namespace is 'urn:hl7-org:v2xml'. Found prefix / namespace: '<sch:value-of select="$elmpfx"/>' / '<sch:value-of select="$elmns"/>'.<sch:value-of select="$locationContext"/></sch:report>-->
            <sch:let name="elmname" value="substring-after(if (contains(@name, '[')) then substring-before(@name, '[') else (@name), concat($elmpfx, ':'))"/>
            <!--http://stackoverflow.com/questions/1631396/what-is-an-xsncname-type-and-when-should-it-be-used-->
            <sch:assert role="error" test="not(@name) or matches(@name, '^([^:\s]+:)?[^\d][A-Za-z\d\._-]*')"
                >ERROR: template element/@name='<sch:value-of select="($elmname, @name)[not(. = '')][1]"/>' SHALL be a QName without predicate between brackets.<sch:value-of select="$locationContext"/></sch:assert>
            
            <sch:let name="oldSchoolAttribute" value="attribute/(@classCode | @contextConductionInd | @contextControlCode | @determinerCode | @extension | @independentInd | @institutionSpecified | @inversionInd | @mediaType | @moodCode | @negationInd | @nullFlavor | @operator | @qualifier | @representation | @root | @typeCode | @unit | @use)"/>
            <sch:let name="allDefinedAttributeNames" value="attribute/@*[name() = $oldSchoolAttribute/name()]/name(), attribute/@name"/>
            <sch:assert role="error" test="count($allDefinedAttributeNames) = count(distinct-values($allDefinedAttributeNames))"
                >ERROR: template<sch:name/>/@name='<sch:value-of select="@name"/>' SHALL NOT define any attribute more than once on the same element.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="warning" test="empty($oldSchoolAttribute)"
                >WARNING: template <sch:name/>/@name='<sch:value-of select="@name"/>' SHOULD NOT use attribute shorthand for HL7 V3 attribute. Use is discouraged, please use @name='..' and optionally @value='..' instead.<sch:value-of select="$locationContext"/></sch:assert>
            
            <sch:report role="error" test="attribute[@id][count(@*[name() = $oldSchoolAttribute/name()]) gt 1]"
                >ERROR: template <sch:name/>/@name='<sch:value-of select="@name"/>' SHALL NOT contain attribute with multiple shorthands and @id as that would be ambiguous.<sch:value-of select="$locationContext"/></sch:report>
            
            <sch:let name="attributeNullFlavor" value="attribute[@nullFlavor][not(@prohibited = 'true')] | attribute[@name = 'nullFlavor'][not(@prohibited = 'true')]"/>
            <sch:let name="requiredParticles" value="attribute[not(@isOptional = 'false')][not(@prohibited = 'true')] | element[@minimumMultiplicity != '0'][not(@conformance = 'NP')] | vocabulary[@code] | vocabulary[@codeSystem]"/>
            <sch:let name="valueSets" value="
                for $vocabulary in vocabulary[@valueSet]
                return $allValueSets[@id = $vocabulary/@valueSet][@effectiveDate = $vocabulary/@flexibility] | $allValueSets[@id = $vocabulary/@valueSet][@effectiveDate = max($allValueSets[@id = $vocabulary/@valueSet]/xs:dateTime(@effectiveDate))]
                "/>
            <sch:let name="vsHasExceptions" value="$valueSets/conceptList/exception | $valueSets/conceptList/include[@exception = 'true']"/>
            <sch:let name="templateType" value="(ancestor::template/classification/@format, 'hl7v3xml1')[1]"/>
            <sch:let name="elementIsMandatory" value="@isMandatory = 'true'"/>
            <sch:let name="elementIsRequired" value="exists(@minimumMultiplicity[not(. = '0')])"/>
            <!-- cannot check valueSet/@ref so make exception for that situation... -->
            <sch:report role="info" test="not(ancestor::template[@statusCode = $statusCodesInactiveFinal]) and (empty(vocabulary[@valueSet]) or $valueSets[@id]) and $format = 'hl7v3xml1' and $dt and $elementIsRequired and not($elementIsMandatory) and not($attributeNullFlavor | $vsHasExceptions | $requiredParticles)"
                >INFO: template <sch:name/>/@name='<sch:value-of select="@name"/>' has @minimumMultiplicity > 0 and is not mandatory, but does not define any NullFlavor values (directly or through a value set). This effectively places all NullFlavors in scope, making it harder to implement.<sch:value-of select="$locationContext"/></sch:report>
        </sch:rule>
        
        <sch:title>Validate Template Include</sch:title>
        <sch:rule context="rules/template[not(@statusCode = $statusCodesInactive)]//include">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;template ', string-join(for $att in ancestor-or-self::template[1]/(@id, @ref, @name, @displayName, @effectiveDate, @flexibility, @statusCode, @versionLabel, @url[not(. = $deeplinkprefixservices)], @ident)
                return
                concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')"/>
            <sch:extends rule="MultiplicityRange"/>
            <sch:extends rule="ValidateConformance"/>
            <sch:extends rule="ValidateIncludedOrContainedTemplate"/>
            <sch:extends rule="ValidateChoice"/>
            <sch:extends rule="ValidateTemplateParticleIdentity"/>
        </sch:rule>
        
        <sch:title>Validate Template Choice</sch:title>
        <sch:rule context="rules/template[not(@statusCode = $statusCodesInactive)]//choice">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;template ', string-join(for $att in ancestor-or-self::template[1]/(@id, @ref, @name, @displayName, @effectiveDate, @flexibility, @statusCode, @versionLabel, @url[not(. = $deeplinkprefixservices)], @ident)
                return
                concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')"/>
            <sch:extends rule="MultiplicityRange"/>
            <sch:extends rule="ValidateChoice"/>
            
            <sch:assert role="error" test="count(element | include) ge 1"
                >ERROR: <sch:name/> SHALL have 1 or more element and/or include (containing elements) to choose from.<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        
        <sch:title>Validate Template Attribute</sch:title>
        <sch:rule context="rules/template[not(@statusCode = $statusCodesInactive)]//attribute">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;template ', string-join(for $att in ancestor-or-self::template[1]/(@id, @ref, @name, @displayName, @effectiveDate, @flexibility, @statusCode, @versionLabel, @url[not(. = $deeplinkprefixservices)], @ident)
                return
                concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')"/>
            <sch:extends rule="ValidateConformanceAttribute"/>
            <sch:extends rule="ValidateTemplateParticleIdentity"/>
            
            <sch:let name="format" value="(ancestor::template/classification/@format, 'hl7v3xml1')[1]"/>
            <sch:let name="artdecor" value="'https://assets.art-decor.org/ADAR/rv/'"/>
            <sch:let name="datatypeFile" value="if ($format = 'hl7v3xml1') then ('DECOR-supported-datatypes.xml') else concat('DECOR-supported-datatypes-', $format, '.xml')"/>
            <!-- Extra $artdecor is necessary for supported in check-decor.xquery that will not resolve the file next to us (...sigh) -->
            <sch:let name="supportedDatatypes" value="if (doc-available($datatypeFile)) then doc($datatypeFile) else if (doc-available(concat($artdecor, $datatypeFile))) then doc(concat($artdecor, $datatypeFile)) else ()"/>
            <sch:let name="dt" value="@datatype"/>
            <sch:let name="dtName" value="if (contains($dt, ':')) then substring-after($dt, ':') else ($dt)"/>
            <sch:let name="val" value="@value[not(. = '')]"/>
            
            <sch:let name="pdt" value="parent::*/@datatype"/>
            <sch:let name="pdtName" value="if (contains($pdt, ':')) then substring-after($pdt, ':') else ($pdt)"/>
            <sch:let name="xsiDtName" value="if (contains(.[@name = 'xsi:type']/@value, ':')) then substring-after(.[@name = 'xsi:type']/@value, ':') else (.[@name = 'xsi:type']/@value)"/>
            <sch:let name="dtIsFlavorAndXsiIsDatatype" value="if ($supportedDatatypes) then (exists($supportedDatatypes//(dataType | flavor)[@name = $pdtName]/ancestor-or-self::dataType[@name = $xsiDtName])) else (true())"/>
            
            <sch:assert role="error" test="not(@name) or matches(@name, '^([^:\s]+:)?[^\d][A-Za-z\d\._-]*$')"
                >ERROR: template attribute/@name='<sch:value-of select="@name"/>' SHALL be a valid QName.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="warning" test="not($pdtName and $xsiDtName) or $dtIsFlavorAndXsiIsDatatype"
                >WARNING: template attribute @xsi:type SHOULD NOT specify a value '<sch:value-of select="$xsiDtName"/>', or SHOULD specify a value that matches the element definition '<sch:value-of select="$pdtName"/>', or SHOULD specify a value that matches the base datatype when the element definition specifies a flavor.<sch:value-of select="$locationContext"/></sch:assert>
            
            <!-- Background: the check on valueSet does not consider code(System)s in the other vocabulary element and vice versa. So there will be errors about a valid codeSystem or a valid code regardless -->
            <!--<sch:assert role="warning" test="not(vocabulary[@valueSet] and vocabulary[@code or @codeSystem])"
                            >WARNING: combining vocabulary definitions based on a valueSet and based on a @code and/or @codeSystem is currently not supported in the schematron engine. Consider creating a valueSet that supports the specified combination.<sch:value-of select="$locationContext"/></sch:assert>-->
            <!--<sch:assert role="error" test="not(@id) or count(index-of(ancestor::template//@id,@id)) = 1"
                            >ERROR: Template attribute/@id='<sch:value-of select="@id"/>' SHALL be unique within the template (version). Found <sch:value-of select="count(index-of(ancestor::template//@id,@id))"/> occurrences.<sch:value-of select="$locationContext"/></sch:assert>-->
            <sch:assert role="error" test="not($supportedDatatypes) or not(@datatype) or $supportedDatatypes//(atomicDataType | flavor)[@name = ($dt, $dtName)]"
                >ERROR: template attribute/@datatype '<sch:value-of select="@datatype"/>' SHALL be a supported datatype (reference file: <sch:value-of select="$datatypeFile"/>).<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(contains(@value, '|'))"
                >ERROR: template attribute/@name='<sch:value-of select="@name"/>' SHOULD NOT have a choice as its @value ('<sch:value-of select="@value"/>'). The schematron engine will NOT support that and treat it as a literal string.<sch:value-of select="$locationContext"/></sch:assert>
            
            <sch:assert role="error" test="not($dt = ('bl', 'bn')) or not($val) or $val = ('true', 'false')"
                >ERROR: template attribute <sch:value-of select="@name"/>='<sch:value-of select="$val"/>' SHALL match the specified datatype '<sch:value-of select="$dt"/>' (true or false)</sch:assert>
            <sch:assert role="error" test="not($dt = ('uid')) or not($val) or matches($val, $OIDpattern) or matches($val, $UUIDpattern) or matches($val, $RUIDpattern)"
                >ERROR: template attribute <sch:value-of select="@name"/>='<sch:value-of select="$val"/>' SHALL match the specified datatype '<sch:value-of select="$dt"/>' (OID, UUID or RUID)</sch:assert>
            <sch:assert role="error" test="not($dt = ('oid')) or not($val) or matches($val, $OIDpattern)"
                >ERROR: template attribute <sch:value-of select="@name"/>='<sch:value-of select="$val"/>' SHALL match the specified datatype '<sch:value-of select="$dt"/>'</sch:assert>
            <sch:assert role="error" test="not($dt = ('uuid')) or not($val) or matches($val, $UUIDpattern)"
                >ERROR: template attribute <sch:value-of select="@name"/>='<sch:value-of select="$val"/>' SHALL match the specified datatype '<sch:value-of select="$dt"/>'</sch:assert>
            <sch:assert role="error" test="not($dt = ('ruid')) or not($val) or matches($val, $RUIDpattern)"
                >ERROR: template attribute <sch:value-of select="@name"/>='<sch:value-of select="$val"/>' SHALL match the specified datatype '<sch:value-of select="$dt"/>'</sch:assert>
            <sch:assert role="error" test="not($dt = ('cs')) or not($val) or not(matches($val, '\s'))"
                >ERROR: template attribute <sch:value-of select="@name"/>='<sch:value-of select="$val"/>' SHALL match the specified datatype '<sch:value-of select="$dt"/>' (no whitespace)</sch:assert>
            <sch:assert role="error" test="not($dt = ('ts')) or not($val) or matches($val, $TSpattern)"
                >ERROR: template attribute <sch:value-of select="@name"/>='<sch:value-of select="$val"/>' SHALL match the specified datatype '<sch:value-of select="$dt"/>'</sch:assert>
            <sch:assert role="error" test="not($dt = ('int')) or not($val) or matches($val, $INTdigits)"
                >ERROR: template attribute <sch:value-of select="@name"/>='<sch:value-of select="$val"/>' SHALL match the specified datatype '<sch:value-of select="$dt"/>'</sch:assert>
            <sch:assert role="error" test="not($dt = ('real')) or not($val) or matches($val, $REALdigits)"
                >ERROR: template attribute <sch:value-of select="@name"/>='<sch:value-of select="$val"/>' SHALL match the specified datatype '<sch:value-of select="$dt"/>'</sch:assert>
            <sch:assert role="error" test="not($dt = ('url')) or not($val) or $val castable as xs:anyURI"
                >ERROR: template attribute <sch:value-of select="@name"/>='<sch:value-of select="$val"/>' SHALL match the specified datatype '<sch:value-of select="$dt"/>'</sch:assert>
            
            <sch:assert role="error" test="empty($dt) or not(@name = 'root') or not($val) or matches($val, $OIDpattern) or matches($val, $UUIDpattern) or matches($val, $RUIDpattern)"
                >ERROR: template attribute <sch:value-of select="@name"/>='<sch:value-of select="$val"/>' SHALL match the datatype OID, UUID or RUID</sch:assert>
            <sch:assert role="error" test="not(@root) or matches(@root, $OIDpattern) or matches(@root, $UUIDpattern) or matches(@root, $RUIDpattern)"
                >ERROR: template attribute root='<sch:value-of select="@root"/>' SHALL match the datatype OID, UUID or RUID</sch:assert>
            
            <sch:assert role="error" test="empty($dt) or not(@name = 'codeSystem') or not($val) or matches($val, $OIDpattern) or matches($val, $UUIDpattern) or matches($val, $RUIDpattern)"
                >ERROR: template attribute <sch:value-of select="@name"/>='<sch:value-of select="$val"/>' SHALL match the datatype 'uid' (OID, UUID or RUID)</sch:assert>
            <sch:assert role="error" test="not(@codeSystem) or matches(@codeSystem, $OIDpattern) or matches(@codeSystem, $UUIDpattern) or matches(@codeSystem, $RUIDpattern)"
                >ERROR: template attribute codeSystem='<sch:value-of select="@codeSystem"/>' SHALL match the datatype 'uid' (OID, UUID or RUID)</sch:assert>
            
            <sch:assert role="error" test="empty($dt) or not(@name = 'code') or not($val) or not(matches($val, '\s'))"
                >ERROR: template attribute <sch:value-of select="@name"/>='<sch:value-of select="$val"/>' SHALL match the datatype 'cs' (no whitespace)</sch:assert>
            <sch:assert role="error" test="not(@code) or not(matches(@code, '\s'))"
                >ERROR: template attribute code='<sch:value-of select="@code"/>' SHALL match the datatype 'cs' (no whitespace)</sch:assert>
            
            <sch:assert role="error" test="empty($dt) or not(@name = 'nullFlavor') or not($val) or not(matches($val, '\s'))"
                >ERROR: template attribute <sch:value-of select="@name"/>='<sch:value-of select="$val"/>' SHALL match the datatype 'cs' (no whitespace)</sch:assert>
            <sch:assert role="error" test="not(@nullFlavor) or not(matches(@nullFlavor, '\s'))"
                >ERROR: template attribute nullFlavor='<sch:value-of select="@nullFlavor"/>' SHALL match the datatype 'cs' (no whitespace)</sch:assert>
            
            <sch:assert role="error" test="empty($dt) or not(@name = 'xsi:nil') or not($val) or $val = ('true', 'false')"
                >ERROR: template attribute <sch:value-of select="@name"/>='<sch:value-of select="$val"/>' SHALL match the datatype 'bl' (true or false)</sch:assert>
            <sch:assert role="error" test="empty($dt) or not(@name = 'xsi:nil') or not($val) or $val = ('true', 'false')"
                >ERROR: template attribute <sch:value-of select="@name"/>='<sch:value-of select="$val"/>' SHALL match the datatype 'bl' (true or false)</sch:assert>
            <!-- CDA -->
            <!-- eXist-db 2.2 (2017-05-25) When you use "castable as". it leads to a seemingly unrelated error in decor-check.xquery due to Saxon-PE:
                 <exception>
                    <path>/db/apps/art/modules/check-decor.xquery</path>
                    <message>exerr:ERROR Exception while transforming node: Ambiguous rule match for /decor/datasets[1]/dataset[1]/concept[1]
                        ERROR XFormsServer  -     Matches both "datasets/dataset//concept[not(ancestor::history)][not(parent::conceptList)][@id]" on line -1 of 
                        ERROR XFormsServer  -     and "node()" on line -1 of  [at line 42, column 40]
                        ERROR XFormsServer  -     In function:
                        ERROR XFormsServer  -     	local:validate-iso-schematron-svrl(item(), item()) [115:17:/db/apps/art/modules/check-decor.xquery]</message>
                 </exception>
            -->
            <sch:assert role="error" test="not($dt = ('xs:ID')) or not($val) or matches($val, '^([\i-[:]][\c-[:]]*)$')"
                >ERROR: template attribute <sch:value-of select="@name"/>='<sch:value-of select="$val"/>' SHALL match the specified datatype '<sch:value-of select="$dt"/>'</sch:assert>
            <sch:assert role="error" test="not($dt = ('xs:IDREF')) or not($val) or matches($val, '^([\i-[:]][\c-[:]]*)$')"
                >ERROR: template attribute <sch:value-of select="@name"/>='<sch:value-of select="$val"/>' SHALL match the specified datatype '<sch:value-of select="$dt"/>'</sch:assert>
            <!-- this needs xpath 3.0 enabled -->
            <sch:assert role="error" test="not($dt = ('xs:IDREFS')) or not($val) or matches($val, '^([\i-[:]][\c-[:]]*)+( [\i-[:]][\c-[:]]*)*$')"
                >ERROR: template attribute <sch:value-of select="@name"/>='<sch:value-of select="$val"/>' SHALL match the specified datatype '<sch:value-of select="$dt"/>'</sch:assert>
        </sch:rule>
        
        <sch:title>Validate Property</sch:title>
        <sch:rule context="rules/template[not(@statusCode = $statusCodesInactive)]//element/property">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;template ', string-join(for $att in ancestor-or-self::template[1]/(@id, @ref, @name, @displayName, @effectiveDate, @flexibility, @statusCode, @versionLabel, @url[not(. = $deeplinkprefixservices)], @ident)
                return
                concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')"/>
            <sch:assert role="error" test="not(@* except (@unit | @minInclude | @maxInclude | @fractionDigits)) or not(@* except (@currency | @minInclude | @maxInclude | @fractionDigits)) or not(@* except (@minLength | @maxLength)) or not(@* except (@value))"
                >ERROR: template element property SHALL contain any of these combinations of attributes: (@unit @minInclude @maxInclude @fractionDigits) or (@currency @minInclude @maxInclude @fractionDigits) or (@minLength @maxLength) or (@value)<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        
        <sch:title>Validate Template Element and Attribute Vocabulary</sch:title>
        <sch:rule context="rules/template[not(@statusCode = $statusCodesInactive)]//vocabulary">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;template ', string-join(for $att in ancestor-or-self::template[1]/(@id, @ref, @name, @displayName, @effectiveDate, @flexibility, @statusCode, @versionLabel, @url[not(. = $deeplinkprefixservices)], @ident)
                return
                concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')"/>
            <sch:let name="vsid" value="@valueSet"/>
            <sch:let name="vsed" value="@flexibility[not(. = 'dynamic')]"/>
            
            <sch:let name="vsbyid" value="$allValueSets[@id = $vsid]"/>
            <sch:let name="vs" value="if ($vsed) then $vsbyid[@effectiveDate = $vsed] else $vsbyid[@effectiveDate = max($vsbyid/xs:dateTime(@effectiveDate))]"/>
            <sch:let name="vsref" value="$allValueSets[@ref = $vsid]"/>
            
            <sch:assert role="error" test="not(@valueSet) or count(@* except (@valueSet | @flexibility)) = 0"
                >ERROR: template <sch:name/>/@valueSet SHALL NOT co-occur with any other attribute than @flexibility.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(@domain) or count(@* except (@domain)) = 0"
                >ERROR: template <sch:name/>/@domain SHALL NOT co-occur with any other attribute.<sch:value-of select="$locationContext"/></sch:assert>
            
            <sch:report role="error" test="$vsid and $isDecorCompiled and empty($vs)"
                >ERROR: template <sch:name/>/@<sch:value-of select="name($vsid)"/>='<sch:value-of select="$vsid"/>' SHALL point to a valueSet with flexibility '<sch:value-of select="($vsed, 'dynamic')[1]"/>'. In a compiled project, all references are expected to be resolved.<sch:value-of select="$locationContext"/></sch:report>
            <sch:report role="error" test="$vsid and not($isDecorCompiled) and starts-with($vsid, concat($projectId, '.')) and empty($vs | $vsref)"
                >ERROR: template <sch:name/>/@<sch:value-of select="name($vsid)"/>='<sch:value-of select="$vsid"/>' SHALL point to a valueSet '<sch:value-of select="($vsed, 'dynamic')[1]"/>' or reference.<sch:value-of select="$locationContext"/></sch:report>
            <sch:report role="info" test="$vsid and not($isDecorCompiled) and not(starts-with($vsid, concat($projectId, '.'))) and empty($vs | $vsref)"
                >INFO: template <sch:name/>/@<sch:value-of select="name($vsid)"/>='<sch:value-of select="$vsid"/>' doesn't point to any valueSet '<sch:value-of select="($vsed, 'dynamic')[1]"/>' or reference. This resolves itself in compilation if possible. To add this valueSet to view, consider adding a reference for it.<sch:value-of select="$locationContext"/></sch:report>
            
            <!-- prepare for FHIR canonicals, but beware: we don't know how to get $vs yet if we get one... -->
            <sch:assert role="error" test="not($vsid) or matches($vsid, '^[0-9\.]+$') or starts-with($vsid, 'http')"
                >ERROR: <sch:name/>/@valueSet='<sch:value-of select="$vsid"/>' references SHALL be based on valueSet/@id. References by @name quickly become ambiguous.<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        
        <sch:title>Validate Questionnaire Item AnswerValueSet</sch:title>
        <sch:rule context="rules/questionnaire[not(@statusCode = $statusCodesInactive)]//answerValueSet">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;questionnaire ', string-join(for $att in ancestor-or-self::questionnaire[1]/(@id, @ref, @name, @displayName, @effectiveDate, @flexibility, @statusCode, @versionLabel, @url[not(. = $deeplinkprefixservices)], @ident)
                return
                concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')"/>
            <sch:let name="vsid" value="@ref"/>
            <sch:let name="vsed" value="@flexibility[not(. = 'dynamic')]"/>
            
            <sch:let name="vsbyid" value="$allValueSets[@id = $vsid]"/>
            <sch:let name="vs" value="if ($vsed) then $vsbyid[@effectiveDate = $vsed] else $vsbyid[@effectiveDate = max($vsbyid/xs:dateTime(@effectiveDate))]"/>
            <sch:let name="vsref" value="$allValueSets[@ref = $vsid]"/>
            
            <sch:report role="error" test="$vsid and $isDecorCompiled and empty($vs)"
                >ERROR: questionnaire <sch:name/>/@<sch:value-of select="name($vsid)"/>='<sch:value-of select="$vsid"/>' SHALL point to a valueSet with flexibility '<sch:value-of select="($vsed, 'dynamic')[1]"/>'. In a compiled project, all references are expected to be resolved.<sch:value-of select="$locationContext"/></sch:report>
            <sch:report role="error" test="$vsid and not($isDecorCompiled) and starts-with($vsid, concat($projectId, '.')) and empty($vs | $vsref)"
                >ERROR: questionnaire <sch:name/>/@<sch:value-of select="name($vsid)"/>='<sch:value-of select="$vsid"/>' SHALL point to a valueSet '<sch:value-of select="($vsed, 'dynamic')[1]"/>' or reference.<sch:value-of select="$locationContext"/></sch:report>
            <sch:report role="info" test="$vsid and not($isDecorCompiled) and not(starts-with($vsid, concat($projectId, '.'))) and empty($vs | $vsref)"
                >INFO: questionnaire <sch:name/>/@<sch:value-of select="name($vsid)"/>='<sch:value-of select="$vsid"/>' doesn't point to any valueSet '<sch:value-of select="($vsed, 'dynamic')[1]"/>' or reference. This resolves itself in compilation if possible. To add this valueSet to view, consider adding a reference for it.<sch:value-of select="$locationContext"/></sch:report>
            
            <!-- prepare for FHIR canonicals, but beware: we don't know how to get $vs yet if we get one... -->
            <sch:assert role="error" test="not($vsid) or matches($vsid, '^[0-9\.]+$') or starts-with($vsid, 'http')"
                >ERROR: <sch:name/>/@valueSet='<sch:value-of select="$vsid"/>' references SHALL be based on valueSet/@id. References by @name quickly become ambiguous.<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        
        <sch:title>Validate Template constraint, let, defineVariable, assert, report</sch:title>
        <sch:rule context="rules/template[not(@statusCode = $statusCodesInactive)]//constraint | 
                           rules/template[not(@statusCode = $statusCodesInactive)]//let | 
                           rules/template[not(@statusCode = $statusCodesInactive)]//defineVariable | 
                           rules/template[not(@statusCode = $statusCodesInactive)]//assert | 
                           rules/template[not(@statusCode = $statusCodesInactive)]//report">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;template ', string-join(for $att in ancestor-or-self::template[1]/(@id, @ref, @name, @displayName, @effectiveDate, @statusCode, @versionLabel, @url[not(. = $deeplinkprefixservices)], @ident)
                return
                concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')"/>
            <sch:extends rule="ValidateTemplateParticleIdentity"/>
        </sch:rule>
        
        <!-- ++++++++++++++++++++++ -->
        <!-- +++     ISSUES     +++ -->
        <!-- ++++++++++++++++++++++ -->
        <sch:title>Validate Issue Object</sch:title>
        <sch:rule context="issue/object">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;issue ', string-join(for $att in ancestor::issue[1]/(@id, @ref, @name, name[string-length() gt 0][1], @displayName, @effectiveDate, @flexibility, @statusCode, @versionLabel, @url[not(. = $deeplinkprefixservices)], @ident)
                return
                concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')"/>
            <sch:assert role="error" test="@id and @type"
                >ERROR: issue object SHALL have an id and a @type.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(@type = ('DS', 'DE', 'VS', 'TM', 'SC', 'TR')) or @effectiveDate"
                >ERROR: issue object of type <sch:value-of select="@type"/> SHALL have static @flexibility.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:report role="error" test="@type = 'CS' and starts-with(@id, ancestor::decor/project/@id) and empty(@effectiveDate)"
                >ERROR: issue object of type <sch:value-of select="@type"/> SHALL have static @flexibility.<sch:value-of select="$locationContext"/></sch:report>
        </sch:rule>
        
        <sch:title>Validate tracking/assignment labels</sch:title>
        <sch:rule context="issues/issue/tracking | issues/issue/assignment">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;issue ', string-join(for $att in ancestor::issue[1]/(@id, @ref, @name, name[string-length() gt 0][1], @displayName, @effectiveDate, @flexibility, @statusCode, @versionLabel, @url[not(. = $deeplinkprefixservices)], @ident)
                return
                concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')"/>
            
            <sch:let name="allLabels" value="ancestor::issues/labels/label/@code"/>
            <sch:let name="undefinedLabels" value="@labels/tokenize(., '\s')[not(. = $allLabels)]"/>
            <sch:report role="warning" test="not(empty($undefinedLabels))"
                >WARNING: issue <sch:name/> @labels SHOULD reference defined label codes. Found <sch:value-of select="$undefinedLabels"/>.<sch:value-of select="$locationContext"/></sch:report>
            <sch:assert role="error" test="xs:dateTime(@effectiveDate) = max((xs:dateTime(@effectiveDate), preceding-sibling::tracking/xs:dateTime(@effectiveDate), preceding-sibling::assignment/xs:dateTime(@effectiveDate)))"
                >ERROR: issue <sch:name/> SHALL be newer than its preceding events. Issue SHALL occur in descending date order.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:report role="error" test=".[@effectiveDate = (preceding-sibling::tracking/@effectiveDate | preceding-sibling::assignment/@effectiveDate)]"
                >ERROR: issue <sch:name/>/@effectiveDate SHALL NOT be equal to that of any of it's preceding siblings.<sch:value-of select="$locationContext"/></sch:report>
        </sch:rule>
        
        <!-- ++++++++++++++++++++++++ -->
        <!-- +++  QUESTIONNAIRE   +++ -->
        <!-- ++++++++++++++++++++++++ -->
        <sch:title>Validate questionnaire</sch:title>
        <sch:rule context="rules/questionnaire[not(ancestor-or-self::*/@statusCode = $statusCodesInactive)]">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;questionnaire ', string-join(for $att in (@id, @ref, @name, name[string-length() gt 0][1], @displayName, @effectiveDate, @flexibility, @statusCode, @versionLabel, @url[not(. = $deeplinkprefixservices)], @ident)
                return
                concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')"/>
            <sch:extends rule="VersionAttributeConsistency"/>
        </sch:rule>
        <sch:rule context="rules/questionnaire[not(@expirationDate)]//item">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;questionnaire ', string-join(for $att in ancestor::questionnaire[1]/(@id, @ref, @name, name[string-length() gt 0][1], @displayName, @effectiveDate, @flexibility, @statusCode, @versionLabel, @url[not(. = $deeplinkprefixservices)], @ident)
                return
                concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')"/>
            <!-- item checks -->
            <sch:assert role="error" test="not(@type='group' and (@maxLength|@minValue|@maxValue))"
                >ERROR: questionnaire/item of type 'group' SHALL not have any of these attributes @maxLength|@minValue|@maxValue.<sch:value-of select="$locationContext"/></sch:assert>
            <!-- http://hl7.org/fhir/questionnaire.html: invariants -->
            <sch:report id="que-1a" role="error" test="ancestor::questionnaire/@statusCode = 'final' and @type = 'group' and empty(item)"
                >ERROR: questionnaire/item of type <sch:value-of select="@type"/> SHALL have items (FHIR invariant que-1a).<sch:value-of select="$locationContext"/></sch:report>
            <sch:report id="que-1b" role="warning" test="ancestor::questionnaire/@statusCode = ('new', 'draft') and @type = 'group' and empty(item)"
                >WARNING: questionnaire/item of type <sch:value-of select="@type"/> SHOULD contain items (FHIR invariant que-1b).<sch:value-of select="$locationContext"/></sch:report>
            <sch:assert id="que-1c" role="error" test="not(@type = 'display' and code)"
                >ERROR: questionnaire/item of type <sch:value-of select="@type"/> SHALL NOT have code (FHIR invariant que-1c).<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="empty(answerValueSet) or empty(answerOption)"
                >ERROR: questionnaire/item SHALL NOT have both answerOption and answerValueSet (FHIR invariant que-4).<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert id="que-4" role="error" test="not(@type = ('group', 'display', 'question') and (answerValueSet | answerOption))"
                >ERROR: questionnaire/item of type <sch:value-of select="@type"/> SHALL NOT have answerOption and answerValueSet (FHIR invariant que-5).<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert id="que-6" role="error" test="not(@type = 'display' and (@repeats[. = 'true'] | @required[. = 'true']))"
                >ERROR: questionnaire/item of type <sch:value-of select="@type"/> SHALL NOT have @repeats or @required (FHIR invariant que-6).<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert id="que-8" role="error" test="not(@type = ('group', 'display') and initial)"
                >ERROR: questionnaire/item of type <sch:value-of select="@type"/> SHALL NOT have initial (FHIR invariant que-8).<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert id="que-9" role="error" test="not(@type = 'display' and @readOnly[. = 'true'])"
                >ERROR: questionnaire/item of type <sch:value-of select="@type"/> SHALL NOT have @readOnly (FHIR invariant que-9).<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert id="que-10" role="error" test="not(@type = ('boolean', 'decimal', 'integer', 'string', 'text', 'url') and @maxLength)"
                >ERROR: questionnaire/item of type <sch:value-of select="@type"/> SHALL NOT have @maxLength, only simple types can have this (FHIR invariant que-10).<sch:value-of select="$locationContext"/></sch:assert>
            <!--img que-11	Rule	Questionnaire.item	If one or more answerOption is present, initial cannot be present. Use answerOption.initialSelected instead	answerOption.empty() or initial.empty()-->
            <sch:assert id="que-12" role="error" test="not(count(enableWhen) gt 1 and empty(@enableBehavior))"
                >ERROR: questionnaire/item SHALL specify @enableBehavior when more than one enableWhen exists (FHIR invariant que-12).<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert id="que-13" role="error" test="@repeats = 'true' or count(initial) le 1"
                >ERROR: questionnaire/item SHALL NOT have multiple initial when item does not repeat (FHIR invariant que-13).<sch:value-of select="$locationContext"/></sch:assert>
            <!--img que-14	Warning	Questionnaire.item	Can only have answerConstraint if answerOption or answerValueSet are present. (This is a warning because extensions may serve the same purpose)	answerConstraint.exists() implies answerOption.exists() or answerValueSet.exists()-->
            <sch:assert id="que-15" role="warning" test="string-length(@linkId) le 255"
                >WARNING: questionnaire/item/@linkId SHALL NOT exceed 255 characters(FHIR invariant que-15).<sch:value-of select="$locationContext"/></sch:assert>
            
            <sch:assert role="error" test="count(answerValueSet) le 1"
                >ERROR: questionnaire/item SHALL NOT more than 1 answerValueSet. To mitigate you could create a singular value set that includes them. Found: <sch:value-of select="count(answerValueSet)"/>.<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        <sch:rule context="rules/questionnaire[not(@expirationDate)]//item/enableWhen">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;questionnaire ', string-join(for $att in ancestor::questionnaire[1]/(@id, @ref, @name, name[string-length() gt 0][1], @displayName, @effectiveDate, @flexibility, @statusCode, @versionLabel, @url[not(. = $deeplinkprefixservices)], @ident)
                return
                concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')"/>
            
            <sch:let name="questionId" value="@question"/>
            <sch:report role="error" test="ancestor::item[@linkId = $questionId]"
                >ERROR: questionnaire item enableWhen SHALL NOT depend on itself or an ancestor.<sch:value-of select="$locationContext"/></sch:report>
            <sch:assert role="error" test="ancestor::questionnaire//item[@linkId = $questionId]"
                >ERROR: questionnaire item enableWhen SHALL depend on an item contained in the same questionnaire. Found: <sch:value-of select="$questionId"/>.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:report role="error" test=".[@operator = ('&lt;', '&lt;=', '&gt;', '&gt;=')][answerBoolean | answerString | answerCoding]"
                >ERROR: questionnaire item enableWhen SHALL NOT depend on being <sch:value-of select="@operator"/> than a boolean, string or coding value.<sch:value-of select="$locationContext"/></sch:report>
            <sch:assert id="que-7" role="error" test="not(@operator = 'exists') or answerBoolean"
                >ERROR: questionnaire item enableWhen/@operator='<sch:value-of select="@operator"/>' SHALL have answerBoolean (FHIR invariant que-7).<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        
        <!-- ++++++++++++++++++++++ -->
        <!-- +++ ABSTRACT RULES +++ -->
        <!-- ++++++++++++++++++++++ -->
        <sch:title>Validate VersionAttributeConsistency</sch:title>
        <sch:rule abstract="true" id="VersionAttributeConsistency">
            <sch:assert role="error" test="(@id and @effectiveDate and @statusCode) or @ref"
                >ERROR: <sch:name/> SHALL have an @id and @effectiveDate and @statusCode, or a @ref.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(@id and @ref)"
                >ERROR: <sch:name/> SHALL NOT have both @id and @ref.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(@id and @flexibility)"
                >ERROR: <sch:name/> SHALL NOT have both @id and @flexibility.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(@ref) or not(@* except (@ref | @name | @displayName | @ident | @url | @isClosed[. = 'false'] | @caseSensitive[. = 'true'] | @*[not(namespace-uri() = '')]) | * except comment[parent::concept])"
                >ERROR: <sch:name/> with a @ref SHALL NOT have other elements<sch:value-of select="if (self::concept) then ' other than comment' else ()"/> or attributes than @name or @displayName. Found: <sch:value-of select="
                    string-join(
                    for $node in @* except (@ref | @name | @displayName | @ident | @url | @isClosed[. = 'false'] | @caseSensitive[. = 'true'] | @*[not(namespace-uri() = '')])
                    return concat('@', name($node))
                    , ', ')
                    "/>
                    .<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="info" test="not(@id) or * except (name | desc)"
                >INFO: <sch:name/> SHOULD have content if it wants to define something.<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        
        <sch:title>Validate MultiplicityRangeRequired</sch:title>
        <sch:rule abstract="true" id="MultiplicityRangeRequired">
            <sch:assert role="warning" test="@maximumMultiplicity = '*' or not(@minimumMultiplicity castable as xs:integer and @maximumMultiplicity castable as xs:integer) or xs:integer(@minimumMultiplicity) le xs:integer(@maximumMultiplicity)"
                >ERROR: <sch:name/> minimumMultiplicity='<sch:value-of select="@minimumMultiplicity"/>' SHALL be less than or equal to maximumMultiplicity='<sch:value-of select="@maximumMultiplicity"/>'.<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        
        <sch:title>Validate MultiplicityRange</sch:title>
        <sch:rule abstract="true" id="MultiplicityRange">
            <sch:assert role="warning" test="@maximumMultiplicity = ('*', '?') or not(@minimumMultiplicity castable as xs:integer and @maximumMultiplicity castable as xs:integer) or xs:integer(@minimumMultiplicity) le xs:integer(@maximumMultiplicity)"
                >ERROR: <sch:name/> minimumMultiplicity='<sch:value-of select="@minimumMultiplicity"/>' SHALL be less than or equal to maximumMultiplicity='<sch:value-of select="@maximumMultiplicity"/>'.<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        
        <sch:title>Validate Conformance</sch:title>
        <sch:rule abstract="true" id="ValidateConformance">
            <sch:let name="refid" value="if (@ref) then concat(' (ref=''', @ref, '''') else ()"/>
            <sch:assert role="error" test="not(@isMandatory = 'true' and @conformance = ('C', 'NP', 'O'))"
                >ERROR: <sch:name/><sch:value-of select="$refid"/><sch:value-of select="self::element/concat(' name=''', @name, '''')"/> SHALL NOT be mandatory and have @conformance = <sch:value-of select="@conformance"/>.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(@isMandatory = 'true' and @minimumMultiplicity = '0')"
                >ERROR: <sch:name/><sch:value-of select="$refid"/><sch:value-of select="self::element/concat(' name=''', @name, '''')"/> SHALL NOT be mandatory and have @minimumMultiplicity = 0.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(@isMandatory = 'true' and @maximumMultiplicity = '0')"
                >ERROR: <sch:name/><sch:value-of select="$refid"/><sch:value-of select="self::element/concat(' name=''', @name, '''')"/> SHALL NOT be mandatory and have @maximumMultiplicity = 0.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(@conformance = 'R' and @maximumMultiplicity = '0')"
                >ERROR: <sch:name/><sch:value-of select="$refid"/><sch:value-of select="self::element/concat(' name=''', @name, '''')"/> SHALL NOT have conformance = 'R' and have @maximumMultiplicity = 0.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(@isMandatory = 'true' and (attribute[@nullFlavor or @name = 'nullFlavor'][not(@isOptional = 'true')] | attribute[@name = 'xsi:nil'][@value = 'true'][not(@prohibited = 'true')]))"
                >ERROR: <sch:name/><sch:value-of select="$refid"/><sch:value-of select="self::element/concat(' name=''', @name, '''')"/> SHALL NOT be mandatory and require @nullFlavor or @xsi:nil = true.<sch:value-of select="$locationContext"/></sch:assert>
            
            <!-- transaction concepts have condition to explain conditions. template elements have constraint -->
            <sch:report role="error" test="@conformance[. = 'NP'] and (@minimumMultiplicity != '0' or @maximumMultiplicity != '0')"
                >ERROR: <sch:name/><sch:value-of select="$refid"/><sch:value-of select="self::element/concat(' name=''', @name, '''')"/> SHALL NOT have conformance=NP and min or max other than 0.<sch:value-of select="$locationContext"/></sch:report>
            <sch:assert role="error" test="not(self::concept[@conformance = 'C']) or condition or enableWhen"
                >ERROR: Conditional <sch:name/><sch:value-of select="$refid"/><sch:value-of select="self::element/concat(' name=''', @name, '''')"/> SHALL have condition/enableWhen to explain the condition.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="warning" test="not(self::element[@conformance = 'C']) or constraint or ../constraint"
                >WARNING: Conditional <sch:name/><sch:value-of select="self::element/concat(' name=''', @name, '''')"/> SHOULD have (a sibling) constraint to explain the condition.<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        
        <sch:title>Validate Conformance Attribute</sch:title>
        <sch:rule abstract="true" id="ValidateConformanceAttribute">
            <sch:let name="refid" value="if (@ref) then concat(' (ref=''', @ref, '''') else ()"/>
            <sch:assert role="error" test="not(@prohibited = 'true') or not(@isOptional = 'true')"
                >ERROR: <sch:name/><sch:value-of select="$refid"/> SHALL NOT be prohibited and "not optional".<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        
        <sch:title>Validate FreeFormMarkupWithLanguage</sch:title>
        <sch:rule abstract="true" id="FreeFormMarkupWithLanguage">
            <sch:let name="locationContext" value="concat(
                ' | Location &lt;', 
                if (ancestor::template) then
                    concat('template ', string-join(for $att in ancestor::template/@* return concat(name($att), '=&#34;', $att, '&#34;'), ' '), '&gt; ')
                else
                if (ancestor::valueSet) then
                    concat('valueSet ', string-join(for $att in ancestor::valueSet/@* return concat(name($att), '=&#34;', $att, '&#34;'), ' '), '&gt; ')
                else
                if (ancestor::codeSystem) then
                    concat('codeSystem ', string-join(for $att in ancestor::codeSystem/@* return concat(name($att), '=&#34;', $att, '&#34;'), ' '), '&gt; ')
                else (
                    concat(name(..), ' ', string-join(for $att in ../@* return concat(name($att), '=&#34;', $att, '&#34;'), ' '), '/&gt;')
                )
                , 
                '&gt;'
            )"/>
            <sch:assert role="error" test="not(preceding-sibling::*[name() = name(current())][@language = current()/@language])"
                >ERROR: Each repetition of <sch:value-of select="name(..)"/>/<sch:name/> with language SHALL be a different language.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="warning" test="@language"
                >WARNING: Each repetition of <sch:value-of select="name(..)"/>/<sch:name/> SHOULD be qualified with @language.<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        
        <sch:title>Validate Included or Contained Template</sch:title>
        <sch:rule abstract="true" id="ValidateIncludedOrContainedTemplate">
            <sch:let name="tmid" value="@contains | @ref"/>
            <sch:let name="tmed" value="@flexibility[not(. = 'dynamic')]"/>
            <sch:let name="tmbyid" value="$allTemplates[(@id | @name) = $tmid]"/>
            <sch:let name="tm" value="if ($tmed) then $tmbyid[@effectiveDate = $tmed] else $tmbyid[@effectiveDate = max($tmbyid/xs:dateTime(@effectiveDate))]"/>
            <sch:let name="tmref" value="$allTemplates[@ref = $tmid]"/>
            <sch:report role="error" test="$tmid and $isDecorCompiled and empty($tm)"
                >ERROR: template <sch:name/>/@<sch:value-of select="name($tmid)"/>='<sch:value-of select="$tmid"/>' SHALL point to a template with flexibility '<sch:value-of select="($tmed, 'dynamic')[1]"/>'. In a compiled project, all references are expected to be resolved.<sch:value-of select="$locationContext"/></sch:report>
            <sch:report role="error" test="$tmid and not($isDecorCompiled) and starts-with($tmid, concat($projectId, '.')) and empty($tm | $tmref)"
                >ERROR: template <sch:name/>/@<sch:value-of select="name($tmid)"/>='<sch:value-of select="$tmid"/>' SHALL point to a template '<sch:value-of select="($tmed, 'dynamic')[1]"/>' or reference.<sch:value-of select="$locationContext"/></sch:report>
            <sch:report role="info" test="$tmid and not($isDecorCompiled) and not(starts-with($tmid, concat($projectId, '.'))) and empty($tm | $tmref)"
                >INFO: template <sch:name/>/@<sch:value-of select="name($tmid)"/>='<sch:value-of select="$tmid"/>' doesn't point to any template '<sch:value-of select="($tmed, 'dynamic')[1]"/>' or reference. This resolves itself in compilation if possible. To add this template to view in ART, consider adding a reference for it.<sch:value-of select="$locationContext"/></sch:report>
            
            <sch:report role="info" test="$tmid and $tm[context/@path[not(. = '//')]] and not(parent::choice)"
                >INFO: template <sch:name/>/@<sch:value-of select="name($tmid)"/>='<sch:value-of select="$tmid"/>' flexibility '<sch:value-of select="($tmed, 'dynamic')[1]"/>' points to a template with context/@path='<sch:value-of select="$tm/context/@path"/>'. Best practice is to call this type of template only from a transaction. When called from another template, this context path is overridden by the context of the calling template.<sch:value-of select="$locationContext"/></sch:report>
            <sch:assert role="error" test="not($tmid) or matches($tmid, '^[0-9\.]+$')"
                >ERROR: template <sch:name/>/@<sch:value-of select="name($tmid)"/>='<sch:value-of select="$tmid"/>' references SHALL be based on template/@id. References by @name quickly become ambiguous.<sch:value-of select="$locationContext"/></sch:assert>
            
            <sch:let name="tcnt" value="count($tm/element | $tm/choice | $tm/include)"/>
            <sch:report role="warning" test="self::include[@minimumMultiplicity | @maximumMultiplicity | @conformance[not(. = 'R')] | @isMandatory] and $tcnt gt 1"
                >WARNING: template include references a template with multiple elements. If you specify multiplicity, conformance or isMandatory it applies to all of them.<sch:value-of select="$locationContext"/></sch:report>
            
            <sch:assert role="error" test="not(self::include) or not($tm/attribute) or parent::template or (parent::element and not(preceding-sibling::element | preceding-sibling::choice))"
                >ERROR: template <sch:name/>/@<sch:value-of select="name($tmid)"/>='<sch:value-of select="$tmid"/>' points to a template with top level attributes, but your context is not an element.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="info" test="count(parent::element/choice | parent::element/include | parent::element/element) != 1 or not(@ref and $tm[context/@id])"
                >INFO: template <sch:name/>/@<sch:value-of select="name($tmid)"/>='<sch:value-of select="$tmid"/>' points to a template with context/@id. Best practice when this include is the only content is to use element/@contains instead of include.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="info" test="not(@ref and $tm[context/@path[not(. = '//')]])"
                >INFO: template <sch:name/>/@<sch:value-of select="name($tmid)"/>='<sch:value-of select="$tmid"/>' points to a template with context/@path='<sch:value-of select="$tm/context/@path"/>'. Best practice is to call this type of template only from a transaction. When called from another template, this context path is overridden by the context of the calling template.<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        
        <sch:title>Validate Choice</sch:title>
        <sch:rule abstract="true" id="ValidateChoice">
            <sch:let name="choicemin" value="(self::choice[1]/@minimumMultiplicity[. castable as xs:integer], parent::choice[1]/@minimumMultiplicity[. castable as xs:integer], 0)[1]"/>
            <sch:let name="choicemax" value="(self::choice[1]/@maximumMultiplicity[. castable as xs:integer], parent::choice[1]/@maximumMultiplicity[. castable as xs:integer], '*')[1]"/>
            <sch:let name="childmin" value="@minimumMultiplicity"/>
            <sch:let name="childmax" value="@maximumMultiplicity"/>
            <sch:assert role="error" test="not($childmin and parent::choice) or not($choicemin castable as xs:integer and $childmin castable as xs:integer) or xs:integer($childmin) le xs:integer($choicemin)"
                >ERROR: <sch:name/>/@minimumMultiplicity '<sch:value-of select="$childmin"/>' SHALL be less than or equal to the parent choice/@minimumMultiplicity '<sch:value-of select="$choicemin"/>'.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not($childmax and parent::choice) or ($childmax = '*' and $choicemax = '*') or not($choicemax castable as xs:integer and $childmax castable as xs:integer) or xs:integer($childmax) le xs:integer($choicemax)"
                >ERROR: <sch:name/>/@maximumMultiplicity '<sch:value-of select="$childmax"/>' SHALL be less than or equal to the parent choice/@maximumMultiplicity '<sch:value-of
                    select="$choicemax"/>'.<sch:value-of select="$locationContext"/></sch:assert>
            
            <sch:let name="childrenmin" value="sum(*/xs:integer(@minimumMultiplicity[. castable as xs:integer]))"/>
            <sch:assert role="error" test="not(self::choice) or empty($childrenmin) or not($choicemin castable as xs:integer) or xs:integer($choicemin) ge $childrenmin"
                >ERROR: <sch:name/>/@minimumMultiplicity '<sch:value-of select="$choicemin"/>' SHALL be greater or equal than the sum of the minimumMultiplicities of its constituents '<sch:value-of select="$childmin"/>'.<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
        
        <sch:title>Validate Template Particle Identity</sch:title>
        <sch:rule abstract="true" id="ValidateTemplateParticleIdentity">
            <sch:let name="name" value="name()"/>
            <sch:let name="nodeIdentity" value="string-join(for $att in (@id, @ref, @contains, @name, @test, @language) return $att, '')"/>
            <sch:let name="duplicates" value="following-sibling::*[name() = $name][string-join(for $att in (@id, @ref, @contains, @name, @test, @language) return $att, '') = $nodeIdentity]"/>
            <sch:assert role="warning" test="empty($duplicates)"
                >WARNING: <sch:name/> has sibling <sch:name/> particle(s) that carry the same values for the attributes @id, @ref, @contains, @name, @test, @language.<sch:value-of select="if (self::let) then 'This is not allowed as per the ISO Schematron standard and will lead to issues with frameworks like SchXslt. ' else ()"/> This could lead to merge problems in editing templates based on this templates. Consider updating to make these particles distinct.<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <sqf:fixes>
        <sqf:fix id="replaceInheritWithIdOfOriginalConcept">
            <sqf:description xml:lang="en-US">
                <sqf:title>Fix inherit with original</sqf:title>
                <sqf:p>Replaces the current inherit/@ref and inherit/@effectiveDate with the @id/@effectiveDate of the original concept</sqf:p>
            </sqf:description>
            <sqf:replace match="inherit/@ref" node-type="attribute" target="ref">
                <sch:value-of select="$inhc/inherit/@ref"/>
            </sqf:replace>
            <sqf:replace match="inherit/@effectiveDate" node-type="attribute" target="effectiveDate">
                <sch:value-of select="$inhc/inherit/@effectiveDate"/>
            </sqf:replace>
        </sqf:fix>
        <sqf:fix id="addHyphenToPrefix">
            <sqf:description xml:lang="en-US">
                <sqf:title>Add Hyphen</sqf:title>
                <sqf:p>Adds a hyphen to the value in @prefix</sqf:p>
            </sqf:description>
            <sqf:replace match="@prefix" node-type="attribute" target="prefix">
                <sch:value-of select="concat(., '-')"/>
            </sqf:replace>
        </sqf:fix>
        <sqf:fix id="addHyphenToIdent">
            <sqf:description xml:lang="en-US">
                <sqf:title>Add Hyphen</sqf:title>
                <sqf:p>Adds a hyphen to the value in @ident</sqf:p>
            </sqf:description>
            <sqf:replace match="@ident" node-type="attribute" target="ident">
                <sch:value-of select="concat(., '-')"/>
            </sqf:replace>
        </sqf:fix>
        <sqf:fix id="addSlashToURL">
            <sqf:description xml:lang="en-US">
                <sqf:title>Add Slash</sqf:title>
                <sqf:p>Adds a slash to the value in @url</sqf:p>
            </sqf:description>
            <sqf:replace match="@url" node-type="attribute" target="url">
                <sch:value-of select="concat(., '/')"/>
            </sqf:replace>
        </sqf:fix>
        <sqf:fix id="addMissingBaseIds">
            <sqf:description xml:lang="en-US">
                <sqf:title>Add Missing BaseIds</sqf:title>
                <sqf:p>Adds missing baseId elements</sqf:p>
            </sqf:description>
            <sch:let name="bi" value="/decor/ids/baseId/@type"/>
            <sch:let name="b" value="/decor/project/@id"/>
            <sch:let name="p" value="/decor/project/@prefix"/>
            <sqf:add xmlns:xsl="http://www.w3.org/1999/XSL/Transform" match="//ids[not(baseId)]">
                <xsl:for-each select="$allTypes[not(. = $bi)]">
                    <xsl:variable name="pos" select="index-of($allTypes, .)"/>
                    <baseId id="{$b}.{$allExtensions[$pos]}" prefix="{$p}{lower-case(.)}-" type="{.}"/>
                </xsl:for-each>
            </sqf:add>
            <sqf:add xmlns:xsl="http://www.w3.org/1999/XSL/Transform" match="//ids/baseId[last()]" position="after">
                <xsl:for-each select="$allTypes[not(. = $bi)]">
                    <xsl:variable name="pos" select="index-of($allTypes, .)"/>
                    <baseId id="{$b}.{$allExtensions[$pos]}" prefix="{$p}{lower-case(.)}-" type="{.}"/>
                </xsl:for-each>
            </sqf:add>
        </sqf:fix>
        <sqf:fix id="addMissingDefaultBaseIds">
            <sqf:description xml:lang="en-US">
                <sqf:title>Add Missing DefaultBaseIds</sqf:title>
                <sqf:p>Adds missing defaultBaseId elements</sqf:p>
            </sqf:description>
            <sch:let name="bi" value="/decor/ids/baseId/@type"/>
            <sch:let name="dbi" value="/decor/ids/defaultBaseId/@type"/>
            <sch:let name="b" value="/decor/project/@id"/>
            <sch:let name="p" value="/decor/project/@prefix"/>
            <sqf:add xmlns:xsl="http://www.w3.org/1999/XSL/Transform" match="//ids[not(defaultBaseId | baseId)]">
                <xsl:for-each select="$allTypes[not(. = $dbi)]">
                    <xsl:variable name="type" select="."/>
                    <xsl:variable name="pos" select="index-of($allTypes, $type)"/>
                    <xsl:variable name="id" select="
                        if ($type = $bi) then
                        ($bi[. = $type]/../@id)[1]
                        else
                        (concat($b, '.', $allExtensions[$pos]))"/>
                    <defaultBaseId id="{$id}" type="{.}"/>
                </xsl:for-each>
            </sqf:add>
            <sqf:add xmlns:xsl="http://www.w3.org/1999/XSL/Transform" match="//ids/(defaultBaseId | baseId)[last()]" position="after">
                <xsl:for-each select="$allTypes[not(. = $dbi)]">
                    <xsl:variable name="type" select="."/>
                    <xsl:variable name="pos" select="index-of($allTypes, $type)"/>
                    <xsl:variable name="id" select="
                        if ($type = $bi) then
                        ($bi[. = $type]/../@id)[1]
                        else
                        (concat($b, '.', $allExtensions[$pos]))"/>
                    <defaultBaseId id="{$id}" type="{.}"/>
                </xsl:for-each>
            </sqf:add>
        </sqf:fix>
        <sqf:fix id="removeTypeAttribute">
            <sqf:description xml:lang="en-US">
                <sqf:title>Remove @type attribute</sqf:title>
                <sqf:p>Removes @type attribute from the focus element</sqf:p>
            </sqf:description>
            <sqf:delete match="@type"/>
        </sqf:fix>
        <sqf:fix id="addConceptParentsInTransaction">
            <sqf:description xml:lang="en-US">
                <sqf:title>Add Missing Parent Concepts</sqf:title>
                <sqf:p>Adds missing parent concepts to the transaction/representingTemplate</sqf:p>
            </sqf:description>
            <sqf:add xmlns:xsl="http://www.w3.org/1999/XSL/Transform" match="." position="before">
                <xsl:for-each select="$missingParentLevel">
                    <concept flexibility="{@effectiveDate}" maximumMultiplicity="*" minimumMultiplicity="0" ref="{@id}"/>
                </xsl:for-each>
            </sqf:add>
        </sqf:fix>
    </sqf:fixes>
</sch:schema>
