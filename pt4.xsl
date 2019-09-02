<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:pt="https://github.com/dariok/pt"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:template match="tei:head[@level = 0]">
    <xsl:copy>
      <xsl:apply-templates />
    </xsl:copy>
    <xsl:apply-templates select="following-sibling::node() 
      intersect following-sibling::tei:head[1]/preceding-sibling::node()"/>
    <xsl:apply-templates select="following-sibling::tei:head" />
  </xsl:template>
  
  <xsl:template match="tei:div/tei:head[number(@level) &gt; 0]">
    <xsl:variable name="mylevel" select="number(@level)" />
    <xsl:variable name="next"
      select="following-sibling::tei:head[number(@level) = $mylevel
        and not(preceding-sibling::tei:head[number(@level) &lt; $mylevel])][1]"/>
    <xsl:text>
      </xsl:text>
    <div>
      <xsl:if test="preceding-sibling::node()[1][self::tei:pb]">
        <xsl:sequence select="preceding-sibling::tei:pb[1]" />
      </xsl:if>
      <head>
        <xsl:apply-templates select="@level | node()" />
      </head>
      <xsl:choose>
        <xsl:when test="$next and (following-sibling::* intersect $next/preceding-sibling::*)[self::tei:head]">
          <xsl:apply-templates select="following-sibling::tei:head[number(@level) &gt; $mylevel]
            intersect $next/preceding-sibling::tei:head" />
        </xsl:when>
        <xsl:when test="$next">
          <xsl:apply-templates select="following-sibling::* intersect $next/preceding-sibling::*" />
        </xsl:when>
        <xsl:when test="following-sibling::tei:head[number(@level) &lt; $mylevel]">
          <xsl:apply-templates select="following-sibling::*
            intersect following-sibling::tei:head[number(@level) &lt; $mylevel][1]/preceding-sibling::*"/>
        </xsl:when>
        <xsl:otherwise>
          <!--<xsl:apply-templates select="following-sibling::*" />-->
          <pt:problem />
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>
  
  <xsl:template match="tei:pb">
    <xsl:choose>
      <xsl:when test="following-sibling::node()[1][self::tei:head]" />
      <xsl:otherwise>
        <xsl:sequence select="." />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="pt:text">
    <xsl:variable name="mtop" select="number(@top)"/>
    <xsl:variable name="mleft" select="number(@left)" />
    <xsl:variable name="nextline" select="following-sibling::pt:text[number(@top) &gt; $mtop][1]" />
    <xsl:if test="$mleft &gt; $nextline/@left">
      <pt:p />
    </xsl:if>
    <xsl:apply-templates />
  </xsl:template>
  
  <xsl:template match="text()[normalize-space() = '']">
    <xsl:text> </xsl:text>
  </xsl:template>
  
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>