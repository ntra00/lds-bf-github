jQuery(function() {
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
    $("#number_hits_sel").change(function() {
        var mycount = "count=" + jQuery.url.param("count");
        if ($(this).val() == "hits25") {
            window.location.href = window.location.href.replace(mycount, "count=25");
        } else if ($(this).val() == "hits10") {
	    window.location.href = window.location.href.replace(mycount, "count=10");
	} else {
            window.location.href = window.location.href.replace(mycount, "count=10");
        }
    });
});


