<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:pt="https://github.com/dariok/pt"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:variable name="sizes">
    <xsl:for-each-group select="//*:text" group-by="@size">
      <xsl:sort select="count(current-group())" order="descending" />
      <s>
        <xsl:value-of select="current-group()[1]/@size"/>
      </s>
    </xsl:for-each-group>
  </xsl:variable>
  
  <xsl:variable name="mainsize" as="xs:int">
    <xsl:value-of select="number($sizes/*[1])"/>
  </xsl:variable>
  
  <xsl:template match="*:text">
    <xsl:variable name="mysize" select="number(@size)"/>
    <xsl:choose>
      <xsl:when test="self::tei:text">
        <text>
          <xsl:apply-templates />
        </text>
      </xsl:when>
      <xsl:when test="$mysize &gt; $mainsize">
        <head>
          <xsl:attribute name="level"
            select="count($sizes/*[. &gt; $mysize])" />
          <xsl:apply-templates select="@* | node()" />
        </head>
      </xsl:when>
      <xsl:when test="$mysize &lt; $mainsize">
        <hi rend="font-size: {$mysize}">
          <xsl:apply-templates select="@* | node()" />
        </hi>
      </xsl:when>
      <xsl:otherwise>
        <pt:text>
          <xsl:apply-templates select="@* | node()" />
        </pt:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="*:page">
    <pb n="{@number}" />
    <xsl:apply-templates />
  </xsl:template>
  
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>