<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:pt="https://github.com/dariok/pt"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:output indent="1" />
  
  <xsl:template match="tei:text">
    <text>
      <body>
        <xsl:for-each-group select="node()" group-starting-with="tei:head[@level = 0 
            and not(preceding-sibling::*[1][self::tei:head[@level = 0]])]">
          <div>
            <xsl:apply-templates select="current-group()" />
          </div>
        </xsl:for-each-group>
      </body>
    </text>
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
  
  <xsl:template match="*:b">
    <xsl:choose>
      <xsl:when test="preceding-sibling::*[1][self::*:b]" />
      <xsl:otherwise>
        <hi rend="bold">
          <xsl:apply-templates select="node() | following-sibling::*[self::*:b]/node()"/>
        </hi>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="*:i">
    <xsl:choose>
      <xsl:when test="preceding-sibling::*[1][self::*:i]" />
      <xsl:otherwise>
        <hi rend="italics">
          <xsl:apply-templates select="node() | following-sibling::*[self::*:i]/node()"/>
        </hi>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>