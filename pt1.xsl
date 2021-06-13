<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:output omit-xml-declaration="1" indent="1" />
  
  <xsl:template match="/">
    <TEI>
      <teiHeader>
        <encodingDesc>
          <tagsDecl>
            <xsl:apply-templates select="//*:fontspec" />
          </tagsDecl>
        </encodingDesc>
      </teiHeader>
      <text>
        <xsl:apply-templates select="*:pdf2xml/*:page" />
      </text>
    </TEI>
  </xsl:template>
  
  <xsl:template match="*:page">
    <xsl:copy>
      <xsl:apply-templates select="@* | *[not(self::*:fontspec)]" />
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*:text">
    <xsl:copy>
      <xsl:attribute name="rendition" select="'#f' || @font" />
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
  
  <xsl:template match="*:fontspec">
    <rendition scheme="css">
      <xsl:attribute name="xml:id" select="'f' || @id" />
      <xsl:text>
               font-size: </xsl:text>
      <xsl:value-of select="@size" />
      <xsl:text>pt;
               font-family: </xsl:text>
      <xsl:value-of _select="@family" />
      <xsl:text>;
               color: </xsl:text>
      <xsl:value-of select="@color" />
      <xsl:text>;
            </xsl:text>
    </rendition>
  </xsl:template>
  
  <xsl:template match="@font" />
  
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>