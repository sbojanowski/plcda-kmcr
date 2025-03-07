<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    DTR1 CS - Coded Simple
    Status: draft
-->
<rule abstract="true" id="CS" xmlns="http://purl.oclc.org/dsdl/schematron">
    <extends rule="ANY"/>
    <assert role="error" test="(@nullFlavor and not(@code or @typeCode)) or (not(@nullFlavor) and (@code or @typeCode))" see="https://art-decor.org/mediawiki/index.php?title=DTr1_CS"
        >dtr1-1-CS: @code/@typeCode and @nullFlavor are mutually exclusive</assert>

    <assert role="error" test="not(@codeSystem)" see="https://art-decor.org/mediawiki/index.php?title=DTr1_CS"
        >dtr1-2-CS: cannot have codeSystem</assert>
    <assert role="error" test="not(@codeSystemName)" see="https://art-decor.org/mediawiki/index.php?title=DTr1_CS"
        >dtr1-3-CS: cannot have codeSystemName</assert>
    <assert role="error" test="not(@codeSystemVersion)" see="https://art-decor.org/mediawiki/index.php?title=DTr1_CS"
        >dtr1-4-CS: cannot have codeSystemVersion</assert>
    <assert role="error" test="not(@displayName)" see="https://art-decor.org/mediawiki/index.php?title=DTr1_CS"
        >dtr1-5-CS: cannot have displayName</assert>
    <assert role="error" test="not(hl7:originalText)" see="https://art-decor.org/mediawiki/index.php?title=DTr1_CS"
        >dtr1-6-CS: cannot have originalText</assert>
    <assert role="error" test="not(hl7:qualifier)" see="https://art-decor.org/mediawiki/index.php?title=DTr1_CS"
        >dtr1-7-CS: cannot have qualifier</assert>
    <assert role="error" test="not(hl7:translation)" see="https://art-decor.org/mediawiki/index.php?title=DTr1_CS"
        >dtr1-8-CS: cannot have translation</assert>
    
</rule>
