<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>This step tries to guess which stretches of text could be a heading. It does so by comparing the font size
      to the average font size in the whole document. If the size is greater than the average, we assume it’s a
      heading, if it’s smaller, we mark it with a negative level.</xd:p>
    </xd:desc>
  </xd:doc>
  
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
  
  <xd:doc>
    <xd:desc>
      <xd:p>Try a classification based on relative font size and assign a level</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="text">
    <xsl:variable name="mysize" select="number(@size)"/>
    <xsl:choose>
      <xsl:when test="$mysize &gt; $mainsize">
        <head>
          <xsl:attribute name="level"
            select="count($sizes/*[. &gt; $mysize])" />
          <xsl:apply-templates select="@* | node()" />
        </head>
      </xsl:when>
      <xsl:when test="$mysize &lt; $mainsize">
        <xsl:copy>
          <xsl:attribute name="level"
             select="'-' || count($sizes/*[. &gt; $mysize and . &lt; $mainsize])" />
          <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
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