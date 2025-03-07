<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    DTr1 IVXB_PQ - PQ
    Status: draft
-->
<rule abstract="true" id="IVXB_PQ" xmlns="http://purl.oclc.org/dsdl/schematron">
    <extends rule="PQ"/>
    <assert role="error" test="not(@nullFlavor and @inclusive) or @inclusive = 'true'" see="https://docs.art-decor.org/documentation/datatypes/DTr1_IVXB_PQ"
        >dtr1-1-IVXB_PQ: not inclusive if null</assert>
</rule>