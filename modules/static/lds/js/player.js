var json_list;
var metadataTextVar;

function clean_json(html_json) {
    var add_diglib = false;
    var path = window.location.pathname;
	if (path.indexOf('diglib') != -1) {
	   add_diglib = true;
	} 
    for (var i = 0; i < html_json.length; i++) {
        if (html_json[i].artists == null) {
            html_json[i].artists = '';
        }
        if (html_json[i].date == null) {
            html_json[i].date = '';
        }
        if (html_json[i].title == null) {
            html_json[i].title = '';
        }
        html_json[i].provider = 'http';
        html_json[i].autoPlay = false;
        
        if (add_diglib) {
            var old_url = html_json[i].url;
            html_json[i].url = '/diglib'+old_url;
        }
    }
    json_list = html_json;
    
    var first = json_list[0];
    if (first["size"] == "0") {
        metadataTextVar = {
            	url: 'http://media.loc.gov/player/flowplayer.content.swf',
                backgroundColor: 'transparent',
                backgroundGradient: 'none',
                top: 10,
	            left: 15,
                height: 60,
                border: 0,
                borderRadius: 0,
                html: '<p>There is no audio for '+json_list[0]["title"]+'.</p>',
                stylesheet: 'http://media.loc.gov/loader/css/audioView.css'
		    }
    } else  {
        metadataTextVar = {
            	url: 'http://media.loc.gov/player/flowplayer.content.swf',
                backgroundColor: 'transparent',
                backgroundGradient: 'none',
                top: 10,
	            left: 15,
                height: 60,
                border: 0,
                borderRadius: 0,
                html: '<p>Loading audio...</p>',
                stylesheet: 'http://media.loc.gov/loader/css/audioView.css'
		    }
    }
    
     player = $f("lcPlaylistPlayer", { 
		src:'http://media.loc.gov/player/flowplayer.commercial.swf',
		wmode:'opaque',
		bgcolor:'#6A6A6A'
	}, 
	{
        key:'#@866c218c34a7a0fc041',
        clip:{
			scaling:'fit',
            autoPlay: true,
			onBegin:function(){
				var currentArtists = $f().getClip().artists;
				var currentDate = $f().getClip().date;
				var currentTitle = $f().getClip().title;
				//currentTitle = '0000 1111 2222 3333 4444 5555 6666 7777 8888 9999 0000 1111 2222 3333 4444 5555';
				$f().getPlugin("metadataText").setHtml("<p>"+currentTitle+"<br />" +currentArtists+"<br />"+currentDate+"</p>");
				$f().getScreen().fadeOut();
				$f().flowplayer.audio.swfgetPlugin("metadataText").fadeIn(100);
				$f().getPlugin("metadataText").animate({top:220},525);
			}
		},
        canvas: {
			background: '#ffffff url(http://media.loc.gov/images/audio-522.png) no-repeat 0 0',
            backgroundGradient: 'none',
            border: 0
		},
		play: null,
		plugins: {
        	controls: {
            	url:'http://media.loc.gov/player/flowplayer.controls-loc.swf',
                bottom:34, height:34, backgroundColor:'transparent', backgroundGradient:'none',
                timeColor:'#ffffff', durationColor:'#bbbbbb', timeFontSize:11,
                all:false, 
                play:true, 
                scrubber:true, 
                volume:true, 
                mute:true, 
                time:true, 
                fullscreen:false, 
                autoHide:'never',
                playlist:false
		    },
            metadataText: metadataTextVar,
            audio:{
            	url:'http://media.loc.gov/player/flowplayer.audio.swf',
                durationFunc: 'getStreamLength'
	        }
	   },
	   contextMenu:[
        	'Library of Congress', {
            	'Library of Congress Home Page': function() {
					location.href = 'http://www.loc.gov/';
				}
			}
		]
    });

    player.load();

    if (first["size"] != "0") {
        first_clip = {url: first["url"], artists: first["artists"], title: first["title"], date: first["date"]};
    } else {
        first_clip = {};
    }
    player.getClip(0).update(first_clip);
    player.play();

    // trigger transcript div for first TEI part
    var tei_id = $("a.player_trigger:first").attr("id");
    $("a.player_trigger:first").addClass("current");
    setTranscript(tei_id);
}

var player;
var first_clip;
$(document).ready(function () {
    // When user clicks on a new part to play (from right hand column)
    // Changes what is loaded in player
    $("a.player_trigger").live('click', function () {
        // e.g. id="T02"
        var old_id = $("a.player_trigger.current").attr("id");
        var tei_id = $(this).attr("id");
        if (old_id != tei_id) {
            //trigger new player
            $("a.player_trigger.current").removeClass("current");
            $(this).addClass("current");
            changePlayer(tei_id);
        
            // trigger transcript div
            setTranscript(tei_id);
            $('ul.tabnav a[href="#transcript"]').parent().trigger('click');
        }
        return false;
    });
  
  /* 
  * When a user clicks "Go" from the Search results, it changes what is
  * is playing in the audio player and changes the Transcript tab, scrolling to anchored text
  */
  $("a.snippet_trigger").live('click', function () {
        // e.g. id="T02#d15e171"
        var text_id = $(this).attr("id");
        var parts = text_id.split('_');
        var tei_id = parts[0];
        var p_id = parts[1];
        
        var old_id = $("a.player_trigger.current").attr("id");
        if (old_id != tei_id) {
            //trigger player when it's new audio
            $("a.player_trigger.current").removeClass("current");
            $("a.player_trigger#"+tei_id).addClass("current");
        
            changePlayer(text_id);
        }
        
        // always trigger Transcript and scroll to paragraph
        var url = getTEIUrl("div", tei_id);        
        $.get(url, function(data){
                $("div#tei-div").html(data);
                $('ul.tabnav a[href="#transcript"]').parent().trigger('click');
                var new_position = $('#'+p_id).offset();
                window.scrollTo(new_position.left,new_position.top);
        });
        return false;
  });
  
  /* When user initially clicks Search Results tab (using original search term) */
  $("a.get_snippets").click(function () {
    setSnippets();
    return false;
  });
});

function setSnippets() {
    var url = getTEIUrl("snippets", "");
    $.get(url, function(data){
                $("div#tei-snips").html(data);
                $('ul.tabnav a[href="#snippets"]').parent().trigger('click');
        });
}

function setTranscript(tei_id) {
    var url = getTEIUrl("div", tei_id);
    $.get(url, function(data){
        $("div#tei-div").html(data);
    });
}

function getTEIUrl(type, itemID) {
    var url = $("a#tei_tab_url").attr("href");
    url = url + "&tabtype="+type;
    if (itemID != "") {
        url = url+"&itemID="+itemID;
    }
    return url;
}

function setTEIUrl(new_url) {
    $("a#tei_tab_url").attr("href", new_url);
}

function changePlayer(text_id) {
    var code_id = "code#"+text_id;
    var text = $(code_id).text();
    var index = parseInt(text)-1;
    var array_obj = json_list[index];
    if (array_obj["size"] != "0") {
        player.setClip({url: array_obj["url"], artists: array_obj["artists"], title: array_obj["title"], date: array_obj["date"]});
        player.play();
    } else {
        player.stop();
        player.setClip({});
        var met = player.getPlugin("metadataText");
        met.setHtml("<p>There is no audio for "+array_obj["title"]+".</p>");
    }
}

// When submitting a new search query, from either the Search Results or Transcript tab
function searchFullText(form) {
    var url_prefix = form.url.value;
    var q = form.q.value;
    if (q == '') {
        alert("Please enter a search term.");
        return false;
    }
    var new_url = url_prefix + "&q=" + q; 
    setTEIUrl(new_url);
    
    setSnippets();
    
    var tei_id = $("a.player_trigger.current").attr("id");
    setTranscript(tei_id);
    
    return false;
}