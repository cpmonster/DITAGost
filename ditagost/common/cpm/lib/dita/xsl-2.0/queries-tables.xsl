<?xml version="1.0" encoding="UTF-8"?>
<!-- * * ** *** ***** ******** ************* ********************* --> 
<!--
    Product:    CopyPaste Monster   
    
    Level:      Library
    
    Part:       DITA
    Module:     queries-tables.xsl
    
    Scope:      DITA
    
    Func:       Retrieving data from source DITA tables                  
-->   
<!-- * * ** *** ***** ******** ************* ********************* -->   
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cpm="http://cpmonster.com/xmlns/cpm" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="cpm xs" version="2.0">

    <!-- 
        Modules
    -->

    <!-- Working with properties, translit -->
    <xsl:import href="../../common/xsl-2.0/props.xsl"/>

    <!-- Wrapper functions -->
    <xsl:import href="funcs.xsl"/>



    <!-- ============================== -->
    <!--  Detecting an element context  -->
    <!-- ============================== -->

    <!-- 
        Detecting elements that are nested into tables
    -->
    <xsl:template match="*" mode="cpm.dita.in_table" as="xs:boolean">
        
        <!-- 
            * represents a DITA element (e.g. ul ro ol) that is probably 
              nested into a table.
        -->
        
        <xsl:choose>
            <xsl:when test="ancestor::*[cpm:dita.eclass(., 'topic/entry')]">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>


    <!-- 
        Detecting a position of a column by its name 
    -->
    <xsl:function name="cpm:dita.colpos">
        
        <!-- A tgroup element -->
        <xsl:param name="tgroup"/>
        
        <!-- A column name -->
        <xsl:param name="colname"/>
        
        <xsl:value-of
            select="$tgroup/colspec[@colname = $colname]/count(preceding-sibling::colspec) + 1"/>
        
    </xsl:function>
    
    
    <!-- 
        Calculating a number of columns a cell spans over
    -->
    
    <!-- A working template -->
    <xsl:template match="*" mode="cpm.dita.colspans">
        
        <!-- 
            * represents a table cell element.
        -->
                        
        <xsl:choose>
            
            <xsl:when test="@morecols">
                <xsl:value-of select="number(@morecols) + 1"/>
            </xsl:when>
            
            <xsl:when test="@namest and @nameend">
                
                <xsl:variable name="pos1">
                    <xsl:value-of select="cpm:dita.colpos(ancestor::tgroup, @namest)"/>
                </xsl:variable>
                
                <xsl:variable name="pos2">
                    <xsl:value-of select="cpm:dita.colpos(ancestor::tgroup, @nameend)"/>
                </xsl:variable>
                
                <xsl:value-of select="$pos2 - $pos1 + 1"/>
                
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:value-of select="1"/>
            </xsl:otherwise>
            
        </xsl:choose>                                                                 
        
    </xsl:template>
    
    <!-- A wrapper function -->
    <xsl:function name="cpm:dita.colspans">
        
        <!-- A cell element -->
        <xsl:param name="cell"/>
        
        <xsl:apply-templates select="$cell" mode="cpm.dita.colspans"/>
        
    </xsl:function>


    <!-- 
        Calculating column positions for cells
    -->
    
    <!-- A working template -->
    <xsl:template match="*" mode="cpm.dita.colpos">

        <xsl:choose>
            
            <xsl:when test="preceding-sibling::*">
                
                <xsl:variable name="pos">
                    <xsl:value-of select="cpm:dita.colpos(preceding-sibling::*[1])"/>
                </xsl:variable>
                
                <xsl:variable name="spans">
                    <xsl:value-of select="cpm:dita.colspans(preceding-sibling::*[1])"/>
                </xsl:variable>
                
                <xsl:value-of select="$pos + $spans"/>
                
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:value-of select="1"/>
            </xsl:otherwise>
            
        </xsl:choose>

    </xsl:template>

    <!-- A wrapper function -->
    <xsl:function name="cpm:dita.colpos">        
        <xsl:param name="cell"/>        
        <xsl:apply-templates select="$cell" mode="cpm.dita.colnum"/>        
    </xsl:function>



    <!-- ============================= -->
    <!--  Extracting data from tables  -->
    <!-- ============================= -->

    <!-- 
        Detecting and retrieving headings row
    -->

    <!-- Detecting a headings row ID moving from an inner table elements -->
    <xsl:template match="tgroup | thead | tbody | tfoot | row | cell" mode="cpm.dita.headings_id">

        <xsl:choose>

            <xsl:when test="ancestor-or-self::tgroup/thead">

                <xsl:variable name="rows">
                    <xsl:value-of select="count(ancestor-or-self::tgroup/thead/row)"/>
                </xsl:variable>

                <xsl:value-of select="generate-id(ancestor-or-self::tgroup/thead/row[$rows])"/>

            </xsl:when>

            <xsl:otherwise>
                <xsl:copy-of select="generate-id(ancestor::tbody/row[1])"/>
            </xsl:otherwise>

        </xsl:choose>

    </xsl:template>

    <!-- Detecting a heading rows ID for a table -->
    <xsl:template match="table" mode="cpm.dita.headings_id">
        <xsl:apply-templates select="tgroup[1]/tbody/row[1]" mode="#current"/>
    </xsl:template>

    <!-- A wrapper function -->
    <xsl:function name="cpm:dita.headings_id">
        <xsl:param name="element"/>
        <xsl:apply-templates select="$element" mode="cpm.dita.headings_id"/>
    </xsl:function>

    <!-- Detecting and retrieving a headings row moving from inner table elements -->
    <xsl:template match="tgroup | thead | tbody | tfoot | row | cell" mode="cpm.dita.headings">

        <xsl:variable name="id">
            <xsl:value-of select="cpm:dita.headings_id(.)"/>
        </xsl:variable>

        <xsl:copy-of select="ancestor-or-self::tgroup//row[generate-id() = $id]"/>

    </xsl:template>

    <!-- Detecting and retrieving a headings row for a table -->
    <xsl:template match="table" mode="cpm.dita.headings">
        <xsl:apply-templates select="tgroup[1]/tbody/row[1]" mode="#current"/>
    </xsl:template>


    <!-- 
        Retrieving a row by its heading
    -->

    <!-- ... more explicit parameters -->
    <xsl:function name="cpm:dita.row_id_by_heading">

        <!-- A row alias list, e.g. "Cats;Dogs;Rabbits" -->
        <xsl:param name="aliases"/>

        <!-- A row of headings (a native one! not a copy stored in a variable!) -->
        <xsl:param name="headings"/>

        <!-- An alias list for a leading column, e.g. "Animal;Item" -->
        <xsl:param name="leading_col_aliases"/>

        <xsl:variable name="index">
            <xsl:value-of select="cpm:dita.index($headings, $leading_col_aliases)"/>
        </xsl:variable>

        <xsl:value-of
            select="generate-id($headings/ancestor-or-self::tgroup/tbody/row[cpm:props.match(entry[$index], $aliases)][1])"/>

    </xsl:function>


    <!-- 
        Retrieving cell content by a row and a column heading
    -->

    <!-- ... more explicit paremeters -->
    <xsl:function name="cpm:dita.cell_by_col">

        <!-- A row element (a copy stored in a variable is allowed) -->
        <xsl:param name="row"/>

        <!-- A column alias list -->
        <xsl:param name="aliases"/>

        <!-- A row containing column headings (a copy stored in a variable is allowed) -->
        <xsl:param name="headings"/>

        <!-- Calculating an index of a cell in a row -->
        <xsl:variable name="index">

            <xsl:choose>

                <!-- 
                     We try to calculate a cell index if an element
                     is provided in the $row.
                -->
                <xsl:when test="cpm:props.is_element($headings)">
                    <xsl:value-of select="cpm:dita.index($headings, $aliases)"/>
                </xsl:when>

                <!-- 
                    We treat the $aliases value as an explicit column index 
                    if no element is provided in the $row. 
                -->
                <xsl:otherwise>
                    <xsl:value-of select="number($aliases)"/>
                </xsl:otherwise>

            </xsl:choose>

        </xsl:variable>

        <!-- Retrieving a value if the index is valid -->
        <xsl:if test="$index != -1">
            <xsl:value-of select="normalize-space($row/entry[$index])"/>
        </xsl:if>

    </xsl:function>

    <!-- ... more automation -->
    <xsl:function name="cpm:dita.cell_by_col">

        <!-- A row element (a native one! not a copy stored in a variable) -->
        <xsl:param name="row"/>

        <!-- A column aliases list -->
        <xsl:param name="aliases"/>

        <!-- Retrieving a column headings row -->
        <xsl:variable name="headings">
            <xsl:apply-templates select="$row" mode="cpm.dita.headings"/>
        </xsl:variable>

        <!-- Calling a function with an explicit column headings row -->
        <xsl:value-of select="cpm:dita.cell_by_col($row, $aliases, $headings/row)"/>

    </xsl:function>


    <!-- 
        Retrieving cell content by row alias and column alias
    -->

    <!-- A service template #1 -->
    <xsl:template match="*" mode="cpm.dita.cell_by_both">
        <xsl:param name="row_id"/>
        <xsl:param name="col_aliases"/>
        <xsl:param name="headings"/>
        <xsl:value-of
            select="
                cpm:dita.cell_by_col(
                ancestor-or-self::tgroup/tbody/row[generate-id() = $row_id],
                $col_aliases, $headings)"
        />
    </xsl:template>

    <!-- A service template #2 -->
    <xsl:template match="table" mode="cpm.dita.cell_by_both">
        <xsl:param name="row_id"/>
        <xsl:param name="col_aliases"/>
        <xsl:param name="headings"/>
        <xsl:value-of
            select="
                cpm:dita.cell_by_col(
                tgroup[1]/tbody/row[generate-id() = $row_id],
                $col_aliases, $headings)"
        />
    </xsl:template>

    <!-- ... more explicit parameters -->
    <xsl:function name="cpm:dita.cell_by_rowcol">

        <!-- A table element or any child of a table -->
        <xsl:param name="element"/>

        <!-- A row alias list -->
        <xsl:param name="row_aliases"/>

        <!-- A column alias list -->
        <xsl:param name="col_aliases"/>

        <!-- A column headings row (a copy is allowed) -->
        <xsl:param name="headings"/>

        <!-- A leading column alias list -->
        <xsl:param name="leading_col_aliases"/>

        <!-- Retrieving an ID of a target row -->
        <xsl:variable name="row_id">
            <xsl:value-of
                select="cpm:dita.row_id_by_heading($row_aliases, $headings, $leading_col_aliases)"/>
        </xsl:variable>

        <!-- Retrieving a value -->
        <xsl:apply-templates select="$element" mode="cpm.dita.cell_by_both">
            <xsl:with-param name="row_id" select="$row_id"/>
            <xsl:with-param name="col_aliases" select="$col_aliases"/>
            <xsl:with-param name="headings" select="$headings"/>
        </xsl:apply-templates>

    </xsl:function>

    <!-- ... more automation -->
    <xsl:function name="cpm:dita.cell_by_rowcol">

        <!-- A table element or any child of a table -->
        <xsl:param name="element"/>

        <!-- A row alias list, e.g. "Cats;Dogs;Rabbits" -->
        <xsl:param name="row_aliases"/>

        <!-- A column alias list, e.g. "Item;Price;Total" -->
        <xsl:param name="col_aliases"/>

        <!-- A leading column alias list, e.g. "Item;Animal" -->
        <xsl:param name="leading_col_aliases"/>

        <!-- Retrieving an ID of a column headings row -->
        <xsl:variable name="heading_row_id">
            <xsl:value-of select="cpm:dita.headings_id($element)"/>
        </xsl:variable>

        <!-- Calling a function that receives an explicit column headings row -->
        <xsl:value-of
            select="
                cpm:dita.cell_by_rowcol(
                $element,
                $row_aliases,
                $col_aliases,
                $element/ancestor-or-self::table//row[generate-id() = $heading_row_id],
                $leading_col_aliases)"/>

    </xsl:function>

</xsl:stylesheet>