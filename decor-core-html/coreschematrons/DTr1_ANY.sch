<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    DTR1 ANY - ANY 
    Status: draft
-->
<rule abstract="true" id="ANY" xmlns="http://purl.oclc.org/dsdl/schematron">
    <!-- partType, integrityCheckAlgorithm='SHA-1', mediaType='text/plain', represention='TXT', inclusive='true' 
        are or have an XML schema default. Latest versions of Saxon 9.7.0.19 will assume this schema default if the instance doesn't carry it and bark even without the instance carrying the attribute. -->
    <assert role="error"
        test="descendant-or-self::*[
        not(@nullFlavor) or
        (@nullFlavor                 and not(@* except (@xsi:type|@xsi:nil|@classCode|@typeCode|@determinerCode|@moodCode|@nullFlavor|@partType|@integrityCheckAlgorithm[. = 'SHA-1']|@mediaType[.='text/plain']|@representation[.='TXT']|@inclusive[. = 'true']) | * | text()[string-length(normalize-space()) gt 0])) or
        (@nullFlavor = ('OTH', 'NA') and not(@* except (@xsi:type|@xsi:nil|@codeSystem|@nullFlavor|@partType|@integrityCheckAlgorithm[. = 'SHA-1']|@mediaType[.='text/plain']|@representation[.='TXT']|@inclusive[. = 'true'])) and (@codeSystem | hl7:originalText | hl7:translation)) or
        (@nullFlavor = 'UNC'         and not(@* except (@xsi:type|@xsi:nill|@extension|@nullFlavor|@partType|@integrityCheckAlgorithm[. = 'SHA-1']|@mediaType[.='text/plain']|@representation[.='TXT']|@inclusive[. = 'true'])) and (@extension) 
        )]" see="https://art-decor.org/mediawiki/index.php?title=DTr1_ANY"
        >dtr1-1-ANY: if there is a nullFlavor, there shall be no text or other attribute or element, unless it's nullFlavor='OTH' or 'NA' (@codeSystem, &lt;originalText&gt; or &lt;translation&gt; may have a value), or nullFlavor 'UNC' (@extension may have a value)</assert>
</rule>
