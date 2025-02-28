<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    DTR1 BN - Boolean not Null
    Status: draft
-->
<rule abstract="true" id="BN" xmlns="http://purl.oclc.org/dsdl/schematron" see="https://docs.art-decor.org/documentation/datatypes/DTr1_BN">
    <extends rule="ANY"/>
    <assert role="error" test="not(@nullFlavor)">dtr1-1-BN: cannot have null</assert>
</rule>