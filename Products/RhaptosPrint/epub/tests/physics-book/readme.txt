To generate a PDF for this I've been running the following line:
../../scripts/module2dbk.sh cnx . "phys-book" "physix" && xsltproc -o index.dbk stripper.xsl index.dbk && ../../scripts/collectiondbk2pdf.sh .


Assorted Notes:

http://sagehill.net/docbookxsl/PageDesign.html#CustomPageSequences
For creating a 2column "Problems" section at the end of a chapter


http://www.sagehill.net/docbookxsl/SideFloats.html#CustomSideFloat

proportional-column-width() explained:
http://74.6.238.254/search/srpcache?ei=UTF-8&p=proportional-column-width&fr=crmas&u=http://cc.bingj.com/cache.aspx?q=proportional-column-width&d=5016083885786701&mkt=en-US&setlang=en-US&w=885980c2,45b49ca&icp=1&.intl=us&sig=cT8g1lYJ5T9fNHyJxHh73Q--

http://threebit.net/mail-archive/fop-users/msg00133.html

alternatives to floats in fop

From: Johannes KŸnsebeck <hnes_k (at) gmx.de>
Date: Mon, 20 Mar 2006 14:42:22 +0100
Thank you Jeremias, that's the solution!
This "2-pass"-approach is very cool, I can't imagine designs that aren't
possible with it.
If you can't wait for XSL-FO2.0, use this as a hack for "layout-driven"
documents.
I just summarize it for the list, because I think it can be helpful in
other situations, too.

 1. first pass: render your content elements (like you want them to
appear) to a areatree
    "fop ... - out application/X-fop-areatree outfile.at"
(don't forget to to include your fonts in the fop.conf for the
areatree-renderer, too). Give your content elements an id, so you later
know where they have been rendered to.

 2. write a XSL that extracts the information about position, sizes,
number of elements per page,  whatever. In my boring example it's just
retrieving the side of a page, but you can retrieve any data that is
known to fop.
...
<xsl:template match="areaTree/pageSequence/pageViewport">
    <xsl:variable name="nr" select=" (at) nr"></xsl:variable><!-- get
page-number -->
    <xsl:variable name="page_format">
        <xsl:choose>
            <xsl:when test="number($nr) mod 2 = 0">left</xsl:when>
            <xsl:when test="number($nr) mod 2 = 1">right</xsl:when>
        </xsl:choose>
    </xsl:variable>
    <page nr="{$nr}" format="{$page_format}">
        <xsl:apply-templates
select="page/regionViewport/regionBody/mainReference/span/flow/block" />
    </page>
</xsl:template>

<xsl:template
match="page/regionViewport/regionBody/mainReference/span/flow/block">
    <xsl:variable name="id" select=" (at) prod-id"></xsl:variable>
    <!-- the id is passed to areatree as  (at) prod-id, you need it later  -->
    <workshop_ref id='{$id}' />
</xsl:template>
...
-> save output in structure.xml
If you're a genius (I'm not), you can skip step 2. and do it directly in 3.

 3. second pass: use the information in the second pass-stylesheet. You
have to pass the context you're working in or you will be stuck in the
included document.
...
       <fo:flow flow-name="xsl-region-body">
            <xsl:apply-templates
select="document('structure.xml')/pages/page/workshop_ref">
                <xsl:with-param name="context" select="." /><!-- keep
context -->
            </xsl:apply-templates>
        </fo:flow>
...
<xsl:template match="workshop_ref">
    <xsl:param name="context"></xsl:param>
    <xsl:variable name="id" select=" (at) id" />
    <xsl:choose>
        <!-- now i know which side I'm on -->
        <xsl:when test="../ (at) format='left'"><xsl:apply-templates
select="$context/workshop[ (at) id=$id]" mode="left" /></xsl:when>
        <xsl:when test="../ (at) format='right'"><xsl:apply-templates
select="$context/workshop[ (at) id=$id]" mode="right" /></xsl:when>
    </xsl:choose
</xsl:template>
 4. That's it. I hope even if the example isn't very exciting, you see
the power behind this.
    cons: It doubles your rendering time, you have a complicated
workflow (automate it with ant), you have to write several stylesheets.
    pros: you can do things you can't do with standard XSL-FO.

I hope I'm not spamming here, but I was happy getting this done.
Thanks Jeremias, for this cool idea.
Hannes


Jeremias Maerki wrote:
> On 07.03.2006 20:37:53 Johannes KŸnsebeck wrote:
>   
>> Hi,
>> I try to build a complex design with fop, the design-template can be
>> seen here :
>>
>>     http://yucca-net.de/data/gild.pdf
>>
>> After toying around with fop, I'm not sure if it is possible to realize
>> this design with fop.
>> I got alternating page-masters and the background-design working.
>> I can format a fo:block with the design for the even page, I can format
>> a fo:block with the design for the odd page, but I can't specify when to
>> use which (the problem you can't see in the template is that it must be
>> possible to put two or more workshops on one page).
>>
>> My thoughts so far (not very far):
>> - use float="inside|outside" (XSL1.1) but that's not supported in fop
>>     
>
> Right. That would probably have been the best approach if it were
> implemented.
>
>   
>> - put date and time infos in region-start/end, but how can I synchronize
>> startpositions with the flow?
>>     
>
> You can't. Not with multiple workshops on one page.
>
>   
>> So my questions are
>> - Do you think it is possible to realize this with XSLT-FO (& maybe
>> extensions)
>>     
>
> Yes, I think so.
>
>   
>> - Do you think it is possible to realize this with fop?
>>     
>
> Not without difficulties. If you can restrict to one workshop per page,
> it's easy. If you want to have multiple workshops you will probably need
> to do a detour. Just an idea: Render the text for the individual
> workshops using a special reduced XSLT using the area tree XML renderer
> with the latest FOP version. You can then determine the height of each
> workshop from the generated XML format. Based on that knowledge you can
> define the distribution of the individual workshops yourself and put one
> page per page-sequence so you can control yourself whether you have a
> left or a right page. Then put the time info in a table together with
> the workshop info, either on the left or right side.
>
> I haven't tried but you may be able to emulate side floats using
> absolutely positioned block-containers with the latest FOP release.
>
>   
>> - If yes, what do I have to read, to get it working
>> thanks in advance,  Hann*
>> *
>>     
>
> Good luck!
>
> Jeremias Maerki
>
>
> ---------------------------------------------------------------------
> To unsubscribe, e-mail: fop-users-unsubscribe (at) xmlgraphics.apache.org
> For additional commands, e-mail: fop-users-help (at) xmlgraphics.apache.org
>
>
>   

---------------------------------------------------------------------
To unsubscribe, e-mail: fop-users-unsubscribe (at) xmlgraphics.apache.org
For additional commands, e-mail: fop-users-help (at) xmlgraphics.apache.org
