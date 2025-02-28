<?xml version="1.0" encoding="UTF-8"?>
<pattern xmlns="http://purl.oclc.org/dsdl/schematron" id="SD.TEXT.table.AT">
    
    <!-- Header-Elemente im Body (<th> wo <td> sein sollte) -->
    <!-- Footer hat mehrere <tr>Zeilen oder mehrere <td> Spalten -->
    
    <!-- *THEAD* Die Tabellenüberschrift wird eingeschlossen in thead Tags, die Überschriftenzeile in tr Tags und die einzelnen Spalten-Items der Überschrift mit th Tags. -->
    <!-- *TBODY* Die eigentlichen Tabelleninhalte werden in tbody Tags, die Datenzeile in tr Tags und die einzelnen Spalteninhalte einer Datenzeile mit td Tag gekapselt. -->
    <!-- *TFOOT* Die optionale Tabellenunterschrift <tfoot> wird entsprechend der HTML-Tabellenkonvention direkt vor dem <tbody>-Tag und nach dem <thead> Tag angeführt. Es wird für Fußnoten in Tabellen verwendet und enthält genau einen <tr> und einen <td>-Tag (Siehe auch Beispiel in Kapitel 7.1.4.8 Fußnoten) -->
    
    <rule context="hl7:text//hl7:table">
        <!-- Anwesenheit von {THEAD} -->
        <assert test="count(hl7:thead) &lt;= 1">(SD.TEXT.table.AT) Tabellen-Header thead darf höchstens einmal vorkommen</assert>
        <!-- Anwesenheit von TBODY -->
        <assert test="count(hl7:tbody) = 1">(SD.TEXT.table.AT) Tabellen-Body tbody muss einmal vorkommen</assert>
        <!-- Anwesenheit von {TFOOT} -->
        <assert test="count(hl7:tfoot) &lt;= 1">(SD.TEXT.table.AT) Tabellen-Footer tfoot darf höchstens einmal vorkommen</assert>
        <!-- Spaltenanzahl ändert sich über die Tabelle (ausgenommen Zellen, die korrekt über COLSPAN zusammengehängt wurden) -->
        <let name="cols" value="
            for $x in (hl7:thead|hl7:tbody)/hl7:tr
            return
            count($x/(hl7:td | hl7:th)[not(@colspan)]) + sum($x/(hl7:td | hl7:th)[@colspan]/@colspan)"/>
        <let name="distinctCols" value="distinct-values($cols)"/>
        <assert test="count($distinctCols) = 1">(SD.TEXT.table.AT) Tabellen-Header/Body Summe über alle Spalten tr bezüglich Anzahl der td oder th inkl. @colspan ist nicht bei allen tr gleich</assert>
        
    </rule>
    
    <!-- nur TR-Kinder in THEAD -->
    <rule context="hl7:text//hl7:table/hl7:thead">
        <assert test="count(* except hl7:tr) = 0">(SD.TEXT.table.AT) Tabellen-Header thead darf nur tr-Kindelemente aufweisen</assert>
    </rule>
    <!-- nur TH-Kinder in THEAD -->
    <rule context="hl7:text//hl7:table/hl7:thead/hl7:tr">
        <assert test="count(* except hl7:th) = 0">(SD.TEXT.table.AT) Tabellen-Header-Row thead.tr darf nur th-Elemente aufweisen</assert>
    </rule>
    
    <!-- keine TH in TBODY -->
    <rule context="hl7:text//hl7:table/hl7:tbody/hl7:tr">
        <assert test="count(* except hl7:td) = 0">(SD.TEXT.table.AT) Tabellen-Body-Row tbody.tr darf nur td-Elemente aufweisen</assert>
    </rule>
    
    <!-- nur eine TR, TD in TFOOT -->
    <rule context="hl7:text//hl7:table/hl7:tfoot">
        <assert test="count(hl7:tr)&lt;=1">(SD.TEXT.table.AT) Tabellen-Footer-Row tfoot.tr darf höchstens einmal vorkommen</assert>           
    </rule>
    <rule context="hl7:text//hl7:table/hl7:tfoot/hl7:tr">
        <assert test="count(hl7:td)&lt;=1">(SD.TEXT.table.AT) Tabellen-Footer-Row tfoot.td darf höchstens einmal vorkommen</assert>
        <assert test="count(* except hl7:td)=0">(SD.TEXT.table.AT) Tabellen-Footer-Row tfoot.tr darf nur td-Elemente aufweisen</assert>
    </rule>
    
</pattern>
