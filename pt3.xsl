<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:output indent="1" />
  
  <xsl:template match="tei:text">
    <text>
      <body>
        <xsl:call-template name="divStructure">
          <xsl:with-param name="context" select="*" />
          <xsl:with-param name="level" select="0" />
        </xsl:call-template>
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
  
  <xsl:template name="divStructure">
    <xsl:param name="level" as="xs:integer" />
    <xsl:param name="context" as="element()+" />
    
    <xsl:for-each-group select="$context" group-starting-with="tei:head[@level = $level 
      and not(preceding-sibling::*[1][self::tei:head[@level = $level]])]">
      <div>
        <xsl:apply-templates select="current-group()[self:: tei:head and @level = $level]" />
        <xsl:choose>
          <xsl:when test="current-group()[self::tei:head and @level = $level + 1]">
            <xsl:call-template name="divStructure">
              <xsl:with-param name="context" select="current-group()[not(self::tei:head and @level = $level)]" />
              <xsl:with-param name="level" select="$level + 1" />
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="lines">
              <xsl:with-param name="texts" select="current-group()[not(self::tei:head and @level = $level)]" />
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </div>
    </xsl:for-each-group>
  </xsl:template>
  
  <xsl:template name="lines">
    <xsl:param name="texts" />
    
    <!-- div by ($mainsizeOfPage - 2) may be more accurate but does not seem necessary in current tests -->
    <xsl:for-each-group select="$texts" group-adjacent="round(number(@top) div 10)">
      <l left="{current-group()[1]/@left}" top="{current-grouping-key()}">
        <xsl:apply-templates select="current-group()" />
      </l>
    </xsl:for-each-group>
  </xsl:template>
  
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>