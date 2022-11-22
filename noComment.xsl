<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" version="3.0">
    
    <xsl:output indent="1"/>
    
    <xsl:variable name="maxTop" select="max(//*:text/@top)"/>
    <xsl:variable name="maxLeft" select="max(//*:text/@left)"/>
    <xsl:variable name="minTop" select="min(//*:text/@top)"/>
    <xsl:variable name="minLeft" select="min(//*:text/@left)"/>
    
    <xd:doc>
        <xd:desc>Delete hidden comments from PDF-XML. Hidden PDF comments stand out from 'normal'
            text nodes in one of the ways listed below.</xd:desc>
    </xd:doc>
    
    <xsl:template match="*:text">
        <xsl:choose>
            <xsl:when test="(xs:double(@top) eq $maxTop) and (xs:double(@left) eq $maxLeft)"/>
            <xsl:when test="(xs:double(@top) eq $maxTop) and (xs:double(@left) eq $minLeft)"/>
            <xsl:when test="(xs:double(@top) eq $minTop) and (xs:double(@left) eq $minLeft)"/>
            <xsl:when test="xs:double(@top) lt 0"/>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>default</xd:desc>
    </xd:doc>
    
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
