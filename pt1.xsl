<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:output omit-xml-declaration="1" indent="1" />
  
  <xd:doc>
    <xd:desc>
      <xd:p>Create the basic TEI outline:
        <xd:ul>
          <xd:li>Create <xd:pre>tei:TEI</xd:pre>, <xd:pre>tei:teiHeader</xd:pre>, <xd:pre>tei:text</xd:pre></xd:li>
          <xd:li>create a <xd:pre>tei:tagsDecl</xd:pre> from the <xd:pre>*:fontspec</xd:pre> elements</xd:li>
          <xd:li>create a preliminary content for <xd:pre>tei:text</xd:pre> from <xd:pre>*:page</xd:pre></xd:li>
        </xd:ul>
      </xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="*:pdf2xml">
    <TEI>
      <teiHeader>
        <encodingDesc>
          <tagsDecl>
            <xsl:apply-templates select="//*:fontspec" />
          </tagsDecl>
        </encodingDesc>
      </teiHeader>
      <text>
        <xsl:apply-templates select="*:page" />
      </text>
    </TEI>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Copy <xd:pre>*:page</xd:pre> into <xd:pre>tei:text</xd:pre>, omit <xd:pre>*:fontspec</xd:pre> as it will be
        used for tei:tagsDecl</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="*:page">
    <xsl:copy>
      <xsl:apply-templates select="@* | *[not(self::*:fontspec)]" />
    </xsl:copy>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Create <xd:pre>@rendition</xd:pre> to point to <xd:pre>tei:rendition</xd:pre>, save size info to
        <xd:pre>@size</xd:pre></xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="*:text">
    <xsl:variable name="font" select="@font"/>
    <xsl:copy>
      <xsl:attribute name="rendition" select="'#f' || @font" />
      <xsl:attribute name="size" select="//*:fontspec[@id = $font]/@size" />
      <xsl:apply-templates select="@* | node()" />
    </xsl:copy>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Create <xd:pre>tei:rendition</xd:pre> from <xd:pre>*:fontspec</xd:pre>. Translate info to CSS</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="*:fontspec">
    <rendition scheme="css">
      <xsl:attribute name="xml:id" select="'f' || @id" />
      <xsl:text>font-size: </xsl:text>
      <xsl:value-of select="@size" />
      <xsl:text>pt; font-family: </xsl:text>
      <xsl:value-of _select="@family" />
      <xsl:text>; color: </xsl:text>
      <xsl:value-of select="@color" />
      <xsl:text>;</xsl:text>
    </rendition>
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