<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>This step tries to guess which stretches of text could be a heading. It does so by comparing the font size
      to the average font size in the whole document. If the size is greater than the average, we assume it’s a
      heading, if it’s smaller, we mark it with a negative level.</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:template match="tei:TEI">
    <xsl:variable name="sizes" as="xs:double+">
      <xsl:for-each-group select="descendant::tei:l" group-by="@size">
        <xsl:sort select="count(current-group())" order="descending" />
        
         <xsl:sequence select="number(current-group()[1]/@size)" />
      </xsl:for-each-group>
    </xsl:variable>
    
    <xsl:variable name="mainsize" as="xs:double">
      <xsl:value-of select="$sizes[1]"/>
    </xsl:variable>
    
    <TEI>
      <xsl:sequence select="tei:teiHeader" />
      <xsl:apply-templates select="tei:body">
        <xsl:with-param name="sizes" select="$sizes" tunnel="1" />
        <xsl:with-param name="mainsize" select="$mainsize" tunnel="1" />
      </xsl:apply-templates>
    </TEI>
  </xsl:template>
  
   <xd:doc>
      <xd:desc>
         <xd:p>Evaluate for the left alignment to aid block detection</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="*:page">
      <xsl:variable name="lefts" as="element()*">
         <xsl:for-each-group select="tei:l" group-by="@left">
            <xsl:sort select="count(current-group())" order="descending" />
            <l value="{current-grouping-key()}" count="{count(current-group())}" />
         </xsl:for-each-group>
      </xsl:variable>
      <xsl:variable name="rights" as="element()*">
         <xsl:for-each-group select="tei:l" group-by="@right">
            <xsl:sort select="count(current-group())" order="descending" />
            <xsl:sort select="current-grouping-key()" order="descending" />
            <r value="{current-grouping-key()}" count="{count(current-group())}" />
         </xsl:for-each-group>
      </xsl:variable>
      
      <page>
         <xsl:attribute name="l" select="$lefts[1]/@value" />
         <xsl:attribute name="r" select="$rights[1]/@value" />
         <xsl:apply-templates select="@* | node()" />
      </page>
   </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Try a classification based on relative font size and assign a level</xd:p>
      <xd:p>Try to establish column breaks, marginalia or forme work: line jumps back to top</xd:p>
    </xd:desc>
    <xd:param name="sizes">Sequence of all size values in the document</xd:param>
    <xd:param name="mainsize">The most common size in the document</xd:param>
  </xd:doc>
  <xsl:template match="tei:l">
    <xsl:param name="sizes" tunnel="true" />
    <xsl:param name="mainsize" tunnel="true" as="xs:double" />
    <xsl:variable name="mysize" select="number(@size)" as="xs:double" />
    <xsl:variable name="mytop" select="number(@top)" as="xs:double" />
    
    <xsl:choose>
      <xsl:when test="$mysize gt $mainsize">
        <head>
          <xsl:attribute name="level" select="1 + count($sizes[. gt $mainsize and . lt $mysize])" />
          <l>
            <xsl:apply-templates select="@* | node()" />
          </l>
        </head>
      </xsl:when>
      <xsl:when test="$mainsize eq $mysize">
        <l level="0">
           <xsl:apply-templates select="@* | node()" />
        </l>
      </xsl:when>
      <xsl:otherwise>
        <l>
          <xsl:attribute name="level"
             select="-1 - count($sizes[. gt $mysize and . lt $mainsize])" />
          <xsl:apply-templates select="@* | node()" />
        </l>
      </xsl:otherwise>
    </xsl:choose>
    
    <xsl:if test="following-sibling::*[1]/@top/number(.) lt $mytop">
      <cb />
    </xsl:if>
  </xsl:template>
   
   <xd:doc>
      <xd:desc>tei:body (from pt0.xsl) → tei:text</xd:desc>
   </xd:doc>
   <xsl:template match="tei:body">
      <text>
         <xsl:apply-templates />
      </text>
   </xsl:template>
   
   <xd:doc>
      <xd:desc>
         <xd:p>If there is a gap between text runs, translate this to a space</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="tei:l/tei:run[preceding-sibling::*]">
      <xsl:variable name="prec" select="preceding-sibling::*[1]" />
      <xsl:variable name="precRight" select="number($prec/@left) + number($prec/@width)" />
      
      <xsl:variable name="myContent">
         <xsl:apply-templates select="." mode="runContent" />
      </xsl:variable>
      <xsl:variable name="precContent">
         <xsl:apply-templates select="$prec" mode="runContent" />
      </xsl:variable>
      
      <xsl:if test="$precRight lt number(@left) - 1 and not(ends-with($precContent, ' ') or starts-with($myContent, ' '))">
         <run>
            <xsl:text> </xsl:text>
         </run>
      </xsl:if>
      <xsl:sequence select="." />
   </xsl:template>
   
   <xd:doc>
     <xd:desc>to see whether there are spaces in the text content</xd:desc>
   </xd:doc>
  <xsl:template match="tei:run" mode="runContent">
      <xsl:choose>
         <xsl:when test="*">
            <xsl:value-of select="*"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="."/>
         </xsl:otherwise>
      </xsl:choose>
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
