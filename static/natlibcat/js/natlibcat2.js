/** ### FACET BOX min max toggle ### */
function toggleFacetBox(img, idStr) {
	if (img.attr('src') == "/static/natlibcat/images/accordion-closed.png") {
		img.attr("src", "/static/natlibcat/images/accordion-open.png");  //up
	} else {
		img.attr("src", "/static/natlibcat/images/accordion-closed.png");  //down
	}
	$("div.content[id=" + idStr + "]").toggle(200);
} 



/** setup the facet box toggles */
function initFacetToggles() { 
	$("div.title").each(function () {
		$(this).toggleClass("hidden");
        var mya = $(this).find("img");
		$(this).click(function (e) {
			e.preventDefault();
            var fid = mya.attr("id");
            var boxtoggle = fid.replace(/toggle-/, '');
            toggleFacetBox(mya, boxtoggle);
		});
	});
}

/** utility function, gets the value from the & delimited parameter string */
function paramVal(str, token) {
	var tokenIndex = str.indexOf(token + "=")
	if (tokenIndex == -1) return "";
	var nextBreak = str.indexOf("&", tokenIndex)
	var phrase = nextBreak == -1 ? str.substring(tokenIndex) : str.substring(tokenIndex, nextBreak);
	return phrase.substring(phrase.indexOf("=") + 1)
}

/** setup action for the main search box, includes both search and autocomplete */
function setupSearch() {
	var textForm = $('#quick-search');
	var textField = $("#quick-search-box");
	textField.autocomplete({
		minLength: 3,
		//delay: 750,
		source: function (req, add) {
			var term = $("#quick-search-box").val()
			$.get("/nlc/suggest.xqy?term=" + encodeURIComponent(term), function (data) {
				add(data.split(","));
			});
		}
	});
}

/** helper function for fading and removing an item div */
function fadeAndRemove(item) {
	$(item + " > div").each(function () {
		$(this).fadeOut(250, function () {
			$(this).remove();
		});
	});
} 

/** for navigating in the more facybox */
function moreNav(rel) {
	var content = $(".content", "#facybox");
	var oldfacet = $('#facetmorediv', content);
	$('<div id="replaceme" style="width:795px;text-align:center;"><img src="/static/natlibcat/images/ajax-loader.gif"/></div>').insertAfter(oldfacet);
	oldfacet.remove();
	$.ajax({
		type: "POST",
		cache: false,
		url: rel,
		dataType: 'html',
		success: function (data) {
			$('#replaceme', content).replaceWith($(data));
			prepMoreLinks();
		}
	});
}



function showSearchOptions() {
	var container = $("#searchOptionsContainer");
	/**
	var current = $("#searchOptionsContainer").css("display");
	if(current == "none") {
		container.css("display","block");
	} else {
		container.css("display","none");
	}
	*/
	/**
	if (document.getElementById("searchOptionsContainer").style.display == "" || document.getElementById("searchOptionsContainer").style.display == "none") {
		document.getElementById("errorMsg1").innerHTML = "";
		document.getElementById("errorMsg1").style.display = "none";
		document.getElementById("subTabSearchHelpText").style.display = "none";
		document.getElementById("searchOptionsContainer").style.display = "block";
		$('#limits-mover').toggleClass('limits-container-move');
		$("#newOptionsMenu").attr("src", "/static/natlibcat/images/bg_options-up.gif");
	} else {
		document.getElementById("searchOptionsContainer").style.display = "none";
		document.getElementById("errorMsg1").innerHTML = "";
		document.getElementById("errorMsg1").style.display = "block";
		document.getElementById("subTabSearchHelpText").style.display = "block";
		$('#limits-mover').toggleClass('limits-container-move');
		$("#newOptionsMenu").attr("src", "/static/natlibcat/images/bg_options.gif");
	}
	*/
}


// set up autocomplete for text box on main page
function mainPageSuggester(qname) {
	if (qname == "keyword" ) {
		return null;
	} else {
		var textField = $("#quick-search-box");
		textField.attr("autocomplete","off");
		textField.autocomplete({
			minLength: 3,
            appendTo: "#quick-search-box",
            dataType: "json",
            source: "/nlc/suggest.xqy?mime=application/json&qname=" + qname
		});
	}
}


// Helper function, clears the value of search box if it contains default tip text
function wipeText() {
	var textBox = $("#quick-search-box");
	if(textBox.val() == defaultsearchtext) {
		textBox.val("");
		textBox.attr("value","");
	}  else {
		textBox.attr("value",textBox.val());
	}
}

function prepMoreLinks() {

    $('a#morepaging','.content').click(function(e) {
        e.preventDefault();
        var rel = $(this).attr('href');
        moreNav(rel);
    });
}

// ** MAIN FUNCTION on document ready **
// set up jquery behavior for page.  will only work if javascript is enabled
$(document).ready( function ($) {

    initFacetToggles();
	
	// put 'Enter search word(s) into the text box
	var textBox = $("#quick-search-box");
	if(textBox.val() == "" || textBox.attr("value") == "" || textBox.attr("value") == defaultsearchtext) {
		textBox.val(defaultsearchtext);
		textBox.css("color","#bbbbbb");
		textBox.focus(function(e){
			$(this).val("");
			$(this).css("color","black");
			$(this).unbind('focus');
		});
	}
	
	// index submit button behavior
	var submitButton = $("button#indexSubmit","form#indexForm").click(function(e) {
		e.preventDefault();
		wipeText();
		$("form#indexForm").submit();
		
	});
	
	// quick search submit button behavior
	var submitButton = $("button#indexSubmit","form#quick-search").click(function(e) {
		e.preventDefault();
		wipeText();
		$("form#quick-search").submit();
		
	});
	
	// popup div for options
	$('#limits-mover').toggleClass('limits-container-move');
	$("#quick-search-options").toggle(); //.css("display","none");
	//$("#lowerSearchText").css("visibility","hidden");
	$("#quick-search-options-img").click(function(e){
		e.preventDefault();
		$('#limits-mover').toggleClass('limits-container-move');
		$("#quick-search-options").toggle();
	});
	
	// autosuggest toggle
	$("input.searchOptionRadioControl","div#quick-search-options-container").click(function(e){
		var value = $(this).attr("value");
		mainPageSuggester(value);
	});
	
	// autosuggest default
	var startingSuggest = $("input[name='qname']:checked", '#indexForm').val();
	if(typeof startingSuggest != "undefined") {
		mainPageSuggester(startingSuggest);
	} else {
		startingSuggest = $("#lc-fielded option:selected").attr("value");
		if(typeof startingSuggest != "undefined") {
			mainPageSuggester(startingSuggest);
		}
	}
	
	// search page quick-search fielded dropdown submission
	/**
	$("#lc-fielded","form#quick-search").change(function(e){
		e.preventDefault();
		wipeText();
		$("form#quick-search").submit();
	});
	*/
	
	// remove 'go' buttons and make search page option dropdowns auto-submit their forms
	$("input[type='submit']", "#search-result-options-form").remove();
	$("select","#search-result-options-form").change(function(e){
		$("#search-result-options-form").submit();
	});
	
	//Librarian MARC View from detail page
	$("#ds-marcview").click(function(e){
	    var objid = $("#detailURL").text();
		e.preventDefault();
		$.ajax({
            url: "/nlc/parts/ajax-MARC.xqy?view=ajax&objid=" + objid,
            success: function(data){
                $.facybox(data);
            }
        });
	});

	// "more" facets
	$(".facet-more").each(function(){
		$(this).click(function(e){
			e.preventDefault();
			$.ajax({
	            		url: $(this).attr("href").replace(/view=full/, "view=ajax"),
	            		success: function(data){
	                		$.facybox(data);
	                		prepMoreLinks();
	            		}
	        	});
		});	
	});
    
    $("span.remove-facet > a").hover(
        function () {
            $(this).addClass("hover");
        },
        function () {
            $(this).removeClass("hover");
        }
    );
	
    $("#fulltext-tabs ul").idTabs();

});
