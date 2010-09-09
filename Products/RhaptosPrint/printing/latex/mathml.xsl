<xsl:stylesheet version="1.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:m="http://www.w3.org/1998/Math/MathML">

<!--
      Replace characters in stdin byte-stream, using mapping from 
      first arg file.

      Author: Christine Donica, Brent Hendricks, Adan Galvan, Chuck Bearden
      (C) 2002-2009 Rice University

      This software is subject to the provisions of the GNU Lesser General
      Public License Version 2.1 (LGPL).  See LICENSE.txt for details.
-->
  <xsl:import href="../common/ident.xsl"/>
  <!-- connexion macros -->
  <xsl:import href="http://cnx.rice.edu/technology/mathml/stylesheet/cnxmathmlc2p.xsl"/>

  <!-- Add a condition to this variable to support parameters from module 
       objects at such time as they are implemented in the repository. -->
  <xsl:variable name="parameters" select="/course/parameters"/>
  <!-- Pull in parameters set by authors in the editing interface. -->
  <xsl:param name="vectornotation"
             select="$parameters/parameter[@name='vectornotation']/@value"/>
  <xsl:param name="scalarproductnotation"
             select="$parameters/parameter[@name='scalarproductnotation']/@value"/>
  <xsl:param name="curlnotation"
             select="$parameters/parameter[@name='curlnotation']/@value"/>
  <xsl:param name="gradnotation"
             select="$parameters/parameter[@name='gradnotation']/@value"/>
  <xsl:param name="andornotation"
             select="$parameters/parameter[@name='andornotation']/@value"/>
  <xsl:param name="realimaginarynotation"
             select="$parameters/parameter[@name='realimaginarynotation']/@value"/>
  <xsl:param name="conjugatenotation"
             select="$parameters/parameter[@name='conjugatenotation']/@value"/>
  <xsl:param name="imaginaryi">
    <xsl:choose>
      <xsl:when test="$parameters/parameter[@name='imaginaryi']/@value">
        <xsl:value-of select="$parameters/parameter[@name='imaginaryi']/@value"/>
      </xsl:when>
      <xsl:otherwise>i</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="forallequation"
             select="$parameters/parameter[@name='forallequation']/@value"/>
  <xsl:param name="meannotation"
             select="$parameters/parameter[@name='meannotation']/@value"/>
  <xsl:param name="remaindernotation"
             select="$parameters/parameter[@name='remaindernotation']/@value"/>
  <!-- FIXME: present in XSLT, but not implemented in interface! -->
  <xsl:param name="vectorproductnotation"
             select="$parameters/parameter[@name='vectorproductnotation']/@value"/>
  <xsl:param name="complementnotation"
             select="$parameters/parameter[@name='complementnotation']/@value"/>

  <!-- Fix our brain-dead, XML-insensitive escaping of LaTeX special 
       characters, at least for curly braces that appear in 
       m:mfenced/@open & @close attributes. -->
  <xsl:template match="m:mfenced/@open|m:mfenced/@close">
    <xsl:choose>
      <xsl:when test=".='\{' or .='\}'">
        <xsl:attribute name="{name(self::node())}">
          <xsl:value-of select="translate(., '\', '')"/>
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise><xsl:copy-of select="."/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<!-- MATH -->
  <xsl:template match="m:math">
    <m:math>
      <xsl:if test="@id">
        <xsl:attribute name="id">
          <xsl:value-of select="@id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:choose>
	<!-- If they specified a display mode, use it -->
	<xsl:when test="@display">
	  <xsl:attribute name="display">
	    <xsl:value-of select="@display"/>
	  </xsl:attribute>
	</xsl:when>
	<!-- Otherwise, explicitly set equations to display 'block' -->
	<xsl:otherwise>
	  <xsl:if test="parent::*[local-name()='equation']">
	    <xsl:attribute name="display">block</xsl:attribute>
	  </xsl:if>
	</xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates />
    </m:math>
  </xsl:template>
 
</xsl:stylesheet>
