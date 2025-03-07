<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    DTR1 CD.IPS - Concept Descriptor
    Status: draft
    TODO: check for codes/codesystems in translations
-->
<rule abstract="true" id="CD.IPS" xmlns="http://purl.oclc.org/dsdl/schematron">
    <extends rule="CD"/>
    
    <assert role="error" test="descendant-or-self::*[not(@code) or @displayName]" see="https://docs.art-decor.org/documentation/datatypes/DTr1_CD.IPS"
        >dtr1-1-CD.IPS: attribute @displayName is required on all codes and translations thereof</assert>
</rule>
