<?xml version="1.0" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  version="1.0">

<xsl:import href="debug.xsl"/>


<xsl:template match="db:book">
	<xsl:variable name="title" select="db:bookinfo/db:title"/>
	<xsl:variable name="authorsPrefix">
		<!-- <xsl:text>By:</xsl:text> -->
	</xsl:variable>
	<xsl:variable name="authors">
		<!-- <xsl:call-template name="person.name.list">
			<xsl:with-param name="person.list" select="db:bookinfo/db:authorgroup/db:author"/>
		</xsl:call-template> -->
	</xsl:variable>
	
	<!-- The big titlepage SVG -->
<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   version="1.1"
   x="0px"
   y="0px"
   width="612.051px"
   height="792px"
   viewBox="0 0 612.051 792"
   enable-background="new 0 0 612.051 792"
   xml:space="preserve"
   id="svg2940"
   inkscape:version="0.47 r22583"
   sodipodi:docname="cnx-blank-cover.svg"><defs
   id="defs3016"><inkscape:perspective
     sodipodi:type="inkscape:persp3d"
     inkscape:vp_x="0 : 396 : 1"
     inkscape:vp_y="0 : 1000 : 0"
     inkscape:vp_z="612.05103 : 396 : 1"
     inkscape:persp3d-origin="306.02551 : 264 : 1"
     id="perspective3020" /></defs><sodipodi:namedview
   pagecolor="#ffffff"
   bordercolor="#666666"
   borderopacity="1"
   objecttolerance="10"
   gridtolerance="10"
   guidetolerance="10"
   inkscape:pageopacity="0"
   inkscape:pageshadow="2"
   inkscape:window-width="1082"
   inkscape:window-height="764"
   id="namedview3014"
   showgrid="false"
   inkscape:zoom="1.1919192"
   inkscape:cx="273.73368"
   inkscape:cy="601.85878"
   inkscape:window-x="0"
   inkscape:window-y="0"
   inkscape:window-maximized="0"
   inkscape:current-layer="svg2940" />

<g
   id="Layer_2">

	<linearGradient
   id="SVGID_1_"
   gradientUnits="userSpaceOnUse"
   x1="306.0259"
   y1="792"
   x2="306.0258"
   y2="4.882813e-004">

		<stop
   offset="0"
   style="stop-color:#336699"
   id="stop2944" />

		<stop
   offset="0.1165"
   style="stop-color:#396C9F"
   id="stop2946" />

		<stop
   offset="1"
   style="stop-color:#6699CC"
   id="stop2948" />

	</linearGradient>

	<rect
   width="612.051"
   height="792"
   id="rect2950"
   fill="url(#SVGID_1_)" />

</g>

<g
   id="Layer_1">

	<g
   id="g2953">

		<g
   id="g2955">

			<g
   id="g2957">

				<path
   fill="#FFFFFF"
   d="M188.246,747.798c-0.445,0.838-1.238,1.301-2.209,1.301c-1.436,0-2.486-1.053-2.486-2.512       c0-1.461,1.051-2.521,2.486-2.521c0.891,0,1.648,0.41,2.104,1.121l-0.5,0.357c-0.303-0.578-0.908-0.918-1.604-0.918       c-1.068,0-1.871,0.82-1.871,1.961c0,1.139,0.803,1.951,1.871,1.951c0.748,0,1.346-0.375,1.729-1.098L188.246,747.798z"
   id="path2959" />

				<path
   fill="#FFFFFF"
   d="M192.078,744.173h0.313l3.117,3.59v-3.59h0.598v4.803h-0.303l-3.127-3.592v3.592h-0.598V744.173z"
   id="path2961" />

				<path
   fill="#FFFFFF"
   d="M201.664,746.56l-1.932-2.387h0.73l1.576,1.924l1.568-1.924h0.721l-1.934,2.359l1.988,2.443h-0.766       l-1.598-1.979l-1.611,1.979h-0.705L201.664,746.56z"
   id="path2963" />

				<path
   fill="#FFFFFF"
   d="M209.078,748.708c0,0.24-0.16,0.391-0.357,0.391c-0.195,0-0.365-0.15-0.365-0.391       s0.17-0.402,0.365-0.402C208.918,748.306,209.078,748.468,209.078,748.708z"
   id="path2965" />

				<path
   fill="#FFFFFF"
   d="M213.301,746.587c0-1.461,1.053-2.521,2.486-2.521c1.436,0,2.496,1.061,2.496,2.521       c0,1.459-1.061,2.512-2.496,2.512C214.354,749.099,213.301,748.046,213.301,746.587z M217.658,746.587       c0-1.141-0.793-1.961-1.871-1.961c-1.068,0-1.871,0.82-1.871,1.961c0,1.139,0.803,1.951,1.871,1.951       C216.865,748.538,217.658,747.718,217.658,746.587z"
   id="path2967" />

				<path
   fill="#FFFFFF"
   d="M222.068,744.173h2.754c0.943,0,1.506,0.498,1.506,1.336c0,0.676-0.438,1.23-1.141,1.354l1.203,2.113       h-0.658l-1.203-2.104h-1.863v2.104h-0.598V744.173z M224.785,746.31c0.607,0,0.918-0.275,0.918-0.783       c0-0.498-0.311-0.803-0.891-0.803h-2.146v1.586H224.785z"
   id="path2969" />

				<path
   fill="#FFFFFF"
   d="M233.857,746.97h-1.311v-0.553h1.906v1.443c-0.465,0.803-1.229,1.238-2.174,1.238       c-1.436,0-2.486-1.053-2.486-2.512c0-1.461,1.051-2.521,2.486-2.521c0.891,0,1.648,0.41,2.104,1.121l-0.498,0.357       c-0.305-0.578-0.91-0.918-1.605-0.918c-1.068,0-1.871,0.82-1.871,1.961c0,1.139,0.803,1.951,1.871,1.951       c0.668,0,1.195-0.285,1.578-0.865V746.97z"
   id="path2971" />

			</g>

		</g>

		<path
   fill="#FFBB33"
   d="M172.377,708.573c-8.266,5.287-14.43,17.441-16.609,22c-0.225-0.063-0.441-0.139-0.684-0.139     c-0.379,0-0.734,0.086-1.061,0.229c-2.365-3.766-10.045-14.287-10.127-14.635c0.451-1.99-1.176-3.799-2.984-3.166     c-1.619,0.566-1.898,3.438,1.098,4.107c2.873,0.643,9.51,11.287,11.029,14.506c-0.352,0.447-0.594,0.986-0.594,1.598     c0,1.045,0.623,1.932,1.506,2.359c-3.184,10.805-14.709,18.734-15.877,18.918c-0.951-1.268-2.699-1.484-4.021-0.768     c-2.322,1.262-2.365,4.383-0.895,5.541c2.668,2.105,5.244-0.666,6.557-2.691c9.809-6.529,13.58-16.561,15.098-20.775     c0.092,0.008,0.174,0.055,0.271,0.055c0.236,0,0.447-0.076,0.664-0.135c2.301,3.568,7.395,10.377,7.465,10.668     c0.209,0.893,0.424,3.113,2.605,2.689c1.221-0.236,1.578-1.738,1.018-2.41c-0.523-0.625-1.766-0.771-1.766-0.771     s-3.316-2.119-8.484-10.568c0.67-0.48,1.137-1.227,1.137-2.111c0-0.936-0.516-1.719-1.25-2.186     c3.34-9.248,12.58-20.072,16.344-20.975C175.949,709.755,173.65,706.585,172.377,708.573"
   id="path2973" />

		<g
   id="g2975">

			<path
   fill="#FFFFFF"
   d="M52.049,735.204c-0.762,1.43-2.115,2.221-3.773,2.221c-2.449,0-4.246-1.795-4.246-4.291      c0-2.494,1.797-4.305,4.246-4.305c1.521,0,2.814,0.699,3.59,1.916l-0.852,0.607c-0.518-0.986-1.551-1.566-2.738-1.566      c-1.826,0-3.195,1.4-3.195,3.348s1.369,3.332,3.195,3.332c1.277,0,2.297-0.639,2.951-1.871L52.049,735.204z"
   id="path2977" />

			<path
   fill="#FFFFFF"
   d="M65.393,733.134c0-2.494,1.795-4.305,4.244-4.305s4.262,1.811,4.262,4.305      c0,2.496-1.813,4.291-4.262,4.291S65.393,735.63,65.393,733.134z M72.832,733.134c0-1.947-1.354-3.348-3.195-3.348      c-1.826,0-3.195,1.4-3.195,3.348s1.369,3.332,3.195,3.332C71.479,736.466,72.832,735.067,72.832,733.134z"
   id="path2979" />

			<path
   fill="#FFFFFF"
   d="M87.865,729.011h0.531l5.326,6.131v-6.131h1.02v8.201h-0.518l-5.34-6.131v6.131h-1.02V729.011z"
   id="path2981" />

			<path
   fill="#FFFFFF"
   d="M109.363,729.011h0.533l5.324,6.131v-6.131h1.02v8.201h-0.516l-5.342-6.131v6.131h-1.02V729.011z"
   id="path2983" />

			<path
   fill="#FFFFFF"
   d="M130.861,729.011h6.453v0.943h-5.434v2.404h3.287v0.943h-3.287v2.967h5.768v0.943h-6.787V729.011z"
   id="path2985" />

			<path
   fill="#FFFFFF"
   d="M168.596,728.966h1.035v8.275h-1.035V728.966z"
   id="path2987" />

			<path
   fill="#FFFFFF"
   d="M183.613,733.134c0-2.494,1.795-4.305,4.244-4.305s4.26,1.811,4.26,4.305c0,2.496-1.811,4.291-4.26,4.291      S183.613,735.63,183.613,733.134z M191.053,733.134c0-1.947-1.354-3.348-3.195-3.348c-1.826,0-3.195,1.4-3.195,3.348      s1.369,3.332,3.195,3.332C189.699,736.466,191.053,735.067,191.053,733.134z"
   id="path2989" />

			<path
   fill="#FFFFFF"
   d="M206.084,729.011h0.533l5.326,6.131v-6.131h1.02v8.201h-0.518l-5.34-6.131v6.131h-1.021V729.011z"
   id="path2991" />

			<path
   fill="#FFFFFF"
   d="M227.4,735.097c1.172,0.912,2.465,1.385,3.668,1.385c1.566,0,2.557-0.746,2.557-1.719      c0-0.746-0.639-1.355-1.918-1.461c-1.4-0.105-2.51-0.123-3.379-0.518c-0.76-0.365-1.17-0.959-1.17-1.689      c0-1.262,1.23-2.266,3.18-2.266c1.385,0,2.738,0.471,3.926,1.338l-0.594,0.852c-1.02-0.82-2.146-1.232-3.316-1.232      c-1.293,0-2.131,0.58-2.131,1.264c0,0.303,0.137,0.533,0.396,0.73c0.699,0.531,1.871,0.41,3.377,0.578      c1.719,0.197,2.709,1.188,2.709,2.434c0,1.416-1.311,2.633-3.621,2.633c-1.613,0-2.998-0.457-4.275-1.445L227.4,735.097z"
   id="path2993" />

		</g>

	</g>

	<linearGradient
   id="SVGID_2_"
   gradientUnits="userSpaceOnUse"
   x1="384.3203"
   y1="601.9473"
   x2="384.3203"
   y2="92.2241">

		<stop
   offset="0"
   style="stop-color:#4D80B3"
   id="stop2996" />

		<stop
   offset="1"
   style="stop-color:#6C9FD2"
   id="stop2998" />

	</linearGradient>

	<path
   fill="url(#SVGID_2_)"
   d="M571.717,98.631c-81.092,51.879-141.563,171.111-162.949,215.834c-2.203-0.604-4.33-1.35-6.707-1.35    c-3.715,0-7.205,0.842-10.404,2.24c-23.205-36.941-98.547-140.164-99.352-143.584c4.428-19.518-11.535-37.268-29.277-31.049    c-15.885,5.555-18.627,33.721,10.77,40.285c28.186,6.303,93.295,110.74,108.203,142.32c-3.451,4.385-5.824,9.676-5.824,15.672    c0,10.251,6.109,18.947,14.771,23.138c-31.234,106.006-144.303,183.795-155.76,185.602c-9.332-12.434-26.484-14.57-39.453-7.535    c-22.785,12.385-23.203,43.008-8.775,54.357c26.172,20.658,51.445-6.535,64.322-26.402    c96.227-64.047,133.229-162.459,148.115-203.819c0.902,0.086,1.707,0.537,2.664,0.537c2.32,0,4.391-0.748,6.514-1.313    c22.574,34.999,72.551,101.803,73.24,104.659c2.047,8.758,4.152,30.533,25.557,26.385c11.977-2.316,15.482-17.064,9.984-23.656    c-5.135-6.129-17.322-7.557-17.322-7.557s-32.537-20.791-83.236-103.692c6.572-4.715,11.15-12.023,11.15-20.705    c0-9.186-5.059-16.859-12.264-21.451c32.768-90.721,123.418-196.91,160.342-205.76C606.76,110.225,584.209,79.127,571.717,98.631z"
   id="path3000" />

</g>

<g
   id="Layer_3">

	<polygon
   points="401.051,0 401.051,680.615 567.698,680.615 567.698,700.114 401.051,700.114 401.051,792     612.051,792 612.051,0  "
   id="polygon3003"
   fill="#FFDD33" />

	<rect
   x="44.029"
   y="661.116"
   width="483.021"
   height="19.499"
   id="rect3005"
   fill="#FFDD33" />

</g>

<g
   id="Layer_6">

	<path
   fill="#FFE67D"
   d="M408.574,363.566c22.574,34.998,72.551,101.803,73.24,104.658c2.047,8.758,4.152,30.533,25.557,26.385    c11.977-2.316,15.482-17.064,9.984-23.656c-5.135-6.129-17.322-7.557-17.322-7.557s-32.537-20.791-83.236-103.691    c6.572-4.715,11.15-12.023,11.15-20.705c0-9.186-5.059-16.859-12.264-21.451c32.768-90.721,123.418-196.91,160.342-205.76    c30.734-1.564,8.184-32.662-4.309-13.158c-81.092,51.879-141.563,171.111-162.949,215.834c-2.203-0.604-4.33-1.35-6.707-1.35    c-0.301,0-0.6,0.014-0.896,0.025v51.615c0.289,0.068,0.582,0.123,0.896,0.123C404.381,364.879,406.451,364.131,408.574,363.566z"
   id="path3008" />

</g>

<g
   id="Layer_4">

	<polyline
   fill="none"
   stroke="#EE7700"
   points="401.051,0 401.051,661.116 44.029,661.116 44.029,680.615 567.698,680.615     567.698,700.114 401.051,700.114 401.051,792  "
   id="polyline3011" />

</g>

<g
   id="Layer_5">

</g>

<flowRoot
   xml:space="preserve"
   id="flowRoot3030"
   style="font-size:48px;font-style:normal;font-weight:bold;fill:#ffffff;fill-opacity:1;stroke:none;font-family:Bitstream Vera Sans;-inkscape-font-specification:Bitstream Vera Sans Bold;font-stretch:normal;font-variant:normal;text-anchor:start;text-align:start;writing-mode:lr;line-height:150%"
   transform="translate(-1.2695312e-5,0)"><flowRegion
     id="flowRegion3032"><rect
       id="rect3034"
       width="365.44238"
       height="605.1156"
       x="26.103027"
       y="32.639225"
       style="-inkscape-font-specification:Bitstream Vera Sans Bold;font-family:Bitstream Vera Sans;font-weight:bold;font-style:normal;font-stretch:normal;font-variant:normal;font-size:48px;text-anchor:start;text-align:start;writing-mode:lr;line-height:150%;fill:#ffffff" /></flowRegion><flowPara
     id="flowPara3036"><xsl:value-of select="$title"/></flowPara></flowRoot><flowRoot
   xml:space="preserve"
   id="flowRoot3038"
   style="font-size:24px;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-align:start;line-height:125%;writing-mode:lr-tb;text-anchor:start;fill:#000000;fill-opacity:1;stroke:none;font-family:Bitstream Vera Sans;-inkscape-font-specification:Bitstream Vera Sans"
   transform="translate(-1.2695312e-5,-20.135593)"><flowRegion
     id="flowRegion3040"><rect
       id="rect3042"
       width="175.60217"
       height="590.87762"
       x="420.02142"
       y="58.742252"
       style="font-size:24px;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-align:start;line-height:125%;writing-mode:lr-tb;text-anchor:start;font-family:Bitstream Vera Sans;-inkscape-font-specification:Bitstream Vera Sans" /></flowRegion><flowPara
     id="flowPara3044"
     style="font-size:24px;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-align:start;line-height:125%;writing-mode:lr-tb;text-anchor:start;font-family:Bitstream Vera Sans;-inkscape-font-specification:Bitstream Vera Sans"><xsl:value-of select="authorsPrefix"/></flowPara><flowPara
     style="font-size:24px;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;text-align:start;line-height:125%;writing-mode:lr-tb;text-anchor:start;font-family:Bitstream Vera Sans;-inkscape-font-specification:Bitstream Vera Sans"
     id="flowPara3046"><xsl:value-of select="$authors"/></flowPara></flowRoot></svg>
</xsl:template>

</xsl:stylesheet>