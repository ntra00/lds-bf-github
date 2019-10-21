xquery version "1.0-ml";
declare default function namespace "http://www.w3.org/1999/xhtml";





  let $coplandCount := fn:count(fn:collection("/lscoll/pae/copland/"))
  let $coplandColls := xdmp:document-get-collections("/lscoll/copland/loc.natlib.copland.phot0080.xml")




  let $bernsteinCount := fn:count(fn:collection("/lscoll/pae/bernstein/"))
  let $bernsteinColls := xdmp:document-get-collections("/lscoll/bernstein/loc.natlib.lbcorr.00002.xml")

  let $bernsteinInfo :=
  (<p xmlns="http://www.w3.org/1999/xhtml">{(fn:concat('There are ', $bernsteinCount, ' documents from the Leonard Bernstein  Collection in the ML3 natlibcat database.'),
  <br/>,
  'They are members of the following collections:',
  <br/>,
  (for $coll in $bernsteinColls
   return ($coll,<br/>)
  )
  )}</p>, <hr xmlns="http://www.w3.org/1999/xhtml"/>)

  
  
  let $coplandInfo :=
  (<p xmlns="http://www.w3.org/1999/xhtml">{(fn:concat('There are ', $coplandCount, ' documents from the Aaron Copland Collection in the ML3 natlibcat database.'),
  <br/>,
  'They are members of the following collections:',
  <br/>,
  (for $coll in $coplandColls
   return ($coll,<br/>)
  )
  )}</p>, <hr xmlns="http://www.w3.org/1999/xhtml"/>)


  let $fineCount := fn:count(fn:collection("/lscoll/pae/fine/"))
  let $fineColls := xdmp:document-get-collections("/lscoll/fine/loc.natlib.fine.phot001.xml")
  
  
  let $fineInfo :=
  (<p xmlns="http://www.w3.org/1999/xhtml">{(fn:concat('There are ', $fineCount, ' documents from the Irving Fine Collection in the ML3 natlibcat database.'),
  <br/>,
  'They are members of the following collections:',
  <br/>,
  (for $coll in $fineColls
   return ($coll,<br/>)
  )
  )}</p>, <hr xmlns="http://www.w3.org/1999/xhtml"/>)
  
  
  
  let $gottliebArticlesColls := xdmp:document-get-collections("/lscoll/pae/gottlieb/loc.natlib.gottlieb.001.xml")
  
  

  let $gottliebCount := fn:count(fn:collection("/lscoll/pae/gottlieb/"))

  let $gottliebPhotosCount := fn:count(fn:collection("/lscoll/pae/gottlieb/photographs/"))
  let $gottliebArticlesCount := fn:count(fn:collection("/lscoll/pae/gottlieb/articles/"))

  let $gottliebPhotoColls := xdmp:document-get-collections("/lscoll/gottlieb/loc.natlib.gottlieb.00011.xml")

  let $gottliebArticleColls := xdmp:document-get-collections("/lscoll/gottlieb/loc.natlib.gottlieb.001.xml")


  let $gottliebInfo :=
  (<p xmlns="http://www.w3.org/1999/xhtml">{(fn:concat('There are ', $gottliebCount, ' documents from the William P. Gottlieb Collection in the ML3 natlibcat database.'),
  <br/>,
  <br/>,

  (let $photos :=fn:data($gottliebPhotosCount)
   let $string := fn:concat('There are ', $photos, ' photographs', ' (PROFILE="lc:photoObject")')
   return $string
  ),

  <p>An example document is: document("/lscoll/gottlieb/loc.natlib.gottlieb.00011.xml")</p>,

  <br/>,
  'They are members of the following collections:',
  <br/>,
  (for $coll in $gottliebPhotoColls
   return ($coll,<br/>)
  ),

  <br/>,

  (let $articles :=fn:data($gottliebArticlesCount)
   let $string := fn:concat('There are ', $articles, ' articles.' ,' (PROFILE="lc:printMaterial")')
   return $string
  ),


  <p>An example document is: document("/lscoll/gottlieb/loc.natlib.gottlieb.001.xml")</p>,


  <br/>,
  'The articles are members of the following collections:',
  <br/>,
  (for $coll in $gottliebArticleColls
   return ($coll,<br/>)
  )

  )}</p>, <hr xmlns="http://www.w3.org/1999/xhtml"/>)



  let $tohapCount := fn:count(fn:collection("/lscoll/tohap/"))
  let $tohapColls := xdmp:document-get-collections("/lscoll/tohap/loc.natlib.tohap.H0008.xml")
  
  
  let $tohapInfo :=
  (<p xmlns="http://www.w3.org/1999/xhtml">{(fn:concat('There are ', $tohapCount, ' documents from the TOHAP Collection in the ML3 natlibcat database.'),
  <br/>,


  'An example document is: document("/lscoll/tohap/loc.natlib.tohap.H0008.xml")',
  <br/>,

  'or...',<br/>,

  <a href="http://marklogic3.loctest.gov/xq/render.xqy?id=loc.natlib.tohap.H0008&amp;mime=application/mets+xml">Example METS document</a>,<br/>,


  'They are members of the following collections:',
  <br/>,
  (for $coll in $tohapColls
   return ($coll,<br/>)
  )
  )}</p>, <hr xmlns="http://www.w3.org/1999/xhtml"/>)





let $totalDocs := ($coplandCount + $fineCount + $gottliebCount + $tohapCount + $bernsteinCount)


return
(xdmp:set-response-content-type("text/html"), 
<html xmlns="http://www.w3.org/1999/xhtml">

  <head>
    <title>Digital Docs</title>
  </head>
  <body>
  <h2>Digital documents loaded to MarkLogic3 natlibcat database</h2>
   <p>{$totalDocs} documents loaded to date.</p>
   <hr/>
   <p>
<a href="#lenny">Leonard Bernstein Collection</a><br/>
<a href="#copland">Aaron Copland Collection</a><br/>
<a href="#gottlieb">William P. Gottlieb Collection</a><br/>
<a href="#fine">Irving Fine Collection</a><br/>
<a href="#tohap">TOHAP Collection</a>
   </p>

   <hr/>
  <h2>American Memory Collections</h2>
  <a name="lenny"/>
  <h3>Leonard Bernstein Collection</h3>
  {$bernsteinInfo}
  <a name="copland"/>
  <h3>Aaron Copland Collection</h3>
  {$coplandInfo}
  <a name="gottlieb"/>
  <h3>William P. Gottlieb Collection</h3>
  {$gottliebInfo}
  <a name="fine"/>
  <h3>Irving Fine Collection</h3>
  {$fineInfo}
  <h2>Other Digital Collections</h2>
  <a name="tohap"/>
  <h3>TOHAP Collection</h3>
  {$tohapInfo}

  </body>
</html>)







(:
<p>
coplandCount is {$coplandCount}<br/>
fineCount is {$fineCount}<br/>
gottliebCount is {$gottliebCount}<br/>
tohapCount is {$tohapCount}<br/>
</p>


/var/www/html/reports
:)



