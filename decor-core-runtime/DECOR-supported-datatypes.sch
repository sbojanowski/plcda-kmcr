<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
    <ns uri="http://purl.oclc.org/dsdl/schematron" prefix="sch"/>
    <let name="currentFilename" value="tokenize(document-uri(.),'/')[last()]"/>
    <let name="classification-format" value="tokenize(substring($currentFilename,1,string-length($currentFilename)-4),'-')[string-length()>0][4]"/>
    <let name="type" value="if ($classification-format != 'hl7v3xml1') then concat('-',$classification-format) else ('')"/>
    
    <!-- Note: this needs updating for every new format e.g. hl7v2.4xml -->
    <let name="prefixsch" value="if ($classification-format = 'hl7v2.5xml') then 'DTv25_' else 'DTr1_'"/>
    <let name="coreSchematronDir" value="concat('coreschematrons',$type)"/>
    
    <let name="prefixunit" value="if (not(empty($classification-format)) and $classification-format != 'hl7v3xml1') then concat('-',$classification-format) else ''"/>
    
    <let name="datatypesSchematronFn" value="concat('coreschematron-unit-tests',$prefixunit,'/datatypes-unit-test.sch')"/>
    <let name="datatypesSchematron" value="doc($datatypesSchematronFn)"/>
    
    <pattern>
        <rule context="dataType|flavor[ancestor::dataType]">
            <let name="coreSchematron" value="concat($coreSchematronDir,'/',$prefixsch,replace(@name,':','-'),'.sch')"/>
            <let name="hasCoreschematron" value="doc-available($coreSchematron)"/>
            <let name="hasUnitTest" value="doc-available($datatypesSchematron) and $datatypesSchematron//sch:include[matches(@href,$coreSchematron)]"/>
            
            <assert test="$hasCoreschematron"
                ><name/>/@name='<value-of select="@name"/>' SHALL have a schematron file named '<value-of select="$coreSchematron"/>'</assert>
            
            <let name="extends" value="replace(parent::*/@name, ':', '-')"/>
            <let name="extendsParent" value="replace(parent::*/parent::*/@name, ':', '-')"/>
            
            <assert test="not(/*[@type='hl7v3xml1']) or not(parent::*/@name) or not($hasCoreschematron) or doc($coreSchematron)//*:extends[@rule=$extends or tokenize(@rule,'\.')[1] = $extendsParent]"
                ><name/>/@name='<value-of select="@name"/>' SHALL NOT have a schematron file with extends value '<value-of select="doc($coreSchematron)//*:extends/@rule"/>' (expected '<value-of select="$extends"/>' or something extending from <value-of select="$extendsParent"/>)</assert>
            
            <assert test="$hasUnitTest"
                ><name/>/@name='<value-of select="@name"/>' SHALL have a unit test in '<value-of select="$datatypesSchematronFn"/>'</assert>
            
            <assert test="desc[@language='en-US'] or (parent::dataType|parent::flavor)"><name/>/@name='<value-of select="@name"/>' SHALL have at least one desc in en-US language.</assert>
        </rule>
        <rule context="attribute[@datatype]">
            <assert test="@datatype=//(atomicDataType|flavor[ancestor::atomicDataType])/@name"
                ><name/>/@datatype='<value-of select="@datatype"/>' SHALL be defined by an atomicDataType or atomicDataType flavor</assert>
        </rule>
        <rule context="element[@datatype]">
            <assert test="@datatype=//(dataType|flavor[ancestor::dataType])/@name"
                ><name/>/@datatype='<value-of select="@datatype"/>' SHALL be defined by a dataType or dataType flavor</assert>
        </rule>
        <rule context="element[not(@datatype)]">
            <assert test="attribute[@name='xsi:type']"
                ><name/> SHALL have @datatype or attribute[@name='xsi:type']</assert>
        </rule>
    </pattern>
</schema>