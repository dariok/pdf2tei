<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:pt="https://github.com/dariok/pt"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:output indent="1" />
  
  <xd:doc scope="stylesheet">
    <xd:desc>Combine <xd:pre>text</xd:pre> into <xd:pre>tei:l</xd:pre> so we can reconstruct line breaks
      and have a basis for establishing paragaph-like boxes.</xd:desc>
  </xd:doc>
  
  <xsl:template match="tei:div">
    <div>
      <xsl:sequence select="@*" />
      <xsl:call-template name="lines">
        <xsl:with-param name="texts" select="*" />
      </xsl:call-template>
    </div>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Evalutate <xd:pre>@top</xd:pre> to group <xd:pre>*:text</xd:pre> into lines.</xd:p>
    </xd:desc>
    <xd:param name="texts">A sequence to texts to be grouped.</xd:param>
  </xd:doc>
  <xsl:template name="lines">
    <xsl:param name="texts" />
    
    <!-- div by ($mainsizeOfPage - 2) may be more accurate but does not seem necessary in current tests -->
    <xsl:for-each-group select="$texts" group-adjacent="round(number(@top) div 10)">
      <xsl:choose>
        <!-- no @top: pagebreak -->
        <xsl:when test="not(@top)">
          <!-- this can be a pb or a head or a sequence of these (e. g. part title, page break, chapter title).
            Hence, we need to look at each part in turn -->
          <xsl:for-each select="current-group()">
            <xsl:choose>
              <xsl:when test="text">
                <xsl:copy>
                  <xsl:sequence select="@*" />
                  <xsl:call-template name="lines">
                    <xsl:with-param name="texts" select="*" />
                  </xsl:call-template>
                </xsl:copy>
              </xsl:when>
              <xsl:otherwise>
                <xsl:sequence select="." />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:when>
        <!-- We need to evaluate info such as @left later, so we copy the elements -->
        <xsl:otherwise>
          <xsl:variable name="bottom" select="for $e in current-group() return $e/@top + $e/@height"/>
          
          <l left="{current-group()[1]/@left}" top="{min(current-group()/@top)}" size="{current-group()[1]/@size}"
              bottom="{max($bottom)}" right="{current-group()[last()]/@left + current-group()[last()]/@width}">
            <xsl:apply-templates select="current-group()" />
          </l>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each-group>
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