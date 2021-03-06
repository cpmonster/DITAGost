<?xml version="1.0" encoding="UTF-8"?>
<!-- * * ** *** ***** ******** ************* ********************* --> 
<!--
    Product:    DITA GOST
    
    Level:      Standalone library
        
    Part:       ESKD  
    Module:     appendix.xsl
    
    Scope:      DITA, DITA OT, Russian, ESKD
    
    Func:       Working with appendices
-->   
<!-- * * ** *** ***** ******** ************* ********************* -->  
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cpm="http://cpmonster.com/xmlns/cpm" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="cpm xs" version="2.0">

    <!-- 
        Modules
    -->

    <!-- Common methods for working with appendices -->
    <xsl:import href="../../common/shared/xsl/appendix.xsl"/>


    <!-- 
        Rebuilding a topic for publishing it as an appendix
    -->

    <!-- Assembling appendix titles -->
    <xsl:template match="*" mode="appendix_titles">

        <p outputclass="Приложение. Номер">           
            <xsl:value-of select="substring-before(cpm:fastcust.full_number(.), '.')"/>            
        </p>
        
        <p outputclass="Приложение. Обязательность">
            <xsl:text>(Обязательное)</xsl:text>
        </p>

        <p outputclass="Приложение. Название">
            <xsl:value-of select="title"/>
        </p>
       

    </xsl:template>

    <!-- Reassembling an appendix -->
    <xsl:template match="*[cpm:sectype(.) = 'appendix']" mode="complete">

        <xsl:copy>

            <xsl:copy-of select="@*"/>

            <xsl:copy-of select="title"/>

            <!--
            <title>
                <xsl:copy-of select="title/@*"/>
                <xsl:value-of select="title"/>                
            </title>
            -->

            <body class="- topic/body ">
                <xsl:copy-of select="*[contains(@class, 'topic/body')]/@*"/>
                <xsl:apply-templates select="." mode="appendix_titles"/>
                <xsl:apply-templates select="*[contains(@class, 'topic/body')]/*" mode="complete"/>
            </body>

            <xsl:apply-templates select="*[cpm:is_topic(.)]" mode="complete"/>

        </xsl:copy>

    </xsl:template>

</xsl:stylesheet>
