<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:chemelem="#chemelem"
		xmlns:m="http://www.w3.org/1998/Math/MathML"
                version='1.0'>
                
<!-- ====================================================================== -->
<!-- $id: tokens.xsl, 2002/11/06 Exp $
     This file is part of the XSLT MathML Library distribution.
     See ./README or http://www.raleigh.ru/MathML/mmltex for
     copyright and other information                                        -->
<!-- ====================================================================== -->

<!-- A list of elements used in chemical notation -->
<chemelem:elements>
	<chemelem:element>He</chemelem:element>
	<chemelem:element>Li</chemelem:element>
	<chemelem:element>Be</chemelem:element>
	<chemelem:element>Ne</chemelem:element>
	<chemelem:element>Na</chemelem:element>
	<chemelem:element>Mg</chemelem:element>
	<chemelem:element>Al</chemelem:element>
	<chemelem:element>Si</chemelem:element>
	<chemelem:element>Cl</chemelem:element>
	<chemelem:element>Ar</chemelem:element>
	<chemelem:element>Ca</chemelem:element>
	<chemelem:element>Sc</chemelem:element>
	<chemelem:element>Ti</chemelem:element>
	<chemelem:element>Cr</chemelem:element>
	<chemelem:element>Mn</chemelem:element>
	<chemelem:element>Fe</chemelem:element>
	<chemelem:element>Co</chemelem:element>
	<chemelem:element>Ni</chemelem:element>
	<chemelem:element>Cu</chemelem:element>
	<chemelem:element>Zn</chemelem:element>
	<chemelem:element>Ga</chemelem:element>
	<chemelem:element>Ge</chemelem:element>
	<chemelem:element>Ar</chemelem:element>
	<chemelem:element>Se</chemelem:element>
	<chemelem:element>Br</chemelem:element>
	<chemelem:element>Kr</chemelem:element>
	<chemelem:element>Rb</chemelem:element>
	<chemelem:element>Sr</chemelem:element>
	<chemelem:element>Zr</chemelem:element>
	<chemelem:element>Nb</chemelem:element>
	<chemelem:element>Mo</chemelem:element>
	<chemelem:element>Tc</chemelem:element>
	<chemelem:element>Ru</chemelem:element>
	<chemelem:element>Rh</chemelem:element>
	<chemelem:element>Pd</chemelem:element>
	<chemelem:element>Ag</chemelem:element>
	<chemelem:element>Cd</chemelem:element>
	<chemelem:element>In</chemelem:element>
	<chemelem:element>Sn</chemelem:element>
	<chemelem:element>Sb</chemelem:element>
	<chemelem:element>Te</chemelem:element>
	<chemelem:element>Xe</chemelem:element>
	<chemelem:element>Cs</chemelem:element>
	<chemelem:element>Ba</chemelem:element>
	<chemelem:element>La</chemelem:element>
	<chemelem:element>Ce</chemelem:element>
	<chemelem:element>Pr</chemelem:element>
	<chemelem:element>Nd</chemelem:element>
	<chemelem:element>Pm</chemelem:element>
	<chemelem:element>Sm</chemelem:element>
	<chemelem:element>Eu</chemelem:element>
	<chemelem:element>Gd</chemelem:element>
	<chemelem:element>Tb</chemelem:element>
	<chemelem:element>Dy</chemelem:element>
	<chemelem:element>Ho</chemelem:element>
	<chemelem:element>Er</chemelem:element>
	<chemelem:element>Tm</chemelem:element>
	<chemelem:element>Yb</chemelem:element>
	<chemelem:element>Lu</chemelem:element>
	<chemelem:element>Hf</chemelem:element>
	<chemelem:element>Ta</chemelem:element>
	<chemelem:element>Re</chemelem:element>
	<chemelem:element>Os</chemelem:element>
	<chemelem:element>Ir</chemelem:element>
	<chemelem:element>Pt</chemelem:element>
	<chemelem:element>Au</chemelem:element>
	<chemelem:element>Hg</chemelem:element>
	<chemelem:element>Tl</chemelem:element>
	<chemelem:element>Pb</chemelem:element>
	<chemelem:element>Bi</chemelem:element>
	<chemelem:element>Po</chemelem:element>
	<chemelem:element>At</chemelem:element>
	<chemelem:element>Rn</chemelem:element>
	<chemelem:element>Fr</chemelem:element>
	<chemelem:element>Ra</chemelem:element>
	<chemelem:element>Ac</chemelem:element>
	<chemelem:element>Th</chemelem:element>
	<chemelem:element>Pa</chemelem:element>
	<chemelem:element>Np</chemelem:element>
	<chemelem:element>Pu</chemelem:element>
	<chemelem:element>Am</chemelem:element>
	<chemelem:element>Cm</chemelem:element>
	<chemelem:element>Bk</chemelem:element>
	<chemelem:element>Cf</chemelem:element>
	<chemelem:element>Es</chemelem:element>
	<chemelem:element>Fm</chemelem:element>
	<chemelem:element>Md</chemelem:element>
	<chemelem:element>No</chemelem:element>
	<chemelem:element>Lr</chemelem:element>
	<chemelem:element>Rf</chemelem:element>
	<chemelem:element>Db</chemelem:element>
	<chemelem:element>Sg</chemelem:element>
	<chemelem:element>Bh</chemelem:element>
	<chemelem:element>Hs</chemelem:element>
	<chemelem:element>Mt</chemelem:element>
	<chemelem:element>Ds</chemelem:element>
	<chemelem:element>Rg</chemelem:element>
</chemelem:elements>

<xsl:variable name="chemelements"
                select="document('')/xsl:stylesheet/chemelem:elements"/>
                
<xsl:template match="m:mi|m:mn|m:mo|m:mtext|m:ms">
	<xsl:call-template name="CommonTokenAtr"/>
</xsl:template>

<!-- Italicize mi's unless longer than 1 character and not a chemical element -->
<xsl:template name="mi">
  <xsl:variable name="math" select="."/>
  <xsl:choose>
    <xsl:when test="string-length(normalize-space(.)) &gt; 1 and not(@mathvariant) and not($chemelements/chemelem:element[string(.)=$math])">
      <xsl:choose>
        <xsl:when test="/course/parameters/parameter[@name='printfont']/@value='palatino'">
          <xsl:text>{\upright </xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>\mathrm{</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:call-template name="replaceEntities">
        <xsl:with-param name="content" select="normalize-space(.)"/>
      </xsl:call-template>
      <xsl:text>}</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="replaceEntities">
        <xsl:with-param name="content" select="normalize-space(.)"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="mn">
	<xsl:apply-templates/>
</xsl:template>

<xsl:template name="mo">
	<xsl:call-template name="replaceEntities">
		<xsl:with-param name="content" select="."/>
	</xsl:call-template>
</xsl:template>

<xsl:template name="mtext">
	<xsl:variable name="content">
		<xsl:call-template name="replaceMtextEntities">
			<xsl:with-param name="content" select="."/>
		</xsl:call-template>
	</xsl:variable>
        <xsl:variable name="italicize">
          <xsl:if test="ancestor::*[local-name()='document'][contains(@class, 'italicize-mtext')]">
            <xsl:text>\it </xsl:text>
          </xsl:if>
        </xsl:variable>
	<xsl:text>\text{</xsl:text>
        <xsl:value-of select="$italicize"/>
	<xsl:value-of select="$content"/>
	<xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="m:mspace">
	<xsl:text>\phantom{\rule</xsl:text>
	<xsl:if test="@depth">
		<xsl:text>[-</xsl:text>
		<xsl:value-of select="@depth"/>
		<xsl:text>]</xsl:text>
	</xsl:if>
	<xsl:text>{</xsl:text>
	<xsl:if test="not(@width)">
		<xsl:text>0ex</xsl:text>
	</xsl:if>
	<xsl:call-template name="replace-namedspace">
	  <xsl:with-param name="length" select="@width"/>
	</xsl:call-template>
	<xsl:text>}{</xsl:text>
	<xsl:if test="not(@height)">
		<xsl:text>0ex</xsl:text>
	</xsl:if>
	<xsl:call-template name="replace-namedspace">
	  <xsl:with-param name="length" select="@height"/>
	</xsl:call-template>
	<xsl:text>}}</xsl:text>
</xsl:template>

<xsl:template name="ms">
	<xsl:choose>
		<xsl:when test="@lquote"><xsl:value-of select="@lquote"/></xsl:when>
		<xsl:otherwise><xsl:text>"</xsl:text></xsl:otherwise>
	</xsl:choose><xsl:apply-templates/><xsl:choose>
		<xsl:when test="@rquote"><xsl:value-of select="@rquote"/></xsl:when>
		<xsl:otherwise><xsl:text>"</xsl:text></xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="CommonTokenAtr">
	<xsl:if test="@mathbackground">
		<xsl:text>\colorbox[rgb]{</xsl:text>
		<xsl:call-template name="color">
			<xsl:with-param name="color" select="@mathbackground"/>
		</xsl:call-template>
		<xsl:text>}{$</xsl:text>
	</xsl:if>
<!-- Note: @color is deprecated in MathML 2.0 -->
	<!--<xsl:if test="@color or @mathcolor"> 
		<xsl:text>\textcolor[rgb]{</xsl:text>
		<xsl:call-template name="color">
			<xsl:with-param name="color" select="@color|@mathcolor"/>
		</xsl:call-template>
		<xsl:text>}{</xsl:text>
	</xsl:if>-->
        <xsl:if test="@fontweight">
                <xsl:choose>
                        <xsl:when test="@fontweight='bold'">
                                <xsl:text>\mathbf{</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                                <xsl:text>{</xsl:text> 
                        </xsl:otherwise>
                </xsl:choose> 
        </xsl:if>  
	<xsl:if test="@mathvariant">
		<xsl:choose>
			<xsl:when test="@mathvariant='bold'">
				<xsl:text>\mathbf{</xsl:text>
			</xsl:when>
			<xsl:when test="@mathvariant='italic'">
				<xsl:text>\mathit{</xsl:text>
			</xsl:when>
			<xsl:when test="@mathvariant='bold-italic'">	<!-- Required definition -->
				<xsl:text>\mathbit{</xsl:text>
			</xsl:when>
			<xsl:when test="@mathvariant='double-struck'">	<!-- Required amsfonts -->
				<xsl:text>\mathbb{</xsl:text>
			</xsl:when>
			<xsl:when test="@mathvariant='bold-fraktur'">	<!-- Error -->
				<xsl:text>{</xsl:text>
			</xsl:when>
			<xsl:when test="@mathvariant='script'">
				<xsl:text>\mathcal{</xsl:text>
			</xsl:when>
			<xsl:when test="@mathvariant='bold-script'">	<!-- Error -->
				<xsl:text>\mathsc{</xsl:text>
			</xsl:when>
			<xsl:when test="@mathvariant='fraktur'">	<!-- Required amsfonts -->
				<xsl:text>\mathfrak{</xsl:text>
			</xsl:when>
			<xsl:when test="@mathvariant='sans-serif'">
				<xsl:text>\mathsf{</xsl:text>
			</xsl:when>
			<xsl:when test="@mathvariant='bold-sans-serif'"> <!-- Required definition -->
				<xsl:text>\mathbsf{</xsl:text>
			</xsl:when>
			<xsl:when test="@mathvariant='sans-serif-italic'"> <!-- Required definition -->
				<xsl:text>\mathsfit{</xsl:text>
			</xsl:when>
			<xsl:when test="@mathvariant='sans-serif-bold-italic'">	<!-- Error -->
				<xsl:text>\mathbsfit{</xsl:text>
			</xsl:when>
			<xsl:when test="@mathvariant='monospace'">
				<xsl:text>\mathtt{</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>
	<xsl:call-template name="selectTemplate"/>
	<xsl:if test="@mathvariant">
		<xsl:text>}</xsl:text>
	</xsl:if>
	<!-- <xsl:if test="@color or @mathcolor">
		<xsl:text>}</xsl:text>
	</xsl:if> -->
	<xsl:if test="@mathbackground">
		<xsl:text>$}</xsl:text>
	</xsl:if>
        <xsl:if test="@fontweight">
                <xsl:text>}</xsl:text>
        </xsl:if>
</xsl:template>

<xsl:template name="selectTemplate">
	<xsl:choose>
		<xsl:when test="local-name(.)='mi'">
			<xsl:call-template name="mi"/>
		</xsl:when>
		<xsl:when test="local-name(.)='mn'">
			<xsl:call-template name="mn"/>
		</xsl:when>
		<xsl:when test="local-name(.)='mo'">
			<xsl:call-template name="mo"/>
		</xsl:when>
		<xsl:when test="local-name(.)='mtext'">
			<xsl:call-template name="mtext"/>
		</xsl:when>
		<xsl:when test="local-name(.)='ms'">
			<xsl:call-template name="ms"/>
		</xsl:when>
	</xsl:choose>
</xsl:template>

<xsl:template name="color">
<!-- NB: Variables colora and valueColor{n} only for Sablotron -->
	<xsl:param name="color"/>
	<xsl:variable name="colora" select="translate($color,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>
	<xsl:choose>
	<xsl:when test="starts-with($colora,'#') and string-length($colora)=4">
		<xsl:variable name="valueColor">
			<xsl:call-template name="Hex2Decimal">
				<xsl:with-param name="arg" select="substring($colora,2,1)"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:value-of select="$valueColor div 15"/><xsl:text>,</xsl:text>
		<xsl:variable name="valueColor1">
			<xsl:call-template name="Hex2Decimal">
				<xsl:with-param name="arg" select="substring($colora,3,1)"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:value-of select="$valueColor1 div 15"/><xsl:text>,</xsl:text>
		<xsl:variable name="valueColor2">
			<xsl:call-template name="Hex2Decimal">
				<xsl:with-param name="arg" select="substring($colora,4,1)"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:value-of select="$valueColor2 div 15"/>
	</xsl:when>
	<xsl:when test="starts-with($colora,'#') and string-length($colora)=7">
		<xsl:variable name="valueColor1">
			<xsl:call-template name="Hex2Decimal">
				<xsl:with-param name="arg" select="substring($colora,2,1)"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="valueColor2">
			<xsl:call-template name="Hex2Decimal">
				<xsl:with-param name="arg" select="substring($colora,3,1)"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:value-of select="($valueColor1*16 + $valueColor2) div 255"/><xsl:text>,</xsl:text>
		<xsl:variable name="valueColor1a">
			<xsl:call-template name="Hex2Decimal">
				<xsl:with-param name="arg" select="substring($colora,4,1)"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="valueColor2a">
			<xsl:call-template name="Hex2Decimal">
				<xsl:with-param name="arg" select="substring($colora,5,1)"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:value-of select="($valueColor1a*16 + $valueColor2a) div 255"/><xsl:text>,</xsl:text>
		<xsl:variable name="valueColor1b">
			<xsl:call-template name="Hex2Decimal">
				<xsl:with-param name="arg" select="substring($colora,6,1)"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="valueColor2b">
			<xsl:call-template name="Hex2Decimal">
				<xsl:with-param name="arg" select="substring($colora,7,1)"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:value-of select="($valueColor1b*16 + $valueColor2b) div 255"/>
	</xsl:when>
<!-- ======================= if color specifed as an html-color-name ========================================== -->
	<xsl:when test="$colora='aqua'"><xsl:text>0,1,1</xsl:text></xsl:when>
	<xsl:when test="$colora='black'"><xsl:text>0,0,0</xsl:text></xsl:when>
	<xsl:when test="$colora='blue'"><xsl:text>0,0,1</xsl:text></xsl:when>
	<xsl:when test="$colora='fuchsia'"><xsl:text>1,0,1</xsl:text></xsl:when>
	<xsl:when test="$colora='gray'"><xsl:text>.5,.5,.5</xsl:text></xsl:when>
	<xsl:when test="$colora='green'"><xsl:text>0,.5,0</xsl:text></xsl:when>
	<xsl:when test="$colora='lime'"><xsl:text>0,1,0</xsl:text></xsl:when>
	<xsl:when test="$colora='maroon'"><xsl:text>.5,0,0</xsl:text></xsl:when>
	<xsl:when test="$colora='navy'"><xsl:text>0,0,.5</xsl:text></xsl:when>
	<xsl:when test="$colora='olive'"><xsl:text>.5,.5,0</xsl:text></xsl:when>
	<xsl:when test="$colora='purple'"><xsl:text>.5,0,.5</xsl:text></xsl:when>
	<xsl:when test="$colora='red'"><xsl:text>1,0,0</xsl:text></xsl:when>
	<xsl:when test="$colora='silver'"><xsl:text>.75,.75,.75</xsl:text></xsl:when>
	<xsl:when test="$colora='teal'"><xsl:text>0,.5,.5</xsl:text></xsl:when>
	<xsl:when test="$colora='white'"><xsl:text>1,1,1</xsl:text></xsl:when>
	<xsl:when test="$colora='yellow'"><xsl:text>1,1,0</xsl:text></xsl:when>
	<xsl:otherwise>
		<xsl:message>Exception at color template</xsl:message>
	</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="Hex2Decimal">
	<xsl:param name="arg"/>
	<xsl:choose>
		<xsl:when test="$arg='f'">
			<xsl:value-of select="15"/>
		</xsl:when>
		<xsl:when test="$arg='e'">
			<xsl:value-of select="14"/>
		</xsl:when>
		<xsl:when test="$arg='d'">
			<xsl:value-of select="13"/>
		</xsl:when>
		<xsl:when test="$arg='c'">
			<xsl:value-of select="12"/>
		</xsl:when>
		<xsl:when test="$arg='b'">
			<xsl:value-of select="11"/>
		</xsl:when>
		<xsl:when test="$arg='a'">
			<xsl:value-of select="10"/>
		</xsl:when>
		<xsl:when test="translate($arg, '0123456789', '9999999999')='9'"> <!-- if $arg is number -->
			<xsl:value-of select="$arg"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:message>Exception at Hex2Decimal template</xsl:message>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- Replaces instances of MathML namedspaces with their appropriate lengths -->
<xsl:template name="replace-namedspace">
<xsl:param name="length"/>
<xsl:if test="starts-with($length,'negative')">
  <xsl:text>-</xsl:text>
</xsl:if>
<xsl:variable name="abs-length">
  <xsl:choose>
    <xsl:when test="starts-with($length,'negative')">
      <xsl:value-of select="substring-after($length,'negative')"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$length"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>
<xsl:choose>
  <xsl:when test="$abs-length='veryverythinmathspace'">
    <xsl:text>0.05556em</xsl:text>
  </xsl:when>
  <xsl:when test="$abs-length='verythinmathspace'">
    <xsl:text>0.11111em</xsl:text>
  </xsl:when>
  <xsl:when test="$abs-length='thinmathspace'">
    <xsl:text>0.16667em</xsl:text>
  </xsl:when>
  <xsl:when test="$abs-length='mediummathspace'">
    <xsl:text>0.22222em</xsl:text>
  </xsl:when>
  <xsl:when test="$abs-length='thickmathspace'">
    <xsl:text>0.27777em</xsl:text>
  </xsl:when>
  <xsl:when test="$abs-length='verythickmathspace'">
    <xsl:text>0.33333em</xsl:text>
  </xsl:when>
  <xsl:when test="$abs-length='veryverythickmathspace'">
    <xsl:text>0.38889em</xsl:text>
  </xsl:when>
  <xsl:otherwise>
    <xsl:value-of select="$abs-length"/>
  </xsl:otherwise>
</xsl:choose>
</xsl:template>

</xsl:stylesheet>
