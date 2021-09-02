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
  
  <xsl:variable name="specs" select="//*:fontspec"/>
  
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
            <xsl:apply-templates select="$specs" />
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
      <xd:p>Evalutate <xd:pre>@top</xd:pre> to group <xd:pre>*:text</xd:pre> into lines.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="*:page">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:for-each-group select="*[not(self::*:fontspec)]" group-starting-with="*[
         @top/number() gt preceding-sibling::*[@top][1]/@top + preceding-sibling::*[@top][1]/@height
         or @top/number() lt preceding-sibling::*[@top][1]/@top - preceding-sibling::*[@top][1]/@height
      ]">
        <xsl:variable name="bottom" select="for $e in current-group() return $e/@top + $e/@height"/>
        <xsl:variable name="sizes" as="xs:int*">
          <xsl:choose>
            <xsl:when test="current-group()[@font]">
              <xsl:for-each-group select="current-group()" group-by="pt:size(.)">
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
         <p>Get the font size for the given element</p>
      </xd:desc>
      <xd:param name="context">The element to be avaluated</xd:param>
   </xd:doc>
   <xsl:function name="pt:size" as="xs:double">
      <xsl:param name="context" as="element()" />
      
      <xsl:sequence select="$specs[@id = $context/@font]/@size/number()" />
   </xsl:function>
  
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
      <xsl:attribute name="size" select="$specs[@id = $font][1]/@size" />
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