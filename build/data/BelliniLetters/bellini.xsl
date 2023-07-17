<?xml version="1.0" encoding="UTF-8" ?> 
<xsl:stylesheet version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:mei="https://music-encoding.org/schema/4.0.1/mei-all.rng"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="tei">
    
    <xsl:strip-space elements="tei:choice tei:expan tei:abbr" />

    <xsl:output 
        method="xml" 
        version="1.0" 
        omit-xml-declaration="no" 
        encoding="UTF-8" 
        indent="no"/>
    


    <!--xsl:strip-space elements="tei:lb"/--> <!--non ho risolto nulla -->
    
    <xsl:template match="@*|node()">
        <xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
    </xsl:template>
    
    <!--xsl:template match="text()">
        <xsl:value-of select="normalized-space()" />
    </xsl:template-->
 
    <xsl:template match="tei:teiHeader">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:facsimile">
        
        <xsl:variable name="idno" select="//tei:idno[@type='inventory']"/>
        <xsl:variable name="id" select="concat ($idno, '_facsimile')"/>
        <xsl:element  name="facsimile" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="xml:id">
                <xsl:copy-of select="$id"/>
            </xsl:attribute>   
            <!--l'attributo xml:id è stato aggiunto perchè serve per creare il corpus finale usando xinclude-->
            <xsl:apply-templates/>
        </xsl:element>

    </xsl:template>

    <xsl:template match="tei:surface">
        
        <!-- variabili per creare l'elemento surface -->
        <xsl:variable name="idno" select="//tei:idno[@type='inventory']"/>
        <xsl:variable name="n" select="@n"/>
        <xsl:variable name="newN" select="concat ($idno, '.', $n)"/>
        <xsl:variable name="id" select="@xml:id"/>
        <xsl:variable name="pb" select="//tei:body//tei:pb"/>
        

        <xsl:element  name="surface" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="n">
                <xsl:copy-of select=" $newN"/>
            </xsl:attribute>
            
            <xsl:attribute name="xml:id">
               <xsl:copy-of select="$id"/>
           </xsl:attribute> 
            
            <xsl:attribute name="corresp">
               <xsl:for-each select="$pb">
                   <xsl:if test="@n=$n">
                       <!-- se il valore dell'attributo n di pb è uguale al valore dell'attributo n di surface -->
                       <xsl:variable name="facs" select="@xml:id"/>
                       <xsl:variable name="newfacs" select="concat('#', $facs)"/>   
                        <xsl:value-of select="$newfacs"/>
                   </xsl:if>
               </xsl:for-each>
           </xsl:attribute> 
            
            <xsl:apply-templates select="tei:graphic"/> 
            
            <!-- variabili per creare gli elementi zone ed ottenere l'allineamento -->
            
            <xsl:variable name="width" select="tei:graphic/@width"/>
            <xsl:variable name="widthnew" select="substring-before($width, 'px')"/>
            <!-- la misura di width a cui levo la stringa px -->
        
            <xsl:variable name="coeff" select="number(723)"/>
            <!-- il coefficiente costante-->
            <xsl:variable name="rapp" select="number($widthnew) div $coeff"/>
            <!-- il rapporto -->
        
        
            <!-- per ogni zona seleziono le variabili di interesse-->                
            <xsl:for-each select="tei:zone ">
            
                <xsl:variable name="id" select="@xml:id"/>
                <xsl:variable name="corresp" select="concat ('#', $id, 'h')"/>
                <xsl:variable name="rendition" select="lower-case(@rendition)"/>
                
                <xsl:choose>
                        <xsl:when test="@ulx">
                            <xsl:variable name="ulx" select="@ulx"/>
                            <xsl:variable name="uly" select="@uly"/>
                            <xsl:variable name="lrx" select="@lrx"/>
                            <xsl:variable name="lry" select="@lry"/>
                            <xsl:element  name="zone" namespace="http://www.tei-c.org/ns/1.0">
                            

                            <xsl:attribute name="ulx">      
                                <xsl:variable name="result" select="$ulx div $rapp"/>
                                <xsl:value-of select="format-number($result, '#.00')"/>
                            </xsl:attribute>
                                    
                            <xsl:attribute name="uly">
                                <xsl:variable name="result" select="$uly div $rapp"/>
                                <xsl:value-of select="format-number($result, '#.00')"/>
                            </xsl:attribute>
                                    
                            <xsl:attribute name="lrx">
                                <xsl:variable name="result" select="$lrx div $rapp"/>
                                <xsl:value-of select="format-number($result, '#.00')"/>
                            </xsl:attribute>
                                    
                            <xsl:attribute name="lry">
                                <xsl:variable name="result" select="$lry div $rapp"/>
                                <xsl:value-of select="format-number($result, '#.00')"/>
                            </xsl:attribute>
                                    
                            <xsl:attribute name="rendition">
                                <xsl:choose>
                                    <xsl:when test="$rendition='hotspot'">
                                        <xsl:text>HotSpot</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$rendition"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                                    
                            <xsl:attribute name="xml:id">
                                <xsl:value-of select="$id"/>
                            </xsl:attribute>
                        
                            <xsl:if test="$rendition='hotspot'">
                                <!-- per tutti gli elementi zone che hanno come valore dell'attributo rendition HotSpot eseguo le seguenti regole: -->
                                <xsl:attribute name="corresp"> 
                                    <!-- inserisce l'attributo corresp in fondo dentro zone  mi serve per poter visualizzare gli hotspot-->
                                    <xsl:value-of select="$corresp"/>
                                </xsl:attribute>
                                        
                                <xsl:attribute name="start"> 
                                    <!-- inserisce l'attributo corresp in fondo dentro zone -->
                                    <xsl:value-of select="$corresp"/>
                                </xsl:attribute>
                            </xsl:if>
                        
                        </xsl:element> <!-- fine elemnto zone -->
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="points" select="@points" />
                            <!-- points="466,460 460,568 82,566 60,2378 1602,2370 1580,482" -->
                            <xsl:variable name="xpoints" select="tokenize($points,',[0-9]+')" />
                            <xsl:variable name="ypoints" select="tokenize($points,'[0-9]+,')" />
                           
                            <xsl:variable name="xpointseq" as="xs:integer *">
                                <xsl:for-each select="$xpoints">
                                    <xsl:if test="current()!='' and current()!=' '">
                                        <xsl:sequence select="xs:integer(round(number(.)))"/>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:variable>

                            <xsl:variable name="ypointseq" as="xs:integer *">
                                <xsl:for-each select="$ypoints">
                                    <xsl:if test="current()!='' and current()!=' '">
                                        <xsl:sequence select="xs:integer(round(number(.)))"/>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:variable>
                            
                            <xsl:variable name="ulx" select="sort($xpointseq)[1]"/>
                            <xsl:variable name="uly" select="sort($ypointseq)[1]"/>
                            <xsl:variable name="lrx" select="sort($xpointseq)[last()]"/>
                            <xsl:variable name="lry" select="sort($ypointseq)[last()]"/>
                           
                            <xsl:element  name="zone" namespace="http://www.tei-c.org/ns/1.0">
                            

                                <xsl:attribute name="ulx">      
                                    <xsl:variable name="result" select="$ulx div $rapp"/>
                                    <xsl:value-of select="format-number($result, '#.00')"/>
                                </xsl:attribute>
                                        
                                <xsl:attribute name="uly">
                                    <xsl:variable name="result" select="$uly div $rapp"/>
                                    <xsl:value-of select="format-number($result, '#.00')"/>
                                </xsl:attribute>
                                        
                                <xsl:attribute name="lrx">
                                    <xsl:variable name="result" select="$lrx div $rapp"/>
                                    <xsl:value-of select="format-number($result, '#.00')"/>
                                </xsl:attribute>
                                        
                                <xsl:attribute name="lry">
                                    <xsl:variable name="result" select="$lry div $rapp"/>
                                    <xsl:value-of select="format-number($result, '#.00')"/>
                                </xsl:attribute>
                                        
                                <xsl:attribute name="rendition">
                                    <xsl:choose>
                                        <xsl:when test="$rendition='hotspot'">
                                            <xsl:text>HotSpot</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$rendition"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                                        
                                <xsl:attribute name="xml:id">
                                    <xsl:value-of select="$id"/>
                                </xsl:attribute>
                            
                                <xsl:if test="$rendition='hotspot'">
                                    <!-- per tutti gli elementi zone che hanno come valore dell'attributo rendition HotSpot eseguo le seguenti regole: -->
                                    <xsl:attribute name="corresp"> 
                                        <!-- inserisce l'attributo corresp in fondo dentro zone  mi serve per poter visualizzare gli hotspot-->
                                        <xsl:value-of select="$corresp"/>
                                    </xsl:attribute>
                                            
                                    <xsl:attribute name="start"> 
                                        <!-- inserisce l'attributo corresp in fondo dentro zone -->
                                        <xsl:value-of select="$corresp"/>
                                    </xsl:attribute>
                                </xsl:if>
                            
                            </xsl:element> <!-- fine elemnto zone -->
                        </xsl:otherwise>
                    </xsl:choose>
                            
                <!-- ricreo tutti gli elemento zone con le nuove coordinate ricalcolate per l'allineamento delle righe su evt -->
                
                
            </xsl:for-each>
            
            
            
            <!-- VISTA LA PRESENZA DI ELEMENTI ZONE ANNIDATI NELLE LETTERE LL1.14, LL1.13.II E LL1.34 ANDREMO A PRENDERE ANCHE QUESTI ELEMENTI ZONE FIGLI 
                IN PARTICOLARE LA LETTERA LL1.13.II NELLA PRIMA PAGINA NON HA ELEMENTI ZONE ANNIDATI MENTRE NELLA SECONDA SI PERCIò HO DECISO DI FARE QUESTA SELEZIONE GENERICA
                SENZA SPECIFICA SE //tei:idno[@type='inventory']='LL1.34.I' ETC E COSì VIA , SEMPLIFICANDO COSì IL CODICE -->
            
  

            <xsl:if test="exists(tei:zone/tei:zone)">
                
                <xsl:for-each select="tei:zone/tei:zone">
                    <xsl:variable name="id" select="@xml:id"/>
                    <xsl:variable name="corresp" select="concat ('#', $id, 'h')"/>
                    <xsl:variable name="rendition" select="lower-case(@rendition)"/>
                    
                    <xsl:choose>
                        <xsl:when test="@ulx">
                            <xsl:variable name="ulx" select="@ulx"/>
                            <xsl:variable name="uly" select="@uly"/>
                            <xsl:variable name="lrx" select="@lrx"/>
                            <xsl:variable name="lry" select="@lry"/>
                             <!-- ricreo tutti gli elemento zone con le nuove coordinate ricalcolate per l'allineamento delle righe su evt -->
                                <xsl:element  name="zone" namespace="http://www.tei-c.org/ns/1.0">
                                    
                                <xsl:attribute name="ulx">      
                                    <xsl:variable name="result" select="$ulx div $rapp"/>
                                    <xsl:value-of select="format-number($result, '#.00')"/>
                                </xsl:attribute>
                                
                                <xsl:attribute name="uly">
                                    <xsl:variable name="result" select="$uly div $rapp"/>
                                    <xsl:value-of select="format-number($result, '#.00')"/>
                                </xsl:attribute>
                                
                                <xsl:attribute name="lrx">
                                    <xsl:variable name="result" select="$lrx div $rapp"/>
                                    <xsl:value-of select="format-number($result, '#.00')"/>
                                </xsl:attribute>
                                
                                <xsl:attribute name="lry">
                                    <xsl:variable name="result" select="$lry div $rapp"/>
                                    <xsl:value-of select="format-number($result, '#.00')"/>
                                </xsl:attribute>
                                
                                <xsl:attribute name="rendition">
                                    <xsl:choose>
                                        <xsl:when test="$rendition='hotspot'">
                                            <xsl:text>HotSpot</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$rendition"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                                
                                <xsl:attribute name="xml:id">
                                    <xsl:value-of select="$id"/>
                                </xsl:attribute>
                                
                                <xsl:if test="$rendition='hotspot'">
                                    <!-- per tutti gli elementi zone che hanno come valore dell'attributo rendition HotSpot eseguo le seguenti regole: -->
                                    <xsl:attribute name="corresp"> 
                                        <!-- inserisce l'attributo corresp in fondo dentro zone  mi serve per poter visualizzare gli hotspot-->
                                        <xsl:value-of select="$corresp"/>
                                    </xsl:attribute>
                                    
                                    <xsl:attribute name="start"> 
                                        <!-- inserisce l'attributo corresp in fondo dentro zone -->
                                        <xsl:value-of select="$corresp"/>
                                    </xsl:attribute>
                                </xsl:if>
                                
                            </xsl:element> <!-- fine elemnto zone -->
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="points" select="@points" />
                            <xsl:variable name="xpoints" select="tokenize($points,',[0-9]+')" />
                            <xsl:variable name="ypoints" select="tokenize($points,'[0-9]+,')" />
                            

                            <xsl:variable name="xpointseq" as="xs:integer *">
                                <xsl:for-each select="$xpoints">
                                    <xsl:if test="current()!='' and current()!=' '">
                                        <xsl:sequence select="xs:integer(round(number(.)))"/>
                                    </xsl:if>
                                </xsl:for-each> 
                            </xsl:variable>

                            <xsl:variable name="ypointseq" as="xs:integer *">
                                <xsl:for-each select="$ypoints">
                                    <xsl:if test="current()!='' and current()!=' '">
                                        <xsl:sequence select="xs:integer(round(number(.)))"/>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:variable>                            

                            <xsl:variable name="ulx" select="sort($xpointseq)[1]"/>
                            <xsl:variable name="uly" select="sort($ypointseq)[1]"/>
                            <xsl:variable name="lrx" select="sort($xpointseq)[last()]"/>
                            <xsl:variable name="lry" select="sort($ypointseq)[last()]"/>

                                <!-- ricreo tutti gli elemento zone con le nuove coordinate ricalcolate per l'allineamento delle righe su evt -->
                                <xsl:element  name="zone" namespace="http://www.tei-c.org/ns/1.0">
                                    
                                <xsl:attribute name="ulx">      
                                    <xsl:variable name="result" select="$ulx div $rapp"/>
                                    <xsl:value-of select="format-number($result, '#.00')"/>
                                </xsl:attribute>
                                
                                <xsl:attribute name="uly">
                                    <xsl:variable name="result" select="$uly div $rapp"/>
                                    <xsl:value-of select="format-number($result, '#.00')"/>
                                </xsl:attribute>
                                
                                <xsl:attribute name="lrx">
                                    <xsl:variable name="result" select="$lrx div $rapp"/>
                                    <xsl:value-of select="format-number($result, '#.00')"/>
                                </xsl:attribute>
                                
                                <xsl:attribute name="lry">
                                    <xsl:variable name="result" select="$lry div $rapp"/>
                                    <xsl:value-of select="format-number($result, '#.00')"/>
                                </xsl:attribute>
                                
                                <xsl:attribute name="rendition">
                                    <xsl:choose>
                                        <xsl:when test="$rendition='hotspot'">
                                            <xsl:text>HotSpot</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$rendition"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                                
                                <xsl:attribute name="xml:id">
                                    <xsl:value-of select="$id"/>
                                </xsl:attribute>
                                
                                <xsl:if test="$rendition='hotspot'">
                                    <!-- per tutti gli elementi zone che hanno come valore dell'attributo rendition HotSpot eseguo le seguenti regole: -->
                                    <xsl:attribute name="corresp"> 
                                        <!-- inserisce l'attributo corresp in fondo dentro zone  mi serve per poter visualizzare gli hotspot-->
                                        <xsl:value-of select="$corresp"/>
                                    </xsl:attribute>
                                    
                                    <xsl:attribute name="start"> 
                                        <!-- inserisce l'attributo corresp in fondo dentro zone -->
                                        <xsl:value-of select="$corresp"/>
                                    </xsl:attribute>
                                </xsl:if>
                                
                            </xsl:element> <!-- fine elemnto zone -->
                        </xsl:otherwise>
                    </xsl:choose>
                    
                    
                    
                    
                    
                </xsl:for-each>
                
            </xsl:if>
            
              
        </xsl:element> <!-- fine elemnto surface -->

    </xsl:template> 

    <xsl:template match="tei:graphic">

        <xsl:variable name="url" select="@url"/>
        <xsl:variable name="urlN" select="substring-before($url, '.jpg')"/>
        <xsl:variable name="urlN2" select="translate($urlN, '.', '-')"/>
        <xsl:variable name="idno" select="//tei:idno[@type='inventory']" />
        <xsl:variable name="newUrl" select="concat('data/test-img/', $idno, '/',$urlN2,'.dzi')"/>
        <xsl:variable name="width" select="@width"/>
        <xsl:variable name="height" select="@height"/>
        
        <xsl:element name="graphic" namespace="http://www.tei-c.org/ns/1.0">
            
            <xsl:variable name="num" select="substring-after(//tei:idno[@type='inventory'], 'LL1.')"/>
            <xsl:variable name="numnew" select="substring-before($num, '.')"/>

            <xsl:attribute name="url">
                <xsl:value-of select="$newUrl"/>
            </xsl:attribute>
       
            <xsl:attribute name="width">
                <xsl:value-of select="$width"/>
            </xsl:attribute>
            
            <xsl:attribute name="height">
                <xsl:value-of select="$height"/>
            </xsl:attribute>
        </xsl:element>
        
        <xsl:apply-templates />
     
    </xsl:template>

    <xsl:template match="tei:msDesc"> 
        <!--Template per l'elemento msDesc -->
        <xsl:copy> 
            <xsl:apply-templates select="tei:msIdentifier"/>
            <!--Template per l'elemento msIdentifier -->
            
            <xsl:element name="msContents" namespace="http://www.tei-c.org/ns/1.0">
                <!--Creazione dell'elemento msContents in cui saranno inseriti gli elementi msitem, uno per ogni lettera -->
                
                <xsl:element name="msItem" namespace="http://www.tei-c.org/ns/1.0"> 
                    <xsl:attribute name="xml:id">
                        <xsl:text>msItem-</xsl:text>
                        <xsl:value-of select="//tei:idno[@type='inventory']"/>
                    </xsl:attribute>
                    
                    <!--Creazione dell'elemento msitem in cui saranno inserite tutte le info riguardanti ogni lettera prese da sourceDesc-->
                    
                        <!--Idno missiva -->
                        <xsl:element name="idno" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:attribute name="type" >inventory</xsl:attribute> 
                            <xsl:value-of select="//tei:idno[@type='inventory']"/>
                        </xsl:element>
                        
                        <!-- Titolo -->
                        <xsl:element name="title" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:value-of select="//tei:titleStmt/tei:title"/>
                        </xsl:element>
                        
                        <!--Bibliografia-->
                        <xsl:element name="bibl" namespace="http://www.tei-c.org/ns/1.0">
                            <!--Creazione dell'elemento bibl in cui inserire le info rigardanti la bibliografia di Seminara -->
                            <xsl:element name="fw" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:text>Bibliografia </xsl:text>
                            </xsl:element>
                            <!-- <xsl:element name="author" namespace="http://www.tei-c.org/ns/1.0">-->
                            <xsl:text>Seminara, 2017, </xsl:text>
                            <!--</xsl:element> 
                        <xsl:element name="date" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:attribute name="when" >2017</xsl:attribute> 
                            <xsl:text>2017</xsl:text>
                        </xsl:element>  --> 
                            
                            
                            <xsl:element name="citedRange" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:attribute name="source">#Seminara2017</xsl:attribute> 
                                <xsl:attribute name="resp">#GS</xsl:attribute> 
                                <xsl:attribute name="ana">
                                    <xsl:value-of select="//tei:sourceDesc//tei:bibl/@ana"/>
                                </xsl:attribute> 
                                <xsl:element name="locus" namespace="http://www.tei-c.org/ns/1.0">
                                    <xsl:attribute name="from">
                                        <xsl:value-of select="//tei:sourceDesc//tei:bibl/tei:citedRange/@from"/>
                                    </xsl:attribute> 
                                    <xsl:attribute name="to" >
                                        <xsl:value-of select="//tei:sourceDesc//tei:bibl/tei:citedRange/@to"/>
                                    </xsl:attribute>
                                    <xsl:text>n.</xsl:text>
                                    <xsl:text> </xsl:text>
                                    <xsl:value-of select="//tei:sourceDesc//tei:bibl/@ana"/>
                                    <xsl:text>,</xsl:text> 
                                    <xsl:text> </xsl:text> 
                                    <xsl:text>p.</xsl:text>
                                    <xsl:text> </xsl:text>
                                    <xsl:value-of select="//tei:sourceDesc//tei:bibl/tei:citedRange"/>
                                    <xsl:text>.</xsl:text> 
                                </xsl:element> 
                            </xsl:element> 
                        </xsl:element> 
                        <xsl:variable name="biblio" select="//tei:back//tei:div[@type='bibliography']//tei:listBibl//tei:bibl//tei:ref//tei:bibl" /> 
                        <xsl:variable name="bibl2" select="//tei:bibl//tei:ref//tei:bibl" /> 
                        <xsl:variable name="author" select="//tei:bibl//tei:ref//tei:bibl//tei:author" /> 
                        <xsl:variable name="date" select="//tei:bibl//tei:ref//tei:bibl//tei:date" /> 
                        <xsl:variable name="pag" select="//tei:bibl//tei:ref//tei:bibl//tei:citedRange" /> 
                        
                        <xsl:if test="exists($author[1])">
                            <xsl:element name="bibl" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:value-of select="$author[1]"/>
                                <xsl:text>, </xsl:text>
                                <xsl:value-of select="$date[1]"/>
                                <xsl:text>, p. </xsl:text>
                                <xsl:value-of select="$pag[1]"/>
                                <xsl:text>. </xsl:text>
                            </xsl:element>
                        </xsl:if>
                        
                        <xsl:if test="exists($author[2])">
                            <xsl:element name="bibl" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:value-of select="$author[2]"/>
                                <xsl:text>, </xsl:text>
                                <xsl:value-of select="$date[2]"/>
                                <xsl:text>, p. </xsl:text>
                                <xsl:value-of select="$pag[2]"/>
                                <xsl:text>. </xsl:text>
                            </xsl:element>
                        </xsl:if>
                        
                        <xsl:if test="exists($author[3])">
                            <xsl:element name="bibl" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:value-of select="$author[3]"/>
                                <xsl:text>, </xsl:text>
                                <xsl:value-of select="$date[3]"/>
                                <xsl:text>, p. </xsl:text>
                                <xsl:value-of select="$pag[3]"/>
                                <xsl:text>. </xsl:text>
                            </xsl:element>
                        </xsl:if>
                        
                        <xsl:if test="exists($author[4])">
                            <xsl:element name="bibl" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:value-of select="$author[4]"/>
                                <xsl:text>, </xsl:text>
                                <xsl:value-of select="$date[4]"/>
                                <xsl:text>, p. </xsl:text>
                                <xsl:value-of select="$pag[4]"/>
                                <xsl:text>. </xsl:text>
                            </xsl:element>
                        </xsl:if>
                        
                        
                        <!--Creazione dell'elemento Incipit -->
                        <xsl:element name="incipit" namespace="http://www.tei-c.org/ns/1.0" >
                            <!--intestazione-->
                            <xsl:element name="fw" namespace="http://www.tei-c.org/ns/1.0">   
                                <xsl:text>Incipit </xsl:text>
                            </xsl:element>
                            <!-- Copia il primo pragrafo e il saluto per riportarlo nell'elemento Incipit-->
                            
                            <xsl:variable name="s1" select="//tei:s[@n='s_01']"/>
                            <xsl:variable name="salute" select="//tei:div[@type='letter-body']//tei:salute"/>
                            
                            
                            <!-- se esiste s1 copia solo s1 altrimenti se s1 non è presente copia salute se presente altrmenti restituisce il testo che non è presente-->
                            
                            <xsl:choose>
                                
                                <xsl:when test="exists($s1)">
                                    <!--<xsl:value-of select="$s1"/>--> <!-- per riportare solo il testo -->
                                                                        
                                        <xsl:apply-templates select="$s1" mode="sciogliabbr"/> <!--per riportare invece tutta la porzione di codice -->
                                                                           
                                </xsl:when>
                                
                                <xsl:otherwise>
                                    
                                    <xsl:choose>
                                        <xsl:when test="exists($salute)"> 
                                            <!--<xsl:value-of select="$salute" />  --><!-- per riportare solo il testo -->
                                            <xsl:apply-templates select="$salute"  mode="sciogliabbr"/> <!--per riportare invece tutta la porzione di codice -->
                                        </xsl:when>
                                        
                                        <xsl:otherwise>
                                            <xsl:text>Incipit non presente</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    
                                </xsl:otherwise>
                            </xsl:choose>
                            
                        </xsl:element>
                    
                        
                        <!--Creazione dell'elemento Explicit -->
                        <!-- usare @type in element con valore "normalizedString" -->
                        <xsl:element name="explicit" namespace="http://www.tei-c.org/ns/1.0">
                            
                            <xsl:element name="fw" namespace="http://www.tei-c.org/ns/1.0">   
                                <xsl:text>Explicit </xsl:text>
                            </xsl:element>  
                            
                            <xsl:variable name="closer" select="//tei:div[@type='closer']"/>
                            
                            <xsl:choose>
                                <!-- li copia solo se sono presenti -->
                                <xsl:when test="exists($closer)">
                                    <!-- <xsl:value-of select="$closer"/>--> <!-- per riportare solo il testo -->
                                    <xsl:apply-templates select="$closer" mode="sciogliabbr" /><!-- per riportare invece tutta la porzione di codice mode pop up è er riportare anche i collegamenti alle entità  -->
                                </xsl:when>
                                
                                <xsl:otherwise>
                                    <xsl:text>Esplicit non presente</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                            
                        </xsl:element>
                </xsl:element>
                
            </xsl:element>
            
        </xsl:copy>
        
    </xsl:template>
 
    <xsl:template match="tei:front">
     <!--Template per l'elemento front in cui verranno riportate tutte le informazioni di ogni missiva-->   
        <xsl:element name="front" namespace="http://www.tei-c.org/ns/1.0">
            
        <xsl:element name="head" namespace="http://www.tei-c.org/ns/1.0">
            Informazioni sulla lettera
        </xsl:element>

            <!--Titolo-->
            <xsl:element name="div" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:attribute name="type">Title</xsl:attribute> 
                    <xsl:element name="fw" namespace="http://www.tei-c.org/ns/1.0"> 
                        Titolo
                    </xsl:element>
                    <xsl:element name="p" namespace="http://www.tei-c.org/ns/1.0"> 
                        <xsl:copy-of select="//tei:titleStmt//tei:title/node()"/>
                    </xsl:element>
            </xsl:element> <!-- fine Titolo -->
            
            <!--Bibliografia Seminara -->
            <xsl:element name="div" namespace="http://www.tei-c.org/ns/1.0">
                <!--Creazione elemento div in cui riportare la bibliografia-->
                <xsl:attribute name="type">Bibliography</xsl:attribute> 
                    <xsl:element name="fw" namespace="http://www.tei-c.org/ns/1.0">
                        Bibliografia 
                    </xsl:element>
                    <xsl:element name="p" namespace="http://www.tei-c.org/ns/1.0"> 
                        <xsl:text>
                            Seminara 2017, n. 
                        </xsl:text>
                        <xsl:value-of select="//tei:sourceDesc//tei:bibl/@ana"/>
                        <xsl:text> </xsl:text> 
                        <xsl:text> p. </xsl:text>
                      <xsl:value-of select="//tei:sourceDesc//tei:bibl/tei:citedRange"/>
                    </xsl:element>
            </xsl:element> <!-- fine Bibliografia -->

            <!--Note -->
            <xsl:variable name="noteGeneriche" select="//tei:msItem/tei:note"/>
            <xsl:if test="exists($noteGeneriche)">
                <xsl:element name="div" namespace="http://www.tei-c.org/ns/1.0"> <!-- Note -->
                <!--Creazione elemento div in cui riportare le note -->
                <xsl:attribute name="type">note</xsl:attribute>
                    <xsl:element name="fw" namespace="http://www.tei-c.org/ns/1.0">
                        Note
                    </xsl:element>
                    <xsl:element name="p" namespace="http://www.tei-c.org/ns/1.0"> 
                        <xsl:copy-of select="//tei:msItem/tei:note/node()"/>
                    </xsl:element>
                </xsl:element>
            </xsl:if>

            <!--Lingua -->
            <xsl:element name="div" namespace="http://www.tei-c.org/ns/1.0"> <!-- Lingua -->
                <!--Creazione elemento div in cui riportare la lingua-->
                <xsl:attribute name="type">language</xsl:attribute>
                <xsl:element name="fw" namespace="http://www.tei-c.org/ns/1.0">
                    Lingua  
                </xsl:element>
                <xsl:element name="p" namespace="http://www.tei-c.org/ns/1.0"> 
                    <xsl:copy-of select="//tei:msItem/tei:textLang/node()"/>
                </xsl:element>
            </xsl:element> <!-- fine lingua -->

            <!--Collocazione -->
            <xsl:element name="div" namespace="http://www.tei-c.org/ns/1.0">
                <!--Creazione elemento div in cui riportare la collocazione-->
                <xsl:attribute name="type">Collocation</xsl:attribute>
                <!--xsl:element name="p" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:element name="fw" namespace="http://www.tei-c.org/ns/1.0">
                        Collocazione 
                    </xsl:element>
                    <xsl:value-of select="//tei:msIdentifier/tei:settlement"/>
                    <xsl:text> (</xsl:text>
                    <xsl:value-of select="//tei:msIdentifier/tei:country"/>
                    <xsl:text>)</xsl:text>
                    <xsl:text> - </xsl:text>
                    <xsl:value-of select="//tei:msIdentifier/tei:repository/node()"/>
                </xsl:element-->
                <!--xsl:element name="p" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:value-of select="//tei:msIdentifier//tei:idno[@type='collocation']"/>
                </xsl:element-->
                
                <!--Idno -->
                <xsl:element name="p" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:element name="fw" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:text>Segnatura </xsl:text>
                    </xsl:element>
                    <xsl:text>I-CATm, </xsl:text><xsl:value-of select="//tei:msIdentifier/tei:idno[@type='inventory']"/>
                </xsl:element>

            </xsl:element> <!-- fine collocazione -->
            
            <!--Descrizione fisica-->
            <xsl:element name="div" namespace="http://www.tei-c.org/ns/1.0">
                <!--Creazione elemento div in cui riportare la descrizione fisica-->
                <xsl:attribute name="type">desc</xsl:attribute>
                <xsl:element name="head" namespace="http://www.tei-c.org/ns/1.0">
                    Descrizione del supporto 
                </xsl:element>
                <!--Materiale-->
                <xsl:element name="p" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:element name="fw" namespace="http://www.tei-c.org/ns/1.0">   
                        <xsl:text>
                            Carta
                        </xsl:text>
                    </xsl:element>
                    <xsl:value-of select="//tei:material" /> 
                </xsl:element>
                
                <xsl:element name="p" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:element name="fw" namespace="http://www.tei-c.org/ns/1.0">  
                        <xsl:text>
                            Numero di carte 
                        </xsl:text>
                    </xsl:element>
                    <xsl:value-of select="//tei:extent/tei:measure"/>
                </xsl:element>
                
                <!--Dimensioni-->
                <xsl:element name="p" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:element name="fw" namespace="http://www.tei-c.org/ns/1.0">  
                        <xsl:text>Dimensioni </xsl:text>
                    </xsl:element>
                    <xsl:value-of select="//tei:height"/><xsl:text>x</xsl:text><xsl:value-of select="//tei:width"/>
                    <xsl:element name="unit" namespace="http://www.tei-c.org/ns/1.0">  
                        mm
                    </xsl:element>
                </xsl:element>
                
                <!--Watermark-->
                <xsl:element name="p" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:element name="fw" namespace="http://www.tei-c.org/ns/1.0">  
                        <xsl:text>
                            Watermark
                        </xsl:text>
                    </xsl:element>
                    
                    <xsl:variable name="watermark" select="//tei:watermark"/>
                    
                    <xsl:if test="exists($watermark)">
                        <xsl:value-of select="$watermark" /> 
                    </xsl:if>
                    
                    <!--Se invece non è presente o ha valore uguale a unknow e sconosciuta o sconosciuto riporta la scritta Non presente -->
                    <xsl:if test="empty($watermark)">
                        Non presente
                    </xsl:if>
                    
                    
                </xsl:element>
                
                <!--Timbri-->
                <xsl:element name="p" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:element name="fw" namespace="http://www.tei-c.org/ns/1.0">  
                        <xsl:text>
                            Timbri
                        </xsl:text>
                    </xsl:element>
                    <xsl:value-of select="//tei:support/tei:stamp" />  
                </xsl:element>
                
                <xsl:element name="p" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:value-of select="//tei:support/tei:p" />  
                </xsl:element>
                
            </xsl:element> <!--fine descfisica -->
            
            <!--Piegatura -->
            <xsl:element name="div" namespace="http://www.tei-c.org/ns/1.0"> 
                <!--Creazione elemento div in cui riportare la piegatura-->
                <xsl:attribute name="type">piegatura</xsl:attribute>
                <xsl:element name="p" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:element name="fw" namespace="http://www.tei-c.org/ns/1.0">
                    Piegatura e disposizione del testo
                </xsl:element>
                <xsl:value-of select="//tei:collation"/>
                </xsl:element>
            </xsl:element>
            
            <xsl:element name="div" namespace="http://www.tei-c.org/ns/1.0">
                <!--Creazione elemento div in cui riportare le condizioni fisiche-->
                <xsl:attribute name="type">condFisica</xsl:attribute>
                <xsl:element name="p" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:element name="fw" namespace="http://www.tei-c.org/ns/1.0">
                    Condizioni fisiche 
                </xsl:element>
                <xsl:value-of select="//tei:condition"/>
                </xsl:element>
            </xsl:element>
            
            <xsl:element name="div" namespace="http://www.tei-c.org/ns/1.0">
                <!--Creazione elemento div in cui riportare le mani -->
                <xsl:attribute name="type">handnote</xsl:attribute>
                <xsl:element name="p" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:element name="fw" namespace="http://www.tei-c.org/ns/1.0">
                    Descrizione delle mani 
                </xsl:element>
                <xsl:value-of select="//tei:handNote"/>
                </xsl:element>
            </xsl:element>
            
            <xsl:element name="div" namespace="http://www.tei-c.org/ns/1.0">
                <!--Creazione elemento div in cui riportare i sigilli-->
                <xsl:attribute name="type">sigilli</xsl:attribute>
                <xsl:element name="p" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:element name="fw" namespace="http://www.tei-c.org/ns/1.0">
                    Descrizione dei sigilli
                </xsl:element>
                    
                    <xsl:variable name="sigilli" select="normalize-space(//tei:sealDesc)"/>
                    
                    <xsl:if test="exists($sigilli)">
                        <xsl:value-of select="$sigilli" /> 
                    </xsl:if>
                    
                    <!--Se invece non è presente o ha valore uguale a unknow e sconosciuta o sconosciuto riporta la scritta Non presente -->
                    <xsl:if test="empty($sigilli)">
                        Non presenti
                    </xsl:if>  

                </xsl:element>
            </xsl:element>

            <xsl:element name="div" namespace="http://www.tei-c.org/ns/1.0">
                <!--Creazione elemento div in cui riportare le informazioni sulla corrispondenza: mittente, destinatario, luogo di spedizione e luogo di destinazione-->
                <xsl:attribute name="type">Corrispondence</xsl:attribute>
                <xsl:element name="head" namespace="http://www.tei-c.org/ns/1.0"> 
                Informazioni sulla Corrispondenza
                </xsl:element>
                <xsl:element name="p" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:element name="fw" namespace="http://www.tei-c.org/ns/1.0">  
                        <xsl:text>  
                            Mittente 
                        </xsl:text>
                    </xsl:element>
                    <xsl:value-of select="//tei:correspAction[@type='sent']/tei:persName"/>
                </xsl:element>
            
                <xsl:element name="p" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:element name="fw" namespace="http://www.tei-c.org/ns/1.0">  
                        <xsl:text> 
                            Luogo di spedizione 
                        </xsl:text>
                    </xsl:element>
                    
                    <xsl:variable name="luogosped" select="//tei:correspAction[@type='sent']/tei:placeName"/>

                    <!-- se il valore esiste e se non è uguale a unnknow lo riporta, usando la funzione exist che verifica che il campo non sia vuoto -->
                    <xsl:if test="exists($luogosped)">
                        <xsl:if test="$luogosped!='unknown'">
                            <!-- aggiunge  parentesi quadre se @cert="medium" o @cert="high" -->
                            <xsl:choose>
                                <xsl:when test="(contains(//tei:correspAction[@type='sent']/tei:placeName/@cert,'medium') or contains(//tei:correspAction[@type='sent']/tei:placeName/@cert,'high'))">
                                    <xsl:text>[</xsl:text>
                                    <xsl:value-of select="$luogosped"/>
                                    <xsl:text>]</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$luogosped"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                    </xsl:if>

                    <!--Se invece non è presente o ha valore uguale a unknow e sconosciuta o sconosciuto riporta la scritta Non presente -->
                    <xsl:if test="empty($luogosped)">
                        Non presente
                    </xsl:if>
                    
                    <xsl:if test="$luogosped='unknown'">
                        Non presente
                    </xsl:if>
                    
                    <xsl:if test="$luogosped='sconosciuta'">
                        Non presente
                    </xsl:if>
                    
                    <xsl:if test="$luogosped='sconosciuto'">
                        Non presente
                    </xsl:if>

                </xsl:element>
            
                <xsl:element name="p" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:element name="fw" namespace="http://www.tei-c.org/ns/1.0">  
                        <xsl:text> 
                            Data di spedizione 
                        </xsl:text>
                    </xsl:element>
                    <!-- se il valore esiste e se non è uguale a unnknow lo riporta, usando la funzione exist che verifica che il campo non sia vuoto -->
                    <xsl:variable name="datasped" select="//tei:correspAction[@type='sent']/tei:date"/>
                    <!-- aggiunge  parentesi quadre se @cert="medium" o "high" -->
                    <xsl:if test="exists($datasped)">
                        <xsl:if test="$datasped!='unknown'">
                            <xsl:choose>
                                <xsl:when test="(contains(//tei:correspAction[@type='sent']/tei:date/@cert,'medium') or contains(//tei:correspAction[@type='sent']/tei:date/@cert,'high') or contains(//tei:correspAction[@type='sent']/tei:date/tei:date/@cert,'medium') or contains(//tei:correspAction[@type='sent']/tei:date/tei:date/@cert,'high'))">
                                    <xsl:text>[</xsl:text>
                                    <xsl:value-of select="$datasped"/>
                                    <xsl:text>]</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$datasped"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                    </xsl:if>
                    <!--Se invece non è presente o ha valore uguale a unknow e sconosciuta o sconosciuto riporta la scritta Non presente -->
                    <xsl:if test="empty($datasped)">
                        Non presente
                    </xsl:if>
                    
                    <xsl:if test="$datasped='unknown'">
                        Non presente o sconosciuta
                    </xsl:if>
                    
                    <xsl:if test="$datasped='sconosciuta'">
                        Non presente
                    </xsl:if>
                    
                    <xsl:if test="$datasped='sconosciuto'">
                        Non presente
                    </xsl:if>
                    
                </xsl:element>
            
                <xsl:element name="p" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:element name="fw" namespace="http://www.tei-c.org/ns/1.0">  
                        <xsl:text> 
                            Destinatario
                        </xsl:text>
                    </xsl:element>
                    <!-- se il valore esiste e se non è uguale a unnknow lo riporta, usando la funzione exist che verifica che il campo non sia vuoto -->
                    <xsl:variable name="destinatario" select="//tei:correspAction[@type='received']/tei:persName"/>
                    <!-- aggiunge  parentesi quadre se @cert="medium" o @cert="high" -->
                    <xsl:if test="exists($destinatario)">
                        <xsl:if test="$destinatario!='unknown'">
                            <xsl:choose>
                                <xsl:when test="(contains(//tei:correspAction[@type='received']/tei:persName/@cert,'medium') or contains(//tei:correspAction[@type='received']/tei:persName/@cert,'high'))">
                                    <xsl:text>[</xsl:text>
                                    <xsl:value-of select="$destinatario"/>
                                    <xsl:text>]</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$destinatario"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                    </xsl:if>
                    <!--Se invece non è presente o ha valore uguale a unknow e sconosciuta o sconosciuto riporta la scritta Non presente -->
                    <xsl:if test="empty($destinatario)">
                        Non presente
                    </xsl:if>
                    
                    <xsl:if test="$destinatario='unknown'">
                        Non presente o sconosciuto
                    </xsl:if>
                    
                    <xsl:if test="$destinatario='sconosciuta'">
                        Non presente
                    </xsl:if>
                    
                    <xsl:if test="$destinatario='sconosciuto'">
                        Non presente
                    </xsl:if>
      
                </xsl:element>
            
                <xsl:element name="p" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:element name="fw" namespace="http://www.tei-c.org/ns/1.0">  
                        <xsl:text> 
                            Luogo di destinazione 
                        </xsl:text>
                    </xsl:element>
                    <!-- se il valore esiste e se non è uguale a unnknow lo riporta, usando la funzione exist che verifica che il campo non sia vuoto -->
                    <xsl:variable name="luogodest" select="//tei:correspAction[@type='received']/tei:placeName"/>
                    <!-- aggiunge  parentesi quadre se @cert="medium" o @cert="high" -->
                    <xsl:if test="exists($luogodest)">
                        <xsl:if test="$luogodest!='unknown'">
                            <xsl:choose>
                                <xsl:when test="(contains(//tei:correspAction[@type='received']/tei:placeName/@cert,'medium') or contains(//tei:correspAction[@type='received']/tei:placeName/@cert,'high'))">
                                    <xsl:text>[</xsl:text>
                                    <xsl:value-of select="$luogodest"/>
                                    <xsl:text>]</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$luogodest"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                    </xsl:if>
                    <!--Se invece non è presente o ha valore uguale a unknow e sconosciuta o sconosciuto riporta la scritta Non presente -->
                    <xsl:if test="empty($luogodest)">
                        Non presente
                    </xsl:if>
                    
                    <xsl:if test="$luogodest='unknown'">
                        Non presente o sconosciuto
                    </xsl:if>
                    
                    <xsl:if test="$luogodest='sconosciuta'">
                        Non presente
                    </xsl:if>
                    
                    <xsl:if test="$luogodest='sconosciuto'">
                        Non presente
                    </xsl:if>
                    
                    
                </xsl:element>
            
                <xsl:element name="p" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:element name="fw" namespace="http://www.tei-c.org/ns/1.0">  
                        <xsl:text> 
                            Data di destinazione
                        </xsl:text>
                    </xsl:element>
                    <!-- se il valore esiste e se non è uguale a unnknow lo riporta, usando la funzione exist che verifica che il campo non sia vuoto -->
                    <xsl:variable name="dataric" select="//tei:correspAction[@type='received']/tei:date"/>
                    <!-- aggiunge  parentesi quadre se @cert="medium" o "high" -->
                    <xsl:if test="exists($dataric)">
                        <xsl:if test="$dataric!='unknown'">
                            <xsl:choose>
                                <xsl:when test="(contains(//tei:correspAction[@type='received']/tei:date/@cert,'medium') or contains(//tei:correspAction[@type='received']/tei:date/@cert,'high') or contains(//tei:correspAction[@type='received']/tei:date/tei:date/@cert,'medium') or contains(//tei:correspAction[@type='received']/tei:date/tei:date/@cert,'high'))">
                                    <xsl:text>[</xsl:text>
                                    <xsl:value-of select="$dataric"/>
                                    <xsl:text>]</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$dataric"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                    </xsl:if>
                    <!--Se invece non è presente o ha valore uguale a unknow e sconosciuta o sconosciuto riporta la scritta Non presente -->
                    <xsl:if test="empty($dataric)">
                        Non presente
                    </xsl:if>
                    
                    <xsl:if test="$dataric='unknown'">
                        Non presente o sconosciuta
                    </xsl:if>
                    
                    <xsl:if test="$dataric='sconosciuta'">
                        Non presente
                    </xsl:if>
                    
                    <xsl:if test="$dataric='sconosciuto'">
                        Non presente
                    </xsl:if>
                    
                     
                </xsl:element>
                
            </xsl:element>
            
        </xsl:element>  
    </xsl:template>
    
    <xsl:template match="tei:text">
        <!--template per l'elemento text -->
        
        <!-- creazioni delle variabili utili -->
        <xsl:variable name="type" select="@type"/>
        <xsl:variable name="n" select="@n"/>
        <xsl:variable name="id" select="@xml:id"/>
        <xsl:variable name="id2" select="substring-after($id, 'LL')"/>
        <xsl:variable name="newN" select="$id2"/>
        
        
        <xsl:element  name="text" namespace="http://www.tei-c.org/ns/1.0">
         <!-- creazione dell'elemento text e ciò che appare in esso -->   
            <xsl:attribute name="type">
                <xsl:copy-of select="$type"/>
            </xsl:attribute> 
            
            <xsl:attribute name="n">
                <xsl:copy-of select="$newN"/>
            </xsl:attribute> 
            
            <xsl:attribute name="xml:id">
                <xsl:copy-of select="$id"/>
            </xsl:attribute> 
            
            <xsl:apply-templates/> 
            
        </xsl:element>
        
        
    </xsl:template>
    
    <xsl:template match="tei:pb">

        <!-- creazione delle variabili di tutti i dati di cui abbiamo bisogno per creare il nuovo elemento pb su evt-->
        <xsl:variable name="idno" select="//tei:idno[@type='inventory']"/>
        <xsl:variable name="id" select="@xml:id"/>
        <xsl:variable name="n" select="@n"/>
        <xsl:variable name="facs" select="@facs"/>
        <xsl:variable name="carta" select="substring-after($facs, 'folio_')"/>
        <xsl:variable name="newN" select="concat ($idno, '.', $carta)"/>
        <!-- funzione concat usata per concatenare le varie stringhe che servono per poter creare la stringa che compone il valore dell'attributo n -->
        <xsl:variable name="newidno" select="translate ($idno, '.', '-' )"/>
        <!-- funzione translate usata per sostituire il punto con il trattino per poter creare la stringa che compone il valore dell'attributo facs -->
        <xsl:variable name="newfacs" select="concat ('data/test-img/', $idno, '/', $newidno, '_000', $n, '.dzi')"/>
        <!-- funzione concat usata per concatenare le varie stringhe che servono per poter creare la stringa che compone il valore dell'attributo facs -->
        

        <xsl:element name="pb" namespace="http://www.tei-c.org/ns/1.0">

            <xsl:attribute name="n">
                <xsl:copy-of select="$newN"/>
            </xsl:attribute>
            
            <xsl:attribute name="xml:id">
                <xsl:copy-of select="$id"/>
            </xsl:attribute>

            <xsl:attribute name="facs">
                <xsl:copy-of select="$newfacs"/>
            </xsl:attribute>
            
        </xsl:element>
        
        <!-- Per mostrare il testo 'La facciata non presenta testo autografo di Bellini' -->

        <xsl:for-each select="//tei:surface[@xml:id=substring-after($facs,'#')]">
            <!--per ogni elemento surface -->
          
            <xsl:choose>
                <xsl:when test="//tei:idno[@type='inventory']='LL1.34.I' or //tei:idno[@type='inventory']='LL1.14' or //tei:idno[@type='inventory']='LL1.13.II'">
                    <xsl:choose>
                        <xsl:when test="exists(./tei:zone/tei:zone[@rendition='Line'])"></xsl:when>
                        <xsl:when test="exists(./tei:zone[@rendition='Line'])"></xsl:when>
                        <!-- solo nel caso in cui non esiste il valore di rendition = a line esegue l'inserimento del paragrafo che indica che non è presente testo autografo di Bellini -->
                        <xsl:otherwise>
                            <xsl:element name="div" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:attribute name="type">extratext</xsl:attribute>
                                <xsl:element name="p" namespace="http://www.tei-c.org/ns/1.0">
                                    La facciata non presenta testo autografo di Bellini relativo a questa lettera
                                </xsl:element>
                            </xsl:element>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="exists(./tei:zone[@rendition='Line'])"></xsl:when>
                        <!-- solo nel caso in cui non esiste il valore di rendition = a line esegue l'inserimento del paragrafo che indica che non è presente testo autografo di Bellini -->
                        <xsl:otherwise>
                            <xsl:element name="div" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:attribute name="type">extratext</xsl:attribute>
                                <xsl:element name="p" namespace="http://www.tei-c.org/ns/1.0">
                                    La facciata non presenta testo autografo di Bellini relativo a questa lettera
                                </xsl:element>
                            </xsl:element>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>

                
            </xsl:choose>
                
            
               
                
            
        </xsl:for-each>
            
          
    </xsl:template> 


    <xsl:template match="tei:text//tei:term">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
        <xsl:element name="note" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="type">comment</xsl:attribute>
            <xsl:attribute name="n">T</xsl:attribute>

            <!--xsl:variable name="term"><xsl:value-of select="current()/text()" /></xsl:variable-->
            <xsl:variable name="ref" select="@ref"/>
            <xsl:variable name="new" select="substring-after($ref, 'TEI-ListTerm.xml')"/>
            <!--Creazione della variabile 'new' a cui viene assegnato il valore ottenuto usando la funzione substring-after-->
            <xsl:variable name="listTerm" select="doc('lists/TEI-ListTerm.xml')//tei:item//tei:gloss/@target"/>
            <!--Creazione della variabile 'listTerm' a cui viene assegnato il valore che ha l'attributo target dell'elemento gloss 
                riportato nel file TEI-ListTerm.xml grazie all'utilizzo della funzione doc-->
            <xsl:element name="seg" namespace="http://www.tei-c.org/ns/1.0">
                [<xsl:value-of select="upper-case(translate(translate($new,'#',''),'_',' '))" />]
            </xsl:element>
            <xsl:if test="$listTerm">
                <xsl:apply-templates select="doc('lists/TEI-ListTerm.xml')//tei:item//tei:gloss[@xml:lang='it'][@target=$new]"/>
                <!-- Applica la regola se il valore dell'attributo target è uguale al valore della variabile new  -->
            </xsl:if>
            <xsl:element name="seg" namespace="http://www.tei-c.org/ns/1.0">
                (<xsl:value-of select="doc('lists/TEI-ListTerm.xml')//tei:item//tei:gloss[@xml:lang='it'][@target=$new]/@source" />)
            </xsl:element>

        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tei:rs">
        <xsl:variable name="ref" select="@ref"/>
        <xsl:variable name="type" select="@type"/>
        <xsl:variable name="role" select="@role"/>
        <xsl:choose>
            <xsl:when test="$type='person'">
                <xsl:element name="persName" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:if test="exists($ref)">
                    <xsl:attribute name="ref">
                        <xsl:value-of select="substring-after($ref, 'TEI-ListPerson.xml')"/>
                    </xsl:attribute> 
                </xsl:if>
                <xsl:if test="exists($type)">
                    <xsl:attribute name="type">
                        <xsl:value-of select="$type"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="exists($role)">
                    <xsl:attribute name="role">
                        <xsl:value-of select="$role"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:if test="exists($ref)">
                        <xsl:attribute name="ref">
                            <xsl:value-of select="substring-after($ref, 'TEI-ListPerson.xml')"/>
                        </xsl:attribute> 
                    </xsl:if>
                    <xsl:if test="exists($type)">
                        <xsl:attribute name="type">
                            <xsl:value-of select="$type"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="exists($role)">
                        <xsl:attribute name="role">
                            <xsl:value-of select="$role"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:text//tei:rs[@type='work']">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
        <xsl:element name="note" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="type">comment</xsl:attribute>
            <xsl:attribute name="n">O</xsl:attribute>
            <xsl:variable name="ref" select="@ref"/>
            <xsl:variable name="new" select="substring-after($ref, 'TEI-ListWork.xml#')"/>
            <xsl:variable name="listWork" select="doc('lists/TEI-ListWork.xml')//div//bibl/@xml:id"/>
            <!--Creazione della variabile 'listWork' a cui viene assegnato il valore che ha l'attributo xml:id dell'elemento bibl
                riportato nel file TEI-ListWork.xml grazie all'utilizzo della funzione doc-->
            
            <xsl:if test="$listWork">
                <xsl:element name="label" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="rend">bold</xsl:attribute>
                    <xsl:text >[Titolo]: </xsl:text>
                </xsl:element>
                <xsl:value-of select="doc('lists/TEI-ListWork.xml')//div//bibl[@xml:id=$new]/title"/> 
               
                <xsl:variable name="composer"  select="doc('lists/TEI-ListWork.xml')//div//bibl[@xml:id=$new]//mei:composer" />
                <xsl:variable name="librettist"  select="doc('lists/TEI-ListWork.xml')//div//bibl[@xml:id=$new]/mei:librettist" />
                <xsl:variable name="author"  select="doc('lists/TEI-ListWork.xml')//div//bibl[@xml:id=$new]//author" />
                
                <xsl:choose>

                    <xsl:when test="exists($composer)">
                        <xsl:element name="label" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:attribute name="rend">bold</xsl:attribute>
                            <xsl:text > [Compositore]: </xsl:text>
                        </xsl:element>
                        <xsl:value-of select="$composer" />

                        <xsl:element name="label" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:attribute name="rend">bold</xsl:attribute>
                            <xsl:text > [Librettista]: </xsl:text>
                        </xsl:element>
                        <xsl:value-of select="$librettist" />
                    </xsl:when>

                    <xsl:otherwise>

                        <xsl:element name="label" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:attribute name="rend">bold</xsl:attribute>
                            <xsl:text > [Autore]: </xsl:text>
                         </xsl:element>
                        <xsl:value-of select="$author" />

                    </xsl:otherwise>
               
                </xsl:choose>
                
                <xsl:element name="label" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="rend">bold</xsl:attribute>
                    <xsl:text > [Prima rappresentazione]: </xsl:text>
                </xsl:element>
                <xsl:value-of select="doc('lists/TEI-ListWork.xml')//div//bibl[@xml:id=$new]/orgName"/> 
                <xsl:text >, </xsl:text>
                <xsl:value-of select="doc('lists/TEI-ListWork.xml')//div//bibl[@xml:id=$new]/placeName"/>
                <xsl:text >, </xsl:text>
                <xsl:value-of select="doc('lists/TEI-ListWork.xml')//div//bibl[@xml:id=$new]/date"/>
                <!-- copia i valori degli element orgName, placeName, date se il valore dell'attributo xml.id è uguale al valore della variabile new -->
                
                <xsl:variable name="note" select="doc('lists/TEI-ListWork.xml')//div//bibl[@xml:id=$new]/note" />
                <!-- (Nota Seminara, 2017: page 65 N. 2) -->

                <xsl:for-each select="$note">
                    <xsl:element name="label" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:attribute name="rend">bold</xsl:attribute>
                        <xsl:text > [Nota]: </xsl:text>
                    </xsl:element>
                    <xsl:choose>
                        <xsl:when test="contains(./@source,'Seminara2017')"><xsl:apply-templates select="current()" mode="noteseminara"/></xsl:when>
                        <xsl:otherwise><xsl:apply-templates select="."/></xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
                <!--xsl:value-of select="doc('lists/TEI-ListWork.xml')//div//bibl[@xml:id=$new]/note"/--> 
                <!-- copia i valori dell'elemento note se il valore dell'attributo xml.id è uguale al valore della variabile new -->

            </xsl:if> 

        </xsl:element>
    </xsl:template>  
    
    <xsl:template match="tei:ptr">
        <!--Template usato per ottenere il testo della nota che appare quando clicchiamo sul pointer di riferimento-->
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
        <xsl:variable name="target" select="@target"/>
        <xsl:variable name="new" select="translate($target, '#', '')"/>
        
        <xsl:choose>
            <xsl:when test="contains(//tei:note[@xml:id=$new]/@source,'Seminara2017')"><xsl:apply-templates select="//tei:note[@xml:id=$new]" mode="noteseminara"/></xsl:when>
            <xsl:otherwise><xsl:apply-templates select="//tei:note[@xml:id=$new]"/></xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>

    <xsl:template match="tei:note" mode="noteseminara">
        <xsl:copy>
            <xsl:text>(Nota Seminara, 2017: p.</xsl:text>            
            <xsl:text> </xsl:text><xsl:value-of select="tei:bibl/tei:citedRange" />
            <xsl:text> </xsl:text>
            <xsl:text>n. </xsl:text>
            <xsl:value-of select="@ana" />
            <xsl:text>)</xsl:text>
            <xsl:apply-templates select="./tei:p" />
        </xsl:copy>
    </xsl:template>

    <xsl:template match="note" mode="noteseminara">
        <xsl:copy>
            <xsl:text>(Seminara, 2017: p.</xsl:text>            
            <xsl:text> </xsl:text><xsl:value-of select="bibl/citedRange" />
            <xsl:text> </xsl:text>
            <xsl:text>n. </xsl:text>
            <xsl:value-of select="@ana" />
            <xsl:text>)</xsl:text>
            <xsl:apply-templates select="./p" />
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:persName">
        <xsl:copy>
            
            <xsl:variable name="ref" select="@ref"/>
            
            <xsl:if test="exists($ref)">
                <!-- aggiunge l'attributo ref solo se è presente nel documento di input applicando la funzione exists che verifica se non è vuoto il campo-->
                <xsl:attribute name="ref">
                    <xsl:value-of select="substring-after($ref, 'TEI-ListPerson.xml')"/>
                </xsl:attribute> 
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:placeName">
        <xsl:copy>
            
            <xsl:variable name="ref" select="@ref"/>
            
            <xsl:if test="exists($ref)">
                <xsl:attribute name="ref">
                    <xsl:value-of select="substring-after($ref, 'TEI-ListPlace.xml')"/>
                </xsl:attribute> 
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:orgName">
        <xsl:copy>
            
            <xsl:variable name="ref" select="@ref"/>
            
            <xsl:if test="exists($ref)">
                <xsl:attribute name="ref">
                    <xsl:value-of select="substring-after($ref, 'TEI-ListOrganization.xml')"/>
                </xsl:attribute>  
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:back">
        
        <xsl:element name="back" namespace="http://www.tei-c.org/ns/1.0"> 
            <!--creazione dell'elemento back dopo l'elemento body in cui sono inseriti i blocchi di testo per gli hotspot-->
            
            <xsl:element name="div" namespace="http://www.tei-c.org/ns/1.0"> 
                <xsl:attribute name="type">hotspot</xsl:attribute>
                <!-- creazione del blocco dell'elemento div con attributo type con valore hotspot -->

                <xsl:variable name="facs" select="//tei:teiHeader//*[@facs]"/>
               
                <xsl:variable name="zone" select="//tei:zone[@rendition='HotSpot']"/>

               <xsl:for-each select="$zone">
                   
                   <xsl:variable name="zone2" select="@xml:id"/>
                   <xsl:variable name="newid" select="concat ($zone2, 'h')"/> <!-- a cui aggiungo la lettera h -->
                   <xsl:variable name="newfacs" select="concat('#', $zone2)"/> 
                   
                   
                   <xsl:element name="div" namespace="http://www.tei-c.org/ns/1.0">
                       
                       <xsl:attribute name="xml:id">
                           <xsl:value-of select="$newid"/>
                       </xsl:attribute>
                       
                       <xsl:attribute name="facs">
                           <xsl:value-of select="$newfacs"/>
                       </xsl:attribute>
                       
                       <xsl:for-each select="$facs">
                           
                           <xsl:variable name="facs3" select="@facs"/>
                           <xsl:variable name="facs4" select="translate($facs3, '#', '')"/>
                           
                           <xsl:if test="$facs4=$zone2">
                               
                               <xsl:element name="p" namespace="http://www.tei-c.org/ns/1.0">  
                                   <xsl:value-of> <!-- mostra solo il testo senza codice -->
                                   <!-- <xsl:copy> se volevo invece mostrare tutta la porzione di codice -->
                                       <xsl:apply-templates mode="hotspot"/>
                                   </xsl:value-of>  <!-- Lo copia -->
                               </xsl:element>
                               
                           </xsl:if>
                       </xsl:for-each>
                       
                   </xsl:element>
               </xsl:for-each>
                       
            </xsl:element> <!--fine div hotspot-->
            
            <!-- inserimento bibliografia nel back dell'ultima lettera -->
            
            <xsl:if test="//tei:idno[@type='inventory']='LL1.35'">
                <xsl:element name="div" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="type">biblCompleta</xsl:attribute>
                    <xsl:element name="listBibl" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:variable name="listbibl" select="doc('lists/TEI-ListBibl.xml')//tei:back//tei:div//tei:listBibl"/>
                        <!--xsl:copy-of select="$listbibl"/-->
                        <xsl:apply-templates select="$listbibl" mode="bibl" />
                    </xsl:element>
                    
                </xsl:element>
                
            </xsl:if>
            
            
        </xsl:element> <!-- fine back -->
    </xsl:template>

        <!--bibl>
                <author>Bellini, V.</author> <date type="anno">2017</date>. <title rend="italics">Carteggi</title>. A cura di <editor>Seminara, G.</editor>. <pubPlace>Firenze</pubPlace>. <publisher>Olschki</publisher>.
        </bibl>

        <bibl>
            <editor>Della Seta F.</editor> (a cura di). 2010. Le parole del teatro musicale. Roma. Carocci.
        </bibl>
        <bibl>
            <! gestire anche la rivista >
        </bibl-->
    <xsl:template match="tei:biblStruct" mode="bibl">
        <xsl:element name="bibl" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="attribute::*" />
            <xsl:apply-templates select="child::node()" mode="bibl" />
        </xsl:element>
    </xsl:template>

    <xsl:template match="tei:author" mode="bibl">
        <xsl:element name="author" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="attribute::*" />
            <xsl:value-of select=".//tei:surname" /><xsl:text>, </xsl:text><xsl:value-of select="substring(.//tei:forename,1,1)" /><xsl:text>. </xsl:text>
        </xsl:element>
        <xsl:element name="date" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:value-of select="following::tei:date[1]/(@when | @to)" />
        </xsl:element>
        <xsl:text>. </xsl:text> 
    </xsl:template>

    <xsl:template match="tei:title[@level='m' or @level='a']" mode="bibl">
        <xsl:element name="title" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="attribute::*" />
            <xsl:value-of select="current()/text()" />
        </xsl:element>
        <xsl:text>. </xsl:text>
    </xsl:template>

    <xsl:template match="tei:title[@level='j']" mode="bibl">
        <xsl:if test="not(@type='sub')">
            <xsl:text>In </xsl:text>
        </xsl:if>
        <xsl:element name="title" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="attribute::*" />
            <xsl:value-of select="current()/text()" />
        </xsl:element>
        <xsl:if test="(following-sibling::tei:imprint/tei:publisher or following-sibling::tei:imprint/tei:pubPlace)">
            <xsl:text>. </xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="tei:editor" mode="bibl">
        <xsl:element name="editor" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="attribute::*" />
            <xsl:value-of select="if (.//tei:surname) then .//tei:surname else .//tei:orgName/text()" /><xsl:text>, </xsl:text><xsl:value-of select=".//tei:forename" />
        </xsl:element>
        <xsl:text> (a cura di). </xsl:text>
    </xsl:template>

    <xsl:template match="tei:imprint" mode="bibl">

        <xsl:if test="exists(./tei:pubPlace)">
        <xsl:element name="pubPlace" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="attribute::*" />
            <xsl:value-of select="./tei:pubPlace/text()" />
        </xsl:element>
        <xsl:if test="./tei:pubPlace/following-sibling::tei:publisher">
            <xsl:text>. </xsl:text>
        </xsl:if>
    </xsl:if>

    <xsl:if test="exists(./tei:publisher)">
        <xsl:element name="publisher" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="attribute::*" />
            <xsl:value-of select="./tei:publisher/text()" />
        </xsl:element>
        <xsl:if test="not(./tei:publisher/following-sibling::tei:date)">
            <xsl:text>.</xsl:text>
        </xsl:if>
    </xsl:if>

    </xsl:template>

    <xsl:template match="text()" mode="bibl">
        <xsl:text></xsl:text>
    </xsl:template>
    
    

    
   <!-- ................su questi applica mode per l'elemento choice  anche per incipit ed explicit............................. --> 
    
    <xsl:template match="tei:choice" mode="sciogliabbr"> 
        <xsl:variable name="expa">
            <xsl:value-of select="translate(normalize-space(tei:expan),' ','')" />
        </xsl:variable>
        <xsl:variable name="spazi" select="concat(' ',$expa, ' ')"/>
        <!-- aggiunge uno spazio prima e uno dopo -->
        
        <xsl:value-of select="$spazi"/> 
        
    </xsl:template>
    
    
    
    <!--  ...........mode per collegamenti delle entità nominate ......................................................... -->
    
    <xsl:template match="tei:persName" mode="hotspot"> 
        <xsl:copy>
            
            <xsl:variable name="ref" select="@ref"/>
            
            <xsl:if test="exists($ref)">
                <!-- aggiunge l'attributo ref solo se è presente nel documento di input applicando la funzione exists che verifica se non è vuoto il campo-->
                <xsl:attribute name="ref">
                    <xsl:value-of select="substring-after($ref, 'TEI-ListPerson.xml')"/>
                </xsl:attribute> 
            </xsl:if>
            <xsl:apply-templates mode ="hotspot"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:placeName"  mode ="hotspot" >
        <xsl:copy>
            
            <xsl:variable name="ref" select="@ref"/>
            
            <xsl:if test="exists($ref)">
                <xsl:attribute name="ref">
                    <xsl:value-of select="substring-after($ref, 'TEI-ListPlace.xml')"/>
                </xsl:attribute> 
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:orgName" mode ="hotspot">
        <xsl:copy>
            
            <xsl:variable name="ref" select="@ref"/>
            
            <xsl:if test="exists($ref)">
                <xsl:attribute name="ref">
                    <xsl:value-of select="substring-after($ref, 'TEI-ListOrganization.xml')"/>
                </xsl:attribute>  
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <!--xsl:template match="tei:gap[@reason='illegible' AND @unit='char' AND @quantity]">
         salvare il numero della quantity 
         creare un elemento unclear con stessi attributi del gap 
         inserire come testo tanti caratteri '+' quanti indicati in quantity' 
    </xsl:template-->

    <!--xsl:template match="tei:gap[@reason='illegible' AND @unit='line' AND @quantity]">
         salvare il numero della quantity 
         creare un elemento unclear con stessi attributi del gap 
         inserire come testo [[+++++++]]' 
    </xsl:template-->

    <!--xsl:template match="tei:gap[@reason='illegible' AND @unit='line' AND @quantity]">
         salvare il numero della quantity 
         creare un elemento unclear con stessi attributi del gap 
         inserire come testo [[+++++++]]' 
    </xsl:template-->

    <xsl:template match="tei:gap[@reason='deleted' and @extent='one-line']">
        <xsl:text>[[+++++++]]</xsl:text>
    </xsl:template>

    <xsl:template match="tei:gap[@reason='illegible' and (@extent='one-word' or @extent='several-characters' or @extent='unknown')]">
        <xsl:text>+++</xsl:text>
    </xsl:template>

    <xsl:template match="tei:gap[not(@reason='illegible') and (@unit='word' or @extent='one-word' or @extent='several-characters' or @extent='unknown')]">
        <xsl:text>[+++]</xsl:text>
    </xsl:template>

    <xsl:template match="tei:gap[not(@reason='illegible') and @unit='char']">
        <xsl:text>[...]</xsl:text>
    </xsl:template>

    <xsl:template match="tei:gap[@reason='illegible' and @unit='char']">
        <xsl:text>...</xsl:text>
    </xsl:template>

    <xsl:template match="tei:gap[@reason='editorial']">
        <xsl:text>[...]</xsl:text>
    </xsl:template>

    <xsl:template match="tei:space[@unit='line']">
        <xsl:element name="lb" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="rend">
                <xsl:value-of select="@quantity" /><xsl:text>-</xsl:text><xsl:value-of select="@unit" />
            </xsl:attribute>
        </xsl:element>
    </xsl:template>

    <xsl:template match="tei:space[not(@unit='line')]">
        <xsl:text>&#160;</xsl:text>
    </xsl:template>

</xsl:stylesheet>