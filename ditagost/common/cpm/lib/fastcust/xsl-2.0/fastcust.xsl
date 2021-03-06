<!-- * * ** *** ***** ******** ************* ********************* --> 
<!--
    Product:    CopyPaste Monster
    
    Level:      Library
    
    Part:       FastCust
    Module:     fastcust.xsl
    
    Scope:      Layout, FO
    
    Func:       Provides the support for DITA OT customization or 
                any other set of XSLT stylesheets that transforms
                a source XML document to FO
             
    Usage:      Import to an XSLT stylesheet that is specific for 
                a particular XML application, e.g. dita.xml. 
                A customization developer may overload templates
                that are defined here. 
-->   
<!-- * * ** *** ***** ******** ************* ********************* -->  

<!DOCTYPE stylesheet [

    <!ENTITY % FO SYSTEM "../../fo/dtd/fo.ent">
    
    %FO;

]>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cpm="http://cpmonster.com/xmlns/cpm" xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="cpm xs" version="2.0">

    <!-- 
        Modules
    -->

    <!-- Queries over document content -->
    <xsl:import href="queries.xsl"/>

    <!-- Document parameters -->
    <xsl:import href="docparams.xsl"/>


    <!-- 
        A customization should provide the following features:
        
        - Templates having mode="level" for document structure elements.
        
        - Templates having mode="sequence" for document structure elements
          having level > 0. 
          
        - A template having match="cpm:static-content" and mode="static".             
    -->



    <!-- ======= -->
    <!--  Misc.  -->
    <!-- ======= -->

    <!-- 
        Converting a sequence name to a page-sequence-master/@master-name
    -->

    <!-- A default template -->
    <xsl:template name="cpm.fastcust.get_master_name">

        <!--                        
            OVERLOAD: in a generated layout.xsl.
        -->

        <!--  An alias of a master page sequence -->
        <xsl:param name="master_alias"/>

        <xsl:value-of select="$master_alias"/>

    </xsl:template>

    <!-- A wrapper function -->
    <xsl:function name="cpm:fastcust.get_master_name">

        <xsl:param name="master_alias"/>

        <xsl:call-template name="cpm.fastcust.get_master_name">
            <xsl:with-param name="master_alias" select="$master_alias"/>
        </xsl:call-template>

    </xsl:function>



    <!-- ======================================== -->
    <!--  Assembling static content placeholders  -->
    <!-- ======================================== -->

    <!-- 
        Assembling cpm:sequence/cpm:region-*
    -->
    <xsl:template match="&FO_STATIC_REGIONS;" mode="cpm.fastcust.static">

        <!--            
            OVERLOAD: never!                   
        -->

        <!--  An alias of a master page sequence -->
        <xsl:param name="master_alias"/>

        <!-- first, rest, etc. -->
        <xsl:param name="page_position"/>

        <xsl:element name="cpm:static-content">
            <xsl:copy-of select="cpm:misc.attr('master-alias', $master_alias)"/>
            <xsl:copy-of select="cpm:misc.attr('page-position', $page_position)"/>
            <xsl:copy-of select="cpm:misc.attr('region-name', @region-name)"/>
            <xsl:copy-of select="cpm:misc.attr('page-side', cpm:fo.regside(.))"/>
        </xsl:element>

    </xsl:template>


    <!-- 
        A wrapper
    -->
    <xsl:template match="fo:simple-page-master" mode="cpm.fastcust.static">

        <!--            
            OVERLOAD: never!                   
        -->

        <!--  An alias of a master page sequence -->
        <xsl:param name="master_alias"/>

        <!-- First, last, odd, even, etc. -->
        <xsl:param name="page_position"/>

        <xsl:apply-templates select="&FO_STATIC_REGIONS;" mode="cpm.fastcust.static">
            <xsl:with-param name="master_alias" select="$master_alias"/>
            <xsl:with-param name="page_position" select="$page_position"/>
        </xsl:apply-templates>

    </xsl:template>


    <!-- 
        A wrapper: accessing simple page masters associated with a page sequence master
    -->
    <xsl:template match="&FO_PAGE_MASTER_REFERENCES;" mode="cpm.fastcust.static">

        <!--            
            OVERLOAD: never!                   
        -->

        <xsl:param name="master_alias"/>

        <xsl:variable name="master_name">
            <xsl:value-of select="@master-reference"/>
        </xsl:variable>

        <xsl:apply-templates
            select="ancestor::fo:layout-master-set//fo:simple-page-master[@master-name = $master_name]"
            mode="cpm.fastcust.static">
            <xsl:with-param name="master_alias" select="$master_alias"/>
            <xsl:with-param name="page_position" select="@page-position"/>
        </xsl:apply-templates>

    </xsl:template>


    <!-- 
        A wrapper: diving into a page sequence master
    -->
    <xsl:template match="fo:page-sequence-master" mode="cpm.fastcust.static">

        <!--            
            OVERLOAD: never!                   
        -->

        <xsl:param name="master_alias"/>

        <xsl:apply-templates select="descendant::*[@master-reference]" mode="cpm.fastcust.static">
            <xsl:with-param name="master_alias" select="$master_alias"/>
        </xsl:apply-templates>

    </xsl:template>


    <!-- 
        Assembling cpm:region elements for a section
    -->
    <xsl:template name="cpm.fastcust.static">

        <!--            
            OVERLOAD: never!                   
        -->

        <xsl:param name="master_alias"/>

        <xsl:variable name="master_name">
            <xsl:call-template name="cpm.fastcust.get_master_name">
                <xsl:with-param name="master_alias" select="$master_alias"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="layout_master_set">
            <xsl:apply-templates select="." mode="cpm.fastcust.layout_master_set"/>
        </xsl:variable>

        <xsl:apply-templates
            select="$layout_master_set/*/descendant::fo:page-sequence-master[@master-name = $master_name]"
            mode="cpm.fastcust.static">
            <xsl:with-param name="master_alias" select="$master_alias"/>
        </xsl:apply-templates>

    </xsl:template>



    <!-- ========================================= -->
    <!--  Completing content of a source document  -->
    <!-- ========================================= -->

    <!-- 
        During the completing stage a customization appends
        generated content to a source document. A customization
        usually generates a cover page, TOC and TOC placeholders,
        auxiliary data, etc.
    -->

    <!-- 
        Generating content (the default template)
    -->
    <xsl:template match="*" mode="complete">

        <!-- 
            * represents an element of a source DITA document,
            e.g. stage1.xml or stage1a.xml. 
            
            NOTE: An application should preprocess a source document 
            by DITA OT before sending it to FastCust. All the topics 
            and conrefed or conkeyrefed content should allready be 
            inserted into the source document. Attributes like 
            @class etc. should be appended to elements. 
            
            An application that don't use DITA OT should anyway 
            preprocess a source document 
        -->

        <!-- 
            OVERLOAD: in a particular customization for 
                      particular elements.                                            
        -->

        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="cpm:misc.mattrid(.)"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>

    </xsl:template>

    <xsl:template match="*[@outputclass = 'signatures']" mode="complete"/>

    <xsl:template match="*[cpm:is_topic(.) and not(cpm:fastcust.is_docmamber(.))]" mode="complete"/>


    <!-- 
        Inserting generated content to a source XML
    -->
    <xsl:template match="*" mode="cpm.fastcust.complete">

        <!-- 
            * represents a root element of a source document. 
        -->

        <!-- 
            OVERLOAD: never!
        -->

        <xsl:apply-templates select="." mode="complete"/>

    </xsl:template>



    <!-- =============================== -->
    <!--  Improving a complete document  -->
    <!-- =============================== -->

    <!-- 
        During the improving stage a customization assigns
        levels, page sequence names, and other attributes
        significant for flattering a document to document 
        elements. TOC and TON placeholders should be replaced
        with TOCs and TONs at the improving stage. Cross-
        references pointing on non-terminal topics should
        be corrected. 
    -->

    <!-- 
        Calculating levels, numbers, etc. 
    -->
    <xsl:template match="*" mode="cpm.fastcust.improve">

        <!-- 
            * represents an element of complete document. 
        -->

        <!--            
            OVERLOAD: never!                  
        -->

        <!-- A number of a closest numbered ancestor -->
        <xsl:param name="hinumber" select="''"/>

        <!-- A numbering sequence of a closest numbered ancestor -->
        <xsl:param name="hinumseq"/>

        <!-- Copying an element -->
        <xsl:copy>

            <!-- Copying attributes -->
            <xsl:copy-of select="@*"/>

            <!-- Appending an ID if an element has no one -->
            <xsl:copy-of select="cpm:misc.mattrid(.)"/>

            <!-- Calculating an element level -->
            <xsl:copy-of select="cpm:misc.attr('cpm:level', cpm:level(.))"/>

            <!-- Section type -->
            <xsl:copy-of select="cpm:misc.attr('cpm:sectype', cpm:sectype(.))"/>

            <!-- Calculating an element level for numbering purpose -->
            <xsl:copy-of select="cpm:misc.attr('cpm:numlevel', cpm:numlevel(.))"/>

            <!-- Detecting a numbering sequence name for an element -->
            <xsl:variable name="numseqname" select="cpm:numseqname(.)"/>

            <!-- Calculating a number of an element -->
            <xsl:variable name="number">
                <xsl:if test="$numseqname != ''">
                    <xsl:value-of select="cpm:number(., $hinumber, $hinumseq)"/>
                </xsl:if>
            </xsl:variable>

            <!-- Retrieving a numbering sequence -->
            <xsl:variable name="numseq" select="cpm:numseq(.)"/>

            <!-- Detecting numbering properties for a numbered element -->
            <xsl:if test="$numseqname != ''">
                <xsl:copy-of select="cpm:misc.attr('cpm:numseqname', $numseqname)"/>
                <xsl:copy-of select="cpm:misc.attr('cpm:numtype', cpm:numtype(.))"/>
                <xsl:copy-of select="cpm:misc.attr('cpm:nummode', cpm:nummode(.))"/>
                <xsl:copy-of select="cpm:misc.attr('cpm:start-from', cpm:start_from(.))"/>
                <xsl:copy-of select="cpm:misc.attr('cpm:numbase', cpm:numbase(.))"/>
                <xsl:copy-of select="cpm:misc.attr('cpm:numbaselevel', cpm:numbaselevel(.))"/>
                <xsl:copy-of select="cpm:misc.attr('cpm:caption', cpm:caption(.))"/>
                <xsl:copy-of select="cpm:misc.attr('cpm:navcaption', cpm:navcaption(.))"/>
                <xsl:copy-of select="cpm:misc.attr('cpm:numformat', cpm:numpattern(.))"/>
                <xsl:copy-of select="cpm:misc.attr('cpm:numnavformat', cpm:numnavpattern(.))"/>
                <xsl:copy-of select="cpm:misc.attr('cpm:numsep', cpm:numsep(.))"/>
                <xsl:copy-of select="cpm:misc.attr('cpm:numbasesep', cpm:numbasesep(.))"/>                

                <xsl:variable name="basenumber">
                    <xsl:if test="cpm:nummode(.) = 'decimal' and cpm:numseqname($hinumseq) = cpm:numbase(.)">
                        <xsl:value-of select="cpm:hinumber(.)"/>
                    </xsl:if>
                    <xsl:if test="cpm:nummode(.) = 'flat' and cpm:numbase(.) != ''">
                        <xsl:value-of select="cpm:hinumber(.)"/>
                    </xsl:if>
                </xsl:variable>

                <xsl:copy-of select="cpm:misc.attr('cpm:basenumber', $basenumber)"/>
               
                <xsl:copy-of select="cpm:misc.attr('cpm:number', $number)"/>
                <xsl:copy-of
                    select="cpm:misc.attr('cpm:full-number', cpm:numformat(., $basenumber, $number, cpm:caption(.)))"/>
                <xsl:copy-of
                    select="cpm:misc.attr('cpm:nav-full-number', cpm:numformat(., $basenumber, $number, cpm:navcaption(.)))"/>
                <xsl:copy-of select="cpm:misc.attr('cpm:title', cpm:fastcust.title(.))"/>
            </xsl:if>

            <!-- Should we proceed with a number element or with a higher number -->
            <xsl:variable name="actual_hinumber" select="cpm:misc.defval($number, $hinumber)"/>

            <!-- The same thing about a higher numbering sequence -->
            <xsl:variable name="actual_hinumseq" select="cpm:misc.defseq($numseq, $hinumseq)"/>

            <!-- Improving children elements -->
            <xsl:apply-templates select="node()" mode="#current">
                <xsl:with-param name="hinumber" select="$actual_hinumber"/>
                <xsl:with-param name="hinumseq" select="$actual_hinumseq"/>
            </xsl:apply-templates>

        </xsl:copy>

    </xsl:template>



    <!-- ================================= -->
    <!--  Flattening an improved document  -->
    <!-- ================================= -->

    <!-- 
        Assigning levels and master page sequence aliases to elements 
    -->

    <!-- Assigning a master page sequence alias to an element -->
    <xsl:template match="*" mode="sequence">
        <!-- 
            * represents an element of an improved document. 
        -->
        <!--            
            OVERLOAD: in a particular customization for each element
                      that requires an individual page sequence.
        -->
    </xsl:template>

    <!-- Element metadata is empty by default -->
    <xsl:template match="*" mode="info"/>

    <!-- Performing markup of an improved document -->
    <xsl:template match="*" mode="cpm.fastcust.seqmarkup">

        <!-- 
            * represents an element of an improved document.
        -->

        <!--            
            OVERLOAD: never!                   
        -->

        <!-- 
            FastCust doesn't know anything about a markup language they
            use in a source document as well as about a layout of an 
            output document. A customization that imports FastCust should
            provide templates assigning a level to a source element.
            
            The following levels are allowed.
            =========+=======================================
             Value   | Effect on a source element
            =========+=======================================
             -1      | Totally ignoring
             0       | Passing and processing child elements
             1, 2... | Placing into an output document
            =========+=======================================
            
            Being placed into an output documents a source element obtains:
            
            - A level in an output document structure (@cpm:level), mandatory
            
            - A number, e.g. 1, 1.1, 1.1.2, etc. (@cpm:number), optional
            
            - An alias of a page-sequence-master (@cpm:master-alias), optional
            
            - Custom metadata (@cpm:info), optional            
        -->

        <!-- Requesting a level of an element in an output document -->
        <xsl:variable name="level" select="number(@cpm:level)"/>

        <xsl:choose>

            <!-- There is no place for the element in the output document -->
            <xsl:when test="$level = -1"/>

            <!-- Diving into the element -->
            <xsl:when test="$level = 0">
                <xsl:apply-templates select="*" mode="#current"/>
            </xsl:when>

            <!-- Placing the element into the output document structure -->
            <xsl:otherwise>

                <xsl:copy>

                    <!-- Master alias (optional) -->

                    <xsl:variable name="master_alias">
                        <xsl:apply-templates select="." mode="sequence"/>
                    </xsl:variable>

                    <xsl:copy-of select="cpm:misc.attr('cpm:master-alias', $master_alias)"/>

                    <xsl:copy-of select="@* | node()"/>

                </xsl:copy>

            </xsl:otherwise>

        </xsl:choose>

    </xsl:template>


    <!-- 
        Tuning the markup
    -->

    <!-- Assigning a master page sequence name to an adjoining element -->
    <xsl:function name="cpm:fastcust.tune">

        <xsl:param name="element"/>

        <!--            
            OVERLOAD: strongly not recommended.                   
        -->

        <xsl:choose>

            <xsl:when test="$element/@cpm:master-alias">
                <xsl:value-of select="$element/@cpm:master-alias"/>
            </xsl:when>

            <xsl:otherwise>
                <xsl:value-of select="cpm:fastcust.tune($element/following-sibling::*[1])"/>
            </xsl:otherwise>

        </xsl:choose>

    </xsl:function>

    <!-- Tuning a flat source document representation -->
    <xsl:template match="*" mode="cpm.fastcust.seqtune">

        <!--            
            OVERLOAD: strongly not recommended.                   
        -->

        <xsl:copy>
            <xsl:copy-of select="cpm:misc.mattr(., 'cpm:master-alias', cpm:fastcust.tune(.))"/>
            <xsl:copy-of select="@* | node()"/>
        </xsl:copy>

    </xsl:template>


    <!-- 
        Splitting a tuned document into page sequences
    -->

    <!-- Assembling page sequence inner content -->
    <xsl:template match="*" mode="cpm.fastcust.seqlink">

        <!--            
            OVERLOAD: never!                   
        -->

        <xsl:copy-of select="."/>

        <xsl:variable name="pma">
            <xsl:value-of select="@cpm:master-alias"/>
        </xsl:variable>

        <xsl:if test="following-sibling::*[1]/@cpm:master-alias = $pma">
            <xsl:apply-templates select="following-sibling::*[1]" mode="#current"/>
        </xsl:if>

    </xsl:template>

    <!-- Splitting a flat source document representation into sections -->
    <xsl:template match="cpm:root" mode="cpm.fastcust.seqsplit">

        <!--            
            OVERLOAD: never!                   
        -->

        <xsl:variable name="xtrf" select="@xtrf"/>

        <xsl:for-each select="*[not(@cpm:master-alias = preceding-sibling::*[1]/@cpm:master-alias)]">

            <xsl:variable name="master_name">
                <xsl:value-of select="cpm:fastcust.get_master_name(@cpm:master-alias)"/>
            </xsl:variable>

            <cpm:page-sequence xtrf="{$xtrf}" master-alias="{@cpm:master-alias}"
                master-name="{$master_name}">

                <xsl:call-template name="cpm.fastcust.static">
                    <xsl:with-param name="master_alias" select="@cpm:master-alias"/>
                </xsl:call-template>

                <cpm:flow>
                    <xsl:apply-templates select="." mode="cpm.fastcust.seqlink"/>
                </cpm:flow>

            </cpm:page-sequence>

        </xsl:for-each>

    </xsl:template>


    <!-- 
        Preprocessing a source XML
    -->
    <xsl:template match="*" mode="cpm.fastcust.flatten">

        <!--            
            OVERLOAD: never!                   
        -->

        <xsl:variable name="flat_raw">
            <cpm:root>
                <xsl:copy-of select="@*"/>
                <xsl:apply-templates select="*" mode="cpm.fastcust.seqmarkup"/>
            </cpm:root>
        </xsl:variable>

        <xsl:variable name="flat">
            <cpm:root>
                <xsl:copy-of select="$flat_raw/cpm:root/@*"/>
                <xsl:apply-templates select="$flat_raw/cpm:root/*" mode="cpm.fastcust.seqtune"/>
            </cpm:root>
        </xsl:variable>

        <xsl:apply-templates select="$flat/cpm:root" mode="cpm.fastcust.seqsplit"/>

    </xsl:template>



    <!-- ==================================== -->
    <!--  Transforming a flat document to FO  -->
    <!-- ==================================== -->

    <!-- 
        Calling a customization for assembling static content
    -->
    <xsl:template match="cpm:static-content" mode="cpm.fastcust.static">

        <!--            
            OVERLOAD: never!                   
        -->

        <!-- 
            Assembling static content inner XML. 
            
            A customization should provide a template having
            mode="static".       
        -->
        <xsl:variable name="static_content">
            <xsl:apply-templates select="." mode="static"/>
        </xsl:variable>

        <!--                         
            NOTE: An empty static content element causes a FO 
                  processing error. 
        -->

        <xsl:if test="cpm:misc.is_element($static_content)">
            <fo:static-content flow-name="{@region-name}">
                <xsl:apply-templates select="$static_content/*" mode="foxml"/>
            </fo:static-content>
        </xsl:if>

    </xsl:template>


    <!-- 
        Choosing a name for a FO element
    -->

    <!-- A default template -->
    <xsl:template match="*" mode="cpm.fastcust.foname">

        <!-- 
            * represents an element of a flat document.
        -->

        <!--            
            OVERLOAD: never!                      
        -->

        <xsl:choose>
            <xsl:when test="cpm:fo.is_fo(.)">
                <xsl:value-of select="name()"/>
            </xsl:when>
            <xsl:when test="cpm:is_block_container(.)">
                <xsl:text>fo:block-container</xsl:text>
            </xsl:when>
            <xsl:when test="cpm:is_block(.)">
                <xsl:text>fo:block</xsl:text>
            </xsl:when>
            <xsl:when test="cpm:is_inline(.)">
                <xsl:text>fo:inline</xsl:text>
            </xsl:when>
            <xsl:when test="cpm:is_list_block(.)">
                <xsl:text>fo:list-block</xsl:text>
            </xsl:when>
            <xsl:when test="cpm:is_list_item_body(.)">
                <xsl:text>fo:list-item-body</xsl:text>
            </xsl:when>
            <xsl:when test="cpm:is_list_block(.)">
                <xsl:text>fo:list-block</xsl:text>
            </xsl:when>
            <xsl:when test="cpm:is_list_item_body(.)">
                <xsl:text>fo:list-item-body</xsl:text>
            </xsl:when>
            <xsl:when test="cpm:is_table(.)">
                <xsl:text>fo:table</xsl:text>
            </xsl:when>
            <xsl:when test="cpm:is_table_header(.)">
                <xsl:text>fo:table-header</xsl:text>
            </xsl:when>
            <xsl:when test="cpm:is_table_body(.)">
                <xsl:text>fo:table-body</xsl:text>
            </xsl:when>
            <xsl:when test="cpm:is_table_footer(.)">
                <xsl:text>fo:table-footer</xsl:text>
            </xsl:when>
            <xsl:when test="cpm:is_table_row(.)">
                <xsl:text>fo:table-row</xsl:text>
            </xsl:when>
            <xsl:when test="cpm:is_table_cell(.)">
                <xsl:text>>fo:table-cell</xsl:text>
            </xsl:when>
            <xsl:when test="cpm:is_external_graphic(.)">
                <xsl:text>fo:external-graphic</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>cpm:none</xsl:text>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <!-- A custom template -->
    <xsl:template match="*" mode="foname">

        <!-- 
            * represents an element of a flat document.
        -->

        <!--            
            OVERLOAD: particular elements.
            
            Overloading is possible:
            
            - On a source markup level 
            
            - In a customization
            
            - In a generated layout.xsl
        -->

        <xsl:value-of select="cpm:fastcust.foname(.)"/>

    </xsl:template>


    <!-- 
        Assembling mandatory attributes for a FO element
    -->

    <!-- A default template -->
    <xsl:template match="*" mode="cpm.fastcust.fosysattrs">
        <xsl:attribute name="id" select="cpm:misc.id(.)"/>
        <xsl:attribute name="language" select="cpm:lang(.)"/>
    </xsl:template>

    <!-- A custom template -->
    <xsl:template match="*" mode="fosysattrs">
        <xsl:apply-templates select="." mode="cpm.fastcust.fosysattrs"/>
    </xsl:template>


    <!-- 
        Retrieving style attributes 
    -->

    <!-- A default template -->
    <xsl:template match="*" mode="cpm.fastcust.fostyle">
        <fostyle role="{name()}"/>
    </xsl:template>

    <!-- A custom template -->
    <xsl:template match="*" mode="fostyle">

        <!-- 
            * represents an element of a flat document.
        -->

        <!-- 
            OVERLOAD: in generated layout.xsl. 
        -->

        <xsl:apply-templates select="." mode="cpm.fastcust.fostyle"/>

    </xsl:template>


    <!-- 
        Assembling style attributes
    -->

    <!-- A default template -->
    <xsl:template match="*" mode="cpm.fastcust.fostyleattrs">

        <!-- Retrieving attributes wrapped into an element -->
        <xsl:variable name="fostyle">
            <xsl:apply-templates select="." mode="fostyle"/>
        </xsl:variable>

        <!-- Unpacking attributes from a wrapper element -->
        <xsl:copy-of select="$fostyle//@*"/>

    </xsl:template>

    <!-- A custom template -->
    <xsl:template match="*" mode="fostyleattrs">
        <xsl:apply-templates select="." mode="cpm.fastcust.fostyleattrs"/>
    </xsl:template>


    <!-- 
        Assembling custom and source markup attributes
    -->

    <!-- A common default template -->
    <xsl:template match="*" mode="cpm.fastcust.foattrs"/>

    <!-- A default template for a corner case: copying FO attributs -->
    <xsl:template match="*[cpm:fo.is_fo(.)]" mode="cpm.fastcust.foattrs">
        <xsl:copy-of select="@* except (@*[cpm:cpm.is_cpm(.)], @outputclass, @xtrf)"/>
    </xsl:template>

    <!-- A custom template for source markup elements -->
    <xsl:template match="*" mode="foattrs">
        <xsl:apply-templates select="." mode="cpm.fastcust.foattrs"/>
    </xsl:template>


    <!-- 
        Transforming a placeholder to an actual number
    -->
    <xsl:template match="cpm:number" mode="foxml">
        <xsl:value-of select="cpm:nav_full_number(root(.)//*[@id = current()/@refid])"/>
    </xsl:template>


    <!-- 
        Assembling inner content for a FO element
    -->

    <!-- A default template -->
    <xsl:template match="*" mode="cpm.fastcust.foinner">

        <!-- 
            * represents an element of a flat document.
        -->

        <!--            
            OVERLOAD: not recommended.
        -->

        <!-- 
            Inserting a full number unless an element has a title.
            If the element has a title then a full number comes 
            at the beginning of the title. 
        -->
        <xsl:if test="not(*[cpm:is_title(.)])">
            <xsl:value-of select="cpm:full_number(.)"/>
        </xsl:if>

        <!-- 
            ATTENTION! A template having mode="foinner"
            is responsible for proceeding a recursive
            procedure of parsing a flat doocument.
        -->

        <!-- Transforming child nodes to FO -->
        <xsl:apply-templates select="node()" mode="foxml"/>

    </xsl:template>

    <!-- A custom template -->
    <xsl:template match="*" mode="foinner">

        <!-- 
            * represents an element of a flat document.
        -->

        <!--            
            OVERLOAD: for particular elements.
                        
            Overloading is possible:
            
            - On a source markup level
            
            - In a customization            
        -->

        <xsl:apply-templates select="." mode="cpm.fastcust.foinner"/>

    </xsl:template>


    <!-- 
        Assembling an entire FO element
    -->

    <!-- A default template -->
    <xsl:template match="*" mode="cpm.fastcust.foxml">

        <!-- 
            * represents an element of a flat document.
        -->

        <!--            
            OVERLOAD: not recommended!                   
        -->

        <xsl:variable name="foname" select="cpm:foname(.)"/>

        <xsl:choose>

            <!-- 
                The case when an element of a flat document
                doesn't give a FO element. This is common
                for redundant wrappers, etc.
                
                An empty string can come out from cpm:foname() if 
                a template having @mode="foname" is defined for 
                the context element and does something wrong. Check 
                your customization stylesheets or a generated layout.xsl.

                The 'cpm:none' can come out from cpm:foname() if 
                a default template having @mode="cpm.fastcust.foname" 
                failed to detect a type of element behaviour: block,
                inline, table, etc. A source markup layer is probably 
                not aware of the context element. 
            -->
            <xsl:when test="$foname = ('', 'cpm:none')">
                <xsl:apply-templates select="." mode="foinner"/>
            </xsl:when>

            <!-- 
                The case when an element of a flat document
                gets transform to a FO element. 
            -->
            <xsl:otherwise>

                <xsl:element name="{$foname}">

                    <!-- Attributes crucial for FactCust (@id, @lang, @role) -->
                    <xsl:apply-templates select="." mode="fosysattrs"/>

                    <!-- Attributes a customization assembled explicitly -->
                    <xsl:apply-templates select="." mode="foattrs"/>

                    <!-- Attributes of styles (from generated layout.xsl)-->
                    <xsl:apply-templates select="." mode="fostyleattrs"/>

                    <!-- Inner FO content we put into a FO element -->
                    <xsl:apply-templates select="." mode="foinner"/>

                </xsl:element>

            </xsl:otherwise>

        </xsl:choose>

    </xsl:template>

    <!-- A custom template -->
    <xsl:template match="*" mode="foxml">

        <!-- 
            * represents an element of a flat document.
        -->

        <!--            
            OVERLOAD: yes, it's custom, but not recommended.                   
        -->

        <xsl:apply-templates select="." mode="cpm.fastcust.foxml"/>

    </xsl:template>


    <!-- 
        Assembling a FO page sequence
    -->
    <xsl:template match="cpm:page-sequence" mode="cpm.fastcust.fodraft">

        <!-- 
            OVERLOAD: strongly not recommended.
        -->

        <fo:page-sequence master-reference="{@master-name}">

            <xsl:apply-templates select="cpm:static-content" mode="cpm.fastcust.static"/>

            <fo:flow flow-name="xsl-region-body">

                <!-- 
                    ATTENTION! Here we enter into a recursive
                    proceure of parsing a flat doocument. 
                -->
                <xsl:apply-templates select="cpm:flow/*" mode="foxml"/>

                <!-- 
                    Creating a marker at the end of document. 
                    We need to have this marker for calculating
                    a number of pages.
                -->
                <xsl:if test="position() = last()">
                    <fo:block id="cpm.fastcust.last_page"/>
                </xsl:if>

            </fo:flow>

        </fo:page-sequence>

    </xsl:template>



    <!-- ================================== -->
    <!--  Correcting an output FO document  -->
    <!-- ================================== -->

    <!-- 
        Postprocessing FO
    -->

    <!-- 
        Supressing redundant attributes 
    -->
    <xsl:template match="@role" mode="cpm.fastcust.fofinal"/>
    <xsl:template match="@*[starts-with(name(), 'cpm:')]" mode="cpm.fastcust.fofinal"/>


    <!-- 
        Parsing final FO 
    -->
    <xsl:template match="node() | @*" mode="cpm.fastcust.fofinal">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="cpm.fastcust.fofinal"/>
        </xsl:copy>
    </xsl:template>



    <!-- ============================================ -->
    <!--  Main: transforming a source documnet to FO  -->
    <!-- ============================================ -->

    <!-- 
        Main
    -->
    <xsl:template match="/">

        <!-- 
            A context node here is a root of a source document (e.g. stage1a.xml) 
        -->

        <!-- 
            OVERLOAD: strongly not recommended.
        -->

        <!-- Supplemented content of a source document -->
        <xsl:variable name="complete_xml">
            <xsl:apply-templates select="*" mode="cpm.fastcust.complete"/>
        </xsl:variable>

        <!-- Assigning levels and numbers to document elements -->
        <xsl:variable name="improved_xml">
            <xsl:apply-templates select="$complete_xml/*" mode="cpm.fastcust.improve"/>
        </xsl:variable>

        <!-- Flattening the improved document and splitting it into sections -->
        <xsl:variable name="flat_xml">
            <xsl:apply-templates select="$improved_xml/*" mode="cpm.fastcust.flatten"/>
        </xsl:variable>

        <!-- Transforming flat sections to FO -->
        <xsl:variable name="fodraft_xml">
            <xsl:apply-templates select="$flat_xml/*" mode="cpm.fastcust.fodraft"/>
        </xsl:variable>

        <!-- Resolving issues in the draft FO -->
        <xsl:variable name="fofinal_xml">

            <!--
            <xsl:comment>#####################</xsl:comment>
            <xsl:copy-of select="$improved_xml"/>
            <xsl:comment>#####################</xsl:comment>
            -->

            <xsl:apply-templates select="$fodraft_xml/*" mode="cpm.fastcust.fofinal"/>

        </xsl:variable>

        <!--
        <xsl:comment>#####################</xsl:comment>
        <xsl:copy-of select="$fodraft_xml"/> 
        <xsl:comment>#####################</xsl:comment>
        -->

        <!-- The FO root element -->
        <fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format"
            xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions">

            <!-- Assembling a page master set (is defined in layout.xsl) -->
            <xsl:apply-templates select="." mode="cpm.fastcust.layout_master_set"/>

            <!-- Writing the final FO output  -->
            <xsl:copy-of select="$fofinal_xml"/>

        </fo:root>

    </xsl:template>

</xsl:stylesheet>
