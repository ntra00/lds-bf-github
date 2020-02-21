xquery version "1.0-ml";

module namespace matconf = "info:lc/xq-modules/config/materials";
declare default element namespace "info:lc/xq-modules/config/materials";

declare function matconf:materials() as element(materials) {
	<materials >
		<materialtype code="[000_06_2]" tag="000_06_2"/>
		<materialtype code="aa" tag="000_06_2">
			<desc>Book (Print, Microform, Electronic, etc.)</desc><short>Book</short>
		</materialtype>
<materialtype code="n" tag="008_21_1">
			<desc>Newspaper</desc><short>Newspaper</short>
		</materialtype>
		<materialtype code="ab" tag="000_06_2">
			<desc>Serial (Journal, Periodical, etc.)</desc><short>Journal/Periodical</short>
		</materialtype>
		<materialtype code="ac" tag="000_06_2">
			<desc>Book (Print, Microform, Electronic, etc.) - Collection</desc><short>Book</short>
		</materialtype>
		<materialtype code="ad" tag="000_06_2">
			<desc>Book (Print, Microform, Electronic, etc.) - Part of Collection</desc><short>Book</short>
		</materialtype>
		<materialtype code="ai" tag="000_06_2">
		<desc>Loose-leaf, Web site, Database, etc.</desc><short>Book</short>
	</materialtype>	
	
		<materialtype code="am" tag="000_06_2">
			<desc>Book (Print, Microform, Electronic, etc.)</desc><short>Book</short>
		</materialtype>
		<materialtype code="as" tag="000_06_2">
			<desc>Serial (Journal, Periodical, etc.)</desc><short>Journal/Periodical</short>
		</materialtype>
		<materialtype code="ba" tag="000_06_2">
			<desc>Archival Manuscript Material</desc><short>Manuscript</short>
		</materialtype>
		<materialtype code="bb" tag="000_06_2">
			<desc>Archival Manuscript Material</desc><short>Manuscript</short>
		</materialtype>
		<materialtype code="bc" tag="000_06_2">
			<desc>Archival Manuscript Material (Collection)</desc><short>Manuscript</short>
		</materialtype>
		<materialtype code="bd" tag="000_06_2">
			<desc>Archival Manuscript Material (Part of Collection)</desc><short>Manuscript</short>
		</materialtype>
		<materialtype code="bm" tag="000_06_2">
			<desc>Archival Manuscript Material</desc><short>Manuscript</short>
		</materialtype>
		<materialtype code="bs" tag="000_06_2">
			<desc>Archival Manuscript Material (Serial)</desc><short>Manuscript</short>
		</materialtype>
		<materialtype code="ca" tag="000_06_2">
			<desc>Printed Music (Part or Selection)</desc><short>Printed Music</short>
		</materialtype>
		<materialtype code="cb" tag="000_06_2">
			<desc>Printed Music (Part or Selection)</desc><short>Printed Music</short>
		</materialtype>
		<materialtype code="cc" tag="000_06_2">
			<desc>Printed Music (Collection)</desc><short>Printed Music</short>
		</materialtype>
		<materialtype code="cd" tag="000_06_2">
			<desc>Printed Music (Part of Collection)</desc><short>Printed Music</short>
		</materialtype>
	<materialtype code="ci" tag="000_06_2">
		<desc>Printed Music (Web site, Database, etc.)</desc><short>Printed Music</short>
	</materialtype>	
	

		<materialtype code="cm" tag="000_06_2">
			<desc>Printed Music</desc><short>Printed Music</short>
		</materialtype>
		<materialtype code="cs" tag="000_06_2">
			<desc>Printed Music (Serial)</desc><short>Printed Music</short>
		</materialtype>
		<materialtype code="da" tag="000_06_2">
			<desc>Manuscript Music (Part or Selection)</desc><short>Manuscript Music</short>
		</materialtype>
		<materialtype code="db" tag="000_06_2">
			<desc>Manuscript Music (Part or Selection)</desc><short>Manuscript Music</short>
		</materialtype>
		<materialtype code="dc" tag="000_06_2">
			<desc>Manuscript Music (Collection)</desc><short>Manuscript Music</short>
		</materialtype>
		<materialtype code="dd" tag="000_06_2">
			<desc>Manuscript Music (Part of Collection)</desc><short>Manuscript Music</short>
		</materialtype>
		<materialtype code="dm" tag="000_06_2">
			<desc>Manuscript Music</desc><short>Manuscript Music</short>
		</materialtype>
		<materialtype code="ds" tag="000_06_2">
			<desc>Manuscript Music (Serial)</desc><short>Manuscript Music</short>
		</materialtype>
		<materialtype code="ea" tag="000_06_2">
			<desc>Cartographic Material</desc><short>Map/Cartography</short>
		</materialtype>
		<materialtype code="eb" tag="000_06_2">
			<desc>Cartographic Material</desc><short>Map/Cartography</short>
		</materialtype>
		<materialtype code="ec" tag="000_06_2">
			<desc>Cartographic Material (Collection)</desc><short>Map/Cartography</short>
		</materialtype>
		<materialtype code="ed" tag="000_06_2">
			<desc>Cartographic Material (Part of Collection)</desc><short>Map/Cartography</short>
		</materialtype>
		<materialtype code="ei" tag="000_06_2">
		<desc>Cartographic Material (Web site, Database, etc.)</desc><short>Map/Cartography</short>
	</materialtype>	
	
		<materialtype code="em" tag="000_06_2">
			<desc>Cartographic Material</desc><short>Map/Cartography</short>
		</materialtype>
		<materialtype code="es" tag="000_06_2">
			<desc>Cartographic Material (Serial)</desc><short>Map/Cartography</short>
		</materialtype>
		<materialtype code="fa" tag="000_06_2">
			<desc>Manuscript Cartographic Material</desc><short>Map/Cartography</short>
		</materialtype>
		<materialtype code="fb" tag="000_06_2">
			<desc>Manuscript Cartographic Material</desc><short>Map/Cartography</short>
		</materialtype>
		<materialtype code="fc" tag="000_06_2">
			<desc>Manuscript Cartographic Material (Collection)</desc><short>Map/Cartography</short>
		</materialtype>
		<materialtype code="fd" tag="000_06_2">
			<desc>Manuscript Cartographic Material (Part of Collection)</desc><short>Map/Cartography</short>
		</materialtype>
		<materialtype code="fm" tag="000_06_2">
			<desc>Manuscript Cartographic Material</desc><short>Map/Cartography</short>
		</materialtype>
		<materialtype code="fs" tag="000_06_2">
			<desc>Manuscript Cartographic Material (Serial)</desc><short>Map/Cartography</short>
		</materialtype>
		<materialtype code="ga" tag="000_06_2">
			<desc>Moving Image or Slide/Transparency</desc><short>Film/Video/Slide</short>
		</materialtype>
		<materialtype code="gb" tag="000_06_2">
			<desc>Moving Image or Slide/Transparency</desc><short>Film/Video/Slide</short>
		</materialtype>
		<materialtype code="gc" tag="000_06_2">
			<desc>Moving Image or Slide/Transparency (Collection)</desc><short>Film/Video/Slide</short>
		</materialtype>
		<materialtype code="gd" tag="000_06_2">
			<desc>Moving Image or Slide/Transparency (Part of Collection)</desc><short>Film/Video/Slide</short>
		</materialtype>
		<materialtype code="gi" tag="000_06_2">
		<desc>Moving Image (Web site, Database, etc.)</desc><short>Film/Video/Slide</short>
	</materialtype>	
	
		<materialtype code="gm" tag="000_06_2">
			<desc>Moving Image or Slide/Transparency</desc><short>Film/Video/Slide</short>
		</materialtype>
		<materialtype code="gs" tag="000_06_2">
			<desc>Moving Image or Slide/Transparency (Serial)</desc><short>Film/Video/Slide</short>
		</materialtype>
		<materialtype code="ia" tag="000_06_2">
			<desc>Nonmusic Sound Recording</desc><short>Audio (Spoken)</short>
		</materialtype>
		<materialtype code="ib" tag="000_06_2">
			<desc>Nonmusic Sound Recording</desc><short>Audio (Spoken)</short>
		</materialtype>
		<materialtype code="ic" tag="000_06_2">
			<desc>Nonmusic Sound Recording (Collection)</desc><short>Audio (Spoken)</short>		
		</materialtype>
		<materialtype code="id" tag="000_06_2">
			<desc>Nonmusic Sound Recording (Part of Collection)</desc><short>Audio (Spoken)</short>		
		</materialtype>
		<materialtype code="ii" tag="000_06_2">
		<desc>Nonmusic Sound Recording (Web site, Database, etc.)</desc><short>Audio (Spoken)</short>		
	</materialtype>	
	
		<materialtype code="im" tag="000_06_2">
			<desc>Nonmusic Sound Recording</desc><short>Audio (Spoken)</short>
		</materialtype>
		<materialtype code="is" tag="000_06_2">
			<desc>Nonmusic Sound Recording (Serial)</desc><short>Audio (Spoken)</short>		
		</materialtype>
		<materialtype code="ja" tag="000_06_2">
			<desc>Music Sound Recording</desc><short>Audio (Music)</short>
		</materialtype>
		<materialtype code="jb" tag="000_06_2">
			<desc>Music Sound Recording</desc><short>Audio (Music)</short>
		</materialtype>
		<materialtype code="jc" tag="000_06_2">
			<desc>Music Sound Recording (Collection)</desc><short>Audio (Music)</short>
		</materialtype>
		<materialtype code="jd" tag="000_06_2">
			<desc>Music Sound Recording (Part of Collection)</desc><short>Audio (Music)</short>
		</materialtype>
	<materialtype code="ji" tag="000_06_2">
		<desc>Music Sound Recording (Web site, Database, etc.)</desc><short>Audio (Music)</short>
	</materialtype>	
	
		<materialtype code="jm" tag="000_06_2">
			<desc>Music Sound Recording</desc><short>Audio (Music)</short>
		</materialtype>
		<materialtype code="js" tag="000_06_2">
			<desc>Music Sound Recording (Serial)</desc><short>Audio (Music)</short>
		</materialtype>
		<materialtype code="ka" tag="000_06_2">
			<desc>Photograph, Print, Drawing</desc><short>Photograph/Art</short>
		</materialtype>
		<materialtype code="kb" tag="000_06_2">
			<desc>Photograph, Print, Drawing</desc><short>Photograph/Art</short>
		</materialtype>
		<materialtype code="kc" tag="000_06_2">
			<desc>Photograph, Print, Drawing (Collection)</desc><short>Photograph/Art</short>
		</materialtype>
		<materialtype code="kd" tag="000_06_2">
			<desc>Photograph, Print, Drawing (Part of Collection)</desc><short>Photograph/Art</short>
		</materialtype>
		<materialtype code="ki" tag="000_06_2">
		<desc>Photograph, Print, Drawing (Web site, database, etc.)</desc><short>Photograph/Art</short>
	</materialtype>
	
		<materialtype code="km" tag="000_06_2">
			<desc>Photograph, Print, Drawing</desc><short>Photograph/Art</short>
		</materialtype>
		<materialtype code="ks" tag="000_06_2">
			<desc>Photograph, Print, Drawing (Serial)</desc><short>Photograph/Art</short>
		</materialtype>
		<materialtype code="ma" tag="000_06_2">
			<desc>Computer File</desc><short>Computer File</short>
		</materialtype>
		<materialtype code="mb" tag="000_06_2">
			<desc>Computer File</desc><short>Computer File</short>
		</materialtype>
		<materialtype code="mc" tag="000_06_2">
			<desc>Computer File (Collection)</desc><short>Computer File</short>
		</materialtype>
		<materialtype code="md" tag="000_06_2">
			<desc>Computer File (Part of Collection)</desc><short>Computer File</short>
		</materialtype>		
	<materialtype code="mi" tag="000_06_2">
		<desc>Computer File (Web site, database, etc.)</desc>
	</materialtype>	
		<materialtype code="mm" tag="000_06_2">
			<desc>Computer File</desc><short>Computer File</short>
		</materialtype>
		<materialtype code="ms" tag="000_06_2">
			<desc>Computer File (Serial)</desc><short>Computer File</short>
		</materialtype>
		<materialtype code="oa" tag="000_06_2">
			<desc>Kit</desc><short>Kit</short>
		</materialtype>
		<materialtype code="ob" tag="000_06_2">
			<desc>Kit</desc><short>Kit</short>
		</materialtype>
		<materialtype code="oc" tag="000_06_2">
			<desc>Kit (Collection)</desc><short>Kit</short>
		</materialtype>
		<materialtype code="od" tag="000_06_2">
			<desc>Kit (Part of Collection)</desc><short>Kit</short>
		</materialtype>
		<materialtype code="om" tag="000_06_2">
			<desc>Kit</desc><short>Kit</short>
		</materialtype>
		<materialtype code="os" tag="000_06_2">
			<desc>Kit (Serial)</desc><short>Kit</short>
		</materialtype>
		<materialtype code="pa" tag="000_06_2">
			<desc>Archival Manuscript Material</desc><short>Manuscript</short>
		</materialtype>
		<materialtype code="pb" tag="000_06_2">
			<desc>Archival Manuscript Material</desc><short>Manuscript</short>
		</materialtype>
		<materialtype code="pc" tag="000_06_2">
			<desc>Archival Manuscript Material (Collection)</desc><short>Manuscript</short>
		</materialtype>
		<materialtype code="pd" tag="000_06_2">
			<desc>Archival Manuscript Material (Part of Collection)</desc><short>Manuscript</short>
		</materialtype>
		<materialtype code="pm" tag="000_06_2">
			<desc>Archival Manuscript Material</desc><short>Manuscript</short>
		</materialtype>
		<materialtype code="ps" tag="000_06_2">
			<desc>Archival Manuscript Material (Serial)</desc><short>Manuscript</short>
		</materialtype>
		<materialtype code="ra" tag="000_06_2">
			<desc>Three-Dimensional Object</desc><short>3-D Object</short>
		</materialtype>
		<materialtype code="rb" tag="000_06_2">
			<desc>Three-Dimensional Object</desc><short>3-D Object</short>
		</materialtype>
		<materialtype code="rc" tag="000_06_2">
			<desc>Three-Dimensional Object (Collection)</desc><short>3-D Object</short>
		</materialtype>
		<materialtype code="rd" tag="000_06_2">
			<desc>Three-Dimensional Object (Part of Collection)</desc><short>3-D Object</short>
		</materialtype>
		<materialtype code="rm" tag="000_06_2">
			<desc>Three-Dimensional Object</desc><short>3-D Object</short>
		</materialtype>
		<materialtype code="rs" tag="000_06_2">
			<desc>Three-Dimensional Object (Serial)</desc><short>3-D Object</short>
		</materialtype>
		<materialtype code="ta" tag="000_06_2">
			<desc>Archival Manuscript Material</desc><short>Manuscript</short>
		</materialtype>
		<materialtype code="tb" tag="000_06_2">
			<desc>Archival Manuscript Material</desc><short>Manuscript</short>
		</materialtype>
		<materialtype code="tc" tag="000_06_2">
			<desc>Archival Manuscript Material (Collection)</desc><short>Manuscript</short>
		</materialtype>
		<materialtype code="td" tag="000_06_2">
			<desc>Archival Manuscript Material (Part of Collection)</desc><short>Manuscript</short>
		</materialtype>
		<materialtype code="tm" tag="000_06_2">
			<desc>Archival Manuscript Material</desc><short>Manuscript</short>
		</materialtype>
		<materialtype code="ts" tag="000_06_2">
			<desc>Archival Manuscript Material (Serial)</desc><short>Manuscript</short>
		</materialtype>
		<materialtype code="[007_00_1]" tag="007_00_1"/>
		<materialtype code="a" tag="007_00_1">
			<desc>Cartographic Material (Map)</desc><short>Map/Cartography</short>
		</materialtype>
		<materialtype code="c" tag="007_00_1">
			<desc>Computer File</desc><short>Computer File</short>
		</materialtype>
		<materialtype code="d" tag="007_00_1">
			<desc>Cartographic Material (Globe)</desc><short>Map/Cartography</short>
		</materialtype>
		<materialtype code="g" tag="007_00_1">
			<desc>Projected Image (Still)</desc><short>Film/Video/Slide</short>
		</materialtype>
		<materialtype code="h" tag="007_00_1">
			<desc>Microform</desc><short>Microformat</short>
		</materialtype>
		<materialtype code="k" tag="007_00_1">
			<desc>Visual Material (Photographs, Prints, etc.)</desc><short>Photograph/Art</short>
		</materialtype>
		<materialtype code="m" tag="007_00_1">
			<desc>Projected Image (Moving)</desc><short>Film/Video/Slide</short>
		</materialtype>
		<materialtype code="s" tag="007_00_1">
			<desc>Sound Recording</desc><short>Sound Recording</short>
		</materialtype>
		<materialtype code="r" tag="007_00_1">
			<desc>Remote-Sensing Image</desc><short>Map/Cartography</short>
		</materialtype>
		<materialtype code="t" tag="007_00_1">
			<desc>Text (Printed or Manuscript)</desc><short>Book</short>
		</materialtype>
		<materialtype code="v" tag="007_00_1">
			<desc>Videorecording</desc><short>Film/Video/Slide</short>
		</materialtype>
		<materialtype code="z" tag="007_00_1">
			<desc>Unspecified</desc><short>Other</short>
		</materialtype>
		<materialtype code="[006_00_1]" tag="006_00_1"/>
		<materialtype code="a" tag="006_00_1">
			<desc>Textual Material</desc><short>Book</short>
		</materialtype>
		<materialtype code="c" tag="006_00_1">
			<desc>Printed Music</desc><short>Printed Music</short>
		</materialtype>
		<materialtype code="d" tag="006_00_1">
			<desc>Manuscript Music</desc><short>Manuscript Music</short>
		</materialtype>
		<materialtype code="e" tag="006_00_1">
			<desc>Cartographic Material</desc><short>Map/Cartography</short>
		</materialtype>
		<materialtype code="f" tag="006_00_1">
			<desc>Manuscript Map</desc><short>Map/Cartography</short>
		</materialtype>
		<materialtype code="g" tag="006_00_1">
			<desc>Moving Image or Slide/Transparency</desc><short>Film/Video/Slide</short>
		</materialtype>
		<materialtype code="i" tag="006_00_1">
			<desc>Non-music Sound Recording</desc><short>Audio (Spoken)</short>
		</materialtype>
		<materialtype code="j" tag="006_00_1">
			<desc>Music Sound Recording</desc><short>Audio (Music)</short>
		</materialtype>
		<materialtype code="k" tag="006_00_1">
			<desc>Photograph, Print, Drawing</desc><short>Photograph/Art</short>
		</materialtype>
		<materialtype code="m" tag="006_00_1">
			<desc>Computer File</desc><short>Computer File</short>
		</materialtype>
		<materialtype code="o" tag="006_00_1">
			<desc>Kit</desc><short>Kit</short>
		</materialtype>
		<materialtype code="p" tag="006_00_1">
			<desc>Mixed Material</desc><short>Other</short>
		</materialtype>
		<materialtype code="r" tag="006_00_1">
			<desc>Three-Dimensional Object</desc><short>3-D Object</short>
		</materialtype>
		<materialtype code="s" tag="006_00_1">
			<desc>Serial</desc><short>Journal/Periodical</short>
		</materialtype>
		<materialtype code="t" tag="006_00_1">
			<desc>Manuscript Textual Material</desc><short>Manuscript</short>
		</materialtype>
		      <!-- mods materials -->
    
     <materialtype code="mods" tag="text">
        <desc>Book (Print, Microform, Electronic, etc.)</desc><short>Book</short>
    </materialtype>
    <materialtype code="mods" tag="text" manuscript="yes">
            <desc>Archival Manuscript Material</desc><short>Manuscript</short>
        </materialtype> 
     <materialtype code="mods" tag="cartographic">
        <desc>Cartographic Material</desc><short>Map/Cartography</short>
    </materialtype>
    <materialtype code="mods" tag="cartographic" manuscript="yes">
    <desc>Manuscript Cartographic Material</desc><short>Map/Cartography</short>
    </materialtype>
    
    <materialtype code="mods" tag="notated music">
        <desc>Printed Music (Part or Selection)</desc><short>Printed Music</short>
    </materialtype>
    <materialtype code="mods" tag="notated music" manuscript="yes">
    <desc>Manuscript Music</desc><short>Manuscript Music</short>
    </materialtype>
    <materialtype code="mods" tag="notated music" collection="yes">
    <desc>Manuscript Music (Collection)</desc><short>Manuscript Music</short>
    </materialtype>
    <materialtype code="mods" tag="sound recording-nonmusical">
            <desc>Non-music Sound Recording</desc><short>Audio (Spoken)</short>
        </materialtype>
        <materialtype code="mods" tag="sound recording-musical">
            <desc>Music Sound Recording</desc><short>Audio (Music)</short>
        </materialtype>
          <materialtype code="mods" tag="sound recording">
            <desc>Music Sound Recording</desc><short>Audio</short>
        </materialtype>
  <materialtype code="mods" tag="still image">
        <desc>Photograph, Print, Drawing</desc><short>Photograph/Art</short>
    </materialtype>
    <materialtype code="mods" tag="moving image">
        <desc>Moving Image or Slide/Transparency</desc><short>Film/Video/Slide</short>
    </materialtype>
<materialtype code="mods" tag="three dimensional object">
            <desc>Three-Dimensional Object</desc><short>3-D Object</short>
        </materialtype>  
    <materialtype code="mods" tag="software, multimedia">       
            <desc>Computer File</desc><short>Computer File</short>        
        </materialtype> 
        <materialtype code="mods" tag="software, multimedia" collection="yes">        
            <desc>Computer File (Collection)</desc><short>Computer File</short>        
        </materialtype>
	</materials>	
};
