<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
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
       <xd:p>Try to find the borders of blocks</xd:p>
     </xd:desc>
   </xd:doc>
  <xsl:template match="tei:div">
    <div>
      <xsl:call-template name="blocks">
         <xsl:with-param name="context" select="*" />
         <xsl:with-param name="level" select="0" />
      </xsl:call-template>
    </div>
  </xsl:template>
   
   <xd:doc>
      <xd:desc>
         <xd:p>assumptions when guessing blocks:
            <xd:ul>
               <xd:li>- no preceding-sibling::tei:l  ––  e.g. first line after heading</xd:li>
               <xd:li>- @left has some other value than the main left of the page</xd:li>
               <xd:li>- @size is different than the previous lines’</xd:li>
               <xd:li>- the previous line is more than 1% of total width shorter than it’s preceding line (we assume all pages have
                 roughly the same width or it will get even more complicated)</xd:li>
               <xd:li>- does not start with a small letter</xd:li>
            </xd:ul>
         </xd:p>
      </xd:desc>
      <xd:param name="context">A sequence of items to evaluate</xd:param>
      <xd:param name="level">The block level</xd:param>
   </xd:doc>
   <xsl:template name="blocks">
      <xsl:param name="context" />
      <xsl:param name="level" as="xs:integer"/>
      
      <xsl:for-each-group select="$context" group-starting-with="tei:l[(@level = $level or ($level = 0 and not(@level)))
         and matches(., '^[A-ZÄÖÜ0-9„“]')
         and (
            not(preceding-sibling::tei:l)
            or @left ne preceding-sibling::tei:l[1]/@left
            or @size ne preceding-sibling::tei:l[1]/@size
            or preceding-sibling::tei:l[1]/@right/number()
                lt preceding-sibling::tei:l[2]/@right/number() - 0.01 * preceding::tei:pb[1]/@width
         )]"
      >
         <xsl:variable name="first" select="(current-group()[self::tei:l
            and (@level = $level or (not(@level) and $level = 0))])[1]" />
         <xsl:variable name="id" select="generate-id($first)" />
         
         <xsl:choose>
            <xsl:when test="$first">
               <xsl:apply-templates select="current-group()[following-sibling::*[generate-id() = $id]]" />
               <ab>
                  <xsl:choose>
                     <xsl:when test="current-group()[@level = $level - 1]">
                        <xsl:variable name="eval" select="$first |
                           current-group()[preceding-sibling::*[generate-id() = $id] and not(self::tei:div)]" />
                        <xsl:for-each-group select="$eval"
                           group-starting-with="tei:l[@level ne preceding-sibling::tei:l[1]/@level]">
                           <xsl:call-template name="blocks">
                              <xsl:with-param name="context" select="current-group()" />
                              <xsl:with-param name="level" select="$level - 1" />
                           </xsl:call-template>
                        </xsl:for-each-group>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:apply-templates select="current-group()[not(self::tei:div)]" />
                     </xsl:otherwise>
                  </xsl:choose>
               </ab>
               <xsl:apply-templates select="current-group()[self::tei:div]" />
            </xsl:when>
            <xsl:otherwise>
               <xsl:apply-templates select="current-group()" />
            </xsl:otherwise>
         </xsl:choose>
      </xsl:for-each-group>
   </xsl:template>
   
   <xd:doc>
      <xd:desc>
         <xd:p><xd:pre>@level</xd:pre> can be dropped</xd:p>
      </xd:desc>
   </xd:doc>
   <xsl:template match="@level" />
   
   <xd:doc>
      <xd:desc>Default</xd:desc>
   </xd:doc>
   <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
