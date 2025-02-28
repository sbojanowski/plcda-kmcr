<!--
    Copyright © ART-DECOR Expert Group and ART-DECOR Open Tools
    see https://docs.art-decor.org/copyright and https://docs.art-decor.org/licenses
    
    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.
    
    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
    
    DECOR optional checks contains checks which can be configured on a project basis.
    
    An entire pattern, based on @id, is turned on or off. The pattern can contain multiple related checks. 
    pattern/title is used in the UI, and should contain a rationale for the pattern.
-->
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
    <sch:ns uri="http://purl.oclc.org/dsdl/schematron" prefix="sch"/>
    <sch:pattern id="unibid">
        <sch:title>Unique base IDs: this will check whether all base ID types have unique identifiers.</sch:title>
        <sch:rule context="baseId">
            <sch:let name="baseType" value="@type"/>
            <sch:let name="basePrefix" value="@prefix"/>
            <sch:assert role="error" test="count(../baseId[@prefix = $basePrefix]) = 1">ERROR: The baseId/@prefix "<sch:value-of select="$basePrefix"/>" with type "<sch:value-of select="$baseType"/>" is not unique.</sch:assert>
        </sch:rule>
    </sch:pattern>
    <sch:pattern id="vsreq">
        <sch:title>Value sets required: this will check whether all coded concepts in the project do have an associated value set.</sch:title>
        <sch:rule context="concept[ancestor::decor/@versionDate][valueDomain/@type='code'][not(ancestor-or-self::*[@statusCode = ('deprecated','cancelled','rejected')])]">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;concept ', string-join((
                for $att in ancestor-or-self::concept[1]/(@id, @ref, @type, name[not(. = '')][1], @displayName, @effectiveDate, @flexibility, @statusCode, @versionLabel, ancestor-or-self::dataset[1]/@url[not(. = ancestor::decor/@deeplinkprefixservices)], ancestor-or-self::dataset[1]/@ident)
                return
                    concat(name($att), '=&#34;', $att, '&#34;'),
                for $att in ancestor-or-self::dataset/(@id, @effectiveDate, @versionLabel, @statusCode, name[not(. = '')][1])
                return
                    concat('dataset', upper-case(substring(name($att), 1, 1)), substring(name($att), 2), '=&#34;', $att, '&#34;')
                ), ' '), '/&gt;')"/>
            <sch:assert role="error" test="valueSet">ERROR: Concept "<sch:value-of select="name"/>" is of type "code" but does not have an associated value set.<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
    </sch:pattern>
    <sch:pattern id="maxvsvd">
        <sch:title>Single value domains: this will detect if there are concepts with more than one valueDomain and/or valueSet. For projects (such as ADA-based projects) which cannot handle multiple types.</sch:title>
        <sch:rule context="concept[valueDomain][not(ancestor-or-self::*[@statusCode = ('deprecated','cancelled','rejected')])]">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;concept ', string-join((
                for $att in ancestor-or-self::concept[1]/(@id, @ref, @type, name[not(. = '')][1], @displayName, @effectiveDate, @flexibility, @statusCode, @versionLabel, ancestor-or-self::dataset[1]/@url[not(. = ancestor::decor/@deeplinkprefixservices)], ancestor-or-self::dataset[1]/@ident)
                return
                    concat(name($att), '=&#34;', $att, '&#34;'),
                for $att in ancestor-or-self::dataset/(@id, @effectiveDate, @versionLabel, @statusCode, name[not(. = '')][1])
                return
                    concat('dataset', upper-case(substring(name($att), 1, 1)), substring(name($att), 2), '=&#34;', $att, '&#34;')
                ), ' '), '/&gt;')"/>
            <sch:assert role="error" test="not(valueDomain[2])">ERROR: Concept "<sch:value-of select="name"/>" has more than one valueDomain.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test="not(valueSet[2])">ERROR: Concept "<sch:value-of select="name"/>" of type "code" has more than one valueSet.<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
    </sch:pattern>
    <sch:pattern id="inhres">
        <sch:title>Resolved inherits: this will check whether all concept inherits (also from BBR's) are fully resolved.</sch:title>
        <sch:rule context="concept[ancestor::decor/@versionDate][inherit][not(ancestor-or-self::*[@statusCode = ('deprecated','cancelled','rejected')])]">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;concept ', string-join((
                for $att in ancestor-or-self::concept[1]/(@id, @ref, @type, name[not(. = '')][1], @displayName, @effectiveDate, @flexibility, @statusCode, @versionLabel, ancestor-or-self::dataset[1]/@url[not(. = ancestor::decor/@deeplinkprefixservices)], ancestor-or-self::dataset[1]/@ident)
                return
                    concat(name($att), '=&#34;', $att, '&#34;'),
                for $att in ancestor-or-self::dataset/(@id, @effectiveDate, @versionLabel, @statusCode, name[not(. = '')][1])
                return
                    concat('dataset', upper-case(substring(name($att), 1, 1)), substring(name($att), 2), '=&#34;', $att, '&#34;')
                ), ' '), '/&gt;')"/>
            <sch:assert role="error" test="name">ERROR: Inherited concept "<sch:value-of select="@id"/>" has no name. All inherited concepts must be resolved.<sch:value-of select="$locationContext"/></sch:assert>
            <sch:assert role="error" test=".[not(name)] | contains | concept | valueDomain">ERROR: Inherited concept "<sch:value-of select="name"/>" does not contain concepts and has no valueDomain. All inherited concepts must be resolved.<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
    </sch:pattern>
    <sch:pattern id="oneinh">
        <sch:title>Singular inherit: this will check if a concept is inherited more than once into the same dataset. This is undesirable when inherited IDs are used for identification purposes.</sch:title>
        <sch:rule context="concept[inherit][not(ancestor-or-self::*[@statusCode = ('deprecated','cancelled','rejected')])]">
            <sch:let name="locationContext" value="
                concat(' | Location &lt;concept ', string-join((
                for $att in ancestor-or-self::concept[1]/(@id, @ref, @type, name[not(. = '')][1], @displayName, @effectiveDate, @flexibility, @statusCode, @versionLabel, ancestor-or-self::dataset[1]/@url[not(. = ancestor::decor/@deeplinkprefixservices)], ancestor-or-self::dataset[1]/@ident)
                return
                    concat(name($att), '=&#34;', $att, '&#34;'),
                for $att in ancestor-or-self::dataset/(@id, @effectiveDate, @versionLabel, @statusCode, name[not(. = '')][1])
                return
                    concat('dataset', upper-case(substring(name($att), 1, 1)), substring(name($att), 2), '=&#34;', $att, '&#34;')
                ), ' '), '/&gt;')"/>
            <sch:let name="ref" value="inherit/@ref"/>
            <sch:assert role="error" test="not(//concept[inherit/@ref = $ref][not(ancestor-or-self::*[@statusCode = ('deprecated','cancelled','rejected')])][2])">ERROR: Inherited concept ref "<sch:value-of select="$ref"/>" is inherited twice. This project only allows single inheritance per project to avoid duplicatie IDs, since the inherited IDs are used in FHIR resources.<sch:value-of select="$locationContext"/></sch:assert>
        </sch:rule>
    </sch:pattern>
</sch:schema>