<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:template match="/">
    <TEI>
      <teiHeader />
      <text>
        <xsl:apply-templates select="*:pdf2xml/*:page" />
      </text>
    </TEI>
  </xsl:template>
  
  <xsl:template match="*:page">
    <page>
      <xsl:apply-templates select="@* | *[not(self::*:fontspec)]" />
    </page>
  </xsl:template>
  
  <xsl:template match="*:text">
    <xsl:variable name="font" select="@font"/>
    <xsl:copy>
      <xsl:attribute name="size" select="//*:fontspec[@id = $font]/@size" />
      <xsl:apply-templates select="@* | node()" />
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*:a">
    <xsl:choose>
      <xsl:when test="string-length() &lt; 5">
        <ref ref="{@href}">
          <xsl:sequence select="node()" />
        </ref>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="node()" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>