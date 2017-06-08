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
            //source: "/nlc/suggest.xqy?mime=application/json&qname=" + qname
            source: function(req, add){
				//pass request to server
				$.getJSON("/nlc/suggest.xqy?mime=application/json&qname=" + qname, req, function(data) {
					//create array for response objects
					var suggestions = [];
					//embed responses in quotes
					$.each(data, function(i, val) {
					   suggestions.push('"' + val.label + '"');
				    });
				//pass array to callback
				add(suggestions);
			});
		}
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

var current_page = 2;  //load page 1 by default, so start at 2 for infinite scroll

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
	var submitButton = $("button#indexSubmit", "form#quick-search").click(function(e) {
		e.preventDefault();
		wipeText();
		$("form#quick-search").submit();
		
	});
	
	// autosuggest toggle
	$("input.searchOptionRadioControl", "div#quick-search-options").click(function(e){
		var value = $(this).attr("value");
		mainPageSuggester(value);
	});
    
    var startingSuggest = $("#lc-fielded option:selected").attr("value");
    if(typeof startingSuggest != "undefined") {
        mainPageSuggester(startingSuggest);
    }
	
    $("span.remove-facet > a").hover(
        function () {
            $(this).addClass("hover");
        },
        function () {
            $(this).removeClass("hover");
        }
    );
	
    $('h3.title-name').each(function() {
	$(this).qtip(
	{
		content: {
                	//text: false,
			url: "/nlc/facet-tooltip.xqy?facet=" + $(this).attr("id"),
			title: {
				text: 'Facet - ' + $(this).text()
			}
                },
		position: {
			corner: {
				target: 'topLeft',
				tooltip: 'bottomRight'
			},
			adjust: {
				screen: true
			}
		},
          	style: { 
             		name: 'light',
			width: 570,
             		tip: true,
             		border: {
         			radius: 8
             		}
	  	}
    	});
    });

    $('.glossary-tei').each(function() {
        $(this).qtip(
        {
                content: {
                        text: $("span.def-box", this),
                        title: {
                                text: $("span.def-label", this).text()
                        }
                },
                position: {
                        adjust: {
                                screen: true
                        }
                },
                style: {
                        name: 'cream', 
                        width: 570,
                        tip: true, 
                        border: {
                                radius: 8
                        }
                }
        });     
    });

    // $("#fulltext-tabs ul").idTabs();
    
    $("#commentform").validate({
        messages: {
            fbkemail: "Please enter a valid email address. The mailer will verify that the email account exists before submitting any feedback data you provide."
        }
    });
    
    $("a.get_holdings").click(function () {
        var url = $("a#holdings_tab_url").attr("href");
        $.get(url, function(data){
                $("div#holdings").html(data);
                $('ul.tabnav a[href="#holdings"]').parent().trigger('click');
            });
        return false;
    });
    
    $('a.more_results').live('click', function() {
        //console.log($('div#scrolls_search').width());
        var prefix = $("a#search_tab_url").attr("href");
        if (prefix != undefined) {
           var url2 = prefix + "&page="+current_page;
           $.ajax({
                    type:"GET", 
                    url: url2, 
                    async: false,
                    success: function(data){
                        var lis = $(data).find("li");
                        $("ul.scrolls").append(lis);
                        // replace with results from search page (which will disable link
                        // to do more searching if there are no more results
                        var new_p = $(data).find("p.more_results");
                        $('div.more_results').html(new_p);
                        current_page++;
                    }
                });
        }
         
        return false;
    });
    
    $("a.get_search_results").click(function () {
        current_page = 2;
        var url = $("a#search_tab_url").attr("href");
        $.ajax({
            type:"GET", 
            url: url, 
            async: false,
            success: function(data){
                $("div#search").html(data);
                $('ul.tabnav a[href="#search"]').parent().trigger('click');
            }
        });
        return false;
    });
    
});

// When submitting a new search query from the Search Results
function searchFullText(form) {
    var url_prefix = form.url.value;
    var q = form.q.value;
    if (q == '') {
        alert("Please enter a search term.");
        return false;
    }
    var new_url = url_prefix + "&q=" + q;
    $("a#search_tab_url").attr("href", new_url);
    $("a.get_search_results").click();
    return false;
}
