<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    DTr1 PN - Person Name
    Status: draft
-->
<rule abstract="true" id="PN" xmlns="http://purl.oclc.org/dsdl/schematron">
    <extends rule="EN"/>
    
    <assert role="error" test="not(*[tokenize(@qualifier,'\s')='LS'])" see="https://docs.art-decor.org/documentation/datatypes/DTr1_PN"
        >dtr1-1-PN: Person names SHALL NOT contain a name part qualified with 'LS' (Legal status for organizations)</assert>
</rule>