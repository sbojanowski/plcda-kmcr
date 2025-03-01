<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    DTR1 - Instance Identifier
    Status: draft
-->
<rule abstract="true" id="II.EPSOS" xmlns="http://purl.oclc.org/dsdl/schematron">
    <extends rule="II"/>
    
    <assert role="error" test="not(@root) or string-length(@root) &lt;= 64" see="https://art-decor.org/mediawiki/index.php?title=DTr1_II.EPSOS"
        >dtr1-1-II.EPSOS: @root should exceed 64 characters</assert>
</rule>
