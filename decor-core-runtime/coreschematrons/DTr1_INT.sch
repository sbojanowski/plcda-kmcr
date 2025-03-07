<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    DTr1 INT - Integer
    Status: draft
-->
<rule abstract="true" id="INT" xmlns="http://purl.oclc.org/dsdl/schematron">
    <extends rule="QTY"/>
    
    <assert role="error" test="(@nullFlavor or @value or *) and not(@nullFlavor and @value)" see="https://docs.art-decor.org/documentation/datatypes/DTr1_INT"
        >dtr1-1-INT: null or value or child element in case of extension</assert>
    
    <assert role="error" test="not(hl7:uncertainty)" see="https://docs.art-decor.org/documentation/datatypes/DTr1_INT"
        >dtr1-2-INT: no uncertainty</assert>
    
</rule>