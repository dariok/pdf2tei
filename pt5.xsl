<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:pt="https://github.com/dariok/pt"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:output indent="1" />
  
  <xd:doc>
    <xd:desc>
      <xd:p>Try to find the borders of blocks</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:template match="tei:div">
    <div>
      <xsl:for-each-group select="*" group-starting-with="tei:l[(@left ne preceding-sibling::tei:l[1]/@left
        and @left ne following-sibling::tei:l[1]/@left)
        or not(preceding-sibling::tei:l)]">
        <xsl:variable name="first" select="(current-group()[self::tei:l])[1]" />
        <xsl:variable name="id" select="generate-id($first)" />
        <xsl:choose>
          <xsl:when test="$first">
            <xsl:apply-templates select="current-group()[following-sibling::*[generate-id() = $id]]" />
            <ab>
              <xsl:apply-templates select="$first | current-group()[preceding-sibling::*[generate-id() = $id]]" />
            </ab>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="current-group()" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </div>
  </xsl:template>
  
  <!-- 
  <xsl:sequence select="@size | $group[1]/@rendition" />
          <xsl:attribute name="top" select="min($group/@top)" />
          <xsl:attribute name="left" select="min($group/@left)" />
          <xsl:attribute name="width" select="max($group/@width)" />
          <xsl:attribute name="height" select="$group[last()]/@top + $group[last()]/@height - $group[1]/@top" />
          <xsl:apply-templates select="$group" mode="head" />
  -->
  
  <xsl:template match="tei:head/@level" />
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
