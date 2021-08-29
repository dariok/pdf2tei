<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:pt="https://github.com/dariok/pt"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:output indent="1" />
  
  <xd:doc>
    <xd:desc>
      <xd:p>Try to create a structure and write it to <xd:pre>tei:body</xd:pre>.</xd:p>
    </xd:desc>
  </xd:doc>
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
  
  <xd:doc>
    <xd:desc>
      <xd:p>Try to create a hierarchical structure of <xd:pre>tei:div</xd:pre> based to lines that have been recognized
        as headings. Use the value of <xd:pre>@level</xd:pre> to determine nesting.</xd:p>
      <xd:p>We try to move a <xd:pre>tei:pb</xd:pre> inside the <xd:pre>tei:div</xd:pre>; this will produce an empty
         <xd:pre>tei:div</xd:pre> at the very beginning.</xd:p>
    </xd:desc>
    <xd:param name="level">The level to use for grouping</xd:param>
    <xd:param name="context">The content of the parent <xd:pre>tei:div</xd:pre> which is to be structured.</xd:param>
  </xd:doc>
  <xsl:template name="divStructure">
    <xsl:param name="level" as="xs:integer" />
    <xsl:param name="context" as="element()+" />
    
    <xsl:for-each-group select="$context"
      group-starting-with="tei:head[@level = $level]">
      <div>
        <xsl:choose>
          <xsl:when test="current-group()[self::tei:head and @level = $level + 1]">
            <xsl:variable name="head" select="current-group()[1]"/>
            <xsl:variable name="lower" select="current-group()[self::tei:head and @level = $level +1][1]"/>
            
            <xsl:apply-templates select="$head/preceding-sibling::*[1][self::tei:pb]" mode="copy" />
            <xsl:apply-templates select="$head" />
            <xsl:apply-templates select="$head/following-sibling::* intersect $lower/preceding-sibling::*" />
            <xsl:call-template name="divStructure">
              <xsl:with-param name="context" select="$lower | current-group()[preceding-sibling::*[@level = $level +1 ]]" />
              <xsl:with-param name="level" select="$level + 1" />
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="current-group()[1]/preceding-sibling::*[1][self::tei:pb]" mode="copy" />
            <xsl:apply-templates select="current-group()" />
          </xsl:otherwise>
        </xsl:choose>
      </div>
    </xsl:for-each-group>
  </xsl:template>
   
   <xd:doc>
      <xd:desc>
         <xd:p><xd:pre>tei:pb</xd:pre> immediately before <xd:pre>tei:head</xd:pre> is moved into <xd:pre>div</xd:pre>
            by structuring template</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="tei:pb[following-sibling::*[1][self::tei:head]]" />
   
   <xd:doc>
      <xd:desc>
         <xd:p>Called by structuring template</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="tei:pb" mode="copy">
      <pb>
         <xsl:apply-templates select="@* | node()" />
      </pb>
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