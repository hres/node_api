<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:schold="http://www.ascc.net/xml/schematron"
                xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:gc="http://docs.oasis-open.org/codelist/ns/genericode/1.0/"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                version="2.0"><!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. -->
   <xsl:param name="archiveDirParameter"/>
   <xsl:param name="archiveNameParameter"/>
   <xsl:param name="fileNameParameter"/>
   <xsl:param name="fileDirParameter"/>
   <xsl:variable name="document-uri">
      <xsl:value-of select="document-uri(/)"/>
   </xsl:variable>

   <!--PHASES-->


   <!--PROLOG-->
   <xsl:output xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
               method="xml"
               omit-xml-declaration="no"
               standalone="yes"
               indent="yes"/>

   <!--XSD TYPES FOR XSLT2-->


   <!--KEYS AND FUNCTIONS-->


   <!--DEFAULT RULES-->


   <!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
   <!--This mode can be used to generate an ugly though full XPath for locators-->
   <xsl:template match="*" mode="schematron-select-full-path">
      <xsl:apply-templates select="." mode="schematron-get-full-path"/>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-->
   <!--This mode can be used to generate an ugly though full XPath for locators-->
   <xsl:template match="*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">
            <xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>*:</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>[namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="preceding"
                    select="count(preceding-sibling::*[local-name()=local-name(current())                                   and namespace-uri() = namespace-uri(current())])"/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="1+ $preceding"/>
      <xsl:text>]</xsl:text>
   </xsl:template>
   <xsl:template match="@*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">@<xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>@*[local-name()='</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>' and namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-2-->
   <!--This mode can be used to generate prefixed XPath for humans-->
   <xsl:template match="node() | @*" mode="schematron-get-full-path-2">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="preceding-sibling::*[name(.)=name(current())]">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-3-->
   <!--This mode can be used to generate prefixed XPath for humans 
	(Top-level element has index)-->
   <xsl:template match="node() | @*" mode="schematron-get-full-path-3">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="parent::*">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>

   <!--MODE: GENERATE-ID-FROM-PATH -->
   <xsl:template match="/" mode="generate-id-from-path"/>
   <xsl:template match="text()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/>
   </xsl:template>
   <xsl:template match="comment()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/>
   </xsl:template>
   <xsl:template match="processing-instruction()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.@', name())"/>
   </xsl:template>
   <xsl:template match="*" mode="generate-id-from-path" priority="-0.5">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:text>.</xsl:text>
      <xsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/>
   </xsl:template>

   <!--MODE: GENERATE-ID-2 -->
   <xsl:template match="/" mode="generate-id-2">U</xsl:template>
   <xsl:template match="*" mode="generate-id-2" priority="2">
      <xsl:text>U</xsl:text>
      <xsl:number level="multiple" count="*"/>
   </xsl:template>
   <xsl:template match="node()" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>n</xsl:text>
      <xsl:number count="node()"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="string-length(local-name(.))"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="translate(name(),':','.')"/>
   </xsl:template>
   <!--Strip characters-->
   <xsl:template match="text()" priority="-1"/>

   <!--SCHEMA SETUP-->
   <xsl:template match="/">
      <svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" title="" schemaVersion="">
         <xsl:comment>
            <xsl:value-of select="$archiveDirParameter"/>   
		 <xsl:value-of select="$archiveNameParameter"/>  
		 <xsl:value-of select="$fileNameParameter"/>  
		 <xsl:value-of select="$fileDirParameter"/>
         </xsl:comment>
         <svrl:ns-prefix-in-attribute-values uri="http://docs.oasis-open.org/codelist/ns/genericode/1.0/"
                                             prefix="gc"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/2001/XMLSchema-instance" prefix="xsi"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">pbx: test area</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M69"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">Prolog Information Validation</xsl:attribute>
            <svrl:text>This section will encode all non doctype specific rules related to the Prolog Information</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M70"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">This pattern includes all rules where the element can occur in any part of the content</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M71"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">Document Information Validation</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M72"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">Author Information Validation</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M73"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">Product Data Section Validation</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M74"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">Labeling Section Validation</xsl:attribute>
            <svrl:text>This covers both the Labeling and the Product Data Sections, any aspect that is only applicable to the
        Product aspects have been located in the Product Data section.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M75"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">Doctype Prolog Validation</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M76"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">Doctype Document Infomation Validation</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M77"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">Doctype Author Validation</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M78"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">Doctype Product Data Section Validation</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M79"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">Doctype Labeling Section Validation</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M80"/>
      </svrl:schematron-output>
   </xsl:template>

   <!--SCHEMATRON PATTERNS-->
   <xsl:param name="oid_loc" select="'..\..\oids\'"/>
   <xsl:param name="file-suffix" select="'.xml'"/>
   <xsl:param name="scheduling-symbol-oid" select="'2.16.840.1.113883.2.20.6.2'"/>
   <xsl:param name="dosage-form-oid" select="'2.16.840.1.113883.2.20.6.3'"/>
   <xsl:param name="telecom-use-oid" select="'2.16.840.1.113883.2.20.6.4'"/>
   <xsl:param name="pharmaceutical-standard-oid"
              select="'2.16.840.1.113883.2.20.6.5'"/>
   <xsl:param name="therapeutic-class-oid" select="'2.16.840.1.113883.2.20.6.6'"/>
   <xsl:param name="route-of-administration-oid"
              select="'2.16.840.1.113883.2.20.6.7'"/>
   <xsl:param name="section-id-oid" select="'2.16.840.1.113883.2.20.6.8'"/>
   <xsl:param name="template-id-oid" select="'2.16.840.1.113883.2.20.6.9'"/>
   <xsl:param name="document-id-oid" select="'2.16.840.1.113883.2.20.6.10'"/>
   <xsl:param name="marketing-category-oid" select="'2.16.840.1.113883.2.20.6.11'"/>
   <xsl:param name="equivalence-codes-oid" select="'2.16.840.1.113883.2.20.6.12'"/>
   <xsl:param name="identifier-type-oid" select="'2.16.840.1.113883.2.20.6.13'"/>
   <xsl:param name="ingredient-id-oid" select="'2.16.840.1.113883.2.20.6.14'"/>
   <xsl:param name="units-of-measure-oid" select="'2.16.840.1.113883.2.20.6.15'"/>
   <xsl:param name="form-code-oid" select="'2.16.840.1.113883.2.20.6.16'"/>
   <xsl:param name="country-code-oid" select="'2.16.840.1.113883.2.20.6.17'"/>
   <xsl:param name="contact-person-role" select="'2.16.840.1.113883.2.20.6.18'"/>
   <xsl:param name="telecom-capability-oid" select="'2.16.840.1.113883.2.20.6.19'"/>
   <xsl:param name="information-disclosure-oid"
              select="'2.16.840.1.113883.2.20.6.21'"/>
   <xsl:param name="schedule-oid" select="'2.16.840.1.113883.2.20.6.22'"/>
   <xsl:param name="product-characteristics-oid"
              select="'2.16.840.1.113883.2.20.6.23'"/>
   <xsl:param name="color-oid" select="'2.16.840.1.113883.2.20.6.24'"/>
   <xsl:param name="shape-oid" select="'2.16.840.1.113883.2.20.6.25'"/>
   <xsl:param name="flavor-oid" select="'2.16.840.1.113883.2.20.6.26'"/>
   <xsl:param name="product-classification-oid"
              select="'2.16.840.1.113883.2.20.6.27'"/>
   <xsl:param name="submission-tracking-system-oid"
              select="'2.16.840.1.113883.2.20.6.28'"/>
   <xsl:param name="language-code-oid" select="'2.16.840.1.113883.2.20.6.29'"/>
   <xsl:param name="combination-product-type-oid"
              select="'2.16.840.1.113883.2.20.6.30'"/>
   <xsl:param name="company-id-oid" select="'2.16.840.1.113883.2.20.6.31'"/>
   <xsl:param name="pack-type-oid" select="'2.16.840.1.113883.2.20.6.32'"/>
   <xsl:param name="organization-role-oid" select="'2.16.840.1.113883.2.20.6.33'"/>
   <xsl:param name="product-source-oid" select="'2.16.840.1.113883.2.20.6.34'"/>
   <xsl:param name="derived-source-oid" select="'2.16.840.1.113883.2.20.6.35'"/>
   <xsl:param name="structure-aspects-oid" select="'2.16.840.1.113883.2.20.6.36'"/>
   <xsl:param name="status-oid" select="'2.16.840.1.113883.2.20.6.37'"/>
   <xsl:param name="units-of-presentation-oid" select="'2.16.840.1.113883.2.20.6.38'"/>
   <xsl:param name="ingredient-role-oid" select="'2.16.840.1.113883.2.20.6.39'"/>
   <xsl:param name="notice-type-oid" select="'2.16.840.1.113883.2.20.6.40'"/>
   <xsl:param name="related-documents-oid" select="'2.16.840.1.113883.2.20.6.41'"/>
   <xsl:param name="din-oid" select="'2.16.840.1.113883.2.20.6.42'"/>
   <xsl:param name="submission-control-number-oid"
              select="'2.16.840.1.113883.2.20.6.49'"/>
   <xsl:param name="telecom-type-oid" select="'2.16.840.1.113883.2.20.6.51'"/>
   <xsl:param name="media-type-oid" select="'2.16.840.1.113883.2.20.6.52'"/>
   <xsl:param name="product-type-oid" select="'2.16.840.1.113883.2.20.6.53'"/>
   <xsl:param name="regulatory-activity-id-oid"
              select="'2.16.840.1.113883.2.20.6.54'"/>
   <xsl:param name="mpid-oid" select="'2.16.840.1.113883.2.20.6.55'"/>
   <xsl:param name="pcid-oid" select="'2.16.840.1.113883.2.20.6.56'"/>
   <xsl:param name="display-language"
              select="(document('.\properties.xml'))/report_message/display-language"/>
   <xsl:param name="code" select="'TBD'"/>
   <xsl:param name="oid" select="'TBD'"/>
   <xsl:param name="oid-section-title" select="'TBD'"/>
   <xsl:param name="doc-doctype" select="document/code/@code"/>
   <xsl:param name="doc-template"
              select="document/templateId[./@root=$template-id-oid]/@extension"/>
   <xsl:param name="doc-id" select="document/id/@root"/>
   <xsl:param name="array_position" select="'TBD'"/>
   <xsl:param name="oid-derived_section" select="'TBD'"/>
   <xsl:param name="section_counter" select="0"/>
   <xsl:param name="product-driven-doctypes" select="'1', '2'"/>
   <xsl:param name="product-required" select="$doc-doctype=$product-driven-doctypes"/>
   <xsl:param name="active-ingredient-roles" select="'ACTI','ACTIB','ACTIM','ACTIR'"/>
   <xsl:param name="ref-ingredient-roles" select="'ACTIR'"/>
   <xsl:param name="exception_sections"
              select="'10','20','30','40','530','370-10','580','48780-1','999999'"/>
   <xsl:param name="PM-root-sections" select="'10','20','30','40','48780-1'"/>
   <xsl:param name="strict-PM-templates" select="'6','7','8','9','10'"/>
   <xsl:param name="debug" select="0"/>

   <!--PATTERN pbx: test area-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">pbx: test area</svrl:text>

	  <!--RULE -->
   <xsl:template match="/" priority="1000" mode="M69">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/"/>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M69"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M69"/>
   <xsl:template match="@*|node()" priority="-2" mode="M69">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M69"/>
   </xsl:template>

   <!--PATTERN Prolog Information Validation-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Prolog Information Validation</svrl:text>

	  <!--RULE -->
   <xsl:template match="/" priority="1000" mode="M70">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/"/>
      <xsl:variable name="doc_info" select="processing-instruction('xml')"/>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>********************* Document Processing Instruction Debuging ************************* </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Doc Information: <xsl:text/>
               <xsl:value-of select="$doc_info"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>********************* end debuging info ************************* </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M70"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M70"/>
   <xsl:template match="@*|node()" priority="-2" mode="M70">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M70"/>
   </xsl:template>

   <!--PATTERN  General Validation Aspects This pattern includes all rules where the element can occur in any part of the content-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl"> General Validation Aspects</svrl:text>
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">This pattern includes all rules where the element can occur in any part of the content</svrl:text>
   <xsl:template match="text()" priority="-1" mode="M71"/>
   <xsl:template match="@*|node()" priority="-2" mode="M71">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M71"/>
   </xsl:template>

   <!--PATTERN Document Information Validation-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Document Information Validation</svrl:text>

	  <!--RULE -->
   <xsl:template match="document" priority="1000" mode="M72">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="document"/>
      <xsl:variable name="context" select="1"/>
      <xsl:variable name="valid_templates"
                    select="(document(concat($oid_loc,$template-id-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue"/>
      <xsl:variable name="valid_doctypes"
                    select="(document(concat($oid_loc,$document-id-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue"/>
      <xsl:variable name="valid_languages"
                    select="(document(concat($oid_loc,$language-code-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue"/>
      <xsl:variable name="valid_status"
                    select="(document(concat($oid_loc,$status-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue"/>
      <xsl:variable name="language-code" select="languageCode/@code"/>
      <xsl:variable name="language-display-name"
                    select="(document(concat($oid_loc,$language-code-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row[./Value[@ColumnRef='code']/SimpleValue=$language-code]/Value[@ColumnRef=$display-language]/SimpleValue"/>

		    <!--REPORT -->
      <xsl:if test="count(typeId) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(typeId) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Document Information: The typeId element is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(typeId[@assigningAuthorityName]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(typeId[@assigningAuthorityName]) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Document Information: The typeId@assigningAuthorityName attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(typeId[@assigningAuthorityName = 'Health Products and Food Branch']) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(typeId[@assigningAuthorityName = 'Health Products and Food Branch']) = 1">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Document Information: The value for the typeId@assigningAuthorityName attribute is not 'Health Products and Food Branch'.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="count(id[@root]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(id[@root]) = 0">
            <xsl:attribute name="id">SPL-5-001</xsl:attribute>
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Document Information: The id@root attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(code[@code]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(code[@code]) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Document Information: The code@code attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(code[@codeSystem]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(code[@codeSystem]) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Document Information: The code@codeSystem attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="code[@codeSystem = $document-id-oid]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="code[@codeSystem = $document-id-oid]">
               <xsl:attribute name="id">SPL-2-002</xsl:attribute>
               <xsl:attribute name="flag">SPL-2</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Document Information: The OID for element: <xsl:text/>
                  <xsl:value-of select=" local-name(code)"/>
                  <xsl:text/> should be: <xsl:text/>
                  <xsl:value-of select="$document-id-oid"/>
                  <xsl:text/> however the codeSystem is set to: <xsl:text/>
                  <xsl:value-of select="code/@codeSystem"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="code/@code=$valid_doctypes"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="code/@code=$valid_doctypes">
               <xsl:attribute name="id">SPL-8-002</xsl:attribute>
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Document Information: code: <xsl:text/>
                  <xsl:value-of select="code/@code"/>
                  <xsl:text/> is not contained in OID: <xsl:text/>
                  <xsl:value-of select="$document-id-oid"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="count(templateId) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(templateId) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Document Information: The templateId element is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(templateId[@root]) = count(templateId)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(templateId[@root]) = count(templateId)">
               <xsl:attribute name="flag">SPL-5</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Document Information: The templateId@root attribute is missing.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(templateId[@extension]) = count(templateId)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(templateId[@extension]) = count(templateId)">
               <xsl:attribute name="flag">SPL-5</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Document Information: The templateId@extension attribute is missing.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="templateId[@root = $template-id-oid]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="templateId[@root = $template-id-oid]">
               <xsl:attribute name="id">SPL-2-001</xsl:attribute>
               <xsl:attribute name="flag">SPL-2</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Document Information: There is no templateId where the @root value is <xsl:text/>
                  <xsl:value-of select="$template-id-oid"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="templateId[@root = $template-id-oid]/@extension = $valid_templates"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="templateId[@root = $template-id-oid]/@extension = $valid_templates">
               <xsl:attribute name="id">SPL-8-001</xsl:attribute>
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Document Information: template: <xsl:text/>
                  <xsl:value-of select="templateId[@root = $template-id-oid]/@extension"/>
                  <xsl:text/> is not in OID: <xsl:text/>
                  <xsl:value-of select="$template-id-oid"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="count(templateId[@root = $template-id-oid]) &gt;1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(templateId[@root = $template-id-oid]) &gt;1">
            <xsl:attribute name="flag">SPL-4</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Document Information: There is more than one templateId where the @root value is <xsl:text/>
               <xsl:value-of select="$template-id-oid"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(effectiveTime) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(effectiveTime) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Document Information: The effectiveTime element is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(languageCode) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(languageCode) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Document Information: The languageCode element is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(languageCode[@code]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(languageCode[@code]) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Document Information: The languageCode@code attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="languageCode/@code=$valid_languages"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="languageCode/@code=$valid_languages">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Document Information: code: <xsl:text/>
                  <xsl:value-of select="languageCode/@code"/>
                  <xsl:text/> is not contained in OID: <xsl:text/>
                  <xsl:value-of select="$language-code-oid"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="languageCode[@code = '1'] or languageCode[@code = '2']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="languageCode[@code = '1'] or languageCode[@code = '2']">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Document Information: The value for the languageCode@code attribute is neither ENG or FRA.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="count(languageCode[@codeSystem]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(languageCode[@codeSystem]) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Document Information: The languageCode@codeSystem attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="languageCode[@codeSystem = $language-code-oid]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="languageCode[@codeSystem = $language-code-oid]">
               <xsl:attribute name="flag">SPL-2</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Document Information: The OID for element: <xsl:text/>
                  <xsl:value-of select=" local-name(languageCode)"/>
                  <xsl:text/> should be: <xsl:text/>
                  <xsl:value-of select="$language-code-oid"/>
                  <xsl:text/> however the codeSystem is set to: <xsl:text/>
                  <xsl:value-of select="languageCode/@codeSystem"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="count(setId) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(setId) = 0">
            <xsl:attribute name="id">SPL-3-001</xsl:attribute>
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Document Information: The setId element is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(setId[@root]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(setId[@root]) = 0">
            <xsl:attribute name="id">SPL-5-002</xsl:attribute>
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Document Information: The setId@root attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(versionNumber) = 0 ">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(versionNumber) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Document Information: The versionNumber element is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(versionNumber[@value]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(versionNumber[@value]) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Document Information: The versionNumber@value attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(versionNumber[@description]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(versionNumber[@description]) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Document Information: The versionNumber@description attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="versionNumber/@description = $valid_status"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="versionNumber/@description = $valid_status">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Document Information: Version description: <xsl:text/>
                  <xsl:value-of select="versionNumber/@description"/>
                  <xsl:text/> is not in OID: <xsl:text/>
                  <xsl:value-of select="$status-oid"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="versionNumber/@value &lt; 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="versionNumber/@value &lt; 1">
            <xsl:attribute name="flag">SPL-8</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Document Information: The version number is less than one (1).</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="versionNumber/@value castable as xs:integer"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="versionNumber/@value castable as xs:integer">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Document Information: The version number should be an integer but was '<xsl:text/>
                  <xsl:value-of select="versionNumber/@value"/>
                  <xsl:text/>'.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="count(author) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(author) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Document Information: The author element is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(author) &gt; 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(author) &gt; 1">
            <xsl:attribute name="flag">SPL-4</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Document Information: There is more than 1 author element defined.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>*********************  Document Information Debuging ************************* </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>display_laguage: <xsl:text/>
               <xsl:value-of select="$display-language"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>doctype: <xsl:text/>
               <xsl:value-of select="$doc-doctype"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>template: <xsl:text/>
               <xsl:value-of select="$doc-template"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>id: <xsl:text/>
               <xsl:value-of select="$doc-id"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Stylesheet Info: <xsl:text/>
               <xsl:value-of select="$oid-section-title"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Valid Doctypes: <xsl:text/>
               <xsl:value-of select="$valid_doctypes"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Current DocType: <xsl:text/>
               <xsl:value-of select="code/@code"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Valid Templates: <xsl:text/>
               <xsl:value-of select="$valid_templates"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text> Current Template: <xsl:text/>
               <xsl:value-of select="templateId/@extension"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>********************* end debuging info ************************* </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M72"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M72"/>
   <xsl:template match="@*|node()" priority="-2" mode="M72">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M72"/>
   </xsl:template>

   <!--PATTERN Author Information Validation-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Author Information Validation</svrl:text>

	  <!--RULE -->
   <xsl:template match="author/assignedEntity" priority="1012" mode="M73">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="author/assignedEntity"/>

		    <!--REPORT -->
      <xsl:if test="count(representedOrganization) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(representedOrganization) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: The representedOrganization element is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M73"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="representedOrganization" priority="1011" mode="M73">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="representedOrganization"/>
      <xsl:variable name="company_id" select="id[@root = $company-id-oid]/@extension"/>
      <xsl:variable name="allowed_company_ids"
                    select="(document(concat($oid_loc,$company-id-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue"/>
      <xsl:variable name="valid_company"
                    select="$company_id=$allowed_company_ids or $company_id='999999999'"/>
      <xsl:variable name="company_name"
                    select="(document(concat($oid_loc,$company-id-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row[./Value[@ColumnRef='code']/SimpleValue=$company_id]/Value[@ColumnRef=$display-language]/SimpleValue"/>

		    <!--REPORT -->
      <xsl:if test="count(id[@root]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(id[@root]) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: The id@root attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(id[@root = $company-id-oid]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(id[@root = $company-id-oid]) = 0">
            <xsl:attribute name="flag">SPL-8</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: No id@root equals <xsl:text/>
               <xsl:value-of select="$company-id-oid"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(id[@root = $company-id-oid]) &gt; 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(id[@root = $company-id-oid]) &gt; 1">
            <xsl:attribute name="flag">SPL-8</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: More than one id@root equals <xsl:text/>
               <xsl:value-of select="$company-id-oid"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="$valid_company"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$valid_company">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Author: The company ID: <xsl:text/>
                  <xsl:value-of select="$company_id"/>
                  <xsl:text/> is not in OID: <xsl:text/>
                  <xsl:value-of select="$company-id-oid"/>
                  <xsl:text/> or 999999999</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="count(id[@root = $company-id-oid and @extension]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(id[@root = $company-id-oid and @extension]) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: An id@extension attribute is missing for the company.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(name) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(name) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: The name element is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="string-length(name)&lt;1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="string-length(name)&lt;1">
            <xsl:attribute name="flag">SPL-6</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: The name element is empty.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="name=$company_name"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="name=$company_name">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Author: The company name: <xsl:text/>
                  <xsl:value-of select="name"/>
                  <xsl:text/> is not the same as: <xsl:text/>
                  <xsl:value-of select="$company_name"/>
                  <xsl:text/>, as defined in the extension</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="count(contactParty) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(contactParty) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: The contactParty element is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(contactParty/addr) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(contactParty/addr) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: The contactParty.addr element is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(/document/author/assignedEntity/representedOrganization/assignedEntity/performance/actDefinition/code[./@code='1' and @codeSystem='2.16.840.1.113883.2.20.6.33']) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(/document/author/assignedEntity/representedOrganization/assignedEntity/performance/actDefinition/code[./@code='1' and @codeSystem='2.16.840.1.113883.2.20.6.33']) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: The DIN Owner Role is is missing for the representedOrganization.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(/document/author/assignedEntity/representedOrganization/assignedEntity/performance/actDefinition/code[./@code='1' and @codeSystem='2.16.840.1.113883.2.20.6.33']) &gt; 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(/document/author/assignedEntity/representedOrganization/assignedEntity/performance/actDefinition/code[./@code='1' and @codeSystem='2.16.840.1.113883.2.20.6.33']) &gt; 1">
            <xsl:attribute name="flag">SPL-4</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: There is more than 1 DIN Owner Role defined.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>********************* represented orginization debuging  ************************* </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>company id: <xsl:text/>
               <xsl:value-of select="$company_id"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>company name: <xsl:text/>
               <xsl:value-of select="name"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>CV company name: <xsl:text/>
               <xsl:value-of select="$company_name"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>allowed_company_ids: <xsl:text/>
               <xsl:value-of select="$allowed_company_ids"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>valid company id: <xsl:text/>
               <xsl:value-of select="$valid_company"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>********************* end debuging info ************************* </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M73"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="contactPerson/name" priority="1010" mode="M73">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="contactPerson/name"/>

		    <!--REPORT -->
      <xsl:if test="count(family) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(family) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: The family name element is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(family) &gt; 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(family) &gt; 1">
            <xsl:attribute name="flag">SPL-4</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: The family name element defined more than once.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(given) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(given) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: The given name element is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(given) &gt; 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(given) &gt; 1">
            <xsl:attribute name="flag">SPL-4</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: The given name element defined more than once.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M73"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="contactPerson/templateId[@root='2.16.840.1.113883.2.20.6.18']"
                 priority="1009"
                 mode="M73">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="contactPerson/templateId[@root='2.16.840.1.113883.2.20.6.18']"/>
      <xsl:variable name="valid_roles"
                    select="(document(concat($oid_loc,$contact-person-role,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue"/>

		    <!--REPORT -->
      <xsl:if test="count(@root) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(@root) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: The contactPerson/templateId@root attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(@extension) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(@extension) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: The contactPerson/templateId@extension attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@root = $contact-person-role"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@root = $contact-person-role">
               <xsl:attribute name="flag">SPL-3</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Author: The OID for element: <xsl:text/>
                  <xsl:value-of select=" local-name(@root)"/>
                  <xsl:text/> should be: <xsl:text/>
                  <xsl:value-of select="$contact-person-role"/>
                  <xsl:text/> however the codeSystem is set to: <xsl:text/>
                  <xsl:value-of select="@root"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@extension=$valid_roles"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@extension=$valid_roles">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Author: code: <xsl:text/>
                  <xsl:value-of select="@extension"/>
                  <xsl:text/> is not contained in OID: <xsl:text/>
                  <xsl:value-of select="$contact-person-role"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M73"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="representedOrganization/assignedEntity/assignedOrganization/assignedEntity"
                 priority="1008"
                 mode="M73">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="representedOrganization/assignedEntity/assignedOrganization/assignedEntity"/>

		    <!--REPORT -->
      <xsl:if test="count(assignedOrganization) =0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(assignedOrganization) =0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: The assignedOrganization element is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(assignedOrganization) &gt; 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(assignedOrganization) &gt; 1">
            <xsl:attribute name="flag">SPL-4</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: The assignedOrganization element is defined more than once.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M73"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="performance/actDefinition" priority="1007" mode="M73">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="performance/actDefinition"/>
      <xsl:variable name="valid_roles"
                    select="(document(concat($oid_loc,$organization-role-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue"/>

		    <!--REPORT -->
      <xsl:if test="count(code) =0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(code) =0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: The actDefinition.code element is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(code[@code]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(code[@code]) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: The code@code attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(code[@codeSystem]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(code[@codeSystem]) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: The code@codeSystem attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="code[@codeSystem = $organization-role-oid]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="code[@codeSystem = $organization-role-oid]">
               <xsl:attribute name="flag">SPL-2</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Author: The OID for element: <xsl:text/>
                  <xsl:value-of select=" local-name(code)"/>
                  <xsl:text/> should be: <xsl:text/>
                  <xsl:value-of select="$organization-role-oid"/>
                  <xsl:text/> however the codeSystem is set to: <xsl:text/>
                  <xsl:value-of select="code/@codeSystem"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="code/@code=$valid_roles"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="code/@code=$valid_roles">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Author: code: <xsl:text/>
                  <xsl:value-of select="code/@code"/>
                  <xsl:text/> is not contained in OID: <xsl:text/>
                  <xsl:value-of select="$organization-role-oid"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="(count(product/manufacturedProduct/manufacturedMaterialKind/code[@codeSystem='2.16.840.1.113883.2.20.6.55'])=0) and (count(product/manufacturedProduct/manufacturedMaterialKind/code[@codeSystem='2.16.840.1.113883.2.20.6.56'])=0)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="(count(product/manufacturedProduct/manufacturedMaterialKind/code[@codeSystem='2.16.840.1.113883.2.20.6.55'])=0) and (count(product/manufacturedProduct/manufacturedMaterialKind/code[@codeSystem='2.16.840.1.113883.2.20.6.56'])=0)">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: There are no MPID's or PCID's associated with a performance element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(product/manufacturedProduct/manufacturedMaterialKind)=0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(product/manufacturedProduct/manufacturedMaterialKind)=0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: There is no product root for a specific manufactured product.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M73"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="performance/actDefinition/product/manufacturedProduct"
                 priority="1006"
                 mode="M73">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="performance/actDefinition/product/manufacturedProduct"/>
      <xsl:variable name="valid_product"
                    select="(document(concat($oid_loc,$mpid-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue"/>
      <xsl:variable name="valid_package"
                    select="(document(concat($oid_loc,$pcid-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@classCode='MANU'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@classCode='MANU'">
               <xsl:attribute name="flag">SPL-2</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Author: There is a manufactured product that does not have the @classCode='MANU'.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="count(manufacturedMaterialKind/code/@code) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(manufacturedMaterialKind/code/@code) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: The @code attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(manufacturedMaterialKind/code/@codeSystem) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(manufacturedMaterialKind/code/@codeSystem) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: The @codeSystem attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="(manufacturedMaterialKind/code/@codeSystem = $mpid-oid) or (manufacturedMaterialKind/code/@codeSystem = $pcid-oid)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="(manufacturedMaterialKind/code/@codeSystem = $mpid-oid) or (manufacturedMaterialKind/code/@codeSystem = $pcid-oid)">
               <xsl:attribute name="flag">SPL-2</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Author: The OID for element: <xsl:text/>
                  <xsl:value-of select=" local-name(manufacturedMaterialKind/code/@codeSystem)"/>
                  <xsl:text/> should be: <xsl:text/>
                  <xsl:value-of select="$mpid-oid"/>
                  <xsl:text/> or <xsl:text/>
                  <xsl:value-of select="$pcid-oid"/>
                  <xsl:text/> however the codeSystem is set to: <xsl:text/>
                  <xsl:value-of select="manufacturedMaterialKind/code/@codeSystem"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M73"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="performance/actDefinition/product/manufacturedProduct/manufacturedMaterialKind/templateId"
                 priority="1005"
                 mode="M73">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="performance/actDefinition/product/manufacturedProduct/manufacturedMaterialKind/templateId"/>
      <xsl:variable name="valid_ingredient"
                    select="(document(concat($oid_loc,$ingredient-id-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue"/>

		    <!--REPORT -->
      <xsl:if test="count(@root) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(@root) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: The @root attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(@extension) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(@extension) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: The @extension attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@root = $ingredient-id-oid"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@root = $ingredient-id-oid">
               <xsl:attribute name="flag">SPL-2</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Author: The OID for element: <xsl:text/>
                  <xsl:value-of select=" local-name(@root)"/>
                  <xsl:text/> should be: <xsl:text/>
                  <xsl:value-of select="$ingredient-id-oid"/>
                  <xsl:text/> however the codeSystem is set to: <xsl:text/>
                  <xsl:value-of select="@root"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@extension=$valid_ingredient"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@extension=$valid_ingredient">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Author: code: <xsl:text/>
                  <xsl:value-of select="code/@code"/>
                  <xsl:text/> is not contained in OID: <xsl:text/>
                  <xsl:value-of select="$ingredient-id-oid"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M73"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="country" priority="1004" mode="M73">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="country"/>
      <xsl:variable name="allowed_countries"
                    select="((document(concat($oid_loc,$country-code-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue)"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@codeSystem = $country-code-oid"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@codeSystem = $country-code-oid">
               <xsl:attribute name="flag">SPL-2</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Author: The OID for element: country should be: <xsl:text/>
                  <xsl:value-of select="$country-code-oid"/>
                  <xsl:text/> however the codeSystem is set to: <xsl:text/>
                  <xsl:value-of select="@codeSystem "/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@code=$allowed_countries"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@code=$allowed_countries">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Author: country code: <xsl:text/>
                  <xsl:value-of select="@code"/>
                  <xsl:text/> is not in OID: <xsl:text/>
                  <xsl:value-of select="$country-code-oid"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>********************* country debuging  ************************* </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>valid_country_codes: <xsl:text/>
               <xsl:value-of select="((document(concat($oid_loc,$country-code-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue)"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>country code: <xsl:text/>
               <xsl:value-of select="@code"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>********************* end debuging info ************************* </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M73"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="telecom[@use]" priority="1003" mode="M73">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="telecom[@use]"/>
      <xsl:variable name="allowed_uses"
                    select="((document(concat($oid_loc,$telecom-use-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue)"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@use=$allowed_uses"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@use=$allowed_uses">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The use: <xsl:text/>
                  <xsl:value-of select="@use"/>
                  <xsl:text/> is not in OID: <xsl:text/>
                  <xsl:value-of select="$telecom-use-oid"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M73"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="telecom[@capabilities]" priority="1002" mode="M73">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="telecom[@capabilities]"/>
      <xsl:variable name="allowed_capabilities"
                    select="((document(concat($oid_loc,$telecom-capability-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue)"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@capabilities=$allowed_capabilities"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@capabilities=$allowed_capabilities">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The capability: <xsl:text/>
                  <xsl:value-of select="@capabilities"/>
                  <xsl:text/> is not in OID: <xsl:text/>
                  <xsl:value-of select="$telecom-capability-oid"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M73"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="contactParty/addr" priority="1001" mode="M73">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="contactParty/addr"/>
      <xsl:variable name="allowed_countries"
                    select="((document(concat($oid_loc,$country-code-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue)"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(*) = 5"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(*) = 5">
               <xsl:attribute name="flag">SPL-9</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Author: Part of the address in the representedOrganization is missing.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="count(streetAddressLine) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(streetAddressLine) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: The streetAddressLine element is missing in the representedOrganization.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="string-length(streetAddressLine)&lt;1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="string-length(streetAddressLine)&lt;1">
            <xsl:attribute name="flag">SPL-6</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: The streetAddressLine element is empty in the representedOrganization.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(city) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(city) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: The city element is missing in the representedOrganization.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="string-length(city)&lt;1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="string-length(city)&lt;1">
            <xsl:attribute name="flag">SPL-6</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: The city element is empty in the author (representedOrganization) section.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(state) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(state) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: The state element is missing in the representedOrganization.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="string-length(state)&lt;1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="string-length(state)&lt;1">
            <xsl:attribute name="flag">SPL-6</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: The state element is empty in the author section.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(postalCode) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(postalCode) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: The postalCode element is missing in the representedOrganization.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="string-length(postalCode)&lt;1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="string-length(postalCode)&lt;1">
            <xsl:attribute name="flag">SPL-6</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: The postalCode element is empty in the author (representedOrganization) section.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(country) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(country) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: The country element is missing in the representedOrganization.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>********************* represented orginization country debuging  ************************* </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>valid_country_codes: <xsl:text/>
               <xsl:value-of select="((document(concat($oid_loc,$country-code-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue)"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>country code: <xsl:text/>
               <xsl:value-of select="country/@code"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>country code length: <xsl:text/>
               <xsl:value-of select="string-length(country/@code)"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>********************* end debuging info ************************* </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M73"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="representedOrganization/assignedEntity/assignedOrganization/assignedEntity/assignedOrganization"
                 priority="1000"
                 mode="M73">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="representedOrganization/assignedEntity/assignedOrganization/assignedEntity/assignedOrganization"/>
      <xsl:variable name="company_id" select="id[@root = $company-id-oid]/@extension"/>
      <xsl:variable name="allowed_company_ids"
                    select="(document(concat($oid_loc,$company-id-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue"/>
      <xsl:variable name="valid_company"
                    select="$company_id=$allowed_company_ids or $company_id='999999999'"/>
      <xsl:variable name="company_name"
                    select="(document(concat($oid_loc,$company-id-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row[./Value[@ColumnRef='code']/SimpleValue=$company_id]/Value[@ColumnRef=$display-language]/SimpleValue"/>

		    <!--REPORT -->
      <xsl:if test="count(id[@root]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(id[@root]) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: The id@root attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(id[@root = $company-id-oid]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(id[@root = $company-id-oid]) = 0">
            <xsl:attribute name="flag">SPL-8</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: No id@root equals <xsl:text/>
               <xsl:value-of select="$company-id-oid"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(id[@root = $company-id-oid]) &gt; 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(id[@root = $company-id-oid]) &gt; 1">
            <xsl:attribute name="flag">SPL-8</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: More than one id@root equals <xsl:text/>
               <xsl:value-of select="$company-id-oid"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="$valid_company"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$valid_company">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Author: The company ID: <xsl:text/>
                  <xsl:value-of select="$company_id"/>
                  <xsl:text/> is not in OID: <xsl:text/>
                  <xsl:value-of select="$company-id-oid"/>
                  <xsl:text/> or 999999999</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="count(id[@root = $company-id-oid and @extension]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(id[@root = $company-id-oid and @extension]) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: An id@extension attribute is missing for the company.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(name) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(name) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: The name element is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="string-length(name)&lt;1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="string-length(name)&lt;1">
            <xsl:attribute name="flag">SPL-6</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: The name element is empty.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="name=$company_name"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="name=$company_name">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Author: The company name: <xsl:text/>
                  <xsl:value-of select="name"/>
                  <xsl:text/> is not the same as: <xsl:text/>
                  <xsl:value-of select="$company_name"/>
                  <xsl:text/>, as defined in the extension</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>********************* assigned orginization debuging  ************************* </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>company id: <xsl:text/>
               <xsl:value-of select="$company_id"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>company name: <xsl:text/>
               <xsl:value-of select="name"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>CV company name: <xsl:text/>
               <xsl:value-of select="$company_name"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>allowed_company_ids: <xsl:text/>
               <xsl:value-of select="$allowed_company_ids"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>valid company id: <xsl:text/>
               <xsl:value-of select="$valid_company"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>********************* end debuging info ************************* </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M73"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M73"/>
   <xsl:template match="@*|node()" priority="-2" mode="M73">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M73"/>
   </xsl:template>

   <!--PATTERN Product Data Section Validation-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Product Data Section Validation</svrl:text>

	  <!--RULE -->
   <xsl:template match="component/structuredBody/component/section"
                 priority="1030"
                 mode="M74">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="component/structuredBody/component/section"/>

		    <!--REPORT -->
      <xsl:if test="code[@code = '48780-1'] and string-length(title)&gt;0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="code[@code = '48780-1'] and string-length(title)&gt;0">
            <xsl:attribute name="flag">SPL-11</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The title element has content.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="code[@code = '48780-1'] and string-length(text)&gt;0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="code[@code = '48780-1'] and string-length(text)&gt;0">
            <xsl:attribute name="flag">SPL-11</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The text element has content.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="code[@code = '48780-1'] and count(subject) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="code[@code = '48780-1'] and count(subject) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The subject element is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="code[@code = '48780-1'] and count(subject/manufacturedProduct/subjectOf) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="code[@code = '48780-1'] and count(subject/manufacturedProduct/subjectOf) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The subjectOf element is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>********************* product data section debuging  ************************* </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>product id count:  <xsl:text/>
               <xsl:value-of select="count(code[@code = '48780-1'])"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>********************* end debuging info ************************* </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M74"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="section/subject/manufacturedProduct/subjectOf/approval"
                 priority="1029"
                 mode="M74">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="section/subject/manufacturedProduct/subjectOf/approval"/>
      <xsl:variable name="allowed-activity-codes"
                    select="(document(concat($oid_loc,$regulatory-activity-id-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue"/>
      <xsl:variable name="allowed-marketing-codes"
                    select="(document(concat($oid_loc,$marketing-category-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue"/>
      <xsl:variable name="allowed-territory-codes"
                    select="(document(concat($oid_loc,$country-code-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue"/>

		    <!--REPORT -->
      <xsl:if test="count(id) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(id) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The id element is missing for an approval element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(id[@root]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(id[@root]) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The id@root attribute is missing for an approval element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(id[@extension]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(id[@extension]) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The id@extension attribute is missing for an approval element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="id/@root=$regulatory-activity-id-oid"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="id/@root=$regulatory-activity-id-oid">
               <xsl:attribute name="flag">SPL-2</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The OID for an approval.id element should be: <xsl:text/>
                  <xsl:value-of select="$regulatory-activity-id-oid"/>
                  <xsl:text/> however the codeSystem is set to: <xsl:text/>
                  <xsl:value-of select="id/@root"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="id/@extension=$allowed-activity-codes"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="id/@extension=$allowed-activity-codes">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: Code: <xsl:text/>
                  <xsl:value-of select="id/@extension"/>
                  <xsl:text/> is not in OID: <xsl:text/>
                  <xsl:value-of select="$regulatory-activity-id-oid"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="count(code) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(code) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The code element is missing for an approval element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(code[@code]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(code[@code]) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The approval.code@code attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(code[@codeSystem]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(code[@codeSystem]) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The approval.code@codeSystem attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="code/@codeSystem=$marketing-category-oid"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="code/@codeSystem=$marketing-category-oid">
               <xsl:attribute name="flag">SPL-2</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The OID for approval.code@codeSystem should be: <xsl:text/>
                  <xsl:value-of select="$marketing-category-oid"/>
                  <xsl:text/> however the codeSystem is set to: <xsl:text/>
                  <xsl:value-of select="code/@codeSystem"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="code/@code=$allowed-marketing-codes"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="code/@code=$allowed-marketing-codes">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: Code: <xsl:text/>
                  <xsl:value-of select="code/@code"/>
                  <xsl:text/> is not in OID: <xsl:text/>
                  <xsl:value-of select="$marketing-category-oid"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="count(author) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(author) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The author element is missing for an approval element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(author) &gt; 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(author) &gt; 1">
            <xsl:attribute name="flag">SPL-4</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The author element has been defined more than once for an approval element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(author/territorialAuthority/territory) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(author/territorialAuthority/territory) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The territory element is missing for an approval element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(author/territorialAuthority/territory/code) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(author/territorialAuthority/territory/code) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The territory.code element is missing for an approval element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(author/territorialAuthority/territory/code[@code]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(author/territorialAuthority/territory/code[@code]) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The territory.code@code attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(author/territorialAuthority/territory/code[@codeSystem]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(author/territorialAuthority/territory/code[@codeSystem]) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The territory.code@codeSystem attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="author/territorialAuthority/territory/code/@codeSystem=$country-code-oid"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="author/territorialAuthority/territory/code/@codeSystem=$country-code-oid">
               <xsl:attribute name="flag">SPL-2</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The OID for territory.code@codeSystem should be: <xsl:text/>
                  <xsl:value-of select="$country-code-oid"/>
                  <xsl:text/> however the codeSystem is set to: <xsl:text/>
                  <xsl:value-of select="author/territorialAuthority/territory/code/@codeSystem"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="author/territorialAuthority/territory/code/@code=$allowed-territory-codes"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="author/territorialAuthority/territory/code/@code=$allowed-territory-codes">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: Code: <xsl:text/>
                  <xsl:value-of select="author/territorialAuthority/territory/code/@code"/>
                  <xsl:text/> is not in OID: <xsl:text/>
                  <xsl:value-of select="$country-code-oid"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="count(effectiveTime) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(effectiveTime) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The effectiveTime element is missing for an approval element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M74"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="manufacturedProduct/manufacturedProduct"
                 priority="1028"
                 mode="M74">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="manufacturedProduct/manufacturedProduct"/>
      <xsl:variable name="current-section" select="code/@code"/>
      <xsl:variable name="form-code" select="formCode/@code"/>
      <xsl:variable name="form-allowed-codes"
                    select="(document(concat($oid_loc,$dosage-form-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue"/>
      <xsl:variable name="form-code-system" select="$dosage-form-oid"/>
      <xsl:variable name="product-code" select="code/@code"/>
      <xsl:variable name="product-allowed-codes"
                    select="(document(concat($oid_loc,$mpid-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue"/>
      <xsl:variable name="product-code-system" select="$mpid-oid"/>
      <xsl:variable name="generic-name" select="asEntityWithGeneric/genericMedicine/name"/>

		    <!--REPORT -->
      <xsl:if test="count(code) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(code) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The code element is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(code[@code]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(code[@code]) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The code@code attribute is missing in section: <xsl:text/>
               <xsl:value-of select="$current-section"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(code[@codeSystem]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(code[@codeSystem]) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The code@codeSystem attribute is missing in section: <xsl:text/>
               <xsl:value-of select="$current-section"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="code[@codeSystem=$mpid-oid]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="code[@codeSystem=$mpid-oid]">
               <xsl:attribute name="flag">SPL-2</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The OID for element: <xsl:text/>
                  <xsl:value-of select=" local-name(code)"/>
                  <xsl:text/> should be: <xsl:text/>
                  <xsl:value-of select="$mpid-oid"/>
                  <xsl:text/> however the codeSystem is set to: <xsl:text/>
                  <xsl:value-of select="code/@codeSystem"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="count(name) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(name) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The name element is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(name) &gt; 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(name) &gt; 1">
            <xsl:attribute name="flag">SPL-4</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: There is more than 1 name element defined.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="string-length(name)&lt;1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="string-length(name)&lt;1">
            <xsl:attribute name="flag">SPL-6</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The name element is empty.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(formCode ) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(formCode ) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The formCode element is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(formCode[@code]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(formCode[@code]) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The formCode@code attribute is missing in section: <xsl:text/>
               <xsl:value-of select="$current-section"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(formCode[@codeSystem]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(formCode[@codeSystem]) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The formCode@codeSystem attribute is missing in section: <xsl:text/>
               <xsl:value-of select="$current-section"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="formCode[@codeSystem=$dosage-form-oid]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="formCode[@codeSystem=$dosage-form-oid]">
               <xsl:attribute name="flag">SPL-2</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The OID for element: <xsl:text/>
                  <xsl:value-of select=" local-name(formCode)"/>
                  <xsl:text/> should be: <xsl:text/>
                  <xsl:value-of select="$dosage-form-oid"/>
                  <xsl:text/> however the codeSystem is set to: <xsl:text/>
                  <xsl:value-of select="formCode/@codeSystem"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="$form-code=$form-allowed-codes"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="$form-code=$form-allowed-codes">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: <xsl:text/>
                  <xsl:value-of select="$code"/>
                  <xsl:text/> is not in OID: <xsl:text/>
                  <xsl:value-of select="$dosage-form-oid"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="count(asEntityWithGeneric) = 0 ">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(asEntityWithGeneric) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The asEntityWithGeneric element is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(asEntityWithGeneric/genericMedicine) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(asEntityWithGeneric/genericMedicine) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The asEntityWithGeneric.genericMedicine element is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(asEntityWithGeneric/genericMedicine) &gt; 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(asEntityWithGeneric/genericMedicine) &gt; 1">
            <xsl:attribute name="flag">SPL-4</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: There is more than 1 asEntityWithGeneric.genericMedicine element defined.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(asEntityWithGeneric/genericMedicine/name) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(asEntityWithGeneric/genericMedicine/name) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The asEntityWithGeneric.genericMedicine.name element is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="string-length(asEntityWithGeneric/genericMedicine/name) &lt;1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="string-length(asEntityWithGeneric/genericMedicine/name) &lt;1">
            <xsl:attribute name="flag">SPL-6</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The asEntityWithGeneric.genericMedicine.name element is empty.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="string-length(asEntityWithGeneric/genericMedicine/name) &gt;512">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="string-length(asEntityWithGeneric/genericMedicine/name) &gt;512">
            <xsl:attribute name="flag">SPL-12</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The asEntityWithGeneric.genericMedicine.name element is longer than 512 characters.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(ingredient) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(ingredient) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The ingredient element is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(asContent) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(asContent) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The asContent element is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(asEquivalentEntity) &gt; 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(asEquivalentEntity) &gt; 1">
            <xsl:attribute name="flag">SPL-4</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: There is more than 1 asEquivalentEntity element defined.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>********************* product data debuging  ************************* </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>generic-name: <xsl:text/>
               <xsl:value-of select="$generic-name"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>code-code: <xsl:text/>
               <xsl:value-of select="$product-code"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>form-code: <xsl:text/>
               <xsl:value-of select="$form-code"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>form allowed codes: <xsl:text/>
               <xsl:value-of select="$form-allowed-codes"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>e allowed codes: <xsl:text/>
               <xsl:value-of select="$product-allowed-codes"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>********************* end debuging info ************************* </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M74"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="manufacturedProduct/manufacturedProduct/ingredient"
                 priority="1027"
                 mode="M74">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="manufacturedProduct/manufacturedProduct/ingredient"/>
      <xsl:variable name="code" select="ingredientSubstance/code/@code"/>
      <xsl:variable name="code-system" select="ingredientSubstance/code/@codeSystem"/>
      <xsl:variable name="role-allowed-codes"
                    select="((document(concat($oid_loc,$ingredient-role-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue)"/>
      <xsl:variable name="ingredient-allowed-codes"
                    select="((document(concat($oid_loc,$ingredient-id-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue)"/>
      <xsl:variable name="ingredient-name"
                    select="((document(concat($oid_loc,$ingredient-id-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row[./Value[@ColumnRef='code']/SimpleValue=$code]/Value[@ColumnRef=$display-language]/SimpleValue)"/>
      <xsl:variable name="classCode" select="@classCode"/>
      <xsl:variable name="valid_units"
                    select="(document(concat($oid_loc,$units-of-measure-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue"/>
      <xsl:variable name="numerator_units" select="quantity/numerator/@unit"/>
      <xsl:variable name="denominator_units" select="quantity/denominator/@unit"/>

		    <!--REPORT -->
      <xsl:if test="count(./@classCode) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(./@classCode) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The ingredient@classCode attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="./@classCode=$role-allowed-codes"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="./@classCode=$role-allowed-codes">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: Code: <xsl:text/>
                  <xsl:value-of select="./@classCode"/>
                  <xsl:text/> is not in OID: <xsl:text/>
                  <xsl:value-of select="$ingredient-role-oid"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="count(ingredientSubstance) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(ingredientSubstance) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The ingredientSubstance element is missing for the ingredient with the ingredient role of: <xsl:text/>
               <xsl:value-of select="./@classCode"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(ingredientSubstance/code) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(ingredientSubstance/code) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The ingredientSubstance.code element is missing for the ingredient with the ingredient role of: <xsl:text/>
               <xsl:value-of select="./@classCode"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(ingredientSubstance/code[@code]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(ingredientSubstance/code[@code]) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The ingredientSubstance.code@code attribute is missing for the ingredient with the ingredient role of: <xsl:text/>
               <xsl:value-of select="./@classCode"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(ingredientSubstance/code[@codeSystem]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(ingredientSubstance/code[@codeSystem]) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The ingredientSubstance.code@codeSystem attribute is missing for the ingredient with the ingredient role of: <xsl:text/>
               <xsl:value-of select="./@classCode"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="$code-system=$ingredient-id-oid"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="$code-system=$ingredient-id-oid">
               <xsl:attribute name="flag">SPL-2</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The OID for element: <xsl:text/>
                  <xsl:value-of select=" local-name(code)"/>
                  <xsl:text/> should be: <xsl:text/>
                  <xsl:value-of select="$ingredient-id-oid"/>
                  <xsl:text/> however the codeSystem is set to: <xsl:text/>
                  <xsl:value-of select="ingredientSubstance/code/@codeSystem"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="ingredientSubstance/code/@code=$ingredient-allowed-codes"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="ingredientSubstance/code/@code=$ingredient-allowed-codes">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: Code: <xsl:text/>
                  <xsl:value-of select="$code"/>
                  <xsl:text/> is not in OID: <xsl:text/>
                  <xsl:value-of select="$ingredient-id-oid"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="count(ingredientSubstance/name) &gt; 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(ingredientSubstance/name) &gt; 1">
            <xsl:attribute name="flag">SPL-4</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: There is more than 1 ingredientSubstance.name element defined for the ingredient with the ingredient role of: <xsl:text/>
               <xsl:value-of select="./@classCode"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="ingredientSubstance/name=$ingredient-name"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="ingredientSubstance/name=$ingredient-name">
               <xsl:attribute name="flag">SPL-7</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The document contains: <xsl:text/>
                  <xsl:value-of select="ingredientSubstance/name"/>
                  <xsl:text/> while code: <xsl:text/>
                  <xsl:value-of select="$code"/>
                  <xsl:text/> for OID: <xsl:text/>
                  <xsl:value-of select="$ingredient-id-oid"/>
                  <xsl:text/> contains: <xsl:text/>
                  <xsl:value-of select="$ingredient-name"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="$numerator_units and not($numerator_units=$valid_units)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="$numerator_units and not($numerator_units=$valid_units)">
            <xsl:attribute name="flag">SPL-8</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The numerator unit <xsl:text/>
               <xsl:value-of select="$numerator_units"/>
               <xsl:text/> is not in for OID: <xsl:text/>
               <xsl:value-of select="$units-of-measure-oid"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$denominator_units and not($denominator_units=$valid_units)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="$denominator_units and not($denominator_units=$valid_units)">
            <xsl:attribute name="flag">SPL-8</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The numerator unit <xsl:text/>
               <xsl:value-of select="$denominator_units"/>
               <xsl:text/> is not in for OID: <xsl:text/>
               <xsl:value-of select="$units-of-measure-oid"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$classCode=$active-ingredient-roles and not(quantity/numerator/@value)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="$classCode=$active-ingredient-roles and not(quantity/numerator/@value)">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: An active ingredient is missing the numerator value.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$classCode=$active-ingredient-roles and not(quantity/denominator/@value)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="$classCode=$active-ingredient-roles and not(quantity/denominator/@value)">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: An active ingredient is missing the denominator value.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$classCode=$active-ingredient-roles and quantity/numerator/@value &lt; 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="$classCode=$active-ingredient-roles and quantity/numerator/@value &lt; 1">
            <xsl:attribute name="flag">SPL-8</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: An active ingredient has a numerator value less than 1.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$classCode=$active-ingredient-roles and quantity/denominator/@value &lt; 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="$classCode=$active-ingredient-roles and quantity/denominator/@value &lt; 1">
            <xsl:attribute name="flag">SPL-8</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: An active ingredient has a denominator value less than 1.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$classCode=$active-ingredient-roles and empty(ingredientSubstance/activeMoiety/activeMoiety)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="$classCode=$active-ingredient-roles and empty(ingredientSubstance/activeMoiety/activeMoiety)">
            <xsl:attribute name="id">SPL-3-002</xsl:attribute>
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: An activeMoiety element is required for <xsl:text/>
               <xsl:value-of select="./@classCode"/>
               <xsl:text/> ingredients.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="not($classCode=$active-ingredient-roles) and not(empty(ingredientSubstance/activeMoiety/activeMoiety))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="not($classCode=$active-ingredient-roles) and not(empty(ingredientSubstance/activeMoiety/activeMoiety))">
            <xsl:attribute name="id">SPL-11-001</xsl:attribute>
            <xsl:attribute name="flag">SPL-11</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: An activeMoiety element is not permited for <xsl:text/>
               <xsl:value-of select="./@classCode"/>
               <xsl:text/> ingredients.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$classCode=$ref-ingredient-roles and not(ingredientSubstance/asEquivalentSubstance)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="$classCode=$ref-ingredient-roles and not(ingredientSubstance/asEquivalentSubstance)">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: An active ingredient reference role is missing the definingsubstance.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="not($classCode=$ref-ingredient-roles) and ingredientSubstance/asEquivalentSubstance">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="not($classCode=$ref-ingredient-roles) and ingredientSubstance/asEquivalentSubstance">
            <xsl:attribute name="flag">SPL-11</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: A definingsubstance has been include for a non reference ingredient.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>********************* ingredient debuging info ************************* </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>class code: <xsl:text/>
               <xsl:value-of select="./@classCode"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>allowed role codes: <xsl:text/>
               <xsl:value-of select="role-allowed-codes"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>ingredient codeSystem: <xsl:text/>
               <xsl:value-of select="ingredientSubstance/code/@codeSystem"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>ingredient code: <xsl:text/>
               <xsl:value-of select="$code"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>allowed ingredient codes: <xsl:text/>
               <xsl:value-of select="$ingredient-allowed-codes"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>ingredient name: <xsl:text/>
               <xsl:value-of select="ingredientSubstance/name"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>display language: <xsl:text/>
               <xsl:value-of select="$display-language"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>classCode: <xsl:text/>
               <xsl:value-of select="$classCode"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>valid units: <xsl:text/>
               <xsl:value-of select="$valid_units"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>unit1: <xsl:text/>
               <xsl:value-of select="$denominator_units"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>unit2: <xsl:text/>
               <xsl:value-of select="$numerator_units"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>********************* end debuging info ************************* </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M74"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="activeMoiety/activeMoiety" priority="1026" mode="M74">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="activeMoiety/activeMoiety"/>
      <xsl:variable name="code" select="code/@code"/>
      <xsl:variable name="ingredient-allowed-codes"
                    select="((document(concat($oid_loc,$ingredient-id-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue)"/>
      <xsl:variable name="ingredient-name"
                    select="((document(concat($oid_loc,$ingredient-id-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row[./Value[@ColumnRef='code']/SimpleValue=$code]/Value[@ColumnRef=$display-language]/SimpleValue)"/>

		    <!--REPORT -->
      <xsl:if test="count(code) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(code) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The activeMoiety.code element is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(code[@code]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(code[@code]) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The activeMoiety.code@code attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(code[@codeSystem]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(code[@codeSystem]) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The activeMoiety.code@codeSystem attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="code/@codeSystem=$ingredient-id-oid"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="code/@codeSystem=$ingredient-id-oid">
               <xsl:attribute name="flag">SPL-2</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The OID for the activeMoiety should be: <xsl:text/>
                  <xsl:value-of select="$ingredient-id-oid"/>
                  <xsl:text/> however the codeSystem is set to: <xsl:text/>
                  <xsl:value-of select="code/@codeSystem"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="code/@code=$ingredient-allowed-codes"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="code/@code=$ingredient-allowed-codes">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: Code: <xsl:text/>
                  <xsl:value-of select="code/@code"/>
                  <xsl:text/> is not in OID: <xsl:text/>
                  <xsl:value-of select="$ingredient-id-oid"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="name=$ingredient-name"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="name=$ingredient-name">
               <xsl:attribute name="flag">SPL-7</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The document contains: <xsl:text/>
                  <xsl:value-of select="name"/>
                  <xsl:text/> while code: <xsl:text/>
                  <xsl:value-of select="code/@code"/>
                  <xsl:text/> for OID: <xsl:text/>
                  <xsl:value-of select="$ingredient-id-oid"/>
                  <xsl:text/> contains: <xsl:text/>
                  <xsl:value-of select="$ingredient-name"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M74"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="asEquivalentSubstance" priority="1025" mode="M74">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="asEquivalentSubstance"/>
      <xsl:variable name="code" select="definingSubstance/code/@code"/>
      <xsl:variable name="ingredient-allowed-codes"
                    select="((document(concat($oid_loc,$ingredient-id-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue)"/>
      <xsl:variable name="ingredient-name"
                    select="((document(concat($oid_loc,$ingredient-id-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row[./Value[@ColumnRef='code']/SimpleValue=$code]/Value[@ColumnRef=$display-language]/SimpleValue)"/>

		    <!--REPORT -->
      <xsl:if test="count(definingSubstance/code) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(definingSubstance/code) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The definingSubstance.code element is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(definingSubstance/code[@code]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(definingSubstance/code[@code]) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The definingSubstance.code@code attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(definingSubstance/code[@codeSystem]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(definingSubstance/code[@codeSystem]) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The definingSubstance.code@codeSystem attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="definingSubstance/code/@codeSystem=$ingredient-id-oid"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="definingSubstance/code/@codeSystem=$ingredient-id-oid">
               <xsl:attribute name="flag">SPL-2</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The OID for the definingSubstance should be: <xsl:text/>
                  <xsl:value-of select="$ingredient-id-oid"/>
                  <xsl:text/> however the codeSystem is set to: <xsl:text/>
                  <xsl:value-of select="definingSubstance/code/@codeSystem"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="definingSubstance/code/@code=$ingredient-allowed-codes"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="definingSubstance/code/@code=$ingredient-allowed-codes">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: Code: <xsl:text/>
                  <xsl:value-of select="definingSubstance/code/@code"/>
                  <xsl:text/> is not in OID: <xsl:text/>
                  <xsl:value-of select="$ingredient-id-oid"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="definingSubstance/name=$ingredient-name"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="definingSubstance/name=$ingredient-name">
               <xsl:attribute name="flag">SPL-7</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The document contains: <xsl:text/>
                  <xsl:value-of select="definingSubstance/name"/>
                  <xsl:text/> while code: <xsl:text/>
                  <xsl:value-of select="definingSubstance/code/@code"/>
                  <xsl:text/> for OID: <xsl:text/>
                  <xsl:value-of select="$ingredient-id-oid"/>
                  <xsl:text/> contains: <xsl:text/>
                  <xsl:value-of select="$ingredient-name"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M74"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="consumedIn/substanceAdministration/routeCode"
                 priority="1024"
                 mode="M74">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="consumedIn/substanceAdministration/routeCode"/>
      <xsl:variable name="allowed-codes"
                    select="(document(concat($oid_loc,$route-of-administration-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue"/>

		    <!--REPORT -->
      <xsl:if test="count(@code) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(@code) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The @code attribute is missing for a routeCode element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(@codeSystem) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(@codeSystem) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The codeSystem attribute is missing for a routeCode element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@codeSystem=$route-of-administration-oid"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@codeSystem=$route-of-administration-oid">
               <xsl:attribute name="flag">SPL-2</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The OID for the routeCode should be: <xsl:text/>
                  <xsl:value-of select="$route-of-administration-oid"/>
                  <xsl:text/> however the codeSystem is set to: <xsl:text/>
                  <xsl:value-of select="@codeSystem"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@code=$allowed-codes"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@code=$allowed-codes">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: Code: <xsl:text/>
                  <xsl:value-of select="@code"/>
                  <xsl:text/> is not in OID: <xsl:text/>
                  <xsl:value-of select="$route-of-administration-oid"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>********************* route debuging  ************************* </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>code: <xsl:text/>
               <xsl:value-of select="$code"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>allowed codes: <xsl:text/>
               <xsl:value-of select="$allowed-codes"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>********************* end debuging info ************************* </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M74"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="marketingAct" priority="1023" mode="M74">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="marketingAct"/>
      <xsl:variable name="allowed-status-codes"
                    select="(document(concat($oid_loc,$status-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue"/>

		    <!--REPORT -->
      <xsl:if test="count(code) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(code) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The code element is missing for an marketingAct element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(code[@code]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(code[@code]) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The marketingAct.code@code attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(code[@codeSystem]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(code[@codeSystem]) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The marketingAct.code@codeSystem attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="code/@codeSystem=$status-oid"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="code/@codeSystem=$status-oid">
               <xsl:attribute name="flag">SPL-2</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The OID for marketingAct.code@codeSystem should be: <xsl:text/>
                  <xsl:value-of select="$status-oid"/>
                  <xsl:text/> however the codeSystem is set to: <xsl:text/>
                  <xsl:value-of select="code/@codeSystem"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="code/@code=$allowed-status-codes"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="code/@code=$allowed-status-codes">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: Code: <xsl:text/>
                  <xsl:value-of select="code/@code"/>
                  <xsl:text/> is not in OID: <xsl:text/>
                  <xsl:value-of select="$status-oid"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M74"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="characteristic" priority="1022" mode="M74">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="characteristic"/>

		    <!--REPORT -->
      <xsl:if test="not(code[@codeSystem=$product-characteristics-oid])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="not(code[@codeSystem=$product-characteristics-oid])">
            <xsl:attribute name="flag">SPL-2</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: There is a characteristic where the OID should be: <xsl:text/>
               <xsl:value-of select="$product-characteristics-oid"/>
               <xsl:text/> however the codeSystem is set to: <xsl:text/>
               <xsl:value-of select="code/@codeSystem"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M74"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="section/subject/manufacturedProduct"
                 priority="1021"
                 mode="M74">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="section/subject/manufacturedProduct"/>

		    <!--REPORT -->
      <xsl:if test="count(subjectOf/characteristic/code[@code='1' and @codeSystem=$product-characteristics-oid]) &gt; 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(subjectOf/characteristic/code[@code='1' and @codeSystem=$product-characteristics-oid]) &gt; 1">
            <xsl:attribute name="flag">SPL-11</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: Only one Color characteristic is allowed for a product.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(subjectOf/characteristic/code[@code='2' and @codeSystem=$product-characteristics-oid]) &gt; 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(subjectOf/characteristic/code[@code='2' and @codeSystem=$product-characteristics-oid]) &gt; 1">
            <xsl:attribute name="flag">SPL-11</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: Only one Image characteristic is allowed for a product.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(subjectOf/characteristic/code[@code='3' and @codeSystem=$product-characteristics-oid]) &gt; 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(subjectOf/characteristic/code[@code='3' and @codeSystem=$product-characteristics-oid]) &gt; 1">
            <xsl:attribute name="flag">SPL-11</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: Only one Shape  characteristic is allowed for a product.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(subjectOf/characteristic/code[@code='4' and @codeSystem=$product-characteristics-oid]) &gt; 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(subjectOf/characteristic/code[@code='4' and @codeSystem=$product-characteristics-oid]) &gt; 1">
            <xsl:attribute name="flag">SPL-11</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: Only one Flavor characteristic is allowed for a product.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(subjectOf/characteristic/code[@code='5' and @codeSystem=$product-characteristics-oid]) &gt; 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(subjectOf/characteristic/code[@code='5' and @codeSystem=$product-characteristics-oid]) &gt; 1">
            <xsl:attribute name="flag">SPL-11</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: Only one Scoring  characteristic is allowed for a product.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(subjectOf/characteristic/code[@code='6' and @codeSystem=$product-characteristics-oid]) &gt; 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(subjectOf/characteristic/code[@code='6' and @codeSystem=$product-characteristics-oid]) &gt; 1">
            <xsl:attribute name="flag">SPL-11</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: Only one Production Amount characteristic is allowed for a product.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(subjectOf/characteristic/code[@code='7' and @codeSystem=$product-characteristics-oid]) &gt; 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(subjectOf/characteristic/code[@code='7' and @codeSystem=$product-characteristics-oid]) &gt; 1">
            <xsl:attribute name="flag">SPL-11</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: Only one Combination Product Type characteristic is allowed for a product.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(subjectOf/characteristic/code[@code='8' and @codeSystem=$product-characteristics-oid]) &gt; 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(subjectOf/characteristic/code[@code='8' and @codeSystem=$product-characteristics-oid]) &gt; 1">
            <xsl:attribute name="flag">SPL-11</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: Only one Reusability characteristic is allowed for a product.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(subjectOf/characteristic/code[@code='9' and @codeSystem=$product-characteristics-oid]) &gt; 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(subjectOf/characteristic/code[@code='9' and @codeSystem=$product-characteristics-oid]) &gt; 1">
            <xsl:attribute name="flag">SPL-11</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: Only one Sterile Use characteristic is allowed for a product.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(subjectOf/characteristic/code[@code='10' and @codeSystem=$product-characteristics-oid]) &gt; 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(subjectOf/characteristic/code[@code='10' and @codeSystem=$product-characteristics-oid]) &gt; 1">
            <xsl:attribute name="flag">SPL-11</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: Only one MRI Use characteristic is allowed for a product.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(subjectOf/characteristic/code[@code='11' and @codeSystem=$product-characteristics-oid]) &gt; 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(subjectOf/characteristic/code[@code='11' and @codeSystem=$product-characteristics-oid]) &gt; 1">
            <xsl:attribute name="flag">SPL-11</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: Only one Size characteristic is allowed for a product.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(subjectOf/characteristic/code[@code='12' and @codeSystem=$product-characteristics-oid]) &gt; 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(subjectOf/characteristic/code[@code='12' and @codeSystem=$product-characteristics-oid]) &gt; 1">
            <xsl:attribute name="flag">SPL-11</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: Only one Imprint characteristic is allowed for a product.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(subjectOf/characteristic/code[@code='16' and @codeSystem=$product-characteristics-oid]) &gt; 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(subjectOf/characteristic/code[@code='16' and @codeSystem=$product-characteristics-oid]) &gt; 1">
            <xsl:attribute name="flag">SPL-11</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: Only one Coating characteristic is allowed for a product.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M74"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="characteristic/code[@code='1' and @codeSystem=$product-characteristics-oid]"
                 priority="1020"
                 mode="M74">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="characteristic/code[@code='1' and @codeSystem=$product-characteristics-oid]"/>
      <xsl:variable name="allowed-codes"
                    select="(document(concat($oid_loc,$color-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue"/>

		    <!--REPORT -->
      <xsl:if test="count(../value) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(../value) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The value element is missing for an Color characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(../value/@code) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(../value/@code) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The @code attribute is missing for a Color characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(../value/@codeSystem) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(../value/@codeSystem) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The codeSystem attribute is missing for a Color characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../value/@codeSystem=$color-oid"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="../value/@codeSystem=$color-oid">
               <xsl:attribute name="flag">SPL-2</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The OID for color should be: <xsl:text/>
                  <xsl:value-of select="$color-oid"/>
                  <xsl:text/> however the codeSystem is set to: <xsl:text/>
                  <xsl:value-of select="../value/@codeSystem"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../value/@code=$allowed-codes"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="../value/@code=$allowed-codes">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: Code: <xsl:text/>
                  <xsl:value-of select="../value/@code"/>
                  <xsl:text/> is not in OID: <xsl:text/>
                  <xsl:value-of select="$color-oid"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../value/@type='CE'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="../value/@type='CE'">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The value of the xsi:type attribute should be CE however it is: <xsl:text/>
                  <xsl:value-of select="../value/@type"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M74"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="characteristic/code[@code='2' and @codeSystem=$product-characteristics-oid]"
                 priority="1019"
                 mode="M74">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="characteristic/code[@code='2' and @codeSystem=$product-characteristics-oid]"/>
      <xsl:variable name="allowed-media-types"
                    select="(document(concat($oid_loc,$media-type-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue"/>

		    <!--REPORT -->
      <xsl:if test="count(../value) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(../value) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The value element is missing for an Image characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(../value/reference) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(../value/reference) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The value.reference element is missing for an Image characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(../value/@mediaType) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(../value/@mediaType) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The value@mediaType attribute is missing for an Image characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(../value/@type) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(../value/@type) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The value@type attribute is missing for an Image characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(../value/reference/@value) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(../value/reference/@value) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The value.reference@value attribute is missing for an Image characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../value/@mediaType=$allowed-media-types"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="../value/@mediaType=$allowed-media-types">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: Code: <xsl:text/>
                  <xsl:value-of select="../value/@mediaType"/>
                  <xsl:text/> is not in OID: <xsl:text/>
                  <xsl:value-of select="$media-type-oid"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../value/@type='ED'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="../value/@type='ED'">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The value of the xsi:type attribute should be ED however it is: <xsl:text/>
                  <xsl:value-of select="../value/@type"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(../value/reference/@value) &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(../value/reference/@value) &gt; 0">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The value.reference@reference attribute is empty for an Image characteristic.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M74"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="characteristic/code[@code='3' and @codeSystem=$product-characteristics-oid]"
                 priority="1018"
                 mode="M74">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="characteristic/code[@code='3' and @codeSystem=$product-characteristics-oid]"/>
      <xsl:variable name="allowed-codes"
                    select="(document(concat($oid_loc,$shape-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue"/>

		    <!--REPORT -->
      <xsl:if test="count(../value) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(../value) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The value element is missing for an Shape characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(../value/@code) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(../value/@code) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The @code attribute is missing for a Shape characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(../value/@codeSystem) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(../value/@codeSystem) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The codeSystem attribute is missing for a Shape characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../value/@codeSystem=$shape-oid"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="../value/@codeSystem=$shape-oid">
               <xsl:attribute name="flag">SPL-2</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The OID for Shape should be: <xsl:text/>
                  <xsl:value-of select="$shape-oid"/>
                  <xsl:text/> however the codeSystem is set to: <xsl:text/>
                  <xsl:value-of select="../value/@codeSystem"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../value/@code=$allowed-codes"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="../value/@code=$allowed-codes">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: Code: <xsl:text/>
                  <xsl:value-of select="../value/@code"/>
                  <xsl:text/> is not in OID: <xsl:text/>
                  <xsl:value-of select="$shape-oid"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../value/@type='CE'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="../value/@type='CE'">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The value of the xsi:type attribute should be CE however it is: <xsl:text/>
                  <xsl:value-of select="../value/@type"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M74"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="characteristic/code[@code='4' and @codeSystem=$product-characteristics-oid]"
                 priority="1017"
                 mode="M74">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="characteristic/code[@code='4' and @codeSystem=$product-characteristics-oid]"/>
      <xsl:variable name="allowed-codes"
                    select="(document(concat($oid_loc,$flavor-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue"/>

		    <!--REPORT -->
      <xsl:if test="count(../value) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(../value) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The value element is missing for an Flavor characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(../value/@code) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(../value/@code) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The @code attribute is missing for a Flavor characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(../value/@codeSystem) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(../value/@codeSystem) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The codeSystem attribute is missing for a Flavor characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../value/@codeSystem=$flavor-oid"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="../value/@codeSystem=$flavor-oid">
               <xsl:attribute name="flag">SPL-2</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The OID for Flavor should be: <xsl:text/>
                  <xsl:value-of select="$flavor-oid"/>
                  <xsl:text/> however the codeSystem is set to: <xsl:text/>
                  <xsl:value-of select="../value/@codeSystem"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../value/@code=$allowed-codes"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="../value/@code=$allowed-codes">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: Code: <xsl:text/>
                  <xsl:value-of select="../value/@code"/>
                  <xsl:text/> is not in OID: <xsl:text/>
                  <xsl:value-of select="$flavor-oid"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../value/@type='CE'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="../value/@type='CE'">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The value of the xsi:type attribute should be CE however it is: <xsl:text/>
                  <xsl:value-of select="../value/@type"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M74"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="characteristic/code[@code='5' and @codeSystem=$product-characteristics-oid]"
                 priority="1016"
                 mode="M74">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="characteristic/code[@code='5' and @codeSystem=$product-characteristics-oid]"/>

		    <!--REPORT -->
      <xsl:if test="count(../value) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(../value) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The value element is missing for an Scoring characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(../value/@value) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(../value/@value) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The value@value attribute is missing for an Scoring characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(../value/@type) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(../value/@type) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The value@type attribute is missing for an Scoring characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../value/@type='INT'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="../value/@type='INT'">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The value of the xsi:type attribute should be INT however it is: <xsl:text/>
                  <xsl:value-of select="../value/@type"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(../value/@value) &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(../value/@value) &gt; 0">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The value@value attribute is empty for an Scoring characteristic.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M74"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="characteristic/code[@code='6' and @codeSystem=$product-characteristics-oid]"
                 priority="1015"
                 mode="M74">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="characteristic/code[@code='6' and @codeSystem=$product-characteristics-oid]"/>

		    <!--REPORT -->
      <xsl:if test="count(../value) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(../value) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The value element is missing for an Production Amount characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(../value/@value) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(../value/@value) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The value@value attribute is missing for an Production Amount characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(../value/@type) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(../value/@type) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The value@type attribute is missing for an Production Amount characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../value/@type='INT'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="../value/@type='INT'">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The value of the xsi:type attribute should be INT however it is: <xsl:text/>
                  <xsl:value-of select="../value/@type"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(../value/@value) &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(../value/@value) &gt; 0">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The value@value attribute is empty for an Production Amount characteristic.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M74"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="characteristic/code[@code='7' and @codeSystem=$product-characteristics-oid]"
                 priority="1014"
                 mode="M74">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="characteristic/code[@code='7' and @codeSystem=$product-characteristics-oid]"/>
      <xsl:variable name="allowed-codes"
                    select="(document(concat($oid_loc,$combination-product-type-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue"/>

		    <!--REPORT -->
      <xsl:if test="count(../value) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(../value) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The value element is missing for an Combination Product Type characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(../value/@code) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(../value/@code) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The @code attribute is missing for a Combination Product Type characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(../value/@codeSystem) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(../value/@codeSystem) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The codeSystem attribute is missing for a Combination Product Type characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../value/@codeSystem=$combination-product-type-oid"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="../value/@codeSystem=$combination-product-type-oid">
               <xsl:attribute name="flag">SPL-2</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The OID for Combination Product Type should be: <xsl:text/>
                  <xsl:value-of select="$combination-product-type-oid"/>
                  <xsl:text/> however the codeSystem is set to: <xsl:text/>
                  <xsl:value-of select="../value/@codeSystem"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../value/@code=$allowed-codes"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="../value/@code=$allowed-codes">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: Code: <xsl:text/>
                  <xsl:value-of select="../value/@code"/>
                  <xsl:text/> is not in OID: <xsl:text/>
                  <xsl:value-of select="$combination-product-type-oid"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../value/@type='CV'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="../value/@type='CV'">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The value of the xsi:type attribute should be CV however it is: <xsl:text/>
                  <xsl:value-of select="../value/@type"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M74"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="characteristic/code[@code='8' and @codeSystem=$product-characteristics-oid]"
                 priority="1013"
                 mode="M74">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="characteristic/code[@code='8' and @codeSystem=$product-characteristics-oid]"/>

		    <!--REPORT -->
      <xsl:if test="count(../value) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(../value) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The value element is missing for an Reusability characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(../value/@value) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(../value/@value) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The value@value attribute is missing for an Reusability characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(../value/@type) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(../value/@type) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The value@type attribute is missing for an Reusability characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../value/@type='INT'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="../value/@type='INT'">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The value of the xsi:type attribute should be INT however it is: <xsl:text/>
                  <xsl:value-of select="../value/@type"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(../value/@value) &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(../value/@value) &gt; 0">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The value@value attribute is empty for an Reusability characteristic.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M74"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="characteristic/code[@code='9' and @codeSystem=$product-characteristics-oid]"
                 priority="1012"
                 mode="M74">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="characteristic/code[@code='9' and @codeSystem=$product-characteristics-oid]"/>

		    <!--REPORT -->
      <xsl:if test="count(../value) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(../value) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The value element is missing for a Sterile Use characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(../value/@value) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(../value/@value) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The value@value attribute is missing for a Sterile Use characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(../value/@type) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(../value/@type) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The value@type attribute is missing for a Sterile Use characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../value/@type='BL'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="../value/@type='BL'">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The value of the xsi:type attribute should be BL however it is: <xsl:text/>
                  <xsl:value-of select="../value/@type"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(../value/@value) &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(../value/@value) &gt; 0">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The value@value attribute is empty for a Sterile Use characteristic.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M74"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="characteristic/code[@code='10' and @codeSystem=$product-characteristics-oid]"
                 priority="1011"
                 mode="M74">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="characteristic/code[@code='10' and @codeSystem=$product-characteristics-oid]"/>

		    <!--REPORT -->
      <xsl:if test="count(../value) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(../value) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The value element is missing for a MRI Use characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(../value/@value) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(../value/@value) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The value@value attribute is missing for a MRI Use characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(../value/@type) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(../value/@type) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The value@type attribute is missing for a MRI Use characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../value/@type='BL'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="../value/@type='BL'">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The value of the xsi:type attribute should be BL however it is: <xsl:text/>
                  <xsl:value-of select="../value/@type"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(../value/@value) &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(../value/@value) &gt; 0">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The value@value attribute is empty for a MRI Use characteristic.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M74"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="characteristic/code[@code='11' and @codeSystem=$product-characteristics-oid]"
                 priority="1010"
                 mode="M74">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="characteristic/code[@code='11' and @codeSystem=$product-characteristics-oid]"/>
      <xsl:variable name="allowed-codes"
                    select="(document(concat($oid_loc,$units-of-measure-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue"/>

		    <!--REPORT -->
      <xsl:if test="count(../value) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(../value) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The value element is missing for a Size characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(../value/@value) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(../value/@value) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The value@value attribute is missing for a Size characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(../value/@unit) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(../value/@unit) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The value@unit attribute is missing for a Size characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(../value/@type) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(../value/@type) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The value@type attribute is missing for a Size characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../value/@unit=$allowed-codes"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="../value/@unit=$allowed-codes">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: Code: <xsl:text/>
                  <xsl:value-of select="../value/@unit"/>
                  <xsl:text/> is not in OID: <xsl:text/>
                  <xsl:value-of select="$units-of-measure-oid"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../value/@type='PQ'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="../value/@type='PQ'">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The value of the xsi:type attribute should be PQ however it is: <xsl:text/>
                  <xsl:value-of select="../value/@type"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(../value/@value) &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(../value/@value) &gt; 0">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The value@value attribute is empty for a Size characteristic.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M74"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="characteristic/code[@code='12' and @codeSystem=$product-characteristics-oid]"
                 priority="1009"
                 mode="M74">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="characteristic/code[@code='12' and @codeSystem=$product-characteristics-oid]"/>

		    <!--REPORT -->
      <xsl:if test="count(../value) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(../value) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The value element is missing for an Imprint characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(../value/@type) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(../value/@type) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The value@type attribute is missing for an Imprint characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../value/@type='ST'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="../value/@type='ST'">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The value of the xsi:type attribute should be ST however it is: <xsl:text/>
                  <xsl:value-of select="../value/@type"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(../value) &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(../value) &gt; 0">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The value@value attribute is empty for an Imprint characteristic.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M74"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="characteristic/code[@code='13' and @codeSystem=$product-characteristics-oid]"
                 priority="1008"
                 mode="M74">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="characteristic/code[@code='13' and @codeSystem=$product-characteristics-oid]"/>
      <xsl:variable name="allowed-codes"
                    select="(document(concat($oid_loc,$pharmaceutical-standard-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue"/>

		    <!--REPORT -->
      <xsl:if test="count(../value) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(../value) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The value element is missing for an Pharmaceutical Standard characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(../value/@code) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(../value/@code) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The @code attribute is missing for a Pharmaceutical Standard characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(../value/@codeSystem) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(../value/@codeSystem) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The codeSystem attribute is missing for a Pharmaceutical Standard characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../value/@codeSystem=$pharmaceutical-standard-oid"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="../value/@codeSystem=$pharmaceutical-standard-oid">
               <xsl:attribute name="flag">SPL-2</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The OID for Pharmaceutical Standard should be: <xsl:text/>
                  <xsl:value-of select="$pharmaceutical-standard-oid"/>
                  <xsl:text/> however the codeSystem is set to: <xsl:text/>
                  <xsl:value-of select="../value/@codeSystem"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../value/@code=$allowed-codes"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="../value/@code=$allowed-codes">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: Code: <xsl:text/>
                  <xsl:value-of select="../value/@code"/>
                  <xsl:text/> is not in OID: <xsl:text/>
                  <xsl:value-of select="$pharmaceutical-standard-oid"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../value/@type='CE'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="../value/@type='CE'">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The value of the xsi:type attribute should be CE however it is: <xsl:text/>
                  <xsl:value-of select="../value/@type"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M74"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="characteristic/code[@code='14' and @codeSystem=$product-characteristics-oid]"
                 priority="1007"
                 mode="M74">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="characteristic/code[@code='14' and @codeSystem=$product-characteristics-oid]"/>
      <xsl:variable name="allowed-codes"
                    select="(document(concat($oid_loc,$scheduling-symbol-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue"/>

		    <!--REPORT -->
      <xsl:if test="count(../value) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(../value) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The value element is missing for an Pharmaceutical Standard characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(../value/@code) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(../value/@code) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The @code attribute is missing for a Pharmaceutical Standard characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(../value/@codeSystem) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(../value/@codeSystem) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The codeSystem attribute is missing for a Pharmaceutical Standard characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../value/@codeSystem=$scheduling-symbol-oid"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="../value/@codeSystem=$scheduling-symbol-oid">
               <xsl:attribute name="flag">SPL-2</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The OID for Pharmaceutical Standard should be: <xsl:text/>
                  <xsl:value-of select="$scheduling-symbol-oid"/>
                  <xsl:text/> however the codeSystem is set to: <xsl:text/>
                  <xsl:value-of select="../value/@codeSystem"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../value/@code=$allowed-codes"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="../value/@code=$allowed-codes">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: Code: <xsl:text/>
                  <xsl:value-of select="../value/@code"/>
                  <xsl:text/> is not in OID: <xsl:text/>
                  <xsl:value-of select="$scheduling-symbol-oid"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../value/@type='CE'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="../value/@type='CE'">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The value of the xsi:type attribute should be CE however it is: <xsl:text/>
                  <xsl:value-of select="../value/@type"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M74"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="characteristic/code[@code='15' and @codeSystem=$product-characteristics-oid]"
                 priority="1006"
                 mode="M74">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="characteristic/code[@code='15' and @codeSystem=$product-characteristics-oid]"/>
      <xsl:variable name="allowed-codes"
                    select="(document(concat($oid_loc,$therapeutic-class-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue"/>

		    <!--REPORT -->
      <xsl:if test="count(../value) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(../value) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The value element is missing for an Pharmaceutical Standard characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(../value/@code) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(../value/@code) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The @code attribute is missing for a Pharmaceutical Standard characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(../value/@codeSystem) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(../value/@codeSystem) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The codeSystem attribute is missing for a Pharmaceutical Standard characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../value/@codeSystem=$therapeutic-class-oid"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="../value/@codeSystem=$therapeutic-class-oid">
               <xsl:attribute name="flag">SPL-2</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The OID for Pharmaceutical Standard should be: <xsl:text/>
                  <xsl:value-of select="$therapeutic-class-oid"/>
                  <xsl:text/> however the codeSystem is set to: <xsl:text/>
                  <xsl:value-of select="../value/@codeSystem"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../value/@code=$allowed-codes"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="../value/@code=$allowed-codes">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: Code: <xsl:text/>
                  <xsl:value-of select="../value/@code"/>
                  <xsl:text/> is not in OID: <xsl:text/>
                  <xsl:value-of select="$therapeutic-class-oid"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../value/@type='CE'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="../value/@type='CE'">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The value of the xsi:type attribute should be CE however it is: <xsl:text/>
                  <xsl:value-of select="../value/@type"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M74"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="characteristic/code[@code='16' and @codeSystem=$product-characteristics-oid]"
                 priority="1005"
                 mode="M74">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="characteristic/code[@code='16' and @codeSystem=$product-characteristics-oid]"/>

		    <!--REPORT -->
      <xsl:if test="count(../value) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(../value) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The value element is missing for an Coating characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(../value/@type) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(../value/@type) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The value@type attribute is missing for an Coating characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="../value/@type='ST'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="../value/@type='ST'">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The value of the xsi:type attribute should be ST however it is: <xsl:text/>
                  <xsl:value-of select="../value/@type"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(../value) &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(../value) &gt; 0">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The value@value attribute is empty for an Coating characteristic.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M74"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="manufacturedProduct/manufacturedProduct/templateId[@root='2.16.840.1.113883.2.20.6.53']"
                 priority="1004"
                 mode="M74">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="manufacturedProduct/manufacturedProduct/templateId[@root='2.16.840.1.113883.2.20.6.53']"/>
      <xsl:variable name="allowed-products"
                    select="(document(concat($oid_loc,$product-type-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue"/>

		    <!--REPORT -->
      <xsl:if test="count(@root) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(@root) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The root attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(@extension) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(@extension) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The extension attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@root=$product-type-oid"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@root=$product-type-oid">
               <xsl:attribute name="flag">SPL-2</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Content: The OID should be: <xsl:text/>
                  <xsl:value-of select="$product-type-oid"/>
                  <xsl:text/> however the codeSystem is set to: <xsl:text/>
                  <xsl:value-of select="@root"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@extension=$allowed-products"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@extension=$allowed-products">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Content: Code: <xsl:text/>
                  <xsl:value-of select="@extension"/>
                  <xsl:text/> is not in OID: <xsl:text/>
                  <xsl:value-of select="$product-type-oid"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M74"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="manufacturedProduct/asContent/quantity"
                 priority="1003"
                 mode="M74">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="manufacturedProduct/asContent/quantity"/>
      <xsl:variable name="valid_units"
                    select="(document(concat($oid_loc,$units-of-presentation-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue"/>
      <xsl:variable name="numerator_units" select="numerator/@unit"/>
      <xsl:variable name="denominator_units" select="denominator/@unit"/>

		    <!--REPORT -->
      <xsl:if test="count(numerator/@unit)=0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(numerator/@unit)=0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The unit attribute is missing for the numerator in an asContent element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(numerator/@value)=0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(numerator/@value)=0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The value attribute is missing for the numerator in an asContent element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="$numerator_units=$valid_units"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="$numerator_units=$valid_units">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The numerator unit <xsl:text/>
                  <xsl:value-of select="$numerator_units"/>
                  <xsl:text/> is not in OID: <xsl:text/>
                  <xsl:value-of select="$units-of-presentation-oid"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="numerator/@value &lt; 1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="numerator/@value &lt; 1">
            <xsl:attribute name="flag">SPL-8</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: An asContent element has a numerator with a value smaller than 1.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(denominator/@unit)=0 and not(numerator/@unit='1')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(denominator/@unit)=0 and not(numerator/@unit='1')">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The unit attribute is missing for the denominator in an asContent element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(denominator/@value)=0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(denominator/@value)=0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The value attribute is missing for the denominator in an asContent element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="denominator/@unit='1' or numerator/@unit='1'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="denominator/@unit='1' or numerator/@unit='1'">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The unit attribute is not 1 for the denominator in an asContent element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="denominator/@value='1' "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="denominator/@value='1'">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The value attribute is not 1 for the denominator in an asContent element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M74"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="manufacturedProduct/asContent/containerPackagedProduct"
                 priority="1002"
                 mode="M74">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="manufacturedProduct/asContent/containerPackagedProduct"/>
      <xsl:variable name="package-allowed-codes"
                    select="((document(concat($oid_loc,$pcid-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue)"/>
      <xsl:variable name="allowed-form-codes"
                    select="((document(concat($oid_loc,$pack-type-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue)"/>

		    <!--REPORT -->
      <xsl:if test="count(code) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(code) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The containerPackagedProduct.code element is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(code[@code]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(code[@code]) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The containerPackagedProduct.code@code attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(code[@codeSystem]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(code[@codeSystem]) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The containerPackagedProduct.code@codeSystem attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="code/@codeSystem=$pcid-oid"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="code/@codeSystem=$pcid-oid">
               <xsl:attribute name="flag">SPL-2</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The OID for the containerPackagedProduct.code should be: <xsl:text/>
                  <xsl:value-of select="$pcid-oid"/>
                  <xsl:text/> however the codeSystem is set to: <xsl:text/>
                  <xsl:value-of select="code/@codeSystem"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="code/@code=$package-allowed-codes"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="code/@code=$package-allowed-codes">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: Code: <xsl:text/>
                  <xsl:value-of select="code/@code"/>
                  <xsl:text/> is not in OID: <xsl:text/>
                  <xsl:value-of select="$pcid-oid"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="count(formCode) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(formCode) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The containerPackagedProduct.formCode element is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(formCode[@code]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(formCode[@code]) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The containerPackagedProduct.formCode@code attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(formCode[@codeSystem]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(formCode[@codeSystem]) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The containerPackagedProduct.formCode@codeSystem attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="formCode/@codeSystem=$pack-type-oid"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="formCode/@codeSystem=$pack-type-oid">
               <xsl:attribute name="flag">SPL-2</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The OID for the containerPackagedProduct.formCode should be: <xsl:text/>
                  <xsl:value-of select="$pack-type-oid"/>
                  <xsl:text/> however the codeSystem is set to: <xsl:text/>
                  <xsl:value-of select="formCode/@codeSystem"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="formCode/@code=$allowed-form-codes"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="formCode/@code=$allowed-form-codes">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: Code: <xsl:text/>
                  <xsl:value-of select="formCode/@code"/>
                  <xsl:text/> is not in OID: <xsl:text/>
                  <xsl:value-of select="$pack-type-oid"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M74"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="subject/manufacturedProduct" priority="1001" mode="M74">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="subject/manufacturedProduct"/>

		    <!--REPORT -->
      <xsl:if test="count(consumedIn) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(consumedIn) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The consumedIn element is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(consumedIn/substanceAdministration) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(consumedIn/substanceAdministration) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The consumedIn.substanceAdministration element is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(consumedIn/substanceAdministration/routeCode) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(consumedIn/substanceAdministration/routeCode) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The consumedIn.substanceAdministration.routeCode element is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M74"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="manufacturedProduct/asEquivalentEntity"
                 priority="1000"
                 mode="M74">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="manufacturedProduct/asEquivalentEntity"/>

		    <!--REPORT -->
      <xsl:if test="count(@classCode) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(@classCode) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The @classCode attribute is missing for a asEquivalentEntity element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@classCode='EQUIV'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@classCode='EQUIV'">
               <xsl:attribute name="flag">SPL-2</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The @classCode attribute should be EQUIV it is set to: <xsl:text/>
                  <xsl:value-of select="@codeSystem"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="valid_product"
                    select="(document(concat($oid_loc,$mpid-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue"/>
      <xsl:variable name="valid_package"
                    select="(document(concat($oid_loc,$pcid-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue"/>
      <xsl:variable name="valid_equivalancy"
                    select="(document(concat($oid_loc,$equivalence-codes-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue"/>

		    <!--REPORT -->
      <xsl:if test="count(code) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(code) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The code element is missing in an asEquivalentEntity element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(code/@code) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(code/@code) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The asEquivalentEntity@code attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(code/@codeSystem) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(code/@codeSystem) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The asEquivalentEntity@codeSystem attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="(code/@codeSystem = $equivalence-codes-oid)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="(code/@codeSystem = $equivalence-codes-oid)">
               <xsl:attribute name="flag">SPL-2</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: The OID for the asEquivalentEntity element should be: <xsl:text/>
                  <xsl:value-of select="$equivalence-codes-oid"/>
                  <xsl:text/> however the codeSystem is set to: <xsl:text/>
                  <xsl:value-of select="code/@codeSystem"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="(code/@code=$valid_equivalancy)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="(code/@code=$valid_equivalancy)">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Product: Code: <xsl:text/>
                  <xsl:value-of select="code/@code"/>
                  <xsl:text/> is not contained in OID: <xsl:text/>
                  <xsl:value-of select="$equivalence-codes-oid"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="count(definingMaterialKind) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(definingMaterialKind) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Product: The definingMaterialKind element is missing in an asEquivalentEntity element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(definingMaterialKind/code/@code) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(definingMaterialKind/code/@code) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: The definingMaterialKind@code attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(definingMaterialKind/code/@codeSystem) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(definingMaterialKind/code/@codeSystem) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Author: The definingMaterialKind@codeSystem attribute is missing.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="(definingMaterialKind/code/@codeSystem = $mpid-oid) or (definingMaterialKind/code/@codeSystem = $pcid-oid)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="(definingMaterialKind/code/@codeSystem = $mpid-oid) or (definingMaterialKind/code/@codeSystem = $pcid-oid)">
               <xsl:attribute name="flag">SPL-2</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Author: The OID for element: <xsl:text/>
                  <xsl:value-of select=" local-name(definingMaterialKind/code/@codeSystem)"/>
                  <xsl:text/> should be: <xsl:text/>
                  <xsl:value-of select="$mpid-oid"/>
                  <xsl:text/> or <xsl:text/>
                  <xsl:value-of select="$pcid-oid"/>
                  <xsl:text/> however the codeSystem is set to: <xsl:text/>
                  <xsl:value-of select="definingMaterialKind/code/@codeSystem"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M74"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M74"/>
   <xsl:template match="@*|node()" priority="-2" mode="M74">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M74"/>
   </xsl:template>

   <!--PATTERN Labeling Section Validation-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Labeling Section Validation</svrl:text>

	  <!--RULE -->
   <xsl:template match="component/section" priority="1006" mode="M75">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="component/section"/>
      <xsl:variable name="current-section_code" select="code/@code"/>
      <xsl:variable name="current-section_codesystem" select="code/@codeSystem"/>
      <xsl:variable name="allowed-section-codes"
                    select="(document(concat($oid_loc,$section-id-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue"/>
      <xsl:variable name="oid-section-title"
                    select="(document(concat($oid_loc,$section-id-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row[./Value[@ColumnRef='code']/SimpleValue=$current-section_code]/Value[@ColumnRef=$display-language]/SimpleValue"/>

		    <!--REPORT -->
      <xsl:if test="count(code) = 0 ">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(code) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Content: The code element is missing in section: <xsl:text/>
               <xsl:value-of select="$current-section_code"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(code[@code]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(code[@code]) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Content: The code@code attribute is missing in section: <xsl:text/>
               <xsl:value-of select="$current-section_code"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(code[@codeSystem]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(code[@codeSystem]) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Content: The code@codeSystem attribute is missing in section: <xsl:text/>
               <xsl:value-of select="$current-section_code"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="$current-section_codesystem=$section-id-oid"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="$current-section_codesystem=$section-id-oid">
               <xsl:attribute name="flag">SPL-2</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Content: The OID for element: <xsl:text/>
                  <xsl:value-of select=" local-name($current-section_codesystem)"/>
                  <xsl:text/> should be: <xsl:text/>
                  <xsl:value-of select="$section-id-oid"/>
                  <xsl:text/> however the codeSystem is set to: <xsl:text/>
                  <xsl:value-of select="$current-section_codesystem"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="$current-section_code=$allowed-section-codes"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="$current-section_code=$allowed-section-codes">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Content: Code: <xsl:text/>
                  <xsl:value-of select="$current-section_code"/>
                  <xsl:text/> is not in OID: <xsl:text/>
                  <xsl:value-of select="$section-id-oid"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="count(effectiveTime) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(effectiveTime) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Content: The effectiveTime element is missing in the <xsl:text/>
               <xsl:value-of select="$oid-section-title"/>
               <xsl:text/> (<xsl:text/>
               <xsl:value-of select="$current-section_code"/>
               <xsl:text/>) section.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>********************* section aspect debuging info for section: <xsl:text/>
               <xsl:value-of select="$current-section_code"/>
               <xsl:text/> ************************* </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>The location of the oid file: <xsl:text/>
               <xsl:value-of select="concat($oid_loc,$structure-aspects-oid,$file-suffix)"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>section code: <xsl:text/>
               <xsl:value-of select="$current-section_code"/>
               <xsl:text/> 
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>section codeSystem: <xsl:text/>
               <xsl:value-of select="$current-section_codesystem"/>
               <xsl:text/> 
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>********************* end debuging info for section: <xsl:text/>
               <xsl:value-of select="$current-section_code"/>
               <xsl:text/> ************************* </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M75"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="renderMultiMedia" priority="1005" mode="M75">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="renderMultiMedia"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@referencedObject=//observationMedia/@ID"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@referencedObject=//observationMedia/@ID">
               <xsl:attribute name="flag">SPL-6</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Image: There was no link target found for renderMultiMedia element: <xsl:text/>
                  <xsl:value-of select="./@referencedObject"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>********************* debuging info for renderMultiMedia ************************* </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Content of renderMultiMedia: <xsl:text/>
               <xsl:value-of select=" attribute::*"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Content of renderMultiMedia@referencedObject : <xsl:text/>
               <xsl:value-of select="./@referencedObject"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>********************* end debuging info for section: ************************* </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M75"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="observationMedia" priority="1004" mode="M75">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="observationMedia"/>
      <xsl:variable name="file_formats"
                    select="((document(concat($oid_loc,$media-type-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef=$display-language]/SimpleValue)"/>
      <xsl:variable name="allowed_format" select="(value/@mediaType = $file_formats)"/>
      <xsl:variable name="period" select="contains(value/reference/@value, '.')"/>
      <xsl:variable name="extension" select="substring-after(value/reference/@value, '.')"/>

		    <!--REPORT -->
      <xsl:if test="count(@ID) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(@ID) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Image: The ID attribute is missing in a observationMedia element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="string-length(@ID)&lt;1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="string-length(@ID)&lt;1">
            <xsl:attribute name="flag">SPL-6</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Image: The ID attribute is empty in a observationMedia element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@ID=//renderMultiMedia/@referencedObject"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@ID=//renderMultiMedia/@referencedObject">
               <xsl:attribute name="flag">SPL-6</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Image: There was no source link found for observationMedia element: <xsl:text/>
                  <xsl:value-of select="./@ID"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="count(text) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(text) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Image: The text element is missing in a observationMedia element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="string-length(text)&lt;1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="string-length(text)&lt;1">
            <xsl:attribute name="flag">SPL-6</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Image: The text element is empty in a observationMedia element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="string-length(value)&lt;1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="string-length(value)&lt;1">
            <xsl:attribute name="flag">SPL-6</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Image: The text element is empty in a observationMedia element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(value/@mediaType) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(value/@mediaType) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Image: The value@mediaType atribute is missing in a observationMedia element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="string-length(value/@mediaType)&lt;1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="string-length(value/@mediaType)&lt;1">
            <xsl:attribute name="flag">SPL-6</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Image: The value@mediaType attribute is empty in a observationMedia element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="value/@type = 'ED'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="value/@type = 'ED'">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Image: The value/@type attribute is not 'ED', it is <xsl:text/>
                  <xsl:value-of select="value/@type"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="not($allowed_format)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($allowed_format)">
            <xsl:attribute name="flag">SPL-8</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Image: The value/@mediaType attribute equals: <xsl:text/>
               <xsl:value-of select="value/@mediaType"/>
               <xsl:text/> which is not in OID: <xsl:text/>
               <xsl:value-of select="$media-type-oid"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(value/reference) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(value/reference) = 0">
            <xsl:attribute name="flag">SPL-3</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Image: The value.reference@value atribute is missing in a renderMultiMedia element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(value/reference/@value) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(value/reference/@value) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Image: The value.reference@value atribute is missing in a renderMultiMedia element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="string-length(value/reference/@value)&lt;1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="string-length(value/reference/@value)&lt;1">
            <xsl:attribute name="flag">SPL-6</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Image: The value.reference@value attribute is empty in a renderMultiMedia element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length(value/reference/@value)&lt;60"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(value/reference/@value)&lt;60">
               <xsl:attribute name="flag">SPL-12</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Image: The value.reference@value atribute <xsl:text/>
                  <xsl:value-of select="value/reference/@value"/>
                  <xsl:text/> is more than 59 characters long in a renderMultiMedia element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="value/reference/@value = lower-case(value/reference/@value)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="value/reference/@value = lower-case(value/reference/@value)">
               <xsl:attribute name="flag">SPL-12</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Image: The value/reference@value atribute <xsl:text/>
                  <xsl:value-of select="value/reference/@value"/>
                  <xsl:text/> is not all lowercase in a renderMultiMedia element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="$period"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$period">
               <xsl:attribute name="flag">SPL-12</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Image: The value/reference@value atribute <xsl:text/>
                  <xsl:value-of select="value/reference/@value"/>
                  <xsl:text/> does not contain an extension.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="string-length($extension)&lt;4"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length($extension)&lt;4">
               <xsl:attribute name="flag">SPL-12</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Image: The extension part of the value.reference@value atribute <xsl:text/>
                  <xsl:value-of select="value/reference/@value"/>
                  <xsl:text/> is more than 3 characters long in a renderMultiMedia element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="local-name(..)='component'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="local-name(..)='component'">
               <xsl:attribute name="flag">SPL-9</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Image: The parent element for the observationMedia element should be component but it was <xsl:text/>
                  <xsl:value-of select="local-name(..)"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>********************* observationMedia Debuging ************************* </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>value: <xsl:text/>
               <xsl:value-of select="value/@type"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>value2: <xsl:text/>
               <xsl:value-of select="value/attribute::*"/>
               <xsl:text/>"</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>@mediaType = <xsl:text/>
               <xsl:value-of select="value/@mediaType"/>
               <xsl:text/>"</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>allowed_format = <xsl:text/>
               <xsl:value-of select="$allowed_format"/>
               <xsl:text/>"</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>allowed formats: <xsl:text/>
               <xsl:value-of select="$file_formats"/>
               <xsl:text/>"</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>file name: <xsl:text/>
               <xsl:value-of select="value/reference/@value"/>
               <xsl:text/>"</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>file name lower: <xsl:text/>
               <xsl:value-of select="lower-case(value/reference/@value)"/>
               <xsl:text/>"</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>********************* end debuging info ************************* </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M75"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="effectiveTime" priority="1003" mode="M75">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="effectiveTime"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@value or low/@value or high/@value"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@value or low/@value or high/@value">
               <xsl:attribute name="flag">SPL-6</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Content: The effectiveTime element that has no direct or indirect value</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>*********************  effectiveTime Debuging ************************* </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>effectiveTime@value <xsl:text/>
               <xsl:value-of select="effectiveTime/@value"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>effectiveTime/low/@value <xsl:text/>
               <xsl:value-of select="effectiveTime/low/@value "/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>effectiveTime/high/@value <xsl:text/>
               <xsl:value-of select="effectiveTime/high/@value"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>********************* end debuging info ************************* </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M75"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="effectiveTime/low" priority="1002" mode="M75">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="effectiveTime/low"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@value"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@value">
               <xsl:attribute name="flag">SPL-5</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Content: There is no value for the effectiveTime.low element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="(@value ) and (../high/@value) and not(@value &lt;= (../high/@value))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="(@value ) and (../high/@value) and not(@value &lt;= (../high/@value))">
            <xsl:attribute name="flag">SPL-8</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Content: The effectiveTime.low value: <xsl:text/>
               <xsl:value-of select="@value"/>
               <xsl:text/> is not smaller or equal to the effectiveTime.high value: <xsl:text/>
               <xsl:value-of select="../high/@value"/>
               <xsl:text/> in an effectiveTime.low element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M75"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="effectiveTime/high" priority="1001" mode="M75">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="effectiveTime/high"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@value"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@value">
               <xsl:attribute name="flag">SPL-5</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Content: There is no value for the effectiveTime.high element.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="(@value ) and (../low/@value) and not(@value &gt;= (../low/@value))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="(@value ) and (../low/@value) and not(@value &gt;= (../low/@value))">
            <xsl:attribute name="flag">SPL-8</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Content: The effectiveTime.high value: <xsl:text/>
               <xsl:value-of select="@value"/>
               <xsl:text/> is not greater or equal to the effectiveTime.low value: <xsl:text/>
               <xsl:value-of select="../low/@value"/>
               <xsl:text/> in an effectiveTime.high element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M75"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="confidentialityCode" priority="1000" mode="M75">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="confidentialityCode"/>
      <xsl:variable name="allowed-codes"
                    select="(document(concat($oid_loc,$information-disclosure-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue"/>

		    <!--REPORT -->
      <xsl:if test="count(@code) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(@code) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Content: The @code attribute is missing for a confidentialityCode element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="count(@codeSystem) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(@codeSystem) = 0">
            <xsl:attribute name="flag">SPL-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Content: The @codeSystem attribute is missing for a confidentialityCode element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@codeSystem=$information-disclosure-oid"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@codeSystem=$information-disclosure-oid">
               <xsl:attribute name="flag">SPL-2</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Content: The OID for the confidentialityCode element should be: <xsl:text/>
                  <xsl:value-of select="$information-disclosure-oid"/>
                  <xsl:text/> however the codeSystem is set to: <xsl:text/>
                  <xsl:value-of select="@codeSystem"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@code=$allowed-codes"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@code=$allowed-codes">
               <xsl:attribute name="flag">SPL-8</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Content: Code: <xsl:text/>
                  <xsl:value-of select="@code"/>
                  <xsl:text/> is not in OID: <xsl:text/>
                  <xsl:value-of select="$information-disclosure-oid"/>
                  <xsl:text/>.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M75"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M75"/>
   <xsl:template match="@*|node()" priority="-2" mode="M75">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M75"/>
   </xsl:template>

   <!--PATTERN Doctype Prolog Validation-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Doctype Prolog Validation</svrl:text>

	  <!--RULE -->
   <xsl:template match="/" priority="1000" mode="M76">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/"/>
      <xsl:variable name="stylesheet-info"
                    select="processing-instruction('xml-stylesheet')"/>
      <xsl:variable name="stylesheet1"
                    select="'type=&#34;text/xsl&#34; href=&#34;https://rawgit.com/HealthCanada/HPFB/master/Structured-Product-Labeling-(SPL)/Style-Sheets/current/hpfb-spm.xsl&#34;'"/>
      <xsl:variable name="stylesheet2"
                    select="'type=&#34;text/css&#34; href=&#34;https://rawgit.com/HealthCanada/HPFB/master/Structured-Product-Labeling-(SPL)/Style-Sheets/current/hpfb-spm-core.css&#34;'"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="$stylesheet1=$stylesheet-info"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="$stylesheet1=$stylesheet-info">
               <xsl:attribute name="flag">DT-11</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Doctype Prolog: Doctype: <xsl:text/>
                  <xsl:value-of select="$doc-doctype"/>
                  <xsl:text/> processing instructions did not contain: <xsl:text/>
                  <xsl:value-of select="$stylesheet1"/>
                  <xsl:text/> 
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="$stylesheet2=$stylesheet-info"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="$stylesheet2=$stylesheet-info">
               <xsl:attribute name="flag">DT-11</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Doctype Prolog: Doctype: <xsl:text/>
                  <xsl:value-of select="$doc-doctype"/>
                  <xsl:text/> processing instructions did not contain: <xsl:text/>
                  <xsl:value-of select="$stylesheet2"/>
                  <xsl:text/> 
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>********************* Doctype Processing Instruction Debuging ************************* </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>TemplateID: <xsl:text/>
               <xsl:value-of select="$doc-template"/>
               <xsl:text/>"</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Valid Template: <xsl:text/>
               <xsl:value-of select="$doc-template='1', '2', '3'"/>
               <xsl:text/>"</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Processing Information: <xsl:text/>
               <xsl:value-of select="processing-instruction('xml-stylesheet')"/>
               <xsl:text/>"</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>PI: <xsl:text/>
               <xsl:value-of select="$stylesheet-info"/>
               <xsl:text/>"</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Stylesheet1: <xsl:text/>
               <xsl:value-of select="$stylesheet1"/>
               <xsl:text/>"</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Stylesheet2: <xsl:text/>
               <xsl:value-of select="$stylesheet2"/>
               <xsl:text/>"</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>********************* end debuging info ************************* </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M76"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M76"/>
   <xsl:template match="@*|node()" priority="-2" mode="M76">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M76"/>
   </xsl:template>

   <!--PATTERN Doctype Document Infomation Validation-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Doctype Document Infomation Validation</svrl:text>

	  <!--RULE -->
   <xsl:template match="document" priority="1000" mode="M77">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="document"/>
      <xsl:variable name="allowed-marketing-codes"
                    select="(document(concat($oid_loc,$marketing-category-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue"/>

		    <!--REPORT -->
      <xsl:if test="$doc-doctype='1' and not(title)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="$doc-doctype='1' and not(title)">
            <xsl:attribute name="flag">DT-1</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Doctype Document Information: Doctype: <xsl:text/>
               <xsl:value-of select="$doc-doctype"/>
               <xsl:text/> requires a title element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$doc-doctype='1' and not(effectiveTime/originalText)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="$doc-doctype='1' and not(effectiveTime/originalText)">
            <xsl:attribute name="flag">DT-1</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Doctype Document Information: Doctype: <xsl:text/>
               <xsl:value-of select="$doc-doctype"/>
               <xsl:text/> requires an originalText element to capture the Date of Initial Approval aspects.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$doc-doctype='1' and not(effectiveTime/originalText/@description='Date of Initial Approval')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="$doc-doctype='1' and not(effectiveTime/originalText/@description='Date of Initial Approval')">
            <xsl:attribute name="flag">DT-4</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Doctype Document Information: The originalText@description is incorrect for Doctype: <xsl:text/>
               <xsl:value-of select="$doc-doctype"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$doc-doctype='1' and not(string-length(effectiveTime/originalText) &gt; 1)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="$doc-doctype='1' and not(string-length(effectiveTime/originalText) &gt; 1)">
            <xsl:attribute name="flag">DT-4</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Doctype Document Information: Doctype: <xsl:text/>
               <xsl:value-of select="$doc-doctype"/>
               <xsl:text/> requires infomation in the originalText@description.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$doc-doctype='1' and count(templateId[@root=$marketing-category-oid]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="$doc-doctype='1' and count(templateId[@root=$marketing-category-oid]) = 0">
            <xsl:attribute name="flag">DT-4</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Doctype Document Information: Doctype: <xsl:text/>
               <xsl:value-of select="$doc-doctype"/>
               <xsl:text/> requires a templateId element where the OID is <xsl:text/>
               <xsl:value-of select="$marketing-category-oid"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$doc-doctype='1' and count(templateId[@root=$marketing-category-oid and @extension=$allowed-marketing-codes]) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="$doc-doctype='1' and count(templateId[@root=$marketing-category-oid and @extension=$allowed-marketing-codes]) = 0">
            <xsl:attribute name="flag">DT-6</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Doctype Document Information: The templateId@extension value is not in OID <xsl:text/>
               <xsl:value-of select="$marketing-category-oid"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M77"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M77"/>
   <xsl:template match="@*|node()" priority="-2" mode="M77">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M77"/>
   </xsl:template>

   <!--PATTERN Doctype Author Validation-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Doctype Author Validation</svrl:text>

	  <!--RULE -->
   <xsl:template match="representedOrganization" priority="1001" mode="M78">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="representedOrganization"/>
      <xsl:variable name="company_id" select="id[@root = $company-id-oid]/@extension"/>

		    <!--REPORT -->
      <xsl:if test="($doc-doctype='1') and $company_id='999999999'">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="($doc-doctype='1') and $company_id='999999999'">
            <xsl:attribute name="flag">DT-9</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Doctype Author: Doctype: <xsl:text/>
               <xsl:value-of select="$doc-doctype"/>
               <xsl:text/> does not allow undefined company's</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M78"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="assignedEntity/assignedOrganization"
                 priority="1000"
                 mode="M78">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="assignedEntity/assignedOrganization"/>
      <xsl:variable name="company_id" select="id[@root = $company-id-oid]/@extension"/>

		    <!--REPORT -->
      <xsl:if test="($doc-doctype='1') and $company_id='999999999'">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="($doc-doctype='1') and $company_id='999999999'">
            <xsl:attribute name="flag">DT-9</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Doctype Author: Doctype: <xsl:text/>
               <xsl:value-of select="$doc-doctype"/>
               <xsl:text/> does not allow undefined company's</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M78"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M78"/>
   <xsl:template match="@*|node()" priority="-2" mode="M78">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M78"/>
   </xsl:template>

   <!--PATTERN Doctype Product Data Section Validation-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Doctype Product Data Section Validation</svrl:text>

	  <!--RULE -->
   <xsl:template match="component/structuredBody" priority="1003" mode="M79">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="component/structuredBody"/>

		    <!--REPORT -->
      <xsl:if test="$product-required and count(component/section/code[@code = '48780-1']) = 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="$product-required and count(component/section/code[@code = '48780-1']) = 0">
            <xsl:attribute name="id">DT-Rule-30001</xsl:attribute>
            <xsl:attribute name="flag">DT-1</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Doctype Product: Doctype: <xsl:text/>
               <xsl:value-of select="$doc-doctype"/>
               <xsl:text/> reqires a product data section (the section where the code@code = '48780-1').</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>********************* Doctype Product Data Section Validation ************************* </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>what doctype are we? <xsl:text/>
               <xsl:value-of select="$doc-doctype"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>who needs products? <xsl:text/>
               <xsl:value-of select="$product-driven-doctypes"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>do we need a product? <xsl:text/>
               <xsl:value-of select="$doc-doctype=$product-driven-doctypes"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>do we need a product alternate? <xsl:text/>
               <xsl:value-of select="$product-required"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="$debug=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$debug=1">
            <xsl:attribute name="flag">0</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>********************* end debuging info ************************* </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M79"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="component/section/code[@code = '48780-1']"
                 priority="1002"
                 mode="M79">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="component/section/code[@code = '48780-1']"/>

		    <!--REPORT -->
      <xsl:if test="($doc-doctype='1') and count(../effectiveTime/low)=0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="($doc-doctype='1') and count(../effectiveTime/low)=0">
            <xsl:attribute name="flag">DT-1</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Doctype Product: Doctype: <xsl:text/>
               <xsl:value-of select="$doc-doctype"/>
               <xsl:text/> requires an effectiveTime.low element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="($doc-doctype='1') and count(../effectiveTime/high)=0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="($doc-doctype='1') and count(../effectiveTime/high)=0">
            <xsl:attribute name="flag">DT-1</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Doctype Product: Doctype: <xsl:text/>
               <xsl:value-of select="$doc-doctype"/>
               <xsl:text/> requires an effectiveTime.high element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="($doc-doctype='1') and count(../subject)=0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="($doc-doctype='1') and count(../subject)=0">
            <xsl:attribute name="flag">DT-1</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Doctype Product: Doctype: <xsl:text/>
               <xsl:value-of select="$doc-doctype"/>
               <xsl:text/> requires one or more subject elements.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="($doc-doctype='1') and count(../subject/manufacturedProduct/manufacturedProduct)=0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="($doc-doctype='1') and count(../subject/manufacturedProduct/manufacturedProduct)=0">
            <xsl:attribute name="flag">DT-1</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Doctype Product: Doctype: <xsl:text/>
               <xsl:value-of select="$doc-doctype"/>
               <xsl:text/> requires one or more products.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="($doc-doctype='1') and count(../subject/manufacturedProduct/subjectOf/marketingAct/effectiveTime/low) &gt; 0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="($doc-doctype='1') and count(../subject/manufacturedProduct/subjectOf/marketingAct/effectiveTime/low) &gt; 0">
            <xsl:attribute name="flag">DT-9</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Doctype Product: Doctype: <xsl:text/>
               <xsl:value-of select="$doc-doctype"/>
               <xsl:text/> may not include a marketing effectiveTime.low element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M79"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="component/section[./code/@code = '48780-1']/subject"
                 priority="1001"
                 mode="M79">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="component/section[./code/@code = '48780-1']/subject"/>

		    <!--REPORT -->
      <xsl:if test="($doc-doctype='1') and count(manufacturedProduct/subjectOf/approval)=0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="($doc-doctype='1') and count(manufacturedProduct/subjectOf/approval)=0">
            <xsl:attribute name="flag">DT-1</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Doctype Product: Doctype: <xsl:text/>
               <xsl:value-of select="$doc-doctype"/>
               <xsl:text/> requires an approval element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="($doc-doctype='1') and count(manufacturedProduct/subjectOf/approval/effectiveTime/low)=0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="($doc-doctype='1') and count(manufacturedProduct/subjectOf/approval/effectiveTime/low)=0">
            <xsl:attribute name="flag">DT-1</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Doctype Product: Doctype: <xsl:text/>
               <xsl:value-of select="$doc-doctype"/>
               <xsl:text/> requires an approval.effectiveTime.low element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="($doc-doctype='1') and count(manufacturedProduct/subjectOf/approval/effectiveTime/high)=0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="($doc-doctype='1') and count(manufacturedProduct/subjectOf/approval/effectiveTime/high)=0">
            <xsl:attribute name="flag">DT-1</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Doctype Product: Doctype: <xsl:text/>
               <xsl:value-of select="$doc-doctype"/>
               <xsl:text/> requires an approval.effectiveTime.high element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="($doc-doctype='1') and count(manufacturedProduct/subjectOf/characteristic/code[@codeSystem=$product-characteristics-oid and @code='13'])=0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="($doc-doctype='1') and count(manufacturedProduct/subjectOf/characteristic/code[@codeSystem=$product-characteristics-oid and @code='13'])=0">
            <xsl:attribute name="flag">DT-1</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Doctype Product: Doctype: <xsl:text/>
               <xsl:value-of select="$doc-doctype"/>
               <xsl:text/> requires a Pharmaceutical Standard characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="($doc-doctype='1') and count(manufacturedProduct/subjectOf/characteristic/code[@codeSystem=$product-characteristics-oid and @code='14'])=0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="($doc-doctype='1') and count(manufacturedProduct/subjectOf/characteristic/code[@codeSystem=$product-characteristics-oid and @code='14'])=0">
            <xsl:attribute name="flag">DT-1</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Doctype Product: Doctype: <xsl:text/>
               <xsl:value-of select="$doc-doctype"/>
               <xsl:text/> requires a Scheduling Symbol characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="($doc-doctype='1') and count(manufacturedProduct/subjectOf/characteristic/code[@codeSystem=$product-characteristics-oid and @code='15'])=0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="($doc-doctype='1') and count(manufacturedProduct/subjectOf/characteristic/code[@codeSystem=$product-characteristics-oid and @code='15'])=0">
            <xsl:attribute name="flag">DT-1</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Doctype Product: Doctype: <xsl:text/>
               <xsl:value-of select="$doc-doctype"/>
               <xsl:text/> requires a Therapeutic Classification characteristic.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="($doc-doctype='1') and count(manufacturedProduct/consumedIn/substanceAdministration/routeCode)=0">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="($doc-doctype='1') and count(manufacturedProduct/consumedIn/substanceAdministration/routeCode)=0">
            <xsl:attribute name="flag">DT-1</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Doctype Product: Doctype: <xsl:text/>
               <xsl:value-of select="$doc-doctype"/>
               <xsl:text/> requires a Route of Administration (substanceAdministration.routeCode element).</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M79"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="manufacturedProduct/manufacturedProduct"
                 priority="1000"
                 mode="M79">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="manufacturedProduct/manufacturedProduct"/>

		    <!--REPORT -->
      <xsl:if test="($doc-doctype='1') and not(templateId[@root=$product-type-oid])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="($doc-doctype='1') and not(templateId[@root=$product-type-oid])">
            <xsl:attribute name="flag">DT-1</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Doctype Product: Doctype: <xsl:text/>
               <xsl:value-of select="$doc-doctype"/>
               <xsl:text/> requires a templateID element where the root is: <xsl:text/>
               <xsl:value-of select="$product-type-oid"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="($doc-doctype='1') and asEquivalentEntity">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="($doc-doctype='1') and asEquivalentEntity">
            <xsl:attribute name="flag">DT-9</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Doctype Product: Doctype: <xsl:text/>
               <xsl:value-of select="$doc-doctype"/>
               <xsl:text/> may not contain the asEquivalentEntity element.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M79"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M79"/>
   <xsl:template match="@*|node()" priority="-2" mode="M79">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M79"/>
   </xsl:template>

   <!--PATTERN Doctype Labeling Section Validation-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Doctype Labeling Section Validation</svrl:text>

	  <!--RULE -->
   <xsl:template match="component/section" priority="1008" mode="M80">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="component/section"/>
      <xsl:variable name="current-section_code" select="code/@code"/>
      <xsl:variable name="current-section_codesystem" select="code/@codeSystem"/>
      <xsl:variable name="current-section_title" select="title"/>
      <xsl:variable name="oid-section-codes"
                    select="(document(concat($oid_loc,$section-id-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row/Value[@ColumnRef='code']/SimpleValue"/>
      <xsl:variable name="oid-section-title"
                    select="(document(concat($oid_loc,$section-id-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row[./Value[@ColumnRef='code']/SimpleValue=$current-section_code]/Value[@ColumnRef=$display-language]/SimpleValue"/>
      <xsl:variable name="oid-derived_section"
                    select="(document(concat($oid_loc,$structure-aspects-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row[./Value[@ColumnRef='code']/SimpleValue=$current-section_code]/Value[@ColumnRef='derived']/SimpleValue"/>
      <xsl:variable name="oid-fixed-title-section"
                    select="(document(concat($oid_loc,$structure-aspects-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row[./Value[@ColumnRef='code']/SimpleValue=$current-section_code]/Value[@ColumnRef='fixed_title']/SimpleValue"/>
      <xsl:variable name="section_cardinality"
                    select="(document(concat($oid_loc,$structure-aspects-oid,$file-suffix)))/gc:CodeList/SimpleCodeList/Row[./Value[@ColumnRef='code']/SimpleValue=$current-section_code]/Value[@ColumnRef='cardinality']/SimpleValue"/>

		    <!--REPORT -->
      <xsl:if test="($doc-doctype='1') and not($doc-template='11') and ($current-section_code='999999')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="($doc-doctype='1') and not($doc-template='11') and ($current-section_code='999999')">
            <xsl:attribute name="flag">DT-9</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Doctype Content: Section (code: <xsl:text/>
               <xsl:value-of select="$current-section_code"/>
               <xsl:text/>) can only be used in Doctype:1 Template:11.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="($doc-doctype='1') and ($oid-derived_section='True')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="($doc-doctype='1') and ($oid-derived_section='True')">
            <xsl:attribute name="flag">DT-9</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Doctype Content: Section (code: <xsl:text/>
               <xsl:value-of select="$current-section_code"/>
               <xsl:text/>) is derived and therefore should not be included in the content.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="($doc-doctype='1') and ($doc-template=$strict-PM-templates) and ($oid-fixed-title-section='True') and not($current-section_code=$exception_sections) and (not($current-section_title=$oid-section-title))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="($doc-doctype='1') and ($doc-template=$strict-PM-templates) and ($oid-fixed-title-section='True') and not($current-section_code=$exception_sections) and (not($current-section_title=$oid-section-title))">
            <xsl:attribute name="flag">DT-5</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Doctype Content: The title in the document: <xsl:text/>
               <xsl:value-of select="$current-section_title"/>
               <xsl:text/> does not match the requirements for the <xsl:text/>
               <xsl:value-of select="$current-section_code"/>
               <xsl:text/> section.</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="($doc-doctype='1') and ($doc-template=$strict-PM-templates) and (count(effectiveTime/low) &lt; 1)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="($doc-doctype='1') and ($doc-template=$strict-PM-templates) and (count(effectiveTime/low) &lt; 1)">
            <xsl:attribute name="flag">DT-1</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Doctype Content: Section (code: <xsl:text/>
               <xsl:value-of select="$current-section_code"/>
               <xsl:text/>) is missing the effectiveTime.low element</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="($doc-doctype='1') and ($doc-template=$strict-PM-templates) and (count(effectiveTime/high) &lt; 1)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="($doc-doctype='1') and ($doc-template=$strict-PM-templates) and (count(effectiveTime/high) &lt; 1)">
            <xsl:attribute name="flag">DT-1</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Doctype Content: Section (code: <xsl:text/>
               <xsl:value-of select="$current-section_code"/>
               <xsl:text/>) is missing the effectiveTime.high element</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M80"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="//asEquivalentEntity" priority="1007" mode="M80">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//asEquivalentEntity"/>

		    <!--REPORT -->
      <xsl:if test="($doc-doctype='1')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="($doc-doctype='1')">
            <xsl:attribute name="flag">DT-9</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Doctype: There is an asEquivalentEntity element defined.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M80"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="structuredBody/component/section/code[@code = '10' and @codeSystem = $section-id-oid]"
                 priority="1006"
                 mode="M80">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="structuredBody/component/section/code[@code = '10' and @codeSystem = $section-id-oid]"/>

		    <!--REPORT -->
      <xsl:if test="($doc-doctype='1') and (string-length(parent::section/text) &gt; 0)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="($doc-doctype='1') and (string-length(parent::section/text) &gt; 0)">
            <xsl:attribute name="flag">DT-9</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Doctype Content: Section 10 has has content in the text element</svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="($doc-doctype='1') and (string-length(parent::section/title) &gt; 0)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="($doc-doctype='1') and (string-length(parent::section/title) &gt; 0)">
            <xsl:attribute name="flag">DT-9</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Doctype Content: Section 10 has has content in the title element</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M80"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="structuredBody/component/section/code[@code = '20' and @codeSystem = $section-id-oid]"
                 priority="1005"
                 mode="M80">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="structuredBody/component/section/code[@code = '20' and @codeSystem = $section-id-oid]"/>

		    <!--REPORT -->
      <xsl:if test="($doc-doctype='1') and (string-length(parent::section/text) &gt; 0)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="($doc-doctype='1') and (string-length(parent::section/text) &gt; 0)">
            <xsl:attribute name="flag">DT-9</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Doctype Content: Section 20 has has content in the text element</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M80"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="structuredBody/component/section/code[@code = '30' and @codeSystem = $section-id-oid]"
                 priority="1004"
                 mode="M80">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="structuredBody/component/section/code[@code = '30' and @codeSystem = $section-id-oid]"/>

		    <!--REPORT -->
      <xsl:if test="($doc-doctype='1') and (string-length(parent::section/text) &gt; 0)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="($doc-doctype='1') and (string-length(parent::section/text) &gt; 0)">
            <xsl:attribute name="flag">DT-9</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Doctype Content: Section 30 has has content in the text element</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M80"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="structuredBody/component/section/code[@code = '40' and @codeSystem = $section-id-oid]"
                 priority="1003"
                 mode="M80">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="structuredBody/component/section/code[@code = '40' and @codeSystem = $section-id-oid]"/>

		    <!--REPORT -->
      <xsl:if test="($doc-doctype='1') and (string-length(parent::section/text) &gt; 0)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="($doc-doctype='1') and (string-length(parent::section/text) &gt; 0)">
            <xsl:attribute name="flag">DT-9</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Doctype Content: Section 40 has has content in the text element</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M80"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="structuredBody/component/section/code[@code = '530' and @codeSystem = $section-id-oid]"
                 priority="1002"
                 mode="M80">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="structuredBody/component/section/code[@code = '530' and @codeSystem = $section-id-oid]"/>

		    <!--REPORT -->
      <xsl:if test="($doc-doctype='1') and (string-length(parent::section/title) &gt; 0)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="($doc-doctype='1') and (string-length(parent::section/title) &gt; 0)">
            <xsl:attribute name="flag">DT-9</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Doctype Content: Section 530 has has content in the title element</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M80"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="structuredBody/component/section/code[@code = '370-10' and @codeSystem = $section-id-oid]"
                 priority="1001"
                 mode="M80">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="structuredBody/component/section/code[@code = '370-10' and @codeSystem = $section-id-oid]"/>

		    <!--REPORT -->
      <xsl:if test="($doc-doctype='1') and (string-length(parent::section/title) &gt; 0)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="($doc-doctype='1') and (string-length(parent::section/title) &gt; 0)">
            <xsl:attribute name="flag">DT-9</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Doctype Content: Section 530 has has content in the title element</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M80"/>
   </xsl:template>

	  <!--RULE -->
   <xsl:template match="structuredBody/component/section/code[@code = '580' and @codeSystem = $section-id-oid]"
                 priority="1000"
                 mode="M80">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="structuredBody/component/section/code[@code = '580' and @codeSystem = $section-id-oid]"/>

		    <!--REPORT -->
      <xsl:if test="($doc-doctype='1') and (string-length(parent::section/title) &gt; 0)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="($doc-doctype='1') and (string-length(parent::section/title) &gt; 0)">
            <xsl:attribute name="flag">DT-9</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Doctype Content: Section 530 has has content in the title element</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M80"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M80"/>
   <xsl:template match="@*|node()" priority="-2" mode="M80">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M80"/>
   </xsl:template>
</xsl:stylesheet>
