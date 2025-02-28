<?xml version="1.0" encoding="UTF-8"?>
<pattern id="xml" xmlns="http://purl.oclc.org/dsdl/schematron">
    <title>XML processing instruction and others</title>

    <title>Elements</title>
    <!-- Test op lege elementen, Place en patient als auteur van autorisatieprofielen of condities zijn uitgesloten, CAVE: some cda xhtml tags maybe empty! -->
    <!--<rule context="*[not(self::hl7:Place) and not(self::hl7:br) and not(self::hl7:p) and
        not(self::hl7:patient and (../../../hl7:consentDirective or ../../../hl7:IntoleranceCondition or ../../../hl7:Condition)) and
        not(*) and (not(@*) or (count(@*)=1 and @xsi:type)) and string-length(normalize-space(text()[1]))=0]">
        <assert role="error" test="not(.)">dtr1-7-XML: Elements SHALL have at least one attribute, a child element or non-empty element content</assert>
    </rule>-->
    <rule 
        context="*[self::hl7:text] and
        not(*) and (not(@*) or (count(@*)=1 and @xsi:type)) and string-length(normalize-space(text()[1]))=0]">
        <assert role="error" test="not(.)">dtr1-1-DE-XML: Elements SHALL have at least one attribute, a child element or non-empty element content</assert>
    </rule>
    
    <title>Attributes</title>
    <!-- Test op elementen met lege attributen -->
    <!-- AH: Merk op: als context="*" dan slaat de Schematron engine verder alle rules over. 
        Vandaar dat ik de * heb gewijzigd in onderstaande constructie waarna een rule staat 
        die gewoon altijd af moet gaan. Wellicht ziet het er vreemd uit, maar het werkt. -->
    <!--rule context="*[count(@*[string-length(normalize-space(.))=0])&gt;0]"-->
    <rule context="*[@*[normalize-space()='']]">
        <assert role="error" test="not(.)">dtr1-2-DE-XML: Attributes SHALL have a value</assert>
    </rule>
    <rule context="hl7:*[@xml:lang]">
        <assert role="error" test="not(.)"
            >dtr1-3-DE-XML: attribute @xml:lang is not permitted anywhere in HL7.</assert>
    </rule>
    
</pattern>
