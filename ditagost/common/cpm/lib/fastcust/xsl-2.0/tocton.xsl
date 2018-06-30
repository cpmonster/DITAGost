<?xml version="1.0" encoding="UTF-8"?>
<!-- * * ** *** ***** ******** ************* ********************* --> 
<!--
    Product:    CopyPaste Monster    
    
    Level:      Library
    
    Part:       FastCust
    Module:     tocton.xsl 
    
    Scope:      Generic, FO
    
    Func:       Assembling TOCs and TONs
-->   
<!-- * * ** *** ***** ******** ************* ********************* -->  
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:cpm="http://cpmonster.com/xmlns/cpm"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">

    <!-- 
        Modules
    -->

    <!-- Wrapper functions -->
    <xsl:import href="funcs.xsl"/>

    <!-- Cross references -->
    <xsl:import href="crossrefs.xsl"/>



    <!-- ============================== -->
    <!--  Working TOC/TON placeholders  -->
    <!-- ============================== -->

    <!-- 
        Assembling a TOC placeholder        
    -->
    <xsl:template name="cpm.fastcust.toc_placeholder">

        <!-- An explicit TOC scope element ID -->
        <xsl:param name="scopeid" select="''"/>

        <!-- Global vs. local -->
        <xsl:param name="scope" select="'global'"/>

        <!-- A greatest section level allowed in a TOC -->
        <xsl:param name="maxlevel" select="cpm:fastcust.numinf('')"/>

        <!-- A maximal number of levels in a TOC -->
        <xsl:param name="maxdepth" select="cpm:fastcust.numinf('')"/>

        <!-- An output class (for applying styles) -->
        <xsl:param name="outputclass" select="''"/>

        <!-- Assembling a TOC placeholder -->
        <cpm:toc maxdepth="{$maxdepth}" maxlevel="{$maxlevel}">

            <xsl:choose>

                <xsl:when test="$scopeid != ''">
                    <xsl:attribute name="scopeid">
                        <xsl:value-of select="$scopeid"/>
                    </xsl:attribute>
                </xsl:when>

                <xsl:otherwise>
                    <xsl:attribute name="scope">
                        <xsl:value-of select="$scope"/>
                    </xsl:attribute>
                </xsl:otherwise>

            </xsl:choose>

            <xsl:if test="$outputclass != ''">
                <xsl:attribute name="outputclass">
                    <xsl:value-of select="$outputclass"/>
                </xsl:attribute>
            </xsl:if>

        </cpm:toc>

    </xsl:template>


    <!-- 
        Assembling a TON placeholer
    -->
    <xsl:template name="cpm.fastcust.ton_placeholder">

        <!-- An explicit TOC scope element ID -->
        <xsl:param name="scopeid" select="''"/>

        <!-- Global vs. local -->
        <xsl:param name="scope" select="'local'"/>

        <!-- A target numbering sequence name (figure, table, etc.) -->
        <xsl:param name="numseqname"/>

        <!-- An output class (for applying styles) -->
        <xsl:param name="outputclass" select="''"/>

        <!-- Assembling a TON placeholder -->
        <cpm:ton numseq="{$numseqname}">

            <xsl:choose>

                <xsl:when test="$scopeid != ''">
                    <xsl:attribute name="scopeid">
                        <xsl:value-of select="$scopeid"/>
                    </xsl:attribute>
                </xsl:when>

                <xsl:otherwise>
                    <xsl:attribute name="scope">
                        <xsl:value-of select="$scope"/>
                    </xsl:attribute>
                </xsl:otherwise>

            </xsl:choose>
            
            <xsl:if test="$outputclass != ''">
                <xsl:attribute name="outputclass">
                    <xsl:value-of select="$outputclass"/>
                </xsl:attribute>
            </xsl:if>

        </cpm:ton>

    </xsl:template>


    <!-- 
        Retrieving TOC/TON numbering sequence name
    -->
    <xsl:template match="cpm:toc | cpm:ton" mode="numseqname">
        <xsl:value-of select="@numseq"/>
    </xsl:template>


    <!-- 
        Detecting a TOC/TON scope section ID
    -->

    <!-- A default template -->
    <xsl:template match="cpm:toc | cpm:ton" mode="cpm.fastcust.scopeid">

        <xsl:choose>

            <!-- Taking an explicit TOC/TON scope section ID by default -->
            <xsl:when test="@scopeid">
                <xsl:value-of select="@scopeid"/>
            </xsl:when>

            <!-- The case when a TOC/TON is local -->
            <xsl:when test="not(@scopeid) and @scope = 'local'">
                <xsl:value-of select="cpm:fastcust.id(ancestor::*[cpm:fastcust.is_section(.)])"/>
            </xsl:when>

            <!-- The case when a TOC/TON is global -->
            <xsl:otherwise>
                <xsl:value-of select="cpm:fastcust.id(ancestor::*[cpm:fastcust.is_docroot(.)])"/>
            </xsl:otherwise>

        </xsl:choose>

    </xsl:template>

    <!-- A default custom template -->
    <xsl:template match="cpm:toc | cpm:ton" mode="scopeid">
        <xsl:apply-templates select="." mode="cpm.fastcust.scopeid"/>
    </xsl:template>

    <!-- A wrapper function -->
    <xsl:function name="cpm:fastcust.scopeid">

        <!-- A TOC/TON element -->
        <xsl:param name="element"/>

        <xsl:apply-templates select="$element" mode="scopeid"/>

    </xsl:function>



    <!-- ========================== -->
    <!--  Assembling TOCs and TONs  -->
    <!-- ========================== -->

    <!-- 
        Assembling an a TOC/TON entry
    -->

    <!-- A default working template -->
    <xsl:template match="*" mode="cpm.fastcust.toctonentry">

        <!-- 
            * represents a section, a table, or any other element 
            that we include into a TOC or a TON.
        -->

        <!-- Assembling TOC entry text -->
        <xsl:value-of select="cpm:fastcust.nav_full_title(.)"/>

        <!-- Assembling a representation for dots or anything else -->
        <fo:leader/>

        <!-- Assembling a page number -->
        <fo:page-number-citation ref-id="{cpm:fastcust.refid(.)}"/>

    </xsl:template>

    <!-- A default custom template -->
    <xsl:template match="*" mode="toctonentry">
        <xsl:apply-templates select="." mode="cpm.fastcust.toctonentry"/>
    </xsl:template>


    <!-- 
        Assembling a TOC/TON row
    -->
    <xsl:template match="*" mode="cpm.fastcust.toctonrow">

        <!-- 
            We assemble TOC and TON rows at the improving stage. 
        -->

        <!-- 
            * represents a section, a table, or any other element 
            that we include into a TOC or a TON. 
        -->

        <!-- The difference of a numlevel and a level of a TOC row -->
        <xsl:param name="baselevel" select="0"/>

        <!-- Assembling a block for a TOC entry -->
        <fo:block outputclass="tocentry" cpm:numlevel="{cpm:fastcust.numlevel(.) - $baselevel}">

            <!-- Assembling an active page link -->
            <fo:basic-link internal-destination="{cpm:fastcust.refid(.)}">

                <!-- Assemblin inner content for a TOC/TON row -->
                <xsl:apply-templates select="." mode="toctonentry"/>

            </fo:basic-link>

        </fo:block>

    </xsl:template>


    <!-- 
        Transforming a TOC placeholer to a TOC 
    -->

    <!-- A service function -->
    <xsl:function name="cpm:fastcust.is_in_toc" as="xs:boolean">

        <!-- An element representing a section -->
        <xsl:param name="element"/>

        <!-- A greatest section level allowed in a TOC-->
        <xsl:param name="maxlevel"/>

        <!-- Converting $maxlevel to a valid numeric value -->
        <xsl:variable name="ml" select="number(cpm:fastcust.numinf($maxlevel))"/>

        <xsl:variable name="tmp" as="xs:boolean"
            select="cpm:fastcust.is_tocmamber($element) and (cpm:fastcust.numlevel($element) &lt;= $ml)"/>

        <xsl:value-of select="boolean($tmp)"/>

    </xsl:function>

    <!-- A working template -->
    <xsl:template match="cpm:toc" mode="cpm.fastcust.improve">

        <!-- 
            We resolve TOCs at the improving stage. 
        -->

        <!-- 
            The parameters declared below are redundant here but they
            are mandatory for each template that has the "improve" mode.
        -->

        <!-- A number of a closest numbered ancestor (mandatory for improve) -->
        <xsl:param name="hinumber"/>

        <!-- A numbering sequence of a closest numbered ancestor (mandatory for improve) -->
        <xsl:param name="hinumseq"/>

        <!-- Detecting a target numbering sequence name -->
        <xsl:variable name="numseqname">
            <xsl:value-of select="cpm:fastcust.numseqname(.)"/>
        </xsl:variable>

        <!-- Detecting an ID of a TOC scope section ID  -->
        <xsl:variable name="scopeid" select="cpm:fastcust.scopeid(.)"/>

        <!-- Detecting a TOC initial level -->
        <xsl:variable name="baselevel"
            select="cpm:fastcust.numlevel(ancestor::*[cpm:fastcust.id(.) = $scopeid])"/>

        <xsl:variable name="maxlevel" select="@maxlevel"/>

        <!-- Assembling a TOC entry for each mamber element -->
        <fo:block role="toc">

            <xsl:copy-of select="@outputclass"/>            

            <!-- Assembling TOC rows -->
            <xsl:apply-templates
                select="ancestor::*[cpm:fastcust.id(.) = $scopeid]//*[cpm:fastcust.is_in_toc(., $maxlevel)]"
                mode="cpm.fastcust.toctonrow">
                <xsl:with-param name="baselevel" select="$baselevel"/>
            </xsl:apply-templates>

        </fo:block>

    </xsl:template>


    <!-- 
        Transforming a TON placeholer to a TON 
    -->
    <xsl:template match="cpm:ton" mode="cpm.fastcust.improve">

        <!-- 
            We resolve TONs at the improving stage. 
        -->

        <!-- 
            The parameters declared below are redundant here but they
            are mandatory for each template that has the "improve" mode.
        -->

        <!-- A number of a closest numbered ancestor (mandatiry for improve) -->
        <xsl:param name="hinumber"/>

        <!-- A numbering sequence of a closest numbered ancestor -->
        <xsl:param name="hinumseq"/>

        <!-- Detecting a target numbering sequence name -->
        <xsl:variable name="numseqname">
            <xsl:value-of select="cpm:fastcust.numseqname(.)"/>
        </xsl:variable>

        <!-- Detecting an ID of a TOC scope section ID  -->
        <xsl:variable name="scopeid">
            <xsl:value-of select="cpm:fastcust.scopeid(.)"/>
        </xsl:variable>

        <!-- Assembling an TON entry for each mamber element -->
        <fo:block role="ton">

            <xsl:copy-of select="@outputclass"/>

            <!-- Assembling TON rows -->
            <xsl:apply-templates
                select="ancestor::*[cpm:fastcust.id(.) = $scopeid]//title[cpm:fastcust.numseqname(.) = $numseqname]"
                mode="cpm.fastcust.toctonrow"/>

        </fo:block>

    </xsl:template>

</xsl:stylesheet>