<?xml version="1.0" encoding="UTF-8"?>
<!-- * * ** *** ***** ******** ************* ********************* --> 
<!--
    Product:    CopyPaste Monster    
    
    Level:      Library        
    
    Part:       FO
    Module:     funcs.xsl
    
    Scope:      FO
    
    Func:       Wrapper functions for queries                   
-->   
<!-- * * ** *** ***** ******** ************* ********************* --> 
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:cpm="http://cpmonster.com/xmlns/cpm"
    xmlns:fo="http://www.w3.org/1999/XSL/Format" exclude-result-prefixes="cpm xs" version="2.0">

    <!-- 
        Detecting FO elements and attributes
    -->    
    <xsl:function name="cpm:fo.is_fo" as="xs:boolean">        

        <!-- A FO element or a FO attribute -->
        <xsl:param name="node"/>        

        <xsl:apply-templates select="$node" mode="cpm.fo.is_fo"/>
        
    </xsl:function>


    <!-- 
        Detecting FO element output class
    -->
    <xsl:function name="cpm:fo.oclass">
        
        <!-- A FO element -->
        <xsl:param name="element"/>
        
        <!-- 
            An output class of a FO element is @role value. 
        -->
        
        <xsl:apply-templates select="$element" mode="cpm.fo.oclass"/>
        
    </xsl:function>
    
    
    <!-- 
        Extracting a region side from an element
    -->
    <xsl:function name="cpm:fo.regside">        
        <xsl:param name="element"/>       
        <xsl:apply-templates select="$element" mode="cpm.fo.regside"/>        
    </xsl:function>


</xsl:stylesheet>
