var begincrumb = '<a href="http://www.loc.gov">The Library of Congress</a><span class="crumb-gt"> &gt; </span><a href="/">National Library Catalog (beta)</a><span class="crumb-gt"> &gt; </span>';

/** setup jquery address actions based on the rel attribute of a tags */
function setRelLinks() {
	$('a').click(function (e) {
		var rel = $(this).attr('rel');
		if (rel != null && rel != '') {
			e.preventDefault();
			$.address.value(rel);
			 /*
			 var decoded = decodeURI(rel);
			 $.address.value(decoded);
			 */
		}
	});
} /** ### FACET BOX min max toggle ### */
function toggleFacetBox(link, idStr) {
	if (link.text() == "+") {
		link.text("-");
	} else {
		link.text("+");
	}
	$("div.content[id=" + idStr + "]").toggle(200);
} /** setup the facet box toggles */
function initFacetToggles() {
	$("span.title-toggle > a").each(function () {
		$(this).toggleClass("hidden");
		$(this).click(function (e) {
			e.preventDefault();
			var idStr = $(this).attr("id");
			toggleFacetBox($(this), idStr);
		});
	});
} /** setup the actions for entity links (currently disabled) */
function setUpEntityEvents() {
	//alert("entity events");
	$("span.entity", "#content").each(function () {
		$(this).click(function (e) {
			e.preventDefault();
			//var typeStr = $(this).attr("type");
			//var textStr = $(this).text();
			//alert("Clicked "+ typeStr+ ": "+ textStr);
		});
	});
} /** utility function, gets the value from the & delimited parameter string */
function paramVal(str, token) {
	var tokenIndex = str.indexOf(token + "=")
	if (tokenIndex == -1) return "";
	var nextBreak = str.indexOf("&", tokenIndex)
	var phrase = nextBreak == -1 ? str.substring(tokenIndex) : str.substring(tokenIndex, nextBreak);
	return phrase.substring(phrase.indexOf("=") + 1)
} /** setup action for the main search box, includes both search and autocomplete */
function setupSearch() {
	var textForm = $('#quick-search');
	var textField = $("#quick-search-box");
	textField.autocomplete({
		minLength: 3,
		//delay: 750,
		source: function (req, add) {
			var term = $("#quick-search-box").val()
			$.get("/xq/lscoll/suggest.xqy?term=" + encodeURIComponent(term), function (data) {
				add(data.split(","));
			});
		}
	});
	// for firefox sumbission (ie submission causes submit event directly)
	textField.keyup(function (e) {
		if (e.keyCode == 13) {
			e.preventDefault();
			textForm.submit();
		};
	});
	// button click
	$("#lc-ajax-button").click(function (e) {
		e.preventDefault();
		textForm.submit();
	});
	// ie submit event and override of submit event
	textForm.submit(function (e) {
		e.preventDefault();
		submitSearchText();
	});
} /** helper function for fading and removing an item div */
function fadeAndRemove(item) {
	$(item + " > div").each(function () {
		$(this).fadeOut(250, function () {
			$(this).remove();
		});
	});
} /** setup handler for jquery address action */
function historyPageInit() {
	$.address.change(function (e) {
		if (e.value != "/" && e.value != "") {
			//alert(e.value);			
			var page = paramVal(e.value, 'page');
			if ((page == 'detail') || (page == 'results') || (page == 'browse') || (page == 'search')) {
				$("#ds-results").html("<div style='width:100%;text-align:center;'><img src='/static/lds/images/ajax-loader.gif'/></div>");
			}
			$.ajax({
				type: "GET",
				//cache: false,
				url: '/xq/lscoll/parts/ajaxPage.xqy',
				data: e.value,
				dataType: 'html',
				success: function (data) {
					$(".ui-autocomplete").remove();
					$("#ds-body").html($(data).find('#search-results'));
					setupSearch();
					if (page == 'search') {
						$("#ds-leftcol").css("visibility", "visible");
						//fadeAndRemove( "#ds-controls" );
						//fadeAndRemove( "#ds-hitlist" );
						$.address.title("Search (National Library Collections, Library of Congress)");
					} else if (page == 'results') {
						//fadeAndRemove( "#content" );
						$("#ds-leftcol").css("visibility", "visible");
						$("#ds-results").html($(data).find('#results-results'));
						var mypath = $.address.path();
						var resultq = paramVal(e.value, 'q');
						var pretitle = "Search Results (National Library Collections, Library of Congress)";
						if (resultq.length > 0) {
							var lctitle = pretitle + ": " + unescape(paramVal(e.value, 'q'));
						} else {
							var lctitle = pretitle;
						}
						$.address.title(lctitle);
						var rescrumb = begincrumb + '<a href="/xq/lscoll/">Search</a><span class="crumb-gt"> &gt; </span><span id="ds-searchcrumb">Search results</span>';
						$("#crumb_nav").html(rescrumb);
						var atompathpre = mypath.replace(/page=results&/, "");
						var atompath = atompathpre.replace(/&mime=text\/html/, "");
						var atom = '<link id="ds-atomfeed" rel="alternate" href="/xq/lscoll/atom.xqy?' + atompath + '" type="application/atom+xml" title="National Library Collections Search Results" />';
						$("#ds-atomfeed").remove();
						$("head").append(atom);
					} else if (page == 'detail') {
						//fadeAndRemove("#ds-hitlist");
						//fadeAndRemove( "#results" );
						$("#ds-leftcol").css("visibility", "hidden");
						$("#ds-results").html($(data).find('#content-results'));
						var titletop = $("#title-top").text();
						var backto = $("#backtoresults").attr("href");
						var detailcrumb = begincrumb + '<a href="' + backto + '">Search results</a><span class="crumb-gt"> &gt; </span><span id="ds-searchcrumb">' + titletop + '</span>';
						$("#crumb_nav").html(detailcrumb);
						var detailtitle = "Result (National Library Collections, Library of Congress)";
						$.address.title(detailtitle + ": " + titletop);
					} else if (page == 'browse') {
						$("#ds-leftcol").css("visibility", "hidden");
						$("#ds-results").html($(data).find('#ds-browseresults'));
						var browseparam = paramVal(e.value, 'browse');
						if (browseparam == 'class') {
						  var browsetype = "classes";
                        } else {
                          var browsetype = browseparam + "s";
                        }
                        var backto = $("#backtodetail").attr("href");
                        var browsecrumb = begincrumb + '<a href="' + backto + '">Search results</a><span class="crumb-gt"> &gt; </span><span id="ds-searchcrumb">Browse ' + browsetype + '</span>';
						$("#crumb_nav").html(browsecrumb);
						var browsetitle = "Browse Results (National Library Collections, Library of Congress)";
						var browseq = paramVal(e.value, 'q');
						if (browseq.length > 0) {
							var btitle = browsetitle + ": " + unescape(browseq);
						} else {
							var btitle = browsetitle;
						}
						$.address.title(btitle);
					}
					$("#ds-facets").html($(data).find('#facet-results'));
					initFacetToggles();
					setRelLinks();
					$('html, body').animate({
						scrollTop: 0
					}, 300);
					if (page == 'results') {
						$("#ds-hitlist").fadeIn(500);
					} else if (page == 'detail') {
						$("#content").fadeIn(500);
					}
				}
			});
		}
	});
} /** for navigating in the more facybox */
function moreNav(rel) {
	var content = $(".content", "#facybox");
	var oldfacet = $('#facetmorediv', content);
	$('<div id="replaceme" style="width:795px;text-align:center;"><img src="/static/lds/images/ajax-loader.gif"/></div>').insertAfter(oldfacet);
	oldfacet.remove();
	$.ajax({
		type: "POST",
		cache: false,
		url: rel,
		dataType: 'html',
		success: function (data) {
			$('#replaceme', content).replaceWith($(data));
		}
	});
} /** ### main script on page ready ### */
$(document).ready(function ($) {
	// On Address Change, change what is in the detail div
	historyPageInit();
}); /** sort order toggling */
function sortOrderSel(obj) {
	var mypath = $.address.path();
	if (obj.value == "score-desc") {
		var newpath = mypath.replace(/sort=(score|pubdate|cre)-(asc|desc)/, "sort=score-desc");
		$.address.path(newpath);
	} else if (obj.value == "score-asc") {
		var newpath = mypath.replace(/sort=(score|pubdate|cre)-(asc|desc)/, "sort=score-asc");
		$.address.path(newpath);
	} else if (obj.value == "cre-desc") {
		var newpath = mypath.replace(/sort=(score|pubdate|cre)-(asc|desc)/, "sort=cre-desc");
		$.address.path(newpath);
	} else if (obj.value == "cre-asc") {
		var newpath = mypath.replace(/sort=(score|pubdate|cre)-(asc|desc)/, "sort=cre-asc");
		$.address.path(newpath);
	} else if (obj.value == "pubdate-asc") {
		var newpath = mypath.replace(/sort=(score|pubdate|cre)-(asc|desc)/, "sort=pubdate-asc");
		$.address.path(newpath);
	} else if (obj.value == "pubdate-desc") {
		var newpath = mypath.replace(/sort=(score|pubdate|cre)-(asc|desc)/, "sort=pubdate-desc");
		$.address.path(newpath);
	} else {
		var newpath = mypath.replace(/sort=.+/, "sort=score-desc");
		$.address.path(newpath);
	}
} /** toggling number of hits per page */
function numHitsSel(obj) {
	var mypath = $.address.path();
	if (obj.value == "hits25") {
		var newpath = mypath.replace(/count=\d*/, "count=25");
		$.address.path(newpath);
	} else if (obj.value == "hits10") {
		var newpath = mypath.replace(/count=\d*/, "count=10");
		$.address.path(newpath);
	} else {
		var newpath = mypath.replace(/count=\d*/, "count=10");
		$.address.path(newpath);
	}
} /** Handler for when search is submitted */
function submitSearchText() {
	var textBox = $("#quick-search-box");
	var existingParams = textBox.attr("rel");
	var textBoxVal = textBox.val();
	if (textBoxVal.length == 0 || textBoxVal == "Enter search word(s)") {
		var mypath = $.address.path();
		var resultspath = mypath.replace(/page=search/, "page=results");
		$.address.path(resultspath);
	} else {
		var addressVal = existingParams + '&q=' + textBoxVal;
		$.address.value(addressVal);
	}
}
var clearSearchBox = function (id) {
	var newid = '#' + id;
	var text = $(newid).attr("value");
	if (text == "Enter search word(s)") {
		$(newid).attr("value", "");
	}
}
function showSearchOptions() {
	if (document.getElementById("searchOptionsContainer").style.display == "" || document.getElementById("searchOptionsContainer").style.display == "none") {
		document.getElementById("errorMsg1").innerHTML = "";
		document.getElementById("errorMsg1").style.display = "none";
		document.getElementById("subTabSearchHelpText").style.display = "none";
		document.getElementById("searchOptionsContainer").style.display = "block";
		$('#limits-mover').toggleClass('limits-container-move');
		$("#newOptionsMenu").attr("src", "/static/lds/images/bg_options-up.gif");
	} else {
		document.getElementById("searchOptionsContainer").style.display = "none";
		document.getElementById("errorMsg1").innerHTML = "";
		document.getElementById("errorMsg1").style.display = "block";
		document.getElementById("subTabSearchHelpText").style.display = "block";
		$('#limits-mover').toggleClass('limits-container-move');
		$("#newOptionsMenu").attr("src", "/static/lds/images/bg_options.gif");
	}
}
function suggester(qname) {
	var mypath = $.address.path();
	if (qname == "idx:mainCreator" || qname == "idx:titleLexicon" || qname == "idx:subjectLexicon") {
		$.address.path(mypath + "&qname=" + qname);
	} else {
		return null;
	}
}
function mainPageSuggester(qname) {
	if (qname == "keyword") {
		return null;
	} else {
		var textField = $("#quick-search-box");
		textField.autocomplete({
			minLength: 3,
			source: function (req, add) {
				var term = $("#quick-search-box").val();
				$.get("/xq/lscoll/suggest.xqy?qname=" + qname + "&term=" + encodeURIComponent(term), function (data) {
					add(data.split(","));
				});
			}
		});
	}
}

function fieldedSel(obj) {
        var mypath = $.address.path(); 
	var textBoxVal = $("#quick-search-box").val();
	if (textBoxVal.length !== 0 && textBoxVal !== "Enter search word(s)") {
		var myq = encodeURIComponent(textBoxVal);
        	if (obj.value == "keyword") {   
                	var newpath = mypath.replace(/qname=.+/, "qname=keyword&q=" + myq);
                	$.address.path(newpath);
        	} else if (obj.value == "idx:mainCreator") {
                	var newpath = mypath.replace(/qname=.+/, "qname=idx:mainCreator&q=" + myq);
                	$.address.path(newpath);
        	} else if (obj.value == "idx:subjectLexicon") {
                	var newpath = mypath.replace(/qname=.+/, "qname=idx:subjectLexicon&q=" + myq);
                	$.address.path(newpath);
        	} else if (obj.value == "idx:titleLexicon") {
                	var newpath = mypath.replace(/qname=.+/, "qname=idx:titleLexicon&q=" + myq);
                	$.address.path(newpath);
        	} else {
                	var newpath = mypath.replace(/qname=.+/, "qname=keyword&q=" + myq);
                	$.address.path(newpath);
        	}
	}
}
