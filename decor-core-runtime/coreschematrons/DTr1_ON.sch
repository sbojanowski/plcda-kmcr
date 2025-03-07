<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    DTr1 ON - Organization Name
    Status: draft
-->
<rule abstract="true" id="ON" xmlns="http://purl.oclc.org/dsdl/schematron">
    <extends rule="EN"/>

    <assert role="error" test="count(hl7:family)=0 and count(hl7:given)=0" see="https://docs.art-decor.org/documentation/datatypes/DTr1_ON"
        >dtr1-1-ON: no parts may be person name type particles</assert>
    <assert role="error" test="not(*)" see="https://docs.art-decor.org/documentation/datatypes/DTr1_ON"
        >dtr1-2-ON: organization names SHALL be element content</assert>

</rule>
