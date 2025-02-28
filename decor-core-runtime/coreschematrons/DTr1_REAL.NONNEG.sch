<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    DTR1 REAL.NONNEG - Real Not Negative
    Status: draft
-->
<rule abstract="true" id="REAL.NONNEG" xmlns="http://purl.oclc.org/dsdl/schematron">
    <extends rule="REAL"/>
    
    <assert role="error" test="@nullFlavor or @value >= 0" see="https://docs.art-decor.org/documentation/datatypes/DTr1_REAL.NONNEG"
        >dtr1-1-REAL.NONNEG: null or value >= 0</assert>
</rule>