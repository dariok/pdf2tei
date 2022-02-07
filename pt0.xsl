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
         <xd:p>Create <xd:pre>tei:rendition</xd:pre> from <xd:pre>*:fontspec</xd:pre>. Translate info to CSS</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="*:fontspec" mode="header">
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
      <xd:desc>Remove <xd:pre>fontspec</xd:pre> from <xd:pre>page</xd:pre></xd:desc>
   </xd:doc>
   <xsl:template match="*:fontspec" />
   
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
                  <xsl:apply-templates select="$specs" mode="header" />
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
         <xd:p>Create <xd:pre>@rendition</xd:pre> to point to <xd:pre>tei:rendition</xd:pre>, save size info to
            <xd:pre>@size</xd:pre></xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="*:text">
      <xsl:variable name="font" select="@font"/>
      <hi>
         <xsl:apply-templates select="@*" />
         <xsl:attribute name="size">
            <!--<xsl:choose>
               <xsl:when test="@font">
                  <xsl:sequence select="$specs[@id = $font]/@size/number()" />
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="@top + @height"/>
               </xsl:otherwise>
            </xsl:choose>-->
            <xsl:sequence select="$specs[@id = $font]/@size/number()" />
         </xsl:attribute>
         <xsl:attribute name="rendition" select="'#f' || @font" />
         
         <xsl:sequence select="node()" />
      </hi>
   </xsl:template>
   
   <xd:doc>
      <xd:desc>Later evaluations need <xd:pre>@size</xd:pre> so we set it to <xd:pre>@height</xd:pre>.</xd:desc>
   </xd:doc>
   <xsl:template match="*:image">
      <graphic>
         <xsl:attribute name="size" select="@height" />
         <xsl:apply-templates select="@*" />
      </graphic>
   </xsl:template>
   
   <xd:doc>
      <xd:desc>Strip text that consists of whitespace only. This is necessary to prevent the text order from being corrupted in later steps</xd:desc>
   </xd:doc>
   
   <xsl:template match="text[string-length(translate(., ' &#9;&#xA;&#xD;','')) = 0]" />
    
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