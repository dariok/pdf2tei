<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:x="http://www.jenitennison.com/xslt/xspec"
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
    <!--<xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:for-each-group select="*[not(self::x:text)]" group-starting-with="*[
            @top/number() gt preceding-sibling::*[@top][1]/@top + .5 * preceding-sibling::*[@top][1]/@height
         or @top/number() lt preceding-sibling::*[@top][1]/@top - .5 * preceding-sibling::*[@top][1]/@height
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
    </xsl:copy>-->
      <xsl:copy>
         <xsl:apply-templates select="@*" />
         
         <xsl:variable name="byTop">
            <xsl:for-each-group select="*[not(self::x:text)]" group-by="@top">
               <xsl:sort select="number(@top)" />
               <xsl:sequence select="current-group()" />
            </xsl:for-each-group>
         </xsl:variable>
         
         <xsl:for-each-group select="$byTop/*"
               group-starting-with="*[number(@top) ge preceding-sibling::*[1]/@top + preceding-sibling::*[1]/@size - 1]">
            <xsl:variable name="sizes" as="xs:int*">
               <!--<xsl:choose>
                  <xsl:when test="current-group()[@font]">
                     <xsl:for-each-group select="current-group()" group-by="@size">
                        <xsl:sort select="string-length(string-join(current-group()))"
                           order="descending"/>
                        <xsl:value-of select="current-grouping-key()"/>
                     </xsl:for-each-group>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:value-of select="@size"/>
                  </xsl:otherwise>
               </xsl:choose>-->
               <xsl:choose>
                  <xsl:when test="current-group()[self::*:run]">
                     <xsl:sequence select="current-group()[self::*:run]/@size" />
                  </xsl:when>
                  <xsl:otherwise>2</xsl:otherwise>
               </xsl:choose>
            </xsl:variable>
            <xsl:variable name="bottom" select="for $e in current-group() return $e/@top + $e/@size"/>
            <xsl:variable name="right" select="for $e in current-group() return $e/@left + $e/@width"/>
            
            <l left="{min(current-group()/@left)}" top="{min(current-group()/@top)}"
               size="{max($sizes)}" bottom="{max($bottom)}"
               right="{max($right)}">
               <xsl:apply-templates select="current-group()">
                  <xsl:sort select="number(@left)"/>
               </xsl:apply-templates>
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
      <xd:desc>This one is onyl necessary to deal with mixed content in XSpec</xd:desc>
   </xd:doc>
   <xsl:template match="x:text">
      <xsl:value-of select="." />
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