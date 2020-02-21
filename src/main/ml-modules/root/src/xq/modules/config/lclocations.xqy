xquery version "1.0-ml";
module namespace locs = "info:lc/xq-modules/config/lclocations";
declare default element namespace "info:lc/xq-modules/config/lclocations";
                 
declare function locs:locations() as element(locations) {
<locations>
  <locationGroup>
    <loc1>American Folklife Center</loc1>
    <location>
      <loc2>Reference Collection</loc2>
      <id>152</id>
      <code>r-AFCRef</code>
      <name>r-Amer Folk Center Ref</name>
      <display>Reference - American Folklife Center (Jefferson, LJG53)</display>
      <opac>Y</opac>
      <spine>AFC REF</spine>
      <suppress>N</suppress>
      <holdings>3186</holdings>
    </location>
    <location>
      <loc2>Main Collection</loc2>
      <id>7</id>
      <code>c-AFC</code>
      <name>c-Amer Folklife Center</name>
      <display>American Folklife Center (Jefferson, LJG53)</display>
      <opac>Y</opac>
      <spine>AFC</spine>
      <suppress>N</suppress>
      <holdings>1687</holdings>
    </location>
    <location>
      <loc2>Stored Offsite</loc2>
      <id>699</id>
      <code>s-FM/AFC</code>
      <name>s-FtMeade/AFC</name>
      <display>American Folklife Center (Jefferson, LJG53) - STORED OFFSITE</display>
      <opac/>
      <spine>FM/AFC</spine>
      <suppress>N</suppress>
      <holdings>0</holdings>
    </location>
	<location>
		<id>712</id>
		<loc2>Stored Offsite</loc2>
  		<code>s-FM/VHP</code> 
  		<name>s-FtMeadeVHP</name> 
  		<display>American Folklife Center (Jefferson, LJ G53)-STORED OFFSITE</display> 
  		<opac /> 
  		<spine /> 
  		<suppress>N</suppress> 
  		<holdings>2</holdings> 
  </location>

  </locationGroup>
  <locationGroup>
    <loc1>African/Middle Eastern</loc1>
    <location>

      <loc2>Stored Offsite</loc2>
      <id>521</id>
      <code>s-FM/AMED</code>
      <name>s-FtMeadeAMED</name>
      <display>African &amp; Middle Eastern Reading Rm - STORED
                OFFSITE
    </display>

      <opac/>
      <spine>s-FtMeadeAME</spine>
      <suppress>N</suppress>
      <holdings>75392</holdings>
    </location>
    <location>
      <loc2>Main Collection</loc2>

      <id>8</id>
      <code>c-AMED</code>
      <name>c-African &amp; Mid East Div</name>
      <display>African &amp; Middle Eastern Reading Room (Jefferson,
                LJ220)
    </display>
      <opac>Y</opac>

      <spine>AMED</spine>
      <suppress>N</suppress>
      <holdings>287862</holdings>
    </location>
    <location>
      <loc2>Hebraic Reference</loc2>
      <id>161</id>

      <code>r-HebrRef</code>
      <name>r-Hebraic Ref Coll/AMED</name>
      <display>Reference/Hebraic - African/Middle East RR (Jefferson
                LJ220)
    </display>
      <opac>Y</opac>
      <spine>HEBR REF</spine>
      <suppress>N</suppress>

      <holdings>2563</holdings>
    </location>
    <location>
      <loc2>Reference Collection</loc2>
      <id>154</id>
      <code>r-AMEDRR</code>
      <name>r-AfricanMidEast RefColl</name>
      <display>Reference - African/Middle Eastern RR (Jefferson, LJ220) </display>
      <opac>Y</opac>
      <spine>AMED RR</spine>
      <suppress>N</suppress>
      <holdings>236</holdings>
    </location>

    <location>
      <loc2>Near East Reference</loc2>
      <id>171</id>
      <code>r-NrEastRe</code>
      <name>r-Near East Ref Coll/AMED</name>
      <display>Reference/Near East - Afr/Middle Eastern RR(Jefferson LJ220)</display>
      <opac>Y</opac>
      <spine>NR EAST REF</spine>
      <suppress>N</suppress>
      <holdings>2222</holdings>
    </location>
    <location>
      <loc2>Africa Reference</loc2>

      <id>153</id>
      <code>r-AfrRef</code>
      <name>r-African Ref Coll/AMED</name>
      <display>Reference/Africa - Afr/Middle Eastern RR (Jefferson,
                LJ220)
    </display>
      <opac>Y</opac>
      <spine>AFR REF</spine>

      <suppress>N</suppress>
      <holdings>2132</holdings>
    </location>
  </locationGroup>
  <locationGroup>
    <loc1>Miscellaneous</loc1>
    <location>

      <loc2>Unavailable</loc2>
      <id>544</id>
      <code>s-FM/GC/NS</code>
      <name>s-FtMeadeDoNotServe</name>
      <display>Unavailable: Contact Collections Officer, CALM,
                x7-7400
    </display>
      <opac/>

      <spine>s-FtMeadeGC/NS</spine>
      <suppress>N</suppress>
      <holdings>76006</holdings>
    </location>
    <location>
      <loc2>Problem</loc2>
      <id>10</id>

      <code>m-Problem</code>
      <name>m-Problem with Location</name>
      <display>See Reference Staff (Problem location)</display>
      <opac>Y</opac>
      <spine/>
      <suppress>N</suppress>

      <holdings>1745</holdings>
    </location>
    <location>
      <loc2>Error</loc2>
      <id>4</id>
      <code>z-LocMsg</code>
      <name>z-LocMsgOPAC</name>

      <display>Use as a "Limit Group" message for OPAC
                screen
    </display>
      <opac>Y</opac>
      <spine/>
      <suppress>N</suppress>
      <holdings>0</holdings>
    </location>
  </locationGroup>

  <locationGroup>
    <loc1>European</loc1>
    <location>
      <loc2>Main Collection</loc2>
      <id>11</id>
      <code>c-Eur</code>
      <name>c-European Division</name>

      <display>European Reading Room (Jefferson, LJ250)</display>
      <opac>Y</opac>
      <spine>EUR</spine>
      <suppress>N</suppress>
      <holdings>7659</holdings>
    </location>

    <location>
      <loc2>Reference Collection</loc2>
      <id>159</id>
      <code>r-EurRR</code>
      <name>r-European RR Ref Coll</name>
      <display>Reference - European Reading Room (Jefferson,
                LJ250)
    </display>

      <opac>Y</opac>
      <spine>EUR RR</spine>
      <suppress>N</suppress>
      <holdings>10861</holdings>
    </location>
  </locationGroup>
  <locationGroup>

    <loc1>Newspaper/Current Periodicals</loc1>
    <location>
      <loc2>Reference Collection</loc2>
      <id>12</id>
      <code>r-N&amp;CPR</code>
      <name>r-Newsp/Current Per Ref</name>

      <display>Reference - Newspaper/Current Periodical RR (Madison,
                LM133)
    </display>
      <opac>Y</opac>
      <spine>N&amp;CPR</spine>
      <suppress>N</suppress>
      <holdings>6248</holdings>
    </location>

    <location>
      <loc2>Main Collection</loc2>
      <id>27</id>
      <code>c-Ser</code>
      <name>c-Serial &amp; Gov Pub Div</name>
      <display>Newspaper &amp; Current Periodical Reading Room (Madison
                LM133)
    </display>

      <opac>Y</opac>
      <spine>SER</spine>
      <suppress>N</suppress>
      <holdings>165403</holdings>
    </location>
    <location>
      <loc2>Stored Offsite</loc2>

      <id>702</id>
      <code>s-FM/Ser</code>
      <name>s-FtMeadeSer</name>
      <display>Newspr &amp; Current Per Rd Rm (Madison LM133) - STORED
                OFFSITE
    </display>
      <opac/>
      <spine>FM/SER</spine>

      <suppress>N</suppress>
      <holdings>1536</holdings>
    </location>
    <location>
      <loc2>Stored Offsite</loc2>
      <id>180</id>
      <code>s-LCA/SER</code>

      <name>s-Landover/SER</name>
      <display>Newspaper/Current Periodical RR, LM133 (Stored
                Offsite-LCA)
    </display>
      <opac>Y</opac>
      <spine/>
      <suppress>N</suppress>
      <holdings>0</holdings>

    </location>
  </locationGroup>
  <locationGroup>
    <loc1>Law Library</loc1>
    <location>
      <loc2>Main Collection</loc2>
      <id>15</id>

      <code>c-LL</code>
      <name>c-Law Library</name>
      <display>Law Library Reading Room (Madison, LM201)</display>
      <opac>Y</opac>
      <spine>LL</spine>
      <suppress>N</suppress>

      <holdings>961887</holdings>
    </location>
    <location>
      <loc2>Stored Offsite</loc2>
      <id>708</id>
      <code>s-FM/LL/RB</code>
      <name>s-FtMeadeLawRare</name>

      <display>Law Library Reading Room (Madison, LM201) - STORED
                OFFSITE
    </display>
      <opac/>
      <spine>s-FtMeadeLawRare</spine>
      <suppress>N</suppress>
      <holdings>289</holdings>
    </location>
    <location>

      <loc2>Reference Collection</loc2>
      <id>166</id>
      <code>r-LL</code>
      <name>r-Law Library Ref Coll</name>
      <display>Reference - Law Library Reading Room (Madison,
                LM201)
    </display>
      <opac>Y</opac>

      <spine>LL</spine>
      <suppress>N</suppress>
      <holdings>21825</holdings>
    </location>
    <location>
      <loc2>Stored Offsite</loc2>
      <id>522</id>

      <code>s-FM/LL</code>
      <name>s-FtMeadeLaw</name>
      <display>Law Library Reading Room (Madison, LM201) - STORED
                OFFSITE
    </display>
      <opac/>
      <spine>s-FtMeadeLaw</spine>
      <suppress>N</suppress>

      <holdings>178397</holdings>
    </location>
    <location>
      <loc2>Rare Book Collection</loc2>
      <id>16</id>
      <code>c-LLRBR</code>
      <name>c-Law Library Rare Books</name>

      <display>Rare Books - Law Library Reading Room (Madison,
                LM201)
    </display>
      <opac>Y</opac>
      <spine>LL RBR</spine>
      <suppress>N</suppress>
      <holdings>17092</holdings>
    </location>

  </locationGroup>
  <locationGroup>
    <loc1>Microforms</loc1>
    <location>
      <loc2>Main Collection</loc2>
      <id>18</id>
      <code>c-MicRR</code>

      <name>c-Microform RR/HSS</name>
      <display>Microform Reading Room (Jefferson,
                LJ139B)
    </display>
      <opac>Y</opac>
      <spine>MIC RR</spine>
      <suppress>N</suppress>
      <holdings>144932</holdings>

    </location>
    <location>
      <loc2>Stored Offsite</loc2>
      <id>538</id>
      <code>s-LCA/MIC</code>
      <name>s-Landover/Micro</name>
      <display>Landover</display>

      <opac/>
      <spine/>
      <suppress>N</suppress>
      <holdings>0</holdings>
    </location>
	<location>
	  <loc2>Stored Offsite</loc2>
  		<id>711</id> 
		  <code>s-FM/Mic</code> 
		  <name>s-FtMeadeMicroform</name> 
		  <display>Microform Reading Room (Jefferson, LJ139B) - STORED OFFSITE</display> 
		  <opac /> 
		  <spine /> 
		  <suppress>N</suppress> 
		  <holdings>65</holdings> 
  </location>


  </locationGroup>
  <locationGroup>
    <loc1>General Collections</loc1>

    <location>
      <loc2>General Collections</loc2>
      <id>13</id>
      <code>c-GenColl</code>
      <name>c-General Collections/CMD</name>
      <display>Jefferson or Adams Building Reading Rooms</display>

      <opac>Y</opac>
      <spine/>
      <suppress>N</suppress>
      <holdings>9437742</holdings>
    </location>
    <location>
      <loc2>Overflow Storage</loc2>

      <id>497</id>
      <code>s-Ovfl/CMD</code>
      <name>s-Overflow/CMD LA1 South</name>
      <display>Jefferson or Adams Building Reading Rooms</display>
      <opac/>
      <spine/>
      <suppress>N</suppress>

      <holdings>5</holdings>
    </location>
    <location>
      <loc2>Machine Readable</loc2>
      <id>19</id>
      <code>c-MRC</code>
      <name>c-Machine Read Coll/HSS</name>

      <display>See Reference Staff. By Appt in Jefferson Main RR
                (MRC)
    </display>
      <opac>Y</opac>
      <spine>MRC</spine>
      <suppress>N</suppress>
      <holdings>40205</holdings>
    </location>

    <location>
      <loc2>Special Search</loc2>
      <id>176</id>
      <code>s-LCA/CMD</code>
      <name>s-Landover/CMD</name>
      <display>Special Search Desk, Alcove 7, Main RR (Stored
                Offsite-LCA)
    </display>

      <opac>Y</opac>
      <spine/>
      <suppress>N</suppress>
      <holdings>34</holdings>
    </location>
    <location>
      <loc2>Special Materials</loc2>

      <id>28</id>
      <code>c-SpecMat</code>
      <name>c-Special Materials/CMD</name>
      <display>Jefferson or Adams Bldg General or Area Studies Reading
                Rms
    </display>
      <opac>Y</opac>
      <spine>SPEC MAT</spine>

      <suppress>N</suppress>
      <holdings>3302</holdings>
    </location>
    <location>
      <loc2>Reference Collection</loc2>
      <id>169</id>
      <code>r-MRR</code>

      <name>r-Main Reading Room Ref</name>
      <display>Reference - Main Reading Room (Jefferson,
                LJ100)
    </display>
      <opac>Y</opac>
      <spine>MRR</spine>
      <suppress>N</suppress>
      <holdings>24011</holdings>

    </location>
    <location>
      <loc2>Stored Offsite</loc2>
      <id>539</id>
      <code>s-FM/MRC</code>
      <name>s-FtMeadeMRC</name>
      <display>Machine Readable Collections - STORED
                OFFSITE
    </display>

      <opac/>
      <spine>s-FM/MRC</spine>
      <suppress>N</suppress>
      <holdings>22381</holdings>
    </location>
    <location>
      <loc2>Stored Offsite</loc2>

      <id>519</id>
      <code>s-FM/GC</code>
      <name>s-FtMeadeGenColl</name>
      <display>Jefferson or Adams Building Reading Rooms - STORED
                OFFSITE
    </display>
      <opac/>
      <spine>s-FtMeadeGC</spine>

      <suppress>N</suppress>
      <holdings>1936928</holdings>
    </location>
  </locationGroup>
  <locationGroup>
    <loc1>Prints/Photographs</loc1>
    <location>

      <loc2>Reference Collection</loc2>
      <id>173</id>
      <code>r-P&amp;PRef</code>
      <name>r-Prints&amp;Photos Ref Coll</name>
      <display>Reference - Prints &amp; Photographs RR (Madison,
                LM337)
    </display>

      <opac>Y</opac>
      <spine>P&amp;P REF</spine>
      <suppress>N</suppress>
      <holdings>3516</holdings>
    </location>
    <location>

      <loc2>Main Collection</loc2>
      <id>22</id>
      <code>c-P&amp;P</code>
      <name>c-Prints &amp; Photos Div</name>
      <display>Prints &amp; Photographs Reading Room (Madison,
                LM337)
    </display>

      <opac>Y</opac>
      <spine>P&amp;P</spine>
      <suppress>N</suppress>
      <holdings>318009</holdings>
    </location>
    <location>

      <loc2>Stored Offsite</loc2>
      <id>179</id>
      <code>s-LCA/P&amp;P</code>
      <name>s-Landover/P&amp;P</name>
      <display>Prints &amp; Photographs RR, Madison, LM337 (Stored
                Offsite-LCA)
    </display>

      <opac>Y</opac>
      <spine/>
      <suppress>N</suppress>
      <holdings>17</holdings>
    </location>
    <location>
      <loc2>Stored Offsite</loc2>

      <id>703</id>
      <code>s-FM/P&amp;P</code>
      <name>s-FtMeadePrints&amp;Photos</name>
      <display>Prints &amp; Photos Reading Rm (Madison, LM337) - STORED
                OFFSITE
    </display>
      <opac/>

      <spine>s-FM/P&amp;P</spine>
      <suppress>N</suppress>
      <holdings>1608</holdings>
    </location>
  </locationGroup>
  <locationGroup>
    <loc1>Recorded Sound</loc1>

    <location>
      <loc2>Reference Collection</loc2>
      <id>175</id>
      <code>r-RecSound</code>
      <name>r-RecSound Ref Coll/MBRS</name>
      <display>Request in advance in Rec Sound Ref Center (Madison,
                LM113)
    </display>

      <opac>Y</opac>
      <spine>RECSOUND Culpeper</spine>
      <suppress>N</suppress>
      <holdings>750</holdings>
    </location>
    <location>
      <loc2>Main Collection</loc2>

      <id>25</id>
      <code>c-RecSound</code>
      <name>c-Recorded Sound/MBRS</name>
      <display>Request in advance in Rec Sound Ref Center (Madison,
                LM113)
    </display>
      <opac>Y</opac>
      <spine>REC SOUND</spine>

      <suppress>N</suppress>
      <holdings>674351</holdings>
    </location>
    <location>
      <loc2>Main Collection</loc2>
      <id>691</id>
      <code>c-RSRC</code>

      <name>c-RecSndRefCtr</name>
      <display>Recorded Sound Reference Center (Madison,
                LM113)
    </display>
      <opac/>
      <spine>RECSOUND</spine>
      <suppress>N</suppress>
      <holdings>22</holdings>

    </location>
    <location>
      <loc2>Reference Collection</loc2>
      <id>692</id>
      <code>r-RSRC</code>
      <name>r-RecSndRefCtr</name>
      <display>Reference - Recorded Sound Reference Center (Madison,
                LM113)
    </display>

      <opac/>
      <spine>RECSOUND REF</spine>
      <suppress>N</suppress>
      <holdings>1136</holdings>
    </location>
  </locationGroup>
  <locationGroup>

    <loc1>Science/Business</loc1>
    <location>
      <loc2>Business Reference</loc2>
      <id>156</id>
      <code>r-BusRR</code>
      <name>r-Business RR Ref Coll</name>

      <display>Reference - Business Reading Room (Adams, 5th
                Floor)
    </display>
      <opac>Y</opac>
      <spine>BUS RR</spine>
      <suppress>N</suppress>
      <holdings>8819</holdings>
    </location>

    <location>
      <loc2>Stored Offsite</loc2>
      <id>543</id>
      <code>s-FM/GC/SM</code>
      <name>s-FtMeadeSpecMat</name>
      <display>Science/Business Reading Room only - STORED
                OFFSITE
    </display>

      <opac/>
      <spine>s-FtMeadeGC/SM</spine>
      <suppress>N</suppress>
      <holdings>20779</holdings>
    </location>
    <location>
      <loc2>Science Reference</loc2>

      <id>26</id>
      <code>r-SciRR</code>
      <name>r-Science RR Ref Coll</name>
      <display>Reference - Science Reading Room (Adams, 5th
                Floor)
    </display>
      <opac>Y</opac>
      <spine>SCI RR</spine>

      <suppress>N</suppress>
      <holdings>16745</holdings>
    </location>
    <location>
      <loc2>Technical Reports</loc2>
      <id>29</id>
      <code>c-ST&amp;B</code>

      <name>c-Science Tech &amp; Bus Div</name>
      <display>ST&amp;B Ref. desk Adams 5th fl, ask for Tech Repts
                202-707-5655
    </display>
      <opac>Y</opac>
      <spine>ST&amp;B TRS</spine>
      <suppress>N</suppress>

      <holdings>1603</holdings>
    </location>
  </locationGroup>
  <locationGroup>
    <loc1>Children's Literature</loc1>
    <location>
      <loc2>Reference Collection</loc2>

      <id>158</id>
      <code>r-ChLitRef</code>
      <name>r-Childrens Lit Cen Ref</name>
      <display>See Reference Staff. By Appt in Jefferson Main RR
                (ChLit)
    </display>
      <opac>Y</opac>
      <spine>CH LIT REF</spine>

      <suppress>N</suppress>
      <holdings>1698</holdings>
    </location>
  </locationGroup>
  <locationGroup>
    <loc1>Computer Catalog Center</loc1>
    <location>

      <loc2>Jefferson Reference</loc2>
      <id>165</id>
      <code>r-LJCCC</code>
      <name>r-LJ Computer Cat Cen Ref</name>
      <display>Reference - Jefferson Computer Catalog Center
                (LJ139)
    </display>
      <opac>Y</opac>

      <spine>LJ CCC</spine>
      <suppress>N</suppress>
      <holdings>16</holdings>
    </location>
    <location>
      <loc2>Adams Reference</loc2>
      <id>163</id>

      <code>r-LACCC</code>
      <name>r-LA Computer Cat Cen Ref</name>
      <display>Reference - Adams Computer Catalog Center (5th
                Floor)
    </display>
      <opac>Y</opac>
      <spine>LA CCC</spine>
      <suppress>N</suppress>

      <holdings>1</holdings>
    </location>
  </locationGroup>
  <locationGroup>
    <loc1>Microform</loc1>
    <location>
      <loc2>Reference Collection</loc2>

      <id>167</id>
      <code>r-MicRRRef</code>
      <name>r-Microform RR Ref</name>
      <display>Reference - Microform Reading Room (Jefferson,
                LJ100)
    </display>
      <opac>Y</opac>
      <spine>MIC RR REF</spine>

      <suppress>N</suppress>
      <holdings>590</holdings>
    </location>
  </locationGroup>
  <locationGroup>
    <loc1>Manuscripts</loc1>
    <location>

      <loc2>Stored Offsite</loc2>
      <id>177</id>
      <code>s-LCA/MSS</code>
      <name>s-Landover/MSS</name>
      <display>Manuscript Reading Room, Madison, LM101 (Stored
                Offsite-LCA)
    </display>
      <opac>Y</opac>

      <spine/>
      <suppress>N</suppress>
      <holdings>727</holdings>
    </location>
    <location>
      <loc2>Reference Collection</loc2>
      <id>170</id>

      <code>r-MSSRef</code>
      <name>r-Manuscript Ref Coll</name>
      <display>Reference - Manuscript Reading Room (Madison,
                LM101)
    </display>
      <opac>Y</opac>
      <spine>MSS REF</spine>
      <suppress>N</suppress>

      <holdings>2863</holdings>
    </location>
    <location>
      <loc2>Stored Offsite</loc2>
      <id>701</id>
      <code>s-FM/MSS</code>
      <name>s-FtMeadeMSS</name>

      <display>Manuscript Reading Room (Madison, LM101) - STORED
                OFFSITE
    </display>
      <opac/>
      <spine>FM/MSS</spine>
      <suppress>N</suppress>
      <holdings>269</holdings>
    </location>
    <location>

      <loc2>Main Collection</loc2>
      <id>20</id>
      <code>c-MSS</code>
      <name>c-Manuscript Division</name>
      <display>Manuscript Reading Room (Madison, LM101)</display>
      <opac>Y</opac>

      <spine>MSS</spine>
      <suppress>N</suppress>
      <holdings>19325</holdings>
    </location>
  </locationGroup>
  <locationGroup>
    <loc1>Performing Arts</loc1>

    <location>
      <loc2>Main Collection</loc2>
      <id>704</id>
      <code>r-MUS/BAS</code>
      <name>r-LS/MUS/BAS</name>
      <display>Performing Arts Reading Room (Madison,
                LM113)
    </display>

      <opac/>
      <spine>MUS/BAS</spine>
      <suppress>N</suppress>
      <holdings>578</holdings>
    </location>
    <location>
      <loc2>Main Collection</loc2>

      <id>21</id>
      <code>c-Music</code>
      <name>c-Music Division</name>
      <display>Performing Arts Reading Room (Madison,
                LM113)
    </display>
      <opac>Y</opac>
      <spine>MUS</spine>

      <suppress>N</suppress>
      <holdings>523255</holdings>
    </location>
    <location>
      <loc2>Reference Collection</loc2>
      <id>172</id>
      <code>r-PARRRef</code>

      <name>r-PerformArts RefColl/MUS</name>
      <display>Reference - Performing Arts Reading Room (Madison,
                LM113)
    </display>
      <opac>Y</opac>
      <spine>PARR REF</spine>
      <suppress>N</suppress>
      <holdings>443</holdings>

    </location>
    <location>
      <loc2>Stored Offsite</loc2>
      <id>541</id>
      <code>s-FM/Music</code>
      <name>s-FtMeadeMusic</name>
      <display>Performing Arts Reading Rm (Madison, LM113) - STORED
                OFFSITE
    </display>

      <opac/>
      <spine/>
      <suppress>N</suppress>
      <holdings>39157</holdings>
    </location>
    <location>
      <loc2>Stored Offsite</loc2>

      <id>709</id>
      <code>s-FM/MUS/R</code>
      <name>s-FtMeadeMusicRare</name>
      <display>Performing Arts Reading Rm (Madison, LM113) - STORED
                OFFSITE
    </display>
      <opac/>
      <spine>FM/MUS/R</spine>

      <suppress>N</suppress>
      <holdings>2</holdings>
    </location>
    <location>
      <loc2>Stored Offsite</loc2>
      <id>178</id>
      <code>s-LCA/MUS</code>

      <name>s-Landover/MUS</name>
      <display>Performing Arts RR, Madison, LM113 (Stored
                Offsite-LCA)
    </display>
      <opac>Y</opac>
      <spine/>
      <suppress>N</suppress>
      <holdings>0</holdings>

    </location>
  </locationGroup>
  <locationGroup>
    <loc1>Asian Division</loc1>
    <location>
      <loc2>Reference Collection</loc2>
      <id>155</id>

      <code>r-AsianRR</code>
      <name>r-Asian RR Ref Coll</name>
      <display>Reference - Asian Reading Room (Jefferson,
                LJ150)
    </display>
      <opac>Y</opac>
      <spine>ASIAN RR</spine>
      <suppress>N</suppress>

      <holdings>7930</holdings>
    </location>
    <location>
      <loc2>Main Collection</loc2>
      <id>9</id>
      <code>c-Asian</code>
      <name>c-Asian Division</name>

      <display>Asian Reading Room (Jefferson, LJ150)</display>
      <opac>Y</opac>
      <spine>ASIAN</spine>
      <suppress>N</suppress>
      <holdings>750820</holdings>
    </location>

    <location>
      <loc2>Stored Offsite</loc2>
      <id>520</id>
      <code>s-FM/Asian</code>
      <name>s-FtMeadeAsian</name>
      <display>Asian Reading Room (Jefferson LJ150) - STORED
                OFFSITE
    </display>

      <opac/>
      <spine>s-FtMeadeAs</spine>
      <suppress>N</suppress>
      <holdings>574474</holdings>
    </location>
  </locationGroup>
  <locationGroup>
    <loc1>Geography/Map</loc1>
    <location>
      <loc2>Reference Collection</loc2>
      <id>160</id>
      <code>r-G&amp;MRR</code>
      <name>r-Geog &amp; Map RR Ref Coll</name>
      <display>Reference - Geography &amp; Map Reading Room (Madison, LMB01)</display>
      <opac>Y</opac>
      <spine>G&amp;M RR</spine>
      <suppress>N</suppress>
      <holdings>5531</holdings>
    </location>
    <location>
      <loc2>Main Collection</loc2>
      <id>14</id>
      <code>c-G&amp;M</code>
      <name>c-Geography &amp; Map Div</name>
      <display>Geography &amp; Map Reading Room (Madison, LMB01)</display>
      <opac>Y</opac>
      <spine>G&amp;M</spine>
      <suppress>N</suppress>
      <holdings>331177</holdings>
    </location>
	<location>
	<loc2>Vault</loc2>
	  <id>697</id> 
	  <code>c-GM/Vault</code> 
	  <name>c-Geography &amp; Map/Vault</name> 
	  <display>Geography &amp; Map Reading Room (Madison, LMB01)</display> 
	  <opac /> 
	  <spine>G&amp;M</spine> 
	  <suppress>N</suppress> 
	  <holdings>814</holdings> 
	  </location>

    <location>
      <loc2>Stored Offsite</loc2>
      <id>700</id>
      <code>s-FM/G&amp;M</code>
      <name>s-FtMeadeG&amp;M</name>

      <display>Geography &amp; Map Reading Rm (Madison, LMB01) - STORED
                OFFSITE
    </display>
      <opac/>
      <spine/>
      <suppress>N</suppress>
      <holdings>1196</holdings>
    </location>

  </locationGroup>
  <locationGroup>
    <loc1>Motion Picture/TV</loc1>
    <location>
      <loc2>Reference Collection</loc2>
      <id>168</id>
      <code>r-MP&amp;TVRef</code>

      <name>r-MoPic&amp;TV Ref Coll/MBRS</name>
      <display>Reference - Motion Picture/TV Reading Room (Madison,
                LM336)
    </display>
      <opac>Y</opac>
      <spine>MP&amp;TV REF</spine>
      <suppress>N</suppress>

      <holdings>4483</holdings>
    </location>
    <location>
      <loc2>Main Collection</loc2>
      <id>17</id>
      <code>c-MP&amp;TV</code>

      <name>c-Motion Pic &amp; TV/MBRS</name>
      <display>Motion Picture/TV Reading Rm. By Appointment (Madison
                LM336)
    </display>
      <opac>Y</opac>
      <spine>MP&amp;TV</spine>
      <suppress>N</suppress>

      <holdings>310270</holdings>
    </location>
  </locationGroup>
  <locationGroup>
    <loc1>Rare Books</loc1>
    <location>
      <loc2>Stored Offsite</loc2>

      <id>545</id>
      <code>s-FM/RBSCD</code>
      <name>s-FtMeadeRBSCD</name>
      <display>Rare Bk/Spec Coll Rdng Rm (Jefferson LJ239) - STORED
                OFFSITE
    </display>
      <opac/>
      <spine>s-FM/RBSCD</spine>

      <suppress>N</suppress>
      <holdings>38891</holdings>
    </location>
    <location>
      <loc2>Main Collection</loc2>
      <id>24</id>
      <code>c-RareBook</code>

      <name>c-Rare Book/Spec Coll Div</name>
      <display>Rare Book/Special Collections Reading Room (Jefferson
                LJ239)
    </display>
      <opac>Y</opac>
      <spine>RARE BK COLL</spine>
      <suppress>N</suppress>
      <holdings>209063</holdings>

    </location>
    <location>
      <loc2>Reference Collection</loc2>
      <id>174</id>
      <code>r-RareBk</code>
      <name>r-RareBook Ref Coll/RBSCD</name>
      <display>Reference - Rare Bk/Special Collections RR (Jefferson
                LJ239)
    </display>

      <opac>Y</opac>
      <spine>RARE BK REF</spine>
      <suppress>N</suppress>
      <holdings>181</holdings>
    </location>
  </locationGroup>
  <locationGroup>

    <loc1>Acquisitions/Bibliographic Access</loc1>
    <location>
      <loc2>ABA Reference</loc2>
      <id>710</id>
      <code>r-ABARef</code>
      <name>r-ABA Ref Coll</name>

      <display>See Reference Staff. By Appointment Only (ABA
                Ref)
    </display>
      <opac/>
      <spine>ABA REF</spine>
      <suppress>N</suppress>
      <holdings>9</holdings>
    </location>
    <location>

      <loc2>Cataloging Reference</loc2>
      <id>157</id>
      <code>r-CatRef</code>
      <name>r-Cataloging Ref Coll</name>
      <display>See Reference Staff. By Appointment Only
                (CatRef)
    </display>
      <opac>Y</opac>

      <spine>CAT REF</spine>
      <suppress>N</suppress>
      <holdings>6643</holdings>
    </location>
  </locationGroup>
  <locationGroup>
    <loc1>Hispanic</loc1>

    <location>
      <loc2>Reference Collection</loc2>
      <id>162</id>
      <code>r-HispRef</code>
      <name>r-Hispanic RR Ref Coll</name>
      <display>Reference - Hispanic Reading Room (Jefferson,
                LJ240)
    </display>

      <opac>Y</opac>
      <spine>HISP REF</spine>
      <suppress>N</suppress>
      <holdings>3224</holdings>
    </location>
  </locationGroup>
  <locationGroup>

    <loc1>Local History/Genealogy</loc1>
    <location>
      <loc2>Reference Collection</loc2>
      <id>164</id>
      <code>r-LH&amp;G</code>
      <name>r-Local Hist &amp; Geneal Ref</name>

      <display>Reference - Local History &amp; Genealogy RR (Jefferson,
                LJG42)
    </display>
      <opac>Y</opac>
      <spine>LH&amp;G</spine>
      <suppress>N</suppress>
      <holdings>6309</holdings>

    </location>
  </locationGroup>
  <locationGroup>
    <loc1>Preservation Reformatting</loc1>
    <location>
      <loc2>Stored Offsite</loc2>
      <id>698</id>

      <code>s-FM/MN</code>
      <name>s-FtMMastrNeg</name>
      <display>Preserv Reformatting Div (Madison, LM-G05) - STORED
                OFFSITE
    </display>
      <opac/>
      <spine>FM/PRD/MN</spine>
      <suppress>N</suppress>

      <holdings>7347</holdings>
    </location>
  </locationGroup>
  <locationGroup>
    <loc1>Electronic Resource</loc1>
    <location>
      <loc2>Online Resource</loc2>

      <id>504</id>
      <code>s-Online</code>
      <name>s-Online</name>
      <display>Online</display>
      <opac/>
      <spine/>
      <suppress>N</suppress>

      <holdings>6</holdings>
    </location>
    <location>
      <loc2>Journal (Law)</loc2>
      <id>530</id>
      <code>e-Eser/LL</code>
      <name>e-Eserial/Law</name>

      <display>.Electronic Journal</display>
      <opac/>
      <spine/>
      <suppress>N</suppress>
      <holdings>286</holdings>
    </location>
    <location>

      <loc2>Journal (General)</loc2>
      <id>529</id>
      <code>e-Eser/GC</code>
      <name>e-Eserial/GenColl</name>
      <display>.Electronic Journal</display>
      <opac/>

      <spine/>
      <suppress>N</suppress>
      <holdings>17545</holdings>
    </location>
  </locationGroup>
  <locationGroup>
    <loc1>NLS/BPH</loc1>

    <location>
      <loc2>Reference Collection</loc2>
      <id>505</id>
      <code>r-NLSBPH</code>
      <name>r-NLSBPH Ref Coll</name>
      <display>Reference - NLS/BPH (Taylor Street Annex)</display>

      <opac/>
      <spine>NLS/BPH REF</spine>
      <suppress>N</suppress>
      <holdings>65</holdings>
    </location>
  </locationGroup>
  <locationGroup>

    <loc1>Photoduplication</loc1>
    <location>
      <loc2>Master Negatives</loc2>
      <id>508</id>
      <code>n-MastrNeg</code>
      <name>n-Master Negatives</name>

      <display>~To buy a copy call Photoduplication Service
                202-707-5640
    </display>
      <opac/>
      <spine/>
      <suppress>N</suppress>
      <holdings>9609</holdings>
    </location>
    <location>

      <loc2>Print Negatives</loc2>
      <id>509</id>
      <code>n-PrintNeg</code>
      <name>n-Print Negatives</name>
      <display>For copy information call Photoduplication,
                202-707-5640
    </display>
      <opac/>

      <spine/>
      <suppress>N</suppress>
      <holdings>1606</holdings>
    </location>
  </locationGroup>
</locations>
};
