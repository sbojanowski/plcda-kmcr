<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:hl7="urn:hl7-org:v3"
    xmlns="http://purl.oclc.org/dsdl/schematron"
    xmlns:sch="http://www.ascc.net/xml/schematron"
    xmlns:uuid="java:java.util.UUID"
    queryBinding="xslt2">
    <ns uri="urn:hl7-org:v3" prefix="hl7"/>
    <ns uri="http://www.w3.org/2001/XMLSchema-instance" prefix="xsi"/>
    
    <pattern>
        <include href="../coreschematrons/DTr1_AD.NL.sch"/>
        <include href="../coreschematrons/DTr1_AD.DE.sch"/>
        <include href="../coreschematrons/DTr1_AD.EPSOS.sch"/>
        <include href="../coreschematrons/DTr1_AD.IPS.sch"/>
        <include href="../coreschematrons/DTr1_AD.CA.BASIC.sch"/>
        <include href="../coreschematrons/DTr1_AD.CA.sch"/>
        <include href="../coreschematrons/DTr1_AD.sch"/>
        <include href="../coreschematrons/DTr1_ADXP.sch"/>
        <include href="../coreschematrons/DTr1_ANY.sch"/>
        <include href="../coreschematrons/DTr1_BIN.sch"/>
        <include href="../coreschematrons/DTr1_BL.sch"/>
        <include href="../coreschematrons/DTr1_BN.sch"/>
        <include href="../coreschematrons/DTr1_BXIT_IVL_PQ.sch"/>
        <include href="../coreschematrons/DTr1_CD.EPSOS.sch"/>
        <include href="../coreschematrons/DTr1_CD.IPS.sch"/>
        <include href="../coreschematrons/DTr1_CD.SDTC.sch"/>
        <include href="../coreschematrons/DTr1_CD.sch"/>
        <include href="../coreschematrons/DTr1_CE.EPSOS.sch"/>
        <include href="../coreschematrons/DTr1_CE.IPS.sch"/>
        <include href="../coreschematrons/DTr1_CE.sch"/>
        <include href="../coreschematrons/DTr1_CO.EPSOS.sch"/>
        <include href="../coreschematrons/DTr1_CO.sch"/>
        <include href="../coreschematrons/DTr1_CR.sch"/>
        <include href="../coreschematrons/DTr1_CS.LANG.sch"/>
        <include href="../coreschematrons/DTr1_CS.sch"/>
        <include href="../coreschematrons/DTr1_CV.EPSOS.sch"/>
        <include href="../coreschematrons/DTr1_CV.IPS.sch"/>
        <include href="../coreschematrons/DTr1_CV.sch"/>
        <include href="../coreschematrons/DTr1_ED.sch"/>
        <include href="../coreschematrons/DTr1_EIVL.event.sch"/>
        <include href="../coreschematrons/DTr1_EIVL_TS.sch"/>
        <include href="../coreschematrons/DTr1_EN.sch"/>
        <include href="../coreschematrons/DTr1_ENXP.sch"/>
        <include href="../coreschematrons/DTr1_GTS.sch"/>
        <include href="../coreschematrons/DTr1_II.AT.ATU.sch"/>
        <include href="../coreschematrons/DTr1_II.AT.BLZ.sch"/>
        <include href="../coreschematrons/DTr1_II.AT.DVR.sch"/>
        <include href="../coreschematrons/DTr1_II.AT.KTONR.sch"/>
        <include href="../coreschematrons/DTr1_II.EPSOS.sch"/>
        <include href="../coreschematrons/DTr1_II.NL.AGB.sch"/>
        <include href="../coreschematrons/DTr1_II.NL.BIG.sch"/>
        <include href="../coreschematrons/DTr1_II.NL.BSN.sch"/>
        <include href="../coreschematrons/DTr1_II.NL.URA.sch"/>
        <include href="../coreschematrons/DTr1_II.NL.UZI.sch"/>
        <include href="../coreschematrons/DTr1_II.sch"/>
        <include href="../coreschematrons/DTr1_INT.NONNEG.sch"/>
        <include href="../coreschematrons/DTr1_INT.POS.sch"/>
        <include href="../coreschematrons/DTr1_INT.sch"/>
        <include href="../coreschematrons/DTr1_hl7nl-INT.sch"/>
        <include href="../coreschematrons/DTr1_IVL.sch"/>
        <include href="../coreschematrons/DTr1_IVL_INT.sch"/>
        <include href="../coreschematrons/DTr1_IVL_MO.sch"/>
        <include href="../coreschematrons/DTr1_IVL_PQ.sch"/>
        <include href="../coreschematrons/DTr1_IVL_REAL.sch"/>
        <include href="../coreschematrons/DTr1_IVL_TS.EPSOS.TZ.OPT.sch"/>
        <include href="../coreschematrons/DTr1_IVL_TS.EPSOS.TZ.sch"/>
        <include href="../coreschematrons/DTr1_IVL_TS.IPS.TZ.sch"/>
        <include href="../coreschematrons/DTr1_IVL_TS.CH.TZ.sch"/>
        <include href="../coreschematrons/DTr1_IVL_TS.sch"/>
        <include href="../coreschematrons/DTr1_hl7nl-IVL_TS.sch"/>
        <include href="../coreschematrons/DTr1_IVXB_INT.sch"/>
        <include href="../coreschematrons/DTr1_IVXB_MO.sch"/>
        <include href="../coreschematrons/DTr1_IVXB_PQ.sch"/>
        <include href="../coreschematrons/DTr1_IVXB_REAL.sch"/>
        <include href="../coreschematrons/DTr1_IVXB_TS.sch"/>
        <include href="../coreschematrons/DTr1_LIST.sch"/>
        <include href="../coreschematrons/DTr1_MO.sch"/>
        <include href="../coreschematrons/DTr1_ON.sch"/>
        <include href="../coreschematrons/DTr1_PIVL_TS.sch"/>
        <include href="../coreschematrons/DTr1_hl7nl-PIVL_TS.sch"/>
        <include href="../coreschematrons/DTr1_PN.sch"/>
        <include href="../coreschematrons/DTr1_PN.NL.sch"/>
        <include href="../coreschematrons/DTr1_PN.CA.sch"/>
        <include href="../coreschematrons/DTr1_PQ.sch"/>
        <include href="../coreschematrons/DTr1_hl7nl-PQ.sch"/>
        <include href="../coreschematrons/DTr1_PQR.sch"/>
        <include href="../coreschematrons/DTr1_QTY.sch"/>
        <include href="../coreschematrons/DTr1_REAL.NONNEG.sch"/>
        <include href="../coreschematrons/DTr1_REAL.POS.sch"/>
        <include href="../coreschematrons/DTr1_REAL.sch"/>
        <include href="../coreschematrons/DTr1_RTO.sch"/>
        <include href="../coreschematrons/DTr1_hl7nl-RTO.sch"/>
        <include href="../coreschematrons/DTr1_RTO_PQ_PQ.sch"/>
        <include href="../coreschematrons/DTr1_RTO_QTY_QTY.sch"/>
        <include href="../coreschematrons/DTr1_SC.sch"/>
        <include href="../coreschematrons/DTr1_SD.TEXT.sch"/>
        <include href="../coreschematrons/DTr1_ST.sch"/>
        <include href="../coreschematrons/DTr1_SXCM.sch"/>
        <include href="../coreschematrons/DTr1_SXCM_INT.sch"/>
        <include href="../coreschematrons/DTr1_SXCM_MO.sch"/>
        <include href="../coreschematrons/DTr1_SXCM_PQ.sch"/>
        <include href="../coreschematrons/DTr1_SXCM_REAL.sch"/>
        <include href="../coreschematrons/DTr1_SXCM_TS.sch"/>
        <include href="../coreschematrons/DTr1_SXPR_TS.sch"/>
        <include href="../coreschematrons/DTr1_TEL.AT.sch"/>
        <include href="../coreschematrons/DTr1_TEL.NL.EXTENDED.sch"/>
        <include href="../coreschematrons/DTr1_TEL.EPSOS.sch"/>
        <include href="../coreschematrons/DTr1_TEL.IPS.sch"/>
        <include href="../coreschematrons/DTr1_TEL.CA.EMAIL.sch"/>
        <include href="../coreschematrons/DTr1_TEL.CA.PHONE.sch"/>
        <include href="../coreschematrons/DTr1_TEL.sch"/>
        <include href="../coreschematrons/DTr1_TN.sch"/>
        <include href="../coreschematrons/DTr1_hl7nl-TS.sch"/>
        <include href="../coreschematrons/DTr1_TS.DATE.FULL.sch"/>
        <include href="../coreschematrons/DTr1_TS.DATE.MIN.sch"/>
        <include href="../coreschematrons/DTr1_TS.DATE.sch"/>
        <include href="../coreschematrons/DTr1_TS.DATETIME.MIN.sch"/>
        <include href="../coreschematrons/DTr1_TS.DATETIMETZ.MIN.sch"/>
        <include href="../coreschematrons/DTr1_TS.EPSOS.TZ.OPT.sch"/>
        <include href="../coreschematrons/DTr1_TS.EPSOS.TZ.sch"/>
        <include href="../coreschematrons/DTr1_TS.IPS.TZ.sch"/>
        <include href="../coreschematrons/DTr1_TS.CH.TZ.sch"/>
        <include href="../coreschematrons/DTr1_TS.AT.TZ.sch"/>
        <include href="../coreschematrons/DTr1_TS.sch"/>
        <include href="../coreschematrons/DTr1_URL.NL.EXTENDED.sch"/>
        <include href="../coreschematrons/DTr1_URL.sch"/>
        <include href="../coreschematrons/DTr1_thumbnail.sch"/>
    
        <rule context="hl7:*[@xsi:type='AD.DE']">
            <extends rule="AD.DE"/>
        </rule>
        <rule context="hl7:*[@xsi:type='AD.EPSOS']">
            <extends rule="AD.EPSOS"/>
        </rule>
        <rule context="hl7:*[@xsi:type='AD.IPS']">
            <extends rule="AD.IPS"/>
        </rule>
        <rule context="hl7:*[@xsi:type='AD.NL']">
            <extends rule="AD.NL"/>
        </rule>
        <rule context="hl7:*[@xsi:type='AD.CA.BASIC']">
            <extends rule="AD.CA.BASIC"/>
        </rule>
        <rule context="hl7:*[@xsi:type='AD.CA']">
            <extends rule="AD.CA"/>
        </rule>
        <rule context="hl7:*[@xsi:type='AD']">
            <extends rule="AD"/>
        </rule>
        <rule context="hl7:*[@xsi:type='ADXP']">
            <extends rule="ADXP"/>
        </rule>
        <rule context="hl7:*[@xsi:type='ANY']">
            <extends rule="ANY"/>
        </rule>
        <rule context="hl7:*[@xsi:type='BIN']">
            <extends rule="BIN"/>
        </rule>
        <rule context="hl7:*[@xsi:type='BXIT_IVL_PQ']">
            <extends rule="BXIT_IVL_PQ"/>
        </rule>
        <rule context="hl7:*[@xsi:type='BL']">
            <extends rule="BL"/>
        </rule>
        <rule context="hl7:*[@xsi:type='BN']">
            <extends rule="BN"/>
        </rule>
        <rule context="hl7:*[@xsi:type='CD.EPSOS']">
            <extends rule="CD.EPSOS"/>
        </rule>
        <rule context="hl7:*[@xsi:type='CD.IPS']">
            <extends rule="CD.IPS"/>
        </rule>
        <rule context="hl7:*[@xsi:type='CD']">
            <extends rule="CD"/>
        </rule>
        <rule context="hl7:*[@xsi:type='CE.EPSOS']">
            <extends rule="CE.EPSOS"/>
        </rule>
        <rule context="hl7:*[@xsi:type='CE.IPS']">
            <extends rule="CE.IPS"/>
        </rule>
        <rule context="hl7:*[@xsi:type='CE']">
            <extends rule="CE"/>
        </rule>
        <rule context="hl7:*[@xsi:type='CO.EPSOS']">
            <extends rule="CO.EPSOS"/>
        </rule>
        <rule context="hl7:*[@xsi:type='CO']">
            <extends rule="CO"/>
        </rule>
        <rule context="hl7:*[@xsi:type='CR']">
            <extends rule="CR"/>
        </rule>
        <rule context="hl7:*[@xsi:type='CS.LANG']">
            <extends rule="CS.LANG"/>
        </rule>
        <rule context="hl7:*[@xsi:type='CS']">
            <extends rule="CS"/>
        </rule>
        <rule context="hl7:*[@xsi:type='CV.EPSOS']">
            <extends rule="CV.EPSOS"/>
        </rule>
        <rule context="hl7:*[@xsi:type='CV.IPS']">
            <extends rule="CV.IPS"/>
        </rule>
        <rule context="hl7:*[@xsi:type='CV']">
            <extends rule="CV"/>
        </rule>
        <rule context="hl7:*[@xsi:type='ED']">
            <extends rule="ED"/>
        </rule>
        <rule context="hl7:*[@xsi:type='EIVL.event']">
            <extends rule="EIVL.event"/>
        </rule>
        <rule context="hl7:*[@xsi:type='EIVL_TS']">
            <extends rule="EIVL_TS"/>
        </rule>
        <rule context="hl7:*[@xsi:type='EN']">
            <extends rule="EN"/>
        </rule>
        <rule context="hl7:*[@xsi:type='ENXP']">
            <extends rule="ENXP"/>
        </rule>
        <rule context="hl7:*[@xsi:type='GTS']">
            <extends rule="GTS"/>
        </rule>
        <rule context="hl7:*[@xsi:type='II.AT.ATU']">
            <extends rule="II.AT.ATU"/>
        </rule>
        <rule context="hl7:*[@xsi:type='II.AT.BLZ']">
            <extends rule="II.AT.BLZ"/>
        </rule>
        <rule context="hl7:*[@xsi:type='II.AT.DVR']">
            <extends rule="II.AT.DVR"/>
        </rule>
        <rule context="hl7:*[@xsi:type='II.AT.KTONR']">
            <extends rule="II.AT.KTONR"/>
        </rule>
        <rule context="hl7:*[@xsi:type='II.EPSOS']">
            <extends rule="II.EPSOS"/>
        </rule>
        <rule context="hl7:*[@xsi:type='II.NL.AGB']">
            <extends rule="II.NL.AGB"/>
        </rule>
        <rule context="hl7:*[@xsi:type='II.NL.BIG']">
            <extends rule="II.NL.BIG"/>
        </rule>
        <rule context="hl7:*[@xsi:type='II.NL.BSN']">
            <extends rule="II.NL.BSN"/>
        </rule>
        <rule context="hl7:*[@xsi:type='II.NL.URA']">
            <extends rule="II.NL.URA"/>
        </rule>
        <rule context="hl7:*[@xsi:type='II.NL.UZI']">
            <extends rule="II.NL.UZI"/>
        </rule>
        <rule context="hl7:*[@xsi:type='II']">
            <extends rule="II"/>
        </rule>
        <rule context="hl7:*[@xsi:type='INT.NONNEG']">
            <extends rule="INT.NONNEG"/>
        </rule>
        <rule context="hl7:*[@xsi:type='INT.POS']">
            <extends rule="INT.POS"/>
        </rule>
        <rule context="hl7:*[@xsi:type='INT']">
            <extends rule="INT"/>
        </rule>
        <rule context="hl7:*[@xsi:type='IVL']">
            <extends rule="IVL"/>
        </rule>
        <rule context="hl7:*[@xsi:type='IVL_INT']">
            <extends rule="IVL_INT"/>
        </rule>
        <rule context="hl7:*[@xsi:type='IVL_MO']">
            <extends rule="IVL_MO"/>
        </rule>
        <rule context="hl7:*[@xsi:type='IVL_PQ']">
            <extends rule="IVL_PQ"/>
        </rule>
        <rule context="hl7:*[@xsi:type='IVL_REAL']">
            <extends rule="IVL_REAL"/>
        </rule>
        <rule context="hl7:*[@xsi:type='IVL_TS.EPSOS.TZ.OPT']">
            <extends rule="IVL_TS.EPSOS.TZ.OPT"/>
        </rule>
        <rule context="hl7:*[@xsi:type='IVL_TS.EPSOS.TZ']">
            <extends rule="IVL_TS.EPSOS.TZ"/>
        </rule>
        <rule context="hl7:*[@xsi:type='IVL_TS.IPS.TZ']">
            <extends rule="IVL_TS.IPS.TZ"/>
        </rule>
        <rule context="hl7:*[@xsi:type='IVL_TS']">
            <extends rule="IVL_TS"/>
        </rule>
        <rule context="hl7:*[@xsi:type='hl7nl:IVL_TS']">
            <extends rule="hl7nl-IVL_TS"/>
        </rule>
        <rule context="hl7:*[@xsi:type='IVXB_INT']">
            <extends rule="IVXB_INT"/>
        </rule>
        <rule context="hl7:*[@xsi:type='IVXB_MO']">
            <extends rule="IVXB_MO"/>
        </rule>
        <rule context="hl7:*[@xsi:type='IVXB_PQ']">
            <extends rule="IVXB_PQ"/>
        </rule>
        <rule context="hl7:*[@xsi:type='IVXB_REAL']">
            <extends rule="IVXB_REAL"/>
        </rule>
        <rule context="hl7:*[@xsi:type='IVXB_TS']">
            <extends rule="IVXB_TS"/>
        </rule>
        <rule context="hl7:*[@xsi:type='LIST']">
            <extends rule="LIST"/>
        </rule>
        <rule context="hl7:*[@xsi:type='MO']">
            <extends rule="MO"/>
        </rule>
        <rule context="hl7:*[@xsi:type='ON']">
            <extends rule="ON"/>
        </rule>
        <rule context="hl7:*[@xsi:type='PIVL_TS']">
            <extends rule="PIVL_TS"/>
        </rule>
        <rule context="hl7:*[@xsi:type='hl7nl:PIVL_TS']">
            <extends rule="hl7nl-PIVL_TS"/>
        </rule>
        <rule context="hl7:*[@xsi:type='PN']">
            <extends rule="PN"/>
        </rule>
        <rule context="hl7:*[@xsi:type='PN.NL']">
            <extends rule="PN.NL"/>
        </rule>
        <rule context="hl7:*[@xsi:type='PN.CA']">
            <extends rule="PN.CA"/>
        </rule>
        <rule context="hl7:*[@xsi:type='PQ']">
            <extends rule="PQ"/>
        </rule>
        <rule context="hl7:*[@xsi:type='PQR']">
            <extends rule="PQR"/>
        </rule>
        <rule context="hl7:*[@xsi:type='QTY']">
            <extends rule="QTY"/>
        </rule>
        <rule context="hl7:*[@xsi:type='REAL.NONNEG']">
            <extends rule="REAL.NONNEG"/>
        </rule>
        <rule context="hl7:*[@xsi:type='REAL.POS']">
            <extends rule="REAL.POS"/>
        </rule>
        <rule context="hl7:*[@xsi:type='REAL']">
            <extends rule="REAL"/>
        </rule>
        <rule context="hl7:*[@xsi:type='RTO']">
            <extends rule="RTO"/>
        </rule>
        <rule context="hl7:*[@xsi:type='RTO_PQ_PQ']">
            <extends rule="RTO_PQ_PQ"/>
        </rule>
        <rule context="hl7:*[@xsi:type='RTO_QTY_QTY']">
            <extends rule="RTO_QTY_QTY"/>
        </rule>
        <rule context="hl7:*[@xsi:type='SC']">
            <extends rule="SC"/>
        </rule>
        <rule context="hl7:*[@xsi:type='SD.TEXT']">
            <extends rule="SD.TEXT"/>
        </rule>
        <rule context="hl7:*[@xsi:type='ST']">
            <extends rule="ST"/>
        </rule>
        <rule context="hl7:*[@xsi:type='SXCM']">
            <extends rule="SXCM"/>
        </rule>
        <rule context="hl7:*[@xsi:type='SXCM_INT']">
            <extends rule="SXCM_INT"/>
        </rule>
        <rule context="hl7:*[@xsi:type='SXCM_MO']">
            <extends rule="SXCM_MO"/>
        </rule>
        <rule context="hl7:*[@xsi:type='SXCM_PQ']">
            <extends rule="SXCM_PQ"/>
        </rule>
        <rule context="hl7:*[@xsi:type='SXCM_REAL']">
            <extends rule="SXCM_REAL"/>
        </rule>
        <rule context="hl7:*[@xsi:type='SXCM_TS']">
            <extends rule="SXCM_TS"/>
        </rule>
        <rule context="hl7:*[@xsi:type='SXPR_TS']">
            <extends rule="SXPR_TS"/>
        </rule>
        <rule context="hl7:*[@xsi:type='TEL.AT']">
            <extends rule="TEL.AT"/>
        </rule>
        <rule context="hl7:*[@xsi:type='TEL.EPSOS']">
            <extends rule="TEL.EPSOS"/>
        </rule>
        <rule context="hl7:*[@xsi:type='TEL.IPS']">
            <extends rule="TEL.IPS"/>
        </rule>
        <rule context="hl7:*[@xsi:type='TEL.NL.EXTENDED']">
            <extends rule="TEL.NL.EXTENDED"/>
        </rule>
        <rule context="hl7:*[@xsi:type='TEL.CA.EMAIL']">
            <extends rule="TEL.CA.EMAIL"/>
        </rule>
        <rule context="hl7:*[@xsi:type='TEL.CA.PHONE']">
            <extends rule="TEL.CA.PHONE"/>
        </rule>
        <rule context="hl7:*[@xsi:type='TEL']">
            <extends rule="TEL"/>
        </rule>
        <rule context="hl7:*[@xsi:type='TN']">
            <extends rule="TN"/>
        </rule>
        <rule context="hl7:*[@xsi:type='hl7nl:TS']">
            <extends rule="hl7nl-TS"/>
        </rule>
        <rule context="hl7:*[@xsi:type='TS.DATE.FULL']">
            <extends rule="TS.DATE.FULL"/>
        </rule>
        <rule context="hl7:*[@xsi:type='TS.DATE.MIN']">
            <extends rule="TS.DATE.MIN"/>
        </rule>
        <rule context="hl7:*[@xsi:type='TS.DATE']">
            <extends rule="TS.DATE"/>
        </rule>
        <rule context="hl7:*[@xsi:type='TS.DATETIME.MIN']">
            <extends rule="TS.DATETIME.MIN"/>
        </rule>
        <rule context="hl7:*[@xsi:type='TS.DATETIMETZ.MIN']">
            <extends rule="TS.DATETIMETZ.MIN"/>
        </rule>
        <rule context="hl7:*[@xsi:type='TS.EPSOS.TZ.OPT']">
            <extends rule="TS.EPSOS.TZ.OPT"/>
        </rule>
        <rule context="hl7:*[@xsi:type='TS.EPSOS.TZ']">
            <extends rule="TS.EPSOS.TZ"/>
        </rule>
        <rule context="hl7:*[@xsi:type='TS.IPS.TZ']">
            <extends rule="TS.IPS.TZ"/>
        </rule>
        <rule context="hl7:*[@xsi:type='TS.CH.TZ']">
            <extends rule="TS.CH.TZ"/>
        </rule>
        <rule context="hl7:*[@xsi:type='TS.AT.TZ']">
            <extends rule="TS.AT.TZ"/>
        </rule>
        <rule context="hl7:*[@xsi:type='TS']">
            <extends rule="TS"/>
        </rule>
        <rule context="hl7:*[@xsi:type='URL.NL.EXTENDED']">
            <extends rule="URL.NL.EXTENDED"/>
        </rule>
        <rule context="hl7:*[@xsi:type='URL']">
            <extends rule="URL"/>
        </rule>
        <rule context="hl7:*[@xsi:type='thumbnail']">
            <extends rule="thumbnail"/>
        </rule>
    </pattern>
</schema>