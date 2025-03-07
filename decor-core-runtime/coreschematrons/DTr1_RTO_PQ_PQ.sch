<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    Datatype 1.0 RTO_PQ_PQ - Ratio of Physical Quantity
    Status: Draft
-->
<rule abstract="true" id="RTO_PQ_PQ" xmlns="http://purl.oclc.org/dsdl/schematron">
    <extends rule="PQ"/>
    
    <assert role="error" test="@nullFlavor or hl7:numerator[not(@nullFlavor)] or hl7:denominator[not(@nullFlavor)]" see="https://docs.art-decor.org/documentation/datatypes/DTr1_RTO_PQ_PQ"
        >dtr1-1-RTO_PQ_PQ: numerator or denominator required</assert>
    
    <assert role="error" test="not(hl7:numerator[@updateMode] or hl7:denominator[@updateMode])" see="https://docs.art-decor.org/documentation/datatypes/DTr1_RTO_PQ_PQ"
        >dtr1-2-RTO_PQ_PQ: no updateMode on numerator or denominator</assert>
    <assert role="error" test="not(hl7:uncertainty)" see="https://docs.art-decor.org/documentation/datatypes/DTr1_RTO_PQ_PQ"
        >dtr1-3-RTO_PQ_PQ: no uncertainty</assert>
    
    <assert role="error" test="not(hl7:denominator/@value='0')" see="https://docs.art-decor.org/documentation/datatypes/DTr1_RTO_PQ_PQ"
        >dtr1-4-RTO_PQ_PQ: The denominator must not be zero.</assert>
</rule>