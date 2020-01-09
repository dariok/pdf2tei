<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:pt="https://github.com/dariok/pt"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:template match="tei:text/*">
    <xsl:text>
    </xsl:text>
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="tei:head[number(@level) = 0]">
          <xsl:apply-templates select="tei:head[number(@level) = 0]" />
        </xsl:when>
        <xsl:when test="tei:head[number(@level) = 1]">
          <xsl:apply-templates select="tei:head[number(@level) = 1]" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="level" select="tei:div[1]/tei:head[1]/@level"/>
          <xsl:apply-templates select="tei:div/tei:head[@level = $level]" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:head[@level = 0]">
    <xsl:text>
      </xsl:text>
    <xsl:copy>
      <xsl:apply-templates />
    </xsl:copy>
    <xsl:apply-templates select="following-sibling::node() 
      intersect following-sibling::tei:head[1]/preceding-sibling::node()"/>
    <xsl:apply-templates
      select="following-sibling::tei:head[number(@level) = 1]" />
  </xsl:template>
  
  <xsl:template match="tei:head">
    <xsl:variable name="me" select="."/>
    <xsl:variable name="mylevel" select="number(@level)" />
    <xsl:variable name="next"
      select="(following-sibling::tei:head[number(@level) lt $mylevel + 1])[1]"/>
    <xsl:text>
      </xsl:text>
    <div>
      <xsl:text>
        </xsl:text>
      <xsl:sequence select="." />
      <xsl:choose>
        <xsl:when test="$next">
          <xsl:apply-templates select="following-sibling::*
              intersect following-sibling::tei:head[1]/preceding-sibling::*" />
          <xsl:apply-templates select="following-sibling::tei:head[number(@level) = $mylevel + 1]
              intersect $next/preceding-sibling::tei:head" />
        </xsl:when>
        <xsl:when test="not($next) and following-sibling::tei:head">
          <xsl:apply-templates select="following-sibling::*
              intersect following-sibling::tei:head[1]/preceding-sibling::*" />
          <xsl:apply-templates select="following-sibling::tei:head[number(@level) = $mylevel + 1]" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="following-sibling::*" />
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
    <!-- anpassen! z.B. Register: 2 text mit gleichem top, aber verschd. left: pt:tab dazwischen, wenn 
      danach top größer ist, pt:lb dazwischen, außer es gibt auch Einzug, dann pt:p -->
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