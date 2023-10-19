<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
   xmlns:x="http://www.jenitennison.com/xslt/xspec"
   xmlns:tei="http://www.tei-c.org/ns/1.0"
   xmlns:pt="https://github.com/dariok/pdf2tei"
   xmlns="http://www.tei-c.org/ns/1.0"
   exclude-result-prefixes="#all"
   version="3.0">
   
   <xsl:output indent="1" />
   
   <xd:doc>
     <xd:desc>
       <xd:p>Try to find the borders of blocks</xd:p>
        <xd:p>Variant 1: there is a heading from which we start finding blocks.</xd:p>
     </xd:desc>
   </xd:doc>
  <xsl:template match="tei:div[tei:l and tei:head]">
    <div>
       <!-- tei:head[1] as there may be other tei:head with @level gt $level + 1 – e.g. a skipped level or there is no
          really good levelling – and we don’t want to destroy the order of thexts -->
       <xsl:apply-templates select="tei:head[1]/preceding-sibling::tei:pb" />
       <xsl:apply-templates select="tei:head[1]" />
       <xsl:call-template name="blocks">
          <xsl:with-param name="context" select="tei:head/following-sibling::*" />
          <xsl:with-param name="level" select="0" />
       </xsl:call-template>
    </div>
  </xsl:template>
   
   <xd:doc>
      <xd:desc>
         <xd:p>Try to find the borders of blocks</xd:p>
         <xd:p>Variant 2: no heading here but in a sub-div.</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="tei:div[tei:l and not(tei:head) and tei:div/tei:head]">
      <div>
         <xsl:apply-templates select="tei:div[1]/preceding-sibling::node()" />
      </div>
      <xsl:apply-templates select="tei:div | node()[preceding-sibling::tei:div]" />
   </xsl:template>
   
   <xd:doc>
      <xd:desc>
         <xd:p>assumptions when guessing blocks are made in pt:ab()</xd:p>
      </xd:desc>
      <xd:param name="context">A sequence of items to evaluate</xd:param>
      <xd:param name="level">The block level</xd:param>
   </xd:doc>
   <xsl:template name="blocks">
      <xsl:param name="context" />
      <xsl:param name="level" as="xs:double"/>
      
      <xsl:for-each-group select="$context" group-starting-with="tei:l[(@level/number() = $level) and pt:ab(.)]">
<!--         <xsl:apply-templates select="current-group()[self::tei:head]" />-->
         <xsl:if test="count(current-group()[not(self::tei:div or self::tei:head)]) gt 0">
            <ab>
               <xsl:for-each-group select="current-group()[not(self::tei:div)]"
                     group-adjacent="(@level, $level)[1]">
                  <xsl:choose>
                     <xsl:when test="current-grouping-key() = $level">
                        <xsl:apply-templates select="current-group()" />
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:call-template name="blocks">
                           <xsl:with-param name="context" select="current-group()" />
                           <xsl:with-param name="level" select="max(current-group()/@level)" />
                        </xsl:call-template>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:for-each-group>
               <!--<xsl:choose>
                  <xsl:when test="current-group()[@level = $level - 1]">
                     <xsl:for-each-group select="current-group()[not(self::tei:div)]"
                        group-starting-with="tei:l[@level ne preceding-sibling::tei:l[1]/@level]">
                        <xsl:choose>
                           <xsl:when test="current-group()[1]/@level = $level">
                              <xsl:apply-templates select="current-group()"/>
                           </xsl:when>
                           <xsl:otherwise>
                              <xsl:call-template name="blocks">
                                 <xsl:with-param name="context" select="current-group()" />
                                 <xsl:with-param name="level" select="$level - 1" />
                              </xsl:call-template>
                           </xsl:otherwise>
                        </xsl:choose>
                     </xsl:for-each-group>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:apply-templates select="current-group()[not(self::tei:div)]" />
                  </xsl:otherwise>
               </xsl:choose>-->
            </ab>
         </xsl:if>
         <xsl:apply-templates select="current-group()[self::tei:div]" />
      </xsl:for-each-group>
   </xsl:template>
   
   <xd:doc>
      <xd:desc>
         <xd:p>Try to determine whether the tei:l passed starts a new paragraph</xd:p>
      </xd:desc>
      <xd:param name="context">The context item</xd:param>
   </xd:doc>
   <xsl:function name="pt:ab" as="xs:boolean">
      <xsl:param name="context" as="element()" />
      
      <xsl:variable name="level" select="$context/@level" />
      <xsl:variable name="pre" select="$context/preceding-sibling::tei:l[@level = $level][1]" />
      <xsl:variable name="next" select="$context/following-sibling::tei:l[@level = $level][1]" />
      
      <xsl:variable name="myPb" select="$context/preceding::tei:pb[1]" />
      <xsl:variable name="prePb" select="$pre/preceding::tei:pb[1]" />
      <xsl:variable name="nextPb" select="$next/preceding::tei:pb[1]" />
      
      <xsl:variable name="myL" select="$context/@left - $myPb/@l" />
      <xsl:variable name="preL" select="$pre/@left - $prePb/@l" />
      <xsl:variable name="nextL" select="$next/@left - $nextPb/@l" />
      
      <!-- a line ... -->
      <xsl:choose>
         <!-- ... cannot start a block if it starts with a small letter -->
         <xsl:when test="matches(normalize-space($context), '^[a-z]')">
            <xsl:sequence select="false()" />
         </xsl:when>
         <!-- ... does start a block if the previous line is shorter than the average right on its page minus some margin of error -->
         <xsl:when test="$pre/@right/number() lt $prePb/@r - 0.02 * $prePb/@width">
            <xsl:sequence select="true()" />
         </xsl:when>
         <xsl:when test="$myL ne $preL and $myL ne $nextL and $context/@right/number() gt $myPb/@r - 0.02 * $myPb/@width">
            <xsl:value-of select="true()" />
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="false()"/>
         </xsl:otherwise>
      </xsl:choose>
      <!-- preceding-sibling::tei:l[@level = $level][1]/@right/number()
         lt preceding-sibling::tei:l[@level = $level][1]/preceding::tei:pb[1]/@r
            + 0.01 * preceding-sibling::tei:l[@level = $level][1]/preceding::tei:pb[1]/@width
      and @left/number() - preceding::tei:pb[1]/@l
         ne preceding-sibling::tei:l[@level = $level][1]/@left
            - preceding-sibling::tei:l[@level = $level][1]/preceding::tei:pb[1]/@l
      and @left/number() - preceding::tei:pb[1]/@l
         ne following-sibling::tei:l[@level = $level][1]/@left
            - preceding-sibling::tei:l[@level = $level][1]/preceding::tei:pb[1]/@l-->
      
      <!--<xsl:for-each-group select="$context" group-starting-with="tei:l[(@level = $level)
         and (
            not(preceding-sibling::tei:l[@level = $level])
            or @right/number() - @left/number() + preceding::tei:pb[1]/@l
               gt preceding-sibling::tei:l[1][@level = $level]/@right
                  - preceding-sibling::tei:l[1][@level = $level]/@left
                  + preceding-sibling::tei:l[1][@level = $level]/preceding::tei:pb[1]/@l
                  + 0.03 * preceding-sibling::tei:l[1][@level = $level]/preceding::tei:pb[1]/@width
            or (
               @left - preceding::tei:pb[1]/@l
                  ne following-sibling::tei:l[@level = $level][1]/@left
                  - following-sibling::tei:l[1][@level = $level]/preceding::tei:pb[1]/@l
               and @left - preceding::tei:pb[1]/@l
                  ne preceding-sibling::tei:l[@level = $level][1]/@left
                  - preceding-sibling::tei:l[1][@level = $level]/preceding::tei:pb[1]/@l
            )
            or (
               @left - preceding::tei:pb[1]/@l
                 ne preceding-sibling::tei:l[@level = $level][1]/@left
                 - preceding-sibling::tei:l[1][@level = $level]/preceding::tei:pb[1]/@l
               and not(following-sibling::tei:l)
            )
         )]"
      >-->
      
      <!--  @left ne preceding-sibling::tei:l[@level = $level]/@left
               and (
                  preceding-sibling::tei:l[@level = $level][1]/@right/number()
                     lt preceding::tei:pb/@r - 0.02 * preceding::tei:pb/@width
                  or preceding-sibling::tei:l[@level = $level][1]/@right/number()
                     ge preceding-sibling::tei:l[@level = $level][1]/preceding::tei:pb[1]/@r/number()
               )
            )
            or  -->
   </xsl:function>
   
   <xd:doc>
      <xd:desc>
         <xd:p><xd:pre>@level</xd:pre> can be dropped</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="tei:head/@level" />
   
   <xd:doc>
      <xd:desc>
         <xd:p><xd:pre>text</xd:pre> to <xd:pre>tei:hi</xd:pre>, avoiding nested hi</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="tei:l/*:run">
      <xsl:choose>
         <xsl:when test="tei:hi">
            <xsl:variable name="atts" select="@*" />
            <xsl:for-each select="tei:hi">
               <hi>
                  <xsl:sequence select="$atts" />
                  <xsl:sequence select="@*" />
                  <xsl:apply-templates select="node()" />
               </hi>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <hi>
               <xsl:sequence select="@*" />
               <xsl:apply-templates />
            </hi>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   
   <xd:doc>
      <xd:desc>hi may contain other hi</xd:desc>
   </xd:doc>
   <xsl:template match="tei:hi">
      <hi>
<!--         <xsl:sequence select="../@*[not(name() = 'level')]" />-->
         
         <xsl:choose>
            <xsl:when test="tei:hi">
               <xsl:attribute name="rend" select="@rend || ' ' || tei:hi/@rend" />
               <xsl:sequence select="tei:hi/text()" />
            </xsl:when>
            <xsl:otherwise>
               <xsl:sequence select="@*" />
               <xsl:apply-templates />
            </xsl:otherwise>
         </xsl:choose>
      </hi>
   </xsl:template>
   
   <xd:doc>
      <xd:desc>Necessary for dealing with mixed content in XSpec</xd:desc>
   </xd:doc>
   <xsl:template match="x:text">
      <xsl:apply-templates />
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
