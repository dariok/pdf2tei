<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:pt="https://github.com/dariok/pt"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:output indent="1" />
  
  <xd:doc scope="stylesheet">
    <xd:desc>Combine <xd:pre>text</xd:pre> into <xd:pre>tei:l</xd:pre> so we can reconstruct line breaks
      and have a basis for establishing paragaph-like boxes.</xd:desc>
  </xd:doc>
  
  <xsl:template match="tei:div">
    <div>
      <xsl:apply-templates select="@* | node()" />
    </div>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Default</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>