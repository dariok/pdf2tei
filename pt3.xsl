<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:output indent="1" />
  
  <xd:doc>
    <xd:desc>
      <xd:p>Try to guess whether there’s forme work on this page; normal book or article pages ususally have no more
        than one line of footer and header each. Official writs, letters etc. may have more (e. g. complete addresses
        etc. but we ignore those use cases for now – this can be dealt with in post processing.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="*:page">
    <xsl:choose>
      <xsl:when test="tei:cb and count(tei:cb[1]/preceding-sibling::*) lt 2 and not(tei:cb[1]/preceding-sibling::tei:head)">
        <pb n="{@number}">
          <xsl:sequence select="@height | @width | @l" />
          <xsl:apply-templates select="tei:cb[1]/preceding-sibling::*" />
        </pb>
        <xsl:apply-templates select="tei:cb[1]/following-sibling::*" />
      </xsl:when>
      <xsl:otherwise>
        <pb n="{@number}">
          <xsl:sequence select="@height | @width | @l" />
        </pb>
        <xsl:apply-templates />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Convert links to <xd:pre>tei:ref</xd:pre></xd:p>
    </xd:desc>
  </xd:doc>
  <!-- TODO This will need more detailed work -->
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
  
  <xd:doc>
    <xd:desc>
      <xd:p>Bold sections: <xd:pre>tei:hi</xd:pre>; use <xd:pre>@rend</xd:pre> for now.</xd:p>
    </xd:desc>
  </xd:doc>
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
  
  <xd:doc>
    <xd:desc>
      <xd:p>Italic sections: <xd:pre>tei:hi</xd:pre>; use <xd:pre>@rend</xd:pre> for now.</xd:p>
    </xd:desc>
  </xd:doc>
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
  
  
  
  <xd:doc>
    <xd:desc>
      <xd:p>Group headings by level</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="tei:head">
    <xsl:variable name="level" select="@level" />
    <xsl:variable name="end" select="following-sibling::*[not(@level eq $level)][1]" />
    
    <xsl:choose>
      <xsl:when test="preceding-sibling::*[1][@level eq $level]" />
      <xsl:otherwise>
        <head level="{$level}">
          <xsl:apply-templates select="* | (following-sibling::* intersect $end/preceding-sibling::*)/*" />
        </head>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Default</xd:desc>
  </xd:doc>
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>