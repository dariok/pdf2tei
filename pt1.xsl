<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:pt="https://github.com/dariok/pdf2tei"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:output omit-xml-declaration="1" indent="1" />
  
  <xd:doc>
    <xd:desc>
      <xd:p>Copy <xd:pre>*:page</xd:pre> into <xd:pre>tei:text</xd:pre>, omit <xd:pre>*:fontspec</xd:pre> as it will be
        used for tei:tagsDecl</xd:p>
      <xd:p>Evalutate <xd:pre>@top</xd:pre> to group <xd:pre>*:text</xd:pre> into lines.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="*:page">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:for-each-group select="*" group-starting-with="*[
         @top/number() ge preceding-sibling::*[@top][1]/@top + preceding-sibling::*[@top][1]/@size
         or @top/number() lt preceding-sibling::*[@top][1]/@top - preceding-sibling::*[@top][1]/@size
      ]">
        <xsl:variable name="bottom" select="for $e in current-group() return $e/@top + $e/@size"/>
        <xsl:variable name="sizes" as="xs:int*">
          <xsl:choose>
            <xsl:when test="current-group()[@font]">
              <xsl:for-each-group select="current-group()" group-by="@size">
                <xsl:sort select="string-length(string-join(current-group()))" order="descending" />
                <xsl:value-of select="current-grouping-key()" />
              </xsl:for-each-group>
            </xsl:when>
            <xsl:otherwise>0</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        
        <l left="{current-group()[1]/@left}" top="{min(current-group()/@top)}" size="{$sizes[1]}"
          bottom="{max($bottom)}" right="{current-group()[last()]/@left + current-group()[last()]/@width}">
          <xsl:apply-templates select="current-group()" />
        </l>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Font info is now stored in <xd:pre>tei:rendition</xd:pre></xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="@font" />
  
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