xquery version "1.0-ml";

module namespace pb = "info:lc/xq-modules/config/profile-behaviors";
declare default element namespace "info:lc/xq-modules/config/profile-behaviors";

declare function pb:profiles() as element(profiles) {
(: sorting of access behaviors is in document order, @label= html text :)
	<profiles>
        <!--  list of access elements citation tab is okay on all options on each???? parameters??? -->
        <profile>
    		<name>modsBibRecord</name>		
    		<behavior label="Description only">description</behavior>
    	</profile>
    	<!--<profile>
    		<name>photoObject</name>
    		<behavior label="Zoom">zoom</behavior>		
    		<behavior label="Versions or Sites or Images">pages</behavior>
    		<behavior label="Contact Sheet">contactsheet</behavior>
    		<behavior label="Download Tiff" note="page level">tiff</behavior>			
    	</profile>
    	<profile>
    		<name>photoBatch</name>
    		<behavior label="Zoom">zoom</behavior>
    		<behavior label="Page turner" note="with bookmark tags and captions?">pages</behavior>
    		<behavior label="Contact Sheet">contactsheet</behavior>
    		<behavior label="Download Tiff" note="page level">tiff</behavior>		
    	</profile>
    	<profile>
    		<name>simplePhoto</name>
    		<behavior label="Zoom">zoom</behavior>		
    		<behavior label="Download Tiff" note="page level">tiff</behavior>		
    	</profile>
    	<profile>
    		<name>printMaterial</name>
    		<behavior label="Zoom">zoom</behavior>
    		<behavior label="Page turner">pages</behavior>
    		<behavior label="Contact Sheet">contactsheet</behavior>
    		<behavior label="Download Tiff" note="page level">tiff</behavior>
    		<behavior label="View OCR Text" note="page level">text</behavior>
    		<behavior label="View Text" note="page level">TEIxml</behavior>
    		<behavior label="PDF">pdf</behavior>
    	</profile>
    	<profile>
    		<name>article</name>
    		<behavior label="Text">xhtml</behavior>
    		<behavior label="Description">bib</behavior>		
    		<behavior label="PDF">pdf</behavior>
    	</profile>
    	<profile>
    		<name>biography</name>
    		<behavior label="Text">xhtml</behavior>
    		<behavior label="Description">bib</behavior>		
    		<behavior label="PDF">pdf</behavior>
    	</profile>
    	<profile>
    		<name>modsBibrecord</name>
    		<behavior label="Zoom">zoom</behavior>
    		<behavior label="Online Resource" note="scdb link">onlinelink</behavior>		
    	</profile>
    	<profile>
    		<name>collectionRecord</name>
    		<behavior label="Zoom">zoom</behavior>
    		<behavior label="Table of Contents" note="to volumes/items in collection">toc</behavior>		
    	</profile>	
    	<profile>
    		<name>compactDisc</name>
    		<behavior label="Zoom">zoom</behavior>
    		<behavior label="Play">player</behavior>
    		<behavior label="Table of Contents" note="to track-level metadata and player">toc</behavior>				
    		<behavior label="View Lyrics" note="page level">TEIxml</behavior>
    		<behavior label="CD Booklet" note="CD Booklet pageturner">pages</behavior>
    		<behavior label="PDF">pdf</behavior>
    	</profile>
    	<profile>
    		<name>newCompactDisc</name>
    		<behavior label="Zoom">zoom</behavior>
    		<behavior label="Play">player</behavior>
    		<behavior label="Table of Contents" note="multi-disc">toc</behavior>				
    		<behavior label="View Lyrics" note="track level">TEIxml</behavior>
    		<behavior label="CD Booklet" note="CD Booklet pageturner">pages</behavior>
    		<behavior label="PDF">pdf</behavior>	
    	</profile>
    	<profile sample="100010138">
    		<name>score</name>
    		<behavior label="Zoom">zoom</behavior>
    		<behavior label="Page turner" note="bookmarked part starting page">pages</behavior>
    		<behavior label="Contact Sheet">contactsheet</behavior>
    		<behavior label="Download Tiff" note="page level">tiff</behavior>
    		<behavior label="View OCR Text" note="page level">text</behavior>
    		<behavior label="View XML" note="page level">xml</behavior>
    		<behavior label="PDF">pdf</behavior>
    	</profile>-->
    <!--
    
    
    	
    
    
    PDFdoc
    	Zoom
    	PDF
    	OCR
    
    RecordedEvent	
    	Zoom
    	TOC
    	Player/Playlist
    	Lyrics/Transcript
    
     SimpleAudio
     	Zoom
    
     VideoProgram
     	Zoom
    	Player
     
     LCDB Bib record
     	Zoom-->
    </profiles>
};
