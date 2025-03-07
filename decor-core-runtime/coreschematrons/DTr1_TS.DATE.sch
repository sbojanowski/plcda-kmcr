<?xml version="1.0" encoding="UTF-8"?>
<!-- 
:   constrains TS so that it may only contain a date value YYYYMMDD (or YYYYMM or YYYY)
    
:   def: let hasTimezone : Boolean = value.pos("+") > 0 or value.pos("-") > 0
:   inv "Date": not hasTimezone and value.size <= 8
    
    Status: draft
-->
<rule abstract="true" id="TS.DATE" xmlns="http://purl.oclc.org/dsdl/schematron">
    <extends rule="TS"/>
        
    <assert role="error" test="@nullFlavor or matches(@value, '^[0-9]{4,8}$')" see="https://docs.art-decor.org/documentation/datatypes/DTr1_TS.DATE"
        >dtr1-1-TS.DATE: null or date precision of time stamp shall be YYYYMMDD.</assert>
</rule>