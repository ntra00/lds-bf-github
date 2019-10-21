jQuery(function() {
	var dataString = 'q=' + facetsdata.search + '&field=' + facetsdata.field;
	var facetsDataString = dataString + '&start=' + facetsdata.start + '&count=' + facetsdata.count ;
	var img = '<img id="loader-img" src="/marklogic/static/img/ajax-loader-snake.gif"/>';
    var loading = '<div style="margin-top: 7px;" id="loading-results-text">Loading Results...</div>';
    var tmpdiv = '<div id="facets-tmpdiv" style="text-align: center; margin: auto; font-size: 9px; color: #990000;">' + img + loading + '</div>';
    var top = $('#facets-space').offset().top - parseFloat($('#facets-space').css('marginTop').replace(/220px/, 0));
    jQuery.ajax({
        type: "GET",
        url: "facets.xqy",
        data: facetsDataString,
        dataType: "html",
        cache: true,
        beforeSend: function(html) {
            $("#facets-filter").after(tmpdiv);
        },
        success: function(html) {
            $("#facets-tmpdiv").remove();
            $("#facets-filter").after(html);
            var icons = {
        		header: "ui-icon-circle-arrow-e",
        		headerSelected: "ui-icon-circle-arrow-s"
        	};
        	$("#facets-accordion").accordion({
        		active: true,
        		header: "h3",
        		collapsible: true,
        		autoHeight: true,
        		fillSpace: false,
        		icons: icons
        	});
        },
        error: function(xhr, ajaxOptions, thrownError) {
            $("#facets-space").append(thrownError);
        }
    });
    function log(message) {
		$("<div/>").text(message).after("#q");
	}
	var cache = {};
	jQuery("#q").autocomplete({
    	source: function(request, response) {
    	    if (cache.term == request.term && cache.content) {
				response(cache.content);
			}
			if (new RegExp(cache.term).test(request.term) && cache.content && cache.content.length < 13) {
				var matcher = new RegExp($.ui.autocomplete.escapeRegex(request.term), "i");
				response($.grep(cache.content, function(value) {
    				return matcher.test(value.value)
				}));
			}
            jQuery.ajax({
            	url: "suggest.xqy",
            	dataType: "json",
            	data: request,
            	//data: 'q=' + encodeURIComponent($("#q").val()) + '&field=' + facetsdata.field //dataString,
            	success: function(data) {
					cache.term = request.term;
					cache.content = data;
					response(data.matches);
				}
            });
        },
    	minLength: 4,
    	select: function(event, ui) {
			log(ui.item ? (ui.item.label) : "Nothing selected, input was ");
		},
    	open: function() {
    		$(this).removeClass("ui-corner-all").addClass("ui-corner-top");
    	},
    	close: function() {
    		$(this).removeClass("ui-corner-top").addClass("ui-corner-all");
    	}
    });
    $(window).scroll(function(event) {
        // what the y position of the scroll is
        var y = $(this).scrollTop();        
        // whether that's below the form
        if (y >= top) {
          // if so, add the fixed class
          $('#facets-space').addClass('fixed');
        } else {
          // otherwise remove it
          $('#facets-space').removeClass('fixed');
        }
    });
    $("#sort-order").change(function() {
        var mysort = "sort=" + jQuery.url.param("sort");
        if ($(this).val() == "score-desc") {
            window.location.href = window.location.href.replace(mysort, "sort=score-desc");
        } else if ($(this).val() == "score-asc") {
            window.location.href = window.location.href.replace(mysort, "sort=score-asc");
        } else if ($(this).val() == "cre-desc") {
            window.location.href = window.location.href.replace(mysort, "sort=cre-desc");
        } else if ($(this).val() == "cre-asc") {
            window.location.href = window.location.href.replace(mysort, "sort=cre-asc");
        } else if ($(this).val() == "pubdate-asc") {
            window.location.href = window.location.href.replace(mysort, "sort=pubdate-asc");
        } else if ($(this).val() == "pubdate-desc") {
            window.location.href = window.location.href.replace(mysort, "sort=pubdate-desc");
        } else {
            window.location.href = window.location.href.replace(mysort, "sort=score-desc");
        }
    });
});


